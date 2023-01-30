%% Iron intervals composite
% Makes final matrix and graph of iron vs. inflammation data. 

inflammatory_marker = 'GFAP';

%% Define directories
directory.scripts = '/Volumes/Corinne hard drive/cSS project/Scripts/Inflammation vs. iron';
directory.save = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel interval analysis/%s/Composite', inflammatory_marker);

%% Run iron intervals script
all_means = NaN(26,4);

for q = [1:3, 5, 7:9, 11, 13:15, 17:18, 20:25]
    cd(directory.scripts)   
    means = iron_intervals(q, inflammatory_marker, 'None');
    all_means(q, 1:4) = means;
end

close all

%means = iron_intervals(11, 'GFAP');
%all_means(q-1, 1:4) = means;

%for q = 13:26
    %means = iron_intervals(q, 'GFAP');
    %all_means(q-2, 1:4) = means;
%end

%% Make figure
figure;
for n = 1:4
    scatter(n * ones(26,1), all_means(:,n), 'black', '.');
    hold on
end

a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',18)

boxplot(all_means)
xlabel('Patch iron density', 'FontSize', 20);
xticks([1 2 3 4]);
xticklabels({'Very low', 'Low', 'Medium', 'High'});

xlim([0.5 4.5]);
ylabel(sprintf('Mean %s objects', inflammatory_marker), 'FontSize', 20);
ylim([0 (nanmax(nanmax(all_means))+10)]);
title(sprintf('Mean %s objects at iron density intervals by brain', inflammatory_marker), 'FontSize', 16);

%% Save
cd(directory.save)
save(sprintf('All_brains_%s_iron_intervals.mat', inflammatory_marker), 'all_means');
saveas(gcf, sprintf('All_brains_%s_iron_intervals_box_plot.png', inflammatory_marker));
