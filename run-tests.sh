#!/usr/bin/env sh
#
# Test execution script for Workshop Organizer Web API (Spring Boot).
# Usage: ./run-tests.sh [springboot]
# Exits: 0 = success, non-zero = failure.
# JUnit XML reports are copied to test-results/ from build/test-results/test/.
#

PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "$0")" && pwd)}"
RESULTS_DIR="${PROJECT_ROOT}/test-results"

usage() {
  echo "Usage: $0 [springboot]"
  echo "  springboot - Run Spring Boot (Gradle) tests (default in this project)"
  echo "Output: JUnit XML in test-results/"
  exit 1
}

clean_test_artifacts() {
  echo "[run-tests] Cleaning previous test artifacts..."
  rm -rf "${RESULTS_DIR:?}"
  mkdir -p "${RESULTS_DIR}"
}

# --- Spring Boot: Gradle test + copy JUnit XML to test-results/ ---
run_spring_boot_tests() {
  cd "${PROJECT_ROOT}" || exit 1
  if [ ! -x "./gradlew" ]; then
    echo "[run-tests] Error: ./gradlew not found or not executable."
    return 1
  fi
  echo "[run-tests] Running Spring Boot tests (./gradlew clean test)..."
  if ! ./gradlew clean test --no-daemon; then
    return 1
  fi
  if [ -d "${PROJECT_ROOT}/build/test-results/test" ]; then
    cp -R "${PROJECT_ROOT}/build/test-results/test/." "${RESULTS_DIR}/"
    echo "[run-tests] JUnit report in ${RESULTS_DIR}/"
  else
    echo "[run-tests] Warning: Gradle test results not found at build/test-results/test"
  fi
  return 0
}

# --- Main ---
main() {
  APP_TYPE="${1:-springboot}"
  case "$APP_TYPE" in
    springboot)
      clean_test_artifacts
      if run_spring_boot_tests; then
        echo "[run-tests] Spring Boot tests passed."
        exit 0
      fi
      echo "[run-tests] Spring Boot tests failed."
      exit 1
      ;;
    *)
      usage
      ;;
  esac
}

main "$@"
