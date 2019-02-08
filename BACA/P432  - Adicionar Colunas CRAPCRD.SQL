-- Add/modify columns 
ALTER TABLE CECRED.CRAPCRD ADD flgprovi NUMBER(1) DEFAULT 0;
-- Add comments to the columns 
COMMENT ON COLUMN CECRED.CRAPCRD.flgprovi IS 'Indica se é cartão provisório';

-- Add/modify columns 
ALTER TABLE CECRED.CRAPCRD ADD dtassele DATE;
-- Add comments to the columns 
COMMENT ON COLUMN CECRED.CRAPCRD.dtassele IS 'Data da assinatura eletrônica';