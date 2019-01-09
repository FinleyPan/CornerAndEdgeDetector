function [ N ] = clamp255( M )
%clamp pixels' intensity to [0,255]
%% params
%@M: image of single channel 
%%
    rows = size(M,1);
    cols = size(M,2);
    N = zeros(rows,cols);
    for i=1:rows
        for j=1:cols
            if(M(i,j)<0)
                N(i,j) = 0;
            elseif(M(i,j)>255)
                N(i,j)=255;
            else
                N(i,j)=M(i,j);
            end
        end
    end

end

