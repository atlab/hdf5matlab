classdef AodCoordinatesReader < HDF5Helper
    properties
        version = 1;
    end
    methods
        function self = AodCoordinatesReader(filename,input_version)
            %self.restrict()
            self = self@HDF5Helper(filename, 'PointCoordinates');
            self.version = input_version;
        end
        
        function x = subsref(self, s)
            
            if self.version==1
                s.type = '()';
                s.subs = {1:self.sz(1), 1};
                x = subsref@HDF5Helper(self,s);
                x = reshape(x,3,[])';
                x = bsxfun(@times, x, ...
                    [1/1460000 1/1460000 1/700]); % [acq.AodScan.x_step acq.AodScan.y_step acq.AodScan.z_step]);
            elseif self.version==2
                s.type = '()';
                s.subs = {1:self.sz(1), 1};
                x = subsref@HDF5Helper(self,s);
                x = reshape(x,6,[])';
                x = bsxfun(@times, x, ...
                    [1/1460000 1/1460000 1/700 1/1460000 1/1460000 1/700]); % [acq.AodScan.x_step acq.AodScan.y_step acq.AodScan.z_step]);
            end
            
            
        end
    end
    
end