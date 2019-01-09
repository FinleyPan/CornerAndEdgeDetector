function [output] = makeBordersReflect(top,bottom,left,right,input)
%Make borders with reflecting padding
%% params
%@ top: length in pixels of padded top border.
%@ bottom: length in pixels of padded bottom border.
%@ left: length in pixels of padded left border.
%@ right: length in pixels of padded right border.
%@ input: input image (both 3-channel and 1-channel are OK)
%%
    rows = size(input,1);
    cols = size(input,2);
    
    %temp variable holding results of top and bottom padding
    temp1 = zeros(rows+top+bottom,cols);
    %temp variable holding results of left and right padding
    temp2 = zeros(rows+top+bottom,cols+left+right);
   
    %for one channel
    if size(input,3) == 1
        temp1(top+1:rows+top,:) = input(:,:);
        %top
        for i=1:top
            temp1(i,:)=input(top-i+2,:);
        end
        %bottom
        for i=top+rows+1:rows+bottom+top
            temp1(i,:)=input(2*rows-i+top,:);
        end
        
        temp2(:,1+left:left+cols) = temp1(:,:);
        
        %left
        for i=1:left
            temp2(:,i) = temp1(:,left-i+2);
        end
        %right
        for i=left+cols+1:left+cols+right
            temp2(:,i) = temp1(:,2*cols-i+left);
        end
        output = temp2;
    % for three channels    
    elseif size(input,3) == 3
        output = zeros(rows+top+bottom,cols+left+right,3);
        for j=1:3
            temp1(top+1:rows+top,:) = input(:,:,j);
            %top
            for i=1:top
                temp1(i,:)=input(top-i+2,:,j);
            end
            %bottom
            for i=top+rows+1:rows+bottom+top
                temp1(i,:)=input(2*rows-i+top,:,j);
            end
        
            temp2(:,1+left:left+cols) = temp1(:,:);
        
            %left
            for i=1:left
                temp2(:,i) = temp1(:,left-i+2);
            end
            %right
            for i=left+cols+1:left+cols+right
                temp2(:,i) = temp1(:,2*cols-i+left);
            end
            output(:,:,j)=temp2;
        end
        
    end
end

