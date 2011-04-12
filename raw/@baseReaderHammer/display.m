function display(br)

% Display output for baseReader

disp('baseReader object'), disp(' ')
disp('Filename:'), disp(' ')
disp(br.fileName), disp(' ')
if isnumeric(br.tetrode)
    disp('Tetrode(s):'), disp(' ')
else
    disp('Channel(s):'), disp(' ')
end
disp(br.tetrode), disp(' ')
disp('Sampling rate:'), disp(' ')
disp(br.samplingRate), disp(' ')
disp('nbChannels ='), disp(' ')
disp(br.nbChannels)
disp('nbSamples ='), disp(' ')
disp(br.nbSamples)
disp('Recording duration:'), disp(' ')
fprintf('    %g%s\n\n', br.nbSamples / br.samplingRate, ' seconds');
