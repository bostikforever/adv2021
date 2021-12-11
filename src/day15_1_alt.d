module day15_1_alt;

auto solve(int[][] inputMap)
{
    import std.algorithm : count, sum;
    import std.container : redBlackTree;
    import std.range : only;
    import std.typecons : Tuple;

    alias Dir = Tuple!(size_t, size_t);
    alias Coord = Dir;
    immutable dirs = [Dir(0, 1), Dir(1, 0), Dir(0, -1), Dir(-1, 0)];

    alias Next = Tuple!(Coord, "pos", Coord, "from", long, "cost");
    enum Start = Coord(0, 0);
    immutable xLength = inputMap.length;
    immutable yLength = inputMap[0].length;
    enum Repeat = 5;
    immutable End = Coord(xLength * Repeat - 1, yLength * Repeat - 1);
    auto toVisit = redBlackTree!("a.cost < b.cost", true)([Next(Start, Start, 0)]);
    alias PathFrag = Tuple!(Coord, "from", long, "cost");
    PathFrag[Coord] paths;
    while (toVisit.length > 0)
    {
        auto curr = toVisit.front;
        toVisit.removeFront();
        if (curr.pos == End)
        {
            break;
        }
        foreach (dir; dirs)
        {
            auto nextPos = Coord(curr.pos[0] + dir[0], curr.pos[1] + dir[1]);
            if (nextPos.expand.only.count!(a => a == size_t.max || a == Repeat * xLength))
            {
                continue;
            }
            auto xMul = nextPos[0] / xLength;
            auto yMul = nextPos[1] / yLength;

            auto accessPos = Coord(nextPos[0] % xLength, nextPos[1] % yLength);
            immutable cost = (inputMap[accessPos[0]][accessPos[1]] - 1 + xMul + yMul) % 9 + 1;
            auto oldNextPost = nextPos in paths;
            immutable newCost = curr.cost + cost;
            if (oldNextPost)
            {
                if (oldNextPost.cost <= newCost)
                {
                    continue;
                }
                toVisit.removeKey(Next(nextPos, oldNextPost.from, oldNextPost.cost));
            }
            toVisit.insert(Next(nextPos, curr.pos, newCost));
            paths[nextPos] = PathFrag(curr.pos, newCost);
        }
    }
    return paths[End].cost;
}

int main(string[] argv)
{
    import std.algorithm : map;
    import std.array : array;
    import std.stdio : File, writeln;

    immutable filename = argv[1];
    auto inputFile = File(filename);
    auto input = inputFile
        .byLine
        .map!(a => a.map!(b => cast(int)(b - '0')).array)
        .array;
    immutable ret = solve(input);
    writeln(ret);
    return 0;
}
