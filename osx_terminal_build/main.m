#import <MacRuby/MacRuby.h>
int main(int argc, char *argv[])
{
    return macruby_main("lib/terminal_main.rb", argc, argv);
}