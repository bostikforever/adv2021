module day14_1;

auto sumCounter(Range)(Range range)
{
    import std.algorithm : chunkBy, map, sort, sum;
    import std.array : array, assocArray;
    import std.typecons : tuple;

    return range.array
        .sort
        .chunkBy!(a => a[0])
        .map!((charCounts) { return tuple(charCounts[0], charCounts[1].map!"a[1]".sum); })
        .assocArray;
}

auto solve(String, Rules)(String start, Rules rules)
{
    import std.algorithm : group, joiner, map, maxElement, minElement, sort;
    import std.array : array, assocArray;
    import std.conv : to;
    import std.range : slide;
    import std.typecons : tuple;

    immutable ruleMap = rules.assocArray;
    auto pairCount = start.slide(2).map!(to!string)
        .array
        .sort
        .group
        .map!(a => tuple(a[0], cast(ulong) a[1]))
        .assocArray;
    foreach (i; 0 .. 40)
    {
        pairCount = pairCount.byKeyValue.map!((pairCount) {
            immutable pair = pairCount.key;
            auto count = pairCount.value;
            auto rule = pair in ruleMap;
            if (!rule)
            {
                return [tuple(pair, count)];
            }
            return [
                tuple(pair[0 .. $ - 1] ~ *rule, count), tuple(*rule ~ pair[1 .. $], count)
            ];
        }).joiner.sumCounter;
    }
    auto frequencyCounts = pairCount.byKeyValue
        .map!((pairCount) {
            immutable pair = pairCount.key;
            auto count = pairCount.value;
            char lhs = pair[0];
            char rhs = pair[1];
            return [tuple(lhs, count), tuple(rhs, count)];
        })
        .joiner
        .sumCounter;
    frequencyCounts[start[0]] += 1;
    frequencyCounts[start[$ - 1]] += 1;

    return (maxElement(frequencyCounts.byValue) - minElement(frequencyCounts.byValue)) / 2;
}

auto parseRules(InputStream)(InputStream lines)
{
    import std.algorithm : map;
    import std.format : formattedRead;
    import std.typecons : tuple;

    return lines.map!((line) {
        string term;
        char insert;
        line.formattedRead("%s -> %c", term, insert);
        return tuple(term, insert);
    });
}

int main(string[] argv)
{
    import std.algorithm : splitter;
    import std.array : array;
    import std.range : dropOne, front;
    import std.stdio : File, writeln;

    immutable filename = argv[1];
    auto inputFile = File(filename);
    auto inputLines = inputFile.byLineCopy.array.splitter("");
    auto start = inputLines.front().front();
    auto ruleLines = inputLines.dropOne.front();
    auto rules = parseRules(ruleLines);
    immutable ret = solve(start, rules);
    writeln(ret);
    return 0;
}
