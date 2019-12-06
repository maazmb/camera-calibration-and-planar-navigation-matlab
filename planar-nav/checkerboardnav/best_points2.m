function [matchedPoints1,matchedPoints2,indexPairs] = best_points2( matchedPoints1,matchedPoints2,indexPairs)
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
B = sort(d,'ascend');
index = zeros(length(d),1);
for i=1:1:length(d)
    index(i) = find(B(i)==d);
end
   temp1 = matchedPoints1(index);
   temp2 = matchedPoints2(index);
   temp3 = indexPairs(index,:);
   if (length(temp1)<size)
        matchedPoints1 = temp1;
        matchedPoints2 = temp2;
        indexPairs = temp3;
   else
        matchedPoints1 = temp1(1:size);
        matchedPoints2 = temp2(1:size);
        indexPairs = temp3(1:size,:);
   end
