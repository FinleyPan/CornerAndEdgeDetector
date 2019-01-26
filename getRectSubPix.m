function [ Res ] = getRectSubPix(input,center0,winWidth,winHeight )
%Recover pixels' rectangle with subpixel accuracy.
%% params:
%@input: image of grayscale.
%@center0: geometric center of rectangle.
%@winWidth: width of the window.
%@winHeight: height of the window.
%%

    rows = size(input,1);
    cols = size(input,2);

    center = center0 - 0.5*[winWidth-1 winHeight-1];
    icenter = floor(center);
    if cols<=icenter(1)+winWidth-1 || rows<=icenter(2)+winHeight-1 ...
       || icenter(1)<1 || icenter(2) <1
        Res = getRectSubPix_OutRange(input,center0,winWidth,winHeight);
        return ;
    end

    Res =zeros(int32(winWidth),int32(winHeight));

    a = center(1) - icenter(1);
    b = center(2) - icenter(2);
    a= max(a,0.0001);
    a12 = a*(1.0-b);
    a22 = a*b;
    b1 = 1.0-b;
    b2 = b;
    s = (1-a)/a;
    
    % bilinear interpolation
    for i = 1:winHeight    
        index = rows*(icenter(1)-1)+icenter(2)+i-1;
        prev = (1-a)*(b1*input(index)+b2*input(index+1));
        for j=1:winWidth
            t=a12*input(index+j*rows)+a22*input(index+j*rows+1);
            Res(winWidth*(j-1)+i)=prev+t;
            prev = t*s;
        end
    end

end

function [Res] = getRectSubPix_OutRange(input,center0,winWidth,winHeight)
%Recover pixels' rectangle with subpixel accuracy for which is out of image.
%% params:
%@input: image of grayscale.
%@center0: geometric center of rectangle.
%@winWidth: width of the window.
%@winHeight: height of the window.
%%
    rows = size(input,1);
    cols = size(input,2);         

    topleft = center0 - 0.5*[winWidth-1 winHeight-1];
    itopleft = floor(topleft);
    
    Res =zeros(int32(winWidth),int32(winHeight));
    
    a=topleft(1) - itopleft(1);
    b=topleft(2) - itopleft(2);
    a11=(1-a)*(1-b);
    a12=a*(1-b);
    a21=(1-a)*b;
    a22=a*b;
    
    [rect,startInd] = adjustRect(itopleft,winWidth,winHeight,cols,rows);
    for i=1:winHeight
        % nextInd refers to the first element of next row in rect.
        nextInd = startInd + 1;
        if i<rect.y || i> rect.height
            nextInd = nextInd -1;                       
        end
        
        % exceed the left boundary.
        if rect.x > 1
            for j=1:rect.x-1
                Res(i,j) = input(startInd)*(1-b)+input(nextInd)*b;
            end
        end
        
        % exceed the right boundary.
        if rect.width < winWidth
            for j=rect.width+1 : winWidth
                Res(i,j) = input(startInd+rect.width*rows)*(1-b)+...
                    input(nextInd+rect.width*rows)*b;
            end
        end
        
        %bilnear interpolation for overlaid region, linear interpolation
        %for out-of-bounds region.
        for j=rect.x : rect.width
            offset = j - rect.x;
            Res(i,j) = a11*input(startInd+offset*rows)+ ... 
                       a12*input(startInd+(offset+1)*rows)+...
                       a21*input(nextInd+offset*rows)+ ...
                       a22*input(nextInd+(offset+1)*rows);
        end
        
        if i<=rect.height
            startInd = nextInd;
        end
    end
    
end

function [rect,startInd] = adjustRect(itopleft,winWidth,winHeight,imgWidth,imgHeight)
%adjust out-of-bounds window's top left corner and size. Typically, we assume
%that the top and left boundaries are inclusive, while the right and bottom boundaries are not.
%linear index of first pixel in this rectangle will be returned too.
%% params:
%@ itopleft: floor of rectangle's top left corner.
%@ winWidth: width of rectangle.
%@ winHeight: height of rectangle.
%@ imgWidth: width of image.
%@ imgHeight: height of image.
%%
    % mind you that origin is at (1,1).
    startInd = 1;
    if itopleft(1)<1
        rect.x=2-itopleft(1);
    else
        rect.x = 1;
        startInd = startInd + (itopleft(1)-1)*imgHeight;
    end
    
    if itopleft(1)+winWidth-1<imgWidth
        rect.width = winWidth;
    else
        rect.width = imgWidth - itopleft(1);
        if rect.width < 0
            %clamp to the last column if exceed the las column.
            startInd = startInd + rect.width*imgHeight;
            rect.width = 0;
        end
    end
    
    if itopleft(2)<1
        rect.y=2-itopleft(2);
    else
        rect.y = 1;
        startInd = startInd + itopleft(2)-1;
    end
    
    if itopleft(2)+winHeight-1<imgHeight
        rect.height = winHeight;
    else
        rect.height = imgHeight - itopleft(2);
        if rect.height < 0
            %clamp to the last row if exceed the last row.
            startInd = startInd + rect.height;
            rect.height = 0;
        end
    end

end
