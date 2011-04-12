function fp = createFile(filename, varargin)

params.driver = [];
params.memberSize = 2147483647; % 2 GB files (minus one byte)

for i=1:2:length(varargin)
    params.(varargin{i}) = varargin{i+1};
end

fp = -1;
if isempty(params.driver)
  fp = H5F.create(filename, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
end

if double(fp) <= 0 && (strcmpi(params.driver, 'family') || isempty(params.driver))
  fapl = H5P.create( 'H5P_FILE_ACCESS' );
  H5P.set_fapl_family( fapl, params.memberSize, 'H5P_DEFAULT' );
  fp = H5F.create(filename, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', fapl);
  H5P.close(fapl);
end

if double(fp) <= 0 && (strcmpi(params.driver, 'sec2') || isempty(params.driver))
  fapl = H5P.create( 'H5P_FILE_ACCESS' );
  H5P.set_fapl_sec2( 'H5P_DEFAULT' );
  fp = H5F.create(filename, flags, 'H5P_DEFAULT', fapl);
  H5P.close(fapl);
end
