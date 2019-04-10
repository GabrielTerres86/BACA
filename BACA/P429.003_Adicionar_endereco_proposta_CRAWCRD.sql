-- Add/modify columns 
ALTER TABLE CECRED.CRAWCRD ADD dsendenv VARCHAR2(500);
-- Add comments to the columns 
COMMENT ON COLUMN CECRED.CRAWCRD.dsendenv IS 'Endereco de envio definido na criacao da proposta.';