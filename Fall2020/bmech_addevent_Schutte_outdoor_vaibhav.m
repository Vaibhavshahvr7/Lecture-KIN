function bmech_addevent_Schutte_outdoor_vaibhav(fld, chns, walk_or_run)

% set default for walk = 1 or run = 2 see FeatureExtraction_v2
if nargin == 2
    walk_or_run = 1;    
end

fl = engine('fld', fld, 'extension', 'zoo');
for f = 1:length(fl)
    batchdisp(fl{f}, 'computing Schutte events')
    data = load(fl{f}, '-mat');
    data = data.data;
    
    % Extracts Schutte feature ------------
    data= Outdoor_Schutte(data, chns, walk_or_run);
    
    % save to zoo
    zsave(fl{f}, data)
end


function data= Outdoor_Schutte(data,chns, walk_or_run)

% extract information from zoo file
fsamp = data.zoosystem.Video.Freq;   % instead of hard coding 

for i = 1:length(chns)
    
    % set position of acceleromer 1 or 2, see FeatureExtraction_v2
    if strcmp(chns{i}, 'trunk')
        pos_acc = 1;
    else
        pos_acc = 2;
    end
    
    Av=data.([chns{i}, '_Acc_X']).line;
    Aml=data.([chns{i}, '_Acc_Y']).line;
    Aap=data.([chns{i}, '_Acc_Z']).line;
    
    % get schutte events
    [Feautres, Labels, Units] = FeatureExtraction_v2(Av, Aml, Aap,fsamp, pos_acc,'', walk_or_run);
   
    % add to zoo files as events
    for j = 1:length(Labels)
        data.([chns{i}, '_Acc_X']).event.(Labels{j}) = [1 Feautres(j) 0];
        
        if ~isfield(data.zoosystem.Units, Labels{j})
           data.zoosystem.Units.(Labels{j}) = Units{j};
        end 
    end
end