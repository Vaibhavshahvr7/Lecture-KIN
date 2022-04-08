function zdata=XsensMt2zoo(fl,SensorID,Trials)

tic
for t=1:length(Trials)
    nfl=fl(contains(fl,Trials{t}));
    zdata=struct;
    sensor.trunk=contains(nfl,SensorID.trunk);
    sensor.shankL=contains(nfl,SensorID.shankL);
    sensor.shankR=contains(nfl,SensorID.shankR);
    sensor.footL=contains(nfl,SensorID.footL);
    sensor.thighR=contains(nfl,SensorID.thighR);
    sensor.thighL=contains(nfl,SensorID.thighL);
    sensors=fieldnames(sensor);
    for i=1:length(sensors)
        data=readtable(nfl{sensor.(sensors{i})});
        Var=data.Properties.VariableNames;
        for j=1:length(Var)
            if contains(Var(j),'SampleTimeFine')
                disp(['skiping SampleTimeFine'])
            elseif contains(Var(j),'PacketCounter')
                disp(['skiping PacketCounter'])
            else
                fn=strfind(nfl{sensor.(sensors{i})},'\');
                flenght=length(fn);
                filename=nfl{sensor.(sensors{i})}((fn(flenght-1)+1:fn(flenght)-1));
                zdata.zoosystem = setZoosystem(filename);
                zdata.zoosystem.Video.Freq=100;
                zdata.zoosystem.Header.Surface='Lab';
                disp(['adding ',sensors{i},'_',Var{j},' to zoo system'])
                zdata=addchannel_data(zdata,[sensors{i},'_',Var{j}],data.(Var{j}),'Video');
            end
        end
    end
    zdata.zoosystem.Video.Channels=fieldnames(zdata);
    [fpath,~]=fileparts(nfl{i});
    zfl=[fpath,filesep,filename,'.zoo'];
    zsave(zfl,zdata)
end
disp(' ')
disp('**********************************')
disp('Finished converting data in: ')
toc
disp('**********************************')

