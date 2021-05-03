create table recuperacao.tbrecup_cobran_lancamento_fut 
(
  nrseqreg  NUMBER(15) NOT NULL,
  cdcooper  NUMBER(10) NOT NULL,
  nrdconta NUMBER(10) NOT NULL,
  cdhistor NUMBER(5) NOT NULL,
  cdchave NUMBER(25) NOT NULL,
  nmestrut  VARCHAR2(30) NOT NULL,
  vllancamento NUMBER(25,4) NOT NULL,
  dhinclusao DATE NOT NULL
)
tablespace TBS_GERAL_D
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  )
/
comment on table recuperacao.tbrecup_cobran_lancamento_fut is 'Lancamentos da craplat e craplau para cobrança no cyber';
/
comment on column recuperacao.tbrecup_cobran_lancamento_fut.nrseqreg is 'ID da tabela';
/
comment on column recuperacao.tbrecup_cobran_lancamento_fut.cdcooper is 'Número da cooperativa';
/
comment on column recuperacao.tbrecup_cobran_lancamento_fut.nrdconta is 'Número da conta';
/
comment on column recuperacao.tbrecup_cobran_lancamento_fut.cdhistor is 'Código do histórico';
/
comment on column recuperacao.tbrecup_cobran_lancamento_fut.cdchave is 'chave da tabela CRAPLAT ou CRAPLAU';
/
comment on column recuperacao.tbrecup_cobran_lancamento_fut.nmestrut is 'tabela CRAPLAT ou CRAPLAU';
/
comment on column recuperacao.tbrecup_cobran_lancamento_fut.vllancamento is 'Valor dos lançamentos';
/
comment on column recuperacao.tbrecup_cobran_lancamento_fut.dhinclusao is 'Data de inclusão do registro';
/
alter table recuperacao.tbrecup_cobran_lancamento_fut add constraint tbrecup_cobran_lanc_futuro_PK primary key (nrseqreg)
/
create table recuperacao.tbrecup_hist_lancamento_futuro 
(
  cdhistor NUMBER(5) NOT NULL,
  nmestrut  VARCHAR2(30) NOT NULL
)
tablespace TBS_GERAL_D
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  )
/
comment on table recuperacao.tbrecup_hist_lancamento_futuro is 'Históricos craplat e craplau para cobrança no cyber';
/
comment on column recuperacao.tbrecup_hist_lancamento_futuro.cdhistor is 'Código do histórico';
/
comment on column recuperacao.tbrecup_hist_lancamento_futuro.nmestrut is 'tabela CRAPLAT ou CRAPLAU';
/
create sequence recuperacao.tbrecup_cobran_lancto_fut_seq minvalue 1 maxvalue 999999999999999999999 start with 1 increment by 1 nocache order
/