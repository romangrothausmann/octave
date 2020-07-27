#!/usr/bin/octave -q
##script to execute imEuler3d from http://in.mathworks.com/matlabcentral/fileexchange/33690-geometric-measures-in-2d-3d-images


file_path = fileparts(mfilename('fullpath')); # https://stackoverflow.com/questions/50151829/how-do-i-get-the-current-script-path-in-gnu-octave#50151830
addpath([file_path "/../functions/"]); # https://octave.org/doc/v4.4.0/Concatenating-Strings.html
addpath([file_path "/../functions/imMinkowski/"]);

arg_list = argv ();
if nargin != 1
  fprintf(stderr, "Usage: %s <input3D.mha>\n", program_name);
  fprintf(stderr, "Decompressing MHAs/MHDs is very slow!\n");
  exit(1)
else
  fprintf(stderr, "Reading 3D data from %s ...", arg_list{1});
  i3d= mha_read_volume(arg_list{1});#from ../functions/
  fprintf(stderr, " done.\n", arg_list{1});
  printf("Image size: %d %d %d\n", size(i3d))
  # if nargin == 2
  #   if (arg_list{2} == "-q")
  #     quiet= 1;
  #   endif
  # endif
endif

##pad with zero in all directions, could use padarray from pkg image
##commented, as this doubles the memory peak, better done by ITK
# i3d_padded= zeros(size(i3d)+2);
# i3d_padded(2:end-1,2:end-1,2:end-1)= i3d;
# i3d= i3d_padded;
# printf("Image size: %d %d %d (after padding with 0)\n", size(i3d))

#printf("dim= %d\n", ndims(i3d))
printf("EPC(26)= %d\n", imEuler3d(i3d, 26))
#printf("EPC(6)= %d\n", imEuler3d(i3d, 6))



