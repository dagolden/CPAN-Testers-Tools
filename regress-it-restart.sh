#!/bin/bash
~/git/cpan-testers-tools/regression.pl        \
  --tar                                       \
  --old EWILHELM/Module-Build-0.32.tar.gz     \
  --new EWILHELM/Module-Build-0.32_01.tar.gz  \
  --dir mb-comparison --list mb-list.txt      \
  --temp /home/david/tmp
