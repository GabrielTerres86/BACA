CREATE OR REPLACE PACKAGE CECRED."CCRD0001" AS

/*..............................................................................

    Programa: CONV0001 (Antigo b1wgen0045.p)
    Autor   : Guilherme - Precise
    Data    : Outubro/2009                       Ultima Atualizacao: 16/06/2016

    Dados referentes ao programa:

    Objetivo  : BO para unificacao de funcoes com o CRPS524.
                Programas com funcoes em comum com CRPS524:
                    - CCARBB
                    - CRPS138 relat 115 - Qntde Cooperados
                    - RELINS relat 470 - Beneficios INSS
                    - CRPS483 relat 450 - Inf. de Convenios
                    - RELSEG Op "R" 4 - Inf. de Seguros

    Alteracoes: 18/03/2010 - Incluido novo campo para guardar o numero de
                             cooperados com debito automatico, que tiveram
                             debitos no mes (Elton).

                14/05/2010 - Incluido novo parametro na procedure
                             valor-convenios com a quantidade de cooperados que
                             tiveram pelo menos um debito automatico no mes,
                             independente do convenio. (Elton).

                04/06/2010 - Incluido tratamento para tarifa TAA (Elton).

                15/03/2011 - Inclusao dos parametros ret_vlcancel e ret_qtcancel
                             na procedure limite-cartao-credito (Vitor)

                20/03/2012 - Alterado o parametro aux_qtassdeb para a table
                             crawass na procedure valor-convenios (Adriano).

                25/04/2012 - Incluido novo parametro na procedure
                             limite-cartao-credito. (David Kruger).

                22/06/2012 - Substituido gncoper por crapcop (Tiago).

                05/09/2012 - Alteracao na leitura da situacao de cartoes de
                             Creditos (David Kruger).

                22/02/2013 - Incluido novas procedures para utilizacao da tela
                             RELSEG no AYLLOS e WEB (David Kruger).

                21/06/2013 - Contabilizando crawcrd.insitcrd = 7 como "em uso"
                             (Tiago).

                16/06/2016 - Correcao para o uso correto do indice da CRAPTAB na
                             procedure pc_limite_cartao_credito.(Carlos Rafael Tanholi).  

..............................................................................*/

  --  Tipo de registro para PlTable de seguros
  TYPE typ_reg_limites IS
    RECORD(cdagenci  crawcrd.cdagenci%TYPE
          ,nrdconta  crawcrd.nrdconta%TYPE
          ,cdadmcrd  crawcrd.cdadmcrd%TYPE
          ,nrcrcard  crawcrd.nrcrcard%TYPE
          ,nmtitcrd  crawcrd.nmtitcrd%TYPE
          ,insitcrd  crawcrd.insitcrd%TYPE
          ,vllimcrd  NUMBER(25,2)
          ,vllimdeb  NUMBER(25,2)
          ,dtmvtolt  crawcrd.dtmvtolt%TYPE
          ,dtentreg  crawcrd.dtentreg%TYPE);

  -- Tipo de tabela para PlTable de seguros
  TYPE typ_tab_limites IS
    TABLE OF typ_reg_limites
    INDEX BY varchar2(45); -- (3) cdagenci || (10) nrdconta || (5) cdadmcrd || (27) nrcrcard


  -- Procedure para busca dos seguros de vida e residencia
  PROCEDURE pc_limite_cartao_credito (pr_cdcooper   IN PLS_INTEGER,
                                      pr_bradesbb   IN PLS_INTEGER,
                                      pr_cddopcao   IN VARCHAR2,
                                      pr_cdageini   IN PLS_INTEGER,
                                      pr_cdagefim   IN PLS_INTEGER,

                                      pr_vllimcon   OUT NUMBER,
                                      pr_vlcreuso   OUT NUMBER,
                                      pr_vlsaquso   OUT NUMBER,
                                      pr_vlcresol   OUT NUMBER,
                                      pr_vlsaqsol   OUT NUMBER,
                                      pr_valorcre   OUT NUMBER,
                                      pr_valordeb   OUT NUMBER,
                                      pr_vlcancel   OUT NUMBER,
                                      pr_vltotsaq   OUT NUMBER,
                                      pr_qtdemuso   OUT PLS_INTEGER,
                                      pr_qtdsolic   OUT PLS_INTEGER,
                                      pr_qtcartao   OUT PLS_INTEGER,
                                      pr_qtcancel   OUT PLS_INTEGER,
                                      pr_tab_limites OUT CCRD0001.typ_tab_limites);

  PROCEDURE pc_retorna_limite_cooperado (pr_cdcooper   IN crapcop.cdcooper%type
                                        ,pr_nrdconta   IN crapass.nrdconta%type
                                        ,pr_vllimtot   OUT NUMBER) ;
                                        
  PROCEDURE pc_retorna_limite_conta (pr_cdcooper   IN crapcop.cdcooper%type
                                    ,pr_nrdconta   IN crapass.nrdconta%type
                                        ,pr_vllimtot   OUT NUMBER) ;

  PROCEDURE pc_retorna_tipoenvio (pr_cdcooper   IN  tbcrd_tipo_envio_cartao.cdcooper%TYPE
                                 ,pr_idfuncio   IN  tbcrd_tipo_envio_cartao.idfuncionalidade%TYPE
                                 ,pr_cdagenci   IN  tbcrd_pa_envio_cartao.cdagencia%TYPE
                                 ,pr_tpdenvio   OUT tbcrd_tipo_envio_cartao.idtipoenvio%TYPE);

END CCRD0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED."CCRD0001" AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CCRD0001
  --  Sistema  : Procedimentos para Cartoes de Credito
  --  Sigla    : CRED
  --  Autor    : Douglas Pagel
  --  Data     : Dezembro/2013.                   Ultima atualizacao: 16/06/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para busca de dados de cartoes de credito
  --
  -- Alteracao : 16/06/2016 - Correcao para o uso da function fn_busca_dstextab da TABE0001 na
  --                          procedure pc_limite_cartao_credito.(Carlos Rafael Tanholi).  
  --
  ---------------------------------------------------------------------------------------------------------------
  /* Procedure que contabiliza os limites de cartoes de credito */
  PROCEDURE pc_limite_cartao_credito (pr_cdcooper   IN PLS_INTEGER,
                                      pr_bradesbb   IN PLS_INTEGER,
                                      pr_cddopcao   IN VARCHAR2,
                                      pr_cdageini   IN PLS_INTEGER,
                                      pr_cdagefim   IN PLS_INTEGER,

                                      pr_vllimcon   OUT NUMBER,
                                      pr_vlcreuso   OUT NUMBER,
                                      pr_vlsaquso   OUT NUMBER,
                                      pr_vlcresol   OUT NUMBER,
                                      pr_vlsaqsol   OUT NUMBER,
                                      pr_valorcre   OUT NUMBER,
                                      pr_valordeb   OUT NUMBER,
                                      pr_vlcancel   OUT NUMBER,
                                      pr_vltotsaq   OUT NUMBER,
                                      pr_qtdemuso   OUT PLS_INTEGER,
                                      pr_qtdsolic   OUT PLS_INTEGER,
                                      pr_qtcartao   OUT PLS_INTEGER,
                                      pr_qtcancel   OUT PLS_INTEGER,
                                      pr_tab_limites OUT CCRD0001.typ_tab_limites) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_limite_cartao_credito           Antigo: b1wgen0045.p/limite-cartao-credito
  --  Sistema  : Procedimentos para contabilizar limites de cartoes de credito
  --  Sigla    : CRED
  --  Autor    : Douglas Pagel
  --  Data     : Dezembro/2013.                   Ultima atualizacao: 07/02/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Retorna os limites de valores de cartoes de credito
  --
  -- Alteracoes: 07/02/2014 - Ajuste de conversao de numeros (Gabriel).
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
    vr_valorbra   NUMBER(25,2) := 0;
    vr_valordbb   NUMBER(25,2) := 0;
    vr_debitbra   NUMBER(25,2) := 0;
    vr_debitabb   NUMBER(25,2) := 0;
    -- Guardar registro dstextab
    vr_dstextab craptab.dstextab%TYPE;

    -- Dados de Arquivo auxiliar de controle de cartoes de credito
    CURSOR cr_crawcrd IS
      SELECT crawcrd.insitcrd,
             crawcrd.nrdconta,
             crawcrd.cdadmcrd,
             crawcrd.tpcartao,
             crawcrd.cdlimcrd
        FROM crawcrd
       WHERE crawcrd.cdcooper = pr_cdcooper
         AND crawcrd.insitcrd IN (0,1,2,3,4,5,7)
         AND ( (crawcrd.cdadmcrd > 82
            AND crawcrd.cdadmcrd < 89
            AND pr_bradesbb = 0)
             OR (crawcrd.cdadmcrd = 3
            AND pr_bradesbb = 1));
    rw_crawcrd cr_crawcrd%rowtype;

    -- CURSOR para filtro de limites de associados por agencia
    CURSOR cr_crapass_agenci (pr_nrdconta crapass.nrdconta%type) IS
      SELECT crapass.nrdconta
        FROM crapass
       WHERE crapass.nrdconta = pr_nrdconta
         AND ((crapass.cdagenci >= pr_cdageini
         AND crapass.cdagenci <= pr_cdagefim)
          OR (crapass.cdagenci = pr_cdageini
         AND pr_cdageini <> 0));
    rw_crapass_agenci cr_crapass_agenci%rowtype;

    -- CURSOR para dados do associado do limite.
    CURSOR cr_crapass (pr_nrdconta crapass.nrdconta%type) IS
      SELECT crapass.vllimdeb
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%rowtype;

    -- CURSOR para tabela de limites de cartao de credito e dias de debito.
    CURSOR cr_craptlc(pr_cdadmcrd craptlc.cdadmcrd%type
                     ,pr_tpcartao craptlc.tpcartao%type
                     ,pr_cdlimcrd craptlc.cdlimcrd%type) IS
      SELECT craptlc.vllimcrd
        FROM craptlc
       WHERE craptlc.cdcooper = pr_cdcooper
         AND craptlc.cdadmcrd = pr_cdadmcrd
         AND craptlc.tpcartao = pr_tpcartao
         AND craptlc.cdlimcrd = pr_cdlimcrd
         AND craptlc.dddebito = 0;
    rw_craptlc cr_craptlc%rowtype;

    -- CURSOR para limites concedidos
    CURSOR cr_crawcrd_concedido IS
      SELECT sum(craptlc.vllimcrd) vllimcrd
        FROM crawcrd,
             craptlc
       WHERE crawcrd.cdcooper = pr_cdcooper
         AND crawcrd.cdadmcrd = 3
         AND (crawcrd.insitcrd = 4
          OR  crawcrd.insitcrd = 7)
         AND craptlc.cdcooper = crawcrd.cdcooper
         AND craptlc.cdadmcrd = crawcrd.cdadmcrd
         AND craptlc.tpcartao = crawcrd.tpcartao
         AND craptlc.cdlimcrd = crawcrd.cdlimcrd
         AND craptlc.dddebito = 0;

    BEGIN
      /** Busca valor de limites de credito e debito Bradesco/BB **/
      
      -- Buscar configuração na tabela
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                      	       ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'VLCONTRCRD'
                                               ,pr_tpregist => 0);
        

      IF pr_bradesbb = 1 THEN /* pega vlr credito e deb Bradesco */
        vr_valorbra := TO_NUMBER(SUBSTR(REPLACE(vr_dstextab,'.',','),1,12));
        vr_debitbra := TO_NUMBER(SUBSTR(REPLACE(vr_dstextab,'.',','),27,12));
        pr_valorcre := vr_valorbra;
        pr_valordeb := vr_debitbra;
      ELSE
        IF pr_bradesbb = 0 THEN /* pega vlr cred e debito BB  */
          vr_valordbb := TO_NUMBER(SUBSTR(REPLACE(vr_dstextab,'.',','),14,12));
          pr_valorcre := vr_valordbb;
          vr_debitabb := TO_NUMBER(SUBSTR(REPLACE(vr_dstextab,'.',','),40,12));
          pr_valordeb := vr_debitabb;
          pr_vltotsaq := TO_NUMBER(SUBSTR(vr_dstextab,53,12));
        END IF;
      END IF;

      -- Dados Arquivo auxiliar de controle de cartoes de credito
      OPEN cr_crawcrd;
      LOOP
        FETCH cr_crawcrd
          INTO rw_crawcrd;
        EXIT WHEN cr_crawcrd%NOTFOUND;

        -- Verifica se deve considerar apenas associados da agencia passada por parametro
        IF pr_cddopcao = 'V' THEN
          OPEN cr_crapass_agenci(rw_crawcrd.nrdconta);
          FETCH cr_crapass_agenci
            INTO rw_crapass_agenci;
          -- Se o associado do limite nao for da agencia passada, continua com proximo registro da crawcrd
          IF cr_crapass_agenci%NOTFOUND THEN
            CLOSE cr_crapass_agenci;
            CONTINUE;
          END IF;
          CLOSE cr_crapass_agenci;
        END IF;

        -- Buscar Tabela de limites de cartao de credito e dias de debito.
        OPEN cr_craptlc (pr_cdadmcrd => rw_crawcrd.cdadmcrd
                        ,pr_tpcartao => rw_crawcrd.tpcartao
                        ,pr_cdlimcrd => rw_crawcrd.cdlimcrd);
        FETCH cr_craptlc
          INTO rw_craptlc;
        CLOSE cr_craptlc;

        -- Buscar também informações do associado
        OPEN cr_crapass(rw_crawcrd.nrdconta);
        FETCH cr_crapass
          INTO rw_crapass;
        CLOSE cr_crapass;

        IF  pr_cddopcao = 'C' THEN
          /*Situacoes: 0-estudo, 1-aprov., 2-solic., 3-liber., 4-em uso, 5-canc., 7-2via*/
          IF rw_crawcrd.insitcrd = 4 THEN
            pr_vlcreuso := nvl(pr_vlcreuso,0) + rw_craptlc.vllimcrd;
            pr_qtdemuso := nvl(pr_qtdemuso,0) + 1;

            IF pr_bradesbb = 1 THEN
              pr_vlsaquso := nvl(pr_vlsaquso,0) + (rw_craptlc.vllimcrd / 2);
            ELSE
              pr_vlsaquso := nvl(pr_vlsaquso,0) + rw_crapass.vllimdeb;
            END IF;
          ELSE
            IF rw_crawcrd.insitcrd = 5 THEN
              pr_vlcancel := nvl(pr_vlcancel,0) + rw_craptlc.vllimcrd;
              pr_qtcancel := nvl(pr_qtcancel,0) + 1;
            ELSE
              IF rw_crawcrd.insitcrd = 7 THEN
                pr_vlcreuso := nvl(pr_vlcreuso,0) + rw_craptlc.vllimcrd;
                pr_qtdemuso := nvl(pr_qtdemuso,0) + 1;

                IF pr_bradesbb = 1 THEN
                  pr_vlsaquso := nvl(pr_vlsaquso,0) + (rw_craptlc.vllimcrd / 2);
                ELSE
                  pr_vlsaquso := nvl(pr_vlsaquso,0) + rw_Crapass.vllimdeb;
                END IF;
              ELSE /* SOLICITADO */
                pr_vlcresol := nvl(pr_vlcresol,0) + rw_craptlc.vllimcrd;
                pr_qtdsolic := nvl(pr_qtdsolic,0) + 1;
                IF pr_bradesbb = 1 THEN
                  pr_vlsaqsol := nvl(pr_vlsaqsol,0) + (rw_craptlc.vllimcrd / 2);
                ELSE
                  pr_vlsaqsol := nvl(pr_vlsaqsol,0) + rw_crapass.vllimdeb;
                END IF;
              END IF;
            END IF;

          END IF;
        ELSE
          IF rw_crawcrd.insitcrd <> 5 THEN
            -- Alimenta pltable de parametro de limites.
            -- Nao encontrei onde e usada essa tabela de memoria que retorna
            -- Nao irei implementar o retorno visto que nao tem utilidade para o programa

            pr_qtcartao := nvl(pr_qtcartao,0) + 1;

          END IF;
        END IF;

      END LOOP; -- FIM Loop para os limites de credito
      CLOSE cr_crawcrd;

      -- Totaliza limites concedidos
      OPEN cr_crawcrd_concedido;
      FETCH cr_crawcrd_concedido INTO pr_vllimcon;
      CLOSE cr_crawcrd_concedido;

    END;
  END pc_limite_cartao_credito; -- pc_contabiliza

  PROCEDURE pc_retorna_limite_cooperado (pr_cdcooper   IN crapcop.cdcooper%type
                                        ,pr_nrdconta   IN crapass.nrdconta%type
                                        ,pr_vllimtot   OUT NUMBER) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_retorna_limite_cooperado
  --  Sigla    : CRED
  --  Autor    : Rafael Faria (Supero)
  --  Data     : Autubro/2018.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Retorna os limites dos cartoes do cooperado para a cooperativa
  --
  -- Alteracoes: 
  ---------------------------------------------------------------------------------------------------------------
    -- Buscar o CPF da conta
    CURSOR cr_crapass IS
      SELECT nrcpfcgc
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    CURSOR cr_crapass_cpfcgc (pr_nrcpfcgc in crapass.nrcpfcgc%type) IS
       SELECT cp.cdcooper
             ,cp.nrdconta
             ,cp.cdagenci
         FROM crapass cp
        WHERE cdcooper = pr_cdcooper
          AND nrcpfcgc = pr_nrcpfcgc;
    rw_crapass_cpfcgc cr_crapass_cpfcgc%rowtype;
   
    -- variaveis
    vr_vltotccr    NUMBER := 0;
    vr_vllimtot    NUMBER := 0;
      
  BEGIN
    
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;
    CLOSE cr_crapass;
    
    FOR rw_crapass_cpfcgc in cr_crapass_cpfcgc (rw_crapass.nrcpfcgc) LOOP

       
       pc_retorna_limite_conta (pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => rw_crapass_cpfcgc.nrdconta
                               ,pr_vllimtot => vr_vltotccr);

        vr_vllimtot := vr_vllimtot + vr_vltotccr;                        

    END LOOP;

    pr_vllimtot := vr_vllimtot;
    
  END pc_retorna_limite_cooperado; -- pc_retorna_limite_cooperado

PROCEDURE pc_retorna_limite_conta (pr_cdcooper   IN crapcop.cdcooper%type
                                  ,pr_nrdconta   IN crapass.nrdconta%type
                                  ,pr_vllimtot   OUT NUMBER) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_retorna_limite_conta
  --  Sigla    : CRED
  --  Autor    : Rafael Faria (Supero)
  --  Data     : Autubro/2018.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Retorna os limites dos cartoes referente a conta
  --
  -- Alteracoes: 
  ---------------------------------------------------------------------------------------------------------------
    -- retorna o limite do cartao para a cooperativa e conta
    CURSOR cr_valorlimite(pr_cdcooper crawcrd.cdcooper%TYPE
                         ,pr_nrdconta crawcrd.nrdconta%TYPE) IS
      SELECT SUM(NVL(vllimite,0)) vllimite
        FROM (SELECT crd.nrcctitg
                     /* Caso a conta cartao tenha mais limite, considera o maior 
                        mas seria uma inconsistencia na base. */
                    ,MAX(crd.vllimcrd) as vllimite
                FROM crawcrd crd
               WHERE crd.cdcooper = pr_cdcooper
                 AND crd.nrdconta = pr_nrdconta
                 AND crd.cdadmcrd between 10 and 80 /* BANCOOB */
                 AND crd.insitcrd in (2,3,4) /* 2-solic. 3-liberado, 4-em uso */
               GROUP BY crd.nrcctitg
              UNION ALL 
              SELECT 0 
                    ,tlc.vllimcrd as vllimite
                FROM crawcrd crd
                JOIN craptlc tlc ON (tlc.cdcooper = crd.cdcooper 
                                 AND tlc.cdadmcrd = crd.cdadmcrd 
                                 AND tlc.tpcartao = crd.tpcartao 
                                 AND tlc.cdlimcrd = crd.cdlimcrd 
                                 AND tlc.dddebito = 0)
                WHERE crd.cdcooper = pr_cdcooper
                  AND crd.nrdconta = pr_nrdconta
                  AND NOT crd.cdadmcrd between 10 and 80 /* NAO BANCOOB */
                  AND crd.insitcrd IN (4,7)); /* Em uso */
    rw_valorlimite cr_valorlimite%rowtype;
      
  BEGIN

    OPEN cr_valorlimite (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta);
    FETCH cr_valorlimite INTO rw_valorlimite;
    CLOSE cr_valorlimite;

    pr_vllimtot := nvl(rw_valorlimite.vllimite, 0);

  END pc_retorna_limite_conta; -- pc_retorna_limite_conta

  PROCEDURE pc_retorna_tipoenvio (pr_cdcooper   IN  tbcrd_tipo_envio_cartao.cdcooper%TYPE
                                 ,pr_idfuncio   IN  tbcrd_tipo_envio_cartao.idfuncionalidade%TYPE
                                 ,pr_cdagenci   IN  tbcrd_pa_envio_cartao.cdagencia%TYPE
                                 ,pr_tpdenvio   OUT tbcrd_tipo_envio_cartao.idtipoenvio%TYPE) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_retorna_tipoenvio
  --  Sigla    : CRED
  --  Autor    : Anderson-Alan (Supero)
  --  Data     : Fevereiro/2019.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Retorna os limites dos cartoes referente a conta
  --
  -- Alteracoes: 
  ---------------------------------------------------------------------------------------------------------------
  
  -- Dados de Arquivo auxiliar de controle de cartoes de credito
    CURSOR cr_tipo_envio_cartao IS
      SELECT tpec.idtipoenvio
        FROM tbcrd_pa_envio_cartao tpec
       WHERE tpec.cdcooper IN (SELECT tec.cdcooper
                                 FROM tbcrd_envio_cartao tec
                                WHERE tec.cdcooper = pr_cdcooper
                                  AND tec.idfuncionalidade = pr_idfuncio
                                  AND tec.flghabilitar = 1)
         AND tpec.idfuncionalidade = pr_idfuncio
         AND tpec.cdagencia = 61;
    rw_tipo_envio_cartao cr_tipo_envio_cartao%ROWTYPE;
  
  BEGIN
    
    OPEN cr_tipo_envio_cartao;
    FETCH cr_tipo_envio_cartao INTO rw_tipo_envio_cartao;
    CLOSE cr_tipo_envio_cartao;
    
    pr_tpdenvio := rw_tipo_envio_cartao.idtipoenvio;
    
  END pc_retorna_tipoenvio;

END CCRD0001;
/
