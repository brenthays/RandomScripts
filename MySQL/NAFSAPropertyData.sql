/**
 * Query  properties and their closest universites, grouped by school
 *
 * min students 25
 * max distance 20 miles
 */

select

    z.id, z.school_id, z.university, z.students, z.property, z.company, z.city, z.state,
    z.latitude, z.longitude, z.occupancy,
    z.price_per_month, z.price_per_night, z.works

from (

    select

        p.id, s.id as school_id, s.name as university, s.students, p.name as 'property',
        m.name as 'company', p.city, p.state, p.occupancy, p.price_per_month,
        p.latitude, p.longitude,
        (p.price_per_month/30*1.45) as 'price_per_night',
        (CASE WHEN p.occupancy < .95 THEN 1 ELSE (CASE WHEN p.occupancy < .97 THEN .5 ELSE 0 END) END) as 'works'


    from properties p

    join schools s
    on ( 3959 * acos( cos( radians( s.latitude ) )
    * cos( radians( p.latitude) )
    * cos( radians( p.longitude ) - radians( s.longitude ) )
    + sin( radians( s.latitude ) )
    * sin( radians( p.latitude ) ) ) ) <= 20
    and s.students >= 25

    left join managers m
    on m.id = p.manager_id

    group by s.id

) z

where z.works > 0;


/**
 * Query  properties and their closest universities, with school data aggregated
 *
 * min students 25
 * max distance 20 miles
 */

select

    z.id, z.universities, z.students, z.property, z.company, z.city, z.state,
    z.latitude, z.longitude, z.occupancy,
    z.price_per_month, z.price_per_night, z.works

from (

    select

        p.id, GROUP_CONCAT(s.name) as universities, SUM(s.students) as students, p.name as 'property',
        m.name as 'company', p.city, p.state, p.occupancy, p.price_per_month,
        p.latitude, p.longitude,
        (p.price_per_month/30*1.45) as 'price_per_night',
        (CASE WHEN p.occupancy < .95 THEN 1 ELSE (CASE WHEN p.occupancy < .97 THEN .5 ELSE 0 END) END) as 'works'


    from properties p

    join schools s
    on ( 3959 * acos( cos( radians( s.latitude ) )
    * cos( radians( p.latitude) )
    * cos( radians( p.longitude ) - radians( s.longitude ) )
    + sin( radians( s.latitude ) )
    * sin( radians( p.latitude ) ) ) ) <= 20
    and s.students >= 25

    left join managers m
    on m.id = p.manager_id

    group by p.id

) z

where z.works > 0;
