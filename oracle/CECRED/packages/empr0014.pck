CREATE OR REPLACE PACKAGE CECRED.empr0014 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : EMPR0013
  --  Sistema  : Rotinas sobre Efetivação de Proposta
  --  Sigla    : EMPR
  --  Autor    : Renato Raul Cordeiro
  --  Data     : Junho/2018.                   Ultima atualizacao: Junho/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para efetivação da Proposta
  --
  -- Alterações: 
  ---------------------------------------------------------------------------------------------------------------

    PROCEDURE pc_grava_efetivacao_proposta (pr_cdcooper  IN crapcop.cdcooper%TYPE      --Codigo Cooperativa
                                           ,pr_cdagenci  IN crapass.cdagenci%TYPE      --Codigo Agencia
                                           ,pr_nrdcaixa  IN INTEGER                    --Numero do Caixa
                                           ,pr_cdoperad  IN VARCHAR2                   --Codigo Operador
                                           ,pr_nmdatela  IN VARCHAR2                   --Nome da Tela
                                           ,pr_idorigem  IN INTEGER                    --Origem dos Dados
                                           ,pr_nrdconta  IN crapass.nrdconta%TYPE      --Numero da Conta do Associado
                                           ,pr_idseqttl  IN INTEGER                    --Sequencial do Titular
                                           ,pr_dtmvtolt  IN DATE                       --Data Movimento
                                           ,pr_flgerlog  IN INTEGER                    --Imprimir log 0=FALSE 1=TRUE
                                           ,pr_nrctremp  IN INTEGER                    --Numero Contrato Emprestimo
                                           ,pr_dtdpagto  IN DATE                       --Data pagamento
                                           ,pr_dtmvtopr  IN DATE
                                           ,pr_inproces  IN INTEGER
                                           ,pr_nrcpfope  IN NUMBER
                                           -->> SAIDA
                                           ,pr_tab_ratings  OUT rati0001.typ_tab_ratings        --> retorna dados do rating
                                           ,pr_mensagem OUT VARCHAR2                            --> Retorna mensagem
                                           ,pr_cdcritic OUT PLS_INTEGER                         --> Código da crítica
                                           ,pr_dscritic OUT VARCHAR2 );                         --> Descrição da crítica
                                           
    
    PROCEDURE pc_valida_dados_efet_proposta (pr_cdcooper  IN crapcop.cdcooper%TYPE      --Codigo Cooperativa
                                           ,pr_cdagenci  IN crapass.cdagenci%TYPE      --Codigo Agencia
                                           ,pr_nrdcaixa  IN INTEGER                    --Numero do Caixa
                                           ,pr_cdoperad  IN VARCHAR2                   --Codigo Operador
                                           ,pr_nmdatela  IN VARCHAR2                   --Nome da Tela
                                           ,pr_idorigem  IN INTEGER                    --Origem dos Dados
                                           ,pr_nrdconta  IN crapass.nrdconta%TYPE      --Numero da Conta do Associado
                                           ,pr_idseqttl  IN INTEGER                    --Sequencial do Titular
                                           ,pr_dtmvtolt  IN DATE                        --Data Movimento
                                           ,pr_flgerlog  IN INTEGER                     --Imprimir log
                                           ,pr_nrctremp  IN INTEGER                    --Numero Contrato Emprestimo
                                           ,pr_dtmvtopr IN DATE
                                           ,pr_inproces IN INTEGER
                                           ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                           ,pr_dscritic OUT crapcri.dscritic%TYPE
                                           );


    PROCEDURE pc_buscar_hist_lote_efet_prop(pr_tpemprst     IN number
                                           ,pr_idfiniof     IN number
                                           ,pr_dsoperac     IN varchar2
                                           ,pr_cdhistor     OUT number
                                           ,pr_cdhistor_tar OUT number
                                           ,pr_nrdolote     OUT number
                                           ,pr_cdcritic     OUT number --> Codigo da critica tratada
                                           ,pr_dscritic     OUT varchar2 --> Descricao de critica tratada
                                           );
                                           
  PROCEDURE pc_grava_efetiv_proposta_web(pr_cdcooper  IN crapcop.cdcooper%TYPE      --Codigo Cooperativa
                                           ,pr_cdagenci  IN crapass.cdagenci%TYPE      --Codigo Agencia
                                           ,pr_nrdcaixa  IN INTEGER                    --Numero do Caixa
                                           ,pr_cdoperad  IN VARCHAR2                   --Codigo Operador
                                           ,pr_nmdatela  IN VARCHAR2                   --Nome da Tela
                                           ,pr_idorigem  IN INTEGER                    --Origem dos Dados
                                           ,pr_nrdconta  IN crapass.nrdconta%TYPE      --Numero da Conta do Associado
                                           ,pr_idseqttl  IN INTEGER                    --Sequencial do Titular
                                           ,pr_dtmvtolt  IN VARCHAR2                        --Data Movimento
                                           ,pr_flgerlog  IN INTEGER                    --Imprimir log 0=FALSE 1=TRUE
                                           ,pr_nrctremp  IN INTEGER                    --Numero Contrato Emprestimo
                                           ,pr_dtdpagto    IN VARCHAR2                        --Data pagamento
                                           ,pr_dtmvtopr IN VARCHAR2
                                           ,pr_inproces IN INTEGER
                                           ,pr_nrcpfope IN NUMBER
                                           ,pr_xmllog   IN VARCHAR2                             --> XML com informações de LOG
                                           ,pr_cdcritic OUT PLS_INTEGER                         --> Código da crítica
                                           ,pr_dscritic OUT VARCHAR2                            --> Descrição da crítica
                                           ,pr_retxml   IN OUT NOCOPY xmltype                   --> Arquivo de retorno do XML
                                           ,pr_nmdcampo OUT VARCHAR2                            --> Nome do Campo
                                           ,pr_des_erro OUT VARCHAR2);
                                           
END empr0014;
/
CREATE OR REPLACE PACKAGE BODY CECRED.empr0014 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : EMPR0013
  --  Sistema  : Rotinas sobre Efetivação de Proposta
  --  Sigla    : EMPR
  --  Autor    : Renato Raul Cordeiro
  --  Data     : Junho/2018.                   Ultima atualizacao: Junho/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para efetivação da Proposta
  --
  -- Alterações: 
  ---------------------------------------------------------------------------------------------------------------

  /* Tratamento de erro */
  vr_des_erro VARCHAR2(4000);
  vr_index    PLS_INTEGER;

  /* Descrição e código da critica */
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);

  /* Erro em chamadas da pc_gera_erro */
  vr_tab_erro GENE0001.typ_tab_erro;

  /* Cursor de Linha de Credito */
  CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                   ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
    SELECT craplcr.cdlcremp
          ,craplcr.dsoperac
      FROM craplcr
     WHERE craplcr.cdcooper = pr_cdcooper
           AND craplcr.cdlcremp = pr_cdlcremp;
  rw_craplcr cr_craplcr%ROWTYPE;

  /* Cursor de Emprestimos */
  CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                   ,pr_nrdconta IN crapepr.nrdconta%TYPE
                   ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
    SELECT crapepr.*
          ,crapepr.rowid
      FROM crapepr
     WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
  rw_crapepr cr_crapepr%ROWTYPE;

  /* Cursor com Detalhes dos Emprestimos */
  CURSOR cr_crawepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                   ,pr_nrdconta IN crapepr.nrdconta%TYPE
                   ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
    SELECT crawepr.cdlcremp
          ,crawepr.vlpreemp
          ,crawepr.dtlibera
          ,crawepr.tpemprst
      FROM crawepr
     WHERE crawepr.cdcooper = pr_cdcooper
           AND crawepr.nrdconta = pr_nrdconta
           AND crawepr.nrctremp = pr_nrctremp;
  rw_crawepr cr_crawepr%ROWTYPE;
  
  
    PROCEDURE pc_grava_efetivacao_proposta (pr_cdcooper  IN crapcop.cdcooper%TYPE      --Codigo Cooperativa
                                           ,pr_cdagenci  IN crapass.cdagenci%TYPE      --Codigo Agencia
                                           ,pr_nrdcaixa  IN INTEGER                    --Numero do Caixa
                                           ,pr_cdoperad  IN VARCHAR2                   --Codigo Operador
                                           ,pr_nmdatela  IN VARCHAR2                   --Nome da Tela
                                           ,pr_idorigem  IN INTEGER                    --Origem dos Dados
                                           ,pr_nrdconta  IN crapass.nrdconta%TYPE      --Numero da Conta do Associado
                                           ,pr_idseqttl  IN INTEGER                    --Sequencial do Titular
                                           ,pr_dtmvtolt  IN DATE                       --Data Movimento
                                           ,pr_flgerlog  IN INTEGER                    --Imprimir log 0=FALSE 1=TRUE
                                           ,pr_nrctremp  IN INTEGER                    --Numero Contrato Emprestimo
                                           ,pr_dtdpagto  IN DATE                       --Data pagamento
                                           ,pr_dtmvtopr  IN DATE
                                           ,pr_inproces  IN INTEGER
                                           ,pr_nrcpfope  IN NUMBER
                                           -->> SAIDA
                                           ,pr_tab_ratings  OUT rati0001.typ_tab_ratings        --> retorna dados do rating
                                           ,pr_mensagem OUT VARCHAR2                            --> Retorna mensagem
                                           ,pr_cdcritic OUT PLS_INTEGER                         --> Código da crítica
                                           ,pr_dscritic OUT VARCHAR2                            --> Descrição da crítica
                                           ) AS 

  /* .............................................................................

       Programa: pc_grava_efetivacao_proposta           (Antigo b1wgen0084.p - grava_efetivacao_proposta)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : 
       Data    :                            Ultima atualizacao: 12/02/2019

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Rotina responsavel por gravar efetivação da proposta

       Alteracoes: 22/06/2018 - Conversao Progress -> Oracle. (Renato Cordeito/Odirlei AMcom)

                   24/10/2018 - P442 - AJustes na chamada da Valida Bens Alienados (Marcos-Envolti)

                   12/02/2019 - P442 - PreAprovado nova estrutura (Marcos-Envolti)

                   16/08/2019 - P450 - Na chamada pc_obtem_emprestimo_risco, incluir pr_nrctremp (Elton -AMcom)

    ............................................................................. */
      ----->> CURSORES <<-----
      cursor cr_crawepr is (
        select a.cdfinemp, a.vlemprst, a.qtpreemp, a.vlpreemp, a.cdlcremp,
               a.tpemprst, a.idfiniof, a.nrctremp, a.nrdconta, a.cdcooper,
               a.nrctrliq##1, a.nrctrliq##2, a.nrctrliq##3, a.nrctrliq##4,
               a.nrctrliq##5, a.nrctrliq##6, a.nrctrliq##7, a.nrctrliq##8,
               a.nrctrliq##9, a.nrctrliq##10,
               a.dtdpagto, a.dtlibera, a.dtcarenc, a.idquapro, a.qttolatr,
               a.txmensal, a.tpdescto, a.txdiaria, a.nrctaav2, a.nrctaav1,
               a.dtmvtolt, a.idcobope, a.dsnivris, a.rowid, a.flgpreap,
               decode(empr0001.fn_tipo_finalidade(a.cdcooper, a.cdfinemp),3,1,0) inintcdc
        from crawepr a
        where a.cdcooper = pr_cdcooper
          and a.nrdconta = pr_nrdconta
          and a.nrctremp = pr_nrctremp
          and rownum = 1);
      rw_crawepr cr_crawepr%ROWTYPE;

      cursor cr_crapfin (pr_cdfinemp in number) is
        SELECT a.tpfinali
          FROM crapfin a
         WHERE a.cdcooper = pr_cdcooper
           AND a.cdfinemp = pr_cdfinemp;
      rw_crapfin  cr_crapfin%ROWTYPE;

      cursor cr_craplcr (pr_cdlcremp in number) is 
        SELECT a.dsoperac
              ,a.cdusolcr
              ,a.tpctrato
              ,a.txdiaria
              ,a.rowid
          FROM craplcr a
         WHERE a.cdcooper = pr_cdcooper
           AND a.cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;

      cursor cr_crappre (pr_inpessoa in number
                        ,pr_cdfinemp in number
                        ,pr_inpreapr in number) is 
        SELECT ROWID
              ,cdfinemp
              ,vlmulpli
              ,vllimmin
              ,inpessoa
          FROM crappre
         WHERE crappre.cdcooper = pr_cdcooper
           AND crappre.inpessoa = pr_inpessoa
           AND crappre.cdfinemp = decode(pr_inpreapr,1,crappre.cdfinemp,pr_cdfinemp);
      rw_crappre cr_crappre%ROWTYPE;

      cursor cr_crapcpa (pr_idcarga        tbepr_carga_pre_aprv.idcarga%TYPE
                        ,pr_tppessoa       crapcpa.tppessoa%TYPE
                        ,pr_nrcpfcnpj_base crapcpa.nrcpfcnpj_base%TYPE) IS 
        SELECT a.iddcarga
              ,a.rowid
          FROM crapcpa a
         WHERE a.cdcooper = pr_cdcooper
           AND a.tppessoa       = pr_tppessoa
           AND a.nrcpfcnpj_base = pr_nrcpfcnpj_base
           AND a.iddcarga       = pr_idcarga
           FOR UPDATE;
      rw_crapcpa cr_crapcpa%ROWTYPE;

      cursor cr_crapjur is 
        SELECT *
          FROM crapjur a
         WHERE a.cdcooper = pr_cdcooper
           AND a.nrdconta = pr_nrdconta;
      rw_crapjur cr_crapjur%ROWTYPE;

      cursor cr_crapbpr (pr_cdcooper  crawepr.cdcooper%TYPE,
                         pr_nrdconta  crawepr.nrdconta%TYPE,
                         pr_nrctremp  crawepr.nrctremp%TYPE) is (
          SELECT a.dscatbem
            FROM crapbpr a
           WHERE a.cdcooper = pr_cdcooper
             AND a.nrdconta = pr_nrdconta
             AND a.nrctrpro = pr_nrctremp
             AND a.tpctrpro = 90);
      rw_crapbpr cr_crapbpr%ROWTYPE;

      cursor cr_crapass is (
          select a.inpessoa, a.nrcadast, a.nrcpfcgc, a.nrdconta, a.nrcpfcnpj_base
          from crapass a
          where a.CDCOOPER = pr_cdcooper
            and a.NRDCONTA = pr_nrdconta);
      rw_crapass cr_crapass%ROWTYPE;

      cursor cr_crapass_nrctaav1 (pr_nrctaav1 in number) is (
          select a.inpessoa, a.nrcadast, a.nrdconta, a.nrcpfcgc
           from crapass a
          where a.CDCOOPER = pr_cdcooper
            and a.NRDCONTA = pr_nrctaav1);
      rw_crapass_nrctaav1 cr_crapass_nrctaav1%ROWTYPE;

      cursor cr_crapttl is 
        SELECT a.cdempres
          FROM crapttl a
         WHERE a.cdcooper = pr_cdcooper
           AND a.nrdconta = pr_nrdconta
           AND a.idseqttl = 1;
      rw_crapttl cr_crapttl%ROWTYPE;
      
      ---->> VARIAVEIS <<----

      vr_nrdrowid rowid;

      vr_tab_dados_cpa  empr0002.typ_tab_dados_cpa;         --> Dados pre aprovado

      vr_vltotemp       crawepr.vlpreemp%TYPE;
      vr_vltotctr       crawepr.vlpreemp%TYPE;
      vr_vltotjur       crawepr.vlpreemp%TYPE;
      vr_floperac       number(1);
      vr_idcarga        tbepr_carga_pre_aprv.idcarga%TYPE;
      vr_inpreapr       number(1) := 0; --inicia com zero e muda quando for cdc e pre-aprovado

      vr_cdhistor       craplcm.cdhistor%TYPE;
      vr_cdhistor_tar   craplcm.cdhistor%TYPE;
      vr_nrdolote       craplot.nrdolote%TYPE;
      vr_flgimune       pls_integer;
      vr_vltotiofpri    crawepr.vlpreemp%TYPE;
      vr_vltotiofadi    crawepr.vlpreemp%TYPE;
      vr_vltotiofcpl    crawepr.vlpreemp%TYPE;
      vr_vltxiofatraso  crawepr.vlpreemp%TYPE;
      vr_vltotiof       crawepr.vlpreemp%TYPE;
      vr_qtdiaiof       number;
      vr_dscatbem       varchar2(32767);
      vr_dsctrliq       varchar2(1000);
      vr_vlpreclc       NUMBER;

      vr_valoriof       crawepr.vlpreemp%TYPE;
      vr_vliofpri       crawepr.vlpreemp%TYPE;
      vr_vliofadi       crawepr.vlpreemp%TYPE;

      vr_vltarifa       number;
      vr_cdfvlcop       crapfco.cdfvlcop%type;
      vr_cdhisgar       craphis.cdhistor%type;
      vr_cdfvlgar       crapfco.cdfvlcop%type;     
      vr_vlrtarif       number;
      vr_vltrfesp       number;
      vr_vltrfgar       number;
      vr_cdhistar_cad   number;
      vr_cdhistar_gar   number;
      vr_nrdolote_cred  integer;
      vr_cdhistor_cred  integer;
      vr_tpfinali       crapfin.tpfinali%TYPE;
      vr_nrseqdig       number;
             
      vr_vltxiofpri     number;
      vr_vltxiofadc     number;
      vr_vltxiofcpl     number;
      vr_vlaqiofc       number;
      vr_vltaxiof       number:=0;
      vr_cdempres       crapttl.cdempres%TYPE;
      vr_mensagem       varchar2(2000);
      vr_dsoperac       varchar2(2000);

      vr_tab_crapras          RATI0001.typ_tab_crapras;
      vr_tab_impress_coop     RATI0001.typ_tab_impress_coop;
      vr_tab_impress_rating   RATI0001.typ_tab_impress_rating;
      vr_tab_impress_risco_cl RATI0001.typ_tab_impress_risco;
      vr_tab_impress_risco_tl RATI0001.typ_tab_impress_risco;
      vr_tab_impress_assina   RATI0001.typ_tab_impress_assina;
      vr_tab_efetivacao       RATI0001.typ_tab_efetivacao;
      vr_tab_erro             GENE0001.typ_tab_erro;

      vr_dsnivris       varchar2(2000);

      vr_vltottar       number;
             
      vr_vltariof       number;
             
      vr_dstransa       varchar2(2000);
             
      vr_flgportb       number(1);

      vr_flcescrd       number(1);
      
      vr_txcetano       NUMBER;  -- Taxa cet ano
      vr_txcetmes       NUMBER;  -- Taxa cet mes
      
      --       vr_cdcritic       INTEGER;
             
      --     vr_dscritic       VARCHAR2(4000);
             
      vr_exc_saida      exception;
      vr_dsorigem       VARCHAR2(100);       
      
      ---->> SUB-ROTINAS <<----
      procedure pc_efetua_desbloqueio (pr_nrctrliq in crawepr.nrctrliq##1%TYPE) IS
      
        CURSOR cr_crawepr_2 IS
          SELECT b.idcobope
            FROM crawepr b
           WHERE b.cdcooper = pr_cdcooper
             AND b.nrdconta = pr_nrdconta
             AND b.nrctremp = pr_nrctrliq
             AND rownum = 1;
      
      BEGIN --pc_efetua_desbloqueio
      
        for rw_reg in cr_crawepr_2 LOOP
          --> Efetuar o desbloqueio de possiveis coberturas vinculadas ao mesmo 
          bloq0001.pc_bloq_desbloq_cob_operacao(
                           pr_nmdatela       => 'ATENDA', 
                           pr_idcobertura    => rw_reg.idcobope, 
                           pr_inbloq_desbloq => 'D', 
                           pr_cdoperador     => pr_cdoperad, 
                           pr_cdcoordenador_desbloq => null, 
                           pr_vldesbloq      => 0, 
                           pr_flgerar_log    => 'S', 
                           pr_dscritic       => pr_dscritic);
                           
          if nvl(pr_dscritic,'OK') <> 'OK' then
            raise vr_exc_saida;
          end if;
        end LOOP;
      end pc_efetua_desbloqueio;

    BEGIN 
  
  -- PONTO 1
      IF pr_flgerlog = 1 THEN
        vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
        vr_dstransa  := 'Grava dados de efetivacao da proposta';
      END IF;

      pr_cdcritic := 0;
      pr_dscritic := NULL;

-- PONTO 2
      begin
        vr_flgportb := 0;
        SELECT 1
          INTO vr_flgportb
          FROM tbepr_portabilidade p
         WHERE p.cdcooper = pr_cdcooper
           AND p.nrdconta = pr_nrdconta
           AND p.nrctremp = pr_nrctremp
           AND rownum = 1;
      exception
          when no_data_found then
             vr_flgportb := 0;
      end;

      if vr_flgportb = 0 then
        -- chamar VALIDA_BENS_ALIENADOS - grvm0001
        grvm0001.pc_valida_bens_alienados( pr_cdcooper => pr_cdcooper,
                                           pr_nrdconta => pr_nrdconta,
                                           pr_nrctrpro => pr_nrctremp,
                                           pr_cdcritic => pr_cdcritic,
                                           pr_dscritic => pr_dscritic); 

        if nvl(pr_cdcritic,0) <> 0 OR 
           nvl(pr_dscritic,'OK') <> 'OK' then
          raise vr_exc_saida;
        end if;
      END IF; 

-- PONTO 3

      pc_valida_dados_efet_proposta( pr_cdcooper => pr_cdcooper,
                                     pr_cdagenci => pr_cdagenci,
                                     pr_nrdcaixa => pr_nrdcaixa,
                                     pr_cdoperad => pr_cdoperad,
                                     pr_nmdatela => pr_nmdatela,
                                     pr_idorigem => pr_idorigem,
                                     pr_nrdconta => pr_nrdconta,
                                     pr_idseqttl => pr_idseqttl,
                                     pr_dtmvtolt => pr_dtmvtolt,
                                     pr_flgerlog => pr_flgerlog,
                                     pr_nrctremp => pr_nrctremp,
                                     pr_dtmvtopr => pr_dtmvtopr,
                                     pr_inproces => pr_inproces,
                                     pr_cdcritic => pr_cdcritic,
                                     pr_dscritic => pr_dscritic);
      if pr_cdcritic is not null or nvl(pr_dscritic,'OK') <> 'OK' then
        raise vr_exc_saida;
      end if;

-- PONTO 4
      OPEN cr_crapfin (rw_crawepr.cdfinemp);
      fetch cr_crapfin into rw_crapfin;
      if cr_crapfin%FOUND and rw_crapfin.tpfinali = 1 then
        vr_flcescrd := 1;
      else
        vr_flcescrd := 0;
      end if;
      close cr_crapfin;
      
      open cr_crawepr;
      fetch cr_crawepr into rw_crawepr;
      if cr_crawepr%NOTFOUND THEN
        close cr_crawepr;
        pr_cdcritic := null;
        pr_dscritic := 'Registro não encontrado crawepr: Cooperativa='||pr_cdcooper||
                         ' Conta='||pr_nrdconta||' Contrato empréstimo='||pr_nrctremp;
        raise vr_exc_saida;
      end if;
      CLOSE cr_crawepr;
       
       

-- PONTO 5
      -- EFETIVAÇÃO
      
      --> Buscar linha de credito
      open cr_craplcr(rw_crawepr.cdlcremp);
      fetch cr_craplcr into rw_craplcr;
      if cr_craplcr%NOTFOUND then
        pr_cdcritic := 363;
        pr_dscritic := null;
        close cr_craplcr;
        raise vr_exc_saida;
      end if;
      close cr_craplcr;
      
      vr_vltotemp := rw_crawepr.vlemprst;
      vr_vltotctr := rw_crawepr.qtpreemp * rw_crawepr.vlpreemp;
      vr_vltotjur := vr_vltotctr - rw_crawepr.vlemprst;
      if rw_craplcr.dsoperac like '%FINANCIAMENTO%' then
        vr_floperac := 1;
      else
        vr_floperac := 0;
      end if;
      
      vr_idcarga  := 0;

      --> Buscar cooperado
      open cr_crapass;
      fetch cr_crapass into rw_crapass;
      if cr_crapass%NOTFOUND THEN
        close cr_crapass;
        pr_cdcritic := null;
        pr_dscritic := substr('Erro leitura crapass ('||pr_cdcooper||'/'||pr_nrdconta||'/'||
                              ') --> '||sqlerrm,1,1000);
        raise vr_exc_saida;

      end if;
      close cr_crapass;

      -- se for cdc e pre aprovado vamos acessar a crappre como 1
      -- para buscar somente pelo tipo de pessoa e cooperativa
      if rw_crawepr.inintcdc=1 and rw_crawepr.flgpreap=1 then
        vr_inpreapr := 1;
      end if;

      open cr_crappre (rw_crapass.inpessoa, rw_crawepr.cdfinemp, vr_inpreapr);
      fetch cr_crappre into rw_crappre;
      if cr_crappre%FOUND THEN
        CLOSE cr_crappre;
        --> Verifica se o emprestimo eh pre-aprovado
        -- PONTO 6
         vr_idcarga := EMPR0002.fn_idcarga_pre_aprovado_cta(pr_cdcooper => pr_cdcooper
                                                           ,pr_nrdconta => pr_nrdconta);
        open cr_crapcpa(vr_idcarga,rw_crapass.inpessoa,rw_crapass.nrcpfcnpj_base);
        fetch cr_crapcpa into rw_crapcpa;
        if cr_crapcpa%NOTFOUND THEN
          close cr_crapcpa;
          pr_cdcritic := 0;
          pr_dscritic := 'Associado nao cadastrado no pre-aprovado.';
          raise vr_exc_saida;      
        end if;
        close cr_crapcpa;
                    
        --> Validar dados do credito pré-aprovado (crapcpa)
        empr0002.pc_valida_dados_cpa (pr_cdcooper  => pr_cdcooper    --> Codigo da cooperativa
                                     ,pr_cdagenci  => pr_cdagenci    --> Código da agencia
                                     ,pr_nrdcaixa  => pr_nrdcaixa    --> Numero do caixa
                                     ,pr_cdoperad  => pr_cdoperad    --> Codigo do operador
                                     ,pr_nmdatela  => pr_nmdatela    --> Nome da tela
                                     ,pr_idorigem  => pr_idorigem    --> Id origem
                                     ,pr_nrdconta  => pr_nrdconta    --> Numero da conta do cooperado
                                     ,pr_idseqttl  => pr_idseqttl    --> Sequencial do titular
                                     ,pr_vlemprst  => rw_crawepr.vlemprst          --> Valor do emprestimo
                                     ,pr_diapagto  => to_char(pr_dtdpagto,'DD')    --> Dia de pagamento
                                     ,pr_nrcpfope  => pr_nrcpfope    --> CPF do operador
                                     ,pr_nrctremp  => 0              --> numero do contrato genérico
                                     ,pr_cdcritic  => pr_cdcritic    --> Retorna codigo da critica
                                     ,pr_dscritic  => pr_dscritic    --> Retorna descrição da critica
                                      );
        IF nvl(pr_cdcritic,0) > 0 OR TRIM(pr_dscritic) IS NOT NULL  THEN
          RAISE vr_exc_saida;
        END IF;        
                    
        /* Atualiza o valor contratado do credito pre-aprovado */
        BEGIN
          update crapcpa a
            set a.vlctrpre = a.vlctrpre + rw_crawepr.vlemprst
            where rowid = rw_crapcpa.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar pre-aprovado:'||SQLERRM;
            RAISE vr_exc_saida;
        END;  
      end if;

      IF cr_crappre%ISOPEN THEN
        close cr_crappre;
      END IF;
                 

-- PONTO 7

      pc_buscar_hist_lote_efet_prop( pr_tpemprst => rw_crawepr.tpemprst, 
                                     pr_idfiniof => rw_crawepr.idfiniof, 
                                     pr_dsoperac => rw_craplcr.dsoperac, 
                                     pr_cdhistor => vr_cdhistor, 
                                     pr_cdhistor_tar => vr_cdhistor_tar, 
                                     pr_nrdolote => vr_nrdolote, 
                                     pr_cdcritic => pr_cdcritic, 
                                     pr_dscritic => pr_dscritic);
       
      if pr_cdcritic is not null or pr_dscritic is not null then
        raise vr_exc_saida;
      end if;

      --> Projeto 410 - Novo IOF 
      vr_flgimune      := 0;
      vr_vltotiofpri   := 0;
      vr_vltotiofadi   := 0;
      vr_vltotiofcpl   := 0;
      vr_vltxiofatraso := 0;
      vr_vltotiof      := 0;
      vr_qtdiaiof      := 1;
      vr_dscatbem      := '';

-- PONTO 8
      open cr_crapjur;
      fetch cr_crapjur into rw_crapjur;
      close cr_crapjur;
       
      vr_dscatbem := '';
       
      FOR rw_crapbpr IN cr_crapbpr( pr_cdcooper => rw_crawepr.cdcooper,
                                    pr_nrdconta => rw_crawepr.nrdconta,
                                    pr_nrctremp => rw_crawepr.nrctremp) LOOP
                                    
        vr_dscatbem := vr_dscatbem || '|' ||rw_crapbpr.dscatbem;
      END LOOP;
      
-- PONTO 9
      vr_dsctrliq := null;

      if rw_crawepr.nrctrliq##1 > 0 then
        if vr_dsctrliq is null then 
          vr_dsctrliq := vr_dsctrliq ||        to_char(rw_crawepr.nrctrliq##1,'99999999999G999D99MI');
        else
          vr_dsctrliq := vr_dsctrliq || ', '|| to_char(rw_crawepr.nrctrliq##1,'99999999999G999D99MI');
        end if;
      end if;

      if rw_crawepr.nrctrliq##2 > 0 then
        if vr_dsctrliq is null then 
           vr_dsctrliq := vr_dsctrliq ||        to_char(rw_crawepr.nrctrliq##2,'99999999999G999D99MI');
        else
           vr_dsctrliq := vr_dsctrliq || ', '|| to_char(rw_crawepr.nrctrliq##2,'99999999999G999D99MI');
        end if;
      end if;

      if rw_crawepr.nrctrliq##3 > 0 then
        if vr_dsctrliq is null then 
           vr_dsctrliq := vr_dsctrliq ||        to_char(rw_crawepr.nrctrliq##3,'99999999999G999D99MI');
        else
           vr_dsctrliq := vr_dsctrliq || ', '|| to_char(rw_crawepr.nrctrliq##3,'99999999999G999D99MI');
        end if;
      end if;

      if rw_crawepr.nrctrliq##4 > 0 then
        if vr_dsctrliq is null then 
           vr_dsctrliq := vr_dsctrliq ||        to_char(rw_crawepr.nrctrliq##4,'99999999999G999D99MI');
        else
           vr_dsctrliq := vr_dsctrliq || ', '|| to_char(rw_crawepr.nrctrliq##4,'99999999999G999D99MI');
        end if;
      end if;

      if rw_crawepr.nrctrliq##5 > 0 then
        if vr_dsctrliq is null then 
           vr_dsctrliq := vr_dsctrliq ||        to_char(rw_crawepr.nrctrliq##5,'99999999999G999D99MI');
        else
           vr_dsctrliq := vr_dsctrliq || ', '|| to_char(rw_crawepr.nrctrliq##5,'99999999999G999D99MI');
        end if;
      end if;

      if rw_crawepr.nrctrliq##6 > 0 then
        if vr_dsctrliq is null then 
           vr_dsctrliq := vr_dsctrliq ||        to_char(rw_crawepr.nrctrliq##6,'99999999999G999D99MI');
        else
           vr_dsctrliq := vr_dsctrliq || ', '|| to_char(rw_crawepr.nrctrliq##6,'99999999999G999D99MI');
        end if;
      end if;

      if rw_crawepr.nrctrliq##7 > 0 then
        if vr_dsctrliq is null then 
           vr_dsctrliq := vr_dsctrliq ||        to_char(rw_crawepr.nrctrliq##7,'99999999999G999D99MI');
        else
           vr_dsctrliq := vr_dsctrliq || ', '|| to_char(rw_crawepr.nrctrliq##7,'99999999999G999D99MI');
        end if;
      end if;

      if rw_crawepr.nrctrliq##8 > 0 then
        if vr_dsctrliq is null then 
           vr_dsctrliq := vr_dsctrliq ||        to_char(rw_crawepr.nrctrliq##8,'99999999999G999D99MI');
        else
           vr_dsctrliq := vr_dsctrliq || ', '|| to_char(rw_crawepr.nrctrliq##8,'99999999999G999D99MI');
        end if;
      end if;

      if rw_crawepr.nrctrliq##9 > 0 then
        if vr_dsctrliq is null then 
           vr_dsctrliq := vr_dsctrliq ||        to_char(rw_crawepr.nrctrliq##9,'99999999999G999D99MI');
        else
           vr_dsctrliq := vr_dsctrliq || ', '|| to_char(rw_crawepr.nrctrliq##9,'99999999999G999D99MI');
        end if;
      end if;

      if rw_crawepr.nrctrliq##10 > 0 then
        if vr_dsctrliq is null then 
           vr_dsctrliq := vr_dsctrliq ||        to_char(rw_crawepr.nrctrliq##10,'99999999999G999D99MI');
        else
           vr_dsctrliq := vr_dsctrliq || ', '|| to_char(rw_crawepr.nrctrliq##10,'99999999999G999D99MI');
        end if;
      end if;

-- PONTO 10
      vr_vliofpri := 0;
      vr_vliofadi := 0;
      vr_flgimune := 0;

      tiof0001.pc_calcula_iof_epr( pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrctremp => rw_crawepr.nrctremp,
                                   pr_dtmvtolt => pr_dtmvtolt,
                                   pr_inpessoa => rw_crapass.inpessoa,
                                   pr_cdlcremp => rw_crawepr.cdlcremp,
                                   pr_cdfinemp => rw_crawepr.cdfinemp,
                                   pr_qtpreemp => rw_crawepr.qtpreemp,
                                   pr_vlpreemp => rw_crawepr.vlpreemp,
                                   pr_vlemprst => rw_crawepr.vlemprst,
                                   pr_dtdpagto => rw_crawepr.dtdpagto,
                                   pr_dtlibera => rw_crawepr.dtlibera,
                                   pr_tpemprst => rw_crawepr.tpemprst,
                                   pr_dtcarenc => rw_crawepr.dtcarenc,
                                   pr_qtdias_carencia => 0,
                                   pr_dscatbem => vr_dscatbem,
                                   pr_idfiniof => rw_crawepr.idfiniof,
                                   pr_dsctrliq => vr_dsctrliq,
                                   pr_vlpreclc => vr_vlpreclc,
                                   pr_valoriof => vr_valoriof,
                                   pr_vliofpri => vr_vliofpri,
                                   pr_vliofadi => vr_vliofadi,
                                   pr_flgimune => vr_flgimune,
                                   pr_dscritic => pr_dscritic);
                                   
      if nvl(pr_dscritic,'OK') <> 'OK' then
        pr_cdcritic := null;
        raise vr_exc_saida;
      end if;

-- PONTO 11
      if nvl(vr_valoriof,0) <> 0 then
        vr_vltotiofpri := round(vr_valoriof,2);
        vr_vltotiof := vr_vltotiofpri;
      end if;

-- PONTO 12

      

-- PONTO 13
      vr_vltarifa := 0;
      TARI0001.pc_calcula_tarifa( pr_cdcooper => pr_cdcooper
                                , pr_nrdconta => pr_nrdconta
                                , pr_cdlcremp => rw_crawepr.cdlcremp
                                , pr_vlemprst => rw_crawepr.vlemprst
                                , pr_cdusolcr => rw_craplcr.cdusolcr
                                , pr_tpctrato => rw_craplcr.tpctrato
                                , pr_dsbemgar => vr_dscatbem
                                , pr_cdprogra => 'ATENDA'
                                , pr_flgemail => 'N'
                                , pr_tpemprst => rw_crawepr.tpemprst
                                , pr_idfiniof => rw_crawepr.idfiniof
                                , pr_vlrtarif => vr_vlrtarif
                                , pr_vltrfesp => vr_vltrfesp
                                , pr_vltrfgar => vr_vltrfgar
                                , pr_cdhistor => vr_cdhistar_cad
                                , pr_cdfvlcop => vr_cdfvlcop
                                , pr_cdhisgar => vr_cdhistar_gar
                                , pr_cdfvlgar => vr_cdfvlgar
                                ,pr_cdcritic  => pr_cdcritic
                                ,pr_dscritic  => pr_dscritic);
      if nvl(pr_cdcritic,0) > 0 or nvl(pr_dscritic,'OK') <> 'OK' then
        RAISE vr_exc_saida;
      end if;
              
      if nvl(vr_vlrtarif,0) > 0 then
        vr_vltarifa := vr_vltarifa + ROUND(nvl(vr_vlrtarif,0),2);
      end if;

      if nvl(vr_vltrfesp,0) > 0 then
        vr_vltarifa := vr_vltarifa + ROUND(nvl(vr_vltrfesp,0),2);
      end if;

      if nvl(vr_vltrfgar,0) > 0 then
        vr_vltrfgar := ROUND(nvl(vr_vltrfgar,0),2);
      end if;

      IF vr_cdhistar_cad IS NULL THEN
        vr_cdhistar_cad := 0;
      END IF;

      IF vr_cdhistar_gar IS NULL THEN
        vr_cdhistar_gar := 0;
      END IF;    

-- PONTO 14
      --> Se for Pos-Fixado  
      if rw_crawepr.tpemprst = 2  THEN
        vr_nrdolote_cred := 650004;
        IF vr_floperac = 1 THEN             /* Financiamento*/
           vr_cdhistor_cred := 2327;
        ELSE                                  /* Emprestimo */
           vr_cdhistor_cred := 2326;
        end if;
      ELSE 
      
        vr_tpfinali := empr0001.fn_tipo_finalidade(pr_cdcooper => pr_cdcooper,
                                                   pr_cdfinemp => rw_crawepr.cdfinemp);
       
        IF vr_floperac = 1 THEN /* Financiamento*/
          IF vr_tpfinali = 3 THEN /* CDC */
            vr_cdhistor_cred := 2014;
          ELSE
            vr_cdhistor_cred := 1059;
          end if;
          vr_nrdolote_cred := 600030;
        ELSE /* Emprestimo */
          IF vr_tpfinali = 3 THEN /* CDC */
            vr_cdhistor_cred := 2013;
          ELSE
            vr_cdhistor_cred := 1036;
          end if;
          vr_nrdolote_cred := 600005;
        end if;
      end if;
      
      empr0001.pc_cria_lancamento_lem_chave(pr_cdcooper => pr_cdcooper, 
                                            pr_dtmvtolt => pr_dtmvtolt, 
                                            pr_cdagenci => pr_cdagenci, 
                                            pr_cdbccxlt => 100, 
                                            pr_cdoperad => pr_cdoperad, 
                                            pr_cdpactra => pr_cdagenci, 
                                            pr_tplotmov => 4, 
                                            pr_nrdolote => vr_nrdolote_cred, 
                                            pr_nrdconta => pr_nrdconta, 
                                            pr_cdhistor => vr_cdhistor_cred, 
                                            pr_nrctremp => pr_nrctremp, 
                                            pr_vllanmto => vr_vltotemp, --> Valor total emprestado
                                            pr_dtpagemp => pr_dtmvtolt, 
                                            pr_txjurepr => rw_craplcr.txdiaria, 
                                            pr_vlpreemp => 0, 
                                            pr_nrsequni => 0, 
                                            pr_nrparepr => 0, 
                                            pr_flgincre => true, 
                                            pr_flgcredi => true, 
                                            pr_nrseqava => 0, 
                                            pr_cdorigem => pr_idorigem, 
                                            pr_qtdiacal => 0, 
                                            pr_vltaxprd => 0, 
                                            pr_nrseqdig => vr_nrseqdig, 
                                            pr_cdcritic => pr_cdcritic, 
                                            pr_dscritic => pr_dscritic);
                                            
      IF nvl(pr_cdcritic,0) > 0 or nvl(pr_dscritic,'OK') <> 'OK' THEN
        RAISE vr_exc_saida;
      END IF;
      
      IF vr_flgimune = 1 AND (vr_vliofpri > 0 OR vr_vliofadi > 0 ) THEN
        tiof0001.pc_insere_iof( pr_cdcooper   => pr_cdcooper, 
                                pr_nrdconta   => pr_nrdconta, 
                                pr_dtmvtolt   => pr_dtmvtolt, 
                                pr_tpproduto  => 1, 
                                pr_nrcontrato => pr_nrctremp, 
                                pr_idlautom   => null, 
                                pr_dtmvtolt_lcm => null, 
                                pr_cdagenci_lcm => null,
                                pr_cdbccxlt_lcm => null,
                                pr_nrdolote_lcm => null, 
                                pr_nrseqdig_lcm => null, 
                                pr_vliofpri     => vr_vliofpri, 
                                pr_vliofadi     => vr_vliofadi, 
                                pr_vliofcpl     => 0,
                                pr_flgimune     => vr_flgimune, 
                                pr_cdcritic     => pr_cdcritic, 
                                pr_dscritic     => pr_dscritic);
                                
         IF nvl(pr_cdcritic,0) > 0 OR TRIM(pr_dscritic) IS NOT NULL THEN
            pr_dscritic := 'Erro ao inserir lancamento de IOF: '|| pr_dscritic;
            raise vr_exc_saida;
         END IF;
      
      END IF;
      
-- PONTO 15

      --> Caso nao cobrou IOF pois é imune, mas possui valor principal ou adicional
      if rw_crawepr.idfiniof = 1 then 
        if vr_vltotiof > 0 then
          empr0001.pc_cria_lancamento_lem_chave(  pr_cdcooper => pr_cdcooper, 
                                                  pr_dtmvtolt => pr_dtmvtolt, 
                                                  pr_cdagenci => pr_cdagenci, 
                                                  pr_cdbccxlt => 100, 
                                                  pr_cdoperad => pr_cdoperad, 
                                                  pr_cdpactra => pr_cdagenci, 
                                                  pr_tplotmov => 4, 
                                                  pr_nrdolote => vr_nrdolote, 
                                                  pr_nrdconta => pr_nrdconta, 
                                                  pr_cdhistor => vr_cdhistor, 
                                                  pr_nrctremp => pr_nrctremp, 
                                                  pr_vllanmto => vr_vltotiof,--*2*,Usar variavel do IF>0???
                                                  pr_dtpagemp => pr_dtmvtolt, 
                                                  pr_txjurepr => rw_craplcr.txdiaria, 
                                                  pr_vlpreemp => 0, 
                                                  pr_nrsequni => 0, 
                                                  pr_nrparepr => 0, 
                                                  pr_flgincre => true, 
                                                  pr_flgcredi => true, 
                                                  pr_nrseqava => 0, 
                                                  pr_cdorigem => pr_idorigem, 
                                                  pr_qtdiacal => 0, 
                                                  pr_vltaxprd => 0, 
                                                  pr_nrseqdig => vr_nrseqdig, 
                                                  pr_cdcritic => pr_cdcritic, 
                                                  pr_dscritic => pr_dscritic);
          IF nvl(pr_cdcritic,0) > 0 or TRIM(pr_dscritic) IS NOT NULL THEN
            raise vr_exc_saida;
          END IF;
               
          tiof0001.pc_insere_iof( pr_cdcooper     => pr_cdcooper, 
                                  pr_nrdconta     => pr_nrdconta, 
                                  pr_dtmvtolt     => pr_dtmvtolt, 
                                  pr_tpproduto    => 1, 
                                  pr_nrcontrato   => pr_nrctremp, 
                                  pr_idlautom     => null, 
                                  pr_dtmvtolt_lcm => pr_dtmvtolt, 
                                  pr_cdagenci_lcm => pr_cdagenci, 
                                  pr_cdbccxlt_lcm => 100,
                                  pr_nrdolote_lcm => vr_nrdolote, 
                                  pr_nrseqdig_lcm => vr_nrseqdig, 
                                  pr_vliofpri     => vr_vliofpri, 
                                  pr_vliofadi     => vr_vliofadi, 
                                  pr_vliofcpl     => 0,
                                  pr_flgimune     => vr_flgimune, 
                                  pr_cdcritic     => pr_cdcritic, 
                                  pr_dscritic     => pr_dscritic);
          if nvl(pr_cdcritic,0) > 0 or nvl(pr_dscritic,'OK') <> 'OK' then
            raise vr_exc_saida;
          end if;
        END IF;  

        --> Gera a tarifa na LEM se for financiado IOF 
        -- PONTO 15.1
        if vr_vltarifa > 0 then
          if vr_cdhistar_cad = 0 then
            pr_cdcritic := 0;
            pr_dscritic := 'Historico de tarifa nao encontrado';
            raise vr_exc_saida;
          end if;
          
          empr0001.pc_cria_lancamento_lem (  pr_cdcooper => pr_cdcooper, 
                                             pr_dtmvtolt => pr_dtmvtolt, 
                                             pr_cdagenci => pr_cdagenci, 
                                             pr_cdbccxlt => 100, 
                                             pr_cdoperad => pr_cdoperad, 
                                             pr_cdpactra => pr_cdagenci, 
                                             pr_tplotmov => 4, 
                                             pr_nrdolote => vr_nrdolote, 
                                             pr_nrdconta => pr_nrdconta, 
                                             pr_cdhistor => vr_cdhistar_cad, 
                                             pr_nrctremp => pr_nrctremp, 
                                             pr_vllanmto => vr_vltarifa, 
                                             pr_dtpagemp => pr_dtmvtolt, 
                                             pr_txjurepr => rw_craplcr.txdiaria, -- *2*
                                             pr_vlpreemp => 0, 
                                             pr_nrsequni => 0, 
                                             pr_nrparepr => 0, 
                                             pr_flgincre => true, 
                                             pr_flgcredi => true, 
                                             pr_nrseqava => 0, 
                                             pr_cdorigem => pr_idorigem, 
                                             pr_qtdiacal => 0, 
                                             pr_vltaxprd => rw_craplcr.txdiaria, 
                                             pr_cdcritic => pr_cdcritic, 
                                             pr_dscritic => pr_dscritic);
          if nvl(pr_cdcritic,0) > 0 or nvl(pr_dscritic,'OK') <> 'OK' then
            raise vr_exc_saida;
          end if;
        END IF;
            
        -- PONTO 15.2
        --> Gerar tarifa de bens
        if vr_vltrfgar > 0 THEN 
        
          if vr_cdhistar_gar = 0 then
            pr_cdcritic := 0;
            pr_dscritic := 'Historico de tarifa nao encontrado';
            raise vr_exc_saida;
          end if;
          
          empr0001.pc_cria_lancamento_lem( pr_cdcooper => pr_cdcooper, 
                                           pr_dtmvtolt => pr_dtmvtolt, 
                                           pr_cdagenci => pr_cdagenci, 
                                           pr_cdbccxlt => 100, 
                                           pr_cdoperad => pr_cdoperad, 
                                           pr_cdpactra => pr_cdagenci, 
                                           pr_tplotmov => 4, 
                                           pr_nrdolote => vr_nrdolote, 
                                           pr_nrdconta => pr_nrdconta, 
                                           pr_cdhistor => vr_cdhistar_gar, 
                                           pr_nrctremp => pr_nrctremp, 
                                           pr_vllanmto => vr_vltrfgar, 
                                           pr_dtpagemp => pr_dtmvtolt, 
                                           pr_txjurepr => rw_craplcr.txdiaria, -- *2*
                                           pr_vlpreemp => 0, 
                                           pr_nrsequni => 0, 
                                           pr_nrparepr => 0, 
                                           pr_flgincre => true, 
                                           pr_flgcredi => true, 
                                           pr_nrseqava => 0, 
                                           pr_cdorigem => pr_idorigem, 
                                           pr_qtdiacal => 0, 
                                           pr_vltaxprd => 0,
                                           pr_cdcritic => pr_cdcritic, 
                                           pr_dscritic => pr_dscritic);
          if nvl(pr_cdcritic,0) > 0 or nvl(pr_dscritic,'OK') <> 'OK' then
            raise vr_exc_saida;
          end if;
        end if;
      END IF; --> Fim IF crawepr.idfiniof = 0

-- PONTO 16
      --> Agrupar valor de tarifas cobradas 
      vr_vltarifa := vr_vltarifa + vr_vltrfgar;
         
      --> Busca a taxa de IOF principal contratada
      tiof0001.pc_busca_taxa_iof( pr_cdcooper   => pr_cdcooper, 
                                  pr_nrdconta   => pr_nrdconta, 
                                  pr_nrctremp   => pr_nrctremp, 
                                  pr_dtmvtolt   => pr_dtmvtolt, 
                                  pr_cdlcremp   => pr_nrctremp, 
                                  pr_cdfinemp   => rw_crawepr.cdfinemp,
                                  pr_vlemprst   => rw_crawepr.vlemprst, 
                                  pr_vltxiofpri => vr_vltxiofpri, 
                                  pr_vltxiofadc => vr_vltxiofadc, 
                                  pr_vltxiofcpl => vr_vltxiofcpl, 
                                  pr_cdcritic   => pr_cdcritic, 
                                  pr_dscritic   => pr_dscritic);
                                  
      IF nvl(pr_cdcritic,0) > 0 or nvl(pr_dscritic,'OK') <> 'OK' THEN
        raise vr_exc_saida;
      END IF;
       
      vr_vlaqiofc := 0;
      vr_vlaqiofc := nvl(vr_vltxiofpri,0);

      IF vr_vlaqiofc = 0 THEN    
        vr_vlaqiofc := nvl(vr_vltxiofcpl,0);
      END IF;
                                        
-- PONTO 17

      --> Se for Pos-Fixado 
      IF rw_crawepr.tpemprst = 2  THEN
        --> Caso NAO seja Refinanciamento efetua credito na conta  
        IF NOT ( rw_crawepr.nrctrliq##1 > 0 or rw_crawepr.nrctrliq##2 > 0 or rw_crawepr.nrctrliq##3 > 0 or
                 rw_crawepr.nrctrliq##4 > 0 or rw_crawepr.nrctrliq##5 > 0 or rw_crawepr.nrctrliq##6 > 0 or 
                 rw_crawepr.nrctrliq##7 > 0 or rw_crawepr.nrctrliq##8 > 0 or rw_crawepr.nrctrliq##9 > 0 or 
                 rw_crawepr.nrctrliq##10 > 0) THEN 
                 
          vr_vltottar := 0;
          vr_vltariof := 0;
          pr_cdcritic := 0;
          
          empr0011.pc_efetua_credito_conta( pr_cdcooper => pr_cdcooper, 
                                            pr_nrdconta => pr_nrdconta, 
                                            pr_nrctremp => pr_nrctremp, 
                                            pr_dtmvtolt => pr_dtmvtolt, 
                                            pr_cdprogra => pr_nmdatela, 
                                            pr_inpessoa => rw_crapass.inpessoa, 
                                            pr_cdagenci => pr_cdagenci, 
                                            pr_nrdcaixa => pr_nrdcaixa, 
                                            pr_cdpactra => pr_cdagenci, 
                                            pr_cdoperad => pr_cdoperad, 
                                            pr_vltottar => vr_vltottar, 
                                            pr_vltariof => vr_vltariof, 
                                            pr_cdcritic => pr_cdcritic, 
                                            pr_dscritic => pr_dscritic);
                                            
          if nvl(pr_cdcritic,0) > 0 or nvl(pr_dscritic,'OK') <> 'OK' then
            raise vr_exc_saida;
          end if;

          pr_dscritic := null;
          vr_vltarifa := vr_vltottar;
                              
        end if;
      end if;

-- PONTO 18
      if rw_crapass.inpessoa = 1 then
        open cr_crapttl;
        fetch cr_crapttl into rw_crapttl;
        if cr_crapttl%FOUND then
           vr_cdempres := rw_crapttl.cdempres;        
        end if;
        close cr_crapttl;
      else
        vr_cdempres := rw_crapjur.cdempres;
      end if;

-- PONTO 19

        

-- PONTO 20 e -- PONTO 21
      BEGIN
          insert into crapepr (dtmvtolt, cdagenci, --1
                               cdbccxlt, nrdolote, --2
                               nrdconta, nrctremp, --3
                               cdfinemp, cdlcremp, --4
                               dtultpag, nrctaav1, --5
                               nrctaav2, qtpreemp, --6
                               qtprepag, txjuremp, --7
                               vljuracu, vljurmes, --8
                               vlpagmes, vlpreemp, --9
                               vlsdeved, vlemprst, --10
                               cdempres, inliquid, --11
                               nrcadast, qtprecal, --12
                               qtmesdec, dtinipag, --13
                               flgpagto, dtdpagto, --14
                               indpagto, vliofepr, --15
                               vlprejuz, vlsdprej, --16
                               inprejuz, vljraprj, --17
                               vljrmprj, dtprejuz, --18
                               tpdescto, cdcooper, --19
                               tpemprst, txmensal, --20
                               vlservtx, vlpagstx, --21
                               vljuratu, vlajsdev, --22
                               dtrefjur, diarefju, --23
                               flliqmen, mesrefju, --24
                               anorefju, flgdigit, --25
                               vlsdvctr, qtlcalat, --26
                               qtpcalat, vlsdevat, --27
                               vlpapgat, vlppagat, --28
                               qtmdecat, --29
                               qttolatr, cdorigem, --30
                               vltarifa, vltariof, --31
                               vltaxiof, nrconbir, --32
                               inconcje, vlttmupr, --33
                               vlttjmpr, vlpgmupr, --34
                               vlpgjmpr, qtimpctr, --35
                               dtliquid, dtultest, --36
                               dtapgoib, iddcarga, --37
                               cdopeori, cdageori, --38
                               dtinsori, cdopeefe, --39
                               dtliqprj, vlsprjat, --40
                               dtrefatu, vlsprojt, --41
                               idfiniof, vliofcpl, --42
                               vliofadc, idquaprc, --43
                               dtrefcor, vlpagiof, --44
                               vlaqiofc/*, inrisco_refin*/) values --45
                              (pr_dtmvtolt, pr_cdagenci, --1
                               100, vr_nrdolote_cred, --2
                               pr_nrdconta, pr_nrctremp,-- 3
                               rw_crawepr.cdfinemp, rw_crawepr.cdlcremp, --4
                               rw_crawepr.dtmvtolt, rw_crawepr.nrctaav1, --5
                               rw_crawepr.nrctaav2, rw_crawepr.qtpreemp, --6
                               0, rw_crawepr.txdiaria, --7
                               0, 0, --8
                               0, rw_crawepr.vlpreemp, --9
                                 
                               case when (rw_crawepr.cdlcremp = 100)
                                    then 0
                                    when (rw_crawepr.idfiniof > 0) 
                                    then rw_crawepr.vlemprst + vr_vltotiof + vr_vltarifa
                                    else rw_crawepr.vlemprst end,--vlsdeved 10

                               case when (rw_crawepr.idfiniof > 0) 
                                    then rw_crawepr.vlemprst + vr_vltotiof + vr_vltarifa
                                    else rw_crawepr.vlemprst end,--10
                                
                               vr_cdempres, --11
                                 
                               case when (rw_crawepr.cdlcremp = 100)
                                    then 1
                                    else 0
                               end,-- inliquid, --11

                               rw_crapass.nrcadast, 0, --12
                               0, null, --13
                               0, pr_dtdpagto, --14
                               0, vr_vltotiof, --15

                               case when (rw_crawepr.cdlcremp = 100)
                                    then rw_crapepr.vlsdeved
                                    else 0
                               end,--vlprejuz, --16

                               case when (rw_crawepr.cdlcremp = 100)
                                    then rw_crapepr.vlsdeved
                                    else 0
                               end,--vlsdprej, --16
                                 
                               case when (rw_crawepr.cdlcremp = 100)
                                    then 1
                                    else 0
                               end,--inprejuz, --17

                               0, --17
                               0, --18
                                 
                               case when (rw_crawepr.cdlcremp = 100)
                                    then pr_dtmvtolt
                                    else null
                               end,--dtprejuz, --18
                                 
                               rw_crawepr.tpdescto, pr_cdcooper, --19
                               rw_crawepr.tpemprst, rw_crawepr.txmensal, --20
                               0,0, --21
                               0,0, --22
                               null,0, --23
                               0,0, --24
                               0,0, --25
                               0,0, --26
                               0,0, --27
                               0,0, --28
                               0, --29
                               rw_crawepr.qttolatr, pr_idorigem, --30
                               vr_vltarifa, decode(rw_crawepr.tpemprst,2,vr_vltariof,vr_vltotiof), --31
                               vr_vltaxiof, 0, --32
                               0,0, --33
                               0,0, --34
                               0,0, --35
                               null,null, --36
                               null, vr_idcarga, --37
                               pr_cdoperad, pr_cdagenci, --38
                               sysdate, pr_cdoperad, --39*2* sysdate ou trunc(sysdate)???
                               null, 0, --40
                               null, --41
                                 
                               case when (rw_crawepr.tpemprst = 2 and rw_crawepr.idfiniof > 0)
                                    then rw_crawepr.vlemprst + vr_vltotiof + vr_vltarifa
                                    when (rw_crawepr.tpemprst = 2)
                                    then rw_crawepr.vlemprst
                                    else 0 end, --41
                                 
                               rw_crawepr.idfiniof, vr_vltotiofcpl, --42
                               vr_vltotiofadi, rw_crawepr.idquapro, --43
                               null, 0, --44
                               vr_vlaqiofc/*, null*/);--45

        if rw_crawepr.cdlcremp = 100 then
          BEGIN
              UPDATE crappep a
                 SET a.inliquid = 1,
                     a.inprejuz = 1
               WHERE a.cdcooper = pr_cdcooper
                 AND a.nrdconta = pr_nrdconta
                 AND a.nrctremp = pr_nrctremp
                 AND a.inliquid = 0;
          exception
              when others then
                 pr_cdcritic := null;
                 pr_dscritic := 'Erro atualização crappep: '||SQLERRM;
                 raise vr_exc_saida;
          END;
        end if;

      EXCEPTION
        when others then
          pr_cdcritic := null;
          pr_dscritic := 'Erro gravação crapepr: '||SQLERRM;
          raise vr_exc_saida;
      END;

-- PONTO 22
      if rw_crawepr.idcobope > 0 then
        if rw_crawepr.nrctrliq##1 > 0 then
           pc_efetua_desbloqueio(rw_crawepr.nrctrliq##1);
        end if;
        if rw_crawepr.nrctrliq##2 > 0 then
           pc_efetua_desbloqueio(rw_crawepr.nrctrliq##2);
        end if;
        if rw_crawepr.nrctrliq##3 > 0 then
           pc_efetua_desbloqueio(rw_crawepr.nrctrliq##3);
        end if;
        if rw_crawepr.nrctrliq##4 > 0 then
           pc_efetua_desbloqueio(rw_crawepr.nrctrliq##4);
        end if;
        if rw_crawepr.nrctrliq##5 > 0 then
           pc_efetua_desbloqueio(rw_crawepr.nrctrliq##5);
        end if;
        if rw_crawepr.nrctrliq##6 > 0 then
           pc_efetua_desbloqueio(rw_crawepr.nrctrliq##6);
        end if;
        if rw_crawepr.nrctrliq##7 > 0 then
           pc_efetua_desbloqueio(rw_crawepr.nrctrliq##7);
        end if;
        if rw_crawepr.nrctrliq##8 > 0 then
           pc_efetua_desbloqueio(rw_crawepr.nrctrliq##8);
        end if;
        if rw_crawepr.nrctrliq##9 > 0 then
           pc_efetua_desbloqueio(rw_crawepr.nrctrliq##9);
        end if;
        if rw_crawepr.nrctrliq##10 > 0 then
           pc_efetua_desbloqueio(rw_crawepr.nrctrliq##10);
        end if;
        -- até o 10

        --> Efetuar o bloqueio de possiveis coberturas vinculadas ao mesmo
        bloq0001.pc_bloq_desbloq_cob_operacao(
                                 pr_nmdatela              => 'ATENDA', 
                                 pr_idcobertura           => rw_crawepr.idcobope, 
                                 pr_inbloq_desbloq        => 'B', 
                                 pr_cdoperador            => pr_cdoperad, 
                                 pr_cdcoordenador_desbloq => null, 
                                 pr_vldesbloq             => 0, 
                                 pr_flgerar_log           => 'S', 
                                 pr_dscritic              => pr_dscritic);
        if nvl(pr_dscritic,'OK') <> 'OK' then
          RAISE vr_exc_saida;
        END IF;

      END IF;

-- PONTO 23
      RATI0002.pc_obtem_emprestimo_risco(
                      pr_cdcooper => pr_cdcooper, 
                      pr_cdagenci => pr_cdagenci, 
                      pr_nrdcaixa => pr_nrdcaixa, 
                      pr_cdoperad => pr_cdoperad, 
                      pr_nrdconta => pr_nrdconta, 
                      pr_idseqttl => pr_idseqttl, 
                      pr_idorigem => pr_idorigem, 
                      pr_nmdatela => pr_nmdatela, 
                      pr_flgerlog => 'N', 
                      pr_cdfinemp => rw_crawepr.cdfinemp, 
                      pr_cdlcremp => rw_crawepr.cdlcremp, 
                      pr_dsctrliq => rw_crawepr.nrctrliq##1||';'||rw_crawepr.nrctrliq##2||';'||
                                     rw_crawepr.nrctrliq##3||';'||rw_crawepr.nrctrliq##4||';'||
                                     rw_crawepr.nrctrliq##5||';'||rw_crawepr.nrctrliq##6||';'||
                                     rw_crawepr.nrctrliq##7||';'||rw_crawepr.nrctrliq##8||';'||
                                     rw_crawepr.nrctrliq##9||';'||rw_crawepr.nrctrliq##10
                            , 
                      pr_nrctremp => rw_crawepr.nrctremp, -- P450
                      pr_nivrisco => vr_dsnivris,
                      pr_dscritic => pr_dscritic, 
                      pr_cdcritic => pr_cdcritic);

      if nvl(pr_dscritic,'OK') <> 'OK' or nvl(pr_cdcritic,0) <> 0 then
        raise vr_exc_saida;
      end if;

-- PONTO 24

      vr_mensagem := null;
      IF rw_crawepr.dsnivris <> vr_dsnivris and 
        --> nao atualizar o risco no caso de cessao
        vr_flcescrd = 0 THEN 
        vr_mensagem := substr('O risco da proposta foi de ' || rw_crawepr.dsnivris ||
                              ' e o do contrato sera de ' || vr_dsnivris || '.',1,2000);
        begin
          UPDATE crawepr
             SET crawepr.dsnivori = vr_dsnivris,
                 crawepr.dsnivris = vr_dsnivris
           WHERE ROWID = rw_crawepr.rowid;
        exception
          when others then
            pr_cdcritic := null;
            pr_dscritic := 'Erro atualização crawepr: '||SQLERRM;
            raise vr_exc_saida;
        end;
 
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper, 
                             pr_cdoperad => pr_cdoperad, 
                             pr_dscritic => null, 
                             pr_dsorigem => vr_dsorigem, 
                             pr_dstransa => vr_mensagem, 
                             pr_dttransa => trunc(sysdate), 
                             pr_flgtrans => 1, 
                             pr_hrtransa => GENE0002.fn_busca_time, 
                             pr_idseqttl => pr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid );
      
        pr_mensagem := vr_mensagem;
      end if;

-- PONTO 25
      if rw_crawepr.nrctaav1 > 0 THEN
      
        open cr_crapass_nrctaav1(rw_crawepr.nrctaav1);
        fetch cr_crapass_nrctaav1 into rw_crapass_nrctaav1;
        
        IF cr_crapass_nrctaav1%NOTFOUND THEN
          CLOSE cr_crapass_nrctaav1;
          pr_cdcritic := 9;
          pr_dscritic := null;
          raise vr_exc_saida;
        END IF;
        CLOSE cr_crapass_nrctaav1;
          
        --> Monta a mensagem da operacao para envio no e-mail
        vr_dsoperac := 'Inclusao/alteracao do Avalista conta '||gene0002.fn_mask_conta(rw_crapass_nrctaav1.nrdconta)||
                       ' - CPF/CNPJ '|| gene0002.fn_mask_cpf_cnpj(rw_crapass_nrctaav1.nrcpfcgc,rw_crapass.inpessoa)||
                       ' na conta '|| gene0002.fn_mask_conta(rw_crawepr.nrdconta);

        --> Verifica se o primeiro avalista esta no cadastro restritivo. Se estiver, sera enviado um e-mail informando a situacao*/
        cada0004.pc_alerta_fraude(pr_cdcooper => pr_cdcooper,
                                  pr_cdagenci => pr_cdagenci,
                                  pr_nrdcaixa => pr_nrdcaixa,
                                  pr_cdoperad => pr_cdoperad,
                                  pr_nmdatela => pr_nmdatela,
                                  pr_dtmvtolt => pr_dtmvtolt,
                                  pr_idorigem => pr_idorigem,
                                  pr_nrcpfcgc => rw_crapass_nrctaav1.nrcpfcgc,
                                  pr_nrdconta => rw_crapass_nrctaav1.nrdconta,
                                  pr_idseqttl => pr_idseqttl,
                                  pr_bloqueia => 0,
                                  pr_cdoperac => 33,
                                  pr_dsoperac => vr_dsoperac,
                                  pr_cdcritic => pr_cdcritic,
                                  pr_dscritic => pr_dscritic,
                                  pr_des_erro => vr_des_erro);
        -- Se retornou erro
        IF vr_des_erro <> 'OK' THEN
          RAISE vr_exc_saida;
        END IF;

      end if;

-- PONTO 26 --> igual ao ponto 25, com a unica diferença do primeiro IF abaixo...

      if rw_crawepr.nrctaav2 > 0 then
        open cr_crapass_nrctaav1(rw_crawepr.nrctaav2);
        fetch cr_crapass_nrctaav1 into rw_crapass_nrctaav1;
        if cr_crapass_nrctaav1%NOTFOUND then
          CLOSE cr_crapass_nrctaav1;
          pr_cdcritic := 9;
          pr_dscritic := null;
          raise vr_exc_saida;
        end if;
        close cr_crapass_nrctaav1;
          
        --> Monta a mensagem da operacao para envio no e-mail
        vr_dsoperac := 'Inclusao/alteracao do Avalista conta '||gene0002.fn_mask_conta(rw_crapass_nrctaav1.nrdconta)||
                       ' - CPF/CNPJ '|| gene0002.fn_mask_cpf_cnpj(rw_crapass_nrctaav1.nrcpfcgc,rw_crapass.inpessoa)||
                       ' na conta '|| gene0002.fn_mask_conta(rw_crawepr.nrdconta);
       
        /*Verifica se o primeiro avalista esta no cadastro restritivo. Se
             estiver, sera enviado um e-mail informando a situacao*/
        cada0004.pc_alerta_fraude(pr_cdcooper => pr_cdcooper,
                                  pr_cdagenci => pr_cdagenci,
                                  pr_nrdcaixa => pr_nrdcaixa,
                                  pr_cdoperad => pr_cdoperad,
                                  pr_nmdatela => pr_nmdatela,
                                  pr_dtmvtolt => pr_dtmvtolt,
                                  pr_idorigem => pr_idorigem,
                                  pr_nrcpfcgc => rw_crapass_nrctaav1.nrcpfcgc,
                                  pr_nrdconta => rw_crapass_nrctaav1.nrdconta,
                                  pr_idseqttl => pr_idseqttl,
                                  pr_bloqueia => 0,
                                  pr_cdoperac => 33,
                                  pr_dsoperac => vr_dsoperac,
                                  pr_cdcritic => pr_cdcritic,
                                  pr_dscritic => pr_dscritic,
                                  pr_des_erro => vr_des_erro);
        -- Se retornou erro
        IF vr_des_erro <> 'OK' THEN
          RAISE vr_exc_saida;
        END IF;
      END IF;

-- PONTO 27

      BEGIN
        UPDATE craplcr a
           SET a.flgsaldo = 1
         WHERE ROWID = rw_craplcr.rowid;
      exception
         when others then
            pr_cdcritic := null;
            pr_dscritic := 'Erro atualização craplcr: '||SQLERRM;
            raise vr_exc_saida;
      END;
          
      RATI0001.pc_gera_rating ( pr_cdcooper => pr_cdcooper, 
                                pr_cdagenci => 0, 
                                pr_nrdcaixa => 0, 
                                pr_cdoperad => pr_cdoperad, 
                                pr_nmdatela => pr_nmdatela, 
                                pr_idorigem => pr_idorigem, 
                                pr_nrdconta => pr_nrdconta, 
                                pr_idseqttl => 1, /** Titular **/
                                pr_dtmvtolt => pr_dtmvtolt, 
                                pr_dtmvtopr => pr_dtmvtopr, 
                                pr_inproces => pr_inproces, 
                                pr_tpctrrat => 90, /*Emprestimo/Financiamento*/
                                pr_nrctrrat => pr_nrctremp, 
                                pr_flgcriar => 1, 
                                pr_flgerlog => 1, 
                                pr_tab_rating_sing      => vr_tab_crapras, 
                                pr_tab_impress_coop     => vr_tab_impress_coop, 
                                pr_tab_impress_rating   => vr_tab_impress_rating, 
                                pr_tab_impress_risco_cl => vr_tab_impress_risco_cl, 
                                pr_tab_impress_risco_tl => vr_tab_impress_risco_tl, 
                                pr_tab_impress_assina   => vr_tab_impress_assina, 
                                pr_tab_efetivacao       => vr_tab_efetivacao, 
                                pr_tab_ratings          => pr_tab_ratings, 
                                pr_tab_crapras          => vr_tab_crapras, 
                                pr_tab_erro             => vr_tab_erro, 
                                pr_des_reto             => vr_des_erro);
                                
      IF vr_des_erro <> 'OK' THEN
            
        vr_index := vr_tab_erro.first;          
        pr_cdcritic := vr_tab_erro(vr_index).cdcritic;
        pr_dscritic := vr_tab_erro(vr_index).dscritic;
          
      END IF;
      
      --> Acionar o calculo do CET dos Empréstimos, gravando quando solicitado
      CCET0001.pc_calculo_cet_emprestimos( pr_cdcooper  => pr_cdcooper         -- Cooperativa
                                          ,pr_dtmvtolt  => pr_dtmvtolt         -- Data Movimento
                                          ,pr_nrdconta  => pr_nrdconta         -- Conta/dv
                                          ,pr_cdprogra  => pr_nmdatela         -- Programa chamador
                                          ,pr_inpessoa  => rw_crapass.inpessoa -- Indicativo de pessoa
                                          ,pr_cdusolcr  => rw_craplcr.cdusolcr -- Codigo de uso da linha de credito
                                          ,pr_cdlcremp  => rw_crawepr.cdlcremp -- Linha de credio
                                          ,pr_tpemprst  => rw_crawepr.tpemprst -- Tipo da operacao
                                          ,pr_nrctremp  => rw_crawepr.nrctremp -- Contrato
                                          ,pr_dtlibera  => rw_crawepr.dtlibera -- Data liberacao
                                          ,pr_vlemprst  => rw_crawepr.vlemprst -- Valor emprestado
                                          ,pr_txmensal  => rw_crawepr.txmensal -- Taxa mensal 
                                          ,pr_vlpreemp  => rw_crawepr.vlpreemp -- Valor Parcela
                                          ,pr_qtpreemp  => rw_crawepr.qtpreemp -- Parcelas
                                          ,pr_dtdpagto  => rw_crawepr.dtdpagto -- Data Pagamento
                                          ,pr_cdfinemp  => rw_crawepr.cdfinemp -- Finalidade de Emprestimo
                                          ,pr_dscatbem  => vr_dscatbem         -- Bens em garantia do Emprestimo
                                          ,pr_idfiniof  => rw_crawepr.idfiniof -- Indicador de financiamento do IOF e tarifa
                                          ,pr_dsctrliq  => vr_dsctrliq         -- Numeros dos contratos de liquidacao
                                          ,pr_idgravar  => 'S'                 -- Indicador de gravação ou não na tabela de calculo
                                          ,pr_txcetano  => vr_txcetano         -- Taxa cet ano
                                          ,pr_txcetmes  => vr_txcetmes         -- Taxa cet mes 
                                          ,pr_cdcritic  => pr_cdcritic         --> Código da crítica
                                          ,pr_dscritic  => pr_dscritic);       --> Descrição da crítica
      IF nvl(pr_cdcritic,0) <> 0 OR TRIM(pr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

       
/*
TYPE typ_reg_ratings IS
  RECORD (cdagenci crapass.cdagenci%TYPE
         ,nrdconta crapnrc.nrdconta%TYPE
         ,nrctrrat crapnrc.nrctrrat%TYPE
         ,tpctrrat crapnrc.tpctrrat%TYPE
         ,indrisco crapnrc.indrisco%TYPE
         ,dtmvtolt crapnrc.dtmvtolt%TYPE
         ,dteftrat crapnrc.dteftrat%TYPE
         ,cdoperad crapnrc.cdoperad%TYPE
         ,insitrat crapnrc.insitrat%TYPE
         ,dsditrat VARCHAR2(300)
         ,nrnotrat crapnrc.nrnotrat%TYPE
         ,vlutlrat crapnrc.vlutlrat%TYPE
         ,vloperac NUMBER
         ,dsdopera VARCHAR2(300)
         ,dsdrisco VARCHAR2(300)
         ,flgorige crapnrc.flgorige%TYPE
         ,inrisctl crapnrc.inrisctl%TYPE
         ,nrnotatl crapnrc.nrnotatl%TYPE
         ,dtrefere DATE
         ,nmprimtl crapass.nmprimtl%TYPE
         ,nmoperad crapope.nmoperad%TYPE);
TYPE typ_tab_ratings IS
  TABLE OF typ_reg_ratings
    INDEX BY BINARY_INTEGER;
*/
      
-- PONTO 28
      if pr_flgerlog = 1 THEN
        -- Chamar geração de LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => NULL
                            ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

        gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid,
                                   pr_nmdcampo => 'nrctremp',
                                   pr_dsdadant => pr_nrctremp,
                                   pr_dsdadatu => pr_nrctremp);
                                     
      end if;

    EXCEPTION
      WHEN vr_exc_saida THEN
      
        pr_cdcritic  := pr_cdcritic;
        pr_dscritic  := pr_dscritic;
       
        ROLLBACK;
      WHEN OTHERS THEN
      
        pr_dscritic  := 'Nao foi possivel efetivar proposta: '||SQLERRM;

        ROLLBACK;
    END pc_grava_efetivacao_proposta;
    

    PROCEDURE pc_valida_dados_efet_proposta ( pr_cdcooper  IN crapcop.cdcooper%TYPE      --Codigo Cooperativa
                                             ,pr_cdagenci  IN crapass.cdagenci%TYPE      --Codigo Agencia
                                             ,pr_nrdcaixa  IN INTEGER                    --Numero do Caixa
                                             ,pr_cdoperad  IN VARCHAR2                   --Codigo Operador
                                             ,pr_nmdatela  IN VARCHAR2                   --Nome da Tela
                                             ,pr_idorigem  IN INTEGER                    --Origem dos Dados
                                             ,pr_nrdconta  IN crapass.nrdconta%TYPE      --Numero da Conta do Associado
                                             ,pr_idseqttl  IN INTEGER                    --Sequencial do Titular
                                             ,pr_dtmvtolt  IN DATE                       --Data Movimento
                                             ,pr_flgerlog  IN INTEGER                    --Imprimir log
                                             ,pr_nrctremp  IN INTEGER                    --Numero Contrato Emprestimo
                                             ,pr_dtmvtopr  IN DATE
                                             ,pr_inproces  IN INTEGER
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                             ,pr_dscritic OUT crapcri.dscritic%TYPE
                                           ) as

    /* .............................................................................

       Programa: pc_valida_dados_efet_proposta      (Antigo b1wgen0084.p - valida_dados_efetivacao_proposta)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : 
       Data    :                            Ultima atualizacao: 19/10/2018

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Rotina responsavel por validar a efetivação da proposta

       Alteracoes: 22/06/2018 - Conversao Progress -> Oracle. (Renato Cordeito/Odirlei AMcom)
       
                   19/10/2018 - P442 - Troca de checagem fixa por funcão para garantir se bem é alienável (Marcos-Envolti)
                  
    ............................................................................. */

       ----->> CURSORES <<-----
       cursor cr_crapope is (
          SELECT a.nmoperad
            FROM crapope a
           WHERE a.cdcooper = pr_cdcooper
             AND a.cdoperad = pr_cdoperad);
       rw_crapope cr_crapope%ROWTYPE;

       cursor cr_crapass( pr_nrdconta crapass.nrdconta%TYPE,
                          pr_cdcooper crapass.cdcooper%TYPE) is (
          SELECT a.nrdconta
                ,a.inpessoa
                ,a.nrcpfcgc
            FROM crapass a
           WHERE a.nrdconta = pr_nrdconta
             AND a.cdcooper = pr_cdcooper);
       rw_crapass cr_crapass%ROWTYPE;

       cursor cr_crapemp (pr_cdempres in number) is (
         SELECT a.cdempres
           FROM crapemp a
          WHERE a.cdcooper = pr_cdcooper
            AND a.cdempres = pr_cdempres);
       rw_crapemp cr_crapemp%ROWTYPE;

       cursor cr_craplcr (pr_cdlcremp in number) is (
        SELECT *
          FROM craplcr a
         WHERE a.cdcooper = pr_cdcooper
           AND a.cdlcremp = pr_cdlcremp);
       rw_craplcr cr_craplcr%ROWTYPE;
            
       cursor cr_crapepr is (
          select *
          from crapepr a
          where a.cdcooper = pr_cdcooper
            and a.nrdconta = pr_nrdconta
            and a.nrctremp = pr_nrctremp
            and rownum = 1);
       rw_crapepr cr_crapepr%ROWTYPE;

       cursor cr_crawepr is (
          select a.insitapr, a.cdfinemp, a.insitest, a.cdcooper, a.nrdconta, 
                 a.cdlcremp, a.dtlibera,
                 a.nrctrliq##1, 
                 a.nrctrliq##2, a.nrctrliq##3,
                 a.nrctrliq##4, a.nrctrliq##5, a.nrctrliq##6, a.nrctrliq##7, a.nrctrliq##8,
                 a.nrctrliq##9, a.nrctrliq##10
          from crawepr a
          where a.cdcooper = pr_cdcooper
            and a.nrdconta = pr_nrdconta
            and a.nrctremp = pr_nrctremp
            and rownum = 1);
       rw_crawepr cr_crawepr%ROWTYPE;
       
       cursor cr_crapttl( pr_cdcooper crapttl.cdcooper%TYPE,
                          pr_nrdconta crapttl.nrdconta%TYPE,
                          pr_idseqttl crapttl.idseqttl%TYPE) is 
         SELECT a.cdempres
           FROM crapttl a
          WHERE a.cdcooper = pr_cdcooper
            AND a.nrdconta = pr_nrdconta
            AND a.idseqttl = pr_idseqttl;
       rw_crapttl cr_crapttl%ROWTYPE;
       
       cursor cr_crapjur is 
         SELECT a.cdempres
           FROM crapjur a
          WHERE a.cdcooper = pr_cdcooper
            AND a.nrdconta = pr_nrdconta;
       rw_crapjur cr_crapjur%ROWTYPE;
       
       CURSOR cr_crapepr_liq ( pr_cdcooper crapepr.cdcooper%TYPE,
                               pr_nrdconta crapepr.nrdconta%TYPE,
                               pr_nrctremp crapepr.nrctremp%TYPE) IS
         SELECT w.nrctrliq##1
               ,w.nrctrliq##2
               ,w.nrctrliq##3
               ,w.nrctrliq##4
               ,w.nrctrliq##5
               ,w.nrctrliq##6
               ,w.nrctrliq##7
               ,w.nrctrliq##8
               ,w.nrctrliq##9
               ,w.nrctrliq##10
           FROM crapepr p
               ,crawepr w
          WHERE p.cdcooper = pr_cdcooper
            AND p.nrdconta = pr_nrdconta
            AND p.nrctremp = pr_nrctremp
            AND p.cdcooper = w.cdcooper
            AND p.nrdconta = w.nrdconta
            AND p.nrctremp = w.nrctremp;
       
       
       cursor cr_crapfin (pr_cdcooper IN number,
                          pr_cdfinemp in number) is
         SELECT a.tpfinali
           FROM crapfin a
          WHERE a.cdcooper = pr_cdcooper
            AND a.cdfinemp = pr_cdfinemp;
       rw_crapfin  cr_crapfin%ROWTYPE;

       --> Verificar se emprestimo ja esta liquidado 
       CURSOR cr_crapepr_liquidado (pr_cdcooper crapepr.cdcooper%TYPE,
                                    pr_nrdconta crapepr.nrdconta%TYPE,
                                    pr_nrctremp crapepr.nrctremp%TYPE )IS
         SELECT 1
           FROM crapepr p
          WHERE p.cdcooper = pr_cdcooper
            AND p.nrdconta = pr_nrdconta
            AND p.inliquid = 1
            AND p.nrctremp = pr_nrctremp;
       rw_crapepr_liquidado cr_crapepr_liquidado%ROWTYPE; 
       
       
       --> Verificar se bens nao estao alienados em outro emprestimo
       CURSOR cr_crapbpr ( pr_cdcooper crapepr.cdcooper%TYPE,
                           pr_nrdconta crapepr.nrdconta%TYPE,
                           pr_nrctremp crapepr.nrctremp%TYPE) IS 
          SELECT 1
            FROM crapbpr bpr,
                 crapepr epr
           WHERE bpr.cdcooper = pr_cdcooper
             AND bpr.nrdconta = pr_nrdconta
             AND bpr.nrctrpro = pr_nrctremp
             AND bpr.flgalien = 1
             AND grvm0001.fn_valida_categoria_alienavel(bpr.dscatbem) = 'S'
             -- Existe em outro contrato deste cooperado ainda nao liquidado
             AND epr.cdcooper = bpr.cdcooper
             AND epr.nrdconta = bpr.nrdconta
             AND epr.inliquid = 0
             AND EXISTS (SELECT 1 
                           FROM crapbpr bbpr 
                          WHERE bbpr.cdcooper = epr.cdcooper
                            AND bbpr.nrdconta = epr.nrdconta
                            AND bbpr.nrctrpro = epr.nrctremp
                            AND bbpr.flgalien = 1
                            AND bbpr.dschassi = bpr.dschassi
                            AND bbpr.cdsitgrv NOT IN (4,5)
                        );
       rw_crapbpr cr_crapbpr%ROWTYPE; 
       
       ---->> VARIAVEIS <<---- 
       
       vr_exc_saida  exception;

       vr_tab_erro   gene0001.typ_tab_erro;
       vr_des_reto   VARCHAR2(100);
       vr_des_erro   varchar2(2000);
       
       vr_nrdconta   crapcti.nrdconta%type;
       vr_dsoperac   varchar2(2000);       
       vr_cdempres   crapttl.cdempres%type;       
       vr_cdlcremp   crawepr.cdlcremp%TYPE;       
       vr_insitest   crawepr.insitest%TYPE;
       vr_nrcpfcgc   crapass.nrcpfcgc%TYPE;
       vr_flgativo   number(1);
       
       vr_result     boolean;
       vr_nrliquid   crawepr.nrctrliq##1%TYPE;
       vr_flcescrd   INTEGER;
       
       ---->>SUB-ROTINAS <<----
       

    BEGIN
      
      -- atribui para variavel, usado em chamada de função com retorno no mesmo campo (calcula dígito)
      vr_nrdconta := pr_nrdconta;  
    
      -- ponto 1
      open cr_crapope;
      fetch cr_crapope into rw_crapope;  
      if cr_crapope%NOTFOUND THEN
        close cr_crapope;
        pr_cdcritic := 1;
        raise vr_exc_saida;
      end if;
      close cr_crapope;

      -- ponto 2
      vr_result := GENE0005.fn_calc_digito(pr_nrcalcul => vr_nrdconta);

      if vr_result = false then
        pr_cdcritic := null;
        pr_dscritic := 'Conta '||pr_nrdconta|| ' com dígito verificador inválido. '||
                       'Correto seria: '||vr_nrdconta;
        raise vr_exc_saida;
      end if;

       -- ponto 3 e 4
       
      open cr_crapass( pr_nrdconta => pr_nrdconta ,
                       pr_cdcooper => pr_cdcooper);
      fetch cr_crapass into rw_crapass;  
      if cr_crapass%NOTFOUND then
        pr_cdcritic := 9;
        CLOSE cr_crapass;
        raise vr_exc_saida;
      ELSE 
        CLOSE cr_crapass;
      END IF;
      
      --> Monta a mensagem da operacao para envio no e-mail
      vr_nrcpfcgc := rw_crapass.nrcpfcgc;
      vr_nrdconta := rw_crapass.nrdconta;
      vr_dsoperac := 'Tentativa de efetivar proposta de emprestimo/financiamento na conta '||
                      rw_crapass.nrdconta ||' - CPF/CNPJ '||
                      gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc,rw_crapass.inpessoa);
      
      
      vr_cdempres :=  NULL;
      --> Buscar empresa do cooperado
      if rw_crapass.inpessoa = 1 THEN --> Fisica
        open cr_crapttl( pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_idseqttl => pr_idseqttl);
        fetch cr_crapttl into rw_crapttl;
        if cr_crapttl%FOUND then
           vr_cdempres := rw_crapttl.cdempres;        
        end if;
        close cr_crapttl;
      ELSE --> Juridica
        rw_crapjur := NULL;
        open cr_crapjur;
        fetch cr_crapjur into rw_crapjur;
        close cr_crapjur;      
        vr_cdempres := rw_crapjur.cdempres;
      end if;
      
        
      -- ponto 5
      open cr_crapemp(vr_cdempres);
      fetch cr_crapemp into rw_crapemp;
      if cr_crapemp%NOTFOUND then
        pr_cdcritic := 40;
        close cr_crapemp;
        raise vr_exc_saida;
      end if;
      close cr_crapemp;

      -- ponto 6
      open cr_crapepr;
      fetch cr_crapepr into rw_crapepr;
      if cr_crapepr%FOUND then
        pr_cdcritic := 92; --> 092 - Lancamento ja existe
        CLOSE cr_crapepr;
        raise vr_exc_saida;
      end if;
      close cr_crapepr;
       
      -- ponto 7
      -- Ponto de atenção: Quando convertido do Progress, percebe-se que este bloco de programação
      -- nunca é executado devido á consistência imediatamente acima.
      -- Acima se achar o registro na tabela crapepr dá o erro, e aqui usa o mesmo registro, 
      -- nunca vai satisfazer aparentemente
      for rw_reg IN cr_crapepr_liq ( pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrctremp => pr_nrctremp) LOOP
        FOR i IN 1..10 LOOP
          CASE i 
            WHEN  1 THEN vr_nrliquid := rw_reg.nrctrliq##1;
            WHEN  2 THEN vr_nrliquid := rw_reg.nrctrliq##2;
            WHEN  3 THEN vr_nrliquid := rw_reg.nrctrliq##3;
            WHEN  4 THEN vr_nrliquid := rw_reg.nrctrliq##4;
            WHEN  5 THEN vr_nrliquid := rw_reg.nrctrliq##5;
            WHEN  6 THEN vr_nrliquid := rw_reg.nrctrliq##6;
            WHEN  7 THEN vr_nrliquid := rw_reg.nrctrliq##7;
            WHEN  8 THEN vr_nrliquid := rw_reg.nrctrliq##8;
            WHEN  9 THEN vr_nrliquid := rw_reg.nrctrliq##9;
            WHEN 10 THEN vr_nrliquid := rw_reg.nrctrliq##10;
            ELSE vr_nrliquid := 0;
          END CASE;
          
          IF nvl(vr_nrliquid,0) > 0 THEN
            --> convertido, caso entrar sempre apresentará erro, pq comparará valor com ele mesmo e indicará o erro.
            IF (rw_reg.nrctrliq##1  = vr_nrliquid OR 
                rw_reg.nrctrliq##2  = vr_nrliquid OR 
                rw_reg.nrctrliq##3  = vr_nrliquid OR
                rw_reg.nrctrliq##4  = vr_nrliquid OR
                rw_reg.nrctrliq##5  = vr_nrliquid OR
                rw_reg.nrctrliq##6  = vr_nrliquid OR
                rw_reg.nrctrliq##7  = vr_nrliquid OR
                rw_reg.nrctrliq##8  = vr_nrliquid OR
                rw_reg.nrctrliq##9  = vr_nrliquid OR
                rw_reg.nrctrliq##10 = vr_nrliquid ) THEN
                
              pr_cdcritic := 805; --> 805 - Proposta com  Contrato Ja Liquidado
              pr_dscritic := null;
              RAISE vr_exc_saida;
            END IF;
                    
          END IF;
           
        END LOOP;
       
      end loop; --> Fim LOOP cr_crapepr_liq

      -- ponto 8 e 11 e 13
      -- ponto 11        /** Verificar "inliquid" do contrato relacionado a ser liquidado **/
      -- ponto 13        /* Condicao para a Finalidade for Cessao de Credito */

      open cr_crawepr;
      fetch cr_crawepr into rw_crawepr;
      
      IF cr_crawepr%NOTFOUND then
        pr_cdcritic := 535;
        CLOSE cr_crawepr;
        raise vr_exc_saida;
      
      ELSE 
        CLOSE cr_crawepr;          
      END IF;
      
      IF rw_crawepr.insitapr not in (1,       --> Aprovado
                                     3) then  --> Aprovado com Restricao
        pr_cdcritic := 0;
        pr_dscritic := 'A proposta deve estar aprovada...';
        raise vr_exc_saida;
      END IF;    
      
      vr_insitest := rw_crawepr.insitest;
      vr_cdlcremp := rw_crawepr.cdlcremp;
      
      -- ponto 13
      rw_crapfin := NULL; 
      OPEN cr_crapfin (pr_cdcooper => pr_cdcooper,
                       pr_cdfinemp => rw_crawepr.cdfinemp);
                       
      fetch cr_crapfin into rw_crapfin;
      if cr_crapfin%FOUND and rw_crapfin.tpfinali = 1 then
        vr_flcescrd := 1;
      else
        vr_flcescrd := 0;
      end if;
      close cr_crapfin;
      
      --> Validar apenas se nao for cessao de credito
      if vr_flcescrd = 0 THEN
      
        --> Verifica se o primeiro avalista esta no cadastro restritivo. Se estiver, sera enviado um e-mail informando a situacao*/
        cada0004.pc_alerta_fraude(pr_cdcooper => pr_cdcooper,
                                  pr_cdagenci => pr_cdagenci,
                                  pr_nrdcaixa => pr_nrdcaixa,
                                  pr_cdoperad => pr_cdoperad,
                                  pr_nmdatela => pr_nmdatela,
                                  pr_dtmvtolt => pr_dtmvtolt,
                                  pr_idorigem => pr_idorigem,
                                  pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                                  pr_nrdconta => rw_crapass.nrdconta,
                                  pr_idseqttl => pr_idseqttl,
                                  pr_bloqueia => 1,
                                  pr_cdoperac => 33,
                                  pr_dsoperac => vr_dsoperac,
                                  pr_cdcritic => pr_cdcritic,
                                  pr_dscritic => pr_dscritic,
                                  pr_des_erro => vr_des_erro);
        -- Se retornou erro
        IF vr_des_erro <> 'OK' THEN
          RAISE vr_exc_saida;
        END IF;
      end if;
      
      -- ponto 10
      --> Verificar se a analise foi finalizada 
      if vr_insitest <> 3 then
        pr_cdcritic := 0;
        pr_dscritic := ' A proposta nao pode ser efetivada, verifique a situacao da proposta.';
        raise vr_exc_saida;
      end if;
      
      --> Verificar "inliquid" do contrato relacionado a ser liquidado 
      FOR vr_contador IN 1..10 LOOP
        vr_nrliquid := 0;
      
        CASE vr_contador
          WHEN  1 THEN vr_nrliquid := rw_crawepr.nrctrliq##1;
          WHEN  2 THEN vr_nrliquid := rw_crawepr.nrctrliq##2;
          WHEN  3 THEN vr_nrliquid := rw_crawepr.nrctrliq##3;
          WHEN  4 THEN vr_nrliquid := rw_crawepr.nrctrliq##4;
          WHEN  5 THEN vr_nrliquid := rw_crawepr.nrctrliq##5;
          WHEN  6 THEN vr_nrliquid := rw_crawepr.nrctrliq##6;
          WHEN  7 THEN vr_nrliquid := rw_crawepr.nrctrliq##7;
          WHEN  8 THEN vr_nrliquid := rw_crawepr.nrctrliq##8;
          WHEN  9 THEN vr_nrliquid := rw_crawepr.nrctrliq##9;
          WHEN 10 THEN vr_nrliquid := rw_crawepr.nrctrliq##10;
          ELSE vr_nrliquid := 0;
        END CASE;
          
        IF nvl(vr_nrliquid,0) > 0 THEN
          --> Verificar se contrato ja esta liquidado
          OPEN cr_crapepr_liquidado(pr_cdcooper => rw_crawepr.cdcooper,
                                    pr_nrdconta => rw_crawepr.nrdconta,
                                    pr_nrctremp => vr_nrliquid );
          FETCH cr_crapepr_liquidado INTO rw_crapepr_liquidado;
          IF cr_crapepr_liquidado%FOUND THEN
            CLOSE cr_crapepr_liquidado;
            pr_cdcritic := 0;
            pr_dscritic := 'Atencao: Exclua da proposta os contratos ja liquidados!';
            raise vr_exc_saida;
            
          ELSE 
            CLOSE cr_crapepr_liquidado;  
          END IF;                    
        END IF;
           
      END LOOP;
      
      -- ponto 12
      --> Verificar se um dos bens da proposta ja se encontra alienado em outro contrato 
      OPEN cr_crapbpr (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_nrctremp => pr_nrctremp);
      FETCH cr_crapbpr INTO rw_crapbpr;
      IF cr_crapbpr%FOUND THEN
        CLOSE cr_crapbpr;
        pr_dscritic := 'Ja existe o mesmo chassi alienado em um contrato liberado!';
        raise vr_exc_saida;
      ELSE
        CLOSE cr_crapbpr;
      END IF;
      
      --> Validar apenas se nao for cessao de credito
      if vr_flcescrd = 0 THEN
      
        -- Verifica se o associado esta no cadastro restritivo
        extr0001.pc_ver_capital(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_inproces => pr_inproces,
                                pr_dtmvtolt => pr_dtmvtolt,
                                pr_dtmvtopr => pr_dtmvtopr,
                                pr_cdprogra => 'lanctri',
                                pr_idorigem => 1, --> AYLLOS
                                pr_nrdconta => pr_nrdconta,
                                pr_vllanmto => 0,
                                pr_des_reto => vr_des_reto,
                                pr_tab_erro => vr_tab_erro);
        
        -- Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
         
          IF vr_tab_erro.COUNT > 0 THEN
            vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '|| pr_nrdconta;
            -- Gera exceção
            RAISE vr_exc_saida;
          END IF;
        
        END IF; 

      END IF;
      
      -- ponto 14
      open cr_craplcr(vr_cdlcremp);
      fetch cr_craplcr into rw_craplcr;
      if cr_craplcr%NOTFOUND then
        pr_cdcritic := 363;
        close cr_craplcr;
        raise vr_exc_saida;
      end if;
      close cr_craplcr;
      
      -- ponto 15
      IF pr_dtmvtolt > rw_crawepr.dtlibera then
        pr_cdcritic := 0;
        pr_dscritic := 'Data de movimento nao pode ser maior que a data de liberacao do emprestimo';
        raise vr_exc_saida;
     
      END IF;
     
     
      --> Verificacao de contrato de acordo
      FOR vr_contador IN 1..10 LOOP
        vr_nrliquid := 0;
      
        CASE vr_contador
          WHEN  1 THEN vr_nrliquid := rw_crawepr.nrctrliq##1;
          WHEN  2 THEN vr_nrliquid := rw_crawepr.nrctrliq##2;
          WHEN  3 THEN vr_nrliquid := rw_crawepr.nrctrliq##3;
          WHEN  4 THEN vr_nrliquid := rw_crawepr.nrctrliq##4;
          WHEN  5 THEN vr_nrliquid := rw_crawepr.nrctrliq##5;
          WHEN  6 THEN vr_nrliquid := rw_crawepr.nrctrliq##6;
          WHEN  7 THEN vr_nrliquid := rw_crawepr.nrctrliq##7;
          WHEN  8 THEN vr_nrliquid := rw_crawepr.nrctrliq##8;
          WHEN  9 THEN vr_nrliquid := rw_crawepr.nrctrliq##9;
          WHEN 10 THEN vr_nrliquid := rw_crawepr.nrctrliq##10;
          ELSE vr_nrliquid := 0;
        END CASE;
          
        IF nvl(vr_nrliquid,0) > 0 THEN
          --> Verifica se ha contratos de acordo
          RECP0001.pc_verifica_acordo_ativo(pr_cdcooper => pr_cdcooper,
                                            pr_nrdconta => pr_nrdconta,
                                            pr_nrctremp => pr_nrctremp,
                                            pr_cdorigem => 3,
                                            pr_flgativo => vr_flgativo,
                                            pr_cdcritic => pr_cdcritic,
                                            pr_dscritic => pr_dscritic);
          if nvl(pr_cdcritic,0) > 0 OR TRIM(pr_dscritic) is not null THEN
            RAISE vr_exc_saida;
          END IF;
         
          -- ponto 17
          IF vr_flgativo = 1 then
            pr_cdcritic := null;
            pr_dscritic := 'A proposta nao pode ser efetivada, contrato marcado para liquidar esta em acordo.';
            raise vr_exc_saida;
          end if;
                          
        END IF;
           
      END LOOP;
       
    EXCEPTION 
      WHEN vr_exc_saida THEN
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 0
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => pr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
      
      WHEN OTHERS THEN
      
           pr_cdcritic := 0;
           pr_dscritic := 'Eroo ao validar efetivação de proposta:' ||SQLERRM;
          

    END pc_valida_dados_efet_proposta;

    PROCEDURE pc_buscar_hist_lote_efet_prop(pr_tpemprst     IN number
                                           ,pr_idfiniof     IN number
                                           ,pr_dsoperac     IN varchar2
                                           ,pr_cdhistor     OUT number
                                           ,pr_cdhistor_tar OUT number
                                           ,pr_nrdolote     OUT number
                                           ,pr_cdcritic     OUT number --> Codigo da critica tratada
                                           ,pr_dscritic     OUT varchar2 --> Descricao de critica tratada
                                           ) is

    /* .............................................................................

       Programa: pc_buscar_hist_lote_efet_prop      (Antigo b1wgen0084.p - buscar_historico_e_lote_efet_prop)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : 
       Data    :                            Ultima atualizacao: 22/06/2018

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Rotina responsavel por definir os historicos de efetivação de proposta

       Alteracoes: 22/06/2018 - Conversao Progress -> Oracle. (Renato Cordeito/Odirlei AMcom)
                  
    ............................................................................. */

    BEGIN

      pr_cdhistor := 0;
      pr_nrdolote := 0;
    
      /* Financia IOF - se financiar IOF, nunca vai ser TR */
      IF pr_idfiniof = 1 THEN
      
        IF pr_tpemprst = 1 THEN /* Pre-Fixado */
          IF pr_dsoperac = 'FINANCIAMENTO' THEN
            pr_cdhistor     := 2305;
            pr_cdhistor_tar := 2307;
            pr_nrdolote     := 600030;
          ELSE
            pr_cdhistor     := 2304;
            pr_cdhistor_tar := 2306;
            pr_nrdolote     := 600005;
          END IF;
        ELSIF pr_tpemprst = 2 THEN /* Pos-Fixado */
          IF pr_dsoperac = 'FINANCIAMENTO' THEN
            pr_cdhistor     := 2536;
            pr_cdhistor_tar := 2307;
            pr_nrdolote     := 600030;
          ELSE
            pr_cdhistor     := 2535;
            pr_cdhistor_tar := 2306;
            pr_nrdolote     := 600005;
          END IF;        
        end if;
      ELSE
        /* Nao financia IOF */
        IF pr_tpemprst = 1 THEN /* Pre-Fixado */
          IF pr_dsoperac = 'FINANCIAMENTO' THEN
            pr_cdhistor := 2309;
            pr_nrdolote := 600030;
          ELSE
            pr_cdhistor := 2308;
            pr_nrdolote := 600005;
          end if;
        ELSIF pr_tpemprst = 2 THEN /* Pos-Fixado */
          IF pr_dsoperac = 'FINANCIAMENTO' THEN
             pr_cdhistor := 2538;
             pr_nrdolote := 600030;
          ELSE
             pr_cdhistor := 2537;
             pr_nrdolote := 600005;
          end if;
        ELSE /* TR */             
          pr_cdhistor := 2310;
          IF pr_dsoperac = 'FINANCIAMENTO' THEN
             pr_nrdolote := 600013;
          ELSE
             pr_nrdolote := 600012;
          end if;
        end if;
        
      end if;
       
      pr_cdcritic := null;
      pr_dscritic := null;
       
    EXCEPTION 
      when others then
        pr_cdcritic := null;
        pr_dscritic := 'Erro execução pc_buscar_hist_lote_efet_prop='||sqlerrm;
    
    END pc_buscar_hist_lote_efet_prop;

  PROCEDURE pc_grava_efetiv_proposta_web( pr_cdcooper  IN crapcop.cdcooper%TYPE      --Codigo Cooperativa
                                         ,pr_cdagenci  IN crapass.cdagenci%TYPE      --Codigo Agencia
                                         ,pr_nrdcaixa  IN INTEGER                    --Numero do Caixa
                                         ,pr_cdoperad  IN VARCHAR2                   --Codigo Operador
                                         ,pr_nmdatela  IN VARCHAR2                   --Nome da Tela
                                         ,pr_idorigem  IN INTEGER                    --Origem dos Dados
                                         ,pr_nrdconta  IN crapass.nrdconta%TYPE      --Numero da Conta do Associado
                                         ,pr_idseqttl  IN INTEGER                    --Sequencial do Titular
                                         ,pr_dtmvtolt  IN VARCHAR2                   --Data Movimento
                                         ,pr_flgerlog  IN INTEGER                    --Imprimir log 0=FALSE 1=TRUE
                                         ,pr_nrctremp  IN INTEGER                    --Numero Contrato Emprestimo
                                         ,pr_dtdpagto  IN VARCHAR2                   --Data pagamento
                                         ,pr_dtmvtopr  IN VARCHAR2
                                         ,pr_inproces  IN INTEGER
                                         ,pr_nrcpfope  IN NUMBER
                                         ,pr_xmllog    IN VARCHAR2                             --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER                         --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2                            --> Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY xmltype                   --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2                            --> Nome do Campo
                                         ,pr_des_erro OUT VARCHAR2) IS            --> Erros do processo
    /* .............................................................................
    
       Programa: pc_grava_efetiv_proposta_web                
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Renato
       Data    : Maio/2018                        Ultima atualizacao: 
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para execução via web da pc_grava_efetivacao_proposta
    
       Alteracoes: 
    
    ............................................................................. */ 
    
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      vr_tab_ratings    RATI0001.typ_tab_ratings;
      vr_mensagem       varchar2(2000);
      i                 PLS_INTEGER;
    
      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
    
      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;

      
    BEGIN
      
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      
      
      pc_grava_efetivacao_proposta (pr_cdcooper  => pr_cdcooper      --Codigo Cooperativa
                                   ,pr_cdagenci  => pr_cdagenci      --Codigo Agencia
                                   ,pr_nrdcaixa  => pr_nrdcaixa      --Numero do Caixa
                                   ,pr_cdoperad  => pr_cdoperad      --Codigo Operador
                                   ,pr_nmdatela  => pr_nmdatela      --Nome da Tela
                                   ,pr_idorigem  => pr_idorigem      --Origem dos Dados
                                   ,pr_nrdconta  => pr_nrdconta      --Numero da Conta do Associado
                                   ,pr_idseqttl  => pr_idseqttl      --Sequencial do Titular
                                   ,pr_dtmvtolt  => to_date(pr_dtmvtolt,'DD/MM/YYYY')      --Data Movimento
                                   ,pr_flgerlog  => pr_flgerlog      --Imprimir log 0=FALSE 1=TRUE
                                   ,pr_nrctremp  => pr_nrctremp      --Numero Contrato Emprestimo
                                   ,pr_dtdpagto  => to_date(pr_dtdpagto,'DD/MM/YYYY')      --Data pagamento
                                   ,pr_dtmvtopr  => to_date(pr_dtmvtopr,'DD/MM/YYYY')
                                   ,pr_inproces  => pr_inproces
                                   ,pr_nrcpfope  => pr_nrcpfope
                                   -->> SAIDA
                                   ,pr_tab_ratings  => vr_tab_ratings--> retorna dados do rating
                                   ,pr_mensagem     => vr_mensagem   --> Retorna mensagem
                                   ,pr_cdcritic     => vr_cdcritic   --> Código da crítica
                                   ,pr_dscritic     => vr_dscritic); --> Descrição da crítica  
    
    
      IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;      
      END IF;
      
      -- atribui tabela vr_tab_ratings para o XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'ratings', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      
      i := vr_tab_ratings.FIRST;      
      WHILE i IS NOT NULL LOOP
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'ratings', pr_posicao => 0, pr_tag_nova => 'rating', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating',  pr_posicao => i, pr_tag_nova => 'dtmvtolt', pr_tag_cont => TO_CHAR(vr_tab_ratings(i).dtmvtolt), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating',  pr_posicao => i, pr_tag_nova => 'dsdopera', pr_tag_cont => TO_CHAR(vr_tab_ratings(i).dsdopera), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating',  pr_posicao => i, pr_tag_nova => 'nrctrrat', pr_tag_cont => TO_CHAR(vr_tab_ratings(i).nrctrrat), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating',  pr_posicao => i, pr_tag_nova => 'indrisco', pr_tag_cont => TO_CHAR(vr_tab_ratings(i).indrisco), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating',  pr_posicao => i, pr_tag_nova => 'nrnotrat', pr_tag_cont => TO_CHAR(vr_tab_ratings(i).nrnotrat), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'rating',  pr_posicao => i, pr_tag_nova => 'vlutlrat', pr_tag_cont => TO_CHAR(vr_tab_ratings(i).vlutlrat), pr_des_erro => vr_dscritic);
        i := vr_tab_ratings.NEXT(i);
      END LOOP;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NOT NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
      WHEN OTHERS THEN
        pr_dscritic := 'Nao foi possivel efetivar proposta(web): '||SQLERRM;  
  END pc_grava_efetiv_proposta_web;


END empr0014;
/
