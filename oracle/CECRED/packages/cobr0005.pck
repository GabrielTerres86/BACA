CREATE OR REPLACE PACKAGE CECRED.COBR0005 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : COBR0005
  --  Sistema  : Procedimentos para  gerais da cobranca
  --  Sigla    : CRED
  --  Autor    : Rafael Cechet
  --  Data     : Agosto/2015.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas referente a consulta e geracao de titulos de cobrança
  --
  --  Alteracoes: 
  ---------------------------------------------------------------------------------------------------------------
  
  -- Definição de PL Table para armazenar os nomes das TAG´s do XML para iteração
  TYPE typ_reg_cob IS
    RECORD(cdcooper crapcob.cdcooper%TYPE
          ,nrdconta crapcob.nrdconta%TYPE
          ,idseqttl crapcob.idseqttl%TYPE
          ,nmprimtl crapass.nmprimtl%TYPE
          ,incobran VARCHAR2(1)
          ,nossonro VARCHAR2(17)
          ,nrctremp crapcob.nrctremp%TYPE
          ,nmdsacad crapcob.nmdsacad%TYPE
          ,nrinssac crapcob.nrinssac%TYPE
          ,cdtpinsc crapcob.cdtpinsc%TYPE
          ,dsendsac crapsab.dsendsac%TYPE
          ,complend crapsab.complend%TYPE
          ,nmbaisac crapsab.nmbaisac%TYPE
          ,nmcidsac crapsab.nmcidsac%TYPE
          ,cdufsaca crapcob.cdufsaca%TYPE
          ,nrcepsac crapcob.nrcepsac%TYPE
          ,cdbandoc crapcob.cdbandoc%TYPE
          ,dsbandig VARCHAR2(10) -- cód banco com DV
          ,nmdavali crapcob.nmdavali%TYPE
          ,nrinsava crapcob.nrinsava%TYPE
          ,cdtpinav crapcob.cdtpinav%TYPE
          ,nrcnvcob crapcob.nrcnvcob%TYPE
          ,nrcnvceb crapceb.nrcnvceb%TYPE
          ,nrdctabb crapcob.nrdctabb%TYPE
          ,nrcpfcgc crapass.nrcpfcgc%TYPE
          ,inpessoa crapass.inpessoa%TYPE
          ,nrdocmto crapcob.nrdocmto%TYPE
          ,dtmvtolt crapcob.dtmvtolt%TYPE
          ,dsdinstr crapcob.dsdinstr%TYPE
          ,dsdinst1 VARCHAR2(100)
          ,dsdinst2 VARCHAR2(100)
          ,dsdinst3 VARCHAR2(100)
          ,dsdinst4 VARCHAR2(100)
          ,dsdinst5 VARCHAR2(100)          
          ,dsinform crapcob.dsinform%TYPE
          ,dsinfor1 VARCHAR2(100)
          ,dsinfor2 VARCHAR2(100)
          ,dsinfor3 VARCHAR2(100)
          ,dsinfor4 VARCHAR2(100)
          ,dsinfor5 VARCHAR2(100)
          ,dslocpag VARCHAR2(100)
          ,dsavis2v VARCHAR2(100) -- aviso de 2a via
          ,dsagebnf VARCHAR2(50) -- Agencia/Codigo do Beneficiario (apenas no boleto)
          ,dspagad1 VARCHAR2(150)
          ,dspagad2 VARCHAR2(150)        
          ,dspagad3 VARCHAR2(150)  
          ,dssacava VARCHAR2(150)
          ,dsdoccop crapcob.dsdoccop%TYPE
          ,dtvencto crapcob.dtvencto%TYPE
          ,dtretcob crapcob.dtretcob%TYPE
          ,dtdpagto crapcob.dtdpagto%TYPE
          ,vltitulo crapcob.vltitulo%TYPE
          ,vldpagto crapcob.vldpagto%TYPE
          ,vldescto crapcob.vldescto%TYPE
          ,vlabatim crapcob.vlabatim%TYPE
          ,vltarifa crapcob.vltarifa%TYPE
          ,vlrmulta NUMBER(25,2)
          ,vlrjuros NUMBER(25,2)
          ,vloutdes NUMBER(25,2)
          ,vloutcre NUMBER(25,2)
          ,cdmensag crapcob.cdmensag%TYPE
          ,dsdpagto VARCHAR2(11)
          ,dsorgarq crapcco.dsorgarq%TYPE
          ,nrregist INTEGER
          ,idbaiexc INTEGER
          ,cdsituac VARCHAR2(1000)   /* Utilizado para a Internet */
          ,dssituac VARCHAR2(1000)   /* Utilizado para o Ayllos   */
          ,cddespec crapcob.cddespec%TYPE
          ,dsdespec VARCHAR2(1000)
          ,dtdocmto crapcob.dtdocmto%TYPE
          ,cdbanpag VARCHAR2(5)
          ,cdagepag VARCHAR2(4)
          ,flgdesco VARCHAR2(1000)
          ,dtelimin crapcob.dtelimin%TYPE
          ,cdcartei crapcob.cdcartei%TYPE
          ,nrvarcar crapcco.nrvarcar%TYPE
          ,cdagenci crapass.cdagenci%TYPE
          ,flgregis VARCHAR2(1000)
          ,nrnosnum crapcob.nrnosnum%TYPE
          ,dsstaabr VARCHAR2(1000)
          ,dsstacom VARCHAR2(1000)
          ,flgaceit VARCHAR2(1000)
          ,dtsitcrt DATE
          ,agencidv VARCHAR2(1000)
          ,tpjurmor INTEGER
          ,tpdmulta INTEGER
          ,flgdprot crapcob.flgdprot%TYPE
          ,qtdiaprt crapcob.qtdiaprt%TYPE
          ,indiaprt crapcob.indiaprt%TYPE
          ,insitpro crapcob.insitpro%TYPE
          ,flgcbdda VARCHAR2(1)
          ,cdocorre INTEGER
          ,dsocorre VARCHAR2(1000)
          ,cdmotivo VARCHAR2(1000)
          ,dsmotivo VARCHAR2(1000)
          ,dtocorre DATE
          ,dtdbaixa DATE
          ,vldocmto NUMBER
          ,vlmormul NUMBER
          ,dtvctori DATE
          ,dscjuros VARCHAR2(1000)
          ,dscmulta VARCHAR2(1000)
          ,dscdscto VARCHAR2(1000)
          ,dsinssac VARCHAR2(1000)
          ,vldesabt NUMBER
          ,vljurmul NUMBER
          ,dsorigem VARCHAR2(1000)
          ,dtcredit DATE
          ,nrborder craptdb.nrborder%TYPE
          ,vllimtit NUMBER
          ,vltdscti NUMBER
          ,nrctrlim craptdb.nrctrlim%TYPE
          ,nrctrlim_ativo craptdb.nrctrlim%TYPE
          ,dsdemail crapsab.dsdemail%TYPE
          ,flgemail NUMBER
          ,inemiten crapcob.inemiten%TYPE
          ,dsemiten VARCHAR2(1000)
          ,dsemitnt VARCHAR2(1000)
          ,flgcarne NUMBER
          ,cdbarras VARCHAR2(44)
          ,lindigit VARCHAR2(60)
          ,rowidcob ROWID);

  -- Declaração do tipo para a PL Table de nomes das TAG´s
  TYPE typ_tab_cob IS TABLE OF typ_reg_cob INDEX BY PLS_INTEGER;  
    
  PROCEDURE pc_calc_codigo_barras ( pr_dtvencto IN DATE
                                   ,pr_cdbandoc IN INTEGER
                                   ,pr_vltitulo IN crapcob.vltitulo%TYPE
                                   ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                                   ,pr_nrcnvceb IN crapceb.nrcnvceb%TYPE DEFAULT 0
                                   ,pr_nrdconta IN crapcob.nrdconta%TYPE
                                   ,pr_nrdocmto IN crapcob.nrdocmto%TYPE
                                   ,pr_cdcartei IN crapcob.cdcartei%TYPE
                                   ,pr_cdbarras OUT VARCHAR2);  
                                   
  PROCEDURE pc_calc_linha_digitavel(pr_cdbarras IN  VARCHAR2
                                   ,pr_lindigit OUT VARCHAR2);                                   
  
  PROCEDURE pc_gera_pedido_remessa( pr_rowidcob IN ROWID
                                   ,pr_dtmvtolt IN DATE
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                   ,pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_gerar_titulo_cobranca(pr_cdcooper IN crapcob.cdcooper%TYPE /* cooperativa */
                                    ,pr_nrdconta IN crapcob.nrdconta%TYPE /* conta do cooperado */
                                    ,pr_idseqttl IN crapcob.idseqttl%TYPE DEFAULT 1 /* titular que gerou o boleto */
                                    ,pr_nrcnvcob IN crapcco.nrconven%TYPE /* número do convenio */
                                    ,pr_nrdocmto IN crapcob.nrdocmto%TYPE DEFAULT NULL /* numero do documento (ou boleto) */
                                    ,pr_flgregis IN crapcob.flgregis%TYPE DEFAULT 1 /* cobranca registrada */
                                    ,pr_flgsacad IN INTEGER               DEFAULT 0 /* se o sacado eh dda ou nao */
                                    ,pr_nrctremp IN crapcob.nrctremp%TYPE DEFAULT 0 /* contrato de empréstimo */
                                    ,pr_nrpartit IN INTEGER DEFAULT 0     /* numero da parcela do titulo quando tiver */
                                    ,pr_inemiten IN crapcob.inemiten%TYPE /* Emitente */
                                    ,pr_cdbandoc IN crapcob.cdbandoc%TYPE /* código do banco */
                                    ,pr_cdcartei IN crapcob.cdcartei%TYPE /* código da carteira */
                                    ,pr_cddespec IN crapcob.cddespec%TYPE /* espécie de documento */
                                    ,pr_nrctasac IN crapcob.nrctasac%TYPE DEFAULT 0 /* numero da conta do sacado se houver */
                                    ,pr_cdtpinsc IN crapcob.cdtpinsc%TYPE /* tipo de inscrição do sacado 1=CPF, 2=CNPJ*/
                                    ,pr_nrinssac IN crapcob.nrinssac%TYPE /* nr de inscrição do sacado */
                                    ,pr_nmdavali IN crapcob.nmdavali%TYPE DEFAULT ' ' /* nome do avalista */
                                    ,pr_cdtpinav IN crapcob.cdtpinav%TYPE DEFAULT 0 /* codigo tipo sacador/avalista */
                                    ,pr_nrinsava IN crapcob.nrinsava%TYPE DEFAULT 0 /* nr da inscrição do sacador/avalista */
                                    ,pr_dtmvtolt IN crapcob.dtmvtolt%TYPE /* data do movimento */
                                    ,pr_dtdocmto IN crapcob.dtdocmto%TYPE /* data do documento */
                                    ,pr_dtvencto IN crapcob.dtvencto%TYPE /* data do vencimento */
                                    ,pr_vldescto IN crapcob.vldescto%TYPE DEFAULT 0 /* vlr do desconto */
                                    ,pr_vlabatim IN crapcob.vlabatim%TYPE DEFAULT 0 /* vlr do abatimento */
                                    ,pr_cdmensag IN crapcob.cdmensag%TYPE /* tipo de desconto */
                                    ,pr_dsdoccop IN crapcob.dsdoccop%TYPE /* descrição do documento */
                                    ,pr_vltitulo IN crapcob.vltitulo%TYPE /* valor do título */
                                    ,pr_dsinform IN crapcob.dsinform%TYPE DEFAULT '____' /* informações */
                                    ,pr_dsdinstr IN crapcob.dsdinstr%TYPE DEFAULT '____' /* instruções */
                                    ,pr_flgdprot IN crapcob.flgdprot%TYPE DEFAULT 0 /* protestar 0 = Não, 1 = Sim */
                                    ,pr_qtdiaprt IN crapcob.qtdiaprt%TYPE DEFAULT 0 /* qtd de dias para protesto */
                                    ,pr_indiaprt IN crapcob.indiaprt%TYPE DEFAULT 3 /* 1= Útil, 2=Corridos, 3= isento */
                                    ,pr_vljurdia IN crapcob.vljurdia%TYPE DEFAULT 0 /* vlr juros ao dia */
                                    ,pr_vlrmulta IN crapcob.vlrmulta%TYPE DEFAULT 0 /* vlr de multa */
                                    ,pr_flgaceit IN crapcob.flgaceit%TYPE DEFAULT 0 /* aceite */
                                    ,pr_tpjurmor IN crapcob.tpjurmor%TYPE DEFAULT 3 /* tipo de juros de mora 1=vlr "R$" diario, 2= "%" Mensal, 3=isento */
                                    ,pr_tpdmulta IN crapcob.tpdmulta%TYPE DEFAULT 3 /* tipo de multa 1=vlr "R$", 2= "%" , 3=isento */
                                    ,pr_tpemitir IN INTEGER               DEFAULT 1 /* tipo de emissão = 1 = Boleto / 2 = Carnê */
                                    ,pr_nrremass IN crapret.nrremass%TYPE DEFAULT 0 /* Numero da remessa do arquivo */
                                    ,pr_cdoperad IN crapcob.cdoperad%TYPE /* código do operador */
                                    ,pr_cdcritic OUT INTEGER              /* código de critica (se houver);*/
                                    ,pr_dscritic OUT VARCHAR2             /* descrição da crítica (se houver);*/
                                    ,pr_tab_cob  OUT typ_tab_cob);        /* record do boleto*/
             
  PROCEDURE pc_buscar_titulo_cobranca (pr_cdcooper IN crapcop.cdcooper%TYPE              --> Cooperativa
                                      ,pr_cdagenci IN crapass.cdagenci%TYPE DEFAULT NULL --> PA
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT NULL --> Nr da Conta
                                      ,pr_nrctremp IN crapcob.nrctremp%TYPE DEFAULT NULL --> Nr do contato de emprestimo                                      
                                      ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE DEFAULT NULL --> Convenio    
                                      ,pr_nrdocmto IN crapcob.nrdocmto%TYPE DEFAULT NULL --> Numero do titulo                                      
                                      ,pr_cdbandoc IN crapcob.cdbandoc%TYPE DEFAULT NULL --> Banco                                                                        
                                      ,pr_dtemissi IN DATE DEFAULT NULL                  --> Data de emissão inicial
                                      ,pr_dtemissf IN DATE DEFAULT NULL                  --> Data de emissão final                                      
                                      ,pr_dtvencti IN DATE DEFAULT NULL                  --> Data de vencimento inicial
                                      ,pr_dtvenctf IN DATE DEFAULT NULL                  --> Data de vencimento final                                      
                                      ,pr_dtbaixai IN DATE DEFAULT NULL                  --> Data de baixa inicial
                                      ,pr_dtbaixaf IN DATE DEFAULT NULL                  --> Data de baixa final
                                      ,pr_dtpagtoi IN DATE DEFAULT NULL                  --> Data de pagamento inicial
                                      ,pr_dtpagtof IN DATE DEFAULT NULL                  --> Data de pagamento final
                                      ,pr_vltituli IN crapcob.vltitulo%TYPE DEFAULT NULL --> Valor do título inicial
                                      ,pr_vltitulf IN crapcob.vltitulo%TYPE DEFAULT NULL --> Valor do título final
                                      ,pr_dsdoccop IN crapcob.dsdoccop%TYPE DEFAULT NULL --> Seu número
                                      ,pr_incobran IN INTEGER DEFAULT NULL               --> Situacao do titulo (0=em aberto, 3=baixado, 5=Pago)
                                      ,pr_flgcbdda IN crapcob.flgcbdda%TYPE DEFAULT NULL --> Flag se o título é DDA
                                      ,pr_flcooexp IN INTEGER DEFAULT NULL               --> Cooperado emite e expede
                                      ,pr_flceeexp IN INTEGER DEFAULT NULL               --> Cooperativa emite e expede
                                      ,pr_flprotes IN INTEGER DEFAULT NULL               --> Se titulo foi protestado
                                      ,pr_fldescon IN INTEGER DEFAULT NULL               --> Se titulo é descontado
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE              --> Cód. Operador
                                      ,pr_nriniseq IN INTEGER                            --> Registro inicial da listagem
                                      ,pr_nrregist IN INTEGER                            --> Numero de registros p/ paginaca
                                      ,pr_dtmvtolt IN DATE DEFAULT NULL                  --> Data do movimento
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE             --> Cód. da crítica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE             --> Descrição da crítica
                                      ,pr_tab_cob  OUT typ_tab_cob);                     /* record do boleto*/                                                              

END cobr0005;
/
CREATE OR REPLACE PACKAGE BODY CECRED.COBR0005 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : COBR0005
  --  Sistema  : Procedimentos para  gerais da cobranca
  --  Sigla    : CRED
  --  Autor    : Rafael Cechet
  --  Data     : Agosto/2015.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas referente a consulta e geracao de titulos de cobrança
  --
  --  Alteracoes: 
  ---------------------------------------------------------------------------------------------------------------
    
  PROCEDURE pc_gera_pedido_remessa( pr_rowidcob IN ROWID
                                   ,pr_dtmvtolt IN DATE
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                   ,pr_dscritic OUT VARCHAR2) IS
                                   
/* ............................................................................

     Programa: pc_gera_pedido_remessa
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Rafael Cechet
     Data    : Agosto/2015                     Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que chamado
     Objetivo  : Gerar registro de remessa para o BB

     Alteracoes: ----

  ............................................................................ */      
                                   

      vr_nrremret crapret.nrremret%TYPE;
      vr_nrseqreg crapret.nrseqreg%TYPE;
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(100);
      
      CURSOR cr_crapcob IS
        SELECT cob.*, cob.rowid 
          FROM crapcob cob
         WHERE cob.rowid = pr_rowidcob;
         
      rw_cob cr_crapcob%ROWTYPE;
      vr_ret ROWID;
      
      vr_exc_erro EXCEPTION;
           
  BEGIN    

    BEGIN
      
      OPEN cr_crapcob;
      FETCH cr_crapcob INTO rw_cob;
      
      IF cr_crapcob%NOTFOUND THEN
         RAISE vr_exc_erro;
      END IF;
      
      CLOSE cr_crapcob;
          
      paga0001.pc_prep_remessa_banco( pr_cdcooper => rw_cob.cdcooper
                                     ,pr_nrcnvcob => rw_cob.nrcnvcob
                                     ,pr_dtmvtolt => pr_dtmvtolt
                                     ,pr_cdoperad => pr_cdoperad
                                     ,pr_nrremret => vr_nrremret
                                    , pr_rowid_ret => vr_ret
                                     ,pr_nrseqreg => vr_nrseqreg
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
                                     

      vr_nrseqreg := vr_nrseqreg + 1;
      
      paga0001.pc_cria_tab_remessa( pr_idregcob => rw_cob.rowid
                                   ,pr_nrremret => vr_nrremret
                                   ,pr_nrseqreg => vr_nrseqreg
                                   ,pr_cdocorre => 1 -- remessa
                                   ,pr_cdmotivo => '' -- sem motivo
                                   ,pr_dtdprorr => NULL -- sem prorrogacao
                                   ,pr_vlabatim => 0 -- sem abatimeto
                                   ,pr_cdoperad => pr_cdoperad
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
                                 
    EXCEPTION
       WHEN vr_exc_erro THEN
         NULL;  
       WHEN OTHERS THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Erro nao tratado na COBR0005.pc_gera_pedido_remessa: ' || SQLERRM;
    END;


  END;
  
  PROCEDURE pc_calc_codigo_barras ( pr_dtvencto IN DATE
                                   ,pr_cdbandoc IN INTEGER
                                   ,pr_vltitulo IN crapcob.vltitulo%TYPE
                                   ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                                   ,pr_nrcnvceb IN crapceb.nrcnvceb%TYPE DEFAULT 0
                                   ,pr_nrdconta IN crapcob.nrdconta%TYPE
                                   ,pr_nrdocmto IN crapcob.nrdocmto%TYPE
                                   ,pr_cdcartei IN crapcob.cdcartei%TYPE
                                   ,pr_cdbarras OUT VARCHAR2) IS
                                   
/* ............................................................................

     Programa: pc_calc_codigo_barras
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Rafael Cechet
     Data    : Agosto/2015                     Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que chamado
     Objetivo  : Calcular o código de barras a partir dos parâmetros básicos

     Alteracoes: ----

  ............................................................................ */      
                                   

    vr_aux VARCHAR2(100);
    vr_dtini  DATE := to_date('07/10/1997','DD/MM/RRRR');
    vr_dtnovo DATE := to_date('22/02/2025','DD/MM/RRRR');
    vr_ftvencto INTEGER;
    vr_flgcbok BOOLEAN;
    
  BEGIN

      IF pr_dtvencto >= to_date('22/02/2025','DD/MM/RRRR') THEN
         vr_ftvencto := (trunc(pr_dtvencto) - trunc(vr_dtnovo)) + 1000;
      ELSE
         vr_ftvencto := (trunc(pr_dtvencto) - trunc(vr_dtini));
      END IF;

      IF length(pr_nrcnvcob) <= 6 THEN
        vr_aux := to_char(pr_cdbandoc,'fm000')
                               || '9' /* moeda */
                               || '1' /* nao alterar - constante */
                               || to_char(vr_ftvencto, 'fm0000') 
                               || to_char(pr_vltitulo * 100, 'fm0000000000')
                               || to_char(pr_nrcnvcob, 'fm000000')
                               || lpad(pr_nrdconta, 8, '0')
                               || lpad(pr_nrdocmto, 9, '0')                               
                               || to_char(pr_cdcartei, 'fm00');
      ELSIF length(pr_nrcnvcob) = 7 THEN
        vr_aux := to_char(pr_cdbandoc,'fm000')
                               || '9' /* moeda */
                               || '1' /* nao alterar - constante */
                               || to_char(vr_ftvencto, 'fm0000') 
                               || to_char(pr_vltitulo * 100, 'fm0000000000')
                               || '000000'
                               || lpad(pr_nrcnvcob, 7, '0')
                               || lpad(pr_nrcnvceb, 4, '0')
                               || lpad(pr_nrdocmto, 6, '0')
                               || to_char(pr_cdcartei, 'fm00');        
      END IF;        

      -- Calcular Digito Código Barras
      CXON0000.pc_calc_digito_titulo(pr_valor   => vr_aux --> Valor Calculado
                                    ,pr_retorno => vr_flgcbok); --> Retorno digito correto
      -- Retornar Codigo Barras
      pr_cdbarras := gene0002.fn_mask(vr_aux
                                     ,'99999999999999999999999999999999999999999999');    
    
  END;
  
  PROCEDURE pc_calc_linha_digitavel(pr_cdbarras IN  VARCHAR2
                                   ,pr_lindigit OUT VARCHAR2) IS
                                   
/* ............................................................................

     Programa: pc_calc_linha_digitavel
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Rafael Cechet
     Data    : Agosto/2015                     Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que chamado
     Objetivo  : Calcular linha digitavel do código de barras

     Alteracoes: ----

  ............................................................................ */      
                                   
                                   
  BEGIN

    DECLARE    
      -- Linha Digitavel
      vr_titulo1 VARCHAR2(100);
      vr_titulo2 VARCHAR2(100);
      vr_titulo3 VARCHAR2(100);
      vr_titulo4 VARCHAR2(100);
      vr_titulo5 VARCHAR2(100);    
      
      vr_nro_digito     INTEGER;
      vr_retorno BOOLEAN;      
    
    BEGIN
      vr_titulo1 := substr(pr_cdbarras,01,04) ||
                    substr(pr_cdbarras,20,01) ||
                    substr(pr_cdbarras,21,04) || '0';
      vr_titulo2 := substr(pr_cdbarras,25,10) || '0';
      vr_titulo3 := substr(pr_cdbarras,35,10) || '0';
      vr_titulo4 := substr(pr_cdbarras,05,01);
      vr_titulo5 := substr(pr_cdbarras,06,14);
       
      -- Calcula digito - Primeiro campo da linha digitavel
      CXON0000.pc_calc_digito_verif (pr_valor        => vr_titulo1    --> Valor Calculado
                                    ,pr_valida_zeros => FALSE          --> Validar Zeros
                                    ,pr_nro_digito   => vr_nro_digito --> Digito Verificador
                                    ,pr_retorno      => vr_retorno);  --> Retorno digito correto
          
      -- Calcula digito - Segunda campo da linha digitavel
      CXON0000.pc_calc_digito_verif (pr_valor        => vr_titulo2    --> Valor Calculado
                                    ,pr_valida_zeros => FALSE         --> Validar Zeros
                                    ,pr_nro_digito   => vr_nro_digito --> Digito Verificador
                                    ,pr_retorno      => vr_retorno);  --> Retorno digito correto
                                    
      -- Calcula digito - Terceira campo da linha digitavel
      CXON0000.pc_calc_digito_verif (pr_valor        => vr_titulo3    --> Valor Calculado
                                    ,pr_valida_zeros => FALSE         --> Validar Zeros
                                    ,pr_nro_digito   => vr_nro_digito --> Digito Verificador
                                    ,pr_retorno      => vr_retorno);  --> Retorno digito correto                              
                                    
      pr_lindigit := gene0002.fn_mask(gene0002.fn_mask(vr_titulo1, '9999999999'),'99999.99999')   || ' ' ||
                     gene0002.fn_mask(gene0002.fn_mask(vr_titulo2, '99999999999'),'99999.999999') || ' ' ||
                     gene0002.fn_mask(gene0002.fn_mask(vr_titulo3, '99999999999'),'99999.999999') || ' ' ||
                     gene0002.fn_mask(vr_titulo4,'9')                                             || ' ' ||     
                     gene0002.fn_mask(vr_titulo5, '99999999999999');                                  
    END;  
    
  END pc_calc_linha_digitavel;                                   
  
  
  -- Gera título de cobrança
  PROCEDURE pc_gerar_titulo_cobranca(pr_cdcooper IN crapcob.cdcooper%TYPE /* cooperativa */
                                    ,pr_nrdconta IN crapcob.nrdconta%TYPE /* conta do cooperado */
                                    ,pr_idseqttl IN crapcob.idseqttl%TYPE DEFAULT 1 /* titular que gerou o boleto */
                                    ,pr_nrcnvcob IN crapcco.nrconven%TYPE /* número do convenio */
                                    ,pr_nrdocmto IN crapcob.nrdocmto%TYPE DEFAULT NULL /* numero do documento (ou boleto) */
                                    ,pr_flgregis IN crapcob.flgregis%TYPE DEFAULT 1 /* cobranca registrada */
                                    ,pr_flgsacad IN INTEGER               DEFAULT 0 /* se o sacado eh dda ou nao */
                                    ,pr_nrctremp IN crapcob.nrctremp%TYPE DEFAULT 0 /* contrato de empréstimo */
                                    ,pr_nrpartit IN INTEGER DEFAULT 0     /* numero da parcela do titulo quando tiver */
                                    ,pr_inemiten IN crapcob.inemiten%TYPE /* Emitente */
                                    ,pr_cdbandoc IN crapcob.cdbandoc%TYPE /* código do banco */
                                    ,pr_cdcartei IN crapcob.cdcartei%TYPE /* código da carteira */
                                    ,pr_cddespec IN crapcob.cddespec%TYPE /* espécie de documento */
                                    ,pr_nrctasac IN crapcob.nrctasac%TYPE DEFAULT 0 /* numero da conta do sacado se houver */
                                    ,pr_cdtpinsc IN crapcob.cdtpinsc%TYPE /* tipo de inscrição do sacado 1=CPF, 2=CNPJ*/
                                    ,pr_nrinssac IN crapcob.nrinssac%TYPE /* nr de inscrição do sacado */
                                    ,pr_nmdavali IN crapcob.nmdavali%TYPE DEFAULT ' ' /* nome do avalista */
                                    ,pr_cdtpinav IN crapcob.cdtpinav%TYPE DEFAULT 0 /* codigo tipo sacador/avalista */
                                    ,pr_nrinsava IN crapcob.nrinsava%TYPE DEFAULT 0 /* nr da inscrição do sacador/avalista */
                                    ,pr_dtmvtolt IN crapcob.dtmvtolt%TYPE /* data do movimento */
                                    ,pr_dtdocmto IN crapcob.dtdocmto%TYPE /* data do documento */
                                    ,pr_dtvencto IN crapcob.dtvencto%TYPE /* data do vencimento */
                                    ,pr_vldescto IN crapcob.vldescto%TYPE DEFAULT 0 /* vlr do desconto */
                                    ,pr_vlabatim IN crapcob.vlabatim%TYPE DEFAULT 0 /* vlr do abatimento */
                                    ,pr_cdmensag IN crapcob.cdmensag%TYPE /* tipo de desconto */
                                    ,pr_dsdoccop IN crapcob.dsdoccop%TYPE /* descrição do documento */
                                    ,pr_vltitulo IN crapcob.vltitulo%TYPE /* valor do título */
                                    ,pr_dsinform IN crapcob.dsinform%TYPE DEFAULT '____' /* informações */
                                    ,pr_dsdinstr IN crapcob.dsdinstr%TYPE DEFAULT '____' /* instruções */
                                    ,pr_flgdprot IN crapcob.flgdprot%TYPE DEFAULT 0 /* protestar 0 = Não, 1 = Sim */
                                    ,pr_qtdiaprt IN crapcob.qtdiaprt%TYPE DEFAULT 0 /* qtd de dias para protesto */
                                    ,pr_indiaprt IN crapcob.indiaprt%TYPE DEFAULT 3 /* 1= Útil, 2=Corridos, 3= isento */
                                    ,pr_vljurdia IN crapcob.vljurdia%TYPE DEFAULT 0 /* vlr juros ao dia */
                                    ,pr_vlrmulta IN crapcob.vlrmulta%TYPE DEFAULT 0 /* vlr de multa */
                                    ,pr_flgaceit IN crapcob.flgaceit%TYPE DEFAULT 0 /* aceite */
                                    ,pr_tpjurmor IN crapcob.tpjurmor%TYPE DEFAULT 3 /* tipo de juros de mora 1=vlr "R$" diario, 2= "%" Mensal, 3=isento */
                                    ,pr_tpdmulta IN crapcob.tpdmulta%TYPE DEFAULT 3 /* tipo de multa 1=vlr "R$", 2= "%" , 3=isento */
                                    ,pr_tpemitir IN INTEGER               DEFAULT 1 /* tipo de emissão = 1 = Boleto / 2 = Carnê */
                                    ,pr_nrremass IN crapret.nrremass%TYPE DEFAULT 0 /* Numero da remessa do arquivo */
                                    ,pr_cdoperad IN crapcob.cdoperad%TYPE /* código do operador */
                                    ,pr_cdcritic OUT INTEGER              /* código de critica (se houver);*/
                                    ,pr_dscritic OUT VARCHAR2             /* descrição da crítica (se houver);*/
                                    ,pr_tab_cob  OUT typ_tab_cob) IS /* record do boleto*/
/* ............................................................................

     Programa: pc_gerar_titulo_cobranca
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Lombardi
     Data    : Agosto/2015                     Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que chamado
     Objetivo  : Gera título de cobrança

     Alteracoes: ----

  ............................................................................ */      

      vr_cdbarras VARCHAR2(44);
      vr_nrnosnum crapcob.nrnosnum%TYPE;
      vr_dtdemiss DATE;

      vr_busca VARCHAR2(100);
      vr_nrdocmto crapcob.nrdocmto%TYPE;
      
      CURSOR cr_cop 
          IS SELECT cdbcoctl, cdagectl 
               FROM crapcop
              WHERE crapcop.cdcooper = pr_cdcooper;
              
      rw_cop cr_cop%ROWTYPE;
      
      CURSOR cr_crapcob IS 
        SELECT cob.*, cob.rowid 
          FROM crapcob cob;
      rw_cob cr_crapcob%ROWTYPE;
      
      CURSOR cr_crapcco (pr_cdcooper IN crapcco.cdcooper%TYPE
                        ,pr_nrconven IN crapcco.nrconven%TYPE) IS
             SELECT * FROM crapcco cco
              WHERE cco.cdcooper = pr_cdcooper
                AND cco.nrconven = pr_nrconven;
                
      rw_crapcco cr_crapcco%ROWTYPE;
      
      CURSOR cr_crapsab (pr_cdcooper IN crapsab.cdcooper%TYPE
                        ,pr_nrdconta IN crapsab.nrdconta%TYPE
                        ,pr_nrinssac IN crapsab.nrinssac%TYPE) IS
             SELECT * FROM crapsab sab
              WHERE sab.cdcooper = pr_cdcooper
                AND sab.nrdconta = pr_nrdconta
                AND sab.nrinssac = pr_nrinssac;
      
      rw_crapsab cr_crapsab%ROWTYPE;                        
      
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
             SELECT * FROM crapass
              WHERE cdcooper = pr_cdcooper
                AND nrdconta = pr_nrdconta;
                
      rw_crapass cr_crapass%ROWTYPE;
      
      CURSOR cr_crappnp ( pr_nmextcid IN crappnp.nmextcid%TYPE
                         ,pr_cduflogr IN crappnp.cduflogr%TYPE) IS 
             SELECT * FROM crappnp
              WHERE nmextcid = pr_nmextcid
                AND cduflogr = pr_cduflogr;
      
      rw_crappnp cr_crappnp%ROWTYPE;
      
      CURSOR cr_crapceb (pr_cdcooper IN crapceb.cdcooper%TYPE
                        ,pr_nrdconta IN crapceb.nrdconta%TYPE
                        ,pr_nrconven IN crapceb.nrconven%TYPE) IS
            SELECT nrcnvceb 
              FROM crapceb 
             WHERE crapceb.cdcooper = pr_cdcooper
               AND crapceb.nrdconta = pr_nrdconta
               AND crapceb.nrconven = pr_nrcnvcob;
               
      rw_crapceb cr_crapceb%ROWTYPE;                  
      
      vr_exc_critica EXCEPTION;
      vr_exc_erro EXCEPTION;
      
      vr_dsdinstr crapcob.dsdinstr%TYPE;
      vr_nrremret crapret.nrremret%TYPE;
      vr_des_erro VARCHAR2(100);
      
      vr_flgdprot INTEGER;
      vr_qtdiaprt INTEGER;
      vr_indiaprt INTEGER;


  BEGIN    
      OPEN cr_crapcco (pr_cdcooper => pr_cdcooper
                      ,pr_nrconven => pr_nrcnvcob);
      FETCH cr_crapcco INTO rw_crapcco;
      
      IF cr_crapcco%NOTFOUND THEN
          CLOSE cr_crapcco;
          pr_cdcritic := 0;
          pr_dscritic := 'Convenio nao encontrado.';        
          RAISE vr_exc_critica;        
      END IF;
      
      CLOSE cr_crapcco;                    

      /* Testar parametro em relacao ao convenio */
      IF  rw_crapcco.flgregis <> pr_flgregis THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Tipo de cobranca invalida.';        
          RAISE vr_exc_critica;
      END IF;

      
      vr_busca := TRIM(to_char(pr_cdcooper)) || ';' ||
                  TRIM(to_char(pr_nrdconta)) || ';' ||
                  TRIM(to_char(pr_nrcnvcob)) || ';' ||
                  TRIM(to_char(rw_crapcco.nrdctabb)) || ';' ||
                  TRIM(to_char(pr_cdbandoc));

      /* Busca a proxima sequencia do campo CRAPCOB.NRDOCMTO */
      IF (pr_nrdocmto IS NULL OR pr_nrdocmto = 0)  THEN
         vr_nrdocmto := fn_sequence('CRAPCOB','NRDOCMTO', vr_busca);
      ELSE
         vr_nrdocmto := pr_nrdocmto;
      END IF;

      IF  vr_nrdocmto = 0 THEN 
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao gerar numero do documento.';
          RAISE vr_exc_critica;
      END IF;

      IF rw_crapcco.cddbanco <> 085 THEN
         /* Se for convenio de 6 digito deve gerar
            o nosso numero apenas com a conta e docto SD 308717*/            
            
         IF LENGTH(to_char(pr_nrcnvcob)) <= 6 THEN
            vr_nrnosnum := to_char(pr_nrdconta,'fm00000000') ||
                           to_char(vr_nrdocmto,'fm000000000');
         ELSE
            OPEN cr_crapceb (pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrconven => pr_nrcnvcob);
            FETCH cr_crapceb INTO rw_crapceb;
            CLOSE cr_crapceb;
               
            vr_nrnosnum := to_char(pr_nrcnvcob, 'fm0000000') ||
                           to_char(rw_crapceb.nrcnvceb, 'fm0000') || 
                           to_char(vr_nrdocmto, 'fm000000');    
         END IF;
      ELSE
          vr_nrnosnum := to_char(pr_nrdconta,'fm00000000') ||
                         to_char(vr_nrdocmto,'fm000000000');
      END IF;
      

      OPEN cr_crapsab (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrinssac => pr_nrinssac);
      FETCH cr_crapsab INTO rw_crapsab;                    

      IF cr_crapsab%NOTFOUND THEN
        CLOSE cr_crapsab;        
        pr_cdcritic := 0;
        pr_dscritic := 'Pagador nao encontrado.';
        RAISE vr_exc_critica;
      END IF;        
      
      CLOSE cr_crapsab;
      
      vr_flgdprot := pr_flgdprot;
      vr_qtdiaprt := pr_qtdiaprt;
      vr_indiaprt := pr_indiaprt;
      
      IF pr_flgregis = 1 THEN
         
         /**** validação praça não executante de protesto ****/      
         OPEN cr_crappnp (pr_nmextcid => rw_crapsab.nmcidsac
                         ,pr_cduflogr => rw_crapsab.cdufsaca);
         FETCH cr_crappnp INTO rw_crappnp;

         IF cr_crappnp%FOUND THEN

            vr_flgdprot := 0;
            vr_qtdiaprt := 0;
            vr_indiaprt := 3;
            
            /* Obs.: cursor será fechado apos a inclusao na crapcob */
                                               
          END IF;
          
      END IF;         
     
      /* se inst aut de protesto, cob registrada e banco 085 */
      IF pr_flgregis = 1 AND 
         pr_flgdprot = 1 AND 
         rw_crapcco.cddbanco = 085 THEN 
         vr_dsdinstr := '** Servico de protesto sera efetuado ' ||  
                        'pelo Banco do Brasil **';
      ELSE
         vr_dsdinstr := pr_dsdinstr;
      END IF;

        /* se banco emite e expede, nosso num conv+ceb+doctmo -
           Rafael Cechet 29/03/11 */

      vr_dtdemiss := pr_dtmvtolt;

      INSERT INTO crapcob 
             (cdcooper, nrdconta, nrdocmto, idseqttl, dtmvtolt, cdbandoc, incobran, nrcnvcob, nrdctabb, cdcartei, 
              cddespec, cdtpinsc, nrinssac, nmdavali, cdtpinav, nrinsava, dtretcob, dtdocmto, dtvencto, vldescto, 
              vlabatim, cdmensag, dsdoccop, vltitulo, dsdinstr, dsinform, cdimpcob, flgimpre, nrctasac, nrctremp, 
              nrnosnum, flgdprot, qtdiaprt, indiaprt, vljurdia, vlrmulta, flgaceit, flgregis, inemiten, insitcrt, 
              insitpro, flgcbdda, tpjurmor, tpdmulta, idopeleg, idtitleg, inemiexp)
      VALUES ( pr_cdcooper
              ,pr_nrdconta
              ,vr_nrdocmto
              ,pr_idseqttl
              ,vr_dtdemiss
              ,pr_cdbandoc
              ,0 -- incobran
              ,pr_nrcnvcob
              ,rw_crapcco.nrdctabb
              ,pr_cdcartei -- 10
              ,pr_cddespec
              ,pr_cdtpinsc
              ,pr_nrinssac
              ,upper(pr_nmdavali)
              ,pr_cdtpinav
              ,pr_nrinsava
              ,pr_dtmvtolt
              ,pr_dtdocmto
              ,pr_dtvencto
              ,pr_vldescto -- 20
              ,pr_vlabatim
              ,pr_cdmensag
              ,upper(TRIM(pr_dsdoccop)) || (CASE pr_nrpartit WHEN 0 THEN ' ' ELSE '/' || to_char(pr_nrpartit,'0000') END)
              ,pr_vltitulo
              ,upper(vr_dsdinstr)
              ,upper(pr_dsinform)
              ,3 -- cdimpcob
              ,1 -- flgimpre
              ,pr_nrctasac
              ,pr_nrctremp -- 30
              ,vr_nrnosnum
              ,vr_flgdprot -- 
              ,vr_qtdiaprt -- 
              ,vr_indiaprt -- 
              ,pr_vljurdia -- 
              ,pr_vlrmulta -- 
              ,pr_flgaceit -- 
              ,pr_flgregis -- 
              ,pr_inemiten -- 
              ,0 -- 40
              ,(CASE pr_cdbandoc WHEN 85 THEN 1 ELSE 0 END) -- 
              ,pr_flgsacad -- 
             /* 1=vlr 'R$' diario, 2= '%' Mensal, 3=isento */
              ,(CASE WHEN pr_vljurdia = 0 THEN 3 ELSE pr_tpjurmor END) -- 
             /* 1=vlr 'R$', 2= '%' , 3=isento */
              ,(CASE pr_vlrmulta WHEN 0 THEN 3 ELSE pr_tpdmulta END) -- 
              ,(CASE pr_flgsacad WHEN 1 THEN seqcob_idopeleg.nextval ELSE 0 END) -- 
              ,(CASE pr_flgsacad WHEN 1 THEN seqcob_idtitleg.nextval ELSE 0 END) -- 
              ,(CASE WHEN pr_inemiten = 3 THEN 1 /* a enviar à PG */ ELSE 0 END )
              ) RETURNING 
                  cdcooper, nrdconta, nrdocmto, idseqttl, dtmvtolt, cdbandoc, incobran, nrcnvcob, nrdctabb, cdcartei, 
                  cddespec, cdtpinsc, nrinssac, nmdavali, cdtpinav, nrinsava, dtretcob, dtdocmto, dtvencto, vldescto, 
                  vlabatim, cdmensag, dsdoccop, vltitulo, dsdinstr, dsinform, cdimpcob, flgimpre, nrctasac, nrctremp, 
                  nrnosnum, flgdprot, qtdiaprt, indiaprt, vljurdia, vlrmulta, flgaceit, flgregis, inemiten, insitcrt, 
                  insitpro, flgcbdda, tpjurmor, tpdmulta, idopeleg, idtitleg, inemiexp, crapcob.ROWID
              INTO 
                  rw_cob.cdcooper, rw_cob.nrdconta, rw_cob.nrdocmto, rw_cob.idseqttl, rw_cob.dtmvtolt, rw_cob.cdbandoc, rw_cob.incobran, rw_cob.nrcnvcob, rw_cob.nrdctabb, rw_cob.cdcartei, 
                  rw_cob.cddespec, rw_cob.cdtpinsc, rw_cob.nrinssac, rw_cob.nmdavali, rw_cob.cdtpinav, rw_cob.nrinsava, rw_cob.dtretcob, rw_cob.dtdocmto, rw_cob.dtvencto, rw_cob.vldescto, 
                  rw_cob.vlabatim, rw_cob.cdmensag, rw_cob.dsdoccop, rw_cob.vltitulo, rw_cob.dsdinstr, rw_cob.dsinform, rw_cob.cdimpcob, rw_cob.flgimpre, rw_cob.nrctasac, rw_cob.nrctremp, 
                  rw_cob.nrnosnum, rw_cob.flgdprot, rw_cob.qtdiaprt, rw_cob.indiaprt, rw_cob.vljurdia, rw_cob.vlrmulta, rw_cob.flgaceit, rw_cob.flgregis, rw_cob.inemiten, rw_cob.insitcrt, 
                  rw_cob.insitpro, rw_cob.flgcbdda, rw_cob.tpjurmor, rw_cob.tpdmulta, rw_cob.idopeleg, rw_cob.idtitleg, rw_cob.inemiexp, rw_cob.rowid;              
                    
      IF pr_flgregis = 1 THEN
         
         IF cr_crappnp%FOUND THEN

            CLOSE cr_crappnp;
      
            paga0001.pc_cria_log_cobranca(rw_cob.rowid
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_dtmvtolt => SYSDATE
                                         ,pr_dsmensag => 'Obs.: Praca nao executante de protesto'
                                         ,pr_des_erro => vr_des_erro
                                         ,pr_dscritic => pr_dscritic);
                                         
          END IF;
          
          IF cr_crappnp%ISOPEN THEN
             CLOSE cr_crappnp;
          END IF;

      END IF;         
  
      /** Validacoes de Cobranca Registrada **/
      IF  pr_cdbandoc = 1 AND pr_flgregis = 1 THEN 

          pc_gera_pedido_remessa( pr_rowidcob => rw_cob.rowid
                                 ,pr_dtmvtolt => pr_dtmvtolt
                                 ,pr_cdoperad => pr_cdoperad
                                 ,pr_cdcritic => pr_cdcritic
                                 ,pr_dscritic => pr_dscritic);
      
      ELSE 
         IF rw_cob.cdbandoc = 085 AND 
            pr_flgregis = 1       AND 
            pr_inemiten <> 3      THEN /* nao gerar confirmacao de retorno
                                              qdo emissao Cooperativa/EE */
                                              
          OPEN cr_cop;
          FETCH cr_cop INTO rw_cop;
          CLOSE cr_cop;
            
          /* Preparar Lote de Retorno Cooperado */
          PAGA0001.pc_prep_retorno_cooper_90 (pr_idregcob => rw_cob.rowid --ROWID da cobranca
                                             ,pr_cdocorre => 02  /* Baixa */   --Codigo Ocorrencia
                                             ,pr_cdmotivo => '' /* Decurso Prazo */  --Codigo Motivo
                                             ,pr_vltarifa => 0
                                             ,pr_cdbcoctl => rw_cop.cdbcoctl
                                             ,pr_cdagectl => rw_cop.cdagectl
                                             ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                             ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                             ,pr_nrremass => pr_nrremass --Numero Remessa
                                             ,pr_cdcritic => pr_cdcritic   --Codigo Critica
                                             ,pr_dscritic => pr_dscritic); --Descricao Critica          
         END IF;
      END IF;

      /*** Criando log do processo - Cobranca Registrada ***/
      IF pr_flgregis = 1 THEN 
        
         paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_cob.rowid
                                     , pr_cdoperad => pr_cdoperad
                                     , pr_dtmvtolt => SYSDATE
                                     , pr_dsmensag => (CASE WHEN pr_tpemitir = 1 THEN 'Titulo gerado'
                                     ELSE 'Titulo gerado - Carne' END)
                                     , pr_des_erro => vr_des_erro
                                     , pr_dscritic => pr_dscritic);
      END IF;

      IF pr_flgregis = 1 AND pr_inemiten = 3 THEN /* cooperativa emite e expede */ 
        
          /*** Criando log do boleto – Titulo a enviar para PG ***/
         paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_cob.rowid
                                     , pr_cdoperad => pr_cdoperad
                                     , pr_dtmvtolt => SYSDATE
                                     , pr_dsmensag => 'Titulo a enviar para PG'
                                     , pr_des_erro => vr_des_erro
                                     , pr_dscritic => pr_dscritic);

      END IF;
      
      cobr0005.pc_buscar_titulo_cobranca(pr_cdcooper => pr_cdcooper
--                                            ,pr_rowidcob => rw_crapcob.rowidcob
                                        ,pr_nrdconta => rw_cob.nrdconta
                                        ,pr_nrcnvcob => rw_cob.nrcnvcob
                                        ,pr_nrdocmto => rw_cob.nrdocmto
                                        ,pr_cdoperad => pr_cdoperad
                                        ,pr_nriniseq => 1
                                        ,pr_nrregist => 1
                                        ,pr_cdcritic => pr_cdcritic
                                        ,pr_dscritic => pr_dscritic
                                        ,pr_tab_cob  => pr_tab_cob);      
      

  /*    ASSIGN pr_lsdoctos = pr_lsdoctos + 
                           (IF  pr_lsdoctos <> ''  THEN
                                ','
                            ELSE
                                '') + to_char(aux_nrdocmto) 
             pr_nrdocmto = pr_nrdocmto + 1
             pr_nrdoccop = pr_nrdoccop + 1.*/

  --    RETURN 'OK'.  
  

  EXCEPTION
    WHEN vr_exc_critica THEN
      IF cr_crappnp%ISOPEN THEN CLOSE cr_crappnp; END IF;
      IF cr_crapass%ISOPEN THEN CLOSE cr_crapass; END IF;
      IF cr_crapceb%ISOPEN THEN CLOSE cr_crapceb; END IF;
      IF cr_crapcob%ISOPEN THEN CLOSE cr_crapcob; END IF;
      IF cr_crapsab%ISOPEN THEN CLOSE cr_crapsab; END IF;
      -- RETURN "NOK".
      -- Efetuar Rollback
    WHEN vr_exc_erro THEN
      IF cr_crappnp%ISOPEN THEN CLOSE cr_crappnp; END IF;
      IF cr_crapass%ISOPEN THEN CLOSE cr_crapass; END IF;
      IF cr_crapceb%ISOPEN THEN CLOSE cr_crapceb; END IF;
      IF cr_crapcob%ISOPEN THEN CLOSE cr_crapcob; END IF;
      IF cr_crapsab%ISOPEN THEN CLOSE cr_crapsab; END IF;
      
      pr_dscritic := pr_dscritic || ' - ' || SQLERRM;

    WHEN OTHERS THEN
      IF cr_crappnp%ISOPEN THEN CLOSE cr_crappnp; END IF;
      IF cr_crapass%ISOPEN THEN CLOSE cr_crapass; END IF;
      IF cr_crapceb%ISOPEN THEN CLOSE cr_crapceb; END IF;
      IF cr_crapcob%ISOPEN THEN CLOSE cr_crapcob; END IF;
      IF cr_crapsab%ISOPEN THEN CLOSE cr_crapsab; END IF;
      
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      
  END pc_gerar_titulo_cobranca;
  
  PROCEDURE pc_buscar_titulo_cobranca (pr_cdcooper IN crapcop.cdcooper%TYPE              --> Cooperativa
                                      ,pr_cdagenci IN crapass.cdagenci%TYPE DEFAULT NULL --> PA
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT NULL --> Nr da Conta
                                      ,pr_nrctremp IN crapcob.nrctremp%TYPE DEFAULT NULL --> Nr do contato de emprestimo
                                      ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE DEFAULT NULL --> Convenio    
                                      ,pr_nrdocmto IN crapcob.nrdocmto%TYPE DEFAULT NULL --> Nr do titulo
                                      ,pr_cdbandoc IN crapcob.cdbandoc%TYPE DEFAULT NULL --> Banco                                                                        
                                      ,pr_dtemissi IN DATE DEFAULT NULL                  --> Data de emissão inicial
                                      ,pr_dtemissf IN DATE DEFAULT NULL                  --> Data de emissão final                                      
                                      ,pr_dtvencti IN DATE DEFAULT NULL                  --> Data de vencimento inicial
                                      ,pr_dtvenctf IN DATE DEFAULT NULL                  --> Data de vencimento final                                      
                                      ,pr_dtbaixai IN DATE DEFAULT NULL                  --> Data de baixa inicial
                                      ,pr_dtbaixaf IN DATE DEFAULT NULL                  --> Data de baixa final
                                      ,pr_dtpagtoi IN DATE DEFAULT NULL                  --> Data de pagamento inicial
                                      ,pr_dtpagtof IN DATE DEFAULT NULL                  --> Data de pagamento final
                                      ,pr_vltituli IN crapcob.vltitulo%TYPE DEFAULT NULL --> Valor do título inicial
                                      ,pr_vltitulf IN crapcob.vltitulo%TYPE DEFAULT NULL --> Valor do título final
                                      ,pr_dsdoccop IN crapcob.dsdoccop%TYPE DEFAULT NULL --> Seu número
                                      ,pr_incobran IN INTEGER DEFAULT NULL               --> Situacao do titulo (0=em aberto, 3=baixado, 5=Pago)
                                      ,pr_flgcbdda IN crapcob.flgcbdda%TYPE DEFAULT NULL --> Flag se o título é DDA
                                      ,pr_flcooexp IN INTEGER DEFAULT NULL               --> Cooperado emite e expede
                                      ,pr_flceeexp IN INTEGER DEFAULT NULL               --> Cooperativa emite e expede
                                      ,pr_flprotes IN INTEGER DEFAULT NULL               --> Se titulo foi protestado
                                      ,pr_fldescon IN INTEGER DEFAULT NULL               --> Se titulo é descontado
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE              --> Cód. Operador
                                      ,pr_nriniseq IN INTEGER                            --> Registro inicial da listagem
                                      ,pr_nrregist IN INTEGER                            --> Numero de registros p/ paginaca
                                      ,pr_dtmvtolt IN DATE DEFAULT NULL                  --> Data do Movimento
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE             --> Cód. da crítica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE             --> Descrição da crítica
                                      ,pr_tab_cob  OUT typ_tab_cob                       /* record do boleto*/                                      
                                      ) IS
  BEGIN                                      
  /* ............................................................................

     Programa: pc_buscar_titulo_cobranca
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Rafael Cechet
     Data    : Agosto/2015                     Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que chamado
     Objetivo  : Buscar de forma generica titulos de cobrança

     Alteracoes: ----

  ............................................................................ */      

	DECLARE
			----------------------------- VARIAVEIS ---------------------------------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
			
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_exc_semresultado EXCEPTION;

      vr_ind INTEGER := 0;      
      vr_ind_cob INTEGER := 0;
      
      vr_nro_digito INTEGER;      
      vr_retorno BOOLEAN;      
      vr_cdagediv INTEGER;
      vr_dsinform cecred.gene0002.typ_split;

			---------------------------- CURSORES -----------------------------------
			CURSOR cr_crapcob 
      
/*      (    pr_cdcooper IN crapcop.cdcooper%TYPE              --> Cooperativa
                            ,pr_cdagenci IN crapass.cdagenci%TYPE DEFAULT NULL --> PA
                            ,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT NULL --> Nr da Conta
                            ,pr_nrctremp IN crapcob.nrctremp%TYPE DEFAULT NULL --> Nr do contato de emprestimo
                            ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE DEFAULT NULL --> Convenio    
                            ,pr_nrdocmto IN crapcob.nrdocmto%TYPE DEFAULT NULL --> Nr do titulo
                            ,pr_cdbandoc IN crapcob.cdbandoc%TYPE DEFAULT NULL --> Banco                                                                        
                            ,pr_dtemissi IN DATE DEFAULT NULL                  --> Data de emissão inicial
                            ,pr_dtemissf IN DATE DEFAULT NULL                  --> Data de emissão final                                      
                            ,pr_dtvencti IN DATE DEFAULT NULL                  --> Data de vencimento inicial
                            ,pr_dtvenctf IN DATE DEFAULT NULL                  --> Data de vencimento final                                      
                            ,pr_dtbaixai IN DATE DEFAULT NULL                  --> Data de baixa inicial
                            ,pr_dtbaixaf IN DATE DEFAULT NULL                  --> Data de baixa final
                            ,pr_dtpagtoi IN DATE DEFAULT NULL                  --> Data de pagamento inicial
                            ,pr_dtpagtof IN DATE DEFAULT NULL                  --> Data de pagamento final
                            ,pr_vltituli IN crapcob.vltitulo%TYPE DEFAULT NULL --> Valor do título inicial
                            ,pr_vltitulf IN crapcob.vltitulo%TYPE DEFAULT NULL --> Valor do título final
                            ,pr_dsdoccop IN crapcob.dsdoccop%TYPE DEFAULT NULL --> Seu número
                            ,pr_incobran IN INTEGER DEFAULT NULL               --> Situacao do titulo (0=em aberto, 3=baixado, 5=Pago)
                            ,pr_flgcbdda IN crapcob.flgcbdda%TYPE DEFAULT NULL --> Flag se o título é DDA
                            ,pr_flcooexp IN INTEGER DEFAULT NULL               --> Cooperado emite e expede
                            ,pr_flceeexp IN INTEGER DEFAULT NULL               --> Cooperativa emite e expede
                            ,pr_flprotes IN INTEGER DEFAULT NULL               --> Se titulo foi protestado
                            ,pr_fldescon IN INTEGER DEFAULT NULL)      
*/      
      
      IS SELECT cop.nmrescop
               ,cop.dsendweb
               ,cop.cdagectl
               ,cop.cdagedbb
               ,cob.dtmvtolt
               ,decode(cob.incobran, 0, 'A', 3, 'B', 5, 'P') incobran
               ,cob.nrdconta
               ,cob.nrctremp
               ,cob.nrdctabb               
               ,cob.cdbandoc
               ,cob.nrdocmto
               ,cob.dtretcob
               ,cob.nrcnvcob
               ,cob.cdcooper
               ,cob.indpagto
               ,cob.dtdpagto
               ,cob.vldpagto
               ,cob.vltitulo
               ,cob.dsinform
               ,cob.dsdinstr
               ,cob.dtvencto
               ,cco.cdcartei
               ,cob.cddespec
               ,decode(cob.cddespec,1,'DM'
                                   ,2,'DS'
                                   ,3,'NP'
                                   ,4,'MENS'
                                   ,5,'NF'
                                   ,6,'RECI'
                                   ,7,'OUTR') dsdespec                                                  
               ,cob.cdtpinsc
               ,cob.cdtpinav
               ,cob.nrinsava
               ,cob.nrinssac
               ,cob.nmdavali
               ,cob.vldescto
               ,cob.cdmensag
               ,cob.dsdoccop
               ,cob.idseqttl
               ,cob.dtdbaixa
               ,cob.vlabatim
               ,cob.vltarifa
               ,decode(cob.cdbanpag, 11, 'COOP', to_char(cob.cdbanpag,'fm000')) cdbanpag
               ,decode(cob.cdagepag, 11, ' ', to_char(cob.cdagepag, 'fm0000')) cdagepag               
               ,cob.dtdocmto
               ,cob.nrnosnum
               ,cob.insitcrt
               ,cob.dtsitcrt
               ,cob.flgdprot
               ,cob.qtdiaprt
               ,cob.indiaprt
               ,cob.vljurdia
               ,cob.vlrmulta
               ,decode(cob.flgaceit,1,' S', 0, ' N') flgaceit
               ,cob.dsusoemp
               ,cob.flgregis
               ,cob.inemiten
               ,cob.tpjurmor
               ,cob.tpdmulta
               ,decode(cob.flgcbdda,1,'S',0,'N') flgcbdda
               ,cob.idtitleg
               ,cob.idopeleg
               ,cob.insitpro
               ,cob.nrremass
               ,cob.cdtitprt
               ,cob.dcmc7chq
               ,cob.inemiexp
               ,cob.dtemiexp
               ,cob.dtelimin
               ,cob.flserasa 
               ,cob.qtdianeg
               ,sab.nmdsacad
               ,sab.dsendsac
               ,sab.nmbaisac
               ,sab.nrcepsac
               ,sab.nmcidsac
               ,sab.cdufsaca
               ,sab.nrendsac
               ,sab.complend
               ,sab.cdsitsac
               ,sab.dsdemail
               ,sab.flgemail
               ,sab.nrcelsac
               ,ceb.nrcnvceb
               ,ass.cdagenci
               ,ass.nmprimtl
               ,ass.nrcpfcgc
               ,ass.inpessoa
               ,cco.dsorgarq
               ,cco.nrvarcar
               ,cob.rowid
               ,decode(cob.inemiten,1,'1-BCO',2,'2-COO',3,'3-CEE') dsemiten
               ,decode(cob.inemiten,1,'BCO',2,'COO',3,'CEE') dsemitnt
               ,nvl((SELECT 1 FROM crapcol col
                      WHERE col.cdcooper (+) = cob.cdcooper
                        AND col.nrdconta (+) = cob.nrdconta
                        AND col.nrcnvcob (+) = cob.nrcnvcob
                        AND col.nrdocmto (+) = cob.nrdocmto
                        AND upper(col.dslogtit(+)) LIKE '%CARNE%'),0) flgcarne
               ,nvl((SELECT 1 FROM craptdb tdb
                      WHERE tdb.cdcooper (+) = cob.cdcooper
                        AND tdb.nrdconta (+) = cob.nrdconta
                        AND tdb.nrcnvcob (+) = cob.nrcnvcob
                        AND tdb.nrdocmto (+) = cob.nrdocmto
                        AND tdb.nrdctabb (+) = cob.nrdctabb
                        AND tdb.cdbandoc (+) = cob.cdbandoc
                        AND tdb.insittit (+) = 4),0) fldescon
           FROM crapcob cob
              , crapsab sab
              , crapcco cco
              , crapceb ceb
              , crapass ass
              , crapcop cop
          WHERE cco.cdcooper = pr_cdcooper                            --> Cód. cooperativa
            AND ceb.cdcooper = cco.cdcooper
            AND ceb.nrconven = cco.nrconven
            AND cob.cdcooper = ceb.cdcooper
            AND cob.nrdconta = ceb.nrdconta
            AND cob.nrcnvcob = ceb.nrconven
--            AND cob.cdbandoc = cco.cddbanco
--            AND cob.nrdctabb = cco.nrdctabb
            AND ass.cdcooper = cob.cdcooper
            AND ass.nrdconta = cob.nrdconta
            AND sab.cdcooper = cob.cdcooper
            AND sab.nrdconta = cob.nrdconta
            AND sab.nrinssac = cob.nrinssac            
            AND cop.cdcooper = cob.cdcooper
					  AND (pr_cdagenci IS NULL OR ass.cdagenci =  pr_cdagenci)   --> PA
						AND (pr_nrdconta IS NULL OR ceb.nrdconta =  pr_nrdconta)   --> Nr da Conta
            AND (pr_nrctremp IS NULL OR cob.nrctremp =  pr_nrctremp)   --> Nr do contrato de emprestimo
            AND (pr_nrcnvcob IS NULL OR cco.nrconven =  pr_nrcnvcob)   --> Nr do Convenio
            AND (pr_nrdocmto IS NULL OR cob.nrdocmto =  pr_nrdocmto)   --> Numero do titulo
            AND (pr_cdbandoc IS NULL OR cco.cddbanco =  pr_cdbandoc)   --> Nr do Banco
						AND (pr_dtbaixai IS NULL OR cob.dtdbaixa >= pr_dtbaixai)   --> Data da baixa de
						AND (pr_dtbaixaf IS NULL OR cob.dtdbaixa <= pr_dtbaixaf)   --> Data de baixa até
						AND (pr_dtemissi IS NULL OR cob.dtmvtolt >= pr_dtemissi)   --> Data de emnissão de 
						AND (pr_dtemissf IS NULL OR cob.dtmvtolt <= pr_dtemissf)   --> Data de emissão até
						AND (pr_dtvencti IS NULL OR cob.dtvencto >= pr_dtvencti)   --> Data de vencimento de 
						AND (pr_dtvenctf IS NULL OR cob.dtvencto <= pr_dtvenctf)   --> Data de vencimento até
						AND (pr_dtpagtoi IS NULL OR cob.dtdpagto >= pr_dtpagtoi)   --> Data de pagamento de
						AND (pr_dtpagtof IS NULL OR cob.dtdpagto <= pr_dtpagtof)   --> Data de pagamento até
            AND (pr_dsdoccop IS NULL OR cob.dsdoccop LIKE pr_dsdoccop) --> Seu Numero
            AND (pr_incobran IS NULL OR cob.incobran  = pr_incobran)   --> Situacao do titulo
            AND (pr_fldescon IS NULL OR 
                (pr_fldescon = 1 AND EXISTS(SELECT 1 FROM craptdb tdb
                                             WHERE tdb.cdcooper = cob.cdcooper
                                               AND tdb.nrdconta = cob.nrdconta
                                               AND tdb.nrcnvcob = cob.nrcnvcob
                                               AND tdb.nrdocmto = cob.nrdocmto
                                               AND tdb.nrdctabb = cob.nrdctabb
                                               AND tdb.cdbandoc = cob.cdbandoc
                                               AND tdb.insittit = 4)))
				  ORDER BY cob.nrdconta,
					         cob.nrcnvcob,
                   cob.nrdocmto;
                   
      rw_crapcob cr_crapcob%ROWTYPE;                     
  
    BEGIN

        -- Gera exceção se informar data de inicio e não informar data final e vice-versa
		    IF pr_dtbaixai IS NOT NULL AND pr_dtbaixaf IS NULL OR 
					 pr_dtbaixai IS NULL AND pr_dtbaixaf IS NOT NULL THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Deve ser informado data De e Ate do Campo Data Baixa.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
			  END IF;
				
			  -- Gera exceção se informar data de inicio e não informar data final e vice-versa
				IF pr_dtemissi IS NOT NULL AND pr_dtemissf IS NULL OR 
					 pr_dtemissi IS NULL AND pr_dtemissf IS NOT NULL THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Deve ser informado data De e Ate do Campo Data Emissao.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
			  END IF;

			  -- Gera exceção se informar data de inicio e não informar data final e vice-versa
				IF pr_dtvencti IS NOT NULL AND pr_dtvenctf IS NULL OR 
					 pr_dtvencti IS NULL AND pr_dtvenctf IS NOT NULL THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Deve ser informado data De e Ate do Campo Data Vencimento.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
			  END IF;

			  -- Gera exceção se informar data de inicio e não informar data final e vice-versa
				IF pr_dtpagtoi IS NOT NULL AND pr_dtpagtof IS NULL OR 
					 pr_dtpagtoi IS NULL AND pr_dtpagtof IS NOT NULL THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Deve ser informado data De e Ate do Campo Data Pagto.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
			  END IF;
			  
				-- Gera exceção se a data inicial informada for maior que a final
			  IF pr_dtbaixai > pr_dtbaixaf THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Baixa inicial deve ser menor ou igual a final.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;
				
				-- Gera exceção se a data inicial informada for maior que a final				
		    IF pr_dtemissi > pr_dtemissf THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Emissao inicial deve ser menor ou igual a final.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;
				
				-- Gera exceção se a data inicial informada for maior que a final				
				IF pr_dtvencti > pr_dtvenctf THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Vencimento inicial deve ser menor ou igual a final.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;
				
				-- Gera exceção se a data inicial informada for maior que a final
 				IF pr_dtpagtoi > pr_dtpagtof THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Pagto inicial deve ser menor ou igual a final.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;
				
				-- Gera exceção se a data final ultrapassar 30 dias da data inicial
			  IF (pr_dtbaixaf - pr_dtbaixai) > 30 THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Baixa final nao deve ultrapassar 30 dias da data inicial.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;

				-- Gera exceção se a data final ultrapassar 30 dias da data inicial
			  IF (pr_dtemissf - pr_dtemissi) > 30 THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Emissao final nao deve ultrapassar 30 dias da data inicial.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;
				
			  -- Gera exceção se a data final ultrapassar 30 dias da data inicial
			  IF (pr_dtvenctf - pr_dtvencti) > 30 THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Vencimento final nao deve ultrapassar 30 dias da data inicial.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;
								
			  -- Gera exceção se a data final ultrapassar 30 dias da data inicial
			  IF (pr_dtpagtof - pr_dtpagtoi) > 30 THEN
					 -- Monta Crítica
				   vr_cdcritic := 0;
					 vr_dscritic := 'Data Pagto final nao deve ultrapassar 30 dias da data inicial.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;  

        -- inicializar elemento do indice        
        vr_ind_cob := 0;
    
				-- Abre cursor para atribuir os registros encontrados na PL/Table
				FOR rw_crapcob IN cr_crapcob 
          
/*                                      (pr_cdcooper => pr_cdcooper
                                      ,pr_cdagenci => pr_cdagenci
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrctremp => pr_nrctremp
                                      ,pr_nrcnvcob => pr_nrcnvcob
                                      ,pr_nrdocmto => pr_nrdocmto
                                      ,pr_cdbandoc => pr_cdbandoc
                                      ,pr_dtemissi => pr_dtemissi
                                      ,pr_dtemissf => pr_dtemissf
                                      ,pr_dtvencti => pr_dtvencti
                                      ,pr_dtvenctf => pr_dtvenctf
                                      ,pr_dtbaixai => pr_dtbaixai
                                      ,pr_dtbaixaf => pr_dtbaixaf
                                      ,pr_dtpagtoi => pr_dtpagtoi
                                      ,pr_dtpagtof => pr_dtpagtof
                                      ,pr_vltituli => pr_vltituli
                                      ,pr_vltitulf => pr_vltitulf
                                      ,pr_dsdoccop => pr_dsdoccop
                                      ,pr_incobran => pr_incobran
                                      ,pr_flgcbdda => pr_flgcbdda
                                      ,pr_flcooexp => pr_flcooexp
                                      ,pr_flceeexp => pr_flceeexp
                                      ,pr_flprotes => pr_flprotes
                                      ,pr_fldescon => pr_fldescon) */
          
                      LOOP				   
				
          -- incrementar indice
          vr_ind_cob := vr_ind_cob + 1;
          
				  pr_tab_cob(vr_ind_cob).cdcooper := rw_crapcob.cdcooper;
					pr_tab_cob(vr_ind_cob).cdagenci := rw_crapcob.cdagenci;
					pr_tab_cob(vr_ind_cob).nrctremp := rw_crapcob.nrctremp;
					pr_tab_cob(vr_ind_cob).nrdconta := rw_crapcob.nrdconta;
					pr_tab_cob(vr_ind_cob).nrcnvcob := rw_crapcob.nrcnvcob;
					pr_tab_cob(vr_ind_cob).nrdocmto := rw_crapcob.nrdocmto;
					pr_tab_cob(vr_ind_cob).dtmvtolt := rw_crapcob.dtmvtolt;
					pr_tab_cob(vr_ind_cob).dtvencto := rw_crapcob.dtvencto;
					pr_tab_cob(vr_ind_cob).vltitulo := rw_crapcob.vltitulo;
					pr_tab_cob(vr_ind_cob).dtdbaixa := rw_crapcob.dtdbaixa;
          pr_tab_cob(vr_ind_cob).idseqttl := rw_crapcob.idseqttl;
          
          /* nome do beneficiario */
          IF rw_crapcob.cdbandoc = 085 THEN
             pr_tab_cob(vr_ind_cob).nmprimtl := rw_crapcob.nmprimtl;
          ELSE
             pr_tab_cob(vr_ind_cob).nmprimtl := substr(rw_crapcob.nmrescop || ' - ' ||
                                                rw_crapcob.nmprimtl,1,40);
          END IF;
          
          pr_tab_cob(vr_ind_cob).incobran := rw_crapcob.incobran;
          pr_tab_cob(vr_ind_cob).nossonro := rw_crapcob.nrnosnum;
          pr_tab_cob(vr_ind_cob).nmdsacad := substr(rw_crapcob.nmdsacad,1,40);
          pr_tab_cob(vr_ind_cob).nrinssac := rw_crapcob.nrinssac;
          pr_tab_cob(vr_ind_cob).cdtpinsc := rw_crapcob.cdtpinsc;
          pr_tab_cob(vr_ind_cob).dsendsac := rw_crapcob.dsendsac;
          pr_tab_cob(vr_ind_cob).complend := rw_crapcob.complend;
          pr_tab_cob(vr_ind_cob).nmbaisac := rw_crapcob.nmbaisac;
          pr_tab_cob(vr_ind_cob).nmcidsac := rw_crapcob.nmcidsac;
          pr_tab_cob(vr_ind_cob).cdufsaca := rw_crapcob.cdufsaca;
          pr_tab_cob(vr_ind_cob).nrcepsac := rw_crapcob.nrcepsac;
          
          -- Pagador - Linha 1
          pr_tab_cob(vr_ind_cob).dspagad1 := rw_crapcob.nmdsacad;
          IF rw_crapcob.cdtpinsc = 1 THEN
             pr_tab_cob(vr_ind_cob).dspagad1 := pr_tab_cob(vr_ind_cob).dspagad1 || ' - ' ||
                                                'CPF: ' || gene0002.fn_mask(rw_crapcob.nrinssac, '999.999.999-99');
          ELSE
             pr_tab_cob(vr_ind_cob).dspagad1 := pr_tab_cob(vr_ind_cob).dspagad1 || ' - ' ||
                                                'CNPJ: ' || gene0002.fn_mask(rw_crapcob.nrinssac, '999.999.999/9999-99');
          END IF;
          
          -- Pagador - Linha 2
          pr_tab_cob(vr_ind_cob).dspagad2 := rw_crapcob.dsendsac || 
            (CASE WHEN nvl(rw_crapcob.nrendsac,0) > 0 THEN ', ' || to_char(rw_crapcob.nrendsac) END) ||
            (CASE WHEN rw_crapcob.complend IS NOT NULL THEN ' - ' || rw_crapcob.complend END) ||
            ' - ' || rw_crapcob.nmbaisac;
            
          -- Pagador - Linha 3
          pr_tab_cob(vr_ind_cob).dspagad3 := rw_crapcob.nmcidsac || ' - ' || 
                                             rw_crapcob.cdufsaca || ' - CEP: ' || 
                                             gene0002.fn_mask(rw_crapcob.nrcepsac, '99999-999');
                                             
          -- Sacador / Avalista
          IF TRIM(rw_crapcob.nmdavali) IS NOT NULL THEN
             pr_tab_cob(vr_ind_cob).dssacava := rw_crapcob.nmdavali || 
                (CASE WHEN rw_crapcob.cdtpinav = 1 THEN 
                      ' - CPF: ' || gene0002.fn_mask(rw_crapcob.nrinsava, '999.999.999-99')
                 ELSE
                      ' - CNPJ: ' || gene0002.fn_mask(rw_crapcob.nrinsava, '99.999.999/9999-99')
                 END);
          END IF;
          
          pr_tab_cob(vr_ind_cob).cdbandoc := rw_crapcob.cdbandoc;          
          IF rw_crapcob.cdbandoc = 85 THEN
             pr_tab_cob(vr_ind_cob).dsbandig := '085-1';
          ELSIF rw_crapcob.cdbandoc = 001 THEN
             pr_tab_cob(vr_ind_cob).dsbandig := '001-9';
          END IF;
          
          pr_tab_cob(vr_ind_cob).nmdavali := rw_crapcob.nmdavali;
          pr_tab_cob(vr_ind_cob).nrinsava := rw_crapcob.nrinsava;
          pr_tab_cob(vr_ind_cob).cdtpinav := rw_crapcob.cdtpinav;
          pr_tab_cob(vr_ind_cob).nrcnvcob := rw_crapcob.nrcnvcob;
          pr_tab_cob(vr_ind_cob).nrcnvceb := rw_crapcob.nrcnvceb;
          pr_tab_cob(vr_ind_cob).nrdctabb := rw_crapcob.nrdctabb;
          pr_tab_cob(vr_ind_cob).nrcpfcgc := rw_crapcob.nrcpfcgc;
          pr_tab_cob(vr_ind_cob).inpessoa := rw_crapcob.inpessoa;
          pr_tab_cob(vr_ind_cob).nrdocmto := rw_crapcob.nrdocmto;
          pr_tab_cob(vr_ind_cob).dtmvtolt := rw_crapcob.dtmvtolt;
          pr_tab_cob(vr_ind_cob).dsdoccop := rw_crapcob.dsdoccop;
          pr_tab_cob(vr_ind_cob).dtvencto := rw_crapcob.dtvencto;
          pr_tab_cob(vr_ind_cob).dtretcob := rw_crapcob.dtretcob;
          pr_tab_cob(vr_ind_cob).dtdpagto := rw_crapcob.dtdpagto;
          pr_tab_cob(vr_ind_cob).vltitulo := rw_crapcob.vltitulo;
          pr_tab_cob(vr_ind_cob).vldpagto := rw_crapcob.vldpagto;
          pr_tab_cob(vr_ind_cob).vldescto := rw_crapcob.vldescto;
          pr_tab_cob(vr_ind_cob).vlabatim := rw_crapcob.vlabatim;
          pr_tab_cob(vr_ind_cob).vltarifa := rw_crapcob.vltarifa;
--          pr_tab_cob(vr_ind_cob).vlrmulta := NUMBER(25,2)
--          ,vlrjuros NUMBER(25,2)
--          ,vloutdes NUMBER(25,2)
--          ,vloutcre NUMBER(25,2)
          pr_tab_cob(vr_ind_cob).cdmensag := rw_crapcob.cdmensag;
--          ,dsdpagto VARCHAR2(11)
          pr_tab_cob(vr_ind_cob).dsorgarq := rw_crapcob.dsorgarq;
--          ,nrregist INTEGER
--          ,idbaiexc INTEGER

          IF rw_crapcob.dtdpagto IS NULL AND 
             rw_crapcob.incobran = 'A' THEN
                    
             IF rw_crapcob.dtvencto < nvl(pr_dtmvtolt, trunc(SYSDATE)) THEN
                pr_tab_cob(vr_ind_cob).cdsituac := 'V';
             ELSE
                pr_tab_cob(vr_ind_cob).cdsituac := 'A';
             END IF;
              
          ELSIF rw_crapcob.dtdpagto IS NOT NULL AND rw_crapcob.dtdbaixa IS NULL  THEN
                pr_tab_cob(vr_ind_cob).cdsituac := 'L';
                 
          ELSIF rw_crapcob.dtdbaixa IS NOT NULL OR rw_crapcob.incobran = 'B' THEN 
                pr_tab_cob(vr_ind_cob).cdsituac := 'B';
                 
          ELSIF rw_crapcob.dtelimin IS NOT NULL THEN
                pr_tab_cob(vr_ind_cob).cdsituac := 'E';
          
          ELSE
                pr_tab_cob(vr_ind_cob).cdsituac := rw_crapcob.incobran;
          END IF;

          IF    pr_tab_cob(vr_ind_cob).cdsituac = 'A' THEN
                pr_tab_cob(vr_ind_cob).dssituac := 'ABERTO';
          ELSIF pr_tab_cob(vr_ind_cob).cdsituac = 'V' THEN
                pr_tab_cob(vr_ind_cob).dssituac := 'VENCIDO';
          ELSIF pr_tab_cob(vr_ind_cob).cdsituac = 'B' THEN
                pr_tab_cob(vr_ind_cob).dssituac := 'BAIXADO';                
          ELSIF pr_tab_cob(vr_ind_cob).cdsituac = 'E' THEN
                pr_tab_cob(vr_ind_cob).dssituac := 'EXCLUIDO';
          ELSIF pr_tab_cob(vr_ind_cob).cdsituac = 'L' THEN
                pr_tab_cob(vr_ind_cob).dssituac := 'LIQUIDADO';                
          END IF;

          pr_tab_cob(vr_ind_cob).cddespec := rw_crapcob.cddespec;
          pr_tab_cob(vr_ind_cob).dsdespec := rw_crapcob.dsdespec;
          pr_tab_cob(vr_ind_cob).dtdocmto := rw_crapcob.dtdocmto;
          pr_tab_cob(vr_ind_cob).cdbanpag := rw_crapcob.cdbanpag;
          pr_tab_cob(vr_ind_cob).cdagepag := rw_crapcob.cdagepag;
          pr_tab_cob(vr_ind_cob).flgdesco := rw_crapcob.fldescon;
          pr_tab_cob(vr_ind_cob).dtelimin := rw_crapcob.dtelimin;
          pr_tab_cob(vr_ind_cob).cdcartei := rw_crapcob.cdcartei;
          
          /* cooperado emite e expede (padrao) */
          pr_tab_cob(vr_ind_cob).nrvarcar := 1;
          
          /* banco emite e expede */
          IF rw_crapcob.inemiten = 2 THEN
             pr_tab_cob(vr_ind_cob).nrvarcar := rw_crapcob.nrvarcar;
          /* cooperativa emite e expede */
          ELSIF rw_crapcob.inemiten = 3 THEN
             pr_tab_cob(vr_ind_cob).nrvarcar := 2;
          END IF;
          
          pr_tab_cob(vr_ind_cob).flgregis := rw_crapcob.flgregis;
          pr_tab_cob(vr_ind_cob).nrnosnum := rw_crapcob.nrnosnum;
--          ,dsstaabr VARCHAR2(1000)
--          ,dsstacom VARCHAR2(1000)
          pr_tab_cob(vr_ind_cob).flgaceit := rw_crapcob.flgaceit;
          pr_tab_cob(vr_ind_cob).dtsitcrt := rw_crapcob.dtsitcrt;
--          ,agencidv VARCHAR2(1000)
          pr_tab_cob(vr_ind_cob).tpjurmor := rw_crapcob.tpjurmor;
          pr_tab_cob(vr_ind_cob).tpdmulta := rw_crapcob.tpdmulta;
          pr_tab_cob(vr_ind_cob).flgdprot := rw_crapcob.flgdprot;
          pr_tab_cob(vr_ind_cob).qtdiaprt := rw_crapcob.qtdiaprt;
          pr_tab_cob(vr_ind_cob).indiaprt := rw_crapcob.indiaprt;
          pr_tab_cob(vr_ind_cob).insitpro := rw_crapcob.insitpro;
          pr_tab_cob(vr_ind_cob).flgcbdda := rw_crapcob.flgcbdda;
--          ,cdocorre INTEGER
--          ,dsocorre VARCHAR2(1000)
--          ,cdmotivo VARCHAR2(1000)
--          ,dsmotivo VARCHAR2(1000)
--          ,dtocorre DATE
          pr_tab_cob(vr_ind_cob).dtdbaixa := rw_crapcob.dtdbaixa;
--          ,vldocmto NUMBER
--          ,vlmormul NUMBER
--          ,dtvctori DATE
--          ,dscjuros VARCHAR2(1000)
--          ,dscmulta VARCHAR2(1000)
--          ,dscdscto VARCHAR2(1000)
--          ,dsinssac VARCHAR2(1000)
--          ,vldesabt NUMBER
--          ,vljurmul NUMBER
--          ,dsorigem VARCHAR2(1000)
--          ,dtcredit DATE
--          ,nrborder craptdb.nrborder;
--          ,vllimtit NUMBER
--          ,vltdscti NUMBER
--          ,nrctrlim craptdb.nrctrlim;
--          ,nrctrlim_ativo craptdb.nrctrlim;
          pr_tab_cob(vr_ind_cob).dsdemail := rw_crapcob.dsdemail;
          pr_tab_cob(vr_ind_cob).flgemail := rw_crapcob.flgemail;
          pr_tab_cob(vr_ind_cob).inemiten := rw_crapcob.inemiten;
          pr_tab_cob(vr_ind_cob).dsemiten := rw_crapcob.dsemiten;
          pr_tab_cob(vr_ind_cob).dsemitnt := rw_crapcob.dsemitnt;
          pr_tab_cob(vr_ind_cob).flgcarne := rw_crapcob.flgcarne;
          pr_tab_cob(vr_ind_cob).rowidcob := rw_crapcob.rowid;

          -- Calcular Agencia / Codigo Beneficiario          
          IF rw_crapcob.cdbandoc = 085 THEN
            vr_cdagediv := rw_crapcob.cdagectl * 10;
            vr_retorno := gene0005.fn_calc_digito(pr_nrcalcul => vr_cdagediv, pr_reqweb => FALSE);
            pr_tab_cob(vr_ind_cob).dsagebnf := gene0002.fn_mask(vr_cdagediv, '9999-9') || ' / ' ||
                                               gene0002.fn_mask(rw_crapcob.nrdconta, '9999999-9');
          ELSIF rw_crapcob.cdbandoc = 001 THEN
            vr_cdagediv := rw_crapcob.cdagenci;
            pr_tab_cob(vr_ind_cob).dsagebnf := gene0002.fn_mask(rw_crapcob.cdagedbb, '9999-9') || ' / ' ||
                                               gene0002.fn_mask(rw_crapcob.nrdctabb, '9999999-9');            
          END IF;                                               
          
          pr_tab_cob(vr_ind_cob).dsdinstr := rw_crapcob.dsdinstr;        
          pr_tab_cob(vr_ind_cob).dsinform := rw_crapcob.dsinform;

          pr_tab_cob(vr_ind_cob).dsinfor1 := ' ';
          pr_tab_cob(vr_ind_cob).dsinfor2 := ' ';
          pr_tab_cob(vr_ind_cob).dsinfor3 := ' ';
          pr_tab_cob(vr_ind_cob).dsinfor4 := ' ';                              
          pr_tab_cob(vr_ind_cob).dsinfor5 := ' ';          

          vr_dsinform := cecred.gene0002.fn_quebra_string(pr_string => rw_crapcob.dsinform,
                                                          pr_delimit => '_');

          FOR vr_ind IN 1..vr_dsinform.count() LOOP
            CASE vr_ind 
               WHEN 1 THEN pr_tab_cob(vr_ind_cob).dsinfor1 := vr_dsinform(1);
               WHEN 2 THEN pr_tab_cob(vr_ind_cob).dsinfor2 := vr_dsinform(2);               
               WHEN 3 THEN pr_tab_cob(vr_ind_cob).dsinfor3 := vr_dsinform(3);
               WHEN 4 THEN pr_tab_cob(vr_ind_cob).dsinfor4 := vr_dsinform(4);
               WHEN 5 THEN pr_tab_cob(vr_ind_cob).dsinfor5 := vr_dsinform(5);
            END CASE;           
          END LOOP;          

          pr_tab_cob(vr_ind_cob).dsdinst1 := ' ';
          pr_tab_cob(vr_ind_cob).dsdinst2 := ' ';
          pr_tab_cob(vr_ind_cob).dsdinst3 := ' ';
          pr_tab_cob(vr_ind_cob).dsdinst4 := ' ';
          pr_tab_cob(vr_ind_cob).dsdinst5 := ' ';

          CASE rw_crapcob.cdmensag 
             WHEN 0 THEN pr_tab_cob(vr_ind_cob).dsdinst1 := ' ';
             WHEN 1 THEN pr_tab_cob(vr_ind_cob).dsdinst1 := 'MANTER DESCONTO ATE O VENCIMENTO';
             WHEN 2 THEN pr_tab_cob(vr_ind_cob).dsdinst1 := 'MANTER DESCONTO APOS O VENCIMENTO';
          ELSE 
             pr_tab_cob(vr_ind_cob).dsdinst1 := ' ';             
          END CASE;
          
          IF nvl(rw_crapcob.nrctremp,0) > 0 THEN
             pr_tab_cob(vr_ind_cob).dsdinst1 := '*** NAO ACEITAR PAGAMENTO APOS O VENCIMENTO ***';
          END IF;                    
          
          IF (rw_crapcob.tpjurmor <> 3) OR (rw_crapcob.tpdmulta <> 3) THEN
            
            pr_tab_cob(vr_ind_cob).dsdinst2 := 'APOS VENCIMENTO, COBRAR: ';
            
            IF rw_crapcob.tpjurmor = 1 THEN 
               pr_tab_cob(vr_ind_cob).dsdinst2 := pr_tab_cob(vr_ind_cob).dsdinst2 || 'R$ ' || to_char(rw_crapcob.vljurdia, 'fm999g999g990d00') || ' JUROS AO DIA';
            ELSIF rw_crapcob.tpjurmor = 2 THEN 
               pr_tab_cob(vr_ind_cob).dsdinst2 := pr_tab_cob(vr_ind_cob).dsdinst2 || to_char(rw_crapcob.vljurdia, 'fm999g999g990d00') || '% JUROS AO MES';
            END IF;
      			
            IF rw_crapcob.tpjurmor <> 3 AND
               rw_crapcob.tpdmulta <> 3 THEN
               pr_tab_cob(vr_ind_cob).dsdinst2 := pr_tab_cob(vr_ind_cob).dsdinst2 || ' E ';
            END IF;

            IF rw_crapcob.tpdmulta = 1 THEN 
               pr_tab_cob(vr_ind_cob).dsdinst2 := pr_tab_cob(vr_ind_cob).dsdinst2 || 'MULTA DE R$ ' || to_char(rw_crapcob.vlrmulta, 'fm999g999g990d00');
            ELSIF rw_crapcob.tpdmulta = 2 THEN 
               pr_tab_cob(vr_ind_cob).dsdinst2 := pr_tab_cob(vr_ind_cob).dsdinst2 || 'MULTA DE ' || to_char(rw_crapcob.vlrmulta, 'fm999g999g990d00') || '%';
            END IF;
      			      			
          END IF;
          
          IF rw_crapcob.flgdprot = 1 THEN
             pr_tab_cob(vr_ind_cob).dsdinst3 := 'PROTESTAR APOS ' || to_char(rw_crapcob.qtdiaprt,'fm00') || ' DIAS CORRIDOS DO VENCIMENTO.';
             pr_tab_cob(vr_ind_cob).dsdinst4 := '*** SERVICO DE PROTESTO SERA EFETUADO PELO BANCO DO BRASIL ***';
          END IF;
                    
          IF rw_crapcob.flserasa = 1 AND rw_crapcob.qtdianeg > 0  THEN
             pr_tab_cob(vr_ind_cob).dsdinst3 := 'NEGATIVAR NA SERASA APOS ' || to_char(rw_crapcob.qtdianeg,'fm00') || ' DIAS CORRIDOS DO VENCIMENTO.';
             pr_tab_cob(vr_ind_cob).dsdinst4 := ' ';
          END IF;
                    
          pr_tab_cob(vr_ind_cob).dsavis2v := ' ';
          
          IF nvl(rw_crapcob.nrctremp,0) = 0 THEN
             pr_tab_cob(vr_ind_cob).dslocpag := 'APOS VENCIMENTO, PAGAR SOMENTE NA COOPERATIVA ' || rw_crapcob.nmrescop;
             pr_tab_cob(vr_ind_cob).dsavis2v := 'Apos o vencimento, acesse http://' || rw_crapcob.dsendweb || '.';
          ELSE
             pr_tab_cob(vr_ind_cob).dslocpag := 'NAO ACEITAR PAGAMENTO APOS O VENCIMENTO';
          END IF;
          
          pc_calc_codigo_barras ( pr_dtvencto => rw_crapcob.dtvencto
                                 ,pr_cdbandoc => rw_crapcob.cdbandoc
                                 ,pr_vltitulo => rw_crapcob.vltitulo
                                 ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                                 ,pr_nrcnvceb => rw_crapcob.nrcnvceb
                                 ,pr_nrdconta => rw_crapcob.nrdconta
                                 ,pr_nrdocmto => rw_crapcob.nrdocmto                                 
                                 ,pr_cdcartei => rw_crapcob.cdcartei
                                 ,pr_cdbarras => pr_tab_cob(vr_ind_cob).cdbarras);
          
          pc_calc_linha_digitavel(pr_cdbarras => pr_tab_cob(vr_ind_cob).cdbarras,
                                  pr_lindigit => pr_tab_cob(vr_ind_cob).lindigit);
                                  					
				END LOOP;
        
        IF pr_tab_cob.count() = 0 THEN
           RAISE vr_exc_semresultado;
        END IF;
  
    EXCEPTION
      
      WHEN vr_exc_semresultado THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Boletos nao encontrados.';
      
      WHEN vr_exc_saida THEN
        -- Se possui código de crítica e não foi informado a descrição
        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
           -- Busca descrição da crítica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Atribui exceção para os parametros de crítica
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
    				
        -- Atribui exceção para os parametros de crítica				
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na COBR0005.pc_buscar_titulo_cobranca: ' || SQLERRM;

    END;
      
  END pc_buscar_titulo_cobranca;                                          

END COBR0005;
/
