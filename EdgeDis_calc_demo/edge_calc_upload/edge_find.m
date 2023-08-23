function edges = edge_find(out,i,savesmall)
    if savesmall==2;
    maskedge=edge(out.imgs{i}(:,:,2),'canny');
    edges.imgs{i}(:,:,1)=maskedge;
    else
    maskedge=edge(out.imgsS{i}(:,:,2),'canny');
    edges.imgs{i}(:,:,1)=maskedge;
end
    
