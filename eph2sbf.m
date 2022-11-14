function frame = eph2sbf(eph,ionoutc)
%eph2sbf Generate subframe acorrding to current eph
%  INPUT
%       eph      - Ephemeris of given SV
%       ionoutc  - Ionosphere related parameters
% OUTPUT
%       sbf      - rray of five sub-frames, 10 long words each
% -------------------------------------------------------------------------
%                  SoftSim: GPS IF signal Sosimulator 
% Author: 
%        Yafeng Li 
%        @ Beijing Information Science and Technology University(BISTU)
% 2021. 02. 18
% -------------------------------------------------------------------------
%
%% =========================== constant =============================
% Pi used in the GPS coordinate system
gpsPi = 3.1415926535898; 
POW2_M5 = 2^(-5);
POW2_M19 = 2^(-19);
POW2_M29 = 2^(-29);
POW2_M31 = 2^(-31);
POW2_M33 = 2^(-33);
POW2_M43 = 2^(-43);
POW2_M55 = 2^(-55);
POW2_M50 = 2^(-50);
POW2_M30 = 2^(-30);
POW2_M27 = 2^(-27);
POW2_M24 = 2^(-24);

%% =================== Variables to be modulated ==================== 
dataId = uint32(1);
sbf5_page25_svId = uint32(51);
sbf4_page18_svId = uint32(56);

% This has to be the "transmission" week number, not for the ephemeris 
% reference time
wn = uint32(0);
ura = uint32(eph.svaccur);
toe = uint32(floor(eph.toe/16.0));
toc = uint32(floor(eph.toc/16.0));
iode = uint32(round(eph.iode));
iodc = uint32(round(eph.iodc));
% original int32 and its type cast ---------
deltan = int32(round(eph.deltan/POW2_M43/gpsPi)); 
deltan = typecast(deltan,'uint32');
%
cuc = int32(round(eph.cuc/POW2_M29));
cuc = typecast(cuc,'uint32');
%
cus = int32(round(eph.cus/POW2_M29));
cus = typecast(cus,'uint32');
%
cic = int32(round(eph.cic/POW2_M29));
cic = typecast(cic,'uint32');
%
cis = int32(round(eph.cis/POW2_M29));
cis = typecast(cis,'uint32');
%
crc = int32(round(eph.crc/POW2_M5));
crc = typecast(crc,'uint32');
%
crs = int32(round(eph.crs/POW2_M5));
crs = typecast(crs,'uint32');
% 
ecc = uint32(round(eph.ecc/POW2_M33));
sqrta = uint32(round(eph.sqrta/POW2_M19));
% 
m0 = int32(round(eph.M0/POW2_M31/gpsPi));
m0 = typecast(m0,'uint32');
%
omg0 = int32(round(eph.Omega0/POW2_M31/gpsPi));
omg0 = typecast(omg0,'uint32');
%
inc0 = int32(round(eph.i0/POW2_M31/gpsPi));
inc0 = typecast(inc0,'uint32');
%
aop = int32(round(eph.omega/POW2_M31/gpsPi));
aop = typecast(aop,'uint32');
%
omgdot = int32(round(eph.Omegadot/POW2_M43/gpsPi));
omgdot = typecast(omgdot,'uint32');
%
idot = int32(round(eph.idot/POW2_M43/gpsPi));
idot = typecast(idot,'uint32');
%
af0 = int32(round(eph.af0/POW2_M31));
af0 = typecast(af0,'uint32');
%
af1 = int32(round(eph.af1/POW2_M43));
af1 = typecast(af1,'uint32');
%
af2 = int32(round(eph.af2/POW2_M55));
af2 = typecast(af2,'uint32');
%
tgd = int32(round(eph.tgd/POW2_M31));
tgd = typecast(tgd,'uint32');
%
svhlth = uint32(floor(eph.svhealth));
codeL2 = uint32(floor(eph.codeL2));
wna = uint32(floor(rem(eph.weekNrm,256)));
toa = uint32(floor(eph.toe/4096.0));
%
alpha0 = int32(round(ionoutc.alpha0/POW2_M30));
alpha0 = typecast(alpha0,'uint32');
alpha1 = int32(round(ionoutc.alpha1/POW2_M27));
alpha1 = typecast(alpha1,'uint32');
alpha2 = int32(round(ionoutc.alpha2/POW2_M24));
alpha2 = typecast(alpha2,'uint32');
alpha3 = int32(round(ionoutc.alpha3/POW2_M24));
alpha3 = typecast(alpha3,'uint32');
beta0 = int32(round(ionoutc.beta0/2048.0));
beta0 = typecast(beta0,'uint32');
beta1 = int32(round(ionoutc.beta1/16384.0));
beta1 = typecast(beta1,'uint32');
beta2 = int32(round(ionoutc.beta2/65536.0));
beta2 = typecast(beta2,'uint32');
beta3 = int32(round(ionoutc.beta3/65536.0));
beta3 = typecast(beta3,'uint32');
A0 = int32(round(ionoutc.A0/POW2_M30));
A0 = typecast(A0,'uint32');
A1 = int32(round(ionoutc.A1/POW2_M50));
A1 = typecast(A1,'uint32');
dtls = int32(round((ionoutc.dtls)));
dtls = typecast(dtls,'uint32');
% 
tot = uint32(round(ionoutc.tot/4096));
wnt = uint32(round(rem(ionoutc.wnt,256)));
% TO DO: Specify scheduled leap seconds in command options
wnlsf = uint32(rem(1929,256));
dn = uint32(7);
dtlsf = int32(18);
dtlsf = typecast(dtlsf,'uint32');

%% =========================== Subframe 1 ===========================
% ------- 1st word --------
sbf1(1) = bitshift(uint32(0x8B0000),6);
% ------- 2nd word -------
sbf1(2) = bitshift(uint32(0x1),8);
% ------- 3rd word -------
% ((wn&0x3FFUL)<<20) | ((codeL2&0x3UL)<<18) | ((ura&0xFUL)<<14) | ...  
% ((svhlth&0x3FUL)<<8) | (((iodc>>8)&0x3UL)<<6);
temp0 = bitshift(bitand(wn,uint32(0x3FF)),20);
temp1 = bitshift(bitand(codeL2,uint32(0x3)),18);
temp2 = bitshift(bitand(ura,uint32(0xF)),14);
temp3 = bitshift(bitand(svhlth,uint32(0x3F)),8);
temp4 = bitshift(  bitand(bitshift(iodc,-8),uint32(0x3)),  6);
sbf1(3) = comBitor(5,temp0,temp1,temp2,temp3,temp4);
% ------- 4th word -------
sbf1(4) = uint32(0);
% ------- 5th word -------
sbf1(5) = uint32(0);
% ------- 6th word -------
sbf1(6) = uint32(0);
% ------- 7th word -------
sbf1(7) = bitshift(bitand(tgd,uint32(0xFF)),6); % (tgd&0xFFUL)<<6
% ------- 8th word -------
temp0 = bitshift(bitand(iodc,uint32(0xFF)),22);
temp1 = bitshift(bitand(toc,uint32(0xFFFF)),6);
sbf1(8) = bitor(temp0,temp1);      % ((iodc&0xFFUL)<<22) | ((toc&0xFFFFUL)<<6)
% ------- 9th word -------
temp0 = bitshift(bitand(af2,uint32(0xFF)),22);
temp1 = bitshift(bitand(af1,uint32(0xFFFF)),6);
sbf1(9) = bitor(temp0,temp1);     % ((af2&0xFFUL)<<22) | ((af1&0xFFFFUL)<<6);
% ------- 10th word -------
sbf1(10) = bitshift(bitand(af0,uint32(0x3FFFFF)),8);  % 

%% =========================== Subframe 2 ===========================
% ------- 1st word --------
sbf2(1) = bitshift(uint32(0x8B0000),6);         %  0x8B0000UL<<6;
% ------- 2nd word --------
sbf2(2) = bitshift(uint32(0x2),8);         %  0x2UL<<8;
% ------- 3rd word --------
temp0 = bitshift(bitand(iode,uint32(0xFF)),22);
temp1 = bitshift(bitand(crs,uint32(0xFFFF)),6);
sbf2(3) = bitor(temp0,temp1);     % ((iode&0xFFUL)<<22) | ((crs&0xFFFFUL)<<6);
% ------- 4th word --------
temp0 = bitshift(bitand(deltan,uint32(0xFFFF)),14);
temp1 = bitshift(  bitand(bitshift(m0,-24),uint32(0xFF)),  6);
sbf2(4) = bitor(temp0,temp1);     % ((deltan&0xFFFFUL)<<14) | (((m0>>24)&0xFFUL)<<6);
% ------- 5th word --------
sbf2(5) = bitshift(bitand(m0,uint32(0xFFFFFF)),6);       %(m0&0xFFFFFFUL)<<6;
% ------- 6th word --------
temp0 = bitshift(bitand(cuc,uint32(0xFFFF)),14);
temp1 = bitshift(  bitand(bitshift(ecc,-24),uint32(0x0FF)),  6);
sbf2(6) = bitor(temp0,temp1);     % ((cuc&0xFFFFUL)<<14) | (((ecc>>24)&0xFFUL)<<6);
% ------- 7th word --------
sbf2(7) = bitshift(bitand(ecc,uint32(0xFFFFFF)),6);       %(ecc&0xFFFFFFUL)<<6;
% ------- 8th word --------
temp0 = bitshift(bitand(cus,uint32(0xFFFF)),14);
temp1 = bitshift(  bitand(bitshift(sqrta,-24),uint32(0xFF)),  6);
sbf2(8) = bitor(temp0,temp1);     % ((cus&0xFFFFUL)<<14) | (((sqrta>>24)&0xFFUL)<<6);
% ------- 9th word --------
sbf2(9) = bitshift(bitand(sqrta,uint32(0xFFFFFF)),6);       %(sqrta&0xFFFFFFUL)<<6;
% ------- 10th word --------
sbf2(10) = bitshift(bitand(toe,uint32(0xFFFF)),14);       % (toe&0xFFFFUL)<<14;

%% =========================== Subframe 3 ===========================
% ------- 1st word --------
sbf3(1) = bitshift(uint32(0x8B0000),6);         %  0x8B0000UL<<6;
% ------- 2nd word --------
sbf3(2) = bitshift(uint32(0x3),8);         %  0x3UL<<8;
% ------- 3rd word --------
% ((cic&0xFFFFUL)<<14) | (((omg0>>24)&0xFFUL)<<6)
temp0 = bitshift(bitand(cic,uint32(0xFFFF)),14);
temp1 = bitshift(omg0,-24);
temp2 = bitshift(bitand(temp1,uint32(0xFF)),6);
sbf3(3) = bitor(temp0,temp2);   
% ------- 4th word --------
sbf3(4) = bitshift(bitand(omg0,uint32(0xFFFFFF)),6);    % (omg0&0xFFFFFFUL)<<6;
% ------- 5th word --------
temp0 = bitshift(bitand(cis,uint32(0xFFFF)),14);
temp1 = bitshift(  bitand(bitshift(inc0,-24),uint32(0xFF)),  6);
sbf3(5) = bitor(temp0,temp1);     % ((cis&0xFFFFUL)<<14) | (((inc0>>24)&0xFFUL)<<6);
% ------- 6th word --------
sbf3(6) = bitshift(bitand(inc0,uint32(0xFFFFFF)),6);    % (inc0&0xFFFFFFUL)<<6;
% ------- 7th word --------
temp0 = bitshift(bitand(crc,uint32(0xFFFF)),14);
temp1 = bitshift(  bitand(bitshift(aop,-24),uint32(0xFF)),  6);
sbf3(7) = bitor(temp0,temp1);     % ((crc&0xFFFFUL)<<14) | (((aop>>24)&0xFFUL)<<6);
% ------- 8th word --------
sbf3(8) = bitshift(bitand(aop,uint32(0xFFFFFF)),6);    % (aop&0xFFFFFFUL)<<6;
% ------- 9th word --------
sbf3(9) = bitshift(bitand(omgdot,uint32(0xFFFFFF)),6);    
% ------- 10th word --------
temp0 = bitshift(bitand(iode,uint32(0xFF)),22);
temp1 = bitshift(bitand(idot,uint32(0x3FFF)),8);
sbf3(10) = bitor(temp0,temp1);     %((iode&0xFFUL)<<22) | ((idot&0x3FFFUL)<<8);

%% ====================== Subframe 4 (page 25) ====================== 
% ------- 1st word --------
sbf4(1) = bitshift(uint32(0x8B0000),6);         %  0x8B0000UL<<6;
% ------- 2nd word --------
sbf4(2) = bitshift(uint32(0x4),8);         %  0x4UL<<8;
% ------- 3rd word --------
% (dataId<<28) | (sbf4_page18_svId<<22) | ((alpha0&0xFFUL)<<14) | ((alpha1&0xFFUL)<<6);
temp0 = bitshift(dataId,28);
temp1 = bitshift(sbf4_page18_svId,22);
temp2 = bitshift(bitand(alpha0,uint32(0xFF)),14);
temp3 = bitshift(bitand(alpha1,uint32(0xFF)),6);
sbf4(3) = comBitor(4,temp0,temp1,temp2,temp3);  
% ------- 4th word --------
% ((alpha2&0xFFUL)<<22) | ((alpha3&0xFFUL)<<14) | ((beta0&0xFFUL)<<6);
temp0 = bitshift(bitand(alpha2,uint32(0xFF)),22);
temp1 = bitshift(bitand(alpha3,uint32(0xFF)),14);
temp2 = bitshift(bitand(beta0,uint32(0xFF)),6);
sbf4(4) = comBitor(3,temp0,temp1,temp2);  
% ------- 5th word --------
% ((beta1&0xFFUL)<<22) | ((beta2&0xFFUL)<<14) | ((beta3&0xFFUL)<<6)
temp0 = bitshift(bitand(beta1,uint32(0xFF)),22);
temp1 = bitshift(bitand(beta2,uint32(0xFF)),14);
temp2 = bitshift(bitand(beta3,uint32(0xFF)),6);
sbf4(5) = comBitor(3,temp0,temp1,temp2);  
% ------- 6th word --------
% (A1&0xFFFFFFUL)<<6;
sbf4(6) = bitshift(bitand(A1,uint32(0xFFFFFF)),6);
% ------- 7th word --------
% ((A0>>8)&0xFFFFFFUL)<<6
temp0 = bitand(bitshift(A0,-8),uint32(0xFFFFFF));
sbf4(7) = bitshift(temp0,6);
% ------- 8th word --------
% ((A0&0xFFUL)<<22) | ((tot&0xFFUL)<<14) | ((wnt&0xFFUL)<<6)
temp0 = bitshift(bitand(A0,uint32(0xFF)),22);
temp1 = bitshift(bitand(tot,uint32(0xFF)),14);
temp2 = bitshift(bitand(wnt,uint32(0xFF)),6);
sbf4(8) = comBitor(3,temp0,temp1,temp2); 
% ------- 9th word --------
% ((dtls&0xFFUL)<<22) | ((wnlsf&0xFFUL)<<14) | ((dn&0xFFUL)<<6)
temp0 = bitshift(bitand(dtls,uint32(0xFF)),22);
temp1 = bitshift(bitand(wnlsf,uint32(0xFF)),14);
temp2 = bitshift(bitand(dn,uint32(0xFF)),6);
sbf4(9) = comBitor(3,temp0,temp1,temp2); 
% ------- 10th word --------
% (dtlsf&0xFFUL)<<22
sbf4(10) = bitshift(bitand(dtlsf,uint32(0xFF)),22);

%% ====================== Subframe 5 (page 25) ======================
% ------- 1st word --------
sbf5(1) = bitshift(uint32(0x8B0000),6);        
% ------- 2nd word --------
sbf5(2) = bitshift(uint32(0x5),8);         
% ------- 3rd word --------
temp0 = bitshift(dataId,28);
temp1 = bitshift(sbf5_page25_svId,22);
temp2 = bitshift(bitand(toa,uint32(0xFF)),14);
temp3 = bitshift(bitand(wna,uint32(0xFF)),6);
sbf5(3) = comBitor(4,temp0,temp1,temp2,temp3);
% ------- 4th word -------- Almanac not modulated 
sbf5(4) = uint32(0x55555555);
sbf5(5) = uint32(0x55555555); 
sbf5(6) = uint32(0x55555555);
sbf5(7) = uint32(0x55555555); 
sbf5(8) = uint32(0x55555555); 
sbf5(9) = uint32(0x55555555); 
sbf5(10) = uint32(0x55555555); 

%% The total navigation message
% sbf = [sbf1, sbf2,sbf3,sbf4,sbf5];
% frame.sbf1 = sbf1;
% frame.sbf2 = sbf2;
% frame.sbf3 = sbf3;
% frame.sbf4 = sbf4;
% frame.sbf5 = sbf5;
frame = [sbf1; sbf2; sbf3; sbf4; sbf5];
end
