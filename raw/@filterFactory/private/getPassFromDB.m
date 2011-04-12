function pass = getPassFromDB(x)

% Converts the ripple of x dB to an amplitude value for firpm
pass = (10^(x/20)-1)/(10^(x/20)+1);