
classdef AodMotionCorrectionReader < HDF5Helper    
    methods 
        function self = AodMotionCorrectionReader(filename)
            %self.restrict()
            self = self@HDF5Helper(filename, 'AODMotionCorrectionData');
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

            assert(numel(s.subs) == 2,'MATLAB:badsubscript', 'Only subscripting of the form (samples, coordinates (max 3)) is allowed!')
            assert(prod(self.sz) ~= 0,'MATLAB:nodata', 'No data available!') ;
                
            s.type = '()';
            if (strcmp(s.subs{1}, ':') == 1)
                s.subs{1} = [1:1:self.sz(1)] ;
            end ;
            if (strcmp(s.subs{2}, ':') == 1)
                s.subs{2} = [1:1:self.sz(2)] ;
            end ;
            x = subsref@HDF5Helper(self,s);
        end
    end
end
