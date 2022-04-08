    function Gait_Events = Gait_Events_Stride_step(Heelstrike,i,Opposite_Heelstrike,Mid_Swing,Toe_off)
    Cycle_Start= Heelstrike(i+1)-Heelstrike(i);
    Cycle_End= Cycle_Start+ Heelstrike(i+2)-Heelstrike(i+1);
   
    [~, iend] = size(Opposite_Heelstrike);
    fs=100;
    
    i=i+1;
    if iend ==0
         Opposite_Heel=0;
        Step_Time=0;
    else
    if iend+1>i
        if Opposite_Heelstrike(i)>Heelstrike(i)
    Opposite_Heel = Cycle_Start+Opposite_Heelstrike(i)-Heelstrike(i);
    Step_Time = (Opposite_Heel-Cycle_Start)/fs;   
        end
    if Opposite_Heelstrike(i)< Heelstrike(i)
    Opposite_Heel = Cycle_Start+ Heelstrike(i)-Opposite_Heelstrike(i);
    Step_Time = (Opposite_Heel-Cycle_Start)/fs;   
        end
    else
        Opposite_Heel=0;
        Step_Time=0;
    end
    end
    
    [iend, ~] =size(Heelstrike);
    if iend==0
    Stride_Time=0;
    else
    Stride_Time = (Heelstrike(i+1)-Heelstrike(i))/fs;
    end
    
    
    [iend, ~] =size(Mid_Swing);
    if iend==0
    Mid_Swing=0;
    else
    Mid_Swing=Mid_Swing(2:end);
    Mid_Swing = Cycle_Start+(Mid_Swing(i)-Heelstrike(i));
    end
    
    
    [iend, ~] =size(Toe_off);
    if iend==0
    Toe_off=0;
    else
    Toe_off = Cycle_Start+(Toe_off(i)-Heelstrike(i));
    end
    
    Double_Support_time= ((Toe_off)-(Opposite_Heel))/fs;
    
    
    
   Gait_Events= struct('Cycle_Start',Cycle_Start,'Cycle_End',Cycle_End,'Opposite_Heelstrike',Opposite_Heel,'Mid_Swing',Mid_Swing,'Toe_off',Toe_off,'Double_Support_time',Double_Support_time,'Step_Time',Step_Time,'Stride_Time',Stride_Time);
    
%    Gait_Events_row1= ["Cycle_Start","Cycle_End","Opposite_Heelstrike","Mid_Swing","Toe_off","Double_Support_time","Step_Time","Stride_Time"];
%    Gait_Events_row2= [Cycle_Start,Cycle_End,Opposite_Heel,Mid_Swing,Toe_off,Double_Support_time,Step_Time,Stride_Time];
%    Gait_Events= [Gait_Events_row1;Gait_Events_row2];
    