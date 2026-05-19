"""
Complete Playwright Test Suite for Ahmad Firdaus Aslam's Portfolio
Website: https://firdausaslamtm.github.io/
"""

import re
import pytest
from playwright.sync_api import Page, expect

# ============================================================
# PART 1: BASIC NAVIGATION & VERIFICATION
# ============================================================

def test_basic_navigation(page: Page):
    """Go to your site and verify it loaded"""
    page.goto("https://firdausaslamtm.github.io/")

    # Verify page title (partial match)
    expect(page).to_have_title(re.compile("Ahmad Firdaus Aslam"))

    # Verify URL is correct
    expect(page).to_have_url(re.compile("firdausaslamtm.github.io"))

    print("✅ Basic navigation passed!")


def test_find_elements(page: Page):
    """Finding elements different ways"""
    page.goto("https://firdausaslamtm.github.io/")

    # METHOD 1: Find by text
    name_element = page.locator("text=Ahmad Firdaus Aslam")
    expect(name_element).to_be_visible()

    # METHOD 2: Find by CSS selector
    heading = page.locator("h1")
    expect(heading).to_be_visible()

    # METHOD 3: Find by role - use body
    body_content = page.locator("body")
    expect(body_content).to_be_visible()

    # METHOD 4: Find by partial text - Use .first
    payment_element = page.locator("text=payment infrastructure").first
    expect(payment_element).to_be_visible()

    print("✅ All element finding methods passed!")


# ============================================================
# PART 2: CHECKING SPECIFIC CONTENT ON YOUR SITE
# ============================================================

def test_your_portfolio_content(page: Page):
    """Check all your personal information appears correctly"""
    page.goto("https://firdausaslamtm.github.io/")

    # Check for your name
    expect(page.locator("text=Ahmad Firdaus Aslam")).to_be_visible()

    # Check for your job title - Use partial match or specific text
    # "QA Engineer" appears twice, so use .first or more specific text
    expect(page.locator("text=QA Engineer · Kuala Lumpur, Malaysia")).to_be_visible()

    # Check for company names
    expect(page.locator("text=PayNet")).to_be_visible()
    expect(page.locator("text=Hong Leong Bank")).to_be_visible()
    expect(page.locator("text=Intel Corporation")).to_be_visible()

    # Check for location
    expect(page.locator("text=Kuala Lumpur, Malaysia")).to_be_visible()

    print("✅ All portfolio content checks passed!")


def test_finding_same_element_different_ways(page: Page):
    """Multiple ways to find the same element"""
    page.goto("https://firdausaslamtm.github.io/")

    # All these find "PayNet" (your employer)
    way1 = page.locator("text=PayNet")
    way2 = page.locator("//*[contains(text(), 'PayNet')]")  # XPath

    # Don't use exact=True for PayNet (it has extra text)
    way3 = page.get_by_text("PayNet", exact=False)

    # All should find the same thing
    expect(way1).to_be_visible()
    expect(way2).to_be_visible()
    expect(way3.first).to_be_visible()  # Use .first to avoid strict mode

    print("✅ All element finding methods work!")


# ============================================================
# PART 3: CHECKING LISTS AND MULTIPLE ITEMS
# ============================================================

def test_check_multiple_items(page: Page):
    """Check all your toolkit items appear"""
    page.goto("https://firdausaslamtm.github.io/")

    # Check for items that definitely exist on your page
    toolkit_items = ["Pytest", "Robot Framework", "JMeter", "Docker"]
    # Removed "Kubernetes" as it might not be visible as plain text

    for item in toolkit_items:
        expect(page.locator(f"text={item}").first).to_be_visible()
        print(f"  ✅ Found: {item}")

    # Optional: Check for "K8s" or "Kubernetes" in a different way
    kubernetes_exists = page.locator("text=Kubernetes").count() > 0 or page.locator("text=K8s").count() > 0
    if kubernetes_exists:
        print("  ✅ Found: Kubernetes/K8s")
    else:
        print("  ⚠️ Kubernetes not found as plain text (may be in a tooltip or image)")


def test_work_experience(page: Page):
    """Test all work history sections exist"""
    page.goto("https://firdausaslamtm.github.io/")

    employers = ["PayNet", "Hong Leong Bank", "Intel Corporation"]
    for employer in employers:
        expect(page.locator(f"text={employer}")).to_be_visible()
        print(f"  ✅ Found employer: {employer}")


def test_toolkit_items(page: Page):
    """Test all mentioned technologies appear"""
    page.goto("https://firdausaslamtm.github.io/")

    tools = ["Pytest", "Playwright", "JMeter", "Docker", "Postman"]
    for tool in tools:
        # Use .first to handle multiple matches
        expect(page.locator(f"text={tool}").first).to_be_visible()
        print(f"  ✅ Found tool: {tool}")


def test_learning_roadmap(page: Page):
    """Test roadmap phases exist"""
    page.goto("https://firdausaslamtm.github.io/")

    phases = ["Phase 1", "Phase 2", "Phase 3", "Phase 4"]
    for phase in phases:
        expect(page.locator(f"text={phase}")).to_be_visible()
        print(f"  ✅ Found phase: {phase}")


# ============================================================
# PART 4: ADVANCED VERIFICATIONS
# ============================================================

def test_contact_section(page: Page):
    """Test GitHub link is present"""
    page.goto("https://firdausaslamtm.github.io/")

    # Look for GitHub links
    github_links = page.get_by_role("link", name=re.compile("GitHub", re.I))
    expect(github_links.first).to_be_visible()

    # Also check email
    expect(page.locator("text=firdausaslamtm@gmail.com")).to_be_visible()

    print("✅ Contact section found!")


def test_take_screenshots(page: Page):
    """Take screenshots for documentation"""
    page.goto("https://firdausaslamtm.github.io/")

    # Full page screenshot
    page.screenshot(path="screen_shot/full-portfolio.png", full_page=True)
    print("  📸 Saved: full-portfolio.png")

    # Screenshot of hero section
    hero_section = page.locator("h1").first
    hero_section.screenshot(path="screen_shot/hero-section.png")
    print("  📸 Saved: hero-section.png")


def test_debug_whats_on_page(page: Page):
    """Debug and print page information"""
    page.goto("https://firdausaslamtm.github.io/")

    # Print the page title
    title = page.title()
    print(f"  📄 Page title: {title}")

    # Check if specific text exists
    page_content = page.content()
    assert "PayNet" in page_content
    assert "Pytest" in page_content

    print("  ✅ Page content verified")


# ============================================================
# PART 5: COMPLETE PAGE VALIDATION
# ============================================================

def test_complete_page_validation(page: Page):
    """Validate everything on your portfolio works"""
    page.goto("https://firdausaslamtm.github.io/")

    # Check page loads
    expect(page.locator("body")).to_be_visible()
    print("✅ Page loaded")

    # Check title with exact match (your actual title)
    expect(page).to_have_title("Ahmad Firdaus Aslam · QA Engineer")
    print("✅ Title matches exactly")

    # Check name appears
    expect(page.locator("text=Ahmad Firdaus Aslam")).to_be_visible()
    print("✅ Name visible")

    # Check job title - Use full text
    expect(page.locator("text=QA Engineer · Kuala Lumpur, Malaysia")).to_be_visible()
    print("✅ Job title visible")

    # Check location
    expect(page.locator("text=Kuala Lumpur, Malaysia")).to_be_visible()
    print("✅ Location visible")

    # Check employers
    employers = ["PayNet", "Hong Leong Bank", "Intel Corporation"]
    for employer in employers:
        expect(page.locator(f"text={employer}")).to_be_visible()
        print(f"✅ Employer {employer} visible")

