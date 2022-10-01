%% Composite flexible columns ring weight analysis
% Collects the data for the ring weight analysis with 0-4 rings and puts it together in a graph and matrix.

close all
clear

%% Input directories
directory.one_column_input = '/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel ring weight analysis/GFAP (1-tailed)/1 column/Composite';
directory.two_column_input = '/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel ring weight analysis/GFAP (1-tailed)/2 column/Composite';
directory.three_column_input = '/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel ring weight analysis/GFAP (1-tailed)/3 column/Composite';
directory.four_column_input = '/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel ring weight analysis/GFAP (1-tailed)/4 column/Composite';
directory.save = '/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel ring weight analysis/GFAP (1-tailed)/Columns compared';

%% Load minima files
% One column
cd(directory.one_column_input)
load('GFAP_and_Iron_1pixel_1_column_ring_weight_analysis_variables.mat', 'minima_all_blocks')

matrix_one_column_minima_by_section = squeeze(minima_all_blocks(1, :, :));
one_column_minima_by_brain = nanmean(matrix_one_column_minima_by_section);

one_column_minima_by_section = reshape(matrix_one_column_minima_by_section, [104, 1]);
one_column_mean = nanmean(one_column_minima_by_section);

clear minima_all_blocks

% Two column
cd(directory.two_column_input)
load('GFAP_and_Iron_1pixel_2_column_ring_weight_analysis_variables.mat', 'minima_all_blocks')

matrix_two_column_minima_by_section = squeeze(minima_all_blocks(1, :, :));
two_column_minima_by_brain = nanmean(matrix_two_column_minima_by_section);

two_column_minima_by_section = reshape(matrix_two_column_minima_by_section, [104, 1]);
two_column_mean = nanmean(two_column_minima_by_section);

clear minima_all_blocks

% Three column
cd(directory.three_column_input)
load('GFAP_and_Iron_1pixel_3_column_ring_weight_analysis_variables.mat', 'minima_all_blocks')

matrix_three_column_minima_by_section = squeeze(minima_all_blocks(1, :, :));
three_column_minima_by_brain = nanmean(matrix_three_column_minima_by_section);

three_column_minima_by_section = reshape(matrix_three_column_minima_by_section, [104, 1]);
three_column_mean = nanmean(three_column_minima_by_section);

clear minima_all_blocks

% Four column
cd(directory.four_column_input)
load('GFAP_and_Iron_1pixel_ring_weight_analysis_variables.mat', 'minima_all_blocks')
minima_all_blocks = minima_all_blocks(:, :, 1:26);

matrix_four_column_minima_by_section = squeeze(minima_all_blocks(1, :, :));
four_column_minima_by_brain = nanmean(matrix_four_column_minima_by_section);

four_column_minima_by_section = reshape(matrix_four_column_minima_by_section, [104, 1]);
four_column_mean = nanmean(four_column_minima_by_section);

clear minima_all_blocks

%% Make and save means matrix
means = [one_column_mean, two_column_mean, three_column_mean, four_column_mean];
clear one_column_mean two_column_mean three_column_mean four_column_mean

cd(directory.save)
save('mean_minimum_by_number_of_columns', 'means')

%% Make and save boxplots
% Sections
sections_boxplot_matrix = [one_column_minima_by_section, two_column_minima_by_section, three_column_minima_by_section, four_column_minima_by_section];
boxplot(sections_boxplot_matrix)
clear one_column_minima_by_section two_column_minima_by_section three_column_minima_by_section four_column_minima_by_section

save('column_comparison_matrix_by_section', 'sections_boxplot_matrix')
saveas(gcf, 'column_comparison_figure_by_section')
close

% Brains
brains_boxplot_matrix = [one_column_minima_by_brain', two_column_minima_by_brain', three_column_minima_by_brain', four_column_minima_by_brain'];
boxplot(brains_boxplot_matrix)
clear one_column_minima_by_brain two_column_minima_by_brain three_column_minima_by_brain four_column_minima_by_brain

save('column_comparison_matrix_by_brain', 'brains_boxplot_matrix')
saveas(gcf, 'column_comparison_figure_by_brain')
