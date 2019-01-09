function [output] =dilate(input)
%dilate an image with 3*3 rectangular structure element
%structure element is [1 1 1;1 1 1;1 1 1]
%% params
%@ input image of single channel
%%
    rows=size(input,1);
    cols=size(input,2);
    %padding zeros on four edges
    output = zeros(rows,cols);
    padded = zeros(rows+2,cols+2);
    padded(2:rows+1,2:cols+1) = input;
    temp = zeros(3,3);
    for i= 2:rows+1
        for j=2:cols+1
            temp = padded(i-1:i+1,j-1:j+1);
            output(i-1,j-1) = max(temp(:));
        end
    end
    
end

