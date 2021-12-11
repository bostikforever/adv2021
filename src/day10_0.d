module src.day10_0;

static dchar[dchar] PARENS;
static int[dchar] PENALTIES;

static this()
{

    PARENS = ['(': ')', '[': ']', '{': '}', '<': '>'];
    PENALTIES = [')': 3, ']': 57, '}': 1197, '>': 25_137];
}

auto scoreLine(R)(R line)
{
    import std.range : back, popBack;

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
            return PENALTIES[ch];
        }
        stack.popBack();
    }
    return 0;
}

auto solve(R)(R range)
{
    import std.algorithm : map, sum;

    return range.map!scoreLine.sum;
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
