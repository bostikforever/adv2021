module day17_1;

import std.typecons : Tuple;

alias Point = Tuple!(int, "x", int, "y");
alias Area = Tuple!(Point, "begin", Point, "end");

auto posXAfterTime(int vel, int time)
{
    if (time >= vel)
    {
        return (vel * (vel + 1)) / 2;
    }
    return ((2 * vel + (1 - time)) * time) / 2;
}

auto posYAfterTime(int vel, int time)
{
    return (2 * vel + (1 - time)) * time / 2;
}

auto solve(Area area)
{
    import std.algorithm : min, max;
    import std.math : ceil, sqrt;
    import std.range : recurrence;

    immutable minXVel = cast(int) ceil((sqrt(1 + 8f * area.begin.x) - 1) / 2);
    immutable maxXVel = area.end.x;
    immutable minYVel = min(area.end.y, -area.end.y);
    immutable maxYVel = max(area.end.y, -area.end.y);
    int validCount;
    foreach (xVel; minXVel .. maxXVel + 1)
    {

        foreach (yVel; minYVel .. maxYVel + 1)
        {
            foreach (t; recurrence!"a[n-1] + 1"(1))
            {
                auto xPos = posXAfterTime(xVel, t);
                auto yPos = posYAfterTime(yVel, t);
                if (yPos <= area.begin.y && yPos >= area.end.y &&
                    xPos >= area.begin.x && xPos <= area.end.x)
                {
                    validCount++;
                    break;
                }
                if (yPos < area.end.y)
                {
                    break;
                }
            }
        }
    }
    return validCount;
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
