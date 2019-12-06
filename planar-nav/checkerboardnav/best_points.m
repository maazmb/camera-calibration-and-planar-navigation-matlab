function [matchedPoints1,matchedPoints2,indexPairs,count] = best_points( matchedPoints1,matchedPoints2,indexPairs)
% matchmetric is a parameter for feature matching. Feature matching
% matches the two points by calulating the distance between the features
% of the two points. Lower is the distance, greater is the match.
% Matchmetric gives this distance.

% FIltering is performed to get the best matched points, depending on the 
% matchmetric distance
count = 0;
thresh = 10;
for i=1:1:length(matchedPoints1)
   P1 = matchedPoints1(i).Location;
   P2 = matchedPoints2(i).Location;
   x1 = P1(1);
   x2 = P2(1);
   y1 = P1(2);
   y2 = P2(2);
   d = distance(x1,x2,y1,y2);
   if(d<thresh)
       count = count+1;
       matchedPoints1(count) = matchedPoints1(i);
       matchedPoints2(count) = matchedPoints2(i);
   end
end
matchedPoints1=matchedPoints1(1:count);
matchedPoints2=matchedPoints2(1:count);
indexPairs = indexPairs(1:count,:);