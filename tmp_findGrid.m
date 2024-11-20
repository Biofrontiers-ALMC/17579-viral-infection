clearvars
clc

fn = 'D:\Projects\ALMC Tickets\EmmaWS\Processed\20241107\RegisteredImages\H3N2\well_1_D10.tif';

Igrid_2 = double(imread(fn, 2));
Igrid_2 = (Igrid_2 - mean(Igrid_2, 'all'))/std(Igrid_2, 0, 'all');

Igrid_5 = double(imread(fn, 5));
Igrid_5 = (Igrid_5 - mean(Igrid_5, 'all'))/std(Igrid_5, 0, 'all');

Igrid_10 = double(imread(fn, 10));
Igrid_10 = (Igrid_10 - mean(Igrid_10, 'all'))/std(Igrid_10, 0, 'all');

Igrid_13= double(imread(fn, 13));
Igrid_13 = (Igrid_13 - mean(Igrid_13, 'all'))/std(Igrid_13, 0, 'all');

Isum = max(cat(3, Igrid_2, Igrid_5, Igrid_10, Igrid_13),[], 3);

imshow(Isum, [])