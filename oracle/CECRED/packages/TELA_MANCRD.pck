CREATE OR REPLACE PACKAGE CECRED.TELA_MANCRD AS

  /*---------------------------------------------------------------------------------------------------------------
  
      Programa: TELA_MANCRD
      Autor   : Kelvin Souza Ott
      Data    : Junho/2017                   Ultima Atualizacao: 
  
      Dados referentes ao programa:
  
      Objetivo  : Package ref. a tela MANCRD (Ayllos Web)
  
      Alteracoes: 25/07/2018 - Adicionado campo insitdec na tela. PRJ345(Lombardi).
                  
                  24/05/2019 - Adicionado procedure pc_valida_atualiza_cartoes
                               Alcemir Jr (PRB0041672).
      
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
                               ,pr_insitcrd IN crawcrd.insitcrd%TYPE --> Situacao do cartao
                               ,pr_insitdec IN crawcrd.insitdec%TYPE --> Decisao sobre a analise de credito do cartao
                               ,pr_flgprcrd IN crawcrd.flgprcrd%TYPE --> Titularidade
                               ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Contrato do cartao
                               ,pr_nmempres IN crawcrd.nmempcrd%TYPE --> Empresa
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG                            
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);
  
   PROCEDURE pc_reenviar_solicitacao (pr_nrdconta IN crapass.nrdconta%TYPE --> Numero de conta
                                     ,pr_nrcrcard IN crapcrd.nrcrcard%TYPE --> Numero do cartao                                    
                                     ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Numero do contrato do cartao
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG                            
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);

PROCEDURE pc_valida_atualiza_cartoes(pr_nrdconta IN crapass.nrdconta%TYPE --> Numero de conta
                                    ,pr_nrcrcard IN crapcrd.nrcrcard%TYPE --> Numero do cartao
                                    ,pr_nrcctitg IN crawcrd.nrcctitg%TYPE --> Conta cartao
                                    ,pr_nrcpftit IN crawcrd.nrcpftit%TYPE --> CPF do cartao
                                    ,pr_cdadmcrd IN crawcrd.cdadmcrd%TYPE --> Administradora
                                    ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Contrato do cartao
                                    ,pr_flgprcrd IN crawcrd.flgprcrd%TYPE --> Flag primeiro cartão                                 
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG                            
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica 
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica                                    
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) ;         --> Saida OK/NOK                                 
  
END TELA_MANCRD;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_MANCRD AS

  /*---------------------------------------------------------------------------------------------------------------
  
      Programa: TELA_MANCRD
      Autor   : Kelvin Souza Ott
      Data    : Junho/2017                   Ultima Atualizacao: 27/10/2017
  
      Dados referentes ao programa:
  
      Objetivo  : Package ref. a tela MANCRD (Ayllos Web)
  
      Alteracoes: 27/10/2017 - Efetuar ajustes e melhorias na tela (Lucas Ranghetti #742880)                           
      
                  25/07/2018 - Adicionado campo insitdec na tela. PRJ345(Lombardi).
      
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
    Data    : Junho/2017                       Ultima atualizacao: 27/10/2017
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Busca as informacoes dos cartoes
                    
    Alteracoes: 27/10/2017 - Efetuar ajustes e melhorias na tela (Lucas Ranghetti #742880)
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
            ,crd.insitcrd    
            ,crd.dtsol2vi     
            ,crd.nrctrcrd
            ,crd.flgprcrd
            ,crd.nmempcrd
            ,crd.insitdec
            ,CASE WHEN (crd.insitcrd = 4 AND dtsol2vi IS NOT NULL) OR insitcrd = 7 THEN 'Sol.2v'
                  WHEN crd.insitcrd = 0 THEN 'Em Estudo' 
                  WHEN crd.insitcrd = 1 THEN 'Aprovado'   
                  WHEN crd.insitcrd = 2 THEN 'Solicitado'   
                  WHEN crd.insitcrd = 3 THEN 'Liberado'   
                  WHEN crd.insitcrd = 4 THEN 'Em Uso'   
                  WHEN crd.insitcrd = 5 THEN 'Bloqueado'   
                  WHEN crd.insitcrd = 6 THEN 'Cancelado'                       
                  WHEN crd.insitcrd = 9 THEN 'Enviado Bancoob'
             END dssitcrd
            ,ass.nmprimtl
            ,ass.inpessoa
           ,(SELECT regexp_replace(sys.stragg(adm.cdadmcrd|| ';' ||adm.nmresadm || '|'),'\|+$','')
               FROM crapadc adm
              WHERE adm.cdadmcrd BETWEEN 10 AND 80
                AND adm.cdcooper = crd.cdcooper 
                AND adm.tpctahab = CASE WHEN ass.inpessoa = 1 THEN 1 ELSE 2 END) listadm -- buscar adm de cartõa conforme tipo de pessoa
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
                                       <insitcrd>' || rw_dados_cartoes.insitcrd || '</insitcrd>
                                       <insitdec>' || rw_dados_cartoes.insitdec || '</insitdec>
                                       <dtsol2vi>' || to_char(nvl(rw_dados_cartoes.dtsol2vi,''),'dd/mm/yyyy') || '</dtsol2vi>
                                       <dssitcrd>' || rw_dados_cartoes.dssitcrd || '</dssitcrd>
                                       <dtvalida>' || TO_CHAR(rw_dados_cartoes.dtvalida, 'DD/MM/YYYY') || '</dtvalida>
                                       <nmprimtl>' || rw_dados_cartoes.nmprimtl || '</nmprimtl>
                                       <listadm>' || rw_dados_cartoes.listadm || '</listadm>
                                       <nrctrcrd>'|| rw_dados_cartoes.nrctrcrd || '</nrctrcrd>
                                       <flgprcrd>'|| rw_dados_cartoes.flgprcrd || '</flgprcrd>
                                       <inpessoa>'|| rw_dados_cartoes.inpessoa || '</inpessoa>
                                       <nmempres>'|| nvl(replace(rw_dados_cartoes.nmempcrd,'0',''),'') || '</nmempres>
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
                              ,pr_insitcrd IN crawcrd.insitcrd%TYPE --> Situacao do cartao   
                              ,pr_insitdec IN crawcrd.insitdec%TYPE --> Decisao sobre a analise de credito do cartao
                              ,pr_flgprcrd IN crawcrd.flgprcrd%TYPE --> Titularidade         
                              ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Contrato do cartao
                              ,pr_nmempres IN crawcrd.nmempcrd%TYPE --> Empresa
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
    Data    : Junho/2017                       Ultima atualizacao: 09/05/2018
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Atualiza as informações do cartao
                    
    Alteracoes: 27/10/2017 - Efetuar ajustes e melhorias na tela (Lucas Ranghetti #742880)
               
                09/05/2018 - Ajuste realizado para nao mostrar critica indevidamente
                             conforme solicitado no ticket PRB0040037. (Kelvin)
    ............................................................................. */
  
   -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_insitcrd INTEGER;    
    vr_dtsol2vi VARCHAR2(10);
    vr_dssitcrd VARCHAR2(20);
    vr_dssitcrd_ant VARCHAR2(20);
    vr_dssitdec VARCHAR2(20);
    vr_dssitdec_ant VARCHAR2(20);
    vr_nmresadm VARCHAR2(25);
    vr_nmresadm_ant VARCHAR2(25);
    vr_nrdrowid ROWID;  
    vr_flgsegvi BOOLEAN;
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
    vr_dscritic crapcri.dscritic%TYPE;    
    vr_dsderror VARCHAR2(500);
  
    -- Dados do Cartao
    CURSOR cr_crawcrd(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE
                     ,pr_nrcrcard crawcrd.nrcrcard%TYPE
                     ,pr_nrctrcrd crawcrd.nrctrcrd%TYPE) IS
      SELECT crd.nrcctitg 
            ,crd.nrcpftit 
            ,crd.cdadmcrd 
            ,crd.flgdebit 
            ,crd.nmtitcrd 
            ,crd.insitcrd 
            ,crd.insitdec
            ,crd.flgprcrd
            ,crd.dtsol2vi
            ,crd.nmempcrd
        FROM crawcrd crd
       WHERE crd.cdcooper = pr_cdcooper
         AND crd.nrdconta = pr_nrdconta
         AND crd.nrcrcard = pr_nrcrcard
         AND crd.nrctrcrd = pr_nrctrcrd;    
    rw_crawcrd cr_crawcrd%ROWTYPE;
    
    -- Dados do Cartao
    CURSOR cr_crawcrd_tit(pr_cdcooper crapcop.cdcooper%TYPE
                         ,pr_nrdconta crapass.nrdconta%TYPE
                         ,pr_nrcrcard crawcrd.nrcrcard%TYPE
                         ,pr_nrctrcrd crawcrd.nrctrcrd%TYPE) IS
      SELECT crd.nrcctitg 
            ,crd.nrcpftit 
            ,crd.cdadmcrd 
            ,crd.flgdebit 
            ,crd.nmtitcrd 
            ,crd.insitcrd 
            ,crd.insitdec
            ,crd.flgprcrd
            ,crd.dtsol2vi
            ,crd.nmempcrd
            ,ROWID
        FROM crawcrd crd
       WHERE crd.cdcooper = pr_cdcooper
         AND crd.nrdconta = pr_nrdconta
         AND crd.nrcrcard <> pr_nrcrcard
         AND crd.nrctrcrd <> pr_nrctrcrd
         AND crd.cdadmcrd = pr_cdadmcrd
         AND crd.insitcrd NOT IN (5,6)
         AND crd.flgprcrd = 1;    
    rw_crawcrd_tit cr_crawcrd_tit%ROWTYPE;
    
  
    -- Dados do Cartao
    CURSOR cr_crapcrd(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE
                     ,pr_nrcrcard crawcrd.nrcrcard%TYPE
                     ,pr_nrctrcrd crawcrd.nrctrcrd%TYPE) IS
      SELECT crd.nrcpftit 
            ,crd.cdadmcrd 
            ,crd.flgdebit 
            ,crd.nmtitcrd            
        FROM crapcrd crd
       WHERE crd.cdcooper = pr_cdcooper
         AND crd.nrdconta = pr_nrdconta
         AND crd.nrcrcard = pr_nrcrcard
         AND crd.nrctrcrd = pr_nrctrcrd;    
    rw_crapcrd cr_crapcrd%ROWTYPE;
    
    -- Dados da Administradora
    CURSOR cr_crapadc(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_cdadmcrd crawcrd.cdadmcrd%TYPE) IS
    SELECT adm.cdadmcrd, 
           adm.nmresadm
      FROM crapadc adm
     WHERE adm.cdadmcrd = pr_cdadmcrd
       AND adm.cdcooper = pr_cdcooper;
    rw_crapadc cr_crapadc%ROWTYPE;
    
    CURSOR cr_primeiro_cartao_ativo(pr_cdcooper crawcrd.cdcooper%TYPE
		                               ,pr_nrdconta crawcrd.nrdconta%TYPE
										               ,pr_cdadmcrd crawcrd.cdadmcrd%TYPE) IS
			SELECT d.nrctrcrd,
             d.flgprcrd
			  FROM crawcrd d
			 WHERE d.cdcooper = pr_cdcooper
			   AND d.nrdconta = pr_nrdconta
				 AND d.cdadmcrd = pr_cdadmcrd
				 AND d.insitcrd NOT IN (5,6) -- bloqueado,cancelado
  	ORDER BY d.dtpropos ASC;
		rw_primeiro_cartao_ativo cr_primeiro_cartao_ativo%ROWTYPE;
    

  
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
                   ,pr_nrcrcard
                   ,pr_nrctrcrd);
      FETCH cr_crawcrd INTO rw_crawcrd;
    CLOSE cr_crawcrd;    
    
    OPEN cr_crapcrd(vr_cdcooper
                   ,pr_nrdconta
                   ,pr_nrcrcard
                   ,pr_nrctrcrd);
      FETCH cr_crapcrd 
        INTO rw_crapcrd;
    CLOSE cr_crapcrd;
    
    IF pr_insitcrd = 7 THEN
       vr_insitcrd:= 4;
       vr_dtsol2vi:= to_char(SYSDATE,'DD/MM/YYYY');
    ELSE 
       vr_insitcrd:= pr_insitcrd;
       vr_dtsol2vi:= NULL;
    END IF;
    
    OPEN cr_crawcrd_tit(vr_cdcooper
                       ,pr_nrdconta
                       ,pr_nrcrcard
                       ,pr_nrctrcrd);
      FETCH cr_crawcrd_tit INTO rw_crawcrd_tit;
    CLOSE cr_crawcrd_tit;
    
    BEGIN
      UPDATE crawcrd crd
         SET crd.nrcctitg = pr_nrcctitg
            ,crd.nrcpftit = pr_nrcpftit
            ,crd.cdadmcrd = pr_cdadmcrd
            ,crd.flgdebit = pr_flgdebit
            ,crd.nmtitcrd = upper(pr_nmtitcrd)
            ,crd.insitcrd = vr_insitcrd
            ,crd.insitdec = pr_insitdec
            ,crd.dtsol2vi = to_date(nvl(vr_dtsol2vi,''),'dd/mm/rrrr')
            ,crd.flgprcrd = pr_flgprcrd
            ,crd.nmempcrd = upper(pr_nmempres)
       WHERE crd.nrdconta = pr_nrdconta
         AND crd.nrcrcard = pr_nrcrcard
         AND crd.nrctrcrd = pr_nrctrcrd
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
            ,crd.nmtitcrd = upper(pr_nmtitcrd)
       WHERE crd.nrdconta = pr_nrdconta
         AND crd.nrcrcard = pr_nrcrcard
         AND crd.cdcooper = vr_cdcooper;    
    EXCEPTION
      WHEN OTHERS THEN
           vr_dsderror := 'TELA_MANCRD.PC_ATUALIZA_CARTAO: Erro ao atualizar a tabela crapcrd ' || SQLERRM;
           RAISE vr_exc_erro;
    END;
    
    -- Logar alteracao da situacao do cartao
    IF (vr_insitcrd <> rw_crawcrd.insitcrd)  OR
       (pr_insitcrd = 7                     AND 
        vr_insitcrd = 4                     AND 
        vr_dtsol2vi IS NOT NULL             AND 
        rw_crawcrd.dtsol2vi IS NULL)         OR
        (vr_insitcrd = 4                    AND 
         vr_dtsol2vi IS NULL                AND 
         rw_crawcrd.dtsol2vi IS NOT NULL)  THEN
    
      -- Pegar descrição da antiga situação
      IF rw_crawcrd.insitcrd = 4 AND 
         rw_crawcrd.dtsol2vi IS NOT NULL THEN 
         vr_dssitcrd_ant:= 'Sol.2v';
      ELSIF rw_crawcrd.insitcrd = 1 THEN
         vr_dssitcrd_ant:= 'Aprovado';
      ELSIF rw_crawcrd.insitcrd = 2 THEN
         vr_dssitcrd_ant:= 'Solicitado';
      ELSIF rw_crawcrd.insitcrd = 3 THEN
         vr_dssitcrd_ant:= 'Liberado';
      ELSIF rw_crawcrd.insitcrd = 4 THEN   
         vr_dssitcrd_ant:= 'Em Uso';   
      ELSIF rw_crawcrd.insitcrd = 5 THEN
         vr_dssitcrd_ant:= 'Bloqueado';
      ELSIF rw_crawcrd.insitcrd = 6 THEN   
        vr_dssitcrd_ant:= 'Cancelado';         
      ELSIF rw_crawcrd.insitcrd = 9 THEN   
        vr_dssitcrd_ant:= 'Enviado Bancoob';         
      END IF;
      
      -- Buscar descição da nova situação
      IF vr_insitcrd = 4 AND 
         vr_dtsol2vi IS NOT NULL THEN 
         vr_dssitcrd:= 'Sol.2v';
      ELSIF vr_insitcrd = 1 THEN
         vr_dssitcrd:= 'Aprovado';
      ELSIF vr_insitcrd = 2 THEN
         vr_dssitcrd:= 'Solicitado';
      ELSIF vr_insitcrd = 3 THEN
         vr_dssitcrd:= 'Liberado';
      ELSIF vr_insitcrd = 4 THEN   
         vr_dssitcrd:= 'Em Uso';   
      ELSIF vr_insitcrd = 5 THEN
         vr_dssitcrd:= 'Bloqueado';
      ELSIF vr_insitcrd = 6 THEN   
         vr_dssitcrd:= 'Cancelado';         
      ELSIF vr_insitcrd = 9 THEN   
         vr_dssitcrd:= 'Enviado Bancoob';         
      END IF;  
      
      OPEN cr_crapadc(vr_cdcooper, 
                       pr_cdadmcrd);
       FETCH cr_crapadc INTO rw_crapadc;
      CLOSE cr_crapadc;
        
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => '',
                             pr_dsorigem => TRIM(GENE0001.vr_vet_des_origens(vr_idorigem)),
                             pr_dstransa => 'Situacao do Cartao ' || rw_crapadc.nmresadm || ' Final: ' || substr(pr_nrcrcard,-4,4)  ,
                             pr_dttransa => TRUNC(SYSDATE),
                             pr_flgtrans => 1,
                             pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
                             pr_idseqttl => 0,
                             pr_nmdatela => vr_nmdatela,
                             pr_nrdconta => pr_nrdconta,
                             pr_nrdrowid => vr_nrdrowid);
                               
      IF vr_insitcrd = 6  THEN
        
        IF rw_crawcrd.flgprcrd = 1 THEN                 
        
        
          BEGIN
            UPDATE crawcrd crd
               SET flgprcrd = 0
            WHERE crd.nrdconta = pr_nrdconta
              AND crd.nrcrcard = pr_nrcrcard
              AND crd.nrctrcrd = pr_nrctrcrd
              AND crd.cdcooper = vr_cdcooper;  
          EXCEPTION 
            WHEN OTHERS THEN
               vr_dsderror := 'TELA_MANCRD.PC_ATUALIZA_CARTAO: Erro ao atualizar a tabela crawcrd ' || SQLERRM;
               RAISE vr_exc_erro;          
          END; 
            
          OPEN cr_primeiro_cartao_ativo(pr_cdcooper => vr_cdcooper,
                                        pr_nrdconta => pr_nrdconta,
                                        pr_cdadmcrd => pr_cdadmcrd);
          FETCH cr_primeiro_cartao_ativo INTO rw_primeiro_cartao_ativo;
          
          IF cr_primeiro_cartao_ativo%FOUND THEN
            --
            BEGIN
             UPDATE crawcrd d
                SET d.flgprcrd = 1
              WHERE d.cdcooper = vr_cdcooper
                AND d.nrdconta = pr_nrdconta
                AND d.nrctrcrd = rw_primeiro_cartao_ativo.nrctrcrd;
            EXCEPTION
            WHEN OTHERS THEN
               CLOSE cr_primeiro_cartao_ativo;
               vr_dscritic := 'Erro ao vincular novo titular. Erro: '||SQLERRM;
               RAISE vr_exc_erro;
            END;
          END IF;
        
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'nrctrcrd'
                                   ,pr_dsdadant => pr_nrctrcrd
                                   ,pr_dsdadatu => rw_primeiro_cartao_ativo.nrctrcrd); 
                                                                        
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'flgprcrd'
                                   ,pr_dsdadant => rw_primeiro_cartao_ativo.flgprcrd
                                   ,pr_dsdadatu => 1); 
          --
          CLOSE cr_primeiro_cartao_ativo;
            
             
          
        END IF;
        
      

      
                                  
      END IF;
      
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'insitcrd',
                                pr_dsdadant => vr_dssitcrd_ant,
                                pr_dsdadatu => vr_dssitcrd);
    
    END IF;
    
    -- Logar alteracao da situacao do cartao
    IF (pr_insitdec <> rw_crawcrd.insitdec) THEN
    
      -- Pegar descrição da antiga situação
      IF rw_crawcrd.insitdec = 1 THEN 
         vr_dssitdec_ant:= 'Sem aprovacao';
      ELSIF rw_crawcrd.insitdec = 2 THEN
         vr_dssitdec_ant:= 'Aprovada auto';
      ELSIF rw_crawcrd.insitdec = 3 THEN
         vr_dssitdec_ant:= 'Aprovada manual';
      ELSIF rw_crawcrd.insitdec = 4 THEN
         vr_dssitdec_ant:= 'Erro';
      ELSIF rw_crawcrd.insitdec = 5 THEN   
         vr_dssitdec_ant:= 'Rejeitada';
      ELSIF rw_crawcrd.insitdec = 6 THEN
         vr_dssitdec_ant:= 'Refazer';
      ELSIF rw_crawcrd.insitdec = 7 THEN   
         vr_dssitdec_ant:= 'Expirada';
      ELSIF rw_crawcrd.insitdec = 8 THEN   
         vr_dssitdec_ant:= 'Efetivada';
      END IF;
      
      -- Buscar descição da nova situação
      IF pr_insitdec = 1 THEN 
         vr_dssitdec:= 'Sem aprovacao';
      ELSIF pr_insitdec = 2 THEN
         vr_dssitdec:= 'Aprovada auto';
      ELSIF pr_insitdec = 3 THEN
         vr_dssitdec:= 'Aprovada manual';
      ELSIF pr_insitdec = 4 THEN
         vr_dssitdec:= 'Erro';
      ELSIF pr_insitdec = 5 THEN   
         vr_dssitdec:= 'Rejeitada';
      ELSIF pr_insitdec = 6 THEN
         vr_dssitdec:= 'Refazer';
      ELSIF pr_insitdec = 7 THEN   
         vr_dssitdec:= 'Expirada';
      ELSIF pr_insitdec = 8 THEN   
         vr_dssitdec:= 'Efetivada';
      END IF;
      
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => '',
                           pr_dsorigem => TRIM(GENE0001.vr_vet_des_origens(vr_idorigem)),
                           pr_dstransa => 'Decisao Do Cartao',
                           pr_dttransa => TRUNC(SYSDATE),
                           pr_flgtrans => 1,
                           pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
                           pr_idseqttl => 0,
                           pr_nmdatela => vr_nmdatela,
                           pr_nrdconta => pr_nrdconta,
                           pr_nrdrowid => vr_nrdrowid);

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'insitdec',
                                pr_dsdadant => vr_dssitdec_ant,
                                pr_dsdadatu => vr_dssitdec);
    
    END IF;
    
    -- Logar alteração do nome do Plastico
    IF upper(trim(pr_nmtitcrd)) <> upper(trim(rw_crawcrd.nmtitcrd)) THEN
       
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => '',
                           pr_dsorigem => TRIM(GENE0001.vr_vet_des_origens(vr_idorigem)),
                           pr_dstransa => 'Nome do Plastico',
                           pr_dttransa => TRUNC(SYSDATE),
                           pr_flgtrans => 1,
                           pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
                           pr_idseqttl => 0,
                           pr_nmdatela => vr_nmdatela,
                           pr_nrdconta => pr_nrdconta,
                           pr_nrdrowid => vr_nrdrowid);

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'nmtitcrd',
                                pr_dsdadant => upper(rw_crawcrd.nmtitcrd),
                                pr_dsdadatu => upper(pr_nmtitcrd));
    END IF;
    
    -- Logar alterações na função debito
    IF pr_flgdebit <> rw_crawcrd.flgdebit THEN
    
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => '',
                           pr_dsorigem => TRIM(GENE0001.vr_vet_des_origens(vr_idorigem)),
                           pr_dstransa => 'Funcao Debito',
                           pr_dttransa => TRUNC(SYSDATE),
                           pr_flgtrans => 1,
                           pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
                           pr_idseqttl => 0,
                           pr_nmdatela => vr_nmdatela,
                           pr_nrdconta => pr_nrdconta,
                           pr_nrdrowid => vr_nrdrowid);

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'flgdebit',
                                pr_dsdadant => CASE rw_crawcrd.flgdebit 
                                                 WHEN 1 THEN 'Sim' 
                                                 WHEN 0 THEN 'Nao' 
                                               END,
                                pr_dsdadatu => CASE pr_flgdebit 
                                                 WHEN 1 THEN 'Sim' 
                                                 WHEN 0 THEN 'Nao' 
                                               END);
                                
    END IF;
    
    -- Logar alterações de titularidade do cartao
    IF pr_flgprcrd <> rw_crawcrd.flgprcrd THEN
      
      OPEN cr_crapadc(vr_cdcooper, 
                       pr_cdadmcrd);
       FETCH cr_crapadc INTO rw_crapadc;
      CLOSE  cr_crapadc;
      
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => '',
                           pr_dsorigem => TRIM(GENE0001.vr_vet_des_origens(vr_idorigem)),
                           pr_dstransa => 'Titular ' || rw_crapadc.nmresadm || ' Final: ' || substr(pr_nrcrcard,-4,4) ,
                           pr_dttransa => TRUNC(SYSDATE),
                           pr_flgtrans => 1,
                           pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
                           pr_idseqttl => 0,
                           pr_nmdatela => vr_nmdatela,
                           pr_nrdconta => pr_nrdconta,
                           pr_nrdrowid => vr_nrdrowid);
                           
                           
      
      -- tirar a titularidade caso for marcado a titularidade para outro 
      
      IF pr_flgprcrd = 1 THEN
        -- se não for nulo devemos tirar a titularidade deste cartão
        IF rw_crawcrd_tit.rowid IS NOT NULL THEN
          
          BEGIN
            UPDATE crawcrd crd
               SET crd.flgprcrd = 0                  
             WHERE crd.rowid = rw_crawcrd_tit.rowid; 
          EXCEPTION
             WHEN OTHERS THEN
                vr_dsderror := 'TELA_MANCRD.PC_ATUALIZA_CARTAO: Erro ao atualizar a tabela crawcrd ' || SQLERRM;
                RAISE vr_exc_erro;
          END;  
        END IF;
        
       gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'flgprcrd_ant',
                                pr_dsdadant => CASE rw_crawcrd_tit.flgprcrd
                                                 WHEN 1 THEN 'Sim' 
                                                 WHEN 0 THEN 'Nao' 
                                               END,
                                pr_dsdadatu => CASE pr_flgprcrd 
                                                 WHEN 1 THEN 'Sim' 
                                                 WHEN 0 THEN 'Nao' 
                                               END);
                                                 
        
      END IF;
    
    

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'flgprcrd',
                                pr_dsdadant => CASE rw_crawcrd.flgprcrd 
                                                 WHEN 1 THEN 'Sim' 
                                                 WHEN 0 THEN 'Nao' 
                                               END,
                                pr_dsdadatu => CASE pr_flgprcrd 
                                                 WHEN 1 THEN 'Sim' 
                                                 WHEN 0 THEN 'Nao' 
                                               END);
    END IF;
    
    -- Logar alterações do CPF do Cartao
    IF pr_nrcpftit <> rw_crawcrd.nrcpftit THEN
    
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => '',
                           pr_dsorigem => TRIM(GENE0001.vr_vet_des_origens(vr_idorigem)),
                           pr_dstransa => 'CPF',
                           pr_dttransa => TRUNC(SYSDATE),
                           pr_flgtrans => 1,
                           pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
                           pr_idseqttl => 0,
                           pr_nmdatela => vr_nmdatela,
                           pr_nrdconta => pr_nrdconta,
                           pr_nrdrowid => vr_nrdrowid);

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'nrcpftit',
                                pr_dsdadant => rw_crawcrd.nrcpftit,
                                pr_dsdadatu => pr_nrcpftit);
    END IF;
    
    -- Logar alterações da Conta Cartão
    IF pr_nrcctitg <> rw_crawcrd.nrcctitg THEN
     
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => '',
                           pr_dsorigem => TRIM(GENE0001.vr_vet_des_origens(vr_idorigem)),
                           pr_dstransa => 'Conta Cartao',
                           pr_dttransa => TRUNC(SYSDATE),
                           pr_flgtrans => 1,
                           pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
                           pr_idseqttl => 0,
                           pr_nmdatela => vr_nmdatela,
                           pr_nrdconta => pr_nrdconta,
                           pr_nrdrowid => vr_nrdrowid);

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'nrcctitg',
                                pr_dsdadant => rw_crawcrd.nrcctitg,
                                pr_dsdadatu => pr_nrcctitg);
    END IF;
    
    -- Logar alterações na adiministradora
    IF pr_cdadmcrd <> rw_crawcrd.cdadmcrd THEN
    
       -- Buscar descrição da adiministradora alterada
       OPEN cr_crapadc(vr_cdcooper, 
                       pr_cdadmcrd);
       FETCH cr_crapadc INTO rw_crapadc;
       
       IF cr_crapadc%FOUND THEN
         CLOSE cr_crapadc;
         vr_nmresadm:= rw_crapadc.nmresadm;
       ELSE 
         CLOSE cr_crapadc;         
       END IF;
       
       -- Buscar descrição da adiministradora antiga
       OPEN cr_crapadc(vr_cdcooper, 
                       rw_crawcrd.cdadmcrd);
       FETCH cr_crapadc INTO rw_crapadc;
       
       IF cr_crapadc%FOUND THEN
         CLOSE cr_crapadc;
         vr_nmresadm_ant:= rw_crapadc.nmresadm;
       ELSE 
         CLOSE cr_crapadc;         
       END IF;
    
       gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => '',
                           pr_dsorigem => TRIM(GENE0001.vr_vet_des_origens(vr_idorigem)),
                           pr_dstransa => 'Administradora',
                           pr_dttransa => TRUNC(SYSDATE),
                           pr_flgtrans => 1,
                           pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
                           pr_idseqttl => 0,
                           pr_nmdatela => vr_nmdatela,
                           pr_nrdconta => pr_nrdconta,
                           pr_nrdrowid => vr_nrdrowid);

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'cdadmcrd',
                                pr_dsdadant => vr_nmresadm_ant,
                                pr_dsdadatu => vr_nmresadm);
                                
    END IF;    
    
    -- Locar Alterações no nome da empresa
    IF upper(trim(pr_nmempres)) <> upper(trim(rw_crawcrd.nmempcrd)) THEN
    
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => '',
                           pr_dsorigem => TRIM(GENE0001.vr_vet_des_origens(vr_idorigem)),
                           pr_dstransa => 'Empresa do Plastico',
                           pr_dttransa => TRUNC(SYSDATE),
                           pr_flgtrans => 1,
                           pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
                           pr_idseqttl => 0,
                           pr_nmdatela => vr_nmdatela,
                           pr_nrdconta => pr_nrdconta,
                           pr_nrdrowid => vr_nrdrowid);

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'nmempcrd',
                                pr_dsdadant => upper(rw_crawcrd.nmempcrd),
                                pr_dsdadatu => upper(pr_nmempres));  
      
    END IF;
    
    IF pr_nrcpftit <> rw_crapcrd.nrcpftit THEN
    
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => '',
                           pr_dsorigem => TRIM(GENE0001.vr_vet_des_origens(vr_idorigem)),
                           pr_dstransa => 'CPF',
                           pr_dttransa => TRUNC(SYSDATE),
                           pr_flgtrans => 1,
                           pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
                           pr_idseqttl => 0,
                           pr_nmdatela => vr_nmdatela,
                           pr_nrdconta => pr_nrdconta,
                           pr_nrdrowid => vr_nrdrowid);

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'nrcpftit',
                                pr_dsdadant => rw_crapcrd.nrcpftit,
                                pr_dsdadatu => pr_nrcpftit);
    END IF;
    
    -- Logar alterações na adiministradora
    IF pr_cdadmcrd <> rw_crapcrd.cdadmcrd THEN

      -- Buscar descrição da adiministradora alterada
      OPEN cr_crapadc(vr_cdcooper, 
                      pr_cdadmcrd);
      FETCH cr_crapadc INTO rw_crapadc;
         
      IF cr_crapadc%FOUND THEN
        CLOSE cr_crapadc;
        vr_nmresadm:= rw_crapadc.nmresadm;
      ELSE 
        CLOSE cr_crapadc;         
    END IF;
      
      -- Buscar descrição da adiministradora antiga
      OPEN cr_crapadc(vr_cdcooper, 
                      rw_crapcrd.cdadmcrd);
      FETCH cr_crapadc INTO rw_crapadc;
   
      IF cr_crapadc%FOUND THEN
        CLOSE cr_crapadc;
        vr_nmresadm_ant:= rw_crapadc.nmresadm;
      ELSE 
        CLOSE cr_crapadc;         
      END IF;

      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => '',
                           pr_dsorigem => TRIM(GENE0001.vr_vet_des_origens(vr_idorigem)),
                           pr_dstransa => 'Administradora',
                           pr_dttransa => TRUNC(SYSDATE),
                           pr_flgtrans => 1,
                           pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
                           pr_idseqttl => 0,
                           pr_nmdatela => vr_nmdatela,
                           pr_nrdconta => pr_nrdconta,
                           pr_nrdrowid => vr_nrdrowid);

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'cdadmcrd',
                                pr_dsdadant => vr_nmresadm_ant,
                                pr_dsdadatu => vr_nmresadm);
               
    END IF; 
    
    -- Logar alterações na função debito
    IF pr_flgdebit <> rw_crapcrd.flgdebit THEN

      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => '',
                           pr_dsorigem => TRIM(GENE0001.vr_vet_des_origens(vr_idorigem)),
                           pr_dstransa => 'Funcao Debito',
                           pr_dttransa => TRUNC(SYSDATE),
                           pr_flgtrans => 1,
                           pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
                           pr_idseqttl => 0,
                           pr_nmdatela => vr_nmdatela,
                           pr_nrdconta => pr_nrdconta,
                           pr_nrdrowid => vr_nrdrowid);

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'flgdebit',
                                pr_dsdadant => CASE rw_crapcrd.flgdebit 
                                         WHEN 1 THEN 'Sim' 
                                         WHEN 0 THEN 'Nao' 
                                         END,
                                pr_dsdadatu => CASE pr_flgdebit 
                                         WHEN 1 THEN 'Sim' 
                                         WHEN 0 THEN 'Nao' 
                                         END);
                  
    END IF;
    
    IF upper(trim(pr_nmtitcrd)) <> upper(trim(rw_crapcrd.nmtitcrd)) THEN
   
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => '',
                           pr_dsorigem => TRIM(GENE0001.vr_vet_des_origens(vr_idorigem)),
                           pr_dstransa => 'Nome do Plastico',
                           pr_dttransa => TRUNC(SYSDATE),
                           pr_flgtrans => 1,
                           pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
                           pr_idseqttl => 0,
                           pr_nmdatela => vr_nmdatela,
                           pr_nrdconta => pr_nrdconta,
                           pr_nrdrowid => vr_nrdrowid);

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'nmtitcrd',
                                pr_dsdadant => upper(rw_crapcrd.nmtitcrd),
                                pr_dsdadatu => upper(pr_nmtitcrd));
    END IF;   
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
                                    ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Numero do contrato do cartao
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG                            
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
    
      
    CURSOR cr_crawcrd(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE
                     ,pr_nrcrcard crawcrd.nrcrcard%TYPE
                     ,pr_nrctrcrd crawcrd.nrctrcrd%TYPE) IS
      SELECT crd.insitcrd
            ,crd.insitdec
            ,crd.dtsol2vi
        FROM crawcrd crd
       WHERE crd.cdcooper = pr_cdcooper
         AND crd.nrdconta = pr_nrdconta
         AND crd.nrcrcard = pr_nrcrcard
         AND crd.nrctrcrd = pr_nrctrcrd;    
    rw_crawcrd cr_crawcrd%ROWTYPE;
      
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_insitcrd INTEGER;
    vr_nrdrowid ROWID;  
    vr_dssitcrd VARCHAR2(20);
      
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
                   ,pr_nrcrcard
                   ,pr_nrctrcrd);
      FETCH cr_crawcrd INTO rw_crawcrd;
    CLOSE cr_crawcrd;
       
    IF rw_crawcrd.insitcrd <> 2 THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Cartao deve estar com o status Solicitado para reenvio.';
      RAISE vr_exc_erro;        
    ELSIF rw_crawcrd.insitdec NOT IN (2,3) THEN
      vr_cdcritic := 0;
      vr_dscritic := 'A Situacao de Decisao do Cartao precisa ser 2 - Aprovada Auto ou 3 - Aprovada Manual!';
      RAISE vr_exc_erro;        
    ELSE
      UPDATE crawcrd crd
         SET crd.insitcrd = 1
       WHERE crd.cdcooper = vr_cdcooper
         AND crd.nrdconta = pr_nrdconta
         AND crd.nrcrcard = pr_nrcrcard
         AND crd.nrctrcrd = pr_nrctrcrd 
         RETURNING insitcrd INTO vr_insitcrd;
    END IF;
    
    -- Gerar log caso tenha reenviado a solicitação
    IF vr_insitcrd <> rw_crawcrd.insitcrd THEN
       
      IF rw_crawcrd.insitcrd = 4 AND 
         rw_crawcrd.dtsol2vi IS NOT NULL THEN 
         vr_dssitcrd:= 'Sol.2v';
      ELSIF rw_crawcrd.insitcrd = 1 THEN
        vr_dssitcrd:= 'Aprovado';
      ELSIF rw_crawcrd.insitcrd = 2 THEN
        vr_dssitcrd:= 'Solicitado';
      ELSIF rw_crawcrd.insitcrd = 3 THEN
        vr_dssitcrd:= 'Liberado';
      ELSIF rw_crawcrd.insitcrd = 4 THEN
        vr_dssitcrd:= 'Em Uso';
      ELSIF rw_crawcrd.insitcrd = 5 THEN
        vr_dssitcrd:= 'Bloqueado';
      ELSIF rw_crawcrd.insitcrd = 6 THEN
        vr_dssitcrd:= 'Cancelado';
      ELSIF rw_crawcrd.insitcrd = 9 THEN
        vr_dssitcrd:= 'Enviado Bancoob';
      END IF;
    
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => '',
                           pr_dsorigem => TRIM(GENE0001.vr_vet_des_origens(vr_idorigem)),
                           pr_dstransa => 'Reenviar Solicitacao do Cartao',
                           pr_dttransa => TRUNC(SYSDATE),
                           pr_flgtrans => 1,
                           pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
                           pr_idseqttl => 0,
                           pr_nmdatela => vr_nmdatela,
                           pr_nrdconta => pr_nrdconta,
                           pr_nrdrowid => vr_nrdrowid);

        -- Situacao do cartao
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'insitcrd',
                                  pr_dsdadant => vr_dssitcrd,
                                  pr_dsdadatu => 'Aprovado');
    
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

PROCEDURE pc_valida_atualiza_cartoes(pr_nrdconta IN crapass.nrdconta%TYPE --> Numero de conta
                                    ,pr_nrcrcard IN crapcrd.nrcrcard%TYPE --> Numero do cartao
                                    ,pr_nrcctitg IN crawcrd.nrcctitg%TYPE --> Conta cartao
                                    ,pr_nrcpftit IN crawcrd.nrcpftit%TYPE --> CPF do cartao
                                    ,pr_cdadmcrd IN crawcrd.cdadmcrd%TYPE --> Administradora
                                    ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Contrato do cartao
                                    ,pr_flgprcrd IN crawcrd.flgprcrd%TYPE --> Flag primeiro cartão                                   
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG                            
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica 
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica                                    
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_valida_atualiza_cartoes
    Sistema : Ayllos Web
    Autor   : Alcemir Jr (Ailos)
    Data    : Junho/2017                       Ultima atualizacao: 27/10/2017
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : validar atualização do cartão
                    
    Alteracoes: 
    ............................................................................. */
    
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    -- Dados do Cartao
    CURSOR cr_crawcrd(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE
                     ,pr_nrcrcard crawcrd.nrcrcard%TYPE
                     ,pr_nrctrcrd crawcrd.nrctrcrd%TYPE) IS
      SELECT crd.nrcctitg 
            ,crd.nrcpftit 
            ,crd.cdadmcrd 
            ,crd.flgdebit 
            ,crd.nmtitcrd 
            ,crd.insitcrd 
            ,crd.insitdec
            ,crd.flgprcrd
            ,crd.dtsol2vi
            ,crd.nmempcrd
        FROM crawcrd crd
       WHERE crd.cdcooper = pr_cdcooper
         AND crd.nrdconta = pr_nrdconta
         AND crd.nrcrcard = pr_nrcrcard
         AND crd.nrctrcrd = pr_nrctrcrd;    
    rw_crawcrd cr_crawcrd%ROWTYPE;
    
      -- Dados do Cartao
    CURSOR cr_crawcrd_val(pr_cdcooper crapcop.cdcooper%TYPE
                         ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT 
             substr(crd.nrcrcard,-4,4) fimcrd,
             crd.nrcpftit
        FROM crawcrd crd
       WHERE crd.cdcooper = pr_cdcooper
         AND crd.nrdconta = pr_nrdconta
         AND crd.flgprcrd = 1
         AND crd.cdadmcrd = pr_cdadmcrd
         AND crd.nrctrcrd <> pr_nrctrcrd
         AND crd.insitcrd NOT IN (5,6);    
    rw_crawcrd_val cr_crawcrd_val%ROWTYPE; 
    
    -- Dados do Cartao
    CURSOR cr_crawcrd_val1(pr_cdcooper crapcop.cdcooper%TYPE
                         ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT 
             substr(crd.nrcrcard,-4,4) fimcrd,
             crd.nrcpftit
        FROM crawcrd crd
       WHERE crd.cdcooper = pr_cdcooper
         AND crd.nrdconta = pr_nrdconta
         AND crd.flgprcrd = 1
         AND crd.cdadmcrd = pr_cdadmcrd
         AND crd.insitcrd NOT IN (5,6);    
    rw_crawcrd_val1 cr_crawcrd_val1%ROWTYPE; 
        
    
    -- Dados da Administradora
    CURSOR cr_crapadc(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_cdadmcrd crawcrd.cdadmcrd%TYPE) IS
    SELECT adm.cdadmcrd, 
           adm.nmresadm
      FROM crapadc adm
     WHERE adm.cdadmcrd = pr_cdadmcrd
       AND adm.cdcooper = pr_cdcooper;
    rw_crapadc cr_crapadc%ROWTYPE;
    
    -- cooperado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE
                      ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
        AND  ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    -- titular
    CURSOR cr_crapttl (pr_nrcpftit crapttl.nrcpfcgc%TYPE
                      ,pr_cdcooper crapttl.cdcooper%TYPE
                      ,pr_nrdconta crapttl.nrdconta%TYPE) IS
      SELECT t.idseqttl FROM crapttl t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta
         AND t.nrcpfcgc = pr_nrcpftit;
    rw_crapttl cr_crapttl%ROWTYPE; 

    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
          
    --Controle de erro
    vr_exc_erro EXCEPTION;
    vr_exc_saida EXCEPTION;
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
        
    OPEN cr_crawcrd(vr_cdcooper
                   ,pr_nrdconta
                   ,pr_nrcrcard
                   ,pr_nrctrcrd);
      FETCH cr_crawcrd INTO rw_crawcrd;
    CLOSE cr_crawcrd;    
    
    OPEN cr_crapass(vr_cdcooper
                   ,pr_nrdconta);
      FETCH cr_crapass 
        INTO rw_crapass;
    CLOSE cr_crapass;
        
    
    IF pr_flgprcrd <> rw_crawcrd.flgprcrd THEN
      
      -- se for desmarcar a titularidade
      -- verificar se e
      IF pr_flgprcrd = 0 THEN
           
        OPEN cr_crawcrd_val(vr_cdcooper
                           ,pr_nrdconta);
         FETCH cr_crawcrd_val INTO rw_crawcrd_val;       
        CLOSE cr_crawcrd_val;  
        
        IF rw_crawcrd_val.nrcpftit IS NULL THEN
          vr_dscritic := 'Nao sera possivel desmarcar a titularidade deste cartao, a conta ficara sem titular para esta administradora.';
          RAISE vr_exc_erro;  
        END IF;
             
      END IF;
        
      IF rw_crapass.inpessoa <> 1 THEN -- PJ
                    
        IF pr_flgprcrd = 1 THEN   
         
         OPEN cr_crawcrd_val1(vr_cdcooper
                           ,pr_nrdconta);
          FETCH cr_crawcrd_val1 INTO rw_crawcrd_val1;       
         CLOSE cr_crawcrd_val1;  
         
         IF rw_crawcrd_val1.nrcpftit IS NOT NULL THEN                      
           vr_dscritic := 'A titularidade atual esta para o cartao com o final: ' || rw_crawcrd_val1.fimcrd ||
                          ' CPF: ' || rw_crawcrd_val1.nrcpftit || '. Esta sendo alterado para o cartao final: ' || substr(pr_nrcrcard,-4,4) ||
                          ' CPF: ' || pr_nrcpftit || '. Deseja continuar?';
           RAISE vr_exc_saida;             
         END IF;  
         
        END IF;
        
      ELSE -- senão é PF
        
        OPEN cr_crapttl(pr_nrcpftit
                       ,vr_cdcooper
                       ,pr_nrdconta);
          FETCH cr_crapttl INTO rw_crapttl;
        CLOSE cr_crapttl;
        
        IF rw_crapttl.idseqttl <> 1 THEN
          vr_dscritic := 'Nao e possivel alterar a titularidade, pois este CPF nao e o titular da conta.';   
          RAISE vr_exc_erro;          
        END IF;
      END IF;
        
    END IF;
            
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_saida THEN 
      -- Retorno  OK          
      pr_des_erro := 'OK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := 0;
      
      pr_dscritic := NULL;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> 
                                        <root>
                                          <dados>' || 
                                           '<msg>' || vr_dscritic || '</msg>' ||
                                           '</dados>                                     
                                        </root>'); 
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
      pr_dscritic := pr_dscritic || ' Erro na TELA_MANCRD.PC_VALIDA_ATUALIZA_CARTOES: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> 
                                        <Root>
                                          <Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro>
                                        </Root>');
    
  END pc_valida_atualiza_cartoes;
    
END TELA_MANCRD;
/
