function [satPositions,dtr] = getSatPos(transmitTime,eph)
%SATPOS Calculation of X,Y,Z satellites coordinates at TRANSMITTIME for
%given ephemeris EPH. Coordinates are calculated for each satellite in the
%list PRNLIST.
%[satPositions, satClkCorr] = satpos(transmitTime, prnList, eph);
%
%   Inputs:
%       transmitTime  - transmission time: 1 by settings.numberOfChannels
%       prnList       - list of PRN-s to be processed
%       eph           - ephemeridies of satellites
%
%   Outputs:
%       satPositions  - positions of satellites (in ECEF system [X; Y; Z])
% -------------------------------------------------------------------------
%                    SoftSim: GPS IF signal simulator 
% Author: 
%        Yafeng Li 
%        @ Beijing Information Science and Technology University(BISTU)
% 2021. 02. 18
% -------------------------------------------------------------------------
%

%% Initialize constants ===================================================
% GPS constatns
gpsPi          = 3.1415926535898;  % Pi used in the GPS coordinate system

%--- Constants for satellite position calculation -------------------------
Omegae_dot     = 7.2921151467e-5;  % Earth rotation rate, [rad/s]
GM             = 3.986005e14;      % Earth's universal gravitational constant
F              = -4.442807633e-10; % Constant, [sec/(meter)^(1/2)]

%% Find satellite's position ----------------------------------------------

% Restore semi-major axis
a   = eph.sqrta * eph.sqrta;

% Time correction
tk  = check_t(transmitTime - eph.toe);

% Initial mean motion
n0  = sqrt(GM / a^3);
% Mean motion
n   = n0 + eph.deltan;

% Mean anomaly
M   = eph.M0 + n * tk;
% Reduce mean anomaly to between 0 and 360 deg
M   = rem(M + 2*gpsPi, 2*gpsPi);

%Initial guess of eccentric anomaly
E   = M;

%--- Iteratively compute eccentric anomaly ----------------------------
for ii = 1:10
    E_old   = E;
    E       = M + eph.ecc * sin(E);
    dE      = rem(E - E_old, 2*gpsPi);
    
    if abs(dE) < 1.e-12
        % Necessary precision is reached, exit from the loop
        break;
    end
end

% Reduce eccentric anomaly to between 0 and 360 deg
E   = rem(E + 2*gpsPi, 2*gpsPi);

%Calculate the true anomaly
nu   = atan2(sqrt(1 - eph.ecc^2) * sin(E), cos(E)-eph.ecc);

% Relativistic correction
dtr = F * eph.ecc * eph.sqrta * sin(E);

%Compute angle phi
phi = nu + eph.omega;
%Reduce phi to between 0 and 360 deg
phi = rem(phi, 2*gpsPi);

%Correct argument of latitude
u = phi + ...
    eph.cuc * cos(2*phi) + ...
    eph.cus * sin(2*phi);
% Correct radius
r = a * (1 - eph.ecc*cos(E)) + ...
    eph.crc * cos(2*phi) + ...
    eph.crs * sin(2*phi);
% Correct inclination
i = eph.i0 + eph.idot * tk + ...
    eph.cic * cos(2*phi) + ...
    eph.cis * sin(2*phi);

% SV position in orbital plane
xk1 = cos(u)*r;
yk1 = sin(u)*r;

%Compute the angle between the ascending node and the Greenwich meridian
Omega = eph.Omega0 + (eph.Omegadot - Omegae_dot)*tk - ...
    Omegae_dot * eph.toe;
%Reduce to between 0 and 360 deg
Omega = rem(Omega + 2*gpsPi, 2*gpsPi);

%--- Compute satellite coordinates ------------------------------------
xk = xk1 * cos(Omega) - yk1 * cos(i)*sin(Omega);
yk = xk1 * sin(Omega) + yk1 * cos(i)*cos(Omega);
zk = yk1 * sin(i);
satPositions = [xk; yk; zk];
