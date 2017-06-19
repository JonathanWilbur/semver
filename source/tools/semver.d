/**
	A command line tool for validating, comparing, and sorting semantic version
    identifiers.

	Authors:
        $(LINK2 mailto:jonathan@wilbur.space, Jonathan M. Wilbur)
	Date: June 18th, 2017
	License: Boost Software License (BSL-1.0)
    Standards: $(LINK2 http://semver.org, Semantic Versioning Website)
	Version: 1.0.0
*/
module main;
import semver;
import std.algorithm.iteration : each;
import std.algorithm.searching : all;
import std.algorithm.sorting : sort;
import std.ascii : toLower;
import std.conv : ConvException, ConvOverflowException, to;
import std.stdio : writefln, writeln;

private immutable string usageMessage = 
`Usage: semver {subcommand} versions ...
Where {subcommand} is one of:
validate
sort
ascend
descend
major
minor
patch
prerelease
build
public
development
compatible
incompatible
`;

int main(string[] args)
{
    if (args.length < 3)
    {
        writeln(usageMessage);
        return 1;
    }

    // Converts each character of the second argument to lowercase.
    args[1].each!"a.toLower()";

    SemVer[] svs;
    try
    {
        svs = parseSemanticVersions(args[2 .. $]);
    }
    catch (Exception e)
    {
        writeln("invalid");
        return 1;
    }

    switch(args[1])
    {
        case "validate":
        {
            writeln("valid");
            return 0;
        }
        case "sort", "ascend":
        {
            writefln("%(%s\n%)", svs.sort!"a < b");
            return 0;
        }
        case "descend":
        {
            writefln("%(%s\n%)", svs.sort!"a > b");
            return 0;
        }
        case "major":
        {
            foreach(sv; svs)
            {
                writeln(sv.major.to!string);
            }
            return 0;
        }
        case "minor":
        {
            foreach(sv; svs)
            {
                writeln(sv.minor.to!string);
            }
            return 0;
        }
        case "patch":
        {
            foreach(sv; svs)
            {
                writeln(sv.patch.to!string);
            }
            return 0;
        }
        case "prerelease":
        {
            foreach(sv; svs)
            {
                writeln(sv.preRelease);
            }
            return 0;
        }
        case "build":
        {
            foreach(sv; svs)
            {
                writeln(sv.build);
            }
            return 0;
        }
        case "public":
        {
            writeln(svs.all!"a.isPublic" ? "true" : "false");
            return 0;
        }
        case "development":
        {
            writeln(svs.all!"a.isInitialDevelopment" ? "true" : "false");
            return 0;
        }
        case "compatible", "incompatible":
        {
            foreach (sv; svs)
            {
                if (sv.major != svs[0].major)
                {
                    writeln("incompatible");
                    return 0;
                }
            }
            writeln("compatible");
            return 0;
        }
        default:
        {
            writeln(usageMessage);
            return 1;
        }
    }
}

private
SemVer[] parseSemanticVersions(string[] semvers ...)
{
    import std.array : split;
    import std.string : indexOf;

    SemVer[] result;

    foreach (semver; semvers)
    {
        uint[] numbers = [];
        string preRelease = "";
        string build = "";
        ptrdiff_t indexOfFirstHyphen = semver.indexOf("-");
        ptrdiff_t indexOfFirstPlus = semver.indexOf("+");

        if (indexOfFirstPlus != -1 && semver.length > indexOfFirstPlus+1)
        {
            build = semver[indexOfFirstPlus+1 .. $];
            semver = semver[0 .. indexOfFirstPlus];
        }
            
        if (indexOfFirstHyphen != -1 && semver.length > indexOfFirstHyphen+1)
        {
            preRelease = semver[indexOfFirstHyphen+1 .. $];
            semver = semver[0 .. indexOfFirstHyphen];
        }

        foreach (number; semver.split("."))
        {
            numbers ~= number.to!uint;
        }

        if (numbers.length != 3)
            throw new SemVerException("One of the input semantic versions is invalid.");

        result ~= new SemVer(numbers[0], numbers[1], numbers[2], preRelease, build);
    }

    return result;
}