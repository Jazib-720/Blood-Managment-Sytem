create database Blood_Managment
use Blood_Managment



---------Creating The User Table--------------------
CREATE TABLE Users(
    UserID INT PRIMARY KEY,
    Username VARCHAR(255) NOT NULL,
    Password VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL,
    CONSTRAINT UC_Username UNIQUE (Username)
);

---------------------Creating The Donor Table-----
CREATE TABLE Donor(
    UserID INT,
    Username VARCHAR(255) NOT NULL,
    BloodType VARCHAR(10) NOT NULL,
    LastDonationDate DATE,
    Bottles INT CHECK (Bottles < 3 AND Bottles > 0),
    Donate_date DATE,
    Location VARCHAR(255),
	Total_bottlesdonate INT,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (Username) REFERENCES Users(Username) 
);

GO
-------------Creating Trigger so no Such Donor insert who have given the blood Already on the month----------
CREATE TRIGGER CheckDonateDate
ON Donor
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Donor d ON i.UserID = d.UserID
        WHERE MONTH(i.Donate_date) = MONTH(d.LastDonationDate)
    )
    BEGIN
        RAISERROR ('Donate_date must not be in the same month as LastDonationDate.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;

-----------------Creating Trigger which is keep tracking the total bottles donoted by user using this database----------

go
CREATE TRIGGER IncrementTotalBottles
ON Donor
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UserID INT

    SELECT @UserID = UserID
    FROM inserted

    IF @UserID IS NOT NULL
    BEGIN
        UPDATE Donor
        SET Total_bottlesdonate = ISNULL(Total_bottlesdonate, 0) + Bottles
        WHERE UserID = @UserID
    END
END;



---------------Creating table Recipent--------------------------------

CREATE TABLE Recipient (
    UserID INT,
    Username VARCHAR(255) NOT NULL,
    BloodType VARCHAR(10) NOT NULL,
    LastRequestDate DATE,
    bottles INT,
    request_date DATE,
    Location VARCHAR(255) NOT NULL,
    Total_bottlerecieved INT,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ,
    FOREIGN KEY (Username) REFERENCES Users(Username) 
);



----------------Creating Trigger so no Such Recipent insert who have taken the blood Already on the month----------

GO

CREATE TRIGGER CheckRequestDate
ON Recipient
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Recipient r ON i.UserID = r.UserID
        WHERE MONTH(i.request_date) = MONTH(r.LastRequestDate)
    )
    BEGIN
        RAISERROR ('Request_date must not be in the same month as LastRequestDate.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;


-----------------Creating Trigger which is keep tracking the total bottles donoted by user using this database----------


go
CREATE TRIGGER IncrementTotalBottle
ON Recipient
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UserID INT

    SELECT @UserID = UserID
    FROM inserted

    IF @UserID IS NOT NULL
    BEGIN
        UPDATE Recipient
        SET Total_bottlerecieved = ISNULL(Total_bottlerecieved, 0) + 1
        WHERE UserID = @UserID
    END
END;


----------------------Creating the table feedback----------------------
CREATE TABLE Feedback (
    FeedbackID INT PRIMARY KEY,
    UserID INT,
    FeedbackText TEXT,
    FeedbackDate DATE,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE ON UPDATE CASCADE
 
);

--------------------Creating Admin Table------------------------

CREATE TABLE Admin (
    AdminID INT PRIMARY KEY,
    Username VARCHAR(255) NOT NULL,
    Password VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL
    
);


---------------------Creating View for Top Donor-------------------------
go
create view TopDonor 
as
select top(1) UserID,Username,Total_bottlesdonate
from Donor
order by Total_bottlesdonate desc

go




--------Location Based Filter-----------------
go
CREATE PROCEDURE locationfinder
    @loc VARCHAR(255)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Donor WHERE Location LIKE '%' + @loc + '%')
        SELECT * FROM Donor WHERE Location LIKE '%' + @loc + '%'
    ELSE
        SELECT 'No Donor on that Location'
END;



---------------- Insert sample data into the Users table----------------
INSERT INTO Users (UserID, Username, Password, Email)
VALUES (1, 'ahmed123', 'ahmedpass', 'ahmed123@example.com'),
       (2, 'sana456', 'sanapass', 'sana456@example.com'),
       (3, 'raheel789', 'raheelpass', 'raheel789@example.com');

-- Insert sample data into the Donor table
INSERT INTO Donor (UserID, Username, BloodType,LastDonationDate, Bottles, Donate_date, Location)
VALUES 
       (1, 'ahmed123', 'AB+', '2023-07-20', 2, '2023-5-02', 'Lahore');
	   INSERT INTO Donor (UserID, Username, BloodType,LastDonationDate, Bottles, Donate_date, Location)
VALUES 

       (2, 'sana456', 'B+', '2023-10-20', 1, '2023-11-02', 'Lahore');

	   truncate table Donor

-------- Insert sample data into the Recipient table---------------------


INSERT INTO Recipient (UserID, Username, BloodType, LastRequestDate, bottles, request_date, Location)
VALUES
     (3, 'raheel789', 'AB+', '2023-09-25', 1, '2023-11-03', 'Faisalabad');

-- -----Insert sample data into the Feedback table--------------------------

INSERT INTO Feedback (FeedbackID, UserID, FeedbackText, FeedbackDate)   
VALUES (1, 1, ' Good Application', '2023-11-01'),
       (2, 2, 'Very Helpful', '2023-11-02'); 

-- Insert sample data into the Admin table
INSERT INTO Admin (AdminID, Username, Password, Email)
VALUES (1, 'Jazib', '1234ABC', 'L211803@lhr.nu.edu.pk')

	   
Select * from Users
select * from Donor
Select * from Recipient
select * from feedback
select * from Admin

---------Getting The Top Donor--------------
select * from Topdonor


----------Location Based Donor----------------------
exec locationfinder @loc='Faisalabad'
exec locationfinder @loc='Lahore'