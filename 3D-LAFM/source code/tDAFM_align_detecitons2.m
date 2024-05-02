%%%%%%
%%% Align 3D-LAFM density map
%%% Input: 
%%%        1: detections: AFM single-particle local maxima
%%%        2: detections_summary: unaligned LAFM detection pool
%%%        3: alignment: local expansion LAFM detection extraction
%%%        alignment information, matrix dimension: N-3
%%%        where N is the number of single-particle images, and the three 
%%%        columns are lateral alignment info (columns 1 and 2, unit: pixel)
%%%        and rotational alignment info (column 3, unit: degree)
%%%        4: scale: local expansion LAFM detection extraction scale factor
%%%        5: rawheight: a flag to use raw data height value. Default: 1
%%% Output:
%%%        1: detections_summary2: aligned LAFM detection pool
%%%%%%


function detections_summary2 = tDAFM_align_detecitons2(detections, detections_summary, alignment, scale, rawheight)
mid = size(detections)./2;
align_x = alignment(:, 2)./scale;
align_y = alignment(:, 1)./scale;
align_a = deg2rad(alignment(:, 3));

detections_summary2 = detections_summary(:, 1:4);
if rawheight
    detections_summary2(:, 3) = detections_summary(:, 15) + detections_summary(:, 12);
end
for i = 1:numel(align_a)
    sel = detections_summary(:, 4) == i;
    x = detections_summary(sel, 1) + align_x(i);
    y = detections_summary(sel, 2) + align_y(i);
    [theta, rho] = cart2pol(x - mid(1), y - mid(2));
    [x2, y2] = pol2cart(theta - align_a(i), rho);
    detections_summary2(sel, 1) = x2 + mid(1);
    detections_summary2(sel, 2) = y2 + mid(2);
end
end