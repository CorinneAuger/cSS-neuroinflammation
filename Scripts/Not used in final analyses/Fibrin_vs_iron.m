%% Is fibrin associated with iron?

%% Input directories
directory.lobe_comparisons = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Saved data/Lobe comparisons';
directory.save = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Saved data/Fibrin vs. iron';

clear
close all

cd(directory.lobe_comparisons)

%% Load fibrin and iron densities for each section
load 'Lobe_comparison_matrix_Fibrin.mat';
Fibrin_matrix = reshape(object_density, [104,1]);
clear object_density

load 'Lobe_comparison_matrix_Iron.mat';
Iron_matrix = reshape(object_density, [104,1]);
clear object_density

%% Make figure
figure;
scatter(Iron_matrix, Fibrin_matrix, 'black', '.');
xlabel('Iron density', 'FontSize', 20);
ylabel('Vascular fibrin density', 'FontSize', 20);

%% Get stats for figure
linear_model = fitlm(Iron_matrix', Fibrin_matrix');
coefs = linear_model.Coefficients.Estimate;
y_intercept = coefs(1);
slope = coefs(2);
refline(slope, y_intercept);
R_squared = linear_model.Rsquared.Ordinary;

%% Make matrix to save
fibrin_vs_iron = [Iron_matrix, Fibrin_matrix];

%% Save
cd(directory.save)
save('Fibrin_vs_iron_variables.mat');
saveas(gcf, 'Fibrin_vs_iron_scatter.png');
