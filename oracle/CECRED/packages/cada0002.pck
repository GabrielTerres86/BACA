CREATE OR REPLACE PACKAGE CECRED.CADA0002 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CADA0002
  --  Sistema  : Rotinas acessadas pelas telas de cadastros Web
  --  Sigla    : CADA
  --  Autor    : Renato Darosci - Supero
  --  Data     : Julho/2014.                    Ultima atualizacao: 19/09/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para manutenção (cadastro) dos dados para sistema Web/genérico
  --
  -- Observacoes: 11/02/2016 - Conversao da rotina B1WGEN0015.valida-inclusao-conta-transferencia,
  --                           (Jean Michel).
  --
  --		      10/05/2016 - Ajustes devido ao projeto M118 para cadastrar o favorecido de forma automatica
  --				     	   (Adriano - M117).
  --
  --              19/05/2016 - Ajsute na inclusão do registro crapcti para tratar quando
  --				 	       o número do ISPB vier nulo e incluir a verificação de senha
  --						   para contas com assinatura conjunta
  --						  (Adriano - M117).
  --
  --              19/09/2016 - Alteraçoes pagamento/agendamento de DARF/DAS pelo 
  --						   InternetBanking (Projeto 338 - Lucas Lunelli)
  --
  --			  23/03/2017 - Incluido procedure pc_impressao_rec_cel. (PRJ321 - Reinert)
  --
  --        11/01/2019 - Criada rotina que gera Ficha-Proposta (Cássia de Oliveira - GFT)
  ---------------------------------------------------------------------------------------------------------------
  
  ---------------------- TEMPTABLE ----------------------------
  -- Antiga tt-autorizacao-favorecido
  -- TempTable para retornar dados do favorecido
  TYPE typ_reg_autorizacao_favorecido IS 
    RECORD (nmextcop  crapcop.nmextcop%TYPE,
            nmrescop  crapcop.nmrescop%TYPE,
            cdbcoctl  crapcop.cdbcoctl%TYPE,
            nmbcoctl  crapban.nmextbcc%TYPE,
            cdagectl  crapcop.cdagectl%TYPE,
            dttransa  crapcti.dttransa%TYPE,
            hrtransa  crapcti.hrtransa%TYPE,
            nrdconta  crapass.nrdconta%TYPE,
            nmextttl  crapttl.nmextttl%TYPE,
            nmprimtl  crapass.nmprimtl%TYPE,
            nmsegttl  crapass.nmprimtl%TYPE,
            cddbanco  crapcti.cddbanco%TYPE,
            nmdbanco  crapban.nmextbcc%TYPE,
            cdageban  crapcti.cdageban%TYPE,
            nrctatrf  crapcti.nrctatrf%TYPE,
            nmtitula  crapcti.nmtitula%TYPE,
            dsprotoc  crapcti.dsprotoc%TYPE,
            nrtelfax  crapage.nrtelfax%TYPE,
            dsdemail  crapage.dsdemail%TYPE,
            nmopecad  VARCHAR2(500),
            idsequen  INTEGER,
            intipcta  INTEGER,
            inpessoa  INTEGER,
            nrcpfcgc  crapass.nrcpfcgc%TYPE,
            indrecid  crapcti.progress_recid%TYPE,
            nrispbif  crapcti.nrispbif%TYPE);
  
  TYPE typ_tab_autorizacao_favorecido IS TABLE OF typ_reg_autorizacao_favorecido
    INDEX BY PLS_INTEGER;
  -- Inicio (Cássia de Oliveira - GFT)
  PROCEDURE pc_impressao_ficha_prop(pr_nrdconta IN crapass.nrdconta%TYPE        --> Numero da Conta
                                   ,pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);                  --> Erros do processo;
  -- Fim (Cássia de Oliveira - GFT)
  -- TELA: VERPRO - Verificação de Protocolos
  PROCEDURE pc_verpro(pr_cdcooper IN     NUMBER          --> Código da cooperativa
                     ,pr_idorigem IN     NUMBER          --> ID da origem
                     ,pr_nrdconta IN     NUMBER          --> Número da conta
                     ,pr_dataini  IN     VARCHAR2        --> Data inicial
                     ,pr_datafin  IN     VARCHAR2        --> Data final
                     ,pr_cdtippro IN     NUMBER          --> Controle de paginação
                     ,pr_nrregist IN     NUMBER          --> Número de registros
                     ,pr_nriniseq IN     NUMBER          --> Número sequenciador
                     ,pr_tpdbusca IN     NUMBER          --> Tipo da busca que será efetuada
                     ,pr_xmllog   IN     VARCHAR2        --> XML com informações de LOG
                     ,pr_cdcritic    OUT PLS_INTEGER     --> Código da crítica
                     ,pr_dscritic    OUT VARCHAR2        --> Descrição da crítica
                     ,pr_retxml   IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                     ,pr_nmdcampo    OUT VARCHAR2        --> Nome do campo com erro
                     ,pr_des_erro    OUT VARCHAR2);      --> Erros do processo


  --> TELA: MUDSEN - Mudança de Senha
  PROCEDURE pc_mudsen(pr_cdcooper IN     crapcop.cdcooper%TYPE  --> Código Cooperativa
                     ,pr_cdoperad IN     crapdev.cdoperad%TYPE  --> Cooperado
                     ,pr_cdsenha1 IN     VARCHAR2               --> Senha atual
                     ,pr_cdsenha2 IN     VARCHAR2               --> Nova senha
                     ,pr_cdsenha3 IN     VARCHAR2               --> Confirmação da senha
                     ,pr_xmllog   IN     VARCHAR2               --> XML com informações de LOG
                     ,pr_cdcritic    OUT PLS_INTEGER            --> Código da crítica
                     ,pr_dscritic    OUT VARCHAR2               --> Descrição da crítica
                     ,pr_retxml   IN OUT NOCOPY XMLType         --> Arquivo de retorno do XML
                     ,pr_nmdcampo    OUT VARCHAR2               --> Nome do campo com erro
                     ,pr_des_erro    OUT VARCHAR2);             --> Erros do processo
  
  --> Imprimir dados VERPRO
  PROCEDURE pc_verpro_imp(pr_cdcooper  IN NUMBER
                         ,pr_dsiduser  IN VARCHAR2  
                         /*pr_cdcooper  IN NUMBER   
                         ,pr_cdagenci  IN NUMBER   
                         ,pr_nrdcaixa  IN NUMBER   
                         ,pr_cdoperad  IN VARCHAR2   
                         ,pr_nmdatela  IN VARCHAR2   
                         ,pr_idorigem  IN NUMBER   
                         ,pr_dsiduser  IN VARCHAR2   
                         ,pr_nrdconta  IN NUMBER   
                         ,pr_nmprimtl  IN VARCHAR2   
                         ,pr_cdtippro  IN NUMBER   
                         ,pr_nrdocmto  IN NUMBER 
                         ,pr_nrseqaut  IN NUMBER   
                         ,pr_nmprepos  IN VARCHAR2   
                         ,pr_nmoperad  IN VARCHAR2   
                         ,pr_dttransa  IN DATE 
                         ,pr_hrautent  IN NUMBER   
                         ,pr_dtmvtolx  IN DATE
                         ,pr_dsprotoc  IN VARCHAR2   
                         ,pr_cdbarras  IN VARCHAR2   
                         ,pr_lndigita  IN VARCHAR2   
                         ,pr_label     IN VARCHAR2   
                         ,pr_label2    IN VARCHAR2   
                         ,pr_valor     IN VARCHAR2   
                         ,pr_auxiliar  IN VARCHAR2   
                         ,pr_auxiliar2 IN VARCHAR2   
                         ,pr_auxiliar3 IN VARCHAR2   
                         ,pr_auxiliar4 IN VARCHAR2   
                         ,pr_dsdbanco  IN VARCHAR2   
                         ,pr_dsageban  IN VARCHAR2   
                         ,pr_nrctafav  IN VARCHAR2   
                         ,pr_nmfavore  IN VARCHAR2   
                         ,pr_nrcpffav  IN VARCHAR2   
                         ,pr_dsfinali  IN VARCHAR2   
                         ,pr_dstransf  IN VARCHAR2   
                         ,pr_flgerlog  IN NUMBER*/
                         ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                         ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                         ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                         ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                         ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                         ,pr_des_erro  OUT VARCHAR2);           --> Erros do processo
                         
  --> Procedure para incluir conta de transferencia
  PROCEDURE pc_inclui_conta_transf (pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                   ,pr_cdagenci IN crapage.cdagenci%TYPE --> Codigo da agencia   
                                   ,pr_nrdcaixa IN INTEGER               --> Numero do caixa
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE --> Cod. do operador
                                   ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                   ,pr_idorigem IN INTEGER               --> Identificador de origem
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta 
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq. do titular
                                   ,pr_dtmvtolt IN DATE                  --> Data do movimento
                                   ,pr_nrcpfope IN crapopi.nrcpfope%TYPE --> CPF operador juridico 
                                   ,pr_flgerlog IN INTEGER               --> flg geracao log 
                                   ,pr_cddbanco IN INTEGER               --> Codigo do banco destino
                                   ,pr_cdageban IN INTEGER               --> Agencia destino
                                   ,pr_nrctatrf IN crapcti.nrctatrf%TYPE --> Nr. conta transf
                                   ,pr_nmtitula IN VARCHAR2              --> Nome titular
                                   ,pr_nrcpfcgc IN NUMBER                --> CPF titulat
                                   ,pr_inpessoa IN INTEGER               --> Tipo pessoa
                                   ,pr_intipcta IN INTEGER               --> Tipo de conta
                                   ,pr_intipdif IN INTEGER               --> tipo de inst. financeira da conta
                                   ,pr_rowidcti IN crapcti.progress_recid%TYPE --> Recid da cta transf
                                   ,pr_cdispbif IN crapcti.nrispbif%TYPE --> Oito primeiras posicoes do cnpj. 
                                   -- OUT 
                                   ,pr_msgaviso OUT VARCHAR2              --> Mensagem de aviso
                                   ,pr_des_erro OUT VARCHAR2              --> Indicador se retornou com erro (OK ou NOK)
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da critica
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE);--> Descricao da critica
                                                                          

                                                                          
  -- Rotina para validacao de inclusao para conta de transferencia
  PROCEDURE pc_val_inclui_conta_transf(pr_cdcooper IN crapcop.cdcooper%TYPE               
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE
                                      ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE                
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE                
                                      ,pr_idorigem IN INTEGER
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE             
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                      ,pr_flgerlog IN INTEGER
                                      ,pr_cddbanco IN INTEGER
                                      ,pr_cdispbif IN INTEGER
                                      ,pr_cdageban IN INTEGER
                                      ,pr_nrctatrf IN crapcti.nrctatrf%TYPE
                                      ,pr_intipdif IN INTEGER
                                      ,pr_intipcta IN OUT INTEGER
                                      ,pr_insitcta IN INTEGER
                                      ,pr_inpessoa IN OUT INTEGER
                                      ,pr_nrcpfcgc IN OUT crapass.nrcpfcgc%TYPE             
                                      ,pr_flvldinc IN INTEGER                
                                      ,pr_rowidcti IN crapcti.progress_recid%TYPE
                                      ,pr_nmtitula IN OUT VARCHAR2
                                      ,pr_dscpfcgc OUT VARCHAR2
                                      ,pr_nmdcampo OUT VARCHAR2
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE);
                                                                          
  PROCEDURE pc_bloqueia_operadores(pr_dscritic OUT crapcri.dscritic%TYPE);

END CADA0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CADA0002 IS
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : CADA0002
    Sistema  : Rotinas acessadas pelas telas de cadastros Web
    Sigla    : CADA
    Autor    : Renato Darosci - Supero
    Data     : Julho/2014.                   Ultima atualizacao: 21/08/2018
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : Rotinas para manutenção (cadastro) dos dados para sistema Web/genérico
  
   Alteracoes: 05/03/2015 - #261634 Inclusão da função lower() no cursor cr_crapope da procedure pc_mudsen para localizar 
                            operadores cadastrados com, por exemplo, o "f" maiúsculo (Carlos)
	
	             13/04/2015 - Adicionado nome do produto junto ao nr da aplicação para os novos produtos de 
  	                        captação na procedure pc_impressao_aplica (Reinert)
  
               10/06/2015 - Adicionado o campo dsispbif na typ_xmldata e na pc_ver_pro_imp e na pc_impressao_ted
                            SD271603 FDR041 (Venessa).
  
               05/08/2015 - Adicionar os parametros para gravar o campo craptoj.idtitdda quando 
                            realizar o agendamento (Douglas - Chamado 291387)  
  
               11/02/2016 - Conversao da rotina b1wgen0015.valida-inclusao-conta-transferencia,
                             (Jean Michel).
  
               05/04/2016 - Ajuste para retirar o "*" ao remover o arquivo
                            (Adriano).
  
  		         10/05/2016 - Ajustes devido ao projeto M118 para cadastrar o favorecido de forma automatica
  					                (Adriano - M117).
  
               19/05/2016 - Ajsute na inclusão do registro crapcti para tratar quando o número do ISPB vier nulo 
                            e incluir a verificação de senha para contas com assinatura conjunta
  						              (Adriano - M117).
  
               23/06/2016 - Correcao no indice sobre a tabela crapope da pc_mudsen para comparar os campo
                            cdoperad com o comando UPPER. (Carlos Rafael Tanholi).
  
               20/07/2016 - #475267 Inclusão da exception DUP_VAL_ON_INDEX na rotina pc_inclui_conta_transf
                            para criticar contas já cadastradas. (Carlos)
  
               30/08/2016 - Criar rotina para impressão de resgate de aplicação 
                            pc_impressao_resg_aplica (Lucas Ranghetti #490678)
  
               19/09/2016 - Alteraçoes pagamento/agendamento de DARF/DAS pelo 
  						              InternetBanking (Projeto 338 - Lucas Lunelli)
  
  	           11/11/2016 - Ajuste para efetuar log no arquivo internal_exception.log
  	                      (Adriano - SD 552561)
  
               20/03/2017 - Ajuste para validar o cpf/cnpj de acordo com o inpessoa informado             
                           (Adriano - SD 620221).
                           
               08/06/2017 - Ajustes referentes ao novo catalogo do SPB (Lucas Ranghetti #668207)

               21/08/2018 - Criar rotina para impressão de comprovante de GPS 
                            pc_impressao_gps (André Bohn Mout's) - INC0021250
                            
               11/01/2019 - Criada rotina que gera Ficha-Proposta (Cássia de Oliveira - GFT)

               04/04/2019 - Incluido novo parâmetro para a TED de deposito judicial.
                            Jose Dill - Mouts (P475 - REQ39)
  ---------------------------------------------------------------------------------------------------------------------------*/

  /****************** OBJETOS COMUNS A SEREM UTILIZADOS PELAS ROTINAS DA PACKAGE *******************/
  
  -- CURSORES
  /* Busca dados dos associados */
  CURSOR cr_crapass(pr_cdcooper IN NUMBER      --> Código da cooperativa
                   ,pr_nrdconta IN NUMBER) IS  --> Número da conta
    SELECT cs.nmprimtl
      FROM crapass cs
     WHERE cs.cdcooper = pr_cdcooper
       AND cs.nrdconta = pr_nrdconta
       AND rownum = 1
     ORDER BY cs.progress_recid;
  
  -- TIPO
  TYPE typ_xmldata IS RECORD(nrdconta   NUMBER
                            ,nmprimtl   VARCHAR2(100)
                            ,cdtippro   NUMBER
                            ,nrdocmto   NUMBER
                            ,nrseqaut   NUMBER
                            ,nmprepos   VARCHAR2(100)
                            ,nmoperad   VARCHAR2(100)
                            ,dttransa   DATE
                            ,hrautent   NUMBER
                            ,dtmvtolx   DATE
                            ,dsprotoc   VARCHAR2(100)
                            ,cdbarras   VARCHAR2(100)
                            ,lndigita   VARCHAR2(400)
                            ,label      VARCHAR2(100)
                            ,label2     VARCHAR2(100)
                            ,valor      NUMBER
                            ,dsinform##2 crappro.dsinform##2%TYPE --pj470
                            ,dtinclusao DATE --pj470
                            ,hrinclusao DATE --pj470
                            ,dsoperacao VARCHAR2(100) --pj470
                            ,cdbanco    VARCHAR2(100) --pj470
                            ,cdagencia  VARCHAR2(100) --pj470
                            ,cdconta    VARCHAR2(100) --pj470
                            ,nrcheque_i VARCHAR2(100) --pj470
                            ,nrcheque_f VARCHAR2(100) --pj470
                            ,dsativo    VARCHAR2(100) --pj470 - SM2
                            ,auxiliar   VARCHAR2(100)
                            ,auxiliar2  VARCHAR2(100)
                            ,auxiliar3  VARCHAR2(100)
                            ,auxiliar4  VARCHAR2(100)
                            ,dsdbanco   VARCHAR2(100)
                            ,dsageban   VARCHAR2(100)
                            ,nrctafav   VARCHAR2(100)
                            ,nmfavore   VARCHAR2(100)
						               	,nmconven   VARCHAR2(100)
                            ,nrcpffav   VARCHAR2(100)
                            ,dsfinali   VARCHAR2(100)
                            ,dstransf   VARCHAR2(100)
                            ,dsispbif   VARCHAR2(100)
							,dspacote   VARCHAR2(100)
							,dtdiadeb   NUMBER
							,dtinivig   DATE
							--DARF/DAS
							,tpcaptur   NUMBER
                            ,dsagtare   VARCHAR2(100)
                            ,dsagenci   VARCHAR2(100)
                            ,tpdocmto   VARCHAR2(100)
                            ,dsnomfon   VARCHAR2(100)
                            ,nmsolici   VARCHAR2(100)
                            ,dtvencto   DATE 
                            ,dtapurac   DATE
                            ,nrcpfcgc   VARCHAR2(100)
                            ,cdtribut   NUMBER
                            ,nrrefere   VARCHAR2(100)
                            ,vlrecbru   NUMBER
                            ,vlpercen   NUMBER
                            ,vlprinci   NUMBER
                            ,vlrmulta   NUMBER
                            ,vlrjuros   NUMBER
                            ,vltotfat   NUMBER
							,nrdocdas   VARCHAR2(100)
							,nrdocdrf   VARCHAR2(100)
                            ,dsidepag   VARCHAR2(100)
                            ,dtmvtdrf   DATE
                            ,hrautdrf   VARCHAR2(100)
							,dtvencto_drf DATE
							              -- Recarga de celuar
														,vlrecarga    NUMBER
														,nmoperadora  VARCHAR2(100)
														,nrtelefo     VARCHAR2(100)
														,dtrecarga    DATE
														,hrrecarga    VARCHAR2(100)
														,dtdebito     DATE
														,nsuopera     VARCHAR2(100)
                            --FGTS/DAE
                            ,cdconven     VARCHAR2(100)
                            ,dtvalida     DATE
                            ,cdcompet     VARCHAR2(100)
                            ,nrdocpes     VARCHAR2(100)
                            ,cdidenti     VARCHAR2(100)
                            ,nrdocmto_dae VARCHAR2(100)
                            ,dslinha3     VARCHAR2(4000)
                            ,qttitbor VARCHAR(500));
    
  
  -- REGISTROS
  rw_crapass cr_crapass%ROWTYPE;
  
  -- VARIÁVEIS
  vr_dsxmlrel    CLOB;
  vr_dsdtexto    VARCHAR2(32000);    
  
  vr_exc_erro       EXCEPTION;       --> Controle de exceção
 
  /******************************************** ROTINAS ********************************************/
  -- Subrotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_xml(pr_dsddados  IN VARCHAR2,
                           pr_nrdlinha  IN NUMBER  DEFAULT NULL,
                           pr_idfechar  IN BOOLEAN DEFAULT FALSE) IS
  
    -- Variáveis
    vr_dstagini      VARCHAR2(20);
    vr_dstagfim      VARCHAR2(20);
    
  BEGIN
    -- Se não for informada a linha
    IF pr_nrdlinha IS NULL THEN
      -- Escreve os dados no XML
      gene0002.pc_escreve_xml(vr_dsxmlrel, vr_dsdtexto, pr_dsddados, pr_idfechar);
    ELSE
      -- Se linha foi informada, deve imprimir no XML com a tag de linha
      vr_dstagini := '<linha'||to_char(pr_nrdlinha,'FM00')||'>';
      vr_dstagfim := '</linha'||to_char(pr_nrdlinha,'FM00')||'>';
      
      gene0002.pc_escreve_xml(vr_dsxmlrel, vr_dsdtexto, vr_dstagini||pr_dsddados||vr_dstagfim, pr_idfechar);
    END IF;
  END pc_escreve_xml;
  
  -- Rotina para impressão de transferencia
  PROCEDURE pc_impressao_transf(pr_xmldata  IN typ_xmldata
                               ,pr_nmrescop IN VARCHAR2) IS
    -- ..........................................................................
    --
    --  Programa : Antigo /generico/procedures/b1wgen0122.p --> impressao_transf 
    --  Sistema  : Rotinas para impressão de dados
    --  Sigla    : VERPRO
    --  Autor    : Renato Darosci  - Supero
    --  Data     : Julho/2014.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Agrupa os dados e monta o layout para impressão de dados de transferencia
    --
    --   Alteracoes: 25/07/2014 - Conversão Progress >>> Oracle. Renato - Supero
    --
    -- .............................................................................
    
    -- Variáveis
    vr_nrdlinha     NUMBER := 0;  
                          
  BEGIN

    -- IMPRIMIR O CABEÇALHO
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,1);
    pc_escreve_xml('     '||pr_nmrescop||' - Comprovante Transferencia - '||
                   'Emissao: '||to_char(SYSDATE,'DD/MM/YY')||' as '||to_char(SYSDATE,'HH24:MI:SS')||' Hr',2); 
    pc_escreve_xml('           Conta/DV: '||to_char(pr_xmldata.nrdconta)||' - '||pr_xmldata.nmprimtl     ,4);
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,5);
    -- IMPRIMIR O CONTEÚDO
    -- Contador de linha - Iniciando na sexta linha do XML
    vr_nrdlinha := 6;

    -- Se tem Preposto
    IF TRIM(pr_xmldata.nmprepos) IS NOT NULL THEN
      pc_escreve_xml('           Preposto: '||pr_xmldata.nmprepos,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    -- Se tem Operador
    IF TRIM(pr_xmldata.nmoperad) IS NOT NULL THEN
      pc_escreve_xml('           Operador: '||pr_xmldata.nmoperad,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    -- Se tem cooperativa de destino
    IF TRIM(pr_xmldata.dsageban) IS NOT NULL THEN
      pc_escreve_xml('      Coop. Destino: '||pr_xmldata.dsageban,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    -- Imprime a conta destino
    pc_escreve_xml('   Conta/dv Destino: '||pr_xmldata.auxiliar,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime a data de transação
    pc_escreve_xml('     Data Transacao: '||to_char(pr_xmldata.dttransa,'dd/mm/yy'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime a hora da transação
    pc_escreve_xml('               Hora: '||to_char(to_date(pr_xmldata.hrautent,'SSSSS'),'hh24:mi:ss'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime a data da transferencia
    pc_escreve_xml('  Dt. Transferencia: '||to_char(pr_xmldata.dtmvtolx,'dd/mm/yy'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime o valor
    pc_escreve_xml('              Valor: '||to_char(pr_xmldata.valor,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime protocolo
    pc_escreve_xml('          Protocolo: '||pr_xmldata.dsprotoc,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Se tem código de barras informado
    IF TRIM(pr_xmldata.cdbarras) IS NOT NULL THEN
      pc_escreve_xml('          Protocolo: '||pr_xmldata.cdbarras,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    -- Se tem código de barras informado
    IF TRIM(pr_xmldata.lndigita) IS NOT NULL THEN
      pc_escreve_xml('    '||pr_xmldata.lndigita,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    -- Imprime o numero do documento...
    pc_escreve_xml('      Nr. Documento: '||pr_xmldata.auxiliar2,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    pc_escreve_xml('  Seq. Autenticacao: '||pr_xmldata.auxiliar3,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    -- Se vai escrever a linha 18... ou mais
    IF vr_nrdlinha >= 18 THEN
      pc_escreve_xml('--------------------------------------------------------------------------------',vr_nrdlinha);
    ELSE 
      pc_escreve_xml('--------------------------------------------------------------------------------',18);
    END IF;

  END pc_impressao_transf;                       
                               
  -- Rotina para impressão de pagamento
  PROCEDURE pc_impressao_pag(pr_xmldata  IN typ_xmldata
                            ,pr_nmrescop IN VARCHAR2
                            ,pr_cdbcoctl IN NUMBER
                            ,pr_cdagectl IN NUMBER) IS
    -- ..........................................................................
    --
    --  Programa : Antigo /generico/procedures/b1wgen0122.p --> impressao_Pag 
    --  Sistema  : Rotinas para impressão de dados
    --  Sigla    : VERPRO
    --  Autor    : Renato Darosci  - Supero
    --  Data     : Julho/2014.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Agrupa os dados e monta o layout para impressão de dados de pagamentos
    --
    --   Alteracoes: 25/07/2014 - Conversão Progress >>> Oracle. Renato - Supero
    --
    -- .............................................................................
    
    -- Variáveis
    vr_nrdlinha     NUMBER := 0;  
    vr_dsbanco      VARCHAR2(50);
                          
  BEGIN

    -- IMPRIMIR O CABEÇALHO
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,1);
    pc_escreve_xml('     '||pr_nmrescop||' - Comprovante Pagamento - '||
                   'Emissao: '||to_char(SYSDATE,'DD/MM/YY')||' as '||to_char(SYSDATE,'HH24:MI:SS')||' Hr',2); 
    pc_escreve_xml('              Banco: '||to_char(pr_cdbcoctl) ,4);
    pc_escreve_xml('            Agencia: '||to_char(pr_cdagectl) ,5);
    pc_escreve_xml('           Conta/DV: '||to_char(pr_xmldata.nrdconta)||' - '||pr_xmldata.nmprimtl,6);
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,7);
    -- IMPRIMIR O CONTEÚDO
    -- Contador de linha - Iniciando na sexta linha do XML
    vr_nrdlinha := 8;

    -- Se tem Preposto
    IF TRIM(pr_xmldata.nmprepos) IS NOT NULL THEN
      pc_escreve_xml('           Preposto: '||pr_xmldata.nmprepos,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    -- Se tem Operador
    IF TRIM(pr_xmldata.nmoperad) IS NOT NULL THEN
      pc_escreve_xml('           Operador: '||pr_xmldata.nmoperad,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
    
    -- separar a descrição do banco
    vr_dsbanco := SUBSTR(pr_xmldata.label,instr(pr_xmldata.label,':')+1);
        
    -- Se p label contem a descrição Banco
    IF pr_xmldata.label LIKE 'Banco%' THEN
      
      -- Banco
      pc_escreve_xml('              Banco: '||vr_dsbanco,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
  
      -- Cedente
      pc_escreve_xml('            Cedente: '||pr_xmldata.auxiliar3,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
  
      -- Data de transação
      pc_escreve_xml('     Data Transacao: '||to_char(pr_xmldata.dttransa,'dd/mm/yy')||
                              '      Hora: '||to_char(to_date(pr_xmldata.hrautent,'SSSSS'),'hh24:mi:ss') ,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
  
      -- Data do pagamento
      pc_escreve_xml('     Data Pagamento: '||to_char(pr_xmldata.dtmvtolx,'dd/mm/yy') ,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
  
      -- Valor
      pc_escreve_xml('              Valor: '||to_char(pr_xmldata.valor,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
      
      -- Protocolo
      pc_escreve_xml('          Protocolo: '||pr_xmldata.dsprotoc,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    ELSE
      
      -- Label conforme o texto passado por parametro
      pc_escreve_xml(LPAD(SUBSTR(pr_xmldata.label,0,instr(pr_xmldata.label,':'))||': ',21,' ')||vr_dsbanco,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
  
      -- Data de transação
      pc_escreve_xml('     Data Transacao: '||to_char(pr_xmldata.dttransa,'dd/mm/yy'),vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
      
      -- Hora
      pc_escreve_xml('               Hora: '||to_char(to_date(pr_xmldata.hrautent,'SSSSS'),'hh24:mi:ss') ,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
  
      -- Data do pagamento
      pc_escreve_xml('     Data Pagamento: '||to_char(pr_xmldata.dtmvtolx,'dd/mm/yy') ,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
  
      -- Valor
      pc_escreve_xml('              Valor: '||to_char(pr_xmldata.valor,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
      
      -- Protocolo
      pc_escreve_xml('          Protocolo: '||pr_xmldata.dsprotoc,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    END IF;
    
    -- Se tem informação de código de barras
    IF  TRIM(pr_xmldata.cdbarras) IS NOT NULL THEN
      pc_escreve_xml('   '||pr_xmldata.cdbarras,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    -- Se tem informação de linha digitável
    IF  TRIM(pr_xmldata.lndigita) IS NOT NULL THEN
      pc_escreve_xml('    '||pr_xmldata.lndigita,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
        
    -- Imprimir documento e sequencia de autenticação
    pc_escreve_xml('      Nr. Documento: '||pr_xmldata.auxiliar2,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
        
    pc_escreve_xml('  Seq. Autenticacao: '||pr_xmldata.auxiliar4,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    -- Se vai escrever a linha 20... ou mais
    IF vr_nrdlinha >= 20 THEN
      pc_escreve_xml('--------------------------------------------------------------------------------',vr_nrdlinha);
    ELSE 
      pc_escreve_xml('--------------------------------------------------------------------------------',20);
    END IF;

  END pc_impressao_pag;   
    
  -- Rotina para impressão de comprovante de capital
  PROCEDURE pc_impressao_cap(pr_xmldata  IN typ_xmldata
                            ,pr_nmrescop IN VARCHAR2) IS
    -- ..........................................................................
    --
    --  Programa : Antigo /generico/procedures/b1wgen0122.p --> impressao_Cap 
    --  Sistema  : Rotinas para impressão de dados
    --  Sigla    : VERPRO
    --  Autor    : Renato Darosci  - Supero
    --  Data     : Julho/2014.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    -- 	
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Agrupa os dados e monta o layout para impressão de comprovantes de capital
    --
    --   Alteracoes: 28/07/2014 - Conversão Progress >>> Oracle. Renato - Supero
    --
    -- .............................................................................
                          
  BEGIN

    -- IMPRIMIR OS DADOS DO COMPROVANTE DE CAPITAL
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,01);
    pc_escreve_xml('    '||RPAD(pr_nmrescop,13,' ')||'  -  Comprovante Capital  - '||
                   'Emissao: '||to_char(SYSDATE,'DD/MM/YY')||' as '||to_char(SYSDATE,'HH24:MI:SS')||' Hr' ,02); 
    pc_escreve_xml('           Conta/DV: '||to_char(pr_xmldata.nrdconta)||' - '||pr_xmldata.nmprimtl     ,04);
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,05);
    pc_escreve_xml('  Nr. do Plano: '||pr_xmldata.auxiliar                                               ,06);
    pc_escreve_xml('          Data: '||to_char(pr_xmldata.dttransa,'dd/mm/yy')                           ,07);
    pc_escreve_xml('          Hora: '||to_char(to_date(pr_xmldata.hrautent,'SSSSS'),'hh24:mi:ss')        ,08);
    pc_escreve_xml('Data Movimento: '||to_char(pr_xmldata.dtmvtolx,'dd/mm/yy')                           ,09);
    pc_escreve_xml('         Valor: '||to_char(pr_xmldata.valor,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),10);
    pc_escreve_xml('     Protocolo: '||pr_xmldata.dsprotoc                                               ,11);
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,12);

  END pc_impressao_cap;
  
  -- Imprimir comprovante de transferencia
  PROCEDURE pc_impressao_credito(pr_xmldata  IN typ_xmldata
                                ,pr_nmrescop IN VARCHAR2) IS
                                
    -- ..........................................................................
    --
    --  Programa : Antigo /generico/procedures/b1wgen0122.p --> impressao_Credito 
    --  Sistema  : Rotinas para impressão de dados
    --  Sigla    : VERPRO
    --  Autor    : Renato Darosci  - Supero
    --  Data     : Julho/2014.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Agrupa os dados e monta o layout para impressão de dados de pagamentos
    --
    --   Alteracoes: 29/07/2014 - Conversão Progress >>> Oracle. Renato - Supero
    --
    -- .............................................................................
    
    -- Variáveis
    vr_nrdlinha     NUMBER := 0;  
                         
  BEGIN

    -- IMPRIMIR O CABEÇALHO
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,1);
    pc_escreve_xml('     '||pr_nmrescop||' - Comprovante Transferencia - '||
                   'Emissao: '||to_char(SYSDATE,'DD/MM/YY')||' as '||to_char(SYSDATE,'HH24:MI:SS')||' Hr',2); 
    pc_escreve_xml('           Conta/DV: '||to_char(pr_xmldata.nrdconta)||' - '||pr_xmldata.nmprimtl     ,4);
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,5);
    -- IMPRIMIR O CONTEÚDO
    -- Contador de linha - Iniciando na sexta linha do XML
    vr_nrdlinha := 6;

    -- Se tem Preposto
    IF TRIM(pr_xmldata.nmprepos) IS NOT NULL THEN
      pc_escreve_xml('           Preposto: '||pr_xmldata.nmprepos,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    -- Se tem Operador
    IF TRIM(pr_xmldata.nmoperad) IS NOT NULL THEN
      pc_escreve_xml('           Operador: '||pr_xmldata.nmoperad,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
     
    -- Conta/dv Destino
    pc_escreve_xml('   Conta/dv Destino: '||pr_xmldata.auxiliar,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
  
    -- Data Transacao
    pc_escreve_xml('     Data Transacao: '||to_char(pr_xmldata.dttransa,'dd/mm/yy'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
  
    -- Hora de transação
    pc_escreve_xml('               Hora: '||to_char(to_date(pr_xmldata.hrautent,'SSSSS'),'hh24:mi:ss') ,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
  
    -- Data da transferencia
    pc_escreve_xml('  Dt. Transferencia: '||to_char(pr_xmldata.dtmvtolx,'dd/mm/yy') ,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
  
    -- Valor
    pc_escreve_xml('              Valor: '||to_char(pr_xmldata.valor,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
      
    -- Protocolo
    pc_escreve_xml('          Protocolo: '||pr_xmldata.dsprotoc,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
   
    -- Se tem informação de código de barras
    IF  TRIM(pr_xmldata.cdbarras) IS NOT NULL THEN
      pc_escreve_xml('   '||pr_xmldata.cdbarras,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    -- Se tem informação de linha digitável
    IF  TRIM(pr_xmldata.lndigita) IS NOT NULL THEN
      pc_escreve_xml('    '||pr_xmldata.lndigita,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
        
    -- Imprimir documento e sequencia de autenticação
    pc_escreve_xml('      Nr. Documento: '||pr_xmldata.auxiliar2,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
        
    pc_escreve_xml('  Seq. Autenticacao: '||pr_xmldata.auxiliar3,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    -- Se vai escrever a linha 20... ou mais
    IF vr_nrdlinha >= 18 THEN
      pc_escreve_xml('--------------------------------------------------------------------------------',vr_nrdlinha);
    ELSE 
      pc_escreve_xml('--------------------------------------------------------------------------------',18);
    END IF;

  END pc_impressao_credito;
  
  -- Imprimir comprovante de TAA
  PROCEDURE pc_impressao_taa(pr_xmldata  IN typ_xmldata
                            ,pr_nmrescop IN VARCHAR2) IS
    -- ..........................................................................
    --
    --  Programa : Antigo /generico/procedures/b1wgen0122.p --> impressao_taa 
    --  Sistema  : Rotinas para impressão de dados
    --  Sigla    : VERPRO
    --  Autor    : Renato Darosci  - Supero
    --  Data     : Julho/2014.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    -- 	
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Agrupa os dados e monta o layout para impressão de comprovantes TAA
    --
    --   Alteracoes: 29/07/2014 - Conversão Progress >>> Oracle. Renato - Supero
    --
    -- .............................................................................
                          
  BEGIN

    -- IMPRIMIR OS DADOS DO COMPROVANTE DE DEPÓSITO TAA
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,01);
    pc_escreve_xml('    '||RPAD(pr_nmrescop,13,' ')||' - Comprovante Deposito TAA - '||
                   'Emissao: '||to_char(SYSDATE,'DD/MM/YY')||' as '||to_char(SYSDATE,'HH24:MI:SS')||' Hr' ,02); 
    pc_escreve_xml('           Conta/DV: '||to_char(pr_xmldata.nrdconta)||' - '||pr_xmldata.nmprimtl     ,04);
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,05);
    pc_escreve_xml('       '||SUBSTR(pr_xmldata.label,0,instr(pr_xmldata.label,':'))||' '||pr_xmldata.auxiliar           ,06);
    pc_escreve_xml('                   Data: '||to_char(pr_xmldata.dttransa,'dd/mm/yy')                           ,07);
    pc_escreve_xml('                   Hora: '||to_char(to_date(pr_xmldata.hrautent,'SSSSS'),'hh24:mi:ss')        ,08);
    pc_escreve_xml('         Data Movimento: '||to_char(pr_xmldata.dtmvtolx,'dd/mm/yy')                           ,09);
    pc_escreve_xml('                  Valor: '||to_char(pr_xmldata.valor,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),10);
    pc_escreve_xml('              Protocolo: '||pr_xmldata.dsprotoc                                               ,11);
    pc_escreve_xml('        '||pr_xmldata.cdbarras                                                       ,12);
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,13);

  END pc_impressao_taa;
  
  -- Imprimir comprovante de pagamento TAA
  PROCEDURE pc_impressao_pag_taa(pr_xmldata  IN typ_xmldata
                                ,pr_nmrescop IN VARCHAR2
                                ,pr_cdbcoctl IN NUMBER
                                ,pr_cdagectl IN NUMBER) IS
    -- ..........................................................................
    --
    --  Programa : Antigo /generico/procedures/b1wgen0122.p --> impressao_pag_taa 
    --  Sistema  : Rotinas para impressão de dados
    --  Sigla    : VERPRO
    --  Autor    : Renato Darosci  - Supero
    --  Data     : Julho/2014.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    -- 	
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Agrupa os dados e monta o layout para impressão de comprovantes de pagamento TAA
    --
    --   Alteracoes: 29/07/2014 - Conversão Progress >>> Oracle. Renato - Supero
    --
    -- .............................................................................
    
    -- Variáveis
    vr_nrdlinha     NUMBER := 0;  
    vr_dsbanco      VARCHAR2(50);
                         
  BEGIN

    -- IMPRIMIR OS DADOS DO COMPROVANTE DE PAGAMENTO TAA
    pc_escreve_xml('--------------------------------------------------------------------------------'     ,01);
    pc_escreve_xml('    '||RPAD(pr_nmrescop,13,' ')||' - Comprovante Pagamento TAA - '||
                   'Emissao: '||to_char(SYSDATE,'DD/MM/YY')||' as '||to_char(SYSDATE,'HH24:MI:SS')||' Hr' ,02); 
    pc_escreve_xml('              Banco: '||to_char(pr_cdbcoctl)                                          ,04);
    pc_escreve_xml('            Agencia: '||to_char(pr_cdagectl)                                          ,05);
    pc_escreve_xml('           Conta/DV: '||to_char(pr_xmldata.nrdconta)||' - '||pr_xmldata.nmprimtl      ,06);
    pc_escreve_xml('--------------------------------------------------------------------------------'     ,07);
    
    -- separar a descrição do banco
    vr_dsbanco  := SUBSTR(pr_xmldata.label,instr(pr_xmldata.label,':')+1);
    
    -- Controle de linha
    vr_nrdlinha := 08;
    
    -- Se o label inicia com Banco
    IF pr_xmldata.label LIKE 'Banco%' THEN
      -- Informação do Banco
      pc_escreve_xml('              Banco: '||vr_dsbanco ,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
      -- Informação do Cedente
      pc_escreve_xml('            Cedente: '||pr_xmldata.auxiliar3 ,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    ELSE
      -- Informação dinamica do banco ou cedente
      pc_escreve_xml('  '||SUBSTR(pr_xmldata.label,0,instr(pr_xmldata.label,':'))||' '||vr_dsbanco,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha      
    END IF;
    
    -- Demais dados
    pc_escreve_xml('     Data Transacao: '||to_char(pr_xmldata.dttransa,'dd/mm/yy')                           ,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha      
    pc_escreve_xml('               Hora: '||to_char(to_date(pr_xmldata.hrautent,'SSSSS'),'hh24:mi:ss')        ,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha      
    pc_escreve_xml('     Data Pagamento: '||to_char(pr_xmldata.dtmvtolx,'dd/mm/yy')                           ,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha      
    pc_escreve_xml('              Valor: '||to_char(pr_xmldata.valor,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha      
    pc_escreve_xml('          Protocolo: '||pr_xmldata.dsprotoc                                               ,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha      
    pc_escreve_xml('  '||pr_xmldata.cdbarras  ,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha     
    pc_escreve_xml('   '||pr_xmldata.lndigita  ,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha    
    pc_escreve_xml('  Seq. Autenticacao: '||pr_xmldata.auxiliar4,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    pc_escreve_xml('      Nr. Documento: '||pr_xmldata.auxiliar2,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    pc_escreve_xml('--------------------------------------------------------------------------------' ,vr_nrdlinha);

  END pc_impressao_pag_taa;
  
  -- Imprimir comprovante arquivo de remessa
  PROCEDURE pc_impressao_rem(pr_xmldata  IN typ_xmldata
                            ,pr_nmrescop IN VARCHAR2) IS
    -- ..........................................................................
    --
    --  Programa : Antigo /generico/procedures/b1wgen0122.p --> impressao_rem 
    --  Sistema  : Rotinas para impressão de dados
    --  Sigla    : VERPRO
    --  Autor    : Renato Darosci  - Supero
    --  Data     : Julho/2014.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    -- 	
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Agrupa os dados e monta o layout para impressão de comprovantes de capital
    --
    --   Alteracoes: 28/07/2014 - Conversão Progress >>> Oracle. Renato - Supero
    --
    -- .............................................................................
                          
  BEGIN

    -- IMPRIMIR OS DADOS DO COMPROVANTE DE CAPITAL
    pc_escreve_xml('--------------------------------------------------------------------------------'        ,01);
    pc_escreve_xml('    '||RPAD(pr_nmrescop,14,' ')||' - Arquivo Remessa - '||
                   'Emissao: '||to_char(SYSDATE,'DD/MM/YY')                 ||
                   ' Remessa: '||TRIM(GENE0002.fn_mask(pr_xmldata.nrdocmto,'zzz,zzz,zzz,zz9')), 02); 
    pc_escreve_xml('          Conta/DV: '||to_char(pr_xmldata.nrdconta,'FM999G999G990','NLS_NUMERIC_CHARACTERS=,.')||' - '||pr_xmldata.nmprimtl          ,04);
    pc_escreve_xml('--------------------------------------------------------------------------------'        ,05);
    pc_escreve_xml('          '||pr_xmldata.label                                                            ,06);
    pc_escreve_xml('    Data Transacao: '||to_char(pr_xmldata.dttransa,'dd/mm/yy')                           ,07);
    pc_escreve_xml(' Hora da Transacao: '||to_char(to_date(pr_xmldata.hrautent,'SSSSS'),'hh24:mi:ss')        ,08);
    pc_escreve_xml('   Data da Remessa: '||to_char(pr_xmldata.dtmvtolx,'dd/mm/yy')                           ,09);
    pc_escreve_xml('             Valor: '||to_char(pr_xmldata.valor,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),10);
    pc_escreve_xml('  '||pr_xmldata.cdbarras                                                                 ,11);
    pc_escreve_xml('   '||pr_xmldata.lndigita                                                                ,12);
    pc_escreve_xml('         Protocolo: '||pr_xmldata.dsprotoc                                               ,13);
    pc_escreve_xml('--------------------------------------------------------------------------------'        ,14);

  END pc_impressao_rem;
  
  -- Rotina para impressão de TEDs
  PROCEDURE pc_impressao_ted(pr_xmldata  IN typ_xmldata
                            ,pr_nmrescop IN VARCHAR2) IS
    -- ..........................................................................
    --
    --  Programa : Antigo /generico/procedures/b1wgen0122.p --> impressao_transf 
    --  Sistema  : Rotinas para impressão de dados
    --  Sigla    : VERPRO
    --  Autor    : Renato Darosci  - Supero
    --  Data     : Julho/2014.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Agrupa os dados e monta o layout para impressão de dados de transferencia
    --
    --   Alteracoes: 25/07/2014 - Conversão Progress >>> Oracle. Renato - Supero
    --
    -- .............................................................................
    
    -- Variáveis
    vr_nrdlinha     NUMBER := 0;  
                          
  BEGIN

    -- IMPRIMIR O CABEÇALHO
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,1);
    pc_escreve_xml('     '||pr_nmrescop||' - Comprovante TED - '||
                   'Emissao: '||to_char(SYSDATE,'DD/MM/YYYY')||' as '||to_char(SYSDATE,'HH24:MI:SS')||' Hr',2); 
    pc_escreve_xml('           Conta/DV: '||TRIM(GENE0002.fn_mask_conta(pr_xmldata.nrdconta))||' - '||pr_xmldata.nmprimtl,4);
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,5);
    -- IMPRIMIR O CONTEÚDO
    -- Contador de linha - Iniciando na sexta linha do XML
    vr_nrdlinha := 6;

    -- Se tem Preposto
    IF TRIM(pr_xmldata.nmprepos) IS NOT NULL THEN
      pc_escreve_xml('           Preposto: '||pr_xmldata.nmprepos,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    -- Se tem Operador
    IF TRIM(pr_xmldata.nmoperad) IS NOT NULL THEN
      pc_escreve_xml('           Operador: '||pr_xmldata.nmoperad,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    -- Imprimir Banco Favorecido
    pc_escreve_xml('   Banco Favorecido: '||pr_xmldata.dsdbanco,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
     -- Imprimir Banco Favorecido
    pc_escreve_xml('    ISPB Favorecido: '||pr_xmldata.dsispbif,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    -- Imprimir agencia do favorecido
    pc_escreve_xml(' Agencia Favorecido: '||pr_xmldata.dsageban,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprimir conta do favorecido
    pc_escreve_xml('   Conta Favorecido: '||pr_xmldata.nrctafav,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprimir o nome do favorecido
    pc_escreve_xml('    Nome Favorecido: '||pr_xmldata.nmfavore,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Verifica pelo tamanho se é CNPJ ou CPF
    IF length(TRIM(pr_xmldata.nrcpffav)) = 18  THEN
      -- Imprimir o CNPJ do favorecido
      pc_escreve_xml('    CNPJ Favorecido: '||pr_xmldata.nrcpffav,vr_nrdlinha);  
    ELSE
      -- Imprimir o CPF do favorecido
      pc_escreve_xml('     CPF Favorecido: '||pr_xmldata.nrcpffav,vr_nrdlinha);  
    END IF;

    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    -- Imprimir Finalidade
    pc_escreve_xml('         Finalidade: '||pr_xmldata.dsfinali,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    -- Se tem Código de identificação
    IF TRIM(pr_xmldata.dstransf) IS NOT NULL THEN
      pc_escreve_xml('  Cod.Identificador: '||pr_xmldata.dstransf,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    -- Imprimir Finalidade
    pc_escreve_xml('Data/Hora Transacao: '||to_char(pr_xmldata.dttransa,'DD/MM/YYYY')||' - '
                                          ||to_char(to_date(pr_xmldata.hrautent,'SSSSS'),'HH24:MI:SS'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime a conta destino
    pc_escreve_xml('              Valor: '||to_char(pr_xmldata.valor,'FM9G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprimir o protocolo
    pc_escreve_xml('          Protocolo: '||pr_xmldata.dsprotoc,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprimir o número do Documento
    pc_escreve_xml('      Nr. Documento: '||pr_xmldata.nrdocmto,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime a sequencia de autenticação
    pc_escreve_xml('  Seq. Autenticacao: '||pr_xmldata.nrseqaut,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
        
    -- Se vai escrever a linha 20... ou mais
    IF vr_nrdlinha >= 20 THEN
      pc_escreve_xml('--------------------------------------------------------------------------------',vr_nrdlinha);
    ELSE 
      pc_escreve_xml('--------------------------------------------------------------------------------',20);
    END IF;

  END pc_impressao_ted;
        
  -- PJ470 - Rubens Lima (Mouts) - Rotina para impressão de CTDs
  PROCEDURE pc_impressao_ctd(pr_xmldata  IN typ_xmldata
                            ,pr_nmrescop IN VARCHAR2) IS
    -- ..........................................................................
    --
    --  Programa :  
    --  Sistema  : Rotinas para impressão de dados
    --  Autor    : Rubens Lima  - Mouts
    --  Data     : Dezembro/2018.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Agrupa os dados e monta o layout para impressão de dados de CTDs
    --
    --   Alteracoes: 
    --
    -- .............................................................................
    
    -- Variáveis
    vr_nrdlinha     NUMBER := 0;  
                          
  BEGIN

    -- IMPRIMIR O CABEÇALHO
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,1);
    pc_escreve_xml(' '||pr_nmrescop||' - '|| pr_xmldata.tpdocmto ||' - '||       'Emissao: '||to_char(SYSDATE,'DD/MM/YY')||' as '||to_char(SYSDATE,'HH24:MI:SS')||' Hr',2); 
    pc_escreve_xml('           Conta/DV: '||pr_xmldata.nrdconta||' - '||pr_xmldata.nmprimtl,4);
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,5);
    -- IMPRIMIR O CONTEÚDO
    -- Contador de linha - Iniciando na sexta linha do XML
    vr_nrdlinha := 6;

      -- Imprimir conta e nome
    pc_escreve_xml('               Conta/dv: '||TRIM(GENE0002.fn_mask_conta(pr_xmldata.nrdconta))||' - '||pr_xmldata.nmprimtl,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

      -- Imprimir Data
    pc_escreve_xml('                   Data: '||to_char(pr_xmldata.dtinclusao,'DD/MM/YY'),vr_nrdlinha);
    
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

      -- Imprimir Hora
    pc_escreve_xml('                   Hora: '||to_char(pr_xmldata.hrinclusao,'HH24:MI:SS'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

      -- Imprimir Data Movimento
    pc_escreve_xml('         Data Movimento: '||to_char(pr_xmldata.dttransa,'DD/MM/YY'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    IF pr_xmldata.dsoperacao <> '-' THEN
      pc_escreve_xml('               Operação: '||pr_xmldata.dsoperacao,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    IF pr_xmldata.cdbanco <> '-' THEN
      pc_escreve_xml('                  Banco: '||pr_xmldata.cdbanco,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    IF pr_xmldata.cdagencia <> '-' THEN
      pc_escreve_xml('                Agência: '||pr_xmldata.cdagencia,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    IF pr_xmldata.cdconta <> '-' THEN
      pc_escreve_xml('                  Conta: '||pr_xmldata.cdconta,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    IF pr_xmldata.nrcheque_i <> '-' THEN
      pc_escreve_xml('         Cheque Inicial: '||pr_xmldata.nrcheque_i,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    IF pr_xmldata.nrcheque_f <> '-' THEN
      pc_escreve_xml('           Cheque Final: '||pr_xmldata.nrcheque_f,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    IF pr_xmldata.cdbanco = '-' THEN -- Se cdbanco está preenchido o tipo é 30 ou 31 e não deve listar valor
      pc_escreve_xml('               Contrato: '||pr_xmldata.nrdocmto,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
      -- Imprimir o Valor
      pc_escreve_xml('                  Valor: '||to_char(pr_xmldata.valor,'FM9999999999D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

      -- Imprimir o Protocolo
    pc_escreve_xml('              Protocolo: '||pr_xmldata.dsprotoc,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
       
    -- Se vai escrever a linha 13... ou mais
    IF vr_nrdlinha >= 13 THEN
      pc_escreve_xml('--------------------------------------------------------------------------------',vr_nrdlinha);
    ELSE 
      pc_escreve_xml('--------------------------------------------------------------------------------',13);
    END IF;

  END pc_impressao_ctd;

        
  -- Imprimir comprovante de Aplicação
  PROCEDURE pc_impressao_aplica(pr_xmldata  IN typ_xmldata
                               ,pr_cdcooper IN NUMBER
                               ,pr_nmrescop IN VARCHAR2) IS
    -- ..........................................................................
    --
    --  Programa : Antigo /generico/procedures/b1wgen0122.p --> impressao_aplicacao 
    --  Sistema  : Rotinas para impressão de dados
    --  Sigla    : VERPRO
    --  Autor    : Renato Darosci  - Supero
    --  Data     : Julho/2014.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Agrupa os dados e monta o layout para impressão de dados de aplicações
    --
    --   Alteracoes: 30/07/2014 - Conversão Progress >>> Oracle. Renato - Supero
    --
    -- .............................................................................
    
    -- Cursores
    -- Buscar dados do protocolo
    CURSOR cr_crappro IS
      SELECT crappro.dsinform##1
           , crappro.dsinform##2
           , crappro.dsinform##3
        FROM crappro
       WHERE crappro.cdcooper        = pr_cdcooper
         AND UPPER(crappro.dsprotoc) = pr_xmldata.dsprotoc;
    
    -- Variáveis
    vr_dsinform1    crappro.dsinform##1%TYPE;
    vr_dsinform2    crappro.dsinform##2%TYPE;
    vr_dsinform3    crappro.dsinform##3%TYPE;
    
    rw_tbdinfo1     GENE0002.typ_split;
    rw_tbdinfo2     GENE0002.typ_split;
    rw_tbdinfo3     GENE0002.typ_split;
    
    vr_nmsolici     VARCHAR2(100);
    vr_dstaxctr     VARCHAR2(100);
    vr_dstaxmin     VARCHAR2(100);
    vr_dscarenc     VARCHAR2(100);
		vr_nmprodut     VARCHAR2(100);
    
    vr_nraplica     NUMBER;
    vr_nrdlinha     NUMBER := 0;  
    
    vr_dtaplica     DATE;
    vr_dtvencim     DATE;
    vr_dtcarenc     DATE;		
    
  BEGIN

    -- IMPRIMIR O CABEÇALHO
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,1);
    pc_escreve_xml('     '||pr_nmrescop||' - Comprovante Aplicacao - '||
                   'Emissao: '||to_char(SYSDATE,'DD/MM/YYYY')||' as '||to_char(SYSDATE,'HH24:MI:SS')||' Hr',2); 
    pc_escreve_xml('           Conta/DV: '||TRIM(GENE0002.fn_mask_conta(pr_xmldata.nrdconta))||' - '||pr_xmldata.nmprimtl,4);
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,5);
    -- IMPRIMIR O CONTEÚDO
    -- Contador de linha - Iniciando na sexta linha do XML
    vr_nrdlinha := 6;

    -- Se tem Preposto
    IF TRIM(pr_xmldata.nmprepos) IS NOT NULL THEN
      pc_escreve_xml('           Preposto: '||pr_xmldata.nmprepos,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    -- Se tem Operador
    IF TRIM(pr_xmldata.nmoperad) IS NOT NULL THEN
      pc_escreve_xml('           Operador: '||pr_xmldata.nmoperad,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
    
    -- Buscar informações do protocolo
    OPEN  cr_crappro;
    FETCH cr_crappro INTO vr_dsinform1
                        , vr_dsinform2
                        , vr_dsinform3;
    -- Se não encontrar dados
    IF cr_crappro%NOTFOUND THEN
      -- Limpar as variáveis
      vr_dsinform1 := NULL;
      vr_dsinform2 := NULL;
      vr_dsinform3 := NULL;
    END IF;
    
    -- Fecha o cursor
    CLOSE cr_crappro;
    
    -- Faz o split dos dados e colocar em registros
    rw_tbdinfo1 := GENE0002.fn_quebra_string(pr_string => vr_dsinform1,pr_delimit => '#');
    rw_tbdinfo2 := GENE0002.fn_quebra_string(pr_string => vr_dsinform2,pr_delimit => '#');
    rw_tbdinfo3 := GENE0002.fn_quebra_string(pr_string => vr_dsinform3,pr_delimit => '#');
    
    -- Se retornou valores na informação 2
    IF rw_tbdinfo2.COUNT() > 0 THEN
      -- Nome
      vr_nmsolici := TRIM(rw_tbdinfo2(1));
    END IF;
    
    -- Se retornou valores na informação 3
    IF rw_tbdinfo3.COUNT() > 0 THEN
      -- Data da aplicação
      vr_dtaplica := to_date(TRIM(SUBSTR(rw_tbdinfo3(1),INSTR(rw_tbdinfo3(1),':')+1)),'dd/mm/yyyy');
      -- número da aplicação
      vr_nraplica := to_number(TRIM(SUBSTR(rw_tbdinfo3(2),INSTR(rw_tbdinfo3(2),':')+1)));
      -- Taxa contratada
      vr_dstaxctr := TRIM(SUBSTR(rw_tbdinfo3(3),INSTR(rw_tbdinfo3(3),':')+1));      
			
      IF rw_tbdinfo3.COUNT() > 10 THEN			
				IF rw_tbdinfo3.COUNT() = 11 THEN
						-- Data de vencimento
					vr_dtvencim := to_date(TRIM(SUBSTR(rw_tbdinfo3(4),INSTR(rw_tbdinfo3(4),':')+1)),'dd/mm/yyyy');
					-- Tempo de carencia
					vr_dtcarenc := to_date(TRIM(SUBSTR(rw_tbdinfo3(6),INSTR(rw_tbdinfo3(6),':')+1)),'dd/mm/yyyy');
					-- Taxa minima
          vr_dstaxmin := TRIM(SUBSTR(rw_tbdinfo3(11),INSTR(rw_tbdinfo3(11),':')+1));
					-- Carencia
          vr_dscarenc := TRIM(SUBSTR(rw_tbdinfo3(5),INSTR(rw_tbdinfo3(5),':')+1));
				ELSIF TRIM(rw_tbdinfo3(11)) = 'N' THEN
					-- Nome da aplicação
					vr_nmprodut := ' - ' || TRIM(rw_tbdinfo3(12));
				  -- Data de vencimento
          vr_dtvencim := to_date(TRIM(SUBSTR(rw_tbdinfo3(5),INSTR(rw_tbdinfo3(4),':')+1)),'dd/mm/yyyy');
          -- Tempo de carencia
          vr_dtcarenc := to_date(TRIM(SUBSTR(rw_tbdinfo3(7),INSTR(rw_tbdinfo3(7),':')+1)),'dd/mm/yyyy');
					-- Taxa minima
          vr_dstaxmin := TRIM(SUBSTR(rw_tbdinfo3(4),INSTR(rw_tbdinfo3(4),':')+1));
					-- Carencia
          vr_dscarenc := TRIM(SUBSTR(rw_tbdinfo3(6),INSTR(rw_tbdinfo3(6),':')+1));
        END IF;
				
			ELSE
				-- Data de vencimento
        vr_dtvencim := to_date(TRIM(SUBSTR(rw_tbdinfo3(5),INSTR(rw_tbdinfo3(5),':')+1)),'dd/mm/yyyy');
        -- Tempo de carencia
        vr_dtcarenc := to_date(TRIM(SUBSTR(rw_tbdinfo3(7),INSTR(rw_tbdinfo3(7),':')+1)),'dd/mm/yyyy');
				-- Taxa minima
        vr_dstaxmin := TRIM(SUBSTR(rw_tbdinfo3(4),INSTR(rw_tbdinfo3(4),':')+1));
				-- Carencia
        vr_dscarenc := TRIM(SUBSTR(rw_tbdinfo3(6),INSTR(rw_tbdinfo3(6),':')+1));

			END IF;
    END IF;
    
    -- Imprimir o solicitante
    pc_escreve_xml('          Solicitante: '||vr_nmsolici  ,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprimir a data da aplicação
    pc_escreve_xml('    Data da Aplicacao: '||to_char(vr_dtaplica,'dd/mm/yyyy') ,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    -- Imprimir a hora da aplicação
    pc_escreve_xml('    Hora da Aplicacao: '||to_char(to_date(pr_xmldata.hrautent,'SSSSS'),'HH24:MI:SS') ,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    
    -- Imprimir o número da aplicação
    IF rw_tbdinfo3.COUNT() > 10 THEN
		   IF TRIM(rw_tbdinfo3(11)) = 'N' THEN
         pc_escreve_xml('  Numero da Aplicacao: '||vr_nraplica|| vr_nmprodut ,vr_nrdlinha);
			 ELSE
				 pc_escreve_xml('  Numero da Aplicacao: '||vr_nraplica ,vr_nrdlinha);
			 END IF;
		ELSE
			 pc_escreve_xml('  Numero da Aplicacao: '||vr_nraplica ,vr_nrdlinha);
		END IF;
		
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime o valor
    pc_escreve_xml('                Valor: '||to_char(pr_xmldata.valor,'FM9G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Taxa contratada
    pc_escreve_xml('      Taxa Contratada: '||vr_dstaxctr,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
	  IF rw_tbdinfo3.COUNT() = 11 THEN
			-- Taxa Minima
			pc_escreve_xml('      Taxa no Periodo: '||vr_dstaxmin,vr_nrdlinha);
			vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
		ELSE
      -- Taxa Minima
			pc_escreve_xml('          Taxa Minima: '||vr_dstaxmin,vr_nrdlinha);
			vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
		END IF;
    -- Vencimento
    pc_escreve_xml('           Vencimento: '||to_char(vr_dtvencim,'dd/mm/yyyy'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Carencia
    pc_escreve_xml('             Carencia: '||vr_dscarenc,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    -- Data da Carencia
    pc_escreve_xml('     Data da Carencia: '||to_char(vr_dtcarenc,'dd/mm/yyyy'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    -- Imprimir o protocolo
    pc_escreve_xml('            Protocolo: '||pr_xmldata.dsprotoc,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime a sequencia de autenticação
    pc_escreve_xml('    Seq. Autenticacao: '||pr_xmldata.nrseqaut,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
        
    -- Se vai escrever a linha 20... ou mais
    IF vr_nrdlinha >= 20 THEN
      pc_escreve_xml('--------------------------------------------------------------------------------',vr_nrdlinha);
    ELSE 
      pc_escreve_xml('--------------------------------------------------------------------------------',20);
    END IF;

  END pc_impressao_aplica;
  
  -- Imprimir comprovante de Resgate de Aplicação
  PROCEDURE pc_impressao_resg_aplica(pr_xmldata  IN typ_xmldata
                                    ,pr_cdcooper IN NUMBER
                                    ,pr_nmrescop IN VARCHAR2) IS
    -- ..........................................................................
    --
    --  Programa : pc_impressao_resg_aplica 
    --  Sistema  : Rotinas para impressão de dados
    --  Sigla    : VERPRO
    --  Autor    : Lucas Ranghetti
    --  Data     : Agosto/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Agrupa os dados e monta o layout para impressão de dados de 
    --               resgate de aplicações
    --
    --   Alteracoes: 
    --
    -- .............................................................................
    
    -- Cursores
    -- Buscar dados do protocolo
    CURSOR cr_crappro IS
      SELECT crappro.dsinform##1
           , crappro.dsinform##2
           , crappro.dsinform##3
        FROM crappro
       WHERE crappro.cdcooper        = pr_cdcooper
         AND UPPER(crappro.dsprotoc) = pr_xmldata.dsprotoc;
    
    -- Variáveis
    vr_dsinform1    crappro.dsinform##1%TYPE;
    vr_dsinform2    crappro.dsinform##2%TYPE;
    vr_dsinform3    crappro.dsinform##3%TYPE;
    
    rw_tbdinfo1     GENE0002.typ_split;
    rw_tbdinfo2     GENE0002.typ_split;
    rw_tbdinfo3     GENE0002.typ_split;
    
    vr_nmsolici     VARCHAR2(100);
    vr_dstaxctr     VARCHAR2(100);
    
    vr_nraplica     NUMBER;
    vr_nrdlinha     NUMBER := 0;  
    
    vr_dtaplica     DATE;
    
    vr_vlrbruto   NUMBER(25,2);    
    vr_aliquota   VARCHAR2(100);
    
  BEGIN

    -- IMPRIMIR O CABEÇALHO
    pc_escreve_xml('--------------------------------------------------------------------------------',1);
    pc_escreve_xml('     '||pr_nmrescop||' - Comprovante de Resgate de Aplicacao                    ',2); 
    pc_escreve_xml('            Emissao: '||to_char(SYSDATE,'DD/MM/YYYY')||' as '||to_char(SYSDATE,'HH24:MI:SS')||' Hr',3); 
    pc_escreve_xml('           Conta/DV: '||TRIM(GENE0002.fn_mask_conta(pr_xmldata.nrdconta))||' - '||pr_xmldata.nmprimtl,4);
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,5);
    
    -- IMPRIMIR O CONTEÚDO
    
    -- Contador de linha - Iniciando na sexta linha do XML
    vr_nrdlinha := 6;

    -- Se tem Preposto
    IF TRIM(pr_xmldata.nmprepos) IS NOT NULL THEN
      pc_escreve_xml('           Preposto: '||pr_xmldata.nmprepos,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    -- Se tem Operador
    IF TRIM(pr_xmldata.nmoperad) IS NOT NULL THEN
      pc_escreve_xml('           Operador: '||pr_xmldata.nmoperad,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
    
    -- Buscar informações do protocolo
    OPEN  cr_crappro;
    FETCH cr_crappro INTO vr_dsinform1
                        , vr_dsinform2
                        , vr_dsinform3;
    -- Se não encontrar dados
    IF cr_crappro%NOTFOUND THEN
      -- Limpar as variáveis
      vr_dsinform1 := NULL;
      vr_dsinform2 := NULL;
      vr_dsinform3 := NULL;
    END IF;
    
    -- Fecha o cursor
    CLOSE cr_crappro;
    
    -- Faz o split dos dados e colocar em registros
    rw_tbdinfo1 := GENE0002.fn_quebra_string(pr_string => vr_dsinform1,pr_delimit => '#');
    rw_tbdinfo2 := GENE0002.fn_quebra_string(pr_string => vr_dsinform2,pr_delimit => '#');
    rw_tbdinfo3 := GENE0002.fn_quebra_string(pr_string => vr_dsinform3,pr_delimit => '#');
    
    -- Se retornou valores na informação 2
    IF rw_tbdinfo2.COUNT() > 0 THEN
      -- Nome
      vr_nmsolici := TRIM(rw_tbdinfo2(1));
    END IF;
    
    -- Se retornou valores na informação 3
    IF rw_tbdinfo3.COUNT() > 0 THEN
      -- Data da aplicação
      vr_dtaplica := to_date(TRIM(SUBSTR(rw_tbdinfo3(1),INSTR(rw_tbdinfo3(1),':')+1)),'dd/mm/yyyy');
      -- número da aplicação
      vr_nraplica := to_number(TRIM(SUBSTR(rw_tbdinfo3(2),INSTR(rw_tbdinfo3(2),':')+1)));
      -- Taxa contratada
      vr_dstaxctr := TRIM(SUBSTR(rw_tbdinfo3(3),INSTR(rw_tbdinfo3(3),':')+1));     
      -- Aliquota
      vr_aliquota := TRIM(SUBSTR(rw_tbdinfo3(4),INSTR(rw_tbdinfo3(4),':')+1));  
      -- Valor Bruto
      vr_vlrbruto := TO_NUMBER(TRIM(SUBSTR(rw_tbdinfo3(5),INSTR(rw_tbdinfo3(5),':') + 1)),'FM9G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.');
    END IF;
    
    -- Imprimir o solicitante
    pc_escreve_xml('          Solicitante: '||vr_nmsolici  ,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprimir a data da aplicação
    pc_escreve_xml('      Data do Resgate: '||to_char(vr_dtaplica,'dd/mm/yyyy') ,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    -- Imprimir a hora da aplicação
    pc_escreve_xml('      Hora do Resgate: '||to_char(to_date(pr_xmldata.hrautent,'SSSSS'),'HH24:MI:SS') ,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprimir o número da aplicação    
	  pc_escreve_xml('  Numero da Aplicacao: '||vr_nraplica ,vr_nrdlinha);				
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime o valor Bruto
    pc_escreve_xml('          Valor Bruto: '||to_char(vr_vlrbruto,'FM9G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Taxa contratada
    pc_escreve_xml('                 IRRF: '||vr_dstaxctr,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    -- Aliquota IRRF
    pc_escreve_xml('        Aliquota IRRF: '||vr_aliquota,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    -- Imprime o valor Liquido
    pc_escreve_xml('        Valor Liquido: '||to_char(pr_xmldata.valor,'FM9G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha    
  
    -- Imprimir o protocolo
    pc_escreve_xml('            Protocolo: '||pr_xmldata.dsprotoc,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime a sequencia de autenticação
    pc_escreve_xml('    Seq. Autenticacao: '||pr_xmldata.nrseqaut,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
      
    pc_escreve_xml('--------------------------------------------------------------------------------',20);
    
  END pc_impressao_resg_aplica;
  
  -- Imprimir protocolo pacote de tarifa
  PROCEDURE pc_impressao_pac_tar(pr_xmldata  IN typ_xmldata
                                ,pr_nmrescop IN VARCHAR2) IS
    -- ..........................................................................
    --
    --  Programa : pc_impressao_pac_tar
    --  Sistema  : Rotinas para impressão de dados
    --  Sigla    : VERPRO
    --  Autor    : Lucas Reinert
    --  Data     : Maio/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    -- 	
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Agrupa os dados e monta o layout para impressão do protocolo de
		--               pacote de tarifas
    --
    --   Alteracoes: 
    --
    -- .............................................................................
          
    -- Variáveis
    vr_nrdlinha     NUMBER := 0;  
		                
  BEGIN

    -- IMPRIMIR OS DADOS DE PACOTE DE TARIFAS
    pc_escreve_xml('--------------------------------------------------------------------------------'        ,1);
    pc_escreve_xml('    '||RPAD(pr_nmrescop,14,' ')||' - Servicos Cooperativos - '||
		               'Emissao: '||to_char(SYSDATE,'DD/MM/YYYY')||' as '||to_char(SYSDATE,'HH24:MI:SS')||' Hr',2); 
    pc_escreve_xml('          Conta/DV: '||to_char(pr_xmldata.nrdconta,'FM999G999G990','NLS_NUMERIC_CHARACTERS=,.')||' - '||pr_xmldata.nmprimtl          ,4);	
    pc_escreve_xml('--------------------------------------------------------------------------------'        ,5);
		
    -- Contador de linha - Iniciando na sexta linha do XML
    vr_nrdlinha := 6;

    -- Se tem Preposto
    IF TRIM(pr_xmldata.nmprepos) IS NOT NULL THEN
      pc_escreve_xml('           Preposto: '||pr_xmldata.nmprepos,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    -- Imprime a data de transação
    pc_escreve_xml('     Data Transacao: '||to_char(pr_xmldata.dttransa,'dd/mm/yy'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime a hora da transação
    pc_escreve_xml('               Hora: '||to_char(to_date(pr_xmldata.hrautent,'SSSSS'),'hh24:mi:ss'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime a descrição do pacote
    pc_escreve_xml('            Servico: '||pr_xmldata.dspacote,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    pc_escreve_xml('              Valor: '||to_char(pr_xmldata.valor,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
		
    -- Imprime dia do débito
    pc_escreve_xml('      Dia do debito: '||pr_xmldata.dtdiadeb,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime a data de início da vigência
    pc_escreve_xml('      Data Vigencia: '||to_char(pr_xmldata.dtinivig,'dd/mm/yy'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime o protocolo
    pc_escreve_xml('          Protocolo: '||pr_xmldata.dsprotoc,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
		
		-- Imprime linha de rodapé
    pc_escreve_xml('--------------------------------------------------------------------------------'        ,vr_nrdlinha);

  END pc_impressao_pac_tar;
  
	-- Rotina para impressão de DARF/DAS
  PROCEDURE pc_impressao_darf_das(pr_xmldata  IN typ_xmldata
                                 ,pr_nmrescop IN VARCHAR2
                                 ,pr_cdbcoctl IN NUMBER
                                 ,pr_cdagectl IN NUMBER) IS
    -- ..........................................................................
    --
    --  Programa : 
    --  Sistema  : Rotinas para impressão de dados
    --  Sigla    : VERPRO
    --  Autor    : Lucas Lunelli
    --  Data     : Setembro/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Agrupa os dados e monta o layout para impressão de dados de pagamentos de DARF/DAS
    --
    --   Alteracoes:
    --
    -- .............................................................................
    
    -- Variáveis
    vr_nrdlinha     NUMBER := 0;  
    vr_dsbanco      VARCHAR2(50);
		vr_dsdcabec     VARCHAR2(50);
		                          
  BEGIN
		
	  IF    pr_xmldata.cdtippro = 16 THEN
			vr_dsdcabec := 'Pagamento DARF';
		ELSIF pr_xmldata.cdtippro = 17 THEN
			vr_dsdcabec := 'Pagamento DAS';
		ELSIF pr_xmldata.cdtippro = 18 THEN
			vr_dsdcabec := 'Agendamento DARF';
		ELSIF pr_xmldata.cdtippro = 19 THEN
      vr_dsdcabec := 'Agendamento DAS';
		END IF;

    -- IMPRIMIR O CABEÇALHO
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,1);
    pc_escreve_xml('     '||pr_nmrescop||' - Comprovante '|| vr_dsdcabec || ' - '||
                   'Emissao: '||to_char(SYSDATE,'DD/MM/YY')||' as '||to_char(SYSDATE,'HH24:MI:SS')||' Hr',2); 
    pc_escreve_xml('              Banco: '||to_char(pr_cdbcoctl) ,4);
    pc_escreve_xml('            Agencia: '||to_char(pr_cdagectl) ,5);
    pc_escreve_xml('           Conta/DV: '||to_char(pr_xmldata.nrdconta)||' - '||pr_xmldata.nmprimtl,6);
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,7);
    -- IMPRIMIR O CONTEÚDO
    -- Contador de linha - Iniciando na sexta linha do XML
    vr_nrdlinha := 8;
		
		-- Se tem Preposto
    IF TRIM(pr_xmldata.nmprepos) IS NOT NULL THEN
      pc_escreve_xml('           Preposto: '||pr_xmldata.nmprepos,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    -- Se tem Operador
    IF TRIM(pr_xmldata.nmoperad) IS NOT NULL THEN
      pc_escreve_xml('           Operador: '||pr_xmldata.nmoperad,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
		
		-- Se tem solicitante
		IF TRIM(pr_xmldata.nmsolici) IS NOT NULL THEN
      pc_escreve_xml('        Solicitante: '||pr_xmldata.nmsolici,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
		
		-- Se tem Agente arrecadador
		IF TRIM(pr_xmldata.dsagtare) IS NOT NULL THEN
      pc_escreve_xml(' Agente Arrecadador: '||pr_xmldata.dsagtare,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
		
		-- Se tem Agência
		IF TRIM(pr_xmldata.dsagenci) IS NOT NULL THEN
      pc_escreve_xml('            Agencia: '||pr_xmldata.dsagenci,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
		
		-- Se tem Tipo de Docmto		
		IF TRIM(pr_xmldata.tpdocmto) IS NOT NULL THEN
      pc_escreve_xml('  Tipo de Documento: '||pr_xmldata.tpdocmto,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
		
		-- Se tem Nome/Telefone
    IF TRIM(pr_xmldata.dsnomfon) IS NOT NULL THEN
      pc_escreve_xml('      Nome/Telefone: '||pr_xmldata.dsnomfon,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    -- Se tem informação de código de barras
    IF  TRIM(pr_xmldata.cdbarras) IS NOT NULL THEN
      pc_escreve_xml('   Codigo de Barras: '||pr_xmldata.cdbarras,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
		
    -- Se tem informação de linha digitável
    IF  TRIM(pr_xmldata.lndigita) IS NOT NULL THEN
      pc_escreve_xml('    Linha Digitavel: '||pr_xmldata.lndigita,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha    
	END IF;
		
	IF  pr_xmldata.tpcaptur = 1 THEN --CDBARRA
		-- Se tem informação de data de vencimento
		IF  TRIM(pr_xmldata.dtvencto_drf) IS NOT NULL THEN
				pc_escreve_xml(' Data de vencimento: '||to_char(pr_xmldata.dtvencto_drf,'dd/mm/rrrr'),vr_nrdlinha);
      			vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    	END IF;
	END IF;
		
    -- Se tem informação de numero do documento (DAS)
    IF  TRIM(pr_xmldata.nrdocdas) IS NOT NULL THEN
      	pc_escreve_xml('  Nr. Docmto. (DAS): ' ||pr_xmldata.nrdocdas,vr_nrdlinha);
      	vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha    
	END IF;
		
    -- Se tem informação de numero do documento (DARF 385)
    IF  TRIM(pr_xmldata.nrdocdrf) IS NOT NULL THEN
      	pc_escreve_xml('  Nr. Docmto.(DARF): ' ||pr_xmldata.nrdocdrf,vr_nrdlinha);
      	vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha    
	END IF;		
				
	IF  pr_xmldata.tpcaptur = 1 THEN --CDBARRA
		-- Se tem informação de valor total
		IF  TRIM(pr_xmldata.vltotfat) IS NOT NULL THEN
			pc_escreve_xml('        Valor Total: '||to_char(pr_xmldata.vltotfat,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
			vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha    
		END IF;
	END IF;		
		
		-- Se tem Dt Apurac
    IF TRIM(pr_xmldata.dtapurac) IS NOT NULL THEN
      pc_escreve_xml('   Data de Apuracao: '||to_char(pr_xmldata.dtapurac,'dd/mm/rrrr'),vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
		
		-- Se tem CPF/CNPJ
    IF TRIM(pr_xmldata.nrcpfcgc) IS NOT NULL THEN
      pc_escreve_xml(' Numero do CPF/CNPJ: '||pr_xmldata.nrcpfcgc,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
		
		-- Se tem Cod Receita
    IF TRIM(pr_xmldata.cdtribut) IS NOT NULL THEN
      pc_escreve_xml('  Codigo do Tributo: '||pr_xmldata.cdtribut,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
		
		-- Se tem Nr de Referencia
    IF TRIM(pr_xmldata.nrrefere) IS NOT NULL THEN
      pc_escreve_xml(' Nro. de Referencia: '||pr_xmldata.nrrefere,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
		
	IF  pr_xmldata.tpcaptur = 2 THEN --MANUAL
		-- Se tem Dt Vencto
		IF TRIM(pr_xmldata.dtvencto_drf) IS NOT NULL THEN
			pc_escreve_xml(' Data de Vencimento: '||to_char(pr_xmldata.dtvencto_drf,'dd/mm/rrrr'),vr_nrdlinha);
	      	vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
	    END IF;
	END IF;			
		
		-- Se tem Valor Rec Bruta
    IF TRIM(pr_xmldata.vlrecbru) IS NOT NULL THEN
      pc_escreve_xml('Valor Receita Bruta: '||to_char(pr_xmldata.vlrecbru,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
		
		-- Se tem Percentual
    IF TRIM(pr_xmldata.vlpercen) IS NOT NULL THEN
      pc_escreve_xml('         Percentual: '||to_char(pr_xmldata.vlpercen,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
		
		-- Se tem Valor Principal
    IF TRIM(pr_xmldata.vlprinci) IS NOT NULL THEN
      pc_escreve_xml(' Valor do Principal: '||to_char(pr_xmldata.vlprinci,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
		
		-- Se tem Valor Multa
    IF TRIM(pr_xmldata.vlrmulta) IS NOT NULL THEN
      pc_escreve_xml('     Valor da Multa: '||to_char(pr_xmldata.vlrmulta,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
		
		-- Se tem Valor Juros
    IF TRIM(pr_xmldata.vlrjuros) IS NOT NULL THEN
      pc_escreve_xml('    Valor dos Juros: '||to_char(pr_xmldata.vlrjuros,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
		
	IF  pr_xmldata.tpcaptur = 2 THEN --MANUAL
		-- Se tem Valor Total
	    IF TRIM(pr_xmldata.vltotfat) IS NOT NULL THEN
	      pc_escreve_xml('        Valor Total: '||to_char(pr_xmldata.vltotfat,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
	      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
	    END IF;
	END IF;
    
	-- Se tem Descricao
	IF TRIM(pr_xmldata.dsidepag) IS NOT NULL THEN
		pc_escreve_xml(' Descricao do Pagto: '||pr_xmldata.dsidepag,vr_nrdlinha);
		vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
	END IF;
  
  IF pr_xmldata.cdtippro IN(18,19) THEN -- Se for agendamento
    -- Se tem Data Pagamento
    IF TRIM(pr_xmldata.dtmvtdrf) IS NOT NULL THEN
      pc_escreve_xml('     Data Transação: '||to_char(pr_xmldata.dtmvtdrf,'dd/mm/yy') ,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    
    -- Se tem Hora Pagamento
    IF TRIM(pr_xmldata.hrautdrf) IS NOT NULL THEN
      pc_escreve_xml('     Hora Transação: '|| pr_xmldata.hrautdrf ,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha      		
    END IF;
  ELSE
    -- Se tem Data Pagamento
    IF TRIM(pr_xmldata.dtmvtdrf) IS NOT NULL THEN
      pc_escreve_xml('     Data Pagamento: '||to_char(pr_xmldata.dtmvtdrf,'dd/mm/yy') ,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    
    -- Se tem Hora Pagamento
    IF TRIM(pr_xmldata.hrautdrf) IS NOT NULL THEN
      pc_escreve_xml('     Hora Pagamento: '|| pr_xmldata.hrautdrf ,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha      		
    END IF;
  END IF;
		            
    -- Imprimir documento e sequencia de autenticação
    pc_escreve_xml('      Nr. Documento: '||pr_xmldata.nrdocmto,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
        
    pc_escreve_xml('  Seq. Autenticacao: '||pr_xmldata.nrseqaut,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
		
		-- Protocolo
		pc_escreve_xml('          Protocolo: '||pr_xmldata.dsprotoc,vr_nrdlinha);
		vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    -- Se vai escrever a linha 20... ou mais
    IF vr_nrdlinha >= 20 THEN
      pc_escreve_xml('--------------------------------------------------------------------------------',vr_nrdlinha);
    ELSE 
      pc_escreve_xml('--------------------------------------------------------------------------------',20);
    END IF;

  END pc_impressao_darf_das;   
  
  -- Rotina para impressão de FGTS/DAE
  PROCEDURE pc_impressao_fgts_dae(pr_xmldata  IN typ_xmldata
                                 ,pr_nmrescop IN VARCHAR2
                                 ,pr_cdbcoctl IN NUMBER
                                 ,pr_cdagectl IN NUMBER) IS
    -- ..........................................................................
    --
    --  Programa : 
    --  Sistema  : Rotinas para impressão de dados
    --  Sigla    : VERPRO
    --  Autor    : 
    --  Data     : Janeiro/2018.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Agrupa os dados e monta o layout para impressão de dados de pagamentos de FGTS/DAE
    --
    --   Alteracoes:
    --
    -- .............................................................................
    
    -- Variáveis
    vr_nrdlinha     NUMBER := 0;  
    vr_dsbanco      VARCHAR2(50);
		vr_dsdcabec     VARCHAR2(50);
		                          
  BEGIN
		
	  IF    pr_xmldata.cdtippro = 24 THEN
			vr_dsdcabec := 'Pagamento FGTS';
		ELSIF pr_xmldata.cdtippro = 23 THEN
			vr_dsdcabec := 'Pagamento DAE';
		END IF;

    -- IMPRIMIR O CABEÇALHO
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,1);
    pc_escreve_xml('     '||pr_nmrescop||' - Comprovante '|| vr_dsdcabec || ' - '||
                   'Emissao: '||to_char(SYSDATE,'DD/MM/YY')||' as '||to_char(SYSDATE,'HH24:MI:SS')||' Hr',2); 
    pc_escreve_xml('               Banco: '||to_char(pr_cdbcoctl) ,4);
    pc_escreve_xml('             Agencia: '||to_char(pr_cdagectl) ,5);
    pc_escreve_xml('            Conta/DV: '||to_char(pr_xmldata.nrdconta)||' - '||pr_xmldata.nmprimtl,6);
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,7);
    -- IMPRIMIR O CONTEÚDO
    -- Contador de linha - Iniciando na sexta linha do XML
    vr_nrdlinha := 8;
		
		-- Se tem Preposto
    IF TRIM(pr_xmldata.nmprepos) IS NOT NULL THEN
      pc_escreve_xml('            Preposto: '||pr_xmldata.nmprepos,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
    
    -- Se tem Tipo de Docmto		
		IF TRIM(pr_xmldata.tpdocmto) IS NOT NULL THEN
      pc_escreve_xml('   Tipo de Documento: '||pr_xmldata.tpdocmto,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
		
		-- Se tem Agente arrecadador
		IF TRIM(pr_xmldata.dsagtare) IS NOT NULL THEN
      pc_escreve_xml('  Agente Arrecadador: '||pr_xmldata.dsagtare,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
		
		-- Se tem informação de código de barras
    IF TRIM(pr_xmldata.cdbarras) IS NOT NULL THEN
      pc_escreve_xml('    Codigo de Barras: '||pr_xmldata.cdbarras,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
		
    -- Se tem informação de linha digitável
    IF  TRIM(pr_xmldata.lndigita) IS NOT NULL THEN
      pc_escreve_xml('     Linha Digitavel: '||pr_xmldata.lndigita,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha    
	  END IF;
    
    -- Se tem documento pessoa
    IF TRIM(pr_xmldata.cdcompet) IS NOT NULL THEN
      -- Modelo 01
      IF pr_xmldata.cdconven IN(179,180,181) THEN
        pc_escreve_xml('CNPJ/CEI Empresa/CPF: '||pr_xmldata.nrdocpes,vr_nrdlinha);
        vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
      -- Modelo 02
      ELSIF pr_xmldata.cdconven IN(178,240) THEN
        pc_escreve_xml('    CNPJ/CEI Empresa: '||pr_xmldata.nrdocpes,vr_nrdlinha);
        vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
      END IF;
    END IF;
    
    IF TRIM(pr_xmldata.cdtippro) IS NOT NULL THEN
      -- FGTS
      IF pr_xmldata.cdtippro = 24 THEN
        -- Se tem Convênio
        IF TRIM(pr_xmldata.cdconven) IS NOT NULL THEN
          pc_escreve_xml('       Cod. Convênio: '||pr_xmldata.cdconven,vr_nrdlinha);
          vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
        END IF;
        -- Se tem Data da Validade
        IF TRIM(pr_xmldata.dtvalida) IS NOT NULL THEN
          pc_escreve_xml('    Data da Validade: '||to_char(pr_xmldata.dtvalida,'dd/mm/yy'),vr_nrdlinha);
          vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
        END IF;
        -- Modelos 01 e 02
        IF pr_xmldata.cdconven IN(179,180,181,178,240) THEN
          -- Se tem Competência
          IF TRIM(pr_xmldata.cdcompet) IS NOT NULL THEN
            pc_escreve_xml('         Competência: '||pr_xmldata.cdcompet,vr_nrdlinha);
            vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
          END IF;
        -- Modelo 03
        ELSIF pr_xmldata.cdconven IN(239,451) THEN
          -- Se tem Identificador
          IF TRIM(pr_xmldata.cdidenti) IS NOT NULL THEN
            pc_escreve_xml('       Identificador: '||pr_xmldata.cdidenti,vr_nrdlinha);
            vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
          END IF;
        END IF;
      -- DAE
      ELSIF pr_xmldata.cdtippro = 23 THEN
        -- Se tem Nr. Docmto. (DAE)
        IF TRIM(pr_xmldata.nrdocmto_dae) IS NOT NULL THEN
          pc_escreve_xml('   Nr. Docmto. (DAE): '||pr_xmldata.nrdocmto_dae,vr_nrdlinha);
          vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
        END IF;
      END IF;
    END IF;
  		
    -- Se tem informação de valor total
    IF TRIM(pr_xmldata.vltotfat) IS NOT NULL THEN
      pc_escreve_xml('         Valor Total: '||to_char(pr_xmldata.vltotfat,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha    
    END IF;
		
		-- Se tem Descricao
    IF TRIM(pr_xmldata.dsidepag) IS NOT NULL THEN
      pc_escreve_xml('  Descricao do Pagto: '||pr_xmldata.dsidepag,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
  
    -- Se tem Data Pagamento
    IF TRIM(pr_xmldata.dtmvtdrf) IS NOT NULL THEN
      pc_escreve_xml('      Data Pagamento: '||to_char(pr_xmldata.dtmvtdrf,'dd/mm/yy') ,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;

    -- Se tem Hora Pagamento
    IF TRIM(pr_xmldata.hrautdrf) IS NOT NULL THEN
      pc_escreve_xml('      Hora Pagamento: '|| pr_xmldata.hrautdrf ,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha      		
    END IF;
		            
    -- Imprimir documento e sequencia de autenticação
    pc_escreve_xml('       Nr. Documento: '||pr_xmldata.nrdocmto,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
        
    pc_escreve_xml('   Seq. Autenticacao: '||pr_xmldata.nrseqaut,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
		
		-- Protocolo
		pc_escreve_xml('           Protocolo: '||pr_xmldata.dsprotoc,vr_nrdlinha);
		vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    -- Se vai escrever a linha 20... ou mais
    IF vr_nrdlinha >= 20 THEN
      pc_escreve_xml('--------------------------------------------------------------------------------',vr_nrdlinha);
    ELSE 
      pc_escreve_xml('--------------------------------------------------------------------------------',20);
    END IF;

  END pc_impressao_fgts_dae;
  
  /* Emissao de comprovante de GPS */
  PROCEDURE pc_impressao_gps(pr_xmldata  IN typ_xmldata
                            ,pr_nmrescop IN VARCHAR2
                            ,pr_cdbcoctl IN NUMBER
                            ,pr_cdagectl IN NUMBER) IS
    -- ..........................................................................
    --
    --  Programa : 
    --  Sistema  : Rotinas para impressão de dados
    --  Sigla    : VERPRO
    --  Autor    : 
    --  Data     : Agosto/2018.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Agrupa os dados e monta o layout para impressão de dados de pagamentos de GPS
    --
    --   Alteracoes:
    --
    -- .............................................................................
    
    -- Variáveis
    vr_nrdlinha       NUMBER := 0;  
    rw_dadosgps       GENE0002.typ_split;
    vr_nrddadogps     NUMBER := 0;  
    vr_nrdcollabel    NUMBER := 31; -- Para manter os títulos alinhados no centro    
    rw_campogps       GENE0002.typ_split;
    
  BEGIN
    -- Imprime o cabeçalho
    pc_escreve_xml(LPAD('',80, '-'), 1);
    pc_escreve_xml('     '||pr_nmrescop||' - Comprovante de Pagamento GPS '||' - '||
                   'Emissao: '||to_char(SYSDATE,'DD/MM/YY')||' as '||to_char(SYSDATE,'HH24:MI:SS')||' Hr',2); 
    pc_escreve_xml(LPAD('Banco: ',vr_nrdcollabel)||to_char(pr_cdbcoctl) ,4);
    pc_escreve_xml(LPAD('Agencia: ',vr_nrdcollabel)||to_char(pr_cdagectl) ,5);
    pc_escreve_xml(LPAD('Conta/DV: ',vr_nrdcollabel)||to_char(pr_xmldata.nrdconta)||' - '||pr_xmldata.nmprimtl,6);
    vr_nrdlinha := 7;
    
    -- Imprime o preposto se estiver informado
    IF TRIM(pr_xmldata.nmprepos) IS NOT NULL THEN
      pc_escreve_xml(LPAD('Preposto: ',vr_nrdcollabel)||pr_xmldata.nmprepos,vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    END IF;
    
    -- Imprime a data do movimento
    pc_escreve_xml(LPAD('Data Movimento: ',vr_nrdcollabel)||to_char(pr_xmldata.dtmvtolx,'dd/mm/yy'), vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime o valor do pagamento
    pc_escreve_xml(LPAD('Valor: ',vr_nrdcollabel)||to_char(pr_xmldata.valor,'FM9G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    pc_escreve_xml(LPAD('',80, '-'), vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
 
    -- Imprime os dados da GPS
    rw_dadosgps := GENE0002.fn_quebra_string(pr_string => pr_xmldata.dslinha3, pr_delimit => '#');
    
    IF rw_dadosgps.COUNT > 0 THEN
      FOR vr_nrddadogps IN 1..rw_dadosgps.COUNT LOOP
        -- Verifica se linha de campos está formatada com "campo : valor"
        IF INSTR(rw_dadosgps(vr_nrddadogps),':') > 0 THEN 
          -- Separa campo do valor
          rw_campogps := GENE0002.fn_quebra_string(pr_string => rw_dadosgps(vr_nrddadogps),pr_delimit => ':');
          IF rw_campogps.COUNT > 1 THEN
            -- Apresenta o campo somente se valor não for vazio
            IF LENGTH(TRIM(rw_campogps(2))) > 0 THEN
              pc_escreve_xml(LPAD(rw_campogps(1),vr_nrdcollabel-2)||': '||rw_campogps(2),vr_nrdlinha);
              vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
            END IF;
          END IF;
        ELSE  
          -- Se não for "campo : valor" apresenta linha toda
          pc_escreve_xml(rw_dadosgps(vr_nrddadogps), vr_nrdlinha);
          vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
        END IF;
      END LOOP; 
    END IF;
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    -- Imprime a data de transação
    pc_escreve_xml(LPAD('Data Transacao: ',vr_nrdcollabel)||to_char(pr_xmldata.dttransa,'dd/mm/yy'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime a hora da transação
    pc_escreve_xml(LPAD('Hora: ',vr_nrdcollabel)||to_char(to_date(pr_xmldata.hrautent,'SSSSS'),'hh24:mi:ss'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprimir o número do Documento
    pc_escreve_xml(LPAD('Nr. Documento: ',vr_nrdcollabel)||pr_xmldata.nrdocmto,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime a sequencia de autenticação
    pc_escreve_xml(LPAD('Seq. Autenticacao: ',vr_nrdcollabel)||pr_xmldata.nrseqaut,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime o protocolo
    pc_escreve_xml(LPAD('Protocolo: ',vr_nrdcollabel)||pr_xmldata.dsprotoc,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
		
		-- Imprime linha de rodapé
    pc_escreve_xml(LPAD('',80, '-'), vr_nrdlinha);
    
  END pc_impressao_gps;
  
  -- Rotina para impressão de comprovante de pagamento do deb automatico
  PROCEDURE pc_impressao_debaut(pr_xmldata  IN typ_xmldata
                               ,pr_nmrescop IN VARCHAR2) IS
    -- ..........................................................................
    --
    --  Programa : impressao_debaut 
    --  Sistema  : Rotinas para impressão de dados
    --  Sigla    : VERPRO
    --  Autor    : Aline Baramarchi
    --  Data     : Março/2017.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Agrupa os dados e monta o layout para impressão de 
    --               comprovante de pagamentos em débito automático
    --
    --   Alteracoes: 
    --
    -- .............................................................................
    
    -- Variáveis
    vr_nrdlinha     NUMBER := 0;  
                          
  BEGIN

    -- IMPRIMIR O CABEÇALHO
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,1);
    pc_escreve_xml('     '||pr_nmrescop||' - Comprovante Pag Deb Aut - '||
                   'Emissao: '||to_char(SYSDATE,'DD/MM/YY')||' as '||to_char(SYSDATE,'HH24:MI:SS')||' Hr',2); 
    pc_escreve_xml('           Conta/DV: '||to_char(pr_xmldata.nrdconta)||' - '||pr_xmldata.nmprimtl     ,4);
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,5);
    -- IMPRIMIR O CONTEÚDO
    -- Contador de linha - Iniciando na sexta linha do XML
    vr_nrdlinha := 6;

    
    -- Imprime o nome do convenio
    pc_escreve_xml('           Convenio: '||pr_xmldata.nmconven,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    -- Imprime o numero identificador 
    pc_escreve_xml('  Nro Identificador: '||pr_xmldata.nrdocmto,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    -- Imprime a data de transação
    pc_escreve_xml('     Data Transacao: '||to_char(pr_xmldata.dttransa,'dd/mm/yy'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime a hora da transação
    pc_escreve_xml('               Hora: '||to_char(to_date(pr_xmldata.hrautent,'SSSSS'),'hh24:mi:ss'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime a data da transferencia
    pc_escreve_xml('      Dt. Pagamento: '||to_char(pr_xmldata.dtmvtolx,'dd/mm/yy'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime o valor
    pc_escreve_xml('              Valor: '||to_char(pr_xmldata.valor,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime protocolo
    pc_escreve_xml('          Protocolo: '||pr_xmldata.dsprotoc,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    -- Imprimir documento e sequencia de autenticação
    pc_escreve_xml('      Nr. Documento: '||pr_xmldata.nrdocmto,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
        
    pc_escreve_xml('  Seq. Autenticacao: '||pr_xmldata.nrseqaut,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    
    pc_escreve_xml('--------------------------------------------------------------------------------',18);
    

  END pc_impressao_debaut; 

  
  
	-- Imprimir protocolo recarga de celular
  PROCEDURE pc_impressao_rec_cel(pr_xmldata  IN typ_xmldata
                                ,pr_nmrescop IN VARCHAR2) IS
    -- ..........................................................................
    --
    --  Programa : pc_impressao_rec_cel
    --  Sistema  : Rotinas para impressão de dados
    --  Sigla    : VERPRO
    --  Autor    : Lucas Reinert
    --  Data     : Março/2017.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    -- 	
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Agrupa os dados e monta o layout para impressão do protocolo de
		--               recarga de celular
    --
    --   Alteracoes: 
    --
    -- .............................................................................
          
    -- Variáveis
    vr_nrdlinha     NUMBER := 0;  
		                
  BEGIN

    -- IMPRIMIR OS DADOS DE PACOTE DE TARIFAS
    pc_escreve_xml('--------------------------------------------------------------------------------'        ,1);
    pc_escreve_xml('    '||RPAD(pr_nmrescop,14,' ')||' - Recarga de celular - '||
		               'Emissao: '||to_char(SYSDATE,'DD/MM/YYYY')||' as '||to_char(SYSDATE,'HH24:MI:SS')||' Hr',2); 
    pc_escreve_xml('          Conta/DV: '||gene0002.fn_mask_conta(pr_xmldata.nrdconta)||' - '||pr_xmldata.nmprimtl          ,4);	
    pc_escreve_xml('--------------------------------------------------------------------------------'        ,5);
		
    -- Contador de linha - Iniciando na sexta linha do XML
    vr_nrdlinha := 6;
		
    -- Valor
		pc_escreve_xml('              Valor: '||to_char(pr_xmldata.vlrecarga, 'FM999g990d00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
		vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
		
    -- Operadora
    pc_escreve_xml('          Operadora: '||pr_xmldata.nmoperadora,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- DDD/Telefone
    pc_escreve_xml('       DDD/Telefone: '||pr_xmldata.nrtelefo,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Data/Hora Recarga
    pc_escreve_xml('  Data/Hora Recarga: '||to_char(pr_xmldata.dtrecarga, 'DD/MM/RRRR') || ' - ' || pr_xmldata.hrrecarga,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Data do Lançamento
    pc_escreve_xml(' Data do Lançamento: '||to_char(pr_xmldata.dtdebito, 'DD/MM/RRRR'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
		
    -- NSU Operadora
    pc_escreve_xml('      NSU Operadora: '||pr_xmldata.nsuopera,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime o protocolo
    pc_escreve_xml('          Protocolo: '||pr_xmldata.dsprotoc,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
		
		-- Imprime linha de rodapé
    pc_escreve_xml('--------------------------------------------------------------------------------'        ,vr_nrdlinha);

  END pc_impressao_rec_cel;
  
  PROCEDURE pc_impressao_bordero(pr_xmldata  IN typ_xmldata
                                 ,pr_nmrescop IN VARCHAR2
                                 ,pr_cdbcoctl IN NUMBER
                                 ,pr_cdagectl IN NUMBER) IS
    -- ..........................................................................
    --
    --  Programa : 
    --  Sistema  : Rotinas para impressão de dados
    --  Sigla    : VERPRO
    --  Autor    : 
    --  Data     : Outubro/2018.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Agrupa os dados e monta o layout para impressão de dados de pagamentos de Bordero
    --
    --   Alteracoes:
    --
    -- .............................................................................
    
    -- Variáveis
    vr_nrdlinha     NUMBER := 0;  
    vr_dsbanco      VARCHAR2(50);
		vr_dsdcabec     VARCHAR2(50);
		                          
  BEGIN
    vr_dsdcabec := 'Bordero';
    -- IMPRIMIR O CABEÇALHO
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,1);
    pc_escreve_xml('     '||pr_nmrescop||' - Comprovante '|| vr_dsdcabec || ' - '||
                   'Emissao: '||to_char(SYSDATE,'DD/MM/YY')||' as '||to_char(SYSDATE,'HH24:MI:SS')||' Hr',2); 
    pc_escreve_xml('               Banco: '||to_char(pr_cdbcoctl) ,4);
    pc_escreve_xml('             Agencia: '||to_char(pr_cdagectl) ,5);
    pc_escreve_xml('            Conta/DV: '||to_char(pr_xmldata.nrdconta)||' - '||pr_xmldata.nmprimtl,6);
    pc_escreve_xml('--------------------------------------------------------------------------------'    ,7);
    -- IMPRIMIR O CONTEÚDO
    -- Contador de linha - Iniciando na sexta linha do XML
    vr_nrdlinha := 8;
		
    
    -- Imprime a data de transação
    pc_escreve_xml('     Data Transacao: '||to_char(pr_xmldata.dttransa,'dd/mm/yy') || ' as ' || to_char(to_date(pr_xmldata.hrautent,'SSSSS'),'hh24:mi:ss') ,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Se tem informação de valor total
    IF TRIM(pr_xmldata.valor) IS NOT NULL THEN
      pc_escreve_xml('         Valor Total: '||to_char(pr_xmldata.valor,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
      vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha    
    END IF;
		   
    -- Imprimir documento e sequencia de autenticação
    pc_escreve_xml('       Nr. Borderô: '||pr_xmldata.nrdocmto,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    pc_escreve_xml('       Qtd. Título: '||pr_xmldata.qttitbor,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
        
    pc_escreve_xml('   Seq. Autenticacao: '||pr_xmldata.nrseqaut,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
		
		-- Protocolo
		pc_escreve_xml('           Protocolo: '||pr_xmldata.dsprotoc,vr_nrdlinha);
		vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha
    
    -- Se vai escrever a linha 20... ou mais
    IF vr_nrdlinha >= 20 THEN
      pc_escreve_xml('--------------------------------------------------------------------------------',vr_nrdlinha);
    ELSE 
      pc_escreve_xml('--------------------------------------------------------------------------------',20);
    END IF;

  END pc_impressao_bordero;
  
  -- Inicio (Cássia de Oliveira - GFT)
  -- Imprimir ficha-proposta
  PROCEDURE pc_impressao_ficha_prop(pr_nrdconta IN crapass.nrdconta%TYPE        --> Numero da Conta
                                   ,pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS                --> Erros do processo
    BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_impressao_ficha_prop
    --  Sistema  : Rotinas para impressão de dados
    --  Autor    : Cássia de Oliveira - GFT
    --  Data     : Janeiro/2019.                   Ultima atualizacao: 18/06/2019
    --
    --  Dados referentes ao programa:
    -- 	
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Agrupa os dados e monta o layout para impressão de Ficha-Proposta
    --
    --   Alteracoes: 
    --               18/06/2019 - RITM0015775 - Mudança de nome de Ficha Proposta para Fica Matricula + Inclusao campo matricula
    -- .............................................................................
      DECLARE
      -- Variaveis padrao
      vr_cdcooper        PLS_INTEGER;
      vr_cdoperad        VARCHAR2(100);
      vr_nmdatela        VARCHAR2(100);
      vr_nmeacao         VARCHAR2(100);
      vr_cdagenci        VARCHAR2(100);
      vr_nrdcaixa        VARCHAR2(100);
      vr_idorigem        VARCHAR2(100);      
      vr_xml_temp        VARCHAR2(32726) := '';
      vr_xml             CLOB;
      vr_nom_direto      VARCHAR2(500);
      vr_nmarqimp        VARCHAR2(100);
      vr_dtmvtolt        DATE;
      vr_cotas           VARCHAR(1);
      vr_poupanca        VARCHAR(1);
      vr_aplicacao       VARCHAR(1);
      vr_cheque          VARCHAR(1);
      vr_internet        VARCHAR(1);
      rw_crapdat         btch0001.cr_crapdat%ROWTYPE; -- Informações de data
      vr_flservic        VARCHAR(100);
      vr_aux             INTEGER := 1;
      vr_fldebaut        VARCHAR(1) := 'N';
      vr_cod01           crapatr.cdrefere%TYPE;
      vr_conv01          craphis.dshistor%TYPE;
      vr_cod02           crapatr.cdrefere%TYPE;
      vr_conv02          craphis.dshistor%TYPE;
      vr_cod03           crapatr.cdrefere%TYPE;
      vr_conv03          craphis.dshistor%TYPE;

      
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      vr_des_reto      VARCHAR2(3);
      vr_typ_saida     VARCHAR2(3);
      
      vr_tab_erro      GENE0001.typ_tab_erro;

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    
      --Busca dados da conta
      CURSOR cr_crapass IS 
        SELECT ass.dtadmiss
              ,ass.cdcatego
              ,ass.nrmatric
              ,CASE ass.cdtipcta
                  WHEN 1  THEN 'NORMAL' 
                  WHEN 2  THEN 'ESPECIAL'
                  WHEN 3  THEN 'NORMAL CONJUNTA' 
                  WHEN 4  THEN 'ESPECIAL CONJUNTA'
                  WHEN 8  THEN 'NORMAL CONVENIO'
                  WHEN 9  THEN 'ESPECIAL CONVENIO'
                  WHEN 10 THEN 'CONJUNTA CONVENIO'
                  WHEN 11 THEN 'CONJUNTA ESPECIAL CONVENIO'
               END AS dstipcta
          FROM crapass ass
         WHERE ass.cdcooper = vr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
          
      --Busca dados Titular
      CURSOR cr_crapttl(pr_idseqttl IN crapttl.idseqttl%TYPE) IS 
        SELECT pes.nmpessoa
              ,pes.nrcpfcgc
              ,pfs.tpsexo
              ,nac.dsnacion
              ,pfs.dtnascimento
              ,translate(upper(mun.dscidesp),
                        'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜ',
                        'ACEIOUAEIOUAEIOUAOEU') AS dscidesp
              ,mun.cdestado
              ,pfs.nrdocumento AS nrdocmto
              ,pfs.dtemissao_documento
              ,oep.cdorgao_expedidor AS cdorgexp
              ,pfs.cduf_orgao_expedidor AS cduforge
              ,pfs.dsprofissao AS dsprofis
              ,emp.nmpessoa AS nmempres
              ,cvl.dsestcvl
              ,(SELECT coj.nmpessoa 
                  FROM tbcadast_pessoa coj 
            INNER JOIN tbcadast_pessoa_relacao rel 
                    ON rel.idpessoa_relacao = coj.idpessoa 
                 WHERE rel.idpessoa = pes.idpessoa 
                   AND rel.tprelacao = 1) AS nmconjug
              ,(SELECT coj.nmpessoa 
                  FROM tbcadast_pessoa coj 
            INNER JOIN tbcadast_pessoa_relacao rel 
                    ON rel.idpessoa_relacao = coj.idpessoa 
                 WHERE rel.idpessoa = pes.idpessoa 
                   AND rel.tprelacao = 4) AS nmfilmae
              ,(SELECT coj.nmpessoa 
                  FROM tbcadast_pessoa coj 
            INNER JOIN tbcadast_pessoa_relacao rel 
                    ON rel.idpessoa_relacao = coj.idpessoa 
                 WHERE rel.idpessoa = pes.idpessoa 
                   AND rel.tprelacao = 3) AS nmfilpai
          FROM crapttl ttl, tbcadast_pessoa pes
    INNER JOIN tbcadast_pessoa_fisica pfs
            ON pfs.idpessoa = pes.idpessoa
     LEFT JOIN crapnac nac
            ON nac.cdnacion = pfs.cdnacionalidade
     LEFT JOIN crapmun mun
            ON mun.idcidade = pfs.cdnaturalidade
     LEFT JOIN tbgen_orgao_expedidor oep
            ON oep.idorgao_expedidor = pfs.idorgao_expedidor
     LEFT JOIN tbcadast_pessoa_renda ren
            ON ren.idpessoa = pes.idpessoa
     LEFT JOIN tbcadast_pessoa emp
            ON emp.idpessoa = ren.idpessoa_fonte_renda
     LEFT JOIN gnetcvl cvl
            ON cvl.cdestcvl = pfs.cdestado_civil
         WHERE ttl.cdcooper = vr_cdcooper
           AND ttl.nrdconta = pr_nrdconta
           AND ttl.idseqttl = pr_idseqttl
           AND pes.nrcpfcgc = ttl.nrcpfcgc;
      rw_primttl cr_crapttl%ROWTYPE;
      rw_seguttl cr_crapttl%ROWTYPE;
      
      --Busca endereço
      CURSOR cr_crapenc(pr_idseqttl IN crapttl.idseqttl%TYPE) IS
        SELECT enc.dsendere
              ,enc.nrendere
              ,enc.complend
              ,enc.nmbairro
              ,enc.nrcepend
              ,enc.nmcidade
              ,enc.cdufende
          FROM crapenc enc
         WHERE enc.nrdconta = pr_nrdconta
           AND enc.cdcooper = vr_cdcooper
           AND enc.idseqttl = pr_idseqttl
           AND ROWNUM = 1
      ORDER BY enc.cdseqinc;
      rw_primenc cr_crapenc%ROWTYPE;
      rw_seguenc cr_crapenc%ROWTYPE;
      
      --Busca telefone
      CURSOR cr_craptfc(pr_idseqttl IN crapttl.idseqttl%TYPE) IS
        SELECT tfc.nrdddtfc
              ,tfc.nrtelefo
          FROM craptfc tfc
         WHERE tfc.nrdconta = pr_nrdconta
           AND tfc.cdcooper = vr_cdcooper
           AND tfc.idseqttl = pr_idseqttl
      ORDER BY tfc.tptelefo;
      rw_primtfc cr_craptfc%ROWTYPE; 
      rw_segutfc cr_craptfc%ROWTYPE;   
      
      --Busca plano de cotas
      CURSOR cr_crappla IS
        SELECT (1) 
          FROM crappla 
         WHERE cdcooper = vr_cdcooper 
           AND nrdconta = pr_nrdconta 
           AND dtcancel IS NULL;
      rw_crappla cr_crappla%ROWTYPE;
      
      --Busca Poupança Programada
      CURSOR cr_craprpp IS
        SELECT (1) 
          FROM craprpp 
         WHERE cdcooper = vr_cdcooper 
           AND nrdconta = pr_nrdconta 
           AND cdsitrpp = 1;
      rw_craprpp cr_craprpp%ROWTYPE;
             
      --Busca Aplicação 
      CURSOR cr_craprda IS 
        SELECT (1) 
          FROM craprda 
         WHERE cdcooper = vr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_craprda cr_craprda%ROWTYPE;
           
      --Busca Cheque Especial
      CURSOR cr_craplim IS
        SELECT (1) 
          FROM craplim 
         WHERE cdcooper = vr_cdcooper 
           AND nrdconta = pr_nrdconta 
           AND insitlim = 2;
           rw_craplim cr_craplim%ROWTYPE;
           
      --Busca Cartão
      CURSOR cr_crawcrd IS
        SELECT CASE crd.tpcartao  
                  WHEN 1 THEN 'NACIONAL' 
                  WHEN 2 THEN 'INTERNACIONAL'
                  WHEN 3 THEN 'GOLD'  
               END AS tpcartao
              ,crd.tpdpagto
              ,crd.nmtitcrd
              ,crd.dddebito
              ,adc.nmbandei
          FROM crawcrd crd 
    INNER JOIN crapass ass 
            ON ass.cdcooper = crd.cdcooper
           AND ass.nrdconta = crd.nrdconta
           AND ass.nrcpfcgc = crd.nrcpftit 
     LEFT JOIN crapadc adc
            ON adc.cdadmcrd = crd.cdadmcrd
           AND adc.cdcooper = crd.cdcooper
         WHERE crd.cdcooper = vr_cdcooper
           AND crd.nrdconta = pr_nrdconta
           AND crd.insitcrd IN (1,3,4)
           AND ROWNUM = 1;     
      rw_crawcrd cr_crawcrd%ROWTYPE;
      
      --Busca convenio
      CURSOR cr_crapatr IS
        SELECT atr.cdrefere
              ,his.dshistor 
          FROM crapatr atr 
     LEFT JOIN craphis his 
            ON his.cdhistor = atr.cdhistor 
            AND his.cdcooper = atr.cdcooper 
          WHERE atr.cdcooper = vr_cdcooper 
            AND atr.nrdconta = pr_nrdconta
            AND atr.dtinsexc IS NULL
            AND ROWNUM <= 3;
      rw_crapatr cr_crapatr%ROWTYPE;
      
      --Busca Internet
      CURSOR cr_crapsnh IS
        SELECT (1) 
          FROM crapsnh 
         WHERE cdcooper = vr_cdcooper 
           AND nrdconta = pr_nrdconta 
           AND tpdsenha = 1 
           AND cdsitsnh IN (1,2);
      rw_crapsnh cr_crapsnh%ROWTYPE;
           
      --Busca Pacote de Serviço
      CURSOR cr_tbtarif_contas_pacote IS
        SELECT cdpacote 
          FROM tbtarif_contas_pacote 
         WHERE cdcooper = vr_cdcooper 
           AND nrdconta = pr_nrdconta 
           AND flgsituacao = 1;
      rw_tbtarif_contas_pacote cr_tbtarif_contas_pacote%ROWTYPE;
      
      --Busca Local
      CURSOR cr_crapage IS
        SELECT nmcidade
              ,cdufdcop 
          FROM crapage 
         WHERE cdcooper = vr_cdcooper 
           AND cdagenci = vr_cdagenci;
      rw_crapage cr_crapage%ROWTYPE;
      
      --Busca Representante Legal
      CURSOR cr_crapcrl IS
        SELECT nmrespon 
          FROM crapcrl 
         WHERE cdcooper = vr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapcrl cr_crapcrl%ROWTYPE;
    BEGIN
         
      -- extrair informações padrão do xml - parametros
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml 
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao 
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => pr_dscritic);
                              
      -- Busca a data de execução
      OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar dados
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        CLOSE BTCH0001.cr_crapdat;
        pr_des_erro := 'Data do sistema nao encontrada. PR_CDCOOPER = '||vr_cdcooper;
        RAISE vr_exc_erro;
      END IF;
      CLOSE BTCH0001.cr_crapdat; 
      --Busca dados associado                  
      OPEN cr_crapass;
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_dscritic := 'Associado nao encontrado.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapass;
      END IF;
      --Busca dados Pessoais Primeiro titular
      OPEN cr_crapttl(pr_idseqttl => 1);
      FETCH cr_crapttl INTO rw_primttl;
      CLOSE cr_crapttl;
      --Busca endereço Primeiro titular
      OPEN cr_crapenc(pr_idseqttl => 1);
      FETCH cr_crapenc INTO rw_primenc;
      CLOSE cr_crapenc;
      --Busca telefone Primeiro titular
      OPEN cr_craptfc(pr_idseqttl => 1);
      FETCH cr_craptfc INTO rw_primtfc;
      CLOSE cr_craptfc;
      --Busca dados Pessoais Segundo titular
      OPEN cr_crapttl(pr_idseqttl => 2);
      FETCH cr_crapttl INTO rw_seguttl;
      CLOSE cr_crapttl;
      --Busca endereço Segundo titular
      OPEN cr_crapenc(2);
      FETCH cr_crapenc INTO rw_seguenc;
      CLOSE cr_crapenc;
      --Busca telefone Segundo titular
      OPEN cr_craptfc(pr_idseqttl => 2);
      FETCH cr_craptfc INTO rw_segutfc;
      CLOSE cr_craptfc;
      --Busca plano de cotas
      OPEN cr_crappla;
      FETCH cr_crappla INTO rw_crappla;
      IF cr_crappla%NOTFOUND THEN
        vr_cotas := 'N';
      ELSE
        vr_cotas := 'S';
      END IF;
      CLOSE cr_crappla;
      --Busca Poupança Programada
      OPEN cr_craprpp;
      FETCH cr_craprpp INTO rw_craprpp;
      IF cr_craprpp%NOTFOUND THEN
        vr_poupanca := 'N';
      ELSE
        vr_poupanca := 'S';
      END IF;
      CLOSE cr_craprpp;
      --Busca Aplicação
      OPEN cr_craprda;
      FETCH cr_craprda INTO rw_craprda;
      IF cr_craprda%NOTFOUND THEN
        vr_aplicacao := 'N';
      ELSE
        vr_aplicacao := 'S';
      END IF;
      CLOSE cr_craprda;
      --Busca Cheque Especial
      OPEN cr_craplim;
      FETCH cr_craplim INTO rw_craplim;
      IF cr_craplim%NOTFOUND THEN
        vr_cheque := 'N';
      ELSE
        vr_cheque := 'S';
      END IF;
      CLOSE cr_craplim;
      --Busca Cratão
      OPEN cr_crawcrd;
      FETCH cr_crawcrd INTO rw_crawcrd;
      CLOSE cr_crawcrd;
      --Busca convenio
      FOR rw_crapatr IN cr_crapatr LOOP
        IF vr_aux = 1 THEN
          vr_fldebaut := 'S';
          vr_cod01 := rw_crapatr.cdrefere;
          vr_conv01 := rw_crapatr.dshistor;
        ELSIF vr_aux = 2 THEN
          vr_cod02 := rw_crapatr.cdrefere;
          vr_conv02 := rw_crapatr.dshistor;
        ELSE 
          vr_cod03 := rw_crapatr.cdrefere;
          vr_conv03 := rw_crapatr.dshistor;
        END IF;
        vr_aux := vr_aux + 1;
      END LOOP;
      --Busca internet
      OPEN cr_crapsnh;
      FETCH cr_crapsnh INTO rw_crapsnh;
      IF cr_crapsnh%NOTFOUND THEN
        vr_internet := 'N';
      ELSE
        vr_internet := 'S';
      END IF;
      CLOSE cr_crapsnh;
      --Busca Pacote de Serviço
      OPEN cr_tbtarif_contas_pacote;
      FETCH cr_tbtarif_contas_pacote INTO rw_tbtarif_contas_pacote;
      IF cr_tbtarif_contas_pacote%NOTFOUND THEN
        vr_flservic := 'N';
      ELSE
        vr_flservic := TO_CHAR(rw_tbtarif_contas_pacote.cdpacote);
      END IF;
      CLOSE cr_tbtarif_contas_pacote;
      --Busca local
      OPEN cr_crapage;
      FETCH cr_crapage INTO rw_crapage;
      CLOSE cr_crapage;
      --Busca Representante Legal
      OPEN cr_crapcrl;
      FETCH cr_crapcrl INTO rw_crapcrl;
      CLOSE cr_crapcrl;
      vr_dscritic := rw_crapcrl.nmrespon;
      -- Monta documento XML
      dbms_lob.createtemporary(vr_xml, TRUE);
      dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_xml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Relatorio>"
                                                      <Dados>
                                                        <nrdconta>'||pr_nrdconta        ||'</nrdconta>
                                                        <nrmatric>'||rw_crapass.nrmatric||'</nrmatric>
                                                        <dtabtcct>'||TO_CHAR(rw_crapass.dtadmiss,'DD/MM/YYYY')||'</dtabtcct>
                                                        <cdcatego>'||rw_crapass.cdcatego||'</cdcatego>
                                                        <dstipcta>'||rw_crapass.dstipcta||'</dstipcta>
                                                        <nmpessoa>'||rw_primttl.nmpessoa||'</nmpessoa>
                                                        <nrcpfcgc>'||gene0002.fn_mask_cpf_cnpj(rw_primttl.nrcpfcgc,1)||'</nrcpfcgc>
                                                        <cdsexotl>'||rw_primttl.tpsexo  ||'</cdsexotl>
                                                        <dsnacion>'||rw_primttl.dsnacion||'</dsnacion>
                                                        <dtnascmt>'||TO_CHAR(rw_primttl.dtnascimento,'DD/MM/YYYY')||'</dtnascmt>
                                                        <nrdocmto>'||rw_primttl.nrdocmto||'</nrdocmto>
                                                        <dtemdoct>'||TO_CHAR(rw_primttl.dtemissao_documento,'DD/MM/YYYY')||'</dtemdoct>
                                                        <cdorgexp>'||rw_primttl.cdorgexp||'</cdorgexp>
                                                        <cduforge>'||rw_primttl.cduforge||'</cduforge>
                                                        <dsprofis>'||rw_primttl.dsprofis||'</dsprofis>
                                                        <nmempres>'||rw_primttl.nmempres||'</nmempres>
                                                        <nmconjug>'||rw_primttl.nmconjug||'</nmconjug>
                                                        <nmfilmae>'||rw_primttl.nmfilmae||'</nmfilmae>
                                                        <nmfilpai>'||rw_primttl.nmfilpai||'</nmfilpai>
                                                        <dsnatura>'||rw_primttl.dscidesp||'</dsnatura>
                                                        <cdufnatu>'||rw_primttl.cdestado||'</cdufnatu>
                                                        <dsestcvl>'||rw_primttl.dsestcvl||'</dsestcvl>
                                                        <dsendere>'||rw_primenc.dsendere||'</dsendere>
                                                        <nrendere>'||rw_primenc.nrendere||'</nrendere>
                                                        <complend>'||rw_primenc.complend||'</complend>
                                                        <nmbairro>'||rw_primenc.nmbairro||'</nmbairro>
                                                        <nrcepend>'||rw_primenc.nrcepend||'</nrcepend>
                                                        <nmcidade>'||rw_primenc.nmcidade||'</nmcidade>
                                                        <cdufende>'||rw_primenc.cdufende||'</cdufende>
                                                        <nrdddtfc>'||rw_primtfc.nrdddtfc||'</nrdddtfc>
                                                        <nrtelefo>'||rw_primtfc.nrtelefo||'</nrtelefo>
                                                        <nmspesso>'||rw_seguttl.nmpessoa||'</nmspesso>
                                                        <nrscpfcg>'||gene0002.fn_mask_cpf_cnpj(rw_seguttl.nrcpfcgc,1)||'</nrscpfcg>
                                                        <cdssexot>'||rw_seguttl.tpsexo  ||'</cdssexot>
                                                        <dssnacio>'||rw_seguttl.dsnacion||'</dssnacio>
                                                        <dtsnascm>'||TO_CHAR(rw_seguttl.dtnascimento,'DD/MM/YYYY')||'</dtsnascm>
                                                        <nrsdocmt>'||rw_seguttl.nrdocmto||'</nrsdocmt>
                                                        <dtsemdoc>'||TO_CHAR(rw_seguttl.dtemissao_documento,'DD/MM/YYYY')||'</dtsemdoc>
                                                        <cdsorgex>'||rw_seguttl.cdorgexp||'</cdsorgex>
                                                        <cdsuforg>'||rw_seguttl.cduforge||'</cdsuforg>
                                                        <dssprofi>'||rw_seguttl.dsprofis||'</dssprofi>
                                                        <nmsempre>'||rw_seguttl.nmempres||'</nmsempre>
                                                        <nmsconju>'||rw_seguttl.nmconjug||'</nmsconju>
                                                        <nmsfilma>'||rw_seguttl.nmfilmae||'</nmsfilma>
                                                        <nmsfilpa>'||rw_seguttl.nmfilpai||'</nmsfilpa>
                                                        <dssnatur>'||rw_seguttl.dscidesp||'</dssnatur>
                                                        <cdsufnat>'||rw_seguttl.cdestado||'</cdsufnat>
                                                        <dssestcv>'||rw_seguttl.dsestcvl||'</dssestcv>
                                                        <dssender>'||rw_seguenc.dsendere||'</dssender>
                                                        <nrsender>'||rw_seguenc.nrendere||'</nrsender>
                                                        <cosmplen>'||rw_seguenc.complend||'</cosmplen>
                                                        <nmsbairr>'||rw_seguenc.nmbairro||'</nmsbairr>
                                                        <nrscepen>'||rw_seguenc.nrcepend||'</nrscepen>
                                                        <nmscidad>'||rw_seguenc.nmcidade||'</nmscidad>
                                                        <cdsufend>'||rw_seguenc.cdufende||'</cdsufend>
                                                        <nrsdddtf>'||rw_segutfc.nrdddtfc||'</nrsdddtf>
                                                        <nrstelef>'||rw_segutfc.nrtelefo||'</nrstelef>
                                                        <flpcotas>'||vr_cotas           ||'</flpcotas>
                                                        <flpoupan>'||vr_poupanca        ||'</flpoupan>
                                                        <flaplica>'||vr_aplicacao       ||'</flaplica>
                                                        <flcheque>'||vr_cheque          ||'</flcheque>
                                                        <tpcartao>'||rw_crawcrd.tpcartao||'</tpcartao>
                                                        <tpdpagto>'||rw_crawcrd.tpdpagto||'</tpdpagto>
                                                        <dddebito>'||rw_crawcrd.dddebito||'</dddebito>
                                                        <nmbandei>'||rw_crawcrd.nmbandei||'</nmbandei>
                                                        <fldebaut>'||vr_fldebaut        ||'</fldebaut>
                                                        <cdconve1>'||vr_cod01           ||'</cdconve1>
                                                        <dsconve1>'||vr_conv01          ||'</dsconve1>
                                                        <cdconve2>'||vr_cod02           ||'</cdconve2>
                                                        <dsconve2>'||vr_conv02          ||'</dsconve2>
                                                        <cdconve3>'||vr_cod03           ||'</cdconve3>
                                                        <dsconve3>'||vr_conv03          ||'</dsconve3>
                                                        <flintern>'||vr_internet        ||'</flintern>
                                                        <flservic>'||vr_flservic        ||'</flservic>
                                                        <nmcidcop>'||rw_crapage.nmcidade||'</nmcidcop>
                                                        <cdufdcop>'||rw_crapage.cdufdcop||'</cdufdcop>
                                                        <dtmvtolt>'||TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/YYYY')||'</dtmvtolt>
                                                        <nmrespon>'||rw_crapcrl.nmrespon||'</nmrespon>
                                                      </Dados>
                                                    </Relatorio>'
                             ,pr_fecha_xml      => TRUE);
                             
      -- Busca do diretório base da cooperativa para PDF
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => vr_cdcooper
                                            ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
      
      -- Definir nome do relatorio
      vr_nmarqimp := 'crrl773_' || TO_CHAR(SYSTIMESTAMP,'SSSSSFF5') || '.pdf';
      
      -- Solicitar geração do relatorio
      gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper --> Cooperativa conectada
                                 ,pr_cdprogra  => 'CONTAS' --> Programa chamador
                                 ,pr_dtmvtolt  => vr_dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_xml --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/Relatorio/Dados' --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl773.jasper' --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto || '/' ||vr_nmarqimp --> Arquivo final com o path
                                 ,pr_cdrelato  => 773
                                 ,pr_qtcoluna  => 132 --> 80 colunas
                                 ,pr_flg_gerar => 'S' --> Geraçao na hora
                                 ,pr_flg_impri => 'N' --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => ''  --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1   --> Número de cópias
                                 ,pr_sqcabrel  => 1   --> Qual a seq do cabrel
                                 ,pr_des_erro  => vr_dscritic); --> Saída com erro
      -- Tratar erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Enviar relatorio para intranet
      gene0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper --> Cooperativa conectada
                                  ,pr_cdagenci => vr_cdagenci --> Codigo da agencia para erros
                                  ,pr_nrdcaixa => vr_nrdcaixa --> Codigo do caixa para erros
                                  ,pr_nmarqpdf => vr_nom_direto || '/' ||vr_nmarqimp --> Arquivo PDF  a ser gerado
                                  ,pr_des_reto => vr_des_reto --> Saída com erro
                                  ,pr_tab_erro => vr_tab_erro); --> tabela de erros
      
      -- caso apresente erro na operação
      IF nvl(vr_des_reto, 'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;          
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Remover relatorio da pasta rl apos gerar
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm ' || vr_nom_direto || '/' ||vr_nmarqimp
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      -- Se retornou erro
      IF vr_typ_saida = 'ERR' OR vr_dscritic IS NOT NULL THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: ' || vr_dscritic;
        RAISE vr_exc_saida;
      END IF;

      -- Libera a memoria do CLOB
      dbms_lob.close(vr_xml);
      dbms_lob.freetemporary(vr_xml);
      
      -- Criar XML de retorno
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' ||vr_nmarqimp || '</nmarqpdf>');
      
      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CADA0002.pc_impressao_ficha_prop: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_impressao_ficha_prop;
  -- Fim (Cássia de Oliveira - GFT)
  
  -- TELA: VERPRO - Verificação de Protocolos
  PROCEDURE pc_verpro(pr_cdcooper IN NUMBER                --> Código da cooperativa
                     ,pr_idorigem IN NUMBER                --> ID da origem
                     ,pr_nrdconta IN NUMBER                --> Número da conta
                     ,pr_dataini  IN VARCHAR2              --> Data inicial
                     ,pr_datafin  IN VARCHAR2              --> Data final
                     ,pr_cdtippro IN NUMBER                --> Controle de paginação
                     ,pr_nrregist IN NUMBER                --> Número de registros
                     ,pr_nriniseq IN NUMBER                --> Número sequenciador
                     ,pr_tpdbusca IN NUMBER                --> Tipo da busca que será efetuada
                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                     ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    -- ..........................................................................
    --
    --  Programa : PC_VERPRO (Antigo /generico/procedures/b1wgen0122.p --> busca-dados | /generico/procedures/b1wgen0122.p --> busca-protocolos)
    --  Sistema  : Rotinas para cadastros Web
    --  Sigla    : VERPRO
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2013.                   Ultima atualizacao: 22/07/2014
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Buscar informações a respeito dos protocolos e dados para a tela VERPRO (Web).
    --
    --   Alteracoes: 29/05/2013 - Conversão Progress-Oracle. Petter - Supero
    --
    --               22/07/2014 - Migrar a procedure para a package CADA0002 e ajustar 
    --                            a mesma. ( Renato - Supero )
    --               03/01/2018 - Incluir tratamento para os tipos 24-FGTS e 23-DAE
    --
    --               24/05/2019 - Tratamento para TED Judicial - REQ040
    -- .............................................................................
    
    /* Busca dados de planos de capitalização */
    CURSOR cr_crappla(pr_nrctrpla  crappla.nrctrpla%TYPE     --> Número plano
                     ,pr_cdcooper  crappla.cdcooper%TYPE     --> Código da cooperativa
                     ,pr_nrdconta  crappla.nrdconta%TYPE) IS --> Número da conta
      SELECT ca.flgpagto
      FROM crappla ca
      WHERE ca.cdcooper = pr_cdcooper
        AND ca.nrdconta = pr_nrdconta
        AND ca.tpdplano = 1
        AND ca.nrctrpla = pr_nrctrpla;
    rw_crappla cr_crappla%ROWTYPE;
    
    -- Variáveis
    vr_dstransa    VARCHAR2(400);                 --> Descrição da transação
    vr_qttotreg    PLS_INTEGER;                   --> Quantidade de registros
    vr_dsinfor2    VARCHAR2(4000);                --> Descrição de informações
    vr_nrregist    PLS_INTEGER;                   --> Número do registro
    vr_cratpro     gene0006.typ_tab_protocolo;    --> PL Table para armazenar registros (retorno protocolo)
    vr_tab_dados   gene0007.typ_mult_array;       --> PL Table para armazenar dados para formar o XML
    vr_tab_dadin   gene0007.typ_mult_array;       --> PL Table para armazenar dados referentes a descrição para formar o XML
    vr_tab_tags    gene0007.typ_tab_tagxml;       --> PL Table para armazenar TAG´s do XML
    vr_tab_tagd    gene0007.typ_tab_tagxml;       --> PL Table para armazenar dados referentes a descrição para TAG´s do XML
    vr_qtregist    NUMBER;                        --> Quantidade de registros processados
		vr_tpcaptur    NUMBER;                        --> tipo de captura DARF/DAS
    vr_index       PLS_INTEGER;                   --> Indexador da PL Table
    vr_tagoco      PLS_INTEGER;                   --> Número de ocorrências do nodo XML
    vr_dataini     DATE;                          --> Data inicial
    vr_datafin     DATE;                          --> Data final
     
  BEGIN
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    -- Criar valores com o tipo DATE
    vr_dataini := to_date(pr_dataini, 'DD/MM/RRRR');
    vr_datafin := to_date(pr_datafin, 'DD/MM/RRRR');

    -- Verifica o tipo de busca que será realizada
    IF pr_tpdbusca = 1 THEN /* Busca dados */
      -- Inicializar variáveis
      -- vr_dstransa := 'Busca para Verificacao de Protocolos';
      pr_dscritic := '';
      pr_cdcritic := 0;
      pr_des_erro := 'NOK';

      IF pr_nrdconta >= 0 THEN
        -- Validar o digito da conta
        IF NOT gene0005.fn_valida_digito_verificador(pr_nrdconta => pr_nrdconta) THEN
          -- 008 - Digito errado.
          pr_cdcritic := 8;
          -- Sair do programa
          RETURN;
        END IF;

        -- Informações sobre o cooperado
        OPEN cr_crapass(pr_cdcooper, pr_nrdconta);
        FETCH cr_crapass INTO rw_crapass;

        -- Verifica se ocorreram erros e gera crítica
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          --009 - Associado nao cadastrado.
          pr_cdcritic := 9;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
          RETURN;
        ELSE
          CLOSE cr_crapass;
        END IF;

        -- Gera nodo com nome do associado
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                           ,'/Root'
                                           ,XMLTYPE('<Dados nmprimtl="' || rw_crapass.nmprimtl || '"></Dados>'));
      ELSE
        -- Gera nodo sem nome do associado
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                           ,'/Root'
                                           ,XMLTYPE('<Dados nmprimtl=" "></Dados>'));
      END IF;

      -- Finaliza com status de sucesso
      pr_des_erro := 'OK';
  
    ELSIF pr_tpdbusca = 2 THEN /* Busca protocolos */
      -- Inicializar variáveis
      -- vr_dstransa := 'Busca para Verificacao de Protocolos';
      pr_dscritic := '';
      pr_cdcritic := 0;
      pr_des_erro := 'NOK';

      -- Listar protocolos de segurança
      gene0006.pc_lista_protocolos(pr_cdcooper  => pr_cdcooper
                                  ,pr_nrdconta  => pr_nrdconta
                                  ,pr_dtinipro  => vr_dataini
                                  ,pr_dtfimpro  => vr_datafin
                                  ,pr_iniconta  => 0
                                  ,pr_nrregist  => 0
                                  ,pr_cdtippro  => pr_cdtippro
                                  ,pr_cdorigem  => 1
                                  ,pr_dstransa  => vr_dstransa
                                  ,pr_dscritic  => pr_dscritic
                                  ,pr_qttotreg  => vr_qttotreg
                                  ,pr_protocolo => vr_cratpro
                                  ,pr_des_erro  => pr_des_erro);

      -- Verifica se retornou erro
      IF pr_des_erro IS NOT NULL THEN
        pr_des_erro := 'Erro em PC_VERPRO:' || pr_des_erro;
        RAISE vr_exc_erro;
      END IF;

      -- Verifica se a quantidade de registro é zero
      IF nvl(vr_qttotreg, 0) = 0 THEN
        pr_des_erro := 'Protocolo(s) nao encontrado(s).';
        pr_cdcritic := 0;
        pr_dscritic := 'Protocolo(s) nao encontrado(s).';
        RAISE vr_exc_erro;
      END IF;

      -- Tratamento de paginação somente para web
      IF pr_idorigem = 5 THEN
        vr_nrregist := pr_nrregist;
      END IF;

      -- Copiando PL Table
      FOR vr_ind IN 1..vr_cratpro.count LOOP

        -- Origem da requisição
        IF pr_idorigem = 5 THEN
          vr_qtregist := nvl(vr_qtregist, 0) + 1;

          -- Controles da paginação
          IF (vr_qtregist < pr_nriniseq) OR (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
            CONTINUE;
          END IF;

          -- Controles da paginação
          IF (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
            CONTINUE;
          END IF;
        END IF;

        -- Captura último indice da PL Table
        vr_index := nvl(vr_tab_dados.count, 0) + 1;

        -- Gravando registros
        vr_tab_dados(vr_index)('cdtippro') := vr_cratpro(vr_ind).cdtippro;
        vr_tab_dados(vr_index)('dstippro') := vr_cratpro(vr_ind).dsinform##1;
        vr_tab_dados(vr_index)('dtmvtolt') := to_char(vr_cratpro(vr_ind).dtmvtolt, 'DD/MM/RRRR');
        vr_tab_dados(vr_index)('dttransa') := to_char(vr_cratpro(vr_ind).dttransa, 'DD/MM/RRRR');
        vr_tab_dados(vr_index)('hrautent') := vr_cratpro(vr_ind).hrautent;
        vr_tab_dados(vr_index)('hrautenx') := gene0002.fn_calc_hora(vr_cratpro(vr_ind).hrautent);
        vr_tab_dados(vr_index)('vldocmto') := vr_cratpro(vr_ind).vldocmto;
        vr_tab_dados(vr_index)('nrdocmto') := vr_cratpro(vr_ind).nrdocmto;
        vr_tab_dados(vr_index)('nrseqaut') := vr_cratpro(vr_ind).nrseqaut;
        vr_tab_dados(vr_index)('dsinform') := '';
        vr_tab_dados(vr_index)('dsprotoc') := vr_cratpro(vr_ind).dsprotoc;
        vr_tab_dados(vr_index)('dscedent') := vr_cratpro(vr_ind).dscedent;
        vr_tab_dados(vr_index)('flgagend') := vr_cratpro(vr_ind).flgagend;
        vr_tab_dados(vr_index)('nmprepos') := vr_cratpro(vr_ind).nmprepos;
        vr_tab_dados(vr_index)('nrcpfpre') := vr_cratpro(vr_ind).nrcpfpre;
        vr_tab_dados(vr_index)('nmoperad') := vr_cratpro(vr_ind).nmoperad;
        vr_tab_dados(vr_index)('nrcpfope') := vr_cratpro(vr_ind).nrcpfope;
        vr_tab_dadin(vr_index)('dsinform.1') := vr_cratpro(vr_ind).dsinform##1;
        vr_tab_dadin(vr_index)('dsinform.2') := vr_cratpro(vr_ind).dsinform##2;
        vr_tab_dadin(vr_index)('dsinform.3') := vr_cratpro(vr_ind).dsinform##3;
        -- Para TED
        IF vr_cratpro(vr_ind).cdtippro = 9 THEN
          vr_tab_dados(vr_index)('dsdbanco') := TRIM(gene0002.fn_busca_entrada(2, vr_cratpro(vr_ind).dsinform##2, '#'));
          vr_tab_dados(vr_index)('dsageban') := TRIM(gene0002.fn_busca_entrada(3, vr_cratpro(vr_ind).dsinform##2, '#'));
          vr_tab_dados(vr_index)('nrctafav') := TRIM(gene0002.fn_busca_entrada(4, vr_cratpro(vr_ind).dsinform##2, '#'));
          vr_tab_dados(vr_index)('nmfavore') := TRIM(gene0002.fn_busca_entrada(1, vr_cratpro(vr_ind).dsinform##2, '#'));
          vr_tab_dados(vr_index)('nrcpffav') := TRIM(gene0002.fn_busca_entrada(2, vr_cratpro(vr_ind).dsinform##2, '#'));
          vr_tab_dados(vr_index)('dsfinali') := TRIM(gene0002.fn_busca_entrada(3, vr_cratpro(vr_ind).dsinform##2, '#'));
          --
          --REQ40 - Busca o número do identificador do deposito judicial (TED)
          IF UPPER(TRIM(gene0002.fn_busca_entrada(3, vr_cratpro(vr_ind).dsinform##3, '#'))) <> 'DEPOSITO JUDICIAL' THEN
             vr_tab_dados(vr_index)('dstransf') := TRIM(gene0002.fn_busca_entrada(4, vr_cratpro(vr_ind).dsinform##2, '#'));
          ELSE   
             vr_tab_dados(vr_index)('dstransf') := gene0002.fn_busca_entrada(4,  vr_cratpro(vr_ind).dsinform##3, '#'); 
          END IF;
          --   
        END IF;

        -- Tratamento para codigo de barra, linha digitável e terminal
        IF vr_cratpro(vr_ind).cdtippro IN (2,6,7) THEN
          vr_tab_dados(vr_index)('cdbarras') := TRIM(gene0002.fn_busca_entrada(1, vr_cratpro(vr_ind).dsinform##3, '#'));
          vr_tab_dados(vr_index)('lndigita') := TRIM(gene0002.fn_busca_entrada(2, vr_cratpro(vr_ind).dsinform##3, '#'));
		-- DARF/DAS
		ELSIF vr_cratpro(vr_ind).cdtippro IN (16,17,18,19) THEN
			vr_tpcaptur := TO_NUMBER(TRIM(gene0002.fn_busca_entrada(2,(gene0002.fn_busca_entrada(1, vr_cratpro(vr_ind).dsinform##3, '#')), ':')));
				
			IF vr_tpcaptur = 1 THEN 
				vr_tab_dados(vr_index)('cdbarras') := TRIM(gene0002.fn_busca_entrada(2,(gene0002.fn_busca_entrada(7, vr_cratpro(vr_ind).dsinform##3, '#')), ':'));
            	vr_tab_dados(vr_index)('lndigita') := TRIM(gene0002.fn_busca_entrada(2,(gene0002.fn_busca_entrada(8, vr_cratpro(vr_ind).dsinform##3, '#')), ':'));
			END IF;
        -- FGTS
        ELSIF vr_cratpro(vr_ind).cdtippro = 24 THEN
          vr_tab_dados(vr_index)('cdbarras') := TRIM(gene0002.fn_busca_entrada(2,gene0002.fn_busca_entrada(3, vr_cratpro(vr_ind).dsinform##3, '#'), ':'));
          vr_tab_dados(vr_index)('lndigita') := TRIM(gene0002.fn_busca_entrada(2,gene0002.fn_busca_entrada(4, vr_cratpro(vr_ind).dsinform##3, '#'), ':'));
          --
        -- DAE
        ELSIF vr_cratpro(vr_ind).cdtippro = 23 THEN
          vr_tab_dados(vr_index)('cdbarras') := TRIM(gene0002.fn_busca_entrada(2,gene0002.fn_busca_entrada(3, vr_cratpro(vr_ind).dsinform##3, '#'), ':'));
          vr_tab_dados(vr_index)('lndigita') := TRIM(gene0002.fn_busca_entrada(2,gene0002.fn_busca_entrada(4, vr_cratpro(vr_ind).dsinform##3, '#'), ':'));
        ELSE
          vr_tab_dados(vr_index)('cdbarras') := '';
          vr_tab_dados(vr_index)('lndigita') := '';
        END IF;

        -- Valida tipos de operação do protocolo
        BEGIN
          IF vr_cratpro(vr_ind).cdtippro = 1 THEN /* transferência */
            vr_tab_dados(vr_index)('terminax') := TRIM(gene0002.fn_busca_entrada(1, vr_cratpro(vr_ind).dsinform##3, '#'));
          ELSIF vr_cratpro(vr_ind).cdtippro = 5 THEN /* Deposito TAA */
            vr_tab_dados(vr_index)('terminax') := TRIM(gene0002.fn_busca_entrada(2, vr_cratpro(vr_ind).dsinform##3, '#'));
          ELSIF vr_cratpro(vr_ind).cdtippro = 6 THEN /* Pagamento TAA */
            vr_tab_dados(vr_index)('terminax') := TRIM(gene0002.fn_busca_entrada(3, vr_cratpro(vr_ind).dsinform##3, '#'));
          ELSE
            vr_tab_dados(vr_index)('terminax') := '';
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            -- Em caso de erros na composição dos valores
            vr_tab_dados(vr_index)('terminax') := '';
        END;

        -- Ajustar campo de valor
        IF vr_tab_dados(vr_index)('cdtippro') = 7 THEN
          vr_tab_dados(vr_index)('lndigita') := '        ' || vr_tab_dados(vr_index)('lndigita');
        END IF;

        -- Busca a flgpagto
        IF vr_cratpro(vr_ind).cdtippro = 3 THEN
          vr_tab_dados(vr_index)('nmprimtl') := '';
          vr_tab_dados(vr_index)('tppgamto') := '';
          vr_tab_dados(vr_index)('dsdbanco') := '';

          -- Buscar dados de capitalização
          OPEN cr_crappla(vr_cratpro(vr_ind).nrdocmto, pr_cdcooper, pr_nrdconta);
          FETCH cr_crappla INTO rw_crappla;

          -- Verifica se retornou tupla
          IF cr_crappla%FOUND THEN
            CLOSE cr_crappla;

            -- Assume valor para a variável
            vr_tab_dados(vr_index)('flgpagto') := rw_crappla.flgpagto;
          ELSE
            CLOSE cr_crappla;
          END IF;
        ELSIF vr_cratpro(vr_ind).cdtippro <> 9 AND vr_cratpro(vr_ind).cdtippro <> 14 THEN

          -- Assume valores para as variáveis
          vr_dsinfor2 := TRIM(gene0002.fn_busca_entrada(2, vr_cratpro(vr_ind).dsinform##2, '#'));
          vr_tab_dados(vr_index)('nmprimtl') := TRIM(gene0002.fn_busca_entrada(1, vr_cratpro(vr_ind).dsinform##2, '#'));
          -- Referente forma pagamento
          vr_tab_dados(vr_index)('tppgamto') := TRIM(gene0002.fn_busca_entrada(1, vr_dsinfor2, ':'));
          -- Referente banco
          vr_tab_dados(vr_index)('dsdbanco') := TRIM(gene0002.fn_busca_entrada(2, vr_dsinfor2, ':'));
        END IF;

        -- Se transf. pega Coop. destino
        IF vr_cratpro(vr_ind).cdtippro = 1 THEN
          vr_tab_dados(vr_index)('dsageban') := TRIM(gene0002.fn_busca_entrada(3, vr_cratpro(vr_ind).dsinform##2, '#'));
        END IF;

        -- Valida número de registros
        IF vr_nrregist > 0 THEN
          -- Decrementa o número de registros
          vr_nrregist := vr_nrregist - 1;
        END IF;

       --PJ 470 - Rubens Lima (Mouts)
       IF vr_cratpro(vr_ind).cdtippro IN (25 -- Rescisão de Lim. Créd. (Termo)
                                            ,26 -- Solicitação de Portab. Créd. (Termo)
                                            ,27 -- Limite de Desc. Chq. (Contrato)
                                            ,28 -- Limite de Desc. Tit. (Contrato)
                                            ,29 -- Limite de Crédito (Contrato)
                                            ,30 -- Solicitação de Sustação de Chq.
                                            ,31 -- Sol.Canc.de Folha/Tal.de Chq. (Termo)
                                            )
       THEN
            vr_tab_dados(vr_index)('dtinclusao') := vr_cratpro(vr_ind).dtinclusao;
            vr_tab_dados(vr_index)('hrinclusao') := vr_cratpro(vr_ind).hrinclusao;
            vr_tab_dados(vr_index)('dsfrase') := vr_cratpro(vr_ind).dsfrase;
            vr_tab_dados(vr_index)('dsativo') := vr_cratpro(vr_ind).dsativo; -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
         IF vr_cratpro(vr_ind).cdtippro IN (30,31)
         THEN
              vr_tab_dados(vr_index)('dsoperacao') := vr_cratpro(vr_ind).dsoperacao;
              vr_tab_dados(vr_index)('cdbanco')    := vr_cratpro(vr_ind).cdbanco;
              vr_tab_dados(vr_index)('cdagencia')  := vr_cratpro(vr_ind).cdagencia;
              vr_tab_dados(vr_index)('cdconta')    := vr_cratpro(vr_ind).cdconta;
              vr_tab_dados(vr_index)('nrcheque_i') := vr_cratpro(vr_ind).nrcheque_i;
              vr_tab_dados(vr_index)('nrcheque_f') := vr_cratpro(vr_ind).nrcheque_f;
         END IF;
        END IF;
	
      END LOOP;

      -- Define retorno
      pr_des_erro := 'OK';
 
      -- Carrega as TAG´s do XML
      gene0007.pc_gera_tag(pr_nome_tag  => 'nmprimtl', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'tppgamto', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'dsdbanco', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'cdtippro', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'dstippro', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'dtmvtolt', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'dttransa', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'hrautent', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'hrautenx', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'vldocmto', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'nrdocmto', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'nrseqaut', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'dsinform', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'cdbarras', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'lndigita', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'terminax', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'dsprotoc', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'dscedent', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'flgagend', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'nmprepos', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'nrcpfpre', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'nmoperad', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'nrcpfope', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'flgpagto', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'dsageban', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'nrctafav', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'nmfavore', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'nrcpffav', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'dsfinali', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'dstransf', pr_tab_tag   => vr_tab_tags);
      --PJ470 
      gene0007.pc_gera_tag(pr_nome_tag  => 'dtinclusao', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'hrinclusao', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'dsfrase', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'dsoperacao', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'cdbanco'   , pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'cdagencia' , pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'cdconta'   , pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'nrcheque_i', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'nrcheque_f', pr_tab_tag   => vr_tab_tags);
      gene0007.pc_gera_tag(pr_nome_tag  => 'dsativo', pr_tab_tag   => vr_tab_tags); -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
      -- Fim PJ470
      -- Carrega as TAG´s do XML referente a descrição (novo nodo)
      gene0007.pc_gera_tag(pr_nome_tag  => 'dsinform.1', pr_tab_tag   => vr_tab_tagd);
      gene0007.pc_gera_tag(pr_nome_tag  => 'dsinform.2', pr_tab_tag   => vr_tab_tagd);
      gene0007.pc_gera_tag(pr_nome_tag  => 'dsinform.3', pr_tab_tag   => vr_tab_tagd);

      -- Criar nodo filho
      pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                         ,'/Root'
                                         ,XMLTYPE('<Protocolos qtregist="' || vr_qtregist || '"></Protocolos>'));

      -- Forma XML de retorno para casos de sucesso (listar dados)
      gene0007.pc_gera_xml(pr_tab_dados => vr_tab_dados
                          ,pr_tab_tag   => vr_tab_tags
                          ,pr_XMLType   => pr_retxml
                          ,pr_path_tag  => '/Root/Protocolos'
                          ,pr_tag_no    => 'Registro'
                          ,pr_des_erro  => pr_des_erro);

      -- Verifica se ocorreram erros
      IF pr_des_erro IS NOT NULL THEN
        pr_des_erro := 'Erro em PC_VERPRO:' || pr_des_erro;
        RAISE vr_exc_erro;
      END IF;

      -- Descobre o número de ocorrências do nodo
      gene0007.pc_lista_nodo(pr_xml      => pr_retxml
                            ,pr_nodo     => 'dsinform'
                            ,pr_cont     => vr_tagoco
                            ,pr_des_erro => pr_des_erro);

      -- Verifica se ocorreram erros
      IF pr_des_erro IS NOT NULL THEN
        pr_des_erro := 'Erro em PC_VERPRO:' || pr_des_erro;
        RAISE vr_exc_erro;
      END IF;

      -- Criar atributo na TAG específica para todas as suas ocorrências
      FOR vr_indc IN 0..(vr_tagoco - 1) LOOP
        gene0007.pc_gera_atributo(pr_xml      => pr_retxml
                                 ,pr_tag      => 'dsinform'
                                 ,pr_atrib    => 'Extent'
                                 ,pr_atval    => '3'
                                 ,pr_numva    => vr_indc
                                 ,pr_des_erro => pr_des_erro);

        -- Verifica se ocorreram erros
        IF pr_des_erro IS NOT NULL THEN
          pr_des_erro := 'Erro em PC_VERPRO:' || pr_des_erro; 
          RAISE vr_exc_erro;
        END IF;
      END LOOP;

      -- Gera novas TAGs na TAG dsinform
      FOR cont IN 1..vr_tab_dadin.count LOOP
        FOR nom IN 1..vr_tab_tagd.count LOOP
          -- Insere as TAG´s na TAG pai
          gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'dsinform'
                                ,pr_posicao  => (cont - 1)
                                ,pr_tag_nova => vr_tab_tagd(nom).tag
                                ,pr_tag_cont => vr_tab_dadin(cont)(vr_tab_tagd(nom).tag)
                                ,pr_des_erro => pr_des_erro);

          -- Verifica se ocorreram erros ao incluir a nova TAG
          IF pr_des_erro IS NOT NULL THEN
            pr_des_erro := 'Erro em PC_VERPRO:' || pr_des_erro;
            RAISE vr_exc_erro;
          END IF;
        END LOOP;
      END LOOP;

      -- Verifica se ocorreram erros
      IF pr_des_erro IS NOT NULL THEN
        pr_des_erro := 'Erro em PC_VERPRO:' || pr_des_erro;
        RAISE vr_exc_erro;
      END IF;

      pr_des_erro := 'OK';
    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');

    WHEN OTHERS THEN
      pr_des_erro := 'Erro geral em PC_VERPRO: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_verpro;
  
  --> TELA: MUDSEN - Mudança de Senha
  PROCEDURE pc_mudsen(pr_cdcooper IN crapcop.cdcooper%TYPE      --> Código Cooperativa
                     ,pr_cdoperad IN crapdev.cdoperad%TYPE      --> Cooperado
                     ,pr_cdsenha1 IN VARCHAR2                   --> Senha atual
                     ,pr_cdsenha2 IN VARCHAR2                   --> Nova senha
                     ,pr_cdsenha3 IN VARCHAR2                   --> Confirmação da senha
                     ,pr_xmllog   IN VARCHAR2                   --> XML com informações de LOG
                     ,pr_cdcritic OUT PLS_INTEGER               --> Código da crítica
                     ,pr_dscritic OUT VARCHAR2                  --> Descrição da crítica
                     ,pr_retxml   IN OUT NOCOPY XMLType         --> Arquivo de retorno do XML
                     ,pr_nmdcampo OUT VARCHAR2                  --> Nome do campo com erro
                     ,pr_des_erro OUT VARCHAR2) IS              --> Erros do processo
    -- ..........................................................................
    --
    --  Programa : PC_MUDSEN (Antigo: procedures/b1wgen0100.p)
    --  Sistema  : Rotinas para cadastros Web
    --  Sigla    : MUDSEN
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2013.                   Ultima atualizacao: 22/07/2014
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Validar alteração de senha e emitir ordem de alteração (UPDATE).
    --
    --   Alteracoes: 10/05/2013 - Conversão Progress >> Oracle PL/SQL (Petter - Supero)
    --
    --               22/07/2014 - Migrar a procedure para a package CADA0002 e ajustar 
    --                            a mesma. ( Renato - Supero )
    --
    --              23/06/2016 - Correcao no indice sobre a tabela crapope da pc_mudsen 
    --                           para comparar os campo cdoperad com o comando UPPER. 
    --                           (Carlos Rafael Tanholi).    
    -- .............................................................................

    -- Buscar dados dos operadores
    CURSOR cr_crapope(pr_cdcooper IN crapcop.cdcooper%TYPE       --> Código Cooperativa
                     ,pr_cdoperad IN crapdev.cdoperad%TYPE) IS   --> Cooperado
      SELECT co.cddsenha
           , co.dtaltsnh
           , co.rowid
        FROM crapope co
       WHERE co.cdcooper = pr_cdcooper
         AND UPPER(co.cdoperad) = UPPER(pr_cdoperad);
    
    -- Registros
    rw_crapope      cr_crapope%ROWTYPE;

  BEGIN      
    -- Carregar XML padrão para variável de retorno não utilizada.
    -- Existe para satisfazer exigência da interface.
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Dados>Rotina sem retorno definido</Dados></Root>');

    -- Tratamento de críticas
    OPEN cr_crapope(pr_cdcooper, pr_cdoperad);
    FETCH cr_crapope INTO rw_crapope;

    -- Verifica se foram encontrados registros
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      -- Define código da crítica
      pr_cdcritic := 67;

      pr_nmdcampo := 'cdoperad';
    ELSE
      -- Validação das senhas informadas
      IF pr_cdsenha1 = rw_crapope.cddsenha THEN
        IF pr_cdsenha2 = pr_cdsenha3 THEN
          IF pr_cdsenha2 = rw_crapope.cddsenha THEN
            pr_cdcritic := 6;
            pr_nmdcampo := 'cdsenha2';
          ELSIF pr_cdsenha2 IS NULL THEN
            pr_cdcritic := 5;
            pr_nmdcampo := 'cdsenha2';
          END IF;
        ELSE
          pr_cdcritic := 7;
          pr_nmdcampo := 'cdsenha3';
        END IF;
      ELSE
        pr_cdcritic := 3;
        pr_nmdcampo := 'cdsenha1';
      END IF;

      CLOSE cr_crapope;
    END IF;

    -- Verifica se ocorreram erros na validação do processo
    IF pr_cdcritic > 0 THEN
      -- Gerar descrição da crítica
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      -- Retorno de erro
      pr_des_erro := 'NOK';

      RAISE vr_exc_erro;
    END IF;

    -- Atualiza a nova senha
    BEGIN
      UPDATE crapope cp
         SET cp.cddsenha = pr_cdsenha2
           , cp.dtaltsnh = SYSDATE
       WHERE cp.rowid    = rw_crapope.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro ao atualizar a tabela CRAPOPE: ' || SQLERRM;
        RAISE vr_exc_erro;
    END;

    -- Verifica se ocorreram erros
    IF pr_des_erro <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;

    IF pr_cdcritic > 0 THEN
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);

      -- Retorno de erro
      pr_des_erro := 'NOK';

      RAISE vr_exc_erro;
    END IF;

    -- Retorno de sucesso
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;
      pr_des_erro := 'Erro em PC_MUDSEN: ' || pr_des_erro;
    WHEN OTHERS THEN
      ROLLBACK;
      pr_des_erro := 'Erro em PC_MUDSEN: ' || SQLERRM;
  END pc_mudsen;
  
  
  --> Imprimir dados VERPRO
  PROCEDURE pc_verpro_imp(pr_cdcooper  IN NUMBER
                         ,pr_dsiduser  IN VARCHAR2  
                         ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                         ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                         ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                         ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                         ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                         ,pr_des_erro  OUT VARCHAR2) IS         --> Erros do processo

    /* .............................................................................

     Programa: pc_verpro_imp
     Sistema : Rotinas acessadas pelas telas de cadastros Web
     Sigla   : CADA
     Autor   : Renato Darosci - Supero
     Data    : Julho/2014.                  Ultima atualizacao: 09/03/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Efetua a impressao dos protocolos
     Observacao: -----

     Alteracoes: 09/12/2014 - Alterado procedure que busca diretorio do arquivo.
                              utilizando proc. fn_diretorio. (Jorge/Rodrigo) SD 229515
                              
                 05/04/2016 - Ajuste para retirar o "*" ao remover o arquivo
                             (Adriano).             
                             
                 09/03/2017 - Ajuste para incluir informações referentes a comprovante
                              de pagamento em debito automatico (Aline).                      
							                      
                 09/01/2018 - Incluido tratamento para FGTS e DAE - PRJ406.
                 
                 04/10/2018 - Impressão do Borderô (Vitor S Assanuma - GFT)

                 12/12/2018 - Incluido tratamento para novas linhas de credito - Rubens Lima (Mouts) - PRJ470

                 19/03/2019 - Alterado o id do protocolo de desconto de titulo do 22 para o 32 (Paulo Penteado GFT)
    ..............................................................................*/ 
    -- CURSORES
    -- Buscar as informações da cooperativa
    CURSOR cr_crapcop IS
      SELECT crapcop.cdbcoctl
           , crapcop.cdagectl
           , crapcop.nmrescop
        FROM crapcop 
       WHERE crapcop.cdcooper = pr_cdcooper;
    
    -- REGISTROS
    rw_crapcop     cr_crapcop%ROWTYPE;
    rw_crapdat     btch0001.cr_crapdat%ROWTYPE; -- Informações de data
    rw_xmldata     typ_xmldata;
  
    -- VARIÁVEIS
    vr_cdcooper    NUMBER;
    vr_nmdatela    varchar2(25);
    vr_nmeacao     varchar2(25);
    vr_cdagenci    varchar2(25);
    vr_nrdcaixa    varchar2(25);
    vr_idorigem    varchar2(25);
    vr_cdoperad    varchar2(25);

    vr_nmdireto    VARCHAR2(100);
    vr_dsdirarq    VARCHAR2(200);
    vr_nmarqpdf    VARCHAR2(200);
    
    vr_typ_said    VARCHAR2(50);
    vr_nmrotina    VARCHAR2(30);
    
    vr_des_reto    VARCHAR2(10);
    vr_tab_erro    gene0001.typ_tab_erro;
    
    -- Retornar o valor do nodo tratando casos nulos
    FUNCTION fn_extract(pr_nodo  VARCHAR2) RETURN VARCHAR2 IS
      
    BEGIN
      -- Extrai e retorna o valor... retornando null em caso de erro ao ler
      RETURN pr_retxml.extract(pr_nodo).getstringval();
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
    
  BEGIN
    
    -- extrair informações padrão do xml - parametros
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml 
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao 
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => pr_dscritic);
  
    -- Buscar dados da cooperativa
    OPEN  cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    -- Se não encontrar dados
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      pr_des_erro := 'Cooperativa não encontrada. PR_CDCOOPER = '||pr_cdcooper;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapcop;
    
    -- Busca a data de execução
    OPEN  BTCH0001.cr_crapdat(pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar dados
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      CLOSE BTCH0001.cr_crapdat;
      pr_des_erro := 'Data do sistema não encontrada. PR_CDCOOPER = '||pr_cdcooper;
      RAISE vr_exc_erro;
    END IF;
    CLOSE BTCH0001.cr_crapdat;
    
    -- Buscar o diretório do relatório
    vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => 'rl');
                                        
    -- Definir o nome do arquivo
    vr_nmarqpdf := pr_dsiduser||'.pdf';
    vr_dsdirarq := vr_nmdireto||'/'||vr_nmarqpdf;
    
    
    -- Comando para excluir arquivos já existentes
    gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_nmdireto||'/'||vr_nmarqpdf||' 2> /dev/null'
                                  ,pr_typ_saida   => vr_typ_said
                                  ,pr_des_saida   => pr_dscritic);
    -- Verificar retorno de erro
    IF NVL(vr_typ_said, ' ') = 'ERR' THEN
      -- O comando shell executou com erro, gerar log e sair do processo
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao remover arquivos: '||pr_dscritic;
      RAISE vr_exc_erro;
    END IF;

    -- Extrair as informações para a impressão
    rw_xmldata.nrdconta := fn_extract('/Root/Dados/nrdconta/text()');
    rw_xmldata.nmprimtl := fn_extract('/Root/Dados/nmprimtl/text()');
    rw_xmldata.cdtippro := fn_extract('/Root/Dados/cdtippro/text()');
    rw_xmldata.nrdocmto := fn_extract('/Root/Dados/nrdocmto/text()');
    rw_xmldata.nrseqaut := fn_extract('/Root/Dados/nrseqaut/text()');
    rw_xmldata.nmprepos := fn_extract('/Root/Dados/nmprepos/text()');
    rw_xmldata.nmoperad := fn_extract('/Root/Dados/nmoperad/text()');
    rw_xmldata.dttransa := to_date(fn_extract('/Root/Dados/dttransa/text()'),'dd/mm/yyyy');
    rw_xmldata.hrautent := fn_extract('/Root/Dados/hrautent/text()');
    rw_xmldata.dtmvtolx := to_date(fn_extract('/Root/Dados/dtmvtolx/text()'),'dd/mm/yyyy');
    rw_xmldata.dsprotoc := fn_extract('/Root/Dados/dsprotoc/text()');
    rw_xmldata.cdbarras := fn_extract('/Root/Dados/cdbarras/text()');
    rw_xmldata.lndigita := fn_extract('/Root/Dados/lndigita/text()');
    rw_xmldata.label    := fn_extract('/Root/Dados/label/text()');
    rw_xmldata.label2   := fn_extract('/Root/Dados/label2/text()');
    rw_xmldata.valor    := GENE0002.fn_char_para_number(fn_extract('/Root/Dados/valor/text()'));
    rw_xmldata.auxiliar := fn_extract('/Root/Dados/auxiliar/text()');
    rw_xmldata.auxiliar2:= fn_extract('/Root/Dados/auxiliar2/text()');
    rw_xmldata.auxiliar3:= fn_extract('/Root/Dados/auxiliar3/text()');
    rw_xmldata.auxiliar4:= fn_extract('/Root/Dados/auxiliar4/text()');
    rw_xmldata.dsdbanco := fn_extract('/Root/Dados/dsdbanco/text()');
    rw_xmldata.dsageban := fn_extract('/Root/Dados/dsageban/text()');
    rw_xmldata.nrctafav := fn_extract('/Root/Dados/nrctafav/text()');
    rw_xmldata.nmfavore := fn_extract('/Root/Dados/nmfavore/text()');
	  rw_xmldata.nmconven := SUBSTR(fn_extract('/Root/Dados/nmconven/text()'),1,100);
    rw_xmldata.nrcpffav := fn_extract('/Root/Dados/nrcpffav/text()');
    rw_xmldata.dsfinali := fn_extract('/Root/Dados/dsfinali/text()');
    rw_xmldata.dstransf := fn_extract('/Root/Dados/dstransf/text()');
    rw_xmldata.dsispbif := fn_extract('/Root/Dados/dsispbif/text()');
		rw_xmldata.dspacote := fn_extract('/Root/Dados/dspacote/text()');
		rw_xmldata.dtdiadeb := GENE0002.fn_char_para_number(fn_extract('/Root/Dados/dtdiadeb/text()'));		
		rw_xmldata.dtinivig := to_date(fn_extract('/Root/Dados/dtinivig/text()'),'dd/mm/yyyy');		
		--DARF/DAS
    rw_xmldata.tpcaptur := fn_extract('/Root/Dados/tpcaptur/text()');
		rw_xmldata.dsagtare := fn_extract('/Root/Dados/dsagtare/text()');
		rw_xmldata.dsagenci := fn_extract('/Root/Dados/dsagenci/text()');
		rw_xmldata.tpdocmto := fn_extract('/Root/Dados/tpdocmto/text()');
		rw_xmldata.dsnomfon := fn_extract('/Root/Dados/dsnomfon/text()');
		rw_xmldata.nmsolici := fn_extract('/Root/Dados/nmsolici/text()');
		rw_xmldata.dtvencto := to_date(fn_extract('/Root/Dados/dtvencto/text()'),'dd/mm/rrrr');
		rw_xmldata.dtapurac := to_date(fn_extract('/Root/Dados/dtapurac/text()'),'dd/mm/rrrr');
		rw_xmldata.nrcpfcgc := fn_extract('/Root/Dados/nrcpfcgc/text()');
		rw_xmldata.cdtribut := fn_extract('/Root/Dados/cdtribut/text()');
		rw_xmldata.nrrefere := fn_extract('/Root/Dados/nrrefere/text()');
		rw_xmldata.vlrecbru := GENE0002.fn_char_para_number(fn_extract('/Root/Dados/vlrecbru/text()'));
		rw_xmldata.vlpercen := GENE0002.fn_char_para_number(fn_extract('/Root/Dados/vlpercen/text()'));
		rw_xmldata.vlprinci := GENE0002.fn_char_para_number(fn_extract('/Root/Dados/vlprinci/text()'));
		rw_xmldata.vlrmulta := GENE0002.fn_char_para_number(fn_extract('/Root/Dados/vlrmulta/text()'));
		rw_xmldata.vlrjuros := GENE0002.fn_char_para_number(fn_extract('/Root/Dados/vlrjuros/text()'));
		rw_xmldata.vltotfat := GENE0002.fn_char_para_number(fn_extract('/Root/Dados/vltotfat/text()'));
		rw_xmldata.nrdocdas := fn_extract('/Root/Dados/nrdocdas/text()');
		rw_xmldata.nrdocdrf := fn_extract('/Root/Dados/nrdocdrf/text()');		
		rw_xmldata.dsidepag := fn_extract('/Root/Dados/dsidepag/text()');
		rw_xmldata.dtmvtdrf := to_date(fn_extract('/Root/Dados/dtmvtdrf/text()'),'dd/mm/rrrr');
		rw_xmldata.dtvencto_drf := to_date(fn_extract('/Root/Dados/dtvencto_drf/text()'),'dd/mm/rrrr');		
		rw_xmldata.hrautdrf := fn_extract('/Root/Dados/hrautdrf/text()');
		rw_xmldata.vlrecarga := GENE0002.fn_char_para_number(fn_extract('/Root/Dados/vlrecarga/text()'));
 		rw_xmldata.nmoperadora := fn_extract('/Root/Dados/nmoperadora/text()');
 		rw_xmldata.nrtelefo := fn_extract('/Root/Dados/nrtelefo/text()');		
		rw_xmldata.dtrecarga := to_date(fn_extract('/Root/Dados/dtrecarga/text()'),'dd/mm/rrrr');		
		rw_xmldata.hrrecarga := fn_extract('/Root/Dados/hrrecarga/text()');		
		rw_xmldata.dtdebito := to_date(fn_extract('/Root/Dados/dtdebito/text()'),'dd/mm/rrrr');		
		rw_xmldata.nsuopera := fn_extract('/Root/Dados/nsuopera/text()');						
    --FGTS/DAE
    rw_xmldata.cdconven := fn_extract('/Root/Dados/cdconven/text()');
    rw_xmldata.dtvalida := to_date(fn_extract('/Root/Dados/dtvalida/text()'),'dd/mm/rrrr');
    rw_xmldata.cdcompet := fn_extract('/Root/Dados/cdcompet/text()');
    rw_xmldata.nrdocpes := fn_extract('/Root/Dados/nrdocpes/text()');
    rw_xmldata.cdidenti := fn_extract('/Root/Dados/cdidenti/text()');
    rw_xmldata.nrdocmto_dae := fn_extract('/Root/Dados/nrdocmto_dae/text()');
    rw_xmldata.dslinha3 := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(fn_extract('/Root/Dados/Inform/Linhas/dslinha3/text()')));
    rw_xmldata.qttitbor := fn_extract('/Root/Dados/qttitbor/text()');
    --pj470
    rw_xmldata.dtinclusao := to_date(fn_extract('/Root/Dados/dtinclusao/text()'),'dd/mm/rrrr');
    rw_xmldata.hrinclusao := to_date(fn_extract('/Root/Dados/hrinclusao/text()'),'hh24:mi:ss');
    rw_xmldata.dsoperacao := NVL(fn_extract('/Root/Dados/dsoperacao/text()'),'-');
    rw_xmldata.cdbanco    := NVL(fn_extract('/Root/Dados/cdbanco/text()'),'-');
    rw_xmldata.cdagencia  := NVL(fn_extract('/Root/Dados/cdagencia/text()'),'-');
    rw_xmldata.cdconta    := NVL(fn_extract('/Root/Dados/cdconta/text()'),'-');
    rw_xmldata.nrcheque_i := NVL(fn_extract('/Root/Dados/nrcheque_i/text()'),'-');
    rw_xmldata.nrcheque_f := NVL(fn_extract('/Root/Dados/nrcheque_f/text()'),'-');
    rw_xmldata.dsativo    := NVL(fn_extract('/Root/Dados/nrcheque_f/text()'),'-'); -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
    -- Fim pj470

    
    -- Inicializar o CLOB do XML
    vr_dsxmlrel := null;
    dbms_lob.createtemporary(vr_dsxmlrel, true);
    dbms_lob.open(vr_dsxmlrel, dbms_lob.lob_readwrite);
    
    -- Inicilizar as informações do XML
    vr_dsdtexto := null;
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><root>');
    
    -- Tratamento para escrever as linhas do XML
    IF    rw_xmldata.cdtippro = 1 THEN
      
      -- Guardar o nome da rotina chamada para exibir em caso de erro
      vr_nmrotina := 'PC_IMPRESSAO_TRANSF';
    
      -- Imprimir transferencia
      pc_impressao_transf(pr_xmldata  => rw_xmldata
                         ,pr_nmrescop => rw_crapcop.nmrescop);
      
    ELSIF rw_xmldata.cdtippro = 2 THEN
      -- Guardar o nome da rotina chamada para exibir em caso de erro
      vr_nmrotina := 'PC_IMPRESSAO_PAG';
    
      -- Imprimir pagamento
      pc_impressao_pag(pr_xmldata  => rw_xmldata
                      ,pr_nmrescop => rw_crapcop.nmrescop
                      ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                      ,pr_cdagectl => rw_crapcop.cdagectl);                      
      
    ELSIF rw_xmldata.cdtippro = 3 THEN
      -- Guardar o nome da rotina chamada para exibir em caso de erro
      vr_nmrotina := 'PC_IMPRESSAO_CAP';
    
      -- Imprimir comprovante de capital
      pc_impressao_cap(pr_xmldata  => rw_xmldata
                      ,pr_nmrescop => rw_crapcop.nmrescop);                      
      
    ELSIF rw_xmldata.cdtippro = 4 THEN
      
      -- Guardar o nome da rotina chamada para exibir em caso de erro
      vr_nmrotina := 'PC_IMPRESSAO_CREDITO';
    
      -- Imprimir comprovante transferencia
      pc_impressao_credito(pr_xmldata  => rw_xmldata
                          ,pr_nmrescop => rw_crapcop.nmrescop);
      
    ELSIF rw_xmldata.cdtippro = 5 THEN
      
      -- Guardar o nome da rotina chamada para exibir em caso de erro
      vr_nmrotina := 'PC_IMPRESSAO_TAA';
    
      -- Imprimir comprovante transferencia
      pc_impressao_taa(pr_xmldata  => rw_xmldata
                      ,pr_nmrescop => rw_crapcop.nmrescop);
      
    ELSIF rw_xmldata.cdtippro = 6 THEN
      
      -- Guardar o nome da rotina chamada para exibir em caso de erro
      vr_nmrotina := 'PC_IMPRESSAO_PAG_TAA';
    
      -- Imprimir comprovante transferencia
      pc_impressao_pag_taa(pr_xmldata  => rw_xmldata
                          ,pr_nmrescop => rw_crapcop.nmrescop
                          ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                          ,pr_cdagectl => rw_crapcop.cdagectl);
                          
    ELSIF rw_xmldata.cdtippro = 7 THEN
      
      -- Guardar o nome da rotina chamada para exibir em caso de erro
      vr_nmrotina := 'PC_IMPRESSAO_REM';
    
      -- Imprimir comprovante de arquivo de remessa
      pc_impressao_rem(pr_xmldata  => rw_xmldata
                      ,pr_nmrescop => rw_crapcop.nmrescop);
                      
    ELSIF rw_xmldata.cdtippro = 9 THEN
      
      -- Guardar o nome da rotina chamada para exibir em caso de erro
      vr_nmrotina := 'PC_IMPRESSAO_TED';
    
      -- Imprimir comprovante de TED
      pc_impressao_ted(pr_xmldata  => rw_xmldata
                      ,pr_nmrescop => rw_crapcop.nmrescop);  
    
    ELSIF rw_xmldata.cdtippro = 10 THEN
      
      -- Guardar o nome da rotina chamada para exibir em caso de erro
      vr_nmrotina := 'PC_IMPRESSAO_APLICA';
    
      -- Imprimir comprovante de Aplicação
      pc_impressao_aplica(pr_xmldata  => rw_xmldata
                         ,pr_cdcooper => pr_cdcooper
                         ,pr_nmrescop => rw_crapcop.nmrescop);  
    ELSIF rw_xmldata.cdtippro = 12 THEN

      -- Guardar o nome da rotina chamada para exibir em caso de erro
      vr_nmrotina := 'PC_IMPRESSAO_RESG_APLICA';
    
      -- Imprimir comprovante de Resgate de Aplicação
      pc_impressao_resg_aplica(pr_xmldata  => rw_xmldata
                              ,pr_cdcooper => pr_cdcooper
                              ,pr_nmrescop => rw_crapcop.nmrescop);  
      
    ELSIF rw_xmldata.cdtippro = 13 THEN --GPS
      -- Guardar o nome da rotina chamada para exibir em caso de erro
      vr_nmrotina := 'PC_IMPRESSAO_GPS';
    
      -- Imprimir comprovante de pagamento de GPS
      pc_impressao_gps(pr_xmldata  => rw_xmldata
                      ,pr_nmrescop => rw_crapcop.nmrescop
                      ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                      ,pr_cdagectl => rw_crapcop.cdagectl);      
													 
    ELSIF rw_xmldata.cdtippro = 14 THEN
      
      -- Guardar o nome da rotina chamada para exibir em caso de erro
      vr_nmrotina := 'PC_IMPRESSAO_PAC_TAR';
    
      -- Imprimir comprovante de Aplicação
      pc_impressao_pac_tar(pr_xmldata  => rw_xmldata
                          ,pr_nmrescop => rw_crapcop.nmrescop);  
      
    ELSIF rw_xmldata.cdtippro = 15 THEN

     -- Guardar o nome da rotina chamada para exibir em caso de erro
      vr_nmrotina := 'PC_IMPRESSAO_DEBAUT';
    
      -- Imprimir comprovante
      pc_impressao_debaut(pr_xmldata  => rw_xmldata
                         ,pr_nmrescop => rw_crapcop.nmrescop);    
      
    ELSIF rw_xmldata.cdtippro IN (16,17,18,19) THEN --DARF/DAS
      -- Guardar o nome da rotina chamada para exibir em caso de erro
      vr_nmrotina := 'PC_IMPRESSAO_DARFDAS';
    
      -- Imprimir pagamento
      pc_impressao_darf_das(pr_xmldata  => rw_xmldata
                           ,pr_nmrescop => rw_crapcop.nmrescop
                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                           ,pr_cdagectl => rw_crapcop.cdagectl);      
    ELSIF rw_xmldata.cdtippro IN (32) THEN --BORDERO
      -- Guardar o nome da rotina chamada para exibir em caso de erro
      vr_nmrotina := 'PC_IMPRESSAO_BORDERO';
													 
      -- Imprimir pagamento
      pc_impressao_bordero(pr_xmldata  => rw_xmldata
                           ,pr_nmrescop => rw_crapcop.nmrescop
                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                           ,pr_cdagectl => rw_crapcop.cdagectl);
    ELSIF rw_xmldata.cdtippro IN (24,23) THEN --FGTS/DAE
      -- Guardar o nome da rotina chamada para exibir em caso de erro
      vr_nmrotina := 'PC_IMPRESSAO_FGTSDAE';
    
      -- Imprimir pagamento
      pc_impressao_fgts_dae(pr_xmldata  => rw_xmldata
                           ,pr_nmrescop => rw_crapcop.nmrescop
                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                           ,pr_cdagectl => rw_crapcop.cdagectl);
													 
    ELSIF rw_xmldata.cdtippro = 20 THEN
      
      -- Guardar o nome da rotina chamada para exibir em caso de erro
      vr_nmrotina := 'PC_IMPRESSAO_REC_CEL';
    
      -- Imprimir comprovante de Aplicação
      pc_impressao_rec_cel(pr_xmldata  => rw_xmldata
                          ,pr_nmrescop => rw_crapcop.nmrescop);  
													 
    -- PJ470
    ELSIF rw_xmldata.cdtippro IN (25 -- Rescisão de Lim. Créd. (Termo)
                                 ,26 -- Solicitação de Portab. Créd. (Termo)
                                 ,27 -- Limite de Desc. Chq. (Contrato)
                                 ,28 -- Limite de Desc. Tit. (Contrato)
                                 ,29 -- Limite de Crédito (Contrato)
                                 ,30 -- Solicitação de Sustação de Chq.
                                 ,31 -- Sol.Canc.de Folha/Tal.de Chq. (Termo)
                                 ) THEN
        -- Guardar o nome da rotina chamada para exibir em caso de erro
        vr_nmrotina := 'PC_IMPRESSAO_CTD';
        -- Imprimir pagamento
        pc_impressao_ctd(pr_xmldata => rw_xmldata
                          ,pr_nmrescop => rw_crapcop.nmrescop);  
    -- Fim PJ470
    END IF;
    
    -- Tag de finalização do XML
    pc_escreve_xml('</root>',NULL,TRUE);
    
    -- Solicitar geração do relatorio
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                               ,pr_cdprogra  => vr_nmdatela -- 'VERPRO'                             --> Programa chamador
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                               ,pr_dsxml     => vr_dsxmlrel                          --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/root'                              --> Nó base do XML para leitura dos dados
                               ,pr_dsjasper  => 'verpro.jasper'                      --> Arquivo de layout do iReport
                               ,pr_dsparams  => NULL                                 --> Sem parâmetros
                               ,pr_dsarqsaid => vr_dsdirarq                          --> Arquivo final com o path
                               ,pr_cdrelato  => 999
                               ,pr_dsextcop  => 'pdf'
                               ,pr_qtcoluna  => 80                                   --> 80 colunas
                               ,pr_flg_gerar => 'S'                                  --> Geraçao na hora
                               ,pr_flg_impri => 'N'                                  --> Chamar a impressão (Imprim.p)
                               ,pr_nmformul  => ''                                   --> Nome do formulário para impressão
                               ,pr_nrcopias  => 1                                    --> Número de cópias
                               ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                               ,pr_des_erro  => pr_dscritic);                        --> Saída com erro

    -- Tratar erro                              
    IF TRIM(pr_dscritic) IS NOT NULL THEN
      pr_des_erro := 'Erro ao gerar relatorio: '||TRIM(pr_dscritic);
      RAISE vr_exc_erro;  
    END IF;  
    
    -- Enviar relatorio para intranet
    gene0002.pc_efetua_copia_pdf 
                          (pr_cdcooper => vr_cdcooper    --> Cooperativa conectada
                          ,pr_cdagenci => vr_cdagenci    --> Codigo da agencia para erros
                          ,pr_nrdcaixa => vr_nrdcaixa    --> Codigo do caixa para erros
                          ,pr_nmarqpdf => vr_dsdirarq    --> Arquivo PDF  a ser gerado                                 
                          ,pr_des_reto => vr_des_reto    --> Saída com erro
                          ,pr_tab_erro => vr_tab_erro);  --> tabela de erros
                                  
    -- caso apresente erro na operação
    IF nvl(vr_des_reto,'OK') <> 'OK' THEN
      IF vr_tab_erro.COUNT > 0 THEN
        pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        pr_des_erro := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                
        RAISE vr_exc_erro;
      END IF;  
    END IF; 
    
    -- Comando para excluir arquivos já existentes
    gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_dsdirarq
                                  ,pr_typ_saida   => vr_typ_said
                                  ,pr_des_saida   => pr_dscritic);
    -- Verificar retorno de erro
    IF NVL(vr_typ_said, ' ') = 'ERR' THEN
      -- O comando shell executou com erro, gerar log e sair do processo
      pr_cdcritic := 0;
      pr_des_erro := 'Erro ao remover arquivos: '||pr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_dsxmlrel);
    dbms_lob.freetemporary(vr_dsxmlrel);
    
    -- Criar XML de retorno
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' || vr_nmarqpdf || '</nmarqpdf>');
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF pr_dscritic IS NOT NULL THEN
        pr_des_erro := pr_dscritic;
      END IF;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>Rotina com erros</Erro></Root>');

    WHEN OTHERS THEN
      pr_des_erro := 'Erro geral em PC_VERPRO['||vr_nmrotina||']: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>Rotina com erros</Erro></Root>');
  END pc_verpro_imp;
  
  --> Procedure para incluir conta de transferencia
  PROCEDURE pc_inclui_conta_transf (pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                   ,pr_cdagenci IN crapage.cdagenci%TYPE --> Codigo da agencia   
                                   ,pr_nrdcaixa IN INTEGER               --> Numero do caixa
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE --> Cod. do operador
                                   ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                   ,pr_idorigem IN INTEGER               --> Identificador de origem
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta 
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq. do titular
                                   ,pr_dtmvtolt IN DATE                  --> Data do movimento
                                   ,pr_nrcpfope IN crapopi.nrcpfope%TYPE --> CPF operador juridico 
                                   ,pr_flgerlog IN INTEGER               --> flg geracao log 
                                   ,pr_cddbanco IN INTEGER               --> Codigo do banco destino
                                   ,pr_cdageban IN INTEGER               --> Agencia destino
                                   ,pr_nrctatrf IN crapcti.nrctatrf%TYPE --> Nr. conta transf
                                   ,pr_nmtitula IN VARCHAR2              --> Nome titular
                                   ,pr_nrcpfcgc IN NUMBER                --> CPF titulat
                                   ,pr_inpessoa IN INTEGER               --> Tipo pessoa
                                   ,pr_intipcta IN INTEGER               --> Tipo de conta
                                   ,pr_intipdif IN INTEGER               --> tipo de inst. financeira da conta
                                   ,pr_rowidcti IN crapcti.progress_recid%TYPE --> Recid da cta transf
                                   ,pr_cdispbif IN crapcti.nrispbif%TYPE --> Oito primeiras posicoes do cnpj. 
                                   -- OUT 
                                   ,pr_msgaviso OUT VARCHAR2              --> Mensagem de aviso
                                   ,pr_des_erro OUT VARCHAR2              --> Indicador se retornou com erro (OK ou NOK)
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da critica
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica


    /* .............................................................................

     Programa: pc_inclui_conta_transf         (Antiga: b1wgen0015.inclui-conta-transferencia)
     Sistema : Rotinas acessadas pelas telas de cadastros Web
     Sigla   : CADA
     Autor   : Odirlei Busana - AMcom
     Data    : Junho/2015.                  Ultima atualizacao: 19/05/2016

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina responsavel por cadastrar as contas de transferencia
     Observacao: -----

     Alteracoes: 03/06/2015 - Conversão Progress -> Oracle (Odirlei-AMcom)
     
	             12/04/2016 - Remocao Aprovacao Favorecido. (Jaison/Marcos - SUPERO)
     
				 19/05/2016 - Ajsute na inclusão do registro crapcti para tratar quando
						      o número do ISPB vier nulo e incluir a verificação de senha
							  para contas com assinatura conjunta
							  (Adriano - M117).
    ..............................................................................*/ 
    ----------------> CURSORES  <-----------------    
    -- Buscar as informações da cooperativa
    CURSOR cr_crapcop_age (pr_cdageban crapcop.cdagectl%TYPE )IS
      SELECT  crapcop.cdcooper
           , crapcop.cdagectl
           , crapcop.nmrescop
           , crapcop.cdbcoctl
           , crapcop.nmextcop
           , crapcop.nrtelfax
           , crapcop.dsdemail
        FROM crapcop 
       WHERE crapcop.cdagectl = pr_cdageban ;   
    rw_crapcop_age  cr_crapcop_age%ROWTYPE;    
    
     -- Buscar as informações da cooperativa
    CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%TYPE )IS
      SELECT crapcop.cdcooper
           , crapcop.cdagectl
           , crapcop.nmrescop
           , crapcop.cdbcoctl
           , crapcop.nmextcop
           , crapcop.nrtelfax
           , crapcop.dsdemail
        FROM crapcop 
       WHERE crapcop.cdcooper = pr_cdcooper ;    
    rw_crapcop  cr_crapcop%ROWTYPE;
    
    -- Buscar associado
    CURSOR cr_crapass ( pr_cdcooper crapass.cdcooper%TYPE,
                        pr_nrdconta crapass.nrdconta%TYPE)  IS
      SELECT ass.nmprimtl,
             ass.inpessoa,
             ass.nrdconta,
             ass.idastcjt
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    rw_crabass cr_crapass%ROWTYPE;
    
    -- Verificar cadasto de senhas
    CURSOR cr_crapsnh (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE,
                       pr_idseqttl crapttl.idseqttl%TYPE,                       
                       pr_cdsitsnh crapsnh.cdsitsnh%TYPE) IS
      SELECT crapsnh.cdcooper
            ,crapsnh.nrdconta
            ,crapsnh.nrcpfcgc
            ,crapsnh.vllimweb
            ,crapsnh.vllimtrf
            ,crapsnh.vllimted
        FROM crapsnh
       WHERE crapsnh.cdcooper = pr_cdcooper
         AND crapsnh.nrdconta = pr_nrdconta
         AND (NVL(pr_idseqttl, 0) = 0 OR crapsnh.idseqttl = pr_idseqttl)
         AND crapsnh.tpdsenha = 1
         AND crapsnh.cdsitsnh = pr_cdsitsnh;         
    rw_crapsnh cr_crapsnh%ROWTYPE;
         
    -- Verificar cadasto de senhas
    CURSOR cr_crapavt (pr_cdcooper crapavt.cdcooper%TYPE,
                       pr_nrdconta crapavt.nrdconta%TYPE,
                       pr_nrcpfcgc crapavt.nrcpfcgc%TYPE) IS
      SELECT crapavt.cdcooper
            ,crapavt.nrdconta
            ,crapavt.nrdctato
            ,crapavt.nmdavali
        FROM crapavt
       WHERE crapavt.cdcooper = pr_cdcooper
         AND crapavt.nrdconta = pr_nrdconta
         AND crapavt.tpctrato = 6
         AND crapavt.nrcpfcgc = pr_nrcpfcgc;
    rw_crapavt cr_crapavt%ROWTYPE;                               
    
    -- Buscar titulares
    CURSOR cr_crapttl ( pr_cdcooper crapass.cdcooper%TYPE,
                        pr_nrdconta crapass.nrdconta%TYPE)  IS
      SELECT ttl.nmextttl
            ,ttl.inpessoa
            ,ttl.idseqttl
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta;
    
    -- Buscar associado
    CURSOR cr_crapopi ( pr_cdcooper crapopi.cdcooper%TYPE,
                        pr_nrdconta crapopi.nrdconta%TYPE,
                        pr_nrcpfope crapopi.nrcpfope%TYPE)  IS
      SELECT opi.nrdconta
            ,opi.nmoperad
        FROM crapopi opi
       WHERE opi.cdcooper = pr_cdcooper
         AND opi.nrdconta = pr_nrdconta
         AND opi.nrcpfope = pr_nrcpfope;
    rw_crapopi cr_crapopi%ROWTYPE;
    
    -- Verificar cadastro de transferencia
    CURSOR cr_crapcti (pr_rowidcti crapcti.progress_recid%TYPE) IS 
      SELECT cti.cddbanco,
             cti.dttransa,
             cti.hrtransa,
             cti.cdageban,
             cti.nrctatrf,
             cti.nmtitula,
             cti.dsprotoc,
             cti.insitcta,
             cti.nrispbif,
             cti.rowid
        FROM crapcti cti
       WHERE cti.progress_recid = pr_rowidcti
         FOR UPDATE; 
    rw_crapcti cr_crapcti%ROWTYPE;     
    
    ----------------> VARIAVEIS <-----------------
    vr_exec_inclui EXCEPTION;
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(500);
    
    vr_dsorigem    VARCHAR2(100);
    vr_dstransa    VARCHAR2(100);
    vr_flgtrans    BOOLEAN;
    vr_cddbanco    crapcti.cddbanco%TYPE;
    vr_nmtitula    crapcti.nmtitula%TYPE;
    vr_inpessoa    crapcti.inpessoa%TYPE;
    vr_nrcpfcgc    crapcti.nrcpfcgc%TYPE;
    vr_intipcta    crapcti.intipcta%TYPE;
    vr_nrseqcad    NUMBER;
    vr_rowid_craplgm ROWID;
	vr_crapsnhFound BOOLEAN:=FALSE;
    
    BEGIN
        
    IF pr_flgerlog = 1 /*1 = TRUE*/ THEN
      vr_dsorigem :=  gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa := 'Inclusao de Conta para Transferencia.';
    END IF;
    
    vr_flgtrans := FALSE;
    vr_cdcritic := 0;
    vr_dscritic := NULL;
    -- Inicializar variaveis que vem como parametro
    vr_cddbanco := pr_cddbanco;
    vr_nmtitula := pr_nmtitula;
    vr_inpessoa := pr_inpessoa;
    vr_nrcpfcgc := pr_nrcpfcgc;
    vr_intipcta := pr_intipcta;
    
    -- Criar savepoint
    SAVEPOINT TRANS_INCLUI;
    BEGIN
      IF pr_intipdif = 1 THEN /** Conta do Sistema **/
        -- buscar dados da cooper
        OPEN cr_crapcop_age (pr_cdageban => pr_cdageban);
        
        FETCH cr_crapcop_age INTO rw_crapcop;
        
        IF cr_crapcop_age%NOTFOUND THEN
          vr_cdcritic := 651; -- Falta registro de controle da cooperativa - ERRO DE SISTEMA
          CLOSE cr_crapcop_age;
          RAISE vr_exec_inclui;
        END IF;
        CLOSE cr_crapcop_age;
            
        vr_cddbanco := rw_crapcop.cdbcoctl;
        vr_nmtitula := NULL;
        vr_inpessoa := 0 ;
        vr_nrcpfcgc := 0;
        vr_intipcta := 1;            
        
      ELSE
        -- buscar dados da cooper
        OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
        
        FETCH cr_crapcop INTO rw_crapcop;
        
        IF cr_crapcop%NOTFOUND THEN
          vr_cdcritic := 651; -- Falta registro de controle da cooperativa - ERRO DE SISTEMA
          CLOSE cr_crapcop;
          RAISE vr_exec_inclui;
        END IF;
        
        CLOSE cr_crapcop;
        
      END IF;
      
      -- Buscar dados associados
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
                      
      FETCH cr_crapass INTO rw_crapass;
      
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_cdcritic := 9; -- 009 - Associado nao cadastrado.
        RAISE vr_exec_inclui;
      END IF;
      
      CLOSE cr_crapass;
      
      IF rw_crapass.idastcjt = 1 THEN 
        OPEN cr_crapsnh(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta 
                       ,pr_idseqttl => NULL                      
                       ,pr_cdsitsnh => 1);
                       
      FETCH cr_crapsnh INTO rw_crapsnh;

      IF cr_crapsnh%NOTFOUND THEN
        CLOSE cr_crapsnh;
        vr_dscritic := 'Senha para conta on-line nao cadastrada';
        RAISE vr_exec_inclui;
      
          ELSE
          CLOSE cr_crapsnh;          
          vr_crapsnhFound:=TRUE;
        END IF;
        ELSE
        
        -- Verificar cadastro de senha
        OPEN cr_crapsnh (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_idseqttl => pr_idseqttl,
                         pr_cdsitsnh => 1); 
        
        FETCH cr_crapsnh INTO rw_crapsnh;
        
        IF cr_crapsnh%NOTFOUND THEN
                                      
          CLOSE cr_crapsnh;
          
          vr_dscritic := 'Senha para conta on-line nao cadastrada';
          RAISE vr_exec_inclui;
        ELSE
          CLOSE cr_crapsnh;
          vr_crapsnhFound:=TRUE;
          END IF;    
        
      END IF;

      IF pr_nrcpfope > 0 THEN
        -- Buscar dados do operador juridico 
        OPEN cr_crapopi (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_nrcpfope => pr_nrcpfope);
                         
        FETCH cr_crapopi INTO rw_crapopi;
        
        IF cr_crapopi%NOTFOUND THEN
          
          vr_dscritic := 'Registro de operador nao encontrado.';
          CLOSE cr_crapopi;
          RAISE vr_exec_inclui;
          
        END IF; 
        CLOSE cr_crapopi; 
      END IF;                  
      
      -- Verificar se ja existe registro
      OPEN cr_crapcti (pr_rowidcti => pr_rowidcti);
      
      FETCH cr_crapcti INTO rw_crapcti;
      
      IF cr_crapcti%NOTFOUND THEN  /* Novo Registro */
        CLOSE cr_crapcti;
        
        /* Verifica se existe um registro desativado
            com a mesma chave de tabela e na situacao
            pendente e desativado */
        -- Se o banco for 0 procura pelo ISPB
        IF pr_cddbanco = 0 THEN
          BEGIN
             DELETE crapcti
              WHERE crapcti.cdcooper = pr_cdcooper
                AND crapcti.nrdconta = pr_nrdconta
                AND crapcti.cddbanco = pr_cddbanco
                AND crapcti.nrispbif = pr_cdispbif
                AND crapcti.cdageban = pr_cdageban
                AND crapcti.nrctatrf = pr_nrctatrf
                AND crapcti.insitcta = 1 /* Pendente */
                AND crapcti.insitfav = 3; /* Removido pelo Cooperado */
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel excluir registro desativado.';
              RAISE vr_exec_inclui;     
          END ;    
        ELSE -- Busca somente pelo Banco
          BEGIN
             DELETE crapcti
              WHERE crapcti.cdcooper = pr_cdcooper
                AND crapcti.nrdconta = pr_nrdconta
                AND crapcti.cddbanco = pr_cddbanco
                AND crapcti.cdageban = pr_cdageban
                AND crapcti.nrctatrf = pr_nrctatrf
                AND crapcti.insitcta = 1 /* Pendente */
                AND crapcti.insitfav = 3; /* Removido pelo Cooperado */
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel excluir registro desativado.';
              RAISE vr_exec_inclui;     
          END ;  
        END IF;
        
        vr_nrseqcad := fn_sequence(pr_nmtabela => 'CRAPCTI'
                                  ,pr_nmdcampo => 'NRSEQCAD'
                                  ,pr_dsdchave => pr_cdcooper||';'||pr_nrdconta
                                  ,pr_flgdecre => 'N');
                                  
        -- inserir conta transferencia                          
        BEGIN
          INSERT INTO crapcti
                   ( crapcti.cdcooper
                    ,crapcti.nrdconta
                    ,crapcti.cdoperad
                    ,crapcti.dttransa
                    ,crapcti.hrtransa
                    ,crapcti.cddbanco
                    ,crapcti.cdageban
                    ,crapcti.nrctatrf
                    ,crapcti.nmtitula
                    ,crapcti.inpessoa
                    ,crapcti.nrcpfcgc
                    ,crapcti.insitcta
                    ,crapcti.insitfav
                    ,crapcti.intipdif
                    ,crapcti.intipcta
                    ,crapcti.nrseqcad
                    ,crapcti.nrispbif)
            VALUES ( pr_cdcooper               --> crapcti.cdcooper
                    ,pr_nrdconta               --> crapcti.nrdconta
                    ,pr_cdoperad               --> crapcti.cdoperad
                    ,trunc(SYSDATE)            --> crapcti.dttransa
                    ,gene0002.fn_busca_time    --> crapcti.hrtransa
                    ,vr_cddbanco               --> crapcti.cddbanco
                    ,pr_cdageban               --> crapcti.cdageban
                    ,pr_nrctatrf               --> crapcti.nrctatrf
                    ,UPPER(vr_nmtitula)         --> crapcti.nmtitula
                    ,vr_inpessoa               --> crapcti.inpessoa
                    ,vr_nrcpfcgc               --> crapcti.nrcpfcgc
                    ,2 /* Habilitado */        --> crapcti.insitcta
                    ,1 /* Novo Registro */     --> crapcti.insitfav
                    ,pr_intipdif               --> crapcti.intipdif
                    ,vr_intipcta               --> crapcti.intipcta
                    ,vr_nrseqcad               --> crapcti.nrseqcad
                    ,NVL(pr_cdispbif,0));             --> crapcti.dsprotoc
        EXCEPTION 
          WHEN DUP_VAL_ON_INDEX THEN
            vr_dscritic := 'Conta destino já cadastrada.';
            RAISE vr_exec_inclui;
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possivel inserir registro de tranferencia: '||SQLERRM;
            RAISE vr_exec_inclui; 
        END;
          
      END IF;
      
      IF vr_crapsnhFound THEN
        -- Verificar limites do cooperado
        IF pr_intipdif = 1       AND  
          ((rw_crapass.inpessoa = 1 AND rw_crapsnh.vllimweb = 0)  OR 
           (rw_crapass.inpessoa > 1 AND rw_crapsnh.vllimtrf = 0)) THEN
          pr_msgaviso := 'Cooperado nao possui limite para transferencia cadastrado.';
        ELSIF pr_intipdif = 2 AND rw_crapsnh.vllimted = 0  THEN
          pr_msgaviso := 'O cooperado ainda nao possui limite para TED cadastrado.';
        END IF;  
      END IF;    
      
      -- marcar como transação ok
      vr_flgtrans := TRUE;
      
    EXCEPTION
      WHEN vr_exec_inclui THEN
        ROLLBACK TO TRANS_INCLUI;
      WHEN OTHERS THEN
      
        vr_dscritic := 'Nao foi possivel efetuar o cadastro. '|| SQLERRM; 
        ROLLBACK TO TRANS_INCLUI; 
    END;
    
    -- caso não concluiu o cadastramento
    IF vr_flgtrans = FALSE THEN
      IF vr_cdcritic = 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := 'Nao foi possivel efetuar o cadastro.';
      END IF;          
                
      pr_dscritic := vr_dscritic;          
                
      --Se for para gerar log
      IF pr_flgerlog = 1 THEN
        --gerar log
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => trunc(SYSDATE)
                            ,pr_flgtrans => 0
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_rowid_craplgm);
      END IF; 
      
      pr_des_erro := 'NOK';
      
    ELSE
      -- Se concluiu com sucesso 
      -- Gerar log do novo registro na CRAPLAU
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => null
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> TRUE
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_rowid_craplgm);

      GENE0001.pc_grava_campos_log_item(pr_nmtabela => 'CRAPCTI'
                                       ,pr_rowidlgm => vr_rowid_craplgm
                                       ,pr_rowidtab => rw_crapcti.rowid
                                       ,pr_cdcritic => vr_dscritic
                                       ,pr_dscritic => vr_cdcritic); 
                                       
      GENE0001.pc_gera_log_item
                        (pr_nrdrowid => vr_rowid_craplgm
                        ,pr_nmdcampo => 'nrcpfope' 
                        ,pr_dsdadant => ' '
                        ,pr_dsdadatu => pr_nrcpfope);
                        
      GENE0001.pc_gera_log_item
                        (pr_nrdrowid => vr_rowid_craplgm
                        ,pr_nmdcampo => 'nrcpfpre' 
                        ,pr_dsdadant => ' '
                        ,pr_dsdadatu => rw_crapsnh.nrcpfcgc);                  
                                                          
    END IF;
    
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN OTHERS THEN
    
      vr_dscritic := 'Nao foi possivel efetuar o cadastro: '||SQLERRM;      
                
      pr_dscritic := vr_dscritic;
                                   
      --Se for para gerar log
      IF pr_flgerlog = 1 THEN
        --gerar log
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => SYSDATE
                            ,pr_flgtrans => 0
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_rowid_craplgm);
      END IF;
      
  END pc_inclui_conta_transf;
  
  -- Rotina para validacao de inclusao para conta de transferencia
  PROCEDURE pc_val_inclui_conta_transf(pr_cdcooper IN crapcop.cdcooper%TYPE               
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE
                                      ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE                
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE                
                                      ,pr_idorigem IN INTEGER
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE             
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                      ,pr_flgerlog IN INTEGER
                                      ,pr_cddbanco IN INTEGER
                                      ,pr_cdispbif IN INTEGER
                                      ,pr_cdageban IN INTEGER
                                      ,pr_nrctatrf IN crapcti.nrctatrf%TYPE
                                      ,pr_intipdif IN INTEGER
                                      ,pr_intipcta IN OUT INTEGER
                                      ,pr_insitcta IN INTEGER
                                      ,pr_inpessoa IN OUT INTEGER
                                      ,pr_nrcpfcgc IN OUT crapass.nrcpfcgc%TYPE             
                                      ,pr_flvldinc IN INTEGER                
                                      ,pr_rowidcti IN crapcti.progress_recid%TYPE
                                      ,pr_nmtitula IN OUT VARCHAR2
                                      ,pr_dscpfcgc OUT VARCHAR2
                                      ,pr_nmdcampo OUT VARCHAR2
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
    /* ..........................................................................
    
      Programa : Antigo /generico/procedures/b1wgen0015.p -> valida-inclusao-conta-transferencia
      Sistema  : Rotinas para validacao de inclusao de contas para transferencia
      Sigla    : CRED
      Autor    : Jean Michel
      Data     : Fevereiro/2016.                   Ultima atualizacao: 24/04/2018
    
      Dados referentes ao programa:
    
       Frequencia: Sempre que for chamado
       Objetivo  : Valida inclusao de contas para transferencias
    
       Alteracoes: 11/02/2016 - Conversão Progress >>> PL/SQL (Jean Michel)
    
	  		           11/11/2016 - Ajuste para efetuar log no arquivo internal_exception.log
  		                          (Adriano - SD 552561)
                                
                   20/03/2017 - Ajuste para validar o cpf/cnpj de acordo com o inpessoa informado             
                                (Adriano - SD 620221).
                                
                   08/06/2017 - Ajustes referentes ao novo catalogo do SPB (Lucas Ranghetti #668207)
                   
                   24/04/2018 - Normalizandos criticas para que busque apenas da tabela crapcri
                                tambem no "WHEN OTHERS THEN" para que nao mostre mais críticas
                                que o usuário não precise enxergar e então gravando em log. 
                                (SD 865935 - Kelvin)
     ...................................................................................*/

    -- CURSORES
  
    -- Selecionar os dados da Cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.cdcooper
            ,cop.nmrescop
            ,cop.nrtelura
            ,cop.cdbcoctl
            ,cop.cdagectl
            ,cop.dsdircop
            ,cop.nrctactl
            ,cop.nmextcop
            ,cop.nrdocnpj
      FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper
        AND cop.flgativo = 1;

    rw_crapcop cr_crapcop%ROWTYPE;

    --Registro do tipo calendario
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

    -- Cadastro de Transferencias pela Internet
    CURSOR cr_crapcti(pr_rowidcti IN crapcti.progress_recid%TYPE) IS
      SELECT cti.intipcta
            ,cti.inpessoa
            ,cti.nmtitula
            ,cti.nrcpfcgc
        FROM crapcti cti
       WHERE cti.progress_recid = pr_rowidcti;
    
    rw_crapcti cr_crapcti%ROWTYPE;
   
    -- Cadastro de Transferencias pela Internet II
    CURSOR cr_crapcti_2(pr_cdcooper IN crapcti.cdcooper%TYPE
                       ,pr_nrdconta IN crapcti.nrdconta%TYPE
                       ,pr_cddbanco IN crapcti.cddbanco%TYPE
                       ,pr_cdageban IN crapcti.cdageban%TYPE
                       ,pr_cdispbif IN crapcti.nrispbif%TYPE
                       ,pr_nrctatrf IN crapcti.nrctatrf%TYPE) IS
      SELECT cti.progress_recid
            ,cti.intipcta
            ,cti.inpessoa
            ,cti.nmtitula
            ,cti.nrcpfcgc
        FROM crapcti cti
       WHERE cti.cdcooper = pr_cdcooper
         AND cti.nrdconta = pr_nrdconta
         AND cti.cddbanco = pr_cddbanco
         AND cti.cdageban = pr_cdageban
         AND cti.nrispbif = pr_cdispbif
         AND cti.nrctatrf = pr_nrctatrf;

    rw_crapcti_2 cr_crapcti_2%ROWTYPE;

    -- Cadastro de Transferencias pela Internet III
    CURSOR cr_crapcti_3(pr_cdcooper IN crapcti.cdcooper%TYPE
                       ,pr_nrdconta IN crapcti.nrdconta%TYPE
                       ,pr_cddbanco IN crapcti.cddbanco%TYPE
                       ,pr_cdageban IN crapcti.cdageban%TYPE
                       ,pr_cdispbif IN crapcti.nrispbif%TYPE
                       ,pr_nrctatrf IN crapcti.nrctatrf%TYPE) IS

     SELECT cti.cdcooper
           ,cti.nrdconta
           ,cti.cddbanco
       FROM crapcti cti
      WHERE cti.cdcooper = pr_cdcooper
        AND cti.nrdconta = pr_nrdconta
        AND cti.cddbanco = pr_cddbanco
        AND cti.cdageban = pr_cdageban
        AND cti.nrctatrf = pr_nrctatrf
        AND (cti.nrispbif = pr_cdispbif OR pr_cdispbif IS NULL)
        AND cti.insitfav <> 3; -- Desativado

    rw_crapcti_3 cr_crapcti_3%ROWTYPE;
            
    -- Consulta de banco
    CURSOR cr_crapban(pr_cddbanco IN crapban.cdbccxlt%TYPE
                     ,pr_cdispbif IN crapban.nrispbif%TYPE) IS
     SELECT ban.cdbccxlt
           ,ban.nrispbif
       FROM crapban ban
      WHERE (ban.cdbccxlt = pr_cddbanco OR pr_cddbanco IS NULL) OR
            (ban.nrispbif = pr_cdispbif OR pr_cdispbif IS NULL);
           
    rw_crapban cr_crapban%ROWTYPE;

    CURSOR cr_crapcop_2(pr_cdagectl IN crapcop.cdagectl%TYPE) IS

     SELECT cop.cdcooper
           ,cop.cdbcoctl 
       FROM crapcop cop
      WHERE cop.cdagectl = pr_cdagectl;

     rw_crapcop_2 cr_crapcop_2%ROWTYPE;

    -- Consultar dados dos cooperados
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS

     SELECT ass.dtdemiss
           ,ass.inpessoa
           ,ass.nmprimtl
           ,ass.nrcpfcgc
       FROM crapass ass
      WHERE ass.cdcooper = pr_cdcooper
        AND ass.nrdconta = pr_nrdconta;

     rw_crapass cr_crapass%ROWTYPE;   
 
    -- Consultar dados dos titulares das contas
    CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE 
                     ,pr_nrdconta IN crapttl.nrdconta%TYPE
                     ,pr_idseqttl IN crapttl.idseqttl%TYPE) IS

     SELECT ttl.cdcooper
           ,ttl.nmextttl
           ,ttl.nrcpfcgc
       FROM crapttl ttl
      WHERE ttl.cdcooper = pr_cdcooper
        AND ttl.nrdconta = pr_nrctatrf
        AND ttl.idseqttl = pr_idseqttl;

     rw_crapttl cr_crapttl%ROWTYPE;
    
    -- VARIAVEIS

    -- Variaveis de Erros
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_exc_saida EXCEPTION;

    -- Variaveis gerais
    vr_stsnrcal BOOLEAN;
    vr_flsitreg BOOLEAN;
    vr_cddbanco INTEGER := pr_cddbanco;
    vr_cdispbif NUMBER;
    vr_dstextab craptab.dstextab%TYPE;    

    -- Variaveis de LOG
    vr_dstransa VARCHAR2(100) := 'Valida Inclusao de Conta para Transferencia.';
    vr_dsorigem VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_idorigem);
                           
  BEGIN
   
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      
    FETCH cr_crapcop INTO rw_crapcop;
      
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      vr_cdcritic:= 651;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Verifica se a cooperativa esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;

    -- Verifica se o registro eh novo ou uma atualizacao
    -- no dados cadastrais de favorecido
    IF pr_rowidcti IS NULL OR pr_rowidcti = 0 THEN
      vr_flsitreg := TRUE;  -- Novo Registro
    ELSE
      vr_flsitreg := FALSE; -- Atualizacao Registro
    END IF;

    IF pr_intipdif = 1  THEN -- Cooperativa
      vr_cddbanco := rw_crapcop.cdbcoctl;
    END IF;

    -- Verifica se o registro informado n tela esta sendo editado ou incluido
    OPEN cr_crapcti(pr_rowidcti);

    FETCH cr_crapcti INTO rw_crapcti;

    IF cr_crapcti%FOUND THEN
      OPEN cr_crapcti_2(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_cddbanco => vr_cddbanco
                       ,pr_cdageban => pr_cdageban
                       ,pr_cdispbif => pr_cdispbif
                       ,pr_nrctatrf => pr_nrctatrf);

      FETCH cr_crapcti_2 INTO rw_crapcti_2;

      -- Se as informacoes da tela for encotrada,
      -- foi encontrado um registro com as informacoes da tela (Registro B) ou 
      -- se trata do mesmo registro que esta sendo editado (Registro A)
      IF cr_crapcti_2%FOUND THEN
        -- Verifica se o restante do registro a ser editado
        -- esta cadastrado na base com as informacoes da tela
        IF rw_crapcti_2.intipcta        = pr_intipcta        AND
           rw_crapcti_2.inpessoa        = pr_inpessoa        AND
           UPPER(rw_crapcti_2.nmtitula) = UPPER(pr_nmtitula) AND
           rw_crapcti_2.nrcpfcgc        = pr_nrcpfcgc       THEN
           
          -- O Registro esta totalmente igual, gerar critica
          vr_cdcritic := 979;   
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          pr_nmdcampo := 'nrctatrf';
          CLOSE cr_crapcti_2;
          CLOSE cr_crapcti;
          RAISE vr_exc_saida;
        
        ELSE
          -- Os campos que nao compoem a chave da tabela foram alterados,
          -- porem a chave da tabela informada na tela ja existe na base.
          -- Gerar critica.

          IF pr_rowidcti <> rw_crapcti_2.progress_recid THEN
          
            vr_cdcritic := 979;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            pr_nmdcampo := 'nrctatrf';
            CLOSE cr_crapcti_2;
            CLOSE cr_crapcti;
            RAISE vr_exc_saida;

          END IF;
        END IF;

      END IF; -- IF FOUND cr_crapcti_2
      CLOSE cr_crapcti_2;

    END IF; -- IF FOUND cr_crapcti

    CLOSE cr_crapcti;

    -- Se o banco for 0 procura pelo ISPB
    IF vr_cddbanco = 0 THEN
      -- Verifica se já existe conta na tabela, utilizando o campo ISPB
		  vr_cdispbif := pr_cdispbif;
    ELSE
		  -- Cadastros de favorecido efetuados na base antes da inclusao do 
      -- campo ISPB, encontram-se com crapcti.nrispbif = 0. Sendo assim,
      -- nao devera utiliza-lo nesta validacao      
      vr_cdispbif := NULL;
    END IF;

    -- Validaçao para conta da cooperativa
    -- Validação é realizada antes do controle de conta já cadastrada para capturar os dados da conta
    -- Os dados serão apresentados junto a mensagem de alerta de conta já cadastrada. 
    IF pr_intipdif = 1 THEN
              
      IF pr_nrdconta = TO_NUMBER(pr_nrctatrf) AND 
         pr_cdageban = rw_crapcop.cdagectl   THEN
        vr_cdcritic := 564;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        pr_nmdcampo := 'nrctatrf';
        RAISE vr_exc_saida;
      END IF;

      OPEN cr_crapcop_2(pr_cdagectl => pr_cdageban);
             
      FETCH cr_crapcop_2 INTO rw_crapcop_2;

      IF cr_crapcop_2%NOTFOUND THEN
        vr_cdcritic := 1070;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        pr_nmdcampo := 'nmrescop';
        CLOSE cr_crapcop_2;
        RAISE vr_exc_saida;
      END IF;

      CLOSE cr_crapcop_2;

      IF rw_crapcop_2.cdcooper = 3 THEN -- CECRED
        vr_cdcritic := 1214;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      END IF;
      
      -- Consulta registro de associado
      OPEN cr_crapass(pr_cdcooper => rw_crapcop_2.cdcooper
                     ,pr_nrdconta => TO_NUMBER(pr_nrctatrf));

      FETCH cr_crapass INTO rw_crapass;
               
      IF cr_crapass%NOTFOUND THEN
        pr_nmdcampo := 'nrctatrf';
        vr_cdcritic := 9;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      END IF;
      
      CLOSE cr_crapass;

      -- Verifica se cooperado e demitido
      IF rw_crapass.dtdemiss IS NOT NULL THEN
        vr_cdcritic := 75;
        pr_nmdcampo := 'nrctatrf';
        RAISE vr_exc_saida;
      END IF;

      -- Verifica tipo de pessoa
      IF rw_crapass.inpessoa = 1 THEN
        
        pr_inpessoa := 1;
        pr_intipcta := 1;
                  
        OPEN cr_crapttl(pr_cdcooper => rw_crapcop_2.cdcooper
                       ,pr_nrdconta => pr_nrctatrf
                       ,pr_idseqttl => 1);

        FETCH cr_crapttl INTO rw_crapttl;        
        
        IF cr_crapttl%FOUND THEN
          pr_nmtitula := rw_crapttl.nmextttl;
          pr_nrcpfcgc := rw_crapttl.nrcpfcgc;
          pr_dscpfcgc := gene0002.fn_mask_cpf_cnpj(rw_crapttl.nrcpfcgc,1);
        ELSE
          pr_nmtitula := rw_crapass.nmprimtl;
          pr_nrcpfcgc := rw_crapass.nrcpfcgc;
          pr_dscpfcgc := gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc,1);
        END IF;
        
        CLOSE cr_crapttl;
      ELSE
        pr_inpessoa := 2;
        pr_intipcta := 1;
        pr_nmtitula := rw_crapass.nmprimtl;
        pr_nrcpfcgc := rw_crapass.nrcpfcgc;  
        pr_dscpfcgc := gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc,2);  
      END IF;                                 
    END IF;

    OPEN cr_crapcti_3(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_cddbanco => pr_cddbanco
                     ,pr_cdageban => pr_cdageban
                     ,pr_cdispbif => vr_cdispbif
                     ,pr_nrctatrf => pr_nrctatrf);

    FETCH cr_crapcti_3 INTO rw_crapcti_3;

    -- Se for um novo registro
    IF cr_crapcti_3%FOUND AND
       pr_flvldinc = 1    AND
       vr_flsitreg        THEN
      vr_cdcritic := 979;  
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      pr_nmdcampo := 'nrctatrf';
      CLOSE cr_crapcti_3;
      RAISE vr_exc_saida;
    END IF;

    CLOSE cr_crapcti_3;

    -- Validaçao para conta de outras IFs
    IF pr_intipdif <> 1 THEN
      IF pr_cddbanco = 85 THEN
        vr_cdcritic := 1215;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        pr_nmdcampo := 'cddbanco';
        RAISE vr_exc_saida;
      END IF;

      -- Valida Banco
      IF pr_cdispbif = 0 AND
         pr_cddbanco > 0 THEN
        vr_cddbanco := pr_cddbanco;
        vr_cdispbif := NULL;
      ELSE
        vr_cddbanco := NULL;
        vr_cdispbif := pr_cdispbif;
      END IF;
         
      -- Consulta codigo de banco
      OPEN cr_crapban(pr_cddbanco => vr_cddbanco
                     ,pr_cdispbif => vr_cdispbif);

      FETCH cr_crapban INTO rw_crapban;

      -- Verifica se encontrou algum registro
      IF cr_crapban%NOTFOUND  THEN
        vr_cdcritic := 057;
        pr_nmdcampo := 'cddbanco';
        CLOSE cr_crapban;
        RAISE vr_exc_saida;
      END IF;

      -- Fecha cursor
      CLOSE cr_crapban;             

      -- 1 Conta Corrente / 2 Conta Poupanca
      IF pr_intipcta IN(1,2) THEN
      -- Verifica se conta para transferencia e valida
      IF LENGTH(TRIM(TO_CHAR(pr_nrctatrf))) < 2  OR 
         LENGTH(TRIM(TO_CHAR(pr_nrctatrf))) > 13 THEN
          vr_cdcritic := 1216;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          pr_nmdcampo := 'nrctatrf';
          RAISE vr_exc_saida;
        END IF;
      ELSE -- 3 Conta de Pagamento
        IF LENGTH(TRIM(TO_CHAR(pr_nrctatrf))) < 2  OR 
           LENGTH(TRIM(TO_CHAR(pr_nrctatrf))) > 20 THEN
          vr_cdcritic := 1217;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          pr_nmdcampo := 'nrctatrf';
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Verifica o tipo de pessoa
      IF pr_inpessoa < 1 OR 
         pr_inpessoa > 2  THEN
        vr_cdcritic := 1218;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        pr_nmdcampo := 'inpessoa';
        vr_cdcritic := 0;
      END IF;
         
      -- Valida o nome do titular         
      IF NOT gene0005.fn_valida_nome(pr_nomedttl => pr_nmtitula
                                    ,pr_inpessoa => pr_inpessoa
                                    ,pr_des_erro => vr_dscritic) THEN
        vr_cdcritic := 0;                            
        vr_dscritic := vr_dscritic;     
        pr_nmdcampo := 'nmtitula';
        RAISE vr_exc_saida;
      END IF;

      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_crapcop.cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 00
                                               ,pr_cdacesso => 'TPCTACRTED'
                                               ,pr_tpregist => pr_intipcta);

      IF vr_dstextab IS NULL THEN
        vr_cdcritic := 17;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        pr_nmdcampo := 'intipcta';
        RAISE vr_exc_saida;
      END IF;
      
      /*** Validação para que somente os tipos de contas "Conta Corrente" e "Poupança"
          obriguem o preenchimento do campo Agencia. O tipo de conta "Conta de
          Pagamento" não deve permitir preenhcimento do campo Agencia. ***/
      IF pr_cdageban = 0 OR pr_cdageban IS NULL THEN
        IF pr_intipcta IN(1,2) THEN
          vr_cdcritic := 1219;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' '|| vr_dstextab;
          pr_nmdcampo := 'intipcta';
          RAISE vr_exc_saida;
        END IF;
      ELSE
        IF pr_intipcta = 3 THEN -- Conta de Pagamento
          vr_cdcritic := 1219;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' '|| vr_dstextab;
          pr_nmdcampo := 'intipcta';
          RAISE vr_exc_saida;
        END IF;
      END IF;

      IF pr_inpessoa = 1 THEN 
        -- Valida CPF enviado
        GENE0005.pc_valida_cpf(pr_nrcalcul => pr_nrcpfcgc   --Numero a ser verificado
                              ,pr_stsnrcal => vr_stsnrcal);   --Situacao
        
      IF NOT vr_stsnrcal THEN
        vr_cdcritic := 1220;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        pr_nmdcampo := 'nrcpfcgc';
        RAISE vr_exc_saida;
      END IF;
      ELSE
        -- Valida CPF/CNPJ enviado
        GENE0005.pc_valida_cnpj(pr_nrcalcul => pr_nrcpfcgc   --Numero a ser verificado
                               ,pr_stsnrcal => vr_stsnrcal);   --Situacao
          
        IF NOT vr_stsnrcal THEN
          vr_cdcritic := 1221;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          pr_nmdcampo := 'nrcpfcgc';
          RAISE vr_exc_saida;
        END IF;
      END IF;
      END IF;

    IF pr_insitcta < 1  OR
       pr_insitcta > 3  THEN      
      vr_cdcritic := 018;   
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      pr_nmdcampo := 'nrctatrf';
      RAISE vr_exc_saida;
    END IF;
        
    EXCEPTION
			WHEN vr_exc_saida THEN
				
        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				END IF;

			  -- Alimenta parametros com as críticas
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
        COMMIT;

      WHEN OTHERS THEN

        --Gera log e passa uma crítica padrão para frente para ser apresentado no internetbank/mobile.
        btch0001.pc_log_internal_exception(pr_cdcooper => pr_cdcooper);
        
        pr_cdcritic := 0;
        pr_dscritic := gene0001.fn_busca_critica(9999) || ' Nao foi possivel validar os dados.';
        
        ROLLBACK;

  END pc_val_inclui_conta_transf; 

  PROCEDURE pc_bloqueia_operadores(pr_dscritic OUT crapcri.dscritic%TYPE) IS  
  /* .............................................................................

     Programa: pc_bloqueia_operadores
     Sistema : Rotina acessada através de job
     Autor   : Kelvin Ott       
     Data    : Novembro/2017.                  Ultima atualizacao: 25/07/2019

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina chamada por job para bloquiar os operadores na tabela crapope que nao 
                 constam na tabela tbcadast_colaborador

     Alteracoes: 19/11/2018 - Alterando o local onde era gerado log de inativação. (SCTASK0034898 - Kelvin)                
	 
	             25/07/2019 - Incluido tratamento no cursor cr_valida_cecred para considerar
				              operadores da Corretora Ailos (PRJ519 - Diego).            
    ..............................................................................*/ 
    CURSOR cr_crapope IS        
      SELECT cdoperad
            ,cdcooper
        FROM crapope ope
       WHERE (TRIM(upper(ope.cdoperad)) LIKE UPPER('e%')
          OR TRIM(upper(ope.cdoperad)) LIKE UPPER('f%'))
         AND length(ope.cdoperad) = 8          
         AND ope.cdsitope = 1;
         
    CURSOR cr_tbcadast_colaborador(pr_cdcooper crapcop.cdcooper%TYPE
                                  ,pr_cdoperad crapope.cdoperad%TYPE) IS
      SELECT 1 retorno
        FROM tbcadast_colaborador col
       WHERE col.cdcooper = pr_cdcooper
         AND UPPER(col.cdusured) = UPPER(pr_cdoperad)
         AND col.flgativo = 'A'; --Ativo         
    rw_tbcadast_colaborador cr_tbcadast_colaborador%ROWTYPE;
    
    CURSOR cr_valida_cecred(pr_cdoperad crapope.cdoperad%TYPE) IS
      SELECT 1 retorno
        FROM tbcadast_colaborador col
       WHERE upper(col.cdusured) = upper(pr_cdoperad)
         AND (col.cdcooper = 3  OR col.cdcooper = 901)
         AND col.flgativo = 'A';
    
    rw_valida_cecred cr_valida_cecred%ROWTYPE;
    
    --Variaveis auxiliares
    vr_idprglog NUMBER;
  
    --Variaveis de excecoes
    vr_exc_error EXCEPTION;
                  
  BEGIN
                
    CECRED.pc_log_programa(pr_dstiplog => 'I'
                         , pr_cdprograma => 'JBOPE_BLOQUEIA_OPERADORES'                                
                         , pr_idprglog => vr_idprglog);

    --Busca todos os operadores ativos
    FOR rw_crapope IN cr_crapope LOOP

      --Verifica se o operador esta na tbcadast_colaborador
      OPEN cr_tbcadast_colaborador(pr_cdcooper => rw_crapope.cdcooper
                                  ,pr_cdoperad => rw_crapope.cdoperad);
        FETCH cr_tbcadast_colaborador
          INTO rw_tbcadast_colaborador;

      --Caso esse operador nao esteja na tabela TBCADAST_COLABORADOR devera ser inativado
      IF cr_tbcadast_colaborador%NOTFOUND THEN 
        CLOSE cr_tbcadast_colaborador;         

        /*Valida se o operador é da cecred pois caso for deverá manter o operador ativo
        em outras cooperativas*/          
        OPEN cr_valida_cecred(pr_cdoperad => rw_crapope.cdoperad);
          FETCH cr_valida_cecred
            INTO rw_valida_cecred;

        --Nao e CECRED ou está inativo
        IF cr_valida_cecred%NOTFOUND THEN
          CLOSE cr_valida_cecred;                       
          --Inativa operador
          BEGIN 
            UPDATE crapope ope
               SET ope.cdsitope = 2
             WHERE ope.cdcooper = rw_crapope.cdcooper
               AND UPPER(ope.cdoperad) = UPPER(rw_crapope.cdoperad);

          -- Log de sucesso.
          CECRED.pc_log_programa(pr_dstiplog => 'O'
                               , pr_cdprograma => 'JBOPE_BLOQUEIA_OPERADORES' 
                               , pr_cdcooper => rw_crapope.cdcooper
                               , pr_tpexecucao => 0
                               , pr_tpocorrencia => 4 
                               , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || 
                                                  ' - CADA0002 --> Operador inativado com sucesso na rotina pc_bloqueia_operadores. Detalhes: Operador - ' ||
                                                  rw_crapope.cdoperad || ' Cooperativa - ' || rw_crapope.cdcooper
                               , pr_idprglog => vr_idprglog);                      
          EXCEPTION
            WHEN OTHERS THEN
              RAISE vr_exc_error;
          END;
        --E CECRED
        ELSE
          CLOSE cr_valida_cecred;  
            --Ativa operador
            BEGIN 
              UPDATE crapope ope
                 SET ope.cdsitope = 1
               WHERE UPPER(ope.cdoperad) = UPPER(rw_crapope.cdoperad)
                 AND ope.cdcooper = rw_crapope.cdcooper;

            EXCEPTION
              WHEN OTHERS THEN
                RAISE vr_exc_error;
            END;
        END IF;

          -- Log de sucesso.
          CECRED.pc_log_programa(pr_dstiplog => 'O'
                               , pr_cdprograma => 'JBOPE_BLOQUEIA_OPERADORES' 
                               , pr_cdcooper => rw_crapope.cdcooper
                               , pr_tpexecucao => 0
                               , pr_tpocorrencia => 4 
                               , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || 
                                                  ' - CADA0002 --> Operador inativado com sucesso na rotina pc_bloqueia_operadores. Detalhes: Operador - ' ||
                                                  rw_crapope.cdoperad || ' Cooperativa - ' || rw_crapope.cdcooper
                               , pr_idprglog => vr_idprglog);                      


      ELSE
        CLOSE cr_tbcadast_colaborador;
      END IF;
        
                
				
    END LOOP;

    CECRED.pc_log_programa(pr_dstiplog => 'F'
                         , pr_cdprograma => 'JBOPE_BLOQUEIA_OPERADORES'                                
                         , pr_idprglog => vr_idprglog);
        
    COMMIT;

  EXCEPTION
    WHEN vr_exc_error THEN

      pr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - CADA0002 --> Erro ao atualzar a tabela crapope na rotina pc_bloqueia_operadores. Detalhes: ' || SQLERRM;
        
      CECRED.pc_log_programa(pr_dstiplog => 'O'
                           , pr_cdprograma => 'JBOPE_BLOQUEIA_OPERADORES' 
                           , pr_cdcooper => 0
                           , pr_tpexecucao => 0
                           , pr_tpocorrencia => 2
                           , pr_dsmensagem => pr_dscritic                                                
                           , pr_idprglog => vr_idprglog);  
        
        ROLLBACK;
    WHEN OTHERS THEN      
      --Gera log
      cecred.pc_internal_exception(pr_cdcooper => 0);

      pr_dscritic := 'Erro nao tratado na CADA0002.pc_bloqueia_operadores: ' || SQLERRM;

      ROLLBACK;
  END pc_bloqueia_operadores;
END CADA0002;
/
