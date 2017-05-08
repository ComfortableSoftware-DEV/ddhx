module Menu;

import std.stdio;
import Poshub;
import ddhx;

//TODO: When typing g goto menu directly
//TODO: Number searching: Inverted bool (native to platform)
//TODO: String searching: Inverted bool (native to platform)
//TODO: Progress bars (es. when searching)

/**
 * Internal command prompt.
 */
void EnterMenu()
{
    import std.array : split;
    //import std.algorithm.iteration : splitter, filter;
    ClearMsg;
    SetPos(0, 0);
    write(">");
    //TODO: Remove empty entries.
    string[] e = split(readln[0..$-1]);
    //string[] e = splitter(readln[0..$-1], ' ').filter!(a => a != null);

    UpdateOffsetBar;
    if (e.length > 0) {
        switch (e[0]) { // toUpper...
            case "g", "goto":
                if (e.length > 1)
                    switch (e[1])
                    {
                        case "e", "end":
                            Goto(CurrentFile.size - Buffer.length);
                            break;
                        case "s", "h", "home", "start":
                            Goto(0);
                            break;
                        default:
                            GotoStr(e[1]);
                            break;
                    }
                break;
            case "s", "search": // Search
                //TODO: Figure a way to figure out signed numbers.
                //      "sbyte" ? (Very possible!
                if (e.length > 1)
                switch (e[1]) {
                    case "b", "byte":
                        if (e.length > 2)
                            e[1] = e[2];
                        else
                            MessageAlt("Missing argument. (Byte)");
                        goto SEARCH_BYTE;
                    default: goto SEARCH_STRING;
                }
                break;
            case "ss": // Search string
SEARCH_STRING:
//TODO: Search string
                switch (e[1][$ - 2..$ - 1]) {
                    case `"`:  break; // UTF-8
                    case `"w`: break; // UTF-16
                    case `"d`: break; // UTF-32
                    default:
                }
                break;
            case "sb": // Search byte
SEARCH_BYTE:
                if (e.length > 1)
                {
                    import Utils : unformat;
                    long l;
                    if (unformat(e[1], l))
                    {
                        import Searcher : SearchByte;
                        if (l >= 0 && l <= 0xFF)
                        {
                            SearchByte(cast(ubyte)l);
                        }
                        /*else if (l >= -127 && l <= 128)
                        {

                        }*/
                        else
                        {
                            MessageAlt("Unsupported range.");
                            return;
                        }
                    }
                }
                break;
            case "i", "info": PrintFileInfo; break;
            case "o", "offset":
                if (e.length > 1) {
                    switch (e[1][0]) {
                        case 'o': CurrentOffset = OffsetType.Octal; break;
                        case 'd': CurrentOffset = OffsetType.Decimal; break;
                        case 'h': CurrentOffset = OffsetType.Hexadecimal; break;
                        default:
                    }
                    UpdateOffsetBar;
                    UpdateDisplay;
                }
                break;
            case "q", "quit": Exit; break;
            case "about": ShowAbout; break;
            case "version": ShowInfo; break;
            case "h", "help": ShowHelp; break;
            default: MessageAlt("Unknown command: " ~ e[0]); break;
        }
    }
}

void ShowHelp()
{
    //TODO: "Scroll" system and etc. (Important!!)
    //TODO: Not make the help text a string maybe?
    enum helpstr =
`Shortcuts:
q: Quit
h: This help screen

Commands:
g|goto: Goto <FilePosition>
i|info: Display file information
o|offset: Change offset type

Navigation
Up/Down Arrows: Go backward or forward a line (by width)
Left/Right Arrow: Go backward or forward a byte
Home/End: Align by line
^Home/^End: Go to begining or end of file`;
    Clear;
    SetPos(0, 0);
    writeln(helpstr);
    MessageAlt(" q:Return");
    while (1)
    {
        const KeyInfo e = ReadKey;
        switch (e.keyCode)
        {
            case Key.Q:
                UpdateDisplay;
                UpdateOffsetBar;
                UpdatePositionBar;
                return;
            default:
        }
    }
}

private void PrintFileInfo()
{
    import Utils : formatsize;
    import std.format : format;
    import std.file : getAttributes;
    import std.path : baseName;
    const uint a = getAttributes(Filepath);
    char[7] c;
    version (Windows)
    { import core.sys.windows.winnt; // FILE_ATTRIBUTE_*
        c[0] = a & FILE_ATTRIBUTE_READONLY ? 'r' : '-';
        c[1] = a & FILE_ATTRIBUTE_HIDDEN ? 'h' : '-';
        c[2] = a & FILE_ATTRIBUTE_SYSTEM ? 's' : '-';
        c[3] = a & FILE_ATTRIBUTE_ARCHIVE ? 'a' : '-';
        c[4] = a & FILE_ATTRIBUTE_TEMPORARY ? 't' : '-';
        c[5] = a & FILE_ATTRIBUTE_COMPRESSED ? 'c' : '-';
        c[6] = a & FILE_ATTRIBUTE_ENCRYPTED ? 'e' : '-';
    }
    else version (Posix)
    {// import core.sys.posix;
        //TODO: Posix symbolic permissions
        
    }
    MessageAlt(format("%s  %s  %s",
        c, // File attributes
        formatsize(CurrentFile.size), // File formatted size
        baseName(CurrentFile.name))
    );
}

private void ShowAbout()
{
    MessageAlt("Written by dd86k in D. Copyright (c) dd86k 2017");
}

private void ShowInfo()
{
    MessageAlt("Using ddhx version " ~ APP_VERSION);
}