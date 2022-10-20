%% Layer analysis CSV
% Makes a CSV for use in R for the layer analysis

%% User input 
% Load the matrix yourself
stain = 'CD68';
og = CD68;

%% Input directory
directory.save = '/Users/corinneauger/Desktop/CSVs for R graphs';

%% Take out unwanted things
first_five = og(:, 1:5);
first_five(any(isnan(first_five), 2), :) = [];

%% Make x column
[x, y] = size(first_five);
for_x_column = ones(x, y);

for i = 1:y
    for_x_column(:, i) = i;
end

x_column = reshape(for_x_column, [(x*y), 1]);

%% Make y column
y_column = reshape(first_five, [(x*y), 1]);

%% Combine
matrix = [x_column, y_column];
final_table = array2table(matrix, 'VariableNames', {'Layer', 'Density'});

%% Make CSV
cd(directory.save)
writetable(final_table, sprintf('%s_1000um_layer_data.csv', stain));
