function [tissue_mask, tissue_map_mask_light] = extract_tissue(image, cortex_mask, stain)

%% Input directories
directory.original_images = 
directory.scripts = 

cd '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Original images'
%image = original_image;
%original_green = image(:,:,2);
original_green = image;

[channel_x, channel_y, ~] = size(original_green);

tissue_map_mask_light = NaN([channel_x, channel_y, 1]);

if strcmp(stain, 'GFAP') == 1
    cutoff = 200;
elseif strcmp(stain, 'Iron') == 1
    cutoff = 225;
elseif strcmp(stain, 'CD68') == 1
    cutoff = 230;
end

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

se = strel('square', 150);
dilated_tissue_map_mask_light = ~imdilate(1-medfilt2(tissue_map_mask_light, [15,15]),se);
filled = imfill(dilated_tissue_map_mask_light, 'holes');

for i = 1:channel_x
    for j = 1:channel_y
        if cortex_mask(i,j) == 1 
            filled(i,j) = 1;
        end
    end
end

filtered_tissue_map_mask_light = imfill(medfilt2(filled, [15,15]), 'holes');
tissue_mask_with_lepto = imresize(filtered_tissue_map_mask_light, [channel_x, channel_y]);
tissue_mask = imfill(tissue_mask_with_lepto, 'holes');

end