Ln = newline;
processStatus = ['Generating: ', int2str(loopCnt), ...
    ' ms ', ' of ', int2str(barTimems), ' msec'];
try
    waitbar(loopCnt/barTimems,hwb,processStatus);
catch
    % The progress bar was closed. It is used as a signal
    % to stop, "cancel" processing. Exit.
    disp('Progress bar closed, exiting...');
    return
end