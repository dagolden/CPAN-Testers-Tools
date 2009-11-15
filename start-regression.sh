#!/bin/bash
~/git/cpan-testers-tools/regression.pl        \
  --src /home/david/src/perl-5.10.1/          \
  --old DAGOLDEN/Module-Build-0.35.tar.gz     \
  --new DAGOLDEN/Module-Build-0.35_07.tar.gz  \
  --dir mb-comparison --list mb-list.txt      \
  --extra POE --extra Moose                   \
  --temp /home/david/tmp
