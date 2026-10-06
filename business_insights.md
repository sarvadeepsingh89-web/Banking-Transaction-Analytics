# Banking Transaction Analytics — Business Insights & Recommendations

> **Dataset Disclosure:** This project utilizes a **synthetic banking dataset containing 5,000 transactions across 500 customers and 8 branches** designed to simulate retail banking operations across Western India in 2025.

---

## 1. Transaction Volume & Seasonal Trends

### Insight 1.1: Volume Variability Across Months
- 📊 **Observation:** Transaction volume fluctuates throughout the year, peaking in July (466 transactions, ₹1.089M) and March (448 transactions, ₹1.091M), with the lowest activity recorded in February (384 transactions, ₹819K). The highest average transaction sizes occurred in September (₹2,632) and June (₹2,628).
- 💡 **Possible explanation/hypothesis:** March volume aligns with fiscal year-end financial settlements, while July may reflect mid-year corporate and retail spending. February's lower volume is partly explained by fewer calendar days (28 days vs 31 days).
- ✅ **Recommended investigation/action:** Evaluate whether volume variations stem strictly from calendar effects or broader customer seasonal cycles. Plan infrastructure capacity and batch processing schedules around historical high-volume windows (March, July, December).

### Insight 1.2: High Overall Success Rate
- 📊 **Observation:** Out of 5,000 total transactions in 2025, 4,683 completed successfully (93.66%), representing ₹11.28M in successful throughput.
- 💡 **Possible explanation/hypothesis:** Core payment processing pipelines operate stably under standard operating loads, but the 6.34% failure rate represents 317 aborted transactions and ₹763K in unfulfilled volume.
- ✅ **Recommended investigation/action:** Conduct root-cause diagnostic audits on failed transactions to identify technical failure codes (gateway timeout, insufficient balance, authentication failure) to assess whether technical improvements can lift success rates toward the 97%+ industry benchmark.

---

## 2. Payment Method & Channel Dynamics

### Insight 2.1: Strong Customer Preference for UPI
- 📊 **Observation:** UPI is the single largest transaction method by volume, capturing 35.7% (1,783 transactions, ₹4.31M) of total activity, followed by Card payments at 24.2% (1,209 transactions, ₹2.81M). Traditional settlement types (NEFT: 9.9%, IMPS: 9.8%, Branch Transfer: 10.3%) account for smaller shares.
- 💡 **Possible explanation/hypothesis:** Retail and SME customers demonstrate a strong behavioral shift toward instant, mobile-first payment rails for everyday banking transactions.
- ✅ **Recommended investigation/action:** Evaluate system throughput capacity on UPI endpoints. Explore extending UPI-centric capabilities (such as recurring mandate auto-pay and merchant QR settlement) while monitoring uptime during high-concurrency periods.

### Insight 2.2: Elevated Failure Rates in Card & IMPS Transactions
- 📊 **Observation:** Card transactions experienced a 7.53% failure rate (91 failures out of 1,209 attempts), and IMPS showed a 7.57% failure rate (37 failures out of 489 attempts). In contrast, NEFT demonstrated the lowest failure rate at 4.83% (24 failures out of 497 attempts).
- 💡 **Possible explanation/hypothesis:** Card transactions involve multi-party authorization loops (issuer, acquirer, card network, OTP gateway) where network latency and user OTP dropouts increase failure risk. NEFT's batch settlement protocol reduces real-time handshake friction.
- ✅ **Recommended investigation/action:** Audit payment gateway partner SLAs for card processing to isolate technical declines (timeout vs. invalid credentials). Review 2-factor authentication drop-off rates on web and mobile checkouts to improve interface responsiveness.

### Insight 2.3: Mobile Channel Failure Friction
- 📊 **Observation:** Transaction volume is distributed relatively evenly across physical and digital channels (Web: 20.3%, ATM: 20.2%, Branch: 20.1%, Mobile: 19.9%, POS: 19.5%). However, the Mobile channel recorded the highest failure rate at 7.45% (74 failures / 993 attempts), compared to POS at 5.85% (57 failures / 975 attempts).
- 💡 **Possible explanation/hypothesis:** Mobile transactions are vulnerable to client-side network switches (e.g. Wi-Fi to cellular data), app session timeouts, and device-level authentication drop-offs.
- ✅ **Recommended investigation/action:** Review mobile application crash logs, API retry policies, and session timeout thresholds. Implement seamless transaction retry prompts within the mobile app before abandoning the transaction flow.

---

## 3. Branch Performance & Geographic Distribution

### Insight 3.1: Geographic Variance in Transaction Activity
- 📊 **Observation:** Branch B008 (Nashik) logged the highest activity with 743 transactions and ₹1.88M in throughput, followed by B002 (Andheri East) with 700 transactions and ₹1.83M. In contrast, B001 (Goregaon East) recorded the lowest volume at 464 transactions and ₹1.11M.
- 💡 **Possible explanation/hypothesis:** Differences in branch transaction volume may stem from local customer account density, varying ratios of SME vs. Retail accounts assigned to the branch, local commercial activity, or differing ATM/counter accessibility rather than inherent operational disparities.
- ✅ **Recommended investigation/action:** Investigate the drivers behind Nashik's higher transaction activity, including customer mix, transaction type, and channel usage, to determine whether replicable factors exist. Perform a demographic and account-density review of the Goregaon East catchment area before reallocating branch resources.

### Insight 3.2: Strong Regional Footprint Outside Core Mumbai
- 📊 **Observation:** Branches in Tier-2 and suburban markets—Nashik (743 txns), Pune Central (633 txns), and Thane (610 txns)—collectively represent 39.7% of total transaction volume and ₹4.74M in value throughput.
- 💡 **Possible explanation/hypothesis:** Emerging commercial and industrial centers outside central Mumbai exhibit high demand for regional retail banking and digital transaction processing.
- ✅ **Recommended investigation/action:** Assess account acquisition and local branch servicing capacity in Pune and Nashik to ensure staffing and self-service kiosk infrastructure keep pace with customer transaction frequency.

---

## 4. Customer Segments & Demographics

### Insight 4.1: Segment Contribution to Value Throughput
- 📊 **Observation:** SME customers (180 accounts) contributed the largest share of volume and value (1,793 transactions, ₹4.39M, average ₹2,450/txn) with a low failure rate (4.91%). Corporate accounts (163 accounts) generated 1,657 transactions (₹4.05M) with a 7.00% failure rate, while Retail accounts (157 accounts) generated 1,550 transactions (₹3.60M) with a 7.29% failure rate.
- 💡 **Possible explanation/hypothesis:** SME clients utilize banking channels frequently for day-to-day vendor and customer payments with established payment workflows. Corporate and retail transactions exhibit higher failure frequencies, possibly related to transaction amount thresholds and authentication steps.
- ✅ **Recommended investigation/action:** Investigate the specific transaction types failing within Corporate accounts (e.g. high-value NEFT/IMPS exceeding limits). Design customized commercial banking service tiers for SME clients to deepen account retention.

### Insight 4.2: Engagement Consistency Across Customer Base
- 📊 **Observation:** The customer base (500 accounts) exhibits an exact mean and median of 10.0 transactions per customer per year (range: 1 to 23 transactions). 25 customers fall into the High Activity tier (>15 transactions, ₹977K total value), 364 in the Medium tier (8–15 transactions, ₹9.64M total value), and 111 in the Low tier (<8 transactions, ₹1.43M total value).
- 💡 **Possible explanation/hypothesis:** The majority (72.8%) of customers engage regularly with the bank on a monthly cadence, indicating healthy account utility across Current (177), Savings (163), and Salary (160) account holders.
- ✅ **Recommended investigation/action:** Profile the 111 low-activity accounts (<8 transactions/year) to assess whether they represent secondary/dormant relationships or recent account openings, and test targeted engagement communications.

---

## 5. Non-Interest Fee Revenue

### Insight 5.1: High Proportion of Zero-Fee Transactions
- 📊 **Observation:** Total fee revenue collected across the entire year was ₹6,958.73, averaging ₹1.39 per transaction. Notably, 3,069 transactions (61.4% of total) incurred zero fees. Furthermore, failed transactions generated zero fee revenue (317 transactions).
- 💡 **Possible explanation/hypothesis:** Basic retail transactions (standard UPI, routine ATM withdrawals within quota, free digital transfers) are zero-rated by design to encourage adoption and comply with regulatory guidelines. Fee revenue is primarily generated from card interchange and specialized corporate transfer charges.
- ✅ **Recommended investigation/action:** Review the current schedule of charges against peer institutions. Without penalizing basic retail access, evaluate fee structures for value-added enterprise services (e.g., instant high-value bulk payroll, API banking, detailed account reconciliation statements).

---

## 6. Strategic Recommendations Framework

Every recommendation follows an evidence-based operational structure:

| Focus Area | Observation | Possible Explanation / Hypothesis | Recommended Investigation / Action |
|---|---|---|---|
| **Digital Channel Reliability** | Mobile channel failure rate is 7.45% (highest across channels); Card failure rate is 7.53%. | Network timeouts, multi-hop authentication friction, or gateway partner latency during peak hours. | Conduct an end-to-end technical diagnostic on mobile payment APIs and payment gateway SLAs. Implement client-side retry recovery prompts to capture aborted transactions. |
| **Regional Activity Optimization** | Nashik (743 txns, ₹1.88M) and Andheri (700 txns, ₹1.83M) outperform Goregaon East (464 txns, ₹1.11M). | Local demographic density, customer segment mix (SME concentration), or branch accessibility differences. | Investigate customer mix and channel preferences at Nashik to determine whether operational practices can be tested at Goregaon East. |
| **UPI Capability Expansion** | UPI represents 35.7% of volume (1,783 transactions) with a moderate 5.61% failure rate. | Overwhelming customer preference for digital and immediate mobile settlement. | Maintain UPI infrastructure redundancy; explore value-added offerings such as UPI AutoPay for billers and recurring payments. |
| **Corporate Payment Support** | Corporate segment failure rate is 7.00% across 1,657 transactions. | Complex approval workflows, transaction limits, or dual-authorization dropouts. | Survey corporate account administrators on payment failure points; review limit management and batch transaction tooling. |
| **Fee Structure Review** | 61.4% of transactions generate ₹0 in fees; total annual fee revenue is ₹6,959. | Free consumer digital payment mandates and standard retail banking concessions. | Maintain fee-free consumer banking while evaluating optional premium services (e.g., dedicated corporate relationship management, automated treasury reporting). |
