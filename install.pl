#!/usr/bin/perl -s
#*************************************************************************
#
#   Program:    tinker
#   File:       install.pl
#   
#   Version:    V1.20
#   Date:       11.12.17
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
# Or if we have a bin directory and a lib directory
#use FindBin;
#use lib abs_path("$FindBin::Bin/../lib");
use config;
use util;

UsageDie() if(defined($::h));

my $tinkerVersion = (defined($::tinker)?$::tinker:"7.1.3");

# Check librarues and includes
if(!LibAndIncludeOK())
{
    print <<__EOF;

Installation aborting. You must install libxml2 development libraries first:

CentOS/Fedora (as root):
   yum install libxml2 libxml2-devel

Ubuntu:
   sudo apt-get install libxml2 libxml2-dev

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
InstallTinker($tinkerVersion);

my $pwd = `pwd`;
chomp $pwd;
$pwd =~ s/\/$//;
$pwd = abs_path($pwd);

my $rd = $config::abymodRoot;
chomp $rd;
$rd =~ s/\/$//;
$rd = abs_path($rd);

# If we are installing into somewhere other than the current directory,
# then install the programs and data
if($pwd ne $rd)
{
    InstallPrograms(0);
}
else
{
    InstallPrograms(1);

    print STDERR <<__EOF;

Programs not installed as source and destination directories are the
same. i.e. You are trying to install to the current directory

__EOF
}

PrintTinkerLicence();

#*************************************************************************
#> void PrintTinkerLicence()
#  -------------------------
#  Print information about the Tinker licence
#
#  28.09.15 Original   By: ACRM
#
sub PrintTinkerLicence
{
    util::RunCommand("cp TinkerLicence.pdf $config::abymodRoot");

    print <<__EOF;

**************************************************************************
abYmod makes use of Tinker (Software Tools for Molecular Design) 
which is (c) Jay William Ponder, Department of Chemistry, Washington
University in Saint Louis, which has been downloadedfrom Ponder\'s web site
during the install.

This is free software, but you should complete the 'TinkerLicence.pdf' 
file and return it to WUSTL.
**************************************************************************

__EOF
}


#*************************************************************************
#> void InstallTinker()
#  --------------------
#  Installs the Tinker Molecular Mechanics software
#
#  19.09.13  Original  By: ACRM
#  13.09.16  Added check that Tinker binaries were installed
sub InstallTinker
{
    my($version) = @_;

    if(!( -d "./tinker") || (!( -f "./tinker/bin/minimize")))
    {
        print STDERR "\n*** Building Tinker V$version - this will take a while! ***\n\n";
        util::RunCommand("./optimization/InstallTinker.sh $version", 1);
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
#  Installs all programs and data required by them
#
#  19.09.13  Original  By: ACRM
#  15.09.15  Now copies static data files from STATICDATA instead of
#            from DATA
#  01.10.15  Added $dataOnly parameter
#  30.10.15  Moved copying of data outside check on directory
#  14.12.16  Added chmod to ensure all data files are readable
sub InstallPrograms
{
    my($dataOnly) = @_;

    if(!$dataOnly)
    {
        util::RunCommand("cp -p *.pl *.pm INSTALL.md $config::abymodRoot");
    }

    my $dir=util::GetDir($config::scOrderFile);
    if(! -d $dir)
    {
        `mkdir -p $dir`;
    }
    util::RunCommand("cp -p STATICDATA/sc/* $dir");

    $dir=util::GetDir($config::mdmFile);
    if(! -d $dir)
    {
        `mkdir -p $dir`;
    }
    util::RunCommand("cp -p STATICDATA/mdm/* $dir");
    util::RunCommand("chmod -R a+r $dir");
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
}



#*************************************************************************
#> sub CreateDirs()
#  ----------------
#  Create installation directories
#
#  19.09.13  Original  By: ACRM
sub CreateDirs
{
    my $dir;
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

      !!!  YOU MUST EDIT config.pm BEFORE USING THIS SCRIPT  !!!

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
        system("mkdir $config::tinkerRoot 2>/dev/null");
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
#> BOOL LibAndIncludeOK()
#  ----------------------
#  Returns:   Found?
#  
#  Checks for the presence of the libxml2 library and its include files
#
#  13.09.16  Original   By: ACRM
#
sub LibAndIncludeOK
{
    print "\nChecking that libxml2 is installed...";
    if(util::CheckLibrary("libxml2.so") &&
       util::CheckInclude("libxml/parser.h") &&
       util::CheckInclude("libxml/tree.h"))
    {
        print "OK\n\n";
        return(1);
    }

    return(0);
}
