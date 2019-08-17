-- Create table para as ocorrencias
CREATE TABLE tbcrd_ocorrencia_arq_inadim(
       idocorrencia    NUMBER(10) NOT NULL
      ,dtprocessamento DATE NOT NULL
			,tpocorrencia    VARCHAR2(1) NOT NULL
			,dsocorrencia    VARCHAR2(255) NOT NULL
			,nmarquivo       VARCHAR2(255)
			,CONSTRAINT tbcrd_ocorrencia_arq_inadim_pk PRIMARY KEY (idocorrencia)
);
-- Add comments to the table 
comment on table tbcrd_ocorrencia_arq_inadim
  is 'Ocorrencias do processamento do arquivo de inadimplentes (CB093)';
-- Add comments to the columns 
comment on column tbcrd_ocorrencia_arq_inadim.idocorrencia
  is 'Identificador unico da ocorrencia.';
comment on column tbcrd_ocorrencia_arq_inadim.dtprocessamento
  is 'Data na qual ocorreu a tentativa de processamento do arquivo inadimplentes (CB093).';
comment on column tbcrd_ocorrencia_arq_inadim.tpocorrencia
  is 'Tipo de ocorrencia A - Ausencia do arquivo, E - Erro no processamento do arquivo.';
comment on column tbcrd_ocorrencia_arq_inadim.dsocorrencia
  is 'Descricao da ocorrencia.';
comment on column tbcrd_ocorrencia_arq_inadim.nmarquivo
  is 'Nome do arquivo.';

CREATE TABLE tbcrd_controle_arq_inadim(
       idcontrole       NUMBER(10) NOT NULL
			,dtprocessamento  DATE NOT NULL
			,nmarquivo        VARCHAR2(255) NOT NULL
			,dslinha_controle CLOB NOT NULL
			,CONSTRAINT tbcrd_controle_arq_inadim_pk PRIMARY KEY (idcontrole)
);
-- Add comments to the table 
comment on table tbcrd_controle_arq_inadim
  is 'Controle do arquivo de inadimplentes (CB093)';
-- Add comments to the columns 
comment on column tbcrd_controle_arq_inadim.idcontrole
  is 'Identificador unico do controle.';
comment on column tbcrd_controle_arq_inadim.dtprocessamento
  is 'Data na qual ocorreu o processamento do arquivo de inadimplentes (CB093).';
comment on column tbcrd_controle_arq_inadim.nmarquivo
  is 'Nome do arquivo de inadimplentes (CB093) processado.';
comment on column tbcrd_controle_arq_inadim.dslinha_controle
  is 'Descricao com a linha de controle.';

CREATE TABLE tbcrd_conta_arq_inadim(
       idcontrole       NUMBER(10) NOT NULL
			,idlinha          NUMBER(10) NOT NULL
			,dtprocessamento  DATE NOT NULL
			,nmarquivo        VARCHAR2(255) NOT NULL
			,dslinha_conta    CLOB NOT NULL
			,CONSTRAINT tbcrd_conta_arq_inadim_pk PRIMARY KEY (idcontrole, idlinha)
			,FOREIGN KEY (idcontrole)
          REFERENCES tbcrd_controle_arq_inadim(cdcontrole)
);
-- Add comments to the table 
comment on table tbcrd_conta_arq_inadim
  is 'Contas do arquivo de inadimplentes (CB093).';
-- Add comments to the columns 
comment on column tbcrd_conta_arq_inadim.idcontrole
  is 'Identificador unico do controle.';
comment on column tbcrd_conta_arq_inadim.idlinha
  is 'Identificador da linha da conta.';
comment on column tbcrd_conta_arq_inadim.dtprocessamento
  is 'Data na qual ocorreu o processamento do arquivo de inadimplentes (CB093).';
comment on column tbcrd_conta_arq_inadim.nmarquivo
  is 'Nome do arquivo de inadimplentes (CB093) processado.';
comment on column tbcrd_conta_arq_inadim.dslinha_conta
  is 'Descricao com a linha da conta.';

CREATE SEQUENCE seqcrd_ocorrencia_arq_inadim
  MINVALUE 1
  START WITH 1
  INCREMENT BY 1
  NOCACHE;

CREATE SEQUENCE seqcrd_controle_arq_inadim
  MINVALUE 1
  START WITH 1
  INCREMENT BY 1
  NOCACHE;
