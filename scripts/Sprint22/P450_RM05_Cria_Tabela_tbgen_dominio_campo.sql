-- Create table
create table CECRED.TBGEN_DOMINIO_CAMPO
(
  nmdominio VARCHAR2(30) not null,
  cddominio VARCHAR2(10) not null,
  dscodigo  VARCHAR2(100) not null
);

-- Add comments to the table 
comment on table CECRED.TBGEN_DOMINIO_CAMPO
  is 'Tabela de dominios dos campos do tipo GENERICO';
-- Add comments to the columns 
comment on column CECRED.TBGEN_DOMINIO_CAMPO.nmdominio
  is 'Nome do campo dominio';
comment on column CECRED.TBGEN_DOMINIO_CAMPO.cddominio
  is 'Codigo do dominio';
comment on column CECRED.TBGEN_DOMINIO_CAMPO.dscodigo
  is 'Descricao do codigo dominio';

-- Create/Recreate primary, unique and foreign key constraints 
alter table CECRED.TBGEN_DOMINIO_CAMPO
add constraint TBGEN_DOMINIO_CAMPO_PK primary key (NMDOMINIO, CDDOMINIO);
