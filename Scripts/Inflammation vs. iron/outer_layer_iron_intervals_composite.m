%% Outer layer iron intervals composite
% Makes final matrix and graph of iron vs. inflammation data, only looking at the outermost 1000um.

%% Make loop to do 2 stains at once
for i = 1:2
    if i == 1
        inflammatory_marker = 'CD68';
    elseif i == 2
        inflammatory_marker = 'GFAP';
    end

    %% Define directories
    directory.scripts = '/Volumes/Corinne hard drive/cSS project/Scripts/Inflammation vs. iron';
    directory.save = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel interval analysis/%s/Composite', inflammatory_marker);

    %% Run iron intervals script
    all_edge_only_means = NaN(26,4);
    all_no_edge_means = NaN(26,4);

    cd(directory.scripts)

    if i == 1 %CD68
        brains_matrix = [1:3, 5, 7:9, 15, 17:18, 22:24];
    elseif i == 2 %GFAP
        brains_matrix = [1:3, 5, 7:9, 13, 14, 17:18, 21:24];
    end

    for brain = brains_matrix
        cd(directory.scripts)
        [edge_only_means, no_edge_means] = outer_layer_iron_intervals(brain, inflammatory_marker);
        all_edge_only_means(brain, 1:4) = edge_only_means;
        all_no_edge_means(brain, 1:4) = no_edge_means;
    end

    close all

    %means = iron_intervals(11, 'GFAP');
    %all_means(q-1, 1:4) = means;

    %for q = 13:26
    %means = iron_intervals(q, 'GFAP');
    %all_means(q-2, 1:4) = means;
    %end

    %% Make edge only figure
    figure;
    for n = 1:4
        scatter(n * ones(26,1), all_edge_only_means(:,n), 'black', '.');
        hold on
    end

    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',18)

    boxplot(all_edge_only_means)
    xlabel('Patch iron density', 'FontSize', 20);
    xticks([1 2 3 4]);
    xticklabels({'Very low', 'Low', 'Medium', 'High'});

    xlim([0.5 4.5]);
    ylabel(sprintf('Mean %s objects', inflammatory_marker), 'FontSize', 20);
    ylim([0 (nanmax(nanmax(all_edge_only_means))+10)]);
    title(sprintf('Outer 1000um only: mean %s objects at iron density intervals by brain', inflammatory_marker), 'FontSize', 16);

    %% Save edge only figure
    cd(directory.save)
    save(sprintf('Edge_only_all_brains_%s_iron_intervals.mat', inflammatory_marker), 'all_edge_only_means');
    saveas(gcf, sprintf('Edge_only_all_brains_%s_iron_intervals_box_plot.png', inflammatory_marker));

    %% Make no edge figure
    figure;
    for n = 1:4
        scatter(n * ones(26,1), all_no_edge_means(:,n), 'black', '.');
        hold on
    end

    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',18)

    boxplot(all_no_edge_means)
    xlabel('Patch iron density', 'FontSize', 20);
    xticks([1 2 3 4]);
    xticklabels({'Very low', 'Low', 'Medium', 'High'});

    xlim([0.5 4.5]);
    ylabel(sprintf('Mean %s objects', inflammatory_marker), 'FontSize', 20);
    ylim([0 (nanmax(nanmax(all_no_edge_means))+10)]);
    title(sprintf('Without outer 1000um: mean %s objects at iron density intervals by brain', inflammatory_marker), 'FontSize', 16);

    %% Save no edge figure
    cd(directory.save)
    save(sprintf('No_edge_all_brains_%s_iron_intervals.mat', inflammatory_marker), 'all_no_edge_means');
    saveas(gcf, sprintf('No_edge_all_brains_%s_iron_intervals_box_plot.png', inflammatory_marker));
end
