#!/usr/bin/perl -s
#*************************************************************************
#
#   Program:    tinker
#   File:       install.pl
#   
#   Version:    V1.0
#   Date:       26.04.22
#   Function:   Installation script for Tinker
#   
#   Copyright:  (c) UCL, Prof. Andrew C. R. Martin, 2022
#   Author:     Prof. Andrew C. R. Martin
#   Address:    Institute of Structural and Molecular Biology
#               Division of Biosciences
#               University College
#               Gower Street
#               London
#               WC1E 6BT
#   EMail:      andrew@bioinf.org.uk
#               
#*************************************************************************
#
#   This program is not in the public domain, but it may be copied
#   according to the conditions laid out in the accompanying file
#   COPYING.DOC
#
#   The code may be modified as required, but any modifications must be
#   documented so that the person responsible can be identified. If 
#   someone else breaks this code, I don't want to be blamed for code 
#   that does not work! 
#
#   The code may not be sold commercially or included as part of a 
#   commercial product except as described in the file COPYING.DOC.
#
#*************************************************************************
#
#   Description:
#   ============
#
#*************************************************************************
#
#   Usage:
#   ======
#   ./install.pl [-tinker=x.y.z]
#
#   Alter config.pm if you wish to install elsewhere
#
#*************************************************************************
#
#   Revision History:
#   =================
#   V1.0   26.04.22  Original based on old abYmod install
#
#*************************************************************************
use strict;
use Cwd qw(abs_path);

# Add the path of the executable to the library path
use FindBin;
use lib $FindBin::Bin;
use config;
use util;

UsageDie() if(defined($::h));

my $tinkerVersion = (defined($::tinker)?$::tinker:"7.1.3");

# Check binaries, libraries and includes
if(!BinLibIncludeOK())
{
    print <<__EOF;

Installation aborting. You must install wget, compilers and libxml2 
development libraries first:

CentOS/Fedora (as root):
   yum install wget gcc gfortran libxml2 libxml2-devel

Ubuntu:
   sudo apt-get wget gcc gfortran install libxml2 libxml2-dev

__EOF
    exit 1;
}

# Check that the destination is correct
if(!DestinationOK())
{
    print <<__EOF;

Installation aborting. Modify config.pm if you wish to install elsewhere.

__EOF
    exit 1;
}

# Create the installation directories and build the C programs
CreateDirs();
BuildPackages();
BuildTinker($tinkerVersion);

my $pwd = `pwd`;
chomp $pwd;
$pwd =~ s/\/$//;
$pwd = abs_path($pwd);

my $rd = $config::tinkerRoot;
chomp $rd;
$rd =~ s/\/$//;
$rd = abs_path($rd);

# If we are installing into somewhere other than the current directory,
# then install the programs and data
if($pwd ne $rd)
{
    InstallPrograms();
    PrintTinkerLicence(1);
}
else
{
    print STDERR <<__EOF;

Programs not installed as source and destination directories are the
same. i.e. You are trying to install to the current directory

__EOF
    PrintTinkerLicence(0);
}

#*************************************************************************
#> void PrintTinkerLicence()
#  -------------------------
#  Print information about the Tinker licence
#
#  26.04.22 Original   By: ACRM
#
sub PrintTinkerLicence
{
    my($copyFile) = @_;

    if($copyFile)
    {
        util::RunCommand("cp TinkerLicence.pdf $config::tinkerRoot");
    }

    print <<__EOF;

**************************************************************************
abYmod makes use of Tinker (Software Tools for Molecular Design) 
which is (c) Jay William Ponder, Department of Chemistry, Washington
University in Saint Louis, which has been downloadedfrom Ponder\'s web site
during the install.

This is free software, but you should complete the Tinker licence
file ($config::tinkerRoot/TinkerLicence.pdf) and return it to WUSTL.
**************************************************************************

__EOF
}


#*************************************************************************
#> void BuildTinker()
#  --------------------
#  Installs the Tinker Molecular Mechanics software
#
#  19.09.13  Original  By: ACRM
#  13.09.16  Added check that Tinker binaries were installed
sub BuildTinker
{
    my($version) = @_;

    if(!( -d "./tinker") || (!( -f "./tinker/bin/minimize")))
    {
        print STDERR "\n*** Building Tinker V$version - this will take a while! ***\n\n";
        util::RunCommand("./BuildTinker.sh $version", 1);
    }

    util::RunCommand("cp tinker/bin/* $config::bindir");
    `mkdir -p $config::tinkerParamDir`;
    util::RunCommand("cp tinker/params/* $config::tinkerParamDir");

    if((! -e "$config::bindir/pdbxyz") ||
       (! -e "$config::bindir/minimize") ||
       (! -e "$config::bindir/xyzpdb"))
    {
        Die("\nabYmod install failed. Tinker minimization package files were not installed.\n\n")
    }
}


#*************************************************************************
#> void InstallPrograms()
#  ----------------------
#  Installs all programs 
#
#  26.04.22  Original  By: ACRM
sub InstallPrograms
{
    util::RunCommand("cp RunTinker.pl config.pm $config::tinkerRoot");
}

#*************************************************************************
#> void BuildPackages()
#  --------------------
#  Build all C program packages
#
#  26.04.22  Original  By: ACRM
sub BuildPackages
{
    util::BuildPackage("./packages/tinkerpatch_V1.0.tgz", # Package file
                       "",                                # Subdir containing src
                       \["tinkerpatch"],                  # Generated executable
                       $config::bindir,                   # Destination binary directory
                       "",                                # Data directory
                       "");                               # Destination data directory

    util::BuildPackage("./packages/pdbhstrip_V1.4.tgz",   # Package file
                       "",                                # Subdir containing src
                       \["pdbhstrip"],                    # Generated executable
                       $config::bindir,                   # Destination binary directory
                       "",                                # Data directory
                       "");                               # Destination data directory

    util::BuildPackage("./packages/pdbrenum_V2.0.tgz",    # Package file
                       "",                                # Subdir containing src
                       \["pdbrenum"],                     # Generated executable
                       $config::bindir,                   # Destination binary directory
                       "",                                # Data directory
                       "");                               # Destination data directory
}


#*************************************************************************
#> sub CreateDirs()
#  ----------------
#  Create installation directories
#
#  26.04.22  Original  By: ACRM
sub CreateDirs
{
    util::RunCommand("mkdir -p $config::bindir");
}


#*************************************************************************
#> void UsageDie()
#  ---------------
#  Prints a usage message and exits
#
#  19.09.13  Original  By: ACRM
sub UsageDie
{
    print <<__EOF;

tinkerinstall (c) 2022, UCL, Prof. Andrew C.R. Martin

Usage: install.pl [-tinker=x.y.z]

install.pl installs tinker and scripts to make it easy to use

By default, Tinker will be installed in the current directory.
Edit config.pm if you wish to install elsewhere.

__EOF

   exit 0;
}


#*************************************************************************
#> BOOL DestinationOK()
#  --------------------
# Checks with the user if the installation destination is OK.
#
# 28.09.15 Original   By: ACRM
#
sub DestinationOK
{
    $|=1;
    print "tinker will be installed in $config::tinkerRoot\n";
    print "Do you wish to proceed? (Y/N) [Y] ";
    my $response = <>;
    chomp $response;
    $response = "\U$response";
    return(0) if(substr($response,0,1) eq "N");

    # Test we can write to the directory
    # Try to create it if is doesn't exist
    if(! -d $config::tinkerRoot)
    {
        system("mkdir -p $config::tinkerRoot 2>/dev/null");
    }
    # Fail if it doesn't exist
    if(! -d $config::tinkerRoot)
    {
        print STDERR "\n   *** Error: Cannot create installation directory ***\n";
        return(0);
    }
    # Fail if we can't write to it
    my $tFile = "$config::tinkerRoot/testWrite.$$";
    system("touch $tFile 2>/dev/null");
    if(! -e $tFile)
    {
        print STDERR "\n   *** Error: Cannot write to installation directory ***\n";
        return(0);
    }
    unlink $tFile;

    return(1);
}


#*************************************************************************
#> BOOL BinLibIncludeOK()
#  ----------------------
#  Returns:   Found?
#  
#  Checks for the presence of the libxml2 library and its include files
#  Checks for required executables
#
#  26.04.22  Original   By: ACRM
#
sub BinLibIncludeOK
{
    my @exes = ("wget", "gcc", "gfortran");
    my @dirs = ("/usr/bin", "/bin");
    
    print "\nChecking that libxml2 is installed...";
    if(util::CheckLibrary("libxml2.so") &&
       util::CheckInclude("libxml/parser.h") &&
       util::CheckInclude("libxml/tree.h"))
    {
        print "OK\n";

        print "Checking that @exes are installed...";
        if(util::CheckFilesExistInDirs(\@exes, \@dirs))
        {
            print "OK\n\n";
            return(1);
        }
    }

    return(0);
}
