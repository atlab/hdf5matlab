
classdef AodMotionCoordinatesReader < HDF5Helper    
    methods 
        function self = AodMotionCoordinatesReader(filename)
            %self.restrict()
            self = self@HDF5Helper(filename, 'MotionCoordinates');
        end

        function x = subsref(self, s)
                     
            s.type = '()';
            s.subs = {1:self.sz(1), 1};
            x = subsref@HDF5Helper(self,s);
            x = reshape(x,3,[])';
               x = bsxfun(@times, x, ...
              [1/1460000 1/1460000 1/700]); % [acq.AodScan.x_step acq.AodScan.y_step acq.AodScan.z_step]);

        end
    end
end