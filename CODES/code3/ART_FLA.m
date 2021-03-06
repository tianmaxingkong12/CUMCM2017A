%% ART
% clear all
% close all
% clc;
init_matrix = depth;
L = 256;%图像大小
nIter = 0;% 迭代次数
iterOK = 0;
iter0 = ones(4*L)*0.2;%元素为0.2的矩阵,512*512
nTheta = length(theta);% 180
m0 = 4;
%%
sample_length = pixel_length/deltx_value;
sample_point = 1:sample_length*m0:512;
sample = interp1(1:512,init_matrix,sample_point,'linear');
size_sample = size(sample);

% 扩大求解范围
% t = floor((sqrt(2)-1)*size_sample(1)/2);
t = 80;
sample1 = [zeros(t,size_sample(2)); sample; zeros(t,size_sample(2))];
% I0 = iradon(sample, theta_deg);
I0 = iradon(sample1, theta_deg,'spline','none',deltx_value,size_sample(1));

%确定射线束的点 中心法
%load value

value = {};
for j = 1:180
    mi = zeros(size_sample(1),size_sample(1)*size_sample(1));
    for i = 1:size_sample(1)
        line_start = zeros(size_sample(1));
        line_start (:,i) = 1;% (4*ii-3)~4*ii 列的值为1
        line = imrotate (line_start, theta(j), 'crop');% 确定射线束
        mi(i,:) = reshape(line,1,[]);
    end
    value = [value,mi];
end
% 最后应该要是一个 180*size_sample*size_sample 的矩阵
% 对应要求的解应该是 (size_sample*size_sample)*1
%% 迭代
% 迭代初始值为I0
% 结果矩阵为sample

correction = [];
iter = reshape(I0,[],1); % 搜索起点 
% iter n*n *1
while (nIter <= 10)% 迭代次数
    cor_temp = 0;
    nIter = nIter + 1;
    %  一次迭代过程
    for i = 1:180
        line = value{i};% n*(n^2)
        iter_sum = line*iter;% n 91*1
        iter_target = sample(:,i);
        iter_num = sum(line* line');% 91 * 91 -> 
        iter1 = iter +line'* ((iter_target-iter_sum)./iter_num');% sum(sum(proj))
        iter = iter1;
        % 评价
        %          iter_del = iter
        cor_temp = cor_temp + (iter_target-iter_sum)'*(iter_target-iter_sum);
    end
    %一次迭代过程结束
    correction = [correction,cor_temp];
end
% imshow(iter0);

%% 重建后图像
% R = zeros(L);
% for aa = 1:L;
%     for bb = 1:L;
%         R (aa, bb) = sum(sum(iter0((4*aa-3):4*aa,(4*bb-3):4*bb)));
%     end
% end
% figure, imshow(R), title('迭代重建图像')
I0 = reshape(iter,91,91);
size_I0 = size(I0);
y0 = 9;
x0 = 6;

centerX = round(x0/m0/pixel_length + (1+size_I0(1))/2);
centerY = round(y0/m0/pixel_length + (1+size_I0(2))/2);
% plot(centerX,centerY,'or');
% rectangle('Position',[centerX-256,centerX+255,512,512]) 
% 以椭圆中心为中心取出512个点即为所需
%n = 512;
n = 256/m0;
I = I0(round(centerX-n/2+1):round(centerX+n/2-1),round(centerY-n/2+1):round(centerY+n/2-1));
