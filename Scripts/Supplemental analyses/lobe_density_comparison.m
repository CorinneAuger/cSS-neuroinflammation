%% Lobe density comparison

for stain = ['Iron', 'GFAP', 'CD68']

%% Input directories
directory.spreadsheet = '/Volumes/Corinne hard drive/cSS project/Saved data/By section table';
directory.save = '/Volumes/Corinne hard drive/cSS project/Saved data/Lobe comparison';

%% Load data
% Columns in order: brain, lobe, age_at_death, sex_0_male_1_female, PMI, Iron, GFAP, CD68
cd(directory.spreadsheet)
data = xlsread('Iron_and_inflammation_quantities_by_section.xlsx');

%% Get densities
[n, ~] = size(data);

% Preallocate
object_density_by_lobe = NaN(30, 4);

counter = 1;

for i = 1:n
    % Set up 4-column matrix with columns separated by lobe
    if data(i, 2) == 1
        lobe_pos = 1;
    elseif data(i, 2) == 4
        lobe_pos = 2;  
    elseif data(i, 2) == 5
        lobe_pos = 3; 
    elseif data(i, 2) == 7
        lobe_pos = 4; 
    end
    
    % Get number of objects
    if strcmp(stain, 'Iron')
        objects_in_section = data(i, 6);
    elseif strcmp(stain, 'GFAP')
        objects_in_section(counter, lobe_pos) = data(i, 7);
    elseif strcmp(stain, 'CD68')
        objects_in_section(counter, lobe_pos) = data(i, 8);
    end
    
    % Get area
    
    
    % Get density
    object_density_by_lobe(counter, lobe_pos) = objects_in_section/section_area;
    
    counter = counter + 1;
end

%% Make figures
% Set up figure
figure
boxplot(object_density_by_lobe)

% Add labels
xlabel('Lobe', 'FontSize', 20);
xticks([1 2 3 4]);
xticklabels({'Frontal', 'Temporal', 'Parietal', 'Occipital'});
xlim([0.5 4.5]);
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',18)

ylabel('Objects per section')

title(sprintf('%s density by cortical lobe', stain));

% Add scatter plot
for block = [1, 2, 3, 4]
    scatter(block * ones(26,1), object_density(:,block), 'black', '.');
    hold on
end

%% Save

end