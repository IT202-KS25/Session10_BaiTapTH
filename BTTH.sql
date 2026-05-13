CREATE DATABASE Hospital_DB;
USE Hospital_DB;

CREATE TABLE Patients (
  Patient_ID     CHAR(5)      PRIMARY KEY,  
  Full_Name      VARCHAR(100) NOT NULL,     
  Admission_Time DATETIME     DEFAULT NOW()     
);

CREATE TABLE Vitals_Logs (
  Log_ID         INT          AUTO_INCREMENT PRIMARY KEY,
  Patient_ID     CHAR(5),
  Heart_Rate     INT          CHECK (Heart_Rate > 0),  
  Blood_Pressure VARCHAR(20),                         
  Record_Time    DATETIME     DEFAULT NOW(),
  FOREIGN KEY (Patient_ID) REFERENCES Patients(Patient_ID)
);

INSERT INTO Patients VALUES
  ('BN001', 'Nguyen Van A', '2026-05-13 08:00:00'),
  ('BN002', 'Le Thi B',     '2026-05-13 09:30:00'), 
  ('BN003', 'Pham Van C',   '2026-05-13 10:15:00');

INSERT INTO Vitals_Logs (Patient_ID, Heart_Rate, Blood_Pressure, Record_Time) VALUES
  ('BN001', 130, '140/90', '2026-05-13 08:10:00'),  
  ('BN001', 125, '135/88', '2026-05-13 08:20:00'), 
  ('BN003', 72,  '120/80', '2026-05-13 10:20:00'); 
  
CREATE INDEX idx_patient_time
ON Vitals_Logs (Patient_ID, Record_Time);

CREATE VIEW ER_Dashboard_View AS
SELECT p.Patient_ID, p.Full_Name, IFNULL(v.Heart_Rate, 'Pending') AS Heart_Rate, v.Blood_Pressure, v.Record_Time,
    CASE
        WHEN v.Heart_Rate > 120 OR v.Heart_Rate < 50
        THEN 'CRITICAL'
        ELSE 'STABLE'
    END AS Urgency_Level
FROM Patients p
LEFT JOIN Vitals_Logs ON p.Patient_ID = v.Patient_ID
WHERE v.Record_Time = (
    SELECT MAX(v2.Record_Time)
    FROM Vitals_Logs v2
    WHERE v2.Patient_ID = p.Patient_ID
)OR v.Record_Time IS NULL;

-- Kiểm tra bảo mật
UPDATE ER_Dashboard_View
SET Heart_Rate = 90
WHERE Patient_ID = 'BN001'; -- ==> LỖI

INSERT INTO ER_Dashboard_View
VALUES ('BN010', 'Nguyen Van A', 80, '120/80', NOW(), 'STABLE'); -- ==> LỖI