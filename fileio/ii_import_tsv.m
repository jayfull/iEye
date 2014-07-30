function ii_import_tsv()
%IMPORT EYELINK EDF FILES
%   This function will import Eyelink EDF files but requires 'edf2asc'
%   command (from Eyelink) be installed in MATLAB's path. A config (*.ifg)
%   file is also required. After import, you can save as binary MAT file
%   for faster file I/O. Config information will be baked into ii_cfg
%   structure.

% MONOCULAR ONLY AT THE MOMENT
% Ignores corneal reflection flag information at the moment
% Automatically pulls out x,y,pupil sample data
% Will always be saved samples, messages
% i.e. x,y,pupil, message1, message2, message3
% Message variables are CASE SENSITIVE


% *IMPORTANT* MAKE SURE EDF2ASC COMMAND IS IN ENV PATH
% Add edf2asc command location to path if not already included. For
% example, this adds "/usr/local/bin" to the env path.
% path1 = getenv('PATH');
% path1 = [path1 ':/usr/local/bin'];
% setenv('PATH', path1);
% !echo $PATH;

    % GET TSV file
    [filename3, pathname3] = uigetfile('*.*', 'Select REACH SAMPLES file');

    % GET CONFIG
    [nchan,lchan,schan,cfg] = ii_openifg();
    nchan = str2num(nchan);
    schan = str2num(schan);
    vis = lchan;
    lchan = textscan(lchan,'%s','delimiter',',');

    % LOAD SAMPLES
    fid = fopen(fullfile(pathname3, filename3),'r');
    M = textscan(fid,'%f %f %f %f %f');
    M = cell2mat(M);
    Frame = M(:,1);
    Time = M(:,2);
    rX = M(:,3);
    rY = M(:,4);
    rZ = M(:,5);
    
    % CREATE II_CFG STRUCT    
    dt = datestr(now,'mmmm dd, yyyy HH:MM:SS.FFF AM');
    
    ii_cfg.cursel = [];
    ii_cfg.sel = rX*0;
    ii_cfg.cfg = cfg;
    ii_cfg.vis = vis;
    ii_cfg.nchan = nchan;
    ii_cfg.lchan = lchan;
    ii_cfg.hz = schan;
    ii_cfg.blink = [];
    ii_cfg.velocity = [];
    ii_cfg.tcursel = [];
    ii_cfg.tsel = rX*0;
    ii_cfg.tindex = 0;
    ii_cfg.saccades = [];
    ii_cfg.history{1} = ['EDF imported ', dt];
    putvar(ii_cfg, Frame, Time, rX, rY, rZ);
    iEye;
    ii_replot;

end

