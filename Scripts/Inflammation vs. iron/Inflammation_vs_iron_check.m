%% Inflammation vs. Iron check
% Checks that no excluded sections are included in the input to the inflammation vs. iron analysis or the edge-only/no-edge analyses

% Arguments
%   inflammatory_marker: 'GFAP' or 'CD68'
%   tissue_area: 'all' for inflammation vs. iron analysis; 'edge' for edge-only/no-edge analyses

function [] = Inflammation_vs_iron_check(inflammatory_marker, tissue_area)

clearvars -except inflammatory_marker tissue_area
close all

%% Define directories
directory.input = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel density comparison/%s/Crucial variables', inflammatory_marker);
directory.all_variables = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel density comparison/%s/All variables', inflammatory_marker);
directory.figures = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel density comparison/%s/Figures', inflammatory_marker);
directory.scripts = '/Volumes/Corinne hard drive/cSS project/Scripts/Inflammation vs. iron';

%% Excluded section info
if strcmp(inflammatory_marker, 'GFAP')
    excluded_sections = [23, 1; 23, 7; 17, 5; 5, 4; 5, 7; 8, 4; 14, 7; 21, 4; 5, 1; 15, 1; 15, 5; 17, 7; 18, 7; 21, 1; 21, 5; 24, 1];
elseif strcmp(inflammatory_marker, 'CD68')
    excluded_sections = [23, 1; 23, 7; 5, 4; 5, 7; 8, 4; 14, 7; 21, 4; 2, 1; 2, 7; 15, 5; 20, 4; 20, 5];
end

%% Check data
% Get sizes
[length_excluded, ~] = size(excluded_sections);

% Preallocate
wrongly_included = {};

% Find excluded sections in data
for i = 1:length_excluded
    cd(directory.input)
    brain = excluded_sections(i, 1);
    block = excluded_sections(i, 2);

    crucial_variables_file = sprintf('CAA%d_%d_%s_and_Iron_1pixel_density_comparison_crucial_variables.mat', brain, block, inflammatory_marker);

    %% For sections that should have been excluded
    if isfile(crucial_variables_file)
        % Document
        section_name = sprintf('CAA%d_%d_%s', brain, block, inflammatory_marker);
        wrongly_included = [wrongly_included, section_name];

        % Delete
        recycle('on');
        delete(crucial_variables_file);

        cd(directory.all_variables)
        all_variables_file = sprintf('CAA%d_%d_%s_and_Iron_1pixel_density_comparison_all_variables.mat', brain, block, inflammatory_marker);
        delete(all_variables_file);

        cd(directory.figures)
        figure_file = sprintf('CAA%d_%d_%s_and_Iron_density_figure.png', brain, block, inflammatory_marker);
        delete(figure_file);
    end
end

%% Re-run initial analysis
if isempty(wrongly_included) == 0
    cd(directory.scripts)
    if strcmp(tissue_area, 'all')
      iron_intervals_composite(inflammatory_marker);
    elseif (tissue_area, 'edge')
      run outer_layer_iron_intervals_composite;
    end
end

end
