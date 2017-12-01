CREATE OR REPLACE PACKAGE CECRED.TELA_LCREDI is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : XXXX0001
  --  Sistema  : Rotina acessada pela tela LCREDI
  --  Sigla    : XXXX
  --  Autor    : Andre Otto - RKAM
  --  Data     : Julho/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas utilizadas para a tela LCREDI
  ---------------------------------------------------------------------------------------------------------------
  
  PROCEDURE pc_consulta_craplcr_lcredi(pr_cdlcremp  IN craplcr.cdlcremp%type   --> Linha de crédito
                                      ,pr_cddopcao  IN VARCHAR2                --> Código da opção
                                      ,pr_nrregist  IN INTEGER                 --> Número de registros
                                      ,pr_nriniseq  IN INTEGER                 --> Número sequencial
                                      ,pr_xmllog    IN VARCHAR2                --> XML com informações de LOG
                                      ,pr_cdcritic  OUT PLS_INTEGER            --> Código da crítica
                                      ,pr_dscritic  OUT VARCHAR2               --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                      ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                      ,pr_des_erro  OUT VARCHAR2);             --> Descrição do erro
                                    
  PROCEDURE pc_alterar_linha_credito(pr_cdlcremp IN craplcr.cdlcremp%TYPE --> Cõdigo da linha de crédito
                                    ,pr_dslcremp IN craplcr.dslcremp%TYPE --> Ddescrição da linha de crédito
                                    ,pr_tpctrato IN craplcr.tpctrato%TYPE --> Tipo de modelo
                                    ,pr_nrgrplcr IN craplcr.nrgrplcr%type --> Grupo
                                    ,pr_txjurfix IN craplcr.txjurfix%type --> Taxa juro fixo
                                    ,pr_txjurvar IN craplcr.txjurvar%type --> Taxa juro variável
                                    ,pr_txpresta IN craplcr.txpresta%type --> Taxa prestação
                                    ,pr_qtdcasas IN craplcr.qtdcasas%type --> Quantidade de casas decimais
                                    ,pr_nrinipre IN craplcr.nrinipre%type --> Número inicial da prestação
                                    ,pr_nrfimpre IN craplcr.nrfimpre%type --> Número final da prestação
                                    ,pr_txbaspre IN craplcr.txbaspre%type --> Taxa base da prestação
                                    ,pr_qtcarenc IN craplcr.qtcarenc%type --> Dias de carência
                                    ,pr_vlmaxass IN craplcr.vlmaxass%type --> Valor máximo fisica
                                    ,pr_vlmaxasj IN craplcr.vlmaxasj%type --> Valor máximo juridica
                                    ,pr_txminima IN craplcr.txminima%type --> Taxa minima
                                    ,pr_txmaxima IN craplcr.txmaxima%type --> Taxa máxima
                                    ,pr_perjurmo IN craplcr.perjurmo%type --> Percentual do juros
                                    ,pr_tpdescto IN craplcr.tpdescto%type --> Tipo de desconto
                                    ,pr_nrdevias IN craplcr.nrdevias%type --> Números de vias
                                    ,pr_cdusolcr IN craplcr.cdusolcr%type --> Código de uso
                                    ,pr_flgtarif IN craplcr.flgtarif%type --> Tarifa normal
                                    ,pr_flgtaiof IN craplcr.flgtaiof%type --> Tarifa IOF
                                    ,pr_vltrfesp IN craplcr.vltrfesp%type --> Valor trsnferência em espécie
                                    ,pr_flgcrcta IN craplcr.flgcrcta%type --> Credita em conta
                                    ,pr_dsoperac IN craplcr.dsoperac%type --> Descrição da operação
                                    ,pr_dsorgrec IN craplcr.dsorgrec%type --> Origem do recurso
                                    ,pr_manterpo IN craplcr.nrdialiq%type --> Manter após liquidar
                                    ,pr_flgimpde IN craplcr.flgimpde%type --> Imprimir declaração
                                    ,pr_flglispr IN craplcr.flglispr%type --> Listar na proposta 
                                    ,pr_tplcremp IN craplcr.tplcremp%type --> Tipo da linha de crédito
                                    ,pr_cdmodali IN craplcr.cdmodali%type --> Código da modalidade
                                    ,pr_cdsubmod IN craplcr.cdsubmod%type --> Código da submodalidade
                                    ,pr_flgrefin IN craplcr.flgrefin%type --> Refinanciamento
                                    ,pr_flgreneg IN craplcr.flgreneg%type --> Renegociação
                                    ,pr_qtrecpro IN craplcr.qtrecpro%type --> Reciprocidade da linha
                                    ,pr_consaut  IN craplcr.inconaut%type --> Consulta automatizada
                                    ,pr_flgdisap IN craplcr.flgdisap%type --> Dispensar aprovação
                                    ,pr_flgcobmu IN craplcr.flgcobmu%type --> Cobrar multa
                                    ,pr_flgsegpr IN craplcr.flgsegpr%type --> Seguro prestamista
                                    ,pr_cdhistor IN craplcr.cdhistor%type --> Código do histórico 
                                    ,pr_tpprodut IN craplcr.tpprodut%TYPE --> Tipo do Produto
                                    ,pr_cddindex IN craplcr.cddindex%TYPE --> Codigo do Indexador
                                    ,pr_permingr IN craplcr.permingr%TYPE --> % Mínimo Garantia
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica   
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica  
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML 
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro    
                                    ,pr_des_erro OUT VARCHAR2);           --> Descrição do erro                   
                                                                              
  PROCEDURE pc_blq_lib_lcredi(pr_cdlcremp IN craplcr.cdlcremp%TYPE --> Código da linha de crédito
                             ,pr_cddopcao IN VARCHAR2              --> Código da opção
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);           --> Descrição do erro
  
  PROCEDURE pc_excluir_lcredi(pr_cdlcremp IN craplcr.cdlcremp%TYPE --> Código da linha de crédito
                             ,pr_cddopcao IN VARCHAR2              --> Código da opção
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);           --> Descrição do erro   
                             
  PROCEDURE pc_incluir_linha_credito(pr_cdlcremp IN craplcr.cdlcremp%TYPE --> Cõdigo da linha de crédito
                                    ,pr_dslcremp IN craplcr.dslcremp%TYPE --> Ddescrição da linha de crédito
                                    ,pr_tpctrato IN craplcr.tpctrato%TYPE --> Tipo de modelo
                                    ,pr_nrgrplcr IN craplcr.nrgrplcr%TYPE --> Grupo
                                    ,pr_txjurfix IN craplcr.txjurfix%TYPE --> Taxa juro fixo
                                    ,pr_txjurvar IN craplcr.txjurvar%TYPE --> Taxa juro variável
                                    ,pr_txpresta IN craplcr.txpresta%TYPE --> Taxa prestação
                                    ,pr_qtdcasas IN craplcr.qtdcasas%TYPE --> Quantidade de casas decimais
                                    ,pr_nrinipre IN craplcr.nrinipre%TYPE --> Número inicial da prestação
                                    ,pr_nrfimpre IN craplcr.nrfimpre%TYPE --> Número final da prestação
                                    ,pr_txbaspre IN craplcr.txbaspre%TYPE --> Taxa base da prestação
                                    ,pr_qtcarenc IN craplcr.qtcarenc%TYPE --> Dias de carência
                                    ,pr_vlmaxass IN craplcr.vlmaxass%TYPE --> Valor máximo fisica
                                    ,pr_vlmaxasj IN craplcr.vlmaxasj%TYPE --> Valor máximo juridica
                                    ,pr_txminima IN craplcr.txminima%TYPE --> Taxa minima
                                    ,pr_txmaxima IN craplcr.txmaxima%TYPE --> Taxa máxima
                                    ,pr_perjurmo IN craplcr.perjurmo%TYPE --> Percentual do juros
                                    ,pr_tpdescto IN craplcr.tpdescto%TYPE --> Tipo de desconto
                                    ,pr_nrdevias IN craplcr.nrdevias%TYPE --> Números de vias
                                    ,pr_cdusolcr IN craplcr.cdusolcr%TYPE --> Código de uso
                                    ,pr_flgtarif IN craplcr.flgtarif%TYPE --> Tarifa normal
                                    ,pr_flgtaiof IN craplcr.flgtaiof%TYPE --> Tarifa IOF
                                    ,pr_vltrfesp IN craplcr.vltrfesp%TYPE --> Valor trsnferência em espécie
                                    ,pr_flgcrcta IN craplcr.flgcrcta%TYPE --> Credita em conta
                                    ,pr_dsoperac IN craplcr.dsoperac%TYPE --> Descrição da operação
                                    ,pr_dsorgrec IN craplcr.dsorgrec%TYPE --> Origem do recurso
                                    ,pr_manterpo IN craplcr.nrdialiq%TYPE --> Manter após liquidar
                                    ,pr_flgimpde IN craplcr.flgimpde%TYPE --> Imprimir declaração
                                    ,pr_flglispr IN craplcr.flglispr%TYPE --> Listar na proposta 
                                    ,pr_tplcremp IN craplcr.tplcremp%TYPE --> Tipo da linha de crédito
                                    ,pr_cdmodali IN craplcr.cdmodali%TYPE --> Código da modalidade
                                    ,pr_cdsubmod IN craplcr.cdsubmod%TYPE --> Código da submodalidade
                                    ,pr_flgrefin IN craplcr.flgrefin%TYPE --> Refinanciamento
                                    ,pr_flgreneg IN craplcr.flgreneg%TYPE --> Renegociação
                                    ,pr_qtrecpro IN craplcr.qtrecpro%TYPE --> Reciprocidade da linha
                                    ,pr_consaut  IN craplcr.inconaut%TYPE --> Consulta automatizada
                                    ,pr_flgdisap IN craplcr.flgdisap%TYPE --> Dispensar aprovação
                                    ,pr_flgcobmu IN craplcr.flgcobmu%TYPE --> Cobrar multa
                                    ,pr_flgsegpr IN craplcr.flgsegpr%TYPE --> Seguro prestamista
                                    ,pr_cdhistor IN craplcr.cdhistor%TYPE --> Código do histórico
                                    ,pr_cdfinali IN VARCHAR2              --> Finalidades 
                                    ,pr_tpprodut IN craplcr.tpprodut%TYPE --> Tipo do Produto
                                    ,pr_cddindex IN craplcr.cddindex%TYPE --> Codigo do Indexador
                                    ,pr_permingr IN craplcr.permingr%TYPE --> % Mínimo Garantia
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Descrição do erro                                                       
                                                              
  PROCEDURE pc_calcula_taxas_web(pr_txjurvar IN craplcr.txjurvar%TYPE --> Juro variável
                                ,pr_txjurfix IN craplcr.txjurfix%TYPE --> Juro fixo
                                ,pr_txminima IN craplcr.txminima%TYPE --> Taxa minima
                                ,pr_txmaxima IN craplcr.txmaxima%TYPE --> Taxa maxima
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                                         
  PROCEDURE pc_busca_modalidade(pr_nrregist IN INTEGER               -- Número de registros
                               ,pr_nriniseq IN INTEGER               -- Número sequencial 
                               ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                               ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK
                               
  PROCEDURE pc_busca_submodalidade(pr_cdmodali IN gnmodal.cdmodali%TYPE --Codigo da modalidade
                                  ,pr_cdsubmod IN gnsbmod.cdsubmod%TYPE --Codigo da submodalidade
                                  ,pr_nriniseq IN INTEGER               -- Número sequencial 
                                  ,pr_nrregist IN INTEGER               -- Número de registros
                                  ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK                                          
END TELA_LCREDI;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_LCREDI IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : XXXX0001
  --  Sistema  : Rotina acessada pela tela LCREDI
  --  Sigla    : XXXX
  --  Autor    : Andre Otto - RKAM
  --  Data     : Julho/2014.                   Ultima atualizacao: 10/08/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas utilizadas para a tela LCREDI
  --
  -- Alteracoes: 10/08/2016 - Ajuste referente a homologação da área de negócio
  --                          (Andrei - RKAM)
  --
  --             11/04/2017 - Alteração para gerar log na tela Logtel para os campos cdmodali 
  --                          e cdsubmod em alterações
  --                          Rafael (Mouts) - Chamado 638849
  ---------------------------------------------------------------------------------------------------------------

  -- Variaveis de log
  vr_cdoperad      VARCHAR2(100);
  vr_cdcooper      NUMBER;
  vr_nmdatela      VARCHAR2(100);
  vr_nmeacao       VARCHAR2(100);
  vr_cdagenci      VARCHAR2(100);
  vr_nrdcaixa      VARCHAR2(100);
  vr_idorigem      VARCHAR2(100);
  
  -- Variável de críticas
  vr_cdcritic      crapcri.cdcritic%TYPE;
  vr_dscritic      VARCHAR2(4000);
  
  vr_exc_saida     EXCEPTION;

  
  PROCEDURE pc_consulta_craplcr_lcredi(pr_cdlcremp  IN craplcr.cdlcremp%type   --> Linha de crédito
                                      ,pr_cddopcao  IN VARCHAR2                --> Código da opção
                                      ,pr_nrregist  IN INTEGER                 --> Número de registros
                                      ,pr_nriniseq  IN INTEGER                 --> Número sequencial
                                      ,pr_xmllog    IN VARCHAR2                --> XML com informações de LOG
                                      ,pr_cdcritic  OUT PLS_INTEGER            --> Código da crítica
                                      ,pr_dscritic  OUT VARCHAR2               --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                      ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                      ,pr_des_erro  OUT VARCHAR2) IS           --> Descrição do erro
										
    /* .............................................................................
    
        Programa: pc_consulta_craplcr_lcredi
        Sistema : CECRED
        Sigla   : LCREDI
        Autor   : Andrei - RKAM
        Data    : Julho - 2016.                    Ultima atualizacao: 28/03/2017
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado pela web
    
        Objetivo  : Rotina para buscar os dados.
    
        Observacao: -----
    
        Alteracoes: 28/03/2017 - Inclusao dos campos Produto e Indexador. (Jaison/James - PRJ298)
                    
                    10/10/2017 - Inclusao do campo % Mínimo Garantia e opção 4 no campo Modelo. (Lombardi - PRJ404)
    ..............................................................................*/

    CURSOR cr_craplcr(p_cdcooper IN crapcop.cdcooper%type
                     ,p_cdlcremp IN craplcr.cdlcremp%type) IS 
      SELECT c.dslcremp
           , decode(c.flgstlcr,1,'LIBERADA','BLOQUEADA') ||
             decode(c.flgsaldo,1,' COM SALDO',' SEM SALDO') dssitlcr
           , c.nrgrplcr
           , c.txmensal
           , c.txdiaria * 100 txdiaria
           , c.txjurfix
           , c.txjurvar
           , c.txpresta
           , c.qtdcasas
           , c.nrinipre
           , c.nrfimpre
           , c.txbaspre
           , c.qtcarenc
           , c.vlmaxass
           , c.vlmaxasj
           , c.perjurmo
           , c.flgtarif
           , c.flgtaiof
           , c.vltrfesp
           , c.flgcrcta
           , c.txminima
           , c.txmaxima
           , c.tpctrato
           , c.tpdescto
           , c.nrdevias
           , c.permingr
           , c.cdusolcr
           , c.tplcremp
           , decode(c.tplcremp,1,'Normal',2,'Equiv. Salarial') dstipolc
           , c.dsorgrec
           , c.nrdialiq manterpo
           , c.flgimpde
           , c.dsoperac
           , c.flglispr
           , c.qtrecpro
           , c.flgrefin
           , decode(c.inconaut,0,1,0) consaut
           , c.flgreneg
           , c.flgdisap
           , c.flgcobmu
           , c.flgsegpr
           , c.cdhistor
           , c.cdmodali
           , c.cdsubmod
           , c.tpprodut
           , c.cddindex
        FROM craplcr c
       WHERE c.cdcooper = p_cdcooper
         AND c.cdlcremp = p_cdlcremp;    
    rw_craplcr        cr_craplcr%ROWTYPE;
    
    CURSOR cr_gnmodal(p_cdmodali IN craplcr.cdmodali%type) IS
      SELECT g.dsmodali
            ,g.cdmodali
        FROM gnmodal g
       WHERE g.cdmodali = p_cdmodali;    
    rw_gnmodal cr_gnmodal%ROWTYPE;
    
    CURSOR cr_gnsbmod(p_cdmodali in craplcr.cdmodali%TYPE 
                     ,p_cdsubmod in craplcr.cdsubmod%TYPE) IS
      SELECT g.dssubmod
            ,g.cdsubmod
        FROM gnsbmod g
       WHERE g.cdmodali = p_cdmodali
         AND g.cdsubmod = p_cdsubmod;    
    rw_gnsbmod cr_gnsbmod%ROWTYPE;
    
    CURSOR cr_craplch(pr_cdcooper IN craplch.cdcooper%TYPE
                     ,pr_cdlcrhab IN craplch.cdlcrhab%TYPE) IS
    SELECT craplch.cdfinemp
          ,crapfin.dsfinemp
      FROM craplch
          ,crapfin
     WHERE craplch.cdcooper = pr_cdcooper
       AND craplch.cdlcrhab = pr_cdlcrhab
       AND crapfin.cdcooper = craplch.cdcooper
       AND crapfin.cdfinemp = craplch.cdfinemp
           ORDER BY craplch.cdfinemp;
    rw_craplch cr_craplch%ROWTYPE;
    
    CURSOR cr_crapccp(pr_cdcooper IN crapccp.cdcooper%TYPE
                     ,pr_cdlcremp IN crapccp.cdlcremp%TYPE
                     ,pr_nrparcel IN crapccp.nrparcel%TYPE)IS
    SELECT crapccp.incalpre
      FROM crapccp
     WHERE crapccp.cdcooper = pr_cdcooper
       AND crapccp.cdlcremp = pr_cdlcremp   
       AND crapccp.nrparcel = pr_nrparcel;
    rw_crapccp cr_crapccp%ROWTYPE;                         
    
    vr_dsctrato       craptab.dstextab%TYPE;
    vr_dsdescto       VARCHAR2(100);
    vr_dsusolcr       VARCHAR2(100);
    vr_nrregist INTEGER;
    vr_qtregist INTEGER := 0;
    
    --Variaveis Arquivo Dados
    vr_auxconta PLS_INTEGER:= 0;
    
  BEGIN
    
    vr_nrregist := pr_nrregist;
  
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'LCREDI'
                              ,pr_action => null);
                                
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
                            
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF; 

    OPEN cr_craplcr(vr_cdcooper,pr_cdlcremp);
    
    FETCH cr_craplcr into rw_craplcr;
    
    IF cr_craplcr%NOTFOUND THEN 
       
      CLOSE cr_craplcr;
      
      IF pr_cddopcao = 'I' THEN
        
        pr_des_erro := 'OK';
        RETURN;
        
      ELSE
        
        vr_cdcritic := 363;
        RAISE vr_exc_saida;
      
      END IF;
      
    ELSE
      
      CLOSE cr_craplcr;
      
      IF pr_cddopcao = 'I' THEN
        
        vr_cdcritic := 937;
        RAISE vr_exc_saida;
      
      END IF;       
      
    END IF;
    
    OPEN cr_gnmodal(rw_craplcr.cdmodali);
    
    FETCH cr_gnmodal INTO rw_gnmodal;
    
    CLOSE cr_gnmodal;
    
    OPEN cr_gnsbmod(rw_craplcr.cdmodali, rw_craplcr.cdsubmod);
    
    FETCH cr_gnsbmod INTO rw_gnsbmod;
    
    CLOSE cr_gnsbmod;
    
    vr_dsctrato := TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'GENERI'
                                             ,pr_cdempres => 0
                                             ,pr_cdacesso => 'CTRATOEMPR'
                                             ,pr_tpregist => rw_craplcr.tpctrato);
    
    IF vr_dsctrato IS NULL THEN 
      vr_dsctrato := 'MODELO NAO CADASTRADO';
    END IF;
    
    IF rw_craplcr.tpdescto = 1 THEN
      vr_dsdescto := 'C/C';
    ELSE
      vr_dsdescto := 'CONSIG. FOLHA';
    END IF;
    
    IF rw_craplcr.cdusolcr = 0 THEN 
      vr_dsusolcr := 'NORMAL';
    ELSIF rw_craplcr.cdusolcr = 1 THEN 
      vr_dsusolcr := 'MICRO CREDITO';
    ELSIF rw_craplcr.cdusolcr = 2 THEN 
      vr_dsusolcr := 'EPR/BOLETOS';
    END IF;
    
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => null, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'craplcr', pr_tag_cont => null, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'dslcremp', pr_tag_cont => rw_craplcr.dslcremp, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'dssitlcr', pr_tag_cont => rw_craplcr.dssitlcr, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'nrgrplcr', pr_tag_cont => rw_craplcr.nrgrplcr, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'txmensal', pr_tag_cont => to_char(rw_craplcr.txmensal,'fm990d000000','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'txdiaria', pr_tag_cont => to_char(rw_craplcr.txdiaria,'fm990d0000000','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'txjurfix', pr_tag_cont => to_char(rw_craplcr.txjurfix,'fm990d000','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'txjurvar', pr_tag_cont => to_char(rw_craplcr.txjurvar,'fm990d000','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'txpresta', pr_tag_cont => to_char(rw_craplcr.txpresta,'fm990d000','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'qtdcasas', pr_tag_cont => rw_craplcr.qtdcasas, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'nrinipre', pr_tag_cont => rw_craplcr.nrinipre, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'nrfimpre', pr_tag_cont => rw_craplcr.nrfimpre, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'txbaspre', pr_tag_cont => to_char(rw_craplcr.txbaspre,'fm990d000','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'qtcarenc', pr_tag_cont => rw_craplcr.qtcarenc, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'vlmaxass', pr_tag_cont => to_char(rw_craplcr.vlmaxass,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'vlmaxasj', pr_tag_cont => to_char(rw_craplcr.vlmaxasj,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'perjurmo', pr_tag_cont => to_char(rw_craplcr.perjurmo,'fm990d000000','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'flgtarif', pr_tag_cont => rw_craplcr.flgtarif, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'flgtaiof', pr_tag_cont => rw_craplcr.flgtaiof, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'vltrfesp', pr_tag_cont => to_char(rw_craplcr.vltrfesp,'fm999g990d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'flgcrcta', pr_tag_cont => rw_craplcr.flgcrcta, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'txminima', pr_tag_cont => to_char(rw_craplcr.txminima,'fm990d000','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'txmaxima', pr_tag_cont => to_char(rw_craplcr.txmaxima,'fm990d000','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'tpctrato', pr_tag_cont => rw_craplcr.tpctrato, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'tpdescto', pr_tag_cont => rw_craplcr.tpdescto, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'permingr', pr_tag_cont => to_char(rw_craplcr.permingr,'fm990d00'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'nrdevias', pr_tag_cont => rw_craplcr.nrdevias, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'cdusolcr', pr_tag_cont => rw_craplcr.cdusolcr, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'tplcremp', pr_tag_cont => rw_craplcr.tplcremp, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'dstipolc', pr_tag_cont => rw_craplcr.dstipolc, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'dsorgrec', pr_tag_cont => rw_craplcr.dsorgrec, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'manterpo', pr_tag_cont => rw_craplcr.manterpo, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'flgimpde', pr_tag_cont => rw_craplcr.flgimpde, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'dsoperac', pr_tag_cont => rw_craplcr.dsoperac, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'flglispr', pr_tag_cont => rw_craplcr.flglispr, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'qtrecpro', pr_tag_cont => to_char(rw_craplcr.qtrecpro,'fm990d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'flgrefin', pr_tag_cont => rw_craplcr.flgrefin, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'consaut', pr_tag_cont => rw_craplcr.consaut, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'flgreneg', pr_tag_cont => rw_craplcr.flgreneg, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'flgdisap', pr_tag_cont => rw_craplcr.flgdisap, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'flgcobmu', pr_tag_cont => rw_craplcr.flgcobmu, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'flgsegpr', pr_tag_cont => rw_craplcr.flgsegpr, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'cdhistor', pr_tag_cont => rw_craplcr.cdhistor, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'cdmodali', pr_tag_cont => rw_gnmodal.cdmodali, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'dsmodali', pr_tag_cont => rw_gnmodal.dsmodali, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'cdsubmod', pr_tag_cont => rw_gnsbmod.cdsubmod, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'dssubmod', pr_tag_cont => rw_gnsbmod.dssubmod, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'dsctrato', pr_tag_cont => vr_dsctrato, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'dsdescto', pr_tag_cont => vr_dsdescto, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'dsusolcr', pr_tag_cont => vr_dsusolcr, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'tpprodut', pr_tag_cont => rw_craplcr.tpprodut, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'craplcr', pr_posicao => 0, pr_tag_nova => 'cddindex', pr_tag_cont => rw_craplcr.cddindex, pr_des_erro => vr_dscritic);

    IF pr_cddopcao = 'F' THEN
      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'finalidades', pr_tag_cont => null, pr_des_erro => vr_dscritic);
          
      FOR rw_craplch IN cr_craplch(pr_cdcooper => vr_cdcooper
                                  ,pr_cdlcrhab => pr_cdlcremp) LOOP
        
        --Incrementar contador
        vr_qtregist:= nvl(vr_qtregist,0) + 1;
          
        -- controles da paginacao 
        IF (vr_qtregist < pr_nriniseq) OR
           (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
            
          --Proximo
          CONTINUE;  
            
        END IF; 
          
        IF vr_nrregist >= 1 THEN  
            
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'finalidades', pr_posicao => 0, pr_tag_nova => 'finalidade', pr_tag_cont => null, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'finalidade', pr_posicao => vr_auxconta, pr_tag_nova => 'cdfinemp', pr_tag_cont => to_char(rw_craplch.cdfinemp,'990'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'finalidade', pr_posicao => vr_auxconta, pr_tag_nova => 'dsfinemp', pr_tag_cont => rw_craplch.dsfinemp, pr_des_erro => vr_dscritic);
          
          -- Incrementa contador p/ posicao no XML
          vr_auxconta := nvl(vr_auxconta,0) + 1;
          
         END IF;
         
       --Diminuir registros
       vr_nrregist:= nvl(vr_nrregist,0) - 1; 
          
      END LOOP;       
    
    ELSIF pr_cddopcao = 'P' THEN      
      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'prestacoes', pr_tag_cont => null, pr_des_erro => vr_dscritic);
      
      -- Percorre a quantidade de prestações
      FOR vr_qtpresta IN rw_craplcr.nrinipre..rw_craplcr.nrfimpre LOOP 
        
        FOR rw_crapccp IN cr_crapccp(pr_cdcooper => vr_cdcooper
                                    ,pr_cdlcremp => pr_cdlcremp
                                    ,pr_nrparcel => vr_qtpresta) LOOP
          
          --Incrementar contador
          vr_qtregist:= nvl(vr_qtregist,0) + 1;
            
          -- controles da paginacao 
          IF (vr_qtregist < pr_nriniseq) OR
             (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
              
            --Proximo
            CONTINUE;  
              
          END IF; 
            
          IF vr_nrregist >= 1 THEN     
            
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'prestacoes', pr_posicao => 0, pr_tag_nova => 'prestacao', pr_tag_cont => null, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'prestacao', pr_posicao => vr_auxconta, pr_tag_nova => 'qtpresta', pr_tag_cont => to_char(vr_qtpresta,'990'), pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'prestacao', pr_posicao => vr_auxconta, pr_tag_nova => 'incalpre', pr_tag_cont => to_char(rw_crapccp.incalpre,'fm0d000000','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
          
            -- Incrementa contador p/ posicao no XML
            vr_auxconta := nvl(vr_auxconta,0) + 1;
          
          END IF;
           
         --Diminuir registros
         vr_nrregist:= nvl(vr_nrregist,0) - 1; 
            
        END LOOP; 
        
      END LOOP;
      
    END IF;
    
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'Root'             --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                                 
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;  
    
    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_nmdcampo := 'cdlcremp';
      
      pr_des_erro := 'NOK';
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em TELA_LCREDI.pc_consulta_craplcr_lcredi: ' || SQLERRM;
      pr_des_erro := 'NOK';
      
      pr_nmdcampo := 'cdlcremp';
      
      pr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_consulta_craplcr_lcredi;
  
  PROCEDURE pc_calcula_taxas(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                            ,pr_alocatab IN INTEGER               --> 1 - Alocar tabela / 0 - Não alocar tabela
                            ,pr_txjurvar IN craplcr.txjurvar%TYPE --> Juro variável
                            ,pr_txjurfix IN craplcr.txjurfix%TYPE --> Juro fixo
                            ,pr_txminima IN craplcr.txminima%TYPE --> Taxa minima
                            ,pr_txmaxima IN craplcr.txmaxima%TYPE --> Taxa maxima
                            ,pr_txmensal OUT NUMBER               --> Taxa mensal
                            ,pr_txdiaria OUT NUMBER               --> Taxa diaria
                            ,pr_cdcritic OUT INTEGER              --> Código da critica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da critica
                            ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................
    
        Programa: pc_calcula_taxa
        Sistema : CECRED
        Sigla   : LCREDI
        Autor   : Andrei - RKAM
        Data    : Julho - 2016.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para calcular taxas de juros
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Cursor para encontrar o registros de taxas do mes
      CURSOR cr_craptab(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT dstextab
        FROM craptab tab
       WHERE tab.cdcooper = pr_cdcooper
         AND UPPER(tab.nmsistem) = 'CRED'
         AND UPPER(tab.tptabela) = 'GENERI'
         AND tab.cdempres = 00
         AND UPPER(tab.cdacesso) = 'TAXASDOMES'
         AND tab.tpregist = 1 FOR UPDATE;
      
      --> Tabela de retorno do operadores que estao alocando a tabela especifidada
      vr_tab_locktab GENE0001.typ_tab_locktab;
        
      -- Variável exceção para locke
      vr_exc_locked EXCEPTION;
      PRAGMA EXCEPTION_INIT(vr_exc_locked, -54);
      
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
      --Variaveis locais
      vr_dstextab craptab.dstextab%type;  
      vr_txutiliz NUMBER(9,6) := 0;  
      vr_des_erro VARCHAR2(10); 
              
    BEGIN
      
      --Alocar tabela
      IF pr_alocatab = 1 THEN
        
        BEGIN
          -- Busca tabela com as taxas
          OPEN cr_craptab(pr_cdcooper => vr_cdcooper);
        
          FETCH cr_craptab into vr_dstextab;
          
          IF cr_craptab%NOTFOUND THEN 
          
            --Fecha o cursor
            CLOSE cr_craptab;
            
            --Monta critica
            vr_dscritic := 'Registros de taxas nao encontrado.';
            --pr_nmdcampo := 'cdlcremp';
            RAISE vr_exc_saida;
            
          ELSE
            
            --Fecha o cursor
            CLOSE cr_craptab;
            
          END IF;
            
        EXCEPTION
          WHEN vr_exc_locked THEN
            gene0001.pc_ver_lock(pr_nmtabela    => 'CRAPTAB'
                                ,pr_nrdrecid    => ''
                                ,pr_des_reto    => vr_des_erro
                                ,pt_tab_locktab => vr_tab_locktab);
                                  
            IF vr_des_erro = 'OK' THEN
              FOR VR_IND IN 1..vr_tab_locktab.COUNT LOOP
                vr_dscritic := 'Registro sendo alterado em outro terminal (CRAPTAB)' || 
                               ' - ' || vr_tab_locktab(VR_IND).nmusuari;
              END LOOP;
            END IF;              
            
            RAISE vr_exc_saida;
               
        END;
        
      ELSE
         
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => 'TAXASDOMES'
                                                 ,pr_tpregist => 1);
        
        --Se nao encontrou
        IF vr_dstextab IS NULL THEN
          
          -- Montar mensagem de critica
          vr_cdcritic := 347;
          vr_dscritic := '';
          
          -- volta para o programa chamador
          RAISE vr_exc_saida;
          
        END IF;
          
      END IF; 
        
      /* Ident. TR ou UFIR */
      IF SUBSTR(vr_dstextab,1,1) = 'T' THEN
              
        vr_txutiliz := to_number(substr(vr_dstextab,3,10));
             
      ELSE
              
        vr_txutiliz := to_number(substr(vr_dstextab,14,10));
              
      END IF;
            
      pr_txmensal := ROUND(((vr_txutiliz * (pr_txjurvar / 100) + 100) * 
                           (1 + (pr_txjurfix / 100)) - 100),6);
                                    
      IF NVL(pr_txminima,0) > pr_txmensal THEN
           
        pr_txmensal := pr_txminima;
          
      ELSIF NVL(pr_txmaxima,0) > 0           AND 
            NVL(pr_txmaxima,0) < pr_txmensal THEN
        
        pr_txmensal := pr_txmaxima;
          
      END IF;
        
      pr_txdiaria := ROUND((pr_txmensal / 3000), 7);
        
      pr_des_erro := 'OK';
      
    EXCEPTION
      WHEN vr_exc_saida THEN
      
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
      
        pr_des_erro := 'NOK';
        
      WHEN OTHERS THEN
      
        pr_des_erro := 'NOK';
           
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na TELA_LCREDI.pc_calcula_taxas --> '|| SQLERRM;
        
    END;
    
  END pc_calcula_taxas;
  
  
  PROCEDURE pc_calcula_taxas_web(pr_txjurvar IN craplcr.txjurvar%TYPE --> Juro variável
                                ,pr_txjurfix IN craplcr.txjurfix%TYPE --> Juro fixo
                                ,pr_txminima IN craplcr.txminima%TYPE --> Taxa minima
                                ,pr_txmaxima IN craplcr.txmaxima%TYPE --> Taxa maxima
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................
    
        Programa: pc_calcula_taxa_web
        Sistema : CECRED
        Sigla   : LCREDI
        Autor   : Andrei - RKAM
        Data    : Julho - 2016.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado pela web
    
        Objetivo  : Rotina para calcular taxas de juros
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
            
      --Variaveis locais      
      vr_txmensal NUMBER(9,6) := 0;
      vr_txdiaria NUMBER(10,7) := 0;
      vr_des_erro VARCHAR2(10);
    
    BEGIN
        
      GENE0001.pc_informa_acesso(pr_module => 'LCREDI' 
                                ,pr_action => null);
                                
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
        RAISE vr_exc_saida;
      END IF;
                             
      pc_calcula_taxas(pr_cdcooper => vr_cdcooper
                      ,pr_alocatab => 0
                      ,pr_txjurvar => pr_txjurvar 
                      ,pr_txjurfix => pr_txjurfix
                      ,pr_txminima => pr_txminima
                      ,pr_txmaxima => pr_txmaxima
                      ,pr_txmensal => vr_txmensal
                      ,pr_txdiaria => vr_txdiaria
                      ,pr_cdcritic => vr_cdcritic
                      ,pr_dscritic => vr_dscritic
                      ,pr_des_erro => vr_des_erro);                           
       
      IF vr_des_erro <> 'OK'           OR 
         nvl(vr_cdcritic,0) <> 0       OR 
         trim(vr_dscritic) IS NOT NULL THEN      
         
        RAISE vr_exc_saida;
      
      END IF;                   
                           
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml          --> XML que irá receber o novo atributo
                               ,pr_tag   => 'Root'             --> Nome da TAG XML
                               ,pr_atrib => 'txmensal'          --> Nome do atributo
                               ,pr_atval => to_char(vr_txmensal,
                                                    'fm990D000000',
                                                    'NLS_NUMERIC_CHARACTERS='',.''') --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
    
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml          --> XML que irá receber o novo atributo
                               ,pr_tag   => 'Root'             --> Nome da TAG XML
                               ,pr_atrib => 'txdiaria'         --> Nome do atributo
                               ,pr_atval => to_char((vr_txdiaria * 100),
                                                    'fm990D0000000',
                                                    'NLS_NUMERIC_CHARACTERS='',.''') --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros                               
                               
      pr_des_erro := 'OK';
      
    EXCEPTION
      WHEN vr_exc_saida THEN
      
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
        
      WHEN OTHERS THEN
      
        pr_des_erro := 'NOK';
           
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na TELA_LCREDI.pc_calcula_taxas_web --> '|| SQLERRM;
          
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
      
       
    END;
    
  END pc_calcula_taxas_web;
  
  PROCEDURE pc_alterar_linha_credito(pr_cdlcremp IN craplcr.cdlcremp%TYPE --> Cõdigo da linha de crédito
                                    ,pr_dslcremp IN craplcr.dslcremp%TYPE --> Ddescrição da linha de crédito
                                    ,pr_tpctrato IN craplcr.tpctrato%TYPE --> Tipo de modelo
                                    ,pr_nrgrplcr IN craplcr.nrgrplcr%type --> Grupo
                                    ,pr_txjurfix IN craplcr.txjurfix%type --> Taxa juro fixo
                                    ,pr_txjurvar IN craplcr.txjurvar%type --> Taxa juro variável
                                    ,pr_txpresta IN craplcr.txpresta%type --> Taxa prestação
                                    ,pr_qtdcasas IN craplcr.qtdcasas%type --> Quantidade de casas decimais
                                    ,pr_nrinipre IN craplcr.nrinipre%type --> Número inicial da prestação
                                    ,pr_nrfimpre IN craplcr.nrfimpre%type --> Número final da prestação
                                    ,pr_txbaspre IN craplcr.txbaspre%type --> Taxa base da prestação
                                    ,pr_qtcarenc IN craplcr.qtcarenc%type --> Dias de carência
                                    ,pr_vlmaxass IN craplcr.vlmaxass%type --> Valor máximo fisica
                                    ,pr_vlmaxasj IN craplcr.vlmaxasj%type --> Valor máximo juridica
                                    ,pr_txminima IN craplcr.txminima%type --> Taxa minima
                                    ,pr_txmaxima IN craplcr.txmaxima%type --> Taxa máxima
                                    ,pr_perjurmo IN craplcr.perjurmo%type --> Percentual do juros
                                    ,pr_tpdescto IN craplcr.tpdescto%type --> Tipo de desconto
                                    ,pr_nrdevias IN craplcr.nrdevias%type --> Números de vias
                                    ,pr_cdusolcr IN craplcr.cdusolcr%type --> Código de uso
                                    ,pr_flgtarif IN craplcr.flgtarif%type --> Tarifa normal
                                    ,pr_flgtaiof IN craplcr.flgtaiof%type --> Tarifa IOF
                                    ,pr_vltrfesp IN craplcr.vltrfesp%type --> Valor trsnferência em espécie
                                    ,pr_flgcrcta IN craplcr.flgcrcta%type --> Credita em conta
                                    ,pr_dsoperac IN craplcr.dsoperac%type --> Descrição da operação
                                    ,pr_dsorgrec IN craplcr.dsorgrec%type --> Origem do recurso
                                    ,pr_manterpo IN craplcr.nrdialiq%type --> Manter após liquidar
                                    ,pr_flgimpde IN craplcr.flgimpde%type --> Imprimir declaração
                                    ,pr_flglispr IN craplcr.flglispr%type --> Listar na proposta 
                                    ,pr_tplcremp IN craplcr.tplcremp%type --> Tipo da linha de crédito
                                    ,pr_cdmodali IN craplcr.cdmodali%type --> Código da modalidade
                                    ,pr_cdsubmod IN craplcr.cdsubmod%type --> Código da submodalidade
                                    ,pr_flgrefin IN craplcr.flgrefin%type --> Refinanciamento
                                    ,pr_flgreneg IN craplcr.flgreneg%type --> Renegociação
                                    ,pr_qtrecpro IN craplcr.qtrecpro%type --> Reciprocidade da linha
                                    ,pr_consaut  IN craplcr.inconaut%type --> Consulta automatizada
                                    ,pr_flgdisap IN craplcr.flgdisap%type --> Dispensar aprovação
                                    ,pr_flgcobmu IN craplcr.flgcobmu%type --> Cobrar multa
                                    ,pr_flgsegpr IN craplcr.flgsegpr%type --> Seguro prestamista
                                    ,pr_cdhistor IN craplcr.cdhistor%type --> Código do histórico  
                                    ,pr_tpprodut IN craplcr.tpprodut%TYPE --> Tipo do Produto
                                    ,pr_cddindex IN craplcr.cddindex%TYPE --> Codigo do Indexador
                                    ,pr_permingr IN craplcr.permingr%TYPE --> % Mínimo Garantia
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG  
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica    
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica    
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML    
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro      
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Descrição do erro                 

    /* .............................................................................
    
        Programa: pc_alterar_linha_credito
        Sistema : CECRED
        Sigla   : LCREDI
        Autor   : Andrei - RKAM
        Data    : Julho - 2016.                    Ultima atualizacao: 28/03/2017
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado pela web
    
        Objetivo  : Rotina para alterar uma linha de crédito
    
        Observacao: -----
    
        Alteracoes: 10/08/2016 - Ajustado validação do tipo de contrato e nas mensagens
							     de log para as informações alteradas
								 (Andrei - RKAM).		

                    28/03/2017 - Inclusao dos campos Produto e Indexador. (Jaison/James - PRJ298)
                    
                    10/10/2017 - Inclusao do campo % Mínimo Garantia e opção 4 no campo Modelo. (Lombardi - PRJ404)
    ..............................................................................*/
	CURSOR cr_craplcr(pr_cdcooper in crapcop.cdcooper%type
                     ,pr_cdlcremp in craplcr.cdlcremp%type) is
      SELECT c.cdlcremp
           , c.cdcooper
           , c.dslcremp
           , c.dsoperac
           , c.tplcremp
           , c.tpdescto
           , c.nrdevias
           , c.permingr
           , c.cdusolcr
           , c.flgtarif
           , c.flgtaiof
           , c.vltrfesp
           , c.flgcrcta
           , c.nrdialiq
           , c.flgimpde
           , c.dsorgrec
           , c.flglispr
           , c.txjurfix
           , c.txjurvar
           , c.txpresta
           , c.txminima
           , c.txmaxima
           , c.txbaspre
           , c.nrgrplcr
           , c.qtcarenc
           , c.perjurmo
           , c.vlmaxass
           , c.vlmaxasj
           , c.nrinipre
           , c.nrfimpre
           , c.qtdcasas
           , c.flgrefin
           , c.flgreneg
           , c.flgdisap
           , c.flgcobmu
           , c.flgsegpr
           , c.cdhistor
           , c.cdmodali -- modalidade
           , c.cdsubmod -- sub-modalidade
           , c.tpprodut
           , c.cddindex
        FROM craplcr c
       WHERE c.cdcooper = pr_cdcooper
         AND c.cdlcremp = pr_cdlcremp
         FOR UPDATE;  
    rw_craplcr cr_craplcr%ROWTYPE;
    
    CURSOR cr_craplcr_base(pr_cdcooper in crapcop.cdcooper%type
                          ,pr_nrgrplcr in craplcr.nrgrplcr%type) is
      SELECT c.txbaspre
        FROM craplcr c
       WHERE c.cdcooper = pr_cdcooper
         AND c.nrgrplcr = pr_nrgrplcr
         FOR UPDATE;  
    rw_craplcr_base cr_craplcr_base%ROWTYPE;
    
    CURSOR cr_crapepr(p_cdcooper IN crapcop.cdcooper%TYPE
                     ,p_cdlcremp IN craplcr.cdlcremp%TYPE) IS
    SELECT 1
      FROM crapepr c
     WHERE c.cdcooper = p_cdcooper
       AND c.cdlcremp = p_cdlcremp
       AND c.inliquid = 0;
    rw_crapepr cr_crapepr%ROWTYPE;
     
    -- Cursor para encontrar o histórico
    CURSOR cr_craphis(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_cdhistor IN craphis.cdhistor%TYPE) IS
    SELECT his.cdhistor      
      FROM craphis his
     WHERE his.cdcooper = pr_cdcooper
       AND his.cdhistor = pr_cdhistor;
    rw_craphis cr_craphis%ROWTYPE;
       
    CURSOR cr_crapccp(pr_cdcooper IN crapccp.cdcooper%TYPE
                     ,pr_cdlcremp IN crapccp.cdlcremp%TYPE
                     ,pr_nrparcel IN crapccp.nrparcel%TYPE)IS
    SELECT crapccp.incalpre
      FROM crapccp
     WHERE crapccp.cdcooper = pr_cdcooper
       AND crapccp.cdlcremp = pr_cdlcremp   
       AND crapccp.nrparcel = pr_nrparcel;
    rw_crapccp cr_crapccp%ROWTYPE;
         
    --Variáveis locais
    vr_dstextab craptab.dstextab%TYPE;
    vr_txmensal NUMBER(9,6) := 0;
    vr_txdiaria NUMBER(10,7) := 0;
    vr_des_erro VARCHAR2(10);
    vr_incalpre crapccp.incalpre%TYPE;
    vr_txbaspre crapccp.incalpre%TYPE;
    vr_incalcul crapccp.incalpre%TYPE;
    vr_permingr craplcr.permingr%TYPE;
    
    --> Tabela de retorno do operadores que estao alocando a tabela especifidada
    vr_tab_locktab GENE0001.typ_tab_locktab;
      
    -- Variável exceção para locke
    vr_exc_locked EXCEPTION;
    PRAGMA EXCEPTION_INIT(vr_exc_locked, -54);
    
  BEGIN
    
    GENE0001.pc_informa_acesso(pr_module => 'LCREDI' 
                              ,pr_action => null);
                              
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
                            
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF; 
    
    -- Verifica se existe algum operador utilizando a tela CALPRE 
    vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'GENERI'
                                            ,pr_cdempres => 00
                                            ,pr_cdacesso => 'OPCALCPRE'
                                            ,pr_tpregist => 0);
    -- Se encontrou 
    IF vr_dstextab IS NULL THEN
      
      vr_cdcritic := 0;
      vr_dscritic := 'Tela CALPRE esta sendo usada pelo operador ' || vr_dstextab;
      RAISE vr_exc_saida;
        
    END IF;
    
    BEGIN
      -- Busca linha de crédito
      OPEN cr_craplcr(vr_cdcooper,pr_cdlcremp);
    
      FETCH cr_craplcr into rw_craplcr;
      
      IF cr_craplcr%NOTFOUND THEN 
      
        --Fecha o cursor
        CLOSE cr_craplcr;
        
        --Monta critica
        vr_cdcritic := 363;
        pr_nmdcampo := 'cdlcremp';
        RAISE vr_exc_saida;
        
      ELSE
        
        --Fecha o cursor
        CLOSE cr_craplcr;
        
      END IF;
        
    EXCEPTION
      WHEN vr_exc_locked THEN
        gene0001.pc_ver_lock(pr_nmtabela    => 'CRAPLCR'
                            ,pr_nrdrecid    => ''
                            ,pr_des_reto    => vr_des_erro
                            ,pt_tab_locktab => vr_tab_locktab);
                              
        IF vr_des_erro = 'OK' THEN
          FOR VR_IND IN 1..vr_tab_locktab.COUNT LOOP
            vr_dscritic := 'Registro sendo alterado em outro terminal (CRAPLCR)' || 
                           ' - ' || vr_tab_locktab(VR_IND).nmusuari;
          END LOOP;
        END IF;
          
        pr_nmdcampo := 'cdlcremp';
        RAISE vr_exc_saida;
           
    END;
    
    IF TRIM(pr_dslcremp) IS NULL THEN
      
      vr_dscritic := 'Informe a descricao da linha de credito.';
      pr_nmdcampo := 'dslcremp';
        
      RAISE  vr_exc_saida;
      
    END IF;
    
    IF NOT pr_tplcremp IN (1,2) THEN
      
      vr_cdcritic := 513;
      pr_nmdcampo := 'tplcremp';
        
      RAISE  vr_exc_saida;
      
    END IF;
      
    IF pr_tpdescto NOT IN (1,2) THEN
      
      vr_cdcritic := 513;
      pr_nmdcampo := 'tpdescto';
        
      RAISE  vr_exc_saida;
      
    END IF;
    
    IF pr_tpctrato NOT IN (1,2,3,4) THEN
      
      vr_cdcritic := 529;
      pr_nmdcampo := 'tpctrato';
        
      RAISE  vr_exc_saida;
      
    END IF;
    
    IF pr_tpctrato <> 4 THEN
      vr_permingr := 0;
    ELSE
      vr_permingr := pr_permingr;
    END IF;
    
    IF pr_tpctrato = 4 AND (vr_permingr < 0.01 OR vr_permingr > 300) THEN
      
      vr_dscritic := 'Percentual minimo da cobertura da garantia de aplicacao inválido. Deve ser entre "0.01" e "300".';
      pr_nmdcampo := 'permingr';
        
      RAISE  vr_exc_saida;
      
    END IF;
    
    IF NOT NVL(pr_nrdevias,0) > 0 THEN
      
      vr_cdcritic := 26;
      pr_nmdcampo := 'nrdevias';
        
      RAISE  vr_exc_saida;
      
    END IF;
    
    IF pr_cdusolcr NOT IN (0,1,2) THEN
      
      vr_cdcritic := 269;
      pr_nmdcampo := 'cdusolcr';
        
      RAISE  vr_exc_saida;
      
    END IF;
    
    IF TRIM(pr_cdmodali) IS NULL THEN
      
      vr_cdcritic := 375;
      pr_nmdcampo := 'cdmodali';
        
      RAISE  vr_exc_saida;
      
    END IF;
    
    IF TRIM(pr_cdsubmod) IS NULL THEN
      
      vr_cdcritic := 375;
      pr_nmdcampo := 'cdsubmod';
        
      RAISE  vr_exc_saida;
      
    END IF;

    -- Se for Pos-Fixado e Taxa Variavel nao for maior que zero
    IF pr_tpprodut = 2 AND NVL(pr_txjurvar,0) <= 0 THEN
      vr_cdcritic := 185;
      pr_nmdcampo := 'txjurvar';
      RAISE  vr_exc_saida;
    END IF;
    
    IF pr_tpdescto <> rw_craplcr.tpdescto THEN
      
      OPEN cr_crapepr(vr_cdcooper,pr_cdlcremp);
      
      FETCH cr_crapepr INTO rw_crapepr;
      
      IF cr_crapepr%FOUND THEN 
        
        CLOSE cr_crapepr;
        
        vr_cdcritic := 377;
        pr_nmdcampo := 'tpdescto';
        
        RAISE  vr_exc_saida;
        
      ELSE 
        CLOSE  cr_crapepr;
      END IF;
      
    END IF;
       
    IF vr_cdcooper <> 9       AND
       NVL(pr_txminima,0) = 0 THEN
      
      vr_cdcritic := 185;
      pr_nmdcampo := 'txminima';
        
      RAISE  vr_exc_saida;   
    
    END IF;
    
    IF NVL(pr_txmaxima,0) > 0                  AND
       NVL(pr_txminima,0) > NVL(pr_txmaxima,0) THEN
      
      vr_dscritic := 'Taxa minima deve ser menor que a taxa maxima.';
      pr_nmdcampo := 'txminima';
        
      RAISE  vr_exc_saida;   
    
    END IF;
    
    IF NOT nvl(pr_nrinipre,0) > 0 THEN
      
      vr_cdcritic := 380;
      pr_nmdcampo := 'nrinipre';
        
      RAISE  vr_exc_saida;
      
    END IF;
    
    IF NOT nvl(pr_nrfimpre,0) > 0    OR 
       NOT nvl(pr_nrfimpre,0) <= 240 THEN
      
      vr_cdcritic := 380;
      pr_nmdcampo := 'nrfimpre';
        
      RAISE  vr_exc_saida;
      
    END IF;
    
    IF NOT nvl(pr_qtdcasas,0) > 0 OR 
       NOT nvl(pr_qtdcasas,0) < 7 THEN
      
      vr_cdcritic := 380;
      pr_nmdcampo := 'qtdcasas';
        
      RAISE  vr_exc_saida;
      
    END IF;
        
    -- Verifica se a taxa base pertence ao grupo informado 
    OPEN cr_craplcr_base(vr_cdcooper,pr_nrgrplcr);
    
    FETCH cr_craplcr_base into rw_craplcr_base;
      
    IF cr_craplcr_base%FOUND                          AND 
       vr_cdcooper <> 9                               AND 
       NVL(pr_txbaspre,0) <> rw_craplcr_base.txbaspre THEN 
      
      --Fecha o cursor
      CLOSE cr_craplcr_base;
        
      --Monta critica
      vr_cdcritic := 382;
      pr_nmdcampo := 'txbaspre';
      RAISE vr_exc_saida;
        
    ELSE
        
      --Fecha o cursor
      CLOSE cr_craplcr_base;
        
    END IF;

    IF vr_cdcooper <> 9       AND
       NVL(pr_txbaspre,0) = 0 THEN
      
      vr_cdcritic := 185;
      pr_nmdcampo := 'txbaspre';
        
      RAISE  vr_exc_saida;   
    
    END IF;
    
    vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'USUARI'
                                            ,pr_cdempres => 11
                                            ,pr_cdacesso => 'CALCPRESTA'
                                            ,pr_tpregist => pr_nrgrplcr);
    -- Se encontrou 
    IF vr_dstextab IS NOT NULL THEN
      
      vr_cdcritic := 570;
      pr_nmdcampo := 'nrgrplcr';
      RAISE vr_exc_saida;
        
    END IF;
    
    IF NVL(pr_nrinipre,0) > NVL(pr_nrfimpre,0) THEN
      
      vr_cdcritic := 380;
      pr_nmdcampo := 'nrinipre';
        
      RAISE  vr_exc_saida;   
    
    END IF;
    
    /* Permitir no maximo 99 parcelas para tipo de desconto 
      consignado em Folha de pagamento. Isto ocorre por   
      restricao de layout CNAB que permite no maximo 2 caracter 
      Sidnei - Precise IT */
    IF NVL(pr_tpdescto,0) = 2  AND
       NVL(pr_nrfimpre,0) > 99 THEN
      
      vr_dscritic := 'Permitido informar no maximo 99 parcelas p/ Linhas com Desconto em Folha.';
      pr_nmdcampo := 'nrfimpre';
        
      RAISE  vr_exc_saida;   
    
    END IF;
    
    pc_calcula_taxas(pr_cdcooper => vr_cdcooper --> Cooperativa
                    ,pr_alocatab => 1           --> 1 - Alocar tabela / 0 - Não alocar tabela
                    ,pr_txjurvar => pr_txjurvar --> Juro variável
                    ,pr_txjurfix => pr_txjurfix --> Juro fixo
                    ,pr_txminima => pr_txminima --> Taxa minima
                    ,pr_txmaxima => pr_txmaxima --> Taxa maxima
                    ,pr_txmensal => vr_txmensal --> Taxa mensal
                    ,pr_txdiaria => vr_txdiaria --> Taxa diaria
                    ,pr_cdcritic => vr_cdcritic --> Código da critica
                    ,pr_dscritic => vr_dscritic --> Descrição da critica
                    ,pr_des_erro => vr_des_erro);--> Erros do processo

    IF vr_des_erro <> 'OK'           OR 
       nvl(vr_cdcritic,0) <> 0       OR 
       trim(vr_dscritic) IS NOT NULL THEN      
         
      RAISE vr_exc_saida;
      
    END IF;                    
                             
    IF NVL(pr_flgcrcta,0) = 0 THEN
      
      OPEN cr_craphis(pr_cdcooper => vr_cdcooper
                     ,pr_cdhistor => pr_cdhistor);
                           
      FETCH cr_craphis INTO rw_craphis;
            
      -- Se não encontrar
      IF cr_craphis%NOTFOUND THEN
              
        -- Fecha o cursor
        CLOSE cr_craphis;
              
        -- Monta critica
        vr_cdcritic := 93;
        vr_dscritic := NULL;
        pr_nmdcampo := 'cdhistor';
              
        -- Gera exceção
        RAISE vr_exc_saida;              
              
      ELSE
        -- Fecha o cursor
        CLOSE cr_craphis;
              
      END IF;   
    
    END IF;         
                
    --  Alterando/Criando/excluindo tabela de coeficientes de prestacao
    FOR vr_qtpresta IN pr_nrinipre..pr_nrfimpre LOOP 
        
      FOR rw_crapccp IN cr_crapccp(pr_cdcooper => vr_cdcooper
                                  ,pr_cdlcremp => pr_cdlcremp
                                  ,pr_nrparcel => vr_qtpresta) LOOP

        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'lcredi.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                      'Coeficiente da Prestacao = ' || vr_qtpresta || ' de ' ||  
                                                      to_char(rw_crapccp.incalpre,'0.000000') || ' Linha: ' ||
                                                      to_char(rw_craplcr.cdlcremp,'9990') || '.');
         
      END LOOP;
      
    END LOOP;
    
    -- Limpar coeficientes
    BEGIN
      
      DELETE crapccp
       WHERE crapccp.cdcooper = rw_craplcr.cdcooper
         AND crapccp.cdlcremp = rw_craplcr.cdlcremp;
    
    EXCEPTION
      WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao tentar eliminar a crapccp - '||sqlerrm;
          RAISE vr_exc_saida; 
    
    END;
    
    FOR vr_qtpresta IN pr_nrinipre..pr_nrfimpre LOOP 
        
      IF pr_txbaspre = 0 THEN
           
        vr_incalpre := 1 / vr_qtpresta;
        
      ELSE
        
        vr_txbaspre := pr_txbaspre / 100;
        vr_incalcul := POWER((1 + vr_txbaspre),vr_qtpresta);
        vr_incalpre := POWER(((vr_incalcul - 1) / (vr_txbaspre * vr_incalcul)),- 1);
      
      END IF;
      
      vr_incalpre := ROUND(vr_incalpre,pr_qtdcasas);
      
      BEGIN
        
        INSERT INTO crapccp(crapccp.cdcooper
                           ,crapccp.cdlcremp
                           ,crapccp.nrparcel
                           ,crapccp.incalpre)
                     VALUES(rw_craplcr.cdcooper
                           ,rw_craplcr.cdlcremp
                           ,vr_qtpresta
                           ,vr_incalpre); 
                           
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'lcredi.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                      'Coeficiente de Prestacao = ' || vr_qtpresta || ' para ' ||  
                                                      to_char(vr_incalpre,'0.000000') || ' Linha: ' ||
                                                      to_char(rw_craplcr.cdlcremp,'9990') ||'.');
                                     
      
      EXCEPTION
        WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao tentar incluir a crapccp - '||sqlerrm;
            RAISE vr_exc_saida; 
      
      END;
      
    END LOOP;
    
    BEGIN
      UPDATE craplcr c
         SET c.dslcremp = pr_dslcremp
           , c.nrgrplcr = pr_nrgrplcr
           , c.txmensal = vr_txmensal
           , c.txdiaria = vr_txdiaria
           , c.txjurfix = pr_txjurfix
           , c.txjurvar = pr_txjurvar
           , c.txpresta = pr_txpresta
           , c.qtdcasas = pr_qtdcasas
           , c.nrinipre = pr_nrinipre
           , c.nrfimpre = pr_nrfimpre
           , c.txbaspre = pr_txbaspre
           , c.qtcarenc = pr_qtcarenc
           , c.vlmaxass = pr_vlmaxass          
           , c.vlmaxasj = pr_vlmaxasj
           , c.txminima = pr_txminima
           , c.txmaxima = pr_txmaxima
           , c.perjurmo = pr_perjurmo
           , c.tpdescto = pr_tpdescto
           , c.nrdevias = pr_nrdevias
           , c.permingr = vr_permingr
           , c.cdusolcr = pr_cdusolcr
           , c.flgtarif = pr_flgtarif
           , c.flgtaiof = pr_flgtaiof
           , c.vltrfesp = pr_vltrfesp
           , c.flgcrcta = pr_flgcrcta
           , c.dsoperac = pr_dsoperac
           , c.dsorgrec = pr_dsorgrec
           , c.nrdialiq = pr_manterpo
           , c.flgimpde = pr_flgimpde
           , c.flglispr = pr_flglispr
           , c.tplcremp = pr_tplcremp
           , c.cdmodali = TRIM(to_char(pr_cdmodali,'99900'))
           , c.cdsubmod = TRIM(to_char(pr_cdsubmod,'99900'))
           , c.flgrefin = pr_flgrefin
           , c.flgreneg = pr_flgreneg
           , c.qtrecpro = pr_qtrecpro
           , c.inconaut = decode(pr_consaut,1,0,1)
           , c.flgdisap = pr_flgdisap
           , c.flgcobmu = pr_flgcobmu
           , c.flgsegpr = pr_flgsegpr
           , c.cdhistor = pr_cdhistor
           , c.tpprodut = pr_tpprodut
           , c.cddindex = pr_cddindex
       WHERE c.cdcooper = vr_cdcooper
         AND c.cdlcremp = pr_cdlcremp;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao tentar atualizar a craplcr - '||sqlerrm;
        RAISE vr_exc_saida;
    END;
    --
    -- Valida alteracao na modalidade, se sim, gerar log tela logtel
    IF NVL(TRIM(pr_cdmodali),'-1') <> NVL(TRIM(rw_craplcr.cdmodali),'-1') THEN
      -- logtel
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou a Modalidade da Linha de Credito ' || trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' de ' || nvl(rw_craplcr.cdmodali,'ND') || ' para ' || nvl(pr_cdmodali,'ND') || '.');
    END IF;
    --
    -- Valida alteracao na submodalidade, se sim, gerar log tela logtel
    IF NVL(TRIM(pr_cdsubmod),'-1') <> NVL(TRIM(rw_craplcr.cdsubmod),'-1') THEN
      -- logtel
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou a Submodalidade da Linha de Credito ' || trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' de ' || nvl(rw_craplcr.cdsubmod,'ND') || ' para ' || nvl(pr_cdsubmod,'ND') || '.');      
    END IF;    
    --	  
    IF pr_tpprodut <> rw_craplcr.tpprodut THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou o Produto da Linha de Credito ' || trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' de ' || rw_craplcr.tpprodut || ' para ' || pr_tpprodut || '.');
          
    END IF;

    IF pr_cddindex <> rw_craplcr.cddindex THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou o Indexador da Linha de Credito ' || trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' de ' || rw_craplcr.cddindex || ' para ' || pr_cddindex || '.');
          
    END IF;

    IF TRIM(pr_dslcremp) <> TRIM(rw_craplcr.dslcremp) THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou a Descricao da Linha de Credito ' || trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' de ' || rw_craplcr.dslcremp || ' para ' || pr_dslcremp || '.');
          
    END IF;
    
    IF TRIM(pr_dsoperac) <> TRIM(rw_craplcr.dsoperac) THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou a Operacao da Linha de Credito ' || trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || rw_craplcr.dsoperac || 
                                                    ' para ' || pr_dsoperac || '.');
          
    END IF;
    
    IF pr_tplcremp <> rw_craplcr.tplcremp THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou a Tipo da Linha de Credito ' || trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || rw_craplcr.tplcremp || 
                                                    ' para ' || pr_tplcremp || '.');
          
    END IF;
    
    IF pr_tpdescto <> rw_craplcr.tpdescto THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou a Tipo da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || rw_craplcr.tpdescto || 
                                                    ' para ' || pr_tpdescto || '.');
          
    END IF;
    
    IF pr_nrdevias <> rw_craplcr.nrdevias THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou o Nr. de Vias da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || rw_craplcr.nrdevias || 
                                                    ' para ' || pr_nrdevias || '.');
          
    END IF;
    
    IF vr_permingr <> rw_craplcr.permingr THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou o Percentual minimo da cobertura da garantia de aplicacao ' ||
                                                    'da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || rw_craplcr.permingr || 
                                                    ' para ' || vr_permingr || '.');
          
    END IF;
    
    IF pr_cdusolcr <> rw_craplcr.cdusolcr THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou o Cod. de Uso da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || rw_craplcr.cdusolcr || 
                                                    ' para ' || pr_cdusolcr || '.');
          
    END IF;
    
    IF pr_flgtarif <> rw_craplcr.flgtarif THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou a cobranca da Tarifa da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' ||  (CASE rw_craplcr.flgtarif  WHEN 1 THEN 'SIM' ELSE 'NAO' END) || 
                                                    ' para ' || (CASE pr_flgtarif WHEN 1 THEN 'SIM' ELSE 'NAO' END) || '.');
          
    END IF;
    
    IF pr_flgtaiof <> rw_craplcr.flgtaiof THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou a cobranca do IOF da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || (CASE rw_craplcr.flgtaiof  WHEN 1 THEN 'SIM' ELSE 'NAO' END)  || 
                                                    ' para ' || (CASE pr_flgtaiof WHEN 1 THEN 'SIM' ELSE 'NAO' END) || '.');
          
    END IF;
    
    IF pr_vltrfesp <> rw_craplcr.vltrfesp THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou Vl. da Tarf. Especial da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || to_char(rw_craplcr.vltrfesp,'fm999g990d00') || 
                                                    ' para ' || pr_vltrfesp || '.');
          
    END IF;
    
    IF pr_flgcrcta <> rw_craplcr.flgcrcta THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou parametro de Creditar em C/C da Linha de Credito ' || trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || (CASE rw_craplcr.flgcrcta  WHEN 1 THEN 'SIM' ELSE 'NAO' END) || 
                                                    ' para ' || (CASE pr_flgcrcta WHEN 1 THEN 'SIM' ELSE 'NAO' END) || '.');
          
    END IF;
    
    IF pr_manterpo <> rw_craplcr.nrdialiq THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou o val. que o Contrato sera Mantido apos Liquidado da Linha de Credito ' || trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || rw_craplcr.nrdialiq || 
                                                    ' para ' || pr_manterpo || '.');
          
    END IF;
    
    IF pr_flgimpde <> rw_craplcr.flgimpde THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou a Impressao de Declaracao da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || (CASE rw_craplcr.flgimpde  WHEN 1 THEN 'SIM' ELSE 'NAO' END) || 
                                                    ' para ' || (CASE pr_flgimpde WHEN 1 THEN 'SIM' ELSE 'NAO' END) || '.');
          
    END IF;
    
    IF pr_dsorgrec <> rw_craplcr.dsorgrec THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou a Origem de Recurso da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || rw_craplcr.dsorgrec || 
                                                    ' para ' || pr_dsorgrec || '.');
          
    END IF;
    
    IF pr_flglispr <> rw_craplcr.flglispr THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou a Listagem na Proposta da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || (CASE rw_craplcr.flglispr  WHEN 1 THEN 'SIM' ELSE 'NAO' END) || 
                                                    ' para ' || (CASE pr_flglispr WHEN 1 THEN 'SIM' ELSE 'NAO' END) || '.');
          
    END IF;
    
    IF pr_txjurfix <> rw_craplcr.txjurfix THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou o Val. de Juros Fixos da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || to_char(rw_craplcr.txjurfix,'fm990d000') || 
                                                    ' para ' || pr_txjurfix || '.');
          
    END IF;
    
    IF pr_txjurvar <> rw_craplcr.txjurvar THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou o Val. de Juros Variaveis da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || to_char(rw_craplcr.txjurvar,'fm990d000') || 
                                                    ' para ' || pr_txjurvar || '.');
          
    END IF;
    
    IF pr_txpresta <> rw_craplcr.txpresta THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou a Taxa sobre Prestacao da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || to_char(rw_craplcr.txpresta,'fm990d000') || 
                                                    ' para ' || pr_txpresta || '.');
          
    END IF;
    
    IF pr_txminima <> rw_craplcr.txminima THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou a Taxa Minima da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || to_char(rw_craplcr.txminima,'fm990d000') || 
                                                    ' para ' || pr_txminima || '.');
          
    END IF;
    
    IF pr_txmaxima <> rw_craplcr.txmaxima THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou a Taxa Maxima da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || to_char(rw_craplcr.txmaxima,'fm990d000') || 
                                                    ' para ' || pr_txmaxima || '.');
          
    END IF;
    
    IF pr_txbaspre <> rw_craplcr.txbaspre THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou a Taxa Base da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || to_char(rw_craplcr.txbaspre,'fm990d000') || 
                                                    ' para ' || pr_txbaspre || '.');
          
    END IF;
    
    IF pr_nrgrplcr <> rw_craplcr.nrgrplcr THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou o Grupo da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || rw_craplcr.nrgrplcr || 
                                                    ' para ' || pr_nrgrplcr || '.');
          
    END IF;
    
    IF pr_qtcarenc <> rw_craplcr.qtcarenc THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou os Dias de Carencia da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || rw_craplcr.qtcarenc || 
                                                    ' para ' || pr_qtcarenc || '.');
          
    END IF;
    
    IF pr_perjurmo <> rw_craplcr.perjurmo THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou o Juros de Mora da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || to_char(rw_craplcr.perjurmo,'fm990d000000') || 
                                                    ' para ' || pr_perjurmo || '.');
          
    END IF;
    
    IF pr_vlmaxass <> rw_craplcr.vlmaxass THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou o Vl.Maximo Associado da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || to_char(rw_craplcr.vlmaxass,'fm999g999g990d00') || 
                                                    ' para ' || pr_vlmaxass || '.');
          
    END IF;
    
    IF pr_vlmaxasj <> rw_craplcr.vlmaxasj THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou o Vl.Maximo para PJ da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || to_char(rw_craplcr.vlmaxasj,'fm999g999g990d00') || 
                                                    ' para ' || pr_vlmaxasj || '.');
          
    END IF;
    
    IF pr_nrinipre <> rw_craplcr.nrinipre OR 
       pr_nrfimpre <> rw_craplcr.nrfimpre THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou a Prestacao da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || rw_craplcr.nrinipre || ' a ' || rw_craplcr.nrfimpre || 
                                                    ' para ' || pr_nrinipre || ' a ' || pr_nrfimpre || '.');
          
    END IF;
    
    IF pr_qtdcasas <> rw_craplcr.qtdcasas THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou a qtd. de Decimais da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || rw_craplcr.qtdcasas || 
                                                    ' para ' || pr_qtdcasas || '.');
          
    END IF;
    
    IF pr_flgrefin <> rw_craplcr.flgrefin THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou o Refinanciamento da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || (CASE rw_craplcr.flgrefin WHEN 1 THEN 'SIM' ELSE 'NAO' END) || 
                                                    ' para ' || (CASE pr_flgrefin WHEN 1 THEN 'SIM' ELSE 'NAO' END)  || '.');
          
    END IF;
    
    IF pr_flgreneg <> rw_craplcr.flgreneg THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou a Renegociacao da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || (CASE rw_craplcr.flgreneg WHEN 1 THEN 'SIM' ELSE 'NAO' END) || 
                                                    ' para ' || (CASE pr_flgreneg WHEN 1 THEN 'SIM' ELSE 'NAO' END) || '.');
          
    END IF;
    
    IF pr_flgdisap <> rw_craplcr.flgdisap THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou Dispensar Aprovacao da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || (CASE rw_craplcr.flgdisap WHEN 1 THEN 'SIM' ELSE 'NAO' END) || 
                                                    ' para ' || (CASE pr_flgdisap WHEN 1 THEN 'SIM' ELSE 'NAO' END)  || '.');
          
    END IF;
    
    IF pr_flgcobmu <> rw_craplcr.flgcobmu THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou Cobrar Multa da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || (CASE rw_craplcr.flgcobmu WHEN 1 THEN 'SIM' ELSE 'NAO' END) || 
                                                    ' para ' || (CASE pr_flgcobmu WHEN 1 THEN 'SIM' ELSE 'NAO' END) || '.');
          
    END IF;
    
    IF pr_flgsegpr <> rw_craplcr.flgsegpr THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou Seguro Prestamista da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || (CASE rw_craplcr.flgsegpr WHEN 1 THEN 'SIM' ELSE 'NAO' END) || 
                                                    ' para ' || (CASE pr_flgsegpr WHEN 1 THEN 'SIM' ELSE 'NAO' END) || '.');
          
    END IF;
    
    IF pr_cdhistor <> rw_craplcr.cdhistor THEN    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lcredi.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Alterou Historico da Linha de Credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) ||
                                                    ' - ' || rw_craplcr.dslcremp || ' de ' || rw_craplcr.cdhistor || 
                                                    ' para ' || pr_cdhistor || '.');
          
    END IF;
      
    pr_des_erro := 'OK';
      
    --Efetua commit das alterações
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
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
      pr_dscritic := 'Erro geral em TELA_LCREDI.pc_alterar_linha_credito: ' || SQLERRM;
      pr_des_erro := 'NOK';
      pr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;
      
  END pc_alterar_linha_credito;
  
  PROCEDURE pc_incluir_linha_credito(pr_cdlcremp IN craplcr.cdlcremp%TYPE --> Cõdigo da linha de crédito
                                    ,pr_dslcremp IN craplcr.dslcremp%TYPE --> Ddescrição da linha de crédito
                                    ,pr_tpctrato IN craplcr.tpctrato%TYPE --> Tipo de modelo
                                    ,pr_nrgrplcr IN craplcr.nrgrplcr%type --> Grupo
                                    ,pr_txjurfix IN craplcr.txjurfix%type --> Taxa juro fixo
                                    ,pr_txjurvar IN craplcr.txjurvar%type --> Taxa juro variável
                                    ,pr_txpresta IN craplcr.txpresta%type --> Taxa prestação
                                    ,pr_qtdcasas IN craplcr.qtdcasas%type --> Quantidade de casas decimais
                                    ,pr_nrinipre IN craplcr.nrinipre%type --> Número inicial da prestação
                                    ,pr_nrfimpre IN craplcr.nrfimpre%type --> Número final da prestação
                                    ,pr_txbaspre IN craplcr.txbaspre%type --> Taxa base da prestação
                                    ,pr_qtcarenc IN craplcr.qtcarenc%type --> Dias de carência
                                    ,pr_vlmaxass IN craplcr.vlmaxass%type --> Valor máximo fisica
                                    ,pr_vlmaxasj IN craplcr.vlmaxasj%type --> Valor máximo juridica
                                    ,pr_txminima IN craplcr.txminima%type --> Taxa minima
                                    ,pr_txmaxima IN craplcr.txmaxima%type --> Taxa máxima
                                    ,pr_perjurmo IN craplcr.perjurmo%type --> Percentual do juros
                                    ,pr_tpdescto IN craplcr.tpdescto%type --> Tipo de desconto
                                    ,pr_nrdevias IN craplcr.nrdevias%type --> Números de vias
                                    ,pr_cdusolcr IN craplcr.cdusolcr%type --> Código de uso
                                    ,pr_flgtarif IN craplcr.flgtarif%type --> Tarifa normal
                                    ,pr_flgtaiof IN craplcr.flgtaiof%type --> Tarifa IOF
                                    ,pr_vltrfesp IN craplcr.vltrfesp%type --> Valor trsnferência em espécie
                                    ,pr_flgcrcta IN craplcr.flgcrcta%type --> Credita em conta
                                    ,pr_dsoperac IN craplcr.dsoperac%type --> Descrição da operação
                                    ,pr_dsorgrec IN craplcr.dsorgrec%type --> Origem do recurso
                                    ,pr_manterpo IN craplcr.nrdialiq%type --> Manter após liquidar
                                    ,pr_flgimpde IN craplcr.flgimpde%type --> Imprimir declaração
                                    ,pr_flglispr IN craplcr.flglispr%type --> Listar na proposta 
                                    ,pr_tplcremp IN craplcr.tplcremp%type --> Tipo da linha de crédito
                                    ,pr_cdmodali IN craplcr.cdmodali%type --> Código da modalidade
                                    ,pr_cdsubmod IN craplcr.cdsubmod%type --> Código da submodalidade
                                    ,pr_flgrefin IN craplcr.flgrefin%type --> Refinanciamento
                                    ,pr_flgreneg IN craplcr.flgreneg%type --> Renegociação
                                    ,pr_qtrecpro IN craplcr.qtrecpro%type --> Reciprocidade da linha
                                    ,pr_consaut  IN craplcr.inconaut%type --> Consulta automatizada
                                    ,pr_flgdisap IN craplcr.flgdisap%type --> Dispensar aprovação
                                    ,pr_flgcobmu IN craplcr.flgcobmu%type --> Cobrar multa
                                    ,pr_flgsegpr IN craplcr.flgsegpr%type --> Seguro prestamista
                                    ,pr_cdhistor IN craplcr.cdhistor%TYPE --> Código do histórico
                                    ,pr_cdfinali IN VARCHAR2              --> Finalidades  
                                    ,pr_tpprodut IN craplcr.tpprodut%TYPE --> Tipo do Produto
                                    ,pr_cddindex IN craplcr.cddindex%TYPE --> Codigo do Indexador
                                    ,pr_permingr IN craplcr.permingr%TYPE --> % Mínimo Garantia
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Descrição do erro                                

	/* .............................................................................
    
        Programa: pc_incluir_linha_credito
        Sistema : CECRED
        Sigla   : LCREDI
        Autor   : Andrei - RKAM
        Data    : Julho - 2016.                    Ultima atualizacao: 28/03/2017
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado pela web
    
        Objetivo  : Rotina para incluir uma linha de crédito
    
        Observacao: -----
    
        Alteracoes: 10/08/2016 - Ajustado validação do tipo de contrato, mensagens
							     de log e inclusão do registro craplcr
								 (Andrei - RKAM).		   

                    28/03/2017 - Inclusao dos campos Produto e Indexador. (Jaison/James - PRJ298)
                    
                    10/10/2017 - Inclusao do campo % Mínimo Garantia e opção 4 no campo Modelo. (Lombardi - PRJ404)
    ..............................................................................*/
    CURSOR cr_craplcr(pr_cdcooper in crapcop.cdcooper%type
                     ,pr_cdlcremp in craplcr.cdlcremp%type) is
      SELECT c.cdlcremp           
        FROM craplcr c
       WHERE c.cdcooper = pr_cdcooper
         AND c.cdlcremp = pr_cdlcremp;  
    rw_craplcr cr_craplcr%ROWTYPE;
    
    CURSOR cr_craplcr_base(pr_cdcooper in crapcop.cdcooper%type
                          ,pr_nrgrplcr in craplcr.nrgrplcr%type) is
      SELECT c.txbaspre
        FROM craplcr c
       WHERE c.cdcooper = pr_cdcooper
         AND c.nrgrplcr = pr_nrgrplcr
         FOR UPDATE;  
    rw_craplcr_base cr_craplcr_base%ROWTYPE;
    
    CURSOR cr_crapfin(pr_cdcooper IN crapfin.cdcooper%TYPE
                     ,pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
    SELECT cdfinemp
      FROM crapfin
     WHERE crapfin.cdcooper = pr_cdcooper
       AND crapfin.cdfinemp = pr_cdfinemp;       
    rw_crapfin cr_crapfin%ROWTYPE;
    
    CURSOR cr_craplch(pr_cdcooper IN craplch.cdcooper%TYPE
                     ,pr_cdlcrhab IN craplch.cdlcrhab%TYPE
                     ,pr_cdfinemp IN craplch.cdfinemp%TYPE)IS
    SELECT cdfinemp
      FROM craplch
     WHERE craplch.cdcooper = pr_cdcooper
       AND craplch.cdlcrhab = pr_cdlcrhab
       AND craplch.cdfinemp = pr_cdfinemp;       
    rw_craplch cr_craplch%ROWTYPE;
    
    CURSOR cr_craplch2(pr_cdcooper IN craplch.cdcooper%TYPE
                      ,pr_cdfinemp IN craplch.cdfinemp%TYPE)IS
    SELECT nrseqlch
      FROM craplch
     WHERE craplch.cdcooper = pr_cdcooper
       AND craplch.cdfinemp = pr_cdfinemp;       
    rw_craplch2 cr_craplch2%ROWTYPE;
    
    -- Cursor para encontrar o histórico
    CURSOR cr_craphis(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_cdhistor IN craphis.cdhistor%TYPE) IS
    SELECT his.cdhistor      
      FROM craphis his
     WHERE his.cdcooper = pr_cdcooper
       AND his.cdhistor = pr_cdhistor;
    rw_craphis cr_craphis%ROWTYPE;
       
    --Variáveis locais
    vr_dstextab craptab.dstextab%TYPE;
    vr_txmensal NUMBER(9,6) := 0;
    vr_txdiaria NUMBER(10,7) := 0;
    vr_des_erro VARCHAR2(10);
    vr_incalpre crapccp.incalpre%TYPE;
    vr_txbaspre crapccp.incalpre%TYPE;
    vr_incalcul crapccp.incalpre%TYPE;
    vr_nrseqlch craplch.nrseqlch%TYPE;
    vr_split    gene0002.typ_split := gene0002.typ_split();
    vr_permingr craplcr.permingr%TYPE;
    
  BEGIN
    
    GENE0001.pc_informa_acesso(pr_module => 'LCREDI' 
                              ,pr_action => null);
                              
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
                            
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF; 
    
    -- Verifica se existe algum operador utilizando a tela CALPRE 
    vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'GENERI'
                                            ,pr_cdempres => 00
                                            ,pr_cdacesso => 'OPCALCPRE'
                                            ,pr_tpregist => 0);
    -- Se encontrou 
    IF vr_dstextab IS NULL THEN
      
      vr_cdcritic := 0;
      vr_dscritic := 'Tela CALPRE esta sendo usada pelo operador ' || vr_dstextab;
      RAISE vr_exc_saida;
        
    END IF;
        
    -- Busca linha de crédito
    OPEN cr_craplcr(vr_cdcooper,pr_cdlcremp);
    
    FETCH cr_craplcr into rw_craplcr;
      
    IF cr_craplcr%FOUND THEN 
      
      --Fecha o cursor
      CLOSE cr_craplcr;
        
      --Monta critica
      vr_cdcritic := 937;
      pr_nmdcampo := 'cdlcremp';
      RAISE vr_exc_saida;
        
    ELSE
        
      --Fecha o cursor
      CLOSE cr_craplcr;
        
    END IF;
    
    IF TRIM(pr_dslcremp) IS NULL THEN
      
      vr_dscritic := 'Informe a descricao da linha de credito.';
      pr_nmdcampo := 'dslcremp';
        
      RAISE  vr_exc_saida;
      
    END IF;
    
    IF NOT pr_tplcremp IN (1,2) THEN
      
      vr_cdcritic := 513;
      pr_nmdcampo := 'tplcremp';
        
      RAISE  vr_exc_saida;
      
    END IF;
      
    IF pr_tpdescto NOT IN (1,2) THEN
      
      vr_cdcritic := 513;
      pr_nmdcampo := 'tpdescto';
        
      RAISE  vr_exc_saida;
      
    END IF;
    
    IF pr_tpctrato NOT IN (1,2,3,4) THEN
      
      vr_cdcritic := 529;
      pr_nmdcampo := 'tpctrato';
        
      RAISE  vr_exc_saida;
      
    END IF;
    
    IF pr_tpctrato <> 4 THEN
      vr_permingr := 0;
    ELSE
      vr_permingr := pr_permingr;
    END IF;
    
    IF pr_tpctrato = 4 AND (vr_permingr < 0.01 OR vr_permingr > 300) THEN
      
      vr_dscritic := 'Percentual minimo da cobertura da garantia de aplicacao inválido. Deve ser entre \"0.01\" e \"300\".' || to_char(vr_permingr);
      pr_nmdcampo := 'permingr';
        
      RAISE  vr_exc_saida;
      
    END IF;
    
    IF NOT NVL(pr_nrdevias,0) > 0 THEN
      
      vr_cdcritic := 26;
      pr_nmdcampo := 'nrdevias';
        
      RAISE  vr_exc_saida;
      
    END IF;
    
    IF pr_cdusolcr NOT IN (0,1,2) THEN
      
      vr_cdcritic := 269;
      pr_nmdcampo := 'cdusolcr';
        
      RAISE  vr_exc_saida;
      
    END IF;
    
    IF TRIM(pr_cdmodali) IS NULL THEN
      
      vr_cdcritic := 375;
      pr_nmdcampo := 'cdmodali';
        
      RAISE  vr_exc_saida;
      
    END IF;
    
    IF TRIM(pr_cdsubmod) IS NULL THEN
      
      vr_cdcritic := 375;
      pr_nmdcampo := 'cdsubmod';
        
      RAISE  vr_exc_saida;
      
    END IF;   

    -- Se for Pos-Fixado e Taxa Variavel nao for maior que zero
    IF pr_tpprodut = 2 AND NVL(pr_txjurvar,0) <= 0 THEN
      vr_cdcritic := 185;
      pr_nmdcampo := 'txjurvar';
      RAISE  vr_exc_saida;
    END IF;   
       
    IF vr_cdcooper <> 9       AND
       NVL(pr_txminima,0) = 0 THEN
      
      vr_cdcritic := 185;
      pr_nmdcampo := 'txminima';
        
      RAISE  vr_exc_saida;   
    
    END IF;
    
    IF NVL(pr_txmaxima,0) > 0                  AND
       NVL(pr_txminima,0) > NVL(pr_txmaxima,0) THEN
      
      vr_dscritic := 'Taxa minima deve ser menor que a taxa maxima.';
      pr_nmdcampo := 'txminima';
        
      RAISE  vr_exc_saida;   
    
    END IF;
    
    IF NOT nvl(pr_nrinipre,0) > 0 THEN
      
      vr_cdcritic := 380;
      pr_nmdcampo := 'nrinipre';
        
      RAISE  vr_exc_saida;
      
    END IF;
    
    IF NOT nvl(pr_nrfimpre,0) > 0    OR 
       NOT nvl(pr_nrfimpre,0) <= 240 THEN
      
      vr_cdcritic := 380;
      pr_nmdcampo := 'nrfimpre';
        
      RAISE  vr_exc_saida;
      
    END IF;
    
    IF NOT nvl(pr_qtdcasas,0) > 0 OR 
       NOT nvl(pr_qtdcasas,0) < 7 THEN
      
      vr_cdcritic := 380;
      pr_nmdcampo := 'qtdcasas';
        
      RAISE  vr_exc_saida;
      
    END IF;    
    
    -- Verifica se a taxa base pertence ao grupo informado 
    OPEN cr_craplcr_base(vr_cdcooper,pr_nrgrplcr);
    
    FETCH cr_craplcr_base into rw_craplcr_base;
      
    IF cr_craplcr_base%FOUND                          AND 
       vr_cdcooper <> 9                               AND 
       NVL(pr_txbaspre,0) <> rw_craplcr_base.txbaspre THEN 
      
      --Fecha o cursor
      CLOSE cr_craplcr_base;
        
      --Monta critica
      vr_cdcritic := 382;
      pr_nmdcampo := 'txbaspre';
      RAISE vr_exc_saida;
        
    ELSE
        
      --Fecha o cursor
      CLOSE cr_craplcr_base;
        
    END IF;

    IF vr_cdcooper <> 9       AND
       NVL(pr_txbaspre,0) = 0 THEN
      
      vr_cdcritic := 185;
      pr_nmdcampo := 'txbaspre';
        
      RAISE  vr_exc_saida;   
    
    END IF;
    
    vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'USUARI'
                                            ,pr_cdempres => 11
                                            ,pr_cdacesso => 'CALCPRESTA'
                                            ,pr_tpregist => pr_nrgrplcr);
    -- Se encontrou 
    IF vr_dstextab IS NOT NULL THEN
      
      vr_cdcritic := 570;
      pr_nmdcampo := 'nrgrplcr';
      RAISE vr_exc_saida;
        
    END IF;
    
    IF NVL(pr_nrinipre,0) > NVL(pr_nrfimpre,0) THEN
      
      vr_cdcritic := 380;
      pr_nmdcampo := 'nrinipre';
        
      RAISE  vr_exc_saida;   
    
    END IF;
    
    /* Permitir no maximo 99 parcelas para tipo de desconto 
      consignado em Folha de pagamento. Isto ocorre por   
      restricao de layout CNAB que permite no maximo 2 caracter 
      Sidnei - Precise IT */
    IF NVL(pr_tpdescto,0) = 2  AND
       NVL(pr_nrfimpre,0) > 99 THEN
      
      vr_dscritic := 'Permitido informar no maximo 99 parcelas p/ Linhas com Desconto em Folha.';
      pr_nmdcampo := 'nrfimpre';
        
      RAISE  vr_exc_saida;   
    
    END IF;
    
    pc_calcula_taxas(pr_cdcooper => vr_cdcooper --> Cooperativa
                    ,pr_alocatab => 1           --> 1 - Alocar tabela / 0 - Não alocar tabela
                    ,pr_txjurvar => pr_txjurvar --> Juro variável
                    ,pr_txjurfix => pr_txjurfix --> Juro fixo
                    ,pr_txminima => pr_txminima --> Taxa minima
                    ,pr_txmaxima => pr_txmaxima --> Taxa maxima
                    ,pr_txmensal => vr_txmensal --> Taxa mensal
                    ,pr_txdiaria => vr_txdiaria --> Taxa diaria
                    ,pr_cdcritic => vr_cdcritic --> Código da critica
                    ,pr_dscritic => vr_dscritic --> Descrição da critica
                    ,pr_des_erro => vr_des_erro);--> Erros do processo

    IF vr_des_erro <> 'OK'           OR 
       nvl(vr_cdcritic,0) <> 0       OR 
       trim(vr_dscritic) IS NOT NULL THEN      
         
      RAISE vr_exc_saida;
      
    END IF;                    
                             
    IF NVL(pr_flgcrcta,0) = 0 THEN
      
      OPEN cr_craphis(pr_cdcooper => vr_cdcooper
                     ,pr_cdhistor => pr_cdhistor);
                           
      FETCH cr_craphis INTO rw_craphis;
            
      -- Se não encontrar
      IF cr_craphis%NOTFOUND THEN
              
        -- Fecha o cursor
        CLOSE cr_craphis;
              
        -- Monta critica
        vr_cdcritic := 93;
        vr_dscritic := NULL;
        pr_nmdcampo := 'cdhistor';
              
        -- Gera exceção
        RAISE vr_exc_saida;              
              
      ELSE
        -- Fecha o cursor
        CLOSE cr_craphis;
              
      END IF;   
    
    END IF;         
    
    -- Limpar coeficientes
    BEGIN
      
      DELETE crapccp
       WHERE crapccp.cdcooper = vr_cdcooper
         AND crapccp.cdlcremp = pr_cdlcremp;
    
    EXCEPTION
      WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao tentar eliminar a crapccp - '||sqlerrm;
          RAISE vr_exc_saida; 
    
    END;
    
    --Criando tabela de coeficientes de prestacao
    FOR vr_qtpresta IN pr_nrinipre..pr_nrfimpre LOOP 
        
      IF pr_txbaspre = 0 THEN
           
        vr_incalpre := 1 / vr_qtpresta;
        
      ELSE
        
        vr_txbaspre := pr_txbaspre / 100;
        vr_incalcul := POWER((1 + vr_txbaspre),vr_qtpresta);
        vr_incalpre := POWER(((vr_incalcul - 1) / (vr_txbaspre * vr_incalcul)),- 1);
      
      END IF;
      
      vr_incalpre := ROUND(vr_incalpre,pr_qtdcasas);
      
      BEGIN
        
        INSERT INTO crapccp(crapccp.cdcooper
                           ,crapccp.cdlcremp
                           ,crapccp.nrparcel
                           ,crapccp.incalpre)
                     VALUES(vr_cdcooper
                           ,pr_cdlcremp
                           ,vr_qtpresta
                           ,vr_incalpre); 
        
      EXCEPTION
        WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao tentar incluir a crapccp - '||sqlerrm;
            RAISE vr_exc_saida; 
      
      END;
      
    END LOOP;
    
    BEGIN
      INSERT INTO craplcr(craplcr.cdlcremp
                         ,craplcr.tpctrato
                         ,craplcr.permingr
                         ,craplcr.flgsaldo
                         ,craplcr.flgstlcr
                         ,craplcr.cdcooper
                         ,craplcr.dslcremp
                         ,craplcr.nrgrplcr
                         ,craplcr.txmensal
                         ,craplcr.txdiaria
                         ,craplcr.txjurfix
                         ,craplcr.txjurvar
                         ,craplcr.txpresta
                         ,craplcr.qtdcasas
                         ,craplcr.nrinipre
                         ,craplcr.nrfimpre
                         ,craplcr.txbaspre
                         ,craplcr.qtcarenc
                         ,craplcr.vlmaxass
                         ,craplcr.vlmaxasj
                         ,craplcr.txminima
                         ,craplcr.txmaxima
                         ,craplcr.perjurmo
                         ,craplcr.tpdescto
                         ,craplcr.nrdevias
                         ,craplcr.cdusolcr
                         ,craplcr.flgtarif
                         ,craplcr.flgtaiof
                         ,craplcr.vltrfesp
                         ,craplcr.flgcrcta
                         ,craplcr.dsoperac
                         ,craplcr.dsorgrec
                         ,craplcr.nrdialiq
                         ,craplcr.flgimpde
                         ,craplcr.flglispr
                         ,craplcr.tplcremp
                         ,craplcr.cdmodali
                         ,craplcr.cdsubmod
                         ,craplcr.flgrefin
                         ,craplcr.flgreneg
                         ,craplcr.qtrecpro
                         ,craplcr.inconaut
                         ,craplcr.flgdisap
                         ,craplcr.flgcobmu
                         ,craplcr.flgsegpr
                         ,craplcr.cdhistor
                         ,craplcr.tpprodut
                         ,craplcr.cddindex)      
                   VALUES(pr_cdlcremp
                         ,pr_tpctrato
                         ,vr_permingr
                         ,0
                         ,1
                         ,vr_cdcooper
                         ,pr_dslcremp
                         ,pr_nrgrplcr
                         ,vr_txmensal
                         ,vr_txdiaria
                         ,pr_txjurfix
                         ,pr_txjurvar
                         ,pr_txpresta
                         ,pr_qtdcasas
                         ,pr_nrinipre
                         ,pr_nrfimpre
                         ,pr_txbaspre
                         ,pr_qtcarenc
                         ,pr_vlmaxass          
                         ,pr_vlmaxasj
                         ,pr_txminima
                         ,pr_txmaxima
                         ,pr_perjurmo
                         ,pr_tpdescto
                         ,pr_nrdevias
                         ,pr_cdusolcr
                         ,pr_flgtarif
                         ,pr_flgtaiof
                         ,pr_vltrfesp
                         ,pr_flgcrcta
                         ,pr_dsoperac
                         ,pr_dsorgrec
                         ,pr_manterpo
                         ,pr_flgimpde
                         ,pr_flglispr
                         ,pr_tplcremp
                         ,TRIM(to_char(pr_cdmodali,'99900'))
                         ,TRIM(to_char(pr_cdsubmod,'99900'))
                         ,pr_flgrefin
                         ,pr_flgreneg
                         ,pr_qtrecpro
                         ,decode(pr_consaut,1,0,1)
                         ,pr_flgdisap
                         ,pr_flgcobmu
                         ,pr_flgsegpr
                         ,pr_cdhistor
                         ,pr_tpprodut
                         ,pr_cddindex);
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao tentar incluir a craplcr - '||sqlerrm;
        RAISE vr_exc_saida;
    END;

    -- Quebrar valores da lista recebida como parametro
    IF TRIM(pr_cdfinali) IS NOT NULL THEN
      
      vr_split := gene0002.fn_quebra_string(pr_string  => pr_cdfinali
                                          , pr_delimit => '#');
      -- ler linhas
      FOR i IN vr_split.first..vr_split.last LOOP
                                                   
        OPEN cr_crapfin(pr_cdcooper => vr_cdcooper
                       ,pr_cdfinemp => vr_split(i));
                       
        FETCH cr_crapfin INTO rw_crapfin;
        
        IF cr_crapfin%NOTFOUND THEN
          
          CLOSE cr_crapfin;
          
          continue;
          
        ELSE
          
          CLOSE cr_crapfin;
        
          OPEN cr_craplch(pr_cdcooper => vr_cdcooper
                         ,pr_cdlcrhab => pr_cdlcremp
                         ,pr_cdfinemp => vr_split(i));
                         
          FETCH cr_craplch INTO rw_craplch;
          
          IF cr_craplch%NOTFOUND THEN
            
            CLOSE cr_craplch;
            
            OPEN cr_craplch2(pr_cdcooper => vr_cdcooper
                            ,pr_cdfinemp => vr_split(i));
                           
            FETCH cr_craplch2 INTO rw_craplch2;
            
            IF cr_craplch2%NOTFOUND THEN
              
              CLOSE cr_craplch2;
                     
              vr_nrseqlch := 0;
                  
            ELSE
              
              CLOSE cr_craplch2;
              
              vr_nrseqlch := rw_craplch2.nrseqlch;
              
            END IF;
            
            BEGIN 
              INSERT INTO craplch(craplch.cdcooper
                                 ,craplch.cdfinemp
                                 ,craplch.cdlcrhab
                                 ,craplch.nrseqlch)      
                           VALUES(vr_cdcooper
                                 ,vr_split(i)
                                 ,pr_cdlcremp
                                 ,(vr_nrseqlch + 1));
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao tentar incluir a craplch - '||sqlerrm;
                RAISE vr_exc_saida;
            END;
                      
          ELSE
            
            CLOSE cr_craplch;
            
          END IF;
        
        END IF;
        
      END LOOP;
                                                 
    END IF;                                                 
       
    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'lcredi.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                  'Incluiu a Linha de Credito ' || trim(to_char(pr_cdlcremp,'99990')) ||
                                                  ' - ' || pr_dslcremp || '.');
    
    pr_des_erro := 'OK';
          
    --Efetua commit das alterações
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
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
      pr_dscritic := 'Erro geral em TELA_LCREDI.pc_incluir_linha_credito: ' || SQLERRM;
      pr_des_erro := 'NOK';
      pr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;
      
  END pc_incluir_linha_credito;
  
  PROCEDURE pc_blq_lib_lcredi(pr_cdlcremp IN craplcr.cdlcremp%TYPE --> Código da linha de crédito
                             ,pr_cddopcao IN VARCHAR2              --> Código da opção
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS         --> Descrição do erro
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_blq_lib_lcredi                           
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Julho/2016                         Ultima atualizacao: 10/08/2016
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Realiza o bloqueio/liberação da linha de crédito
    
    Alterações : 10/08/2016 - Ajustado formato da informação a ser apresentada no log
						 	 (Andrei - RKAM).
    -------------------------------------------------------------------------------------------------------------*/                               
  
    CURSOR cr_craplcr(p_cdcooper in crapcop.cdcooper%TYPE 
                     ,p_cdlcremp in craplcr.cdlcremp%TYPE) IS
    SELECT c.cdlcremp
          ,c.dslcremp           
      FROM craplcr c
     WHERE c.cdcooper = p_cdcooper
       AND c.cdlcremp = p_cdlcremp;
    rw_craplcr    cr_craplcr%ROWTYPE;
  
  BEGIN
    
    GENE0001.pc_informa_acesso(pr_module => 'LCREDI' 
                              ,pr_action => null);
                                
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
                            
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF; 
    
    OPEN cr_craplcr(vr_cdcooper
                   ,pr_cdlcremp);
    
    FETCH cr_craplcr INTO rw_craplcr;
    
    IF cr_craplcr%NOTFOUND THEN 
      
      --Fecha o cursor
      CLOSE cr_craplcr;
      
      --Monta critica
      vr_cdcritic := 363;
      RAISE vr_exc_saida;
      
    ELSE
      
      --Fecha o cursor
      CLOSE cr_craplcr;
      
    END IF;

    BEGIN
      UPDATE craplcr c SET c.flgstlcr = decode(pr_cddopcao,'L',1,'B',0)
       WHERE c.cdcooper = vr_cdcooper
         AND c.cdlcremp = pr_cdlcremp;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao tentar atualizar a craplcr.';
        RAISE vr_exc_saida;
    END;

    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'lcredi.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                  (CASE pr_cddopcao
                                                     WHEN 'L' THEN
                                                       'Liberou '
                                                     ELSE
                                                       'Bloqueou '
                                                   END)
                                                  || 'a linha de credito ' || trim(to_char(rw_craplcr.cdlcremp,'99990')) || 
                                                  ' - ' || rw_craplcr.dslcremp ||'.');

    pr_des_erro := 'OK';
                                                  
    --Efetua commit das alterações        
    COMMIT;
        
  EXCEPTION
    WHEN vr_exc_saida THEN
      
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
      pr_dscritic := 'Erro geral em TELA_LCREDI.pc_blq_lib_lcredi: ' || SQLERRM;
      pr_des_erro := 'NOK';
      pr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;
      
  END pc_blq_lib_lcredi;
  
  PROCEDURE pc_excluir_lcredi(pr_cdlcremp IN craplcr.cdlcremp%TYPE --> Código da linha de crédito
                             ,pr_cddopcao IN VARCHAR2              --> Código da opção
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS         --> Descrição do erro
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_excluir_lcredi                           
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Julho/2016                         Ultima atualizacao: 10/08/2016
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Realiza a exclusão da linha de crédito
    
    Alterações : 10/08/2016 - Ajustado formato da informação a ser apresentada no log
						 	 (Andrei - RKAM).
    -------------------------------------------------------------------------------------------------------------*/                               
  
    CURSOR cr_craplcr(pr_cdcooper IN crapcop.cdcooper%TYPE 
                     ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
    SELECT craplcr.cdlcremp
          ,craplcr.dslcremp           
      FROM craplcr 
     WHERE craplcr.cdcooper = pr_cdcooper
       AND craplcr.cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;
       
    CURSOR cr_crapepr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
    SELECT 1
      FROM crapepr
     WHERE crapepr.cdcooper = pr_cdcooper
       AND crapepr.cdlcremp = pr_cdlcremp;
    rw_crapepr cr_crapepr%ROWTYPE;
    
  BEGIN
    
    GENE0001.pc_informa_acesso(pr_module => 'LCREDI' 
                              ,pr_action => null);
                                
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
                            
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF; 
    
    OPEN cr_craplcr(vr_cdcooper
                   ,pr_cdlcremp);
    
    FETCH cr_craplcr INTO rw_craplcr;
    
    IF cr_craplcr%NOTFOUND THEN 
      
      --Fecha o cursor
      CLOSE cr_craplcr;
      
      --Monta critica
      vr_cdcritic := 363;
      RAISE vr_exc_saida;
      
    ELSE
      
      --Fecha o cursor
      CLOSE cr_craplcr;
      
    END IF;
    
    OPEN cr_crapepr(vr_cdcooper
                   ,pr_cdlcremp);
    
    FETCH cr_crapepr INTO rw_crapepr;
    
    IF cr_crapepr%FOUND THEN 
      
      --Fecha o cursor
      CLOSE cr_crapepr;
      
      --Monta critica
      vr_cdcritic := 377;
      RAISE vr_exc_saida;
      
    ELSE
      
      --Fecha o cursor
      CLOSE cr_crapepr;
      
    END IF;
    
    /*  Zera os coeficientes de prestacao  */
    BEGIN 
      
      DELETE crapccp 
       WHERE crapccp.cdcooper = vr_cdcooper
         AND crapccp.cdlcremp = pr_cdlcremp;
          
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao tentar excluir a crapccp.';
        RAISE vr_exc_saida;
    END;    
    
    BEGIN 
      
      DELETE craplch 
       WHERE craplch.cdcooper = vr_cdcooper
         AND craplch.cdlcrhab = pr_cdlcremp;
          
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao tentar excluir a craplch.';
        RAISE vr_exc_saida;
    END;

    BEGIN
      
      DELETE craplcr 
       WHERE craplcr.cdcooper = vr_cdcooper
         AND craplcr.cdlcremp = pr_cdlcremp;
         
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao tentar excluir a craplcr.';
        RAISE vr_exc_saida;
    END;

    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'lcredi.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                  'Deletou a linha de credito ' ||  trim(to_char(rw_craplcr.cdlcremp,'99990')) || 
                                                  ' - ' || rw_craplcr.dslcremp ||'.');
     
    pr_des_erro := 'OK';
    
    --Efetua commit das alterações       
    COMMIT;
        
  EXCEPTION
    WHEN vr_exc_saida THEN
      
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
      pr_dscritic := 'Erro geral em TELA_LCREDI.pc_excluir_lcredi: ' || SQLERRM;
      pr_des_erro := 'NOK';
      pr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;
      
  END pc_excluir_lcredi;
  
  PROCEDURE pc_busca_modalidade(pr_nrregist IN INTEGER               -- Número de registros
                               ,pr_nriniseq IN INTEGER               -- Número sequencial 
                               ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                               ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_modalidade                           
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Julho/2016                         Ultima atualizacao: 29/03/2017
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca modalidades
    
    Alterações : 29/03/2017 - Alterado para exibir modalidade 13 - Outros creditos.
                              PRJ343 - Cessao de credito (Odirlei-AMcom)
    -------------------------------------------------------------------------------------------------------------*/                               
  
    CURSOR cr_gnmodal IS
    SELECT gnmodal.cdmodali
          ,gnmodal.dsmodali
      FROM gnmodal
     WHERE gnmodal.cdmodali IN ('02','04','14','13');          
                       
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := '';      
    vr_nrregist  INTEGER; 
    vr_qtregist  INTEGER := 0; 
    vr_contador  INTEGER := 0;  
        
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
  BEGIN
    
    vr_nrregist := pr_nrregist;
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'LCREDI'
                              ,pr_action => null); 
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
       
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
        
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><modalidades>');     
                           
    --Busca as propostas
    FOR rw_gnmodal IN cr_gnmodal LOOP
    
      --Incrementar contador
      vr_qtregist:= nvl(vr_qtregist,0) + 1;
              
      -- controles da paginacao 
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN

        --Proximo
        CONTINUE;  
                  
      END IF; 
              
      IF vr_nrregist >= 1 THEN   
        -- Carrega os dados           
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<modalidade>'||  
                                                       '  <cdmodali>' || rw_gnmodal.cdmodali ||'</cdmodali>'||                                                                                                      
                                                       '  <dsmodali>' || rw_gnmodal.dsmodali ||'</dsmodali>'||                                                       
                                                     '</modalidade>');
        
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1;
           
      END IF;         
          
      vr_contador := vr_contador + 1; 
    
    END LOOP;

    IF vr_nrregist = 0 THEN
      
      vr_cdcritic:= 0;
      vr_dscritic:= 'Nenhuma modalidade encontrada!';
      
      RAISE vr_exc_erro;
          
    END IF;
        
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</modalidades></Root>'
                           ,pr_fecha_xml      => TRUE);
     
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);
       
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);  
               
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml          --> XML que irá receber o novo atributo
                             ,pr_tag   => 'Root'             --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
                             
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite); 
    
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na TELA_LCREDI.pc_busca_modalidade --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_busca_modalidade;  

  PROCEDURE pc_busca_submodalidade(pr_cdmodali IN gnmodal.cdmodali%TYPE --Codigo da modalidade
                                  ,pr_cdsubmod IN gnsbmod.cdsubmod%TYPE --Codigo da submodalidade
                                  ,pr_nriniseq IN INTEGER               -- Número sequencial 
                                  ,pr_nrregist IN INTEGER               -- Número de registros
                                  ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_submodalidade                           
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Julho/2016                         Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca submodalidades
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                               
  
    CURSOR cr_gnsbmod(pr_cdmodali IN gnmodal.cdmodali%TYPE
                     ,pr_cdsubmod IN gnsbmod.cdsubmod%TYPE)IS
    SELECT gnsbmod.cdsubmod
          ,gnsbmod.dssubmod
      FROM gnsbmod
     WHERE gnsbmod.cdmodali = pr_cdmodali
       AND (pr_cdsubmod IS NULL OR gnsbmod.cdsubmod = pr_cdsubmod)
     ORDER BY gnsbmod.cdsubmod;          
                       
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := '';      
    vr_nrregist  INTEGER; 
    vr_qtregist  INTEGER := 0; 
    vr_contador  INTEGER := 0;  
        
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
  BEGIN
    
    vr_nrregist := pr_nrregist;
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'LCREDI'
                              ,pr_action => null); 
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
       
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
        
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><submodalidades>');     
                           
    --Busca as propostas
    FOR rw_gnsbmod IN cr_gnsbmod(pr_cdmodali => TRIM(TO_CHAR(pr_cdmodali,'00'))
                                ,pr_cdsubmod => TRIM(TO_CHAR(pr_cdsubmod,'00'))) LOOP
    
      --Incrementar contador
      vr_qtregist:= nvl(vr_qtregist,0) + 1;
              
      -- controles da paginacao 
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN

        --Proximo
        CONTINUE;  
                  
      END IF; 
              
      IF vr_nrregist >= 1 THEN   
        -- Carrega os dados           
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<submodalidade>'||  
                                                       '  <cdsubmod>' || rw_gnsbmod.cdsubmod ||'</cdsubmod>'||                                                                                                      
                                                       '  <dssubmod>' || rw_gnsbmod.dssubmod ||'</dssubmod>'||                                                       
                                                     '</submodalidade>');
        
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1;
           
      END IF;         
          
      vr_contador := vr_contador + 1; 
    
    END LOOP;

    IF vr_nrregist = 0 THEN
      
      vr_cdcritic:= 0;
      vr_dscritic:= 'Nenhuma submodalidade encontrada!';
      
      RAISE vr_exc_erro;
          
    END IF;
        
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</submodalidades></Root>'
                           ,pr_fecha_xml      => TRUE);
     
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);
       
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);  
               
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml          --> XML que irá receber o novo atributo
                             ,pr_tag   => 'submodalidades'    --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
                             
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite); 
    
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na TELA_LCREDI.pc_busca_submodalidade --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_busca_submodalidade;  

  
END TELA_LCREDI;
/
