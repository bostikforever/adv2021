module day19_0;

import std.algorithm : cartesianProduct, map, permutations;
import std.array : array;
import std.range : take;

immutable STANDARD_INDEX = [0, 1, 2];
immutable INDEXES = permutations(STANDARD_INDEX).map!(a => a.array).array;
immutable POS_NEG = [1, -1];
immutable AXIS_SIGN = POS_NEG.cartesianProduct(POS_NEG).map!(a => [
        a[0], a[1], a[0] * a[1]
    ]).array;
immutable ORIENT = INDEXES.cartesianProduct(AXIS_SIGN).array;
static assert(ORIENT.length == 24);

auto transform(Index, AxesSign)(int[] coords, Index index, AxesSign axesSign)
{
    import std.algorithm : fold, map;
    import std.array : array;
    import std.range : indexed, only, zip;

    auto ret = coords.indexed(index).zip(axesSign).map!(a => a.expand.only.fold!"a*b")
        .array;
    ret[2] *= (index[0] + 1) % 3 == index[1] ? 1 : -1;
    return ret;
}

import std.typecons : Tuple;

alias Match = Tuple!(
    bool, "matching",
    int[], "index",
    int[], "axesSign",
    int[], "displacement");

auto elementWise(alias pred = "a + b")(int[] lhs, int[] rhs)
{

    import std.algorithm : fold, map;
    import std.array : array;
    import std.range : only, zip;

    return lhs.zip(rhs).map!(a => a.expand.only.fold!pred).array;
}

alias add = elementWise!"a+b";
alias minus = elementWise!"a-b";
alias multiply = elementWise!"a*b";

/*
   Check that rhs matches lhs, up to some orientation and displacement. The criteria for
   'matches' is at least 12 matching measurements.
*/
auto matches(Measurements)(Measurements lhs, Measurements rhs)

{
    import std.algorithm : cartesianProduct, count, each, group, setIntersection, sort;
    import std.array : array;
    import std.range : enumerate, No, Yes;

    Match match;

    bool[int[]] lhsSet;
    foreach (coord; lhs)
    {
        lhsSet[cast(immutable(int[])) coord] = true;
    }

    ORIENT.each!((orient) {
        auto index = orient[0];
        auto axesSign = orient[1];
        auto transformed = rhs.map!(meas => meas.transform(index, axesSign));
        return lhs.cartesianProduct(transformed).map!(a => a.expand.minus)
            .each!((disp) {
                auto newCoords = transformed.map!(a => a.add(disp));
                int matching = 0;
                foreach (i, coord; enumerate(newCoords))
                {
                    matching += ((cast(immutable(int[])) coord) in lhsSet) ? 1 : 0;
                    if (newCoords.length - i + matching < 12)
                    {
                        return Yes.each;
                    }
                }
                if (matching >= 12)
                {
                    match.matching = true;
                    match.index = index.dup;
                    match.axesSign = axesSign.dup;
                    match.displacement = disp;
                    return No.each;
                }
                return Yes.each;
            });
    });

    return match;
}

auto parseSensorData(InputStream)(InputStream inputLines)
{
    import std.algorithm : map, splitter;
    import std.array : array;
    import std.conv : parse;
    import std.range : dropOne;

    return inputLines.dropOne // scanner number; ignoring, assuming sequential
    .map!(line => line.splitter(",").map!(a => parse!int(a)).array).array;
}

auto solve(int[][][] sensorsData)
{
    import std.algorithm : cartesianProduct, count, each, filter, map, sort, uniq;
    import std.array : assocArray;
    import std.range : iota, retro;
    import std.typecons : tuple, Tuple;

    sensorsData.each!((ref data) { data.sort; });
    auto idx = iota(0, sensorsData.length);
    Tuple!(ulong, Match)[][ulong] transforms;
    auto transformsPre = cartesianProduct(idx, idx).filter!(a => a[0] != a[1])
        .array
        .retro
        .map!((idxs) {
            auto y = idxs[0];
            auto x = idxs[1];
            auto match = tuple(y, tuple(x, sensorsData[x].matches(sensorsData[y])));
            return match;
        })
        .filter!(a => a[1][1].matching);
    foreach (transform; transformsPre)
    {
        auto key = transform[0];
        if (key !in transforms)
        {
            transforms[key] = [];
        }
        transforms[key] ~= transform[1];
    }

    ulong[][] paths;
    paths.length = sensorsData.length;

    foreach (i; 1 .. sensorsData.length)
    {

        bool[ulong] visited;
        auto toConsider = [[i]];
        while (toConsider.length > 0)
        {
            auto curr = toConsider[$ - 1];
            toConsider = toConsider[0 .. $ - 1];
            if (curr[$ - 1] in visited)
            {
                continue;
            }
            if (curr[$ - 1] == 0)
            {
                paths[i] = curr;
                break;
            }
            foreach (transform; transforms[curr[$ - 1]])
            {
                auto next = transform[0];
                auto nextPath = curr.dup ~ next;
                toConsider ~= nextPath;
            }
            visited[curr[$ - 1]] = true;
        }
    }

    foreach (i; 1 .. sensorsData.length)
    {
        import std.range : slide;

        auto transformed = sensorsData[i];
        foreach (currNext; slide(paths[i], 2))
        {
            auto curr = currNext[0];
            auto next = currNext[1];
            foreach (tform; transforms[curr])
            {
                if (tform[0] == next)
                {
                    auto t = tform[1];
                    transformed = transformed.map!(a => transform(a, t.index, t.axesSign)
                            .add(t.displacement)).array;
                    break;
                }

            }
        }
        sensorsData[i] = [];
        sensorsData[0] ~= transformed;
    }
    return sensorsData[0].sort.uniq.count;
}

int main(string[] argv)
{
    import std.algorithm : splitter;
    import std.array : array;
    import std.stdio : File, writeln;

    immutable filename = argv[1];
    auto inputFile = File(filename);
    auto inputLines = inputFile.byLineCopy.array.splitter("");
    auto sensorsData = inputLines.map!parseSensorData.array;
    immutable ret = solve(sensorsData);
    writeln(ret);
    return 0;
}
