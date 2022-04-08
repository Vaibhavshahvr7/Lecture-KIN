function gait_event_detect(fld, PeakLim)

% fld is path to data folder
% add new ch for heel strike(HS), mid swing(MS), toe_off(TO) both right(R) and left(L) side

if nargin ==0
    fld = uigetfolder;
    PeakLim = 0.7;
end

fl = engine('fld', fld, 'extension', 'zoo');
for i = 1:length(fl)
    if strfind(fl{i}, 'CALIB')
        batchdisp(fl{i}, 'no gait events for CALIB, skipping...')
    else
        batchdisp(fl{i}, 'extracting gait events')
        data = load(fl{i},'-mat');
        data = data.data;
        PeakLim=Select_PeakLim(data,PeakLim);
        data = event_detect_data(data, PeakLim);
        zsave(fl{i},data)
    end
end


function data = event_detect_data(data, PeakLim)


ch = fieldnames(data);

if ismember('shankR_Gyr_X', ch)
    
    g_x = data.shankR_Gyr_X.line;
    g_y = data.shankR_Gyr_Y.line;
    g_z = data.shankR_Gyr_Z.line;
    Gmag=sqrt(g_x.^2 + g_y.^2 + g_z.^2); %Normalized Gyro Data
    % detect heel strike, mid swing, toe_off for Right side
    RHS = Heelstrike_Detection(Gmag,PeakLim); % min value between two peaks
    RMS=  Mid_Swing_Detection(Gmag,PeakLim); % mid-swing are peaks
    RTO=  Toe_off_Detection(RMS,RHS,Gmag); % min between RHS location + 10 and mind-swing
    RMS= RMS(2:end); % mid-swing are peaks
    
    %adding as events to zoo
    for i = 1:length(RHS)
        data.shankR_Gyr_X.event.(['RHS',num2str(i)]) = [RHS(i) 0 0];
    end
    
    for i = 1:length(RMS)
        data.shankR_Gyr_X.event.(['RMS',num2str(i)]) = [RMS(i) 0 0];
    end
    
    for i = 1:length(RTO)
        data.shankR_Gyr_X.event.(['RTO',num2str(i)]) = [RTO(i) 0 0];
    end
    
end

if ismember('shankL_Gyr_X', ch)
    
    g_x = data.shankL_Gyr_X.line;
    g_y = data.shankL_Gyr_Y.line;
    g_z = data.shankL_Gyr_Z.line;
    Gmag=sqrt(g_x.^2 + g_y.^2 + g_z.^2); %Normalized Gyro Data
    % detect heel strike, mid swing, toe_off for Left side
    LHS = Heelstrike_Detection(Gmag,PeakLim); % min value between two peaks
    LMS=  Mid_Swing_Detection(Gmag,PeakLim); % mid-swing are peaks
    LTO=  Toe_off_Detection(LMS,LHS,Gmag); % min between LHS location + 10 and mind-swing
    LMS= LMS(2:end); % mid-swing are peaks
    
    %adding as events to zoo
    for i = 1:length(LHS)
        data.shankL_Gyr_X.event.(['LHS',num2str(i)]) = [LHS(i) 0 0];
    end
    
    for i = 1:length(LMS)
        data.shankL_Gyr_X.event.(['LMS',num2str(i)]) = [LMS(i) 0 0];
    end
    
    for i = 1:length(LTO)
        data.shankL_Gyr_X.event.(['LTO',num2str(i)]) = [LTO(i) 0 0];
    end
    
end

function PeakLim = Select_PeakLim(data,PeakLim_ex)
%Surface |FlatEven|ColbbeStone|StairUP          |     StairDown   |SlopeUp          |SlopeDown        |bnkL| bnkR |Grass|%%
%PeakLim |0.7     |  0.7      |        0.52     |     0.6         |   0.67          |    0.6          |        0.7      |%%
% functions ----------------------------------------------------------------------------------------

%FE,CS,GR,StrU,StrD,SlpU,SlpD,BnkL,BnKR
if contains(data.zoosystem.Header.Surface,'StrU')
    PeakLim=0.52;
elseif contains(data.zoosystem.Header.Surface,'StrD')
    PeakLim=0.6;
elseif contains(data.zoosystem.Header.Surface,'SlpU')
    PeakLim=0.67;
elseif contains(data.zoosystem.Header.Surface,'SlpD')
    PeakLim=0.6;
else
    PeakLim=PeakLim_ex;
end
    
    
    
    
