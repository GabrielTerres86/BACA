-- Add/modify columns 
alter table tbcrd_endereco_entrega add cdagenci number(5) default 0;
-- Add comments to the columns 
comment on column tbcrd_endereco_entrega.cdagenci
  is 'Codigo do PA definido como destino do envio.';
