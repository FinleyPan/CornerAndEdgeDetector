function [ goodCorners ] = cornerSubPix( Img,corners,winSize,maxIters,epsilon )
% refine corners' locations with subpixel accuracy
%% params:
%@Img: grayscale image within which corners are detected.
%@corners: crude corners to be refined.
%@winSize: half size of the search window.
%@maxIters: maximum iteration number.
%@epsilon: threshold within which corner locations are considered to be converged.
%%
    imgHeight = size(Img,1);
    imgWidth = size(Img,2);
    
    win_w = 2*winSize(1)+1;
    win_h = 2*winSize(2)+1;
    
    %get number of corners.
    Ncorners = size(corners,1);
    
    if imgHeight<2*winSize(2)+5 || imgWidth <2*winSize(1)+5            
        fprintf('Error: improper window size!\n');
        goodCorners=[];
        return;
    elseif Ncorners <=0
        fprintf('Error: no corners to be refined!\n');
        goodCorners=[];
        return;
    end
    
    goodCorners = zeros(Ncorners,2);
    %clamp number of maximum iteration to [1,100].
    maxIters = min(max(maxIters,1),100);
    %square epsilon.
    epsilon = max(0,epsilon);
    
    mask = zeros(win_h,win_w); 
    for i=1:win_h
        y = (i- winSize(2)-1)/winSize(2);
        vy = exp(-y*y);
        for j=1:win_w
            x = (j-winSize(1)-1)/winSize(1);
            mask(i,j)=vy*exp(-x*x);
        end
    end
        
    %optimize locations for all corners.
    for cornerInd = 1:Ncorners
        cT = corners(cornerInd,:);cI = cT;
        iter =0; err =0;
        
        while 1
            cI2 = zeros(1,2);
            a=0;b=0;c=0;bb1=0;bb2=0;
            subpix_buff = getRectSubPix(Img,cI,win_w+2,win_h+2);            
            %accumulate gradient matrices.
            for i= 1:win_h
                py = i-1-winSize(2);
                for j=1:win_w                    
                    dx = subpix_buff(i+1,j+2) - subpix_buff(i+1,j);
                    dy = subpix_buff(i+2,j+1) - subpix_buff(i,j+1);
                    dxx = dx*dx*mask(i,j);
                    dxy = dx*dy*mask(i,j);
                    dyy = dy*dy*mask(i,j);
                    px = j-1-winSize(1);
                    
                    a=a + dxx;
                    b=b + dxy;
                    c=c + dyy;
                    bb1 = bb1+dxx*px+dxy*py;
                    bb2 = bb2+dxy*px+dyy*py;
                                        
                end               
            end
            
            det = a*c-b*b;
            if abs(det) < eps*eps
                break;
            end
            
            % update corners' locations.
            cI2(1) = cI(1) + (1/det)*(c*bb1-b*bb2);
            cI2(2) = cI(2) + (1/det)*(a*bb2-b*bb1);
            err = norm(cI-cI2);            
            
            if cI2(1)<1 || cI2(1)>imgWidth || cI2(2)<1 || cI2(2)>imgHeight
                break;
            else
                cI = cI2;
            end
            
            % check whether converged or maximum iteration number achieved.
            iter = iter +1;            
            if iter >= maxIters || err<=epsilon
                break;
            end
        end
        
        % leave initial point as result if new point is too far.
        if abs(cI(1)-cT(1))>winSize(1) || abs(cI(2)-cT(2))>winSize(2)
            cI = cT;
        end
        
        goodCorners(cornerInd,:) = cI;
    end
end

