module src.day8_1_alt;
/+

ANALYSIS:

  0:      1:      2:      3:      4:
 aaaa    ....    aaaa    aaaa    ....
b    c  .    c  .    c  .    c  b    c
b    c  .    c  .    c  .    c  b    c
 ....    ....    dddd    dddd    dddd
e    f  .    f  e    .  .    f  .    f
e    f  .    f  e    .  .    f  .    f
 gggg    ....    gggg    gggg    ....

  5:      6:      7:      8:      9:
 aaaa    aaaa    aaaa    aaaa    aaaa
b    .  b    .  .    c  b    c  b    c
b    .  b    .  .    c  b    c  b    c
 dddd    dddd    ....    dddd    dddd
.    f  e    f  .    f  e    f  .    f
.    f  e    f  .    f  e    f  .    f
 gggg    gggg    ....    gggg    gggg

 a = 7 - 1
 {c, f} = 1
 {b, d} = 4 - 1
 {e, g} = 8 - (7 U 4) 

0.5 means "half match, only one character matches out of 2":

0: a + 0.5 b_d +     c_f +     e_g => b present
2: a + 0.5 b_d + 0.5 c_f +     e_g => d, f present
3: a + 0.5 b_d +     c_f + 0.5 e_g => d, g present
5: a +     b_d + 0.5 c_f + 0.5 e_g => f, g present
6: a +     b_d + 0.5 c_f +     e_g => f present
9: a +     b_d +     c_f + 0.5 e_g => g present

a is present in all, can drop
normalise values 0.5 and 1 to 0 and 1
construct binary system from the digits
011: 0
001: 2
010: 3
100: 5
101: 6
110: 9
 
 +/

auto decodeOutput(S, R)(S output, R bd, R cf, R eg)
{
    import std.algorithm : count, setIntersection, sort;
    import std.array : array;

    switch (output.length)
    {
    case 2:
        return '1';
    case 3:
        return '7';
    case 4:
        return '4';
    case 7:
        return '8';
    default:
        break;
    }
    auto outputCanon = output.array.sort;
    immutable bdCount = outputCanon.setIntersection(bd).count;
    immutable cfCount = outputCanon.setIntersection(cf).count;
    immutable egCount = outputCanon.setIntersection(eg).count;
    immutable index = ((bdCount - 1) << 2) + ((cfCount - 1) << 1) + ((egCount - 1) << 0);
    final switch (index)
    {
    case 0b011:
        return '0';
    case 0b001:
        return '2';
    case 0b010:
        return '3';
    case 0b100:
        return '5';
    case 0b101:
        return '6';
    case 0b110:
        return '9';
    }
}

auto deduceInput(R)(R input)
{
    import std.algorithm : map, multiwayUnion, setDifference, sort;
    import std.array : array;
    import std.typecons : Tuple;

    alias DecodeState = Tuple!(dchar[], "bd", dchar[], "cf", dchar[], "eg");
    DecodeState ret;

    dchar[] four, seven, eight;
    foreach (digit; input)
    {
        switch (digit.length)
        {
        case 2:
            ret.cf = digit.array.sort.release;
            continue;
        case 3:
            seven = digit.array.sort.release;
            continue;
        case 4:
            four = digit.array.sort.release;
            continue;
        case 7:
            eight = digit.array.sort.release;
            continue;
        default:
            continue;
        }
    }
    ret.bd = four.setDifference(ret.cf).array;
    ret.eg = eight.setDifference(multiwayUnion([seven, four])).array;
    return ret;
}

auto deduceInDecodeOut(RoR)(RoR inOut)
{
    import std.algorithm : map;
    import std.conv : to;

    auto input = inOut.front();
    inOut.popFront();
    auto decodeState = deduceInput(input);

    auto output = inOut.front();
    return output.map!(x => x.decodeOutput(decodeState.bd, decodeState.cf, decodeState.eg))
        .to!int;
}

auto solve(R)(R range)
{
    import std.algorithm : map, sum;

    return range.map!deduceInDecodeOut.sum;
}

int main(string[] argv)
{
    import std.algorithm : map, splitter;
    import std.stdio : File, writeln;

    immutable filename = argv[1];
    auto inputFile = File(filename);
    auto input = inputFile
        .byLine
        .map!(a => a.splitter(" | ")
                .map!(a => a.splitter(" ")));
    immutable ret = solve(input);
    writeln(ret);
    return 0;
}
