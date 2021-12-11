import std.bitmanip : BitArray;

auto buildMasks(size_t sideLength)
{
    import std.algorithm : each;
    import std.bitmanip : BitArray;

    BitArray[] masks;
    masks.length = sideLength * 2;

    immutable squareLength = sideLength ^^ 2;
    masks.each!((ref a) => a.length = squareLength);

    // rows
    foreach (i; 0 .. sideLength)
    {
        masks[i][i * sideLength .. (i + 1) * sideLength] = true;
    }

    // columns
    auto columMask = BitArray();
    columMask.length = squareLength;
    foreach (i; 0 .. sideLength)
    {
        columMask[i * sideLength] = true;
    }
    foreach (i; 0 .. sideLength)
    {
        immutable j = i + sideLength;
        masks[j] |= columMask;
        columMask <<= 1;
    }
    return masks;
}

bool checkBoard(BitArray boardBits, BitArray[] masks)
{

    foreach (mask; masks)
    {
        if ((boardBits & mask) == mask)
        {
            return true;
        }
    }
    return false;
}

size_t calculateScore(BitArray boardBits, int[] board, int round)
{
    import std.algorithm : map, sum;

    immutable unsetSum = (~boardBits).bitsSet()
        .map!(a => board[a])
        .sum();
    return unsetSum * round;
}

size_t solve(int[] rounds, int[][] startingBoards, size_t sideLength)
{
    import std.algorithm : each;
    import std.bitmanip : BitArray;

    // init
    auto masks = buildMasks(sideLength);

    BitArray[] boardBits = new BitArray[](startingBoards.length);
    boardBits.each!((ref a) => a.length = sideLength ^^ 2);

    alias EntryMap = size_t[int];
    EntryMap[] entryMaps = new EntryMap[](startingBoards.length);
    foreach (i, ref startingBoard; startingBoards)
    {
        auto entryMap = &(entryMaps[i]);
        foreach (key, val; startingBoard)
        {
            (*entryMap)[val] = key;
        }
    }

    // check
    size_t lastScore;
    bool[size_t] won;
    foreach (round; rounds)
    {
        foreach (i, ref startingBoard; startingBoards)
        {
            auto entryMap = entryMaps[i];
            auto bitIdxPtr = round in entryMap;
            if (!bitIdxPtr)
            {
                continue;
            }
            boardBits[i][*bitIdxPtr] = true;
            if (!(i in won) && checkBoard(boardBits[i], masks))
            {
                lastScore = calculateScore(boardBits[i], startingBoard, round);
                won[i] = true;
            }
        }
    }
    return lastScore;
}

int[][] parseBoard(InputStream)(InputStream inputFile)
{
    import std.algorithm : map, splitter;
    import std.array : array;
    import std.conv : parse;

    int[][] ret;
    ret ~= inputFile.readln
        .splitter
        .map!(a => parse!int(a))
        .array;
    auto sideLength = ret[0].length;
    ret.length = sideLength;
    foreach (i; 1 .. ret[0].length)
    {
        ret[i] = inputFile.readln
            .splitter
            .map!(a => parse!int(a))
            .array;
    }
    inputFile.readln;
    return ret;
}

int main(string[] argv)
{
    import std.algorithm : map, splitter;
    import std.array : array, join;
    import std.conv : parse;
    import std.stdio : File, writeln;

    immutable filename = argv[1];
    auto inputFile = File(filename);
    auto rounds = inputFile.readln
        .splitter(",")
        .map!(a => parse!int(a))
        .array;
    inputFile.readln;

    int[][] startingBoards;
    size_t sideLength;
    while (!inputFile.eof)
    {
        auto board = parseBoard(inputFile);
        sideLength = board.length;
        startingBoards ~= board.join;
    }
    immutable ret = solve(rounds, startingBoards, sideLength);
    writeln(ret);
    return 0;
}
