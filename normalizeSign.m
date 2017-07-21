%%N.M.Meegama
%%Eduction: Sri Lanka Institue of Information Technology,University of Sri
%%Jayewardenepura
%%Created:2009/07/09
%%Use imge signature1.jpg,siganture2.jpg,signature3.jpg to test the code
%%The code will Normalize The signature image
%% Pre proceessing steps
%%      Resizing
%%      Thinning
%%      Rotating
%%      Cropping a boundry box around it
%% NOTE: The "pause" statement used will pause the execution after each
%% important step use any key to resume execution

%% The code does not bring every signature to a similar state but it is
%% almost accurate
%% download the images given to test the code but this code will work for
%% other signatures as well
clear all
I=imread('D:\Read\7th Sem\Mini Project\My Proj\Mini'); % Load the image file and store it as the variable I. 
figure,imshow(I);
pause
I2=imresize(I,[128 ,128]);
figure,imshow(I2);
pause
I3=rgb2gray(I2);
I3=im2double(I3);
I3=im2bw(I3);                       %converting image to black and white
I3 = bwmorph(~I3, 'thin', inf);                   %thining the image
I3=~I3;
figure,imshow(I3);
pause
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%extracting the black pixels
k=1;
for i=1:128
    for j=1:128
        if(I3(i,j)==0)
            u(k)=i;
            v(k)=j;
            k=k+1;
            I3(i,j)=1;
        end
    end
end
C=[u;v];%the curve of the signature
N=k-1;%the number of pixels in the signature
oub=sum(C(1,:))/N;   %the original x co-ordinate center of mass of the image
ovb=sum(C(2,:))/N;   %the original y co-ordinate center of mass of the image



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%********ROTATE******%%%%%%%%%%%%%%%%%%%%%%%%
%moving the signature to the origin
for i=1:N
    u(i)=u(i)-oub+1;
    v(i)=v(i)-ovb+1;
end
% the new curve of the signature
C=[u;v];

ub=sum(C(1,:))/N;
vb=sum(C(2,:))/N;
ubSq=sum((C(1,:)-ub).^2)/N;
vbSq=sum((C(2,:)-vb).^2)/N;
 
for i=1:N
    uv(i)=u(i)*v(i);
end

uvb=sum(uv)/N;
M=[ubSq uvb;uvb vbSq]
%calculating minimum igen value of the matrix
minIgen=min(abs(eig(M)))
%the eigen vector
MI=[ubSq-minIgen uvb;uvb vbSq-minIgen]
theta=(atan((-MI(1))/MI(2))*180)/pi


thetaRad=(theta*pi)/180;
rotMat=[cos(thetaRad) -sin(thetaRad);sin(thetaRad) cos(thetaRad)];
% rotation
for i=1:N
    v(i)=(C(2,i)*cos(thetaRad))-(C(1,i)*sin(thetaRad));
    u(i)=(C(2,i)*sin(thetaRad))+(C(1,i)*cos(thetaRad));
end
C=[u;v];
%moving the signature to its original position

for i=1:N
    u(i)=round(u(i)+oub-1);
    v(i)=round(v(i)+ovb-1);
end

%after rotating the image the signature might go out of the boundry (128x128) therefore 
%we have to move the signature curve 
mx=0;%the moving x co-ordinate
my=0;%the moving y co-ordinate

if (min(u)<0)
    mx=-min(u)
    for i=1:N
        u(i)=u(i)+mx+1;
    end
end

if (min(v)<0)
    my=-min(v)
    for i=1:N
        v(i)=v(i)+my+1;
    end
end

C=[u;v];

for i=1:N
    I3((u(i)),(v(i)))=0;
end

figure,imshow(I3);
pause
%%%%%%%%%%%%%%%%%%%%%%%****DRWING THE BOUNDRY BOX*****%%%%%%%%%%%%%%%%%%%%
%getting the margins
xstart=128;
xend=1;
ystart=128;
yend=1;

for r=1:128
    for c=1:128
        if((I3(r,c)==0))
            if (r<ystart)
                ystart=r;
            end
            if((r>yend))
                yend=r; 
            end
            if (c<xstart)
                xstart=c;
            end
            if (c>xend)
                xend=c;
            end     
       end  
    end
end
%cutting the image and copying it to another matrix        
for i=ystart:yend
    for j=xstart:xend
        im((i-ystart+1),(j-xstart+1))=I3(i,j);
    end
end


figure,imshow(im);     %cropped image

