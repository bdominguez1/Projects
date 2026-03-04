INSERT INTO Room VALUES (1, 5, 50.00);
INSERT INTO Room VALUES (2, 4, 100.00);
INSERT INTO Room VALUES (3, 3, 200.00);
INSERT INTO Room VALUES (4, 2, 400.00);
INSERT INTO Room VALUES (5, 1, 800.00);

INSERT INTO Patient VALUES (1, 'PatOne', '123 Lasalle St', '1111111111');
INSERT INTO Patient VALUES (2, 'PatTwo', '456 Wood St', '2222222222');
INSERT INTO Patient VALUES (3, 'PatThree', '789 UIC St', '3333333333');
INSERT INTO Patient VALUES (4, 'PatFour', '321 Clark St', '4444444444');
INSERT INTO Patient VALUES (5, 'PatFive', '654 Hamlin St', '5555555555');

INSERT INTO Physician VALUES (11, 'Dr. A', 'CERT0000', 'Radiologist', '12 Oak St', '6666666666');
INSERT INTO Physician VALUES (22, 'Dr. B', 'CERT1111', 'Neurology', '34 Red St', '7777777777');
INSERT INTO Physician VALUES (33, 'Dr. C', 'CERT2222', 'Orthopedics', '56 Blue St', '8888888888');
INSERT INTO Physician VALUES (44, 'Dr. D', 'CERT3333', 'Oncology', '78 Lake St', '9999999999');
INSERT INTO Physician VALUES (55, 'Dr. E', 'CERT4444', 'Pediatrics', '90 Buren St', '0000000000');

INSERT INTO Nurse VALUES (66, 'Ava', 'NCERT5555', '1 Cali St', '1212121212');
INSERT INTO Nurse VALUES (77, 'Olivia', 'NCERT6666', '2 Kedzie St', '3434343434');
INSERT INTO Nurse VALUES (88, 'Ben', 'NCERT7777', '3 Streak Rd', '5656565656');
INSERT INTO Nurse VALUES (99, 'Oscar', 'NCERT8888', '4 Ocean Pl', '7878787878');
INSERT INTO Nurse VALUES (100, 'Riazi', 'NCERT9999', '5 Park Rd', '9090909090');

INSERT INTO Health_Record VALUES (1, 5, 'Flu', '2025-01-15', 'Resolved', 'Recovered flu');
INSERT INTO Health_Record VALUES (2, 4, 'Asthma', '2025-03-01', 'Ongoing', 'Asthma monitoring');
INSERT INTO Health_Record VALUES (3, 3, 'Fracture', '2025-02-10', 'Resolved', 'Fracture healed');
INSERT INTO Health_Record VALUES (4, 2, 'Allergy', '2025-04-05', 'Ongoing', 'Pollen allergy seasonal');
INSERT INTO Health_Record VALUES (5, 1, 'Diabetes', '2025-01-20', 'Resolved', 'Type 2 diabetes treatment');

INSERT INTO Physician_Order VALUES (100, 'Blood', 50.00, 11, 1);
INSERT INTO Physician_Order VALUES (111, 'X-Ray', 100.00, 22, 2);
INSERT INTO Physician_Order VALUES (222, 'MRI Scan', 200.00, 33, 3);
INSERT INTO Physician_Order VALUES (333, 'Chemo', 400.00, 44, 4);
INSERT INTO Physician_Order VALUES (444, 'Vaccination', 10.00, 55, 5);

INSERT INTO Room_Stay VALUES (201, '2025-01-10', '2025-01-15', 1, 1);
INSERT INTO Room_Stay VALUES (202, '2025-02-01', '2025-02-05', 2, 2);
INSERT INTO Room_Stay VALUES (203, '2025-03-12', '2025-03-18', 3, 3);
INSERT INTO Room_Stay VALUES (204, '2025-04-05', '2025-04-12', 4, 4);
INSERT INTO Room_Stay VALUES (205, '2025-05-01', '2025-05-03', 5, 5);

INSERT INTO Execution VALUES (301, '2025-01-11', 'Pending', 66, 100);
INSERT INTO Execution VALUES (302, '2025-02-02', 'Done', 77, 111);
INSERT INTO Execution VALUES (303, '2025-03-13', 'Done', 88, 222);
INSERT INTO Execution VALUES (304, '2025-04-06', 'Pending', 99, 333);
INSERT INTO Execution VALUES (305, '2025-05-01', 'Done', 100, 444);

INSERT INTO Medication_Administration VALUES (401, '2025-01-12', 'Ibuprofen', '100mg', 66, 1);
INSERT INTO Medication_Administration VALUES (402, '2025-02-03', 'Antibiotic', '250mg', 77, 2);
INSERT INTO Medication_Administration VALUES (403, '2025-03-14', 'Insulin', '4 units', 88, 3);
INSERT INTO Medication_Administration VALUES (404, '2025-04-07', 'ChemoDrug', '30mg', 99, 4);
INSERT INTO Medication_Administration VALUES (405, '2025-05-02', 'Vaccine', '3 dose', 100, 5);

INSERT INTO Invoice VALUES (101, 11111, '2025-01-20', '2025-01-10', '2025-01-15', 1);
INSERT INTO Invoice VALUES (102, 11112, '2025-02-10', '2025-02-01', '2025-02-05', 2);
INSERT INTO Invoice VALUES (103, 11113, '2025-03-20', '2025-03-12', '2025-03-18', 3);
INSERT INTO Invoice VALUES (104, 11114, '2025-04-15', '2025-04-05', '2025-04-12', 4);
INSERT INTO Invoice VALUES (105, 11115, '2025-05-05', '2025-05-01', '2025-05-03', 5);

INSERT INTO Payment VALUES (201, '2025-01-25', 340.00, 1);
INSERT INTO Payment VALUES (202, '2025-02-15', 420.00, 2);
INSERT INTO Payment VALUES (203, '2025-03-25', 510.00, 3);
INSERT INTO Payment VALUES (204, '2025-04-20', 660.00, 4);
INSERT INTO Payment VALUES (205, '2025-05-10', 210.00, 5);

INSERT INTO Payable VALUES (501, 50.00,  '2025-01-15', 'Room Charge', 101);
INSERT INTO Payable VALUES (502, 10.00,  '2025-01-15', 'Blood Test', 101);
INSERT INTO Payable VALUES (503, 200.00, '2025-02-05', 'Room Charge', 102);
INSERT INTO Payable VALUES (504, 100.00, '2025-02-05', 'X-Ray', 102);
INSERT INTO Payable VALUES (505, 280.00, '2025-03-18', 'Room Charge', 103);
INSERT INTO Payable VALUES (506, 200.00, '2025-03-18', 'MRI Scan', 103);
INSERT INTO Payable VALUES (507, 400.00, '2025-04-12', 'Room Charge', 104);
INSERT INTO Payable VALUES (508, 400.00, '2025-04-12', 'Chemo', 104);
INSERT INTO Payable VALUES (509, 800.00, '2025-05-03', 'Room Charge', 105);
INSERT INTO Payable VALUES (510, 10.00,  '2025-05-03', 'Vaccination', 105);
INSERT INTO Payable VALUES (511, 50.00,  '2025-01-15', 'Execution', 101);
INSERT INTO Payable VALUES (512, 60.00,  '2025-02-05', 'Execution', 102);
INSERT INTO Payable VALUES (513, 70.00,  '2025-03-18', 'Execution', 103);
INSERT INTO Payable VALUES (514, 80.00,  '2025-04-12', 'Execution', 104);
INSERT INTO Payable VALUES (515, 90.00,  '2025-05-03', 'Execution', 105);

INSERT INTO Room_Charge VALUES (501, 201);
INSERT INTO Room_Charge VALUES (503, 202);
INSERT INTO Room_Charge VALUES (505, 203);
INSERT INTO Room_Charge VALUES (507, 204);
INSERT INTO Room_Charge VALUES (509, 205);

INSERT INTO Medication_Charge VALUES (502, 401);
INSERT INTO Medication_Charge VALUES (504, 402);
INSERT INTO Medication_Charge VALUES (506, 403);
INSERT INTO Medication_Charge VALUES (508, 404);
INSERT INTO Medication_Charge VALUES (510, 405);

INSERT INTO Execution_Charge VALUES (511, 301);
INSERT INTO Execution_Charge VALUES (512, 302);
INSERT INTO Execution_Charge VALUES (513, 303);
INSERT INTO Execution_Charge VALUES (514, 304);
INSERT INTO Execution_Charge VALUES (515, 305);

INSERT INTO Monitors VALUES (11, 1, '2025-01-10', '2025-01-15');
INSERT INTO Monitors VALUES (22, 2, '2025-02-01', '2025-02-05');
INSERT INTO Monitors VALUES (33, 3, '2025-03-12', '2025-03-18');
INSERT INTO Monitors VALUES (44, 4, '2025-04-05', '2025-04-12');
INSERT INTO Monitors VALUES (55, 5, '2025-05-01', '2025-05-03');