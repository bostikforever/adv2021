module day20_0;

bool toPixel(dchar ch)
{
    assert(ch == '#' || ch == '.');
    return ch == '#' ? true : false;
}

int readValueAt(bool[][] image, ulong x, ulong y)
{
    import std.algorithm : joiner, map, reverse;
    import std.array : array;
    import std.format : unformatValue, singleSpec;
    import std.range : iota;

    auto binString = iota(x - 1, x + 2).map!(a => image[a][y - 1 .. y + 2])
        .joiner
        .map!(b => b ? '1' : '0');

    auto spec = singleSpec("%b");
    auto ret = binString.unformatValue!int(spec);
    return ret;
}

import std.typecons : Tuple;

alias InfiniteImage = Tuple!(bool[][], "image", bool, "infiniteValue");

auto getDefault(bool[] algo, bool infiniteValue)
{
    return algo[infiniteValue ? 0b111_111_111: 0b000_000_000];
}

auto runAlgo(bool[] algo, InfiniteImage infiniteImage)
{
    import std.algorithm : cartesianProduct, count, each, fill, fold;
    import std.array : array;
    import std.range : iota, repeat;

    enum PAD_LENGTH = 2;
    auto image = infiniteImage.image;
    auto origLength = image[0].length;
    auto newLength = origLength + 2 * PAD_LENGTH;
    auto horPad = infiniteImage.infiniteValue.repeat(newLength).array.repeat(PAD_LENGTH)
        .array;
    auto verPad = infiniteImage.infiniteValue.repeat(PAD_LENGTH).array;
    image.each!((ref a) => a = verPad ~ a ~ verPad);
    image = horPad ~ image ~ horPad;
    assert(image.length == image[0].length);

    auto resImage = new bool[][](image.length, image[0].length);
    auto res = InfiniteImage(resImage, algo.getDefault(infiniteImage.infiniteValue));
    resImage.each!((ref a) => a.fill(res.infiniteValue));
    auto range = iota(1, newLength - 1);
    cartesianProduct(range, range).each!((coord) {
        auto value = image.readValueAt(coord.expand);
        resImage[coord[0]][coord[1]] = algo[value];
    });
    return res;
}

auto solve(bool[] algo, bool[][] image)
{
    import std.algorithm : count, joiner;

    auto infiniteImage = InfiniteImage(image, false);
    foreach (i; 0 .. 2)
    {
        infiniteImage = runAlgo(algo, infiniteImage);
        // import std; writeln(infiniteImage.image.map!(a=>a.map!(b=>b?'#':'.')).join('\n'));
    }
    return infiniteImage.image.joiner.count(true);
}

int main(string[] argv)
{
    import std.algorithm : map, splitter;
    import std.array : array;
    import std.range : dropOne, front;
    import std.stdio : File, writeln;

    immutable filename = argv[1];
    auto inputFile = File(filename);
    auto inputLines = inputFile.byLineCopy.array.splitter("");
    auto algo = inputLines.front().front().map!toPixel.array;
    auto imageLines = inputLines.dropOne.front();
    auto image = imageLines
        .map!(a => a.map!toPixel.array)
        .array;
    auto ret = solve(algo, image);
    writeln(ret);
    return 0;
}
