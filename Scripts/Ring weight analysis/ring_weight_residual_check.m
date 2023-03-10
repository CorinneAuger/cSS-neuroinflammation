%% Ring weight residual check
% Proofreads ring residual analysis data to make sure no excluded sections were included by mistake.

close all
clear

%% Input directories
directory.data = '/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel ring weight analysis/GFAP (1-tailed)/Residual comparison/Normalized';
directory.save = '/Volumes/Corinne hard drive/cSS project/ALL EXCLUDED/Ring weight (E)';

%% Import data
cd(directory.data)
load('GFAP_ring_weight_normalized_residuals.mat', 'all_residuals')

%% Excluded section info
excluded_sections = [23, 1; 23, 7; 17, 5; 5, 4; 5, 7; 8, 4; 14, 7; 21, 4; 5, 1; 15, 1; 15, 5; 17, 7; 18, 7; 21, 1; 21, 5; 24, 1];

%% Check data
% Get sizes
[length_excluded, ~] = size(excluded_sections);

% Preallocate
wrongly_included = {};
new_data = all_residuals;
    
% Find excluded section in data
for i = 1:length_excluded
    brain = excluded_sections(i, 1);
    section = excluded_sections(i, 2);
    
    % Check that data is NaNs
    if isnan(all_residuals(brain, section, 1)) == 0|| isnan(all_residuals(brain, section, 2)) == 0 || isnan(all_residuals(brain, section, 3)) == 0 || isnan(all_residuals(brain, section, 4)) == 0
        section_name = sprintf('CAA%d_%d_GFAP', brain, section);
        wrongly_included = [wrongly_included, section_name];
        
        % Replace with NaNs in new matrix
        new_data(brain, section, :) = NaN(1,1,4);
    end
end
    
%% Get new data by brain
new_data_by_brain = squeeze(nanmean(new_data, 2));

%% Make graph
figure
boxplot(new_data_by_brain);
xticklabels({'Inner pixel', 'Inner pixel + ring 1', 'Inner pixel + rings 1 & 2', 'Inner pixel + rings 1, 2, & 3'})
ylim([0 2])
ylabel('Normalized residual', 'FontSize', 18)

% Make axis labels bigger
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',10)
b = get(gca,'YTickLabel');
set(gca,'YTickLabel',b,'fontsize',18)

% Add scatter plot
hold on
for ring = 1:4
    scatter(ring * ones(25,1), new_data_by_brain(:,ring), 'black', '.');
    hold on
end
    
%% Save 
cd(directory.save)
saveas(gcf, 'GFAP_residual_graph.png')
save('GFAP_residual_comparison_by_section', 'new_data')
save('GFAP_residual_comparison_by_brain', 'new_data_by_brain')
    