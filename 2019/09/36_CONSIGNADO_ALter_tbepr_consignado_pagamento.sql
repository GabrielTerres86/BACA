-- Add/modify columns 
alter table CECRED.TBEPR_CONSIGNADO_PAGAMENTO add inconciliado number(1);
alter table CECRED.TBEPR_CONSIGNADO_PAGAMENTO add idseqpagamento number;
alter table CECRED.TBEPR_CONSIGNADO_PAGAMENTO add idintegracao number;
-- Add comments to the columns 
comment on column CECRED.TBEPR_CONSIGNADO_PAGAMENTO.inconciliado is 'Indicador se o movimento esta conciliado (0 - Não conciliado, 1 - Conciliado)';
comment on column CECRED.TBEPR_CONSIGNADO_PAGAMENTO.idseqpagamento is 'Id para controle do estorno, qual idsequencia do pagamneto se refere';
comment on column CECRED.TBEPR_CONSIGNADO_PAGAMENTO.idintegracao is 'Id retorno da integração do pagamento/estorno';
-- Alteração de definição da coluna instatus
comment on column CECRED.TBEPR_CONSIGNADO_PAGAMENTO.instatus
  is 'Indicador do status do processamento (1 - Pendente, 2 - Processado, 3 - Erro, 4 - Estornado)';


update tbcadast_dominio_campo set dscodigo = 'Pendente' where nmdominio = 'INSTATUS' and cddominio = '1';
update tbcadast_dominio_campo set dscodigo = 'Processado' where nmdominio = 'INSTATUS' and cddominio = '2';
update tbcadast_dominio_campo set dscodigo = 'Erro' where nmdominio = 'INSTATUS' and cddominio = '3';
insert into tbcadast_dominio_campo values ('INSTATUS','4','Estornado');
commit;