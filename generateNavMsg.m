function [navWord,refTime] = generateNavMsg(ephFrame,ephTime,initFlag,navWord)
%
%                SoftSim: GPS IF signal simulator 
% Author: 
%        Yafeng Li 
%        @ Beijing Information Science and Technology University(BISTU)
% 2021. 01. 18
% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
% week number
wn = int32(rem(ephTime.weekNrm,1024));
wn = typecast(wn,'uint32');
refTime = floor(ephTime.second/30)*30;
% Time of week
tow = int32(refTime/6);
tow = typecast(tow,'uint32');

%% ==================== Initializztion ==============================
if (initFlag == 1) % Initialize subframe 5
    % Allocate space for data words (5 plus 1 subframe)
    navWord = uint32(zeros(1,60));
    
    prevwrd = uint32(0);
    for wordIndex = 1:10
        sbfwrd = ephFrame(5,wordIndex);
        % Add TOW-count message into HOW
        if(wordIndex == 2)
            % sbfwrd |= ((tow&0x1FFFFUL)<<13);
            temp0 = bitshift(bitand(tow,uint32(0x1FFFF)),13);
            sbfwrd = bitor(sbfwrd,temp0);
        end
        % ---------------- Compute checksum -------------------------------
        % 2 LSBs of the previous transmitted word
        temp0 = bitand(bitshift(prevwrd,30),uint32(0xC0000000));
        sbfwrd = bitor(sbfwrd,temp0);
        % Non-information bearing bits for word 2 and 10
        if (wordIndex == 2) || (wordIndex == 10)
            niBit = 1;
        else
            niBit = 0;
        end
        % Nav data word
        navWord(wordIndex) = computeChecksum(sbfwrd, niBit);
        prevwrd = navWord(wordIndex);
    end
else % Save subframe 5
    for wordIndex = 1:10
        navWord(wordIndex) = navWord(50+wordIndex);
        prevwrd = navWord(wordIndex);
    end
end

for subfIndex = 1:5
    tow = tow + 1;
    for wordIndex = 1:10
        sbfwrd = ephFrame(subfIndex,wordIndex);
        % Add transmission week number to Subframe 1
        if (subfIndex==1)&&(wordIndex==3)
            % frameWord |= (wn&0x3FFUL)<<20
            temp0 = bitshift(bitand(wn,uint32(0x3FF)),20);
            sbfwrd = bitor(sbfwrd,temp0);
        end
        
        % Add TOW-count message into HOW
        if wordIndex == 2
            % frameWord |= ((tow&0x1FFFFUL)<<13);
            temp0 = bitshift(bitand(tow,uint32(0x1FFFF)),13);
            sbfwrd = bitor(sbfwrd,temp0);
        end
        
        % ---------------- Compute checksum -------------------------------
        % 2 LSBs of the previous transmitted word
        temp0 = bitand(bitshift(prevwrd,30),uint32(0xC0000000));
        sbfwrd = bitor(sbfwrd,temp0);
        % Non-information bearing bits for word 2 and 10
        if (wordIndex == 2) || (wordIndex == 10)
            niBit = 1;
        else
            niBit = 0;
        end
        % Nav data word
        navWord(subfIndex * 10 + wordIndex) = computeChecksum(sbfwrd, niBit);
        prevwrd = navWord(subfIndex * 10 + wordIndex);
    end
end




