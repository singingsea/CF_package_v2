function uncertainties = uncertainty_v4(gbs_brewer,gbs_vcd_type,save_fig,fig_title)

%% input
%save_fig = 1;
%fig_file = 'H:\work\Eureka\GBS\CI\2011\UTGBS\vs_Brewer\'
%mkdir(fig_file);
%load('H:\work\Eureka\GBS\Validation_ACE_OSIRIS\formated_data\gbs_and_saoz_paried.mat');
%load('H:\work\Eureka\GBS\CI\2011\UTGBS\vs_Brewer\matlab.mat');
DU=2.69e16;


data = gbs_brewer;
if ~istable(data)
    disp('Can not estimate uncertainties: No Brewer measurements found conincident with GBS measurements!');
    %uncertainties = 0;
    uncertainties = table;
    uncertainties.u_GBS = -9999;
    uncertainties.pu_GBS = -9999;
    uncertainties.u_Brewer = -9999;
    uncertainties.pu_Brewer = -9999;
    uncertainties.u_X = -9999;
    uncertainties.pu_X = -9999;
else
        %% M1 and M2 subtract daily mean, to get only high frequency part
    for year = min(str2num(data.year)):1:max(str2num(data.year))
        for day = min(data.day):1:max(data.day)
            TF = (str2num(data.year) == year) & (data.day == day);
            if sum(TF) == 1
                data(TF,:) = []; % we only keep days have both am. pm. values
            elseif sum(TF) == 2
                data.daily_gbs_mean(TF,:) = mean(data.mean_vcd(TF,:));
                data.daily_gbs_mean_langley(TF,:) = mean(data.langley_vcd(TF,:));
                data.daily_brewer_mean(TF,:) = mean(data.mean_ColumnO3(TF,:));
            end
        end
        
    
    end
        
    %%
    if strcmp(gbs_vcd_type,'normal')
        M1 = (data.mean_vcd - data.daily_gbs_mean)./DU; % GBS TCO using our normal routine (RCD -> VCDs -> mean VCD)
    elseif strcmp(gbs_vcd_type,'langley')
        M1 = (data.langley_vcd - data.daily_gbs_mean_langley)./DU; % GBS TCO using slope of langley fit as VCD
    end
    M2 = data.mean_ColumnO3 - data.daily_brewer_mean; % brewer TCO

    %fig_title = 'Brewer vs GBS';
    
    %% filters: 
    %filter 1 : we will filter any measuremnts with abs(TCO - daily_mean) > 100 DU
    TF1 = abs(M1) > 100;
    TF2 = abs(M2) > 100;
    TF = TF1 | TF2;
    M1(TF,:) = [];
    M2(TF,:) = [];
    %filter 2 : we will filter TCO in table as NaN
    TF1 = isnan(M1);
    TF2 = isnan(M2);
    TF = TF1 | TF2;
    M1(TF,:) = [];
    M2(TF,:) = [];
    
    

    %%
    delta_M = M1 - M2;
    
    var_M1 = var(M1);
    var_M2 = var(M2);
    var_delta_M = var(delta_M);
    
    var_X = 0.5*(var_M1 + var_M2 - var_delta_M);
    var_e1 = 0.5*(var_M1 - var_M2 + var_delta_M);
    var_e2 = 0.5*(var_M2 - var_M1 + var_delta_M);
    
    u_X = (var_X)^0.5;
    u_e1 = (var_e1)^0.5;
    u_e2 = (var_e2)^0.5;
    pu_X = u_X./mean(data.mean_ColumnO3)*100;
    pu_e1 = u_e1./mean( data.mean_ColumnO3)*100;
    pu_e2 = u_e2./mean( data.mean_ColumnO3)*100;
    
    %% output
    uncertainties = table;
    uncertainties.u_GBS = u_e1;
    uncertainties.pu_GBS = pu_e1;
    uncertainties.u_Brewer = u_e2;
    uncertainties.pu_Brewer = pu_e2;
    uncertainties.u_X = u_X;
    uncertainties.pu_X = pu_X;
    
    %linear_fits(M1,M2);
    linear_fits(M2,M1);
    hold all;
    %c = g1.T20(~TF,:);
    c = data.fd(~TF,:);
    %scatter(M1,M2,20,c,'filled');
    scatter(M2,M1,20,c,'filled');
    %xlim([200 550]);
    %ylim([200 550]);
    textbp(['u_G_B_S = ' num2str(u_e1) '; ' num2str(pu_e1) '%']);
    textbp(['u_B_r_e_w_e_r = ' num2str(u_e2) '; ' num2str(pu_e2) '%']);
    textbp(['X = ' num2str(u_X) '; ' num2str(pu_X) '%']);
    N = size(M1);
    textbp(['N = ' num2str(N(1))]);
    xlabel('Brewer ozone [DU]');
    ylabel('GBS ozone [DU]');
    title(fig_title);
    print_setting(1,save_fig,[ fig_title '_scatter']);
    %print_setting(1,save_fig,'Brewer_vs_SAOZ_ozone_scatter_filtered');
    
    
    figure;
    h1 = histogram(M1);
    hold on
    h2 = histogram(M2);
    h1.Normalization = 'probability';
    h1.BinWidth = 2;
    h2.Normalization = 'probability';
    h2.BinWidth = 2;
    %xlim([200 550]);
    xlabel('TCO [DU]');
    ylabel('f');
    title(fig_title);
    print_setting(1,save_fig,[ fig_title '_hist']);
    %print_setting(1,save_fig,'Brewer_vs_SAOZ_ozone_hist_filtered');
    
end