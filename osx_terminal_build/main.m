#import <MacRuby/MacRuby.h>
int main(int argc, char *argv[])
{
    return macruby_main("osx_terminal_build/terminal_main.rb", argc, argv);
}