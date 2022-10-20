%% Layer analysis composite
% Makes the final graphs for the paper.
% One stain per graph.

clear

%% User input
stain = 'CD68';

%% Input directories
directory.input = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Saved data/Edge analysis/Final edge composite data';
directory.save = '/Users/corinneauger/Desktop/R graphs';

%% Import data
cd(directory.input)
load('Variables_all_brains_1000um_Iron_edge_analysis')
close all

%% Set up color palettes
if strcmp(stain, 'Iron')
    color_palette = [0.79, 0.25, 0.19];
    dark_color_palette = [0, 0, 0];
elseif strcmp(stain, 'GFAP')
    color_palette = [0.3, 0.74, 0.87];
    dark_color_palette = [0, 0, 0];
elseif strcmp(stain, 'CD68')
    color_palette = [0.63, 0.83, 0.55];
    dark_color_palette = [0, 0, 0];
end

%% Get percentiles
percentiles_to_be_cleared = prctile(layer_densities_all_brains, [25, 50, 75]);
if layer_width == 500
    number_of_layers = 40 - numel(find(isnan(percentiles_to_be_cleared(2,:))));
elseif layer_width == 1000
    number_of_layers = 20 - numel(find(isnan(percentiles_to_be_cleared(2,:))));
end
clear percentiles_to_be_cleared

percentiles = prctile(layer_densities_all_brains(:, 1:5), [25, 50, 75]);

%% Make figure with points
for column_number = 1:5
    temp_column = column_number * ones(26,1);   
    scatter(temp_column, layer_densities_all_brains(:,column_number), 200, '.', 'MarkerEdgeColor', color_palette);   
    hold on
end

%% Add median line, 25th and 75th percentiles
x = 1:5;
fill([x(1,:), fliplr(x(1,:))], [percentiles(1,:), fliplr(percentiles(3,:))], color_palette, 'FaceAlpha', 0.1, 'EdgeColor', 'None');
plot(percentiles(2, 1:5), 'LineStyle', '-', 'LineWidth', 1.5, 'Color', dark_color_palette);
%plot(percentiles(2,:), '-b');

%% Format plot
% X ticks
xlim([1 5]); 
xticks([1 5]);
labels = {'Outermost', 'Innermost'};
xticklabels(labels)

a = get(gca,'XTickLabel');
set(gca, 'XTickLabel', a, 'fontsize', 11, 'fontweight', 'bold')

% Axis labels
xlabel('1000um layer', 'FontSize', 20, 'FontWeight', 'bold');
ylabel('Mean density (%)', 'FontSize', 20, 'FontWeight', 'bold');

% Title
title(stain, 'FontSize', 25)

% Border
box on 
ax = gca;
ax.LineWidth = 1;

%% Save
cd(directory.save)
saveas(gcf, sprintf('%s_layer_graph.png', stain))
