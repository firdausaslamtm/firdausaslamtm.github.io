# firdausaslamtm.github.io

# robot-to-pytest-migration

> How and why we migrated a payment test suite from Robot Framework to Pytest — covering architecture decisions, speed improvements, and CI/CD integration.

---

## Why We Migrated

Our legacy Robot Framework suite worked, but it had grown painful to maintain:

| Pain Point | Detail |
|---|---|
| Slow execution | Sequential-only, no native parallelism |
| Keyword abstraction overhead | Debugging failures meant tracing through keyword layers |
| Limited Python integration | Custom logic required awkward keyword wrappers |
| Poor CI fit | Robot's HTML reports didn't integrate cleanly with GitLab CI |

The team needed a suite that a developer could debug directly, run in parallel, and plug into a standard Python ecosystem — so we moved to **Pytest**.

---

## What Was Migrated

The migration covered the **Card Not Present (CNP) authentication layer** — EMVCo 3DS message flows used in MyDebit online transactions.

### Flows Covered

```
Browser / Merchant
       │
       ▼
  [AReq] ──► 3DS Server ──► [ARes]
                  │
                  ▼
           [RReq] ──► [RRes]
                  │
                  ▼
           [PReq] ──► [PRRes]
```

| Message | Description |
|---|---|
| AReq | Authentication Request — sent by merchant |
| ARes | Authentication Response — issued by issuer |
| RReq | Results Request — confirms auth result |
| RRes | Results Response |
| PReq | Preparation Request |
| PRRes | Preparation Response |

---

## Architecture: Before vs After

### Before — Robot Framework

```
robot_suite/
├── resources/
│   ├── Keywords.robot        # 400+ lines of keyword definitions
│   ├── Variables.robot
│   └── CommonSetup.robot
├── tests/
│   ├── CNP_Auth.robot
│   └── Regression.robot
└── results/                  # HTML only, no JUnit XML
```

**Problems:** Keywords called keywords called keywords. A single test failure required tracing 4–5 layers deep. No parallel execution. Output was HTML-only, incompatible with GitLab CI test reports.

---

### After — Pytest

```
pytest_suite/
├── tests/
│   ├── cnp/
│   │   ├── test_areq_ares.py     # AReq / ARes flows
│   │   ├── test_rreq_rres.py     # RReq / RRes flows
│   │   └── test_preq_prres.py    # PReq / PRRes flows
│   └── conftest.py               # Fixtures: sessions, auth headers, env config
├── utils/
│   ├── message_builder.py        # ISO message construction
│   └── validators.py             # Response field assertions
├── pytest.ini
└── .gitlab-ci.yml
```

**Improvements:** Plain Python — debuggable line by line. `pytest-xdist` for parallel execution. JUnit XML output native to CI. Fixtures replace keyword setup/teardown.

---

## Speed Comparison

| Metric | Robot Framework | Pytest |
|---|---|---|
| Full CNP regression | ~40 minutes | **~28 minutes** |
| Execution mode | Sequential | Parallel (`-n auto`) |
| Speed improvement | — | **~30% faster** |
| CI report format | HTML (manual) | JUnit XML (native) |

---

## CI/CD Integration

```yaml
# .gitlab-ci.yml (simplified)
test:regression:
  stage: test
  script:
    - pip install -r requirements.txt
    - pytest tests/ -n auto --junitxml=report.xml -v
  artifacts:
    reports:
      junit: report.xml
    paths:
      - report.xml
    expire_in: 7 days
```

GitLab CI parses the JUnit XML natively — test results appear directly in the merge request UI with pass/fail per test case. No Robot-to-XML conversion step needed.

---

## Key Lessons

**What worked well**

- Fixtures replaced setup/teardown keywords cleanly — less duplication
- `pytest-xdist` parallel execution required zero test redesign (tests were already isolated)
- Inline Python assertions are faster to write and easier to read than keyword chains
- JUnit XML output integrated with GitLab CI, TestRail, and Allure with no extra tooling

**What to watch out for**

- Robot Framework's readable syntax has genuine value for non-developer stakeholders — if your team has BAs writing test cases, reconsider the migration
- Migrating keyword libraries with shared state requires careful fixture scoping (`session` vs `function`)
- Run both suites in parallel during transition to catch any coverage gaps before decommissioning Robot

---

## Tools Used

| Tool | Purpose |
|---|---|
| **Pytest** | Core framework |
| **pytest-xdist** | Parallel test execution |
| **pytest-html / Allure** | Reporting |
| **GitLab CI** | Pipeline + native JUnit XML reports |
| **Docker** | Containerised test environment |

---

*Built by Ahmad Firdaus Aslam — QA Engineer at Payment Network Malaysia (PayNet)*