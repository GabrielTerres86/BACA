-- Create table
create table CECRED.TBCC_LANCAMENTOS_BLOQUEADOS
(
  idlancto       NUMBER(10) not null,
  dtmvtolt       DATE,
  cdagenci       NUMBER(5) default 0,
  cdbccxlt       NUMBER(5) default 0,
  nrdolote       NUMBER(10) default 0,
  nrdconta       NUMBER(10) default 0,
  nrdocmto       NUMBER(25) default 0,
  cdhistor       NUMBER(5) default 0,
  nrseqdig       NUMBER(10) default 0,
  vllanmto       NUMBER(25,2) default 0,
  nrdctabb       NUMBER(10) default 0,
  cdpesqbb       VARCHAR2(4000) default ' ',
  dtrefere       DATE,
  hrtransa       NUMBER(10) default 0,
  cdoperad       VARCHAR2(10) default ' ',
  cdcooper       NUMBER(10) default 0,
  nrdctitg       VARCHAR2(16) default ' ',
  cdorigem       NUMBER(3) default 0
  tpbloqueio     INTEGER default 1
);

-- Add comments to the table 
comment on table CECRED.TBCC_LANCAMENTOS_BLOQUEADOS
  is 'Lancamentos em depositos a vista (bloqueados)';
-- Add comments to the columns
comment on column CECRED.TBCC_LANCAMENTOS_BLOQUEADOS.idlancto
  is 'ID do lançamento (SEQ_CC_LANCTO_ID).';
comment on column CECRED.TBCC_LANCAMENTOS_BLOQUEADOS.dtmvtolt
  is 'Data do movimento.';
comment on column CECRED.TBCC_LANCAMENTOS_BLOQUEADOS.cdagenci
  is 'Numero do PA.';
comment on column CECRED.TBCC_LANCAMENTOS_BLOQUEADOS.cdbccxlt
  is 'Codigo do banco/caixa.';
comment on column CECRED.TBCC_LANCAMENTOS_BLOQUEADOS.nrdolote
  is 'Numero do lote.';
comment on column CECRED.TBCC_LANCAMENTOS_BLOQUEADOS.nrdconta
  is 'Numero da conta/dv do associado.';
comment on column CECRED.TBCC_LANCAMENTOS_BLOQUEADOS.nrdocmto
  is 'Numero do documento.';
comment on column CECRED.TBCC_LANCAMENTOS_BLOQUEADOS.cdhistor
  is 'Codigo do historico do lancamento.';
comment on column CECRED.TBCC_LANCAMENTOS_BLOQUEADOS.nrseqdig
  is 'Sequencia de digitacao.';
comment on column CECRED.TBCC_LANCAMENTOS_BLOQUEADOS.vllanmto
  is 'Valor do lancamento.';
comment on column CECRED.TBCC_LANCAMENTOS_BLOQUEADOS.nrdctabb
  is 'Numero da conta base no Banco do Brasil.';
comment on column CECRED.TBCC_LANCAMENTOS_BLOQUEADOS.cdpesqbb
  is 'Codigo de pesquisa do lancamento no banco do Brasil.';
comment on column CECRED.TBCC_LANCAMENTOS_BLOQUEADOS.dtrefere
  is 'Data de referencia do lancamento.';
comment on column CECRED.TBCC_LANCAMENTOS_BLOQUEADOS.hrtransa
  is 'Hora em que ocorreu a transacao.';
comment on column CECRED.TBCC_LANCAMENTOS_BLOQUEADOS.cdoperad
  is 'Codigo do operador.';
comment on column CECRED.TBCC_LANCAMENTOS_BLOQUEADOS.cdcooper
  is 'Codigo que identifica a Cooperativa.';
comment on column CECRED.TBCC_LANCAMENTOS_BLOQUEADOS.nrdctitg
  is 'Numero da conta de integracao com o Banco do Brasil.';
comment on column CECRED.TBCC_LANCAMENTOS_BLOQUEADOS.cdorigem
  is 'Codigo Origem Lancamento conforme definido em TBGEN_CANAL_ENTRADA';
comment on column CECRED.TBCC_LANCAMENTOS_BLOQUEADOS.tpbloqueio
  is 'Tipo de bloqueio que originou o lançamento (1 - Prejuízo, ...)';

-- Constraints
alter table CECRED.TBCC_LANCAMENTOS_BLOQUEADOS
  add constraint TBCC_LANCAMENTOS_BLOQUEADOS_PK primary key (idlancto);

-- Create/Recreate indexes 
create unique index CECRED.TBCC_LANCAMENTOS_BLOQUEADOS##TBCC_LANCAMENTOS_BLOQUEADOS1 on CECRED.TBCC_LANCAMENTOS_BLOQUEADOS (CDCOOPER, DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRDCTABB, NRDOCMTO)
  local;
create index CECRED.TBCC_LANCAMENTOS_BLOQUEADOS##TBCC_LANCAMENTOS_BLOQUEADOS2 on CECRED.TBCC_LANCAMENTOS_BLOQUEADOS (CDCOOPER, NRDCONTA, DTMVTOLT, CDHISTOR, NRDOCMTO)
  local;
create unique index CECRED.TBCC_LANCAMENTOS_BLOQUEADOS##TBCC_LANCAMENTOS_BLOQUEADOS3 on CECRED.TBCC_LANCAMENTOS_BLOQUEADOS (CDCOOPER, DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRSEQDIG)
  local;
create index CECRED.TBCC_LANCAMENTOS_BLOQUEADOS##TBCC_LANCAMENTOS_BLOQUEADOS4 on CECRED.TBCC_LANCAMENTOS_BLOQUEADOS (CDCOOPER, DTMVTOLT, CDHISTOR)
  local;
create index CECRED.TBCC_LANCAMENTOS_BLOQUEADOS##TBCC_LANCAMENTOS_BLOQUEADOS5 on CECRED.TBCC_LANCAMENTOS_BLOQUEADOS (CDCOOPER, DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, UPPER(NRDCTITG), NRDOCMTO)
  local;

-- Create sequence 
create sequence CECRED.SEQ_CC_LANCTO_ID
minvalue 1
maxvalue 9999999999
start with 1
increment by 1
cache 20;

-- Trigger para geração do ID
CREATE OR REPLACE TRIGGER CECRED.TRG_CC_LANCTO_ID
  BEFORE INSERT
  ON TBCC_LANCAMENTOS_BLOQUEADOS
  FOR EACH ROW
    BEGIN
      SELECT CECRED.SEQ_CC_LANCTO_ID.NEXTVAL
        INTO :NEW.idlancto
        FROM DUAL;

    EXCEPTION 
	  WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20100,'ERRO GERACAO SEQ_CC_LANCTO_ID!');
    END;
/