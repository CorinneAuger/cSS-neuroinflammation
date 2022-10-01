%% Ring weight minima comparison
% Compares how well predicted heat maps (using 4 columns) fit actual heat maps between GFAP and CD68.
% Have to run flexible_columns_ring_weight_analysis with 4 columns first.

close all
clear

tailed = 1;

%% Enter directories
directory.GFAP_input = '/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel ring weight analysis/GFAP (1-tailed)/4 column/Composite';
directory.CD68_input = '/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel ring weight analysis/CD68 (1-tailed)/4 column/Composite';
directory.scripts = '/Volumes/Corinne hard drive/cSS project/Scripts';
directory.save = '/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel ring weight analysis/Minima comparison';

%% Load files
cd(directory.GFAP_input)
load('GFAP_and_Iron_1pixel_ring_weight_analysis_variables.mat', 'minima_all_blocks')
GFAP_minima = squeeze(minima_all_blocks(1, :, :));
clear minima_all_blocks
GFAP_minima(:, 27:104) = [];

cd(directory.CD68_input)
load('CD68_and_Iron_1pixel_ring_weight_analysis_variables.mat', 'minima_all_blocks')
CD68_minima = squeeze(minima_all_blocks(1, :, :));
clear minima_all_blocks
CD68_minima(:, 27:104) = [];

%% Calculate effect size
reshaped_GFAP = reshape(GFAP_minima, [104,1]);
reshaped_CD68 = reshape(CD68_minima, [104,1]);

reshaped_GFAP(any(isnan(reshaped_GFAP), 2), :) = [];
reshaped_CD68(any(isnan(reshaped_CD68), 2), :) = [];

%cd(directory.scripts)
%Cohens_d = computeCohen_d(reshaped_CD68, reshaped_GFAP, 'independent');

%% Make boxplot
GFAP_column = reshape(GFAP_minima, [104, 1]);
CD68_column = reshape(CD68_minima, [104, 1]);
boxplot([GFAP_column, CD68_column])

xticklabels({'GFAP', 'CD68'});
ylabel('Difference (number of objects)/total inflammation objects', 'FontSize', 16)
title({'Difference between predicted and actual inflammation' 'heat maps for best weight combination'}, 'FontSize', 16);

%% Make axis labels bigger
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',18)
b = get(gca,'YTickLabel');
set(gca,'YTickLabel',b,'fontsize',14)

%% Add points
hold on
scatter(1 * ones(104,1), GFAP_column, 'black', '.');

hold on
scatter(2 * ones(104,1), CD68_column, 'black', '.');

%% Save
cd(directory.save)
clearvars -except GFAP_minima CD68_minima Cohens_d
save('final_1-tailed_minima_matrices.mat')
saveas(gcf, 'ring_weight_minima_comparison_1-tailed.png')
