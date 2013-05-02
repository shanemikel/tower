# [Tower][tower]

## About

Tower is an an Architectural Description Language (ADL) for the [Ivory language][ivory].
It is a system for composing Ivory programs into applications using tasks,
shared state, and synchronous channels.

At the moment, Tower includes a backend targeting the [FreeRTOS][freertos]
operating system.

## Installing

Tower should be installed in a cabal-dev sandbox along with the [Ivory
language repository][ivory].

The c library `ivory_freertos_wrapper` is required for as a shim between code
generated by the FreeRTOS backend with the FreeRTOS kernel. We need this in
order to change the FreeRTOS primitive types into types that exist in the Ivory
language.

XXX: This c code is not yet included in this repository. need to find a way to repackage
it outside of the smaccmpilot repo...


## Sample Tower Application

A sample tower application can be found at
`ivory-tower/src/Ivory/Tower/Test/FooBarTest.hs` ([github][foobartest])
and a sample for building `FooBarTest` for FreeRTOS is found at
`ivory-tower-freertos/examples/Main.hs` ([github][foobarmain]).

## Using Tower

XXX I should write a basic user guide...

## Copyright and license
Copyright 2013 [Galois, Inc.][galois]

Licensed under the BSD 3-Clause License; you may not use this work except in
compliance with the License. A copy of the License is included in the LICENSE
file.

[ivory]: http://github.com/GaloisInc/ivory
[tower]: http://github.com/GaloisInc/tower
[freertos]: http://freertos.org
[galois]: http://galois.com

[foobartest]: https://github.com/GaloisInc/tower/blob/master/ivory-tower/src/Ivory/Tower/Test/FooBarTower.hs
[foobarmain]: https://github.com/GaloisInc/tower/blob/master/ivory-tower-freertos/examples/Main.hs
