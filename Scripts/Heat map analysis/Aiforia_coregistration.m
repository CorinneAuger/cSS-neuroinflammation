function [rotation, D, tform, coregistered_stain, fixed, moving] = Aiforia_coregistration(cohort, directory, brain, block, fixed_image_stain, moving_image_stain)

%% Coregisters NanoZoomer scans of two serial sections with different stains
% For use in density_comparison.

% Arguments
%   cohort: 'CAA' or 'ADRC'
%   directory: struct of paths. Needs to include scripts, images_sizes_spreadsheets, and original_images.
%   brain: number (ex. for CAA3_7_GFAP, brain = 3)
%   block: number (ex. for CAA3_7_GFAP, block = 7)
%   fixed_image_stain: name of stain to which the other stain will be coregistered, in quotes (ex. 'Iron')
%   moving_image_stain: name of stain that will be coregistered to the other stain, in quotes (ex. 'GFAP')

%% Get slide names
if strcmp(cohort, 'CAA')
    fixed_slide_name = sprintf('CAA%d_%d_%s.png', brain, block, fixed_image_stain);
    moving_slide_name = sprintf('CAA%d_%d_%s.png', brain, block, moving_image_stain);
elseif strcmp(cohort, 'ADRC')
    fixed_slide_name = sprintf('%d_%d_%s.png', brain, block, fixed_image_stain);
    moving_slide_name = sprintf('%d_%d_%s.png', brain, block, moving_image_stain);
end

%% Import images and convert to gray
cd(directory.original_images)
fixed_3D = imread(fixed_slide_name);
unresized_fixed = rgb2gray(fixed_3D);
moving_3D = imread(moving_slide_name);
moving = rgb2gray(moving_3D);

%% Look up image size and rotation
cd(directory.scripts)
[spreadsheet_width, spreadsheet_height, rotation, ~] = get_image_size_from_spreadsheet(cohort, directory, brain, block, moving_image_stain);

%% Shrink images and resize to one another
if strcmp(cohort, 'CAA')
    scaled_width = spreadsheet_width/14.5;
    scaled_height = spreadsheet_height/14.5;
    fixed = imresize(unresized_fixed, [scaled_height, scaled_width]);
else
    fixed = unresized_fixed;
end

% Rotate if needed
moving = imrotate(moving, rotation);

%% Set up imregtform function
[moving_x, moving_y, ~] = size(moving);
Rmoving = imref2d([moving_x, moving_y]);
[fixed_x, fixed_y, ~] = size(fixed);
Rfixed = imref2d([fixed_x, fixed_y]);
[optimizer, metric] = imregconfig('multimodal');

%% Modify optimizer settings
optimizer.GrowthFactor = 1.01;
optimizer.Epsilon = 1.5e-6;
optimizer.InitialRadius = 0.002;
optimizer.MaximumIterations = 600;

%% Perform coregistration
moving = imhistmatch(moving,fixed);
tform = imregtform(moving, fixed, 'affine', optimizer, metric);

%% Apply transformation to moving section
affine_coreg_moving = imwarp(moving, Rmoving, tform, 'OutputView', Rfixed);

%% Display coregistered image overlayed on fixed image
% figure;
% imshowpair(fixed,affine_coreg_moving);

%% Non-rigid transformation - perform after rigid transformation above to improve registration (note: this is very slow--7 mins per slide)
[D,coregistered_stain] = imregdemons(affine_coreg_moving,fixed,[1000 400 400],'AccumulatedFieldSmoothing',3, 'DisplayWaitbar',true); % number of iterations at each pyramidal layer
figure;
imshowpair(fixed,coregistered_stain);
close all

end
