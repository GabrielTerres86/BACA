CREATE OR REPLACE PACKAGE CECRED.TELA_GT0018 IS

  /*--------------------------------------------------------------------------
  --
  --  Programa : TELA_GT0018
  --  Sistema  : Rotinas utilizadas pela Tela GT0018
  --  Sigla    : COBR
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Dezembro - 2017.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela GT0018
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------*/

  ---------------------------- ESTRUTURAS DE REGISTRO -----------------------
  
  
  ------------------------------------ ROTINAS ------------------------------
  --> Rotina para consultar dados para a tela GT0018
  PROCEDURE pc_buscar_dados_gt0018_web
                           (pr_cddopcao IN VARCHAR2                              --> Opcoes da tela 
                           ,pr_cdempres IN tbconv_arrecadacao.cdempres%TYPE      --> Codigo empresa do convenio
                           ,pr_tparrecd IN tbconv_arrecadacao.tparrecadacao%TYPE --> Tipo de arrecadacao(1-Sicredi, 2-Bancoob)
                           ,pr_cdempcon IN tbconv_arrecadacao.cdempcon%TYPE      --> Empresa do convenio
                           ,pr_cdsegmto IN tbconv_arrecadacao.cdsegmto%TYPE      --> Segmento da empresa do convenio
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                           
  --> Rotina para gravar dados para a tela GT0018
  PROCEDURE pc_gravar_dados_gt0018_web
                           (pr_cddopcao IN VARCHAR2              --> Opcao da operacao
                           ,pr_tparrecd IN tbconv_arrecadacao.tparrecadacao%TYPE --> Tipo de arrecadacao(1-Sicredi, 2-Bancoob)
                           ,pr_cdempres IN tbconv_arrecadacao.cdempres%TYPE      --> Codigo empresa do convenio
                           ,pr_nmextcon IN crapcon.nmextcon%TYPE --> Nome extenso do convenio
                           ,pr_cdempcon IN crapcon.cdempcon%TYPE --> Codigo empresa do convenio
                           ,pr_cdsegmto IN crapcon.cdsegmto%TYPE --> Codigo de segmento
                           ,pr_nmrescon IN crapcon.nmrescon%TYPE --> Nome resumido do convenio
                           
                           ,pr_vltarint IN VARCHAR2              --> Valor tarifa internet
                           ,pr_vltartaa IN VARCHAR2              --> Valor tarifa TAA
                           ,pr_vltarcxa IN VARCHAR2              --> Valor tarifa Caixa
                           ,pr_vltardeb IN VARCHAR2              --> Valor tarifa Deb. aut.
                           ,pr_vltarcor IN VARCHAR2              --> Valor tarifa corresp. banc.
                           ,pr_vltararq IN VARCHAR2              --> Valor tarifa arquivo
                           ,pr_nrrenorm IN NUMBER                --> Numero de dias de float
                           ,pr_nrtolera IN NUMBER                --> Numero de dias de tolerancia
                           ,pr_dsdianor IN VARCHAR2              --> Forma de repasse
                           ,pr_dtcancel IN VARCHAR2              --> Data de cancelamento
                           ,pr_nrlayout IN NUMBER                --> Numero do layout febraban
                           
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                                                                              
END TELA_GT0018;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_GT0018 IS
  /*--------------------------------------------------------------------------
  --
  --  Programa : TELA_GT0018
  --  Sistema  : Rotinas utilizadas pela Tela GT0018
  --  Sigla    : COBR
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Dezembro - 2017.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela GT0018
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------*/
  
  --> Rotina para consultar dados para a tela GT0018
  PROCEDURE pc_buscar_dados_gt0018_web
                           (pr_cddopcao IN VARCHAR2                              --> Opcoes da tela 
                           ,pr_cdempres IN tbconv_arrecadacao.cdempres%TYPE      --> Codigo empresa do convenio
                           ,pr_tparrecd IN tbconv_arrecadacao.tparrecadacao%TYPE --> Tipo de arrecadacao(1-Sicredi, 2-Bancoob)
                           ,pr_cdempcon IN tbconv_arrecadacao.cdempcon%TYPE      --> Empresa do convenio
                           ,pr_cdsegmto IN tbconv_arrecadacao.cdsegmto%TYPE      --> Segmento da empresa do convenio
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_buscar_dados_gt0018_web
        Sistema : CECRED
        Sigla   : CONV
        Autor   : Odirlei Busana
        Data    : Dezembro/2017.                    Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para consultar dados para a tela GT0018

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
      
      ---------->> CURSORES <<--------
      --> Buscar dados do convenio Sicredi
      CURSOR cr_crapscn ( pr_cdempres IN crapscn.cdempres%TYPE) IS
        SELECT *
          FROM crapscn scn 
         WHERE UPPER(scn.cdempres) = UPPER(pr_cdempres);
      rw_crapscn cr_crapscn%ROWTYPE;
      
      --> Buscar demais convenios
      CURSOR cr_conv_arrec ( pr_cdempres IN tbconv_arrecadacao.cdempres%TYPE,
                             pr_tparrecd IN tbconv_arrecadacao.tparrecadacao%TYPE,
                             pr_cdcooper IN crapcon.cdcooper%TYPE
                             ) IS
        SELECT arr.*,
               con.nmextcon,
               con.nmrescon
          FROM tbconv_arrecadacao arr
              ,crapcon con
         WHERE UPPER(arr.cdempres) = UPPER(pr_cdempres)
           AND arr.cdempcon = con.cdempcon
           AND arr.cdsegmto = con.cdsegmto
           AND arr.tparrecadacao = pr_tparrecd
           AND con.cdcooper = pr_cdcooper;
      rw_conv_arrec cr_conv_arrec%ROWTYPE;
      
      --> Verificar se empresa conveniada ja esta cadastrada
      CURSOR cr_conv_arrec_2 ( pr_cdempcon IN tbconv_arrecadacao.cdempcon%TYPE,
                               pr_cdsegmto IN tbconv_arrecadacao.cdsegmto%TYPE,                             
                               pr_tparrecd IN tbconv_arrecadacao.tparrecadacao%TYPE
                             ) IS
        SELECT arr.cdempres
          FROM tbconv_arrecadacao arr
         WHERE arr.cdempcon = pr_cdempcon
           AND arr.cdsegmto = pr_cdsegmto
           AND arr.tparrecadacao = pr_tparrecd;
      rw_conv_arrec_2 cr_conv_arrec_2%ROWTYPE;
      
      --> Buscar departamento do operado
      CURSOR cr_crapope ( pr_cdcooper IN crapope.cdcooper%TYPE,
                          pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT ope.cddepart
          FROM crapope ope
         WHERE ope.cdcooper = pr_cdcooper
           AND ope.cdoperad = pr_cdoperad;
      
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
     
      vr_dsalerta VARCHAR2(500);
      vr_fconven  BOOLEAN;
      vr_retxml   CLOB;
      vr_cdempcon VARCHAR2(500);
      
      --> Buscar valor da tarifa
      FUNCTION fn_vltarifa(pr_cdempres IN crapscn.cdempres%TYPE,
                           pr_tpmeiarr IN crapstn.tpmeiarr%TYPE) RETURN NUMBER IS
        --> Buscar tarifa                   
        CURSOR cr_craptfs IS
          SELECT stn.vltrfuni
            FROM crapstn stn
           WHERE stn.cdempres = pr_cdempres 
             AND stn.tpmeiarr = pr_tpmeiarr;
             
        --> Buscar tarifa Internet                   
        CURSOR cr_craptfs_D IS
          SELECT stn.vltrfuni
            FROM crapstn stn
           WHERE stn.cdempres = pr_cdempres 
             AND stn.tpmeiarr = pr_tpmeiarr     
             AND ( (pr_tpmeiarr = 'K0'  AND stn.cdtransa = '0XY') 
                    OR
                   (pr_tpmeiarr = '147' AND stn.cdtransa = '1CK') 
                   OR 
                   pr_tpmeiarr NOT IN ('K0','147')
                 );             
        rw_craptfs cr_craptfs%ROWTYPE;     
        
      BEGIN
      
        IF pr_tpmeiarr <> 'D' THEN
          OPEN cr_craptfs;
          FETCH cr_craptfs INTO rw_craptfs;
          IF cr_craptfs%NOTFOUND THEN
            CLOSE cr_craptfs;
            RETURN 0;
          ELSE
            CLOSE cr_craptfs;
            RETURN rw_craptfs.vltrfuni;
          END IF;
          
        ELSE --> Internet
        
          OPEN cr_craptfs_D;
          FETCH cr_craptfs_D INTO rw_craptfs;
          IF cr_craptfs_D%NOTFOUND THEN
            CLOSE cr_craptfs_D;
            RETURN 0;
          ELSE
            CLOSE cr_craptfs_D;
            RETURN rw_craptfs.vltrfuni;
          END IF;
        
        END IF;
      
      EXCEPTION
        WHEN OTHERS THEN
          RETURN 0;
      END fn_vltarifa;      

    BEGIN
    
      gene0001.pc_informa_acesso(pr_module => 'TELA_GT0018',
                                 pr_action => 'pc_buscar_dados_gt0018_web');

      pr_des_erro := 'OK';
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
        RAISE vr_exc_erro;
      END IF;
      
      vr_dsalerta := NULL;
      
      -- Criar cabeçalho do XML
      vr_retxml := '<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                   '<root><Dados><inf>';
                   
      --> Sicredi
      IF pr_tparrecd = 1 THEN
        OPEN cr_crapscn(pr_cdempres => pr_cdempres);
        FETCH cr_crapscn INTO rw_crapscn;
        vr_fconven := cr_crapscn%FOUND;
        CLOSE cr_crapscn;
      
      ELSE
        --> Buscar demais convenios
        OPEN cr_conv_arrec ( pr_cdempres => pr_cdempres,
                             pr_tparrecd => pr_tparrecd,
                             pr_cdcooper => vr_cdcooper);
        FETCH cr_conv_arrec INTO rw_conv_arrec;
        vr_fconven := cr_conv_arrec%FOUND;
        CLOSE cr_conv_arrec;
      
      END IF;
      
      IF vr_fconven = FALSE THEN
        
        --> Apresentar critica apenas para diferente de Insersao
        IF pr_cddopcao <> 'I' THEN          
          vr_dscritic := 'Convênio não encontrado.';
          RAISE vr_exc_erro;        
        
        -- caso fo inclusao
        ELSE
          --> Verificar se empresa conveniada ja esta cadastrada
          OPEN cr_conv_arrec_2 ( pr_cdempcon => pr_cdempcon,
                                 pr_cdsegmto => pr_cdsegmto,               
                                 pr_tparrecd => pr_tparrecd);
          FETCH cr_conv_arrec_2 INTO rw_conv_arrec_2;
          IF cr_conv_arrec_2%FOUND THEN
            CLOSE cr_conv_arrec_2;
            vr_dscritic := 'Convênio '||rw_conv_arrec_2.cdempres||' já cadastrado para a Empresa e Segmento informados.';
            RAISE vr_exc_erro; 
            
          ELSE
            CLOSE cr_conv_arrec_2;
          END IF;
        
        END IF;
        
        
        
        vr_retxml := vr_retxml ||
                    '<dsalerta>' || vr_dsalerta  || '</dsalerta>' ;
        
      ELSE
        IF pr_tparrecd = 1 THEN
        
          vr_cdempcon := rw_crapscn.cdempcon;
          
          IF rw_crapscn.cdempco2 <> 0  THEN
            vr_cdempcon := vr_cdempcon || '/' || rw_crapscn.cdempco2;
          END IF;  
          
          IF rw_crapscn.cdempco3 <> 0  THEN
            vr_cdempcon := vr_cdempcon || '/' || rw_crapscn.cdempco3;
          END IF;
          
          IF rw_crapscn.cdempco4 <> 0  THEN
            vr_cdempcon := vr_cdempcon || '/' || rw_crapscn.cdempco4;
          END IF;
          
          IF rw_crapscn.cdempco5 <> 0  THEN
            vr_cdempcon := vr_cdempcon || '/' || rw_crapscn.cdempco5;
          END IF;
        
          vr_retxml := vr_retxml ||
                      '<cdempres>' || rw_crapscn.cdempres  || '</cdempres>' ||
                      '<nmextcon>' || rw_crapscn.dsnomcnv  || '</nmextcon>' ||                    
                      '<cdempcon>' || vr_cdempcon          || '</cdempcon>' ||
                      '<nmrescon>' || rw_crapscn.dsnomres  || '</nmrescon>' ||
                      '<cdsegmto>' || rw_crapscn.cdsegmto  || '</cdsegmto>';
                      
         --> Tipos de Arrecadaçao SICREDI 
         -->  A - ATM 
         -->  B - Correspondente Bancário 
         -->  C - Caixa 
         -->  D - Internet Banking
         -->  E - Debito Auto
         -->  F - Arquivo de Pagamento (CNAB 240)
                
         --> INTERNET
         vr_retxml := vr_retxml ||
                      '<vltarint>' || fn_vltarifa( pr_cdempres => rw_crapscn.cdempres,
                                                   pr_tpmeiarr => 'D') ||
                      '</vltarint>'; 
                      
         --> TAA
         vr_retxml := vr_retxml ||
                      '<vltartaa>' || fn_vltarifa( pr_cdempres => rw_crapscn.cdempres,
                                                   pr_tpmeiarr => 'A') ||
                      '</vltartaa>';
         --> CAIXA
         vr_retxml := vr_retxml ||
                      '<vltarcxa>' || fn_vltarifa( pr_cdempres => rw_crapscn.cdempres,
                                                   pr_tpmeiarr => 'C') ||
                      '</vltarcxa>';             
         --> DEB. AUT.
         vr_retxml := vr_retxml ||
                      '<vltardeb>' || fn_vltarifa( pr_cdempres => rw_crapscn.cdempres,
                                                   pr_tpmeiarr => 'E') ||
                      '</vltardeb>';
                      
         --> CORRESPONDENTE
         vr_retxml := vr_retxml ||
                      '<vltarcor>' || fn_vltarifa( pr_cdempres => rw_crapscn.cdempres,
                                                   pr_tpmeiarr => 'B') ||
                      '</vltarcor>';
         
         --> ARQUIVO
         vr_retxml := vr_retxml ||
                      '<vltararq>' || fn_vltarifa( pr_cdempres => rw_crapscn.cdempres,
                                                   pr_tpmeiarr => 'F') ||
                      '</vltararq>';             
                                  
         vr_retxml := vr_retxml ||             
                      '<nrrenorm>' || rw_crapscn.nrrenorm  || '</nrrenorm>' ||
                      '<nrtolera>' || rw_crapscn.nrtolera  || '</nrtolera>' ||
                      '<dsdianor>' || rw_crapscn.dsdianor  || '</dsdianor>' ||
                      '<dtcancel>' || to_char(rw_crapscn.dtencemp,'DD/MM/RRRR')  || '</dtcancel>'                    
                      ;
        
                  
          IF pr_cddopcao = 'A' THEN
            --> Validar se permite alteracao
            IF rw_crapscn.dsoparre <> 'E' OR 
               rw_crapscn.cddmoden NOT IN ('A','C') THEN
              vr_dsalerta := 'Não permitido alteração deste tipo de Convênio.';
            END IF;   
          END IF;
          
        /* Bancoob */  
        ELSIF pr_tparrecd = 2 THEN  
        
          vr_retxml := vr_retxml ||
                      '<cdempres>' || rw_conv_arrec.cdempres  || '</cdempres>' ||
                      '<nmextcon>' || rw_conv_arrec.nmextcon  || '</nmextcon>' ||                    
                      '<cdempcon>' || rw_conv_arrec.cdempcon  || '</cdempcon>' ||
                      '<nmrescon>' || rw_conv_arrec.nmrescon  || '</nmrescon>' ||
                      '<cdsegmto>' || rw_conv_arrec.cdsegmto  || '</cdsegmto>';
          
          
          vr_retxml := vr_retxml ||
                      --> INTERNET 
                      '<vltarint>' || rw_conv_arrec.vltarifa_internet ||'</vltarint>'||                       
                      --> TAA 
                      '<vltartaa>' || rw_conv_arrec.vltarifa_taa      ||'</vltartaa>'||
                      --> CAIXA
                      '<vltarcxa>' || rw_conv_arrec.vltarifa_caixa    ||'</vltarcxa>'||
                      --> DEB. AUT.
                      '<vltardeb>' || rw_conv_arrec.vltarifa_debaut   ||'</vltardeb>';
                      
          vr_retxml := vr_retxml ||             
                      '<nrrenorm>' || rw_conv_arrec.nrdias_float      || '</nrrenorm>' ||
                      '<nrtolera>' || rw_conv_arrec.nrdias_tolerancia || '</nrtolera>' ||
                      '<dsdianor>' || rw_conv_arrec.tpdias_repasse    || '</dsdianor>' ||
                      '<dtcancel>' || to_char(rw_conv_arrec.dtencemp,'DD/MM/RRRR')  || '</dtcancel>'||                    
                      '<nrlayout>' || rw_conv_arrec.nrlayout          || '</nrlayout>'
                      ;
        
        
        END IF;  
        vr_retxml := vr_retxml ||
                    '<dsalerta>' || vr_dsalerta  || '</dsalerta>' ;
        
      END IF;

      vr_retxml := vr_retxml || '</inf></Dados></root>';
      pr_retxml := xmltype.createxml(vr_retxml);



  EXCEPTION
    WHEN vr_exc_erro THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_buscar_dados_gt0018_web;
  
  --> Rotina para gravar dados para a tela GT0018
  PROCEDURE pc_gravar_dados_gt0018_web
                           (pr_cddopcao IN VARCHAR2              --> Opcao da operacao
                           ,pr_tparrecd IN tbconv_arrecadacao.tparrecadacao%TYPE --> Tipo de arrecadacao(1-Sicredi, 2-Bancoob)
                           ,pr_cdempres IN tbconv_arrecadacao.cdempres%TYPE      --> Codigo empresa do convenio
                           ,pr_nmextcon IN crapcon.nmextcon%TYPE --> Nome extenso do convenio
                           ,pr_cdempcon IN crapcon.cdempcon%TYPE --> Codigo empresa do convenio
                           ,pr_cdsegmto IN crapcon.cdsegmto%TYPE --> Codigo de segmento
                           ,pr_nmrescon IN crapcon.nmrescon%TYPE --> Nome resumido do convenio
                           
                           ,pr_vltarint IN VARCHAR2              --> Valor tarifa internet
                           ,pr_vltartaa IN VARCHAR2              --> Valor tarifa TAA
                           ,pr_vltarcxa IN VARCHAR2              --> Valor tarifa Caixa
                           ,pr_vltardeb IN VARCHAR2              --> Valor tarifa Deb. aut.
                           ,pr_vltarcor IN VARCHAR2              --> Valor tarifa corresp. banc.
                           ,pr_vltararq IN VARCHAR2              --> Valor tarifa arquivo
                           ,pr_nrrenorm IN NUMBER                --> Numero de dias de float
                           ,pr_nrtolera IN NUMBER                --> Numero de dias de tolerancia
                           ,pr_dsdianor IN VARCHAR2              --> Forma de repasse
                           ,pr_dtcancel IN VARCHAR2              --> Data de cancelamento
                           ,pr_nrlayout IN NUMBER                --> Numero do layout febraban
                           
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_gravar_dados_gt0018_web
        Sistema : CECRED
        Sigla   : COBR
        Autor   : Odirlei Busana
        Data    : Dezembro/2017.                    Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para gravar dados para a tela GT0018

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
      
      ---------->> CURSORES <<--------
      --> Buscar dados do convenio Sicredi
      CURSOR cr_crapscn ( pr_cdempres IN crapscn.cdempres%TYPE) IS
        SELECT scn.*,
               scn.rowid
          FROM crapscn scn 
         WHERE UPPER(scn.cdempres) = UPPER(pr_cdempres)
           FOR UPDATE NOWAIT;
      rw_crapscn cr_crapscn%ROWTYPE;
      
      --> Cadastro de convenios de arrecadacao
      CURSOR cr_arrecad (pr_cdempres tbconv_arrecadacao.cdempres%TYPE,
                         pr_tparrecd tbconv_arrecadacao.tparrecadacao%TYPE
                         ) IS
        SELECT arr.*,
               arr.rowid
          FROM tbconv_arrecadacao arr
         WHERE arr.cdempres      = pr_cdempres
           AND arr.tparrecadacao = pr_tparrecd; 
      rw_arrecad cr_arrecad%ROWTYPE;
      
      --> Buscar cadastro de convenio
      CURSOR cr_crapcon (pr_cdempcon tbconv_arrecadacao.cdempcon%TYPE,
                         pr_cdsegmto tbconv_arrecadacao.cdsegmto%TYPE
                         ) IS
        SELECT con.*,
               con.rowid
          FROM crapcon con
         WHERE con.cdempcon = pr_cdempcon
           AND con.cdsegmto = pr_cdsegmto
           AND con.cdcooper = 1; 
      rw_crapcon cr_crapcon%ROWTYPE;
      
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
     
      vr_flconven BOOLEAN;
      vr_dscdolog VARCHAR2(1000);
      
      vr_retxml   CLOB;
      
      vr_dsmensag VARCHAR2(100) := NULL;
      
      ------------->>> SUB-ROTINAS <<<-----------
      PROCEDURE pr_gera_log_gt0018 ( pr_cdcooper  IN NUMBER
                                    ,pr_dscdolog  IN VARCHAR2) IS
      BEGIN
        
        btch0001.pc_gera_log_batch( pr_cdcooper     => pr_cdcooper,
                                    pr_ind_tipo_log => 1,
                                    pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS') ||
                                                       ' Operador: '|| vr_cdoperad ||
                                                       ' --> '||pr_dscdolog,
                                    pr_nmarqlog     => 'gt0018',
                                    pr_flfinmsg     => 'N');
      
      END pr_gera_log_gt0018;
      

    BEGIN
      
      
      pr_des_erro := 'OK';
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
        RAISE vr_exc_erro;
      END IF;
      
      -- Criar cabeçalho do XML
      vr_retxml := '<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                   '<root><Dados><inf>';
      
      --> SICREDI             
      IF pr_tparrecd = 1 THEN
        
        vr_dscritic := NULL;
        --> Buscar dados do convenio Sicredi
        BEGIN
          OPEN cr_crapscn ( pr_cdempres  => pr_cdempres);
          FETCH cr_crapscn INTO rw_crapscn; 
          IF cr_crapscn%NOTFOUND THEN
            CLOSE cr_crapscn;
            vr_dscritic := 'Convenio nao econtrado.';
            
          ELSE  
            CLOSE cr_crapscn;        
          END IF;
          
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Registro sendo alterado por outro usuario.';            
        END;
        
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        --> Atualizar registro
        BEGIN
          UPDATE crapscn scn
             SET scn.cdempcon = pr_cdempcon,
                 scn.dsnomres = pr_nmrescon,
                 scn.cdsegmto = pr_cdsegmto
           WHERE scn.rowid = rw_crapscn.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Nao foi possivel alterar convenio sicredi: '||SQLERRM;
            RAISE vr_exc_erro;
            
        END;
        
        IF nvl(pr_cdempcon,0) <> nvl(rw_crapscn.cdempcon,0) THEN
          pr_gera_log_gt0018 (pr_cdcooper => vr_cdcooper
                             ,pr_dscdolog => 'alterou para o convenio Sicredi, Codigo: ' || pr_cdempres ||
                                               ' --> codigo de empresa ' ||rw_crapscn.cdempcon ||
                                               ' para '|| pr_cdempcon);
        END IF;
        
        IF nvl(pr_cdsegmto,'0') <> nvl(rw_crapscn.cdsegmto,'0') THEN
          pr_gera_log_gt0018 (pr_cdcooper => vr_cdcooper
                             ,pr_dscdolog => 'alterou para o convenio Sicredi, Codigo: ' || pr_cdempres ||
                                               ' --> codigo de segmento ' ||rw_crapscn.cdsegmto ||
                                               ' para '|| pr_cdsegmto);
        END IF;
        
        IF nvl(pr_nmrescon,' ') <> nvl(rw_crapscn.dsnomres,' ') THEN
          pr_gera_log_gt0018 (pr_cdcooper => vr_cdcooper
                             ,pr_dscdolog => 'alterou para o convenio Sicredi, Codigo: ' || pr_cdempres ||
                                               ' --> nome resumido ' ||rw_crapscn.dsnomres ||
                                               ' para '|| pr_nmrescon);
        END IF;
      
        vr_dsmensag := 'Registros atualizados com sucesso.';
      
      END IF;
      
      
      --> Bancoob  
      IF pr_tparrecd = 2 THEN 
        
        vr_dscritic := NULL;
        --> Buscar dados do convenio Sicredi
        BEGIN
          
          OPEN cr_arrecad ( pr_cdempres  => pr_cdempres,
                            pr_tparrecd  => pr_tparrecd);
          FETCH cr_arrecad INTO rw_arrecad; 
          vr_flconven := cr_arrecad%FOUND;
          CLOSE cr_arrecad;
          
          IF vr_flconven = FALSE AND pr_cddopcao != 'I' THEN
            vr_dscritic := 'Convenio nao econtrado.';
          END IF;
          
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Registro sendo alterado por outro usuario.';            
        END;
        
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      
        --> Atualizar
        IF pr_cddopcao = 'A' THEN
        
          BEGIN
            UPDATE tbconv_arrecadacao arr
               SET cdempcon          = pr_cdempcon       
                  ,cdsegmto          = pr_cdsegmto       
                  ,tpdias_repasse    = pr_dsdianor       
                  ,nrdias_float      = nvl(pr_nrrenorm,0)
                  ,nrdias_tolerancia = nvl(pr_nrtolera,0)
                  ,dtencemp          = to_date(pr_dtcancel,'DD/MM/RRRR')
                  ,nrlayout          = pr_nrlayout
                  ,vltarifa_caixa    = nvl(to_number(pr_vltarcxa, 'FM9999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ,0)
                  ,vltarifa_debaut   = nvl(to_number(pr_vltardeb, 'FM9999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ,0)
                  ,vltarifa_internet = nvl(to_number(pr_vltarint, 'FM9999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ,0)
                  ,vltarifa_taa      = nvl(to_number(pr_vltartaa, 'FM9999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ,0)
             WHERE arr.rowid = rw_arrecad.rowid;  
          
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Nao foi possivel incluir convenio: '||SQLERRM;
              RAISE vr_exc_erro;
          END;
          
          --> Caso estiver cancelando o convenio
          IF pr_dtcancel IS NOT NULL AND 
             rw_arrecad.dtencemp IS NULL THEN
             
            --> Buscar cadastro de convenio
            OPEN cr_crapcon (pr_cdempcon => pr_cdempcon,
                             pr_cdsegmto => pr_cdsegmto);
            FETCH cr_crapcon INTO rw_crapcon;
            IF cr_crapcon%NOTFOUND THEN 
              CLOSE cr_crapcon;
              vr_dscritic := 'Empresa '||pr_cdempcon||' conveniada nao encontrada.';
              RAISE vr_exc_erro;              
            ELSE
              CLOSE cr_crapcon;
            END IF;
            
            --> Caso possua outro tipo de arrecadação
            IF rw_crapcon.tparrecd <> 2 THEN
              --> apenas marcar como nao aceita bancoob
              BEGIN
                UPDATE crapcon con
                   SET con.flgacbcb = 0 
                 --> replicar em todas as cooperativar  
                 WHERE con.cdempcon = pr_cdempcon
                   AND con.cdsegmto = pr_cdsegmto;
              EXCEPTION
                WHEN OTHERS THEN
                   vr_dscritic := 'Nao foi possivel atualizar empresa conveniada(1): '||SQLERRM;
                   RAISE vr_exc_erro;
              END;
              
            --> Caso for arrecadado pelo bancoob
            ELSIF rw_crapcon.tparrecd = 2 THEN
             --> deve ser alterar para nã permitir pagamento internet
              BEGIN
                UPDATE crapcon con
                   SET con.flginter = 0
                 --> replicar em todas as cooperativar  
                 WHERE con.cdempcon = pr_cdempcon
                   AND con.cdsegmto = pr_cdsegmto;
              EXCEPTION
                WHEN OTHERS THEN
                   vr_dscritic := 'Nao foi possivel alterar empresa conveniada: '||SQLERRM;
                   RAISE vr_exc_erro;
              END; 
              pr_gera_log_gt0018 (pr_cdcooper => vr_cdcooper
                                 ,pr_dscdolog => 'Alterado permissao de arrecadacao internet da empresa conveniada '|| pr_cdempcon ||', pois convenio nao sera mais aceito.');
                          
            END IF;
             
             
          END IF;
          
          
          
          vr_dscdolog := 'alterou para o convenio Bancoob, Codigo: ' || pr_cdempres;
          
          --> codigo de empresa 
          IF nvl(pr_cdempcon,0) <> nvl(rw_arrecad.cdempcon,0) THEN
            pr_gera_log_gt0018 (pr_cdcooper => vr_cdcooper
                               ,pr_dscdolog => vr_dscdolog ||
                                                 ' --> Codigo de empresa ' ||rw_arrecad.cdempcon ||
                                                 ' para '|| pr_cdempcon);
          END IF;
          
          --> segmento
          IF nvl(pr_cdsegmto,0) <> nvl(rw_arrecad.cdsegmto,0) THEN
            pr_gera_log_gt0018 (pr_cdcooper => vr_cdcooper
                               ,pr_dscdolog => vr_dscdolog ||
                                                 ' --> Segmento de empresa ' ||rw_arrecad.cdsegmto ||
                                                 ' para '|| pr_cdsegmto);
          END IF;
          
          --> data de cancelamento
          IF nvl(to_date(pr_dtcancel,'DD/MM/RRRR'),SYSDATE+999) <> nvl(rw_arrecad.dtencemp,SYSDATE+999) THEN
            pr_gera_log_gt0018 (pr_cdcooper => vr_cdcooper
                               ,pr_dscdolog => vr_dscdolog ||
                                                 ' --> Data de cancelamento de ' ||to_date(rw_arrecad.dtencemp,'DD/MM/RRR') ||
                                                 ' para '|| pr_dtcancel);
          END IF;
          
          --> tipo de repasse
          IF nvl(pr_dsdianor,'') <> nvl(rw_arrecad.tpdias_repasse,'') THEN
            pr_gera_log_gt0018 (pr_cdcooper => vr_cdcooper
                               ,pr_dscdolog => vr_dscdolog ||
                                                 ' --> Tipo de repasse ' ||rw_arrecad.tpdias_repasse ||
                                                 ' para '|| pr_dsdianor);
          END IF;
          
          --> Dias de Float
          IF nvl(pr_nrrenorm ,0) <> nvl(rw_arrecad.nrdias_float,0) THEN
            pr_gera_log_gt0018 (pr_cdcooper => vr_cdcooper
                               ,pr_dscdolog => vr_dscdolog ||
                                                 ' --> Dias de Float ' ||rw_arrecad.nrdias_float ||
                                                 ' para '|| pr_nrrenorm);
          END IF;
          
          --> Dias de Tolerância Após Vencimento:
          IF nvl(pr_nrtolera ,0) <> nvl(rw_arrecad.nrdias_tolerancia,0) THEN
            pr_gera_log_gt0018 (pr_cdcooper => vr_cdcooper
                               ,pr_dscdolog => vr_dscdolog ||
                                                 ' --> Dias de Tolerancia ' ||rw_arrecad.nrdias_tolerancia ||
                                                 ' para '|| pr_nrtolera);
          END IF;
          
          -->  Valor Tarifa Caixa
          IF nvl(to_number(pr_vltarcxa, 'FM9999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ,0) <> nvl(rw_arrecad.vltarifa_caixa,0) THEN
            pr_gera_log_gt0018 (pr_cdcooper => vr_cdcooper
                               ,pr_dscdolog => vr_dscdolog ||
                                                 ' --> Valor Tarifa Caixa ' ||to_char(rw_arrecad.vltarifa_caixa,'FM990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                                 ' para '|| pr_vltarcxa);
          END IF;
          
          --> Valor Tarifa Déb. Automático
          IF nvl(to_number(pr_vltardeb, 'FM9999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ,0) <> nvl(rw_arrecad.vltarifa_debaut,0) THEN
            pr_gera_log_gt0018 (pr_cdcooper => vr_cdcooper
                               ,pr_dscdolog => vr_dscdolog ||
                                                 ' --> Valor Tarifa Déb. Automático ' ||to_char(rw_arrecad.vltarifa_debaut,'FM990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                                 ' para '|| pr_vltardeb);
          END IF;
        
          --> Valor Tarifa Internet
          IF nvl(to_number(pr_vltarint, 'FM9999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ,0) <> nvl(rw_arrecad.vltarifa_internet,0) THEN
            pr_gera_log_gt0018 (pr_cdcooper => vr_cdcooper
                               ,pr_dscdolog => vr_dscdolog ||
                                                 ' --> Valor Tarifa Internet ' ||to_char(rw_arrecad.vltarifa_internet,'FM990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                                 ' para '|| pr_vltarint);
          END IF;
        
          --> Valor Tarifa TAA
          IF nvl(to_number(pr_vltartaa, 'FM9999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ,0) <> nvl(rw_arrecad.vltarifa_taa,0) THEN
            pr_gera_log_gt0018 (pr_cdcooper => vr_cdcooper
                               ,pr_dscdolog => vr_dscdolog ||
                                                 ' --> Valor Tarifa TAA ' ||to_char(rw_arrecad.vltarifa_taa,'FM990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                                 ' para '|| pr_vltartaa);
          END IF;
          
          
          --> Valor Tarifa TAA
          IF nvl(pr_nrlayout,0) <> nvl(rw_arrecad.nrlayout,0) THEN
            pr_gera_log_gt0018 (pr_cdcooper => vr_cdcooper
                               ,pr_dscdolog => vr_dscdolog ||
                                                 ' --> Layout febraban ' ||rw_arrecad.nrlayout ||
                                                 ' para '|| pr_nrlayout);
          END IF;
          
          vr_dsmensag := 'Convênio atualizados com sucesso.';
        --> Caso for Inclusão
        ELSIF pr_cddopcao = 'I' THEN
          
          IF vr_flconven = TRUE THEN
            vr_dscritic := 'Convênio já cadastrado.';
            RAISE vr_exc_erro;
          END IF;
        
          BEGIN
            INSERT INTO tbconv_arrecadacao
                        (cdempres
                        ,tparrecadacao
                        ,cdempcon
                        ,cdsegmto
                        ,tpdias_repasse
                        ,nrdias_float
                        ,nrdias_tolerancia
                        ,dtencemp
                        ,nrlayout
                        ,vltarifa_caixa
                        ,vltarifa_debaut
                        ,vltarifa_internet
                        ,vltarifa_taa) 
                VALUES ( pr_cdempres          -- cdempres
                        ,pr_tparrecd          -- tparrecadacao
                        ,pr_cdempcon          -- cdempcon
                        ,pr_cdsegmto          -- cdsegmto
                        ,pr_dsdianor          -- tpdias_repasse
                        ,nvl(pr_nrrenorm,0)   -- nrdias_float
                        ,nvl(pr_nrtolera,0)   -- nrdias_tolerancia
                        ,pr_dtcancel          -- dtencemp
                        ,pr_nrlayout          -- nrlayout
                        ,nvl(to_number(pr_vltarcxa, 'FM9999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ,0)   -- vltarifa_caixa
                        ,nvl(to_number(pr_vltardeb, 'FM9999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ,0)   -- vltarifa_debaut
                        ,nvl(to_number(pr_vltarint, 'FM9999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ,0)   -- vltarifa_internet
                        ,nvl(to_number(pr_vltartaa, 'FM9999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') ,0)); -- vltarifa_taa
          
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Nao foi possivel incluir convenio: '||SQLERRM;
              RAISE vr_exc_erro;
          END;
          
          --> Gerar log  
          pr_gera_log_gt0018 (pr_cdcooper => vr_cdcooper
                             ,pr_dscdolog => 'Incluido o convenio Bancoob ' || pr_cdempres ||' - ' || pr_nmextcon ||
                                             ' o codigo de empresa ' ||rw_crapscn.cdempcon );
          
          vr_dsmensag := 'Convênio incluído com sucesso.';
        END IF;
      
      END IF;
     
      -- Cria o XML de retorno
      vr_retxml := '<?xml version="1.0" encoding="ISO-8859-1" ?>';
      vr_retxml := vr_retxml || '<Root><Dados>';
      vr_retxml := vr_retxml || '<mensagem>'|| vr_dsmensag ||' </mensagem>';
      vr_retxml := vr_retxml || '</Dados></Root>';
    
      pr_retxml := xmltype.createxml(vr_retxml);
    
      COMMIT;
    
      pr_des_erro := 'OK';


  EXCEPTION
    WHEN vr_exc_erro THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_gravar_dados_gt0018_web;
  
  
                                   
  
END TELA_GT0018;
/
