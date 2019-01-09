function [ Res ] = sobel( image,kSize,direction,scale )
%apply sobel to image
%% params
%@ image: input of gray-scale.
%@ kSize; size of sobel kernel, which must be odd.
%@ direction: a character indicating orientations of gradients, must be one of {'x','y'}.
%@ scale: scale for the computed derivative values.
%%    
    rows = size(image,1);
    cols = size(image,2);
    
    Res = zeros(rows,cols);
    
    if(mode(kSize,2)==0 || kSize<=1)
        fprintf('Improper kSize!\n');
    end
    
    [kx,ky] = makeSobelKer(kSize,direction);
    
    Res = sepFilter2D(image,kx,ky,scale);

%% ----------------------deprecated----------------------------
%{ 
    rows = size(image,1);
    cols = size(image,2);
    sobel = [-1 0 1;
             -2 0 2;
             -1 0 1];
    if (r==1)
        if (c==1)
            block=[image(2,2) image(2,1) image(2,2);
                   image(1,2) image(1,1) image(1,2);
                   image(2,2) image(2,1) image(2,2)];
        elseif (c==cols)
            block=[image(2,cols-1) image(2,cols) image(2,cols-1);
                   image(1,cols-1) image(1,cols) image(1,cols-1);
                   image(2,cols-1) image(2,cols) image(2,cols-1)];
        else
            block=[image(r+1,c-1) image(r+1,c) image(r+1,c+1);
                   image(r,c-1) image(r,c) image(r,c+1);
                   image(r+1,c-1) image(r+1,c) image(r+1,c+1)];
        end
    elseif (r==rows) 
        if (c==1)
            block = [image(r-1,2) image(r-1,1) image(r-1,2);
                     image(r,2)  image(r,1)    image(r,2);
                     image(r-1,2) image(r-1,1) image(r-1,2)];
        elseif(c==cols)
            block = [image(r-1,c-1) image(r-1,c) image(r-1,c-1);
                     image(r,c-1)   image(r,c) image(r,c-1);
                     image(r-1,c-1) image(r-1,c) image(r-1,c-1)];
        else
            block = [image(r-1,c-1) image(r-1,c) image(r-1,c+1);
                     image(r,c-1) image(r,c) image(r,c+1);
                     image(r-1,c-1) image(r-1,c) image(r-1,c+1)];
        end
    elseif((c>1) && (c<cols))
        block= image(r-1:r+1,c-1:c+1);
    else
        if c==1
            block = [image(r-1,2) image(r-1,1) image(r-1,2);
                     image(r,2)   image(r,1)  image(r,2);
                     image(r+1,2) image(r+1,1)  image(r+1,2)];
        elseif c==cols
            block = [image(r-1,cols-1) image(r-1,cols) image(r-1,cols-1);
                     image(r,cols-1) image(r,cols) image(r,cols-1);
                     image(r+1,cols-1) image(r+1,cols) image(r+1,cols-1)];
        end
    end
    conv = block .* sobel;
    newPix = sum(conv(:));
end
 %}

end

function [kx,ky] = makeSobelKer(kSize,direction)
% return horizontal and vertical 1D sobel kernels
%% params:
%@ kSize: size of sobel kernel, which must be odd.
%@ direction: a character indicating orientations of gradients, must be one of {'x','y'}.
%%
    if direction == 'x'
        ker = [-1 0 1;
                  -2 0 2;
                  -1 0 1];
    elseif direction == 'y'
        ker = [-1 -2 -1;
                   0 0 0;
                    1 2 1];
    else
        kx = [];ky=[];
        fprintf('Error: direction is either ''x'' or ''y''!\n');
        return ;
    end
    cnt =(kSize-1)/2;
    
    smoothKer = [1 2 1]'*[1 2 1];
    for i = 1 : cnt-1
        ker = conv2(smoothKer,ker);
    end
    
    if(direction == 'x')
        kx = ker(1,:);
        ky = -ker(:,1);
    else
        kx = -ker(1,:);
        ky = ker(:,1);
    end
end