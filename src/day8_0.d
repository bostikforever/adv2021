module src.day7_1;


auto solve(R)(R range)
{
    import std.array: array;
    import std.algorithm : count, map, sum;

    auto isEasy = (size_t length) {
        switch(length) {
            case 2, 3, 4, 7:
               return true;
            default:
                return false;
        }
    };

    return range.map!(a => array(a)[1].count!(x => isEasy(x.length))).sum;
}

int main(string[] argv)
{
    import std.algorithm : map, splitter;
    import std.stdio : File, writeln;

    immutable filename = argv[1];
    auto inputFile = File(filename);
    auto input = inputFile
        .byLine
        .map!(a => a.splitter(" | ")
                    .map!(a => a.splitter(" ")));
    immutable ret = solve(input);
    writeln(ret);
    return 0;
}
