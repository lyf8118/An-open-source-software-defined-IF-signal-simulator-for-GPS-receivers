function [TxTime,satClkErr] = GetTravelTime(RxTime,RxPos,eph,settings)
% Get signal transmitting time and travel time.
%
%[Txtime,travelTime] = GetTravelTime(RxTime,RxPosEcef,eph,settings)
%
%   Inputs:
%       RxTime            - Signal receiving time.
%       RxPos             - Receiver position in ECEF coordinate.
%       eph               - Ephemeris.
%       settings          - simulator settings.
%   Outputs:
%       Txtime            - Signal transmitting time.
%       travelTime        - Signal travel time.
%--------------------------------------------------------------------------
%
%              SoftSim: GPS IF signal simulator 
% Author: 
%        Yafeng Li 
%        @ Beijing Information Science and Technology University(BISTU)
% 2021. 02. 18
% -------------------------------------------------------------------------
%
% Threshold is 1/10 of the sampling interval
threshold = 0.1/settings.c;

TxTime = zeros(1,length(RxTime));
travelTime = zeros(1,length(RxTime));
% Satellite clock error including relativistic effect and tgd
satClkErr = zeros(1,length(RxTime));

for index = 1:length(RxTime)
    % --- Initialize the transmitting time --------------------------------
    if index == 1
    TxTimeTemp = RxTime(1) - settings.startOffset/1000;
    else
        TxTimeTemp = TxTime(index-1) + RxTime(index) - RxTime(index-1) ;
    end
    % Get current receiver position
    RxPosTemp = RxPos(index,:)';
    
    % --- Search for the transmitting time --------------------------------  
    for iterCnt = 1:10   % the max iteration counts
        % Satellite position at transmitting time
        [satPos,relaError] = getSatPos(TxTimeTemp,eph);
        % Calculate travel time
        traveltimeTemp = norm(satPos - RxPosTemp) / settings.c ;
        
        %--- Correct satellite position (do to earth rotation) --------
        % Convert SV position at signal transmitting time to position
        % at signal receiving time. ECEF always changes with time as
        % earth rotates.
        Rot_X = e_r_corr(traveltimeTemp, satPos);
        % Corrected transmitting time
        traveltimeTemp = norm(Rot_X - RxPosTemp) / settings.c;
        TxtimeCorrect = RxTime(index) - traveltimeTemp;
        
        % Finish iteration for transmitting time search
        if abs(TxtimeCorrect - TxTimeTemp) < threshold
            TxTime(index) = TxtimeCorrect;
            travelTime(index) = traveltimeTemp;
            satClkErr(index) = GpsClockCorrection(TxtimeCorrect,eph) + relaError;
            break
        end
        % For next interation
        TxTimeTemp = TxtimeCorrect;
    end   % iterCnt = 1:10 
end   % index = 1:length(RxTime)
