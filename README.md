# Thomas — Data Analyst Portfolio

Hi, I'm Thomas. This repository contains my personal data analytics projects. In each project I clean the data, build a Power BI dashboard, and share the insights and recommendations I found.

## Skills

- **Power BI:** dashboards, Power Query, data modelling, DAX
- **SQL Server:** layered data warehouse (landing, staging, marts), views, star schema
- **Excel**
- **Analysis:** KPIs, trends, insights and business recommendations

## Projects

| Project | Description |
|---|---|
| [Hospital ER Analysis](hospital-er/) | Analysis of 9,216 emergency room visits: patient volume, waiting time and patient satisfaction. |
| [Coffee Sales Analysis](coffee-sales/) | Sales analysis for a coffee chain with three stores: sales trends, busiest hours and best-selling products. |
| [Pizza Sales Analysis](pizza-sales/) | One year of orders from a pizza restaurant: peak hours, holiday spikes, best and worst pizzas, ingredient usage and the price-volume link. |
| [Payroll Remediation Analytics](payroll_project/) | SQL Server data warehouse and Power BI report that finds employees paid below their minimum entitlement across 45,607 timesheet rows. |
| [RFM Customer Segmentation](RFM%20Project/) | Customer segmentation of 51,290 retail order lines in SQL Server using RFM analysis, comparing `NTILE` and percentile-threshold scoring. |

Each project folder has a README and screenshots. The Power BI projects include the report file (`.pbix`); the SQL projects include the `.sql` scripts.

## Adding a project to the website

The Projects section of [thomas-vu-portfolio.vercel.app](https://thomas-vu-portfolio.vercel.app) is built from this repository. Any project folder that contains a `project.json` appears on the site, and every push to `main` rebuilds the site within a couple of minutes.

To add a project, put a `project.json` and a cover image in its folder:

```json
{
  "title": "Pizza Sales Analysis",
  "description": "One or two sentences on the data and the main finding.",
  "tools": ["Power BI", "Power Query", "DAX"],
  "categories": ["Power BI"],
  "date": "09/2026",
  "cover": "cover.jpg"
}
```

| Field | What it does |
|---|---|
| `title`, `description` | Card heading and text |
| `tools` | Small tags under the description |
| `categories` | Badge on the image and the filter buttons (for example `Power BI`, `SQL`, `Python`) |
| `date` | Month and year, `MM/YYYY`; cards are sorted newest first |
| `cover` | Image path inside the folder; a 16:9 image about 800 px wide loads fastest |
