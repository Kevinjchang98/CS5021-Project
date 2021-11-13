-- Select ID of Aircraft of each Class with soonest annual inspection
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

-- Find the Mechanic that has done the most Maintenance within the last year and Type of Maintenance they’ve performed
SELECT
    mech.*,
    maint.maintType,
    count(*) AS typeFrequency,
    A.mechanicCount AS totalCountPerMechanic
FROM
    Maintenance maint
    JOIN Mechanic mech ON maint.idMechanic = mech.idMechanic
    JOIN (
        SELECT
            idMechanic,
            count(*) AS mechanicCount
        FROM
            Maintenance
        GROUP BY
            idMechanic
        HAVING
            mechanicCount >= (
                SELECT
                    MAX(a1.mechanicCount)
                FROM
                    (
                        SELECT
                            count(*) AS mechanicCount
                        FROM
                            Maintenance
                        GROUP BY
                            idMechanic
                    ) a1
            )
    ) A ON maint.idMechanic = A.idMechanic
GROUP BY
    maint.idMechanic,
    maint.maintType
HAVING
    typeFrequency >= (
        SELECT
            MAX(b1.mechanicCount)
        FROM
            (
                SELECT
                    count(*) AS mechanicCount
                FROM
                    Maintenance
                GROUP BY
                    maintType,
                    idMechanic
            ) b1
    );

-- Select the most frequently flown-together Customer and Instructor pair(s)
SELECT
    instr.idInstructor,
    instr.nameLast AS 'Instructor Last Name',
    instr.nameFirst AS 'Instructor First Name',
    cust.idCustomer,
    cust.nameLast AS 'Customer Last Name',
    cust.nameFirst AS 'Customer First Name',
    timesFlownTogether AS 'Total Times Flown Together'
FROM
    (
        SELECT
            idInstructor,
            idCustomer,
            count(*) AS timesFlownTogether
        FROM
            Reservation
        WHERE
            idInstructor IS NOT NULL
        GROUP BY
            idCustomer,
            idInstructor
        HAVING
            timesFlownTogether = (
                # Finds the max num of flights any customer and instructor have flown together
                SELECT
                    max(count)
                FROM
                    (
                        SELECT
                            count(*) AS count
                        FROM
                            Reservation
                        WHERE
                            idInstructor IS NOT NULL
                        GROUP BY
                            idCustomer,
                            idInstructor
                    ) AS t1
            )
    ) AS t2
    JOIN Customer AS cust ON cust.idCustomer = t2.idCustomer
    JOIN Instructor AS instr ON instr.idInstructor = t2.idInstructor
ORDER BY
    instr.nameLast,
    instr.nameFirst,
    cust.nameLast,
    cust.nameFirst;

-- Select Aircraft that’s been flown the most
SELECT
    idAircraft,
    class,
    tachTime,
    rentalRate
FROM
    Aircraft
WHERE
    tachTime = (
        SELECT
            MAX(tachTime)
        FROM
            Aircraft
    );

-- Select the most used Instructor, their current instruction Rate and largest single Invoice
SELECT
    inst.*,
    CONCAT(
        '$',
        (inst.rate * MAX(inv.hoursBilledInstructor))
    ) AS 'HighestInvoice',
    count(res.idInstructor) AS 'TotalReservationCount'
FROM
    Reservation res
    JOIN Instructor inst ON res.idInstructor = inst.idInstructor
    JOIN Invoice inv ON res.idInvoice = inv.idInvoice
WHERE
    res.idInstructor IS NOT NULL
GROUP BY
    res.idInstructor
HAVING
    TotalReservationCount = (
        SELECT
            MAX(a1.instructorCount)
        FROM
            (
                SELECT
                    count(*) AS instructorCount
                FROM
                    Reservation res1
                WHERE
                    res1.idInstructor IS NOT NULL
                GROUP BY
                    res1.idInstructor
            ) a1
    );

-- Select Aircraft that have gone through more than 15 reservations
SELECT
    ac.idAircraft,
    ac.class,
    res.numReservations AS 'Number of Reservation'
FROM
    Aircraft AS ac
    JOIN (
        SELECT
            idAircraft,
            count(*) AS numReservations
        FROM
            Reservation
        WHERE
            idAircraft IS NOT NULL
        GROUP BY
            idAircraft
        HAVING
            count(*) > 15
    ) AS res ON ac.idAircraft = res.idAircraft
ORDER BY
    class,
    idAircraft;

-- Select all Customers with unpaid Invoices
SELECT
    cust.*,
    inv.idInvoice
FROM
    Customer cust
    JOIN Reservation res ON cust.idCustomer = res.idCustomer
    JOIN Invoice inv ON inv.idInvoice = res.idInvoice
WHERE
    inv.isPaid = 0;

-- Select Customers with more than 5 Reservations that have no Invoices
SELECT
    cust.idCustomer,
    nameLast,
    nameFirst,
    email
FROM
    Customer AS cust
    JOIN (
        SELECT
            idCustomer
        FROM
            Reservation
        WHERE
            idInvoice IS NULL
            AND (datediff(curdate(), dateStart) < 31)
        GROUP BY
            idCustomer
        HAVING
            count(idReservation) > 5
    ) AS res ON res.idCustomer = cust.idCustomer;

-- Select Customers with no saved Payment information that already have Reservations
SELECT
    DISTINCT nameLast,
    nameFirst,
    email
FROM
    (
        SELECT
            cust.idCustomer,
            nameLast,
            nameFirst,
            email
        FROM
            Customer AS cust
            JOIN Reservation AS res ON cust.idCustomer = res.idCustomer
    ) AS custWithRes
    LEFT JOIN PaymentMethod AS pay ON custWithRes.idCustomer = pay.idCustomer
WHERE
    idPaymentMethod IS NULL
ORDER BY
    nameLast,
    nameFirst;

-- Select Instructors that have Reservations within the next 24 hours
SELECT
    inst.*,
    res.idReservation,
    res.idCustomer,
    res.dateStart,
    res.dateEnd
FROM
    Instructor inst
    JOIN Reservation res ON inst.idInstructor = res.idInstructor
WHERE
    res.dateStart >= (NOW() - INTERVAL 1 DAY)
    AND res.idInstructor IS NOT NULL;

-- Select Ratings of Customers that have booked High Performance Aircraft
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

-- Select all people that have .edu emails
SELECT
    email,
    nameFirst,
    nameLast
FROM
    Customer
WHERE
    email LIKE '%.edu'
UNION
SELECT
    email,
    nameFirst,
    nameLast
FROM
    Instructor
WHERE
    email LIKE '%.edu'
UNION
SELECT
    email,
    nameFirst,
    nameLast
FROM
    Mechanic
WHERE
    email LIKE '%.edu';

-- Categorize Customer by frequency of Reservations made
SELECT
    DISTINCT cust.*,
    A1.numberOfReservation,
    CASE
        WHEN A1.numberOfReservation = 1 THEN 'One-time Customer'
        WHEN A1.numberOfReservation >= 2
        AND A1.numberOfReservation < 5 THEN 'Repeated Customer'
        WHEN A1.numberOfReservation >= 5
        AND A1.numberOfReservation < 10 THEN 'Frequent Customer'
        WHEN A1.numberOfReservation >= 10 THEN 'Loyal Customer'
    END customerType
FROM
    Reservation res
    JOIN Customer cust ON res.idCustomer = cust.idCustomer
    JOIN (
        SELECT
            idCustomer,
            COUNT(*) AS 'numberOfReservation'
        FROM
            Reservation
        GROUP BY
            idCustomer
    ) A1 ON res.idCustomer = A1.idCustomer
ORDER BY
    idCustomer;