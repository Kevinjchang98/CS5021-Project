DELIMITER //
CREATE PROCEDURE `listFlyableAircraft` (idCustomerIn INT)
BEGIN
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
                idCustomer = idCustomerIn
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
                idCustomer = idCustomerIn
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
                idCustomer = idCustomerIn
                AND idRating = 'HP'
        )
        OR aircraft.isHighPerformance = '0'
    ) -- Also check annual date and if maint schedule exists for it?
WHERE
    idCustomer = idCustomerIn
ORDER BY
    class,
    rentalRate;
END//