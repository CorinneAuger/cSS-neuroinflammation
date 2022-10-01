%% Cortical thickness vs. iron (separate scripts for by brain and by section)

% Assembles matrices and makes scatter plots for comparing cortical thickness to iron without a LME model.
% Converts matrix to csv at the end, using another scipt, so it can be used in R to make an LME model.

%% Input directories
directory.IA_details = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/IA details';
directory.image_sizes_spreadsheets = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Image sizes spreadsheets';
directory.save = '/Volumes/Corinne hard drive/cSS project/Saved data/Cortical thickness'
directory.scripts = '/Volumes/Corinne hard drive/cSS project/Scripts/Cortical thickness';

%% By brain

clear
close all

cd(directory.IA_details)

%% Get number of iron objects for each brain
brain_iron_objects = NaN(25,1);

for brain = [1:3, 5, 7:9, 11, 13:15, 17, 18, 20:25]

    brain_iron_objects(brain) = 0;
    brain_str = num2str(brain);

    for block = [1, 4, 5, 7]
        block_str = num2str(block);
        Aiforia_details_sheet_name = join(['IA_details__CAA', brain_str, '_', block_str, '_Iron.xlsx']);

        Aiforia_details_table = readtable(Aiforia_details_sheet_name);
        Aiforia_details_matrix = Aiforia_details_table{:,22};

        object_centers_x = Aiforia_details_matrix(~isnan(Aiforia_details_matrix));
        [block_iron_objects, ~] = size(object_centers_x);

        brain_iron_objects(brain) = brain_iron_objects(brain) + block_iron_objects;
    end
end

%% Get cortical thickness measurements for each brain
cortical_thickness_for_brain = NaN(25,1);

cd(directory.image_sizes_spreadsheets)

cortical_thickness_table = readtable('Cortical thickness measurements 3.2022 - Copy.xlsx');
cortical_thickness_matrix = cortical_thickness_table{:,6};

for brain = [1:3, 5, 7:9, 11, 13:15, 17, 18, 20:25]
    cortical_thickness_for_block = NaN(7,1);

    for block = [1, 4, 5, 7]
        if block == 1
            place_in_list = brain * 4 - 3;
        elseif block == 2
            place_in_list = brain * 4 - 2;
        elseif block == 3
            place_in_list = brain * 4 - 1;
        else
            place_in_list = brain * 4;
        end

        cortical_thickness_for_block(block) = cortical_thickness_matrix(place_in_list);
    end
    cortical_thickness_for_brain(brain) = nanmean(cortical_thickness_for_block);
    clear cortical_thickness_for_block
end

%% Make scatter plot
figure;
scatter(brain_iron_objects, cortical_thickness_for_brain, 25, '.', 'black');
xlabel('Iron-positive cells')
ylabel('Cortical thickness (mm)')

linear_model = fitlm(brain_iron_objects, cortical_thickness_for_brain);
coefs = linear_model.Coefficients.Estimate;
y_intercept = coefs(1);
slope = coefs(2);
refline(slope, y_intercept);

%% Save
cd(directory.save)
save('Cortical_thickness_vs_Iron_by_brain_variables.mat');
saveas(gcf, 'Cortical_thickness_vs_Iron_by_brain_figure.png');

%% By section

clear
close all

cd(directory.IA_details)

%% Get number of Iron objects for each block
weird_format_all_iron_objects = NaN(25,7);

for brain = [1:3, 5, 7:9, 11, 13:15, 17, 18, 20:25]

    brain_iron_objects(brain) = 0;
    brain_str = num2str(brain);

    for block = [1, 4, 5, 7]
        block_str = num2str(block);
        Aiforia_details_sheet_name = join(['IA_details__CAA', brain_str, '_', block_str, '_Iron.xlsx']);

        Aiforia_details_table = readtable(Aiforia_details_sheet_name);
        Aiforia_details_matrix = Aiforia_details_table{:,22};

        object_centers_x = Aiforia_details_matrix(~isnan(Aiforia_details_matrix));
        [block_iron_objects, ~] = size(object_centers_x);

        weird_format_all_iron_objects(brain, block) = block_iron_objects;
    end
end

all_iron_objects = reshape(weird_format_all_iron_objects, [1, 175]);

%% Get cortical thickness measurements for each brain
weird_format_all_cortical_thickness = NaN(25,7);

cd(directory.image_sizes_spreadsheets)

cortical_thickness_table = readtable('Cortical thickness measurements 3.2022 - Copy.xlsx');
cortical_thickness_matrix = cortical_thickness_table{:,6};

for brain = [1:3, 5, 7:9, 11, 13:15, 17, 18, 20:25]
    cortical_thickness_for_block = NaN(7,1);

    for block = [1, 4, 5, 7]
        if block == 1
            place_in_list = brain * 4 - 3;
        elseif block == 2
            place_in_list = brain * 4 - 2;
        elseif block == 3
            place_in_list = brain * 4 - 1;
        else
            place_in_list = brain * 4;
        end

        cortical_thickness_for_block(block) = cortical_thickness_matrix(place_in_list);
    end
    weird_format_all_cortical_thickness(brain, :) = cortical_thickness_for_block;
    clear cortical_thickness_for_block
end

all_cortical_thickness = reshape(weird_format_all_cortical_thickness, [1, 175]);

%% Make scatter plot
figure;
scatter(all_iron_objects, all_cortical_thickness, 150, '.', 'black');
xlabel('Iron-positive cells (x10^4)')
ylabel('Cortical thickness (mm)')

%% Add line
linear_model = fitlm(all_iron_objects, all_cortical_thickness);
coefs = linear_model.Coefficients.Estimate;
y_intercept = coefs(1);
slope = coefs(2);
%line = refline(slope, y_intercept);
hold on
%line.LineWidth = 2;

%% Make axis labels bigger
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',18)
b = get(gca,'YTickLabel');
set(gca,'YTickLabel',b,'fontsize',18)

%% Save
cd(directory.save)
save('Cortical_thickness_vs_Iron_by_section_variables.mat');
saveas(gcf, 'Cortical_thickness_vs_Iron_by_section_figure.png');

%% Convert to csv
cd(directory.scripts)
cortical_thickness_csv(25, 7)
