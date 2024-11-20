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
        refNormMeanInt = cat(2, cellData.NormMeanIntensity);
        refNormMaxInt = cat(2, cellData.NormMaxIntensity);        
    else
        refNormMeanInt = [refNormMeanInt cat(2, cellData.NormMeanIntensity)];
        refNormMaxInt = [refNormMaxInt cat(2, cellData.NormMaxIntensity)];
    end    
end

th_NormMean = mean(refNormMeanInt, 2, 'omitnan');
th_NormMax = mean(refNormMaxInt, 2, 'omitnan');

%Print a summary
fidSummary = fopen(fullfile(outputDir, 'summary.csv'), 'w');
fprintf(fidSummary, 'File, Number of positive cells (Norm mean), Positive cell IDs (Norm mean), Number (norm Max), ID (norm max)\n');

for iFile = 1:numel(files)

    file = fullfile(files(iFile).folder, files(iFile).name);

    load(file)

    %Determine if cell is positive or not
    hitOrMiss_NormMean = false(numel(cellData(1).NormMeanIntensity), numel(cellData));
    hitOrMiss_NormMax = false(numel(cellData(1).NormMeanIntensity), numel(cellData));

    for iCol = 1:numel(cellData)
        hitOrMiss_NormMean(:, iCol) = cellData(iCol).NormMeanIntensity > th_NormMean;
        hitOrMiss_NormMax(:, iCol) = cellData(iCol).NormMaxIntensity > th_NormMax;
    end

    % %Generate a csv file of the raw data
    [~, fn] = fileparts(file);
    % 
    % fid = fopen(fullfile(outputDir, [fn, '.csv']), 'w');
    % % fprintf(fid, 'Cell ID, Segment 5, Segment 1, Segment 2, ' + ...
    % %     'Segment 5, Segment 3, Segment 4,' + ...
    % %     'Segment 5, Segment 6, Segment 7,' + ...
    % %     'Segment 8, Segment 2\n');
    % 
    % 
    % %Maybe take the brightest of the duplicates in Seg5 and Seg2
    % 
    % fprintf(fid, ['Cell ID, Segment 1, Segment 2, Segment 3, ', ...
    %     'Segment 4, Segment 5, Segment 6,', ...
    %     'Segment 7, Segment 8\n']);
    % 
    % for iCell = 1:size(meanCellIntensity, 1)
    %     % fprintf(fid, '%d, %.2f, %.2f, %.2f, ' + ...
    %     %     '%.2f, %.2f, %.2f,' + ...
    %     %     '%.2f, %.2f, %.2f,' + ...
    %     %     '%.2f, %.2f\n', ...
    %     %     iCell, meanIntensity(iCell, 2), meanIntensity(iCell, 3), meanIntensity(iCell, 4), ...
    %     %     meanIntensity(iCell, 6), meanIntensity(iCell, 7), meanIntensity(iCell, 8), ...
    %     % meanIntensity(iCell, 2), meanIntensity(iCell, 2), meanIntensity(iCell, 2),, ...
    %     % meanIntensity(iCell, 2), meanIntensity(iCell, 2));
    % 
    %     fprintf(fid, ['%d, %.2f, %.2f, %.2f, ', ...
    %         '%.2f, %.2f, %.2f,', ...
    %         '%.2f, %.2f\n'], ...
    %         iCell, meanCellIntensity(iCell, 3), meanCellIntensity(iCell, 4), meanCellIntensity(iCell, 7), ...
    %         meanCellIntensity(iCell, 8), meanCellIntensity(iCell, 2), meanCellIntensity(iCell, 11), meanCellIntensity(iCell, 12), ...
    %         meanCellIntensity(iCell, 15));
    % 
    % end
    % fclose(fid);

    %Find positive cells
    posIDs_normMean = find(all(hitOrMiss_NormMean(:, [3 4 7 8 2 11 12 15]), 2));
    posIDs_normMax = find(all(hitOrMiss_NormMax(:, [3 4 7 8 2 11 12 15]), 2));

    fprintf(fidSummary, '%s, %d,', fn, numel(posIDs_normMean));
    fprintf(fidSummary, '%d,', posIDs_normMean);
    fprintf(fidSummary, '%d,', numel(posIDs_normMax));
    fprintf(fidSummary, '%d,', posIDs_normMax);
    fprintf(fidSummary, '\n');

end

fclose(fidSummary);


end