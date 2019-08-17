-- Insert columns into CRAPCBD
-- Add/modify columns 
ALTER TABLE CECRED.CRAPCBD ADD vlprejme NUMBER(15,2);
ALTER TABLE CECRED.CRAPCBD ADD vlopesme NUMBER(15,2);

-- Add comments to the columns 
COMMENT ON COLUMN CECRED.CRAPCBD.vlprejme IS 'Valor das operacoes em prejuizo dos ultimos 12 meses';
COMMENT ON COLUMN CECRED.CRAPCBD.vlopesme IS 'Valor das operacoes vencidas dos ultimos 12 meses';
