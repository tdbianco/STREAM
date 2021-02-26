%%  Braintools UK project test-retest data: Visualising features at test and retest

% This script visualises the relevant EEG features for different numbers of 
% trials from the previous scrips. This script further also calculates the 
% ICC between EEG features for the test and retest session. 

% Analyses are performed in the included sample for the checkerboards and
% faces separately. Next, analyses are repeated in the subsample of highly
% attentive children. 


% Calls to the ICC function: 
% Arash Salarian (2021). Intraclass Correlation Coefficient (ICC) (https://www.mathworks.com/matlabcentral/fileexchange/22099-intraclass-correlation-coefficient-icc), MATLAB Central File Exchange. Retrieved February 26, 2021.


% by Rianne Haartsen: jan-feb 21

%% Large included sample

clear variables
% braintools UK specific analysis scripts    
    addpath('/XXXXX');
% folder with the ICC script
    addpath('/XXXXX');


%% Checkerboards 

    % load table with the data
        load /XXXXX/BrtUK_Checkers_features.mat
    % rename to data for ease
    Data = BrtUK_Checkers_features;
    clear BrtUK_Checkers_features

% prep data
    Nsubjtot = height(Data); Nthrsh = length(Data.Nrantrls{1});
    % test session
    P1lat_test = nan(Nsubjtot/2,Nthrsh); % P1 peak latency
    P1pamp_test = nan(Nsubjtot/2,Nthrsh); % P1 peak amplitude
    DTWstim_test = nan(Nsubjtot/2,Nthrsh); % DTW during stimulus
    DTWP1_test = nan(Nsubjtot/2,Nthrsh); % DTW during P1 window
    valid_test = nan(Nsubjtot/2,Nthrsh);
    for ii = 1:(Nsubjtot/2)
        P1lat_test(ii,:) = Data.P1lat{ii};
        P1pamp_test(ii,:) = Data.P1pamp{ii};
        DTWstim_test(ii,:) = Data.DTWdir_stim{ii};
        DTWP1_test(ii,:) = Data.DTWdir_P1time{ii};
        valid_test(ii,:) = Data.P1_valid{ii};
    end
    clear ii
    % retest session
    P1lat_retest = nan(Nsubjtot/2,Nthrsh); % P1 peak latency
    P1pamp_retest = nan(Nsubjtot/2,Nthrsh); % P1 peak amplitude
    DTWstim_retest = nan(Nsubjtot/2,Nthrsh); % DTW during stimulus
    DTWP1_retest = nan(Nsubjtot/2,Nthrsh); % DTW during P1 window
    valid_retest = nan(Nsubjtot/2,Nthrsh);
    for ii = 1:(Nsubjtot/2)
        P1lat_retest(ii,:) = Data.P1lat{ii+(Nsubjtot/2)};
        P1pamp_retest(ii,:) = Data.P1pamp{ii+(Nsubjtot/2)};
        DTWstim_retest(ii,:) = Data.DTWdir_stim{ii+(Nsubjtot/2)};
        DTWP1_retest(ii,:) = Data.DTWdir_P1time{ii+(Nsubjtot/2)};
        valid_retest(ii,:) = Data.P1_valid{ii+(Nsubjtot/2)};
    end
    clear ii

% set values for invalid individual ERPs to Nan    
    % test
    P1lat_test(valid_test == 0) = NaN;
    P1pamp_test(valid_test == 0) = NaN;
    DTWstim_test(valid_test == 0) = NaN;
    DTWP1_test(valid_test == 0) = NaN;
    % retest
    P1lat_retest(valid_retest == 0) = NaN;
    P1pamp_retest(valid_retest == 0) = NaN;
    DTWstim_retest(valid_retest == 0) = NaN;
    DTWP1_retest(valid_retest == 0) = NaN;
    
    
% plot the data and put ICC in title    
    % common parameters
    MkrS = 12;
    Str1_axis = 'Session 1';
    Str2_axis = 'Session 2';
    ICCtype = 'C-1';
    Rows_fig = 4;
    Thrs_trls = [10,20,30,40,50,0]; 
    
    %preallocate variables for ICC
    ICCvals_P1lat = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_P1pamp = nan(length(Thrs_trls),5);
    ICCvals_DTWstim = nan(length(Thrs_trls),5);
    ICCvals_DTWP1 = nan(length(Thrs_trls),5);

    
InclSample_Figure_Checkers_features = figure;
  
    % P1 peak latency
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),tt);
        % get values for ICC
        CurVals = [P1lat_test(:,tt), P1lat_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_P1lat(tt,:) = [r, LB, UB, p, size(CurVals,1)];
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('P1 plat: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('P1 plat: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end
    
    % P1 peak amplitude
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)));
        % get values for ICC
        CurVals = [P1pamp_test(:,tt), P1pamp_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_P1pamp(tt,:) = [r, LB, UB, p, size(CurVals,1)];
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('P1 pampl: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('P1 pampl: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end
    
    % P1 peak amplitude
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)));
        % get values for ICC
        CurVals = [P1pamp_test(:,tt), P1pamp_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_P1pamp(tt,:) = [r, LB, UB, p, size(CurVals,1)];
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('P1 pampl: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('P1 pampl: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end

    % DTW direction during stimulus
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+(length(Thrs_trls)*2)));
        % get values for ICC
        CurVals = [DTWstim_test(:,tt), DTWstim_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_DTWstim(tt,:) = [r, LB, UB, p, size(CurVals,1)];
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('DTW stim: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('DTW stim: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end    

    % DTW direction during P1 window
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+(length(Thrs_trls)*3)));
        % get values for ICC
        CurVals = [DTWP1_test(:,tt), DTWP1_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_DTWP1(tt,:) = [r, LB, UB, p, size(CurVals,1)];
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('DTW P1: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('DTW P1: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end     
        
sgtitle({'Braintools UK: ICCs for P1 features during checkerboards'}, 'FontSize',14)    

% save ICC vals for later
    ICCvals_Checkers = struct;
    ICCvals_Checkers.P1plat = ICCvals_P1lat;
    ICCvals_Checkers.P1pamp = ICCvals_P1pamp;
    ICCvals_Checkers.DTWstim = ICCvals_DTWstim;
    ICCvals_Checkers.DTWP1 = ICCvals_DTWP1;
    ICCvals_Checkers.ICCdim1_Thresholds= Thrs_trls;
    ICCvals_Checkers.ICCdim2_Values = {strcat('rho: ',ICCtype),'LB','UB','pval'};
    
    save('/XXXXX/Checkers_ICCvals.mat','ICCvals_Checkers')
    

    

%% For faces

clear variables
    % load table with the data
        load /XXXXX/BrtUK_Faces_features.mat
    % rename to data for ease 
    Data = BrtUK_Faces_features; 
    clear BrtUK_Faces_features

% prep data
    Nsubjtot = height(Data); Nthrsh = length(Data.Nrantrls{1});
    % test session
    N290lat_test = nan(Nsubjtot/2,Nthrsh); % N290 peak latency
    N290pamp_test = nan(Nsubjtot/2,Nthrsh); % N290 peak amplitude
    N290mamp_test = nan(Nsubjtot/2,Nthrsh); % N290 mean amplitude
    P400mamp_test = nan(Nsubjtot/2,Nthrsh); % P400 mean amplitude
    DTWstim_test = nan(Nsubjtot/2,Nthrsh); % DTW during stimulus
    DTWN290_test = nan(Nsubjtot/2,Nthrsh); % DTW during N290 window
    DTWP400_test = nan(Nsubjtot/2,Nthrsh); % DTW during P400 window
    valid_test = nan(Nsubjtot/2,Nthrsh);
    for ii = 1:(Nsubjtot/2)
        N290lat_test(ii,:) = Data.N290lat{ii};
        N290pamp_test(ii,:) = Data.N290pamp{ii};
        N290mamp_test(ii,:) = Data.N290mamp{ii};
        P400mamp_test(ii,:) = Data.P400mamp{ii};
        DTWstim_test(ii,:) = Data.DTWdir_stim{ii};
        DTWN290_test(ii,:) = Data.DTWdir_N290time{ii};
        DTWP400_test(ii,:) = Data.DTWdir_P400time{ii};
        valid_test(ii,:) = Data.N290_valid{ii};
    end
    clear ii
    % retest session
    N290lat_retest = nan(Nsubjtot/2,Nthrsh); % N290 peak latency
    N290pamp_retest = nan(Nsubjtot/2,Nthrsh); % N290 peak amplitude
    N290mamp_retest = nan(Nsubjtot/2,Nthrsh); % N290 mean amplitude
    P400mamp_retest = nan(Nsubjtot/2,Nthrsh); % P400 mean amplitude
    DTWstim_retest = nan(Nsubjtot/2,Nthrsh); % DTW during stimulus
    DTWN290_retest = nan(Nsubjtot/2,Nthrsh); % DTW during N290 window
    DTWP400_retest = nan(Nsubjtot/2,Nthrsh); % DTW during P400 window
    valid_retest = nan(Nsubjtot/2,Nthrsh);
    for ii = 1:(Nsubjtot/2)
        N290lat_retest(ii,:) = Data.N290lat{ii+(Nsubjtot/2)};
        N290pamp_retest(ii,:) = Data.N290pamp{ii+(Nsubjtot/2)};
        N290mamp_retest(ii,:) = Data.N290mamp{ii+(Nsubjtot/2)};
        P400mamp_retest(ii,:) = Data.P400mamp{ii+(Nsubjtot/2)};
        DTWstim_retest(ii,:) = Data.DTWdir_stim{ii+(Nsubjtot/2)};
        DTWN290_retest(ii,:) = Data.DTWdir_N290time{ii+(Nsubjtot/2)};
        DTWP400_retest(ii,:) = Data.DTWdir_P400time{ii+(Nsubjtot/2)};
        valid_retest(ii,:) = Data.N290_valid{ii+(Nsubjtot/2)};
    end
    clear ii
    
    % set values for invalid individual ERPs to Nan    
        % test
        N290lat_test(valid_test == 0) = NaN;
        N290pamp_test(valid_test == 0) = NaN;
        N290mamp_test(valid_test == 0) = NaN;
        P400mamp_test(valid_test == 0) = NaN;
        DTWstim_test(valid_test == 0) = NaN;
        DTWN290_test(valid_test == 0) = NaN;
        DTWP400_test(valid_test == 0) = NaN;
        % retest
        N290lat_retest(valid_test == 0) = NaN;
        N290pamp_retest(valid_test == 0) = NaN;
        N290mamp_retest(valid_test == 0) = NaN;
        P400mamp_retest(valid_test == 0) = NaN;
        DTWstim_retest(valid_test == 0) = NaN;
        DTWN290_retest(valid_test == 0) = NaN;
        DTWP400_retest(valid_test == 0) = NaN;
  
        
        
% plot the data for traditional ERPs and put ICC in title    
    % common parameters
    MkrS = 12;
    Str1_axis = 'Session 1';
    Str2_axis = 'Session 2';
    ICCtype = 'C-1';
    Rows_fig = 4;
    Thrs_trls = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 0];
    
    %preallocate variables for ICC
    ICCvals_N290plat = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_N290pamp = nan(length(Thrs_trls),5);
    ICCvals_N290mamp = nan(length(Thrs_trls),5);
    ICCvals_P400mamp = nan(length(Thrs_trls),5);


InclSample_Figure_Faces_tradERPfeatures = figure;   

% N290 peak latency
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),tt);
        % get values for ICC
        CurVals = [N290lat_test(:,tt), N290lat_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_N290plat(tt,:) = [r, LB, UB, p, size(CurVals,1)];
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('N290 lat: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('N290 lat: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end


% N290 peak amplitude
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)));
        % get values for ICC
        CurVals = [N290pamp_test(:,tt), N290pamp_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_N290pamp(tt,:) = [r, LB, UB, p, size(CurVals,1)];;
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('N290 pampl:', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('N290 pampl: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end

% N290 mean amplitude
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)*2));
        % get values for ICC
        CurVals = [N290mamp_test(:,tt), N290mamp_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_N290mamp(tt,:) = [r, LB, UB, p, size(CurVals,1)];
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('N290 mampl: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('N290 mampl: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end

% P400 mean amplitude
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)*3));
        % get values for ICC
        CurVals = [P400mamp_test(:,tt), P400mamp_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_P400mamp(tt,:) = [r, LB, UB, p, size(CurVals,1)];
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('P400 mampl: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('P400 mampl: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end

    
sgtitle({'Braintools UK: ICCs for N290 and P400 traditional features during faces'}, 'FontSize',14)    






% creat a plot for the DTW values %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % common parameters
    MkrS = 12;
    Str1_axis = 'Session 1';
    Str2_axis = 'Session 2';
    ICCtype = 'C-1';
    Rows_fig = 3;
    Thrs_trls = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 0];
    
    %preallocate variables for ICC
    ICCvals_DTWstim = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_DTWN290 = nan(length(Thrs_trls),5);
    ICCvals_DTWP400 = nan(length(Thrs_trls),5);


Figure_Faces_DTWfeatures = figure;   

% DTWdir stim
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),tt);
        % get values for ICC
        CurVals = [DTWstim_test(:,tt), DTWstim_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_DTWstim(tt,:) = [r, LB, UB, p, size(CurVals,1)];
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('DTW stim: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('DTW stim: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end

% DTWdir N290
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)));
        % get values for ICC
        CurVals = [DTWN290_test(:,tt), DTWN290_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_DTWN290(tt,:) = [r, LB, UB, p, size(CurVals,1)];
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('DTW N290: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('DTW N290: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end

% DTWdir P400
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)*2));
        % get values for ICC
        CurVals = [DTWP400_test(:,tt), DTWP400_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_DTWP400(tt,:) = [r, LB, UB, p, size(CurVals,1)];
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('DTW P400: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('DTW P400: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end    
    
    
sgtitle({'Braintools UK: ICCs for dynamic time warping features during faces'}, 'FontSize',14)    


% save ICC vals for later
    ICCvals_Faces = struct;
    ICCvals_Faces.N290plat = ICCvals_N290plat;
    ICCvals_Faces.N290pamp = ICCvals_N290pamp;
    ICCvals_Faces.N290mamp = ICCvals_N290mamp;
    ICCvals_Faces.P400mamp = ICCvals_P400mamp;
    ICCvals_Faces.DTWstim = ICCvals_DTWstim;
    ICCvals_Faces.DTWN290 = ICCvals_DTWN290;
    ICCvals_Faces.DTWP400 = ICCvals_DTWP400;
    ICCvals_Faces.ICCdim1_Thresholds= Thrs_trls;
    ICCvals_Faces.ICCdim2_Values = {strcat('rho: ',ICCtype),'LB','UB','pval'};
    
    save('/XXXXX/Faces_ICCvals.mat','ICCvals_Faces')


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
%% For the highly attentive sample %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    
%% Checkerboards 
clear variables
    % load table with the data
        load /XXXXX/BrtUK_Checkers_features.mat
    % rename to data for ease
    Data_all = BrtUK_Checkers_features;
    clear BrtUK_Checkers_features
    % select ppts who were very attentive during the session
    load('/XXXXX/IDs_samples_HighlyAttentive.mat',...
            'IDs_HAttET_EEG');
    Inds_HAtt = nan(height(Data_all),1);
        for ss = 1:height(Data_all)
            SubjCode = extractBefore(Data_all.IDses{ss},7);
            if ismember(SubjCode,IDs_HAttET_EEG)
                Inds_HAtt(ss) = 1;
            else
                Inds_HAtt(ss) = 0;
            end
        end
    Data = Data_all(Inds_HAtt == 1,:);    
    
% prep data
    Nsubjtot = height(Data); Nthrsh = length(Data.Nrantrls{1});
    % test session
    P1lat_test = nan(Nsubjtot/2,Nthrsh); % P1 peak latency
    P1pamp_test = nan(Nsubjtot/2,Nthrsh); % P1 peak amplitude
    DTWstim_test = nan(Nsubjtot/2,Nthrsh); % DTW during stimulus
    DTWP1_test = nan(Nsubjtot/2,Nthrsh); % DTW during P1 window
    valid_test = nan(Nsubjtot/2,Nthrsh);
    for ii = 1:(Nsubjtot/2)
        P1lat_test(ii,:) = Data.P1lat{ii};
        P1pamp_test(ii,:) = Data.P1pamp{ii};
        DTWstim_test(ii,:) = Data.DTWdir_stim{ii};
        DTWP1_test(ii,:) = Data.DTWdir_P1time{ii};
        valid_test(ii,:) = Data.P1_valid{ii};
    end
    clear ii
    % retest session
    P1lat_retest = nan(Nsubjtot/2,Nthrsh); % P1 peak latency
    P1pamp_retest = nan(Nsubjtot/2,Nthrsh); % P1 peak amplitude
    DTWstim_retest = nan(Nsubjtot/2,Nthrsh); % DTW during stimulus
    DTWP1_retest = nan(Nsubjtot/2,Nthrsh); % DTW during P1 window
    valid_retest = nan(Nsubjtot/2,Nthrsh);
    for ii = 1:(Nsubjtot/2)
        P1lat_retest(ii,:) = Data.P1lat{ii+(Nsubjtot/2)};
        P1pamp_retest(ii,:) = Data.P1pamp{ii+(Nsubjtot/2)};
        DTWstim_retest(ii,:) = Data.DTWdir_stim{ii+(Nsubjtot/2)};
        DTWP1_retest(ii,:) = Data.DTWdir_P1time{ii+(Nsubjtot/2)};
        valid_retest(ii,:) = Data.P1_valid{ii+(Nsubjtot/2)};
    end
    clear ii

% set values for invalid individual ERPs to Nan    
    % test
    P1lat_test(valid_test == 0) = NaN;
    P1pamp_test(valid_test == 0) = NaN;
    DTWstim_test(valid_test == 0) = NaN;
    DTWP1_test(valid_test == 0) = NaN;
    % retest
    P1lat_retest(valid_retest == 0) = NaN;
    P1pamp_retest(valid_retest == 0) = NaN;
    DTWstim_retest(valid_retest == 0) = NaN;
    DTWP1_retest(valid_retest == 0) = NaN;
    
    
% plot the data and put ICC in title    
    % common parameters
    MkrS = 12;
    Str1_axis = 'Session 1';
    Str2_axis = 'Session 2';
    ICCtype = 'C-1';
    Rows_fig = 4;
    Thrs_trls = [10,20,30,40,50,0]; 
    
    %preallocate variables for ICC
    ICCvals_P1lat = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_P1pamp = nan(length(Thrs_trls),5);
    ICCvals_DTWstim = nan(length(Thrs_trls),5);
    ICCvals_DTWP1 = nan(length(Thrs_trls),5);

    
HAttSample_Figure_Checkers_features = figure;
  
    % P1 peak latency
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),tt);
        % get values for ICC
        CurVals = [P1lat_test(:,tt), P1lat_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_P1lat(tt,:) = [r, LB, UB, p, size(CurVals,1)];
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('P1 plat: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('P1 plat: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end
    
    % P1 peak amplitude
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)));
        % get values for ICC
        CurVals = [P1pamp_test(:,tt), P1pamp_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_P1pamp(tt,:) = [r, LB, UB, p, size(CurVals,1)];
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('P1 pampl: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('P1 pampl: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end
    
    % P1 peak amplitude
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)));
        % get values for ICC
        CurVals = [P1pamp_test(:,tt), P1pamp_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_P1pamp(tt,:) = [r, LB, UB, p, size(CurVals,1)];
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('P1 pampl: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('P1 pampl: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end

    % DTW direction during stimulus
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+(length(Thrs_trls)*2)));
        % get values for ICC
        CurVals = [DTWstim_test(:,tt), DTWstim_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_DTWstim(tt,:) = [r, LB, UB, p, size(CurVals,1)];
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('DTW stim: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('DTW stim: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end    

    % DTW direction during P1 window
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+(length(Thrs_trls)*3)));
        % get values for ICC
        CurVals = [DTWP1_test(:,tt), DTWP1_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_DTWP1(tt,:) = [r, LB, UB, p, size(CurVals,1)];
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('DTW P1: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('DTW P1: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end     
        
sgtitle({'Braintools UK: ICCs for P1 features during checkerboards in highly attentive sample'}, 'FontSize',14)    
    

% save ICC vals for later
    ICCvals_Checkers_HAtt = struct;
    ICCvals_Checkers_HAtt.P1plat = ICCvals_P1lat;
    ICCvals_Checkers_HAtt.P1pamp = ICCvals_P1pamp;
    ICCvals_Checkers_HAtt.DTWstim = ICCvals_DTWstim;
    ICCvals_Checkers_HAtt.DTWP1 = ICCvals_DTWP1;
    ICCvals_Checkers_HAtt.ICCdim1_Thresholds= Thrs_trls;
    ICCvals_Checkers_HAtt.ICCdim2_Values = {strcat('rho: ',ICCtype),'LB','UB','pval'};
    
    save('/XXXXX/Checkers_ICCvals_HAtt.mat','ICCvals_Checkers_HAtt')

    
    
    
%% Faces

clear variables
    % load table with the data
        load /XXXXX/BrtUK_Faces_features.mat
    % rename to data for ease
    Data_all = BrtUK_Faces_features;
    clear BrtUK_Faces_features
    % select ppts who were very attentive during the session
    load('/XXXXX/IDs_samples_HighlyAttentive.mat',...
            'IDs_HAttET_EEG');
    Inds_HAtt = nan(height(Data_all),1);
        for ss = 1:height(Data_all)
            SubjCode = extractBefore(Data_all.IDses{ss},7);
            if ismember(SubjCode,IDs_HAttET_EEG)
                Inds_HAtt(ss) = 1;
            else
                Inds_HAtt(ss) = 0;
            end
        end
    Data = Data_all(Inds_HAtt == 1,:);    
    
    

% prep data
    Nsubjtot = height(Data); Nthrsh = length(Data.Nrantrls{1});
    % test session
    N290lat_test = nan(Nsubjtot/2,Nthrsh); % N290 peak latency
    N290pamp_test = nan(Nsubjtot/2,Nthrsh); % N290 peak amplitude
    N290mamp_test = nan(Nsubjtot/2,Nthrsh); % N290 mean amplitude
    P400mamp_test = nan(Nsubjtot/2,Nthrsh); % P400 mean amplitude
    DTWstim_test = nan(Nsubjtot/2,Nthrsh); % DTW during stimulus
    DTWN290_test = nan(Nsubjtot/2,Nthrsh); % DTW during N290 window
    DTWP400_test = nan(Nsubjtot/2,Nthrsh); % DTW during P400 window
    valid_test = nan(Nsubjtot/2,Nthrsh);
    for ii = 1:(Nsubjtot/2)
        N290lat_test(ii,:) = Data.N290lat{ii};
        N290pamp_test(ii,:) = Data.N290pamp{ii};
        N290mamp_test(ii,:) = Data.N290mamp{ii};
        P400mamp_test(ii,:) = Data.P400mamp{ii};
        DTWstim_test(ii,:) = Data.DTWdir_stim{ii};
        DTWN290_test(ii,:) = Data.DTWdir_N290time{ii};
        DTWP400_test(ii,:) = Data.DTWdir_P400time{ii};
        valid_test(ii,:) = Data.N290_valid{ii};
    end
    clear ii
    % retest session
    N290lat_retest = nan(Nsubjtot/2,Nthrsh); % N290 peak latency
    N290pamp_retest = nan(Nsubjtot/2,Nthrsh); % N290 peak amplitude
    N290mamp_retest = nan(Nsubjtot/2,Nthrsh); % N290 mean amplitude
    P400mamp_retest = nan(Nsubjtot/2,Nthrsh); % P400 mean amplitude
    DTWstim_retest = nan(Nsubjtot/2,Nthrsh); % DTW during stimulus
    DTWN290_retest = nan(Nsubjtot/2,Nthrsh); % DTW during N290 window
    DTWP400_retest = nan(Nsubjtot/2,Nthrsh); % DTW during P400 window
    valid_retest = nan(Nsubjtot/2,Nthrsh);
    for ii = 1:(Nsubjtot/2)
        N290lat_retest(ii,:) = Data.N290lat{ii+(Nsubjtot/2)};
        N290pamp_retest(ii,:) = Data.N290pamp{ii+(Nsubjtot/2)};
        N290mamp_retest(ii,:) = Data.N290mamp{ii+(Nsubjtot/2)};
        P400mamp_retest(ii,:) = Data.P400mamp{ii+(Nsubjtot/2)};
        DTWstim_retest(ii,:) = Data.DTWdir_stim{ii+(Nsubjtot/2)};
        DTWN290_retest(ii,:) = Data.DTWdir_N290time{ii+(Nsubjtot/2)};
        DTWP400_retest(ii,:) = Data.DTWdir_P400time{ii+(Nsubjtot/2)};
        valid_retest(ii,:) = Data.N290_valid{ii+(Nsubjtot/2)};
    end
    clear ii
    
    % set values for invalid individual ERPs to Nan    
        % test
        N290lat_test(valid_test == 0) = NaN;
        N290pamp_test(valid_test == 0) = NaN;
        N290mamp_test(valid_test == 0) = NaN;
        P400mamp_test(valid_test == 0) = NaN;
        DTWstim_test(valid_test == 0) = NaN;
        DTWN290_test(valid_test == 0) = NaN;
        DTWP400_test(valid_test == 0) = NaN;
        % retest
        N290lat_retest(valid_test == 0) = NaN;
        N290pamp_retest(valid_test == 0) = NaN;
        N290mamp_retest(valid_test == 0) = NaN;
        P400mamp_retest(valid_test == 0) = NaN;
        DTWstim_retest(valid_test == 0) = NaN;
        DTWN290_retest(valid_test == 0) = NaN;
        DTWP400_retest(valid_test == 0) = NaN;
  
        
        
% plot the data for traditional ERPs and put ICC in title    
    % common parameters
    MkrS = 12;
    Str1_axis = 'Session 1';
    Str2_axis = 'Session 2';
    ICCtype = 'C-1';
    Rows_fig = 4;
    Thrs_trls = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 0];
    
    %preallocate variables for ICC
    ICCvals_N290plat = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_N290pamp = nan(length(Thrs_trls),5);
    ICCvals_N290mamp = nan(length(Thrs_trls),5);
    ICCvals_P400mamp = nan(length(Thrs_trls),5);


HAttSample_Figure_Faces_tradERPfeatures = figure;   

% N290 peak latency
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),tt);
        % get values for ICC
        CurVals = [N290lat_test(:,tt), N290lat_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_N290plat(tt,:) = [r, LB, UB, p, size(CurVals,1)];
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('N290 lat: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('N290 lat: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end


% N290 peak amplitude
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)));
        % get values for ICC
        CurVals = [N290pamp_test(:,tt), N290pamp_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_N290pamp(tt,:) = [r, LB, UB, p, size(CurVals,1)];;
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('N290 pampl:', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('N290 pampl: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end

% N290 mean amplitude
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)*2));
        % get values for ICC
        CurVals = [N290mamp_test(:,tt), N290mamp_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_N290mamp(tt,:) = [r, LB, UB, p, size(CurVals,1)];
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('N290 mampl: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('N290 mampl: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end

% P400 mean amplitude
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)*3));
        % get values for ICC
        CurVals = [P400mamp_test(:,tt), P400mamp_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_P400mamp(tt,:) = [r, LB, UB, p, size(CurVals,1)];
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('P400 mampl: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('P400 mampl: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end

    
sgtitle({'Braintools UK: ICCs for N290 and P400 traditional features during faces in highly attentive sample'}, 'FontSize',14)    






% creat a plot for the DTW values %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % common parameters
    MkrS = 12;
    Str1_axis = 'Session 1';
    Str2_axis = 'Session 2';
    ICCtype = 'C-1';
    Rows_fig = 3;
    Thrs_trls = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 0];
    
    %preallocate variables for ICC
    ICCvals_DTWstim = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_DTWN290 = nan(length(Thrs_trls),5);
    ICCvals_DTWP400 = nan(length(Thrs_trls),5);


Figure_Faces_DTWfeatures = figure;   

% DTWdir stim
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),tt);
        % get values for ICC
        CurVals = [DTWstim_test(:,tt), DTWstim_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_DTWstim(tt,:) = [r, LB, UB, p, size(CurVals,1)];
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('DTW stim: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('DTW stim: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end

% DTWdir N290
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)));
        % get values for ICC
        CurVals = [DTWN290_test(:,tt), DTWN290_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_DTWN290(tt,:) = [r, LB, UB, p, size(CurVals,1)];
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('DTW N290: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('DTW N290: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end

% DTWdir P400
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)*2));
        % get values for ICC
        CurVals = [DTWP400_test(:,tt), DTWP400_retest(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        % plot the data for session 1 and 2
        scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled')
        xlabel(Str1_axis); ylabel(Str2_axis)
        % link the axes
        Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
        Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
        ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_DTWP400(tt,:) = [r, LB, UB, p, size(CurVals,1)];
        % create stings for in the title
        if ~isequal(tt,length(Thrs_trls))
            str1 = strcat('DTW P400: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                num2str(size(CurVals,1)),')');
        else
            str1 = strcat('DTW P400: all trls (N=',...
                num2str(size(CurVals,1)),')');
        end
        str2 = strcat('ICC=', num2str(round(r,2)),' [',num2str(round(LB,2)), ', ', num2str(round(UB,2)),']',...
            ', p=',num2str(round(p,3)));
        title({str1; str2},'FontSize',12)
        clear CurVals str1 str2 r LB UB p 
    end    
    
    
sgtitle({'Braintools UK: ICCs for dynamic time warping features during faces in highly attentive sample'}, 'FontSize',14)    


% save ICC vals for later
    ICCvals_Faces_HAtt = struct;
    ICCvals_Faces_HAtt.N290plat = ICCvals_N290plat;
    ICCvals_Faces_HAtt.N290pamp = ICCvals_N290pamp;
    ICCvals_Faces_HAtt.N290mamp = ICCvals_N290mamp;
    ICCvals_Faces_HAtt.P400mamp = ICCvals_P400mamp;
    ICCvals_Faces_HAtt.DTWstim = ICCvals_DTWstim;
    ICCvals_Faces_HAtt.DTWN290 = ICCvals_DTWN290;
    ICCvals_Faces_HAtt.DTWP400 = ICCvals_DTWP400;
    ICCvals_Faces_HAtt.ICCdim1_Thresholds= Thrs_trls;
    ICCvals_Faces_HAtt.ICCdim2_Values = {strcat('rho: ',ICCtype),'LB','UB','pval'};
    
    save('/XXXXX/Faces_ICCvals_HAtt.mat','ICCvals_Faces_HAtt')
 

    