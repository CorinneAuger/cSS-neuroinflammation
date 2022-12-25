%% Ring weight estimated map figures
% Generates predicted inflammation heat maps based on iron ones.
% To be used in ring weight figure for paper.

%% Manual input
clear

inflammatory_marker = 'GFAP';
patch_size_microns = 500;

%% Input directories
directory.input = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel ring weight analysis/%s (1-tailed)/4 column/By section', inflammatory_marker);
directory.density_map = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel density comparison/%s/Crucial variables', inflammatory_marker);
directory.save = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel ring weight analysis/%s (1-tailed)/4 column/By section/Figures', inflammatory_marker);

%% Load data
for brain = 1:25
    for block = [1 4 5 7]
        variables_file_name = sprintf('CAA%d__%d_%s_and_Iron_best_weights_4_column.mat', brain, block, inflammatory_marker);
        cd(directory.input)
        
        % Allow sections to be excluded
        if isfile(variables_file_name)
            
            % Load ring weight analysis variables
            load(variables_file_name, 'best_weights', 'density_map_x', 'density_map_y', 'predicted_pixel_value', 'predicted_first_ring_value', 'predicted_second_ring_value', 'predicted_third_ring_value')
            best_weights = best_weights(1, :);
            
            % Load real heat maps
            cd(directory.density_map)
            density_map_file_name = sprintf('CAA%d_%d_%s_and_Iron_1pixel_density_comparison_crucial_variables.mat', brain, block, inflammatory_marker);
            load(density_map_file_name, 'stat_iron', 'stat_inflammation');
            
            %% Make map
            %Preallocate
            predicted_heat_map = NaN(density_map_x, density_map_y);
            
            for x = 1:density_map_x
                for y = 1:density_map_y
                    predicted_heat_map(x,y) = (predicted_pixel_value(x,y) * best_weights(1)) + (predicted_first_ring_value(x,y) * best_weights(2)) + (predicted_second_ring_value(x,y) * best_weights(3)) + (predicted_third_ring_value(x,y) * best_weights(4));
                    
                    % Make sure nothing exceeds 100%
                    if predicted_heat_map(x,y) > 3.0036e+04
                        predicted_heat_map(x,y) = 3.0036e+04;
                    end
                    
                end
            end
            
            %% Make figure
            % Get scale bar upper_limit
            matlab_pixel_size = 6.603822; %microns
            patch_size_pixels = round(patch_size_microns / matlab_pixel_size);
            scale_bar_upper_limit = (patch_size_pixels^2) * 0.01;
            
            figure
            set(gcf, 'position', [1 1 1440 615])
            
            % Set up real iron figure
            subplot(3,1,1)
            imshow(stat_iron(:,:), [0, scale_bar_upper_limit]);
            title(sprintf('CAA%d__%d_real_iron', brain, block));
            colormap(gca, jet);
            colorbar;
            
            % Set up estimated inflammation figure
            subplot(3,1,2)
            imshow(predicted_heat_map(:,:), [0, scale_bar_upper_limit]);
            title(sprintf('CAA%d__%d_estimated_%s', brain, block, inflammatory_marker));
            colormap(gca, jet);
            colorbar;
            
            % Set up real inflammation figure
            subplot(3,1,3)
            imshow(stat_inflammation(:,:), [0, scale_bar_upper_limit]);
            title(sprintf('CAA%d__%d_real_%s', brain, block, inflammatory_marker));
            colormap(gca, jet);
            colorbar;
            
            %% Save
            cd(directory.save)
            saveas(gcf, sprintf('CAA%d_%d_estimated_%s_figure.png', brain, block, inflammatory_marker));
            
            %% Reset for next loop iteration
            close all
            clearvars -except inflammatory_marker patch_size_microns brain block directory
        end
    end
end
