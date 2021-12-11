import std.range.primitives : isForwardRange;

size_t countIncreases(R)(R range) if (isForwardRange!(R))
{
    import std.algorithm : count, map, sum;
    import std.range : slide;

    auto increases = range.slide(3)
        .map!"a.sum"
        .slide(2)
        .count!"a[1] > a[0]";
    return increases;
}

int main(string[] argv)
{
    import std.array : array;
    import std.algorithm : map;
    import std.conv : parse;
    import std.stdio : File, writeln;

    immutable filename = argv[1];

    auto inputFile = File(filename);
    auto ret = inputFile.byLine
        .map!(a => parse!int(a))
        .array
        .countIncreases;
    writeln(ret);
    return 0;
}
