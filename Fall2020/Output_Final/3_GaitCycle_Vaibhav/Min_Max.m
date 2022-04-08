function MIN_MAX=Min_Max(VT,ML,AP)
MIN= struct('VT',min(VT),'ML',min(ML),'AP',min(AP));
MAX= struct('VT',max(VT),'ML',max(ML),'AP',max(AP));
MIN_MAX= struct('Min',MIN,'Max',MAX);

