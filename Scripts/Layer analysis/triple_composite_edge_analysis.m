%% Triple composite edge analysis
% Puts all the edge analyses for different stains together.

clear
cd '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Saved data/Edge analysis/Final edge composite data'
load('Variables_all_brains_1000um_Iron_edge_analysis')
close all

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

    scatter(temp_column, layer_densities_all_brains(:,column_number), 25, '.', 'blue');
    hold on
end

x = 1:number_of_layers;
fill([x(1,:), fliplr(x(1,:))], [percentiles(1,:), fliplr(percentiles(3,:))], 'blue', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
plot(percentiles(2,:), '-b');

%xticks([1 number_of_layers])
%xlim([1 number_of_layers])
%labels = {'Outermost', 'Innermost'};
%xticklabels(labels)

Iron_number_of_layers = number_of_layers;
clearvars -except Iron_number_of_layers
%% starting again for GFAP

cd '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Saved data/Edge analysis/Final edge composite data'
load('Variables_all_brains_1000um_GFAP_edge_analysis')
close

percentiles_to_be_cleared = prctile(layer_densities_all_brains, [25, 50, 75]);
if layer_width == 500
    number_of_layers = 40 - numel(find(isnan(percentiles_to_be_cleared(2,:))));
elseif layer_width == 1000
    number_of_layers = 20 - numel(find(isnan(percentiles_to_be_cleared(2,:))));
end
clear percentiles_to_be_cleared

percentiles = prctile(layer_densities_all_brains(:,1:number_of_layers), [25, 50, 75]);
hold on

for column_number = 1:number_of_layers
    temp_column = column_number * ones(26,1);
    for row = 1:26
        if isnan(layer_densities_all_brains(row,column_number))
            temp_column(row) = NaN;
        end
    end

    scatter(temp_column, layer_densities_all_brains(:,column_number), 25, '.', 'red');
    hold on
end

x = 1:number_of_layers;
fill([x(1,:), fliplr(x(1,:))], [percentiles(1,:), fliplr(percentiles(3,:))], 'red', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
plot(percentiles(2,:), '-r');

a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',18)

if layer_width == 500
    xlabel('500um layer', 'FontSize', 20, 'FontWeight', 'bold');
elseif layer_width == 1000
    xlabel('1000um layer', 'FontSize', 20, 'FontWeight', 'bold');
end

GFAP_number_of_layers = number_of_layers;
clearvars -except Iron_number_of_layers GFAP_number_of_layers
%% Starting again for CD68

cd '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Saved data/Edge analysis/Final edge composite data'
load('Variables_all_brains_1000um_CD68_edge_analysis')
close

percentiles_to_be_cleared = prctile(layer_densities_all_brains, [25, 50, 75]);
if layer_width == 500
    number_of_layers = 40 - numel(find(isnan(percentiles_to_be_cleared(2,:))));
elseif layer_width == 1000
    number_of_layers = 20 - numel(find(isnan(percentiles_to_be_cleared(2,:))));
end
clear percentiles_to_be_cleared

percentiles = prctile(layer_densities_all_brains(:,1:number_of_layers), [25, 50, 75]);
hold on

for column_number = 1:number_of_layers
    temp_column = column_number * ones(26,1);
    for row = 1:26
        if isnan(layer_densities_all_brains(row,column_number))
            temp_column(row) = NaN;
        end
    end

    scatter(temp_column, layer_densities_all_brains(:,column_number), 25, '.', 'green');
    hold on
end

x = 1:number_of_layers;
fill([x(1,:), fliplr(x(1,:))], [percentiles(1,:), fliplr(percentiles(3,:))], 'green', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
plot(percentiles(2,:), '-g');

a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',18)

if layer_width == 500
    xlabel('500um layer', 'FontSize', 20, 'FontWeight', 'bold');
elseif layer_width == 1000
    xlabel('1000um layer', 'FontSize', 20, 'FontWeight', 'bold');
end

CD68_number_of_layers = number_of_layers;

number_of_layers_minimum = min([Iron_number_of_layers, GFAP_number_of_layers, CD68_number_of_layers]);
%title('Iron and GFAP density by 1000um-thick layer of cortex', 'FontSize', 18);
%xticks([1 number_of_layers_minimum]); xlim([1 number_of_layers_minimum])
xlim([1 5]); xticks([1 5])
labels = {'Outermost', 'Innermost'};
xticklabels(labels)
ylabel('Mean density (%)', 'FontSize', 20, 'FontWeight', 'bold');

cd '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Saved data/Edge analysis/Final edge composite data';
saveas(gcf, 'Line_graph_GFAP_CD68_and_Iron.png')

cd '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Scripts';
