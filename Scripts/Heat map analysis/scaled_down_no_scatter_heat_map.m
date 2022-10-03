function final_heat_map = scaled_down_no_scatter_heat_map(scale_image, brain, block, stain, roi)
% Makes an accurate scatter plot with the object counts from the region each pixel represents in Aiforia.
% Used in one_pixel_density_comparison.

%% Input directories
directory.scripts = '/Volumes/Corinne hard drive/cSS project/Scripts/Heat map analysis';

%% Generate original giant scatter plot
cd(directory.scripts);
giant_plot = no_scatter_heat_map_from_Aiforia(brain, block, stain, roi);

%% Get sizes of giant heat map and image to which we're trying to scale it
[dimx, dimy, ~] = size(giant_plot);
[og_x, og_y, ~] = size(scale_image);

%% Get patch and jump sizes
size_patch = [ceil(dimx/og_x), ceil(dimy/og_y)];
size_jump = size_patch;

%% Patch generator
% This divides the original scatter plot into patches with dimensions that are whole numbers of pixels, rounding down in size if necessary.
% Each patch's value is the number of objects that were in it.
cd(directory.scripts)
almost_scaled_heat_map = PatchGenerator_density_comparison(giant_plot, size_patch, size_jump, 'Zeros');

%% Resize final heat map (resizing up slightly because patch size rounded up) to fit the size of the coregistered images.
% The 'nearest' parameter keeps everything at zeros and ones.
scaled_heat_map = imresize(almost_scaled_heat_map, [og_x, og_y], 'nearest');

%% Calculate ratio of number of points in scaled and almost scaled versions
almost_scaled_number_of_points = nansum(nansum(almost_scaled_heat_map));
scaled_number_of_points = nansum(nansum(scaled_heat_map));
points_ratio = scaled_number_of_points/almost_scaled_number_of_points;

%% Calculate the same ratio for the total number of pixels (sanity check)
% Theoretically, points_ratio = pixels_ratio
almost_scaled_number_of_pixels = numel(almost_scaled_heat_map);
scaled_number_of_pixels = numel(scaled_heat_map);
pixels_ratio = scaled_number_of_pixels/almost_scaled_number_of_pixels;

%% Get final heat map by using the points ratio to make all the points worth slightly less
final_heat_map = scaled_heat_map/points_ratio;

%% Make NaNs at edges into 0s
[size_x, size_y] = size(final_heat_map);

for x = 1:size_x
    for y = 1:size_y
        if isnan(final_heat_map(x,y))
            final_heat_map(x,y) = 0;
        end
    end
end

close all

end
