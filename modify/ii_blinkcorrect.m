function ii_blinkcorrect(chan, pchan, pval, pri, fol)
% Basic blink correction. This function takes 5 inputs: (1) The channel you
% want to perform blink correction on; (2) the name of the Pupil channel;
% (3) the Pupil threshold you want to use to define a blink; the # of
% prior (4) and following (5) samples to that threshold value you want to
% include in the correction around each blink

% If not passed, get arguments
if nargin ~= 5
    prompt = {'Channel to Correct', 'Pupil Channel', 'Pupil Threshold', '# Prior Samples', '# Following Samples'};
    dlg_title = 'Blink Correction';
    num_lines = 1;
    answer = inputdlg(prompt,dlg_title,num_lines);
    
    chan = answer{1};
    pchan = answer{2};
    pval = str2num(answer{3});
    pri = str2num(answer{4});
    fol = str2num(answer{5});
end

basevars = evalin('base','who');

if ismember(chan,basevars)
    pupil = evalin('base',pchan);
    x = evalin('base',chan);
    xx = x; xx(pupil==0) = NaN; % To improve the mean estimate: replace any data points in channel x to NaN when Pupil==0
    xmean = nanmean(nonzeros(xx)); % Calculate mean of channel omitting NaNs (i.e. when Pupil==0);
    lx = length(x);
    ii_cfg = evalin('base', 'ii_cfg');
    sel = x*0;
    
    blink = find(pupil<=pval);
    if blink > 0
        split1 = SplitVec(blink,'consecutive','firstval');
        split2 = SplitVec(blink,'consecutive','lastval');

        blinked(:,1) = split1 - pri;
        blinked(:,2) = split2 + fol;

        chk_low = find(blinked(:,1) < 0);
        if ~isempty(chk_low)
            blinked(chk_low,1) = 1;
        end
        
        chk_hi = find(blinked(:,2) > lx);
        if ~isempty(chk_hi)
            blinked(chk_hi,2) = lx;
        end
               
        for z=1:(size(blinked,1))
            sel(blinked(z,1):blinked(z,2)) = 1;
        end
        
        x(sel==1) = 0;
        
        if x(1) == 0;
            x(1) = xmean; % if the first data point is a blink, interpolate using the mean of the channel
        end
        
        for o = 2:(length(x))
            if x(o) == 0
                x(o) = x(o - 1);
            end
        end
        
%         % Plot blinks in new window
%         figure('Name','Blink Correction','NumberTitle','off')
%         plot(x);
%         hold all;
%         ylims = get(gca,'YLim');
%         hold on
%         plot([blink blink], ylims, '-r')
        
        assignin('base',chan,x);
        ii_cfg.blink = blink;
        putvar(ii_cfg);
        ii_replot;
    else
        disp('No blinks detected')
    end
else
    disp('Channel to correct does not exist in worksapce');
end
end

