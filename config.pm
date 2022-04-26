package config;
use strict;
#*************************************************************************
#                                                                        *
#        Root directory for Tinker install                               *
#                                                                        *
#        By default, Tinker will be installed within the directory       *
#        where you run this. If you wish to install elsewhere, change    *
#        this variable                                                   *
$config::tinkerRoot=`pwd`;
#
#*************************************************************************
#                                                                        *
#          You shouldn't need to change anything below here              *
#                                                                        *
#*************************************************************************
chomp $config::tinkerRoot;
# Location of data and binary files
$config::bindir = "$config::tinkerRoot/bin";
$config::dataDir="$config::tinkerRoot/DATA";

# Tinker parameter sets
$config::tinkerParamDir="$config::dataDir/tinkerParams";       
# We will use amber99 by default
$config::tinkerParams="amber99";                               
$config::tinkerParamFile="$config::tinkerParamDir/$config::tinkerParams";

