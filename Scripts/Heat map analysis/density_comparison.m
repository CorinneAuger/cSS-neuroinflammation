% Original function to make heat maps.
% For a brand new slide, use this and then one_pixel_density_comparison.m

%% Define directories
directory.image_sizes_spreadsheets = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Image sizes spreadsheets';
directory.scripts = '/Volumes/Corinne hard drive/cSS project/Scripts/Heat map analysis';
directory.original_images = '/Volumes/Corinne hard drive/cSS project/Original images';
directory.tissue_screenshots = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Tissue screenshots';
directory.save = '/Volumes/Corinne hard drive/cSS project/Saved data/Original density comparison';

%% Inputs to change
inflammatory_marker = 'GFAP';
patch_size_microns = 500;

%% 1. coregister og inflammation image to og iron image

for brain = [1:5, 7:9, 11, 13:15, 17:18, 20:25]  
    for block = [1, 4, 5, 7]  

        close all
        
        cohort = 'CAA';
        number_inflammation_rois = 1;

        cd(directory.image_sizes_spreadsheets)
        iron_image_size_matrix = xlsread('Aiforia_image_sizes_Iron.xlsx');
        % column 1 is width; column 2 is height; column 3 is how many rois

        if block == 1
            row_number = ((brain - 1)*4) + 1;
        elseif block == 4
            row_number = ((brain - 1)*4) + 2;
        elseif block == 5
            row_number = ((brain - 1)*4) + 3;
        elseif block == 7
            row_number = brain * 4;
        end

        number_iron_rois = iron_image_size_matrix(row_number, 3);

        cd(directory.scripts)
        fixed_image_stain = 'Iron';
        moving_image_stain = inflammatory_marker;
        [rotation, D, tform, coregistered_inflammation, ~, ~] = Aiforia_coregistration(brain, block, fixed_image_stain, moving_image_stain);

        %% 2. make iron and inflammation scatterplots (for both and combine)

        cd(directory.scripts)

        if number_iron_rois == 1
            iron_scatter = Heat_map_from_Aiforia(brain, block, 'Iron', 1);
            iron_heat_map = double((iron_scatter(:,:,1) == 0));
        elseif number_iron_rois == 2
            iron_scatter_1 = Heat_map_from_Aiforia(brain, block, 'Iron', 1);
            iron_heat_map_1 = iron_scatter_1(:,:,1);

            cd(directory.scripts)
            iron_scatter_2 = Heat_map_from_Aiforia(brain, block, 'Iron', 2);
            iron_heat_map_2 = iron_scatter_2(:,:,1);
            close all

            iron_heat_map_sum = iron_heat_map_1 + iron_heat_map_2;
            iron_heat_map = double((iron_heat_map_sum(:,:,1) < 2));
        end

        cd(directory.scripts)

        if number_inflammation_rois == 1
            noncoregistered_inflammation_scatter = Heat_map_from_Aiforia(brain, block, inflammatory_marker, 1);
            noncoregistered_inflammation_scatter = double((noncoregistered_inflammation_scatter(:,:,1) == 0));
        elseif number_inflammation_rois == 2
            inverted_noncoregistered_inflammation_scatter_1 = Heat_map_from_Aiforia(brain, block, inflammatory_marker, 1);
            noncoregistered_inflammation_scatter_1 = inverted_noncoregistered_inflammation_scatter_1(:,:,1);

            cd(directory.scripts)
            inverted_noncoregistered_inflammation_scatter_2 = Heat_map_from_Aiforia(brain, block, inflammatory_marker, 2);
            noncoregistered_inflammation_scatter_2 = inverted_noncoregistered_inflammation_scatter_2(:,:,1);
            close all

            noncoreg_inf_sum = noncoregistered_inflammation_scatter_1 + noncoregistered_inflammation_scatter_2;
            noncoregistered_inflammation_scatter = double((noncoreg_inf_sum(:,:,1) < 2));
        end
        
        noncoregistered_inflammation_scatter = imrotate(noncoregistered_inflammation_scatter, rotation);

        %% 3. coregister GFAP scatterplot to og iron image

        original_inflammation = imread(sprintf('CAA%d_%d_%s.png', brain, block, inflammatory_marker));
        original_iron = imresize(imread(sprintf('CAA%d_%d_Iron.png', brain, block)), size(coregistered_inflammation));
        [noncoreg_x, noncoreg_y, ~] = size(noncoregistered_inflammation_scatter);
        Rnoncoregistered_inflammation_scatter = imref2d([noncoreg_x, noncoreg_y]);

        [iron_x, iron_y, ~] = size(coregistered_inflammation);
        Rpartially_coregistered_tissue_map_inflammation = imref2d([iron_x, iron_y]);
        partially_coregistered_inflammation_scatter = imwarp(noncoregistered_inflammation_scatter, Rnoncoregistered_inflammation_scatter, tform, 'OutputView', Rpartially_coregistered_tissue_map_inflammation, 'FillValues', 0.5);
        inflammation_heat_map = imwarp(partially_coregistered_inflammation_scatter, D, 'FillValues', 0.5);

        %% 4. coregister iron screenshot to og iron (for both)

        for l = 1:2
            if l == 1
                number_rois = number_iron_rois;
            elseif l == 2
                number_rois = 1;
            end

            for k = 1 : number_rois
                cd(directory.tissue_screenshots)

                if l == 1
                    stain = 'Iron';
                elseif l == 2
                    stain = inflammatory_marker;
                end

                if k == 1
                    Aiforia_tissue_map = imread(sprintf('CAA%d_%d_%s_tissue.png', brain, block, stain));
                elseif k == 2
                    Aiforia_tissue_map = imread(sprintf('CAA%d_%d_%s_tissue_2.png', brain, block, stain));
                end

                green_channel = Aiforia_tissue_map(:,:,2);
                [green_channel_x, green_channel_y] = size(green_channel);
                no_outline_light = green_channel;
                no_outline_dark = green_channel;
                no_outside_outline_light = Aiforia_tissue_map;
                no_outside_outline_dark = Aiforia_tissue_map;

                reshaped_tissue_color_values = reshape(green_channel, green_channel_x * green_channel_y, 1);
                reshaped_tissue_color_values(reshaped_tissue_color_values < 21) = [];
                reshaped_tissue_color_values(reshaped_tissue_color_values > 200) = [];
                tissue_color = mean(reshaped_tissue_color_values);

                reshaped_background_color_values = reshape(green_channel, green_channel_x * green_channel_y, 1);
                reshaped_background_color_values(reshaped_background_color_values < 200) = [];
                background_color = mean(reshaped_background_color_values);

                for i = 1:green_channel_x
                    for j = 1:green_channel_y
                        if green_channel(i, j) <= 40
                            no_outline_dark(i,j) = tissue_color;
                        elseif green_channel(i,j) > 40 && green_channel(i,j) < 85
                            no_outline_dark(i,j) = background_color;
                            no_outside_outline_dark(i,j,:) = background_color;
                        end
                    end
                end

                clear i;
                clear j;

                for i = 1:green_channel_x
                    for j = 1:green_channel_y
                        if green_channel(i, j) <= 15
                            no_outline_light(i,j) = tissue_color;
                        elseif green_channel(i,j) > 15 && green_channel(i,j) < 110
                            no_outline_light(i,j) = background_color;
                            no_outside_outline_light(i,j,:) = background_color;
                        end
                    end
                end

                no_outline_filt_light = medfilt2(no_outline_light, [3,3]);
                no_outline_filt_dark = medfilt2(no_outline_dark, [3,3]);

                erased_outlines = figure('Name', 'Erased Outlines');
                subplot(1,2,1)
                imshow(no_outline_filt_light);
                title('Light')
                subplot(1,2,2)
                imshow(no_outline_filt_dark);
                title('Dark')
                erased_outlines.Position(3:4) = [900, 900];
                colorbar

                if l == 2
                    %rorl = input('Light or dark?   If light, reply 0; if dark, reply 1     ');
                    rorl = 0;
                    if rorl == 0
                        no_outline_filt = no_outline_filt_light;
                        no_outside_outline = no_outside_outline_light;
                    else
                        no_outline_filt = no_outline_filt_dark;
                        no_outside_outline = no_outside_outline_dark;
                    end
                else
                    no_outline_filt = no_outline_filt_light;
                    no_outside_outline = no_outside_outline_light;
                end

                %coregistered_inflammation_green = imwarp(original_inflammation(:,:,2), D);

                [og_inf_x, og_inf_y, ~] = size(original_inflammation);

                if l == 1
                    fixed = medfilt2(original_iron(:,:,2), [3,3]);
                    Roriginal_iron = imref2d(size(fixed));
                    moving = imresize(no_outline_filt, size(fixed));
                else
                    fixed = medfilt2(original_inflammation(:,:,2), [3,3]);
                    Roriginal_inflammation = imref2d([og_inf_x, og_inf_y]);
                    moving = imresize(no_outline_filt, [og_inf_x, og_inf_y]);
                end

                resized_Aiforia_tissue_map = imresize(Aiforia_tissue_map, size(fixed));
                Rresized_Aiforia_tissue_map = imref2d(size(moving));

                [optimizer, metric] = imregconfig('multimodal');
                optimizer.GrowthFactor = 1.01;
                optimizer.InitialRadius = 0.002;
                optimizer.MaximumIterations = 500;
                optimizer.Epsilon = 1.5e-6;

                moving = imhistmatch(moving,fixed);

                no_outside_outline_filt_blue = imresize(medfilt2(no_outside_outline(:,:,3), [3,3]), size(fixed));
                no_outside_outline_filt_red = imresize(medfilt2(no_outside_outline(:,:,1), [3,3]), size(fixed));

                if l == 1
                    if number_iron_rois == 1
                        tform_screenshot_iron = imregtform(moving, fixed, 'similarity', optimizer, metric);
                        coregistered_tissue_map_iron = imwarp(resized_Aiforia_tissue_map, Rresized_Aiforia_tissue_map, tform_screenshot_iron, 'OutputView', Roriginal_iron);
                        blue_channel_iron = imwarp(no_outside_outline_filt_blue, Rresized_Aiforia_tissue_map, tform_screenshot_iron, 'OutputView', Roriginal_iron);
                        red_channel_iron = imwarp(no_outside_outline_filt_red, Rresized_Aiforia_tissue_map, tform_screenshot_iron, 'OutputView', Roriginal_iron);
                    elseif number_iron_rois == 2
                        if k == 1
                            tform_screenshot_iron_1 = imregtform(moving, fixed, 'similarity', optimizer, metric);
                            coregistered_tissue_map_iron_1 = imwarp(resized_Aiforia_tissue_map, Rresized_Aiforia_tissue_map, tform_screenshot_iron_1, 'OutputView', Roriginal_iron);
                            blue_channel_iron_1 = imwarp(no_outside_outline_filt_blue, Rresized_Aiforia_tissue_map, tform_screenshot_iron_1, 'OutputView', Roriginal_iron);
                            red_channel_iron_1 = imwarp(no_outside_outline_filt_red, Rresized_Aiforia_tissue_map, tform_screenshot_iron_1, 'OutputView', Roriginal_iron);
                        elseif k == 2
                            tform_screenshot_iron_2 = imregtform(moving, fixed, 'similarity', optimizer, metric);
                            coregistered_tissue_map_iron_2 = imwarp(resized_Aiforia_tissue_map, Rresized_Aiforia_tissue_map, tform_screenshot_iron_2, 'OutputView', Roriginal_iron);
                            blue_channel_iron_2 = imwarp(no_outside_outline_filt_blue, Rresized_Aiforia_tissue_map, tform_screenshot_iron_2, 'OutputView', Roriginal_iron);
                            red_channel_iron_2 = imwarp(no_outside_outline_filt_red, Rresized_Aiforia_tissue_map, tform_screenshot_iron_2, 'OutputView', Roriginal_iron);
                        end
                    end
                else
                    tform_screenshot_inflammation = imregtform(moving, fixed, 'affine', optimizer, metric);
                    partially_coregistered_tissue_map_inflammation = imwarp(moving, Rresized_Aiforia_tissue_map, tform_screenshot_inflammation, 'OutputView', Roriginal_inflammation);
                    partially_coreg_blue_channel_inflammation = imwarp(no_outside_outline_filt_blue, Rresized_Aiforia_tissue_map, tform_screenshot_inflammation, 'OutputView', Roriginal_inflammation);
                    partially_coreg_red_channel_inflammation = imwarp(no_outside_outline_filt_red, Rresized_Aiforia_tissue_map, tform_screenshot_inflammation, 'OutputView', Roriginal_inflammation);

                    partially_coregistered_tissue_map_inflammation = imrotate(partially_coregistered_tissue_map_inflammation, rotation);
                    partially_coreg_blue_channel_inflammation = imrotate(partially_coreg_blue_channel_inflammation, rotation);
                    partially_coreg_red_channel_inflammation = imrotate(partially_coreg_red_channel_inflammation, rotation);

                    Rpartially_coregistered_tissue_map_inflammation = imref2d(size(partially_coregistered_tissue_map_inflammation));
                    noD_coregistered_tissue_map_inflammation = imwarp(partially_coregistered_tissue_map_inflammation, Rpartially_coregistered_tissue_map_inflammation, tform, 'OutputView', Roriginal_iron);

                    noD_blue_channel_inflammation = imwarp(partially_coreg_blue_channel_inflammation, Rpartially_coregistered_tissue_map_inflammation, tform, 'OutputView', Roriginal_iron);
                    noD_red_channel_inflammation = imwarp(partially_coreg_red_channel_inflammation, Rpartially_coregistered_tissue_map_inflammation, tform, 'OutputView', Roriginal_iron);

                    coregistered_tissue_map_inflammation = imwarp(noD_coregistered_tissue_map_inflammation, D);
                    blue_channel_inflammation = imwarp(noD_blue_channel_inflammation, D);
                    red_channel_inflammation = imwarp(noD_red_channel_inflammation, D);
                end

                %vars_to_clear = {'Rresized_Aiforia_tissue_map' 'resized_Aiforia_tissue_map' 'moving_x' 'moving_y' 'Rmoving' 'fixed_x' 'fixed_y' 'Roriginal_iron' 'optimizer' 'metric' 'no_outline_filt' 'fixed_3D' 'fixed' 'moving' 'tform_screenshot' 'i' 'j' 'k' 'Aiforia_tissue_map' 'green_channel' 'green_channel_x' 'green_channel_y' 'no_outline' 'reshaped_tissue_color_values' 'tissue_color' 'background_color' 'reshaped_background_color_values'};
                %clear(vars_to_clear{:})
                close all

            end
        end

        %% 5. filter coregistered screenshots to make masks (for both and combine)

        cd(directory.scripts)

        if number_iron_rois == 1
            iron_tissue_mask = extract_cortex_from_tissue_map(coregistered_tissue_map_iron, blue_channel_iron, red_channel_iron);
        elseif number_iron_rois == 2
            iron_tissue_mask_1 = extract_cortex_from_tissue_map(coregistered_tissue_map_iron_1, blue_channel_iron_1, red_channel_iron_1);
            iron_tissue_mask_2 = extract_cortex_from_tissue_map(coregistered_tissue_map_iron_2, blue_channel_iron_2, red_channel_iron_2);
            iron_tissue_mask_sum = iron_tissue_mask_1 + iron_tissue_mask_2;
            iron_tissue_mask = (iron_tissue_mask_sum > 0);
        end

        close all

        %% 6. apply masks to scatter plots to put NaNs in non-cortex areas

        inflammation_tissue_mask = extract_cortex_from_tissue_map(coregistered_tissue_map_inflammation, blue_channel_inflammation, red_channel_inflammation);

        if strcmp(inflammatory_marker, 'CD68') == 1
            primary_mask = inflammation_tissue_mask;
        else
            primary_mask = iron_tissue_mask;
        end

        [mask_size_x, mask_size_y] = size(primary_mask);

        for x = 1:mask_size_x
            for y = 1:mask_size_y
                if primary_mask(x,y) == 0
                    iron_heat_map(x,y) = NaN;
                    inflammation_heat_map(x,y) = NaN;
                end
                if primary_mask(x,y) == 0.5
                    iron_heat_map(x,y) = NaN;
                    inflammation_heat_map(x,y) = NaN;
                end
            end
        end

        %% 7. calculate densities

        matlab_pixel_size = 6.603822;

        patch_size_pixels = round(patch_size_microns / matlab_pixel_size);
        size_patch = [patch_size_pixels, patch_size_pixels];

        cd(directory.scripts)
        stat_iron = PatchGenerator_density_comparison(iron_heat_map, size_patch, size_patch, 'Zeros');
        stat_inflammation = PatchGenerator_density_comparison(inflammation_heat_map, size_patch, size_patch, 'Zeros');

        %% 9. make and save data tables and graphs

        iron_patch_densities = reshape(stat_iron, [1, numel(stat_iron)]);
        inflammation_patch_densities = reshape(stat_inflammation, [1, numel(stat_inflammation)]);
        finalfigure = figure;
        finalfigure.Position = [1,1,1500, 482];
        graph = subplot(2,6,[1,2,7,8]);
        graph.Position = graph.Position + [0 0 0.015 0];
        density_comparison_scatter = scatter(iron_patch_densities, inflammation_patch_densities, 25, '.', 'black');
        ylim([0, (max(inflammation_patch_densities)*(5/3))])
        patch_size_squared = patch_size_microns * patch_size_microns;
        xlabel('Iron density (% area)');
        ylabel(sprintf('%s density (%% area)', inflammatory_marker));
        title(sprintf('CAA%d__%d', brain, block));

        linear_model = fitlm(iron_patch_densities', inflammation_patch_densities');
        coefs = linear_model.Coefficients.Estimate;
        y_intercept = coefs(1);
        slope = coefs(2);
        refline(slope, y_intercept);
        R_squared = linear_model.Rsquared.Ordinary;

        no_nan_iron_patch_densities = iron_patch_densities';
        no_nan_inflammation_patch_densities = inflammation_patch_densities';
        [~,number_of_iron_patches] = size(iron_patch_densities);

        for i = number_of_iron_patches:-1:1
            if  isnan(iron_patch_densities(i)) == 1 || isnan(inflammation_patch_densities(i)) == 1
                no_nan_iron_patch_densities(i) = [];
                no_nan_inflammation_patch_densities(i) = [];
            end
        end

        [Pearson_coefficient, Pearson_pval] = corr(no_nan_iron_patch_densities, no_nan_inflammation_patch_densities, 'Type', 'Pearson');
        [Spearman_coefficient, Spearman_pval] = corr(no_nan_iron_patch_densities, no_nan_inflammation_patch_densities, 'Type', 'Spearman');

        caption = ['slope = ', sprintf('%.4f', slope)];
        caption = [caption newline 'R^2 = ',sprintf('%.4f', R_squared)];
        caption = [caption newline 'Pearson''s linear correlation coefficient = ',sprintf('%.4f', Pearson_coefficient), '     p = ', sprintf('%.4e', Pearson_pval)];
        caption = [caption newline 'Spearman''s \rho = ',sprintf('%.4f', Spearman_coefficient), '     p = ', sprintf('%.4e', Spearman_pval)];
        annotation('textbox',[.15 0.9 0 0],'string',caption,'FitBoxToText','on','EdgeColor','black','BackgroundColor','white')

        subplot(2,5,3)
        imshowpair(iron_heat_map, original_iron);
        title(sprintf('CAA%d__%d_Iron', brain, block));
        axis image;
        axis off;

        subplot(2,5,4)
        imshow(stat_iron(:,:),[0 80]);
        title(sprintf('CAA%d__%d_Iron', brain, block));
        axis image;
        axis off;
        colormap(gca, jet);
        colorbar;

        subplot(2,5,5);
        imshowpair(original_iron, coregistered_inflammation);
        %imshowpair(bw_iron, bw_inflammation);
        %title({'Coregistration', sprintf('Dice coefficient=%f', section_similarity)})
        axis image;
        axis off;

        subplot(2,5,8)
        imshowpair(inflammation_tissue_mask, coregistered_inflammation);
        title(sprintf('CAA%d__%d_%s', brain, block, inflammatory_marker));
        axis image;
        axis off;

        subplot(2,5,9);
        imshow(stat_inflammation,[0 100]);
        title(sprintf('CAA%d__%d_%s', brain, block, inflammatory_marker));
        axis image;
        axis off;
        colormap(gca, jet);
        colorbar;

        subplot(2,5,10)
        if strcmp(inflammatory_marker, 'CD68') == 1
            imshowpair(iron_heat_map, primary_mask)
            title('Iron Heat Map on Inflammation Mask')
        else
            imshowpair(inflammation_heat_map, primary_mask)
            title('Inflammation Heat Map on Iron Mask')
        end
        axis image
        axis off

        cd(directory.save)
        density_figure_save_name = sprintf('CAA%d_%d_%s_and_Iron_density_figure.png', brain, block, inflammatory_marker);
        saveas(gcf, density_figure_save_name);

        all_variables_save_name = sprintf('CAA%d_%d_%s_and_Iron_density_comparison_all_variables.mat', brain, block, inflammatory_marker);
        save(all_variables_save_name);
        crucial_variables_save_name = sprintf('CAA%d_%d_%s_and_Iron_density_comparison_crucial_variables.mat', brain, block, inflammatory_marker);
        save(crucial_variables_save_name, 'stat_iron', 'stat_inflammation', 'Spearman_coefficient', 'rotation', 'R_squared', 'Pearson_coefficient', 'original_iron', 'original_inflammation', 'linear_model', 'iron_tissue_mask', 'iron_heat_map', 'inflammation_heat_map');

        cd(directory.scripts)
        clearvars -except brain block inflammatory_marker patch_size_microns q

    end
end

%end
