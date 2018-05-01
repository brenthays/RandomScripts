/*
 * query finds how many housing applications were received before a specified date, for a certain semester (defined by arrival date range)
 * for Simply WW2 (old site)
 */

set @before = '2017-05-01';
set @arrivalMin = '2017-06-01';
set @arrivalMax = '2017-10-01';

select z.property_id, z.property_name, count(distinct z.email) as total_apps from (
  select
    (case when a.user_id is not null then u.email else a.email end) as email,
    p.name as property_name,
    p.id as property_id

  from users_properties_applications a

  join properties p
  on p.id = a.property_id

  join payments y
  on y.id = a.payment_id
  and y.amount_paid > 0

  left join users u
  on u.id = a.user_id

  where a.date_arrival between @arrivalMin and @arrivalMax
  and a.is_deleted=0
  and a.date_created < @before
  -- and a.user_id != 11
  -- and a.user_id != 5
  -- and a.user_id != 666
) z

group by z.property_id
