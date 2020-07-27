#!/usr/bin/octave -q
## script to calc Euler-Poincare Characteristic (EPC|chi) of a fiji labeled skeleton
## removing one branch in each run
## imEuler3d: http://in.mathworks.com/matlabcentral/fileexchange/33690-geometric-measures-in-2d-3d-images

file_path = fileparts(mfilename('fullpath')); # https://stackoverflow.com/questions/50151829/how-do-i-get-the-current-script-path-in-gnu-octave#50151830
addpath([file_path "/../functions/"]); # https://octave.org/doc/v4.4.0/Concatenating-Strings.html
addpath([file_path "/../functions/imMinkowski/"]);
pkg load image

arg_list = argv ();
if nargin != 1
  fprintf(stderr, "Usage: %s <fiji_labeled-skel.mha>\n", program_name);
  fprintf(stderr, "Decompressing MHAs/MHDs is very slow!\n");
  exit(1)
else
  fprintf(stderr, "Reading 3D data from %s...\n", arg_list{1});
  i3d= mha_read_volume(arg_list{1});#from ../functions/
  # if nargin == 2
  #   if (arg_list{2} == "-q")
  #     quiet= 1;
  #   endif
  # endif
endif

info= mha_read_header(arg_list{1})
info.BitDepth

#[i,j,v]=find(i3d); #find non-zero values
#unique(v) #list occuring non-zero values
unique(i3d)#list all occuring values

#i3d= cat(3,zeros(size(i3d(:,:,1))), i3d); #pad with zero 2D image

conn= 26;

#chi= imEuler3d(i3d, conn);
#printf("chi(%d)= %d\n", conn, chi)

nodesI= i3d == 70;
branchesI= i3d == 127;

chi0= imEuler3d(branchesI + nodesI, conn);#branchesI and nodesI are always disjunct!
printf("chi(%d)= %d\n", conn, chi0)

[labelI, maxl]= bwlabeln(branchesI, conn);

cc= 1;
for i=0:maxl
  thrI= labelI & (labelI <= (maxl-i)); #make sure pixel value 0 is excluded!!!
  redI= thrI + nodesI; #only then are thrI and nodesI always disjunct!!!

  [labelIn, cc]= bwlabeln(redI, conn);
  # if tcc > 1
  #   cc+= tcc - 1;
  #   printf("%6d: tcc(%d)= %6d\n", i, conn, tcc)
  # endif

  chi= imEuler3d(redI, conn);
  #chi= imEuler3d(thrI | nodesI, conn);

  nloops= cc - chi;
  printf("%6d: chi(%d)= %6d; cc= %6d;  nloops= %6d\n", i, conn, chi, cc, nloops )

  if nloops + i != cc - chi0 #chi0 is expected to be from a single cc
     printf("nloops + i != cc - chi0\n")
   endif

  fflush(stdout);
end
