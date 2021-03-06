samplePathArr = {'data/lena.jpg','data/boldt.jpg','data/building.jpg', ... 
    'data/group.jpg','data/moose.jpg','data/waves.jpg'};
Img = imread(samplePathArr{2});

%% edges detection
figure;
imshow(uint8(edgeDetector(Img,3,1,1)));hold on;

%% corners detection
[corners,response] = goodCorners(Img,3,0.01,10,true,1/25);
cornersSubPix = cornerSubPix(RGB2Gray(Img),corners,[10 10],30,0.03);
plot(cornersSubPix(:,1),cornersSubPix(:,2),'o','Color',[1 0 0]);

