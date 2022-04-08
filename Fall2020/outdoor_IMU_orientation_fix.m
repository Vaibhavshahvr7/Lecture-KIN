function outdoor_IMU_orientation_fix(fld,position,variable,s_start,s_end,t_start,t_end,rotation_angle)

fl= select_fault_files(fld,s_start,s_end,t_start,t_end)';
quat = quaternion(rotation_angle,'eulerd','XYZ','point');
X = [position, '_',  variable, '_X'];
Y = [position, '_', variable, '_Y'];
Z = [position, '_', variable, '_Z'];

for i=1:length(fl)
    msg = 'Switched X and Y trunk axis';
    batchdisp(fl{i}, msg)
    data=zload(fl{i});
    var=[data.(X).line,data.(Y).line,data.(Z).line];
    var=rotateframe(quat, var);
    data.(X).line = var(:,1);
    data.(Y).line = var(:,2);
    data.(Z).line = var(:,3);
    zsave(fl{i},data,msg);
end

function fault_files= select_fault_files(fld,s_start,s_end,t_start,t_end)
fault_files={};
s = s_end-s_start+1;
for s_num=1:s
    Sub_Num = num2str(s_start+s_num-1);
    t = t_end-t_start+1;
    for t_num = 1:t
        T_Num = num2str(t_start+t_num-1);
        if length(T_Num) ==1
            T_Num = ['0', num2str(T_Num)];
        end
        r = engine('fld', [fld, filesep, 'subject_',Sub_Num], 'search file', ['_trial_',T_Num,'.zoo']);
        fault_files{1,t_num} = r{1};
    end
end
