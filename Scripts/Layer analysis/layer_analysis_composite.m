%% Layer analysis composite
% Makes the final graphs for the paper.
% One stain per graph.
% Used in end_of_layer_analysis. Can also be used independently.

function [] = layer_analysis_composite(stain)

%% Input directories 
directory.input = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/Edge analysis/Individual slides/%s 1000um/Variables', stain);
directory.save_plots = '/Volumes/Corinne hard drive/cSS project/Saved data/Edge analysis/Composite data/Plots';
directory.save_variables = '/Volumes/Corinne hard drive/cSS project/Saved data/Edge analysis/Composite data/Variables';

%% Build layer_densities_all_brains matrix
% Preallocate for all brains
layer_densities_all_brains = NaN(26, 5);

% Load data
cd(directory.input)

for brain = [1:3, 5, 7:9, 11, 13:15, 17:18, 20:25]
    
    % Preallocate for one brain only
    block_densities = NaN(7, 5);
    
    % Fill in densities for each block
    for block = [1, 4, 5, 7]
        file_name = sprintf('CAA%d_%d_%s_edge_analysis_variables.mat', brain, block, stain);
        cd(directory.input)
        
        % Allow missing data
        if isfile(file_name)
            layer_densities_struct = load(file_name, 'layer_densities');
            block_densities(block, :) = layer_densities_struct.layer_densities;
            clear layer_densities_struct
        end
    end
    
    % Get mean layer densities for brain
    layer_densities_all_brains(brain, :) = nanmean(block_densities);
end

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
percentiles = prctile(layer_densities_all_brains, [25, 50, 75]);

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

if strcmp(stain, 'Iron')
    ylabel('Mean iron deposits/?m^2', 'FontSize', 20, 'FontWeight', 'bold');
elseif strcmp(stain, 'GFAP')
    ylabel('Mean GFAP-positive cells/?m^2', 'FontSize', 20, 'FontWeight', 'bold');
elseif strcmp(stain, 'CD68')
    ylabel('Mean CD68-positive cells/?m^2', 'FontSize', 20, 'FontWeight', 'bold');
end

% Title
title(sprintf('%s: all brains', stain), 'FontSize', 25)

% Border
box on
ax = gca;
ax.LineWidth = 1;

%% Save
% Save plot
cd(directory.save_plots)
saveas(gcf, sprintf('%s_layer_graph.png', stain))

% Save matrix
matrix_save_name = sprintf('%s_layer_densities_all_brains.mat', stain);

cd(directory.save_variables)
save(matrix_save_name, 'layer_densities_all_brains');

end
