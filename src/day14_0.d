module day14_0;

auto solve(String, Rules)(String start, Rules rules)
{
    import std.algorithm : fold, group, map, sort;
    import std.array : array, assocArray;
    import std.conv : to;
    import std.range : slide;

    immutable ruleMap = rules.assocArray;
    auto finalString = start;
    foreach (i; 0 .. 10)
    {
        finalString = finalString.slide(2).map!((pair) {
            auto pairStr = pair.to!string;
            auto sub = pairStr in ruleMap;
            if (!sub)
            {
                return pairStr;
            }
            return "" ~ pairStr[0] ~ *sub ~ pairStr[1];
        })
            .fold!((a, b) => a[0 .. $] ~ b[1 .. $]);
    }
    auto frequencyCounts = finalString
        .array
        .sort
        .group
        .array
        .sort!((a, b) => a[1] < b[1]);
    return frequencyCounts[$ - 1][1] - frequencyCounts[0][1];
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
