module day12_1;

auto buildGraph(Range)(Range range)
{
    string[][string] graph;
    foreach (line; range)
    {
        auto node1 = line[0];
        auto node2 = line[1];
        graph[node1] ~= node2;
        graph[node2] ~= node1;
    }
    return graph;
}

auto process(Range)(Range range)
{
    import std.range : back, popBack;
    import std.typecons : Tuple;

    auto graph = buildGraph(range);
    enum Start = "start";
    enum End = "end";

    int[string] inPath = [Start: 1];

    alias StackItem = Tuple!(string, size_t, bool);
    StackItem[] visitStack = [StackItem(Start, 0, false)];

    string exception;

    int pathCount = 0;
    while (visitStack.length > 0)
    {
        auto curr = visitStack.back();
        immutable currNode = curr[0];
        auto currNodeIdx = curr[1];
        immutable currIsException = curr[2];

        if (currNode == End)
        {
            immutable isUniquePath = exception.length == 0 || inPath[exception] == 2;
            pathCount += isUniquePath;
            visitStack.popBack();
            inPath.remove(currNode);
            continue;
        }
        immutable isSpecial = (string node) {
            import std.ascii : isLower;

            return node[0].isLower && node != Start;
        };
        immutable currNodeLength = graph[currNode].length;
        if (currNodeIdx >= currNodeLength)
        {
            if (!currIsException && exception.length == 0 && isSpecial(currNode))
            {
                visitStack[$ - 1] = StackItem(currNode, 0, true);
                exception = currNode;
                continue;
            }
            visitStack.popBack();
            if (currNode in inPath)
            {
                inPath[currNode] -= 1;
                if (inPath[currNode] == 0)
                {
                    inPath.remove(currNode);
                }
            }
            if (currNode == exception && currIsException)
            {
                exception = "";
            }
            continue;
        }
        string next;
        // skip to next node not in path
        immutable isValidNext = (string next) {
            return (!(next in inPath)) || (next == exception && inPath[next] == 1);
        };
        while (currNodeIdx < currNodeLength && !isValidNext(next = graph[currNode][currNodeIdx]))
        {
            currNodeIdx++;
        }
        currNodeIdx++;
        visitStack[$ - 1] = StackItem(currNode, currNodeIdx, currIsException);
        if (!isValidNext(next))
        { // implies we have exhausted next nodes
            continue;
        }
        visitStack.assumeSafeAppend() ~= StackItem(next, 0, false);
        if (isSpecial(next))
        {

            inPath[next] += 1;
            assert(inPath[next] <= 2);
        }
    }
    return pathCount;
}

auto parseEdge(char[] s)
{
    import std.typecons : tuple;
    import std.format : formattedRead;

    string left, right;
    s.formattedRead("%s-%s", left, right);
    return tuple(left, right);
}

int main(string[] argv)
{
    import std.algorithm : map;
    import std.stdio : File, writeln;

    immutable filename = argv[1];

    auto inputFile = File(filename);
    auto ret = inputFile.byLine
        .map!parseEdge
        .process;
    writeln(ret);
    return 0;
}
