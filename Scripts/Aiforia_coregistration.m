%% Coregisters NanoZoomer scans of two serial sections with different stains

function [rotation, D, tform, coregistered_inflammation] = Aiforia_coregistration(brain, block, fixed_image_stain, moving_image_stain)

cd '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Original images'

% import images and convert to gray
fixed_3D = imread(sprintf('CAA%d_%d_%s.png', brain, block, fixed_image_stain));
unresized_fixed = rgb2gray(fixed_3D);
moving_3D = imread(sprintf('CAA%d_%d_%s.png', brain, block, moving_image_stain));
moving = rgb2gray(moving_3D);
%figure; 
%imshowpair(fixed,moving,'montage');
%rotation = input('Rotate 180 degrees?   If no, reply 0; if yes, reply 1     '); 

cd '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Image sizes spreadsheets'

% import spreadsheets with sizes of each image
image_size_sheet_name_moving = join(['Aiforia_image_sizes_', moving_image_stain, '.xlsx']);
image_size_matrix_moving = xlsread(image_size_sheet_name_moving);
image_size_sheet_name_fixed = join(['Aiforia_image_sizes_', fixed_image_stain, '.xlsx']);
image_size_matrix_fixed = xlsread(image_size_sheet_name_fixed);
% column 1 is width; column 2 is height; column 3 is rotation; column 4 is how many rois

% look up whether sections need to be rotated to align in spreadsheet (make spreadsheet manually)
if block == 1
    row_number = ((brain - 1)*4) + 1;
elseif block == 4
    row_number = ((brain - 1)*4) + 2;
elseif block == 5
    row_number = ((brain - 1)*4) + 3;
elseif block == 7
    row_number = brain * 4;
end

rotation = image_size_matrix_moving(row_number, 3);

% look up image sizes
spreadsheet_width = image_size_matrix_fixed(row_number, 1);
spreadsheet_height = image_size_matrix_fixed(row_number, 2);

% shrink images and resize to one another
scaled_width = spreadsheet_width/14.5;
scaled_height = spreadsheet_height/14.5;
fixed = imresize(unresized_fixed, [scaled_height, scaled_width]);

% rotate if needed
if rotation == 1
    moving = imrotate(moving, 180);
elseif rotation == 2
    moving = imrotate(moving, 90);
else 
end 

close;

% set up imregtform function
[moving_x, moving_y, ~] = size(moving);        
Rmoving = imref2d([moving_x, moving_y]);
[fixed_x, fixed_y, ~] = size(fixed);  
Rfixed = imref2d([fixed_x, fixed_y]);
[optimizer, metric] = imregconfig('multimodal');

% modify optimizer settings
optimizer.GrowthFactor = 1.01;
optimizer.InitialRadius = 0.002;
optimizer.MaximumIterations = 600;
optimizer.Epsilon = 1.5e-6;

% perform coregistration
moving = imhistmatch(moving,fixed); 
tform = imregtform(moving, fixed, 'affine', optimizer, metric); 

% apply transformation to moving section
affine_coreg_heat_map = imwarp(moving, Rmoving, tform, 'OutputView', Rfixed);

% display coregistered image overlayed on fixed image 
%figure; 
%imshowpair(fixed,affine_coreg_heat_map);

%% non-rigid transformation - perform after rigid transformation above to improve registration (note: this is very slow--7 mins per slide) 

[D,coregistered_inflammation] = imregdemons(affine_coreg_heat_map,fixed,[1000 400 400],'AccumulatedFieldSmoothing',3, 'DisplayWaitbar',true); % number of iterations at each pyramidal layer 
figure;
imshowpair(fixed,coregistered_inflammation); 
close all

%filename = sprintf('CAA%d_%d_%s_iron-coregistered_heat_map.tif', brain, block, inflammatory_marker);
%imwrite(squeeze(transformed_inflammation_heat_map), filename, 'WriteMode', 'append',  'Compression', 'none');

end