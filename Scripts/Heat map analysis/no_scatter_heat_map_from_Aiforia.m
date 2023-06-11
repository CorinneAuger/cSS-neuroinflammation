function heat_map = no_scatter_heat_map_from_Aiforia(cohort, directory, brain, block, stain, roi, region)
% Makes a matrix with the Aiforia coordinates of detected objects.
% Used in scaled_down_no_scatter_heat_map to generate the giant scatter plot matrix.

% Arguments
%   cohort: 'CAA' or 'ADRC'
%   directory: struct of paths. Needs to include IA_details, images_sizes_spreadsheets, scripts, and original_images.
%   brain: number (ex. for CAA3_7_GFAP, brain = 3)
%   block: number (ex. for CAA3_7_GFAP, block = 7)
%   stain: name of stain in quotes (ex. 'Iron')
%   roi: number of rois for the region (usually 1)
%   region: if cohort is 'CAA', enter []. If cohort is 'ADRC', enter 'hc', 'phc', 'ec', or 'am'

%% Inport Aiforia coordinates
if strcmp(cohort, 'CAA')
    if roi == 1
        IA_details_sheet_name = sprintf('IA_details__CAA%d_%d_%s.xlsx', brain, block, stain);
    else
        IA_details_sheet_name = sprintf('IA_details__CAA%d_%d_%s_%d.xlsx', brain, block, stain, roi);
    end
elseif strcmp(cohort, 'ADRC')
    IA_details_sheet_name = sprintf('IA_details__%d_%d_%s_%s.xlsx', brain, block, region, stain);
end

cd(directory.IA_details)
Aiforia_details_table = readtable(IA_details_sheet_name);

% Find which table columns have object coordinates
column_names = Aiforia_details_table.Properties.VariableNames;
x_col = find(contains(column_names, 'ObjectCenterX__m_'));
y_col = find(contains(column_names, 'ObjectCenterY__m_'));

Aiforia_details_matrix = table2array(Aiforia_details_table(:, x_col:y_col));

clear column_names x_col y_col

%% Take NaNs out of object coordinate matrix
object_centers_x_with_NaNs = Aiforia_details_matrix(:, 1);
object_centers_x = object_centers_x_with_NaNs(~isnan(object_centers_x_with_NaNs));
object_centers_y_with_NaNs = Aiforia_details_matrix(:, 2);
object_centers_y = object_centers_y_with_NaNs(~isnan(object_centers_y_with_NaNs));

%% Get pixel size
if strcmp(cohort, 'CAA')
    if strcmp(stain, 'CD68') == 1
        pixel_size = 0.441131; %size of one Aiforia pixel in um
    elseif strcmp(stain, 'GFAP') == 1
        pixel_size = 0.455228;
    elseif strcmp(stain, 'Iron') == 1
        pixel_size = 0.455436;
    end
elseif strcmp(cohort, 'ADRC')
    cd(directory.image_sizes_spreadsheets)
    pixel_sizes_table = readtable('Aiforia_specs_ADRC.xlsx');
    row = find(strcmp(pixel_sizes_table.Stain, stain));
    pixel_size = pixel_sizes_table{row, 2};
end

%% Get image size in microns
cd(directory.scripts)
[width, height, ~] = get_image_size_from_spreadsheet(cohort, directory, brain, block, stain);

% Convert to microns
x_measurement = round(pixel_size * height);
y_measurement = round(pixel_size * width);

%% Preallocate image matrix
heat_map = ones(x_measurement, y_measurement);

for i = 1:numel(object_centers_x)
    x_coordinate = round(object_centers_x(i));
    y_coordinate = round(object_centers_y(i));

    heat_map(y_coordinate, x_coordinate) = 0;

    clear x_coordinate y_coordinate
end

%% Display scatter plot
figure
imshow(heat_map)

end
