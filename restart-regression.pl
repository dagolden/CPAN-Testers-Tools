#!/bin/bash
~/git/cpan-testers-tools/regression.pl        \
  --tar                                       \
  --old EWILHELM/Module-Build-0.33.tar.gz     \
  --new DAGOLDEN/Module-Build-0.33_03.tar.gz  \
  --dir mb-comparison --list mb-list.txt      \
  --temp /home/david/tmp
