-- Insert columns into CRAPBDT
-- Add/modify columns 
ALTER TABLE CECRED.CRAPBDT ADD dtliqprj DATE NOT NULL;
ALTER TABLE CECRED.CRAPBDT ADD dtprejuz DATE NOT NULL;
ALTER TABLE CECRED.CRAPBDT ADD inprejuz NUMBER DEFAULT 0 NOT NULL;

-- Add comments to the columns 
COMMENT ON COLUMN CECRED.CRAPBDT.dtliqprj IS 'Data de Liquidacao do Prejuizo';
COMMENT ON COLUMN CECRED.CRAPBDT.dtprejuz IS 'Data em que foi lancado em Prejuizo';
COMMENT ON COLUMN CECRED.CRAPBDT.inprejuz IS 'Indicador do Prejuizo (1 - Em Prejuizo)';


-- Insert columns into CRAPTDB
-- Add/modify columns 
ALTER TABLE CECRED.CRAPTDB ADD vljraprj NUMBER(25,2) DEFAULT 0 NOT NULL;
ALTER TABLE CECRED.CRAPTDB ADD vljrmprj NUMBER(25,2) DEFAULT 0 NOT NULL;
ALTER TABLE CECRED.CRAPTDB ADD vlpgjmpr NUMBER(25,2) DEFAULT 0 NOT NULL;
ALTER TABLE CECRED.CRAPTDB ADD vlpgmupr NUMBER(25,2) DEFAULT 0 NOT NULL;
ALTER TABLE CECRED.CRAPTDB ADD vlprejuz NUMBER(25,2) DEFAULT 0 NOT NULL;
ALTER TABLE CECRED.CRAPTDB ADD vlsdprej NUMBER(25,2) DEFAULT 0 NOT NULL;
ALTER TABLE CECRED.CRAPTDB ADD vlsprjat NUMBER(25,2) DEFAULT 0 NOT NULL;
ALTER TABLE CECRED.CRAPTDB ADD vlttjmpr NUMBER(25,2) DEFAULT 0 NOT NULL;
ALTER TABLE CECRED.CRAPTDB ADD vlttmupr NUMBER(25,2) DEFAULT 0 NOT NULL;

-- Add comments to the columns 
COMMENT ON COLUMN CECRED.CRAPTDB.vljraprj IS 'Juros acumulados no prejuizo.';
COMMENT ON COLUMN CECRED.CRAPTDB.vljrmprj IS 'Valor dos juros calculados no mes em prejuizo.';
COMMENT ON COLUMN CECRED.CRAPTDB.vlpgjmpr IS 'Valor total pago dos juros de mora em prejuizo.';
COMMENT ON COLUMN CECRED.CRAPTDB.vlpgmupr IS 'Valor total pago da multa em prejuizo.';
COMMENT ON COLUMN CECRED.CRAPTDB.vlprejuz IS 'Valor do prejuizo.';
COMMENT ON COLUMN CECRED.CRAPTDB.vlsdprej IS 'Saldo em prejuizo.';
COMMENT ON COLUMN CECRED.CRAPTDB.vlsprjat IS 'Saldo em prejuizo do dia anterior.';
COMMENT ON COLUMN CECRED.CRAPTDB.vlttjmpr IS 'Valor total da mora em prejuizo.';
COMMENT ON COLUMN CECRED.CRAPTDB.vlttmupr IS 'Valor total da multa em prejuizo.';