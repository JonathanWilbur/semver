/**
	A class for a strongly-typed Semantic Version.

	Authors:
        $(LINK2 mailto:jonathan@wilbur.space, Jonathan M. Wilbur)
	Date: June 18th, 2017
	License: Boost Software License (BSL-1.0)
    Standards: $(LINK2 http://semver.org, Semantic Versioning Website)
	Version: 1.0.0
*/
module semver;

///
alias SemVerException = SemanticVersionException;
/**
    A class thrown when a SemanticVersion is supplied with an invalid
    identifier.
*/
public
class SemanticVersionException : Exception
{
    @nogc @safe pure nothrow
    this
    (
        string msg, 
        string file = __FILE__, 
        size_t line = __LINE__,
        Throwable next = null
    )
    {
        super(msg, file, line, next);
    }
}

///
alias SemVer = SemanticVersion;
/**
    A class representing a strongly-typed Semantic Version number.
*/
public class SemanticVersion
{
    import std.algorithm.iteration : each;
    import std.ascii : isAlphaNum, toLower;

    private uint _major;
    private uint _minor;
    private uint _patch;
    private string[] _preRelease;
    private string[] _build;

    /**
        Returns: The major version number. This number is supposed to represent
        the number of times that a backwards-incompatible change has been
        introduced.
    */
    public nothrow @property @nogc @safe
    uint major()
    {
        return this._major;
    }

    /**
        Returns: The minor version number. This number is supposed to
        represent the number of times that a backwards-compatible feature has
        been introduced.
    */
    public nothrow @property @nogc @safe
    uint minor()
    {
        return this._minor;
    }

    /**
        Returns: The patch version number. This number is supposed to
        represent the number of times that a backwards-compatible fix has been
        introduced without introducing new functionality or features.
    */
    public nothrow @property @nogc @safe
    uint patch()
    {
        return this._patch;
    }

    /**
        Returns an array of identifiers used to identify a pre-release version.
        From the official documentation on Semantic Versioning: "A pre-release
        version indicates that the version is unstable and might not satisfy
        the intended compatibility requirements as denoted by its associated
        normal version."
    */
    public nothrow @property @nogc @safe
    string[] preRelease()
    {
        return this._preRelease;
    }

    /**
        Returns an array of identifiers used to identify a build version.
    */
    public nothrow @property @nogc @safe
    string[] build()
    {
        return this._build;
    } 

    /**
        Increments the major version number by one. This should be called only
        when a backwards-incompatible change is introduced. Note that the minor
        and patch version numbers get reverted to zero when this method is
        called, and all pre-release identifiers and build identifiers are
        deleted.

        If the change introduces a new feature, but is backwards compatible,
        then incrementMinorNumber() should be used instead.
    */
    public nothrow @nogc @safe
    void incrementMajorNumber()
    {
        this._major++;
        this._minor = 0u;
        this._patch = 0u;
        this._preRelease = [];
        this._build = [];
    }

    ///
    @safe
    unittest
    {
        SemVer sv1 = new SemVer(1u, 4u, 5u);
        sv1.incrementMajorNumber();
        assert(sv1.major == 2u && sv1.minor == 0u && sv1.patch == 0u);

        SemVer sv2 = new SemVer(1u, 4u, 5u, "alpha");
        sv2.build([ "x86-64" ]);
        sv2.incrementMajorNumber();
        assert(sv2.major == 2u && sv2.minor == 0u && sv2.patch == 0u);
        assert(sv2.preRelease == []); // Pre-release identifiers are reset.
        assert(sv2.build == []); // Build identifiers are reset.
    }

    /**
        Increments the minor version number by one. This should be called only
        when a backwards-compatible feature is introduced. Note that the patch
        version number gets reverted to zero when this method is called, and
        all pre-release identifiers and build identifiers are deleted.
    */
    public nothrow @nogc @safe
    void incrementMinorNumber()
    {
        this._minor++;
        this._patch = 0u;
        this._preRelease = [];
        this._build = [];
    }

    ///
    @safe
    unittest
    {
        SemVer sv1 = new SemVer(1u, 4u, 5u);
        sv1.incrementMinorNumber();
        assert(sv1.major == 1u && sv1.minor == 5u && sv1.patch == 0u);

        SemVer sv2 = new SemVer(1u, 4u, 5u, "beta");
        sv2.build([ "x86-64" ]);
        sv2.incrementMinorNumber();
        assert(sv2.major == 1u && sv2.minor == 5u && sv2.patch == 0u);
        assert(sv2.preRelease == []); // Pre-release identifiers are reset.
        assert(sv2.build == []); // Build identifiers are reset.
    }

    /**
        Increments the patch number by one. This should be called only when a
        bug fix or improvement upon an existing feature is introduced. Note
        that all pre-release identifiers and build identifiers are deleted when
        this method is called.
    */
    public nothrow @nogc @safe
    void incrementPatchNumber()
    {
        this._patch++;
        this._preRelease = [];
        this._build = [];
    }

    ///
    @safe
    unittest
    {
        SemVer sv1 = new SemVer(1u, 4u, 5u);
        sv1.incrementPatchNumber();
        assert(sv1.major == 1u && sv1.minor == 4u && sv1.patch == 6u);

        SemVer sv2 = new SemVer(1u, 4u, 5u, "beta");
        sv2.build([ "x86-64" ]);
        sv2.incrementPatchNumber();
        assert(sv2.major == 1u && sv2.minor == 4u && sv2.patch == 6u);
        assert(sv2.preRelease == []); // Pre-release identifiers are reset.
        assert(sv2.build == []); // Build identifiers are reset.
    }

    /**
        Whether the current version is used for initial development. This is
        true if the major version number is zero. Per the documentation on
        Semantic Versioning: "Anything may change at any time. The public API
        should not be considered stable."
    */
    public nothrow @nogc @safe
    bool isInitialDevelopment()
    {
        return (this._major == 0u);
    }

    ///
    @safe
    unittest
    {
        SemVer sv1 = new SemVer(1u, 0u, 0u);
        SemVer sv2 = new SemVer(0u, 0u, 0u);
        SemVer sv3 = new SemVer(0u, 99u, 99u, "alpha", "beta");
        SemVer sv4 = new SemVer(1u, 99u, 99u, "alpha", "beta");
        assert(sv1.isInitialDevelopment == false);
        assert(sv2.isInitialDevelopment == true);
        assert(sv3.isInitialDevelopment == true);
        assert(sv4.isInitialDevelopment == false);
    }

    /**
        Whether the current version is public, meaning that the developer of
        the semantically-versioned thing is expected (though not necessarily
        legally required) to maintain some stability of the API.
    */
    public nothrow @nogc @safe
    bool isPublic()
    {
        return (this._major != 0u);
    }

    ///
    @safe
    unittest
    {
        SemVer sv1 = new SemVer(1u, 0u, 0u);
        SemVer sv2 = new SemVer(0u, 0u, 0u);
        SemVer sv3 = new SemVer(0u, 99u, 99u, "alpha", "beta");
        SemVer sv4 = new SemVer(1u, 99u, 99u, "alpha", "beta");
        assert(sv1.isPublic == true);
        assert(sv2.isPublic == false);
        assert(sv3.isPublic == false);
        assert(sv4.isPublic == true);
    }

    /**
        Sets the pre-release identifiers. No pre-release identifier be empty,
        nor may any identifier start with "0", nor may any identifier have any
        characters other than ASCII alphanumerics [A-Za-z0-9] and the hyphen
        '-'.

        Note that all identifiers get converted to lowercase.

        Throws:
            SemanticVersionException if an invalid pre-release identifier
                is supplied.
    */
    public @property @safe
    void preRelease(in string[] identifiers)
    {
        this._preRelease = [];

        /* REVIEW:
            Is the second parameter of the foreach loop below calculated once
            then stored, or does .split() run for every iteration of the
            foreach loop? If the latter, then I would like to save the output
            to a separate variable, then supply that variable.
        */
        foreach (identifier; identifiers)
        {
            if (identifier == "")
                throw new SemanticVersionException
                ("Pre-release identifiers in semantic version cannot be empty strings.");

            if (identifier[0] == '0')
                throw new SemanticVersionException
                ("Pre-release identifiers in semantic version cannot have leading zeroes.");

            /*
                I tried this:
                    if (!identifier.all!"a.isAlphaNum() || a == '-'"())
                but I got a compiler error. In particular the problem
                seemed to be with the .isAlphaNum() function. It would not
                compile if I had that, giving a template instantiation error.
            */
            foreach (character; identifier)
            {
                if (!(character.isAlphaNum()) && !(character == '-'))
                    throw new SemanticVersionException
                    ("Pre-release identifiers in semantic version must be all graphical characters.");
            }

            identifier.each!"a.toLower()";
            this._preRelease ~= identifier;
        }
    }

    ///
    @safe
    unittest
    {
        SemVer sv1 = new SemVer(1u, 0u, 0u);
        assert(sv1.preRelease == []);
        sv1.preRelease = [ "alpha", "beta" ];
        assert(sv1.preRelease == [ "alpha", "beta" ]);
    }

    /**
        Sets the build identifiers. No build identifier may be empty, nor may
        any identifier start with "0", nor may any identifier have any
        characters other than ASCII alphanumerics [A-Za-z0-9] and the hyphen
        '-'.

        Note that all identifiers get converted to lowercase.

        Throws:
            SemanticVersionException if an invalid build identifier is
                supplied.
    */
    public @property @safe
    void build(in string[] identifiers)
    {
        this._build = [];

        foreach (identifier; identifiers)
        {
            if (identifier == "")
                throw new SemanticVersionException
                ("Build Metadata identifiers in semantic version cannot be empty strings.");

            if (identifier[0] == '0')
                throw new SemanticVersionException
                ("Build Metadata identifiers in semantic version cannot have leading zeroes.");

            /*
                I tried this:
                    if (!identifier.all!"a.isAlphaNum() || a == '-'"())
                but I got a compiler error. In particular the problem
                seemed to be with the .isAlphaNum() function. It would not
                compile if I had that, giving a template instantiation error.
            */
            foreach (character; identifier)
            {
                if (!(character.isAlphaNum()) && !(character == '-'))
                    throw new SemanticVersionException
                    ("Build Metadata identifiers in semantic version must be all graphical characters.");
            }

            identifier.each!"a.toLower()";
            this._build ~= identifier;
        }
    }

    ///
    @safe
    unittest
    {
        SemVer sv1 = new SemVer(1u, 0u, 0u);
        assert(sv1.preRelease == []);
        sv1.build = [ "alpha", "beta" ];
        assert(sv1.build == [ "alpha", "beta" ]);
    }

    /**
        Returns: the Semantic Version as an array of uints.
    */
    public nothrow @property @nogc @safe
    uint[3] asArray()
    {
        return [ this._major, this._minor, this._patch ];
    }

    ///
    @safe
    unittest
    {
        SemVer sv1 = new SemVer(12u, 34u, 56u);
        assert(sv1.asArray == [ 12u, 34u, 56u]);
    }

    /**
        Returns: the Semantic Version as a string.
    */
    public override nothrow @property @safe
    string toString()
    {
        import std.array : join;
        import std.conv : text;
        
        return 
            text(this._major, ".", this._minor, ".", this._patch) ~
            (this._preRelease != [] ? ("-" ~ this._preRelease.join('.')) : "") ~
            (this._build != [] ? ("+" ~ this._build.join('.')) : "");
    }

    ///
    @safe
    unittest
    {
        SemVer sv1 = new SemVer(16u, 0u, 32u, "alpha", "x86-64");
        assert(sv1.toString == "16.0.32-alpha+x86-64");
    }

    @safe
    unittest
    {
        SemVer sv1 = new SemVer(1u, 0u, 0u);
        assert(sv1.toString == "1.0.0");

        SemVer sv2 = new SemVer(1u, 0u, 0u, "beta");
        assert(sv2.toString == "1.0.0-beta");

        SemVer sv3 = new SemVer(1u, 0u, 0u, "alpha.1");
        assert(sv3.toString == "1.0.0-alpha.1");

        SemVer sv4 = new SemVer(1u, 0u, 0u, "alpha.beta");
        assert(sv4.toString == "1.0.0-alpha.beta");

        SemVer sv5 = new SemVer(1u, 0u, 0u, "beta.11");
        assert(sv5.toString == "1.0.0-beta.11");

        SemVer sv6 = new SemVer(99u, 999u, 9999u, "11.gamma");
        assert(sv6.toString == "99.999.9999-11.gamma");

        SemVer sv7 = new SemVer(16u, 0u, 32u, "beta.11", "x86-64");
        assert(sv7.toString == "16.0.32-beta.11+x86-64");

        SemVer sv8 = new SemVer(16u, 0u, 32u, "99.gamma", "x86-64");
        assert(sv8.toString == "16.0.32-99.gamma+x86-64");

        SemVer sv9 = new SemVer(16u, 0u, 32u, "gamma", "x86-64.linux");
        assert(sv9.toString == "16.0.32-gamma+x86-64.linux");
    }

    // REVIEW: Mainly, I want to know that this line is secure.
    /**
        An override so that associative arrays can use a Semantic Version as a
        key.

        Returns: A size_t that represents a hash of the Semantic Version.
    */
    public override nothrow const @trusted
    size_t toHash()
    {
        size_t preReleaseHash = 0;
        foreach (pr; this._preRelease)
        {
            preReleaseHash += typeid(pr).getHash(cast(const void*)&pr);
        }

        return
        (
            typeid(this._major).getHash(cast(const void*)&this._major) +
            typeid(this._minor).getHash(cast(const void*)&this._minor) +
            typeid(this._patch).getHash(cast(const void*)&this._patch) +
            preReleaseHash
        );
    }

    /*
        This is just to make sure that two SemVers do not have the same hash.
        Yes, I know that is extremely unlikely *given random chance*, but
        should there be some kind of bizarre runtime / compiler problem where
        two SemVers all get the same hash or something, this will catch it.
        I *can* be talked into removing this, though.
    */
    @system
    unittest
    {
        import std.conv : to;

        SemVer[] sva = [
            new SemVer(1u, 0u, 0u),
            new SemVer(1u, 0u, 0u, "beta"),
            new SemVer(1u, 0u, 0u, "alpha.1"),
            new SemVer(1u, 0u, 0u, "alpha.beta"),
            new SemVer(1u, 0u, 0u, "beta.11"),
            new SemVer(99u, 999u, 9999u, "11.gamma"),
            new SemVer(16u, 0u, 32u, "beta.11", "x86-64"),
            new SemVer(16u, 0u, 32u, "99.gamma", "x86-64"),
            new SemVer(16u, 0u, 32u, "gamma", "x86-64.linux")
        ];

        for (int x = 0; x < sva.length; x++)
        {
            for (int y = 0; y < sva.length; y++)
            {
                if (x != y)
                    assert(sva[x].toHash() != sva[y].toHash(), 
                    "Hash collision @x,y: " ~ x.to!string ~ "," ~ y.to!string);
            }
        }
    }

    /**
        Casts the Semantic Version as a string.
    */
    public nothrow
    string opCast(string)()
    {
        return this.toString();
    }

    ///
    @safe
    unittest
    {
        SemVer sv1 = new SemVer(16u, 0u, 32u, "alpha", "x86-64");
        assert(cast(string) sv1 == "16.0.32-alpha+x86-64");
    }

    @safe
    unittest
    {
        SemVer sv1 = new SemVer(1u, 0u, 0u);
        assert(cast(string) sv1 == "1.0.0");

        SemVer sv2 = new SemVer(1u, 0u, 0u, "beta");
        assert(cast(string) sv2 == "1.0.0-beta");

        SemVer sv3 = new SemVer(1u, 0u, 0u, "alpha.1");
        assert(cast(string) sv3 == "1.0.0-alpha.1");

        SemVer sv4 = new SemVer(1u, 0u, 0u, "alpha.beta");
        assert(cast(string) sv4 == "1.0.0-alpha.beta");

        SemVer sv5 = new SemVer(1u, 0u, 0u, "beta.11");
        assert(cast(string) sv5 == "1.0.0-beta.11");

        SemVer sv6 = new SemVer(99u, 999u, 9999u, "11.gamma");
        assert(cast(string) sv6 == "99.999.9999-11.gamma");

        SemVer sv7 = new SemVer(16u, 0u, 32u, "beta.11", "x86-64");
        assert(cast(string) sv7 == "16.0.32-beta.11+x86-64");

        SemVer sv8 = new SemVer(16u, 0u, 32u, "99.gamma", "x86-64");
        assert(cast(string) sv8 == "16.0.32-99.gamma+x86-64");

        SemVer sv9 = new SemVer(16u, 0u, 32u, "gamma", "x86-64.linux");
        assert(cast(string) sv9 == "16.0.32-gamma+x86-64.linux");

        SemVer sv10 = new SemVer(16u, 0u, 32u, "gamma", "x86-64.linux");
        assert(cast(string) sv10 == "16.0.32-gamma+x86-64.linux");
    }

    public override
    uint[] opCast(T)()
    if (is(Unqual!T == uint))
    {
        return this.asArray();
    }

    /**
        Operator override for comparing one Semantic Version to another
        using the double equals sign comparator ("==").
    */
    public override nothrow @trusted
    bool opEquals(Object other)
    {
        // Build metadata does not factor into precedence.
        SemVer that = cast(SemVer) other;
        return
            (!(that is null)) &&
            (this.major == that.major) &&
            (this.minor == that.minor) &&
            (this.patch == that.patch) &&
            (this.preRelease == that.preRelease);
    }

    ///
    @system
    unittest
    {
        assert(new SemVer(1u, 0u, 0u) == new SemVer(1u, 0u, 0u));
        assert(new SemVer(1u, 0u, 0u) != new SemVer(2u, 0u, 0u));
        assert(new SemVer(1u, 0u, 0u) != new SemVer(1u, 1u, 0u));
        assert(new SemVer(1u, 0u, 0u) != new SemVer(1u, 0u, 1u));

        SemVer sv1, sv2;
        sv1 = new SemVer(1u, 0u, 0u, "alpha", "");
        sv2 = new SemVer(1u, 0u, 0u, "alpha", "");
        assert(sv1 == sv2);

        sv1 = new SemVer(1u, 0u, 0u, "beep.boop", "");
        sv2 = new SemVer(1u, 0u, 0u, "beep.boop", "");
        assert(sv1 == sv2);

        sv1 = new SemVer(1u, 0u, 0u, "alpha", "");
        sv2 = new SemVer(1u, 0u, 0u, "beta", "");
        assert(sv1 != sv2);

        sv1 = new SemVer(1u, 0u, 0u, "alpha", "");
        sv2 = new SemVer(1u, 0u, 0u, "alpha.jk", "");
        assert(sv1 != sv2);

        sv1 = new SemVer(1u, 0u, 0u, "alpha", "");
        sv2 = new SemVer(1u, 0u, 0u, "alpha", "beta");
        assert(sv1 == sv2);

        sv1 = new SemVer(1u, 0u, 0u, "alpha", "gamma");
        sv2 = new SemVer(1u, 0u, 0u, "alpha", "beta");
        assert(sv1 == sv2);

        sv1 = new SemVer(1u, 0u, 0u, "alpha", "gamma.charlie");
        sv2 = new SemVer(1u, 0u, 0u, "alpha", "beta.delta");
        assert(sv1 == sv2);

        sv1 = new SemVer(1u, 0u, 0u, "alpha.7", "gamma");
        sv2 = new SemVer(1u, 0u, 0u, "alpha", "beta");
        assert(sv1 != sv2);

        sv1 = new SemVer(1u, 0u, 0u, "alpha.8", "gamma");
        sv2 = new SemVer(1u, 0u, 0u, "alpha.8", "beta");
        assert(sv1 == sv2);
    }

    /**
        Operator override for comparing one Semantic Version to another
        using the "<", "<=", ">", and ">=" comparators.
    */
    // NOTE: I could not make this nothrow, because of .all!() for some reason.
    // NOTE: I also could not make it override for some reason.
    public override @trusted
    int opCmp(Object other)
    {
        debug import std.stdio : writeln;

        SemVer that = cast(SemVer) other;
        if (that is null) return 0;
        // Build metadata does not factor into precedence.
        // REVIEW: I am not sure that the versions will properly get converted to ints
        if (this.major != that.major) return (this.major - that.major);
        if (this.minor != that.minor) return (this.minor - that.minor);
        if (this.patch != that.patch) return (this.patch - that.patch);

        if (!this.preRelease.length && that.preRelease.length) return 1;
        if (this.preRelease.length && !that.preRelease.length) return -1;

        immutable size_t tagsToCompare = 
            (this.preRelease.length < that.preRelease.length ? 
            this.preRelease.length : that.preRelease.length);

        import std.algorithm.searching : all;
        for (size_t i; i < tagsToCompare; i++)
        {
            if 
            (
                // I tried .all!"a.isDigit", but that would not compile.
                this.preRelease[i].all!"a >= 0x30 && a <= 0x39" && 
                that.preRelease[i].all!"a >= 0x30 && a <= 0x39"
            )
            {
                /*
                    "...identifiers consisting of only digits are compared
                    numerically..."
                */
                if (this.preRelease[i].length > that.preRelease[i].length) return 1;
                if (this.preRelease[i].length < that.preRelease[i].length) return -1;
                for (size_t j; j < this.preRelease[i].length; j++)
                {
                    if (this.preRelease[i][j] > that.preRelease[i][j]) return 1;
                    if (this.preRelease[i][j] < that.preRelease[i][j]) return -1;
                }
            }
            else if
            (
                // I tried .all!"a.isDigit", but that would not compile.
                !this.preRelease[i].all!"a >= 0x30 && a <= 0x39" && 
                that.preRelease[i].all!"a >= 0x30 && a <= 0x39"
            )
            {
                /*
                    "Numeric identifiers always have lower precedence than 
                    non-numeric identifiers."
                */
                return 1;
            }
            else if
            (
                // I tried .all!"a.isDigit", but that would not compile.
                this.preRelease[i].all!"a >= 0x30 && a <= 0x39" && 
                !that.preRelease[i].all!"a >= 0x30 && a <= 0x39"
            )
            {
                /*
                    "Numeric identifiers always have lower precedence than 
                    non-numeric identifiers."
                */
                return -1;
            }
            else
            {
                /*
                    "...identifiers with letters or hyphens are compared
                    lexically in ASCII sort order."
                */
                immutable size_t lettersToCompare = 
                    (this.preRelease[i].length < that.preRelease[i].length ? 
                    this.preRelease[i].length : that.preRelease[i].length);
                
                for (size_t j; j < lettersToCompare; j++)
                {
                    if (this.preRelease[i][j] < that.preRelease[i][j]) return -1;
                    if (this.preRelease[i][j] > that.preRelease[i][j]) return 1;
                }

                /* REVIEW:
                    This part assumes that pre-release identifiers with shorter
                    names take precedence if all characters are held in common
                    with their longer comparand. It does not specify in the
                    official documentation whether to or not to do this,
                    however.
                */
                if (this.preRelease[i].length > lettersToCompare) return 1;
                if (that.preRelease[i].length > lettersToCompare) return -1;
            }
        }
    
        /*
            "A larger set of pre-release fields has a higher precedence than a
            smaller set, if all of the preceding identifiers are equal."
        */
        if (this.preRelease.length > that.preRelease.length)
        {
            return 1;
        }
        else if (this.preRelease.length < that.preRelease.length)
        {
            return -1;
        }
        else
        {
            return 0;
        }
    }

    @safe
    unittest
    {
        assert(new SemVer(1u, 0u, 0u) < new SemVer(2u, 0u, 0u));
        assert(new SemVer(1u, 0u, 0u) < new SemVer(1u, 1u, 0u));
        assert(new SemVer(1u, 0u, 0u) < new SemVer(1u, 0u, 1u));

        SemVer sv1, sv2;
        sv1 = new SemVer(1u, 0u, 0u);
        sv2 = new SemVer(1u, 0u, 0u);
        assert(!(sv1 > sv2));
        assert(!(sv1 < sv2));
        assert(sv1 >= sv2);
        assert(sv1 <= sv2);

        sv1 = new SemVer(1u, 0u, 0u, "alpha", "");
        sv2 = new SemVer(1u, 0u, 0u, "alpha", "");
        assert(!(sv1 > sv2));
        assert(!(sv1 < sv2));
        assert(sv1 >= sv2);
        assert(sv1 <= sv2);

        sv1 = new SemVer(1u, 0u, 0u, "alpha", "beta");
        sv2 = new SemVer(1u, 0u, 0u, "alpha", "beta");
        assert(!(sv1 > sv2));
        assert(!(sv1 < sv2));
        assert(sv1 >= sv2);
        assert(sv1 <= sv2);

        sv1 = new SemVer(1u, 0u, 0u, "alpha", "beta.gamma");
        sv2 = new SemVer(1u, 0u, 0u, "alpha", "beta.gamma");
        assert(!(sv1 > sv2));
        assert(!(sv1 < sv2));
        assert(sv1 >= sv2);
        assert(sv1 <= sv2);

        sv1 = new SemVer(1u, 0u, 0u, "alpha", "beta.11");
        sv2 = new SemVer(1u, 0u, 0u, "alpha", "beta.11");
        assert(!(sv1 > sv2));
        assert(!(sv1 < sv2));
        assert(sv1 >= sv2);
        assert(sv1 <= sv2);

        sv1 = new SemVer(1u, 0u, 0u, "alpha", "11.beta");
        sv2 = new SemVer(1u, 0u, 0u, "alpha", "11.beta");
        assert(!(sv1 > sv2));
        assert(!(sv1 < sv2));
        assert(sv1 >= sv2);
        assert(sv1 <= sv2);

        sv1 = new SemVer(1u, 0u, 0u, "alpha", "beta");
        sv2 = new SemVer(1u, 0u, 0u, "alpha", "gamma");
        assert(!(sv1 > sv2));
        assert(!(sv1 < sv2));
        assert(sv1 >= sv2);
        assert(sv1 <= sv2);

    }

    /// These examples are straight from the official documentation.
    @safe
    unittest
    {
        // 1.0.0-alpha
        SemVer sv1 = new SemVer(1u, 0u, 0u, "alpha");

        // 1.0.0-alpha.1
        SemVer sv2 = new SemVer(1u, 0u, 0u, "alpha.1");

        // 1.0.0-alpha.beta
        SemVer sv3 = new SemVer(1u, 0u, 0u, "alpha.beta");

        // 1.0.0-beta
        SemVer sv4 = new SemVer(1u, 0u, 0u, "beta");

        // 1.0.0-beta.2
        SemVer sv5 = new SemVer(1u, 0u, 0u, "beta.2");

        // 1.0.0-beta.11
        SemVer sv6 = new SemVer(1u, 0u, 0u, "beta.11");

        // 1.0.0-rc.1
        SemVer sv7 = new SemVer(1u, 0u, 0u, "rc.1");

        // 1.0.0
        SemVer sv8 = new SemVer(1u, 0u, 0u);

        assert(sv1 < sv2);
        assert(sv2 < sv3);
        assert(sv3 < sv4);
        assert(sv4 < sv5);
        assert(sv5 < sv6);
        assert(sv6 < sv7);
        assert(sv7 < sv8);
    }

    ///
    public @safe
    this(in uint major, in uint minor, in uint patch)
    {
        this._major = major;
        this._minor = minor;
        this._patch = patch;
    }

    ///
    @safe
    unittest
    {
        SemVer sv1 = new SemVer(1u, 0u, 0u);
    }

    ///
    public @safe
    this
    (
        in uint major,
        in uint minor,
        in uint patch,
        in string preRelease,
        in string build = ""
    )
    {
        import std.array : split;
        this._major = major;
        this._minor = minor;
        this._patch = patch;
        this.preRelease = preRelease.split(".");
        this.build = build.split(".");
    }

    @safe
    unittest
    {
        import std.exception : assertThrown;

        // Fuzz testing the end of a pre-release field
        for (ubyte i = 0x00u; i < 0x2Du; i++)
        {
            assertThrown!SemVerException
                (new SemVer(1u, 0u, 0u, "gamma" ~ cast(char) i));
        }
        assertThrown!SemVerException(new SemVer(1u, 0u, 0u, "gamma/")); 
        for (ubyte i = 0x3Au; i < 0x41u; i++)
        {
            assertThrown!SemVerException
                (new SemVer(1u, 0u, 0u, "gamma" ~ cast(char) i));
        }
        for (ubyte i = 0x5Bu; i < 0x61u; i++)
        {
            assertThrown!SemVerException
                (new SemVer(1u, 0u, 0u, "gamma" ~ cast(char) i));
        }
        for (ubyte i = 0x7Bu; i < 0x7Fu; i++)
        {
            assertThrown!SemVerException
                (new SemVer(1u, 0u, 0u, "gamma" ~ cast(char) i));
        }

        // Fuzz testing the beginning of a pre-release field
        for (ubyte i = 0x00u; i < 0x2Du; i++)
        {
            assertThrown!SemVerException
                (new SemVer(1u, 0u, 0u, cast(char) i ~ "delta"));
        }
        assertThrown!SemVerException(new SemVer(1u, 0u, 0u, "/gamma")); 
        for (ubyte i = 0x3Au; i < 0x41u; i++)
        {
            assertThrown!SemVerException
                (new SemVer(1u, 0u, 0u, cast(char) i ~ "delta"));
        }
        for (ubyte i = 0x5Bu; i < 0x61u; i++)
        {
            assertThrown!SemVerException
                (new SemVer(1u, 0u, 0u, cast(char) i ~ "delta"));
        }
        for (ubyte i = 0x7Bu; i < 0x7Fu; i++)
        {
            assertThrown!SemVerException
                (new SemVer(1u, 0u, 0u, cast(char) i ~ "delta"));
        }

        // Fuzz testing the end of a build field
        for (ubyte i = 0x00u; i < 0x2Du; i++)
        {
            assertThrown!SemVerException
                (new SemVer(1u, 0u, 0u, "", "gamma" ~ cast(char) i));
        }
        assertThrown!SemVerException(new SemVer(1u, 0u, 0u, "", "gamma/")); 
        for (ubyte i = 0x3Au; i < 0x41u; i++)
        {
            assertThrown!SemVerException
                (new SemVer(1u, 0u, 0u, "", "gamma" ~ cast(char) i));
        }
        for (ubyte i = 0x5Bu; i < 0x61u; i++)
        {
            assertThrown!SemVerException
                (new SemVer(1u, 0u, 0u, "", "gamma" ~ cast(char) i));
        }
        for (ubyte i = 0x7Bu; i < 0x7Fu; i++)
        {
            assertThrown!SemVerException
                (new SemVer(1u, 0u, 0u, "", "gamma" ~ cast(char) i));
        }

        // Fuzz testing the beginning of a build field
        for (ubyte i = 0x00u; i < 0x2Du; i++)
        {
            assertThrown!SemVerException
                (new SemVer(1u, 0u, 0u, "", cast(char) i ~ "delta"));
        }
        assertThrown!SemVerException(new SemVer(1u, 0u, 0u, "", "/gamma")); 
        for (ubyte i = 0x3Au; i < 0x41u; i++)
        {
            assertThrown!SemVerException
                (new SemVer(1u, 0u, 0u, "", cast(char) i ~ "delta"));
        }
        for (ubyte i = 0x5Bu; i < 0x61u; i++)
        {
            assertThrown!SemVerException
                (new SemVer(1u, 0u, 0u, "", cast(char) i ~ "delta"));
        }
        for (ubyte i = 0x7Bu; i < 0x7Fu; i++)
        {
            assertThrown!SemVerException
                (new SemVer(1u, 0u, 0u, "", cast(char) i ~ "delta"));
        }
    }

    invariant
    {
        import std.ascii : isAlphaNum;

        foreach (identifier; this._preRelease)
        {
            assert(identifier != "");
            assert(identifier[0] != '0');
            foreach (character; identifier)
            {
                assert(character.isAlphaNum() || character == '-');
            }
        }

        foreach (identifier; this._build)
        {
            assert(identifier != "");
            assert(identifier[0] != '0');
            foreach (character; identifier)
            {
                assert(character.isAlphaNum() || character == '-');
            }
        }

    }

}