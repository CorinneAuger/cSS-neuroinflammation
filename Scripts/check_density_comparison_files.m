%% Check density comparison files
% Missing save and documentation components

%% Input directories
directory.density_comparison = '/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel density comparison';
directory.ext_hd_scripts = '/Volumes/Corinne hard drive/cSS project/Scripts';

%% Loop through files
cd(directory.density_comparison)
figures = dir('**/*.png');

number_of_figures = length(figures);

for i = 1 : number_of_figures
    
    %% Display test figure and ask if satisfied
    test_figure_name = convertCharsToStrings(figures(i).name);
    folder_name = figures(i).folder;
    
    cd(folder_name)
    test_figure = imread(test_figure_name); 
    imshow(test_figure) 
    
    satisfied = input('Satisfied? If no, reply 0; if yes, reply 1');
    
    if satisfied == 0
        %% Load Variables 
        all_variables_folder = strrep(folder_name, 'Figures', 'All variables');
        all_variables_name = strrep(test_figure_name, 'density_figure.png', '1pixel_density_comparison_all_variables.mat');
        
        cd(all_variables_folder)
        load(all_variables_name)
        
        %% Use opposite primary mask
        if primary_mask == inflammation_tissue_mask
            primary_mask = iron_tissue_mask;
        else
            primary_mask = inflammation_tissue_mask;
        end
        
        %% Generate new figure and ask if satisfied
        cd(directory.ext_hd_scripts)
        run(end_of_one_pixel_density_comparison);
        
        satisfied_2 = input('Satisfied? If no, reply 0; if yes, reply 1');
        
        if satisfied == 0
        end
        
        clearvars -except directory figures number_of_figures i
    end
    
    close all
end