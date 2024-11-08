function exportData(file)

%Segment 1 - Image 3
%Segment 2 - Image 4
%Segment 3 - Image 7
%Segment 4 - Image 8
%Segment 5 - Image 6
%Segment 6 - Image 11
%Segment 7 - Image 12
%Segment 8 - Image 15

load(file)

%Count cells which are all positive
nPos = find(all(hitOrMiss(:, [3 4 7 8 6 11 12 15]), 2))

%Count


end