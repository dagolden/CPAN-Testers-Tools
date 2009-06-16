#!/bin/bash
~/git/cpan-testers-tools/regression.pl        \
  --src /home/david/src/perl-5.10.0/          \
  --old EWILHELM/Module-Build-0.32.tar.gz     \
  --new EWILHELM/Module-Build-0.32_01.tar.gz  \
  --dir mb-comparison --list mb-list.txt      \
  --temp /home/david/tmp
