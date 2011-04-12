filt = filterFactory.createLowPass(100,500,1000);
n = getFilterLength(filt)
d = getAverageDelay(filt)
x = sin(linspace(0,4*pi,40));
y = apply(filt,x);
figure
plot(1:40,x)
hold on
% indexing wie in filteredReader/subsref
%   zeiten: zeile 57
%   samples: zeile 38
plot((1:40-n)+d,y(n+1:end),'k')
