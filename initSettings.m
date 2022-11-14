function settings = initSettings()
% -------------------------------------------------------------------------
%                   SoftSim: GPS IF signal simulator 
% Author: 
%        Yafeng Li 
%    @ Beijing Information Science and Technology University(BISTU)
%    2022. 08. 18
% -------------------------------------------------------------------------
%
%% Simulator settings ============================================
% Signal length(milliseconds) to be simulated
settings.msToProcess        = 48000;        %[ms]
% Rinex version  
settings.rinexVersion        = 2;      % 2 or 3
% Name of the rinex file to be used in the simulation
settings.rinexfile           = 'brdc3540.14n';
% Name of the IF file to store the generated signals
settings.IfFile             = 'ifdata_55.bin';
% Data type used to store one sample
settings.dataType           = 'int8';  
% File Types
%1 - 8 bit real samples S0,S1,S2,...
%2 - 8 bit I/Q samples I0,Q0,I1,Q1,I2,Q2,...                      
settings.fileType           = 1;
% Intermediate, sampling and code frequencies
settings.IF                 = 1.364e6;              % [Hz]   1.364e6
settings.samplingFreq       =  5.45e6;              % [Hz]
settings.codeFreqBasis      = 1.023e6;              % [Hz]
% Define number of chips in a code period
settings.codeLength         = 1023.;
% Nominal carrier frequency
settings.carrFreqBasis      = 1575.42e6;            % [Hz]
% White noise amplitude (Sigma): should be set according to the ADC
% quantization level and max C/No values 
settings.gwnAmp             = 40;                    % 
% Front end bandwidth 
settings.FeBandwidth        = 1.3e6 *2;              % [Hz]
% Front end filter order 
settings.FeOrder            = 20;  
% Enable FE filter or not
settings.filterEn           = 1;                    % 1- on,  0 -off 
% Elevation mask to exclude signals from satellites at low elevation
settings.elevationMask      = 10;           %[degrees 0 - 90]

%% Constants ======================================================
settings.c                  = 299792458;    % The speed of light, [m/s]
settings.startOffset        = 68.802;       %[ms] Initial signal travel time


