function ndata = resamp_nofilter(data,factor)

% ndata = resamp_nofilter(data,factor) takes column vector of any length and
% normalizes it according to factor
%
% NOTES
% - normalizeline is the same code. This will be depreciated in future
%   releases
%
% ARGUMENTS
%   data      ...  column vector
%   factor   ...   amount to change data by ex. 2 will double length of
%                  data, 0.5 will half the data
%
% RETURNS
%   ndata     ...  normalized data containing ndatalength+1 number of points
%
%
%
% Created by Phil Dixon & JJ Loh
% McGill University Biomechanics
%
% Updated Feb 2010
% -back to original code
%
% Updated June 2011
% - small error in rounding fixed for conversion in resamp_nofilter
%
% Updated May 2016
% - If entire matrix is NaNs, new matrix of NaNs of correct size will
%   be returned in ndata
% - Initialized output stk (ndata)



data = makecolumn(data);
[r,c]=size(data);
ndatalength = round(r*factor);  % this is more precise
xdata = (((1:r)'-1)/(r-1))*ndatalength;  %% JJ code
ndata = zeros(ndatalength,c);               % initialize stk


if isempty(find(~isnan(data), 1))
   ndata = NaN*ndata;
    
else
    id = (0:ndatalength-1)';
    for i = 1:c
        yd = data(:,i);
        nindx = find(isnan(yd));
        
        xxd = xdata;
        xxd(nindx) = [];
        yyd = yd;
        yyd(nindx) = [];
        if isempty(yyd)
            ndata = [];
            return
        end
        
        ndata(:,i) = interp1(xxd,yyd,id);
        
    end
    
    
end
