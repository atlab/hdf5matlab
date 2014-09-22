classdef baseReaderHammerEW
    % Base reader for Hammer system based recordings
    %   br = baseReaderHammerEW(fileName) opens a base reader for the
    %   file given in fileName.
    %
    %   br = baseReaderHammerEW(fileName, channels) opens a reader for
    %   only the given channels, where channels is either a numerical vector of
    %   channel indices, a string containing a channel name or a cell array of
    %   stings containig multiple channel names.
    %
    %   br = baseReaderHammerEW(fileName, pattern) opens a reader for
    %   a group of channels matching the given pattern. Channel groups can be
    %   for instance tetrodes. In this case the pattern would be 't10c*'.
    %
    % AE 2011-04-11
    % Modified into newer format of class by EYW 2014-09-17
    
    properties
        fileName; % loaded file
        fp; % file pointer to the opened HDF5 file
        nbChannels; % number of channels loaded
        nbSamples; % number of samples per channel
        Fs; % sampling frequency in 
        t0; % start time in 
        scale; % scale of the data (
        chIndices; % index array for channels
        chNames; % names of channels
        
        tetrode = 0; %??? perhaps the same thing as channel indices?
        channels = []; % ??? list of channels?
    end
    
    methods
        function br = baseReaderHammerEW(fileName, channels)
            br.fileName = fileName;
            br.fp = H5Tools.openFamily(fileName);
            
            
            dataDim = H5Tools.getDatasetDim(br.fp, 'data');
            nbChannels = dataDim(1); %#ok
            br.nbSamples = dataDim(2);
            if nargin < 2
                channels = 1:nbChannels; %#ok
            end
            
            if isnumeric(channels) 
                br.chIndices = channels;
                br.chNames = H5Tools.getChannelNames(br.fp, channels);
            else % if channels specified by their names
                [br.chIndices, br.chNames] = H5Tools.matchChannels(br.fp, channels);
            end
            
            br.nbChannels = length(br.chIndices);
            
            % read in sampling rate
            if H5Tools.existAttribute(br.fp, 'sample rate')
                br.Fs = H5Tools.readAttribute(br.fp, 'sample rate');
            elseif H5Tools.existAttribute(br.fp, 'Fs')
                br.Fs = H5Tools.readAttribute(br.fp, 'Fs');
            else
                br.Fs = -1;
                warning('Could not read ''sample rate'' attribute from recording file.');
            end
            
            
            if H5Tools.existAttribute(br.fp, 't0') % if t0 defined
                br.t0 = H5Tools.readAttribute(br.fp, 't0');
            else % if not defined, assume 0
                br.t0 = 0;
            end
            
        end
        
        function varargout = close(br)
            % closes the file pointer
            if ~isempty(br.fp)
                H5F.close(br.fp);
                br.fp = [];
            end
            if nargout % TODO: remove this argout reference
                varargout{1} = br;
            end
        end
        
        function display(br)
            fprintf('\n')
            fprintf('%s object\n', class(br))
            fprintf('\n')
            fprintf('                 File name: %s\n', br.fileName)
            fprintf('  Total number of channels: %d\n', numel(br.chIndices))
            fprintf('         Number of samples: %d\n', br.nbSamples)
            fprintf('             Sampling rate: %.0f Hz\n', br.Fs)
            fprintf('        Recording duration: %.1f seconds\n', br.nbSamples / br.Fs)
            fprintf('\n')
        end
        
        function i = end(br, k, n)
            % TODO: No idea what it does, will checkback
            i = size(br, k);
        end
        
        function br = getBaseReader(br)
            % end of recursion, returns itself
        end
        
        
        
        %%%% getters for attributes %%%%
        function channelNames = getChannelNames(br)
            channelNames = br.chNames;
        end
        
        function nbChannels = getNbChannels(br)
            nbChannels = br.nbChannels;
        end
        
        function nbSamples = getNbSamples(br)
            nbSamples = br.nbSamples;
        end
        
        function [refs, indices] = getRefs(br)
            res = regexp(getChannelNames(br), '^ref(\d+)$', 'once', 'tokens');
            indices = find(cellfun(@(x) ~isempty(x), res));
            [refs, order] = sort(cellfun(@(x) str2double(x{1}), res(indices)));
            indices = indices(order);
        end
        
        function idx = getSampleIndex(br, t)
            % Return sample index that corresponds to specified timestamp
            % t in millli seconds
            % NaN is returned if timestamp out of range
            idx = round(1e-3 * (t - br.t0) * br.Fs) + 1;
            idx(idx < 1) = nan;
            idx(idx > br.nbSamples) = nan;
        end
        
        function t = getTimestamps(br, samples)
            % Return timestamps corresponding to specified sample indicies
            % If ':' is passed, timestamps for all samples are returned, as
            % would be expected.
            if iscolon(samples)
                t = br.t0 + 1000 * (0:br.nbSamples-1)' / br.Fs;
            else
                t = br.t0 + 1000 * (samples(:)-1)' / br.Fs;
            end
        end
        
        function r = getSamplingRate(br)
            r = br.Fs;
        end
        
        function scale = getScale(br)
            scale = br.scale;
        end
        
        function len = length(br)
            % length of br is defined as number of samples
            len = br.nbSamples;
        end
        
        function [tetrodes, channels, indices] = getTetrodes(br)
            % Get recorded tetrodes (and their channels).
            %   [tetrodes, channels, indices] = getTetrodes(br) returns the tetrodes
            %   and their channels that were recorded. The third output indices
            %   contains the physical channel indices in the recording file.
            %
            % AE 2011-10-15
            
            % match all channels with name of form like t15c1, t8c3...
            res = regexp(br.chNames, '^t(\d+)c([1-4]{1})$', 'tokens', 'once');
            matches = find(cellfun(@(x) ~isempty(x), res));
            tetNos = cellfun(@(x) str2double(x{1}), res(matches));
            channelNos = cellfun(@(x) str2double(x{2}), res(matches));
            
            % group channels by tetrodes
            tetrodes = unique(tetNos);
            channels = cell(size(tetrodes));
            indices = cell(size(tetrodes));
            for i = 1:numel(tetrodes)
                channelIdx = find(tetNos == tetrodes(i));
                [channels{i}, sortIdx] = sort(channelNos(channelIdx));
                indices{i} = matches(channelIdx(sortIdx));
            end
        end
        
        function varargout = size(br, dim)
            % Returns the size of br data in the specified dimension
            % Dim 1 => number of samples
            % Dim 2 => number of channels
            
            sz = [br.nbSamples, br.nbChannels];
            if nargout == 1 && nargin > 1
                varargout{1} = sz(dim);
            elseif nargout > 1
                varargout = num2cell(sz(1:nargout));
            else
                varargout{1} = sz;
            end
        end
        
        function muv = toMuV(br, x)
            % Converts values to microvolts assuming input is in volts.
            %   muv = toMuV(br, x)
            %    
            muv = x * 1e6;
        end
        
        function x = subsref(br, s)
            % Subscripting.
            %   x = br(samples, channels). channels can be either channel indices or
            %   't' for the timestamps in milliseconds.
            %
            % AE 2011-04-11
            %
            % If using dot notation, use builtin subsref to handle that
            % EYW 2014-09-19
            
            if strcmp(s.type, '.')
                x = br.(s.subs);
                return;
            end
            
            assert(numel(s) == 1 && strcmp(s.type, '()') && numel(s.subs) == 2, ...
                'MATLAB:badsubscript', 'Only subscripting of the form (samples, channels) is allowed!');
            
            % samples and channels
            samples = s(1).subs{1};
            channels = s(1).subs{2};
            
            % all samples requested?
            if iscolon(samples)
                nSamples = br.nbSamples;
            else
                % Check for valid range of samples
                assert(all(samples <= br.nbSamples & samples > 0), 'MATLAB:badsubscript', ...
                    'Sample index out of range [1 %d]', br.nbSamples);
                nSamples = numel(samples);
            end
            
            % time channel requested?
            if ischar(channels) && channels == 't'
                assert(br.t0 > 0, 't0 has not been updated in this file!')
                x = br.getTimestamps(samples);
            else
                
                % all channels requested?
                if iscolon(channels)
                    channels = 1:(br.nbChannels);
                else
                    % Check for valid range of channels
                    assert(all(channels <= br.nbChannels & channels > 0), ...
                        'MATLAB:badsubscript', 'Channel index out of range [1 %d]', br.nbChannels);
                end
                nChannels = numel(channels);
                
                % Convert to actual channel numbers in the recording file
                channels = br.chIndices(channels);
                
                x = zeros(nSamples, nChannels);
                
                if iscolon(samples)
                    % reading all samples
                    for i = 1:nChannels
                        x(:,i) = H5Tools.readDataset(br.fp, 'data', 'range', [channels(i), 1], [channels(i), br.nbSamples]);
                    end
                elseif length(samples) > 2 && samples(end) - samples(1) == length(samples) - 1 && all(diff(samples) == 1)
                    % reading continuous block of samples
                    for i = 1:nChannels
                        x(:,i) = H5Tools.readDataset(br.fp, 'data', 'range', [channels(i), samples(1)], [channels(i), samples(end)]);
                    end
                else
                    % reading arbitrary set of samples
                    for i = 1:nChannels
                        x(:,i) = H5Tools.readDataset(br.fp, 'data', 'index', [repmat(channels(i), nSamples, 1) , samples(:)]);
                    end
                end
                
                % scale to (micro/milli?)volts
                order = numel(br.scale);
                if order == 1
                    x = x * br.scale;
                else
                    y = 0;
                    for i = 1:order
                        y = y + x.^(i - 1) * br.scale(i);
                    end
                    x = y;
                end
            end
        end
            
    end
    
end


function b = iscolon(x)
    % checks if x is colon character ':'
    b = ischar(x) && isscalar(x) && x == ':';
end
