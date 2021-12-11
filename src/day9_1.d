module src.day9_1;

auto solve(int[][] map)
{
    import std.algorithm : cartesianProduct, count, each, fold, topN;
    import std.array : array;
    import std.range : front, iota, popFront, repeat;
    import std.typecons : Tuple;

    alias Dir = Tuple!(int, int);
    immutable dirs = [Dir(0, 1), Dir(1, 0), Dir(0, -1), Dir(-1, 0)];

    auto horPad = int.max.repeat(map[0].length + 2).array;
    map.each!((ref a) => a = int.max ~ a ~ int.max);
    map = horPad ~ map ~ horPad;

    immutable xLength = map.length;
    immutable yLength = map[0].length;

    alias Coord = Tuple!(size_t, size_t);
    Coord[] sinks;
    cartesianProduct(iota(1, xLength - 1), iota(1, yLength - 1)).each!((coord) {
        auto height = map[coord[0]][coord[1]];
        if (dirs.count!(a => height < map[coord[0] + a[0]][coord[1] + a[1]]) == 4)
        {
            sinks ~= coord;
        }
    });

    bool[Coord] seen;
    int[] basinSizes;
    foreach (sink; sinks)
    {
        if (sink in seen)
        {
            continue;
        }
        Coord[] toVisit = [sink];
        int basinSize;
        while (toVisit.length > 0)
        {
            auto cur = toVisit.front();
            toVisit.popFront();
            if (cur in seen)
            {
                continue;
            }
            basinSize += 1;

            foreach (dir; dirs)
            {
                immutable next = Coord(dir[0] + cur[0], dir[1] + cur[1]);
                if (next[0] == 0 ||
                    next[1] == 0 ||
                    next[0] == xLength - 1 ||
                    next[1] == yLength - 1
                    )
                {
                    continue;
                }
                immutable nextValue = map[next[0]][next[1]];
                immutable currVal = map[cur[0]][cur[1]];
                if (nextValue == 9 || nextValue <= currVal)
                {
                    continue;
                }
                toVisit ~= next;
            }
            seen[cur] = true;
        }
        basinSizes ~= basinSize;
    }
    return basinSizes.topN!"a > b"(3).fold!"a * b"(1);
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
