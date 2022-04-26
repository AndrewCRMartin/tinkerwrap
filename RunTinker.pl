#!/usr/bin/perl
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

# Set executables
my $pdbhstrip   = "$config::bindir/pdbhstrip";
my $pdbrenum    = "$config::bindir/pdbrenum";
my $tinkerpatch = "$config::bindir/tinkerpatch";
my $pdbxyz      = "$config::bindir/pdbxyz";
my $minimize    = "$config::bindir/minimize";
my $xyzpdb      = "$config::bindir/xyzpdb";

# Main program
my $pdbfile     = shift(@ARGV);

# Work out the base filename
my $basefile = $pdbfile;
$basefile =~ s/^.*\///;  # Remove the path
$basefile =~ s/\.pdb$//; # Remove the extension
$basefile =~ s/\.ent$//; # Remove the extension

# Clean up and exiting files
`rm -f $basefile.xyz* $basefile.pdb_* $basefile.seq* foo.*`;

# Create filenames for new files
my $seqfile      = "$basefile.seq";
my $xyzfile      = "$basefile.xyz";
my $xyz2file     = "${xyzfile}_2";
my $resultfile   = "${basefile}_result.pdb";
my $cleanpdbfile = "$basefile.pdc";

# Run pdbrenum without renumbering to remove alternate occupancies
`$pdbrenum -n -d $pdbfile $cleanpdbfile`;

# Convert to xyz
system("$pdbxyz $cleanpdbfile ALL ALL $config::tinkerParamFile");

# Cartesian energy minimization
system("$minimize $xyzfile $config::tinkerParamFile 2");

# Convert results to pdb
`cp $xyz2file foo.xyz`;
`cp $seqfile  foo.seq`;
`$xyzpdb foo.xyz $config::tinkerParamFile`;
`$tinkerpatch $cleanpdbfile foo.pdb | $pdbhstrip > $resultfile`;

# Remove intermediate files
`rm -f foo.xyz foo.seq foo.pdb`;
`rm $xyzfile $xyz2file $seqfile $cleanpdbfile`;
