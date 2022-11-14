function count = countBits(inputValue)
% Count number of bits set to 1
% v word in whihc bits are counted
% returns Count of bits set to 1
% -------------------------------------------------------------------------
%                SoftSim: GPS IF signal simulator 
% Author: 
%        Yafeng Li 
%        @ Beijing Information Science and Technology University(BISTU)
% 2021. 02. 18
% -------------------------------------------------------------------------
%
inputValue = uint32(inputValue);
S = [1, 2, 4, 8, 16];
B = uint32([0x55555555, 0x33333333, 0x0F0F0F0F, 0x00FF00FF, 0x0000FFFF]);

count = inputValue;
% c = ((c >> S[0]) & B[0]) + (c & B[0]);
count = bitand(bitshift(count,-S(1)),B(1)) + bitand(count,B(1));

% c = ((c >> S[1]) & B[1]) + (c & B[1]);
count = bitand(bitshift(count,-S(2)),B(2)) + bitand(count,B(2));

% c = ((c >> S[2]) & B[2]) + (c & B[2]);
count = bitand(bitshift(count,-S(3)),B(3)) + bitand(count,B(3));

% c = ((c >> S[3]) & B[3]) + (c & B[3]);
count = bitand(bitshift(count,-S(4)),B(4)) + bitand(count,B(4));

% c = ((c >> S[4]) & B[4]) + (c & B[4]);
count = bitand(bitshift(count,-S(5)),B(5)) + bitand(count,B(5));

