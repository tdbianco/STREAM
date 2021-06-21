%%  Braintools UK project test-retest data: Internal consistency - ICC values at test and retest

% This script visualises the relevant EEG features for different numbers of trials from the previous scrips.


% EEG features: 
% checkers: P1 peak latency - peak amplitude, DTW during P1 window
% faces; N290 peak latency - peak amplitude - mean amplitude, DTW during N290 window,
% P400 mean amplitude

% Calls to the ICC function: 
% Arash Salarian (2021). Intraclass Correlation Coefficient (ICC) (https://www.mathworks.com/matlabcentral/fileexchange/22099-intraclass-correlation-coefficient-icc), MATLAB Central File Exchange. Retrieved February 26, 2021.

% RH 13-05-21

%% For checkers

clear variables
% braintools UK specific analysis scripts    
    addpath('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrT_UK_scripts_publication');

% load table with the data
    load('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_InternCons_Checkers.mat');

% rename to data for ease 
Data = BrtUK_InternCons_Checkers; 
clear BrtUK_InternCons_Checkers

% prep data
    Nsubjtot = height(Data); Nthrsh = length(Data.Nrantrls{1});
    Thrs_trls = Data.Nrantrls{1};
    % at test session
        % set A
        P1lat_tA = nan(Nsubjtot/2,Nthrsh); 
        P1pamp_tA = nan(Nsubjtot/2,Nthrsh); 
        P1dtw_tA = nan(Nsubjtot/2,Nthrsh); 
        valid_tA = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            P1lat_tA(ii,:) = Data.CA_P1lat{ii};
            P1pamp_tA(ii,:) = Data.CA_P1pamp{ii};
            P1dtw_tA(ii,:) = Data.CA_P1dtw{ii};
            valid_tA(ii,:) = Data.CA_P1val{ii};
        end
        clear ii
            % set invalid to NaN
            P1lat_tA(valid_tA == 0) = NaN;
            P1pamp_tA(valid_tA == 0) = NaN;
            P1dtw_tA(valid_tA == 0) = NaN;
            
        % set B
        P1lat_tB = nan(Nsubjtot/2,Nthrsh); 
        P1pamp_tB = nan(Nsubjtot/2,Nthrsh); 
        P1dtw_tB = nan(Nsubjtot/2,Nthrsh); 
        valid_tB = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            P1lat_tB(ii,:) = Data.CB_P1lat{ii};
            P1pamp_tB(ii,:) = Data.CB_P1pamp{ii};
            P1dtw_tB(ii,:) = Data.CB_P1dtw{ii};
            valid_tB(ii,:) = Data.CB_P1val{ii};
        end
        clear ii
        % set invalid to NaN
            P1lat_tB(valid_tB == 0) = NaN;
            P1pamp_tB(valid_tB == 0) = NaN;
            P1dtw_tB(valid_tB == 0) = NaN;
            
    % retest session
    % set A
        P1lat_rtA = nan(Nsubjtot/2,Nthrsh); 
        P1pamp_rtA = nan(Nsubjtot/2,Nthrsh); 
        P1dtw_rtA = nan(Nsubjtot/2,Nthrsh); 
        valid_rtA = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            P1lat_rtA(ii,:) = Data.CA_P1lat{ii+(Nsubjtot/2)};
            P1pamp_rtA(ii,:) = Data.CA_P1pamp{ii+(Nsubjtot/2)};
            P1dtw_rtA(ii,:) = Data.CA_P1dtw{ii+(Nsubjtot/2)};
            valid_rtA(ii,:) = Data.CA_P1val{ii+(Nsubjtot/2)};
        end
        clear ii
         % set invalid to NaN
            P1lat_rtA(valid_rtA == 0) = NaN;
            P1pamp_rtA(valid_rtA == 0) = NaN;
            P1dtw_rtA(valid_rtA == 0) = NaN;
        % set B
        P1lat_rtB = nan(Nsubjtot/2,Nthrsh); 
        P1pamp_rtB = nan(Nsubjtot/2,Nthrsh); 
        P1dtw_rtB = nan(Nsubjtot/2,Nthrsh); 
        valid_rtB = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            P1lat_rtB(ii,:) = Data.CB_P1lat{ii+(Nsubjtot/2)};
            P1pamp_rtB(ii,:) = Data.CB_P1pamp{ii+(Nsubjtot/2)};
            P1dtw_rtB(ii,:) = Data.CB_P1dtw{ii+(Nsubjtot/2)};
            valid_rtB(ii,:) = Data.CB_P1val{ii+(Nsubjtot/2)};
        end
        clear ii
        % set invalid to NaN
            P1lat_rtB(valid_rtB == 0) = NaN;
            P1pamp_rtB(valid_rtB == 0) = NaN;
            P1dtw_rtB(valid_rtB == 0) = NaN;
        

% preallocate variables for ICC        
    ICCtype = 'C-1';
    
    IntCon_ICC_Checkers = struct;
    IntCon_ICC_Checkers.Test.P1_Lat = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Checkers.Test.P1_pAmp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Checkers.Test.P1_dtw = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Checkers.Retest.P1_Lat = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Checkers.Retest.P1_pAmp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Checkers.Retest.P1_dtw = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Checkers.ICCdim1_Thresholds = Thrs_trls;
    IntCon_ICC_Checkers.ICCdim2_Values = {strcat('rho: ',ICCtype),'LB','UB','pval'};
        
      
% plot the data for N290 features and put ICC in title %%%%%%%%%%%%%%%%%%%%   
    % common parameters
    MkrS = 12;
    Str1_axis = 'Set A';
    Str2_axis = 'Set B';
    
    
    Rows_fig = 3;
    Thrs_trls = IntCon_ICC_Checkers.ICCdim1_Thresholds;

Figure_Checkers_P1features = figure;   

% P1 peak latency %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),tt);
        % get values for ICC
        CurVals = [P1lat_tA(:,tt), P1lat_tB(:,tt), P1lat_rtA(:,tt), P1lat_rtB(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        if ~isempty(CurVals)
            % plot the data for set A and B in test
            scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled','b')
            xlabel(Str1_axis); ylabel(Str2_axis)
            hold on
            % plot the data for set A and B in retest
            scatter(CurVals(:,3),CurVals(:,4),MkrS,'filled','r')
            % link the axes
            Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
            Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
            ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
            legend({'Test','Retest'},'Location','southoutside','Orientation','horizontal');
            % calculate ICC and put in matrix for test
            [r_t, LB_t, UB_t, ~, ~, ~, p_t] = ICC(CurVals(:,[1,2]), ICCtype, 0.05, 0);
            IntCon_ICC_Checkers.Test.P1_Lat(tt,:) = [r_t, LB_t, UB_t, p_t, size(CurVals,1)];
            % calculate ICC and put in matrix for retest
            [r_rt, LB_rt, UB_rt, ~, ~, ~, p_rt] = ICC(CurVals(:,[3,4]), ICCtype, 0.05, 0);
            IntCon_ICC_Checkers.Retest.P1_Lat(tt,:) = [r_rt, LB_rt, UB_rt, p_rt, size(CurVals,1)];
            
            % create stings for in the title
            if ~isequal(tt,length(Thrs_trls))
                str1 = strcat('P1 lat: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                    num2str(size(CurVals,1)),')');
            else
                str1 = strcat('P1 lat: all trls (N=',...
                    num2str(size(CurVals,1)),')');
            end
            str2 = strcat('ICC test =', num2str(round(r_t,2)),' [',num2str(round(LB_t,2)), ', ', num2str(round(UB_t,2)),']',...
                ', p=',num2str(round(p_t,3)));
            str3 = strcat('ICC retest =', num2str(round(r_rt,2)),' [',num2str(round(LB_rt,2)), ', ', num2str(round(UB_rt,2)),']',...
                ', p=',num2str(round(p_rt,3)));
            title({str1; str2; str3},'FontSize',12)
            clear CurVals str1 str2 r LB UB p 
            clear r_t LB_t UB_t p_t
            clear r_rt LB_rt UB_rt p_rt
           
        else
            scatter(1,1)
            str1 = strcat('P1 lat: ', num2str(Thrs_trls(1,tt)), ' trls (N=0)');
            title({str1},'FontSize',12)
            IntCon_ICC_Checkers.Test.P1_Lat(tt,:) = [NaN NaN NaN NaN 0];
            IntCon_ICC_Checkers.Retest.P1_Lat(tt,:) = [NaN NaN NaN NaN 0];
        end
    end


% P1 peak amplitude %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)));
        % get values for ICC
        CurVals = [P1pamp_tA(:,tt), P1pamp_tB(:,tt), P1pamp_rtA(:,tt), P1pamp_rtB(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        if ~isempty(CurVals)
            % plot the data for set A and B in test
            scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled','b')
            xlabel(Str1_axis); ylabel(Str2_axis)
            hold on
            % plot the data for set A and B in retest
            scatter(CurVals(:,3),CurVals(:,4),MkrS,'filled','r')
            % link the axes
            Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
            Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
            ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
            legend({'Test','Retest'},'Location','southoutside','Orientation','horizontal');
            % calculate ICC and put in matrix for test
            [r_t, LB_t, UB_t, ~, ~, ~, p_t] = ICC(CurVals(:,[1,2]), ICCtype, 0.05, 0);
            IntCon_ICC_Checkers.Test.P1_pAmp(tt,:) = [r_t, LB_t, UB_t, p_t, size(CurVals,1)];
            % calculate ICC and put in matrix for retest
            [r_rt, LB_rt, UB_rt, ~, ~, ~, p_rt] = ICC(CurVals(:,[3,4]), ICCtype, 0.05, 0);
            IntCon_ICC_Checkers.Retest.P1_pAmp(tt,:) = [r_rt, LB_rt, UB_rt, p_rt, size(CurVals,1)];
            
            % create stings for in the title
            if ~isequal(tt,length(Thrs_trls))
                str1 = strcat('P1 pamp: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                    num2str(size(CurVals,1)),')');
            else
                str1 = strcat('P1 pamp: all trls (N=',...
                    num2str(size(CurVals,1)),')');
            end
            str2 = strcat('ICC test =', num2str(round(r_t,2)),' [',num2str(round(LB_t,2)), ', ', num2str(round(UB_t,2)),']',...
                ', p=',num2str(round(p_t,3)));
            str3 = strcat('ICC retest =', num2str(round(r_rt,2)),' [',num2str(round(LB_rt,2)), ', ', num2str(round(UB_rt,2)),']',...
                ', p=',num2str(round(p_rt,3)));
            title({str1; str2; str3},'FontSize',12)
            clear CurVals str1 str2 r LB UB p 
            clear r_t LB_t UB_t p_t
            clear r_rt LB_rt UB_rt p_rt
            
        else
            scatter(1,1)
            str1 = strcat('P1 pamp: ', num2str(Thrs_trls(1,tt)), ' trls (N=0)');
            title({str1},'FontSize',12)
            IntCon_ICC_Checkers.Test.P1_pAmp(tt,:) = [NaN NaN NaN NaN 0];
            IntCon_ICC_Checkers.Retest.P1_pAmp(tt,:) = [NaN NaN NaN NaN 0];
        end
    end    
    
    
% P1 dtw %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)*2));
        % get values for ICC
        CurVals = [P1dtw_tA(:,tt), P1dtw_tB(:,tt), P1dtw_rtA(:,tt), P1dtw_rtB(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        if ~isempty(CurVals)
            % plot the data for set A and B in test
            scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled','b')
            xlabel(Str1_axis); ylabel(Str2_axis)
            hold on
            % plot the data for set A and B in retest
            scatter(CurVals(:,3),CurVals(:,4),MkrS,'filled','r')
            % link the axes
            Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
            Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
            ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
            legend({'Test','Retest'},'Location','southoutside','Orientation','horizontal');
            ax = gca; ax.XAxisLocation = 'origin'; ax.YAxisLocation = 'origin';
            % calculate ICC and put in matrix for test
            [r_t, LB_t, UB_t, ~, ~, ~, p_t] = ICC(CurVals(:,[1,2]), ICCtype, 0.05, 0);
            IntCon_ICC_Checkers.Test.P1_dtw(tt,:) = [r_t, LB_t, UB_t, p_t, size(CurVals,1)];
            % calculate ICC and put in matrix for retest
            [r_rt, LB_rt, UB_rt, ~, ~, ~, p_rt] = ICC(CurVals(:,[3,4]), ICCtype, 0.05, 0);
            IntCon_ICC_Checkers.Retest.P1_dtw(tt,:) = [r_rt, LB_rt, UB_rt, p_rt, size(CurVals,1)];
            
            % create stings for in the title
            if ~isequal(tt,length(Thrs_trls))
                str1 = strcat('P1 dtw: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                    num2str(size(CurVals,1)),')');
            else
                str1 = strcat('P1 dtw: all trls (N=',...
                    num2str(size(CurVals,1)),')');
            end
            str2 = strcat('ICC test =', num2str(round(r_t,2)),' [',num2str(round(LB_t,2)), ', ', num2str(round(UB_t,2)),']',...
                ', p=',num2str(round(p_t,3)));
            str3 = strcat('ICC retest =', num2str(round(r_rt,2)),' [',num2str(round(LB_rt,2)), ', ', num2str(round(UB_rt,2)),']',...
                ', p=',num2str(round(p_rt,3)));
            title({str1; str2; str3},'FontSize',12)
            clear CurVals str1 str2 r LB UB p 
            clear r_t LB_t UB_t p_t
            clear r_rt LB_rt UB_rt p_rt
            
        else
            scatter(1,1)
            str1 = strcat('P1 dtw: ', num2str(Thrs_trls(1,tt)), ' trls (N=0)');
            title({str1},'FontSize',12)
            IntCon_ICC_Checkers.Test.P1_dtw(tt,:) = [NaN NaN NaN NaN 0];
            IntCon_ICC_Checkers.Retest.P1_dtw(tt,:) = [NaN NaN NaN NaN 0];
        end
    end     
    
    
%% save the data and figure
    save('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/IntCon_ICC_Checkers.mat','IntCon_ICC_Checkers')
    saveas(Figure_Checkers_P1features,'/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_Figures_graphs/IntCon_ICCs_Checkers_P1features.tif')
 
% clean up    
    clear variables
    
    
    
    
    
%% For Faces %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear variables
% braintools UK specific analysis scripts    
    addpath('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrT_UK_scripts_publication');

% load table with the data
    load('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_InternCons_Faces.mat');

% rename to data for ease 
Data = BrtUK_InternCons_Faces; 
clear BrtUK_InternCons_Faces

% prep data
    Nsubjtot = height(Data); Nthrsh = length(Data.Nrantrls{1});
    Thrs_trls = Data.Nrantrls{1};
    % at test session
        % set A
        N290lat_tA = nan(Nsubjtot/2,Nthrsh); 
        N290pamp_tA = nan(Nsubjtot/2,Nthrsh); 
        N290mamp_tA = nan(Nsubjtot/2,Nthrsh); 
        N290dtw_tA = nan(Nsubjtot/2,Nthrsh); 
        P400mamp_tA = nan(Nsubjtot/2,Nthrsh); 
        valid_tA = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            N290lat_tA(ii,:) = Data.FA_N290lat{ii};
            N290pamp_tA(ii,:) = Data.FA_N290pamp{ii};
            N290mamp_tA(ii,:) = Data.FA_N290mamp{ii};
            N290dtw_tA(ii,:) = Data.FA_N290dtw{ii};
            P400mamp_tA(ii,:) = Data.FA_P400mamp{ii};
            valid_tA(ii,:) = Data.FA_N290val{ii};
        end
        clear ii
            % set invalid to NaN
            N290lat_tA(valid_tA == 0) = NaN;
            N290pamp_tA(valid_tA == 0) = NaN;
            N290mamp_tA(valid_tA == 0) = NaN;    
            N290dtw_tA(valid_tA == 0) = NaN;   
            P400mamp_tA(valid_tA == 0) = NaN;
        % set B
        N290lat_tB = nan(Nsubjtot/2,Nthrsh); 
        N290pamp_tB = nan(Nsubjtot/2,Nthrsh); 
        N290mamp_tB = nan(Nsubjtot/2,Nthrsh); 
        N290dtw_tB = nan(Nsubjtot/2,Nthrsh); 
        P400mamp_tB = nan(Nsubjtot/2,Nthrsh); 
        valid_tB = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            N290lat_tB(ii,:) = Data.FB_N290lat{ii};
            N290pamp_tB(ii,:) = Data.FB_N290pamp{ii};
            N290mamp_tB(ii,:) = Data.FB_N290mamp{ii};
            N290dtw_tB(ii,:) = Data.FB_N290dtw{ii};
            P400mamp_tB(ii,:) = Data.FB_P400mamp{ii};
            valid_tB(ii,:) = Data.FB_N290val{ii};
        end
        clear ii
            % set invalid to NaN
            N290lat_tB(valid_tB == 0) = NaN;
            N290pamp_tB(valid_tB == 0) = NaN;
            N290mamp_tB(valid_tB == 0) = NaN;    
            N290dtw_tB(valid_tB == 0) = NaN;   
            P400mamp_tB(valid_tB == 0) = NaN;    
    
        % at retest session
        % set A
        N290lat_rtA = nan(Nsubjtot/2,Nthrsh); 
        N290pamp_rtA = nan(Nsubjtot/2,Nthrsh); 
        N290mamp_rtA = nan(Nsubjtot/2,Nthrsh); 
        N290dtw_rtA = nan(Nsubjtot/2,Nthrsh); 
        P400mamp_rtA = nan(Nsubjtot/2,Nthrsh); 
        valid_rtA = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            N290lat_rtA(ii,:) = Data.FA_N290lat{ii+(Nsubjtot/2)};
            N290pamp_rtA(ii,:) = Data.FA_N290pamp{ii+(Nsubjtot/2)};
            N290mamp_rtA(ii,:) = Data.FA_N290mamp{ii+(Nsubjtot/2)};
            N290dtw_rtA(ii,:) = Data.FA_N290dtw{ii+(Nsubjtot/2)};
            P400mamp_rtA(ii,:) = Data.FA_P400mamp{ii+(Nsubjtot/2)};
            valid_rtA(ii,:) = Data.FA_N290val{ii+(Nsubjtot/2)};
        end
        clear ii
            % set invalid to NaN
            N290lat_rtA(valid_rtA == 0) = NaN;
            N290pamp_rtA(valid_rtA == 0) = NaN;
            N290mamp_rtA(valid_rtA == 0) = NaN;    
            N290dtw_rtA(valid_rtA == 0) = NaN;   
            P400mamp_rtA(valid_rtA == 0) = NaN;
        % set B
        N290lat_rtB = nan(Nsubjtot/2,Nthrsh); 
        N290pamp_rtB = nan(Nsubjtot/2,Nthrsh); 
        N290mamp_rtB = nan(Nsubjtot/2,Nthrsh); 
        N290dtw_rtB = nan(Nsubjtot/2,Nthrsh); 
        P400mamp_rtB = nan(Nsubjtot/2,Nthrsh); 
        valid_rtB = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            N290lat_rtB(ii,:) = Data.FB_N290lat{ii+(Nsubjtot/2)};
            N290pamp_rtB(ii,:) = Data.FB_N290pamp{ii+(Nsubjtot/2)};
            N290mamp_rtB(ii,:) = Data.FB_N290mamp{ii+(Nsubjtot/2)};
            N290dtw_rtB(ii,:) = Data.FB_N290dtw{ii+(Nsubjtot/2)};
            P400mamp_rtB(ii,:) = Data.FB_P400mamp{ii+(Nsubjtot/2)};
            valid_rtB(ii,:) = Data.FB_N290val{ii+(Nsubjtot/2)};
        end
        clear ii
            % set invalid to NaN
            N290lat_rtB(valid_rtB == 0) = NaN;
            N290pamp_rtB(valid_rtB == 0) = NaN;
            N290mamp_rtB(valid_rtB == 0) = NaN;    
            N290dtw_rtB(valid_rtB == 0) = NaN;   
            P400mamp_rtB(valid_rtB == 0) = NaN;    
    

% preallocate variables for ICC        
    ICCtype = 'C-1';
    
    IntCon_ICC_Faces = struct;
    IntCon_ICC_Faces.Test.N290_Lat = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Faces.Test.N290_pAmp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Faces.Test.N290_mAmp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Faces.Test.N290_dtw = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Faces.Test.P400_mAmp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Faces.Retest.N290_Lat = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Faces.Retest.N290_pAmp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Faces.Retest.N290_mAmp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Faces.Retest.N290_dtw = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Faces.Retest.P400_mAmp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Faces.ICCdim1_Thresholds = Thrs_trls;
    IntCon_ICC_Faces.ICCdim2_Values = {strcat('rho: ',ICCtype),'LB','UB','pval'};
            
            
            
            
% plot the data for N290 features and put ICC in title %%%%%%%%%%%%%%%%%%%%   
    % common parameters
    MkrS = 12;
    Str1_axis = 'Set A';
    Str2_axis = 'Set B';
    
    
    Rows_fig = 3;
    Thrs_trls = IntCon_ICC_Faces.ICCdim1_Thresholds;

Figure_Faces_ERPfeatures1 = figure;   

% N290 peak latency %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),tt);
        % get values for ICC
        CurVals = [N290lat_tA(:,tt), N290lat_tB(:,tt), N290lat_rtA(:,tt), N290lat_rtB(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        if ~isempty(CurVals)
            % plot the data for set A and B in test
            scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled','b')
            xlabel(Str1_axis); ylabel(Str2_axis)
            hold on
            % plot the data for set A and B in retest
            scatter(CurVals(:,3),CurVals(:,4),MkrS,'filled','r')
            % link the axes
            Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
            Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
            ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
            legend({'Test','Retest'},'Location','southoutside','Orientation','horizontal');
            % calculate ICC and put in matrix for test
            [r_t, LB_t, UB_t, ~, ~, ~, p_t] = ICC(CurVals(:,[1,2]), ICCtype, 0.05, 0);
            IntCon_ICC_Faces.Test.N290_Lat(tt,:) = [r_t, LB_t, UB_t, p_t, size(CurVals,1)];
            % calculate ICC and put in matrix for retest
            [r_rt, LB_rt, UB_rt, ~, ~, ~, p_rt] = ICC(CurVals(:,[3,4]), ICCtype, 0.05, 0);
            IntCon_ICC_Faces.Retest.N290_Lat(tt,:) = [r_rt, LB_rt, UB_rt, p_rt, size(CurVals,1)];
            
            % create stings for in the title
            if ~isequal(tt,length(Thrs_trls))
                str1 = strcat('N290 lat: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                    num2str(size(CurVals,1)),')');
            else
                str1 = strcat('N290 lat: all trls (N=',...
                    num2str(size(CurVals,1)),')');
            end
            str2 = strcat('ICC test =', num2str(round(r_t,2)),' [',num2str(round(LB_t,2)), ', ', num2str(round(UB_t,2)),']',...
                ', p=',num2str(round(p_t,3)));
            str3 = strcat('ICC retest =', num2str(round(r_rt,2)),' [',num2str(round(LB_rt,2)), ', ', num2str(round(UB_rt,2)),']',...
                ', p=',num2str(round(p_rt,3)));
            title({str1; str2; str3},'FontSize',12)
            clear CurVals str1 str2 r LB UB p 
            clear r_t LB_t UB_t p_t
            clear r_rt LB_rt UB_rt p_rt
           
        else
            scatter(1,1)
            str1 = strcat('N290 lat: ', num2str(Thrs_trls(1,tt)), ' trls (N=0)');
            title({str1},'FontSize',12)
            IntCon_ICC_Faces.Test.P1_Lat(tt,:) = [NaN NaN NaN NaN 0];
            IntCon_ICC_Faces.Retest.P1_Lat(tt,:) = [NaN NaN NaN NaN 0];
        end
    end
            
            
            
% N290 peak amplitude %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)));
        % get values for ICC
        CurVals = [N290pamp_tA(:,tt), N290pamp_tB(:,tt), N290pamp_rtA(:,tt), N290pamp_rtB(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        if ~isempty(CurVals)
            % plot the data for set A and B in test
            scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled','b')
            xlabel(Str1_axis); ylabel(Str2_axis)
            hold on
            % plot the data for set A and B in retest
            scatter(CurVals(:,3),CurVals(:,4),MkrS,'filled','r')
            % link the axes
            Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
            Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
            ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
            legend({'Test','Retest'},'Location','southoutside','Orientation','horizontal');
            % calculate ICC and put in matrix for test
            [r_t, LB_t, UB_t, ~, ~, ~, p_t] = ICC(CurVals(:,[1,2]), ICCtype, 0.05, 0);
            IntCon_ICC_Faces.Test.N290_pAmp(tt,:) = [r_t, LB_t, UB_t, p_t, size(CurVals,1)];
            % calculate ICC and put in matrix for retest
            [r_rt, LB_rt, UB_rt, ~, ~, ~, p_rt] = ICC(CurVals(:,[3,4]), ICCtype, 0.05, 0);
            IntCon_ICC_Faces.Retest.N290_pAmp(tt,:) = [r_rt, LB_rt, UB_rt, p_rt, size(CurVals,1)];
            
            % create stings for in the title
            if ~isequal(tt,length(Thrs_trls))
                str1 = strcat('N290 pamp: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                    num2str(size(CurVals,1)),')');
            else
                str1 = strcat('N290 pamp: all trls (N=',...
                    num2str(size(CurVals,1)),')');
            end
            str2 = strcat('ICC test =', num2str(round(r_t,2)),' [',num2str(round(LB_t,2)), ', ', num2str(round(UB_t,2)),']',...
                ', p=',num2str(round(p_t,3)));
            str3 = strcat('ICC retest =', num2str(round(r_rt,2)),' [',num2str(round(LB_rt,2)), ', ', num2str(round(UB_rt,2)),']',...
                ', p=',num2str(round(p_rt,3)));
            title({str1; str2; str3},'FontSize',12)
            clear CurVals str1 str2 r LB UB p 
            clear r_t LB_t UB_t p_t
            clear r_rt LB_rt UB_rt p_rt
           
        else
            scatter(1,1)
            str1 = strcat('N290 pamp: ', num2str(Thrs_trls(1,tt)), ' trls (N=0)');
            title({str1},'FontSize',12)
            IntCon_ICC_Faces.Test.N290_pAmp(tt,:) = [NaN NaN NaN NaN 0];
            IntCon_ICC_Faces.Retest.N290_pAmp(tt,:) = [NaN NaN NaN NaN 0];
        end
    end          
            
 
    
% N290 mean amplitude %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)*2));
        % get values for ICC
        CurVals = [N290mamp_tA(:,tt), N290mamp_tB(:,tt), N290mamp_rtA(:,tt), N290mamp_rtB(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        if ~isempty(CurVals)
            % plot the data for set A and B in test
            scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled','b')
            xlabel(Str1_axis); ylabel(Str2_axis)
            hold on
            % plot the data for set A and B in retest
            scatter(CurVals(:,3),CurVals(:,4),MkrS,'filled','r')
            % link the axes
            Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
            Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
            ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
            legend({'Test','Retest'},'Location','southoutside','Orientation','horizontal');
            % calculate ICC and put in matrix for test
            [r_t, LB_t, UB_t, ~, ~, ~, p_t] = ICC(CurVals(:,[1,2]), ICCtype, 0.05, 0);
            IntCon_ICC_Faces.Test.N290_mAmp(tt,:) = [r_t, LB_t, UB_t, p_t, size(CurVals,1)];
            % calculate ICC and put in matrix for retest
            [r_rt, LB_rt, UB_rt, ~, ~, ~, p_rt] = ICC(CurVals(:,[3,4]), ICCtype, 0.05, 0);
            IntCon_ICC_Faces.Retest.N290_mAmp(tt,:) = [r_rt, LB_rt, UB_rt, p_rt, size(CurVals,1)];
            
            % create stings for in the title
            if ~isequal(tt,length(Thrs_trls))
                str1 = strcat('N290 mamp: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                    num2str(size(CurVals,1)),')');
            else
                str1 = strcat('N290 mamp: all trls (N=',...
                    num2str(size(CurVals,1)),')');
            end
            str2 = strcat('ICC test =', num2str(round(r_t,2)),' [',num2str(round(LB_t,2)), ', ', num2str(round(UB_t,2)),']',...
                ', p=',num2str(round(p_t,3)));
            str3 = strcat('ICC retest =', num2str(round(r_rt,2)),' [',num2str(round(LB_rt,2)), ', ', num2str(round(UB_rt,2)),']',...
                ', p=',num2str(round(p_rt,3)));
            title({str1; str2; str3},'FontSize',12)
            clear CurVals str1 str2 r LB UB p 
            clear r_t LB_t UB_t p_t
            clear r_rt LB_rt UB_rt p_rt
           
        else
            scatter(1,1)
            str1 = strcat('N290 mamp: ', num2str(Thrs_trls(1,tt)), ' trls (N=0)');
            title({str1},'FontSize',12)
            IntCon_ICC_Faces.Test.N290_mAmp(tt,:) = [NaN NaN NaN NaN 0];
            IntCon_ICC_Faces.Retest.N290_mAmp(tt,:) = [NaN NaN NaN NaN 0];
        end
    end          

Figure_Faces_ERPfeatures2 = figure;   
Rows_fig = 2;   
    
% N290 dtw %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),tt);
        % get values for ICC
        CurVals = [N290dtw_tA(:,tt), N290dtw_tB(:,tt), N290dtw_rtA(:,tt), N290dtw_rtB(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        if ~isempty(CurVals)
            % plot the data for set A and B in test
            scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled','b')
            xlabel(Str1_axis); ylabel(Str2_axis)
            hold on
            % plot the data for set A and B in retest
            scatter(CurVals(:,3),CurVals(:,4),MkrS,'filled','r')
            % link the axes
            Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
            Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
            ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
            legend({'Test','Retest'},'Location','southoutside','Orientation','horizontal');
            % calculate ICC and put in matrix for test
            [r_t, LB_t, UB_t, ~, ~, ~, p_t] = ICC(CurVals(:,[1,2]), ICCtype, 0.05, 0);
            IntCon_ICC_Faces.Test.N290_dtw(tt,:) = [r_t, LB_t, UB_t, p_t, size(CurVals,1)];
            % calculate ICC and put in matrix for retest
            [r_rt, LB_rt, UB_rt, ~, ~, ~, p_rt] = ICC(CurVals(:,[3,4]), ICCtype, 0.05, 0);
            IntCon_ICC_Faces.Retest.N290_dtw(tt,:) = [r_rt, LB_rt, UB_rt, p_rt, size(CurVals,1)];
            
            % create stings for in the title
            if ~isequal(tt,length(Thrs_trls))
                str1 = strcat('N290 dtw: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                    num2str(size(CurVals,1)),')');
            else
                str1 = strcat('N290 dtw: all trls (N=',...
                    num2str(size(CurVals,1)),')');
            end
            str2 = strcat('ICC test =', num2str(round(r_t,2)),' [',num2str(round(LB_t,2)), ', ', num2str(round(UB_t,2)),']',...
                ', p=',num2str(round(p_t,3)));
            str3 = strcat('ICC retest =', num2str(round(r_rt,2)),' [',num2str(round(LB_rt,2)), ', ', num2str(round(UB_rt,2)),']',...
                ', p=',num2str(round(p_rt,3)));
            title({str1; str2; str3},'FontSize',12)
            clear CurVals str1 str2 r LB UB p 
            clear r_t LB_t UB_t p_t
            clear r_rt LB_rt UB_rt p_rt
           
        else
            scatter(1,1)
            str1 = strcat('N290 dtw: ', num2str(Thrs_trls(1,tt)), ' trls (N=0)');
            title({str1},'FontSize',12)
            IntCon_ICC_Faces.Test.N290_dtw(tt,:) = [NaN NaN NaN NaN 0];
            IntCon_ICC_Faces.Retest.N290_dtw(tt,:) = [NaN NaN NaN NaN 0];
        end
    end          
    
  
    
    
    
% P400 mean amplitude %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)));
        % get values for ICC
        CurVals = [P400mamp_tA(:,tt), P400mamp_tB(:,tt), P400mamp_rtA(:,tt), P400mamp_rtB(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        if ~isempty(CurVals)
            % plot the data for set A and B in test
            scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled','b')
            xlabel(Str1_axis); ylabel(Str2_axis)
            hold on
            % plot the data for set A and B in retest
            scatter(CurVals(:,3),CurVals(:,4),MkrS,'filled','r')
            % link the axes
            Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
            Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
            ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
            legend({'Test','Retest'},'Location','southoutside','Orientation','horizontal');
            % calculate ICC and put in matrix for test
            [r_t, LB_t, UB_t, ~, ~, ~, p_t] = ICC(CurVals(:,[1,2]), ICCtype, 0.05, 0);
            IntCon_ICC_Faces.Test.P400_mAmp(tt,:) = [r_t, LB_t, UB_t, p_t, size(CurVals,1)];
            % calculate ICC and put in matrix for retest
            [r_rt, LB_rt, UB_rt, ~, ~, ~, p_rt] = ICC(CurVals(:,[3,4]), ICCtype, 0.05, 0);
            IntCon_ICC_Faces.Retest.P400_mAmp(tt,:) = [r_rt, LB_rt, UB_rt, p_rt, size(CurVals,1)];
            
            % create stings for in the title
            if ~isequal(tt,length(Thrs_trls))
                str1 = strcat('P400 mamp: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                    num2str(size(CurVals,1)),')');
            else
                str1 = strcat('P400 mamp: all trls (N=',...
                    num2str(size(CurVals,1)),')');
            end
            str2 = strcat('ICC test =', num2str(round(r_t,2)),' [',num2str(round(LB_t,2)), ', ', num2str(round(UB_t,2)),']',...
                ', p=',num2str(round(p_t,3)));
            str3 = strcat('ICC retest =', num2str(round(r_rt,2)),' [',num2str(round(LB_rt,2)), ', ', num2str(round(UB_rt,2)),']',...
                ', p=',num2str(round(p_rt,3)));
            title({str1; str2; str3},'FontSize',12)
            clear CurVals str1 str2 r LB UB p 
            clear r_t LB_t UB_t p_t
            clear r_rt LB_rt UB_rt p_rt
           
        else
            scatter(1,1)
            str1 = strcat('P400 mamp: ', num2str(Thrs_trls(1,tt)), ' trls (N=0)');
            title({str1},'FontSize',12)
            IntCon_ICC_Faces.Test.P400_mAmp(tt,:) = [NaN NaN NaN NaN 0];
            IntCon_ICC_Faces.Retest.P400_mAmp(tt,:) = [NaN NaN NaN NaN 0];
        end
    end          

%% save the data and figure
    save('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/IntCon_ICC_Faces.mat','IntCon_ICC_Faces')
    saveas(Figure_Faces_ERPfeatures1,'/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_Figures_graphs/IntCon_ICCs_Faces_ERPfeatures1.tif')
    saveas(Figure_Faces_ERPfeatures2,'/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_Figures_graphs/IntCon_ICCs_Faces_ERPfeatures2.tif')

    
% clean up    
    clear variables
    
    
    
%% In the highly attentive sample %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% For checkers

clear variables
% braintools UK specific analysis scripts    
    addpath('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrT_UK_scripts_publication');

% load table with the data
    load('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_InternCons_Checkers.mat');

    % rename to data for ease
    Data_all = BrtUK_InternCons_Checkers; 
    clear BrtUK_Checkers_features
    
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

    
% prep data
    Nsubjtot = height(Data); Nthrsh = length(Data.Nrantrls{1});
    Thrs_trls = Data.Nrantrls{1};
    % at test session
        % set A
        P1lat_tA = nan(Nsubjtot/2,Nthrsh); 
        P1pamp_tA = nan(Nsubjtot/2,Nthrsh); 
        P1dtw_tA = nan(Nsubjtot/2,Nthrsh); 
        valid_tA = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            P1lat_tA(ii,:) = Data.CA_P1lat{ii};
            P1pamp_tA(ii,:) = Data.CA_P1pamp{ii};
            P1dtw_tA(ii,:) = Data.CA_P1dtw{ii};
            valid_tA(ii,:) = Data.CA_P1val{ii};
        end
        clear ii
            % set invalid to NaN
            P1lat_tA(valid_tA == 0) = NaN;
            P1pamp_tA(valid_tA == 0) = NaN;
            P1dtw_tA(valid_tA == 0) = NaN;
            
        % set B
        P1lat_tB = nan(Nsubjtot/2,Nthrsh); 
        P1pamp_tB = nan(Nsubjtot/2,Nthrsh); 
        P1dtw_tB = nan(Nsubjtot/2,Nthrsh); 
        valid_tB = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            P1lat_tB(ii,:) = Data.CB_P1lat{ii};
            P1pamp_tB(ii,:) = Data.CB_P1pamp{ii};
            P1dtw_tB(ii,:) = Data.CB_P1dtw{ii};
            valid_tB(ii,:) = Data.CB_P1val{ii};
        end
        clear ii
        % set invalid to NaN
            P1lat_tB(valid_tB == 0) = NaN;
            P1pamp_tB(valid_tB == 0) = NaN;
            P1dtw_tB(valid_tB == 0) = NaN;
            
    % retest session
    % set A
        P1lat_rtA = nan(Nsubjtot/2,Nthrsh); 
        P1pamp_rtA = nan(Nsubjtot/2,Nthrsh); 
        P1dtw_rtA = nan(Nsubjtot/2,Nthrsh); 
        valid_rtA = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            P1lat_rtA(ii,:) = Data.CA_P1lat{ii+(Nsubjtot/2)};
            P1pamp_rtA(ii,:) = Data.CA_P1pamp{ii+(Nsubjtot/2)};
            P1dtw_rtA(ii,:) = Data.CA_P1dtw{ii+(Nsubjtot/2)};
            valid_rtA(ii,:) = Data.CA_P1val{ii+(Nsubjtot/2)};
        end
        clear ii
         % set invalid to NaN
            P1lat_rtA(valid_rtA == 0) = NaN;
            P1pamp_rtA(valid_rtA == 0) = NaN;
            P1dtw_rtA(valid_rtA == 0) = NaN;
        % set B
        P1lat_rtB = nan(Nsubjtot/2,Nthrsh); 
        P1pamp_rtB = nan(Nsubjtot/2,Nthrsh); 
        P1dtw_rtB = nan(Nsubjtot/2,Nthrsh); 
        valid_rtB = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            P1lat_rtB(ii,:) = Data.CB_P1lat{ii+(Nsubjtot/2)};
            P1pamp_rtB(ii,:) = Data.CB_P1pamp{ii+(Nsubjtot/2)};
            P1dtw_rtB(ii,:) = Data.CB_P1dtw{ii+(Nsubjtot/2)};
            valid_rtB(ii,:) = Data.CB_P1val{ii+(Nsubjtot/2)};
        end
        clear ii
        % set invalid to NaN
            P1lat_rtB(valid_rtB == 0) = NaN;
            P1pamp_rtB(valid_rtB == 0) = NaN;
            P1dtw_rtB(valid_rtB == 0) = NaN;
        

% preallocate variables for ICC        
    ICCtype = 'C-1';
    
    IntCon_ICC_Checkers_HAtt = struct;
    IntCon_ICC_Checkers_HAtt.Test.P1_Lat = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Checkers_HAtt.Test.P1_pAmp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Checkers_HAtt.Test.P1_dtw = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Checkers_HAtt.Retest.P1_Lat = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Checkers_HAtt.Retest.P1_pAmp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Checkers_HAtt.Retest.P1_dtw = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Checkers_HAtt.ICCdim1_Thresholds = Thrs_trls;
    IntCon_ICC_Checkers_HAtt.ICCdim2_Values = {strcat('rho: ',ICCtype),'LB','UB','pval'};
        
      
% plot the data for N290 features and put ICC in title %%%%%%%%%%%%%%%%%%%%   
    % common parameters
    MkrS = 12;
    Str1_axis = 'Set A';
    Str2_axis = 'Set B';
    
    
    Rows_fig = 3;
    Thrs_trls = IntCon_ICC_Checkers_HAtt.ICCdim1_Thresholds;

Figure_Checkers_P1features = figure;   

% P1 peak latency %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),tt);
        % get values for ICC
        CurVals = [P1lat_tA(:,tt), P1lat_tB(:,tt), P1lat_rtA(:,tt), P1lat_rtB(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        if ~isempty(CurVals)
            % plot the data for set A and B in test
            scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled','b')
            xlabel(Str1_axis); ylabel(Str2_axis)
            hold on
            % plot the data for set A and B in retest
            scatter(CurVals(:,3),CurVals(:,4),MkrS,'filled','r')
            % link the axes
            Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
            Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
            ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
            legend({'Test','Retest'},'Location','southoutside','Orientation','horizontal');
            % calculate ICC and put in matrix for test
            [r_t, LB_t, UB_t, ~, ~, ~, p_t] = ICC(CurVals(:,[1,2]), ICCtype, 0.05, 0);
            IntCon_ICC_Checkers_HAtt.Test.P1_Lat(tt,:) = [r_t, LB_t, UB_t, p_t, size(CurVals,1)];
            % calculate ICC and put in matrix for retest
            [r_rt, LB_rt, UB_rt, ~, ~, ~, p_rt] = ICC(CurVals(:,[3,4]), ICCtype, 0.05, 0);
            IntCon_ICC_Checkers_HAtt.Retest.P1_Lat(tt,:) = [r_rt, LB_rt, UB_rt, p_rt, size(CurVals,1)];
            
            % create stings for in the title
            if ~isequal(tt,length(Thrs_trls))
                str1 = strcat('P1 lat: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                    num2str(size(CurVals,1)),')');
            else
                str1 = strcat('P1 lat: all trls (N=',...
                    num2str(size(CurVals,1)),')');
            end
            str2 = strcat('ICC test =', num2str(round(r_t,2)),' [',num2str(round(LB_t,2)), ', ', num2str(round(UB_t,2)),']',...
                ', p=',num2str(round(p_t,3)));
            str3 = strcat('ICC retest =', num2str(round(r_rt,2)),' [',num2str(round(LB_rt,2)), ', ', num2str(round(UB_rt,2)),']',...
                ', p=',num2str(round(p_rt,3)));
            title({str1; str2; str3},'FontSize',12)
            clear CurVals str1 str2 r LB UB p 
            clear r_t LB_t UB_t p_t
            clear r_rt LB_rt UB_rt p_rt
           
        else
            scatter(1,1)
            str1 = strcat('P1 lat: ', num2str(Thrs_trls(1,tt)), ' trls (N=0)');
            title({str1},'FontSize',12)
            IntCon_ICC_Checkers_HAtt.Test.P1_Lat(tt,:) = [NaN NaN NaN NaN 0];
            IntCon_ICC_Checkers_HAtt.Retest.P1_Lat(tt,:) = [NaN NaN NaN NaN 0];
        end
    end


% P1 peak amplitude %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)));
        % get values for ICC
        CurVals = [P1pamp_tA(:,tt), P1pamp_tB(:,tt), P1pamp_rtA(:,tt), P1pamp_rtB(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        if ~isempty(CurVals)
            % plot the data for set A and B in test
            scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled','b')
            xlabel(Str1_axis); ylabel(Str2_axis)
            hold on
            % plot the data for set A and B in retest
            scatter(CurVals(:,3),CurVals(:,4),MkrS,'filled','r')
            % link the axes
            Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
            Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
            ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
            legend({'Test','Retest'},'Location','southoutside','Orientation','horizontal');
            % calculate ICC and put in matrix for test
            [r_t, LB_t, UB_t, ~, ~, ~, p_t] = ICC(CurVals(:,[1,2]), ICCtype, 0.05, 0);
            IntCon_ICC_Checkers_HAtt.Test.P1_pAmp(tt,:) = [r_t, LB_t, UB_t, p_t, size(CurVals,1)];
            % calculate ICC and put in matrix for retest
            [r_rt, LB_rt, UB_rt, ~, ~, ~, p_rt] = ICC(CurVals(:,[3,4]), ICCtype, 0.05, 0);
            IntCon_ICC_Checkers_HAtt.Retest.P1_pAmp(tt,:) = [r_rt, LB_rt, UB_rt, p_rt, size(CurVals,1)];
            
            % create stings for in the title
            if ~isequal(tt,length(Thrs_trls))
                str1 = strcat('P1 pamp: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                    num2str(size(CurVals,1)),')');
            else
                str1 = strcat('P1 pamp: all trls (N=',...
                    num2str(size(CurVals,1)),')');
            end
            str2 = strcat('ICC test =', num2str(round(r_t,2)),' [',num2str(round(LB_t,2)), ', ', num2str(round(UB_t,2)),']',...
                ', p=',num2str(round(p_t,3)));
            str3 = strcat('ICC retest =', num2str(round(r_rt,2)),' [',num2str(round(LB_rt,2)), ', ', num2str(round(UB_rt,2)),']',...
                ', p=',num2str(round(p_rt,3)));
            title({str1; str2; str3},'FontSize',12)
            clear CurVals str1 str2 r LB UB p 
            clear r_t LB_t UB_t p_t
            clear r_rt LB_rt UB_rt p_rt
            
        else
            scatter(1,1)
            str1 = strcat('P1 pamp: ', num2str(Thrs_trls(1,tt)), ' trls (N=0)');
            title({str1},'FontSize',12)
            IntCon_ICC_Checkers_HAtt.Test.P1_pAmp(tt,:) = [NaN NaN NaN NaN 0];
            IntCon_ICC_Checkers_HAtt.Retest.P1_pAmp(tt,:) = [NaN NaN NaN NaN 0];
        end
    end    
    
    
% P1 dtw %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)*2));
        % get values for ICC
        CurVals = [P1dtw_tA(:,tt), P1dtw_tB(:,tt), P1dtw_rtA(:,tt), P1dtw_rtB(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        if ~isempty(CurVals)
            % plot the data for set A and B in test
            scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled','b')
            xlabel(Str1_axis); ylabel(Str2_axis)
            hold on
            % plot the data for set A and B in retest
            scatter(CurVals(:,3),CurVals(:,4),MkrS,'filled','r')
            % link the axes
            Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
            Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
            ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
            legend({'Test','Retest'},'Location','southoutside','Orientation','horizontal');
            ax = gca; ax.XAxisLocation = 'origin'; ax.YAxisLocation = 'origin';
            % calculate ICC and put in matrix for test
            [r_t, LB_t, UB_t, ~, ~, ~, p_t] = ICC(CurVals(:,[1,2]), ICCtype, 0.05, 0);
            IntCon_ICC_Checkers_HAtt.Test.P1_dtw(tt,:) = [r_t, LB_t, UB_t, p_t, size(CurVals,1)];
            % calculate ICC and put in matrix for retest
            [r_rt, LB_rt, UB_rt, ~, ~, ~, p_rt] = ICC(CurVals(:,[3,4]), ICCtype, 0.05, 0);
            IntCon_ICC_Checkers_HAtt.Retest.P1_dtw(tt,:) = [r_rt, LB_rt, UB_rt, p_rt, size(CurVals,1)];
            
            % create stings for in the title
            if ~isequal(tt,length(Thrs_trls))
                str1 = strcat('P1 dtw: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                    num2str(size(CurVals,1)),')');
            else
                str1 = strcat('P1 dtw: all trls (N=',...
                    num2str(size(CurVals,1)),')');
            end
            str2 = strcat('ICC test =', num2str(round(r_t,2)),' [',num2str(round(LB_t,2)), ', ', num2str(round(UB_t,2)),']',...
                ', p=',num2str(round(p_t,3)));
            str3 = strcat('ICC retest =', num2str(round(r_rt,2)),' [',num2str(round(LB_rt,2)), ', ', num2str(round(UB_rt,2)),']',...
                ', p=',num2str(round(p_rt,3)));
            title({str1; str2; str3},'FontSize',12)
            clear CurVals str1 str2 r LB UB p 
            clear r_t LB_t UB_t p_t
            clear r_rt LB_rt UB_rt p_rt
            
        else
            scatter(1,1)
            str1 = strcat('P1 dtw: ', num2str(Thrs_trls(1,tt)), ' trls (N=0)');
            title({str1},'FontSize',12)
            IntCon_ICC_Checkers_HAtt.Test.P1_dtw(tt,:) = [NaN NaN NaN NaN 0];
            IntCon_ICC_Checkers_HAtt.Retest.P1_dtw(tt,:) = [NaN NaN NaN NaN 0];
        end
    end     
    
    
%% save the data and figure
    save('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/IntCon_ICC_Checkers_HAtt.mat','IntCon_ICC_Checkers_HAtt')
    saveas(Figure_Checkers_P1features,'/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_Figures_graphs/IntCon_ICCs_Checkers_HAtt_P1features.tif')
 
% clean up    
    clear variables
    
    
    
    
    
%% For Faces %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear variables
% braintools UK specific analysis scripts    
    addpath('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrT_UK_scripts_publication');

% load table with the data
    load('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_InternCons_Faces.mat');

    % rename to data for ease
    Data_all = BrtUK_InternCons_Faces; 
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




% prep data
    Nsubjtot = height(Data); Nthrsh = length(Data.Nrantrls{1});
    Thrs_trls = Data.Nrantrls{1};
    % at test session
        % set A
        N290lat_tA = nan(Nsubjtot/2,Nthrsh); 
        N290pamp_tA = nan(Nsubjtot/2,Nthrsh); 
        N290mamp_tA = nan(Nsubjtot/2,Nthrsh); 
        N290dtw_tA = nan(Nsubjtot/2,Nthrsh); 
        P400mamp_tA = nan(Nsubjtot/2,Nthrsh); 
        valid_tA = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            N290lat_tA(ii,:) = Data.FA_N290lat{ii};
            N290pamp_tA(ii,:) = Data.FA_N290pamp{ii};
            N290mamp_tA(ii,:) = Data.FA_N290mamp{ii};
            N290dtw_tA(ii,:) = Data.FA_N290dtw{ii};
            P400mamp_tA(ii,:) = Data.FA_P400mamp{ii};
            valid_tA(ii,:) = Data.FA_N290val{ii};
        end
        clear ii
            % set invalid to NaN
            N290lat_tA(valid_tA == 0) = NaN;
            N290pamp_tA(valid_tA == 0) = NaN;
            N290mamp_tA(valid_tA == 0) = NaN;    
            N290dtw_tA(valid_tA == 0) = NaN;   
            P400mamp_tA(valid_tA == 0) = NaN;
        % set B
        N290lat_tB = nan(Nsubjtot/2,Nthrsh); 
        N290pamp_tB = nan(Nsubjtot/2,Nthrsh); 
        N290mamp_tB = nan(Nsubjtot/2,Nthrsh); 
        N290dtw_tB = nan(Nsubjtot/2,Nthrsh); 
        P400mamp_tB = nan(Nsubjtot/2,Nthrsh); 
        valid_tB = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            N290lat_tB(ii,:) = Data.FB_N290lat{ii};
            N290pamp_tB(ii,:) = Data.FB_N290pamp{ii};
            N290mamp_tB(ii,:) = Data.FB_N290mamp{ii};
            N290dtw_tB(ii,:) = Data.FB_N290dtw{ii};
            P400mamp_tB(ii,:) = Data.FB_P400mamp{ii};
            valid_tB(ii,:) = Data.FB_N290val{ii};
        end
        clear ii
            % set invalid to NaN
            N290lat_tB(valid_tB == 0) = NaN;
            N290pamp_tB(valid_tB == 0) = NaN;
            N290mamp_tB(valid_tB == 0) = NaN;    
            N290dtw_tB(valid_tB == 0) = NaN;   
            P400mamp_tB(valid_tB == 0) = NaN;    
    
        % at retest session
        % set A
        N290lat_rtA = nan(Nsubjtot/2,Nthrsh); 
        N290pamp_rtA = nan(Nsubjtot/2,Nthrsh); 
        N290mamp_rtA = nan(Nsubjtot/2,Nthrsh); 
        N290dtw_rtA = nan(Nsubjtot/2,Nthrsh); 
        P400mamp_rtA = nan(Nsubjtot/2,Nthrsh); 
        valid_rtA = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            N290lat_rtA(ii,:) = Data.FA_N290lat{ii+(Nsubjtot/2)};
            N290pamp_rtA(ii,:) = Data.FA_N290pamp{ii+(Nsubjtot/2)};
            N290mamp_rtA(ii,:) = Data.FA_N290mamp{ii+(Nsubjtot/2)};
            N290dtw_rtA(ii,:) = Data.FA_N290dtw{ii+(Nsubjtot/2)};
            P400mamp_rtA(ii,:) = Data.FA_P400mamp{ii+(Nsubjtot/2)};
            valid_rtA(ii,:) = Data.FA_N290val{ii+(Nsubjtot/2)};
        end
        clear ii
            % set invalid to NaN
            N290lat_rtA(valid_rtA == 0) = NaN;
            N290pamp_rtA(valid_rtA == 0) = NaN;
            N290mamp_rtA(valid_rtA == 0) = NaN;    
            N290dtw_rtA(valid_rtA == 0) = NaN;   
            P400mamp_rtA(valid_rtA == 0) = NaN;
        % set B
        N290lat_rtB = nan(Nsubjtot/2,Nthrsh); 
        N290pamp_rtB = nan(Nsubjtot/2,Nthrsh); 
        N290mamp_rtB = nan(Nsubjtot/2,Nthrsh); 
        N290dtw_rtB = nan(Nsubjtot/2,Nthrsh); 
        P400mamp_rtB = nan(Nsubjtot/2,Nthrsh); 
        valid_rtB = nan(Nsubjtot/2,Nthrsh);
        for ii = 1:(Nsubjtot/2)
            N290lat_rtB(ii,:) = Data.FB_N290lat{ii+(Nsubjtot/2)};
            N290pamp_rtB(ii,:) = Data.FB_N290pamp{ii+(Nsubjtot/2)};
            N290mamp_rtB(ii,:) = Data.FB_N290mamp{ii+(Nsubjtot/2)};
            N290dtw_rtB(ii,:) = Data.FB_N290dtw{ii+(Nsubjtot/2)};
            P400mamp_rtB(ii,:) = Data.FB_P400mamp{ii+(Nsubjtot/2)};
            valid_rtB(ii,:) = Data.FB_N290val{ii+(Nsubjtot/2)};
        end
        clear ii
            % set invalid to NaN
            N290lat_rtB(valid_rtB == 0) = NaN;
            N290pamp_rtB(valid_rtB == 0) = NaN;
            N290mamp_rtB(valid_rtB == 0) = NaN;    
            N290dtw_rtB(valid_rtB == 0) = NaN;   
            P400mamp_rtB(valid_rtB == 0) = NaN;    
    

% preallocate variables for ICC        
    ICCtype = 'C-1';
    
    IntCon_ICC_Faces_HAtt = struct;
    IntCon_ICC_Faces_HAtt.Test.N290_Lat = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Faces_HAtt.Test.N290_pAmp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Faces_HAtt.Test.N290_mAmp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Faces_HAtt.Test.N290_dtw = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Faces_HAtt.Test.P400_mAmp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Faces_HAtt.Retest.N290_Lat = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Faces_HAtt.Retest.N290_pAmp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Faces_HAtt.Retest.N290_mAmp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Faces_HAtt.Retest.N290_dtw = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Faces_HAtt.Retest.P400_mAmp = nan(length(Thrs_trls),5); %r, LB, UB, p values, Nsubj
    IntCon_ICC_Faces_HAtt.ICCdim1_Thresholds = Thrs_trls;
    IntCon_ICC_Faces_HAtt.ICCdim2_Values = {strcat('rho: ',ICCtype),'LB','UB','pval'};
            
            
            
            
% plot the data for N290 features and put ICC in title %%%%%%%%%%%%%%%%%%%%   
    % common parameters
    MkrS = 12;
    Str1_axis = 'Set A';
    Str2_axis = 'Set B';
    
    
    Rows_fig = 3;
    Thrs_trls = IntCon_ICC_Faces_HAtt.ICCdim1_Thresholds;

Figure_Faces_ERPfeatures1 = figure;   

% N290 peak latency %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),tt);
        % get values for ICC
        CurVals = [N290lat_tA(:,tt), N290lat_tB(:,tt), N290lat_rtA(:,tt), N290lat_rtB(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        if ~isempty(CurVals)
            % plot the data for set A and B in test
            scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled','b')
            xlabel(Str1_axis); ylabel(Str2_axis)
            hold on
            % plot the data for set A and B in retest
            scatter(CurVals(:,3),CurVals(:,4),MkrS,'filled','r')
            % link the axes
            Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
            Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
            ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
            legend({'Test','Retest'},'Location','southoutside','Orientation','horizontal');
            % calculate ICC and put in matrix for test
            [r_t, LB_t, UB_t, ~, ~, ~, p_t] = ICC(CurVals(:,[1,2]), ICCtype, 0.05, 0);
            IntCon_ICC_Faces_HAtt.Test.N290_Lat(tt,:) = [r_t, LB_t, UB_t, p_t, size(CurVals,1)];
            % calculate ICC and put in matrix for retest
            [r_rt, LB_rt, UB_rt, ~, ~, ~, p_rt] = ICC(CurVals(:,[3,4]), ICCtype, 0.05, 0);
            IntCon_ICC_Faces_HAtt.Retest.N290_Lat(tt,:) = [r_rt, LB_rt, UB_rt, p_rt, size(CurVals,1)];
            
            % create stings for in the title
            if ~isequal(tt,length(Thrs_trls))
                str1 = strcat('N290 lat: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                    num2str(size(CurVals,1)),')');
            else
                str1 = strcat('N290 lat: all trls (N=',...
                    num2str(size(CurVals,1)),')');
            end
            str2 = strcat('ICC test =', num2str(round(r_t,2)),' [',num2str(round(LB_t,2)), ', ', num2str(round(UB_t,2)),']',...
                ', p=',num2str(round(p_t,3)));
            str3 = strcat('ICC retest =', num2str(round(r_rt,2)),' [',num2str(round(LB_rt,2)), ', ', num2str(round(UB_rt,2)),']',...
                ', p=',num2str(round(p_rt,3)));
            title({str1; str2; str3},'FontSize',12)
            clear CurVals str1 str2 r LB UB p 
            clear r_t LB_t UB_t p_t
            clear r_rt LB_rt UB_rt p_rt
           
        else
            scatter(1,1)
            str1 = strcat('N290 lat: ', num2str(Thrs_trls(1,tt)), ' trls (N=0)');
            title({str1},'FontSize',12)
            IntCon_ICC_Faces_HAtt.Test.P1_Lat(tt,:) = [NaN NaN NaN NaN 0];
            IntCon_ICC_Faces_HAtt.Retest.P1_Lat(tt,:) = [NaN NaN NaN NaN 0];
        end
    end
            
            
            
% N290 peak amplitude %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)));
        % get values for ICC
        CurVals = [N290pamp_tA(:,tt), N290pamp_tB(:,tt), N290pamp_rtA(:,tt), N290pamp_rtB(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        if ~isempty(CurVals)
            % plot the data for set A and B in test
            scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled','b')
            xlabel(Str1_axis); ylabel(Str2_axis)
            hold on
            % plot the data for set A and B in retest
            scatter(CurVals(:,3),CurVals(:,4),MkrS,'filled','r')
            % link the axes
            Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
            Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
            ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
            legend({'Test','Retest'},'Location','southoutside','Orientation','horizontal');
            % calculate ICC and put in matrix for test
            [r_t, LB_t, UB_t, ~, ~, ~, p_t] = ICC(CurVals(:,[1,2]), ICCtype, 0.05, 0);
            IntCon_ICC_Faces_HAtt.Test.N290_pAmp(tt,:) = [r_t, LB_t, UB_t, p_t, size(CurVals,1)];
            % calculate ICC and put in matrix for retest
            [r_rt, LB_rt, UB_rt, ~, ~, ~, p_rt] = ICC(CurVals(:,[3,4]), ICCtype, 0.05, 0);
            IntCon_ICC_Faces_HAtt.Retest.N290_pAmp(tt,:) = [r_rt, LB_rt, UB_rt, p_rt, size(CurVals,1)];
            
            % create stings for in the title
            if ~isequal(tt,length(Thrs_trls))
                str1 = strcat('N290 pamp: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                    num2str(size(CurVals,1)),')');
            else
                str1 = strcat('N290 pamp: all trls (N=',...
                    num2str(size(CurVals,1)),')');
            end
            str2 = strcat('ICC test =', num2str(round(r_t,2)),' [',num2str(round(LB_t,2)), ', ', num2str(round(UB_t,2)),']',...
                ', p=',num2str(round(p_t,3)));
            str3 = strcat('ICC retest =', num2str(round(r_rt,2)),' [',num2str(round(LB_rt,2)), ', ', num2str(round(UB_rt,2)),']',...
                ', p=',num2str(round(p_rt,3)));
            title({str1; str2; str3},'FontSize',12)
            clear CurVals str1 str2 r LB UB p 
            clear r_t LB_t UB_t p_t
            clear r_rt LB_rt UB_rt p_rt
           
        else
            scatter(1,1)
            str1 = strcat('N290 pamp: ', num2str(Thrs_trls(1,tt)), ' trls (N=0)');
            title({str1},'FontSize',12)
            IntCon_ICC_Faces_HAtt.Test.N290_pAmp(tt,:) = [NaN NaN NaN NaN 0];
            IntCon_ICC_Faces_HAtt.Retest.N290_pAmp(tt,:) = [NaN NaN NaN NaN 0];
        end
    end          
            
 
    
% N290 mean amplitude %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)*2));
        % get values for ICC
        CurVals = [N290mamp_tA(:,tt), N290mamp_tB(:,tt), N290mamp_rtA(:,tt), N290mamp_rtB(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        if ~isempty(CurVals)
            % plot the data for set A and B in test
            scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled','b')
            xlabel(Str1_axis); ylabel(Str2_axis)
            hold on
            % plot the data for set A and B in retest
            scatter(CurVals(:,3),CurVals(:,4),MkrS,'filled','r')
            % link the axes
            Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
            Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
            ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
            legend({'Test','Retest'},'Location','southoutside','Orientation','horizontal');
            % calculate ICC and put in matrix for test
            [r_t, LB_t, UB_t, ~, ~, ~, p_t] = ICC(CurVals(:,[1,2]), ICCtype, 0.05, 0);
            IntCon_ICC_Faces_HAtt.Test.N290_mAmp(tt,:) = [r_t, LB_t, UB_t, p_t, size(CurVals,1)];
            % calculate ICC and put in matrix for retest
            [r_rt, LB_rt, UB_rt, ~, ~, ~, p_rt] = ICC(CurVals(:,[3,4]), ICCtype, 0.05, 0);
            IntCon_ICC_Faces_HAtt.Retest.N290_mAmp(tt,:) = [r_rt, LB_rt, UB_rt, p_rt, size(CurVals,1)];
            
            % create stings for in the title
            if ~isequal(tt,length(Thrs_trls))
                str1 = strcat('N290 mamp: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                    num2str(size(CurVals,1)),')');
            else
                str1 = strcat('N290 mamp: all trls (N=',...
                    num2str(size(CurVals,1)),')');
            end
            str2 = strcat('ICC test =', num2str(round(r_t,2)),' [',num2str(round(LB_t,2)), ', ', num2str(round(UB_t,2)),']',...
                ', p=',num2str(round(p_t,3)));
            str3 = strcat('ICC retest =', num2str(round(r_rt,2)),' [',num2str(round(LB_rt,2)), ', ', num2str(round(UB_rt,2)),']',...
                ', p=',num2str(round(p_rt,3)));
            title({str1; str2; str3},'FontSize',12)
            clear CurVals str1 str2 r LB UB p 
            clear r_t LB_t UB_t p_t
            clear r_rt LB_rt UB_rt p_rt
           
        else
            scatter(1,1)
            str1 = strcat('N290 mamp: ', num2str(Thrs_trls(1,tt)), ' trls (N=0)');
            title({str1},'FontSize',12)
            IntCon_ICC_Faces_HAtt.Test.N290_mAmp(tt,:) = [NaN NaN NaN NaN 0];
            IntCon_ICC_Faces_HAtt.Retest.N290_mAmp(tt,:) = [NaN NaN NaN NaN 0];
        end
    end          

Figure_Faces_ERPfeatures2 = figure;   
Rows_fig = 2;   
    
% N290 dtw %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),tt);
        % get values for ICC
        CurVals = [N290dtw_tA(:,tt), N290dtw_tB(:,tt), N290dtw_rtA(:,tt), N290dtw_rtB(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        if ~isempty(CurVals)
            % plot the data for set A and B in test
            scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled','b')
            xlabel(Str1_axis); ylabel(Str2_axis)
            hold on
            % plot the data for set A and B in retest
            scatter(CurVals(:,3),CurVals(:,4),MkrS,'filled','r')
            % link the axes
            Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
            Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
            ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
            legend({'Test','Retest'},'Location','southoutside','Orientation','horizontal');
            % calculate ICC and put in matrix for test
            [r_t, LB_t, UB_t, ~, ~, ~, p_t] = ICC(CurVals(:,[1,2]), ICCtype, 0.05, 0);
            IntCon_ICC_Faces_HAtt.Test.N290_dtw(tt,:) = [r_t, LB_t, UB_t, p_t, size(CurVals,1)];
            % calculate ICC and put in matrix for retest
            [r_rt, LB_rt, UB_rt, ~, ~, ~, p_rt] = ICC(CurVals(:,[3,4]), ICCtype, 0.05, 0);
            IntCon_ICC_Faces_HAtt.Retest.N290_dtw(tt,:) = [r_rt, LB_rt, UB_rt, p_rt, size(CurVals,1)];
            
            % create stings for in the title
            if ~isequal(tt,length(Thrs_trls))
                str1 = strcat('N290 dtw: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                    num2str(size(CurVals,1)),')');
            else
                str1 = strcat('N290 dtw: all trls (N=',...
                    num2str(size(CurVals,1)),')');
            end
            str2 = strcat('ICC test =', num2str(round(r_t,2)),' [',num2str(round(LB_t,2)), ', ', num2str(round(UB_t,2)),']',...
                ', p=',num2str(round(p_t,3)));
            str3 = strcat('ICC retest =', num2str(round(r_rt,2)),' [',num2str(round(LB_rt,2)), ', ', num2str(round(UB_rt,2)),']',...
                ', p=',num2str(round(p_rt,3)));
            title({str1; str2; str3},'FontSize',12)
            clear CurVals str1 str2 r LB UB p 
            clear r_t LB_t UB_t p_t
            clear r_rt LB_rt UB_rt p_rt
           
        else
            scatter(1,1)
            str1 = strcat('N290 dtw: ', num2str(Thrs_trls(1,tt)), ' trls (N=0)');
            title({str1},'FontSize',12)
            IntCon_ICC_Faces_HAtt.Test.N290_dtw(tt,:) = [NaN NaN NaN NaN 0];
            IntCon_ICC_Faces_HAtt.Retest.N290_dtw(tt,:) = [NaN NaN NaN NaN 0];
        end
    end          
    
  
    
    
    
% P400 mean amplitude %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for tt = 1:length(Thrs_trls)
        % create subplot
        sp = subplot(Rows_fig,length(Thrs_trls),(tt+length(Thrs_trls)));
        % get values for ICC
        CurVals = [P400mamp_tA(:,tt), P400mamp_tB(:,tt), P400mamp_rtA(:,tt), P400mamp_rtB(:,tt)];
        CurVals(any(isnan(CurVals),2),:) = []; % get rid on nan values 
        if ~isempty(CurVals)
            % plot the data for set A and B in test
            scatter(CurVals(:,1),CurVals(:,2),MkrS,'filled','b')
            xlabel(Str1_axis); ylabel(Str2_axis)
            hold on
            % plot the data for set A and B in retest
            scatter(CurVals(:,3),CurVals(:,4),MkrS,'filled','r')
            % link the axes
            Axis_min = min([sp.XLim(1,1) sp.YLim(1,1)]);
            Axis_max = max([sp.XLim(1,2) sp.YLim(1,2)]);
            ylim([Axis_min Axis_max]); xlim([Axis_min Axis_max])
            legend({'Test','Retest'},'Location','southoutside','Orientation','horizontal');
            % calculate ICC and put in matrix for test
            [r_t, LB_t, UB_t, ~, ~, ~, p_t] = ICC(CurVals(:,[1,2]), ICCtype, 0.05, 0);
            IntCon_ICC_Faces_HAtt.Test.P400_mAmp(tt,:) = [r_t, LB_t, UB_t, p_t, size(CurVals,1)];
            % calculate ICC and put in matrix for retest
            [r_rt, LB_rt, UB_rt, ~, ~, ~, p_rt] = ICC(CurVals(:,[3,4]), ICCtype, 0.05, 0);
            IntCon_ICC_Faces_HAtt.Retest.P400_mAmp(tt,:) = [r_rt, LB_rt, UB_rt, p_rt, size(CurVals,1)];
            
            % create stings for in the title
            if ~isequal(tt,length(Thrs_trls))
                str1 = strcat('P400 mamp: ', num2str(Thrs_trls(1,tt)), ' trls (N=',...
                    num2str(size(CurVals,1)),')');
            else
                str1 = strcat('P400 mamp: all trls (N=',...
                    num2str(size(CurVals,1)),')');
            end
            str2 = strcat('ICC test =', num2str(round(r_t,2)),' [',num2str(round(LB_t,2)), ', ', num2str(round(UB_t,2)),']',...
                ', p=',num2str(round(p_t,3)));
            str3 = strcat('ICC retest =', num2str(round(r_rt,2)),' [',num2str(round(LB_rt,2)), ', ', num2str(round(UB_rt,2)),']',...
                ', p=',num2str(round(p_rt,3)));
            title({str1; str2; str3},'FontSize',12)
            clear CurVals str1 str2 r LB UB p 
            clear r_t LB_t UB_t p_t
            clear r_rt LB_rt UB_rt p_rt
           
        else
            scatter(1,1)
            str1 = strcat('P400 mamp: ', num2str(Thrs_trls(1,tt)), ' trls (N=0)');
            title({str1},'FontSize',12)
            IntCon_ICC_Faces_HAtt.Test.P400_mAmp(tt,:) = [NaN NaN NaN NaN 0];
            IntCon_ICC_Faces_HAtt.Retest.P400_mAmp(tt,:) = [NaN NaN NaN NaN 0];
        end
    end          

%% save the data and figure
    save('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/IntCon_ICC_Faces_HAtt.mat','IntCon_ICC_Faces_HAtt')
    saveas(Figure_Faces_ERPfeatures1,'/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_Figures_graphs/IntCon_ICCs_Faces_HAtt_ERPfeatures1.tif')
    saveas(Figure_Faces_ERPfeatures2,'/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_Figures_graphs/IntCon_ICCs_Faces_HAtt_ERPfeatures2.tif')

    
% clean up    
    clear variables
    
    
    



