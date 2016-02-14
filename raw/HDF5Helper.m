classdef HDF5Helper
    properties
        filename = '';
        fp = 0;
        sz = [];
        dataset = '';
        t0 = 0;
        Fs = 0;
    end
    
    methods
        function self = HDF5Helper(filename, dataset)
            self.filename = filename;
            self.fp = H5Tools.openFamily(self.filename);
            self.dataset = dataset;
            self.sz = fliplr(H5Tools.getDatasetDim(self.fp, self.dataset));

            if(H5Tools.existAttribute(self.fp, 't0'))
                self.t0 = H5Tools.readAttribute(self.fp, 't0');
            else
                self.t0 = 0;
            end

             if(H5Tools.existAttribute(self.fp, 'Fs'))
                self.Fs = H5Tools.readAttribute(self.fp, 'Fs');
             else
                self.Fs = 50000;
             end
        end
        
        function self = close(self)
            if ~isempty(self.fp)
                H5F.close(self.fp);
                self.fp = [];
            end
        end

        function Fs = getSamplingRate(self)
            % Return the sampling rate
            Fs = self.Fs;
        end
        
        function l = length(self)
            l = self.sz(1);
        end

        function x = end(self,dim,varargin)
            x = size(self,dim);
        end

        function varargout = size(self, dim)    
            if (nargout == 1) && (nargin > 1)
                varargout{1} = self.sz(dim);
            elseif (nargout > 1)
                varargout = num2cell( self.sz(1:nargout) );
            else
                varargout{1} = self.sz;
            end
        end
        
        function x = subsref(self, s)
            % Subscripting.
            %   x = br(samples, channels). channels can be either channel indices or
            %   't' for the timestamps in milliseconds.
            %
            % AE 2011-04-11
            
            if (strcmp(s(1).type, '.') == 1)
                assert(ismember(s(1).subs,properties(self)), 'MATLAB:badsubscript', 'Field not found');
                x = self.(s(1).subs);
                
                if length(s) > 1
                    x = subsref(x,s(2:end));
                end
                
            	return;
            end
            
            % make sure subscripting has the right form
            assert(numel(s) == 1 && strcmp(s.type, '()') && numel(s.subs) == 2, ...
                'MATLAB:badsubscript', 'Only subscripting of the form (samples, channels) is allowed!')
            
            % samples and channels
            samples = s(1).subs{1};
            channels = s(1).subs{2};
            
            % all samples requested?
            if HDF5Helper.iscolon(samples)
                nSamples = self.sz(1);
            else
                % Check for valid range of samples
                assert(all(samples <= self.sz(1) & samples > 0), 'MATLAB:badsubscript', ...
                    'Sample index out of range [1 %d]', self.sz(1));
                nSamples = numel(samples);
            end
            
            % time channel requested?
            if ischar(channels) && channels == 't'
                assert(self.t0 > 0, 't0 has not been updated in this file!')
                if iscolon(samples)
                    x = self.t0 + 1000 * (0:self.sz(1)-1)' / self.Fs;
                else
                    x = self.t0 + 1000 * (samples(:)-1)' / self.Fs;
                end
            else
                
                % all channels requested?
                if HDF5Helper.iscolon(channels)
                    channels = 1:(self.nbImChannels);
                else
                    % Check for valid range of channels
                    assert(all(channels <= self.sz(2) & channels > 0), ...
                        'MATLAB:badsubscript', 'Channel index out of range [1 %d]', self.sz(2));
                end
                nChannels = numel(channels);
                
                % Convert to actual channel numbers in the recording file
                %channels = self.imChIndices(channels);
                
                x = zeros(nSamples, nChannels);
                
                if HDF5Helper.iscolon(samples)
                    % reading all samples
                    for i = 1:nChannels
                        x(:,i) = H5Tools.readDataset(self.fp, self.dataset, 'range', [channels(i), 1], [channels(i), self.sz(1)]);
                    end
                elseif length(samples) > 2 && samples(end) - samples(1) == length(samples) - 1 && all(diff(samples) == 1)
                    % reading continuous block of samples
                    for i = 1:nChannels
                        x(:,i) = H5Tools.readDataset(self.fp, self.dataset, 'range', [channels(i), samples(1)], [channels(i), samples(end)]);
                    end
                else
                    % reading arbitrary set of samples
                    for i = 1:nChannels
                        x(:,i) = H5Tools.readDataset(self.fp, self.dataset, 'index', [repmat(channels(i), nSamples, 1) , samples(:)]);
                    end
                end
                
                % scale to (micro/milli?)volts
            end
        end
    end
    
    methods(Static)
        function b = iscolon(x)
            b = ischar(x) && isscalar(x) && x == ':';
        end
    end

end