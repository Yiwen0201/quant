function data = mod_data(data, t1, t2)
    data.basal  = mean(data.ratio(1 : t1));
    data.delta  = max(data.ratio(t2 : length(data.ratio))) - data.basal;
    data.delta_ratio = data.delta / data.basal;
end