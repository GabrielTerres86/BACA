-- Alteracao necessaria para persistir a cidade corretamente
alter table CECRED.TBCRD_ENDERECO_ENTREGA modify idcidade varchar2(50);

alter table CECRED.TBCRD_ENDERECO_ENTREGA rename column idcidade to nmcidade;

comment on column CECRED.TBCRD_ENDERECO_ENTREGA.nmcidade
  is 'Nome da cidade.';