function [tissue_mask, tissue_map_mask_light] = extract_tissue(image, cortex_mask, stain)

%% Input directories
directory.original_images = '/Volumes/Corinne hard drive/cSS project/Original images';
directory.scripts = '/Volumes/Corinne hard drive/cSS project/Scripts/Layer analysis';

cd(directory.original_images)

%% Set up input image
original_green = image;
[channel_x, channel_y, ~] = size(original_green);

%% Preallocate
tissue_map_mask_light = NaN([channel_x, channel_y, 1]);

%% Set mask thresholds
if strcmp(stain, 'GFAP') == 1
    cutoff = 200;
elseif strcmp(stain, 'Iron') == 1
    cutoff = 225;
elseif strcmp(stain, 'CD68') == 1
    cutoff = 230;
end

%% Make masks
for i = 1:channel_x
    for j = 1:channel_y
        if original_green(i, j) <= 15
            tissue_map_mask_light(i,j) = 0;
        elseif original_green(i,j) >= cutoff
            tissue_map_mask_light(i,j) = 0;
        else
            tissue_map_mask_light(i,j) = 1;
        end
    end
end

%% Median filtering, filling small gaps
se = strel('square', 150);
dilated_tissue_map_mask_light = ~imdilate(1-medfilt2(tissue_map_mask_light, [15,15]),se);
filled = imfill(dilated_tissue_map_mask_light, 'holes');

%% Make sure everything in the cortex mask from the density comparison is also in the median filtered mask
for i = 1:channel_x
    for j = 1:channel_y
        if cortex_mask(i,j) == 1 
            filled(i,j) = 1;
        end
    end
end

%% Median filter again
filtered_tissue_map_mask_light = imfill(medfilt2(filled, [15,15]), 'holes');

%% Resize
tissue_mask_with_lepto = imresize(filtered_tissue_map_mask_light, [channel_x, channel_y]);

%% Fill gaps
tissue_mask = imfill(tissue_mask_with_lepto, 'holes');

end