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
    import std.algorithm : count, max;
    import std.array : join;
    import std.math : sgn;

    int[][] board;
    foreach (line; range)
    {
        board.length = max(board.length, max(line.begin.x, line.end.x) + 1);
        immutable xSign = sgn(line.end.x - line.begin.x);
        immutable ySign = sgn(line.end.y - line.begin.y);
        immutable iterEnd = Point(line.end.x + xSign, line.end.y + ySign);
        for (auto p = line.begin; p != iterEnd; p.x += xSign, p.y += ySign)
        {
            auto boardLine = &board[p.x];
            boardLine.length = max(boardLine.length, p.y + 1);
            (*boardLine)[p.y] += 1;
        }
    }
    return board.join.count!(a => a > 1);
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
