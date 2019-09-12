PL/SQL Developer Test script 3.0
264
declare
  -- Non-scalar parameters require additional processing 
  vr_tab_dsdrisco         cecred.rati0001.typ_tab_dsdrisco;
  vr_dstextab_bacen       craptab.dstextab%TYPE;
  vr_nivrisco             VARCHAR2(2);
  vr_dtrefere             DATE;
  vr_cdcritic             crapcri.cdcritic%TYPE;
  vr_dscritic             VARCHAR2(4000);
  vr_innivris             INTEGER;
  vr_dslinha              VARCHAR2(4000);

  vr_flgcriar             INTEGER;
  vr_tab_rating_sing      RATI0001.typ_tab_crapras;
  vr_tab_impress_coop     RATI0001.typ_tab_impress_coop;
  vr_tab_impress_rating   RATI0001.typ_tab_impress_rating;
  vr_tab_impress_risco_cl RATI0001.typ_tab_impress_risco;
  vr_tab_impress_risco_tl RATI0001.typ_tab_impress_risco;
  vr_tab_impress_assina   RATI0001.typ_tab_impress_assina;
  vr_tab_ratings          RATI0001.typ_tab_ratings;
  vr_tab_crapras          RATI0001.typ_tab_crapras;
  vr_tab_efetivacao       RATI0001.typ_tab_efetivacao;
  vr_tab_erro             gene0001.typ_tab_erro;



  CURSOR cr_cop IS
    SELECT c.cdcooper, d.dtmvtolt
      FROM crapcop c, crapdat d
     WHERE c.flgativo = 1
       AND c.cdcooper = 11 -- REMOVER
       AND d.cdcooper = c.cdcooper
     ORDER BY c.cdcooper ;
  rw_cop  cr_cop%ROWTYPE;


  CURSOR cr_empr (pr_cdcooper  IN  crapcop.cdcooper%TYPE)IS
    SELECT w.dtmvtolt
          ,w.nrdconta
          ,w.nrctremp
          ,w.dsnivris risco_rating
          ,w.insitapr
          ,w.insitest
          ,a.nrcpfcnpj_base
      FROM crawepr w, crapass a
     WHERE a.cdcooper = w.cdcooper
       AND a.nrdconta = w.nrdconta
       AND NOT EXISTS (SELECT 1  -- CDCOOPER, DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRDCONTA, NRCTREMP
                         FROM crapepr e
                        WHERE e.cdcooper = w.cdcooper
                          AND e.DTMVTOLT = w.DTMVTOLT
                          AND e.nrdconta = w.nrdconta
                          AND e.nrctremp = w.nrctremp                          
                      )
       AND w.dtmvtolt >= '01/06/2019'
       AND w.dtexpira IS NULL
       AND w.cdcooper = pr_cdcooper
       AND ((w.insitest = 3 AND w.insitapr = 1) OR
            (w.insitest = 2 AND w.insitapr = 0) OR
            (w.insitapr = 2 AND 
             upper(w.cdopeapr) = 'MOTOR' AND
             w.dtenvest IS NULL)
           )
--           AND rownum <= 50
           ;
  rw_empr  cr_empr%ROWTYPE;
  
  
  CURSOR cr_desctit (pr_cdcooper  IN  crapcop.cdcooper%TYPE)IS
    SELECT w.cdcooper, w.nrdconta, w.nrctrlim, insitapr, insitlim ,insitest, tpctrlim
          ,a.nrcpfcnpj_base
      FROM crawlim w, crapass a
     WHERE w.cdcooper = pr_cdcooper
       AND w.tpctrlim = 3
       AND w.dtpropos >= '01/06/2019'
       AND a.cdcooper = w.cdcooper
       AND a.nrdconta = w.nrdconta
       AND w.insitapr = 5 -- rejeitado automaticamente
       AND w.insitlim = 6 -- nao aprovado
       AND w.insitest = 3 -- analise finalizada
  --     AND rownum <= 10
    UNION ALL
    SELECT w.cdcooper, w.nrdconta, w.nrctrlim, insitapr, insitlim ,insitest, tpctrlim  -- Enviada Analise Manual  
          ,a.nrcpfcnpj_base
      FROM crawlim w, crapass a
     WHERE w.cdcooper = pr_cdcooper
       AND w.tpctrlim = 3
       AND w.dtpropos >= '01/06/2019'
       AND a.cdcooper = w.cdcooper
       AND a.nrdconta = w.nrdconta
       AND w.insitapr = 0 -- nao analisado
       AND w.insitlim = 1 -- em estudo
       AND w.insitest = 2 -- enviada analise manual
  --     AND rownum <= 10
    UNION ALL
    SELECT w.cdcooper, w.nrdconta, w.nrctrlim, insitapr, insitlim ,insitest, tpctrlim   -- Analize Finalizada Aprovação Aut/Manul
          ,a.nrcpfcnpj_base
      FROM crawlim w, crapass a
     WHERE w.cdcooper = pr_cdcooper 
       AND w.tpctrlim = 3 -- Desconto Titulo
       AND w.dtpropos >= '01/06/2019'
       AND w.dtfimvig IS NULL
       AND a.cdcooper = w.cdcooper
       AND a.nrdconta = w.nrdconta
       AND insitapr   IN (1, 2) -- aprovada aut. / aprov manual
       AND w.insitlim = 5 -- aprovado
    --   AND rownum <= 10
    ;
  rw_desctit  cr_desctit%ROWTYPE;
  
  
BEGIN

  vr_tab_dsdrisco(0) := 'A';
  vr_tab_dsdrisco(1) := 'AA';
  vr_tab_dsdrisco(2) := 'A';
  vr_tab_dsdrisco(3) := 'B';
  vr_tab_dsdrisco(4) := 'C';
  vr_tab_dsdrisco(5) := 'D';
  vr_tab_dsdrisco(6) := 'E';
  vr_tab_dsdrisco(7) := 'F';
  vr_tab_dsdrisco(8) := 'G';
  vr_tab_dsdrisco(9) := 'H';
  vr_tab_dsdrisco(10) := 'HH';

  vr_dslinha := 'TIPO;COOP;CONTA;CONTRATO;RISCO';
  btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                            ,pr_ind_tipo_log => 2 -- Erro tratado
                            ,pr_nmarqlog     => 'CARGA_PROPOSTAS'
                            ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                               || vr_dslinha);
  FOR rw_cop IN cr_cop LOOP
    
    vr_nivrisco := NULL;
    --Popular variavel com valor risco bacen
    vr_dstextab_bacen:= TABE0001.fn_busca_dstextab(pr_cdcooper => rw_cop.cdcooper
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_tptabela => 'USUARI'
                                                   ,pr_cdempres => 11
                                                   ,pr_cdacesso => 'RISCOBACEN'
                                                   ,pr_tpregist => 0);



    FOR rw_empr IN cr_empr(rw_cop.cdcooper) LOOP

      cecred.rati0001.pc_obtem_risco(pr_cdcooper       => rw_cop.cdcooper,
                                     pr_nrdconta       => rw_empr.nrdconta,
                                     pr_tab_dsdrisco   => vr_tab_dsdrisco,
                                     pr_dstextab_bacen => vr_dstextab_bacen,
                                     pr_dtmvtolt       => rw_cop.dtmvtolt,                                         
                                     pr_nivrisco       => vr_nivrisco,
                                     pr_dtrefere       => vr_dtrefere,
                                     pr_cdcritic       => vr_cdcritic,
                                     pr_dscritic       => vr_dscritic);

            vr_innivris := risc0004.fn_traduz_nivel_risco(rw_empr.risco_rating);

            vr_dslinha := 'EMPR;'|| rw_cop.cdcooper || ';'   || rw_empr.nrdconta
                          || ';' || rw_empr.nrctremp
                          || ';' || vr_innivris;
            btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                      ,pr_ind_tipo_log => 2 -- Erro tratado
                                      ,pr_nmarqlog     => 'CARGA_PROPOSTAS'
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_dslinha);


            rati0003.pc_grava_rating_operacao(pr_cdcooper          => rw_cop.cdcooper
                                             ,pr_nrdconta          => rw_empr.nrdconta
                                             ,pr_tpctrato          => 90
                                             ,pr_nrctrato          => rw_empr.nrctremp
                                             ,pr_ntrataut          => vr_innivris
                                             ,pr_dtrataut          => rw_cop.dtmvtolt
                                             ,pr_strating          => 2  -- ANALISADO
                                             --Variáveis para gravar o histórico
                                             ,pr_cdoperad          => '1'
                                             ,pr_dtmvtolt          => rw_cop.dtmvtolt
                                             ,pr_valor             => NULL
                                             ,pr_rating_sugerido   => NULL
                                             ,pr_justificativa     => 'CARGA INICIA - PROPOSTAS ANALISADAS PENDENTES'
                                             ,pr_tpoperacao_rating => 1
                                             ,pr_nrcpfcnpj_base    => rw_empr.nrcpfcnpj_base
--                                             --Variáveis de crítica
                                             ,pr_cdcritic          => vr_cdcritic
                                             ,pr_dscritic          => vr_dscritic);
    END LOOP;
    COMMIT;



    FOR rw_desctit IN cr_desctit(rw_cop.cdcooper) LOOP
      ------------------------
      RATI0001.pc_calcula_rating(pr_cdcooper => rw_cop.cdcooper   --> Codigo Cooperativa
                                ,pr_cdagenci => 1   --> Codigo Agencia
                                ,pr_nrdcaixa => 1   --> Numero Caixa
                                ,pr_cdoperad => '1'   --> Codigo Operador
                                ,pr_nrdconta => rw_desctit.nrdconta   --> Numero da Conta
                                ,pr_tpctrato => 3             --> Tipo Contrato Rating
                                ,pr_nrctrato => rw_desctit.nrctrlim --> Numero Contrato Rating
                                ,pr_flgcriar => vr_flgcriar   --> Indicado se deve criar o rating
                                ,pr_flgcalcu => 1             --> Indicador de calculo
                                ,pr_idseqttl => 1              --> Sequencial do Titular
                                ,pr_idorigem => 1   --> Identificador Origem
                                ,pr_nmdatela => 'b1wgen0043'  --> Nome da tela
                                ,pr_flgerlog => 0             --> Identificador de geração de log
                                ,pr_tab_rating_sing      => vr_tab_rating_sing      --> Registros gravados para rati
                                ,pr_flghisto => 1
                                ,pr_tab_impress_coop     => vr_tab_impress_coop     --> Registro impressão da Cooper
                                ,pr_tab_impress_rating   => vr_tab_impress_rating   --> Registro itens do Rating
                                ,pr_tab_impress_risco_cl => vr_tab_impress_risco_cl --> Registro Nota e risco do coo
                                ,pr_tab_impress_risco_tl => vr_tab_impress_risco_tl --> Registro Nota e risco do coo
                                ,pr_tab_impress_assina   => vr_tab_impress_assina   --> Assinatura na impressao do R
                                ,pr_tab_efetivacao       => vr_tab_efetivacao       --> Registro dos itens da efetiv
                                ,pr_tab_ratings          => vr_tab_ratings          --> Informacoes com os Ratings d
                                ,pr_tab_crapras          => vr_tab_crapras          --> Tabela com os registros proc
                                ,pr_tab_erro             => vr_tab_erro             --> Tabela de retorno de erro
                                ,pr_des_reto             => vr_dscritic);           --> Ind. de retorno OK/NOK
           COMMIT;

            vr_innivris := risc0004.fn_traduz_nivel_risco(vr_tab_impress_risco_cl(vr_tab_impress_risco_cl.FIRST).dsdrisco);

            vr_dslinha := 'DESC.TIT;'|| rw_cop.cdcooper || ';'   || rw_desctit.nrdconta
                          || ';' || rw_desctit.nrctrlim
                          || ';' || vr_innivris;
            btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                      ,pr_ind_tipo_log => 2 -- Erro tratado
                                      ,pr_nmarqlog     => 'CARGA_PROPOSTAS'
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_dslinha);

            rati0003.pc_grava_rating_operacao(pr_cdcooper          => rw_cop.cdcooper
                                             ,pr_nrdconta          => rw_desctit.nrdconta
                                             ,pr_tpctrato          => 3
                                             ,pr_nrctrato          => rw_desctit.nrctrlim
                                             ,pr_ntrataut          => vr_innivris
                                             ,pr_dtrataut          => rw_cop.dtmvtolt
                                             ,pr_strating          => 2  -- ANALISADO
                                             --Variáveis para gravar o histórico
                                             ,pr_cdoperad          => '1'
                                             ,pr_dtmvtolt          => rw_cop.dtmvtolt
                                             ,pr_valor             => NULL  --pr_vllimite
                                             ,pr_rating_sugerido   => NULL
                                             ,pr_justificativa     => 'CARGA INICIA - PROPOSTAS ANALISADAS PENDENTES'
                                             ,pr_tpoperacao_rating => 1
                                             ,pr_nrcpfcnpj_base    => rw_desctit.nrcpfcnpj_base
--                                             --Variáveis de crítica
                                             ,pr_cdcritic          => vr_cdcritic
                                             ,pr_dscritic          => vr_dscritic);
------------------------
    END LOOP;
    COMMIT;

  END LOOP;
  COMMIT;
  
  vr_dslinha := '------------- FIM --------------';
  btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                            ,pr_ind_tipo_log => 2 -- Erro tratado
                            ,pr_nmarqlog     => 'CARGA_PROPOSTAS'
                            ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                               || vr_dslinha);
                                               
end;

8
pr_cdcooper
0
-4
pr_nrdconta
0
-4
pr_dstextab_bacen
0
-5
pr_dtmvtolt
0
-12
pr_nivrisco
0
-5
pr_dtrefere
0
-12
pr_cdcritic
0
-4
pr_dscritic
0
-5
2
vr_dtultdma
pr_nrdconta
