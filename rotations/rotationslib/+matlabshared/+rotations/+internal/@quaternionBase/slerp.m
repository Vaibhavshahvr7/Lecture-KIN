function qo = slerp(q1, q2, t)
%SLERP - Spherical Linear Interpolation
%  QO = SLERP(Q1,Q2,T) spherically interpolates between Q1 and Q2 by the
%  interpolation coefficient T. T is a single or double precision number
%  between 0 and 1, inclusive.  The inputs Q1, Q2, and T must have
%  compatible sizes. In the simplest cases, they can be the same size or
%  any one can be a scalar.  Two inputs have compatible sizes if, for every
%  dimension, the dimension sizes of the inputs are either the same or one
%  of them is 1.      
%
%  % Example:
%       e = deg2rad([40 20 10; 50 10 5; 45 70 1]);
%       q = quaternion(e, 'euler', 'ZYX', 'frame'); 
%       qs = slerp(q(1), q(2), 0.7); 
%       rad2deg(euler(qs, 'ZYX', 'frame'))  
%       
%   See also QUATERNION, MEANROT 

%   Copyright 2018 The MathWorks, Inc.    

%q1 and q2 and t must be compatible sizes and vectors


%#codegen 

% to use indexing, put in a private function (i.e. not a class member)
qo = matlabshared.rotations.internal.privslerp(q1,q2,t); 
