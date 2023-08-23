%% Jac Billington 30/11/2019
% Run to create n number of stimulus
% Saves output as basicresults
% [stimnumber rotation of tri, canny edge score, [hmax output EdgeScore
% spatial pooling range 1:8, scale blank blank].



clc
clear all

addpath('\color_hmax-master');

%%% options
saveimg=2; % 1=yes/ 2=no   % save a copy of the created image
disp=1; % 1=yes/ 2=no      % display it? 
logimg=2;  % 1=yes/ 2=no   % keep as no. 


imgload = imread('tree_bark.jpg');
imgload  = rgb2gray(imgload);
imgload = double(imgload );
sTri=200; %% size triangle
scal=[1 2 3 4 5 1 2 3 4 5 1 2 3 4 5 1 2 3 4 5 1 2 3 4 5 1 2 3 4 5 1 2 3 4 5]; 
scale=3; %% rescale moth? [1 2 3 4 5] 3=normal 1/2-lessthan  4/5 -morethan

savesmall=1;   %save only local region  2=save all - much larger file not needed for exp. 
number=1;      % number of stimulus to create.
basicresults=zeros(number,14);     %save information. 


for i=1:number;
%     scale=scal(i)
    %%%% create stimuli - save as jpeg if testing with humans   
    %%%% output:[3168×3921×i×2 double] 4thD 1=img/ 2=maskimg
    %%%% img is full imgS is condenced to save memory.
    
      out = create_stim(imgload,sTri, scale, saveimg, i,disp, logimg);
      
%     figure(1)
%     checkimg=out.imgs(:,:,i,1);
%     imshow(checkimg, []);
%     title('Original Image', 'FontSize', 15);
%     pause;
%     close all;

    %%%% work out edges with canny.
    edges = edge_find(out,i,savesmall);
    
    %%%% canny edge rating
    %%% output=[3168×3921×1×3 logical] mskedge, imageedge, diff.
    cannyout = canny_calc(out,i,savesmall);
    
    %%%% hmax rating
    hmaxout=hmax_calc(out,i,savesmall);  
    
%     save results
    basicresults(i,1)=i;
    basicresults(i,2)=out.textrot{i};
    basicresults(i,3)=cannyout.ratio{i};
    for k=4:11;
    basicresults(i,k)=hmaxout.hmean{k-3};
    end;
    basicresults(i,12)=scale;
    clear out cannyout hmaxout
end;






