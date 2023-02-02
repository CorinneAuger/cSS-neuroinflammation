function [] = ring_weight_csv(inflammatory_marker, number_of_columns)
% Makes a CSV of ring weight data for use in making linear mixed effects models in R.
% We haven't been assessing them with LME models after all, so this isn't useful.

%% Input directories
directory.input = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel ring weight analysis/%s (1-tailed)/%d column/Composite', inflammatory_marker, number_of_columns);
directory.spreadsheet = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Image sizes spreadsheets';
directory.scripts = '/Volumes/Corinne hard drive/cSS project/Scripts';
directory.save = directory.input;

%% Load og_matrix
cd(directory.input)
file_name = sprintf('%s_and_Iron_1pixel_%d_column_ring_weight_analysis_variables.mat', inflammatory_marker, number_of_columns);
load(file_name, 'top_weight_for_each_section');
og_matrix = top_weight_for_each_section;

%% Make weights column
clearvars -except og_matrix directory inflammatory_marker number_of_columns
cd(directory.input)
[size_x, size_y] = size(og_matrix);
weights_column = reshape(og_matrix, [(size_x * size_y), 1]);

%% Make brains column
brains_matrix = repmat((1:(size_x * size_y)/16)', 1, 4)';
quarter_of_brains_column = reshape(brains_matrix, [(size_x * size_y)/4, 1]);
brains_column = repmat(quarter_of_brains_column, 4, 1);

%% Make rings column (0 = pixel; 1 = 1st ring, etc.)
rings_matrix = NaN(((size_x * size_y)/4), 4);
for column_no = 1:4
    rings_matrix(:,column_no) = column_no - 1;
end
rings_column = reshape(rings_matrix, [(size_x * size_y), 1]);

%% Make age, sex, and PMI columns
age_column = NaN((size_x * size_y),1);
sex_column = NaN((size_x * size_y),1);
PMI_column = NaN((size_x * size_y),1);

cd(directory.spreadsheet)
case_info_table = readtable('Case_info_03012022.xlsx');

for i = 1:(size_x * size_y)
    CAA_brain_name = sprintf('CAA%d', brains_column(i));
    table_brain_coordinate = find(ismember(case_info_table{:,1},{CAA_brain_name}),2);
    age_column(i) = str2double(case_info_table.AgeAtDeath(table_brain_coordinate));
    sex_column(i) = strcmp(case_info_table.Sex(table_brain_coordinate), 'F');
    PMI_column(i) = str2double(case_info_table.PMI(table_brain_coordinate));
end

%% Make lobes column
lobes_column = NaN((size_x*size_y), 1);

for i = 1:(size_x * size_y)
    remainder = rem(i,4);
    if remainder == 0
        remainder = 4;
    end
    lobes_column(i) = remainder;
end

%% Combine columns in matrix (indep variable 2nd to last, dep variable last)
matrix_with_NaNs = [age_column, sex_column, PMI_column, brains_column, lobes_column, rings_column, weights_column];

%% Sort rows so brains and lobes are in order (adjust based on variables)
sorted_matrix_with_NaNs = sortrows(matrix_with_NaNs, [4,5]);

%% Delete rows with NaNs
final_matrix = sorted_matrix_with_NaNs;
[~, variables] = size(final_matrix);

for i = (size_x * size_y):-1:1
    if isnan(sorted_matrix_with_NaNs(i,variables)) == 1
        final_matrix(i,:) = [];
    end
end

%% Make table
final_table = array2table(final_matrix, 'VariableNames', {'Age_at_death', 'Sex_0_male_1_female', 'PMI', 'Brain', 'Lobe', 'Ring', 'Weight'});

%% Save csv file
cd(directory.save)
save_name = sprintf('1-tailed_early_%s_%d_column_ring_weight_data.csv', inflammatory_marker, number_of_columns);
writetable(final_table, save_name);

end
