SELECT * FROM [dbo].Orders_Full
select * from [dbo].Return_Full
GO

-----------------------REMOVE return orders--------------------------------

CREATE OR ALTER VIEW New_Orders AS
WITH Order_ID_Return AS (
     Select Order_ID
     from Orders_Full
     Except
     Select r.Order_ID
     from Orders_Full o
     JOIN Return_Full r On o.Order_ID = r.Order_ID
)
SELECT o.*
from Orders_Full o
join Order_ID_Return oir ON o.Order_ID = oir.Order_ID
GO

Select * from New_Orders

-------------------RFM (method 1: NTILE)------------------------------
-- Score direction: 5 = best, so 555 is the best customer
;with RFM_base as (
    select Customer_Name,
        --get R
        datediff(day, max(Order_Date), '2023-12-31') as R_Values,
        --get F
        count(distinct Order_Date) as F_Values,
        --get M
        round(sum(Sales), 2) as M_Values
    from New_Orders
    group by Customer_Name
)
-- SELECT * FROM RFM_Base
, RFM_Score as (
    select *,
        NTILE(5) OVER (order by R_Values desc) as R_Score,
        NTILE(5) OVER (order by F_Values asc) as F_Score,
        NTILE(5) OVER (order by M_Values asc) as M_Score
    from RFM_base
)
-- SELECT * FROM RFM_Score
, RFM_Final as (
    select *,
        CONCAT(R_Score, F_Score, M_Score) as RFM_Overall
    from RFM_Score
)
-- SELECT * FROM RFM_Final
-- attach the segment name for each RFM code
select f.*, s.Segment
from RFM_Final f
left join [segment scores] s on f.RFM_Overall = s.Scores
order by f.RFM_Overall desc

-------------------RFM (method 2: percentile thresholds)-------------------
-- Score direction: low value = 1, so 115 is the best customer
drop table if exists RFM_RawData;

select h.*,
    ntile(5) over (order by recency) as n_tile_recency,
    percentile_disc(0.2) within group (order by recency) over () as percent_20_recency,
    percentile_disc(0.4) within group (order by recency) over () as percent_40_recency,
    percentile_disc(0.6) within group (order by recency) over () as percent_60_recency,
    percentile_disc(0.8) within group (order by recency) over () as percent_80_recency,

    ntile(5) over (order by frequency) as n_tile_frequency,
    percentile_disc(0.2) within group (order by frequency) over () as percent_20_frequency,
    percentile_disc(0.4) within group (order by frequency) over () as percent_40_frequency,
    percentile_disc(0.6) within group (order by frequency) over () as percent_60_frequency,
    percentile_disc(0.8) within group (order by frequency) over () as percent_80_frequency,

    ntile(5) over (order by monetary) as n_tile_monetary,
    percentile_disc(0.2) within group (order by monetary) over () as percent_20_monetary,
    percentile_disc(0.4) within group (order by monetary) over () as percent_40_monetary,
    percentile_disc(0.6) within group (order by monetary) over () as percent_60_monetary,
    percentile_disc(0.8) within group (order by monetary) over () as percent_80_monetary

into RFM_RawData

from (select Customer_ID,
            datediff(day, max(Order_Date), '2024-01-01') as recency,
            datediff(day, min(Order_Date), '2024-01-01') / count(*) as frequency,
            sum(sales) / count(*) as monetary
      from New_Orders
      group by Customer_ID) h
--select * from RFM_RawData
GO

--========
-- NOTE: run everything from here to the end of the file together.
-- Variables only exist within a single batch.

-- declare variables for recency
declare @percentile_20_r decimal(10, 2);
declare @percentile_40_r decimal(10, 2);
declare @percentile_60_r decimal(10, 2);
declare @percentile_80_r decimal(10, 2);

-- declare variables for frequency
declare @percentile_20_f decimal(10, 2);
declare @percentile_40_f decimal(10, 2);
declare @percentile_60_f decimal(10, 2);
declare @percentile_80_f decimal(10, 2);

-- declare variables for monetary
declare @percentile_20_m decimal(10, 2);
declare @percentile_40_m decimal(10, 2);
declare @percentile_60_m decimal(10, 2);
declare @percentile_80_m decimal(10, 2);

select
    @percentile_20_r = max(percent_20_recency),
    @percentile_40_r = max(percent_40_recency),
    @percentile_60_r = max(percent_60_recency),
    @percentile_80_r = max(percent_80_recency),

    @percentile_20_f = max(percent_20_frequency),
    @percentile_40_f = max(percent_40_frequency),
    @percentile_60_f = max(percent_60_frequency),
    @percentile_80_f = max(percent_80_frequency),

    @percentile_20_m = max(percent_20_monetary),
    @percentile_40_m = max(percent_40_monetary),
    @percentile_60_m = max(percent_60_monetary),
    @percentile_80_m = max(percent_80_monetary)

from RFM_RawData;

-- Output the thresholds to check them
select
    @percentile_20_r as percentile_20_recency,
    @percentile_40_r as percentile_40_recency,
    @percentile_60_r as percentile_60_recency,
    @percentile_80_r as percentile_80_recency,

    @percentile_20_f as percentile_20_frequency,
    @percentile_40_f as percentile_40_frequency,
    @percentile_60_f as percentile_60_frequency,
    @percentile_80_f as percentile_80_frequency,

    @percentile_20_m as percentile_20_monetary,
    @percentile_40_m as percentile_40_monetary,
    @percentile_60_m as percentile_60_monetary,
    @percentile_80_m as percentile_80_monetary
    ;

-- Score each customer against the thresholds and count customers per RFM code
select rb * 100 + fb * 10 + mb as rfm
, count(*) as Num_Cust --Or CustomerID
from (
    select Customer_ID,
        (case   when recency <= @percentile_20_r then 1
                when recency <= @percentile_40_r then 2
                when recency <= @percentile_60_r then 3
                when recency <= @percentile_80_r then 4
                else 5 end) as rb,
        (case   when frequency <= @percentile_20_f then 1
                when frequency <= @percentile_40_f then 2
                when frequency <= @percentile_60_f then 3
                when frequency <= @percentile_80_f then 4
                else 5 end) as fb,
        (case   when monetary <= @percentile_20_m then 1
                when monetary <= @percentile_40_m then 2
                when monetary <= @percentile_60_m then 3
                when monetary <= @percentile_80_m then 4
                else 5 end) as mb
    from RFM_RawData
    ) b
group by rb * 100 + fb * 10 + mb
order by rfm
