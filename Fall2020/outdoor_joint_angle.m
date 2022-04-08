function outdoor_joint_angle(fld, segment_pairs)

if nargin==1
    segment_pairs = { {'trunk', 'thighR'}, {'thighR', 'shankR'},{'trunk', 'thighL'},{'thighL', 'shankL'}};
end

fl = engine('fld', fld, 'extension', 'zoo');
for i = 1:length(fl)
    batchdisp(fl{i}, 'computing joint angles')
    data = load(fl{i},'-mat');
    data = data.data;
    data = joint_angle_data(data, segment_pairs);
    zsave(fl{i},data)
end

function data = joint_angle_data(data, segment_pairs)


for i = 1:length(segment_pairs)
    
    segment_pair = segment_pairs{i};
    
    % right hip
    if ismember({'trunk', 'thighR'}, segment_pair)
        Qtrunk= outdoor_quaternion(data,'trunk');
        %Qtrunk= quaternion_rotation(Qtrunk);
        QthighR= outdoor_quaternion(data,'thighR');
        QhipR = conj(Qtrunk) .* QthighR;
        QhipR=quat2eul(QhipR);
        hipR_flex= rad2deg(QhipR(:,2));
        data = addchannel_data(data,"hipR_flex",hipR_flex,'Analog');
    end
    
    % right knee
    if ismember({'thighR', 'shankR'}, segment_pair)
        QshankR= outdoor_quaternion(data,'shankR');
        QkneeR =conj(QthighR) .*QshankR;
        %QkneeR= quaternion_rotation(QkneeR);
        QkneeR=quat2eul(QkneeR);
        kneeR_flex = rad2deg(QkneeR(:,2));
        data = addchannel_data(data,"kneeR_flex",kneeR_flex,'Analog');
    end
    
        % left hip
    if ismember({'trunk', 'thighL'}, segment_pair)
        Qtrunk= outdoor_quaternion(data,'trunk');
        %Qtrunk= quaternion_rotation(Qtrunk);
        QthighL= outdoor_quaternion(data,'thighL');
        QhipL = conj(Qtrunk) .* QthighL;
        QhipL=quat2eul(QhipL);
        hipL_flex= rad2deg(QhipL(:,2));
        data = addchannel_data(data,"hipL_flex",hipL_flex,'Analog');
    end
        % right knee
    if ismember({'thighL', 'shankL'}, segment_pair)
        QshankL= outdoor_quaternion(data,'shankL');
        QkneeL =conj(QthighL) .*QshankL;
        %QkneeL= quaternion_rotation(QkneeL);
        QkneeL=quat2eul(QkneeL);
        kneeL_flex = rad2deg(QkneeL(:,2));
        data = addchannel_data(data,"kneeL_flex",kneeL_flex,'Analog');
    end
end

% left hip (code later)

% left knee (code later)


% QthighL= outdoor_quaternion(data,'thighL');
% QshankL= outdoor_quaternion(data,'shankL');
% 
% 
% 
% QhipL = conj(Qtrunk) .* QthighL;
% QhipL=quat2eul(QhipL);
% hipL_flex= rad2deg(QhipL(:,2));
% 
% 
% 
% QkneeL =conj(QthighL) .*QshankL;
% QkneeL= quaternion_rotation(QkneeL);
% QkneeL=quat2eul(QkneeL);
% kneeL_flex = rad2deg(QkneeL(:,2));
% 
% % add to zoosystem
% data = addchannel_data(data,"hipL_flex",hipL_flex,'Analog');
% data = addchannel_data(data,"kneeL_flex",kneeL_flex,'Analog');
