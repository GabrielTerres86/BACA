CREATE OR REPLACE PACKAGE CECRED.CADA0009 is
  /*---------------------------------------------------------------------------------------------------------------
   --
  --  Programa : CADA0009
  --  Sistema  : CRM
  --  Sigla    : CADA
  --  Autor    : Andrino Carlos de Souza Junior (Mouts)
  --  Data     : Agosto/2017.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Efetuar a igualdade de todas as bases do cadastro
  --
  -- Alteracoes:   
  --    
  --  
  ---------------------------------------------------------------------------------------------------------------*/
  
    -- Tipo de registro
    TYPE typ_reg_conta IS
        RECORD (cdcooper crapttl.cdcooper%TYPE,
                nrdconta crapttl.nrdconta%TYPE,
                idseqttl crapttl.idseqttl%TYPE,
                inpessoa crapass.inpessoa%TYPE,
                pr_rowid ROWID,
                tptabela PLS_INTEGER);
    /* Definicao de tabela que compreende os registros acima declarados */
    TYPE typ_tab_conta IS
      TABLE OF typ_reg_conta
      INDEX BY VARCHAR2(15);
    /* Vetor com as informacoes das contas*/
    vr_conta typ_tab_conta;

  /*****************************************************************************/
  /**            Procedure para execucao do processo                          **/
  /*****************************************************************************/
  PROCEDURE pc_executa_processo(pr_dscritic OUT VARCHAR2);
  
  
END CADA0009;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CADA0009 IS
  /*---------------------------------------------------------------------------------------------------------------
   --
  --  Programa : CADA0009
  --  Sistema  : CRM
  --  Sigla    : CADA
  --  Autor    : Andrino Carlos de Souza Junior (Mouts)
  --  Data     : Agosto/2017.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Efetuar a igualdade de todas as bases do cadastro
  --
  -- Alteracoes:   
  --    
  --  
  ---------------------------------------------------------------------------------------------------------------*/

  -- Variaveis de log
  vr_log        CLOB;          --> Variavel de log
  vr_log_aux    VARCHAR2(32600); --> Variavel auxiliar de log

  PROCEDURE pc_exclui_auxiliares(pr_inpessoa_dst crapass.inpessoa%TYPE,
                                 pr_cdcooper_dst crapass.cdcooper%TYPE,
                                 pr_nrdconta_dst crapass.nrdconta%TYPE,
                                 pr_idseqttl_dst crapttl.idseqttl%TYPE,
                                 pr_dscritic OUT VARCHAR2) IS
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic   VARCHAR2(1000);
    vr_exc_erro   EXCEPTION;     
  BEGIN
    -- Cadastro de conjuge
    BEGIN
      DELETE crapcje
       WHERE cdcooper = pr_cdcooper_dst      
         AND nrdconta = pr_nrdconta_dst
         AND idseqttl = pr_idseqttl_dst;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir CRAPCJE: '||SQLERRM;
        RAISE vr_exc_erro;
    END;


    -- Cadastro de email
    BEGIN
      DELETE crapcem
       WHERE cdcooper = pr_cdcooper_dst      
         AND nrdconta = pr_nrdconta_dst
         AND idseqttl = pr_idseqttl_dst;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir CRAPCEM: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

    -- Cadastro de endereco
    BEGIN
      DELETE crapenc
       WHERE cdcooper = pr_cdcooper_dst      
         AND nrdconta = pr_nrdconta_dst
         AND idseqttl = pr_idseqttl_dst;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir CRAPENC: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

    -- Cadastro de informacoes financeiras
    BEGIN
      DELETE crapjfn
       WHERE cdcooper = pr_cdcooper_dst      
         AND nrdconta = pr_nrdconta_dst;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir CRAPJFN: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

    -- Cadastro de participacoes em empresas
    BEGIN
      DELETE crapepa
       WHERE cdcooper = pr_cdcooper_dst      
         AND nrdconta = pr_nrdconta_dst;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir CRAPEPA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

    -- Cadastro de responsavel legal
    BEGIN
      DELETE crapcrl
       WHERE cdcooper = pr_cdcooper_dst      
         AND nrctamen = pr_nrdconta_dst
         AND idseqmen = pr_idseqttl_dst;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir CRAPCRL: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

    -- Cadastro de dependentes
    BEGIN
      DELETE crapdep
       WHERE cdcooper = pr_cdcooper_dst      
         AND nrdconta = pr_nrdconta_dst
         AND idseqdep = pr_idseqttl_dst;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir CRAPDEP: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

    -- Cadastro de telefones
    BEGIN
      DELETE craptfc
       WHERE cdcooper = pr_cdcooper_dst      
         AND nrdconta = pr_nrdconta_dst
         AND idseqttl = pr_idseqttl_dst;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir CRAPTFC: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    -- Cadastro de bens
    BEGIN
      DELETE crapbem
       WHERE cdcooper = pr_cdcooper_dst      
         AND nrdconta = pr_nrdconta_dst
         AND idseqttl = pr_idseqttl_dst;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir CRAPBEM: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    -- Excluir representantes legais diferentes de procuradores
    BEGIN
      DELETE crapavt
       WHERE cdcooper = pr_cdcooper_dst      
         AND nrdconta = pr_nrdconta_dst
         AND tpctrato = 6
         AND pr_inpessoa_dst <> 1
         AND dsproftl <> 'PROCURADOR';
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir CRAPAVT: '||SQLERRM;
        RAISE vr_exc_erro;
    END;


    -- Excluir as pessoas de referencia
    BEGIN
      DELETE crapavt
       WHERE cdcooper = pr_cdcooper_dst      
         AND nrdconta = pr_nrdconta_dst
         AND tpctrato = 5
         AND nrctremp = decode(pr_inpessoa_dst, 1, pr_idseqttl_dst, nrctremp);
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir CRAPAVT: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_exclui_auxiliares: '||SQLERRM;          
  END;                                 

  -- Insere o cadastro de participacao em empresas
  PROCEDURE pc_insere_crapepa(pr_cdcooper_org crapass.cdcooper%TYPE,
                              pr_nrdconta_org crapass.nrdconta%TYPE,
                              pr_cdcooper_dst crapass.cdcooper%TYPE,
                              pr_nrdconta_dst crapass.nrdconta%TYPE,
                              pr_dscritic OUT VARCHAR2) IS

    ---------------> VARIAVEIS <----------------- 
    vr_dscritic   VARCHAR2(1000);
    vr_exc_erro   EXCEPTION;     
    
  BEGIN
    -- Inserir na tabela de participacao
    BEGIN
      INSERT INTO crapepa
        (cdcooper,
         nrdconta,
         nrdocsoc,
         nrctasoc,
         nmfansia,
         nrinsest,
         natjurid,
         dtiniatv,
         qtfilial,
         qtfuncio,
         dsendweb,
         cdseteco,
         cdmodali,
         cdrmativ,
         vledvmto,
         dtadmiss,
         dtmvtolt,
         persocio,
         nmprimtl)
       SELECT pr_cdcooper_dst,
              pr_nrdconta_dst,
              nrdocsoc,
              nrctasoc,
              nmfansia,
              nrinsest,
              natjurid,
              dtiniatv,
              qtfilial,
              qtfuncio,
              dsendweb,
              cdseteco,
              cdmodali,
              cdrmativ,
              vledvmto,
              dtadmiss,
              dtmvtolt,
              persocio,
              nmprimtl
         FROM crapepa
        WHERE cdcooper = pr_cdcooper_org
          AND nrdconta = pr_nrdconta_org
          AND (nrctasoc = 0 OR pr_cdcooper_dst = pr_cdcooper_org);
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir na CRAPEPA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    -- Se for entre cooperativas diferentes
    IF pr_cdcooper_dst <> pr_cdcooper_org THEN
      BEGIN
        INSERT INTO crapepa
          (cdcooper,
           nrdconta,
           nrdocsoc,
           nrctasoc,
           nmfansia,
           nrinsest,
           natjurid,
           dtiniatv,
           qtfilial,
           qtfuncio,
           dsendweb,
           cdseteco,
           cdmodali,
           cdrmativ,
           vledvmto,
           dtadmiss,
           dtmvtolt,
           persocio,
           nmprimtl)
        SELECT 
             pr_cdcooper_dst,
             pr_nrdconta_dst,
             c.nrdocsoc,
             0,
             a.nmfansia,
             a.nrinsest,
             a.natjurid,
             a.dtiniatv,
             a.qtfilial,
             a.qtfuncio,
             a.dsendweb,
             a.cdseteco,
             a.cdmodali,
             a.cdrmativ,
             c.vledvmto,
             c.dtadmiss,
             c.dtmvtolt,
             c.persocio,
             b.nmprimtl
        FROM crapepa c,
             crapass b,
             crapjur a
       WHERE c.cdcooper = pr_cdcooper_org
         AND c.nrdconta = pr_nrdconta_org
         AND c.nrctasoc = 0
         AND a.cdcooper = a.cdcooper
         AND a.nrdconta = c.nrctasoc
         AND b.cdcooper = a.cdcooper
         AND b.nrdconta = a.nrdconta;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro na inclusao da CRAPEPA: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END IF;
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_insere_auxiliares: '||SQLERRM;          
  END;
      
  -- Insere o cadastro de responsavel legal
  PROCEDURE pc_insere_crapcrl(pr_cdcooper_org crapass.cdcooper%TYPE,
                              pr_nrdconta_org crapass.nrdconta%TYPE,
                              pr_idseqttl_org crapttl.idseqttl%TYPE,
                              pr_cdcooper_dst crapass.cdcooper%TYPE,
                              pr_nrdconta_dst crapass.nrdconta%TYPE,
                              pr_idseqttl_dst crapttl.idseqttl%TYPE,
                              pr_dscritic OUT VARCHAR2) IS

    ---------------> VARIAVEIS <----------------- 
    vr_dscritic   VARCHAR2(1000);
    vr_exc_erro   EXCEPTION;     
    
  BEGIN
    -- Inserir na tabela de responsavel legal
    BEGIN
      INSERT INTO crapcrl
        (cdcooper,
         nrctamen,
         nrcpfmen,
         idseqmen,
         nrdconta,
         nrcpfcgc,
         nmrespon,
         idorgexp,
         cdufiden,
         dtemiden,
         dtnascin,
         cddosexo,
         cdestciv,
         cdnacion,
         dsnatura,
         cdcepres,
         dsendres,
         nrendres,
         dscomres,
         dsbaires,
         nrcxpost,
         dscidres,
         dsdufres,
         nmpairsp,
         nmmaersp,
         tpdeiden,
         nridenti,
         dtmvtolt,
         flgimpri,
         cdrlcrsp)
      SELECT pr_cdcooper_dst,
             pr_nrdconta_dst,
             nrcpfmen,
             pr_idseqttl_dst,
             nrdconta,
             nrcpfcgc,
             nmrespon,
             idorgexp,
             cdufiden,
             dtemiden,
             dtnascin,
             cddosexo,
             cdestciv,
             cdnacion,
             dsnatura,
             cdcepres,
             dsendres,
             nrendres,
             dscomres,
             dsbaires,
             nrcxpost,
             dscidres,
             dsdufres,
             nmpairsp,
             nmmaersp,
             tpdeiden,
             nridenti,
             dtmvtolt,
             flgimpri,
             cdrlcrsp
        FROM crapcrl
       WHERE cdcooper = pr_cdcooper_org
         AND nrctamen = pr_nrdconta_org
         AND idseqmen = pr_idseqttl_org
         AND (pr_cdcooper_dst = pr_cdcooper_org
          OR  nrdconta = 0);
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro inserir na CRAPCLR: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    -- Se for entre cooperativas diferentes
    IF pr_cdcooper_dst <> pr_cdcooper_org AND
       SQL%ROWCOUNT = 0 THEN
      BEGIN
        INSERT INTO crapcrl
          (cdcooper,
           nrctamen,
           nrcpfmen,
           idseqmen,
           nrdconta,
           nrcpfcgc,
           nmrespon,
           idorgexp,
           cdufiden,
           dtemiden,
           dtnascin,
           cddosexo,
           cdestciv,
           cdnacion,
           dsnatura,
           cdcepres,
           dsendres,
           nrendres,
           dscomres,
           dsbaires,
           nrcxpost,
           dscidres,
           dsdufres,
           nmpairsp,
           nmmaersp,
           tpdeiden,
           nridenti,
           dtmvtolt,
           flgimpri,
           cdrlcrsp)
        SELECT pr_cdcooper_dst,
               pr_nrdconta_dst,
               nrcpfmen,
               pr_idseqttl_dst,
               0,
               b.nrcpfcgc,
               substr(b.nmextttl,1,40),
               b.idorgexp,
               b.cdufdttl,
               b.dtemdttl,
               b.dtnasttl,
               b.cdsexotl,
               b.cdestcvl,
               b.cdnacion,
               b.dsnatura,
               c.nrcepend,
               c.dsendere,
               c.nrendere,
               substr(c.complend,1,40),
               c.nmbairro,
               c.nrcxapst,
               c.nmcidade,
               c.cdufende,
               b.nmpaittl,
               b.nmmaettl,
               b.tpdocttl,
               b.nrdocttl,
               a.dtmvtolt,
               a.flgimpri,
               a.cdrlcrsp
          FROM crapenc c,
               crapttl b,
               crapcrl a
         WHERE a.cdcooper = pr_cdcooper_org
           AND a.nrctamen = pr_nrdconta_org
           AND a.idseqmen = pr_idseqttl_org
           AND b.cdcooper = a.cdcooper
           AND b.nrdconta = a.nrdconta
           AND b.idseqttl = 1
           AND c.cdcooper = b.cdcooper
           AND c.nrdconta = b.nrdconta
           AND c.idseqttl = b.idseqttl
           AND c.tpendass = 10
           AND rownum = 1;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro na inclusao da CRAPCRL: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END IF;
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_insere_crapcrl: '||SQLERRM;          
  END;
      
  -- Insere o cadastro de conjuge
  PROCEDURE pc_insere_crapcje(pr_cdcooper_org crapass.cdcooper%TYPE,
                              pr_nrdconta_org crapass.nrdconta%TYPE,
                              pr_idseqttl_org crapttl.idseqttl%TYPE,
                              pr_cdcooper_dst crapass.cdcooper%TYPE,
                              pr_nrdconta_dst crapass.nrdconta%TYPE,
                              pr_idseqttl_dst crapttl.idseqttl%TYPE,
                              pr_dscritic OUT VARCHAR2) IS

    ---------------> VARIAVEIS <----------------- 
    vr_dscritic   VARCHAR2(1000);
    vr_exc_erro   EXCEPTION;     
    
  BEGIN
    -- Inserir na tabela de conjuge
    BEGIN
      INSERT INTO crapcje
        (cdcooper, 
         nrdconta, 
         idseqttl, 
         nmconjug, 
         nrcpfcjg, 
         dtnasccj, 
         tpdoccje, 
         nrdoccje, 
         cdufdcje, 
         dtemdcje, 
         grescola, 
         cdfrmttl, 
         cdnatopc, 
         cdocpcje, 
         tpcttrab, 
         nmextemp, 
         dsproftl, 
         cdnvlcgo, 
         nrfonemp, 
         nrramemp, 
         cdturnos, 
         dtadmemp, 
         vlsalari, 
         nrdocnpj, 
         nrctacje, 
         dsendcom, 
         idorgexp)
      SELECT pr_cdcooper_dst, 
             pr_nrdconta_dst, 
             pr_idseqttl_dst, 
             nmconjug, 
             nrcpfcjg, 
             dtnasccj, 
             tpdoccje, 
             nrdoccje, 
             cdufdcje, 
             dtemdcje, 
             grescola, 
             cdfrmttl, 
             cdnatopc, 
             cdocpcje, 
             tpcttrab, 
             nmextemp, 
             dsproftl, 
             cdnvlcgo, 
             nrfonemp, 
             nrramemp, 
             cdturnos, 
             dtadmemp, 
             vlsalari, 
             nrdocnpj, 
             nrctacje, 
             dsendcom, 
             idorgexp
        FROM crapcje
       WHERE cdcooper = pr_cdcooper_org
         AND nrdconta = pr_nrdconta_org
         AND idseqttl = pr_idseqttl_org
         AND (pr_cdcooper_dst = pr_cdcooper_org
          OR  nrctacje = 0);
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir na CRAPCJE: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    -- Se for entre cooperativas diferentes
    IF pr_cdcooper_dst <> pr_cdcooper_org AND
       SQL%ROWCOUNT = 0 THEN -- Nao teve inclusao no insert anterior
      BEGIN
        INSERT INTO crapcje
          (cdcooper, 
           nrdconta, 
           idseqttl, 
           nmconjug, 
           nrcpfcjg, 
           dtnasccj, 
           tpdoccje, 
           nrdoccje, 
           cdufdcje, 
           dtemdcje, 
           grescola, 
           cdfrmttl, 
           cdnatopc, 
           cdocpcje, 
           tpcttrab, 
           nmextemp, 
           dsproftl, 
           cdnvlcgo, 
           nrfonemp, 
           nrramemp, 
           cdturnos, 
           dtadmemp, 
           vlsalari, 
           nrdocnpj, 
           nrctacje, 
           dsendcom, 
           idorgexp)
        SELECT pr_cdcooper_dst,
               pr_nrdconta_dst,
               pr_idseqttl_dst,
               b.nmextttl, 
               b.nrcpfcgc, 
               b.dtnasttl, 
               b.tpdocttl, 
               b.nrdocttl, 
               b.cdufdttl, 
               b.dtemdttl, 
               b.grescola, 
               b.cdfrmttl, 
               b.cdnatopc, 
               b.cdocpttl, 
               b.tpcttrab, 
               b.nmextemp,
               b.dsproftl,
               b.cdnvlcgo,
               nvl(to_char(d.nrtelefo),' '),
               nvl(d.nrdramal,0),
               b.cdturnos,
               b.dtadmemp,
               b.vlsalari,
               b.nrcpfemp,
               0,
               nvl(c.dsendere,' '), 
               b.idorgexp
          FROM craptfc d,
               crapenc c,
               crapttl b,
               crapcje a
         WHERE a.cdcooper = pr_cdcooper_org
           AND a.nrdconta = pr_nrdconta_org
           AND a.idseqttl = pr_idseqttl_org
           AND b.cdcooper = a.cdcooper
           AND b.nrdconta = a.nrctacje 
           AND b.idseqttl = 1
           AND c.cdcooper (+)= b.cdcooper
           AND c.nrdconta (+)= b.nrdconta
           AND c.idseqttl (+)= b.idseqttl
           AND c.tpendass (+)= 9 -- Comercial
           AND d.cdcooper (+)= b.cdcooper
           AND d.nrdconta (+)= b.nrdconta
           AND d.idseqttl (+)= b.idseqttl
           AND d.tptelefo (+)= 3 -- Comercial
           AND rownum = 1;
           
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro na inclusao da CRAPCJE: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END IF;
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_insere_crapcje: '||SQLERRM;          
  END;
      
  -- Insere o cadastro de pessoas de referencia e representantes legais
  PROCEDURE pc_insere_crapavt(pr_inpessoa_org crapass.inpessoa%TYPE,
                              pr_cdcooper_org crapass.cdcooper%TYPE,
                              pr_nrdconta_org crapass.nrdconta%TYPE,
                              pr_idseqttl_org crapttl.idseqttl%TYPE,
                              pr_cdcooper_dst crapass.cdcooper%TYPE,
                              pr_nrdconta_dst crapass.nrdconta%TYPE,
                              pr_idseqttl_dst crapttl.idseqttl%TYPE,
                              pr_dscritic OUT VARCHAR2) IS

    -- Tipo de registro de bem
    TYPE typ_reg_bem IS
        RECORD (dsrelbem crapbem.dsrelbem%TYPE,
                persemon crapbem.persemon%TYPE,
                qtprebem crapbem.qtprebem%TYPE,
                vlrdobem crapbem.vlrdobem%TYPE,
                vlprebem crapbem.vlprebem%TYPE);
    /* Definicao de tabela que compreende os registros acima declarados */
    TYPE typ_tab_bem IS
      TABLE OF typ_reg_bem
      INDEX BY BINARY_INTEGER;
    /* Vetor com as informacoes bem*/
    vr_bem typ_tab_bem;

    -- Cursor para busca dos bens
    CURSOR cr_crapbem(pr_cdcooper craptfc.cdcooper%TYPE,
                      pr_nrdconta craptfc.nrdconta%TYPE,
                      pr_idseqttl craptfc.idseqttl%TYPE) IS
      SELECT a.dsrelbem,
             a.persemon,
             a.qtprebem,
             a.vlrdobem,
             a.vlprebem,
             a.idseqbem
        FROM crapbem a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.idseqttl = pr_idseqttl
        ORDER BY a.idseqbem;

    -- Cursor para buscar as referencia que possuem conta
    CURSOR cr_crapavt IS
      SELECT b.nrcpfcgc nrcpforg,
             a.*
        FROM crapass b,
             crapavt a
       WHERE a.cdcooper = pr_cdcooper_org
         AND a.nrdconta = pr_nrdconta_org
         AND a.nrdctato > 0 -- Somente se tiver conta referenciada
         AND b.cdcooper = a.cdcooper
         AND b.nrdconta = a.nrdctato
         AND ((a.tpctrato = 6 -- Representantes
         AND   pr_inpessoa_org <> 1 -- Diferente de PF
         AND   a.dsproftl <> 'PROCURADOR')
          OR  (a.tpctrato = 5 -- Pessoa de referencia
         AND   pr_inpessoa_org <> 1)
          OR  (a.tpctrato = 5 -- Pessoa de referencia
         AND   pr_inpessoa_org =  1
         AND   a.nrctremp = pr_idseqttl_org));

    -- Cursor para verificar se o CPF / CNPJ possui conta na cooperativa de destino
    CURSOR cr_crapass(pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
      SELECT nrdconta
        FROM crapass a
       WHERE cdcooper = pr_cdcooper_dst
         AND nrcpfcgc = pr_nrcpfcgc
       ORDER BY decode(a.dtdemiss,NULL,0,1), a.dtadmiss DESC;
    rw_crapass cr_crapass%ROWTYPE;

    -- Cursor para buscar os telefones
    CURSOR cr_craptfc(pr_cdcooper craptfc.cdcooper%TYPE,
                      pr_nrdconta craptfc.nrdconta%TYPE,
                      pr_idseqttl craptfc.idseqttl%TYPE,
                      pr_tptelefo craptfc.tptelefo%TYPE) IS
      SELECT a.nrtelefo,
             a.nrdramal
        FROM craptfc a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.idseqttl = pr_idseqttl
         AND a.tptelefo = pr_tptelefo
         ORDER BY a.cdseqtfc;
    rw_craptfc cr_craptfc%ROWTYPE;
    
    -- Cursor para buscar o conjuge
    CURSOR cr_crapcje(pr_cdcooper craptfc.cdcooper%TYPE,
                      pr_nrdconta craptfc.nrdconta%TYPE,
                      pr_idseqttl craptfc.idseqttl%TYPE) IS
      SELECT a.nrcpfcjg,
             a.nmconjug,
             a.tpdoccje,
             a.nrdoccje
        FROM crapcje a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.nrctacje = 0
       UNION ALL   
      SELECT b.nrcpfcgc,
             b.nmextttl,
             b.tpdocttl,
             b.nrdocttl
        FROM crapttl b,
             crapcje a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND b.cdcooper = a.cdcooper
         AND b.nrdconta = a.nrdconta
         AND b.idseqttl = pr_idseqttl
         AND a.nrctacje <> 0;    
    rw_crapcje cr_crapcje%ROWTYPE;
    
    -- Cursor para buscar os emails
    CURSOR cr_crapcem(pr_cdcooper craptfc.cdcooper%TYPE,
                      pr_nrdconta craptfc.nrdconta%TYPE,
                      pr_idseqttl craptfc.idseqttl%TYPE) IS
      SELECT a.dsdemail
        FROM crapcem a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.idseqttl = pr_idseqttl
         ORDER BY a.cddemail;
    rw_crapcem cr_crapcem%ROWTYPE;

    -- Cursor para buscar os telefones
    CURSOR cr_crapenc(pr_cdcooper crapenc.cdcooper%TYPE,
                      pr_nrdconta crapenc.nrdconta%TYPE,
                      pr_idseqttl crapenc.idseqttl%TYPE,
                      pr_tpencass crapenc.tpendass%TYPE) IS
      SELECT a.nrcepend,
             a.dsendere,
             a.nrendere,
             a.nmbairro,
             a.nmcidade,
             a.cdufende,
             a.complend
        FROM crapenc a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.idseqttl = pr_idseqttl
         AND a.tpendass = pr_tpencass
         ORDER BY a.cdseqinc;
    rw_crapenc cr_crapenc%ROWTYPE;


    -- Cursor para buscar o nome do cooperado
    CURSOR cr_crapass_2(pr_cdcooper craptfc.cdcooper%TYPE,
                        pr_nrdconta craptfc.nrdconta%TYPE) IS
      SELECT a.nmprimtl,
             a.tpdocptl,
             a.nrdocptl,
             a.dtemdptl,
             a.cdufdptl,
             a.idorgexp,
             a.dtnasctl,
             b.nmpaittl,
             b.nmmaettl,
             b.dsnatura,
             b.cdsexotl,
             b.cdestcvl,
             b.inhabmen, 
             b.dthabmen,
             nvl(b.cdnacion, a.cdnacion) cdnacion
        FROM crapttl b,
             crapass a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND b.cdcooper (+) = a.cdcooper
         AND b.nrdconta (+) = a.nrdconta
         AND b.idseqttl (+) = 1;
    rw_crapass_2 cr_crapass_2%ROWTYPE;


    ---------------> VARIAVEIS <----------------- 
    vr_dscritic   VARCHAR2(1000);
    vr_exc_erro   EXCEPTION;     
    
  BEGIN
    -- Exclui os procuradores da conta de destino que possuem o mesmo CPF
    -- da conta de origem e que nao sao procuradores
    -- Isso eh necessario para nao dar chave duplicada
    IF pr_inpessoa_org <> 1 THEN
      BEGIN
        DELETE crapavt x
         WHERE x.cdcooper = pr_cdcooper_dst
           AND x.nrdconta = pr_nrdconta_dst
           AND x.dsproftl = 'PROCURADOR'
           AND x.tpctrato = 6
           AND EXISTS (SELECT 1
                         FROM crapavt a
                        WHERE a.cdcooper = pr_cdcooper_org
                          AND a.nrdconta = pr_nrdconta_org
                          AND a.tpctrato = 6
                          AND a.dsproftl <> 'PROCURADOR'
                          AND a.nrcpfcgc = x.nrcpfcgc);
      EXCEPTION
        WHEN OTHERS THEN
           vr_dscritic := 'Erro exclusao CRAPAVT '||SQLERRM;
           RAISE vr_exc_erro;
      END;
    END IF;

    -- Se a cooperativa de origem for igual a cooperativa de destino, entao pode-se
    -- fazer o insert direto, pois existe conta de referencia nesta tabela
    IF pr_cdcooper_org = pr_cdcooper_dst THEN
      -- Insere os contatos e representantes legais
      BEGIN
        INSERT INTO crapavt
          (nrdconta,
           nrctremp,
           nrcpfcgc,
           nmdavali,
           nrcpfcjg,
           nmconjug,
           tpdoccjg,
           nrdoccjg,
           tpdocava,
           nrdocava,
           dsendres##1,
           dsendres##2,
           nrfonres,
           dsdemail,
           tpctrato,
           nrcepend,
           nmcidade,
           cdufresd,
           dtmvtolt,
           cdcooper,
           cdnacion,
           nrendere,
           complend,
           nmbairro,
           nrcxapst,
           nrtelefo,
           nmextemp,
           cddbanco,
           cdagenci,
           dsproftl,
           nrdctato,
           idorgexp,
           dtemddoc,
           cdufddoc,
           dtvalida,
           nmmaecto,
           nmpaicto,
           dtnascto,
           dsnatura,
           cdsexcto,
           cdestcvl,
           flgimpri,
           dsrelbem##1,
           dsrelbem##2,
           dsrelbem##3,
           dsrelbem##4,
           dsrelbem##5,
           dsrelbem##6,
           persemon##1,
           persemon##2,
           persemon##3,
           persemon##4,
           persemon##5,
           persemon##6,
           qtprebem##1,
           qtprebem##2,
           qtprebem##3,
           qtprebem##4,
           qtprebem##5,
           qtprebem##6,
           vlprebem##1,
           vlprebem##2,
           vlprebem##3,
           vlprebem##4,
           vlprebem##5,
           vlprebem##6,
           vlrdobem##1,
           vlrdobem##2,
           vlrdobem##3,
           vlrdobem##4,
           vlrdobem##5,
           vlrdobem##6,
           vlrenmes,
           vledvmto,
           dtadmsoc,
           persocio,
           flgdepec,
           vloutren,
           dsoutren,
           inhabmen,
           dthabmen,
           inpessoa,
           dtdrisco,
           qtopescr,
           qtifoper,
           vltotsfn,
           vlopescr,
           vlprejuz,
           idmsgvct)
        SELECT pr_nrdconta_dst,
               DECODE(pr_inpessoa_org, 1,
                        pr_idseqttl_dst, nrctremp),
               nrcpfcgc,
               nmdavali,
               nrcpfcjg,
               nmconjug,
               tpdoccjg,
               nrdoccjg,
               tpdocava,
               nrdocava,
               dsendres##1,
               dsendres##2,
               nrfonres,
               dsdemail,
               tpctrato,
               nrcepend,
               nmcidade,
               cdufresd,
               dtmvtolt,
               pr_cdcooper_dst,
               cdnacion,
               nrendere,
               complend,
               nmbairro,
               nrcxapst,
               nrtelefo,
               nmextemp,
               cddbanco,
               cdagenci,
               dsproftl,
               nrdctato,
               idorgexp,
               dtemddoc,
               cdufddoc,
               dtvalida,
               nmmaecto,
               nmpaicto,
               dtnascto,
               dsnatura,
               cdsexcto,
               cdestcvl,
               flgimpri,
               dsrelbem##1,
               dsrelbem##2,
               dsrelbem##3,
               dsrelbem##4,
               dsrelbem##5,
               dsrelbem##6,
               persemon##1,
               persemon##2,
               persemon##3,
               persemon##4,
               persemon##5,
               persemon##6,
               qtprebem##1,
               qtprebem##2,
               qtprebem##3,
               qtprebem##4,
               qtprebem##5,
               qtprebem##6,
               vlprebem##1,
               vlprebem##2,
               vlprebem##3,
               vlprebem##4,
               vlprebem##5,
               vlprebem##6,
               vlrdobem##1,
               vlrdobem##2,
               vlrdobem##3,
               vlrdobem##4,
               vlrdobem##5,
               vlrdobem##6,
               vlrenmes,
               vledvmto,
               dtadmsoc,
               persocio,
               flgdepec,
               vloutren,
               dsoutren,
               inhabmen,
               dthabmen,
               inpessoa,
               dtdrisco,
               qtopescr,
               qtifoper,
               vltotsfn,
               vlopescr,
               vlprejuz,
               idmsgvct 
          FROM crapavt
         WHERE cdcooper = pr_cdcooper_org
           AND nrdconta = pr_nrdconta_org
           AND ((tpctrato = 6 -- Representantes
           AND   pr_inpessoa_org <> 1 -- Diferente de PF
           AND   dsproftl <> 'PROCURADOR')
            OR  (tpctrato = 5 -- Pessoa de referencia
           AND   pr_inpessoa_org <> 1)
            OR  (tpctrato = 5 -- Pessoa de referencia
           AND   pr_inpessoa_org =  1
           AND   nrctremp = pr_idseqttl_org));
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPAVT: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    ELSE -- Se for de cooperativas diferentes
      -- Primeiro faz o insert onde a conta de referencia for zerado
      BEGIN
        INSERT INTO crapavt
          (nrdconta,
           nrctremp,
           nrcpfcgc,
           nmdavali,
           nrcpfcjg,
           nmconjug,
           tpdoccjg,
           nrdoccjg,
           tpdocava,
           nrdocava,
           dsendres##1,
           dsendres##2,
           nrfonres,
           dsdemail,
           tpctrato,
           nrcepend,
           nmcidade,
           cdufresd,
           dtmvtolt,
           cdcooper,
           cdnacion,
           nrendere,
           complend,
           nmbairro,
           nrcxapst,
           nrtelefo,
           nmextemp,
           cddbanco,
           cdagenci,
           dsproftl,
           nrdctato,
           idorgexp,
           dtemddoc,
           cdufddoc,
           dtvalida,
           nmmaecto,
           nmpaicto,
           dtnascto,
           dsnatura,
           cdsexcto,
           cdestcvl,
           flgimpri,
           dsrelbem##1,
           dsrelbem##2,
           dsrelbem##3,
           dsrelbem##4,
           dsrelbem##5,
           dsrelbem##6,
           persemon##1,
           persemon##2,
           persemon##3,
           persemon##4,
           persemon##5,
           persemon##6,
           qtprebem##1,
           qtprebem##2,
           qtprebem##3,
           qtprebem##4,
           qtprebem##5,
           qtprebem##6,
           vlprebem##1,
           vlprebem##2,
           vlprebem##3,
           vlprebem##4,
           vlprebem##5,
           vlprebem##6,
           vlrdobem##1,
           vlrdobem##2,
           vlrdobem##3,
           vlrdobem##4,
           vlrdobem##5,
           vlrdobem##6,
           vlrenmes,
           vledvmto,
           dtadmsoc,
           persocio,
           flgdepec,
           vloutren,
           dsoutren,
           inhabmen,
           dthabmen,
           inpessoa,
           dtdrisco,
           qtopescr,
           qtifoper,
           vltotsfn,
           vlopescr,
           vlprejuz,
           idmsgvct)
        SELECT pr_nrdconta_dst,
               DECODE(pr_inpessoa_org, 1,
                        pr_idseqttl_dst, nrctremp),
               nrcpfcgc,
               nmdavali,
               nrcpfcjg,
               nmconjug,
               tpdoccjg,
               nrdoccjg,
               tpdocava,
               nrdocava,
               dsendres##1,
               dsendres##2,
               nrfonres,
               dsdemail,
               tpctrato,
               nrcepend,
               nmcidade,
               cdufresd,
               dtmvtolt,
               pr_cdcooper_dst,
               cdnacion,
               nrendere,
               complend,
               nmbairro,
               nrcxapst,
               nrtelefo,
               nmextemp,
               cddbanco,
               cdagenci,
               dsproftl,
               nrdctato,
               idorgexp,
               dtemddoc,
               cdufddoc,
               dtvalida,
               nmmaecto,
               nmpaicto,
               dtnascto,
               dsnatura,
               cdsexcto,
               cdestcvl,
               flgimpri,
               dsrelbem##1,
               dsrelbem##2,
               dsrelbem##3,
               dsrelbem##4,
               dsrelbem##5,
               dsrelbem##6,
               persemon##1,
               persemon##2,
               persemon##3,
               persemon##4,
               persemon##5,
               persemon##6,
               qtprebem##1,
               qtprebem##2,
               qtprebem##3,
               qtprebem##4,
               qtprebem##5,
               qtprebem##6,
               vlprebem##1,
               vlprebem##2,
               vlprebem##3,
               vlprebem##4,
               vlprebem##5,
               vlprebem##6,
               vlrdobem##1,
               vlrdobem##2,
               vlrdobem##3,
               vlrdobem##4,
               vlrdobem##5,
               vlrdobem##6,
               vlrenmes,
               vledvmto,
               dtadmsoc,
               persocio,
               flgdepec,
               vloutren,
               dsoutren,
               inhabmen,
               dthabmen,
               inpessoa,
               dtdrisco,
               qtopescr,
               qtifoper,
               vltotsfn,
               vlopescr,
               vlprejuz,
               idmsgvct 
          FROM crapavt a
         WHERE cdcooper = pr_cdcooper_org
           AND nrdconta = pr_nrdconta_org
           AND a.nrdctato = 0 -- Somente se nao tiver conta referenciada
           AND ((tpctrato = 6 -- Representantes
           AND   pr_inpessoa_org <> 1 -- Diferente de PF
           AND   dsproftl <> 'PROCURADOR')
            OR  (tpctrato = 5 -- Pessoa de referencia
           AND   pr_inpessoa_org <> 1)
            OR  (tpctrato = 5 -- Pessoa de referencia
           AND   pr_inpessoa_org =  1
           AND   nrctremp = pr_idseqttl_org));
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPAVT-2: '||SQLERRM;
          RAISE vr_exc_erro;
      END;      
      
      -- Efetua o insert onde possui conta de referencia na cooperativa de origem.
      -- Neste caso, nao devera ter conta na cooperativa de destino e os dados deverao
      -- ser retornados da cooperativa de origem
      FOR rw_crapavt IN cr_crapavt LOOP
        -- Verifica se existe conta na cooperativa de destino utilizando o CPF / CNPJ da origem
        OPEN cr_crapass(rw_crapavt.nrcpforg);
        FETCH cr_crapass INTO rw_crapass;
        
        -- Se possui conta
        IF cr_crapass%FOUND THEN
          -- Efetua a inclusao utilizando a conta da cooperativa de destino
          BEGIN
            INSERT INTO crapavt
              (nrdconta,
               nrctremp,
               nrcpfcgc,
               nmdavali,
               nrcpfcjg,
               nmconjug,
               tpdoccjg,
               nrdoccjg,
               tpdocava,
               nrdocava,
               dsendres##1,
               dsendres##2,
               nrfonres,
               dsdemail,
               tpctrato,
               nrcepend,
               nmcidade,
               cdufresd,
               dtmvtolt,
               cdcooper,
               cdnacion,
               nrendere,
               complend,
               nmbairro,
               nrcxapst,
               nrtelefo,
               nmextemp,
               cddbanco,
               cdagenci,
               dsproftl,
               nrdctato,
               idorgexp,
               dtemddoc,
               cdufddoc,
               dtvalida,
               nmmaecto,
               nmpaicto,
               dtnascto,
               dsnatura,
               cdsexcto,
               cdestcvl,
               flgimpri,
               dsrelbem##1,
               dsrelbem##2,
               dsrelbem##3,
               dsrelbem##4,
               dsrelbem##5,
               dsrelbem##6,
               persemon##1,
               persemon##2,
               persemon##3,
               persemon##4,
               persemon##5,
               persemon##6,
               qtprebem##1,
               qtprebem##2,
               qtprebem##3,
               qtprebem##4,
               qtprebem##5,
               qtprebem##6,
               vlprebem##1,
               vlprebem##2,
               vlprebem##3,
               vlprebem##4,
               vlprebem##5,
               vlprebem##6,
               vlrdobem##1,
               vlrdobem##2,
               vlrdobem##3,
               vlrdobem##4,
               vlrdobem##5,
               vlrdobem##6,
               vlrenmes,
               vledvmto,
               dtadmsoc,
               persocio,
               flgdepec,
               vloutren,
               dsoutren,
               inhabmen,
               dthabmen,
               inpessoa,
               dtdrisco,
               qtopescr,
               qtifoper,
               vltotsfn,
               vlopescr,
               vlprejuz,
               idmsgvct)
             VALUES
              (pr_nrdconta_dst,
               DECODE(pr_inpessoa_org, 1,
                         pr_idseqttl_dst, rw_crapavt.nrctremp),
               rw_crapavt.nrcpfcgc,
               rw_crapavt.nmdavali,
               rw_crapavt.nrcpfcjg,
               rw_crapavt.nmconjug,
               rw_crapavt.tpdoccjg,
               rw_crapavt.nrdoccjg,
               rw_crapavt.tpdocava,
               rw_crapavt.nrdocava,
               rw_crapavt.dsendres##1,
               rw_crapavt.dsendres##2,
               rw_crapavt.nrfonres,
               rw_crapavt.dsdemail,
               rw_crapavt.tpctrato,
               rw_crapavt.nrcepend,
               rw_crapavt.nmcidade,
               rw_crapavt.cdufresd,
               rw_crapavt.dtmvtolt,
               pr_cdcooper_dst,
               rw_crapavt.cdnacion,
               rw_crapavt.nrendere,
               rw_crapavt.complend,
               rw_crapavt.nmbairro,
               rw_crapavt.nrcxapst,
               rw_crapavt.nrtelefo,
               rw_crapavt.nmextemp,
               rw_crapavt.cddbanco,
               rw_crapavt.cdagenci,
               rw_crapavt.dsproftl,
               rw_crapass.nrdconta,
               rw_crapavt.idorgexp,
               rw_crapavt.dtemddoc,
               rw_crapavt.cdufddoc,
               rw_crapavt.dtvalida,
               rw_crapavt.nmmaecto,
               rw_crapavt.nmpaicto,
               rw_crapavt.dtnascto,
               rw_crapavt.dsnatura,
               rw_crapavt.cdsexcto,
               rw_crapavt.cdestcvl,
               rw_crapavt.flgimpri,
               rw_crapavt.dsrelbem##1,
               rw_crapavt.dsrelbem##2,
               rw_crapavt.dsrelbem##3,
               rw_crapavt.dsrelbem##4,
               rw_crapavt.dsrelbem##5,
               rw_crapavt.dsrelbem##6,
               rw_crapavt.persemon##1,
               rw_crapavt.persemon##2,
               rw_crapavt.persemon##3,
               rw_crapavt.persemon##4,
               rw_crapavt.persemon##5,
               rw_crapavt.persemon##6,
               rw_crapavt.qtprebem##1,
               rw_crapavt.qtprebem##2,
               rw_crapavt.qtprebem##3,
               rw_crapavt.qtprebem##4,
               rw_crapavt.qtprebem##5,
               rw_crapavt.qtprebem##6,
               rw_crapavt.vlprebem##1,
               rw_crapavt.vlprebem##2,
               rw_crapavt.vlprebem##3,
               rw_crapavt.vlprebem##4,
               rw_crapavt.vlprebem##5,
               rw_crapavt.vlprebem##6,
               rw_crapavt.vlrdobem##1,
               rw_crapavt.vlrdobem##2,
               rw_crapavt.vlrdobem##3,
               rw_crapavt.vlrdobem##4,
               rw_crapavt.vlrdobem##5,
               rw_crapavt.vlrdobem##6,
               rw_crapavt.vlrenmes,
               rw_crapavt.vledvmto,
               rw_crapavt.dtadmsoc,
               rw_crapavt.persocio,
               rw_crapavt.flgdepec,
               rw_crapavt.vloutren,
               rw_crapavt.dsoutren,
               rw_crapavt.inhabmen,
               rw_crapavt.dthabmen,
               rw_crapavt.inpessoa,
               rw_crapavt.dtdrisco,
               rw_crapavt.qtopescr,
               rw_crapavt.qtifoper,
               rw_crapavt.vltotsfn,
               rw_crapavt.vlopescr,
               rw_crapavt.vlprejuz,
               rw_crapavt.idmsgvct);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir na CRAPAVT-3: '||SQLERRM;
              RAISE vr_exc_erro;
          END;      
        ELSE -- Nao possui conta
          rw_crapenc := NULL;
          -- Busca o endereco da conta de destino
          OPEN cr_crapenc(pr_cdcooper => pr_cdcooper_org,
                          pr_nrdconta => rw_crapavt.nrdctato,
                          pr_idseqttl => 1, 
                          pr_tpencass => 10); -- Residencial
          FETCH cr_crapenc INTO rw_crapenc;
          CLOSE cr_crapenc;
          
          -- Busca os conjuges da conta de destino
          rw_crapcje := NULL;
          OPEN cr_crapcje(pr_cdcooper => pr_cdcooper_org,
                          pr_nrdconta => rw_crapavt.nrdctato,
                          pr_idseqttl => 1);
          FETCH cr_crapcje INTO rw_crapcje;
          CLOSE cr_crapcje;

          -- Limpa as variaveis de bens
          vr_bem.delete;
          
          -- Busca os bens
          FOR rw_crapbem IN cr_crapbem(pr_cdcooper => pr_cdcooper_org,
                                       pr_nrdconta => rw_crapavt.nrdctato,
                                       pr_idseqttl => 1) LOOP
            vr_bem(rw_crapbem.idseqbem).dsrelbem := rw_crapbem.dsrelbem;
            vr_bem(rw_crapbem.idseqbem).persemon := rw_crapbem.persemon;
            vr_bem(rw_crapbem.idseqbem).qtprebem := rw_crapbem.qtprebem;
            vr_bem(rw_crapbem.idseqbem).vlrdobem := rw_crapbem.vlrdobem;
            vr_bem(rw_crapbem.idseqbem).vlprebem := rw_crapbem.vlprebem;
          END LOOP;

          -- Loop para iniciar os 6 bens
          FOR x IN 1..6 LOOP
            IF NOT vr_bem.exists(x) THEN
              vr_bem(x).dsrelbem := ' ';
              vr_bem(x).persemon := 0;
              vr_bem(x).qtprebem := 0;
              vr_bem(x).vlrdobem := 0;
              vr_bem(x).vlprebem := 0;
            END IF;
          END LOOP;
          
          rw_craptfc := NULL;
          -- Busca o telefone da conta de destino
          OPEN cr_craptfc(pr_cdcooper => pr_cdcooper_org,
                          pr_nrdconta => rw_crapavt.nrdctato,
                          pr_idseqttl => 1,
                          pr_tptelefo => 1); -- Residencial
          FETCH cr_craptfc INTO rw_craptfc;
          CLOSE cr_craptfc;
          
          rw_crapcem := NULL;
          -- Busca o email da conta de destino
          OPEN cr_crapcem(pr_cdcooper => pr_cdcooper_org,
                          pr_nrdconta => rw_crapavt.nrdctato,
                          pr_idseqttl => 1);
          FETCH cr_crapcem INTO rw_crapcem;
          CLOSE cr_crapcem;
          
          -- Busca o nome da conta de destino
          OPEN cr_crapass_2(pr_cdcooper => pr_cdcooper_org,
                            pr_nrdconta => rw_crapavt.nrdctato);
          FETCH cr_crapass_2 INTO rw_crapass_2;
          CLOSE cr_crapass_2;
          
          -- Efetua a inclusao utilizando a conta da cooperativa de destino
          BEGIN
            INSERT INTO crapavt
              (nrdconta,
               nrctremp,
               nrcpfcgc,
               nmdavali,
               nrcpfcjg,
               nmconjug,
               tpdoccjg,
               nrdoccjg,
               tpdocava,
               nrdocava,
               dsendres##1,
               dsendres##2,
               nrfonres,
               dsdemail,
               tpctrato,
               nrcepend,
               nmcidade,
               cdufresd,
               dtmvtolt,
               cdcooper,
               cdnacion,
               nrendere,
               complend,
               nmbairro,
               nrcxapst,
               nrtelefo,
               nmextemp,
               cddbanco,
               cdagenci,
               dsproftl,
               nrdctato,
               idorgexp,
               dtemddoc,
               cdufddoc,
               dtvalida,
               nmmaecto,
               nmpaicto,
               dtnascto,
               dsnatura,
               cdsexcto,
               cdestcvl,
               flgimpri,
               dsrelbem##1,
               dsrelbem##2,
               dsrelbem##3,
               dsrelbem##4,
               dsrelbem##5,
               dsrelbem##6,
               persemon##1,
               persemon##2,
               persemon##3,
               persemon##4,
               persemon##5,
               persemon##6,
               qtprebem##1,
               qtprebem##2,
               qtprebem##3,
               qtprebem##4,
               qtprebem##5,
               qtprebem##6,
               vlprebem##1,
               vlprebem##2,
               vlprebem##3,
               vlprebem##4,
               vlprebem##5,
               vlprebem##6,
               vlrdobem##1,
               vlrdobem##2,
               vlrdobem##3,
               vlrdobem##4,
               vlrdobem##5,
               vlrdobem##6,
               vlrenmes,
               vledvmto,
               dtadmsoc,
               persocio,
               flgdepec,
               vloutren,
               dsoutren,
               inhabmen,
               dthabmen,
               inpessoa,
               dtdrisco,
               qtopescr,
               qtifoper,
               vltotsfn,
               vlopescr,
               vlprejuz,
               idmsgvct)
             VALUES
              (pr_nrdconta_dst,
               DECODE(pr_inpessoa_org, 1,
                         pr_idseqttl_dst, rw_crapavt.nrctremp),
               rw_crapavt.nrcpfcgc,
               rw_crapass_2.nmprimtl,
               nvl(rw_crapcje.nrcpfcjg,0),
               nvl(rw_crapcje.nmconjug,' '),
               nvl(rw_crapcje.tpdoccje,' '),
               nvl(rw_crapcje.nrdoccje,' '),
               rw_crapass_2.tpdocptl,
               rw_crapass_2.nrdocptl,
               rw_crapenc.dsendere,
               rw_crapavt.dsendres##2,
               substr(nvl(to_char(rw_craptfc.nrtelefo),' '),1,26),
               nvl(rw_crapcem.dsdemail,' '),
               rw_crapavt.tpctrato,
               rw_crapenc.nrcepend,
               rw_crapenc.nmcidade,
               rw_crapenc.cdufende,
               rw_crapavt.dtmvtolt,
               pr_cdcooper_dst,
               rw_crapass_2.cdnacion,
               rw_crapenc.nrendere,
               substr(rw_crapenc.complend,1,47),
               rw_crapenc.nmbairro,
               rw_crapavt.nrcxapst,
               substr(nvl(to_char(rw_craptfc.nrtelefo),' '),1,20),
               rw_crapavt.nmextemp,
               rw_crapavt.cddbanco,
               rw_crapavt.cdagenci,
               rw_crapavt.dsproftl,
               0,
               rw_crapass_2.idorgexp,
               rw_crapass_2.dtemdptl,
               rw_crapass_2.cdufdptl,
               rw_crapavt.dtvalida,
               substr(rw_crapass_2.nmmaettl,1,42),
               substr(rw_crapass_2.nmpaittl,1,42),
               rw_crapass_2.dtnasctl,
               rw_crapass_2.dsnatura,
               rw_crapass_2.cdsexotl,
               rw_crapass_2.cdestcvl,
               rw_crapavt.flgimpri,
               vr_bem(1).dsrelbem,
               vr_bem(2).dsrelbem,
               vr_bem(3).dsrelbem,
               vr_bem(4).dsrelbem,
               vr_bem(5).dsrelbem,
               vr_bem(6).dsrelbem,
               vr_bem(1).persemon,
               vr_bem(2).persemon,
               vr_bem(3).persemon,
               vr_bem(4).persemon,
               vr_bem(5).persemon,
               vr_bem(6).persemon,
               vr_bem(1).qtprebem,
               vr_bem(2).qtprebem,
               vr_bem(3).qtprebem,
               vr_bem(4).qtprebem,
               vr_bem(5).qtprebem,
               vr_bem(6).qtprebem,
               vr_bem(1).vlprebem,
               vr_bem(2).vlprebem,
               vr_bem(3).vlprebem,
               vr_bem(4).vlprebem,
               vr_bem(5).vlprebem,
               vr_bem(6).vlprebem,
               vr_bem(1).vlrdobem,
               vr_bem(2).vlrdobem,
               vr_bem(3).vlrdobem,
               vr_bem(4).vlrdobem,
               vr_bem(5).vlrdobem,
               vr_bem(6).vlrdobem,
               rw_crapavt.vlrenmes,
               rw_crapavt.vledvmto,
               rw_crapavt.dtadmsoc,
               rw_crapavt.persocio,
               rw_crapavt.flgdepec,
               rw_crapavt.vloutren,
               rw_crapavt.dsoutren,
               rw_crapass_2.inhabmen,
               rw_crapass_2.dthabmen,
               rw_crapavt.inpessoa,
               rw_crapavt.dtdrisco,
               rw_crapavt.qtopescr,
               rw_crapavt.qtifoper,
               rw_crapavt.vltotsfn,
               rw_crapavt.vlopescr,
               rw_crapavt.vlprejuz,
               rw_crapavt.idmsgvct);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir na CRAPAVT-4: '||SQLERRM;
              RAISE vr_exc_erro;
          END;      
          
        END IF;
        CLOSE cr_crapass;
        
      END LOOP;
    END IF;
          
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_insere_crapavt: '||SQLERRM;          
  END;
      
  -- Insere as tabelas auxiliares
  PROCEDURE pc_insere_auxiliares(pr_cdcooper_org crapass.cdcooper%TYPE,
                                 pr_nrdconta_org crapass.nrdconta%TYPE,
                                 pr_idseqttl_org crapttl.idseqttl%TYPE,
                                 pr_cdcooper_dst crapass.cdcooper%TYPE,
                                 pr_nrdconta_dst crapass.nrdconta%TYPE,
                                 pr_idseqttl_dst crapttl.idseqttl%TYPE,
                                 pr_dscritic OUT VARCHAR2) IS
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic   VARCHAR2(1000);
    vr_exc_erro   EXCEPTION;     
  BEGIN
        
    -- Insere endereco
    BEGIN
        INSERT INTO crapenc
          (cdcooper,
           nrdconta,
           idseqttl,
           cdseqinc,
           tpendass,
           dsendere,
           nrendere,
           complend,
           nmbairro,
           nmcidade,
           cdufende,
           nrcepend,
           incasprp,
           dtinires,
           vlalugue,
           nrcxapst,
           nranores,
           dtaltenc,
           nrdoapto,
           cddbloco,
           idorigem)
        SELECT pr_cdcooper_dst,
               pr_nrdconta_dst,
               pr_idseqttl_dst,
               cdseqinc,
               tpendass,
               dsendere,
               nrendere,
               complend,
               nmbairro,
               nmcidade,
               cdufende,
               nrcepend,
               incasprp,
               dtinires,
               vlalugue,
               nrcxapst,
               nranores,
               dtaltenc,
               nrdoapto,
               cddbloco,
               idorigem
          FROM crapenc
         WHERE cdcooper = pr_cdcooper_org
           AND nrdconta = pr_nrdconta_org
           AND idseqttl = pr_idseqttl_org;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPENC: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      -- Insere informacoes financeiras
      BEGIN
        INSERT INTO crapjfn
          (cdcooper,
           nrdconta,
           mesftbru##1,
           mesftbru##2,
           mesftbru##3,
           mesftbru##4,
           mesftbru##5,
           mesftbru##6,
           mesftbru##7,
           mesftbru##8,
           mesftbru##9,
           mesftbru##10,
           mesftbru##11,
           mesftbru##12,
           anoftbru##1,
           anoftbru##2,
           anoftbru##3,
           anoftbru##4,
           anoftbru##5,
           anoftbru##6,
           anoftbru##7,
           anoftbru##8,
           anoftbru##9,
           anoftbru##10,
           anoftbru##11,
           anoftbru##12,
           vlrftbru##1,
           vlrftbru##2,
           vlrftbru##3,
           vlrftbru##4,
           vlrftbru##5,
           vlrftbru##6,
           vlrftbru##7,
           vlrftbru##8,
           vlrftbru##9,
           vlrftbru##10,
           vlrftbru##11,
           vlrftbru##12,
           vlrctbru,
           vlctdpad,
           vldspfin,
           ddprzrec,
           ddprzpag,
           vlcxbcaf,
           vlctarcb,
           vlrestoq,
           vloutatv,
           vlrimobi,
           vlfornec,
           vloutpas,
           vldivbco,
           cddbanco##1,
           cddbanco##2,
           cddbanco##3,
           cddbanco##4,
           cddbanco##5,
           dstipope##1,
           dstipope##2,
           dstipope##3,
           dstipope##4,
           dstipope##5,
           vlropera##1,
           vlropera##2,
           vlropera##3,
           vlropera##4,
           vlropera##5,
           garantia##1,
           garantia##2,
           garantia##3,
           garantia##4,
           garantia##5,
           dsvencto##1,
           dsvencto##2,
           dsvencto##3,
           dsvencto##4,
           dsvencto##5,
           dtaltjfn##1,
           dtaltjfn##2,
           dtaltjfn##3,
           dtaltjfn##4,
           dtaltjfn##5,
           cdopejfn##1,
           cdopejfn##2,
           cdopejfn##3,
           cdopejfn##4,
           cdopejfn##5,
           mesdbase,
           anodbase,
           dsinfadi##1,
           dsinfadi##2,
           dsinfadi##3,
           dsinfadi##4,
           dsinfadi##5,
           perfatcl)
         SELECT pr_cdcooper_dst,
                pr_nrdconta_dst,
                mesftbru##1,
                mesftbru##2,
                mesftbru##3,
                mesftbru##4,
                mesftbru##5,
                mesftbru##6,
                mesftbru##7,
                mesftbru##8,
                mesftbru##9,
                mesftbru##10,
                mesftbru##11,
                mesftbru##12,
                anoftbru##1,
                anoftbru##2,
                anoftbru##3,
                anoftbru##4,
                anoftbru##5,
                anoftbru##6,
                anoftbru##7,
                anoftbru##8,
                anoftbru##9,
                anoftbru##10,
                anoftbru##11,
                anoftbru##12,
                vlrftbru##1,
                vlrftbru##2,
                vlrftbru##3,
                vlrftbru##4,
                vlrftbru##5,
                vlrftbru##6,
                vlrftbru##7,
                vlrftbru##8,
                vlrftbru##9,
                vlrftbru##10,
                vlrftbru##11,
                vlrftbru##12,
                vlrctbru,
                vlctdpad,
                vldspfin,
                ddprzrec,
                ddprzpag,
                vlcxbcaf,
                vlctarcb,
                vlrestoq,
                vloutatv,
                vlrimobi,
                vlfornec,
                vloutpas,
                vldivbco,
                cddbanco##1,
                cddbanco##2,
                cddbanco##3,
                cddbanco##4,
                cddbanco##5,
                dstipope##1,
                dstipope##2,
                dstipope##3,
                dstipope##4,
                dstipope##5,
                vlropera##1,
                vlropera##2,
                vlropera##3,
                vlropera##4,
                vlropera##5,
                garantia##1,
                garantia##2,
                garantia##3,
                garantia##4,
                garantia##5,
                dsvencto##1,
                dsvencto##2,
                dsvencto##3,
                dsvencto##4,
                dsvencto##5,
                dtaltjfn##1,
                dtaltjfn##2,
                dtaltjfn##3,
                dtaltjfn##4,
                dtaltjfn##5,
                cdopejfn##1,
                cdopejfn##2,
                cdopejfn##3,
                cdopejfn##4,
                cdopejfn##5,
                mesdbase,
                anodbase,
                dsinfadi##1,
                dsinfadi##2,
                dsinfadi##3,
                dsinfadi##4,
                dsinfadi##5,
                perfatcl
           FROM crapjfn
          WHERE cdcooper = pr_cdcooper_org
            AND nrdconta = pr_nrdconta_org;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPJFN: '||SQLERRM;
          RAISE vr_exc_erro;
      END;

/*      -- Cria o responsavel legal
      BEGIN
        INSERT INTO crapcrl
          (cdcooper,
           nrctamen,
           nrcpfmen,
           idseqmen,
           nrdconta,
           nrcpfcgc,
           nmrespon,
           idorgexp,
           cdufiden,
           dtemiden,
           dtnascin,
           cddosexo,
           cdestciv,
           cdnacion,
           dsnatura,
           cdcepres,
           dsendres,
           nrendres,
           dscomres,
           dsbaires,
           nrcxpost,
           dscidres,
           dsdufres,
           nmpairsp,
           nmmaersp,
           tpdeiden,
           nridenti,
           dtmvtolt,
           flgimpri,
           cdrlcrsp)
        SELECT pr_cdcooper_dst,
               pr_nrdconta_dst,
               nrcpfmen,
               pr_idseqttl_dst,
               nrdconta,
               nrcpfcgc,
               nmrespon,
               idorgexp,
               cdufiden,
               dtemiden,
               dtnascin,
               cddosexo,
               cdestciv,
               cdnacion,
               dsnatura,
               cdcepres,
               dsendres,
               nrendres,
               dscomres,
               dsbaires,
               nrcxpost,
               dscidres,
               dsdufres,
               nmpairsp,
               nmmaersp,
               tpdeiden,
               nridenti,
               dtmvtolt,
               flgimpri,
               cdrlcrsp
          FROM crapcrl
         WHERE cdcooper = pr_cdcooper_org
           AND nrctamen = pr_nrdconta_org
           AND idseqmen = pr_idseqttl_org;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPCLR: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
*/
      -- Cria os dependentes
      BEGIN
        INSERT INTO crapdep
          (cdcooper,
           nrdconta,
           idseqdep,
           nmdepend,
           dtnascto,
           tpdepend)
         SELECT pr_cdcooper_dst,
                pr_nrdconta_dst,
                pr_idseqttl_dst,
                nmdepend,
                dtnascto,
                tpdepend
           FROM crapdep
          WHERE cdcooper = pr_cdcooper_org
            AND nrdconta = pr_nrdconta_org
            AND idseqdep = pr_idseqttl_org;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPDEP: '||SQLERRM;
          RAISE vr_exc_erro;
      END;

      -- Insere os telefones
      BEGIN
        INSERT INTO craptfc
          (cdcooper,
           nrdconta,
           idseqttl,
           cdseqtfc,
           cdopetfn,
           nrdddtfc,
           tptelefo,
           nmpescto,
           prgqfalt,
           nrtelefo,
           nrdramal,
           secpscto,
           idsittfc,
           idorigem,
           flgacsms)
         SELECT pr_cdcooper_dst,
                pr_nrdconta_dst,
                pr_idseqttl_dst,
                cdseqtfc,
                cdopetfn,
                nrdddtfc,
                tptelefo,
                nmpescto,
                'A',
                nrtelefo,
                nrdramal,
                secpscto,
                idsittfc,
                idorigem,
                flgacsms
           FROM craptfc
          WHERE cdcooper = pr_cdcooper_org
            AND nrdconta = pr_nrdconta_org
            AND idseqttl = pr_idseqttl_org;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPTFC: '||SQLERRM;
          RAISE vr_exc_erro;
      END;

      -- Insere os emails
      BEGIN
        INSERT INTO crapcem
          (nrdconta,
           dsdemail,
           cddemail,
           dtmvtolt,
           hrtransa,
           cdcooper,
           idseqttl,
           prgqfalt,
           nmpescto,
           secpscto)
         SELECT pr_nrdconta_dst,
                dsdemail,
                cddemail,
                dtmvtolt,
                to_char(SYSDATE,'sssss'),
                pr_cdcooper_dst,
                pr_idseqttl_dst,
                prgqfalt,
                nmpescto,
                secpscto
           FROM crapcem
          WHERE cdcooper = pr_cdcooper_org
            AND nrdconta = pr_nrdconta_org
            AND idseqttl = pr_idseqttl_org;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPCEM: '||SQLERRM;
          RAISE vr_exc_erro;
      END;

      -- Insere os bens
      BEGIN
        INSERT INTO crapbem
          (cdcooper,
           nrdconta,
           idseqttl,
           dtmvtolt,
           cdoperad,
           dtaltbem,
           idseqbem,
           dsrelbem,
           persemon,
           qtprebem,
           vlrdobem,
           vlprebem)
         SELECT pr_cdcooper_dst,
                pr_nrdconta_dst,
                pr_idseqttl_dst,
                dtmvtolt,
                '1',
                dtaltbem,
                idseqbem,
                dsrelbem,
                persemon,
                qtprebem,
                vlrdobem,
                vlprebem
           FROM crapbem
          WHERE cdcooper = pr_cdcooper_org
            AND nrdconta = pr_nrdconta_org
            AND idseqttl = pr_idseqttl_org;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPBEM: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_insere_auxiliares: '||SQLERRM;          
  END;
  
  -- Atualiza os dados na CRAPJUR
  PROCEDURE pc_atualiza_crapjur(pr_nrcpfcgc IN crapttl.nrcpfcgc%TYPE,
                                pr_nmextttl IN crapjur.nmextttl%TYPE,
                                pr_dtatutel IN crapjur.dtatutel%TYPE,
                                pr_nmfansia IN crapjur.nmfansia%TYPE,
                                pr_nrinsest IN crapjur.nrinsest%TYPE,
                                pr_natjurid IN crapjur.natjurid%TYPE,
                                pr_dtiniatv IN crapjur.dtiniatv%TYPE,
                                pr_qtfilial IN crapjur.qtfilial%TYPE,
                                pr_qtfuncio IN crapjur.qtfuncio%TYPE,
                                pr_vlcaprea IN crapjur.vlcaprea%TYPE,
                                pr_dtregemp IN crapjur.dtregemp%TYPE,
                                pr_nrregemp IN crapjur.nrregemp%TYPE,
                                pr_orregemp IN crapjur.orregemp%TYPE,
                                pr_dtinsnum IN crapjur.dtinsnum%TYPE,
                                pr_nrcdnire IN crapjur.nrcdnire%TYPE,
                                pr_flgrefis IN crapjur.flgrefis%TYPE,
                                pr_dsendweb IN crapjur.dsendweb%TYPE,
                                pr_nrinsmun IN crapjur.nrinsmun%TYPE,
                                pr_cdseteco IN crapjur.cdseteco%TYPE,
                                pr_vlfatano IN crapjur.vlfatano%TYPE,
                                pr_cdrmativ IN crapjur.cdrmativ%TYPE,
                                pr_nrlicamb IN crapjur.nrlicamb%TYPE,
                                pr_dtvallic IN crapjur.dtvallic%TYPE,
                                pr_dscritic OUT VARCHAR2) IS
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic   VARCHAR2(1000);
    vr_exc_erro   EXCEPTION;     
  BEGIN    
    BEGIN
      UPDATE crapjur a
         SET nmextttl = pr_nmextttl,
             dtatutel = pr_dtatutel,
             nmfansia = pr_nmfansia,
             nrinsest = pr_nrinsest,
             natjurid = pr_natjurid,
             dtiniatv = pr_dtiniatv,
             qtfilial = pr_qtfilial,
             qtfuncio = pr_qtfuncio,
             vlcaprea = pr_vlcaprea,
             dtregemp = pr_dtregemp,
             nrregemp = pr_nrregemp,
             orregemp = pr_orregemp,
             dtinsnum = pr_dtinsnum,
             nrcdnire = pr_nrcdnire,
             flgrefis = pr_flgrefis,
             dsendweb = pr_dsendweb,
             nrinsmun = pr_nrinsmun,
             cdseteco = pr_cdseteco,
             vlfatano = pr_vlfatano,
             cdrmativ = pr_cdrmativ,
             nrlicamb = pr_nrlicamb,
             dtvallic = pr_dtvallic
       WHERE (cdcooper, nrdconta) IN
               (SELECT cdcooper, nrdconta
                  FROM crapass
                 WHERE nrcpfcgc = pr_nrcpfcgc);
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar CRAPJUR: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

    -- Escreve o log da conta principal      
    gene0002.pc_escreve_xml(vr_log,vr_log_aux,' Total atualizados na CRAPJUR: '||SQL%ROWCOUNT||chr(10));
         
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_atualiza_crapjur: '||SQLERRM;          
  END;
  
  -- Atualiza os dads na CRAPTTL
  PROCEDURE pc_atualiza_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE,
                                pr_nrcpfcgc IN crapttl.nrcpfcgc%TYPE,
                                pr_dsnatura IN crapttl.dsnatura%TYPE,
                                pr_cdnacion IN crapttl.cdnacion%TYPE,
                                pr_cdufnatu IN crapttl.cdufnatu%TYPE,
                                pr_nmextttl IN crapttl.nmextttl%TYPE,
                                pr_dtcnscpf IN crapttl.dtcnscpf%TYPE,
                                pr_cdsitcpf IN crapttl.cdsitcpf%TYPE,
                                pr_dtatutel IN crapttl.dtatutel%TYPE,
                                pr_cdsexotl IN crapttl.cdsexotl%TYPE,
                                pr_cdestcvl IN crapttl.cdestcvl%TYPE,
                                pr_dtnasttl IN crapttl.dtnasttl%TYPE,
                                pr_tpnacion IN crapttl.tpnacion%TYPE,
                                pr_tpdocttl IN crapttl.tpdocttl%TYPE,
                                pr_nrdocttl IN crapttl.nrdocttl%TYPE,
                                pr_dtemdttl IN crapttl.dtemdttl%TYPE,
                                pr_idorgexp IN crapttl.idorgexp%TYPE,
                                pr_cdufdttl IN crapttl.cdufdttl%TYPE,
                                pr_inhabmen IN crapttl.inhabmen%TYPE,
                                pr_dthabmen IN crapttl.dthabmen%TYPE,
                                pr_grescola IN crapttl.grescola%TYPE,
                                pr_cdfrmttl IN crapttl.cdfrmttl%TYPE,
                                pr_cdnatopc IN crapttl.cdnatopc%TYPE,
                                pr_dsproftl IN crapttl.dsproftl%TYPE,
                                pr_dsjusren IN crapttl.dsjusren%TYPE,
                                pr_nmpaittl IN crapttl.nmpaittl%TYPE,
                                pr_nmmaettl IN crapttl.nmmaettl%TYPE,
                                pr_tpcttrab IN crapttl.tpcttrab%TYPE,
                                pr_cdnvlcgo IN crapttl.cdnvlcgo%TYPE,
                                pr_dtadmemp IN crapttl.dtadmemp%TYPE,
                                pr_cdocpttl IN crapttl.cdocpttl%TYPE,
                                pr_nrcadast IN crapttl.nrcadast%TYPE,
                                pr_vlsalari IN crapttl.vlsalari%TYPE,
                                pr_cdturnos IN crapttl.cdturnos%TYPE,
                                pr_nmextemp IN crapttl.nmextemp%TYPE,
                                pr_nrcpfemp IN crapttl.nrcpfemp%TYPE,
                                pr_cdempres IN crapttl.cdempres%TYPE,
                                pr_tpdrendi##1 IN crapttl.tpdrendi##1%TYPE,
                                pr_tpdrendi##2 IN crapttl.tpdrendi##2%TYPE,
                                pr_tpdrendi##3 IN crapttl.tpdrendi##3%TYPE,
                                pr_tpdrendi##4 IN crapttl.tpdrendi##4%TYPE,
                                pr_tpdrendi##5 IN crapttl.tpdrendi##5%TYPE,
                                pr_tpdrendi##6 IN crapttl.tpdrendi##6%TYPE,
                                pr_vldrendi##1 IN crapttl.vldrendi##1%TYPE,
                                pr_vldrendi##2 IN crapttl.vldrendi##2%TYPE,
                                pr_vldrendi##3 IN crapttl.vldrendi##3%TYPE,
                                pr_vldrendi##4 IN crapttl.vldrendi##4%TYPE,
                                pr_vldrendi##5 IN crapttl.vldrendi##5%TYPE,
                                pr_vldrendi##6 IN crapttl.vldrendi##6%TYPE,
                                pr_dscritic OUT VARCHAR2) IS

    ---------------> VARIAVEIS <----------------- 
    vr_dscritic   VARCHAR2(1000);
    vr_exc_erro   EXCEPTION;     
  BEGIN    
    BEGIN
      UPDATE crapttl
         SET cdempres = decode(cdcooper,pr_cdcooper, pr_cdempres, cdempres),
             dsnatura = pr_dsnatura,
             cdnacion = pr_cdnacion,
             cdufnatu = pr_cdufnatu,
             nmextttl = pr_nmextttl,
             dtcnscpf = pr_dtcnscpf,
             cdsitcpf = pr_cdsitcpf,
             dtatutel = pr_dtatutel,
             cdsexotl = pr_cdsexotl,
             cdestcvl = pr_cdestcvl,
             dtnasttl = pr_dtnasttl,
             tpnacion = pr_tpnacion,
             tpdocttl = pr_tpdocttl,
             nrdocttl = pr_nrdocttl,
             dtemdttl = pr_dtemdttl,
             idorgexp = pr_idorgexp,
             cdufdttl = pr_cdufdttl,
             inhabmen = pr_inhabmen,
             dthabmen = pr_dthabmen,
             grescola = pr_grescola,
             cdfrmttl = pr_cdfrmttl,
             cdnatopc = pr_cdnatopc,
             dsproftl = pr_dsproftl,
             dsjusren = pr_dsjusren,
             nmpaittl = pr_nmpaittl,
             nmmaettl = pr_nmmaettl,
             tpcttrab = pr_tpcttrab,
             cdnvlcgo = pr_cdnvlcgo,
             dtadmemp = pr_dtadmemp,
             cdocpttl = pr_cdocpttl,
             nrcadast = pr_nrcadast,
             vlsalari = pr_vlsalari,
             cdturnos = pr_cdturnos,
             nmextemp = pr_nmextemp,
             nrcpfemp = pr_nrcpfemp,
             tpdrendi##1 = pr_tpdrendi##1,
             tpdrendi##2 = pr_tpdrendi##2,
             tpdrendi##3 = pr_tpdrendi##3,
             tpdrendi##4 = pr_tpdrendi##4,
             tpdrendi##5 = pr_tpdrendi##5,
             tpdrendi##6 = pr_tpdrendi##6,
             vldrendi##1 = pr_vldrendi##1,
             vldrendi##2 = pr_vldrendi##2,
             vldrendi##3 = pr_vldrendi##3,
             vldrendi##4 = pr_vldrendi##4,
             vldrendi##5 = pr_vldrendi##5,
             vldrendi##6 = pr_vldrendi##6
       WHERE nrcpfcgc = pr_nrcpfcgc;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar CRAPTTL: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

    -- Escreve o log da conta principal      
    gene0002.pc_escreve_xml(vr_log,vr_log_aux,' Total atualizados na CRAPTTL: '||SQL%ROWCOUNT||chr(10));
         
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_atualiza_crapttl: '||SQLERRM;          
  END;
  
  -- Atualiza os conjuges
  PROCEDURE pc_atualiza_crapcje(pr_nrcpfcjg IN crapcje.nrcpfcjg%TYPE,
                                pr_nmconjug in crapcje.nmconjug%TYPE,
                                pr_dtnasccj in crapcje.dtnasccj%TYPE,
                                pr_tpdoccje in crapcje.tpdoccje%TYPE,
                                pr_nrdoccje in crapcje.nrdoccje%TYPE,
                                pr_idorgexp in crapcje.idorgexp%TYPE,
                                pr_cdufdcje in crapcje.cdufdcje%TYPE,
                                pr_dtemdcje in crapcje.dtemdcje%TYPE,
                                pr_grescola in crapcje.grescola%TYPE,
                                pr_cdfrmttl in crapcje.cdfrmttl%TYPE,
                                pr_cdnatopc in crapcje.cdnatopc%TYPE,
                                pr_dsproftl in crapcje.dsproftl%TYPE,
                                pr_cdocpcje in crapcje.cdocpcje%TYPE,
                                pr_tpcttrab in crapcje.tpcttrab%TYPE,
                                pr_cdnvlcgo in crapcje.cdnvlcgo%TYPE,
                                pr_cdturnos in crapcje.cdturnos%TYPE,
                                pr_dtadmemp in crapcje.dtadmemp%TYPE,
                                pr_vlsalari in crapcje.vlsalari%TYPE,
                                pr_nrdocnpj IN crapcje.nrdocnpj%TYPE,
                                pr_nmextemp in crapcje.nmextemp%TYPE,
                                pr_nrfonemp in crapcje.nrfonemp%TYPE,
                                pr_nrramemp in crapcje.nrramemp%TYPE,
                                pr_dscritic OUT VARCHAR2) IS
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic   VARCHAR2(1000);
    vr_exc_erro   EXCEPTION;     
  BEGIN
    BEGIN
      UPDATE crapcje a
         SET nmconjug = pr_nmconjug,
             dtnasccj = pr_dtnasccj,
             tpdoccje = pr_tpdoccje,
             nrdoccje = pr_nrdoccje,
             idorgexp = pr_idorgexp,
             cdufdcje = pr_cdufdcje,
             dtemdcje = pr_dtemdcje,
             grescola = pr_grescola,
             cdfrmttl = pr_cdfrmttl,
             cdnatopc = pr_cdnatopc,
             dsproftl = pr_dsproftl,
             cdocpcje = pr_cdocpcje,
             tpcttrab = pr_tpcttrab,
             cdnvlcgo = pr_cdnvlcgo,
             cdturnos = pr_cdturnos,
             dtadmemp = pr_dtadmemp,
             vlsalari = pr_vlsalari,
             nrdocnpj = pr_nrdocnpj,
             nmextemp = pr_nmextemp,
             nrfonemp = pr_nrfonemp,
             nrramemp = pr_nrramemp
       WHERE nrcpfcjg = pr_nrcpfcjg
         AND nrctacje = 0
         AND pr_nrcpfcjg <> 0;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar CRAPCJE: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    -- Escreve o log da conta principal      
    gene0002.pc_escreve_xml(vr_log,vr_log_aux,' Total atualizados na CRAPCJE: '||SQL%ROWCOUNT||chr(10));
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_atualiza_crapcje: '||SQLERRM;          
  END;

  PROCEDURE pc_atualiza_crapcje_crapvt(pr_nrcpfcjg IN crapcje.nrcpfcjg%TYPE,
                                       pr_nmconjug IN crapcje.nmconjug%TYPE,
                                       pr_dtnasccj IN crapcje.dtnasccj%TYPE,
                                       pr_tpdoccje IN crapcje.tpdoccje%TYPE,
                                       pr_nrdoccje IN crapcje.nrdoccje%TYPE,
                                       pr_idorgexp IN crapcje.idorgexp%TYPE,
                                       pr_cdufdcje IN crapcje.cdufdcje%TYPE,
                                       pr_dtemdcje IN crapcje.dtemdcje%TYPE,
                                       pr_dscritic OUT VARCHAR2) IS

    ---------------> VARIAVEIS <----------------- 
    vr_dscritic   VARCHAR2(1000);
    vr_exc_erro   EXCEPTION;     
  BEGIN
    BEGIN
      UPDATE crapcje a
         SET nmconjug = pr_nmconjug,
             dtnasccj = pr_dtnasccj,
             tpdoccje = pr_tpdoccje,
             nrdoccje = pr_nrdoccje,
             idorgexp = pr_idorgexp,
             cdufdcje = pr_cdufdcje,
             dtemdcje = pr_dtemdcje
       WHERE nrcpfcjg = pr_nrcpfcjg
         AND nrctacje = 0
         AND pr_nrcpfcjg <> 0;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar CRAPCJE-2: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_atualiza_crapcje_crapavt: '||SQLERRM;          
  END;

  -- Atualiza os representantes e avalistas terceiros
  PROCEDURE pc_atualiza_crapavt(pr_nrcpfcgc    IN crapavt.nrcpfcgc%TYPE,
                                pr_nmdavali    IN crapavt.nmdavali%TYPE,
                                pr_tpdocava    IN crapavt.tpdocava%TYPE,
                                pr_nrdocava    IN crapavt.nrdocava%TYPE,
                                pr_idorgexp    IN crapavt.idorgexp%TYPE,
                                pr_dtemddoc    IN crapavt.dtemddoc%TYPE,
                                pr_cdufddoc    IN crapavt.cdufddoc%TYPE,
                                pr_dtnascto    IN crapavt.dtnascto%TYPE,
                                pr_cdsexcto    IN crapavt.cdsexcto%TYPE,
                                pr_cdestcvl    IN crapavt.cdestcvl%TYPE,
                                pr_inhabmen    IN crapavt.inhabmen%TYPE,
                                pr_dthabmen    IN crapavt.dthabmen%TYPE,
                                pr_cdnacion    IN crapavt.cdnacion%TYPE,
                                pr_dsnatura    IN crapavt.dsnatura%TYPE,
                                pr_nmpaicto    IN crapavt.nmpaicto%TYPE,
                                pr_nmmaecto    IN crapavt.nmmaecto%TYPE,
                                pr_nrcepend    IN crapavt.nrcepend%TYPE,
                                pr_dsendres##1 IN crapavt.dsendres##1%TYPE,
                                pr_nrendere    IN crapavt.nrendere%TYPE,
                                pr_complend    IN crapavt.complend%TYPE,
                                pr_nmbairro    IN crapavt.nmbairro%TYPE,
                                pr_nmcidade    IN crapavt.nmcidade%TYPE,
                                pr_cdufresd    IN crapavt.cdufresd%TYPE,
                                pr_dsrelbem##1 IN crapavt.dsrelbem##1%TYPE,
                                pr_persemon##1 IN crapavt.persemon##1%TYPE,
                                pr_qtprebem##1 IN crapavt.qtprebem##1%TYPE,
                                pr_vlrdobem##1 IN crapavt.vlrdobem##1%TYPE,
                                pr_vlprebem##1 IN crapavt.vlprebem##1%TYPE,
                                pr_dsrelbem##2 IN crapavt.dsrelbem##2%TYPE,
                                pr_persemon##2 IN crapavt.persemon##2%TYPE,
                                pr_qtprebem##2 IN crapavt.qtprebem##2%TYPE,
                                pr_vlrdobem##2 IN crapavt.vlrdobem##2%TYPE,
                                pr_vlprebem##2 IN crapavt.vlprebem##2%TYPE,
                                pr_dsrelbem##3 IN crapavt.dsrelbem##3%TYPE,
                                pr_persemon##3 IN crapavt.persemon##3%TYPE,
                                pr_qtprebem##3 IN crapavt.qtprebem##3%TYPE,
                                pr_vlrdobem##3 IN crapavt.vlrdobem##3%TYPE,
                                pr_vlprebem##3 IN crapavt.vlprebem##3%TYPE,
                                pr_dsrelbem##4 IN crapavt.dsrelbem##4%TYPE,
                                pr_persemon##4 IN crapavt.persemon##4%TYPE,
                                pr_qtprebem##4 IN crapavt.qtprebem##4%TYPE,
                                pr_vlrdobem##4 IN crapavt.vlrdobem##4%TYPE,
                                pr_vlprebem##4 IN crapavt.vlprebem##4%TYPE,
                                pr_dsrelbem##5 IN crapavt.dsrelbem##5%TYPE,
                                pr_persemon##5 IN crapavt.persemon##5%TYPE,
                                pr_qtprebem##5 IN crapavt.qtprebem##5%TYPE,
                                pr_vlrdobem##5 IN crapavt.vlrdobem##5%TYPE,
                                pr_vlprebem##5 IN crapavt.vlprebem##5%TYPE,
                                pr_dsrelbem##6 IN crapavt.dsrelbem##6%TYPE,
                                pr_persemon##6 IN crapavt.persemon##6%TYPE,
                                pr_qtprebem##6 IN crapavt.qtprebem##6%TYPE,
                                pr_vlrdobem##6 IN crapavt.vlrdobem##6%TYPE,
                                pr_vlprebem##6 IN crapavt.vlprebem##6%TYPE,
                                pr_dscritic   OUT VARCHAR2) IS
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic   VARCHAR2(1000);
    vr_exc_erro   EXCEPTION;     
  BEGIN
    BEGIN
      UPDATE crapavt a
         SET nmdavali = pr_nmdavali,
             tpdocava = pr_tpdocava,
             nrdocava = pr_nrdocava,
             idorgexp = pr_idorgexp,
             dtemddoc = pr_dtemddoc,
             cdufddoc = pr_cdufddoc,
             dtnascto = pr_dtnascto,
             cdsexcto = pr_cdsexcto,
             cdestcvl = pr_cdestcvl,
             inhabmen = pr_inhabmen,
             dthabmen = pr_dthabmen,
             cdnacion = pr_cdnacion,
             dsnatura = pr_dsnatura,
             nmpaicto = substr(pr_nmpaicto,1,42),
             nmmaecto = substr(pr_nmmaecto,1,42),
             nrcepend = pr_nrcepend,
             dsendres##1 = pr_dsendres##1,
             nrendere = pr_nrendere,
             complend = pr_complend,
             nmbairro = pr_nmbairro,
             nmcidade = pr_nmcidade,
             cdufresd = pr_cdufresd,
             dsrelbem##1 = pr_dsrelbem##1,
             persemon##1 = pr_persemon##1,
             qtprebem##1 = pr_qtprebem##1,
             vlrdobem##1 = pr_vlrdobem##1,
             vlprebem##1 = pr_vlprebem##1,
             dsrelbem##2 = pr_dsrelbem##2,
             persemon##2 = pr_persemon##2,
             qtprebem##2 = pr_qtprebem##2,
             vlrdobem##2 = pr_vlrdobem##2,
             vlprebem##2 = pr_vlprebem##2,
             dsrelbem##3 = pr_dsrelbem##3,
             persemon##3 = pr_persemon##3,
             qtprebem##3 = pr_qtprebem##3,
             vlrdobem##3 = pr_vlrdobem##3,
             vlprebem##3 = pr_vlprebem##3,
             dsrelbem##4 = pr_dsrelbem##4,
             persemon##4 = pr_persemon##4,
             qtprebem##4 = pr_qtprebem##4,
             vlrdobem##4 = pr_vlrdobem##4,
             vlprebem##4 = pr_vlprebem##4,
             dsrelbem##5 = pr_dsrelbem##5,
             persemon##5 = pr_persemon##5,
             qtprebem##5 = pr_qtprebem##5,
             vlrdobem##5 = pr_vlrdobem##5,
             vlprebem##5 = pr_vlprebem##5,
             dsrelbem##6 = pr_dsrelbem##6,
             persemon##6 = pr_persemon##6,
             qtprebem##6 = pr_qtprebem##6,
             vlrdobem##6 = pr_vlrdobem##6,
             vlprebem##6 = pr_vlprebem##6
       WHERE nrcpfcgc = pr_nrcpfcgc
         AND a.nrdctato = 0
         AND tpctrato IN (1,  -- Avalistas terceiros
                          6); -- Representante legal
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar CRAPAVT: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    -- Exclui o avalista e representante da tabela de priorizacao, pois ele ja foi atualizado
    IF vr_conta.exists(lpad(pr_nrcpfcgc,15,'0')) THEN
      IF vr_conta(lpad(pr_nrcpfcgc,15,'0')).tptabela = 2 THEN
        vr_conta.delete(lpad(pr_nrcpfcgc,15,'0'));
      END IF;
    END IF;
    
    -- Escreve o log da conta principal      
    gene0002.pc_escreve_xml(vr_log,vr_log_aux,' Total atualizados na CRAPAVT: '||SQL%ROWCOUNT||chr(10));
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_atualiza_crapavt: '||SQLERRM;          
  END;

  -- Atualiza os responsaveis legais
  PROCEDURE pc_atualiza_crapcrl(pr_nrcpfcgc IN crapcrl.nrcpfcgc%TYPE,
                                pr_nmrespon IN crapcrl.nmrespon%TYPE,
                                pr_idorgexp IN crapcrl.idorgexp%TYPE,
                                pr_cdufiden IN crapcrl.cdufiden%TYPE,
                                pr_dtemiden IN crapcrl.dtemiden%TYPE,
                                pr_dtnascin IN crapcrl.dtnascin%TYPE,
                                pr_cddosexo IN crapcrl.cddosexo%TYPE,
                                pr_cdestciv IN crapcrl.cdestciv%TYPE,
                                pr_nridenti IN crapcrl.nridenti%TYPE,
                                pr_tpdeiden IN crapcrl.tpdeiden%TYPE,
                                pr_cdnacion IN crapcrl.cdnacion%TYPE,
                                pr_dsnatura IN crapcrl.dsnatura%TYPE,
                                pr_nmpairsp IN crapcrl.nmpairsp%TYPE,
                                pr_nmmaersp IN crapcrl.nmmaersp%TYPE,
                                pr_cdcepres IN crapcrl.cdcepres%TYPE,
                                pr_dsendres IN crapcrl.dsendres%TYPE,
                                pr_nrendres IN crapcrl.nrendres%TYPE,
                                pr_dscomres IN crapcrl.dscomres%TYPE,
                                pr_dsbaires IN crapcrl.dsbaires%TYPE,
                                pr_dscidres IN crapcrl.dscidres%TYPE,
                                pr_dsdufres IN crapcrl.dsdufres%TYPE,
                                pr_dscritic OUT VARCHAR2) IS
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic   VARCHAR2(1000);
    vr_exc_erro   EXCEPTION; 
    
  BEGIN
    -- Atualiza os responsaveis legais
    BEGIN
      UPDATE /*+ index (a CRAPCRL##CRAPCRL1) */
             crapcrl a
         SET nmrespon = substr(pr_nmrespon,1,40),
             idorgexp = pr_idorgexp,
             cdufiden = pr_cdufiden,
             dtemiden = pr_dtemiden,
             dtnascin = pr_dtnascin,
             cddosexo = pr_cddosexo,
             cdestciv = pr_cdestciv,
             nridenti = pr_nridenti,
             tpdeiden = pr_tpdeiden,
             cdnacion = pr_cdnacion,
             dsnatura = pr_dsnatura,
             nmpairsp = pr_nmpairsp,
             nmmaersp = pr_nmmaersp,
             cdcepres = pr_cdcepres,
             dsendres = pr_dsendres,
             nrendres = pr_nrendres,
             dscomres = substr(pr_dscomres,1,40),
             dsbaires = pr_dsbaires,
             dscidres = pr_dscidres,
             dsdufres = pr_dsdufres
       WHERE a.nrdconta = 0
         AND a.nrcpfcgc = pr_nrcpfcgc;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar CRAPCRL: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

    -- Escreve o log da conta principal      
    gene0002.pc_escreve_xml(vr_log,vr_log_aux,' Total atualizados na CRAPCRL: '||SQL%ROWCOUNT||chr(10));

  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_atualiza_crapcrl: '||SQLERRM;          
  END;

  -- Atualizar a tabela de associados
  PROCEDURE pc_atualiza_crapass(pr_nrcpfcgc crapass.nrcpfcgc%TYPE,
                                pr_nmprimtl crapass.nmprimtl%TYPE,
                                pr_dtnasctl crapass.dtnasctl%TYPE,
                                pr_cdnacion crapass.cdnacion%TYPE,
                                pr_dsproftl crapass.dsproftl%TYPE,
                                pr_tpdocptl crapass.tpdocptl%TYPE,
                                pr_nrdocptl crapass.nrdocptl%TYPE,
                                pr_dsfiliac crapass.dsfiliac%TYPE,
                                pr_cdturnos crapass.cdturnos%TYPE,
                                pr_nrramemp crapass.nrramemp%TYPE,
                                pr_dtcnsspc crapass.dtcnsspc%TYPE,
                                pr_idorgexp crapass.idorgexp%TYPE,
                                pr_cdufdptl crapass.cdufdptl%TYPE,
                                pr_dtemdptl crapass.dtemdptl%TYPE,
                                pr_dtcnscpf crapass.dtcnscpf%TYPE,
                                pr_cdsitcpf crapass.cdsitcpf%TYPE,
                                pr_nmpaiptl crapass.nmpaiptl%TYPE,
                                pr_nmmaeptl crapass.nmmaeptl%TYPE,
                                pr_dtcnsscr crapass.dtcnsscr%TYPE,
                                pr_cdclcnae crapass.cdclcnae%TYPE,
                                pr_nmttlrfb crapass.nmttlrfb%TYPE,
                                pr_inconrfb crapass.inconrfb%TYPE,
                                pr_cdsexotl crapass.cdsexotl%TYPE,
                                pr_dtultalt crapass.dtultalt%TYPE,
                                pr_dscritic OUT VARCHAR2) IS
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic   VARCHAR2(1000);
    vr_exc_erro   EXCEPTION; 
  BEGIN
    BEGIN
      UPDATE crapass
         SET nmprimtl = pr_nmprimtl,
             dtnasctl = pr_dtnasctl,
             cdnacion = pr_cdnacion,
             dsproftl = pr_dsproftl,
             tpdocptl = pr_tpdocptl,
             nrdocptl = pr_nrdocptl,
             dsfiliac = pr_dsfiliac,
             cdturnos = pr_cdturnos,
             nrramemp = pr_nrramemp,
             dtcnsspc = pr_dtcnsspc,
             idorgexp = pr_idorgexp,
             cdufdptl = pr_cdufdptl,
             dtemdptl = pr_dtemdptl,
             dtcnscpf = pr_dtcnscpf,
             cdsitcpf = pr_cdsitcpf,
             nmpaiptl = pr_nmpaiptl,
             nmmaeptl = pr_nmmaeptl,
             dtcnsscr = pr_dtcnsscr,
             cdclcnae = pr_cdclcnae,
             nmttlrfb = pr_nmttlrfb,
             inconrfb = pr_inconrfb,
             cdsexotl = pr_cdsexotl,
             dtultalt = pr_dtultalt
       WHERE nrcpfcgc = pr_nrcpfcgc;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar CRAPASS: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

    -- Escreve o log da conta principal      
    gene0002.pc_escreve_xml(vr_log,vr_log_aux,' Total atualizados na CRAPASS: '||SQL%ROWCOUNT||chr(10));
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_atualiza_crapass: '||SQLERRM;          
  END;



  -- Atualizar a tabela de associados
  PROCEDURE pc_atualiza_crapass_basico(pr_nrcpfcgc crapass.nrcpfcgc%TYPE,
                                       pr_nmprimtl crapass.nmprimtl%TYPE,
                                       pr_dtnasctl crapass.dtnasctl%TYPE,
                                       pr_tpdocptl crapass.tpdocptl%TYPE,
                                       pr_nrdocptl crapass.nrdocptl%TYPE,
                                       pr_dsfiliac crapass.dsfiliac%TYPE,
                                       pr_nrramemp crapass.nrramemp%TYPE,
                                       pr_dtcnsspc crapass.dtcnsspc%TYPE,
                                       pr_cdufdptl crapass.cdufdptl%TYPE,
                                       pr_dtemdptl crapass.dtemdptl%TYPE,
                                       pr_dtcnsscr crapass.dtcnsscr%TYPE,
                                       pr_cdclcnae crapass.cdclcnae%TYPE,
                                       pr_nmttlrfb crapass.nmttlrfb%TYPE,
                                       pr_inconrfb crapass.inconrfb%TYPE,
                                       pr_dtultalt crapass.dtultalt%TYPE,
                                       pr_dscritic OUT VARCHAR2) IS
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic   VARCHAR2(1000);
    vr_exc_erro   EXCEPTION; 
  BEGIN
    BEGIN
      UPDATE crapass
         SET nmprimtl = pr_nmprimtl,
             dtnasctl = pr_dtnasctl,
             tpdocptl = pr_tpdocptl,
             nrdocptl = pr_nrdocptl,
             dsfiliac = pr_dsfiliac,
             nrramemp = pr_nrramemp,
             dtcnsspc = pr_dtcnsspc,
             cdufdptl = pr_cdufdptl,
             dtemdptl = pr_dtemdptl,
             dtcnsscr = pr_dtcnsscr,
             cdclcnae = pr_cdclcnae,
             nmttlrfb = pr_nmttlrfb,
             inconrfb = pr_inconrfb,
             dtultalt = pr_dtultalt
       WHERE nrcpfcgc = pr_nrcpfcgc;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar CRAPASS_2: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

    -- Escreve o log da conta principal      
    gene0002.pc_escreve_xml(vr_log,vr_log_aux,' Total atualizados na CRAPASS Dados Basicos: '||SQL%ROWCOUNT||chr(10));
    
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_atualiza_crapass_basico: '||SQLERRM;          
  END;

  /*****************************************************************************/
  /**            Procedure para priorizar as contas que serao saneadas        **/
  /*****************************************************************************/
  PROCEDURE pc_prioriza_dados(pr_conta    OUT typ_tab_conta,
                              pr_dscritic OUT VARCHAR2) IS
    -- Cursor sobre as contas PF
    CURSOR cr_crapass_01 IS
      SELECT b.*
        FROM (SELECT cdcooper,
                     nrdconta,
                     MAX(dtaltera) dtaltera
                FROM crapalt   
               WHERE tpaltera = 1
               GROUP BY cdcooper,
                     nrdconta) d, -- Tabela com as revisoes cadastrais
             crapcop c,
             crapttl b,
             crapass a
       WHERE b.cdcooper = a.cdcooper
         AND nvl(b.nrcpfcgc,0) <> 0
         AND b.nrdconta = a.nrdconta
         AND c.cdcooper = a.cdcooper
         AND c.flgativo = 1
         AND d.cdcooper (+) = b.cdcooper
         AND d.nrdconta (+) = b.nrdconta
--         AND a.cdcooper = 16 -- Andrino
--         AND b.nrcpfcgc = 00084257000179 
       ORDER BY decode(a.dtdemiss,NULL,0,1),
                decode(b.idseqttl,1,0,1),
                nvl(d.dtaltera,a.dtadmiss) DESC;

    -- Cursor sobre as contas PJ
    CURSOR cr_crapass_02 IS
      SELECT a.*
        FROM (SELECT cdcooper,
                     nrdconta,
                     MAX(dtaltera) dtaltera
                FROM crapalt   
               WHERE tpaltera = 1
               GROUP BY cdcooper,
                     nrdconta) d, -- Tabela com as revisoes cadastrais
             crapcop c,
             crapass a
       WHERE a.inpessoa <> 1
         AND nvl(a.nrcpfcgc,0) <> 0
         AND c.cdcooper = a.cdcooper
         AND c.flgativo = 1
         AND d.cdcooper (+) = a.cdcooper
         AND d.nrdconta (+) = a.nrdconta
--         AND a.cdcooper = 20 -- Andrino
--         AND a.nrcpfcgc = 00084257000179
       ORDER BY decode(a.dtdemiss,NULL,0,1),
                nvl(d.dtaltera,a.dtadmiss) DESC;

    -- Busca os representantes legais e procuradores
    CURSOR cr_crapavt IS
      SELECT a.cdcooper,
             a.nrdconta,
             a.nrcpfcgc,
             a.rowid
        FROM (SELECT cdcooper,
                     nrdconta,
                     MAX(dtaltera) dtaltera
                FROM crapalt   
               WHERE tpaltera = 1
               GROUP BY cdcooper,
                     nrdconta) d, -- Tabela com as revisoes cadastrais
             crapavt a
       WHERE a.tpctrato = 6
         AND a.nrdctato = 0 -- Nao tenha conta referenciada
         AND nvl(a.nrcpfcgc,0) <> 0
         AND d.cdcooper (+) = a.cdcooper
         AND d.nrdconta (+) = a.nrdconta
--         AND a.cdcooper = 20 -- Andrino
        ORDER BY nvl(d.dtaltera,a.dtmvtolt) DESC;

    -- Busca os fiadores
    CURSOR cr_crapavt_2 IS
      SELECT a.cdcooper,
             a.nrdconta,
             a.nrcpfcgc,
             a.rowid
        FROM crapavt a
       WHERE a.tpctrato = 1 -- Avalista
         AND nvl(a.nrcpfcgc,0) <> 0
         AND a.nrdctato = 0 -- Nao tenha conta referenciada
--         AND a.cdcooper = 20 -- Andrino
        ORDER BY nvl(a.dtmvtolt,SYSDATE-10000) DESC;

    -- Busca os conjuges
    CURSOR cr_crapcje IS
      SELECT a.cdcooper,
             a.nrdconta,
             a.nrcpfcjg,
             a.rowid
        FROM crapcje a
       WHERE nvl(a.nrcpfcjg,0) <> 0
         AND a.nrctacje = 0 -- Nao tenha conta do conjuge
--         AND a.cdcooper = 20 -- Andrino
        ORDER BY a.progress_recid DESC;

    ---------------> VARIAVEIS <----------------- 
    vr_dscritic   VARCHAR2(1000);
    vr_exc_erro   EXCEPTION; 

  BEGIN
    -- Loop sobre as contas PF
    FOR rw_crapass IN cr_crapass_01 LOOP
      -- Se ja nao existe registro para o CPF / CNPJ
      IF NOT pr_conta.exists(lpad(rw_crapass.nrcpfcgc,15,'0')) THEN
        pr_conta(lpad(rw_crapass.nrcpfcgc,15,'0')).cdcooper := rw_crapass.cdcooper;
        pr_conta(lpad(rw_crapass.nrcpfcgc,15,'0')).nrdconta := rw_crapass.nrdconta;
        pr_conta(lpad(rw_crapass.nrcpfcgc,15,'0')).idseqttl := rw_crapass.idseqttl;
        pr_conta(lpad(rw_crapass.nrcpfcgc,15,'0')).inpessoa := 1;
        pr_conta(lpad(rw_crapass.nrcpfcgc,15,'0')).tptabela := 1;
      END IF;
    END LOOP;
    
    -- Loop sobre as contas PJ
    FOR rw_crapass IN cr_crapass_02 LOOP
      -- Se ja nao existe registro para o CPF / CNPJ
      IF NOT pr_conta.exists(lpad(rw_crapass.nrcpfcgc,15,'0')) THEN
        pr_conta(lpad(rw_crapass.nrcpfcgc,15,'0')).cdcooper := rw_crapass.cdcooper;
        pr_conta(lpad(rw_crapass.nrcpfcgc,15,'0')).nrdconta := rw_crapass.nrdconta;
        pr_conta(lpad(rw_crapass.nrcpfcgc,15,'0')).idseqttl := 1;
        pr_conta(lpad(rw_crapass.nrcpfcgc,15,'0')).inpessoa := 2;
        pr_conta(lpad(rw_crapass.nrcpfcgc,15,'0')).tptabela := 1;
      END IF;
    END LOOP;
    
    -- Loop sobre representantes legais e procuradores
    FOR rw_crapavt IN cr_crapavt LOOP
      -- Se ja nao existe registro para o CPF / CNPJ
      IF NOT pr_conta.exists(lpad(rw_crapavt.nrcpfcgc,15,'0')) THEN
        pr_conta(lpad(rw_crapavt.nrcpfcgc,15,'0')).cdcooper := rw_crapavt.cdcooper;
        pr_conta(lpad(rw_crapavt.nrcpfcgc,15,'0')).nrdconta := rw_crapavt.nrdconta;
        pr_conta(lpad(rw_crapavt.nrcpfcgc,15,'0')).tptabela := 2; -- Representantes e procuradores
        pr_conta(lpad(rw_crapavt.nrcpfcgc,15,'0')).pr_rowid := rw_crapavt.rowid;
      END IF;
    END LOOP;
    
    -- Loop sobre avalistas
    FOR rw_crapavt IN cr_crapavt_2 LOOP
      -- Se ja nao existe registro para o CPF / CNPJ
      IF NOT pr_conta.exists(lpad(rw_crapavt.nrcpfcgc,15,'0')) THEN
        pr_conta(lpad(rw_crapavt.nrcpfcgc,15,'0')).cdcooper := rw_crapavt.cdcooper;
        pr_conta(lpad(rw_crapavt.nrcpfcgc,15,'0')).nrdconta := rw_crapavt.nrdconta;
        pr_conta(lpad(rw_crapavt.nrcpfcgc,15,'0')).tptabela := 3; -- Avalistas
        pr_conta(lpad(rw_crapavt.nrcpfcgc,15,'0')).pr_rowid := rw_crapavt.rowid;
      END IF;
    END LOOP;

    -- Loop sobre os cojuges
    FOR rw_crapcje IN cr_crapcje LOOP
      -- Se ja nao existe registro para o CPF / CNPJ
      IF NOT pr_conta.exists(lpad(rw_crapcje.nrcpfcjg,15,'0')) THEN
        pr_conta(lpad(rw_crapcje.nrcpfcjg,15,'0')).cdcooper := rw_crapcje.cdcooper;
        pr_conta(lpad(rw_crapcje.nrcpfcjg,15,'0')).nrdconta := rw_crapcje.nrdconta;
        pr_conta(lpad(rw_crapcje.nrcpfcjg,15,'0')).tptabela := 4; -- Conjuges
        pr_conta(lpad(rw_crapcje.nrcpfcjg,15,'0')).pr_rowid := rw_crapcje.rowid;
      END IF;
    END LOOP;
    
    -- Crapavt com tpctrato igual a 6
    -- crapavt com tpctrato igual a 1
    -- crapccs -- conta salario
    -- crapcje
    -- crapcrl
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_prioriza_dados: '||SQLERRM; 
  END;

  /*****************************************************************************/
  /**            Procedure para execucao do processo                          **/
  /*****************************************************************************/
  PROCEDURE pc_executa_processo(pr_dscritic OUT VARCHAR2) IS
    
    -- Tipo de registro de bem
    TYPE typ_reg_bem IS
        RECORD (dsrelbem crapbem.dsrelbem%TYPE,
                persemon crapbem.persemon%TYPE,
                qtprebem crapbem.qtprebem%TYPE,
                vlrdobem crapbem.vlrdobem%TYPE,
                vlprebem crapbem.vlprebem%TYPE);
    /* Definicao de tabela que compreende os registros acima declarados */
    TYPE typ_tab_bem IS
      TABLE OF typ_reg_bem
      INDEX BY BINARY_INTEGER;
    /* Vetor com as informacoes bem*/
    vr_bem typ_tab_bem;

    -- Cursor para buscar os telefones
    CURSOR cr_craptfc(pr_cdcooper craptfc.cdcooper%TYPE,
                      pr_nrdconta craptfc.nrdconta%TYPE,
                      pr_idseqttl craptfc.idseqttl%TYPE,
                      pr_tptelefo craptfc.tptelefo%TYPE) IS
      SELECT a.nrtelefo,
             a.nrdramal
        FROM craptfc a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.idseqttl = pr_idseqttl
         AND a.tptelefo = pr_tptelefo
         ORDER BY a.idseqttl;
    rw_craptfc cr_craptfc%ROWTYPE;

    -- Cursor para buscar os telefones
    CURSOR cr_crapenc(pr_cdcooper crapenc.cdcooper%TYPE,
                      pr_nrdconta crapenc.nrdconta%TYPE,
                      pr_idseqttl crapenc.idseqttl%TYPE,
                      pr_tpencass crapenc.tpendass%TYPE) IS
      SELECT a.nrcepend,
             a.dsendere,
             a.nrendere,
             a.nmbairro,
             a.nmcidade,
             a.cdufende,
             a.complend
        FROM crapenc a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.idseqttl = pr_idseqttl
         AND a.tpendass = pr_tpencass
         ORDER BY a.idseqttl;
    rw_crapenc cr_crapenc%ROWTYPE;
        
    -- Cursor para busca dos bens
    CURSOR cr_crapbem(pr_cdcooper craptfc.cdcooper%TYPE,
                      pr_nrdconta craptfc.nrdconta%TYPE,
                      pr_idseqttl craptfc.idseqttl%TYPE) IS
      SELECT a.dsrelbem,
             a.persemon,
             a.qtprebem,
             a.vlrdobem,
             a.vlprebem,
             a.idseqbem
        FROM crapbem a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.idseqttl = pr_idseqttl
        ORDER BY a.idseqbem;
          
    
    -- Cursor para buscar as contas PF ativas que possuem mais de uma conta
    CURSOR cr_crapass_01(pr_cdcooper crapttl.cdcooper%TYPE,
                         pr_nrdconta crapttl.nrdconta%TYPE,
                         pr_idseqttl crapttl.idseqttl%TYPE) IS
      SELECT a.cdcooper,
             a.nrdconta,
             a.nmprimtl,
             a.dtnasctl,
             a.tpdocptl,
             a.nrdocptl,
             a.dsfiliac,
             a.nrramemp,
             a.dtcnsspc,
             a.cdufdptl,
             a.dtemdptl,
             a.dtcnsscr,
             a.cdclcnae,
             a.nmttlrfb,
             a.dtultalt,
             a.inconrfb,
             a.inpessoa,
             a.nrcpfcgc nrcpfcgc_crapass,
             b.idseqttl,
             b.nrcpfcgc,
             b.dsnatura,
             b.cdnacion,
             b.cdufnatu,
             b.nmextttl,
             b.dtcnscpf,
             b.cdsitcpf,
             b.dtatutel,
             b.cdsexotl,
             b.cdestcvl,
             b.dtnasttl,
             b.tpnacion,
             b.tpdocttl,
             b.nrdocttl,
             b.dtemdttl,
             b.idorgexp,
             b.cdufdttl,
             b.inhabmen,
             b.dthabmen,
             b.grescola,
             b.cdfrmttl,
             b.cdnatopc,
             b.dsproftl,
             b.dsjusren,
             b.cdocpttl,
             b.tpcttrab,
             b.cdnvlcgo,
             b.cdturnos,
             b.dtadmemp,
             b.vlsalari,
             b.nmextemp,
             b.nmpaittl,
             b.nmmaettl,
             b.nrcadast,
             b.nrcpfemp,
             NULL nmfansia,
             NULL nrinsest,
             NULL natjurid,
             NULL dtiniatv,
             NULL qtfilial,
             NULL qtfuncio,
             NULL vlcaprea,
             NULL dtregemp,
             NULL nrregemp,
             NULL orregemp,
             NULL dtinsnum,
             NULL nrcdnire,
             NULL flgrefis,
             NULL dsendweb,
             NULL nrinsmun,
             NULL cdseteco,
             NULL vlfatano,
             NULL cdrmativ,
             NULL nrlicamb,
             NULL dtvallic,
             decode(a.dtdemiss,NULL,'Ativa','Inativa') situacao,
             b.cdempres,
             b.tpdrendi##1,
             b.tpdrendi##2,
             b.tpdrendi##3,
             b.tpdrendi##4,
             b.tpdrendi##5,
             b.tpdrendi##6,
             b.vldrendi##1,
             b.vldrendi##2,
             b.vldrendi##3,
             b.vldrendi##4,
             b.vldrendi##5,
             b.vldrendi##6
        FROM crapttl b,
             crapass a
       WHERE b.cdcooper = pr_cdcooper
         AND b.nrdconta = pr_nrdconta
         AND b.idseqttl = pr_idseqttl
         AND b.cdcooper = a.cdcooper
         AND b.nrdconta = a.nrdconta
       UNION ALL
      SELECT a.cdcooper,
             a.nrdconta,
             a.nmprimtl,
             a.dtnasctl,
             a.tpdocptl,
             a.nrdocptl,
             a.dsfiliac,
             a.nrramemp,
             a.dtcnsspc,
             a.cdufdptl,
             a.dtemdptl,
             a.dtcnsscr,
             a.cdclcnae,
             a.nmttlrfb,
             a.dtultalt,
             a.inconrfb,
             a.inpessoa,
             a.nrcpfcgc nrcpfcgc_crapass,
             1 idseqttl,
             a.nrcpfcgc,
             ' ' dsnatura,
             a.cdnacion,
             NULL cdufnatu,
             b.nmextttl,
             a.dtcnscpf,
             a.cdsitcpf,
             b.dtatutel,
             a.cdsexotl,
             NULL cdestcvl,
             NULL dtnasttl,
             NULL tpnacion,
             NULL tpdocttl,
             NULL nrdocttl,
             NULL dtemdttl,
             a.idorgexp,
             NULL cdufdttl,
             NULL inhabmen,
             NULL dthabmen,
             NULL grescola,
             NULL cdfrmttl,
             NULL cdnatopc,
             a.dsproftl,
             NULL dsjusren,
             NULL cdocpttl,
             NULL tpcttrab,
             NULL cdnvlcgo,
             a.cdturnos,
             NULL dtadmemp,
             NULL vlsalari,
             NULL nmextemp,
             a.nmpaiptl,
             a.nmmaeptl,
             NULL nrcadast,
             NULL nrcpfemp,
             b.nmfansia,
             b.nrinsest,
             b.natjurid,
             b.dtiniatv,
             b.qtfilial,
             b.qtfuncio,
             b.vlcaprea,
             b.dtregemp,
             b.nrregemp,
             b.orregemp,
             b.dtinsnum,
             b.nrcdnire,
             b.flgrefis,
             b.dsendweb,
             b.nrinsmun,
             b.cdseteco,
             b.vlfatano,
             b.cdrmativ,
             b.nrlicamb,
             b.dtvallic,
             decode(a.dtdemiss,NULL,'Ativa','Inativa') situacao,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL
        FROM crapjur b,
             crapass a
       WHERE b.cdcooper = pr_cdcooper
         AND b.nrdconta = pr_nrdconta
         AND b.cdcooper = a.cdcooper
         AND b.nrdconta = a.nrdconta;
    rw_crapass cr_crapass_01%ROWTYPE;
    
    -- Cursor para buscar todas as contas com o mesmo CPF
    CURSOR cr_crapass_02(pr_inpessoa crapass.inpessoa%TYPE,
                         pr_nrcpfcgc crapttl.nrcpfcgc%TYPE,
                         pr_cdcooper crapttl.cdcooper%TYPE,
                         pr_nrdconta crapttl.nrdconta%TYPE,
                         pr_idseqttl crapttl.idseqttl%TYPE) IS
      SELECT cdcooper,
             nrdconta,
             idseqttl,
             1 inpessoa
        FROM crapttl 
       WHERE nrcpfcgc = pr_nrcpfcgc
         AND NOT (cdcooper = pr_cdcooper
              AND nrdconta = pr_nrdconta
              AND idseqttl = pr_idseqttl)
         AND pr_inpessoa = 1
       UNION ALL
      SELECT cdcooper,
             nrdconta,
             1,
             2
        FROM crapass
       WHERE nrcpfcgc = pr_nrcpfcgc
         AND NOT (cdcooper = pr_cdcooper
              AND nrdconta = pr_nrdconta)
         AND pr_inpessoa <> 1;
  
    -- Cursor sobre os avalistas, representantes e procuradores
    CURSOR cr_crapavt(pr_rowid ROWID) IS
      SELECT *
        FROM crapavt
       WHERE ROWID = pr_rowid;
    rw_crapavt cr_crapavt%ROWTYPE;
         
    CURSOR cr_crapcje(pr_rowid ROWID) IS
      SELECT *
        FROM crapcje
       WHERE ROWID = pr_rowid;
    rw_crapcje cr_crapcje%ROWTYPE;
  
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic   VARCHAR2(1000);
    vr_exc_erro   EXCEPTION; 
    
    vr_conta      typ_tab_conta; --> Tabela que contera as contas
    ind           VARCHAR2(20);  --> Indice das contas. Contera o CPF / CNPJ
    vr_qtprocesso NUMBER(10) := 0; --> Quantidade de registros processados

  BEGIN    

    -- Inicializa o LOG
    vr_log := null;
    DBMS_LOB.createtemporary(vr_log, FALSE);

    -- Inicio do Log
    gene0002.pc_escreve_xml(vr_log,vr_log_aux,'Inicio do processo: '||to_char(SYSDATE,'DD/MM/YYYY HH24:mi:ss')||chr(10));

    -- Busca a priorizacao das contas
    pc_prioriza_dados(pr_conta    => vr_conta,
                      pr_dscritic => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
  
    -- Atualiza o indice para o primeiro registro
    ind := vr_conta.first;
  
    LOOP
      EXIT WHEN NOT vr_conta.exists(ind);
      
      -- Se nao for da tabela de associado
      IF vr_conta(ind).tptabela <> 1 THEN
        -- Vai para o proximo registro
        ind := vr_conta.next(ind);
        -- vai para o inicio do loop
        continue; 
      END IF;
        
      -- Incrementa o total de registros processados
      vr_qtprocesso := vr_qtprocesso + 1;
      
      -- Limpa as variaveis de bens
      vr_bem.delete;
      
      -- Efetuar commit a cada 5000 registros
      IF MOD(vr_qtprocesso,5000) = 0 THEN
        COMMIT;
      END IF;
      
      -- Cursor para buscar os dados da conta PF
      OPEN cr_crapass_01(pr_cdcooper => vr_conta(ind).cdcooper,
                         pr_nrdconta => vr_conta(ind).nrdconta,
                         pr_idseqttl => vr_conta(ind).idseqttl);
      FETCH cr_crapass_01 INTO rw_crapass;
      CLOSE cr_crapass_01;
  
      -- Escreve o log da conta principal      
      gene0002.pc_escreve_xml(vr_log,vr_log_aux,'Conta Principal: '||vr_conta(ind).cdcooper||'-'||vr_conta(ind).nrdconta||'-'||vr_conta(ind).idseqttl||
                                                 ' CPF: '||ind||' Situacao: '|| rw_crapass.situacao || chr(10));

      -- Busca os bens
      FOR rw_crapbem IN cr_crapbem(pr_cdcooper => rw_crapass.cdcooper,
                                   pr_nrdconta => rw_crapass.nrdconta,
                                   pr_idseqttl => rw_crapass.idseqttl) LOOP
        vr_bem(rw_crapbem.idseqbem).dsrelbem := rw_crapbem.dsrelbem;
        vr_bem(rw_crapbem.idseqbem).persemon := rw_crapbem.persemon;
        vr_bem(rw_crapbem.idseqbem).qtprebem := rw_crapbem.qtprebem;
        vr_bem(rw_crapbem.idseqbem).vlrdobem := rw_crapbem.vlrdobem;
        vr_bem(rw_crapbem.idseqbem).vlprebem := rw_crapbem.vlprebem;
      END LOOP;

      -- Loop para iniciar os 6 bens
      FOR x IN 1..6 LOOP
        IF NOT vr_bem.exists(x) THEN
          vr_bem(x).dsrelbem := ' ';
          vr_bem(x).persemon := 0;
          vr_bem(x).qtprebem := 0;
          vr_bem(x).vlrdobem := 0;
          vr_bem(x).vlprebem := 0;
        END IF;
      END LOOP;
        
      -- Busca os telefones
      rw_craptfc := NULL;
      OPEN cr_craptfc(pr_cdcooper => rw_crapass.cdcooper,
                      pr_nrdconta => rw_crapass.nrdconta,
                      pr_idseqttl => rw_crapass.idseqttl,
                      pr_tptelefo => 3); -- Comercial
      FETCH cr_craptfc INTO rw_craptfc;
      CLOSE cr_craptfc;

      -- Busca o endereco
      rw_crapenc := NULL;
      OPEN cr_crapenc(pr_cdcooper => rw_crapass.cdcooper,
                      pr_nrdconta => rw_crapass.nrdconta,
                      pr_idseqttl => rw_crapass.idseqttl,
                      pr_tpencass => 10); -- Residencial
      FETCH cr_crapenc INTO rw_crapenc;
      CLOSE cr_crapenc;
      
      -- Se for o primeiro titular, deve-se atualizar na CRAPASS
      IF rw_crapass.idseqttl = 1 THEN
        pc_atualiza_crapass(pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                            pr_nmprimtl => rw_crapass.nmprimtl,
                            pr_dtnasctl => rw_crapass.dtnasctl,
                            pr_cdnacion => rw_crapass.cdnacion,
                            pr_dsproftl => rw_crapass.dsproftl,
                            pr_tpdocptl => rw_crapass.tpdocptl,
                            pr_nrdocptl => rw_crapass.nrdocptl,
                            pr_dsfiliac => rw_crapass.dsfiliac,
                            pr_cdturnos => rw_crapass.cdturnos,
                            pr_nrramemp => rw_crapass.nrramemp,
                            pr_dtcnsspc => rw_crapass.dtcnsspc,
                            pr_idorgexp => rw_crapass.idorgexp,
                            pr_cdufdptl => rw_crapass.cdufdptl,
                            pr_dtemdptl => rw_crapass.dtemdptl,
                            pr_dtcnscpf => rw_crapass.dtcnscpf,
                            pr_cdsitcpf => rw_crapass.cdsitcpf,
                            pr_nmpaiptl => rw_crapass.nmpaittl,
                            pr_nmmaeptl => rw_crapass.nmmaettl,
                            pr_dtcnsscr => rw_crapass.dtcnsscr,
                            pr_cdclcnae => rw_crapass.cdclcnae,
                            pr_nmttlrfb => rw_crapass.nmttlrfb,
                            pr_inconrfb => rw_crapass.inconrfb,
                            pr_cdsexotl => rw_crapass.cdsexotl,
                            pr_dtultalt => rw_crapass.dtultalt,
                            pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      ELSE
        -- Atualiza a CRAPASS com os dados basicos (que nao sao exclusivos da TTL ou JUR)
        pc_atualiza_crapass_basico(pr_nrcpfcgc => rw_crapass.nrcpfcgc_crapass,
                                   pr_nmprimtl => rw_crapass.nmprimtl,
                                   pr_dtnasctl => rw_crapass.dtnasctl,
                                   pr_tpdocptl => rw_crapass.tpdocptl,
                                   pr_nrdocptl => rw_crapass.nrdocptl,
                                   pr_dsfiliac => rw_crapass.dsfiliac,
                                   pr_nrramemp => rw_crapass.nrramemp,
                                   pr_dtcnsspc => rw_crapass.dtcnsspc,
                                   pr_cdufdptl => rw_crapass.cdufdptl,
                                   pr_dtemdptl => rw_crapass.dtemdptl,
                                   pr_dtcnsscr => rw_crapass.dtcnsscr,
                                   pr_cdclcnae => rw_crapass.cdclcnae,
                                   pr_nmttlrfb => rw_crapass.nmttlrfb,
                                   pr_inconrfb => rw_crapass.inconrfb,
                                   pr_dtultalt => rw_crapass.dtultalt,
                                   pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;        
      END IF;

      -- Se for PF
      IF rw_crapass.inpessoa = 1 THEN
        -- Atualiza os dados dos titulares
        pc_atualiza_crapttl(pr_cdcooper => rw_crapass.cdcooper,
                            pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                            pr_dsnatura => rw_crapass.dsnatura,
                            pr_cdnacion => rw_crapass.cdnacion,
                            pr_cdufnatu => rw_crapass.cdufnatu,
                            pr_nmextttl => rw_crapass.nmextttl,
                            pr_dtcnscpf => rw_crapass.dtcnscpf,
                            pr_cdsitcpf => rw_crapass.cdsitcpf,
                            pr_dtatutel => rw_crapass.dtatutel,
                            pr_cdsexotl => rw_crapass.cdsexotl,
                            pr_cdestcvl => rw_crapass.cdestcvl,
                            pr_dtnasttl => rw_crapass.dtnasttl,
                            pr_tpnacion => rw_crapass.tpnacion,
                            pr_tpdocttl => rw_crapass.tpdocttl,
                            pr_nrdocttl => rw_crapass.nrdocttl,
                            pr_dtemdttl => rw_crapass.dtemdttl,
                            pr_idorgexp => rw_crapass.idorgexp,
                            pr_cdufdttl => rw_crapass.cdufdttl,
                            pr_inhabmen => rw_crapass.inhabmen,
                            pr_dthabmen => rw_crapass.dthabmen,
                            pr_grescola => rw_crapass.grescola,
                            pr_cdfrmttl => rw_crapass.cdfrmttl,
                            pr_cdnatopc => rw_crapass.cdnatopc,
                            pr_nmpaittl => rw_crapass.nmpaittl,
                            pr_nmmaettl => rw_crapass.nmmaettl,
                            pr_dsproftl => rw_crapass.dsproftl,
                            pr_dsjusren => rw_crapass.dsjusren,
                            pr_tpcttrab => rw_crapass.tpcttrab,
                            pr_cdnvlcgo => rw_crapass.cdnvlcgo,
                            pr_dtadmemp => rw_crapass.dtadmemp,
                            pr_cdocpttl => rw_crapass.cdocpttl,
                            pr_nrcadast => rw_crapass.nrcadast,
                            pr_vlsalari => rw_crapass.vlsalari,
                            pr_cdturnos => rw_crapass.cdturnos,
                            pr_nmextemp => rw_crapass.nmextemp,
                            pr_nrcpfemp => rw_crapass.nrcpfemp,
                            pr_cdempres => rw_crapass.cdempres,
                            pr_tpdrendi##1 => rw_crapass.tpdrendi##1,
                            pr_tpdrendi##2 => rw_crapass.tpdrendi##2,
                            pr_tpdrendi##3 => rw_crapass.tpdrendi##3,
                            pr_tpdrendi##4 => rw_crapass.tpdrendi##4,
                            pr_tpdrendi##5 => rw_crapass.tpdrendi##5,
                            pr_tpdrendi##6 => rw_crapass.tpdrendi##6,
                            pr_vldrendi##1 => rw_crapass.vldrendi##1,
                            pr_vldrendi##2 => rw_crapass.vldrendi##2,
                            pr_vldrendi##3 => rw_crapass.vldrendi##3,
                            pr_vldrendi##4 => rw_crapass.vldrendi##4,
                            pr_vldrendi##5 => rw_crapass.vldrendi##5,
                            pr_vldrendi##6 => rw_crapass.vldrendi##6,
                            pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Atualiza os dados do conjuge
        pc_atualiza_crapcje(pr_nrcpfcjg => rw_crapass.nrcpfcgc,
                            pr_nmconjug => rw_crapass.nmextttl,
                            pr_dtnasccj => rw_crapass.dtnasttl,
                            pr_tpdoccje => rw_crapass.tpdocttl,
                            pr_nrdoccje => rw_crapass.nrdocttl,
                            pr_idorgexp => rw_crapass.idorgexp,
                            pr_cdufdcje => rw_crapass.cdufdttl,
                            pr_dtemdcje => rw_crapass.dtemdttl,
                            pr_grescola => rw_crapass.grescola,
                            pr_cdfrmttl => rw_crapass.cdfrmttl,
                            pr_cdnatopc => rw_crapass.cdnatopc,
                            pr_dsproftl => rw_crapass.dsproftl,
                            pr_cdocpcje => rw_crapass.cdocpttl,
                            pr_tpcttrab => rw_crapass.tpcttrab,
                            pr_cdnvlcgo => rw_crapass.cdnvlcgo,
                            pr_cdturnos => rw_crapass.cdturnos,
                            pr_dtadmemp => rw_crapass.dtadmemp,
                            pr_vlsalari => rw_crapass.vlsalari,
                            pr_nrdocnpj => rw_crapass.nrcpfemp,
                            pr_nmextemp => rw_crapass.nmextemp,
                            pr_nrfonemp => rw_craptfc.nrtelefo,
                            pr_nrramemp => rw_craptfc.nrdramal,
                            pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Atualiza os responsaveis legais
        pc_atualiza_crapcrl(pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                            pr_nmrespon => rw_crapass.nmextttl,
                            pr_idorgexp => rw_crapass.idorgexp,
                            pr_cdufiden => rw_crapass.cdufdttl,
                            pr_dtemiden => rw_crapass.dtemdttl,
                            pr_dtnascin => rw_crapass.dtnasttl,
                            pr_cddosexo => rw_crapass.cdsexotl,
                            pr_cdestciv => rw_crapass.cdestcvl,
                            pr_nridenti => rw_crapass.nrdocttl,
                            pr_tpdeiden => rw_crapass.tpdocttl,
                            pr_cdnacion => rw_crapass.cdnacion,
                            pr_dsnatura => rw_crapass.dsnatura,
                            pr_nmpairsp => rw_crapass.nmpaittl,
                            pr_nmmaersp => rw_crapass.nmmaettl,
                            pr_cdcepres => rw_crapenc.nrcepend,
                            pr_dsendres => rw_crapenc.dsendere,
                            pr_nrendres => rw_crapenc.nrendere,
                            pr_dscomres => rw_crapenc.complend,
                            pr_dsbaires => rw_crapenc.nmbairro,
                            pr_dscidres => rw_crapenc.nmcidade,
                            pr_dsdufres => rw_crapenc.cdufende,
                            pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

      ELSE -- Se for PJ
        -- Atualiza a tabela de pessoa juridica
        pc_atualiza_crapjur(pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                            pr_nmextttl => rw_crapass.nmextttl,
                            pr_dtatutel => rw_crapass.dtatutel,
                            pr_nmfansia => rw_crapass.nmfansia,
                            pr_nrinsest => rw_crapass.nrinsest,
                            pr_natjurid => rw_crapass.natjurid,
                            pr_dtiniatv => rw_crapass.dtiniatv,
                            pr_qtfilial => rw_crapass.qtfilial,
                            pr_qtfuncio => rw_crapass.qtfuncio,
                            pr_vlcaprea => rw_crapass.vlcaprea,
                            pr_dtregemp => rw_crapass.dtregemp,
                            pr_nrregemp => rw_crapass.nrregemp,
                            pr_orregemp => rw_crapass.orregemp,
                            pr_dtinsnum => rw_crapass.dtinsnum,
                            pr_nrcdnire => rw_crapass.nrcdnire,
                            pr_flgrefis => rw_crapass.flgrefis,
                            pr_dsendweb => rw_crapass.dsendweb,
                            pr_nrinsmun => rw_crapass.nrinsmun,
                            pr_cdseteco => rw_crapass.cdseteco,
                            pr_vlfatano => rw_crapass.vlfatano,
                            pr_cdrmativ => rw_crapass.cdrmativ,
                            pr_nrlicamb => rw_crapass.nrlicamb,
                            pr_dtvallic => rw_crapass.dtvallic,
                            pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
                            
      END IF; -- Fim da verificacao se eh pessoa fisica
      
      -- Atualiza os dados do representante e avalistas terceiro
      pc_atualiza_crapavt(pr_nrcpfcgc    => rw_crapass.nrcpfcgc,
                          pr_nmdavali    => rw_crapass.nmextttl,
                          pr_tpdocava    => rw_crapass.tpdocttl,
                          pr_nrdocava    => rw_crapass.nrdocttl,
                          pr_idorgexp    => rw_crapass.idorgexp,
                          pr_dtemddoc    => rw_crapass.dtemdttl,
                          pr_cdufddoc    => rw_crapass.cdufdttl,
                          pr_dtnascto    => rw_crapass.dtnasttl,
                          pr_cdsexcto    => rw_crapass.cdsexotl,
                          pr_cdestcvl    => rw_crapass.cdestcvl,
                          pr_inhabmen    => rw_crapass.inhabmen,
                          pr_dthabmen    => rw_crapass.dthabmen,
                          pr_cdnacion    => rw_crapass.cdnacion,
                          pr_dsnatura    => rw_crapass.dsnatura,
                          pr_nmpaicto    => rw_crapass.nmpaittl,
                          pr_nmmaecto    => rw_crapass.nmmaettl,
                          pr_nrcepend    => rw_crapenc.nrcepend,
                          pr_dsendres##1 => rw_crapenc.dsendere,
                          pr_nrendere    => rw_crapenc.nrendere,
                          pr_complend    => rw_crapenc.complend,
                          pr_nmbairro    => rw_crapenc.nmbairro,
                          pr_nmcidade    => rw_crapenc.nmcidade,
                          pr_cdufresd    => rw_crapenc.cdufende,
                          pr_dsrelbem##1 => vr_bem(1).dsrelbem,
                          pr_persemon##1 => vr_bem(1).persemon,
                          pr_qtprebem##1 => vr_bem(1).qtprebem,
                          pr_vlrdobem##1 => vr_bem(1).vlrdobem,
                          pr_vlprebem##1 => vr_bem(1).vlprebem,
                          pr_dsrelbem##2 => vr_bem(2).dsrelbem,
                          pr_persemon##2 => vr_bem(2).persemon,
                          pr_qtprebem##2 => vr_bem(2).qtprebem,
                          pr_vlrdobem##2 => vr_bem(2).vlrdobem,
                          pr_vlprebem##2 => vr_bem(2).vlprebem,
                          pr_dsrelbem##3 => vr_bem(3).dsrelbem,
                          pr_persemon##3 => vr_bem(3).persemon,
                          pr_qtprebem##3 => vr_bem(3).qtprebem,
                          pr_vlrdobem##3 => vr_bem(3).vlrdobem,
                          pr_vlprebem##3 => vr_bem(3).vlprebem,
                          pr_dsrelbem##4 => vr_bem(4).dsrelbem,
                          pr_persemon##4 => vr_bem(4).persemon,
                          pr_qtprebem##4 => vr_bem(4).qtprebem,
                          pr_vlrdobem##4 => vr_bem(4).vlrdobem,
                          pr_vlprebem##4 => vr_bem(4).vlprebem,
                          pr_dsrelbem##5 => vr_bem(5).dsrelbem,
                          pr_persemon##5 => vr_bem(5).persemon,
                          pr_qtprebem##5 => vr_bem(5).qtprebem,
                          pr_vlrdobem##5 => vr_bem(5).vlrdobem,
                          pr_vlprebem##5 => vr_bem(5).vlprebem,
                          pr_dsrelbem##6 => vr_bem(6).dsrelbem,
                          pr_persemon##6 => vr_bem(6).persemon,
                          pr_qtprebem##6 => vr_bem(6).qtprebem,
                          pr_vlrdobem##6 => vr_bem(6).vlrdobem,
                          pr_vlprebem##6 => vr_bem(6).vlprebem,
                          pr_dscritic    => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
        
      
      -- Loop sobre as contas com o mesmo CPF / CNPJ
      FOR rw_crapass_2 IN cr_crapass_02(pr_inpessoa => rw_crapass.inpessoa,
                                        pr_nrcpfcgc => ind,
                                        pr_cdcooper => rw_crapass.cdcooper,
                                        pr_nrdconta => rw_crapass.nrdconta,
                                        pr_idseqttl => rw_crapass.idseqttl) LOOP

        -- Escreve o log da conta secundaria
        gene0002.pc_escreve_xml(vr_log,vr_log_aux,'  Conta secundaria: '||rw_crapass_2.cdcooper||'-'||rw_crapass_2.nrdconta||'-'||rw_crapass_2.idseqttl||chr(10));

        -- Exclui as tabelas auxiliares
        pc_exclui_auxiliares(pr_inpessoa_dst => rw_crapass_2.inpessoa,
                             pr_cdcooper_dst => rw_crapass_2.cdcooper,
                             pr_nrdconta_dst => rw_crapass_2.nrdconta,
                             pr_idseqttl_dst => rw_crapass_2.idseqttl,
                             pr_dscritic     => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
             
        -- Insere nas tabelas auxiliares        
        pc_insere_auxiliares(pr_cdcooper_org => rw_crapass.cdcooper,
                             pr_nrdconta_org => rw_crapass.nrdconta,
                             pr_idseqttl_org => rw_crapass.idseqttl,
                             pr_cdcooper_dst => rw_crapass_2.cdcooper,
                             pr_nrdconta_dst => rw_crapass_2.nrdconta,
                             pr_idseqttl_dst => rw_crapass_2.idseqttl,
                             pr_dscritic     => vr_dscritic);          
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Insere as empresas com participacao
        pc_insere_crapepa(pr_cdcooper_org => rw_crapass.cdcooper,
                          pr_nrdconta_org => rw_crapass.nrdconta, 
                          pr_cdcooper_dst => rw_crapass_2.cdcooper, 
                          pr_nrdconta_dst => rw_crapass_2.nrdconta,
                          pr_dscritic     => vr_dscritic);          
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Insere na tabela de responsavel legal
        pc_insere_crapcrl(pr_cdcooper_org => rw_crapass.cdcooper,
                          pr_nrdconta_org => rw_crapass.nrdconta,
                          pr_idseqttl_org => rw_crapass.idseqttl,
                          pr_cdcooper_dst => rw_crapass_2.cdcooper,
                          pr_nrdconta_dst => rw_crapass_2.nrdconta,
                          pr_idseqttl_dst => rw_crapass_2.idseqttl,
                          pr_dscritic     => vr_dscritic);                    
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Insere as pessoas de referencia
        pc_insere_crapavt(pr_inpessoa_org => rw_crapass.inpessoa,
                          pr_cdcooper_org => rw_crapass.cdcooper,
                          pr_nrdconta_org => rw_crapass.nrdconta,
                          pr_idseqttl_org => rw_crapass.idseqttl,
                          pr_cdcooper_dst => rw_crapass_2.cdcooper,
                          pr_nrdconta_dst => rw_crapass_2.nrdconta,      
                          pr_idseqttl_dst => rw_crapass_2.idseqttl,
                          pr_dscritic     => vr_dscritic);          
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Insere o conjuge
        pc_insere_crapcje(pr_cdcooper_org => rw_crapass.cdcooper,
                          pr_nrdconta_org => rw_crapass.nrdconta,
                          pr_idseqttl_org => rw_crapass.idseqttl,
                          pr_cdcooper_dst => rw_crapass_2.cdcooper,
                          pr_nrdconta_dst => rw_crapass_2.nrdconta,
                          pr_idseqttl_dst => rw_crapass_2.idseqttl,
                          pr_dscritic     => vr_dscritic);         
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
                          
      END LOOP;                                 
      
      -- Vai para o proximo registro
      ind := vr_conta.next(ind);
      
    END LOOP;

    ---------------------- PROCURADOR, REPRESENTANTE ---------------------
    -- Escreve o log para inicio do processo
    gene0002.pc_escreve_xml(vr_log,vr_log_aux,chr(10)||chr(10)||'INICIO PROCESSO Representante, Procurador e Avalistas'||chr(10));

    -- Atualiza o indice para o primeiro registro
    ind := vr_conta.first;
  
    LOOP
      EXIT WHEN NOT vr_conta.exists(ind);
      
      -- Se nao for da tabela de procurador, respresentante ou avalista
      IF vr_conta(ind).tptabela <> 2 THEN
        -- Vai para o proximo registro
        ind := vr_conta.next(ind);
        -- vai para o inicio do loop
        continue; 
      END IF;
      
      -- Incrementa o total de registros processados
      vr_qtprocesso := vr_qtprocesso + 1;

      OPEN cr_crapavt(vr_conta(ind).pr_rowid);
      FETCH cr_crapavt INTO rw_crapavt;
      CLOSE cr_crapavt; 

      -- Escreve o log da conta principal      
      gene0002.pc_escreve_xml(vr_log,vr_log_aux,'Conta Principal: '||rw_crapavt.cdcooper||'-'||rw_crapavt.nrdconta||
                                                 ' CPF: '||rw_crapavt.nrcpfcgc||chr(10));
      
      -- Atualiza os dados do representante e avalistas terceiro
      pc_atualiza_crapavt(pr_nrcpfcgc    => rw_crapavt.nrcpfcgc   ,
                          pr_nmdavali    => rw_crapavt.nmdavali   ,
                          pr_tpdocava    => rw_crapavt.tpdocava   ,
                          pr_nrdocava    => rw_crapavt.nrdocava   ,
                          pr_idorgexp    => rw_crapavt.idorgexp   ,
                          pr_dtemddoc    => rw_crapavt.dtemddoc   ,
                          pr_cdufddoc    => rw_crapavt.cdufddoc   ,
                          pr_dtnascto    => rw_crapavt.dtnascto   ,
                          pr_cdsexcto    => rw_crapavt.cdsexcto   ,
                          pr_cdestcvl    => rw_crapavt.cdestcvl   ,
                          pr_inhabmen    => rw_crapavt.inhabmen   ,
                          pr_dthabmen    => rw_crapavt.dthabmen   ,
                          pr_cdnacion    => rw_crapavt.cdnacion   ,
                          pr_dsnatura    => rw_crapavt.dsnatura   ,
                          pr_nmpaicto    => rw_crapavt.nmpaicto   ,
                          pr_nmmaecto    => rw_crapavt.nmmaecto   ,
                          pr_nrcepend    => rw_crapavt.nrcepend   ,
                          pr_dsendres##1 => rw_crapavt.dsendres##1,
                          pr_nrendere    => rw_crapavt.nrendere   ,
                          pr_complend    => rw_crapavt.complend   ,
                          pr_nmbairro    => rw_crapavt.nmbairro   ,
                          pr_nmcidade    => rw_crapavt.nmcidade   ,
                          pr_cdufresd    => rw_crapavt.cdufresd   ,
                          pr_dsrelbem##1 => rw_crapavt.dsrelbem##1,
                          pr_persemon##1 => rw_crapavt.persemon##1,
                          pr_qtprebem##1 => rw_crapavt.qtprebem##1,
                          pr_vlrdobem##1 => rw_crapavt.vlrdobem##1,
                          pr_vlprebem##1 => rw_crapavt.vlprebem##1,
                          pr_dsrelbem##2 => rw_crapavt.dsrelbem##2,
                          pr_persemon##2 => rw_crapavt.persemon##2,
                          pr_qtprebem##2 => rw_crapavt.qtprebem##2,
                          pr_vlrdobem##2 => rw_crapavt.vlrdobem##2,
                          pr_vlprebem##2 => rw_crapavt.vlprebem##2,
                          pr_dsrelbem##3 => rw_crapavt.dsrelbem##3,
                          pr_persemon##3 => rw_crapavt.persemon##3,
                          pr_qtprebem##3 => rw_crapavt.qtprebem##3,
                          pr_vlrdobem##3 => rw_crapavt.vlrdobem##3,
                          pr_vlprebem##3 => rw_crapavt.vlprebem##3,
                          pr_dsrelbem##4 => rw_crapavt.dsrelbem##4,
                          pr_persemon##4 => rw_crapavt.persemon##4,
                          pr_qtprebem##4 => rw_crapavt.qtprebem##4,
                          pr_vlrdobem##4 => rw_crapavt.vlrdobem##4,
                          pr_vlprebem##4 => rw_crapavt.vlprebem##4,
                          pr_dsrelbem##5 => rw_crapavt.dsrelbem##5,
                          pr_persemon##5 => rw_crapavt.persemon##5,
                          pr_qtprebem##5 => rw_crapavt.qtprebem##5,
                          pr_vlrdobem##5 => rw_crapavt.vlrdobem##5,
                          pr_vlprebem##5 => rw_crapavt.vlprebem##5,
                          pr_dsrelbem##6 => rw_crapavt.dsrelbem##6,
                          pr_persemon##6 => rw_crapavt.persemon##6,
                          pr_qtprebem##6 => rw_crapavt.qtprebem##6,
                          pr_vlrdobem##6 => rw_crapavt.vlrdobem##6,
                          pr_vlprebem##6 => rw_crapavt.vlprebem##6,
                          pr_dscritic    => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Atualiza os dados do representante e avalista terceiro no cadastro de conjuge
      pc_atualiza_crapcje_crapvt(pr_nrcpfcjg => rw_crapavt.nrcpfcgc,
                                 pr_nmconjug => rw_crapavt.nmdavali,
                                 pr_dtnasccj => rw_crapavt.dtnascto,
                                 pr_tpdoccje => rw_crapavt.tpdocava,
                                 pr_nrdoccje => rw_crapavt.nrdocava,
                                 pr_idorgexp => rw_crapavt.idorgexp,
                                 pr_cdufdcje => rw_crapavt.cdufddoc,
                                 pr_dtemdcje => rw_crapavt.dtemddoc,
                                 pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Atualiza os dados do representante e avalista terceiro no cadastro de responsavel legal
      pc_atualiza_crapcrl(pr_nrcpfcgc => rw_crapavt.nrcpfcgc,
                          pr_nmrespon => rw_crapavt.nmdavali,
                          pr_idorgexp => rw_crapavt.idorgexp,
                          pr_cdufiden => rw_crapavt.cdufddoc,
                          pr_dtemiden => rw_crapavt.dtemddoc,
                          pr_dtnascin => rw_crapavt.dtnascto,
                          pr_cddosexo => rw_crapavt.cdsexcto,
                          pr_cdestciv => rw_crapavt.cdestcvl,
                          pr_nridenti => rw_crapavt.nrdocava,
                          pr_tpdeiden => rw_crapavt.tpdocava,
                          pr_cdnacion => rw_crapavt.cdnacion,
                          pr_dsnatura => rw_crapavt.dsnatura,
                          pr_nmpairsp => rw_crapavt.nmpaicto,
                          pr_nmmaersp => rw_crapavt.nmmaecto,
                          pr_cdcepres => rw_crapavt.nrcepend,
                          pr_dsendres => rw_crapavt.dsendres##1,
                          pr_nrendres => rw_crapavt.nrendere,
                          pr_dscomres => rw_crapavt.complend,
                          pr_dsbaires => rw_crapavt.nmbairro,
                          pr_dscidres => rw_crapavt.nmcidade,
                          pr_dsdufres => rw_crapavt.cdufresd,
                          pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Vai para o proximo registro
      ind := vr_conta.next(ind);
      
    END LOOP;


    ---------------------- CONJUGE  ---------------------
    -- Escreve o log para inicio do processo
    gene0002.pc_escreve_xml(vr_log,vr_log_aux,chr(10)||chr(10)||'INICIO PROCESSO Conjuge'||chr(10));

    -- Atualiza o indice para o primeiro registro
    ind := vr_conta.first;
  
    LOOP
      EXIT WHEN NOT vr_conta.exists(ind);
      
      -- Se nao for da tabela de conjuge
      IF vr_conta(ind).tptabela <> 4 THEN
        -- Vai para o proximo registro
        ind := vr_conta.next(ind);
        -- vai para o inicio do loop
        continue; 
      END IF;
      
      -- Incrementa o total de registros processados
      vr_qtprocesso := vr_qtprocesso + 1;

      OPEN cr_crapcje(vr_conta(ind).pr_rowid);
      FETCH cr_crapcje INTO rw_crapcje;
      CLOSE cr_crapcje; 

      -- Escreve o log da conta principal      
      gene0002.pc_escreve_xml(vr_log,vr_log_aux,'Conta Principal: '||rw_crapcje.cdcooper||'-'||rw_crapcje.nrdconta||
                                                 ' CPF: '||rw_crapcje.nrcpfcjg||chr(10));
      
      -- Atualiza os dados do conjuge
      pc_atualiza_crapcje(pr_nrcpfcjg => rw_crapcje.nrcpfcjg,
                          pr_nmconjug => rw_crapcje.nmconjug,
                          pr_dtnasccj => rw_crapcje.dtnasccj,
                          pr_tpdoccje => rw_crapcje.tpdoccje,
                          pr_nrdoccje => rw_crapcje.nrdoccje,
                          pr_idorgexp => rw_crapcje.idorgexp,
                          pr_cdufdcje => rw_crapcje.cdufdcje,
                          pr_dtemdcje => rw_crapcje.dtemdcje,
                          pr_grescola => rw_crapcje.grescola,
                          pr_cdfrmttl => rw_crapcje.cdfrmttl,
                          pr_cdnatopc => rw_crapcje.cdnatopc,
                          pr_dsproftl => rw_crapcje.dsproftl,
                          pr_cdocpcje => rw_crapcje.cdocpcje,
                          pr_tpcttrab => rw_crapcje.tpcttrab,
                          pr_cdnvlcgo => rw_crapcje.cdnvlcgo,
                          pr_cdturnos => rw_crapcje.cdturnos,
                          pr_dtadmemp => rw_crapcje.dtadmemp,
                          pr_vlsalari => rw_crapcje.vlsalari,
                          pr_nrdocnpj => rw_crapcje.nrdocnpj,
                          pr_nmextemp => rw_crapcje.nmextemp,
                          pr_nrfonemp => rw_crapcje.nrfonemp,
                          pr_nrramemp => rw_crapcje.nrramemp,
                          pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Vai para o proximo registro
      ind := vr_conta.next(ind);
      
    END LOOP;


    -- Escreve o log do termino do processo
    gene0002.pc_escreve_xml(vr_log,vr_log_aux,'Total de registros processados: '||to_char(vr_qtprocesso));
    -- Escreve o log do termino do processo
    gene0002.pc_escreve_xml(vr_log,vr_log_aux,'Termino do processo: '||to_char(SYSDATE,'DD/MM/YYYY HH24:mi:ss'),TRUE);
    
    -- Gera o arquivo de log
    gene0002.pc_clob_para_arquivo(pr_clob => vr_log,
                                  pr_caminho => '/micros/cecred/andrino',
                                  pr_arquivo => 'log_saneamento.txt',
                                  pr_des_erro => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
  EXCEPTION 
    WHEN vr_exc_erro THEN

      pr_dscritic := 'Reg: '|| vr_qtprocesso||'.  '|| vr_dscritic;

    -- Escreve o log do termino do processo
    gene0002.pc_escreve_xml(vr_log,vr_log_aux,'Termino do processo: '||to_char(SYSDATE,'DD/MM/YYYY HH24:mi:ss'),TRUE);
    
    -- Gera o arquivo de log
    gene0002.pc_clob_para_arquivo(pr_clob => vr_log,
                                  pr_caminho => '/microsh/cecred/andrino',
                                  pr_arquivo => 'log_saneamento.txt',
                                  pr_des_erro => vr_dscritic);

    WHEN OTHERS THEN
      pr_dscritic := 'Reg: '|| vr_qtprocesso||'.  Erro nao tratado pc_executa_processo: '||SQLERRM; 
  END pc_executa_processo;
    
  

END CADA0009;
/
