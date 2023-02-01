function [ich_brains_and_blocks, excluded_brains_and_blocks] = ID_ICH_sections(inflammatory_marker)
% Get names of sections with ICH from spreadsheets

%% Define directories
directory.image_sizes_spreadsheets = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Image sizes spreadsheets';

%% Import spreadsheet
cd(directory.image_sizes_spreadsheets)

[~, slide_names] = xlsread(sprintf('Aiforia_image_sizes_%s.xlsx', inflammatory_marker), 'A:A');
slide_names(1) = [];

exclusion_matrix = xlsread(sprintf('Aiforia_image_sizes_%s.xlsx', inflammatory_marker), 'E:E');

%% Identify ICH sections
ich_sections = {};
excluded_sections = {};

for i = 1:length(exclusion_matrix)
    if exclusion_matrix(i) == 2
        ich_sections = [ich_sections; slide_names(i)];
    elseif exclusion_matrix(i) == 1
        excluded_sections = [excluded_sections; slide_names(i)];
    end
end

%% Make matrix of brains and blocks for ICH sections
ich_brains_and_blocks = NaN(length(ich_sections), 2);

for i = 1:length(ich_sections)
     brain_block_cell = textscan(ich_sections{i}, 'CAA%d_%d');
     brain_block_string = sprintf('%f %f', brain_block_cell{:});
     ich_brains_and_blocks(i, :) = sscanf(brain_block_string, '%f %f');   
end

clear brain_block_cell brain_block_string

%% Make matrix of brains and blocks for excluded sections
excluded_brains_and_blocks = NaN(length(excluded_sections), 2);

for i = 1:length(excluded_sections)
     brain_block_cell = textscan(excluded_sections{i}, 'CAA%d_%d');
     brain_block_string = sprintf('%f %f', brain_block_cell{:});
     excluded_brains_and_blocks(i, :) = sscanf(brain_block_string, '%f %f');   
end

end