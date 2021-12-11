module day16_0;

interface PacketVisitor
{
    void beginPacket();
    void recordVersion(int _version);
    void recordType(int type);
    void recordData(long data);
    void endPacket();
}

class VersionAdder : PacketVisitor
{
    int packetCount = 0;
    int versionCount = 0;
    int openPackets = 0;
    int versionSum = 0;

    void beginPacket()
    {
        packetCount++;
        openPackets++;
    }

    void recordVersion(int _version)
    {
        versionCount++;
        assert(versionCount == packetCount);
        versionSum += _version;
    }

    void recordType(int type)
    {
    }

    void recordData(long data)
    {
    }

    void endPacket()
    {
        openPackets--;
        assert(openPackets <= packetCount);
        assert(openPackets >= 0);
    }
}

auto hexToBin(Range)(Range input)
{
    import std.algorithm : joiner, map;
    import std.conv : to;
    import std.format : format;

    return input.map!(a => a.to!string
            .to!int(16).format!"%04b").joiner;
}

import std.range : RefRange;

int takeBits(Range)(RefRange!Range binStream, uint bitCount)
{
    import std.conv : to;
    import std.range : takeExactly;

    auto bits = binStream.takeExactly(bitCount);
    return bits.to!int(2);
}

auto parseVersion(Range)(RefRange!Range binStream, PacketVisitor visitor)
{
    immutable ver = binStream.takeBits(3);
    visitor.recordVersion(ver);
    return ver;
}

auto parseType(Range)(RefRange!Range binStream, PacketVisitor visitor)
{
    immutable type = binStream.takeBits(3);
    visitor.recordType(type);
    return type;
}

void parseData(Range)(RefRange!Range binStream, PacketVisitor visitor)
{
    import std.conv : to;
    import std.range : takeExactly;

    bool cont;
    string dataBits;
    do
    {
        cont = cast(bool) binStream.takeBits(1);
        dataBits ~= binStream.takeExactly(4).to!string;
    }
    while (cont);
    visitor.recordData(dataBits.to!long(2));
}

void parseOperandsByBitsLength(Range)(RefRange!Range binstream, PacketVisitor visitor)
{
    import std.range : inputRangeObject, InputRange, refRange, takeExactly;

    immutable subStreamLength = binstream.takeBits(15);
    InputRange!dchar subStream = binstream.takeExactly(subStreamLength).inputRangeObject;
    while (!subStream.empty)
    {
        auto subStreamRef = refRange(&subStream);
        visitPacket(subStreamRef, visitor);
    }
}

void parseOperandsByCount(Range)(RefRange!Range binstream, PacketVisitor visitor)
{
    immutable operandCount = binstream.takeBits(11);
    foreach (i; 0 .. operandCount)
    {
        visitPacket(binstream, visitor);
    }
}

void parseOperands(Range)(RefRange!Range binStream, PacketVisitor visitor)
{
    immutable lengthType = binStream.takeBits(1);
    final switch (lengthType)
    {
    case 0:
        parseOperandsByBitsLength(binStream, visitor);
        break;
    case 1:
        parseOperandsByCount(binStream, visitor);
        break;
    }
}

void visitPacket(Range)(RefRange!Range binStream, PacketVisitor visitor)
{
    visitor.beginPacket();
    parseVersion(binStream, visitor);
    immutable type = parseType(binStream, visitor);
    switch (type)
    {
    case 4:
        parseData(binStream, visitor);
        break;
    default:
        parseOperands(binStream, visitor);
    }
    visitor.endPacket();
}

void visit(Range)(Range input, PacketVisitor visitor)
{
    import std.algorithm : count, uniq;
    import std.range : refRange;

    auto binStream = input.hexToBin;
    visitPacket(refRange(&binStream), visitor);
    assert(binStream.uniq.count('0') <= 1);
}

auto solve(string hexInputStream)
{
    auto versionVisitor = new VersionAdder;
    hexInputStream.visit(versionVisitor);
    return versionVisitor.versionSum;
}

int main(string[] argv)
{
    import std.algorithm : map, stripRight;
    import std.array : array;
    import std.stdio : File, writeln;

    immutable filename = argv[1];
    auto inputFile = File(filename);
    auto input = inputFile.readln.stripRight('\n');
    immutable ret = solve(input);
    writeln(ret);
    return 0;
}
