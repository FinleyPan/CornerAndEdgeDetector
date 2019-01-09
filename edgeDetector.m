function [Res] = edgeDetector(input,kSize,scaleX,scaleY)
% detect edges in one images, and return a grayscale result.
%% params:
%@input : image of single channel or three channels.
%@kSize: specify size of sobel kernels.
%@scaleX: specify scale applying to horizontal sobel kernels.
%@scaleY: specify scale applying to vertical sobel kernels.
%%
    input = RGB2Gray(input);
    sobelX = sobel(input,kSize,'x',scaleX);
    sobelY = sobel(input,kSize,'y',scaleY);
    Res = clamp255(0.5*abs(sobelX)+abs(0.5*sobelY));
end

