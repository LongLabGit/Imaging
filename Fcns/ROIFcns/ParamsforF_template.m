%Things you need to tell the system:
%1) which cells you are interested in
%2) which motifs to remove from those cells
%3)
% mb=[76,41,35,23,7];% sb=[90,75,59,14,12];
sb=[75,14,12];
mb=[76,41,7];
cells=[sb,mb];

BadMotifs2={[8,11,13,27,28,29,37],[7,20],[3,4,5,6,10,14,13,19,24,29,30,34,40,41,42],[34,41,42],[6,11,13,18,19,20,27,29,33,37],[6,8,11,17,20,21,25,29,31,35,37,42]};
baseOn=[0.4,0.88,-1,0.3,0.8,-1];
baseLen=[1,1,15,8,4,4];