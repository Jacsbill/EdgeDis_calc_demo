function hmaxout=hmax_calc(out,i,savesmall)
%% higher hmax= more edge distruption
%% Jac Billington 30/11/2019


if savesmall==2;
    stim=out.imgs{i}(:,:,1);
    stimM=out.imgs{i}(:,:,2);
else;
    stim=out.imgsS{i}(:,:,1);
    stimM=out.imgsS{i}(:,:,2);
end;

% fprintf('initializing S1 gabor filters\n');

% rot = [90 -45 0 45]; % 4 orientations for gabor filters
rot = [0 -30 -60 90 60 30]; % 4 orientations for gabor filters
RFsizes      = linspace(5,37,17);        % receptive field sizes
div          = linspace(4,3.2,17);    % tuning parameters for the filters' "tightness"
[fSiz,filters,c1OL,numSimpleFilters, lambda, sigma, G] = init_gabor_jb(rot, RFsizes, div)

%%%% these should be orthognal to above +number equivilants. 
 rotO = [90 60 30 0 -30 -60]; 
 rotN = [1 2 3 4 5 6];
 rotON = [4 5 6 1 2 3];
 
% fprintf('initializing C1 parameters\n')

c1ScaleSS = linspace(1,17,9)% defining 8 scale bands
c1SpaceSS = linspace(8,22,8) ; % defining spatial pooling range for each scale band (larger makes broader) length c1SpaceSS-1
[c1s,s1s]=C1_jb(stim, filters, fSiz, c1SpaceSS, c1ScaleSS, c1OL,'yes');
[c1m,s1m]=C1_jb(stimM, filters, fSiz, c1SpaceSS, c1ScaleSS, c1OL,'yes');

sizes=zeros(length(c1SpaceSS),2);
for ii =1:length(c1SpaceSS);
    [cs1 cs2 cs3]=  size(c1m{ii});
    sizes(ii,1)=cs1;
    sizes(ii,2)=cs2;
end


%%%%% create a log of the peak orientations on a plain image.
c1moris={};
for ii =1:length(c1SpaceSS);
    for iix=1:sizes(ii,1);
        for iiy=1:sizes(ii,2);
            getpix=max(c1m{ii}(iix, iiy,:));
            if getpix>0.1;
            getpixloc=find(c1m{ii}(iix, iiy,:)==getpix);
                if length(getpixloc)>1;
                   c1moris{ii}(iix, iiy,1)=getpix;
                   c1moris{ii}(iix, iiy,2)=getpixloc(1);
                   c1moris{ii}(iix, iiy,3)=getpixloc(2);
                   c1moris{ii}(iix, iiy,4)=1;
                else
                   c1moris{ii}(iix, iiy,1)=getpix;
                   c1moris{ii}(iix, iiy,2)=getpixloc;
                   c1moris{ii}(iix, iiy,4)=0;
                end
            else
               c1moris{ii}(iix, iiy,1)=0;
               c1moris{ii}(iix, iiy,2)=0;

            end
        end 
    end
% plotting values demo for students.
%    figure(1)
%    subplot(2,4,ii);
%    imagesc(c1moris{ii}(:,:,2));
%    figure(2)
%    subplot(2,4,ii);
%    imshow(c1moris{ii}(:,:,4));
  
end

%%%%% create a log of the peak orientations on a triangle image. don't
%%%%% leave this on, not needed for calculation. Just to look at for
%%%%% student demo.
% c1soris={};
% for ii =1:length(c1SpaceSS);
%     for iix=1:sizes(ii,1);
%         for iiy=1:sizes(ii,2);
%             getpix=max(c1s{ii}(iix, iiy,:));
%             if getpix>0.1;
%             getpixloc=find(c1s{ii}(iix, iiy,:)==getpix);
%                 if length(getpixloc)>1;
%                    c1soris{ii}(iix, iiy,1)=getpix;
%                    c1soris{ii}(iix, iiy,2)=getpixloc(1);
%                    c1soris{ii}(iix, iiy,3)=getpixloc(2);
%                    c1soris{ii}(iix, iiy,4)=1;
%                 else
%                    c1soris{ii}(iix, iiy,1)=getpix;
%                    c1soris{ii}(iix, iiy,2)=getpixloc;
%                    c1soris{ii}(iix, iiy,4)=0;
%                 end
%             else
%                c1soris{ii}(iix, iiy,1)=0;
%                c1soris{ii}(iix, iiy,2)=0;
% 
%             end
%         end 
%     end
%    figure(3)
%    subplot(2,4,ii);
%    imagesc(c1soris{ii}(:,:,2));
%    figure(4)
%    subplot(2,4,ii);
%    imshow(c1soris{ii}(:,:,4));
%   
% end



%%%% hmaxcalc
hmaxcalc={};

for ii =1:length(c1SpaceSS);
    for iix=1:sizes(ii,1);
        for iiy=1:sizes(ii,2);
            getori=c1moris{ii}(iix, iiy,2); %% get parallel orientation
                if getori>0;
                getoriorth=rotON(getori); %% get othoganal orientation
                hmaxcalc{ii}(iix, iiy,1)=c1s{ii}(iix, iiy,getoriorth)/(c1s{ii}(iix, iiy,getori)+c1s{ii}(iix, iiy,getoriorth));
                maskhmaxcalc{ii}(iix, iiy,1)=c1m{ii}(iix, iiy,getoriorth)/(c1m{ii}(iix, iiy,getori)+c1m{ii}(iix, iiy,getoriorth));  %%% look at distruption in mask if you want
                else
                hmaxcalc{ii}(iix, iiy,1)=0;
                maskhmaxcalc{ii}(iix, iiy,1)=0;
              
                end
         end
    end 
       meanhmax{ii}=mean(nonzeros(mean(nonzeros(hmaxcalc{ii}))));
        nhamx{ii}=nnz(nonzeros(hmaxcalc{ii}));
    
% 
%    figure(5)
%    subplot(2,4,ii);
%    imagesc(hmaxcalc{ii}(:,:,1));
%    figure(6)
%    subplot(2,4,ii);
%    imshow(maskhmaxcalc{ii}(:,:,1));
end
    hmaxout.c1s=c1s;
    hmaxout.c1m=c1m;
    hmaxout.maskori=c1moris;
    hmaxout.stimdisrupt=hmaxcalc;
    hmaxout.hmean=meanhmax;
    hmaxout.hmeann=nhamx;

end

    