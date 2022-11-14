function output = comBitor(inputNumnum,inputBit1,inputBit2,inputBit3,inputBit4,inputBit5)
%comBitor: compute bit or of more than 3 uint32 
% -------------------------------------------------------------------------
%                SoftSim: GPS IF signal simulator 
% Author: 
%        Yafeng Li 
%        @ Beijing Information Science and Technology University(BISTU)
% 2021. 02. 18
% -------------------------------------------------------------------------
%
switch inputNumnum
    case 3
        temp1 = bitor(inputBit1,inputBit2);
        output = bitor(temp1,inputBit3);
    case 4
        temp1 = bitor(inputBit1,inputBit2);
        temp2 = bitor(inputBit3,inputBit4);
        output = bitor(temp1,temp2);
    case 5
        temp1 = bitor(inputBit1,inputBit2);
        temp2 = bitor(inputBit3,inputBit4);
        temp3 = bitor(temp2,inputBit5);
        output = bitor(temp1,temp3);
    otherwise
        error("Input unmber error!");
end

end

