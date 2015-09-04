
classdef AodVolumeReader < HDF5Helper
    properties
        x = [];
        y = [];
        z = [];
        reps = [];
    end
    
    methods 
        function self = AodVolumeReader(filename)
            %self.restrict()
            self = self@HDF5Helper(filename, 'ImData');

             assert(H5Tools.existAttribute(self.fp,'ScanType') && ...
            	strncmp(H5Tools.readAttribute(self.fp, 'ScanType')', 'Volume', 6) == 1, ...
                'Not a volume scan file');
            
            settings = H5Tools.readAttribute(self.fp, 'Settings');
            dx = floor((settings(2) - settings(1)) / settings(3));
            dy = floor((settings(5) - settings(4)) / settings(6));
            dz = floor((settings(8) - settings(7)) / settings(9));
            
            self.x = (settings(1) + (0:settings(3)-1) * dx) * 1/1460000; %acq.AodScan.x_step;
            self.y = (settings(4) + (0:settings(6)-1) * dy) * 1/1460000; %acq.AodScan.y_step;
            self.z = (settings(7) + (0:settings(9)-1) * dz) * 1/700; %acq.AodScan.z_step;
            self.reps = settings(end);
            
            numPoints = prod([numel(self.x) numel(self.y) numel(self.z)]);
            self.reps = min(floor(self.sz(1) / numPoints), self.reps);
        end
        
        function dat = subsref(self, s)

            if(strcmp(s(1).type,'()') == 0) 
                if 0 && ismember(s.subs,properties(self))
                    dat = self.(s.subs);
                    return;
                end
                dat = subsref@HDF5Helper(self,s);
                return
            end
            
            % make sure subscripting has the right form
            assert(numel(s) == 1 && strcmp(s.type, '()') && numel(s.subs) == 5 || ...
                numel(s) == 1 && strcmp(s.type, '()') && numel(s.subs) == 4 || ...
                numel(s) == 1 && strcmp(s.type, '()') && numel(s.subs) == 3, ...
                'MATLAB:badsubscript', 'Only subscripting of the form (samples, channels) is allowed!')
            
            % samples and channels
            x = s(1).subs{1};
            y = s(1).subs{2};
            z = s(1).subs{3};
            
            if numel(s(1).subs) < 4
                reps = ':';
                avg = true;
            else
                reps = s(1).subs{4};
                avg = false;
            end

            % all samples requested?
            if HDF5Helper.iscolon(x)
                x = 1:numel(self.x);
            else
                % Check for valid range of samples
                assert(all(x <= numel(self.x) & x > 0), 'MATLAB:badsubscript', ...
                    'Sample index out of range [1 %d]', numel(self.x));
            end

            % all samples requested?
            if HDF5Helper.iscolon(y)
                y = 1:numel(self.y);
            else
                % Check for valid range of samples
                assert(all(y <= numel(self.y) & y > 0), 'MATLAB:badsubscript', ...
                    'Sample index out of range [1 %d]', numel(self.y));
            end

            % all samples requested?
            if HDF5Helper.iscolon(z)
                z = 1:numel(self.z);
            else
                % Check for valid range of samples
                assert(all(z <= numel(self.z) & z > 0), 'MATLAB:badsubscript', ...
                    'Sample index out of range [1 %d]', numel(self.z));
            end
            
            % all samples requested?
            if HDF5Helper.iscolon(reps)
                reps = 1:self.reps;
            else
                % Check for valid range of samples
                assert(all(reps <= numel(self.reps) & reps > 0), 'MATLAB:badsubscript', ...
                    'Sample index out of range [1 %d]', numel(self.reps));
            end

            i1 = repmat(reshape(x,[numel(x) 1 1 1]),[1 numel(y) numel(z) numel(reps)]);
            i2 = repmat(reshape(y,[1 numel(y) 1 1]),[numel(x) 1 numel(z) numel(reps)]);
            i3 = repmat(reshape(z,[1 1 numel(z) 1]),[numel(x) numel(y) 1 numel(reps)]);
            i4 = repmat(reshape(reps,[1 1 1 numel(reps)]), [numel(x) numel(y) numel(z) 1]);
            
            ind = sub2ind([numel(self.x) numel(self.y) numel(self.z) self.reps], ...
                i1(:), i2(:), i3(:), i4(:));
            
            if numel(s(1).subs) < 5
                s.subs = {ind, 1};
            else
                s.subs = {ind, s(1).subs{5}};
            end
            
            dat = subsref@HDF5Helper(self,s);
            dat = reshape(dat,[numel(x) numel(y) numel(z) numel(reps)]);
%            dat = permute(dat,[2 1 3]);
        end
    end
end