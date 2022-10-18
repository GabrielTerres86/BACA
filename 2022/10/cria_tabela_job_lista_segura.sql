BEGIN

   create table TRANSFERENCIAS.TBTRANSF_ALT_LST_SEG
   (
    idsolicitacao_lst_seg NUMBER(10),
    cdcooper              NUMBER(10),
    nrdconta              NUMBER(10),
    nrdcontatrf           NUMBER(10),
    dhsolicitacao         DATE,
    vlanterior            NUMBER(1),
    vlsolicitado          NUMBER(1),
    flalterado            NUMBER(1) default 0,
    progress_recid        NUMBER  
   );

   comment on table TRANSFERENCIAS.TBTRANSF_ALT_LST_SEG
     is 'Cadastro de solicitacoes de alteracao da lista segura.';
   comment on column TRANSFERENCIAS.TBTRANSF_ALT_LST_SEG.idsolicitacao_lst_seg
     is 'Identificacao unica do registro da solicitacao de alteracao da lista segura. E gerado pela incrementacao automatica do Oracle.';
   comment on column TRANSFERENCIAS.TBTRANSF_ALT_LST_SEG.cdcooper
     is 'Código da cooperativa #CLASSIFICACAO_DADO: C';
   comment on column TRANSFERENCIAS.TBTRANSF_ALT_LST_SEG.nrdconta
     is 'Numero da conta do cooperado #CLASSIFICACAO_DADO: C';
   comment on column TRANSFERENCIAS.TBTRANSF_ALT_LST_SEG.nrdcontatrf
     is 'Numero da conta de transferência #CLASSIFICACAO_DADO: C';  
   comment on column TRANSFERENCIAS.TBTRANSF_ALT_LST_SEG.dhsolicitacao
     is 'Data e hora de cadastro da solicitacao de alteracao da lista segura #CLASSIFICACAO_DADO: C';
   comment on column TRANSFERENCIAS.TBTRANSF_ALT_LST_SEG.vlanterior
     is 'Valor anterior. 0-Não presente na lista segura,1-Presente na lista segura #CLASSIFICACAO_DADO: C';
   comment on column TRANSFERENCIAS.TBTRANSF_ALT_LST_SEG.vlsolicitado
     is 'Valor solicitado 0-Não presente na lista segura,1-Presente na lista segura #CLASSIFICACAO_DADO: C';
   comment on column TRANSFERENCIAS.TBTRANSF_ALT_LST_SEG.flalterado
     is 'Flag de informacao sobre o status de alteracao do item. Contem o dominio: 0 - Nao; 1 - Sim. #CLASSIFICACAO_DADO: C';
   comment on column TRANSFERENCIAS.TBTRANSF_ALT_LST_SEG.progress_recid
     is '#CLASSIFICACAO_DADO: I';  

   create index TRANSFERENCIAS.TBTRANSF_ALT_LST_SEG_IDX1 on TRANSFERENCIAS.TBTRANSF_ALT_LST_SEG (DHSOLICITACAO, FLALTERADO);

   alter table TRANSFERENCIAS.TBTRANSF_ALT_LST_SEG
     add constraint TBTRANSF_ALT_LST_SEG_PK primary key (idsolicitacao_lst_seg)
     using index;

   commit;
END;