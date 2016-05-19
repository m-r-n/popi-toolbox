
function pitLUT = define_pitLUT(ll,fs, minPit, maxPit)

% =======================================
% the same version is used in "cor2spacefreq2" in popi
% 1st ver: 18.8.2006
%
% =======================================
% ll = length(cor_segm); % length of the correlation slice

% --------------------Pitch range -------------
%minPit = 450;
%maxPit = 550;
pitStep = 0.5;

% creating the pitch-LookupTable:
noPit= round((maxPit-minPit)/pitStep +1);
pitLUT = zeros(noPit,1);


% filling the pitch-LUT
i=1;
for pit= minPit:pitStep:maxPit
    pitLUT(i)=(fs/pit);
    i=i+1;
end;

if 1
figure(10)
subplot(212)
plot(pitLUT)
grid
title ('The Pitch LookUpTable (PitLUT)')
xlabel (['Pitch - ', num2str(minPit), ' [Hz]', ' with a step of ', num2str(pitStep)])
ylabel (['Lag- [ sample]'])
end