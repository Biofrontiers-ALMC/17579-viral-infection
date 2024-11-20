function exportData(inputDir, outputDir, refFiles)

%Segment 1 - Image 3 (cyto)
%Segment 2 - Image 4 (cyto)
%Segment 3 - Image 7 (cyto)
%Segment 4 - Image 8 (cyto)
%Segment 5 - Image 2 (cyto)
%Segment 6 - Image 11 (cyto)
%Segment 7 - Image 12 (cyto)
%Segment 8 - Image 15 (cyto)

files = dir(fullfile(inputDir, '*.mat'));

if isempty(files)
    error('exportData:FilesNotFound', ...
        'No MAT-files were found.')
end

%Parse the reference files first to get threshold values

for iRefs = 1:numel(refFiles)
    load(fullfile(inputDir, refFiles{iRefs}));

    if iRefs == 1
        allCytoInt = upperPrctileIntensity;
    else
        allCytoInt = [allCytoInt; upperPrctileIntensity];
    end
    
end

thresholds = mean(allCytoInt, 1, 'omitnan') %+ 0.25 * std(allCytoInt, 1, 1, 'omitnan')
%thresholds = max(allCytoInt, 1);

%Print a summary
fidSummary = fopen(fullfile(outputDir, 'summary.csv'), 'w');
fprintf(fidSummary, 'File, Number of positive cells, Positive cell IDs\n');

for iFile = 1:numel(files)

    file = fullfile(files(iFile).folder, files(iFile).name);

    load(file)

    %Determine if cell is positive or not
    hitOrMiss = false(size(upperPrctileIntensity));
    for iCol = 1:size(upperPrctileIntensity, 2)
        hitOrMiss(:, iCol) = upperPrctileIntensity(:, iCol) > thresholds(iCol);
    end


    %Generate a csv file of the raw data
    [~, fn] = fileparts(file);

    fid = fopen(fullfile(outputDir, [fn, '.csv']), 'w');
    % fprintf(fid, 'Cell ID, Segment 5, Segment 1, Segment 2, ' + ...
    %     'Segment 5, Segment 3, Segment 4,' + ...
    %     'Segment 5, Segment 6, Segment 7,' + ...
    %     'Segment 8, Segment 2\n');


    %Maybe take the brightest of the duplicates in Seg5 and Seg2

    fprintf(fid, ['Cell ID, Segment 1, Segment 2, Segment 3, ', ...
        'Segment 4, Segment 5, Segment 6,', ...
        'Segment 7, Segment 8\n']);

    for iCell = 1:size(meanCellIntensity, 1)
        % fprintf(fid, '%d, %.2f, %.2f, %.2f, ' + ...
        %     '%.2f, %.2f, %.2f,' + ...
        %     '%.2f, %.2f, %.2f,' + ...
        %     '%.2f, %.2f\n', ...
        %     iCell, meanIntensity(iCell, 2), meanIntensity(iCell, 3), meanIntensity(iCell, 4), ...
        %     meanIntensity(iCell, 6), meanIntensity(iCell, 7), meanIntensity(iCell, 8), ...
        % meanIntensity(iCell, 2), meanIntensity(iCell, 2), meanIntensity(iCell, 2),, ...
        % meanIntensity(iCell, 2), meanIntensity(iCell, 2));

        fprintf(fid, ['%d, %.2f, %.2f, %.2f, ', ...
            '%.2f, %.2f, %.2f,', ...
            '%.2f, %.2f\n'], ...
            iCell, meanCellIntensity(iCell, 3), meanCellIntensity(iCell, 4), meanCellIntensity(iCell, 7), ...
            meanCellIntensity(iCell, 8), meanCellIntensity(iCell, 2), meanCellIntensity(iCell, 11), meanCellIntensity(iCell, 12), ...
            meanCellIntensity(iCell, 15));

    end
    fclose(fid);

    %Find positive cells
    posIDs = find(all(hitOrMiss(:, [3 4 7 8 2 11 12 15]), 2));

    fprintf(fidSummary, '%s, %d,', fn, numel(posIDs));
    fprintf(fidSummary, '%d,', posIDs);
    fprintf(fidSummary, '\n');

end

fclose(fidSummary);


end