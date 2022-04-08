function r = randrot(varargin)
%RANDROT Uniformly distributed random rotations
%   R = RANDROT(N) returns an N-by-N matrix of unit quaternions drawn
%   from a uniform distribution of random rotations. 
%
%   R = RANDROT(M,N) returns an M-by-N matrix.
%
%   R = RANDROT(M,N,P, ...) or RANDROT([M N P ...]) returns an
%   M-by-N-by-P-by-... array.
%
%   R = RANDROT returns a scalar.
%
%   EXAMPLE: Create a uniform distribution of points on the unit sphere 
%       q = randrot(500,1);
%       pt = rotatepoint(q, [1 0 0]);
%       scatter3(pt(:,1), pt(:,2), pt(:,3))
%       axis equal
%
%   See also QUATERNION 

%   Copyright 2018-2019 The MathWorks, Inc.    

%#codegen 

if nargin==0
    % randrot()
    dims = 1;

elseif nargin==1
    % randrot([1 2 3 ...]) or randrot(1)
    v1 = varargin{1};
    validateattributes(v1, {'numeric'}, ...
        {'integer', 'row', 'nonempty'}, ...
        'randrot');
    dims = v1;
else
    % randrot(1,2,3,...)
    for ii=1:nargin
        validateattributes(varargin{ii}, {'numeric'}, {'integer', ...
            'nonempty', 'scalar'}, ...
            'randrot', '', ii); 
    end
    dims = cat(2, varargin{:});
end

% Create temporaries to ensure the random numbers are always generated in
% the same order.
aNums = randn(dims);
bNums = randn(dims);
cNums = randn(dims);
dNums = randn(dims);

r1 = quaternion(aNums, bNums, cNums, dNums);
r = normalize(r1); 





