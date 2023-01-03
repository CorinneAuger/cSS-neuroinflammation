%% Ring weight R^2 comparison
% Used in place of ring_weight_minima_comparison to compare two inflammatory markers.

clear
close all

columns = 4;

for k = 1
    if k == 1
        inflammatory_marker = 'GFAP';
    elseif k == 2
        inflammatory_marker = 'CD68';
    end
    
    %% Input directories
    directory.input = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel ring weight analysis/%s (1-tailed)/%d column/By section', inflammatory_marker, columns);
    directory.save_by_section = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel ring weight analysis/R^2 analysis/%s/By section', inflammatory_marker);
    directory.save_composite = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel ring weight analysis/R^2 analysis/%s/Composite', inflammatory_marker);
    
    %% Preallocate R^2 matrix
    R2_matrix = NaN(26, 7);
    
    for brain = 1:26
        for block = 1:7
            %% Import ring weight output
            cd(directory.input)
            variables_file_name = sprintf('CAA%d__%d_%s_and_Iron_best_weights_%d_column.mat', brain, block, inflammatory_marker, columns);
            
            if isfile(variables_file_name)
                load(variables_file_name, 'stat_inflammation');
                load(variables_file_name, 'best_weights')
                load(variables_file_name, 'stat_iron')
                
                best_weights = best_weights(1, :);
                
                %% Make actual heat map into a column
                actual_heat_map_size = size(stat_inflammation);
                actual_heat_map_number_of_pixels = actual_heat_map_size(1) * actual_heat_map_size(2);
                actual_heat_map_column = reshape(stat_inflammation, [actual_heat_map_number_of_pixels, 1]);
                
                %% Make predicted heat map
                % Make bordered iron density map
                [density_map_x, density_map_y] = size(stat_iron);
                side_bordered_densities = cat(2, NaN(density_map_x, 3), stat_iron, NaN(density_map_x, 3));
                bordered_densities = cat(1, NaN(3, density_map_y+6), side_bordered_densities, NaN(3, density_map_y+6));
                
                % Pre-allocate matrices
                predicted_pixel_value = NaN(size(stat_iron));
                predicted_first_ring_value = NaN(size(stat_iron));
                predicted_second_ring_value = NaN(size(stat_iron));
                predicted_third_ring_value = NaN(size(stat_iron));
                predicted_heat_map = NaN([density_map_x, density_map_y]);
                
                % Calculate brightness scaling factor
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
                
                % Calculate predicted ring values
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
                
                % Make the predicted heat map
                for x = 1:density_map_x
                    for y = 1:density_map_y
                        predicted_heat_map(x,y) = (predicted_pixel_value(x,y) * best_weights(1)) + (predicted_first_ring_value(x,y) * best_weights(2)) + (predicted_second_ring_value(x,y) * best_weights(3)) + (predicted_third_ring_value(x,y) * best_weights(4));
                    end
                end
                
                %% Make the predicted heat map into column
                predicted_heat_map_column = reshape(predicted_heat_map, [actual_heat_map_number_of_pixels, 1]);
                
                %% Make scatter plot
                scatter(actual_heat_map_column, predicted_heat_map_column, 25, '.', 'black')
                
                title(sprintf('CAA%d__%d_%s', brain, block, inflammatory_marker));
                xlabel('Actual values')
                ylabel('Predicted values')
                
                % Add line and R^2
                linear_model = fitlm(actual_heat_map_column, predicted_heat_map_column);
                coefs = linear_model.Coefficients.Estimate;
                y_intercept = coefs(1);
                slope = coefs(2);
                refline(slope, y_intercept);
                R_squared = linear_model.Rsquared.Ordinary;
                
                %% Add R^2 to overall matrix
                R2_matrix(brain, block) = R_squared;
                
                %% Save for section
                cd(directory.save_by_section)
                
                % Variables
                variables_save_name = sprintf('CAA%d_%d_%s_R_squared_analysis_matrix.mat', brain, block, inflammatory_marker);
                scatter_plot_matrix = [predicted_heat_map_column, actual_heat_map_column];
                save(variables_save_name, 'scatter_plot_matrix')
                
                % Figure
                section_figure_save_name = sprintf('CAA%d_%d_%s_R_squared_analysis_figure.png', brain, block, inflammatory_marker);
                saveas(gcf, section_figure_save_name)
                
                %% Reset loop for next iteration
                clearvars -except columns k inflammatory_marker directory R2_matrix brain block
                close all
                
            end
        end
    end
    
    %% Make overall R^2 graph
    R2_column = reshape(R2_matrix, [182, 1]);
    R2_column(any(isnan(R2_column), 2), :) = [];
    
    ones_column_for_final_figure = ones(size(R2_column));
    
    scatter(ones_column_for_final_figure, R2_column, 25, '.', 'black')
    hold on
    
    boxplot(R2_column)
    title('All R^2 values')
    ylabel('R^2')
    
    %% Get overall R^2 stats
    
    R2_mean = mean(R2_column);
    R2_median = median(R2_column);
    
    %% Save composite
    cd(directory.save_composite)
    
    composite_variables_save_name = sprintf('%s R^2 variables.mat', inflammatory_marker);
    save(composite_variables_save_name, 'R2_matrix', 'R2_mean', 'R2_median')
    
    composite_figure_save_name = sprintf('%s all R^2 values figure.png', inflammatory_marker);
    saveas(gcf, composite_figure_save_name)
end
