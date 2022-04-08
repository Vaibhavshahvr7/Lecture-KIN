    function Trunk = Output_Trunk(Atrunk2)
      
    VT = Atrunk2(:,1);
    ML = Atrunk2(:,2);
    AP = Atrunk2(:,3);
%     UnNormal = struct ('VT',VT,'ML',ML,'AP',AP);
%     MIN_MAX=Min_Max(VT,ML,AP);
%     Normal=Gaitcycle_Normal(VT,ML,AP);
%     Trunk = struct('UnNormal',UnNormal,'MIN_MAX',MIN_MAX,'Normal',Normal);
Trunk = struct ('VT',VT,'ML',ML,'AP',AP);