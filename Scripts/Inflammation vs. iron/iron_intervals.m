function means = iron_intervals(brain, inflammatory_marker, specify_sections)
% Iron vs. inflammation for a single brain. Used in iron_intervals_composite.

close all

%% Input directories
if strcmp(specify_sections, 'ICH')
    directory.input = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel density comparison/%s/ICH sections', inflammatory_marker);
    directory.save = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel interval analysis/%s/ICH sections', inflammatory_marker);
else
    directory.input = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel density comparison/%s/Crucial variables', inflammatory_marker);
    directory.save = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel interval analysis/%s', inflammatory_marker);
end

for block = [1, 4, 5, 7]
    %% Import objects heat map
    variables_file = sprintf('CAA%d_%d_%s_and_Iron_1pixel_density_comparison_crucial_variables.mat', brain, block, inflammatory_marker);
    cd(directory.input)

    if isfile(variables_file) == 1   %lets us exclude sections that couldn't coregister
        load(variables_file, 'stat_iron');
        load(variables_file, 'stat_inflammation');
        [density_x, density_y] = size(stat_iron);
        interval_plot_iron = NaN(density_x, density_y);

        %% Classify each pixel into very low, low, medium, or high iron density
        % In interval_plot_iron, very low = 0, low = 1, medium = 2, high = 3
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

        %% Make vectors of the interval categorizations for all the blocks in the brain
        block_vector_interval_iron = reshape(interval_plot_iron, [1, numel(interval_plot_iron)]);
        block_vector_inflammation = reshape(stat_inflammation, [1, numel(stat_inflammation)]);

        if block == 1
            vector_interval_iron = block_vector_interval_iron;
            vector_inflammation = block_vector_inflammation;
        else
            vector_interval_iron = [vector_interval_iron, block_vector_interval_iron];
            vector_inflammation = [vector_inflammation, block_vector_inflammation];
        end
    else
        %% Deal with excluded sections so they won't make a glitch
        if block == 1
            vector_interval_iron = NaN;
            vector_inflammation = NaN;
        else
        end
    end
end

%% Get mean for each interval grouping
clear i j
[~, vector_length] = size(vector_inflammation);

for i = 3:-1:0
    indices = find(vector_interval_iron == i);
    [~, indices_length] = size(indices);

    values = NaN(1, indices_length);

    for j = 1: indices_length
        values(j) = vector_inflammation(indices(j));
    end

    if i == 0
        very_low_mean = nanmean(values);
    elseif i == 1
        low_mean = nanmean(values);
    elseif i == 2
        medium_mean = nanmean(values);
    elseif i == 3
        high_mean = nanmean(values);
    end
end

means = [very_low_mean; low_mean; medium_mean; high_mean];

%% Make figure
figure;

scatter(vector_interval_iron, vector_inflammation, 'black', '.');
hold on
scatter([0; 1; 2; 3], means, 100, 'red', 'x');

xlabel('Iron objects in patch', 'FontSize', 16);
xticks([0 1 2 3]);
xticklabels({'Very low', 'Low', 'Medium', 'High'});
xlim([-0.5 3.5]);

ylabel_name = sprintf('%s objects in patch', inflammatory_marker);
ylabel(ylabel_name, 'FontSize', 16);
ylim([0 (nanmax(nanmax(stat_inflammation)))]);

title(sprintf('CAA%d', brain), 'FontSize', 16);

%% Save
cd(directory.save)
figure_save_name = sprintf('CAA%d__%s_1pixel_interval_figure.png', brain, inflammatory_marker);
saveas(gcf, figure_save_name);

end
