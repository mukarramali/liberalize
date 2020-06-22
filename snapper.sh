# Snapper helps you create snapshot tests in bulk

# Usage:
#   $ ./snapper.sh <components directory>
#   Example:
#     $ ./snapper.sh ./App/components

# Issues:
#   1. export const Component not allowed, you need to create component first and then do export

# In which directory to look for components
if [ -z "$1" ]; then
  echo "Components path not passed!"
  exit
fi

# Enter the directory
cd $1

# Test directory
TEST_DIR="./__tests__"

# If tests directory not present, create one
if [ ! -d "$TEST_DIR" ]; then
  echo "Creating $TEST_DIR directory..."
  mkdir $TEST_DIR
fi

# Get al the component names
components=($(ls | sed -n "s/\.js$//p"))

generateTestTemplate()
{
  # One tests is without passing any props, one with some props, mostly string props
  testTemplate="import React from 'react';
import renderer from 'react-test-renderer';

import $1 from '../$1';

describe('SnapshotTesting', () => {
  it('Without props', () => {
    const tree = renderer
      .create(<$1 />)
      .toJSON();
    expect(tree).toMatchSnapshot();
  });

  // it('With props', () => {
    // const tree = renderer
      // .create(<$1 />)
      // .toJSON();
    // expect(tree).toMatchSnapshot();
  // });
})
"
}

for component in ${components[@]}
do
  componentTestFile="$TEST_DIR/$component.test.js"

  # Create test file only if it doesn't exists already
  if [ ! -f "$componentTestFile" ]; then
    echo "Creating test for $component..."

    # Embed component in test template
    generateTestTemplate $component

    # Insert updated test templated in new test file
    echo "$testTemplate" > $componentTestFile
  fi
done
