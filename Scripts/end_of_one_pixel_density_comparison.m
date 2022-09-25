%% End of pixel density comparison
% Used in check_density_comparison_files to generate new final figure with new primary mask

if exist('skip_first_steps', 'var') == 0 || skip_first_steps == 1
elseif skip_first_steps == 1
    
    %% Apply primary mask
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
end

%% Calculate densities
clear stat_iron stat_inflammation

matlab_pixel_size = 6.603822; %microns
patch_size_pixels = round(patch_size_microns / matlab_pixel_size); % = 76
size_patch = [patch_size_pixels, patch_size_pixels];

cd(scripts_directory)
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
if strcmp(inflammatory_marker, 'CD68') == 1
    imshowpair(figure_only_inflammation_heat_map, primary_mask)
    title('Iron Heat Map on Inflammation Mask')
else
    imshowpair(figure_only_iron_heat_map, primary_mask)
    title('Inflammation Heat Map on Iron Mask')
end
axis image
axis off