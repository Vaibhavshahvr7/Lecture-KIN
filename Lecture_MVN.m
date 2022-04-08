%%
fld=uigetfolder;
fl=engine('fld',fld,'ext','.xlsx');
xsens2zoo(fld, '.xlsx')
%%
fld=uigetfolder;
action='keep';
ch={'JointAnglesZXY_Right_Hip_Flexion_Extension','JointAnglesZXY_Left_Hip_Flexion_Extension',...
    'JointAnglesZXY_Right_Knee_Flexion_Extension','JointAnglesZXY_Left_Knee_Flexion_Extension',...
    'JointAnglesZXY_Right_Ankle_Dorsiflexion_Plantarflexion','JointAnglesZXY_Left_Ankle_Dorsiflexion_Plantarflexion'};


bmech_removechannel(fld,ch,action)
%% 
PeakLim=0.7;
gait_event_knee(fld, PeakLim)
%%
n_cycles=1;
outdoor_gait_cycle_data_Knee(fld,n_cycles)
%%
bmech_normalize(fld) 
%%
fld=uigetfolder;
[subjects, Conditions] = extract_filestruct(fld);
Conditions=unique(Conditions);
ch={'JointAnglesZXY_Right_Knee_Flexion_Extension', 'JointAnglesZXY_Right_Hip_Flexion_Extension'};
%%
table_event = bmech_line(fld,ch,subjects, Conditions);
%%
figure 
for i=1:length(table_event.JointAnglesZXY_Right_Knee_Flexion_Extension)
    plot(table_event.JointAnglesZXY_Right_Knee_Flexion_Extension{i,1},'r')
    hold on
end
figure 
for i=1:length(table_event.JointAnglesZXY_Right_Hip_Flexion_Extension)
    plot(table_event.JointAnglesZXY_Right_Hip_Flexion_Extension{i,1},'r')
    hold on
end
