CREATE OR REPLACE PACKAGE CECRED.TELA_LISLOT IS

  /*Programa: visualização de detalhes da contab. do prejuízo na Lislot
    Sistema : contab. do prejuízo na Lislot
    Sigla   : CRED
    Autor   : Fabio Adriano
    Data    : Agosto/2018                       Ultima atualizacao: */
  
  PROCEDURE pc_lista_det_prej_lislot(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta
                                    ,pr_cdhistor IN craphis.cdhistor%TYPE --> Código do histórico
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);
                                    
  PROCEDURE pc_lista_lislot_periodo(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta
                                   ,pr_cdhistor IN craphis.cdhistor%TYPE --> Código do histórico
                                   ,par_dtinicio IN VARCHAR2 --IN TBCC_PREJUIZO_DETALHE.dtmvtolt%TYPE -->Data movimento
                                   ,par_dttermin IN VARCHAR2 --TBCC_PREJUIZO_DETALHE.dtmvtolt%TYPE -->Data movimento
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                   ,pr_retxml   OUT CLOB    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);
                                                                        
END TELA_LISLOT;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_LISLOT IS

  /*..............................................................................

     Sistema : contab. do prejuízo na Lislot
     Sigla   : CRED
     Autor   : Fabio Adriano
     Data    : Agosto/2018                       Ultima atualizacao: 07/06/2019

     Frequencia: Sempre que for chamado

     Alteracoes:  07/06/2019 - P450 - Tratamento historicos 2970 e 2971 e Prejuizo 
                                      (Guilherme/AMcom)
     
     */
     

/*Procedure para visualização de detalhes da contab. do prejuízo na Lislot*/
PROCEDURE pc_lista_det_prej_lislot(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta
                                  ,pr_cdhistor IN craphis.cdhistor%TYPE --> Código do histórico
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
BEGIN
/* .............................................................................

  Programa: pc_lista_det_prej_lislot
  Sistema : Ayllos Web
  Autor   : Fabio Adriano
  Data    : 30/08/2018                 Ultima atualizacao:

  Frequencia: Sempre que for chamado

  Objetivo  : Rotina para visualização de detalhes da contab. do prejuízo na Lislot.

  Alteracoes: -----
  ..............................................................................*/
  
  DECLARE

    ----------->>> VARIAVEIS <<<--------
    
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(10000);       --> Desc. Erro
   
    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variáveis gerais da procedure
    vr_contador INTEGER := 0; -- Contador para inserção dos dados no XML
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    ----------->>> CURSORES <<<--------
    
    --busca detalhes da contab. do prejuízo na Lislot
    CURSOR cr_det_prej_lislot(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                             ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta
                             ,pr_cdhistor IN craphis.cdhistor%TYPE --> Código do histórico
                              ) IS
    SELECT v.dtmvtolt   ,
           --v.idlancto   ,
           v.nrdconta   ,
           v.cdhistor   ,
           v.vllanmto   ,
           v.dthrtran   ,
           v.cdoperad   ,
           v.cdcooper   
           --v.idprejuizo  
    FROM TBCC_PREJUIZO_DETALHE v             
     WHERE v.cdcooper = pr_cdcooper
      and  v.nrdconta = pr_nrdconta
      and  v.cdhistor = pr_cdhistor
      AND  v.cdhistor <> 2323 
      AND  v.cdhistor in (2408,2412,2716,2717,2718,2719,2720,2738,2739,2721,2723,2733,2725,2727,2729,2722,2732,2724,2726,2728,2730,2970,2971)
    ORDER BY v.dtmvtolt desc;       
    rw_det_prej_lislot cr_det_prej_lislot%ROWTYPE;
    
    --busca documento e nome do associado
    CURSOR cr_doc_nom_ass(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                         ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta
                          ) IS
    select distinct NRCPFCNPJ_BASE, NMPRIMTL   --doc e nome ass
        from crapass a 
        where a.nrdconta = pr_nrdconta
        and   a.cdcooper = pr_cdcooper;
    rw_doc_nom_ass cr_doc_nom_ass%ROWTYPE;
        
  BEGIN
     
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
    END IF;
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao  => 0, pr_tag_nova => 'historicos', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    FOR rw_det_prej_lislot 
      IN cr_det_prej_lislot(pr_cdcooper, pr_nrdconta, pr_cdhistor) LOOP
            
      FOR rw_doc_nom_ass IN cr_doc_nom_ass(pr_cdcooper, pr_nrdconta) LOOP                                       
        
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'historicos', pr_posicao  => 0, pr_tag_nova => 'historico', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'historico', pr_posicao  => vr_contador, pr_tag_nova => 'dtmvtolt', pr_tag_cont => rw_det_prej_lislot.dtmvtolt, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'historico', pr_posicao  => vr_contador, pr_tag_nova => 'cdagenci', pr_tag_cont => vr_cdagenci, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'historico', pr_posicao  => vr_contador, pr_tag_nova => 'nrdconta', pr_tag_cont => rw_det_prej_lislot.nrdconta, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'historico', pr_posicao  => vr_contador, pr_tag_nova => 'nmprimtl', pr_tag_cont => rw_doc_nom_ass.nmprimtl, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'historico', pr_posicao  => vr_contador, pr_tag_nova => 'nrdocmto', pr_tag_cont => rw_doc_nom_ass.NRCPFCNPJ_BASE, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'historico', pr_posicao  => vr_contador, pr_tag_nova => 'vllanmto', pr_tag_cont => rw_det_prej_lislot.vllanmto, pr_des_erro => vr_dscritic);
          /*gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'historico', pr_posicao  => vr_contador, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_det_prej_lislot.cdcooper, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'historico', pr_posicao  => vr_contador, pr_tag_nova => 'nrdcaixa', pr_tag_cont => vr_nrdcaixa, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'historico', pr_posicao  => vr_contador, pr_tag_nova => 'cdoperad', pr_tag_cont => rw_det_prej_lislot.cdoperad, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'historico', pr_posicao  => vr_contador, pr_tag_nova => 'cdhistor', pr_tag_cont => rw_det_prej_lislot.cdhistor, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'historico', pr_posicao  => vr_contador, pr_tag_nova => 'dthrtran', pr_tag_cont => rw_det_prej_lislot.dthrtran, pr_des_erro => vr_dscritic);*/
                  
      END LOOP;  
        
        vr_contador := vr_contador + 1;
      
    END LOOP;

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela TELA_LISLOT(pc_lista_det_prej_lislot): ' || SQLERRM;

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END;
  
END pc_lista_det_prej_lislot;
  

/*Procedure para visualização de detalhes da contab. do prejuízo na Lislot*/
PROCEDURE pc_lista_lislot_periodo(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta
                                 ,pr_cdhistor IN craphis.cdhistor%TYPE --> Código do histórico
                                 ,par_dtinicio IN VARCHAR2 --TBCC_PREJUIZO_DETALHE.dtmvtolt%TYPE -->Data movimento
                                 ,par_dttermin IN VARCHAR2 --TBCC_PREJUIZO_DETALHE.dtmvtolt%TYPE -->Data movimento
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                 ,pr_retxml   OUT CLOB    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
BEGIN
/* .............................................................................

  Programa: pc_lista_lislot_periodo
  Sistema : Ayllos Web
  Autor   : Fabio Adriano
  Data    : 30/08/2018                 Ultima atualizacao:

  Frequencia: Sempre que for chamado

  Objetivo  : Rotina para visualização de detalhes da contab. do prejuízo na Lislot. Periodo

  Alteracoes: -----
  ..............................................................................*/
  
  DECLARE

    ----------->>> VARIAVEIS <<<--------
    
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(10000);       --> Desc. Erro
   
    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variáveis gerais da procedure
    vr_contador INTEGER := 0; -- Contador para inserção dos dados no XML
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    vr_retxml xmltype;
    
    ----------->>> CURSORES <<<--------
    
    --busca detalhes da contab. do prejuízo na Lislot
    CURSOR cr_det_prej_lislot(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                             ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta
                             ,pr_cdhistor IN craphis.cdhistor%TYPE --> Código do histórico
                             ,par_dtinicio IN VARCHAR2 --IN TBCC_PREJUIZO_DETALHE.dtmvtolt%TYPE -->Data movimento
                             ,par_dttermin IN VARCHAR2 --IN TBCC_PREJUIZO_DETALHE.dtmvtolt%TYPE -->Data movimento
                              ) IS
    SELECT v.dtmvtolt  ,
           --v.idlancto   ,
           v.nrdconta   ,
           v.cdhistor   ,
           v.vllanmto   ,
           v.dthrtran   ,
           v.cdoperad   ,
           v.cdcooper   
           --v.idprejuizo  
    FROM TBCC_PREJUIZO_DETALHE v,
         craphis h              
     WHERE v.cdcooper = pr_cdcooper
      and  v.nrdconta = decode(pr_nrdconta,0,v.nrdconta,pr_nrdconta) --decode(0/*pr*/,0,v.nrdconta,/*pr*/0) --pr_nrdconta
      and  v.cdhistor = pr_cdhistor
      and  v.dtmvtolt >= TO_DATE(par_dtinicio, 'DD/MM/YYYY')
      and  v.dtmvtolt <= TO_DATE(par_dttermin, 'DD/MM/YYYY')
      AND  v.cdcooper = h.cdcooper
      AND  v.cdhistor = h.cdhistor
      AND  h.nmestrut =  'TBCC_PREJUIZO_DETALHE'
      AND  v.cdhistor <> 2323 
--      and  v.cdhistor in (2408,2412,2716,2717,2718,2719,2720,2738,2739,2721,2723,2733,2725,2727,2729,2722,2732,2724,2726,2728,2730,2970,2971)
    ORDER BY v.dtmvtolt desc;       
    rw_det_prej_lislot cr_det_prej_lislot%ROWTYPE;
    
    --busca documento e nome do associado
    CURSOR cr_doc_nom_ass(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                         ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta
                          ) IS
    select distinct NRCPFCNPJ_BASE, NMPRIMTL   --doc e nome ass
        from crapass a 
        where a.nrdconta = pr_nrdconta
        and   a.cdcooper = pr_cdcooper;
    rw_doc_nom_ass cr_doc_nom_ass%ROWTYPE;
        
  BEGIN
     
    vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
    --gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Dados', pr_posicao  => 0, pr_tag_nova => 'historicos', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    FOR rw_det_prej_lislot 
      IN cr_det_prej_lislot(pr_cdcooper, pr_nrdconta, pr_cdhistor, par_dtinicio, par_dttermin) LOOP
                  
      FOR rw_doc_nom_ass IN cr_doc_nom_ass(pr_cdcooper, rw_det_prej_lislot.nrdconta /*pr_nrdconta*/) LOOP                                       
        
          gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Dados', pr_posicao  => 0, pr_tag_nova => 'historico', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'historico', pr_posicao  => vr_contador, pr_tag_nova => 'dtmvtolt', pr_tag_cont => to_char(rw_det_prej_lislot.dtmvtolt,'DD/MM/YYYY'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'historico', pr_posicao  => vr_contador, pr_tag_nova => 'nrdconta', pr_tag_cont => rw_det_prej_lislot.nrdconta, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'historico', pr_posicao  => vr_contador, pr_tag_nova => 'nrdocmto', pr_tag_cont => rw_doc_nom_ass.NRCPFCNPJ_BASE, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'historico', pr_posicao  => vr_contador, pr_tag_nova => 'vllanmto', pr_tag_cont => rw_det_prej_lislot.vllanmto, pr_des_erro => vr_dscritic);
                  
      END LOOP;  
        
        vr_contador := vr_contador + 1;
      
    END LOOP;

    dbms_output.put_line(vr_retxml.getclobval);
    
    pr_retxml := vr_retxml.getclobval();

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;


    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela TELA_LISLOT(pc_lista_det_prej_lislot): ' || SQLERRM;

  END;
  
END pc_lista_lislot_periodo;

end TELA_LISLOT;
/
