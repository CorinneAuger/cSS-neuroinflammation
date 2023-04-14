function heat_map = Heat_map_from_Aiforia(brain, block, stain, roi)
% NOTE: if you want to use this function independently, use scaled_down_no_scatter_heat_map instead.
% Makes an iron scatter plot with the coordinates exported from Aiforia but underestimates the count of objects that are close together.
% This function is used in density_comparison.m just to make it run, but its output is replaced in one_pixel_density_comparison.

% Arguments
%   brain: number (ex. for CAA3_7_GFAP, brain = 3)
%   block: number (ex. for CAA3_7_GFAP, block = 7)
%   stain: name of stain in quotes (ex. for CAA3_7_GFAP, stain = 'GFAP')
%   roi: number of cortex rois in Aiforia. Usually there will be only one, but if there are non-contiguous sections of cortex, there may be multiple. 
%       Try to avoid having multiple when drawing new rois.

%% Input directories
directory.IA_details = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/IA details';
directory.image_sizes_spreadsheets = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Image sizes spreadsheets';
directory.original_images = '/Volumes/Corinne hard drive/cSS project/Original images';

%% Convert numbers to strings
brain_str = num2str(brain);
block_str = num2str(block);
roi_str = num2str(roi);
cd(directory.IA_details)

%% Import Aiforia coordinates
if roi == 1
    Aiforia_details_sheet_name = join(['IA_details__CAA', brain_str, '_', block_str, '_', stain, '.xlsx']);
else
    Aiforia_details_sheet_name = join(['IA_details__CAA', brain_str, '_', block_str, '_', stain, '_', roi_str, '.xlsx']);
end

%if number_roi == 1
    %Aiforia_details_sheet_name = join(['IA_details__CAA', brain_str, '_', block_str, '_', stain, '.xlsx']);
%elseif number_roi == 2
    %Aiforia_details_sheet_name = join(['IA_details__CAA', brain_str, '_', block_str, '_', stain, '_2.xlsx']);
%end

Aiforia_details_table = readtable(Aiforia_details_sheet_name);
Aiforia_details_matrix = table2array(Aiforia_details_table(:,22:23));

%% Take NaNs out of object coordinate matrix
object_centers_x_with_NaNs = Aiforia_details_matrix(:, 1);
object_centers_x = object_centers_x_with_NaNs(~isnan(object_centers_x_with_NaNs));
object_centers_y_with_NaNs = Aiforia_details_matrix(:, 2);
object_centers_y = object_centers_y_with_NaNs(~isnan(object_centers_y_with_NaNs));

%% Make scatter plot
figure;
og_scatter = scatter(object_centers_x, object_centers_y, 1, '.', 'black');

cd(directory.image_sizes_spreadsheets)

%% Try to make sizes representative of the size of the original image (doesn't work because of the weird MATLAB scatter plot function)
if strcmp(stain, 'CD68') == 1
    pixel_size = 0.441131; %size of one Aiforia pixel in um
elseif strcmp(stain, 'GFAP') == 1
    pixel_size = 0.455228;
elseif strcmp(stain, 'Iron') == 1
    pixel_size = 0.455436;
end

image_size_sheet_name = join(['Aiforia_image_sizes_', stain, '.xlsx']);
image_size_matrix = xlsread(image_size_sheet_name);
% column 1 is width; column 2 is height

if block == 1
    row_number = ((brain - 1)*4) + 1;
elseif block == 4
    row_number = ((brain - 1)*4) + 2;
elseif block == 5
    row_number = ((brain - 1)*4) + 3;
elseif block == 7
    row_number = brain * 4;
end

width = image_size_matrix(row_number, 1);
height = image_size_matrix(row_number, 2);

% Convert to microns
x_measurement = pixel_size * width;
y_measurement = pixel_size * height;
xlim([0, x_measurement]);
ylim([0, y_measurement]);

set(gca,'xtick',[]);
set(gca,'ytick',[]);
axis off;

%% Convert from frame (MATLAB's way of displaying scatter plot) to matrix
frame = getframe;
unflipped_heat_map = frame2im(frame);
heat_map = double(imbinarize(flip(unflipped_heat_map, 1)));
imshow(heat_map);

cd(directory.original_images)
%og_image = imread(sprintf('CAA%d_%d_%s.png', brain, block, stain));
%[og_x, og_y, ~] = size(og_image);
%resized_heat_map = imresize(heat_map, [og_x, og_y]);
%resized_heat_map = double(imbinarize(resized_heat_map));

end
