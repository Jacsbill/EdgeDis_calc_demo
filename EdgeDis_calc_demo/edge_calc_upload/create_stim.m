function [out] = create_stim(imgload,sTri, scale, saveimg,i,disp,logimg);
 
addpath('C:\Program Files\MATLAB\R2019b\toolbox\geom2d\polygons2d');

%%%% load image and find sizes
img=imgload;
[ys xs]=size(imgload);
R=round(sTri*1.3);
ySmax=ys-R;
xSmax=xs-R;
ySmin=R;
xSmin=R;



if logimg==1;
 imgLog = log(img+1);  %Add 1 to avoid taking log of zero.
 imgLogNrm = mat2gray(imgLog);
 imgLogNrm = 1.0751e+04 * imgLogNrm;
 imgLogNrmR=reshape(imgLogNrm,[ys*xs,1]);
 imgLogNrmY50 = prctile(imgLogNrmR,50);
 imgLogNrmY25 = prctile(imgLogNrmR,25);
 imgLogNrmY75 =prctile(imgLogNrmR,75);
 imgLogNrmT=imgLogNrm;
 imgLogNrmT(imgLogNrm<=imgLogNrmY50)=imgLogNrmY25;
 imgLogNrmT(imgLogNrm>imgLogNrmY50)=imgLogNrmY75;
end

%%% find the percentiles for the threshold image
imgR=reshape(imgload,[ys*xs,1]);
imgY50 = prctile(imgR,50);
imgY25 = prctile(imgR,25);
imgY75 =prctile(imgR,75);

%%% create threshold image
imgT=img;
imgT(img<=imgY50)=imgY25;
imgT(img>imgY50)=imgY75;


%%%% not sure what this is. 
cropy=randi([10,round(ys/2.5)]);
cropx=randi([10,round(xs/2.5)]);

%%%% rescale image %%% needs work
scales=[0.5 0.666 1 1.5 2];
if scale~=3;
     scale2=scales(scale);
     if scale2>1;
     F = griddedInterpolant(double(imgT));
     [sy,sx,sz] = size(imgT);
     yq = (0:1/scale2:sy)';
     xq = (0:1/scale2:sx)';    
     imgTF2 =uint8(F({yq,xq})); 
     imgTF3=imcrop(imgTF2, [1 1 ys-1 xs-1]);
     else;
     imgTF=imresize(imgT, scale2);
     [imgTFys imgTFxs]=size(imgTF);
     imgTF3=padarray(imgTF, [round((ys-imgTFys)/2) round((xs-imgTFxs)/2)-1 ] , 0, 'both');
     end
     imgT=imgTF3;
end

%%%% select location of tri select
xsample=randi([xSmin, xSmax]);
ysample=randi([ySmin, ySmax]);

xsampleS=randi([xSmin, xSmax]);
ysampleS=randi([ySmin, ySmax]);

%%%% sort out the rotated image
%%%% this pads, rotates and then crops to create new image 
rotang=datasample([0,45,90,135,225,270,305],1);
% rotang=datasample([180],1);
if  ysample>(ys/2) && xsample>(xs/2);
    imgTP=padarray(imgT, [-1*(ys-(2*ysample)) -1*(xs-(2*xsample))] , 0, 'pre');
    newmiddle=round(size(imgTP)/2);
    imgTR=imrotate(imgTP,rotang,'crop');
elseif ysample<(ys/2) && xsample<(xs/2);
    imgTP=padarray(imgT, [(ys-(2*ysample)) (xs-(2*xsample))] , 0, 'post');
    newmiddle=round(size(imgTP)/2);
    imgTR=imrotate(imgTP,rotang,'crop');
elseif ysample<(ys/2) && xsample>(xs/2);
%    imgTP=padarray(imgT, [(ys-(2*ysample)) -1*(xs-(2*xsample))] , 0, 'post');
     imgTP=padarray(imgT, [0 -1*(xs-(2*xsample))] , 0, 'pre');
    imgTP=padarray(imgTP, [(ys-(2*ysample)) 0 ] , 0, 'post');
   newmiddle=round(size(imgTP)/2);
    imgTR=imrotate(imgTP,rotang,'crop');
else 
%    imgTP=padarray(imgT, [-1*(ys-(2*ysample)) (xs-(2*xsample))] , 0, 'post');
      imgTP=padarray(imgT, [0 1*(xs-(2*xsample))] , 0, 'post');
    imgTP=padarray(imgTP, [-1*(ys-(2*ysample)) 0 ] , 0, 'pre');
   newmiddle=round(size(imgTP)/2);
    imgTR=imrotate(imgTP,rotang,'crop');
end

ysmpold=ysample;
xsmpold=xsample;
ysample=newmiddle(1);
xsample=newmiddle(2);
%%%% make some triangles
radius=sTri;
% angle=randi([1,279]);
ag=datasample([0,45,90,135,225,270,305],1);
ag=datasample([140 320],1);
angle=ag* pi/180;
angle2=(ag+80)* pi/180;

cx1= radius*sin(angle) +xsample; cy1= radius*cos(angle) + ysample;
cx2= radius*sin(angle2) +xsample; cy2= radius*cos(angle2) + ysample;



x = round([xsample cx1 cx2]);
y = round([ysample cy1 cy2]);

xS=xsample-xsampleS;
yS=ysample-ysampleS;

xshift = round([xsample-xS cx1-xS cx2-xS]);
yshift = round([ysample-yS cy1-yS cy2-yS]);

% if scale>=3;
% if xsample<sTri & ysample<sTri; 
%     shift=randi([round(sTri/4),sTri/2]);
% elseif xsample>sTri & ysample>sTri; 
%      shift=randi([-sTri/2,round(sTri/4)]);
% else
%     shift=randi([-sTri/2,sTri/2]);
% end
% else
%      shift=randi([-sTri*2,sTri*2]);
% end
%     



%%% find centre to cut and save a bit of memory space.
xx= [xshift(1) yshift(1); xshift(2) yshift(2); xshift(3) yshift(3)];
meanx=round(mean(xshift));
meany=round(mean(yshift));
R2=round(sTri*0.9);



bw = poly2mask(x,y,ys,xs);
bwshift = poly2mask(xshift,yshift,ys,xs);
  

imgF=img;
[xeshift yeshift]=find(bwshift==1);
[xe ye]=find(bw==1);
for rp=1:length(xe);
imgF(xeshift(rp), yeshift(rp))=imgTR(xe(rp), ye(rp));
end;
% 

% 
out.imgs{i}(:,:,1)=imgF;
out.imgs{i}(:,:,2)=bwshift;
out.imgsS{i}(:,:,1)=imgF(meany-R2:meany+R2,meanx-R2:meanx+R2);
out.imgsS{i}(:,:,2)=bwshift(meany-R2:meany+R2,meanx-R2:meanx+R2);
out.scale{i}=scale;
out.textrot{i}=rotang;
out.samples{i}(:,1)=[ysample, xsample];
out.samples{i}(:,2)=[ysample-yS, xsample-xS];
out.samples{i}(:,3)=[ysmpold, xsmpold];

if saveimg==1;
    file_name = sprintf('img_I%d_S%d_R%d_RA%d_Y%d_X%d_A%d.jpg',i,scale,rotang,ag,ysample,xsample,angle);
    imwrite(uint8(imgF),file_name);
end

if disp==1;
    figure(1)
    subplot(2,3,1);
    imshow(img, []);
    title('Original Image', 'FontSize', 15);
    axis on;
    if logimg==1;
        subplot(2,3,6);
        imshow(imgLogNrm, []);
        axis on;
        title('Log Normalised Image', 'FontSize', 15);
    end
    subplot(2,3,2);
    imshow(uint8(imgT));
    axis on;
    title('Original Image Thesh', 'FontSize', 15);
    subplot(2,3,3);
    imshow(uint8(imgTR));
    axis on;
    title('Rotated image', 'FontSize', 15);
    subplot(2,3,4);
    imshow(bw);
    title('Mask', 'FontSize', 15);
    subplot(2,3,5);
    imshow(bwshift);
    title('Mask Shift', 'FontSize', 15);
    subplot(2,3,6);
    h=imshow(uint8(imgF));
    title('Final', 'FontSize', 15);
    
end;
end

