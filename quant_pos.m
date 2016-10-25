function data = quant_pos(prefix, time_frame, idx_pattern, idx_postfix, posDir)

    % check input info
    if nargin < 1
        prompt = {'Prefix of this position: ', 'Enter frame1: ', 'Enter frame2: ',...
                  'Define idx_pattern: ', 'Define idx_postfix: '};
        dlg_title = 'Input';
        num_lines = 1;
        defaultans = {'date_info_dish_pos','8','9', 't\d', '.TIF'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

        prefix = answer{1};

        frame1 = str2num(answer{2});
        frame2 = str2num(answer{3});
        time_frame = [frame1; frame2];

        idx_pattern = answer{4};
        idx_postfix = answer{5};

        posDir = uigetdir;
    elseif nargin == 1
        prompt = {'Enter frame1: ', 'Enter frame2: ',...
                  'Define idx_pattern: ', 'Define idx_postfix: '};
        dlg_title = 'Input';
        num_lines = 1;
        defaultans = {'8','9', 't\d', '.TIF'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

        frame1 = str2num(answer{1});
        frame2 = str2num(answer{2});
        time_frame = [frame1; frame2];

        idx_pattern = answer{3};
        idx_postfix = answer{4};

        posDir = uigetdir;
    elseif nargin == 2
        prompt = {'Define idx_pattern: ', 'Define idx_postfix: '};
        dlg_title = 'Input';
        num_lines = 1;
        defaultans = {'t\d', '.TIF'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

        idx_pattern = answer{1};
        idx_postfix = answer{2};

        posDir = uigetdir;
    elseif nargin == 3
        prompt = {'Define idx_postfix: '};
        dlg_title = 'Input';
        num_lines = 1;
        defaultans = {'.TIF'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

        idx_postfix = answer{1};

        posDir = uigetdir;
    elseif nargin == 4
        posDir = uigetdir;
    elseif nargin > 5
        error('Invalid input argument, please read the code and input correctly! \n');
    end

    % shift when calculating intensity, in case of 0/0
    shift = 1e-4;

    % intensity image, calculation region image
    outDir = fullfile(posDir, 'calculate_region');
    if ~exist(outDir)
        mkdir(outDir);
    end

    % Get filename for ch1, ch2, ch3
    ch1_file = dir(fullfile(posDir, '*FRET*'));
    ch2_file = dir(fullfile(posDir, '*CFP*'));
    ch3_file = dir(fullfile(posDir, '*DIC*'));

    % dir for mask file, for 0907
    maskDir = fullfile(posDir, 'output');
    tmp_file = dir(fullfile(maskDir, '*-*'));

    for i = 1 : length(tmp_file)
        if(tmp_file(i).isdir)
            tmp_maskDir = [maskDir, '\', tmp_file(i).name];
            if(length(dir(fullfile(tmp_maskDir, '*ratio*'))) < length(ch1_file))
                continue;
            end
            maskDir = tmp_maskDir;
            mask_file = dir(fullfile(maskDir, '*ratio*'));
            break;
        end
    end

    for i = 1 : length(ch1_file)

        % get idx for this time frame
        idx1 = regexp(ch1_file(i).name, idx_pattern);
        idx2 = regexp(ch1_file(i).name, idx_postfix);

        idx = ch1_file(i).name(idx1+1 : idx2-1);
        idx = str2num(idx);

        idx_map(idx) = i;
    end

    % If the index is not continuous
    idx_map = idx_map(idx_map ~= 0);

    % this is for solving some DIC image becomes too bright, and result in mask3 too big
    % if current dish has more than one pos have DIC issues (too bright) define it as bad
    % eg: 0716_baz1_dish2_p6
    global_tag = true;

    for i = 1 : length(idx_map)

        % index of files in ch1/2/3_file
        cur_idx = idx_map(i);

        % if current frame is a good one
        local_tag = true;

        % read ch1, ch2, ch3 image
        im1 = imread(fullfile(posDir, ch1_file(cur_idx).name));
        im2 = imread(fullfile(posDir, ch2_file(cur_idx).name));
        im3 = imread(fullfile(posDir, ch3_file(cur_idx).name));

        % % mask for 0929 data
        ratio_image = imread(fullfile(maskDir, mask_file(cur_idx).name));
        ratio_gray = rgb2gray(ratio_image);
        mask1 = bwareaopen(ratio_gray, 100);

        % mask1, calculate from FRET ch, whole cell
        % l1 = graythresh(im1);
        % mask1 = im2bw(im1, l1);

        % subtract background
        % Using same method as in fluocell, preprocess.m, line 36
        bg_file = fullfile(posDir, 'output/background.mat');

        % subtract background for im1
        bg_bw = get_background_0926(im1, bg_file, 'method', 'auto');
        bw = double(bg_bw);
        bg_value = sum(sum(double(im1) .* bw)) / sum(sum(bw));
        im_sub = double(im1) - bg_value;
        im1_sub = max(im_sub, 0);

        % subtract background for im2
        bg_bw = get_background_0926(im2, bg_file, 'method', 'auto');
        bw = double(bg_bw);
        bg_value = sum(sum(double(im2) .* bw)) / sum(sum(bw));
        im_sub = double(im2) - bg_value;
        im2_sub = max(im_sub, 0);

        % calculate intensity
        im4 = (double(im1_sub) + shift) ./ (double(im2_sub) + shift);
        % figure(1); imagesc(im4);

        % whole cell average
        im5 = im4 .* mask1;

        if i <= time_frame(1)
            % before adding beads, only apply FRET mask
            % im6 = im4 .* mask1;
            % im6 = im4 .* mask;
            im6 = im5;

            cell_sum = sum(sum(mask1));
            bead_sum = 0;
            percent(i) = bead_sum / cell_sum;
        else
            % after adding beads, apply FRET and DIC
            % im5 = im4 .* mask1;

            % im5 = im4 .* mask;

            % mask3, calculate from DIC ch, beads
            % for 0907 data
            % mask3 = (im3 > 55000);
            
            % for 0929 data - 2nd attempt
            l3 = graythresh(im3);
            mask3 = im2bw(im3, l3);
            
            cell_sum = sum(sum(mask1));
            bead_sum = sum(sum(mask1 .* mask3));
            percent(i) = bead_sum / cell_sum;

            % tmp = sum(sum(mask1 .* mask3));
            % tmp = sum(sum(mask .* mask3));

            % mask for whole cell exclude beads
            tmp = sum(sum(mask1 .* (~mask3)));

            if tmp < 500
                % intersection of 2 mask is too small
                % im6 = im5;
                im6 = im5;
            else
                % im6 = im5 .* mask3;
                im6 = im5 .* (~mask3);
            end

        end

        % im6 = im4 .* mask;

        % threshold for selecting 90% pixels in valid region in im6
        if sum(sum(im6 < 5.0 & im6 > 0)) / sum(sum(im6 > 0)) < 0.9
            % th = 5.0 cannot select more than 90% valid pixels
            th = 5.0;
        else
            % more than 90% valid pixels with ratio < 5.0
            thl = 0.0;
            thr = 5.0;
            th  = (thl + thr) / 2.0;
            tmp = sum(sum(im6 < th & im6 > 0)) / sum(sum(im6 > 0));

            while tmp < 0.9
                thl = th;
                th  = (thl + thr) / 2.0;
                tmp = sum(sum(im6 < th & im6 > 0)) / sum(sum(im6 > 0));
            end
        end

        % wca: whole cell image
        % im6: whole cell exclude beads

        % calculated region
        figure(1); imagesc(im4 .* (im4 < th));
        figure(2); imagesc(im6 .* (im6 < th));
        figure(3); imagesc(im5 .* (im5 < th));

        % calculate ratio for this frame, with in the 90% threshold
        % im7 = im6 .* (im6 < th);
        % tmp_ratio = sum(sum(im7)) / sum(sum(im7 > 0));
        % ratio(i) = tmp_ratio;

        % whole cell exclude beads
        im7 = im6 .* (im6 < th);
        tmp_ratio = sum(sum(im7)) / sum(sum(im7 > 0));
        ratio_2(i) = tmp_ratio;

        % whole cell
        im8 = im5 .* (im5 < th);
        wca_ratio = sum(sum(im8)) / sum(sum(im8 > 0));
        ratio_3(i) = wca_ratio;

        % save figure for later validation
        saveas(1, fullfile(outDir, [prefix, '_intensity_2_', num2str(i)]), 'fig');
        saveas(1, fullfile(outDir, [prefix, '_intensity_2_', num2str(i)]), 'jpeg');

        % whole cell exclude beads
        saveas(2, fullfile(outDir, [prefix, '_calculate_2_', num2str(i)]), 'fig');
        saveas(2, fullfile(outDir, [prefix, '_calculate_2_', num2str(i)]), 'jpeg');

        % whole cell average
        saveas(3, fullfile(outDir, [prefix, '_calculate_whole_', num2str(i)]), 'fig');
        saveas(3, fullfile(outDir, [prefix, '_calculate_whole_', num2str(i)]), 'jpeg');

        % close figures
        close(1); close(2); close(3);



    end

    % data.time = [1 : length(ratio)] - time_frame(1);
    % data.ratio  = ratio;
    % data.isgood = global_tag;
    % data.basal  = mean(ratio(1 : time_frame(1)));
    % data.delta  = max(ratio(time_frame(2) : length(ratio))) - data.basal;
    % data.delta_ratio = data.delta / data.basal;

    load([posDir, '/data.mat']);

    data.time_2 = [1 : length(ratio_2)] - time_frame(1);

    data.ratio_2 = ratio_2;
    data.ratio_3 = ratio_3;

    data.delta_2  = max(ratio_2(time_frame(2) : length(ratio_2))) - data.basal;
    data.delta_ratio_2 = data.delta_2 / data.basal;

    data.delta_3  = max(ratio_3(time_frame(2) : length(ratio_3))) - data.basal;
    data.delta_ratio_3 = data.delta_3 / data.basal;

    data.percent = percent;

    save([posDir, '/data.mat'], 'data');
end
