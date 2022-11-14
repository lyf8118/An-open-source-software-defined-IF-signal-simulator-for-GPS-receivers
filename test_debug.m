clear;clc;close all
% navWord.dataWord = uint32([583008274 707790100 484411381 1073741782 41 1073741782 41 1073741782 41 ...
%     1073741600 583008274 707797480 838074402 41 1073741782 41 1073741110 ...
%     387949605 1073741600 1067697996 583008274 707805816 385913518 223139129 ...
%     941980554 8290424 97730324 1023023029 1017982811 542900084 583008274 ...
%     707814384 1073269125 220349228 166342 182561823 933772105 935984602 ...
%     1072282104 386173464 583008274 707822592 503824608 1065374439 46153312 ...
%     581 1073741782 8636472 69353941 998244304 583008274 707831176 484411381 ...
%     1073741782 41 1073741782 41 1073741782 41 1073741600]);

[eph,ionoutc] = rinexeV2('brdc3540.14n');

% Genaerate Nav message according to the ephemeris 
frameMsg = eph2sbf(eph(1),ionoutc);

ephTime.second = eph(1).toc;
ephTime.weekNrm = eph(1).weekNrm;

% Modulate WN, TOW and CRC- into Nav messages
navWord = generateNavMsg(frameMsg,ephTime,1);

% Extract data bits from nav message
dataBit = zeros(1,30*60);
for nitindex = 1:60
dataBit((nitindex-1) * 30 + 1 : nitindex * 30) = bitget(navWord.dataWord(nitindex),30:-1:1) *2 - 1;
end

% Verify
I_P_InputBits = kron(dataBit, ones(1, 20));
[eph2, subFrameStart,TOW] = NAVdecoding(I_P_InputBits)

