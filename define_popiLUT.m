function [popiLUT_L, popiLUT_0, popiLUT_R] = define_popiLUT(pitLUT, phiLUT, figind, seglen, length_cor_segm)

%===================================================
% LUT for correlation to space-frequency decomposition
%===================================================
% 1st ver:  9.may
% 2nd ver:        
%===================================================
% cor_segm  .. a correlation of one segment
% cut       .. represntation in doa-pitch plane

% --------- to fix: --------
% - DeWindowing of the correlation vector
%        (tried in: not a big effect)
% - Triangularisation instead of Round ()
%===================================================

noDelay = length(phiLUT)
noPit   = length(pitLUT)

ll=length_cor_segm;
% ------------ Removing negative values ---------
% when removing the negative values further anomalies appear in the Po-Pi
% plane
%cor_segm = max(0.0000000001, cor_segm); % 
%cor_segm = log10(cor_segm);

%plot(cor_segm((seglen-500):(seglen+500)),'r')

%===================================================
popiLUT_R = zeros (noPit,noDelay);
popiLUT_0 = zeros (noPit,noDelay);
popiLUT_L = zeros (noPit,noDelay);


for angle_ind = 1:noDelay;
    %angle_ind
    delay = seglen + phiLUT(angle_ind);
    
    for pitInd = 1:noPit
       %pitInd

      
            
           % Right side contributor
               iind = round(pitLUT(pitInd)+delay);
              
              if (iind <= ll) && (iind >= 1)
                popiLUT_R(pitInd, angle_ind)=iind;
              end
            
               % Center, ie. ure DoA  contributor
              iind = round(delay);
              if (iind <= ll) && (iind >= 1)
                popiLUT_0(pitInd, angle_ind)=iind;
              end
            
            % Left side contributor
             iind = round(-1*pitLUT(pitInd)+delay);
             if (iind <= ll) && (iind >= 1)
               popiLUT_L(pitInd, angle_ind)=iind;
             end

    end
end

%===================================================
if figind

figure(figind)
imagesc(popiLUT_L)
ylabel (['f_0 - ',num2str(round(44100/pitLUT(1))), '[Hz] '])
xlabel (['Phi/2 [deg]'])
colorbar

if 1
figure(figind+1)
imagesc(popiLUT_0)
ylabel (['f_0 - ',num2str(round(44100/pitLUT(1))), '[Hz] '])
xlabel (['Phi/2 [deg]'])
colorbar
end

figure(figind+2)
imagesc(popiLUT_R)
ylabel (['f_0 - ',num2str(round(44100/pitLUT(1))), '[Hz] '])
xlabel (['Phi/2 [deg]'])
colorbar

end %if figind
%===================================================
%===================================================


