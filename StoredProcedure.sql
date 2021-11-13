DELIMITER //
CREATE PROCEDURE `listFlyableAircraft` (idCustomerIn INT)
BEGIN
SELECT
    Flyable.*,
    max(datePerformed) AS mostRecentMaint
FROM
    Maintenance
    INNER JOIN (
        SELECT
            idAircraft,
            class,
            100HrDueTime - tachTime as timeBefore100Hr,
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
            )
        WHERE
            idCustomer = idCustomerIn
            AND annualInspectionDate > NOW() + INTERVAL 1 DAY
            AND 100HrDueTime - tachTime > 0.1
    ) Flyable ON Maintenance.idAircraft = Flyable.idAircraft
GROUP BY
    Flyable.idAircraft
ORDER BY
    class,
    rentalRate;
END//