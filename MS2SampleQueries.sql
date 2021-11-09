-- Selecting the aircraft in each class with the soonest annual inspection time
SELECT
    class,
    idAircraft,
    annualInspectionDate,
    tachTime
FROM
    Aircraft a1
WHERE
    annualInspectionDate = (
        SELECT
            MIN(annualInspectionDate)
        FROM
            Aircraft a2
        WHERE
            a2.class = a1.class
    )
ORDER BY
    class;

-- Possible stored procedure to select flyable aircraft for a particular customer
SELECT
    idAircraft,
    class,
    tachTime,
    rentalRate,
    annualInspectionDate,
    isTailwheel,
    isComplex,
    isHighPerformance
FROM
    CustomerHasRating
    INNER JOIN aircraft ON class = idRating
    AND (
        aircraft.isTailwheel = EXISTS(
            SELECT
                *
            FROM
                CustomerHasRating
            WHERE
                idCustomer = '447'
                AND idRating = 'TW'
        )
        OR aircraft.isTailWheel = 0
    )
    AND (
        aircraft.isComplex = EXISTS(
            SELECT
                *
            FROM
                CustomerHasRating
            WHERE
                idCustomer = '447'
                AND idRating = 'CP'
        )
        OR aircraft.isComplex = 0
    )
    AND (
        aircraft.isHighPerformance = EXISTS(
            SELECT
                *
            FROM
                CustomerHasRating
            WHERE
                idCustomer = '447'
                AND idRating = 'HP'
        )
        OR aircraft.isHighPerformance = '0'
    ) -- Also check annual date and if maint schedule exists for it?
WHERE
    idCustomer = '499'
ORDER BY
    class,
    rentalRate;