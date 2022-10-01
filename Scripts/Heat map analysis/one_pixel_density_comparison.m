%% One pixel density comparison
% Use after density_comparison to work in accurate object counts rather than densities that underestimate the number of objects in dense areas.

%% User inputs
inflammatory_marker = 'GFAP';

% Try toggling either of these on (replace 0 with 1) if the first try gave a bad mask
different_mask_thresholding = 0;
try_CD68_mask = 0;

for brain = [1:3, 5, 7:9, 11, 13:15, 17, 18, 20:25]
    for block = [1, 4, 5, 7]

        %% Define directories
        directory.variables = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Saved data/Density comparison';
        directory.scripts = '/Volumes/Corinne hard drive/cSS project/Scripts/Heat map analysis';
        directory.CD68_masks = '/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel density comparison/CD68/All variables';
        directory.save_all_variables = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel density comparison/%s/All variables', inflammatory_marker);
        directory.save_crucial_variables = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel density comparison/%s/Crucial variables', inflammatory_marker);
        directory.save_figures = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel density comparison/%s/Figures', inflammatory_marker);

        if strcmp(inflammatory_marker, 'GFAP') == 1
            directory.exclusion = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Saved data/Neighbor analysis/Comparing ring weights/By section/1-tailed/GFAP 1-tailed early brightness correction';
            exclusion_file = sprintf('CAA%d__%d_%s_and_Iron_best_weights.mat', brain, block, inflammatory_marker);
        elseif strcmp(inflammatory_marker, 'CD68') == 1
            directory.exclusion = directory.variables;
            exclusion_file = sprintf('CAA%d_%d_%s_and_Iron_density_comparison_all_variables.mat', brain, block, inflammatory_marker);
        end

        %% Load variables
        variables_file = sprintf('CAA%d_%d_%s_and_Iron_density_comparison_all_variables.mat', brain, block, inflammatory_marker);

        cd(directory.exclusion)
        if isfile(exclusion_file)

            cd(directory.variables)
            load(variables_file);

            %% Clear old scatter plot variables
            close all
            clear iron_scatter iron_heat_map iron_scatter_1 iron_heat_map_1 iron_scatter_2 iron_heat_map_2 iron_heat_map_sum noncoregistered_inflammation_scatter inverted_noncoregistered_inflammation_scatter_1 noncoregistered_inflammation_scatter_1 inverted_noncoregistered_inflammation_scatter_2 noncoregistered_inflammation_scatter_2 noncoreg_inf_sum

            %% Make new masks - TOGGLES ON AND OFF
            if different_mask_thresholding == 1
                clear iron_tissue_mask iron_tissue_mask_1 iron_tissue_mask_2 inflammation_tissue_mask
                cd(directory.scripts)

                % Iron
                if number_iron_rois == 1
                    iron_tissue_mask = extract_cortex_from_tissue_map(coregistered_tissue_map_iron, blue_channel_iron, red_channel_iron);
                elseif number_iron_rois == 2
                    iron_tissue_mask_1 = extract_cortex_from_tissue_map(coregistered_tissue_map_iron_1, blue_channel_iron_1, red_channel_iron_1);
                    iron_tissue_mask_2 = extract_cortex_from_tissue_map(coregistered_tissue_map_iron_2, blue_channel_iron_2, red_channel_iron_2);
                    iron_tissue_mask_sum = iron_tissue_mask_1 + iron_tissue_mask_2;
                    iron_tissue_mask = (iron_tissue_mask_sum > 0);
                end

                % Inflammation
                inflammation_tissue_mask = extract_cortex_from_tissue_map(coregistered_tissue_map_inflammation, blue_channel_inflammation, red_channel_inflammation);
                close all
            end

            %% Make iron scatter plot
            cd(directory.scripts)

            if number_iron_rois == 1
                iron_heat_map = scaled_down_no_scatter_heat_map(original_iron, brain, block, 'Iron', 1);
            elseif number_iron_rois == 2
                iron_heat_map_1 = scaled_down_no_scatter_heat_map(original_iron, brain, block, 'Iron', 1);

                cd(directory.scripts)
                iron_heat_map_2 = scaled_down_no_scatter_heat_map(original_iron, brain, block, 'Iron', 2);

                close all

                iron_heat_map = iron_heat_map_1 + iron_heat_map_2;
            end

            %% Make inflammation scatter plot
            cd(directory.scripts)

            if number_inflammation_rois == 1
                noncoregistered_inflammation_scatter = scaled_down_no_scatter_heat_map(original_inflammation, brain, block, inflammatory_marker, 1);
            elseif number_inflammation_rois == 2
                noncoregistered_inflammation_scatter_1 = scaled_down_no_scatter_heat_map(original_inflammation, brain, block, inflammatory_marker, 1);

                cd(directory.scripts)
                noncoregistered_inflammation_scatter_2 = scaled_down_no_scatter_heat_map(original_inflammation, brain, block, inflammatory_marker, 2);

                close all

                noncoregistered_inflammation_scatter = noncoregistered_inflammation_scatter_1 + noncoregistered_inflammation_scatter_2;
            end

            if rotation == 1
                noncoregistered_inflammation_scatter = imrotate(noncoregistered_inflammation_scatter, 180);
            elseif rotation == 2
                noncoregistered_inflammation_scatter = imrotate(noncoregistered_inflammation_scatter, 90);
            else
            end

            close all

            %% Coregister inflammation scatterplot to og iron image
            clear Rnoncoregistered_inflammation_scatter partially_coregistered_inflammation_scatter inflammation_heat_map

            Rnoncoregistered_inflammation_scatter = imref2d([noncoreg_x, noncoreg_y]);

            % Apply first transformation
            [iron_x, iron_y] = size(coregistered_inflammation);
            Rpartially_coregistered_tissue_map_inflammation = imref2d([iron_x, iron_y]);
            partially_coregistered_inflammation_scatter = imwarp(noncoregistered_inflammation_scatter, Rnoncoregistered_inflammation_scatter, tform, 'OutputView', Rpartially_coregistered_tissue_map_inflammation, 'FillValues', 200);

            % Apply second transformation
            unscaled_inflammation_heat_map = imwarp(partially_coregistered_inflammation_scatter, D, 'nearest', 'FillValues', 200);

            %% Set primary mask
            primary_mask = inflammation_tissue_mask;

            % Try CD68 mask - TOGGLES ON AND OFF
            if try_CD68_mask == 1
                cd(directory.CD68_masks)

                CD68_variables_file_name = sprintf('CAA%d_%d_CD68_and_Iron_1pixel_density_comparison_all_variables.mat', brain, block);
                load(CD68_variables_file_name, 'primary_mask')
            end

            %% Apply masks to scatter plots to put NaNs in non-cortex area
            [mask_size_x, mask_size_y] = size(primary_mask);

            for x = 1:mask_size_x
                for y = 1:mask_size_y
                    if primary_mask(x,y) == 0 || primary_mask(x,y) == 0.5 || unscaled_inflammation_heat_map(x,y) > 2
                        iron_heat_map(x,y) = NaN;
                        unscaled_inflammation_heat_map(x,y) = NaN;
                    end
                end
            end

            %% Scale all the points in the inflammation heat map by the same amount to account for the coregistration transformation
            noncoreg_inflammation_objects = nansum(nansum(noncoregistered_inflammation_scatter));
            inflammation_objects = nansum(nansum(unscaled_inflammation_heat_map));
            inflammation_heat_map = unscaled_inflammation_heat_map * (noncoreg_inflammation_objects/inflammation_objects);

            %% Calculate densities
            clear stat_iron stat_inflammation

            matlab_pixel_size = 6.603822; %microns
            patch_size_pixels = round(patch_size_microns / matlab_pixel_size); % = 76
            size_patch = [patch_size_pixels, patch_size_pixels];

            cd(directory.scripts)
            stat_iron = PatchGenerator_density_comparison(iron_heat_map, size_patch, size_patch, 'Values');
            stat_inflammation = PatchGenerator_density_comparison(inflammation_heat_map, size_patch, size_patch, 'Values');

            clear iron_patch_densities inflammation_patch_densities finalfigure graph density_comparison_scattter

            %% Set up final figure
            finalfigure = figure;
            finalfigure.Position = [1,1,1500,482];
            graph = subplot(2,6,[1,2,7,8]);
            graph.Position = graph.Position + [0 0 0.015 0];

            %% Final figure: make scatter plot of pixels
            iron_patch_objects = reshape(stat_iron, [1, numel(stat_iron)]);
            inflammation_patch_objects = reshape(stat_inflammation, [1, numel(stat_inflammation)]);
            density_comparison_scatter = scatter(iron_patch_objects, inflammation_patch_objects, 25, '.', 'black');
            ylim([0, (max(inflammation_patch_objects)*(5/3))])
            xlabel('Iron objects');
            ylabel(sprintf('%s objects', inflammatory_marker));
            title(sprintf('CAA%d__%d', brain, block));

            %% Final figure: slope and R^2 for scatter plot
            clear linear_model coefs y_intercept slope R_squared no_nan_iron_patch_densities non_nan_inflammation_patch_densities number_of_iron_patches
            linear_model = fitlm(iron_patch_objects', inflammation_patch_objects');
            coefs = linear_model.Coefficients.Estimate;
            y_intercept = coefs(1);
            slope = coefs(2);
            refline(slope, y_intercept);
            R_squared = linear_model.Rsquared.Ordinary;

            %% Final figure: Pearson and Spearman coefficients for scatter plot
            % Make matrix of columns
            no_nan_iron_patch_densities = iron_patch_objects';
            no_nan_inflammation_patch_densities = inflammation_patch_objects';
            [~,number_of_iron_patches] = size(iron_patch_objects);

            % Exclude NaNs
            for i = number_of_iron_patches:-1:1
                if  isnan(iron_patch_objects(i)) == 1 || isnan(inflammation_patch_objects(i)) == 1
                    no_nan_iron_patch_densities(i) = [];
                    no_nan_inflammation_patch_densities(i) = [];
                end
            end

            % Get Pearson and Spearman coefficients
            clear Pearson_coefficient Pearson_pval Spearman_coefficient Spearman_pval caption
            [Pearson_coefficient, Pearson_pval] = corr(no_nan_iron_patch_densities, no_nan_inflammation_patch_densities, 'Type', 'Pearson');
            [Spearman_coefficient, Spearman_pval] = corr(no_nan_iron_patch_densities, no_nan_inflammation_patch_densities, 'Type', 'Spearman');

            % Put stats in box on graph
            caption = ['slope = ', sprintf('%.4f', slope)];
            caption = [caption newline 'R^2 = ',sprintf('%.4f', R_squared)];
            caption = [caption newline 'Pearson''s linear correlation coefficient = ',sprintf('%.4f', Pearson_coefficient), '     p = ', sprintf('%.4e', Pearson_pval)];
            caption = [caption newline 'Spearman''s \rho = ',sprintf('%.4f', Spearman_coefficient), '     p = ', sprintf('%.4e', Spearman_pval)];
            annotation('textbox',[.15 0.9 0 0],'string',caption,'FitBoxToText','on','EdgeColor','black','BackgroundColor','white')

            %% Final figure: iron scatter plot overlaid on original iron stain
            subplot(2,5,3)

            figure_only_iron_heat_map = ones(iron_x, iron_y);

            % invert to black on white and make all pixels 1s or 0s
            for x = 1 : iron_x
                for y = 1: iron_y
                    if iron_heat_map(x,y) ~= 0 && isnan(iron_heat_map(x,y)) == 0
                        figure_only_iron_heat_map(x,y) = 0;
                    end
                end
            end

            imshowpair(figure_only_iron_heat_map, original_iron);
            title(sprintf('CAA%d__%d_Iron', brain, block));
            axis image;
            axis off;

            %% Final figure: iron heat map
            subplot(2,5,4)
            imshow(stat_iron(:,:), [0 ((patch_size_pixels^2) * 0.01)]);
            title(sprintf('CAA%d__%d_Iron', brain, block));
            axis image;
            axis off;
            colormap(gca, jet);
            colorbar;

            %% Final figure: original two images overlaid: can see coregistration accuracy
            subplot(2,5,5);
            imshowpair(original_iron, coregistered_inflammation);
            %imshowpair(bw_iron, bw_inflammation);
            %title({'Coregistration', sprintf('Dice coefficient=%f', section_similarity)})
            axis image;
            axis off;

            %% Final figure: inflammation scatter plot overlaid on original iron stain
            subplot(2,5,8)

            figure_only_inflammation_heat_map = ones(iron_x, iron_y);

            % invert to black on white and make all pixels 1s or 0s
            for x = 1 : iron_x
                for y = 1: iron_y
                    if inflammation_heat_map(x,y) ~= 0 && isnan(inflammation_heat_map(x,y)) == 0
                        figure_only_inflammation_heat_map(x,y) = 0;
                    end
                end
            end

            imshowpair(figure_only_inflammation_heat_map, coregistered_inflammation);
            title(sprintf('CAA%d__%d_%s', brain, block, inflammatory_marker));
            axis image;
            axis off;

            %% Final figure: inflammation heat map
            subplot(2,5,9);

            if strcmp(inflammatory_marker, 'CD68') == 1
                imshow(stat_inflammation,[0 (patch_size_pixels^2) * 0.02]);
            elseif strcmp(inflammatory_marker, 'GFAP') == 1
                imshow(stat_inflammation,[0 (patch_size_pixels^2) * 0.01])
            end

            title(sprintf('CAA%d__%d_%s', brain, block, inflammatory_marker));
            axis image;
            axis off;
            colormap(gca, jet);
            colorbar;

            %% Final figure: cortex mask and opposite scatter plot overlaid
            subplot(2,5,10)
            imshowpair(figure_only_iron_heat_map, primary_mask)
            title('Iron Heat Map on Inflammation Mask')
            axis image
            axis off

            %% Save
            % Save final figure
            cd(directory.save_figures)
            density_figure_save_name = sprintf('CAA%d_%d_%s_and_Iron_density_figure.png', brain, block, inflammatory_marker);
            saveas(gcf, density_figure_save_name);

            % Save file of all variables
            clear all_variables_save_name cruicial_variables_save_name
            cd(directory.save_all_variables)
            all_variables_save_name = sprintf('CAA%d_%d_%s_and_Iron_1pixel_density_comparison_all_variables.mat', brain, block, inflammatory_marker);
            save(all_variables_save_name);

            % Save file of crucial variables
            cd(directory.save_crucial_variables)
            crucial_variables_save_name = sprintf('CAA%d_%d_%s_and_Iron_1pixel_density_comparison_crucial_variables.mat', brain, block, inflammatory_marker);
            save(crucial_variables_save_name, 'stat_iron', 'stat_inflammation', 'Spearman_coefficient', 'rotation', 'R_squared', 'Pearson_coefficient', 'original_iron', 'original_inflammation', 'linear_model', 'iron_tissue_mask', 'iron_heat_map', 'inflammation_heat_map');

        end

        % Reset for the next iteration of the loop
        cd(directory.scripts)
        clearvars -except brain block inflammatory_marker patch_size_microns different_mask_thresholding try_CD68_mask
        close all

    end
end
