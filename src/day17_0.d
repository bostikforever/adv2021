module day17_0;

import std.typecons : Tuple;

alias Point = Tuple!(int, "x", int, "y");
alias Area = Tuple!(Point, "begin", Point, "end");

auto solve(Area area)
{
    import std.algorithm : max;
    import std.math : ceil, sqrt;
    import std.range : recurrence;

    immutable maxXVel = cast(int) ceil((sqrt(1 + 8f * area.begin.x) - 1) / 2);
    immutable maxXPos = (maxXVel * (maxXVel + 1)) / 2;
    assert(maxXPos >= area.begin.x);
    assert(maxXPos <= area.end.x);
    int minXTime = maxXVel;
    int maxYVel = int.min;
    foreach (time; recurrence!"a[n-1] + 1"(minXTime))
    {
        immutable totYdec = (time * (time - 1)) / 2;
        immutable yVel = (area.begin.y + totYdec) / time;
        auto yFinal = yVel * time - totYdec;
        if (yFinal <= area.begin.y && yFinal >= area.end.y)
        {
            maxYVel = max(maxYVel, yVel);
        }
        if (yVel > -area.end.y)
        {
            break;
        }
    }
    auto maxY = ((maxYVel + 1) * maxYVel) / 2;
    return maxY;
}

auto parseInput(string line)
{
    import std.format : formattedRead;

    Point begin, end;
    line.formattedRead("target area: x=%d..%d, y=%d..%d", begin.x, end.x, end.y, begin.y);
    return Area(begin, end);
}

int main(string[] argv)
{
    import std.algorithm : splitter;
    import std.array : array;
    import std.stdio : File, writeln;

    immutable filename = argv[1];
    auto inputFile = File(filename);
    immutable area = inputFile.readln.parseInput;
    immutable ret = solve(area);
    writeln(ret);
    return 0;
}
