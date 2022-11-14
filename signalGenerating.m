function signalGenerating(settings)
% Main script generating IF signals
% Input:
%         settings    - IF simulator settings
%      
% -------------------------------------------------------------------------
%                   SoftSim: GPS IF signal simulator 
% Author: 
%        Yafeng Li 
%    @ Beijing Information Science and Technology University(BISTU)
%    2022. 08. 18
% -------------------------------------------------------------------------
%
%
%% Load trajectory ================================================
[ECEFx,ECEFy,ECEFz] = geo2cartd(39.9, 116.3, 1000, 5);
trajectory = zeros(150000*10,6);
for index = 1: 150000*10                                            
    trajectory(index,1:6) = [39.9, 116.3, 1000,ECEFx,ECEFy,ECEFz];
end

%% Read ephemeris file ============================================
if settings.rinexVersion == 2
    [eph,ionoutc] = rinexeV2(settings.rinexfile);
elseif settings.rinexVersion == 3
    [eph,ionoutc] = rinexeV3(settings.rinexfile);
end

%% Determine the visible satellite list ===========================
% Starting time of the simulation, corresponding to the first positions 
% in the trajectory 
startTime = eph(1).toc;                                         
% Initail position of the receiver trajectory
RxPosEcef = trajectory(1,4:6);
% Visible satellite list (PRN#)
[satList,elevation,azimuth] = getVisibleSat(eph,startTime,RxPosEcef',settings);

%% Sky plot and C/N0 seting========================================
skyPlot(azimuth',elevation',satList');
% Set C/No: 1.5dB is added for compesating the cross-correlation interference
% between diffierent PRNs
CNoValuesdB = CNoSetting(satList) + 1.5;
% Covert to unite of Hz
CNoValues = 10.^(CNoValuesdB/10);
% Calculate carrier amplitude 
carrAmp = 2 * settings.gwnAmp * sqrt(CNoValues/settings.samplingFreq);
if  settings.fileType == 2
    carrAmp = carrAmp/sqrt(2);
end
%% Initialize data bits for each channle ==========================
for svIndex = 1:length(satList)
    PRN = satList(svIndex);
    % Genaerate Nav message according to the ephemeris
    navBits(svIndex).frameMsg = eph2sbf(eph(PRN),ionoutc); %#ok<*SAGROW>
    
    % Time to generate Nav Messages
    navBits(svIndex).ephTime.second = startTime;
    navBits(svIndex).ephTime.weekNrm = eph(1).weekNrm;
    
    % Modulate WN, TOW and CRC into Nav messages
    [navBits(svIndex).dataWord, navBits(svIndex).refTime] = ...
        generateNavMsg(navBits(svIndex).frameMsg,navBits(svIndex).ephTime,1);
    
    % Extract Nav data bits from nav message
    navBits(svIndex).dataBit = zeros(1,30*60);
    for bitindex = 1:60
        navBits(svIndex).dataBit((bitindex-1) * 30 + 1 : bitindex * 30) = ...
            double(bitget(navBits(svIndex).dataWord(bitindex),30:-1:1)) * 2 - 1;
    end
end

%% Generate C/A code table
% Get a vector with the C/A code sampled 1x/chip
for svIndex = 1:length(satList)
    PRN = satList(svIndex);
    caCode = generateCAcode(PRN);
    caCodeTable(svIndex,:) = [caCode(end) caCode caCode(1)];
end

%% Allocate variables and spaces ==================================
% Sample counts within each transmitting time calculation step (1 ms) 
blockSize = round(settings.samplingFreq * 0.001);
% Time interval for each transmitting time calculation step (the calculation
% step may not be exactly the same as 1 ms). The time interval of position
% samples in trajectory must equal blockTime.
blockTime = blockSize/settings.samplingFreq;
% Iteration count   （每次循环1ms。分割成10个发射时间计算点）
iterCnt = round(settings.msToProcess/1000/blockTime);

% Initialize Rx Time and Rx postions 
RxTime(1) = startTime;
RxTime(2) = RxTime(1) + blockTime;
RxPosEcef(1:2,:)  = trajectory(1:2,4:6);
% Local oscilator frequency in rad
localOsFreq = (settings.carrFreqBasis - settings.IF) * 2 * pi;
% RF signal freq in rad
carrFreqRad = settings.carrFreqBasis * 2 * pi;
% Nav bit period
bitPeriod = 0.001 * 20;
% Front end filter coeffficient
coef = getFliterCoef(settings);
% Open the IF file to save senerated samples 
[fid, ~] = fopen(settings.IfFile, 'w');

% Start waitbar
hwb = waitbar(0,'IF signal generating ...');
barTimeMs  = round(iterCnt * blockTime * 1000); % [ms]

%% Generate IF siganl =============================================
disp('IF signal generating is undegoing, please wait ...')
for loopCnt =  1:iterCnt
    % wait bar ------------------------------------------------------------
    if (rem(loopCnt, 100) == 0)
        Ln = newline;
        processStatus = ['Generating: ', int2str(loopCnt), ...
            ' ms ', ' of ', int2str(barTimeMs), ' msec'];
        try
            waitbar(loopCnt/barTimeMs,hwb,processStatus);
        catch
            % The progress bar was closed. It is used as a signal
            % to stop, "cancel" processing. Exit.
            disp('Progress bar closed, exiting...');
            return
        end
    end

    % Sum of loacal signals of all visible satellites
    if settings.fileType == 1
        localSigSum = zeros(1,blockSize); % samples of 1ms length
    elseif settings.fileType == 2
        localSigSum = complex(zeros(1,blockSize));
    end
        
    for svIndex = 1:length(satList)
        % Compute the transmitting time coresponding to the Rx time -------
        PRN = satList(svIndex);
        [TxTime,satClkErr] = GetTravelTime(RxTime,RxPosEcef,eph(PRN),settings);
        % include tgd, clock error and relativistic effect 
        TxTime = TxTime + satClkErr;
        
        % generate local code, carrier and Nav data -----------------------
        sapcing = (TxTime(2) - TxTime(1))/blockSize;
        TxTimeSample = linspace(TxTime(1),TxTime(2) - sapcing,blockSize);
        sapcing = (RxTime(2) - RxTime(1))/blockSize;
        RxTimeSample = linspace(RxTime(1),RxTime(2) - sapcing,blockSize);
        % local carrier samples
        if  settings.fileType == 1
            localCarr = cos(carrFreqRad * TxTimeSample - localOsFreq * RxTimeSample);
        elseif settings.fileType == 2
            localCarr = exp(-1i*(carrFreqRad * TxTimeSample - localOsFreq * RxTimeSample));
        end
        
        % Local code samples
        codePhase = TxTimeSample * settings.codeFreqBasis;
        codeIndex = ceil(rem(codePhase,settings.codeLength)) + 1;
        localCode = caCodeTable(svIndex,codeIndex);
        % Nav bit samples
        dataTime = TxTimeSample - (navBits(svIndex).refTime - 6);
        bitPhase = ceil(dataTime/bitPeriod);
        localDataBit = navBits(svIndex).dataBit(bitPhase);
        
        % Update Nav date bits --------------------------------------------
        if (TxTime(end) + 1) > (navBits(svIndex).refTime + 30)
            % Time to generate Nav Messages
            navBits(svIndex).ephTime.second = navBits(svIndex).refTime + 30.5;
                        
            % Modulate WN, TOW and CRC into Nav messages
            [navBits(svIndex).dataWord, navBits(svIndex).refTime] = ...
                generateNavMsg(navBits(svIndex).frameMsg,navBits(svIndex).ephTime, ...
                0,navBits(svIndex).dataWord);
            
            % Extract Nav data bits from nav message
            for bitindex = 1:60
                navBits(svIndex).dataBit((bitindex-1) * 30 + 1 : bitindex * 30) = ...
                double(bitget(navBits(svIndex).dataWord(bitindex),30:-1:1)) * 2 - 1;
            end
        end
        
        % Combine each componests of local signals
        localSig = (localCode .* localDataBit .* localCarr) * carrAmp(svIndex);
        localSigSum = localSigSum + localSig;
    end % svIndex = 1:length(satList)
    
    % Update Rx time and receiver position --------------------------------
    RxTime(1) = RxTime(2);
    RxTime(2) = RxTime(2) + blockTime;
    % Corresponding receiver positions 
    RxPosEcef(1,:)  = RxPosEcef(2,:);
    RxPosEcef(2,:)  = trajectory(loopCnt + 1,4:6);
    
    % Add nosie and filter ------------------------------------------------
    if settings.filterEn == 1
        % Generate WGN
        if  settings.fileType == 1
            gwnSamlple = wgn(1,blockSize,settings.gwnAmp^2,'linear');
        elseif settings.fileType == 2
            gwnSamlple = wgn(1,blockSize,settings.gwnAmp^2,'linear')...
                + 1i*wgn(1,blockSize,settings.gwnAmp^2,'linear');
        end
        % Add WGN
        localSigSum = localSigSum + gwnSamlple;
        % Do FE filtering 
%         localSigSum = filter(coef,1,localSigSum);
    end
    
    % ADC quantization ----------------------------------------------------
    if strcmp(settings.dataType,'int8')
        localSigSum = localSigSum/max(real(localSigSum)) * 2^7;
        quantizedSig = int8(localSigSum);
        fwrite(fid,quantizedSig,settings.dataType);
    elseif strcmp(settings.dataType,'int16')
        localSigSum = localSigSum/max(real(localSigSum)) * 2^12;
        quantizedSig = int16(localSigSum); 
        fwrite(fid,quantizedSig,settings.dataType);
    end
    
    if settings.fileType == 2 
        quantizedSig1 = reshape([real(quantizedSig);imag(quantizedSig)],[],1);
        fwrite(fid,quantizedSig1,settings.dataType);
    end
    
end
%% clear environment
fclose(fid);
close(hwb) 

