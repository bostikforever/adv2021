module src.day7_1;

auto prefixSum(R)(R range)
{
    import std.algorithm : cumulativeFold;

    return range.cumulativeFold!((a, b) => a + b);
}

auto solve(int[] positions)
{
    import std.algorithm : cumulativeFold, fold, max, min, reverse, sum;
    import std.array : array;
    import std.range : chain, dropBackOne, only, retro, zip;

    long[] collection;

    foreach (i; positions)
    {
        collection.length = max(collection.length, i + 1);
        collection[i] += 1;
    }

    static immutable zeroPrefix = [0];
    long[] prefix = zeroPrefix.chain(collection.prefixSum.prefixSum.prefixSum).array
        .dropBackOne;
    long[] suffix = zeroPrefix.chain(collection.retro.prefixSum.prefixSum.prefixSum)
        .array
        .dropBackOne
        .reverse;
    assert(prefix.length == suffix.length);
    return zip(prefix, suffix).fold!((a, b) => min(a, b.expand.only.sum))(long.max);
}

int main(string[] argv)
{
    import std.array : array;
    import std.algorithm : map, splitter;
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
