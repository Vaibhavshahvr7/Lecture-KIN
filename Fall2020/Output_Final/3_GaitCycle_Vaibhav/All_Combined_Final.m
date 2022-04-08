%-----------------------------------------------------

% All_Combined_Final.m (Vaibhav Shah dd/mm/yy)

%--------------------------------------------------------------------------


% INPUT

% 1. "data.mat" Lou et al. (2020)

% OUTPUT

% 1. Struct - "FinalOutput.mat" 
%--------------------------------------------------------------------------
%%
% clc; clear all;
% 
% load('data.mat');

%% Variables that should be set
FinalOutput= struct('FlatEven',[],'CobbleStone',[],'StairUp',[],'StairDown',[],'SlopeUp',[],'SlopeDown',[],'BnkL',[],'BnkR',[],'Grass',[]);

% select=1; % 1=FlatEven;2=CobbleStone;3=StairUp;4=StairDown;5=SlopeUp;6=SlopeDown;7=BnkL,8=BnkR,9=Grass;
for select=1:9
FinalOutput= Final_Output(data,select,FinalOutput);
end
 save('FinalOutput.mat','FinalOutput')
