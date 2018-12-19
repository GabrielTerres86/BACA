CREATE OR REPLACE PACKAGE PROGRID.PRGD0002 IS
  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : PRGD0002
  --  Sistema  : Rotinas Genericas sistema Web PROGRID
  --  Sigla    : PRGD0002
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Agosto/2016.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas Genericas sistema Web PROGRID
  --
  -- Alteracoes: 
  --             
  ---------------------------------------------------------------------------------------------------------------*/

  --> Armazenar as descrições dos dias da semana 
  TYPE typ_tab_dia_semana IS TABLE OF VARCHAR2(30)  
       INDEX BY PLS_INTEGER;       
  vr_tab_dia_semana typ_tab_dia_semana;    
  
  --> Armazenar as descrições dos tipos de evento  
  TYPE typ_tab_tpevento IS TABLE OF VARCHAR2(50)
       INDEX BY PLS_INTEGER;
  vr_tab_tpevento typ_tab_tpevento;
  
  --> Retorna a lista de dias da semana em extenso
  FUNCTION fn_dia_semana (pr_dslisdia IN VARCHAR2) RETURN VARCHAR2;
  
  --> Retornar a descrição do tipo de evento
  FUNCTION fn_desc_tpevento(pr_tpevento IN crapedp.tpevento%TYPE) RETURN VARCHAR2;
  
  FUNCTION fn_format_fone(pr_nrtelefo IN NUMBER) RETURN VARCHAR2;
  
  --> Procedure para listar os fornecedores da cooperativa
  PROCEDURE pc_lista_fornecedores(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                 ,pr_idevento IN crapcdp.idevento%TYPE --> Identificador de evento
                                 ,pr_dtanoage IN crapadp.dtanoage%TYPE --> Ano agenda
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro
  
  --> Funcao para retornar os parametros de logo para utilização no relatorio
  FUNCTION fn_prm_logo_relat( pr_cdcooper IN crapcop.cdcooper%TYPE,
                              pr_nmrescop IN crapcop.nmrescop%TYPE) RETURN VARCHAR2;
                                                     
  PROCEDURE pc_retorna_pa_pessoa(pr_cdcooper in  crapcop.cdcooper%type,
                                 pr_nrcpfcgc in  crapass.nrcpfcgc%type,
                                 pr_cdagenci out crapage.cdagenci%type,
                                 pr_cdcritic out crapcri.cdcritic%type,    --> Codigo da critica
                                 pr_dscritic out crapcri.dscritic%type); --> Descricao da critica   

  PROCEDURE pc_retorna_grupo_coop(pr_cdcooper in  crapcop.cdcooper%type,
                                  pr_nrcpfcgc in  crapass.nrcpfcgc%type,
                                  pr_nmdgrupo out tbevento_grupos.nmdgrupo%type,
                                  pr_cdcritic out crapcri.cdcritic%type,    --> Codigo da critica
                                  pr_dscritic out crapcri.dscritic%type); --> Descricao da critica   
                                
                                                     
END PRGD0002;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.PRGD0002 IS
  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : PRGD0002
  --  Sistema  : Rotinas Genericas sistema Web PROGRID
  --  Sigla    : PRGD0002
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Agosto/2016.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas Genericas sistema Web PROGRID
  --
  -- Alteracoes: 
  --             
  ---------------------------------------------------------------------------------------------------------------*/
  
  --> Procedure para listar os fornecedores da cooperativa
  PROCEDURE pc_lista_fornecedores(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                 ,pr_idevento IN crapcdp.idevento%TYPE --> Identificador de evento
                                 ,pr_dtanoage IN crapadp.dtanoage%TYPE --> Ano agenda
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS --> Descricao do Erro
    -- ..........................................................................
    --
    --  Programa : pc_lista_fornecedores
    --  Sistema  : Progrid
    --  Sigla    : GENE
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Agosto/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar para listar os fornecedores da cooperativa
    --
    --  Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
    
    -- Cursores
    --> Buscar fornecedores
    CURSOR cr_gnapfdp IS
      SELECT DISTINCT 
             gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => fdp.nrcpfcgc, 
                                       pr_inpessoa => fdp.inpessoa) nrcpfcgc,
             fdp.nmfornec
        FROM gnapfdp fdp
       WHERE EXISTS ( SELECT cdp.nrcpfcgc
                        FROM crapcdp cdp
                       WHERE cdp.cdcooper = nvl(nullif(pr_cdcooper,99),cdp.cdcooper)
                         AND cdp.dtanoage = pr_dtanoage
                         AND cdp.idevento = pr_idevento
                         AND cdp.nrcpfcgc = fdp.nrcpfcgc)
       ORDER BY gene0007.fn_caract_acento(fdp.nmfornec);
    
    -- Variaveis locais
    vr_contador INTEGER := 0;
    
    -- Variaveis de critica
    vr_dscritic crapcri.dscritic%TYPE;
  BEGIN
    
    pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><root><Dados/></root>');
    
    FOR rw_gnapfdp IN cr_gnapfdp LOOP
      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao  => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => vr_contador, pr_tag_nova => 'nrcpfcgc', pr_tag_cont => rw_gnapfdp.nrcpfcgc, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => vr_contador, pr_tag_nova => 'nmfornec', pr_tag_cont => rw_gnapfdp.nmfornec, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
      
    END LOOP;
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_des_erro := 'Erro geral em PRGD0002.pc_lista_fornecedores: ' || SQLERRM;
      pr_dscritic := 'Erro geral em PRGD0002.pc_lista_fornecedores: ' || SQLERRM;
  END pc_lista_fornecedores;
  
  --> Retorna a lista de dias da semana em extenso
  FUNCTION fn_dia_semana (pr_dslisdia IN VARCHAR2) RETURN VARCHAR2 IS
    -- ..........................................................................
    --
    --  Programa : fn_dia_semana
    --  Sistema  : Progrid
    --  Sigla    : GENE
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Agosto/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retorna a lista de dias da semana em extenso
    --
    --  Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
    
    
    vr_tab_dias     gene0002.typ_split;
    vr_listdias_ext VARCHAR2(1000);
    
  BEGIN    

    vr_tab_dias := gene0002.fn_quebra_string(pr_string  => pr_dslisdia
                                            ,pr_delimit => ',');

                                                                                                 
    -- Itera sobre a string quebrada
    IF vr_tab_dias.count > 0 THEN
      FOR idx IN 1 .. vr_tab_dias.count LOOP
        IF idx = 1 THEN
          vr_listdias_ext := prgd0002.vr_tab_dia_semana(vr_tab_dias(idx));
        ELSIF idx = vr_tab_dias.count THEN
          vr_listdias_ext := vr_listdias_ext ||' E '||prgd0002.vr_tab_dia_semana(vr_tab_dias(idx));
        ELSE
          vr_listdias_ext := vr_listdias_ext ||', '||prgd0002.vr_tab_dia_semana(vr_tab_dias(idx));
        END IF;
          
      END LOOP;
    END IF;
  
    RETURN vr_listdias_ext;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN 'DIAS INVALIDOS.';  
  END fn_dia_semana;
  
  PROCEDURE pc_carrega_tpevento IS
    -- ..........................................................................
    --
    --  Programa : pc_carrega_tpevento
    --  Sistema  : Progrid
    --  Sigla    : GENE
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Agosto/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Carrega descrições dos tipos de evento
    --
    --  Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
    
    
    vr_dstextab craptab.dstextab%TYPE;
    vr_paramemt gene0002.typ_split;
    
  BEGIN
    --> Buscar registro com os tipos de eventos
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => 0
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'CONFIG'
                                             ,pr_cdempres => 0
                                             ,pr_cdacesso => 'PGTPEVENTO'
                                             ,pr_tpregist => 0);

    vr_paramemt := gene0002.fn_quebra_string(pr_string  => vr_dstextab
                                            ,pr_delimit => ',');

                                                                                                 
    -- Itera sobre a string quebrada
    IF vr_paramemt.count > 0 THEN
      FOR idx IN 1 .. vr_paramemt.count LOOP
        IF MOD(idx,2) = 0 THEN
          CONTINUE;
        END IF;
        --> Carregar na temptable os tipos de eventos
        vr_tab_tpevento(vr_paramemt(idx+1)) := vr_paramemt(idx);
          
      END LOOP;
    END IF;
  
  
  END pc_carrega_tpevento;
  
  --> Retornar a descrição do tipo de evento
  FUNCTION fn_desc_tpevento(pr_tpevento IN crapedp.tpevento%TYPE) RETURN VARCHAR2 IS
    -- ..........................................................................
    --
    --  Programa : fn_desc_tpevento
    --  Sistema  : Progrid
    --  Sigla    : GENE
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Agosto/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retorna descrições dos tipos de evento
    --
    --  Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
    
    
  BEGIN
  
    IF vr_tab_tpevento.count = 0 THEN
      pc_carrega_tpevento;
    END IF;
    
    IF vr_tab_tpevento.exists(pr_tpevento) THEN
      RETURN vr_tab_tpevento(pr_tpevento);
    ELSE
      RETURN 'Tipo de evento invalido';
    END IF;
    
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'Tipo de evento invalido';
  END fn_desc_tpevento;
  
  FUNCTION fn_format_fone(pr_nrtelefo IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN SUBSTR(pr_nrtelefo,1,LENGTH(pr_nrtelefo)-4)||'-'||SUBSTR(pr_nrtelefo,-4);  
  END;
  
  --> Funcao para retornar os parametros de logo para utilização no relatorio
  FUNCTION fn_prm_logo_relat( pr_cdcooper IN crapcop.cdcooper%TYPE,
                              pr_nmrescop IN crapcop.nmrescop%TYPE) RETURN VARCHAR2 IS
    /* ..........................................................................
    --
    --  Programa : fn_prm_logo_relat
    --  Sistema  : Progrid
    --  Sigla    : GENE
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Agosto/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Funcao para retornar os parametros de logo para utilização no relatorio
    --
    --  Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................*/
    
    vr_dsimglog VARCHAR2(500);
    vr_dsprmlog VARCHAR2(1500);
    
  BEGIN
    
    --Logo do progrid
    vr_dsimglog := gene0001.fn_param_sistema (pr_nmsistem => 'CRED', 
                                              pr_cdcooper => pr_cdcooper, 
                                              pr_cdacesso => 'IMG_LOGO_PROGRID');
                                              
    vr_dsprmlog := 'PR_LOGOPROGRID##'|| vr_dsimglog||'@@';
    
    --> Logo da cooperativa
    vr_dsimglog := gene0001.fn_param_sistema (pr_nmsistem => 'CRED', 
                                              pr_cdcooper => pr_cdcooper, 
                                              pr_cdacesso => 'IMG_LOGO_COOP_PROGRID');
                                              
    vr_dsimglog := vr_dsimglog||'logo_'||replace(lower(pr_nmrescop),' ','_')||'.gif';
    vr_dsprmlog := vr_dsprmlog||'PR_LOGOCOOP##'|| vr_dsimglog||'@@';
    
    RETURN vr_dsprmlog;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
  END fn_prm_logo_relat;

  PROCEDURE pc_retorna_pa_pessoa(pr_cdcooper in  crapcop.cdcooper%type,
                                 pr_nrcpfcgc in  crapass.nrcpfcgc%type,
                                 pr_cdagenci out crapage.cdagenci%type,
                                 pr_cdcritic out crapcri.cdcritic%type,    --> Codigo da critica
                                 pr_dscritic out crapcri.dscritic%type) IS --> Descricao da critica  
                                     
    /* .............................................................................

    Programa:  pc_retorna_pa_pessoa
    Sistema : Progrid
    Autor   : Márcio(Mouts)
    Data    : Dezembro/2018                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Retornar o número do PA relacionado a conta que está na tabela tbcadast_pessoa 

    Alteracoes: -----
    ..............................................................................*/                                     
   cursor agencia is
     select
           tg.cdagenci
       from 
           tbevento_pessoa_grupos tg
      where
           tg.cdcooper = pr_cdcooper 
       AND tg.idpessoa = ( select 
                                 tp.idpessoa
                             from
                                 tbcadast_pessoa tp
                            where
                                 tp.nrcpfcgc = pr_nrcpfcgc);                                

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000); 
  
    
  BEGIN
    pr_cdagenci:=-1; -- Inicia como -1 pois se não encontrar não deve carregar os eventos
    FOR c1 in agencia LOOP
      pr_cdagenci:= c1.cdagenci;
    END LOOP;
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;  
  END pc_retorna_pa_pessoa;   

  PROCEDURE pc_retorna_grupo_coop(pr_cdcooper in  crapcop.cdcooper%type,
                                  pr_nrcpfcgc in  crapass.nrcpfcgc%type,
                                  pr_nmdgrupo out tbevento_grupos.nmdgrupo%type,
                                  pr_cdcritic out crapcri.cdcritic%type,    --> Codigo da critica
                                  pr_dscritic out crapcri.dscritic%type) IS --> Descricao da critica  
    /* .............................................................................

    Programa:  pc_retorna_grupo_coop
    Sistema : Progrid
    Autor   : Márcio(Mouts)
    Data    : Dezembro/2018                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Retornar o grupo da qual o cooperado participa

    Alteracoes: -----
    ..............................................................................*/                                     
   cursor grupo is
    select tg.nmdgrupo 
    from tbevento_pessoa_grupos tp,
         tbevento_grupos tg
   where tp.cdcooper = pr_cdcooper
     and tp.nrcpfcgc = pr_nrcpfcgc
     and tg.cdcooper = tp.cdcooper
     and tg.cdagenci = tp.cdagenci
     and tg.nrdgrupo = tp.nrdgrupo;

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000); 
    
  BEGIN
    pr_nmdgrupo:= 'Não Cad';
    FOR c1 in grupo LOOP
      pr_nmdgrupo:= c1.nmdgrupo;
    END LOOP;
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;  
      
  END pc_retorna_grupo_coop;   

  
BEGIN

  --> Inicializar temptable com os dias da semana usados pelo progrid
  vr_tab_dia_semana(0) := 'DOMINGO';
  vr_tab_dia_semana(1) := 'SEGUNDA-FEIRA';
  vr_tab_dia_semana(2) := 'TERÇA-FEIRA';
  vr_tab_dia_semana(3) := 'QUARTA-FEIRA';
  vr_tab_dia_semana(4) := 'QUINTA-FEIRA';
  vr_tab_dia_semana(5) := 'SEXTA-FEIRA';
  vr_tab_dia_semana(6) := 'SÁBADO';
  

END PRGD0002;
/
