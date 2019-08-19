-- Add/modify columns 
alter table TBEPR_MOTIVO_NAO_APRV add idregistro number(20);
alter table TBEPR_MOTIVO_NAO_APRV add tppessoa NUMBER(1);
alter table TBEPR_MOTIVO_NAO_APRV add nrcpfcnpj_base number(12);
alter table TBEPR_MOTIVO_NAO_APRV add dtbloqueio date;
alter table TBEPR_MOTIVO_NAO_APRV add dtregulariza date;
alter table TBEPR_MOTIVO_NAO_APRV add idmotivo_sas NUMBER(20);
alter table TBEPR_MOTIVO_NAO_APRV add dsmotivo_sas VARCHAR2(200);
alter table TBEPR_MOTIVO_NAO_APRV modify idmotivo null;


-- Add comments to the columns 
comment on column TBEPR_MOTIVO_NAO_APRV.idregistro
  is 'Id sequencial e unico de registro';
comment on column TBEPR_MOTIVO_NAO_APRV.tppessoa
  is 'Tipo de pessoa da carga';
comment on column TBEPR_MOTIVO_NAO_APRV.nrcpfcnpj_base
  is 'Numero CPF/CNPJ Base para o registro';
comment on column TBEPR_MOTIVO_NAO_APRV.dtbloqueio
  is 'Data do Bloqueio';
comment on column TBEPR_MOTIVO_NAO_APRV.dtregulariza
  is 'Data da Regualização do Bloqueio';
comment on column TBEPR_MOTIVO_NAO_APRV.idmotivo_sas
  is 'ID do motivo oriundo do SAS';
comment on column TBEPR_MOTIVO_NAO_APRV.dsmotivo_sas
  is 'Descricao do motivo oriundo do SAS';

  

-- Create/Recreate indexes 
create index TBEPR_MOTIVO_NAO_APRV_IDX02 on TBEPR_MOTIVO_NAO_APRV (cdcooper, tppessoa, nrcpfcnpj_base, idcarga);
create index TBEPR_MOTIVO_NAO_APRV_IDX03 on TBEPR_MOTIVO_NAO_APRV (cdcooper, nrdconta, idcarga);

-- Drop primary, unique and foreign key constraints 
alter table TBEPR_MOTIVO_NAO_APRV
  drop constraint TBEPR_MOTIVO_NAO_APRV_PK;

-- Create sequence 
create sequence SEQ_EPR_MOTIVO_NAO_APRV_IDREG
minvalue 1
maxvalue 99999999999999999999
start with 1
increment by 1
cache 20;


CREATE OR REPLACE TRIGGER CECRED.TRG_EPR_MOTIVO_NAO_APRV_IDREG
  before insert on TBEPR_MOTIVO_NAO_APRV
  for each row
begin
    IF :NEW.idregistro IS NULL OR :NEW.idregistro = 0 THEN
    :NEW.idregistro := SEQ_EPR_MOTIVO_NAO_APRV_IDREG.NEXTVAL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100,'ERRO GERACAO SEQUENCE DO CAMPO idregistro - TABELA TBEPR_MOTIVO_NAO_APRV!');
end TRG_EPR_MOTIVO_NAO_APRV_IDREG;

begin
  update TBEPR_MOTIVO_NAO_APRV set idregistro = SEQ_EPR_MOTIVO_NAO_APRV_IDREG.NEXTVAL
                                  ,nrcpfcnpj_base = nvl((select nrcpfcnpj_base 
                                                      from crapass 
                                                     where crapass.cdcooper = TBEPR_MOTIVO_NAO_APRV.cdcooper
                                                       and crapass.nrdconta = TBEPR_MOTIVO_NAO_APRV.nrdconta),0)
                                  ,tppessoa = nvl((select inpessoa 
                                                  from crapass 
                                                 where crapass.cdcooper = TBEPR_MOTIVO_NAO_APRV.cdcooper
                                                   and crapass.nrdconta = TBEPR_MOTIVO_NAO_APRV.nrdconta),0);
  commit;
end;

alter table TBEPR_MOTIVO_NAO_APRV modify idregistro not null;
alter table TBEPR_MOTIVO_NAO_APRV modify tppessoa not null;

-- Create/Recreate primary, unique and foreign key constraints 
alter table TBEPR_MOTIVO_NAO_APRV
  add constraint TBEPR_MOTIVO_NAO_APRV_PK primary key (IDREGISTRO);

alter table TBBI_CPA_POSICAO_DIARIA add tppessoa NUMBER(1);
alter table TBBI_CPA_POSICAO_DIARIA add nrcpfcnpj_base number(12);

comment on column TBBI_CPA_POSICAO_DIARIA.tppessoa
  is 'Tipo da pessoa';
comment on column TBBI_CPA_POSICAO_DIARIA.nrcpfcnpj_base
  is 'Numero CPF/CNPJ Base para o registro';
  
/* BACA Antes de mudar a PK da tabela TBBI_CPA_POSICAO_DIARIA */  
begin
  update TBBI_CPA_POSICAO_DIARIA set nrcpfcnpj_base = nvl((select nrcpfcnpj_base 
                                                      from crapass 
                                                     where crapass.cdcooper = TBBI_CPA_POSICAO_DIARIA.cdcooper
                                                       and crapass.nrdconta = TBBI_CPA_POSICAO_DIARIA.nrdconta),0)
                                    ,tppessoa = nvl((select inpessoa 
                                                    from crapass 
                                                   where crapass.cdcooper = TBBI_CPA_POSICAO_DIARIA.cdcooper
                                                     and crapass.nrdconta = TBBI_CPA_POSICAO_DIARIA.nrdconta),0);
  commit;
end;
  
  
  
-- Create/Recreate primary, unique and foreign key constraints 
alter table TBBI_CPA_POSICAO_DIARIA
  drop constraint TBBI_CPA_POSICAO_DIARIA_PK;
alter table TBBI_CPA_POSICAO_DIARIA
  add constraint TBBI_CPA_POSICAO_DIARIA_PK primary key (DTMVTOLT, CDCOOPER, NRDCONTA, TPPESSOA, NRCPFCNPJ_BASE);  
  
  
-- Add/modify columns 
alter table CRAPLCR add flprapol number default 0;
-- Add comments to the columns 
comment on column CRAPLCR.flprapol
  is 'Flag de permissão de contratação de PreAprovado exclusivamente Online';


-- Add/modify columns 
alter table TBGEN_MOTIVO add flgreserva_sistema number default 0;
-- Add comments to the columns 
comment on column TBGEN_MOTIVO.flgreserva_sistema
  is 'Flag que indica se o motivo é reservado para sistema, ou seja, não será apresentado em telas para seleção';

  -- Add/modify columns 
alter table TBGEN_MOTIVO add flgexibe number(1) default 1 not null;
alter table TBGEN_MOTIVO add flgtipo number(1) default 1 not null;

-- Add comments to the columns 
comment on column TBGEN_MOTIVO.flgexibe
is 'Determina se a descricao na listagem de historio de bloqueios manuais [0- Nao Exibe, 1-Exibe]';
comment on column TBGEN_MOTIVO.flgtipo
is 'Identifica o tipo do motivo na tela de bloqueio manual [0-Desbloqueio, 1-Bloqueio]';
  
  
  
create table TBEPR_HISTOR_LIB_PRE_APRV
(
  idhistor            NUMBER(20) not null,
  cdcooper            NUMBER(10) not null,
  tppessoa            NUMBER(1) not null,
  nrcpfcnpj_base       number(12) not null,
  idcarga             NUMBER(6) not null,  
  qtparcelas          NUMBER(5) not null,
  vlparcela_maxima    NUMBER(25,2) not null,
  vllimite_atual      NUMBER(25,2) not null,
  vlscr               NUMBER(25,2) not null,
  vlscr_conjuge       NUMBER(25,2) not null,
  vlparcel_pos_scr    NUMBER(25,2) not null,
  vlparcel_pos_scr_conjuge NUMBER(25,2) not null,
  vlprop_nao_lib           NUMBER(25,2) not null,
  vlprop_nao_lib_conjuge   NUMBER(25,2) not null,
  vlpotencial_maximo       NUMBER(25,2) not null);
  
-- Add comments to the table 
comment on table TBEPR_HISTOR_LIB_PRE_APRV
  is 'Tabela de histórico de liberacoes de credito pre-aprovado';
  
-- Add comments to the columns 

comment on column TBEPR_HISTOR_LIB_PRE_APRV.idhistor
  is 'Indentificador unico do Historico';
comment on column TBEPR_HISTOR_LIB_PRE_APRV.cdcooper
  is 'Codigo da cooperativa';  
comment on column TBEPR_HISTOR_LIB_PRE_APRV.tppessoa
  is 'Tipo de pessoa da liberacao';
comment on column TBEPR_HISTOR_LIB_PRE_APRV.idcarga
  is 'Indentificador unico da carga';  
comment on column TBEPR_HISTOR_LIB_PRE_APRV.qtparcelas
  is 'Quantidade de parcelas da Linha de Credito da liberacao'; 
comment on column TBEPR_HISTOR_LIB_PRE_APRV.vlparcela_maxima
  is 'Valor de parcelas maxima da liberacao'; 
comment on column TBEPR_HISTOR_LIB_PRE_APRV.vllimite_atual
  is 'Valor de limite da liberacao';   
comment on column TBEPR_HISTOR_LIB_PRE_APRV.vlscr
  is 'Valor da divida SCR do Cooperado';   
comment on column TBEPR_HISTOR_LIB_PRE_APRV.vlscr_conjuge
  is 'Valor da divida SCR do Conjuge do Cooperado';     

comment on column TBEPR_HISTOR_LIB_PRE_APRV.vlparcel_pos_scr
  is 'Valor da divida Apos SCR do Cooperado';   
comment on column TBEPR_HISTOR_LIB_PRE_APRV.vlparcel_pos_scr_conjuge
  is 'Valor da divida Apos SCR do Conjuge do Cooperado';       

comment on column TBEPR_HISTOR_LIB_PRE_APRV.vlprop_nao_lib
  is 'Valor das propostas nao liberadas do Cooperado';   
comment on column TBEPR_HISTOR_LIB_PRE_APRV.vlprop_nao_lib_conjuge
  is 'Valor das propostas nao liberadas do Conjuge do Cooperado';        
  
comment on column TBEPR_HISTOR_LIB_PRE_APRV.vlpotencial_maximo
  is 'Valor do Potencial Maximo do Cooperado';   
     
  
-- Create/Recreate primary, unique and foreign key constraints 
alter table TBEPR_HISTOR_LIB_PRE_APRV
  add constraint TBEPR_HISTOR_LIB_PRE_APR_PK primary key (idhistor);
  
create index TBEPR_HISTOR_LIB_PRE_APR_IDX01 on TBEPR_HISTOR_LIB_PRE_APRV (cdcooper, tppessoa, nrcpfcnpj_base, idcarga);  
  
  
-- Create sequence 
create sequence SEQ_EPR_HISTOR_LIB_PREAPV_ID
minvalue 1
maxvalue 99999999999999999999
start with 1
increment by 1
cache 20;


CREATE OR REPLACE TRIGGER CECRED.TBEPR_HISTOR_LIB_PRE_APRV_ID
  before insert on TBEPR_HISTOR_LIB_PRE_APRV
  for each row
begin
    IF :NEW.idhistor IS NULL OR :NEW.idhistor = 0 THEN
    :NEW.idhistor := SEQ_EPR_HISTOR_LIB_PREAPV_ID.NEXTVAL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100,'ERRO GERACAO SEQUENCE DO CAMPO idhistor - TABELA TBEPR_HISTOR_LIB_PRE_APRV!');
end TBEPR_HISTOR_LIB_PRE_APRV_ID;    

  
-- Create table
create table TBCC_OPERACOES_PRODUTO
(
  cdproduto        NUMBER(5) not null,
  cdoperac_produto NUMBER(5) not null,
  dsoperac_produto VARCHAR2(1000) NOT NULL,
  tpcontrole       varchar2(1)
);
-- Add comments to the table 
comment on table TBCC_OPERACOES_PRODUTO
  is 'Tabela de operacoes do Produto';
-- Add comments to the columns 
comment on column TBCC_OPERACOES_PRODUTO.cdproduto
  is 'Código da cooperativa';
comment on column TBCC_OPERACOES_PRODUTO.cdoperac_produto
  is 'Codigo da operacao no produto';
comment on column TBCC_OPERACOES_PRODUTO.dsoperac_produto
  is 'Descricao da operacao no produto'; 
comment on column TBCC_OPERACOES_PRODUTO.tpcontrole
  is 'Tipo de controle da operação ([C]onta ou [D]ocumento)';  
    
-- Create/Recreate primary, unique and foreign key constraints 
alter table TBCC_OPERACOES_PRODUTO
  add constraint TBCC_OPERACOES_PRODUTO_PK primary key (cdproduto,cdoperac_produto);
    
alter table TBCC_OPERACOES_PRODUTO
  add constraint TBCC_OPERACOES_PRODUTO_FK1 foreign key (cdproduto)
  references tbcc_produto (cdproduto);    
  
  
  
-- Create table
create table TBCC_PARAM_PESSOA_PRODUTO
(
  idregistro             number(20) not null,
  cdcooper               NUMBER(5) not null,
  nrdconta               number(10) default 0 not null,
  tppessoa               NUMBER(1) not null,
  nrcpfcnpj_base         number(12) not null,
  cdproduto              NUMBER(5) NOT NULL,
  cdoperac_produto       NUMBER(5) not null,
  flglibera              NUMBER(1) default 0 not null,
  idmotivo               number(10),
  dtvigencia_paramet     DATE null
);
-- Add comments to the table 
comment on table TBCC_PARAM_PESSOA_PRODUTO
  is 'Tabela de parametros de pessoa X operacoes em produtos';
-- Add comments to the columns 
comment on column TBCC_PARAM_PESSOA_PRODUTO.cdcooper
  is 'Código da cooperativa';
comment on column TBCC_PARAM_PESSOA_PRODUTO.tppessoa
  is 'Tipo de pessoa';
comment on column TBCC_PARAM_PESSOA_PRODUTO.nrcpfcnpj_base
  is 'CPF/CNPJ base da pessoa'; 
comment on column TBCC_PARAM_PESSOA_PRODUTO.cdproduto
  is 'Codigo Produto'; 
comment on column TBCC_PARAM_PESSOA_PRODUTO.cdoperac_produto
  is 'Codigo da Operacao no Produto'; 
comment on column TBCC_PARAM_PESSOA_PRODUTO.flglibera
  is 'Flag liberação da operacao no Produto (1-Sim/ 0-Não)';
comment on column TBCC_PARAM_PESSOA_PRODUTO.dtvigencia_paramet
  is 'Data de vigencia final da parametrizacao';
comment on column TBCC_PARAM_PESSOA_PRODUTO.idregistro
  is 'ID sequencial e unico do registro';  
comment on column TBCC_PARAM_PESSOA_PRODUTO.nrdconta 
  is 'Numero da conta parametrizada';
comment on column TBCC_PARAM_PESSOA_PRODUTO.idmotivo
  is 'Motivo da operacao no produto';
  

  
-- Create/Recreate primary, unique and foreign key constraints 
alter table TBCC_PARAM_PESSOA_PRODUTO
  add constraint TBCC_PARAM_PESSOA_PRODUTO_PK primary key (IDREGISTRO);
  
alter table TBCC_PARAM_PESSOA_PRODUTO
  add constraint TBCC_PARAM_PESSOA_PRODUTO_FK1 foreign key (cdproduto,cdoperac_produto)
  references TBCC_OPERACOES_PRODUTO (cdproduto,cdoperac_produto);
create index TBCC_PARAM_PESSOA_PROD_IDX01 on TBCC_PARAM_PESSOA_PRODUTO (CDCOOPER, TPPESSOA, NRCPFCNPJ_BASE, NRDCONTA, CDPRODUTO, CDOPERAC_PRODUTO);
  
  
-- Create sequence 
create sequence SEQ_TBCC_PARAM_PES_PRD_ID
minvalue 1
maxvalue 99999999999999999999
start with 1
increment by 1
cache 20;

CREATE OR REPLACE TRIGGER TBCC_PARAM_PESSOA_PRD_ID
  before insert on TBCC_PARAM_PESSOA_PRODUTO
  for each row
begin
    IF :NEW.idregistro IS NULL OR :NEW.idregistro = 0 THEN
    :NEW.idregistro := SEQ_TBCC_PARAM_PES_PRD_ID.NEXTVAL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100,'ERRO GERACAO SEQUENCE DO CAMPO idregistro - TABELA TBCC_PARAM_PESSOA_PRODUTO!');
end TBCC_PARAM_PESSOA_PRD_ID;  
  
  
  
-- Create table
create table TBCC_HIST_PARAM_PESSOA_PROD
(
  idregistro             NUMBER(20) NOT NULL,
  cdcooper               NUMBER(5) not null,
  nrdconta               number(10) default 0 not null,
  tppessoa               NUMBER(1) not null,
  nrcpfcnpj_base         number(12) not null,
  dtoperac               DATE not null,
  dtvigencia_paramet     DATE null,
  cdproduto              NUMBER(5) NOT NULL,
  cdoperac_produto       NUMBER(5) not null,
  flglibera              number(1) not null,
  idmotivo               NUMBER(10) NOT NULL,
  cdoperad               VARCHAR2(10) NOT NULL
);
-- Add comments to the table 
comment on table TBCC_HIST_PARAM_PESSOA_PROD
  is 'Historico de Parametrizacao pessoa X operacoes em produtos';
-- Add comments to the columns 
comment on column TBCC_HIST_PARAM_PESSOA_PROD.idregistro
  is 'Identificar unico de registro';
comment on column TBCC_HIST_PARAM_PESSOA_PROD.cdcooper
  is 'Código da cooperativa';
comment on column TBCC_HIST_PARAM_PESSOA_PROD.tppessoa
  is 'Tipo de pessoa';
comment on column TBCC_HIST_PARAM_PESSOA_PROD.nrcpfcnpj_base
  is 'CPF/CNPJ base da pessoa'; 
comment on column TBCC_HIST_PARAM_PESSOA_PROD.dtoperac
  is 'Data da operacao';
comment on column TBCC_HIST_PARAM_PESSOA_PROD.dtvigencia_paramet
  is 'Data da vigencia';
comment on column TBCC_HIST_PARAM_PESSOA_PROD.cdproduto
  is 'Codigo Produto'; 
comment on column TBCC_HIST_PARAM_PESSOA_PROD.cdoperac_produto
  is 'Codigo da Operacao no Produto'; 
comment on column TBCC_HIST_PARAM_PESSOA_PROD.flglibera
  is 'Flag liberação da operacao no Produto (1-Sim/ 0-Não)';
comment on column TBCC_HIST_PARAM_PESSOA_PROD.idmotivo
  is 'Motivo da operacao no produto';
comment on column TBCC_HIST_PARAM_PESSOA_PROD.cdoperad
  is 'Codigo do Operador da operacao no produto';
comment on column TBCC_HIST_PARAM_PESSOA_PROD.nrdconta 
  is 'Numero da conta parametrizada';  
  

-- Create/Recreate primary, unique and foreign key constraints 
alter table TBCC_HIST_PARAM_PESSOA_PROD
  add constraint TBCC_HIST_PARAM_PESSOA_PRD_PK primary key (idregistro);
  
alter table TBCC_HIST_PARAM_PESSOA_PROD
  add constraint TBCC_HIST_PARAM_PESSOA_PRD_FK1 foreign key (IDMOTIVO)
  references TBGEN_MOTIVO (IDMOTIVO);
alter table TBCC_HIST_PARAM_PESSOA_PROD
  add constraint TBCC_HIST_PARAM_PESSOA_PRD_FK2 foreign key (cdproduto,cdoperac_produto)
  references TBCC_OPERACOES_PRODUTO (cdproduto,cdoperac_produto);
create index TBCC_HIST_PARAM_PES_PRD_IDX01 on TBCC_HIST_PARAM_PESSOA_PROD (CDCOOPER, TPPESSOA, NRCPFCNPJ_BASE, NRDCONTA, CDPRODUTO, CDOPERAC_PRODUTO);  
 
-- Create sequence 
create sequence SEQ_TBCC_HIST_PARAM_PES_PRD_ID
minvalue 1
maxvalue 99999999999999999999
start with 1
increment by 1
cache 20;


CREATE OR REPLACE TRIGGER TBCC_HIST_PARAM_PESSOA_PRD_ID
  before insert on TBCC_HIST_PARAM_PESSOA_PRD
  for each row
begin
    IF :NEW.idregistro IS NULL OR :NEW.idregistro = 0 THEN
    :NEW.idregistro := SEQ_TBCC_HIST_PARAM_PES_PRD_ID.NEXTVAL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100,'ERRO GERACAO SEQUENCE DO CAMPO idregistro - TABELA TBCC_HIST_PARAM_PESSOA_PRD!');
end TBCC_HIST_PARAM_PESSOA_PRD_ID;

/* Baca para converter as informações da TBEPR_PARAM_CONTA para TBCC_PARAM_PESSOA_PRODUTO pois ela será removida ao fim deste */
BEGIN
  -- Criar as operações
  INSERT INTO TBCC_OPERACOES_PRODUTO (cdproduto
                                     ,cdoperac_produto
                                     ,dsoperac_produto
                                     ,tpcontrole)
                               VALUES(25
                                     ,1
                                     ,'Pré-Aprovado Liberado'
                                     ,2); --> Por Documento(CPF/CNPJ raiz)
  INSERT INTO TBCC_OPERACOES_PRODUTO (cdproduto
                                     ,cdoperac_produto
                                     ,dsoperac_produto
                                     ,tpcontrole)
                               VALUES(4
                                     ,2 
                                     ,'Majoração Automática do Cartão de Crédito'
                                     ,1); --> Por conta
  
  -- Motivo para decsontos de títulos
  INSERT INTO tbgen_motivo(idmotivo
						  ,dsmotivo
						  ,cdproduto
						  ,flgreserva_sistema
						  ,flgativo
						  ,flgtipo
						  ,flgexibe)
			  VALUES(78
					,'Desconto de titulo em atraso'
					,25
					,0
					,1
					,0
					,1);
  
  -- Motivo para BACA de integração de cargas antigas
  INSERT INTO tbgen_motivo(idmotivo
						  ,dsmotivo
						  ,cdproduto
						  ,flgreserva_sistema
						  ,flgativo
						  ,flgtipo
						  ,flgexibe)
			  VALUES(79
					,'Bloqueio manual'
					,25
					,1
					,1
					,0
					,1);
					
	INSERT INTO tbgen_motivo(idmotivo
							,dsmotivo
							,cdproduto
							,flgreserva_sistema
							,flgativo
							,flgexibe
							,flgtipo) 
	  VALUES(71
			,'Carga de liberacao manual.'
			,25
			,1
			,1
			,1
			,1);
			
	INSERT INTO tbgen_motivo(idmotivo
							,dsmotivo
							,cdproduto
							,flgreserva_sistema
							,flgativo
							,flgexibe
							,flgtipo) 
	  VALUES(70
			,'Carga de liberacao.'
			,25
			,1
			,1
			,1
			,1);
  
  -- Transformar tbepr_param_conta para nova estrutura
  -- Transformar tbepr_param_conta para nova estrutura
  INSERT INTO TBCC_PARAM_PESSOA_PRODUTO(cdcooper             
                                       ,tppessoa             
                                       ,nrcpfcnpj_base       
                                       ,nrdconta
                                       ,cdproduto            
                                       ,cdoperac_produto			 
                                       ,idmotivo      
                                       ,flglibera      
                                       ,dtvigencia_paramet)
    SELECT ass.cdcooper
          ,ass.inpessoa
          ,ass.nrcpfcnpj_Base
          ,0
          ,25
          ,1
          ,nvl(par.idmotivo,DECODE(par.flglibera_pre_aprv,0,70,71))
          ,par.flglibera_pre_aprv
          ,trunc(add_months(nvl(par.dtatualiza_pre_aprv,SYSDATE),pre.qtmesblq))
      FROM crapass ass 
          ,tbepr_param_conta par
          ,crappre pre
     WHERE par.cdcooper = ass.cdcooper
       AND par.nrdconta = ass.nrdconta
       AND pre.cdcooper = ass.cdcooper
       AND pre.inpessoa = ass.inpessoa; 
  
  -- Gravar
  commit;
end;



-- Add/modify columns 
alter table CRAWEPR add dtpreapv date;
alter table CRAWEPR add hrpreapv numberr(6);

-- Add comments to the columns 
comment on column CRAWEPR.dtpreapv
  is 'Data da aprovacao de Pre-Aprovado pelo Cooperado atraves de canais de Auto Atendimento';
comment on column CRAWEPR.hrpreapv
  is 'Hora da aprovacao de Pre-Aprovado pelo Cooperado atraves de canais de Auto Atendimento';  
  


-- Add/modify columns 
alter table CRAPPRE add qtdiavig NUMBER(5);
alter table CRAPPRE add qtdtitul NUMBER(5);
alter table CRAPPRE add vltitulo NUMBER(15,2);
alter table CRAPPRE add qtcarcre NUMBER(5);
alter table CRAPPRE add vlcarcre NUMBER(15,2);
alter table CRAPPRE add vlctaatr NUMBER(15,2);
alter table CRAPPRE add vldiaest NUMBER(15,2);
alter table CRAPPRE add vldiadev NUMBER(15,2);
alter table CRAPPRE add vllimman NUMBER(15,2);
alter table CRAPPRE add vllimaut NUMBER(15,2);
alter table CRAPPRE add vlepratr NUMBER(15,2);


-- Add comments to the columns 
comment on column CRAPPRE.qtdiavig
  is 'Qtd dias maximo de vigencia';
comment on column CRAPPRE.qtdtitul
  is 'Qtd dias em atraso de Titulos';
comment on column CRAPPRE.vltitulo
  is 'Valor em atraso de Titulos';
comment on column CRAPPRE.qtcarcre
  is 'Qtd dias em atraso do Cartão de Crédito';
comment on column CRAPPRE.vlcarcre
  is 'Valor em atraso do Cartão de Crédito';
comment on column CRAPPRE.vlctaatr
  is 'Valor em atraso de conta corrente';
comment on column CRAPPRE.vldiaest
  is 'Valor de estouro de conta corrente';
comment on column CRAPPRE.vldiadev
  is 'Valor atrasp para calc. devolucao de cheque';
comment on column CRAPPRE.vllimman
  is 'Valor limitador para cargas manuais';
comment on column CRAPPRE.vllimaut
  is 'Valor limitador para cargas automaticas';
comment on column CRAPPRE.vlepratr
  is 'Valor de Emprestimos em atraso';
  

  
-- Add/modify columns 
alter table TBEPR_CARGA_PRE_APRV modify idcarga NUMBER(20);
alter table TBEPR_CARGA_PRE_APRV add skcarga_sas number(10) default 0;
alter table TBEPR_CARGA_PRE_APRV add qtcarga_pf number(10) default 0;
alter table TBEPR_CARGA_PRE_APRV add qtcarga_pj number(10) default 0;
alter table TBEPR_CARGA_PRE_APRV add vllimite_total number(25,2);
alter table TBEPR_CARGA_PRE_APRV add cdoperad_libera varchar2(10);
alter table TBEPR_CARGA_PRE_APRV add dtbloqueio date;
alter table TBEPR_CARGA_PRE_APRV add cdoperad_bloque varchar2(10);
alter table TBEPR_CARGA_PRE_APRV add dsmotivo_rejeicao VARCHAR2(1000);

-- Add comments to the columns 
comment on column TBEPR_CARGA_PRE_APRV.skcarga_sas
  is 'SK único da Carga originaria do SAS';
comment on column TBEPR_CARGA_PRE_APRV.qtcarga_pf
  is 'Quantidade de registros de PF na carga';
comment on column TBEPR_CARGA_PRE_APRV.qtcarga_pj
  is 'Quantidade de registros de PJ na carga';
comment on column TBEPR_CARGA_PRE_APRV.vllimite_total
  is 'Valor total de limite liberado na carga';
comment on column TBEPR_CARGA_PRE_APRV.cdoperad_libera
  is 'Codigo do operador da liberacao da carga';
comment on column TBEPR_CARGA_PRE_APRV.dtbloqueio
  is 'Data do bloqueio da Carga';
comment on column TBEPR_CARGA_PRE_APRV.cdoperad_bloque
  is 'Codigo do operador do bloqueio da carga';
comment on column TBEPR_CARGA_PRE_APRV.indsituacao_carga
  is 'Situacao da carga (1 - Importada, 2 - Liberada, 3 - Rejeitada, 4 - Substituida)';
comment on column TBEPR_CARGA_PRE_APRV.dsmotivo_rejeicao
  is 'Motivo da rejeicao da Carga';
  
BEGIN
  update TBEPR_CARGA_PRE_APRV set indsituacao_carga = decode(indsituacao_carga,1,2,1);
END;  
  
  
-- Create/Recreate indexes 
create index TBEPR_CARGA_PRE_APRV_IDX_01 on TBEPR_CARGA_PRE_APRV (cdcooper, dtcalculo, tpcarga);

-- Alter sequence
alter sequence SEQ_EPR_CARGA_IDCARGA 
maxvalue 99999999999999999999;

-- Add/modify columns 
alter table CRAPCPA add idregistro number(20);
alter table CRAPCPA add tppessoa number(1);
alter table CRAPCPA add nrcpfcnpj_base number(12);
alter table CRAPCPA add cdrating varchar2(2);
alter table CRAPCPA add dtcalc_rating date;
alter table CRAPCPA add vlpot_parc_maximo number(25,2);
alter table CRAPCPA add vlpot_lim_max number(25,2);
alter table CRAPCPA add cdoperad_bloque varchar2(12);
alter table CRAPCPA add dtbloqueio date;
alter table CRAPCPA add cdsituacao varchar2(1);
alter table CRAPCPA add dscritica VARCHAR2(1000);

-- Add comments to the columns 
comment on column CRAPCPA.idregistro
  is 'Identificador unico do registro';
comment on column CRAPCPA.tppessoa
  is 'Tipo de pessoa da carga';
comment on column CRAPCPA.nrcpfcnpj_base
  is 'Numero CPF/CNPJ Base para o registro';
comment on column CRAPCPA.cdrating
  is 'Valor do Rating da Carga';
comment on column CRAPCPA.dtcalc_rating
  is 'Data de calculo do Rating da Carga';
comment on column CRAPCPA.vlpot_parc_maximo
  is 'Valor de Potencial maximo de Parcela da Carga';
comment on column CRAPCPA.vlpot_lim_max
  is 'Valor de Potencial maximo de Limite da Carga';
comment on column CRAPCPA.cdoperad_bloque
  is 'Codigo do opearador do Bloqueio';
comment on column CRAPCPA.dtbloqueio
  is 'Data de bloqueio da Carga';
comment on column CRAPCPA.cdsituacao
  is 'Situacao da Carga ([A]ceita, [R]ecusada e [B]loqueada)';
comment on column CRAPCPA.dscritica
  is 'Descricao da critica na Carga';
  
  
  
-- Drop indexes 
drop index CRAPCPA##CRAPCPA1;  
  
 -- Create/Recreate indexes 
create index CRAPCPA##CRAPCPA1 on CRAPCPA (cdcooper, tppessoa, nrcpfcnpj_base, IDDCARGA);
create index CRAPCPA##CRAPCPA2 on CRAPCPA (cdcooper, nrdconta, IDDCARGA);

-- Create sequence 
create sequence SEQ_CRAPCPA_IDREG
minvalue 1
maxvalue 99999999999999999999
start with 1
increment by 1
cache 20;


CREATE OR REPLACE TRIGGER CECRED.TRG_CRAPCPA_IDREG
  before insert on CRAPCPA
  for each row
begin
    IF :NEW.idregistro IS NULL OR :NEW.idregistro = 0 THEN
    :NEW.idregistro := SEQ_CRAPCPA_IDREG.NEXTVAL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100,'ERRO GERACAO SEQUENCE DO CAMPO idregistro - TABELA CRAPCPA!');
end TRG_CRAPCPA_IDREG;

begin
  update CRAPCPA set idregistro = SEQ_CRAPCPA_IDREG.NEXTVAL
                                  ,nrcpfcnpj_base = nvl((select nrcpfcnpj_base 
                                                      from crapass 
                                                     where crapass.cdcooper = CRAPCPA.cdcooper
                                                       and crapass.nrdconta = CRAPCPA.nrdconta),0)
                                  ,tppessoa = nvl((select inpessoa 
                                                  from crapass 
                                                 where crapass.cdcooper = CRAPCPA.cdcooper
                                                   and crapass.nrdconta = CRAPCPA.nrdconta),0);
  commit;
end;

alter table CRAPCPA modify idregistro not null;
alter table CRAPCPA modify tppessoa not null;

-- Create/Recreate primary, unique and foreign key constraints 
alter table CRAPCPA
  add constraint CRAPCPA_PK primary key (IDREGISTRO);


alter table CRAPCPA
  add constraint CRAPCPA_FK1 foreign key (IDDCARGA)
  references TBEPR_CARGA_PRE_APRV (IDCARGA);
  
  
-- Add/modify columns 
alter table TBEPR_PARAM_CONTA add flg_desat_majora_auto NUMBER(1) default 0;
alter table TBEPR_PARAM_CONTA add dtatualiza_majora_auto date;
-- Add comments to the columns 
comment on column TBEPR_PARAM_CONTA.flg_desat_majora_auto
  is 'Flag que indica que a conta nao tera majoracao automatica de credito';
comment on column TBEPR_PARAM_CONTA.dtatualiza_majora_auto
  is 'Data da atualizacao da majoracao automatica de credito';
  
-- Ajustar campos detectados faltantes nos demais ambientes
alter table TBGEN_MOTIVO add flgativo NUMBER(1) default 1 not null;
comment on column TBGEN_MOTIVO.flgativo
  is 'Flag: 1 - Ativo / 0 - Inativo';

alter table CRAPASS add nrcpfcnpj_base NUMBER(11) default 0 not null;
comment on column CRAPASS.nrcpfcnpj_base
  is 'Numero do CPF/CNPJ Base do associado.';