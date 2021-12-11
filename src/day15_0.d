module day15_0;

auto solve(int[][] inputMap)
{
    import std.algorithm : each;
    import std.array : array;
    import std.container : heapify;
    import std.range : repeat;
    import std.typecons : Tuple;

    alias Dir = Tuple!(size_t, size_t);
    alias Coord = Dir;
    immutable dirs = [Dir(0, 1), Dir(1, 0), Dir(0, -1), Dir(-1, 0)];

    auto horPad = int.max.repeat(inputMap[0].length + 2).array;
    inputMap.each!((ref a) => a = int.max ~ a ~ int.max);
    inputMap = horPad ~ inputMap ~ horPad;

    alias Next = Tuple!(Coord, "pos", Coord, "from", long, "cost");
    enum Start = Coord(1, 1);
    immutable xLength = inputMap.length;
    immutable yLength = inputMap[0].length;
    immutable End = Coord(xLength - 2, yLength - 2);
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
            toVisit.insert(Next(nextPos, curr.pos, curr.cost + inputMap[nextPos[0]][nextPos[1]]));
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
