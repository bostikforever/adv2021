import std.typecons : Tuple;

enum Direction : string
{
    U = "up",
    D = "down",
    F = "forward",
    B = "back"
}

alias Step = Tuple!(Direction, int);

int advance(R)(R range)
{
    import std.algorithm : fold;
    import std.typecons : tuple;

    alias State = Tuple!(int, int, int);
    auto advanceStep = function(State state, Step step) {
        final switch (step[0])
        {
        case Direction.U:
            state[2] -= step[1];
            break;
        case Direction.D:
            state[2] += step[1];
            break;
        case Direction.F:
            state[1] += step[1];
            state[0] += state[2] * step[1];
            break;
        case Direction.B:
            state[1] -= step[1];
            break;
        }
        return state;
    };
    auto state = range.fold!advanceStep(tuple(0, 0, 0));
    return state[0] * state[1];
}

auto parseCommand(char[] s)
{
    import std.typecons : tuple;
    import std.format : formattedRead;

    string direction;
    int steps;
    s.formattedRead("%s %s", direction, steps);

    return tuple(cast(Direction)(direction), steps);
}

int main(string[] argv)
{
    import std.algorithm : map;
    import std.stdio : File, writeln;

    immutable filename = argv[1];

    auto inputFile = File(filename);
    auto ret = inputFile.byLine
        .map!parseCommand
        .advance;
    writeln(ret);
    return 0;
}
