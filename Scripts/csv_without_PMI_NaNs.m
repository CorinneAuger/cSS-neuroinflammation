%function [] = csv_without_PMI_NaNs(input_file)

clear

% enter directories
input_directory = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Saved data/CSV files for stats';
scripts_directory = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Scripts';
save_directory = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Saved data/CSV files for stats/No PMI NaNs';

% set up loop through files in directory
cd(input_directory)
directory = dir('*.csv');

for i = 1:numel(directory)
    input_file = directory(i).name;
    
    % read input file
    cd(input_directory)
    input_matrix = csvread(input_file, 1, 0);
    
    % take out rows with NaNs in PMI
    output_matrix = input_matrix;
    [length, ~] = size(input_matrix);
    
    for j = length:-1:1
        if isnan(input_matrix(j,3)) == 1
            output_matrix(j,:) = [];
        end
    end
    
    % get variable names
    tbl = readtable(input_file);
    variable_names = tbl.Properties.VariableNames(:,:);
    
    % make matrix into table
    final_table = array2table(output_matrix, 'VariableNames', variable_names);
    
    % save csv file
    input_file_name = erase(input_file, '.csv');
    ending = '_without_PMI_NaNs.csv';
    save_name = strcat(input_file_name, ending);
    
    cd(save_directory)
    writetable(final_table, save_name);
    
end

cd(scripts_directory)

%end