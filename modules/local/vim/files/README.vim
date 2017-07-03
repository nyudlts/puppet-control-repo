Before building YouCompleteMe enable gcc 5 by doing,

  $ scl enable devtoolset-4 bash

Also upgrade vim to vim8

  $ sudo yum install vim-minimal vim-enhanced

Then build YouCompleteMe

  $ cd ~/.vim/bundle/YouCompleteMe
  $ ./install.py -all
  

TODO

  - Right now it works for centos
    - structure vim::setup for Ceonts and Darwin
    - same goes for init

