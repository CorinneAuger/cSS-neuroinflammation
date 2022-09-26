%% Is fibrin associated with iron?

clear
close all

cd '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Saved data/Lobe comparisons'

load 'Lobe_comparison_matrix_Fibrin.mat';
Fibrin_matrix = reshape(object_density, [104,1]);
clear object_density

load 'Lobe_comparison_matrix_Iron.mat';
Iron_matrix = reshape(object_density, [104,1]);
clear object_density

figure;
scatter(Iron_matrix, Fibrin_matrix, 'black', '.');
xlabel('Iron density', 'FontSize', 20);
ylabel('Vascular fibrin density', 'FontSize', 20);

linear_model = fitlm(Iron_matrix', Fibrin_matrix');
coefs = linear_model.Coefficients.Estimate;
y_intercept = coefs(1); 
slope = coefs(2);
refline(slope, y_intercept);
R_squared = linear_model.Rsquared.Ordinary;

fibrin_vs_iron = [Iron_matrix, Fibrin_matrix];

cd '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Saved data/Fibrin vs. iron'
save('Fibrin_vs_iron_variables.mat');
saveas(gcf, 'Fibrin_vs_iron_scatter.png');
