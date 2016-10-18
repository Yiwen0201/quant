function batch_dish_0926(myDir, prefix_in)

    if nargin < 1
        myDir = 'C:\YiwenShi\pengzhi\bead_binding_0907\0716\itimless_baz1';
        prefix_in = '0716_baz1_dish';
    end
    
    infoFile = dir([myDir, '\*.txt']);
    infoFileID = fopen([myDir, '\', infoFile.name]);

    tline = fgets(infoFileID);
    i = 1;
    while ischar(tline)
        keyIndex = strfind(tline,'#');
        dish_frame{i}(1) = sscanf(tline(keyIndex(1) + length('#'):end), '%g', 1);
        dish_frame{i}(2) = sscanf(tline(keyIndex(2) + length('#'):end), '%g', 1);
        tline = fgets(infoFileID);
        i = i+1;
    end    

    fclose(infoFileID);

    dishFolders = dir(fullfile(myDir, 'dish*'));

    idx_pattern = 't\d';
    idx_postfix = '.TIF';

    for i = 1 : length(dish_frame)
        dishDir = [myDir, '\', dishFolders(i).name];
        prefix = [prefix_in, num2str(i)];
        time_frame = [dish_frame{i}(1); dish_frame{i}(2)];
        quant_dish(prefix, time_frame, idx_pattern, idx_postfix, dishDir);
        close all;
    end

end
