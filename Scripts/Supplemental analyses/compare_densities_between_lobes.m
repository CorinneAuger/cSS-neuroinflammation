function compare_densities_between_lobes(stain)
% Compares object densities across all brains between different cortical lobes.
% Used supplementally to show that brain region is not an important factor in determining the density of any of our markers.

%% Define directories
directory.spreadsheet = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Image sizes spreadsheets';

%% Import spreadsheet with object densities
cd(directory.spreadsheet)

[~, ~, master_file_cell] = xlsread('Masterfile_Aiforia_Hemispheres_04202021.xlsx', sprintf('AI_results_%s', stain));
[master_x, master_y] = size(master_file_cell);
master_file_string = string(master_file_cell);

if strcmp(stain, 'Iron') == 1
    object_name = 'Iron';
    tissue_name = 'Tissue';
elseif strcmp(stain, 'GFAP') == 1
    object_name = 'Astrocyte';
    tissue_name = 'Tissue';
elseif strcmp (stain, 'Fibrin') == 1
    object_name = 'Vascular';
    tissue_name = 'Non Vascular Tissue';
end

%% Pre-allocate object density matrix
object_density = NaN(26,4);

%% Get tissue area and object count from spreadsheet for each block
for brain = [1:3, 5, 7:9, 11, 13:15, 17, 18, 20:25]
    for block = [1 4 5 7]
        for row = 1: master_x
            if strcmp(sprintf('CAA%d_%d_%s', brain, block, stain), master_file_string(row,1)) == 1
                if strcmp(master_file_string(row,5), tissue_name) == 1
                    tissue_area = str2double(master_file_string(row,6));
                elseif strcmp(master_file_string(row,5), object_name) == 1
                    if strcmp(stain, 'Fibrin') == 1
                        object_count = str2double(master_file_string(row, 6));
                    else
                        object_count = str2double(master_file_string(row, 8));
                    end
                end
            end
        end

        %% Calculate object count per area
        if strcmp (stain, 'Fibrin') == 1
            object_density(brain, block) = object_count/(tissue_area + object_count);
        else
            object_density(brain, block) = object_count/tissue_area;
        end
    end
end

%% Omit blocks not included in analysis
object_density(:, 6) = [];
object_density(:, 3) = [];
object_density(:, 2) = [];

%% Make scatterplot
figure;
for block = [1, 2, 3, 4]
    scatter(block * ones(26,1), object_density(:,block), 'black', '.');
    hold on
end

a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',18)

boxplot(object_density)
xlabel('Lobe', 'FontSize', 20);
xticks([1 2 3 4]);
xticklabels({'Frontal', 'Temporal', 'Parietal', 'Occipital'});
xlim([0.5 4.5]);

%ylim([0 200]);
ylabel(sprintf('%s density (objects/mm^2)', stain), 'FontSize', 20);
%title(sprintf('%s density by lobe', stain), 'FontSize', 16);

%% Save
cd '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Saved data/Lobe comparisons'
save(sprintf('Lobe_comparison_matrix_%s.mat', stain), 'object_density');
saveas(gcf, sprintf('Lobe_comparison_box_plot_%s.png', stain));

end
