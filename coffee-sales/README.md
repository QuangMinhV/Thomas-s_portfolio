# Coffee Sales Analysis — Power BI Dashboard

An interactive Power BI report analysing six months of transaction data (January – June 2023) from a coffee shop chain with three locations in New York: **Astoria**, **Hell’s Kitchen** and **Lower Manhattan**.

> **Tools:** Power BI Desktop · Power Query · DAX · Star-schema data modelling
>
> **Data:** ~149K transaction rows (date, time, store, product, quantity, unit price) — *Coffee Shop Sales dataset (Maven Analytics)*

## 1. Problem Statement

The business sells coffee, tea, bakery items, drinking chocolate and retail products across three stores, but has no single view of performance. Managers need to answer:

1.  **How are sales trending?** Are revenue, orders and quantity growing month over month?
2.  **When do customers buy?** Which days of the week and hours of the day drive the most revenue, so staffing and stock can be planned?
3.  **What do they buy?** Which categories, product types and individual products lead or lag?
4.  **Where do they buy?** How do the three stores compare?
5.  **What drives revenue?** Is there a relationship between unit price and sales, and can it be used to estimate sales at a given price point?

**Goal:** build a self-service dashboard that answers these questions and supports decisions on staffing, menu, pricing and promotions.

## 2. Process

### 2.1 Data preparation (Power Query)

- Imported the raw transaction table and checked data types (date, time, currency, whole numbers).
- Removed duplicates and checked for nulls in key columns.
- Split the flat file into dimension tables and created surrogate keys (`product_id`, `type_id`, `category_id`, `store_id`).
- Added a `Sales` column (`transaction_qty × unit_price`).

### 2.2 Data model (star schema)

                     Dim_Date ─┐
                     Dim_Time ─┤
                    Dim_Store ─┼──► Fact_Transaction
    Dim_category ─► Dim_Type ─► Dim_Product ─┘

| Table                                       | Purpose                                                                                                              |
|---------------------------------------------|----------------------------------------------------------------------------------------------------------------------|
| `Fact_Transaction`                          | One row per transaction line: product, store, date, time, qty, unit price, sales                                     |
| `Dim_Date`                                  | Calendar table: year, quarter, month, week number, weekday, weekend flag                                             |
| `Dim_Time`                                  | Hour of day for intraday analysis                                                                                    |
| `Dim_Store`                                 | Store location                                                                                                       |
| `Dim_Product` → `Dim_Type` → `Dim_category` | Product hierarchy (snowflaked)                                                                                       |
| Parameter tables                            | `Predicted Unit Price`, `Ranking Option`, `Category/Type Ranking Option`, `Breakdown` (field parameter), `TopBottom` |

### 2.3 DAX measures

Measures are organised in a dedicated `Measure Table` (folders: Sales, Orders, Quantity, Linear Regression, Other).

- **Core KPIs:** `Total Sales`, `Total Orders`, `Total Quantity Sold`
- **Time intelligence:** current month (CM), previous month (PM), MoM growth % and difference for sales, orders and quantity
- **Ranking:** `Product Ranking` and `Category & Type Ranking` use `RANKX` over `ALLSELECTED` and respond to the **Top/Bottom** and **Top N** slicers
- **Linear regression:** slope and intercept computed in DAX with the least-squares formulas (`SUMX` for Σxy and Σx²). The report shows the fitted equation and a **what-if prediction** of sales for a user-selected unit price.
- **Context helpers:** `Selected Product Type` uses `CROSSFILTER(..., BOTH)` so the drill-through page shows the correct product type without changing model relationships.

### 2.4 Report design

| Page                             | What it shows                                                                                                                                                             |
|----------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Monthly Overview**             | KPI cards with sparklines and MoM change, calendar heatmap, weekday vs weekend split, sales by store, day × hour heatmap, category/type Top-N ranking (field parameter)   |
| **Sales Correlation & Forecast** | Price vs sales scatter with trend line, regression formula, what-if price → predicted sales, decomposition tree (category → type → product), product Top/Bottom-N ranking |
| **Product Drillthrough**         | Product and type cards, sales/orders/quantity trend by month for the selected product                                                                                     |
| **Tooltip pages**                | Calendar and day-hour tooltips with details on hover                                                                                                                      |

**Interactivity:** date-range and store slicers, Top/Bottom and Top-N slicers, field parameters, drill-through button with hover/press states, and a reset button built with bookmarks.

## 3. Key Insights

*Month-level examples use February 2023.*

**Trend**

- Total revenue for Jan–Jun 2023 is **\$698.8K**, with a clear **upward trend from March to June**. May and June are the strongest months.
- February dipped: sales **\$76.2K (-6.8% MoM)**, orders **16K (-5.5%)**, quantity **24K (-5.3%)**. This is consistent with fewer trading days in February.

**Timing**

- The **morning peak (7 – 10 AM)** is the busiest period. In February, 8 AM, 9 AM and 10 AM each brought in about **\$8.9K – \$9.7K**, roughly double any afternoon hour (about \$4.2K – \$4.8K).
- **Weekdays generate ~71% of sales** and weekends ~29%, which points to a commuter/office customer base.

**Stores**

- The three stores perform **almost identically**: Hell’s Kitchen \$25.7K, Lower Manhattan \$25.3K and Astoria \$25.1K in February. No single store is under-performing.

**Products**

- **Coffee** is the largest category, followed by **Tea** (\$196.4K over six months). **Bakery** (\$82.3K) and **Drinking Chocolate** (\$72.4K) are smaller but steady.
- Top product types: **Barista Espresso**, **Brewed Chai Tea**, **Hot Chocolate** and **Gourmet Brewed Coffee**.
- Best-selling products over the period: **Sustainably Grown Organic (Lg) \$21.2K**, **Dark Chocolate (Lg) \$21.0K**, **Latte (Rg) \$19.1K**, **Cappuccino (Lg) \$17.6K**, **Morning Sunrise Chai (Lg) \$17.4K**.
- **Large sizes dominate the top-10 list**, so customers are willing to trade up.
- The bottom of the ranking is almost entirely **packaged tea/coffee for retail** (e.g. Serenity Green Tea, English Breakfast, Peppermint, Lemon Grass). Each earns only about **\$1.3K – \$1.5K** over six months.

**Price vs sales**

- Unit price and sales show a strong positive linear relationship (**y = 1.09x + 1.00**). Higher-priced items contribute proportionally more revenue per transaction rather than suppressing demand.

## 4. Recommendations

| #   | Recommendation                                                                                                                                                          | Based on                           |
|-----|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------|
| 1   | **Staff and stock for the 7–10 AM rush.** Add baristas and pre-prepare bakery items before 7 AM, and reduce staffing mid-afternoon.                                     | Hourly heatmap                     |
| 2   | **Grow weekend traffic** with weekend-only bundles (coffee + pastry), brunch items or loyalty double-points.                                                            | 71% / 29% weekday–weekend split    |
| 3   | **Encourage upsizing.** Make Large the default suggestion at the till and price the Rg → Lg step attractively. Large drinks already top the ranking.                    | Top-N product ranking              |
| 4   | **Cross-sell bakery with morning coffee** (e.g. a “morning combo”), since bakery is under-represented relative to coffee traffic.                                       | Category split + peak hours        |
| 5   | **Review the retail range.** Shrink or rotate the lowest-selling packaged teas/coffees, or move them to a promoted display near the counter.                            | Bottom-N product ranking           |
| 6   | **Protect the lead products.** Keep the top 5 (Organic brewed coffee, Dark Chocolate, Latte, Cappuccino, Chai) always in stock, and use them as anchors for promotions. | Top-N ranking + drillthrough trend |
| 7   | **Test premium pricing carefully.** The price–sales relationship suggests room for premium lines. Validate with an A/B test in one store before rolling out.            | Regression / what-if analysis      |
| 8   | **Replicate best practices across stores.** Performance is balanced, so standardise what works (menu, promotions) across all three rather than fixing a weak store.     | Store comparison                   |

## 5. Limitations

- Only **six months** of data, so seasonality (e.g. holiday season) is not visible.
- The data has **no cost or margin** information, so recommendations focus on revenue rather than profit.
