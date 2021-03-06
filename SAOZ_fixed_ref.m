function SAOZ_fixed_ref(year,plot_path,fixed_rcd)
% this function use fixed RCD value to continue CF_GBS_main step 4 and the
% rest
% this function need read in a temp.mat file from "GBS" standard VCD
% process which contents SCD_S info. 
%year = '2016';
%plot_path_new = ['H:\work\Eureka\SAOZ\' year '\CF_450_550_minCI_fixref\'];
%plot_path_new = ['H:\work\Eureka\SAOZ\' year '\CF_450_550_fixref_RCD2p24\'];
%plot_path_new = ['E:\H\work\Eureka\SAOZ\' year '\CF_450_550_minCI_v2_fixref\'];
%plot_path_new = ['E:\H\work\Eureka\SAOZ\' year '\CF_450_550_minCI_v2_VCDcodev2_rerun_fixref_4p3\'];
plot_path_new = [plot_path(1:end-1) '_fixref\'];
mkdir(plot_path_new);
addpath('E:\F\Work\MatlabCode\');


%temp_file_nm = 'H:\work\Eureka\SAOZ\2011\CF_450_550_minCI\VCD\temp.mat';
%temp_file_nm = 'H:\work\Eureka\SAOZ\2015\CF_450_550\VCD\temp.mat';
%temp_file_nm = 'E:\H\work\Eureka\SAOZ\2015\CF_450_550_minCI_v2\temp.mat';
%temp_file_nm = ['E:\H\work\Eureka\SAOZ\' year '\CF_450_550_minCI_v2\temp.mat'];
%temp_file_nm = ['E:\H\work\Eureka\SAOZ\' year '\CF_450_550_minCI_v2_VCDcodev2_rerun\temp.mat'];

temp_file_nm = [plot_path 'temp.mat'];

%fixed_rcd = 1.6e19;% SAOZ V3 RCD
%fixed_rcd = 2.49e19;% averaged 2015 SAOZ RCD
%fixed_rcd = 2.24e19;% averaged 2015 SAOZ RCD (j day < 130)
%fixed_rcd = 4.4e19; % new SAOZ RCDs for years 2012-2017 (2016, day 101)
%fixed_rcd = 2.74e19; % SAOZ RCD for 2016 day 101, estimated by using GBS code (see daily RCD plots)
%fixed_rcd = 3.3e19; % SAOZ RCD for 2016 day 101, estimated by using GBS code (only afternoon RCD)
%fixed_rcd = 4.0e19; % guessed SAOZ RCD for 2016 day 101
%fixed_rcd = 4.3e19; % guessed SAOZ RCD for 2016 day 101

load(temp_file_nm);
cd(plot_path_new);
plot_path = plot_path_new;
CF_ind = true;
[vcd_outCF,vcd_out_vecCF] = SAOZ_VCD(year,CF_ind,temp_file_nm,fixed_rcd);
CF_ind = false;
[vcd_out,vcd_out_vec] = SAOZ_VCD(year,CF_ind,temp_file_nm,fixed_rcd);

plot_path = plot_path_new;
VCD.mean_vcd = vcd_out.mean_vcd_fixref;
VCD.std_vcd = vcd_out.std_vcd_fixref;
VCD_CF.mean_vcd = vcd_outCF.mean_vcd_fixref;
VCD_CF.std_vcd = vcd_outCF.std_vcd_fixref;
%%
% %% 4) vs Brewer
% try
%     fig_name = '';
%     ds_zs = 0;
%     gbs_brewer = pair_Brewer_GBS_daily_v2(brewer_all,ds_zs,VCD,save_fig,fig_name,plot_path);
%     
%     fig_name = '-CF';
%     ds_zs = 0;
%     gbscf_brewer = pair_Brewer_GBS_daily_v2(brewer_all,ds_zs,VCD_CF,save_fig,fig_name,plot_path);
%     
%     fig_name = '';
%     ds_zs = 1;
%     gbs_brewerzs = pair_Brewer_GBS_daily_v2(brewer_all,ds_zs,VCD,save_fig,fig_name,plot_path);
%     
%     fig_name = '-CF';
%     ds_zs = 1;
%     gbscf_brewerzs = pair_Brewer_GBS_daily_v2(brewer_all,ds_zs,VCD_CF,save_fig,fig_name,plot_path);
%     
%     
% catch
%     disp('Warning: step 4 failed');
%     save('temp.mat');
%     pause;
% end
% save('temp_fixref.mat');

    try
        % pair Brewer DS data with GBS/SAOZ data
        fig_name = '';
        ds_zs = 0;
        gbs_brewer = pair_Brewer_GBS_daily_v2(brewer_all,ds_zs,VCD,save_fig,fig_name,plot_path);
        
        % pair Brewer DS data with GBS/SAOZ cloud filtered data
        fig_name = '-CF';
        ds_zs = 0;
        gbscf_brewer = pair_Brewer_GBS_daily_v2(brewer_all,ds_zs,VCD_CF,save_fig,fig_name,plot_path);

        % pair Brewer ZS data with GBS/SAOZ data
        fig_name = '';
        ds_zs = 1;
        gbs_brewerzs = pair_Brewer_GBS_daily_v2(brewer_all,ds_zs,VCD,save_fig,fig_name,plot_path);

        % pair Brewer ZS data with GBS/SAOZ cloud filtered data
        fig_name = '-CF';
        ds_zs = 1;
        gbscf_brewerzs = pair_Brewer_GBS_daily_v2(brewer_all,ds_zs,VCD_CF,save_fig,fig_name,plot_path);
        
        disp('>>> Step 4-SAOZ-fix finished');
        
        
        cd(plot_path);
        save('temp.mat');

    catch
        disp('Warning: step 4-SAOZ-fix failed');
        cd(plot_path);
        save('temp.mat');
        email_notice('CODE STOPPED @ STEP-4-SAOZ-fix DUE TO ERROR');
        pause;
    end
%% 5) uncertaity estimation
% try
%     fig_title = 'BrewerDS vs GBS';
%     uncertainties_gbs_brewer = uncertainty_v2(gbs_brewer,save_fig,fig_title);
%     
%     fig_title = 'BrewerDS vs GBS-CF';
%     uncertainties_gbscf_brewer = uncertainty_v2(gbscf_brewer,save_fig,fig_title);
%     
%     fig_title = 'BrewerZS vs GBS';
%     uncertainties_gbs_brewerzs = uncertainty_v2(gbs_brewerzs,save_fig,fig_title);
%     
%     fig_title = 'BrewerZS vs GBS-CF';
%     uncertainties_gbscf_brewerzs = uncertainty_v2(gbscf_brewerzs,save_fig,fig_title);
%     
%     uncertainties = [uncertainties_gbs_brewer;uncertainties_gbscf_brewer;uncertainties_gbs_brewerzs;uncertainties_gbscf_brewerzs];
% catch
%     disp('Warning: step 5 failed');
%     save('temp_fixref.mat');
%     pause;
% end
    try

        cd([plot_path 'vs_Brewer'])

        % calculate uncertainties
        fig_title = 'BrewerDS vs GBS';
        gbs_vcd_type = 'normal';
        uncertainties_gbs_brewer = uncertainty_v3(gbs_brewer,gbs_vcd_type,save_fig,fig_title);

        fig_title = 'BrewerDS vs GBS(langley)';
        gbs_vcd_type = 'langley';
        uncertainties_gbsl_brewer = uncertainty_v3(gbs_brewer,gbs_vcd_type,save_fig,fig_title);

        fig_title = 'BrewerDS vs GBS-CF';
        gbs_vcd_type = 'normal';
        uncertainties_gbscf_brewer = uncertainty_v3(gbscf_brewer,gbs_vcd_type,save_fig,fig_title);

        fig_title = 'BrewerDS vs GBS-CF(langley)';
        gbs_vcd_type = 'langley';
        uncertainties_gbscfl_brewer = uncertainty_v3(gbscf_brewer,gbs_vcd_type,save_fig,fig_title);

        fig_title = 'BrewerZS vs GBS';
        gbs_vcd_type = 'normal';
        uncertainties_gbs_brewerzs = uncertainty_v3(gbs_brewerzs,gbs_vcd_type,save_fig,fig_title);

        fig_title = 'BrewerZS vs GBS(langley)';
        gbs_vcd_type = 'langley';
        uncertainties_gbsl_brewerzs = uncertainty_v3(gbs_brewerzs,gbs_vcd_type,save_fig,fig_title);

        fig_title = 'BrewerZS vs GBS-CF';
        gbs_vcd_type = 'normal';
        uncertainties_gbscf_brewerzs = uncertainty_v3(gbscf_brewerzs,gbs_vcd_type,save_fig,fig_title);

        fig_title = 'BrewerZS vs GBS-CF(langley)';
        gbs_vcd_type = 'langley';
        uncertainties_gbscfl_brewerzs = uncertainty_v3(gbscf_brewerzs,gbs_vcd_type,save_fig,fig_title);

        uncertainties = [uncertainties_gbs_brewer;uncertainties_gbscf_brewer;uncertainties_gbs_brewerzs;uncertainties_gbscf_brewerzs;uncertainties_gbsl_brewer;uncertainties_gbscfl_brewer;uncertainties_gbsl_brewerzs;uncertainties_gbscfl_brewerzs];
        uncertainties.Properties.RowNames = {'gbs_brewer','gbscf_brewer','gbs_brewerzs','gbscf_brewerzs','gbsl_brewer','gbscfl_brewer','gbsl_brewerzs','gbscfl_brewerzs'};
        
        disp('>>> Step 5-SAOZ-fix finished');
        
        cd(plot_path);
        save('temp.mat');
        
    catch
        disp('Warning: step 5-SAOZ-fix failed');
        cd(plot_path);
        save('temp.mat');
        email_notice('CODE STOPPED @ STEP-5-SAOZ-fix DUE TO ERROR');
        pause;
    end
%% 6) save data
% gbs = data;
% brewer = brewer_all;
% 
% save('gbs_brewer.mat','gbs','brewer','EWS','gbs_brewer','gbscf_brewer','gbs_brewerzs','gbscf_brewerzs','VCD','VCD_CF','list_HQ_day','qdoas_filt','rcd_S','rcd_SCF','year','uncertainties');
gbs = data;
brewer = brewer_all;
cd(plot_path);
cd vs_Brewer
save('gbs_brewer.mat','gbs','brewer','EWS','gbs_brewer','gbscf_brewer','gbs_brewerzs','gbscf_brewerzs','VCD','VCD_CF','list_HQ_day','qdoas_filt','rcd_S','rcd_SCF','year','uncertainties');
try
    email_notice('CODE (SAOZ-fix-ref) SUCCESSFULLY FINISHED!');
catch
    disp('CAN NOT SEND EMAIL, PLS CHECK SETTINGS IN "email_notice".');
end
close all;
