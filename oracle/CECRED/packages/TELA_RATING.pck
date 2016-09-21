CREATE OR REPLACE PACKAGE CECRED.TELA_RATING AS
---------------------------------------------------------------------------------------------------------------
--
--    Programa: TELA_RATING
--    Autor   : Jonathan
--    Data    : Janeiro/2016                   Ultima Atualizacao:   /  /    
--
--    Dados referentes ao programa:
--
--    Objetivo  : BO ref. a Mensageria da tela RATING 
--
--    Alteracoes: 
--    
---------------------------------------------------------------------------------------------------------------
  
  /* Rotina para buscar os rating do cooperado */
  PROCEDURE pc_busca_rating(pr_cddopcao  IN crapace.cddopcao%TYPE --> Opcao da tela
                           ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta 
                           ,pr_nrregist IN INTEGER                --> Número de registros
                           ,pr_nriniseq IN INTEGER                --> Número sequencial 
                           ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                           ,pr_des_erro OUT VARCHAR2);          --> Saida OK/NOK                                  
  
  /* Rotina para gerar o ralatorio com os rating do cooperado */
  PROCEDURE pc_gera_rel_rating(pr_cddopcao  IN crapace.cddopcao%TYPE --> Opcao da tela
                              ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta                              
                              ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2);          --> Saida OK/NOK   
                              
  /* Rotina para gravar os rating do cooperado */
  PROCEDURE pc_gravar_rating(pr_cddopcao IN crapace.cddopcao%TYPE --> Opcao da tela
                            ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta 
                            ,pr_vlrating IN VARCHAR2              --> Ratings
                            ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                            ,pr_des_erro OUT VARCHAR2);          --> Saida OK/NOK                                

END TELA_RATING;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_RATING AS
---------------------------------------------------------------------------------------------------------------
--
--    Programa: TELA_RATING
--    Autor   : Jonathan
--    Data    : Janeiro/2016                   Ultima Atualizacao: 05/04/2016  
--
--    Dados referentes ao programa:
--
--    Objetivo  : BO ref. a Mensageria da tela RATING
--
--    Alteracoes: 05/04/2016 - Ajuste para retirar o "*" ao remover o arquivo
--                             (Adriano).                              
--    
---------------------------------------------------------------------------------------------------------------
  /* Rotina para buscar os rating do cooperado */
  PROCEDURE pc_busca_rating(pr_cddopcao IN crapace.cddopcao%TYPE --> Opcao da tela
                           ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                           ,pr_nrregist IN INTEGER                --> Número de registros
                           ,pr_nriniseq IN INTEGER                --> Número sequencial 
                           ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                           ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_busca_rating
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jonathan
    Data    : Janeiro/2016                       Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar o rating do cooperado

    Alteracoes:   
    ............................................................................. */
      
      -- Busca dos dados do associado
      CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.nrdconta
            ,ass.cdcooper 
            ,ass.cdagenci
            ,ass.inpessoa           
       FROM crapass ass
      WHERE ass.cdcooper = pr_cdcooper
        AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE; 
            
     --Buscas as Notas do rating por contrato do cooperado
     CURSOR cr_crapnrc(pr_cdcooper IN crapnrc.cdcooper%TYPE
                      ,pr_nrdconta IN crapnrc.nrdconta%TYPE)IS
     SELECT crapnrc.dtmvtolt
           ,crapnrc.nrnotrat
           ,crapnrc.indrisco
           ,crapnrc.flgativo
      FROM crapnrc
     WHERE crapnrc.cdcooper = pr_cdcooper
       AND crapnrc.nrdconta = pr_nrdconta
       AND crapnrc.tpctrrat = 0
       AND crapnrc.nrctrrat = 0;
     rw_crapnrc cr_crapnrc%ROWTYPE;
           
     --Encontra os itens de rating
     CURSOR cr_rating(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_inpessoa IN crapass.inpessoa%TYPE) IS
     SELECT craptor.progress_recid progress_recid_tor               
           ,craptor.nrtopico
           ,craptor.dstopico      
           ,crapitr.progress_recid progress_recid_itr           
           ,crapitr.nritetop           
           ,crapitr.pesoitem          
           ,crapitr.dsitetop 
           ,crapsir.dsseqite
           ,crapsir.progress_recid progress_recid_sir
           ,crapsir.nrseqite           
           ,crapsir.pesosequ    
           ,row_number() over (partition by craptor.nrtopico, crapitr.nritetop
                               order by craptor.nrtopico, crapitr.nritetop ) nrreg 
           ,(SELECT COUNT(*) 
               FROM crapsir 
              WHERE crapsir.cdcooper = crapitr.cdcooper
                AND crapsir.nrtopico = crapitr.nrtopico
                AND crapsir.nritetop = crapitr.nritetop) qtdMax
      FROM craptor
          ,crapitr
          ,crapsir
     WHERE craptor.cdcooper = pr_cdcooper
       AND craptor.nrtopico >= 0
       AND craptor.inpessoa = pr_inpessoa
       AND craptor.flgativo = 1
       AND crapitr.cdcooper = craptor.cdcooper       
       AND crapitr.nrtopico = craptor.nrtopico
       AND crapsir.cdcooper = crapitr.cdcooper
       AND crapsir.nrtopico = crapitr.nrtopico
       AND crapsir.nritetop = crapitr.nritetop;  
     rw_rating cr_rating%ROWTYPE;
     
     --Encontra os rating selecionados do cooperado
     CURSOR cr_crapras(pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE
                      ,pr_nrtopico IN crapras.nrtopico%TYPE
                      ,pr_nritetop IN crapras.nritetop%TYPE
                      ,pr_nrseqite IN crapras.nrseqite%TYPE)IS
     SELECT crapras.cdcooper
      FROM crapras
     WHERE crapras.cdcooper = pr_cdcooper
       AND crapras.nrdconta = pr_nrdconta
       AND crapras.nrctrrat = 0
       AND crapras.tpctrrat = 0
       AND crapras.nrtopico = pr_nrtopico
       AND crapras.nritetop = pr_nritetop
       AND crapras.nrseqite = pr_nrseqite;
     rw_crapras cr_crapras%ROWTYPE;
     
     --Tabela de Erros
     vr_tab_erro gene0001.typ_tab_erro;
    
     vr_cdcritic crapcri.cdcritic%TYPE;
     vr_dscritic crapcri.dscritic%TYPE;
     
     --Variáveis auxiliares
     vr_nrregist  INTEGER; 
     vr_qtregist  INTEGER := 0;
     vr_vltotnota NUMBER(25,2);
     vr_vlrnota   NUMBER(25,2);
     vr_contador  INTEGER := 0;    
     vr_subtopico INTEGER := 0;
     
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
      
    BEGIN
           
      pr_des_erro := 'NOK';
      vr_nrregist := pr_nrregist;
      
      --Limpar tabela dados      
      vr_tab_erro.DELETE;
      
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
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'RATING'
                                ,pr_action => null);  
        
      -- Verifica se o associado existe
      OPEN cr_crapass (pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
                      
      FETCH cr_crapass INTO rw_crapass;
      
      -- Se nao encontrar
      IF cr_crapass%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapass;
        
        -- Montar mensagem de critica
        vr_cdcritic := 9;
        
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
        --Campo com critica
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
          
      ELSE
          
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapass;        
        
      END IF;
      
      OPEN cr_crapnrc(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
                     
      FETCH cr_crapnrc INTO rw_crapnrc;
      
      IF cr_crapnrc%NOTFOUND THEN
        
        --Fecha o cursor
        CLOSE cr_crapnrc;
        
        --Monta mensagem de erro
        vr_cdcritic := 0;
        vr_dscritic := 'Rating nao existente para este cooperado(a).';
        
        RAISE vr_exc_erro;
      
      ELSE
        
        --Fecha o cursor
        CLOSE cr_crapnrc;
        
        IF rw_crapnrc.flgativo = 0 THEN
          
          --Monta mensagem de erro
          vr_cdcritic := 0;
          vr_dscritic := 'Este Rating esta desativado. Utilize a tela ATURAT.';
        
          RAISE vr_exc_erro;
        
        END IF;
        
      END IF; 
     
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?>' ||
                                        '<dados dtmvtolt="' || to_char(rw_crapnrc.dtmvtolt,'dd/mm/RRRR') || '" nrnotrat="' || to_char(rw_crapnrc.nrnotrat,'fm99999g999g990d00') || '" indrisco="' || rw_crapnrc.indrisco || '"/>');
              
      FOR rw_rating IN cr_rating(pr_cdcooper => rw_crapass.cdcooper 
                                ,pr_inpessoa => rw_crapass.inpessoa) LOOP  
                    
        --Incrementar contador
        vr_qtregist:= nvl(vr_qtregist,0) + 1;
            
        -- controles da paginacao 
        IF (vr_qtregist < pr_nriniseq) OR
           (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN

          --Proximo
          CONTINUE;  
                
        END IF; 
            
        IF vr_nrregist >= 1 THEN            
                       
          -- Se for o primeiro item do subitem
          IF rw_rating.nrreg = 1 THEN

            -- Incrementa o contador           
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dados', pr_posicao => 0, pr_tag_nova => 'topico', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
                      
          END IF;   
         
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'topico', pr_posicao => vr_subtopico, pr_tag_nova => 'rating', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating', pr_posicao => vr_contador, pr_tag_nova => 'nrsequen', pr_tag_cont => TRIM(rw_rating.nrtopico) || '.' ||
                                                                                                                                                   TRIM(rw_rating.nritetop) || '.' ||
                                                                                                                                                   TRIM(rw_rating.nrseqite), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating', pr_posicao => vr_contador, pr_tag_nova => 'dsseqite', pr_tag_cont => rw_rating.dsseqite, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating', pr_posicao => vr_contador, pr_tag_nova => 'dstopico', pr_tag_cont => rw_rating.dstopico, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating', pr_posicao => vr_contador, pr_tag_nova => 'dsitetop', pr_tag_cont => rw_rating.dsitetop, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating', pr_posicao => vr_contador, pr_tag_nova => 'reg_craptor', pr_tag_cont => rw_rating.progress_recid_tor, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating', pr_posicao => vr_contador, pr_tag_nova => 'reg_crapitr', pr_tag_cont => rw_rating.progress_recid_itr, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating', pr_posicao => vr_contador, pr_tag_nova => 'reg_crapsir', pr_tag_cont => rw_rating.progress_recid_sir, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating', pr_posicao => vr_contador, pr_tag_nova => 'nota', pr_tag_cont => To_Char((rw_rating.pesoitem * rw_rating.pesosequ),'fm999g999g999g990d00'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating', pr_posicao => vr_contador, pr_tag_nova => 'nrtopico', pr_tag_cont => rw_rating.nrtopico, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating', pr_posicao => vr_contador, pr_tag_nova => 'nritetop', pr_tag_cont => rw_rating.nritetop, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating', pr_posicao => vr_contador, pr_tag_nova => 'nrseqite', pr_tag_cont => rw_rating.nrseqite, pr_des_erro => vr_dscritic);
                                                            
          OPEN cr_crapras(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrtopico => rw_rating.nrtopico
                         ,pr_nritetop => rw_rating.nritetop
                         ,pr_nrseqite => rw_rating.nrseqite);
                           
          FETCH cr_crapras INTO rw_crapras;
            
          IF cr_crapras%NOTFOUND THEN             
              
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating', pr_posicao => vr_contador, pr_tag_nova => 'selecionado', pr_tag_cont => '0', pr_des_erro => vr_dscritic); 
                                          
            vr_vlrnota := 0;
            
          ELSE           
              
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating', pr_posicao => vr_contador, pr_tag_nova => 'selecionado', pr_tag_cont => '1', pr_des_erro => vr_dscritic); 
                                              
            vr_vlrnota := rw_rating.pesoitem * rw_rating.pesosequ;
              
          END IF;  
            
          --Fecha o cursor
          CLOSE cr_crapras;
            
          vr_vltotnota := vr_vltotnota + vr_vlrnota;
          
          --Diminuir registros
          vr_nrregist:= nvl(vr_nrregist,0) - 1;
          
        END IF;         
        
        vr_contador := vr_contador + 1;     
        
        IF  rw_rating.nrreg = rw_rating.qtdmax THEN
                  
         vr_subtopico := vr_subtopico + 1;    
          
                   
        END IF;
                    
      END LOOP;      
        
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml          --> XML que irá receber o novo atributo
                               ,pr_tag   => 'dados'             --> Nome da TAG XML
                               ,pr_atrib => 'qtregist'          --> Nome do atributo
                               ,pr_atval => vr_qtregist         --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;         
            
      pr_des_erro := 'OK';      
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                       
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na TELA_RATING.pc_busca_rating --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');        
        
  END pc_busca_rating;
 
  /* Rotina para gravar os rating do cooperado */
  PROCEDURE pc_gravar_rating(pr_cddopcao IN crapace.cddopcao%TYPE --> Opcao da tela
                            ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta 
                            ,pr_vlrating IN VARCHAR2              --> Ratings
                            ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                            ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_gravar_rating
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jonathan
    Data    : Fevereiro/2016                       Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para gravar o rating do cooperado

    Alteracoes:   
    ............................................................................. */
      
     -- Busca dos dados do associado
      CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.nrdconta
            ,ass.cdcooper 
            ,ass.cdagenci
            ,ass.inpessoa           
       FROM crapass ass
      WHERE ass.cdcooper = pr_cdcooper
        AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;  
     
     CURSOR cr_rating(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_inpessoa IN crapass.inpessoa%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE)IS
     SELECT crapsir.dsseqite
           ,crapsir.progress_recid progress_recid_sir
           ,crapitr.progress_recid progress_recid_itr
           ,craptor.progress_recid progress_recid_tor               
           ,craptor.nrtopico
           ,craptor.dstopico
           ,crapitr.nritetop
           ,crapsir.nrseqite
           ,crapitr.pesoitem
           ,crapsir.pesosequ
           ,crapitr.dsitetop
      FROM crapsir
          ,craptor
          ,crapitr
     WHERE craptor.cdcooper = pr_cdcooper       
       AND craptor.inpessoa = pr_inpessoa
       AND craptor.flgativo = 1 
       AND crapitr.cdcooper = craptor.cdcooper       
       AND crapitr.nrtopico = craptor.nrtopico
       AND crapsir.cdcooper = crapitr.cdcooper
       AND crapsir.nrtopico = crapitr.nrtopico
       AND crapsir.nritetop = crapitr.nritetop;
     rw_rating cr_rating%ROWTYPE;  
     
     CURSOR cr_crapras(pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE
                      ,pr_nrtopico IN crapras.nrtopico%TYPE
                      ,pr_nritetop IN crapras.nritetop%TYPE)IS 
     SELECT crapras.cdcooper
       FROM crapras
      WHERE crapras.cdcooper = pr_cdcooper
        AND crapras.nrdconta = pr_nrdconta
        AND crapras.nrctrrat = 0
        AND crapras.tpctrrat = 0 
        AND crapras.nrtopico = pr_nrtopico
        AND crapras.nritetop = pr_nritetop;
     rw_crapras cr_crapras%ROWTYPE;
     
     CURSOR cr_craptor (pr_progress_recid IN craptor.progress_recid%TYPE)IS
     SELECT craptor.nrtopico
       FROM craptor
      WHERE craptor.progress_recid = pr_progress_recid;
     rw_craptor cr_craptor%ROWTYPE;
     
     CURSOR cr_crapitr (pr_progress_recid IN crapitr.progress_recid%TYPE)IS
     SELECT crapitr.nritetop
           ,crapitr.pesoitem
       FROM crapitr
      WHERE crapitr.progress_recid = pr_progress_recid;
     rw_crapitr cr_crapitr%ROWTYPE;
     
     CURSOR cr_crapsir (pr_progress_recid IN crapsir.progress_recid%TYPE)IS
     SELECT crapsir.nrseqite
           ,crapsir.pesosequ
       FROM crapsir
      WHERE crapsir.progress_recid = pr_progress_recid;
     rw_crapsir cr_crapsir%ROWTYPE;
     
     CURSOR cr_crapnrc(pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE)IS
     SELECT crapnrc.cdcooper
       FROM crapnrc
      WHERE crapnrc.cdcooper = pr_cdcooper
        AND crapnrc.nrdconta = pr_nrdconta
        AND crapnrc.tpctrrat = 0
        AND crapnrc.nrctrrat = 0
        FOR UPDATE NOWAIT;
     rw_crapnrc cr_crapnrc%ROWTYPE;     
     
     CURSOR cr_craptab(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
     SELECT craptab.dstextab
       FROM craptab
      WHERE craptab.cdcooper = pr_cdcooper
        AND craptab.nmsistem = 'CRED'
        AND craptab.tptabela = 'GENERI'
        AND craptab.cdempres = 00
        AND craptab.cdacesso = 'PROVISAOCL';
     rw_craptab cr_craptab%ROWTYPE;
     
     --Tabela de Erros
     vr_tab_erro gene0001.typ_tab_erro;
    
     vr_cdcritic crapcri.cdcritic%TYPE;
     vr_dscritic crapcri.dscritic%TYPE;
     
     --Variáveis auxiliares 
     vr_des_reto  VARCHAR2(3);       
     vr_vltotnota NUMBER(25,2);
     vr_split     gene0002.typ_split := gene0002.typ_split();
     vr_reg_craptor craptor.progress_recid%TYPE;
     vr_reg_crapitr crapitr.progress_recid%TYPE;
     vr_reg_crapsir crapsir.progress_recid%TYPE;
     vr_selecionado INTEGER;
     vr_inusatab    BOOLEAN;
     vr_incompleto  BOOLEAN;
     vr_vlutiliz    NUMBER;
     vr_risco       VARCHAR(4);
     
     --Registro do tipo calendario
     rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
     
     -- Variável exceção para locke
     vr_exc_locked EXCEPTION;
     PRAGMA EXCEPTION_INIT(vr_exc_locked, -54);
     
     --> Tabela de retorno do operadores que estao alocando a tabela especifidada
     vr_tab_locktab GENE0001.typ_tab_locktab;
      
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
      
    BEGIN
           
      pr_des_erro := 'NOK';
      
      --Limpar tabela dados      
      vr_tab_erro.DELETE;
      
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
        
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'RATING'
                                ,pr_action => null);
                                
      -- Verifica se a cooperativa esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        
        RAISE vr_exc_erro;
        
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
        
      END IF;
       
      -- Verifica se o associado existe
      OPEN cr_crapass (pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
                      
      FETCH cr_crapass INTO rw_crapass;
      
      -- Se nao encontrar
      IF cr_crapass%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapass;
        
        -- Montar mensagem de critica
        vr_cdcritic := 9;
        
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
        --Campo com critica
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
          
      ELSE
          
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapass;        
       
      END IF;
       
      BEGIN
        DELETE crapras
         WHERE crapras.cdcooper = vr_cdcooper
           AND crapras.nrdconta = pr_nrdconta
           AND crapras.nrctrrat = 0
           AND crapras.tpctrrat = 0;
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de erro
          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi possivel eliminar os rating do cooperado(a).';
        
          RAISE vr_exc_erro;
          
      END;
             
      -- Quebrar valores da lista recebida como parametro
      IF TRIM(pr_vlrating) IS NOT NULL THEN
        vr_split := gene0002.fn_quebra_string(pr_string  => pr_vlrating
                                            , pr_delimit => '#');
        -- ler linhas
        FOR i IN vr_split.first..vr_split.last LOOP
                                                   
          vr_reg_craptor := ( gene0002.fn_busca_entrada( pr_postext => 2
                                                   ,pr_dstext  => vr_split(i)
                                                   ,pr_delimitador => '|'));
          
          vr_reg_crapitr := ( gene0002.fn_busca_entrada( pr_postext => 3
                                                   ,pr_dstext  => vr_split(i)
                                                   ,pr_delimitador => '|'));
                                                   
          vr_reg_crapsir := ( gene0002.fn_busca_entrada( pr_postext => 4
                                                   ,pr_dstext  => vr_split(i)
                                                   ,pr_delimitador => '|'));      
                                                   
          vr_selecionado := ( gene0002.fn_busca_entrada( pr_postext => 5
                                                   ,pr_dstext  => vr_split(i)
                                                   ,pr_delimitador => '|'));                                                                                      
                                                 
          OPEN cr_craptor(pr_progress_recid => vr_reg_craptor);
          
          FETCH cr_craptor INTO rw_craptor;
          
          IF cr_craptor%NOTFOUND THEN
            
            --Fecha o cursor
            CLOSE cr_craptor; 
            
            --Monta mensagem de critica
            vr_cdcritic := 0;
            vr_dscritic := 'Topicos do rating nao encontrado.'; 
            
          ELSE
            
            --Fecha o cursor
            CLOSE cr_craptor;
          
          END IF;
          
          OPEN cr_crapitr(pr_progress_recid => vr_reg_crapitr);
          
          FETCH cr_crapitr INTO rw_crapitr;
          
          IF cr_crapitr%NOTFOUND THEN
            
            --Fecha o cursor
            CLOSE cr_crapitr; 
            
            --Monta mensagem de critica
            vr_cdcritic := 0;
            vr_dscritic := 'Itens do rating nao encontrado.'; 
            
          ELSE
            
            --Fecha o cursor
            CLOSE cr_crapitr;
          
          END IF;
          
          OPEN cr_crapsir(pr_progress_recid => vr_reg_crapsir);
          
          FETCH cr_crapsir INTO rw_crapsir;
          
          IF cr_crapsir%NOTFOUND THEN
            
            --Fecha o cursor
            CLOSE cr_crapsir;  
            
            --Monta mensagem de critica
            vr_cdcritic := 0;
            vr_dscritic := 'Sequencia dos itens do rating nao encontrado.'; 
            
          ELSE
            
            --Fecha o cursor
            CLOSE cr_crapsir;
          
          END IF;  
          
          IF NVL(vr_selecionado,0) = 1 THEN
            
            BEGIN
              
              INSERT INTO crapras (crapras.cdcooper
                                  ,crapras.nrdconta
                                  ,crapras.nrctrrat
                                  ,crapras.tpctrrat
                                  ,crapras.nrtopico
                                  ,crapras.nritetop
                                  ,crapras.nrseqite)
                          VALUES (vr_cdcooper
                                 ,pr_nrdconta
                                 ,0
                                 ,0
                                 ,rw_craptor.nrtopico
                                 ,rw_crapitr.nritetop
                                 ,rw_crapsir.nrseqite);
                                 
              vr_vltotnota := NVL(vr_vltotnota,0) + (rw_crapitr.pesoitem * rw_crapsir.pesosequ);
              
            EXCEPTION
              WHEN OTHERS THEN
                --Monta mensagem de critica
                vr_cdcritic := 0;
                vr_dscritic := 'Nao foi criar registros de rating.' || SQLERRM;
                
                --Gera exceção
                RAISE vr_exc_erro;
            
            END;
          
          END IF;
                                                
                                                   
        END LOOP;
        
      END IF;
                                       
      FOR rw_craptab IN cr_craptab(pr_cdcooper => vr_cdcooper) LOOP        
                                     
        IF rw_crapass.inpessoa = 1 THEN
          
          IF vr_vltotnota >= TO_NUMBER(SUBSTR(rw_craptab.dstextab,27,6)) AND
             vr_vltotnota <= TO_NUMBER(SUBSTR(rw_craptab.dstextab,34,6)) THEN
            
            vr_risco := TRIM(SUBSTR(rw_craptab.dstextab,8,3));
            
            IF vr_risco = 'A' THEN
              
              vr_risco := 'AA';
            
            END IF;
        
          END IF;
        
        ELSE
          
          IF vr_vltotnota >= TO_NUMBER(SUBSTR(rw_craptab.dstextab,57,6)) AND
             vr_vltotnota <= TO_NUMBER(SUBSTR(rw_craptab.dstextab,64,6)) THEN
             
            vr_risco := TRIM(SUBSTR(rw_craptab.dstextab,8,3));
            
            IF vr_risco = 'A' THEN
              
              vr_risco := 'AA';
            
            END IF;
                                
          END IF;
          
        END IF;
      
      END LOOP;               
       
      vr_incompleto := TRUE;  
                                    
      FOR rw_rating IN cr_rating(pr_cdcooper => rw_crapass.cdcooper
                                ,pr_inpessoa => rw_crapass.inpessoa
                                ,pr_nrdconta => rw_crapass.nrdconta) LOOP
           
        OPEN cr_crapras(pr_cdcooper => rw_crapass.cdcooper
                       ,pr_nrdconta => rw_crapass.nrdconta
                       ,pr_nrtopico => rw_rating.nrtopico
                       ,pr_nritetop => rw_rating.nritetop);
                      
        FETCH cr_crapras INTO rw_crapras;
      
        IF cr_crapras%NOTFOUND THEN
          
          --Fecha o cursor
          CLOSE cr_crapras;
          
          vr_incompleto := FALSE;
          
          EXIT;              
        ELSE
          
          --Fecha o cursor
          CLOSE cr_crapras;
          
        END IF;              
       
      END LOOP;
                               
      BEGIN
        -- Busca notas de rating do associado
        OPEN cr_crapnrc(pr_cdcooper => rw_crapass.cdcooper,
                        pr_nrdconta => rw_crapass.nrdconta);
                        
        FETCH cr_crapnrc INTO rw_crapnrc;
             
        -- Gerar erro caso não encontre
        IF cr_crapnrc%NOTFOUND THEN
           -- Fechar cursor pois teremos raise
           CLOSE cr_crapnrc;
           
           -- Sair com erro
           vr_cdcritic := 0;
           vr_dscritic := 'Notas nao encontradas!';
           
           RAISE vr_exc_erro;
           
        ELSE
           -- Apenas fechar o cursor
           CLOSE cr_crapnrc;
        END IF; 
        
      EXCEPTION
        
        WHEN vr_exc_locked THEN
          gene0001.pc_ver_lock(pr_nmtabela    => 'CRAPNRC'
                              ,pr_nrdrecid    => ''
                              ,pr_des_reto    => vr_des_reto
                              ,pt_tab_locktab => vr_tab_locktab);
                              
          IF vr_des_reto = 'OK' THEN
            FOR VR_IND IN 1..vr_tab_locktab.COUNT LOOP
              vr_dscritic := 'Registro sendo alterado em outro terminal (CRAPNRC)' || 
                             ' - ' || vr_tab_locktab(VR_IND).nmusuari;
                             
                             --Escrever No LOG
          btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                  --  ,pr_nmarqlog     => 'prcins.log'
                                    ,pr_des_log      => vr_dscritic); 
        
        
            END LOOP;
          END IF;
          -- Gera exceção
          RAISE vr_exc_erro;
           
      END;
                                
      -- Consultar saldo utilizado
      gene0005.pc_saldo_utiliza(pr_cdcooper    => vr_cdcooper
                               ,pr_tpdecons    => 2
                               ,pr_cdagenci    => vr_cdagenci
                               ,pr_nrdcaixa    => vr_nrdcaixa
                               ,pr_cdoperad    => vr_cdoperad
                               ,pr_nrdconta    => pr_nrdconta                               
                               ,pr_idorigem    => vr_idorigem
                               ,pr_dsctrliq    => ''
                               ,pr_cdprogra    => vr_nmdatela
                               ,pr_tab_crapdat => rw_crapdat
                               ,pr_inusatab    => vr_inusatab
                               ,pr_vlutiliz    => vr_vlutiliz
                               ,pr_cdcritic    => vr_cdcritic
                               ,pr_dscritic    => vr_dscritic);      
                           
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;         
      
      BEGIN
        
        IF NOT vr_incompleto THEN 
          
          UPDATE crapnrc SET crapnrc.dtmvtolt = rw_crapdat.dtmvtolt
                            ,crapnrc.cdoperad = vr_cdoperad
                            ,crapnrc.vlutlrat = vr_vlutiliz                            
                            ,crapnrc.indrisco = ''
                            ,crapnrc.nrnotrat = 0
           WHERE crapnrc.cdcooper = rw_crapass.cdcooper
             AND crapnrc.nrdconta = rw_crapass.nrdconta
             AND crapnrc.tpctrrat = 0
             AND crapnrc.nrctrrat = 0;
             
          -- Existe para satisfazer exigência da interface. 
      	  pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><mensagem>Rating incompleto - Sem classificacao de Risco - VERIFIQUE</mensagem></Root>');                     
         
             
        ELSE
         
           UPDATE crapnrc SET crapnrc.dtmvtolt = rw_crapdat.dtmvtolt
                             ,crapnrc.cdoperad = vr_cdoperad
                             ,crapnrc.vlutlrat = vr_vlutiliz                            
                             ,crapnrc.indrisco = vr_risco
                             ,crapnrc.nrnotrat = vr_vltotnota
           WHERE crapnrc.cdcooper = rw_crapass.cdcooper
             AND crapnrc.nrdconta = rw_crapass.nrdconta
             AND crapnrc.tpctrrat = 0
             AND crapnrc.nrctrrat = 0;
        
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          --Monta mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi possivel atualizar as notas de rating.' || SQLERRM;
          
          RAISE vr_exc_erro;
      
      END;
           
      pr_des_erro := 'OK';      
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                       
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na TELA_RATING.pc_busca_rating --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');        
        
  END pc_gravar_rating;
 
  /* Rotina para gerar o ralatorio com os rating do cooperado */
  PROCEDURE pc_gera_rel_rating(pr_cddopcao  IN crapace.cddopcao%TYPE --> Opcao da tela
                              ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta                              
                              ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_gera_rel_rating
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jonathan
    Data    : Janeiro/2016                       Ultima atualizacao: 05/04/2016 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para gerar o relatorio com os ratings do cooperado

    Alteracoes: 05/04/2016 - Ajuste para retirar o "*" ao remover o arquivo
                             (Adriano).
    ............................................................................. */
      
      -- Busca dos dados do associado
      CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.nrdconta
            ,ass.cdcooper 
            ,ass.cdagenci
            ,ass.inpessoa   
            ,decode(ass.inpessoa,1,'Pessoa Fisica',2,'Pessoa Juridica') dspessoa  
            ,ass.nmprimtl      
       FROM crapass ass
      WHERE ass.cdcooper = pr_cdcooper
        AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;             
     
     CURSOR cr_craptor(pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_inpessoa IN crapass.inpessoa%TYPE) IS
     SELECT craptor.nrtopico
           ,craptor.dstopico
           ,craptor.cdcooper
      FROM craptor
     WHERE craptor.cdcooper = pr_cdcooper
       AND craptor.inpessoa = pr_inpessoa
       AND craptor.nrtopico >= 0
       AND craptor.flgativo = 1;
     rw_craptor cr_craptor%ROWTYPE;
     
     CURSOR cr_crapitr(pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrtopico IN crapitr.nrtopico%TYPE) IS
     SELECT crapitr.pesoitem
           ,crapitr.nritetop
           ,crapitr.dsitetop
      FROM crapitr
     WHERE crapitr.cdcooper = pr_cdcooper       
       AND crapitr.nrtopico = pr_nrtopico;
     rw_crapitr cr_crapitr%ROWTYPE;
     
     CURSOR cr_crapsir(pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrtopico IN crapsir.nrtopico%TYPE
                      ,pr_nritetop IN crapsir.nritetop%TYPE) IS
     SELECT crapsir.nrseqite
           ,crapsir.pesosequ
           ,crapsir.dsseqite
      FROM crapsir
     WHERE crapsir.cdcooper = pr_cdcooper       
       AND crapsir.nrtopico = pr_nrtopico
       AND crapsir.nritetop = pr_nritetop;
     rw_crapsir cr_crapsir%ROWTYPE;
     
     CURSOR cr_crapras(pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE
                      ,pr_nrtopico IN crapras.nrtopico%TYPE
                      ,pr_nritetop IN crapras.nritetop%TYPE
                      ,pr_nrseqite IN crapras.nrseqite%TYPE)IS
     SELECT crapras.cdcooper
      FROM crapras
     WHERE crapras.cdcooper = pr_cdcooper
       AND crapras.nrdconta = pr_nrdconta
       AND crapras.tpctrrat = 0
       AND crapras.nrctrrat = 0
       AND crapras.nrtopico = pr_nrtopico
       AND crapras.nritetop = pr_nritetop
       AND crapras.nrseqite = pr_nrseqite;
     rw_crapras cr_crapras%ROWTYPE;
     
     CURSOR cr_craptab(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
     SELECT craptab.dstextab
       FROM craptab
      WHERE craptab.cdcooper = pr_cdcooper
        AND craptab.nmsistem = 'CRED'
        AND craptab.tptabela = 'GENERI'
        AND craptab.cdempres = 00
        AND craptab.cdacesso = 'PROVISAOCL'
        ORDER BY SUBSTR(craptab.dstextab,12,2);
     rw_craptab cr_craptab%ROWTYPE;
     
     CURSOR cr_crapope(pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
     SELECT crapope.nmoperad
       FROM crapope
      WHERE crapope.cdcooper = pr_cdcooper
        AND crapope.cdoperad = pr_cdoperad;
     rw_crapope cr_crapope%ROWTYPE;
         
     --Tabela de Erros
     vr_tab_erro gene0001.typ_tab_erro;
    
     -- Cursor genérico de calendário
     rw_crapdat btch0001.cr_crapdat%ROWTYPE;
     
     vr_cdcritic crapcri.cdcritic%TYPE;
     vr_dscritic crapcri.dscritic%TYPE;
          
     --Variáveis auxiliares
     vr_nmdireto    VARCHAR2(100);
     vr_dstexto     VARCHAR2(32700);      
     vr_clobxml     CLOB;       
     vr_des_reto    VARCHAR2(3);      
     vr_nmarqpdf    VARCHAR2(1000);
     vr_nmarquiv    VARCHAR2(1000);
     vr_comando     VARCHAR2(1000);
     vr_typ_saida   VARCHAR2(3);
     vr_vltotnota   NUMBER(25,2) := 0;
     vr_vlrnota     NUMBER(25,2) := 0;
     vr_contador    INTEGER := 0;
     vr_selecionado VARCHAR(1) := ' ';
     vr_auxconta    PLS_INTEGER:= 0;
     vr_risco       VARCHAR(4);
     vr_desrisco    VARCHAR(4);
     vr_provisao    NUMBER;
     vr_notamini    NUMBER;
     vr_notamaxi    NUMBER;
     vr_parecer     VARCHAR(20);
     
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
      
    BEGIN
           
      pr_des_erro := 'NOK';      
      
      --Limpar tabela dados      
      vr_tab_erro.DELETE;    
      
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
        
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'RATING'
                                ,pr_action => null);
                                
      -- Verifica se o associado existe
      OPEN cr_crapass (pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
                      
      FETCH cr_crapass INTO rw_crapass;
      
      -- Se nao encontrar
      IF cr_crapass%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapass;
        
        -- Montar mensagem de critica
        vr_cdcritic := 9;
        
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
        --Campo com critica
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
          
        ELSE
          
          -- Fechar o cursor pois haverá raise
          CLOSE cr_crapass;        
        
        END IF;    
        
      OPEN cr_crapope(pr_cdcooper => vr_cdcooper
                     ,pr_cdoperad => vr_cdoperad);
                     
      FETCH cr_crapope INTO rw_crapope;
      
      --Fecha o cursor
      CLOSE cr_crapope;          
      
      -- Verifica se a cooperativa esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        
        RAISE vr_exc_erro;
        
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
        
      END IF;
      
      --Buscar Diretorio Padrao da Cooperativa
      vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => 'rl');
                                       
      --Nome do Arquivo
      vr_nmarquiv:= vr_nmdireto||'/'||'crrl367.lst';
      
      --Nome do Arquivo PDF
      vr_nmarqpdf:= REPLACE(vr_nmarquiv,'.lst','.pdf');
      
      -- Inicializar as informações do XML de dados para o relatório
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

      --Escrever no arquivo XML
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                               '<?xml version="1.0" encoding="UTF-8"?>' || 
                                  '<crrl367 dtmvtolt="' || to_char(rw_crapdat.dtmvtolt,'dd') || ' de ' || trim(to_char(rw_crapdat.dtmvtolt,'Month','nls_date_language=portuguese')) || ' de ' || to_char(rw_crapdat.dtmvtolt,'RRRR')  || 
                                         '" nmoperad="' || rw_crapope.nmoperad ||
                                         '" nrdconta="' || to_char(rw_crapass.nrdconta,'fm9999g999g9') || 
                                         '" nmprimtl="' || rw_crapass.nmprimtl ||
                                         '" dspessoa="' || rw_crapass.dspessoa || '">');
                                          
      FOR rw_craptor IN cr_craptor(pr_cdcooper => vr_cdcooper 
                                  ,pr_inpessoa => rw_crapass.inpessoa) LOOP 
          
        --Escrever no arquivo XML
        gene0002.pc_escreve_xml(vr_clobxml
                               ,vr_dstexto
                               ,'<topico nrtopico="' || to_char(rw_craptor.nrtopico,'000') || '" dstopico="'|| rw_craptor.dstopico ||'">');
        
        FOR rw_crapitr IN cr_crapitr(pr_cdcooper => rw_craptor.cdcooper 
                                    ,pr_nrtopico => rw_craptor.nrtopico) LOOP  
                                                       
          --Escrever no arquivo XML
          gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                                     '<subtopico nritetop="' || to_char(rw_crapitr.nritetop,'000') || '" dsitetop="'|| rw_crapitr.dsitetop ||'" pesoitem="'|| to_char(rw_crapitr.pesoitem,'fm99999g999g990d00') ||'">');
          
          FOR rw_crapsir IN cr_crapsir(pr_cdcooper => rw_craptor.cdcooper 
                                      ,pr_nrtopico => rw_craptor.nrtopico
                                      ,pr_nritetop => rw_crapitr.nritetop) LOOP  
          
             OPEN cr_crapras(pr_cdcooper => rw_craptor.cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrtopico => rw_craptor.nrtopico
                            ,pr_nritetop => rw_crapitr.nritetop
                            ,pr_nrseqite => rw_crapsir.nrseqite);
                            
             FETCH cr_crapras INTO rw_crapras;
             
             IF cr_crapras%FOUND THEN             
               
               vr_selecionado := '*';                 
               vr_vlrnota := rw_crapitr.pesoitem * rw_crapsir.pesosequ;
             
             ELSE  
                 
               vr_selecionado := '';                               
               vr_vlrnota := 0;
               
             END IF;  
             
             --Fecha o cursor
             CLOSE cr_crapras;        
             
             vr_vltotnota := vr_vltotnota + vr_vlrnota;        
               
             --Escrever no arquivo XML
             gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                                        '<item>' ||
                                           '<pesosequ>' || to_char(rw_crapsir.pesosequ,'fm99999g999g990d00') || '</pesosequ>' ||
                                           '<nrseqite>' || to_char(rw_crapsir.nrseqite,'000') || '</nrseqite>' ||
                                           '<dsseqite>' || rw_crapsir.dsseqite || '</dsseqite>' ||                                           
                                           '<vlrnota>'  || CASE vr_vlrnota WHEN 0 THEN NULL ELSE to_char(vr_vlrnota,'fm99999g999g990d00') END || '</vlrnota>' ||
                                           '<selecionado>' || vr_selecionado || '</selecionado>' ||
                                        '</item>');
                                
             vr_contador := vr_contador + 1;           
          
          END LOOP;
          
          --Escrever no arquivo XML
          gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                                     '</subtopico>');      
        
        END LOOP;
        
        --Escrever no arquivo XML
        gene0002.pc_escreve_xml(vr_clobxml
                               ,vr_dstexto
                               ,'</topico>');
                               
      END LOOP;
      
      --Escrever no arquivo XML
      gene0002.pc_escreve_xml(vr_clobxml
                             ,vr_dstexto
                             ,'<legendas>');   
                              
      FOR rw_craptab IN cr_craptab(pr_cdcooper => vr_cdcooper) LOOP  
        
        vr_provisao := to_number(SUBSTR(rw_craptab.dstextab,1,6));
        vr_desrisco := TRIM(SUBSTR(rw_craptab.dstextab,8,3)); 
                                   
        IF rw_crapass.inpessoa = 1 THEN
          
          vr_notamini := to_number(SUBSTR(rw_craptab.dstextab,27,6));        
          vr_notamaxi := to_number(SUBSTR(rw_craptab.dstextab,34,6));      
          vr_parecer  := SUBSTR(rw_craptab.dstextab,41,15);
          
          IF vr_vltotnota >= TO_NUMBER(SUBSTR(rw_craptab.dstextab,27,6)) AND
             vr_vltotnota <= TO_NUMBER(SUBSTR(rw_craptab.dstextab,34,6)) THEN
            
            vr_risco := TRIM(SUBSTR(rw_craptab.dstextab,8,3)); 
        
          END IF;
        
        ELSE
          
          vr_notamini := to_number(SUBSTR(rw_craptab.dstextab,56,6));        
          vr_notamaxi := to_number(SUBSTR(rw_craptab.dstextab,62,6));      
          vr_parecer  := SUBSTR(rw_craptab.dstextab,70,15);
          
          IF vr_vltotnota >= TO_NUMBER(SUBSTR(rw_craptab.dstextab,57,6)) AND
             vr_vltotnota <= TO_NUMBER(SUBSTR(rw_craptab.dstextab,64,6)) THEN
             
            vr_risco := TRIM(SUBSTR(rw_craptab.dstextab,8,3));
                                
          END IF;
          
        END IF;
      
        --Escrever no arquivo XML
        gene0002.pc_escreve_xml(vr_clobxml
                               ,vr_dstexto
                               ,'<deslegenda>' || 
                                  '<desrisco>' || vr_desrisco || '</desrisco>' ||
                                  '<notamini>' || to_char(vr_notamini,'fm99999g999g990d00')  || '</notamini>' ||
                                  '<notamaxi>' || to_char(vr_notamaxi,'fm99999g999g990d00')  || '</notamaxi>' ||
                                  '<provisao>' || to_char(vr_provisao,'fm99999g999g990d00')  || '</provisao>' ||
                                  '<parecer>' || vr_parecer || '</parecer>' ||
                                '</deslegenda>');          
                                 
      END LOOP;
      
      --Escrever no arquivo XML
      gene0002.pc_escreve_xml(vr_clobxml
                             ,vr_dstexto
                             ,'</legendas>' || 
                              '<nota>' || 
                                '<vltotnota>' || to_char(vr_vltotnota,'fm99999g999g990d00') || '</vltotnota>' ||
                                '<risco>' || vr_risco || '</risco>' ||
                              '</nota>');                                 
          
      --Finaliza TAG Relatorio
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</crrl367>',TRUE); 
   
      -- Gera relatório crrl657
	    gene0002.pc_solicita_relato(pr_cdcooper    => vr_cdcooper    --> Cooperativa conectada
                                   ,pr_cdprogra  => 'RATING'--vr_nmdatela         --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt         --> Data do movimento atual
                                   ,pr_dsxml     => vr_clobxml          --> Arquivo XML de dados
                                   ,pr_dsxmlnode => 'crrl367/topico/subtopico/item'          --> Nó base do XML para leitura dos dados                                  
                                   ,pr_dsjasper  => 'crrl367.jasper'    --> Arquivo de layout do iReport
                                   ,pr_dsparams  => NULL                --> Sem parâmetros
                                   ,pr_dsarqsaid => vr_nmarqpdf         --> Arquivo final com o path
                                   ,pr_qtcoluna  => 132                  --> Colunas do relatorio
                                   ,pr_flg_gerar => 'S'                 --> Geraçao na hora
                                   ,pr_cdrelato  => '367'               --> Códigod do relatório
                                   ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p) 
                                   ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 1                   --> Número de cópias
                                   ,pr_sqcabrel  => 1                   --> Qual a seq do cabrel                                                                          
                                   ,pr_des_erro  => vr_dscritic);       --> Saída com erro
        
      --Se ocorreu erro no relatorio
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF; 
        
      --Fechar Clob e Liberar Memoria  
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);  
      
       --Efetuar Copia do PDF
      gene0002.pc_efetua_copia_pdf (pr_cdcooper => vr_cdcooper     --> Cooperativa conectada
                                   ,pr_cdagenci => vr_cdagenci     --> Codigo da agencia para erros
                                   ,pr_nrdcaixa => vr_nrdcaixa     --> Codigo do caixa para erros
                                   ,pr_nmarqpdf => vr_nmarqpdf     --> Arquivo PDF  a ser gerado                                 
                                   ,pr_des_reto => vr_des_reto     --> Saída com erro
                                   ,pr_tab_erro => vr_tab_erro);   --> tabela de erros 
                                   
      --Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        
        --Se possui erro
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Nao foi possivel efetuar a copia do relatorio.';
        END IF;
        
        --Levantar Excecao  
        RAISE vr_exc_erro;
        
      END IF; 
        
      --Se Existir arquivo pdf  
      IF gene0001.fn_exis_arquivo(pr_caminho => vr_nmarqpdf) THEN
        
        --Remover arquivo
        vr_comando:= 'rm '||vr_nmarqpdf||' 2>/dev/null';
        
        --Executar o comando no unix
        GENE0001.pc_OScommand (pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);
                          
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          
          --Monta mensagem de critica
          vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_comando;
          
          -- retornando ao programa chamador
          RAISE vr_exc_erro;
          
        END IF;
        
      END IF;
        
      /* Nome do PDF para devolver como parametro */
      vr_nmarqpdf:= SUBSTR(vr_nmarqpdf,instr(vr_nmarqpdf,'/',-1)+1);
      
      --Se ocorreu erro
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN                                   
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      -- Insere as tags dos campos da PLTABLE 
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmarqpdf', pr_tag_cont => vr_nmarqpdf, pr_des_erro => vr_dscritic);      --Retorno OK
    
      
      pr_des_erro := 'OK';      
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                       
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na TELA_RATING.pc_gera_rel_rating --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');        
        
  END pc_gera_rel_rating;
 
 
END TELA_RATING;
/
