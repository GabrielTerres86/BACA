BEGIN 
    -- Create table
    create table CECRED.TBCOBRAN_CONTROLE_EXEC_ARQ
    (
      idexecucao number(10) not null,
      tpexecucao varchar(3) not null,
      instatus   number(1) not null,
      dsstatus   varchar2(512),
      dhiniexec  timestamp not null,
      dhfinexec  timestamp not null
    )
    ;
    -- Add comments to the table 
    comment on table CECRED.TBCOBRAN_CONTROLE_EXEC_ARQ
      is 'Tabela que controla a execucao dos arquivos processados';
    -- Add comments to the columns 
    comment on column CECRED.TBCOBRAN_CONTROLE_EXEC_ARQ.tpexecucao
      is 'Tipo de Execucao [''C''=Processar Confirmacao, ''R''=Processar Retorno, ''T''=Criar Remessa/Cancelamento/Desistencia, ''CR''=Buscar Confirmacao e Retorno, ''RCD''=Enviar Remessa/Cancelamento/Desistencia]';
    comment on column CECRED.TBCOBRAN_CONTROLE_EXEC_ARQ.instatus
      is 'Status do Log [0=Executando, 1=Sucesso, 2=Falha]';
    comment on column CECRED.TBCOBRAN_CONTROLE_EXEC_ARQ.dsstatus
      is 'Descricao do Status';
    comment on column CECRED.TBCOBRAN_CONTROLE_EXEC_ARQ.dhiniexec
      is 'Data e hora de inicio da execucao';
    comment on column CECRED.TBCOBRAN_CONTROLE_EXEC_ARQ.dhfinexec
      is 'Data e hora do fim da execucao';
      

    alter table CECRED.TBCOBRAN_CONTROLE_EXEC_ARQ
      add constraint TBCOBRAN_CONTROLE_EXEC_ARQ_PK primary key (idexecucao)
      using index;
    
    commit;
END;