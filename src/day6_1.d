module day6_1;

auto solve(int[] beginning, int days)
{
    import std.algorithm : sum;
    import std.range : chain;

    enum CYCLE_LEGTH = 7;

    ulong[CYCLE_LEGTH] collection;
    ulong[CYCLE_LEGTH] nursery;

    foreach (i; beginning)
    {
        collection[i] += 1;
    }

    foreach (day; 0 .. days)
    {
        immutable i = day %= CYCLE_LEGTH;
        auto newly_spawned = collection[i];
        immutable spawned_day = (i + 2) % CYCLE_LEGTH;
        nursery[spawned_day] += newly_spawned;
        collection[i] += nursery[i];
        nursery[i] = 0;
    }

    return sum(chain(collection[], nursery[]));
}

int main(string[] argv)
{
    import std.algorithm : map, splitter;
    import std.array : array;
    import std.conv : parse;
    import std.stdio : File, writeln;

    immutable filename = argv[1];
    auto inputFile = File(filename);
    auto beginning = inputFile.readln
        .splitter(",")
        .map!(a => parse!int(a))
        .array;
    immutable ret = solve(beginning, 256);
    writeln(ret);
    return 0;
}
