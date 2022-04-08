function gait_event_knee(fld, PeakLim)

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
        data = event_detect_data(data, PeakLim);
        zsave(fl{i},data)
    end
end


function data = event_detect_data(data, PeakLim)


ch = fieldnames(data);

if ismember('JointAnglesZXY_Right_Knee_Flexion_Extension', ch)
    
    Gmag=data.JointAnglesZXY_Right_Knee_Flexion_Extension.line; %knee angle flextion 
    % detect heel strike, mid swing, toe_off for Right side
    RHS = Heelstrike_Detection(Gmag,PeakLim); % min value between two peaks
    %RMS=  Mid_Swing_Detection(Gmag,PeakLim); % mid-swing are peaks
    %RTO=  Toe_off_Detection(RMS,RHS,Gmag); % min between RHS location + 10 and mind-swing
    %RMS= RMS(2:end); % mid-swing are peaks
    
    %adding as events to zoo
    for i = 1:length(RHS)
        data.JointAnglesZXY_Right_Knee_Flexion_Extension.event.(['RHS',num2str(i)]) = [RHS(i) 0 0];
    end
    
    %for i = 1:length(RMS)
     %   data.JointAnglesZXY_Right_Knee_Flexion_Extension.event.(['RMS',num2str(i)]) = [RMS(i) 0 0];
    %end
    
    %for i = 1:length(RTO)
     %   data.JointAnglesZXY_Right_Knee_Flexion_Extension.event.(['RTO',num2str(i)]) = [RTO(i) 0 0];
    %end
    
end

if ismember('JointAnglesZXY_Left_Knee_Flexion_Extension', ch)
    
    Gmag=data.JointAnglesZXY_Left_Knee_Flexion_Extension.line; %Knee angle
    % detect heel strike, mid swing, toe_off for Left side
    LHS = Heelstrike_Detection(Gmag,PeakLim); % min value between two peaks
    %LMS=  Mid_Swing_Detection(Gmag,PeakLim); % mid-swing are peaks
    %LTO=  Toe_off_Detection(LMS,LHS,Gmag); % min between LHS location + 10 and mind-swing
    %LMS= LMS(2:end); % mid-swing are peaks
    
    %adding as events to zoo
    for i = 1:length(LHS)
        data.JointAnglesZXY_Left_Knee_Flexion_Extension.event.(['LHS',num2str(i)]) = [LHS(i) 0 0];
    end
    
%     for i = 1:length(LMS)
%         data.JointAnglesZXY_Left_Knee_Flexion_Extension.event.(['LMS',num2str(i)]) = [LMS(i) 0 0];
%     end
%     
%     for i = 1:length(LTO)
%         data.JointAnglesZXY_Left_Knee_Flexion_Extension.event.(['LTO',num2str(i)]) = [LTO(i) 0 0];
%     end
    
end
    
    
    
