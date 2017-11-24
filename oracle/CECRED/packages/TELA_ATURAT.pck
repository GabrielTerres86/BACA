CREATE OR REPLACE PACKAGE CECRED.TELA_ATURAT AS

   /*
   Programa: TELA_ATURAT                          antigo: /ayllos/fontes/aturat.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Andrei - RKAM
   Data    : Maio/2016                       Ultima atualizacao: 02/05/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line).
   Objetivo  : Mostrar a tela ATURAT, Ratings dos cooperados.

   Alteracoes: 08/03/2010 - Implementar opcao 'S' da tela (Gabriel).
  
               18/03/2011 - Incluido opcao 'L' - Risco Cooperado
                          - Incluido Risco e nota cooperado nas opcoes "C,A,R"
                           (Guilherme).
                         
               14/04/2011 - Incluido a temp-table tt-impressao-risco-tl como
                            parametro de saida da procedure atualiza_rating,
                            para atualizar a crapass. (Fabricio)
                            
               13/09/2011 - Alterações para Rating da Central (Guilherme).
               
               09/11/2011 - Alterações para Rating da Central (Adriano).

               15/02/2012 - Alteracao da msg O risco efetivado para a C. de Risco (Rosangela) 
  
               03/07/2012 - Alteração CDOPERAD de INTE para CHAR (Lucas R.).
               
               18/10/2012 - Alterado o format do campo 'bb-ratings.vloperac'
                            do browse 'b-ratings' (Lucas).
               
               10/09/2013 - Nova forma de chamar as agências, de PAC agora 
                             a escrita será PA (André Euzébio - Supero).
                             
               03/01/2014 - Trocar critica 15 Agencia nao cadastrada por 
                            962 PA nao cadastrado (Reinert)
                            
               29/05/2015 - Remover a opcao "S", atualizacao do risco sera
                            no crps310_i. (James)  
                            
               02/05/2016 - Conversão Progress >> Oracle (Andrei - RKAM). 

			   11/10/2017 - Liberacao da melhoria 442 (Heitor - Mouts)

			   07/11/2017 - Alteracao em relatorio impresso para Rating Proposta
                            com layout mais organizado e parecido com o Rating Atual
                            Heitor (Mouts) - Melhoria 442
   */               
   
  PROCEDURE pc_verifica_rating_ativo(pr_nrdconta IN crapass.nrdconta%TYPE -- Número da conta
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE -- Data de movimento
                                    ,pr_cddopcao IN VARCHAR2              --Opção da tela
                                    ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK
                                    
  PROCEDURE pc_atualiza_risco_coop(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                  ,pr_cddopcao IN VARCHAR2              --Opção da tela
                                  ,pr_flgatltl IN INTEGER               --Tipo de atualizacao
                                  ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK                                 
                                    
  --Rotina para buscar os ratings   
  PROCEDURE pc_busca_ratings (pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                             ,pr_cddopcao IN VARCHAR2              --Opção
                             ,pr_dtinirat IN VARCHAR2              --Data inicial
                             ,pr_dtfinrat IN VARCHAR2              --Data final
                             ,pr_cdagesel IN crapage.cdagenci%TYPE --Agencia 
                             ,pr_tprelato IN INTEGER               --Tipo do relatorio 
                             ,pr_nrregist IN INTEGER               --> Número de registros
                             ,pr_nriniseq IN INTEGER               --> Número sequencial 
                             ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                             ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK
                             
                             
  PROCEDURE pc_verifica_atual_rating(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                    ,pr_cddopcao IN VARCHAR2              --Opção da tela
                                    ,pr_nrctrrat IN crapnrc.nrctrrat%TYPE --Número do contrato
                                    ,pr_tpctrrat IN crapnrc.tpctrrat%TYPE --Tipo do contrato
                                    ,pr_indrisco IN crapnrc.indrisco%TYPE --Indicador do risco
                                    ,pr_nrnotrat IN crapnrc.nrnotrat%TYPE --Nota do rating
                                    ,pr_insitrat IN crapnrc.insitrat%TYPE --Situação do rating
                                    ,pr_tpdaoper  IN INTEGER              --Controla operacao
                                    ,pr_vlrating IN VARCHAR2              --> Ratings
                                    ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK
                       
  
  PROCEDURE pc_gera_rating(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                          ,pr_cddopcao IN VARCHAR2              --Opção da tela
                          ,pr_nrctrrat IN crapnrc.nrctrrat%TYPE --Número do contrato
                          ,pr_tpctrrat IN crapnrc.tpctrrat%TYPE --Tipo do contrato
                          ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                          ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK
                          
  PROCEDURE pc_calcula(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                      ,pr_cddopcao IN VARCHAR2              --Opção da tela
                      ,pr_nrctrrat IN crapnrc.nrctrrat%TYPE --Número do contrato
                      ,pr_tpctrrat IN crapnrc.tpctrrat%TYPE --Tipo do contrato
                      ,pr_dsdopera IN VARCHAR2              --Descricao da operacao
                      ,pr_insitrat IN crapnrc.insitrat%TYPE --Situação do rating
                      ,pr_rowidnrc IN ROWID                 --Rowid do registro
                      ,pr_indrisco IN crapnrc.indrisco%TYPE --Indicador do risco
                      ,pr_nrnotrat IN crapnrc.nrnotrat%TYPE --Nota do rating
                      ,pr_vlrating IN VARCHAR2              --Ratings
                      ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                      ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                      ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                      ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                      ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                      ,pr_des_erro OUT VARCHAR2);         --Saida OK/NOK     
                      
  /* Rotina para buscar os rating das singulares */
  PROCEDURE pc_busca_rating_singulares(pr_cddopcao IN crapace.cddopcao%TYPE --> Opcao da tela
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_nrregist IN INTEGER                --> Número de registros
                                      ,pr_nriniseq IN INTEGER                --> Número sequencial 
                                      ,pr_nrctrrat IN crapras.nrctrrat%TYPE  --> Numero do contrato
                                      ,pr_tpctrrat IN crapras.tpctrrat%TYPE  --> Tipo do contrato
                                      ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK                                           
                                                    
  PROCEDURE pc_gera_rating_proposta(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                   ,pr_cddopcao IN VARCHAR2              --Opção da tela
                                   ,pr_nrctrrat IN crapnrc.nrctrrat%TYPE --Número do contrato
                                   ,pr_tpctrrat IN crapnrc.tpctrrat%TYPE --Tipo do contrato
                                   ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK
END TELA_ATURAT;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATURAT AS

/*---------------------------------------------------------------------------------------------------------------
   Programa: TELA_ATURAT                          antigo: /ayllos/fontes/aturat.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Andrei - RKAM
   Data    : Maio/2016                       Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Diario (on-line).
   Objetivo  : Mostrar a tela ATURAT, Ratings dos cooperados.

   Alteracoes: 08/03/2010 - Implementar opcao 'S' da tela (Gabriel).
  
               18/03/2011 - Incluido opcao 'L' - Risco Cooperado
                          - Incluido Risco e nota cooperado nas opcoes "C,A,R"
                           (Guilherme).
                         
               14/04/2011 - Incluido a temp-table tt-impressao-risco-tl como
                            parametro de saida da procedure atualiza_rating,
                            para atualizar a crapass. (Fabricio)
                            
               13/09/2011 - Alterações para Rating da Central (Guilherme).
               
               09/11/2011 - Alterações para Rating da Central (Adriano).

               15/02/2012 - Alteracao da msg O risco efetivado para a C. de Risco (Rosangela) 
  
               03/07/2012 - Alteração CDOPERAD de INTE para CHAR (Lucas R.).
               
               18/10/2012 - Alterado o format do campo 'bb-ratings.vloperac'
                            do browse 'b-ratings' (Lucas).
               
               10/09/2013 - Nova forma de chamar as agências, de PAC agora 
                             a escrita será PA (André Euzébio - Supero).
                             
               03/01/2014 - Trocar critica 15 Agencia nao cadastrada por 
                            962 PA nao cadastrado (Reinert)
                            
               29/05/2015 - Remover a opcao "S", atualizacao do risco sera
                            no crps310_i. (James)  
                            
               02/05/2016 - Conversão Progress >> Oracle (Andrei - RKAM).             
                                                             
  ---------------------------------------------------------------------------------------------------------------*/
  
  PROCEDURE pc_gera_log(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE
                       ,pr_flgratin IN BOOLEAN
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_dsoperad IN crapope.nmoperad%TYPE
                       ,pr_nrctrrat IN crapnrc.nrctrrat%TYPE
                       ,pr_indrisco IN VARCHAR2
                       ,pr_nrnotrat IN crapnrc.nrnotrat%TYPE
                       ,pr_novorisc IN VARCHAR2
                       ,pr_novanota IN crapnrc.nrnotrat%TYPE
                       ,pr_des_erro OUT VARCHAR2) IS  
                        
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gera_log                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Procedure para gerar log
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                            
   
   BEGIN
     
     /* Se nao tem Rating (Opcao S) */
     IF NOT pr_flgratin THEN
       -- Gera log
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_nmarqlog     => 'aturat.log'
                                 ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                     ' -->  Operador '|| pr_cdoperad || ' - ' ||
                                                     'Atualizou o Risco da conta/dv ' || 
                                                     LTrim(RTRIM(gene0002.fn_mask(pr_nrdconta, 'zzzz.zzz.9'))) || ', ' || pr_dsoperad || 
                                                    ', contrato ' || gene0002.fn_mask(pr_nrctrrat,'z.zzz.zz9') || ' de ' || pr_indrisco ||
                                                    ' para ' || pr_novorisc || '.');
     
      /* Sem alteraçao na nota do Rating */     
     ELSIF pr_nrnotrat = pr_novanota THEN
       
       -- Gera log
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_nmarqlog     => 'aturat.log'
                                 ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                     ' -->  Operador '|| pr_cdoperad || ' - ' ||
                                                     'Atualizou o Rating da conta/dv ' || 
                                                     LTrim(RTRIM(gene0002.fn_mask(pr_nrdconta, 'zzzz.zzz.9'))) || ', ' || pr_dsoperad || 
                                                    ', contrato ' || gene0002.fn_mask(pr_nrctrrat,'z.zzz.zz9') || 
                                                    ', sem alterar a nota do mesmo.');
     
     /* Com alteraçao na nota */
     ELSE
       
       -- Gera log
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_nmarqlog     => 'aturat.log'
                                 ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                     ' -->  Operador '|| pr_cdoperad || ' - ' ||
                                                     'Atualizou o Rating da conta/dv ' || 
                                                     LTrim(RTRIM(gene0002.fn_mask(pr_nrdconta, 'zzzz.zzz.9'))) || ', ' || pr_dsoperad || 
                                                    ', contrato ' || gene0002.fn_mask(pr_nrctrrat,'z.zzz.zz9') || ', risco ' || pr_indrisco || 
                                                    ' e nota ' || to_char(pr_nrnotrat,'fm990d00') || ' para o risco ' ||
                                                    pr_novorisc || ' e nota ' || to_char(pr_novanota,'fm990d00') || '.');
     
             
     END IF;
        
        
     pr_des_erro := 'OK';                                          
   
   EXCEPTION
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';    
         
   END pc_gera_log;    
   
  PROCEDURE pc_verifica_rating_ativo(pr_nrdconta IN crapass.nrdconta%TYPE -- Número da conta
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE -- Data de movimento
                                    ,pr_cddopcao IN VARCHAR2              --Opção da tela
                                    ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
  
    
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_verifica_rating_ativo                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Verifica ser o rating a ser atualizado esta ativo ou não
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                
    
    --Cursor para encontrar a conta do associado
    CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT crapass.nrdconta
          ,crapass.inrisctl
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
       AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
      
    --Cursor para encontrar o rating ativo do cooperado
    CURSOR cr_crapnrc(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT crapnrc.nrdconta
          ,crapnrc.flgativo
      FROM crapnrc
     WHERE crapnrc.cdcooper = pr_cdcooper
       AND crapnrc.nrdconta = pr_nrdconta
       AND crapnrc.insitrat = 2 --Efetivo
       AND crapnrc.flgativo = 1; --ativo
    rw_crapnrc cr_crapnrc%ROWTYPE;  
    
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_clob     CLOB;
    vr_dstexto  VARCHAR2(32700); 
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    
  BEGIN 
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'ATURAT'
                              ,pr_action => null); 
                                 
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
    
    --Busca o associado
    OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
                   
    FETCH cr_crapass INTO rw_crapass;
    
    IF cr_crapass%NOTFOUND THEN
      
      -- Fecha o cursor
      CLOSE cr_crapass;
      
      vr_cdcritic := 9;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      
      RAISE vr_exc_erro;
      
    ELSE
      
      -- Fecha o cursor
      CLOSE cr_crapass;
    
    END IF;
  
    --Busca o rating ativo
    OPEN cr_crapnrc(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);                   
                   
    FETCH cr_crapnrc INTO rw_crapnrc;
    
    IF cr_crapnrc%FOUND THEN
      
      -- Fecha o cursor
      CLOSE cr_crapnrc;
      
      vr_cdcritic := 0;
      vr_dscritic := 'Cooperado com rating ativo. Atualizacao pela opcao ''A''.';
      
      RAISE vr_exc_erro;
      
    ELSE
      
      -- Fecha o cursor
      CLOSE cr_crapnrc;
    
    END IF;               
  
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
      
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><rating>');                                    
                                    
    -- Carrega os dados           
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '<situacao>'||                                                                      
                                                 '  <flgativo>' || rw_crapnrc.flgativo||'</flgativo>'||
                                                 '  <inrisctl>' || rw_crapass.inrisctl||'</inrisctl>'||
                                                 '</situacao>');  
      
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '</rating></Root>'
                           ,pr_fecha_xml      => TRUE);
                  
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);   
    
    pr_des_erro := 'OK';
  
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := 'nrdconta';
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_verifica_rating_ativo --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_verifica_rating_ativo;
    
  PROCEDURE pc_atualiza_risco_coop(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                  ,pr_cddopcao IN VARCHAR2              --Opção da tela
                                  ,pr_flgatltl IN INTEGER               -- 0 = Calcular / 1 = atualizar
                                  ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_atualiza_risco_coop                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Calcula a nota de rating do cooperado
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                
      
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_flgcriar INTEGER := 0;
    vr_clob     CLOB;
    vr_dstexto  VARCHAR2(32700); 
    vr_des_reto VARCHAR2(3);
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    --PL tables  
    vr_tab_impress_coop     RATI0001.typ_tab_impress_coop;
    vr_tab_impress_rating   RATI0001.typ_tab_impress_rating;
    vr_tab_impress_risco_cl RATI0001.typ_tab_impress_risco;
    vr_tab_impress_risco_tl RATI0001.typ_tab_impress_risco;
    vr_tab_impress_assina   RATI0001.typ_tab_impress_assina;
    vr_tab_efetivacao       RATI0001.typ_tab_efetivacao;
    vr_tab_ratings          RATI0001.typ_tab_ratings;
    vr_tab_crapras          RATI0001.typ_tab_crapras;
    vr_tab_erro             GENE0001.typ_tab_erro;
    
  BEGIN 
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'ATURAT'
                              ,pr_action => null); 
                                 
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
       
    IF pr_flgatltl IS NULL      OR
       NOT pr_flgatltl in (0,1) THEN
       
      vr_cdcritic := 0;
      vr_dscritic := 'Tipo de atualizacao invalida.';
          
      RAISE vr_exc_erro;
        
    END IF;
       
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    
    RATI0001.pc_calcula_rating(pr_cdcooper => vr_cdcooper  --> Codigo Cooperativa
                              ,pr_cdagenci => vr_cdagenci  --> Codigo Agencia
                              ,pr_nrdcaixa => vr_nrdcaixa  --> Numero Caixa
                              ,pr_cdoperad => vr_cdoperad  --> Codigo Operador
                              ,pr_nrdconta => pr_nrdconta  --> Numero da Conta
                              ,pr_tpctrato => 0            --> Tipo Contrato Rating
                              ,pr_nrctrato => 0            --> Numero Contrato Rating
                              ,pr_flgcriar => vr_flgcriar  --> Indicado se deve criar o rating
                              ,pr_flgcalcu => 1            --> Indicador de calculo
                              ,pr_idseqttl => 1            --> Sequencial do Titular
                              ,pr_idorigem => vr_idorigem  --> Identificador Origem
                              ,pr_nmdatela => vr_nmdatela  --> Nome da tela
                              ,pr_flgerlog => 'N'          --> Identificador de geração de log
                              ,pr_tab_rating_sing       => vr_tab_crapras --> Registros gravados para rating singular
                              ,pr_flghisto => pr_flgatltl
                              ----- OUT ----
                              ,pr_tab_impress_coop     => vr_tab_impress_coop     --> Registro impressão da Cooperado
                              ,pr_tab_impress_rating   => vr_tab_impress_rating   --> Registro itens do Rating
                              ,pr_tab_impress_risco_cl => vr_tab_impress_risco_cl    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                              ,pr_tab_impress_risco_tl => vr_tab_impress_risco_tl    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                              ,pr_tab_impress_assina   => vr_tab_impress_assina   --> Assinatura na impressao do Rating
                              ,pr_tab_efetivacao       => vr_tab_efetivacao       --> Registro dos itens da efetivação
                              ,pr_tab_ratings          => vr_tab_ratings          --> Informacoes com os Ratings do Cooperado
                              ,pr_tab_crapras          => vr_tab_crapras          --> Tabela com os registros processados
                              ,pr_tab_erro             => vr_tab_erro             --> Tabela de retorno de erro
                              ,pr_des_reto             => vr_des_reto             --> Ind. de retorno OK/NOK
                              );            
  
    IF vr_des_reto <> 'OK' THEN      
           
      vr_cdcritic := 0;
      vr_dscritic := 'Erro na verificacao da atualizacao do Rating.';
          
      RAISE vr_exc_erro;
        
    END IF;
      
    IF vr_tab_impress_risco_tl.COUNT = 0 THEN
        
      vr_cdcritic := 0;
      vr_dscritic := 'Registro do calculo de Risco Cooperado nao encontrado.';
          
      RAISE vr_exc_erro;
      
    END IF;
     
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
        
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><risco>');                                    
                                      
    -- Carrega os dados           
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '<situacao>'||                                                                      
                                                 '  <dsdrisco>' || vr_tab_impress_risco_tl(vr_tab_impress_risco_tl.first).dsdrisco||'</dsdrisco>'||
                                                 '  <vlrtotal>' || vr_tab_impress_risco_tl(vr_tab_impress_risco_tl.first).vlrtotal||'</vlrtotal>'||
                                                 '</situacao>');  
        
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '</risco></Root>'
                           ,pr_fecha_xml      => TRUE);
                    
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);
    
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);   
       
    IF pr_flgatltl = 1 THEN 
      
      --Atualiza o cadastro do associado com o novo risco calculado
      BEGIN

        UPDATE crapass
           SET crapass.inrisctl = vr_tab_impress_risco_tl(1).dsdrisco
              ,crapass.nrnotatl = vr_tab_impress_risco_tl(1).vlrtotal
              ,crapass.dtrisctl = rw_crapdat.dtmvtolt
         WHERE crapass.cdcooper = vr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro ao atualizar crapass: ' || SQLERRM;
          
          RAISE vr_exc_erro;
      
      END;      
    
    END IF;
    
    pr_des_erro := 'OK';
  
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := 'nrdconta';
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_verifica_rating_ativo --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_atualiza_risco_coop;
  
  
  PROCEDURE pc_verifica_atual_rating(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                    ,pr_cddopcao IN VARCHAR2              --Opção da tela
                                    ,pr_nrctrrat IN crapnrc.nrctrrat%TYPE --Número do contrato
                                    ,pr_tpctrrat IN crapnrc.tpctrrat%TYPE --Tipo do contrato
                                    ,pr_indrisco IN crapnrc.indrisco%TYPE --Indicador do risco
                                    ,pr_nrnotrat IN crapnrc.nrnotrat%TYPE --Nota do rating
                                    ,pr_insitrat IN crapnrc.insitrat%TYPE --Situação do rating
                                    ,pr_tpdaoper  IN INTEGER              --Controla operacao
                                    ,pr_vlrating IN VARCHAR2              --> Ratings
                                    ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_verifica_atual_rating                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Atualiza o rating do cooperado
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                
      
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_clob     CLOB;
    vr_dstexto  VARCHAR2(32700); 
    vr_des_reto VARCHAR2(3);
    vr_indrisco VARCHAR2(300);
    vr_nrnotrat crapnrc.nrnotrat%TYPE;
    vr_rowidnrc ROWID;
    vr_inrisctl crapass.inrisctl%TYPE;
    vr_nrnotatl crapass.nrnotatl%TYPE;
    vr_split    gene0002.typ_split := gene0002.typ_split();
    vr_index    VARCHAR2(15);
    vr_nrtopico craprat.nrtopico%TYPE;
    vr_nritetop craprai.nritetop%TYPE;
    vr_nrseqite craprad.nrseqite%TYPE;
    vr_reg_craprat craprat.progress_recid%TYPE;
    vr_reg_craprai craprai.progress_recid%TYPE;
    vr_reg_craprad craprad.progress_recid%TYPE;
    vr_selecionado INTEGER;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    vr_exc_saida EXCEPTION;
    
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    --PL tables  
    vr_tab_rating_sing      RATI0001.typ_tab_crapras;
    vr_tab_impress_risco    RATI0001.typ_tab_impress_risco;
    vr_tab_erro             GENE0001.typ_tab_erro;
    
  BEGIN 
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'ATURAT'
                              ,pr_action => null); 
                                 
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
       
    IF NVL(pr_nrctrrat,0) = 0 AND
       NVL(pr_tpctrrat,0) = 0 THEN
      
      --Monta critica
      vr_cdcritic := 0;
      vr_dscritic := 'Para atualizar Rating antigo utilize a tela RATING.';
          
      RAISE vr_exc_erro; 
       
    END IF;
    
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;

    END IF;
    
    -- Verificar , independente da situacao, se o Rating pode ser atualizado 
    IF vr_cdcooper = 3 THEN
                 
      IF pr_tpdaoper = 0 THEN
        RATI0001.pc_verifica_atualizacao(pr_cdcooper => vr_cdcooper  --> Codigo Cooperativa
                                        ,pr_cdagenci => 0            --> Codigo Agencia
                                        ,pr_nrdcaixa => 0            --> Numero Caixa
                                        ,pr_cdoperad => vr_cdoperad  --> Codigo Operador
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt  --> Data de movimento
                                        ,pr_dtmvtopr => rw_crapdat.dtmvtopr  --> Data do proximo dia útil
                                        ,pr_inproces => rw_crapdat.inproces  --> Situação do processo
                                        ,pr_nrdconta => pr_nrdconta  --> Numero da Conta
                                        ,pr_tpctrrat => pr_tpctrrat  --> Tipo Contrato Rating
                                        ,pr_nrctrrat => pr_nrctrrat  --> Numero Contrato Rating
                                        ,pr_idseqttl => 1            --> Sequencial do Titular
                                        ,pr_idorigem => 1            --> Identificador Origem
                                        ,pr_nmdatela => vr_nmdatela  --> Nome da tela
                                        ,pr_flgerlog => 'N'          --> Identificador de geração de log
                                        ,pr_dsretorn => TRUE         --> Retorna
                                        ,pr_tab_rating_sing => vr_tab_rating_sing --> Registros gravados para rating singular
                                        ,pr_indrisco => vr_indrisco  --> Indicador do risco
                                        ,pr_nrnotrat => vr_nrnotrat  --> Nota do rating
                                        ,pr_rowidnrc => vr_rowidnrc  --> Rowid do rating
                                        ,pr_tab_erro => vr_tab_erro  --> Tabela de retorno de erro
                                        ,pr_des_reto => vr_des_reto  --> Ind. de retorno OK/NOK
                                        ) ;
                                        
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          
          --Se possui erro
          IF vr_tab_erro.COUNT > 0 THEN
            vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro na verificacao da atualizacao do Rating.';
          END IF;
          
          --Levantar Excecao  
          RAISE vr_exc_erro;        
        
        ELSE
          
          --Levanta exceção
          RAISE vr_exc_saida;
          
        END IF; 
        
      ELSE
        -- Quebrar valores da lista recebida como parametro
        IF TRIM(pr_vlrating) IS NOT NULL THEN
            
          vr_split := gene0002.fn_quebra_string(pr_string  => pr_vlrating
                                               , pr_delimit => '#');
          -- ler linhas
          FOR i IN vr_split.first..vr_split.last LOOP
                    
            vr_nrtopico:= ( gene0002.fn_busca_entrada( pr_postext => 2
                                                      ,pr_dstext  => vr_split(i)
                                                      ,pr_delimitador => '|'));
                                                  
            vr_nritetop:= ( gene0002.fn_busca_entrada( pr_postext => 3
                                                      ,pr_dstext  => vr_split(i)
                                                      ,pr_delimitador => '|'));
                                                                                                         
            vr_nrseqite:= ( gene0002.fn_busca_entrada( pr_postext => 4
                                                      ,pr_dstext  => vr_split(i)
                                                      ,pr_delimitador => '|'));   
                                                      
            vr_reg_craprat:= ( gene0002.fn_busca_entrada( pr_postext => 5
                                                         ,pr_dstext  => vr_split(i)
                                                         ,pr_delimitador => '|'));
                                                  
            vr_reg_craprai:= ( gene0002.fn_busca_entrada( pr_postext => 6
                                                         ,pr_dstext  => vr_split(i)
                                                         ,pr_delimitador => '|'));
                                                                                                         
            vr_reg_craprad:= ( gene0002.fn_busca_entrada( pr_postext => 7
                                                         ,pr_dstext  => vr_split(i)
                                                         ,pr_delimitador => '|'));  
                                                      
            vr_selecionado := ( gene0002.fn_busca_entrada( pr_postext => 8
                                                          ,pr_dstext  => vr_split(i)
                                                          ,pr_delimitador => '|'));                                                                                                                      
                                                   
            IF vr_selecionado = 1 THEN
              
              -- definir indice
              vr_index := lpad(vr_nrtopico,5,'0') || lpad(vr_nritetop,5,'0') || lpad(vr_nrseqite,5,'0');
              
              -- incluir dados na temptable
              vr_tab_rating_sing(vr_index).nrtopico := vr_nrtopico;
              vr_tab_rating_sing(vr_index).nritetop := vr_nritetop;
              vr_tab_rating_sing(vr_index).nrseqite := vr_nrseqite;  
                                                                     
            END IF;
                                                         
          END LOOP;
        
        ELSE
          
          vr_cdcritic:= 0;
          vr_dscritic:= 'Nenhum rating selecionado.';

          --Levantar Excecao  
          RAISE vr_exc_erro;        
          
        END IF;        
        
      END IF;
      
    END IF;
    
    RATI0001.pc_verifica_atualizacao(pr_cdcooper => vr_cdcooper  --> Codigo Cooperativa
                                    ,pr_cdagenci => 0            --> Codigo Agencia
                                    ,pr_nrdcaixa => 0            --> Numero Caixa
                                    ,pr_cdoperad => vr_cdoperad  --> Codigo Operador
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt  --> Data de movimento
                                    ,pr_dtmvtopr => rw_crapdat.dtmvtopr  --> Data do proximo dia útil
                                    ,pr_inproces => rw_crapdat.inproces  --> Situação do processo
                                    ,pr_nrdconta => pr_nrdconta  --> Numero da Conta
                                    ,pr_tpctrrat => pr_tpctrrat  --> Tipo Contrato Rating
                                    ,pr_nrctrrat => pr_nrctrrat  --> Numero Contrato Rating
                                    ,pr_idseqttl => 1            --> Sequencial do Titular
                                    ,pr_idorigem => 1            --> Identificador Origem
                                    ,pr_nmdatela => vr_nmdatela  --> Nome da tela
                                    ,pr_flgerlog => 'N'          --> Identificador de geração de log
                                    ,pr_dsretorn => FALSE        --> Retorna
                                    ,pr_tab_rating_sing => vr_tab_rating_sing --> Registros gravados para rating singular
                                    ,pr_indrisco => vr_indrisco  --> Indicador do risco
                                    ,pr_nrnotrat => vr_nrnotrat  --> Nota do rating
                                    ,pr_rowidnrc => vr_rowidnrc  --> Rowid do rating
                                    ,pr_tab_erro => vr_tab_erro  --> Tabela de retorno de erro
                                    ,pr_des_reto => vr_des_reto  --> Ind. de retorno OK/NOK
                                    ) ;
    --Se ocorreu erro
    IF vr_des_reto = 'NOK' THEN
        
      --Se possui erro
      IF vr_tab_erro.COUNT > 0 THEN
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro na verificacao da atualizacao do Rating.';
      END IF;
        
      --Levantar Excecao  
      RAISE vr_exc_erro;
        
    END IF;
      
    --Preposto
    IF pr_insitrat = 1 THEN
      
      RATI0001.pc_proc_calcula(pr_cdcooper => vr_cdcooper  --> Codigo Cooperativa
                              ,pr_cdagenci => vr_cdagenci  --> Codigo Agencia
                              ,pr_nrdcaixa => vr_nrdcaixa  --> Numero Caixa
                              ,pr_cdoperad => vr_cdoperad  --> Codigo Operador
                              ,pr_nrdconta => pr_nrdconta  --> Numero da Conta
                              ,pr_tpctrato => pr_tpctrrat  --> Tipo Contrato Rating
                              ,pr_nrctrato => pr_nrctrrat  --> Numero Contrato Rating
                              ,pr_flgcriar => 0            --> Indicado se deve criar o rating
                              ,pr_idorigem => vr_idorigem  --> Identificador Origem
                              ,pr_nmdatela => vr_nmdatela  --> Nome da tela
                              ,pr_inproces => rw_crapdat.inproces --> Situacao do processo
                              ,pr_insitrat => pr_insitrat --> Situacao do rating
                              ,pr_rowidnrc => vr_rowidnrc           --> Registro de rating
                              ,pr_tab_rating_sing => vr_tab_rating_sing --> Registros gravados para rating singular
                              ,pr_tab_impress_risco_tl => vr_tab_impress_risco --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                              ,pr_indrisco => vr_indrisco  --> Indicador do risco
                              ,pr_nrnotrat => vr_nrnotrat  --> Nota do rating
                              ,pr_tab_erro => vr_tab_erro                      --> Tabela de retorno de erro
                              ,pr_des_reto => pr_des_erro);                    --> Ind. de retorno OK/NOK
                              
      -- Em caso de erro
      IF pr_des_erro <> 'OK' THEN
          
        --Se não tem erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN 
        
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.first).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic;
            
        ELSE         
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao calcular o Rating.';

        END IF;

                
        -- Sair
        RAISE vr_exc_erro;
      
      END IF;
      
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
            
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><Risco rowidnrc="'||vr_rowidnrc||'">');                                    
                                          
      -- Carrega os dados           
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => '<msg>O risco será '|| vr_indrisco ||' com a nota '|| vr_nrnotrat||'</msg>'); 
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => '</Risco></Root>'
                             ,pr_fecha_xml      => TRUE);
                        
      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);
        
      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);  
        
      RAISE vr_exc_saida;
      
    --Efetivo
    ELSIF pr_insitrat = 2 THEN
        
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
            
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><risco rowidnrc="'||vr_rowidnrc||'">');                                    
                                          
     -- Carrega os dados           
     gene0002.pc_escreve_xml(pr_xml            => vr_clob
                            ,pr_texto_completo => vr_dstexto
                            ,pr_texto_novo     => '<msg>O risco efetivado para o Rating será '|| vr_indrisco ||', com a nota '|| vr_nrnotrat||'</msg>'); 
            
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => '</risco></Root>'
                             ,pr_fecha_xml      => TRUE);
                        
      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);
        
      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);  
        
      RAISE vr_exc_saida;
            
    END IF;  
    
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_des_erro := 'OK';
      
    WHEN vr_exc_erro THEN 
                     
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := 'nrdconta';
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_verifica_atual_rating --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_verifica_atual_rating;
  
  PROCEDURE pc_calcula(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                      ,pr_cddopcao IN VARCHAR2              --Opção da tela
                      ,pr_nrctrrat IN crapnrc.nrctrrat%TYPE --Número do contrato
                      ,pr_tpctrrat IN crapnrc.tpctrrat%TYPE --Tipo do contrato
                      ,pr_dsdopera IN VARCHAR2              --Descricao da operacao
                      ,pr_insitrat IN crapnrc.insitrat%TYPE --Situação do rating
                      ,pr_rowidnrc IN ROWID                 --Rowid do registro
                      ,pr_indrisco IN crapnrc.indrisco%TYPE --Indicador do risco
                      ,pr_nrnotrat IN crapnrc.nrnotrat%TYPE --Nota do rating
                      ,pr_vlrating IN VARCHAR2              --Ratings
                      ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                      ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                      ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                      ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                      ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                      ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_calcula                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Atualiza o rating do cooperado
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                
      
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_clob     CLOB;
    vr_dstexto  VARCHAR2(32700); 
    vr_des_reto VARCHAR2(3);
    vr_indrisco VARCHAR2(300);
    vr_nrnotrat crapnrc.nrnotrat%TYPE;
    vr_rowidnrc ROWID;
    vr_inrisctl crapass.inrisctl%TYPE;
    vr_nrnotatl crapass.nrnotatl%TYPE;
    vr_split    gene0002.typ_split := gene0002.typ_split();
    vr_index    VARCHAR2(15);
    vr_nrtopico craprat.nrtopico%TYPE;
    vr_nritetop craprai.nritetop%TYPE;
    vr_nrseqite craprad.nrseqite%TYPE;
    vr_reg_craprat craprat.progress_recid%TYPE;
    vr_reg_craprai craprai.progress_recid%TYPE;
    vr_reg_craprad craprad.progress_recid%TYPE;
    vr_selecionado INTEGER;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    vr_exc_saida EXCEPTION;
    
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    --PL tables  
    vr_tab_impress_risco    RATI0001.typ_tab_impress_risco;
    vr_tab_crapras          RATI0001.typ_tab_crapras;
    vr_tab_erro             GENE0001.typ_tab_erro;
    
  BEGIN 
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'ATURAT'
                              ,pr_action => null); 
                                 
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
       
    IF NVL(pr_nrctrrat,0) = 0 AND
       NVL(pr_tpctrrat,0) = 0 THEN
      
      --Monta critica
      vr_cdcritic := 0;
      vr_dscritic := 'Para atualizar Rating antigo utilize a tela RATING.';
          
      RAISE vr_exc_erro; 
       
    END IF;
    
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;

    END IF;  
    
    --Somente se for CECRED
    IF vr_cdcooper = 3 THEN
    
      -- Quebrar valores da lista recebida como parametro
      IF TRIM(pr_vlrating) IS NOT NULL THEN
              
        vr_split := gene0002.fn_quebra_string(pr_string  => pr_vlrating
                                             , pr_delimit => '#');
        -- ler linhas
        FOR i IN vr_split.first..vr_split.last LOOP
                      
          vr_nrtopico:= ( gene0002.fn_busca_entrada( pr_postext => 2
                                                    ,pr_dstext  => vr_split(i)
                                                    ,pr_delimitador => '|'));
                                                
          vr_nritetop:= ( gene0002.fn_busca_entrada( pr_postext => 3
                                                    ,pr_dstext  => vr_split(i)
                                                    ,pr_delimitador => '|'));
                                                                                                       
          vr_nrseqite:= ( gene0002.fn_busca_entrada( pr_postext => 4
                                                    ,pr_dstext  => vr_split(i)
                                                    ,pr_delimitador => '|'));   
                                                    
          vr_reg_craprat:= ( gene0002.fn_busca_entrada( pr_postext => 5
                                                       ,pr_dstext  => vr_split(i)
                                                       ,pr_delimitador => '|'));
                                                
          vr_reg_craprai:= ( gene0002.fn_busca_entrada( pr_postext => 6
                                                       ,pr_dstext  => vr_split(i)
                                                       ,pr_delimitador => '|'));
                                                                                                       
          vr_reg_craprad:= ( gene0002.fn_busca_entrada( pr_postext => 7
                                                       ,pr_dstext  => vr_split(i)
                                                       ,pr_delimitador => '|'));   
                                                      
          vr_selecionado := ( gene0002.fn_busca_entrada( pr_postext => 8
                                                        ,pr_dstext  => vr_split(i)
                                                        ,pr_delimitador => '|'));                                                        
           
          IF vr_selecionado = 1 THEN   
                                                   
            -- definir indice
            vr_index := lpad(vr_nrtopico,5,'0') || lpad(vr_nritetop,5,'0') || lpad(vr_nrseqite,5,'0');
                
            -- incluir dados na temptable
            vr_tab_crapras(vr_index).nrtopico := vr_nrtopico;
            vr_tab_crapras(vr_index).nritetop := vr_nritetop;
            vr_tab_crapras(vr_index).nrseqite := vr_nrseqite;                                                         
            
          END IF;
                                                           
        END LOOP;

          
      ELSE
            
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nenhum rating selecionado.';

        --Levantar Excecao  
        RAISE vr_exc_erro;        
            
      END IF;   
     
    END IF;
           
    RATI0001.pc_proc_calcula(pr_cdcooper => vr_cdcooper --> Codigo Cooperativa
                            ,pr_cdagenci => vr_cdagenci --> Codigo Agencia
                            ,pr_nrdcaixa => vr_nrdcaixa --> Numero Caixa
                            ,pr_cdoperad => vr_cdoperad --> Codigo Operador
                            ,pr_nrdconta => pr_nrdconta --> Numero da Conta
                            ,pr_tpctrato => pr_tpctrrat --> Tipo Contrato Rating
                            ,pr_nrctrato => pr_nrctrrat --> Numero Contrato Rating
                            ,pr_flgcriar => 1           --> Indicado se deve criar o rating
                            ,pr_idorigem => vr_idorigem --> Identificador Origem
                            ,pr_nmdatela => vr_nmdatela --> Nome da tela
                            ,pr_inproces => rw_crapdat.inproces --> Situacao do processo
                            ,pr_insitrat => pr_insitrat         --> Situacao do rating
                            ,pr_rowidnrc => pr_rowidnrc                      --> Registro de rating
                            ,pr_tab_rating_sing => vr_tab_crapras            --> Registros gravados para rating singular
                            ,pr_tab_impress_risco_tl => vr_tab_impress_risco --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                            ,pr_indrisco => vr_indrisco  --> Indicador do risco
                            ,pr_nrnotrat => vr_nrnotrat  --> Nota do rating
                            ,pr_tab_erro => vr_tab_erro             --> Tabela de retorno de erro
                            ,pr_des_reto => pr_des_erro);           --> Ind. de retorno OK/NOK
                                
    -- Em caso de erro
    IF pr_des_erro <> 'OK' THEN
            
      --Se não tem erro na tabela
      IF vr_tab_erro.COUNT > 0 THEN 
      
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic;
          
      ELSE         
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro na atualizacao do Rating.';
      END IF;
              
      -- Sair
      RAISE vr_exc_erro;
          
    END IF;
      
    vr_inrisctl := vr_tab_impress_risco(vr_tab_impress_risco.first).dsdrisco;
    vr_nrnotatl := vr_tab_impress_risco(vr_tab_impress_risco.first).vlrtotal;

    BEGIN
            
      UPDATE crapass
         SET crapass.inrisctl = vr_inrisctl
            ,crapass.nrnotatl = vr_nrnotatl
       WHERE crapass.cdcooper = vr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
               
    EXCEPTION
      WHEN OTHERS THEN
         vr_cdcritic:= 0;
         vr_dscritic:= 'Nao foi possivel atualizar o risco: ' || SQLERRM;
               
         -- Sair
         RAISE vr_exc_erro;
          
    END;  
         
    pc_gera_log(pr_cdcooper => vr_cdcooper
               ,pr_cdoperad => vr_cdoperad
               ,pr_flgratin => TRUE --Possui Rating
               ,pr_nrdconta => pr_nrdconta
               ,pr_dsoperad => pr_dsdopera
               ,pr_nrctrrat => pr_nrctrrat
               ,pr_indrisco => pr_indrisco
               ,pr_nrnotrat => pr_nrnotrat
               ,pr_novorisc => vr_indrisco
               ,pr_novanota => vr_nrnotrat
               ,pr_des_erro => pr_des_erro);
                       
    pr_des_erro := 'OK';
  
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := 'nrdconta';
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_calcula --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_calcula;
   
  /* Rotina para gerar o ralatorio com os rating do cooperado */
 PROCEDURE pc_imprimir_rating(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                              ,pr_cddopcao  IN crapace.cddopcao%TYPE --> Opcao da tela
                              ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta                              
                              ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do operador
                              ,pr_cdagenci  IN crapage.cdagenci%TYPE --> Codigo da agencia
                              ,pr_nrdcaixa  IN INTEGER               --> Numero do caixa                              
                              ,pr_tab_impress_coop     IN rati0001.typ_tab_impress_coop     --> Registro impressão da Cooperado
                              ,pr_tab_impress_rating   IN rati0001.typ_tab_impress_rating   --> Registro itens do Rating
                              ,pr_tab_impress_risco_cl IN rati0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                              ,pr_tab_impress_risco_tl IN rati0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                              ,pr_tab_impress_assina   IN rati0001.typ_tab_impress_assina   --> Assinatura na impressao do Rating
                              ,pr_tab_efetivacao       IN rati0001.typ_tab_efetivacao       --> Registro dos itens da efetivação
							  ,pr_nmrelato             IN VARCHAR2                          --> Nome do relatorio
                              ,pr_nmarquiv             OUT VARCHAR2                         --> Nome do arquivo gerado
                              ,pr_tab_erro             OUT GENE0001.typ_tab_erro            --> Tabela de retorno de erro                             
                              ,pr_des_reto             OUT VARCHAR2)IS                      --> Ind. de retorno OK/NOK
                          
    /* .............................................................................
    Programa: pc_imprimir_rating                                     Antigo: fontes/imprimir_rating.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Andrei
    Data    : Maio/2016                       Ultima atualizacao:  

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para gerar o relatorio com os ratings do cooperado

    Alteracoes:  
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
     vr_index       PLS_INTEGER;
     vr_index2      PLS_INTEGER;
     vr_index3      PLS_INTEGER;
     vr_cdagenci VARCHAR2(100);
     vr_nrdcaixa VARCHAR2(100);
     vr_dsdefeti VARCHAR2(300);
         
     --Controle de erro
     vr_exc_erro EXCEPTION;      
      
    BEGIN
           
      pr_des_reto:= 'NOK';      
      
      --Limpar tabela dados      
      vr_tab_erro.DELETE;    
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'ATURAT'
                                ,pr_action => null);
                                
      -- Verifica se o associado existe
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper
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
               
        --Levantar Excecao
        RAISE vr_exc_erro;
          
        ELSE
          
          -- Fechar o cursor pois haverá raise
          CLOSE cr_crapass;        
        
        END IF;    
        
      OPEN cr_crapope(pr_cdcooper => pr_cdcooper
                     ,pr_cdoperad => pr_cdoperad);
                     
      FETCH cr_crapope INTO rw_crapope;
      
      --Fecha o cursor
      CLOSE cr_crapope;          
      
      -- Verifica se a cooperativa esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      
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
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => 'rl');
                                       
      --Nome do Arquivo
      vr_nmarquiv:= vr_nmdireto||'/'||'crrl367' || dbms_random.string('X',20) || '.lst';
      
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
                                         '" nrdconta="' || to_char(pr_tab_impress_coop(pr_tab_impress_coop.first).nrdconta,'fm9999g999g9') || 
                                         '" nmprimtl="' || pr_tab_impress_coop(pr_tab_impress_coop.first).nmprimtl ||
                                         '" nrctrrat="' || to_char(pr_tab_impress_coop(pr_tab_impress_coop.first).nrctrrat,'fm9999g999g999') ||
                                         '" dsdopera="' || pr_tab_impress_coop(pr_tab_impress_coop.first).dsdopera ||
	                                       '" dspessoa="' || pr_tab_impress_coop(pr_tab_impress_coop.first).dspessoa || '">');
        
      --Topicos do rating  
      vr_index := pr_tab_impress_rating.first;
      
      WHILE vr_index IS NOT NULL LOOP
        
        --Escrever no arquivo XML
        gene0002.pc_escreve_xml(vr_clobxml
                               ,vr_dstexto
                               ,'<topico nrtopico="' || to_char(pr_tab_impress_rating(vr_index).nrtopico,'999') || '" dstopico="'|| pr_tab_impress_rating(vr_index).dsitetop ||'">');
        
        --SubTopicos do rating  
        vr_index2 := pr_tab_impress_rating(vr_index).tab_subtopico.first;
      
        WHILE vr_index2 IS NOT NULL LOOP
          
          --Escrever no arquivo XML
          gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                                     '<subtopico nritetop="' || to_char(pr_tab_impress_rating(vr_index).tab_subtopico(vr_index2).nritetop,'999') || 
                                              '" dsitetop="' || pr_tab_impress_rating(vr_index).tab_subtopico(vr_index2).dsitetop ||
                                              '" pesoitem="' || trim(pr_tab_impress_rating(vr_index).tab_subtopico(vr_index2).dspesoit) ||'">');
          
          --Itens do rating  
          vr_index3 := pr_tab_impress_rating(vr_index).tab_subtopico(vr_index2).tab_itens.first;
        
          WHILE vr_index3 IS NOT NULL LOOP      
      
            --Escrever no arquivo XML
            gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                                      '<item>' || 
                                         '<pesosequ>' || trim(pr_tab_impress_rating(vr_index).tab_subtopico(vr_index2).tab_itens(vr_index3).dspesoit) || '</pesosequ>' ||
                                         '<dsseqite>' || pr_tab_impress_rating(vr_index).tab_subtopico(vr_index2).tab_itens(vr_index3).dsitetop || '</dsseqite>' ||                                           
                                         '<vlrdnota>' || pr_tab_impress_rating(vr_index).tab_subtopico(vr_index2).tab_itens(vr_index3).vlrdnota || '</vlrdnota>' ||                                           
                                      '</item>');          
                                   
            vr_index3 := pr_tab_impress_rating(vr_index).tab_subtopico(vr_index2).tab_itens.next(vr_index3);
          
          END LOOP;


          --Escrever no arquivo XML
          gene0002.pc_escreve_xml(vr_clobxml
                                 ,vr_dstexto
                                 ,'</subtopico>');
                                 
          vr_index2 := pr_tab_impress_rating(vr_index).tab_subtopico.next(vr_index2);
        
        END LOOP;

        
        --Escrever no arquivo XML
        gene0002.pc_escreve_xml(vr_clobxml
                               ,vr_dstexto
                               ,'</topico>');
                               
        vr_index := pr_tab_impress_rating.next(vr_index);
      
      END LOOP;
        
      vr_index := pr_tab_efetivacao.first;
      
      IF vr_index IS NOT NULL THEN
        vr_dsdefeti:= pr_tab_efetivacao(vr_index).dsdefeti;                                                    
      ELSE
        vr_dsdefeti := ' ';
      END IF ;
                                                   
      --Escrever no arquivo XML
      gene0002.pc_escreve_xml(vr_clobxml
                             ,vr_dstexto                             
                             ,'<deslegenda>'  || 
                                  '<dsdriscotl>' || pr_tab_impress_risco_tl(pr_tab_impress_risco_tl.first).dsdrisco || '</dsdriscotl>' ||
                                  '<vlrtotaltl>' || to_char(pr_tab_impress_risco_tl(pr_tab_impress_risco_tl.first).vlrtotal,'fm99999g999g990d00')  || '</vlrtotaltl>' ||
                                  '<nrnotaope>'  || to_char(pr_tab_impress_risco_cl(pr_tab_impress_risco_cl.first).vlrtotal - pr_tab_impress_risco_tl(pr_tab_impress_risco_tl.first).vlrtotal,'fm99999g999g990d00')  || '</nrnotaope>' ||
                                  '<dsdriscocl>' || pr_tab_impress_risco_cl(pr_tab_impress_risco_cl.first).dsdrisco  || '</dsdriscocl>' ||
                                  '<vlrtotalcl>' || to_char(pr_tab_impress_risco_cl(pr_tab_impress_risco_cl.first).vlrtotal,'fm99999g999g990d00')  || '</vlrtotalcl>' || 
                                  '<vlprovis>'   || to_char(pr_tab_impress_risco_cl(pr_tab_impress_risco_cl.first).vlprovis,'fm99999g999g990d00')  || '</vlprovis>' ||
                                  '<parecer>'    || pr_tab_impress_risco_cl(pr_tab_impress_risco_tl.first).dsparece || '</parecer>' ||
                              '</deslegenda>'  ||                              
                              '<obervacao>' || 
                                  '<dsdefeti>' || vr_dsdefeti || '</dsdefeti>' ||
                              '</obervacao>');                                 
          
      --Finaliza TAG Relatorio
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</crrl367>',TRUE); 
   
      -- Gera relatório crrl657
	    gene0002.pc_solicita_relato(pr_cdcooper    => pr_cdcooper    --> Cooperativa conectada
                                   ,pr_cdprogra  => 'RATING'--vr_nmdatela         --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt         --> Data do movimento atual
                                   ,pr_dsxml     => vr_clobxml          --> Arquivo XML de dados
                                   ,pr_dsxmlnode => 'crrl367/topico/subtopico/item'          --> Nó base do XML para leitura dos dados                                  
                                   ,pr_dsjasper  => pr_nmrelato         --> Arquivo de layout do iReport
                                   ,pr_dsparams  => NULL                --> Sem parâmetros
                                   ,pr_dsarqsaid => vr_nmarqpdf         --> Arquivo final com o path
                                   ,pr_qtcoluna  => 132                  --> Colunas do relatorio
                                   ,pr_flg_gerar => 'S'                 --> Geraçao na hora
                                   ,pr_cdrelato  => '367'               --> Código do relatório
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
      gene0002.pc_efetua_copia_pdf (pr_cdcooper => pr_cdcooper     --> Cooperativa conectada
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
      
      pr_nmarquiv:= vr_nmarqpdf;
            
      pr_des_reto := 'OK';      
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_reto:= 'NOK';
        
        -- Se ainda não tem registro de erro, criar com a critica
        IF pr_tab_erro.COUNT = 0 THEN
          -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        END IF;

                            
                                       
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto:= 'NOK';
        
        -- Erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro na TELA_ATURAT.pc_imprimir_rating --> '|| SQLERRM;    
        
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
                                    
        
  END pc_imprimir_rating;

  PROCEDURE pc_gera_rating(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                          ,pr_cddopcao IN VARCHAR2              --Opção da tela
                          ,pr_nrctrrat IN crapnrc.nrctrrat%TYPE --Número do contrato
                          ,pr_tpctrrat IN crapnrc.tpctrrat%TYPE --Tipo do contrato
                          ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                          ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gera_rating                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Atualiza o rating do cooperado
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                
      
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := '';      
    vr_index    PLS_INTEGER;
    vr_nmarquiv VARCHAR2(400);
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;    
    
    --PL tables  
    vr_tab_impress_coop     RATI0001.typ_tab_impress_coop;
    vr_tab_impress_rating   RATI0001.typ_tab_impress_rating;
    vr_tab_impress_risco_cl RATI0001.typ_tab_impress_risco;
    vr_tab_impress_risco_tl RATI0001.typ_tab_impress_risco;
    vr_tab_impress_assina   RATI0001.typ_tab_impress_assina;
    vr_tab_efetivacao       RATI0001.typ_tab_efetivacao;
    vr_tab_ratings          RATI0001.typ_tab_ratings;
    vr_tab_crapras          RATI0001.typ_tab_crapras;
    vr_tab_erro             GENE0001.typ_tab_erro;
    
  BEGIN 
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'ATURAT'
                              ,pr_action => null); 
                                 
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
       
    IF NVL(pr_nrctrrat,0) = 0 AND
       NVL(pr_tpctrrat,0) = 0 THEN
      
      --Monta critica
      vr_cdcritic := 0;
      vr_dscritic := 'Para atualizar Rating antigo utilize a tela RATING.';
          
      RAISE vr_exc_erro; 
       
    END IF;
    
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;

    END IF;
    
    RATI0001.pc_gera_rating(pr_cdcooper => vr_cdcooper         --> Codigo Cooperativa
                           ,pr_cdagenci => vr_cdagenci         --> Codigo Agencia
                           ,pr_nrdcaixa => vr_nrdcaixa         --> Numero Caixa
                           ,pr_cdoperad => vr_cdoperad         --> Codigo Operador
                           ,pr_nmdatela => vr_nmdatela          --> Nome da tela
                           ,pr_idorigem => vr_idorigem         --> Identificador Origem
                           ,pr_nrdconta => pr_nrdconta         --> Numero da Conta
                           ,pr_idseqttl => 1                   --> Sequencial do Titular
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data de movimento
                           ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> Data do próximo dia útil
                           ,pr_inproces => rw_crapdat.inproces --> Situação do processo
                           ,pr_tpctrrat => pr_tpctrrat         --> Tipo Contrato Rating
                           ,pr_nrctrrat => pr_nrctrrat         --> Numero Contrato Rating
                           ,pr_flgcriar => 0                   --> Não Criar rating
                           ,pr_flgerlog => 1                      --> Identificador de geração de log
                           ,pr_tab_rating_sing => vr_tab_crapras  --> Registros gravados para rating singular
                           ,pr_tab_impress_coop => vr_tab_impress_coop     --> Registro impressão da Cooperado
                           ,pr_tab_impress_rating => vr_tab_impress_rating   --> Registro itens do Rating
                           ,pr_tab_impress_risco_cl => vr_tab_impress_risco_cl    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                           ,pr_tab_impress_risco_tl => vr_tab_impress_risco_tl    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                           ,pr_tab_impress_assina   => vr_tab_impress_assina   --> Assinatura na impressao do Rating
                           ,pr_tab_efetivacao       => vr_tab_efetivacao       --> Registro dos itens da efetivação
                           ,pr_tab_ratings          => vr_tab_ratings          --> Informacoes com os Ratings do Cooperado
                           ,pr_tab_crapras          => vr_tab_crapras          --> Tabela com os registros processados
                           ,pr_tab_erro             => vr_tab_erro             --> Tabela de retorno de erro
                           ,pr_des_reto             => pr_des_erro             --> Ind. de retorno OK/NOK
                           );
                           
    -- Em caso de erro
    IF pr_des_erro <> 'OK' THEN
          
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
        
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><criticas>');      
        
      vr_index := vr_tab_erro.first;
      
      WHILE vr_index IS NOT NULL LOOP 
        
        pr_cdcritic:= vr_tab_erro(vr_index).cdcritic;
        pr_dscritic:= vr_tab_erro(vr_index).dscritic;
        
        -- Carrega os dados           
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<critica>'||                                                       
                                                     '  <descricao>' || vr_tab_erro(vr_index).cdcritic ||'-'||vr_tab_erro(vr_index).dscritic||'</descricao>'||
                                                     '</critica>');  
                                                     
                                                      
        --Proximo Registro
        vr_index:= vr_tab_ratings.NEXT(vr_index);
          
      END LOOP;
        
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</criticas></Root>'
                             ,pr_fecha_xml      => TRUE);
                    
      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);

      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);   

      pr_des_erro := 'NOK'; 
          
      RETURN;
      
    END IF;
           
    pc_imprimir_rating(pr_cdcooper  => vr_cdcooper --> Codigo da cooperativa
                      ,pr_cddopcao  => pr_cddopcao --> Opcao da tela
                      ,pr_nrdconta  => pr_nrdconta --> Número da Conta                              
                      ,pr_cdoperad  => vr_cdoperad --> Codigo do operador
                      ,pr_cdagenci  => vr_cdagenci --> Codigo da agencia
                      ,pr_nrdcaixa  => vr_nrdcaixa --> Numero do caixa
                      ,pr_tab_impress_coop     => vr_tab_impress_coop     --> Registro impressão da Cooperado
                      ,pr_tab_impress_rating   => vr_tab_impress_rating   --> Registro itens do Rating
                      ,pr_tab_impress_risco_cl => vr_tab_impress_risco_cl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                      ,pr_tab_impress_risco_tl => vr_tab_impress_risco_tl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                      ,pr_tab_impress_assina   => vr_tab_impress_assina   --> Assinatura na impressao do Rating
                      ,pr_tab_efetivacao       => vr_tab_efetivacao       --> Registro dos itens da efetivação
					  ,pr_nmrelato             => 'aturat_risco.jasper'   --> Nome do relatorio
                      ,pr_nmarquiv             => vr_nmarquiv             --> Nome do arquivo gerado
                      ,pr_tab_erro             => vr_tab_erro             --> Tabela de retorno de erro                             
                      ,pr_des_reto             => pr_des_erro);           --> Ind. de retorno OK/NOK
        
    
    IF pr_des_erro <> 'OK' THEN      
         
      vr_cdcritic := 0;
      vr_dscritic := 'Nao foi possivel gerar o relatorio.';
        
      RAISE vr_exc_erro;
      
    END IF;
    
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
        
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?>'|| 
                                                 '<Dados>' ||
                                                   '<relatorio>'||                                                       
                                                      '<nmarquiv>' || vr_nmarquiv ||'</nmarquiv>'||
                                                   '</relatorio>'||
                                                 '</Dados>'
                           ,pr_fecha_xml      => TRUE);      
        
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);  
             
    pr_des_erro := 'OK';  
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := 'nrdconta';
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_gera_rating --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_gera_rating;
  
  PROCEDURE pc_busca_ratings (pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                             ,pr_cddopcao IN VARCHAR2              --Opção
                             ,pr_dtinirat IN VARCHAR2              --Data inicial
                             ,pr_dtfinrat IN VARCHAR2              --Data final
                             ,pr_cdagesel IN crapage.cdagenci%TYPE --Agencia 
                             ,pr_tprelato IN INTEGER               --Tipo do relatorio 
                             ,pr_nrregist IN INTEGER               --> Número de registros
                             ,pr_nriniseq IN INTEGER               --> Número sequencial 
                             ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                             ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_ratings                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                         Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca os ratings
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                               
  
    --Busca agencia
    CURSOR cr_crapage(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
    SELECT crapage.cdagenci
          ,crapage.nmresage
      FROM crapage
     WHERE crapage.cdcooper = pr_cdcooper
       AND crapage.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%ROWTYPE;                 
                     
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_dtinirat DATE;
    vr_dtfinrat DATE;
    vr_des_erro VARCHAR2(10);
    vr_nmdireto VARCHAR2(100);
    vr_nmarqpdf VARCHAR2(1000);
    vr_nmarquiv VARCHAR2(1000);
    vr_des_reto VARCHAR2(3);  
    vr_comando  VARCHAR2(1000);
    vr_typ_saida VARCHAR2(3);  
    vr_qtregist INTEGER :=0;
    vr_nrregist INTEGER:=0;
    vr_ctrlagen crapage.cdagenci%TYPE;
    
    --TABELAS
    vr_tab_ratings RATI0001.typ_tab_ratings;
    
    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
     
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    --Variaveis Locais   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := '';      
    vr_index    PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
  BEGIN
                                                
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'ATURAT'
                              ,pr_action => null); 
    
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
    
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
                                                
    BEGIN                                                  
      --Pega a data inicial
      vr_dtinirat := to_date(pr_dtinirat,'DD/MM/RRRR'); 
                      
    EXCEPTION
      WHEN OTHERS THEN
          
        --Monta mensagem de critica
        vr_dscritic := 'Data inicial invalida.';
        pr_nmdcampo := 'dtinirat';
          
        --Gera exceção
        RAISE vr_exc_erro;
    END;
      
    BEGIN                                                  
      --Pega a data  final
      vr_dtfinrat := to_date(pr_dtfinrat,'DD/MM/RRRR'); 
                      
    EXCEPTION
      WHEN OTHERS THEN
          
        --Monta mensagem de critica
        vr_dscritic := 'Data final invalida.';
        pr_nmdcampo := 'dtfinrat';
          
        --Gera exceção
        RAISE vr_exc_erro;
    END;         
      
    IF vr_dtinirat > rw_crapdat.dtmvtolt THEN
      
      --Monta mensagem de critica
      vr_dscritic := 'Data inicial invalida.';
      pr_nmdcampo := 'dtinirat';
          
      --Gera exceção
      RAISE vr_exc_erro;
      
    END IF;
    
    IF vr_dtfinrat > rw_crapdat.dtmvtolt OR
       vr_dtfinrat < vr_dtinirat         THEN
      
      --Monta mensagem de critica
      vr_dscritic := 'Data final invalida.';
      pr_nmdcampo := 'dtfinrat';
          
      --Gera exceção
      RAISE vr_exc_erro;
      
    END IF;
    
    IF pr_cddopcao = 'R' AND 
       pr_tprelato = 2   THEN
      
      vr_nrregist:= 999999;
    
    ELSE
      
      vr_nrregist:= pr_nrregist;
    
    END IF;
    
    RATI0001.pc_ratings_cooperado(pr_cdcooper => vr_cdcooper --> Cooperativa conectada
                                 ,pr_cdagenci => pr_cdagesel --> Código da agência
                                 ,pr_nrdconta => pr_nrdconta --> Conta do associado
                                 ,pr_nrregist => vr_nrregist --> Número de registros
                                 ,pr_nriniseq => pr_nriniseq --> Número sequencial 
                                 ,pr_dtinirat => vr_dtinirat --> Data de início do Rating
                                 ,pr_dtfinrat => vr_dtfinrat --> Data de termino do Rating
                                 ,pr_insitrat => 0           --> Situação do Rating ( 0 = Todas as situações)
                                 ,pr_qtregist => vr_qtregist --> Quantidade de registros encontrados
                                 ,pr_tab_ratings => vr_tab_ratings --> Registro com os ratings do associado
                                 ,pr_des_reto    => vr_des_erro);  --> Indicador erro
     
    IF vr_des_erro <> 'OK' THEN      
         
      vr_cdcritic := 0;
      vr_dscritic := 'Nao foi possivel buscar os ratings.';
        
      RAISE vr_exc_erro;
      
    END IF;
     
    IF pr_cddopcao <> 'R' OR 
       pr_cddopcao = 'R'  AND 
       pr_tprelato = 1    THEN
        
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
        
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><ratings qtregist="' || nvl(vr_qtregist,0) || '">');      
        
      vr_index := vr_tab_ratings.first;
      
      WHILE vr_index IS NOT NULL LOOP                 
        -- Carrega os dados           
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<rating>'||                                                       
                                                     '  <cdagenci>' || vr_tab_ratings(vr_index).cdagenci ||'</cdagenci>'||
                                                     '  <nrdconta>' || LTrim(RTRIM(gene0002.fn_mask(vr_tab_ratings(vr_index).nrdconta, 'zzzz.zzz.9')))||'</nrdconta>'||
                                                     '  <nrctrrat>' || gene0002.fn_mask(vr_tab_ratings(vr_index).nrctrrat,'zzzz.zzz') ||'</nrctrrat>'||
                                                     '  <tpctrrat>' || vr_tab_ratings(vr_index).tpctrrat ||'</tpctrrat>'||
                                                     '  <indrisco>' || vr_tab_ratings(vr_index).indrisco ||'</indrisco>'|| 
                                                     '  <dtmvtolt>' || to_char(vr_tab_ratings(vr_index).dtmvtolt,'dd/mm/rrrr') ||'</dtmvtolt>'||
                                                     '  <dteftrat>' || to_char(vr_tab_ratings(vr_index).dteftrat,'dd/mm/rrrr') ||'</dteftrat>'||
                                                     '  <cdoperad>' || vr_tab_ratings(vr_index).cdoperad ||'</cdoperad>'||
                                                     '  <nmoperad>' || vr_tab_ratings(vr_index).nmoperad ||'</nmoperad>'||
                                                     '  <insitrat>' || vr_tab_ratings(vr_index).insitrat ||'</insitrat>'||
                                                     '  <nrnotrat>' || to_char(vr_tab_ratings(vr_index).nrnotrat,'fm990d00') ||'</nrnotrat>'||
                                                     '  <nrnotatl>' || to_char(vr_tab_ratings(vr_index).nrnotatl,'fm990d00') ||'</nrnotatl>'||
                                                     '  <inrisctl>' || vr_tab_ratings(vr_index).inrisctl ||'</inrisctl>'||
                                                     '  <vlutlrat>' || vr_tab_ratings(vr_index).vlutlrat ||'</vlutlrat>'||
                                                     '  <flgorige>' || vr_tab_ratings(vr_index).flgorige ||'</flgorige>'||
                                                     '  <vloperac>' || nvl(vr_tab_ratings(vr_index).vloperac,0) ||'</vloperac>'||
                                                     '  <dsdopera>' || nvl(vr_tab_ratings(vr_index).dsdopera,' ') ||'</dsdopera>'||
                                                     '  <dsditrat>' || vr_tab_ratings(vr_index).dsditrat ||'</dsditrat>'||
                                                     '</rating>');  
        
        --Proximo Registro
        vr_index:= vr_tab_ratings.NEXT(vr_index);
          
      END LOOP;
        
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</ratings></Root>'
                             ,pr_fecha_xml      => TRUE);
                    
      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);
      
      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);   
      
    ELSE
    
      IF vr_tab_ratings.count = 0 THEN
        
        vr_cdcritic := 0;
        vr_dscritic := 'Nenhum Rating foi encontrado para estas condicoes.';
          
        RAISE vr_exc_erro;
        
      END IF;
       
      --Buscar Diretorio Padrao da Cooperativa
      vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => 'rl');
                                       
      --Nome do Arquivo
      vr_nmarquiv:= vr_nmdireto||'/'||'crrl539.lst';
      
      --Nome do Arquivo PDF
      vr_nmarqpdf:= REPLACE(vr_nmarquiv,'.lst','.pdf');
      
      -- Inicializar as informações do XML de dados para o relatório
      dbms_lob.createtemporary(vr_clob, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);

      --Escrever no arquivo XML
      gene0002.pc_escreve_xml(vr_clob,
                              vr_xml_temp,
                               '<?xml version="1.0" encoding="UTF-8"?>' || 
                                  '<crrl539>');                                  
                                  
      vr_index := vr_tab_ratings.first;
      
      vr_ctrlagen := 0;
                                       
      WHILE vr_index IS NOT NULL LOOP
                     
                    
        IF vr_ctrlagen <> vr_tab_ratings(vr_index).cdagenci THEN
         
          OPEN cr_crapage(pr_cdcooper =>  vr_cdcooper
                         ,pr_cdagenci =>  vr_tab_ratings(vr_index).cdagenci);
                         
          FETCH cr_crapage INTO rw_crapage;
          
          IF cr_crapage%FOUND THEN
            
            --Inicaliza tag agencia
            gene0002.pc_escreve_xml(vr_clob,vr_xml_temp,'<agencia cdagenci="'|| gene0002.fn_mask(rw_crapage.cdagenci,'zz9') || ' ' || rw_crapage.nmresage || '">');

          ELSE
            --Inicaliza tag agencia
            gene0002.pc_escreve_xml(vr_clob,vr_xml_temp,'<agencia cdagenci="PA NAO CADASTRADO">');
          
          END IF;
          
          --Fechar o curosr 
          CLOSE cr_crapage;
          
          vr_ctrlagen := vr_tab_ratings(vr_index).cdagenci;
              
        END IF;
        
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<rating>'||                                                       
                                                     '  <cdagenci>' || vr_tab_ratings(vr_index).cdagenci ||'</cdagenci>'||
                                                     '  <nrdconta>' || LTrim(RTRIM(gene0002.fn_mask(vr_tab_ratings(vr_index).nrdconta, 'zzzz.zzz.9')))||'</nrdconta>'||
                                                     '  <nrctrrat>' || gene0002.fn_mask(vr_tab_ratings(vr_index).nrctrrat,'zzzz.zzz') ||'</nrctrrat>'||
                                                     '  <tpctrrat>' || vr_tab_ratings(vr_index).tpctrrat ||'</tpctrrat>'||
                                                     '  <indrisco>' || vr_tab_ratings(vr_index).indrisco ||'</indrisco>'|| 
                                                     '  <dtmvtolt>' || to_char(vr_tab_ratings(vr_index).dtmvtolt,'dd/mm/rrrr') ||'</dtmvtolt>'||
                                                     '  <dteftrat>' || to_char(vr_tab_ratings(vr_index).dteftrat,'dd/mm/rrrr') ||'</dteftrat>'||
                                                     '  <cdoperad>' || vr_tab_ratings(vr_index).cdoperad ||'</cdoperad>'||
                                                     '  <nmoperad>' || vr_tab_ratings(vr_index).nmoperad ||'</nmoperad>'||
                                                     '  <insitrat>' || vr_tab_ratings(vr_index).insitrat ||'</insitrat>'||
                                                     '  <nrnotrat>' || to_char(vr_tab_ratings(vr_index).nrnotrat,'fm990d00') ||'</nrnotrat>'||
                                                     '  <nrnotatl>' || to_char(vr_tab_ratings(vr_index).nrnotatl,'fm990d00') ||'</nrnotatl>'||
                                                     '  <inrisctl>' || vr_tab_ratings(vr_index).inrisctl ||'</inrisctl>'||
                                                     '  <vlutlrat>' || to_char(vr_tab_ratings(vr_index).vlutlrat,'fm99999g990d00') ||'</vlutlrat>'||
                                                     '  <flgorige>' || vr_tab_ratings(vr_index).flgorige ||'</flgorige>'||
                                                     '  <vloperac>' || nvl(to_char(vr_tab_ratings(vr_index).vloperac,'fm99999g990d00'),0) ||'</vloperac>'||
                                                     '  <dsdopera>' || nvl(vr_tab_ratings(vr_index).dsdopera,' ') ||'</dsdopera>'||
                                                     '  <dsditrat>' || vr_tab_ratings(vr_index).dsditrat ||'</dsditrat>'||
                                                     '</rating>');  
         
        IF vr_index = vr_tab_ratings.last THEN
          --Pega o proximo registro
          vr_index := vr_tab_ratings.next(vr_index);
          
          --Finaliza TAG agencia
          gene0002.pc_escreve_xml(vr_clob,vr_xml_temp,'</agencia>');  
        ELSE
        
          --Pega o proximo registro
          vr_index := vr_tab_ratings.next(vr_index);
          
          IF vr_ctrlagen <> vr_tab_ratings(vr_index).cdagenci THEN        
          
           --Finaliza TAG agencia
           gene0002.pc_escreve_xml(vr_clob,vr_xml_temp,'</agencia>');    
               
          END IF;
        
        END IF;
                                      
      END LOOP;     
        
      --Finaliza TAG Relatorio
      gene0002.pc_escreve_xml(vr_clob,vr_xml_temp,'</crrl539>',TRUE); 
     
      -- Gera relatório crrl657
      gene0002.pc_solicita_relato(pr_cdcooper    => vr_cdcooper    --> Cooperativa conectada
                                 ,pr_cdprogra  => 'RATING'--vr_nmdatela         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt         --> Data do movimento atual
                                 ,pr_dsxml     => vr_clob          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl539/agencia/rating'          --> Nó base do XML para leitura dos dados                                  
                                 ,pr_dsjasper  => 'crrl539.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nmarqpdf         --> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                  --> Colunas do relatorio
                                 ,pr_flg_gerar => 'S'                 --> Geraçao na hora
                                 ,pr_cdrelato  => '539'               --> Códigod do relatório
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
      dbms_lob.close(vr_clob);
      dbms_lob.freetemporary(vr_clob);  
      
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

      -- Insere atributo na tag Dados com o valor total de agendamentos
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'Dados'             --> Nome da TAG XML
                               ,pr_atrib => 'nmarquiv'          --> Nome do atributo
                               ,pr_atval => substr(vr_nmarqpdf,instr(vr_nmarqpdf,'/',-1)+1)         --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                                   
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;   
      
    END IF;
                                              
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_ratings --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_busca_ratings;  
  
  /* Rotina para buscar os rating das singulares */
  PROCEDURE pc_busca_rating_singulares(pr_cddopcao IN crapace.cddopcao%TYPE --> Opcao da tela
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_nrregist IN INTEGER                --> Número de registros
                                      ,pr_nriniseq IN INTEGER                --> Número sequencial 
                                      ,pr_nrctrrat IN crapras.nrctrrat%TYPE  --> Numero do contrato
                                      ,pr_tpctrrat IN crapras.tpctrrat%TYPE  --> Tipo do contrato
                                      ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_busca_rating_singulares
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Andrei
    Data    : Maio/2016                       Ultima atualizacao: 06/06/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar o rating da singular

    Alteracoes:   06/06/2017 - Ordenação da tela ATURAT (Andrey Formigari - Mouts)
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
            
     --Encontra os itens de rating
     CURSOR cr_rating(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_inpessoa IN crapass.inpessoa%TYPE) IS
     SELECT craprat.progress_recid progress_recid_rat               
           ,craprat.nrtopico
           ,craprat.dstopico      
           ,craprai.progress_recid progress_recid_rai           
           ,craprai.nritetop           
           ,craprai.pesoitem          
           ,craprai.dsitetop 
           ,craprad.dsseqite
           ,craprad.progress_recid progress_recid_rad
           ,craprad.nrseqite           
           ,craprad.pesosequ    
           ,row_number() over (partition by craprat.nrtopico, craprai.nritetop
                               order by craprat.nrtopico, craprai.nritetop, craprad.nrseqite ) nrreg 
           ,(SELECT COUNT(*) 
               FROM craprad 
              WHERE craprad.cdcooper = craprai.cdcooper
                AND craprad.nrtopico = craprai.nrtopico
                AND craprad.nritetop = craprai.nritetop) qtdMax
      FROM craprat
          ,craprai
          ,craprad
     WHERE craprat.cdcooper = pr_cdcooper
       AND craprat.nrtopico >= 0
       AND craprat.inpessoa = pr_inpessoa
       AND craprat.flgativo = 1
       AND craprai.cdcooper = craprat.cdcooper       
       AND craprai.nrtopico = craprat.nrtopico
       AND craprad.cdcooper = craprai.cdcooper
       AND craprad.nrtopico = craprai.nrtopico
       AND craprad.nritetop = craprai.nritetop;  
     rw_rating cr_rating%ROWTYPE;
     
     --Encontra os rating selecionados do cooperado
     CURSOR cr_crapras(pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE
                      ,pr_nrctrrat IN crapras.nrctrrat%TYPE
                      ,pr_tpctrrat IN crapras.tpctrrat%TYPE
                      ,pr_nrtopico IN crapras.nrtopico%TYPE
                      ,pr_nritetop IN crapras.nritetop%TYPE
                      ,pr_nrseqite IN crapras.nrseqite%TYPE)IS
     SELECT crapras.cdcooper
      FROM crapras
     WHERE crapras.cdcooper = pr_cdcooper
       AND crapras.nrdconta = pr_nrdconta
       AND crapras.nrctrrat = pr_nrctrrat
       AND crapras.tpctrrat = pr_tpctrrat
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
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?>' ||
                                        '<dados/>');
              
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
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating', pr_posicao => vr_contador, pr_tag_nova => 'reg_craprat', pr_tag_cont => rw_rating.progress_recid_rat, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating', pr_posicao => vr_contador, pr_tag_nova => 'reg_craprai', pr_tag_cont => rw_rating.progress_recid_rai, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating', pr_posicao => vr_contador, pr_tag_nova => 'reg_craprad', pr_tag_cont => rw_rating.progress_recid_rad, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating', pr_posicao => vr_contador, pr_tag_nova => 'nota', pr_tag_cont => To_Char((rw_rating.pesoitem * rw_rating.pesosequ),'fm999g999g999g990d00'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating', pr_posicao => vr_contador, pr_tag_nova => 'nrtopico', pr_tag_cont => rw_rating.nrtopico, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating', pr_posicao => vr_contador, pr_tag_nova => 'nritetop', pr_tag_cont => rw_rating.nritetop, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating', pr_posicao => vr_contador, pr_tag_nova => 'nrseqite', pr_tag_cont => rw_rating.nrseqite, pr_des_erro => vr_dscritic);
                                                            
          OPEN cr_crapras(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrctrrat => pr_nrctrrat
                         ,pr_tpctrrat => pr_tpctrrat
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
        
        IF rw_rating.nrreg = rw_rating.qtdmax THEN
                  
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
        pr_dscritic:= 'Erro na TELA_RATING.pc_busca_rating_singulares --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');        
        
  END pc_busca_rating_singulares;
  PROCEDURE pc_gera_rating_proposta(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                   ,pr_cddopcao IN VARCHAR2              --Opção da tela
                                   ,pr_nrctrrat IN crapnrc.nrctrrat%TYPE --Número do contrato
                                   ,pr_tpctrrat IN crapnrc.tpctrrat%TYPE --Tipo do contrato
                                   ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2) IS
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := '';      
    vr_index    varchar2(25);
    vr_nmarquiv VARCHAR2(400);
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;    
    --PL tables  
    vr_tab_impress_coop     RATI0001.typ_tab_impress_coop;
    vr_tab_impress_rating   RATI0001.typ_tab_impress_rating;
    vr_tab_impress_risco_cl RATI0001.typ_tab_impress_risco;
    vr_tab_impress_risco_tl RATI0001.typ_tab_impress_risco;
    vr_tab_impress_assina   RATI0001.typ_tab_impress_assina;
    vr_tab_efetivacao       RATI0001.typ_tab_efetivacao;
    vr_tab_ratings          RATI0001.typ_tab_ratings;
    vr_tab_crapras          RATI0001.typ_tab_crapras;
    vr_tab_erro             GENE0001.typ_tab_erro;
    cursor c_rating is
      select t.nrtopico
           , t.nritetop
           , t.nrseqite
        from tbrat_hist_cooperado t
       where t.cdcooper = vr_cdcooper
         and t.nrdconta = pr_nrdconta
         and t.nrctrrat = pr_nrctrrat
         and t.tpctrrat = pr_tpctrrat
         and t.nrseqrat = 1;
  BEGIN
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'ATENDA'
                              ,pr_action => null); 
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
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);      
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    for r_rating in c_rating loop
      vr_index := lpad(r_rating.nrtopico,5,'0') || lpad(r_rating.nritetop,5,'0') || lpad(r_rating.nrseqite,5,'0');
      -- incluir dados na temptable
      vr_tab_crapras(vr_index).nrtopico := r_rating.nrtopico;
      vr_tab_crapras(vr_index).nritetop := r_rating.nritetop;
      vr_tab_crapras(vr_index).nrseqite := r_rating.nrseqite;
    end loop;
    if vr_tab_crapras.count > 0 then
      rati0001.pc_gera_arq_impress_rating(pr_cdcooper => vr_cdcooper
                                        , pr_cdagenci => vr_cdagenci
                                        , pr_nrdcaixa => vr_nrdcaixa
                                        , pr_cdoperad => vr_cdoperad
                                        , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        , pr_nrdconta => pr_nrdconta
                                        , pr_tpctrato => pr_tpctrrat
                                        , pr_nrctrato => pr_nrctrrat
                                        , pr_flgcriar => 0
                                        , pr_flgcalcu => 1
                                        , pr_idseqttl => 1
                                        , pr_idorigem => vr_idorigem
                                        , pr_nmdatela => vr_nmdatela
                                        , pr_flgerlog => 'N'
                                        , pr_tab_crapras => vr_tab_crapras
                                        , pr_tab_impress_coop => vr_tab_impress_coop
                                        , pr_tab_impress_rating => vr_tab_impress_rating
                                        , pr_tab_impress_risco_cl => vr_tab_impress_risco_cl
                                        , pr_tab_impress_risco_tl => vr_tab_impress_risco_tl
                                        , pr_tab_impress_assina => vr_tab_impress_assina
                                        , pr_tab_efetivacao => vr_tab_efetivacao
                                        , pr_tab_erro => vr_tab_erro
                                        , pr_des_reto => pr_des_erro);
      -- Em caso de erro
      IF pr_des_erro <> 'OK' THEN
        -- Sair
        RAISE vr_exc_erro;
      END IF;
    else
      vr_cdcritic := 0;
      vr_dscritic := 'Nao existe rating proposta para esse contrato!';
      RAISE vr_exc_erro;
    end if;
    pc_imprimir_rating(pr_cdcooper  => vr_cdcooper --> Codigo da cooperativa
                      ,pr_cddopcao  => pr_cddopcao --> Opcao da tela
                      ,pr_nrdconta  => pr_nrdconta --> Número da Conta                              
                      ,pr_cdoperad  => vr_cdoperad --> Codigo do operador
                      ,pr_cdagenci  => vr_cdagenci --> Codigo da agencia
                      ,pr_nrdcaixa  => vr_nrdcaixa --> Numero do caixa
                      ,pr_tab_impress_coop     => vr_tab_impress_coop     --> Registro impressão da Cooperado
                      ,pr_tab_impress_rating   => vr_tab_impress_rating   --> Registro itens do Rating
                      ,pr_tab_impress_risco_cl => vr_tab_impress_risco_cl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                      ,pr_tab_impress_risco_tl => vr_tab_impress_risco_tl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                      ,pr_tab_impress_assina   => vr_tab_impress_assina   --> Assinatura na impressao do Rating
                      ,pr_tab_efetivacao       => vr_tab_efetivacao       --> Registro dos itens da efetivação
					  ,pr_nmrelato             => 'aturat_risco_pro.jasper'   --> Nome do relatorio
                      ,pr_nmarquiv             => vr_nmarquiv             --> Nome do arquivo gerado
                      ,pr_tab_erro             => vr_tab_erro             --> Tabela de retorno de erro                             
                      ,pr_des_reto             => pr_des_erro);           --> Ind. de retorno OK/NOK
    IF pr_des_erro <> 'OK' THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Nao foi possivel gerar o relatorio.';
      RAISE vr_exc_erro;
    END IF;
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?>'|| 
                                                 '<Dados>' ||
                                                   '<relatorio>'||                                                       
                                                      '<nmarquiv>' || vr_nmarquiv ||'</nmarquiv>'||
                                                   '</relatorio>'||
                                                 '</Dados>'
                           ,pr_fecha_xml      => TRUE);      
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);  
    pr_des_erro := 'OK'; 
  EXCEPTION
    WHEN vr_exc_erro THEN 
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK'; 
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
    WHEN OTHERS THEN 
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_gera_rating_proposta --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
  END;
 
END TELA_ATURAT;
/
