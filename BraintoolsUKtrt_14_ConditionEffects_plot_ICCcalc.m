%%  Braintools UK project test-retest data: Visualising face features at t1 and t2

% This script visualises the relevant EEG features for different numbers of trials from the previous scrips.


% EEG features: 
% faces; N290 peak latency - peak amplitude - mean amplitude, DTW during N290 window,
% P400 mean amplitude, DTW during P400 window

% Calls to the ICC function: 
% Arash Salarian (2021). Intraclass Correlation Coefficient (ICC) (https://www.mathworks.com/matlabcentral/fileexchange/22099-intraclass-correlation-coefficient-icc), MATLAB Central File Exchange. Retrieved February 26, 2021.

% RH 06-05-21

%% Large included sample

clear variables
% braintools UK specific analysis scripts    
    addpath('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrT_UK_scripts_publication');

% load table with the data
    load /Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrTUK_CE_ERPs_Nrandtrls.mat
% rename to data for ease 
Data = BrtUK_CE_ERPs_Nrandtrls; 
clear BrtUK_CE_ERPs_Nrandtrls


%% Faces up %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
% prep data
    Nsubjtot = height(Data); Nthrsh = length(Data.Nrantrls{1});
    Thrs_trls = Data.Nrantrls{1};
    % test session
    N290lat_test = nan(Nsubjtot/2,Nthrsh); % N290 peak latency
    N290pamp_test = nan(Nsubjtot/2,Nthrsh); % N290 peak amplitude
    N290mamp_test = nan(Nsubjtot/2,Nthrsh); % N290 mean amplitude
    DTWN290_test = nan(Nsubjtot/2,Nthrsh); % DTW during N290 window
    P400mamp_test = nan(Nsubjtot/2,Nthrsh); % P400 mean amplitude
    DTWP400_test = nan(Nsubjtot/2,Nthrsh); % DTW during P400 window
    valid_test = nan(Nsubjtot/2,Nthrsh);
    for ii = 1:(Nsubjtot/2)
        N290lat_test(ii,:) = Data.Fu_N290lat{ii};
        N290pamp_test(ii,:) = Data.Fu_N290pamp{ii};
        N290mamp_test(ii,:) = Data.Fu_N290mamp{ii};
        DTWN290_test(ii,:) = Data.Fu_N290dtw{ii};
        P400mamp_test(ii,:) = Data.Fu_P400mamp{ii};
        DTWP400_test(ii,:) = Data.Fu_P400dtw{ii};
        valid_test(ii,:) = Data.Fu_val{ii};
    end
    clear ii
    % retest session
    N290lat_retest = nan(Nsubjtot/2,Nthrsh); % N290 peak latency
    N290pamp_retest = nan(Nsubjtot/2,Nthrsh); % N290 peak amplitude
    N290mamp_retest = nan(Nsubjtot/2,Nthrsh); % N290 mean amplitude
    DTWN290_retest = nan(Nsubjtot/2,Nthrsh); % DTW during N290 window
    P400mamp_retest = nan(Nsubjtot/2,Nthrsh); % P400 mean amplitude
    DTWP400_retest = nan(Nsubjtot/2,Nthrsh); % DTW during P400 window
    valid_retest = nan(Nsubjtot/2,Nthrsh);
    for ii = 1:(Nsubjtot/2)
        N290lat_retest(ii,:) = Data.Fu_N290lat{ii+(Nsubjtot/2)};
        N290pamp_retest(ii,:) = Data.Fu_N290pamp{ii+(Nsubjtot/2)};
        N290mamp_retest(ii,:) = Data.Fu_N290mamp{ii+(Nsubjtot/2)};
        DTWN290_retest(ii,:) = Data.Fu_N290dtw{ii+(Nsubjtot/2)};
        P400mamp_retest(ii,:) = Data.Fu_P400mamp{ii+(Nsubjtot/2)};
        DTWP400_retest(ii,:) = Data.Fu_P400dtw{ii+(Nsubjtot/2)};
        valid_retest(ii,:) = Data.Fu_val{ii+(Nsubjtot/2)};
    end
    clear ii
    
    % set values for invalid individual ERPs to Nan    
        % test
        N290lat_test(valid_test == 0) = NaN;
        N290pamp_test(valid_test == 0) = NaN;
        N290mamp_test(valid_test == 0) = NaN;
        DTWN290_test(valid_test == 0) = NaN;
        P400mamp_test(valid_test == 0) = NaN;
        DTWP400_test(valid_test == 0) = NaN;
        % retest
        N290lat_retest(valid_test == 0) = NaN;
        N290pamp_retest(valid_test == 0) = NaN;
        N290mamp_retest(valid_test == 0) = NaN;
        DTWN290_retest(valid_test == 0) = NaN;
        P400mamp_retest(valid_test == 0) = NaN;
        DTWP400_retest(valid_test == 0) = NaN;
  
% preallocate variables for ICC        
    ICCtype = 'C-1';
    
    ICCvals_FacesUp = struct;
    ICCvals_FacesUp.N290plat = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesUp.N290pamp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesUp.N290mamp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesUp.N290dtw = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesUp.P400mamp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesUp.P400dtw = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesUp.ICCdim1_Thresholds = Thrs_trls;
    ICCvals_FacesUp.ICCdim2_Values = {strcat('rho: ',ICCtype),'LB','UB','pval'};
        
        
% plot the data for N290 features and put ICC in title %%%%%%%%%%%%%%%%%%%%   
    % common parameters
    MkrS = 12;
    Str1_axis = 'Session 1';
    Str2_axis = 'Session 2';
    Rows_fig = 4;
    Thrs_trls = ICCvals_FacesUp.ICCdim1_Thresholds;

Figure_FacesUp_N290features = figure;   

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
        ICCvals_FacesUp.N290plat(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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
        ICCvals_FacesUp.N290pamp(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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
        ICCvals_FacesUp.N290mamp(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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

    
% DTWdir N290
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)*3));
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
        ICCvals_FacesUp.N290dtw(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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
    
    
    
sgtitle({'Braintools UK: ICCs for N290 features during faces up'}, 'FontSize',14)    






% plot the data for P400 features and put ICC in title %%%%%%%%%%%%%%%%%%%%   

Figure_FacesUp_P400features = figure;  

    
% P400 mean amplitude
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)));
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
        ICCvals_FacesUp.P400mamp(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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
        ICCvals_FacesUp.P400dtw(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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
    
sgtitle({'Braintools UK: ICCs for P400 features during faces up'}, 'FontSize',14)    


%% save the data and figures
    save('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/FacesUp_ICCvals.mat','ICCvals_FacesUp')
    saveas(Figure_FacesUp_N290features,'/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_Figures_graphs/ICCs_FacesUp_N290features.tif')
    saveas(Figure_FacesUp_P400features,'/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_Figures_graphs/ICCs_FacesUp_P400features.tif')

% clean up
    clear Nsubjtot N290lat_test N290pamp_test N290mamp_test DTWN290_test P400mamp_test DTWP400_test valid_test 
    clear N290lat_retest N290pamp_retest N290mamp_retest DTWN290_retest P400mamp_retest DTWP400_retest valid_retest 
    clear Axis_max Axis_min MkrS Nthrsh Rows_fig sp Str1_axis Str2_axis Thrs_trls tt ICCtype
    clear Figure_FacesUp_N290features Figure_FacesUp_P400features
    clear ICCvals_FacesUp

    
    
    
    
    
    
    
    
%% Faces inv %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
% prep data
    Nsubjtot = height(Data); Nthrsh = length(Data.Nrantrls{1});
    Thrs_trls = Data.Nrantrls{1};
    % test session
    N290lat_test = nan(Nsubjtot/2,Nthrsh); % N290 peak latency
    N290pamp_test = nan(Nsubjtot/2,Nthrsh); % N290 peak amplitude
    N290mamp_test = nan(Nsubjtot/2,Nthrsh); % N290 mean amplitude
    DTWN290_test = nan(Nsubjtot/2,Nthrsh); % DTW during N290 window
    P400mamp_test = nan(Nsubjtot/2,Nthrsh); % P400 mean amplitude
    DTWP400_test = nan(Nsubjtot/2,Nthrsh); % DTW during P400 window
    valid_test = nan(Nsubjtot/2,Nthrsh);
    for ii = 1:(Nsubjtot/2)
        N290lat_test(ii,:) = Data.Fi_N290lat{ii};
        N290pamp_test(ii,:) = Data.Fi_N290pamp{ii};
        N290mamp_test(ii,:) = Data.Fi_N290mamp{ii};
        DTWN290_test(ii,:) = Data.Fi_N290dtw{ii};
        P400mamp_test(ii,:) = Data.Fi_P400mamp{ii};
        DTWP400_test(ii,:) = Data.Fi_P400dtw{ii};
        valid_test(ii,:) = Data.Fi_val{ii};
    end
    clear ii
    % retest session
    N290lat_retest = nan(Nsubjtot/2,Nthrsh); % N290 peak latency
    N290pamp_retest = nan(Nsubjtot/2,Nthrsh); % N290 peak amplitude
    N290mamp_retest = nan(Nsubjtot/2,Nthrsh); % N290 mean amplitude
    DTWN290_retest = nan(Nsubjtot/2,Nthrsh); % DTW during N290 window
    P400mamp_retest = nan(Nsubjtot/2,Nthrsh); % P400 mean amplitude
    DTWP400_retest = nan(Nsubjtot/2,Nthrsh); % DTW during P400 window
    valid_retest = nan(Nsubjtot/2,Nthrsh);
    for ii = 1:(Nsubjtot/2)
        N290lat_retest(ii,:) = Data.Fi_N290lat{ii+(Nsubjtot/2)};
        N290pamp_retest(ii,:) = Data.Fi_N290pamp{ii+(Nsubjtot/2)};
        N290mamp_retest(ii,:) = Data.Fi_N290mamp{ii+(Nsubjtot/2)};
        DTWN290_retest(ii,:) = Data.Fi_N290dtw{ii+(Nsubjtot/2)};
        P400mamp_retest(ii,:) = Data.Fi_P400mamp{ii+(Nsubjtot/2)};
        DTWP400_retest(ii,:) = Data.Fi_P400dtw{ii+(Nsubjtot/2)};
        valid_retest(ii,:) = Data.Fi_val{ii+(Nsubjtot/2)};
    end
    clear ii
    
    % set values for invalid individual ERPs to Nan    
        % test
        N290lat_test(valid_test == 0) = NaN;
        N290pamp_test(valid_test == 0) = NaN;
        N290mamp_test(valid_test == 0) = NaN;
        DTWN290_test(valid_test == 0) = NaN;
        P400mamp_test(valid_test == 0) = NaN;
        DTWP400_test(valid_test == 0) = NaN;
        % retest
        N290lat_retest(valid_test == 0) = NaN;
        N290pamp_retest(valid_test == 0) = NaN;
        N290mamp_retest(valid_test == 0) = NaN;
        DTWN290_retest(valid_test == 0) = NaN;
        P400mamp_retest(valid_test == 0) = NaN;
        DTWP400_retest(valid_test == 0) = NaN;
  
% preallocate variables for ICC        
    ICCtype = 'C-1';
    
    ICCvals_FacesInv = struct;
    ICCvals_FacesInv.N290plat = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesInv.N290pamp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesInv.N290mamp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesInv.N290dtw = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesInv.P400mamp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesInv.P400dtw = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesInv.ICCdim1_Thresholds = Thrs_trls;
    ICCvals_FacesInv.ICCdim2_Values = {strcat('rho: ',ICCtype),'LB','UB','pval'};
        
        
% plot the data for N290 features and put ICC in title %%%%%%%%%%%%%%%%%%%%   
    % common parameters
    MkrS = 12;
    Str1_axis = 'Session 1';
    Str2_axis = 'Session 2';
    Rows_fig = 4;
    Thrs_trls = ICCvals_FacesInv.ICCdim1_Thresholds;

Figure_FacesInv_N290features = figure;   

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
        ICCvals_FacesInv.N290plat(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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
        ICCvals_FacesInv.N290pamp(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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
        ICCvals_FacesInv.N290mamp(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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

    
% DTWdir N290
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)*3));
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
        ICCvals_FacesInv.N290dtw(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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
    
    
    
sgtitle({'Braintools UK: ICCs for N290 features during faces inverted'}, 'FontSize',14)    






% plot the data for P400 features and put ICC in title %%%%%%%%%%%%%%%%%%%%   

Figure_FacesInv_P400features = figure;  

    
% P400 mean amplitude
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)));
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
        ICCvals_FacesInv.P400mamp(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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
        ICCvals_FacesInv.P400dtw(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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
    
sgtitle({'Braintools UK: ICCs for P400 features during faces inverted'}, 'FontSize',14)    


%% save the data and figures
    save('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/FacesInv_ICCvals.mat','ICCvals_FacesInv')
    saveas(Figure_FacesInv_N290features,'/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_Figures_graphs/ICCs_FacesInv_N290features.tif')
    saveas(Figure_FacesInv_P400features,'/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_Figures_graphs/ICCs_FacesInv_P400features.tif')

% clean up
    clear Nsubjtot N290lat_test N290pamp_test N290mamp_test DTWN290_test P400mamp_test DTWP400_test valid_test 
    clear N290lat_retest N290pamp_retest N290mamp_retest DTWN290_retest P400mamp_retest DTWP400_retest valid_retest 
    clear Axis_max Axis_min MkrS Nthrsh Rows_fig sp Str1_axis Str2_axis Thrs_trls tt ICCtype
    clear Figure_FacesInv_N290features Figure_FacesInv_P400features
    clear ICCvals_FacesInv

    
    
    
    
    
    
    
%% Faces condition effect: inv - up %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
% prep data
    Nsubjtot = height(Data); Nthrsh = length(Data.Nrantrls{1});
    Thrs_trls = Data.Nrantrls{1};
    % test session
    N290lat_test = nan(Nsubjtot/2,Nthrsh); % N290 peak latency
    N290pamp_test = nan(Nsubjtot/2,Nthrsh); % N290 peak amplitude
    N290mamp_test = nan(Nsubjtot/2,Nthrsh); % N290 mean amplitude
    DTWN290_test = nan(Nsubjtot/2,Nthrsh); % DTW during N290 window
    P400mamp_test = nan(Nsubjtot/2,Nthrsh); % P400 mean amplitude
    DTWP400_test = nan(Nsubjtot/2,Nthrsh); % DTW during P400 window
    for ii = 1:(Nsubjtot/2)
        N290lat_test(ii,:) = Data.CE_N290lat{ii};
        N290pamp_test(ii,:) = Data.CE_N290pamp{ii};
        N290mamp_test(ii,:) = Data.CE_N290mamp{ii};
        DTWN290_test(ii,:) = Data.CE_N290dtw{ii};
        P400mamp_test(ii,:) = Data.CE_P400mamp{ii};
        DTWP400_test(ii,:) = Data.CE_P400dtw{ii};
    end
    clear ii
    % retest session
    N290lat_retest = nan(Nsubjtot/2,Nthrsh); % N290 peak latency
    N290pamp_retest = nan(Nsubjtot/2,Nthrsh); % N290 peak amplitude
    N290mamp_retest = nan(Nsubjtot/2,Nthrsh); % N290 mean amplitude
    DTWN290_retest = nan(Nsubjtot/2,Nthrsh); % DTW during N290 window
    P400mamp_retest = nan(Nsubjtot/2,Nthrsh); % P400 mean amplitude
    DTWP400_retest = nan(Nsubjtot/2,Nthrsh); % DTW during P400 window
    for ii = 1:(Nsubjtot/2)
        N290lat_retest(ii,:) = Data.CE_N290lat{ii+(Nsubjtot/2)};
        N290pamp_retest(ii,:) = Data.CE_N290pamp{ii+(Nsubjtot/2)};
        N290mamp_retest(ii,:) = Data.CE_N290mamp{ii+(Nsubjtot/2)};
        DTWN290_retest(ii,:) = Data.CE_N290dtw{ii+(Nsubjtot/2)};
        P400mamp_retest(ii,:) = Data.CE_P400mamp{ii+(Nsubjtot/2)};
        DTWP400_retest(ii,:) = Data.CE_P400dtw{ii+(Nsubjtot/2)};
    end
    clear ii
  
% preallocate variables for ICC        
    ICCtype = 'C-1';
    
    ICCvals_FacesCE = struct;
    ICCvals_FacesCE.N290plat = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesCE.N290pamp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesCE.N290mamp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesCE.N290dtw = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesCE.P400mamp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesCE.P400dtw = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesCE.ICCdim1_Thresholds = Thrs_trls;
    ICCvals_FacesCE.ICCdim2_Values = {strcat('rho: ',ICCtype),'LB','UB','pval'};
        
        
% plot the data for N290 features and put ICC in title %%%%%%%%%%%%%%%%%%%%   
    % common parameters
    MkrS = 12;
    Str1_axis = 'Session 1';
    Str2_axis = 'Session 2';
    Rows_fig = 4;
    Thrs_trls = ICCvals_FacesCE.ICCdim1_Thresholds;

Figure_FacesCE_N290features = figure;   

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
        ax = gca; ax.XAxisLocation = 'origin'; ax.YAxisLocation = 'origin';
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_FacesCE.N290plat(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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
        ax = gca; ax.XAxisLocation = 'origin'; ax.YAxisLocation = 'origin';
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_FacesCE.N290pamp(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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
        ax = gca; ax.XAxisLocation = 'origin'; ax.YAxisLocation = 'origin';
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_FacesCE.N290mamp(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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

    
% DTWdir N290
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)*3));
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
        ax = gca; ax.XAxisLocation = 'origin'; ax.YAxisLocation = 'origin';
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_FacesCE.N290dtw(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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
    
    
    
sgtitle({'Braintools UK: ICCs for N290 features face condition effects (Inv - Up)'}, 'FontSize',14)    






% plot the data for P400 features and put ICC in title %%%%%%%%%%%%%%%%%%%%   

Figure_FacesCE_P400features = figure;  

    
% P400 mean amplitude
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)));
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
        ax = gca; ax.XAxisLocation = 'origin'; ax.YAxisLocation = 'origin';
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_FacesCE.P400mamp(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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
        ax = gca; ax.XAxisLocation = 'origin'; ax.YAxisLocation = 'origin';
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_FacesCE.P400dtw(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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
    
sgtitle({'Braintools UK: ICCs for P400 features face condition effects (Inv - Up)'}, 'FontSize',14)    







%% save the data and figures
    save('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/FacesCE_ICCvals.mat','ICCvals_FacesCE')
    saveas(Figure_FacesCE_N290features,'/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_Figures_graphs/ICCs_FacesCE_N290features.tif')
    saveas(Figure_FacesCE_P400features,'/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_Figures_graphs/ICCs_FacesCE_P400features.tif')

% clean up
    clear Nsubjtot N290lat_test N290pamp_test N290mamp_test DTWN290_test P400mamp_test DTWP400_test valid_test 
    clear N290lat_retest N290pamp_retest N290mamp_retest DTWN290_retest P400mamp_retest DTWP400_retest valid_retest 
    clear Axis_max Axis_min MkrS Nthrsh Rows_fig sp Str1_axis Str2_axis Thrs_trls tt ICCtype
    clear Figure_FacesInv_N290features Figure_FacesInv_P400features
    clear ICCvals_FacesInv


%% test condition effects at test and retest for each feature

clear variables
% braintools UK specific analysis scripts    
    addpath('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrT_UK_scripts_publication');

% load table with the data
    load /Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrTUK_CE_ERPs_Nrandtrls.mat
% rename to data for ease
    % rename to data for ease 
    Data = BrtUK_CE_ERPs_Nrandtrls; 
    clear BrtUK_CE_ERPs_Nrandtrls

    
% prep data for test
    Nsubjtot = height(Data); Nthrsh = length(Data.Nrantrls{1});
    Thrs_trls = Data.Nrantrls{1};
    % Face up 
        T_N290lat_Fu = nan(Nsubjtot/2,Nthrsh); % N290 peak latency
        T_N290pamp_Fu = nan(Nsubjtot/2,Nthrsh); % N290 peak amplitude
        T_N290mamp_Fu = nan(Nsubjtot/2,Nthrsh); % N290 mean amplitude
        T_DTWN290_Fu = nan(Nsubjtot/2,Nthrsh); % DTW during N290 window
        T_P400mamp_Fu = nan(Nsubjtot/2,Nthrsh); % P400 mean amplitude
        valid_test = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            T_N290lat_Fu(ii,:) = Data.Fu_N290lat{ii};
            T_N290pamp_Fu(ii,:) = Data.Fu_N290pamp{ii};
            T_N290mamp_Fu(ii,:) = Data.Fu_N290mamp{ii};
            T_DTWN290_Fu(ii,:) = Data.Fu_N290dtw{ii};
            T_P400mamp_Fu(ii,:) = Data.Fu_P400mamp{ii};
            valid_test(ii,:) = Data.Fu_val{ii};
        end
        clear ii
        % set values for invalid individual ERPs to Nan    
        % test
        T_N290lat_Fu(valid_test == 0) = NaN;
        T_N290pamp_Fu(valid_test == 0) = NaN;
        T_N290mamp_Fu(valid_test == 0) = NaN;
        T_DTWN290_Fu(valid_test == 0) = NaN;
        T_P400mamp_Fu(valid_test == 0) = NaN;
        clear valid_test
        
    % Face inv
        T_N290lat_Fi = nan(Nsubjtot/2,Nthrsh); % N290 peak latency
        T_N290pamp_Fi = nan(Nsubjtot/2,Nthrsh); % N290 peak amplitude
        T_N290mamp_Fi = nan(Nsubjtot/2,Nthrsh); % N290 mean amplitude
        T_DTWN290_Fi = nan(Nsubjtot/2,Nthrsh); % DTW during N290 window
        T_P400mamp_Fi = nan(Nsubjtot/2,Nthrsh); % P400 mean amplitude
        valid_test = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            T_N290lat_Fi(ii,:) = Data.Fi_N290lat{ii};
            T_N290pamp_Fi(ii,:) = Data.Fi_N290pamp{ii};
            T_N290mamp_Fi(ii,:) = Data.Fi_N290mamp{ii};
            T_DTWN290_Fi(ii,:) = Data.Fi_N290dtw{ii};
            T_P400mamp_Fi(ii,:) = Data.Fi_P400mamp{ii};
            valid_test(ii,:) = Data.Fi_val{ii};
        end
        clear ii
        % set values for invalid individual ERPs to Nan    
        % test
        T_N290lat_Fi(valid_test == 0) = NaN;
        T_N290pamp_Fi(valid_test == 0) = NaN;
        T_N290mamp_Fi(valid_test == 0) = NaN;
        T_DTWN290_Fi(valid_test == 0) = NaN;
        T_P400mamp_Fi(valid_test == 0) = NaN;    
        clear valid_test
   
        TestCE = struct();
        TestCE.Dim = {'h paired samples t-test, p-val, meanFu, meanFi'};
        TestCE.N290_lat = zeros(Nthrsh,5);
        TestCE.N290_pamp = zeros(Nthrsh,5);
        TestCE.N290_mamp = zeros(Nthrsh,5);
        TestCE.N290_dtw = zeros(Nthrsh,5);
        TestCE.P400_mamp = zeros(Nthrsh,5);
        
        
% prep data for retest        
    % Face up 
        RT_N290lat_Fu = nan(Nsubjtot/2,Nthrsh); % N290 peak latency
        RT_N290pamp_Fu = nan(Nsubjtot/2,Nthrsh); % N290 peak amplitude
        RT_N290mamp_Fu = nan(Nsubjtot/2,Nthrsh); % N290 mean amplitude
        RT_DTWN290_Fu = nan(Nsubjtot/2,Nthrsh); % DTW during N290 window
        RT_P400mamp_Fu = nan(Nsubjtot/2,Nthrsh); % P400 mean amplitude
        RT_valid_test = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            RT_N290lat_Fu(ii,:) = Data.Fu_N290lat{ii+(Nsubjtot/2)};
            RT_N290pamp_Fu(ii,:) = Data.Fu_N290pamp{ii+(Nsubjtot/2)};
            RT_N290mamp_Fu(ii,:) = Data.Fu_N290mamp{ii+(Nsubjtot/2)};
            RT_DTWN290_Fu(ii,:) = Data.Fu_N290dtw{ii+(Nsubjtot/2)};
            RT_P400mamp_Fu(ii,:) = Data.Fu_P400mamp{ii+(Nsubjtot/2)};
            RT_valid_test(ii,:) = Data.Fu_val{ii+(Nsubjtot/2)};
        end
        clear ii
        % set values for invalid individual ERPs to Nan    
        % test
        T_N290lat_Fu(RT_valid_test == 0) = NaN;
        T_N290pamp_Fu(RT_valid_test == 0) = NaN;
        T_N290mamp_Fu(RT_valid_test == 0) = NaN;
        T_DTWN290_Fu(RT_valid_test == 0) = NaN;
        T_P400mamp_Fu(RT_valid_test == 0) = NaN;
        clear RT_valid_test
        
    % Face inv
        RT_N290lat_Fi = nan(Nsubjtot/2,Nthrsh); % N290 peak latency
        RT_N290pamp_Fi = nan(Nsubjtot/2,Nthrsh); % N290 peak amplitude
        RT_N290mamp_Fi = nan(Nsubjtot/2,Nthrsh); % N290 mean amplitude
        RT_DTWN290_Fi = nan(Nsubjtot/2,Nthrsh); % DTW during N290 window
        RT_P400mamp_Fi = nan(Nsubjtot/2,Nthrsh); % P400 mean amplitude
        RT_valid_test = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            RT_N290lat_Fi(ii,:) = Data.Fi_N290lat{ii+(Nsubjtot/2)};
            RT_N290pamp_Fi(ii,:) = Data.Fi_N290pamp{ii+(Nsubjtot/2)};
            RT_N290mamp_Fi(ii,:) = Data.Fi_N290mamp{ii+(Nsubjtot/2)};
            RT_DTWN290_Fi(ii,:) = Data.Fi_N290dtw{ii+(Nsubjtot/2)};
            RT_P400mamp_Fi(ii,:) = Data.Fi_P400mamp{ii+(Nsubjtot/2)};
            RT_valid_test(ii,:) = Data.Fi_val{ii+(Nsubjtot/2)};
        end
        clear ii
        % set values for invalid individual ERPs to Nan    
        % test
        RT_N290lat_Fi(RT_valid_test == 0) = NaN;
        RT_N290pamp_Fi(RT_valid_test == 0) = NaN;
        RT_N290mamp_Fi(RT_valid_test == 0) = NaN;
        RT_DTWN290_Fi(RT_valid_test == 0) = NaN;
        RT_P400mamp_Fi(RT_valid_test == 0) = NaN;    
        clear RT_valid_test
   
        RetestCE = struct();
        RetestCE.Dim = {'h paired samples t-test, p-val, meanFu, meanFi'};
        RetestCE.N290_lat = zeros(Nthrsh,5);
        RetestCE.N290_pamp = zeros(Nthrsh,5);
        RetestCE.N290_mamp = zeros(Nthrsh,5);
        RetestCE.N290_dtw = zeros(Nthrsh,5);
        RetestCE.P400_mamp = zeros(Nthrsh,5);
        
        
        
%% Calculate condition effects        
       
for tt = 1:length(Thrs_trls)    
  
    % N290 lat
    % get values for paired samples t-test
        CurVals = [T_N290lat_Fu(:,tt), T_N290lat_Fi(:,tt) RT_N290lat_Fu(:,tt), RT_N290lat_Fi(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
    % test
        % perform stats
            [h,p] = ttest(CurVals(:,1),CurVals(:,2));
        % track values
            meansCur = mean(CurVals(:, [1 2]),1);
            TestCE.N290_lat(tt,:) = [h, p, meansCur, size(CurVals,1)];
        % clean up
            clear h p meansCur
    % retest
        % perform stats
            [h,p] = ttest(CurVals(:,3),CurVals(:,4));
        % track values
            meansCur = mean(CurVals(:, [3 4]),1);
            RetestCE.N290_lat(tt,:) = [h, p, meansCur, size(CurVals,1)];
        % clean up
            clear CurVals h p meansCur
        
    % N290 pamp
    % get values for paired samples t-test
        CurVals = [T_N290pamp_Fu(:,tt), T_N290pamp_Fi(:,tt) RT_N290pamp_Fu(:,tt), RT_N290pamp_Fi(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
    % test
        % perform stats
            [h,p] = ttest(CurVals(:,1),CurVals(:,2));
        % track values
            meansCur = mean(CurVals(:, [1 2]),1);
            TestCE.N290_pamp(tt,:) = [h, p, meansCur, size(CurVals,1)];
        % clean up
            clear h p meansCur
    % retest
        % perform stats
            [h,p] = ttest(CurVals(:,3),CurVals(:,4));
        % track values
            meansCur = mean(CurVals(:, [3 4]),1);
            RetestCE.N290_pamp(tt,:) = [h, p, meansCur, size(CurVals,1)];
        % clean up
            clear CurVals h p meansCur      
            
    % N290 mamp
    % get values for paired samples t-test
        CurVals = [T_N290mamp_Fu(:,tt), T_N290mamp_Fi(:,tt) RT_N290mamp_Fu(:,tt), RT_N290mamp_Fi(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
    % test
        % perform stats
            [h,p] = ttest(CurVals(:,1),CurVals(:,2));
        % track values
            meansCur = mean(CurVals(:, [1 2]),1);
            TestCE.N290_mamp(tt,:) = [h, p, meansCur, size(CurVals,1)];
        % clean up
            clear h p meansCur
    % retest
        % perform stats
            [h,p] = ttest(CurVals(:,3),CurVals(:,4));
        % track values
            meansCur = mean(CurVals(:, [3 4]),1);
            RetestCE.N290_mamp(tt,:) = [h, p, meansCur, size(CurVals,1)];
        % clean up
            clear CurVals h p meansCur

    % N290 dtw
    % get values for paired samples t-test
        CurVals = [T_DTWN290_Fu(:,tt), T_DTWN290_Fi(:,tt) RT_DTWN290_Fu(:,tt), RT_DTWN290_Fi(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
    % test
        % perform stats
            [h,p] = ttest(CurVals(:,1),CurVals(:,2));
        % track values
            meansCur = mean(CurVals(:, [1 2]),1);
            TestCE.N290_dtw(tt,:) = [h, p, meansCur, size(CurVals,1)];
        % clean up
            clear h p meansCur  
     % retest
        % perform stats
            [h,p] = ttest(CurVals(:,3),CurVals(:,4));
        % track values
            meansCur = mean(CurVals(:, [3 4]),1);
            RetestCE.N290_dtw(tt,:) = [h, p, meansCur, size(CurVals,1)];
        % clean up
            clear CurVals h p meansCur    

    % P400 pamp
    % get values for paired samples t-test
        CurVals = [T_P400mamp_Fu(:,tt), T_P400mamp_Fi(:,tt) RT_P400mamp_Fu(:,tt), RT_P400mamp_Fi(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
   % test
        % perform stats
            [h,p] = ttest(CurVals(:,1),CurVals(:,2));
        % track values
            meansCur = mean(CurVals(:, [1 2]),1);
            TestCE.P400_mamp(tt,:) = [h, p, meansCur, size(CurVals,1)];
        % clean up
            clear h p meansCur
   % retest
        % perform stats
            [h,p] = ttest(CurVals(:,3),CurVals(:,4));
        % track values
            meansCur = mean(CurVals(:, [3 4]),1);
            RetestCE.P400_mamp(tt,:) = [h, p, meansCur, size(CurVals,1)];
        % clean up
            clear CurVals h p meansCur
            
end



    clear N290lat_Fu N290pamp_Fu N290mamp_Fu DTWN290_Fu P400mamp_Fu
    clear N290lat_Fi N290pamp_Fi N290mamp_Fi DTWN290_Fi P400mamp_Fi

save('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/FacesCE_sign_direction.mat','TestCE','RetestCE')







%% Highly attentive sample %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear variables
% braintools UK specific analysis scripts    
    addpath('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrT_UK_scripts_publication');

% load table with the data
    load /Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrTUK_CE_ERPs_Nrandtrls.mat
    
    % rename to data for ease
    Data_all = BrtUK_CE_ERPs_Nrandtrls;
    clear BrtUK_Faces_features
    % select ppts who were very attentive during the session
    load('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/IDs_samples_HighlyAttentive.mat',...
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






   
%% Faces condition effect: inv - up %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
% prep data
    Nsubjtot = height(Data); Nthrsh = length(Data.Nrantrls{1});
    Thrs_trls = Data.Nrantrls{1};
    % test session
    N290lat_test = nan(Nsubjtot/2,Nthrsh); % N290 peak latency
    N290pamp_test = nan(Nsubjtot/2,Nthrsh); % N290 peak amplitude
    N290mamp_test = nan(Nsubjtot/2,Nthrsh); % N290 mean amplitude
    DTWN290_test = nan(Nsubjtot/2,Nthrsh); % DTW during N290 window
    P400mamp_test = nan(Nsubjtot/2,Nthrsh); % P400 mean amplitude
    DTWP400_test = nan(Nsubjtot/2,Nthrsh); % DTW during P400 window
    for ii = 1:(Nsubjtot/2)
        N290lat_test(ii,:) = Data.CE_N290lat{ii};
        N290pamp_test(ii,:) = Data.CE_N290pamp{ii};
        N290mamp_test(ii,:) = Data.CE_N290mamp{ii};
        DTWN290_test(ii,:) = Data.CE_N290dtw{ii};
        P400mamp_test(ii,:) = Data.CE_P400mamp{ii};
        DTWP400_test(ii,:) = Data.CE_P400dtw{ii};
    end
    clear ii
    % retest session
    N290lat_retest = nan(Nsubjtot/2,Nthrsh); % N290 peak latency
    N290pamp_retest = nan(Nsubjtot/2,Nthrsh); % N290 peak amplitude
    N290mamp_retest = nan(Nsubjtot/2,Nthrsh); % N290 mean amplitude
    DTWN290_retest = nan(Nsubjtot/2,Nthrsh); % DTW during N290 window
    P400mamp_retest = nan(Nsubjtot/2,Nthrsh); % P400 mean amplitude
    DTWP400_retest = nan(Nsubjtot/2,Nthrsh); % DTW during P400 window
    for ii = 1:(Nsubjtot/2)
        N290lat_retest(ii,:) = Data.CE_N290lat{ii+(Nsubjtot/2)};
        N290pamp_retest(ii,:) = Data.CE_N290pamp{ii+(Nsubjtot/2)};
        N290mamp_retest(ii,:) = Data.CE_N290mamp{ii+(Nsubjtot/2)};
        DTWN290_retest(ii,:) = Data.CE_N290dtw{ii+(Nsubjtot/2)};
        P400mamp_retest(ii,:) = Data.CE_P400mamp{ii+(Nsubjtot/2)};
        DTWP400_retest(ii,:) = Data.CE_P400dtw{ii+(Nsubjtot/2)};
    end
    clear ii
  
% preallocate variables for ICC        
    ICCtype = 'C-1';
    
    ICCvals_FacesCE_HAtt = struct;
    ICCvals_FacesCE_HAtt.N290plat = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesCE_HAtt.N290pamp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesCE_HAtt.N290mamp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesCE_HAtt.N290dtw = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesCE_HAtt.P400mamp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesCE_HAtt.P400dtw = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    ICCvals_FacesCE_HAtt.ICCdim1_Thresholds = Thrs_trls;
    ICCvals_FacesCE_HAtt.ICCdim2_Values = {strcat('rho: ',ICCtype),'LB','UB','pval'};
        
        
% plot the data for N290 features and put ICC in title %%%%%%%%%%%%%%%%%%%%   
    % common parameters
    MkrS = 12;
    Str1_axis = 'Session 1';
    Str2_axis = 'Session 2';
    Rows_fig = 4;
    Thrs_trls = ICCvals_FacesCE_HAtt.ICCdim1_Thresholds;

Figure_FacesCE_N290features = figure;   

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
        ax = gca; ax.XAxisLocation = 'origin'; ax.YAxisLocation = 'origin';
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_FacesCE_HAtt.N290plat(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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
        ax = gca; ax.XAxisLocation = 'origin'; ax.YAxisLocation = 'origin';
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_FacesCE_HAtt.N290pamp(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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
        ax = gca; ax.XAxisLocation = 'origin'; ax.YAxisLocation = 'origin';
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_FacesCE_HAtt.N290mamp(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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

    
% DTWdir N290
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)*3));
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
        ax = gca; ax.XAxisLocation = 'origin'; ax.YAxisLocation = 'origin';
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_FacesCE_HAtt.N290dtw(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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
    
    
    
sgtitle({'Braintools UK: ICCs for N290 features face condition effects (Inv - Up)'}, 'FontSize',14)    






% plot the data for P400 features and put ICC in title %%%%%%%%%%%%%%%%%%%%   

Figure_FacesCE_P400features = figure;  

    
% P400 mean amplitude
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)));
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
        ax = gca; ax.XAxisLocation = 'origin'; ax.YAxisLocation = 'origin';
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_FacesCE_HAtt.P400mamp(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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
        ax = gca; ax.XAxisLocation = 'origin'; ax.YAxisLocation = 'origin';
        % calculate ICC and put in matrix
        [r, LB, UB, ~, ~, ~, p] = ICC(CurVals, ICCtype, 0.05, 0);
        ICCvals_FacesCE_HAtt.P400dtw(tt,:) = [r, LB, UB, p, size(CurVals,1)];
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
    
sgtitle({'Braintools UK: ICCs for P400 features face condition effects (Inv - Up)'}, 'FontSize',14)    







%% save the data and figures
    save('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/FacesCE_ICCvals_HAtt.mat','ICCvals_FacesCE_HAtt')
    saveas(Figure_FacesCE_N290features,'/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_Figures_graphs/ICCs_FacesCE_N290features_HAtt.tif')
    saveas(Figure_FacesCE_P400features,'/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_Figures_graphs/ICCs_FacesCE_P400features_HAtt.tif')

% clean up
    clear Nsubjtot N290lat_test N290pamp_test N290mamp_test DTWN290_test P400mamp_test DTWP400_test valid_test 
    clear N290lat_retest N290pamp_retest N290mamp_retest DTWN290_retest P400mamp_retest DTWP400_retest valid_retest 
    clear Axis_max Axis_min MkrS Nthrsh Rows_fig sp Str1_axis Str2_axis Thrs_trls tt ICCtype
    clear Figure_FacesInv_N290features Figure_FacesInv_P400features
    clear ICCvals_FacesInv


    
    
%% test condition effects at test and retest for each feature

clear variables
% braintools UK specific analysis scripts    
    addpath('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrT_UK_scripts_publication');

% load table with the data
    load /Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrTUK_CE_ERPs_Nrandtrls.mat
% rename to data for ease
    Data_all = BrtUK_CE_ERPs_Nrandtrls;
    clear BrtUK_Faces_features
    % select ppts who were very attentive during the session
    load('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/IDs_samples_HighlyAttentive.mat',...
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
    

    
% prep data for test
    Nsubjtot = height(Data); Nthrsh = length(Data.Nrantrls{1});
    Thrs_trls = Data.Nrantrls{1};
    % Face up 
        T_N290lat_Fu = nan(Nsubjtot/2,Nthrsh); % N290 peak latency
        T_N290pamp_Fu = nan(Nsubjtot/2,Nthrsh); % N290 peak amplitude
        T_N290mamp_Fu = nan(Nsubjtot/2,Nthrsh); % N290 mean amplitude
        T_DTWN290_Fu = nan(Nsubjtot/2,Nthrsh); % DTW during N290 window
        T_P400mamp_Fu = nan(Nsubjtot/2,Nthrsh); % P400 mean amplitude
        valid_test = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            T_N290lat_Fu(ii,:) = Data.Fu_N290lat{ii};
            T_N290pamp_Fu(ii,:) = Data.Fu_N290pamp{ii};
            T_N290mamp_Fu(ii,:) = Data.Fu_N290mamp{ii};
            T_DTWN290_Fu(ii,:) = Data.Fu_N290dtw{ii};
            T_P400mamp_Fu(ii,:) = Data.Fu_P400mamp{ii};
            valid_test(ii,:) = Data.Fu_val{ii};
        end
        clear ii
        % set values for invalid individual ERPs to Nan    
        % test
        T_N290lat_Fu(valid_test == 0) = NaN;
        T_N290pamp_Fu(valid_test == 0) = NaN;
        T_N290mamp_Fu(valid_test == 0) = NaN;
        T_DTWN290_Fu(valid_test == 0) = NaN;
        T_P400mamp_Fu(valid_test == 0) = NaN;
        clear valid_test
        
    % Face inv
        T_N290lat_Fi = nan(Nsubjtot/2,Nthrsh); % N290 peak latency
        T_N290pamp_Fi = nan(Nsubjtot/2,Nthrsh); % N290 peak amplitude
        T_N290mamp_Fi = nan(Nsubjtot/2,Nthrsh); % N290 mean amplitude
        T_DTWN290_Fi = nan(Nsubjtot/2,Nthrsh); % DTW during N290 window
        T_P400mamp_Fi = nan(Nsubjtot/2,Nthrsh); % P400 mean amplitude
        valid_test = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            T_N290lat_Fi(ii,:) = Data.Fi_N290lat{ii};
            T_N290pamp_Fi(ii,:) = Data.Fi_N290pamp{ii};
            T_N290mamp_Fi(ii,:) = Data.Fi_N290mamp{ii};
            T_DTWN290_Fi(ii,:) = Data.Fi_N290dtw{ii};
            T_P400mamp_Fi(ii,:) = Data.Fi_P400mamp{ii};
            valid_test(ii,:) = Data.Fi_val{ii};
        end
        clear ii
        % set values for invalid individual ERPs to Nan    
        % test
        T_N290lat_Fi(valid_test == 0) = NaN;
        T_N290pamp_Fi(valid_test == 0) = NaN;
        T_N290mamp_Fi(valid_test == 0) = NaN;
        T_DTWN290_Fi(valid_test == 0) = NaN;
        T_P400mamp_Fi(valid_test == 0) = NaN;    
        clear valid_test
   
        TestCE_HAtt = struct();
        TestCE_HAtt.Dim = {'h paired samples t-test, p-val, meanFu, meanFi'};
        TestCE_HAtt.N290_lat = zeros(Nthrsh,5);
        TestCE_HAtt.N290_pamp = zeros(Nthrsh,5);
        TestCE_HAtt.N290_mamp = zeros(Nthrsh,5);
        TestCE_HAtt.N290_dtw = zeros(Nthrsh,5);
        TestCE_HAtt.P400_mamp = zeros(Nthrsh,5);
        
        
% prep data for retest        
    % Face up 
        RT_N290lat_Fu = nan(Nsubjtot/2,Nthrsh); % N290 peak latency
        RT_N290pamp_Fu = nan(Nsubjtot/2,Nthrsh); % N290 peak amplitude
        RT_N290mamp_Fu = nan(Nsubjtot/2,Nthrsh); % N290 mean amplitude
        RT_DTWN290_Fu = nan(Nsubjtot/2,Nthrsh); % DTW during N290 window
        RT_P400mamp_Fu = nan(Nsubjtot/2,Nthrsh); % P400 mean amplitude
        RT_valid_test = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            RT_N290lat_Fu(ii,:) = Data.Fu_N290lat{ii+(Nsubjtot/2)};
            RT_N290pamp_Fu(ii,:) = Data.Fu_N290pamp{ii+(Nsubjtot/2)};
            RT_N290mamp_Fu(ii,:) = Data.Fu_N290mamp{ii+(Nsubjtot/2)};
            RT_DTWN290_Fu(ii,:) = Data.Fu_N290dtw{ii+(Nsubjtot/2)};
            RT_P400mamp_Fu(ii,:) = Data.Fu_P400mamp{ii+(Nsubjtot/2)};
            RT_valid_test(ii,:) = Data.Fu_val{ii+(Nsubjtot/2)};
        end
        clear ii
        % set values for invalid individual ERPs to Nan    
        % test
        T_N290lat_Fu(RT_valid_test == 0) = NaN;
        T_N290pamp_Fu(RT_valid_test == 0) = NaN;
        T_N290mamp_Fu(RT_valid_test == 0) = NaN;
        T_DTWN290_Fu(RT_valid_test == 0) = NaN;
        T_P400mamp_Fu(RT_valid_test == 0) = NaN;
        clear RT_valid_test
        
    % Face inv
        RT_N290lat_Fi = nan(Nsubjtot/2,Nthrsh); % N290 peak latency
        RT_N290pamp_Fi = nan(Nsubjtot/2,Nthrsh); % N290 peak amplitude
        RT_N290mamp_Fi = nan(Nsubjtot/2,Nthrsh); % N290 mean amplitude
        RT_DTWN290_Fi = nan(Nsubjtot/2,Nthrsh); % DTW during N290 window
        RT_P400mamp_Fi = nan(Nsubjtot/2,Nthrsh); % P400 mean amplitude
        RT_valid_test = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            RT_N290lat_Fi(ii,:) = Data.Fi_N290lat{ii+(Nsubjtot/2)};
            RT_N290pamp_Fi(ii,:) = Data.Fi_N290pamp{ii+(Nsubjtot/2)};
            RT_N290mamp_Fi(ii,:) = Data.Fi_N290mamp{ii+(Nsubjtot/2)};
            RT_DTWN290_Fi(ii,:) = Data.Fi_N290dtw{ii+(Nsubjtot/2)};
            RT_P400mamp_Fi(ii,:) = Data.Fi_P400mamp{ii+(Nsubjtot/2)};
            RT_valid_test(ii,:) = Data.Fi_val{ii+(Nsubjtot/2)};
        end
        clear ii
        % set values for invalid individual ERPs to Nan    
        % test
        RT_N290lat_Fi(RT_valid_test == 0) = NaN;
        RT_N290pamp_Fi(RT_valid_test == 0) = NaN;
        RT_N290mamp_Fi(RT_valid_test == 0) = NaN;
        RT_DTWN290_Fi(RT_valid_test == 0) = NaN;
        RT_P400mamp_Fi(RT_valid_test == 0) = NaN;    
        clear RT_valid_test
   
        RetestCE_HAtt = struct();
        RetestCE_HAtt.Dim = {'h paired samples t-test, p-val, meanFu, meanFi'};
        RetestCE_HAtt.N290_lat = zeros(Nthrsh,5);
        RetestCE_HAtt.N290_pamp = zeros(Nthrsh,5);
        RetestCE_HAtt.N290_mamp = zeros(Nthrsh,5);
        RetestCE_HAtt.N290_dtw = zeros(Nthrsh,5);
        RetestCE_HAtt.P400_mamp = zeros(Nthrsh,5);
        
        
        
%% Calculate condition effects        
       
for tt = 1:length(Thrs_trls)    
  
    % N290 lat
    % get values for paired samples t-test
        CurVals = [T_N290lat_Fu(:,tt), T_N290lat_Fi(:,tt) RT_N290lat_Fu(:,tt), RT_N290lat_Fi(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
    % test
        % perform stats
            [h,p] = ttest(CurVals(:,1),CurVals(:,2));
        % track values
            meansCur = mean(CurVals(:, [1 2]),1);
            TestCE_HAtt.N290_lat(tt,:) = [h, p, meansCur, size(CurVals,1)];
        % clean up
            clear h p meansCur
    % retest
        % perform stats
            [h,p] = ttest(CurVals(:,3),CurVals(:,4));
        % track values
            meansCur = mean(CurVals(:, [3 4]),1);
            RetestCE_HAtt.N290_lat(tt,:) = [h, p, meansCur, size(CurVals,1)];
        % clean up
            clear CurVals h p meansCur
        
    % N290 pamp
    % get values for paired samples t-test
        CurVals = [T_N290pamp_Fu(:,tt), T_N290pamp_Fi(:,tt) RT_N290pamp_Fu(:,tt), RT_N290pamp_Fi(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
    % test
        % perform stats
            [h,p] = ttest(CurVals(:,1),CurVals(:,2));
        % track values
            meansCur = mean(CurVals(:, [1 2]),1);
            TestCE_HAtt.N290_pamp(tt,:) = [h, p, meansCur, size(CurVals,1)];
        % clean up
            clear h p meansCur
    % retest
        % perform stats
            [h,p] = ttest(CurVals(:,3),CurVals(:,4));
        % track values
            meansCur = mean(CurVals(:, [3 4]),1);
            RetestCE_HAtt.N290_pamp(tt,:) = [h, p, meansCur, size(CurVals,1)];
        % clean up
            clear CurVals h p meansCur      
            
    % N290 mamp
    % get values for paired samples t-test
        CurVals = [T_N290mamp_Fu(:,tt), T_N290mamp_Fi(:,tt) RT_N290mamp_Fu(:,tt), RT_N290mamp_Fi(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
    % test
        % perform stats
            [h,p] = ttest(CurVals(:,1),CurVals(:,2));
        % track values
            meansCur = mean(CurVals(:, [1 2]),1);
            TestCE_HAtt.N290_mamp(tt,:) = [h, p, meansCur, size(CurVals,1)];
        % clean up
            clear h p meansCur
    % retest
        % perform stats
            [h,p] = ttest(CurVals(:,3),CurVals(:,4));
        % track values
            meansCur = mean(CurVals(:, [3 4]),1);
            RetestCE_HAtt.N290_mamp(tt,:) = [h, p, meansCur, size(CurVals,1)];
        % clean up
            clear CurVals h p meansCur

    % N290 dtw
    % get values for paired samples t-test
        CurVals = [T_DTWN290_Fu(:,tt), T_DTWN290_Fi(:,tt) RT_DTWN290_Fu(:,tt), RT_DTWN290_Fi(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
    % test
        % perform stats
            [h,p] = ttest(CurVals(:,1),CurVals(:,2));
        % track values
            meansCur = mean(CurVals(:, [1 2]),1);
            TestCE_HAtt.N290_dtw(tt,:) = [h, p, meansCur, size(CurVals,1)];
        % clean up
            clear h p meansCur  
     % retest
        % perform stats
            [h,p] = ttest(CurVals(:,3),CurVals(:,4));
        % track values
            meansCur = mean(CurVals(:, [3 4]),1);
            RetestCE_HAtt.N290_dtw(tt,:) = [h, p, meansCur, size(CurVals,1)];
        % clean up
            clear CurVals h p meansCur    

    % P400 pamp
    % get values for paired samples t-test
        CurVals = [T_P400mamp_Fu(:,tt), T_P400mamp_Fi(:,tt) RT_P400mamp_Fu(:,tt), RT_P400mamp_Fi(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
   % test
        % perform stats
            [h,p] = ttest(CurVals(:,1),CurVals(:,2));
        % track values
            meansCur = mean(CurVals(:, [1 2]),1);
            TestCE_HAtt.P400_mamp(tt,:) = [h, p, meansCur, size(CurVals,1)];
        % clean up
            clear h p meansCur
   % retest
        % perform stats
            [h,p] = ttest(CurVals(:,3),CurVals(:,4));
        % track values
            meansCur = mean(CurVals(:, [3 4]),1);
            RetestCE_HAtt.P400_mamp(tt,:) = [h, p, meansCur, size(CurVals,1)];
        % clean up
            clear CurVals h p meansCur
            
end



    clear N290lat_Fu N290pamp_Fu N290mamp_Fu DTWN290_Fu P400mamp_Fu
    clear N290lat_Fi N290pamp_Fi N290mamp_Fi DTWN290_Fi P400mamp_Fi

save('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/FacesCE_sign_direction_HAtt.mat','TestCE_HAtt','RetestCE_HAtt')




