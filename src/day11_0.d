module day11_0;

import std.typecons : Tuple;
import std.algorithm : cartesianProduct, filter, map;
import std.array : array;
import std.range : chain, only;

alias Dir = Tuple!(int, int);
immutable X_DIRS = [Dir(-1, 0), Dir(1, 0)];
immutable Y_DIRS = [Dir(0, -1), Dir(0, 1)];
immutable ORIGIN = Dir(0, 0);
immutable DIRS = cartesianProduct(X_DIRS.chain(only(ORIGIN)),
    Y_DIRS.chain(only(ORIGIN)))
    .map!(a => Dir(a[0][0] + a[1][0], a[0][1] + a[1][1]))
    .filter!(a => a != ORIGIN)
    .array;

auto solve(int[][] map, int days)
{
    import std.algorithm : count, each;
    import std.array : array;
    import std.range : front, iota, repeat;
    import std.typecons : Tuple;

    auto horPad = int.max.repeat(map[0].length + 2).array;
    map.each!((ref a) => a = int.max ~ a ~ int.max);
    map = horPad ~ map ~ horPad;

    immutable xLength = map.length;
    immutable yLength = map[0].length;
    int flashes = 0;
    foreach (day; 0 .. days)
    {
        alias Coord = Tuple!(size_t, size_t);
        bool[Coord] toFlash, flashed;
        cartesianProduct(iota(1, xLength - 1), iota(1, yLength - 1)).each!((coord) {
            immutable energy = map[coord[0]][coord[1]] += 1;
            if (energy > 9)
            {
                toFlash[coord] = true;
            }
        });
        while (toFlash.length > 0)
        {
            immutable curr = toFlash.byKey().front();
            toFlash.remove(curr);
            flashed[curr] = true;
            flashes += 1;
            map[curr[0]][curr[1]] = 0;
            DIRS.each!((ref dir) {
                auto next = Coord(curr[0] + dir[0], curr[1] + dir[1]);
                auto nextValue = &(map[next[0]][next[1]]);
                if (next in flashed)
                {
                    return;
                }
                if (*nextValue == int.max)
                {
                    return;
                }
                *nextValue += 1;
                if (*nextValue > 9)
                {
                    toFlash[next] = true;
                }
            });
        }
    }
    return flashes;
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
    immutable ret = solve(input, 100);
    writeln(ret);
    return 0;
}
