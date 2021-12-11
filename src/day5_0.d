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

    int[][] board;
    foreach (line; range)
    {
        board.length = max(board.length, max(line.begin.x, line.end.x) + 1);

        if (line.begin == line.end)
        {
            board[line.begin.x][line.begin.y] += 1;
            continue;
        }
        if (line.begin.x == line.end.x)
        {
            auto boardLine = &board[line.begin.x];
            boardLine.length = max(boardLine.length, max(line.begin.y, line.end.y) + 1);
            foreach (j; minmaxIncl(line.begin.y, line.end.y))
            {
                board[line.begin.x][j] += 1;
            }
        }
        if (line.begin.y == line.end.y)
        {
            foreach (i; minmaxIncl(line.begin.x, line.end.x))
            {
                auto row = &board[i];
                row.length = max(row.length, line.begin.y + 1);
                (*row)[line.begin.y] += 1;
            }
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
