-- Migration Script v2: Global Payment Format
-- Date: 2026-01-05
-- Purpose: Update seller payment info to support international bank accounts

-- 1. Rename 'bank_account_name' to 'beneficiary_name' for clarity (or just add new and migrate)
-- We will add new columns and drop old ones to be clean.

ALTER TABLE sellers ADD COLUMN beneficiary_name VARCHAR(100) COMMENT '受益人姓名 (Beneficiary Name)' AFTER bank_name;
ALTER TABLE sellers ADD COLUMN swift_code VARCHAR(20) COMMENT 'SWIFT/BIC Code' AFTER bank_name;
ALTER TABLE sellers ADD COLUMN bank_address VARCHAR(255) COMMENT '銀行地址' AFTER bank_account_number;
ALTER TABLE sellers ADD COLUMN bank_country VARCHAR(50) DEFAULT 'Taiwan' COMMENT '銀行所在國家' AFTER bank_address;

-- 2. Modify account number to support longer IBAN (max 34 chars usually, let's say 50 safe)
ALTER TABLE sellers MODIFY COLUMN bank_account_number VARCHAR(50) COMMENT '銀行帳號 / IBAN';

-- 3. Drop obsolete columns
-- 'bank_code' is specific to Taiwan locally (3 digits), implied in SWIFT now or not needed.
ALTER TABLE sellers DROP COLUMN bank_code;
-- 'bank_branch_name' is often optional or part of address in international wiring.
ALTER TABLE sellers DROP COLUMN bank_branch_name;
-- 'bank_account_name' is replaced by 'beneficiary_name'
ALTER TABLE sellers DROP COLUMN bank_account_name;
