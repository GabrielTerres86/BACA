CREATE OR REPLACE PACKAGE CECRED.TELA_MANCRD AS

  /*---------------------------------------------------------------------------------------------------------------
  
      Programa: TELA_MANCRD
      Autor   : Kelvin Souza Ott
      Data    : Junho/2017                   Ultima Atualizacao: 
  
      Dados referentes ao programa:
  
      Objetivo  : Package ref. a tela MANCRD (Ayllos Web)
  
      Alteracoes:                              
      
  ---------------------------------------------------------------------------------------------------------------*/
  PROCEDURE pc_busca_cartoes(pr_nrdconta IN crapass.nrdconta %TYPE --> Numero de conta
                            ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG                            
                            ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK
  
  
   PROCEDURE pc_atualiza_cartao(pr_nrdconta IN crapass.nrdconta%TYPE --> Numero de conta
                               ,pr_nrcrcard IN crapcrd.nrcrcard%TYPE --> Numero do cartao
                               ,pr_nrcctitg IN crawcrd.nrcctitg%TYPE --> Conta cartao
                               ,pr_nrcpftit IN crawcrd.nrcpftit%TYPE --> CPF do cartao
                               ,pr_cdadmcrd IN crawcrd.cdadmcrd%TYPE --> Administradora
                               ,pr_flgdebit IN crawcrd.flgdebit%TYPE --> Funcao debito
                               ,pr_nmtitcrd IN crapcrd.nmtitcrd%TYPE --> Nome do plastico
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG                            
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);
  
   PROCEDURE pc_reenviar_solicitacao (pr_nrdconta IN crapass.nrdconta%TYPE --> Numero de conta
                                     ,pr_nrcrcard IN crapcrd.nrcrcard%TYPE --> Numero do cartao                                    
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG                            
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);
  
END TELA_MANCRD;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_MANCRD AS

  /*---------------------------------------------------------------------------------------------------------------
  
      Programa: TELA_MANCRD
      Autor   : Kelvin Souza Ott
      Data    : Junho/2017                   Ultima Atualizacao: 
  
      Dados referentes ao programa:
  
      Objetivo  : Package ref. a tela MANCRD (Ayllos Web)
  
      Alteracoes:                              
      
  ---------------------------------------------------------------------------------------------------------------*/

  PROCEDURE pc_busca_cartoes(pr_nrdconta IN crapass.nrdconta %TYPE --> Numero de conta
                            ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG                            
                            ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_busca_cartoes
    Sistema : Ayllos Web
    Autor   : Kelvin Souza Ott
    Data    : Junho/2017                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Busca as informacoes dos cartoes
                    
    Alteracoes: 
    ............................................................................. */
    
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    --Valida se cooperado existe
    CURSOR cr_busca_cooperado(pr_cdcooper crapcop.cdcooper%TYPE
                             ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT 1
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_busca_cooperado cr_busca_cooperado%ROWTYPE;
                                         
    --Busca dados do pacote
    CURSOR cr_dados_cartoes(pr_cdcooper crapcop.cdcooper%TYPE
                           ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT crd.cdcooper
            ,gene0002.fn_mask_conta(crd.nrdconta) nrdconta
            ,gene0002.fn_mask(to_char(crd.nrcrcard),'9999.9999.9999.9999') nrcrcard
            ,crd.nmtitcrd
            ,crd.nrcctitg
            ,crd.cdadmcrd
            ,gene0002.fn_mask(lpad(crd.nrcpftit,11,'0'),'999.999.999-99') nrcpftit
            ,crd.flgdebit
            ,adc.nmresadm
            ,crd.dtvalida            
            ,CASE WHEN crd.insitcrd = 0 THEN 'Em Estudo' 
                  WHEN crd.insitcrd = 1 THEN 'Aprovado'   
                  WHEN crd.insitcrd = 2 THEN 'Solicitado'   
                  WHEN crd.insitcrd = 3 THEN 'Liberado'   
                  WHEN crd.insitcrd = 4 THEN 'Em Uso'   
                  WHEN crd.insitcrd = 5 THEN 'Bloqueado'   
                  WHEN crd.insitcrd = 6 THEN 'Cancelado'                       
                  WHEN (crd.insitcrd = 4 AND dtsol2vi IS NOT NULL) OR insitcrd = 7 THEN 'Sol.2v'
             END dssitcrd
            ,ass.nmprimtl
            ,(SELECT regexp_replace(sys.stragg(adm.cdadmcrd|| ';' ||adm.nmresadm || '|'),'\|+$','')
                FROM crapadc adm
               WHERE adm.cdadmcrd BETWEEN 10 AND 80
                 AND adm.cdcooper = crd.cdcooper ) listadm
        FROM crawcrd crd
   LEFT JOIN crapadc adc
          ON adc.cdcooper = crd.cdcooper
         AND adc.cdadmcrd = crd.cdadmcrd
        JOIN crapass ass
          ON ass.cdcooper = crd.cdcooper
         AND ass.nrdconta = crd.nrdconta
       WHERE crd.cdcooper = pr_cdcooper
         AND crd.nrdconta = pr_nrdconta
         AND (crd.cdadmcrd BETWEEN 10 AND 80 OR crd.cdadmcrd = 0);
         
    --Variaveis auxiliares
    vr_dadosxml VARCHAR(32676);
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
  BEGIN
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
  
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Verifica se a cooperativa esta cadastrada
    OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);

    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    OPEN cr_busca_cooperado(vr_cdcooper
                           ,pr_nrdconta);
      FETCH cr_busca_cooperado
        INTO rw_busca_cooperado;
        
      IF cr_busca_cooperado%NOTFOUND THEN
        CLOSE cr_busca_cooperado;
        vr_cdcritic := 9;
        RAISE vr_exc_erro;
      END IF;    

    CLOSE cr_busca_cooperado; 

                           
    
    vr_dadosxml := '<?xml version="1.0" encoding="ISO-8859-1" ?>
                       <root>';
    FOR rw_dados_cartoes IN cr_dados_cartoes(vr_cdcooper
                                            ,pr_nrdconta) LOOP
      
      vr_dadosxml := vr_dadosxml || '<dados>  
                                       <cdcooper>' || rw_dados_cartoes.cdcooper || '</cdcooper>
                                       <nrdconta>' || rw_dados_cartoes.nrdconta || '</nrdconta>
                                       <nrcrcard>' || rw_dados_cartoes.nrcrcard || '</nrcrcard>                          
                                       <nmtitcrd>' || rw_dados_cartoes.nmtitcrd || '</nmtitcrd>
                                       <nrcctitg>' || rw_dados_cartoes.nrcctitg || '</nrcctitg>
                                       <cdadmcrd>' || rw_dados_cartoes.cdadmcrd || '</cdadmcrd>
                                       <nrcpftit>' || rw_dados_cartoes.nrcpftit || '</nrcpftit>
                                       <flgdebit>' || rw_dados_cartoes.flgdebit || '</flgdebit>
                                       <nmresadm>' || rw_dados_cartoes.nmresadm || '</nmresadm>
                                       <dssitcrd>' || rw_dados_cartoes.dssitcrd || '</dssitcrd>
                                       <dtvalida>' || TO_CHAR(rw_dados_cartoes.dtvalida, 'DD/MM/YYYY') || '</dtvalida>
                                       <nmprimtl>' || rw_dados_cartoes.nmprimtl || '</nmprimtl>
                                       <listadm>' || rw_dados_cartoes.listadm || '</listadm>
                                     </dados>'; 
                                                  
    END LOOP;
    
    vr_dadosxml := vr_dadosxml || '</root>';
    
    IF vr_dadosxml IS NOT NULL THEN
        pr_retxml := XMLType.createXML(vr_dadosxml);
    END IF;
    
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> 
                                        <Root>
                                          <Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro>
                                        </Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_MANCRD.PC_BUSCA_CARTOES: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> 
                                        <Root>
                                          <Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro>
                                        </Root>');
    
  END pc_busca_cartoes;

  PROCEDURE pc_atualiza_cartao(pr_nrdconta IN crapass.nrdconta%TYPE --> Numero de conta
                              ,pr_nrcrcard IN crapcrd.nrcrcard%TYPE --> Numero do cartao
                              ,pr_nrcctitg IN crawcrd.nrcctitg%TYPE --> Conta cartao
                              ,pr_nrcpftit IN crawcrd.nrcpftit%TYPE --> CPF do cartao
                              ,pr_cdadmcrd IN crawcrd.cdadmcrd%TYPE --> Administradora
                              ,pr_flgdebit IN crawcrd.flgdebit%TYPE --> Funcao debito
                              ,pr_nmtitcrd IN crapcrd.nmtitcrd%TYPE --> Nome do plastico
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG                            
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_atualiza_cartao
    Sistema : Ayllos Web
    Autor   : Kelvin Souza Ott
    Data    : Junho/2017                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Atualiza as informações do cartao
                    
    Alteracoes: 
    ............................................................................. */
  
   -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
    vr_dscritic crapcri.dscritic%TYPE;    
    vr_dsderror VARCHAR2(500);
  
  BEGIN
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    BEGIN
      UPDATE crawcrd crd
         SET crd.nrcctitg = pr_nrcctitg
            ,crd.nrcpftit = pr_nrcpftit
            ,crd.cdadmcrd = pr_cdadmcrd
            ,crd.flgdebit = pr_flgdebit
            ,crd.nmtitcrd = pr_nmtitcrd
       WHERE crd.nrdconta = pr_nrdconta
         AND crd.nrcrcard = pr_nrcrcard
         AND crd.cdcooper = vr_cdcooper;    
    EXCEPTION
      WHEN OTHERS THEN
           vr_dsderror := 'TELA_MANCRD.PC_ATUALIZA_CARTAO: Erro ao atualizar a tabela crawcrd ' || SQLERRM;
           RAISE vr_exc_erro;
    END;
    
    BEGIN
      UPDATE crapcrd crd
         SET crd.nrcpftit = pr_nrcpftit
            ,crd.cdadmcrd = pr_cdadmcrd
            ,crd.flgdebit = pr_flgdebit
            ,crd.nmtitcrd = pr_nmtitcrd
       WHERE crd.nrdconta = pr_nrdconta
         AND crd.nrcrcard = pr_nrcrcard
         AND crd.cdcooper = vr_cdcooper;
      
    EXCEPTION 
      WHEN OTHERS THEN
        vr_dsderror := 'Erro na tela_mancrd.pc_atualiza_cartao: ao atualizar a tabela crapcrd ' || SQLERRM;
        RAISE vr_exc_erro;
    END;    
      
  EXCEPTION 
    WHEN vr_exc_erro THEN
      ROLLBACK;
      -- Retorno não OK          
      pr_des_erro := 'NOK';
    
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := vr_dsderror;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> 
                                        <Root>
                                          <Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro>
                                        </Root>');
    WHEN OTHERS THEN
      ROLLBACK;
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na tela_mancrd.pc_atualiza_cartao: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> 
                                        <Root>
                                          <Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro>
                                        </Root>');  

  END pc_atualiza_cartao;
  
  PROCEDURE pc_reenviar_solicitacao (pr_nrdconta IN crapass.nrdconta%TYPE --> Numero de conta
                                    ,pr_nrcrcard IN crapcrd.nrcrcard%TYPE --> Numero do cartao                                    
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG                            
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
    
      
    CURSOR cr_crawcrd(pr_cdcooper crapcop.cdcooper%TYPE

                     ,pr_nrdconta crapass.nrdconta%TYPE
                     ,pr_nrcrcard crawcrd.nrcrcard%TYPE) IS
      SELECT crd.insitcrd
        FROM crawcrd crd
       WHERE crd.cdcooper = pr_cdcooper
         AND crd.nrdconta = pr_nrdconta
         AND crd.nrcrcard = pr_nrcrcard;
    
    rw_crawcrd cr_crawcrd%ROWTYPE;
      
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;    
  
  BEGIN
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    OPEN cr_crawcrd(vr_cdcooper
                   ,pr_nrdconta
                   ,pr_nrcrcard);
      FETCH cr_crawcrd
        INTO rw_crawcrd;
    CLOSE cr_crawcrd;
       
    IF rw_crawcrd.insitcrd <> 2 THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Cartao deve estar com o status Solicitado para reenvio.';
      RAISE vr_exc_erro;        
    ELSE
      UPDATE crawcrd crd
         SET crd.insitcrd = 1
       WHERE crd.cdcooper = vr_cdcooper
         AND crd.nrdconta = pr_nrdconta
         AND crd.nrcrcard = pr_nrcrcard;      
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;
      -- Retorno não OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> 
                                        <Root>
                                          <Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro>
                                        </Root>');
    WHEN OTHERS THEN
      ROLLBACK;
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro em tela_mancrd.pc_reenviar_solicitacao: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> 
                                        <Root>
                                          <Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro>
                                        </Root>');  
  END pc_reenviar_solicitacao;
END TELA_MANCRD;
/
