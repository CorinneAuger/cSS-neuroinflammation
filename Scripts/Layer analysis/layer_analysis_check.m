%% Layer analysis check
% Checks that no excluded sections are included in the input to the inflammation vs. iron analysis or the edge-only/no-edge analyses

function [] = layer_analysis_check(stain)

clearvars -except stain
close all

%% Define directories
directory.input = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/Edge analysis/Individual slides/%s 1000um/Variables', stain);
directory.cortex_figures = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/Edge analysis/Individual slides/%s 1000um/Cortex figures', stain);
directory.line_plots = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/Edge analysis/Individual slides/%s 1000um/Density line plot figures', stain);
directory.scripts = '/Volumes/Corinne hard drive/cSS project/Scripts/Layer analysis';

%% Excluded section info
if strcmp(stain, 'Iron')
    excluded_sections = [5, 4; 5, 7; 8, 4; 14, 7; 21, 4; 23, 1; 23, 7];
elseif strcmp(stain, 'GFAP')
    excluded_sections = [17, 5; 5, 4; 5, 7; 8, 4; 14, 7; 21, 4; 5, 1; 15, 1; 15, 5; 17, 7; 18, 7; 21, 1; 21, 5; 24, 1];
elseif strcmp(stain, 'CD68')
    excluded_sections = [5, 4; 5, 7; 8, 4; 14, 7; 21, 4; 2, 1; 2, 7; 15, 5; 20, 4; 20, 5];
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
    
    data_file = sprintf('CAA%d_%d_%s.mat_edge_analysis_variables.mat', brain, block, stain);
    
    if isfile(data_file)
        % Document
        section_name = sprintf('CAA%d_%d_%s', brain, block, stain);
        wrongly_included = [wrongly_included, section_name];
        
        % Delete
%         recycle('on');
%         delete(data_file);
%         
%         cd(directory.cortex_figures)
%         cortex_figure_file = sprintf('CAA%d_%d_%s_cortex_figure.png', brain, block, stain);
%         delete(cortex_figure_file);
%         
%         cd(directory.line_plots)
%         line_plot_file = sprintf('CAA%d_%d_%s_layer_density_line_plot.png', brain, block, stain);
%         delete(line_plot_file);
    end  
end

%% Re-run composite layer analysis
if isempty(wrongly_included) == 0
    cd(directory.scripts)
    layer_analysis_composite(stain);
end

end
