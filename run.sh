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

# Handle Allure report viewing
if [[ $report_choice == "2" ]] || [[ $report_choice == "3" ]]; then
    echo ""
    read -p "View Allure report? (y/n): " view_allure

    if [[ $view_allure == "y" ]] || [[ $view_allure == "Y" ]]; then
        if command -v allure &> /dev/null; then
            echo "📊 Opening Allure report..."
            allure serve "$ARTIFACTS_DIR/allure-results"
        else
            echo "❌ Allure not installed."
            echo ""
            echo "Install Allure with:"
            echo "  macOS: brew install allure"
            echo "  Linux: sudo apt-add-repository ppa:qameta/allure && sudo apt-get update && sudo apt-get install allure"
            echo "  Windows: scoop install allure"
            echo ""
            echo "Raw Allure results are available in '$ARTIFACTS_DIR/allure-results/' folder"
        fi
    fi
fi

# Generate static Allure report (optional)
if [[ $report_choice == "2" ]] || [[ $report_choice == "3" ]]; then
    if command -v allure &> /dev/null; then
        echo ""
        read -p "Generate static Allure report (can be shared)? (y/n): " gen_static
        if [[ $gen_static == "y" ]] || [[ $gen_static == "Y" ]]; then
            echo "📊 Generating static Allure report in $ARTIFACTS_DIR/allure-report/"
            allure generate "$ARTIFACTS_DIR/allure-results" -o "$ARTIFACTS_DIR/allure-report" --clean
            echo "✅ Static report generated at: $ARTIFACTS_DIR/allure-report/index.html"

            read -p "Open static Allure report? (y/n): " open_static
            if [[ $open_static == "y" ]] || [[ $open_static == "Y" ]]; then
                open "$ARTIFACTS_DIR/allure-report/index.html" 2>/dev/null || \
                xdg-open "$ARTIFACTS_DIR/allure-report/index.html" 2>/dev/null
            fi
        fi
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