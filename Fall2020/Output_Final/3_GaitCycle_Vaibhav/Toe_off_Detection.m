function Toe_off = Toe_off_Detection(Mid_Swing,Heelstrike,G)

                Heelstrike=Heelstrike.';
                [iend,~] = size(Heelstrike);
                if iend >1
                for i= 1:iend-1
                    [TF,~]=islocalmin(G(Heelstrike(i):Mid_Swing(i+1)));
                    TFmin=find(TF==1);
                    Toe(i)= Heelstrike(i)+TFmin(end)-1;
                end
                else
                    Toe=[];
                end
                Toe_off=Toe;