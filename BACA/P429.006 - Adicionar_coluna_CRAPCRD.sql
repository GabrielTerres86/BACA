-- Add/modify columns 
ALTER TABLE CECRED.CRAPCRD ADD dtasssup DATE;
-- Add comments to the columns 
COMMENT ON COLUMN CECRED.CRAPCRD.dtassele IS 'Data da assinatura eletrônica';