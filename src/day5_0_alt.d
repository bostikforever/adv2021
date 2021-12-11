import std.typecons : Tuple;

alias Point = Tuple!(int, "x", int, "y");
alias Line = Tuple!(Point, "begin", Point, "end");

auto minmaxIncl(T)(T lhs, T rhs)
{
    import std.range : iota;

    if (lhs < rhs)
    {
        return iota(lhs, rhs + 1);
    }
    return iota(rhs, lhs + 1);
}

auto process(Range)(Range range)
{
    import std.algorithm : count;
    import std.typecons : tuple;

    alias Coord = Tuple!(int, int);
    int[Coord] board;
    foreach (line; range)
    {
        if (line.begin == line.end)
        {
            board[tuple(line.begin.x, line.begin.y)] += 1;
            continue;
        }
        if (line.begin.x == line.end.x)
        {
            foreach (j; minmaxIncl(line.begin.y, line.end.y))
            {
                board[tuple(line.begin.x, j)] += 1;
            }
        }
        if (line.begin.y == line.end.y)
        {
            foreach (i; minmaxIncl(line.begin.x, line.end.x))
            {
                board[tuple(i, line.begin.y)] += 1;
            }
        }
    }
    return board.byValue.count!(a => a > 1);
}

auto parseCommand(char[] s)
{
    import std.format : formattedRead;

    Line ret;
    s.formattedRead("%d,%d -> %d,%d", ret.begin.x, ret.begin.y, ret.end.x, ret.end.y);
    return ret;
}

int main(string[] argv)
{
    import std.algorithm : map;
    import std.stdio : File, writeln;

    immutable filename = argv[1];

    auto inputFile = File(filename);
    auto ret = inputFile.byLine
        .map!parseCommand
        .process;
    writeln(ret);
    return 0;
}
