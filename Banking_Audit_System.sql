CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(100),
    Phone VARCHAR(15)
);
CREATE TABLE Accounts (
    AccountID INT IDENTITY(1001,1) PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    AccountType VARCHAR(20),
    Balance DECIMAL(15,2) DEFAULT 0.00
);
CREATE TABLE AuditTrail (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    AccountID INT,
    OldBalance DECIMAL(15,2),
    NewBalance DECIMAL(15,2),
    ChangeDate DATETIME DEFAULT GETDATE(),
    ActionType VARCHAR(50)
);
GO

CREATE TRIGGER trg_TrackBalanceChanges
ON Accounts
AFTER UPDATE
AS
BEGIN
   
    IF UPDATE(Balance)
    BEGIN
        INSERT INTO AuditTrail (AccountID, OldBalance, NewBalance, ActionType)
        SELECT 
            i.AccountID, 
            d.Balance, -- Deleted table = Purana Balance
            i.Balance, -- Inserted table = Naya Balance
            'Balance Updated'
        FROM inserted i
        JOIN deleted d ON i.AccountID = d.AccountID;
    END
END;
GO
CREATE NONCLUSTERED INDEX IX_AuditTrail_AccountID 
ON AuditTrail(AccountID);
GO
INSERT INTO Customers (FullName, Phone) VALUES ('Jogesh Sahu', '9876543210');
UPDATE Accounts SET Balance = 4000.00 WHERE AccountID = 1001;
INSERT INTO Customers (FullName, Phone) VALUES ('Jogesh Sahu', '9876543210');
INSERT INTO Accounts (CustomerID, AccountType, Balance) VALUES (1, 'Savings', 5000.00);
UPDATE Accounts SET Balance = 4000.00 WHERE AccountID = 1001;
UPDATE Accounts SET Balance = 6500.00 WHERE AccountID = 1001;

SELECT * FROM Accounts;
SELECT * FROM AuditTrail;
