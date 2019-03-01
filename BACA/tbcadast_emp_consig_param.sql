-- Create table
create table CECRED.TBCADAST_EMP_CONSIG_PARAM
( idemprconsigparam    NUMBER(5) not null,
  idemprconsig         NUMBER(5) not null,
  dtinclpropostade     DATE,
  dtinclpropostaate    DATE,
  dtenvioarquivo       DATE,  
  dtvencimento         DATE)
/  
  
-- Add comments to the table 
comment on table CECRED.TBCADAST_EMP_CONSIG_PARAM is 'Parâmetros para Emprestimos Consignado por Empresa';
-- Add comments to the columns 
comment on column CECRED.TBCADAST_EMP_CONSIG_PARAM.idemprconsigparam is 'Sequencial da tabela.';
comment on column CECRED.TBCADAST_EMP_CONSIG_PARAM.idemprconsig is 'Sequencial da tabela.';
comment on column CECRED.TBCADAST_EMP_CONSIG_PARAM.dtinclpropostade is 'Data de inclusão da proposta De (DD/MM)';
comment on column CECRED.TBCADAST_EMP_CONSIG_PARAM.dtinclpropostaate is 'Data de inclusão da proposta Até(DD/MM).';
comment on column CECRED.TBCADAST_EMP_CONSIG_PARAM.dtenvioarquivo is 'Data do envio do arquivo (DD/MM).';
comment on column CECRED.TBCADAST_EMP_CONSIG_PARAM.dtvencimento is 'Data do vencimento (DD/MM).';

-- Create/Recreate primary, unique and foreign key constraints 
alter table CECRED.TBCADAST_EMP_CONSIG_PARAM add constraint TBCADAST_EMP_CONSIG_PARAM_PK primary key (IDEMPRCONSIGPARAM);

-- Create sequence 
create sequence CECRED.SEQ_TBC_EMP_CONS_PAR_IDEMPRCONSIGPARAM
minvalue 1
maxvalue 99999
start with 1
increment by 1
nocache
order;

-- Trigger 
CREATE OR REPLACE TRIGGER CECRED.trg_tbcadast_emp_consig_param
    BEFORE INSERT ON cecred.TBCADAST_EMP_CONSIG_PARAM
    FOR EACH ROW
DECLARE
  -- local variables here
BEGIN
    IF :new.idemprconsigparam IS NULL THEN
      :new.idemprconsigparam := CECRED.EQ_TBC_EMP_CONS_PAR_IDEMPRCONSIGPARAM.nextval;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100,'ERRO NA EXECUCAO DA TABELA TBCADAST_EMP_CONSIG_PARAM!');
END trg_tbcadast_emp_consig_param;



