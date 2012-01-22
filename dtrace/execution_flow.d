#!/usr/sbin/dtrace -s


macruby$target:::method-entry
{
   printf("%s:%s\n", copyinstr(arg0), copyinstr(arg1));
}

macruby$target:::method-return
{
   printf("%s:%s\n", copyinstr(arg0), copyinstr(arg1));
}