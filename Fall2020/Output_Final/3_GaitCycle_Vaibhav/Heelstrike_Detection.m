function Heelstrike = Heelstrike_Detection(G,PeakLim)

% Heelstrike_Detection(Gs,PeakLim) finds frames for heel strike based on
% magnitude of gyroscope data (G). 

[GRow, ~] = size(G); % Count Row and Columm of Gyro Shank
limitPeakH = PeakLim * max(G,[],'all'); %Set limit peak (X to Max value of Gyro)
limitPeakD = 50; %Min Distance between two peaks
% Peak ditection Start
[~,GyroPeaks,~,~] = findpeaks(G,[1:GRow],...
    'MinPeakProminence',limitPeakH,...
    'MinPeakDistance',limitPeakD);

GyroPeaks= GyroPeaks.';
[iend, ~] = size(GyroPeaks);
if iend >1
    for i= 1:iend-1
        [TF,~]=islocalmin(G(GyroPeaks(i):GyroPeaks(i+1)));
        TFmin=find(TF==1);
        Heel(i)= GyroPeaks(i)+TFmin(1)-1;
    end
else
    Heel=[];
end
Heelstrike=Heel;