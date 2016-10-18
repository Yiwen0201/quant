function plot_batch_0927(dateDir)

    if nargin < 1
        dateDir = uigetdir;
    end

    % read all the method folders
    method_file = dir(fullfile(dateDir, '*baz1*'));
    idx = 1;
    while(idx <= length(method_file))
        if(method_file(idx).isdir)
            idx = idx + 1;
        else
            method_file(idx) = [];
        end
    end

    for i = 1 : length(method_file)

        methodDir = fullfile(dateDir, method_file(i).name);

        % read all the dish folders
        dish_file = dir(fullfile(methodDir, 'dish*'));
        idx = 1;
        while(idx <= length(dish_file))
            if(dish_file(idx).isdir)
                idx = idx + 1;
            else
                dish_file(idx) = [];
            end
        end

        for j = 1 : length(dish_file)
            dishDir = fullfile(methodDir, dish_file(j).name);

            plot_dish_0927(dishDir);
            
        end
    end

end