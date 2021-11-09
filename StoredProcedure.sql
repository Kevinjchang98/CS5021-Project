DELIMITER / / CREATE PROCEDURE `listFlyableAircraft` (idCustomerIn INT) BEGIN
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
    INNER JOIN Aircraft ON class = idRating
    AND (
        Aircraft.isTailwheel = EXISTS(
            SELECT
                *
            FROM
                CustomerHasRating
            WHERE
                idCustomer = idCustomerIn
                AND idRating = 'TW'
        )
        OR Aircraft.isTailWheel = 0
    )
    AND (
        Aircraft.isComplex = EXISTS(
            SELECT
                *
            FROM
                CustomerHasRating
            WHERE
                idCustomer = idCustomerIn
                AND idRating = 'CP'
        )
        OR Aircraft.isComplex = 0
    )
    AND (
        Aircraft.isHighPerformance = EXISTS(
            SELECT
                *
            FROM
                CustomerHasRating
            WHERE
                idCustomer = idCustomerIn
                AND idRating = 'HP'
        )
        OR Aircraft.isHighPerformance = '0'
    ) -- Also check annual date and if maint schedule exists for it?
WHERE
    idCustomer = idCustomerIn
ORDER BY
    class,
    rentalRate;

END / /