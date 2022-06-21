% Annotated Old Scans

%% Input needed
% reference   = 'Text Files/Scan 20-11-19-12.00.txt';
% reference   = 'Text Files/Reference Scan 20-12-03-14.00.txt'; %December
% reference   = 'Text Files/Reference Scan 21-01-07-10.00.txt'; %January
% reference    = 'Text Files/Bad Reference Scan 22-02-15-5.00 - some magnets in.txt'; %February
% reference_file  = 'Text Files/2022-02-25-10.37.txt'; %February reference


file        = reference;

% December Tuning (first 40 mag)
% file        = 'Text Files/Scan 20-12-03-19.00.txt'; 
% file        = 'Text Files/Scan 20-12-04-16.00.txt';
% file        = 'Text Files/Scan 20-12-04-18.00.txt';
% file        = 'Text Files/Scan 20-12-06-13.00.txt';

% January Tuning
% file        = 'Text Files/Scan 21-01-08-18.00.txt'; %After shimming 
% file        = 'Text Files/Scan 21-01-11-10.00.txt'; %After shimming
% file        = 'Text Files/Scan 21-01-12-12.00.txt'; %After Bxy-field      (1)
% file        = 'Text Files/Scan 21-01-12-16.00.txt'; %After Bxy-field      (2)
% file        = 'Text Files/Scan 21-01-13-17.00.txt'; %After Bxy-slippage   (3)
% file        = 'Text Files/Scan 21-01-14-12.00.txt'; %After Bz-field       (4)
% file        = 'Text Files/Scan 21-01-14-16.00.txt'; %After Bxy-slippage   (5)
% file        = 'Text Files/Scan 21-01-15-11.00.txt'; %After Bxy-slippage   (6)
% file        = 'Text Files/Scan 21-01-15-14.00.txt'; %After Bxy-slippage   (7)
% file        = 'Text Files/Scan 21-01-21-8.00.txt';  %After Bxy-slippage   (8)
% file        = 'Text Files/Scan 21-01-21-14.00.txt'; %After Bxy-slippage   (9)
% file        = 'Text Files/Scan 21-01-22-10.00.txt'; %After Bxy-slippage   (10)
% 
% May Tuning
% file        = 'Text Files/Scan 21-05-03-11.00.txt'; %Test run
% file        = 'Text Files/Scan 21-05-04-8.00.txt'; %Test run
% file        = 'Text Files/Scan 21-05-05-16.00.txt'; %Test run (same fields as previous)
% reference = file;

% February Tuning (aborted due to issues with magnets pushing vacuum pipe)
% scan_file       = 'Text Files/2022-02-25-16.51.txt'; %Jason tuned Bxy (magnets slipped)
% scan_file       = 'Text Files/2022-02-28-14.51.txt'; %Reset magnets, Jason tuned Bxy
% scan_file       = 'Text Files/2022-03-01-15.04.txt'; %Jason tuned Bxy
% scan_file       = 'Text Files/2022-03-02-15.47.txt'; %Andrew tuned Bz (only By magnets)
% scan_file       = 'Text Files/2022-03-03-10.17.txt'; %Testing offset vacuum pipe 

% March Tuning (aborted because pipe hit again, going to try stronger tensioning
% reference_file  = 'Text Files/2022-03-03-15.16.txt'; %March reference
% scan_file       = 'Text Files/2022-03-03-17.47.txt'; % Tuned Bx fields - Andrew
% scan_file       = 'Text Files/2022-03-04-10.22.txt'; % Tuned By fields - Andrew