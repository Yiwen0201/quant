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

        copyfile(fullfile(posDir, 'data.mat'), fullfile(posDir, 'calculate_region'));
        load(fullfile(posDir, 'data.mat'));

        % modify data
        if length(data.time_2) ~= length(data.time)
            [C, ia] = setdiff(data.time_2, data.time);
            data.time_2(ia) = [];
            data.ratio_2(ia) = [];
            data.ratio_3(ia) = [];
            data.percent(ia) = [];
        end

        t1 = max(find(data.time_2 <= 0));

        data.basal_2  = mean(data.ratio_2(1 : t1));
        data.delta_2  = max(data.ratio_2(t1+1 : length(data.ratio_2))) - data.basal_2;
        data.delta_ratio_2 = data.delta_2 / data.basal_2;

        data.basal_3  = mean(data.ratio_3(1 : t1));
        data.delta_3  = max(data.ratio_3(t1+1 : length(data.ratio_3))) - data.basal_3;
        data.delta_ratio_3 = data.delta_3 / data.basal_3;

        save(fullfile(posDir, 'data.mat'), 'data');

        % beads region
        figure(1); plot(data.time, data.ratio);
        title('beads region dynamics')

        % exclude beads region
        figure(2); plot(data.time_2, data.ratio_2);
        title('exclude beads region dynamics')

        % whole cell region
        figure(3); plot(data.time_2, data.ratio_3);
        title('whole cell dynamics')

        % one cell comparision
        figure(4); plot(data.time, data.ratio, 'b'); hold on
        figure(4); plot(data.time_2, data.ratio_2, 'r'); hold on
        figure(4); plot(data.time_2, data.ratio_3, 'g'); hold on
        title('three region comparison in one cell')
        legend('beads', 'exclude beads', 'whole cell')

        % beads region percentage
        figure(8); plot(data.time_2, data.percent);
        title('beads region percent')

        % beads region for all cell in dish
        figure(5); plot(data.time, data.ratio); hold on

        % exclude beads region for all cell in dish
        figure(6); plot(data.time_2, data.ratio_2); hold on

        % whole cell for all cell in dish
        figure(7); plot(data.time_2, data.ratio_3); hold on



        saveas(1, fullfile(outDdir, [pos_file(i).name, '_beads']), 'jpeg');
        saveas(1, fullfile(outDdir, [pos_file(i).name, '_beads']), 'fig');

        saveas(2, fullfile(outDdir, [pos_file(i).name, '_non_beads']), 'jpeg');
        saveas(2, fullfile(outDdir, [pos_file(i).name, '_non_beads']), 'fig');

        saveas(3, fullfile(outDdir, [pos_file(i).name, '_whole']), 'jpeg');
        saveas(3, fullfile(outDdir, [pos_file(i).name, '_whole']), 'fig');

        saveas(4, fullfile(outDdir, [pos_file(i).name, '_comp']), 'jpeg');
        saveas(4, fullfile(outDdir, [pos_file(i).name, '_comp']), 'fig');

        saveas(8, fullfile(outDdir, [pos_file(i).name, '_percent']), 'jpeg');
        saveas(8, fullfile(outDdir, [pos_file(i).name, '_percent']), 'fig');

        close(1); close(2); close(3); close(4); close(8);
    end

    saveas(5, fullfile(outDdir, 'all_beads'), 'jpeg');
    saveas(5, fullfile(outDdir, 'all_beads'), 'fig');

    saveas(6, fullfile(outDdir, 'all_non_beads'), 'jpeg');
    saveas(6, fullfile(outDdir, 'all_non_beads'), 'fig');

    saveas(7, fullfile(outDdir, 'all_whole'), 'jpeg');
    saveas(7, fullfile(outDdir, 'all_whole'), 'fig');

    close(5); close(6); close(7);


end
