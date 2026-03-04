-- QUERIES

-- JOIN QUERIES
-- Query 1: This JOIN query gets the amount of medication given to a patient and it shows when and who administered it. This is useful to a hospital database because if a patient comes back with issues because of the medication we can see why.
SELECT n.Name AS Nurse_Name, pat.Name AS Patient_Name, m.Medication_Type, m.Amount, m.Administer_Date
FROM Medication_Administration m
JOIN Nurse n ON m.Nurse_ID = n.Nurse_ID
JOIN Patient pat ON m.Patient_ID = pat.Patient_ID;

-- Query 2: This JOIN query lists which physicians are monitoring patients, but also showing how long each physician watches a patient. This is helpful because the monitor table alone can't tell you who since it only shows the ID but here it connects those IDs to actual names making it more readable.
SELECT phys.Name AS Physician_Name, pat.Name AS Patient_Name, m.Start_Date, m.End_Date
FROM Monitors m
JOIN Physician phys ON m.Physician_ID = phys.Physician_ID
JOIN Patient pat ON m.Patient_ID = pat.Patient_ID;

-- Query 3: This JOIN query lists the amount the patient has paid and showcases when the bill was given and when the bill was paid. This is useful because it shows when and which patients made payments.
SELECT pay.Payment_Date, pay.Amount_Paid, pat.Name AS Patient_Name, i.Issue_Date
FROM Payment pay
JOIN Patient pat ON pay.Patient_ID = pat.Patient_ID
LEFT JOIN Invoice i ON pat.Patient_ID = i.Patient_ID;

-- Aggregation Queries
-- Query 1: This query checks how many times a medication was used. It is helpful as it helps hospitals know how much stock to have of each medication in order to save costs.
SELECT Medication_Type, COUNT(*) AS Usage_Count
FROM Medication_Administration
GROUP BY Medication_Type;

-- Query 2: This aggregate query gets the total amount per patient. This is helpful by showing how much each patient has to pay overall.
SELECT i.Patient_ID, pat.Name AS Patient_Name, SUM(pay.Amount) AS Total_Invoice
FROM Invoice i
JOIN Payable pay ON i.Invoice_ID = pay.Invoice_ID
JOIN Patient pat ON i.Patient_ID = pat.Patient_ID
GROUP BY i.Patient_ID, pat.Name;

-- Query 3: This query calculates total number of orders and the avg fee for each type of order. This is helpful because it helps hospitals know which medication is used the most and they can help reduce or increase price.
SELECT Description, COUNT(Order_Code) AS Total_Orders, AVG(Fee) AS Average_Fee
FROM Physician_Order
GROUP BY Description;

-- NESTED Queries
-- Query 1: This nested query gets data on each nurse who has administered a certain amount of medication. This is useful since it can help show which nurses perform better.
SELECT Nurse_ID, Name
FROM Nurse
WHERE Nurse_ID IN (
	SELECT Nurse_ID
    FROM Medication_Administration
    GROUP BY Nurse_ID
    HAVING COUNT(*) = 1
);

-- Query 2: This query returns the most expensive order that a patient got. It is significant because it helps patients see how much their exams cost.
SELECT phys.Order_Code, phys.Description, phys.Fee, phys.Patient_ID
FROM Physician_Order phys
WHERE phys.Fee > ALL (
    SELECT Fee
    FROM Physician_Order
    WHERE Patient_ID = phys.Patient_ID AND Order_Code <> phys.Order_Code
);

-- Query 3: This nested query finds the names of the nurese who haven't given any medicine or medical care to a patient. This is not applicable to my inserts but if new ones were made this would be helpful because it helps out which nurses are not doing their job.
SELECT Name
FROM Nurse
WHERE Nurse_ID NOT IN (
    SELECT DISTINCT Nurse_ID
    FROM Medication_Administration
);

-- REST OF THE QUERIES
-- Query 1: This query shows the status of the work that nurses do and if they completed it or not. This is helpful as it can help determine which nurses are efficient or which nurses are done and can be assigned to something else.
SELECT n.Name AS Nurse_Name, e.Status, phys.Description
FROM Execution e
JOIN Nurse n ON e.Nurse_ID = n.Nurse_ID
JOIN Physician_Order phys ON e.Order_Code = phys.Order_Code
WHERE e.Status = 'Pending';

-- Query 2: This query shows how long a patient stays in a room. This is helpful because we are able to see how much to bill a patient.
SELECT rms.Patient_ID, pat.Name, DATEDIFF(rms.CheckOut_Date, rms.CheckIn_Date) AS Stay_Length
FROM Room_Stay rms
JOIN Patient pat ON rms.Patient_ID = pat.Patient_ID;

-- Query 3: This query gets the total amount that physicians charged. This is helpful since it shows that physicians are able to bill properly.
SELECT phys.Name AS Physician_Name, SUM(physo.Fee) AS Total_Charged
FROM Physician phys
JOIN Physician_Order physo ON phys.Physician_ID = physo.Physician_ID
GROUP BY phys.Name;

-- Query 4: This query finds patients who stay in expensive rooms. This is not really helpful but it is a cool way in seeing who spends the most.
SELECT DISTINCT pat.Name AS Patient_Name, rm.Room_Number, rm.Nightly_Fee
FROM Room_Stay rms
JOIN Room rm ON rms.Room_Number = rm.Room_Number
JOIN Patient pat ON rms.Patient_ID = pat.Patient_ID
WHERE rm.Nightly_Fee = (
    SELECT MAX(Nightly_Fee) FROM Room
);

-- Query 5: This query finds patients who have more than one diagnosis. This is useful since it will alert the hospital and tell them who to prioritize or monitor first.
SELECT Name, Patient_ID
FROM Patient
WHERE Patient_ID IN (
    SELECT Patient_ID
    FROM Health_Record
    GROUP BY Patient_ID
    HAVING COUNT(DISTINCT Disease_Details) > 1
);

-- Query 6: This query shows patients who have not received any order. While the output might be null this is because I have only done the required 5 inserts and didn't account for this but if new inserts were made then this would be useful because it would be used to see who needs to get care.
SELECT pat.Patient_ID, pat.Name
FROM Patient pat
WHERE pat.Patient_ID NOT IN (
    SELECT DISTINCT Patient_ID FROM Physician_Order
);