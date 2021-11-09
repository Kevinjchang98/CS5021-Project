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