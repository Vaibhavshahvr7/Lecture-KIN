function [qa,qb,qc,qd] = feul2qparts(ein, rot)
%FEUL2QPARTS - Quaternion Parts From Euler Angles
%   This function is for internal use only. It may be removed in the future.

%   Copyright 2017 The MathWorks, Inc.

%#codegen

ein = ein./2;
a = ein(:,1);
b = ein(:,2);
c = ein(:,3);

found = true;
switch upper(rot)
    case 'YZY'
        qa = cos(a + c).*cos(b);
        qb = sin(b).*sin(a - c);
        qc = sin(a + c).*cos(b);
        qd = sin(b).*cos(a - c);
    case 'YXY'
        qa = cos(a + c).*cos(b);
        qb = sin(b).*cos(a - c);
        qc = sin(a + c).*cos(b);
        qd = -sin(b).*sin(a - c);
    case 'ZYZ'
        qa = cos(a + c).*cos(b);
        qb = -sin(b).*sin(a - c);
        qc = sin(b).*cos(a - c);
        qd = sin(a + c).*cos(b);
    case 'ZXZ'
        qa = cos(a + c).*cos(b);
        qb = sin(b).*cos(a - c);
        qc = sin(b).*sin(a - c);
        qd = sin(a + c).*cos(b);
    case 'XYX'
        qa = cos(a + c).*cos(b);
        qb = sin(a + c).*cos(b);
        qc = sin(b).*cos(a - c);
        qd = sin(b).*sin(a - c);
    case 'XZX'
        qa = cos(a + c).*cos(b);
        qb = sin(a + c).*cos(b);
        qc = -sin(b).*sin(a - c);
        qd = sin(b).*cos(a - c);
    case 'XYZ'
        qa = cos(a).*cos(b).*cos(c) - sin(a).*sin(b).*sin(c);
        qb = cos(b).*cos(c).*sin(a) + cos(a).*sin(b).*sin(c);
        qc = cos(a).*cos(c).*sin(b) - cos(b).*sin(a).*sin(c);
        qd = cos(a).*cos(b).*sin(c) + cos(c).*sin(a).*sin(b);
    case 'YZX'
        qa = cos(a).*cos(b).*cos(c) - sin(a).*sin(b).*sin(c);
        qb = cos(a).*cos(b).*sin(c) + cos(c).*sin(a).*sin(b);
        qc = cos(b).*cos(c).*sin(a) + cos(a).*sin(b).*sin(c);
        qd = cos(a).*cos(c).*sin(b) - cos(b).*sin(a).*sin(c);
    case 'ZXY'
        qa = cos(a).*cos(b).*cos(c) - sin(a).*sin(b).*sin(c);
        qb = cos(a).*cos(c).*sin(b) - cos(b).*sin(a).*sin(c);
        qc = cos(a).*cos(b).*sin(c) + cos(c).*sin(a).*sin(b);
        qd = cos(b).*cos(c).*sin(a) + cos(a).*sin(b).*sin(c);
    case 'XZY'
        qa = cos(a).*cos(b).*cos(c) + sin(a).*sin(b).*sin(c);
        qb = cos(b).*cos(c).*sin(a) - cos(a).*sin(b).*sin(c);
        qc = cos(a).*cos(b).*sin(c) - cos(c).*sin(a).*sin(b);
        qd = cos(a).*cos(c).*sin(b) + cos(b).*sin(a).*sin(c);
    case 'ZYX'
        qa = cos(a).*cos(b).*cos(c) + sin(a).*sin(b).*sin(c);
        qb = cos(a).*cos(b).*sin(c) - cos(c).*sin(a).*sin(b);
        qc = cos(a).*cos(c).*sin(b) + cos(b).*sin(a).*sin(c);
        qd = cos(b).*cos(c).*sin(a) - cos(a).*sin(b).*sin(c);
    case 'YXZ'
        qa = cos(a).*cos(b).*cos(c) + sin(a).*sin(b).*sin(c);
        qb = cos(a).*cos(c).*sin(b) + cos(b).*sin(a).*sin(c);
        qc = cos(b).*cos(c).*sin(a) - cos(a).*sin(b).*sin(c);
        qd = cos(a).*cos(b).*sin(c) - cos(c).*sin(a).*sin(b);
    otherwise
        found = false;
        qa = zeros(size(a), 'like', a);
        qb = zeros(size(a), 'like', a);
        qc = zeros(size(a), 'like', a);
        qd = zeros(size(a), 'like', a);
end
coder.internal.assert(found, 'shared_rotations:quaternion:NoSeqConv', rot);
end
