function coef = getFliterCoef(settings)
% -------------------------------------------------------------------------
%                    SoftSim: GPS IF signal simulator 
% Author: 
%        Yafeng Li 
%    @ Beijing Information Science and Technology University(BISTU)
%    2021. 02. 18
% -------------------------------------------------------------------------
if settings.fileType == 1
    % For real IF siganls
    w1 = settings.IF - settings.FeBandwidth/2;
    w2 = settings.IF + settings.FeBandwidth/2;
    wp = [w1*2/settings.samplingFreq - 0.002, w2*2/settings.samplingFreq + 0.002];
    coef = fir1(settings.FeOrder,wp);
elseif settings.fileType == 2
    % For complex IF signals
    coef = fir1(settings.FeOrder,settings.FeBandwidth/settings.samplingFreq);
end