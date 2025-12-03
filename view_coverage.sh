#!/bin/bash
# View the detailed code coverage report

if [ -f "luacov.report.out" ]; then
    cat luacov.report.out
else
    echo "No coverage report found. Run tests first with: lua tests/run_tests.lua"
    exit 1
fi
