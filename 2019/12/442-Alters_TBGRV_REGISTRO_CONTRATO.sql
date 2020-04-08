alter table CECRED.TBGRV_REGISTRO_CONTRATO
add dsc_identificador varchar2(100);

alter table CECRED.TBGRV_REGISTRO_CONTRATO
add dsc_identificador_registro varchar2(100);

comment on column CECRED.TBGRV_REGISTRO_CONTRATO.dsc_identificador
  is 'Identificador que retorna do serviço Gravames';
  
comment on column CECRED.TBGRV_REGISTRO_CONTRATO.dsc_identificador_registro
  is 'Identificador Hash que retorna do serviço Gravames';