function [rainbowImage,extras] = computeRainbowSummary(obj,varargin)
% average in HSV space
% theta = position in image sequence (i.e. state in VR sequence)
% r = intensity of pixel at each theta
% These are taken as polar coordinates in the HS plane
%
% returns rainbow image, and theta, rho, and std in extras struct


p = inputParser;
p.addParamValue('removeMean','div',@(x)any(strcmpi(x,{'div','sub'})))
p.addParamValue('rhoPower',0.8)
p.addParamValue('stdPower',0.8)
p.addParamValue('rhoValue',0.5,@(x)x>=0&x<=1)
p.addParamValue('plot',[])
parse(p,varargin{:});



% put images into convenient variable name
ims = obj.images;

% note image count
nIms = size(ims,4);

% compute angle for each point in time course
thetas = linspace(0,2*pi,nIms+1);
thetas = thetas(1:end-1)';





% remove the mean
switch p.Results.removeMean
    case 'sub' % subtract mean
        %ims = ims -repmat(mean(ims,4),[1 1 1 nIms]);
        ims = normalizeToZeroOne(ims);
    case 'div' % divide by mean
        ims = ims./repmat(mean(ims,4),[1 1 1 nIms]);
        %ims = ims/max(reshape(ims,[],1));
    otherwise
        error('Mean removal ''%s'' not recognized.',p.Results.removeMean)
end




switch 1
    
    case 1  % vectorized version of computation
        
        % put thetas into 4th dimension...
        thetas = permute(thetas,[4 2 3 1]);
        % ...at every pixel
        thetas = repmat(thetas,size(ims(:,:,:,1)));
        
        % convert polar coordinates to x-y coordinates
        % treat image intensity as rho value in polar coordinates
        [X,Y] = pol2cart(thetas,ims);
        
        % take vector average, and convert back to HSV space
        [theta,rho] = cart2pol(sum(X,4),sum(Y,4));
        
        % compute std
        stdDev = std(ims,[],4);
        
        % save to extras struct
        extras.theta = 0.5+theta/(2*pi);
        extras.rho = rho;
        extras.std = stdDev;
        
        % adjust "gamma"
        rho = normalizeToZeroOne(rho.^p.Results.rhoPower);
        %rho = rho/max(reshape(rho,[],1)); rho = rho.^.8;
        stdDev = normalizeToZeroOne(stdDev.^p.Results.stdPower);
        
        % initialize HSV image
        hsvImage = zeros(size(ims,1),size(ims,2),3);
        
        % hue <- theta
        hsvImage(:,:,1) = 0.5+theta/(2*pi);
        % saturation <- rho
        hsvImage(:,:,2) = 0.5+.5*rho;%
        % value <- mix of standard deviation and rho
        hsvImage(:,:,3) = rho*p.Results.rhoValue + stdDev*(1-p.Results.rhoValue);
        
        % convert from HSV space to RGB space
        rainbowImage = hsv2rgb(hsvImage);
        
        
        
        % DEBUG
        
        if 0
            
            % show rho values
            figure(1);clf;
            subplot(221);h = polar(reshape(theta,[],1),reshape(rho,[],1),'.r');
            set(h,'Markersize',3)
            hold on
            angs = linspace(0,1,200)';
            cols = hsv2rgb([angs repmat([1 1],200,1)]);
            for cc=1:size(cols,1)
                h = polar(angs(cc)*2*pi,1,'.');
                set(h,'Color',cols(cc,:))
            end
            subplot(222);hist(reshape(rho,[],1),30)
            subplot(223);plot(reshape(rho,[],1),reshape(stdDev,[],1),'.','Markersize',3);
            xlabel('rho');ylabel('std dev')
            
        end
        
        
        
        
        
    case 2  % pixel by pixel, slow but allows easier debugging
        
        all_theta = [];
        all_rho = [];
        
        % initialize output
        rainbowImage = zeros(size(ims,1),size(ims,2),3);
        
        % for each pixel
        for ii=1:size(ims,1)
            for jj=1:size(ims,2)
                % get time course
                tc = squeeze(ims(ii,jj,1,:));
                
                % convert to polar coordinates in the
                rs = tc;
                
                % convert polar coordinates to x-y coordinates
                [X,Y] = pol2cart(thetas,rs);
                
                % take mean activation, and convert back to HSV space
                [theta,rho] = cart2pol(sum(X),sum(Y));
                
                
                if (ii==23 && jj==95)% || (ii==6 && jj==61);
                    figure%(1);clf;
                    polar(thetas,rs,'.')  % plot value in all directions
                    hold on
                    polar([0 theta],[0 rho],'r')  % plot vector average
                    title(sprintf('row %d, col %d',ii,jj))
                    pause;
                end
                
                %rho = (rho*15).^.6;
                
                % and finally to RGB space
                rainbowImage(ii,jj,:) = hsv2rgb([ 0.5+theta/(2*pi) 0.5+0.5*rho rho ]);
                
                all_theta = [all_theta theta];
                all_rho = [all_rho rho];
                
            end
        end
        
        %figure(1);clf;polar(all_theta,all_rho,'.')
        
end


% plot if desired
if ~isempty(p.Results.plot)
    h = parsePlotSpec(p.Results.plot);
    cla(h)
    image(rainbowImage,'Parent',h)
end





if 0
    
    % "significance" map
    figure(fig+4);clf;colormap gray
    switch 2
        case 1 % maximum deviation from mean
            nm = avg_ims./repmat(avg_im,[1 1 size(avg_ims,3)]);
            sig_map = max(sqrt(abs(nm-1)),[],3);
        case 2 % std of deviation from mean
            sig_map = std(mov,[],3).^.5;
    end
    
    
    % choose colors
    cols = jet(nIms);
    
    % normalize ims
    imsMax = max(reshape(ims,[],1));
    imsMin = min(reshape(ims,[],1));
    ims = (ims-imsMin)/(imsMax-imsMin);
    
    % sum images weighted by color
    for ii=1:nIms
        for cc=1:3
            rainbowImage(:,:,cc) = rainbowImage(:,:,cc) + cols(ii,cc)*ims(:,:,:,ii);
        end
    end
    
end

