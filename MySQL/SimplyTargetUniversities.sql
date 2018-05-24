/**
 * Query uses dump of all US universities, the size of their international program, and available properties to find universities to target
 *
 */

set @minStudents = 25;
set @distanceMax = 20;

select
    x.id as 'school_id', x.name, x.city, x.state, x.students,
    x.total_properties, x.ach_properties, x.ca_properties, x.cardinal_properties,
    x.average_price_per_month,

    (x.average_price_per_month/30*1.45) as average_price_per_night,

    /* priority balances the size of program and how many properties we have near the university */
    round((x.students / 100) * (x.total_properties * .6)) as priority

from (

    select
        z.id, z.name, z.city, z.state, z.students,
        count(distinct z.p_id) as total_properties,
        count(distinct z.p_ach_id) as ach_properties,
        count(distinct z.p_ca_id) as ca_properties,
        count(distinct z.p_car_id) as cardinal_properties,
        AVG(z.price_per_month) as average_price_per_month

    from (

        select
            s.id, s.name, s.city, s.state, s.students,
            p.id as p_id, p_ach.id as p_ach_id, p_ca.id as p_ca_id, p_car.id as p_car_id,
            p.price_per_month

        from schools s

        /* total number of properties within distance to school, regardless of the manager */
        left join properties p
        on ( 3959 * acos( cos( radians( s.latitude ) )
            * cos( radians( p.latitude) )
            * cos( radians( p.longitude ) - radians( s.longitude ) )
            + sin( radians( s.latitude ) )
            * sin( radians( p.latitude ) ) ) ) <= @distanceMax

        /* total number of properties within distance to school with manager_id 3 */
        left join properties p_ach
        on p_ach.manager_id = 3
        and ( 3959 * acos( cos( radians( s.latitude ) )
            * cos( radians( p_ach.latitude) )
            * cos( radians( p_ach.longitude ) - radians( s.longitude ) )
            + sin( radians( s.latitude ) )
            * sin( radians( p_ach.latitude ) ) ) ) <= @distanceMax

        /* total number of properties within distance to school with manager_id 2 */
        left join properties p_ca
        on p_ca.manager_id = 2
        and ( 3959 * acos( cos( radians( s.latitude ) )
            * cos( radians( p_ca.latitude) )
            * cos( radians( p_ca.longitude ) - radians( s.longitude ) )
            + sin( radians( s.latitude ) )
            * sin( radians( p_ca.latitude ) ) ) ) <= @distanceMax

        /* total number of properties within distance to school with manager_id 1 */
        left join properties p_car
        on p_car.manager_id = 1
        and ( 3959 * acos( cos( radians( s.latitude ) )
            * cos( radians( p_car.latitude) )
            * cos( radians( p_car.longitude ) - radians( s.longitude ) )
            + sin( radians( s.latitude ) )
            * sin( radians( p_car.latitude ) ) ) ) <= @distanceMax

        where s.students >= @minStudents

    ) z

    group by z.id

) x

where x.total_properties > 0

order by priority desc
