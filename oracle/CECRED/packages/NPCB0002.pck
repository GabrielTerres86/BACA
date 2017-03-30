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
  PROCEDURE pc_consultar_valor_titulo(pr_cdcooper       IN NUMBER       -- Cooperativa
                                     ,pr_nrdconta       IN NUMBER       -- Número da conta
                                     ,pr_cdagenci       IN NUMBER       -- Agência     
                                     ,pr_nrdcaixa       IN NUMBER       -- Número do caixa  
                                     ,pr_idseqttl       IN NUMBER       -- Titular da conta
                                     ,pr_flmobile       IN NUMBER       -- Indicador origem Mobile
                                     ,pr_titulo1        IN NUMBER       -- FORMAT "99999,99999"
                                     ,pr_titulo2        IN NUMBER       -- FORMAT "99999,999999"
                                     ,pr_titulo3        IN NUMBER       -- FORMAT "99999,999999"
                                     ,pr_titulo4        IN NUMBER       -- FORMAT "9"
                                     ,pr_titulo5        IN NUMBER       -- FORMAT "zz,zzz,zzz,zzz999"
                                     ,pr_codigo_barras  IN VARCHAR2     -- Codigo de Barras
                                     ,pr_cdoperad       IN VARCHAR2     -- Código do operador
                                     ,pr_idorigem       IN NUMBER       -- Origem da requisição
                                     ,pr_nrdocbenf     OUT NUMBER       -- Documento do beneficiário emitente
                                     ,pr_tppesbenf     OUT VARCHAR2     -- Tipo de pessoa beneficiaria
						                         ,pr_dsbenefic     OUT VARCHAR2     -- Descrição do beneficiário emitente
                                     ,pr_vlrtitulo     OUT NUMBER       -- Valor do título
                                     ,pr_vlrjuros      OUT NUMBER       -- Valor dos Juros
						                         ,pr_vlrmulta	     OUT NUMBER       -- Valor da multa
						                         ,pr_vlrdescto	   OUT NUMBER       -- Valor do desconto
						                         ,pr_cdctrlcs      OUT VARCHAR2     -- Numero do controle da consulta
 	 			  		                       ,pr_flblq_valor   OUT NUMBER	      -- Flag para bloquear o valor de pagamento
                                     ,pr_fltitven      OUT NUMBER       -- Flag indicador de titulo vencido
	  				                         ,pr_des_erro      OUT VARCHAR2     -- Indicador erro OK/NOK
                                     ,pr_cdcritic      OUT NUMBER       -- Código do erro 
			  		                         ,pr_dscritic      OUT VARCHAR2);   -- Descricao do erro 
  
  --> Rotina para consultar os titulos CIP
  PROCEDURE pc_consultar_titulo_cip(pr_cdcooper       IN INTEGER     -- Cooperativa
                                   ,pr_nrdconta       IN NUMBER       -- Número da conta
                                   ,pr_cdagenci       IN INTEGER     -- Agência
                                   ,pr_flmobile       IN INTEGER     -- Indicador origem Mobile
					                         ,pr_dtmvtolt       IN DATE         -- Data de movimento
                                   ,pr_titulo1        IN NUMBER      -- FORMAT "99999,99999"
                                   ,pr_titulo2        IN NUMBER      -- FORMAT "99999,999999"
                                   ,pr_titulo3        IN NUMBER      -- FORMAT "99999,999999"
                                   ,pr_titulo4        IN NUMBER      -- FORMAT "9"
                                   ,pr_titulo5        IN NUMBER      -- FORMAT "zz,zzz,zzz,zzz999"
                                   ,pr_codigo_barras  IN VARCHAR2    -- Codigo de Barras
                                   ,pr_cdoperad       IN VARCHAR2    -- Código do operador
                                   ,pr_idorigem       IN NUMBER       -- Origem da requisição
                                   ,pr_nrdocbenf     OUT NUMBER      -- Documento do beneficiário emitente
                                   ,pr_tppesbenf     OUT VARCHAR2    -- Tipo de pessoa beneficiaria
						                       ,pr_dsbenefic     OUT VARCHAR2    -- Descrição do beneficiário emitente
                                   ,pr_vlrtitulo     OUT NUMBER      -- Valor do título
                                   ,pr_vlrjuros      OUT NUMBER      -- Valor dos Juros
                                   ,pr_vlrmulta      OUT NUMBER      -- Valor da multa
                                   ,pr_vlrdescto     OUT NUMBER      -- Valor do desconto
                                   ,pr_cdctrlcs      OUT VARCHAR2    -- Numero do controle da consulta
					                         ,pr_tbTituloCIP   OUT NPCB0001.typ_reg_TituloCIP  -- TAB com os dados do Boleto
						                       ,pr_flblq_valor   OUT NUMBER	     -- Flag para bloquear o valor de pagamento			
					                         ,pr_fltitven      OUT NUMBER      -- Flag indicando que o título está vencido
					                         ,pr_des_erro      OUT VARCHAR2    -- Indicador erro OK/NOK
                                   ,pr_cdcritic      OUT NUMBER      -- Código do erro 
					                         ,pr_dscritic      OUT VARCHAR2);  -- Descricao do erro

  --> Rotina para enviar titulo para CIP de forma online
  PROCEDURE pc_registra_tit_cip_online (pr_cdcooper     IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                       ,pr_nrdconta     IN crapass.nrdconta%TYPE --> Numer da conta do cooperado
                                       ,pr_cdcritic    OUT INTEGER               --> Codigo da critico
                                       ,pr_dscritic    OUT VARCHAR2              --> Descrição da critica
                                       ) ;

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
  PROCEDURE pc_consultar_valor_titulo(pr_cdcooper       IN NUMBER       -- Cooperativa
                                     ,pr_nrdconta       IN NUMBER       -- Número da conta
                                     ,pr_cdagenci       IN NUMBER       -- Agência     
                                     ,pr_nrdcaixa       IN NUMBER       -- Número do caixa  
                                     ,pr_idseqttl       IN NUMBER       -- Titular da conta
                                     ,pr_flmobile       IN NUMBER       -- Indicador origem Mobile
                                     ,pr_titulo1        IN NUMBER       -- FORMAT "99999,99999"
                                     ,pr_titulo2        IN NUMBER       -- FORMAT "99999,999999"
                                     ,pr_titulo3        IN NUMBER       -- FORMAT "99999,999999"
                                     ,pr_titulo4        IN NUMBER       -- FORMAT "9"
                                     ,pr_titulo5        IN NUMBER       -- FORMAT "zz,zzz,zzz,zzz999"
                                     ,pr_codigo_barras  IN VARCHAR2     -- Codigo de Barras
                                     ,pr_cdoperad       IN VARCHAR2     -- Código do operador
                                     ,pr_idorigem       IN NUMBER       -- Origem da requisição
                                     ,pr_nrdocbenf     OUT NUMBER       -- Documento do beneficiário emitente
                                     ,pr_tppesbenf     OUT VARCHAR2     -- Tipo de pessoa beneficiaria
						                         ,pr_dsbenefic     OUT VARCHAR2     -- Descrição do beneficiário emitente
                                     ,pr_vlrtitulo     OUT NUMBER       -- Valor do título
                                     ,pr_vlrjuros      OUT NUMBER       -- Valor dos Juros
						                         ,pr_vlrmulta	     OUT NUMBER       -- Valor da multa
						                         ,pr_vlrdescto	   OUT NUMBER       -- Valor do desconto
						                         ,pr_cdctrlcs      OUT VARCHAR2     -- Numero do controle da consulta
 	 			  		                       ,pr_flblq_valor   OUT NUMBER	      -- Flag para bloquear o valor de pagamento
                                     ,pr_fltitven      OUT NUMBER       -- Flag indicador de titulo vencido
	  				                         ,pr_des_erro      OUT VARCHAR2     -- Indicador erro OK/NOK
                                     ,pr_cdcritic      OUT NUMBER       -- Código do erro 
			  		                         ,pr_dscritic      OUT VARCHAR2) IS -- Descricao do erro 
                                    
    -- Variáveis
    rw_crapdat     BTCH0001.cr_crapdat%ROWTYPE;       
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(1000);  
    vr_des_erro    VARCHAR2(3);
    vr_tbtitulocip NPCB0001.typ_reg_titulocip;        
    vr_nrdocbenf   NUMBER;
    vr_tppesbenf   VARCHAR2(1);
    vr_dsbenefic   VARCHAR2(100);
    vr_vlrtitulo   NUMBER;
    vr_vlrjuros    NUMBER;
    vr_vlrmulta    NUMBER;
    vr_vlrdescto   NUMBER;
    vr_flgtitven   NUMBER;
    vr_cdctrlcs    VARCHAR2(50);   
    vr_flblq_valor NUMBER;
            
  BEGIN
               
    pr_des_erro := 'NOK';

    -- Buscar a data do sistema
    OPEN  BTCH0001.cr_crapdat(pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se nao encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
rw_crapdat.dtmvtolt := TRUNC(SYSDATE); -- ver renato
    -- Chamar a rotina de consulta dos dados      
    NPCB0002.pc_consultar_titulo_cip(pr_cdcooper      => pr_cdcooper 
                                    ,pr_nrdconta      => pr_nrdconta      
                                    ,pr_cdagenci      => pr_cdagenci       
                                    ,pr_flmobile      => pr_flmobile  
                                    ,pr_dtmvtolt      => rw_crapdat.dtmvtolt
                                    ,pr_titulo1       => pr_titulo1        
                                    ,pr_titulo2       => pr_titulo2        
                                    ,pr_titulo3       => pr_titulo3        
                                    ,pr_titulo4       => pr_titulo4        
                                    ,pr_titulo5       => pr_titulo5        
                                    ,pr_codigo_barras => pr_codigo_barras  
                                    ,pr_cdoperad      => pr_cdoperad  
                                    ,pr_idorigem      => pr_idorigem     
                                    ,pr_nrdocbenf     => vr_nrdocbenf
                                    ,pr_tppesbenf     => vr_tppesbenf
                                    ,pr_dsbenefic     => vr_dsbenefic      
                                    ,pr_vlrtitulo     => vr_vlrtitulo      
                                    ,pr_vlrjuros      => vr_vlrjuros       
                                    ,pr_vlrmulta      => vr_vlrmulta       
                                    ,pr_vlrdescto     => vr_vlrdescto      
                                    ,pr_cdctrlcs      => vr_cdctrlcs       
                                    ,pr_tbtitulocip   => vr_tbtitulocip    
                                    ,pr_flblq_valor   => vr_flblq_valor    
                                    ,pr_fltitven      => vr_flgtitven
                                    ,pr_des_erro      => vr_des_erro       
                                    ,pr_cdcritic      => vr_cdcritic       
                                    ,pr_dscritic      => vr_dscritic);     
                                         
    -- Se der erro não retorna informações   
    IF vr_des_erro = 'NOK' THEN
      -- Não retornar as informações do título  
      -- Retornar os valores consultados na CIP
      pr_nrdocbenf   := NULL;
      pr_tppesbenf   := NULL;
      pr_dsbenefic   := NULL;
      pr_vlrtitulo   := NULL;
      pr_vlrjuros    := NULL;
      pr_vlrmulta    := NULL;
      pr_fltitven    := NULL; 
      pr_vlrdescto   := NULL; 
      pr_cdctrlcs    := vr_cdctrlcs;
      pr_flblq_valor := NULL;
      
      -- Retornar erro 
      pr_des_erro := 'NOK';
      RAISE vr_exc_erro;
    
    -- Se não encontrou titulo na CIP e não ocorreu erro (normalmente por estar fora do rollout)
    ELSIF vr_tbtitulocip.NumCtrlPart IS NULL THEN

      -- Busca o valor do titulo de vencimento
      CXON0014.pc_retorna_vlr_tit_vencto(pr_cdcooper      => pr_cdcooper
                                        ,pr_nrdconta      => pr_nrdcaixa
                                        ,pr_idseqttl      => pr_idseqttl
                                        ,pr_cdagenci      => pr_cdagenci
                                        ,pr_nrdcaixa      => pr_nrdcaixa
                                        ,pr_titulo1       => pr_titulo1
                                        ,pr_titulo2       => pr_titulo2
                                        ,pr_titulo3       => pr_titulo3
                                        ,pr_titulo4       => pr_titulo4
                                        ,pr_titulo5       => pr_titulo5
                                        ,pr_codigo_barras => pr_codigo_barras
                                        ,pr_vlfatura      => vr_vlrtitulo
                                        ,pr_vlrjuros      => vr_vlrjuros
                                        ,pr_vlrmulta      => vr_vlrmulta
                                        ,pr_fltitven      => vr_flgtitven
                                        ,pr_des_erro      => vr_des_erro
                                        ,pr_dscritic      => vr_dscritic);
      
      -- Se ocorreu erro 
      IF vr_des_erro = 'NOK' OR vr_dscritic IS NOT NULL THEN
        pr_des_erro := 'NOK';
        RAISE vr_exc_erro;
      END IF;
      
      -- Retornar as variáveis
      pr_nrdocbenf   := NULL;
      pr_tppesbenf   := NULL;
      pr_dsbenefic   := NULL;
      pr_vlrtitulo   := vr_vlrtitulo;
      pr_vlrjuros    := vr_vlrjuros;
      pr_vlrmulta    := vr_vlrmulta;
      pr_fltitven    := vr_flgtitven;
      pr_vlrdescto   := NULL;
      pr_cdctrlcs    := NULL;
      pr_flblq_valor := 0;
      
    ELSE -- Se efetuou a busca na CIP com sucesso e encontrou registro
      -- Retornar os valores consultados na CIP
      pr_nrdocbenf   := vr_nrdocbenf;
      pr_tppesbenf   := vr_tppesbenf;
      pr_dsbenefic   := vr_dsbenefic;
      pr_vlrtitulo   := vr_vlrtitulo;
      pr_vlrjuros    := vr_vlrjuros;
      pr_vlrmulta    := vr_vlrmulta;
      pr_vlrdescto   := vr_vlrdescto;
      pr_cdctrlcs    := vr_cdctrlcs;
      pr_flblq_valor := vr_flblq_valor;
      -- Títulos CIP poderão ser pagos vencidos, mas iremos retornar o flag para bloquear agendamento
      pr_fltitven    := vr_flgtitven; 
      
      -- Realizar as pré-validações do título
      NPCB0001.pc_valid_titulo_npc(pr_cdcooper    => pr_cdcooper
                                  ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                  ,pr_cdctrlcs    => vr_cdctrlcs
                                  ,pr_tbtitulocip => vr_tbtitulocip
                                  ,pr_cdcritic    => vr_cdcritic
                                  ,pr_dscritic    => vr_dscritic);
      
      -- Se ocorreu erro 
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        pr_des_erro := 'NOK';
        RAISE vr_exc_erro;
      END IF;
      
    END IF;
    
    -- Retornar o ok, informando sucesso na execução 
    pr_des_erro := 'OK';
    
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
  END pc_consultar_valor_titulo;
  
  --> Rotina para consultar os titulos CIP
  PROCEDURE pc_consultar_titulo_cip(pr_cdcooper       IN INTEGER      -- Cooperativa
					                         ,pr_nrdconta       IN NUMBER       -- Número da conta
                                   ,pr_cdagenci       IN INTEGER      -- Agência
					                         ,pr_flmobile       IN INTEGER      -- Indicador origem Mobile
					                         ,pr_dtmvtolt       IN DATE         -- Data de movimento
                                   ,pr_titulo1        IN NUMBER       -- FORMAT "99999,99999"
                                   ,pr_titulo2        IN NUMBER       -- FORMAT "99999,999999"
                                   ,pr_titulo3        IN NUMBER       -- FORMAT "99999,999999"
                                   ,pr_titulo4        IN NUMBER       -- FORMAT "9"
                                   ,pr_titulo5        IN NUMBER       -- FORMAT "zz,zzz,zzz,zzz999"
                                   ,pr_codigo_barras  IN VARCHAR2     -- Codigo de Barras
						                       ,pr_cdoperad       IN VARCHAR2     -- Código do operador
                                   ,pr_idorigem       IN NUMBER       -- Origem da requisição
                                   ,pr_nrdocbenf     OUT NUMBER       -- Documento do beneficiário emitente
                                   ,pr_tppesbenf     OUT VARCHAR2     -- Tipo de pessoa beneficiaria
						                       ,pr_dsbenefic	   OUT VARCHAR2     -- Descrição do beneficiário emitente
						                       ,pr_vlrtitulo	   OUT NUMBER	      -- Valor do título
						                       ,pr_vlrjuros	     OUT NUMBER       -- Valor dos Juros
						                       ,pr_vlrmulta	     OUT NUMBER       -- Valor da multa
						                       ,pr_vlrdescto	   OUT NUMBER       -- Valor do desconto*/
						                       ,pr_cdctrlcs      OUT VARCHAR2     -- Numero do controle da consulta
					                         ,pr_tbTituloCIP   OUT NPCB0001.typ_reg_TituloCIP  -- TAB com os dados do Boleto
						                       ,pr_flblq_valor   OUT NUMBER	      -- Flag para bloquear o valor de pagamento				
                                   ,pr_fltitven      OUT NUMBER       -- Flag indicando que o título está vencido
					                         ,pr_des_erro      OUT VARCHAR2     -- Indicador erro OK/NOK
                                   ,pr_cdcritic      OUT NUMBER       -- Código do erro 
					                         ,pr_dscritic      OUT VARCHAR2) IS -- Descricao do erro

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
    ----------> CURSORES <-----------   
    -- Buscar a cidade da agencia
    CURSOR cr_crapage IS
      SELECT a.cdcidade
        FROM crapcaf a
           , crapmun m
           , crapage t 
       WHERE TRIM(a.nmcidade) = TRIM(m.dscidade)
         AND m.idcidade = t.idcidade
         AND t.cdagenci = pr_cdagenci 
         AND t.cdcooper = pr_cdcooper;
    
    -- Buscar a cidade do cooperado
    CURSOR cr_crapenc IS 
      SELECT c.cdcidade
        FROM crapcaf c
           , crapenc t
       WHERE TRIM(c.nmcidade) = TRIM(t.nmcidade)
         AND t.nmcidade IS NOT NULL
         AND t.tpendass IN (9,10) -- Comercial / Residencial
         AND t.nrdconta = pr_nrdconta
         AND t.cdcooper = pr_cdcooper
       ORDER BY t.tpendass DESC;
    
    ----------> VARIAVEIS <-----------   
    vr_idrollout       INTEGER;
    vr_flbltcip        BOOLEAN := FALSE;
    vr_titulo1         NUMBER  := pr_titulo1; 
    vr_titulo2         NUMBER  := pr_titulo2; 
    vr_titulo3         NUMBER  := pr_titulo3; 
    vr_titulo4         NUMBER  := pr_titulo4; 
    vr_titulo5         NUMBER  := pr_titulo5;
    vr_codbarras       VARCHAR2(44) := pr_codigo_barras;
    vr_cdctrlcs        VARCHAR2(50);
    vr_cdcritic        NUMBER;
    vr_dscritic        VARCHAR2(1000);
    vr_des_erro        VARCHAR2(3);
    vr_vlboleto        NUMBER;
    vr_tpconcip        NUMBER;
    vr_xmltit          CLOB;
    vr_nrdrowid        VARCHAR2(50);
    vr_cdcidade        crapcaf.cdcidade%TYPE;
    
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
     
     -- Ver renato -- Apenas para teste.... deve ser removido
     vr_flbltcip := TRUE;
     
     -- Se não é um titulo CIP... não realiza a consulta via WS das informações
     IF NOT vr_flbltcip THEN
       -- Retornar os valores em branco indicando que está fora da faixa de rollaut
       pr_nrdocbenf   := NULL;
       pr_tppesbenf   := NULL;
       pr_dsbenefic   := NULL;
       pr_vlrtitulo   := NULL;
       pr_vlrjuros    := NULL;
       pr_vlrmulta    := NULL;
       pr_vlrdescto   := NULL;
       pr_cdctrlcs    := NULL;
       pr_flblq_valor := NULL;
       
       -- Garantir que não retorne dados tbm na collection
       pr_tbTituloCIP := NULL;
            
       pr_des_erro := 'OK';
       
       -- Sai da rotina de consulta 
       RETURN;
     
     ELSE
       
       -- Montar o número de controle do participante (código de controle da consulta)
       vr_cdctrlcs := NPCB0001.fn_montar_NumCtrlPart(pr_cdbarras => vr_codbarras
                                                    ,pr_cdagenci => pr_cdagenci
                                                    ,pr_flmobile => pr_flmobile);
       
       -- Retornar o número de controle de consulta
       pr_cdctrlcs := vr_cdctrlcs;
       
       /* BUSCAR O CÓDIGO DO MUNICIPIO DE PAGAMENTO */
       -- Se o pagamento foi via Internet Banking ou Mobile
       IF pr_cdagenci = 90 OR pr_flmobile = 1 THEN
         -- Deve buscar o municipio de residencia do cooperado
         OPEN  cr_crapenc;
         FETCH cr_crapenc INTO vr_cdcidade;
         
         -- Se não for encontrado registro
         IF cr_crapenc%NOTFOUND THEN
           vr_cdcidade := NULL;
         END IF;
         
         -- Fechar o cursor
         CLOSE cr_crapenc;
       ELSE
         -- Deve buscar a cidade da agencia
         OPEN  cr_crapage;
         FETCH cr_crapage INTO vr_cdcidade;
         
         -- Se não encontrou cidade
         IF cr_crapage%NOTFOUND THEN
           vr_cdcidade := NULL;
         END IF;
         
         -- Fechar o cursor 
         CLOSE cr_crapage;
       END IF;
       
       -- CONSULTAR O TITULO NA CIP VIA WEBSERVICE
       NPCB0003.pc_wscip_requisitar_titulo(pr_cdcooper => pr_cdcooper
                                          ,pr_cdctrlcs => vr_cdctrlcs
                                          ,pr_cdbarras => vr_codbarras
                                          ,pr_dtmvtolt => pr_dtmvtolt
                                          ,pr_cdcidade => vr_cdcidade
                                          ,pr_dsxmltit => vr_xmltit
                                          ,pr_tpconcip => vr_tpconcip
                                          ,pr_des_erro => vr_des_erro
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
       
       -- Se retornar o indicador de erro da rotina 
       IF vr_des_erro = 'NOK' THEN
         
         -- Gerar log para a tela ver log, quando há número de conta
         IF pr_nrdconta IS NOT NULL THEN
           
           -- Incluso rollback neste ponto, apenas para garantir que em futuras alterações não 
           -- sejam inclusas operações DML e acabem por fim comitando informações indevidas
           ROLLBACK;
           
           -- Chamar rotina generica para criação de log - LOGTEL
           GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                               ,pr_cdoperad => pr_cdoperad
                               ,pr_dscritic => vr_cdcritic||'-'||vr_dscritic
                               ,pr_dsorigem => GENE0001.vr_vet_des_origens(pr_idorigem)
                               ,pr_dstransa => 'Consultar titulo NPC'
                               ,pr_dttransa => TRUNC(SYSDATE)
                               ,pr_flgtrans => 0 -- ERRO/FALSE
                               ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                               ,pr_idseqttl => 1
                               ,pr_nmdatela => 'NPCB0000'
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrdrowid => vr_nrdrowid);
         
           -- Realiza o commit para gravar as informações da VERLOG
           COMMIT;
         
         END IF;
       
         RAISE vr_exc_erro;
       END IF;
     
       -- Converter o XML retornado
       NPCB0003.pc_xmlsoap_extrair_titulo(pr_dsxmltit => vr_xmltit
                                         ,pr_tbtitulo => pr_tbTituloCIP
                                         ,pr_des_erro => vr_des_erro
                                         ,pr_dscritic => vr_dscritic);
       
       -- Se retornar o indicador de erro da rotina de extração de título
       IF vr_des_erro = 'NOK' THEN
         RAISE vr_exc_erro;
       END IF;
       
       -- Inserir o registro consultado na tabela de registro de consulta
       BEGIN
         INSERT INTO tbcobran_consulta_titulo(cdctrlcs
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
                                      VALUES (vr_cdctrlcs                 -- cdctrlcs
                                             ,pr_tbTituloCIP.NumIdentcTit -- nrdident
                                             ,pr_cdcooper                 -- cdcooper
                                             ,pr_cdagenci                 -- cdagenci
                                             ,pr_dtmvtolt                 -- dtmvtolt
                                             ,vr_tpconcip                 -- tpconsulta
                                             ,SYSDATE                     -- dhconsulta
                                             ,pr_tbTituloCIP.NumCodBarras -- dscodbar
                                             ,pr_tbTituloCIP.VlrTit       -- vltitulo
                                             ,pr_tbTituloCIP.ISPBPartDestinatario -- nrispbds
                                             ,vr_xmltit                   -- dsxml
                                             ,pr_idorigem                           -- cdcanal -- ver renato
                                             ,pr_cdoperad );              -- cdoperad
       
       EXCEPTION
         WHEN OTHERS THEN
           vr_dscritic := 'Erro ao registrar consulta CIP: '||SQLERRM;
           RAISE vr_exc_erro;
       END;
       
       -- Retornar o doc do beneficiário
       pr_nrdocbenf := TRIM(pr_tbTituloCIP.CNPJ_CPFBenfcrioOr);   -- Documento do Beneficiário Original
       
       -- Retornar o tipo da pessoa do beneficiário
       pr_tppesbenf := TRIM(pr_tbTituloCIP.TpPessoaBenfcrioOr);   -- Tipo Pessoa do Beneficiário Original
       
       -- Retornar o nome do beneficiário
       pr_dsbenefic := NVL(TRIM(pr_tbTituloCIP.NomFantsBenfcrioOr)   -- Nome Fantasia do Beneficiário Original
                          ,TRIM(pr_tbTituloCIP.Nom_RzSocBenfcrioOr));-- Razão Social do Beneficiário Original
       
       -- Se não permitir pagamento parcial e não permitir valor divergente (3-Não aceitar pagamento com o valor divergente)
       IF pr_tbTituloCIP.IndrPgtoParcl = 'N' AND pr_tbTituloCIP.TpAutcRecbtVlrDivgte = '3' THEN
         -- Definir os valores do título
         NPCB0001.pc_valor_calc_titulo_npc(pr_dtmvtolt  => pr_dtmvtolt
                                          ,pr_tbtitulo  => pr_tbTituloCIP
                                          ,pr_vlrtitulo => pr_vlrtitulo   -- Retornar valor do título
                                          ,pr_vlrjuros  => pr_vlrjuros    -- Retornar valor dos juros
                                          ,pr_vlrmulta  => pr_vlrmulta    -- Retornar valor da multa
                                          ,pr_vlrdescto => pr_vlrdescto); -- Retornar valor de desconto
         
         --> Se valor estiver diferente retornar critica
        IF nvl(pr_vlrtitulo,0) = 0 THEN
          vr_dscritic := 'Problemas ao buscar valor do titulo.';
          RAISE vr_exc_erro;
        END IF;
         
         -- Indicar que não deve permitir alteração do valor do pagamento
         pr_flblq_valor := 1;
       ELSE 
         -- Define o valor do titulo como zero, pois o valor deve ser informado em tela pelo usuário
         pr_vlrtitulo := 0;       
         -- Indicar que deve permitir alteração do valor do pagamento para que o mesmo possa ser informado
         pr_flblq_valor := 0;
       END IF;
       
       -- Verifica se o título está vencidos
       IF pr_dtmvtolt > pr_tbTituloCIP.DtVencTit THEN
         -- Indicar que o título está vencido
         pr_fltitven := 1;
       ELSE
         -- Indicar que o título NÃO está vencido
         pr_fltitven := 0;
       END IF;
     END IF;
     
     pr_des_erro := 'OK';
     
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
  
  --> Rotina para enviar titulo para CIP de forma online
  PROCEDURE pc_registra_tit_cip_online (pr_cdcooper     IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                       ,pr_nrdconta     IN crapass.nrdconta%TYPE --> Numer da conta do cooperado
                                       ,pr_cdcritic    OUT INTEGER               --> Codigo da critico
                                       ,pr_dscritic    OUT VARCHAR2              --> Descrição da critica
                                       ) IS
  /* ..........................................................................
    
      Programa : pc_registra_tit_cip_online        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Janeiro/2017.                   Ultima atualizacao: 24/01/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para enviar titulo para CIP de forma online
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    ----------> VARIAVEIS <-----------
    vr_dscritic       VARCHAR2(4000);
    vr_cdcritic       INTEGER;
    vr_exc_erro       EXCEPTION;
    
    vr_dsplsql        VARCHAR2(10000);
    vr_jobname        VARCHAR2(100);
    
    
    
  BEGIN    
    
    
    vr_jobname := 'JB618_'||pr_nrdconta||'$';
    vr_dsplsql := 'DECLARE
                     vr_cdcritic integer; 
                     vr_dscritic varchar2(400);
                   BEGIN
                   pc_crps618(pr_cdcooper   => '||pr_cdcooper||
                             ',pr_nrdconta  => '||pr_nrdconta||
                             ',pr_cdcritic  => vr_cdcritic '||
                             ',pr_dscritic  => vr_dscritic );
                   end;';
    
    gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper, 
                           pr_cdprogra => 'NPCB0002', 
                           pr_dsplsql  => vr_dsplsql, 
                           pr_dthrexe  => NULL, 
                           pr_interva  => NULL, 
                           pr_jobname  => vr_jobname, 
                           pr_des_erro => vr_dscritic );
                           
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Nao foi possivel enviar titulo cip online: '||SQLERRM; 
  END pc_registra_tit_cip_online;

END NPCB0002;
/
