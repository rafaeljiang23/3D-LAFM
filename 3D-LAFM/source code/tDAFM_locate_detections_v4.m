%%%%%%
%%% Local expansion LAFM detection extraction
%%% Input: 
%%%        1: detections: AFM single-particle local maxima
%%%        2: data: AFM raw single-particle data
%%%        3: scale: local expansion LAFM detection extraction scale factor
%%%        4: showprogress: a flag to show progress. Default: 1
%%% Output:
%%%        1: detections_summary: unaligned LAFM detection pool
%%%%%%


function detections_summary = tDAFM_locate_detections_v4(detections, data, scale, showprogress)
%%
[d1, d2, d3] = size(detections);
[X, Y, Z] = ndgrid(1:d1, 1:d2, 1:d3);
num_detections = sum(~isnan(detections(:)));
detections_summary = zeros(num_detections, 16);
sel = ~isnan(detections);
detections_x = X(sel);
detections_y = Y(sel);
detections_z = Z(sel);
% radius = 10;   % 0622
radius = 2;
z_min = min(data(:));
data = data - z_min;
frame = zeros(d1 + 2 * radius, d2 + 2*radius);
for i = 1:num_detections
    if showprogress
    i + "/" + num_detections
    end
    xi = detections_x(i);  
    yi = detections_y(i);
    zi = detections_z(i);
    frame(radius+1:end-radius, radius+1:end-radius) = squeeze(data(:, :, zi));
%     xx_roi = max([1 xi-radius]): min([d1 xi+radius]);
%     yy_roi = max([1 yi-radius]): min([d2 yi+radius]);
%     xx_roi = xi-radius : xi+radius;
%     yy_roi = yi-radius : yi+radius;
    xx_roi = xi : xi + 2*radius;
    yy_roi = yi : yi + 2*radius;
    zz = frame(xx_roi, yy_roi);  %% ideally 5x5
    try
        fitresult = tDAFM_bicubic(zz, scale);   % [amp, ang, sx, sy, xo, yo, zo]
        detections_summary(i, 1) = xi + fitresult(1)/scale - radius-1;
        detections_summary(i, 2) = yi + fitresult(2)/scale - radius-1;
        detections_summary(i, 3) = fitresult(3) + z_min; 
        detections_summary(i, 4) = zi;   % particle number
        detections_summary(i, 5:8) = fitresult;
        detections_summary(i, 12) = z_min;
        detections_summary(i, 13) = xi;
        detections_summary(i, 14) = yi;
        detections_summary(i, 15) = data(xi,yi,zi);
        detections_summary(i, 16) = nan;
    catch ME
        warning('Error found in detection allocation...  Assigning a value of nan.');
        detections_summary(i, 1) = xi;
        detections_summary(i, 2) = yi;
        detections_summary(i, 3) = data(xi,yi,zi);
        detections_summary(i, 4) = zi;
        detections_summary(i, 5:8) = nan;
        detections_summary(i, 12) = z_min;
        detections_summary(i, 13) = xi;
        detections_summary(i, 14) = yi;
        detections_summary(i, 15) = data(xi,yi,zi);
        detections_summary(i, 16) = nan;
    end
end
% detections_summary(:, 3) = detections_summary(:, 3) + z_min;
% data = data + z_min;
end


function fitresult = tDAFM_bicubic(zz, scale)
sz = size(zz);
% sz_mid = floor((sz - 1)/2);  %-！
sz2 = 2*floor(sz * scale / 2) + 1;
sz2_mid = floor((sz2 - 1)/2);
zz_resize = imresize(zz, sz2, "bicubic");
% hei_mid = zz(sz_mid(1), sz_mid(2));
zz_resize_max = imregionalmax(zz_resize, 4);
[row, col] = find(zz_resize_max);
hei = zz_resize(zz_resize_max);
dist = (row - sz2_mid(1)).^2 + (col - sz2_mid(2)).^2;
% sel = abs(row - sz2_mid(1)) < scale & abs(col - sz2_mid(2)) < scale;
% sel = dist < (scale + 0.5)^2;
% hei(~sel) = nan;
% [~, idx] =  max(hei);
% if isnan(hei(idx))
%     [~, idx] =  min(dist);
% end
[~, idx] =  min(dist);
fitresult(1) = row(idx);
fitresult(2) = col(idx);
fitresult(3) = hei(idx);
fitresult(4) = dist(idx);
end