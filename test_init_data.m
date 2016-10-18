% function data = test_init_data( cell_name )
function data = test_init_data( cell_name )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
root = 'C:\YiwenShi\pengzhi\';
path0 = strcat(root, 'bead_binding_0803/jurkat/experiment/dish1/p7_movie/');
data_file = strcat(path0, 'output/data.mat');
res = load(data_file);
data = res.data;

switch cell_name,
    %%% analysis on 09/14/2016
    case '0824_f1_baz1_dish1_p1',
        data.cell_name = cell_name;
        data.between_frame = [8;9];
        data.path = strcat(root, 'C:\YiwenShi\pengzhi\bead_binding_0907\0824\fl_baz1\run_it_individually/p1/');
        data.output_path = strcat(data.path, 'output/');
        data.first_file = strcat(data.path, '1_w2FRET-WPZ-10P_s1_t1.TIF');
        data.brightness_factor = 1.0;
        data.image_index = (1:45);
        data.intensity_bound = [1 5000];
    
    %%% analysis on 09/07/2016
    case 'hela0716_baz1_dish11',
        data.cell_name = cell_name;
        data.between_frame = [8;9];
        data.path = strcat(root, 'bead_binding_0907/0716/itimless_baz1/dish1/p1/');
        data.output_path = strcat(data.path, 'output/');
        data.first_file = strcat(data.path, '1_w2FRET-WPZ-1P_s1_t1.TIF');
        data.brightness_factor = 1.0;
        data.image_index = (1:81);
        data.intensity_bound = [1 5000];
    case 'hela0716_baz1_dish12',
        data.cell_name = cell_name;
        data.between_frame = [8;9];
        data.path = strcat(root, 'bead_binding_0907/0716/itimless_baz1/dish1/p2/');
        data.output_path = strcat(data.path, 'output/');
        data.first_file = strcat(data.path, '1_w2FRET-WPZ-1P_s2_t1.TIF');
        data.brightness_factor = 1.0;
        data.image_index = (1:81);
        data.intensity_bound = [1 5000];
    case 'hela0716_baz1_dish13',
        data.cell_name = cell_name;
        data.between_frame = [8;9];
        data.path = strcat(root, 'bead_binding_0907/0716/itimless_baz1/dish1/p3/');
        data.output_path = strcat(data.path, 'output/');
        data.first_file = strcat(data.path, '1_w2FRET-WPZ-1P_s3_t1.TIF');
        data.brightness_factor = 1.0;
        data.image_index = (1:81);
        data.intensity_bound = [1 5000];
    case 'hela0716_baz1_dish14',
        data.cell_name = cell_name;
        data.between_frame = [8;9];
        data.path = strcat(root, 'bead_binding_0907/0716/itimless_baz1/dish1/p4/');
        data.output_path = strcat(data.path, 'output/');
        data.first_file = strcat(data.path, '1_w2FRET-WPZ-1P_s4_t1.TIF');
        data.brightness_factor = 1.0;
        data.image_index = (1:81);
        data.intensity_bound = [1 5000];
        
        %%% analysis on 08/03/2016
    case 'jurkat0803_p7',
        data.cell_name = cell_name;
        data.between_frame = [18; 19]; 
        data.path = strcat(root, 'bead_binding_0803/jurkat/experiment/dish1/p7_movie/');
        data.output_path = strcat(data.path, 'output/');
        data.first_file = strcat(data.path, '1_w2FRET-WPZ_s7_t1.TIF');
    case 'jurkat0803_p3',
        % not good, signal not stable before adding beads
        data.cell_name = cell_name;
        data.between_frame = [18; 19];
        data.path = strcat(root, 'bead_binding_0803/jurkat/experiment/dish1/p3/');
        data.output_path = strcat(data.path, 'output/');
        data.first_file = strcat(data.path, '1_w2FRET-WPZ_s3_t1.TIF');
        data.brightness_factor = 0.3;
        data.image_index = [1:16, 18:40];
     case 'jurkat0803_p6',
         % No cell after frame 19. 
        data.cell_name = cell_name;
        data.between_frame = [18; 19];
        data.path = strcat(root, 'bead_binding_0803/jurkat/experiment/dish1/p6/');
        data.output_path = strcat(data.path, 'output/');
        data.first_file = strcat(data.path, '1_w2FRET-WPZ_s6_t1.TIF');
     case 'jurkat0803_p9',
        data.cell_name = cell_name;
        data.between_frame = [18; 19];
        data.path = strcat(root, 'bead_binding_0803/jurkat/experiment/dish1/p9/');
        data.output_path = strcat(data.path, 'output/');
        data.first_file = strcat(data.path, '1_w2FRET-WPZ_s9_t1.TIF');
        data.brightness_factor = 0.5;
        data.image_index = [10:25, 27:44];
    case 'hela0803_p3',
        data.cell_name = cell_name;
        data.between_frame = [6; 7];
        data.path = strcat(root, 'bead_binding_0803/hela/experiment/dish2/p3/');
        data.output_path = strcat(data.path, 'output/');
        data.first_file = strcat(data.path, '1_w2FRET-WPZ-1P_s3_t1.TIF');
        data.brightness_factor = 1.0;
        data.image_index = (1:73);
        data.intensity_bound = [1 5000];
    case 'hela0803_p8',
        data.cell_name = cell_name;
        data.between_frame = [6; 7];
        data.path = strcat(root, 'bead_binding_0803/hela/experiment/dish2/p8/');
        data.output_path = strcat(data.path, 'output/');
        data.first_file = strcat(data.path, '1_w2FRET-WPZ-1P_s8_t1.TIF');
        data.brightness_factor = 1.0;
        data.image_index = (1:73);
        data.intensity_bound = [1 5000];
    case 'hela0803_p9',
        data.cell_name = cell_name;
        data.between_frame = [6; 7];
        data.path = strcat(root, 'bead_binding_0803/hela/experiment/dish2/p9/');
        data.output_path = strcat(data.path, 'output/');
        data.first_file = strcat(data.path, '1_w2FRET-WPZ-1P_s9_t1.TIF');
        data.brightness_factor = 1.0;
        data.image_index = (1:73);
        data.intensity_bound = [1 5000];
     case 'hela0803_control_dish13',
        data.cell_name = cell_name;
        data.between_frame = [6; 7];
        data.path = strcat(root, 'bead_binding_0803/hela/control/dish1/p3/');
        data.output_path = strcat(data.path, 'output/');
        data.first_file = strcat(data.path, '1_w2FRET-WPZ-1P_s3_t1.TIF');
        data.brightness_factor = 1.0;
        data.image_index = (1:67);
        data.intensity_bound = [1 5000];
     case 'hela0803_control_dish16',
        data.cell_name = cell_name;
        data.between_frame = [6; 7];
        data.path = strcat(root, 'bead_binding_0803/hela/control/dish1/p6/');
        data.output_path = strcat(data.path, 'output/');
        data.first_file = strcat(data.path, '1_w2FRET-WPZ-1P_s6_t1.TIF');
        data.brightness_factor = 1.0;
        data.image_index = (1:67);
        data.intensity_bound = [1 5000];
     case 'hela0803_control_dish17',
        data.cell_name = cell_name;
        data.between_frame = [6; 7];
        data.path = strcat(root, 'bead_binding_0803/hela/control/dish1/p7/');
        data.output_path = strcat(data.path, 'output/');
        data.first_file = strcat(data.path, '1_w2FRET-WPZ-1P_s7_t1.TIF');
        data.brightness_factor = 1.0;
        data.image_index = (1:67);
        data.intensity_bound = [1 5000];
     case 'hela0803_control_dish25',
        data.cell_name = cell_name;
        data.between_frame = [5; 6];
        data.path = strcat(root, 'bead_binding_0803/hela/control/dish2/p5/');
        data.output_path = strcat(data.path, 'output/');
        data.first_file = strcat(data.path, '1_w2FRET-WPZ-1P_s5_t1.TIF');
        data.brightness_factor = 1.0;
        data.image_index = (1:61);
        data.intensity_bound = [1 5000];

end;
[~, data.prefix, ~] = fileparts(data.first_file);

end

