%% ICH iron intervals
% Runs sections and makes final matrix and graph of iron vs. inflammation data for ICH sections.

inflammatory_marker = 'GFAP';

%% Define directories
directory.scripts = '/Volumes/Corinne hard drive/cSS project/Scripts/Inflammation vs. iron';
directory.input = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel density comparison/%s/ICH sections', inflammatory_marker);
directory.save = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel interval analysis/%s/ICH sections/Composite', inflammatory_marker);

%% Get ICH sections
cd(directory.scripts)
ich_brains_and_blocks = ID_ICH_sections(inflammatory_marker);

%% Run iron intervals script
all_ich_means = NaN(length(ich_brains_and_blocks), 4);

for h = 1 : length(ich_brains_and_blocks)
    brain = ich_brains_and_blocks(h, 1);
    block = ich_brains_and_blocks(h, 2);
    
    variables_file = sprintf('CAA%d_%d_%s_and_Iron_1pixel_density_comparison_crucial_variables.mat', brain, block, inflammatory_marker);
    cd(directory.input)
    
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
    
    %% Make vectors of the interval categorizations
    vector_interval_iron = reshape(interval_plot_iron, [1, numel(interval_plot_iron)]);
    vector_inflammation = reshape(stat_inflammation, [1, numel(stat_inflammation)]);
    
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
    
    %% Add to overall matrix
    all_ich_means(h, 1:4) = means;
    
    %% Save section
end

%% Make composite figure
figure;

% Plot points
for n = 1:4
    scatter(n * ones(length(all_ich_means),1), all_ich_means(:,n), 'black', '.');
    hold on
end

% Plot boxplot
boxplot(all_ich_means)

% X axis
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',18)

xlabel('Patch iron density', 'FontSize', 20);
xticks([1 2 3 4]);
xticklabels({'Very low', 'Low', 'Medium', 'High'});

% Axis limits
xlim([0.5 4.5]);
ylabel(sprintf('Mean %s objects', inflammatory_marker), 'FontSize', 20);
ylim([0 (nanmax(nanmax(all_ich_means))+10)]);
title(sprintf('ICH: mean %s objects at iron density intervals by section', inflammatory_marker), 'FontSize', 16);

%% Save
cd(directory.save)

save(sprintf('All_brains_ICH_%s_iron_intervals_by_section.mat', inflammatory_marker), 'all_means');
saveas(gcf, sprintf('All_brains_ICH_%s_iron_intervals_by_section_box_plot.png', inflammatory_marker));
