    function Shank = Output_Shank(Ashank2)
      
    VT = Ashank2(:,1);
    ML = Ashank2(:,2);
    AP = Ashank2(:,3);
%     UnNormal = struct ('VT',VT,'ML',ML,'AP',AP);
%     MIN_MAX=Min_Max(VT,ML,AP);
%     Normal=Gaitcycle_Normal(VT,ML,AP);
%     Shank = struct('UnNormal',UnNormal,'MIN_MAX',MIN_MAX,'Normal',Normal);
    Shank = struct ('VT',VT,'ML',ML,'AP',AP);
    
    