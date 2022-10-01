function [old_analyis_quartiles, proper_quartiles] = choose_iron_intervals(inflammatory_marker)

%% Input directories
directory.crucial_variables = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel density comparison/%s/Crucial variables', inflammatory_marker);

%% Make struct of all variables file names
cd(directory.crucial_variables)
variables_files = dir('**/*.mat');
number_of_files = length(variables_files);

%% Preallocate
all_pixels = NaN((number_of_files * 55 * 55), 1);
maximum = 0;
minimum = 0;
all_pixels_starting_point = 1;

for i = 1:number_of_files
    %% Load iron heat map
    file_name = variables_files(i).name;
    load(file_name, 'stat_iron');
    
    %% Update maximum
    section_maximum = max(max(stat_iron));

    if  section_maximum > maximum
        maximum = section_maximum;
    end
    
    %% Put iron pixel values in giant matrix
    [stat_x, stat_y] = size(stat_iron);
    section_number_of_pixels = stat_x * stat_y;
    
    reshaped_stat_iron = reshape(stat_iron(section_number_of_pixels, 1);
    all_pixels(all_pixels_starting_point : (all_pixels_starting_point + section_number_of_pixels), 1) = reshaped_stat_iron;
    
    all_pixels_starting_point = all_pixels_starting_point + section_number_of_pixels + 1;
end

%% Get proper quartiles
proper_quartiles = quantile(all_pixels, 4);

%% Get quartiles based on old analysis (%s instead of objects)
% Cut-offs: 5 objects for low, 15 for medium, 25 for high.
% In the old analysis, the cut-offs are akin to 5 objects for low, 14 for medium, 27 for high.

old_analysis_quartiles = [5, 15, 25];

end