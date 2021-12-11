module src.day9_0;

auto solve(int[][] map)
{
    import std.algorithm : count, each;
    import std.array: array;
    import std.range: repeat;
    import std.typecons : Tuple;

    alias Dir = Tuple!(int, int);
    immutable dirs = [Dir(0, 1), Dir(1, 0), Dir(0, -1), Dir(-1, 0)];


    auto horPad = int.max.repeat(map[0].length + 2).array;
    map.each!((ref a) => a = int.max ~ a ~ int.max);
    map = horPad ~ map ~ horPad;

    immutable xLength = map.length;
    immutable yLength = map[0].length;
    int riskSum = 0;
    foreach (i; 1 .. xLength - 1)
    {
        foreach (j; 1 .. yLength - 1)
        {
            auto height = map[i][j];
            if (dirs.count!(a => height < map[i + a[0]][j + a[1]]) == 4)
            {
                riskSum += height + 1;
            }
        }
    }
    return riskSum;
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
