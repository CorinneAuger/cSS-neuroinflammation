function heat_map = no_scatter_heat_map_from_Aiforia(brain, block, stain, roi)

brain_str = num2str(brain);
block_str = num2str(block);
roi_str = num2str(roi);
cd '/Users/corinneauger/Documents/Aiforia heatmap coregistration/IA details';

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

object_centers_x_with_NaNs = Aiforia_details_matrix(:, 1);
object_centers_x = object_centers_x_with_NaNs(~isnan(object_centers_x_with_NaNs));
object_centers_y_with_NaNs = Aiforia_details_matrix(:, 2);
object_centers_y = object_centers_y_with_NaNs(~isnan(object_centers_y_with_NaNs));

cd '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Image sizes spreadsheets'

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

% convert to microns
x_measurement = round(pixel_size * height); 
y_measurement = round(pixel_size * width);

% preallocate image matrix
heat_map = ones(x_measurement, y_measurement);

for i = 1:numel(object_centers_x)
    x_coordinate = round(object_centers_x(i));
    y_coordinate = round(object_centers_y(i));
    
    heat_map(y_coordinate, x_coordinate) = 0;
    
    clear x_coordinate y_coordinate
end

figure
imshow(heat_map)

end