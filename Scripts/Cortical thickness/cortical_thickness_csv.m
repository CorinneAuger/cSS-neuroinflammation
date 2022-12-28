function [] = cortical_thickness_csv(number_of_brains, number_of_lobes)

% Used in cortical_thickness_vs_iron to save the data.
% Makes a CSV with columns for iron (saved as .mat), cortical thickness (saved as .mat), brain, lobe, sex (saved in spreadsheet), age (saved in spreadsheet), and PMI (saved in spreadsheet) for use in LME model.

clear

%% Enter inputs
number_of_brains = 25;
number_of_lobes = 7;

%% Enter directories
directory.input = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Saved data/Cortical thickness vs. iron';
directory.spreadsheets = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Image sizes spreadsheets';
directory.save = '/Volumes/Corinne hard drive/cSS project/Saved data/Cortical thickness';

%% Make thickness column
cd(directory.input);
load('Cortical_thickness_vs_Iron_by_section_variables.mat', 'all_cortical_thickness');
cortical_thickness_column = all_cortical_thickness';

%% Make iron column
cd(directory.input)
load('Cortical_thickness_vs_Iron_by_section_variables.mat', 'all_iron_objects');
iron_column = all_iron_objects';

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

for i = 1:length
    if lobes_column(i) == 4
        lobes_column(i) = 2;
    elseif lobes_column(i) == 5
        lobes_column(i) = 3;
    elseif lobes_column(i) == 7
        lobes_column(i) = 4;
    end
end

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
matrix_with_NaNs = [age_column, sex_column, PMI_column, brains_column, lobes_column, iron_column, cortical_thickness_column];

%% Sort rows so brains and lobes are in order (adjust based on variables)
sorted_matrix_with_NaNs = sortrows(matrix_with_NaNs, [4,5]);

%% Delete rows with NaNs
final_matrix = sorted_matrix_with_NaNs;
[~, variables] = size(final_matrix);

for i = length:-1:1
    if isnan(sorted_matrix_with_NaNs(i,variables)) == 1
        final_matrix(i,:) = [];
    end
end

[sections, ~] = size(final_matrix);

for j = sections:-1:1
    if isnan(final_matrix(j,3)) == 1
        final_matrix(j,:) = [];
    end
end

%% Delete ICH sections
[sections, ~] = size(final_matrix);

for i = sections:-1:1
    if final_matrix(i,4) == 5 && final_matrix(i, 5) == 2
        final_matrix(i, :) = [];
    elseif final_matrix(i,4) == 5 && final_matrix(i, 5) == 4
        final_matrix(i, :) = [];
    elseif final_matrix(i,4) == 8 && final_matrix(i, 5) == 2
        final_matrix(i, :) = [];
    elseif final_matrix(i,4) == 14 && final_matrix(i, 5) == 4
        final_matrix(i, :) = [];
    elseif final_matrix(i,4) == 21 && final_matrix(i, 5) == 2
        final_matrix(i, :) = [];
    end
end
    
%% Make table
final_table = array2table(final_matrix, 'VariableNames', {'Age_at_death', 'Sex_0_male_1_female', 'PMI', 'Brain', 'Lobe', 'Iron', 'Cortical_thickness'});

%% Save csv file
cd(directory.save)
writetable(final_table, 'cortical_thickness_data_without_PMI_NaNs.csv');

end
