function [] = cortical_thickness_csv(number_of_brains, number_of_lobes)

% Used in cortical_thickness_vs_iron to save the data.
% Makes a CSV with columns for iron (saved as .mat), cortical thickness (saved as .mat), brain, lobe, sex (saved in spreadsheet), age (saved in spreadsheet), and PMI (saved in spreadsheet) for use in LME model.

clear

%% Enter directories
% "Brain" must be column A and "Lobe" must be column B in by_section_table
% "PMI" must be column E
% GFAP and CD68 counts must be columns G and H
% Cortical thickness measurements must be in columns I-K with mean in column L
directory.by_section_table = '/Volumes/Corinne hard drive/cSS project/Saved data/By section table';
directory.save = '/Volumes/Corinne hard drive/cSS project/Saved data/Cortical thickness';

%% Load table
cd(directory.by_section_table)
by_section_table = readtable('Iron_and_inflammation_quantities_by_section.xlsx');

%% Delete measurement columns 
by_section_table(:, 7:11) = [];

%% Change cortical thickness column name
by_section_table.Properties.VariableNames{7} = 'Cortical_thickness';

%% Change lobe names from 1, 4, 5, and 7 to 1, 2, 3, and 4
[length, ~] = size(by_section_table);
by_section_matrix = table2array(by_section_table);

for i = length:-1:1
    if by_section_matrix(i, 2) == 4
        by_section_table(i, 2) = {2};
    elseif by_section_matrix(i, 2) == 5
        by_section_table(i, 2) = {3};
    elseif by_section_matrix(i, 2) == 7
        by_section_table(i, 2) = {4};
    end
    
    %% Delete rows with NaNs
    if isnan(by_section_matrix(i, 5))
        by_section_table(i,:) = [];
    elseif isnan(by_section_matrix(i, 7))
        by_section_table(i,:) = [];
    end
end

%% Delete ICH sections
[sections, ~] = size(by_section_table);

clear by_section_matrix
by_section_matrix = table2array(by_section_table);

for i = sections:-1:1
    if by_section_matrix(i,4) == 5 && by_section_matrix(i, 5) == 2
        by_section_table(i, :) = [];
    elseif by_section_matrix(i,4) == 5 && by_section_matrix(i, 5) == 4
        by_section_table(i, :) = [];
    elseif by_section_matrix(i,4) == 8 && by_section_matrix(i, 5) == 2
        by_section_table(i, :) = [];
    elseif by_section_matrix(i,4) == 14 && by_section_matrix(i, 5) == 4
        by_section_table(i, :) = [];
    elseif by_section_matrix(i,4) == 21 && by_section_matrix(i, 5) == 2
        by_section_table(i, :) = [];
    end
end
    
%% Save csv file
cd(directory.save)
writetable(by_section_table, 'cortical_thickness_data_without_PMI_NaNs.csv');

end
