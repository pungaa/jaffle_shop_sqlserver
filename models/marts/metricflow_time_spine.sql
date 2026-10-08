with

day_offsets as (

    select top (3651)
        row_number() over (order by (select null)) - 1 as day_offset

    from sys.all_objects as first_set

    cross join sys.all_objects as second_set

)

select
    cast(dateadd(day, day_offset - 3650, cast(getdate() as date)) as date) as date_day

from day_offsets
