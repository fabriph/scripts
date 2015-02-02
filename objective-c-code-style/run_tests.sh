#!/bin/bash
TMP_OUTPUT="test.styleobjc.tmp"

runWithFile () {
  echo -e "\n$1\n"
  ./styleobjc.sh "./test/$1" > $TMP_OUTPUT
 # TODO:What diff tool is better? diff, git diff, colordiff?
  git diff $TMP_OUTPUT "./test/expected-$1"
  rm "$TMP_OUTPUT"
}

runWithFile "colon-spacing.txt"
runWithFile "math-operands.txt"
runWithFile "method-signature.txt"
runWithFile "pointers.txt"

