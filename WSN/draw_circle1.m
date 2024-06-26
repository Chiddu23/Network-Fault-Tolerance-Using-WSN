function draw_circle1(x,y,R,c)

% Initialise the snake

t = 0:0.05:6.28;

x1 = (x + R*cos(t))';

y1 = (y +  R*sin(t))';


XS=[x1; x1(1)];

YS=[y1; y1(1)];

line(XS,YS,'color',c);