declare 
  -- Local variables here
  cursor cr_lojista is
    select c.cdcooper
          ,c.nrdconta
          ,c.nmfantasia
      from tbsite_cooperado_cdc c
      join crapass a on (a.cdcooper=c.cdcooper and a.nrdconta=c.nrdconta)
     --join crapcdr d on (a.cdcooper=D.cdcooper and a.nrdconta=d.nrdconta and d.flgconve=1)
     where ( 
            (c.cdcooper=1
       and c.nrdconta in (6204090,
                          8540985,
                          7850166,
                          6008810,
                          8622205,
                          8597464,
                          2246090,
                          7354100,
                          8506574,
                          3615332,
                          907936,
                          8583498,
                          927180,
                          2653656,
                          2813602,
                          881090,
                          2639475,
                          7593309,
                          3500764,
                          8584176,
                          7715030,
                          2095289,
                          6041973,
                          8580057,
                          3884473,
                          2403900,
                          2117525,
                          3883655,
                          8466432,
                          2722348,
                          8646350,
                          8544387,
                          7238703,
                          8608334,
                          859001,
                          9107185,
                          8584338,
                          6172300,
                          7947909,
                          7830262,
                          2751666,
                          8615101,
                          3614840,
                          9129634,
                          7889038,
                          6322662,
                          6972470,
                          9470654,
                          2244667,
                          8144184,
                          7688032,
                          941611,
                          8240175,
                          3721876,
                          6398332,
                          8472130,
                          8660263,
                          6680097,
                          7801190,
                          7644426,
                          6819443,
                          7733127,
                          9101292,
                          8422672,
                          4251,
                          8589232,
                          6583776,
                          6640591,
                          2709805,
                          2949555,
                          7562730,
                          9120572,
                          2177110,
                          1521330,
                          6511023,
                          8579202,
                          7445105,
                          2572265,
                          3732401,
                          7289812,
                          8564817,
                          8380058,
                          8542902,
                          3921859,
                          6506704,
                          4059824,
                          8552525,
                          2157217,
                          8070970,
                          7083629,
                          7562080,
                          8026548,
                          1936450,
                          6242910,
                          6726313,
                          8578044,
                          8649111,
                          8581150,
                          4042158,
                          2232936,
                          7788100,
                          2717654,
                          8630720,
                          3952215,
                          3025225,
                          7289790,
                          7562608,
                          2197367,
                          6753906,
                          6172130,
                          8377162,
                          7923139,
                          8658943,
                          2924358,
                          7307918,
                          80420575,
                          7947801,
                          8131422,
                          8255857,
                          6262198,
                          7057806,
                          8630216,
                          7650019,
                          7258330,
                          3857395,
                          3658651,
                          8592080,
                          7312288,
                          2196328,
                          7662831,
                          4076095,
                          932302,
                          2540584,
                          8152977,
                          2752654,
                          8638160,
                          7735090,
                          8173729,
                          6447872,
                          8362661,
                          4050894,
                          8377871,
                          7861702,
                          8649847,
                          7592167,
                          8553890,
                          8587612,
                          6485189,
                          8586608,
                          8343233,
                          7484011,
                          3884198) ) OR
       (c.cdcooper=2
       and c.nrdconta=615781) OR
       (c.cdcooper=7
       and c.nrdconta=173070) OR
       (c.cdcooper=14
       and c.nrdconta IN (22284,7994)) OR
       (c.cdcooper=16 and
       c.nrdconta in (62367,190772,2853558)
       ))
       and c.idmatriz is null;

  
  cursor cr_vendedor (pr_cdcooper in crapass.cdcooper%type
                     ,pr_nrdconta in crapass.nrdconta%type) is
    select a.cdcooper
          ,a.nrdconta
          ,a.nmprimtl
          ,j.nmfansia
          ,c.nmfantasia
          ,v.nmvendedor
          ,v.idvendedor
      from tbsite_cooperado_cdc c 
      join crapass a on (a.cdcooper=c.cdcooper and a.nrdconta=c.nrdconta)
      left join tbepr_cdc_vendedor v on (v.idcooperado_cdc=c.idcooperado_cdc and v.nrcpf=a.nrcpfcgc)
      left join crapjur j on (j.cdcooper=c.cdcooper and j.nrdconta=c.nrdconta)
     where c.cdcooper=pr_cdcooper 
       and c.nrdconta=pr_nrdconta;
  
  cursor cr_valida (pr_dslogin in tbepr_cdc_usuario.dslogin%type) is
    select *
      from tbepr_cdc_usuario u
     where u.dslogin = pr_dslogin;
     
  cursor cr_valida_adm (pr_vendedor in tbepr_cdc_vendedor.idvendedor%type) is
    select v.idvendedor 
      from tbepr_cdc_usuario_vinculo v
      join tbepr_cdc_usuario u on (u.idusuario=v.idusuario and u.flgadmin=1)
     where v.idvendedor=pr_vendedor;
     
  cursor cr_usuario (pr_cdcooper in crapass.cdcooper%type
                    ,pr_nrdconta in crapass.nrdconta%type) is

    select decode(a.inpessoa,1,lpad(a.nrcpfcgc,11,'0'),lpad(a.nrcpfcgc,14,'0')) login
          ,lower(RAWTOHEX(DBMS_OBFUSCATION_TOOLKIT.md5(input => UTL_RAW.cast_to_raw(decode(a.inpessoa,1,lpad(a.nrcpfcgc,11,'0'),lpad(a.nrcpfcgc,14,'0')))))) as senha
          ,l.idcooperado_cdc
          ,c.cdcooper
          ,c.nrdconta
          ,a.inpessoa
          ,l.nmfantasia
          ,l.dsemail
      from crapass a
      join crapcdr c on (c.cdcooper=a.cdcooper and c.nrdconta=a.nrdconta)
      join tbsite_cooperado_cdc l on (l.cdcooper=c.cdcooper and l.nrdconta=c.nrdconta and l.idmatriz is null)
     where a.cdcooper=pr_cdcooper
       and a.nrdconta=pr_nrdconta;

   -- Definicao do tipo de registro
  TYPE typ_reg_cdr_cdc IS
  RECORD (flgconve           crapcdr.flgconve%TYPE
         ,dtinicon           crapcdr.dtinicon%TYPE
         ,inmotcan           crapcdr.inmotcan%TYPE
         ,dtcancon           crapcdr.dtcancon%TYPE
         ,dtacectr           crapcdr.dtacectr%TYPE
         ,dsmotcan           crapcdr.dsmotcan%TYPE
         ,dtrencon           crapcdr.dtrencon%TYPE
         ,dttercon           crapcdr.dttercon%TYPE
         ,idcooperado_cdc    tbsite_cooperado_cdc.idcooperado_cdc%TYPE
         ,nmfantasia         tbsite_cooperado_cdc.nmfantasia%TYPE
         ,cdcnae             tbsite_cooperado_cdc.cdcnae%TYPE
         ,dslogradouro       tbsite_cooperado_cdc.dslogradouro%TYPE
         ,dscomplemento      tbsite_cooperado_cdc.dscomplemento%TYPE
         ,idcidade           tbsite_cooperado_cdc.idcidade%TYPE
         ,nmbairro           tbsite_cooperado_cdc.nmbairro%TYPE
         ,nrendereco         tbsite_cooperado_cdc.nrendereco%TYPE
         ,nrcep              tbsite_cooperado_cdc.nrcep%TYPE
         ,dstelefone         tbsite_cooperado_cdc.dstelefone%TYPE
         ,dsemail            tbsite_cooperado_cdc.dsemail%TYPE
         ,nrlatitude         tbsite_cooperado_cdc.nrlatitude%TYPE
         ,nrlongitude        tbsite_cooperado_cdc.nrlongitude%TYPE
         ,idcomissao         tbsite_cooperado_cdc.idcomissao%TYPE
         ,flgitctr           crapcdr.flgitctr%TYPE);
  
  
  TYPE typ_reg_info_cdc
	     IS RECORD(dsendere tbsite_cooperado_cdc.dslogradouro%TYPE
                  ,nrendere tbsite_cooperado_cdc.nrendereco%TYPE
                  ,complend tbsite_cooperado_cdc.dscomplemento%TYPE
                  ,nmbairro tbsite_cooperado_cdc.nmbairro%TYPE
                  ,nrcepend tbsite_cooperado_cdc.nrcep%TYPE
                  ,nmcidade crapenc.nmcidade%TYPE
                  ,cdufende crapenc.cdufende%TYPE
                  ,idcidade tbsite_cooperado_cdc.idcidade%TYPE
                  ,nrtelefo tbsite_cooperado_cdc.dstelefone%TYPE
                  ,dsdemail tbsite_cooperado_cdc.dsemail%TYPE
                  ,nmfansia tbsite_cooperado_cdc.nmfantasia%TYPE);       

  -- Definicao do tipo de tabela registro
  TYPE typ_tab_cdr_cdc IS TABLE OF typ_reg_cdr_cdc INDEX BY PLS_INTEGER;

  -- Vetor para armazenar os dados da tabela
  vr_tab_cdr_cdc typ_tab_cdr_cdc;
  
  
  rw_usuario                   cr_usuario%rowtype;  
  vr_idusuario                 tbepr_cdc_usuario.idusuario%type;
  vr_idvendedor                tbepr_cdc_vendedor.idvendedor%type;
  rw_valida_adm                cr_valida_adm%rowtype;  
  rw_vendedor                  cr_vendedor%rowtype;  

  rw_lojista                   cr_lojista%rowtype;  
  rw_valida                    cr_valida%rowtype;  
  
  vr_cdcritic                  crapcri.cdcritic%type;
  vr_dscritic                  crapcri.dscritic%type;
  
  vr_nmlojista_old             tbsite_cooperado_cdc.nmfantasia%type;
  vr_nmlojista                 tbsite_cooperado_cdc.nmfantasia%type;
  
  -- Variaveis
  vr_idcooperado_cdc    tbsite_cooperado_cdc.idcooperado_cdc%TYPE;
  vr_nrendereco         tbsite_cooperado_cdc.nrendereco%TYPE;
  vr_nrcep              tbsite_cooperado_cdc.nrcep%TYPE;
  vr_idcidade           tbsite_cooperado_cdc.idcidade%TYPE;
  vr_cdcnae             tbsite_cooperado_cdc.cdcnae%TYPE;
  vr_dscnae_new         tbgen_cnae.dscnae%TYPE;
  vr_dscnae_old         tbgen_cnae.dscnae%TYPE;
  vr_dscidade_new       crapmun.dscidade%TYPE;
  vr_dscidade_old       crapmun.dscidade%TYPE;
  vr_nmrescop           crapcop.nmrescop%TYPE;
  vr_dtinicon_old       VARCHAR2(10);
  vr_dsconteudo_mail    VARCHAR2(10000) := '';
  vr_emaildst           VARCHAR2(4000);
  vr_rowid              ROWID;
      
  vr_dslogin            tbepr_cdc_usuario.dslogin%TYPE;
  vr_dssenha            tbepr_cdc_usuario.dssenha%TYPE;

  -- Vetor para armazenar os dados da tabela
  vr_tab_crapmun CADA0003.typ_tab_crapmun;
  
  
  
  -------
  PROCEDURE pc_carrega_dados(pr_cdcooper        IN crapcdr.cdcooper%TYPE --> Codigo da cooperativa
                            ,pr_nrdconta        IN crapcdr.nrdconta%TYPE --> Numero da conta
                            ,pr_idmatriz        IN tbsite_cooperado_cdc.idmatriz%TYPE
                            ,pr_idcooperado_cdc IN tbsite_cooperado_cdc.idcooperado_cdc%TYPE
                            ,pr_tab_cdr_cdc    OUT typ_tab_cdr_cdc --> PLTABLE com os dados
                            ,pr_cdcritic       OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic       OUT VARCHAR2) IS --> Descricao da critica
  BEGIN

    /* .............................................................................

    Programa: pc_carrega_dados
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Agosto/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os dados.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados
      CURSOR cr_crapcdr(pr_cdcooper IN crapcdr.cdcooper%TYPE
                       ,pr_nrdconta IN crapcdr.nrdconta%TYPE) IS
        SELECT crapcdr.flgconve
              ,crapcdr.dtinicon
              ,crapcdr.dtacectr
              ,nvl(crapcdr.inmotcan,0) inmotcan
              ,crapcdr.dtcancon              
              ,crapcdr.dsmotcan
              ,crapcdr.dtrencon
              ,crapcdr.dttercon
              ,crapcdr.flgitctr
          FROM crapcdr
         WHERE crapcdr.cdcooper = pr_cdcooper
           AND crapcdr.nrdconta = pr_nrdconta;
      rw_crapcdr cr_crapcdr%ROWTYPE;

      -- Selecionar os dados para o site da cooperativa
      CURSOR cr_tbsite_cooperado_cdc(pr_cdcooper        IN tbsite_cooperado_cdc.cdcooper%TYPE
                                    ,pr_nrdconta        IN tbsite_cooperado_cdc.nrdconta%TYPE
                                    ,pr_idmatriz        IN tbsite_cooperado_cdc.idmatriz%TYPE
                                    ,pr_idcooperado_cdc IN tbsite_cooperado_cdc.idcooperado_cdc%TYPE) IS
        SELECT t.idcooperado_cdc
              ,t.nmfantasia
              ,t.cdcnae
              ,t.dslogradouro
              ,t.dscomplemento
              ,t.idcidade
              ,t.nmbairro
              ,t.nrendereco
              ,t.nrcep
              ,t.dstelefone
              ,t.dsemail
              ,t.nrlatitude
              ,t.nrlongitude
              ,t.idcomissao
          FROM tbsite_cooperado_cdc t
         WHERE t.cdcooper = pr_cdcooper
           AND t.nrdconta = pr_nrdconta
           AND ((pr_idmatriz = 0 AND t.idmatriz IS NULL) OR
                (pr_idmatriz = t.idmatriz AND t.idcooperado_cdc = pr_idcooperado_cdc));
      rw_tbsite_cooperado_cdc cr_tbsite_cooperado_cdc%ROWTYPE;
      
      -- Variaveis Gerais
      vr_blnfound BOOLEAN;

    BEGIN
      -- Limpa PLTABLE
      pr_tab_cdr_cdc.DELETE;

      -- Selecionar os dados
      OPEN cr_crapcdr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapcdr INTO rw_crapcdr;
      -- Alimenta a booleana
      vr_blnfound := cr_crapcdr%FOUND;
      -- Fechar o cursor
      CLOSE cr_crapcdr;

      -- Se encontrou
      IF vr_blnfound THEN

        -- Carrega os dados na PLTRABLE
        pr_tab_cdr_cdc(pr_nrdconta).flgconve := rw_crapcdr.flgconve;
        pr_tab_cdr_cdc(pr_nrdconta).dtinicon := rw_crapcdr.dtinicon;
        pr_tab_cdr_cdc(pr_nrdconta).dtacectr := rw_crapcdr.dtacectr;
        pr_tab_cdr_cdc(pr_nrdconta).inmotcan := rw_crapcdr.inmotcan;
        pr_tab_cdr_cdc(pr_nrdconta).dtcancon := rw_crapcdr.dtcancon;
        pr_tab_cdr_cdc(pr_nrdconta).dsmotcan := rw_crapcdr.dsmotcan;
        pr_tab_cdr_cdc(pr_nrdconta).dtrencon := rw_crapcdr.dtrencon;
        pr_tab_cdr_cdc(pr_nrdconta).dttercon := rw_crapcdr.dttercon;
        pr_tab_cdr_cdc(pr_nrdconta).flgitctr := rw_crapcdr.flgitctr;

        -- Selecionar os dados para o site da cooperativa
        OPEN cr_tbsite_cooperado_cdc(pr_cdcooper        => pr_cdcooper
                                    ,pr_nrdconta        => pr_nrdconta
                                    ,pr_idmatriz        => pr_idmatriz
                                    ,pr_idcooperado_cdc => pr_idcooperado_cdc);
        FETCH cr_tbsite_cooperado_cdc INTO rw_tbsite_cooperado_cdc;
        -- Alimenta a booleana
        vr_blnfound := cr_tbsite_cooperado_cdc%FOUND;
        -- Fechar o cursor
        CLOSE cr_tbsite_cooperado_cdc;

        -- Se encontrou
        IF vr_blnfound THEN

          -- Carrega os dados na PLTRABLE
          pr_tab_cdr_cdc(pr_nrdconta).idcooperado_cdc    := rw_tbsite_cooperado_cdc.idcooperado_cdc;
          pr_tab_cdr_cdc(pr_nrdconta).nmfantasia         := rw_tbsite_cooperado_cdc.nmfantasia;
          pr_tab_cdr_cdc(pr_nrdconta).cdcnae             := rw_tbsite_cooperado_cdc.cdcnae;
          pr_tab_cdr_cdc(pr_nrdconta).dslogradouro       := rw_tbsite_cooperado_cdc.dslogradouro;
          pr_tab_cdr_cdc(pr_nrdconta).dscomplemento      := rw_tbsite_cooperado_cdc.dscomplemento;
          pr_tab_cdr_cdc(pr_nrdconta).idcidade           := rw_tbsite_cooperado_cdc.idcidade;
          pr_tab_cdr_cdc(pr_nrdconta).nmbairro           := rw_tbsite_cooperado_cdc.nmbairro;
          pr_tab_cdr_cdc(pr_nrdconta).nrendereco         := rw_tbsite_cooperado_cdc.nrendereco;
          pr_tab_cdr_cdc(pr_nrdconta).nrcep              := rw_tbsite_cooperado_cdc.nrcep;
          pr_tab_cdr_cdc(pr_nrdconta).dstelefone         := rw_tbsite_cooperado_cdc.dstelefone;
          pr_tab_cdr_cdc(pr_nrdconta).dsemail            := rw_tbsite_cooperado_cdc.dsemail;
          pr_tab_cdr_cdc(pr_nrdconta).nrlatitude         := rw_tbsite_cooperado_cdc.nrlatitude;
          pr_tab_cdr_cdc(pr_nrdconta).nrlongitude        := rw_tbsite_cooperado_cdc.nrlongitude;
          pr_tab_cdr_cdc(pr_nrdconta).idcomissao         := rw_tbsite_cooperado_cdc.idcomissao;
        END IF;

      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral na rotina da tela CVNCDC: ' || SQLERRM;
    END;

  END pc_carrega_dados;

  -------
  PROCEDURE pc_busca_nmfansia_cdc(pr_cdcooper IN crapenc.cdcooper%TYPE
                                 ,pr_nrdconta IN crapenc.nrdconta%TYPE
                                 ,pr_info_cdc IN OUT typ_reg_info_cdc
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                 ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
  /* .............................................................................

    Programa: pc_busca_nmfansia_cdc
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Janeiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar o nome fantasia da conta para o cdc

    Alteracoes: -----
    ..............................................................................*/                                   
    DECLARE
    
      vr_exc_erro EXCEPTION;
      
      vr_cdcritic NUMBER;
      vr_dscritic VARCHAR2(4000);
    
      -- Busca nome fantasia do cooperado
      CURSOR cr_crapjur(pr_cdcooper IN crapenc.cdcooper%TYPE
                       ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
        SELECT jur.nmfansia
          FROM crapjur jur
         WHERE jur.cdcooper = pr_cdcooper
           AND jur.nrdconta = pr_nrdconta;
      rw_crapjur cr_crapjur%ROWTYPE;
    BEGIN
      -- Busca nome fantasia do cooperado
      OPEN cr_crapjur(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapjur INTO rw_crapjur;
          
      pr_info_cdc.nmfansia := rw_crapjur.nmfansia;
          
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CVNCDC: ' || SQLERRM;

    END;		
	END pc_busca_nmfansia_cdc;
  ------------
  
  ----------
  PROCEDURE pc_busca_email_cdc(pr_cdcooper IN crapenc.cdcooper%TYPE
                              ,pr_nrdconta IN crapenc.nrdconta%TYPE
                              ,pr_info_cdc IN OUT typ_reg_info_cdc
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                              ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
  /* .............................................................................

    Programa: pc_busca_email_cdc
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Janeiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar o email da conta para o cdc

    Alteracoes: -----
    ..............................................................................*/                                   
    DECLARE
    
      vr_exc_erro EXCEPTION;
      
      vr_cdcritic NUMBER;
      vr_dscritic VARCHAR2(4000);
    
      -- Busca email do cooperado
      CURSOR cr_crapcem(pr_cdcooper IN crapenc.cdcooper%TYPE
                       ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
        SELECT cem.dsdemail
          FROM crapcem cem
         WHERE cem.cdcooper = pr_cdcooper
           AND cem.nrdconta = pr_nrdconta
           AND cem.idseqttl = 1;
      rw_crapcem cr_crapcem%ROWTYPE;
    BEGIN
      -- Busca email
      OPEN cr_crapcem(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapcem INTO rw_crapcem;
          
      pr_info_cdc.dsdemail := rw_crapcem.dsdemail;
          
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CVNCDC: ' || SQLERRM;

    END;		
	END pc_busca_email_cdc;

  ----------
  
  -----------
  PROCEDURE pc_busca_telefone_cdc(pr_cdcooper IN crapenc.cdcooper%TYPE
                                 ,pr_nrdconta IN crapenc.nrdconta%TYPE
                                 ,pr_info_cdc IN OUT typ_reg_info_cdc
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                 ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
  /* .............................................................................

    Programa: pc_busca_telefone_cdc
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Janeiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar telefone da conta para o cdc

    Alteracoes: -----
    ..............................................................................*/                                   
    DECLARE
    
      vr_exc_erro EXCEPTION;
      
      vr_cdcritic NUMBER;
      vr_dscritic VARCHAR2(4000);
    
      -- Busca telefone do cooperado
      CURSOR cr_craptfc(pr_cdcooper IN crapenc.cdcooper%TYPE
                       ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
        SELECT '('||lpad(tfc.nrdddtfc,2,'0')||') '|| tfc.nrtelefo nrtelefo
          FROM craptfc tfc
         WHERE tfc.cdcooper = pr_cdcooper
           AND tfc.nrdconta = pr_nrdconta
           AND tfc.idseqttl = 1
           AND tfc.tptelefo = 3 /* Comercial */
      ORDER BY tfc.cdseqtfc;
      rw_craptfc cr_craptfc%ROWTYPE;
    BEGIN
      -- Busca telefone
      OPEN cr_craptfc(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_craptfc INTO rw_craptfc;
        
      pr_info_cdc.nrtelefo := rw_craptfc.nrtelefo;
          
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CVNCDC: ' || SQLERRM;

    END;		
	END pc_busca_telefone_cdc;

  ----------
  
  
  
  ---------
  PROCEDURE pc_busca_endereco_cdc(pr_cdcooper IN crapenc.cdcooper%TYPE
                                 ,pr_nrdconta IN crapenc.nrdconta%TYPE
                                 ,pr_info_cdc IN OUT typ_reg_info_cdc
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                 ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
  /* .............................................................................

    Programa: pc_busca_endereco_cdc
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Janeiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar informações de endereço da conta para o cdc

    Alteracoes: -----
    ..............................................................................*/                                   
    DECLARE
    
      vr_exc_erro EXCEPTION;
      
      vr_cdcritic NUMBER;
      vr_dscritic VARCHAR2(4000);
    
      -- Busca endereço do cooperado
      CURSOR cr_crapenc(pr_cdcooper IN crapenc.cdcooper%TYPE
                       ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
        SELECT enc.dsendere
              ,enc.nrendere
              ,enc.complend
              ,enc.nmbairro
              ,enc.nrcepend
              ,enc.nmcidade
              ,enc.cdufende
          FROM crapenc enc
         WHERE enc.cdcooper = pr_cdcooper
           AND enc.nrdconta = pr_nrdconta
           AND enc.idseqttl = 1
           AND enc.tpendass = 9 /* Comercial */
      ORDER BY cdseqinc;
      rw_crapenc cr_crapenc%ROWTYPE;
    BEGIN
      -- Busca endereço
      OPEN cr_crapenc(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapenc INTO rw_crapenc;
      
      pr_info_cdc.dsendere := rw_crapenc.dsendere;
      pr_info_cdc.nrendere := rw_crapenc.nrendere;
      pr_info_cdc.complend := rw_crapenc.complend;
      pr_info_cdc.nmbairro := rw_crapenc.nmbairro;
      pr_info_cdc.nrcepend := rw_crapenc.nrcepend;
      pr_info_cdc.nmcidade := rw_crapenc.nmcidade;
      pr_info_cdc.cdufende := rw_crapenc.cdufende;
      pr_info_cdc.idcidade := cada0003.fn_busca_codigo_cidade(pr_cdestado => rw_crapenc.cdufende
                                                             ,pr_dscidade => rw_crapenc.nmcidade);
          
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CVNCDC: ' || SQLERRM;

    END;		
	END pc_busca_endereco_cdc;
	
  ---------
  
  
  --------------
  PROCEDURE pc_busca_dados(pr_nrdconta        IN crapcdr.nrdconta%TYPE --> Numero da conta
                          ,pr_inpessoa        IN crapass.inpessoa%TYPE --> Tipo de pessoa
                          ,pr_idmatriz        IN tbsite_cooperado_cdc.idmatriz%TYPE
                          ,pr_idcooperado_cdc IN tbsite_cooperado_cdc.idcooperado_cdc%TYPE
                          ,pr_xmllog          IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic       OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic       OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml      IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo       OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro       OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_dados
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Agosto/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os dados.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar o CNAE
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.cdclcnae
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;    
    
      -- Selecionar a UF
      CURSOR cr_crapenc(pr_cdcooper IN crapenc.cdcooper%TYPE
                       ,pr_nrdconta IN crapenc.nrdconta%TYPE
                       ,pr_tpendass IN crapenc.tpendass%TYPE) IS
        SELECT crapenc.cdufende
          FROM crapenc
         WHERE crapenc.cdcooper = pr_cdcooper
           AND crapenc.nrdconta = pr_nrdconta
           AND crapenc.tpendass = pr_tpendass;

      -- Selecionar a descricao da comissao
      CURSOR cr_comissao(pr_idcomissao IN tbepr_cdc_parm_comissao.idcomissao%TYPE) IS
        SELECT t.nmcomissao
          FROM tbepr_cdc_parm_comissao t
         WHERE t.idcomissao = pr_idcomissao;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis Gerais
      vr_cdclcnae crapass.cdclcnae%TYPE;
      vr_cdufende crapenc.cdufende%TYPE;
      vr_nmcomissao tbepr_cdc_parm_comissao.nmcomissao%TYPE;

      -- Vetor para armazenar os dados da tabela
      vr_tab_crapmun CADA0003.typ_tab_crapmun;

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      
      -- Selecionar a UF
      OPEN cr_crapenc(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_tpendass => (CASE WHEN pr_inpessoa = 1 THEN 10 ELSE 9 END)); -- PF: 10-Residencial / PJ: 9-Comercial
      FETCH cr_crapenc INTO vr_cdufende;
      CLOSE cr_crapenc;

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'cdufende'
                            ,pr_tag_cont => vr_cdufende
                            ,pr_des_erro => vr_dscritic);

      -- Carrega os dados
      pc_carrega_dados(pr_cdcooper        => vr_cdcooper
                      ,pr_nrdconta        => pr_nrdconta
                      ,pr_idmatriz        => pr_idmatriz
                      ,pr_idcooperado_cdc => pr_idcooperado_cdc
                      ,pr_tab_cdr_cdc     => vr_tab_cdr_cdc
                      ,pr_cdcritic        => vr_cdcritic
                      ,pr_dscritic        => vr_dscritic);

      -- Se houve retorno de erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Se encontrou registro
      IF vr_tab_cdr_cdc.EXISTS(pr_nrdconta) THEN

        -- Carrega a descricao da comissao
        OPEN cr_comissao(pr_idcomissao => vr_tab_cdr_cdc(pr_nrdconta).idcomissao);
        FETCH cr_comissao INTO vr_nmcomissao;
        CLOSE cr_comissao;

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'flgconve'
                              ,pr_tag_cont => NVL(vr_tab_cdr_cdc(pr_nrdconta).flgconve, 0)
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dtinicon'
                              ,pr_tag_cont => TO_CHAR(vr_tab_cdr_cdc(pr_nrdconta).dtinicon, 'DD/MM/RRRR')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'inmotcan'
                              ,pr_tag_cont => NVL(vr_tab_cdr_cdc(pr_nrdconta).inmotcan,0)
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dtcancon'
                              ,pr_tag_cont => TO_CHAR(vr_tab_cdr_cdc(pr_nrdconta).dtcancon, 'DD/MM/RRRR')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsmotcan'
                              ,pr_tag_cont => NVL(vr_tab_cdr_cdc(pr_nrdconta).dsmotcan,'')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dtrencon'
                              ,pr_tag_cont => TO_CHAR(vr_tab_cdr_cdc(pr_nrdconta).dtrencon, 'DD/MM/RRRR')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dttercon'
                              ,pr_tag_cont => TO_CHAR(vr_tab_cdr_cdc(pr_nrdconta).dttercon, 'DD/MM/RRRR')
                              ,pr_des_erro => vr_dscritic);
        
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dtacectr'
                              ,pr_tag_cont => TO_CHAR(vr_tab_cdr_cdc(pr_nrdconta).dtacectr, 'DD/MM/RRRR')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'idcooperado_cdc'
                              ,pr_tag_cont => vr_tab_cdr_cdc(pr_nrdconta).idcooperado_cdc
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nmfantasia'
                              ,pr_tag_cont => vr_tab_cdr_cdc(pr_nrdconta).nmfantasia
                              ,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dslogradouro'
                              ,pr_tag_cont => vr_tab_cdr_cdc(pr_nrdconta).dslogradouro
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dscomplemento'
                              ,pr_tag_cont => vr_tab_cdr_cdc(pr_nrdconta).dscomplemento
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nmbairro'
                              ,pr_tag_cont => vr_tab_cdr_cdc(pr_nrdconta).nmbairro
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrendereco'
                              ,pr_tag_cont => vr_tab_cdr_cdc(pr_nrdconta).nrendereco
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrcep'
                              ,pr_tag_cont => GENE0002.fn_mask(NVL(vr_tab_cdr_cdc(pr_nrdconta).nrcep, 0),'99.999-999')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dstelefone'
                              ,pr_tag_cont => vr_tab_cdr_cdc(pr_nrdconta).dstelefone
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsemail'
                              ,pr_tag_cont => vr_tab_cdr_cdc(pr_nrdconta).dsemail
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'idcomissao'
                              ,pr_tag_cont => vr_tab_cdr_cdc(pr_nrdconta).idcomissao
                              ,pr_des_erro => vr_dscritic);                      
        
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nmcomissao'
                              ,pr_tag_cont => vr_nmcomissao
                              ,pr_des_erro => vr_dscritic);                      
        
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrlatitude'
                              ,pr_tag_cont => vr_tab_cdr_cdc(pr_nrdconta).nrlatitude
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrlongitude'
                              ,pr_tag_cont => vr_tab_cdr_cdc(pr_nrdconta).nrlongitude
                              ,pr_des_erro => vr_dscritic);

         GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'flgitctr'
                              ,pr_tag_cont => NVL(vr_tab_cdr_cdc(pr_nrdconta).flgitctr, 0)
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'idcidade'
                              ,pr_tag_cont => vr_tab_cdr_cdc(pr_nrdconta).idcidade
                              ,pr_des_erro => vr_dscritic);

        -- Se possui cidade cadastrada
        IF vr_tab_cdr_cdc(pr_nrdconta).idcidade > 0 THEN

          -- Busca o nome da cidade
          CADA0003.pc_busca_cidades(pr_idcidade    => vr_tab_cdr_cdc(pr_nrdconta).idcidade
                                   ,pr_cdcidade    => 0
                                   ,pr_dscidade    => ''
                                   ,pr_cdestado    => ''
                                   ,pr_infiltro    => 1 -- CETIP
                                   ,pr_intipnom    => 1 -- SEM ACENTUACAO
                                   ,pr_tab_crapmun => vr_tab_crapmun
                                   ,pr_cdcritic    => vr_cdcritic
                                   ,pr_dscritic    => vr_dscritic);
          -- Se retornou erro
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Se encontrou
          IF vr_tab_crapmun.COUNT > 0 THEN

            GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'dscidade'
                                  ,pr_tag_cont => vr_tab_crapmun(1).dscidade
                                  ,pr_des_erro => vr_dscritic);

            GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'cdestado'
                                  ,pr_tag_cont => vr_tab_crapmun(1).cdestado
                                  ,pr_des_erro => vr_dscritic);

          END IF;

        END IF; -- rw_tbsite_cooperado_cdc.idcidade > 0

        -- Se for PF busca o CNAE da tbsite_cooperado_cdc
        IF pr_inpessoa = 1 THEN
          vr_cdclcnae := vr_tab_cdr_cdc(pr_nrdconta).cdcnae;
        END IF;

      END IF; -- vr_tab_cdr_cdc.EXISTS(pr_nrdconta)

      -- Se for PJ busca o CNAE da crapass
      IF pr_inpessoa = 2 THEN
        -- Selecionar o CNAE
        OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crapass INTO vr_cdclcnae;
        CLOSE cr_crapass;
      END IF;

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'cdcnae'
                            ,pr_tag_cont => vr_cdclcnae
                            ,pr_des_erro => vr_dscritic);

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
        pr_dscritic := 'Erro geral na rotina da tela CVNCDC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_dados;

  --------------
  
  
  
  
  --------
  PROCEDURE pc_replica_cdc(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa
                          ,pr_nrdconta IN crapass.nrdconta%TYPE   --> Conta
                          ,pr_cdoperad IN crapope.cdoperad%TYPE   --> Operador
                          ,pr_idorigem IN INTEGER                 --> Origem
                          ,pr_nmdatela IN VARCHAR2                --> Nome da tela
                          ,pr_flendere IN INTEGER                 --> Flag replicar endereço
                          ,pr_fltelefo IN INTEGER                 --> Flag replicar telefone
                          ,pr_flgemail IN INTEGER                 --> Flag replicar email
                          ,pr_flnmfant IN INTEGER                 --> Flag replicar nome fantasia
                          ,pr_nmlojista OUT tbsite_cooperado_cdc.nmfantasia%type 
                          ,pr_cdcritic OUT PLS_INTEGER            --> Cód. da crítica
                          ,pr_dscritic OUT VARCHAR2) IS           --> Descrição da crítica
  BEGIN                          
  /* .............................................................................

    Programa: pc_replica_cdc
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Janeiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para replicar informações para o cdc

    Alteracoes: -----
    ..............................................................................*/                                   
    DECLARE
    
      vr_exc_erro EXCEPTION;
      
      vr_cdcritic NUMBER;
      vr_dscritic VARCHAR2(4000);
      vr_nmdcampo VARCHAR2(100);
      vr_des_erro VARCHAR2(4000);
      vr_nmlojista crapass.nmprimtl%type;
  
      vr_info_cdc typ_reg_info_cdc;
      vr_tab_cdr_cdc typ_tab_cdr_cdc;
      
      -- Buscar dados da filial
      CURSOR cr_cooperado_cdc(pr_cdcooper IN crapcop.cdcooper%TYPE
                             ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT t.idcooperado_cdc
              ,t.cdcnae
          FROM tbsite_cooperado_cdc t
         WHERE t.cdcooper = pr_cdcooper
           AND t.nrdconta = pr_nrdconta
           AND t.idmatriz IS NULL;
      rw_cooperado_cdc cr_cooperado_cdc%ROWTYPE;
      
      -- Buscar cooperado
      CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ass.*
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
    BEGIN
      -- Sera o modulo de execucao
      GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_CVNCDC'
                                ,pr_action => 'TELA_ATENDA_CVNCDC.pc_replica_cdc');

      
      -- Buscar cooperado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      
      IF cr_crapass%NOTFOUND THEN
        -- Fechar cursor
        CLOSE cr_crapass;
        -- Gerar crítica
        vr_cdcritic := 9;
        vr_dscritic := '';
        -- Levantar exceção
        RAISE vr_exc_erro;
      END IF;
      
      -- Buscar filial CDC
      OPEN cr_cooperado_cdc(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta);
      FETCH cr_cooperado_cdc INTO rw_cooperado_cdc;
          
      -- Carrega os dados
      -- faria 1
      pc_carrega_dados(pr_cdcooper        => pr_cdcooper
                      ,pr_nrdconta        => pr_nrdconta
                      ,pr_idmatriz        => 0
                      ,pr_idcooperado_cdc => rw_cooperado_cdc.idcooperado_cdc
                      ,pr_tab_cdr_cdc     => vr_tab_cdr_cdc
                      ,pr_cdcritic        => vr_cdcritic
                      ,pr_dscritic        => vr_dscritic);

      -- Se houve retorno de erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
  
      -- Se replica endereço
      IF pr_flendere = 1 THEN
        -- Busca informações do endereço do cooperado
        -- faria 2
        pc_busca_endereco_cdc(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_info_cdc => vr_info_cdc
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
                             
        -- Se retornou alguma crítica   
        IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      ELSE
        -- Utiliza informações anteriores
        vr_info_cdc.dsendere := vr_tab_cdr_cdc(pr_nrdconta).dslogradouro;
        vr_info_cdc.nrendere := vr_tab_cdr_cdc(pr_nrdconta).nrendereco;
        vr_info_cdc.complend := vr_tab_cdr_cdc(pr_nrdconta).dscomplemento;
        vr_info_cdc.nmbairro := vr_tab_cdr_cdc(pr_nrdconta).nmbairro;
        vr_info_cdc.nrcepend := vr_tab_cdr_cdc(pr_nrdconta).nrcep;
        vr_info_cdc.idcidade := vr_tab_cdr_cdc(pr_nrdconta).idcidade;

      END IF;
      
      -- Se replica telefone
      IF pr_fltelefo = 1 THEN
        -- Busca telefone do cooperado
        -- faria 3
        pc_busca_telefone_cdc(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_info_cdc => vr_info_cdc
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
                             
        -- Se retornou alguma crítica   
        IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      ELSE
        -- Utiliza informações anteriores
        vr_info_cdc.nrtelefo := vr_tab_cdr_cdc(pr_nrdconta).dstelefone;
      END IF;
      
      -- Se replica email
      IF pr_flgemail = 1 THEN
        -- Busca email do cooperado
        -- faria 4
        pc_busca_email_cdc(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                           ,pr_info_cdc => vr_info_cdc
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);
                             
        -- Se retornou alguma crítica   
        IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      ELSE
        -- Utiliza informações anteriores
        vr_info_cdc.dsdemail := vr_tab_cdr_cdc(pr_nrdconta).dsemail;
      END IF;

      -- Se replica nome fantasia
      IF pr_flnmfant = 1 OR vr_tab_cdr_cdc(pr_nrdconta).nmfantasia IS NULL THEN
        -- Busca nome fantasia do cooperado
        -- faria 5
        pc_busca_nmfansia_cdc(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                              ,pr_info_cdc => vr_info_cdc
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
                             
        -- Se retornou alguma crítica   
        IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      ELSE
        -- Utiliza informações anteriores
        vr_info_cdc.nmfansia := vr_tab_cdr_cdc(pr_nrdconta).nmfantasia;
      END IF;

      -- faria BEGIN
      -- Seta as variaveis
      vr_cdcnae     := (CASE WHEN rw_crapass.inpessoa = 1 AND 0 = 0 THEN rw_cooperado_cdc.cdcnae ELSE NULL END);
      vr_nrcep      := (CASE WHEN vr_info_cdc.nrcepend = 0      THEN NULL ELSE vr_info_cdc.nrcepend      END);
      vr_idcidade   := (CASE WHEN vr_info_cdc.idcidade = 0   THEN NULL ELSE vr_info_cdc.idcidade   END);
      vr_nrendereco := (CASE WHEN vr_info_cdc.nrendere = 0 THEN NULL ELSE vr_info_cdc.nrendere END);
      
      -- Carrega os dados
      pc_carrega_dados(pr_cdcooper        => pr_cdcooper
                      ,pr_nrdconta        => pr_nrdconta
                      ,pr_idmatriz        => 0
                      ,pr_idcooperado_cdc => nvl(rw_cooperado_cdc.idcooperado_cdc,0)
                      ,pr_tab_cdr_cdc     => vr_tab_cdr_cdc
                      ,pr_cdcritic        => vr_cdcritic
                      ,pr_dscritic        => vr_dscritic);

      vr_nmlojista := vr_info_cdc.nmfansia;
      IF rw_crapass.nrdconta in (7850166,1936450,2196328,2197367,6204090) THEN
        vr_nmlojista := rw_crapass.nmprimtl;
      END IF;

      pr_nmlojista := vr_nmlojista;
      
      -- Grava os demais dados
      UPDATE tbsite_cooperado_cdc t
         SET t.nmfantasia      = vr_nmlojista
            ,t.cdcnae          = vr_cdcnae
            ,t.dslogradouro    = vr_info_cdc.dsendere
            ,t.dscomplemento   = vr_info_cdc.complend
            ,t.idcidade        = vr_info_cdc.idcidade
            ,t.nmbairro        = vr_info_cdc.nmbairro
            ,t.nrendereco      = vr_info_cdc.nrendere
            ,t.nrcep           = vr_info_cdc.nrcepend
            ,t.dstelefone      = vr_info_cdc.nrtelefo
            ,t.dsemail         = vr_info_cdc.dsdemail
            ,t.nrlatitude      = vr_tab_cdr_cdc(pr_nrdconta).nrlatitude 
            ,t.nrlongitude     = vr_tab_cdr_cdc(pr_nrdconta).nrlongitude
            ,t.idcomissao      = vr_tab_cdr_cdc(pr_nrdconta).idcomissao
       WHERE t.idcooperado_cdc = nvl(rw_cooperado_cdc.idcooperado_cdc,0);               
                      
      -- necessário fazer update
      /*pc_grava_dados(pr_cdcooper => pr_cdcooper
                    ,pr_cdoperad => pr_cdoperad
                    ,pr_idorigem => pr_idorigem
                    ,pr_nmdatela => pr_nmdatela
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_inpessoa => rw_crapass.inpessoa
                    ,pr_idmatriz => 0
                    ,pr_idcooperado_cdc => nvl(rw_cooperado_cdc.idcooperado_cdc,0)
                    ,pr_flgconve => vr_tab_cdr_cdc(pr_nrdconta).flgconve
                    ,pr_dtinicon => to_char(vr_tab_cdr_cdc(pr_nrdconta).dtinicon, 'DD/MM/RRRR')
                    ,pr_inmotcan => vr_tab_cdr_cdc(pr_nrdconta).inmotcan
                    ,pr_dtcancon => to_char(vr_tab_cdr_cdc(pr_nrdconta).dtcancon, 'DD/MM/RRRR')
                    ,pr_dsmotcan => vr_tab_cdr_cdc(pr_nrdconta).dsmotcan
                    ,pr_dtrencon => to_char(vr_tab_cdr_cdc(pr_nrdconta).dtrencon, 'DD/MM/RRRR') 
                    ,pr_dttercon => to_char(vr_tab_cdr_cdc(pr_nrdconta).dttercon, 'DD/MM/RRRR')
                    ,pr_nmfantasia => vr_info_cdc.nmfansia
                    ,pr_cdcnae => rw_cooperado_cdc.cdcnae
                    ,pr_dslogradouro => vr_info_cdc.dsendere
                    ,pr_dscomplemento => vr_info_cdc.complend
                    ,pr_nrendereco => vr_info_cdc.nrendere
                    ,pr_nmbairro => vr_info_cdc.nmbairro
                    ,pr_nrcep => vr_info_cdc.nrcepend
                    ,pr_idcidade => vr_info_cdc.idcidade
                    ,pr_dstelefone => vr_info_cdc.nrtelefo
                    ,pr_dsemail => vr_info_cdc.dsdemail
                    ,pr_nrlatitude => vr_tab_cdr_cdc(pr_nrdconta).nrlatitude
                    ,pr_nrlongitude => vr_tab_cdr_cdc(pr_nrdconta).nrlongitude
                    ,pr_idcomissao => vr_tab_cdr_cdc(pr_nrdconta).idcomissao
                    ,pr_flgitctr   => vr_tab_cdr_cdc(pr_nrdconta).flgitctr
                    ,pr_cdcritic => vr_cdcritic
                    ,pr_dscritic => vr_dscritic
                    ,pr_nmdcampo => vr_nmdcampo
                    ,pr_des_erro => vr_des_erro);*/

      -- Se houver alguma crítica
      IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    EXCEPTION                  
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CVNCDC: ' || SQLERRM;
				
		END;
	END pc_replica_cdc;
	
  
begin

  /*INICIO DE TUDO -- FARIA*/
  -- Test statements here

  FOR rw_lojista IN cr_lojista LOOP

    vr_nmlojista_old :=  rw_lojista.nmfantasia;
    pc_replica_cdc (pr_cdcooper => rw_lojista.cdcooper
                   ,pr_nrdconta => rw_lojista.nrdconta
                   ,pr_cdoperad => 1
                   ,pr_idorigem => 5
                   ,pr_nmdatela => 'ATENDA'
                   ,pr_flendere => 1
                   ,pr_fltelefo => 1
                   ,pr_flgemail => 1
                   ,pr_flnmfant => 1
                   ,pr_nmlojista => vr_nmlojista
                   ,pr_cdcritic => vr_cdcritic -- out
                   ,pr_dscritic => vr_dscritic); -- out

    IF vr_cdcritic >0 OR vr_dscritic IS NOT NULL THEN
      null;
      dbms_output.put_line ('Erro pc_replica_cdc: ' || vr_dscritic);
    ELSE
      null;
      dbms_output.put_line ('Sucesso! Conta:' || rw_lojista.cdcooper || ' - ' || rw_lojista.nrdconta  || ' nome antes: ' || vr_nmlojista_old || ' - nome novo: ' || vr_nmlojista );
    END IF;
      
    -- faria agora ele cria o usuario               
    --- verifica criacao do usuario
    for rw_usuario in cr_usuario (rw_lojista.cdcooper
                                 ,rw_lojista.nrdconta) loop

      --dbms_output.put_line ('Passei: ' || rw_usuario.idcooperado_cdc);
      -- criar controle para nao gerar mais de um login igual
      OPEN cr_valida  (rw_usuario.login);
      FETCH cr_valida INTO rw_valida;
      
      IF cr_valida%NOTFOUND THEN
      
        begin
          insert into tbepr_cdc_usuario (dslogin, dssenha, flgadmin)
          values (rw_usuario.login, rw_usuario.senha, 1)
          returning idusuario into vr_idusuario;
          
          insert into tbepr_cdc_vendedor (nmvendedor, nrcpf, dsemail, idcooperado_cdc)
          values (vr_nmlojista, rw_usuario.login, rw_usuario.dsemail, rw_usuario.idcooperado_cdc)
          returning idvendedor into vr_idvendedor;
          
          insert into tbepr_cdc_usuario_vinculo (idusuario,idcooperado_cdc,idvendedor )
          values (vr_idusuario, rw_usuario.idcooperado_cdc, vr_idvendedor);
          
          --commit;
          dbms_output.put_line ('Vendedor criado ' || vr_idvendedor);
          rollback;
          
        exception
          when others then
            dbms_output.put_line ('EROO: ' || SQLERRM);
            null;
        end;
      ELSE
        null;
        dbms_output.put_line ('Usuário já existe para esse CPF/CNPJ: ' || rw_usuario.login);
      END IF;
      CLOSE cr_valida;
      
      /* ATUALIZA NOME DO VENDEDOR*/
      OPEN cr_vendedor (rw_lojista.cdcooper
                       ,rw_lojista.nrdconta);
      FETCH cr_vendedor INTO rw_vendedor;

      IF cr_vendedor%FOUND THEN

        OPEN cr_valida_adm (rw_vendedor.idvendedor);
        FETCH cr_valida_adm INTO rw_valida_adm;

        -- se for ADM entao atualiza
        IF cr_valida_adm%FOUND THEN

          begin
            update tbepr_cdc_vendedor v
               set nmvendedor = vr_nmlojista
             where v.idvendedor = rw_valida_adm.idvendedor;
            dbms_output.put_line ('Atualizei o nome: ' || vr_nmlojista);
            --commit;
          exception
            when others then
              dbms_output.put_line ('EROO: ' || SQLERRM);
              null;
          end;
        ELSE
          null;
          dbms_output.put_line ('Usuário nao existe para a conta');
        END IF;
        CLOSE cr_valida_adm;
      END IF; -- cr_vendedor%FOUND 
      CLOSE cr_vendedor;
      /* ATUALIZA NOME DO VENDEDOR*/    
    end loop; 

    commit;

    dbms_output.put_line ('---------------------------');

  END LOOP;
  
end;