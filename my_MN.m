function [area_micron_final micron_final] = function_MN (I)

%%%%%% read image
[filename,pathname] = uigetfile('*.jpg;*.tif;*.png;*.jpeg;*.bmp;*.pgm;*.gif','pick an imgae');
file = fullfile(pathname,filename);
I = imread(file);

%%%%%%%% resize and green channel
I2=imresize(I, [576 720]); 
figure,subplot(2,1,1), imshow(I2), title('Resized Image to 576X720');

greenChannel = I2(:, :, 2);
 subplot(2,1,2), imshow(greenChannel), title('Green Channel');


 %%%%%%%%%% noise removal and contrast enhancement
B1=medfilt2(greenChannel,[5 5]);
figure, subplot(2,1,1), imshow(B1), title('Denoised Image');

J1=adapthisteq(greenChannel);
subplot(2,1,2), imshow(J1),title('Contrast Enhancement Image');


%%%%%%%%%% morphological operation and thresholding
SE1=strel('square',1);
IC1=imclose(greenChannel,SE1);
figure,subplot(2,2,1), imshow(IC1), title('Closed Image');


IF1=imfill(IC1,'holes');
subplot(2,2,2), imshow(IF1), title('Holes filled Image');



diff_img=imsubtract(IF1,IC1);
subplot(2,1,2), imshow(diff_img), title('Difference Image');


level1=graythresh(diff_img);
IB1=im2bw(diff_img,level1);
BW1=~imextendedmin(diff_img,20);

figure
imshow(IB1);
title('Microaneurysms');
figure, subplot(1,2,1), imshow(I2), title('input image');
subplot(1,2,2), imshow(IB1), title('output(Microaneurysms)');

%%%% area calculation %%%
area_micron_final = 0;
for x = 1:576 for y = 1:720
if IB1(x,y) == 1
area_micron_final = area_micron_final+1;
end
    end
end
end