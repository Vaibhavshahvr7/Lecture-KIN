function sl_customization(~)
    %sl_customization add icon package when Simulink is launched

    %   Copyright 2019 The MathWorks, Inc.
    
    iconfolder = fullfile(matlabroot ,...
        'toolbox', 'shared', 'robotics', 'robotslcore', 'blockicons');
    
    DVG.Registry.addIconPackage(iconfolder);
end