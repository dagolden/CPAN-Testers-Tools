#!/bin/bash
~/git/cpan-testers-tools/regression.pl        \
  --tar                                       \
  --old EXODIST/Test-Simple-1.001014.tar.gz   \
  --new EXODIST/Test-Simple-1.301001_104.tar.gz   \
  --dir comparison --list list.txt      \
