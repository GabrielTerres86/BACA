-- Add/modify columns 
alter table CECRED.TBCC_PREJUIZO_DETALHE add nrctremp number(10) default 0 not null;
-- Add comments to the columns 
comment on column CECRED.TBCC_PREJUIZO_DETALHE.nrctremp
  is 'Numero do contrato de emprestimo relacionado com o lancamento';