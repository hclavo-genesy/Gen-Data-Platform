{% docs date_table_definition %}
**Purpose**
A single calendar table use by tableau for consistent business-day logic.

**Logic**
- GW holiday dates come from `DIM_Holiday` observed dates.
- GW holiday membership is controlled by  `GW_HOLIDAY_POLICY`
- `is_workday = is_weekday AND NOT is_holiday`
- `is_internship_month = is_workday AND month NOT IN (7,8)`
{% enddocs %}