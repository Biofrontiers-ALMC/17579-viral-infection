clearvars
clc

registerImages('D:\Projects\ALMC Tickets\EmmaWS\data\20240912', ...
    'D:\Projects\ALMC Tickets\EmmaWS\Processed\20241107\RegisteredImages');

%%
analyzeImages('D:\Documents\OneDrive - UCB-O365\Shared\temp2\Processed\20241107\RegisteredImages\H1N1', ...
    'D:\Documents\OneDrive - UCB-O365\Shared\temp2\Processed\20241107\H1N1')
analyzeImages('D:\Documents\OneDrive - UCB-O365\Shared\temp2\Processed\20241107\RegisteredImages\H3N2', ...
    'D:\Documents\OneDrive - UCB-O365\Shared\temp2\Processed\20241107\H3N2')