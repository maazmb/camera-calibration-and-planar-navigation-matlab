function [new_matchmetric,new_indexPairs ] = filtering( matchmetric,indexPairs )
% matchmetric is a parameter for feature matching. Feature matching
% matches the two points by calulating the distance between the features
% of the two points. Lower is the distance, greater is the match.
% Matchmetric gives this distance.

% FIltering is performed to get the best matched points, depending on the 
% matchmetric distance
elements = 20;
B = sort(matchmetric,'ascend');
index = zeros(length(matchmetric),1);
for i=1:1:length(matchmetric)
    index(i) = find(B(i)==matchmetric);
end
   temp1 = matchmetric(index);
   temp2 = indexPairs(index,:);
   
%    new_matchmetric = temp1(1:elements);
%    new_indexPairs = temp2(1:elements,:);
   new_matchmetric = temp1;
   new_indexPairs = temp2;

end

