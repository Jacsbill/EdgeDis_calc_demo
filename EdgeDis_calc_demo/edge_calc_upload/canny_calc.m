function cannyout = canny_calc(out,i,savesmall)
if savesmall==2;
    maskedge=edge(out.imgs{i}(:,:,2),'canny');
    imgedge=edge(out.imgs{i}(:,:,1),'canny');
else
    maskedge=edge(out.imgsS{i}(:,:,2),'canny');
    imgedge=edge(out.imgsS{i}(:,:,1),'canny');
end
edgediff=maskedge+imgedge;

[xm ym]=find(maskedge==1);
[xi yi]=find(edgediff==2);

cannyout.ratio{i}=1/(length(xi)/length(xm));

cannyout.imgs{i}(:,:,1)=maskedge;
cannyout.imgs{i}(:,:,2)=imgedge;
cannyout.imgs{i}(:,:,3)=edgediff;


end


