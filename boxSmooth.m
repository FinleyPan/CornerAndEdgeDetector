function [Res] = boxSmooth(image,boxSize,IsNormalized)
%Box Smooth filter
%% params:
%@image: input of gray-scale.
%@boxSize: size of the window.
%@IsNormalized: flag indicate whether normalized.
%%

    rows = size(image,1);
    cols = size(image,2);
    
    Res = zeros(rows,cols);
    if(mod(boxSize,2)==0 || boxSize<=1)
        fprintf('Improper box size!\n');
        return ;
    end
    
    Area = 1;
    if IsNormalized
        Area = boxSize^2;
    end
    
    kerX = ones(1,boxSize);kerY = ones(1,boxSize);
    Res = sepFilter2D(image,kerX,kerY,1/Area);
end

