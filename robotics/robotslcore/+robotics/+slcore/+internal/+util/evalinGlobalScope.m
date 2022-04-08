function varargout = evalinGlobalScope(model, exprToEval)
    %This function is for internal use only. It may be removed in the future.
    
    %EVALINGLOBALSCOPE Evaluate expression in global scope
    %   If the MODEL input is empty, the expression will always be evaluated in the
    %   base workspace. Otherwise, the expression will be passed along to the
    %   evalInGlobalScope function.
    
    %   Copyright 2018 The MathWorks, Inc.
    
    if isempty(model)
        % Always evaluate in base workspace
        [varargout{1:nargout}] = evalin('base', exprToEval);
    else
        % Pass expression to standard evalinGlobalScope function
        [varargout{1:nargout}] = evalinGlobalScope(model, exprToEval);
    end
end

