DROP DATABASE IF EXISTS hospital;
CREATE DATABASE hospital;
USE hospital;

CREATE TABLE Room(Room_Number INT PRIMARY KEY, Capacity INT NOT NULL, Nightly_Fee DECIMAL(9,2) NOT NULL);
CREATE TABLE Patient(Patient_ID INT PRIMARY KEY, Name VARCHAR(20) NOT NULL, Address VARCHAR(50), Phone_Number VARCHAR(11));
CREATE TABLE Physician(Physician_ID INT PRIMARY KEY, Name VARCHAR(20) NOT NULL, Certification_Number VARCHAR(30), Field_Of_Expertise VARCHAR(20), Address VARCHAR(50), Phone_Number VARCHAR(11));
CREATE TABLE Nurse(Nurse_ID INT PRIMARY KEY, Name VARCHAR(20) NOT NULL, Certification_Number VARCHAR(20), Address VARCHAR(50), Phone_Number VARCHAR(11));
CREATE TABLE Health_Record(Patient_ID INT NOT NULL, Record_Number INT NOT NULL, Disease_Details VARCHAR(20), Diagnosis_Date DATE, Status VARCHAR(15), Health_Description TEXT, PRIMARY KEY (Patient_ID, Record_Number), FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID));
CREATE TABLE Physician_Order(Order_Code INT PRIMARY KEY, Description VARCHAR(20), Fee DECIMAL(9,2), Physician_ID INT, Patient_ID INT, FOREIGN KEY (Physician_ID) REFERENCES Physician(Physician_ID), FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID));
CREATE TABLE Room_Stay(Stay_ID INT PRIMARY KEY, CheckIn_Date DATE, CheckOut_Date DATE, Patient_ID INT, Room_Number INT, FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID), FOREIGN KEY (Room_Number) REFERENCES Room(Room_Number));
CREATE TABLE Execution (Execution_ID INT PRIMARY KEY, Execution_Date DATE, Status VARCHAR(15), Nurse_ID INT, Order_Code INT, FOREIGN KEY (Nurse_ID) REFERENCES Nurse(Nurse_ID), FOREIGN KEY (Order_Code) REFERENCES Physician_Order(Order_Code));
CREATE TABLE Medication_Administration (Admin_ID INT PRIMARY KEY, Administer_Date DATE, Medication_Type VARCHAR(20), Amount VARCHAR(20), Nurse_ID INT, Patient_ID INT, FOREIGN KEY (Nurse_ID) REFERENCES Nurse(Nurse_ID), FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID));
CREATE TABLE Invoice(Invoice_ID INT PRIMARY KEY, Account_Number INT, Issue_Date DATE, Start_Date DATE, End_Date DATE, Patient_ID INT, FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID));
CREATE TABLE Payment(Payment_ID INT PRIMARY KEY, Payment_Date DATE, Amount_Paid DECIMAL(9,2), Patient_ID INT, FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID));
CREATE TABLE Payable(Payable_ID INT PRIMARY KEY, Amount DECIMAL(9,2), Payable_Date DATE, Description VARCHAR(20), Invoice_ID INT, FOREIGN KEY (Invoice_ID) REFERENCES Invoice(Invoice_ID));

CREATE TABLE Room_Charge(Payable_ID INT PRIMARY KEY, Stay_ID INT, FOREIGN KEY (Payable_ID) REFERENCES Payable(Payable_ID), FOREIGN KEY (Stay_ID) REFERENCES Room_Stay(Stay_ID));
CREATE TABLE Medication_Charge(Payable_ID INT PRIMARY KEY, Admin_ID INT, FOREIGN KEY (Payable_ID) REFERENCES Payable(Payable_ID), FOREIGN KEY (Admin_ID) REFERENCES Medication_Administration(Admin_ID));
CREATE TABLE Execution_Charge(Payable_ID INT PRIMARY KEY, Execution_ID INT, FOREIGN KEY (Payable_ID) REFERENCES Payable(Payable_ID), FOREIGN KEY (Execution_ID) REFERENCES Execution(Execution_ID));

CREATE TABLE Monitors (Physician_ID INT, Patient_ID INT, Start_Date DATE, End_Date DATE, PRIMARY KEY (Physician_ID, Patient_ID, Start_Date), FOREIGN KEY (Physician_ID) REFERENCES Physician(Physician_ID), FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID));