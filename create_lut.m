%==================================================
% part-of: Pitch dependent DOA estimation from 2-channel sources
% this  routine creates the lookup tables for the popi decomposition
%
%==================================================
fs =44100; 	 % sampling frequency in Herz
mic_dist = 0.35 % microphone distance in meters!
seglen = 2000   % lenght of the signal frame to be analyzed
		
minPit = 80;        % pitch is to be scanned from this value
maxPit = 120;      % pitch is to be scanned up to this value
lut_file_saved = 0 % shell we only read  the Phi and pit LUTsm or shell we reacreate all of them? 

filename = ['popiLUT_', num2str(mic_dist), 'm_', num2str(minPit), 'Hz_to_',num2str(maxPit), 'Hz']

if  lut_file_saved
	
	disp('------------- loading the popiLUT ------------')
	pitLUT = define_pitLUT(0,fs, minPit, maxPit);
	%disp('-')
	phiLUT = define_phiLUT(mic_dist, fs);
	%disp('-')
	load (filename,  "popiLUT_L", "popiLUT_0",  "popiLUT_R");
else
	disp('------------- creating the popiLUT ------------')
	pitLUT = define_pitLUT(0,fs, minPit, maxPit);
	disp('-')
	phiLUT = define_phiLUT(mic_dist, fs);
	disp('-')
	[popiLUT_L, popiLUT_0, popiLUT_R] = define_popiLUT(pitLUT, phiLUT, 80, seglen, 4001);
	disp('_popiLUT created_')
	
	disp('------------- saving the popiLUT ------------')
	save  (filename, "popiLUT_L", "popiLUT_0",  "popiLUT_R")
	
end;
