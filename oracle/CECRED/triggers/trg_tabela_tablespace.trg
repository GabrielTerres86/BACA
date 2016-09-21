CREATE OR REPLACE TRIGGER CECRED.trg_tabela_tablespace
  before insert or update on cecred.tabela_tablespace
  for each row
begin

  :new.dt_atualizacao := sysdate;

end trg_tabela_tablespace;
/

