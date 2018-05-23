select
    a.name, a.email, u.gender, a.arrival, a.departure,
    a.created_at as 'application_date',
    p.name as 'Property', pu.name as 'Unit',
    (CASE WHEN a.is_private = 1 THEN 'Private' ELSE 'Shared' END) as 'Room Type'

from applications a

left join users u
on a.user_id=u.id

left join properties p
on p.id = a.property_id

left join property_floorplans f
on f.id = a.property_floorplan_id

left join property_units pu
on pu.id = u.property_unit_id

where a.group_id=47 and a.deleted_at is null

group by a.id
