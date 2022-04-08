%% section 1 .txt file to .zoo conversation

fld=uigetfolder;
fl=engine('fld',fld,'ext','.txt');

SensorID.trunk='00B45AE2';
SensorID.shankL='00B44077';
SensorID.shankR='00B44090';  %76
SensorID.footL='00B44073';
SensorID.thighR='00B4406E';
SensorID.thighL='00B4406D';
SensorID.footR='00B44078';
Trials={'walking_03'}; %{'walking1'}
zdata=XsensMt2zoo(fl,SensorID,Trials);

%% section 2 Filtering the data with low pass butterworth filter

filt.type = 'butterworth';
filt.cutoff = 6;                
filt.order = 4;
filt.pass = 'lowpass';
chns = 'all';

% functions ----------------------------------------------------------------------------------------
bmech_filter(fld,chns,filt)
%% section 3 Heel strick detection using gyroscope magnitude data 

peak_lim = 0.65;
%segment_pairs = { {'trunk', 'thighR'}, {'thighR', 'shankR'}};      % prox, dist segments for jnt ang

% functions ----------------------------------------------------------------------------------------
gait_event_detect(fld, peak_lim) 

%% section 4 Hip and knee joint angle calculation

outdoor_joint_angle(fld) 
%% section 5 Ploting right knee flextion
grab
x=-data.kneeR_flex.line(1:600);
plot(x,'r')
hold on
title('Knee flextion Right')
%% detrend data to remove drift 

y=detrend(x);
y=y-y(1)+x(1);
plot(y,'b')
legend('Original','Detrended')
set(0,'DefaultLegendAutoUpdate','off')
%%
names=fieldnames(data.shankR_Gyr_X.event);
for i=1:length(names(1:8))
xline(data.shankR_Gyr_X.event.(names{i})(1));
end
%%
n_cycles=1;
outdoor_gait_cycle_data(fld,n_cycles)