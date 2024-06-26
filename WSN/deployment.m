clc;
clear; 
mn=5; % malicious node
sn=29; % sensor node
x=randi([0,100],1,sn); % x coordinate of a sn
y=randi([0,100],1,sn); % y coordinate of a sn
z=randi([0,sn],1,mn); % malicious nodes index values (as per percentage 20%)
plot(x,y,'mo',...
    'LineWidth',2,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor',[.17 0.66 .83],...
    'MarkerSize',10)
legend('SN')
for i=1:sn  
      draw_circle1(x(i),y(i),30,'g') 
end
for j=1:sn     
    for k=1:mn
    if z(k)==j
    draw_circle1(x(j),y(j),30,'r')
    end
    end 
end
grid on
figure(1) % Hold figure 1
hold on
run('MCTCP.p');