clear all
close all
clc

I=imread('D:\Read\7th Sem\Mini Project\matlab proj\cip\cip\input\1.jpg'); 
figure,imshow(I);
pause

I2=imresize(I,[128,128]); 
figure,imshow(I2);
pause

I3=rgb2gray(I2); 

I3=im2double(I3); 

I3=im2bw(I3);

I3=bwmorph(~I3, 'thin', inf); 

I3=~I3; 

figure,imshow(I3);
pause

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

C=[u;v];

N=k-1; 

oub=sum(C(1,:))/N; 

ovb=sum(C(1,:))/N; 

%Moving the Signature to the Origin

for i=1:N
    u(i)=u(i)-oub+1;
    v(i)=v(i)-ovb+1;
end

C=[u,v];

ub=sum(C(1,:))/N;
vb=sum(C(1,:))/N;

ubSq=sum((C(1,:)-ub).^2)/N;
vbSq=sum((C(2,:)-vb).^2)/N;

for i=1:N
    uv(i)=u(i)*v(i);
end

uvb=sum(uv)/N;
M=[ubSq uvb;uvb vbSq];


minIgen=min(abs(eig(M)));

MI=[ubSq-minIgen uvb;uvb vbSq-minIgen];
theta=(atan((-MI(1))/MI(2))*180)/pi;

thetaRad=(theta*pi)/180;
rotMat=[cos(thetaRad) -sin(thetaRad);sin(thetaRad) cos(thetaRad)];


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

mx=0; %moving x co-ordinate
my=0; %moving y co-ordinate

if (min(u)<0)
    mx=-min(u);
    for i=1:N
        u(i)=u(i)+mx+1;
    end
end

if (min(v)<0)
    my=-min(v);
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

for i=ystart:yend
    for j=xstart:xend
        im((i-ystart+1),(j-xstart+1))=I3(i,j);
    end
end

figure,imshow(im); 
















