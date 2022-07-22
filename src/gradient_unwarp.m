function [out, nii_displacement] = gradient_unwarp(nii, config_name, warp_flag)
% gradient_unwarp
%
% inputs:
%   nii: nii structure
%   config_name: gradient configuration
%   warp_flag: default is false. take unwarped image and return warped version.
%
% outputs:
%   out: unwarped image structure
%   nii_displacement: displacement field, in FSL convention
    
    if nargin < 2 | isempty(config_name)
        config_name = 'GCT_WA_MRL';
    end

    if nargin < 3 | isempty(warp_flag)
        warp_flag = false;
    end

    temp_datadir = tempname;
    [~,~,~] = mkdir(temp_datadir);

    temp_infile = fullfile(temp_datadir, 'in.nii.gz');
    temp_warpfile = fullfile(temp_datadir, 'warp.nii.gz');
    temp_outfile = fullfile(temp_datadir, 'out.nii.gz');

    nii_tool('save', nii, temp_infile);

    nii_displacement = calc_unwarp_displacement(nii, config_name);

    if warp_flag
        nii_displacement.img = -nii_displacement.img;
    end

    nii_tool('save', nii_displacement, temp_warpfile);

    cmd = ['applywarp -i ' temp_infile ' -r ' temp_infile ' -o ' temp_outfile ' -w ' temp_warpfile ' --interp=spline -v'];
    system(cmd);

    out = nii_tool('load', temp_outfile);

    % cleanup
    rmdir(temp_datadir, 's');
   
