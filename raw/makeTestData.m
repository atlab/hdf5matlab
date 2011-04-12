function makeTestData(fileName)
% THIS IS ONLY TEMPORARY. SHOULD BE REMOVED WHEN DONE
% AE 2011-04-11

m = 0.1 * 32000;
tt = 2;
n = 4 * tt + 1;
fp = H5Tools.createFile(fileName);

% put same fake data
H5Tools.writeDataset(fp, 'data', reshape(1:m*n, [], n), [m n], {'H5S_UNLIMITED', n})

% put channel names in random order
channelNames{n} = 'photodiode,';
for i = 1:tt
    for j = 1:4
        channelNames{(i-1)*4+j} = sprintf('t%dc%d,', i, j);
    end
end
channelNames = [channelNames{randperm(n)}];
H5Tools.writeAttribute(fp, 'channelNames', channelNames(1:end-1))

% metadata
H5Tools.writeAttribute(fp, 'class', 'Electrophysiology')
H5Tools.writeAttribute(fp, 'tstart', 4711)
H5Tools.writeAttribute(fp, 'Fs', 32000)

H5F.close(fp)
