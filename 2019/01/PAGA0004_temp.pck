create or replace package cecred.paga0004_temp is

  /*..............................................................................

   Programa: paga0004_temp 
   Autor   : Odirlei Busana - AMcom
   Data    : 04/2018                        Ultima atualizacao: 05/04/2018

   Dados referentes ao programa:

   Objetivo  : Rotinas de estorno de Pagamentos

   Alteracoes:
                           
..............................................................................*/
  --> Procedimento para retornar/validar valores para estorno
  PROCEDURE pc_ret_val_fatura_estornotmp 
                                ( pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                                 ,pr_cdoperad  IN crapope.cdoperad%TYPE   --> Codigo do operador
                                 ,pr_cdagenci  IN INTEGER                 --> Codigo Agencia
                                 ,pr_nrdcaixa  IN INTEGER                 --> Numero Caixa
                                 ,pr_fatura1   IN NUMBER                  --> Parte 1 fatura
                                 ,pr_fatura2   IN NUMBER                  --> Parte 2 fatura
                                 ,pr_fatura3   IN NUMBER                  --> Parte 3 fatura
                                 ,pr_fatura4   IN NUMBER                  --> Parte 4 fatura
                                 ,pr_cdbarras  IN OUT craplft.cdbarras%TYPE   --> Codigo de barras
                                 ,pr_idorigem  IN NUMBER DEFAULT 0        --> Origem da operacao de estorno
                                 ,pr_cdseqfat     OUT craplft.cdseqfat%TYPE   --> sequencial da fatura
                                 ,pr_vldpagto     OUT craplft.vllanmto%TYPE   --> Valor pago
                                 ,pr_vlfatura     OUT craplft.vllanmto%TYPE   --> Valor da fatura
                                 ,pr_nrdigfat     OUT INTEGER                 --> Digito da fatura
                                 ,pr_iptu         OUT INTEGER                 --> identifica se é iptu                                 
                                 ,pr_dscritic     OUT VARCHAR2);                --> Retorna critica

  --> Procedimento para estornar convenios
  PROCEDURE pc_estorna_conveniotmp ( pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                                 ,pr_nrdconta  IN crapttl.nrdconta%TYPE   --> Numero da conta
                                 ,pr_idseqttl  IN crapttl.idseqttl%TYPE   --> Sequencial titular
                                 ,pr_cdbarras  IN craplft.cdbarras%TYPE   --> Codigo de barras
                                 ,pr_dscedent  IN craplcm.dscedent%TYPE   --> Cedente
                                 ,pr_cdseqfat  IN VARCHAR2                --> sequencial da fatura
                                 ,pr_vlfatura  IN craplft.vllanmto%TYPE   --> Valor da fatura
                                 ,pr_cdoperad  IN crapope.cdoperad%TYPE   --> Codigo do operador
                                 ,pr_idorigem  IN INTEGER                 --> Id de origem da operação
                                 ,pr_dstransa OUT VARCHAR2                --> Retorna Descrição da transação
                                 ,pr_dscritic OUT VARCHAR2                --> Retorna critica
                                 ,pr_dsprotoc OUT crappro.dsprotoc%TYPE);   --> Retorna protocolo
  
  --> Procedimento para estornar titulo
  PROCEDURE pc_estorna_titulotmp ( pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                               ,pr_cdagenci  IN crapage.cdagenci%TYPE   --> Codigo da agencia
                               ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE   --> Data de movimento
                               ,pr_nrdconta  IN crapttl.nrdconta%TYPE   --> Numero da conta
                               ,pr_idseqttl  IN crapttl.idseqttl%TYPE   --> Sequencial titular
                               ,pr_cdbarras  IN craplft.cdbarras%TYPE   --> Codigo de barras
                               ,pr_dscedent  IN craplcm.dscedent%TYPE   --> Cedente
                               ,pr_vlfatura  IN craplft.vllanmto%TYPE   --> Valor da fatura
                               ,pr_cdoperad  IN crapope.cdoperad%TYPE   --> Codigo do operador
                               ,pr_idorigem  IN INTEGER                 --> Id de origem da operação
                               ,pr_cdctrbxo  IN VARCHAR2                --> Codigo de controle de baixa
                               ,pr_nrdident  IN VARCHAR2                --> Identificador do titulo NPC
                               ,pr_dstransa OUT VARCHAR2                --> Retorna Descrição da transação
                               ,pr_dscritic OUT VARCHAR2                --> Retorna critica
                               ,pr_dsprotoc OUT crappro.dsprotoc%TYPE);   --> Retorna protocolo
                                                                                                      
end paga0004_temp;
/
create or replace package body cecred.paga0004_temp is

  /*---------------------------------------------------------------------------------------------------------------
    
      Programa : paga0004_temp
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana - Amcom
      Data     : Abril/2018.                   Ultima atualizacao: 03/09/2018
    
     Dados referentes ao programa:    
     Frequencia: 
     Objetivo  : Rotinas de estorno de Pagamentos
    
     Alteracoes: 03/09/2018 - Correção para remover lote (Jonata - Mouts).                
  ---------------------------------------------------------------------------------------------------------------*/

  ----------------------> CURSORES <----------------------
    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT crapcop.cdcooper
            ,crapcop.nmrescop
            ,crapcop.nrtelura
            ,crapcop.dsdircop
            ,crapcop.cdbcoctl
            ,crapcop.cdagectl
            ,crapcop.flgoppag
            ,crapcop.flgopstr
            ,crapcop.inioppag
            ,crapcop.fimoppag
            ,crapcop.iniopstr
            ,crapcop.fimopstr
            ,crapcop.cdagebcb
            ,crapcop.dssigaut
            ,crapcop.cdagesic
            ,crapcop.nrtelsac
        FROM crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    --> Busca dos dados do associado 
    CURSOR cr_crapass(pr_cdcooper IN craptab.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta
            ,crapass.nmprimtl
            ,crapass.inpessoa
            ,crapass.cdagenci
            ,crapass.vllimcre
            ,crapass.nrcpfcgc
            ,crapass.idastcjt
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
       AND   crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    CURSOR cr_crappod(pr_cdcooper crapass.cdcooper%TYPE,
                        pr_nrdconta crapass.nrdconta%TYPE)IS
        SELECT pod.cdcooper
              ,pod.nrdconta
              ,pod.nrcpfpro
          FROM crappod pod
         WHERE pod.cdcooper = pr_cdcooper
           AND pod.nrdconta = pr_nrdconta
           AND pod.cddpoder = 10
           AND pod.flgconju = 1;
           
    -- Verificar cadasto de senhas
    CURSOR cr_crapsnh2 (pr_cdcooper crapass.cdcooper%TYPE,
                        pr_nrdconta crapass.nrdconta%TYPE,
                        pr_nrcpfcgc crapttl.nrcpfcgc%TYPE) IS
      SELECT crapsnh.cdcooper
            ,crapsnh.nrdconta
            ,crapsnh.idseqttl
        FROM crapsnh
       WHERE crapsnh.cdcooper = pr_cdcooper
         AND crapsnh.nrdconta = pr_nrdconta
         AND crapsnh.tpdsenha = 1
         AND crapsnh.nrcpfcgc = pr_nrcpfcgc;
    rw_crapsnh2 cr_crapsnh2%ROWTYPE;
           
    --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
  
  --> Procedimento para retornar/validar valores para estorno
  PROCEDURE pc_ret_val_fatura_estornotmp 
                                ( pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                                 ,pr_cdoperad  IN crapope.cdoperad%TYPE   --> Codigo do operador
                                 ,pr_cdagenci  IN INTEGER                 --> Codigo Agencia
                                 ,pr_nrdcaixa  IN INTEGER                 --> Numero Caixa
                                 ,pr_fatura1   IN NUMBER                  --> Parte 1 fatura
                                 ,pr_fatura2   IN NUMBER                  --> Parte 2 fatura
                                 ,pr_fatura3   IN NUMBER                  --> Parte 3 fatura
                                 ,pr_fatura4   IN NUMBER                  --> Parte 4 fatura
                                 ,pr_cdbarras  IN OUT craplft.cdbarras%TYPE   --> Codigo de barras
                                 ,pr_idorigem  IN NUMBER DEFAULT 0        --> Origem da operacao de estorno
                                 ,pr_cdseqfat     OUT craplft.cdseqfat%TYPE   --> sequencial da fatura
                                 ,pr_vldpagto     OUT craplft.vllanmto%TYPE   --> Valor pago
                                 ,pr_vlfatura     OUT craplft.vllanmto%TYPE   --> Valor da fatura
                                 ,pr_nrdigfat     OUT INTEGER                 --> Digito da fatura
                                 ,pr_iptu         OUT INTEGER                 --> identifica se é iptu                                 
                                 ,pr_dscritic     OUT VARCHAR2                --> Retorna critica
                                 ) IS   

    /* ..........................................................................

      Programa : pc_ret_val_fatura_estorno        Antiga: sistema/siscaixa/web/dbo/b1crap15.p-retorna-valores-fatura
      Sistema : Internet - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Odirlei Busana - AMcom
      Data    : Abril/2018.                       Ultima atualizacao: 05/04/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado (On-Line)
      Objetivo  : Procedimento para retornar/validar valores para estorno

      Alteracoes: 05/04/2018 - Conversão Progress -> Oracle.
                                PRJ381 - Antifraude. (Odirlei-AMcom)
      
      
    .................................................................................*/
    ----------------> TEMPTABLE  <---------------
    
    ---------------->   CURSOR   <---------------
    --Selecionar cadastro empresas conveniadas
    CURSOR cr_crapcon (pr_cdcooper IN crapcon.cdcooper%type
                      ,pr_cdempcon IN crapcon.cdempcon%type
                      ,pr_cdsegmto IN crapcon.cdsegmto%type) IS
      SELECT crapcon.cdcooper
            ,crapcon.tparrecd
            ,crapcon.cdempcon
            ,crapcon.cdsegmto
            ,crapcon.cdhistor
      FROM crapcon
      WHERE crapcon.cdcooper = pr_cdcooper
        AND crapcon.cdempcon = pr_cdempcon
        AND crapcon.cdsegmto = pr_cdsegmto;
    rw_crapcon cr_crapcon%ROWTYPE;
    
    -- Buscar convenio sicredi
    CURSOR cr_crapscn (pr_cdempcon  crapcon.cdempcon%TYPE,
                       pr_cdsegmto  crapcon.cdsegmto%TYPE)IS
      SELECT scn.cdempres
        FROM crapscn scn
       WHERE scn.cdempcon = pr_cdempcon
         AND scn.cdsegmto = pr_cdsegmto
         AND scn.dsoparre <> 'E' --> Debaut 
         AND scn.dtencemp IS NULL;
    rw_crapscn cr_crapscn%ROWTYPE;
    
    -- Buscar transacoes sicredi
    CURSOR cr_crapstn (pr_cdempres  crapstn.cdempres%TYPE)IS
      SELECT stn.dstipdrf
        FROM crapstn stn
       WHERE stn.cdempres = pr_cdempres 
         AND stn.tpmeiarr = 'C';
    rw_crapstn cr_crapstn%ROWTYPE;
    
    --> Convenio Cecred
    CURSOR cr_gnconve (pr_cdhistor gnconve.cdhiscxa%TYPE) IS
      SELECT flgenvpa
        FROM gnconve 
       WHERE gnconve.cdhiscxa = pr_cdhistor;
    rw_gnconve cr_gnconve%ROWTYPE;
        
    --> Selecionar lancamentos de fatura
    CURSOR cr_craplft (pr_cdcooper IN craplft.cdcooper%type
                      ,pr_dtmvtolt IN craplft.dtmvtolt%type
                      ,pr_cdagenci IN craplft.cdagenci%type
                      ,pr_cdbccxlt IN craplft.cdbccxlt%type
                      ,pr_nrdolote IN craplft.nrdolote%type
                      ,pr_cdseqfat IN craplft.cdseqfat%type) IS
      SELECT lft.cdcooper,
             lft.vllanmto,
             lft.flgenvpa
      FROM craplft lft
      WHERE lft.cdcooper = pr_cdcooper
        AND lft.dtmvtolt = pr_dtmvtolt
        AND lft.cdagenci = pr_cdagenci
        AND lft.cdbccxlt = pr_cdbccxlt
        AND lft.nrdolote = pr_nrdolote
        AND lft.cdseqfat = pr_cdseqfat;
    rw_craplft cr_craplft%ROWTYPE;
    
    --> Buscar lote
    CURSOR cr_craplot ( pr_cdcooper craplot.cdcooper%TYPE,
                        pr_dtmvtocd craplot.dtmvtolt%TYPE,
                        pr_cdagenci craplot.cdagenci%TYPE,
                        pr_nrdolote craplot.nrdolote%TYPE ) IS
      SELECT lot.rowid,
             lot.cdbccxlt,
             lot.nrdolote,
             lot.cdagenci,
             lot.vlcompdb,
             lot.vlinfodb,
             lot.vlcompcr,
             lot.vlinfocr
        FROM craplot lot
       WHERE lot.cdcooper = pr_cdcooper
         AND lot.dtmvtolt = pr_dtmvtocd
         AND lot.cdagenci = pr_cdagenci
         AND lot.cdbccxlt = 11 --> Fixo 
         AND lot.nrdolote = pr_nrdolote;          
     rw_craplot cr_craplot%ROWTYPE;
      
    ----------------> VARIAVEIS <---------------
    --Variaveis de Erro
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_dscritic  VARCHAR2(4000);
    vr_des_erro  VARCHAR2(10);
    --Variaveis de Excecao
    vr_exc_erro  EXCEPTION;

    vr_cdagenci      crapage.cdagenci%TYPE;
    vr_cdhisdeb      craphis.cdhistor%TYPE;
    vr_cdhisest      craphis.cdhistor%TYPE;
    
    vr_flgfatex      BOOLEAN;
    vr_calc          VARCHAR2(100);
    vr_digito        INTEGER;
    vr_retorno       BOOLEAN;
    vr_dstextab      craptab.dstextab%TYPE;
    vr_hrcancel      NUMBER;
    vr_nrdolote      NUMBER;
    
    -----------> SubPrograma <------------
   

  BEGIN
  
    --Verificar se a cooperativa existe
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_cdcritic:= 651;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapcop;
    
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      
      CLOSE BTCH0001.cr_crapdat;      
      vr_cdcritic:= 1;
      RAISE vr_exc_erro;
    ELSE
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    pr_iptu       := 0;
    pr_cdseqfat   := 0;
    pr_vlfatura   := 0;
    pr_nrdigfat   := 0;
    vr_flgfatex   := FALSE;
    
    IF pr_fatura1 <> 0 OR
       pr_fatura2 <> 0 OR
       pr_fatura3 <> 0 OR
       pr_fatura4 <> 0 THEN
       
      pr_cdbarras := SUBSTR(to_char(pr_fatura1,'fm000000000000'),1,11) || 
                     SUBSTR(to_char(pr_fatura2,'fm000000000000'),1,11) ||
                     SUBSTR(to_char(pr_fatura3,'fm000000000000'),1,11) ||
                     SUBSTR(to_char(pr_fatura4,'fm000000000000'),1,11);
       
    END IF;   
    
    --Calcular Digito Codigo Barras
    vr_calc := pr_cdbarras;

    --> Calculo digito verificador pelo modulo 10
    CXON0000.pc_calc_digito_iptu_samae (pr_valor    => vr_calc       --> Valor Calculado
                                       ,pr_nrdigito => vr_digito     --> Digito Verificador
                                       ,pr_retorno  => vr_retorno);  --> Retorno digito correto
    IF vr_retorno = FALSE THEN
      --Calcular Digito Codigo Barras
      vr_calc := pr_cdbarras;
    
      --> Verificacao do digito no modulo 11 
      CXON0000.pc_calc_digito_titulo_mod11 (pr_valor      => vr_calc      --> Valor Calculado
                                           ,pr_nro_digito => vr_digito    --> Digito verificador
                                           ,pr_retorno    => vr_retorno); --> Retorno digito correto
    
    END IF; 
    
    IF vr_retorno = FALSE THEN
      vr_cdcritic := 8;
      RAISE vr_exc_erro;
    END IF;
  
    --Selecionar cadastro empresas conveniadas
    OPEN cr_crapcon (pr_cdcooper => rw_crapcop.cdcooper
                    ,pr_cdempcon => to_number(SUBSTR(pr_cdbarras,16,4))
                    ,pr_cdsegmto => to_number(SUBSTR(pr_cdbarras,2,1)));
    --Posicionar no proximo registro
    FETCH cr_crapcon INTO rw_crapcon;
    IF cr_crapcon%NOTFOUND THEN
      CLOSE cr_crapcon;
      vr_dscritic := 'Empresa nao Conveniada '||SUBSTR(pr_cdbarras,2,1) ||
                                             '/'||SUBSTR(pr_cdbarras,16,4);
      RAISE vr_exc_erro;                                       
    ELSE
      CLOSE cr_crapcon;
    END IF;
    
    --> Se for conv. SICREDI 
    IF rw_crapcon.tparrecd = 1 THEN
      -- Buscar convenio sicredi
      rw_crapscn := NULL;
      OPEN cr_crapscn (pr_cdempcon  => rw_crapcon.cdempcon,
                       pr_cdsegmto  => rw_crapcon.cdsegmto);
      FETCH cr_crapscn INTO rw_crapscn;
      CLOSE cr_crapscn;
      
      -- Buscar transacoes sicredi
      rw_crapstn := NULL;
      OPEN cr_crapstn (pr_cdempres => rw_crapscn.cdempres);
      FETCH cr_crapstn INTO rw_crapstn;
      
      --> Nao permite o estorno de DARFs
      IF cr_crapstn%FOUND AND 
         --> Nao validar qnd for analise de fraude, pois esta deve permitir
         pr_idorigem <> 12 THEN 
         
        CLOSE cr_crapstn;
        IF (TRIM(rw_crapstn.dstipdrf) IS NOT NULL OR
            rw_crapscn.cdempres = 'K0' ) THEN
          vr_dscritic := 'Esta guia nao pode ser estornada.';
          RAISE vr_exc_erro;
        END IF;                 

      ELSE
        CLOSE cr_crapstn;
      END IF;
      
      --> Validaçao relativa ao horario de canc. de pgto de Convenios SICREDI
      vr_dstextab := tabe0001.fn_busca_dstextab( pr_cdcooper => rw_crapcop.cdcooper, 
                                                 pr_nmsistem => 'CRED'          , 
                                                 pr_tptabela => 'GENERI'        , 
                                                 pr_cdempres => 00              , 
                                                 pr_cdacesso => 'HRPGSICRED'    , 
                                                 pr_tpregist => pr_cdagenci );
      
      IF TRIM(vr_dstextab) IS NULL THEN
        vr_dscritic := 'Parametros nao cadastrados.(HRPGSICRED)';
        RAISE vr_exc_erro;
      END IF;
      
      vr_hrcancel := gene0002.fn_busca_entrada ( pr_postext => 3,
                                                 pr_dstext => vr_dstextab,
                                                 pr_delimitador => ' ');
      
      --> Verifica se a hora atual é maior do que a do cancelamento
      IF gene0002.fn_busca_time > vr_hrcancel THEN
        
        vr_dscritic := 'Nao permitido estornar faturas do Sicredi apos as ' || 
                       gene0002.fn_converte_time_data(vr_hrcancel) ||' hrs.';
        RAISE vr_exc_erro;               
             
      END IF;
    
    END IF;
    
    -->  Buscar Sequencial da fatura *
    CXON0014.pc_busca_sequencial_fatura(pr_cdhistor      => rw_crapcon.cdhistor  --Codigo historico
                                       ,pr_codigo_barras => pr_cdbarras          --Codigo Barras
                                       ,pr_cdseqfat      => pr_cdseqfat          --Codigo Sequencial Fatura
                                       ,pr_cdcritic      => vr_cdcritic          --Codigo erro
                                       ,pr_dscritic      => vr_dscritic);        --Descricao erro
                                       
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    --Retornar valor fatura
    pr_vlfatura:= TO_NUMBER(SUBSTR(pr_cdbarras,5,11)) / 100;

    --Retornar Digito Faturamento
    IF  rw_crapcon.cdhistor IN (644,307,348)  THEN
      pr_nrdigfat:= TO_NUMBER(SUBSTR(pr_cdbarras,43,02));
    ELSE
      pr_nrdigfat:= 0;
    END IF;
    
    --> Lote - 15000 --- Tipo 13 --- FATURAS 
    vr_nrdolote:= 15000 + pr_nrdcaixa;

    --Selecionar lancamentos de fatura
    OPEN cr_craplft (pr_cdcooper => rw_crapcop.cdcooper
                    ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                    ,pr_cdagenci => pr_cdagenci
                    ,pr_cdbccxlt => 11
                    ,pr_nrdolote => vr_nrdolote
                    ,pr_cdseqfat => pr_cdseqfat);
    --Posicionar no proximo registro
    FETCH cr_craplft INTO rw_craplft;
    --Se encontrar
    IF cr_craplft%NOTFOUND THEN
      
      CLOSE cr_craplft;      
      vr_cdcritic := 90;
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_craplft;
    
    IF rw_crapcon.cdhistor <> 1154 THEN
      
      --> Convenio Cecred
      rw_gnconve := null;
      OPEN cr_gnconve (pr_cdhistor => rw_crapcon.cdhistor);
      FETCH cr_gnconve INTO rw_gnconve;
      CLOSE cr_gnconve;
      
      IF rw_gnconve.flgenvpa = 1 THEN
        --> Caso for Estorno de fraude, deve apenas validar se ja foi transmitido
        IF pr_idorigem = 12 AND 
           rw_craplft.flgenvpa = 1 THEN
           
          vr_dscritic := 'Fatura nao pode ser estornado pois ja foi transmitida.';
          RAISE vr_exc_erro;               
          
        ELSIF pr_idorigem <> 12 THEN
      
          vr_dscritic := 'Este tipo de fatura nao pode ser estornado.';
          RAISE vr_exc_erro;               
        
        END IF;      
      END IF;
    END IF;
    
    --> Buscar lote
    OPEN cr_craplot ( pr_cdcooper => rw_crapcop.cdcooper,
                      pr_dtmvtocd => rw_crapdat.dtmvtocd,
                      pr_cdagenci => pr_cdagenci,
                      pr_nrdolote => vr_nrdolote);
    FETCH cr_craplot INTO rw_craplot;
    IF cr_craplot%NOTFOUND THEN
      CLOSE cr_craplot;
      vr_cdcritic := 60;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craplot;
    END IF;
    
    --> Alterado para retornar valor fatura quando c?digo de barras = 0 
    IF pr_vlfatura = 0 THEN
      pr_vlfatura := rw_craplft.vllanmto;
    END IF;   
     
    -------------------------------------
    --> Robinson Rafael Koprowski 
    --> retorno do valor pago     
    pr_vldpagto := rw_craplft.vllanmto;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
     
      -- se possui codigo, porém não possui descrição
      IF nvl(vr_cdcritic,0) > 0 AND
         TRIM(vr_dscritic) IS NULL THEN
        -- buscar descrição
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

      END IF;

      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      
      btch0001.pc_log_internal_exception(pr_cdcooper);

      pr_dscritic := 'Erro inesperado ao retornar dados da fatura.: '||SQLERRM;
      
  END pc_ret_val_fatura_estornotmp;

  --> Procedimento para retornar/validar valores de DARF para estorno
  PROCEDURE pc_ret_val_darf_estornotmp
                                ( pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                                 ,pr_cdoperad  IN crapope.cdoperad%TYPE   --> Codigo do operador
                                 ,pr_cdagenci  IN INTEGER                 --> Codigo Agencia
                                 ,pr_nrdcaixa  IN INTEGER                 --> Numero Caixa                                 
                                 ,pr_idorigem  IN NUMBER DEFAULT 0        --> Origem da operacao de estorno
                                 ,pr_cdseqfat_ori  IN craplft.cdseqfat%TYPE   --> sequencial da fatura original
                                 ,pr_cdseqfat     OUT craplft.cdseqfat%TYPE   --> sequencial da fatura
                                 ,pr_vldpagto     OUT craplft.vllanmto%TYPE   --> Valor pago
                                 ,pr_vlfatura     OUT craplft.vllanmto%TYPE   --> Valor da fatura                               
                                 ,pr_nmconven     OUT VARCHAR2                --> retorna nome do convenio
                                 ,pr_dscritic     OUT VARCHAR2                --> Retorna critica
                                 ) IS   

    /* ..........................................................................
      Programa : pc_ret_val_darf_estorno        
      Sistema : Internet - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Odirlei Busana - AMcom
      Data    : Maio/2018.                       Ultima atualizacao: 05/04/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado (On-Line)
      Objetivo  : Procedimento para retornar/validar valores de DARF para estorno

      Alteracoes: 
      
    .................................................................................*/
    ----------------> TEMPTABLE  <---------------
    
    ---------------->   CURSOR   <---------------
    --Selecionar cadastro empresas conveniadas
    CURSOR cr_crapcon (pr_cdcooper IN crapcon.cdcooper%type
                      ,pr_cdempcon IN crapcon.cdempcon%type
                      ,pr_cdsegmto IN crapcon.cdsegmto%type) IS
      SELECT crapcon.cdcooper
            ,crapcon.tparrecd
            ,crapcon.cdempcon
            ,crapcon.cdsegmto
            ,crapcon.cdhistor
      FROM crapcon
      WHERE crapcon.cdcooper = pr_cdcooper
        AND crapcon.cdempcon = pr_cdempcon
        AND crapcon.cdsegmto = pr_cdsegmto;
    rw_crapcon cr_crapcon%ROWTYPE;
    
    -- Buscar convenio sicredi
    CURSOR cr_crapscn(pr_cdempres crapscn.cdempres%TYPE,
		                  pr_tpmeiarr crapstn.tpmeiarr%TYPE)IS
      SELECT scn.cdempres
            ,scn.dsnomcnv
            ,scn.dssigemp
            ,stn.cdtransa
        FROM crapscn scn,
             crapstn stn
       WHERE scn.cdempres = pr_cdempres
         AND stn.cdempres = scn.cdempres
         AND stn.tpmeiarr = pr_tpmeiarr;
    rw_crapscn cr_crapscn%ROWTYPE;
    
    -- Buscar transacoes sicredi
    CURSOR cr_crapstn (pr_cdempres  crapstn.cdempres%TYPE)IS
      SELECT stn.dstipdrf
        FROM crapstn stn
       WHERE stn.cdempres = pr_cdempres 
         AND stn.tpmeiarr = 'C';
    rw_crapstn cr_crapstn%ROWTYPE;
    
    --> Convenio Cecred
    CURSOR cr_gnconve (pr_cdhistor gnconve.cdhiscxa%TYPE) IS
      SELECT flgenvpa
        FROM gnconve 
       WHERE gnconve.cdhiscxa = pr_cdhistor;
    rw_gnconve cr_gnconve%ROWTYPE;
        
    --> Selecionar lancamentos de fatura
    CURSOR cr_craplft (pr_cdcooper IN craplft.cdcooper%type
                      ,pr_dtmvtolt IN craplft.dtmvtolt%type
                      ,pr_cdagenci IN craplft.cdagenci%type
                      ,pr_cdbccxlt IN craplft.cdbccxlt%type
                      ,pr_nrdolote IN craplft.nrdolote%type
                      ,pr_cdseqfat IN craplft.cdseqfat%type) IS
      SELECT lft.cdcooper,
             lft.vllanmto,
             lft.flgenvpa,
             lft.cdtribut,
             lft.cdagenci,
             lft.dtapurac,
             lft.nrcpfcgc,
             lft.dtlimite,
             lft.vlrmulta,
             lft.vlrjuros
      FROM craplft lft
      WHERE lft.cdcooper = pr_cdcooper
        AND lft.dtmvtolt = pr_dtmvtolt
        AND lft.cdagenci = pr_cdagenci
        AND lft.cdbccxlt = pr_cdbccxlt
        AND lft.nrdolote = pr_nrdolote
        AND lft.cdseqfat = pr_cdseqfat;
    rw_craplft cr_craplft%ROWTYPE;
    
    --> Buscar lote
    CURSOR cr_craplot ( pr_cdcooper craplot.cdcooper%TYPE,
                        pr_dtmvtocd craplot.dtmvtolt%TYPE,
                        pr_cdagenci craplot.cdagenci%TYPE,
                        pr_nrdolote craplot.nrdolote%TYPE ) IS
      SELECT lot.rowid,
             lot.cdbccxlt,
             lot.nrdolote,
             lot.cdagenci,
             lot.vlcompdb,
             lot.vlinfodb,
             lot.vlcompcr,
             lot.vlinfocr
        FROM craplot lot
       WHERE lot.cdcooper = pr_cdcooper
         AND lot.dtmvtolt = pr_dtmvtocd
         AND lot.cdagenci = pr_cdagenci
         AND lot.cdbccxlt = 11 --> Fixo 
         AND lot.nrdolote = pr_nrdolote;          
     rw_craplot cr_craplot%ROWTYPE;
      
    ----------------> VARIAVEIS <---------------
    --Variaveis de Erro
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_dscritic  VARCHAR2(4000);
    vr_des_erro  VARCHAR2(10);
    --Variaveis de Excecao
    vr_exc_erro  EXCEPTION;

    vr_cdagenci      crapage.cdagenci%TYPE;
    vr_cdhisdeb      craphis.cdhistor%TYPE;
    vr_cdhisest      craphis.cdhistor%TYPE;
    
    vr_flgfatex      BOOLEAN;
    vr_calc          VARCHAR2(100);
    vr_digito        INTEGER;
    vr_retorno       BOOLEAN;
    vr_dstextab      craptab.dstextab%TYPE;
    vr_hrcancel      NUMBER;
    vr_nrdolote      NUMBER;
    vr_vlrtotal      NUMBER;
    -----------> SubPrograma <------------
   

  BEGIN
  
    
    pr_cdseqfat   := 0;
    pr_vlfatura   := 0;    
    vr_flgfatex   := FALSE;
  
    --Verificar se a cooperativa existe
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_cdcritic:= 651;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapcop;
    
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      
      CLOSE BTCH0001.cr_crapdat;      
      vr_cdcritic:= 1;
      RAISE vr_exc_erro;
    ELSE
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    --> Lote - 15000 --- Tipo 13 --- FATURAS 
    vr_nrdolote:= 15000 + pr_nrdcaixa;
    
    --Selecionar lancamentos de fatura
    OPEN cr_craplft (pr_cdcooper => rw_crapcop.cdcooper
                    ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                    ,pr_cdagenci => pr_cdagenci
                    ,pr_cdbccxlt => 11
                    ,pr_nrdolote => vr_nrdolote
                    ,pr_cdseqfat => pr_cdseqfat_ori);
    --Posicionar no proximo registro
    FETCH cr_craplft INTO rw_craplft;
    --Se encontrar
    IF cr_craplft%NOTFOUND THEN
      
      CLOSE cr_craplft;      
      vr_cdcritic := 90;
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_craplft; 
        
    -- Pega o nome do convenio
    OPEN cr_crapscn (pr_cdempres => CASE rw_craplft.cdtribut
                                         WHEN '6106' THEN 'D0'
                                         ELSE 'A0' 
                                    END,
                     pr_tpmeiarr => CASE rw_craplft.cdagenci
                                         WHEN 90 THEN 'D'
                                         ELSE 'C'
                                         END);
    FETCH cr_crapscn INTO rw_crapscn;
    --Se nao encontrar
    IF NOT cr_crapscn%FOUND THEN
      vr_cdcritic:= 0;
      vr_dscritic:= 'Convenio nao encontrado.';
      CLOSE cr_crapscn;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapscn;
        
    -- Buscar transacoes sicredi
    rw_crapstn := NULL;
    OPEN cr_crapstn (pr_cdempres => rw_crapscn.cdempres);
    FETCH cr_crapstn INTO rw_crapstn;
      
    --> Nao permite o estorno de DARFs
    IF cr_crapstn%FOUND AND 
       --> Nao validar qnd for analise de fraude, pois esta deve permitir
       pr_idorigem <> 12 THEN 
         
      CLOSE cr_crapstn;
      IF (TRIM(rw_crapstn.dstipdrf) IS NOT NULL OR
          rw_crapscn.cdempres = 'K0' ) THEN
        vr_dscritic := 'Esta guia nao pode ser estornada.';
        RAISE vr_exc_erro;
      END IF;                 

    ELSE
      CLOSE cr_crapstn;
    END IF;
      
    --> Validaçao relativa ao horario de canc. de pgto de Convenios SICREDI
    vr_dstextab := tabe0001.fn_busca_dstextab( pr_cdcooper => rw_crapcop.cdcooper, 
                                               pr_nmsistem => 'CRED'          , 
                                               pr_tptabela => 'GENERI'        , 
                                               pr_cdempres => 00              , 
                                               pr_cdacesso => 'HRPGSICRED'    , 
                                               pr_tpregist => pr_cdagenci );
      
    IF TRIM(vr_dstextab) IS NULL THEN
      vr_dscritic := 'Parametros nao cadastrados.(HRPGSICRED)';
      RAISE vr_exc_erro;
    END IF;
      
    vr_hrcancel := gene0002.fn_busca_entrada ( pr_postext => 3,
                                               pr_dstext => vr_dstextab,
                                               pr_delimitador => ' ');
      
    --> Verifica se a hora atual é maior do que a do cancelamento
    IF gene0002.fn_busca_time > vr_hrcancel THEN
        
      vr_dscritic := 'Nao permitido estornar faturas do Sicredi apos as ' || 
                     gene0002.fn_converte_time_data(vr_hrcancel) ||' hrs.';
      RAISE vr_exc_erro;               
             
    END IF; 
    
    vr_vlrtotal := (rw_craplft.vllanmto + rw_craplft.vlrmulta + rw_craplft.vlrjuros);
    
    -- Consulta de sequencial único para DARFs
    CXON0041.pc_busca_sequencial_darf(pr_dtapurac => rw_craplft.dtapurac
                                     ,pr_nrcpfcgc => rw_craplft.nrcpfcgc
                                     ,pr_cdtribut => rw_craplft.cdtribut
                                     ,pr_dtlimite => rw_craplft.dtlimite
                                     ,pr_vlrtotal => vr_vlrtotal
                                     ,pr_cdseqfat => pr_cdseqfat
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);

    IF vr_dscritic IS NOT NULL OR
      NVL(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro;   
    END IF;
    
    IF pr_cdseqfat <> pr_cdseqfat_ori THEN
      vr_dscritic := 'Sequencial de fatura invalida.';
      RAISE vr_exc_erro;                      
    END IF;
    
    IF rw_craplft.flgenvpa = 1 THEN           
      vr_dscritic := 'Fatura nao pode ser estornado pois ja foi transmitida.';
      RAISE vr_exc_erro;                      
    END IF;
    
    --> Buscar lote
    OPEN cr_craplot ( pr_cdcooper => rw_crapcop.cdcooper,
                      pr_dtmvtocd => rw_crapdat.dtmvtocd,
                      pr_cdagenci => pr_cdagenci,
                      pr_nrdolote => vr_nrdolote);
    FETCH cr_craplot INTO rw_craplot;
    IF cr_craplot%NOTFOUND THEN
      CLOSE cr_craplot;
      vr_cdcritic := 60;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craplot;
    END IF;
    
    --Retornar valor fatura
    pr_vlfatura:= rw_craplft.vllanmto;    
    --> retorno do valor pago     
    pr_vldpagto := vr_vlrtotal;
    --> 
    pr_nmconven := rw_crapscn.dsnomcnv;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
     
      -- se possui codigo, porém não possui descrição
      IF nvl(vr_cdcritic,0) > 0 AND
         TRIM(vr_dscritic) IS NULL THEN
        -- buscar descrição
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

      END IF;

      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      
      btch0001.pc_log_internal_exception(pr_cdcooper);

      pr_dscritic := 'Erro inesperado ao retornar dados da fatura.: '||SQLERRM;
      
  END pc_ret_val_darf_estornotmp;


  
  --> Procedimento para estornar convenios
  PROCEDURE pc_estorna_conveniotmp ( pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                                 ,pr_nrdconta  IN crapttl.nrdconta%TYPE   --> Numero da conta
                                 ,pr_idseqttl  IN crapttl.idseqttl%TYPE   --> Sequencial titular
                                 ,pr_cdbarras  IN craplft.cdbarras%TYPE   --> Codigo de barras
                                 ,pr_dscedent  IN craplcm.dscedent%TYPE   --> Cedente
                                 ,pr_cdseqfat  IN VARCHAR2                --> sequencial da fatura
                                 ,pr_vlfatura  IN craplft.vllanmto%TYPE   --> Valor da fatura
                                 ,pr_cdoperad  IN crapope.cdoperad%TYPE   --> Codigo do operador
                                 ,pr_idorigem  IN INTEGER                 --> Id de origem da operação
                                 ,pr_dstransa OUT VARCHAR2                --> Retorna Descrição da transação
                                 ,pr_dscritic OUT VARCHAR2                --> Retorna critica
                                 ,pr_dsprotoc OUT crappro.dsprotoc%TYPE   --> Retorna protocolo
                                 ) IS   

    /* ..........................................................................

      Programa : pc_estorna_convenio        Antiga: sistema/generico/procedures/b1wgen0016.p-estorna_convenio
      Sistema : Internet - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Odirlei Busana - AMcom
      Data    : Abril/2018.                       Ultima atualizacao: 03/09/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado (On-Line)
      Objetivo  : Procedimento para estornar convenios

      Alteracoes: 05/04/2018 - Conversão Progress -> Oracle.
                                PRJ381 - Antifraude. (Odirlei-AMcom)
      
                  03/09/2018 - Correção para remover lote (Jonata - Mouts).
    .................................................................................*/
    ---------------->  CURSOR  <---------------
    --Buscar informacoes de lote
    CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
                      ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                      ,pr_cdagenci IN craplot.cdagenci%TYPE
                      ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                      ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
      SELECT  craplot.nrdolote
             ,craplot.nrseqdig
             ,craplot.cdbccxlt
             ,craplot.tplotmov
             ,craplot.dtmvtolt
             ,craplot.cdagenci
             ,craplot.cdhistor
             ,craplot.cdoperad
             ,craplot.qtcompln
             ,craplot.qtinfoln
             ,craplot.vlcompcr
             ,craplot.vlinfocr
             ,craplot.vlcompdb
             ,craplot.vlinfodb
             ,craplot.cdcooper
             ,craplot.rowid
      FROM craplot craplot
      WHERE craplot.cdcooper = pr_cdcooper
      AND   craplot.dtmvtolt = pr_dtmvtolt
      AND   craplot.cdagenci = pr_cdagenci
      AND   craplot.cdbccxlt = pr_cdbccxlt
      AND   craplot.nrdolote = pr_nrdolote
      FOR UPDATE NOWAIT;
    rw_craplot cr_craplot%ROWTYPE;
               
    --> Busca a autenticacao do estorno da fatura 
    CURSOR cr_crapaut (pr_rowid IN ROWID) IS
      SELECT crapaut.cdcooper
            ,crapaut.dtmvtolt
            ,crapaut.cdagenci
            ,crapaut.nrdcaixa
            ,crapaut.vldocmto
            ,crapaut.hrautent
            ,crapaut.nrsequen
            ,crapaut.cdopecxa
            ,crapaut.cdhistor
            ,crapaut.dsprotoc
            ,crapaut.nrdocmto
            ,crapaut.nrseqaut
            ,crapaut.ROWID
      FROM crapaut
      WHERE ROWID = pr_rowid;
    rw_crapaut cr_crapaut%ROWTYPE;

    -- Busca a autenticacao que foi criada no pagamento da fatura
    CURSOR cr_crapaut_sequen (pr_cdcooper IN crapaut.cdcooper%type
                             ,pr_cdagenci IN crapaut.cdagenci%type
                             ,pr_nrdcaixa IN crapaut.nrdcaixa%type
                             ,pr_dtmvtolt IN crapaut.dtmvtolt%type
                             ,pr_nrsequen IN crapaut.nrsequen%type) IS
      SELECT crapaut.cdcooper
            ,crapaut.dtmvtolt
            ,crapaut.cdagenci
            ,crapaut.nrdcaixa
            ,crapaut.vldocmto
            ,crapaut.hrautent
            ,crapaut.nrsequen
            ,crapaut.cdopecxa
            ,crapaut.cdhistor
            ,crapaut.dsprotoc
            ,crapaut.nrdocmto
            ,crapaut.ROWID
      FROM crapaut crapaut
      WHERE crapaut.cdcooper = pr_cdcooper
      AND   crapaut.cdagenci = pr_cdagenci
      AND   crapaut.nrdcaixa = pr_nrdcaixa
      AND   crapaut.dtmvtolt = pr_dtmvtolt
      AND   crapaut.nrsequen = pr_nrsequen;
    rw_crapaut_sequen cr_crapaut_sequen%ROWTYPE;                       
     
    --> Busca a autenticacao criada para o debito no pagamento 
    CURSOR cr_crabaut (pr_cdcooper crapaut.cdcooper%TYPE,
                       pr_dsprotoc crapaut.dsprotoc%TYPE,
                       pr_rowid    ROWID) IS 
      SELECT aut.cdcooper,
             aut.dtmvtolt,
             aut.nrdocmto
        FROM crapaut aut 
       WHERE aut.cdcooper  = pr_cdcooper   
         AND UPPER(aut.dsprotoc)  = UPPER(pr_dsprotoc)
         AND aut.rowid     <> pr_rowid;
    rw_crabaut cr_crabaut%ROWTYPE;       
    
    --Selecionar cadastro empresas conveniadas
    CURSOR cr_crapcon (pr_cdcooper IN crapcon.cdcooper%type
                      ,pr_cdempcon IN crapcon.cdempcon%type
                      ,pr_cdsegmto IN crapcon.cdsegmto%type) IS
      SELECT crapcon.cdcooper
            ,crapcon.tparrecd
            ,crapcon.cdempcon
            ,crapcon.cdsegmto
            ,crapcon.cdhistor
            ,crapcon.nmrescon
      FROM crapcon
      WHERE crapcon.cdcooper = pr_cdcooper
        AND crapcon.cdempcon = pr_cdempcon
        AND crapcon.cdsegmto = pr_cdsegmto;
    rw_crapcon cr_crapcon%ROWTYPE;  
    
    --> Buscar dados da fatura
    CURSOR cr_craplft( pr_cdcooper  craplft.cdcooper%TYPE,
                       pr_nrdconta  craplft.nrdconta%TYPE,
                       pr_dtmvtocd  craplft.dtmvtolt%TYPE,
                       pr_cdagenci  craplft.cdagenci%TYPE,
                       pr_cdbccxlt  craplft.cdbccxlt%TYPE,
                       pr_nrdolote  craplft.nrdolote%TYPE,
                       pr_cdseqfat  craplft.cdseqfat%TYPE) IS
      SELECT lft.tpfatura,
             lft.cdempcon,
             lft.cdsegmto
        FROM craplft lft
       WHERE lft.cdcooper = pr_cdcooper
         AND lft.nrdconta = pr_nrdconta
         AND lft.dtmvtolt = pr_dtmvtocd
         AND lft.cdagenci = pr_cdagenci                         
         AND lft.cdbccxlt = pr_cdbccxlt
         AND lft.nrdolote = pr_nrdolote
         AND lft.cdseqfat = pr_cdseqfat;
    rw_craplft cr_craplft%ROWTYPE;
    
    ----------------> TEMPTABLE  <---------------


    ----------------> VARIAVEIS <---------------
    --Variaveis de Erro
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_dscritic  VARCHAR2(4000);
    vr_des_erro  VARCHAR2(10);
    --Variaveis de Excecao
    vr_exc_erro  EXCEPTION;
    -- Variaveis de XML
    vr_xml_temp VARCHAR2(32767);

    vr_cdagenci      crapage.cdagenci%TYPE;
    vr_cdhisdeb      craphis.cdhistor%TYPE;
    vr_cdhisest      craphis.cdhistor%TYPE;
    
    vr_nrautdoc      craplcm.nrautdoc%type;
    vr_nrseqdig      craplcm.nrseqdig%TYPE :=0 ;
    vr_dslitera      VARCHAR2(32000);
    vr_nrdrecid      ROWID;  
    
    vr_cdseqfat      NUMBER;
    vr_vldpagto      NUMBER;
    vr_vlfatura      NUMBER;
    vr_nrdigfat      NUMBER;
    vr_iptu          INTEGER;
    
    vr_cdbarras      VARCHAR2(100);
    vr_cdhistor      craphis.cdhistor%TYPE;
    vr_flgpagto      INTEGER;
    vr_nrdocmto      NUMBER;
    vr_dsprotoc      crappro.dsprotoc%TYPE;
    vr_tpfatura      craplft.tpfatura%TYPE;
    vr_nmconven      VARCHAR2(100);
    -----------> SubPrograma <------------
   
	-- Procedimento para inserir o lote e não deixar tabela lockada
      PROCEDURE pc_insere_lote (pr_cdcooper IN craplot.cdcooper%TYPE,
                                pr_dtmvtolt IN craplot.dtmvtolt%TYPE,
                                pr_cdagenci IN craplot.cdagenci%TYPE,
                                pr_cdbccxlt IN craplot.cdbccxlt%TYPE,
                                pr_nrdolote IN craplot.nrdolote%TYPE,								
                                pr_cdoperad IN craplot.cdoperad%TYPE,
                                pr_nrdcaixa IN craplot.nrdcaixa%TYPE,
                                pr_tplotmov IN craplot.tplotmov%TYPE,
                                pr_cdhistor IN craplot.cdhistor%TYPE,
                                pr_craplot  OUT cr_craplot%ROWTYPE,
                                pr_dscritic OUT VARCHAR2)IS

        -- Pragma - abre nova sessao para tratar a atualizacao
        PRAGMA AUTONOMOUS_TRANSACTION;

      BEGIN

        /* Tratamento para buscar registro de lote se o mesmo estiver em lock, tenta por 10 seg. */
        FOR i IN 1..100 LOOP
          BEGIN
            -- Leitura do lote
            OPEN cr_craplot (pr_cdcooper  => pr_cdcooper,
                             pr_dtmvtolt  => pr_dtmvtolt,
                             pr_cdagenci  => pr_cdagenci,
                             pr_cdbccxlt  => pr_cdbccxlt,
                             pr_nrdolote  => pr_nrdolote);
            FETCH cr_craplot INTO rw_craplot;
            EXIT;
          EXCEPTION
            WHEN OTHERS THEN
               IF cr_craplot%ISOPEN THEN
                 CLOSE cr_craplot;
               END IF;
               -- setar critica caso for o ultimo
               IF i = 100 THEN
                 pr_dscritic:= 'Registro de lote '||pr_nrdolote||' em uso. Tente novamente.';
               END IF;
               -- aguardar meio segundo seg. antes de tentar novamente
               sys.dbms_lock.sleep(0.1);
          END;
        END LOOP;

        -- se encontrou erro ao buscar lote, abortar programa
        IF pr_dscritic IS NOT NULL THEN
          ROLLBACK;
          RETURN;
        END IF;

        IF cr_craplot%NOTFOUND THEN
          -- criar registros de lote na tabela
          INSERT INTO craplot
                  (craplot.cdcooper
                  ,craplot.dtmvtolt
                  ,craplot.cdagenci
                  ,craplot.cdbccxlt
                  ,craplot.nrdolote                  
                  ,craplot.tplotmov
                  ,craplot.cdoperad
                  ,craplot.cdhistor
                  ,craplot.nrdcaixa
                  ,craplot.cdopecxa)
          VALUES  (pr_cdcooper
                  ,pr_dtmvtolt
                  ,pr_cdagenci
                  ,pr_cdbccxlt
                  ,pr_nrdolote                  
                  ,pr_tplotmov
                  ,pr_cdoperad
                  ,pr_cdhistor
                  ,pr_nrdcaixa
                  ,pr_cdoperad)
             RETURNING craplot.dtmvtolt
                      ,craplot.cdagenci
                      ,craplot.cdbccxlt
                      ,craplot.nrdolote
                      ,craplot.qtcompln
                      ,craplot.qtinfoln
                      ,craplot.vlcompcr
                      ,craplot.vlinfocr
                      ,craplot.ROWID
                 INTO  rw_craplot.dtmvtolt
                      ,rw_craplot.cdagenci
                      ,rw_craplot.cdbccxlt
                      ,rw_craplot.nrdolote
                      ,rw_craplot.qtcompln
                      ,rw_craplot.qtinfoln
                      ,rw_craplot.vlcompcr
                      ,rw_craplot.vlinfocr
                      ,rw_craplot.rowid;
         
        END IF;

        CLOSE cr_craplot;

        -- retornar informações para o programa chamador
        pr_craplot := rw_craplot;

        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          IF cr_craplot%ISOPEN THEN
            CLOSE cr_craplot;
          END IF;
          ROLLBACK;
          -- se ocorreu algum erro durante a criac?o
          pr_dscritic := 'Erro ao gravar craplot('|| pr_nrdolote||'): '||SQLERRM;
      END pc_insere_lote;

  BEGIN
  
    vr_cdbarras := pr_cdbarras;
  
    --> tratamento para TAA 
    IF pr_idorigem = 4 THEN
      vr_cdagenci := 91;
      vr_cdhisdeb := 856;
      vr_cdhisest := 857;
    --> tratamento para ANTIFRAUDE
    ELSIF pr_idorigem = 12 THEN
      vr_cdagenci := 90;
      vr_cdhisdeb := 508;
      vr_cdhisest := 2280;
    ELSE
      vr_cdagenci := 90;
      vr_cdhisdeb := 508;
      vr_cdhisest := 570;
    END IF;
    
    pr_dstransa := 'Estorno de convenio (fatura)';
    
    --Verificar se a cooperativa existe
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_cdcritic:= 651;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapcop;
    
    -- Validar cooperado
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9;
      RAISE vr_exc_erro;      
    ELSE
      CLOSE cr_crapass;
    END IF;    
    
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    IF BTCH0001.cr_crapdat%NOTFOUND THEN      
      CLOSE BTCH0001.cr_crapdat;      
      vr_cdcritic:= 1;
      RAISE vr_exc_erro;
    ELSE
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    SAVEPOINT TRANS_ESTORNO_CONVENIO;
    
    --> Buscar dados da fatura
    rw_craplft  := NULL;
    vr_tpfatura := 0;
    OPEN cr_craplft( pr_cdcooper  => pr_cdcooper,
                     pr_nrdconta  => pr_nrdconta,
                     pr_dtmvtocd  => rw_crapdat.dtmvtocd,
                     pr_cdagenci  => vr_cdagenci,
                     pr_cdbccxlt  => 11,
                     pr_nrdolote  => 15900, /* Lote - 15000 + nrdcaixa --- 900 --- FATURAS ---*/
                     pr_cdseqfat  => pr_cdseqfat);
    FETCH cr_craplft INTO rw_craplft;
    IF cr_craplft%FOUND THEN
      CLOSE cr_craplft;
      vr_tpfatura := rw_craplft.tpfatura;
    ELSE
      CLOSE cr_craplft;
    END IF;
    
    IF TRIM(vr_cdbarras) IS NOT NULL THEN
    
    --> Procedimento para retornar/validar valores para estorno
    pc_ret_val_fatura_estornotmp ( pr_cdcooper => rw_crapcop.cdcooper    --> Codigo da cooperativa
                               ,pr_cdoperad => 996                    --> Codigo do operador
                               ,pr_cdagenci => vr_cdagenci            --> Codigo Agencia
                               ,pr_nrdcaixa => 900                    --> Numero Caixa
                               ,pr_fatura1  => NULL                   --> Parte 1 fatura
                               ,pr_fatura2  => NULL                   --> Parte 2 fatura
                               ,pr_fatura3  => NULL                   --> Parte 3 fatura
                               ,pr_fatura4  => NULL                   --> Parte 4 fatura
                               ,pr_cdbarras => vr_cdbarras            --> Codigo de barras
                               ,pr_idorigem => pr_idorigem            --> Origem do estorno
                               ,pr_cdseqfat => vr_cdseqfat            --> sequencial da fatura
                               ,pr_vldpagto => vr_vldpagto            --> Valor pago
                               ,pr_vlfatura => vr_vlfatura            --> Valor da fatura
                               ,pr_nrdigfat => vr_nrdigfat            --> Digito da fatura
                               ,pr_iptu     => vr_iptu                --> identifica se é iptu                                 
                               ,pr_dscritic => vr_dscritic );         --> Retorna critica
                               
    IF TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_erro;
    END IF;      
    --> Se for fatura DARF s/CodBarras  
    ELSIF rw_craplft.tpfatura = 2 AND 
          rw_craplft.cdempcon = 0 AND
          rw_craplft.cdsegmto = 6 THEN
          
      --> Retornar/validar valores de DARF para estorno
      pc_ret_val_darf_estornotmp ( pr_cdcooper     => rw_crapcop.cdcooper   --> Codigo da cooperativa
                               ,pr_cdoperad     => 996                   --> Codigo do operador
                               ,pr_cdagenci     => vr_cdagenci           --> Codigo Agencia
                               ,pr_nrdcaixa     => 900                   --> Numero Caixa                                 
                               ,pr_idorigem     => pr_idorigem           --> Origem da operacao de estorno
                               ,pr_cdseqfat_ori => pr_cdseqfat           --> sequencial da fatura original
                               ,pr_cdseqfat     => vr_cdseqfat           --> sequencial da fatura
                               ,pr_vldpagto     => vr_vldpagto           --> Valor pago
                               ,pr_vlfatura     => vr_vlfatura           --> Valor da fatura 
                               ,pr_nmconven     => vr_nmconven           --> Nome do convenio
                               ,pr_dscritic     => vr_dscritic  );       --> Retorna critica

    
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF; 
      
      IF nvl(vr_vldpagto,0) <> nvl(pr_vlfatura,0) THEN
        vr_dscritic := 'Valor para estorno difere do valor total do lancamento.';
        RAISE vr_exc_erro;
      END IF;
      
    ELSE
      vr_dscritic := 'Fatura sem codbarras não pode ser estornada.';
      RAISE vr_exc_erro;
    END IF;
    --> Procedure para estornar faturas
    cxon0014.pc_estorna_faturas( pr_cdcooper  => rw_crapcop.cdcooper  --Codigo Cooperativa
                                ,pr_cdoperad  => '996'                --Codigo Operador
                                ,pr_cdagenci  => vr_cdagenci          --Codigo Agencia
                                ,pr_nrdcaixa  => 900                  --Numero Caixa
                                ,pr_cddbarra  => vr_cdbarras          --Codigo de Barras
                                ,pr_cdseqfat  => pr_cdseqfat          --Codigo sequencial da fatura 
                                ,pr_cdhistor  => vr_cdhistor          --Codigo Historico
                                ,pr_pg        => vr_flgpagto          --Indicador Pago
                                ,pr_nrdocmto  => vr_nrdocmto          --Numero Documento
                                ,pr_cdcritic  => vr_cdcritic          --Codigo do erro
                                ,pr_dscritic  => vr_dscritic );       --Descricao do erro                       
   
    IF nvl(vr_cdcritic,0) <> 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;   
    
    --> Grava autenticacao do estorno da fatura
    CXON0000.pc_grava_autenticacao (pr_cooper       => rw_crapcop.cdcooper   --Codigo Cooperativa
                                   ,pr_cod_agencia  => vr_cdagenci   --Codigo Agencia
                                   ,pr_nro_caixa    => 900   --Numero do caixa
                                   ,pr_cod_operador => 996   --Codigo Operador
                                   ,pr_valor        => pr_vlfatura   --Valor da transacao
                                   ,pr_docto        => vr_nrdocmto   --Numero documento
                                   ,pr_operacao     => TRUE           --Indicador Operacao Debito
                                   ,pr_status       => '1'            --Status da Operacao - Online
                                   ,pr_estorno      => TRUE           --Indicador Estorno
                                   ,pr_histor       => vr_cdhistor    --Historico
                                   ,pr_data_off     => NULL           --Data Transacao
                                   ,pr_sequen_off   => 0              --Sequencia
                                   ,pr_hora_off     => 0              --Hora transacao
                                   ,pr_seq_aut_off  => 0              --Sequencia automatica
                                   ,pr_literal      => vr_dslitera    --Descricao literal
                                   ,pr_sequencia    => vr_nrautdoc    --Sequencia
                                   ,pr_registro     => vr_nrdrecid    --ROWID do registro
                                   ,pr_cdcritic     => vr_cdcritic    --Código do erro
                                   ,pr_dscritic     => vr_dscritic);  --Descricao do erro
    IF nvl(vr_cdcritic,0) <> 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      vr_cdcritic:= 0;
      vr_dscritic:= 'Erro no estorno da Fatura: '||vr_dscritic;
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    --> Busca a autenticacao do estorno da fatura 
    OPEN cr_crapaut (pr_rowid => vr_nrdrecid);
    FETCH cr_crapaut INTO rw_crapaut;
    CLOSE cr_crapaut;
    
    -- Busca a autenticacao que foi criada no pagamento da fatura
    OPEN cr_crapaut_sequen (pr_cdcooper => rw_crapaut.cdcooper
                           ,pr_cdagenci => rw_crapaut.cdagenci 
                           ,pr_nrdcaixa => rw_crapaut.nrdcaixa
                           ,pr_dtmvtolt => rw_crapaut.dtmvtolt
                           ,pr_nrsequen => rw_crapaut.nrseqaut);
    FETCH cr_crapaut_sequen INTO rw_crapaut_sequen;
    CLOSE cr_crapaut_sequen;
    
    --> Busca a autenticacao criada para o debito no pagamento 
    OPEN cr_crabaut (pr_cdcooper => rw_crapaut_sequen.cdcooper,
                     pr_dsprotoc => rw_crapaut_sequen.dsprotoc,
                     pr_rowid    => rw_crapaut_sequen.ROWID);
    FETCH cr_crabaut INTO rw_crabaut;
    IF cr_crabaut%NOTFOUND THEN
      CLOSE cr_crabaut;
      vr_dscritic:= 'Autenticacao do debito nao encontrada.';
      RAISE vr_exc_erro;
      
    ELSE
      CLOSE cr_crabaut;
    END IF;
    
    vr_nrseqdig := fn_sequence('CRAPLOT'
                              ,'NRSEQDIG'
                              ,''||rw_crapaut_sequen.cdcooper||';'
                                 ||to_char(rw_crapaut_sequen.dtmvtolt,'DD/MM/RRRR')||';'
                                 ||rw_crapaut_sequen.cdagenci||';'
                                 ||11||';'
                                 ||11900);
    rw_craplot := NULL;
                              
	  -- Controlar criação de lote, com pragma
    pc_insere_lote (pr_cdcooper => rw_crapaut_sequen.cdcooper,
                    pr_dtmvtolt => rw_crapaut_sequen.dtmvtolt,
                    pr_cdagenci => rw_crapaut_sequen.cdagenci,
                    pr_cdbccxlt => 11,
                    pr_nrdolote => 11900,
                    pr_cdoperad => pr_cdoperad,
                    pr_nrdcaixa => rw_crapaut_sequen.nrdcaixa,
                    pr_tplotmov => 1,
                    pr_cdhistor => vr_cdhisdeb,
                    pr_craplot  => rw_craplot,
                    pr_dscritic => vr_dscritic);    
                           
    -- se encontrou erro ao buscar lote, abortar programa
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    --> Coloca a informacao de estorno no protocolo, usando os dados da
    -->    autenticacao do debito em conta
    GENE0006.pc_estorna_protocolo(pr_cdcooper => rw_crabaut.cdcooper,
                                  pr_dtmvtolt => rw_crabaut.dtmvtolt,
                                  pr_nrdconta => pr_nrdconta,
                                  pr_cdtippro => (CASE 
                                                      WHEN vr_tpfatura = 1 THEN 17--> DARF
                                                      WHEN vr_tpfatura = 2 THEN 16--> DAS
                                                      WHEN vr_tpfatura = 3 THEN 24--> FGTS
                                                      WHEN vr_tpfatura = 4 THEN 23--> DAE 
                                                      WHEN pr_idorigem = 4 THEN 6 --> Tipo - Pagamento TAA
                                                      ELSE 2                      --> Tipo - Pagamento INTERNET
                                                   END),
                                  pr_nrdocmto => rw_crabaut.nrdocmto,
                                  pr_dsprotoc => vr_dsprotoc,     --> Descrição do protocolo
                                  pr_retorno  => vr_dscritic);
    IF nvl(vr_dscritic,'OK')<> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;
    
    --> Grava uma autenticacao para o CREDITO na conta    
    CXON0000.pc_grava_autenticacao_internet (pr_cooper       => rw_crapcop.cdcooper  --Codigo Cooperativa
                                            ,pr_nrdconta     => pr_nrdconta          --Numero da Conta
                                            ,pr_idseqttl     => pr_idseqttl          --Sequencial do titular
                                            ,pr_cod_agencia  => vr_cdagenci          --Codigo Agencia
                                            ,pr_nro_caixa    => 900                  --Numero do caixa
                                            ,pr_cod_operador => '996'                --Codigo Operador
                                            ,pr_valor        => pr_vlfatura     --Valor da transacao
                                            ,pr_docto        => rw_crabaut.nrdocmto  --Numero documento
                                            ,pr_operacao     => FALSE            --Indicador Operacao Debito
                                            ,pr_status       => '1'             --Status da Operacao - Online
                                            ,pr_estorno      => TRUE           --Indicador Estorno
                                            ,pr_histor       => vr_cdhisdeb     --Historico Debito
                                            ,pr_data_off     => NULL            --Data Transacao
                                            ,pr_sequen_off   => 0               --Sequencia
                                            ,pr_hora_off     => 0               --Hora transacao
                                            ,pr_seq_aut_off  => 0               --Sequencia automatica
                                            ,pr_cdempres     => NULL            --Descricao Observacao
                                            ,pr_literal      => vr_dslitera     --Descricao literal lcm
                                            ,pr_sequencia    => vr_nrautdoc    --Sequencia
                                            ,pr_registro     => vr_nrdrecid    --ROWID do registro debito
                                            ,pr_cdcritic     => vr_cdcritic    --Código do erro
                                            ,pr_dscritic     => vr_dscritic);  --Descricao do erro
    --Se ocorreu erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      vr_cdcritic:= 0;
      vr_dscritic:= 'Erro na autenticacao do credito.('||vr_dscritic||')';
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    --> Buscar a autenticacao do credito do estorno
    rw_crapaut := NULL;
    OPEN cr_crapaut (pr_rowid => vr_nrdrecid);
    FETCH cr_crapaut INTO rw_crapaut;
    CLOSE cr_crapaut;
    
    IF TRIM(pr_cdbarras) IS NOT NULL THEN
      --Selecionar cadastro empresas conveniadas
      OPEN cr_crapcon (pr_cdcooper => rw_crapcop.cdcooper
                      ,pr_cdempcon => to_number(SUBSTR(pr_cdbarras,16,4))
                      ,pr_cdsegmto => to_number(SUBSTR(pr_cdbarras,2,1)));
      --Posicionar no proximo registro
      FETCH cr_crapcon INTO rw_crapcon;
      IF cr_crapcon%NOTFOUND THEN
        CLOSE cr_crapcon;
        vr_dscritic := 'Empresa nao Conveniada '||SUBSTR(pr_cdbarras,2,1) ||
                                               '/'||SUBSTR(pr_cdbarras,16,4);
        RAISE vr_exc_erro;                                       
      ELSE
        CLOSE cr_crapcon;
      END IF;
      
      vr_nmconven := rw_crapcon.nmrescon;  
    END IF;

    BEGIN
      INSERT INTO craplcm 
                 ( cdcooper
                  ,dtmvtolt
                  ,cdagenci
                  ,cdbccxlt
                  ,nrdolote
                  ,dtrefere
                  ,hrtransa
                  ,cdoperad
                  ,nrdconta
                  ,nrdctabb
                  ,nrdctitg
                  ,nrdocmto
                  ,nrsequni
                  ,nrseqdig
                  ,cdhistor
                  ,vllanmto
                  ,nrautdoc
                  ,dscedent
                  ,cdpesqbb)      
           VALUES (rw_crapaut.cdcooper        -- cdcooper
                  ,rw_crapaut.dtmvtolt        -- dtmvtolt
                  ,rw_crapaut.cdagenci        -- cdagenci
                  ,11                         -- cdbccxlt
                  ,11900                      -- nrdolote
                  ,rw_crapaut.dtmvtolt        -- dtrefere
                  ,gene0002.fn_busca_time     -- hrtransa
                  ,rw_crapaut.cdopecxa        -- cdoperad
                  ,pr_nrdconta                -- nrdconta
                  ,pr_nrdconta                -- nrdctabb
                  ,to_char(pr_nrdconta,'fm00000000') -- nrdctitg
                  ,vr_nrseqdig                -- nrdocmto
                  ,vr_nrseqdig                -- nrsequni
                  ,vr_nrseqdig                -- nrseqdig
                  ,vr_cdhisest                -- cdhistor
                  ,rw_crapaut.vldocmto        -- vllanmto
                  ,rw_crapaut.nrsequen        -- nrautdoc
                  ,pr_dscedent                -- dscedent
                  ,( CASE 
                       WHEN pr_idorigem = 4 THEN
                          'TAA - ESTORNO PAGAMENTO ON-LINE - CONVENIO '|| vr_nmconven
                       ELSE
                          'INTERNET - ESTORNO PAGAMENTO ON-LINE - CONVENIO '|| vr_nmconven
                     END          
                   )      -- cdpesqbb
                  );
    
    EXCEPTION 
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir lançamento de credito de estorno: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    --> Cria o registro do movimento da internet 
    IF  pr_idorigem <> 4  THEN --> TAA 
      
      IF rw_crapass.idastcjt = 0 THEN
        -- Atualiza o registro de movimento da internet
        paga0001.pc_insere_movimento_internet(pr_cdcooper => pr_cdcooper     
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_idseqttl => pr_idseqttl
                                             ,pr_dtmvtolt => rw_crapaut.dtmvtolt
                                             ,pr_cdoperad => rw_crapaut.cdopecxa
                                             ,pr_inpessoa => rw_crapass.inpessoa
                                             ,pr_tpoperac => 2 -- Pagamento
                                             ,pr_vllanmto => (pr_vlfatura * -1) -- Diminuir valor
                                             ,pr_dscritic => vr_dscritic);

        --Levantar Excecao
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      ELSE
      
        FOR rw_crappod IN cr_crappod(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta) LOOP

          OPEN cr_crapsnh2(pr_cdcooper => rw_crappod.cdcooper
                          ,pr_nrdconta => rw_crappod.nrdconta
                          ,pr_nrcpfcgc => rw_crappod.nrcpfpro);

          FETCH cr_crapsnh2 INTO rw_crapsnh2;

          IF cr_crapsnh2%NOTFOUND THEN
            CLOSE cr_crapsnh2;
            CONTINUE;
          ELSE
            CLOSE cr_crapsnh2;
          END IF;

          -- Atualiza o registro de movimento da internet
          paga0001.pc_insere_movimento_internet(pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_idseqttl => rw_crapsnh2.idseqttl
                                               ,pr_dtmvtolt => rw_crapaut.dtmvtolt
                                               ,pr_cdoperad => rw_crapaut.cdopecxa
                                               ,pr_inpessoa => rw_crapass.inpessoa
                                               ,pr_tpoperac => 2 -- Pagamento
                                               ,pr_vllanmto => (pr_vlfatura * -1) -- Diminuir valor
                                               ,pr_dscritic => vr_dscritic);

          --Levantar Excecao
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

        END LOOP;
      
      
      END IF;
    END IF;
    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK TO TRANS_ESTORNO_CONVENIO;
      -- se possui codigo, porém não possui descrição
      IF nvl(vr_cdcritic,0) > 0 AND
         TRIM(vr_dscritic) IS NULL THEN
        -- buscar descrição
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

      END IF;

      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      ROLLBACK TO TRANS_ESTORNO_CONVENIO;
      btch0001.pc_log_internal_exception(pr_cdcooper);

      pr_dscritic := 'Erro inesperado ao estornar fatura.: '||SQLERRM;
      
  END pc_estorna_conveniotmp;
  
  --> Procedimento para estornar titulo
  PROCEDURE pc_estorna_titulotmp ( pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                               ,pr_cdagenci  IN crapage.cdagenci%TYPE   --> Codigo da agencia
                               ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE   --> Data de movimento
                               ,pr_nrdconta  IN crapttl.nrdconta%TYPE   --> Numero da conta
                               ,pr_idseqttl  IN crapttl.idseqttl%TYPE   --> Sequencial titular
                               ,pr_cdbarras  IN craplft.cdbarras%TYPE   --> Codigo de barras
                               ,pr_dscedent  IN craplcm.dscedent%TYPE   --> Cedente
                               ,pr_vlfatura  IN craplft.vllanmto%TYPE   --> Valor da fatura
                               ,pr_cdoperad  IN crapope.cdoperad%TYPE   --> Codigo do operador
                               ,pr_idorigem  IN INTEGER                 --> Id de origem da operação
                               ,pr_cdctrbxo  IN VARCHAR2                --> Codigo de controle de baixa
                               ,pr_nrdident  IN VARCHAR2                --> Identificador do titulo NPC
                               ,pr_dstransa OUT VARCHAR2                --> Retorna Descrição da transação
                               ,pr_dscritic OUT VARCHAR2                --> Retorna critica
                               ,pr_dsprotoc OUT crappro.dsprotoc%TYPE   --> Retorna protocolo
                               ) IS   

    /* ..........................................................................

      Programa : pc_estorna_titulo        Antiga: sistema/generico/procedures/b1wgen0016.p-estorna_titulo
      Sistema : Internet - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Odirlei Busana - AMcom
      Data    : Abril/2018.                       Ultima atualizacao: 03/09/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado (On-Line)
      Objetivo  : Procedimento para estornar titulo

      Alteracoes: 11/04/2018 - Conversão Progress -> Oracle.
                                PRJ381 - Antifraude. (Odirlei-AMcom)
      
                  03/09/2018 - Correção para remover lote (Jonata - Mouts).
    .................................................................................*/
    ---------------->  CURSOR  <---------------
    --Buscar informacoes de lote
    CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
                      ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                      ,pr_cdagenci IN craplot.cdagenci%TYPE
                      ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                      ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
      SELECT  craplot.nrdolote
             ,craplot.nrseqdig
             ,craplot.cdbccxlt
             ,craplot.tplotmov
             ,craplot.dtmvtolt
             ,craplot.cdagenci
             ,craplot.cdhistor
             ,craplot.cdoperad
             ,craplot.qtcompln
             ,craplot.qtinfoln
             ,craplot.vlcompcr
             ,craplot.vlinfocr
             ,craplot.vlcompdb
             ,craplot.vlinfodb
             ,craplot.cdcooper
             ,craplot.rowid
      FROM craplot craplot
      WHERE craplot.cdcooper = pr_cdcooper
      AND   craplot.dtmvtolt = pr_dtmvtolt
      AND   craplot.cdagenci = pr_cdagenci
      AND   craplot.cdbccxlt = pr_cdbccxlt
      AND   craplot.nrdolote = pr_nrdolote
      FOR UPDATE NOWAIT;
    rw_craplot cr_craplot%ROWTYPE;
    
    --> Busca a autenticacao do estorno da fatura 
    CURSOR cr_crapaut (pr_rowid IN ROWID) IS
      SELECT crapaut.cdcooper
            ,crapaut.dtmvtolt
            ,crapaut.cdagenci
            ,crapaut.nrdcaixa
            ,crapaut.vldocmto
            ,crapaut.hrautent
            ,crapaut.nrsequen
            ,crapaut.cdopecxa
            ,crapaut.cdhistor
            ,crapaut.dsprotoc
            ,crapaut.nrdocmto
            ,crapaut.nrseqaut
            ,crapaut.ROWID
      FROM crapaut
      WHERE ROWID = pr_rowid;
    rw_crapaut cr_crapaut%ROWTYPE;

    -- Busca a autenticacao que foi criada no pagamento da fatura
    CURSOR cr_crapaut_sequen (pr_cdcooper IN crapaut.cdcooper%type
                             ,pr_cdagenci IN crapaut.cdagenci%type
                             ,pr_nrdcaixa IN crapaut.nrdcaixa%type
                             ,pr_dtmvtolt IN crapaut.dtmvtolt%type
                             ,pr_nrsequen IN crapaut.nrsequen%type) IS
      SELECT crapaut.cdcooper
            ,crapaut.dtmvtolt
            ,crapaut.cdagenci
            ,crapaut.nrdcaixa
            ,crapaut.vldocmto
            ,crapaut.hrautent
            ,crapaut.nrsequen
            ,crapaut.cdopecxa
            ,crapaut.cdhistor
            ,crapaut.dsprotoc
            ,crapaut.nrdocmto
            ,crapaut.ROWID
      FROM crapaut crapaut
      WHERE crapaut.cdcooper = pr_cdcooper
      AND   crapaut.cdagenci = pr_cdagenci
      AND   crapaut.nrdcaixa = pr_nrdcaixa
      AND   crapaut.dtmvtolt = pr_dtmvtolt
      AND   crapaut.nrsequen = pr_nrsequen;
    rw_crapaut_sequen cr_crapaut_sequen%ROWTYPE;                       
     
    --> Busca a autenticacao criada para o debito no pagamento 
    CURSOR cr_crabaut (pr_cdcooper crapaut.cdcooper%TYPE,
                       pr_dsprotoc crapaut.dsprotoc%TYPE,
                       pr_rowid    ROWID) IS 
      SELECT aut.cdcooper,
             aut.dtmvtolt,
             aut.nrdocmto
        FROM crapaut aut 
       WHERE aut.cdcooper  = pr_cdcooper   
         AND UPPER(aut.dsprotoc)  = UPPER(pr_dsprotoc)
         AND aut.rowid     <> pr_rowid;
    rw_crabaut cr_crabaut%ROWTYPE;       
    
    --Buscar dados do banco
    CURSOR cr_crapban (pr_cdbccxlt IN crapban.cdbccxlt%TYPE) IS
      SELECT ban.nmextbcc
        FROM crapban ban
       WHERE ban.cdbccxlt = pr_cdbccxlt;
    rw_crapban cr_crapban%ROWTYPE;  
    
    ----------------> TEMPTABLE  <---------------


    ----------------> VARIAVEIS <---------------
    --Variaveis de Erro
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_dscritic  VARCHAR2(4000);
    vr_des_erro  VARCHAR2(10);
    --Variaveis de Excecao
    vr_exc_erro  EXCEPTION;
    -- Variaveis de XML
    vr_xml_temp VARCHAR2(32767);

    vr_cdagenci      crapage.cdagenci%TYPE;
    vr_cdhisdeb      craphis.cdhistor%TYPE;
    vr_cdhisest      craphis.cdhistor%TYPE;
    
    vr_nrautdoc      craplcm.nrautdoc%type;
    vr_nrseqdig      craplcm.nrseqdig%TYPE := 0;
    vr_dslitera      VARCHAR2(32000);
    vr_nrdrecid      ROWID;  
    
    vr_cdseqfat      NUMBER;
    vr_vldpagto      NUMBER;
    vr_vlfatura      NUMBER;
    vr_nrdigfat      NUMBER;
    vr_iptu          INTEGER;
    
    vr_cdbarras      VARCHAR2(100);
    vr_cdhistor      craphis.cdhistor%TYPE;
    vr_flgpagto      INTEGER;
    vr_nrdocmto      NUMBER;
    vr_dsprotoc      crappro.dsprotoc%TYPE;
    vr_pg            INTEGER;
    
    vr_idpenden      NUMBER;
    -----------> SubPrograma <------------
   
	-- Procedimento para inserir o lote e não deixar tabela lockada
      PROCEDURE pc_insere_lote (pr_cdcooper IN craplot.cdcooper%TYPE,
                                pr_dtmvtolt IN craplot.dtmvtolt%TYPE,
                                pr_cdagenci IN craplot.cdagenci%TYPE,
                                pr_cdbccxlt IN craplot.cdbccxlt%TYPE,
                                pr_nrdolote IN craplot.nrdolote%TYPE,								
                                pr_cdoperad IN craplot.cdoperad%TYPE,
                                pr_nrdcaixa IN craplot.nrdcaixa%TYPE,
                                pr_tplotmov IN craplot.tplotmov%TYPE,
                                pr_cdhistor IN craplot.cdhistor%TYPE,
                                pr_craplot  OUT cr_craplot%ROWTYPE,
                                pr_dscritic OUT VARCHAR2)IS

        -- Pragma - abre nova sessao para tratar a atualizacao
        PRAGMA AUTONOMOUS_TRANSACTION;

      BEGIN

        /* Tratamento para buscar registro de lote se o mesmo estiver em lock, tenta por 10 seg. */
        FOR i IN 1..100 LOOP
          BEGIN
            -- Leitura do lote
            OPEN cr_craplot (pr_cdcooper  => pr_cdcooper,
                             pr_dtmvtolt  => pr_dtmvtolt,
                             pr_cdagenci  => pr_cdagenci,
                             pr_cdbccxlt  => pr_cdbccxlt,
                             pr_nrdolote  => pr_nrdolote);
            FETCH cr_craplot INTO rw_craplot;
            EXIT;
          EXCEPTION
            WHEN OTHERS THEN
               IF cr_craplot%ISOPEN THEN
                 CLOSE cr_craplot;
               END IF;
               -- setar critica caso for o ultimo
               IF i = 100 THEN
                 pr_dscritic:= 'Registro de lote '||pr_nrdolote||' em uso. Tente novamente.';
               END IF;
               -- aguardar meio segundo seg. antes de tentar novamente
               sys.dbms_lock.sleep(0.1);
          END;
        END LOOP;

        -- se encontrou erro ao buscar lote, abortar programa
        IF pr_dscritic IS NOT NULL THEN
          ROLLBACK;
          RETURN;
        END IF;

        IF cr_craplot%NOTFOUND THEN
          -- criar registros de lote na tabela
          INSERT INTO craplot
                  (craplot.cdcooper
                  ,craplot.dtmvtolt
                  ,craplot.cdagenci
                  ,craplot.cdbccxlt
                  ,craplot.nrdolote                  
                  ,craplot.tplotmov
                  ,craplot.cdoperad
                  ,craplot.cdhistor
                  ,craplot.nrdcaixa
                  ,craplot.cdopecxa)
          VALUES  (pr_cdcooper
                  ,pr_dtmvtolt
                  ,pr_cdagenci
                  ,pr_cdbccxlt
                  ,pr_nrdolote                  
                  ,pr_tplotmov
                  ,pr_cdoperad
                  ,pr_cdhistor
                  ,pr_nrdcaixa
                  ,pr_cdoperad)
             RETURNING craplot.dtmvtolt
                      ,craplot.cdagenci
                      ,craplot.cdbccxlt
                      ,craplot.nrdolote
                      ,craplot.qtcompln
                      ,craplot.qtinfoln
                      ,craplot.vlcompcr
                      ,craplot.vlinfocr
                      ,craplot.ROWID
                 INTO  rw_craplot.dtmvtolt
                      ,rw_craplot.cdagenci
                      ,rw_craplot.cdbccxlt
                      ,rw_craplot.nrdolote
                      ,rw_craplot.qtcompln
                      ,rw_craplot.qtinfoln
                      ,rw_craplot.vlcompcr
                      ,rw_craplot.vlinfocr
                      ,rw_craplot.rowid;
         
        END IF;

        CLOSE cr_craplot;

        -- retornar informações para o programa chamador
        pr_craplot := rw_craplot;

        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          IF cr_craplot%ISOPEN THEN
            CLOSE cr_craplot;
          END IF;
          ROLLBACK;
          -- se ocorreu algum erro durante a criac?o
          pr_dscritic := 'Erro ao gravar craplot('|| pr_nrdolote||'): '||SQLERRM;
      END pc_insere_lote;

  BEGIN
  
    vr_cdbarras := pr_cdbarras;
    
    --> tratamento para TAA 
    IF pr_idorigem = 4 THEN
      vr_cdagenci := 91;
      vr_cdhisdeb := 856;
      vr_cdhisest := 857;
    --> tratamento para ANTIFRAUDE
    ELSIF pr_idorigem = 12 THEN
      vr_cdagenci := 90;
      vr_cdhisdeb := 508;
      vr_cdhisest := 2280;
    ELSE
      vr_cdagenci := 90;
      vr_cdhisdeb := 508;
      vr_cdhisest := 570;
    END IF;
    
    pr_dstransa := 'Estorno de titulo';
    
    --Verificar se a cooperativa existe
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_cdcritic:= 651;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapcop;
    
    -- Validar cooperado
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9;
      RAISE vr_exc_erro;      
    ELSE
      CLOSE cr_crapass;
    END IF; 
    
    SAVEPOINT TRANS_ESTORNO_TITULO;
    
    --> Estornar títulos iptu
    cxon0014.pc_estorna_titulos_iptu ( pr_cdcooper      => rw_crapcop.cdcooper    --Codigo Cooperativa
                                      ,pr_cod_operador  => '996'                  --Codigo Operador
                                      ,pr_cod_agencia   => vr_cdagenci            --Codigo Agencia
                                      ,pr_nro_caixa     => 900                    --Numero Caixa
                                      ,pr_iptu          => 0                      --IPTU
                                      ,pr_codigo_barras => vr_cdbarras            -- Codigo de Barras
                                      ,pr_histor        => vr_cdhistor            --Codigo Historico
                                      ,pr_pg            => vr_pg                  --Indicador Pago
                                      ,pr_docto         => vr_nrdocmto            --Numero Documento
                                      ,pr_cdcritic      => vr_cdcritic            --Codigo do erro
                                      ,pr_dscritic      => vr_dscritic);          --Descricao do erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      vr_dscritic:= 'Erro no estorno da Titulo: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF;     
    
    --> Grava autenticacao do estorno da fatura
    CXON0000.pc_grava_autenticacao (pr_cooper       => rw_crapcop.cdcooper   --Codigo Cooperativa
                                   ,pr_cod_agencia  => vr_cdagenci   --Codigo Agencia
                                   ,pr_nro_caixa    => 900   --Numero do caixa
                                   ,pr_cod_operador => 996   --Codigo Operador
                                   ,pr_valor        => pr_vlfatura   --Valor da transacao
                                   ,pr_docto        => vr_nrdocmto   --Numero documento
                                   ,pr_operacao     => TRUE           --Indicador Operacao Debito
                                   ,pr_status       => '1'            --Status da Operacao - Online
                                   ,pr_estorno      => TRUE           --Indicador Estorno
                                   ,pr_histor       => vr_cdhistor    --Historico
                                   ,pr_data_off     => NULL           --Data Transacao
                                   ,pr_sequen_off   => 0              --Sequencia
                                   ,pr_hora_off     => 0              --Hora transacao
                                   ,pr_seq_aut_off  => 0              --Sequencia automatica
                                   ,pr_literal      => vr_dslitera    --Descricao literal
                                   ,pr_sequencia    => vr_nrautdoc    --Sequencia
                                   ,pr_registro     => vr_nrdrecid    --ROWID do registro
                                   ,pr_cdcritic     => vr_cdcritic    --Código do erro
                                   ,pr_dscritic     => vr_dscritic);  --Descricao do erro
    IF nvl(vr_cdcritic,0) <> 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      vr_cdcritic:= 0;
      vr_dscritic:= 'Erro no estorno da Titulo: '||vr_dscritic;
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    --> Busca a autenticacao do estorno da fatura 
    OPEN cr_crapaut (pr_rowid => vr_nrdrecid);
    FETCH cr_crapaut INTO rw_crapaut;
    CLOSE cr_crapaut;
    
    -- Busca a autenticacao que foi criada no pagamento da fatura
    OPEN cr_crapaut_sequen (pr_cdcooper => rw_crapaut.cdcooper
                           ,pr_cdagenci => rw_crapaut.cdagenci 
                           ,pr_nrdcaixa => rw_crapaut.nrdcaixa
                           ,pr_dtmvtolt => rw_crapaut.dtmvtolt
                           ,pr_nrsequen => rw_crapaut.nrseqaut);
    FETCH cr_crapaut_sequen INTO rw_crapaut_sequen;
    CLOSE cr_crapaut_sequen;
    
    --> Busca a autenticacao criada para o debito no pagamento 
    OPEN cr_crabaut (pr_cdcooper => rw_crapaut_sequen.cdcooper,
                     pr_dsprotoc => rw_crapaut_sequen.dsprotoc,
                     pr_rowid    => rw_crapaut_sequen.ROWID);
    FETCH cr_crabaut INTO rw_crabaut;
    IF cr_crabaut%NOTFOUND THEN
      CLOSE cr_crabaut;
      vr_dscritic:= 'Autenticacao do debito nao encontrada.';
      RAISE vr_exc_erro;
      
    ELSE
      CLOSE cr_crabaut;
    END IF;
    
    vr_nrseqdig := fn_sequence('CRAPLOT'
                              ,'NRSEQDIG'
                              ,''||rw_crapaut_sequen.cdcooper||';'
                                 ||to_char(rw_crapaut_sequen.dtmvtolt,'DD/MM/RRRR')||';'
                                 ||rw_crapaut_sequen.cdagenci||';'
                                 ||11||';'
                                 ||11900);
    rw_craplot := NULL;
	-- Controlar criação de lote, com pragma
    pc_insere_lote (pr_cdcooper => rw_crapaut_sequen.cdcooper,
                    pr_dtmvtolt => rw_crapaut_sequen.dtmvtolt,
                    pr_cdagenci => rw_crapaut_sequen.cdagenci,
                    pr_cdbccxlt => 11,
                    pr_nrdolote => 11900,
                    pr_cdoperad => pr_cdoperad,
                    pr_nrdcaixa => rw_crapaut_sequen.nrdcaixa,
                    pr_tplotmov => 1,
                    pr_cdhistor => vr_cdhisdeb,
                    pr_craplot  => rw_craplot,
                    pr_dscritic => vr_dscritic);   					    
                           
    -- se encontrou erro ao buscar lote, abortar programa
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    
    --> Coloca a informacao de estorno no protocolo, usando os dados da
    -->    autenticacao do debito em conta
    GENE0006.pc_estorna_protocolo(pr_cdcooper => rw_crabaut.cdcooper,
                                  pr_dtmvtolt => rw_crabaut.dtmvtolt,
                                  pr_nrdconta => pr_nrdconta,
                                  pr_cdtippro => (CASE 
                                                      WHEN pr_idorigem = 4 THEN 6 --> Tipo - Pagamento TAA
                                                      ELSE 2                      --> Tipo - Pagamento INTERNET
                                                   END),
                                  pr_nrdocmto => rw_crabaut.nrdocmto,
                                  pr_dsprotoc => vr_dsprotoc,     --> Descrição do protocolo
                                  pr_retorno  => vr_dscritic);
    IF nvl(vr_dscritic,'OK')<> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;
    
    --> Grava uma autenticacao para o CREDITO na conta    
    CXON0000.pc_grava_autenticacao_internet (pr_cooper       => rw_crapcop.cdcooper  --Codigo Cooperativa
                                            ,pr_nrdconta     => pr_nrdconta          --Numero da Conta
                                            ,pr_idseqttl     => pr_idseqttl          --Sequencial do titular
                                            ,pr_cod_agencia  => vr_cdagenci          --Codigo Agencia
                                            ,pr_nro_caixa    => 900                  --Numero do caixa
                                            ,pr_cod_operador => '996'                --Codigo Operador
                                            ,pr_valor        => pr_vlfatura     --Valor da transacao
                                            ,pr_docto        => rw_crabaut.nrdocmto  --Numero documento
                                            ,pr_operacao     => FALSE            --Indicador Operacao Debito
                                            ,pr_status       => '1'             --Status da Operacao - Online
                                            ,pr_estorno      => TRUE           --Indicador Estorno
                                            ,pr_histor       => vr_cdhisdeb     --Historico Debito
                                            ,pr_data_off     => NULL            --Data Transacao
                                            ,pr_sequen_off   => 0               --Sequencia
                                            ,pr_hora_off     => 0               --Hora transacao
                                            ,pr_seq_aut_off  => 0               --Sequencia automatica
                                            ,pr_cdempres     => NULL            --Descricao Observacao
                                            ,pr_literal      => vr_dslitera     --Descricao literal lcm
                                            ,pr_sequencia    => vr_nrautdoc    --Sequencia
                                            ,pr_registro     => vr_nrdrecid    --ROWID do registro debito
                                            ,pr_cdcritic     => vr_cdcritic    --Código do erro
                                            ,pr_dscritic     => vr_dscritic);  --Descricao do erro
    --Se ocorreu erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      vr_cdcritic:= 0;
      vr_dscritic:= 'Erro na autenticacao do credito.('||vr_dscritic||')';
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    --> Buscar a autenticacao do credito do estorno
    rw_crapaut := NULL;
    OPEN cr_crapaut (pr_rowid => vr_nrdrecid);
    FETCH cr_crapaut INTO rw_crapaut;
    CLOSE cr_crapaut;
    
    -- Buscar dados do banco
    rw_crapban := NULL;
    OPEN cr_crapban (pr_cdbccxlt => SUBSTR(pr_cdbarras,1,3));
    FETCH cr_crapban INTO rw_crapban;
    IF cr_crapban%NOTFOUND THEN
      CLOSE cr_crapban;
      vr_dscritic := 'Banco nao encontrado.';
      RAISE vr_exc_erro;
      
    ELSE
      CLOSE cr_crapban;
    END IF;
    
    BEGIN
      INSERT INTO craplcm 
                 ( cdcooper
                  ,dtmvtolt
                  ,cdagenci
                  ,cdbccxlt
                  ,nrdolote
                  ,dtrefere
                  ,hrtransa
                  ,cdoperad
                  ,nrdconta
                  ,nrdctabb
                  ,nrdctitg
                  ,nrdocmto
                  ,nrsequni
                  ,nrseqdig
                  ,cdhistor
                  ,vllanmto
                  ,nrautdoc
                  ,dscedent
                  ,cdpesqbb)      
           VALUES (rw_crapaut.cdcooper        -- cdcooper
                  ,rw_crapaut.dtmvtolt        -- dtmvtolt
                  ,rw_crapaut.cdagenci        -- cdagenci
                  ,11                         -- cdbccxlt
                  ,11900                      -- nrdolote
                  ,rw_crapaut.dtmvtolt        -- dtrefere
                  ,gene0002.fn_busca_time     -- hrtransa
                  ,rw_crapaut.cdopecxa        -- cdoperad
                  ,pr_nrdconta                -- nrdconta
                  ,pr_nrdconta                -- nrdctabb
                  ,to_char(pr_nrdconta,'fm00000000') -- nrdctitg
                  ,vr_nrseqdig                -- nrdocmto
                  ,vr_nrseqdig                -- nrsequni
                  ,vr_nrseqdig                -- nrseqdig
                  ,vr_cdhisest  -- Historico do Estorno -- cdhistor
                  ,rw_crapaut.vldocmto        -- vllanmto
                  ,rw_crapaut.nrsequen        -- nrautdoc
                  ,pr_dscedent                -- dscedent
                  ,( CASE 
                       WHEN pr_idorigem = 4 THEN
                          'TAA - ESTORNO PAGAMENTO ON-LINE - BANCO '|| rw_crapban.nmextbcc
                       ELSE
                          'INTERNET - ESTORNO PAGAMENTO ON-LINE - BANCO '|| rw_crapban.nmextbcc
                     END          
                   )      -- cdpesqbb
                  );
    
    EXCEPTION 
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir lançamento de credito de estorno: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    --> Cria o registro do movimento da internet 
    IF  pr_idorigem <> 4  THEN --> TAA 
      
      IF rw_crapass.idastcjt = 0 THEN
        -- Atualiza o registro de movimento da internet
        paga0001.pc_insere_movimento_internet(pr_cdcooper => pr_cdcooper     
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_idseqttl => pr_idseqttl
                                             ,pr_dtmvtolt => rw_crapaut.dtmvtolt
                                             ,pr_cdoperad => rw_crapaut.cdopecxa
                                             ,pr_inpessoa => rw_crapass.inpessoa
                                             ,pr_tpoperac => 2 -- Pagamento
                                             ,pr_vllanmto => (pr_vlfatura * -1) -- Diminuir valor
                                             ,pr_dscritic => vr_dscritic);

        --Levantar Excecao
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      ELSE
      
        FOR rw_crappod IN cr_crappod(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta) LOOP

          OPEN cr_crapsnh2(pr_cdcooper => rw_crappod.cdcooper
                          ,pr_nrdconta => rw_crappod.nrdconta
                          ,pr_nrcpfcgc => rw_crappod.nrcpfpro);

          FETCH cr_crapsnh2 INTO rw_crapsnh2;

          IF cr_crapsnh2%NOTFOUND THEN
            CLOSE cr_crapsnh2;
            CONTINUE;
          ELSE
            CLOSE cr_crapsnh2;
          END IF;

          -- Atualiza o registro de movimento da internet
          paga0001.pc_insere_movimento_internet(pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_idseqttl => rw_crapsnh2.idseqttl
                                               ,pr_dtmvtolt => rw_crapaut.dtmvtolt
                                               ,pr_cdoperad => rw_crapaut.cdopecxa
                                               ,pr_inpessoa => rw_crapass.inpessoa
                                               ,pr_tpoperac => 2 -- Pagamento
                                               ,pr_vllanmto => (pr_vlfatura * -1) -- Diminuir valor
                                               ,pr_dscritic => vr_dscritic);

          --Levantar Excecao
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

        END LOOP;
      
      
      END IF;
    END IF;
    
    --> Requisitar cancelamento da baixa operacional CIP 
    -->  Se possuir codigo de controle de baixa operacional 
    IF TRIM(pr_cdctrbxo) IS NOT NULL THEN
      
      vr_idpenden := 0; -- Passa zero, indicando que não está processando pendencias
    
      DDDA0001.pc_cancelar_baixa_operac ( pr_cdlegado => 'LEGWS'       --> Codigo Legado
                                         ,pr_idtitdda => '0'           --> Identificador Titulo DDA
                                         ,pr_cdctrlcs => pr_cdctrbxo   --> Numero controle consulta NPC
                                         ,pr_cdcodbar => pr_cdbarras   --> Codigo de barras do titulo
                                         ,pr_idpenden => vr_idpenden   --> Indica o processamento da pendencia
                                         ,pr_des_erro => vr_des_erro   --> Indicador erro OK/NOK
                                         ,pr_dscritic => vr_dscritic); --> Descricao erro
    
      IF vr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      
      END IF;
    END IF;
    
    IF pr_nrdident > 0  THEN

      --Atualizar situacao titulo
      DDDA0001.pc_atualz_situac_titulo_sacado (pr_cdcooper => pr_cdcooper    --Codigo da Cooperativa
                                              ,pr_cdagecxa => pr_cdagenci    --Codigo da Agencia
                                              ,pr_nrdcaixa => 900            --Numero do Caixa
                                              ,pr_cdopecxa => pr_cdoperad    --Codigo Operador Caixa
                                              ,pr_nmdatela => 'ESTORNO'      --Nome da tela
                                              ,pr_idorigem => pr_idorigem    --Indicador Origem
                                              ,pr_nrdconta => pr_nrdconta    --Numero da Conta
                                              ,pr_idseqttl => pr_idseqttl    --Sequencial do titular
                                              ,pr_idtitdda => pr_nrdident    --Indicador Titulo DDA                                              
                                              ,pr_cdsittit => 1 -- Em aberto --Situacao Titulo
                                              ,pr_flgerlog => 0              --Gerar Log
                                              ,pr_dtmvtolt => pr_dtmvtolt    --Dta movimento
                                              ,pr_dscodbar => pr_cdbarras    --CodBarras
                                              ,pr_cdctrlcs => NULL           --Identificador da consulta
                                              ,pr_cdcritic => vr_cdcritic    -- Codigo de critica
                                              ,pr_dscritic => vr_dscritic);  -- Descrição de critica
      --Se ocorreu erro
      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN        
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK TO TRANS_ESTORNO_TITULO;
      -- se possui codigo, porém não possui descrição
      IF nvl(vr_cdcritic,0) > 0 AND
         TRIM(vr_dscritic) IS NULL THEN
        -- buscar descrição
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

      END IF;

      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      ROLLBACK TO TRANS_ESTORNO_TITULO;
      btch0001.pc_log_internal_exception(pr_cdcooper);

      pr_dscritic := 'Erro inesperado ao estornar titulo.: '||SQLERRM;
      
  END pc_estorna_titulotmp;
END paga0004_temp;
/
