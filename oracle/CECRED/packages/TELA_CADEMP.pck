create or replace package cecred.TELA_CADEMP is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_CADEMP
  --  Sistema  : Rotinas focando nas funcionalidades da tela CADEMP
  --  Sigla    : TELA
  --  Autor    : CIS Corporate
  --  Data     : Setembro/2018.                   Ultima atualizacao: 12/04/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia:
  -- Objetivo  : Agrupar rotinas que venham a ser utilizadas pela tela CADEMP.
  --
  -- Alteração : 11/09/2018 Criação da package (CIS Corporate)
  --             12/04/2019 P437 - Consignado - Incusão do campo nrdddemp - Josiane stiehler - AMcom             
  --
  ---------------------------------------------------------------------------------------------------------------


  /* Tipo que compreende o registro da tab. temporaria tt-crapemp */
  TYPE typ_reg_dados_emp IS RECORD (
    inavscot crapemp.inavscot%TYPE,
    inavsemp crapemp.inavsemp%TYPE,
    inavsppr crapemp.inavsppr%TYPE,
    inavsden crapemp.inavsden%TYPE,
    inavsseg crapemp.inavsseg%TYPE,
    inavssau crapemp.inavssau%TYPE,
    cdempres crapemp.cdempres%TYPE,
    nmresemp crapemp.nmresemp%TYPE,
    nmextemp crapemp.nmextemp%TYPE,
    cdcooper crapemp.cdcooper%TYPE,
    tpdebemp crapemp.tpdebemp%TYPE,
    tpdebcot crapemp.tpdebcot%TYPE,
    tpdebppr crapemp.tpdebppr%TYPE,
    cdempfol crapemp.cdempfol%TYPE,
    dtavscot crapemp.dtavscot%TYPE,
    dtavsemp crapemp.dtavsemp%TYPE,
    dtavsppr crapemp.dtavsppr%TYPE,
    flgpagto crapemp.flgpagto%TYPE,
    tpconven crapemp.tpconven%TYPE,
    cdufdemp crapemp.cdufdemp%TYPE,
    dscomple crapemp.dscomple%TYPE,
    dsdemail crapemp.dsdemail%TYPE,
    dsendemp crapemp.dsendemp%TYPE,
    dtfchfol crapemp.dtfchfol%TYPE,
    indescsg crapemp.indescsg%TYPE,
    nmbairro crapemp.nmbairro%TYPE,
    nmcidade crapemp.nmcidade%TYPE,
    nrcepend crapemp.nrcepend%TYPE,
    nrdocnpj crapemp.nrdocnpj%TYPE,
    nrendemp crapemp.nrendemp%TYPE,
    nrfaxemp crapemp.nrfaxemp%TYPE,
    nrfonemp crapemp.nrfonemp%TYPE,
    flgarqrt crapemp.flgarqrt%TYPE,
    flgvlddv crapemp.flgvlddv%TYPE,
    idtpempr crapemp.idtpempr%TYPE,
    nrdconta crapemp.nrdconta%TYPE,
    nmcontat crapemp.nmcontat%TYPE,
    flgpgtib crapemp.flgpgtib%TYPE,
    cdcontar crapemp.cdcontar%TYPE,
    vllimfol crapemp.vllimfol%TYPE,
    nmextttl crapass.nmprimtl%TYPE,
    dscontar crapcfp.dscontar%TYPE,
    dtultufp crapemp.dtultufp%TYPE,
    dtlimdeb crapemp.dtlimdeb%TYPE,
    tpmodcon tbcadast_empresa_consig.tpmodconvenio%TYPE,
    flnecont tbcadast_empresa_consig.indconsignado%TYPE,
    nrdddemp crapemp.nrdddemp%TYPE
  );

  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_dados_emp IS TABLE OF typ_reg_dados_emp INDEX BY BINARY_INTEGER;

  PROCEDURE pc_busca_empresa_web(pr_nmextemp IN crapemp.nmextemp%TYPE DEFAULT NULL --> Nome da empresa
                                    ,pr_nmresemp IN crapemp.nmresemp%TYPE DEFAULT NULL --> Nome reduzido da empresa
                                    ,pr_nrdocnpj IN crapemp.nrdocnpj%TYPE DEFAULT NULL   --> Numero de CNPJ
                                    ,pr_cdempres IN crapemp.cdempres%TYPE DEFAULT -1   --> Codigo da empresa (-1 todas)
                                    ,pr_cddopcao IN INTEGER                        --> Opção da Tela 1-Empresa
                                    ,pr_nriniseq IN INTEGER DEFAULT 0                  --> Paginação - Inicio de sequencia
                                    ,pr_nrregist IN INTEGER DEFAULT 0                  --> Paginação - Número de registros
                                    ,pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                                     --------> OUT <--------
                                    ,pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype                 --> arquivo de retorno do xml
                                    ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2                          --> Erros do processo
                                    );
  
  PROCEDURE pc_busca_dados_consig_fis (-- campos padrões  
                                       pr_xmllog             IN VARCHAR2              --> XML com informacoes de LOG
                                      ,pr_cdcritic          OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic          OUT VARCHAR2              --> Descricao da critica
                                      ,pr_retxml             IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro          OUT VARCHAR2              --> Erros do processo
                                      );                                    
end TELA_CADEMP; 
/
create or replace package body cecred.TELA_CADEMP is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_CADEMP
  --  Sistema  : Rotinas focando nas funcionalidades da tela CADEMP
  --  Sigla    : TELA
  --  Autor    : CIS Corporate
  --  Data     : Setembro/2018.                   Ultima atualizacao: 12/04/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia:
  -- Objetivo  : Agrupar rotinas que venham a ser utilizadas pela tela CADEMP.
  --
  -- Alteração : 11/09/2018 Criação da package (CIS Corporate)
  --             29/03/2019 Criação da rotina pc_busca_dados_emp_fis
  --             12/04/2019 P437 - Consignado - Incusão do campo nrdddemp - Josiane stiehler - AMcom             
  ---------------------------------------------------------------------------------------------------------------


    PROCEDURE pc_busca_empresa (pr_cdcooper IN crapemp.cdcooper%TYPE                 --> Código da Cooperativa
                                 ,pr_nmextemp IN crapemp.nmextemp%TYPE DEFAULT NULL    --> Nome da empresa
                                 ,pr_nmresemp IN crapemp.nmresemp%TYPE DEFAULT NULL    --> Nome reduzido da empresa
								 ,pr_nrdocnpj IN crapemp.nrdocnpj%TYPE DEFAULT NULL   --> Numero de CNPJ
                                 ,pr_cdempres IN crapemp.cdempres%TYPE DEFAULT -1      --> Codigo da empresa (-1 todas)
                                 ,pr_cddopcao IN INTEGER              --> Opção da Tela 1-Empres
                                 ,pr_idorigem IN INTEGER                               --> Identificador Origem Chamada
                                 ,pr_nriniseq IN INTEGER DEFAULT 0                     --> Paginação - Inicio de sequencia
                                 ,pr_nrregist IN INTEGER DEFAULT 0                     --> Paginação - Número de registros
                                 --> OUT <--
                                 ,pr_qtregist OUT integer                              --> Quantidade de registros encontrados
                                 ,pr_tab_dados_emp OUT typ_tab_dados_emp --> Tabela de retorno
                                 ,pr_cdcritic OUT PLS_INTEGER                          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2                             --> Descrição da crítica
                                 ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_busca_empresa
      Sistema  : Ayllos
      Sigla    : CADEMP
      Autor    : CIS Corporate
      Data     : Setembro/2018

      Objetivo  : Busca os dados da empresa para cademp

      Alteração : 11/09/2018 - Criação (CIS Corporate)
                  12/04/2019 P437 - Consignado - Incusão do campo nrdddemp - Josiane stiehler - AMcom             

    ----------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
      CURSOR cr_cademp IS
      SELECT tmp.*
        FROM (
        SELECT row_number() OVER(ORDER BY p.cdempres) /*rownum*/ numero_linha,
        p.inavscot,
        p.inavsemp,
        p.inavsppr,
        p.inavsden,
        p.inavsseg,
        p.inavssau,
        p.cdempres,
        p.nmresemp,
        p.nmextemp,
        p.cdcooper,
        p.tpdebemp,
        p.tpdebcot,
        p.tpdebppr,
        p.cdempfol,
        p.dtavscot,
        p.dtavsemp,
        p.dtavsppr,
        p.flgpagto,
        p.tpconven,
        p.cdufdemp,
        p.dscomple,
        p.dsdemail,
        p.dsendemp,
        p.dtfchfol,
        p.indescsg,
        p.nmbairro,
        p.nmcidade,
        p.nrcepend,
        p.nrdocnpj,
        p.nrendemp,
        p.nrfaxemp,
        p.nrdddemp,
        p.nrfonemp,
        p.flgarqrt,
        p.flgvlddv,
        p.idtpempr,
              (SELECT pas.nmprimtl FROM crapass pas WHERE pas.cdcooper = p.cdcooper AND pas.nrdconta = p.nrdconta) nmextttl, --> Tabela Nova CONSIG.
              (SELECT pcf.dscontar FROM crapcfp pcf WHERE pcf.cdcooper = p.cdcooper AND pcf.cdcontar = p.cdcontar) dscontar, --> Tabela Nova CONSIG.
        p.nrdconta,
        p.nmcontat,
        p.flgpgtib,
        p.cdcontar,
        p.vllimfol,
        (SELECT tec.indconsignado FROM tbcadast_empresa_consig tec WHERE tec.cdcooper = p.cdcooper AND tec.cdempres = p.cdempres AND tec.indconsignado=1) indconsignado, --> Tabela Nova CONSIG.
        p.dtultufp,
        p.dtlimdeb,
        (SELECT tec.tpmodconvenio FROM tbcadast_empresa_consig tec WHERE tec.cdcooper = p.cdcooper AND tec.cdempres = p.cdempres AND tec.indconsignado=1) tpmodconvenio --> Tabela Nova CONSIG.
          FROM crapemp p
         WHERE p.cdcooper = pr_cdcooper
           AND CASE
                 WHEN pr_cdempres >= 0 AND p.cdempres = pr_cdempres THEN 1
                 WHEN pr_cdempres = -1 THEN
                   CASE
                     WHEN (pr_nmextemp IS NULL AND pr_nmresemp IS NULL AND pr_nrdocnpj IS NULL) THEN 1
                     WHEN (pr_nrdocnpj IS NOT NULL AND (p.nrdocnpj = pr_nrdocnpj)) THEN 1
                     WHEN (pr_nmextemp IS NOT NULL AND (upper(p.nmextemp) LIKE '%'||  upper(pr_nmextemp) ||'%')) THEN 1
                     WHEN (pr_nmresemp IS NOT NULL AND (upper(p.nmresemp) LIKE '%'||  upper(pr_nmresemp) ||'%')) THEN 1
                     ELSE 0
                   END
                 ELSE 0
               END = 1
           ) tmp
      WHERE  CASE WHEN (pr_nriniseq + pr_nrregist) = 0 THEN 1
                  WHEN (pr_nriniseq + pr_nrregist) > 0 AND
                       numero_linha >= pr_nriniseq AND numero_linha < (pr_nriniseq + pr_nrregist) THEN 1
                  ELSE 0
             END = 1;

      rw_cademp cr_cademp%ROWTYPE;

      /* Tratamento de erro */
      vr_exc_erro EXCEPTION;

      /* Descrição e código da critica */
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      vr_idtab number;
    BEGIN

      IF (pr_cdempres < 0) THEN
          IF (pr_nmresemp = '' AND pr_nmextemp = '' AND pr_idorigem = 5) THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Campo de pesquisa deve ser informado!';
                RAISE vr_exc_erro;
          END IF;
      END IF;

      -- Se encontrou por Código ou por Nome Fantasia ou por Razão Social, preencher a tab de retorno.
      OPEN cr_cademp;
      LOOP
        FETCH cr_cademp INTO rw_cademp;
        EXIT WHEN cr_cademp%NOTFOUND;

        vr_idtab := pr_tab_dados_emp.count + 1;

    pr_tab_dados_emp(vr_idtab).inavscot := rw_cademp.inavscot;
    pr_tab_dados_emp(vr_idtab).inavsemp := rw_cademp.inavsemp;
    pr_tab_dados_emp(vr_idtab).inavsppr := rw_cademp.inavsppr;
    pr_tab_dados_emp(vr_idtab).inavsden := rw_cademp.inavsden;
    pr_tab_dados_emp(vr_idtab).inavsseg := rw_cademp.inavsseg;
    pr_tab_dados_emp(vr_idtab).inavssau := rw_cademp.inavssau;
    pr_tab_dados_emp(vr_idtab).cdempres := rw_cademp.cdempres;
    pr_tab_dados_emp(vr_idtab).nmresemp := rw_cademp.nmresemp;
    pr_tab_dados_emp(vr_idtab).nmextemp := rw_cademp.nmextemp;
    pr_tab_dados_emp(vr_idtab).cdcooper := rw_cademp.cdcooper;
    pr_tab_dados_emp(vr_idtab).tpdebemp := rw_cademp.tpdebemp;
    pr_tab_dados_emp(vr_idtab).tpdebcot := rw_cademp.tpdebcot;
    pr_tab_dados_emp(vr_idtab).tpdebppr := rw_cademp.tpdebppr;
    pr_tab_dados_emp(vr_idtab).cdempfol := rw_cademp.cdempfol;
    pr_tab_dados_emp(vr_idtab).dtavscot := rw_cademp.dtavscot;
    pr_tab_dados_emp(vr_idtab).dtavsemp := rw_cademp.dtavsemp;
    pr_tab_dados_emp(vr_idtab).dtavsppr := rw_cademp.dtavsppr;
    pr_tab_dados_emp(vr_idtab).flgpagto := rw_cademp.flgpagto;
    pr_tab_dados_emp(vr_idtab).tpconven := rw_cademp.tpconven;
    pr_tab_dados_emp(vr_idtab).cdufdemp := rw_cademp.cdufdemp;
    pr_tab_dados_emp(vr_idtab).dscomple := rw_cademp.dscomple;
    pr_tab_dados_emp(vr_idtab).dsdemail := rw_cademp.dsdemail;
    pr_tab_dados_emp(vr_idtab).dsendemp := rw_cademp.dsendemp;
    pr_tab_dados_emp(vr_idtab).dtfchfol := rw_cademp.dtfchfol;
    pr_tab_dados_emp(vr_idtab).indescsg := rw_cademp.indescsg;
    pr_tab_dados_emp(vr_idtab).nmbairro := rw_cademp.nmbairro;
    pr_tab_dados_emp(vr_idtab).nmcidade := rw_cademp.nmcidade;
    pr_tab_dados_emp(vr_idtab).nrcepend := rw_cademp.nrcepend;
    pr_tab_dados_emp(vr_idtab).nrdocnpj := rw_cademp.nrdocnpj;
    pr_tab_dados_emp(vr_idtab).nrendemp := rw_cademp.nrendemp;
    pr_tab_dados_emp(vr_idtab).nrfaxemp := rw_cademp.nrfaxemp;
    pr_tab_dados_emp(vr_idtab).nrfonemp := rw_cademp.nrfonemp;
    pr_tab_dados_emp(vr_idtab).flgarqrt := rw_cademp.flgarqrt;
    pr_tab_dados_emp(vr_idtab).flgvlddv := rw_cademp.flgvlddv;
    pr_tab_dados_emp(vr_idtab).idtpempr := rw_cademp.idtpempr;
        pr_tab_dados_emp(vr_idtab).nmextttl := rw_cademp.nmextttl;
        pr_tab_dados_emp(vr_idtab).dscontar := rw_cademp.dscontar;
    pr_tab_dados_emp(vr_idtab).nrdconta := rw_cademp.nrdconta;
    pr_tab_dados_emp(vr_idtab).nmcontat := rw_cademp.nmcontat;
    pr_tab_dados_emp(vr_idtab).flgpgtib := rw_cademp.flgpgtib;
    pr_tab_dados_emp(vr_idtab).cdcontar := rw_cademp.cdcontar;
    pr_tab_dados_emp(vr_idtab).vllimfol := rw_cademp.vllimfol;
        pr_tab_dados_emp(vr_idtab).flnecont := rw_cademp.indconsignado;
    pr_tab_dados_emp(vr_idtab).dtultufp := rw_cademp.dtultufp;
    pr_tab_dados_emp(vr_idtab).dtlimdeb := rw_cademp.dtlimdeb;
        pr_tab_dados_emp(vr_idtab).tpmodcon := rw_cademp.tpmodconvenio;
    pr_tab_dados_emp(vr_idtab).nrdddemp := rw_cademp.nrdddemp;
    
        pr_qtregist := nvl(pr_qtregist,0) + 1;
      END LOOP;
      CLOSE cr_cademp;
    EXCEPTION
      WHEN vr_exc_erro THEN
        /* busca valores de critica predefinidos */
        IF NVL(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
          /* busca a descriçao da crítica baseado no código */
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro nao tratado na tela_cademp.pc_busca_empresa '|| sqlerrm;
        pr_cdcritic := 0;
    END;
  END pc_busca_empresa;

  PROCEDURE pc_busca_empresa_web(pr_nmextemp IN crapemp.nmextemp%TYPE DEFAULT NULL --> Nome da empresa
                                ,pr_nmresemp IN crapemp.nmresemp%TYPE DEFAULT NULL --> Nome reduzido da empresa
								            	  ,pr_nrdocnpj IN crapemp.nrdocnpj%TYPE DEFAULT NULL --> Numero de CNPJ
                                ,pr_cdempres IN crapemp.cdempres%TYPE DEFAULT -1   --> Codigo da empresa (-1 todas)
                                ,pr_cddopcao IN INTEGER                            --> Opção da Tela 1-Empresa
                                ,pr_nriniseq IN INTEGER DEFAULT 0                  --> Paginação - Inicio de sequencia
                                ,pr_nrregist IN INTEGER DEFAULT 0                  --> Paginação - Número de registros
                                ,pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                                 --------> OUT <--------
                                ,pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype                 --> arquivo de retorno do xml
                                ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2                          --> Erros do processo
                                ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_busca_empresa_web
      Sistema  : Ayllos
      Sigla    : CADEMP
      Autor    : CIS Corporate
      Data     : Setembro/2018

      Objetivo  : Busca os dados da empresa

      Alteração : 11/09/2018 - Criação (CIS Corporate)

    ----------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
      /* Tratamento de erro */
      vr_exc_erro EXCEPTION;

      /* Descrição e código da critica */
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      -- variaveis de retorno
      vr_tab_dados_emp     typ_tab_dados_emp;
      vr_qtregist         number;

      -- variaveis de entrada vindas no xml
      vr_cdcooper integer;
      vr_cdoperad varchar2(100);
      vr_nmdatela varchar2(100);
      vr_nmeacao  varchar2(100);
      vr_cdagenci varchar2(100);
      vr_nrdcaixa varchar2(100);
      vr_idorigem varchar2(100);

      -- variáveis para armazenar as informaçoes em xml
      vr_des_xml        clob;
      vr_texto_completo varchar2(32600);
      vr_index          varchar2(100);

      procedure pc_escreve_xml( pr_des_dados in varchar2
                              , pr_fecha_xml in boolean default false
                              ) is
      begin
          gene0002.pc_escreve_xml( vr_des_xml
                                 , vr_texto_completo
                                 , pr_des_dados
                                 , pr_fecha_xml );
      end;

    BEGIN
      pr_nmdcampo := NULL;
      pr_des_erro := 'OK';
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);

      tela_cademp.pc_busca_empresa(pr_cdcooper => vr_cdcooper
                                              ,pr_nmextemp => pr_nmextemp
                                              ,pr_nmresemp => pr_nmresemp
                                              ,pr_nrdocnpj => pr_nrdocnpj
                                              ,pr_cdempres => pr_cdempres
                                              ,pr_cddopcao => pr_cddopcao
                                              ,pr_idorigem => vr_idorigem
                                              ,pr_nriniseq => pr_nriniseq
                                              ,pr_nrregist => pr_nrregist
                                              ,pr_qtregist => vr_qtregist
                                              ,pr_tab_dados_emp => vr_tab_dados_emp
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic);

      IF (nvl(vr_cdcritic,0) <> 0 OR  vr_dscritic IS NOT NULL) THEN
          raise vr_exc_erro;
      END IF;

      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;

      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados qtregist="' || vr_qtregist ||'" >');

      -- ler os registros de consignado e incluir no xml
      vr_index := vr_tab_dados_emp.first;
      while vr_index is not null loop
            pc_escreve_xml('<inf>'||
        '<inavscot>'|| vr_tab_dados_emp(vr_index).inavscot ||'</inavscot>'||
        '<inavsemp>'|| vr_tab_dados_emp(vr_index).inavsemp ||'</inavsemp>'||
        '<inavsppr>'|| vr_tab_dados_emp(vr_index).inavsppr ||'</inavsppr>'||
        '<inavsden>'|| vr_tab_dados_emp(vr_index).inavsden ||'</inavsden>'||
        '<inavsseg>'|| vr_tab_dados_emp(vr_index).inavsseg ||'</inavsseg>'||
        '<inavssau>'|| vr_tab_dados_emp(vr_index).inavssau ||'</inavssau>'||
        '<cdempres>'|| vr_tab_dados_emp(vr_index).cdempres ||'</cdempres>'||
        '<nmresemp>'|| vr_tab_dados_emp(vr_index).nmresemp ||'</nmresemp>'||
        '<nmextemp>'|| vr_tab_dados_emp(vr_index).nmextemp ||'</nmextemp>'||
        '<cdcooper>'|| vr_tab_dados_emp(vr_index).cdcooper ||'</cdcooper>'||
        '<tpdebemp>'|| vr_tab_dados_emp(vr_index).tpdebemp ||'</tpdebemp>'||
        '<tpdebcot>'|| vr_tab_dados_emp(vr_index).tpdebcot ||'</tpdebcot>'||
        '<tpdebppr>'|| vr_tab_dados_emp(vr_index).tpdebppr ||'</tpdebppr>'||
        '<cdempfol>'|| vr_tab_dados_emp(vr_index).cdempfol ||'</cdempfol>'||
        '<dtavscot>'|| to_char(vr_tab_dados_emp(vr_index).dtavscot,'DD/MM/RRRR') ||'</dtavscot>'||
        '<dtavsemp>'|| to_char(vr_tab_dados_emp(vr_index).dtavsemp,'DD/MM/RRRR') ||'</dtavsemp>'||
        '<dtavsppr>'|| to_char(vr_tab_dados_emp(vr_index).dtavsppr,'DD/MM/RRRR') ||'</dtavsppr>'||
        '<flgpagto>'|| vr_tab_dados_emp(vr_index).flgpagto ||'</flgpagto>'||
        '<tpconven>'|| vr_tab_dados_emp(vr_index).tpconven ||'</tpconven>'||
        '<cdufdemp>'|| upper(vr_tab_dados_emp(vr_index).cdufdemp) ||'</cdufdemp>'||
        '<dscomple>'|| vr_tab_dados_emp(vr_index).dscomple ||'</dscomple>'||
        '<dsdemail>'|| vr_tab_dados_emp(vr_index).dsdemail ||'</dsdemail>'||
        '<dsendemp>'|| vr_tab_dados_emp(vr_index).dsendemp ||'</dsendemp>'||
        '<dtfchfol>'|| vr_tab_dados_emp(vr_index).dtfchfol ||'</dtfchfol>'||
        '<indescsg>'|| vr_tab_dados_emp(vr_index).indescsg ||'</indescsg>'||
        '<nmbairro>'|| vr_tab_dados_emp(vr_index).nmbairro ||'</nmbairro>'||
        '<nmcidade>'|| vr_tab_dados_emp(vr_index).nmcidade ||'</nmcidade>'||
        '<nrcepend>'|| vr_tab_dados_emp(vr_index).nrcepend ||'</nrcepend>'||
        '<nrdocnpj>'|| vr_tab_dados_emp(vr_index).nrdocnpj ||'</nrdocnpj>'||
        '<nrendemp>'|| vr_tab_dados_emp(vr_index).nrendemp ||'</nrendemp>'||
        '<nrfaxemp>'|| vr_tab_dados_emp(vr_index).nrfaxemp ||'</nrfaxemp>'||
        '<nrfonemp>'|| vr_tab_dados_emp(vr_index).nrfonemp ||'</nrfonemp>'||
        '<flgarqrt>'|| vr_tab_dados_emp(vr_index).flgarqrt ||'</flgarqrt>'||
        '<flgvlddv>'|| vr_tab_dados_emp(vr_index).flgvlddv ||'</flgvlddv>'||
        '<idtpempr>'|| vr_tab_dados_emp(vr_index).idtpempr ||'</idtpempr>'||
        '<nmextttl>'|| vr_tab_dados_emp(vr_index).nmextttl ||'</nmextttl>'||
        '<dscontar>'|| vr_tab_dados_emp(vr_index).dscontar ||'</dscontar>'||
        '<nrdconta>'|| vr_tab_dados_emp(vr_index).nrdconta ||'</nrdconta>'||
        '<nmcontat>'|| vr_tab_dados_emp(vr_index).nmcontat ||'</nmcontat>'||
        '<flgpgtib>'|| vr_tab_dados_emp(vr_index).flgpgtib ||'</flgpgtib>'||
        '<cdcontar>'|| vr_tab_dados_emp(vr_index).cdcontar ||'</cdcontar>'||
        '<vllimfol>'|| vr_tab_dados_emp(vr_index).vllimfol ||'</vllimfol>'||
        '<flnecont>'|| vr_tab_dados_emp(vr_index).flnecont ||'</flnecont>'||
        '<dtultufp>'|| to_char(vr_tab_dados_emp(vr_index).dtultufp,'DD/MM/RRRR') ||'</dtultufp>'||
        '<dtlimdeb>'|| vr_tab_dados_emp(vr_index).dtlimdeb ||'</dtlimdeb>'||
        '<tpmodcon>'|| vr_tab_dados_emp(vr_index).tpmodcon ||'</tpmodcon>'||
        '<nrdddemp>'|| vr_tab_dados_emp(vr_index).nrdddemp ||'</nrdddemp>'||
       '</inf>');
          /* buscar proximo */
          vr_index := vr_tab_dados_emp.next(vr_index);
      end loop;
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    EXCEPTION
      WHEN vr_exc_erro THEN
           /*  se foi retornado apenas código */
           IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           END IF;
           /* variavel de erro recebe erro ocorrido */
           pr_des_erro := 'NOK';
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
             -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
             pr_des_erro := 'NOK';
           /* montar descriçao de erro nao tratado */
             pr_dscritic := 'erro nao tratado na tela_cademp.pc_busca_empresa_web ' ||SQLERRM;
             -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_busca_empresa_web;

   
  PROCEDURE pc_busca_dados_consig_fis (-- campos padrões  
                                       pr_xmllog             IN VARCHAR2              --> XML com informacoes de LOG
                                      ,pr_cdcritic          OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic          OUT VARCHAR2              --> Descricao da critica
                                      ,pr_retxml             IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro          OUT VARCHAR2              --> Erros do processo
                                      ) IS

/*---------------------------------------------------------------------------------------------------------
      Programa : pc_busca_dados_emp_fis
      Sistema  : AIMARO
      Sigla    : CONSIG
      Autor    : Josiane Stiehler - AMcom Sistemas de Informação
      Data     : 29/03/2019

      Objetivo : Recebe os dados da tela cademp e lê os dados da consig e gera
                 XML com as duas informações retornando um XLM para tela CADEMP validar os dados na FIS.

      Alteração : 

    ----------------------------------------------------------------------------------------------------------*/

 BEGIN
    DECLARE
    
    /* Tratamento de erro */
    vr_exc_erro EXCEPTION;
    vr_saida    EXCEPTION;
    
    /* Descrição e código da critica */
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);

    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);

    vr_nrvencto      number;
    vr_xmlvencto     varchar2(32600);
        
    -- variáveis para armazenar as informaçoes em xml
    vr_des_xml        clob;
    vr_texto_completo varchar2(32600);
    
    vr_cdempres             crapemp.cdempres%TYPE; 
    vr_codPromotora         crapemp.cdcooper%TYPE;
    vr_codConvenio          crapemp.cdempres%TYPE;
    vr_numCNPJLoja          crapemp.nrdocnpj%TYPE;
    vr_descNomeLoja         crapemp.nmresemp%TYPE;
    vr_descRazaoLoja        crapemp.nmextemp%TYPE;
    vr_cepLogradouro        crapemp.nrcepend%TYPE;
    vr_descLogradouro       crapemp.dsendemp%TYPE;
    vr_numLogradouro        crapemp.nrendemp%TYPE;
    vr_desccompllogradouro  crapemp.dscomple%TYPE;
    vr_descBairroLogradouro crapemp.nmbairro%TYPE;
    vr_descCidadeLogradouro crapemp.nmcidade%TYPE;
    vr_ufLogradouro         crapemp.cdufdemp%TYPE;
    vr_dddLoja              varchar2(10);  ---crapemp. derá adicionada nrdddemp
    vr_telLoja              varchar2(20);
    vr_numConta             crapemp.nrdconta%TYPE;

    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    vr_datainicio VARCHAR2(20) := TO_CHAR(sysdate, 'yyyy-mm-dd') || 'T' ||
                                    to_char(sysdate, 'hh24:mi:ss');
    
    CURSOR cr_dados_consig (pr_cdcooper  IN crapemp.cdcooper%TYPE,
                            pr_cdempres  IN crapemp.cdempres%TYPE) IS
    SELECT 'GRCONV' codTransacao,
           to_char(SYSTIMESTAMP,'yyyy-mm-dd')||'T'||to_char(SYSTIMESTAMP,'hh24:mi:ss') dataHoraEnvio,
           to_char(c.dtativconsignado,'yyyy-mm-dd')||'T'||to_char(c.dtativconsignado,'hh24:mi:ss') datainicio,
           decode(c.indconsignado,0,to_char(SYSTIMESTAMP,'yyyy-mm-dd')||'T'||to_char(SYSTIMESTAMP,'hh24:mi:ss'),null) datafim,
           null descEmail,
           null descContatoLoja,  
           null numContaDigito,
           '1' tipoOperador,
           decode(c.tpmodconvenio,1,161,
                  decode(c.tpmodconvenio,2,162,
                         decode(c.tpmodconvenio,3,163,null))) tipoPadrao,
           c.idemprconsig,
           c.indconsignado,
           p.cdbcoctl codbanco,
           p.cdagectl codAgencia
     FROM crapemp e,
          tbcadast_empresa_consig c,
          crapcop p
    WHERE e.cdcooper  = c.cdcooper
      AND e.cdempres  = c.cdempres
      AND e.cdcooper  = p.cdcooper
      AND e.cdcooper  = pr_cdcooper
      AND e.cdempres  = pr_cdempres
      AND nvl(c.indconsignado,0) = 1; -- indica que é consignado

  rw_dados_consig cr_dados_consig%ROWTYPE;

  CURSOR cr_dados_vencto (pr_idemprconsig in tbcadast_emp_consig_param.idemprconsig%TYPE) IS
  SELECT to_char(SYSTIMESTAMP,'yyyy-mm-dd')||'T'||to_char(SYSTIMESTAMP,'hh24:mi:ss') dataInicioValidade,
         to_char(t.dtinclpropostade,'yyyy-mm-dd')  diaMesDe,
         to_char(t.dtinclpropostaate,'yyyy-mm-dd') diaMesAte,
         to_char(t.dtenvioarquivo,'yyyy-mm-dd')    diaMesEnvio,
         to_char(t.dtvencimento,'yyyy-mm-dd')      diaMesVencto,
         1  qtdeVenctos
    FROM tbcadast_emp_consig_param  t
   WHERE t.idemprconsig = pr_idemprconsig
   ORDER BY  t.dtinclpropostade;
   
   PROCEDURE pc_escreve_xml(pr_des_dados in varchar2
                           ,pr_fecha_xml in boolean default false
                           ) is
   BEGIN
      gene0002.pc_escreve_xml(vr_des_xml
                             ,vr_texto_completo
                             ,pr_des_dados
                             ,pr_fecha_xml );
   END;
  

   BEGIN
      pr_nmdcampo := NULL;
      pr_des_erro := 'OK';
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);

      IF (nvl(vr_cdcritic,0) <> 0 OR  
          vr_dscritic IS NOT NULL) THEN
          raise vr_exc_erro;
      END IF;

      vr_codPromotora:= vr_cdcooper;

       -- busca data movimento da cooperativa        
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat 
       INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;
      vr_datainicio := TO_CHAR(rw_crapdat.dtmvtolt, 'yyyy-mm-dd') || 'T' ||
                               to_char(sysdate, 'hh24:mi:ss');

      -- Extraindo os dados do XML que vem da tela EMP    
      vr_cdempres        := TRIM(pr_retxml.extract('/Root/dto/cdempres/text()').getstringval());      
      vr_codConvenio     := TRIM(pr_retxml.extract('/Root/dto/codconvenio/text()').getstringval());      
      vr_numCNPJLoja     := TRIM(pr_retxml.extract('/Root/dto/numcnpjloja/text()').getstringval());      
      vr_descNomeLoja    := TRIM(pr_retxml.extract('/Root/dto/descnomeloja/text()').getstringval());      
      vr_descRazaoLoja   := TRIM(pr_retxml.extract('/Root/dto/descrazaoloja/text()').getstringval());      
      vr_cepLogradouro   := TRIM(pr_retxml.extract('/Root/dto/ceplogradouro/text()').getstringval());      
      vr_descLogradouro  := TRIM(pr_retxml.extract('/Root/dto/desclogradouro/text()').getstringval());      
      vr_numLogradouro   := TRIM(pr_retxml.extract('/Root/dto/numlogradouro/text()').getstringval());      
      vr_desccompllogradouro := TRIM(pr_retxml.extract('/Root/dto/desccompllogradouro/text()').getstringval());      
      vr_descBairroLogradouro:= TRIM(pr_retxml.extract('/Root/dto/descbairrologradouro/text()').getstringval());      
      vr_descCidadeLogradouro:= TRIM(pr_retxml.extract('/Root/dto/desccidadelogradouro/text()').getstringval());      
      vr_ufLogradouro        := TRIM(pr_retxml.extract('/Root/dto/uflogradouro/text()').getstringval());      
      vr_dddLoja             := TRIM(pr_retxml.extract('/Root/dto/dddloja/text()').getstringval());      
      vr_telLoja             := TRIM(pr_retxml.extract('/Root/dto/telloja/text()').getstringval());      
      vr_numConta            := TRIM(pr_retxml.extract('/Root/dto/numConta/text()').getstringval());      

      -- retirar acentuação e caracteres especiasi
      vr_descNomeLoja        := gene0007.fn_caract_acento (pr_texto   => vr_descNomeLoja,
                                                           pr_dssubsin=> '@#$&%¹²³ªº°*!?<>/\|-().,=_',
                                                           pr_insubsti=> 1) ;
      vr_descRazaoLoja       := gene0007.fn_caract_acento (pr_texto   => vr_descRazaoLoja,
                                                           pr_dssubsin=> '@#$&%¹²³ªº°*!?<>/\|-().,=_',
                                                           pr_insubsti=> 1) ;
      vr_descLogradouro      := gene0007.fn_caract_acento (pr_texto   => vr_descLogradouro,
                                                           pr_dssubsin=> '@#$&%¹²³ªº°*!?<>/\|-().,=_',
                                                           pr_insubsti=> 1) ;
      vr_desccompllogradouro := gene0007.fn_caract_acento (pr_texto   => vr_desccompllogradouro,
                                                           pr_dssubsin=> '@#$&%¹²³ªº°*!?<>/\|-().,=_',
                                                           pr_insubsti=> 1) ;
      vr_descBairroLogradouro:= gene0007.fn_caract_acento (pr_texto   => vr_descBairroLogradouro,
                                                           pr_dssubsin=> '@#$&%¹²³ªº°*!?<>/\|-().,=_',
                                                           pr_insubsti=> 1) ;
      vr_descCidadeLogradouro:= gene0007.fn_caract_acento (pr_texto   => vr_descCidadeLogradouro,
                                                           pr_dssubsin=> '@#$&%¹²³ªº°*!?<>/\|-().,=_',
                                                           pr_insubsti=> 1) ;                    
      vr_telLoja             := trim(gene0007.fn_caract_acento (pr_texto   => vr_telLoja,
                                                           pr_dssubsin=> '@#$&%¹²³ªº°*!?<>/\|-().,=_',
                                                           pr_insubsti=> 1));                                                                            

      
      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;

      pc_escreve_xml('<?xml version="1.0"?>');
      
      OPEN cr_dados_consig(pr_cdcooper => to_number(vr_cdcooper),
                           pr_cdempres => to_number(vr_cdempres));
      LOOP
        FETCH cr_dados_consig INTO rw_dados_consig;
        EXIT WHEN cr_dados_consig%NOTFOUND;
        IF cr_dados_consig%NOTFOUND THEN
           vr_cdcritic:= 0;
           vr_dscritic:= 'Empresa nao trabalha com consignado';
           CLOSE cr_dados_consig;
           raise vr_saida;
        END IF;


        pc_escreve_xml('<dto>'||
                         '<convenioCredito>'||
                           '<conveniado>'||
                             '<identificadorReceitaFederal>'||vr_numcnpjloja||'</identificadorReceitaFederal>'||
                             '<nomeFantasiaOuAbreviado>'||vr_descnomeloja||'</nomeFantasiaOuAbreviado>'||
                             '<razaoSocialOuNome>'||vr_descrazaoloja||'</razaoSocialOuNome>'||
                             '<contaCorrente>'||
                               '<agencia>'||
                                '<codigo>'||rw_dados_consig.codagencia||'</codigo>'||
                               '</agencia>'||
                               '<banco>'||
                                 '<codigo>'||rw_dados_consig.codbanco||'</codigo>'||
                               '</banco>'||
                               '<codigoContaSemDigito>'||vr_numconta||'</codigoContaSemDigito>'||
                             '</contaCorrente>'||
                           '</conveniado>'||
                           '<cooperativa>'||
                             '<codigo>'||vr_codpromotora||'</codigo>'|| 
                           '</cooperativa>'||
                           '<dataContratacao>'||vr_datainicio||'</dataContratacao>');
        IF rw_dados_consig.datafim IS NOT NULL THEN
           pc_escreve_xml('<dataExpiracao>'||rw_dados_consig.datafim||'</dataExpiracao>');
        END IF;
        pc_escreve_xml('<numeroContrato>'||vr_codconvenio||'</numeroContrato>'|| -- codigo da empresa
                           '<tipoConveniada>'||
                             '<codigo>'||'3'||'</codigo>'||  -- 3- Consignado
                           '</tipoConveniada>'||
                         '</convenioCredito>'||
                         '<pessoaContatoEndereco>'||
                           '<CEP>'||vr_ceplogradouro||'</CEP>'||
                           '<cidade>'||
                             '<descricao>'||vr_desccidadelogradouro||'</descricao>'||
                           '</cidade>'||
                           '<nomeBairro>'||vr_descbairrologradouro||'</nomeBairro>'||
                           '<numeroLogradouro>'||vr_numlogradouro||'</numeroLogradouro>'||
                           '<tipoENomeLogradouro>'||vr_desclogradouro||'</tipoENomeLogradouro>'||
                           '<UF>'||upper(vr_uflogradouro)||'</UF>'||
                         '</pessoaContatoEndereco>'||
                         '<pessoaContatoTelefone>'||
                           '<numero>'||vr_telloja||'</numero>'||
                           '<DDD>'||vr_dddloja||'</DDD>'||
                         '</pessoaContatoTelefone>');
                         
        pc_escreve_xml('<pessoaContatoEmail>'||
                           '<enderecoEletronico>'||rw_dados_consig.descemail||'</enderecoEletronico>'||
                           '<nomeContato>'||rw_dados_consig.desccontatoloja||'</nomeContato>'||
                         '</pessoaContatoEmail>'||
                         '<credito>'||
                           '<produto>'||
                           '<codigo>'||rw_dados_consig.tipoPadrao||'</codigo>'||
                           '</produto>'||
                         '</credito>'||
                         '<sistemaTransacao>'||
                           '<tipoUsuario>'||
                            '<codigo>'||rw_dados_consig.tipoOperador|| '</codigo>'||
                           '</tipoUsuario>'||
                         '</sistemaTransacao>'||
                         '<interacaoGrafica>'||
                          '<dataAcaoUsuario>'||vr_datainicio||'</dataAcaoUsuario>'||
                        '</interacaoGrafica>'||
                        '<listaVencimentos>');

         vr_nrvencto := 0;
         vr_xmlvencto:= null;

         FOR rw_dados_vencto in cr_dados_vencto (pr_idemprconsig => rw_dados_consig.idemprconsig)
         LOOP
            vr_nrvencto:= vr_nrvencto + 1;
             vr_xmlvencto:=  vr_xmlvencto||
                             '<vencimento>'||
                               '<convenioCredito>'||
                                '<dataContratacao>'||vr_datainicio||'</dataContratacao>'||
                               '</convenioCredito>'||
                               '<configuracaoCredito>'||
                                '<tratamendoDiaNaoUtil>'||
                                 '<codigo>'||'3'||'</codigo>'|| --  Dia fixo
                                '</tratamendoDiaNaoUtil>'||
                               '</configuracaoCredito>'||
                               '<consulta>'||
                                '<tipoContagemDias>'||
                                 '<codigo>'||'2'||'</codigo>'|| --  dia do mes
                                '</tipoContagemDias>'||
                               '</consulta>'||
                               '<parametroConsignado>'||
                                '<diaMesVencInicial>'||rw_dados_vencto.diaMesDe||'</diaMesVencInicial>'||
                                '<diaMesVencFinal>'||rw_dados_vencto.diaMesAte||'</diaMesVencFinal>'||
                                '<diaMesVencInterface>'||rw_dados_vencto.diamesenvio||'</diaMesVencInterface>'||
                                '<diaMesVencimento>'||rw_dados_vencto.diamesvencto||'</diaMesVencimento>'||
                                '<qtdeVencimentos>'||rw_dados_vencto.qtdeVenctos||'</qtdeVencimentos>'||
                               '</parametroConsignado>'||
                               '</vencimento>';
         END LOOP;
         
         IF vr_xmlvencto IS NULL THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Os parametros de vencimento não estao cadastrados!';
            raise vr_saida;
         END IF;

         pc_escreve_xml(vr_xmlvencto);

      END LOOP;
      CLOSE cr_dados_consig;
      pc_escreve_xml ('</listaVencimentos>'||
                      '</dto>',true);
                      
      --DBMS_OUTPUT.put_line(vr_des_xml);
      pr_retxml := xmltype.createxml(vr_des_xml);
      
      --DBMS_OUTPUT.put_line(pr_retxml.getClobVal());

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    EXCEPTION
      WHEN vr_saida THEN
         pr_des_erro := 'OK';
         pr_cdcritic := nvl(vr_cdcritic,0);
         --pr_dscritic := vr_dscritic;
         pr_dscritic := null;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><mensagem>' || vr_dscritic || '</mensagem></Root>');
      WHEN vr_exc_erro THEN
         /*  se foi retornado apenas código */
         IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
             /* buscar a descriçao */
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         /* variavel de erro recebe erro ocorrido */
         pr_des_erro := 'NOK';
         pr_cdcritic := nvl(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
           pr_des_erro := 'NOK';
         /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_cademp.pc_busca_dados_consig_fis ' ||SQLERRM;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_busca_dados_consig_fis;

end TELA_CADEMP; 
/
