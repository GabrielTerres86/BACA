CREATE OR REPLACE PACKAGE CECRED.TELA_SLIP IS

  -- Author  : T0031688
  -- Created : 02/11/2018 17:12:01
  -- Purpose : ROTINAS PARA A TELA SLIP

  PROCEDURE pc_valida_cta_contab(pr_tipvalida        IN VARCHAR2 DEFAULT NULL
                                ,pr_nrconta_contabil IN tbcontab_prm_cta_ctb_slip.nrconta_contabil%TYPE --> nr conta contabil   
                                ,pr_nrctadeb         IN tbcontab_slip_lancamento.nrctacrd%TYPE DEFAULT NULL --> nr conta contabil   
                                ,pr_nrctacrd         IN tbcontab_slip_lancamento.nrctadeb%TYPE DEFAULT NULL --> nr conta contabil                                   
                                ,pr_xmllog           IN VARCHAR2 --> xml com informações de log 
                                ,pr_cdcritic         OUT PLS_INTEGER --> código da crítica
                                ,pr_dscritic         OUT VARCHAR2 --> descrição da crítica
                                ,pr_retxml           IN OUT NOCOPY xmltype --> arquivo de retorno do xml
                                ,pr_nmdcampo         OUT VARCHAR2 --> nome do campo com erro
                                ,pr_des_erro         OUT VARCHAR2);

  PROCEDURE PC_INSERE_PARAM(PR_LSNRCONTA_CONTABIL     IN VARCHAR2 --> lista com nr. conta contabil separados por ";"
                           ,pr_lscdhistor             IN VARCHAR2 --> lista com os historicos ||
                           ,pr_lsid_rateio_gerencial  IN VARCHAR2 --> lista com rateio gerencial || 
                           ,pr_lsid_risco_operacional IN VARCHAR2 --> lista com risco operacional ||                           
                           ,pr_xmllog                 IN VARCHAR2 --> xml com informações de log ||
                           ,pr_cdcritic               OUT PLS_INTEGER --> código da crítica
                           ,pr_dscritic               OUT VARCHAR2 --> descrição da crítica
                           ,pr_retxml                 IN OUT NOCOPY xmltype --> arquivo de retorno do xml
                           ,pr_nmdcampo               OUT VARCHAR2 --> nome do campo com erro
                           ,pr_des_erro               OUT VARCHAR2);

  PROCEDURE PC_CONSULTA_PARAM(PR_NRCONTA_CONTABIL     IN TBCONTAB_PRM_CTA_CTB_SLIP.NRCONTA_CONTABIL%TYPE --> conta contabil
                             ,pr_cdhistor             IN tbcontab_prm_cta_ctb_slip.cdhistor%TYPE --> historico 
                             ,pr_id_rateio_gerencial  IN tbcontab_prm_cta_ctb_slip.idexige_rateio_gerencial%TYPE --> exige rateio s/n
                             ,pr_id_risco_operacional IN tbcontab_prm_cta_ctb_slip.idexige_risco_operacional%TYPE --> exige risco s/n
                             ,pr_xmllog               IN VARCHAR2 --> xml com informações de log ||
                             ,pr_cdcritic             OUT PLS_INTEGER --> código da crítica
                             ,pr_dscritic             OUT VARCHAR2 --> descrição da crítica
                             ,pr_retxml               IN OUT NOCOPY xmltype --> arquivo de retorno do xml
                             ,pr_nmdcampo             OUT VARCHAR2 --> nome do campo com erro
                             ,pr_des_erro             OUT VARCHAR2);

  PROCEDURE PC_INSERE_GERENCIAL(PR_CDCOOPER      IN CRAPASS.CDCOOPER%TYPE --> cdcooper gerencial
                               ,pr_lsidativo     IN VARCHAR2 --> lista id ativo ";"
                               ,pr_lscdgerencial IN VARCHAR2 --> lista com os gerenciais||                          
                               ,pr_xmllog        IN VARCHAR2 --> xml com informações de log ||
                               ,pr_cdcritic      OUT PLS_INTEGER --> código da crítica
                               ,pr_dscritic      OUT VARCHAR2 --> descrição da crítica
                               ,pr_retxml        IN OUT NOCOPY xmltype --> arquivo de retorno do xml
                               ,pr_nmdcampo      OUT VARCHAR2 --> nome do campo com erro
                               ,pr_des_erro      OUT VARCHAR2);

  PROCEDURE pc_busca_gerenciais(pr_cdcooper IN crapass.cdcooper%TYPE
                               ,pr_xmllog   IN VARCHAR2 --> xml com informações de log ||
                               ,pr_cdcritic OUT PLS_INTEGER --> código da crítica
                               ,pr_dscritic OUT VARCHAR2 --> descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype --> arquivo de retorno do xml
                               ,pr_nmdcampo OUT VARCHAR2 --> nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);

  PROCEDURE PC_INSERE_HISTORICOS(PR_LSCDHISTOR IN VARCHAR2 -->  lista historico
                                ,pr_lsnrctadeb IN VARCHAR2 --> lista  conta debito";"
                                ,pr_lsnrctacrd IN VARCHAR2 --> lista conta credito ||                          
                                ,pr_xmllog     IN VARCHAR2 --> xml com informações de log ||
                                ,pr_cdcritic   OUT PLS_INTEGER --> código da crítica
                                ,pr_dscritic   OUT VARCHAR2 --> descrição da crítica
                                ,pr_retxml     IN OUT NOCOPY xmltype --> arquivo de retorno do xml
                                ,pr_nmdcampo   OUT VARCHAR2 --> nome do campo com erro
                                ,pr_des_erro   OUT VARCHAR2);

  PROCEDURE PC_INSERE_RISCO(PR_CDRISCO_OPERACIONAL IN TBCONTAB_PRM_RISCO_SLIP.CDRISCO_OPERACIONAL%TYPE -->  cd risco operacional  
                           ,pr_dsrisco_operacional IN tbcontab_prm_risco_slip.cdrisco_operacional%TYPE --> descrição
                           ,pr_lsnrconta_contabil  IN VARCHAR2 -- lista com contas contabeis
                           ,pr_xmllog              IN VARCHAR2 --> xml com informações de log ||
                           ,pr_cdcritic            OUT PLS_INTEGER --> código da crítica
                           ,pr_dscritic            OUT VARCHAR2 --> descrição da crítica
                           ,pr_retxml              IN OUT NOCOPY xmltype --> arquivo de retorno do xml
                           ,pr_nmdcampo            OUT VARCHAR2 --> nome do campo com erro
                           ,pr_des_erro            OUT VARCHAR2);

  PROCEDURE PC_BUSCA_RISCOS(PR_XMLLOG   IN VARCHAR2 --> XML com informações de LOG ||
                           ,pr_cdcritic OUT PLS_INTEGER --> código da crítica
                           ,pr_dscritic OUT VARCHAR2 --> descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> arquivo de retorno do xml
                           ,pr_nmdcampo OUT VARCHAR2 --> nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);

  PROCEDURE PC_BUSCA_HISTORICOS(PR_XMLLOG   IN VARCHAR2 --> XML com informações de LOG ||
                               ,pr_cdcritic OUT PLS_INTEGER --> código da crítica
                               ,pr_dscritic OUT VARCHAR2 --> descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype --> arquivo de retorno do xml
                               ,pr_nmdcampo OUT VARCHAR2 --> nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_busca_hist_param(pr_cdhistor IN NUMBER
                               ,pr_xmllog   IN VARCHAR2 --> xml com informações de log ||
                               ,pr_cdcritic OUT PLS_INTEGER --> código da crítica
                               ,pr_dscritic OUT VARCHAR2 --> descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype --> arquivo de retorno do xml
                               ,pr_nmdcampo OUT VARCHAR2 --> nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_busca_lancamentos(pr_cdcooper IN crapass.cdcooper%TYPE
                                ,pr_nrregist IN NUMBER
                                ,pr_nriniseq IN NUMBER
                                ,pr_xmllog   IN VARCHAR2 --> xml com informações de log ||
                                ,pr_cdcritic OUT PLS_INTEGER --> código da crítica
                                ,pr_dscritic OUT VARCHAR2 --> descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> arquivo de retorno do xml
                                ,pr_nmdcampo OUT VARCHAR2 --> nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);

  PROCEDURE PC_INSERE_LANCAMENTO(PR_CDCOOPER              IN CRAPASS.CDCOOPER%TYPE -->  lista historico                            
                                ,pr_cdhistor              IN tbcontab_slip_lancamento.cdhistor%TYPE --> lista conta credito ||                 
                                ,pr_nrctadeb              IN tbcontab_slip_lancamento.nrctadeb%TYPE
                                ,pr_nrctacrd              IN tbcontab_slip_lancamento.nrctacrd%TYPE
                                ,pr_vllanmto              IN tbcontab_slip_lancamento.vllanmto%TYPE
                                ,pr_cdhistor_padrao       IN tbcontab_slip_lancamento.cdhistor_padrao%TYPE
                                ,pr_dslancamento          IN tbcontab_slip_lancamento.dslancamento%TYPE
                                ,pr_cdoperad              IN tbcontab_slip_lancamento.cdoperad%TYPE
                                ,pr_lscdgerencial         IN VARCHAR2
                                ,pr_lsvllanmto            IN VARCHAR2
                                ,pr_lscdrisco_operacional IN VARCHAR2
                                ,pr_xmllog                IN VARCHAR2 --> xml com informações de log ||
                                ,pr_cdcritic              OUT PLS_INTEGER --> código da crítica
                                ,pr_dscritic              OUT VARCHAR2 --> descrição da crítica
                                ,pr_retxml                IN OUT NOCOPY xmltype --> arquivo de retorno do xml
                                ,pr_nmdcampo              OUT VARCHAR2 --> nome do campo com erro
                                ,pr_des_erro              OUT VARCHAR2);

  PROCEDURE PC_ALTERA_LANCAMENTO(PR_CDCOOPER              IN CRAPASS.CDCOOPER%TYPE -->  coperativa                  
                                ,pr_nrseqlan              IN tbcontab_slip_lancamento.nrsequencia_slip%TYPE --> sequencia slip
                                ,pr_cdhistor              IN tbcontab_slip_lancamento.cdhistor%TYPE --> historico alios                 
                                ,pr_nrctadeb              IN tbcontab_slip_lancamento.nrctadeb%TYPE --> conta debito
                                ,pr_nrctacrd              IN tbcontab_slip_lancamento.nrctacrd%TYPE --> conta credito
                                ,pr_vllanmto              IN tbcontab_slip_lancamento.vllanmto%TYPE --> valor do lancamento
                                ,pr_cdhistor_padrao       IN tbcontab_slip_lancamento.cdhistor_padrao%TYPE --> hisotrico padrao
                                ,pr_dslancamento          IN tbcontab_slip_lancamento.dslancamento%TYPE --> descrição do lancamento
                                ,pr_cdoperad              IN tbcontab_slip_lancamento.cdoperad%TYPE --> operador que alterou o lancamento
                                ,pr_lscdgerencial         IN VARCHAR2 --> lista gerenciais
                                ,pr_lsvllanmto            IN VARCHAR2 --> valor lancamento
                                ,pr_lscdrisco_operacional IN VARCHAR2 --> lista risco operacional
                                ,pr_xmllog                IN VARCHAR2 --> xml com informações de log ||
                                ,pr_cdcritic              OUT PLS_INTEGER --> código da crítica
                                ,pr_dscritic              OUT VARCHAR2 --> descrição da crítica
                                ,pr_retxml                IN OUT NOCOPY xmltype --> arquivo de retorno do xml
                                ,pr_nmdcampo              OUT VARCHAR2 --> nome do campo com erro
                                ,pr_des_erro              OUT VARCHAR2);

  PROCEDURE pc_busca_gerenciais_lanc(pr_cdcooper IN crapass.cdcooper%TYPE
                                    ,pr_nrseqlan IN tbcontab_slip_rateio.nrsequencia_slip%TYPE --> sequencian do lancamento
                                    ,pr_xmllog   IN VARCHAR2 --> xml com informações de log ||
                                    ,pr_cdcritic OUT PLS_INTEGER --> código da crítica
                                    ,pr_dscritic OUT VARCHAR2 --> descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype --> arquivo de retorno do xml
                                    ,pr_nmdcampo OUT VARCHAR2 --> nome do campo com erro 
                                    ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_busca_riscos_lanc(pr_cdcooper IN crapass.cdcooper%TYPE
                                ,pr_nrseqlan IN tbcontab_slip_rateio.nrsequencia_slip%TYPE --> sequencian do lancamento
                                ,pr_xmllog   IN VARCHAR2 --> xml com informações de log ||
                                ,pr_cdcritic OUT PLS_INTEGER --> código da crítica
                                ,pr_dscritic OUT VARCHAR2 --> descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> arquivo de retorno do xml
                                ,pr_nmdcampo OUT VARCHAR2 --> nome do campo com erro 
                                ,pr_des_erro OUT VARCHAR2);

  PROCEDURE PC_EXCLUI_LANCAMENTO(PR_CDCOOPER IN CRAPASS.CDCOOPER%TYPE -->  lista historico                            
                                ,pr_nrseqlan IN tbcontab_slip_lancamento.nrsequencia_slip%TYPE --> sequencia slip
                                ,pr_xmllog   IN VARCHAR2 --> xml com informações de log ||
                                ,pr_cdcritic OUT PLS_INTEGER --> código da crítica
                                ,pr_dscritic OUT VARCHAR2 --> descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> arquivo de retorno do xml
                                ,pr_nmdcampo OUT VARCHAR2 --> nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);

  PROCEDURE PC_VALIDA_GERENCIAL(PR_CDCOOPER    IN CRAPASS.CDCOOPER%TYPE --> cooperativa
                               ,pr_cdgerencial IN tbcontab_prm_gerencial_slip.cdgerencial%TYPE
                               ,pr_xmllog      IN VARCHAR2 --> xml com informações de log 
                               ,pr_cdcritic    OUT PLS_INTEGER --> código da crítica
                               ,pr_dscritic    OUT VARCHAR2 --> descrição da crítica
                               ,pr_retxml      IN OUT NOCOPY xmltype --> arquivo de retorno do xml
                               ,pr_nmdcampo    OUT VARCHAR2 --> nome do campo com erro
                               ,pr_des_erro    OUT VARCHAR2);

  PROCEDURE pc_valida_risco(pr_cddrisco IN tbcontab_prm_risco_slip.cdrisco_operacional%TYPE
                           ,pr_nrctadeb IN tbcontab_prm_cta_ctb_slip.nrconta_contabil%TYPE
                           ,pr_nrctacrd IN tbcontab_prm_cta_ctb_slip.nrconta_contabil%TYPE
                           ,pr_xmllog   IN VARCHAR2 --> xml com informações de log 
                           ,pr_cdcritic OUT PLS_INTEGER --> código da crítica
                           ,pr_dscritic OUT VARCHAR2 --> descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> arquivo de retorno do xml
                           ,pr_nmdcampo OUT VARCHAR2 --> nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_consulta_lancamentos(pr_cdcooper        IN crapass.cdcooper%TYPE
                                   ,pr_dtmvtolt        IN VARCHAR2
                                   ,pr_cdhistor        IN tbcontab_slip_lancamento.cdhistor%TYPE
                                   ,pr_nrctadeb        IN tbcontab_slip_lancamento.nrctadeb%TYPE
                                   ,pr_nrctacrd        IN tbcontab_slip_lancamento.nrctacrd%TYPE
                                   ,pr_vllanmto        IN tbcontab_slip_lancamento.vllanmto%TYPE
                                   ,pr_cdhistor_padrao IN tbcontab_slip_lancamento.cdhistor_padrao%TYPE
                                   ,pr_dslancamento    IN tbcontab_slip_lancamento.dslancamento%TYPE
                                   ,pr_cdoperad        IN tbcontab_slip_lancamento.cdoperad%TYPE
                                   ,pr_nrregist        IN NUMBER
                                   ,pr_nriniseq        IN NUMBER
                                   ,pr_opevlrlan       IN VARCHAR2
                                   ,pr_xmllog          IN VARCHAR2 --> xml com informações de log ||
                                   ,pr_cdcritic        OUT PLS_INTEGER --> código da crítica
                                   ,pr_dscritic        OUT VARCHAR2 --> descrição da crítica
                                   ,pr_retxml          IN OUT NOCOPY xmltype --> arquivo de retorno do xml
                                   ,pr_nmdcampo        OUT VARCHAR2 --> nome do campo com erro
                                   ,pr_des_erro        OUT VARCHAR2);

  PROCEDURE pc_busca_conta_contabil(pr_cdrisco_operacional IN tbcontab_prm_risco_slip.cdrisco_operacional%TYPE
                                   ,pr_xmllog              IN VARCHAR2 --> xml com informações de log ||
                                   ,pr_cdcritic            OUT PLS_INTEGER --> código da crítica
                                   ,pr_dscritic            OUT VARCHAR2 --> descrição da crítica
                                   ,pr_retxml              IN OUT NOCOPY xmltype --> arquivo de retorno do xml
                                   ,pr_nmdcampo            OUT VARCHAR2 --> nome do campo com erro
                                   ,pr_des_erro            OUT VARCHAR2);

  PROCEDURE PC_ALTERA_RISCO(PR_CDRISCO_OPERACIONAL IN TBCONTAB_PRM_RISCO_SLIP.CDRISCO_OPERACIONAL%TYPE -->  cd risco operacional  
                           ,pr_dsrisco_operacional IN tbcontab_prm_risco_slip.cdrisco_operacional%TYPE --> descrição
                           ,pr_lsnrconta_contabil  IN VARCHAR2 -- lista com contas contabeis
                           ,pr_xmllog              IN VARCHAR2 --> xml com informações de log ||
                           ,pr_cdcritic            OUT PLS_INTEGER --> código da crítica
                           ,pr_dscritic            OUT VARCHAR2 --> descrição da crítica
                           ,pr_retxml              IN OUT NOCOPY xmltype --> arquivo de retorno do xml
                           ,pr_nmdcampo            OUT VARCHAR2 --> nome do campo com erro
                           ,pr_des_erro            OUT VARCHAR2);

END TELA_SLIP;
/
create or replace package body cecred.TELA_SLIP IS



  -- Function and procedure implementations
  PROCEDURE pc_valida_cta_contab(pr_tipvalida IN VARCHAR2 DEFAULT NULL
                                ,pr_nrconta_contabil IN tbcontab_prm_cta_ctb_slip.nrconta_contabil%TYPE --> nr conta contabil   
                                ,pr_nrctadeb IN tbcontab_slip_lancamento.nrctacrd%TYPE DEFAULT NULL --> nr conta contabil   
                                ,pr_nrctacrd IN tbcontab_slip_lancamento.nrctadeb%TYPE DEFAULT NULL --> nr conta contabil                                   
                                ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG 
                                ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS
                                 
     -- cursor para buscar conta contabil;
     CURSOR cr_conta_contab IS
      SELECT 1 FROM tbcontab_prm_cta_ctb_slip 
       WHERE nrconta_contabil = pr_nrconta_contabil;
     
     CURSOR cr_conta_contab1 (pr_nrctadeb IN tbcontab_slip_lancamento.nrctadeb%TYPE,
                              pr_nrctacrd IN tbcontab_slip_lancamento.nrctacrd%TYPE) IS 
     SELECT cta.nrconta_contabil,
            cta.idexige_rateio_gerencial  AS idger, 
            cta.idexige_risco_operacional AS idris FROM tbcontab_prm_cta_ctb_slip cta
       WHERE (cta.nrconta_contabil = pr_nrctadeb OR
              cta.nrconta_contabil = pr_nrctacrd);     
     rw_conta_contab1  cr_conta_contab1%ROWTYPE;
                            
     vr_flgexiste PLS_INTEGER;
     vr_cdcritic crapcri.cdcritic%TYPE := NULL ; --> Cód. Erro
     vr_dscritic VARCHAR2(1000) := NULL;        --> Desc. Erro
     vr_dsconta_contabil VARCHAR2(10) := NULL;
     
     -- Tratamento de erros
     vr_exc_erro EXCEPTION;      
       
  BEGIN
     pr_des_erro := 'OK';
         
     OPEN cr_conta_contab;
      FETCH cr_conta_contab INTO vr_flgexiste;
     CLOSE cr_conta_contab;
     
     IF pr_tipvalida = 'R' THEN -- parametrizacao Risco  
       IF nvl(vr_flgexiste,0) = 0 THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Conta Contabil nao esta parametrizada.';
          RAISE vr_exc_erro;
       END IF;
     END IF;
          
     IF pr_tipvalida IS NULL THEN  
        IF vr_flgexiste = 1 THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Conta contabil ja cadastrada.';
          RAISE vr_exc_erro;
        END IF;
     END IF;
     
     IF pr_tipvalida = 'LG' THEN -- validar lancamento rateio gerencial         
        FOR rw_conta_contab1 IN cr_conta_contab1(pr_nrctadeb => pr_nrctadeb,
                                                 pr_nrctacrd => pr_nrctacrd) LOOP
          
          -- validar conta debito se exige gerencial
          IF (nvl(rw_conta_contab1.idger,' ') = 'S') THEN 
             vr_cdcritic := NULL;
             vr_dscritic := NULL;
             EXIT;            
          ELSE
            IF vr_dsconta_contabil IS NULL THEN 
              vr_dsconta_contabil := nvl(rw_conta_contab1.nrconta_contabil,'');
            ELSE 
              vr_dsconta_contabil := vr_dsconta_contabil || ', '|| nvl(rw_conta_contab1.nrconta_contabil,'');
            END IF;
            
            vr_cdcritic := 0;
            vr_dscritic := 'Conta contabil ' || nvl(vr_dsconta_contabil,'') || ' nao exige rateio gerencial.';            
          END IF;                                                     
        END LOOP; 
        
        IF vr_dscritic IS NOT NULL THEN           
          RAISE vr_exc_erro; 
        END IF;
        
      END IF;
        
            
      IF pr_tipvalida = 'LR' THEN -- validar lancamento risco
        FOR rw_conta_contab1 IN cr_conta_contab1(pr_nrctadeb => pr_nrctadeb,
                                                 pr_nrctacrd => pr_nrctacrd) LOOP
            
          -- validar conta debito se exige gerencial
          IF (nvl(rw_conta_contab1.idris,' ') = 'S') THEN 
             vr_cdcritic := NULL;
             vr_dscritic := NULL;
             EXIT;            
          ELSE
            
            IF vr_dsconta_contabil IS NULL THEN 
              vr_dsconta_contabil := nvl(rw_conta_contab1.nrconta_contabil,'');
            ELSE 
              vr_dsconta_contabil := vr_dsconta_contabil || ', '|| nvl(rw_conta_contab1.nrconta_contabil,'');
            END IF;
            
            vr_cdcritic := 0;
            vr_dscritic := 'Conta contabil ' ||vr_dsconta_contabil || ' nao exige risco operacional.';
           
          END IF;                                                         
        END LOOP;
         
        IF vr_dscritic IS NOT NULL THEN           
          RAISE vr_exc_erro; 
        END IF;
      END IF;           
                                      
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                                           
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na rotina que valida conta contabil.' || SQLERRM ;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');      
  end pc_valida_cta_contab;
  
 -- validar lancamento na inclusao ou alteração
  PROCEDURE pc_valida_lancamento(pr_nrctadeb IN tbcontab_slip_lancamento.nrctadeb%TYPE --> nr conta contabil   
                                ,pr_nrctacrd IN tbcontab_slip_lancamento.nrctacrd%TYPE --> nr conta contabil    
                                ,pr_lscdgerencial IN VARCHAR2        
                                ,pr_lscdrisco_operacional IN VARCHAR2                 
                                ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                ) IS
                                 
     -- cursor para buscar conta contabil;
    CURSOR cr_conta_contab (pr_conta_contabil IN tbcontab_prm_cta_ctb_slip.nrconta_contabil%TYPE) IS 
     SELECT cta.nrconta_contabil,
            cta.idexige_rateio_gerencial  AS idger, 
            cta.idexige_risco_operacional AS idris FROM tbcontab_prm_cta_ctb_slip cta
       WHERE cta.nrconta_contabil = pr_conta_contabil;     
     rw_conta_contab  cr_conta_contab%ROWTYPE;
                                
     vr_cdcritic crapcri.cdcritic%TYPE := NULL ; --> Cód. Erro
     vr_dscritic VARCHAR2(1000) := NULL;        --> Desc. Erro
     
     -- Tratamento de erros
     vr_exc_erro EXCEPTION;      
       
  BEGIN
     pr_dscritic := NULL;
     pr_cdcritic := NULL;
     
     OPEN cr_conta_contab(pr_nrctadeb);
      FETCH cr_conta_contab INTO rw_conta_contab;
     CLOSE cr_conta_contab;
               
     IF (rw_conta_contab.idger = 'S') AND (nvl(pr_lscdgerencial,' ') = ' ') THEN  
        
        vr_cdcritic := 0;
        vr_dscritic := 'Conta contabil: ' || pr_nrctadeb || ' exige rateio gerencial. Favor informar para concluir o lancamento.' ;
        RAISE vr_exc_erro;
               
     END IF;
     
     OPEN cr_conta_contab(pr_nrctacrd);
      FETCH cr_conta_contab INTO rw_conta_contab;
     CLOSE cr_conta_contab;
               
     IF (rw_conta_contab.idger = 'S') AND (nvl(pr_lscdgerencial,' ') = ' ') THEN  
        
        vr_cdcritic := 0;
        vr_dscritic := 'Conta contabil: ' || pr_nrctacrd || ' exige rateio gerencial. Favor informar para concluir o lancamento.' ;
        RAISE vr_exc_erro;
               
     END IF;
     
     OPEN cr_conta_contab(pr_nrctadeb);
      FETCH cr_conta_contab INTO rw_conta_contab;
     CLOSE cr_conta_contab;
               
     IF (rw_conta_contab.idris = 'S') AND (nvl(pr_lscdrisco_operacional,' ') = ' ') THEN  
        
        vr_cdcritic := 0;
        vr_dscritic := 'Conta contabil: ' || pr_nrctadeb || ' exige risco operacional. Favor informar para finalizar o lancamento.' ;
        RAISE vr_exc_erro;
               
     END IF;
     
     OPEN cr_conta_contab(pr_nrctacrd);
      FETCH cr_conta_contab INTO rw_conta_contab;
     CLOSE cr_conta_contab;
               
     IF (rw_conta_contab.idris = 'S') AND (nvl(pr_lscdrisco_operacional,' ') = ' ') THEN  
        
        vr_cdcritic := 0;
        vr_dscritic := 'Conta contabil: ' || pr_nrctacrd ||  ' exige risco operacional. Favor informar para finalizar o lancamento.' ;
        RAISE vr_exc_erro;
               
     END IF;
                        
                                  
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
                                                      
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na rotina que valida conta contabil.' || SQLERRM ;
      
       
  end pc_valida_lancamento;
                
 PROCEDURE pc_valida_gerencial(pr_cdcooper  IN crapass.cdcooper%TYPE --> cooperativa
                             ,pr_cdgerencial IN  tbcontab_prm_gerencial_slip.cdgerencial%TYPE
                             ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG 
                             ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS
                                 
     -- cursor para buscar conta contabil;
     CURSOR cr_gerencial IS
      SELECT tgs.idativo FROM tbcontab_prm_gerencial_slip tgs
       WHERE tgs.cdcooper =  pr_cdcooper
        AND  tgs.cdgerencial = pr_cdgerencial;       
     
     vr_flgexiste VARCHAR2(1);
     vr_cdcritic crapcri.cdcritic%TYPE := NULL ; --> Cód. Erro
     vr_dscritic VARCHAR2(1000) := NULL;        --> Desc. Erro
     
     -- Tratamento de erros
     vr_exc_erro EXCEPTION;      
       
  BEGIN
     pr_des_erro := 'OK';
         
     OPEN cr_gerencial;
      FETCH cr_gerencial INTO vr_flgexiste;
     CLOSE cr_gerencial;
     
     IF vr_flgexiste IS NULL THEN
            vr_cdcritic := 0;
       vr_dscritic := 'Gerencial nao parametrizado para esta cooperativa.';
       RAISE vr_exc_erro;
     END IF;
       
     IF nvl(vr_flgexiste,'N') = 'N' THEN
       vr_cdcritic := 0;
       vr_dscritic := 'Gerencial esta inativo.';
       RAISE vr_exc_erro;
     END IF;
      
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                                           
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na rotina que valida conta contabil.' || SQLERRM ;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');      
  end pc_valida_gerencial;
  
PROCEDURE pc_valida_risco(pr_cddrisco IN  tbcontab_prm_risco_slip.cdrisco_operacional%TYPE
                         ,pr_nrctadeb IN tbcontab_prm_cta_ctb_slip.nrconta_contabil%TYPE
                         ,pr_nrctacrd IN tbcontab_prm_cta_ctb_slip.nrconta_contabil%TYPE                         
                         ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG 
                         ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                         ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                         ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2) IS
                                 
     -- cursor para buscar conta contabil;
     CURSOR cr_risco IS
      SELECT 1 FROM tbcontab_prm_risco_slip trs
       WHERE trs.cdrisco_operacional = pr_cddrisco;
           
     CURSOR cr_conta_contabil IS 
       SELECT 1 FROM tbcontab_prm_risco_cta_slip cta
        WHERE cta.cdrisco_operacional = pr_cddrisco
        AND (cta.nrconta_contabil = pr_nrctadeb OR
             cta.nrconta_contabil = pr_nrctacrd);
     
     vr_flgexiste PLS_INTEGER;
     vr_cdcritic crapcri.cdcritic%TYPE := NULL ; --> Cód. Erro
     vr_dscritic VARCHAR2(1000) := NULL;        --> Desc. Erro
     
     -- Tratamento de erros
     vr_exc_erro EXCEPTION;      
       
  BEGIN
     pr_des_erro := 'OK';
     
     OPEN cr_conta_contabil;
      FETCH cr_conta_contabil INTO vr_flgexiste;
     CLOSE cr_conta_contabil;
     
     IF vr_flgexiste IS NULL THEN
       vr_cdcritic := 0;
       vr_dscritic := 'Risco operacional nao parametrizado para as contas contabeis informadas.' ||
                      'Contas: ' || pr_nrctadeb || '(D) e '||pr_nrctacrd ||'(C)' ;
       RAISE vr_exc_erro;
     END IF;
       
         
     OPEN cr_risco;
      FETCH cr_risco INTO vr_flgexiste;
     CLOSE cr_risco;
     
     IF vr_flgexiste IS NULL THEN
       vr_cdcritic := 0;
       vr_dscritic := 'Risco operacional nao parametrizado para esta cooperativa.';
       RAISE vr_exc_erro;
     END IF;
       
   
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                                           
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na rotina que valida risco operacional.' || SQLERRM ;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');      
  end pc_valida_risco;
      
  
  PROCEDURE pc_insere_param(pr_lsnrconta_contabil IN VARCHAR2  --> lista com nr. conta contabil separados por ";"
                           ,pr_lscdhistor IN VARCHAR2          --> lista com os historicos ||
                           ,pr_lsid_rateio_gerencial IN VARCHAR2 --> lista com rateio gerencial || 
                           ,pr_lsid_risco_operacional IN VARCHAR2 --> lista com risco operacional ||                           
                           ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG ||
                           ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS
                           
   vr_cdcritic crapcri.cdcritic%TYPE := NULL ; --> Cód. Erro
   vr_dscritic VARCHAR2(1000) := NULL;        --> Desc. Erro
   vr_tab_lsnrconta_contabil gene0002.typ_split;
   vr_tab_lsid_rateio_gerencial gene0002.typ_split;     
   vr_tab_lsid_risco_operacional gene0002.typ_split;     
   vr_tab_lscdhistor gene0002.typ_split;     

   -- Tratamento de erros
   vr_exc_erro EXCEPTION;      
                                
  BEGIN
    pr_des_erro := 'OK';
    
    vr_tab_lsnrconta_contabil := gene0002.fn_quebra_string(pr_lsnrconta_contabil,';');
    vr_tab_lsid_rateio_gerencial := gene0002.fn_quebra_string(pr_lsid_rateio_gerencial,';');    
    vr_tab_lsid_risco_operacional := gene0002.fn_quebra_string(pr_lsid_risco_operacional,';');    
    vr_tab_lscdhistor := gene0002.fn_quebra_string(pr_lscdhistor,';'); 
    
    IF vr_tab_lsnrconta_contabil.count() > 0 THEN
      FOR idx IN vr_tab_lsnrconta_contabil.first..vr_tab_lsnrconta_contabil.last LOOP
        BEGIN
              
          IF (vr_tab_lsnrconta_contabil(idx) IS NOT NULL AND 
              vr_tab_lsid_rateio_gerencial(idx) IS NOT NULL AND
              vr_tab_lsid_risco_operacional(idx) IS NOT NULL AND 
              vr_tab_lscdhistor(idx) IS NOT NULL) THEN

            UPDATE tbcontab_prm_cta_ctb_slip t
               SET t.idexige_rateio_gerencial = vr_tab_lsid_rateio_gerencial(idx)
                 , t.idexige_risco_operacional = vr_tab_lsid_risco_operacional(idx)
                 , t.cdhistor = vr_tab_lscdhistor(idx)
             WHERE t.nrconta_contabil = vr_tab_lsnrconta_contabil(idx);

            IF SQL%ROWCOUNT = 0 THEN
              INSERT INTO tbcontab_prm_cta_ctb_slip 
                (nrconta_contabil,
                 idexige_rateio_gerencial,
                 idexige_risco_operacional,
                 cdhistor)
              VALUES 
                (vr_tab_lsnrconta_contabil(idx),
                 vr_tab_lsid_rateio_gerencial(idx),
                 vr_tab_lsid_risco_operacional(idx),
                 vr_tab_lscdhistor(idx));
            END IF;
          END IF;  
        EXCEPTION
          WHEN OTHERS THEN 
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao inserir parametro. ' || Sqlerrm;             
            RAISE vr_exc_erro;
        END;
      END LOOP;

      COMMIT;
    END IF;
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na rotina que insere parametro.' || SQLERRM ;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_insere_param;
  
 PROCEDURE pc_consulta_param (pr_nrconta_contabil IN tbcontab_prm_cta_ctb_slip.nrconta_contabil%TYPE  --> conta contabil
                            ,pr_cdhistor IN tbcontab_prm_cta_ctb_slip.cdhistor%TYPE          --> historico 
                            ,pr_id_rateio_gerencial IN tbcontab_prm_cta_ctb_slip.idexige_rateio_gerencial%TYPE --> exige rateio S/N
                            ,pr_id_risco_operacional IN tbcontab_prm_cta_ctb_slip.idexige_risco_operacional%TYPE --> exige risco S/N
                            ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG ||
                            ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS
  
  CURSOR cr_prm_slip (pr_nrconta_contabil IN tbcontab_prm_cta_ctb_slip.nrconta_contabil%TYPE,
                      pr_cdhistor IN tbcontab_prm_cta_ctb_slip.cdhistor%TYPE,
                      pr_id_rateio_gerencial IN tbcontab_prm_cta_ctb_slip.idexige_rateio_gerencial%TYPE,
                      pr_id_risco_operacional IN tbcontab_prm_cta_ctb_slip.idexige_risco_operacional%TYPE
                      ) IS                         
  SELECT prm.nrconta_contabil,
         prm.cdhistor,
         prm.idexige_rateio_gerencial,
         prm.idexige_risco_operacional
  FROM tbcontab_prm_cta_ctb_slip prm
   WHERE prm.nrconta_contabil = NVL(pr_nrconta_contabil,prm.nrconta_contabil)
    AND  prm.cdhistor = NVL(pr_cdhistor,prm.cdhistor)
    AND  prm.idexige_rateio_gerencial = NVL(pr_id_rateio_gerencial,prm.idexige_rateio_gerencial)
    AND  prm.idexige_risco_operacional = NVL(pr_id_risco_operacional,prm.idexige_risco_operacional);
    
  
   vr_cdcritic crapcri.cdcritic%TYPE := NULL ; --> Cód. Erro
   vr_dscritic VARCHAR2(1000) := NULL;        --> Desc. Erro

   -- Tratamento de erros
   vr_exc_erro EXCEPTION;      
   
   --> variaveis auxiliares 
   vr_des_xml         CLOB;  
   vr_texto_completo  VARCHAR2(32600); 
   vr_flgexist        BOOLEAN;
      
      
   -- Subrotina para escrever texto na variável CLOB do XML
   procedure pc_escreve_xml(pr_des_dados in varchar2,
                            pr_fecha_xml in boolean default false) is
   begin
     gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
   end;
                                   
  BEGIN
    pr_des_erro := 'OK';
    
    
    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
    vr_texto_completo := null;        
        
      -- Criar cabeçalho do XML
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                     '<Dados>');
                     
    FOR rw_prm_slip IN cr_prm_slip(pr_nrconta_contabil => pr_nrconta_contabil,
                                   pr_cdhistor         => pr_cdhistor,
                                   pr_id_rateio_gerencial => pr_id_rateio_gerencial,
                                   pr_id_risco_operacional => pr_id_risco_operacional) LOOP
               
        BEGIN
            pc_escreve_xml( '<parametros>
                             <nrconta_contabil>'|| rw_prm_slip.nrconta_contabil ||'</nrconta_contabil>'||
                            '<cdhistor>'|| rw_prm_slip.cdhistor ||'</cdhistor>'||
                            '<id_rateio_gerencial>'|| rw_prm_slip.idexige_rateio_gerencial ||'</id_rateio_gerencial>'||
                            '<id_risco_operacional>'|| rw_prm_slip.idexige_risco_operacional ||'</id_risco_operacional>'||                            
                            '</parametros>');   
       EXCEPTION
         WHEN OTHERS THEN
           vr_dscritic := 'Erro ao montar tabela de parametros: '||SQLERRM;
           RAISE vr_exc_erro;               
       END;  
          
              
    END LOOP;
    
    pc_escreve_xml('</Dados>',TRUE);
    pr_retxml := xmltype.createxml(vr_des_xml);        
      
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
                           
                     
                         
               
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na rotina que insere parametro.' || SQLERRM ;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_consulta_param;

PROCEDURE pc_insere_gerencial(pr_cdcooper IN crapass.cdcooper%TYPE
                             ,pr_lsidativo IN VARCHAR2  --> lista com nr. conta contabil separados por ";"
                             ,pr_lscdgerencial IN VARCHAR2          --> lista com os historicos ||                          
                             ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG ||
                             ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS
                           
   vr_cdcritic crapcri.cdcritic%TYPE := NULL ; --> Cód. Erro
   vr_dscritic VARCHAR2(1000) := NULL;   --> Desc. Erro

   vr_tab_lsidativo  gene0002.typ_split;  
   vr_tab_lscdgerencial  gene0002.typ_split;


   -- Tratamento de erros
   vr_exc_erro EXCEPTION;      
                                
  BEGIN
    pr_des_erro := 'OK';
    
    vr_tab_lsidativo := gene0002.fn_quebra_string(pr_lsidativo,';');
    vr_tab_lscdgerencial := gene0002.fn_quebra_string(pr_lscdgerencial,';');    
    
    IF vr_tab_lscdgerencial.count() > 0 THEN
     
     FOR idx IN vr_tab_lscdgerencial.first..vr_tab_lscdgerencial.last LOOP
          BEGIN
              
             IF (vr_tab_lsidativo(idx) IS NOT NULL AND 
                vr_tab_lscdgerencial(idx) IS NOT NULL)
             THEN
              
              -- primeiro atualizae
              UPDATE tbcontab_prm_gerencial_slip ger 
                SET ger.idativo = vr_tab_lsidativo(idx)
              WHERE ger.cdcooper = pr_cdcooper
                AND ger.cdgerencial = vr_tab_lscdgerencial(idx);
              
              -- se não existe então criar
              IF SQL%ROWCOUNT = 0 THEN                                               
                -- iserir gerencial
                INSERT INTO tbcontab_prm_gerencial_slip 
                (cdcooper,
                 cdgerencial,
                 idativo)
                VALUES 
                (pr_cdcooper,
                 vr_tab_lscdgerencial(idx),
                 vr_tab_lsidativo(idx));
                                  
               END IF;               
             
             END IF;  
              
          EXCEPTION
            WHEN OTHERS THEN 
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao inserir gerencial. ' || Sqlerrm;             
              RAISE vr_exc_erro;
          END;
      END LOOP;
      
      COMMIT;
      
    END IF;
            
  EXCEPTION 
    WHEN vr_exc_erro THEN
      ROLLBACK;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      ROLLBACK;
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na rotina que insere parametro.' || SQLERRM ;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_insere_gerencial;

-- PROCEDURE pc_insere_historicos()

PROCEDURE pc_insere_historicos(pr_lscdhistor IN VARCHAR2         -->  lista historico
                              ,pr_lsnrctadeb IN VARCHAR2         --> lista  conta debito";"
                              ,pr_lsnrctacrd IN VARCHAR2         --> lista conta credito ||                          
                              ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG ||
                              ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS
                           
   vr_cdcritic crapcri.cdcritic%TYPE := NULL ; --> Cód. Erro
   vr_dscritic VARCHAR2(1000) := NULL;   --> Desc. Erro

   vr_tab_lscdhistor  gene0002.typ_split;  
   vr_tab_lsnrctadeb  gene0002.typ_split;
   vr_tab_lsnrctacrd  gene0002.typ_split;   


   -- Tratamento de erros
   vr_exc_erro EXCEPTION;      
                                
  BEGIN
    pr_des_erro := 'OK';
    
    vr_tab_lscdhistor := gene0002.fn_quebra_string(pr_lscdhistor,';');
    vr_tab_lsnrctadeb := gene0002.fn_quebra_string(pr_lsnrctadeb,';');    
    vr_tab_lsnrctacrd := gene0002.fn_quebra_string(pr_lsnrctacrd,';');     
    
    
    IF vr_tab_lscdhistor.count() > 0 THEN

     --deletar todos os parametros e inserir novamente
     DELETE FROM tbcontab_prm_his_slip;

     FOR idx IN vr_tab_lscdhistor.first..vr_tab_lscdhistor.last LOOP
          BEGIN
              
             IF vr_tab_lscdhistor(idx) IS NOT NULL 
             THEN
              
             /* -- primeiro atualizae
              UPDATE tbcontab_prm_his_slip his
                SET his.nrctadeb = vr_tab_lsnrctadeb(idx),
                    his.nrctacrd = vr_tab_lsnrctacrd(idx)                
              WHERE his.cdhistor = vr_tab_lscdhistor(idx);*/
              
              -- se não existe então criar
                                           
                -- iserir gerencial
                INSERT INTO tbcontab_prm_his_slip 
                (cdcooper,
                 cdhistor,
                 nrctadeb,
                 nrctacrd)
                VALUES 
                (3, -- fixo para coop 3
                 vr_tab_lscdhistor(idx),
                 vr_tab_lsnrctadeb(idx),
                 vr_tab_lsnrctacrd(idx));
                                           
             
             END IF;  
              
          EXCEPTION
            WHEN OTHERS THEN 
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao inserir historicos. ' || Sqlerrm;             
              RAISE vr_exc_erro;
          END;
      END LOOP;
      
      COMMIT;
      
    END IF;
            
  EXCEPTION 
    WHEN vr_exc_erro THEN
      ROLLBACK;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      ROLLBACK;
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na rotina que insere parametro.' || SQLERRM ;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_insere_historicos;
  


 PROCEDURE pc_insere_lancamento(pr_cdcooper  IN crapass.cdcooper%TYPE         -->  lista historico                            
                               ,pr_cdhistor  IN tbcontab_slip_lancamento.cdhistor%TYPE         --> lista conta credito ||                 
                               ,pr_nrctadeb  IN tbcontab_slip_lancamento.nrctadeb%TYPE
                               ,pr_nrctacrd  IN tbcontab_slip_lancamento.nrctacrd%TYPE
                               ,pr_vllanmto  IN tbcontab_slip_lancamento.vllanmto%TYPE
                               ,pr_cdhistor_padrao IN tbcontab_slip_lancamento.cdhistor_padrao%TYPE
                               ,pr_dslancamento IN tbcontab_slip_lancamento.dslancamento%TYPE
                               ,pr_cdoperad     IN tbcontab_slip_lancamento.cdoperad%TYPE
                               ,pr_lscdgerencial IN VARCHAR2
                               ,pr_lsvllanmto IN VARCHAR2
                               ,pr_lscdrisco_operacional IN VARCHAR2
                               ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG ||
                               ,pr_cdcritic  OUT PLS_INTEGER       --> Código da crítica
                               ,pr_dscritic  OUT VARCHAR2          --> Descrição da crítica
                               ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo  OUT VARCHAR2          --> Nome do campo com erro
                               ,pr_des_erro  OUT VARCHAR2) IS
                           
   vr_cdcritic crapcri.cdcritic%TYPE := NULL ; --> Cód. Erro
   vr_dscritic VARCHAR2(1000) := NULL;   --> Desc. Erro

   vr_tab_lscdgerencial  gene0002.typ_split;  
   vr_tab_lsvllanmto  gene0002.typ_split;
   vr_tab_lscdrisco_operacional  gene0002.typ_split;   
   vr_seq NUMBER;
   vr_dtmvtolt DATE;
   vr_vltotrat NUMBER := 0;
   vr_cdrisco_operacional VARCHAR2(25);
   rowid_lanc ROWID;
   -- Tratamento de erros
   vr_exc_erro EXCEPTION;      
                                
  BEGIN
    pr_des_erro := 'OK';
    vr_cdrisco_operacional := NULL;
    
    --Utilizar as datas da crapdat
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    vr_dtmvtolt :=  btch0001.rw_crapdat.dtmvtolt; 
    
    vr_tab_lscdgerencial := gene0002.fn_quebra_string(pr_lscdgerencial,';');
    vr_tab_lsvllanmto := gene0002.fn_quebra_string(pr_lsvllanmto,';');    
    vr_tab_lscdrisco_operacional := gene0002.fn_quebra_string(pr_lscdrisco_operacional,';');     
    
    
    pc_valida_lancamento(pr_nrctadeb => pr_nrctadeb,
                         pr_nrctacrd => pr_nrctacrd,
                         pr_lscdgerencial => pr_lscdgerencial,
                         pr_lscdrisco_operacional => pr_lscdrisco_operacional,
                         pr_cdcritic => vr_cdcritic,
                         pr_dscritic => vr_dscritic);
    
    IF nvl(vr_dscritic,' ') <> ' ' THEN
       RAISE vr_exc_erro;
    END IF;
                      
    --pegar a sequencia slip 
    SELECT nvl(MAX(nrsequencia_slip),0) + 1 INTO vr_seq FROM tbcontab_slip_lancamento tsl
     WHERE tsl.dtmvtolt = vr_dtmvtolt
      AND  tsl.cdcooper = pr_cdcooper;
    
    IF nvl(pr_vllanmto,0) <= 0 THEN 
       vr_dscritic := 'Valor do lancamento deve ser maior que 0.';
       RAISE vr_exc_erro;
    END IF;
        
    -- verifca se o valor do rateio é diferente do valor do lancamentos
    IF  vr_tab_lsvllanmto.count() > 0 THEN -- valores do rateio
       FOR idx IN vr_tab_lsvllanmto.first..vr_tab_lsvllanmto.last LOOP
          vr_vltotrat :=  vr_vltotrat + nvl(REPLACE(REPLACE(vr_tab_lsvllanmto(idx),'.',''),',','.'),0);                                
       END LOOP;
    
       IF vr_vltotrat <> pr_vllanmto THEN 
          vr_dscritic := 'Valor do rateio diferente do valor do lancamento.';
          RAISE vr_exc_erro;
       END IF;
    END IF;
                   
    BEGIN
            
      --inserir lancamento
      INSERT INTO tbcontab_slip_lancamento
      (cdcooper,
       dtmvtolt,
       nrsequencia_slip,
       cdhistor,
       nrctadeb,
       nrctacrd,
       vllanmto,
       cdhistor_padrao,
       dslancamento,
       cdoperad)
       VALUES
       (pr_cdcooper,
        vr_dtmvtolt,
        vr_seq,
        nvl(pr_cdhistor,0),
        pr_nrctadeb,
        pr_nrctacrd,
        pr_vllanmto,
        pr_cdhistor_padrao,
        gene0007.fn_caract_acento(pr_dslancamento,1),
        pr_cdoperad)
        RETURNING ROWID INTO rowid_lanc;
        
        --inserir rateio com a lista de gerencias
        
       IF  vr_tab_lscdgerencial.count() > 0 THEN
           FOR idx IN vr_tab_lscdgerencial.first..vr_tab_lscdgerencial.last LOOP
              IF vr_tab_lscdgerencial(idx) IS NOT NULL THEN                
                INSERT INTO tbcontab_slip_rateio
                (cdcooper,
                 dtmvtolt,
                 nrsequencia_slip,
                 cdgerencial,
                 vllanmto)
                VALUES
                (pr_cdcooper,
                 vr_dtmvtolt,
                 vr_seq,
                 vr_tab_lscdgerencial(idx),
                 REPLACE(REPLACE(vr_tab_lsvllanmto(idx),'.',''),',','.'));  
               END IF;                       
           END LOOP;
       END IF;
      
       IF  vr_tab_lscdrisco_operacional.count() > 0 THEN 
          FOR idx IN vr_tab_lscdrisco_operacional.first..vr_tab_lscdrisco_operacional.last LOOP
              
              IF vr_tab_lscdrisco_operacional(idx) IS NOT NULL THEN
                  
                INSERT INTO tbcontab_slip_risco
                (cdcooper,
                 dtmvtolt,
                 nrsequencia_slip,
                 cdrisco_operacional)
                VALUES
                (pr_cdcooper,
                 vr_dtmvtolt,
                 vr_seq,
                 vr_tab_lscdrisco_operacional(idx))                  
                 RETURNING 
                 cdrisco_operacional
                 INTO 
                 vr_cdrisco_operacional;
                 
               END IF;
          END LOOP;
       END IF; 
        
      UPDATE tbcontab_slip_lancamento lan SET lan.dslancamento = TRIM(nvl(vr_cdrisco_operacional,'') || ' ' || lan.dslancamento)
       WHERE lan.rowid = rowid_lanc; 
               
  
     EXCEPTION
        WHEN OTHERS THEN 
           vr_cdcritic := 0;
           vr_dscritic := 'Erro ao inserir Lancamento. ' || Sqlerrm;             
           RAISE vr_exc_erro;
     END;
   
    
      
     COMMIT;
     
            
  EXCEPTION 
    WHEN vr_exc_erro THEN
      ROLLBACK;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      ROLLBACK;
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na rotina que insere parametro.' || SQLERRM ;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_insere_lancamento;  
   

 PROCEDURE pc_exclui_lancamento(pr_cdcooper  IN crapass.cdcooper%TYPE         -->  lista historico                            
                               ,pr_nrseqlan  IN tbcontab_slip_lancamento.nrsequencia_slip%TYPE --> sequencia slip
                               ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG ||
                               ,pr_cdcritic  OUT PLS_INTEGER       --> Código da crítica
                               ,pr_dscritic  OUT VARCHAR2          --> Descrição da crítica
                               ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo  OUT VARCHAR2          --> Nome do campo com erro
                               ,pr_des_erro  OUT VARCHAR2) IS
                           
  
  CURSOR cr_nrseqlan (pr_nrseqlan IN tbcontab_slip_lancamento.nrsequencia_slip%TYPE,
                      pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
    SELECT 1 FROM tbcontab_slip_lancamento  tsl
     WHERE tsl.nrsequencia_slip = pr_nrseqlan
      AND  tsl.dtmvtolt = pr_dtmvtolt
      AND  tsl.cdcooper = pr_cdcooper; -- fixar data do lancamento para a do dia
   
   vr_cdcritic crapcri.cdcritic%TYPE := NULL ; --> Cód. Erro
   vr_dscritic VARCHAR2(1000) := NULL;   --> Desc. Erro
  
   vr_seq NUMBER;
   vr_dtmvtolt DATE;
   vr_flgnrseqlan PLS_INTEGER;
   
   -- Tratamento de erros
   vr_exc_erro EXCEPTION;      
                                
  BEGIN
    pr_des_erro := 'OK';
    
    --Utilizar as datas da CENTRAL
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    vr_dtmvtolt :=  btch0001.rw_crapdat.dtmvtolt; 
    
    --pegar a sequencia slip 
    SELECT nvl(MAX(nrsequencia_slip),0) + 1 INTO vr_seq FROM tbcontab_slip_lancamento tsl
     WHERE tsl.dtmvtolt = vr_dtmvtolt
      AND  tsl.cdcooper = pr_cdcooper;
         
      --Utilizar as datas da CENTRAL
    OPEN btch0001.cr_crapdat(3);
    FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    vr_dtmvtolt :=  btch0001.rw_crapdat.dtmvtolt; 
    
    -- verificar se é uma sequencia valida
    OPEN cr_nrseqlan(pr_nrseqlan,vr_dtmvtolt);
    FETCH cr_nrseqlan INTO vr_flgnrseqlan;
    CLOSE cr_nrseqlan;
    
    IF vr_flgnrseqlan  <> 1 THEN 
       vr_dscritic := 'sequencia: '|| pr_nrseqlan || ' não existe para esta data. Alteracao nao sera feita.';
       RAISE vr_exc_erro;   
    END IF;
     
     BEGIN 
       ---deletar rateio
       DELETE tbcontab_slip_rateio  tsrat
        WHERE tsrat.cdcooper = pr_cdcooper
         AND  tsrat.dtmvtolt = vr_dtmvtolt
         AND  tsrat.nrsequencia_slip = pr_nrseqlan;
              
       DELETE  tbcontab_slip_risco   tsr  
        WHERE tsr.cdcooper = pr_cdcooper
         AND  tsr.dtmvtolt = vr_dtmvtolt
         AND  tsr.nrsequencia_slip = pr_nrseqlan;
            
        DELETE tbcontab_slip_lancamento tsl
         WHERE tsl.cdcooper = pr_cdcooper
          AND  tsl.dtmvtolt = vr_dtmvtolt
          AND  tsl.nrsequencia_slip = pr_nrseqlan;
                                         
    EXCEPTION 
       WHEN OTHERS THEN 
         vr_dscritic := 'Erro ao tentar excluir lancamento.';
         
    END;
   
    
      
     COMMIT;
     
            
  EXCEPTION 
    WHEN vr_exc_erro THEN
      ROLLBACK;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      ROLLBACK;
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na rotina que insere parametro.' || SQLERRM ;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_exclui_lancamento; 
     

PROCEDURE pc_altera_lancamento(pr_cdcooper  IN crapass.cdcooper%TYPE         -->  coperativa                  
                              ,pr_nrseqlan  IN tbcontab_slip_lancamento.nrsequencia_slip%TYPE --> sequencia slip
                              ,pr_cdhistor  IN tbcontab_slip_lancamento.cdhistor%TYPE         --> historico alios                 
                              ,pr_nrctadeb  IN tbcontab_slip_lancamento.nrctadeb%TYPE         --> conta debito
                              ,pr_nrctacrd  IN tbcontab_slip_lancamento.nrctacrd%TYPE  --> conta credito
                              ,pr_vllanmto  IN tbcontab_slip_lancamento.vllanmto%TYPE  --> valor do lancamento
                              ,pr_cdhistor_padrao IN tbcontab_slip_lancamento.cdhistor_padrao%TYPE --> hisotrico padrao
                              ,pr_dslancamento IN tbcontab_slip_lancamento.dslancamento%TYPE --> descrição do lancamento
                              ,pr_cdoperad     IN tbcontab_slip_lancamento.cdoperad%TYPE  --> operador que alterou o lancamento
                              ,pr_lscdgerencial IN VARCHAR2 --> lista gerenciais
                              ,pr_lsvllanmto IN VARCHAR2 --> valor lancamento
                              ,pr_lscdrisco_operacional IN VARCHAR2 --> lista risco operacional
                              ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG ||
                              ,pr_cdcritic  OUT PLS_INTEGER       --> Código da crítica
                              ,pr_dscritic  OUT VARCHAR2          --> Descrição da crítica
                              ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo  OUT VARCHAR2          --> Nome do campo com erro
                              ,pr_des_erro  OUT VARCHAR2) IS
                           
   
   CURSOR cr_nrseqlan (pr_nrseqlan IN tbcontab_slip_lancamento.nrsequencia_slip%TYPE,
                       pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
    SELECT 1 FROM tbcontab_slip_lancamento  tsl
     WHERE tsl.nrsequencia_slip = pr_nrseqlan
      AND  tsl.dtmvtolt = pr_dtmvtolt
      AND  tsl.cdcooper = pr_cdcooper; -- fixar data do lancamento para a do dia
   
   vr_cdcritic crapcri.cdcritic%TYPE := NULL ; --> Cód. Erro
   vr_dscritic VARCHAR2(1000) := NULL;   --> Desc. Erro

   vr_tab_lscdgerencial  gene0002.typ_split;  
   vr_tab_lsvllanmto  gene0002.typ_split;
   vr_tab_lscdrisco_operacional  gene0002.typ_split;   
   vr_seq NUMBER;
   vr_dtmvtolt DATE;
   vr_flgnrseqlan PLS_INTEGER;
   vr_vltotrat NUMBER := 0;
   -- Tratamento de erros
   vr_exc_erro EXCEPTION;      
                                
  BEGIN
    pr_des_erro := 'OK';
       --Utilizar as datas da CENTRAL
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    vr_dtmvtolt :=  btch0001.rw_crapdat.dtmvtolt; 
    
    vr_tab_lscdgerencial := gene0002.fn_quebra_string(pr_lscdgerencial,';');
    vr_tab_lsvllanmto := gene0002.fn_quebra_string(pr_lsvllanmto,';');    
    vr_tab_lscdrisco_operacional := gene0002.fn_quebra_string(pr_lscdrisco_operacional,';');     
     
    pc_valida_lancamento(pr_nrctadeb => pr_nrctadeb,
                         pr_nrctacrd => pr_nrctacrd,
                         pr_lscdgerencial => pr_lscdgerencial,
                         pr_lscdrisco_operacional => pr_lscdrisco_operacional,
                         pr_cdcritic => vr_cdcritic,
                         pr_dscritic => vr_dscritic);
    
    IF nvl(vr_dscritic,' ') <> ' ' THEN
       RAISE vr_exc_erro;
    END IF;
    
    IF nvl(pr_vllanmto,0) <= 0 THEN 
       vr_dscritic := 'Valor do lancamento deve ser maior que 0.';
       RAISE vr_exc_erro;
    END IF;
               
    -- verifca se o valor do rateio é diferente do valor do lancamentos
    IF  vr_tab_lsvllanmto.count() > 0 THEN -- valores do rateio
       FOR idx IN vr_tab_lsvllanmto.first..vr_tab_lsvllanmto.last LOOP
          vr_vltotrat :=  vr_vltotrat + nvl(REPLACE(REPLACE(vr_tab_lsvllanmto(idx),'.',''),',','.'),0);                                
       END LOOP;
    
       IF vr_vltotrat <> pr_vllanmto THEN 
          vr_dscritic := 'Valor do rateio diferente do valor do lancamento.';
          RAISE vr_exc_erro;
       END IF;
    END IF;
      
    -- verificar se é uma sequencia valida
    OPEN cr_nrseqlan(pr_nrseqlan,vr_dtmvtolt);
    FETCH cr_nrseqlan INTO vr_flgnrseqlan;
    CLOSE cr_nrseqlan;
    
    IF vr_flgnrseqlan  <> 1 THEN 
       vr_dscritic := 'sequencia: '|| pr_nrseqlan || ' não existe para esta data. Alteracao nao sera feita.';
       RAISE vr_exc_erro;   
    END IF;
    
    -- para alterarmos devemos deletar a sequencia caso ela exista.
    -- após isso pegar os dados do parametro e inserilos novamente.
    
    BEGIN 
       ---deletar rateio
       DELETE tbcontab_slip_rateio  tsrat
        WHERE tsrat.cdcooper = pr_cdcooper
         AND  tsrat.dtmvtolt = vr_dtmvtolt
         AND  tsrat.nrsequencia_slip = pr_nrseqlan;
              
       DELETE  tbcontab_slip_risco   tsr  
        WHERE tsr.cdcooper = pr_cdcooper
         AND  tsr.dtmvtolt = vr_dtmvtolt
         AND  tsr.nrsequencia_slip = pr_nrseqlan;
            
        DELETE tbcontab_slip_lancamento tsl
         WHERE tsl.cdcooper = pr_cdcooper
          AND  tsl.dtmvtolt = vr_dtmvtolt
          AND  tsl.nrsequencia_slip = pr_nrseqlan;
                                         
    EXCEPTION 
       WHEN OTHERS THEN 
         vr_dscritic := 'Erro ao tentar alterar lancamento(1).';
         
    END;
    
    BEGIN
            
      --inserir lancamento
      INSERT INTO tbcontab_slip_lancamento
      (cdcooper,
       dtmvtolt,
       nrsequencia_slip,
       cdhistor,
       nrctadeb,
       nrctacrd,
       vllanmto,
       cdhistor_padrao,
       dslancamento,
       cdoperad)
       VALUES
       (pr_cdcooper,
        vr_dtmvtolt,
        pr_nrseqlan,
        pr_cdhistor,
        pr_nrctadeb,
        pr_nrctacrd,
        pr_vllanmto,
        pr_cdhistor_padrao,
        gene0007.fn_caract_acento(pr_dslancamento,1),
        pr_cdoperad);
        
        --inserir rateio com a lista de gerencias
        
       IF  vr_tab_lscdgerencial.count() > 0 THEN
           FOR idx IN vr_tab_lscdgerencial.first..vr_tab_lscdgerencial.last LOOP
              IF vr_tab_lscdgerencial(idx) IS NOT NULL THEN                
                INSERT INTO tbcontab_slip_rateio
                (cdcooper,
                 dtmvtolt,
                 nrsequencia_slip,
                 cdgerencial,
                 vllanmto)
                VALUES
                (pr_cdcooper,
                 vr_dtmvtolt,
                 pr_nrseqlan,
                 vr_tab_lscdgerencial(idx),
                 REPLACE(REPLACE(vr_tab_lsvllanmto(idx),'.',''),',','.'));  
               END IF;                       
           END LOOP;
       END IF;
      
       IF  vr_tab_lscdrisco_operacional.count() > 0 THEN 
          FOR idx IN vr_tab_lscdrisco_operacional.first..vr_tab_lscdrisco_operacional.last LOOP
              
              IF vr_tab_lscdrisco_operacional(idx) IS NOT NULL THEN
                  
                INSERT INTO tbcontab_slip_risco
                (cdcooper,
                 dtmvtolt,
                 nrsequencia_slip,
                 cdrisco_operacional)
                VALUES
                (pr_cdcooper,
                 vr_dtmvtolt,
                 pr_nrseqlan,
                 vr_tab_lscdrisco_operacional(idx));
                 
               END IF;
          END LOOP;
       END IF; 
        
  
     EXCEPTION
        WHEN OTHERS THEN 
           vr_cdcritic := 0;
           vr_dscritic := 'Erro ao inserir Lancamento(2). ' || Sqlerrm;             
           RAISE vr_exc_erro;
     END;
             
     COMMIT;      
            
  EXCEPTION 
    WHEN vr_exc_erro THEN
      ROLLBACK;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      ROLLBACK;
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na rotina que insere parametro.' || SQLERRM ;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_altera_lancamento;  
         

 PROCEDURE pc_insere_risco(pr_cdrisco_operacional IN tbcontab_prm_risco_slip.cdrisco_operacional%TYPE        -->  cd risco operacional  
                         ,pr_dsrisco_operacional IN tbcontab_prm_risco_slip.cdrisco_operacional%TYPE         --> descrição
                         ,pr_lsnrconta_contabil  IN VARCHAR2 -- lista com contas contabeis
                         ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG ||
                         ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                         ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                         ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2) IS
                           
   vr_cdcritic crapcri.cdcritic%TYPE := NULL ; --> Cód. Erro
   vr_dscritic VARCHAR2(1000) := NULL;   --> Desc. Erro

   vr_tab_lsnrconta_contabil  gene0002.typ_split;
 


   -- Tratamento de erros
   vr_exc_erro EXCEPTION;      
                                
  BEGIN
    pr_des_erro := 'OK';
    
    vr_tab_lsnrconta_contabil := gene0002.fn_quebra_string(pr_lsnrconta_contabil,';');                 
    
    BEGIN
              
                                            
        -- iserir risco operacional
        INSERT INTO tbcontab_prm_risco_slip 
        (cdrisco_operacional,
         dsrisco_operacional)
        VALUES 
        (pr_cdrisco_operacional, 
         gene0007.fn_caract_acento(pr_dsrisco_operacional,1));
        
     IF vr_tab_lsnrconta_contabil.count() > 0 THEN                             
         
        FOR idx IN vr_tab_lsnrconta_contabil.first..vr_tab_lsnrconta_contabil.last LOOP
            
          IF vr_tab_lsnrconta_contabil(idx) IS NOT NULL THEN             
              INSERT INTO tbcontab_prm_risco_cta_slip
              (cdrisco_operacional,
               nrconta_contabil)
              VALUES
              (pr_cdrisco_operacional,
               vr_tab_lsnrconta_contabil(idx));
           END IF;
           
        END LOOP;      
                             
     END IF;       
 
              
    EXCEPTION
      WHEN OTHERS THEN 
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao inserir Risco. ' || Sqlerrm;             
        RAISE vr_exc_erro;
    END;
    
      
    COMMIT;
      

            
  EXCEPTION 
    WHEN vr_exc_erro THEN
      ROLLBACK;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      ROLLBACK;
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na rotina que insere parametro.' || SQLERRM ;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_insere_risco;

PROCEDURE pc_altera_risco(pr_cdrisco_operacional IN tbcontab_prm_risco_slip.cdrisco_operacional%TYPE        -->  cd risco operacional  
                         ,pr_dsrisco_operacional IN tbcontab_prm_risco_slip.cdrisco_operacional%TYPE         --> descrição
                         ,pr_lsnrconta_contabil  IN VARCHAR2 -- lista com contas contabeis
                         ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG ||
                         ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                         ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                         ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2) IS
                           
   vr_cdcritic crapcri.cdcritic%TYPE := NULL ; --> Cód. Erro
   vr_dscritic VARCHAR2(1000) := NULL;   --> Desc. Erro

   vr_tab_lsnrconta_contabil  gene0002.typ_split;
 


   -- Tratamento de erros
   vr_exc_erro EXCEPTION;      
                                
  BEGIN
    pr_des_erro := 'OK';
    
    vr_tab_lsnrconta_contabil := gene0002.fn_quebra_string(pr_lsnrconta_contabil,';');                 
    
    BEGIN
        DELETE  tbcontab_prm_risco_cta_slip
         WHERE cdrisco_operacional = pr_cdrisco_operacional;
        
        DELETE  tbcontab_prm_risco_slip
         WHERE cdrisco_operacional = pr_cdrisco_operacional;
                                            
        -- iserir risco operacional
        INSERT INTO tbcontab_prm_risco_slip 
        (cdrisco_operacional,
         dsrisco_operacional)
        VALUES 
        (pr_cdrisco_operacional, 
         gene0007.fn_caract_acento(pr_dsrisco_operacional,1));
                                  
     IF vr_tab_lsnrconta_contabil.count() > 0 THEN        
        FOR idx IN vr_tab_lsnrconta_contabil.first..vr_tab_lsnrconta_contabil.last LOOP
            
          IF vr_tab_lsnrconta_contabil(idx) IS NOT NULL THEN             
              INSERT INTO tbcontab_prm_risco_cta_slip
              (cdrisco_operacional,
               nrconta_contabil)
              VALUES
              (pr_cdrisco_operacional,
               vr_tab_lsnrconta_contabil(idx));
           END IF;
           
        END LOOP;      
      END IF;                       
             
 
              
    EXCEPTION
      WHEN OTHERS THEN 
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar Risco. ' || Sqlerrm;             
        RAISE vr_exc_erro;
    END;
    
      
    COMMIT;
      

            
  EXCEPTION 
    WHEN vr_exc_erro THEN
      ROLLBACK;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      ROLLBACK;
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na rotina que atualiza parametro.' || SQLERRM ;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_altera_risco;
    
  

 PROCEDURE pc_busca_historicos(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG ||
                             ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS
                           
  
   CURSOR cr_historicos IS
    SELECT 
      his.cdhistor,
      his.nrctadeb,
      his.nrctacrd
    FROM tbcontab_prm_his_slip his
    ORDER BY his.cdhistor;

 
   vr_cdcritic crapcri.cdcritic%TYPE := NULL ; --> Cód. Erro
   vr_dscritic VARCHAR2(1000) := NULL;   --> Desc. Erro

   -- Tratamento de erros
   vr_exc_erro EXCEPTION;      
  
  --> variaveis auxiliares 
   vr_des_xml         CLOB;  
   vr_texto_completo  VARCHAR2(32600); 
   
   -- Subrotina para escrever texto na variável CLOB do XML
   procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
   begin
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
   end;   
                             
  BEGIN
    pr_des_erro := 'OK';
     
    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
    vr_texto_completo := null;        
        
      -- Criar cabeçalho do XML
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                     '<Dados>');
                     
    FOR rw_historicos  IN cr_historicos LOOP

      BEGIN
        pc_escreve_xml( '<historicos>
                         <cdhistor>'|| rw_historicos.cdhistor ||'</cdhistor>'||
                        '<nrctadeb>'|| rw_historicos.nrctadeb ||'</nrctadeb>'||
                        '<nrctacrd>'|| rw_historicos.nrctacrd ||'</nrctacrd>'||
                        '</historicos>');   
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Erro ao buscar historicos '||
                       ': '||SQLERRM;
        RAISE vr_exc_erro;               
      END;                         
    END LOOP;

    
    pc_escreve_xml('</Dados>',TRUE);
    pr_retxml := xmltype.createxml(vr_des_xml);        
      
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
                           
    
               
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na rotina que insere parametro.' || SQLERRM ;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_busca_historicos;
   
 PROCEDURE pc_busca_gerenciais(pr_cdcooper IN crapass.cdcooper%TYPE
                             ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG ||
                             ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS
                           
  
   CURSOR cr_gerencial IS
    SELECT 
      ger.cdcooper,
      ger.cdgerencial,
      ger.idativo
    FROM tbcontab_prm_gerencial_slip ger
     WHERE ger.cdcooper = pr_cdcooper;
 
   vr_cdcritic crapcri.cdcritic%TYPE := NULL ; --> Cód. Erro
   vr_dscritic VARCHAR2(1000) := NULL;   --> Desc. Erro

   -- Tratamento de erros
   vr_exc_erro EXCEPTION;      
  
  --> variaveis auxiliares 
   vr_des_xml         CLOB;  
   vr_texto_completo  VARCHAR2(32600); 
   
   -- Subrotina para escrever texto na variável CLOB do XML
   procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
   begin
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
   end;   
                             
  BEGIN
    pr_des_erro := 'OK';
     
    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
    vr_texto_completo := null;        
        
      -- Criar cabeçalho do XML
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                     '<Dados>');
                     
    FOR rw_gerencial  IN cr_gerencial LOOP

      BEGIN
        pc_escreve_xml( '<gerenciais>
                         <cdcooper>'|| rw_gerencial.cdcooper ||'</cdcooper>'||
                        '<cdgerencial>'|| rw_gerencial.cdgerencial ||'</cdgerencial>'||
                        '<idativo>'|| rw_gerencial.idativo ||'</idativo>'||
                        '</gerenciais>');   
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Erro ao buscar gerencias '||
                       ': '||SQLERRM;
        RAISE vr_exc_erro;               
      END;                         
    END LOOP;
    
    pc_escreve_xml('</Dados>',TRUE);
    pr_retxml := xmltype.createxml(vr_des_xml);        
      
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
                           
    
               
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na rotina que insere parametro.' || SQLERRM ;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_busca_gerenciais;


 
PROCEDURE pc_busca_riscos_lanc(pr_cdcooper IN crapass.cdcooper%TYPE
                              ,pr_nrseqlan IN tbcontab_slip_rateio.nrsequencia_slip%TYPE --> sequencian do lancamento
                              ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG ||
                              ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro 
                              ,pr_des_erro OUT VARCHAR2) IS
                           
  
   CURSOR cr_risco_lanc(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE)IS
    SELECT 
      tsr.cdrisco_operacional
    FROM tbcontab_slip_risco tsr
     WHERE tsr.cdcooper = pr_cdcooper
      AND  tsr.nrsequencia_slip = pr_nrseqlan
      AND  tsr.dtmvtolt = pr_dtmvtolt; -- 
 
   vr_cdcritic crapcri.cdcritic%TYPE := NULL ; --> Cód. Erro
   vr_dscritic VARCHAR2(1000) := NULL;   --> Desc. Erro

   -- Tratamento de erros
   vr_exc_erro EXCEPTION;      
   vr_dtmvtolt DATE;
  --> variaveis auxiliares 
   vr_des_xml         CLOB;  
   vr_texto_completo  VARCHAR2(32600); 
   
   -- Subrotina para escrever texto na variável CLOB do XML
   procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
   begin
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
   end;   
                             
  BEGIN
    pr_des_erro := 'OK';
     
    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
    vr_texto_completo := null;        
        
      -- Criar cabeçalho do XML
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                     '<Dados>');
     --Utilizar as datas da CENTRAL
    OPEN btch0001.cr_crapdat(3);
    FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    vr_dtmvtolt :=  btch0001.rw_crapdat.dtmvtolt; 
                     
    FOR rw_risco_lanc  IN cr_risco_lanc(vr_dtmvtolt) LOOP

      BEGIN
        pc_escreve_xml( '<riscos>
                         <cdrisco_operacional>'|| rw_risco_lanc.cdrisco_operacional ||'</cdrisco_operacional>'||                        
                        '</riscos>');   
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Erro ao buscar riscos '||
                       ': '||SQLERRM;
        RAISE vr_exc_erro;               
      END;                         
    END LOOP;
    
    pc_escreve_xml('</Dados>',TRUE);
    pr_retxml := xmltype.createxml(vr_des_xml);        
      
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
                           
    
               
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratada na rotia que busca risco.' || SQLERRM ;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_busca_riscos_lanc;
      
 PROCEDURE pc_busca_gerenciais_lanc(pr_cdcooper IN crapass.cdcooper%TYPE
                                   ,pr_nrseqlan IN tbcontab_slip_rateio.nrsequencia_slip%TYPE --> sequencian do lancamento
                                   ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG ||
                                   ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro 
                                   ,pr_des_erro OUT VARCHAR2) IS
                           
  
   CURSOR cr_gerencial_lanc(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
    SELECT 
      tsr.cdgerencial,
      tsr.vllanmto      
    FROM tbcontab_slip_rateio tsr
     WHERE tsr.cdcooper = pr_cdcooper
      AND  tsr.nrsequencia_slip = pr_nrseqlan
      AND  tsr.dtmvtolt = pr_dtmvtolt; -- 
 
   vr_cdcritic crapcri.cdcritic%TYPE := NULL ; --> Cód. Erro
   vr_dscritic VARCHAR2(1000) := NULL;   --> Desc. Erro

   -- Tratamento de erros
   vr_exc_erro EXCEPTION;  
   
   vr_dtmvtolt DATE;    
  
  --> variaveis auxiliares 
   vr_des_xml         CLOB;  
   vr_texto_completo  VARCHAR2(32600); 
   
   -- Subrotina para escrever texto na variável CLOB do XML
   procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
   begin
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
   end;   
                             
  BEGIN
    pr_des_erro := 'OK';
     
    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
    vr_texto_completo := null;        
    
    --Utilizar as datas da CENTRAL
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    vr_dtmvtolt :=  btch0001.rw_crapdat.dtmvtolt; 
      
      -- Criar cabeçalho do XML
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                     '<Dados>');
                     
    FOR rw_gerencial_lanc  IN cr_gerencial_lanc(vr_dtmvtolt) LOOP

      BEGIN
        pc_escreve_xml( '<gerenciais>
                         <cdgerencial>'|| rw_gerencial_lanc.cdgerencial ||'</cdgerencial>'||
                        '<vllanmto>'|| to_char(rw_gerencial_lanc.vllanmto,'FM999G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') ||'</vllanmto>'||
                        '</gerenciais>');   
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Erro ao buscar gerencias '||
                       ': '||SQLERRM;
        RAISE vr_exc_erro;               
      END;                         
    END LOOP;
    
    pc_escreve_xml('</Dados>',TRUE);
    pr_retxml := xmltype.createxml(vr_des_xml);        
      
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
                           
    
               
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na rotina que busca gerenciais.' || SQLERRM ;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_busca_gerenciais_lanc;
    

 PROCEDURE pc_busca_conta_contabil(pr_cdrisco_operacional IN tbcontab_prm_risco_slip.cdrisco_operacional%TYPE
                                  ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG ||
                                  ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS
                           
  
   CURSOR cr_ctacontabil IS
    SELECT 
     cta.nrconta_contabil
    FROM tbcontab_prm_risco_cta_slip cta
     WHERE cta.cdrisco_operacional = pr_cdrisco_operacional
    ORDER BY cta.nrconta_contabil;
 
   vr_cdcritic crapcri.cdcritic%TYPE := NULL ; --> Cód. Erro
   vr_dscritic VARCHAR2(1000) := NULL;   --> Desc. Erro

   -- Tratamento de erros
   vr_exc_erro EXCEPTION;      
  
  --> variaveis auxiliares 
   vr_des_xml         CLOB;  
   vr_texto_completo  VARCHAR2(32600); 
   
   -- Subrotina para escrever texto na variável CLOB do XML
   procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
   begin
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
   end;   
                             
  BEGIN
    pr_des_erro := 'OK';
     
    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
    vr_texto_completo := null;        
        
      -- Criar cabeçalho do XML
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                     '<Dados>');
                     
    FOR rw_ctacontabil  IN cr_ctacontabil LOOP

      BEGIN
        pc_escreve_xml( '<lsconta>
                         <nrconta_contabil>'|| rw_ctacontabil.nrconta_contabil ||'</nrconta_contabil>'||
                        '</lsconta>');   
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Erro ao buscar contas contabeis '||
                       ': '||SQLERRM;
        RAISE vr_exc_erro;               
      END;                         
    END LOOP;
    
    pc_escreve_xml('</Dados>',TRUE);
    pr_retxml := xmltype.createxml(vr_des_xml);        
      
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
                           
    
               
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na rotina que busca conta contabil.' || SQLERRM ;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_busca_conta_contabil;  
  
 PROCEDURE pc_busca_riscos(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG ||
                          ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2) IS
                           
  
   CURSOR cr_risco IS
    SELECT 
      ris.cdrisco_operacional,
      ris.dsrisco_operacional

    FROM tbcontab_prm_risco_slip ris
    ORDER BY ris.cdrisco_operacional;
 
   vr_cdcritic crapcri.cdcritic%TYPE := NULL ; --> Cód. Erro
   vr_dscritic VARCHAR2(1000) := NULL;   --> Desc. Erro

   -- Tratamento de erros
   vr_exc_erro EXCEPTION;      
  
  --> variaveis auxiliares 
   vr_des_xml         CLOB;  
   vr_texto_completo  VARCHAR2(32600); 
   
   -- Subrotina para escrever texto na variável CLOB do XML
   procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
   begin
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
   end;   
                             
  BEGIN
    pr_des_erro := 'OK';
     
    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
    vr_texto_completo := null;        
        
      -- Criar cabeçalho do XML
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                     '<Dados>');
                     
    FOR rw_risco  IN cr_risco LOOP

      BEGIN
        pc_escreve_xml( '<riscos>
                         <cdrisco_operacional>'|| to_char(rw_risco.cdrisco_operacional) ||'</cdrisco_operacional>'||
                        '<dsrisco_operacional>'|| rw_risco.dsrisco_operacional ||'</dsrisco_operacional>'||
                        '</riscos>');   
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Erro ao buscar riscos '||
                       ': '||SQLERRM;
        RAISE vr_exc_erro;               
      END;                         
    END LOOP;
    
    pc_escreve_xml('</Dados>',TRUE);
    pr_retxml := xmltype.createxml(vr_des_xml);        
      
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
                           
    
               
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na rotina que insere parametro.' || SQLERRM ;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_busca_riscos;  
                                                                                         

                             
  PROCEDURE pc_busca_hist_param(pr_cdhistor IN NUMBER
                               ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG ||
                               ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS
                            
  
   CURSOR cr_hist_para IS
    SELECT nrctadeb,nrctacrd FROM  tbcontab_prm_his_slip
     WHERE cdhistor = pr_cdhistor;
     
  CURSOR cr_hist_padrao (pr_nrconta_contabil IN tbcontab_prm_cta_ctb_slip.nrconta_contabil%TYPE)IS
   SELECT cta.cdhistor,
          cta.idexige_rateio_gerencial AS idger,
          cta.idexige_risco_operacional AS idris FROM tbcontab_prm_cta_ctb_slip cta
    WHERE cta.nrconta_contabil = pr_nrconta_contabil;
   rw_hist_padrao cr_hist_padrao%ROWTYPE;
   
   vr_cdcritic crapcri.cdcritic%TYPE := NULL ; --> Cód. Erro
   vr_dscritic VARCHAR2(1000) := NULL;   --> Desc. Erro

   -- Tratamento de erros
   vr_exc_erro EXCEPTION;      
   vr_cdhistor NUMBER(5);
   
  --> variaveis auxiliares 
   vr_des_xml         CLOB;  
   vr_texto_completo  VARCHAR2(32600); 
   
   -- Subrotina para escrever texto na variável CLOB do XML
   procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
   begin
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
   end;   
                             
  BEGIN
    pr_des_erro := 'OK';
     
    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
    vr_texto_completo := null;        
        
      -- Criar cabeçalho do XML
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                     '<Dados>');
                     
    FOR rw_hist_para  IN cr_hist_para LOOP

      BEGIN
        
        IF rw_hist_para.nrctadeb IS NOT NULL THEN          
           OPEN cr_hist_padrao(rw_hist_para.nrctadeb);
           FETCH cr_hist_padrao INTO rw_hist_padrao;
           CLOSE cr_hist_padrao; 
        END IF;
        
        IF rw_hist_para.nrctacrd IS NOT NULL THEN          
           OPEN cr_hist_padrao(rw_hist_para.nrctacrd);
           FETCH cr_hist_padrao INTO rw_hist_padrao;
           CLOSE cr_hist_padrao; 
        END IF;
        
                       
        pc_escreve_xml( '<hist_param>
                         <nrctadeb>'|| rw_hist_para.nrctadeb ||'</nrctadeb>'||
                        '<nrctacrd>'|| rw_hist_para.nrctacrd ||'</nrctacrd>'||
                        '<cdhistor>'|| rw_hist_padrao.cdhistor ||'</cdhistor>'||  
                        '<idger>'|| rw_hist_padrao.idger ||'</idger>'||
                        '<idris>'|| rw_hist_padrao.idris ||'</idris>'||                      
                        '</hist_param>');   
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Erro ao buscar historico parametro '||
                       ': '||SQLERRM;
        RAISE vr_exc_erro;               
      END;                         
    END LOOP;
    
    pc_escreve_xml('</Dados>',TRUE);
    pr_retxml := xmltype.createxml(vr_des_xml);        
      
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
                           
    
               
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na rotina que busca historico parametro.' || SQLERRM ;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_busca_hist_param;

 PROCEDURE pc_busca_lancamentos(pr_cdcooper IN crapass.cdcooper%TYPE
                               ,pr_nrregist IN NUMBER
                               ,pr_nriniseq IN NUMBER                             
                               ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG ||
                               ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS
                            
  
   CURSOR cr_lancamentos (pr_dtmvtolt IN crapdat.dtmvtolt%TYPE)IS
     SELECT lan.nrsequencia_slip,
        lan.cdhistor,
        lan.nrctadeb,
        lan.nrctacrd,
        lan.vllanmto,
        lan.cdhistor_padrao,
        lan.dslancamento,
        lan.cdoperad,
        lan.cdoperad || ' - ' || ope.nmoperad AS dsoperador
      FROM tbcontab_slip_lancamento lan
      LEFT JOIN crapope ope ON (ope.cdoperad = lan.cdoperad AND ope.cdcooper = lan.cdcooper)
      WHERE lan.nrsequencia_slip <= pr_nrregist
       AND  lan.nrsequencia_slip >= pr_nriniseq
       AND  lan.cdcooper = pr_cdcooper
       AND  lan.dtmvtolt = pr_dtmvtolt
      ORDER BY lan.nrsequencia_slip;
   
   vr_cdcritic crapcri.cdcritic%TYPE := NULL ; --> Cód. Erro
   vr_dscritic VARCHAR2(1000) := NULL;   --> Desc. Erro
   vr_dtmvtolt DATE;
   -- Tratamento de erros
   vr_exc_erro EXCEPTION;      
   vr_cdhistor NUMBER(5);
   vr_count NUMBER;
  --> variaveis auxiliares 
   vr_des_xml         CLOB;  
   vr_texto_completo  VARCHAR2(32600); 
   
   -- Subrotina para escrever texto na variável CLOB do XML
   procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
   begin
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
   end;   
                             
  BEGIN
    pr_des_erro := 'OK';
     
    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
    vr_texto_completo := null;        
        
      -- Criar cabeçalho do XML
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                     '<Dados>');
    vr_count := 0;    
    
          --Utilizar as datas da CENTRAL
    OPEN btch0001.cr_crapdat(3);
    FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    vr_dtmvtolt :=  btch0001.rw_crapdat.dtmvtolt; 
    
    pc_escreve_xml('<lancamentos>');       
    
    
    FOR rw_lancamentos  IN cr_lancamentos(vr_dtmvtolt) LOOP

      BEGIN
                               
        pc_escreve_xml( '<registro>
                         <nrseq_slip>'|| rw_lancamentos.nrsequencia_slip ||'</nrseq_slip>'||
                        '<cdhistor>'|| rw_lancamentos.cdhistor ||'</cdhistor>'||
                        '<nrctadeb>'|| rw_lancamentos.nrctadeb ||'</nrctadeb>'||    
                        '<nrctacrd>'|| rw_lancamentos.nrctacrd ||'</nrctacrd>'|| 
                        '<vllanmto>'|| rw_lancamentos.vllanmto ||'</vllanmto>'|| 
                        '<cdhistor_padrao>'|| rw_lancamentos.cdhistor_padrao ||'</cdhistor_padrao>'|| 
                        '<dslancamento>'|| rw_lancamentos.dslancamento ||'</dslancamento>'|| 
                        '<cdoperad>'|| rw_lancamentos.cdoperad ||'</cdoperad>'||  
                        '<dsoperador>'|| rw_lancamentos.dsoperador ||'</dsoperador>'||                   
                        '</registro>');   
        vr_count := vr_count + 1;                        
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Erro ao buscar Lancamentos '||
                       ': '||SQLERRM;
        RAISE vr_exc_erro;               
      END;                         
    END LOOP;
       
     pc_escreve_xml('</lancamentos><totreg>'||vr_count||'</totreg>');
    
    pc_escreve_xml('</Dados>',TRUE);
    pr_retxml := xmltype.createxml(vr_des_xml);        
      
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
                           
    
               
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na rotina que busca os lancamentos.' || SQLERRM ;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_busca_lancamentos;

PROCEDURE pc_consulta_lancamentos(pr_cdcooper IN crapass.cdcooper%TYPE
                                 ,pr_dtmvtolt IN VARCHAR2
                                 ,pr_cdhistor  IN tbcontab_slip_lancamento.cdhistor%TYPE        
                                 ,pr_nrctadeb  IN tbcontab_slip_lancamento.nrctadeb%TYPE
                                 ,pr_nrctacrd  IN tbcontab_slip_lancamento.nrctacrd%TYPE
                                 ,pr_vllanmto  IN tbcontab_slip_lancamento.vllanmto%TYPE
                                 ,pr_cdhistor_padrao IN tbcontab_slip_lancamento.cdhistor_padrao%TYPE
                                 ,pr_dslancamento IN tbcontab_slip_lancamento.dslancamento%TYPE
                                 ,pr_cdoperad     IN tbcontab_slip_lancamento.cdoperad%TYPE                                 
                                 ,pr_nrregist IN NUMBER  
                                 ,pr_nriniseq IN NUMBER                             
                                 ,pr_opevlrlan IN VARCHAR2
                                 ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG ||
                                 ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS
                            
  
  CURSOR cr_lancamentos (pr_vllanmtoI  IN tbcontab_slip_lancamento.vllanmto%TYPE
                        ,pr_vllanmtoMA  IN tbcontab_slip_lancamento.vllanmto%TYPE
                        ,pr_vllanmtoME  IN tbcontab_slip_lancamento.vllanmto%TYPE) IS
   SELECT con.nrsequencia_slip,
          con.cdhistor,
          con.nrctadeb,
          con.nrctacrd,
          con.vllanmto,
          con.cdhistor_padrao,
          con.dslancamento,
          con.cdoperad,
          con.dsoperador
    FROM (SELECT lan.nrsequencia_slip,
          lan.cdhistor,
          lan.nrctadeb,
          lan.nrctacrd,
          lan.vllanmto,
          lan.cdhistor_padrao,
          lan.dslancamento,
          lan.cdoperad,
          lan.cdoperad || ' - ' || ope.nmoperad AS dsoperador,
          ROWNUM AS seqlanc
    FROM tbcontab_slip_lancamento lan
      LEFT JOIN crapope ope ON (ope.cdoperad = lan.cdoperad AND ope.cdcooper = lan.cdcooper) --junção 
      WHERE lan.cdcooper = pr_cdcooper -- restrição 
       AND  lan.dtmvtolt = to_date(pr_dtmvtolt,'dd/mm/yyyy')
       AND  lan.cdhistor = NVL(pr_cdhistor,lan.cdhistor)
       AND  lan.nrctadeb = NVL(pr_nrctadeb,lan.nrctadeb)
       AND  lan.nrctacrd = NVL(pr_nrctacrd,lan.nrctacrd)
       AND  lan.cdhistor_padrao = NVL(pr_cdhistor_padrao,lan.cdhistor_padrao)       
       AND  lan.cdoperad = nvl(pr_cdoperad,lan.cdoperad)
       AND  (lan.dslancamento LIKE '%'||nvl(pr_dslancamento,'')||'%')
       AND  (lan.vllanmto     = pr_vllanmtoI
             OR lan.vllanmto  > pr_vllanmtoMA
             OR lan.vllanmto  < pr_vllanmtoME)
    ORDER BY lan.dtmvtolt,lan.nrsequencia_slip) con
    WHERE con.seqlanc BETWEEN pr_nriniseq AND pr_nrregist;
       
                  
   
   vr_cdcritic crapcri.cdcritic%TYPE := NULL ; --> Cód. Erro
   vr_dscritic VARCHAR2(1000) := NULL;   --> Desc. Erro

   -- Tratamento de erros
   vr_exc_erro EXCEPTION;      
   vr_cdhistor NUMBER(5);
   vr_count NUMBER;
   vr_vllanmtoI tbcontab_slip_lancamento.vllanmto%TYPE;  -- valor quando opção for igual
   vr_vllanmtoMA tbcontab_slip_lancamento.vllanmto%TYPE; -- 
   vr_vllanmtoME tbcontab_slip_lancamento.vllanmto%TYPE;   
  --> variaveis auxiliares 
   vr_des_xml         CLOB;  
   vr_texto_completo  VARCHAR2(32600); 
   
   -- Subrotina para escrever texto na variável CLOB do XML
   procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
   begin
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
   end;   
                             
  BEGIN
    pr_des_erro := 'OK';
     
    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
    vr_texto_completo := null;        
        
      -- Criar cabeçalho do XML
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                     '<Dados>');
    vr_count := 0;    
    
    vr_vllanmtoI := NULL;
    vr_vllanmtoME := NULL;
    vr_vllanmtoMA := 0; -- default > 0 
        
    IF nvl(pr_vllanmto,0) > 0 THEN 
       IF pr_opevlrlan = 'I' THEN 
          vr_vllanmtoI := pr_vllanmto;
          vr_vllanmtoMA := NULL;
       END IF;  
       
       IF pr_opevlrlan = 'ME' THEN 
          vr_vllanmtoME := pr_vllanmto;
          vr_vllanmtoMA := NULL;          
       END IF;  
       
       IF pr_opevlrlan = 'MA' THEN 
          vr_vllanmtoMA := pr_vllanmto;         
       END IF;     
    END IF;
    
     
    pc_escreve_xml('<lancamentos>');       
    
    FOR rw_lancamentos  IN cr_lancamentos (pr_vllanmtoI   => vr_vllanmtoI
                                           ,pr_vllanmtoMA => vr_vllanmtoMA 
                                           ,pr_vllanmtoME => vr_vllanmtoME) LOOP

      BEGIN
                               
        pc_escreve_xml( '<registro>
                         <nrseq_slip>'|| rw_lancamentos.nrsequencia_slip ||'</nrseq_slip>'||
                        '<cdhistor>'|| rw_lancamentos.cdhistor ||'</cdhistor>'||
                        '<nrctadeb>'|| rw_lancamentos.nrctadeb ||'</nrctadeb>'||    
                        '<nrctacrd>'|| rw_lancamentos.nrctacrd ||'</nrctacrd>'|| 
                        '<vllanmto>'|| rw_lancamentos.vllanmto ||'</vllanmto>'|| 
                        '<cdhistor_padrao>'|| rw_lancamentos.cdhistor_padrao ||'</cdhistor_padrao>'|| 
                        '<dslancamento>'|| rw_lancamentos.dslancamento ||'</dslancamento>'|| 
                        '<cdoperad>'|| rw_lancamentos.cdoperad ||'</cdoperad>'||  
                        '<dsoperador>'|| rw_lancamentos.dsoperador ||'</dsoperador>'||                   
                        '</registro>');   
        vr_count := vr_count + 1;                        
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Erro ao consultar Lancamentos '||
                       ': '||SQLERRM;
        RAISE vr_exc_erro;               
      END;                         
    END LOOP;
       
     pc_escreve_xml('</lancamentos><totreg>'||vr_count||'</totreg>');
    
    pc_escreve_xml('</Dados>',TRUE);
    pr_retxml := xmltype.createxml(vr_des_xml);        
      
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
                           
    
               
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na rotina que consulta os lancamentos.' || SQLERRM ;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_consulta_lancamentos;
    
                                                          
                          
end TELA_SLIP;
/
