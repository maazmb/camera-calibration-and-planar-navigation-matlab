function [matchedPoints1,matchedPoints2,indexPairs,f] = best_points3( matchedPoints1,matchedPoints2,indexPairs)
% matchmetric is a parameter for feature matching. Feature matching
% matches the two points by calulating the distance between the features
% of the two points. Lower is the distance, greater is the match.
% Matchmetric gives this distance.

% FIltering is performed to get the best matched points, depending on the 
% matchmetric distance
size = 20;
P1 = matchedPoints1.Location;
P2 = matchedPoints2.Location;
   x1 = P1(:,1);
   x2 = P2(:,1);
   y1 = P1(:,2);
   y2 = P2(:,2);
d = distance(x1,x2,y1,y2);
% if (length(d)>40)
    [x,y] = hist(d,length(d)/4);
    %???? x,y??
    %???bestpont m file is ,uch easier
    
    
    
% else
%     [x,y] = hist(d,length(d)/1.5);
% end

best_clas = find(x==max(x));
t = diff(y);
t=t(1);
% f are the best distances
f = find(d<y(best_clas)+t & d>y(best_clas)-t);
%??

% index = zeros(length(f),1);
% for i=1:1:length(f)
%     index(i) = find(f(i)==d);
% end
   temp1 = matchedPoints1(f);
   temp2 = matchedPoints2(f);
   temp3 = indexPairs(f,:);

        matchedPoints1 = temp1;
        matchedPoints2 = temp2;
        indexPairs = temp3;

   end
