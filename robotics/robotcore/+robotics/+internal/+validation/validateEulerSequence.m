function seq = validateEulerSequence( varargin )
%This function is for internal use only. It may be removed in the future.

%validateEulerSequence Parse an Euler sequence input
%   This function parses the input string that is given by the user and
%   resolves it to a valid Euler rotation sequence.

%   Copyright 2014-2018 The MathWorks, Inc.

%#codegen

    if isempty(varargin)
        % Use default rotation sequence
        seq = 'ZYX';
        return;
    end

    % Error if more than one argument
    coder.internal.errorIf(numel(varargin) > 1, 'shared_robotics:robotcore:utils:EulerSequenceTooManyInputs');

    % Otherwise, validate the input rotation sequence
    seq = convertStringsToChars(varargin{1});
    validateattributes(seq, {'char','string'}, {'nonempty'}, ...
                       'validateEulerSequence', 'seq');

    upperSeq = upper(seq);
    switch upperSeq
      case 'ZYZ'
        seq = upperSeq;
      case 'ZYX'
        seq = upperSeq;
      case 'XYZ'
        seq = upperSeq;
      otherwise
        if coder.target('MATLAB')
            error(message('shared_robotics:robotcore:utils:EulerSequenceNotSupported', ...
                          seq, 'ZYX, ZYZ, XYZ'));
        else
            assert(false);
        end
    end

end
