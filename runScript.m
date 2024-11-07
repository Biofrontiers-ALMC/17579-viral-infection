clearvars
clc

registerImages('D:\Projects\ALMC Tickets\EmmaWS\data\20240912', ...
    'D:\Projects\ALMC Tickets\EmmaWS\Processed\20241107\RegisteredImages');

%%
analyzeImages('D:\Projects\ALMC Tickets\EmmaWS\Processed\20241107\RegisteredImages\H1N1', ...
    'D:\Projects\ALMC Tickets\EmmaWS\Processed\20241107\H1N1')
analyzeImages('D:\Projects\ALMC Tickets\EmmaWS\Processed\20241107\RegisteredImages\H3N2', ...
    'D:\Projects\ALMC Tickets\EmmaWS\Processed\20241107\H3N2')