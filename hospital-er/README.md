# Hospital Emergency Room Analysis — Power BI Dashboard

An interactive Power BI report analysing **9,216 emergency room (ER) visits** recorded between **April 2019 and October 2020**. It gives hospital management one place to monitor patient volume, waiting times, patient satisfaction and department referrals.

> **Tools:** Power BI Desktop, Power Query, DAX, data modelling
>
> **Data:** `Hospital ER.csv`, one row per ER visit (arrival date and time, patient demographics, wait time, satisfaction score, admission flag, department referral)

## 1. Problem Statement

The emergency department sees about 480 patients every month, but managers have no easy way to see how the department is performing over time. They need to answer:

1.  **How many patients are we seeing?** How does patient volume change month to month?
2.  **How long do patients wait?** What share of patients are seen within the **30-minute target**, and is the average wait improving?
3.  **How satisfied are patients?** What is the average satisfaction score, and what influences it?
4.  **Who are our patients?** What is the mix of gender, age group and race?
5.  **When do patients arrive?** Which days of the week and hours of the day are busiest?
6.  **Where do patients go next?** How many are admitted, and which departments receive the most referrals?

**Goal:** build a dashboard that tracks these KPIs month by month and supports decisions on staffing, patient flow and service quality.

## 2. Process

### 2.1 Data preparation (Power Query)

- Imported the raw CSV file and set data types (date/time, whole numbers, true/false, text).
- Renamed columns to readable names (e.g. `patient_waittime` to `Patient Waittime`).
- Replaced gender codes with full labels: `M` to Male, `F` to Female, `NC` to Not Confirmed.
- Combined first initial and last name into `Patient Full name`.
- Split the arrival timestamp into a separate `Time` column for hour-of-day analysis.

### 2.2 Data model

| Table                | Purpose                                                                                                   |
|----------------------|-----------------------------------------------------------------------------------------------------------|
| `Hospital ER`        | Fact table, one row per ER visit                                                                          |
| `Date Table`         | Calendar table built with `CALENDAR()` over the visit dates: year, month (short/full), day of week        |
| `Measure Table`      | Holds all DAX measures                                                                                    |
| `Measures Parameter` | Field parameter to switch the heatmap between Total Patients, Avg Wait Time and Avg Satisfaction Score |

**Calculated columns** in `Hospital ER`:

| Column                   | Logic                                                              |
|--------------------------|--------------------------------------------------------------------|
| `Admission Status`       | Admitted / Not Admitted, from the admission flag                   |
| `Age Group`              | 10-year bands (0-9, 10-19 … 70-79)                                 |
| `Waittime Status`        | **Within Target** if wait is 30 minutes or less, otherwise **Target Missed** |
| `Hour` and `Hour Group`  | Arrival hour grouped into 2-hour blocks for the heatmap           |

### 2.3 DAX measures

- **Core KPIs:** `Total Patients` (distinct count of Patient ID), `Avg Wait Time`, `Avg Satisfaction Score`, `Total Referred Patients` (patients with a department referral)
- **Month-over-month comparison:** each KPI has a last-month version using `DATEADD(..., -1, MONTH)`, plus the difference and % growth vs last month
- **Share of total:** `% of Total Patients` uses `ALL()` on Admission Status to calculate the admitted / not admitted split
- **Dynamic titles and labels:** `HeatMap Title` changes with the field parameter; `Avg Wait Time Display` formats the wait as "35.3 Min"

### 2.4 Report design

| Page                      | What it shows                                                                                                                                                                                            |
|---------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Monthly View**          | KPI cards with last-month comparison, filtered by year and month slicers. Patient trend, wait-time target status, gender, race, age group, admission status, and a day × hour heatmap that can switch between patients, wait time and satisfaction |
| **Consolidated View**     | The same layout across the full date range (date-range slicer), for an overall picture                                                                                                                  |
| **Satisfaction Overview** | Wait time vs satisfaction by department (scatter), satisfaction by wait time and admission status (line), wait time and satisfaction by age group (combo chart), and a patient detail table          |

**Interactivity:** page navigator, bookmark navigator, year/month and date-range slicers, and a field parameter slicer for the heatmap.

## 3. Key Insights

*Figures cover the full period, April 2019 – October 2020, unless stated otherwise.*

**Patient volume**

- The ER treated **9,216 patients** over 19 months, an average of **about 485 per month**. Volume is **stable**, ranging from **431 (February 2020)** to **530 (August 2020)**, with no clear upward or downward trend.
- Arrivals are spread **evenly across the week**. Monday is the busiest day (1,377 patients) and Friday the quietest (1,260), a difference of less than 10%.
- Arrivals are also spread **evenly across the day**: every hour receives between about 350 and 440 patients, including overnight. **The ER is as busy at midnight as at midday.**

**Waiting time**

- The average wait is **35.3 minutes**, above the **30-minute target**.
- **59% of patients miss the target**; only 41% are seen within 30 minutes.
- Waits range from 10 to 60 minutes, and the average stays between **34 and 37 minutes in every month, on every weekday and in every hour block**. The delay is a **constant, system-wide issue**, not tied to a particular peak time.

**Patient satisfaction**

- The average satisfaction score is **5.0 out of 10**, which is only moderate.
- Only **27% of patients (2,517) gave a score**, so this result is based on a small sample.
- Satisfaction is almost the same for patients seen within target (5.04) and those who missed it (4.96). **Wait time on its own does not explain satisfaction**; other parts of the experience matter.
- By age group, satisfaction is lowest for patients aged **70-79 (4.58)** and **10-19 (4.76)**.
- By referral department, **Renal (4.57)** and **Orthopedics (4.86)** score lowest, and **Gastroenterology (5.80)** scores highest.

**Patient profile and flow**

- The gender split is balanced: **51% male, 49% female**. Age groups from 0-9 to 70-79 are each about 12-13% of patients.
- The largest groups by race are **White (2,571)**, **African American (1,951)** and **Two or More Races (1,557)**. **1,030 patients (11%) declined to identify.**
- **50% of patients are admitted** to hospital.
- **41% (3,816) are referred** to another department. **General Practice (1,840)** and **Orthopedics (995)** receive the most referrals; together they account for about three-quarters of all referrals.

## 4. Recommendations

| #   | Recommendation                                                                                                                                                                                    | Based on                                        |
|-----|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------|
| 1   | **Staff evenly around the clock.** Arrivals do not drop at night or on weekends, so night and weekend rosters should match daytime levels rather than run on reduced teams.                        | Day × hour heatmap, patients by weekday         |
| 2   | **Target the 30-minute wait with process changes, not just extra staff at peak times.** Because waits are high at all hours, review triage, registration and handover steps to find the constant bottleneck. | Wait-time status, wait time by hour and weekday |
| 3   | **Set a measurable goal**, such as raising the share of patients seen within 30 minutes from 41% to 60%, and track it monthly on the Monthly View page.                                        | Wait-time status donut, MoM KPI cards           |
| 4   | **Increase the satisfaction survey response rate** (currently 27%) with a short SMS or tablet survey at discharge, so decisions are based on a representative sample.                           | Satisfaction score coverage                     |
| 5   | **Improve the experience for elderly (70-79) and teenage (10-19) patients**, for example with a dedicated escort or communication protocol, as these groups report the lowest satisfaction.        | Wait time and satisfaction by age group         |
| 6   | **Create fast-track pathways to General Practice and Orthopedics**, which receive about three-quarters of referrals, to free up ER beds and staff sooner.                                          | Department referral scatter                     |
| 7   | **Review the Renal and Orthopedics referral experience**, which has the lowest satisfaction among departments.                                                                                    | Satisfaction by department                      |
| 8   | **Improve demographic data capture.** 11% of patients declined to identify their race; clearer explanations at registration would support equity reporting.                                      | Patients by race                                |

## 5. Limitations

- The dataset has **no clinical information** (diagnosis, triage level, severity), so wait times cannot be compared against urgency.
- Satisfaction scores are available for **only 27% of visits**, so satisfaction results may not represent all patients.
- Each visit has a single wait-time figure; the **total length of stay** in the ER is not recorded.
- The data covers **19 months** (April 2019 – October 2020), which includes the start of the COVID-19 period. No COVID-related change is visible in patient volume.
