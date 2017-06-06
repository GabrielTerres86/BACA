CREATE OR REPLACE PACKAGE CECRED.TELA_MOVRGP AS

   /*
   Programa: TELA_MOVRGP                          antigo:
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Jonata - RKAM
   Data    : Maio/2017                       Ultima atualizacao:  

   Dados referentes ao programa:

   Frequencia: Diario (on-line).
   Objetivo  : Mostrar a tela MOVGRP para permitir o lan�amento manual de contratos para gera��o das informa��es do Doc3040.

   Alteracoes: 
   */  
   
   PROCEDURE pc_carrega_cooperativas(pr_cddopcao IN VARCHAR2     --N�mero da conta
                                    ,pr_xmllog   IN VARCHAR2      --XML com informa��es de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER  --C�digo da cr�tica
                                    ,pr_dscritic OUT VARCHAR2     --Descri��o da cr�tica
                                    ,pr_retxml   IN OUT NOCOPY XMLType --Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2     --Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2);   --Saida OK/NOK          
                                   
   PROCEDURE pc_carrega_campo_produtos(pr_cdcopsel IN crapcop.cdcooper%TYPE --C�digo da cooperativa selecionada
                                      ,pr_cddopcao IN VARCHAR2      --N�mero da conta
                                      ,pr_xmllog   IN VARCHAR2      --XML com informa��es de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER  --C�digo da cr�tica
                                      ,pr_dscritic OUT VARCHAR2     --Descri��o da cr�tica
                                      ,pr_retxml   IN OUT NOCOPY XMLType --Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2     --Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2);   --Saida OK/NOK                                   
   
   PROCEDURE pc_carrega_movimentos(pr_cdcopsel IN crapcop.cdcooper%TYPE --C�digo da cooperativa selecionada
                                  ,pr_idproduto IN tbrisco_provisgarant_prodt.idproduto%TYPE --C�digo do produto
                                  ,pr_dtrefere IN VARCHAR2      --Data de refer�ncia
                                  ,pr_cddopcao IN VARCHAR2      --N�mero da conta
                                  ,pr_nrregist IN INTEGER       --Quantidade de registros                            
                                  ,pr_nriniseq IN INTEGER       --Qunatidade inicial
                                  ,pr_xmllog   IN VARCHAR2      --XML com informa��es de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER  --C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2     --Descri��o da cr�tica
                                  ,pr_retxml   IN OUT NOCOPY XMLType --Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2     --Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2);  --Saida OK/NOK
                                     
   PROCEDURE pc_exportar(pr_cdcopsel IN crapcop.cdcooper%TYPE --C�digo da cooperativa selecionada
                        ,pr_idproduto IN tbrisco_provisgarant_prodt.idproduto%TYPE --C�digo do produto
                        ,pr_dtrefere IN VARCHAR2      --Data de refer�ncia
                        ,pr_cddopcao IN VARCHAR2      --N�mero da conta
                        ,pr_xmllog   IN VARCHAR2      --XML com informa��es de LOG
                        ,pr_cdcritic OUT PLS_INTEGER  --C�digo da cr�tica
                        ,pr_dscritic OUT VARCHAR2     --Descri��o da cr�tica
                        ,pr_retxml   IN OUT NOCOPY XMLType --Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2     --Nome do Campo
                        ,pr_des_erro OUT VARCHAR2);  --Saida OK/NOK 
                         
   PROCEDURE pc_importar(pr_cdcopsel  IN crapcop.cdcooper%TYPE --C�digo da cooperativa selecionada
                        ,pr_idproduto IN tbrisco_provisgarant_prodt.idproduto%TYPE --C�digo do produto
                        ,pr_dtrefere  IN VARCHAR2      --Data de refer�ncia
                        ,pr_tpoperacao IN VARCHAR2    --Tipo da operacao
                        ,pr_cddopcao IN VARCHAR2      --N�mero da conta
                        ,pr_xmllog   IN VARCHAR2      --XML com informa��es de LOG
                        ,pr_cdcritic OUT PLS_INTEGER  --C�digo da cr�tica
                        ,pr_dscritic OUT VARCHAR2     --Descri��o da cr�tica
                        ,pr_retxml   IN OUT NOCOPY XMLType --Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2     --Nome do Campo
                        ,pr_des_erro OUT VARCHAR2);  --Saida OK/NOK
                        
  PROCEDURE pc_alterar_movimento(pr_idmovto_risco         IN tbrisco_provisgarant_movto.idmovto_risco%TYPE --C�digo do movimento
                                ,pr_cdcopsel              IN tbrisco_provisgarant_movto.cdcooper%TYPE --C�digo da cooperativa
                                ,pr_dtrefere              IN VARCHAR2 --Data de refer�ncia
                                ,pr_idproduto             IN tbrisco_provisgarant_movto.idproduto%TYPE --C�digo do produto
                                ,pr_nrdconta              IN tbrisco_provisgarant_movto.nrdconta%TYPE --N�mero da conta
                                ,pr_nrcpfcgc              IN tbrisco_provisgarant_movto.nrcpfcgc%TYPE --CPF/CNPJ
                                ,pr_nrctremp              IN tbrisco_provisgarant_movto.nrctremp%TYPE --N�mero do contrato
                                ,pr_idgarantia            IN tbrisco_provisgarant_movto.idgarantia%TYPE --C�digo da garantia
                                ,pr_idorigem_recurso      IN tbrisco_provisgarant_movto.idorigem_recurso%TYPE --C�digo de origem do recurso
                                ,pr_idindexador           IN tbrisco_provisgarant_movto.idindexador%TYPE --C�digo do indexador
                                ,pr_perindexador          IN tbrisco_provisgarant_movto.perindexador%TYPE --Percentual do indexador
                                ,pr_vltaxa_juros          IN tbrisco_provisgarant_movto.vltaxa_juros%TYPE --Valor da taxa de juros
                                ,pr_dtlib_operacao        IN VARCHAR2 --Data de libera��o da opera��o
                                ,pr_vloperacao            IN tbrisco_provisgarant_movto.vloperacao%TYPE --Valor da opera��o
                                ,pr_idnat_operacao        IN tbrisco_provisgarant_movto.idnat_operacao%TYPE --C�digo da natureza de opera��o
                                ,pr_dtvenc_operacao       IN VARCHAR2 --Data de vencimento da opera��o
                                ,pr_cdclassifica_operacao IN tbrisco_provisgarant_movto.cdclassifica_operacao%TYPE --C�digo da classifica��o de opera��o
                                ,pr_qtdparcelas           IN tbrisco_provisgarant_movto.qtdparcelas%TYPE --Quantidade de parcelas
                                ,pr_vlparcela             IN tbrisco_provisgarant_movto.vlparcela%TYPE --Valor da parcela
                                ,pr_dtproxima_parcela     IN VARCHAR2 --Data da pr�xima parcela
                                ,pr_vlsaldo_pendente      IN tbrisco_provisgarant_movto.vlsaldo_pendente%TYPE --Valor pendente
                                ,pr_flsaida_operacao      IN tbrisco_provisgarant_movto.flsaida_operacao%TYPE --Saida opera��o
                                ,pr_cddopcao IN VARCHAR2      --N�mero da conta
                                ,pr_xmllog   IN VARCHAR2      --XML com informa��es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER  --C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2     --Descri��o da cr�tica
                                ,pr_retxml   IN OUT NOCOPY XMLType --Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2     --Nome do Campo
                                ,pr_des_erro OUT VARCHAR2);  --Saida OK/NOK              
                        
   
  PROCEDURE pc_excluir_movimento(pr_idmovto_risco IN tbrisco_provisgarant_movto.idmovto_risco%TYPE --C�digo do movimento
                                ,pr_cddopcao IN VARCHAR2      --N�mero da conta
                                ,pr_xmllog   IN VARCHAR2      --XML com informa��es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER  --C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2     --Descri��o da cr�tica
                                ,pr_retxml   IN OUT NOCOPY XMLType --Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2     --Nome do Campo
                                ,pr_des_erro OUT VARCHAR2);  --Saida OK/NOK         
                                
  PROCEDURE pc_fechamento_digitacao(pr_cdcopsel  IN crapcop.cdcooper%TYPE --C�digo da cooperativa selecionada
                                   ,pr_dtrefere  IN VARCHAR2      --Data de refer�ncia
                                   ,pr_cddopcao IN VARCHAR2      --N�mero da conta
                                   ,pr_xmllog   IN VARCHAR2      --XML com informa��es de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER  --C�digo da cr�tica
                                   ,pr_dscritic OUT VARCHAR2     --Descri��o da cr�tica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2     --Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2);  --Saida OK/NOK
                                   
  PROCEDURE pc_reabertura_digitacao(pr_cdcopsel  IN crapcop.cdcooper%TYPE --C�digo da cooperativa selecionada
                                   ,pr_dtrefere  IN VARCHAR2      --Data de refer�ncia
                                   ,pr_cddopcao IN VARCHAR2      --N�mero da conta
                                   ,pr_xmllog   IN VARCHAR2      --XML com informa��es de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER  --C�digo da cr�tica
                                   ,pr_dscritic OUT VARCHAR2     --Descri��o da cr�tica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2     --Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2);  --Saida OK/NOK                                                                   
                                                                   
  PROCEDURE pc_detalhes_movimento(pr_idmovto_risco IN tbrisco_provisgarant_movto.idmovto_risco%TYPE --C�digo do movimento
                                 ,pr_idproduto     IN tbrisco_provisgarant_movto.idproduto%TYPE --C�digo do produto
                                 ,pr_cddopcao IN VARCHAR2      --N�mero da conta
                                 ,pr_xmllog   IN VARCHAR2      --XML com informa��es de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER  --C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2     --Descri��o da cr�tica
                                 ,pr_retxml   IN OUT NOCOPY XMLType --Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2     --Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2);  --Saida OK/NOK
                                 
  PROCEDURE pc_incluir_movimento(pr_cdcopsel              IN tbrisco_provisgarant_movto.cdcooper%TYPE --C�digo da cooperativa
                                ,pr_dtrefere              IN VARCHAR2 --Data de refer�ncia
                                ,pr_idproduto             IN tbrisco_provisgarant_movto.idproduto%TYPE --C�digo do produto
                                ,pr_nrdconta              IN tbrisco_provisgarant_movto.nrdconta%TYPE --N�mero da conta
                                ,pr_nrcpfcgc              IN tbrisco_provisgarant_movto.nrcpfcgc%TYPE --CPF/CNPJ
                                ,pr_nrctremp              IN tbrisco_provisgarant_movto.nrctremp%TYPE --N�mero do contrato
                                ,pr_idgarantia            IN tbrisco_provisgarant_movto.idgarantia%TYPE --C�digo da garantia
                                ,pr_idorigem_recurso      IN tbrisco_provisgarant_movto.idorigem_recurso%TYPE --C�digo de origem do recurso
                                ,pr_idindexador           IN tbrisco_provisgarant_movto.idindexador%TYPE --C�digo do indexador
                                ,pr_perindexador          IN tbrisco_provisgarant_movto.perindexador%TYPE --Percentual do indexador
                                ,pr_vltaxa_juros          IN tbrisco_provisgarant_movto.vltaxa_juros%TYPE --Valor da taxa de juros
                                ,pr_dtlib_operacao        IN VARCHAR2 --Data de libera��o da opera��o
                                ,pr_vloperacao            IN tbrisco_provisgarant_movto.vloperacao%TYPE --Valor da opera��o
                                ,pr_idnat_operacao        IN tbrisco_provisgarant_movto.idnat_operacao%TYPE --C�digo da natureza de opera��o
                                ,pr_dtvenc_operacao       IN VARCHAR2 --Data de vencimento da opera��o
                                ,pr_cdclassifica_operacao IN tbrisco_provisgarant_movto.cdclassifica_operacao%TYPE --C�digo da classifica��o de opera��o
                                ,pr_qtdparcelas           IN tbrisco_provisgarant_movto.qtdparcelas%TYPE --Quantidade de parcelas
                                ,pr_vlparcela             IN tbrisco_provisgarant_movto.vlparcela%TYPE --Valor da parcela
                                ,pr_dtproxima_parcela     IN VARCHAR2 --Data da pr�xima parcela
                                ,pr_vlsaldo_pendente      IN tbrisco_provisgarant_movto.vlsaldo_pendente%TYPE --Valor pendente
                                ,pr_flsaida_operacao      IN tbrisco_provisgarant_movto.flsaida_operacao%TYPE --Saida opera��o
                                ,pr_cddopcao IN VARCHAR2      --N�mero da conta
                                ,pr_xmllog   IN VARCHAR2      --XML com informa��es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER  --C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2     --Descri��o da cr�tica
                                ,pr_retxml   IN OUT NOCOPY XMLType --Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2     --Nome do Campo
                                ,pr_des_erro OUT VARCHAR2);  --Saida OK/NOK                                 
                                 
                                                    
END TELA_MOVRGP;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_MOVRGP AS

/*---------------------------------------------------------------------------------------------------------------
   Programa: TELA_MOVRGP                          antigo: 
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Jonata - RKAM
   Data    : Maio/2017                       Ultima atualizacao: 01/06/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line).
   Objetivo  : Mostrar a tela MOVGRP para permitir o lan�amento manual de contratos para gera��o das informa��es do Doc3040.

   Alteracoes: 01/06/2017 - Ajuste para retirar valida��o de valor do percentaul, poder� ser enviado valor zerado
                            (Jonata - RKAM).
           
  ---------------------------------------------------------------------------------------------------------------*/
  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE)IS
  SELECT crapcop.cdcooper
        ,crapcop.nmrescop 
    FROM crapcop
   WHERE crapcop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
    
   
  PROCEDURE pc_gera_log(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_idproduto IN tbrisco_provisgarant_prodt.idproduto%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE
                       ,pr_dsdcampo IN VARCHAR2
                       ,pr_vlrcampo IN VARCHAR2
                       ,pr_vlcampo2 IN VARCHAR2
                       ,pr_des_erro OUT VARCHAR2) IS

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_gera_log                            antiga:
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonata - RKAM
    Data     : Maio/2017                           Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Procedure para gerar log

    Altera��es :
    -------------------------------------------------------------------------------------------------------------*/

   BEGIN

     IF pr_vlrcampo <> pr_vlcampo2 THEN

       -- Gera log
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_nmarqlog     => 'movrgp.log'
                                 ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                     ' -->  Operador '|| pr_cdoperad || ' - ' ||
                                                     'Efetuou a alteracao do produto ' ||
                                                     'Codigo: ' || gene0002.fn_mask(pr_idproduto,'z.zzz.zz9') ||
                                                     ', ' || pr_dsdcampo || ' de ' || pr_vlrcampo ||
                                                     ' para ' || pr_vlcampo2 || '.');

     END IF;

     pr_des_erro := 'OK';

   EXCEPTION
     WHEN OTHERS THEN
       pr_des_erro := 'NOK';
   END pc_gera_log;
   
  PROCEDURE pc_carrega_cooperativas(pr_cddopcao IN VARCHAR2      --N�mero da conta
                                   ,pr_xmllog   IN VARCHAR2      --XML com informa��es de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER  --C�digo da cr�tica
                                   ,pr_dscritic OUT VARCHAR2     --Descri��o da cr�tica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2     --Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2)IS  --Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_carrega_cooperativas                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonata - RKAM
    Data     : Maio/2017                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca informa��es para carregar campo de cooperativas da tela MOVRGP
    
    Altera��es : 
    -------------------------------------------------------------------------------------------------------------*/                                
      
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_des_lista VARCHAR2(32700);
    vr_tab_coop gene0002.typ_split;
    vr_tab_desc_coop gene0002.typ_split;
    vr_contador INT := 0;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    vr_exc_saida EXCEPTION;
    
  BEGIN 
    
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'MOVRGP'
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
    
    -- Criar cabe�alho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
                    
    GENE0001.pc_lista_cooperativas(pr_des_lista => vr_des_lista);
        
    vr_tab_coop := gene0002.fn_quebra_string(pr_string => vr_des_lista ,pr_delimit => '#');
    
    --> Varrer a lista de cooperativas
    IF vr_tab_coop.count > 0 THEN
       
      FOR i IN vr_tab_coop.first..vr_tab_coop.last LOOP
      
        vr_tab_desc_coop := gene0002.fn_quebra_string(pr_string => vr_tab_coop(i) ,pr_delimit => ';');
        
        --> Varrer a lista de informa��es
        IF vr_tab_desc_coop.count > 0 THEN
        
          IF pr_cddopcao = 'J'        AND 
             vr_tab_desc_coop(1) <> 3 THEN
            
            CONTINUE;
            
          END IF;
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dados', pr_posicao => 0, pr_tag_nova => 'cooperativa', pr_tag_cont => null, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cooperativa', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper', pr_tag_cont => vr_tab_desc_coop(1), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cooperativa', pr_posicao => vr_contador, pr_tag_nova => 'nmrescop', pr_tag_cont => vr_tab_desc_coop(1) || ' - ' || vr_tab_desc_coop(2), pr_des_erro => vr_dscritic);
          
          vr_contador := vr_contador + 1;
          
        END IF;          
        
      END LOOP;        
      
    END IF;    
      
    -- Insere atributo na tag Dados com a data de refer�ncia
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que ir� receber o novo atributo
                             ,pr_tag   => 'dados'             --> Nome da TAG XML
                             ,pr_atrib => 'dtrefere'          --> Nome do atributo
                             ,pr_atval => to_char(last_day(add_months(sysdate,-1)),'dd/mm/rrrr' ) --> Valor do atributo
                             ,pr_numva => 0                   --> N�mero da localiza��o da TAG na �rvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descri��o de erros
                               
    --Se ocorreu erro  
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := 'cddopcao';
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_carrega_cooperativas --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_carrega_cooperativas;
   
  PROCEDURE pc_carrega_campo_produtos(pr_cdcopsel IN crapcop.cdcooper%TYPE --C�digo da cooperativa selecionada
                                     ,pr_cddopcao IN VARCHAR2      --N�mero da conta
                                     ,pr_xmllog   IN VARCHAR2      --XML com informa��es de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER  --C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2     --Descri��o da cr�tica
                                     ,pr_retxml   IN OUT NOCOPY XMLType --Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2     --Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2)IS  --Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_carrega_campo_produtos                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonata - RKAM
    Data     : Maio/2017                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca informa��es para carregar campo de produtos da tela MOVRGP
    
    Altera��es : 
    -------------------------------------------------------------------------------------------------------------*/                                
      
    CURSOR cr_produtos(pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_cddopcao IN VARCHAR2) IS
    SELECT idproduto
          ,LPAD(idproduto, 2, '0') || '-' || dsproduto dsproduto
      FROM tbrisco_provisgarant_prodt
     WHERE (pr_cddopcao = 'J'  
       AND (pr_cdcooper = 3
       AND UPPER(tparquivo) <> 'NAO')
        OR (pr_cdcooper <> 3 
       AND tpdestino = 'S' ))
        OR (pr_cddopcao = 'I'
       AND (tpdestino = 'C' AND pr_cdcooper = 3)
        OR (tpdestino = 'S' AND pr_cdcooper <> 3)
        OR (UPPER(tparquivo) <> 'NAO' 
        AND pr_cdcooper = 3))
        OR (pr_cddopcao NOT IN ('J','I')
       AND (tpdestino = 'C' AND pr_cdcooper = 3)
        OR (tpdestino = 'S' AND pr_cdcooper <> 3)
        OR (UPPER(tparquivo) <> 'NAO' 
        AND pr_cdcooper = 3))
     ORDER BY idproduto;
     
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_contador INT :=0;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    vr_exc_saida EXCEPTION;
    
  BEGIN 
    
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'MOVRGP'
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
    
    -- Criar cabe�alho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        
    FOR rw_produtos IN cr_produtos(pr_cdcooper => pr_cdcopsel
                                  ,pr_cddopcao => pr_cddopcao) LOOP
      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dados', pr_posicao => 0, pr_tag_nova => 'produtos', pr_tag_cont => null, pr_des_erro => vr_dscritic);   
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'produtos', pr_posicao => vr_contador, pr_tag_nova => 'idproduto', pr_tag_cont => rw_produtos.idproduto, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'produtos', pr_posicao => vr_contador, pr_tag_nova => 'dsproduto', pr_tag_cont => rw_produtos.dsproduto, pr_des_erro => vr_dscritic);

      vr_contador := vr_contador + 1;
      
    END LOOP;
                    
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := 'cddopcao';
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_carrega_campo_produtos --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_carrega_campo_produtos;
  
  PROCEDURE pc_carrega_movimentos(pr_cdcopsel IN crapcop.cdcooper%TYPE --C�digo da cooperativa selecionada
                                 ,pr_idproduto IN tbrisco_provisgarant_prodt.idproduto%TYPE --C�digo do produto
                                 ,pr_dtrefere IN VARCHAR2      --Data de refer�ncia
                                 ,pr_cddopcao IN VARCHAR2      --N�mero da conta
                                 ,pr_nrregist IN INTEGER       --Quantidade de registros                            
                                 ,pr_nriniseq IN INTEGER       --Qunatidade inicial
                                 ,pr_xmllog   IN VARCHAR2      --XML com informa��es de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER  --C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2     --Descri��o da cr�tica
                                 ,pr_retxml   IN OUT NOCOPY XMLType --Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2     --Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2)IS  --Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_carrega_movimentos                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonata - RKAM
    Data     : Maio/2017                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca movimentos da tela MOVRGP
    
    Altera��es : 
    -------------------------------------------------------------------------------------------------------------*/                                
    CURSOR cr_risco_prodt(pr_idproduto IN tbrisco_provisgarant_prodt.idproduto%TYPE) IS 
    SELECT ppg.tpdestino
          ,ppg.tparquivo
      FROM tbrisco_provisgarant_prodt ppg
     WHERE ppg.idproduto = pr_idproduto;
    rw_risco_prodt cr_risco_prodt%ROWTYPE;

    CURSOR cr_movimentos(pr_cdcooper  IN crapcop.cdcooper%TYPE
                        ,pr_idproduto IN tbrisco_provisgarant_prodt.idproduto%TYPE
                        ,pr_dtrefere  IN DATE)IS
    SELECT mvt.idmovto_risco
          ,LPAD(prd.idproduto, 2, '0') || ' - ' || prd.dsproduto dsproduto
          ,gene0002.fn_mask_conta(ass.nrdconta) nrdconta
          ,mvt.nrcpfcgc
          ,mvt.nrctremp
          ,mvt.vloperacao
          ,mvt.vlsaldo_pendente
          ,ass.inpessoa
      FROM tbrisco_provisgarant_prodt prd
          ,tbrisco_provisgarant_movto mvt LEFT JOIN crapass ass
           ON mvt.cdcooper = ass.cdcooper
          AND mvt.nrdconta = ass.nrdconta
     WHERE prd.idproduto = mvt.idproduto
       AND mvt.cdcooper = pr_cdcooper
       AND mvt.dtbase   = pr_dtrefere
       AND mvt.idproduto = DECODE(pr_idproduto, 0, mvt.idproduto, pr_idproduto)
     ORDER BY prd.idproduto
             ,mvt.nrdconta
             ,mvt.nrctremp;

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_dtrefere DATE;
    vr_contador INT :=0;       
    vr_tot_saldo NUMBER(25,2) :=0;
    vr_vlsaldo_pendente_pf NUMBER(25,2) :=0;    
    vr_vlsaldo_pendente_pj NUMBER(25,2) :=0;    
    vr_tot_vloperacao NUMBER(25,2) :=0;
    vr_qtregist INTEGER := 0; 
    vr_nrregist INTEGER;
    vr_stsnrcal BOOLEAN;
    vr_inpessoa PLS_INTEGER;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    vr_exc_saida EXCEPTION;
    
  BEGIN 
    
    --Inicializar Variaveis
    vr_nrregist:= pr_nrregist;
    
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'MOVRGP'
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
    
    IF nvl(pr_idproduto,0) = 0 THEN
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'idproduto';
      vr_dscritic := 'Produto n�o informado.';
      RAISE vr_exc_erro;
      
    END IF;
    
    IF TRIM(pr_dtrefere) IS NULL THEN
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'dtrefere';
      vr_dscritic := 'Data de refer�ncia n�o informada.';
      RAISE vr_exc_erro;
      
    END IF;
    
    BEGIN
      
      vr_dtrefere:= to_date(pr_dtrefere,'dd/mm/rrrr');
      
    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        pr_nmdcampo := 'dtrefere';
        vr_dscritic := 'Data de refer�ncia inv�lida.';
        RAISE vr_exc_erro;
        
    END;
    
    IF vr_dtrefere >= last_day(trunc(SYSDATE)) THEN
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'dtrefere';
      vr_dscritic := 'Dt. Ref. Inv�lida - Favor selecionar data anterior ou igual a ' || to_char(last_day(add_months(sysdate,-1)),'dd/mm/rrrr' ) || '.';
      RAISE vr_exc_erro;
        
    END IF;
    
    OPEN cr_risco_prodt(pr_idproduto => pr_idproduto);
    
    FETCH cr_risco_prodt INTO rw_risco_prodt;
    
    CLOSE cr_risco_prodt;
    
    IF (rw_risco_prodt.tpdestino = 'S'            AND 
        pr_cdcopsel = 3                           AND
        upper(rw_risco_prodt.tparquivo) <> 'NAO') OR
       (rw_risco_prodt.tpdestino = 'C'            AND
        pr_cdcopsel <> 3)                         THEN
       
      -- Montar mensagem de critica
      pr_nmdcampo := 'cdcooper';
      vr_dscritic := 'Combina��o Produto e Cooperativa inv�lida, favor selecionar outro produto ou Cooperativa!';
      RAISE vr_exc_erro;    
       
    END IF;
    
    IF pr_cddopcao IN ('A','E','I')                                   AND 
       RISC0003.fn_periodo_habilitado(pr_cdcooper => pr_cdcopsel
                                     ,pr_dtbase   => vr_dtrefere) = 0 THEN
    
      -- Montar mensagem de critica
      vr_dscritic := 'Per�odo n�o est� liberado para digita��o!';
      RAISE vr_exc_erro;                                   
                                     
    END IF;
    
    risc0003.pc_cria_contratos_novo_mes(pr_cdcooper  => pr_cdcopsel
                                       ,pr_idproduto => pr_idproduto
                                       ,pr_dtbase    => vr_dtrefere
                                       ,pr_dscritic  => vr_dscritic); 
                                       
    -- Verifica se houve erro 
    IF vr_dscritic IS NOT NULL THEN
    
      pr_nmdcampo:= 'cdcooper';
      vr_dscritic:= 'Erro na recria��o dos contratos devido m�s novo: ' || vr_dscritic;
      RAISE vr_exc_erro;
      
    END IF;                                        
    
    -- Criar cabe�alho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dados', pr_posicao => 0, pr_tag_nova => 'movimentos', pr_tag_cont => null, pr_des_erro => vr_dscritic);   
      
    FOR rw_movimentos IN cr_movimentos(pr_cdcooper  => pr_cdcopsel
                                      ,pr_idproduto => pr_idproduto
                                      ,pr_dtrefere  => vr_dtrefere) LOOP
       
      vr_tot_vloperacao:= vr_tot_vloperacao + rw_movimentos.vloperacao;
      vr_tot_saldo:= vr_tot_saldo + rw_movimentos.vlsaldo_pendente;
      
      --Se inpessoa = 0 significa que movimento foi cadastrado com conta zerada e
      --precisamos encontrar o tipo de pessoa com base no cpf/cnpj.
      IF rw_movimentos.inpessoa = 0 THEN
  
        gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => rw_movimentos.nrcpfcgc
                                   ,pr_stsnrcal => vr_stsnrcal
                                   ,pr_inpessoa => vr_inpessoa);
                                   
        IF vr_stsnrcal THEN
          
          IF vr_inpessoa = 1 THEN
            
            vr_vlsaldo_pendente_pf := vr_vlsaldo_pendente_pf + rw_movimentos.vlsaldo_pendente;
            
          ELSE
            
            vr_vlsaldo_pendente_pj := vr_vlsaldo_pendente_pj + rw_movimentos.vlsaldo_pendente;
            
          END IF;
          
        ELSE
          vr_vlsaldo_pendente_pj := vr_vlsaldo_pendente_pj + rw_movimentos.vlsaldo_pendente;
        END IF; 
                                          
      ELSIF rw_movimentos.inpessoa = 1 THEN
          
        vr_vlsaldo_pendente_pf := vr_vlsaldo_pendente_pf + rw_movimentos.vlsaldo_pendente;
          
      ELSE
        
        vr_vlsaldo_pendente_pj := vr_vlsaldo_pendente_pj + rw_movimentos.vlsaldo_pendente;
          
      END IF;
                                     
      --Incrementar Quantidade Registros do Parametro
      vr_qtregist:= nvl(vr_qtregist,0) + 1;
          
      /* controles da paginacao */
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proximo Titular
        CONTINUE;
      END IF; 
          
      --Numero Registros
      IF vr_nrregist > 0 THEN                                      
      
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'movimentos', pr_posicao => 0, pr_tag_nova => 'movimento', pr_tag_cont => null, pr_des_erro => vr_dscritic);   
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'movimento', pr_posicao => vr_contador, pr_tag_nova => 'idmovto_risco', pr_tag_cont => rw_movimentos.idmovto_risco, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'movimento', pr_posicao => vr_contador, pr_tag_nova => 'dsproduto', pr_tag_cont => rw_movimentos.dsproduto, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'movimento', pr_posicao => vr_contador, pr_tag_nova => 'nrdconta', pr_tag_cont => rw_movimentos.nrdconta, pr_des_erro => vr_dscritic);      
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'movimento', pr_posicao => vr_contador, pr_tag_nova => 'nrctremp', pr_tag_cont => to_char(rw_movimentos.nrctremp,'fm9999g999g990'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'movimento', pr_posicao => vr_contador, pr_tag_nova => 'vloperacao', pr_tag_cont => to_char(rw_movimentos.vloperacao,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'movimento', pr_posicao => vr_contador, pr_tag_nova => 'vlsaldo_pendente', pr_tag_cont => to_char(rw_movimentos.vlsaldo_pendente,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);            
        
        vr_contador:= vr_contador + 1;
        
      END IF;
      
      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1;
      
    END LOOP;
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dados', pr_posicao => 0, pr_tag_nova => 'totais', pr_tag_cont => null, pr_des_erro => vr_dscritic);   
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'totais', pr_posicao => 0, pr_tag_nova => 'tot_vloperacao', pr_tag_cont => to_char(vr_tot_vloperacao,'fm999g999g999g990d00'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'totais', pr_posicao => 0, pr_tag_nova => 'tot_vlsaldo', pr_tag_cont => to_char(vr_tot_saldo,'fm999g999g999g990d00'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'totais', pr_posicao => 0, pr_tag_nova => 'vlsaldo_pendente_pf', pr_tag_cont => to_char(vr_vlsaldo_pendente_pf,'fm999g999g999g990d00'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'totais', pr_posicao => 0, pr_tag_nova => 'vlsaldo_pendente_pj', pr_tag_cont => to_char(vr_vlsaldo_pendente_pj,'fm999g999g999g990d00'), pr_des_erro => vr_dscritic);
      
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que ir� receber o novo atributo
                             ,pr_tag   => 'dados'             --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> N�mero da localiza��o da TAG na �rvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descri��o de erros
                               
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
             
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := 'cddopcao';
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_carrega_movimentos --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_carrega_movimentos;
  
  PROCEDURE pc_exportar(pr_cdcopsel IN crapcop.cdcooper%TYPE --C�digo da cooperativa selecionada
                       ,pr_idproduto IN tbrisco_provisgarant_prodt.idproduto%TYPE --C�digo do produto
                       ,pr_dtrefere IN VARCHAR2      --Data de refer�ncia
                       ,pr_cddopcao IN VARCHAR2      --N�mero da conta
                       ,pr_xmllog   IN VARCHAR2      --XML com informa��es de LOG
                       ,pr_cdcritic OUT PLS_INTEGER  --C�digo da cr�tica
                       ,pr_dscritic OUT VARCHAR2     --Descri��o da cr�tica
                       ,pr_retxml   IN OUT NOCOPY XMLType --Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2     --Nome do Campo
                       ,pr_des_erro OUT VARCHAR2)IS  --Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_exportar                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonata - RKAM
    Data     : Maio/2017                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Realiza a exporta��o de informa��es da tela MOVRGP
    
    Altera��es : 
    -------------------------------------------------------------------------------------------------------------*/                                
      
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_dtrefere DATE;
    vr_arquivo_txt UTL_FILE.file_type;
    vr_nmdireto VARCHAR2(100);      
    vr_nmarquiv VARCHAR2(100);
    vr_dsarquiv varchar2(32767);
    vr_des_reto  VARCHAR2(3);      
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    vr_exc_saida EXCEPTION;
    
    -- Tabela de Erros
    vr_tab_erro      GENE0001.typ_tab_erro;
    
  BEGIN 
    
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'MOVRGP'
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
    
    IF nvl(pr_cdcopsel,0) = 0 THEN
      
      -- Montar mensagem de critica
      vr_dscritic := 'Cooperativa inv�lida.';
      RAISE vr_exc_erro;
      
    END IF;
    
    IF nvl(pr_idproduto,0) = 0 THEN
      
      -- Montar mensagem de critica
      vr_dscritic := 'Produto n�o informado.';
      RAISE vr_exc_erro;
      
    END IF;
    
    IF TRIM(pr_dtrefere) IS NULL THEN
      
      -- Montar mensagem de critica
      vr_dscritic := 'Data de refer�ncia n�o informada.';
      RAISE vr_exc_erro;
      
    END IF;

    BEGIN
      
      vr_dtrefere:= to_date(pr_dtrefere,'dd/mm/rrrr');
      
    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        pr_nmdcampo := 'cdproduto';
        vr_dscritic := 'Data de refer�ncia inv�lida.';
        RAISE vr_exc_erro;
        
    END;

    IF vr_dtrefere >= last_day(trunc(SYSDATE)) THEN
      
      -- Montar mensagem de critica
      vr_dscritic := 'Dt. Ref. Inv�lida - Favor selecionar data anterior ou igual a ' || to_char(last_day(add_months(sysdate,-1)),'dd/mm/rrrr' ) || '.';
      RAISE vr_exc_erro;
        
    END IF;
    
    risc0003.pc_exporta_dados_csv(pr_cdcooper  => pr_cdcopsel
                                 ,pr_idproduto => pr_idproduto
                                 ,pr_dtbase    => vr_dtrefere
                                 ,pr_dsarquiv  => vr_dsarquiv
                                 ,pr_dscritic  => vr_dscritic); 
                                 
    --Se houve erro na rotina:
    IF vr_dscritic IS NOT NULL THEN
      
      --Desfazer as altera��es (Rollback);
      vr_dscritic:= 'Erro na gera��o do movimento para CSV: ' || vr_dscritic;
      RAISE vr_exc_erro;
      
    END IF; 
      
    --Buscar Diretorio Padrao da Cooperativa
    vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                        ,pr_cdcooper => vr_cdcooper
                                        ,pr_nmsubdir => 'rl');
                                       
    --Nome do Arquivo
    vr_nmarquiv:= to_char(vr_cdcooper,'fm9999999990') || '_' || 
                  to_char(sysdate,'RRRRMMDD')         || '_' || 
                  to_char(pr_idproduto,'fm9999999990') || '.csv';
        
    -- Abre arquivo crrl579.csv
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto, --> Diret�rio do arquivo
                             pr_nmarquiv => vr_nmarquiv,    --> Nome do arquivo
                             pr_tipabert => 'W',            --> Modo de abertura (R,W,A)
                             pr_utlfileh => vr_arquivo_txt, --> Handle do arquivo aberto
                             pr_des_erro => vr_dscritic);   --> Retorno da critica

    -- Se retornou erro
    IF  vr_dscritic IS NOT NULL  THEN
      RAISE vr_exc_saida;
    END IF;

    -- Escreve conte�do 
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt,vr_dsarquiv);
    
    -- Fechar o arquivo 
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_arquivo_txt);
    
    --O ireport j� ir� gerar o relat�rio em formato pdf e por isso, iremos apenas
    --envia-lo ao servidor web.           
    gene0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_nmarqpdf => vr_nmdireto||'/'|| vr_nmarquiv
                                ,pr_des_reto => vr_des_reto
                                ,pr_tab_erro => vr_tab_erro);

    --Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN
          
      --Se tem erro na tabela 
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        vr_dscritic:= 'Erro ao enviar arquivo para web.';  
      END IF; 
          
      --Sair 
      RAISE vr_exc_erro;
          
    END IF; 
    
    -- Criar cabe�alho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><dados/>');
        
    -- Incrementa o contador           
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dados', pr_posicao => 0, pr_tag_nova => 'arquivo', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'arquivo', pr_posicao => 0, pr_tag_nova => 'nmarquivo', pr_tag_cont => vr_nmarquiv, pr_des_erro => vr_dscritic);
        
    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'movrgp.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou a exportacao  de arquivo: ' || 
                                                  'Codigo: ' || gene0002.fn_mask(pr_idproduto,'z.zzz.zz9') ||
                                                  ', Cooperativa: ' || to_char(rw_crapcop.cdcooper,'fm9999990') || '- ' || rw_crapcop.nmrescop|| 
                                                  ', Data de referencia: ' || to_char(vr_dtrefere,'DD/MM/RRRR') || '.');
    
    pr_des_erro := 'OK';
    
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_exportar --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_exportar;
 
  PROCEDURE pc_importar(pr_cdcopsel  IN crapcop.cdcooper%TYPE --C�digo da cooperativa selecionada
                       ,pr_idproduto IN tbrisco_provisgarant_prodt.idproduto%TYPE --C�digo do produto
                       ,pr_dtrefere  IN VARCHAR2      --Data de refer�ncia
                       ,pr_tpoperacao IN VARCHAR2    --Tipo da operacao
                       ,pr_cddopcao IN VARCHAR2      --N�mero da conta
                       ,pr_xmllog   IN VARCHAR2      --XML com informa��es de LOG
                       ,pr_cdcritic OUT PLS_INTEGER  --C�digo da cr�tica
                       ,pr_dscritic OUT VARCHAR2     --Descri��o da cr�tica
                       ,pr_retxml   IN OUT NOCOPY XMLType --Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2     --Nome do Campo
                       ,pr_des_erro OUT VARCHAR2)IS  --Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_importar                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonata - RKAM
    Data     : Maio/2017                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Realiza a importa��o de informa��es da tela MOVRGP
    
    Altera��es : 
    -------------------------------------------------------------------------------------------------------------*/                                
      
    CURSOR cr_risco(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_dtbase   IN tbrisco_provisgarant_movto.dtbase%TYPE
                   ,pr_idproduto IN tbrisco_provisgarant_movto.idproduto%TYPE)IS        
    SELECT COUNT(*)
      FROM tbrisco_provisgarant_movto mvt
     WHERE mvt.cdcooper = pr_cdcooper
       AND mvt.dtbase   = pr_dtbase
       AND mvt.idproduto = DECODE(pr_idproduto, 0, mvt.idproduto, pr_idproduto);
       
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_dtrefere DATE;
    vr_dsinform varchar2(32767); 
    vr_qtregist INT:=0;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    vr_exc_saida EXCEPTION;
        
  BEGIN 
    
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'MOVRGP'
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
    
    IF nvl(pr_cdcopsel,0) = 0 THEN
      
      -- Montar mensagem de critica
      vr_dscritic := 'Cooperativa inv�lida.';
      RAISE vr_exc_erro;
      
    END IF;    
    
    IF nvl(pr_idproduto,0) = 0 THEN
      
      -- Montar mensagem de critica
      vr_dscritic := 'Produto n�o informado.';
      RAISE vr_exc_erro;
      
    END IF;
    
    IF TRIM(pr_dtrefere) IS NULL THEN
      
      -- Montar mensagem de critica
      vr_dscritic := 'Data de refer�ncia n�o informada.';
      RAISE vr_exc_erro;
      
    END IF;

    BEGIN
      
      vr_dtrefere:= to_date(pr_dtrefere,'dd/mm/rrrr');
      
    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        vr_dscritic := 'Data de refer�ncia inv�lida.';
        RAISE vr_exc_erro;
        
    END;

    IF vr_dtrefere >= last_day(trunc(SYSDATE)) THEN
      
      -- Montar mensagem de critica
      vr_dscritic := 'Dt. Ref. Inv�lida � Favor selecionar data anterior ou igual a ' || to_char(last_day(add_months(sysdate,-1)),'dd/mm/rrrr' ) || '.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF TRIM(pr_tpoperacao) IS NULL     OR 
       pr_tpoperacao NOT IN('VI','GI') THEN
       
      -- Montar mensagem de critica
      vr_dscritic := 'Tipo da opera��o inv�lida.';
      RAISE vr_exc_erro;
         
    END IF;
    
    IF RISC0003.fn_periodo_habilitado(pr_cdcooper => pr_cdcopsel
                                     ,pr_dtbase   => vr_dtrefere) = 0 THEN
    
      -- Montar mensagem de critica
      vr_dscritic := 'Per�odo n�o est� liberado para digita��o!';
      RAISE vr_exc_erro;                                   
                                     
    END IF;
    
    IF pr_tpoperacao <> 'GI' THEN
      
      OPEN cr_risco(pr_cdcooper  => pr_cdcopsel
                   ,pr_dtbase    => vr_dtrefere
                   ,pr_idproduto => pr_idproduto);
                   
      FETCH cr_risco INTO vr_qtregist;
      
      --Fecha o cursor
      CLOSE cr_risco;
        
      -- Criar cabe�alho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><root/>');
        
      -- Incrementa o contador           
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'root', pr_posicao => 0, pr_tag_nova => 'validacao', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'validacao', pr_posicao => 0, pr_tag_nova => 'tpoperacao', pr_tag_cont => 'GI', pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'validacao', pr_posicao => 0, pr_tag_nova => 'qtregist', pr_tag_cont => vr_qtregist, pr_des_erro => vr_dscritic);
         
      pr_des_erro := 'OK';
      RETURN;
      
    END IF;
    
    OPEN cr_crapcop(pr_cdcooper => pr_cdcopsel);
    
    FETCH cr_crapcop INTO rw_crapcop;
    
    IF cr_crapcop%NOTFOUND THEN
      
      CLOSE cr_crapcop;
      
      -- Montar mensagem de critica
      vr_dscritic := 'Cooperativa n�o encontrada.';
      RAISE vr_exc_erro;
    
    END IF;
    
    CLOSE cr_crapcop;
    
    Risc0003.pc_importa_arquivo(pr_cdcooper  => pr_cdcopsel
                               ,pr_idproduto => pr_idproduto 
                               ,pr_dtbase    => vr_dtrefere
                               ,pr_dsinform  => vr_dsinform 
                               ,pr_dscritic  => vr_dscritic);
                                 
    --Se houve erro na rotina:
    IF vr_dscritic IS NOT NULL THEN
      
      --Desfazer as altera��es (Rollback);
      vr_dscritic:= 'Erro na importa��o do arquivo: ' || vr_dscritic;
      RAISE vr_exc_erro;
      
    END IF; 
    
    -- Criar cabe�alho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><avisos/>');
    
    -- Incrementa o contador           
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'avisos', pr_posicao => 0, pr_tag_nova => 'mensagem', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'descricao', pr_tag_cont => vr_dsinform, pr_des_erro => vr_dscritic);
            
    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'movrgp.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou a importacao  de arquivo: ' || 
                                                  'Codigo: ' || gene0002.fn_mask(pr_idproduto,'z.zzz.zz9') ||
                                                  ', Cooperativa: ' || to_char(rw_crapcop.cdcooper,'fm9999990') || ' - ' || rw_crapcop.nmrescop|| 
                                                  ', Data de referencia: ' || to_char(vr_dtrefere,'DD/MM/RRRR') || '.');
      
    pr_des_erro := 'OK';
    
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := 'cddopcao';
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_importar --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_importar;
 
  PROCEDURE pc_excluir_movimento(pr_idmovto_risco IN tbrisco_provisgarant_movto.idmovto_risco%TYPE --C�digo do movimento
                                ,pr_cddopcao IN VARCHAR2      --N�mero da conta
                                ,pr_xmllog   IN VARCHAR2      --XML com informa��es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER  --C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2     --Descri��o da cr�tica
                                ,pr_retxml   IN OUT NOCOPY XMLType --Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2     --Nome do Campo
                                ,pr_des_erro OUT VARCHAR2)IS  --Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_excluir_movimento                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonata - RKAM
    Data     : Maio/2017                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Realiza a exclus�o de moviemtnos da tela MOVRGP
    
    Altera��es : 
    -------------------------------------------------------------------------------------------------------------*/                                
      
    CURSOR cr_risco(pr_idmovto_risco IN tbrisco_provisgarant_movto.idmovto_risco%TYPE)IS        
    SELECT mvt.idproduto
      FROM tbrisco_provisgarant_movto mvt
     WHERE mvt.idmovto_risco = pr_idmovto_risco;
    rw_risco cr_risco%ROWTYPE;
       
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
        
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    vr_exc_saida EXCEPTION;
    
  BEGIN 
    
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'MOVRGP'
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
    
    IF trim(pr_cddopcao) IS NULL OR
       pr_cddopcao <> 'E'        THEN
       
      -- Montar mensagem de critica
      pr_nmdcampo := 'dsproduto';
      vr_dscritic := 'C�digo da op��o inv�lida.';
      RAISE vr_exc_erro;
      
    END IF;
    
    IF nvl(pr_idmovto_risco,0) = 0 THEN
      
      -- Montar mensagem de critica
      vr_dscritic := 'C�digo do movimento inv�lido.';
      RAISE vr_exc_erro;
      
    END IF;
    
    OPEN cr_risco(pr_idmovto_risco => pr_idmovto_risco);
                   
    FETCH cr_risco INTO rw_risco;
    
    IF cr_risco%NOTFOUND THEN
      
      --Fecha o cursor
      CLOSE cr_risco;

      -- Montar mensagem de critica
      vr_dscritic := 'Movimento n�o encontrado.';
      RAISE vr_exc_erro;
    
    END IF;
    
    --Fecha o cursor
    CLOSE cr_risco;
    
    BEGIN
      
      DELETE tbrisco_provisgarant_movto
       WHERE tbrisco_provisgarant_movto.idmovto_risco = pr_idmovto_risco;
    
    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        vr_dscritic := 'N�o foi poss�vel excluir o movimento.';
        RAISE vr_exc_erro;
    
    END;
    
    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'movrgp.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou a exclusao do movimento ' || 
                                                  gene0002.fn_mask(pr_idmovto_risco,'z.zzz.zz9') || '.');
                                                  
    pr_des_erro := 'OK';
    
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_excluir_movimento --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_excluir_movimento;
 
  PROCEDURE pc_alterar_movimento(pr_idmovto_risco         IN tbrisco_provisgarant_movto.idmovto_risco%TYPE --C�digo do movimento
                                ,pr_cdcopsel              IN tbrisco_provisgarant_movto.cdcooper%TYPE --C�digo da cooperativa
                                ,pr_dtrefere              IN VARCHAR2 --Data de refer�ncia
                                ,pr_idproduto             IN tbrisco_provisgarant_movto.idproduto%TYPE --C�digo do produto
                                ,pr_nrdconta              IN tbrisco_provisgarant_movto.nrdconta%TYPE --N�mero da conta
                                ,pr_nrcpfcgc              IN tbrisco_provisgarant_movto.nrcpfcgc%TYPE --CPF/CNPJ
                                ,pr_nrctremp              IN tbrisco_provisgarant_movto.nrctremp%TYPE --N�mero do contrato
                                ,pr_idgarantia            IN tbrisco_provisgarant_movto.idgarantia%TYPE --C�digo da garantia
                                ,pr_idorigem_recurso      IN tbrisco_provisgarant_movto.idorigem_recurso%TYPE --C�digo de origem do recurso
                                ,pr_idindexador           IN tbrisco_provisgarant_movto.idindexador%TYPE --C�digo do indexador
                                ,pr_perindexador          IN tbrisco_provisgarant_movto.perindexador%TYPE --Percentual do indexador
                                ,pr_vltaxa_juros          IN tbrisco_provisgarant_movto.vltaxa_juros%TYPE --Valor da taxa de juros
                                ,pr_dtlib_operacao        IN VARCHAR2 --Data de libera��o da opera��o
                                ,pr_vloperacao            IN tbrisco_provisgarant_movto.vloperacao%TYPE --Valor da opera��o
                                ,pr_idnat_operacao        IN tbrisco_provisgarant_movto.idnat_operacao%TYPE --C�digo da natureza de opera��o
                                ,pr_dtvenc_operacao       IN VARCHAR2 --Data de vencimento da opera��o
                                ,pr_cdclassifica_operacao IN tbrisco_provisgarant_movto.cdclassifica_operacao%TYPE --C�digo da classifica��o de opera��o
                                ,pr_qtdparcelas           IN tbrisco_provisgarant_movto.qtdparcelas%TYPE --Quantidade de parcelas
                                ,pr_vlparcela             IN tbrisco_provisgarant_movto.vlparcela%TYPE --Valor da parcela
                                ,pr_dtproxima_parcela     IN VARCHAR2 --Data da pr�xima parcela
                                ,pr_vlsaldo_pendente      IN tbrisco_provisgarant_movto.vlsaldo_pendente%TYPE --Valor pendente
                                ,pr_flsaida_operacao      IN tbrisco_provisgarant_movto.flsaida_operacao%TYPE --Saida opera��o
                                ,pr_cddopcao IN VARCHAR2      --N�mero da conta
                                ,pr_xmllog   IN VARCHAR2      --XML com informa��es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER  --C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2     --Descri��o da cr�tica
                                ,pr_retxml   IN OUT NOCOPY XMLType --Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2     --Nome do Campo
                                ,pr_des_erro OUT VARCHAR2)IS  --Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_alterar_movimento                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonata - RKAM
    Data     : Maio/2017                           Ultima atualizacao: 01/06/2017
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Realiza a altera��o de moviemtnos da tela MOVRGP
    
    Altera��es : 01/06/2017 - Ajuste para retirar valida��o de valor do percentaul, poder� ser enviado valor zerado
                            (Jonata - RKAM).
                            
    -------------------------------------------------------------------------------------------------------------*/                                
      
    CURSOR cr_movto_1(pr_cdcooper  IN tbrisco_provisgarant_movto.cdcooper%TYPE
                     ,pr_dtbase    IN tbrisco_provisgarant_movto.dtbase%TYPE
                     ,pr_idproduto IN tbrisco_provisgarant_movto.idproduto%TYPE
                     ,pr_nrdconta  IN tbrisco_provisgarant_movto.nrdconta%TYPE
                     ,pr_nrctremp  IN tbrisco_provisgarant_movto.nrctremp%TYPE
                     ,pr_idmovto_risco IN tbrisco_provisgarant_movto.idmovto_risco%TYPE) IS       
    SELECT 1
      FROM tbrisco_provisgarant_movto 
     WHERE cdcooper  = pr_cdcooper
       AND dtbase    = pr_dtbase
       AND idproduto = pr_idproduto
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp
       AND idmovto_risco <> pr_idmovto_risco;
    rw_movto_1 cr_movto_1%ROWTYPE;
    
    CURSOR cr_movto_2(pr_idmovto_risco IN tbrisco_provisgarant_movto.idmovto_risco%TYPE) IS       
    SELECT *
      FROM tbrisco_provisgarant_movto
     WHERE idmovto_risco = pr_idmovto_risco;
    rw_movto_2 cr_movto_2%ROWTYPE;
    
    CURSOR cr_risco_prodt(pr_idproduto IN tbrisco_provisgarant_prodt.idproduto%TYPE)IS
    SELECT ppg.idorigem_recurso,
           ppg.idindexador,
           ppg.perindexador,
           ppg.idnat_operacao,
           ppg.flpermite_saida_operacao,
           ppg.flpermite_fluxo_financeiro,
           ppg.vltaxa_juros,
           ppg.cdclassifica_operacao,
           ppg.idgarantia,
           ppg.idproduto
      FROM tbrisco_provisgarant_prodt ppg
     WHERE ppg.idproduto = pr_idproduto;
     rw_risco_prodt cr_risco_prodt%ROWTYPE;
       
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_dtrefere DATE;
    vr_dtlib_operacao DATE;
    vr_dtproxima_parcela DATE;
    vr_dtvenc_operacao DATE;
    vr_des_erro VARCHAR2(10);
        
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    vr_exc_saida EXCEPTION;
    
  BEGIN 
    
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'MOVRGP'
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
    
    IF trim(pr_cddopcao) IS NULL OR
       pr_cddopcao <> 'A'        THEN
       
      -- Montar mensagem de critica
      pr_nmdcampo := 'dsproduto';
      vr_dscritic := 'C�digo da op��o inv�lida.';
      RAISE vr_exc_erro;
      
    END IF;
       
    IF NVL(pr_idmovto_risco,0) = 0 THEN               
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'dsproduto';
      vr_dscritic := 'C�digo do movimento inv�lido.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF NVL(pr_cdcopsel,0) = 0 THEN               
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'dsproduto';
      vr_dscritic := 'C�digo da cooperativa inv�lido.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF TRIM(pr_dtrefere) IS NULL THEN
      
      -- Montar mensagem de critica
      vr_dscritic := 'Data de refer�ncia n�o informada.';
      RAISE vr_exc_erro;
      
    END IF;

    BEGIN
      
      vr_dtrefere:= to_date(pr_dtrefere,'dd/mm/rrrr');
      
    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        vr_dscritic := 'Data de refer�ncia inv�lida.';
        RAISE vr_exc_erro;
        
    END;

    IF vr_dtrefere >= last_day(trunc(SYSDATE)) THEN
      
      -- Montar mensagem de critica
      vr_dscritic := 'Dt. Ref. Inv�lida � Favor selecionar data anterior ou igual a ' || to_char(last_day(add_months(sysdate,-1)),'dd/mm/rrrr' ) || '.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF NVL(pr_idproduto,0) = 0 THEN               
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'dsproduto';
      vr_dscritic := 'C�digo do produto inv�lido.';
      RAISE vr_exc_erro;
        
    END IF;
    
    OPEN cr_risco_prodt(pr_idproduto => pr_idproduto);
      
    FETCH cr_risco_prodt INTO rw_risco_prodt;
      
    IF cr_risco_prodt%NOTFOUND THEN
        
      CLOSE cr_risco_prodt;
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'idproduto';
      vr_dscritic := 'Par�metros n�o encontrados.';
      RAISE vr_exc_erro;
      
    END IF;
      
    CLOSE cr_risco_prodt;
    
    IF NVL(pr_nrdconta,0) = 0 THEN               
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'nrdconta';
      vr_dscritic := 'Conta inv�lida.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF NVL(pr_nrcpfcgc,0) = 0 THEN               
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'nrdconta';
      vr_dscritic := 'CPF/CNPJ inv�lido.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF NVL(pr_nrctremp,0) = 0 THEN               
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'nrctremp';
      vr_dscritic := 'N�mero do contrato inv�lido.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF NVL(pr_idgarantia,0) = 0                           OR
       RISC0003.fn_valor_opcao_dominio(pr_idgarantia) = 0 THEN
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'idgarantia';
      vr_dscritic := 'C�digo da garantia inv�lida.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF NVL(pr_idorigem_recurso,0) = 0                           OR
       RISC0003.fn_valor_opcao_dominio(pr_idorigem_recurso) = 0 THEN
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'idorigem_recurso';
      vr_dscritic := 'C�digo de origem do recurso inv�lida.';
      RAISE vr_exc_erro;
        
    END IF;
      
    IF NVL(pr_idindexador,0) = 0                           OR
       RISC0003.fn_valor_opcao_dominio(pr_idindexador) = 0 THEN
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'idindexador';
      vr_dscritic := 'Indexador inv�lido.';
      RAISE vr_exc_erro;
        
    END IF;
      
    IF NVL(pr_vltaxa_juros,0) = 0 THEN
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'vltaxa_juros';
      vr_dscritic := 'Valor da taxa de juros inv�lida.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF TRIM(pr_dtlib_operacao) IS NULL THEN
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'dtlib_operacao';
      vr_dscritic := 'Data de libera��o da opera��o n�o informada.';
      RAISE vr_exc_erro;
      
    END IF;

    BEGIN
      
      vr_dtlib_operacao:= to_date(pr_dtlib_operacao,'dd/mm/rrrr');
      
    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        pr_nmdcampo := 'dtlib_operacao';
        vr_dscritic := 'Data de libera��o da opera��o n�o informada.';
        RAISE vr_exc_erro;
        
    END;
    
    IF NVL(pr_vloperacao,0) = 0 THEN
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'vloperacao';
      vr_dscritic := 'Valor da opera��o inv�lida.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF NVL(pr_idnat_operacao,0) = 0                           OR
       RISC0003.fn_valor_opcao_dominio(pr_idnat_operacao) = 0 THEN
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'idnat_operacao';
      vr_dscritic := 'Natureza de opera��O inv�lida.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF TRIM(pr_dtvenc_operacao) IS NULL THEN
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'dtvenc_operacao';
      vr_dscritic := 'Data de vencimento da opera��o n�o informada.';
      RAISE vr_exc_erro;
      
    END IF;

    BEGIN
      
      vr_dtvenc_operacao:= to_date(pr_dtvenc_operacao,'dd/mm/rrrr');
      
    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        pr_nmdcampo := 'dtvenc_operacao';
        vr_dscritic := 'Data de vencimento da opera��o n�o informada.';
        RAISE vr_exc_erro;
        
    END;
    
    IF NVL(TRIM(pr_cdclassifica_operacao), ' ') NOT IN ('AA','A','B','C','D','E','F','G','H','HH') THEN 
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'cdclassificao';
      vr_dscritic := 'C�digo da classifica��o inv�lida.';
      RAISE vr_exc_erro;
        
    END IF;  
    
    IF rw_risco_prodt.cdclassifica_operacao = 'AA' AND
       pr_cdclassifica_operacao <> 'AA'            THEN 
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'cdclassificao';
      vr_dscritic := 'C�digo da classifica��o inv�lida para o produto informado.';
      RAISE vr_exc_erro;
        
    END IF;         
                       
    IF rw_risco_prodt.flpermite_fluxo_financeiro = 1 AND
       NVL(pr_qtdparcelas,0) = 0                     THEN
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'qtdparcelas';
      vr_dscritic := 'Quantidade de parcelas inv�lida.';
      RAISE vr_exc_erro;
        
    END IF;
      
    IF rw_risco_prodt.flpermite_fluxo_financeiro = 1 AND 
       NVL(pr_vlparcela,0) = 0                       THEN
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'vlparcela';
      vr_dscritic := 'Valor da parcela inv�lida.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF rw_risco_prodt.flpermite_fluxo_financeiro = 1 AND
       TRIM(pr_dtproxima_parcela) IS NULL            THEN
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'dtproxima_parcela';
      vr_dscritic := 'Data da pr�xima parcela n�o informada.';
      RAISE vr_exc_erro;
      
    END IF;

    BEGIN
      
      vr_dtproxima_parcela:= to_date(pr_dtproxima_parcela,'dd/mm/rrrr');
      
    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        pr_nmdcampo := 'dtproxima_parcela';
        vr_dscritic := 'Data da pr�xima parcela inv�lida.';
        RAISE vr_exc_erro;
        
    END;  
    
    IF vr_dtproxima_parcela <= vr_dtrefere THEN
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'dtproxima_parcela';
      vr_dscritic := 'Data da pr�xima parcela inv�lida: Favor preencher uma data superior a ' || to_char(vr_dtrefere,'DD/MM/RRRR');
      RAISE vr_exc_erro;
      
    END IF;
    
    IF pr_flsaida_operacao NOT IN(0,1) THEN
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'flsaida_operacao';
      vr_dscritic := 'Sa�da de opera��o inv�lida.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF pr_flsaida_operacao = 0        AND 
       NVL(pr_vlsaldo_pendente,0) = 0 THEN
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'vlsaldo_pendente';
      vr_dscritic := 'Valor do saldo pendente inv�lido.';
      RAISE vr_exc_erro;
        
    END IF;
      
    OPEN cr_movto_1(pr_cdcooper  => pr_cdcopsel
                   ,pr_dtbase    => vr_dtrefere
                   ,pr_idproduto => pr_idproduto
                   ,pr_nrdconta  => pr_nrdconta
                   ,pr_nrctremp  => pr_nrctremp
                   ,pr_idmovto_risco => pr_idmovto_risco); 
                                        
    FETCH cr_movto_1 INTO rw_movto_1;
        
    IF cr_movto_1%FOUND THEN
          
      CLOSE cr_movto_1;
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'nrctremp';
      vr_dscritic := 'Aten��o: J� existe outro movimento com esta numera��o de Contrato, favor revisar o cadastro!';
      RAISE vr_exc_erro; 
              
    END IF;
      
    CLOSE cr_movto_1; 
    
    OPEN cr_movto_2(pr_idmovto_risco => pr_idmovto_risco);
                   
    FETCH cr_movto_2 INTO rw_movto_2;
    
    IF cr_movto_2%NOTFOUND THEN
      
      --Fecha o cursor
      CLOSE cr_movto_2;

      -- Montar mensagem de critica
      vr_dscritic := 'Movimento n�o encontrado.';
      RAISE vr_exc_erro;
    
    END IF;
    
    --Fecha o cursor
    CLOSE cr_movto_2;
    
    BEGIN
      
      UPDATE tbrisco_provisgarant_movto
         SET tbrisco_provisgarant_movto.nrdconta = pr_nrdconta
            ,tbrisco_provisgarant_movto.nrctremp = pr_nrctremp
            ,tbrisco_provisgarant_movto.nrcpfcgc = pr_nrcpfcgc
            ,tbrisco_provisgarant_movto.idorigem_recurso = pr_idorigem_recurso 
            ,tbrisco_provisgarant_movto.idindexador = pr_idindexador
            ,tbrisco_provisgarant_movto.perindexador = nvl(pr_perindexador,0)
            ,tbrisco_provisgarant_movto.idgarantia = pr_idgarantia
            ,tbrisco_provisgarant_movto.vltaxa_juros = pr_vltaxa_juros
            ,tbrisco_provisgarant_movto.dtlib_operacao = vr_dtlib_operacao
            ,tbrisco_provisgarant_movto.vloperacao = pr_vloperacao
            ,tbrisco_provisgarant_movto.idnat_operacao = pr_idnat_operacao
            ,tbrisco_provisgarant_movto.dtvenc_operacao = vr_dtvenc_operacao
            ,tbrisco_provisgarant_movto.cdclassifica_operacao = pr_cdclassifica_operacao
            ,tbrisco_provisgarant_movto.qtdparcelas = decode(rw_risco_prodt.flpermite_fluxo_financeiro,1,pr_qtdparcelas,tbrisco_provisgarant_movto.qtdparcelas)
            ,tbrisco_provisgarant_movto.vlparcela = decode(rw_risco_prodt.flpermite_fluxo_financeiro,1,pr_vlparcela,tbrisco_provisgarant_movto.vlparcela)
            ,tbrisco_provisgarant_movto.dtproxima_parcela = decode(rw_risco_prodt.flpermite_fluxo_financeiro,1,vr_dtproxima_parcela,tbrisco_provisgarant_movto.dtproxima_parcela)
            ,tbrisco_provisgarant_movto.vlsaldo_pendente = pr_vlsaldo_pendente
            ,tbrisco_provisgarant_movto.flsaida_operacao = decode(rw_risco_prodt.flpermite_saida_operacao,1,pr_flsaida_operacao,tbrisco_provisgarant_movto.flsaida_operacao)
       WHERE tbrisco_provisgarant_movto.idmovto_risco = pr_idmovto_risco;
    
    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        vr_dscritic := 'N�o foi poss�vel alterar o movimento.';
        RAISE vr_exc_erro;
    
    END;
    
    pc_gera_log(pr_cdcooper => vr_cdcooper -- C�digo da cooperativa
               ,pr_idproduto => pr_idproduto --C�digo do produto
               ,pr_cdoperad => vr_cdoperad -- Operador
               ,pr_dsdcampo => 'Conta'  --Descri��o do campo
               ,pr_vlrcampo => gene0002.fn_mask_conta(rw_movto_2.nrdconta)   --Valor antigo
               ,pr_vlcampo2 => gene0002.fn_mask_conta(pr_nrdconta)  --Valor atual
               ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_erro;

    END IF;
    
    pc_gera_log(pr_cdcooper => vr_cdcooper -- C�digo da cooperativa
               ,pr_idproduto => pr_idproduto --C�digo do produto
               ,pr_cdoperad => vr_cdoperad -- Operador
               ,pr_dsdcampo => 'CPF/CNPJ'  --Descri��o do campo
               ,pr_vlrcampo => rw_movto_2.nrcpfcgc   --Valor antigo
               ,pr_vlcampo2 => pr_nrcpfcgc  --Valor atual
               ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_erro;

    END IF;
    
    pc_gera_log(pr_cdcooper => vr_cdcooper -- C�digo da cooperativa
               ,pr_idproduto => pr_idproduto --C�digo do produto
               ,pr_cdoperad => vr_cdoperad -- Operador
               ,pr_dsdcampo => 'Contrato'  --Descri��o do campo
               ,pr_vlrcampo => to_char(rw_movto_2.nrctremp,'fm9999g999g990')   --Valor antigo
               ,pr_vlcampo2 => to_char(pr_nrctremp,'fm9999g999g990')  --Valor atual
               ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_erro;

    END IF;
      
    pc_gera_log(pr_cdcooper => vr_cdcooper -- C�digo da cooperativa
               ,pr_idproduto => pr_idproduto --C�digo do produto
               ,pr_cdoperad => vr_cdoperad -- Operador
               ,pr_dsdcampo => 'Garantia'  --Descri��o do campo
               ,pr_vlrcampo => RISC0003.fn_valor_opcao_dominio(rw_movto_2.idgarantia)   --Valor antigo
               ,pr_vlcampo2 => RISC0003.fn_valor_opcao_dominio(pr_idgarantia)  --Valor atual
               ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_erro;

    END IF;
    
    pc_gera_log(pr_cdcooper => vr_cdcooper -- C�digo da cooperativa
               ,pr_idproduto => pr_idproduto --C�digo do produto
               ,pr_cdoperad => vr_cdoperad -- Operador
               ,pr_dsdcampo => 'Origem Recurso'  --Descri��o do campo
               ,pr_vlrcampo => RISC0003.fn_valor_opcao_dominio(rw_movto_2.idorigem_recurso)   --Valor antigo
               ,pr_vlcampo2 => RISC0003.fn_valor_opcao_dominio(pr_idorigem_recurso)  --Valor atual
               ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_erro;

    END IF;
    
    pc_gera_log(pr_cdcooper => vr_cdcooper -- C�digo da cooperativa
               ,pr_idproduto => pr_idproduto --C�digo do produto
               ,pr_cdoperad => vr_cdoperad -- Operador
               ,pr_dsdcampo => 'Indexador'  --Descri��o do campo
               ,pr_vlrcampo => RISC0003.fn_valor_opcao_dominio(rw_movto_2.idindexador)  --Valor antigo
               ,pr_vlcampo2 => RISC0003.fn_valor_opcao_dominio(pr_idindexador)  --Valor atual
               ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_erro;

    END IF;
      
    pc_gera_log(pr_cdcooper => vr_cdcooper -- C�digo da cooperativa
               ,pr_idproduto => pr_idproduto --C�digo do produto
               ,pr_cdoperad => vr_cdoperad -- Operador
               ,pr_dsdcampo => 'Perc. Indexador'  --Descri��o do campo
               ,pr_vlrcampo => to_char(rw_movto_2.perindexador,'990D0000000','NLS_NUMERIC_CHARACTERS='',.''') --Valor antigo 
               ,pr_vlcampo2 => to_char(pr_perindexador,'990D0000000','NLS_NUMERIC_CHARACTERS='',.''')  --Valor atual
               ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_erro;

    END IF;
    
    pc_gera_log(pr_cdcooper => vr_cdcooper -- C�digo da cooperativa
               ,pr_idproduto => pr_idproduto --C�digo do produto
               ,pr_cdoperad => vr_cdoperad -- Operador
               ,pr_dsdcampo => 'Valor taxa de juros'  --Descri��o do campo
               ,pr_vlrcampo => to_char(rw_movto_2.vltaxa_juros,'990D0000000','NLS_NUMERIC_CHARACTERS='',.''') --Valor antigo
               ,pr_vlcampo2 => to_char(pr_vltaxa_juros,'990D0000000','NLS_NUMERIC_CHARACTERS='',.''') --Valor atual
               ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_erro;

    END IF;
    
    pc_gera_log(pr_cdcooper => vr_cdcooper -- C�digo da cooperativa
               ,pr_idproduto => pr_idproduto --C�digo do produto
               ,pr_cdoperad => vr_cdoperad -- Operador
               ,pr_dsdcampo => 'Data de liberacao da operacao'  --Descri��o do campo
               ,pr_vlrcampo => to_char(rw_movto_2.dtlib_operacao,'DD/MM/RRRR') --Valor antigo
               ,pr_vlcampo2 => to_char(vr_dtlib_operacao,'DD/MM/RRRR') --Valor atual
               ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_erro;

    END IF;
    
    pc_gera_log(pr_cdcooper => vr_cdcooper -- C�digo da cooperativa
               ,pr_idproduto => pr_idproduto --C�digo do produto
               ,pr_cdoperad => vr_cdoperad -- Operador
               ,pr_dsdcampo => 'Valor da operacao'  --Descri��o do campo
               ,pr_vlrcampo => to_char(rw_movto_2.vloperacao,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''') --Valor antigo
               ,pr_vlcampo2 => to_char(pr_vloperacao,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''') --Valor atual
               ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_erro;

    END IF;
    
    pc_gera_log(pr_cdcooper => vr_cdcooper -- C�digo da cooperativa
               ,pr_idproduto => pr_idproduto --C�digo do produto
               ,pr_cdoperad => vr_cdoperad -- Operador
               ,pr_dsdcampo => 'Nat. Operacao'  --Descri��o do campo
               ,pr_vlrcampo => RISC0003.fn_valor_opcao_dominio(rw_movto_2.idnat_operacao)   --Valor antigo
               ,pr_vlcampo2 => RISC0003.fn_valor_opcao_dominio(pr_idnat_operacao)  --Valor atual
               ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_erro;

    END IF;
    
    pc_gera_log(pr_cdcooper => vr_cdcooper -- C�digo da cooperativa
               ,pr_idproduto => pr_idproduto --C�digo do produto
               ,pr_cdoperad => vr_cdoperad -- Operador
               ,pr_dsdcampo => 'Data de vencimento da operacao'  --Descri��o do campo
               ,pr_vlrcampo => to_char(rw_movto_2.dtvenc_operacao,'DD/MM/RRRR')   --Valor antigo
               ,pr_vlcampo2 => to_char(vr_dtvenc_operacao,'DD/MM/RRRR')  --Valor atual
               ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_erro;

    END IF;
    
    pc_gera_log(pr_cdcooper => vr_cdcooper -- C�digo da cooperativa
               ,pr_idproduto => pr_idproduto --C�digo do produto
               ,pr_cdoperad => vr_cdoperad -- Operador
               ,pr_dsdcampo => 'Classificacao da operacao'  --Descri��o do campo
               ,pr_vlrcampo => rw_movto_2.cdclassifica_operacao   --Valor antigo
               ,pr_vlcampo2 => pr_cdclassifica_operacao  --Valor atual
               ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_erro;

    END IF;
    
    pc_gera_log(pr_cdcooper => vr_cdcooper -- C�digo da cooperativa
               ,pr_idproduto => pr_idproduto --C�digo do produto
               ,pr_cdoperad => vr_cdoperad -- Operador
               ,pr_dsdcampo => 'Quantidade de parcelas'  --Descri��o do campo
               ,pr_vlrcampo => to_char(rw_movto_2.qtdparcelas,'fm9999g999g990')   --Valor antigo
               ,pr_vlcampo2 => to_char(pr_qtdparcelas,'fm9999g999g990')  --Valor atual
               ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_erro;

    END IF;
    
    pc_gera_log(pr_cdcooper => vr_cdcooper -- C�digo da cooperativa
               ,pr_idproduto => pr_idproduto --C�digo do produto
               ,pr_cdoperad => vr_cdoperad -- Operador
               ,pr_dsdcampo => 'Valor da parcela'  --Descri��o do campo
               ,pr_vlrcampo => to_char(rw_movto_2.vlparcela,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''') --Valor antigo
               ,pr_vlcampo2 => to_char(pr_vlparcela,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''') --Valor atual
               ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_erro;

    END IF;
    
    pc_gera_log(pr_cdcooper => vr_cdcooper -- C�digo da cooperativa
               ,pr_idproduto => pr_idproduto --C�digo do produto
               ,pr_cdoperad => vr_cdoperad -- Operador
               ,pr_dsdcampo => 'Data da proxima parcela'  --Descri��o do campo
               ,pr_vlrcampo => to_char(rw_movto_2.dtproxima_parcela,'DD/MM/RRRR')   --Valor antigo
               ,pr_vlcampo2 => to_char(vr_dtproxima_parcela,'DD/MM/RRRR')  --Valor atual
               ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_erro;

    END IF;
    
    pc_gera_log(pr_cdcooper => vr_cdcooper -- C�digo da cooperativa
               ,pr_idproduto => pr_idproduto --C�digo do produto
               ,pr_cdoperad => vr_cdoperad -- Operador
               ,pr_dsdcampo => 'Valor do saldo pendente'  --Descri��o do campo
               ,pr_vlrcampo => to_char(rw_movto_2.vlsaldo_pendente,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''') --Valor antigo
               ,pr_vlcampo2 => to_char(pr_vlsaldo_pendente,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''') --Valor atual
               ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_erro;

    END IF;
    
    pc_gera_log(pr_cdcooper => vr_cdcooper -- C�digo da cooperativa
               ,pr_idproduto => pr_idproduto --C�digo do produto
               ,pr_cdoperad => vr_cdoperad -- Operador
               ,pr_dsdcampo => 'Saida de operacao'  --Descri��o do campo
               ,pr_vlrcampo => (CASE WHEN rw_movto_2.flsaida_operacao = 0 THEN 'Nao' ELSE 'Sim' END) --Valor antigo
               ,pr_vlcampo2 => (CASE WHEN pr_flsaida_operacao = 0 THEN 'Nao' ELSE 'Sim' END)  --Valor atual
               ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_erro;

    END IF;
      
    pr_des_erro := 'OK';
    
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_alterar_movimento --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_alterar_movimento;
 
  PROCEDURE pc_incluir_movimento(pr_cdcopsel              IN tbrisco_provisgarant_movto.cdcooper%TYPE --C�digo da cooperativa
                                ,pr_dtrefere              IN VARCHAR2 --Data de refer�ncia
                                ,pr_idproduto             IN tbrisco_provisgarant_movto.idproduto%TYPE --C�digo do produto
                                ,pr_nrdconta              IN tbrisco_provisgarant_movto.nrdconta%TYPE --N�mero da conta
                                ,pr_nrcpfcgc              IN tbrisco_provisgarant_movto.nrcpfcgc%TYPE --CPF/CNPJ
                                ,pr_nrctremp              IN tbrisco_provisgarant_movto.nrctremp%TYPE --N�mero do contrato
                                ,pr_idgarantia            IN tbrisco_provisgarant_movto.idgarantia%TYPE --C�digo da garantia
                                ,pr_idorigem_recurso      IN tbrisco_provisgarant_movto.idorigem_recurso%TYPE --C�digo de origem do recurso
                                ,pr_idindexador           IN tbrisco_provisgarant_movto.idindexador%TYPE --C�digo do indexador
                                ,pr_perindexador          IN tbrisco_provisgarant_movto.perindexador%TYPE --Percentual do indexador
                                ,pr_vltaxa_juros          IN tbrisco_provisgarant_movto.vltaxa_juros%TYPE --Valor da taxa de juros
                                ,pr_dtlib_operacao        IN VARCHAR2 --Data de libera��o da opera��o
                                ,pr_vloperacao            IN tbrisco_provisgarant_movto.vloperacao%TYPE --Valor da opera��o
                                ,pr_idnat_operacao        IN tbrisco_provisgarant_movto.idnat_operacao%TYPE --C�digo da natureza de opera��o
                                ,pr_dtvenc_operacao       IN VARCHAR2 --Data de vencimento da opera��o
                                ,pr_cdclassifica_operacao IN tbrisco_provisgarant_movto.cdclassifica_operacao%TYPE --C�digo da classifica��o de opera��o
                                ,pr_qtdparcelas           IN tbrisco_provisgarant_movto.qtdparcelas%TYPE --Quantidade de parcelas
                                ,pr_vlparcela             IN tbrisco_provisgarant_movto.vlparcela%TYPE --Valor da parcela
                                ,pr_dtproxima_parcela     IN VARCHAR2 --Data da pr�xima parcela
                                ,pr_vlsaldo_pendente      IN tbrisco_provisgarant_movto.vlsaldo_pendente%TYPE --Valor pendente
                                ,pr_flsaida_operacao      IN tbrisco_provisgarant_movto.flsaida_operacao%TYPE --Saida opera��o
                                ,pr_cddopcao IN VARCHAR2      --N�mero da conta
                                ,pr_xmllog   IN VARCHAR2      --XML com informa��es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER  --C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2     --Descri��o da cr�tica
                                ,pr_retxml   IN OUT NOCOPY XMLType --Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2     --Nome do Campo
                                ,pr_des_erro OUT VARCHAR2)IS  --Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_incluir_movimento                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonata - RKAM
    Data     : Maio/2017                           Ultima atualizacao: 01/06/2017
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Realiza a inclus�o de moviemtnos da tela MOVRGP
    
    Altera��es : 01/06/2017 - Ajuste para retirar valida��o de valor do percentaul, poder� ser enviado valor zerado
                             (Jonata - RKAM).
                            
    -------------------------------------------------------------------------------------------------------------*/                                
      
    CURSOR cr_movto_1(pr_cdcooper  IN tbrisco_provisgarant_movto.cdcooper%TYPE
                     ,pr_dtbase    IN tbrisco_provisgarant_movto.dtbase%TYPE
                     ,pr_idproduto IN tbrisco_provisgarant_movto.idproduto%TYPE
                     ,pr_nrdconta  IN tbrisco_provisgarant_movto.nrdconta%TYPE
                     ,pr_nrctremp  IN tbrisco_provisgarant_movto.nrctremp%TYPE) IS       
    SELECT 1
      FROM tbrisco_provisgarant_movto 
     WHERE cdcooper = pr_cdcooper
       AND dtbase   = pr_dtbase
       AND idproduto = pr_idproduto
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp;
    rw_movto_1 cr_movto_1%ROWTYPE;
    
    CURSOR cr_risco_prodt(pr_idproduto IN tbrisco_provisgarant_prodt.idproduto%TYPE)IS
    SELECT ppg.idorigem_recurso,
           ppg.idindexador,
           ppg.perindexador,
           ppg.idnat_operacao,
           ppg.flpermite_saida_operacao,
           ppg.flpermite_fluxo_financeiro,
           ppg.vltaxa_juros,
           ppg.cdclassifica_operacao,
           ppg.idgarantia,
           ppg.idproduto
      FROM tbrisco_provisgarant_prodt ppg
     WHERE ppg.idproduto = pr_idproduto;
     rw_risco_prodt cr_risco_prodt%ROWTYPE;
       
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_dtrefere DATE;
    vr_dtlib_operacao DATE;
    vr_dtproxima_parcela DATE;
    vr_dtvenc_operacao DATE;
    vr_idmovto_risco tbrisco_provisgarant_movto.idmovto_risco%TYPE;
        
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    vr_exc_saida EXCEPTION;
    
  BEGIN 
    
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'MOVRGP'
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
    
    IF trim(pr_cddopcao) IS NULL OR
       pr_cddopcao <> 'I'        THEN
       
      -- Montar mensagem de critica
      pr_nmdcampo := 'dsproduto';
      vr_dscritic := 'C�digo da op��o inv�lida.';
      RAISE vr_exc_erro;
      
    END IF;
       
    IF NVL(pr_cdcopsel,0) = 0 THEN               
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'dsproduto';
      vr_dscritic := 'C�digo da cooperativa inv�lido.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF TRIM(pr_dtrefere) IS NULL THEN
      
      -- Montar mensagem de critica
      vr_dscritic := 'Data de refer�ncia n�o informada.';
      RAISE vr_exc_erro;
      
    END IF;

    BEGIN
      
      vr_dtrefere:= to_date(pr_dtrefere,'dd/mm/rrrr');
      
    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        vr_dscritic := 'Data de refer�ncia inv�lida.';
        RAISE vr_exc_erro;
        
    END;   
    
    IF vr_dtrefere >= last_day(trunc(SYSDATE)) THEN
      
      -- Montar mensagem de critica
      vr_dscritic := 'Dt. Ref. Inv�lida � Favor selecionar data anterior ou igual a ' || to_char(last_day(add_months(sysdate,-1)),'dd/mm/rrrr' ) || '.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF NVL(pr_idproduto,0) = 0 THEN               
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'dsproduto';
      vr_dscritic := 'C�digo do produto inv�lido.';
      RAISE vr_exc_erro;
        
    END IF;
    
    OPEN cr_risco_prodt(pr_idproduto => pr_idproduto);
      
    FETCH cr_risco_prodt INTO rw_risco_prodt;
      
    IF cr_risco_prodt%NOTFOUND THEN
        
      CLOSE cr_risco_prodt;
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'idproduto';
      vr_dscritic := 'Par�metros n�o encontrados.';
      RAISE vr_exc_erro;
      
    END IF;
      
    CLOSE cr_risco_prodt;
    
    IF NVL(pr_nrdconta,0) = 0 THEN               
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'nrdconta';
      vr_dscritic := 'Conta inv�lida.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF NVL(pr_nrcpfcgc,0) = 0 THEN               
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'nrdconta';
      vr_dscritic := 'CPF/CNPJ inv�lido.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF NVL(pr_nrctremp,0) = 0 THEN               
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'nrctremp';
      vr_dscritic := 'N�mero do contrato inv�lido.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF NVL(pr_idgarantia,0) = 0                           OR
       RISC0003.fn_valor_opcao_dominio(pr_idgarantia) = 0 THEN
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'idgarantia';
      vr_dscritic := 'C�digo da garantia inv�lida.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF NVL(pr_idorigem_recurso,0) = 0                           OR
       RISC0003.fn_valor_opcao_dominio(pr_idorigem_recurso) = 0 THEN
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'idorigem_recurso';
      vr_dscritic := 'C�digo de origem do recurso inv�lida.';
      RAISE vr_exc_erro;
        
    END IF;
      
    IF NVL(pr_idindexador,0) = 0                           OR
       RISC0003.fn_valor_opcao_dominio(pr_idindexador) = 0 THEN
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'idindexador';
      vr_dscritic := 'Indexador inv�lido.';
      RAISE vr_exc_erro;
        
    END IF;
      
    IF NVL(pr_vltaxa_juros,0) = 0 THEN
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'vltaxa_juros';
      vr_dscritic := 'Valor da taxa de juros inv�lida.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF TRIM(pr_dtlib_operacao) IS NULL THEN
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'dtlib_operacao';
      vr_dscritic := 'Data de libera��o da opera��o n�o informada.';
      RAISE vr_exc_erro;
      
    END IF;

    BEGIN
      
      vr_dtlib_operacao:= to_date(pr_dtlib_operacao,'dd/mm/rrrr');
      
    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        pr_nmdcampo := 'dtlib_operacao';
        vr_dscritic := 'Data de libera��o da opera��o n�o informada.';
        RAISE vr_exc_erro;
        
    END;
    
    IF NVL(pr_vloperacao,0) = 0 THEN
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'vloperacao';
      vr_dscritic := 'Valor da opera��o inv�lida.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF NVL(pr_idnat_operacao,0) = 0                           OR
       RISC0003.fn_valor_opcao_dominio(pr_idnat_operacao) = 0 THEN
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'idnat_operacao';
      vr_dscritic := 'Natureza de opera��O inv�lida.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF TRIM(pr_dtvenc_operacao) IS NULL THEN
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'dtvenc_operacao';
      vr_dscritic := 'Data de vencimento da opera��o n�o informada.';
      RAISE vr_exc_erro;
      
    END IF;

    BEGIN
      
      vr_dtvenc_operacao:= to_date(pr_dtvenc_operacao,'dd/mm/rrrr');
      
    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        pr_nmdcampo := 'dtvenc_operacao';
        vr_dscritic := 'Data de vencimento da opera��o n�o informada.';
        RAISE vr_exc_erro;
        
    END;
    
    IF NVL(TRIM(pr_cdclassifica_operacao), ' ') NOT IN ('AA','A','B','C','D','E','F','G','H','HH') THEN 
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'cdclassificao';
      vr_dscritic := 'C�digo da classifica��o inv�lida.';
      RAISE vr_exc_erro;
        
    END IF;     
    
    IF rw_risco_prodt.cdclassifica_operacao = 'AA' AND
       pr_cdclassifica_operacao <> 'AA'            THEN 
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'cdclassificao';
      vr_dscritic := 'C�digo da classifica��o inv�lida para o produto informado.';
      RAISE vr_exc_erro;
        
    END IF;       
                       
    IF rw_risco_prodt.flpermite_fluxo_financeiro = 1 AND
       NVL(pr_qtdparcelas,0) = 0                     THEN
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'qtdparcelas';
      vr_dscritic := 'Quantidade de parcelas inv�lida.';
      RAISE vr_exc_erro;
        
    END IF;
      
    IF rw_risco_prodt.flpermite_fluxo_financeiro = 1 AND 
       NVL(pr_vlparcela,0) = 0                       THEN
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'vlparcela';
      vr_dscritic := 'Valor da parcela inv�lida.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF rw_risco_prodt.flpermite_fluxo_financeiro = 1 AND
       TRIM(pr_dtproxima_parcela) IS NULL            THEN
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'dtproxima_parcela';
      vr_dscritic := 'Data da pr�xima parcela n�o informada.';
      RAISE vr_exc_erro;
      
    END IF;

    BEGIN
      
      vr_dtproxima_parcela:= to_date(pr_dtproxima_parcela,'dd/mm/rrrr');
      
    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        pr_nmdcampo := 'dtproxima_parcela';
        vr_dscritic := 'Data da pr�xima parcela inv�lida.';
        RAISE vr_exc_erro;
        
    END;  
    
    IF vr_dtproxima_parcela <= vr_dtrefere THEN
      
      -- Montar mensagem de critica
      pr_nmdcampo := 'dtproxima_parcela';
      vr_dscritic := 'Data da pr�xima parcela inv�lida: Favor preencher uma data superior a ' || to_char(vr_dtrefere,'DD/MM/RRRR');
      RAISE vr_exc_erro;
      
    END IF;
    
    IF pr_flsaida_operacao NOT IN(0,1) THEN
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'flsaida_operacao';
      vr_dscritic := 'Sa�da de opera��o inv�lida.';
      RAISE vr_exc_erro;
        
    END IF;
    
    IF pr_flsaida_operacao = 0        AND
       NVL(pr_vlsaldo_pendente,0) = 0 THEN
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'vlsaldo_pendente';
      vr_dscritic := 'Valor do saldo pendente inv�lido.';
      RAISE vr_exc_erro;
        
    END IF;
    
    OPEN cr_crapcop(pr_cdcooper => pr_cdcopsel);
    
    FETCH cr_crapcop INTO rw_crapcop;
    
    IF cr_crapcop%NOTFOUND THEN
      
      CLOSE cr_crapcop;
      
      -- Montar mensagem de critica
      vr_dscritic := 'Cooperativa n�o encontrada.';
      RAISE vr_exc_erro;
    
    END IF;
    
    CLOSE cr_crapcop;
      
    OPEN cr_movto_1(pr_cdcooper  => pr_cdcopsel
                   ,pr_dtbase    => vr_dtrefere
                   ,pr_idproduto => pr_idproduto
                   ,pr_nrdconta  => pr_nrdconta
                   ,pr_nrctremp  => pr_nrctremp); 
                                        
    FETCH cr_movto_1 INTO rw_movto_1;
        
    IF cr_movto_1%FOUND THEN
          
      CLOSE cr_movto_1;
        
      -- Montar mensagem de critica
      pr_nmdcampo := 'nrctremp';
      vr_dscritic := 'Aten��o: J� existe outro movimento com esta numera��o de Contrato, favor revisar o cadastro!';
      RAISE vr_exc_erro; 
              
    END IF;
      
    CLOSE cr_movto_1; 
    
    BEGIN
      
      INSERT INTO tbrisco_provisgarant_movto
                 (tbrisco_provisgarant_movto.cdcooper
                 ,tbrisco_provisgarant_movto.dtbase
                 ,tbrisco_provisgarant_movto.idproduto
                 ,tbrisco_provisgarant_movto.nrdconta
                 ,tbrisco_provisgarant_movto.nrctremp
                 ,tbrisco_provisgarant_movto.nrcpfcgc
                 ,tbrisco_provisgarant_movto.idorigem_recurso
                 ,tbrisco_provisgarant_movto.idindexador
                 ,tbrisco_provisgarant_movto.perindexador
                 ,tbrisco_provisgarant_movto.idgarantia
                 ,tbrisco_provisgarant_movto.vltaxa_juros
                 ,tbrisco_provisgarant_movto.dtlib_operacao
                 ,tbrisco_provisgarant_movto.vloperacao
                 ,tbrisco_provisgarant_movto.idnat_operacao
                 ,tbrisco_provisgarant_movto.dtvenc_operacao
                 ,tbrisco_provisgarant_movto.cdclassifica_operacao
                 ,tbrisco_provisgarant_movto.qtdparcelas
                 ,tbrisco_provisgarant_movto.vlparcela
                 ,tbrisco_provisgarant_movto.dtproxima_parcela
                 ,tbrisco_provisgarant_movto.vlsaldo_pendente
                 ,tbrisco_provisgarant_movto.flsaida_operacao)
          VALUES(pr_cdcopsel
                ,vr_dtrefere
                ,pr_idproduto
                ,pr_nrdconta
                ,pr_nrctremp
                ,pr_nrcpfcgc
                ,pr_idorigem_recurso
                ,pr_idindexador
                ,nvl(pr_perindexador,0)
                ,pr_idgarantia
                ,pr_vltaxa_juros
                ,vr_dtlib_operacao
                ,pr_vloperacao
                ,pr_idnat_operacao
                ,vr_dtvenc_operacao
                ,pr_cdclassifica_operacao
                ,pr_qtdparcelas
                ,pr_vlparcela
                ,vr_dtproxima_parcela
                ,pr_vlsaldo_pendente
                ,pr_flsaida_operacao)
       RETURNING tbrisco_provisgarant_movto.idmovto_risco INTO vr_idmovto_risco;
    
    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        vr_dscritic := 'N�o foi poss�vel alterar o movimento.';
        RAISE vr_exc_erro;
    
    END;
    
    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'movrgp.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou a inclusao do movimento: ' || 
                                                  'Codigo: ' || gene0002.fn_mask(vr_idmovto_risco,'z.zzz.zz9') ||
                                                  ', Cooperativa: ' || to_char(rw_crapcop.cdcooper,'fm9999990') || ' - ' || rw_crapcop.nmrescop || 
                                                  ', Data base: ' || to_char(vr_dtrefere,'DD/MM/RRRR') ||
                                                  ', Produto:' || gene0002.fn_mask(pr_idproduto,'z.zzz.zz9') ||
                                                  ', Conta: ' || gene0002.fn_mask_conta(pr_nrdconta) || 
                                                  ', Contrato: ' || to_char(pr_nrctremp,'fm9999g999g990') ||
                                                  ', CPF/CNPJ: ' || pr_nrcpfcgc ||
                                                  ', Origem Recurso: ' || RISC0003.fn_valor_opcao_dominio(pr_idorigem_recurso) ||
                                                  ', Indexador: ' || RISC0003.fn_valor_opcao_dominio(pr_idindexador) ||
                                                  ', Perc. Indexador: ' || to_char(pr_perindexador,'990D0000000','NLS_NUMERIC_CHARACTERS='',.''') ||
                                                  ', Garantia: '   || RISC0003.fn_valor_opcao_dominio(pr_idgarantia) ||
                                                  ', Valor taxa de juros: ' || to_char(pr_vltaxa_juros,'990D0000000','NLS_NUMERIC_CHARACTERS='',.''') ||
                                                  ', Data de liberacao da operacao: ' || to_char(vr_dtlib_operacao,'DD/MM/RRRR') ||
                                                  ', Valor da operacao: ' || to_char(pr_vloperacao,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''') ||
                                                  ', Nat. Operacao: ' || RISC0003.fn_valor_opcao_dominio(pr_idnat_operacao) ||
                                                  ', Data Vencimento da operacao: ' || to_char(vr_dtvenc_operacao,'DD/MM/RRRR') ||
                                                  ', Classificacao da operacao: ' || pr_cdclassifica_operacao || 
                                                  ', Quantidade de parcelas: ' || to_char(pr_qtdparcelas,'fm9999g999g990') ||
                                                  ', Valor da parcela: ' || to_char(pr_vlparcela,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''') ||
                                                  ', Data da proxima parcela: ' || to_char(vr_dtproxima_parcela,'DD/MM/RRRR') || 
                                                  ', Valor do saldo pendente: ' || to_char(pr_vlsaldo_pendente,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''') ||
                                                  ', Permite saida de operacao: ' || (CASE WHEN pr_flsaida_operacao = 0 THEN 'Nao' ELSE 'Sim' END)  || '.');
    
      
    pr_des_erro := 'OK';
    
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_incluir_movimento --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_incluir_movimento;
 

  PROCEDURE pc_fechamento_digitacao(pr_cdcopsel  IN crapcop.cdcooper%TYPE --C�digo da cooperativa selecionada
                                   ,pr_dtrefere  IN VARCHAR2      --Data de refer�ncia
                                   ,pr_cddopcao IN VARCHAR2      --N�mero da conta
                                   ,pr_xmllog   IN VARCHAR2      --XML com informa��es de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER  --C�digo da cr�tica
                                   ,pr_dscritic OUT VARCHAR2     --Descri��o da cr�tica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2     --Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2)IS  --Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_fechamento_digitacao                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonata - RKAM
    Data     : Maio/2017                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Realiza o fechamento de digita��o da tela MOVRGP
    
    Altera��es : 
    -------------------------------------------------------------------------------------------------------------*/                                
          
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_dtrefere DATE;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    vr_exc_saida EXCEPTION;
        
  BEGIN 
    
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'MOVRGP'
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
    
    IF nvl(pr_cdcopsel,0) = 0 THEN
      
      -- Montar mensagem de critica
      vr_dscritic := 'Cooperativa inv�lida.';
      RAISE vr_exc_erro;
      
    END IF;    
    
    IF TRIM(pr_dtrefere) IS NULL THEN
      
      -- Montar mensagem de critica
      vr_dscritic := 'Data de refer�ncia n�o informada.';
      RAISE vr_exc_erro;
      
    END IF;

    BEGIN
      
      vr_dtrefere:= to_date(pr_dtrefere,'dd/mm/rrrr');
      
    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        vr_dscritic := 'Data de refer�ncia inv�lida.';
        RAISE vr_exc_erro;
        
    END;

    IF vr_dtrefere >= last_day(trunc(SYSDATE)) THEN
      
      -- Montar mensagem de critica
      vr_dscritic := 'Dt. Ref. Inv�lida � Favor selecionar data anterior ou igual a ' || to_char(last_day(add_months(sysdate,-1)),'dd/mm/rrrr' ) || '.';
      RAISE vr_exc_erro;
        
    END IF;
    
    OPEN cr_crapcop(pr_cdcooper => pr_cdcopsel);
    
    FETCH cr_crapcop INTO rw_crapcop;
    
    IF cr_crapcop%NOTFOUND THEN
      
      CLOSE cr_crapcop;
      
      -- Montar mensagem de critica
      vr_dscritic := 'Cooperativa n�o encontrada.';
      RAISE vr_exc_erro;
    
    END IF;
    
    CLOSE cr_crapcop;
    
    Risc0003.pc_fecham_risco_garantia_prest(pr_cdcooper => pr_cdcopsel
                                           ,pr_dtrefere => vr_dtrefere
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
                                          
    --Se houve erro na rotina:
    IF nvl(vr_cdcritic,0) <> 0 OR
       vr_dscritic IS NOT NULL THEN
      
      RAISE vr_exc_erro;
      
    END IF; 
    
    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'movrgp.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou o fechamento da digitacao: ' || 
                                                  ' Cooperativa: ' || to_char(rw_crapcop.cdcooper,'fm9999990') || ' - ' || rw_crapcop.nmrescop|| 
                                                  ', Data de referencia: ' || to_char(vr_dtrefere,'DD/MM/RRRR') || '.');
      
    pr_des_erro := 'OK';
    
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := 'cddopcao';
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_fechamento_digitacao --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_fechamento_digitacao;
 
  PROCEDURE pc_reabertura_digitacao(pr_cdcopsel  IN crapcop.cdcooper%TYPE --C�digo da cooperativa selecionada
                                   ,pr_dtrefere  IN VARCHAR2      --Data de refer�ncia
                                   ,pr_cddopcao IN VARCHAR2      --N�mero da conta
                                   ,pr_xmllog   IN VARCHAR2      --XML com informa��es de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER  --C�digo da cr�tica
                                   ,pr_dscritic OUT VARCHAR2     --Descri��o da cr�tica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2     --Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2)IS  --Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_reabertura_digitacao                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonata - RKAM
    Data     : Maio/2017                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Realiza a reabertura do per�odo da digita��o da tela MOVRGP
    
    Altera��es : 
    -------------------------------------------------------------------------------------------------------------*/                                
            
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_dtrefere DATE;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    vr_exc_saida EXCEPTION;
        
  BEGIN 
    
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'MOVRGP'
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
    
    IF nvl(pr_cdcopsel,0) = 0 THEN
      
      -- Montar mensagem de critica
      vr_dscritic := 'Cooperativa inv�lida.';
      RAISE vr_exc_erro;
      
    END IF;    
    
    IF TRIM(pr_dtrefere) IS NULL THEN
      
      -- Montar mensagem de critica
      vr_dscritic := 'Data de refer�ncia n�o informada.';
      RAISE vr_exc_erro;
      
    END IF;

    BEGIN
      
      vr_dtrefere:= to_date(pr_dtrefere,'dd/mm/rrrr');
      
    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        vr_dscritic := 'Data de refer�ncia inv�lida.';
        RAISE vr_exc_erro;
        
    END;

    IF vr_dtrefere >= last_day(trunc(SYSDATE)) THEN
      
      -- Montar mensagem de critica
      vr_dscritic := 'Dt. Ref. Inv�lida � Favor selecionar data anterior ou igual a ' || to_char(last_day(add_months(sysdate,-1)),'dd/mm/rrrr' ) || '.';
      RAISE vr_exc_erro;
        
    END IF;
    
    OPEN cr_crapcop(pr_cdcooper => pr_cdcopsel);
    
    FETCH cr_crapcop INTO rw_crapcop;
    
    IF cr_crapcop%NOTFOUND THEN
      
      CLOSE cr_crapcop;
      
      -- Montar mensagem de critica
      vr_dscritic := 'Cooperativa n�o encontrada.';
      RAISE vr_exc_erro;
    
    END IF;
    
    CLOSE cr_crapcop;
    
    Risc0003.pc_reabre_risco_garantia_prest(pr_cdcooper => pr_cdcopsel
                                           ,pr_dtrefere => vr_dtrefere
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
                                          
    --Se houve erro na rotina:
    IF nvl(vr_cdcritic,0) <> 0 OR
       vr_dscritic IS NOT NULL THEN
      
      RAISE vr_exc_erro;
      
    END IF; 
    
    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'movrgp.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou o reabertura da digitacao: ' || 
                                                  ' Cooperativa: ' || to_char(rw_crapcop.cdcooper,'fm9999990') ||  ' - ' || rw_crapcop.nmrescop|| 
                                                  ', Data de referencia: ' || to_char(vr_dtrefere,'DD/MM/RRRR') || '.');
      
    pr_des_erro := 'OK';
    
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := 'cddopcao';
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_reabertura_digitacao --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_reabertura_digitacao;
 
  PROCEDURE pc_detalhes_movimento(pr_idmovto_risco IN tbrisco_provisgarant_movto.idmovto_risco%TYPE --C�digo do movimento
                                 ,pr_idproduto     IN tbrisco_provisgarant_movto.idproduto%TYPE --C�digo do produto
                                 ,pr_cddopcao IN VARCHAR2      --N�mero da conta
                                 ,pr_xmllog   IN VARCHAR2      --XML com informa��es de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER  --C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2     --Descri��o da cr�tica
                                 ,pr_retxml   IN OUT NOCOPY XMLType --Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2     --Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2)IS  --Saida OK/NOK
      
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_detalhes_movimento                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonata - RKAM
    Data     : Maio/2017                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca informa��es detalhadas do movimento selecionado
    
    Altera��es : 
    -------------------------------------------------------------------------------------------------------------*/                                
      
    CURSOR cr_risco_prodt(pr_idproduto IN tbrisco_provisgarant_prodt.idproduto%TYPE)IS
    SELECT ppg.idorigem_recurso,
           ppg.idindexador,
           ppg.perindexador,
           ppg.idnat_operacao,
           ppg.flpermite_saida_operacao,
           ppg.flpermite_fluxo_financeiro,
           ppg.vltaxa_juros,
           ppg.cdclassifica_operacao,
           ppg.idgarantia,
           ppg.idproduto
      FROM tbrisco_provisgarant_prodt ppg
     WHERE ppg.idproduto = pr_idproduto;
     rw_risco_prodt cr_risco_prodt%ROWTYPE;
    
    CURSOR cr_movimentos(pr_idmovto_risco IN tbrisco_provisgarant_movto.idmovto_risco%TYPE)IS
    SELECT mvt.cdcooper,
           mvt.dtbase,
           mvt.idproduto,
           gene0002.fn_mask_conta(mvt.nrdconta) nrdconta,
           gene0002.fn_mask_cpf_cnpj(mvt.nrcpfcgc, ass.inpessoa) nrcpfcgc,
           ass.nmprimtl,
           ass.dsnivris,
           mvt.nrctremp,
           mvt.idgarantia,
           mvt.idorigem_recurso,
           mvt.idindexador,
           mvt.perindexador,
           mvt.vltaxa_juros,
           mvt.dtlib_operacao,
           mvt.vloperacao,
           mvt.idnat_operacao,
           mvt.dtvenc_operacao,
           mvt.cdclassifica_operacao,
           mvt.qtdparcelas,
           mvt.vlparcela,
           mvt.dtproxima_parcela,
           mvt.vlsaldo_pendente,
           mvt.flsaida_operacao,
           mvt.idmovto_risco,
           LPAD(prd.idproduto, 2, '0') || ' - ' || prd.dsproduto dsproduto,
           prd.cdclassifica_operacao cdclassificacao_produto           
      FROM tbrisco_provisgarant_prodt prd
          ,tbrisco_provisgarant_movto mvt LEFT JOIN crapass ass
           ON ass.cdcooper = mvt.cdcooper
          AND ass.nrdconta = mvt.nrdconta 
     WHERE prd.idproduto = mvt.idproduto
       AND mvt.idmovto_risco = pr_idmovto_risco;
    rw_movimentos cr_movimentos%ROWTYPE;

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    vr_exc_saida EXCEPTION;
    
  BEGIN 
    
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'MOVRGP'
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
    
    IF nvl(pr_idproduto,0) = 0 THEN
        
      -- Montar mensagem de critica
      vr_dscritic := 'Produto n�o informado.';
      RAISE vr_exc_erro;
        
    END IF;
      
    OPEN cr_risco_prodt(pr_idproduto => pr_idproduto);
      
    FETCH cr_risco_prodt INTO rw_risco_prodt;
      
    IF cr_risco_prodt%NOTFOUND THEN
        
      CLOSE cr_risco_prodt;
        
      -- Montar mensagem de critica
       vr_dscritic := 'Par�metros n�o encontrados.';
      RAISE vr_exc_erro;
      
    END IF;
      
    CLOSE cr_risco_prodt;
      
    IF pr_cddopcao <> 'I' THEN
      
      IF nvl(pr_idmovto_risco,0) = 0 THEN
        
        -- Montar mensagem de critica
        vr_dscritic := 'Produto n�o informado.';
        RAISE vr_exc_erro;
        
      END IF;
      
      OPEN cr_movimentos(pr_idmovto_risco => pr_idmovto_risco);
      
      FETCH cr_movimentos INTO rw_movimentos;
      
      IF cr_movimentos%NOTFOUND THEN
        
        --Fecha o cursor
        CLOSE cr_movimentos;
        vr_dscritic := 'Movimento n�o encontrado.';
        RAISE vr_exc_erro;
      
      END IF;
      
      CLOSE cr_movimentos;
      
      OPEN cr_crapcop(pr_cdcooper => rw_movimentos.cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;
      
      IF cr_crapcop%NOTFOUND THEN
        
        CLOSE cr_crapcop;
        
        -- Montar mensagem de critica
        vr_dscritic := 'Cooperativa n�o encontrada.';
        RAISE vr_exc_erro;
      
      END IF;
      
      CLOSE cr_crapcop;
      
      -- Criar cabe�alho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><Root/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'detalhe', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_crapcop.cdcooper || '-' || rw_crapcop.nmrescop, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'idmovto_risco', pr_tag_cont => rw_movimentos.idmovto_risco, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'dtbase', pr_tag_cont => to_char(rw_movimentos.dtbase,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'dsproduto', pr_tag_cont => rw_movimentos.dsproduto, pr_des_erro => vr_dscritic);      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'idproduto', pr_tag_cont => rw_movimentos.idproduto, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'nrdconta', pr_tag_cont => rw_movimentos.nrdconta, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'nmprimtl', pr_tag_cont => rw_movimentos.nmprimtl, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'nrcpfcgc', pr_tag_cont => rw_movimentos.nrcpfcgc, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'nrctremp', pr_tag_cont => to_char(rw_movimentos.nrctremp,'fm9999g999g990'), pr_des_erro => vr_dscritic);            
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'iddominio_idgarantia', pr_tag_cont => rw_movimentos.idgarantia, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'idgarantia', pr_tag_cont => RISC0003.fn_valor_opcao_dominio(rw_movimentos.idgarantia), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'dsgarantia', pr_tag_cont => RISC0003.fn_descri_opcao_dominio(rw_movimentos.idgarantia), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'iddominio_idorigem_recurso', pr_tag_cont => rw_movimentos.idorigem_recurso, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'idorigem_recurso', pr_tag_cont => RISC0003.fn_valor_opcao_dominio(rw_movimentos.idorigem_recurso), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'dsorigem_recurso', pr_tag_cont => RISC0003.fn_descri_opcao_dominio(rw_movimentos.idorigem_recurso), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'iddominio_idindexador', pr_tag_cont => rw_movimentos.idindexador, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'idindexador', pr_tag_cont => RISC0003.fn_valor_opcao_dominio(rw_movimentos.idindexador), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'dsindexador', pr_tag_cont => RISC0003.fn_descri_opcao_dominio(rw_movimentos.idindexador), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'perindexador', pr_tag_cont => to_char(rw_movimentos.perindexador,'990D0000000','NLS_NUMERIC_CHARACTERS='',.''') , pr_des_erro => vr_dscritic);            
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'vltaxa_juros', pr_tag_cont => to_char(rw_movimentos.vltaxa_juros,'990D0000000','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);            
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'dtlib_operacao', pr_tag_cont => to_char(rw_movimentos.dtlib_operacao,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);            
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'vloperacao', pr_tag_cont => to_char(rw_movimentos.vloperacao,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);            
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'iddominio_idnat_operacao', pr_tag_cont => rw_movimentos.idnat_operacao, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'idnat_operacao', pr_tag_cont => RISC0003.fn_valor_opcao_dominio(rw_movimentos.idnat_operacao), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'dsnat_operacao', pr_tag_cont => RISC0003.fn_descri_opcao_dominio(rw_movimentos.idnat_operacao), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'dtvenc_operacao', pr_tag_cont => to_char(rw_movimentos.dtvenc_operacao,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);            
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'cdclassifica_operacao', pr_tag_cont => rw_movimentos.cdclassifica_operacao, pr_des_erro => vr_dscritic);            
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'qtdparcelas', pr_tag_cont => rw_movimentos.qtdparcelas, pr_des_erro => vr_dscritic);            
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'vlparcela', pr_tag_cont => to_char(rw_movimentos.vlparcela,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'dtproxima_parcela', pr_tag_cont => to_char(rw_movimentos.dtproxima_parcela,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);            
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'vlsaldo_pendente', pr_tag_cont => to_char(rw_movimentos.vlsaldo_pendente,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'flsaida_operacao', pr_tag_cont => rw_movimentos.flsaida_operacao, pr_des_erro => vr_dscritic);            
     
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml             --> XML que ir� receber o novo atributo
                               ,pr_tag   => 'detalhe'             --> Nome da TAG XML
                               ,pr_atrib => 'cdclassificacao_produto' --> Nome do atributo
                               ,pr_atval => rw_movimentos.cdclassificacao_produto  --> Valor do atributo
                               ,pr_numva => 0                   --> N�mero da localiza��o da TAG na �rvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descri��o de erros
                                     
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF; 
      
    ELSE
      
      -- Criar cabe�alho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><Root/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'detalhe', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'idproduto', pr_tag_cont => rw_risco_prodt.idproduto, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'iddominio_idgarantia', pr_tag_cont => rw_risco_prodt.idgarantia, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'idgarantia', pr_tag_cont => RISC0003.fn_valor_opcao_dominio(rw_risco_prodt.idgarantia), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'dsgarantia', pr_tag_cont => RISC0003.fn_descri_opcao_dominio(rw_risco_prodt.idgarantia), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'iddominio_idorigem_recurso', pr_tag_cont => rw_risco_prodt.idorigem_recurso, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'idorigem_recurso', pr_tag_cont => RISC0003.fn_valor_opcao_dominio(rw_risco_prodt.idorigem_recurso), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'dsorigem_recurso', pr_tag_cont => RISC0003.fn_descri_opcao_dominio(rw_risco_prodt.idorigem_recurso), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'iddominio_idindexador', pr_tag_cont => rw_risco_prodt.idindexador, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'idindexador', pr_tag_cont => RISC0003.fn_valor_opcao_dominio(rw_risco_prodt.idindexador), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'dsindexador', pr_tag_cont => RISC0003.fn_descri_opcao_dominio(rw_risco_prodt.idindexador), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'perindexador', pr_tag_cont => to_char(rw_risco_prodt.perindexador,'990D0000000','NLS_NUMERIC_CHARACTERS='',.''') , pr_des_erro => vr_dscritic);            
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'vltaxa_juros', pr_tag_cont => to_char(rw_risco_prodt.vltaxa_juros,'990D0000000','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);            
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'iddominio_idnat_operacao', pr_tag_cont => rw_risco_prodt.idnat_operacao, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'idnat_operacao', pr_tag_cont => RISC0003.fn_valor_opcao_dominio(rw_risco_prodt.idnat_operacao), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => 0, pr_tag_nova => 'dsnat_operacao', pr_tag_cont => RISC0003.fn_descri_opcao_dominio(rw_risco_prodt.idnat_operacao), pr_des_erro => vr_dscritic);
              
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml             --> XML que ir� receber o novo atributo
                               ,pr_tag   => 'detalhe'             --> Nome da TAG XML
                               ,pr_atrib => 'cdclassificacao_produto' --> Nome do atributo
                               ,pr_atval => rw_risco_prodt.cdclassifica_operacao  --> Valor do atributo
                               ,pr_numva => 0                   --> N�mero da localiza��o da TAG na �rvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descri��o de erros
                                     
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
    END IF;
      
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml             --> XML que ir� receber o novo atributo
                             ,pr_tag   => 'detalhe'             --> Nome da TAG XML
                             ,pr_atrib => 'flpermite_fluxo_financeiro' --> Nome do atributo
                             ,pr_atval => rw_risco_prodt.flpermite_fluxo_financeiro --> Valor do atributo
                             ,pr_numva => 0                   --> N�mero da localiza��o da TAG na �rvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descri��o de erros
                                   
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 
        
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml             --> XML que ir� receber o novo atributo
                             ,pr_tag   => 'detalhe'             --> Nome da TAG XML
                             ,pr_atrib => 'flpermite_saida_operacao' --> Nome do atributo
                             ,pr_atval => rw_risco_prodt.flpermite_saida_operacao  --> Valor do atributo
                             ,pr_numva => 0                   --> N�mero da localiza��o da TAG na �rvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descri��o de erros
                                   
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 
    
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := 'cddopcao';
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_detalhes_movimento --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_detalhes_movimento;
  
  
END TELA_MOVRGP;
/
