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
    object_density_by_lobe = NaN(71, 4);
    
    for i = 1:n
        %% Set up 4-column matrix with columns separated by lobe
        if data(i, 2) == 1
            lobe_pos = 1;
        elseif data(i, 2) == 4
            lobe_pos = 2;
        elseif data(i, 2) == 5
            lobe_pos = 3;
        elseif data(i, 2) == 7
            lobe_pos = 4;
        end
        
        %% Get number of objects
        if strcmp(stain, 'Iron')
            objects_in_section = data(i, 6);
            excel_column_letter = 'P';
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
        
        excel_column = sprintf('%s:%s', excel_column_letter, excel_column_letter);
        
        if isfile(IA_details_sheet_name)
            areas_to_sum = table2array(readtable(IA_details_sheet_name, 'Range', excel_column));
            area_in_um = nansum(areas_to_sum);
            area_in_mm = area_in_um * 10^6;

            %% Calculate density
            object_density_by_lobe(i, lobe_pos) = objects_in_section/area_in_mm;
        end
        
        clear lobe_pos objects_in_section excel_column_letter brain block IA_details_sheet_name areas_to_sum area_in_um area_in_mm
    end
    
    %% Make figure
    % Set up figure
    figure
    boxplot(object_density_by_lobe)
    
    % Add labels
    xlabel('Lobe', 'FontSize', 20);
    xticks([1 2 3 4]);
    xticklabels({'Frontal', 'Temporal', 'Parietal', 'Occipital'});
    xlim([0.5 4.5]);
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',18)
    
    ylabel('Objects per mm^2')
    
    title(sprintf('%s density by cortical lobe', stain));
    hold on
    
    % Add scatter plot
    for block = [1, 2, 3, 4]
        scatter(block * ones(71,1), object_density_by_lobe(:,block), 'black', '.');
        hold on
    end
    
    %% Save
    cd(directory.save)
    
    % Save matrix
    matrix_save_name = sprintf('%s_lobe_comparison', stain);
    save(matrix_save_name, 'object_density_by_lobe')
    
    % Save figure
    figure_save_name = sprintf('%s_lobe_comparison_figure.png', stain);
    saveas(gcf, figure_save_name)
end