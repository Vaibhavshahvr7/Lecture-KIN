function x = reshape(obj,varargin)
%RESHAPE Reshape a quaternion array
%   RESHAPE(X,M,N) or RESHAPE(X,[M,N]) returns the M-by-N matrix
%   whose elements are taken columnwise from X. An error results
%   if X does not have M*N elements.
%
%   RESHAPE(X,M,N,P,...) or RESHAPE(X,[M,N,P,...]) returns an
%   N-D array with the same elements as X but reshaped to have
%   the size M-by-N-by-P-by-.... The product of the specified
%   dimensions, M*N*P*..., must be the same as NUMEL(X).
%
%   RESHAPE(X,...,[],...) calculates the length of the dimension
%   represented by [], such that the product of the dimensions
%   equals NUMEL(X). The value of NUMEL(X) must be evenly divisible
%   by the product of the specified dimensions. You can use only one
%   occurrence of [].

%   Copyright 2018 The MathWorks, Inc.    


obj.a = reshape(obj.a,varargin{:});
obj.b = reshape(obj.b,varargin{:});
obj.c = reshape(obj.c,varargin{:});
obj.d = reshape(obj.d,varargin{:});
x = obj;
end
