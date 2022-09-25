%% Ring weight analysis

%% Input inflammatory marker (GFAP or CD68)
inflammatory_marker = 'CD68';

%% Input directories
directory.input = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel density comparison/%s/All variables', inflammatory_marker);
directory.save_by_section = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel ring weight analysis/%s (1-tailed)/By section', inflammatory_marker);
directory.save_overall_matrix = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel ring weight analysis/%s (1-tailed)/Composite', inflammatory_marker);
directory.scripts = '/Volumes/Corinne hard drive/cSS project/Scripts';

%% Make matrix of weight combinations
percent_weights = NaN(8038,4);
%percent_weights = NaN(176852,4);

loop = 1;
for trial_pixel_weight = 0:100
    for trial_first_ring_weight = 0:100
        for trial_second_ring_weight = 0:100
            for trial_third_ring_weight = 0:100
                if trial_pixel_weight >= trial_first_ring_weight && trial_first_ring_weight >= trial_second_ring_weight && trial_second_ring_weight >= trial_third_ring_weight
                    if  (trial_pixel_weight + trial_first_ring_weight + trial_second_ring_weight + trial_third_ring_weight) == 100
                        loop = loop + 1;
                        percent_weights(loop,:) = [trial_pixel_weight, trial_first_ring_weight, trial_second_ring_weight, trial_third_ring_weight];
                    end
                end
            end
        end
    end
end

%% Reformat
weights = percent_weights/100;
weights(1,:) = [];
clearvars -except weights inflammatory_marker directory

%% Pre-allocate matrices for all blocks
best_weights_all_blocks = NaN(3,4,104);
minima_all_blocks = NaN(3,4,26);
excluded_based_on_slope = 0;

%% Start loop to compare weighting options for each block
for brain = [22:25]
    for block = [1, 4, 5, 7]
        
        close all
        fprintf('CAA%d__%d', brain, block) % make progress visible in command window
    
        %% Import iron and inflammation density maps
        cd(directory.input)
        variables_file = sprintf('CAA%d_%d_%s_and_Iron_1pixel_density_comparison_all_variables.mat', brain, block, inflammatory_marker);
        
        if isfile(variables_file)
            load(variables_file, 'stat_iron');
            load(variables_file, 'stat_inflammation');
            load(variables_file, 'slope');
            
            if slope > 0
                
                %% Make bordered iron density map
                [density_map_x, density_map_y] = size(stat_iron);
                side_bordered_densities = cat(2, NaN(density_map_x, 3), stat_iron, NaN(density_map_x, 3));
                bordered_densities = cat(1, NaN(3, density_map_y+6), side_bordered_densities, NaN(3, density_map_y+6));
                
                %% Pre-allocate matrices
                predicted_pixel_value = NaN(size(stat_iron));
                predicted_first_ring_value = NaN(size(stat_iron));
                predicted_second_ring_value = NaN(size(stat_iron));
                predicted_third_ring_value = NaN(size(stat_iron));
                predicted_heat_map = NaN([density_map_x, density_map_y]);
                difference_means = NaN(8037,1);
                
                %% Calculate brightness scaling factor
                density_map_pixels = density_map_x * density_map_y;
                reshaping_dimensions = [density_map_pixels, 1];
                
                reshaped_stat_iron = reshape(stat_iron, reshaping_dimensions);
                reshaped_stat_inflammation = reshape(stat_inflammation, reshaping_dimensions);
                
                % Preallocate
                iron_above_1 = reshaped_stat_iron;
                inflammation_above_1 = reshaped_stat_inflammation;
                
                for pixel = density_map_pixels: -1: 1 % median doesn't include very low values
                    if reshaped_stat_iron(pixel) < 1
                        iron_above_1(pixel) = [];
                    end
                    if reshaped_stat_inflammation(pixel) < 1
                        inflammation_above_1(pixel) = [];
                    end
                end
                
                iron_median = nanmedian(iron_above_1);
                inflammation_median = nanmedian(inflammation_above_1);
                
                brightness_scaling_factor = inflammation_median/iron_median;
    
                %% Calculate predicted ring values
                for i = 4: density_map_x + 3
                    for j = 4: density_map_y + 3
                        closest_ring = [bordered_densities(i,j-1), bordered_densities(i,j+1), bordered_densities(i+1,j), bordered_densities(i-1,j), bordered_densities(i+1,j+1), bordered_densities(i+1,j-1), bordered_densities(i-1,j+1), bordered_densities(i-1,j-1)];
                        closest_ring(find(isnan(closest_ring))) = [];
                        closest_ring_mean = mean(mean(closest_ring));
                        
                        second_closest_ring = [bordered_densities(i+2,j-2), bordered_densities(i+2,j-1), bordered_densities(i+2,j), bordered_densities(i+2,j+1), bordered_densities(i+2,j+2), bordered_densities(i-2,j-2), bordered_densities(i-2,j-1), bordered_densities(i-2,j), bordered_densities(i-2,j+1), bordered_densities(i-2,j+2), bordered_densities(i-1,j-2), bordered_densities(i,j-2), bordered_densities(i+1,j-2), bordered_densities(i-1,j+2), bordered_densities(i,j+2), bordered_densities(i+1,j+2)];
                        second_closest_ring(find(isnan(second_closest_ring))) = [];
                        second_closest_ring_mean = mean(mean(second_closest_ring));
                        
                        third_closest_ring = [bordered_densities(i+3,j-3), bordered_densities(i+3,j-2), bordered_densities(i+3,j-1), bordered_densities(i+3,j), bordered_densities(i+3,j+1), bordered_densities(i+3,j+2), bordered_densities(i+3,j+3), bordered_densities(i-3,j-3), bordered_densities(i-3,j-2), bordered_densities(i-3,j-1), bordered_densities(i-3,j), bordered_densities(i-3,j+1), bordered_densities(i-3,j+2), bordered_densities(i-3,j+3), bordered_densities(i-2,j-3), bordered_densities(i-1,j-3), bordered_densities(i,j-3), bordered_densities(i+1,j-3), bordered_densities(i+2,j-3), bordered_densities(i-2,j+3), bordered_densities(i-1,j-3), bordered_densities(i,j-3), bordered_densities(i+1,j-3), bordered_densities(i+2,j-3)];
                        third_closest_ring(find(isnan(third_closest_ring))) = [];
                        third_closest_ring_mean = mean(mean(third_closest_ring));
                                            
                        predicted_pixel_value(i-3, j-3) = stat_iron(i-3, j-3) * brightness_scaling_factor;
                        predicted_first_ring_value(i-3, j-3) = closest_ring_mean * brightness_scaling_factor;
                        predicted_second_ring_value(i-3, j-3) = second_closest_ring_mean * brightness_scaling_factor;
                        predicted_third_ring_value(i-3, j-3) = third_closest_ring_mean * brightness_scaling_factor;
                    end
                end         
                               
                %% Compare heat maps for all weight combinations
                for n = 1:8037
                    progress = waitbar(n/8037);
                    for x = 1:density_map_x
                        for y = 1:density_map_y
                            predicted_heat_map(x,y) = (predicted_pixel_value(x,y) * weights(n,1)) + (predicted_first_ring_value(x,y) * weights(n,2)) + (predicted_second_ring_value(x,y) * weights(n,3)) + (predicted_third_ring_value(x,y) * weights(n,4));
                            
                            if predicted_heat_map(x,y) > 3.0036e+04
                                predicted_heat_map(x,y) = 3.0036e+04;
                            end
                            
                            prediction_and_data_differences = abs(predicted_heat_map - stat_inflammation);
                            difference_means(n) = nanmean(nanmean(prediction_and_data_differences))/inflammation_median;
                        end
                    end
                end
                
                close(progress)
                
                %% Make matrix of best weighting options
                difference_means_without_minimum = difference_means;
                for k = 1:3
                    minimum_indices(k) = find(difference_means_without_minimum(:) == min(difference_means_without_minimum(:)));
                    minima(k) = min(min(difference_means_without_minimum));
                    best_weights(k,:) = weights(minimum_indices(k),:);
                    difference_means_without_minimum(minimum_indices(k)) = [];
                end
                
                %% Save file for the block
                cd(directory.save_by_section)
                save(sprintf('CAA%d__%d_%s_and_Iron_best_weights.mat', brain, block, inflammatory_marker));

                %% Put data into big matrix for all sections
                if block == 1
                    section_number = (brain * 4) - 3;
                elseif block == 4
                    section_number = (brain * 4) - 2;
                elseif block == 5
                    section_number = (brain * 4) - 1;
                elseif block == 7
                    section_number = brain * 4;
                end
                
                minima_all_blocks(:,section_number) = minima;
                best_weights_all_blocks(:,:,section_number) = best_weights;                
                clearvars -except brain block weights best_weights_all_blocks excluded_based_on_slope minima_all_blocks inflammatory_marker directory inflammation_median
                
            else
                %% Count sections where iron and inflammation don't positively correlate (already excluded)
                fprintf 'Negative slope';
                excluded_based_on_slope = excluded_based_on_slope + 1;
            end
            
        else
            fprintf 'No file';
        end 
    end
end

%% Make graph of weight options for sections
figure
top_weight_for_each_section = squeeze(best_weights_all_blocks(1,:,:))';
boxplot(top_weight_for_each_section);
xticklabels({'Pixel', 'Ring 1', 'Ring 2', 'Ring 3'})
ylim([0 1])
ylabel('Weight', 'FontSize', 18)
title('By section');

% Make axis labels bigger
a = get(gca,'XTickLabel');  
set(gca,'XTickLabel',a,'fontsize',18)
b = get(gca,'YTickLabel');  
set(gca,'YTickLabel',b,'fontsize',18)

% Add scatter plot
hold on
for ring = 1:4
    scatter(ring * ones(104,1), top_weight_for_each_section(:,ring), 'black', '.');
    hold on
end

%% Save section graph
cd(directory.save_by_section) 
saveas(gcf, sprintf('%s_and_Iron_weights_by_section.png', inflammatory_marker))
hold off

%% Calculate measures of central tendency across sections
section_mean = nanmean(top_weight_for_each_section);
section_median = median(top_weight_for_each_section,'omitnan');

%% Calculate values for brains
for brain_number = 1:26
    individual_brain_weights = [top_weight_for_each_section((brain_number * 4) - 3,:); top_weight_for_each_section((brain_number * 4) - 2,:); top_weight_for_each_section((brain_number * 4) - 1,:); top_weight_for_each_section(brain_number * 4,:)];
    top_weight_for_each_brain(brain_number, :) = nanmean(individual_brain_weights);
end

%% Calculate measures of central tendency across brains
brain_mean = nanmean(top_weight_for_each_brain);
brain_median = median(top_weight_for_each_brain,'omitnan');

%% Make graph of weight options for brains
figure
boxplot(top_weight_for_each_brain);
xticklabels({'Pixel', 'Ring 1', 'Ring 2', 'Ring 3'})
ylim([0 1])
ylabel('Weight', 'FontSize', 18)
title('By brain');

% Make axis labels bigger
a = get(gca,'XTickLabel');  
set(gca,'XTickLabel',a,'fontsize',18)
b = get(gca,'YTickLabel');  
set(gca,'YTickLabel',b,'fontsize',18)

% Add scatter plot
hold on
for ring = 1:4
    scatter(ring * ones(26,1), top_weight_for_each_brain(:,ring), 'black', '.');
    hold on
end

%% Save
% Save brain graph
cd(directory.save_overall_matrix)
saveas(gcf, sprintf('%s_and_Iron_1pixel_weights_by_brain.png', inflammatory_marker))
hold off

% Save variables
clearvars -except directory weights best_weights_all_blocks section_mean section_median top_weight_for_each_brain top_weight_for_each_section brain_mean brain_median excluded_based_on_slope minima_all_blocks inflammatory_marker
save(sprintf('%s_and_Iron_1pixel_ring_weight_analysis_variables.mat', inflammatory_marker))

%% Make into csv
cd(directory.scripts)
ring_weight_csv(inflammatory_marker);
