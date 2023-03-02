%% Temporary

clear

for jj = 1:3
    
    if jj == 1
        stain = 'Iron';
    elseif jj == 2
        stain = 'GFAP';
    elseif jj == 3
        stain = 'CD68';
    end
    
    cd(sprintf('/Volumes/Corinne hard drive/cSS project/Saved data/Edge analysis/Individual slides/%s 1000um/Variables', stain))
    files = struct2cell(dir);
    [~, length] = size(files);    

    for ii = 1:length
        if contains(files{1, ii}, 'CAA')
            load(files{1, ii})
            clear heat_map_file_name_CD68 heat_map_file_name_GFAP figure_save_name
            save(files{1, ii})
            
            clearvars -except stain jj ii files length
        end
    end
end
