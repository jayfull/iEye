function ii_import_ascii()
%II_IMPORT_ASCII Summary of this function goes here
%   Detailed explanation goes here

[filename, pathname] = uigetfile('*.*', 'Select Messages file');
[filename2, pathname2] = uigetfile('*.*', 'Select Samples file');

if isequal(filename,0)
    disp('User selected Cancel');
else
    % GET CONFIG
    [nchan,lchan,schan,cfg] = ii_openifg();
    nchan = str2num(nchan);
    schan = str2num(schan);
    vis = lchan;
    lchan = textscan(lchan,'%s','delimiter',',');
    
    echan = nchan - 3;
    
    % SAMPLES
    fid = fopen(fullfile(pathname2, filename2),'r');
    M = textscan(fid,'%f %f %f %f %*s');
    M = cell2mat(M);
    s_num = M(:,1);
    x = M(:,2);
    y = M(:,3);    
    pupil = M(:,4);
    
    % MESSAGES
    
    fid = fopen(fullfile(pathname, filename),'r');
    E = textscan(fid,'%s', 'delimiter','\n');
    E = E{1};
    mline = 1;
    Mess = {};
    
    % GET MSG EVENTS
    token = strtok(E);
    for v = 1:length(token)
        dm = strcmp(token(v),'MSG');
        if dm == 1
            Mess(mline) = E(v);
            mline = mline + 1;
        end
    end
    
    Mess = Mess';
    [useless, remain] = strtok(Mess);
    [samp_n, remain] = strtok(remain);
    [varbl, vval] = strtok(remain);
    samp_n = str2double(samp_n);
    vval = str2double(vval);   
    
    % SEARCH MSG EVENTS FOR VARIABLE
    for i = 4:nchan
        mline = 1;
        cname = lchan{1}{i};
        MV = [];
        
        for v = 1:length(varbl)
            dm = strcmp(varbl(v),cname);
            
            if dm == 1
                MV(mline,:) = [samp_n(v) vval(v)];
                mline = mline + 1;
            end
        end
        
        % GET INDICES & SET VALUES
        li = 1;
        ci = 1;
        cv = 0;
        M(:,(i+1)) = 0;
        
        for h = 1:length(MV)
            ci = find(M(:,1)==MV(h,1));            
            M((ci:length(M)),(i+1)) = MV(h,2);
            li = ci;
        end       
    end

        % CREATE FILE MATRIX  
    iye_file = strrep(filename, 'edf', 'iye');
    fil = fullfile(pathname, iye_file);
    M(:,1) = [];
     
%    dlmwrite(fil, M, 'delimiter', '\t', 'precision', '%.2f');
   
    % SAVE AND PLOT
    h = waitbar(0,'Opening file...');
    for i = 1:nchan
        cname = lchan{1}{i};
        cvalue = M(:,i);
        assignin('base',cname,cvalue);
        waitbar(i/nchan,h);
    end
    close(h);
   
    x = M(:,1);
   
    iEye;
   
    % CREATE II_CFG STRUCT    
        dt = datestr(now,'mmmm dd, yyyy HH:MM:SS.FFF AM');
    
    ii_cfg.cursel = [];
    ii_cfg.sel = x*0;
    ii_cfg.cfg = cfg;
    ii_cfg.vis = vis;
    ii_cfg.nchan = nchan;
    ii_cfg.lchan = lchan;
    ii_cfg.hz = schan;
    ii_cfg.blink = [];
    ii_cfg.velocity = [];
    ii_cfg.tcursel = [];
    ii_cfg.tsel = x*0;
    ii_cfg.tindex = 0;
    ii_cfg.saccades = [];
    ii_cfg.history{1} = ['ASCII imported ', dt];
    putvar(ii_cfg);
    ii_replot;
    
%     cursel = [ ];
%     sel = x*0;
%     putvar(sel,cursel,cfg,vis);
%     ii_replot;
%     
%     ii_saveiye;
    
end
end

