DECLARE

  -- Gravar execucao
  vr_cdprogra VARCHAR(40) := 'PRJ0015801_2';
  vr_idprglog TBGEN_PRGLOG.IDPRGLOG%TYPE := 0;

BEGIN

  -- Gera log no início da execução
  cecred.pc_log_programa(pr_dstiplog   => 'I'         
                        ,pr_cdprograma => vr_cdprogra 
                        ,pr_cdcooper   => 0
                        ,pr_tpexecucao => 0     
                        ,pr_idprglog   => vr_idprglog);

  /* Dados da tela cadfra */
  cecred.pc_log_programa(pr_dstiplog => 'O', pr_cdprograma => vr_cdprogra, pr_cdcooper => 0, pr_dsmensagem => 'Dados da tela cadfra', pr_idprglog => vr_idprglog);
  --
  insert into tbgen_analise_fraude_param (CDOPERACAO, TPOPERACAO, HRRETENCAO, FLGEMAIL_ENTREGA, DSEMAIL_ENTREGA, DSASSUNTO_ENTREGA, DSCORPO_ENTREGA, FLGEMAIL_RETORNO, DSEMAIL_RETORNO, DSASSUNTO_RETORNO, DSCORPO_RETORNO, FLGATIVO, TPRETENCAO)
  values (13, 1, null, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha na entrega da Transferência Intra para a análise do sistema antifraude.', null, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha no retorno da análise de Transferência Intra do sistema antifraude.', null, 0, 1);
  --
  insert into tbgen_analise_fraude_param (CDOPERACAO, TPOPERACAO, HRRETENCAO, FLGEMAIL_ENTREGA, DSEMAIL_ENTREGA, DSASSUNTO_ENTREGA, DSCORPO_ENTREGA, FLGEMAIL_RETORNO, DSEMAIL_RETORNO, DSASSUNTO_RETORNO, DSCORPO_RETORNO, FLGATIVO, TPRETENCAO)
  values (13, 2, 24900, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha na entrega da Transferência Intra para a análise do sistema antifraude.', null, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha no retorno da análise de Transferência Intra do sistema antifraude.', null, 0, 2);
  --
  insert into tbgen_analise_fraude_param (CDOPERACAO, TPOPERACAO, HRRETENCAO, FLGEMAIL_ENTREGA, DSEMAIL_ENTREGA, DSASSUNTO_ENTREGA, DSCORPO_ENTREGA, FLGEMAIL_RETORNO, DSEMAIL_RETORNO, DSASSUNTO_RETORNO, DSCORPO_RETORNO, FLGATIVO, TPRETENCAO)
  values (14, 1, null, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha na entrega da Transferência Inter para a análise do sistema antifraude.', null, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha no retorno da análise de Transferência Inter do sistema antifraude.', null, 0, 1);
  --
  insert into tbgen_analise_fraude_param (CDOPERACAO, TPOPERACAO, HRRETENCAO, FLGEMAIL_ENTREGA, DSEMAIL_ENTREGA, DSASSUNTO_ENTREGA, DSCORPO_ENTREGA, FLGEMAIL_RETORNO, DSEMAIL_RETORNO, DSASSUNTO_RETORNO, DSCORPO_RETORNO, FLGATIVO, TPRETENCAO)
  values (14, 2, 24900, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha na entrega da Transferência Inter para a análise do sistema antifraude.', null, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha no retorno da análise de Transferência Inter do sistema antifraude.', null, 0, 2);
  --
  insert into tbgen_analise_fraude_param (CDOPERACAO, TPOPERACAO, HRRETENCAO, FLGEMAIL_ENTREGA, DSEMAIL_ENTREGA, DSASSUNTO_ENTREGA, DSCORPO_ENTREGA, FLGEMAIL_RETORNO, DSEMAIL_RETORNO, DSASSUNTO_RETORNO, DSCORPO_RETORNO, FLGATIVO, TPRETENCAO)
  values (15, 1, null, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha na entrega da Transferência Ailos Pag para a análise do sistema antifraude.', null, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha no retorno da análise de Transferência Ailos Pag do sistema antifraude.', null, 0, 1);

  /* Dados de transf. internas */
  cecred.pc_log_programa(pr_dstiplog => 'O', pr_cdprograma => vr_cdprogra, pr_cdcooper => 0, pr_dsmensagem => 'Dados de transf. internas', pr_idprglog => vr_idprglog);
  --
  insert into tbcc_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('CDOPERAC_ANALISE_FRAUDE', '13', 'Transferências Internas');
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (13, 1, 21600, 77400, 20);
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (13, 1, 77460, 78540, 10);
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (13, 1, 78600, 79200, 5);

  /* Dados de transf. intercooperativas */
  cecred.pc_log_programa(pr_dstiplog => 'O', pr_cdprograma => vr_cdprogra, pr_cdcooper => 0, pr_dsmensagem => 'Dados de transf. intercooperativas', pr_idprglog => vr_idprglog);
  --
  insert into tbcc_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('CDOPERAC_ANALISE_FRAUDE', '14', 'Intercooperativas');
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (14, 1, 21600, 77400, 20);
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (14, 1, 77460, 78540, 10);
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (14, 1, 78600, 79200, 5);

  /* Dados de transf. ailos pag */
  cecred.pc_log_programa(pr_dstiplog => 'O', pr_cdprograma => vr_cdprogra, pr_cdcooper => 0, pr_dsmensagem => 'Dados de transf. ailos pag', pr_idprglog => vr_idprglog);
  --
  insert into tbcc_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('CDOPERAC_ANALISE_FRAUDE', '15', 'Ailos Pag');
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (15, 1, 21600, 79200, 10);

  /* Dados de parametrizacao */
  cecred.pc_log_programa(pr_dstiplog => 'O', pr_cdprograma => vr_cdprogra, pr_cdcooper => 0, pr_dsmensagem => 'Dados de parametrizacao', pr_idprglog => vr_idprglog);
  --
  update tbgen_analise_fraude_param set vlcorte_envio_ofsaa = 1000 where cdoperacao > 12;
  --
  update crapaca c
     set c.lstparam = c.lstparam||',pr_vlcorteofs'
   where c.nmdeacao = 'CADFRA_GRAVA';
  --
  insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  values ((SELECT MAX(NRSEQACA)+1 FROM CRAPACA), 'CONSULTA_PARMON_OFS', 'TELA_PARMON', 'pc_consultar_parmon_ofs', 'pr_cdcoptel', 1024);
  --
  insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  values ((SELECT MAX(NRSEQACA)+1 FROM CRAPACA), 'ALTERA_PARMON_OFS', 'TELA_PARMON', 'pc_alterar_parmon_ofs', 'pr_cdcoptel,pr_vlflgtri,pr_vlflgico,pr_vlflgaip,pr_inflgtri,pr_inflgico,pr_inflgaip', 1024); 

  -- Gera log no início da execução
  cecred.pc_log_programa(pr_dstiplog   => 'F'         
                        ,pr_cdprograma => vr_cdprogra 
                        ,pr_cdcooper   => 0
                        ,pr_tpexecucao => 0     
                        ,pr_flgsucesso => 1     
                        ,pr_idprglog   => vr_idprglog);

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN

    ROLLBACK;

    -- Gera ocorrencia
    cecred.pc_log_programa(pr_dstiplog   => 'O'
                          ,pr_cdprograma => vr_cdprogra
                          ,pr_cdcooper   => 0
                          ,pr_dsmensagem => 'Erro nao tratado: '||SQLERRM
                          ,pr_idprglog   => vr_idprglog);

    -- Gera log no início da execução
    cecred.pc_log_programa(pr_dstiplog   => 'F'         
                          ,pr_cdprograma => vr_cdprogra 
                          ,pr_cdcooper   => 0
                          ,pr_tpexecucao => 0     
                          ,pr_flgsucesso => 0     
                          ,pr_idprglog   => vr_idprglog);

END;