function out = gradient_unwarp(nii, config_name)
% gradient_unwarp
%
% inputs:
%   nii: nii structure
%   config_name: gradient configuration
%
% outputs:
%   nii: unwarped image structure
    
    if nargin < 2
        config_name = 'GCT_WA_MRL';
    end

    temp_datadir = tempname;
    [~,~,~] = mkdir(temp_datadir);

    temp_infile = fullfile(temp_datadir, 'in.nii.gz');
    temp_warpfile = fullfile(temp_datadir, 'warp.nii.gz');
    temp_outfile = fullfile(temp_datadir, 'out.nii.gz');

    nii_tool('save', nii, temp_infile);

    nii_displacement = calc_unwarp_displacement(nii, config_name);
    nii_tool('save', nii_displacement, temp_warpfile);

    cmd = ['applywarp -i ' temp_infile ' -r ' temp_infile ' -o ' temp_outfile ' -w ' temp_warpfile ' --interp=spline -v'];
    system(cmd);

    out = nii_tool('load', temp_outfile);

    % cleanup
    rmdir(temp_datadir, 's');
   
