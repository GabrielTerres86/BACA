alter table CECRED.TBRECUP_ACORDO_CONTRATO add (
    INDPAGAR VARCHAR2(1) DEFAULT 'S' NOT NULL )
/
comment on column CECRED.TBRECUP_ACORDO_CONTRATO.INDPAGAR is 'Pagar (S/N) - N: Não / S: Sim'
/
alter table CECRED.TBRECUP_ACORDO_CONTRATO add (
    CDOPERAD VARCHAR2(10))
/
comment on column CECRED.TBRECUP_ACORDO_CONTRATO.CDOPERAD is 'Operador que incluiu o contrato no acordo'
/
alter table CECRED.TBRECUP_ACORDO_CONTRATO add (
    DTDINCLU DATE))
/
comment on column CECRED.TBRECUP_ACORDO_CONTRATO.DTDINCLU is 'Data da inclusão do contrato no acordo'
/