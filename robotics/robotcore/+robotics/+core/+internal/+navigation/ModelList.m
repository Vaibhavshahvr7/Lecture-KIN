classdef ModelList
    %This class is for internal use only. It may be removed in the future.
    
    %ModelList parses the model defintion XML.
    %   ModelList contains a struct that maps the navigation model names to
    %   their constructors in MATLAB. The struct is parsed from
    %   RoboticsNavigationModels.xml file.
    
    %   Copyright 2018 The MathWorks, Inc.
    %#codegen
    
    properties (Constant)
        ModelDefinitionXML = 'RoboticsNavigationModels.xml';
    end
    
    properties(SetAccess = immutable)
        %Models - immutable list of all the available models
        Models
    end
    
    methods
        function obj = ModelList()
            %ModelList constructor that starts the parsing
            coder.extrinsic('robotics.core.internal.navigation.ModelList.parseXML');
            obj.Models = coder.const(robotics.core.internal.navigation.ModelList.parseXML());
        end
    end
    
    methods (Static)
        
        function models = parseXML()
            %parseXML extrinsic function for extracting model prototype information from xml file
            
            filePath = fullfile(...
                fileparts(mfilename('fullpath')), ...
                robotics.core.internal.navigation.ModelList.ModelDefinitionXML);
            doc = xmlread(filePath);
            els = doc.getElementsByTagName('NavigationModel');
            for i = 0:els.getLength-1
                paramName = char(extractTagValue(els.item(i), 'name'));
                paramValue = char(extractTagValue(els.item(i), 'prototype'));
                models.(paramName) = paramValue;
            end
            
            function v = extractTagValue(item, tag)
                v = item.getElementsByTagName(tag).item(0).getFirstChild.getData;
            end
            
        end
        
    end
end

