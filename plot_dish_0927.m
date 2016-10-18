function plot_dish_0927(dishDir)

    if nargin < 1
        dishDir = uigetdir;
    end

    % read all the position folders
    pos_file = dir(fullfile(dishDir, 'p*'));
    p_idx = 1;
    while(p_idx <= length(pos_file))
        if(pos_file(p_idx).isdir)
            p_idx = p_idx + 1;
        else
            pos_file(p_idx) = [];
        end
    end

    % output directory for figure for each position
    outDdir = fullfile(dishDir, 'figures');
    if ~exist(outDdir)
        mkdir(outDdir);
    end

    for i = 1 : length(pos_file)
        posDir = fullfile(dishDir, pos_file(i).name);
        load(fullfile(posDir, 'data.mat'));

        figure(1); plot(data.time, data.ratio);
        figure(2); plot(data.time, data.ratio); hold on

        saveas(1, fullfile(outDdir, pos_file(i).name), 'jpeg');
        saveas(1, fullfile(outDdir, pos_file(i).name), 'fig');      

        close(1);  
    end

    saveas(2, fullfile(outDdir, 'all'), 'jpeg');
    saveas(2, fullfile(outDdir, 'all'), 'fig');

    close(2);

    
end