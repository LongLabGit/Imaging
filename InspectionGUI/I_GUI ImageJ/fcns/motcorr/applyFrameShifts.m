function newmov=applyFrameShifts(mov,xoffsets,yoffsets,fignum,verbose,dataClass)
%create a motion corrected version of the 3 dimensional movie mov
%where size(mov)=[y x z] and z is the number of frames
%where xoffsets, yoffsets represent the displacement of the movie at each
%frame
%fignum is an optional argument that when set will cause a motion corrected
%movie to be played back in figure number (fignum);

%save the size of the movie
[y,x,z]=size(mov);

%find the maximum and minimum offsets
maxxshift=max(xoffsets);
maxyshift=max(yoffsets);
minxshift=min(xoffsets);
minyshift=min(yoffsets);

%shift them appropriately to find the shifts which will gauruntee that you
%never get any blank pixels on the edge
maxxshift=ceil(maxxshift);
maxyshift=ceil(maxyshift);
minxshift=floor(minxshift);
minyshift=floor(minyshift);

%calculate the new size of the movie which clips off the edges such that
%there are never any blank pixels
keepRangeY = max(1,1+maxyshift):min(y,y+minyshift);
keepRangeX = max(1,1+maxxshift):min(x,x+minxshift);
ny=length(keepRangeY);
nx=length(keepRangeX);

%initialize the matrix for the motion corrected movie
newmov=zeros(ny,nx,z,dataClass);

%if we are going to play the movie back, calculate the dynamic range of the
%movie so we can have a consistent colormap
if exist('fignum','var') && ~isempty(fignum)
    maxpixel=max(mov(:));
    minpixel=min(mov(:));
end

if verbose
    fprintf('applying motion correction... ')
end
    
%loop over frames
for i=1:z

    %extract the current frame
    thisframe=squeeze(mov(:,:,i));
    
    eval(sprintf('thisframe = %s(thisframe);',dataClass))

    % if any offsets are NaN, don't try to shift the frame
    if any(isnan(xoffsets(i))) || any(isnan(yoffsets(i)))
        thisframe_interp = thisframe;
    else
        %use linear interpolation to find the corrected movie at the standard
        %coordinates, given that the offsets are given relative to those
        %coordinates
        thisframe_interp=interp2((1:x)+xoffsets(i),((1:y)+yoffsets(i))',thisframe,1:x,(1:y)','*linear');
    end
   
    %save the result, clipping the edges as neccesary
    newmov(:,:,i)=thisframe_interp(keepRangeY,keepRangeX);

    %if playing back the movie, do so
    if exist('fignum','var') && ~isempty(fignum)

        figure(fignum);
        clf;
        imagesc(newmov(:,:,i));
        caxis([minpixel maxpixel]);
        colormap gray;
        %pause(.1);
    end
    %display your progress
    if mod(i,1000)==0 && verbose
        fprintf('%d, ',i)
    end
end

if verbose
    fprintf(' total of %d images\n',i)
end
