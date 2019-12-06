function w3 = pixel2world(p1,p2,p3,w1,w2)
     
% First find d1,d2,d3 in image coordinate system
% find distance between p1 and p3
d1 = distance(p1(1),p3(1),p1(2),p3(2));

% find distance between p2 and p3
d3 = distance(p2(1),p3(1),p2(2),p3(2));

% find distance between p1 and p2
d2 = distance(p1(1),p2(1),p1(2),p2(2));

% find D1,D2,D3 in world coordinate system
D2 = distance(w1(1),w2(1),w1(2),w2(2));

%find scale
s=D2/d2;
D1 = s*d1;
D3 = s*d3;
theta1 = acosd(((D1)^2 + (D2)^2 -(D3)^2)/(2*D1*D2));
theta2 = acosd(((D1)^2 + (D3)^2 -(D2)^2)/(2*D1*D3));
theta3 = acosd(((D2)^2 + (D3)^2 -(D1)^2)/(2*D2*D3));

w3 = [theta1 theta2 theta3];
x = (D2^2 - D1^2 + D3^2)/(2*D3);
y = D2^2 - x^2;
% w3 = [x y];
end


