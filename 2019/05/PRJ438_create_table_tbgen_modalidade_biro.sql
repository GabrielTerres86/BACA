CREATE TABLE tbgen_modalidade_biro
(nrconbir NUMBER(10), 
 nrseqdet NUMBER(5),
 cdmodbir NUMBER(5),
 nrcpfcgc NUMBER(25),
 xmlmodal  CLOB
 );   
 
ALTER TABLE cecred.tbgen_modalidade_biro
  ADD CONSTRAINT tbgen_modalidade_biro_pk PRIMARY KEY (nrconbir, nrseqdet,cdmodbir)

ALTER TABLE cecred.tbgen_modalidade_biro
  ADD CONSTRAINT modalidade_biro_FK_CRAPCBD FOREIGN KEY (nrconbir, nrseqdet)
  REFERENCES cecred.crapcbd (nrconbir, nrseqdet);
   
 tbgen_analise_credito;
comment on table CECRED.tbgen_modalidade_biro
  is 'Detalhe da modalidade do biro';
-- Add comments to the columns 
comment on column CECRED.tbgen_modalidade_biro.nrconbir
  is 'Sequencial com o numero da consulta no biro';
comment on column CECRED.tbgen_modalidade_biro.nrseqdet
  is 'Sequencial do detalhe';
comment on column CECRED.tbgen_modalidade_biro.cdmodbir
  is 'Codigo da modalidade no biro de consultas  '; 
comment on column CECRED.tbgen_modalidade_biro.nrcpfcgc
  is 'Numero do CPF/CNPJ  '; 
comment on column CECRED.tbgen_modalidade_biro.xmlmodal
  is 'XML da modalidade  ';  
