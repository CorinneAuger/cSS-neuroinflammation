%% Inflammation vs. iron by section

% Makes a spreadsheet with columns for iron, GFAP, CD68, brain, lobe, sex, and age at death.
% Spreadsheet can be used to create LME model.

clear

%% Enter inputs
number_of_brains = 25;
number_of_lobes = 7;

%% Enter directories
directory.iron_input = '/Volumes/Corinne hard drive/cSS project/Saved data/Cortical thickness';
directory.inflammation_input = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/IA details';
directory.spreadsheets = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Image sizes spreadsheets';
directory.save = '/Volumes/Corinne hard drive/cSS project/Saved data/By section table';

%% Make iron column
cd(directory.iron_input)
load('Cortical_thickness_vs_Iron_by_section_variables.mat', 'all_iron_objects');
iron_column = all_iron_objects';

%% Make GFAP and columns
CD68_column = NaN(175,1);
GFAP_column = NaN(175,1);

for q = 1:2
    if q == 1
        inflammatory_marker = 'GFAP';
    elseif q == 2
        inflammatory_marker = 'CD68';
    end
    
    inflammation_matrix = NaN(25,7);
    cd(directory.inflammation_input)
    
    % Get number of inflammation objects in section
    for brain = [1:3, 5, 7:9, 11, 13:15, 17, 18, 20:25]
        for block = [1, 4, 5, 7]
            
            Aiforia_details_sheet_name = sprintf('IA_details__CAA%d_%d_%s.xlsx', brain, block, inflammatory_marker);
            cd(directory.inflammation_input)
            
            if isfile(Aiforia_details_sheet_name)
                Aiforia_details_table = readtable(Aiforia_details_sheet_name);
                
                if strcmp(inflammatory_marker, 'GFAP')
                    Aiforia_details_matrix = Aiforia_details_table{:,22};
                elseif strcmp(inflammatory_marker, 'CD68')
                    Aiforia_details_matrix = Aiforia_details_table{:,23};
                end
                
                object_centers_x = Aiforia_details_matrix(~isnan(Aiforia_details_matrix));
                [block_inflammation_objects, ~] = size(object_centers_x);
                
                inflammation_matrix(brain, block) = block_inflammation_objects;
                clear Aiforia_details_sheet_name Aiforia_details_table Aiforia_details_matrix object_centers_x block_inflammation_objects place_in_list
            end
        end
    end
    
    if q == 1
        GFAP_column = reshape(inflammation_matrix, [175, 1]);
    elseif q == 2
        CD68_column = reshape(inflammation_matrix, [175, 1]);
    end
    
    clear inflammation_objects_column inflammation_matrix
end

%% Make brains column
[length, ~] = size(iron_column);
brains_column = NaN(length, 1);

for i = 1:length
    remainder = rem(i,number_of_brains);
    if remainder == 0
        remainder = number_of_brains;
    end
    brains_column(i) = remainder;
end

%% Make lobes column
lobes_matrix = repmat((1:number_of_lobes), [number_of_brains,1]);
lobes_column = reshape(lobes_matrix, [length, 1]);

%% Make age, sex, and PMI columns
age_column = NaN(length,1);
sex_column = NaN(length,1);
PMI_column = NaN(length,1);

cd(directory.spreadsheets)
case_info_table = readtable('Case_info_03012022.xlsx');

for i = 1:length
    CAA_brain_name = sprintf('CAA%d', brains_column(i));
    table_brain_coordinate = find(ismember(case_info_table{:,1},{CAA_brain_name}),2);
    age_column(i) = str2double(case_info_table.AgeAtDeath(table_brain_coordinate));
    sex_column(i) = strcmp(case_info_table.Sex(table_brain_coordinate), 'F');
    PMI_column(i) = str2double(case_info_table.PMI(table_brain_coordinate));
end

%% Combine columns in matrix (indep variable 2nd to last, dep variable last)
matrix_with_NaNs = [brains_column, lobes_column, age_column, sex_column, PMI_column, iron_column, GFAP_column, CD68_column];

%% Sort rows so brains and lobes are in order (adjust based on variables)
sorted_matrix_with_NaNs = sortrows(matrix_with_NaNs, [1,2]);

%% Delete rows for controls and blocks 2, 3, and 6
final_matrix = sorted_matrix_with_NaNs;
[sections, ~] = size(final_matrix);

for i = sections:-1:1
    brain = sorted_matrix_with_NaNs(i,1);
    block = sorted_matrix_with_NaNs(i,2);
    
    if brain == 4 || brain == 6 || brain == 10 || brain == 12 || brain == 16 || brain == 19 || block == 2 || block == 3 || block == 6
        final_matrix(i, :) = [];
    end
end

%% Delete ICH sections and sections with poor iron tissue detection
[sections, ~] = size(final_matrix);

for i = sections:-1:1
    if final_matrix(i,1) == 5 && final_matrix(i, 2) == 4        % ICH
        final_matrix(i, :) = [];
    elseif final_matrix(i,1) == 5 && final_matrix(i, 2) == 7    % ICH
        final_matrix(i, :) = [];
    elseif final_matrix(i,1) == 8 && final_matrix(i, 2) == 4    % ICH
        final_matrix(i, :) = [];
    elseif final_matrix(i,1) == 14 && final_matrix(i, 2) == 7   % ICH
        final_matrix(i, :) = [];
    elseif final_matrix(i,1) == 21 && final_matrix(i, 2) == 4   % ICH
        final_matrix(i, :) = [];
    elseif final_matrix(i,1) == 23 && final_matrix(i, 2) == 1   % tissue detection
        final_matrix(i, :) = [];
    elseif final_matrix(i,1) == 23 && final_matrix(i, 2) == 7   % tissue detection
        final_matrix(i, :) = [];
    end
end

%% Make table
final_table = array2table(final_matrix, 'VariableNames', {'Brain', 'Lobe', 'Age_at_death', 'Sex_0_male_1_female', 'PMI', 'Iron', 'GFAP', 'CD68'});

%% Save
% Save as xlsx
cd(directory.save)
writetable(final_table, 'Iron_and_inflammation_quantities_by_section.xlsx')

% Save as csv
writetable(final_table, 'Iron_and_inflammation_quantities_by_section.csv')
