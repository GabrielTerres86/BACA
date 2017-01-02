CREATE OR REPLACE PACKAGE CECRED.NPCB0002 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : NPCB0002
      Sistema  : Rotinas referentes a Nova Plataforma de Cobrança de Boletos
      Sigla    : NPCB
      Autor    : Renato Darosci - Supero
      Data     : Dezembro/2016.                   

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes a Nova Plataforma de Cobrança de Boletos
  ---------------------------------------------------------------------------------------------------------------*/
  
  --> Rotina para consultar os titulos CIP
  PROCEDURE pc_consultar_titulo_cip(pr_cdcooper      IN INTEGER    -- Cooperativa
                                   --,pr_nrdconta      IN INTEGER    -- Conta
                                   ,pr_dtmvtolt      IN DATE       -- Data de movimento ou data atual
                                   --,pr_idseqttl      IN INTEGER    -- Titular
                                   ,pr_cdagenci      IN INTEGER    -- Agência
                                   --,pr_nrdcaixa      IN INTEGER    -- Caixa
                                   ,pr_flmobile      IN INTEGER    -- Indicador origem Mobile
                                   ,pr_titulo1       IN NUMBER     -- FORMAT "99999,99999"
                                   ,pr_titulo2       IN NUMBER     -- FORMAT "99999,999999"
                                   ,pr_titulo3       IN NUMBER     -- FORMAT "99999,999999"
                                   ,pr_titulo4       IN NUMBER     -- FORMAT "9"
                                   ,pr_titulo5       IN NUMBER     -- FORMAT "zz,zzz,zzz,zzz999"
                                   ,pr_codigo_barras IN VARCHAR2   -- Codigo de Barras
                                   ,pr_cdoperad      IN VARCHAR2   -- Código do operador
                                   /*,pr_dsbenefic     OUT VARCHAR2  -- Descrição do beneficiário emitente
                                   ,pr_vlrtitulo     OUT NUMBER  -- Valor do título
                                   ,pr_vlrjuros       OUT NUMBER    -- Valor dos Juros
                                   ,pr_vlrmulta       OUT NUMBER    -- Valor da multa
                                   ,pr_vlrdescto     OUT NUMBER    -- Valor do desconto*/
                                   ,pr_nrctrlcs      OUT VARCHAR2  -- Numero do controle da consulta
					                         ,pr_tbTituloCIP   OUT NPCB0001.typ_reg_TituloCIP  -- TAB com os dados do Boleto
						                       --,pr_flblq_valor   OUT NUMBER	-- Flag para bloquear o valor de pagamento
                                   --,pr_fltitven      OUT NUMBER    -- Indicador Vencido						
					                         ,pr_des_erro      OUT VARCHAR2  -- Indicador erro OK/NOK
                                   ,pr_cdcritic      OUT NUMBER    -- Código do erro 
					                         ,pr_dscritic      OUT VARCHAR2); --Descricao do erro

END NPCB0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.NPCB0002 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : NPCB0002
      Sistema  : Rotinas referentes a Nova Plataforma de Cobrança de Boletos
      Sigla    : NPCB
      Autor    : Renato Darosci - Supero
      Data     : Dezembro/2016.                   Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas de transações da Nova Plataforma de Cobrança de Boletos

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/
  -- Declaração de variáveis/constantes gerais
  --> Declaração geral de exception
  vr_exc_erro        EXCEPTION;


  --> Rotina para consultar os titulos CIP
  PROCEDURE pc_consultar_titulo_cip(pr_cdcooper      IN INTEGER    -- Cooperativa
                                   --,pr_nrdconta      IN INTEGER    -- Conta
                                   ,pr_dtmvtolt      IN DATE       -- Data de movimento ou data atual
					                         --,pr_idseqttl      IN INTEGER    -- Titular
					                         ,pr_cdagenci      IN INTEGER    -- Agência
					                         --,pr_nrdcaixa      IN INTEGER    -- Caixa
						                       ,pr_flmobile      IN INTEGER    -- Indicador origem Mobile
					                         ,pr_titulo1       IN NUMBER     -- FORMAT "99999,99999"
                                   ,pr_titulo2       IN NUMBER     -- FORMAT "99999,999999"
                                   ,pr_titulo3       IN NUMBER     -- FORMAT "99999,999999"
                                   ,pr_titulo4       IN NUMBER     -- FORMAT "9"
                                   ,pr_titulo5       IN NUMBER     -- FORMAT "zz,zzz,zzz,zzz999"
                                   ,pr_codigo_barras IN VARCHAR2   -- Codigo de Barras
						                       ,pr_cdoperad      IN VARCHAR2   -- Código do operador
						                       /*,pr_dsbenefic	   OUT VARCHAR2  -- Descrição do beneficiário emitente
						                       ,pr_vlrtitulo	   OUT NUMBER	-- Valor do título
						                       ,pr_vlrjuros	     OUT NUMBER    -- Valor dos Juros
						                       ,pr_vlrmulta	     OUT NUMBER    -- Valor da multa
						                       ,pr_vlrdescto	   OUT NUMBER    -- Valor do desconto*/
						                       ,pr_nrctrlcs      OUT VARCHAR2  -- Numero do controle da consulta
					                         ,pr_tbTituloCIP   OUT NPCB0001.typ_reg_TituloCIP  -- TAB com os dados do Boleto
						                       --,pr_flblq_valor   OUT NUMBER	-- Flag para bloquear o valor de pagamento
                                   --,pr_fltitven      OUT NUMBER    -- Indicador Vencido						
					                         ,pr_des_erro      OUT VARCHAR2  -- Indicador erro OK/NOK
                                   ,pr_cdcritic      OUT NUMBER    -- Código do erro 
					                         ,pr_dscritic      OUT VARCHAR2) IS --Descricao do erro

  /* ..........................................................................
    
      Programa : pc_consultar_titulo_cip        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Renato Darosci(Supero)
      Data     : Dezembro/2016.                   Ultima atualizacao: --/--/----
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para consultar o titulo na CIP, realizar a gravação do 
                  retorno da consulta e retornar a tab com os dados recebidos
                  
      Alteração : 
        
    ..........................................................................*/
    
    /****************************/
    PRAGMA AUTONOMOUS_TRANSACTION;
    /****************************/
        
    ----------> VARIAVEIS <-----------
    vr_idrollout       INTEGER;
    vr_flbltcip        BOOLEAN := FALSE;
    vr_titulo1         NUMBER  := pr_titulo1; 
    vr_titulo2         NUMBER  := pr_titulo2; 
    vr_titulo3         NUMBER  := pr_titulo3; 
    vr_titulo4         NUMBER  := pr_titulo4; 
    vr_titulo5         NUMBER  := pr_titulo5;
    vr_codbarras       VARCHAR2(44) := pr_codigo_barras;
    vr_cdcritic        NUMBER;
    vr_dscritic        VARCHAR2(1000);
    vr_des_erro        VARCHAR2(3);
    vr_vlboleto        NUMBER;
    vr_tpconcip        NUMBER;
    vr_dsxmltit        CLOB;
    
  BEGIN   

     -- Inicializar o retorno como não-ok
     pr_des_erro := 'NOK';
     
     -- Ajustar o código de barras ou a linha digitável
     NPCB0001.pc_linha_codigo_barras(pr_titulo1  => vr_titulo1  
                                    ,pr_titulo2  => vr_titulo2  
                                    ,pr_titulo3  => vr_titulo3  
                                    ,pr_titulo4  => vr_titulo4  
                                    ,pr_titulo5  => vr_titulo5  
                                    ,pr_codbarra => vr_codbarras
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
     
     -- Se ocorreu erro ao configurar a linha digitável / código de barras
     IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
       RAISE vr_exc_erro;
     END IF;
     
     -- Quando uma Instituição autorizada pelo BACEN a atuar como destinatária emissora de Boletos 
     -- de Pagamento e não foi concedido um código de compensação, as instituições devem reconhecer 
     -- o ISPB da Instituição através do detalhamento do Boleto de Pagamento contido na base assim 
     -- como a sua identificação no código de barras gerado. O ISPB deve estar contido na posição 
     -- 10 a 19 e nas três primeiras posições o valor fixo 988, na posição 04 a 04 deve estar fixo 
     -- o valor Zero, e na posição 06 à 09 devem estar preenchidos com o valor Zero. Neste cenário, 
     -- o código de barras não terá em sua composição o valor do Boleto de Pagamento, o fator de 
     -- vencimento e o código da moeda.
     -- Dessa forma verificamos se o código de barras inicia com 998 para neste caso permitir a 
     -- consulta na CIP sem validar pelo Rollout da Nova Plataforma de Cobrança
     IF SUBSTR(vr_codbarras,1,3) = 988 THEN
       vr_flbltcip := TRUE;
     ELSE 
       -- Reserva o valor do boleto
       vr_vlboleto := TO_NUMBER(SUBSTR(gene0002.fn_mask(vr_titulo5,'99999999999999'),5,10)) / 100;
     
       -- Verificar se o titulo está na faixa de rollout
       vr_idrollout := NPCB0001.fn_verifica_rollout(pr_cdcooper => pr_cdcooper
                                                   ,pr_dtmvtolt => pr_dtmvtolt
                                                   ,pr_vltitulo => vr_vlboleto
                                                   ,pr_tpdregra => 2);
                                                   
       -- Verifica se está na faixa de rollout
       IF vr_idrollout = 1 THEN
         vr_flbltcip := TRUE;
       END IF;
     END IF;
     
     -- Se é um titulo CIP... realiza a consulta via WS das informações
     IF NOT vr_flbltcip THEN
       -- Retornar os valores em branco indicando que está fora da faixa de rollaut
       /*pr_dsbenefic   := NULL;
       pr_vlrtitulo   := NULL;
       pr_vlrjuros    := NULL;
       pr_vlrmulta    := NULL;
       pr_vlrdescto   := NULL;*/
       pr_nrctrlcs    := NULL;
       --pr_flblq_valor := NULL;
       --pr_fltitven    := NULL;
     
       -- Garantir que não retorne dados tbm na collection
       pr_tbTituloCIP := NULL;
     
       -- Sai da rotina de consulta 
       RETURN;
     
     ELSE
       
       -- Montar o número de controle do participante (código de controle da consulta)
       pr_nrctrlcs := NPCB0001.fn_montar_NumCtrlPart(pr_cdbarras => vr_codbarras
                                                    ,pr_cdagenci => pr_cdagenci
                                                    ,pr_flmobile => pr_flmobile);
     
       -- CONSULTAR O TITULO NA CIP VIA WEBSERVICE
       NPCB0003.pc_wscip_requisitar_titulo(pr_cdlegado => 'LEG'   -- TEMPORARIO
                                          ,pr_nrispbif => 5463212 -- TEMPORARIO
                                          ,pr_idtitdda => NULL    -- TEMPORARIO
                                          ,pr_dsxmltit => vr_dsxmltit
                                          ,pr_tpconcip => vr_tpconcip
                                          ,pr_des_erro => vr_des_erro
                                          ,pr_dscritic => vr_dscritic);
       
       -- Se retornar o indicador de erro da rotina 
       IF vr_des_erro = 'NOK' THEN
         RAISE vr_exc_erro;
       END IF;
     
       -- Converter o XML retornado
       NPCB0003.pc_xmlsoap_extrair_titulo(pr_dsxmltit => vr_dsxmltit
                                         ,pr_tbtitulo => pr_tbTituloCIP
                                         ,pr_des_erro => vr_des_erro
                                         ,pr_dscritic => vr_dscritic);
       
       -- Se retornar o indicador de erro da rotina de extração de título
       IF vr_des_erro = 'NOK' THEN
         RAISE vr_exc_erro;
       END IF;
       
       -- Inserir o registro consultado na tabela de registro de consulta
       BEGIN
         INSERT INTO tbcobran_consulta_titulo(nrctrlcs
                                             ,nrdident
                                             ,cdcooper
                                             ,cdagenci
                                             ,dtmvtolt
                                             ,tpconsulta
                                             ,dhconsulta
                                             ,dscodbar
                                             ,vltitulo
                                             ,nrispbds
                                             ,dsxml
                                             ,cdcanal
                                             ,cdoperad)
                                      VALUES (pr_nrctrlcs                 -- nrctrlcs
                                             ,pr_tbTituloCIP.NumIdentcTit -- nrdident
                                             ,pr_cdcooper                 -- cdcooper
                                             ,pr_cdagenci                 -- cdagenci
                                             ,pr_dtmvtolt                 -- dtmvtolt
                                             ,vr_tpconcip                 -- tpconsulta
                                             ,SYSDATE                     -- dhconsulta
                                             ,pr_tbTituloCIP.NumCodBarras -- dscodbar
                                             ,pr_tbTituloCIP.VlrTit       -- vltitulo
                                             ,pr_tbTituloCIP.ISPBPartDestinatario -- nrispbds
                                             ,vr_dsxmltit                 -- dsxml
                                             ,0                           -- cdcanal -- ver renato
                                             ,pr_cdoperad );              -- cdoperad
       
       EXCEPTION
         WHEN OTHERS THEN
           vr_dscritic := 'Erro ao registrar consulta CIP: '||SQLERRM;
           RAISE vr_exc_erro;
       END;
       
     END IF;
    
     -- Encerrar com commit devido a rotina pragma
     COMMIT;
  
  EXCEPTION 
     WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Devolvemos código e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;

      -- Efetuar rollback
      ROLLBACK;
  END pc_consultar_titulo_cip;



END NPCB0002;
/
