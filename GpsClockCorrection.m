function satClkCorr = GpsClockCorrection(transmitTime,eph)
% -------------------------------------------------------------------------
%             SoftSim: GPS IF signal simulator 
% Author: 
%        Yafeng Li 
%        @ Beijing Information Science and Technology University(BISTU)
% 2021. 02. 18
% -------------------------------------------------------------------------
%
%--- Find time difference
dt = check_t(transmitTime - eph.toc);
% Calculate clock correction
satClkCorr = (eph.af2 * dt + eph.af1) * dt + eph.af0 - eph.tgd;