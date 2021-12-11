module day13_0;

import std.typecons : Tuple;

alias Point = Tuple!(int, "x", int, "y");

auto foldAt = (int point, int foldPoint) => 2 * foldPoint - point;

auto foldXAt = (Point p, int x) => (p.x < x) ? p : Point(p.x.foldAt(x), p.y);

auto foldYAt = (Point p, int y) => (p.y < y) ? p : Point(p.x, p.y.foldAt(y));

enum FoldAxis : char
{
    X = 'x',
    Y = 'y'
}

alias Fold = Tuple!(FoldAxis, "axis", int, "along");

auto foldWith(Point p, Fold fold)
{
    final switch (fold.axis)
    {
    case FoldAxis.X:
        return p.foldXAt(fold.along);
    case FoldAxis.Y:
        return p.foldYAt(fold.along);
    }
}

auto solve(Points, Folds)(Points dots, Folds folds)
{
    import std.algorithm : count, fold, map, sort, uniq;
    import std.array : array;
    import std.range : takeOne;

    auto foldedDots = dots.map!(dot => folds.takeOne.fold!((d, f) => d.foldWith(f))(dot))
        .array;
    return foldedDots.sort.uniq.count;
}

auto parseDots(InputStream)(InputStream lines)
{
    import std.algorithm : map;
    import std.format : formattedRead;

    return lines.map!((line) { Point p; line.formattedRead("%d, %d", p.x, p.y); return p; });
}

auto parseFolds(InputStream)(InputStream lines)
{
    import std.algorithm : map;
    import std.format : formattedRead;

    return lines.map!((line) {
        Fold f;
        char fold;
        line.formattedRead("fold along %c=%d", fold, f.along);
        f.axis = cast(FoldAxis) fold;
        return f;
    });
}

int main(string[] argv)
{
    import std.algorithm : splitter;
    import std.array : array;
    import std.range : dropOne;
    import std.stdio : File, writeln;

    immutable filename = argv[1];
    auto inputFile = File(filename);
    auto inputLines = inputFile.byLineCopy.array.splitter("");
    auto dotLines = inputLines.front();
    auto foldLines = inputLines.dropOne.front();
    auto dots = parseDots(dotLines);
    auto folds = parseFolds(foldLines);
    immutable ret = solve(dots, folds);
    writeln(ret);
    return 0;
}
