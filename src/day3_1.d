string repeatedTournament(alias pred = "a >= b", Range)(Range sortedStrings, char prefNeedle)
{
    import std.algorithm : countUntil, count, map;

    auto strings = sortedStrings.release;
    auto index = 0;
    while (strings.length > 1)
    {
        immutable needleCount = strings.count!(a => a[index] == prefNeedle);
        long minIdx, maxIdx;
        if (pred(needleCount, strings.length - needleCount))
        {
            minIdx = strings.countUntil!(a => a[index] == prefNeedle);
            strings = strings[minIdx .. $];
            maxIdx = strings.countUntil!(a => a[index] != prefNeedle);
        }
        else
        {
            minIdx = strings.countUntil!(a => a[index] != prefNeedle);
            strings = strings[minIdx .. $];
            maxIdx = strings.countUntil!(a => a[index] == prefNeedle);
        }
        if (maxIdx == -1)
        {
            maxIdx = strings.length;
        }
        strings = strings[0 .. maxIdx];
        index += 1;
    }
    return strings[0];
}

int power(R)(R range)
{
    import std.algorithm : sort;
    import std.format : unformatValue, singleSpec;

    auto sorted = range.sort;
    auto oxygenStr = repeatedTournament!((a, b) => a >= b)(sorted, '1');
    auto co2Str = repeatedTournament!((a, b) => a <= b)(sorted, '0');

    auto spec = singleSpec("%b");
    auto oxygen = oxygenStr.unformatValue!int(spec);
    auto co2 = co2Str.unformatValue!int(spec);

    return co2 * oxygen;
}

int main(string[] argv)
{
    import std.stdio : File, writeln;
    import std.array : array;

    immutable filename = argv[1];

    auto inputFile = File(filename);
    immutable ret = inputFile.byLineCopy
        .array
        .power;
    writeln(ret);
    return 0;
}
