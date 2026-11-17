-- ============================================================================
-- FASE 1: CREACIÓN DE ESQUEMA Y DATOS DE ORIGEN (LEGACY CRM)
-- Archivo: sql/01_create_source_schema.sql
-- ============================================================================

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'LegacyCRM')
BEGIN
    EXEC('CREATE SCHEMA LegacyCRM');
END
GO

-- 1. Tabla de Empresas / Clientes (Mapea a entidad 'Account' en Dataverse)
CREATE TABLE LegacyCRM.Accounts (
    AccountLegacyID VARCHAR(20) PRIMARY KEY,
    CompanyName     NVARCHAR(150) NOT NULL,
    IndustryCode    VARCHAR(10) NULL, -- Códigos legacy: 'TECH', 'RETAIL', 'LOGISTICS', 'FIN'
    MainPhone       VARCHAR(30) NULL,
    Website         VARCHAR(150) NULL,
    City            NVARCHAR(80) NULL,
    Country         NVARCHAR(80) NULL,
    IsActive        BIT NOT NULL DEFAULT 1,
    CreatedDate     DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedDate    DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);
GO

-- 2. Tabla de Contactos (Mapea a entidad 'Contact' en Dataverse)
CREATE TABLE LegacyCRM.Contacts (
    ContactLegacyID VARCHAR(20) PRIMARY KEY,
    AccountLegacyID VARCHAR(20) NOT NULL,
    FirstName       NVARCHAR(80) NOT NULL,
    LastName        NVARCHAR(80) NOT NULL,
    Email           VARCHAR(150) NULL,
    JobTitle        NVARCHAR(100) NULL,
    MobilePhone     VARCHAR(30) NULL,
    ModifiedDate    DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Contacts_Accounts FOREIGN KEY (AccountLegacyID) 
        REFERENCES LegacyCRM.Accounts(AccountLegacyID)
);
GO

-- 3. Tabla de Órdenes / Transacciones (Mapea a entidad personalizada o 'SalesOrder')
CREATE TABLE LegacyCRM.Orders (
    OrderLegacyID   VARCHAR(20) PRIMARY KEY,
    AccountLegacyID VARCHAR(20) NOT NULL,
    OrderNumber     VARCHAR(30) NOT NULL,
    TotalAmount     DECIMAL(18,2) NOT NULL,
    CurrencyCode    VARCHAR(3) NOT NULL DEFAULT 'USD',
    OrderStatus     VARCHAR(20) NOT NULL, -- 'COMPLETED', 'PENDING', 'CANCELLED'
    OrderDate       DATETIME2 NOT NULL,
    ModifiedDate    DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Orders_Accounts FOREIGN KEY (AccountLegacyID) 
        REFERENCES LegacyCRM.Accounts(AccountLegacyID)
);
GO

-- ============================================================================
-- INSERCIÓN DE DATOS DE PRUEBA (Incluye anomalías reales para limpieza en ETL)
-- ============================================================================

INSERT INTO LegacyCRM.Accounts (AccountLegacyID, CompanyName, IndustryCode, MainPhone, Website, City, Country, IsActive)
VALUES 
('ACC-1001', '  Logística del Golfo S.A.  ', 'LOGISTICS', '+52 (229) 931-4400', 'https://logisticagolfo.example.com', 'Veracruz', 'México', 1),
('ACC-1002', 'TechNova Solutions', 'TECH', '55-8492-1100', 'technova.example.io', 'Ciudad de México', 'México', 1),
('ACC-1003', 'Distribuidora Pacífico', 'RETAIL', '3331229988', NULL, 'Guadalajara', 'México', 1),
('ACC-1004', 'Financiera Atlas Corp', 'FIN', '+1-415-555-0192', 'https://atlasfin.example.com', 'San Francisco', 'USA', 0); -- Registro inactivo
GO

INSERT INTO LegacyCRM.Contacts (ContactLegacyID, AccountLegacyID, FirstName, LastName, Email, JobTitle, MobilePhone)
VALUES
('CON-5001', 'ACC-1001', 'Carlos', 'Mendoza', 'CARLOS.MENDOZA@LOGISTICAGOLFO.EXAMPLE.COM', 'Director de Operaciones', '2291122334'),
('CON-5002', 'ACC-1001', 'Ana', 'Ríos', 'ana.rios@logisticagolfo.example.com', 'Gerente de Compras', '2299988776'),
('CON-5003', 'ACC-1002', 'Sofía', 'Vargas', 'sofia.vargas@technova.example.io', 'CTO', '5512345678'),
('CON-5004', 'ACC-1003', 'Roberto', 'Navarro', NULL, 'Jefe de Almacén', '3319876543'); -- Contacto sin email
GO

INSERT INTO LegacyCRM.Orders (OrderLegacyID, AccountLegacyID, OrderNumber, TotalAmount, CurrencyCode, OrderStatus, OrderDate)
VALUES
('ORD-9001', 'ACC-1001', 'SO-2026-001', 15400.50, 'USD', 'COMPLETED', '2026-10-15 10:30:00'),
('ORD-9002', 'ACC-1001', 'SO-2026-002', 8200.00, 'USD', 'PENDING', '2026-11-02 14:15:00'),
('ORD-9003', 'ACC-1002', 'SO-2026-003', 42000.00, 'USD', 'COMPLETED', '2026-11-10 09:00:00'),
('ORD-9004', 'ACC-1003', 'SO-2026-004', 3150.75, 'USD', 'CANCELLED', '2026-11-12 16:45:00');
GO