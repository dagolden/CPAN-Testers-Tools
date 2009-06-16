#!/bin/bash
~/git/cpan-testers-tools/regression.pl        \
  --src /home/david/src/perl-5.10.0/          \
  --old EWILHELM/Module-Build-0.33.tar.gz     \
  --new DAGOLDEN/Module-Build-0.33_02.tar.gz  \
  --dir mb-comparison --list mb-list.txt      \
  --temp /home/david/tmp
