# Semantic Versioning D Library

* Author: Jonathan M. Wilbur
* Copyright: Jonathan M. Wilbur
* License: [Boost License 1.0](http://www.boost.org/LICENSE_1_0.txt)
* Publication Year: 2017

This is a library for strongly-typed Semantic Version identifiers. If you just
want an array of numbers with no safeguards, this is not the library for you.
This library follows the specifications for semantic versioning exactly, as
found at [The Official SemVer website](http://semver.org/).

# Usage

The `SemanticVersion` (aliased as `SemVer`) type has two constructors.
The first accepts only three _unsigned_ integers, and cannot throw an
exception. The second accepts three _unsigned_ integers, then
two strings containing dot-delimited pre-release identifiers and build
identifiers respectively. These identifiers may contain only ASCII
alpha-numerics and the hyphen '-'. If you violate those constraints,
a `SemanticVersionException` (aliased as `SemVerException`) will be
thrown by the constructor.

```d 
// Version 1.0.0
SemVer sv1 = new SemVer(1u, 0u, 0u);

// Version 1.0.0-alpha.rc2+x86-64.linux
SemVer sv2 = new SemVer(1u, 0u, 0u, "alpha.rc2", "x86-64.linux");
```

Once you have a SemVer object, you cannot directly manipulate the version
number components. This is to prevent developers from developing code that
can incorrectly incrementing version numbers. Instead, you may call
methods to increment the version, like so:

```d
SemVer sv1 = new SemVer(1u, 2u, 3u);

sv1.incrementMajorNumber();
// Now Version is 2.0.0
// (Notice that the minor and patch #s reset.)

sv1.incrementPatchNumber();
// Now version is 2.0.1

sv1.incrementMinorNumber();
// Now version is 2.1.0

```

If you create a `SemanticVersion`, then later decide that you want to append
pre-release or build identifiers, you may do so, but as in the constructor,
they may only contain ASCII alpha-numeric characters and a hyphen, or they will
throw an `SemanticVersionException`.

```d
SemVer sv1 = new SemVer(1u, 4u, 5u);
sv1.preRelease = [ "alpha", "beta" ];
sv1.build = [ "x86-64", "linux" ];
// Version is now 1.4.5-alpha.beta+x86-64.linux
```

`SemanticVersion`s can be compared for equality or inequality or sorted, all per the specfication.

```d
SemVer sv1 = new SemVer(1u, 2u, 3u);
SemVer sv2 = new SemVer(1u, 3u, 4u);
SemVer sv3 = new SemVer(1u, 3u, 4u, "", "linux");
assert(sv2 > sv1);
assert(!(sv3 <> sv2)); // Build identifiers do not count in comparison
```

The `SemanticVersion` can be cast to a string, or directly output a string via
the `toString()` method. Or, you can output an array of unsigned integers with
`toArray()`, but it will not contain any pre-release identifiers or build
identifiers.

```d
SemVer sv1 = new SemVer(1u, 2u, 3u, "alpha.beta", "x86", "osx");

// Both of these output "1.2.3-alpha.beta+x86.osx"
writeln(sv1.toString());
writeln(cast (string) sv1);

assert(sv1.toArray() == [ 1u, 2u, 3u ]);
```

Finally there are two properties that essentially do the opposite of each
other. A `SemanticVersion` is in initial development if the major version
number is 0. The two properties `isInitialDevelopment` and `isPublic` just
return a boolean indicating whether the `SemanticVersion` is in initial
development, or if it is used to describe a public API. Who would have
guessed?

```d
SemVer sv1 = new SemVer(0u, 3u, 4u);
SemVer sv2 = new SemVer(1u, 3u, 4u);

assert(sv1.isInitialDevelopment);
assert(!sv1.isPublic);

assert(!sv1.isInitialDevelopment);
assert(sv1.isPublic);
```

## Compile and Install

As of right now, there are no build scripts, since the source is a single file,
but there will be build scripts in the future, just for the sake of consistency
across all similar projects.

## See Also

* [The Official Semantic Versioning Website](http://semver.org/)

## Contact Me

If you would like to suggest fixes or improvements on this library, please just
comment on this on GitHub. If you would like to contact me for other reasons,
please email me at [jonathan@wilbur.space](mailto:jonathan@wilbur.space). :boar: