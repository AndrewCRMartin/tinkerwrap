TinkerWrap
==========

(c) 2022, UCL, Prof. Andrew C.R. Martin
---------------------------------------

Script to download and install Tinker and provides a simple wrapper
script to run a cartesian energy minimization on a PDB file.

### Copyright Information

This code is freely distributable. Tinker itself now requires you to
register and commercial use requires payment of a commercial licence
fee.

### Installation

Simply run the installscript: `./install.pl`

Optionally you can add `-tinker=x.y.z` to install a different version.

This will install everything in the current directory. If you wish to
install elsewhere, edit the `config.pm` file to specify the
installation location.

### Running

Simply run `RunTinker` (specifying the path as needed) followed by a
PDB file to be minimized.

This cleans up multiple occupancies, does the conversion to Tinker xyz
format, runs the minimization and converts back to PDB, stripping
hydrogens and patching back the chain labels and residue numbers.

