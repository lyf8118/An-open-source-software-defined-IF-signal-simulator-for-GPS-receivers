function Checksum = computeChecksum(source, niBit)
% Compute the Checksum for one given word of a subframe
% source The input data
% niBit Does this word contain non-information-bearing bits?
% returns Computed Checksum

% 	Bits 31 to 30 = 2 LSBs of the previous transmitted word, D29* and D30*
% 	Bits 29 to  6 = Source data bits, d1, d2, ..., d24
% 	Bits  5 to  0 = Empty parity bits

% 	Bits 31 to 30 = 2 LSBs of the previous transmitted word, D29* and D30*
% 	Bits 29 to  6 = Data bits transmitted by the SV, D1, D2, ..., D24
% 	Bits  5 to  0 = Computed parity bits, D25, D26, ..., D30

% 	                  1            2           3
% 	bit    12 3456 7890 1234 5678 9012 3456 7890
% 	---    -------------------------------------
% 	D25    11 1011 0001 1111 0011 0100 1000 0000
% 	D26    01 1101 1000 1111 1001 1010 0100 0000
% 	D27    10 1110 1100 0111 1100 1101 0000 0000
% 	D28    01 0111 0110 0011 1110 0110 1000 0000
% 	D29    10 1011 1011 0001 1111 0011 0100 0000
% 	D30    00 1011 0111 1010 1000 1001 1100 0000
% -------------------------------------------------------------------------
%                SoftSim: GPS IF signal simulator 
% Author: 
%        Yafeng Li 
%        @ Beijing Information Science and Technology University(BISTU)
% 2021. 02. 18
% -------------------------------------------------------------------------
%
source = uint32(source);
bmask = uint32([0x3B1F3480, 0x1D8F9A40, 0x2EC7CD00, ...
    0x1763E680, 0x2BB1F340, 0x0B7A89C0]);

d = bitand(source, uint32(0x3FFFFFC0));
% D29 = (source>>31)&0x1UL
D29 = bitand(bitshift(source,-31),uint32(0x1));
% D30 = (source>>30)&0x1UL;
D30 = bitand(bitshift(source,-30),uint32(0x1));

% Non-information bearing bits for word 2 and 10
if (niBit)
    % Solve bits 23 and 24 to presearve parity check
    % with zeros in bits 29 and 30.
    temp0 = bitand(bmask(5),d);
    if rem(D30 + countBits(temp0),2)
        % d ^= (0x1UL<<6);
        temp1 = bitshift(uint32(0x1),6);
        d = bitxor(d,temp1);
    end
    
    temp0 = bitand(bmask(6),d);
    if rem(D29 + countBits(temp0),2)
        % d ^= (0x1UL<<7);
        temp1 = bitshift(uint32(0x1),7);
        d = bitxor(d,temp1);
    end
end

Checksum = d;
if (D30)
    % Checksum ^= 0x3FFFFFC0UL
    Checksum = bitxor(Checksum,uint32(0x3FFFFFC0));
end

% Checksum |= ((D29 + countBits(bmask[0] & d)) % 2) << 5
temp0 = bitand(bmask(1),d);
temp1 = rem(D29 + countBits(temp0),2);
Checksum = bitor(Checksum, bitshift(temp1,5));

% Checksum |= ((D30 + countBits(bmask[1] & d)) % 2) << 4
temp0 = bitand(bmask(2),d);
temp1 = rem(D30 + countBits(temp0),2);
Checksum = bitor(Checksum, bitshift(temp1,4));

% Checksum |= ((D29 + countBits(bmask[2] & d)) % 2) << 3
temp0 = bitand(bmask(3),d);
temp1 = rem(D29 + countBits(temp0),2);
Checksum = bitor(Checksum, bitshift(temp1,3));

% Checksum |= ((D30 + countBits(bmask[3] & d)) % 2) << 2
temp0 = bitand(bmask(4),d);
temp1 = rem(D30 + countBits(temp0),2);
Checksum = bitor(Checksum, bitshift(temp1,2));

% Checksum |= ((D30 + countBits(bmask[4] & d)) % 2) << 1
temp0 = bitand(bmask(5),d);
temp1 = rem(D30 + countBits(temp0),2);
Checksum = bitor(Checksum, bitshift(temp1,1));

% Checksum |= ((D29 + countBits(bmask[5] & d)) % 2)
temp0 = bitand(bmask(6),d);
temp1 = rem(D29 + countBits(temp0),2);
Checksum = bitor(Checksum, temp1);
% Output
Checksum = bitand(Checksum,uint32(0x3FFFFFFF));


