function tissue_mask = extract_cortex_from_tissue_map(Aiforia_tissue_map, blue_channel, red_channel)
% Used in density_comparison

%% Get sizes
[channel_x, channel_y, ~] = size(Aiforia_tissue_map);
[br_channel_x, br_channel_y, ~] = size(blue_channel);

%% Preallocate
tissue_map_mask_light = NaN([br_channel_x, br_channel_y, 1]);
tissue_map_mask_dark = NaN([br_channel_x, br_channel_y, 1]);

%% Set up comparison figure
Light = figure('Name', 'Light');
subplot(2, 2, 1)
imshow(blue_channel)
title('Blue Channel')
colorbar

Dark = figure('Name', 'Dark');
subplot(2, 2, 1)
imshow(red_channel)
title('Red Channel')
colorbar

%% Make 2 masks, one with filtering for lighter slides and one for darker
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

%% Smooth (no one-pixel aberrations)
tissue_map_mask_light = medfilt2(tissue_map_mask_light, [3,3]);
tissue_map_mask_dark = medfilt2(tissue_map_mask_dark, [3,3]);

%% Filter again
for i = 1:br_channel_x
    for j = 1:br_channel_y
        if blue_channel(i, j) <= 15
            tissue_map_mask_light(i,j) = 0;
        elseif blue_channel(i, j) >= 180
            %elseif blue_channel(i, j) >= 140
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
        elseif red_channel(i, j) >= 105
            tissue_map_mask_dark(i,j) = 0;
        else
            tissue_map_mask_dark(i,j) = 1;
        end
    end
end

%% Smooth again
filtered_tissue_map_mask_light = medfilt2(tissue_map_mask_light, [15,15]);
filtered_tissue_map_mask_dark = medfilt2(tissue_map_mask_dark, [15,15]);

%% Resize
resized_tissue_map_mask_light = imresize(filtered_tissue_map_mask_light, [channel_x, channel_y]);
resized_tissue_map_mask_dark = imresize(filtered_tissue_map_mask_dark, [channel_x, channel_y]);
resized_blue_channel = imresize(blue_channel, [channel_x, channel_y]);
resized_red_channel = imresize(red_channel, [channel_x, channel_y]);

%% Make figure for user to see the 2 options
Overlays = figure('Name', 'Overlays');
subplot(1,2,1)
imshowpair(resized_blue_channel, resized_tissue_map_mask_light);
title('Light')
subplot(1,2,2)
imshowpair(resized_red_channel, resized_tissue_map_mask_dark);
title('Dark')
Overlays.Position(3:4) = [900, 900];

%% Ask user for input on choosing light or dark mask
rorl = input('Light or dark?   If light, reply 0; if dark, reply 1     ');
% default rorl is 0
if rorl == 0
    tissue_mask = resized_tissue_map_mask_light;
elseif rorl == 1
    tissue_mask = resized_tissue_map_mask_dark;
end
