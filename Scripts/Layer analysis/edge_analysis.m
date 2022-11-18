function [] = edge_analysis(brain, block, stain)
% Compares object density between consecutive artificial 1000um layers of the cortex, one section at a time.
% First step of layer analysis.
% Sections analyzed one by one.

%% Input brain, block, stain if not running in a loop (can comment these out if being looped)
brain = 1;
block = 4;
stain = 'CD68';

% Inflammatory marker
if strcmp(stain, 'CD68') || strcmp(stain, 'Iron')
    inflammatory_marker = 'CD68';
elseif strcmp(stain, 'GFAP')
    inflammatory_marker = 'GFAP';
end

%% Input directories
directory.input = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel density comparison/%s/All variables', inflammatory_marker);
directory.scripts = '/Volumes/Corinne hard drive/cSS project/Scripts/Layer analysis';
directory.save = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/Edge analysis/Individual slides/%s 1000um', stain);

clearvars -except brain block stain q directory inflammatory_marker
close all

%% Load variables
cd(directory.input)
variables_file = sprintf('CAA%d_%d_%s_and_Iron_1pixel_density_comparison_all_variables.mat', brain, block, inflammatory_marker);

if strcmp(stain, 'GFAP') == 1 || strcmp(stain, 'CD68') == 1
    % Load
    load(variables_file, 'inflammation_heat_map', 'stat_inflammation', 'coregistered_inflammation', 'inflammation_tissue_mask');
    
    % Rename so variables are standardized
    heat_map = inflammation_heat_map;
    density_map = stat_inflammation;
    original_image = coregistered_inflammation;
    cortex_mask = inflammation_tissue_mask;

elseif strcmp(stain, 'Iron') == 1
    % Load
    load(variables_file, 'iron_heat_map', 'stat_iron', 'original_iron', 'iron_tissue_mask');
    
    % Rename so variables are standardized
    heat_map = iron_heat_map;
    density_map = stat_iron;
    original_image = original_iron;
    cortex_mask = iron_tissue_mask;
    
end

% Generate tissue mask
original_image = imresize(original_image, size(cortex_mask));

cd(directory.scripts)
[tissue_mask, ~] = extract_tissue(original_image, cortex_mask, stain);

%% Check iron quantity

[density_x, density_y] = size(density_map);

%for i = 1:density_x
    %for j = 1:density_y
        %if density_map(i,j) <= 16
            %interval_plot(i,j) = 0;
        %elseif density_map(i,j) > 16 && stat_iron.density(i,j) <= 32
            %interval_plot(i,j) = 1;
        %elseif density_map(i,j) > 32 && stat_iron.density(i,j) <= 48
            %interval_plot(i,j) = 2;
        %elseif density_map(i,j) > 48
            %interval_plot(i,j) = 3;
        %end
    %end
%object_quantity = sum(sum(interval_plot));

%if object_quantity >=  5

%% EXPERIMENTAL
% Make opposite tissue mask
[x, y, ~] = size(original_image);
opposite_tissue_mask = logical(1 - tissue_mask(:,:,1));

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
            if correction_mask(x,y)
                if black_or_white == 0
                    opposite_tissue_mask(i,j) = 0;
                elseif black_or_white == 1
                    opposite_tissue_mask(i,j) = 0;
                end
            end
        end
    end
    
    % Keep the while loop going
    another_correction = input('Draw an ROI?   If no, reply 0; if yes, reply 1    ');
    
    % Make new overlaid figure to help with drawing
    close
    drawing_figure = figure;
    imshowpair(original_image, opposite_tissue_mask(:,:,1))
    drawing_figure.Position = [412 165 775 626];
    
    clear correction correction_mask
end

    %% Create tissue mask

    [x, y, ~] = size(original_image);
    opposite_tissue_mask = logical(1 - tissue_mask(:,:,1));

    original_image_pair_figure = figure;
    imshowpair(original_image, opposite_tissue_mask(:,:,1))
    original_image_pair_figure.Position = [0 82 387 313];

    original_image_figure = figure;
    imshow(original_image)
    original_image_figure.Position = [1 1 1166 358];

    rectangle_drawing_figure = figure;
    imshow(opposite_tissue_mask)
    rectangle_drawing_figure.Position = [412 165 775 626];
    composite_frames = opposite_tissue_mask;

    another_rectangle = input('Draw a rectangle?   If no, reply 0; if yes, reply 1    ');

    while another_rectangle == 1
        rect = imrect;
        pos = getPosition(rect);
        delete(rect);

        black_or_white = input('If black, reply 0; if white, reply 1.      ');

        if black_or_white == 0
            new_rectangle = rectangle('Position', pos, 'FaceColor', 'black', 'EdgeColor', 'black');
        else
            new_rectangle = rectangle('Position', pos, 'FaceColor', 'white', 'EdgeColor', 'white');
        end

        frame = getframe;
        composite_frames = frame.cdata;
        another_rectangle = input('Draw a rectangle?   If no, reply 0; if yes, reply 1    ');
        clear frame rectangle

        assisting_image = input('Assisting image?   If no, reply 0; if yes, reply 1    ');

        if assisting_image == 1
            imshowpair(imresize(composite_frames, [x,y]), original_image);
            pause(3);
            imshow(composite_frames)
        end
    end

    close all

    resized_composite_frames = imresize(composite_frames, size(opposite_tissue_mask));
    if islogical(resized_composite_frames) == 0
        corrected_opposite_tissue_mask = imbinarize(resized_composite_frames(:,:,1));
    else
        corrected_opposite_tissue_mask = resized_composite_frames(:,:,1);
    end

    %% Make masks for layers of cortex

    if strcmp(stain, 'GFAP') == 1
        % Load variables
        cd(directory.input)
        load(variables_file, 'coregistered_tissue_map_inflammation', 'blue_channel_inflammation', 'red_channel_inflammation');
        cortex_mask_input = coregistered_tissue_map_inflammation;
        blue_channel = blue_channel_inflammation;
        red_channel = red_channel_inflammation;

        % Generate cortex mask
        cd(directory.scripts)
        cortex_mask = extract_GFAP_cortex_from_tissue_map(cortex_mask_input, blue_channel, red_channel);
        close
    end

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

    %% Apply masks to scatterplots and calculate densities

    [~, ~, number_of_layers] = size(layer_masks);
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

    %% Make plot of density at each layer
    
    % Prepare color palettes
    color = jet(number_of_layers);
    dark_color = color./2;
    
    % Make figure
    figure;
    %subplot(1,2,1)
    
    % Plot line
    plot(layer_densities, 'Color', 'black', 'LineStyle', '-', 'LineWidth', 1.5);
    hold on
    
    % Plot points
    for k = 1:number_of_layers
        scatter(k, layer_densities(k), 100, 'filled', 'MarkerEdgeColor', dark_color((number_of_layers + 1)-k,:), 'MarkerFaceColor', color((number_of_layers + 1)-k,:));   
        hold on
    end
    
    % X axis
    xlim([0,number_of_layers]);
    set(gca,'xticklabel',[])
    set(gca,'XTick',[])
    
    % Y axis
    a = get(gca,'YTickLabel');
    set(gca, 'YTickLabel', a, 'fontsize', 11, 'fontweight', 'bold')
    
    % Axis labels
    xlabel('1000 µm layer', 'FontSize', 20, 'FontWeight', 'bold');
    ylabel('Iron density (%)', 'FontSize', 20, 'FontWeight', 'bold');

    % Title
    title('Example section', 'FontSize', 25)
    
    % Border
    box on 
    ax = gca;
    ax.LineWidth = 1;

    % Cortex figure
    double_tissue_mask = double(tissue_mask);

    rainbow_figure = cat(3, double_tissue_mask, double_tissue_mask, double_tissue_mask);
    for k = 1:number_of_layers
        for l = 1:x
            for m = 1:y
                if layer_masks(l,m,k) == 1
                    rainbow_figure(l,m,:) = color((number_of_layers + 1)-k,:);
                end
            end
        end
    end

    subplot(1,2,2)
    imshow(rainbow_figure)
    %title(sprintf('CAA%d__%d__%s', brain, block, stain));

    cd(directory.save)
    figure_save_name = sprintf('Example_layer_graph_CAA%d_%d_%s.png', brain, block, stain);
    saveas(gcf, figure_save_name);
    all_variables_save_name = sprintf('CAA%d_%d_%s_edge_analysis_variables.mat', brain, block, stain);
    save(all_variables_save_name);

%else
    %fprintf 'Not enough iron!';
%end

cd(directory.scripts)

end
