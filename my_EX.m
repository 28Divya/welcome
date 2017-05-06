
function [area_exudates exudates] = function_EX (I)

%%% read file%%
[filename,pathname] = uigetfile('*.jpg;*.tif;*.png;*.jpeg;*.bmp;*.pgm;*.gif','pick an imgae');
file = fullfile(pathname,filename);
I = imread(file);

%%% resize, Green channel and brighten%%
I2=imresize(I, [576 720]); 
figure,subplot(2,2,1), imshow(I2), title('Resized Image to 576X720');

greenGrayscale = I2(:, :, 2);
subplot(2,2,2), imshow(greenGrayscale), title('Green Channel');

Grayscale_brighten = imadjust(greenGrayscale);
subplot(2,1,2), imshow(Grayscale_brighten), title('Brighten Grayscale Image');

%%%remove blood vessels%%
se2 = strel('ball',10,10); 
G_imclose = imclose(Grayscale_brighten, se2); 
figure, subplot(2,1,1), imshow(G_imclose), title('blood vessels removed');

%%column filter%%
filter_db_G_imclose = double(G_imclose); 
filter_colfilt = colfilt(filter_db_G_imclose,[6 6],'sliding',@var); 
filter_uint8_colfilt = uint8(filter_colfilt);
filter_image_seg = im2bw(filter_uint8_colfilt, 0.45); 
subplot(2,1,2), imshow(filter_image_seg), title('Image after image segmentation using column filter');

%%optical disk removal%%

%%%%%%%%%%%%%%%%%%%1. Rectangular border
for x=1:5 for y=1:720 
box_5pix(x,y)=1; 
end
end
for x=572:576 
    for y=1:720 
box_5pix(x,y)=1;
end
end
for x=1:576 for y=1:5 
box_5pix(x,y)=1; 
end
end
for x=1:576 for y=715:720 
box_5pix(x,y)=1; 
end
end
box_5pixel = logical(box_5pix);

%%%%%%%%%%%%%%%%%%%%%2. cirucular border

outline_border=edge(Grayscale_brighten, 'canny', 0.09);
for x=2:5 for y=100:620 
outline_border(x,y)=1; 
end
end
for x=572:575 for y=100:620 
outline_border(x,y)=1; 
end
end
Grayscale_imfill = imfill(outline_border, 'holes');
se = strel('disk',6);Grayscale_imerode = imerode(Grayscale_imfill, se); 
Grayscale_imdilate= imdilate(Grayscale_imfill, se);
Grayscale_C_border = Grayscale_imdilate - Grayscale_imerode;
Grayscale_C_border_L = logical(Grayscale_C_border); 
area_Cborder = 0;
area_new_Cborder = 0;
for x = 1:576 for y = 1:720
if Grayscale_C_border_L(x,y) == 1
area_Cborder = area_Cborder+1;
end
end
end
clear Grayscale_C_border_L
G_invert_G_B = imcomplement(Grayscale_brighten); 
black_filled = im2bw(G_invert_G_B, 0.94); 
se = strel('disk',6);
black_imerode = imerode(black_filled, se);
black_imdilate= imdilate(black_filled, se);
black_new_Cborder = black_imdilate - black_imerode;
Grayscale_C_border_L = logical(black_new_Cborder);
area_new_Cborder = 0;
for x = 1:576 for y = 1:720
if Grayscale_C_border_L(x,y) == 1
area_new_Cborder = area_new_Cborder+1;
end
end
end

%%%%%%%%%%%%%%3. Binary masking

max_GB_column=max(Grayscale_brighten);
max_GB_single=max(max_GB_column); 
[row,column] = find(Grayscale_brighten==max_GB_single);
median_row = floor(median(row)); 
median_column = floor(median(column)); 
radius = 130;
[x,y]=meshgrid(1:720, 1:576);
mask = sqrt( (x - median_column).^2 + (y - median_row).^2 )<= radius;
image_optical_removed = filter_image_seg - mask;
image_od_Cborder_removed = image_optical_removed - Grayscale_C_border;

figure, subplot(2,2,1), imshow(Grayscale_brighten), title('Grayscale image');
subplot(2,2,2), imshow(filter_image_seg), title('After image seg');
subplot(2,2,3), imshow(mask), title('Mask for optical disk');
subplot(2,2,4), imshow(image_optical_removed), title('Image with optical disk removed');

%%% Exudates %%

image_ex = image_od_Cborder_removed - box_5pixel;
image_ex_imclose = imclose (image_ex, se);
Gadpt_his = adapthisteq(Grayscale_brighten); 
dark_region = im2bw(Gadpt_his,0.85);
dark_features = ~dark_region;
exudates =image_ex_imclose;
exudates (image_ex_imclose & dark_features) = 0; 
figure, subplot(2,2,1), imshow(image_ex), title('Region with exudates');
subplot(2,2,2), imshow(image_ex_imclose), title('Expanded Region');
subplot(2,2,3), imshow(dark_features), title('Dark Features');
subplot(2,2,4), imshow(exudates), title('Exudates after AND function');
figure, imshow(exudates), title('Exudates');
figure, subplot(1,2,1), imshow(I2), title('input image')
subplot(1,2,2), imshow(exudates), title('output(exudates)')
stats  = regionprops(exudates,'Area');
area_exudates =stats.Area;
end












