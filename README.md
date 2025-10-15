# 📊 UPI Transaction Funnel Analysis

## 🔹 Overview
An end-to-end **Product Analyst project** analyzing UPI transaction funnels (init → amount_entered → PIN → bank_auth → completed).  
Covers **SQL, Python, and Tableau**, simulating real product analytics work.

---

## 🔹 Problem Statement
Understand user drop-offs in a UPI transaction journey:
- Where do most users drop off?
- How do banks and devices compare?
- What errors cause failures?
- What is the average time-to-complete?

---

## 🔹 Tools Used
- **SQL (DBeaver + SQLite)** → Funnel queries
- **Python (Pandas, Matplotlib, Jupyter)** → Time & Error analysis
- **Tableau Public** → Interactive dashboard

---

## 🔹 Analysis Performed
1. **SQL**
   - Global funnel counts
   - Per-bank and per-device funnels

2. **Python**
   - Average transaction time (init → completed)
   - Error breakdown by bank & device

3. **Tableau**
   - Funnel dashboard with conversion %
   - Segmented funnels (bank/device)
   - Error & time visualizations

---

## 🔹 Key Insights
- Biggest drop-off: **Completed stage (87% after BankAuth)**  
- SBI has longer completion times (~4.2s vs HDFC ~2.9s)  
- Top error: **NETWORK_TIMEOUT (35% of SBI failures)**  
- Overall funnel completion: **79%**  

---

## 🔹 Deliverables
- SQL scripts (`/sql/`)
- Python notebooks (`/python/`)
- Tableau dashboard (`/tableau/`)
- Data samples (`/data/`)

---

## 🔹 Live Dashboard
[Tableau Public Link](https://public.tableau.com/) (insert your published link)

---

## 🔹 Author
👤 **Bhumesh Lalwani**  
 Product Analyst | Skilled in SQL, Python, Tableau
