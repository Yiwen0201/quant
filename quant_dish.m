function quant_dish(prefix, time_frame, idx_pattern, idx_postfix, dishDir)

    % check input info
    if nargin < 1
        prompt = {'Prefix of this dish: ', 'Enter frame1: ', 'Enter frame2: ',...
                  'Define idx_pattern: ', 'Define idx_postfix: '};    
        dlg_title = 'Input';    
        num_lines = 1;
        defaultans = {'date_info_dish','8','9', 't\d', '.TIF'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);  

        prefix = answer{1};

        frame1 = str2num(answer{2});
        frame2 = str2num(answer{3});
        time_frame = [frame1; frame2];

        idx_pattern = answer{4};
        idx_postfix = answer{5};

        dishDir = uigetdir;
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

        dishDir = uigetdir;
    elseif nargin == 2
        prompt = {'Define idx_pattern: ', 'Define idx_postfix: '};    
        dlg_title = 'Input';    
        num_lines = 1;
        defaultans = {'t\d', '.TIF'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);  

        idx_pattern = answer{1};
        idx_postfix = answer{2};

        dishDir = uigetdir;
    elseif nargin == 3
        prompt = {'Define idx_postfix: '};    
        dlg_title = 'Input';    
        num_lines = 1;
        defaultans = {'.TIF'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);  

        idx_postfix = answer{1};

        dishDir = uigetdir;
    elseif nargin == 4
        dishDir = uigetdir;
    elseif nargin > 5
        error('Invalid input argument, please read the code and input correctly! \n');
    end

    % get postition info
    pos_file = dir(fullfile(dishDir, 'p*'));

    % delete non-folder files in pos_file
    p_idx = 1;
    while( p_idx <= length(pos_file))
        if(pos_file(p_idx).isdir)
            p_idx = p_idx+1;
        else
            pos_file(p_idx) = [];
        end
    end    

    figure(10);
    % outputFile = [dishDir, '\', prefix, '_output_data.xlsx'];
    % col_title = [{'time_idx'}, {'ratio'}];

    for i = 1 : length(pos_file)
        pos_prefix = [prefix, '_', pos_file(i).name];
        fprintf([pos_prefix, '\n']);
        posDir = fullfile(dishDir, pos_file(i).name);
        data = quant_pos(pos_prefix, time_frame, idx_pattern, idx_postfix, posDir);

        data.dishDir = dishDir;
        data.posInfo = pos_prefix;
        data.posName = pos_file(i).name;
        % data.time    = time;
        % data.ratio   = ratio;
        % data.isgood  = global_tag;
        % data.basal   = basal;
        % data.delta   = delta;
        % data.delta_ratio = delta_ratio;

        save([posDir, '/data.mat'], 'data');
        
        plot(data.time, data.ratio);
        hold on
        
        % write data into xlsx file
        % xlswrite(outputFile, col_title, pos_file(i).name, 'A1:B1');
        % xlswrite(outputFile, time, pos_file(i).name, 'A2');
        % xlswrite(outputFile, ratio, pos_file(i).name, 'B2');

        % write data into txt file
        txtFileName = [dishDir, '/', pos_file(i).name, '.txt'];
        M(1, :) = data.time;
        M(2, :) = data.ratio;
        dlmwrite(txtFileName, M, 'delimiter', '\t', 'precision', 4);

        clear data M;

    end
    
    saveas(10, fullfile(dishDir, [prefix, '_intensity']), 'jpeg');
    saveas(10, fullfile(dishDir, [prefix, '_intensity']), 'fig');    
    
end
