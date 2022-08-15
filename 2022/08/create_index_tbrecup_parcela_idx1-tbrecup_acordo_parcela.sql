create index CECRED.TBRECUP_PARCELA_IDX1 on CECRED.TBRECUP_ACORDO_PARCELA (NRBOLETO, NRCONVENIO, NRDCONTA_COB)
  tablespace TBS_CREDITO_I
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
