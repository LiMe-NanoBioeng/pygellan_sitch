function [rowstart,rowend,colstart,colend]=frame_create_sub_image(row_cen,col_cen,radius,pad,r,c)
    rowstart=max([round(row_cen-pad*radius),1]);
    rowend=min([round(row_cen+pad*radius),r]);
    colstart=max([round(col_cen-pad*radius),1]);
    colend=min([round(col_cen+pad*radius),c]);
end