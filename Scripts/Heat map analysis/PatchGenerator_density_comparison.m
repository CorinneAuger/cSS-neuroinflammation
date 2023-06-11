function heat_map = PatchGenerator_density_comparison(img_in, size_patch, size_jump, count_type)

%% Converts a matrix scatter plot/heat map into a smaller heat map.
% Counts objects, not densities.

% Arguments
%   img_in: larger image from which to make a heat map
%   size_patch: a 2x1 matrix with desired patch dimensions (ex. size_patch = [250, 250])
%   size_jump: same as size_patch unless you want your patches to overlap or skip over areas
%   count_type: set to 'Zeros' to count zeros. Set to 'Values' to sum values.

%% Get parameters
[dimx, dimy, ~] = size(img_in);

for i = 1:dimx
    max_count_x = size_patch(1,1) + (i-1)*size_jump(1,1);
    if max_count_x > dimx
        n_rows_to_fill = max_count_x - dimx;
        max_iter_x = i;
        break
    end
end

for j = 1:dimy
    max_count_y = size_patch(1,2) + (j-1)*size_jump(1,2);
    if max_count_y > dimy
        n_columns_to_fill = max_count_y - dimy;
        max_iter_y = j;
        break
    end
end

%% Preallocate
img_tmp = ones(max_count_x,max_count_y);

%% Initialize
img_tmp(1:dimx,1:dimy) = img_in;

% Get rid of lines
for i = 1:max_count_x
    if img_tmp(i, 1:dimy) == zeros(1, dimy)
        img_tmp(i, :) = ones(1, max_count_y);
    end
end

%% Preallocate
img_tmp((max_count_x - n_rows_to_fill + 1):max_count_x,:) = NaN;
img_tmp(:, (max_count_y - n_columns_to_fill + 1):max_count_y) = NaN;

warning('off', 'MATLAB:colon:nonIntegerIndex');

raw_objects = NaN(max_iter_x, max_iter_y);
heat_map = NaN(max_iter_x, max_iter_y);

for h = 1:max_iter_y
    for g = 1:max_iter_x
        %% Get vectors with all the values in the patch
        curr_x_start = 1+(g-1)*size_jump(1,1);
        curr_y_start = 1+(h-1)*size_jump(1,2);
        curr_x_end   = size_patch(1,1) + (g-1)*size_jump(1,1);
        curr_y_end   = size_patch(1,2) + (h-1)*size_jump(1,2);
        population   = img_tmp(curr_x_start:curr_x_end,curr_y_start:curr_y_end);
        population   = reshape(population,1,numel(population));

        %% Exclude patches that are more than 1/3 NaNs
        pixels_in_patch = size_patch(1) * size_patch(2);
        NaN_pixel_count = sum(sum(isnan(population)));

        if NaN_pixel_count > (pixels_in_patch/3)
            heat_map(g,h) = NaN;
        else
            %% Get object count for the patch
            if strcmp(count_type, 'Zeros')
                IndexZeroValues = find(population==0);
                N_ZeroValues    = numel(IndexZeroValues);
                raw_objects(g,h) = N_ZeroValues;
            elseif strcmp(count_type, 'Values')
                raw_objects(g,h) = sum(sum(population));
            end

            %% Remove edge artifacts
            if raw_objects(g,h) == pixels_in_patch
                % In pixel
                raw_objects(g,h) = 0;
                
                % In 5x5 box around it 
                try
                    raw_objects(g-2:g+2, h-2:h+2) = 0;
                catch
                    warning('Subscript indices must either be real positive integers or logicals.');
                    map = false(size(raw_objects));
                    map(g,h) = 1;
                    dmap = imdilate(map,true(5,5));
                    change = xor(map,dmap);
                    raw_objects(change) = false;
                end
                
                clear map dmap change
            end

            %% Scale object count to be proportional to number of pixels within the cortex in the patch
            cortex_pixels = pixels_in_patch - NaN_pixel_count;
            cortex_pixel_fraction = cortex_pixels/pixels_in_patch;
            heat_map(g,h) = raw_objects(g,h) / cortex_pixel_fraction;
        end
    end
end

end
