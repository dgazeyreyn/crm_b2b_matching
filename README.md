# Analytics Engineering Case Study: Data Quality, Match Accuracy, and Customer Trust

## Overview

This project is an end-to-end analytics engineering case study focused on **data quality, record matching accuracy, manual validation effectiveness, customer trust, and support signals** within a hypothetical B2B data enrichment context.

While the underlying datasets were provided as part of an interview-style case study, the modeling, analysis, and narrative framing were approached as if this were a real production environment. The goal of the project is to demonstrate how an analytics engineer or senior data analyst would:

* Audit and improve data quality
* Identify systemic issues rather than isolated errors
* Design analytics models for downstream BI consumption
* Translate messy, imperfect data into decision-ready insights

The project is intentionally structured to support a **case-file-style dashboard report** that tells a clear, defensible narrative about risk, trust, and exposure.

---

## Core Analytical Questions

The models in this project are designed to support the following narratives:

### 1. Manual Validation Quality

* Are human validators correctly identifying bad matches?
* Are validation errors isolated or systemic?
* Are validators being misled by algorithmic confidence scores?

### 2. Match Confidence vs Reality

* Is the matching algorithm overconfident?
* Does higher confidence actually correlate with correctness?
* Are certain customer segments disproportionately affected?

### 3. Customer Trust vs Data Exposure

* Do customers notice underlying data and match defects?
* Does exposure to defects correlate with lower trust (NPS)?

### 4. Support Signals vs Data Reality

* Do support complaints align with actual data issues?
* Are customers reacting rationally to real defects?
* Which issues generate the highest volume and severity of tickets?

---

## Project Structure

The project follows a layered dbt architecture designed for clarity, maintainability, and BI usability.

### `staging/`

Source-aligned models with light cleaning and standardization. Each subfolder corresponds to a source system (CRM, matching, support, etc.).

Purpose:

* Normalize raw inputs
* Preserve source-level grain
* Avoid business logic

---

### `intermediate/`

Optional transformation layer used for more complex reshaping that does not yet represent business entities.

Currently used sparingly to avoid unnecessary abstraction.

---

### `marts/`

Business-facing entities and quality lenses.

Includes:

* **Dimensions**: tenants, CRM accounts, companies, dates, feedback themes
* **Facts**: matches, manual validations, support tickets, customer health
* **Quality marts**:

  * `mart_company_quality` — internal consistency of company attributes
  * `mart_match_quality` — CRM to company matching outcomes
  * `mart_support_quality` — customer-reported issues and severity

These models are designed to answer *what is happening* without assuming how the data will be visualized.

---

### `platinum/`

Curated, BI-ready models aligned directly to analytical narratives.

Design principles:

* Minimal joins required in downstream reporting
* Clear grain (event-level or tenant-level)
* One story per model

Key Platinum models include:

* Manual validation quality metrics
* Support vs company quality alignment
* Support vs match quality alignment
* Trust vs company quality exposure
* Trust vs match quality exposure

These models intentionally trade flexibility for clarity to support fast, accurate reporting.

---

## Key Design Decisions

* **Separation of defect types**: Company data defects and match defects are modeled independently to avoid conceptual overlap.
* **Validator evaluation adjusted for known defects**: Manual validation accuracy is assessed relative to known data issues, not just validator labels.
* **Tenant-level exposure modeling**: Risk and impact are quantified at the tenant level, including customer segment and annual contract value (ACV).
* **Narrative-first Platinum layer**: Models are built to answer specific business questions rather than serve as generic aggregates.

---

## Intended Outputs

The final output of this project is a case-file-style dashboard report that:

* Highlights systemic data and process failures
* Quantifies customer and revenue exposure
* Contrasts algorithmic confidence with real-world correctness
* Shows how customer behavior (support tickets, NPS) reflects underlying data quality

---

## Notes

* The datasets used in this project were provided as part of a case study and contain intentionally exaggerated issues to surface analytical findings.
* The modeling and analytical approach mirrors how these problems would be investigated and communicated in a real production environment.

---

## Author

David Reynolds

Analytics Engineering / Data Analytics Case Study
