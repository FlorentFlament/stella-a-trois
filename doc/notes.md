Dots plane shapes
=================

Inspired by:
* Genesis Project - Egypt 2600 BC
* Noice - Liquid Candy
* Noice - Sphaera Stellarum

Technical constraints
=====================
* Resolution is officially 160x228 on a PAL TV screen.
* 1 dot per line

What
====

A plane shape is the shape (or outline) of a (2D) object. Though since
we are constrained to 1 dot per line, we can display 1 dot out of 2 of
each side, resulting in a dot line.

If we are considering 64 dots (i.e 64 2-pixels lines), this sums up to
128 pixel (i.e 56% of the screen's height). Letting some space for
graphics.

To have a square zone for the object, a 64x64 zone can be used. Each
dot is characterized by its 6-bits position. Without compression, a
shape weights 64 bytes (i.e 1.6% of 4KB).



The engine
==========

A dot can be encoded in polar coordinates (length, angle). Since the
shapes are 2D shapes, only 2 angles are possible 0 and pi. Therefore a
dot coordinates can be expressed as follows:

bit 0-4 : [0-31] dot length (distance to the origin)
bit 5: 0 for 0 radians, 1 for pi radians

We can then compute the polar coordinates like this:
length =  dot & 0x1f       in [0-31]
angle  = (dot & 0x20) >> 1 in [0-31]

Then we can increase/decrease the angle to have the shape rotate in
3D.



Sizes
=====

* Alphabet (* 32 8) = 256 Bytes

* Music = 1024 Bytes

* 3D engine data = 1024 Bytes

* Graphix = (* (- (- 228 128) 16) 8) 672 Bytes


Cylindrical shapes
==================

Data
----

* The outline of our cylindrical objects
* One dot per line
* The dot's value is the distance of the outline from the center of the cylinder

Engine
------

* 16 discs corresponding to 16 possible distances from the center
* 1 (half) cos table per disc diameter
* 32 values per cos table

Algorithm
---------

For each dot:
* The dot norm allows selecting a 'disc' (out of 16 discs)
* The dot angle is updated with the current rotation value (global)
* The rotated dot angle is looked up into the disc table to find the appropriate position

