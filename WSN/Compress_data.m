I= imread('23.jpg'); 
figure();X=I;n=5;wname = 'haar';
x = double(X);TotalColors = 255;map = gray(TotalColors);
x = uint8(x);x = double(X);xrgb  = 0.2990*x(:,:,1) + 0.5870*x(:,:,2) + 0.1140*x(:,:,3);
colors = 255;x = wcodemat(xrgb,colors);map = pink(colors);x = uint8(x);
[c,s] = wavedec2(x,n,wname);alpha = 1.5; m = 2.7*prod(s(1,:));
[thr,nkeep] = wdcbm2(c,s,alpha,m);[xd,cxd,sxd,perf0,perfl2] = wdencmp('lvd',c,s,wname,n,thr,'h');
disp('Compression Ratio');disp(perf0);R = waverec2(c,s,wname); rc = uint8(R);
subplot(221), image(x); colormap(map); title('Original image');Original_PSNR = psnr(xd,xrgb)*-1;
Original_MSE = immse(xd,xrgb);fg=num2str(Original_MSE);msgbox(fg,'Or_MSE');
AA=num2str(Original_PSNR);msgbox(AA,'Or_PSNR');subplot(222), image(xd); colormap(map);
title('Encrypted image');subplot(223), image(rc); colormap(map);title('Decrypted image');
 img_spiht=rc; Decrypted_PSNR = psnr(R,xd)*-1; AA=num2str(Decrypted_PSNR);msgbox(AA,'De_PSNR');
 Decrypted_MSE = immse(R,xd);fg=num2str(Decrypted_MSE);msgbox(fg,'De_MSE');
subplot(122);imshow(img_spiht);title('Decrypted Image');colormap(map);run('confusion_matrix');

run('confusion_matrix.p');


