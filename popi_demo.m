% -------------------------------------------------------------
%                             popi_demo
%
% this code is based on the following conference paper:
% M. Képesi, F. Pernkopf, M. Wohmayr, “Joint Position-Pitch Tracking for 2-Channel Audio,” 
% CBMI 2007, Jun 25-27, Bordeaux, France
%
%         contact: mrn-at-post in cz
% -------------------------------------------------------------


% -------------------------------------------------------------
% 	Load Data
% -------------------------------------------------------------
% load 2 audio frames, 2001 samples per frame. 
% samples were recorded by 2 mics spaced at 60cm, at Fs=44100Hz.
% for a different set-up you will create different LUTs

load ('audio_frames')

% load the PoPi decomp matrices, precalculated for 60cm mic_dist 
% and scanning: Fo  [80Hz .... 300Hz],  and DoA [-90deg .....  90deg]

minPit = 80;	% in Hz
maxPit = 300;	% in Hz
mic_dist=0.60;	% in m
filename = ['popiLUT_', num2str(mic_dist), 'm_', num2str(minPit), 'Hz_to_',num2str(maxPit), 'Hz'];
load (filename,  "popiLUT_L", "popiLUT_0",  "popiLUT_R");

% -------------------------------------------------------------
%	Cross correlation or AMDF!
% -------------------------------------------------------------

%sc1 =xcorr(seg1,seg2, 2000, 'biased');
max_amdf_lag = 633; %derived from.. max(max(popiLUT_R))
%sc1 =cross_amdf(seg1,seg2, max_amdf_lag);
sl=sc1/max(abs(sc1));
sl=-sl;				%trick nr2
% -------------------------------------------------------------
% 	PoPi Decomposition
% -------------------------------------------------------------
tic
cut1=sl(popiLUT_L) +  sl(popiLUT_0) + sl(popiLUT_R) ;
cut1(cut1<0)=0;
ido1= toc;

tic
cut2=sl(popiLUT_L) .*  sl(popiLUT_0) .* sl(popiLUT_R) ;
cut2(cut2<0)=0;
ido2= toc;

cut3=cut1.*cut2;

disp('---')
disp (['1st decomposition: ', num2str(round(1000000*ido1)), ' micro-sec.']);
disp (['2nd decomposition: ', num2str(round(1000000*ido2)), ' micro-sec.']);
disp('Freq. resolution of Pitch axis: 2Hz, pitch starts at 80Hz!')
disp('Angular resolution of DoA axis: 2degs')

%seg10=[seg1, seg1];
%cut1=seg10(popiLUT_L) +  seg10(popiLUT_0) + seg10(popiLUT_R) ;

% -------------------------------------------------------------
%	Plotting
% -------------------------------------------------------------
    figure(1)
    
    subplot(311)
    plot(seg1)
    title ([' channel nr. 1'])

    subplot(312)
    plot(seg2)
    title ([' channel nr. 2'])

    subplot(313)
    plot(sl);
    title('Cross-Correlation')
    
    figure(2)
   imagesc(cut1);
   colorbar
   title (' decomp: (L + O + R)')
   ylabel (['(Pitch - ',num2str(minPit), ')/2 [Hz] '])
   xlabel (['DoA /2 [deg]'])
   
   figure(3)
   imagesc(cut2);
   colorbar
   title ('  decomp: (L * O * R)')
   ylabel (['(Pitch - ',num2str(minPit), ')/2 [Hz] '])
   xlabel (['DoA /2 [deg]'])
   
   figure(4)
   imagesc(cut3);
   colorbar
   title (' decomp: (L + O + R) .* ( L .* O .* R)')
   ylabel (['(Pitch - ',num2str(minPit), ')/2 [Hz] '])
   xlabel (['DoA /2 [deg]'])
    
    % -------------------------------------------------------------
    
