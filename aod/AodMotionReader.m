
classdef AodMotionReader < HDF5Helper
    properties
        planes = [];
        gridSize = 10; % need to store in file!
        motionIncrement = 0;
        motionCoordinates = 0;
        numPoints = 0;
        reshapedSize = [];
    end
    
    methods
        function self = AodMotionReader(filename)
            %self.restrict()
            self = self@HDF5Helper(filename, 'MotionData');
            
            %%%% Coordinates are now stored as data 2014-12-10 %%%%%%%%%%%%
            try
                coord = AodMotionCoordinatesReader(filename);
                self.motionCoordinates = coord(:);
            catch
                self.motionCoordinates = reshape(H5Tools.readAttribute(self.fp, ...
                    'MotionCoordinates'),3,[])';
                self.motionCoordinates = bsxfun(@times, self.motionCoordinates, ...
                    [1/1460000 1/1460000 1/700]); % [acq.AodScan.x_step acq.AodScan.y_step acq.AodScan.z_step]);
            end
            if H5Tools.existAttribute(self.fp, 'MotionIncrement')
                self.motionIncrement = H5Tools.readAttribute(self.fp ,'MotionIncrement');
                self.Fs = self.Fs / size(self.motionCoordinates,1) / self.motionIncrement;
            else
                error('No motion planes');
            end
            
            self.numPoints = size(self.motionCoordinates,1);
            self.planes = self.numPoints / self.gridSize / self.gridSize;
            timepoints = floor(self.sz(1) / self.numPoints);
            
            self.reshapedSize = [timepoints self.numPoints self.sz(2)];
        end
        
        function x = subsref(self, s)
            if(strcmp(s.type,'()') == 0)
                if 0 && ismember(s.subs,properties(self))
                    x = self.(s.subs);
                    return;
                end
                x = subsref@HDF5Helper(self,s);
                return
            end
            
            % make sure subscripting has the right form
            assert(numel(s) == 1 && strcmp(s.type, '()') && numel(s.subs) == 3 || ...
                numel(s) == 1 && strcmp(s.type, '()') && numel(s.subs) == 2, ...
                'MATLAB:badsubscript', 'Only subscripting of the form (samples, channels) is allowed!')
            
            % samples and channels
            samples = s(1).subs{1};
            points = s(1).subs{2};
            
            % all samples requested?
            if HDF5Helper.iscolon(samples)
                samples = 1:self.reshapedSize(1);
            else
                % Check for valid range of samples
                assert(all(samples <= self.reshapedSize(1) & samples > 0), 'MATLAB:badsubscript', ...
                    'Sample index out of range [1 %d]', self.reshapedSize(1));
            end
            
            % time channel requested?  Shortcut out
            if ischar(points) && points == 't'
                assert(self.t0 > 0, 't0 has not been updated in this file!')
                if HDF5Helper.iscolon(samples)
                    x = self.t0 + 1000 * (0:self.reshapedSize(2)-1)' / self.Fs;
                else
                    x = self.t0 + 1000 * (samples(:)-1)' / self.Fs;
                end
                return;
            end
            
            if numel(s(1).subs) >= 3
                channels = s(1).subs{3};
            else
                channels = 1;
            end
            
            % all points requested?
            if HDF5Helper.iscolon(points)
                points = 1:self.reshapedSize(2);
            else
                % Check for valid range of channels
                assert(all(points <= self.reshapedSize(2) & points > 0), ...
                    'MATLAB:badsubscript', 'Point index out of range [1 %d]', self.reshapedSize(2));
            end
            
            % all channels requested?
            if HDF5Helper.iscolon(channels)
                channels = 1:self.reshapedSize(3);
            else
                % Check for valid range of channels
                assert(all(channels <= self.reshapedSize(3) & channels > 0), ...
                    'MATLAB:badsubscript', 'Channel index out of range [1 %d]', self.reshapedSize(3));
            end
            
            i1 = repmat(samples,numel(points),1);
            i2 = repmat(points,1,numel(samples));
            
            ind = sub2ind(self.reshapedSize([2 1]), i2(:), i1(:));
            
            s.subs = {ind, channels};
            x = subsref@HDF5Helper(self,s);
            x = reshape(x,[numel(points) numel(samples) numel(channels)]);
            x = permute(x,[2 1 3]);
        end
    end
end