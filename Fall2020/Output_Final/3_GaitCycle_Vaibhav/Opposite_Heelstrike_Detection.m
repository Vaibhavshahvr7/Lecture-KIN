function Opposite_Heelstrike = Opposite_Heelstrike_Detection(Gso,PeakLim)

   G=sqrt(Gso(:,1).^2+Gso(:,2).^2+Gso(:,3).^2); %Normalized Gyro Data
                
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
                Opposite_Heelstrike=Heel;