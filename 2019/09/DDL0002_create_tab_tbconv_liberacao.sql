-- Create table 
CREATE TABLE cecred.tbconv_liberacao
( idseqconvelib  NUMBER(10) NOT NULL,
  tparrecadacao  NUMBER(2)  NOT NULL,
  cdcooper       NUMBER(10) NOT NULL,
  cdempres       VARCHAR2(10),
  cdconven       NUMBER(5),   
  flgautdb       NUMBER(1) DEFAULT 0     
);
-- Add comments to the table 
COMMENT ON TABLE cecred.tbconv_liberacao IS 'Tabela de controle para liberacao de debito automatico por cooperativa para convenios';
-- Add comments to the columns
COMMENT ON COLUMN cecred.tbconv_liberacao.idseqconvelib IS 'ID Sequencial';
COMMENT ON COLUMN cecred.tbconv_liberacao.tparrecadacao IS 'Tipo de arrecadacao. Referencia tbconv_dominio_campo.nmdominio("TPARRECADACAO")';
COMMENT ON COLUMN cecred.tbconv_liberacao.cdcooper      IS 'Codigo que identifica a Cooperativa.';
COMMENT ON COLUMN cecred.tbconv_liberacao.cdempres      IS 'Codigo do convenio de arrecadacao';
COMMENT ON COLUMN cecred.tbconv_liberacao.cdconven      IS 'Contem o codigo do convenio para controle interno';
COMMENT ON COLUMN cecred.tbconv_liberacao.flgautdb      IS 'Flag para indicar se o debito automatico esta liberado na cooperativa (0-Nao, 1-Sim).';
--PK
ALTER TABLE cecred.tbconv_liberacao  ADD CONSTRAINT tbconv_liberacao_pk primary key (idseqconvelib);
-- Create/Recreate indexes 
create unique index cecred.tbconv_liberacao_idx01 on cecred.tbconv_liberacao(tparrecadacao,cdcooper,cdconven);
create unique index cecred.tbconv_liberacao_idx02 on cecred.tbconv_liberacao(tparrecadacao,cdcooper,cdempres);
-- Create sequence 
create sequence cecred.tbconv_liberacao_seq
minvalue 1
maxvalue 9999999999
start with 1
increment by 1
nocache
order;
--Create Trigger tbconv_liberacao
CREATE OR REPLACE TRIGGER cecred.trgtbconv_liberacao
BEFORE INSERT ON tbconv_liberacao

FOR EACH ROW

BEGIN
  
  IF :NEW.idseqconvelib IS NULL THEN
    :NEW.idseqconvelib := tbconv_liberacao_seq.NEXTVAL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100,'Erro na SEQUENCE tbconv_liberacao_seq na trigger trgtbconv_liberacao .');
END;
/
--Drop tabela 
DROP TABLE CECRED.tbconv_canalcoop_liberado CASCADE CONSTRAINT;
--Canais de Liberação do Convênio
CREATE TABLE CECRED.tbconv_canalcoop_liberado
(
  idsequencia	   NUMBER(10) NOT NULL,
  idseqconvelib  NUMBER(10) NOT NULL,
  cdsegmto       NUMBER(5)  NOT NULL,
  cdempcon       NUMBER(5)  NOT NULL,
  cdcanal        NUMBER(2)  NOT NULL,
  flgliberado    NUMBER(1)  DEFAULT 0     
);
-- Add comments to the table 
COMMENT ON TABLE CECRED.tbconv_canalcoop_liberado
  IS 'Tabela de cadastro dos canais e cooperativa liberados para o convênio';
-- Add comments to the columns 
COMMENT ON COLUMN CECRED.tbconv_canalcoop_liberado.idsequencia
  IS 'ID sequencial';
COMMENT ON COLUMN CECRED.tbconv_canalcoop_liberado.idseqconvelib
  IS 'Identificacao do tipo de arrecadacao e cooperativa.';  
COMMENT ON COLUMN CECRED.tbconv_canalcoop_liberado.cdsegmto
  IS 'Identificacao do segmento da empresa/orgao.';
COMMENT ON COLUMN CECRED.tbconv_canalcoop_liberado.cdempcon
  IS 'Codigo da empresa a ser conveniada.';
COMMENT ON COLUMN CECRED.tbconv_canalcoop_liberado.cdcanal
  IS 'Codigo da empresa a ser cdcanal.';
COMMENT ON COLUMN CECRED.tbconv_canalcoop_liberado.flgliberado
  IS 'Flag para indicar se o canal e cooperativa estao liberados (0-Nao, 1-Sim).';
--PK
ALTER TABLE cecred.tbconv_canalcoop_liberado  ADD CONSTRAINT tbconv_canalcoop_liberado_pk primary key (idsequencia);
--FK
ALTER TABLE cecred.tbconv_canalcoop_liberado  ADD CONSTRAINT tbconv_canalcoop_liberado_fk01 foreign key (idseqconvelib)
  REFERENCES cecred.tbconv_liberacao (idseqconvelib);
--  
CREATE UNIQUE INDEX CECRED.tbconv_canalcoop_lib_idx01 on CECRED.tbconv_canalcoop_liberado(idseqconvelib,cdsegmto,cdempcon,cdcanal);

-- Create sequence 
create sequence cecred.tbconv_canalcoop_liberado_seq
minvalue 1
maxvalue 9999999999
start with 1
increment by 1
nocache
order;

--Create Trigger
CREATE OR REPLACE TRIGGER cecred.trgtbconv_canalcoop_liberado
BEFORE INSERT ON tbconv_canalcoop_liberado

FOR EACH ROW

BEGIN
  
  IF :NEW.idsequencia IS NULL THEN
    :NEW.idsequencia := tbconv_canalcoop_liberado_seq.NEXTVAL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100,'Erro na SEQUENCE tbconv_canalcoop_liberado_seq na trigger trgtbconv_canalcoop_liberado .');
END
/
