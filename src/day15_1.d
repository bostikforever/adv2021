module day15_1;

auto solve(int[][] inputMap)
{
    import std.algorithm : count, sum;
    import std.container : heapify;
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
    auto toVisit = heapify!"a.cost > b.cost"([Next(Start, Start, 0)]);
    alias PathFrag = Tuple!(Coord, "from", long, "cost");
    PathFrag[Coord] paths;
    while (toVisit.length > 0)
    {
        auto curr = toVisit.front;
        toVisit.popFront();
        if (curr.pos in paths)
        {
            continue;
        }
        paths[curr.pos] = PathFrag(curr.from, curr.cost);
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
            if (nextPos in paths) {
                continue;
            }
            auto xMul = nextPos[0] / xLength;
            auto yMul = nextPos[1] / yLength;
            auto accessPos = Coord(nextPos[0] % xLength, nextPos[1] % yLength);

            immutable cost = (inputMap[accessPos[0]][accessPos[1]] - 1 + xMul + yMul) % 9 + 1;
            toVisit.insert(Next(nextPos, curr.pos, curr.cost + cost));
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
