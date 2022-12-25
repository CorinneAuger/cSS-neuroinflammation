function [block_vector_iron, block_vector_inflammation] = pixel_classifier(stat_iron, stat_inflammation, patch_size_microns)
% Used in outer_layer_iron_intervals to classify pixels into very_low, low,
% medium, and high object densities.

%% Preallocate
[density_x, density_y] = size(stat_iron);
interval_plot_iron = NaN(density_x, density_y);

%% Make interval plots
if patch_size_microns == 500
    for i = 1:density_x
        for j = 1:density_y
            if stat_iron(i,j) <= 5
                interval_plot_iron(i,j) = 0;
            elseif stat_iron(i,j) > 5 && stat_iron(i,j) <= 15
                interval_plot_iron(i,j) = 1;
            elseif stat_iron(i,j) > 15 && stat_iron(i,j) <= 25
                interval_plot_iron(i,j) = 2;
            elseif stat_iron(i,j) > 25
                interval_plot_iron(i,j) = 3;
            end
        end
    end
    
elseif patch_size_microns == 250
    for i = 1:density_x
        for j = 1:density_y
            if stat_iron(i,j) <= 1.25
                interval_plot_iron(i,j) = 0;
            elseif stat_iron(i,j) > 1.25 && stat_iron(i,j) <= 3.75
                interval_plot_iron(i,j) = 1;
            elseif stat_iron(i,j) > 3.75 && stat_iron(i,j) <= 6.25
                interval_plot_iron(i,j) = 2;
            elseif stat_iron(i,j) > 6.25
                interval_plot_iron(i,j) = 3;
            end
        end
    end
end

%% Make block vectors
block_vector_iron = reshape(interval_plot_iron, [1, numel(interval_plot_iron)]);
block_vector_inflammation = reshape(stat_inflammation, [1, numel(stat_inflammation)]);

