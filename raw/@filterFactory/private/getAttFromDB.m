function att = getAttFromDB(x)

% Converts the attenuation x db to an amplitude value for firpm
att =  10^(-x / 20);