CREATE OR REPLACE PACKAGE CECRED.cont0002 IS
  /********************************************************************************
    Programa: CONT0002
    Autor   : Heitor / Alcemir (MOUTS)
    Data    : Outubro/2018                       Ultima Atualizacao: --/--/----

    Dados referentes ao programa:

    Objetivo  : Rotina para processamento de ajustes e geracao de arquivos contabeis.
                Processamento dos ajustes solicitado no Projeto 421 - Melhorias nas
                ferramentas contabeis e fiscais.

  ********************************************************************************/
  
  -- Public type declarations
  TYPE typ_reg_arquiv IS
        RECORD(nrdconta crapass.nrdconta%TYPE
              ,cdtransa craplcm.cdhistor%TYPE
              ,vltransa craplcm.vllanmto%TYPE);
              
  TYPE typ_tab_arquiv IS TABLE OF typ_reg_arquiv
    INDEX BY VARCHAR(20);   
    
  TYPE typ_critica IS
        RECORD(nrseqcri NUMBER(10)
              ,nrdconta crapass.nrdconta%TYPE
              ,vltransa NUMBER(25,2)
              ,dscritic crapcri.dscritic%TYPE);

  TYPE tab_critica IS TABLE OF typ_critica INDEX BY VARCHAR2(10);

  TYPE typ_transa IS
        RECORD(criticas tab_critica);

  type tab_transa is table of typ_transa index by VARCHAR(10);   

   -- Public type declarations
  TYPE typ_reg_arquiv_abbc IS
        RECORD(nrcheque crapfdc.nrcheque%TYPE   -- numero do cheque 
              ,vlcheque crapfdc.vlcheque%TYPE   -- valor do cheque
              ,cdageori crapfdc.cdagechq%TYPE   -- agencia de origem              
              ,nrctadep crapfdc.nrctadep%TYPE   -- numero da conta do depositante
              ,tpdearqv VARCHAR2(2));           -- tipo de arquivo SL OU SF
              
  TYPE typ_tab_arquiv_abbc IS TABLE OF typ_reg_arquiv_abbc
    INDEX BY VARCHAR(50);   
  
  TYPE typ_tab_cdcooper IS TABLE OF crapcop.cdcooper%TYPE
    INDEX BY PLS_INTEGER; 

  TYPE typ_tab_coop IS TABLE OF crapcop.cdcooper%TYPE
    INDEX BY PLS_INTEGER;
        

  PROCEDURE pc_processa_arquivo_bancoob(pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_cdcritic OUT NUMBER                --> Desc. da crítica
                                       ,pr_dscritic OUT VARCHAR2);

  --Procedure para geracao das guias de pagamento IOF e IRRF decendiais
  PROCEDURE pc_gera_iof_irrf_decendial(pr_cdcooper IN crapcop.cdcooper%TYPE
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE);

  --Procedure para geracao de segregacao de prejuizo
  PROCEDURE pc_gera_segregacao_prejuizo(pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE);

  --Procedure para processamento dos ajustes/arquivos do projeto 421 - Melhorias nas ferramentas contabeis e fiscais
  PROCEDURE pc_processa_contabil;
  
  PROCEDURE pc_processa_arquivo_abbc(pr_cdcooper IN crapcop.cdcooper%TYPE
                                    ,pr_cdcritic OUT NUMBER                --> Desc. da crítica
                                    ,pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_processa_lanc_slip(pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ,pr_cdcritic OUT NUMBER                --> Desc. da crítica
                                    ,pr_dscritic OUT VARCHAR2);

END cont0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.cont0002 IS
  /********************************************************************************
    Programa: CONT0002
    Autor   : Heitor / Alcemir (MOUTS)
    Data    : Outubro/2018                       Ultima Atualizacao: --/--/----

    Dados referentes ao programa:

    Objetivo  : Rotina para processamento de ajustes e geracao de arquivos contabeis.
                Processamento dos ajustes solicitado no Projeto 421 - Melhorias nas
                ferramentas contabeis e fiscais.

    Alteracoes: 

  ********************************************************************************/

  PROCEDURE pc_processa_arquivo_bancoob(pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_cdcritic OUT NUMBER                --> Desc. da crítica
                                       ,pr_dscritic OUT VARCHAR2) is

     --operações invertidas para teste depois alterar

     CURSOR cr_craplcm (pr_cdcooper craplcm.cdcooper%TYPE
                       ,pr_nrdconta craplcm.nrdconta%TYPE
                       ,pr_cdtransa craplcm.cdhistor%TYPE
                       ,pr_dtmvtolt craplcm.dtmvtolt%TYPE) IS
      SELECT nvl(SUM(decode(tcb.indebcre,'D',lcm.vllanmto*-1,lcm.vllanmto)),0) vllanmto FROM craplcm lcm -- invertido aqui
       LEFT JOIN tbcontab_conc_bancoob tcb ON (tcb.cdhistor = lcm.cdhistor)
       WHERE lcm.cdcooper = pr_cdcooper
        AND  lcm.nrdconta = pr_nrdconta
        AND  lcm.dtmvtolt = pr_dtmvtolt
        AND  lcm.cdhistor IN (SELECT tcb.cdhistor FROM tbcontab_conc_bancoob tcb 
                               WHERE tcb.cdtransa = pr_cdtransa GROUP BY tcb.cdhistor); 
     rw_craplcm cr_craplcm%ROWTYPE;

     -- lancamentos do cartao
     CURSOR cr_craplcm_lanc (pr_cdcooper craplcm.cdcooper%TYPE
                            ,pr_dtmvtolt craplcm.dtmvtolt%TYPE) IS
      SELECT lcm.nrdconta,tcb.cdtransa,nvl(SUM(decode(tcb.indebcre,'D',lcm.vllanmto*-1,lcm.vllanmto)),0) vllanmto FROM craplcm lcm -- invertido aqui
      LEFT JOIN tbcontab_conc_bancoob tcb ON (tcb.cdhistor = lcm.cdhistor)
       WHERE lcm.cdcooper = pr_cdcooper
        AND  lcm.dtmvtolt = pr_dtmvtolt
        AND  lcm.cdhistor IN (SELECT tcb.cdhistor FROM tbcontab_conc_bancoob tcb GROUP BY tcb.cdhistor)
      GROUP BY lcm.nrdconta,tcb.cdtransa;
     rw_craplcm_lanc cr_craplcm_lanc%ROWTYPE;
     
     CURSOR cr_hist_ailos(pr_cdtransa IN tbcontab_conc_bancoob.cdtransa%TYPE) IS
      SELECT cdhistor FROM tbcontab_conc_bancoob tcb 
       WHERE tcb.cdtransa = pr_cdtransa
        AND  tcb.indebcre = 'C';
      rw_hist_ailos cr_hist_ailos%ROWTYPE;
      
     -- fazer cursor para pegar historicos do bancoob
     CURSOR cr_transacao (pr_cdtransa IN tbcontab_transa_bancoob.cdtransa%TYPE) IS
      SELECT ttb.cdtransa,ttb.dstransa FROM tbcontab_transa_bancoob ttb
       WHERE ttb.cdtransa = pr_cdtransa;
     rw_transacao cr_transacao%ROWTYPE;
     
     CURSOR cr_crapcop(pr_cdagebcb crapcop.cdagebcb%TYPE) IS
      SELECT cdcooper,nmrescop FROM crapcop
       WHERE cdagebcb = pr_cdagebcb;
     rw_crapcop cr_crapcop%ROWTYPE;
     
     CURSOR cr_indebcre (pr_cdtransa IN tbcontab_transa_bancoob.cdtransa%TYPE) IS
      SELECT CAST(decode(ttb.indebcre,'D',-1,1) AS NUMBER) AS indebcre FROM tbcontab_transa_bancoob ttb
       WHERE ttb.cdtransa = pr_cdtransa;
     rw_indebcre cr_indebcre%ROWTYPE;
     
     --
     CURSOR cr_transacao1 (pr_cdtransa IN tbcontab_conc_bancoob.cdtransa%TYPE) IS 
      SELECT MAX(1) FROM tbcontab_transa_bancoob ttb
       WHERE  NOT EXISTS (SELECT 1 FROM tbcontab_conc_bancoob tcb WHERE tcb.cdtransa = pr_cdtransa);

     vr_nomedarq VARCHAR2(200) := NULL;
     vr_nmdircop VARCHAR(200) := NULL;
     
     vr_dslisarq VARCHAR(4000);
     vr_setlinha VARCHAR(4000);
     vr_idx VARCHAR(20);
     vr_idx_conta PLS_INTEGER;
     vr_idx_transa PLS_INTEGER;
     vr_nrdconta NUMBER;
     vr_cdtransa NUMBER;
     vr_vltransa NUMBER;
     vr_dttransa DATE;
     vr_dstransa VARCHAR2(200);
     vr_clobxml CLOB;
     vr_dstexto VARCHAR2(32767);
     -- Data do movimento no formato yymmdd
     vr_dtmvtolt_yymmdd     VARCHAR2(8);
     vr_seq_critica NUMBER;
     vr_tot_pos NUMBER;
     vr_tot_neg NUMBER;
     -- Nome do diretório
     vr_nom_diretorio       varchar2(200);
     vr_dsdircop            varchar2(200);
     vr_nmdireto            varchar2(200);
     -- Nome do arquivo que será gerado
     vr_nmarqnov            VARCHAR2(50); -- nome do arquivo por cooperativa
     vr_nmarqdat            varchar2(50);

     -- Arquivo texto
     vr_arquivo_txt         utl_file.file_type;
     vr_linhadet            varchar2(200);
     vr_transacao1    NUMBER(1);
     vr_dtmvtolt DATE;
     vr_cdagebcb NUMBER;
     vr_vldiflan NUMBER;
     vr_farquivo utl_file.file_type;
     vr_tab_nmarqtel gene0002.typ_split;
     vr_tab_regarqvo typ_tab_arquiv;
     vr_tab_linhacsv gene0002.typ_split;
     vr_typ_said VARCHAR2(4);
     vr_dscritic VARCHAR2(4000);
     vr_cdcritic NUMBER;
     vr_exc_saida EXCEPTION;
     vr_exc_proxima_linha EXCEPTION;
     vr_tab_critica tab_critica;
     vr_tab_transa tab_transa;   
  

  begin
    BEGIN
      --arquivos a serem listados
      vr_nomedarq := '756-2011%TRANSACOES_CEXT'||to_char(SYSDATE,'RRRR-MM-DD')||'.CSV';
                      
      vr_nmdircop := gene0001.fn_diretorio(pr_tpdireto => 'M'
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => 'cecred_cartoes');
  
      gene0001.pc_lista_arquivos(pr_path     => vr_nmdircop
                                ,pr_pesq     => vr_nomedarq
                                ,pr_listarq  => vr_dslisarq
                                ,pr_des_erro => vr_dscritic);

      vr_tab_nmarqtel := gene0002.fn_quebra_string(vr_dslisarq);


      -- interar arquivos
      FOR idx IN 1..vr_tab_nmarqtel.count() LOOP

          gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdircop  --> Diretorio do arquivo
                                  ,pr_nmarquiv => vr_tab_nmarqtel(idx) --> Nome do arquivo
                                  ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                                  ,pr_utlfileh => vr_farquivo  --> Handle do arquivo aberto
                                  ,pr_des_erro => vr_dscritic);  --> Erro
          
          IF vr_dscritic IS NOT NULL THEN
             RAISE vr_exc_saida;
          END IF;


            BEGIN

             -- IGNORAR A PRIMEIRA LINHA
             gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_farquivo --> Handle do arquivo aberto
                                         ,pr_des_text => vr_setlinha); --> Texto lido


           EXCEPTION
             WHEN NO_DATA_FOUND THEN
               --Chegou ao final arquivo, sair do loop
               EXIT;
             WHEN OTHERS THEN
               vr_dscritic:= 'Erro na leitura do arquivo. '||sqlerrm;
               RAISE vr_exc_saida;
           END;
                                   
           -- obter cdagebcb que esta no nome do arquivo
           vr_cdagebcb := substr(vr_tab_nmarqtel(idx),10,4);

           -- buscar cooperativa
           OPEN cr_crapcop(pr_cdagebcb => vr_cdagebcb);
           FETCH cr_crapcop INTO rw_crapcop;

           IF cr_crapcop%NOTFOUND THEN
             CLOSE cr_crapcop;
             CONTINUE;
           END IF;

           CLOSE cr_crapcop;

           vr_dtmvtolt := to_date(REPLACE(SUBSTR(vr_tab_nmarqtel(idx),LENGTH(vr_tab_nmarqtel(idx))-13,10),'-',''),'yyyymmdd') - 1;
                              
           vr_tot_neg := 0;
           vr_tot_pos := 0;
           
           vr_tab_critica.delete;          
           vr_tab_regarqvo.delete;
           vr_tab_transa.delete;

           -- loop para ler a linha do arquivo
           LOOP
           BEGIN
             
             BEGIN

               -- ler novamente
               gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_farquivo --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto lido
               

             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 --Chegou ao final arquivo, sair do loop
                 EXIT;
               WHEN OTHERS THEN
                 vr_dscritic:= 'Erro na leitura do arquivo. '||sqlerrm;
                 RAISE vr_exc_saida;
             END;

             
             vr_tab_linhacsv := gene0002.fn_quebra_string(vr_setlinha,';');
             
             
             -- percorrer os campos do arquivo CSV
             FOR idx IN 1..vr_tab_linhacsv.count() LOOP
               -- verificar os campos e jogar na pltable
               CASE
                  WHEN idx = 3 THEN vr_nrdconta := gene0002.fn_char_para_number(vr_tab_linhacsv(idx));
                  WHEN idx = 5 THEN vr_cdtransa := gene0002.fn_char_para_number(vr_tab_linhacsv(idx));
                  WHEN idx = 6 THEN vr_vltransa := gene0002.fn_char_para_number(vr_tab_linhacsv(idx));
                  WHEN idx = 9 THEN vr_dttransa := to_date(vr_tab_linhacsv(idx),'DD/MM/RRRR');
                  ELSE CONTINUE;
               END CASE;
             END LOOP;

               IF  vr_cdtransa = 5041
               AND to_char(SYSDATE,'IW') <> to_char(vr_dttransa,'IW') THEN
                 RAISE vr_exc_proxima_linha;
               END IF;
               
               -- verificamos se a transação esta parametrizada (PARCBA - TELA PARA A PARAMETRIZAÇÃO)
               rw_transacao := NULL;                              

               OPEN cr_transacao(vr_cdtransa);
               FETCH cr_transacao INTO rw_transacao;
               CLOSE cr_transacao;
               
               IF rw_transacao.cdtransa IS NULL THEN
                  -- se não estiver parametrizada pular para a proxima linha
                  RAISE vr_exc_proxima_linha;
               END IF;  
                                             
               -- busca operador - ou + para aplicar no valor da transação bancoob 
               OPEN cr_indebcre(pr_cdtransa => vr_cdtransa);
                FETCH cr_indebcre INTO rw_indebcre;
               CLOSE cr_indebcre;               
               
               vr_vltransa := nvl(vr_vltransa*rw_indebcre.indebcre,1); -- caso a transacao sejá debito rw_indebcre.indebcre retorna -1                 
               -- montar indice para vr_tab_regarqvo
               vr_idx := vr_nrdconta || vr_cdtransa;

               --verificar se já existe o registro, se existir acumular valor de transação
               --caso contrario apenas inserir na pltable.
               IF vr_tab_regarqvo.exists(vr_idx) THEN
                 vr_tab_regarqvo(vr_idx).vltransa := vr_tab_regarqvo(vr_idx).vltransa + vr_vltransa;
               ELSE
                 vr_tab_regarqvo(vr_idx).nrdconta :=  vr_nrdconta;
                 vr_tab_regarqvo(vr_idx).cdtransa :=  vr_cdtransa;
                 vr_tab_regarqvo(vr_idx).vltransa :=  vr_vltransa;
               END IF;
           EXCEPTION
             WHEN vr_exc_proxima_linha THEN
               NULL;                                
           END; 
           
           END LOOP; -- fim loop linha arquivo
           
           
           -- verificar as diferenças
           vr_idx := vr_tab_regarqvo.first;

           WHILE vr_idx IS NOT NULL LOOP
                 

               rw_craplcm := NULL;
               -- verificar se a transação esta cadastrada
               --                                                                         
               OPEN cr_craplcm(pr_cdcooper => rw_crapcop.cdcooper
                              ,pr_nrdconta => vr_tab_regarqvo(vr_idx).nrdconta
                              ,pr_cdtransa => vr_tab_regarqvo(vr_idx).cdtransa
                              ,pr_dtmvtolt => vr_dtmvtolt);
               FETCH cr_craplcm INTO rw_craplcm;

               CLOSE cr_craplcm;
                             
               vr_vldiflan := rw_craplcm.vllanmto + vr_tab_regarqvo(vr_idx).vltransa;
                      
               rw_hist_ailos := NULL;
                
               OPEN cr_hist_ailos(pr_cdtransa => vr_tab_regarqvo(vr_idx).cdtransa);
               FETCH cr_hist_ailos INTO rw_hist_ailos;
               CLOSE cr_hist_ailos;
               
               vr_idx_conta := vr_tab_regarqvo(vr_idx).nrdconta;
               vr_idx_transa := vr_tab_regarqvo(vr_idx).cdtransa;
               
               OPEN cr_transacao1 (pr_cdtransa =>  vr_tab_regarqvo(vr_idx).cdtransa);
               FETCH cr_transacao1 INTO vr_transacao1;
               CLOSE cr_transacao1;
               
               -- se encontrou a transacao sem historico ailos
               -- deve sair no relatorio, e gerado lançamento contabil
               IF vr_transacao1 = 1 THEN
                 vr_tab_critica(vr_idx_conta).nrdconta := vr_tab_regarqvo(vr_idx).nrdconta;
                 vr_tab_critica(vr_idx_conta).vltransa := vr_vldiflan;   
                 vr_tab_critica(vr_idx_conta).dscritic := 'HISTORICO ' || vr_tab_regarqvo(vr_idx).cdtransa || ' SEM CONTRAPARTIDA';
                 vr_tab_transa(vr_idx_transa).criticas(vr_idx_conta) := vr_tab_critica(vr_idx_conta);                 
               ELSE
                 
                 
                 IF vr_vldiflan > 0 THEN
                   -- popular critica
                   vr_tab_critica(vr_idx_conta).nrdconta := vr_tab_regarqvo(vr_idx).nrdconta;
                   vr_tab_critica(vr_idx_conta).vltransa := vr_vldiflan;                 
                   vr_tab_critica(vr_idx_conta).dscritic := 'HISTORICO ' || rw_hist_ailos.cdhistor  || ' SEM HISTORICO '
                                                     || vr_tab_regarqvo(vr_idx).cdtransa;
                                                     
                   vr_tab_transa(vr_idx_transa).criticas(vr_idx_conta) := vr_tab_critica(vr_idx_conta);                                                   

                 END IF;

                 IF vr_vldiflan <  0 THEN
                   -- popular critica
                   vr_tab_critica(vr_idx_conta).nrdconta := vr_tab_regarqvo(vr_idx).nrdconta;
                   vr_tab_critica(vr_idx_conta).vltransa := vr_vldiflan;         
                   vr_tab_critica(vr_idx_conta).dscritic := 'HISTORICO ' || vr_tab_regarqvo(vr_idx).cdtransa  || ' SEM HISTORICO '
                                                                   || rw_hist_ailos.cdhistor;
                                                                   
                   vr_tab_transa(vr_idx_transa).criticas(vr_idx_conta) := vr_tab_critica(vr_idx_conta);                                                                 

                 END IF;
               END IF;                                             
             vr_idx := vr_tab_regarqvo.next(vr_idx);


           END LOOP;

           -- serve para verificar se existe lançamento na lcm
           -- Mas que não exista no arquivo
           FOR rw_craplcm_lanc IN cr_craplcm_lanc(pr_cdcooper => rw_crapcop.cdcooper
                                                 ,pr_dtmvtolt => vr_dtmvtolt) LOOP

             -- buscar historico bancoob do parametro
             vr_idx := rw_craplcm_lanc.nrdconta || rw_craplcm_lanc.cdtransa;

             IF vr_idx IS NULL THEN
               continue;
             END IF;
             
             vr_idx_conta := rw_craplcm_lanc.nrdconta;
             vr_idx_transa := rw_craplcm_lanc.cdtransa;
             
             rw_hist_ailos := NULL;
             
             OPEN cr_hist_ailos(pr_cdtransa => rw_craplcm_lanc.cdtransa);
             FETCH cr_hist_ailos INTO rw_hist_ailos;
             CLOSE cr_hist_ailos;
             
             IF NOT vr_tab_regarqvo.exists(vr_idx) THEN
               
               IF rw_craplcm_lanc.vllanmto > 0 THEN
                 -- popular citica
                 vr_tab_critica(vr_idx_conta).nrdconta:= rw_craplcm_lanc.nrdconta;                
                 vr_tab_critica(vr_idx_conta).vltransa := rw_craplcm_lanc.vllanmto;
                 vr_tot_pos := vr_tot_pos + rw_craplcm_lanc.vllanmto;
                 vr_tab_critica(vr_idx_conta).dscritic := 'HISTORICO ' || rw_hist_ailos.cdhistor  || ' SEM HISTORICO '
                                                   || rw_craplcm_lanc.cdtransa;                                                   
                 vr_tab_transa(vr_idx_transa).criticas(vr_idx_conta) := vr_tab_critica(vr_idx_conta);                                                                                                       

               END IF;

               IF rw_craplcm_lanc.vllanmto <  0 THEN
                 -- popular critica;
                 vr_tab_critica(vr_idx_conta).nrdconta := rw_craplcm_lanc.nrdconta;
                 vr_tab_critica(vr_idx_conta).vltransa := rw_craplcm_lanc.vllanmto;
                 vr_tot_neg := vr_tot_neg + rw_craplcm_lanc.vllanmto;
                 vr_tab_critica(vr_idx_conta).dscritic := 'HISTORICO ' || rw_craplcm_lanc.cdtransa  || ' SEM HISTORICO '
                                                   || rw_hist_ailos.cdhistor;                                                   
                 vr_tab_transa(vr_idx_transa).criticas(vr_idx_conta) := vr_tab_critica(vr_idx_conta);
               END IF;
                              
             END IF;


           END LOOP;
                   
     IF vr_tab_transa.count > 0 THEN 

        -- gerar arquivo contabil
        vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                                pr_cdcooper => rw_crapcop.cdcooper,
                                                pr_nmsubdir => 'contab');

       -- Busca o diretório final para copiar arquivos
       vr_dsdircop := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                               ,pr_cdcooper => 0
                                               ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');
       -- Nome do arquivo a ser gerado
       vr_dtmvtolt_yymmdd := to_char(vr_dtmvtolt, 'yyyymmdd');
       vr_nmarqdat        := vr_dtmvtolt_yymmdd||'_CONCILIA_CARTOES.txt';
              
       -- gera xml para rel crrlxxx
       dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
       dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

       -- Escrever no arquivo XML
       GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                              '<?xml version="1.0" encoding="UTF-8"?><crrl760><transacoes>');
         
       -- Abre o arquivo para escrita
       gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio,    --> Diretório do arquivo
                                   pr_nmarquiv => vr_nmarqdat,         --> Nome do arquivo
                                   pr_tipabert => 'W',                 --> Modo de abertura (R,W,A)
                                   pr_utlfileh => vr_arquivo_txt,      --> Handle do arquivo aberto
                                   pr_des_erro => vr_dscritic);

       if vr_dscritic is not null then
         vr_cdcritic := 0;
         RAISE vr_exc_saida;
       end if;
                 
       -- ira interar as diferenças para gerar o arquivo contabil
       -- alem de relatório de critica Crrlxxx
        
       vr_idx_transa := vr_tab_transa.first;
            
       --percorrer as transações   
       WHILE vr_idx_transa IS NOT NULL LOOP
            
          vr_idx_conta := vr_tab_transa(vr_idx_transa).criticas.first;
            
          OPEN cr_transacao (vr_idx_transa);
          FETCH cr_transacao INTO rw_transacao;
          CLOSE cr_transacao;
          
          vr_dstransa := rw_transacao.dstransa;

          vr_seq_critica := 0;
          
          GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'<transacao cdtransa="'|| vr_idx_transa ||'" dstransa="'|| vr_dstransa ||'">');
            
          WHILE vr_idx_conta IS NOT NULL LOOP
              
            vr_seq_critica := vr_seq_critica + 1;
            
              
              
            GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                '<critica>' || 
                '  <nrseqcri>'|| to_char(vr_seq_critica) ||'</nrseqcri>'||
                '  <nrdconta>'|| gene0002.fn_mask_conta(vr_tab_transa(vr_idx_transa).criticas(vr_idx_conta).nrdconta) ||'</nrdconta>'||
                '  <vltransa>'|| TO_CHAR(vr_tab_transa(vr_idx_transa).criticas(vr_idx_conta).vltransa,'FM999999999990D00') ||'</vltransa>'||
                '  <dscritic>'|| TO_CHAR(vr_tab_transa(vr_idx_transa).criticas(vr_idx_conta).dscritic) ||'</dscritic>'||
               '</critica>');
                 
                 
            IF vr_tab_transa(vr_idx_transa).criticas(vr_idx_conta).vltransa < 0 THEN
       
              /* Escrita arquivo */
              vr_linhadet := TRIM(vr_dtmvtolt_yymmdd)||','||
                             trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                             '1779,'||
                             '1242,'||
                             trim(to_char(vr_tab_transa(vr_idx_transa).criticas(vr_idx_conta).vltransa*-1,'999999999999.00'))||','|| --valor deve ir positivo para o arquivo
                             '5210,'||
                             '"PEND. IDENT. CARTAO BANCOOB REF. C/C ' || gene0002.fn_mask_conta(vr_tab_transa(vr_idx_transa).criticas(vr_idx_conta).nrdconta)
                             || ' - ' || vr_dstransa || ' - A REGULARIZAR"';

              gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
              /* Fim escrita arquivo */


            END IF;

            IF vr_tab_transa(vr_idx_transa).criticas(vr_idx_conta).vltransa > 0 THEN
              
              /* Escrita arquivo */
              vr_linhadet := TRIM(vr_dtmvtolt_yymmdd)||','||
                             trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                             '1242,'||
                             '4899,'||
                             trim(to_char(vr_tab_transa(vr_idx_transa).criticas(vr_idx_conta).vltransa, '999999999999.00'))||','||
                             '5210,'||
                             '"PEND. IDENT. CARTAO BANCOOB REF. C/C ' || gene0002.fn_mask_conta(vr_tab_transa(vr_idx_transa).criticas(vr_idx_conta).nrdconta)
                             || ' - ' || vr_dstransa || ' - A REGULARIZAR"';

              gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
              /* Fim escrita arquivo */
            END IF;
              
            vr_idx_conta := vr_tab_transa(vr_idx_transa).criticas.next(vr_idx_conta);
          END LOOP;
            
          GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</transacao>');
            
          vr_idx_transa := vr_tab_transa.next(vr_idx_transa);

        END LOOP; 
          
        gene0001.pc_fecha_arquivo(vr_arquivo_txt);
                   

        GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</transacoes></crrl760>',TRUE);

        -- Busca o diretorio padrao do sistema
        vr_nmdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => rw_crapcop.cdcooper
                                            ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

        -- Efetuar solicitacao de geracao de relatorio
        GENE0002.pc_solicita_relato(pr_cdcooper  => rw_crapcop.cdcooper,
                                    pr_cdprogra  => 'PARCBA',
                                    pr_dtmvtolt  => vr_dtmvtolt,
                                    pr_dsxml     => vr_clobxml,
                                    pr_dsxmlnode => '/crrl760',
                                    pr_dsjasper  => 'crrl760.jasper',
                                    pr_dsparams  => NULL,
                                    pr_dsarqsaid => vr_nmdireto || '/crrl760.lst',
                                    pr_flg_gerar => 'N',
                                    pr_qtcoluna  => 132,
                                    pr_cdrelato  => 760,
                                    pr_flg_impri => 'S',
                                    pr_nmformul  => '132col',
                                    pr_nrcopias  => 1,
                                    pr_des_erro  => vr_dscritic);

        -- Fechar Clob e Liberar Memoria
        dbms_lob.close(vr_clobxml);
        dbms_lob.freetemporary(vr_clobxml);

        -- Testar se houve erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        vr_nmarqnov := vr_dtmvtolt_yymmdd||'_'||LPAD(TO_CHAR(rw_crapcop.cdcooper),2,0)||'_CONCILIA_CARTOES.txt';
                                                   
        
        -- Copia o arquivo gerado para o diretório final convertendo para DOS
        gene0001.pc_oscommand_shell(pr_des_comando =>  'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqdat||' > '||vr_dsdircop||'/'||vr_nmarqnov||' 2>/dev/null',
                                    pr_typ_saida   => vr_typ_said,
                                    pr_des_saida   => vr_dscritic);
                
        -- Testar erro
        if vr_typ_said = 'ERR' then
           vr_cdcritic := 1040;
           gene0001.pc_print(gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_nmarqdat||': '||vr_dscritic);
        end if;
        
     END IF;   
                                 
     COMMIT;
                 
    END LOOP;
    
    
    EXCEPTION

      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
           -- Buscar a descrição
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
             -- Devolvemos código e critica encontradas 
           pr_cdcritic := NVL(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
        ELSE
           pr_cdcritic := vr_cdcritic;
           pr_dscritic := vr_dscritic; 
        END IF;             
        ROLLBACK;  
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => 1);
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral na rotina. ' || Sqlerrm;
        ROLLBACK;
    END;
  END pc_processa_arquivo_bancoob;

  PROCEDURE pc_calcula_decendio(pr_dtmvtoan IN DATE
                               ,pr_dtmvtolt IN DATE
                               ,pr_dtini    OUT DATE
                               ,pr_dtfim    OUT DATE) IS
  BEGIN
    IF TO_CHAR(pr_dtmvtoan, 'DD') <= 10 AND TO_CHAR(pr_dtmvtolt, 'DD') > 10 THEN
      pr_dtini := TO_DATE('01' || TO_CHAR(pr_dtmvtoan, '/MM/RRRR'), 'DD/MM/RRRR');
      pr_dtfim := TO_DATE('10' || TO_CHAR(pr_dtmvtoan, '/MM/RRRR'), 'DD/MM/RRRR');
    ELSIF TO_CHAR(pr_dtmvtoan, 'DD') <= 20 AND TO_CHAR(pr_dtmvtolt, 'DD') > 20 THEN
      pr_dtini := TO_DATE('11' || TO_CHAR(pr_dtmvtoan, '/MM/RRRR'), 'DD/MM/RRRR');
      pr_dtfim := TO_DATE('20' || TO_CHAR(pr_dtmvtoan, '/MM/RRRR'), 'DD/MM/RRRR');
    ELSIF TO_CHAR(pr_dtmvtoan, 'MM') <> TO_CHAR(pr_dtmvtolt, 'MM') THEN
      pr_dtini := TO_DATE('21' || TO_CHAR(pr_dtmvtoan, '/MM/RRRR'), 'DD/MM/RRRR');
      pr_dtfim := LAST_DAY(pr_dtmvtoan);
    ELSE
      pr_dtini    := NULL;
      pr_dtfim    := NULL;
    END IF;
  END;

  --Prj 421 - Item 20 (DR)
  PROCEDURE pc_gera_iof_irrf_decendial(pr_cdcooper IN crapcop.cdcooper%TYPE
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
    --Cursor para buscar as cooperativas
    CURSOR cr_crapcop IS
      SELECT c.cdcooper
           , c.nmrescop
           , c.nrdocnpj
           , c.nmrescop||' PA '|| min(x.cdagenci) nmcooper
        FROM crapage x
           , crapcop c
       WHERE x.cdcooper = c.cdcooper
         AND c.flgativo = 1
         AND x.flgdsede = 1
         AND c.cdcooper <> pr_cdcooper
       GROUP
          BY c.cdcooper
           , c.nmrescop
           , c.nrdocnpj
           , c.nmrescop;

    --Cursor para busca de IOF
    CURSOR cr_iof(pr_cdcooper IN crapcop.cdcooper%TYPE
                 ,pr_dtini    IN DATE
                 ,pr_dtfim    IN DATE) IS
      SELECT decode(c.inpessoa,1,1,2) inpessoa
           , SUM(t.vliof) vliof
        FROM crapass              c
           , tbgen_iof_lancamento t
       WHERE c.cdcooper = t.cdcooper
         AND c.nrdconta = t.nrdconta
         AND t.cdcooper = pr_cdcooper
         AND t.dtmvtolt BETWEEN pr_dtini AND pr_dtfim
       GROUP
          BY decode(c.inpessoa,1,1,2);

    --Cursor para busca de IRRF
    CURSOR cr_irrf(pr_cdcooper IN crapcop.cdcooper%TYPE
                  ,pr_dtini    IN DATE) IS
      SELECT c.inpessoa
           , c.vlapagar
        FROM gnarrec c
       WHERE c.cdcooper = pr_cdcooper
         AND c.dtiniapu = pr_dtini
         AND c.tpimpost = 2;
    
    --Tabela de feriados para calcula da data de recolhimento
    CURSOR cr_crapfer(pr_cdcooper IN crapfer.cdcooper%TYPE      --> Código da cooperativa
                     ,pr_dtrecolh IN crapfer.dtferiad%TYPE) IS  --> Data de recolhimento
      SELECT cf.dsferiad
        FROM crapfer cf
       WHERE cf.cdcooper = pr_cdcooper
         AND cf.dtferiad = pr_dtrecolh;

    rw_crapfer cr_crapfer%ROWTYPE;

    --Variaveis
    vr_dtini    DATE;
    vr_dtfim    DATE;
    vr_dtrecolh DATE;
    vr_contador NUMBER;
    
    -- Data do movimento no formato yymmdd
    vr_dtmvtolt_yymmdd     varchar2(6);
      
    -- Nome do diretório
    vr_nom_diretorio       varchar2(200);
    vr_dsdircop            varchar2(200);

    -- Nome do arquivo que será gerado
    vr_nmarqnov            VARCHAR2(50); -- nome do arquivo por cooperativa
    vr_nmarqdat            varchar2(50);

    -- Arquivo texto
    vr_arquivo_txt         utl_file.file_type;
    vr_linhadet            varchar2(500);

    -- Tratamento de erros
    vr_typ_said            VARCHAR2(4);

    -- Variaveis de Erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);

    -- Variaveis de Excecao
    vr_exc_erro EXCEPTION;
  BEGIN
    --Utilizar as datas da CENTRAL
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    --Verifica as datas do decendio
    --Utilizar as datas AN e LT pois irá rodar em JOB após a execução da rotina diária
    pc_calcula_decendio(btch0001.rw_crapdat.dtmvtoan
                       ,btch0001.rw_crapdat.dtmvtolt
                       ,vr_dtini
                       ,vr_dtfim);

    --Se a data retornar nula da procedure pc_calcula_decendio significa que não deve calcular as guias decendiais (Data inválida)
    IF vr_dtini IS NOT NULL THEN
      --Buscar data de recolhimento
      vr_dtrecolh := vr_dtfim + 1;
      vr_contador := 0;

      -- Fazer varredura até encontrar data util
      LOOP
        -- Busca se a data é feriado
        -- Buscar data de processamento
        OPEN cr_crapfer(pr_cdcooper, vr_dtrecolh);
        FETCH cr_crapfer INTO rw_crapfer;
        -- Se a data não for sabado ou domingo ou feriado
        IF NOT(TO_CHAR(vr_dtrecolh, 'd') IN (1,7) OR cr_crapfer%FOUND) THEN
          vr_contador := vr_contador + 1;
        END IF;
        --
        close cr_crapfer;
        -- Sair quando encontrar o 3º dia apos
        exit when vr_contador >= 3;
        -- Incrementar data
        vr_dtrecolh := vr_dtrecolh + 1;
      END LOOP;

      -- Busca próximo dia útil considerando feriados e finais de semana
      vr_dtrecolh := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                ,pr_dtmvtolt => vr_dtrecolh
                                                ,pr_tipo => 'P');
      
      /* Prj421 - Geracao de arquivo contabil */
      -- Busca do diretório onde ficará o arquivo
      vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                                pr_cdcooper => pr_cdcooper,
                                                pr_nmsubdir => 'contab');
                                                
      -- Busca o diretório final para copiar arquivos
      vr_dsdircop := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => 0
                                              ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');
      -- Nome do arquivo a ser gerado
      vr_dtmvtolt_yymmdd := to_char(btch0001.rw_crapdat.dtmvtoan, 'yymmdd');
      vr_nmarqdat        := vr_dtmvtolt_yymmdd||'_IRRF_IOF.txt';

      -- Abre o arquivo para escrita
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio,    --> Diretório do arquivo
                               pr_nmarquiv => vr_nmarqdat,         --> Nome do arquivo
                               pr_tipabert => 'W',                 --> Modo de abertura (R,W,A)
                               pr_utlfileh => vr_arquivo_txt,      --> Handle do arquivo aberto
                               pr_des_erro => vr_dscritic);

      if vr_dscritic is not null then
        vr_cdcritic := 0;
        RAISE vr_exc_erro;
      end if;

      --Busca todas as cooperativas ativas
      FOR rw_crapcop IN cr_crapcop LOOP
        --Busca IOF quebrando em PF/PJ
        FOR rw_iof IN cr_iof(rw_crapcop.cdcooper, vr_dtini, vr_dtfim) LOOP
          /* Escrita arquivo */
          vr_linhadet := '01'; --Tipo Registo
          vr_linhadet := vr_linhadet || rpad('IOF',10,' '); --Imposto
          vr_linhadet := vr_linhadet || rpad(' ',4,' '); --ID Retencao
          vr_linhadet := vr_linhadet || rpad(CASE rw_iof.inpessoa WHEN 1 THEN '7893' ELSE '1150' END,10,' '); --Cod Retencao
          vr_linhadet := vr_linhadet || to_char(vr_dtrecolh,'DDMMRRRR'); --Data Recolhimento
          vr_linhadet := vr_linhadet || rpad(' ',7,' '); --ID Empresa
          vr_linhadet := vr_linhadet || rpad(substr(rw_crapcop.nmcooper,1,20),20,' '); --Apelido Empresa
          vr_linhadet := vr_linhadet || rpad(lpad(rw_crapcop.nrdocnpj,14,'0'),15,' '); --CNPJ Empresa
          vr_linhadet := vr_linhadet || to_char(btch0001.rw_crapdat.dtmvtoan,'DDMMRRRR'); --Data Fato Gerador
          vr_linhadet := vr_linhadet || rpad(' ',1,' '); --Ind Dec Terc        
          vr_linhadet := vr_linhadet || to_char(btch0001.rw_crapdat.dtmvtoan,'DDMMRRRR'); --Data Apuracao
          vr_linhadet := vr_linhadet || rpad(' ',37,' '); --Filler

          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          
          vr_linhadet := '02'; --Tipo Registo
          vr_linhadet := vr_linhadet || rpad(' ',7,' '); --ID Filial
          vr_linhadet := vr_linhadet || rpad(substr(rw_crapcop.nmcooper,1,20),20,' '); --Apelido Filial
          vr_linhadet := vr_linhadet || rpad(lpad(rw_crapcop.nrdocnpj,14,'0'),15,' '); --CNPJ Filial
          vr_linhadet := vr_linhadet || rpad(' ',7,' '); --ID Fornecedor
          vr_linhadet := vr_linhadet || rpad(substr(rw_crapcop.nmcooper,1,20),20,' '); --Apelido Fornecedor
          vr_linhadet := vr_linhadet || rpad(lpad(rw_crapcop.nrdocnpj,14,'0'),15,' '); --CNPJ Fornecedor
          vr_linhadet := vr_linhadet || rpad(' ',20,' '); --Cod Projeto
          vr_linhadet := vr_linhadet || rpad(' ',6,' '); --Id Centro Custo
          vr_linhadet := vr_linhadet || rpad(' ',20,' '); --Cod Custo
          vr_linhadet := vr_linhadet || rpad('4532',15,' '); --Cod Conta
          vr_linhadet := vr_linhadet || rpad(rw_iof.vliof * 100,15,' '); --Valor Imposto
          vr_linhadet := vr_linhadet || rpad(rw_iof.vliof * 1000,15,' '); --Valor Tributavel
          vr_linhadet := vr_linhadet || rpad(' ',15,' '); --Vlr Deducao
          vr_linhadet := vr_linhadet || rpad(' ',15,' '); --Vlr Deducao
          vr_linhadet := vr_linhadet || rpad(to_char(btch0001.rw_crapdat.dtmvtoan,'DDMMRRRR'),20,' '); --Nr Doc
          vr_linhadet := vr_linhadet || rpad(substr(rw_crapcop.nmrescop,1,10),10,' '); --Apelido Fornecedor
          vr_linhadet := vr_linhadet || to_char(btch0001.rw_crapdat.dtmvtoan,'DDMMRRRR'); --Data Fato Gerador
          vr_linhadet := vr_linhadet || rpad(' ',72,' '); --Filler

          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        END LOOP;

        --Busca IRRF quebrando em PF/PJ
        FOR rw_irrf IN cr_irrf(rw_crapcop.cdcooper, vr_dtini) LOOP
          /* Escrita arquivo */
          vr_linhadet := '01'; --Tipo Registo
          vr_linhadet := vr_linhadet || rpad('IRRFAF',10,' '); --Imposto
          vr_linhadet := vr_linhadet || rpad(' ',4,' '); --ID Retencao
          vr_linhadet := vr_linhadet || rpad(CASE rw_irrf.inpessoa WHEN 1 THEN '8053' ELSE '3426' END,10,' '); --Cod Retencao
          vr_linhadet := vr_linhadet || to_char(vr_dtrecolh,'DDMMRRRR'); --Data Recolhimento
          vr_linhadet := vr_linhadet || rpad(' ',7,' '); --ID Empresa
          vr_linhadet := vr_linhadet || rpad(substr(rw_crapcop.nmcooper,1,20),20,' '); --Apelido Empresa
          vr_linhadet := vr_linhadet || rpad(lpad(rw_crapcop.nrdocnpj,14,'0'),15,' '); --CNPJ Empresa
          vr_linhadet := vr_linhadet || to_char(btch0001.rw_crapdat.dtmvtoan,'DDMMRRRR'); --Data Fato Gerador
          vr_linhadet := vr_linhadet || rpad(' ',1,' '); --Ind Dec Terc        
          vr_linhadet := vr_linhadet || to_char(btch0001.rw_crapdat.dtmvtoan,'DDMMRRRR'); --Data Apuracao
          vr_linhadet := vr_linhadet || rpad(' ',37,' '); --Filler

          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          
          vr_linhadet := '02'; --Tipo Registo
          vr_linhadet := vr_linhadet || rpad(' ',7,' '); --ID Filial
          vr_linhadet := vr_linhadet || rpad(substr(rw_crapcop.nmcooper,1,20),20,' '); --Apelido Filial
          vr_linhadet := vr_linhadet || rpad(lpad(rw_crapcop.nrdocnpj,14,'0'),15,' '); --CNPJ Filial
          vr_linhadet := vr_linhadet || rpad(' ',7,' '); --ID Fornecedor
          vr_linhadet := vr_linhadet || rpad(substr(rw_crapcop.nmcooper,1,20),20,' '); --Apelido Fornecedor
          vr_linhadet := vr_linhadet || rpad(lpad(rw_crapcop.nrdocnpj,14,'0'),15,' '); --CNPJ Fornecedor
          vr_linhadet := vr_linhadet || rpad(' ',20,' '); --Cod Projeto
          vr_linhadet := vr_linhadet || rpad(' ',6,' '); --Id Centro Custo
          vr_linhadet := vr_linhadet || rpad(' ',20,' '); --Cod Custo
          vr_linhadet := vr_linhadet || rpad('4816',15,' '); --Cod Conta
          vr_linhadet := vr_linhadet || rpad(rw_irrf.vlapagar * 100,15,' '); --Valor Imposto
          vr_linhadet := vr_linhadet || rpad(rw_irrf.vlapagar * 1000,15,' '); --Valor Tributavel
          vr_linhadet := vr_linhadet || rpad(' ',15,' '); --Vlr Deducao
          vr_linhadet := vr_linhadet || rpad(' ',15,' '); --Vlr Deducao
          vr_linhadet := vr_linhadet || rpad(to_char(btch0001.rw_crapdat.dtmvtoan,'DDMMRRRR'),20,' '); --Nr Doc
          vr_linhadet := vr_linhadet || rpad(substr(rw_crapcop.nmrescop,1,10),10,' '); --Apelido Fornecedor
          vr_linhadet := vr_linhadet || to_char(btch0001.rw_crapdat.dtmvtoan,'DDMMRRRR'); --Data Fato Gerador
          vr_linhadet := vr_linhadet || rpad(' ',72,' '); --Filler

          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        END LOOP;
      END LOOP;

      gene0001.pc_fecha_arquivo(vr_arquivo_txt);

      COMMIT;

      vr_nmarqnov := vr_dtmvtolt_yymmdd||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_IRRF_IOF.txt';                        

      -- Copia o arquivo gerado para o diretório final convertendo para DOS
      gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqdat||' > '||vr_dsdircop||'/'||vr_nmarqnov||' 2>/dev/null',
                                  pr_typ_saida   => vr_typ_said,
                                  pr_des_saida   => vr_dscritic);

      -- Testar erro
      if vr_typ_said = 'ERR' then
         vr_cdcritic := 1040;
         gene0001.pc_print(gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_nmarqdat||': '||vr_dscritic);
      end if;
    END IF;
  EXCEPTION
   WHEN vr_exc_erro THEN
     pr_cdcritic := vr_cdcritic;
     pr_dscritic := vr_dscritic;
   WHEN OTHERS THEN
     pr_cdcritic := 0;
     pr_dscritic := 'Erro na rotina CONV0001.pc_relat_repasse_dpvat. ' || SQLERRM;
  END;

  PROCEDURE pc_gera_segregacao_prejuizo(pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE) IS 
    CURSOR cr_crapcop IS
      SELECT c.cdcooper
        FROM crapcop c
       WHERE c.flgativo = 1
         AND c.cdcooper <> pr_cdcooper;

    CURSOR cr_crapvri(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_dtrefere IN DATE) IS
      SELECT vri.cdvencto
           , SUM(vri.vldivida) vlprejuz
        FROM crapvri vri
       WHERE vri.cdcooper = pr_cdcooper
         AND vri.dtrefere = pr_dtrefere
         AND vri.cdvencto IN (320, 330)
       GROUP
          BY vri.cdvencto
       ORDER
          BY vri.cdvencto;

    -- Data do movimento no formato yymmdd
    vr_dtmvtolt_yymmdd     varchar2(6);
        
    -- Nome do diretório
    vr_nom_diretorio       varchar2(200);
    vr_dsdircop            varchar2(200);

    -- Nome do arquivo que será gerado
    vr_nmarqnov            VARCHAR2(50); -- nome do arquivo por cooperativa
    vr_nmarqdat            varchar2(50);

    -- Arquivo texto
    vr_arquivo_txt         utl_file.file_type;
    vr_linhadet            varchar2(200);

    -- Tratamento de erros
    vr_typ_said            VARCHAR2(4);

    -- Variaveis de Excecao
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;

  BEGIN
    --Utilizar as datas da CENTRAL
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    --Executar apenas no primeiro dia util do mes
    IF TO_CHAR(btch0001.rw_crapdat.dtmvtoan, 'MM') <> TO_CHAR(btch0001.rw_crapdat.dtmvtolt, 'MM') THEN
      FOR rw_crapcop IN cr_crapcop LOOP
        /* Prj421 - Geracao de arquivo contabil */
        -- Busca do diretório onde ficará o arquivo
        vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                                  pr_cdcooper => rw_crapcop.cdcooper,
                                                  pr_nmsubdir => 'contab');
                                                  
        -- Busca o diretório final para copiar arquivos
        vr_dsdircop := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdcooper => 0
                                                ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');                                              
        -- Nome do arquivo a ser gerado
        vr_dtmvtolt_yymmdd := to_char(btch0001.rw_crapdat.dtmvtoan, 'yymmdd');
        vr_nmarqdat        := vr_dtmvtolt_yymmdd||'_SEGREGACAO_PREJUIZO.txt';

        -- Abre o arquivo para escrita
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio,    --> Diretório do arquivo
                                 pr_nmarquiv => vr_nmarqdat,         --> Nome do arquivo
                                 pr_tipabert => 'W',                 --> Modo de abertura (R,W,A)
                                 pr_utlfileh => vr_arquivo_txt,      --> Handle do arquivo aberto
                                 pr_des_erro => vr_dscritic);

        if vr_dscritic is not null then
          vr_cdcritic := 0;
          RAISE vr_exc_erro;
        end if;

        --Buscar os lancamentos de risco para contabilizar o valor de prejuizo
        FOR rw_crapvri IN cr_crapvri(rw_crapcop.cdcooper,btch0001.rw_crapdat.dtultdma) LOOP
          --Maior que 12 meses
          IF rw_crapvri.cdvencto = 320 THEN
            /* Escrita arquivo */
            --Ajuste contabil
            vr_linhadet := trim(vr_dtmvtolt_yymmdd)||','||
                           trim(to_char(btch0001.rw_crapdat.dtmvtoan,'ddmmyy'))||','||
                           '9261,'||
                           '9263,'||
                           trim(to_char(rw_crapvri.vlprejuz, '99999999999990.00'))||','||
                           '5210,'||
                           '"VALOR REF. SALDO DE EMPRESTIMOS/FINANCIAMENTOS E SALDO DEVEDOR DE C/C LANCADOS PARA PREJUIZO A MAIS DE 12 MESES"';

            gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            
            --Reversao ajuste contabil
            vr_linhadet := trim(to_char(btch0001.rw_crapdat.dtmvtolt,'yymmdd'))||','||
                           trim(to_char(btch0001.rw_crapdat.dtmvtolt,'ddmmyy'))||','||
                           '9263,'||
                           '9261,'||
                           trim(to_char(rw_crapvri.vlprejuz, '99999999999990.00'))||','||
                           '5210,'||
                           '"VALOR REF. REVERSAO DE SALDO DE EMPRESTIMOS/FINANCIAMENTOS E SALDO DEVEDOR DE C/C LANCADOS PARA PREJUIZO A MAIS DE 12 MESES"';

            gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            /* Fim escrita arquivo */
          ELSE --330 - Maior que 48 meses
            /* Escrita arquivo */
            --Ajuste contabil
            vr_linhadet := trim(vr_dtmvtolt_yymmdd)||','||
                           trim(to_char(btch0001.rw_crapdat.dtmvtoan,'ddmmyy'))||','||
                           '9261,'||
                           '9262,'||
                           trim(to_char(rw_crapvri.vlprejuz, '99999999999990.00'))||','||
                           '5210,'||
                           '"VALOR REF. SALDO DE EMPRESTIMOS/FINANCIAMENTOS E SALDO DEVEDOR DE C/C LANCADOS PARA PREJUIZO A MAIS DE 48 MESES"';

            gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            
            --Reversao ajuste contabil
            vr_linhadet := trim(to_char(btch0001.rw_crapdat.dtmvtolt,'yymmdd'))||','||
                           trim(to_char(btch0001.rw_crapdat.dtmvtolt,'ddmmyy'))||','||
                           '9262,'||
                           '9261,'||
                           trim(to_char(rw_crapvri.vlprejuz, '99999999999990.00'))||','||
                           '5210,'||
                           '"VALOR REF. REVERSAO DE SALDO DE EMPRESTIMOS/FINANCIAMENTOS E SALDO DEVEDOR DE C/C LANCADOS PARA PREJUIZO A MAIS DE 48 MESES"';

            gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
            /* Fim escrita arquivo */
          END IF;
        END LOOP;
        
        gene0001.pc_fecha_arquivo(vr_arquivo_txt);

        vr_nmarqnov := vr_dtmvtolt_yymmdd||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_SEGREGACAO_PREJUIZO.txt';                        

        -- Copia o arquivo gerado para o diretório final convertendo para DOS
        gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqdat||' > '||vr_dsdircop||'/'||vr_nmarqnov||' 2>/dev/null',
                                    pr_typ_saida   => vr_typ_said,
                                    pr_des_saida   => vr_dscritic);
        -- Testar erro
        if vr_typ_said = 'ERR' then
           vr_cdcritic := 1040;
           gene0001.pc_print(gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_nmarqdat||': '||vr_dscritic);
        end if;

        COMMIT;
      END LOOP;
    END IF;
  EXCEPTION
   WHEN vr_exc_erro THEN
     pr_cdcritic := vr_cdcritic;
     pr_dscritic := vr_dscritic;
   WHEN OTHERS THEN
     pr_cdcritic := 0;
     pr_dscritic := 'Erro na rotina CONV0001.pc_relat_repasse_dpvat. ' || SQLERRM;
  END;
  
  --Procedure para processamento dos ajustes/arquivos do projeto 421 - Melhorias nas ferramentas contabeis e fiscais
  PROCEDURE pc_processa_contabil IS
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    vr_cdcooper INTEGER := 3;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_dserro   VARCHAR2(4000);
    vr_exc_erro EXCEPTION;

    vr_cdprogra    VARCHAR2(40) := 'CONT0002.PC_PROCESSA_CONTABIL';
    vr_nomdojob    VARCHAR2(40) := 'JBCONTAB_PROCESSA_CONTABIL';

    vr_intipmsg INTEGER := 1;
    vr_dscrioco VARCHAR2(4000);
    vr_diautil  BOOLEAN;

    --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
    PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2 DEFAULT 'E' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                                   ,pr_tpocorre IN NUMBER   DEFAULT 2   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                   ,pr_cdcricid IN NUMBER   DEFAULT 2   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                                   ,pr_tpexecuc IN NUMBER   DEFAULT 2   -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                                   ,pr_dscritic IN VARCHAR2 DEFAULT NULL
                                   ,pr_cdcritic IN VARCHAR2 DEFAULT NULL
                                   ,pr_cdcooper IN VARCHAR2 DEFAULT 3
                                   ,pr_flgsuces IN NUMBER   DEFAULT 1    -- Indicador de sucesso da execução  
                                   ,pr_flabrchd IN INTEGER  DEFAULT 0    -- Abre chamado 1 Sim/ 0 Não
                                   ,pr_textochd IN VARCHAR2 DEFAULT NULL -- Texto do chamado
                                   ,pr_desemail IN VARCHAR2 DEFAULT NULL -- Destinatario do email
                                   ,pr_flreinci IN INTEGER  DEFAULT 0    -- Erro pode reincidir no prog em dias diferentes, devendo abrir chamado
    ) 
    IS
      vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;        
    BEGIN   
      -- Controlar geração de log de execução dos jobs
      CECRED.pc_log_programa(pr_dstiplog           => pr_dstiplog -- I-início/ F-fim/ O-ocorrência/ E-erro 
                            ,pr_tpocorrencia       => pr_tpocorre -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                            ,pr_cdcriticidade      => pr_cdcricid -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                            ,pr_tpexecucao         => pr_tpexecuc -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                            ,pr_dsmensagem         => pr_dscritic
                            ,pr_cdmensagem         => pr_cdcritic
                            ,pr_cdcooper           => pr_cdcooper 
                            ,pr_flgsucesso         => pr_flgsuces
                            ,pr_flabrechamado      => pr_flabrchd -- Abre chamado 1 Sim/ 0 Não
                            ,pr_texto_chamado      => pr_textochd
                            ,pr_destinatario_email => pr_desemail
                            ,pr_flreincidente      => pr_flreinci
                            ,pr_cdprograma         => vr_nomdojob
                            ,pr_idprglog           => vr_idprglog);   
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log  
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
    END pc_controla_log_batch;
  BEGIN
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
    
    -- Log de inicio de execucao
    pc_controla_log_batch(pr_dstiplog => 'I');
    
    --Verifica se o JOB pode rodar
    --Sabado e Domingo nao deve validar o processo batch, pois o INPROCES da CECRED vai estar como 2 o final de semana inteiro
    IF to_char(SYSDATE,'D') NOT IN ('7','1') THEN
    gene0004.pc_trata_exec_job(pr_cdcooper => vr_cdcooper      --> Codigo da cooperativa
                              ,pr_fldiautl => 0                --> Podem ser recebidos arquivos em dias nao uteis com movimentos de dias uteis
                              ,pr_flproces => 1                --> Flag se deve validar se esta no processo
                              ,pr_flrepjob => 1                --> Flag para reprogramar o job
                              ,pr_flgerlog => 0                --> indicador se deve gerar log
                              ,pr_nmprogra => vr_cdprogra      --> Nome do programa que esta sendo executado no job
                              ,pr_intipmsg => vr_intipmsg
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dserro);
    END IF;

    -- se nao retornou critica chama rotina
    IF trim(vr_dserro) IS NULL THEN 
      IF trunc(SYSDATE) = gene0005.fn_valida_dia_util(pr_cdcooper => 3
                                                    , pr_dtmvtolt => TRUNC(SYSDATE)
                                                    , pr_tipo => 'P') THEN
        vr_diautil := TRUE;
      ELSE
        vr_diautil := FALSE;
      END IF;

      -- Retorna nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
        
      OPEN btch0001.cr_crapdat(vr_cdcooper);
      FETCH btch0001.cr_crapdat  INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;
      
      pc_processa_arquivo_bancoob(pr_cdcooper => vr_cdcooper
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);

      IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
        pc_controla_log_batch(pr_dscritic => vr_dscritic
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_flgsuces => 0           -- Indicador de sucesso da execução
                             );
      END IF;

      IF vr_diautil THEN
      pc_gera_segregacao_prejuizo(pr_cdcooper => vr_cdcooper
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);

      IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
        pc_controla_log_batch(pr_dscritic => vr_dscritic
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_flgsuces => 0           -- Indicador de sucesso da execução
                             );
      END IF;

        pc_processa_arquivo_abbc(pr_cdcooper => vr_cdcooper
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);

        IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
          pc_controla_log_batch(pr_dscritic => vr_dscritic
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_flgsuces => 0           -- Indicador de sucesso da execução
                               );
        END IF;
        
        pc_processa_lanc_slip(pr_cdcooper => vr_cdcooper
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);

        IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
          pc_controla_log_batch(pr_dscritic => vr_dscritic
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_flgsuces => 0           -- Indicador de sucesso da execução
                               );
        END IF;
        
        pc_gera_iof_irrf_decendial(pr_cdcooper => vr_cdcooper
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);

        IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
          pc_controla_log_batch(pr_dscritic => vr_dscritic
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_flgsuces => 0           -- Indicador de sucesso da execução
                               );
        END IF;
      END IF;

      -- Retorna nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);  

    ELSE
      -- Processo noturno nao finalizado para cooperativa - Não gera critica
      IF NVL(vr_intipmsg,1) = 1 THEN
        vr_dscritic := vr_dserro;

        --Incluída gravação de log aqui para evitar duplicidade na situação de retorno de crps652
        --Log de erro de execucao
        pc_controla_log_batch(pr_cdcritic => nvl(vr_cdcritic,0)
                             ,pr_dscritic => vr_dscritic);
        RAISE vr_exc_erro;
      ELSE
        vr_cdcritic := NVL(vr_cdcritic,0);
        -- Buscar a descrição - Se foi retornado apenas código
        vr_dscrioco := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic) ||
                       ' '  || vr_cdprogra;

        -- Log de erro de execucao
        pc_controla_log_batch(pr_dstiplog => 'O'
                             ,pr_tpocorre => 4
                             ,pr_cdcricid => 0
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscrioco);
      END IF;
    END IF;

    -- Log de fim de execucao
    pc_controla_log_batch(pr_dstiplog => 'F');

    -- Retorna nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
  EXCEPTION
    WHEN vr_exc_erro THEN  
      ROLLBACK;
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper, 
                                   pr_compleme => vr_dscritic);
      -- Monta mensagens
      vr_cdcritic := 9999; -- 9999 -  Erro nao tratado: 
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                     vr_cdprogra ||
                     '. ' || SQLERRM;

      -- Log de erro de execucao
      pc_controla_log_batch(pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);

      ROLLBACK;                             
  END;

  PROCEDURE pc_processa_arquivo_abbc(pr_cdcooper IN crapcop.cdcooper%TYPE
                                    ,pr_cdcritic OUT NUMBER                --> Desc. da crítica
                                    ,pr_dscritic OUT VARCHAR2) is

    -- cursor para pegar codigo da cooperativa
    CURSOR cr_crapcop IS 
     SELECT cdcooper,cdagectl  FROM crapcop;                                 
   
    -- exceptions
    vr_exc_saida EXCEPTION;
                                   
    vr_nom_diretorio       varchar2(200);
    vr_dsdircop            varchar2(200);
    -- Nome do arquivo que será gerado
    vr_nmarqnov            VARCHAR2(50); -- nome do arquivo por cooperativa
    vr_nmarqdat            varchar2(50);
    vr_nomedarq            VARCHAR2(50);
    vr_nmdircop VARCHAR(200) := NULL; 
    vr_dtmvtolt_yymmdd     VARCHAR2(8);
    
    -- Arquivo texto
    vr_arquivo_txt         utl_file.file_type;
    vr_farquivo         utl_file.file_type;  

    vr_lerlinha PLS_INTEGER;
    
    vr_dslisarq            VARCHAR2(4000); 
    vr_linhadet            varchar2(200);
    vr_setlinha            VARCHAR2(300);
    vr_tab_nmarqtel gene0002.typ_split;  -- tabela com os arquivos listados
    vr_tab_coop typ_tab_coop;
    vr_dscritic VARCHAR2(4000);  
    vr_cdcritic NUMBER; 
    vr_typ_said VARCHAR2(4);
    
    vr_tab_regarqvo typ_tab_arquiv_abbc; -- tabela com os dados retirados do arquivo
    vr_idx_regarqvo VARCHAR2(50);
    
    vr_tab_cdcooper typ_tab_cdcooper;
    vr_idx_cdcooper PLS_INTEGER;
    
    -- variaveis dos campos do arquivo
    vr_dtconcil DATE := NULL;
    vr_nrcheque crapfdc.nrcheque%TYPE;
    vr_vlcheque crapfdc.vlcheque%TYPE;
    vr_cdageori crapfdc.cdagechq%TYPE;
    vr_nrctadep crapfdc.nrctadep%TYPE;
    vr_tpdearqv VARCHAR2(2);
    vr_cdcooper crapcop.cdcooper%TYPE;
  BEGIN


    BEGIN 
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      --carregar as cooperativas
      vr_tab_cdcooper.DELETE;
      vr_tab_coop.delete;
      
      FOR rw_crapcop IN cr_crapcop LOOP
        vr_tab_cdcooper(rw_crapcop.cdagectl) := rw_crapcop.cdcooper;
      END LOOP;
                       
      vr_tab_regarqvo.delete;
                       
      FOR i IN 1..2 LOOP -- loop para os dois tipos de arquivos SF e SL
        
        IF i = 1 THEN -- primeiro o SF      
          vr_nomedarq := 'DTSF'||to_char(btch0001.rw_crapdat.dtmvtoan,'dd') || to_char(btch0001.rw_crapdat.dtmvtoan,'mm')||'%.TXT';
        ELSE -- depois SL
          vr_nomedarq := 'DTSL'||to_char(btch0001.rw_crapdat.dtmvtoan,'dd') || to_char(btch0001.rw_crapdat.dtmvtoan,'mm')||'%.TXT';
        END IF; 
        
        -- diretorio dos arquivos para serem listados                   
         vr_nmdircop := gene0001.fn_diretorio(pr_tpdireto => 'M'
                                            ,pr_cdcooper => 3
                                            ,pr_nmsubdir => 'contab'); 
        
        gene0001.pc_lista_arquivos(pr_path     => vr_nmdircop
                                  ,pr_pesq     => vr_nomedarq
                                  ,pr_listarq  => vr_dslisarq
                                  ,pr_des_erro => vr_dscritic);

        vr_tab_nmarqtel := gene0002.fn_quebra_string(vr_dslisarq);
        
        -- ler arquivos encontrados
        FOR idx IN 1..vr_tab_nmarqtel.count() LOOP
            vr_dtconcil := NULL;
            
            
            gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdircop  --> Diretorio do arquivo
                                    ,pr_nmarquiv => vr_tab_nmarqtel(idx) --> Nome do arquivo
                                    ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                                    ,pr_utlfileh => vr_farquivo  --> Handle do arquivo aberto
                                    ,pr_des_erro => vr_dscritic);  --> Erro
                                    
              
            IF vr_dscritic IS NOT NULL THEN
               vr_cdcritic := 0;
               vr_dscritic := vr_dscritic; 
               RAISE vr_exc_saida ;            
            END IF;
            
            LOOP
              
              BEGIN
                gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_farquivo --> Handle do arquivo aberto
                                               ,pr_des_text => vr_setlinha); --> Texto lido
                                               
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  --Chegou ao final arquivo, sair do loop
                  EXIT;
                WHEN OTHERS THEN
                  vr_cdcritic := 0;
                  vr_dscritic:= 'Erro na leitura do arquivo.';
                  RAISE vr_exc_saida;
              END;
              
                             
              -- para pegar a data ignorar até encontrar a linha que começa com Conciliacao
              IF upper(TRIM(substr(vr_setlinha,1,12))) = upper('Conciliacao') AND (vr_dtconcil IS NULL) THEN                                       
                vr_dtconcil := to_date(TRIM(SUBSTR(vr_setlinha,30,10)),'DD/MM/YYYY');
              END IF;
                                  
              
              vr_lerlinha := 0;
              
              FOR rw_crapcop IN cr_crapcop LOOP
                IF lpad(rw_crapcop.cdagectl,4,0) = nvl(TRIM(SUBSTR(vr_setlinha,83,4)),' ') THEN
                   vr_lerlinha := 1; 
                   EXIT;                    
                END IF;
              END LOOP;
              
              IF nvl(vr_lerlinha,0) = 0 THEN
                continue;
              END IF;          
                
                vr_cdageori := to_number(TRIM(SUBSTR(vr_setlinha,83,4)));
                vr_nrcheque := to_number(TRIM(SUBSTR(vr_setlinha,38,6)));
                vr_vlcheque := to_number(TRIM(REPLACE(SUBSTR(vr_setlinha,49,23),'.','') )); 
                vr_nrctadep := to_number(TRIM(SUBSTR(vr_setlinha,89,12))); 
                
                IF i = 1 THEN 
                  vr_tpdearqv := 'SF';
                ELSE 
                  vr_tpdearqv := 'SL';
                END IF;
              
              
              -- montar indice para a tabela dos registros encontrados no arquivo
              vr_idx_regarqvo := lpad(to_char(vr_cdageori),4,0) ||
                                 lpad(to_char(vr_nrcheque),6,0) ||
                                 lpad(to_char(vr_nrctadep),12,0);

              IF NOT vr_tab_regarqvo.exists(vr_idx_regarqvo) THEN                   
                                 
                 vr_tab_regarqvo(vr_idx_regarqvo).cdageori := vr_cdageori;               
                 vr_tab_regarqvo(vr_idx_regarqvo).nrcheque := vr_nrcheque;
                 vr_tab_regarqvo(vr_idx_regarqvo).vlcheque := vr_vlcheque;
                 vr_tab_regarqvo(vr_idx_regarqvo).nrctadep := vr_nrctadep;  
                 vr_tab_regarqvo(vr_idx_regarqvo).tpdearqv := vr_tpdearqv;                               
              END IF;
                                                              
              vr_idx_cdcooper := vr_tab_cdcooper(vr_cdageori);
             
              -- seriva para gerar arquivo apenas para as cooperativas que tenham sido importadas nos arquivos SL e SF
              IF NOT vr_tab_coop.exists(vr_idx_cdcooper) THEN 
                  vr_tab_coop(vr_idx_cdcooper) := vr_idx_cdcooper;
                 END IF;
           END LOOP;           
        END LOOP; -- loop arquivo
      END LOOP; -- fim loop tipo arquivo
                  
                          
      -- gerar arquivo por cooperativa SL e SF
      vr_idx_cdcooper := vr_tab_coop.first;
               
      WHILE vr_idx_cdcooper IS NOT NULL LOOP

               -- gerar arquivo contabil
               vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                                   pr_cdcooper => vr_tab_coop(vr_idx_cdcooper),
                                                         pr_nmsubdir => 'contab');
              
               -- Busca o diretório final para copiar arquivos
               vr_dsdircop := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                       ,pr_cdcooper => 0
                                                       ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');
               -- Nome do arquivo a ser gerado
               vr_dtmvtolt_yymmdd := to_char(vr_dtconcil, 'yyyymmdd');
         vr_nmarqdat        := vr_dtmvtolt_yymmdd||'_'|| LPAD(TO_CHAR(vr_tab_coop(vr_idx_cdcooper)),2,0) || '_SF_SL.txt';
                   
               -- Abre o arquivo para escrita
               gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio,    --> Diretório do arquivo
                                        pr_nmarquiv => vr_nmarqdat,         --> Nome do arquivo
                                        pr_tipabert => 'W',                 --> Modo de abertura (R,W,A)
                                        pr_utlfileh => vr_arquivo_txt,      --> Handle do arquivo aberto
                                        pr_des_erro => vr_dscritic); 
                                                     
         
         vr_idx_regarqvo := vr_tab_regarqvo.first;    
         
         WHILE vr_idx_regarqvo IS NOT NULL LOOP                        
           vr_cdcooper := vr_tab_cdcooper(vr_tab_regarqvo(vr_idx_regarqvo).cdageori); 
             
           IF vr_cdcooper <> vr_tab_coop(vr_idx_cdcooper) THEN
              vr_idx_regarqvo := vr_tab_regarqvo.next(vr_idx_regarqvo);
              continue;
             END IF;
                                         
             -- gerar lançamentos
             IF vr_tab_regarqvo(vr_idx_regarqvo).tpdearqv = 'SL' THEN 
               IF vr_tab_regarqvo(vr_idx_regarqvo).vlcheque > 0 THEN
                 /* Escrita arquivo */
                 vr_linhadet := TRIM(vr_dtmvtolt_yymmdd)||','||
                             trim(to_char(vr_dtconcil,'ddmmyy'))||','||
                             '1894,'||
                             '1455,'||
                             trim(to_char(vr_tab_regarqvo(vr_idx_regarqvo).vlcheque,'999999999999.00'))||','|| --valor deve ir positivo para o arquivo
                             '5210,'||
                             '"VLR. REF. NR CHEQUE Nº ' || LPAD(TO_CHAR(vr_tab_regarqvo(vr_idx_regarqvo).nrcheque),6,0) || ' DA C/C '
                                                        || gene0002.fn_mask_conta(vr_tab_regarqvo(vr_idx_regarqvo).nrctadep) 
                                                        || ' CRITICADO REL. SL ABBC - A REGULARIZAR"';

                 gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
                 /* Fim escrita arquivo */ 
               END IF;  
             ELSE
               IF vr_tab_regarqvo(vr_idx_regarqvo).vlcheque > 0 THEN
                 /* Escrita arquivo */
                 vr_linhadet := TRIM(vr_dtmvtolt_yymmdd)||','||
                             trim(to_char(vr_dtconcil,'ddmmyy'))||','||
                             '1455,'||
                             '1894,'||
                             trim(to_char(vr_tab_regarqvo(vr_idx_regarqvo).vlcheque,'999999999999.00'))||','|| --valor deve ir positivo para o arquivo
                             '5210,'||
                             '"VLR. REF. NR CHEQUE Nº ' || LPAD(TO_CHAR(vr_tab_regarqvo(vr_idx_regarqvo).nrcheque),6,0) || ' DA C/C '
                                                        || gene0002.fn_mask_conta(vr_tab_regarqvo(vr_idx_regarqvo).nrctadep) 
                                                        || ' CRITICADO REL. SF ABBC - REGULARIZADO NESTA DATA"';

                 gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
                 /* Fim escrita arquivo */ 
               END IF; 
             
             END IF; 
            
            vr_idx_regarqvo := vr_tab_regarqvo.next(vr_idx_regarqvo);
          
         END LOOP;
         
       
         -- fechar e mover depois aqui
         gene0001.pc_fecha_arquivo(vr_arquivo_txt);
                                  
         vr_nmarqnov := vr_dtmvtolt_yymmdd||'_'||LPAD(TO_CHAR(vr_tab_coop(vr_idx_cdcooper)),2,0)||'_SF_SL.txt';                       
          
         -- Copia o arquivo gerado para o diretório final convertendo para DOS
         gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqdat||' > '||vr_dsdircop||'/'||vr_nmarqnov||' 2>/dev/null',
                                      pr_typ_saida   => vr_typ_said,
                                      pr_des_saida   => vr_dscritic);
                  
         -- Testar erro
         if vr_typ_said = 'ERR' THEN
            vr_cdcritic := 1040;
            gene0001.pc_print(gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_nmarqdat||': '||vr_dscritic);
         END IF;
         
         vr_idx_cdcooper :=  vr_tab_coop.next(vr_idx_cdcooper);
         
         COMMIT;
                                                                                      
        
       END LOOP;                                                                                                                     
    EXCEPTION          
      WHEN vr_exc_saida THEN 
        pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := vr_dscritic || Sqlerrm;

      WHEN OTHERS THEN 
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral na rotina.' || SQLERRM; 
        
    END;
  END pc_processa_arquivo_abbc;


  PROCEDURE pc_processa_lanc_slip(pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ,pr_cdcritic OUT NUMBER                --> Desc. da crítica
                                 ,pr_dscritic OUT VARCHAR2) is

    -- cursor para pegar codigo da cooperativa
    CURSOR cr_crapcop IS 
     SELECT cdcooper,cdagectl  FROM crapcop;                                 
    
    CURSOR cr_lancamentos (pr_cdcooper IN crapcop.cdcooper%TYPE,
                           pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS 
     SELECT lan.cdcooper,
        lan.dtmvtolt,
        lan.nrsequencia_slip,
        lan.nrctadeb,
        lan.nrctacrd,
        lan.vllanmto,
        lan.cdhistor_padrao,
        lan.dslancamento,
        lan.cdoperad FROM tbcontab_slip_lancamento lan 
     WHERE lan.cdcooper = pr_cdcooper
      AND  lan.dtmvtolt = pr_dtmvtolt;
      
    CURSOR cr_rateio (pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_nseqslip IN tbcontab_slip_rateio.nrsequencia_slip%TYPE,
                      pr_dtmvtolt IN tbcontab_slip_rateio.dtmvtolt%TYPE) IS 
     SELECT rat.cdgerencial,rat.vllanmto FROM tbcontab_slip_rateio rat
      WHERE rat.cdcooper = pr_cdcooper
       AND  rat.dtmvtolt = pr_dtmvtolt
       AND  rat.nrsequencia_slip = pr_nseqslip;
       
    -- exceptions
    vr_exc_saida EXCEPTION;
                                   
    vr_nom_diretorio       varchar2(200);
    vr_dsdircop            varchar2(200);
    -- Nome do arquivo que será gerado
    vr_nmarqnov            VARCHAR2(50); -- nome do arquivo por cooperativa
    vr_nmarqdat            varchar2(50);
    vr_dtmvtolt_yymmdd     VARCHAR2(8);
    
    -- Arquivo texto
    vr_arquivo_txt         utl_file.file_type;
    
    vr_linhadet            varchar2(200);
    vr_tab_coop typ_tab_coop;
    vr_dscritic VARCHAR2(4000);  
    vr_cdcritic NUMBER; 
    vr_typ_said VARCHAR2(4);
    
    vr_tab_cdcooper typ_tab_cdcooper;
    vr_flgarq PLS_INTEGER;
    -- variaveis dos campos do arquivo

    vr_dtmvtoan DATE;
  BEGIN

    BEGIN 
      --carregar as cooperativas
      vr_tab_cdcooper.DELETE;
      vr_tab_coop.delete;
      
      --Utilizar as datas da CENTRAL
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
      CLOSE btch0001.cr_crapdat;
      
      vr_dtmvtoan := btch0001.rw_crapdat.dtmvtoan;
      
      FOR rw_crapcop IN cr_crapcop LOOP
        vr_flgarq := 1;  -- criar arquivo        
        FOR rw_lancamentos IN cr_lancamentos(pr_cdcooper => rw_crapcop.cdcooper,
                                             pr_dtmvtolt => vr_dtmvtoan) LOOP
          
           IF  vr_flgarq = 1 THEN
               vr_flgarq:= 0;              
         
                    -- gerar arquivo contabil
               vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                                         pr_cdcooper => rw_lancamentos.cdcooper,
                                                         pr_nmsubdir => 'contab');
                    
               -- Busca o diretório final para copiar arquivos
               vr_dsdircop := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                       ,pr_cdcooper => 0
                                                       ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');
               -- Nome do arquivo a ser gerado
               vr_dtmvtolt_yymmdd := to_char(rw_lancamentos.dtmvtolt, 'yyyymmdd');
               vr_nmarqdat        := vr_dtmvtolt_yymmdd||'_'|| LPAD(TO_CHAR(rw_lancamentos.cdcooper),2,0) || '_SLIP_CONTABIL.txt';
                         
               -- Abre o arquivo para escrita
               gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio,    --> Diretório do arquivo
                                        pr_nmarquiv => vr_nmarqdat,         --> Nome do arquivo
                                        pr_tipabert => 'W',                 --> Modo de abertura (R,W,A)
                                        pr_utlfileh => vr_arquivo_txt,      --> Handle do arquivo aberto
                                        pr_des_erro => vr_dscritic); 
                                    
              
               IF vr_dscritic IS NOT NULL THEN
                  vr_cdcritic := 0;
                  vr_dscritic := vr_dscritic; 
                  RAISE vr_exc_saida ;            
               END IF;       
              
           END IF;
           
           
           vr_linhadet :=  TRIM(vr_dtmvtolt_yymmdd)||','||
                           trim(to_char(rw_lancamentos.dtmvtolt,'ddmmyy'))||','||
                           rw_lancamentos.nrctadeb ||','||
                           rw_lancamentos.nrctacrd ||','||
                           trim(to_char(rw_lancamentos.vllanmto,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --valor deve ir positivo para o arquivo
                           rw_lancamentos.cdhistor_padrao||','||
                           '"'||rw_lancamentos.dslancamento||'"';
                           
           gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
           
           --buscar rateios
           FOR rw_rateio IN cr_rateio(pr_cdcooper => rw_lancamentos.cdcooper
                                     ,pr_nseqslip => rw_lancamentos.nrsequencia_slip
                                     ,pr_dtmvtolt => rw_lancamentos.dtmvtolt) LOOP
              vr_linhadet := lpad(rw_rateio.cdgerencial,3,0)||','|| trim(to_char(rw_rateio.vllanmto,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
              gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet); 
           END LOOP;                                 
                     
        END LOOP;

        IF vr_flgarq = 0 THEN 
          -- fechar e mover depois aqui
          gene0001.pc_fecha_arquivo(vr_arquivo_txt);
                                            
          vr_nmarqnov := vr_dtmvtolt_yymmdd||'_'||LPAD(TO_CHAR(rw_crapcop.cdcooper),2,0)||'_SLIP_CONTABIL.txt';                       
                    
          -- Copia o arquivo gerado para o diretório final convertendo para DOS
          gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqdat||' > '||vr_dsdircop||'/'||vr_nmarqnov||' 2>/dev/null',
                                        pr_typ_saida   => vr_typ_said,
                                        pr_des_saida   => vr_dscritic);
                            
          -- Testar erro
          if vr_typ_said = 'ERR' THEN
              vr_cdcritic := 1040;
              gene0001.pc_print(gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_nmarqdat||': '||vr_dscritic);
          END IF;                                                       
                 
          COMMIT; 
        END IF;
      END LOOP;
    EXCEPTION          
      WHEN vr_exc_saida THEN 
        pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := vr_dscritic || Sqlerrm;
      WHEN OTHERS THEN 
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral na rotina.' || SQLERRM; 
    END;
  END pc_processa_lanc_slip;
END cont0002;
/
