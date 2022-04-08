function r = angle(m1,m2,ref)

%Calculates the smallest angle between two vectors, m1 and m2. 
%
% r = angle(m1,m2,ref)
%
% ARGUMENTS    
%  m1    ...      1st nx3 vector
%  m2    ...      2nd nx3 vector
%  ref   ...      string: 'deg' for degrees or 'rad' for radians. 
%                 Default is degrees.
%
% OUTPUTS
%  r    ...       angle 
%
%
% Created by JJ Loh 2006
% 
% updated by Phil Dixon Oct 2008



if nargin ==2
    ref = 'deg';
end

[~,cols] = size(m1);

if cols ==1
    m1 = makerow(m1);
    m2 = makerow(m2);
end

dotp = diag(m1*m2');

mag1 = sqrt(diag(m1*m1'));
mag2 = sqrt(diag(m2*m2'));

r = acos(dotp./(mag1.*mag2));


% changes to degrees if 'deg' is chosen


switch ref

    case 'deg'
        r = r*180;
        r = r/pi;

    case 'rad'

        
end





