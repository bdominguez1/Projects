-- VIEWS

-- VIEW 1: This first view will show how many order physicians made along with the fee for each order. This is useful because we are able to track physician activity and the billing along with it. 
CREATE VIEW Phys_Activity AS
SELECT
	p.Physician_ID, p1.Name AS Physician_Name,
    COUNT(p.Order_Code) AS Total_Orders,
    SUM(p.Fee) AS Total_Order_Fees
FROM
	physician_order p
JOIN physician p1 ON p.Physician_ID = p1.Physician_ID
GROUP BY p.Physician_ID, p1.Name;

-- VIEW 2: This second view showcases which nurses have given medications to patients and when. This is useful as it tracks the medication history of each nurse and patient so if anything goes wrong people can see who is responsible.
CREATE VIEW Nurse_Activity AS
SELECT
	n.Nurse_ID, n.Name AS Nurse_Name,
    p.Patient_ID, p.Name AS Patient_Name,
    m.Medication_Type, m.Amount, m.Administer_Date
FROM
	Nurse n
JOIN medication_administration m ON n.Nurse_ID = m.Nurse_ID
JOIN patient p ON m.Patient_ID = p.Patient_ID;

-- VIEW 3: Shows what type of medications are used often. This is useful because if hospitals don't know how much inventory to get this can help them estimate better how much inventory they should carry of each medication.
CREATE VIEW Medication_Usage AS
SELECT
	Medication_Type, COUNT(*) AS Administration_Count
FROM
	medication_administration
GROUP BY Medication_Type
ORDER BY Administration_Count DESC;

-- TRIGGERS

 -- TRIGGER 1: This trigger checks if a physician submitted a order with a total value of 0. This is useful because it ensures that any services a physician provides is billable and makes sure no one gets away with not paying.
 DELIMITER //
 CREATE TRIGGER free_orders
 BEFORE INSERT ON Physician_Order
 FOR EACH ROW
 BEGIN
	IF NEW.FEE = 0 THEN
		SIGNAL SQLSTATE '45000'
		SET message_text = 'Order must be greater than zero to process';
	END IF;
END;
//
DELIMITER ;
    
-- TRIGGER 2: This trigger checks if Patients have not filled out all their information. This is helpful because in a hospital database you need name and address mainly to be able to bill a patient or to give to a healthcare provider.
DELIMITER //
CREATE TRIGGER wrong_info
BEFORE INSERT ON Patient
FOR EACH ROW
BEGIN
	IF NEW.Name IS  NULL OR NEW.Address IS NULL OR NEW.Phone_Number IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET message_text = 'Patient Info not valid: Need name, address and phone number';
	END IF;
END;
//
DELIMITER ;

-- TRIGGER 3: This trigger makes sure that patients are given the correct dosage. This is useful because it can prevent unsafe dosages from being given to patients and cause a medical error.
DELIMITER //
CREATE TRIGGER med_amount
BEFORE INSERT ON medication_administration
FOR EACH ROW
BEGIN
	IF NEW.Amount NOT LIKE '% mg' AND NEW.Amount NOT LIKE '% doses' AND NEW.Amount NOT LIKE '% units' THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Medication amount must be a safe amount';
    END IF;
END;
//
DELIMITER ;

-- TRANSACTIONS

-- Transaction 1: This transaction updates a patients info if they changed their information or they came back with a new problem. This is useful ebcause it keeps their medical and personal info updated.
START TRANSACTION;

UPDATE patient
SET Address = '1200 W Harrison', Phone_Number = '2222222221'
WHERE Patient_ID = 2;

INSERT INTO health_record (Patient_ID, Record_Number, Disease_Details, Diagnosis_Date, Status, Health_Description)
VALUES (2, 6, 'Cold', '2025-07-31', 'Ongoing', 'Diagonsed with early stage cold');
COMMIT;

-- Transaction 2: This transaction moves a patient to a new room and charges them the room they move to. This is useful because if a transfer happens then it will update the room and billing accordingly.
START TRANSACTION;
UPDATE Room_Stay
SET Room_Number = 5
WHERE Stay_ID = 205;

DELETE FROM Room_Charge
WHERE Payable_ID = 501;

DELETE FROM Payable
WHERE Payable_ID = 501; 

INSERT INTO Payable (Payable_ID, Amount, Payable_Date, Description, Invoice_ID)
VALUES (517, 800.00, '2025-06-30', 'Room Transfer', 101);

INSERT INTO Room_Charge (Payable_ID, Stay_ID)
VALUES (517, 205);
COMMIT;