function [output] = threshold(input,threshVal)
%Set pixels' intensities to zero if intensities are less than threshVal.
%keep constant otherwise.
%% params:
%@input:input image of gray scale
%@threshVal:threshold Value
%%
    rows = size(input,1);
    cols = size(input,2);
    output = zeros(rows,cols);
    for i=1:rows
        for j=1:cols
            if input(i,j)>threshVal
                output(i,j) = input(i,j);
            end
        end
    end
end

