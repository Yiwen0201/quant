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

    maskDir = fullfile(posDir, 'output');
    tmp_file = dir(fullfile(maskDir, '*-*'));
    for i = 1 : length(tmp_file)
        if(tmp_file(i).isdir)
            maskDir = [maskDir, '\', tmp_file(i).name];
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

    for i = 1 : length(mask_file)

        % get idx for this time frame
        idx1 = regexp(mask_file(i).name, idx_pattern);
        idx2 = regexp(mask_file(i).name, '.tiff');

        idx = mask_file(i).name(idx1+1 : idx2-1);
        idx = str2num(idx);

        mask_map(idx) = i;
    end

    % If the index is not continuous
    % idx_map = idx_map(idx_map ~= 0);

    % this is for solving some DIC image becomes too bright, and result in mask3 too big
    % if current dish has more than one pos have DIC issues (too bright) define it as bad
    % eg: 0716_baz1_dish2_p6
    global_tag = true;

    for i = 1 : length(idx_map)

        % index of files in ch1/2/3_file
        cur_idx = idx_map(i);
        mask_idx = mask_map(i);
        % If the index is not continuous
        if cur_idx == 0
            continue;
        end

        % if current frame is a good one
        local_tag = true;

        % read ch1, ch2, ch3 image
        im1 = imread(fullfile(posDir, ch1_file(cur_idx).name));
        im2 = imread(fullfile(posDir, ch2_file(cur_idx).name));
        im3 = imread(fullfile(posDir, ch3_file(cur_idx).name));

        % mask cell
        ratio_image = imread(fullfile(maskDir, mask_file(mask_idx).name));
        ratio_gray = rgb2gray(ratio_image);
        mask = bwareaopen(ratio_gray, 100);

        % % mask1, calculate from FRET ch, cell
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

        % ratio for whole cell
        im5 = im4 .* mask;

        if i <= time_frame(1)
            % before adding beads, only apply FRET mask
            % im6 = im4 .* mask1;
            im6 = im5;
            im_non = im5;

            % calculate beads region percentage
            cell_sum = sum(sum(mask));
            bead_sum = 0;
            percent(i) = bead_sum / cell_sum;

        else
            % after adding beads, apply FRET and DIC
            % im5 = im4 .* mask1;

            % beads mask
            cell_region = (im1_sub .* mask);
            intensities = cell_region(cell_region > 0);
            idx = kmeans(intensities, 2);
            c1 = intensities(idx == 1);
            c2 = intensities(idx == 2);
            thres = max(min(min(c1)), min(min(c2)));

            % beads mask, cluster with highest intensity in im1_sub, FRET
            mask3 = (cell_region > thres);

            % non beads region mask
            mask4 = (cell_region <= thres);



            % mask3, calculate from DIC ch, beads
            % for 0907 data
            % mask3 = (im3 > 55000);
            % for 0929 data - 1st attempt
            % mask3 = (im3 > 40000);
            % for 0929 data - 2nd attempt
            % l3 = graythresh(im3);
            % mask3 = im2bw(im3, l3);

            % tmp = sum(sum(mask1 .* mask3));
            tmp = sum(sum(mask .* mask3));
            tmp2 = sum(sum(mask .* mask4));

            if tmp < 500 || tmp2 < 500
                % intersection of 2 mask is too small, either for beads or exclude beads
                % then the calculation will be on whole cell region
                im6 = im5;
                im_non = im5;

                % calculate beads region percentage
                cell_sum = sum(sum(mask));
                bead_sum = 0;
                percent(i) = bead_sum / cell_sum;

            else
                % separate beads region or exclude beads region
                im6 = im5 .* mask3;
                im_non = im5 .* mask4;

                % beads region percentage
                cell_sum = sum(sum(mask));
                bead_sum = sum(sum(mask .* mask3));
                percent(i) = bead_sum / cell_sum;
            end

        end

        % im6 = im4 .* mask;

        % threshold for selecting 90% pixels in valid region in im6
        % if sum(sum(im6 < 5.0 & im6 > 0)) / sum(sum(im6 > 0)) < 0.9
        %     % th = 5.0 cannot select more than 90% valid pixels
        %     th = 5.0;
        % else
        %     % more than 90% valid pixels with ratio < 5.0
        %     thl = 0.0;
        %     thr = 5.0;
        %     th  = (thl + thr) / 2.0;
        %     tmp = sum(sum(im6 < th & im6 > 0)) / sum(sum(im6 > 0));
        %
        %     while tmp < 0.9
        %         thl = th;
        %         th  = (thl + thr) / 2.0;
        %         tmp = sum(sum(im6 < th & im6 > 0)) / sum(sum(im6 > 0));
        %     end
        % end

        % for simplicity, just set threshold = 5
        th = 5;

        % calculated region
        % entire ratio image
        figure(1); imagesc(im4 .* (im4 < th));
        caxis([0.8, 2])
        colormap(jet)

        % beads region ratio
        figure(2); imagesc(im6 .* (im6 < th));
        caxis([0.8, 2])
        colormap(jet)

        % exclude beads region ratio
        figure(3); imagesc(im_non .* (im_non < th));
        caxis([0.8, 2])
        colormap(jet)

        % whole cell region ratio
        figure(4); imagesc(im5 .* (im5 < th));
        caxis([0.8, 2])
        colormap(jet)

        % calculate beads ratio for this frame
        beads = im6 .* (im6 < th);
        tmp_ratio = sum(sum(beads)) / sum(sum(beads > 0));
        ratio(i) = tmp_ratio;

        % calculate beads ratio for this frame
        no_beads = im_non .* (im_non < th);
        tmp_ratio = sum(sum(no_beads)) / sum(sum(no_beads > 0));
        ratio_2(i) = tmp_ratio;

        % calculate beads ratio for this frame
        whole_cell = im5 .* (im5 < th);
        tmp_ratio = sum(sum(whole_cell)) / sum(sum(whole_cell > 0));
        ratio_3(i) = tmp_ratio;

        % save figure for later validation
        % entire ratio image
        saveas(1, fullfile(outDir, [prefix, '_ratio_', num2str(i)]), 'fig');
        saveas(1, fullfile(outDir, [prefix, '_ratio_', num2str(i)]), 'jpeg');

        % beads ratio image
        saveas(2, fullfile(outDir, [prefix, '_beads_ratio_', num2str(i)]), 'fig');
        saveas(2, fullfile(outDir, [prefix, '_beads_ratio_', num2str(i)]), 'jpeg');

        % exclude beads ratio image
        saveas(3, fullfile(outDir, [prefix, '_no_beads_ratio_', num2str(i)]), 'fig');
        saveas(3, fullfile(outDir, [prefix, '_no_beads_ratio_', num2str(i)]), 'jpeg');

        % whole cell ratio image
        saveas(4, fullfile(outDir, [prefix, '_cell_ratio_', num2str(i)]), 'fig');
        saveas(4, fullfile(outDir, [prefix, '_cell_ratio_', num2str(i)]), 'jpeg');

        % close figures
        close(1); close(2); close(3); close(4);

    end

    % ratio: beads region, ratio_2: no beads region, ratio_3: whole cell
    data.time = [1 : length(ratio)] - time_frame(1);

    % delete 0s
    valid_ratio = (ratio ~= 0);
    data.time = data.time(valid_ratio);

    ratio = ratio(valid_ratio);
    ratio_2 = ratio_2(valid_ratio);
    ratio_3 = ratio_3(valid_ratio);
    percent = percent(valid_ratio);

    data.ratio  = ratio;
    data.ratio_2  = ratio_2;
    data.ratio_3  = ratio_3;

    % beads region
    data.basal  = mean(ratio(1 : time_frame(1)));
    data.delta  = max(ratio(time_frame(2) : length(ratio))) - data.basal;
    data.delta_ratio = data.delta / data.basal;

    % no beads region
    data.basal_2  = mean(ratio_2(1 : time_frame(1)));
    data.delta_2  = max(ratio_2(time_frame(2) : length(ratio_2))) - data.basal_2;
    data.delta_ratio_2 = data.delta_2 / data.basal_2;

    % whole cell
    data.basal_3  = mean(ratio_3(1 : time_frame(1)));
    data.delta_3  = max(ratio_3(time_frame(2) : length(ratio_3))) - data.basal_3;
    data.delta_ratio_3 = data.delta_3 / data.basal_3;

    data.percent = percent;
    data.info = prefix;
    data.path = posDir;

    save([posDir, '/data.mat'], 'data');
end
