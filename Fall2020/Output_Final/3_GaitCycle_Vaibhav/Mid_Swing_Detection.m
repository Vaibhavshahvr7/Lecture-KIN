function Mid_Swing = Mid_Swing_Detection(G,PeakLim)

                
                [GRow, ~] = size(G); % Count Row and Columm of Gyro Shank
                limitPeakH = PeakLim * max(G,[],'all'); %Set limit peak (X to Max value of Gyro)
                limitPeakD = 50; %Min Distance between two peaks
                % Peak ditection Start
                [~,GyroPeaks,~,~] = findpeaks(G,[1:GRow],...
                    'MinPeakProminence',limitPeakH,...
                    'MinPeakDistance',limitPeakD);
                Mid_Swing= GyroPeaks.';
         