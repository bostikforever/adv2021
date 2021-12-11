module day18_1;

class Pair
{
    int value;
    Pair lhs;
    Pair rhs;
    Pair parent;

    string toString(int depth) const @safe pure nothrow
    {
        import std.conv : to;

        if (lhs is null && rhs is null)
        {
            return value.to!string(10);
        }

        return "[" ~ lhs.toString(depth + 1) ~ "," ~ rhs.toString(depth + 1) ~ "]";
    }

    override string toString() const @safe pure nothrow
    {
        return toString(0);
    }
}

bool isNumber(Pair pair)
{
    if (pair is null)
    {
        return false;
    }
    return pair.lhs is null && pair.rhs is null;
}

bool purePair(Pair pair)
{
    if (pair is null)
    {
        return false;
    }
    return pair.lhs.isNumber && pair.rhs.isNumber;
}

void splitNumber(Pair pair)
{
    assert(pair.isNumber && pair.value > 9);

    auto lhsPair = new Pair;
    lhsPair.value = pair.value / 2; // round down
    pair.lhs = lhsPair;
    lhsPair.parent = pair;

    auto rhsPair = new Pair;
    rhsPair.value = (pair.value + 1) / 2; // round up
    pair.rhs = rhsPair;
    rhsPair.parent = pair;
}

Pair getNextNumber(Pair pair)
{
    while (pair.parent && pair.parent.rhs == pair)
    {
        pair = pair.parent;
    }
    if (pair.parent is null)
    {
        return null;
    }
    pair = pair.parent.rhs;
    while (!pair.isNumber)
    {
        pair = pair.lhs;
    }
    return pair;
}

Pair getPrevNumber(Pair pair)
{
    while (pair.parent && pair.parent.lhs == pair)
    {
        pair = pair.parent;
    }
    if (pair.parent is null)
    {
        return null;
    }
    pair = pair.parent.lhs;
    while (!pair.isNumber)
    {
        pair = pair.rhs;
    }
    return pair;
}

bool explodePair(Pair pair, int depth = 0)
{
    if (pair is null)
    {
        return false;
    }

    if (explodePair(pair.lhs, depth + 1))
    {
        return true;
    }

    if (depth == 4 && pair.purePair)
    {
        auto lastNumber = getPrevNumber(pair);
        if (lastNumber !is null)
        {
            lastNumber.value += pair.lhs.value;
        }
        auto nextNumber = getNextNumber(pair);
        if (nextNumber !is null)
        {
            nextNumber.value += pair.rhs.value;
        }
        pair.lhs = null;
        pair.rhs = null;
        pair.value = 0;
        return true;
    }

    if (explodePair(pair.rhs, depth + 1))
    {
        return true;
    }
    return false;
}

bool splitPair(Pair pair, int depth = 0)
{
    if (pair is null)
    {
        return false;
    }

    if (splitPair(pair.lhs, depth + 1))
    {
        return true;
    }

    if (pair.isNumber && pair.value > 9)
    {
        splitNumber(pair);
        return true;
    }

    if (splitPair(pair.rhs, depth + 1))
    {
        return true;
    }
    return false;
}

bool normalizePair(Pair pair)
{
    if (explodePair(pair))
    {
        return true;
    }
    if (splitPair(pair))
    {
        return true;
    }
    return false;
}

void linkParentToChild(Pair parent, Pair child)
{
    if (parent.lhs is null)
    {
        parent.lhs = child;
        child.parent = parent;
    }
    else
    {
        parent.rhs = child;
        child.parent = parent;
    }
}

auto parse(Range)(Range line)
{
    import std.range : back, empty, popBack;

    Pair[] stack;
    Pair pair;

    foreach (ch; line)
    {
        switch (ch)
        {
        case '[':
            stack.assumeSafeAppend() ~= new Pair;
            break;
        case ']':
            pair = stack.back();
            stack.popBack();
            if (!stack.empty)
            {
                auto parentPair = stack.back();
                linkParentToChild(parentPair, pair);
            }
            break;
        case ',':
            pair = stack.back();
            assert(pair.lhs !is null);
            assert(pair.rhs is null);
            break;
        default:
            auto parentPair = stack.back();
            assert(parentPair !is null);
            pair = new Pair;
            pair.value = ch - '0';
            assert(pair.value < 10 && pair.value >= 0);
            linkParentToChild(parentPair, pair);
        }
    }

    return pair;
}

void normalizeCompletely(Pair pair)
{
    while (pair.normalizePair)
    {
    }
}

auto magnitude(Pair pair)
{
    assert(pair !is null);
    if (pair.isNumber)
    {
        return pair.value;
    }
    return 3UL * magnitude(pair.lhs) + 2UL * magnitude(pair.rhs);
}

auto addPair(Pair lhs, Pair rhs)
{
    auto ret = new Pair;
    ret.lhs = lhs;
    lhs.parent = ret;
    ret.rhs = rhs;
    rhs.parent = ret;
    ret.normalizeCompletely;
    return ret;
}

auto solve(Range)(Range input)
{
    import std.algorithm : fold, map;

    auto retPair = input.map!parse
        .fold!addPair;
    return retPair.magnitude;
}

int main(string[] argv)
{
    import std.stdio : File, writeln;

    immutable filename = argv[1];
    auto inputFile = File(filename);
    auto lines = inputFile.byLine;
    immutable ret = solve(lines);
    writeln(ret);
    return 0;
}
