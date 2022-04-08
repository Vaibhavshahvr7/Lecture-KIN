function Plot_acc(fld)


fl = engine('fld', fld, 'extension', 'zoo');

Color_plot = ['g','r','b'];


for f = 1:length(fl)
    batchdisp(fl{f}, 'plotting shankR_Acc_X')
    data = load(fl{f}, '-mat');
    data = data.data;
    if ~isempty(strfind(fl{f},'FE'))
        ppplace=1;
    elseif ~isempty(strfind(fl{f},'CS'))
        ppplace=2;
    elseif ~isempty(strfind(fl{f},'GR'))
        ppplace=3;
    elseif ~isempty(strfind(fl{f},'BnkL'))
        ppplace=4;
    elseif ~isempty(strfind(fl{f},'BnkR'))
        ppplace=5;
    elseif ~isempty(strfind(fl{f},'SlpU'))
        ppplace=6;
    elseif ~isempty(strfind(fl{f},'SlpD'))
        ppplace=7;
    end
    % Extracts Schutte feature ------------
    plot_data_acc(data,ppplace);
    
    
end
end


function data= plot_data_acc(data,ppplace)



Av=data.shankR_Acc_X.line;
subplot(7,1,ppplace)
plot(Av,'b')
hold on


end