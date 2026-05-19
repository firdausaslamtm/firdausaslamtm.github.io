#!/bin/bash

# Find the best Python version available
find_python() {
    for py in python3.11 python3.12 python3.10; do
        if command -v $py &> /dev/null; then
            echo $py
            return 0
        fi
    done
    echo "python3"
}

# Setup virtual environment if needed
if [ ! -d "venv" ]; then
    echo "🔧 First time setup - creating virtual environment..."

    PYTHON_CMD=$(find_python)
    echo "Using: $PYTHON_CMD"

    $PYTHON_CMD -m venv venv

    echo "📦 Upgrading pip..."
    ./venv/bin/pip install --upgrade pip

fi

echo "📦 Installing requirements..."
./venv/bin/pip install -r requirements.txt

# Install browsers if needed (handles SSL error)
export NODE_TLS_REJECT_UNAUTHORIZED=0
./venv/bin/playwright install chromium 2>/dev/null || echo "✅ Browsers already installed"

# Create artifacts directory
ARTIFACTS_DIR="artifacts"
mkdir -p "$ARTIFACTS_DIR"

# Show main menu
echo ""
echo "========================================="
echo "  Portfolio Test Runner"
echo "========================================="
echo ""
echo "Select test mode:"
echo "  1) Headless mode (fast, no browser visible)"
echo "  2) Headed mode (watch the browser automate)"
echo ""
read -p "Enter choice (1 or 2): " choice

# Show report type menu
echo ""
echo "========================================="
echo "  Report Options"
echo "========================================="
echo ""
echo "Select report type:"
echo "  1) HTML Report (pytest-html - simple, no extra tools)"
echo "  2) Allure Report (professional, requires 'brew install allure')"
echo "  3) Both reports (HTML + Allure)"
echo ""
read -p "Enter choice (1, 2, or 3): " report_choice

# Clean previous results in artifacts folder
rm -rf "$ARTIFACTS_DIR"/allure-results
rm -rf "$ARTIFACTS_DIR"/allure-report
rm -f "$ARTIFACTS_DIR"/report.html
mkdir -p "$ARTIFACTS_DIR"/allure-results

# Build the base pytest command
BASE_CMD="./venv/bin/pytest tests/test_portfolio.py -v --tb=short"

# Add mode option (headed/headless)
if [ "$choice" == "2" ]; then
    BASE_CMD="$BASE_CMD --headed --slowmo 500"
    echo ""
    echo "👁️  Running in HEADED mode"
else
    echo ""
    echo "🎭 Running in HEADLESS mode"
fi

# Add report options based on user choice
case $report_choice in
    1)
        echo "📊 Generating HTML report (pytest-html)..."
        PYTEST_CMD="$BASE_CMD --html=$ARTIFACTS_DIR/report.html --self-contained-html"
        ;;
    2)
        echo "📊 Generating Allure report..."
        PYTEST_CMD="$BASE_CMD --alluredir=$ARTIFACTS_DIR/allure-results"
        ;;
    3)
        echo "📊 Generating BOTH reports (HTML + Allure)..."
        PYTEST_CMD="$BASE_CMD --html=$ARTIFACTS_DIR/report.html --self-contained-html --alluredir=$ARTIFACTS_DIR/allure-results"
        ;;
    *)
        echo "⚠️  No valid report option selected. Running tests without report..."
        PYTEST_CMD="$BASE_CMD"
        ;;
esac

echo ""
echo "🧪 Running all portfolio tests..."
echo ""

# Run the tests
eval $PYTEST_CMD

# Save exit code
TEST_EXIT_CODE=$?

echo ""
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "🎉 All tests passed!"
else
    echo "❌ Some tests failed. Check output above."
fi

# Handle HTML report viewing
if [[ $report_choice == "1" ]] || [[ $report_choice == "3" ]]; then
    if [ -f "$ARTIFACTS_DIR/report.html" ]; then
        echo ""
        read -p "Open HTML report in browser? (y/n): " view_html
        if [[ $view_html == "y" ]] || [[ $view_html == "Y" ]]; then
            # macOS
            open "$ARTIFACTS_DIR/report.html" 2>/dev/null || \
            # Linux
            xdg-open "$ARTIFACTS_DIR/report.html" 2>/dev/null || \
            # Windows
            start "$ARTIFACTS_DIR/report.html" 2>/dev/null
        fi
    fi
fi

# Handle Allure report - Clear single choice
if [[ $report_choice == "2" ]] || [[ $report_choice == "3" ]]; then
    if command -v allure &> /dev/null; then
        echo ""
        echo "========================================="
        echo "  Allure Report Options"
        echo "========================================="
        echo ""
        echo "What would you like to do?"
        echo "  1) View live report (temporary, auto-refresh)"
        echo "  2) Generate static report (permanent, shareable)"
        echo "  3) Both (view live, then generate static)"
        echo "  4) Skip"
        echo ""
        read -p "Choose (1-4): " allure_choice

        case $allure_choice in
            1)
                echo "📊 Opening live Allure report..."
                echo "Press Ctrl+C when done viewing"
                allure serve "$ARTIFACTS_DIR/allure-results"
                ;;
            2)
                echo "📊 Generating static Allure report..."
                allure generate "$ARTIFACTS_DIR/allure-results" -o "$ARTIFACTS_DIR/allure-report" --clean
                echo "✅ Static report: $ARTIFACTS_DIR/allure-report/index.html"
                open "$ARTIFACTS_DIR/allure-report/index.html" 2>/dev/null
                ;;
            3)
                echo "📊 Opening live Allure report first..."
                echo "Press Ctrl+C when done viewing, then static report will generate"
                allure serve "$ARTIFACTS_DIR/allure-results"

                echo ""
                echo "📊 Now generating static report..."
                allure generate "$ARTIFACTS_DIR/allure-results" -o "$ARTIFACTS_DIR/allure-report" --clean
                echo "✅ Static report: $ARTIFACTS_DIR/allure-report/index.html"
                open "$ARTIFACTS_DIR/allure-report/index.html" 2>/dev/null
                ;;
            *)
                echo "📁 Skipping Allure report"
                echo "Raw results saved in: $ARTIFACTS_DIR/allure-results/"
                ;;
        esac
    else
        echo "❌ Allure not installed. Install with: brew install allure"
        echo "Raw results saved in: $ARTIFACTS_DIR/allure-results/"
    fi
fi

# Show report locations
echo ""
echo "========================================="
echo "  Artifacts Saved"
echo "========================================="
echo "📁 All artifacts are in: $ARTIFACTS_DIR/"
if [[ $report_choice == "1" ]] || [[ $report_choice == "3" ]]; then
    echo "📄 HTML report: $ARTIFACTS_DIR/report.html"
fi
if [[ $report_choice == "2" ]] || [[ $report_choice == "3" ]]; then
    echo "📁 Allure results: $ARTIFACTS_DIR/allure-results/"
    if command -v allure &> /dev/null; then
        echo "📁 Allure static report: $ARTIFACTS_DIR/allure-report/"
    fi
fi

exit $TEST_EXIT_CODE