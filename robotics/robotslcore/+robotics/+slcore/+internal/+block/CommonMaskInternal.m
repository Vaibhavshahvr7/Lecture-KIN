classdef CommonMaskInternal
%This class is for internal use only. It may be removed in the future.

%CommonMaskInternal - Base class with shared code for working with Simulink block masks

%   Copyright 2019 The MathWorks, Inc.

    properties (Constant, Abstract)
        %MaskType - Type of block mask
        MaskType
    end

    properties (Constant, Abstract)
        %MaskParamIndex - Struct specifying index of various parameters
        %   associated with the block mask, for example: TopicEdit and
        %   TopicSourceDropdown
        MaskParamIndex

        %MaskDlgIndex - Struct specifying index of various widgets in the
        %   block mask  that *aren't* parameters, for example: buttons for
        %   topic or parameter selection
        MaskDlgIndex

        % SourceBlockName - Name of source block inside the
        %   subsystem (or '' if there is no system object block)
        SourceBlockName
    end

    properties (Abstract,Constant)
        % The following strings (used for the TopicSource dropdown) are
        % directly specified on the block mask & don't use the message
        % catalog.
        % Rationale: Even though these strings are user-visible, the user
        % can also programmatically set the parameter using
        %   set_param(gcb, 'topicsource', 'Select from Gazebo network')
        % If the strings are internationalized, then the set_param would
        % have to be locale-specific
        TopicSourceFromNetwork         
    end
    
    properties(Constant)
        TopicSourceSpecifyOwn = message('robotics:robotslgazebo:blockmask:TopicSourceSpecifyOwn').getString;
    end

    methods(Static, Abstract)
        dispatch(methodName, varargin)
    end

    methods(Static)
        %% Utilities
        function out = isLibraryBlock(block)
            out = strcmpi(get_param(bdroot(block), 'BlockDiagramType'), 'library');
        end
    end

    methods
        function configureNetworkAddrDlg(obj, block) %#ok<INUSD>
            dlg = robotics.slgazebo.internal.dlg.GazeboPreferenceSpecifier;   
            dlg.openDialog;
        end

    end

    methods (Abstract)
        updateSubsystem(obj, block)
        %updateSubsystem Update subsystem when configuration changes are made
        %   For example, this should be called when users make changes on
        %   the block mask, or if they call get_param and set_param.
    end

    methods
        %% Mask Initialization
        % This counts as a callback. It is invoked when the user:
        % * Changes the value of a mask parameter by using the block dialog box or?set_param.
        % * Changes any of the parameters that define the mask
        % * Causes the icon to be redrawn
        % * Copies the block
        %
        % Mask initialization is invoked after the individual parameter
        % callbacks

        function maskInitialize(obj, block) %#ok<INUSD>
        % This is invoked after the callbacks
        end

    end
end
