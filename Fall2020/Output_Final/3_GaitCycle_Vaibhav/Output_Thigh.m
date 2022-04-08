    function Thigh = Output_Thigh(Athigh2)
      
    VT = Athigh2(:,1);
    ML = Athigh2(:,2);
    AP = Athigh2(:,3);
%     UnNormal = struct ('VT',VT,'ML',ML,'AP',AP);
%     MIN_MAX=Min_Max(VT,ML,AP);
%     Normal=Gaitcycle_Normal(VT,ML,AP);
%     Thigh = struct('UnNormal',UnNormal,'MIN_MAX',MIN_MAX,'Normal',Normal);
Thigh = struct ('VT',VT,'ML',ML,'AP',AP);