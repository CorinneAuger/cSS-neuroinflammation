function [] = cortical_thickness_csv(number_of_brains, number_of_lobes)

clear

% inputs
number_of_brains = 25;
number_of_lobes = 7;

% enter directories
input_directory = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Saved data/Cortical thickness vs. iron';
spreadsheet_directory = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Image sizes spreadsheets';
save_directory = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Saved data/CSV files for stats';

% make thickness column
cd(input_directory);
load('Cortical_thickness_vs_Iron_by_section_variables.mat', 'all_cortical_thickness');
cortical_thickness_column = all_cortical_thickness';

% make iron column
cd(input_directory)
load('Cortical_thickness_vs_Iron_by_section_variables.mat', 'all_iron_objects');
iron_column = all_iron_objects';

% make brains column
[length, ~] = size(iron_column);
brains_column = NaN(length, 1);

for i = 1:length
    remainder = rem(i,number_of_brains);
    if remainder == 0
        remainder = number_of_brains;
    end
    brains_column(i) = remainder;
end

% make lobes column
lobes_matrix = repmat((1:number_of_lobes), [number_of_brains,1]);
lobes_column = reshape(lobes_matrix, [length, 1]);

for i = 1:length
    if lobes_column(i) == 4
        lobes_column(i) = 2;
    elseif lobes_column(i) == 5
        lobes_column(i) = 3;
    elseif lobes_column(i) == 7
        lobes_column(i) = 4;
    end
end

% make age, sex, and PMI columns
age_column = NaN(length,1);
sex_column = NaN(length,1);
PMI_column = NaN(length,1);

cd(spreadsheet_directory)
case_info_table = readtable('Case_info_03012022.xlsx');

for i = 1:length
    CAA_brain_name = sprintf('CAA%d', brains_column(i));
    table_brain_coordinate = find(ismember(case_info_table{:,1},{CAA_brain_name}),2);
    age_column(i) = str2double(case_info_table.AgeAtDeath(table_brain_coordinate));
    sex_column(i) = strcmp(case_info_table.Sex(table_brain_coordinate), 'F');
    PMI_column(i) = str2double(case_info_table.PMI(table_brain_coordinate));
end

% combine columns in matrix (indep variable 2nd to last, dep variable last)
matrix_with_NaNs = [age_column, sex_column, PMI_column, brains_column, lobes_column, iron_column, cortical_thickness_column];

% sort rows so brains and lobes are in order (adjust based on variables)
sorted_matrix_with_NaNs = sortrows(matrix_with_NaNs, [4,5]);

% delete rows with NaNs
final_matrix = sorted_matrix_with_NaNs;
[~, variables] = size(final_matrix);

for i = length:-1:1
    if isnan(sorted_matrix_with_NaNs(i,variables)) == 1
        final_matrix(i,:) = [];
    end
end

% make table
final_table = array2table(final_matrix, 'VariableNames', {'Age_at_death', 'Sex_0_male_1_female', 'PMI', 'Brain', 'Lobe', 'Iron', 'Cortical_thickness'});

% save csv file
cd(save_directory)
writetable(final_table, 'cortical_thickness_data.csv');

end