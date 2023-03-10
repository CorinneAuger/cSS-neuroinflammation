%% Ring weight exclusion check
% Proofreads ring weight data to make sure no excluded sections were included by mistake.

close all
clear

%% Change manually
for number_of_columns = 1:4
    inflammatory_marker = 'GFAP';
    
    %% Input directories
    directory.data = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel ring weight analysis/%s (1-tailed)/%d column/Composite', inflammatory_marker, number_of_columns);
    directory.save = '/Volumes/Corinne hard drive/cSS project/ALL EXCLUDED/Ring weight (E)';
    
    %% Import data
    cd(directory.data)
    load(sprintf('%s_and_Iron_1pixel_%d_column_ring_weight_analysis_variables.mat', inflammatory_marker, number_of_columns), 'top_weight_for_each_section')
    
    %% Excluded section info
    if strcmp(inflammatory_marker, 'GFAP')
        excluded_sections = [23, 1; 23, 7; 17, 5; 5, 4; 5, 7; 8, 4; 14, 7; 21, 4; 5, 1; 15, 1; 15, 5; 17, 7; 18, 7; 21, 1; 21, 5; 24, 1];
    elseif strcmp(inflammatory_marker, 'CD68')
        excluded_sections = [23, 1; 23, 7; 5, 4; 5, 7; 8, 4; 14, 7; 21, 4; 2, 1; 2, 7; 15, 5; 20, 4; 20, 5];
    end
    
    %% Check data
    % Get sizes
    [length_excluded, ~] = size(excluded_sections);
    
    % Preallocate
    wrongly_included = {};
    new_data = top_weight_for_each_section;
    
    % Find excluded section in data
    for i = 1:length_excluded
        brain = excluded_sections(i, 1);
        section = excluded_sections(i, 2);
        
        if section == 1
            section_code = 1;
        elseif section == 4
            section_code = 2;
        elseif section == 5
            section_code = 3;
        elseif section == 7
            section_code = 4;
        end
        
        data_index = ((brain - 1) * 4) + section_code;
        
        % Check that data is NaNs
        if sum(~isnan(top_weight_for_each_section(data_index, :))) ~= 0
            section_name = sprintf('CAA%d_%d_%s', brain, section, inflammatory_marker);
            wrongly_included = [wrongly_included, section_name];
            
            % Replace with NaNs in new matrix
            new_data(data_index, :) = NaN(1,4);
        end
    end
    
    %% Make graph of weight options for sections
    figure
    boxplot(new_data);
    xticklabels({'Pixel', 'Ring 1', 'Ring 2', 'Ring 3'})
    ylim([0 1])
    ylabel('Weight', 'FontSize', 18)
    title('By section');
    
    % Make axis labels bigger
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',18)
    b = get(gca,'YTickLabel');
    set(gca,'YTickLabel',b,'fontsize',18)
    
    % Add scatter plot
    hold on
    for ring = 1:4
        scatter(ring * ones(104,1), top_weight_for_each_section(:,ring), 'black', '.');
        hold on
    end
    
    %% Save section graph
    cd(directory.save)
    saveas(gcf, sprintf('%s_and_Iron_%d_column_weights_by_section.png', inflammatory_marker, number_of_columns))
    
    hold off
    close all
    
    %% Calculate values for brains
    top_weight_for_each_brain = NaN(26,4);
    
    for brain_number = 1:26
        individual_brain_weights = [top_weight_for_each_section((brain_number * 4) - 3,:); top_weight_for_each_section((brain_number * 4) - 2,:); top_weight_for_each_section((brain_number * 4) - 1,:); top_weight_for_each_section(brain_number * 4,:)];
        top_weight_for_each_brain(brain_number, :) = nanmean(individual_brain_weights);
    end
    
    
    %% Make graph of weight options for brains
    figure
    boxplot(top_weight_for_each_brain);
    xticklabels({'Pixel', 'Ring 1', 'Ring 2', 'Ring 3'})
    ylim([0 1])
    ylabel('Weight', 'FontSize', 18)
    title('By brain');
    
    % Make axis labels bigger
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',18)
    b = get(gca,'YTickLabel');
    set(gca,'YTickLabel',b,'fontsize',18)
    
    % Add scatter plot
    hold on
    for ring = 1:4
        scatter(ring * ones(26,1), top_weight_for_each_brain(:,ring), 'black', '.');
        hold on
    end
    
    %% Save brain graph
    cd(directory.save)
    saveas(gcf, sprintf('%s_and_Iron_1pixel_%d_column_weights_by_brain.png', inflammatory_marker, number_of_columns))
    hold off
    
    %% Save new data
    cd(directory.save)
    save(sprintf('%s_%d_column_brain_weights', inflammatory_marker, number_of_columns), 'top_weight_for_each_brain')
    save(sprintf('%s_%d_column_section_weights', inflammatory_marker, number_of_columns), 'new_data')
    
end