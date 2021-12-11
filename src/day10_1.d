module src.day10_1;

static dchar[dchar] PARENS;
static int[dchar] PENALTIES;
static int[dchar] SCORE;

static this()
{

    PARENS = ['(': ')', '[': ']', '{': '}', '<': '>'];
    PENALTIES = [')': 3, ']': 57, '}': 1197, '>': 25_137];
    SCORE = [')': 1, ']': 2, '}': 3, '>': 4];
}

auto scoreLine(R)(R line)
{
    import std.algorithm : fold, map;
    import std.range : back, popBack, retro;

    dchar[] stack;
    foreach (ch; line)
    {
        if (ch in PARENS)
        {
            stack.assumeSafeAppend() ~= ch;
            continue;
        }
        auto top = stack.back();
        if (PARENS[top] != ch)
        {
            return 0;
        }
        stack.popBack();
    }
    return stack.retro
        .map!(a => SCORE[PARENS[a]])
        .fold!((a, b) => a * 5 + b)(0L);
}

auto solve(R)(R range)
{
    import std.algorithm : filter, map, partialSort;
    import std.array;

    auto scores = range.map!scoreLine
        .filter!"a != 0"
        .array;
    auto middle = scores.length / 2;
    scores.partialSort(middle + 1);
    return scores[middle];
}

int main(string[] argv)
{
    import std.stdio : File, writeln;

    immutable filename = argv[1];

    auto inputFile = File(filename);
    immutable ret = inputFile.byLine
        .solve;
    writeln(ret);
    return 0;
}
