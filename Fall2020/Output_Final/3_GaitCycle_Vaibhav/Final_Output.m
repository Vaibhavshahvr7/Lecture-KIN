

function FinalOutput= Final_Output(data,select,FinalOutput)
s=1; %ID of the participant
e=30; %Number of Subject/run loops for x times; e=30 will run for all 30 participants 
Te = 6; % Number of trial loop you want to run--Shoul be set 6 as there are six numbers of trial on each surfaces
Sideselect= 2; % For both side=2

%% Counter for the output that comes under set condition  (error data removed)
Counthip =0;
Count = 0;
Total =0;
Totalhip =0;
% Total possible
outrow  = 1; % Row in the output Struct of each trial
irowhip = 1;% Row in the output Struct of each trial
STable= table(); % participant output table
SideTable= table();
    gait_cycle= table();
SurfaceSelect= ["FlatEven","CobbleStone","StairUp","StairDown","SlopeUp","SlopeDown","BnkL","BnkR","Grass"];
Tselect=[4,10,16,17,28,29,40,41,52];

%%
for s= 1:e  % Loop for the participants
    %% participant select
    Sensor = "ID" + s; %ID of dataset
      %% Trial Select
    T= Tselect(select); % Strat trial number according to surface
    TrialNumber=1;
    %set peak limit according to surface
    %--------------------------------------------------------------------------------------------------
    %Surface |FlatEven|ColbbeStone|StairUP          |     StairDown   |SlopeUp          |SlopeDown        |BnkL|BnkR|Grass|%%
    %PeakLim |0.7     |  0.7      |        0.52     |     0.6         |   0.67          |    0.6          | 0.7           |%%
    %  T     |4-9     |  10-15    |16-18-20-22-24-26|17-19-21-23-25-27|28-30-32-34-36-38|29-31-33-35-37-39|40-57          |%%
    %-------------------------------------------------------------------------------------------------
    %% peak detection limit select
     PeakLim = peak_detection_limit(T,s);
    %% Loop for trials
    for Trial= 1:Te %Trial loop (Trial can not be set as T because for some we need to take T+1 and for some we need T+2 trail number)
        
        
        Side = ["R";"L"]; %Side select
        plotColor = ['b';'r']; % Blue for Right; Red for Left
        %% Loop for side
        for SideSel = 1: Sideselect %Side select 1= Right and 2 =Left
            Heelstrike=[];         
            %% Data Selection
            shank = "shank"+ Side(SideSel,1);
            thigh = "thigh"+ Side(SideSel,1);
            trunk = "trunk";
            %% End number of Row selection
            Gmissing= [data.(Sensor).(shank).Gyr_X{T,1} data.(Sensor).(shank).Gyr_Y{T,1} data.(Sensor).(shank).Gyr_Z{T,1}]; % Shank Gyro data
            [Gmissingrow, ~] = size(Gmissing);
            Start = 1; %Start of Data row
            m1 = data.(Sensor).(shank).MissingCount{T,1};
            m2 = data.(Sensor).(thigh).MissingCount{T,1};
            m3 = data.(Sensor).(trunk).MissingCount{T,1};
            End=Missing_data(m1,m2,m3,Gmissingrow);
            
            if End >100 % Only if the total rows are higher than 100
                %% Start of Heel strike detection
                Gs= [data.(Sensor).(shank).Gyr_X{T,1}(Start:End) data.(Sensor).(shank).Gyr_Y{T,1}(Start:End) data.(Sensor).(shank).Gyr_Z{T,1}(Start:End)]; % Shank Gyro data
                Heelstrike = Heelstrike_Detection(Gs,PeakLim);
                [~, Heelstrikei] = size(Heelstrike); %Count number of Row and Column
                
                if SideSel==1
                    Gso=[data.(Sensor).shankL.Gyr_X{T,1}(Start:End) data.(Sensor).shankL.Gyr_Y{T,1}(Start:End) data.(Sensor).shankL.Gyr_Z{T,1}(Start:End)];
                    Opposite_Heelstrike = Opposite_Heelstrike_Detection(Gso,PeakLim);
                    
                end
                
                if SideSel==2
                    Gso=[data.(Sensor).shankR.Gyr_X{T,1}(Start:End) data.(Sensor).shankR.Gyr_Y{T,1}(Start:End) data.(Sensor).shankR.Gyr_Z{T,1}(Start:End)];
                    Opposite_Heelstrike = Opposite_Heelstrike_Detection(Gso,PeakLim);
                   
                end
                Mid_Swing = Mid_Swing_Detection(Gs,PeakLim);
                Toe_off = Toe_off_Detection(Mid_Swing,Heelstrike,Gs);
                
                %% Knee and Hip angle estimation
                
                %Loading data
                Ashank1= [data.(Sensor).(shank).Acc_X{T,1}(Start:End) data.(Sensor).(shank).Acc_Y{T,1}(Start:End) data.(Sensor).(shank).Acc_Z{T,1}(Start:End)];
                
                Athigh1= [data.(Sensor).(thigh).Acc_X{T,1}(Start:End) data.(Sensor).(thigh).Acc_Y{T,1}(Start:End) data.(Sensor).(thigh).Acc_Z{T,1}(Start:End)];
               
                Atrunk1= [data.(Sensor).(trunk).Acc_X{T,1}(Start:End) data.(Sensor).(trunk).Acc_Y{T,1}(Start:End) data.(Sensor).(trunk).Acc_Z{T,1}(Start:End)];
              
                %Data loaded
                
                outrow=1;
                
               if Heelstrikei-3 > 0
                for i= 1:Heelstrikei-3
                    OutputX= Heelstrike(i); %ouput Row Start
                    OutputY= Heelstrike(i+3); %output Row end
                    
                    
                    Ashank2 = Ashank1(OutputX:OutputY,1:3);
                    Athigh2  = Athigh1 (OutputX:OutputY,1:3);
                    Atrunk2 = Atrunk1(OutputX:OutputY,1:3);
                    color = plotColor(SideSel,1);
                
                    [KC, ~] = size(Atrunk2);
                    
                    if KC < 450
                     
                        Count= Count+1;
                            Shank = Output_Shank(Ashank2);
                            Thigh = Output_Thigh(Athigh2);
                            Trunk = Output_Trunk(Atrunk2);
                            Gait_Events = Gait_Events_Stride_step(Heelstrike,i,Opposite_Heelstrike,Mid_Swing,Toe_off);                            
                            
%                             gait_cycle(1,outrow) = table(struct('Trunk',Trunk,'Gait_Events',Gait_Events));
                                gait_cycle(1,outrow) = table(struct('Trunk',Trunk,'Thigh',Thigh,'Shank',Shank,'Gait_Events',Gait_Events));
%                                 gait_cycle(1,outrow) = table(struct('Trunk',Trunk,'Thigh',Thigh,'Shank',Shank));
                            cycle= "cycle_" + (outrow);
                            gait_cycle.Properties.VariableNames{outrow}= str2mat(cycle);
                            outrow= outrow+1;
                    else
                       
                    end
                    Total = Total+1;
                
                end
                else
                gait_cycle=table(0);
                gait_cycle.Properties.VariableNames{1}= 'nah';
            end

            end
                        [~,gi]=size(gait_cycle);
            if gi==0
                gait_cycle=table(0);
                gait_cycle.Properties.VariableNames{1}= 'nah';
            end
    SideTable(1,SideSel)= table(table2struct(gait_cycle));
    SideTable.Properties.VariableNames{SideSel}= str2mat(Side(SideSel,1));
    gait_cycle= table();
    outrow=1;
        end
      
       %% %Next trial selection
        
        if T < 16
            T= T+1;

        elseif T<52
                T= T+2;
            
        else
                T= T+1;
        end
    TrialTable(1,TrialNumber)= table(table2struct(SideTable));
    SideTable=table();
    Pro_trial= "trial" + (TrialNumber);
    TrialTable.Properties.VariableNames{TrialNumber}= str2mat(Pro_trial);
    TrialNumber=TrialNumber+1;
  
    end

   
       
    STable(1,s)= table(table2struct(TrialTable));
    STable.Properties.VariableNames{s} = str2mat(Sensor);
    TrialTable= table();
  

end

SucRate = 100*Count/Total;

% 
FinalOutput.(SurfaceSelect(select))=table2struct(STable);
FinalOutput=FinalOutput;
% save('FinalOutput.mat','FinalOutput')