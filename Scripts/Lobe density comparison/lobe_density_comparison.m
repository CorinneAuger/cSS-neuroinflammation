%% Lobe density comparison

clear

%% Set up loop through stains
for a = 1:3
    if a == 1
        stain = 'Iron';
    elseif a == 2
        stain = 'GFAP';
    elseif a == 3
        stain = 'CD68';
    end
    
    close all
    
    %% Input directories
    directory.objects_spreadsheet = '/Volumes/Corinne hard drive/cSS project/Saved data/By section table';
    directory.IA_details = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/IA details';
    directory.save = '/Volumes/Corinne hard drive/cSS project/Saved data/Lobe comparison';
    
    %% Load data
    % Columns in order: brain, lobe, age_at_death, sex_0_male_1_female, PMI, Iron, GFAP, CD68
    cd(directory.objects_spreadsheet)
    data = xlsread('Iron_and_inflammation_quantities_by_section.xlsx');
    [n, ~] = size(data);
    
    %% Preallocate
    object_density_by_lobe = NaN(26, 7);
    
    for i = 1:n      
        %% Get number of objects
        if strcmp(stain, 'Iron')
            objects_in_section = data(i, 6);
        elseif strcmp(stain, 'GFAP')
            objects_in_section = data(i, 7);
            excel_column_letter = 'P';
        elseif strcmp(stain, 'CD68')
            objects_in_section = data(i, 8);
            excel_column_letter = 'Q';
        end
        
        %% Get area
        brain = data(i, 1);
        block = data(i, 2);
        IA_details_sheet_name = sprintf('IA_details__CAA%d_%d_%s.xlsx', brain, block, stain);
        cd(directory.IA_details)
        
        if isfile(IA_details_sheet_name)
            
            % Figure out which excel column has area data
            column_names = readtable(IA_details_sheet_name, 'Range', 'A1:Z1', 'ReadVariableNames', true);
            excel_column_index = strfind(column_names.Properties.VariableNames, 'Area__m__');
            excel_column_index(cellfun(@isempty, excel_column_index)) = {0};
            excel_column_number = find(cell2mat(excel_column_index));
            
            % Format as letter
            excel_column_letter = char(excel_column_number + 64);
            excel_column = sprintf('%s:%s', excel_column_letter, excel_column_letter);
            
            areas_to_sum = table2array(readtable(IA_details_sheet_name, 'Range', excel_column));
            area_in_um = nansum(areas_to_sum);
            area_in_mm = area_in_um * 10^-6;

            %% Calculate density
            object_density_by_lobe(brain, block) = objects_in_section/area_in_mm;
        end
        
        clear objects_in_section excel_column_letter brain block IA_details_sheet_name areas_to_sum area_in_um area_in_mm
    end
    
    %% Make figure
    % Preallocate for boxplot, then delete columns
    object_density_by_lobe_cortex_only = object_density_by_lobe; 
    object_density_by_lobe_cortex_only(:, 6) = []; 
    object_density_by_lobe_cortex_only(:, 3) = []; 
    object_density_by_lobe_cortex_only(:, 2) = []; 
    
    boxplot(object_density_by_lobe_cortex_only)
    
    % Add labels
    xlabel('Lobe', 'FontSize', 20);
    xticks([1 2 3 4]);
    xticklabels({'Frontal', 'Temporal', 'Parietal', 'Occipital'});
    xlim([0.5 4.5]);
    b = get(gca,'XTickLabel');
    
    ylabel('Objects per mm^2')
    
    title(sprintf('%s density by cortical lobe', stain));
    hold on
    
    % Add scatter plot
    for chron_block = 1:4    
        scatter(chron_block * ones(26,1), object_density_by_lobe_cortex_only(:, chron_block), 'black', '.');
        hold on
    end
    
    %% Save
    cd(directory.save)
    
    % Save matrix
    matrix_save_name = sprintf('%s_lobe_comparison', stain);
    save(matrix_save_name, 'object_density_by_lobe')
    
    % Save excel sheet
    object_density_by_lobe_table = array2table(object_density_by_lobe);
    writetable(object_density_by_lobe_table, 'Lobe_comparison.xlsx', 'Sheet', stain, 'WriteVariableNames', false)
    
    % Save figure
    figure_save_name = sprintf('%s_lobe_comparison_figure.png', stain);
    saveas(gcf, figure_save_name)
end