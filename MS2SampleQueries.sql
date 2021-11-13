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

SELECT
    a.idCustomer,
    nameFirst,
    nameLast,
    idRating
FROM
    CustomerHasRating
    RIGHT JOIN (
        SELECT
            Reservation.idCustomer,
            Customer.nameFirst,
            Customer.nameLast
        FROM
            Reservation
            LEFT JOIN Aircraft ON Reservation.idAircraft = Aircraft.idAircraft
            LEFT JOIN Customer ON Reservation.idCustomer = Customer.idCustomer
        WHERE
            isHighPerformance = 1
        GROUP BY
            Reservation.idCustomer
    ) a ON a.idCustomer = CustomerHasRating.idCustomer
ORDER BY
    idCustomer;