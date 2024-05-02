%%% make 3D kernel for 3D LAFM
%%% para: 
%%% size: size of the kernel, must be an odd number
%%% sigma: sigma for the 3D gaussian kernel
function h = make_3D_LAFM_kernel1a(sigma_xy, sigma_z)
size_xy = sigma_xy * 6 + 1;
size_xy = 2*floor(size_xy/2) + 1;
mid_xy = (size_xy+1)/2;
size_z = sigma_z * 6 + 1;
size_z = 2*floor(size_z/2) + 1;
mid_z = (size_z+1)/2;

[xx, yy, zz] = meshgrid(1:size_xy, 1:size_xy, 1:size_z);
%%% normal distribution in x and y directions
hx = 1/(sigma_xy*sqrt(2*pi)) .* exp(-0.5.*((xx - mid_xy)./sigma_xy).^2);
hy = 1/(sigma_xy*sqrt(2*pi)) .* exp(-0.5.*((yy - mid_xy)./sigma_xy).^2);
%%% normal distribution in the z direction
hz = 1/(sigma_z*sqrt(2*pi)) .* exp(-0.5.*((zz - mid_z)./sigma_z).^2);

%%% combine
h = hx.*hy.*hz;
%%% normalize to 1
h = h ./ sum(h(:));
end