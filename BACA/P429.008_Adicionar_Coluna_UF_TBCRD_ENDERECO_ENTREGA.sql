-- Add/modify columns 
alter table tbcrd_endereco_entrega add cdufende VARCHAR2(2) default null;
-- Add comments to the columns 
comment on column tbcrd_endereco_entrega.cdufende
  is 'Sigla do estado definido como destino do envio.';