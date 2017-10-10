function [starts,stops,centers,warps]=findMotifs(audioF,templateF,thresh)
% Input
%   audioF: string filename of .wav for a trial (~25 s)
%   templateF: string filename of a .wav file of the template song (~1 s)
%   thresh: threshold on the correlations,m between 0 and 1
% Output
%   starts: song onsets
%   stops, centers you know what to do 
%   warp: warp=length of song/length(template)