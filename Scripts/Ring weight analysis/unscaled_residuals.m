%% Residual analysis
% Compares the error between the best predicted GFAP heat map and the real one for each slide.

clear

scale_residuals = 0; % toggle on and off
inflammatory_marker = 'GFAP';
patch_size_microns = 500;

%% Input directories (input directory is later bc it changes with number of columns)
directory.density_map = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel density comparison/%s/Crucial variables', inflammatory_marker);

if scale_residuals == 0
    directory.save = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel ring weight analysis/%s (1-tailed)/Residual comparison/Non-normalized', inflammatory_marker);
elseif scale_residuals == 1
    directory.save = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel ring weight analysis/%s (1-tailed)/Residual comparison/Normalized', inflammatory_marker);
end 

%% Preallocate
all_residuals = NaN(25, 7, 4);

%% Load data
for number_of_columns = 1:4
    
    % Input directory
    directory.input = sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel ring weight analysis/%s (1-tailed)/%d column/By section', inflammatory_marker, number_of_columns);
    
    for brain = 1:25
        for block = [1 4 5 7]
            
            variables_file_name = sprintf('CAA%d__%d_%s_and_Iron_best_weights_%d_column.mat', brain, block, inflammatory_marker, number_of_columns);
            cd(directory.input)
            
            % Allow sections to be excluded
            if isfile(variables_file_name)
                
                % Load ring weight analysis variables
                load(variables_file_name, 'minima', 'inflammation_median')
                
                if scale_residuals == 0
                    section_residual = minima(1) * inflammation_median;
                elseif scale_residuals == 1
                    section_residual = minima(1);
                end
                
                % Add to overall matrix
                all_residuals(brain, block, number_of_columns) = section_residual;
                
                % Clear for next loop iteration
                clear section_residual minima inflammation_median
                
            end
        end
    end
end

%% Make figure
% Reformat residuals matrix
all_residuals_reformatted = NaN(175, 4);

for i = 1:4
    all_residuals_reformatted(:, i) = reshape(all_residuals(:,:,i), [175, 1]);
end

% Set up figure
figure
boxplot(all_residuals_reformatted)
xticklabels({'Pixel', 'Pixel + 1 ring', 'Pixel + 2 rings', 'Pixel + 3 rings'})
ylabel('Mean difference between predicted and actual GFAP objects per 500µm * µm pixel', 'FontSize', 14)
set(gcf, 'position', [1 1 651 614])

if scale_residuals == 0
    title('Non-normalized residuals by number of rings');
elseif scale_residuals == 1
    title('Normalized residuals by number of rings');
end

% Add scatter plot
hold on
for column = 1:4
    scatter(column * ones(175,1), all_residuals_reformatted(:,column), 'black', '.');
    hold on
end

%% Save
cd(directory.save)

if scale_residuals == 0
    save('GFAP_ring_weight_non-normalized_residuals', 'all_residuals');
    saveas(gcf, 'GFAP_ring_weight_non-normalized_residual_plot.png');
elseif scale_residuals == 1
    save('GFAP_ring_weight_normalized_residuals', 'all_residuals');
    saveas(gcf, 'GFAP_ring_weight_normalized_residual_plot.png');
end
