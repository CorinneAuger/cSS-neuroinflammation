function tissue_mask = extract_GFAP_cortex_from_tissue_map(Aiforia_tissue_map, blue_channel, red_channel)
% For use in edge_analysis.

%% Input directories
directory.scripts = '/Volumes/Corinne hard drive/cSS project/Scripts/Layer analysis';

%% Get sizes
[channel_x, channel_y, ~] = size(Aiforia_tissue_map);
[br_channel_x, br_channel_y, ~] = size(blue_channel);

%% Preallocate light and dark masks
tissue_map_mask_light = NaN([br_channel_x, br_channel_y, 1]);
tissue_map_mask_dark = NaN([br_channel_x, br_channel_y, 1]);

%Light = figure('Name', 'Light');
%subplot(2, 2, 1)
%imshow(blue_channel)
%title('Blue Channel')
%colorbar

%Dark = figure('Name', 'Dark');
%subplot(2, 2, 1)
%imshow(red_channel)
%title('Red Channel')
%colorbar

%% Generate light and dark masks
for m = 1:br_channel_x
    for n = 1:br_channel_y
        if blue_channel(m,n) > 15 && blue_channel(m,n) < 65
            tissue_map_mask_light(m,n) = 150;
        end
        if red_channel(m,n) > 15 && red_channel(m,n) < 65
            tissue_map_mask_dark(m,n) = 150;
        end
    end
end

%% Filter
tissue_map_mask_light = medfilt2(tissue_map_mask_light, [3,3]);
tissue_map_mask_dark = medfilt2(tissue_map_mask_dark, [3,3]);

for i = 1:br_channel_x
    for j = 1:br_channel_y
        if blue_channel(i, j) <= 15
            tissue_map_mask_light(i,j) = 0;
        elseif blue_channel(i, j) >= 120
            tissue_map_mask_light(i,j) = 0;
        else
            tissue_map_mask_light(i,j) = 1;
        end
    end
end

for i = 1:br_channel_x
    for j = 1:br_channel_y
        if red_channel(i, j) <= 20
            tissue_map_mask_dark(i,j) = 0;
        elseif red_channel(i, j) >= 112
            tissue_map_mask_dark(i,j) = 0;
        else
            tissue_map_mask_dark(i,j) = 1;
        end
    end
end

%% Filter again
filtered_tissue_map_mask_light = medfilt2(tissue_map_mask_light, [15,15]);
filtered_tissue_map_mask_dark = medfilt2(tissue_map_mask_dark, [15,15]);

%% Resize
resized_tissue_map_mask_light = imresize(filtered_tissue_map_mask_light, [channel_x, channel_y]);
resized_tissue_map_mask_dark = imresize(filtered_tissue_map_mask_dark, [channel_x, channel_y]);
resized_blue_channel = imresize(blue_channel, [channel_x, channel_y]);
resized_red_channel = imresize(red_channel, [channel_x, channel_y]);

%se = strel('square',12);
%dilated_tissue_map_mask_light = imdilate(filtered_tissue_map_mask_light, se);
%dilated_tissue_map_mask_dark = imdilate(filtered_tissue_map_mask_dark, se);

%% Display figure for user
Overlays = figure('Name', 'Overlays');
subplot(1,2,1)
imshowpair(resized_blue_channel, resized_tissue_map_mask_light);
title('Light')
subplot(1,2,2)
imshowpair(resized_red_channel, resized_tissue_map_mask_dark);
title('Dark')
Overlays.Position(3:4) = [900, 900];

%% User chooses better version of mask
rorl = input('Light or dark?   If light, reply 0; if dark, reply 1     ');
if rorl == 0
    tissue_mask = resized_tissue_map_mask_light;
elseif rorl == 1
    tissue_mask = resized_tissue_map_mask_dark;
end

cd(directory.scripts)
end
