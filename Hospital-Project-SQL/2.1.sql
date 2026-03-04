Room(Room_Number, Capacity, Nightly_Fee)
primary key: {Room_Number}
foreign key: {}

Patient(Patient_ID, Name, Address, Phone_Number)
primary key: {Patient_ID}
foreign key: {}

Physician(Physician_ID, Name, Certification_Number, Field_Of_Expertise, Address, Phone_Number)
primary key: {Physician_ID}
foreign key: {}

Nurse(Nurse_ID, Name, Certification_Number, Address, Phone_Number)
primary key: {Nurse_ID}
foreign key: {}

Health_Record(Patient_ID, Record_Number, Disease_Details, Diagnosis_Date, Status, Health_Description)
primary key: {Patient_ID, Record_Number}
foreign key: {Patient_ID references Patient(Patient_ID)}

Physician_Order(Order_Code, Description, Fee, Physician_ID, Patient_ID)
primary key: {Order_Code}
foreign key: {Physician_ID references Physician(Physician_ID), Patient_ID references Patient(Patient_ID)}

Room_Stay(Stay_ID, CheckIn_Date, CheckOut_Date, Patient_ID, Room_Number)
primary key: {Stay_ID}
foreign key: {Patient_ID references Patient(Patient_ID), Room_Number references Room(Room_Number)}

Execution(Execution_ID, Execution_Date, Status, Nurse_ID, Order_Code)
primary key: {Execution_ID}
foreign key: {Nurse_ID references Nurse(Nurse_ID), Order_Code references Physician_Order(Order_Code)}

Medication_Administration(Admin_ID, Administer_Date, Medication_Type, Amount, Nurse_ID, Patient_ID)
primary key: {Admin_ID}
foreign key: {Nurse_ID references Nurse(Nurse_ID), Patient_ID references Patient(Patient_ID)}

Invoice(Invoice_ID, Account_Number, Issue_Date, Start_Date, End_Date, Patient_ID)
primary key: {Invoice_ID}
foreign key: {Patient_ID references Patient(Patient_ID)}

Payment(Payment_ID, Payment_Date, Amount_Paid, Patient_ID)
primary key: {Payment_ID}
foreign key: {Patient_ID references Patient(Patient_ID)}

Payable(Payable_ID, Amount, Payable_Date, Description, Invoice_ID)
primary key: {Payable_ID}
foreign key: {Invoice_ID references Invoice(Invoice_ID)}

Room_Charge(Payable_ID, Stay_ID)
primary key: {Payable_ID}
foreign key: {Payable_ID references Payable(Payable_ID), Stay_ID references Room_Stay(Stay_ID)}

Medication_Charge(Payable_ID, Admin_ID)
primary key: {Payable_ID}
foreign key: {Payable_ID references Payable(Payable_ID), Admin_ID references Medication_Administration(Admin_ID)}

Execution_Charge(Payable_ID, Execution_ID)
primary key: {Payable_ID}
foreign key: {Payable_ID references Payable(Payable_ID), Execution_ID references Execution(Execution_ID)}

Monitors(Physician_ID, Patient_ID, Start_Date, End_Date)
primary key: {Physician_ID, Patient_ID, Start_Date}
foreign key: {Physician_ID references Physician(Physician_ID), Patient_ID references Patient(Patient_ID)}