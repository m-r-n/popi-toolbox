
function phiLUT = define_phiLUT(mic_dist, fs)

% =======================================
% Lookup table to warp the Correlation lag to correspong 0-180
% 1st ver: 11.9.2006
%
% =======================================


% ------------- Angle range -------------
minPhi = 1;
maxPhi = 180;
phiStep = 2;

c = 341;        % speed of sound in air;

% creating the phi-LookupTable:
noPhi= round((maxPhi-minPhi)/phiStep );
phiLUT = zeros(noPhi,1);


% filling the pitch-LUT
i=1;
for phi= minPhi:phiStep:maxPhi
    % nos:
    phi_deg = phi*pi/180;
    phiLUT(i)=mic_dist * cos(phi_deg) * fs / c;
    i=i+1;
end;

% ------------- Plotting -----------------

if 1
figure(10)
subplot(211)
plot(phiLUT)
grid on
xlabel ('Phi/2 [deg]')
ylabel (['Corr. lag at Fs=', num2str(fs), 'Hz'])
title ('The Angle-of-Arrival LookUpTable (PhiLUT)')
end