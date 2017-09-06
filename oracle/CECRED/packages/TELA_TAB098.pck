CREATE OR REPLACE PACKAGE CECRED.TELA_TAB098 IS

  PROCEDURE pc_consultar(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                        ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                        ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                        ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                        ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_atualizar(pr_cdcooper                IN crapcop.cdcooper%TYPE
                        ,pr_cdoperad                IN VARCHAR2    
                        ,pr_prz_baixa_cip           IN VARCHAR2
                        ,pr_vlvrboleto              IN VARCHAR2
                        ,pr_vlcontig_cip            IN VARCHAR2
                        ,pr_xmllog     IN VARCHAR2 --> XML com informacoes de LOG
                        ,pr_cdcritic   OUT PLS_INTEGER --> Codigo da critica
                        ,pr_dscritic   OUT VARCHAR2 --> Descricao da critica
                        ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                        ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                        ,pr_des_erro   OUT VARCHAR2); --> Erros do processo

END TELA_TAB098;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_TAB098 IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_TAB098
  --  Sistema  : Ayllos Web
  --  Autor    : Ricardo Linhares
  --  Data     : Dezembro - 2016                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela TAB098
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

 
  FUNCTION fn_buscar_param(pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_cdacesso IN VARCHAR2) RETURN VARCHAR2 IS
                          
  BEGIN
    
    /* .............................................................................

    Programa: fn_busca_param
    Sistema : Ayllos Web
    Autor   : Ricardo Linhares
    Data    : Dezembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar parametros relacionados a TAB098

    Alteracoes: -----
    ..............................................................................*/  
      
        RETURN tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                ,pr_nmsistem => 'CRED'
                                ,pr_tptabela => 'GENERI'
                                ,pr_cdempres => 0
                                ,pr_cdacesso => pr_cdacesso
                                ,pr_tpregist => 0);
  
  END fn_buscar_param;          

  PROCEDURE pc_auditar_alteracao(pr_cdcooper IN crapcop.cdcooper%TYPE
                                ,pr_utlfileh IN utl_file.file_type
                                ,pr_cdopera IN VARCHAR2
                                ,pr_param   IN VARCHAR2
                                ,pr_vlatual IN VARCHAR2
                                ,pr_vlnovo  IN VARCHAR2) IS
                                
  BEGIN
    
    /* .............................................................................

    Programa: pc_auditar_alteracao
    Sistema : Ayllos Web
    Autor   : Ricardo Linhares
    Data    : Dezembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina respons�vel por efetuar a auditoria da tab098

    Alteracoes: -----
    ..............................................................................*/    
  
    DECLARE
      vr_dsclinha VARCHAR2(500);
      vr_utlfileh utl_file.file_type;

      BEGIN
        
          vr_utlfileh := pr_utlfileh;    
          vr_dsclinha := to_char(SYSDATE,'dd/mm/yyyy hh24:mi:ss') || ' - Coop:' || pr_cdcooper 
                         || ' Alterou parametro ' || pr_param || ' De ' || pr_vlatual || ' para ' || pr_vlnovo
                         || ' pelo operador ' || pr_cdopera;

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                        ,pr_des_text => vr_dsclinha);
                                                
      END;                                                  
  
  END pc_auditar_alteracao;

  PROCEDURE pc_insere_tag_dados(pr_retxml   IN OUT NOCOPY xmltype
                               ,pr_tag IN VARCHAR2          
                               ,pr_conteudo IN VARCHAR2     
                               ,pr_dscritic OUT VARCHAR2) IS
                               
    /* .............................................................................

    Programa: pc_insere_tag_dados
    Sistema : Ayllos Web
    Autor   : Ricardo Linhares
    Data    : Dezembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina respons�vel inserir a tag de dados no XML

    Alteracoes: -----
    ..............................................................................*/                                
    
  BEGIN
    
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'inf'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => pr_tag
                              ,pr_tag_cont => pr_conteudo
                              ,pr_des_erro => pr_dscritic);   
    
  
  END pc_insere_tag_dados;

  PROCEDURE pc_atualizar_param(pr_cdcooper IN crapcop.cdcooper%TYPE
                              ,pr_nmparam IN craptab.cdacesso%TYPE
                              ,pr_vlparam IN craptab.dstextab%TYPE
                              ,pr_cdcritic   OUT PLS_INTEGER
                              ,pr_dscritic   OUT VARCHAR2) IS

    /* .............................................................................

    Programa: pc_atualizar_param
    Sistema : Ayllos Web
    Autor   : Ricardo Linhares
    Data    : Dezembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina respons�vel atualizar o parametro da tab098

    Alteracoes: -----
    ..............................................................................*/    
                              
                              
  BEGIN                            
                         
       UPDATE craptab
          SET dstextab = pr_vlparam
        WHERE cdcooper = pr_cdcooper
          AND nmsistem = 'CRED'
          AND tptabela = 'GENERI'
          AND cdempres = 0
          AND tpregist = 0
          AND cdacesso = pr_nmparam;  
          
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral na rotina da tela TAB098: ' || SQLERRM;
  END pc_atualizar_param;

  PROCEDURE pc_consultar(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                        ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                        ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                        ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                        ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    
    /* .............................................................................

    Programa: pc_consultar
    Sistema : Ayllos Web
    Autor   : Ricardo Linhares
    Data    : Dezembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina respons�vel por consultar os par�metros da tab098

    Alteracoes: -----
    ..............................................................................*/                            
                        
  BEGIN

   DECLARE
      
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      vr_exc_saida EXCEPTION;
      vr_vet_dados gene0002.typ_split;
      vr_dstextab  craptab.dstextab%TYPE;
	    vr_rollout_cip_reg_data VARCHAR2(20);
	    vr_rollout_cip_reg_valor VARCHAR2(20);
	    vr_rollout_cip_pag_data VARCHAR2(20);
	    vr_rollout_cip_pag_valor VARCHAR2(20);       
      
    BEGIN
  
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'inf'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

     -- insere as tags de conte�do
     pc_insere_tag_dados(pr_retxml, 'prz_baixa_cip',      fn_buscar_param(pr_cdcooper, 'PRZ_BAIXA_CIP'),  vr_dscritic);                                                    
     pc_insere_tag_dados(pr_retxml, 'vlvrboleto',         fn_buscar_param(pr_cdcooper, 'VLVRBOLETO'),     vr_dscritic);                                                    
     pc_insere_tag_dados(pr_retxml, 'vlcontig_cip',       fn_buscar_param(pr_cdcooper, 'VLCONTIG_CIP'),   vr_dscritic);
                            
     
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TAB098: ' || SQLERRM;

        -- Carregar XML padr�o para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
   END;
  
  END pc_consultar;
  
   PROCEDURE pc_atualizar(pr_cdcooper             IN crapcop.cdcooper%TYPE
                         ,pr_cdoperad              IN VARCHAR2
                         ,pr_prz_baixa_cip         IN VARCHAR2
                         ,pr_vlvrboleto            IN VARCHAR2
                         ,pr_vlcontig_cip          IN VARCHAR2
                         ,pr_xmllog     IN VARCHAR2 --> XML com informacoes de LOG
                         ,pr_cdcritic   OUT PLS_INTEGER --> Codigo da critica
                         ,pr_dscritic   OUT VARCHAR2 --> Descricao da critica
                         ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                         ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                         ,pr_des_erro   OUT VARCHAR2) IS --> Erros do processo

    /* .............................................................................

    Programa: pc_atualizar
    Sistema : Ayllos Web
    Autor   : Ricardo Linhares
    Data    : Dezembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina respons�vel receber o XML das atualiza��es dos par�metros da tab098

    Alteracoes: 01/08/2017 - Incluir campo vlcontig_cip para armazenar o valor limite 
                             para pagamentos de boletos em contigencia.
                             PRJ340 - (Odirlei-AMcom)
    ..............................................................................*/                             
                         
  BEGIN
    DECLARE
      vr_prz_baixa_cip           VARCHAR2(10);
      vr_vlvrboleto              VARCHAR2(50);
      vr_vlcontig_cip            VARCHAR2(50);      
      vr_vet_dados gene0002.typ_split;
      vr_dstextab  craptab.dstextab%TYPE;      
      vr_rollout_cip_reg craptab.dstextab%TYPE;
      vr_rollout_cip_pag craptab.dstextab%TYPE;
      vr_dsdireto VARCHAR2(400);
      vr_utlfileh      utl_file.file_type;    --> Handle para arquivo de LOG      
      vr_exc_saida EXCEPTION;
      vr_dscritic  crapcri.dscritic%TYPE;
 
    BEGIN
      
        -- diretorio do log
        vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/log');
                                            
        -- Abrir arquivo em modo de adi��o
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto
                                ,pr_nmarquiv => 'TAB098.log'
                                ,pr_tipabert => 'A'
                                ,pr_utlfileh => vr_utlfileh
                                ,pr_des_erro => vr_dscritic);                                            
                                            
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;                                            
    
        vr_prz_baixa_cip := NVL(fn_buscar_param(pr_cdcooper, 'PRZ_BAIXA_CIP'),' ');
        IF vr_prz_baixa_cip <> pr_prz_baixa_cip THEN
          pc_atualizar_param(pr_cdcooper, 'PRZ_BAIXA_CIP', pr_prz_baixa_cip, pr_cdcritic, pr_dscritic);
          pc_auditar_alteracao(pr_cdcooper, vr_utlfileh, pr_cdoperad, 'PRZ_BAIXA_CIP', vr_prz_baixa_cip, pr_prz_baixa_cip);
        END IF;
        
        vr_vlvrboleto    := NVL(fn_buscar_param(pr_cdcooper, 'VLVRBOLETO'),' ');
        IF vr_vlvrboleto <> pr_vlvrboleto THEN
          pc_atualizar_param(pr_cdcooper, 'VLVRBOLETO', pr_vlvrboleto, pr_cdcritic, pr_dscritic);
          pc_auditar_alteracao(pr_cdcooper, vr_utlfileh, pr_cdoperad, 'VLVRBOLETO', vr_vlvrboleto, pr_vlvrboleto);          
        END IF;

        --> Estabelece o valor limite para recebimento de boletos em contigencia        
        vr_vlcontig_cip    := NVL(fn_buscar_param(pr_cdcooper, 'VLCONTIG_CIP'),' ');
        IF vr_vlcontig_cip <> pr_vlcontig_cip THEN
          pc_atualizar_param(pr_cdcooper, 'VLCONTIG_CIP', pr_vlcontig_cip, pr_cdcritic, pr_dscritic);
          pc_auditar_alteracao(pr_cdcooper, vr_utlfileh, pr_cdoperad, 'VLCONTIG_CIP', vr_vlcontig_cip, pr_vlcontig_cip);          
        END IF;
        
        -- Fechar arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
        
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
        ROLLBACK;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na rotina da tela TAB098.pc_atualizar: '||SQLERRM;
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
        ROLLBACK;

    END;

  END pc_atualizar;                        

END TELA_TAB098;
/
