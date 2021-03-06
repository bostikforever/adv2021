int power(R)(R range)
{
    import std.algorithm: fold, map, sum;
    import std.array: array, join;
    import std.conv: toChars;
    import std.format: unformatValue, singleSpec;
    import std.range: only, zip;

    auto bitCounts = range.fold!((a, b) =>  (zip(a,b).map!(c => c.expand.only.sum)
                                                     .array));
    auto gammaStr = bitCounts[1..$].map!(a => (cast(int)(a > bitCounts[0]/2)).toChars)
                                   .join;
    auto epsilonStr = gammaStr.map!(a=>a=='0'?'1':'0')
                              .array;
    auto spec = singleSpec("%b");
    auto gamma = gammaStr.unformatValue!int(spec);
    auto epsilon = epsilonStr.unformatValue!int(spec);
    return gamma * epsilon;
}

int main(string[] argv) {
    import std.algorithm: map;
    import std.array: array;
    import std.conv: text, to;
    import std.stdio: File, writeln;
    import std.range: chain, only;

    immutable filename = argv[1];

    auto inputFile = File(filename);
    auto ret = inputFile.byLine
                        .map!(a => only(1U).chain(a.map!(b => b.text
                                                     .to!uint))
                                         .array)
                        .power;
    writeln(ret);
    return 0;
}