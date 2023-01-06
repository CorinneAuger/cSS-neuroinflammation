function [] = edge_analysis(brain, block, stain)
% Compares object density between consecutive artificial 1000um layers of the cortex, one section at a time.
% First step of layer analysis.
% Sections analyzed one by one.
% Have to run end_of_layer_analysis after to modernize. It runs on the whole batch.

%% Input brain, block, stain if not running in a loop (can comment these out if being looped)
brain = 3;
block = 1;
stain = 'Iron';

close all
clearvars -except  brain block stain

% Inflammatory marker
if strcmp(stain, 'CD68') || strcmp(stain, 'Iron')
    inflammatory_marker = 'CD68';
elseif strcmp(stain, 'GFAP')
    inflammatory_marker = 'GFAP';
end

%% Input directories
directory.input = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel density comparison/%s/All variables', inflammatory_marker);
directory.scripts = '/Volumes/Corinne hard drive/cSS project/Scripts/Layer analysis';
directory.save = sprintf('/Users/corinneauger/Documents/Aiforia heatmap coregistration/Saved data/Edge analysis/%s 1000um', stain);
directory.save_cortex_figure = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/Edge analysis/Individual slides/%s 1000um/Cortex figures', stain);

clearvars -except brain block stain q directory inflammatory_marker
close all

%% Load variables
cd(directory.input)
variables_file = sprintf('CAA%d_%d_%s_and_Iron_1pixel_density_comparison_all_variables.mat', brain, block, inflammatory_marker);

if strcmp(stain, 'GFAP') == 1 || strcmp(stain, 'CD68') == 1
    % Load
    load(variables_file, 'stat_iron', 'inflammation_heat_map', 'stat_inflammation', 'coregistered_inflammation', 'inflammation_tissue_mask');
    
    % Rename so variables are standardized
    heat_map = inflammation_heat_map;
    original_image = coregistered_inflammation;
    cortex_mask = inflammation_tissue_mask;
    
elseif strcmp(stain, 'Iron') == 1
    % Allow CD68-only exclusions to use GFAP data instead
    if isfile(variables_file) == 0
        % Update variables like GFAP was in use all along
        inflammatory_marker = 'GFAP';
        directory.input = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel density comparison/%s/All variables', inflammatory_marker);
        
        cd(directory.input)
        variables_file = sprintf('CAA%d_%d_%s_and_Iron_1pixel_density_comparison_all_variables.mat', brain, block, inflammatory_marker);
    end
    
    % Load
    load(variables_file, 'iron_heat_map', 'stat_iron', 'original_iron', 'iron_tissue_mask');

    % Rename so variables are standardized
    heat_map = iron_heat_map;
    original_image = original_iron;
    cortex_mask = iron_tissue_mask;
end

% Generate tissue mask
original_image = imresize(original_image, size(cortex_mask));

cd(directory.scripts)
[tissue_mask, ~] = extract_tissue(original_image, cortex_mask, stain);

%% Check iron quantity
iron_objects = nansum(nansum(stat_iron));

%if iron_objects > 400

%% Correct automatically generated tissue mask
% Make opposite tissue mask
[x, y, ~] = size(original_image);
opposite_tissue_mask = logical(1 - tissue_mask(:,:,1));
corrected_opposite_tissue_mask = opposite_tissue_mask;

% Make overlaid figure to help with drawing
drawing_figure = figure;
imshowpair(original_image, opposite_tissue_mask(:,:,1))
drawing_figure.Position = [412 165 775 626];

% Ask whether to draw
another_correction = input('Draw an ROI?   If no, reply 0; if yes, reply 1    ');

while another_correction == 1
    % Draw correction
    correction = impoly;
    correction_mask = createMask(correction);
    
    % Ask about color
    black_or_white = input('If black, reply 0; if white, reply 1.      ');
    
    % Change opposite tissue mask
    for i = 1:x
        for j = 1:y
            if correction_mask(i,j) == 1
                if black_or_white == 0
                    corrected_opposite_tissue_mask(i,j) = 0;
                elseif black_or_white == 1
                    corrected_opposite_tissue_mask(i,j) = 1;
                end
            end
        end
    end
    
    % Make new overlaid figure
    close
    drawing_figure = figure;
    imshowpair(original_image, corrected_opposite_tissue_mask)
    drawing_figure.Position = [412 165 775 626];
    
    % Keep the while loop going
    another_correction = input('Draw an ROI?   If no, reply 0; if yes, reply 1    ');
    
    clear correction correction_mask
end

%% Make masks for layers of cortex
% Get size of one MATLAB pixel in um
layer_size_microns = 1000;
if strcmp(stain, 'CD68') == 1
    microns_per_pixel = 6.3964;
elseif strcmp(stain, 'GFAP') == 1
    microns_per_pixel = 6.600806;
elseif strcmp(stain, 'Iron') == 1
    microns_per_pixel = 6.603822;
end

% Set dilation amount
layer_size_pixels = round(layer_size_microns / microns_per_pixel);
se = strel('square', layer_size_pixels);

% Set up variables for loop
next_smaller = imdilate(corrected_opposite_tissue_mask, se);
layer = next_smaller - corrected_opposite_tissue_mask;
layer_masks(:,:,1) = layer;
current = next_smaller;

% Make layer masks
for k = 1:19
    next_smaller = imdilate(next_smaller, se);
    layer = next_smaller - current;
    if sum(sum(layer & cortex_mask)) > 0
        layer_masks(:,:,k+1) = layer;
        current = next_smaller;
    else
        break
    end
end

for l = 1:x
    for m = 1:y
        if cortex_mask(l,m) == 0
            layer_masks(l,m,:) = 0;
        end
    end
end

clear k l m

%% Make trial rainbow cortex figure
% Set up for colors
[~, ~, number_of_layers] = size(layer_masks);
color = jet(number_of_layers);
double_tissue_mask = double(tissue_mask);
rainbow_figure = cat(3, double_tissue_mask, double_tissue_mask, double_tissue_mask);

% Add colors
for k = 1:number_of_layers
    for l = 1:x
        for m = 1:y
            if layer_masks(l,m,k) == 1
                rainbow_figure(l,m,:) = color((number_of_layers + 1)-k,:);
            end
        end
    end
end

% Display figure
close all
figure;
imshow(rainbow_figure)

%% Correct overextending cortex mask if needed
% Ask for input
change_cortex_mask = input('Try different cortex mask? If no, reply 0; if yes, reply 1      ');

if change_cortex_mask
    % Import and view primary mask
    cd(directory.input)
    load(variables_file, 'primary_mask');
    
    close all
    figure;
    imshowpair(primary_mask, rainbow_figure);
    
    % Ask whether to use primary mask
    use_primary_mask = input('Use this mask? If no, reply 0; if yes, reply 1     ');
    close all
    
    % Apply mask
    if use_primary_mask
        for k = 1:number_of_layers
            for l = 1:x
                for m = 1:y
                    if primary_mask(l,m) == 0
                        layer_masks(l,m,k) = 0;
                    end
                end
            end
        end
        
        %% Make new rainbow cortex figure
        rainbow_figure = cat(3, double_tissue_mask, double_tissue_mask, double_tissue_mask);
        
        % Add colors
        for k = 1:number_of_layers
            for l = 1:x
                for m = 1:y
                    if layer_masks(l,m,k) == 1
                        rainbow_figure(l,m,:) = color((number_of_layers + 1)-k,:);
                    end
                end
            end
        end
        
        for l = 1:x
            for m = 1:y
                if rainbow_figure(l, m, :) == 0
                    rainbow_figure(l,m,:) = 1;
                end
            end
        end
        
        % Display figure
        close all
        figure;
        imshow(rainbow_figure)
    end
end

%% Save rainbow cortex figure
cd(directory.save_cortex_figure)

cortex_figure_save_name = sprintf('CAA%d_%d_%s_cortex_figure.png', brain, block, stain);
saveas(gcf, cortex_figure_save_name);

%% Apply masks to scatterplots and calculate densities
heat_map_layers = NaN(x,y,number_of_layers);
layer_densities = NaN(number_of_layers);
layer_too_small = NaN(1, number_of_layers);

for k = 1:number_of_layers
    heat_map_layers(:,:,k) = heat_map;
    for l = 1:x
        for m = 1:y
            if layer_masks(l,m,k) == 0
                heat_map_layers(l,m,k) = NaN;
            end
        end
    end
    
    % Calculate densities
    density_numerator = sum(sum(heat_map_layers(:,:,k) == 1));
    density_denominator = numel(find(heat_map_layers(:,:,k)==0)) + density_numerator;
    layer_densities(k) = density_numerator/density_denominator;
    
    % Exclusion
    if density_denominator < (x * y)/150
        layer_too_small(k) = 1;
        %layer_densities(k) = NaN;
    else
        layer_too_small(k) = 0;
    end
    
    clear density_denominator density_numerator
end

clear k l m

%% Save variables
cd(directory.save)
all_variables_save_name = sprintf('CAA%d_%d_%s_edge_analysis_variables.mat', brain, block, stain);
save(all_variables_save_name);

%else
%% If below iron threshold
%fprintf 'Not enough iron!';

%close all
%cd(directory.scripts)

%end
