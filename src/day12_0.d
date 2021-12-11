module day12_0;

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
    import std.ascii : isLower;
    import std.range : back, popBack;
    import std.typecons : Tuple;

    auto graph = buildGraph(range);
    enum Start = "start";
    enum End = "end";
    bool[string] inPath = [Start: true];
    alias StackItem = Tuple!(string, size_t);
    StackItem[] visitStack = [StackItem(Start, 0)];
    int pathCount = 0;
    while (visitStack.length > 0)
    {
        auto curr = visitStack.back();
        immutable currNode = curr[0];
        auto currNodeIdx = curr[1];
        if (currNode == End)
        {
            pathCount += 1;
        }
        immutable currNodeLength = graph[currNode].length;
        if (currNode == End || currNodeIdx >= currNodeLength)
        {
            visitStack.popBack();
            if (currNode in inPath)
            {
                inPath.remove(currNode);
            }
            continue;
        }
        string next;
        // skip to next node not in path
        immutable isValidNext = (string next) {
            return !(next in inPath);
        };
        while (currNodeIdx < currNodeLength && !isValidNext(next = graph[currNode][currNodeIdx]))
        {
            currNodeIdx++;
        }
        currNodeIdx++;
        visitStack[$ - 1] = StackItem(currNode, currNodeIdx);
        if (next in inPath)
        { // implies we have exhausted next nodes
            continue;
        }
        visitStack.assumeSafeAppend() ~= StackItem(next, 0);
        if (next[0].isLower)
        {
            inPath[next] = true;
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
