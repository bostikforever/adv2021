string repeatedTournament(alias pred = "a >= b", Range)(Range sortedStrings, char prefNeedle)
{
    import std.range : assumeSorted;
    import std.algorithm : isSorted;
    import std.conv : text;

    auto index = 0;
    immutable prefNeedleStr = text(prefNeedle);
    auto sortCriteria = (string a, string b) {
        if (a.length > 1 && b.length == 1)
        {
            return a[index .. index + 1] < b;
        }
        if (a.length == 1 && b.length > 1)
        {
            return a < b[index .. index + 1];
        }
        assert(false);
    };
    auto strings = assumeSorted!sortCriteria(sortedStrings);
    while (strings.length > 1)
    {
        auto trisected = strings.trisect(prefNeedleStr);
        auto prefRange = trisected[1];
        auto otherRange = trisected[0].length > 0 ? trisected[0] : trisected[2];
        assert(trisected[0].length > 0 ? trisected[2].length == 0 : trisected[0].length == 0);
        strings = pred(prefRange.length, otherRange.length) ? prefRange : otherRange;
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
