function nii_displacement = calc_unwarp_displacement(nii, config_name)
% calc_unwarp_displacement
%
% inputs:
%   nii: nii structure
%   config_name: gradient configuration
%
% outputs:
%   nii_displacement: nii file to be used in FSL-applywarp
    
    if nargin < 2
        config_name = 'GCT_WA_MRL';
    end

    % Affines
    % notation:
    %   aff_ABC_XYZ multiplies a vector in ABC space
    %   returns vector in XYZ space
    aff_ijk_ras = [nii.hdr.srow_x; nii.hdr.srow_y; nii.hdr.srow_z; 0 0 0 1];

    % ijk space = voxel coordinates in nii file
    % xyz space = ALS for head-first, supine
    % See gyrotools manual.

    % Need variable to specify patient orientation.
    % This is valid for head first, supine.
    % Is this in the .sin file?
    aff_ras_als = [ 0  1  0  0; ...
                   -1  0  0  0; ...
                    0  0  1  0; ...
                    0  0  0  1];

    aff_ras_xyz = aff_ras_als;                
    aff_ijk_xyz = aff_ras_xyz * aff_ijk_ras;

    ni = size(nii.img, 1);
    nj = size(nii.img, 2);
    nk = size(nii.img, 3);
    [ii, jj, kk] = ndgrid( [0:ni-1], [0:nj-1], [0:nk-1] );
    % convert (ii,jj,kk) to (xx,yy,zz):
    ijk_stack = cat(4,ii,jj,kk,ones(size(ii)));
    ijk_stack = permute(ijk_stack, [4 1 2 3]);

    xyz_stack = aff_ijk_xyz * ijk_stack(:,:);
    xx = reshape(xyz_stack(1, :), size(ii));
    yy = reshape(xyz_stack(2, :), size(ii));
    zz = reshape(xyz_stack(3, :), size(ii));

    % calculate spherical harmonic coordinates
    [r, theta, phi] = r_cart2sph(xx, yy, zz);

    [F_x, F_y, F_z] = expand_gradient_basis(r, theta, phi, config_name);

    % Displacements (mm)
    d_x = F_x - xx;
    d_y = F_y - yy;
    d_z = F_z - zz;
    d = cat(4, d_x, d_y, d_z);

    % Transform xyz displacement, back to ijk space
    rot_ras_xyz = aff_ras_xyz(1:3, 1:3);
    rot_xyz_ras = inv(rot_ras_xyz);
    rot_xyz_ijk = inv(aff_ijk_xyz(1:3, 1:3));

    d = permute(d, [4 1 2 3]);
    d = rot_xyz_ijk * d(:,:);

    % Scale to mm displacements in ijk space.
    % FSL-applywarp seems to expect axis 1 to be reversed.
    % Below is equivalent:
    %d(1,:) = d(1,:) * nii.hdr.pixdim(2);
    %d(2,:) = d(2,:) * nii.hdr.pixdim(3);
    %d(3,:) = d(3,:) * nii.hdr.pixdim(4);
    %d(1,:) = -d(1,:);
    scale_pixdim_ijk = diag(nii.hdr.pixdim(2:4));
    scale_pixdim_ijk(1,1) = -scale_pixdim_ijk(1,1);
    d = scale_pixdim_ijk * d; 

    d = reshape(d, [3 size(d_x)]);
    d = permute(d, [2 3 4 1]);

    nii_displacement = nii;
    nii_displacement.img = d;
