
[C, ia] = setdiff(data.time_2, data.time);
data.time_2(ia) = [];
data.ratio_2(ia) = [];
data.ratio_3(ia) = [];
data.percent(ia) = [];

t1 = max(find(data.time_2 <= 0));

data.basal_2  = mean(data.ratio_2(1 : t1));
data.delta_2  = max(data.ratio_2(t1+1 : length(data.ratio_2))) - data.basal_2;
data.delta_ratio_2 = data.delta_2 / data.basal_2;

data.basal_3  = mean(data.ratio_3(1 : t1));
data.delta_3  = max(data.ratio_3(t1+1 : length(data.ratio_3))) - data.basal_3;
data.delta_ratio_3 = data.delta_3 / data.basal_3;