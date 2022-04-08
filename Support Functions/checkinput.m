function [fld,fl,saveFile] = checkinput(fld,ext)

% [fld,fl,saveFile] = CHECKINPUT(fld,ext) standalone function used to
% switch between file and folder inputs

% try to catch error if fld is the output of engine
if isa(fld, 'cell')
fld = fld{1};
end

if strfind(fld,ext)                                       % for converting a single trial 
    if iscell(fld)
        fld = fld{1};
    end
    fl= {fld};
    fld = fileparts(fld);
    saveFile = false;                                        % do not save output to zoo file
else
    fl = engine('path',fld,'extension',ext);           % normal case, operate on folder
    saveFile = true;
end