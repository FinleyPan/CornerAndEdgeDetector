function [corners,response] = goodCorners(input,blockSize,qualityLevel,minDist,useHarris,kappa)
% detect salient corners and return corresponding response intensities.
%% params:
%@input: image of single channel or three channels.
%@blockSize: window size for computing a derivative covariation matrix.
%@qualityLevel: the lower limit response for qualifying as a corner
%@minDist: the minumum distance between two good corners.
%@useHarris: calculation response by Harris formula or Shi-Tomasi formula.
%@kappa: parameter used for Harris formula.
%%
corners=[];response=[];
Img = RGB2Gray(input);
kSize = 3; %size of sobel
scale_sob = 1/(2^(kSize -1)*255);
rows = size(Img,1);
cols = size(Img,2);

myCov = zeros(rows,cols,3);
%solve for intensity derivative for each pixel with sobel.
Dx = sobel(Img,kSize,'x',scale_sob);
Dy = sobel(Img,kSize,'y',scale_sob);

myCov(:,:,1) = Dx .* Dx;
myCov(:,:,2) = Dx .* Dy;
myCov(:,:,3) = Dy .* Dy;

myCov(:,:,1) = boxSmooth(myCov(:,:,1),blockSize,true);
myCov(:,:,2) = boxSmooth(myCov(:,:,2),blockSize,true);
myCov(:,:,3) = boxSmooth(myCov(:,:,3),blockSize,true);

if(~useHarris)
    %% calculate minimux eigenvalues
    A = 0.5*(myCov(:,:,1)+myCov(:,:,3));
    B = myCov(:,:,2);
    C = 0.5*(myCov(:,:,1)-myCov(:,:,3));
    cornerResponse = A-sqrt(B.*B+C.*C);
else
    %% Harris response
    A=myCov(:,:,1) .* myCov(:,:,3);
    B=myCov(:,:,2) .^2;
    C=myCov(:,:,1) + myCov(:,:,3);
    cornerResponse = A-B-kappa*(C.*C);
end
% kick outs corners whose response are poor
thresholdResponse = threshold(cornerResponse,qualityLevel*max(cornerResponse(:)));

%% non-maximum suppression
temp = dilate(thresholdResponse);
%find indexes of corners whose responses are local maximum in a 3*3 neighborhood
NMS_Index = int32(find( (temp==thresholdResponse) & (thresholdResponse~=0)));
%leave out corners at edges
NMS_EdgeRemvoal_Index = int32(find(mod(NMS_Index,rows)~=0 & mod(NMS_Index,rows)~=1 ...
&idivide(NMS_Index,rows)~=0 & idivide(NMS_Index,rows)~=cols-1));
thresholdResponse = thresholdResponse(:);
myTempCornersResponse = thresholdResponse(NMS_Index(NMS_EdgeRemvoal_Index));
myTempLocYX = zeros(size(myTempCornersResponse,1),2);
%convert linear indices back to matrix indices
myTempLocYX(:,1) = mod(NMS_Index(NMS_EdgeRemvoal_Index),rows);
myTempLocYX(:,2) = idivide(NMS_Index(NMS_EdgeRemvoal_Index),rows)+1;
%sort according to descending responses
[myTempCornersResponse,order] = sort(myTempCornersResponse,'descend');
%Y: row in which pixel resides.
%X: column in which pixel resides.
%R: corresponding response intensity.
%Gy: vertical grid coordinate of the pixel.
%Gx: horizontal grid coordinate of the pixel.
tempYXRGyGx = zeros(size(myTempCornersResponse,1),5);
tempYXRGyGx(:,1:3) = [myTempLocYX(order,:) myTempCornersResponse];

%% remove corners for which there exist stronger corners at a distance less than minDist
% partion images into grids
if minDist >=1     
    cell_size = int32(minDist);
% consider potential anomaly grids near right and bottom edges.
    grid_width = idivide(cols+cell_size-1,cell_size);
    grid_height = idivide(rows+cell_size-1,cell_size);
    
    Grids = cell(grid_height,grid_width);
% put corners into corresponding grids.    
    for i=1:size(tempYXRGyGx,1)
        gridY = idivide(tempYXRGyGx(i,1)-1,cell_size)+1;
        gridX = idivide(tempYXRGyGx(i,2)-1,cell_size)+1;
        tempYXRGyGx(i,4)=double(gridY);tempYXRGyGx(i,5)=double(gridX);
        Grids{gridY,gridX}= [Grids{gridY,gridX};
                             tempYXRGyGx(i,1:3)];
    end    
    
    goodCorners_flags = ones(size(tempYXRGyGx,1),1);
    for ind = 1:size(tempYXRGyGx,1) 
        %boundary check.
        gridY = tempYXRGyGx(ind,4);
        gridX = tempYXRGyGx(ind,5);
        topGridY = max(gridY -1,1);
        bottomGridY = min(gridY+1,double(grid_height));
        leftGridX = max(gridX-1,1);
        rightGridX = min(gridX+1,double(grid_width));
        jumpOut = false;
        %traverse neighborhoods of grids,
        for gy = topGridY:bottomGridY
            for gx = leftGridX:rightGridX
                 if Grids{gy,gx}
                     for i =1: size(Grids{gy,gx},1)
                        dist = norm(Grids{gy,gx}(i,1:2)-tempYXRGyGx(ind,1:2));
                        if Grids{gy,gx}(i,3)>tempYXRGyGx(ind,3) && ...
                           dist>0 && dist<minDist
                           goodCorners_flags(ind) = 0;
                           %remove this corner in Grids
                           remove_Ind = find(Grids{gridY,...
                               gridX}(:,3)==tempYXRGyGx(ind,3));
                           Grids{gridY,gridX}(remove_Ind,:)=[];
                           jumpOut = true;
                           break;
                        end
                     end
                    if jumpOut
                        break;
                    end
                 end
            end
            if jumpOut
                break;
            end
        end        
    end
    corners = tempYXRGyGx(find(goodCorners_flags==1),2:-1:1);      
    response = tempYXRGyGx(find(goodCorners_flags==1),3);
% only reserve one corner with intensest response in each grid.
%     for i=1:grid_height
%         for j=1:grid_width
%             if Grids{i,j}                
%                 [~,order] = sort(Grids{i,j}(:,3),'descend');                
%                 Grids{i,j} = Grids{i,j}(order(1),:); 
%                 GridsResponse(i,j) = Grids{i,j}(1,3);                
%             end
%         end
%     end
        
end
end

