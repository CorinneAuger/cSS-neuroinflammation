%% Fill in positive slope column on iron spreadsheet

%% Input directories
directory.slopes = '/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel density comparison/GFAP/All variables';
directory.spreadsheet = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Image sizes spreadsheets';

%% Make matrix of which blocks have a positive slope for GFAP/Iron
% Preallocate
spreadsheet_row_count = 0;
positive_GFAP_slope_matrix = NaN(104, 1);

cd(directory.slopes)
for brain = 1:25
    for block = [1, 4, 5, 7]
        spreadsheet_row_count = spreadsheet_row_count + 1;
        variables_file_name = sprintf('CAA%d_%d_GFAP_and_Iron_1pixel_density_comparison_all_variables.mat', brain, block);
        
        if isfile(variables_file_name)
            load(variables_file_name, 'slope')
            close all
            
            if slope > 0
                positive_GFAP_slope_matrix(spreadsheet_row_count) = 1;
            else
                positive_GFAP_slope_matrix(spreadsheet_row_count) = 0;
            end
            
            clear slope
        end
    end
end

%% Write to Excel
spreadsheet_name = 'Aiforia_image_sizes_Iron.xlsx';

table = array2table(positive_GFAP_slope_matrix);

cd(directory.spreadsheet)
writetable(table, spreadsheet_name, 'Sheet', 1, 'Range', 'F1:F105')

