-- Create table
CREATE TABLE CECRED.tbconv_dominio_campo
(
  nmdominio VARCHAR2(30) not null,
  cddominio VARCHAR2(10) not null,
  dscodigo  VARCHAR2(100) not null
);
-- Add comments to the table 
comment on table CECRED.TBCONV_DOMINIO_CAMPO
  is 'Tabela de dominios dos campos do modulo CONVENIO';
-- Add comments to the columns 
comment on column CECRED.TBCONV_DOMINIO_CAMPO.nmdominio
  is 'Nome do campo dominio';
comment on column CECRED.TBCONV_DOMINIO_CAMPO.cddominio
  is 'Codigo do dominio';
comment on column CECRED.TBCONV_DOMINIO_CAMPO.dscodigo
  is 'Descricao do codigo dominio';
-- Create/Recreate primary, unique and foreign key constraints 
alter table CECRED.TBCONV_DOMINIO_CAMPO
  add constraint TBCONV_DOMINIO_CAMPO_PK primary key (NMDOMINIO, CDDOMINIO);

-- Add/modify columns 
alter table CECRED.GNCONVE add flgrelmes number(1) default 0;
alter table CECRED.GNCONVE add dsdemailmes VARCHAR2(4000);
alter table CECRED.GNCONVE add flgarrecada number(1) default 0;
alter table CECRED.GNCONVE add dtvencto DATE;
alter table CECRED.GNCONVE add flgvalidavencto NUMBER(1) DEFAULT 0;
alter table CECRED.GNCONVE add nrdias_tolerancia NUMBER(2) DEFAULT 0;
alter table CECRED.GNCONVE add qttamanho_optante NUMBER(10) DEFAULT 0;
alter table CECRED.GNCONVE add flgenv_dt_repasse NUMBER(1) DEFAULT 0;
alter table CECRED.GNCONVE add flgacata_dup NUMBER(1) DEFAULT 0;
alter table CECRED.GNCONVE add qtdias_envia_alerta NUMBER(4) DEFAULT 20;
alter table CECRED.GNCONVE add nrlayout_arrecad	NUMBER(4)	DEFAULT 3;
alter table CECRED.GNCONVE add intpconvenio	NUMBER(2);
alter table CECRED.GNCONVE add dsidentfatura	VARCHAR2(4000);
alter table CECRED.GNCONVE add flgdebfacil	NUMBER(1) DEFAULT 0;

-- Add comments to the columns 
comment on column CECRED.GNCONVE.flgrelmes
  is 'Flag validadora se Envia ou nao(1-sim,0-nao) relatorio mensal para emails cadastrados no campo DSDEMAILMES';
comment on column CECRED.GNCONVE.dsdemailmes
  is 'Contem os emails cadastrados para envio do relatorio mensal CRRL659/49';
comment on column CECRED.GNCONVE.flgarrecada
  is 'Flag validadora se o convenio arrecada';
comment on column CECRED.GNCONVE.dtvencto
  is 'Contem a data de vencimento do contrato';
comment on column CECRED.GNCONVE.flgvalidavencto
  is 'Flag para informar se o sistema deve ou nao validar a data de vencimento no codigo de barrras';
comment on column CECRED.GNCONVE.nrdias_tolerancia
  is 'Contem o numero de dias que pode ser acrescido a data de vencimento.';
comment on column CECRED.GNCONVE.qttamanho_optante
  is 'Contem a quantiade de posições que a identificação do cliente deve ter nos convenios de Debito Automatico';
comment on column CECRED.GNCONVE.flgenv_dt_repasse
  is 'Flag para informar se o sistema deve encaminhar ao convenio a data do repasse financeiro no arq. de retorno do deb. auto';
comment on column CECRED.GNCONVE.flgacata_dup
  is 'Flag para informar se o sistema deve aceitar um debito automatico com dados iguais';
comment on column CECRED.GNCONVE.qtdias_envia_alerta
  is 'Contem a quantidade de dias sem receber arquivo que o sistema deve disparar email alerta para: convenios@ailos.coop.br. O padrao eh 20.';
comment on column CECRED.GNCONVE.nrlayout_arrecad
  IS 'Identificador do numero da versao do leiaute de arrecadacao que deve ser utilizada.';
comment on column CECRED.GNCONVE.intpconvenio
  IS 'Indicador do tipo de convenio. Referencia.: tbconv_dominio_campo.nmdominio("INTPCONVENIO")';
comment on column CECRED.GNCONVE.dsidentfatura
  IS 'Campo reservado para o SAC detalhar uma orientação ao cooperado no nomento de informar a identificacao da fatura para Deb.Auto.';
comment on column CECRED.GNCONVE.flgdebfacil
  IS 'Flag que permite o sistema identificar se o convenio pode ser apresentado para inclusao da fatura no Debito Facil';
