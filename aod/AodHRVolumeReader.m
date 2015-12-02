
classdef AodHRVolumeReader < HDF5Helper
    properties
        x = [];
        y = [];
        z = [];
        reps = [];
        version = [];
        vfilename = [];
    end
    
    methods
        function self = AodHRVolumeReader(filename,vfilename)
            
            self = self@HDF5Helper(filename, 'ImData');
            
            isHRV = (H5Tools.existAttribute(self.fp,'CellFocussedVolume') && ...
                H5Tools.readAttribute(self.fp, 'CellFocussedVolume') == 1);
            self.version = H5Tools.readAttribute(self.fp, 'Version');
            assert((H5Tools.existAttribute(self.fp,'ScanType') && ...
                strncmp(H5Tools.readAttribute(self.fp, 'ScanType')', 'Volume', 6) == 1) ...
                || isHRV , ...
                'Not a volume scan file');
            
            
            coord = AodCoordinatesReader(self.filename,self.version);
            coords =  coord(:);
            numPoints = size(coords,1);
            self.reps = floor(self.sz(1) / numPoints);
            
            ar = aodReader(vfilename,'Volume');
            
            self.x = ar.x;
            self.y = ar.y;
            self.z = ar.z;
            self.vfilename = vfilename;
            
        end
        
        function volume = subsref(self, s)
            
            ar = aodReader(self.filename,'Functional');
            data = ar(:,:,:);
            coord = AodCoordinatesReader(self.filename,self.version);
            coords =  coord(:);
            volume = nan(length(self.x),length(self.y),length(self.z),size(data,3),size(data,1));
            
            for i = 1:size(coords,1)
                xind = find(single(coords(i,1))==single(self.x));
                yind = find(single(coords(i,2))==single(self.y));
                zind = find(single(coords(i,3))==single(self.z));
                volume(xind,yind,zind,:,:) = squeeze(data(:,i,:))';
            end
            
            if(strcmp(s(1).type,'()') == 0)
                if 0 && ismember(s.subs,properties(self))
                    volume = self.(s.subs);
                    return;
                end
                volume = subsref@HDF5Helper(self,s);
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
            
            if numel(s(1).subs)<4
                chan = ':';
            else
                chan = s(1).subs{4};
            end
            
            if numel(s(1).subs) < 5
                volume = mean(volume,5);
            else
                reps = s(1).subs{5};
            end
            
            % all samples requested?
            if ~HDF5Helper.iscolon(x)
                volume = volume(x,:,:,:,:);
            end
            
            % all samples requested?
            if ~HDF5Helper.iscolon(y)
                volume = volume(:,y,:,:,:);
            end
            
            % all samples requested?
            if ~HDF5Helper.iscolon(z)
                volume = volume(:,:,z,:,:);
            end
            
            % all samples requested?
            if ~HDF5Helper.iscolon(reps)
                volume = volume(:,:,:,:,reps);
            end
            
        end
    end
end