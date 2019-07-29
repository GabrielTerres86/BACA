CREATE OR REPLACE PACKAGE CECRED.CONT0001 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CONT0001
  --  Sistema  : Rotinas para geração de arquivos contábeis para o Radar/Matera de
  --             lançamentos centralizados
  --  Sigla    : CONT
  --  Autor    : Jonatas Jaqmam Pereira - Supero
  --  Data     : Maio/2017.                   Ultima atualizacao: 02/05/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Diário
  -- Objetivo  : Rotinas para geração de arquivos contábeis para o Radar/Matera de
  --             lançamentos centralizados
  --
  ---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_gera_arq_centralizacao(pr_cdcooper IN NUMBER
                                     ,pr_dtmvtolt   IN DATE
                                     ,pr_retfile   OUT VARCHAR2
                                     ,pr_dscritic  OUT VARCHAR2);
                                       
  PROCEDURE pc_gera_arq_compe_central(pr_cdcooper   IN NUMBER
                                     ,pr_dtmvtolt   IN DATE
                                     ,pr_retfile   OUT VARCHAR2
                                     ,pr_dscritic  OUT VARCHAR2);    
                                     
  PROCEDURE pc_gera_arq_recuros_caixa(pr_cdcooper IN NUMBER
                                     ,pr_dtmvtolt   IN DATE    
                                     ,pr_dtmvtopr   IN DATE                                     
                                     ,pr_retfile   OUT VARCHAR2
                                     ,pr_dscritic  OUT VARCHAR2);                                   
                                   
  PROCEDURE pc_gera_arquivos_contabeis(pr_dtmvtolt IN DATE
                                      ,pr_dtmvtopr IN DATE);
                                      
  PROCEDURE pc_insere_lct_central(pr_dtmvtolt      IN DATE,
                                  pr_cdcooper      IN NUMBER,
                                  pr_cdagenci      IN NUMBER,
                                  pr_cdhistor      IN NUMBER,
                                  pr_vllamnto      IN NUMBER,
                                  pr_nrdconta      IN NUMBER,
                                  pr_nrconta_deb   IN NUMBER,
                                  pr_nrconta_cred  IN NUMBER,
                                  pr_dsrefere      IN VARCHAR2,
                                  pr_tplancamento  IN NUMBER,
                                  pr_cdcritic     OUT NUMBER,
                                  pr_dscritic     OUT VARCHAR2);                                        
                                                                  
END CONT0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CONT0001 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CONT0001
  --  Sistema  : Rotinas para geração de arquivos contábeis para o Radar/Matera de
  --             lançamentos centralizados
  --  Sigla    : CONT
  --  Autor    : Jonatas Jaqmam Pereira - Supero
  --  Data     : Maio/2017.                   Ultima atualizacao: 03/10/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Diário
  -- Objetivo  : Rotinas para geração de arquivos contábeis para o Radar/Matera de
  --             lançamentos centralizados
  --
  -- Alterações : 03/10/2017 - Ajustes na CC Debito Histórico 851 - Marcos(Supero)
  --
  --              16/07/2018 - Adicionados históricos nos arquivos LCTOSCENTRALIZACAO.txt e LCTOSCOMPE.txt
  --                           (Task SCTASK0010739 e SCTASK0010819 - Reinert) 
  ---------------------------------------------------------------------------------------------------------------

  -- constantes para geracao de arquivos contabeis
  vc_cdacesso CONSTANT VARCHAR2(24) := 'DIR_ARQ_CONTAB_X';
  vc_cdtodascooperativas INTEGER := 0;

  vr_con_dtmvtolt      VARCHAR2(20);
  vr_ind_arquivo       utl_file.file_type;  
  vr_contador          NUMBER := 0;  
  vr_utlfileh          VARCHAR2(200); 
  vr_nmarquiv          VARCHAR2(100);
  vr_linhadet          VARCHAR2(500);
  vr_dscomando         VARCHAR2(500);  
  vr_dscritic          VARCHAR2(4000);
  vr_retfile           VARCHAR2(400);
  vr_typ_saida         VARCHAR2(4000);  
  vr_dircon            VARCHAR2(200);
  vr_arqcon            VARCHAR2(200);   

  vr_idprglog          tbgen_prglog.idprglog%TYPE := 0;

  --Variavel de Exceção
  vr_exc_erro  EXCEPTION;
 
  -- Pl-Table principal que indexa os registro historico
  TYPE typ_reg_historico
    IS RECORD (nrctaori NUMBER          --> Conta Origem
              ,nrctades NUMBER          --> Conta Destino
              ,dsrefere VARCHAR2(500)); --> Descricao Historico


  TYPE typ_tab_historico
    IS TABLE OF typ_reg_historico
    INDEX BY BINARY_INTEGER; 
    
  vr_tab_historico typ_tab_historico;
  
  --Busca todas as cooperativas exceto central
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM crapcop
     WHERE cdcooper <> 3
  ORDER BY cdcooper;
  
  CURSOR cr_lct_central(pr_cdcooper in tbcontab_lanctos_centraliza.cdcooper%type) IS
    SELECT t.dtmvtolt,
           t.cdagenci,
           t.cdhistor,
           t.nrdconta,
           t.nrconta_deb,
           t.nrconta_cred,
           t.dsrefere,
           t.tplancamento,
           sum(t.vllancamento) vllancamento
      FROM tbcontab_lanctos_centraliza t
     WHERE t.cdhistor in (809,811,812,813,814,822,839,909,910,913,914,916,915,945,946,1007,1008)
       AND t.cdcooper = pr_cdcooper
    GROUP BY t.dtmvtolt,
             t.cdagenci,
             t.cdhistor,
             t.nrdconta,
             t.nrconta_deb,
             t.nrconta_cred,
             t.dsrefere,
             t.tplancamento
    ORDER BY t.dtmvtolt,
             t.cdhistor,
             t.tplancamento,
             t.nrconta_deb,
             t.dsrefere,
             t.cdagenci; 

  --
  PROCEDURE pc_abre_arquivo(pr_cdcooper  IN NUMBER,
                            pr_dtmvtolt  IN DATE,
                            pr_nmarquiv  IN VARCHAR2,
                            pr_retfile  OUT VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_abre_arquivo
  --  Sistema  : CONT
  --  Sigla    : CONT
  --  Autor    : Jonatas Jaqmam Pereira - Supero
  --  Data     : Maio/2017.                   Ultima atualizacao: 26/09/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : 
  --
  -- Alteracoes:
  -- 26/09/2017 - Inclusão do módulo e ação logado no oracle
  --            - Inclusão da chamada de procedure em exception others
  --            - Colocado logs no padrão
  --              (Ana - Envolti - Chamado 744433)
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    -- Inclusão do módulo e ação logado - Chamado 744433 - 26/09/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CONT0001.pc_abre_arquivo');
    
         
    -- Define o diretório do arquivo
    vr_utlfileh := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => 'contab') ;

    -- Define Nome do Arquivo
    vr_nmarquiv := to_char(pr_dtmvtolt, 'yy') ||
                   to_char(pr_dtmvtolt, 'mm') ||
                   to_char(pr_dtmvtolt, 'dd') ||
                   '_'||pr_nmarquiv||'.TMP';
         
    pr_retfile  := to_char(pr_dtmvtolt, 'yy') ||
                   to_char(pr_dtmvtolt, 'mm') ||
                   to_char(pr_dtmvtolt, 'dd') ||
                   '_'||pr_nmarquiv||'.txt';


    -- Abre arquivo em modo de escrita (W)
    GENE0001.pc_abre_arquivo(pr_nmdireto => vr_utlfileh         --> Diretório do arquivo
                            ,pr_nmarquiv => vr_nmarquiv         --> Nome do arquivo
                            ,pr_tipabert => 'W'                 --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_ind_arquivo      --> Handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic);       --> Erro
 
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao executar CONT0001.pc_abre_arquivo. Erro:'||sqlerrm;         

      --Inclusão na tabela de erros Oracle - Chamado 744433
      CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper
                                   ,pr_compleme => vr_dscritic );
  END pc_abre_arquivo;
  
  -- Escrever linha no arquivo
  PROCEDURE pc_gravar_linha(pr_linha IN VARCHAR2) IS
  BEGIN
    GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,pr_linha);
  END pc_gravar_linha;
  
  /*** Gerar arquivo AAMMDD_XX_LCTOSCENTRALIZACAO.txt ***/
  PROCEDURE pc_gera_arq_centralizacao(pr_cdcooper   IN NUMBER
                                     ,pr_dtmvtolt   IN DATE
                                     ,pr_retfile   OUT VARCHAR2
                                     ,pr_dscritic  OUT VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_gera_arq_centralizacao
  --  Sistema  : CONT
  --  Sigla    : CONT
  --  Autor    : Jonatas Jaqmam Pereira - Supero
  --  Data     : Maio/2017.                   Ultima atualizacao: 06/08/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : 
  --
  -- Alteracoes:
  -- 26/09/2017 - Inclusão do módulo e ação logado no oracle
  --            - Inclusão da chamada de procedure em exception others
  --            - Colocado logs no padrão
  --              (Ana - Envolti - Chamado 744433)
  --
  -- 06/08/2018 - Adicionado historico 2736 e 2737 (Rafael Faria - Supero PJ439)
  --
  --07/12/2018 - Alteração de conta no lançamento no arquivo, com histórico 1090. Alterado para conta 4453. SCTASK0029392 (Douglas - Mouts)
  --
  -- 08/07/2019 - Adicionado os históricos 2330, 2331, 2326 e 2327, para CCB MAIS IMOBILIZADO 
  --              e CCB MAIS CREDITO. SM Pós-Fixado. (Renato Darosci - Supero)
  --              
  ---------------------------------------------------------------------------------------------------------------
    
    -- Buscar informações de lançamentos das filiadas na central
    CURSOR cr_craplcm IS
      SELECT l.cdhistor,
             l.dtmvtolt,
             l.nrdconta,
             substr(l.nrdconta,1,length(l.nrdconta) -1)||'-'||substr(l.nrdconta,-1,1) nrctafmt,
             case when l.cdhistor IN (440,446,544,545,1024,1069,1160,1161,1024,1069,841,842,1802,1538) then
                    l.nrdocmto
                  else
                    null
             end nrdocmto,
             SUM(l.vllanmto) vllanmto
        FROM craplcm l,
             crapcop c 
       WHERE l.nrdconta = c.nrctactl
         AND l.cdhistor IN (440,446,544,545,1024,1069,1160,1161,1024,1069,841,842,1802,1538,
                            1623,1624,1625,1626,1627,1628,1684,527,530,1119,1120,1123,1124,1125,1126,1136,
                            1137,2057,2058,51,135,1917,1919,1148,1810,1837,1838,1028,777,851,1988,1660,1661,
                            1148,2227,2237,2238,2239,2240,2249,2250,2251,2252,
														845,1589,1090,844,846,847,848,1659,1864,2183,2222,2223,1155,843,1725,2461,
                            2462,1788,1811,1835,1836,2647,1687,1806,2221,1588,2657,2736,2737)
         AND l.cdcooper = 3   --Apenas lançamentos realizados na central para a filiada
         AND l.dtmvtolt = pr_dtmvtolt 
         AND c.cdcooper = pr_cdcooper
      GROUP BY l.cdhistor,
               case when l.cdhistor IN (440,446,544,545,1024,1069,1160,1161,1024,1069,841,842,1802,1538) then
                      l.nrdocmto
                    else
                      null
               end,
               l.dtmvtolt,
               l.nrdconta,
               substr(l.nrdconta,1,length(l.nrdconta) -1)||'-'||substr(l.nrdconta,-1,1)
      ORDER BY l.cdhistor;

    -- Buscar informações de lançamentos das filiadas na central
    -- Cursor ler parâmetros por número de documento
    CURSOR cr_crapprm(p_cdacesso IN VARCHAR2) IS
      SELECT substr(dsvlrprm,1,instr(dsvlrprm,';')-1) nrctacrt,
             substr(dsvlrprm,instr(dsvlrprm,';')+1) cdctactb
        FROM crapprm 
       WHERE nmsistem = 'CRED' 
         AND CDCOOPER   = 0 
         AND CDACESSO = p_cdacesso;
             
  --Busca lançamentos de pagamentos de emprestimos para geração de lançamentos             
  CURSOR cr_craplem IS     
    SELECT lem.dtmvtolt
         , lem.nrdconta
         -- Para o pós-fixado, deve retornar o contrato
         , CASE WHEN lem.cdhistor IN (91,95)     THEN lem.nrdocmto -- Pagamento emprestimo
                WHEN lem.cdhistor IN (2330,2331) THEN lem.nrctremp -- Pagamento emprestimo POS-FIXADO
                WHEN lem.cdhistor IN (2326,2327) THEN lem.nrctremp -- Liberacao de credito POS-FIXADO
                ELSE 0 END     nrdocmto
         , SUBSTR(lem.nrdconta,1,LENGTH(lem.nrdconta) -1)||'-'||SUBSTR(lem.nrdconta,-1,1) nrctafmt
         , epr.cdfinemp
         , SUM(lem.vllanmto) vllanmto
         , CASE WHEN lem.cdhistor IN (91,95)     THEN 1 -- Pagamento emprestimo
                WHEN lem.cdhistor IN (2330,2331) THEN 2 -- Pagamento emprestimo POS-FIXADO
                WHEN lem.cdhistor IN (2326,2327) THEN 3 -- Liberacao de credito POS-FIXADO
                ELSE 0 END      intiphis
      FROM craplem lem
         , crapepr epr
         , crapcop cop
     WHERE epr.cdcooper = lem.cdcooper
       AND epr.nrdconta = lem.nrdconta
       AND epr.nrctremp = lem.nrctremp
       AND lem.nrdconta = cop.nrctactl
       AND lem.cdcooper = 3           ---Apenas lançamento da central para as filiadas 
       AND epr.cdfinemp IN (1,2,3,4)
       AND lem.cdhistor IN (91,95  
                           ,2330,2331   -- Pagamentos POS-FIXADO
                           ,2326,2327)  -- Liberação de crédito POS-FIXADO
       AND lem.dtmvtolt = pr_dtmvtolt
       AND cop.cdcooper = pr_cdcooper
     GROUP BY lem.dtmvtolt
            , lem.nrdconta
            , CASE WHEN lem.cdhistor IN (91,95)     THEN lem.nrdocmto -- Pagamento emprestimo
                   WHEN lem.cdhistor IN (2330,2331) THEN lem.nrctremp -- Pagamento emprestimo POS-FIXADO
                   WHEN lem.cdhistor IN (2326,2327) THEN lem.nrctremp -- Liberacao de credito POS-FIXADO
                   ELSE 0 END
            , SUBSTR(lem.nrdconta,1,LENGTH(lem.nrdconta) -1)||'-'||SUBSTR(lem.nrdconta,-1,1)
            , epr.cdfinemp
            , CASE WHEN lem.cdhistor IN (91,95)     THEN 1 -- Pagamento emprestimo
                   WHEN lem.cdhistor IN (2330,2331) THEN 2 -- Pagamento emprestimo POS-FIXADO
                   WHEN lem.cdhistor IN (2326,2327) THEN 3 -- Liberacao de credito POS-FIXADO
                   ELSE 0 END;
    
    /*****************************  VARIAVEIS  ****************************/
    vr_exc_erro          EXCEPTION;
    vr_file_erro         EXCEPTION;

    vr_dsprefix          VARCHAR2(50);
    vr_nrctacrt          VARCHAR2(30);
    vr_cdctactb          NUMBER;
    vr_decendio          VARCHAR2(2);
    vr_dtdecendio        VARCHAR2(8);
    vr_tppessoa          VARCHAR2(2);
    vr_descricao         VARCHAR2(500);
    vr_nrctaori          NUMBER;
    vr_nrctades          NUMBER;


     -- Inicializa tabela de Historicos
     PROCEDURE pc_inicia_historico IS
     BEGIN
	      -- Inclusão do módulo e ação logado - Chamado 744433 - 26/09/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CONT0001.pc_inicia_historico 1');
        vr_tab_historico.DELETE;

        vr_tab_historico(1623).nrctaori := 1781;
        vr_tab_historico(1623).nrctades := 1452;
        vr_tab_historico(1623).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. SUPRIMENTO DE CASH';
        
        vr_tab_historico(1624).nrctaori := 1452;
        vr_tab_historico(1624).nrctades := 1781;
        vr_tab_historico(1624).dsrefere := 'CREDITO C/C pr_nrctafmt AILOS REF. RECOLHIMENTO DE CASH'; 

        vr_tab_historico(1625).nrctaori := 1781;
        vr_tab_historico(1625).nrctades := 1452;
        vr_tab_historico(1625).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. SUPRIMENTO DE NUMERARIOS NOS PA''S''';
        
        vr_tab_historico(1626).nrctaori := 1452;
        vr_tab_historico(1626).nrctades := 1781;
        vr_tab_historico(1626).dsrefere := 'CREDITO C/C pr_nrctafmt AILOS REF. RECOLHIMENTO DE NUMERARIOS NOS PA''S''';
        
        vr_tab_historico(1627).nrctaori := 1781;
        vr_tab_historico(1627).nrctades := 1452;
        vr_tab_historico(1627).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. AJUSTE DIFERENÇA DE FALTA DE NUMERARIOS';
        
        vr_tab_historico(1628).nrctaori := 1452;
        vr_tab_historico(1628).nrctades := 1781;
        vr_tab_historico(1628).dsrefere := 'CREDITO C/C pr_nrctafmt AILOS REF. AJUSTE DIFERENÇA DE SOBRA DE NUMERARIOS';
        
        vr_tab_historico(1684).nrctaori := 1452;
        vr_tab_historico(1684).nrctades := 1781;
        vr_tab_historico(1684).dsrefere := 'CREDITO C/C pr_nrctafmt AILOS REF. RECOLHIMENTO COOPERATIVA';
        
        vr_tab_historico(527).nrctaori := 1344;
        vr_tab_historico(527).nrctades := 1452;
        vr_tab_historico(527).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. APLICACAO RDCPOS AILOS';        
        
        vr_tab_historico(530).nrctaori := 1452;
        vr_tab_historico(530).nrctades := 1344;
        vr_tab_historico(530).dsrefere := 'CREDITO C/C pr_nrctafmt AILOS REF. RESGATE APLICACAOO RDCPOS AILOS';
        
        vr_tab_historico(1119).nrctaori := 4990;
        vr_tab_historico(1119).nrctades := 1452;
        vr_tab_historico(1119).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. REPASSE BENEFICIO INSS (MIGRACAO)';  
        
        vr_tab_historico(1120).nrctaori := 1452;
        vr_tab_historico(1120).nrctades := 1839;
        vr_tab_historico(1120).dsrefere := 'CREDITO C/C pr_nrctafmt AILOS REF. REPASSE BENEFICIO INSS (MIGRACAO)';
        
        vr_tab_historico(1123).nrctaori := 4990;
        vr_tab_historico(1123).nrctades := 1452;
        vr_tab_historico(1123).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. REPASSE LIQUIDACAO DE COBRANCA (MIGRACAO)';                          
        
        vr_tab_historico(1124).nrctaori := 1452;
        vr_tab_historico(1124).nrctades := 1839;
        vr_tab_historico(1124).dsrefere := 'CREDITO C/C pr_nrctafmt AILOS REF. REPASSE LIQUIDACAO DE COBRANCA (MIGRACAO)';
        
        vr_tab_historico(1125).nrctaori := 4990;
        vr_tab_historico(1125).nrctades := 1452;
        vr_tab_historico(1125).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. REPASSE TARIFA LIQUIDACAO DE COBRANCA (MIGRACAO)';                          
        
        vr_tab_historico(1126).nrctaori := 1452;
        vr_tab_historico(1126).nrctades := 1839;
        vr_tab_historico(1126).dsrefere := 'CREDITO C/C pr_nrctafmt AILOS REF. REPASSE TARIFA LIQUIDACAO DE COBRANCA (MIGRACAO)';
        
        vr_tab_historico(1136).nrctaori := 4957;
        vr_tab_historico(1136).nrctades := 1452;
        vr_tab_historico(1136).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. AJUSTE CHEQUES TROCADOS NO CAIXA (MIGRACAO)';
        
        vr_tab_historico(1137).nrctaori := 1452;
        vr_tab_historico(1137).nrctades := 4957;
        vr_tab_historico(1137).dsrefere := 'CREDITO C/C pr_nrctafmt AILOS REF. AJUSTE CHEQUES TROCADOS NO CAIXA (MIGRACAO)';
        
        vr_tab_historico(2057).nrctaori := 1452;
        vr_tab_historico(2057).nrctades := 7499;
        vr_tab_historico(2057).dsrefere := 'CREDITO C/C pr_nrctafmt AILOS REF. REEMBOLSO DE DESPESAS COM DEBITO DE SEGURO RESIDENCIAL - RECEBIDO DE CHUBB DO BRASIL';

        vr_tab_historico(2058).nrctaori := 1452;
        vr_tab_historico(2058).nrctades := 7499;
        vr_tab_historico(2058).dsrefere := 'CREDITO C/C pr_nrctafmt AILOS REF. REEMBOLSO DE DESPESAS COM DEBITO DE SEGURO DE VIDA - RECEBIDO DE CHUBB DO BRASIL';
                
        vr_tab_historico(51).nrctaori := 1452;
        vr_tab_historico(51).nrctades := 1829;
        vr_tab_historico(51).dsrefere := 'CREDITO C/C pr_nrctafmt AILOS REF. RECEITA DE CENTRALIZACAO FINANCEIRA AILOS';
                
        vr_tab_historico(135).nrctaori := 4940;
        vr_tab_historico(135).nrctades := 1452;
        vr_tab_historico(135).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. PAGAMENTO DE DESPESAS DIRETAS E INDIRETAS DA CENTRAL';
                
        vr_tab_historico(1917).nrctaori := 1767;
        vr_tab_historico(1917).nrctades := 1452;
        vr_tab_historico(1917).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. ENVIO DE TED PARA EFETIVACAO DE PORTABILIDADE DE CREDITO';
                
        vr_tab_historico(1919).nrctaori := 8278;
        vr_tab_historico(1919).nrctades := 1452;
        vr_tab_historico(1919).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. RESSARCIMENTO DE CUSTOS DE ORIGINACAO SOBRE OPERACOES DE PORTABILIDADE DE CREDITO';
                
        vr_tab_historico(1148).nrctaori := 4983;
        vr_tab_historico(1148).nrctades := 1452;
        vr_tab_historico(1148).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. REGULARIZACAO DE REPASSE DE CDC DIGITADO NA COOPERATIVA E REPASSADO POR OUTRA COOPERATIVA FILIADA A AILOS';
                
        vr_tab_historico(1810).nrctaori := 1452;
        vr_tab_historico(1810).nrctades := 7264;
        vr_tab_historico(1810).dsrefere := 'CREDITO C/C pr_nrctafmt AILOS REF. TIB SICREDI';   
                
        vr_tab_historico(1837).nrctaori := 8605;
        vr_tab_historico(1837).nrctades := 1452;
        vr_tab_historico(1837).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. CUSTO SPB SICREDI - INSS CONSIGNADO SICREDI';
                
        vr_tab_historico(1838).nrctaori := 8605;
        vr_tab_historico(1838).nrctades := 1452;
        vr_tab_historico(1838).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. TARIFA SICREDI';
                
        vr_tab_historico(1028).nrctaori := 8371;
        vr_tab_historico(1028).nrctades := 1452;
        vr_tab_historico(1028).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. CONTRIBUICAO PARA RESERVA PARA RISCOS DE VALORES EM TERMINAIS DE AUTOATENDIMENTO – RRVTA';
                
        vr_tab_historico(777).nrctaori := 8371;
        vr_tab_historico(777).nrctades := 1452;
        vr_tab_historico(777).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. CONTRIBUICAO PARA RESERVA PARA RISCOS DE VALORES DOS POSTOS DE ATENDIMENTO – RRV';             
                
        vr_tab_historico(851).nrctaori := 4453;
        vr_tab_historico(851).nrctades := 1452;
        vr_tab_historico(851).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. REPASSE CONTRIBUICAO SINDICAL';             
                
        vr_tab_historico(1988).nrctaori := 1452;
        vr_tab_historico(1988).nrctades := 7478;
        vr_tab_historico(1988).dsrefere := 'CREDITO C/C pr_nrctafmt AILOS REF. RECEBIMENTO INCENTIVO DE CAMPANHA BANDEIRA MASTERCARD - MASTERCARD PLATINUM'; 
                
        vr_tab_historico(1660).nrctaori := 8546;
        vr_tab_historico(1660).nrctades := 1452;
        vr_tab_historico(1660).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. CONTRIBUICAO AO REFAP';             
                
        vr_tab_historico(1661).nrctaori := 8545;
        vr_tab_historico(1661).nrctades := 1452;
        vr_tab_historico(1661).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. CONTRIBUICAO ADICIONAL AO REFAP CONFORME REGULAMENTO DO SARC';             
                
        vr_tab_historico(2227).nrctaori := 4340;
        vr_tab_historico(2227).nrctades := 1452;
        vr_tab_historico(2227).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. REPASSE RECARGA DE CELULAR TIM';
                
        vr_tab_historico(2237).nrctaori := 4340;
        vr_tab_historico(2237).nrctades := 1452;
        vr_tab_historico(2237).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. REPASSE RECARGA DE CELULAR VIVO';
                
        vr_tab_historico(2238).nrctaori := 4340;
        vr_tab_historico(2238).nrctades := 1452;
        vr_tab_historico(2238).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. REPASSE RECARGA DE CELULAR OI';
                
        vr_tab_historico(2239).nrctaori := 4340;
        vr_tab_historico(2239).nrctades := 1452;
        vr_tab_historico(2239).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. REPASSE RECARGA DE CELULAR CLARO';
                
        vr_tab_historico(2240).nrctaori := 4340;
        vr_tab_historico(2240).nrctades := 1452;
        vr_tab_historico(2240).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. REPASSE RECARGA DE CELULAR NEXTEL';
                
        vr_tab_historico(2249).nrctaori := 4340;
        vr_tab_historico(2249).nrctades := 1452;
        vr_tab_historico(2249).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. REPASSE RECARGA DE CELULAR EMBRATEL LIVRE';
                
        vr_tab_historico(2250).nrctaori := 4340;
        vr_tab_historico(2250).nrctades := 1452;
        vr_tab_historico(2250).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. REPASSE RECARGA DE CELULAR CTBC';                
                
        vr_tab_historico(2251).nrctaori := 4340;
        vr_tab_historico(2251).nrctades := 1452;
        vr_tab_historico(2251).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. REPASSE RECARGA DE CELULAR CERCONTEL';
                
        vr_tab_historico(2252).nrctaori := 4340;
        vr_tab_historico(2252).nrctades := 1452;
        vr_tab_historico(2252).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. REPASSE RECARGA DE CELULAR TELEFONICA';
        
				vr_tab_historico(845).nrctaori := 4453;
        vr_tab_historico(845).nrctades := 1452;
        vr_tab_historico(845).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. FGTS S/ FOLHA DE PAGAMENTO DOS COLABORADORES';
				
				vr_tab_historico(1589).nrctaori := 4453;
        vr_tab_historico(1589).nrctades := 1452;
        vr_tab_historico(1589).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. REPASSE SERVICO DE SEGURANCA E VIGILANCIA';

				vr_tab_historico(1090).nrctaori := 4453;
        vr_tab_historico(1090).nrctades := 1452;
        vr_tab_historico(1090).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. PAGAMENTO PROCAPCRED';

				vr_tab_historico(844).nrctaori := 4453;
        vr_tab_historico(844).nrctades := 1452;
        vr_tab_historico(844).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. REPASSE IR FOLHA';

				vr_tab_historico(846).nrctaori := 4453;
        vr_tab_historico(846).nrctades := 1452;
        vr_tab_historico(846).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. REPASSE INSS';

				vr_tab_historico(847).nrctaori := 4453;
        vr_tab_historico(847).nrctades := 1452;
        vr_tab_historico(847).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. REPASSE IR TERCEIROS';

				vr_tab_historico(848).nrctaori := 4453;
        vr_tab_historico(848).nrctades := 1452;
        vr_tab_historico(848).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. REPASSE PCC';

				vr_tab_historico(1659).nrctaori := 4947;
        vr_tab_historico(1659).nrctades := 1452;
        vr_tab_historico(1659).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. CONTRIBUICAO ORDINARIA AO FGCOOP';

				vr_tab_historico(1864).nrctaori := 4453;
        vr_tab_historico(1864).nrctades := 1452;
        vr_tab_historico(1864).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. REPASSE GRRF';

				vr_tab_historico(2183).nrctaori := 8265;
        vr_tab_historico(2183).nrctades := 1452;
        vr_tab_historico(2183).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. CONTRIBUICAO RRF AILOS';
				
				vr_tab_historico(2222).nrctaori := 8503;
        vr_tab_historico(2222).nrctades := 1452;
        vr_tab_historico(2222).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. PROCESSAMENTO PAG SPB';

				vr_tab_historico(2223).nrctaori := 8503;
        vr_tab_historico(2223).nrctades := 1452;
        vr_tab_historico(2223).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. PROCESSAMENTO STR SPB';

				vr_tab_historico(1155).nrctaori := 1452;
        vr_tab_historico(1155).nrctades := 1889;
        vr_tab_historico(1155).dsrefere := 'CREDITO C/C pr_nrctafmt AILOS REF. REGULARIZACAO DE REPASSE DE CDC DIGITADO EM OUTRA COOPERATIVA FILIADA A AILOS E REPASSADO PELA COOPERATIVA';

				vr_tab_historico(843).nrctaori := 4453;
        vr_tab_historico(843).nrctades := 1452;
        vr_tab_historico(843).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. REPASSE PIS S/ FOLHA DE PAGAMENTO';

				vr_tab_historico(1725).nrctaori := 8247;
        vr_tab_historico(1725).nrctades := 1452;
        vr_tab_historico(1725).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. MENSALIDADE DOS PARTICIPANTES DO PROLIDER';

				vr_tab_historico(2461).nrctaori := 8248;
        vr_tab_historico(2461).nrctades := 1452;
        vr_tab_historico(2461).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. MENSALIDADE DO PROGRAMA DE DESENVOLVIMENTO DE EXECUTIVOS - PROEX';
				
				vr_tab_historico(2462).nrctaori := 4453;
        vr_tab_historico(2462).nrctades := 1452;
        vr_tab_historico(2462).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. REPASSE DARE - JURIDICO';
				
				vr_tab_historico(1788).nrctaori := 1272;
        vr_tab_historico(1788).nrctades := 1452;
        vr_tab_historico(1788).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. TED CONSIGNADO INSS RECEBIDO PELO SICREDI E REPASSADO AS COOP. FILIADAS A AILOS ATRAVES DA CONTA CENTRALIZADORA';
				
			  vr_tab_historico(1811).nrctaori := 4896;
        vr_tab_historico(1811).nrctades := 1452;
        vr_tab_historico(1811).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. TARIFA TIB DO CONSIGNADO INSS RECEBIDO DO SICREDI E REPASSADO AS COOPERATIVAS FILIADAS';
				
				vr_tab_historico(1835).nrctaori := 1452;
        vr_tab_historico(1835).nrctades := 1776;
        vr_tab_historico(1835).dsrefere := 'CREDITO C/C pr_nrctafmt AILOS REF. CUSTO SPB CONSIGNADO INSS SICREDI - ENVIADAS - REGULARIZADO NESTA DATA';

				vr_tab_historico(1836).nrctaori := 1452;
        vr_tab_historico(1836).nrctades := 1776;
        vr_tab_historico(1836).dsrefere := 'CREDITO C/C pr_nrctafmt AILOS REF. TARIFA RESERVA BANCARIA CONSIGNADO INSS SICREDI - CONVENIADAS - REGULARIZADO NESTA DATA';
				
				vr_tab_historico(2647).nrctaori := 4896;
        vr_tab_historico(2647).nrctades := 1452;
        vr_tab_historico(2647).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. AJUSTE DE TIB DO CONSIGNADO INSS SICREDI. VALOR REF. DEVOLUCOES DE TED ONDE A RECEITA PERTENCE A CENTRAL';
				
				vr_tab_historico(1687).nrctaori := 1452;
        vr_tab_historico(1687).nrctades := 1877;
        vr_tab_historico(1687).dsrefere := 'CREDITO C/C pr_nrctafmt AILOS REF. REEMBOLSO RECEBIDO DA REFAP';
				
				vr_tab_historico(1806).nrctaori := 4225;
        vr_tab_historico(1806).nrctades := 1452;
        vr_tab_historico(1806).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. PAGAMENTO DE RECURSOS CAPTADOS JUNTO AO BNDES PARA OPERACOES DE FINAME';
				
				vr_tab_historico(2221).nrctaori := 4453;
        vr_tab_historico(2221).nrctades := 1452;
        vr_tab_historico(2221).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. DESPESA COM RESSARCIMENTO DO USO DO SISBACEN';
				
				vr_tab_historico(1588).nrctaori := 4898;
        vr_tab_historico(1588).nrctades := 1452;
        vr_tab_historico(1588).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. DESPESAS COM TRANSPORTE DE VALORES - NFS FATURADAS P/ CENTRAL';
				
				vr_tab_historico(2657).nrctaori := 4453;
        vr_tab_historico(2657).nrctades := 1452;
        vr_tab_historico(2657).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. DESPESAS COM TRANSPORTE DE VALORES - NFS FATURADAS P/ FILIADAS';

        vr_tab_historico(2736).nrctaori := 1452;
        vr_tab_historico(2736).nrctades := 4955;
        vr_tab_historico(2736).dsrefere := 'CREDITO C/C pr_nrctafmt AILOS REF. REGULARIZACAO DE REPASSE DE CDC AUTOMATIZADO NA COOPERATIVA E REPASSADO POR OUTRA COOPERATIVA FILIADA A AILOS';

        vr_tab_historico(2737).nrctaori := 4955;
        vr_tab_historico(2737).nrctades := 1452;
        vr_tab_historico(2737).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. REGULARIZACAO DE REPASSE DE CDC AUTOMATIZADO NA COOPERATIVA E REPASSADO POR OUTRA COOPERATIVA FILIADA A AILOS';
				
   END;  
    
  BEGIN
    -- Inclusão do módulo e ação logado - Chamado 744433 - 26/09/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CONT0001.pc_gera_arq_centralizacao');

    -- Definir as datas das linhas do arquivo
    vr_con_dtmvtolt := '20' ||
                       to_char(pr_dtmvtolt, 'yy') ||
                       to_char(pr_dtmvtolt, 'mm') ||
                       to_char(pr_dtmvtolt, 'dd');

    pc_inicia_historico;
    -- Inclusão do módulo e ação logado - Chamado 744433 - 26/09/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CONT0001.pc_gera_arq_centralizacao');

    vr_contador := 0;
    
    --leitura e lançamentos gravados em tabela acumulado nos programas de origem
    FOR rw_lct_central IN cr_lct_central(pr_cdcooper/*, pr_dtmvtolt*/) LOOP
      
      IF rw_lct_central.cdhistor IN (909,910,913,914,915,916,945,946,1007,1008) THEN 
        
        vr_contador := vr_contador + 1;
        
        IF vr_contador = 1 THEN
             
          cont0001.pc_abre_arquivo(pr_cdcooper,pr_dtmvtolt,'LCTOSCENTRALIZACAO',pr_retfile);

          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_file_erro;
          END IF;
          -- Inclusão do módulo e ação logado - Chamado 744433 - 26/09/2017
          GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CONT0001.pc_gera_arq_centralizacao');

        END IF;  
          
        IF rw_lct_central.cdagenci = 0 AND rw_lct_central.tplancamento = 0 THEN      
    
          vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                         TRIM(to_char(rw_lct_central.dtmvtolt, 'ddmmyy')) || ','|| 
                         rw_lct_central.nrconta_deb||','||
                         rw_lct_central.nrconta_cred||','||                         
                         TRIM(to_char(rw_lct_central.vllancamento, '99999999999990.00')) ||
                         ',5210,' ||
                         '"'||rw_lct_central.dsrefere||'"';

          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);

        ELSE
          vr_linhadet := LPAD(rw_lct_central.cdagenci,3,0) ||','|| TRIM(to_char(rw_lct_central.vllancamento, '99999999999990.00')); 
          -- Gravar Linha          
          pc_gravar_linha(vr_linhadet);          
        END IF;
        
      END IF;
      
    END LOOP;
    --

    FOR rw_craplcm IN cr_craplcm LOOP
      
      vr_contador := vr_contador + 1;
    
      IF vr_contador = 1 THEN
         
        cont0001.pc_abre_arquivo(pr_cdcooper,pr_dtmvtolt,'LCTOSCENTRALIZACAO',pr_retfile);

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_file_erro;
        END IF;
        -- Inclusão do módulo e ação logado - Chamado 744433 - 26/09/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CONT0001.pc_gera_arq_centralizacao');

      END IF;
      
      --Prefixo de código de acesso para busca de parametros.      
      IF rw_craplcm.cdhistor in (440,446,544,545,1024,1069,1160,1161) THEN
        
        IF rw_craplcm.cdhistor in (544,545) THEN
          vr_dsprefix := 'CTA_BO_DOC_'; 
        ELSIF rw_craplcm.cdhistor in (1160,1161) THEN
          vr_dsprefix := 'CTA_SI_DOC_'; 
        ELSIF rw_craplcm.cdhistor in (440,446) THEN
          vr_dsprefix := 'CTA_BB_DOC_';
        ELSIF rw_craplcm.cdhistor in (1024,1069) THEN
          vr_dsprefix := 'CTA_BD_DOC_';
        END IF;
        
        vr_nrctacrt := null;
        vr_cdctactb := null;
        
        OPEN cr_crapprm(vr_dsprefix|| rw_craplcm.nrdocmto);
        FETCH cr_crapprm INTO vr_nrctacrt,vr_cdctactb;
        CLOSE cr_crapprm;
        
        IF vr_nrctacrt IS NULL THEN
          vr_nrctacrt := '';
          vr_cdctactb := 1888;  
        END IF;
      
      ELSIF rw_craplcm.cdhistor in (841,842) THEN
        
        IF to_char(pr_dtmvtolt, 'DD') BETWEEN 1 AND 10 or to_char(pr_dtmvtolt, 'DD') = 31 THEN
          vr_decendio := '3º';
          if to_char(pr_dtmvtolt, 'DD') = 31 then
            vr_dtdecendio := to_char(pr_dtmvtolt, 'MM/RRRR'); 
          ELSE
            vr_dtdecendio := to_char(add_months(pr_dtmvtolt,-1), 'MM/RRRR');            
          END IF;
        ELSIF to_char(pr_dtmvtolt, 'DD') BETWEEN 11 AND 20 THEN
          vr_decendio := '1º';  
          vr_dtdecendio := to_char(pr_dtmvtolt, 'MM/RRRR');                   
        ELSE
          vr_decendio := '2º';  
          vr_dtdecendio := to_char(pr_dtmvtolt, 'MM/RRRR');             
        END IF;       
        
        IF rw_craplcm.nrdocmto IN (7893,8053) THEN
          vr_tppessoa := 'PF';
        ELSE
          vr_tppessoa := 'PJ';
        END IF;
        
      END IF; 
      
      --Insere no arquivo conforme tipos de históricos
      IF rw_craplcm.cdhistor = 544 THEN

        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(pr_dtmvtolt, 'ddmmyy')) || ','|| 
                       vr_cdctactb||
                       ',1452,' ||
                       TRIM(to_char(rw_craplcm.vllanmto, '99999999999990.00')) ||
                       ',5210,' ||
                       '"CENTRALIZACAO FINANCEIRA AILOS DA C/C '||vr_nrctacrt||' BANCOOB"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);
      
      ELSIF rw_craplcm.cdhistor = 545 THEN
        
        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(pr_dtmvtolt, 'ddmmyy')) || ','|| 
                       '1452,'||
                       vr_cdctactb||','||
                       TRIM(to_char(rw_craplcm.vllanmto, '99999999999990.00')) ||
                       ',5210,' ||
                       '"CENTRALIZACAO FINANCEIRA AILOS DA C/C '||vr_nrctacrt||' BANCOOB"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);        

      ELSIF rw_craplcm.cdhistor = 1160 THEN

        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(pr_dtmvtolt, 'ddmmyy')) || ','|| 
                       '1272,'||
                       '1452,' ||
                       TRIM(to_char(rw_craplcm.vllanmto, '99999999999990.00')) ||
                       ',5210,' ||
                       '"CENTRALIZACAO FINANCEIRA AILOS DA C/C '||NVL(vr_nrctacrt,rw_craplcm.nrdocmto)||' SICREDI"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);
      
      ELSIF rw_craplcm.cdhistor = 1161 THEN
        
        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(pr_dtmvtolt, 'ddmmyy')) || ','|| 
                       '1452,'||
                       '1272,'||
                       TRIM(to_char(rw_craplcm.vllanmto, '99999999999990.00')) ||
                       ',5210,' ||
                       '"CENTRALIZACAO FINANCEIRA AILOS DA C/C '||NVL(vr_nrctacrt,rw_craplcm.nrdocmto)||' SICREDI"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet); 

      ELSIF rw_craplcm.cdhistor = 446 THEN

        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(pr_dtmvtolt, 'ddmmyy')) || ','|| 
                       vr_cdctactb||
                       ',1452,' ||
                       TRIM(to_char(rw_craplcm.vllanmto, '99999999999990.00')) ||
                       ',5210,' ||
                       '"DEBITO C/C '||rw_craplcm.nrctafmt||' AILOS REF. CENTRALIZACAO FINANCEIRA DA C/C '||vr_nrctacrt||' B. BRASIL"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);
      
      ELSIF rw_craplcm.cdhistor = 440 THEN
        
        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(pr_dtmvtolt, 'ddmmyy')) || ','|| 
                       '1452,'||
                       vr_cdctactb||','||
                       TRIM(to_char(rw_craplcm.vllanmto, '99999999999990.00')) ||
                       ',5210,' ||
                       '"CREDITO C/C '||rw_craplcm.nrctafmt||' AILOS REF. CENTRALIZACAO FINANCEIRA DA C/C '||vr_nrctacrt||' B. BRASIL"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet); 

      ELSIF rw_craplcm.cdhistor = 1024 THEN

        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(pr_dtmvtolt, 'ddmmyy')) || ','|| 
                       '1193,'||
                       '1452,' ||
                       TRIM(to_char(rw_craplcm.vllanmto, '99999999999990.00')) ||
                       ',5210,' ||
                       '"DEBITO C/C '||rw_craplcm.nrctafmt||' AILOS REF. CENTRALIZACAO FINANCEIRA DA C/C '||NVL(vr_nrctacrt,rw_craplcm.nrdocmto)||' BRADESCO"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);
      
      ELSIF rw_craplcm.cdhistor = 1069 THEN
        
        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(pr_dtmvtolt, 'ddmmyy')) || ','|| 
                       '1452,'||
                       '1193,'||
                       TRIM(to_char(rw_craplcm.vllanmto, '99999999999990.00')) ||
                       ',5210,' ||
                       '"CREDITO C/C '||rw_craplcm.nrctafmt||' AILOS REF. CENTRALIZACAO FINANCEIRA DA C/C '||NVL(vr_nrctacrt,rw_craplcm.nrdocmto)||' BRADESCO"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet); 
        
      ELSIF rw_craplcm.cdhistor = 1802 THEN        
        
        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(pr_dtmvtolt, 'ddmmyy')) || ','|| 
                       '4641,1452,'||
                       TRIM(to_char(rw_craplcm.vllanmto, '99999999999990.00')) ||
                       ',5210,' ||
                       '"DEBITO C/C '||rw_craplcm.nrctafmt||' AILOS REF. PAGTO MICROCREDITO BNDES - CONTRATO '||rw_craplcm.nrdocmto||'"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet); 

      ELSIF rw_craplcm.cdhistor = 1538 THEN        
        
        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(pr_dtmvtolt, 'ddmmyy')) || ','|| 
                       '4224,1452,'||
                       TRIM(to_char(rw_craplcm.vllanmto, '99999999999990.00')) ||
                       ',5210,' ||
                       '"DEBITO C/C '||rw_craplcm.nrctafmt||' AILOS REF. PAGTO MICROCREDITO BRDE - CONTRATO '||rw_craplcm.nrdocmto||'"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet); 

      ELSIF rw_craplcm.cdhistor = 841 THEN        
        
        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(pr_dtmvtolt, 'ddmmyy')) || ','|| 
                       '4453,1452,'||
                       TRIM(to_char(rw_craplcm.vllanmto, '99999999999990.00')) ||
                       ',5210,' ||
                       '"DEBITO C/C '||rw_craplcm.nrctafmt||' AILOS REF. RECOLHIMENTO DE IRRF S/ CAPTACAO ('||
                       vr_tppessoa||') '||rw_craplcm.nrdocmto||' REF '||vr_decendio||' DECENDIO DE '||vr_dtdecendio||'"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet); 

      ELSIF rw_craplcm.cdhistor = 842 THEN        
        
        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(pr_dtmvtolt, 'ddmmyy')) || ','|| 
                       '4453,1452,'||
                       TRIM(to_char(rw_craplcm.vllanmto, '99999999999990.00')) ||
                       ',5210,' ||
                       '"DEBITO C/C '||rw_craplcm.nrctafmt||' AILOS REF. RECOLHIMENTO DE IOF S/ OPERACOES DE CREDITO ('||
                       vr_tppessoa||') '||' REF '||vr_decendio||' DECENDIO DE '||vr_dtdecendio||'"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet); 

      END IF;
      
      IF vr_tab_historico.exists(rw_craplcm.cdhistor) THEN
  
        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(pr_dtmvtolt, 'ddmmyy')) || ','|| 
                       vr_tab_historico(rw_craplcm.cdhistor).nrctaori||','||
                       vr_tab_historico(rw_craplcm.cdhistor).nrctades||','||                         
                       TRIM(to_char(rw_craplcm.vllanmto, '99999999999990.00')) ||
                       ',5210,' ||
                       '"'||replace(vr_tab_historico(rw_craplcm.cdhistor).dsrefere,'pr_nrctafmt',rw_craplcm.nrctafmt)||'"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);          
  
      END IF;
        
      --Gravar linha gerencial
      IF rw_craplcm.cdhistor in (2057, 2058, 1919, 1810, 1837, 1838, 1028, 777, 1988, 1660, 1661, 1802, 1538
				                        ,2183, 2222, 2223, 1725, 2461, 1806) THEN
         
        vr_linhadet := '999'||','||TRIM(to_char(rw_craplcm.vllanmto, '99999999999990.00'));
          
        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);           
        
      END IF;
      
    END LOOP;
    --
    FOR rw_craplem IN cr_craplem LOOP
      
      vr_contador := vr_contador + 1;
    
      IF vr_contador = 1 THEN
         
        cont0001.pc_abre_arquivo(pr_cdcooper,pr_dtmvtolt,'LCTOSCENTRALIZACAO',pr_retfile);

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_file_erro;
        END IF;
        -- Inclusão do módulo e ação logado - Chamado 744433 - 26/09/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CONT0001.pc_gera_arq_centralizacao');

      END IF;    
    
      -- Se for registro de Liberação de Crédito
      IF rw_craplem.intiphis = 3 THEN
        
        -- Número conta
        vr_nrctaori := 1452;
      
        -- Financiamento
        IF rw_craplem.cdfinemp = 2 THEN
          vr_nrctades  := 4623;
          vr_descricao := '"CREDITO C/C '||rw_craplem.nrctafmt||' AILOS REF. LIBERACAO DE FINANCIAMENTO LONGO PRAZO - CCB MAIS IMOBILIZADO - CONTRATO '||rw_craplem.nrdocmto ||'"';
        -- Emprestimo
        ELSIF rw_craplem.cdfinemp = 3 THEN
          vr_nrctades  := 4624;
          vr_descricao := '"CREDITO C/C '||rw_craplem.nrctafmt||' AILOS REF. LIBERACAO DE EMPRESTIMO LONGO PRAZO - CCB MAIS CREDITO - CONTRATO '||rw_craplem.nrdocmto ||'"';        
        END IF; 
        
      ELSE
        
        -- Número conta
        vr_nrctades := 1452;
      
        IF rw_craplem.cdfinemp = 1 THEN
          vr_nrctaori  := 4226;
          vr_descricao := '"DEBITO C/C '||rw_craplem.nrctafmt||' AILOS REF. PAGAMENTO PRESTACAO REPASSE DE RECURSOS P/ MICROCREDITO - CEF - CONTRATO '||rw_craplem.nrdocmto ||'"';
        ELSIF rw_craplem.cdfinemp = 2 THEN
          vr_nrctaori  := 4623;
          vr_descricao := '"DEBITO C/C '||rw_craplem.nrctafmt||' AILOS REF. PAGAMENTO PRESTACAO FINANCIAMENTO LONGO PRAZO - CCB IMOBILIZADO - CONTRATO '||rw_craplem.nrdocmto ||'"';
        ELSIF rw_craplem.cdfinemp = 3 THEN
          vr_nrctaori  := 4624;
          vr_descricao := '"DEBITO C/C '||rw_craplem.nrctafmt||' AILOS REF. PAGAMENTO PRESTACAO EMPRESTIMO LONGO PRAZO - CCB MAIS CREDITO - CONTRATO '||rw_craplem.nrdocmto ||'"';        
        ELSIF rw_craplem.cdfinemp = 4 THEN
          vr_nrctaori  := 4227;
          vr_descricao := '"DEBITO C/C '||rw_craplem.nrctafmt||' AILOS REF. PAGAMENTO PRESTACAO REPASSE DE RECURSOS P/ MICROCREDITO - BNDES - CONTRATO '||rw_craplem.nrdocmto ||'"';
        END IF; 

      END IF;
      
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(pr_dtmvtolt, 'ddmmyy')) || ','|| 
                     vr_nrctaori||','||
                     vr_nrctades||','||                         
                     TRIM(to_char(rw_craplem.vllanmto, '99999999999990.00')) ||
                     ',5210,' ||
                     vr_descricao;

      -- Gravar Linha
      pc_gravar_linha(vr_linhadet); 
      
      if rw_craplem.cdfinemp = 3 then
        --Gera linha gerencial
        vr_linhadet := '133,'||TRIM(to_char(rw_craplem.vllanmto, '99999999999990.00')); 
      else 
        --Gera linha gerencial
        vr_linhadet := '999,'||TRIM(to_char(rw_craplem.vllanmto, '99999999999990.00'));  
      end if;            
              
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet);        
      
    END LOOP;

    /******************************************* GERAR ARQUIVO *****************************/

    IF vr_contador > 0 THEN
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

      -- Executa comando UNIX para converter arq para Dos
      vr_dscomando := 'ux2dos ' || vr_utlfileh || '/' || vr_nmarquiv || ' > '
                                || vr_utlfileh || '/' || pr_retfile || ' 2>/dev/null';

      -- Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_dscomando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);

      IF vr_typ_saida = 'ERR' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Busca o diretório para contabilidade
       vr_dircon := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                             ,pr_cdcooper => vc_cdtodascooperativas
                                             ,pr_cdacesso => vc_cdacesso);
                                             
       vr_arqcon := to_char(pr_dtmvtolt, 'yy') ||
                    to_char(pr_dtmvtolt, 'mm') ||
                    to_char(pr_dtmvtolt, 'dd') ||
                    '_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||
                    '_LCTOSCENTRALIZACAO.txt';

        -- Executa comando UNIX para converter arq para Dos
       vr_dscomando := 'ux2dos '||vr_utlfileh||'/'||pr_retfile||' > '||
                                  vr_dircon||'/'||vr_arqcon||' 2>/dev/null';

      -- Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_dscomando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);

      IF vr_typ_saida = 'ERR' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Remover arquivo tmp
      vr_dscomando := 'rm ' || vr_utlfileh || '/' || vr_nmarquiv;

      -- Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_dscomando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);

      IF vr_typ_saida = 'ERR' THEN

          RAISE vr_exc_erro;

      END IF;
    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN vr_file_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Monta mensagem de erro
      pr_dscritic := 'Erro em CONT0001.pc_gera_arq_centralizacao: ' || SQLERRM;
      --Inclusão na tabela de erros Oracle - Chamado 744433
      CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper
                                   ,pr_compleme => pr_dscritic );
  END pc_gera_arq_centralizacao;

  /*** Gerar arquivo AAMMDD_XX_LCTOSCOMPE.txt ***/
  PROCEDURE pc_gera_arq_compe_central(pr_cdcooper   IN NUMBER
                                      ,pr_dtmvtolt   IN DATE
                                      ,pr_retfile   OUT VARCHAR2
                                      ,pr_dscritic  OUT VARCHAR2) IS
  
  ---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_gera_arq_compe_central
  --  Sistema  : CONT
  --  Sigla    : CONT
  --  Autor    : Jonatas Jaqmam Pereira - Supero
  --  Data     : Maio/2017.                   Ultima atualizacao: 26/09/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : 
  --
  -- Alteracoes:
  -- 26/09/2017 - Inclusão do módulo e ação logado no oracle
  --            - Inclusão da chamada de procedure em exception others
  --            - Colocado logs no padrão
  --              (Ana - Envolti - Chamado 744433)
  ---------------------------------------------------------------------------------------------------------------
  
    vr_file_erro     EXCEPTION;
    
    --Busca lançamentos a serem enviados para o radar.    
    CURSOR cr_craplcm IS
      SELECT DECODE(l.cdhistor,788,787,790,789,l.cdhistor) cdhistor,
             l.nrdconta,
             TRIM(to_char(l.nrdconta,'999g999g999g9')) nrctafmt,
             SUM(l.vllanmto) vllanmto
        FROM CRAPLCM l,
             crapcop c 
       WHERE l.nrdconta = c.nrctacmp
         AND l.cdcooper = 3    --Apenas lançamentos da central
         AND l.cdhistor in (574, 577, 587, 787, 788, 789, 790, 807, 808, 2270, 2655, 2656)
         AND l.dtmvtolt = pr_dtmvtolt
         AND c.cdcooper = pr_cdcooper
      GROUP BY DECODE(l.cdhistor,788,787,790,789,l.cdhistor),
             l.nrdconta,
             TRIM(to_char(l.nrdconta,'999g999g999g9'))
      ORDER BY DECODE(l.cdhistor,788,787,790,789,l.cdhistor);
      
     -- Inicializa tabela de Historicos
     PROCEDURE pc_inicia_historico IS
     BEGIN
	      -- Inclusão do módulo e ação logado - Chamado 744433 - 26/09/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CONT0001.pc_inicia_historico 2');

        vr_tab_historico.DELETE;

        vr_tab_historico(574).nrctaori := 4894;
        vr_tab_historico(574).nrctades := 1455;
        vr_tab_historico(574).dsrefere := 'REGULARIZACAO DE DEVOLUCAO DE DOC DEVIDO INCONSISTENCIA DE DADOS (CONFORME CRITICA RELATORIO 527)';
        
        vr_tab_historico(787).nrctaori := 1455;
        vr_tab_historico(787).nrctades := 4958;
        vr_tab_historico(787).dsrefere := 'CREDITO C/C pr_nrctafmt AILOS REF. DEVOLUCAO CHEQUES DE COOPERADOS'; 

        vr_tab_historico(789).nrctaori := 1411;
        vr_tab_historico(789).nrctades := 1455;
        vr_tab_historico(789).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. DEVOLUCAO CHEQUES DE TERCEIROS DEPOSITADOS';
        
        vr_tab_historico(807).nrctaori := 1452;
        vr_tab_historico(807).nrctades := 1455;
        vr_tab_historico(807).dsrefere := 'CENTRALIZACAO FINANCEIRA C/C pr_nrctafmt COMPE AILOS';
        
        vr_tab_historico(808).nrctaori := 1455;
        vr_tab_historico(808).nrctades := 1452;
        vr_tab_historico(808).dsrefere := 'CENTRALIZACAO FINANCEIRA C/C pr_nrctafmt COMPE AILOS';
        
        vr_tab_historico(577).nrctaori := 1455;
        vr_tab_historico(577).nrctades := 1802;
        vr_tab_historico(577).dsrefere := 'CREDITO C/C pr_nrctafmt REF. RECEITA TARIFAS INTERBANCARIO AILOS - TIB REF. MES MM/YYYY';
        
        vr_tab_historico(2270).nrctaori := 4894;
        vr_tab_historico(2270).nrctades := 1455;
        vr_tab_historico(2270).dsrefere := 'DEBITO C/C pr_nrctafmt AILOS REF. DEVOLUCAO REMETIDA DE COBRANCA (CONFORME CRITICAS RELATORIO 574)';    
				
        vr_tab_historico(587).nrctaori := 4930;
        vr_tab_historico(587).nrctades := 1455;
        vr_tab_historico(587).dsrefere := 'DEBITO C/C pr_nrctafmt COMPE AILOS REF. TARIFAS INTERBANCARIO AILOS - TIB REF. MES MM/YYYY';
				
        vr_tab_historico(2655).nrctaori := 4952;
        vr_tab_historico(2655).nrctades := 1455;
        vr_tab_historico(2655).dsrefere := 'DEBITO C/C pr_nrctafmt COMPE AILOS REF. ARRECADACAO DO COBAN REALIZADO PELA CREDIFOZ ATRAVES DO PA 192 DA VIACREDI NO DIA ANTERIOR';
				
        vr_tab_historico(2656).nrctaori := 1455;
        vr_tab_historico(2656).nrctades := 1888;
        vr_tab_historico(2656).dsrefere := 'CREDITO C/C pr_nrctafmt COMPE AILOS REF. ARRECADACAO DO COBAN REALIZADO PELA CREDIFOZ ATRAVES DO PA 192 DA VIACREDI NO DIA ANTERIOR';
								
   END;  
             
  BEGIN
    -- Inclusão do módulo e ação logado - Chamado 744433 - 26/09/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CONT0001.pc_gera_arq_compe_central');

    -- Definir as datas das linhas do arquivo
    vr_con_dtmvtolt := '20' ||
                       to_char(pr_dtmvtolt, 'yy') ||
                       to_char(pr_dtmvtolt, 'mm') ||
                       to_char(pr_dtmvtolt, 'dd');

    vr_contador := 0;
    
    pc_inicia_historico;
    -- Inclusão do módulo e ação logado - Chamado 744433 - 26/09/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CONT0001.pc_gera_arq_compe_central');
    
    --leitura e lançamentos gravados em tabela acumulado nos programas de origem
    FOR rw_lct_central IN cr_lct_central(pr_cdcooper/*, pr_dtmvtolt*/) LOOP
      
      IF rw_lct_central.cdhistor IN (809,811,812,813,814,822,839) THEN 
        
        vr_contador := vr_contador + 1;
        
        IF vr_contador = 1 THEN
             
          cont0001.pc_abre_arquivo(pr_cdcooper,pr_dtmvtolt,'LCTOSCOMPE',pr_retfile);

          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_file_erro;
          END IF;
          -- Inclusão do módulo e ação logado - Chamado 744433 - 26/09/2017
          GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CONT0001.pc_gera_arq_compe_central');

        END IF;  
          
        IF rw_lct_central.cdagenci = 0 AND rw_lct_central.tplancamento = 0 THEN      
    
          vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                         TRIM(to_char(rw_lct_central.dtmvtolt, 'ddmmyy')) || ','|| 
                         rw_lct_central.nrconta_deb||','||
                         rw_lct_central.nrconta_cred||','||                         
                         TRIM(to_char(rw_lct_central.vllancamento, '99999999999990.00')) ||
                         ',5210,' ||
                         '"'||rw_lct_central.dsrefere||'"';

          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);

        ELSE
          vr_linhadet := LPAD(rw_lct_central.cdagenci,3,0) ||','||TRIM(to_char(rw_lct_central.vllancamento, '99999999999990.00')); 
          -- Gravar Linha
          pc_gravar_linha(vr_linhadet);          
        END IF;
        
      END IF;
      
    END LOOP;
    --
    
    FOR rw_craplcm in cr_craplcm LOOP
      
      vr_contador := vr_contador + 1;
    
      IF vr_contador = 1 THEN
         
        cont0001.pc_abre_arquivo(pr_cdcooper,pr_dtmvtolt,'LCTOSCOMPE',pr_retfile);

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_file_erro;
        END IF;
	      -- Inclusão do módulo e ação logado - Chamado 744433 - 26/09/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CONT0001.pc_gera_arq_compe_central');

      END IF;
      
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(pr_dtmvtolt, 'ddmmyy')) || ','|| 
                     vr_tab_historico(rw_craplcm.cdhistor).nrctaori||','||
                     vr_tab_historico(rw_craplcm.cdhistor).nrctades||','||                         
                     TRIM(to_char(rw_craplcm.vllanmto, '99999999999990.00')) ||
                     ',5210,' ||
                     '"'||REPLACE(REPLACE(vr_tab_historico(rw_craplcm.cdhistor).dsrefere,'pr_nrctafmt',rw_craplcm.nrctafmt),'MM/YYYY',to_char(pr_dtmvtolt, 'MM/YYYY'))||'"';

        -- Gravar Linha
      pc_gravar_linha(vr_linhadet); 
       
    END LOOP;
    
    IF vr_contador > 0 THEN
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

      -- Executa comando UNIX para converter arq para Dos
      vr_dscomando := 'ux2dos ' || vr_utlfileh || '/' || vr_nmarquiv || ' > '
                                || vr_utlfileh || '/' || pr_retfile || ' 2>/dev/null';

      -- Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_dscomando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);

      IF vr_typ_saida = 'ERR' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Busca o diretório para contabilidade
       vr_dircon := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                             ,pr_cdcooper => vc_cdtodascooperativas
                                             ,pr_cdacesso => vc_cdacesso);
                                             
       vr_arqcon := to_char(pr_dtmvtolt, 'yy') ||
                    to_char(pr_dtmvtolt, 'mm') ||
                    to_char(pr_dtmvtolt, 'dd') ||
                    '_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||
                    '_LCTOSCOMPE.txt';

        -- Executa comando UNIX para converter arq para Dos
       vr_dscomando := 'ux2dos '||vr_utlfileh||'/'||pr_retfile||' > '||
                                  vr_dircon||'/'||vr_arqcon||' 2>/dev/null';

      -- Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_dscomando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);

      IF vr_typ_saida = 'ERR' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Remover arquivo tmp
      vr_dscomando := 'rm ' || vr_utlfileh || '/' || vr_nmarquiv;

      -- Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_dscomando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);

      IF vr_typ_saida = 'ERR' THEN
          RAISE vr_exc_erro;
      END IF;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN vr_file_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Monta mensagem de erro
      pr_dscritic := 'Erro em CONT0001.pc_gera_arq_compe_central: ' || SQLERRM;
      --Inclusão na tabela de erros Oracle - Chamado 744433
      CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper
                                   ,pr_compleme => pr_dscritic );
  END pc_gera_arq_compe_central; 
  --
  PROCEDURE pc_gera_arq_recuros_caixa(pr_cdcooper   IN NUMBER
                                     ,pr_dtmvtolt   IN DATE
                                     ,pr_dtmvtopr   IN DATE
                                     ,pr_retfile   OUT VARCHAR2
                                     ,pr_dscritic  OUT VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_gera_arq_recuros_caixa
  --  Sistema  : CONT
  --  Sigla    : CONT
  --  Autor    : Jonatas Jaqmam Pereira - Supero
  --  Data     : Maio/2017.                   Ultima atualizacao: 26/09/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : 
  --
  -- Alteracoes:
  -- 26/09/2017 - Inclusão do módulo e ação logado no oracle
  --            - Inclusão da chamada de procedure em exception others
  --            - Colocado logs no padrão
  --              (Ana - Envolti - Chamado 744433)
  ---------------------------------------------------------------------------------------------------------------
  
    vr_vlsdeved      NUMBER := 0;    
    vr_file_erro     EXCEPTION;        
         
    CURSOR cr_vlsdeved IS
      SELECT SUM(epr.vlsdeved) vlsdeved
        FROM craplcr lcr
            ,crapepr epr
            ,crapcop cop
       WHERE epr.nrdconta = cop.nrctactl
         AND epr.cdcooper = lcr.cdcooper 
         AND epr.cdlcremp = lcr.cdlcremp
         AND epr.cdcooper = 3 -- Fixo Central
         AND epr.cdfinemp = 1 -- Fixo (REPASSE RECURSOS PNMPO CEF)
         AND lcr.cdusolcr = 1
         AND lcr.dsorgrec <> ' '
         AND cop.cdcooper = pr_cdcooper;
      rw_vlsdeved cr_vlsdeved%ROWTYPE;
         
  BEGIN
    -- Inclusão do módulo e ação logado - Chamado 744433 - 26/09/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CONT0001.pc_gera_arq_recuros_caixa');

    -- Definir as datas das linhas do arquivo
    vr_con_dtmvtolt := '50' ||
                       to_char(pr_dtmvtolt, 'yy') ||
                       to_char(pr_dtmvtolt, 'mm') ||
                       to_char(pr_dtmvtolt, 'dd');
  
    -- Busca o Saldo Devedor       
    OPEN cr_vlsdeved;
    FETCH cr_vlsdeved INTO rw_vlsdeved;
    IF cr_vlsdeved%FOUND THEN
       vr_vlsdeved := rw_vlsdeved.vlsdeved;  
    END IF;
    CLOSE cr_vlsdeved;     
         
    IF nvl(vr_vlsdeved,0) <> 0 then

      cont0001.pc_abre_arquivo(pr_cdcooper,pr_dtmvtolt,'RECURSOS_CAIXA',pr_retfile);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_file_erro;
      END IF;
      -- Inclusão do módulo e ação logado - Chamado 744433 - 26/09/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CONT0001.pc_gera_arq_recuros_caixa');
           
      -- 1ª linha
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(pr_dtmvtolt, 'ddmmyy')) || ','
                     || '3957'                                                                   || ','
                     || '9264'                                                                   || ','
                     || TRIM(TO_CHAR(vr_vlsdeved,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,')) || ','                                                      
                     || '5210' || ','
                     || '"CAIXA – CREDITOS CAPTADOS POR COOPERATIVAS REF. MES DE ' || TRIM(UPPER(to_char(pr_dtmvtolt,'month'))) || '/' || to_char(pr_dtmvtolt,'yyyy') || '"';                          


      -- Gravar Linha
      pc_gravar_linha(vr_linhadet); 
      --                  
                            
      -- 2ª linha
      vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                     TRIM(to_char(pr_dtmvtopr, 'ddmmyy')) || ','
                     || '9264'                                                                   || ','
                     || '3957'                                                                   || ','
                     || TRIM(TO_CHAR(vr_vlsdeved,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,')) || ','   
                     || '5210' || ','
                     || '"CAIXA – REVERSAO DOS CREDITOS CAPTADOS POR COOPERATIVAS REF. MES DE ' || TRIM(UPPER(to_char(pr_dtmvtolt,'month'))) || '/' || to_char(pr_dtmvtolt,'yyyy') || '"';                          

      ----
      -- Gravar Linha
      pc_gravar_linha(vr_linhadet); 
      --                              
                                    
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

      -- Executa comando UNIX para converter arq para Dos
      vr_dscomando := 'ux2dos ' || vr_utlfileh || '/' || vr_nmarquiv || ' > '
                                || vr_utlfileh || '/' || pr_retfile || ' 2>/dev/null';

      -- Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_dscomando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);

      IF vr_typ_saida = 'ERR' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Busca o diretório para contabilidade
       vr_dircon := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                             ,pr_cdcooper => vc_cdtodascooperativas
                                             ,pr_cdacesso => vc_cdacesso);
                                             
       vr_arqcon := to_char(pr_dtmvtolt, 'yy') ||
                    to_char(pr_dtmvtolt, 'mm') ||
                    to_char(pr_dtmvtolt, 'dd') ||
                    '_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||
                    '_RECURSOS_CAIXA.txt';

        -- Executa comando UNIX para converter arq para Dos
       vr_dscomando := 'ux2dos '||vr_utlfileh||'/'||pr_retfile||' > '||
                                  vr_dircon||'/'||vr_arqcon||' 2>/dev/null';

      -- Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_dscomando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);

      IF vr_typ_saida = 'ERR' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Remover arquivo tmp
      vr_dscomando := 'rm ' || vr_utlfileh || '/' || vr_nmarquiv;

      -- Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_dscomando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);

      IF vr_typ_saida = 'ERR' THEN
          RAISE vr_exc_erro;
      END IF;
         
    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN vr_file_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Monta mensagem de erro
      pr_dscritic := 'Erro em CONT0001.pc_gera_arq_recuros_caixa: ' || SQLERRM;
      --Inclusão na tabela de erros Oracle - Chamado 744433
      CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper
                                   ,pr_compleme => pr_dscritic );
  END pc_gera_arq_recuros_caixa;     
  --
  
  PROCEDURE pc_gera_arquivos_contabeis(pr_dtmvtolt IN DATE
                                      ,pr_dtmvtopr IN DATE) IS
    

    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_gera_arquivos_contabeis
    --  Sistema  : CONT
    --  Sigla    : CONT
    --  Autor    : Jonatas Jaqmam Pereira - Supero
    --  Data     : Maio/2017.                   Ultima atualizacao: 26/09/2017
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Esta rotina será encarregada de controlar todo o Workflow
    --
    -- Alteracoes:
    -- 26/09/2017 - Inclusão do módulo e ação logado no oracle
    --            - Inclusão da chamada de procedure em exception others
    --            - Colocado logs no padrão
    --              (Ana - Envolti - Chamado 744433)
    ---------------------------------------------------------------------------------------------------------------
    vr_des_log     VARCHAR2(2000);
    vr_cdprogra    VARCHAR2(30) := 'CONT0001';

  BEGIN
    -- Inclusão do módulo e ação logado - Chamado 744433 - 26/09/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CONT0001.pc_gera_arquivos_contabeis');
    
    vr_des_log := 'Inicio geracao arquivos contabeis de lancamentos centralizacao.';
    --> Controlar geração de log de execução dos jobs                                
    CECRED.pc_log_programa(pr_dstiplog      => 'O', 
                           pr_cdprograma    => vr_cdprogra, 
                           pr_cdcooper      => 3, 
                           pr_tpexecucao    => 2, --job
                           pr_tpocorrencia  => 4,
                           pr_cdcriticidade => 0, --baixa
                           pr_dsmensagem    => vr_des_log,                             
                           pr_idprglog      => vr_idprglog,
                           pr_nmarqlog      => NULL);
  
    FOR rw_crapcop IN cr_crapcop LOOP

      vr_dscritic := null;
      
      --Arquivo de lançamentos centralizado
      CONT0001.pc_gera_arq_centralizacao(rw_crapcop.cdcooper,pr_dtmvtolt,vr_retfile,vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN
        --> Controlar geração de log de execução dos jobs                                
        CECRED.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdprograma    => vr_cdprogra, 
                               pr_cdcooper      => 3, 
                               pr_tpexecucao    => 2, --job
                               pr_tpocorrencia  => 2,
                               pr_cdcriticidade => 0, --baixa
                               pr_dsmensagem    => vr_dscritic,                             
                               pr_idprglog      => vr_idprglog,
                               pr_nmarqlog      => NULL);
      END IF;
      -- Inclusão do módulo e ação logado - Chamado 744433 - 26/09/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CONT0001.pc_gera_arquivos_contabeis');

      vr_dscritic := null;       
      --Arquivos de lançamentos de compensação centralizado
      CONT0001.pc_gera_arq_compe_central(rw_crapcop.cdcooper,pr_dtmvtolt,vr_retfile,vr_dscritic); 
      
      IF vr_dscritic IS NOT NULL THEN
        --> Controlar geração de log de execução dos jobs                                
        CECRED.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdprograma    => vr_cdprogra, 
                               pr_cdcooper      => 3, 
                               pr_tpexecucao    => 2, --job
                               pr_tpocorrencia  => 2,
                               pr_cdcriticidade => 0, --baixa
                               pr_dsmensagem    => vr_dscritic,                             
                               pr_idprglog      => vr_idprglog,
                               pr_nmarqlog      => NULL);
      END IF; 
      -- Inclusão do módulo e ação logado - Chamado 744433 - 26/09/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CONT0001.pc_gera_arquivos_contabeis');
      
      vr_dscritic := null;       
      --Arquivos de lançamentos de recurso caixa
      CONT0001.pc_gera_arq_recuros_caixa(rw_crapcop.cdcooper,pr_dtmvtolt,pr_dtmvtopr,vr_retfile,vr_dscritic); 
      
      IF vr_dscritic IS NOT NULL THEN
        --> Controlar geração de log de execução dos jobs                                
        CECRED.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdprograma    => vr_cdprogra, 
                               pr_cdcooper      => 3, 
                               pr_tpexecucao    => 2, --job
                               pr_tpocorrencia  => 2,
                               pr_cdcriticidade => 0, --baixa
                               pr_dsmensagem    => vr_dscritic,                             
                               pr_idprglog      => vr_idprglog,
                               pr_nmarqlog      => NULL);
      END IF;       
      -- Inclusão do módulo e ação logado - Chamado 744433 - 26/09/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CONT0001.pc_gera_arquivos_contabeis');
      
    END LOOP;
    
    --Limpa os dados da tabela de lançamentos centralizados.
    DELETE FROM TBCONTAB_LANCTOS_CENTRALIZA;
    COMMIT;
    
    vr_des_log := 'Fim geracao arquivos contabeis de lancamentos centralizacao.';
    --> Controlar geração de log de execução dos jobs                                
    CECRED.pc_log_programa(pr_dstiplog      => 'O', 
                           pr_cdprograma    => vr_cdprogra, 
                           pr_cdcooper      => 3, 
                           pr_tpexecucao    => 2, --job
                           pr_tpocorrencia  => 4,
                           pr_cdcriticidade => 0, --baixa
                           pr_dsmensagem    => vr_des_log,                             
                           pr_idprglog      => vr_idprglog,
                           pr_nmarqlog      => NULL);

    
  
  END pc_gera_arquivos_contabeis;
  --
  PROCEDURE pc_insere_lct_central(pr_dtmvtolt      IN DATE,
                                  pr_cdcooper      IN NUMBER,
                                  pr_cdagenci      IN NUMBER,
                                  pr_cdhistor      IN NUMBER,
                                  pr_vllamnto      IN NUMBER,
                                  pr_nrdconta      IN NUMBER,
                                  pr_nrconta_deb   IN NUMBER,
                                  pr_nrconta_cred  IN NUMBER,
                                  pr_dsrefere      IN VARCHAR2,
                                  pr_tplancamento  IN NUMBER,
                                  pr_cdcritic     OUT NUMBER,
                                  pr_dscritic     OUT VARCHAR2) IS
    
  ---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_insere_lct_central
  --  Sistema  : CONT
  --  Sigla    : CONT
  --  Autor    : Jonatas Jaqmam Pereira - Supero
  --  Data     : Maio/2017.                   Ultima atualizacao: 26/09/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : 
  --
  -- Alteracoes:
  -- 26/092017 - Inclusão do módulo e ação logado no oracle
  --            - Inclusão da chamada de procedure em exception others
  --            - Colocado logs no padrão
  --              (Ana - Envolti - Chamado 744433)
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    -- Inclusão do módulo e ação logado - Chamado 744433 - 26/09/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CONT0001.pc_insere_lct_central');

    BEGIN
      INSERT INTO tbcontab_lanctos_centraliza(dtmvtolt,
                                              cdcooper, 
                                              cdagenci, 
                                              cdhistor, 
                                              vllancamento, 
                                              nrdconta, 
                                              nrconta_deb, 
                                              nrconta_cred, 
                                              dsrefere, 
                                              tplancamento)
                                       VALUES(pr_dtmvtolt,
                                              pr_cdcooper, 
                                              pr_cdagenci, 
                                              pr_cdhistor, 
                                              pr_vllamnto, 
                                              pr_nrdconta, 
                                              pr_nrconta_deb, 
                                              pr_nrconta_cred, 
                                              pr_dsrefere, 
                                              pr_tplancamento);
                                              
      COMMIT;
                                                                                        
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao inserir tbcontab_lanctos_centraliza: ' ||SQLERRM;
        --Inclusão na tabela de erros Oracle - Chamado 744433
        CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper
                                     ,pr_compleme => pr_dscritic );
    END;
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro na geral na procedure pc_insere_lct_central: ' ||SQLERRM;     
      --Inclusão na tabela de erros Oracle - Chamado 744433
      CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper
                                   ,pr_compleme => vr_dscritic );
  END;  
  --
END CONT0001;
/
