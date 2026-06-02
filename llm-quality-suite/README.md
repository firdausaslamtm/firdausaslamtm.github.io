# firdausaslamtm.github.io

# nextswitch-qa-framework

> Pytest automation framework for validating payment transaction flows on a national payment network.
> Built to support migration from a legacy switch to an in-house payment switch (NextSwitch).

---

## Background

Malaysia's national payment infrastructure processes millions of transactions daily across two major products:

- **MyDebit** — Malaysia's domestic debit scheme
- **Shared ATM Network (SAN)** — interbank ATM transaction network

This framework was built to validate the migration of both products from a legacy switch (Base24 NS4) to an in-house switch (NextSwitch). It covers functional correctness, regression safety, and pre-production performance testing.

**MyDebit** went live in 2025 after full validation using this suite.
**SAN** migration is ongoing, targeting go-live July 2026.

---

## What This Framework Does

```
┌─────────────────────────────────────────────────────┐
│                  Test Orchestration                 │
│                  (Pytest + CI/CD)                   │
└────────────┬───────────────────────┬────────────────┘
             │                       │
     ┌───────▼───────┐       ┌───────▼───────┐
     │  Functional   │       │  Performance  │
     │  Test Suite   │       │  Test Suite   │
     │  (Pytest)     │       │  (JMeter)     │
     └───────┬───────┘       └───────┬───────┘
             │                       │
     ┌───────▼───────────────────────▼───────┐
     │         NextSwitch (Target System)    │
     │  ┌────────────┐   ┌────────────────┐  │
     │  │  MyDebit   │   │      SAN       │  │
     │  └────────────┘   └────────────────┘  │
     └───────────────────────────────────────┘
```

---

## Test Categories

### 1. Functional Tests (Pytest)

| Category | Description | Coverage |
|---|---|---|
| Purchase | Card-present debit purchase flows | Happy path, declines, timeouts |
| Reversal | Transaction reversal and void | Full and partial reversal |
| Inquiry | Balance inquiry, mini statement | All account types |
| ATM Withdrawal | Domestic ATM cash withdrawal | Single and multi-currency |
| Card Not Present | CNP authentication (EMVCo 3DS) | AReq → ARes → RReq → RRes |
| Interbank | Cross-bank transaction routing | Domestic acquiring/issuing |
| Error Handling | Acquirer/issuer timeouts, host down | All ISO 8583 error codes |

### 2. Performance Tests (JMeter)

| Test Type | Objective | Key Metric |
|---|---|---|
| Load Test | Sustained normal volume | TPS, p95 latency |
| Stress Test | Peak load above baseline | Breaking point, error rate |
| Soak Test | Extended run over hours | Memory stability, no drift |

---

## Key Results

| Metric | Before | After |
|---|---|---|
| Manual regression effort | Baseline | **↓ 40%** |
| Regression execution time | ~12 hours | **< 3 hours** |
| Transaction flows covered | — | **500+** |
| SAN flows (in progress) | — | **50+ flows** |

---

## Tech Stack

| Tool | Purpose |
|---|---|
| **Pytest** | Test framework + assertions |
| **Python** | Test scripting, data generation |
| **JMeter** | Performance + load testing |
| **Docker** | Test environment isolation |
| **Jenkins / GitLab CI** | Pipeline automation |
| **Oracle DB / MySQL** | Test data verification |
| **Kibana / Grafana** | Result monitoring and dashboards |

---

## Project Structure

```
nextswitch-qa-framework/
├── tests/
│   ├── functional/
│   │   ├── mydebit/
│   │   │   ├── test_purchase.py
│   │   │   ├── test_reversal.py
│   │   │   └── test_inquiry.py
│   │   └── san/
│   │       ├── test_atm_withdrawal.py
│   │       └── test_interbank.py
│   └── performance/
│       └── jmeter_plans/
├── utils/
│   ├── iso8583_builder.py      # Transaction message builder
│   ├── test_data_factory.py    # Synthetic card/account data
│   └── db_validator.py         # Post-transaction DB checks
├── config/
│   └── environments.yaml       # SIT / UAT environment configs
├── conftest.py
├── pytest.ini
└── README.md
```

---

## CI/CD Pipeline

```
Push → GitLab CI / Jenkins
         │
         ├── Lint + static checks
         ├── Unit tests (utils)
         ├── Functional regression suite
         │     └── Pytest parallel execution (-n auto)
         └── Report → Allure / TestRail
```

---

## Note on Code

This repository contains the **framework architecture and documentation only**. Transaction logic, simulators, and environment credentials are not included — this work was performed on regulated national payment infrastructure under strict data security controls.

---

## Certification

ISTQB Certified Tester Foundation Level (CTFL) — methodology applied throughout.

---

*Built by Ahmad Firdaus Aslam — QA Engineer at Payment Network Malaysia (PayNet)*