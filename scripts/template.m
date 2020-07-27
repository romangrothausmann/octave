#!/usr/bin/octave -q
##script to execute imEuler3d from http://in.mathworks.com/matlabcentral/fileexchange/33690-geometric-measures-in-2d-3d-images


file_path = fileparts(mfilename('fullpath')); # https://stackoverflow.com/questions/50151829/how-do-i-get-the-current-script-path-in-gnu-octave#50151830
addpath([file_path "/../functions/"]); # https://octave.org/doc/v4.4.0/Concatenating-Strings.html
addpath([file_path "/../functions/imMinkowski/"]);

arg_list = argv ();
if nargin != 2
  fprintf(stderr, "Usage: %s <input3D.mha> arg1 \n", program_name);
  fprintf(stderr, "Decompressing MHAs/MHDs is very slow!\n");
  exit(1)
else
  fprintf(stderr, "Reading 3D data from %s ...\n", arg_list{1});
  i3dInfo= mha_read_header(arg_list{1});#from ../functions/
  fprintf(stderr, "ElementSize: %f, %f, %f\n", i3dInfo.PixelDimensions);
  i3d= mha_read_volume(i3dInfo);#from ../functions/
  fprintf(stderr, "Reading done.\n", arg_list{1});
  fprintf(stderr, "Image size: %d %d %d\n", size(i3d))
  # if nargin == 2
  #   if (arg_list{2} == "-q")
  #     quiet= 1;
  #   endif
  # endif
endif

if ndims(i3d) ~= 3
  error('Image has to be 3D!');
end

arg1= str2num(arg_list{2})

printf("res: %f\n", imFunction(i3d, ))



