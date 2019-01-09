function [ Res ] = sepFilter2D( image ,kernelX,kernelY,scale)
%Linearly filter image with one-dimensional kernels in x-direction and in y-direction separately.
%% params
%image: input of gray scale.
%kernelX: horizontal 1D kernel.
%kernelY: vertical 1D kernel.
%scale: scale applying to filtering. 
%%

    rows = size(image,1);
    cols = size(image,2);
    lengthX = max(size(kernelX));
    lengthY = max(size(kernelY));
    dimX = min(size(kernelX));dimY = min(size(kernelY));
    top =(lengthY-1)/2; bottom = (lengthY-1)/2;
    left =(lengthX-1)/2; right = (lengthX-1)/2;
    
    Res = zeros(rows,cols);
    
    if(scale==0)
        fprintf('Error: scale cannot be zeros!\n');
        return;    
    end
    
    if size(image,3)~=1
        fprintf('Error: single channel required!\n');
        return;
    end  
    
    if(dimX~=1||dimY~=1)
        fprintf('Error: kernels must be vectors!\n');
        return;
    end
    if mod(lengthX,2)==0 || mod(lengthY,2)==0
        fprintf('Error: kernel of odd length required!\n');
        return;
    end
       
    kernelY = scale*kernelY;
    % pad borders
    imagePadded = makeBordersReflect(top,bottom,left,right,image);
    %% -----------------------deprecated-------------------------
%     imagePadded(2:(rows+1),2:(cols+1)) = image;
%     %padding top, bottom, left and right edges
%     for i=1:cols
%         imagePadded(1,i+1) = image(2,i);
%         imagePadded(rows+2,i+1) = image(rows-1,i);        
%     end
%     for i=1:rows
%         imagePadded(i+1,1) = image(i,2);
%         imagePadded(i+1,cols+2) = image(i,cols-1);
%     end
%     % padding four corners
%     imagePadded(1,1) = image(2,2);
%     imagePadded(1,cols+2) = image(2,cols-1);
%     imagePadded(rows+2,1) = image(rows-1,2);
%     imagePadded(rows+2,cols+2) = image(rows-1,cols-1);
   %% --------------------------------------------------------
   
    %save intermediate results of horizontally filtering
    tempX = zeros(rows+top+bottom,cols+left+right);
    %filter in x direction
    for i=1:rows+top+bottom
        for j=left+1:left+cols
            for k = 1:lengthX
                tempX(i,j) =tempX(i,j)+ kernelX(k)*imagePadded(i,j+k-left-1);
            end
        end
    end
    
    %save intermediate results of vertically filtering
    tempY = zeros(rows+top+bottom,cols+left+right);
    %filter in y direction
    for j=left+1:left+cols
        for i=top+1:rows+top
            for k = 1:lengthY
                tempY(i,j) =tempY(i,j)+ kernelY(k)*tempX(i+k-top-1,j);
            end
        end
    end
    
    %extract the result
    Res = tempY(top+1:rows+top,left+1:cols+left);
end

