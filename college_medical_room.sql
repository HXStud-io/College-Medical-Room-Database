CREATE DATABASE IF NOT EXISTS CollegeMedicalRoom_3NF;
USE CollegeMedicalRoom_3NF;

-- Drop tables (children first) so the script can be re-run safely
DROP TABLE IF EXISTS VISIT_EQUIPMENT;
DROP TABLE IF EXISTS PRESCRIPTION;
DROP TABLE IF EXISTS DIAGNOSIS;
DROP TABLE IF EXISTS MEDICAL_VISIT;
DROP TABLE IF EXISTS INVENTORY;
DROP TABLE IF EXISTS EQUIPMENT;
DROP TABLE IF EXISTS MEDICINE;
DROP TABLE IF EXISTS AMBULANCE;
DROP TABLE IF EXISTS STAFF;
DROP TABLE IF EXISTS STUDENT_MEDICAL_HISTORY;
DROP TABLE IF EXISTS STUDENT_ALLERGY;
DROP TABLE IF EXISTS STUDENT;


-- 1. STUDENT
CREATE TABLE STUDENT (
    StudentID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DOB DATE,
    ContactNumber VARCHAR(15),
    EmergencyContact VARCHAR(15)
);

-- 2. STUDENT_ALLERGY
CREATE TABLE STUDENT_ALLERGY (
    StudentID INT NOT NULL,
    Allergy VARCHAR(100) NOT NULL,
    PRIMARY KEY (StudentID, Allergy),
    CONSTRAINT fk_allergy_student
        FOREIGN KEY (StudentID) REFERENCES STUDENT(StudentID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 3. STUDENT_MEDICAL_HISTORY
CREATE TABLE STUDENT_MEDICAL_HISTORY (
    HistoryID INT AUTO_INCREMENT PRIMARY KEY,
    StudentID INT NOT NULL,
    MedicalHistory TEXT NOT NULL,
    RecordDate DATE NOT NULL,
    CONSTRAINT fk_history_student
        FOREIGN KEY (StudentID) REFERENCES STUDENT(StudentID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 4. STAFF
CREATE TABLE STAFF (
    StaffID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Position VARCHAR(50) NOT NULL,
    Specialization VARCHAR(100),
    ContactNumber VARCHAR(15)
);

-- 5. AMBULANCE
CREATE TABLE AMBULANCE (
    AmbulanceID INT AUTO_INCREMENT PRIMARY KEY,
    VehicleNumber VARCHAR(20) NOT NULL UNIQUE,
    Type VARCHAR(30) NOT NULL,
    Status VARCHAR(20) NOT NULL,
    DriverName VARCHAR(100),
    ContactNumber VARCHAR(15)
);

-- 6. MEDICAL_VISIT
CREATE TABLE MEDICAL_VISIT (
    VisitID INT AUTO_INCREMENT PRIMARY KEY,
    StudentID INT NOT NULL,
    StaffID INT NOT NULL,
    AmbulanceID INT NULL,
    VisitDate DATE NOT NULL,
    VisitTime TIME NOT NULL,
    ReasonForVisit VARCHAR(255) NOT NULL,
    Symptoms TEXT,
    Height DECIMAL(5,2),
    Weight DECIMAL(5,2),
    BP VARCHAR(20),
    Temperature DECIMAL(4,1),
    Notes TEXT,
    CONSTRAINT fk_visit_student
        FOREIGN KEY (StudentID) REFERENCES STUDENT(StudentID),
    CONSTRAINT fk_visit_staff
        FOREIGN KEY (StaffID) REFERENCES STAFF(StaffID),
    CONSTRAINT fk_visit_ambulance
        FOREIGN KEY (AmbulanceID) REFERENCES AMBULANCE(AmbulanceID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- 7. DIAGNOSIS
CREATE TABLE DIAGNOSIS (
    DiagnosisID INT AUTO_INCREMENT PRIMARY KEY,
    VisitID INT NOT NULL,
    DiagnosticCode VARCHAR(20),
    Description VARCHAR(255) NOT NULL,
    CONSTRAINT fk_diagnosis_visit
        FOREIGN KEY (VisitID) REFERENCES MEDICAL_VISIT(VisitID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 8. MEDICINE
CREATE TABLE MEDICINE (
    MedicineID INT AUTO_INCREMENT PRIMARY KEY,
    MedicineName VARCHAR(100) NOT NULL,
    Description TEXT,
    Manufacturer VARCHAR(100)
);

-- 9. INVENTORY
CREATE TABLE INVENTORY (
    InventoryID INT AUTO_INCREMENT PRIMARY KEY,
    MedicineID INT NOT NULL,
    BatchNumber VARCHAR(50) NOT NULL,
    QuantityInStock INT NOT NULL DEFAULT 0,
    ExpiryDate DATE,
    LocationInRoom VARCHAR(100),
    CONSTRAINT uq_medicine_batch UNIQUE (MedicineID, BatchNumber),
    CONSTRAINT chk_inventory_quantity CHECK (QuantityInStock >= 0),
    CONSTRAINT fk_inventory_medicine
        FOREIGN KEY (MedicineID) REFERENCES MEDICINE(MedicineID)
);

-- 10. PRESCRIPTION
CREATE TABLE PRESCRIPTION (
    PrescriptionID INT AUTO_INCREMENT PRIMARY KEY,
    VisitID INT NOT NULL,
    MedicineID INT NOT NULL,
    Dosage VARCHAR(100) NOT NULL,
    Frequency VARCHAR(100),
    Duration VARCHAR(100),
    CONSTRAINT fk_prescription_visit
        FOREIGN KEY (VisitID) REFERENCES MEDICAL_VISIT(VisitID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_prescription_medicine
        FOREIGN KEY (MedicineID) REFERENCES MEDICINE(MedicineID)
);

-- 11. EQUIPMENT
CREATE TABLE EQUIPMENT (
    EquipmentID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Category VARCHAR(50),
    Model VARCHAR(100),
    SerialNumber VARCHAR(100) UNIQUE,
    Status VARCHAR(30) NOT NULL,
    LocationInRoom VARCHAR(100)
);

-- 12. VISIT_EQUIPMENT (junction table)
CREATE TABLE VISIT_EQUIPMENT (
    VisitID INT NOT NULL,
    EquipmentID INT NOT NULL,
    PRIMARY KEY (VisitID, EquipmentID),
    CONSTRAINT fk_visit_equipment_visit
        FOREIGN KEY (VisitID) REFERENCES MEDICAL_VISIT(VisitID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_visit_equipment_equipment
        FOREIGN KEY (EquipmentID) REFERENCES EQUIPMENT(EquipmentID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO STUDENT
    (FirstName, LastName, DOB, ContactNumber, EmergencyContact)
VALUES
    ('Rahul', 'Sharma', '2004-05-12', '9876543210', '9876501234'),
    ('Aman', 'Verma', '2003-08-20', '9876543211', '9876501235'),
    ('Priya', 'Singh', '2004-02-15', '9876543212', '9876501236');

INSERT INTO STUDENT_ALLERGY (StudentID, Allergy)
VALUES
    (1, 'Dust'),
    (1, 'Pollen'),
    (3, 'Penicillin');

INSERT INTO STUDENT_MEDICAL_HISTORY
    (StudentID, MedicalHistory, RecordDate)
VALUES
    (1, 'Asthma', '2026-11-18'),
    (2, 'No previous illness reported', '2026-11-18'),
    (3, 'Migraine', '2026-11-18');

INSERT INTO STAFF
    (FirstName, LastName, Position, Specialization, ContactNumber)
VALUES
    ('Anita', 'Gupta', 'Doctor', 'General Physician', '9811100001'),
    ('Ramesh', 'Kumar', 'Nurse', 'First Aid', '9811100002'),
    ('Suresh', 'Yadav', 'Assistant', 'Emergency Care', '9811100003');

INSERT INTO AMBULANCE
    (VehicleNumber, Type, Status, DriverName, ContactNumber)
VALUES
    ('HR-29-AB-1234', 'BLS', 'Available', 'Rajesh Kumar', '9822200001'),
    ('HR-29-CD-5678', 'ALS', 'Busy', 'Mohan Singh', '9822200002');

INSERT INTO MEDICAL_VISIT
    (StudentID, StaffID, AmbulanceID, VisitDate, VisitTime,
     ReasonForVisit, Symptoms, Height, Weight, BP, Temperature, Notes)
VALUES
    (1, 1, NULL, '2026-11-18', '09:30:00',
     'Fever', 'Fever and headache', 170.00, 65.00, '120/80', 38.2,
     'Student advised rest and fluids.'),
    (2, 2, 1, '2026-11-18', '10:15:00',
     'Injury', 'Minor leg injury', 175.00, 70.00, '118/78', 36.8,
     'First aid provided; ambulance assigned.'),
    (3, 1, NULL, '2026-11-18', '11:00:00',
     'Allergy', 'Skin rash and itching', 162.00, 55.00, '110/70', 36.9,
     'Possible allergic reaction assessed.');

INSERT INTO DIAGNOSIS (VisitID, DiagnosticCode, Description)
VALUES
    (1, 'D001', 'Viral fever'),
    (2, 'D002', 'Minor leg injury'),
    (3, 'D003', 'Allergic reaction');

INSERT INTO MEDICINE (MedicineName, Description, Manufacturer)
VALUES
    ('Paracetamol', 'Pain and fever relief medicine', 'Sample Manufacturer A'),
    ('Cetirizine', 'Antihistamine medicine', 'Sample Manufacturer B'),
    ('Antacid', 'Medicine for acidity relief', 'Sample Manufacturer C');

INSERT INTO INVENTORY
    (MedicineID, BatchNumber, QuantityInStock, ExpiryDate, LocationInRoom)
VALUES
    (1, 'BATCH001', 100, '2027-12-31', 'Cabinet A'),
    (2, 'BATCH002', 50, '2027-10-31', 'Cabinet A'),
    (3, 'BATCH003', 75, '2027-09-30', 'Cabinet B');

INSERT INTO PRESCRIPTION
    (VisitID, MedicineID, Dosage, Frequency, Duration)
VALUES
    (1, 1, 'As prescribed by medical staff', 'As prescribed', 'As prescribed'),
    (2, 3, 'As prescribed by medical staff', 'As prescribed', 'As prescribed'),
    (3, 2, 'As prescribed by medical staff', 'As prescribed', 'As prescribed');

INSERT INTO EQUIPMENT
    (Name, Category, Model, SerialNumber, Status, LocationInRoom)
VALUES
    ('Thermometer', 'Diagnostic', 'Digital Thermometer', 'EQ001', 'Available', 'Cabinet C'),
    ('BP Monitor', 'Diagnostic', 'Digital BP Monitor', 'EQ002', 'Available', 'Cabinet C'),
    ('First Aid Kit', 'Emergency', 'Standard Kit', 'EQ003', 'Available', 'Cabinet B');

INSERT INTO VISIT_EQUIPMENT (VisitID, EquipmentID)
VALUES
    (1, 1),
    (1, 2),
    (2, 3),
    (3, 1);

-- ==========================================
-- ADDITIONAL SAMPLE DATA
-- (IDs assume a fresh database, so auto-increment continues from the rows above)
-- ==========================================

INSERT INTO STUDENT
    (FirstName, LastName, DOB, ContactNumber, EmergencyContact)
VALUES
    ('Neha', 'Kapoor', '2004-09-03', '9876543213', '9876501237'),
    ('Vikram', 'Malhotra', '2003-12-25', '9876543214', '9876501238'),
    ('Sneha', 'Reddy', '2005-01-18', '9876543215', '9876501239'),
    ('Arjun', 'Mehta', '2004-07-09', '9876543216', '9876501240'),
    ('Kavita', 'Joshi', '2003-03-30', '9876543217', '9876501241'),
    ('Rohan', 'Das', '2004-11-11', '9876543218', '9876501242'),
    ('Ishita', 'Bansal', '2005-04-22', '9876543219', '9876501243'),
    ('Mohit', 'Chauhan', '2003-06-14', '9876543220', '9876501244'),
    ('Ananya', 'Iyer', '2004-10-05', '9876543221', '9876501245');

INSERT INTO STUDENT_ALLERGY (StudentID, Allergy)
VALUES
    (3, 'Dust'),
    (4, 'Sulfa drugs'),
    (5, 'Aspirin'),
    (6, 'Dust'),
    (7, 'Lactose'),
    (9, 'Ibuprofen'),
    (10, 'Pollen'),
    (12, 'Shellfish');

INSERT INTO STUDENT_MEDICAL_HISTORY
    (StudentID, MedicalHistory, RecordDate)
VALUES
    (4, 'Recurrent acidity', '2026-11-18'),
    (5, 'Seasonal migraines', '2026-11-18'),
    (6, 'Frequent cold and cough', '2026-11-18'),
    (7, 'Previous ankle injury (2024)', '2026-11-18'),
    (8, 'Mild anemia', '2026-11-18'),
    (9, 'No previous illness reported', '2026-11-18'),
    (10, 'Allergic rhinitis', '2026-11-18'),
    (11, 'Fractured wrist (2022), fully healed', '2026-11-18'),
    (12, 'Tonsillitis (2023)', '2026-11-18'),
    (1, 'Asthma review: inhaler prescribed', '2026-11-17'),
    (3, 'Migraine follow-up', '2026-11-12');

INSERT INTO STAFF
    (FirstName, LastName, Position, Specialization, ContactNumber)
VALUES
    ('Vivek', 'Malik', 'Doctor', 'Internal Medicine', '9811100004'),
    ('Pooja', 'Rani', 'Nurse', 'General Nursing', '9811100005'),
    ('Deepak', 'Chauhan', 'Pharmacist', 'Dispensing', '9811100006');

INSERT INTO AMBULANCE
    (VehicleNumber, Type, Status, DriverName, ContactNumber)
VALUES
    ('HR-29-EF-9012', 'BLS', 'Available', 'Sanjay Yadav', '9822200003'),
    ('HR-29-GH-3456', 'ALS', 'Maintenance', 'Pawan Kumar', '9822200004');

INSERT INTO MEDICAL_VISIT
    (StudentID, StaffID, AmbulanceID, VisitDate, VisitTime,
     ReasonForVisit, Symptoms, Height, Weight, BP, Temperature, Notes)
VALUES
    (4, 4, NULL, '2026-11-18', '11:45:00',
     'Stomach pain', 'Abdominal cramps and nausea', 158.00, 52.00, '108/70', 36.7,
     'Advised light diet and hydration.'),
    (5, 1, NULL, '2026-11-18', '12:30:00',
     'Headache', 'Severe headache with sensitivity to light', 178.00, 74.00, '124/82', 37.0,
     'Rest in a dark room advised.'),
    (6, 5, NULL, '2026-11-18', '14:00:00',
     'Cold and cough', 'Runny nose, dry cough, sore throat', 163.00, 54.00, '110/70', 37.4,
     'Steam inhalation advised.'),
    (1, 1, 2, '2026-11-17', '16:20:00',
     'Breathing difficulty', 'Wheezing and shortness of breath', 170.00, 65.00, '130/85', 37.1,
     'Asthma episode; referred to hospital by ambulance.'),
    (7, 5, NULL, '2026-11-17', '10:05:00',
     'Sprain', 'Swollen right ankle after football', 176.00, 72.00, '120/78', 36.8,
     'Ankle strapped; RICE advised.'),
    (8, 4, NULL, '2026-11-16', '09:10:00',
     'Fatigue', 'Weakness and dizziness', 155.00, 48.00, '100/65', 36.6,
     'Fluids given; iron-rich diet advised.'),
    (9, 2, NULL, '2026-11-16', '13:40:00',
     'Cut wound', 'Minor cut on palm during lab session', 172.00, 68.00, '118/76', 36.8,
     'Wound cleaned and dressed.'),
    (10, 1, NULL, '2026-11-15', '11:20:00',
     'Allergy', 'Sneezing and watery eyes', 160.00, 50.00, '112/72', 36.7,
     'Advised to avoid dusty areas.'),
    (11, 5, 3, '2026-11-14', '15:50:00',
     'Sports injury', 'Pain and swelling in left wrist', 180.00, 78.00, '126/82', 36.9,
     'Splint applied; sent for X-ray by ambulance.'),
    (12, 4, NULL, '2026-11-14', '10:30:00',
     'Fever', 'Fever, body ache and sore throat', 165.00, 58.00, '114/74', 38.6,
     'Rest and plenty of fluids advised.'),
    (2, 1, NULL, '2026-11-13', '12:00:00',
     'Acidity', 'Heartburn after meals', 175.00, 70.00, '120/80', 36.8,
     'Avoid spicy food.'),
    (3, 1, NULL, '2026-11-12', '10:45:00',
     'Migraine', 'Throbbing headache with nausea', 162.00, 55.00, '110/72', 36.8,
     'Follow-up in one week if symptoms persist.');

INSERT INTO DIAGNOSIS (VisitID, DiagnosticCode, Description)
VALUES
    (4, 'D004', 'Gastritis'),
    (5, 'D005', 'Migraine'),
    (6, 'D006', 'Upper respiratory tract infection'),
    (7, 'D007', 'Acute asthma exacerbation'),
    (8, 'D008', 'Ankle sprain'),
    (9, 'D009', 'Dehydration and fatigue'),
    (10, 'D010', 'Minor laceration'),
    (11, 'D011', 'Allergic rhinitis'),
    (12, 'D012', 'Suspected wrist fracture'),
    (13, 'D013', 'Acute pharyngitis'),
    (14, 'D014', 'Acid reflux'),
    (15, 'D005', 'Migraine');

INSERT INTO MEDICINE (MedicineName, Description, Manufacturer)
VALUES
    ('Ibuprofen', 'Anti-inflammatory and pain relief medicine', 'Sample Manufacturer D'),
    ('Azithromycin', 'Antibiotic for bacterial infections', 'Sample Manufacturer E'),
    ('ORS', 'Oral rehydration salts', 'Sample Manufacturer F'),
    ('Salbutamol Inhaler', 'Bronchodilator for asthma relief', 'Sample Manufacturer G'),
    ('Cough Syrup', 'Dextromethorphan-based cough suppressant', 'Sample Manufacturer H'),
    ('Povidone-Iodine Ointment', 'Antiseptic for wounds', 'Sample Manufacturer I'),
    ('Pantoprazole', 'Reduces stomach acid', 'Sample Manufacturer J'),
    ('Domperidone', 'Relief from nausea and vomiting', 'Sample Manufacturer K'),
    ('Diclofenac Gel', 'Topical pain relief for sprains', 'Sample Manufacturer L');

INSERT INTO INVENTORY
    (MedicineID, BatchNumber, QuantityInStock, ExpiryDate, LocationInRoom)
VALUES
    (4, 'BATCH004', 80, '2027-08-31', 'Cabinet A'),
    (5, 'BATCH005', 40, '2027-06-30', 'Cabinet B'),
    (6, 'BATCH006', 120, '2028-01-31', 'Cabinet B'),
    (7, 'BATCH007', 15, '2027-05-31', 'Cabinet A'),
    (8, 'BATCH008', 30, '2027-01-31', 'Cabinet B'),
    (9, 'BATCH009', 25, '2027-11-30', 'Cabinet C'),
    (10, 'BATCH011', 60, '2027-07-31', 'Cabinet A'),
    (11, 'BATCH012', 45, '2027-09-15', 'Cabinet A'),
    (12, 'BATCH013', 20, '2027-04-30', 'Cabinet C'),
    (1, 'BATCH010', 200, '2028-03-31', 'Cabinet A');

INSERT INTO PRESCRIPTION
    (VisitID, MedicineID, Dosage, Frequency, Duration)
VALUES
    (4, 10, '40 mg', 'Once daily before breakfast', '5 days'),
    (4, 11, '10 mg', 'Twice daily', '3 days'),
    (5, 1, '500 mg', 'Up to 3 times daily if needed', '2 days'),
    (6, 8, '10 ml', '3 times daily', '5 days'),
    (6, 2, '10 mg', 'Once daily at night', '3 days'),
    (7, 7, '2 puffs (100 mcg each)', 'Every 4-6 hours if needed', '7 days'),
    (8, 12, 'Thin layer on affected area', '3 times daily', '5 days'),
    (9, 6, '1 sachet in 1 litre of water', 'Sip through the day', '2 days'),
    (10, 9, 'Apply a thin layer', 'Twice daily', '5 days'),
    (11, 2, '10 mg', 'Once daily at night', '5 days'),
    (12, 4, '400 mg', 'Twice daily after food', '3 days'),
    (13, 5, '500 mg', 'Once daily', '3 days'),
    (13, 1, '500 mg', '3 times daily', '3 days'),
    (14, 3, '10 ml', '3 times daily after meals', '5 days'),
    (14, 10, '40 mg', 'Once daily before breakfast', '7 days'),
    (15, 1, '500 mg', 'Up to 3 times daily if needed', '2 days'),
    (15, 11, '10 mg', 'Once if nauseous', '2 days');

-- Correct the original sample prescriptions (antacid was prescribed for a leg injury)
UPDATE PRESCRIPTION SET Dosage='500 mg', Frequency='3 times daily', Duration='3 days'
WHERE VisitID=1 AND MedicineID=1;
UPDATE PRESCRIPTION SET MedicineID=12, Dosage='Thin layer on affected area', Frequency='3 times daily', Duration='5 days'
WHERE VisitID=2 AND MedicineID=3;
UPDATE PRESCRIPTION SET Dosage='10 mg', Frequency='Once daily at night', Duration='5 days'
WHERE VisitID=3 AND MedicineID=2;

INSERT INTO EQUIPMENT
    (Name, Category, Model, SerialNumber, Status, LocationInRoom)
VALUES
    ('Stethoscope', 'Diagnostic', 'Standard Dual-Head', 'EQ004', 'Available', 'Cabinet C'),
    ('Pulse Oximeter', 'Diagnostic', 'Fingertip Digital', 'EQ005', 'Available', 'Cabinet C'),
    ('Nebulizer', 'Respiratory', 'Compressor Type', 'EQ006', 'Available', 'Cabinet B'),
    ('Splint Set', 'Emergency', 'Adjustable Set', 'EQ007', 'Available', 'Cabinet B'),
    ('Wheelchair', 'Mobility', 'Foldable', 'EQ008', 'Available', 'Room B'),
    ('Glucometer', 'Diagnostic', 'Digital Glucometer', 'EQ009', 'Under Maintenance', 'Cabinet C');

INSERT INTO VISIT_EQUIPMENT (VisitID, EquipmentID)
VALUES
    (4, 1), (4, 4),
    (5, 1), (5, 2),
    (6, 1), (6, 4),
    (7, 5), (7, 6), (7, 8),
    (8, 3), (8, 7),
    (9, 2),
    (10, 3),
    (11, 1),
    (12, 7), (12, 8),
    (13, 1), (13, 4),
    (14, 2),
    (15, 2);

SHOW TABLES;

SELECT * FROM STUDENT;
SELECT * FROM STUDENT_ALLERGY;
SELECT * FROM STUDENT_MEDICAL_HISTORY;
SELECT * FROM STAFF;
SELECT * FROM AMBULANCE;
SELECT * FROM MEDICAL_VISIT;
SELECT * FROM DIAGNOSIS;
SELECT * FROM MEDICINE;
SELECT * FROM INVENTORY;
SELECT * FROM PRESCRIPTION;
SELECT * FROM EQUIPMENT;
SELECT * FROM VISIT_EQUIPMENT;

SELECT
    mv.VisitID,
    CONCAT(s.FirstName, ' ', s.LastName) AS StudentName,
    CONCAT(st.FirstName, ' ', st.LastName) AS StaffName,
    mv.VisitDate,
    mv.VisitTime,
    mv.ReasonForVisit,
    mv.Temperature,
    mv.BP
FROM MEDICAL_VISIT AS mv
JOIN STUDENT AS s ON mv.StudentID = s.StudentID
JOIN STAFF AS st ON mv.StaffID = st.StaffID
ORDER BY mv.VisitDate, mv.VisitTime;

SELECT
    d.DiagnosisID,
    d.DiagnosticCode,
    d.Description,
    mv.VisitID,
    CONCAT(s.FirstName, ' ', s.LastName) AS StudentName
FROM DIAGNOSIS AS d
JOIN MEDICAL_VISIT AS mv ON d.VisitID = mv.VisitID
JOIN STUDENT AS s ON mv.StudentID = s.StudentID;

SELECT
    m.MedicineName,
    i.BatchNumber,
    i.QuantityInStock,
    i.ExpiryDate,
    i.LocationInRoom
FROM INVENTORY AS i
JOIN MEDICINE AS m ON i.MedicineID = m.MedicineID
ORDER BY m.MedicineName, i.ExpiryDate;

SELECT
    p.PrescriptionID,
    mv.VisitID,
    CONCAT(s.FirstName, ' ', s.LastName) AS StudentName,
    m.MedicineName,
    p.Dosage,
    p.Frequency,
    p.Duration
FROM PRESCRIPTION AS p
JOIN MEDICAL_VISIT AS mv ON p.VisitID = mv.VisitID
JOIN STUDENT AS s ON mv.StudentID = s.StudentID
JOIN MEDICINE AS m ON p.MedicineID = m.MedicineID;

-- Medicines with low stock (below 30 units)
SELECT m.MedicineName, i.BatchNumber, i.QuantityInStock, i.ExpiryDate
FROM INVENTORY AS i
JOIN MEDICINE AS m ON i.MedicineID = m.MedicineID
WHERE i.QuantityInStock < 30
ORDER BY i.QuantityInStock;

-- Medicines expiring within 6 months of 2026-11-18
SELECT m.MedicineName, i.BatchNumber, i.ExpiryDate
FROM INVENTORY AS i
JOIN MEDICINE AS m ON i.MedicineID = m.MedicineID
WHERE i.ExpiryDate <= DATE_ADD('2026-11-18', INTERVAL 6 MONTH)
ORDER BY i.ExpiryDate;

-- Visits per student
SELECT CONCAT(s.FirstName, ' ', s.LastName) AS StudentName, COUNT(*) AS TotalVisits
FROM STUDENT AS s
JOIN MEDICAL_VISIT AS mv ON s.StudentID = mv.StudentID
GROUP BY s.StudentID, s.FirstName, s.LastName
ORDER BY TotalVisits DESC;

-- Student allergy report
SELECT s.StudentID, CONCAT(s.FirstName, ' ', s.LastName) AS StudentName, a.Allergy
FROM STUDENT AS s
JOIN STUDENT_ALLERGY AS a ON s.StudentID = a.StudentID
ORDER BY s.StudentID;
