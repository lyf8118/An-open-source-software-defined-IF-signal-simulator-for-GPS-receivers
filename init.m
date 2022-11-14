% -------------------------------------------------------------------------
%                    SoftSim: GPS IF signal simulator
% Author:
%        Yafeng Li
%        @ Beijing Information Science and Technology University(BISTU)
% 2021. 08. 18
% -------------------------------------------------------------------------
%
%% Clean up the environment first =================================
clear; close all; clc;
format long g

%% Initialize constants, settings =================================
settings = initSettings();

%% Main script generating IF signals ==============================
disp(['   IF signal generating started at ', datestr(now)]);
% The main process
signalGenerating(settings);

%% Generate plot of generated IF data =============================
fprintf('Probing data (%s)...\n', settings.IfFile) 
probeData(settings);
disp(['   IF signal simulation is over at', datestr(now)])
