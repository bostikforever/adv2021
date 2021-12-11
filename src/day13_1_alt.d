module day13_1_alt;

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

auto plotPoints(Range)(Range range)
{

    import std.algorithm : chunkBy, fold, map;
    import std.array : join;
    import std.conv : to;
    import std.range : chain, only, repeat;
    import std.typecons : tuple;

    return range.chunkBy!(a => a.y)
        .map!((linenumRange) {
            immutable lineNum = linenumRange[0];
            auto lineRange = linenumRange[1];
            return tuple(lineNum, lineRange.fold!((line, dot) {
                    return chain(line, ' '.repeat(dot.x - line.length), only('#')).to!string;
                })(""));
        })
        .fold!((screen, line) {
            immutable newLines = line[0] - screen[1];
            return tuple(chain(screen[0], '\n'.repeat(newLines), line[1]).to!string, line[0]);
        })(tuple("", 0))[0];
}

auto pointLess = (Point lhs, Point rhs) => lhs.y < rhs.y ||
    (lhs.y == rhs.y && lhs.x < rhs.x);

auto solve(Points, Folds)(Points dots, Folds folds)
{
    import std.algorithm : fold, map, sort, uniq;
    import std.array : array;

    auto foldedDots = dots.map!(dot => folds.fold!((d, f) => d.foldWith(f))(dot))
        .array;
    return plotPoints(foldedDots.sort!pointLess.uniq);
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
