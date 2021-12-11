module src.day7_0;

auto prefixSum(R)(R range)
{
    import std.algorithm : cumulativeFold;

    return range.cumulativeFold!((a, b) => a + b);
}

auto solve(int[] positions)
{
    import std.array : array;
    import std.algorithm : fold, max, min, reverse;
    import std.functional : binaryFun;
    import std.range : chain, dropBackOne, retro, zip;

    long[] collection;

    foreach (i; positions)
    {
        collection.length = max(collection.length, i + 1);
        collection[i] += 1;
    }

    static immutable zeroPrefix = [0];
    long[] prefix = zeroPrefix.chain(collection.prefixSum.prefixSum).array.dropBackOne;
    long[] suffix = zeroPrefix.chain(collection.retro.prefixSum.prefixSum).array
        .dropBackOne
        .reverse;
    assert(prefix.length == suffix.length);
    return zip(prefix, suffix).fold!((a, b) => min(a, b.expand.binaryFun!"a+b"))(long.max);
}

int main(string[] argv)
{
    import std.algorithm : map, splitter;
    import std.array : array;
    import std.conv : parse;
    import std.stdio : File, writeln;

    immutable filename = argv[1];
    auto inputFile = File(filename);
    auto beginning = inputFile.readln
        .splitter(",")
        .map!(a => parse!int(a))
        .array;
    immutable ret = solve(beginning);
    writeln(ret);
    return 0;
}
