function [output] = RGB2Gray(input)
%convert a colorful image to grayscale image.
%% params:
%@input: image of single channel or three channels
%%
    output = zeros(size(input,1),size(input,2));
    input = single(input);
    if size(input,3)==1
        output = input;
    elseif size(input,3)==3
        output=round(0.229*input(:,:,1)+0.587*input(:,:,2) ...
        +0.114*input(:,:,3));
    else
        fprintf('Error: improper channels for input image!\n');
        return;
    end
end

