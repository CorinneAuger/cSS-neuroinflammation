%% Edge analysis composite
% Second step of edge analysis. Gathers all slides' edge data for one stain.

%% User settings
close all
clear
layer_width = 1000;
stain = 'CD68';

%% Input directories
directory.input = '/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel density comparison/GFAP/Crucial variables';
directory.save = '/Volumes/Corinne hard drive/cSS project/Saved data/Edge analysis/Final edge composite data';

%% Preallocation and settings
if layer_width == 500
    beginning_layers = 40;
elseif layer_width == 1000
    beginning_layers = 20;
end

layer_densities_by_brain = NaN(7,beginning_layers);
layer_densities_all_brains = NaN(26,beginning_layers);

%% Make matrix with all layer densities
specific_folder_name = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/Edge analysis/Individual slides/%s %dum', stain, layer_width);

for brain = [1:3, 5, 7:9, 11, 13:15, 17:18, 20:25]
    for block = [1 4 5 7]
        cd(directory.input)
        variables_file = sprintf('CAA%d_%d_%s_and_Iron_1pixel_density_comparison_crucial_variables.mat', brain, block, 'Iron');
        edge_analysis_file = sprintf('CAA%d_%d_%s_edge_analysis_variables.mat', brain, block, stain);
        cd(specific_folder_name)

        if isfile(edge_analysis_file)
            load(edge_analysis_file, 'layer_densities');
            layer_densities = layer_densities(:,1);
            number_of_nan_layers_needed = beginning_layers - numel(layer_densities);
            layer_densities_with_nans = cat(1, layer_densities, NaN(number_of_nan_layers_needed,1));
            layer_densities_by_brain(block, :) = layer_densities_with_nans;
        else
        end
    end

    layer_densities_all_brains(brain, :) = nanmean(layer_densities_by_brain);
    layer_densities_by_brain = NaN(7,beginning_layers);
    clear number_of_nan_layers_needed variables_file edge_analysis_file layer_densities layer_densities_with_nans number_of_nans_needed
end

composite_Iron_edge_analysis_graph = figure;

%% Make figure
for layer = 1:beginning_layers
    scatter(layer * ones(26,1), layer_densities_all_brains(:,layer), 'black', '.');
    hold on
end

boxplot(layer_densities_all_brains)
xlabel(sprintf('%dum layer', layer_width));
xticks(1:beginning_layers);
%xticklabels({'Outermost', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 'Innermost',});
xlim([0.5 (beginning_layers + 0.5)]);
title(sprintf('%s density by %dum-thick layer of cortex', stain, layer_width), 'FontSize', 16);

if strcmp(stain, 'GFAP') == 1
    ylabel('Average GFAP density (%)');
else
    ylabel(sprintf('Average %s density (%%)', stain));
end

%% Save
hold off
cd(directory.save)
save(sprintf('Variables_all_brains_%dum_%s_edge_analysis.mat', layer_width, stain));
save(sprintf('Matrix_all_brains_%dum_%s_edge_analysis', layer_width, stain), 'layer_densities_all_brains');
saveas(gcf, sprintf('Box_plot_all_brains_%dum_%s_edge_analysis_box_plot.png', layer_width, stain));

%% For prettier graph

% Get percentiles for shading
percentiles_to_be_cleared = prctile(layer_densities_all_brains, [25, 50, 75]);

if layer_width == 500
    number_of_layers = 40 - numel(find(isnan(percentiles_to_be_cleared(2,:))));
elseif layer_width == 1000
    number_of_layers = 20 - numel(find(isnan(percentiles_to_be_cleared(2,:))));
end
clear percentiles_to_be_cleared

percentiles = prctile(layer_densities_all_brains(:,1:number_of_layers), [25, 50, 75]);

figure;
for column_number = 1:number_of_layers
    temp_column = column_number * ones(26,1);
    for row = 1:26
        if isnan(layer_densities_all_brains(row,column_number))
            temp_column(row) = NaN;
        end
    end

    %if numel(find(isnan(layer_densities_all_brains(2,:)))) > 24
        %percentiles(2,column_number) = nanmean(temp_column);
    %end

    scatter(temp_column, layer_densities_all_brains(:,column_number), 25, '.', 'blue');
    hold on
end

% Shade from first to third quartile
x = 1:number_of_layers;
fill([x(1,:), fliplr(x(1,:))], [percentiles(1,:), fliplr(percentiles(3,:))], 'blue', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
plot(percentiles(2,:), '-b');

if layer_width == 500
    xlabel('500um layer');
    title(sprintf('%s density by 500um-thick layer of cortex', stain));
    %labels = {'Outermost', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 'Innermost'};
elseif layer_width == 1000
    xlabel('1000um layer');
    title(sprintf('%s density by 1000um-thick layer of cortex', stain));
    %labels = {'Outermost', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'Innermost'};
end
xticks([1 number_of_layers])
xlim([1 number_of_layers])
labels = {'Outermost', 'Innermost'};
xticklabels(labels)

if strcmp(stain, 'GFAP') == 1
    ylabel('Average GFAP density (%)');
else
    ylabel(sprintf('Average %s density (%%)', stain));
end

cd(directory.save)
%saveas(gcf, sprintf('All_brains_%dum_%s_edge_analysis_line_graph.png', layer_width, stain));
saveas(gcf, 'Line_graph_GFAP_and_Iron.png')
