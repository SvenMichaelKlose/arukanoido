C2NWARP VIC-20 tape loader
==========================

Author: Sven Michael Klose <pixel@hugbox.org>

# Overview

This loader has been designed with focus on realiability
and to make recordings last as well as reasonable speed.

# Format

CN uses three pulse widths, short, medium and long.
Medium and long pulses are of double and triple widths
of the short pulse.  Short pulses are used to encode unset
bits and medium pulses represent bits set to 1.  Long
pulses are used to synchronize the timing.

## Leader

Each data block starts with a leader of 128 triples, each
being a sequence of a long, short and medium pulse.  At
least 64 of them must be read properly before a block can
start.  The data block is introduced with the sequence
long, short, short.

## Data block

The size of the data block must be know by the loader.
Each byte starts with a long pulse followed by eight short
or medium sized pulses.

## Trailer

The optional trailer protects the last bits of the block
from distortion.  It should contain a series of any pulses
preferable of the same width.  By default the trailer is
made of 32 long pulses.  It is extended to the next leader
if another data block folllows.
