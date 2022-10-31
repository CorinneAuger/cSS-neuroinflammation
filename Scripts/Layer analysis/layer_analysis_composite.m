%% Layer analysis composite
% Makes the final graphs for the paper.
% One stain per graph.
% Used in end_of_layer_analysis. Can also be used independently.

function [] = layer_analysis_composite(stain)

%% Input directories
directory.input = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Saved data/Edge analysis/Final edge composite data';
directory.scripts = '/Users/corinneauger/Desktop/R graphs';
directory.save = '/Users/corinneauger/Desktop/R graphs';

%% Import data
cd(directory.input)
load(sprintf('Variables_all_brains_1000um_%s_edge_analysis', stain));
close all

%% Set up color palettes
% Get dark color palette using color_darken.py
if strcmp(stain, 'Iron')
    color_palette = [0.61, 0.70, 0.82];
    dark_color_palette = [0.23, 0.34, 0.49];
elseif strcmp(stain, 'GFAP')
    color_palette = [0.90, 0.58, 0.54];
    dark_color_palette = [0.59, 0.18, 0.13];
elseif strcmp(stain, 'CD68')
    color_palette = [0.91, 0.65, 0.38];
    dark_color_palette = [0.56, 0.33, 0.08];
end

%% Get percentiles
percentiles = prctile(layer_densities_all_brains(:, 1:5), [25, 50, 75]);

%% Make figure with points
for column_number = 1:5
    temp_column = column_number * ones(26,1);
    scatter(temp_column, layer_densities_all_brains(:,column_number), 50, 'filled', 'MarkerEdgeColor', dark_color_palette, 'MarkerFaceColor', color_palette);
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
set(gca, 'XTickLabel', a, 'fontsize', 15, 'fontweight', 'bold')

% Y ticks
b = get(gca,'YTickLabel');
set(gca, 'YTickLabel', b, 'fontsize', 15, 'fontweight', 'bold')

% Axis labels
xlabel('1000 µm layer', 'FontSize', 20, 'FontWeight', 'bold');
ylabel('Mean density (%)', 'FontSize', 20, 'FontWeight', 'bold');

% Title
title(sprintf('%s: all brains', stain), 'FontSize', 25)

% Border
box on
ax = gca;
ax.LineWidth = 1;

%% Save
cd(directory.save)
saveas(gcf, sprintf('%s_layer_graph.png', stain))

end
