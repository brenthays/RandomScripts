/**
 * Generates a calendar of availability for a given unit in a specified month & year 
 *
 */

SELECT
    cal.day,
    COUNT(r.id) num_reservations
FROM
(
    SELECT day
    FROM
    (
        SELECT MAKEDATE(:year,1) +
        INTERVAL (:month-1) MONTH +
        INTERVAL daynum DAY day
        FROM
        (
            SELECT t*10+u daynum FROM
            (SELECT 0 t UNION SELECT 1 UNION SELECT 2 UNION SELECT 3) A,
            (SELECT 0 u UNION SELECT 1 UNION SELECT 2 UNION SELECT 3
            UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7
            UNION SELECT 8 UNION SELECT 9) B ORDER BY daynum
        ) AA
    ) AA WHERE MONTH(day) = :month2
) cal
LEFT JOIN (
    SELECT check_in,check_out,id,status,deleted_at,property_unit_id
    FROM reservations
) r
ON cal.day >= r.check_in
AND cal.day < r.check_out
AND (r.status = 'confirmed' OR r.status = 'blocked')
AND r.deleted_at IS NULL
AND r.property_unit_id=:property_unit_id
GROUP BY cal.day
ORDER BY cal.day
