#!/bin/sh
export PATH=~/.composer/vendor/bin:$PATH

# Don't load xdebug on CLI
alias php='php -dzend_extension=xdebug.so'

# Drupal Command Line
source "$HOME/.console/console.rc" 2>/dev/null