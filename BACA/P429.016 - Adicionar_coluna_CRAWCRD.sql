-- Add/modify columns 
ALTER TABLE CECRED.CRAWCRD ADD dsendenv VARCHAR2(400);
-- Add comments to the columns 
COMMENT ON COLUMN CECRED.CRAWCRD.dsendenv IS 'Endereço de envio definido na criação da prosta.';