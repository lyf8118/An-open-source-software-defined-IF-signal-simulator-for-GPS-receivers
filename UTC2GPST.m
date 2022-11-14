function [week,sow] = UTC2GPST(year, monthnum,dayofmonth,hour, minute, second)
%UTC2GPSTime onvert a UTC date into a GPS date
%   INPUTS
%         year          - year of UTC
%         monthnum      - monthnum of UTC
%         dayofmonth    - dayofmonth of UTC
%   OUTPUTS
%         week          - week of GPS Time
%         sow           - second of week of GPS Time
% -------------------------------------------------------------------------
doy = [0,31,59,90,120,151,181,212,243,273,304,334];
ye = year - 1980;

% Compute the number of leap days since Jan 5/Jan 6, 1980.
lpdays = floor(ye/4) + 1;
if (rem(ye,4) == 0) && (monthnum <=2)
    lpdays = lpdays - 1;
end

% Compute the number of days elapsed since Jan 5/Jan 6, 1980.
de = ye*365 + doy(monthnum) + dayofmonth + lpdays - 6;

% Convert time to GPS weeks and seconds.
week = floor(de / 7);
sow = rem(de,7) * 86400 + hour * 3600 + minute*60 + second;


