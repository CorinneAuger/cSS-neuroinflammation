%% Iron interval bar graph

%% Toggles
only_count_cSS = 0;
% count everything = 0
% positive slope = 1
% cSS within the brain from MRI = 2

%% Input directories
directory.input = '/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel density comparison/CD68/Crucial variables';
directory.excel = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Image sizes spreadsheets';
directory.save = '/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel interval analysis/Interval pixel counts bar graph';

%% Set up loop
cd(directory.input)
all_files = dir('**/*.mat');
number_of_files = length(all_files);

interval_pixel_counts = zeros(1,4);

for i = 1 : number_of_files
    %% Import stat_iron
    cd(directory.input)
    file_name = convertCharsToStrings(all_files(i).name);
    load(file_name, 'stat_iron');
    
    %% Get brain and block
    brain_block = extractBefore(file_name, '_CD68');
    
    %% Only count sections with positive slope
    % Toggle
    if only_count_cSS == 1 || only_count_cSS == 2
        cd(directory.excel)
        exclusion_table = readtable('Aiforia_image_sizes_Iron.xlsx');
        row_number = find(strcmp(convertCharsToStrings(exclusion_table{:,1}), brain_block));
        
        if only_count_cSS == 1
            positive_slope = exclusion_table{row_number, 6};
        elseif only_count_cSS == 2
            positive_slope = exclusion_table{row_number, 5};
        end
        
        if positive_slope == 1
            %% Count pixels in intervals for section
            [size_x, size_y] = size(stat_iron);
            section_count = zeros(1,4);
            
            for x = 1 : size_x
                for y = 1 : size_y
                    if stat_iron(x,y) <= 5
                        section_count(1) = section_count(1) + 1;
                    elseif stat_iron(x,y) > 5 && stat_iron(x,y) <= 15
                        section_count(2) = section_count(2) + 1;
                    elseif stat_iron(x,y) > 15 && stat_iron(x,y) <= 25
                        section_count(3) = section_count(3) + 1;
                    elseif stat_iron(x,y) > 25
                        section_count(4) = section_count(4) + 1;
                    end
                end
            end
            
            %% Add to overall count
            interval_pixel_counts(1) = interval_pixel_counts(1) + section_count(1);
            interval_pixel_counts(2) = interval_pixel_counts(2) + section_count(2);
            interval_pixel_counts(3) = interval_pixel_counts(3) + section_count(3);
            interval_pixel_counts(4) = interval_pixel_counts(4) + section_count(4);
            
            %% Reset for next iteration
            clearvars -except directory all_files number_of_files i interval_pixel_counts only_count_cSS
        end
    else
        %% Count pixels in intervals for section
        [size_x, size_y] = size(stat_iron);
        section_count = zeros(1,4);
        
        for x = 1 : size_x
            for y = 1 : size_y
                if stat_iron(x,y) <= 5
                    section_count(1) = section_count(1) + 1;
                elseif stat_iron(x,y) > 5 && stat_iron(x,y) <= 15
                    section_count(2) = section_count(2) + 1;
                elseif stat_iron(x,y) > 15 && stat_iron(x,y) <= 25
                    section_count(3) = section_count(3) + 1;
                elseif stat_iron(x,y) > 25
                    section_count(4) = section_count(4) + 1;
                end
            end
        end
        
        %% Add to overall count
        interval_pixel_counts(1) = interval_pixel_counts(1) + section_count(1);
        interval_pixel_counts(2) = interval_pixel_counts(2) + section_count(2);
        interval_pixel_counts(3) = interval_pixel_counts(3) + section_count(3);
        interval_pixel_counts(4) = interval_pixel_counts(4) + section_count(4);
        
        %% Reset for next iteration
        clearvars -except directory all_files number_of_files i interval_pixel_counts only_count_cSS
    end
end

%% Make bar graph
% Set bar labels
X = categorical({'Very low','Low','Medium','High'});
X = reordercats(X,{'Very low','Low','Medium','High'});

% Make graph
figure;
bar_graph = bar(X, interval_pixel_counts);

%% Save
cd(directory.save)
if only_count_cSS == 1
    saveas(gcf, 'Iron_interval_bar_graph_only_positive_slopes.png');
    save('Interval_pixel_counts_only_positive_slopes.mat', 'interval_pixel_counts')    
elseif only_count_cSS == 2
    saveas(gcf, 'Iron_interval_bar_graph_only_cSS_in_brain.png');
    save('Interval_pixel_counts_only_cSS_in_brain.mat', 'interval_pixel_counts')    
else
    saveas(gcf, 'Iron_interval_bar_graph.png');
    save('Interval_pixel_counts.mat', 'interval_pixel_counts')
end
