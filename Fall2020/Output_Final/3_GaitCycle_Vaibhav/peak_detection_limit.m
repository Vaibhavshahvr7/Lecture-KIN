    %set peak limit according to surface
    %--------------------------------------------------------------------------------------------------
    %Surface |FlatEven|ColbbeStone|StairUP          |     StairDown   |SlopeUp          |SlopeDown        |bnkL| bnkR |Grass|%%
    %PeakLim |0.7     |  0.7      |        0.52     |     0.6         |   0.67          |    0.6          |        0.7      |%%
    %  T     |4-9     |  10-15    |16-18-20-22-24-26|17-19-21-23-25-27|28-30-32-34-36-38|29-31-33-35-37-39|40   |41   |52-57|%%
    %-------------------------------------------------------------------------------------------------
    %% peak detection limit select
    function PeakLim = peak_detection_limit(T,s)
    if T <16
        peaklim=0.7;
    end%% FlatEven and ColbbeStone
    
    if T<28
        if T>15
            even = rem(T,2);
            if even ==0
                if s==29
                    peaklim=0.4; %StairUP(only for participant 29)
                else
                    peaklim=0.52;%StairUP
                end
            else
                peaklim=0.6; %StairDown
            end
        end
    end
   if T <40
       if T > 27
            even = rem(T,2);
            if even ==0
                peaklim=0.67; % %SlopeUp
            else
                peaklim=0.6; %SlopeDown
            end
       end
   end
        
    if T>39
        peaklim=0.7; %Grass
    end
    
    PeakLim=peaklim;