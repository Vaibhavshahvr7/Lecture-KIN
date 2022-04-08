function qo = privslerp(q1, q2, t)
%   This function is for internal use only. It may be removed in the future. 
%PRIVSLERP Slerp implementation, as a function

%   Copyright 2018 The MathWorks, Inc.    

%#codegen 
coder.internal.assert(isa(q1, 'quaternion'), ...
    'shared_rotations:quaternion:QuatExpectedArg', '1');
coder.internal.assert(isa(q2, 'quaternion'), ...
    'shared_rotations:quaternion:QuatExpectedArg', '2');
validateattributes(t, {'double', 'single'}, {'>=' 0, '<=', 1, ...
    'finite', 'nonnan', 'real', 'nonsparse'}, 'slerp', 't', 3);

% Codegen requires all sizes to be equal.
if ~isempty(coder.target)
    coder.internal.assert(isequal(size(q1), size(q2), size(t)), ...
        'shared_rotations:quaternion:SlerpCodegen');
end
q1n = normalize(q1);
q2n = normalize(q2);

% Implement quaterion dot product, inline
[a1, b1, c1, d1] = parts(q1n);
[a2, b2, c2, d2] = parts(q2n);

dp = a1.*a2 + b1.*b2 + c1.*c2 + d1.*d2;

% Negative dot product, the quaternions aren't pointing the same way (one
% pos, one negative). Flip the second one. Sim and codegen path because 
% logical indexing on the rhs is a varsize operation which causes MATLAB
% Coder to error. The for-loop is also more efficient in the generated C
% code. 
if isempty(coder.target)
    dpidx = dp < 0;
    if any(dpidx(:))
        q2n(dpidx) = -q2n(dpidx);
        dp(dpidx) = -dp(dpidx);
    end
    dp(dp > 1) = 1;
else
    for ii=1:numel(dp)
        if dp(ii) < 0
            q2n(ii) = -q2n(ii);
            dp(ii) = -dp(ii);
        end
        if dp(ii) > 1
            dp(ii) = 1;
        end
    end
    
end
theta0 = acos(dp);


sinv = 1./sin(theta0);
qnumerator = q1n.*sin((1- t).*theta0) + q2n.*sin(t.*theta0);
qo =  qnumerator.* sinv;



% Fix up dp == 1 which causes NaN quaternions. This means the the two
% quaternions are the same - just use the first. Sim and codegen paths exist
% because sim allows implicit expansion, codegen requires same size. So for
% the codegen portion, isequal(size(qo), size(q1))

% if sinv is inf, qo is nan. But we can't look for nans in qo because they
% may have come in from q1 or q2 == nan at input. Instead find infs in
% sinv, then expand it to match size of qo, then use findOriginalIndex to
% update qo.

infmap = isinf(sinv);
if any(infmap(:)) % For performance, let's not do this unless needed.
    
    % Compute infs that were caused by sinv. Should be same size as qo
    infmapExpanded = true(size(qnumerator)) & infmap; 
    if isempty(coder.target)
        [q1Idx, qoIdx] = matlabshared.rotations.internal.findOriginalIndex(...
            infmapExpanded, q1n);
        
        if ~isempty(qoIdx)
            qo(qoIdx) = q1n(q1Idx);
        end
    else
        % Because in codegen all sizes are the same, this is just a simple
        % loop.
        for ii=1:numel(sinv)
            if isinf(sinv(ii))
                qo(ii) = q1n(ii);
            end
        end
    end
end
qo = normalize(qo);
