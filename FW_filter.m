%FW Filter
% need spm,fmri_banpass_filter and fmri_highpass_filter and filtfilt.m 
function FW_filter(path,subname,sesname,modname,cH,cL,c_task)

path=path;
sespath= ([path '/' subname '/' sesname]);
regresspath1=dir([path '/' subname '/' sesname '/' modname '/PP/task*' ])
%regresspath1=dir([path '/' subname '/' sesname '/' modname '/PP/task*' ]);

fprintf(['regresspath1=' path '/' subname '/' sesname '/' modname '/PP/task*'])
%regresspath1=dir('/Users/aazeez/Downloads/testAMK/PP/task*')

%space(1).name= ['MNI152NLin2009cAsym'];space(2).name=['T1w'];
%for SPACE =1:length(space)
    
 %   spacename=([space(SPACE).name])
    
    for SF=1:length(regresspath1)
        SCANFILE=regresspath1(SF).name
        task = extractBefore(regresspath1(SF).name,"_sub");
        
        regresspath=([path '/' subname '/' sesname '/' modname '/PP/' SCANFILE]);
        %regresspath=(['/Users/aazeez/Downloads/testAMK/PP/' SCANFILE])
        
        cd(regresspath)
        %FP_out_reg='reg_sm_dspk_sk_sub-AMKTest_ses-baseline_task-resting1mux6scanheavy_space-MNI152NLin2009cAsym_desc-preproc_bold.nii';
        %FP_out_reg=(['reg_sm_dspk_sk_' subname '_' sesname '_' task '_space-' spacename '_desc-preproc_bold.nii' ])
        FP_out_REG=  dir(['reg_*']);
        for  n=1:length(FP_out_REG)
            FP_out_reg=FP_out_REG(n).name
            %FP_out_reg='sm_dspk_sk_sub-AMKTest_ses-baseline_task-Resting1NewHB6scan_space-MNI152NLin2009cAsym_desc-preproc_bold.nii';
            %pathreg='/Users/aazeez/Downloads/testAMK';
            delete(['filt*']);

            clear  v_pair y_pair v_image y_image mean_image  y_mean_image imp_mask  y_image_regressed_filtered  TimPts

            v_pair = spm_vol([regresspath '/' FP_out_reg]);
            y_pair = spm_read_vols(v_pair);
            image_dim = v_pair.dim;
            [TimPts,t1]=size(v_pair);
            
            
            for imagei = 1:TimPts % number of timepoints
                v_image = spm_vol([regresspath '/' FP_out_reg ',' num2str(imagei)]);
                y_image(:,:,:,imagei) = spm_read_vols(v_image);
            end
            
            
            TR= load(['REPTIME_' task]);TR=TR.TR;
            sf = 1/TR;
            %cH = 0.1;
            %cL = 0.01;
            %
            fprintf(['TR=' num2str(TR)])
             fprintf(['sf=' num2str(sf)])
             fprintf(['cL=' num2str(cL)])
             fprintf(['cH=' num2str(cH)])
            
            
            mean_image = mean(y_image,4);   % calculate mask
            y_mean_image = mean_image(:);
            imp_mask = mean(y_mean_image(find(y_mean_image>(mean(y_mean_image)/8))))*.3;
            
            RST=["Rest", "rest", "REST"];
            RST1=find(contains(SCANFILE,RST));
            if RST1==1
                
                fprintf('This is a Rest Scan Bandpass{0.01-0.1} filter will be applied \n')
                for vi = 1:image_dim(1)
                    fprintf('%d ',vi)
                    for vj = 1:image_dim(2)
                        for vk = 1:image_dim(3)
                            if y_image(vi,vj,vk)<imp_mask
                                %  y_image_regressed(vi,vj,vk,:) = zeros(1,1,1,TimPts);
                                y_image_regressed_filtered(vi,vj,vk,:) = zeros(1,1,1,TimPts);
                            else
                                %warning('off','all')
                                %warning
                                % b = zscore([ TOTALREG]); %T
                                %b=zscore([CSF_ALL WM_ALL MOT_ALL GS_ALL]);
                                %   [b,bint,y_image_regressed(vi,vj,vk,:)] = regress(shiftdim(y_image(vi,vj,vk,:),3),[b ones(TimPts,1)]);
                                y_image_regressed_filtered(vi,vj,vk,:) = fmri_banpass_filter(squeeze(y_image(vi,vj,vk,:)),sf,cH,cL);
                            end
                        end
                        
                    end
                end
            else
                
                fprintf('This is a Task Scan Highpass{0.01} filter will be applied \n')
                for vi = 1:image_dim(1)
                    fprintf('%d ',vi)
                    for vj = 1:image_dim(2)
                        for vk = 1:image_dim(3)
                            if y_image(vi,vj,vk)<imp_mask
                                %  y_image_regressed(vi,vj,vk,:) = zeros(1,1,1,TimPts);
                                y_image_regressed_filtered(vi,vj,vk,:) = zeros(1,1,1,TimPts);
                            else
                                %warning('off','all')
                                %warning
                                % b = zscore([ TOTALREG]); %T
                                %b=zscore([CSF_ALL WM_ALL MOT_ALL GS_ALL]);
                                %   [b,bint,y_image_regressed(vi,vj,vk,:)] = regress(shiftdim(y_image(vi,vj,vk,:),3),[b ones(TimPts,1)]);
                                    y_image_regressed_filtered(vi,vj,vk,:) = fmri_highpass_filter(squeeze(y_image(vi,vj,vk,:)),sf,c_task);
                            end
                        end
                        
                    end
                end
            end
            
            fprintf(' done! \n')
            %varname=([subjfolder(subji).name '_WS'])
            %save(varname);
            % cd(regresspath)
            fprintf('saving image...\n')
            V.dim   = v_pair.dim;
            V.dt    = v_pair.dt;
            V.mat   = v_pair.mat;
            V.pinfo = v_pair.pinfo;
            for imagei = 1:TimPts
                V.n=[imagei 1];
                % V.fname = [regresspath '/filtreg_sk_' subname '_' sesname '_task-resting1muxscan_space-' spacename '_desc-preproc_bold.nii'];
                V.fname =  [ regresspath '/filt' FP_out_reg];
                V = spm_write_vol(V,y_image_regressed_filtered(:,:,:,imagei)+mean_image);
            end
        end
    end
%end
