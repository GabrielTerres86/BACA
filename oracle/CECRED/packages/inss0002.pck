CREATE OR REPLACE PACKAGE CECRED.INSS0002 AS

   /*---------------------------------------------------------------------------------------------------------------

   Programa : INSS0002
   Autor    : Dionathan
   Data     : 27/08/2015                        Ultima atualizacao: 08/12/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : GPS

   ATENÇÃO: Manter hisórico de alterações apenas no header

   Alterações: 25/11/2015 - Removida da pc_gps_arrecadar_sicredi a validação da data do dia
                            (Guilherme/SUPERO)

               22/03/2016 - A tag "v15:DataVencimento" deve enviar a data do dia, e não mais a
                            Data do Vencimento da Guia GPS, conforme orientação do SICREDI
                            Chamado 421994 (Guilherme/SUPERO)

               03/05/2016 - Alterada pc_gps_agmto_novo para passar TRUE no "pr_flgagend" na chamada da
							pc_gera_protocolo_md5 (Guilherme/SUPERO)

               17/05/2016 - SD451205 - (pc_gps_validar_sicredi) Definir dtdebito da LAU quando cancelar Agendamento GPS
                              (pc_gps_validar_sicredi-INET0001) Passar a Data Débito ao invés de Data Vencimento na validação de limites
                            SD453520 - (pc_gps_pagamento) Utilizar data dtmvtocd ao inves de dtmvtolt e dtmvtopr
                            (Guilherme/SUPERO)

               27/05/2016 - SD456783 - Corrigida a linha digitável da LAU quando vindo por Leitora de Cod Barras
                            Retirada validação de Data Agendamento quando apenas validação (Guilherme/SUPERO)
  
               22/06/2016 - Alterada a pasta de gravacao do arquivo XML de salvar/ para salvar/gps/
							Correcao do parametro passado para a pc_verifica_operacao informando que
                            trata-se de um agendamento ou pagamento (Guilherme/SUPERO)
                            
               23/06/2016 - Correcao no cursor da crapbcx utilizando o indice correto
                            sobre o campo cdopecxa.(Carlos Rafael Tanholi).       

               03/08/2016 - Alteração na nomenclatura dos nomes dos XMLs de comunicação com o
                            Sicredi, adicionado os milisecundos (Guilherme/SUPERO)

               05/09/2016 - SD 514294 - Alterar as rotinas PC_GPS_VALIDAR_SICREDI e
                            PC_GPS_ARRECADAR_SICREDI para formar a nova nomenclatura
                            para os arquivos do GPS, possibilitando a busca e download
                            dos mesmos.   (Renato Darosci - SUPERO)

               05/09/2016 - SD 490844 - Removido o código que limpava a variável
                            vr_cdlindig quando o agendamento era feito pelo código
                            de barras (procedure pc_gps_agmto_novo). (Carlos)

               26/09/2016 - SD 524122 - Ajuste no sequencial enviado no XML para  o SICREDI,
                            nrautsic, para utilizar uma nova Sequence (Guilherme/SUPERO)
                            SD 531444 - pc_gps_arquivo_download - Alterada a forma de
                            listar os arquivos da pasta de pc_lista_arquivos para pc_OScommand_Shell
                            (Guilherme/SUPERO)

               08/12/2016 - Implementacao do controle de lock correto sobre as tabelas craplot e crapbcx
                            nas procedures envolvidas com o pagamento da guia de previdencia social.
                            SD 560911 - (Carlos Rafael Tanholi)
  --------------------------------------------------------------------------------------------------------------- */
  PROCEDURE pc_gps_validar_sicredi(pr_cdcooper IN crapcop.cdcooper %TYPE
                                  ,pr_cdagenci IN NUMBER
                                  ,pr_nrdcaixa IN VARCHAR2
                                  ,pr_idorigem IN NUMBER
                                  ,pr_dtmvtolt IN DATE
                                  ,pr_nmdatela IN VARCHAR2
                                  ,pr_cdoperad IN VARCHAR2
                                  ,pr_inproces IN NUMBER
                                  ,pr_idleitur IN NUMBER
                                  ,pr_cddpagto IN VARCHAR2
                                  ,pr_cdidenti IN VARCHAR2
                                  ,pr_dtvencto IN DATE
                                  ,pr_cdbarras IN VARCHAR2
                                  ,pr_dslindig IN VARCHAR2
                                  ,pr_mmaacomp IN VARCHAR2
                                  ,pr_vlrdinss IN NUMBER
                                  ,pr_vlrouent IN NUMBER
                                  ,pr_vlrjuros IN NUMBER
                                  ,pr_vlrtotal IN NUMBER
                                  ,pr_idseqttl IN NUMBER
                                  ,pr_tpdpagto IN NUMBER -- (1 - com cod.barra, 2 - sem cod.barra)
                                  ,pr_nrdconta IN NUMBER
                                  ,pr_inpesgps IN NUMBER
                                  ,pr_indpagto IN VARCHAR2
                                  ,pr_nrseqagp IN NUMBER
                                  ,pr_nrcpfope crapopi.nrcpfope%TYPE DEFAULT NULL
                                  ,pr_dslitera OUT VARCHAR2
                                  ,pr_sequenci OUT NUMBER
                                  ,pr_nrseqaut OUT NUMBER
                                  ,pr_cdcritic OUT PLS_INTEGER -- Código da crítica
                                  ,pr_dscritic OUT VARCHAR2 -- Descrição da crítica
                                  ,pr_des_reto OUT VARCHAR2 -- Saida OK/NOK
                                   );

  PROCEDURE pc_gps_arrecadar_sicredi(pr_cdcooper IN crapcop.cdcooper%TYPE
                                    ,pr_cdagenci IN NUMBER
                                    ,pr_nrdcaixa IN VARCHAR2
                                    ,pr_idorigem IN NUMBER
                                    ,pr_dtmvtolt IN DATE
                                    ,pr_nmdatela IN VARCHAR2
                                    ,pr_cdoperad IN VARCHAR2
                                    ,pr_inproces IN NUMBER
                                    ,pr_idleitur IN NUMBER
                                    ,pr_cddpagto IN VARCHAR2
                                    ,pr_cdidenti IN VARCHAR2
                                    ,pr_dtvencto IN DATE
                                    ,pr_cdbarras IN VARCHAR2
                                    ,pr_dslindig IN VARCHAR2
                                    ,pr_mmaacomp IN VARCHAR2
                                    ,pr_vlrdinss IN NUMBER
                                    ,pr_vlrouent IN NUMBER
                                    ,pr_vlrjuros IN NUMBER
                                    ,pr_vlrtotal IN NUMBER
                                    ,pr_idseqttl IN NUMBER
                                    ,pr_tpdpagto IN NUMBER -- (1 - com cod.barra, 2 - sem cod.barra)
                                    ,pr_nrdconta IN NUMBER
                                    ,pr_inpesgps IN NUMBER
                                    ,pr_nrseqagp IN NUMBER
                                    ,pr_dslitera OUT VARCHAR2
                                    ,pr_sequenci OUT NUMBER
                                    ,pr_nrseqaut OUT NUMBER
                                    ,pr_cdcritic OUT PLS_INTEGER -- Código da crítica
                                    ,pr_dscritic OUT VARCHAR2 -- Descrição da crítica
                                    ,pr_des_reto OUT VARCHAR2 -- Saida OK/NOK
                                     );

  /*---------------------------------------------------------------------------------------------------------------
   Autor    : Renato Darosci - Supero
   Objetivo : GPS - Consultar os dados de agentamentos do GPS
  ---------------------------------------------------------------------------------------------------------------*/
  PROCEDURE pc_gps_agmto_consulta(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                 ,pr_nrdconta   IN NUMBER
                                 ,pr_idorigem   IN NUMBER
                                 ,pr_cdoperad   IN crapope.cdoperad%TYPE
                                 ,pr_nmdatela   IN craptel.nmdatela%TYPE
                                 ,pr_cdcritic  OUT PLS_INTEGER -- Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2
                                 ,pr_retxml    OUT CLOB);


  /*---------------------------------------------------------------------------------------------------------------
   Autor    : Renato Darosci - Supero
   Objetivo : GPS - Realizar os cancelamentos de Agendamento de GPS
  ---------------------------------------------------------------------------------------------------------------*/
  PROCEDURE pc_gps_agmto_desativar(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                  ,pr_nrdconta   IN NUMBER
                                  ,pr_idorigem   IN NUMBER
                                  ,pr_cdoperad   IN crapope.cdoperad%TYPE
                                  ,pr_nmdatela   IN craptel.nmdatela%TYPE
                                  ,pr_dsdrowid   IN VARCHAR2
								  ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE --397
                                  ,pr_dscritic  OUT VARCHAR2);


  /*---------------------------------------------------------------------------------------------------------------
   Autor    : Renato Darosci - Supero
   Objetivo : GPS - Realizar a gravação dos Agendamentos de GPS
  ---------------------------------------------------------------------------------------------------------------*/
  PROCEDURE pc_gps_agmto_novo(pr_cdcooper   IN NUMBER
                             ,pr_nrdconta   IN NUMBER
                             ,pr_tpdpagto   IN NUMBER
                             ,pr_cdagenci   IN NUMBER
                             ,pr_nrdcaixa   IN NUMBER
                             ,pr_idseqttl   IN NUMBER
                             ,pr_idorigem   IN NUMBER
                             ,pr_cdoperad   IN VARCHAR2
                             ,pr_nmdatela   IN VARCHAR2
                             ,pr_idleitur   IN NUMBER   -- Indica se os campos vieram via Leitura Laser(1) ou Manual(0)
                             ,pr_cdbarras   IN VARCHAR2
                             ,pr_cdlindig   IN VARCHAR2
                             ,pr_cdpagmto   IN NUMBER
                             ,pr_dtcompet   IN VARCHAR2 -- Recebe como string e trata no programa
                             ,pr_dsidenti   IN VARCHAR2 -- Recebe como char para prese
                             ,pr_vldoinss   IN NUMBER
                             ,pr_vloutent   IN NUMBER
                             ,pr_vlatmjur   IN NUMBER
                             ,pr_vlrtotal   IN NUMBER
                             ,pr_dtvencim   IN VARCHAR2 -- Recebe como string e trata no programa
                             ,pr_inpesgps   IN NUMBER
                             ,pr_dtdebito   IN VARCHAR2 -- Recebe como string e trata no programa
                             ,pr_nrcpfope   IN crapopi.nrcpfope%TYPE DEFAULT 0	-- 397
                             ,pr_dslitera  OUT CLOB
                             ,pr_cdultseq  OUT NUMBER
                             ,pr_dscritic  OUT VARCHAR2);

  /*---------------------------------------------------------------------------------------------------------------
   Autor    : Andre Santos/SUPERO
   Objetivo : GPS - Efetuar pagamento de GPS
  ---------------------------------------------------------------------------------------------------------------*/
   PROCEDURE pc_gps_pagamento(pr_cdcooper   IN NUMBER
                             ,pr_nrdconta   IN NUMBER
                             ,pr_cdagenci   IN NUMBER
                             ,pr_nrdcaixa   IN NUMBER
                             ,pr_idseqttl   IN NUMBER
                             ,pr_tpdpagto   IN NUMBER
                             ,pr_idorigem   IN NUMBER
                             ,pr_cdoperad   IN VARCHAR2
                             ,pr_nmdatela   IN VARCHAR2
                             ,pr_idleitur   IN NUMBER   -- Indica se os campos vieram via Leitura Laser(1) ou Manual(0)
                             ,pr_inproces   IN NUMBER
                             ,pr_cdbarras   IN VARCHAR2
                             ,pr_sftcdbar   IN VARCHAR2
                             ,pr_cdpagmto   IN NUMBER
                             ,pr_dtcompet   IN VARCHAR2 -- Recebe como string e trata no programa
                             ,pr_dsidenti   IN VARCHAR2 -- Recebe como char para prese
                             ,pr_vldoinss   IN NUMBER
                             ,pr_vloutent   IN NUMBER
                             ,pr_vlatmjur   IN NUMBER
                             ,pr_vlrtotal   IN NUMBER
                             ,pr_dtvencim   IN VARCHAR2 -- Recebe como string e trata no programa
                             ,pr_inpesgps   IN NUMBER
                             ,pr_nrseqagp   IN NUMBER
                             ,pr_nrcpfope   IN crapopi.nrcpfope%TYPE DEFAULT 0 -- 397
                             ,pr_dslitera  OUT VARCHAR2
                             ,pr_cdultseq  OUT NUMBER
                             ,pr_dscritic  OUT VARCHAR2);


  /*---------------------------------------------------------------------------------------------------------------
   Autor    : Renato Darosci - Supero
   Objetivo : GPS - Consultar os dados da cooperativa para o sistema GPS
  ---------------------------------------------------------------------------------------------------------------*/
  PROCEDURE pc_gps_cooperativa(pr_cdcooper   IN crapcop.cdcooper%TYPE
                              ,pr_nrdconta   IN crapass.nrdconta%TYPE
                              ,pr_dscritic  OUT VARCHAR2
                              ,pr_retxml    OUT CLOB);



  /*---------------------------------------------------------------------------------------------------------------
   Autor    : Renato Darosci - Supero
   Objetivo : GPS - Gerar as datas de agendamento para a competencia selecionada, retornando as mesmas
                    para serem exibidas na tela de confirmação
  ---------------------------------------------------------------------------------------------------------------*/
  PROCEDURE pc_gps_datas_competencia(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                    ,pr_nrdiadeb   IN NUMBER
                                    ,pr_dtcmptde   IN VARCHAR2 -- Recebe como string e trata no programa
                                    ,pr_dtcmpate   IN VARCHAR2 -- Recebe como string e trata no programa
                                    ,pr_dscritic  OUT VARCHAR2
                                    ,pr_retxml    OUT CLOB);



  PROCEDURE pc_gps_totalizar(pr_dtpagmto IN VARCHAR2
                            ,pr_cdagenci IN VARCHAR2
                            ,pr_nrdcaixa IN VARCHAR2
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);


  PROCEDURE pc_gps_detalhes(pr_dtpagmto IN VARCHAR2
                           ,pr_cdagenci IN VARCHAR2
                           ,pr_nrdcaixa IN VARCHAR2
                           ,pr_cdidenti IN VARCHAR2
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_lisgps_imp(pr_cdcooper  IN NUMBER
                         ,pr_dsiduser  IN VARCHAR2
                         ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                         ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                         ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                         ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                         ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                         ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo


  /*---------------------------------------------------------------------------------------------------------------
   Autor    : Renato Darosci - Supero
   Objetivo : GPS - Validar os dados do pagamento
  ---------------------------------------------------------------------------------------------------------------*/
  PROCEDURE pc_gps_validar_pagar(pr_cdcooper   IN craplau.cdcooper%TYPE
                                ,pr_nrdconta   IN craplau.nrdconta%TYPE
                                ,pr_nrseqagp   IN craplau.nrseqagp%TYPE
                                ,pr_dtmvtolt   IN craplau.dtmvtopg%TYPE
                                ,pr_cdcritic  OUT NUMBER
                                ,pr_dscritic  OUT VARCHAR2);

  /*---------------------------------------------------------------------------------------------------------------
   Autor    : Renato Darosci - Supero
   Objetivo : GPS - Validar os dados do pagamento
  ---------------------------------------------------------------------------------------------------------------*/
  PROCEDURE pc_gps_atualiza_pagto(pr_rowidlau   IN VARCHAR2
                                 ,pr_dtmvtolt   IN DATE
                                 ,pr_cdcritic  OUT NUMBER
                                 ,pr_dscritic  OUT VARCHAR2);

  /*---------------------------------------------------------------------------------------------------------------
   Autor    : Renato Darosci - Supero
   Objetivo : GPS - Organizar e preparar arquivos para download
  ---------------------------------------------------------------------------------------------------------------*/
  PROCEDURE pc_gps_arquivo_download(pr_cdcooper  IN NUMBER
                                   ,pr_dtpagmto  IN VARCHAR2
                                   ,pr_cdidenti  IN VARCHAR2
                                   ,pr_xmllog    IN VARCHAR2             --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
  /*---------------------------------------------------------------------------------------------------------------
   Autor    : Rafael Monteiro
   Objetivo : GPS - Efetuar pagamento de GPS apos aprovacao prepostos
  ---------------------------------------------------------------------------------------------------------------*/                             
  PROCEDURE pc_gps_pgt_aprovado(pr_cdcooper      IN NUMBER
                               ,pr_nrdconta      IN NUMBER
                               ,pr_cdtransacao   IN NUMBER
                               ,pr_idagendamento IN NUMBER
                               ,pr_cdcritic1     OUT NUMBER  --> Código da crítica
                               ,pr_dscritic1     OUT VARCHAR2) ;
                                   

END INSS0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.INSS0002 AS

  /*---------------------------------------------------------------------------------------------------------------
   Programa : INSS0002
   Autor    : Dionathan
   Data     : 27/08/2015                        Ultima atualizacao: 17/07/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : GPS

   Alteracoes: 25/04/2016 - Ajustes na impressao comprovante de agendamento
                            na rotina pc_gps_agmto_novo referente a melhoria
                            112 (Tiago/Elton).

               05/09/2016 - SD 514294 - Alterar as rotinas PC_GPS_VALIDAR_SICREDI e
                            PC_GPS_ARRECADAR_SICREDI para formar a nova nomenclatura
                            para os arquivos do GPS, possibilitando a busca e download
                            dos mesmos.   (Renato Darosci - SUPERO)

               05/09/2016 - SD 490844 - Removido o código que limpava a variável
                            vr_cdlindig quando o agendamento era feito pelo código
                            de barras (procedure pc_gps_agmto_novo). (Carlos)
                            
               02/02/2017 - Incluir chamada da procedure pc_insere_movimento_internet para
                            gravar registro na tabela crapmvi, para somar as movimentacoes
                            de GPS junto com as outras. (Lucas Ranghetti #556489)
                            
               06/03/2017 - Ajustado no cursor da craplgp na procedure pc_gps_agmto_novo para
                            converter cddidenti para numero antes de realizar a clausula where
                            pois a autoconversao do oracle nao convertia de forma adequada
                            (Tiago/Fabricio SD616352).             
                            
               25/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

               25/05/2017 - Se DEBSIC ja rodou, nao aceitamos mais agendamento para agendamentos 
                           em que o dia que antecede o final de semana ou feriado nacional
                           (Lucas Ranghetti #671126)      
                            
               17/07/2017 - Nao gerar RAISE caso chegue ao final do processo de pagto de GPS
                            e o Sicredi tenha aceitado o mesmo. (Chamado 704313) - (Fabricio)
  ---------------------------------------------------------------------------------------------------------------*/

  --Buscar informacoes de lote
  CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                   ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                   ,pr_cdagenci IN craplot.cdagenci%TYPE
                   ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                   ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
    SELECT lot.rowid
          ,lot.nrdolote
          ,lot.nrseqdig
          ,lot.cdbccxlt
          ,lot.tplotmov
          ,lot.dtmvtolt
          ,lot.cdagenci
          ,lot.cdhistor
          ,lot.cdoperad
          ,lot.qtcompln
          ,lot.qtinfoln
          ,lot.vlcompcr
          ,lot.vlinfocr
      FROM craplot lot
     WHERE lot.cdcooper = pr_cdcooper
       AND lot.dtmvtolt = pr_dtmvtolt
       AND lot.cdagenci = pr_cdagenci
       AND lot.cdbccxlt = pr_cdbccxlt
       AND lot.nrdolote = pr_nrdolote
       FOR UPDATE NOWAIT;

  -- TIPO
  TYPE typ_xmldata IS RECORD(-- Linha Cabecalho
                             cddbanco   NUMBER
                            ,cdagenci   NUMBER
                            ,nrdconta   craplgp.nrctapag%TYPE
                            ,nmprimtl   VARCHAR2(500)
                            ,nmprepos   VARCHAR2(500)
                            ,inpesgps   VARCHAR2(500)
                            ,tpdpagto   VARCHAR2(500)
                            -- Linha Detalhes
                            ,nrdocmto   NUMBER
                            ,nrdcontr   NUMBER
                            ,cdbarras   VARCHAR2(500)
                            ,cdlindig   VARCHAR2(500)
                            ,cddpagto   NUMBER
                            ,mmaacomp   VARCHAR2(10)
                            ,cdidenti   VARCHAR2(20)
                            ,vlrdinss   NUMBER
                            ,vlrouent   NUMBER
                            ,vlrjuros   NUMBER
                            ,vlrtotal   NUMBER
                            ,dtmvtolt   DATE
                            ,hrtransa   VARCHAR2(10)
                            ,dsprotoc   VARCHAR2(500));

  ----------------> TEMPTABLE <---------------
  vr_tab_limite     INET0001.typ_tab_limite;
  vr_tab_internet   INET0001.typ_tab_internet;
  vr_tab_erro       GENE0001.typ_tab_erro;    --> Tabela com erros
  vr_tab_saldos     EXTR0001.typ_tab_saldos;  --> Tabela de retorno da rotina


  -- Variáveis
  vr_dsxmlrel    CLOB;
  vr_dsdtexto    VARCHAR2(32000);
  vr_nrdrowid    ROWID;
  vr_nrdrowid1  ROWID;
  vr_dtcompet   VARCHAR(6); 


  vr_exc_saida      EXCEPTION;       --> Controle de Exceção
  vr_exit           EXCEPTION;

  -- Data Limite para pagamento do 13º - Formato DDMM
  vr_dialim13 CONSTANT VARCHAR2(4) := '2012'; -- FIXO / Sempre 20/12 quando 13º

  -- OBSERVAÇÃO: User/Paswd é para o SERVIÇO SICREDI, não por Cooperativa
  vr_usr_sicredi   VARCHAR2(30):= GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                           ,pr_cdcooper => 0
                                                           ,pr_cdacesso => 'USR_SICREDI_GPS');
  vr_pwd_sicredi   VARCHAR2(30):= GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                           ,pr_cdcooper => 0
                                                           ,pr_cdacesso => 'PWD_SICREDI_GPS');

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

  /*Função para buscar o filho de um nó no xml a partir de um LIKE*/
  FUNCTION xmldom_getChildNodeLike(n xmldom.DOMNode, l VARCHAR2) RETURN xmldom.DOMNode IS
    vr_lista_nodo xmldom.domnodelist;
    vr_nodo       xmldom.domnode;
    vr_nome_nodo  VARCHAR2(255);
    vr_length NUMBER;
  BEGIN
    vr_lista_nodo := xmldom.getChildNodes(n);
    vr_length := xmldom.getlength(vr_lista_nodo);

    FOR i IN 0..vr_length LOOP
       vr_nodo := xmldom.item(vr_lista_nodo, i);
       vr_nome_nodo := xmldom.getNodeName(vr_nodo);

       IF UPPER(vr_nome_nodo) LIKE UPPER(l) THEN
         RETURN vr_nodo;
       END IF;
    END LOOP;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN RETURN NULL;
  END;


  /******************************************************************************
  Procedure responsavel por efetuar o lancamento do credito da guia de GPS.
  ******************************************************************************/
  PROCEDURE pc_atualiza_pagamento(pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ,pr_dtmvtolt IN DATE
                                 ,pr_cdagenci IN craplgp.cdagenci%TYPE
                                 ,pr_nrdcaixa IN NUMBER
                                 ,pr_cdoperad IN VARCHAR2
                                 ,pr_cdidenti IN VARCHAR2
                                 ,pr_idleitur IN NUMBER
                                 ,pr_cddpagto IN craplgp.cddpagto%TYPE
                                 ,pr_mmaacomp IN VARCHAR2
                                 ,pr_vlrdinss IN NUMBER
                                 ,pr_vlrouent IN NUMBER
                                 ,pr_vlrjuros IN NUMBER
                                 ,pr_vlrtotal IN NUMBER
                                 ,pr_tpdpagto IN NUMBER -- (1 - com cod.barra, 2 - sem cod.barra)
                                 ,pr_cdbarras IN VARCHAR2
                                 ,pr_dslindig IN VARCHAR2
                                 ,pr_nrdconta IN NUMBER
                                 ,pr_inpesgps IN NUMBER
                                 ,pr_idseqttl IN NUMBER
                                 ,pr_dtvencto IN DATE
                                 ,pr_dstiparr IN VARCHAR2
                                 ,pr_nmdatela IN  VARCHAR2
                                 ,pr_inproces IN NUMBER
                                 ,pr_nrseqagp IN NUMBER
                                 ,pr_craplgp_rowid OUT ROWID
                                 ,pr_craplot OUT cr_craplot%ROWTYPE
                                 ,pr_dslitera   OUT VARCHAR2
                                 ,pr_sequenci   OUT NUMBER
                                 ,pr_nrseqaut   OUT NUMBER
                                 ,pr_registro   OUT ROWID
                                 ,pr_cdcritic   OUT PLS_INTEGER --Código da crítica
                                 ,pr_dscritic   OUT VARCHAR2 --Descrição da crítica
                                 ,pr_des_reto   OUT VARCHAR2 --Saida OK/NOK
                                  ) IS

    -- Cursor CRAPLGP
    CURSOR cr_craplgp(p_cdcooper IN craplgp.cdcooper%TYPE
                     ,p_dtmvtolt IN craplgp.dtmvtolt%TYPE
                     ,p_cdagenci IN craplgp.cdagenci%TYPE
                     ,p_cdbccxlt IN craplgp.cdbccxlt%TYPE
                     ,p_nrdolote IN craplgp.nrdolote%TYPE
                     ,p_cdidenti IN VARCHAR2
                     ,p_cddpagto IN craplgp.cddpagto%TYPE
                     ,p_mmaacomp IN craplgp.mmaacomp%TYPE
                     ,p_vlrtotal IN craplgp.vlrtotal%TYPE) IS
      SELECT lgp.rowid
        FROM craplgp lgp
       WHERE lgp.cdcooper  = p_cdcooper
         AND lgp.dtmvtolt  = p_dtmvtolt
         AND lgp.cdagenci  = p_cdagenci
         AND lgp.cdbccxlt  = p_cdbccxlt
         AND lgp.nrdolote  = p_nrdolote
         AND lgp.cdidenti2 = p_cdidenti
         AND lgp.mmaacomp  = TO_NUMBER(p_mmaacomp)
         AND lgp.vlrtotal  = p_vlrtotal
         AND lgp.cddpagto  = p_cddpagto
         AND lgp.flgpagto  = 1 --TRUE
         AND lgp.flgativo  = 1;

    -- Cursor CRAPLGP para identificar Agendamento
    CURSOR cr_lgp_agp(p_cdcooper IN craplgp.cdcooper%TYPE
                     ,p_nrdconta IN craplgp.nrctapag%TYPE
                     ,p_nrseqagp IN craplgp.nrseqagp%TYPE) IS
      SELECT lgp.rowid
            ,lgp.nrseqagp
        FROM craplgp lgp
       WHERE lgp.cdcooper  = p_cdcooper
         AND lgp.nrctapag  = p_nrdconta
         AND lgp.nrseqagp  = p_nrseqagp
         AND lgp.flgpagto  = 0 --NAO PAGO
         ;

    rw_lgp_agp       cr_lgp_agp%ROWTYPE;
    rw_craplgp       cr_craplgp%ROWTYPE;
    cr_craplgp_found BOOLEAN := FALSE;
    vr_lgp_agp_found BOOLEAN := FALSE;
    vr_nrseqagp      craplgp.nrseqagp%TYPE:=0;
    vr_rowid_lgp     ROWID;

    vr_nrdolote craplgp.nrdolote%TYPE := 31000 + pr_nrdcaixa;


    -- Procedimento para inserir o lote e não deixar tabela lockada
    PROCEDURE pc_insere_lote(pr_cdcooper IN craplot.cdcooper%TYPE
                            ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                            ,pr_cdagenci IN craplot.cdagenci%TYPE
                            ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                            ,pr_nrdolote IN craplot.nrdolote%TYPE
                            ,pr_cdoperad IN craplot.cdoperad%TYPE
                            ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE
                            ,pr_tplotmov IN craplot.tplotmov%TYPE
                            ,pr_cdhistor IN craplot.cdhistor%TYPE
                            ,pr_vlcompdb IN craplot.vlcompdb%TYPE
                            ,pr_vlinfodb IN craplot.vlinfodb%TYPE
                            ,pr_dscritic OUT VARCHAR2) IS

      -- Pragma - abre nova sessao para tratar a atualizacao
      PRAGMA AUTONOMOUS_TRANSACTION;

    BEGIN

      /* Tratamento para buscar registro de lote se o mesmo estiver em lock, tenta por 10 seg. */
      FOR i IN 1 .. 100 LOOP
        BEGIN
          -- Leitura do lote
          OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => pr_dtmvtolt
                         ,pr_cdagenci => pr_cdagenci
                         ,pr_cdbccxlt => pr_cdbccxlt
                         ,pr_nrdolote => pr_nrdolote);
          FETCH cr_craplot
            INTO pr_craplot;
          pr_dscritic := NULL;
          EXIT;
        EXCEPTION
          WHEN OTHERS THEN
            IF cr_craplot%ISOPEN THEN
              CLOSE cr_craplot;
            END IF;

            -- setar critica caso for o ultimo
            IF i = 100 THEN
              pr_dscritic := pr_dscritic || 'Registro de lote ' ||
                             pr_nrdolote || ' em uso. Tente novamente!';
            END IF;
            -- aguardar 0,5 seg. antes de tentar novamente
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
          ,craplot.nrseqdig
          ,craplot.tplotmov
          ,craplot.cdoperad
          ,craplot.cdhistor
          ,craplot.nrdcaixa
          ,craplot.cdopecxa)
        VALUES
          (pr_cdcooper
          ,pr_dtmvtolt
          ,pr_cdagenci
          ,pr_cdbccxlt
          ,pr_nrdolote
          ,1 -- craplot.nrseqdig
          ,pr_tplotmov
          ,pr_cdoperad
          ,pr_cdhistor
          ,pr_nrdcaixa
          ,pr_cdoperad)
        RETURNING craplot.rowid
                 ,craplot.nrdolote
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
              INTO
                  pr_craplot.rowid
                 ,pr_craplot.nrdolote
                 ,pr_craplot.nrseqdig
                 ,pr_craplot.cdbccxlt
                 ,pr_craplot.tplotmov
                 ,pr_craplot.dtmvtolt
                 ,pr_craplot.cdagenci
                 ,pr_craplot.cdhistor
                 ,pr_craplot.cdoperad
                 ,pr_craplot.qtcompln
                 ,pr_craplot.qtinfoln
                 ,pr_craplot.vlcompcr
                 ,pr_craplot.vlinfocr;
      ELSE
        -- ou atualizar o nrseqdig para reservar posição
        UPDATE craplot
           SET craplot.nrseqdig = NVL(craplot.nrseqdig, 0) + 1
         WHERE craplot.rowid = pr_craplot.rowid
        RETURNING craplot.nrseqdig INTO pr_craplot.nrseqdig;
      END IF;

      CLOSE cr_craplot;

      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        IF cr_craplot%ISOPEN THEN
          CLOSE cr_craplot;
        END IF;
        ROLLBACK;
        -- se ocorreu algum erro durante a criac?o
        pr_dscritic := 'Erro ao gravar LOTE(' || pr_nrdolote || '): ' ||
                       SQLERRM;
    END pc_insere_lote;




  BEGIN

    -- Verifica se já possui registro na lgp
    OPEN cr_craplgp(p_cdcooper => pr_cdcooper
                   ,p_dtmvtolt => pr_dtmvtolt
                   ,p_cdagenci => pr_cdagenci
                   ,p_cdbccxlt => 100 /* Fixo */
                   ,p_nrdolote => vr_nrdolote
                   ,p_cdidenti => pr_cdidenti
                   ,p_cddpagto => pr_cddpagto
                   ,p_mmaacomp => pr_mmaacomp
                   ,p_vlrtotal => pr_vlrtotal);
    FETCH cr_craplgp
      INTO rw_craplgp;
    cr_craplgp_found := cr_craplgp%FOUND;
    CLOSE cr_craplgp;

    IF cr_craplgp_found THEN
      -- Montar mensagem de critica
      pr_cdcritic := 92;
      -- Busca critica
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      RAISE vr_exc_saida;
    END IF;



    -- Verifica se já possui registro na lgp para AGENDAMENTO
    IF  pr_nmdatela = 'AYLLOS'  THEN -- Veio pelo CRPS/DEBSIC
        BEGIN
          -- Excluir
          DELETE craplgp lgp
           WHERE lgp.cdcooper = pr_cdcooper
             AND lgp.nrctapag = pr_nrdconta
             AND lgp.nrseqagp = pr_nrseqagp;

        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro no Pagamento do Agendamento! (Erro: '|| to_char(SQLCODE) || ')';
            RAISE vr_exc_saida;
        END;
    END IF;

    -- Procedimento para inserir o lote e não deixar tabela lockada
    pc_insere_lote(pr_cdcooper => pr_cdcooper
                  ,pr_dtmvtolt => pr_dtmvtolt
                  ,pr_cdagenci => pr_cdagenci
                  ,pr_cdbccxlt => 100 /* Fixo */
                  ,pr_nrdolote => vr_nrdolote
                  ,pr_cdoperad => pr_cdoperad
                  ,pr_nrdcaixa => pr_nrdcaixa
                  ,pr_tplotmov => 30
                  ,pr_cdhistor => 1414 /* Historico gps sicredi */
                  ,pr_vlcompdb => pr_vlrtotal
                  ,pr_vlinfodb => pr_vlrtotal
                  ,pr_dscritic => pr_dscritic);

    -- se encontrou erro ao buscar lote, abortar programa
    IF pr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_saida;
    END IF;

    --
    INSERT INTO craplgp
               (cdcooper
               ,dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,cdopecxa
               ,nrdcaixa
               ,nrdmaqui
               ,cdidenti
               ,cdidenti2
               ,tpleitur
               ,cddpagto
               ,mmaacomp
               ,vlrdinss
               ,vlrouent
               ,vlrjuros
               ,vlrtotal
               ,nrseqdig
               ,hrtransa
               ,flgenvio
               ,tpdpagto
               ,cdbarras
               ,dslindig
               ,nrctapag
               ,inpesgps
               ,dtvencto
               ,dstiparr
               ,nrseqagp
               ,flgativo)
        VALUES (pr_cdcooper
               ,pr_craplot.dtmvtolt
               ,pr_craplot.cdagenci
               ,pr_craplot.cdbccxlt
               ,pr_craplot.nrdolote
               ,pr_cdoperad
               ,pr_nrdcaixa
               ,pr_nrdcaixa
               ,TO_NUMBER(pr_cdidenti)
               ,pr_cdidenti
               ,pr_idleitur
               ,pr_cddpagto
               ,pr_mmaacomp
               ,pr_vlrdinss
               ,pr_vlrouent
               ,pr_vlrjuros
               ,pr_vlrtotal
               ,pr_craplot.nrseqdig
               ,to_number(to_char(SYSDATE, 'SSSSS'))
               ,1
               ,pr_tpdpagto
               ,NVL(pr_cdbarras,' ')
               ,NVL(pr_dslindig,' ')
               ,NVL(pr_nrdconta,0)
               ,pr_inpesgps
               ,pr_dtvencto
               ,pr_dstiparr
               ,pr_nrseqagp
               ,1 -- flgativo
               )
             RETURNING ROWID
             INTO pr_craplgp_rowid;

    -- se encontrou erro ao buscar lote, abortar programa
    IF pr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_saida;
    END IF;


    -- atualiza os valores da lote
    BEGIN
      UPDATE craplot SET craplot.qtcompln = NVL(craplot.qtcompln, 0) + 1
                        ,craplot.qtinfoln = NVL(craplot.qtinfoln, 0) + 1
                        ,craplot.vlcompdb = NVL(craplot.vlcompdb, 0) + NVL(pr_vlrtotal, 0)              
                        ,craplot.vlinfodb = NVL(craplot.vlinfodb, 0) + NVL(pr_vlrtotal, 0)
      WHERE craplot.ROWID = pr_craplot.ROWID
      RETURNING craplot.nrseqdig INTO pr_sequenci;
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro ao atualizar tabela craplot. '||SQLERRM;
        --Levantar Excecao
        RAISE vr_exc_saida;
    END;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Retorno não OK
      pr_des_reto := 'NOK';

    WHEN OTHERS THEN

      -- Retorno não OK
      pr_des_reto := 'NOK';

      --Monta mensagem de critica
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na INSS0002.pc_atualiza_pagamento --> ' ||
                     SQLERRM;

  END pc_atualiza_pagamento;

  PROCEDURE pc_gps_validar_sicredi(pr_cdcooper IN crapcop.cdcooper %TYPE
                                  ,pr_cdagenci IN NUMBER
                                  ,pr_nrdcaixa IN VARCHAR2
                                  ,pr_idorigem IN NUMBER
                                  ,pr_dtmvtolt IN DATE
                                  ,pr_nmdatela IN VARCHAR2
                                  ,pr_cdoperad IN VARCHAR2
                                  ,pr_inproces IN NUMBER    -- 1-On-line / Maior Igual 2 -> Batch
                                  ,pr_idleitur IN NUMBER    -- Indica se os campos vieram via Leitura Laser(1) ou Manual(0)
                                  ,pr_cddpagto IN VARCHAR2
                                  ,pr_cdidenti IN VARCHAR2
                                  ,pr_dtvencto IN DATE
                                  ,pr_cdbarras IN VARCHAR2
                                  ,pr_dslindig IN VARCHAR2
                                  ,pr_mmaacomp IN VARCHAR2
                                  ,pr_vlrdinss IN NUMBER
                                  ,pr_vlrouent IN NUMBER
                                  ,pr_vlrjuros IN NUMBER
                                  ,pr_vlrtotal IN NUMBER
                                  ,pr_idseqttl IN NUMBER
                                  ,pr_tpdpagto IN NUMBER -- (1 - com cod.barra, 2 - sem cod.barra)
                                  ,pr_nrdconta IN NUMBER
                                  ,pr_inpesgps IN NUMBER
                                  ,pr_indpagto IN VARCHAR2
                                  ,pr_nrseqagp IN NUMBER
                                  ,pr_nrcpfope IN crapopi.nrcpfope%TYPE DEFAULT NULL
                                  ,pr_dslitera OUT VARCHAR2
                                  ,pr_sequenci OUT NUMBER
                                  ,pr_nrseqaut OUT NUMBER
                                  ,pr_cdcritic OUT PLS_INTEGER -- Código da crítica
                                  ,pr_dscritic OUT VARCHAR2 -- Descrição da crítica
                                  ,pr_des_reto OUT VARCHAR2 -- Saida OK/NOK
                                   ) IS

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cop.cdagesic
            ,TRUNC(SYSDATE) + 1 / 86400 * cop.hrinigps hrinigps
            ,TRUNC(SYSDATE) + 1 / 86400 * cop.hrfimgps hrfimgps
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Buscar Data Debito da GPS
    CURSOR cr_gps (p_cdcooper IN tbinss_agendamento_gps.cdcooper%TYPE
                  ,p_nrdconta IN tbinss_agendamento_gps.nrdconta%TYPE
                  ,p_nrseqagp IN tbinss_agendamento_gps.nrseqagp%TYPE) IS
      SELECT gps.dtdebito
        FROM tbinss_agendamento_gps gps
       WHERE gps.cdcooper = p_cdcooper
         AND gps.nrdconta = p_nrdconta
         AND gps.nrseqagp = p_nrseqagp;
    rw_gps    cr_gps%ROWTYPE;
    CURSOR cr_crapsnh (prc_cdcooper crapsnh.cdcooper%type,
                       prc_nrdconta crapsnh.nrdconta%type,
                       prc_idseqttl crapsnh.idseqttl%type)IS
      SELECT c.nrcpfcgc
        FROM crapsnh c
       WHERE c.cdcooper = prc_cdcooper
         AND c.nrdconta = prc_nrdconta
         AND c.idseqttl = prc_idseqttl
         AND c.tpdsenha = 1 -- INTERNET
         ;    

    vr_raizcoop VARCHAR2(255);
    vr_msgenvio VARCHAR2(255);
    vr_msgreceb VARCHAR2(255);
    vr_movarqto VARCHAR2(255);
    vr_nmarqlog VARCHAR2(255);
    vr_dstiparr VARCHAR2(255);
    vr_mmaacomp VARCHAR2(6);
    vr_dtdenvio VARCHAR2(19);
    vr_indagend PLS_INTEGER;
    vr_assin_conjunta NUMBER(1);
    vr_nmdatela VARCHAR2(50);
    vr_nrcpfcgc  crapsnh.nrcpfcgc%type;

    --Variáveis para trabalhar com XML/SOAP
    vr_dstexto VARCHAR2(32767);
    vr_xml     xmltype; --> XML de requisição

    vr_cddpagto VARCHAR2(50)  := pr_cddpagto;
    vr_cdidenti VARCHAR2(20)  := pr_cdidenti;
    vr_dsorigem VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_idorigem);
    vr_nrcpfope crapopi.nrcpfope%TYPE;
    vr_dstransa VARCHAR2(100);
    vr_dstransa1 VARCHAR2(100);
    vr_vlrtotal NUMBER        := pr_vlrtotal;
    vr_dtdebito DATE;

    --Variaveis Documentos DOM
    vr_xmldoc     xmldom.domdocument;
    vr_nodo       xmldom.domnode;

  BEGIN
    pr_des_reto := 'NOK';
    vr_assin_conjunta := 0;
    vr_nmdatela       := pr_nmdatela;
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      pr_cdcritic := 651;
      -- Busca critica
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;


    IF LENGTH(pr_cddpagto) = 0 THEN
      vr_cddpagto := CASE
                       WHEN LENGTH(pr_cdbarras) > 0 THEN
                        SUBSTR(pr_cdbarras, 20, 4)
                       ELSE
                        SUBSTR(pr_dslindig, 21, 3) || SUBSTR(pr_dslindig, 25, 1)
                     END;
    END IF;

    IF LENGTH(pr_cdidenti) = 0 THEN
      vr_cdidenti := CASE
                       WHEN LENGTH(pr_cdbarras) > 0 THEN
                        SUBSTR(pr_cdbarras, 24, 14)
                       ELSE
                        SUBSTR(pr_dslindig, 26, 14)
                     END;
    END IF;

    vr_mmaacomp := lpad(pr_mmaacomp,6,'0');

    vr_raizcoop := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => NULL);
    vr_nmarqlog := vr_raizcoop || '/log/' || 'SICREDI_Soap_LogErros.log';

    -- Alterado por Renato Darosci - 05/09/2016 - SD 514294
    /******************************************************************
    vr_msgenvio := vr_raizcoop || '/arq/' ||
                   'INSS.SOAP.GPS.E.V.' ||   -- ENVIO VALIDACAO
                   to_char(pr_dtmvtolt, 'yyyymmdd') || '.' ||
                   to_char(SYSDATE,'SSSSS')         ||
                   to_char(SYSTIMESTAMP,'FF6')      || '.' ||
                   pr_cdoperad;
    vr_msgreceb := vr_raizcoop || '/arq/' ||
                   'INSS.SOAP.GPS.R.V.' ||   -- RECEBIMENTO VALIDACAO
                   to_char(pr_dtmvtolt, 'yyyymmdd') || '.' ||
                   to_char(SYSDATE,'SSSSS')         ||
                   to_char(SYSTIMESTAMP,'FF6')      || '.' ||
                   pr_cdoperad;
    *******************************************************************/
    vr_msgenvio := vr_raizcoop || '/arq/' ||
                   'GPS.' ||   -- ENVIO VALIDACAO
                   LPAD(vr_cdidenti,14,'0') || '.' ||
                   to_char(pr_dtmvtolt, 'RRRRMMDD') || '.' ||
                   to_char(SYSTIMESTAMP, 'hh24miss.FF6') || '.' ||
                   'E.V.' ||
                   pr_cdoperad;
    vr_msgreceb := vr_raizcoop || '/arq/' ||
                   'GPS.' ||   -- RECEBIMENTO VALIDACAO
                   LPAD(vr_cdidenti,14,'0') || '.' ||
                   to_char(pr_dtmvtolt, 'RRRRMMDD') || '.' ||
                   to_char(SYSTIMESTAMP, 'hh24miss.FF6') || '.' ||
                   'R.V.' ||
                   pr_cdoperad;

    vr_movarqto := vr_raizcoop || '/salvar/gps/';

    /* APESAR DE A TAG DataVencimento SIGNIFICAR  QUE DEVE SER INFORMADA
       A DATA DE VENCIMENTO DA GUIA GPS, O SICREDI UTILIZA ESSA TAG PARA
       A DATA DE PAGAMENTO DA GUIA GPS JUNTO A RECEITA FEDERAL. POR ISSO
       DEVE SER INFORMADA A DATA DO DIA NESSA TAG AO ENVIAR PARA SICREDI
       JÁ NO CASO DO AGENDAMENTO, PASSAR A DATA DO AGENDAMETNO     */
    IF pr_indpagto = 'A' THEN
      vr_dtdenvio := to_char(pr_dtvencto,'YYYY-MM-DD') || 'T00:00:00';
    ELSE
      vr_dtdenvio := to_char(pr_dtmvtolt,'YYYY-MM-DD') || 'T00:00:00';
    END IF;


    IF pr_idorigem = 2 THEN
      -- 2 - CAIXA
      IF pr_tpdpagto = 2 THEN -- 2-Sem Cod Barras
        vr_dstiparr := 'MANUAL BOCA DE CAIXA E RETAGUARDA';
      ELSE
        vr_dstiparr := 'GPS COM CODIGO DE BARRAS GUICHE DE CAIXA';
      END IF;
    ELSIF pr_idorigem = 3 THEN
      -- 3 - INTERNET BANK
      IF pr_tpdpagto = 2 THEN -- 2-Sem Cod Barras
        vr_dstiparr := 'ELETRONICA';
      ELSE
        vr_dstiparr := 'GPS COM CODIGO DE BARRAS ELETRONICA';
      END IF;
    END IF;


    -- Hora atual deve estar entre o horário limite cadastrado na CRAPCOP
    -- e INPROCESS "on-line", caso contrario, nao precisa.
    IF  pr_inproces = 1   -- On-line
    AND pr_nrdconta > 0   -- Tem Conta
    AND pr_indpagto = 'V' -- É para Validar Pagamento (A-Agendar / P-Pagar / V-Validar Pagamento)
    AND SYSDATE NOT BETWEEN rw_crapcop.hrinigps AND rw_crapcop.hrfimgps THEN -- Horario Limite SICREDI
      pr_cdcritic := 0;
      pr_dscritic := 'Pagamento fora do horário limite para arrecadação de GPS! (De ' ||
                     to_char(rw_crapcop.hrinigps, 'HH24:MI') || 'h até ' ||
                     to_char(rw_crapcop.hrfimgps, 'HH24:MI') || 'h)';
      RAISE vr_exc_saida;
    END IF;


    -- Verificar limites diários no IB -> Quando Pagamento ou Agendamento
    IF  pr_idorigem = 3         -- Veio pelo Internet Banking
    AND pr_nrdconta > 0 THEN     -- Tem Conta

      IF pr_nrseqagp <> 0 THEN -- Pagamento Agendamento
        -- Buscar dados da GPS - Data de DEBITO
        OPEN cr_gps(pr_cdcooper, pr_nrdconta, pr_nrseqagp);
        FETCH cr_gps INTO rw_gps;
        -- Verificar se existe informacao, e gerar erro caso nao exista
        IF cr_gps%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_gps;
          -- Gerar excecao
          pr_dscritic := 'Agendamento não encontrado!';
          RAISE vr_exc_saida;
        END IF;
        -- Fechar o cursor
        CLOSE cr_gps;
        
        vr_dtdebito := rw_gps.dtdebito;

      ELSE -- Pagamento ou apenas Validação
        IF pr_indpagto = 'A' THEN
          vr_dtdebito := pr_dtvencto;
        ELSE -- apenas VALIDACAO 
          vr_dtdebito := pr_dtmvtolt;
        END IF;
      END IF;

      IF pr_indpagto = 'A' THEN
        vr_indagend := 2; -- AGENDAMENTO
      ELSE
        vr_indagend := 1; -- PAGAMENTO
      END IF;
      BEGIN
        vr_nrdrowid := NULL;
        vr_dstransa1 := 'Registro de Validacoes GPS'; -- 397
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                            ,pr_dstransa => vr_dstransa1
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid1);
        --        
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid1
                                 ,pr_nmdcampo => 'Nro CPF Operador'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_nrcpfope);  
        --               
                                                                  
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro chamada GERAR LOG GPS '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      vr_nrcpfcgc := 0;
      IF pr_nrcpfope = 0 THEN
        FOR rw_crapsnh IN cr_crapsnh(pr_cdcooper,
                                       pr_nrdconta,
                                       pr_idseqttl) LOOP
          vr_nrcpfcgc := rw_crapsnh.nrcpfcgc;
        END LOOP;      
      END IF;
      --
      --Verificar Operacao
      INET0001.pc_verifica_operacao (pr_cdcooper => pr_cdcooper          --Código Cooperativa
                                    ,pr_cdagenci => pr_cdagenci          --Agencia do Associado
                                    ,pr_nrdcaixa => pr_nrdcaixa          --Numero caixa
                                    ,pr_nrdconta => pr_nrdconta          --Numero da conta
                                    ,pr_idseqttl => pr_idseqttl          --Identificador Sequencial titulo
                                    ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                    ,pr_idagenda => vr_indagend          --Indicador agenda
                                    ,pr_dtmvtopg => vr_dtdebito          --Data Pagamento
                                    ,pr_vllanmto => vr_vlrtotal          --Valor Lancamento
                                    ,pr_cddbanco => 0                    --Codigo banco destino
                                    ,pr_cdageban => 0                    --Codigo Agencia destino
                                    ,pr_nrctatrf => 0                    --Numero Conta Destino
                                    ,pr_cdtiptra => 0                    --Tipo transacao
                                    ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                    ,pr_tpoperac => 2                    --Pagamento
                                    ,pr_flgvalid => TRUE                 --Indicador validacoes
                                    ,pr_dsorigem => vr_dsorigem          --Descricao Origem
                                    ,pr_nrcpfope => pr_nrcpfope                 --CPF operador
                                    ,pr_flgctrag => FALSE                --controla validacoes na efetivacao de agendamentos */
                                    ,pr_nmdatela => pr_nmdatela          -- Nome da tela
                                    ,pr_dstransa => vr_dstransa          --Descricao da transacao
                                    ,pr_tab_limite   => vr_tab_limite    --Tabelas de retorno de horarios limite
                                    ,pr_tab_internet => vr_tab_internet  --Tabelas de retorno de horarios limite
                                    ,pr_cdcritic => pr_cdcritic          --Código do erro
                                    ,pr_dscritic => pr_dscritic
                                    ,pr_assin_conjunta => vr_assin_conjunta);        --Descricao do erro;
      -- verificar se retornou critica
      IF NVL(pr_cdcritic,0) > 0 OR
         TRIM(pr_dscritic) IS NOT NULL THEN
        -- abortar programa
        RAISE vr_exc_saida;
      END IF;

    END IF;
    --
    BEGIN
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid1
                                 ,pr_nmdcampo => 'Id Ass Conjunta'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => vr_assin_conjunta);
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro chamada Id Ass Conjunta '||SQLERRM;
        RAISE vr_exc_saida;      
    END;
    --         
    -- Deverá gerar pendencia de aprovacao
    IF vr_assin_conjunta = 1 AND pr_nmdatela = 'INTERNETBANK' THEN
      -- 
      --Cria transacao pendente de pagamento GPS
      BEGIN
        INET0002.pc_cria_trans_pend_pag_gps( pr_cdagenci => 90             --> Codigo do PA
                                            ,pr_nrdcaixa => 900            --> Numero do Caixa
                                            ,pr_cdoperad => '996'          --> Codigo do Operados
                                            ,pr_nmdatela => 'INTERNETBANK' --> Nome da Tela
                                            ,pr_idorigem => 3              --> Origem da solicitacao
                                            ,pr_idseqttl => pr_idseqttl    --> Sequencial de Titular
                                            ,pr_nrcpfope => pr_nrcpfope    --> Numero do cpf do operador juridico
                                            ,pr_nrcpfrep => vr_nrcpfcgc    --> Numero do cpf do representante legal
                                            ,pr_cdcoptfn => 0              --> Cooperativa do Terminal
                                            ,pr_cdagetfn => 0              --> Agencia do Terminal
                                            ,pr_nrterfin => 0              --> Numero do Terminal Financeiro
                                            ,pr_dtmvtolt => pr_dtmvtolt    --> Data do movimento
                                            ,pr_cdcooper => pr_cdcooper    --> Codigo da cooperativa
                                            ,pr_nrdconta => pr_nrdconta    --> Numero da Conta
                                            ,pr_idtippag => 3              --> Identificacao do tipo de pagamento (1 – Convenio / 2 – Titulo / 3 - GPS)
                                            ,pr_vllanmto => vr_vlrtotal    --> Valor do pagamento
                                            ,pr_dtmvtopg => vr_dtdebito    --> Data do debito
                                            ,pr_idagenda => vr_indagend    --> Indica se o pagamento foi agendado (1 – Online / 2 – Agendamento)
                                            ,pr_dscedent => 'Pagamento de GPS' --> Descricao do cedente do documento
                                            ,pr_dscodbar => pr_cdbarras    --> Descricao do codigo de barras
                                            ,pr_dslindig => pr_dslindig    --> Descricao da linha digitavel
                                            ,pr_vlrdocto => vr_vlrtotal    --> Valor do documento
                                            ,pr_dtvencto => vr_dtdebito    --> Data de vencimento do documento
                                            ,pr_tpcptdoc => 2              --> Tipo de captura do documento
                                            ,pr_idtitdda => 0              --> Identificador do titulo no DDA
                                            ,pr_idastcjt => vr_assin_conjunta --> Indicador de Assinatura Conjunta
                                            ,pr_nrdrowid => vr_nrdrowid    -- rowid do log
                                            ,pr_cdcritic => pr_cdcritic    --> Codigo de Critica
                                            ,pr_dscritic => pr_dscritic);  --> Descricao de Critica
        -- Verificar se retornou critica
        IF pr_cdcritic > 0 OR TRIM(pr_dscritic) IS NOT NULL THEN
          -- se possui codigo, porém não possui descrição
          IF nvl(pr_cdcritic,0) > 0 AND
             TRIM(pr_dscritic) IS NULL THEN
            -- buscar descrição
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);

          END IF;
          -- Se retornou critica , deve abortar
          RAISE vr_exc_saida;
        END IF;      
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro chamada pc_cria_trans_pend_pag_gps '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      --
      BEGIN
        -- Logs para recuperar quando aprovar
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'pr_cdcooper'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_cdcooper);
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro chamada pr_cdcooper '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      BEGIN
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'pr_nrdconta'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_nrdconta);
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro chamada pr_nrdconta '||SQLERRM;
          RAISE vr_exc_saida;
      END;                               
      BEGIN                      
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'pr_idseqttl'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_idseqttl);
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro chamada pr_idseqttl '||SQLERRM;
          RAISE vr_exc_saida;
      END; 
      BEGIN                              
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'pr_tpdpagto'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_tpdpagto);  
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro chamada pr_tpdpagto '||SQLERRM;
          RAISE vr_exc_saida;
      END; 
      BEGIN                              
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'pr_idleitur'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_idleitur);  
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro chamada pr_idleitur '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      BEGIN
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'pr_cdbarras'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_cdbarras); 
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro chamada pr_cdbarras '||SQLERRM;
          RAISE vr_exc_saida;
      END;      
      BEGIN                            
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'pr_sftcdbar'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_dslindig);  
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro chamada pr_sftcdbar '||SQLERRM;
          RAISE vr_exc_saida;
      END;    
      BEGIN                             
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'pr_cdpagmto'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_cddpagto);  
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro chamada pr_cdpagmto '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      BEGIN
        vr_dtcompet := SUBSTR(pr_mmaacomp,3,4)||SUBSTR(pr_mmaacomp,1,2);
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'pr_dtcompet'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => vr_dtcompet);     
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro chamada pr_dtcompet '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      BEGIN
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'pr_dsidenti'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_cdidenti);
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro chamada pr_dsidenti '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      BEGIN
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'pr_vldoinss'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_vlrdinss);                                 
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro chamada pr_vldoinss '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      BEGIN
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'pr_vloutent'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_vlrouent);
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro chamada pr_vloutent '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      BEGIN
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'pr_vlatmjur'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_vlrjuros);    
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro chamada pr_vlatmjur '||SQLERRM;
          RAISE vr_exc_saida;
      END;         
      BEGIN                                                                                   
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'pr_vlrtotal'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_vlrtotal); 
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro chamada pr_vlrtotal '||SQLERRM;
          RAISE vr_exc_saida;
      END; 
      BEGIN
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'pr_dtvencim'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => TO_CHAR(vr_dtdebito,'DD/MM/YYYY'));
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro chamada pr_dtvencim '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      BEGIN
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'pr_inpesgps'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_inpesgps);   
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro chamada pr_inpesgps '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      BEGIN
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'pr_nrseqagp'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_nrseqagp);
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro chamada pr_nrseqagp '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      BEGIN
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'pr_dtdebito'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => TO_CHAR(vr_dtdebito,'DD/MM/YYYY'));
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro chamada pr_dtdebito '||SQLERRM;
          RAISE vr_exc_saida;
      END;  
      BEGIN                             
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'pr_cdlindig'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_dslindig);       
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro chamada pr_cdlindig '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      BEGIN                             
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'pr_nrcpfope'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_nrcpfope);       
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro chamada pr_nrcpfope '||SQLERRM;
          RAISE vr_exc_saida;
      END;            
      --COMMIT;
      
      pr_cdcritic := 0;
      pr_dscritic := 'Pagamento registrado com sucesso. ' ||
                     'Aguardando aprovacao opcao Transacoes pendentes';
      RAISE vr_exc_saida;                                                                                                                       
    --
    ELSE

    -- Gerar cabeçalho do envelope SOAP
    inss0001.pc_gera_cabecalho_soap(pr_idservic => 5 -- idservic
                                   ,pr_nmmetodo => 'arr:InValidarArrecadacaoGPS' -- Nome Metodo
                                   ,pr_username => vr_usr_sicredi -- Username
                                   ,pr_password => vr_pwd_sicredi -- Password
                                   ,pr_dstexto  => vr_dstexto -- Texto do Arquivo de Dados
                                   ,pr_des_reto => pr_des_reto -- Retorno OK/NOK
                                   ,pr_dscritic => pr_dscritic); -- Descricao da Critica
    --Se ocorreu erro
    IF pr_des_reto <> 'OK'
    OR TRIM(pr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    /*Monta as tags de envio
    OBS.: O valor das tags deve respeitar a formatacao presente na
          base do SICREDI do contrario, a operacao nao sera
          realizada. */

    /* BLOCO: v1:UnidadeAtendimento */
    vr_dstexto := vr_dstexto || '<v1:UnidadeAtendimento>' ||
                  '<v1:Cooperativa>' ||
                    '<v1:CodigoCooperativa>' || rw_crapcop.cdagesic || '</v1:CodigoCooperativa>' ||
                  '</v1:Cooperativa>' ||
                 /*Devido a limitacao do SICREDI, PA com no maximo dois digitos, foi
                                                   definido que sempre sera enviado o PA 2 (Sem os zeros) ao inves
                                                   do par_cdagenci.*/
                  '<v1:NumeroUnidadeAtendimento>2</v1:NumeroUnidadeAtendimento>' ||
                  '</v1:UnidadeAtendimento>';

    /* BLOCO: arr:guiaPrevidenciaSocial */
    IF NVL(TRIM(pr_cdbarras),' ') <> ' ' THEN
      -- Com Código de barras
      vr_dstexto := vr_dstexto ||
                    '<arr:guiaPrevidenciaSocial v15:ID="0">' ||
                      '<v15:CodigoBarra>'   || pr_cdbarras ||   '</v15:CodigoBarra>' ||
                      '<v15:FormaCaptacao>' || vr_dstiparr || '</v15:FormaCaptacao>' ||
                    '</arr:guiaPrevidenciaSocial>';
    ELSIF  NVL(TRIM(pr_dslindig),' ') <> ' ' THEN
      -- Com Linha Digitavel
      vr_dstexto := vr_dstexto ||
                    '<arr:guiaPrevidenciaSocial v15:ID="0">' ||
                      '<v15:LinhaDigitada>' || pr_dslindig || '</v15:LinhaDigitada>' ||
                      '<v15:FormaCaptacao>' || vr_dstiparr || '</v15:FormaCaptacao>' ||
                    '</arr:guiaPrevidenciaSocial>';
    ELSE
      -- Digitação Manual
      vr_dstexto := vr_dstexto ||
                    '<arr:guiaPrevidenciaSocial v15:ID="0">' ||
                      '<v15:IdentificacaoPessoa>' || vr_cdidenti || '</v15:IdentificacaoPessoa>' ||
                      '<v15:Receita>' || vr_cddpagto || '</v15:Receita>' ||
                     /*Mesmo que nao haja valor, somos obrigados a enviar "0" pois o SICREDI nao aceita valor nulo.*/
                      '<v15:ValorPrincipal>' || REPLACE(REPLACE(NVL(pr_vlrdinss, '0'), '.', ''),',','.') ||
                        '</v15:ValorPrincipal>' ||

                      '<v15:DataVencimento>' || vr_dtdenvio || '</v15:DataVencimento>' ||

                      '<v15:AtualizacaoMonetaria>' || REPLACE(REPLACE(NVL(pr_vlrjuros, '0'), '.', ''),',','.') ||
                        '</v15:AtualizacaoMonetaria>' ||
                      '<v15:Competencia>' || vr_mmaacomp || '</v15:Competencia>' ||

                      '<v15:ValorOutrasEntidades>' || REPLACE(REPLACE(NVL(pr_vlrouent, '0'), '.', ''),',','.') ||
                        '</v15:ValorOutrasEntidades>' ||

                      '<v15:FormaCaptacao>' || vr_dstiparr || '</v15:FormaCaptacao>' ||
                    '</arr:guiaPrevidenciaSocial>';
    END IF;

    vr_dstexto := vr_dstexto ||
                  '<arr:canal>TERMINAL_FINANCEIRO</arr:canal>' ||
                  '<arr:formaPagamento>DINHEIRO</arr:formaPagamento>' ||
                  '<arr:aceitaGpsArrecadada>NAO</arr:aceitaGpsArrecadada>';

    /* BLOCO: arr:autenticacao */
    vr_dstexto := vr_dstexto ||
                  '<arr:autenticacao>' ||
                      '<aut:usuario>CECR</aut:usuario>' || -- No Máximo 4 Letras/números
                      '<aut:terminal>1</aut:terminal>' ||
                 /*O numero da autenticacao eh obrigatorio porem, neste xml de validacao,
                   enviaremos uma autenticacao ficticia pois a autenticacao real
                   sera gerada e enviada apenas no xml de arrecadacao.
                   Apesar de ser obrigatorio o envio de um valor, o SICREDI nao ira
                   valida-lo*/
                      '<aut:numeroAutenticacao>0001</aut:numeroAutenticacao>' ||
                  '</arr:autenticacao>';

    --FECHA AS TAGS E FINALIZA O XML
    vr_dstexto := vr_dstexto || '</arr:InValidarArrecadacaoGPS>' ||
                                '</soapenv:Body>' ||
                                '</soapenv:Envelope>';

      vr_nmdatela := 'INTERNETBANK';
    -- Envia o xml
    inss0001.pc_efetua_requisicao_soap(pr_cdcooper => pr_cdcooper -- Codigo Cooperativa
                                      ,pr_cdagenci => pr_cdagenci -- Codigo Agencia
                                      ,pr_nrdcaixa => pr_nrdcaixa -- Numero Caixa
                                      ,pr_idservic => 7 -- Identificador Servico
                                      ,pr_dsservic => 'Validar GPS' -- Descricao Servico
                                      ,pr_nmmetodo => 'OutValidarArrecadacaoGPS' -- Nome Método
                                      ,pr_dstexto  => vr_dstexto -- Texto com a msg XML
                                      ,pr_msgenvio => vr_msgenvio -- Mensagem Envio
                                      ,pr_msgreceb => vr_msgreceb -- Mensagem Recebimento
                                      ,pr_movarqto => vr_movarqto -- Nome Arquivo mover
                                      ,pr_nmarqlog => vr_nmarqlog -- Nome Arquivo LOG
                                        ,pr_nmdatela => vr_nmdatela -- Nome da Tela
                                      ,pr_des_reto => pr_des_reto -- Saida OK/NOK
                                      ,pr_dscritic => pr_dscritic); -- Mensagem Erro
    --Se ocorreu erro
    IF pr_des_reto <> 'OK'
    OR TRIM(pr_dscritic) IS NOT NULL THEN

      /* Tratamento para Erros Genericos do SICREDI */
      IF pr_dscritic LIKE '%LPX-00229%'
      OR pr_dscritic LIKE '%GenericJDBCException%'
      OR pr_dscritic LIKE '%hibernate.exception%' THEN
         pr_dscritic := 'ATENÇÃO: Falha na execucao do metodo de Validar GPS! ERR-SVC';
      END IF;

      RAISE vr_exc_saida;
    END IF;

    --Verifica Falha no Pacote
    inss0001.pc_obtem_fault_packet(pr_cdcooper => pr_cdcooper -- Codigo Cooperativa
                                    ,pr_nmdatela => vr_nmdatela -- Nome da Tela
                                  ,pr_cdagenci => pr_cdagenci -- Codigo Agencia
                                  ,pr_nrdcaixa => pr_nrdcaixa -- Numero Caixa
                                  ,pr_dsderror => 'SOAP-ENV:-950' -- Descricao Servico
                                  ,pr_msgenvio => vr_msgenvio -- Mensagem Envio
                                  ,pr_msgreceb => vr_msgreceb -- Mensagem Recebimento
                                  ,pr_movarqto => vr_movarqto -- Nome Arquivo mover
                                  ,pr_nmarqlog => vr_nmarqlog -- Nome Arquivo log
                                  ,pr_des_reto => pr_des_reto -- Saida OK/NOK
                                  ,pr_dscritic => pr_dscritic); -- Mensagem Erro
    --Se ocorreu erro
    IF pr_des_reto <> 'OK'
    OR TRIM(pr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    ELSE
      BEGIN
      /** Valida SOAP retornado pelo WebService **/
      gene0002.pc_arquivo_para_xml (pr_nmarquiv => vr_msgreceb    --> Nome do caminho completo)
                                   ,pr_xmltype  => vr_xml         --> Saida para o XML
                                   ,pr_des_reto => pr_des_reto    --> Descrição OK/NOK
                                   ,pr_dscritic => pr_dscritic    --> Descricao Erro
                                   ,pr_tipmodo  => 2);

      --Se ocorreu erro
      IF pr_des_reto <> 'OK'
      OR TRIM(pr_dscritic) IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;

      --Realizar o Parse do Arquivo XML
      vr_xmldoc := xmldom.newdomdocument(vr_xml);

      -- Busca o primeiro nível
      vr_nodo := xmldom.makenode(vr_xmldoc);

      -- TAG
      vr_nodo := xmldom.getFirstChild(vr_nodo); -- TAG <S:Envelope/>
      vr_nodo := xmldom.getFirstChild(vr_nodo); -- TAG <S:Body/>

      vr_nodo := xmldom_getChildNodeLike(vr_nodo, '%OutValidarArrecadacaoGPS'); -- TAG <ns7:OutValidarArrecadacaoGPS/>
      vr_nodo := xmldom_getChildNodeLike(vr_nodo, '%gpsValida'); -- TAG <ns7:gpsValida/>
      vr_nodo := xmldom.getFirstChild(vr_nodo); -- Texto da TAG

      --Se o retorno da tag não for TRUE
      IF XMLDOM.getNodeValue(vr_nodo) IS NULL OR XMLDOM.getNodeValue(vr_nodo) <> 'true' THEN
        RAISE vr_exc_saida;
      END IF;

      EXCEPTION
        WHEN OTHERS THEN
                  
        pr_dscritic := 'Validacao de GPS nao efetuada.';

        RAISE vr_exc_saida;
      END;
    END IF;

    -- Elimina os arquivos utilizados para requisição
    inss0001.pc_elimina_arquivos_requis(pr_cdcooper => pr_cdcooper -- Codigo Cooperativa
                                         ,pr_cdprogra => vr_nmdatela -- Codigo Programa
                                       ,pr_msgenvio => vr_msgenvio -- Mensagem Envio
                                       ,pr_msgreceb => vr_msgreceb -- Mensagem Recebimento
                                       ,pr_movarqto => vr_movarqto -- Nome Arquivo mover
                                       ,pr_nmarqlog => vr_nmarqlog -- Nome Arquivo Log
                                       ,pr_des_reto => pr_des_reto -- Saida OK/NOK
                                       ,pr_dscritic => pr_dscritic); -- Mensagem Erro

    IF pr_des_reto <> 'OK'
    OR TRIM(pr_dscritic) IS NOT NULL THEN
      --Retorno NOK
      RAISE vr_exc_saida;
    END IF;


    -- Se necessita chamar Arrecada GPS
    IF pr_indpagto = 'P' THEN

       pc_gps_arrecadar_sicredi(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_idorigem => pr_idorigem
                               ,pr_dtmvtolt => pr_dtmvtolt
                                 ,pr_nmdatela => vr_nmdatela
                               ,pr_cdoperad => pr_cdoperad
                               ,pr_inproces => pr_inproces
                               ,pr_idleitur => pr_idleitur
                               ,pr_cddpagto => pr_cddpagto
                               ,pr_cdidenti => pr_cdidenti
                               ,pr_dtvencto => pr_dtvencto
                               ,pr_cdbarras => pr_cdbarras
                               ,pr_dslindig => pr_dslindig
                               ,pr_mmaacomp => vr_mmaacomp
                               ,pr_vlrdinss => pr_vlrdinss
                               ,pr_vlrouent => pr_vlrouent
                               ,pr_vlrjuros => pr_vlrjuros
                               ,pr_vlrtotal => pr_vlrtotal
                               ,pr_idseqttl => pr_idseqttl
                               ,pr_tpdpagto => pr_tpdpagto
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_inpesgps => pr_inpesgps
                               ,pr_nrseqagp => pr_nrseqagp
                               ,pr_dslitera => pr_dslitera
                               ,pr_sequenci => pr_sequenci
                               ,pr_nrseqaut => pr_nrseqaut
                               ,pr_cdcritic => pr_cdcritic
                               ,pr_dscritic => pr_dscritic
                               ,pr_des_reto => pr_des_reto);

        IF pr_des_reto <> 'OK'
        OR TRIM(pr_dscritic) IS NOT NULL THEN
          --Retorno NOK

          RAISE vr_exc_saida;
        END IF;

    END IF;
    END IF;
    ----------------------------
    -- Retorno OK
    pr_des_reto := 'OK';


  EXCEPTION
    WHEN vr_exc_saida THEN

      IF pr_idorigem = 2 THEN
        pr_dscritic := REPLACE(REPLACE(pr_dscritic,'(NEGOCIO)','(SICREDI)'),'(VALIDACAO)','(SICREDI)');
      END IF;
      -- Retorno não OK
      pr_des_reto := 'NOK';

    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_reto := 'NOK';

      --Monta mensagem de critica
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na INSS0002.pc_gps_validar_sicredi --> ' || SQLERRM;

  END pc_gps_validar_sicredi;


  PROCEDURE pc_gps_arrecadar_sicredi(pr_cdcooper IN crapcop.cdcooper%TYPE
                                    ,pr_cdagenci IN NUMBER
                                    ,pr_nrdcaixa IN VARCHAR2
                                    ,pr_idorigem IN NUMBER
                                    ,pr_dtmvtolt IN DATE
                                    ,pr_nmdatela IN VARCHAR2
                                    ,pr_cdoperad IN VARCHAR2
                                    ,pr_inproces IN NUMBER    -- 1-On-line / Maior que 2 -> Batch
                                    ,pr_idleitur IN NUMBER
                                    ,pr_cddpagto IN VARCHAR2
                                    ,pr_cdidenti IN VARCHAR2
                                    ,pr_dtvencto IN DATE
                                    ,pr_cdbarras IN VARCHAR2
                                    ,pr_dslindig IN VARCHAR2
                                    ,pr_mmaacomp IN VARCHAR2
                                    ,pr_vlrdinss IN NUMBER
                                    ,pr_vlrouent IN NUMBER
                                    ,pr_vlrjuros IN NUMBER
                                    ,pr_vlrtotal IN NUMBER
                                    ,pr_idseqttl IN NUMBER
                                    ,pr_tpdpagto IN NUMBER -- (1 - com cod.barra, 2 - sem cod.barra)
                                    ,pr_nrdconta IN NUMBER
                                    ,pr_inpesgps IN NUMBER
                                    ,pr_nrseqagp IN NUMBER
                                    ,pr_dslitera OUT VARCHAR2
                                    ,pr_sequenci OUT NUMBER
                                    ,pr_nrseqaut OUT NUMBER
                                    ,pr_cdcritic OUT PLS_INTEGER -- Código da crítica
                                    ,pr_dscritic OUT VARCHAR2 -- Descrição da crítica
                                    ,pr_des_reto OUT VARCHAR2 -- Saida OK/NOK
                                     ) IS

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cop.cdagesic
            ,TRUNC(SYSDATE) + 1 / 86400 * cop.hrinigps hrinigps
            ,TRUNC(SYSDATE) + 1 / 86400 * cop.hrfimgps hrfimgps
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    --Registro tipo Data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Busca dos dados do associado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa
            ,ass.vllimcre
            ,ass.nrdctitg
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    --Tabela de Saldos
    vr_tab_saldos extr0001.typ_tab_saldos;

    vr_raizcoop VARCHAR2(255);
    vr_msgenvio VARCHAR2(255);
    vr_msgreceb VARCHAR2(255);
    vr_movarqto VARCHAR2(255);
    vr_nmarqlog VARCHAR2(255);
    vr_dstiparr VARCHAR2(255);
    vr_mmaacomp VARCHAR2(6);
    vr_vlsldisp NUMBER(25, 2);
    vr_cddpagto VARCHAR2(50)    := pr_cddpagto;
    vr_cdidenti VARCHAR2(20)    := pr_cdidenti;
    vr_idarrgps NUMBER(10)      := 0;
    vr_dsorigem VARCHAR2(100)   := gene0001.vr_vet_des_origens(pr_idorigem);
    vr_dsmsglog VARCHAR2(32767) := '';
    vr_nrautsic NUMBER(5)       :=0; -- Numero Sequencial para enviar ao Sicredi
    vr_busca    VARCHAR2(50);

    vr_dtdenvio VARCHAR2(19);

    vr_registro ROWID;
    vr_craplgp_rowid ROWID;
    rw_craplot cr_craplot%ROWTYPE;

    vr_cdagenci craplcm.cdagenci%TYPE;
    vr_cdhistor craplcm.cdhistor%TYPE;
    vr_cdoperad craplcm.cdoperad%TYPE;

    --Variáveis para trabalhar com XML/SOAP
    vr_dstexto VARCHAR2(32767);
    vr_xml     xmltype; --> XML de requisição

    --Variaveis Documentos DOM
    vr_xmldoc     xmldom.domdocument;
    vr_nodo       xmldom.domnode;

    --Tabela de erros
    vr_tab_erro gene0001.typ_tab_erro;

    vr_idprglog   tbgen_prglog.idprglog%TYPE := 0;

  BEGIN
    pr_des_reto := 'NOK';

    /*-------------------BUSCA COOPERATIVA--------------------*/
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
      INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      pr_cdcritic := 651;
      -- Busca critica
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    /*----------------------BUSCA DATA------------------------*/
    -- Verifica se a data esta cadastrada
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    -- Se nao encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      pr_cdcritic := 1;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
    /*--------------------BUSCA ASSOCIADO---------------------*/
    IF pr_nrdconta > 0 THEN
      --Selecionar Associado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass
        INTO rw_crapass;
      CLOSE cr_crapass;
    END IF;
    /*--------------------------------------------------------*/

    IF LENGTH(pr_cddpagto) = 0 THEN
      vr_cddpagto := CASE
                       WHEN LENGTH(pr_cdbarras) > 0 THEN
                        SUBSTR(pr_cdbarras, 20, 4)
                       ELSE
                        SUBSTR(pr_dslindig, 21, 3) || SUBSTR(pr_dslindig, 25, 1)
                     END;
    END IF;

    IF LENGTH(pr_cdidenti) = 0 THEN
      vr_cdidenti := CASE
                       WHEN LENGTH(pr_cdbarras) > 0 THEN
                        SUBSTR(pr_cdbarras, 24, 14)
                       ELSE
                        SUBSTR(pr_dslindig, 26, 14)
                     END;
    END IF;

    vr_mmaacomp := lpad(pr_mmaacomp,6,'0');

    vr_raizcoop := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => NULL);
    vr_nmarqlog := vr_raizcoop || '/log/' || 'SICREDI_Soap_LogErros.log';

    -- Alterado por Renato Darosci - 05/09/2016 - SD 514294
    /******************************************************************
    vr_msgenvio := vr_raizcoop || '/arq/' ||
                     'INSS.SOAP.GPS.' ||   -- ENVIO ARRECADACAO
                   to_char(pr_dtmvtolt, 'yyyymmdd') || '.' ||
                   to_char(SYSDATE,'SSSSS')         ||
                   to_char(SYSTIMESTAMP,'FF6')      || '.' ||
                   pr_cdoperad;
    vr_msgreceb := vr_raizcoop || '/arq/' ||
                     'INSS.SOAP.GPS.' ||   -- RECEBIMENTO ARRECADACAO
                   to_char(pr_dtmvtolt, 'yyyymmdd') || '.' ||
                   to_char(SYSDATE,'SSSSS')         ||
                   to_char(SYSTIMESTAMP,'FF6')      || '.' ||
                   pr_cdoperad;
    *******************************************************************/
    vr_msgenvio := vr_raizcoop || '/arq/' ||
                   'GPS.' ||   -- ENVIO ARRECADACAO
                   LPAD(vr_cdidenti,14,'0') || '.' ||
                   to_char(pr_dtmvtolt, 'RRRRMMDD') || '.' ||
                   to_char(SYSTIMESTAMP, 'hh24miss.FF6') || '.' ||
                   'E.A.' ||
                   pr_cdoperad;
    vr_msgreceb := vr_raizcoop || '/arq/' ||
                   'GPS.' ||   -- RECEBIMENTO ARRECADACAO
                   LPAD(vr_cdidenti,14,'0') || '.' ||
                   to_char(pr_dtmvtolt, 'RRRRMMDD') || '.' ||
                   to_char(SYSTIMESTAMP, 'hh24miss.FF6') || '.' ||
                   'R.A.' ||
                   pr_cdoperad;

    vr_movarqto := vr_raizcoop || '/salvar/gps/';

    /* APESAR DE A TAG DataVencimento SIGNIFICAR  QUE DEVE SER INFORMADA
       A DATA DE VENCIMENTO DA GUIA GPS, O SICREDI UTILIZA ESSA TAG PARA
       A DATA DE PAGAMENTO DA GUIA GPS JUNTO A RECEITA FEDERAL. POR ISSO
       DEVE SER INFORMADA A DATA DO DIA NESSA TAG AO ENVIAR PARA SICREDI  */
    vr_dtdenvio := to_char(pr_dtmvtolt,'YYYY-MM-DD') || 'T' || to_char(sysdate,'hh24:mi:ss');
                   -- to_char(pr_dtvencto,'YYYY-MM-DD') ;


    IF pr_idorigem = 2 THEN
      -- 2 - CAIXA
      IF pr_tpdpagto = 2 THEN -- 2-Sem Cod Barras
        vr_dstiparr := 'MANUAL BOCA DE CAIXA E RETAGUARDA';
      ELSE
        vr_dstiparr := 'GPS COM CODIGO DE BARRAS GUICHE DE CAIXA';
      END IF;
    ELSIF pr_idorigem = 3 THEN
      -- 3 - INTERNET BANK
      IF pr_tpdpagto = 2 THEN -- 2-Sem Cod Barras
        vr_dstiparr := 'ELETRONICA';
      ELSE
        vr_dstiparr := 'GPS COM CODIGO DE BARRAS ELETRONICA';
      END IF;
    END IF;


    -- Hora atual deve estar entre o horário limite cadastrado na CRAPCOP
    -- e INPROCESS "on-line", caso contrario, nao precisa.
    IF pr_inproces = 1 -- On-line
    AND SYSDATE NOT BETWEEN rw_crapcop.hrinigps AND rw_crapcop.hrfimgps THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Pagamento fora do horário limite para arrecadação de GPS! (De ' ||
                     to_char(rw_crapcop.hrinigps, 'HH24:MI') || 'h até ' ||
                     to_char(rw_crapcop.hrfimgps, 'HH24:MI') || 'h)';
      RAISE vr_exc_saida;
    END IF;

    --Verificar o saldo + limite, e este deve ser maior ou igual ao valor a ser pago
    IF pr_nrdconta > 0 THEN
      --Obter Saldo do Dia
      extr0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper
                                 ,pr_rw_crapdat => rw_crapdat
                                 ,pr_cdagenci   => pr_cdagenci
                                 ,pr_nrdcaixa   => pr_nrdcaixa
                                 ,pr_cdoperad   => pr_cdoperad
                                 ,pr_nrdconta   => pr_nrdconta
                                 ,pr_vllimcre   => rw_crapass.vllimcre
                                 ,pr_dtrefere   => rw_crapdat.dtmvtopr
                                 ,pr_des_reto   => pr_des_reto
                                 ,pr_tab_sald   => vr_tab_saldos
                                 ,pr_tipo_busca => 'A'
                                 ,pr_tab_erro   => vr_tab_erro);
      -- Verifica se deu erro
      IF pr_des_reto <> 'OK'
      OR TRIM(pr_dscritic) IS NOT NULL THEN
        pr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        pr_cdcritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        RAISE vr_exc_saida;
      END IF;

      --Total disponivel recebe valor disponivel + limite credito
      vr_vlsldisp := NVL(vr_tab_saldos(vr_tab_saldos.first).vlsddisp, 0) +
                     NVL(vr_tab_saldos(vr_tab_saldos.first).vllimcre, 0);

      --Valor a Pagar Maior Soma total
      IF NVL(pr_vlrtotal, 0) > NVL(vr_vlsldisp, 0) THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Sem saldo para pagamento da Guia da Previdência Social (GPS)';
        RAISE vr_exc_saida;
      END IF;

    END IF;


      /*Atualiza pagamento*/
    pc_atualiza_pagamento(pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => pr_dtmvtolt
                         ,pr_cdagenci => pr_cdagenci
                         ,pr_nrdcaixa => pr_nrdcaixa
                         ,pr_cdoperad => pr_cdoperad
                         ,pr_cdidenti => pr_cdidenti
                         ,pr_idleitur => pr_idleitur
                         ,pr_cddpagto => pr_cddpagto
                         ,pr_mmaacomp => vr_mmaacomp
                         ,pr_vlrdinss => pr_vlrdinss
                         ,pr_vlrouent => pr_vlrouent
                         ,pr_vlrjuros => pr_vlrjuros
                         ,pr_vlrtotal => pr_vlrtotal
                         ,pr_tpdpagto => pr_tpdpagto
                         ,pr_cdbarras => pr_cdbarras
                         ,pr_dslindig => pr_dslindig
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_inpesgps => pr_inpesgps
                         ,pr_idseqttl => pr_idseqttl
                         ,pr_dtvencto => pr_dtvencto
                         ,pr_dstiparr => vr_dstiparr
                         ,pr_nmdatela => pr_nmdatela
                         ,pr_inproces => pr_inproces
                         ,pr_nrseqagp => pr_nrseqagp
                         ,pr_craplgp_rowid => vr_craplgp_rowid
                         ,pr_craplot => rw_craplot
                         ,pr_dslitera => pr_dslitera
                         ,pr_sequenci => pr_sequenci
                         ,pr_nrseqaut => pr_nrseqaut
                         ,pr_registro => vr_registro
                         ,pr_cdcritic => pr_cdcritic
                         ,pr_dscritic => pr_dscritic
                         ,pr_des_reto => pr_des_reto);

    --Se ocorreu erro
    IF pr_des_reto <> 'OK'
    OR TRIM(pr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Grava autenticacao na internet
    cxon0000.pc_grava_autenticacao_internet(pr_cooper       => pr_cdcooper --Codigo Cooperativa
                                           ,pr_nrdconta     => pr_nrdconta --Numero da Conta
                                           ,pr_idseqttl     => pr_idseqttl --Sequencial do titular
                                           ,pr_cod_agencia  => pr_cdagenci --Codigo Agencia
                                           ,pr_nro_caixa    => pr_nrdcaixa --Numero do caixa
                                           ,pr_cod_operador => pr_cdoperad --Codigo Operador
                                           ,pr_valor        => pr_vlrtotal --Valor da transacao
                                           ,pr_docto        => pr_sequenci -- NRSEQDIG da LOT
                                           ,pr_operacao     => FALSE --Indicador Operacao Debito
                                           ,pr_status       => '1' --Status da Operacao - Online
                                           ,pr_estorno      => FALSE --Indicador Estorno
                                           ,pr_histor       => 1414 --Historico
                                           ,pr_data_off     => NULL --Data Transacao
                                           ,pr_sequen_off   => 0 --Sequencia
                                           ,pr_hora_off     => 0 --Hora transacao
                                           ,pr_seq_aut_off  => 0 --Sequencia automatica
                                           ,pr_cdempres     => NULL --Descricao Observacao
                                           ,pr_literal      => pr_dslitera --Descricao literal lcm
                                           ,pr_sequencia    => pr_nrseqaut --Sequencia
                                           ,pr_registro     => vr_registro --ROWID
                                           ,pr_cdcritic     => pr_cdcritic --Código do erro
                                           ,pr_dscritic     => pr_dscritic); --Descricao do erro

      -- se encontrou erro ao buscar lote, abortar programa
    IF pr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_saida;
    ELSE
      pr_des_reto := 'OK';

      -- Completa literal com o Identificador
      pr_dslitera := pr_dslitera || pr_cdidenti;


      -- Nr Sequencial para enviar no XML do SICREDI apenas
      vr_busca    :=  TRIM(pr_cdcooper)    || ';' ||
                      TO_char(rw_crapdat.dtmvtocd,'dd/mm/yyyy');
      vr_nrautsic := fn_sequence('CRAPLGP','NRAUTSIC',vr_busca);

      /* Grava id da arrecadacao da gps do sicredi na lgp */
      BEGIN
        UPDATE craplgp lgp
           SET lgp.nrautdoc = pr_nrseqaut  -- ID autenticacao CECRED
             , lgp.nrautsic = vr_nrautsic  -- ID autenticacao apenas para envio ao SICREDI
         WHERE lgp.rowid = vr_craplgp_rowid;
        --Se nao atualizou registro
        IF SQL%ROWCOUNT = 0 THEN
           pr_cdcritic:= 0;
           pr_dscritic:= 'Erro Sistema - LGP nao Encontrado!';
           RAISE vr_exc_saida;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic:= 0;
          pr_dscritic:= 'Erro ao atualizar LGP!. Erro: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

    END IF;

    -- CAIXA
    IF pr_idorigem = 2 THEN
      vr_cdagenci := pr_cdagenci;
      vr_cdhistor := 540; -- (DEB. GPS INSS)
      vr_cdoperad := pr_cdoperad;
    -- INTERNET BANK
    ELSIF pr_idorigem = 3 THEN
      vr_cdagenci := 90;
      vr_cdhistor := 508; -- (PG.P/INTERNET)
      vr_cdoperad := '996';
    END IF;


    --Se informou conta, efetua lançamento na conta
    IF pr_nrdconta > 0 THEN
      BEGIN
        --CRAPLCM##CRAPLCM1
        --CDCOOPER, DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRDCTABB, NRDOCMTO
        INSERT INTO craplcm
            (cdcooper
            ,dtmvtolt
            ,cdagenci
            ,cdbccxlt
            ,nrdolote
            ,nrdctabb
            ,nrdocmto
            ,vllanmto
            ,nrdconta
            ,cdhistor
            ,cdoperad
            ,nrseqdig
            ,nrdctitg
            ,dscedent
            ,cdpesqbb)
        VALUES (
             pr_cdcooper         -- CDCOOPER
            ,rw_craplot.dtmvtolt -- DTMVTOLT
            ,vr_cdagenci         -- CDAGENCI
            ,rw_craplot.cdbccxlt -- CDBCCXLT
            ,rw_craplot.nrdolote -- NRDOLOTE
            ,pr_nrdconta         -- NRDCTABB
            ,pr_nrseqaut         -- NRDOCMTO
            ,pr_vlrtotal
            ,pr_nrdconta
            ,vr_cdhistor
            ,vr_cdoperad
            ,rw_craplot.nrseqdig + 1
            ,TRIM(rw_crapass.nrdctitg)
            ,'GPS – Identificador ' || pr_cdidenti -- (campo beneficiario do formulário);
            ,vr_dsorigem || ' - PAGAMENTO ON-LINE – GUIA PREVIDENCIA SOCIAL'
            );
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic:= 0;
          vr_dsmsglog:= 'Erro ao atualizar LCM.' || pr_nrseqaut;
          RAISE vr_exc_saida;
      END;

      -- Atualiza o registro de movimento da internet
      paga0001.pc_insere_movimento_internet(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_idseqttl => pr_idseqttl
                                           ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                           ,pr_cdoperad => vr_cdoperad
                                           ,pr_inpessoa => rw_crapass.inpessoa
                                           ,pr_tpoperac => 2 -- Pagamento
                                           ,pr_vllanmto => pr_vlrtotal
                                           ,pr_dscritic => pr_dscritic);
                                           
       IF TRIM(pr_dscritic) IS NOT NULL THEN
         RAISE vr_exc_saida;
    END IF;

    END IF;

    -- Gerar cabeçalho do envelope SOAP
    inss0001.pc_gera_cabecalho_soap(pr_idservic => 5 -- idservic
                                   ,pr_nmmetodo => 'arr:InArrecadarGPS' -- Nome Metodo
                                   ,pr_username => vr_usr_sicredi -- Username
                                   ,pr_password => vr_pwd_sicredi -- Password
                                   ,pr_dstexto  => vr_dstexto -- Texto do Arquivo de Dados
                                   ,pr_des_reto => pr_des_reto -- Retorno OK/NOK
                                   ,pr_dscritic => pr_dscritic); -- Descricao da Critica
    --Se ocorreu erro
    IF pr_des_reto <> 'OK'
    OR TRIM(pr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    /*Monta as tags de envio
    OBS.: O valor das tags deve respeitar a formatacao presente na
          base do SICREDI do contrario, a operacao nao sera
          realizada. */

    /* BLOCO: v1:UnidadeAtendimento */
    vr_dstexto := vr_dstexto ||
                  '<v1:UnidadeAtendimento>' ||
                  '<v1:Cooperativa>' ||
                    '<v1:CodigoCooperativa>' || rw_crapcop.cdagesic || '</v1:CodigoCooperativa>' ||
                  '</v1:Cooperativa>' ||
                 /*Devido a limitacao do SICREDI, PA com no maximo dois digitos, foi
                                                   definido que sempre sera enviado o PA 2 (Sem os zeros) ao inves
                                                   do par_cdagenci.*/
                  '<v1:NumeroUnidadeAtendimento>2</v1:NumeroUnidadeAtendimento>' ||
                  '</v1:UnidadeAtendimento>';

    /* BLOCO: arr:guiaPrevidenciaSocial */
    IF NVL(TRIM(pr_cdbarras),' ') <> ' ' THEN
      -- Com Código de barras
      vr_dstexto := vr_dstexto ||
                    '<arr:guiaPrevidenciaSocial v15:ID="0">' ||
                      '<v15:CodigoBarra>'   || pr_cdbarras || '</v15:CodigoBarra>' ||
                      '<v15:FormaCaptacao>' || vr_dstiparr || '</v15:FormaCaptacao>' ||
                    '</arr:guiaPrevidenciaSocial>';
    ELSIF NVL(TRIM(pr_dslindig),' ') <> ' ' THEN
      -- Com Linha Digitavel
      vr_dstexto := vr_dstexto ||
                    '<arr:guiaPrevidenciaSocial v15:ID="0">' ||
                      '<v15:LinhaDigitada>' || pr_dslindig || '</v15:LinhaDigitada>' ||
                      '<v15:FormaCaptacao>' || vr_dstiparr || '</v15:FormaCaptacao>' ||
                    '</arr:guiaPrevidenciaSocial>';
    ELSE
      -- Digitação Manual
      vr_dstexto := vr_dstexto ||
                    '<arr:guiaPrevidenciaSocial v15:ID="0">' ||
                      '<v15:IdentificacaoPessoa>' || vr_cdidenti || '</v15:IdentificacaoPessoa>' ||
                      '<v15:Receita>' || vr_cddpagto || '</v15:Receita>' ||
                     /*Mesmo que nao haja valor, somos obrigados a enviar "0" pois o SICREDI nao aceita valor nulo.*/
                      '<v15:ValorPrincipal>' || REPLACE(REPLACE(NVL(pr_vlrdinss, '0'), '.', ''),',','.') ||
                       '</v15:ValorPrincipal>' ||

                      '<v15:DataVencimento>' || vr_dtdenvio || '</v15:DataVencimento>' ||

                      '<v15:AtualizacaoMonetaria>' || REPLACE(REPLACE(NVL(pr_vlrjuros, '0'), '.', ''),',','.') ||
                       '</v15:AtualizacaoMonetaria>' ||

                      '<v15:Competencia>' || vr_mmaacomp || '</v15:Competencia>' ||

                      '<v15:ValorOutrasEntidades>' || REPLACE(REPLACE(NVL(pr_vlrouent, '0'), '.', ''),',','.') ||
                       '</v15:ValorOutrasEntidades>' ||

                      '<v15:FormaCaptacao>' || vr_dstiparr || '</v15:FormaCaptacao>' ||
                    '</arr:guiaPrevidenciaSocial>';
    END IF;

    vr_dstexto := vr_dstexto ||
                  '<arr:canal>TERMINAL_FINANCEIRO</arr:canal>' ||
                  '<arr:formaPagamento>DINHEIRO</arr:formaPagamento>' ||
                  '<arr:aceitaGpsArrecadada>NAO</arr:aceitaGpsArrecadada>';

    /* BLOCO: arr:autenticacao */
    vr_dstexto := vr_dstexto ||
                  '<arr:autenticacao>' ||
                      '<aut:usuario>CECR</aut:usuario>' || -- No Máximo 4 Letras/números
                      '<aut:terminal>1</aut:terminal>' ||
                      '<aut:numeroAutenticacao>' || to_char( vr_nrautsic) || '</aut:numeroAutenticacao>' ||
                  '</arr:autenticacao>';

    --FECHA AS TAGS E FINALIZA O XML
    vr_dstexto := vr_dstexto || '</arr:InArrecadarGPS>' ||
                                '</soapenv:Body>' ||
                                '</soapenv:Envelope>';

    -- Envia o xml
    inss0001.pc_efetua_requisicao_soap(pr_cdcooper => pr_cdcooper -- Codigo Cooperativa
                                      ,pr_cdagenci => pr_cdagenci -- Codigo Agencia
                                      ,pr_nrdcaixa => pr_nrdcaixa -- Numero Caixa
                                      ,pr_idservic => 7 -- Identificador Servico
                                      ,pr_dsservic => 'Arrecadar GPS' -- Descricao Servico
                                      ,pr_nmmetodo => 'OutArrecadacaoGPSINSS' -- Nome Método
                                      ,pr_dstexto  => vr_dstexto -- Texto com a msg XML
                                      ,pr_msgenvio => vr_msgenvio -- Mensagem Envio
                                      ,pr_msgreceb => vr_msgreceb -- Mensagem Recebimento
                                      ,pr_movarqto => vr_movarqto -- Nome Arquivo mover
                                      ,pr_nmarqlog => vr_nmarqlog -- Nome Arquivo LOG
                                      ,pr_nmdatela => pr_nmdatela -- Nome da Tela
                                      ,pr_des_reto => pr_des_reto -- Saida OK/NOK
                                      ,pr_dscritic => pr_dscritic); -- Mensagem Erro
    --Se ocorreu erro
    IF pr_des_reto <> 'OK'
    OR TRIM(pr_dscritic) IS NOT NULL THEN

      /* Tratamento para Erros Genericos do SICREDI */
      IF pr_dscritic LIKE '%LPX-00229%'
      OR pr_dscritic LIKE '%GenericJDBCException%'
      OR pr_dscritic LIKE '%hibernate.exception%' THEN
         pr_dscritic := 'ATENÇÃO: Falha na execucao do metodo de Validar GPS! ERR-SVC';
      END IF;

      RAISE vr_exc_saida;
    END IF;

    --Verifica Falha no Pacote
    inss0001.pc_obtem_fault_packet(pr_cdcooper => pr_cdcooper -- Codigo Cooperativa
                                  ,pr_nmdatela => pr_nmdatela -- Nome da Tela
                                  ,pr_cdagenci => pr_cdagenci -- Codigo Agencia
                                  ,pr_nrdcaixa => pr_nrdcaixa -- Numero Caixa
                                  ,pr_dsderror => 'SOAP-ENV:-950' -- Descricao Servico
                                  ,pr_msgenvio => vr_msgenvio -- Mensagem Envio
                                  ,pr_msgreceb => vr_msgreceb -- Mensagem Recebimento
                                  ,pr_movarqto => vr_movarqto -- Nome Arquivo mover
                                  ,pr_nmarqlog => vr_nmarqlog -- Nome Arquivo log
                                  ,pr_des_reto => pr_des_reto -- Saida OK/NOK
                                  ,pr_dscritic => pr_dscritic); -- Mensagem Erro
    --Se ocorreu erro
    IF pr_des_reto <> 'OK'
    OR TRIM(pr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    ELSE

      /** Valida SOAP retornado pelo WebService **/
      gene0002.pc_arquivo_para_xml (pr_nmarquiv => vr_msgreceb    --> Nome do caminho completo)
                                   ,pr_xmltype  => vr_xml         --> Saida para o XML
                                   ,pr_des_reto => pr_des_reto    --> Descrição OK/NOK
                                   ,pr_dscritic => pr_dscritic    --> Descricao Erro
                                   ,pr_tipmodo  => 2);

      --Se ocorreu erro
      IF pr_des_reto <> 'OK'
      OR TRIM(pr_dscritic) IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;

      --Realizar o Parse do Arquivo XML
      vr_xmldoc := xmldom.newdomdocument(vr_xml);

      -- Busca o primeiro nível
      vr_nodo := xmldom.makenode(vr_xmldoc);

      -- TAG
      vr_nodo := xmldom.getFirstChild(vr_nodo); -- TAG <S:Envelope/>
      vr_nodo := xmldom.getFirstChild(vr_nodo); -- TAG <S:Body/>

      vr_nodo := xmldom_getChildNodeLike(vr_nodo, '%OutArrecadacaoGPSINSS'); -- TAG <ns7:OutValidarArrecadacaoGPS/>
      vr_nodo := xmldom_getChildNodeLike(vr_nodo, '%id'); -- TAG <ns7:gpsValida/>
      vr_nodo := xmldom.getFirstChild(vr_nodo); -- Texto da TAG

      --Se o retorno da tag não for TRUE
      IF XMLDOM.getNodeValue(vr_nodo) IS NULL THEN
        pr_dscritic := 'Arrecadacao de GPS não efetuada!';

        RAISE vr_exc_saida;
      ELSE
        vr_idarrgps := NVL(to_number(TRIM(XMLDOM.getNodeValue(vr_nodo))), 0);
      END IF;
    END IF;


    /* Grava id da arrecadacao da gps do sicredi na lgp */
    BEGIN
      UPDATE craplgp lgp
         SET lgp.idsicred = vr_idarrgps  -- ID autenticacao SICREDI
            ,lgp.flgpagto = 1 -- TRUE/PAGO
       WHERE lgp.rowid = vr_craplgp_rowid;
      --Se nao atualizou registro
      IF SQL%ROWCOUNT = 0 THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro Sistema - LGP nao Encontrado';
         RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro ao atualizar LGP. Erro: '||SQLERRM;
        RAISE vr_exc_saida;
    END;

    pr_dslitera := REPLACE(pr_dslitera, 'XXXX', gene0002.fn_mask(vr_idarrgps,'9999'));

    -- Ajustando a string de autenticacao do SICREDI
    -- Autenticacao REC
    BEGIN
      UPDATE crapaut
         SET crapaut.dslitera = pr_dslitera
       WHERE crapaut.ROWID = vr_registro;

      --Se nao atualizou registro
      IF SQL%ROWCOUNT = 0 THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro Sistema - CRAPAUT nao Encontrado';
         RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro ao atualizar tabela crapaut. Erro: '||SQLERRM;
        RAISE vr_exc_saida;
    END;


    -- Elimina os arquivos utilizados para requisição
    inss0001.pc_elimina_arquivos_requis(pr_cdcooper => pr_cdcooper -- Codigo Cooperativa
                                       ,pr_cdprogra => pr_nmdatela -- Codigo Programa
                                       ,pr_msgenvio => vr_msgenvio -- Mensagem Envio
                                       ,pr_msgreceb => vr_msgreceb -- Mensagem Recebimento
                                       ,pr_movarqto => vr_movarqto -- Nome Arquivo mover
                                       ,pr_nmarqlog => vr_nmarqlog -- Nome Arquivo Log
                                       ,pr_des_reto => pr_des_reto -- Saida OK/NOK
                                       ,pr_dscritic => pr_dscritic); -- Mensagem Erro

    IF pr_des_reto <> 'OK'
    OR TRIM(pr_dscritic) IS NOT NULL THEN
      --Retorno NOK
      /* Se chegou ate este ponto nao deve gerar RAISE pois a guia ja consta como paga 
         no Sicredi. (Chamado 704313) - (Fabricio)
      RAISE vr_exc_saida; */
      cecred.pc_log_programa(PR_DSTIPLOG      => 'E'           --> Tipo do log: I - início; F - fim; O - ocorrência
                            ,PR_CDPROGRAMA    => 'INSS0002.pc_gps_arrecadar_sicredi'   --> Codigo do programa ou do job
                            ,pr_tpexecucao    => 3             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                            -- Parametros para Ocorrencia
                            ,pr_tpocorrencia  => 2             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
                            ,pr_cdcriticidade => 1             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                            ,pr_dsmensagem    => pr_cdcooper || ' - ' ||
                                                 pr_nrdconta || ' - ' ||
                                                 pr_cdidenti || ' - ' ||
                                                 pr_vlrdinss || ' - ' ||
                                                 vr_mmaacomp || ' - ' ||
                                                 pr_cddpagto || ' - ' ||
                                                 pr_dscritic    --> dscritic
                            ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)
                            
    END IF;

    ----------------------------
    -- Retorno OK
    pr_des_reto := 'OK';
    pr_cdcritic := 0;
    pr_dscritic := NULL;

    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => 'OK'
                        ,pr_dsorigem => vr_dsorigem
                        ,pr_dstransa => 'Arrecadar SICREDI'
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> 1/SUCESSO/TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => pr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);

  EXCEPTION
    WHEN vr_exc_saida THEN

      -- Retorno não OK
      pr_des_reto := 'NOK';
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => 'Arrecadar SICREDI'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);

    WHEN OTHERS THEN

      -- Retorno não OK
      pr_des_reto := 'NOK';

      --Monta mensagem de critica
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possível efetuar arrecadação da GPS ao beneficiário! ' || SQLCODE;

      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => 'Erro na Arrecadação:' || vr_dsmsglog || '/' || SQLERRM
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => 'Arrecadar SICREDI'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);

  END pc_gps_arrecadar_sicredi;

  /*---------------------------------------------------------------------------------------------------------------
   Autor    : Renato Darosci - Supero
   Objetivo : GPS - Consultar os dados de agentamentos do GPS
  ---------------------------------------------------------------------------------------------------------------*/
  PROCEDURE pc_gps_agmto_consulta(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                 ,pr_nrdconta   IN NUMBER
                                 ,pr_idorigem   IN NUMBER
                                 ,pr_cdoperad   IN crapope.cdoperad%TYPE
                                 ,pr_nmdatela   IN craptel.nmdatela%TYPE
                                 ,pr_cdcritic  OUT PLS_INTEGER -- Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2
                                 ,pr_retxml    OUT CLOB) IS

    -- Buscar os dados que serão retornados para a tela
    CURSOR cr_dados IS
      SELECT gps.cdcooper
           , gps.nrdconta
           , gps.rowid            dsdrowid
           , gps.nrseqagp         nrseqagp
           , lgp.cdagenci         cdagenci
           , lgp.nrdcaixa         nrdcaixa
           , lgp.cddpagto         cddpagto
           , SUBSTR(lpad(lgp.mmaacomp,6,'0'),1,2)|| '/' || SUBSTR(lpad(lgp.mmaacomp,6,'0'),3,4) dsperiod
           , lgp.cdidenti2        cdidenti
           , gps.VLTOTAL_GPS      vlrtotal
           , DECODE(lgp.inpesgps,1,'FÍSICA','JURÍDICA') dspesgps
           ,  gps.dtdebito        nrdiaesc
           , gps.insituacao       insituac
           , DECODE(gps.insituacao,0,'ATIVA',DECODE(gps.insituacao,1,'CANCELADA','PAGA')) dssitgps
           , gps.dtcancelamento   dtcancel
        FROM tbinss_agendamento_gps gps
           , craplgp                lgp
       WHERE lgp.cdcooper = gps.cdcooper
         AND lgp.nrctapag = gps.nrdconta
         AND lgp.nrseqagp = gps.nrseqagp
         AND lgp.flgativo = 1 -- Guia Ativa
         AND gps.nrdconta = pr_nrdconta
         AND gps.cdcooper = pr_cdcooper
         AND gps.insituacao = 0 -- ATIVA
       GROUP BY gps.cdcooper
              , gps.nrdconta
              , gps.rowid
              , gps.nrseqagp
              , lgp.cdagenci
              , lgp.nrdcaixa
              , lgp.cddpagto
              , lgp.mmaacomp
              , lgp.cdidenti2
              , gps.VLTOTAL_GPS
              , DECODE(lgp.inpesgps,1,'FÍSICA','JURÍDICA')
              , gps.dtdebito
              , gps.insituacao
              , DECODE(gps.insituacao,0,'ATIVO',DECODE(gps.insituacao,1,'CANCELADO','PAGO'))
              , gps.dtcancelamento
       ORDER BY gps.insituacao, gps.dtdebito, lgp.cddpagto;

    -- Busca os dados de detalhes que serão apresentados na tela
    CURSOR cur_detalhe(pr_cdcooper  craplau.cdcooper%TYPE
                      ,pr_nrdconta  craplau.nrdconta%TYPE
                      ,pr_nrseqagp  craplau.nrseqagp%TYPE
                      ,pr_dtcancel  tbinss_agendamento_gps.dtcancelamento%TYPE ) IS
      SELECT TO_CHAR(lau.dtmvtopg,'DD/MM/YYYY')  dtmvtopg
           , lau.insitlau
           , DECODE(lau.insitlau, 1, 'Pagamento Pendente'
                                , 2, 'Pagamento efetuado em: '||to_char(lau.dtdebito,'DD/MM/YYYY')
                                , 3, 'Pagamento cancelado em '||to_char(pr_dtcancel ,'DD/MM/YYYY')
                                   , 'Pagamento não efetivado!') dssitlau
        FROM craplau lau
       WHERE lau.cdcooper = pr_cdcooper
         AND lau.nrdconta = pr_nrdconta
         AND lau.nrseqagp = pr_nrseqagp
       ORDER BY lau.dtmvtopg ASC;

    -- Variáveis
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(500);

    vr_dstransa VARCHAR2(100) := 'Consulta de Agendamentos de GPS';
    vr_dsorigem VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_idorigem);

    -- Verificar a necessidade de conversão e retornar o texto convertido
    FUNCTION fn_convert_db_web(pr_convtext IN VARCHAR2) RETURN VARCHAR2 IS

      -- Implementar conforme necessidade
      -- Origem = 1 - AYLLOS
      -- Origem = 2 - CAIXA
      -- Origem = 3 - INTERNET
      -- Origem = 4 - CASH
      -- Origem = 5 - INTRANET (AYLLOS WEB)
      -- Origem = 6 - URA

    BEGIN
      -- Se a origem for Caixa On-line
      IF pr_idorigem = 2 THEN
        -- Retorna o texto convertido
        RETURN gene0007.fn_convert_db_web(pr_convtext);
      END IF;

      -- Retornar o texto sem conversão
      RETURN pr_convtext;

    END fn_convert_db_web;

  BEGIN

    -- Montar o XML de dados que serão exibidos na tela de agendamento do GPS
    pr_retxml := '<dados >';

    -- Percorrer todos os dados retornados pela consulta
    FOR reg IN cr_dados LOOP
      -- Conteudo dos registros
      pr_retxml := pr_retxml||'<registro>'
                            ||'  <dsdrowid>'||reg.dsdrowid||'</dsdrowid>'
                            ||'  <nrseqagp>'||reg.nrseqagp||'</nrseqagp>'
                            ||'  <cdagenci>'||reg.cdagenci||'</cdagenci>'
                            ||'  <nrdcaixa>'||reg.nrdcaixa||'</nrdcaixa>'
                            ||'  <cddpagto>'||reg.cddpagto||'</cddpagto>'
                            ||'  <dsperiod>'||fn_convert_db_web(reg.dsperiod)||'</dsperiod>'
                            ||'  <cdidenti>'||reg.cdidenti||'</cdidenti>'
                            ||'  <vlrtotal>'||TO_CHAR(reg.vlrtotal, 'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.')||'</vlrtotal>'
                            ||'  <dspesgps>'||fn_convert_db_web(reg.dspesgps)||'</dspesgps>'
                            ||'  <nrdiaesc>'||to_char(reg.nrdiaesc,'DD/MM/YYYY')||'</nrdiaesc>'
                            ||'  <insituac>'||reg.insituac||'</insituac>'
                            ||'  <dssitgps>'||fn_convert_db_web(reg.dssitgps)||'</dssitgps>'
                            ||'  <detalhes>';

      -- Percorre todos os dados de detalhes
      FOR detail IN cur_detalhe(reg.cdcooper
                               ,reg.nrdconta
                               ,reg.nrseqagp
                               ,reg.dtcancel) LOOP

        -- Informações de detalhes
        pr_retxml := pr_retxml||'<detalhe>'
                              ||'  <dtpagmto>'||detail.dtmvtopg||'</dtpagmto>'
                              ||'  <dssitlau>'||fn_convert_db_web(detail.dssitlau)||'</dssitlau>'
                              ||'  <insitlau>'||detail.insitlau||'</insitlau>'
                              ||'</detalhe>';
      END LOOP;

      -- Fecha as tags
      pr_retxml := pr_retxml||'</detalhes></registro>';

    END LOOP;

    -- Finaliza o XML
    pr_retxml := pr_retxml||'</dados>';

    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => NVL(vr_dscritic,' ')
                        ,pr_dsorigem => vr_dsorigem
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> 1/SUCESSO/TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => pr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);

  EXCEPTION
      WHEN vr_exc_saida THEN
        --Mensagem de critica
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => NVL(vr_dscritic,' ')
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0 --> ERRO/FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

      WHEN OTHERS THEN
        --Monta mensagem de critica
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro ao executar consulta: --> '|| SQLERRM;
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => NVL(pr_dscritic,' ')
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0 -- ERRO/FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

  END pc_gps_agmto_consulta;

  /*---------------------------------------------------------------------------------------------------------------
   Autor    : Renato Darosci - Supero
   Objetivo : GPS - Realizar os cancelamentos de Agendamento de GPS
  ---------------------------------------------------------------------------------------------------------------*/
  PROCEDURE pc_gps_agmto_desativar(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                  ,pr_nrdconta   IN NUMBER
                                  ,pr_idorigem   IN NUMBER
                                  ,pr_cdoperad   IN crapope.cdoperad%TYPE
                                  ,pr_nmdatela   IN craptel.nmdatela%TYPE
                                  ,pr_dsdrowid   IN VARCHAR2
								  ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE --397
                                  ,pr_dscritic  OUT VARCHAR2) IS
    
	/*
    Alterações: 
                04/09/2017 - Alterações projeto 397 - Assinatura conjunta
    */

    -- Buscar dados do agendamento
    CURSOR cr_agmto IS
      SELECT gps.cdcooper
           , gps.nrdconta
           , gps.nrseqagp
           , gps.insituacao insituac
           , gps.dtdebito
		   , gps.vltotal_gps -- 397
        FROM tbinss_agendamento_gps  gps
       WHERE gps.rowid = pr_dsdrowid;
    rw_agmto    cr_agmto%ROWTYPE;

    -- Buscar dados da GPS
    CURSOR cr_gps (p_cdcooper IN crapass.cdcooper%TYPE
                  ,p_nrdconta IN crapass.nrdconta%TYPE
                  ,p_nrseqagp IN craplgp.nrseqagp%TYPE) IS
      SELECT lgp.cddpagto
           , lgp.mmaacomp
           , lgp.cdidenti2 cdidenti
           , lgp.vlrtotal
        FROM craplgp lgp
       WHERE lgp.cdcooper = p_cdcooper
         AND lgp.nrctapag = p_nrdconta
         AND lgp.nrseqagp = p_nrseqagp;
    rw_gps    cr_gps%ROWTYPE;

	-- 397
    CURSOR cr_crapopi (prc_cdcooper       IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                      ,prc_nrdconta       IN crapass.nrdconta%TYPE --Conta do Associado
                      ,prc_nrcpfope       IN crapass.nrcpfcgc%TYPE) IS
      SELECT 1
        FROM crapopi opi
       WHERE opi.cdcooper = prc_cdcooper
         AND opi.nrdconta = prc_nrdconta
         AND opi.nrcpfope = prc_nrcpfope
         AND rownum       = 1; 

    -- Variáveis
    vr_dstransa VARCHAR2(100) := 'Cancelar Agendamentos de GPS';
    vr_dsorigem VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_idorigem);
    vr_cdcompet VARCHAR(10);
	-- 397
    va_existe_operador NUMBER;             
    vr_vldsppgo NUMBER;
    pr_tab_internet INET0001.typ_tab_internet;
    pr_cdcritic    PLS_INTEGER;  

  BEGIN

    -- Buscar dados do agendamento e validar o ROWID
    BEGIN

      -- Buscar dados do agendamento
      OPEN  cr_agmto;
      FETCH cr_agmto INTO rw_agmto;
      CLOSE cr_agmto;

    EXCEPTION
      WHEN SYS_INVALID_ROWID THEN -- Tratamento para Rowid Inválido
        pr_dscritic := 'Agendamento não encontrado!';
        RAISE vr_exc_saida;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao buscar dados do agendamento: '||SQLERRM;
        RAISE vr_exc_saida;
    END;

    -- Buscar a data do sistema
    OPEN  btch0001.cr_crapdat(rw_agmto.cdcooper);
    FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;

    -- Se não encontrar a data
    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;
      pr_dscritic := 'Erro ao buscar data do sistema. ';
      RAISE vr_exc_saida;
    END IF;

    -- Fechar o cursor
    CLOSE btch0001.cr_crapdat;


    -- Validar a situação do agendamento
    IF    NVL(rw_agmto.insituac,0) = 1 THEN
      pr_dscritic := 'Agendamento não pode ser desativado, pois já está desativado!';
      RAISE vr_exc_saida;
    ELSIF NVL(rw_agmto.insituac,0) = 2 THEN
      pr_dscritic := 'Agendamento não pode ser desativado, pois já foi pago!';
      RAISE vr_exc_saida;
    END IF;

    -- Excluir os dados do agendamento conforme informações encontradas através do Rowid e pagamento não efetuado
    -- Buscar dados da GPS
      OPEN cr_gps(rw_agmto.cdcooper, rw_agmto.nrdconta, rw_agmto.nrseqagp);
      FETCH cr_gps INTO rw_gps;
      -- Verificar se existe informacao, e gerar erro caso nao exista
      IF cr_gps%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_gps;
        -- Gerar excecao
        pr_dscritic := 'Agendamento não encontrado!';
        RAISE vr_exc_saida;
      END IF;
      -- Fechar o cursor
      CLOSE cr_gps;
      -- 397
      IF pr_nrcpfope > 0 THEN
        -- Inicializa 
        va_existe_operador := 0;
        -- Verifica se é operador
        BEGIN
          FOR rw_crapopi IN cr_crapopi(pr_cdcooper,
                                       pr_nrdconta,
                                       pr_nrcpfope) LOOP
            va_existe_operador := 1;
          END LOOP;
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic:= 0;
            pr_dscritic:= 'INSS0002.Erro ao buscar operador: '||sqlerrm;
            --Levantar Excecao
            RAISE vr_exc_saida;
        END;
        --
        IF va_existe_operador = 1 THEN


          BEGIN
          
            INET0001.pc_busca_limites_opera_trans(pr_cdcooper    => pr_cdcooper  --Codigo Cooperativa
                                                ,pr_nrdconta     => pr_nrdconta  --Numero da conta
                                                ,pr_idseqttl     => 1            --Identificador Sequencial titulo
                                                ,pr_nrcpfope     => pr_nrcpfope  --Numero do CPF
                                                ,pr_dtmvtopg     => nvl(rw_agmto.dtdebito,sysdate)  --Data do debito da folha de pagamento
                                                ,pr_dsorigem     => gene0001.vr_vet_des_origens(pr_idorigem)  --Descricao Origem
                                                ,pr_tab_internet => pr_tab_internet --Tabelas de retorno de horarios limite
                                                ,pr_cdcritic     => pr_cdcritic   --Codigo do erro
                                                ,pr_dscritic     => pr_dscritic); --Descricao do erro;
                               
            --Se ocorreu erro
            IF pr_cdcritic IS NOT NULL OR pr_dscritic IS NOT NULL THEN
              --Levantar Excecao
               RAISE vr_exc_saida;
            END IF; 
            
            IF NOT pr_tab_internet.EXISTS(1) THEN
              pr_cdcritic:= 0;
              pr_dscritic:= 'Registro de limite para validar cancelamento GPS nao encontrado.';
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF; 
            
             vr_vldsppgo := pr_tab_internet(1).vldsppgo;            
            /** Verifica se pode movimentar em relacao ao que ja foi usado **/
            IF rw_agmto.vltotal_gps > vr_vldsppgo  THEN

              pr_dscritic:= 'Operador não possui limite disponível para cancelar o agendamento do GPS';
              RAISE vr_exc_saida;            
           
            END IF;              
          END;
        END IF; 
      END IF;
    BEGIN
      -- Excluir
      DELETE craplgp lgp
       WHERE lgp.cdcooper = rw_agmto.cdcooper
         AND lgp.nrctapag = rw_agmto.nrdconta
         AND lgp.nrseqagp = rw_agmto.nrseqagp
         AND lgp.flgpagto = 0;     -- FIXO    -- Pagto não efetuado

    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro na desativação do agendamento! (e:01)';
        RAISE vr_exc_saida;
    END;

    -- Atualizar os registros da CRAPLAU para cancelado
    BEGIN

      -- Atualizar
      UPDATE craplau lau
         SET lau.insitlau = 3    -- Fixo  -- CANCELADO
            ,lau.dtdebito = btch0001.rw_crapdat.dtmvtocd
       WHERE lau.cdcooper = rw_agmto.cdcooper
         AND lau.nrdconta = rw_agmto.nrdconta
         AND lau.nrseqagp = rw_agmto.nrseqagp
         AND lau.insitlau = 1;   -- Fixo  -- PENDENTE

    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro na desativação do agendamento! (e:02)';
        RAISE vr_exc_saida;
    END;

    -- Atualizar os registros da GPS
    BEGIN

      -- Atualizar
      UPDATE tbinss_agendamento_gps gps
         SET gps.insituacao        = 1  -- Fixo -- Cancelada
           , gps.dtcancelamento    = btch0001.rw_crapdat.dtmvtocd
           , gps.cdoperador_cancel = pr_cdoperad
       WHERE gps.rowid = pr_dsdrowid;

    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro na desativação do agendamento! (e:03)';
        RAISE vr_exc_saida;
    END;

    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => 'OK'
                        ,pr_dsorigem => vr_dsorigem
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> 1/SUCESSO/TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => pr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    -- Log Item => Código Pagamento
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Cod.Pagto'
                            , pr_dsdadant => TRIM(TO_CHAR(gene0002.fn_mask(rw_gps.cddpagto,'9999')))
                            , pr_dsdadatu => '');
    -- Log Item => Competencia
    vr_cdcompet :=TRIM(TO_CHAR(gene0002.fn_mask(rw_gps.mmaacomp,'999999')));
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Competencia'
                            , pr_dsdadant => SUBSTR(vr_cdcompet,1,2)||'/'||SUBSTR(vr_cdcompet,3,4)
                            , pr_dsdadatu => '');
    -- Log Item => Identificador
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Identificador'
                            , pr_dsdadant => rw_gps.cdidenti
                            , pr_dsdadatu => '');
    -- Log Item => Valor Total
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Valor Total'
                            , pr_dsdadant => TRIM(TO_CHAR(rw_gps.vlrtotal,'999G999G999D99'))
                            , pr_dsdadatu => '');
    -- Log Item => Data Debito
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Data Debito'
                            , pr_dsdadant => TO_CHAR(rw_agmto.dtdebito,'DD/MM/YYYY')
                            , pr_dsdadatu => '');
    -- Efetivar os dados na base
    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Desfazer alterações
      ROLLBACK;
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 -- ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      COMMIT; -- Commitar o LOG

    WHEN OTHERS THEN
      -- Desfazer alterações
      ROLLBACK;
      pr_dscritic := 'Erro ao cancelar Agendamento: '||SQLERRM;
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 -- ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      COMMIT; -- Commitar o LOG
  END pc_gps_agmto_desativar;

  /*---------------------------------------------------------------------------------------------------------------
   Autor    : Renato Darosci - Supero
   Objetivo : GPS - Realizar a gravação dos Agendamentos de GPS
  ---------------------------------------------------------------------------------------------------------------*/
  PROCEDURE pc_gps_agmto_novo(pr_cdcooper   IN NUMBER
                             ,pr_nrdconta   IN NUMBER
                             ,pr_tpdpagto   IN NUMBER
                             ,pr_cdagenci   IN NUMBER
                             ,pr_nrdcaixa   IN NUMBER
                             ,pr_idseqttl   IN NUMBER
                             ,pr_idorigem   IN NUMBER
                             ,pr_cdoperad   IN VARCHAR2
                             ,pr_nmdatela   IN VARCHAR2
                             ,pr_idleitur   IN NUMBER   -- Indica se os campos vieram via Leitura Laser(1) ou Manual(0)
                             ,pr_cdbarras   IN VARCHAR2
                             ,pr_cdlindig   IN VARCHAR2
                             ,pr_cdpagmto   IN NUMBER
                             ,pr_dtcompet   IN VARCHAR2 -- Recebe como string e trata no programa
                             ,pr_dsidenti   IN VARCHAR2 -- Recebe como char para prese
                             ,pr_vldoinss   IN NUMBER
                             ,pr_vloutent   IN NUMBER
                             ,pr_vlatmjur   IN NUMBER
                             ,pr_vlrtotal   IN NUMBER
                             ,pr_dtvencim   IN VARCHAR2 -- Recebe como string e trata no programa
                             ,pr_inpesgps   IN NUMBER
                             ,pr_dtdebito   IN VARCHAR2 -- Recebe como string e trata no programa
                             ,pr_nrcpfope   IN crapopi.nrcpfope%TYPE DEFAULT 0 -- 397
                             ,pr_dslitera  OUT CLOB     -- Retornará o comprovante Agendamento quando CAIXA
                             ,pr_cdultseq  OUT NUMBER
                             ,pr_dscritic  OUT VARCHAR2) IS

     -- Tipo de tabela para vetor literal
     TYPE typ_tab_literal IS table of VARCHAR2(100) index by PLS_INTEGER;
     -- Vetor de memoria do literal
     vr_tab_literal typ_tab_literal;

     -- CURSORES
     -- Selecionar os dados da Cooperativa
     CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
       SELECT cop.cdcooper
             ,cop.nmrescop
             ,cop.nmextcop
             ,cop.cdagectl
             ,cop.nrtelsac
             ,cop.nrtelouv
             ,cop.hrinisac
             ,cop.hrfimsac
             ,cop.hriniouv
             ,cop.hrfimouv
         FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper;
     rw_crapcop cr_crapcop%ROWTYPE;

     -- Buscar informações do associado
     CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ass.cdcooper
              ,ass.nrdconta
              ,ass.cdagenci
              ,ass.inpessoa
              ,ass.nmprimtl
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
     rw_crapass cr_crapass%ROWTYPE;

     -- Selecionar informacoes do titular
     CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%type
                      ,pr_nrdconta IN crapttl.nrdconta%type
                      ,pr_idseqttl IN crapttl.idseqttl%type) IS
        SELECT ttl.nmextttl
              ,ttl.nrcpfcgc
              ,ttl.idseqttl
          FROM crapttl ttl
         WHERE ttl.cdcooper = pr_cdcooper
           AND ttl.nrdconta = pr_nrdconta
           AND ttl.idseqttl = pr_idseqttl;
     rw_crapttl cr_crapttl%ROWTYPE;


     -- Verificar a existencia do registro na tabela CRAPLGP
     CURSOR cr_craplgp(p_cdcooper   craplgp.cdcooper%TYPE
                      ,p_dtmvtolt   craplgp.dtmvtolt%TYPE
                      ,p_cdagenci   craplgp.cdagenci%TYPE
                      ,p_nrdolote   craplgp.nrdolote%TYPE
                      ,p_cdidenti   VARCHAR2
                      ,p_cddpagto   craplgp.cddpagto%TYPE
                      ,p_dtcompet   VARCHAR2
                      ,p_vlrtotal   craplgp.vlrtotal%TYPE ) IS
        SELECT 1
          FROM craplgp
         WHERE craplgp.cdcooper  = p_cdcooper
           AND craplgp.dtmvtolt  = p_dtmvtolt
           AND craplgp.cdagenci  = p_cdagenci
           AND craplgp.cdbccxlt  = 100    /* Fixo */
           AND craplgp.nrdolote  = p_nrdolote
           AND craplgp.cdidenti2 = TO_NUMBER(p_cdidenti)
           AND craplgp.mmaacomp  = to_number(p_dtcompet)
           AND craplgp.vlrtotal  = p_vlrtotal
           AND craplgp.cddpagto  = p_cddpagto
           AND craplgp.flgativo  = 1;
     rw_craplgp cr_craplgp%ROWTYPE;

     -- Buscar os dados do lote
     CURSOR cr_craplot(pr_cdcooper  craplot.cdcooper%TYPE
                      ,pr_dtmvtolt  craplot.dtmvtolt%TYPE
                      ,pr_cdagenci  craplot.cdagenci%TYPE
                      ,pr_nrdolote  craplot.nrdolote%TYPE) IS
        SELECT lot.rowid     dsdrowid
              ,lot.nrseqdig
          FROM craplot     lot
         WHERE lot.cdcooper = pr_cdcooper
           AND lot.dtmvtolt = pr_dtmvtolt
           AND lot.cdagenci = pr_cdagenci
           AND lot.cdbccxlt = 100   /* Fixo */
           AND lot.nrdolote = pr_nrdolote
           FOR UPDATE; -- Lock do registro, para preservar sequencia de NRSEQDIG
     rw_craplot    cr_craplot%ROWTYPE;

     CURSOR cr_craphec(pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_cdprogra IN craphec.cdprogra%TYPE) IS
     SELECT MAX(hec.hriniexe) hriniexe
       FROM craphec hec
      WHERE upper(hec.cdprogra) = upper(pr_cdprogra)
        AND hec.cdcooper = pr_cdcooper;
     rw_craphec cr_craphec%ROWTYPE;
     --
     CURSOR cr_crapsnh2 (prc_cdcooper crapsnh.cdcooper%type,
                         prc_nrdconta crapsnh.nrdconta%type,
                         prc_idseqttl crapsnh.idseqttl%type)IS
        SELECT c.nrcpfcgc
          FROM crapsnh c
         WHERE c.cdcooper = prc_cdcooper
           AND c.nrdconta = prc_nrdconta
           AND c.idseqttl = prc_idseqttl
           AND c.tpdsenha = 1 -- INTERNET
           ;             
     -- Variáveis
     rw_crapdat    btch0001.cr_crapdat%ROWTYPE;

     vr_cdbarras   VARCHAR2(44); -- Deve ser obrigatóriamente tratado para ter 44 caracteres
     vr_cdlindig   VARCHAR2(100);
     vr_cdlidgfm   VARCHAR2(100); -- Linha digitavel formatada
     vr_dtvencim   DATE;
     vr_dtdebito   DATE;
     vr_dtcalcul   DATE;
     vr_nrdolote   NUMBER := 11900; --(31000 + pr_nrdcaixa);
     vr_cdoperad   VARCHAR2(30);
     vr_dstiparr   VARCHAR2(255);
     vr_linbarr1   VARCHAR2(50);
     vr_linbarr2   VARCHAR2(50);
	 vr_nmsegntl   crapttl.nmextttl%TYPE;

     vr_lindigi1 VARCHAR2(50);
     vr_lindigi2 VARCHAR2(50);
     vr_lindigi3 VARCHAR2(50);
     vr_lindigi4 VARCHAR2(50);
     -- Digito verificar
     vr_validig1 PLS_INTEGER;
     vr_validig2 PLS_INTEGER;
     vr_validig3 PLS_INTEGER;
     vr_validig4 PLS_INTEGER;

     vr_mensagem   VARCHAR2(1000);

     vr_sequen   INTEGER;
     vr_busca    VARCHAR2(100);

     vr_sequen_pro NUMBER; -- Utilizado para gravar a sequencia de agendamento

     vr_dsorigem   craplau.dsorigem%TYPE;
     vr_dstransa   VARCHAR2(100) := 'Agendamento de GPS';
     vr_nrseqagp   craplau.nrseqagp%TYPE;
     vr_dscritic   VARCHAR2(32767);       -- Usar para mensagem de retorno para tela
     vr_dsmsglog   VARCHAR2(32767) := ''; -- Usar para mensagem a ser gravada no log (VERLOG)
     vr_dtcompet   VARCHAR(6);

     vr_nmextttl   VARCHAR2(100);
     vr_dsinfor1   crappro.dsinform##1%TYPE;
     vr_dsinfor2   crappro.dsinform##2%TYPE;
     vr_dsdpagto   VARCHAR2(60);
     vr_dspesgps   VARCHAR2(15);
     vr_dsprotoc   VARCHAR2(1000);
     vr_dsretorn   VARCHAR2(500) := '';
     vr_hriniexe   craphec.hriniexe%TYPE;

     vr_dslitera   VARCHAR2(500);
     vr_sequenci   NUMBER;
     vr_nrseqaut   NUMBER;
     vr_cdcritic   NUMBER;
     vr_des_reto   VARCHAR2(500);

     vr_nrcpfcgc      crapsnh.nrcpfcgc%type;

     FUNCTION fn_centraliza(pr_frase IN VARCHAR2, pr_tamlinha IN PLS_INTEGER) RETURN VARCHAR2 IS 
       vr_contastr PLS_INTEGER;
  BEGIN
       vr_contastr := TRUNC( (pr_tamlinha - LENGTH(TRIM(pr_frase))) / 2 ,0);
       RETURN LPAD(NVL(' ',' '),vr_contastr,' ')||TRIM(pr_frase);
     END fn_centraliza;          

  BEGIN
     vr_cdbarras := NVL(pr_cdbarras,' ');
     vr_cdlindig := NVL(pr_cdlindig,' ');


     -- Configurar dados conforme a origem
     IF pr_idorigem = 2 THEN
        vr_dsorigem := 'CAIXA';
        -- 2 - CAIXA
        IF pr_tpdpagto = 2 THEN -- 2-Sem Cod Barras
           vr_dstiparr := 'MANUAL BOCA DE CAIXA E RETAGUARDA';
        ELSE
           vr_dstiparr := 'GPS COM CODIGO DE BARRAS GUICHE DE CAIXA';
        END IF;
     ELSIF pr_idorigem = 3 THEN
        vr_cdoperad := '996'; -- Fixo
        vr_dsorigem := 'INTERNET';

        -- 3 - INTERNET BANK
        IF pr_tpdpagto = 2 THEN -- 2-Sem Cod Barras
           vr_dstiparr := 'ELETRONICA';
        ELSE
           vr_dstiparr := 'GPS COM CODIGO DE BARRAS ELETRONICA';
        END IF;
     END IF;


     -- Buscar dados da cooperativa e validar a existencia da mesma
     OPEN  cr_crapcop(pr_cdcooper);
     FETCH cr_crapcop INTO rw_crapcop;
     -- Se não encontrar
     IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        pr_dscritic := gene0001.fn_busca_critica(651);  -- 651 - Falta registro de controle da cooperativa - ERRO DE SISTEMA
        vr_dsmsglog := pr_dscritic; -- Mantém mesma mensagem no log
        RAISE vr_exc_saida;
     END IF;
     -- Apenas fechar o cursor
     CLOSE cr_crapcop;

     -- Buscar os dados do associado para validar
     OPEN cr_crapass(pr_cdcooper, pr_nrdconta);
     FETCH cr_crapass INTO rw_crapass;
     -- Verificar se existe informacao, e gerar erro caso nao exista
     IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapass;
        -- Gerar excecao
        pr_dscritic := gene0001.fn_busca_critica(9);  -- 009 - Associado nao cadastrado.
        vr_dsmsglog := pr_dscritic; -- Mantém mesma mensagem no log
        RAISE vr_exc_saida;
     END IF;
     -- Fechar o cursor
     CLOSE cr_crapass;

     -- Leitura do calendário da cooperativa
     OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
     FETCH btch0001.cr_crapdat INTO rw_crapdat;
     -- Se não encontrar
     IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        pr_dscritic := gene0001.fn_busca_critica(1);  -- 001 - Sistema sem data de movimento.
        vr_dsmsglog := pr_dscritic; -- Mantém mesma mensagem no log
        RAISE vr_exc_saida;
     ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
     END IF;

     -- Verificar parametro de tipo de pagamento ( 1 -> Com código de barras / 2 -> Sem código de barras )
     IF pr_tpdpagto NOT IN (1,2) THEN
        -- Gerar excecao
        pr_dscritic := 'Tipo de Pagamento inválido!';
        vr_dsmsglog := pr_dscritic; -- Mantém mesma mensagem no log
        RAISE vr_exc_saida;
     END IF;

     -- Verificar parametro de tipo de pessoa GPS ( 1 -> Física / 2 -> Jurídica )
     IF pr_inpesgps NOT IN (1,2) THEN
        -- Gerar excecao
        pr_dscritic := 'Tipo de Pessoa inválido!';
        vr_dsmsglog := pr_dscritic; -- Mantém mesma mensagem no log
        RAISE vr_exc_saida;
     END IF;

     -- Transformar a data em String para DATE
     vr_dtvencim := to_date(TRIM(pr_dtvencim),'DD/MM/YYYY');
     vr_dtdebito := to_date(pr_dtdebito,'DD/MM/YYYY');

/**** RETIRADO
     -- Validar data de Débito informada - Não pode ser fim de semana nem feriado
     IF vr_dtdebito <> gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                  ,pr_dtmvtolt => vr_dtdebito) THEN
        -- Gerar excecao
        pr_dscritic := 'Data de Débito informada deve ser dia útil!';
        RAISE vr_exc_saida;
     END IF;
****/

     IF pr_tpdpagto = 1 THEN
        -- Com Código de Barras
        vr_dsdpagto := 'Com Código de Barras';
        IF pr_idleitur = 1 THEN
           vr_dstransa := vr_dstransa || '(Leitora)';
           vr_dsdpagto := vr_dsdpagto || '(Leitora)';
        ELSE
           vr_dstransa := vr_dstransa || '(Lin.Digitável/Manual)';
           vr_dsdpagto := vr_dsdpagto || '(Lin.Digitável/Manual)';
        END IF;
     ELSE
        -- Sem Código de Barras
        vr_dstransa := vr_dstransa || '(Manual)';
        vr_dsdpagto := 'Sem Código de Barras (Manual)';
     END IF;

     -- Se o indicador for 1 - COM CÓDIGO DE BARRAS
     IF pr_tpdpagto = 1 THEN

        -- Validar o código de barras informado - Se não possuir 44 ou 48 posições
        IF TRIM(pr_cdbarras) IS NOT NULL THEN
           IF length(pr_cdbarras) <> 44 THEN
              -- Gerar excecao
              pr_dscritic := 'Código de Barras inválido ou incompleto!';
              vr_dsmsglog := pr_dscritic; -- Mantém mesma mensagem no log
              RAISE vr_exc_saida;
           ELSE
              vr_cdbarras := pr_cdbarras;
              vr_linbarr1 := '  CODIGO DE BARRAS: ' ||
                             SUBSTR(vr_cdbarras, 1,11)||'.'||SUBSTR(vr_cdbarras,12,11);
              vr_linbarr2 := '                    ' ||
                             SUBSTR(vr_cdbarras,23,11)||'.'||SUBSTR(vr_cdbarras,34,11);

              -- Formatando a linha digitavel
              /* Verifica o Digito Verificador */
              vr_lindigi1 := SUBSTR(vr_cdbarras, 1,11);
              CXON0014.pc_verifica_digito(pr_nrcalcul => vr_lindigi1
							             ,pr_poslimit => 0            --Utilizado para validação de dígito adicional de DAS
                                         ,pr_nrdigito => vr_validig1);
              /* Verifica o Digito Verificador */
              vr_lindigi2 := SUBSTR(vr_cdbarras, 12,11);
              CXON0014.pc_verifica_digito(pr_nrcalcul => vr_lindigi2
							             ,pr_poslimit => 0            --Utilizado para validação de dígito adicional de DAS
                                         ,pr_nrdigito => vr_validig2);
              /* Verifica o Digito Verificador */
              vr_lindigi3 := SUBSTR(vr_cdbarras, 23,11);
              CXON0014.pc_verifica_digito(pr_nrcalcul => vr_lindigi3
							             ,pr_poslimit => 0            --Utilizado para validação de dígito adicional de DAS
                                         ,pr_nrdigito => vr_validig3);
              /* Verifica o Digito Verificador */
              vr_lindigi4 := SUBSTR(vr_cdbarras, 34,11);
              CXON0014.pc_verifica_digito(pr_nrcalcul => vr_lindigi4
							             ,pr_poslimit => 0            --Utilizado para validação de dígito adicional de DAS
                                         ,pr_nrdigito => vr_validig4);

              /* Montando a linha digitavel para CRAPLAU*/
/*              vr_cdlidgfm := vr_lindigi1||'-'||vr_validig1||' '||
                             vr_lindigi2||'-'||vr_validig2||' '||
                             vr_lindigi3||'-'||vr_validig3||' '||
                             vr_lindigi4||'-'||vr_validig4;*/
              vr_cdlidgfm := vr_lindigi1||vr_validig1||
                             vr_lindigi2||vr_validig2||
                             vr_lindigi3||vr_validig3||
                             vr_lindigi4||vr_validig4;
           END IF;
        ELSIF TRIM(pr_cdlindig) IS NOT NULL THEN
           IF length(pr_cdlindig) <> 48 THEN
              -- Gerar excecao
              pr_dscritic := 'Linha Digitável inválida ou incompleta!';
              vr_dsmsglog := pr_dscritic; -- Mantém mesma mensagem no log
              RAISE vr_exc_saida;
           ELSE
              vr_linbarr1 := '   LINHA DIGITAVEL: ' ||
                             SUBSTR(vr_cdlindig, 1,12)||'.'||SUBSTR(vr_cdlindig,13,12);
              vr_linbarr2 := '                    ' ||
                             SUBSTR(vr_cdlindig,25,12)||'.'||SUBSTR(vr_cdlindig,37,12);
             -- Se o código de barras possuir 48 posições, deverá remover os dígitos, passando assim para 44 posições - LINHA DIGITÁVEL
             vr_cdbarras := SUBSTR(pr_cdlindig, 1,11)  ||
                            SUBSTR(pr_cdlindig,13,11)  ||
                            SUBSTR(pr_cdlindig,25,11)  ||
                            SUBSTR(pr_cdlindig,37,11);
           END IF;
        ELSE
           -- Gerar excecao
           pr_dscritic := 'Código de Barras ou Linha digitável devem ser informados!';
           vr_dsmsglog := pr_dscritic; -- Mantém mesma mensagem no log
           RAISE vr_exc_saida;
        END IF;

        -- Validar o codigo do pagamento
        IF pr_cdpagmto <> SUBSTR(vr_cdbarras,20, 4) THEN
           -- Gerar excecao
           pr_dscritic := 'Informação divergente no Código de Pagamento!';
           vr_dsmsglog := pr_dscritic; -- Mantém mesma mensagem no log
           RAISE vr_exc_saida;
        END IF;

        -- Verificar a competencia
        IF pr_dtcompet <> SUBSTR(vr_cdbarras,38, 6) THEN
           -- Gerar excecao
           pr_dscritic := 'Informação divergente no campo Competência!';
           vr_dsmsglog := pr_dscritic; -- Mantém mesma mensagem no log
           RAISE vr_exc_saida;
        END IF;

        -- Verificar o identificador do pagamento
        IF pr_dsidenti <> SUBSTR(vr_cdbarras,24,14) THEN
           -- Gerar excecao
           pr_dscritic := 'Informação divergente no campo Identificador!';
           vr_dsmsglog := pr_dscritic; -- Mantém mesma mensagem no log
           RAISE vr_exc_saida;
        END IF;

        -- Verificar o valor do INSS
        IF pr_vldoinss <> (to_number(SUBSTR(vr_cdbarras, 5,11)) / 100) THEN
           -- Gerar excecao
           pr_dscritic := 'Informação divergente no campo Valor do INSS!';
           vr_dsmsglog := pr_dscritic; -- Mantém mesma mensagem no log
           RAISE vr_exc_saida;
        END IF;

        -- Verificar se o campo de valor outras entidades está zerado
        IF pr_vloutent > 0 THEN
           -- Gerar excecao
           pr_dscritic := 'Informação divergente no campo Valor Outras Entidades!';
           vr_dsmsglog := pr_dscritic; -- Mantém mesma mensagem no log
           RAISE vr_exc_saida;
        END IF;

        -- Verificar se o campo de Atm, Juros e multa está zerado
        IF pr_vlatmjur > 0 THEN
           -- Gerar excecao
           pr_dscritic := 'Informação divergente no campo ATM / Multa e Juros!';
           vr_dsmsglog := pr_dscritic; -- Mantém mesma mensagem no log
           RAISE vr_exc_saida;
        END IF;

        -- Verificar se as informações do valor total e do INSS estã corretas
        IF pr_vlrtotal <> pr_vldoinss THEN
           -- Gerar excecao
           pr_dscritic := 'Informação divergente no Valor Total!';
           vr_dsmsglog := pr_dscritic; -- Mantém mesma mensagem no log
           RAISE vr_exc_saida;
        END IF;

     -- Se o indicador for 2 - SEM CÓDIGO DE BARRAS
     ELSIF pr_tpdpagto = 2 THEN
        -- Verificar se o código de pagamento foi informado
        IF NVL(pr_cdpagmto,0) <= 0 THEN
           -- Gerar excecao
           pr_dscritic := 'Código de Pagamento não informado!';
           vr_dsmsglog := pr_dscritic; -- Mantém mesma mensagem no log
           RAISE vr_exc_saida;
        END IF;

        -- Verificar se o identificador foi informado
        IF NVL(to_number(pr_dsidenti),0) <= 0 THEN
           -- Gerar excecao
           pr_dscritic := 'Identificador não informado!';
           vr_dsmsglog := pr_dscritic; -- Mantém mesma mensagem no log
           RAISE vr_exc_saida;
        END IF;

        -- Verificar se o Valor Total condiz com o somatório total dos valores da tela
        IF (NVL(pr_vldoinss,0) + NVL(pr_vloutent,0) + NVL(pr_vlatmjur,0)) <> NVL(pr_vlrtotal,0) THEN
           -- Gerar excecao
           pr_dscritic := 'Informação divergente no Valor Total!';
           vr_dsmsglog := pr_dscritic; -- Mantém mesma mensagem no log
           RAISE vr_exc_saida;
        END IF;

        IF vr_dtdebito > vr_dtvencim THEN
           -- Gerar excecao
           pr_dscritic := 'Data do débito não pode ser superior ao Vencimento!';
           RAISE vr_exc_saida;
        END IF;

     END IF;

     -- Valor padrão de configuração
     vr_cdoperad := pr_cdoperad; -- Parametro


     -- Ajustando a data de competencia para MMAAAA
     vr_dtcompet := SUBSTR(pr_dtcompet,5,2)||SUBSTR(pr_dtcompet,1,4);

     -- Chama a rotina para validação do Sicredi
     INSS0002.pc_gps_validar_sicredi(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => pr_cdagenci
                                    ,pr_nrdcaixa => pr_nrdcaixa
                                    ,pr_idorigem => pr_idorigem
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                                    ,pr_nmdatela => pr_nmdatela
                                    ,pr_cdoperad => pr_cdoperad
                                    ,pr_inproces => 2    -- pr_inproces FIXO para nao validar horario
                                    ,pr_idleitur => pr_idleitur
                                    ,pr_cddpagto => pr_cdpagmto
                                    ,pr_cdidenti => pr_dsidenti
                                    ,pr_dtvencto => vr_dtdebito --vr_dtvencim
                                    ,pr_cdbarras => pr_cdbarras
                                    ,pr_dslindig => pr_cdlindig
                                    ,pr_mmaacomp => vr_dtcompet
                                    ,pr_vlrdinss => pr_vldoinss
                                    ,pr_vlrouent => pr_vloutent
                                    ,pr_vlrjuros => pr_vlatmjur
                                    ,pr_vlrtotal => pr_vlrtotal
                                    ,pr_idseqttl => pr_idseqttl
                                    ,pr_tpdpagto => pr_tpdpagto
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_inpesgps => pr_inpesgps
                                    ,pr_indpagto => 'A' -- Agendar
                                    ,pr_nrseqagp => 0
                                    ,pr_nrcpfope => pr_nrcpfope
                                    ,pr_dslitera => vr_dslitera
                                    ,pr_sequenci => vr_sequenci
                                    ,pr_nrseqaut => vr_nrseqaut
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_des_reto => vr_des_reto);
    -- VErificar erros
    IF vr_des_reto = 'NOK' OR NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      IF vr_dscritic LIKE '%Transacoes pendentes%' THEN
        pr_dscritic := vr_dscritic;
        RAISE vr_exit;
      ELSE      
       -- Se descrição for nula e há código de erro
       IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          vr_dsmsglog := pr_dscritic; -- Mantém mesma mensagem no log
          -- Exception
          RAISE vr_exc_saida;
       END IF;

       IF pr_idorigem = 2 THEN
         pr_dscritic := REPLACE(REPLACE(vr_dscritic,'(NEGOCIO)','(SICREDI)'),'(VALIDACAO)','(SICREDI)');
       END IF;

       IF vr_dscritic LIKE '%ERR-SVC%' THEN
          pr_dscritic := TRIM(REPLACE(vr_dscritic,'ERR-SVC','(Erro no serviço)'));
       ELSE
          pr_dscritic := vr_dscritic;
       END IF;

       vr_dsmsglog := pr_dscritic; -- Mantém mesma mensagem no log
       -- Exception
       RAISE vr_exc_saida;
      END IF;
    END IF;

    /************************* CALCULO DE DATA (DIA UTEIS) *************************/
    -- Se o mês estiver indicando pagamento do décimo terceiro
    IF SUBSTR(pr_dtcompet,5) = 13 THEN
       -- Montar a data e realizar a conversão para DATE, considerando como data o dia 20/12 do ano
       vr_dtcalcul := to_date(vr_dialim13||SUBSTR(pr_dtcompet,1,4) ,'ddmmyyyy');
    ELSE
       -- Montar a data e realizar a conversão para DATE, considerando como data o dia 20/12 do ano
       vr_dtcalcul := to_date(pr_dtdebito,'dd/mm/yyyy');
    END IF;

    -- Igualar as variáveis com a mesma data
    vr_dtdebito := vr_dtcalcul;

    /******* BUSCAR DATA EM DIA UTIL *********/
    LOOP
       -- Busca uma data anterior válida - Retornar igual caso a data já seja valida
       vr_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                 ,pr_dtmvtolt => vr_dtdebito
                                                 ,pr_tipo     => 'A'); -- Retornar data anterior

       -- Validar se a data é dia util -> Se SIM... sai do loop
       EXIT WHEN vr_dtcalcul = vr_dtdebito;
       -- Atualiza a data de débito com a nova data
       vr_dtdebito := vr_dtcalcul;
    END LOOP;
    /******* FIM - BUSCAR DATA EM DIA UTIL *********/

    -- busca ultimo horario da debsic
    OPEN cr_craphec(pr_cdcooper => pr_cdcooper
                   ,pr_cdprogra => 'DEBSIC');
    FETCH cr_craphec INTO rw_craphec;

    IF cr_craphec%NOTFOUND THEN
      CLOSE cr_craphec;
      vr_hriniexe:= 0;
    ELSE
      CLOSE cr_craphec;
      vr_hriniexe:= rw_craphec.hriniexe;
    END IF;

    -- Se DEBSIC ja rodou, nao aceitamos mais agendamento para agendamentos em que o dia
    -- que antecede o final de semana ou feriado nacional
    IF to_char(SYSDATE,'sssss') >= vr_hriniexe  AND 
       rw_crapdat.dtmvtolt = vr_dtdebito THEN
      pr_dscritic := 'Agendamento de GPS permitido apenas para o proximo dia util.';
      RAISE vr_exc_saida;     
    END IF;

    vr_sequen_pro := fn_sequence('TBINSS_AGENDAMENTO_GPS','NRSEQAGP',pr_cdcooper||';'||pr_nrdconta);

    BEGIN
       -- Inserir dados do agendamento
       INSERT INTO tbinss_agendamento_gps(cdcooper
                                         ,nrdconta
                                         ,nrseqagp
                                         ,nrmes_inicial
                                         ,nrmes_final
                                         ,insituacao
                                         ,dtdebito
                                         ,vltotal_gps
                                         ,dtagendamento
                                         ,cdoperador_agend)
                                 VALUES  (pr_cdcooper                  -- cdcooper
                                         ,pr_nrdconta                  -- nrdconta
                                         ,vr_sequen_pro                -- nrseqagp
                                         ,SUBSTR(pr_dtcompet,5)        -- nrmes_inicial
                                         ,SUBSTR(pr_dtcompet,5)        -- nrmes_final
                                         ,0   /* FIXO - Agendadas */   -- insituacao
                                         ,vr_dtdebito                  -- data escolhida para débito
                                         ,pr_vlrtotal                  -- vltotal_gps
                                         ,rw_crapdat.dtmvtocd          -- dtagendamento
                                         ,pr_cdoperad )                -- cdoperador_agend
                                RETURNING nrseqagp INTO vr_nrseqagp;

    EXCEPTION
       WHEN OTHERS THEN
          -- Erro no insert
          pr_dscritic := 'Erro na inclusão do agendamento! (Erro e01: '|| to_char(SQLCODE) || ')';
          vr_dsmsglog := 'Erro ao criar tbinss_agendamento_gps! ' ||SQLERRM;
          RAISE vr_exc_saida;
    END;



    /*******************************************************************/

    -- Buscar os dados do lote
    OPEN  cr_craplot(pr_cdcooper         -- pr_cdcooper
                    ,rw_crapdat.dtmvtocd -- pr_dtmvtolt
                    ,pr_cdagenci         -- pr_cdagenci
                    ,vr_nrdolote);       -- pr_nrdolote
    FETCH cr_craplot INTO rw_craplot;

    -- Se não encontrar registro, deve criar o registro de lote
    IF cr_craplot%NOTFOUND THEN
       -- Inserir a capa do LOTE
       BEGIN
          INSERT INTO craplot(cdcooper
                             ,nrdcaixa
                             ,cdopecxa
                             ,dtmvtolt
                             ,cdhistor
                             ,cdagenci
                             ,cdbccxlt
                             ,nrdolote
                             ,tplotmov
                             ,cdoperad)
                      VALUES (pr_cdcooper   -- cdcooper
                             ,pr_nrdcaixa   -- nrdcaixa
                             ,pr_cdoperad   -- cdopecxa
                             ,rw_crapdat.dtmvtocd -- dtmvtolt
                             ,1414          -- cdhistor
                             ,pr_cdagenci   -- cdagenci
                             ,100           -- cdbccxlt - Fixo
                             ,vr_nrdolote   -- nrdolote
                             ,30            -- tplotmov
                             ,vr_cdoperad)  -- cdoperad
              RETURNING ROWID, nrseqdig
                         INTO rw_craplot.dsdrowid
                             ,rw_craplot.nrseqdig;
       EXCEPTION
          WHEN OTHERS THEN
             pr_dscritic := 'Erro na inclusão do agendamento! (Erro e02: '|| to_char(SQLCODE) || ')';
             vr_dsmsglog := 'Erro ao criar LOTE! ' ||SQLERRM;
             RAISE vr_exc_saida;
       END;
    END IF;

    -- Fechar o cursor do lote
    CLOSE cr_craplot;

    -- Verificar se o registro existe na CRAPLGP
    OPEN  cr_craplgp(pr_cdcooper            -- pr_cdcooper
                    ,rw_crapdat.dtmvtocd    -- pr_dtmvtolt
                    ,pr_cdagenci            -- pr_cdagenci
                    ,vr_nrdolote            -- pr_nrdolote
                    ,pr_dsidenti            -- pr_cdidenti
                    ,pr_cdpagmto            -- pr_cddpagto
                    ,vr_dtcompet            -- pr_dtcompet
                    ,pr_vlrtotal);          -- pr_vlrtotal

    FETCH cr_craplgp INTO rw_craplgp;

    -- Se encontrar registro
    IF cr_craplgp%FOUND THEN
      -- Fechar o cursor
      CLOSE cr_craplgp;

      -- retornar a exception
      pr_dscritic := 'Guia já agendada ou já paga!';
      vr_dsmsglog := pr_dscritic;
      RAISE vr_exc_saida;
    END IF;

    -- Fechar o cursor
    CLOSE cr_craplgp;

    -- Atualizar o Digito sequencial do lote
    rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;

    -- Criar registro de agendamento na tabela CRAPLGP
    BEGIN
      INSERT INTO craplgp(cdcooper
                         ,dtmvtolt
                         ,cdagenci
                         ,cdbccxlt
                         ,nrdolote
                         ,cdopecxa
                         ,nrdcaixa
                         ,nrdmaqui
                         ,cdidenti
                         ,cdidenti2
                         ,cddpagto
                         ,mmaacomp
                         ,vlrdinss
                         ,vlrouent
                         ,vlrjuros
                         ,vlrtotal
                         ,nrseqdig
                         ,hrtransa
                         ,flgenvio
                         ,cdbarras
                         ,nrctapag
                         ,inpesgps
                         ,tpdpagto
                         ,dslindig
                         ,dtvencto
                         ,flgpagto
                         ,tpleitur
                         ,dstiparr
                         ,nrseqagp
                         ,flgativo
                         )
                  VALUES (pr_cdcooper             -- cdcooper
                         ,rw_crapdat.dtmvtocd     -- dtmvtolt
                         ,pr_cdagenci             -- cdagenci
                         ,100                     -- cdbccxlt - fixo
                         ,vr_nrdolote             -- nrdolote
                         ,pr_cdoperad             -- cdopecxa
                         ,pr_nrdcaixa             -- nrdcaixa
                         ,pr_nrdcaixa             -- nrdmaqui
                         ,to_number(pr_dsidenti)  -- cdidenti
                         ,pr_dsidenti             -- cdidenti2
                         ,pr_cdpagmto             -- cddpagto
                         ,to_number(vr_dtcompet)  -- mmaacomp
                         ,pr_vldoinss             -- vlrdinss
                         ,pr_vloutent             -- vlrouent
                         ,pr_vlatmjur             -- vlrjuros
                         ,pr_vlrtotal             -- vlrtotal
                         ,rw_craplot.nrseqdig     -- nrseqdig
                         ,GENE0002.fn_busca_time  -- hrtransa
                         ,1        /* SIM */      -- flgenvio
                         ,vr_cdbarras             -- cdbarras
                         ,pr_nrdconta             -- nrctapag
                         ,pr_inpesgps             -- inpesgps
                         ,pr_tpdpagto             -- tpdpagto
                         ,vr_cdlindig             -- dslindig
                         ,vr_dtvencim             -- dtvencto
                         ,0       /* NÃO */       -- flgpagto
                         ,pr_idleitur             -- idleitur
                         ,vr_dstiparr             -- dstiparr
                         ,vr_nrseqagp             -- nrseqagp
                         ,1                       -- flgativo
                         );

    EXCEPTION
      WHEN OTHERS THEN
        -- retornar a exception
        pr_dscritic := 'Erro na inclusão do agendamento! (Erro e03: '|| to_char(SQLCODE) || ')';
        vr_dsmsglog := 'Erro ao criar CRAPLGP! ' ||SQLERRM;
        RAISE vr_exc_saida;
    END;

    -- Atualizar registro da LOTE
    BEGIN

      UPDATE craplot lot
         SET lot.nrseqdig = rw_craplot.nrseqdig
           , lot.qtcompln = NVL(lot.qtcompln,0) + 1
           , lot.qtinfoln = NVL(lot.qtinfoln,0) + 1
           , lot.vlcompdb = NVL(lot.vlcompdb,0) + pr_vlrtotal
           , lot.vlinfodb = NVL(lot.vlinfodb,0) + pr_vlrtotal
       WHERE ROWID = rw_craplot.dsdrowid;

    EXCEPTION
      WHEN OTHERS THEN
        -- retornar a exception
        pr_dscritic := 'Erro na inclusão do agendamento! (Erro e04: '|| to_char(SQLCODE) || ')';
        vr_dsmsglog := 'Erro ao atualizar CRAPLOT! ' ||SQLERRM;
        RAISE vr_exc_saida;
    END;

    -- Criar registro na CRAPLAU
    BEGIN

      -- Grava a informação formatada
      IF TRIM(pr_cdbarras) IS NOT NULL THEN
         vr_cdlindig := vr_cdlidgfm;
      END IF;
      INSERT INTO craplau(cdcooper
                         ,dtmvtolt
                         ,cdagenci
                         ,cdbccxlt
                         ,nrdolote
                         ,nrseqdig
                         ,nrdocmto
                         ,nrdconta
                         ,idseqttl
                         ,dttransa
                         ,hrtransa
                         ,cdhistor
                         ,dsorigem
                         ,insitlau
                         ,cdtiptra
                         ,dscedent
                         ,dscodbar
                         ,dslindig
                         ,dtmvtopg
                         ,vllanaut
                         ,nrseqagp
                         ,tpdvalor
						 ,NRCPFOPE)	 -- 397
                       VALUES
    --unico: CDCOOPER, DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRDCTABB, NRDOCMTO
    --unico: CDCOOPER, DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRSEQDIG
                         (pr_cdcooper                              -- cdcooper
                         ,rw_crapdat.dtmvtocd                      -- dtmvtolt
                         ,pr_cdagenci                              -- cdagenci
                         ,100                                      -- cdbccxlt - fixo
                         ,vr_nrdolote                              -- nrdolote
                         ,rw_craplot.nrseqdig                      -- nrseqdig
                         ,rw_craplot.nrseqdig                      -- nrdocmto

                         ,pr_nrdconta                              -- nrdconta
                         ,1                -- FIXO                 -- idseqttl
                         ,TRUNC(SYSDATE)                           -- dttransa
                         ,GENE0002.fn_busca_time                   -- hrtransa
                         ,540 --DEB. GPS INSS                      -- cdhistor
                         ,vr_dsorigem                              -- dsorigem
                         ,1            -- Pendente insitlau        -- insitlau
                         ,2            -- pgto titulo (2)          -- cdtiptra
                         ,UPPER('GPS Identificador '||pr_dsidenti) -- dscedent
                         ,vr_cdbarras                              -- dscodbar
                         ,vr_cdlindig                              -- dslindig
                         ,vr_dtdebito                              -- dtmvtopg
                         ,pr_vlrtotal                              -- vllanaut
                         ,vr_nrseqagp                              -- nrseqagp
                         ,1                                        -- tpdvalor
						 ,pr_nrcpfope);   --397

      -- Limpa a variavel
      /* CARLOS - 05/09/2016 - SD 490844
      IF TRIM(pr_cdbarras) IS NOT NULL THEN
         vr_cdlindig := NULL;
      END IF; */

    EXCEPTION
      WHEN OTHERS THEN
        -- retornar a exception
        pr_dscritic := 'Erro na inclusão do agendamento! (Erro e05: '|| to_char(SQLCODE) || ')';
        vr_dsmsglog := 'Erro ao criar CRAPLAU! ' ||SQLERRM;
        RAISE vr_exc_saida;
    END;

    --Se for pessoa fisica
    IF rw_crapass.inpessoa = 1 THEN

      /* Nome do titular que fez a transferencia */
      OPEN cr_crapttl (pr_cdcooper => rw_crapass.cdcooper
                      ,pr_nrdconta => rw_crapass.nrdconta
                      ,pr_idseqttl => pr_idseqttl);

      --Posicionar no proximo registro
      FETCH cr_crapttl INTO rw_crapttl;

      --Se nao encontrar
      IF cr_crapttl%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapttl;

        vr_cdcritic := 0;
        vr_dscritic := 'Titular nao encontrado!';
        vr_dsmsglog := vr_dscritic;

        -- Gera exceção
        RAISE vr_exc_saida;
      END IF;

      -- Fechar Cursor
      CLOSE cr_crapttl;

      -- Nome titular
      vr_nmextttl:= rw_crapttl.nmextttl;

	  /* Nome do titular que fez a transferencia */
      OPEN cr_crapttl (pr_cdcooper => rw_crapass.cdcooper
                      ,pr_nrdconta => rw_crapass.nrdconta
                      ,pr_idseqttl => 2);

      --Posicionar no proximo registro
      FETCH cr_crapttl INTO rw_crapttl;

      -- Fechar Cursor
      CLOSE cr_crapttl;

      -- Nome titular
      vr_nmsegntl:= rw_crapttl.nmextttl;

    ELSE
      vr_nmextttl:= rw_crapass.nmprimtl;
    END IF;


    IF pr_inpesgps = 1 THEN
      vr_dspesgps := 'PESSOA FISICA';
    ELSE
      vr_dspesgps := 'PESSOA JURIDICA';
    END IF;

    vr_dsinfor1:= 'Agendamento de GPS';
    vr_dsinfor2:= vr_nmextttl ||'#' ||
                  'Conta/dv: ' ||rw_crapass.nrdconta ||' - '||
                  rw_crapass.nmprimtl;

    -- Formatando a linha digitavel
    IF pr_cdlindig IS NOT NULL AND pr_tpdpagto = 1 THEN
       vr_cdlidgfm := SUBSTR(vr_cdlindig,1,11)  ||'-'|| SUBSTR(vr_cdlindig,12,1) ||' '||
                      SUBSTR(vr_cdlindig,13,11) ||'-'|| SUBSTR(vr_cdlindig,24,1) ||' '||
                      SUBSTR(vr_cdlindig,25,11) ||'-'|| SUBSTR(vr_cdlindig,36,1) ||' '||
                      SUBSTR(vr_cdlindig,37,11) ||'-'|| SUBSTR(vr_cdlindig,48,1);
    END IF;
    -- 397
    vr_nrcpfcgc := null;          
    FOR rw_crapsnh2 IN cr_crapsnh2 (pr_cdcooper,
                                    pr_nrdconta,
                                    pr_idseqttl) LOOP
      vr_nrcpfcgc :=  rw_crapsnh2.nrcpfcgc;
    END LOOP;
    -- Gerar Protocolo MD5
    GENE0006.pc_gera_protocolo_md5(pr_cdcooper => pr_cdcooper
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                                  ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrdocmto => rw_craplot.nrseqdig
                                  ,pr_nrseqaut => vr_sequen_pro
                                  ,pr_vllanmto => pr_vlrtotal
                                  ,pr_nrdcaixa => pr_nrdcaixa
                                  ,pr_gravapro => TRUE
                                  ,pr_cdtippro => 13 -- Identificacao de Guia da Previdencia Social
                                  ,pr_dsinfor1 => vr_dsinfor1
                                  ,pr_dsinfor2 => vr_dsinfor2
                                  ,pr_dsinfor3 => 'Linha Digitável: '||vr_cdlidgfm
                                               || '#Código de Barras: '||vr_cdbarras
                                               || '#03 - Código de Pagamento: '||pr_cdpagmto
                                               || '#04 - Competência: '||SUBSTR(pr_dtcompet,5,2)||'/'||SUBSTR(pr_dtcompet,1,4)
                                               || '#05 - Identificador: '||pr_dsidenti
                                               || '#06 - Valor do INSS(R$): '||TO_CHAR(pr_vldoinss,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')
                                               || '#09 - Valor Out. Entidades(R$): '||TO_CHAR(pr_vloutent,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')
                                               || '#10 - ATM/Multa e Juros(R$): '||TO_CHAR(pr_vlatmjur,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')
                                               || '#11 - Valor Total(R$): '||TO_CHAR(pr_vlrtotal,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')
                                  ,pr_dscedent => 'GPS Beneficiário ' || pr_dsidenti
                                  ,pr_flgagend => TRUE
                                  ,pr_nrcpfope => nvl(pr_nrcpfope,0)
                                  ,pr_nrcpfpre => nvl(vr_nrcpfcgc,0)
                                  ,pr_nmprepos => ''
                                  ,pr_dsprotoc => vr_dsprotoc
                                  ,pr_dscritic => pr_dscritic
                                  ,pr_des_erro => vr_dsretorn);

    -- Se retornou erro, gera critica
    IF pr_dscritic IS NOT NULL THEN
       vr_dsmsglog := pr_dscritic;
       RAISE vr_exc_saida;
    END IF;


    IF pr_idorigem = 2 THEN -- Apenas CAIXA ON-LINE

       /*---- Gera literal autenticacao - RECEBIMENTO(Rolo) ----*/

       -- Populando vetor
       vr_tab_literal.DELETE;
       vr_tab_literal(1):= TRIM(rw_crapcop.nmrescop) ||' - '||TRIM(rw_crapcop.nmextcop);
       vr_tab_literal(2):= ' ';
       vr_tab_literal(3):= TO_CHAR(rw_crapdat.dtmvtocd,'DD/MM/RR')  ||' '||
                           TO_CHAR(SYSDATE,'HH24:MI:SS') ||' PA  '||
                           TRIM(TO_CHAR(gene0002.fn_mask(pr_cdagenci,'999')))  ||'  CAIXA: '||
                           TO_CHAR(gene0002.fn_mask(pr_nrdcaixa,'Z99')) || '/' ||
                           SUBSTR(pr_cdoperad,1,10);
       vr_tab_literal(4):= ' ';
       vr_tab_literal(5):= ' * * * * COMPROVANTE DE AGENDAMENTO GPS * * * * ';

       IF pr_tpdpagto = 2 THEN
          vr_tab_literal(6):= '              SEM CODIGO DE BARRAS';
       ELSE
          vr_tab_literal(6):= '              COM CODIGO DE BARRAS';
       END IF;

       vr_tab_literal(7):= ' ';
       vr_tab_literal(8):= 'AGENCIA: '||TRIM(TO_CHAR(rw_crapcop.cdagectl,'9999')) ||
                           ' - ' ||TRIM(rw_crapcop.nmrescop);
       vr_tab_literal(9):= 'CONTA..: '||TRIM(TO_CHAR(pr_nrdconta,'9999G999G9')) ||
                           '   PA: ' || TRIM(TO_CHAR(rw_crapass.cdagenci));
       vr_tab_literal(10):=  '       ' || TRIM(rw_crapass.nmprimtl); -- NOME TITULAR 1
       vr_tab_literal(11):= '       ' || TRIM(vr_nmsegntl); -- NOME TITULAR 2
       vr_tab_literal(12):= ' ';

       IF pr_tpdpagto = 2 THEN
          vr_tab_literal(13):= ' ';
          vr_tab_literal(14):= ' ';
       ELSE
          vr_tab_literal(13):= vr_linbarr1;
          vr_tab_literal(14):= vr_linbarr2;
       END IF;

       vr_tab_literal(15):= '  CODIGO PAGAMENTO..: '||TRIM(TO_CHAR(gene0002.fn_mask(pr_cdpagmto,'9999')));
       vr_tab_literal(16):= '  COMPETENCIA.......: '||SUBSTR(pr_dtcompet,5,2)||'/'||SUBSTR(pr_dtcompet,1,4);
       vr_tab_literal(17):= '  IDENTIFICADOR.....: '||TRIM(pr_dsidenti);
       vr_tab_literal(18):= ' ';
       vr_tab_literal(19):= '  VALOR TOTAL.......: '||TO_CHAR(pr_vlrtotal,'999G999G999D99');
       vr_tab_literal(20):= '  PAGAMENTO PARA....: '||vr_dspesgps;
       vr_tab_literal(21):= '  DATA P/ PAGAMENTO.: '||pr_dtdebito;
       vr_tab_literal(22):= ' ';
       vr_tab_literal(23):= '  PROTOCOLO:';
       vr_tab_literal(24):= '  '||vr_dsprotoc;
       vr_tab_literal(25):= ' ';
       vr_tab_literal(26):= ' ';
       vr_tab_literal(27):= 'OBSERVACOES: CASO O DATA DO DEBITO ESCOLHIDO NAO';
       vr_tab_literal(28):= 'SEJA UM DIA UTIL, O DEBITO OCORRERA  NO DIA UTIL';
       vr_tab_literal(29):= 'ANTERIOR A DATA ESCOLHIDA.';
       vr_tab_literal(30):= ' ';
       vr_tab_literal(31):= 'A QUITACAO EFETIVA  DESSE AGENDAMENTO  DEPENDERA';
       vr_tab_literal(32):= 'DA EXISTENCIA DE  SALDO NA SUA CONTA CORRENTE NA';
       vr_tab_literal(33):= 'DATA ESCOLHIDA PARA DEBITO.';
       vr_tab_literal(34):= ' ';
       vr_tab_literal(35):= ' ';
       vr_tab_literal(36):= ' ';
       vr_tab_literal(37):= fn_centraliza('SAC - '||rw_crapcop.nrtelsac,48);
       vr_tab_literal(38):= fn_centraliza('Atendimento todos os dias das '
         ||to_char(to_date(rw_crapcop.hrinisac,'SSSSS'),'HH24"H"')||nullif(to_char(to_date(rw_crapcop.hrinisac,'SSSSS'),'MI'),'00')||' as '
         ||to_char(to_date(rw_crapcop.hrfimsac,'SSSSS'),'HH24"H"')||nullif(to_char(to_date(rw_crapcop.hrfimsac,'SSSSS'),'MI'),'00') ,48);
       vr_tab_literal(39):= fn_centraliza('OUVIDORIA - '||rw_crapcop.nrtelouv,48);
       vr_tab_literal(40):= fn_centraliza('Atendimento nos dias uteis das '         
         ||to_char(to_date(rw_crapcop.hriniouv,'SSSSS'),'HH24"H"')||nullif(to_char(to_date(rw_crapcop.hriniouv,'SSSSS'),'MI'),'00')||' as '
         ||to_char(to_date(rw_crapcop.hrfimouv,'SSSSS'),'HH24"H"')||nullif(to_char(to_date(rw_crapcop.hrfimouv,'SSSSS'),'MI'),'00') ,48);
       vr_tab_literal(41):= ' ';
       vr_tab_literal(42):= ' ';
       vr_tab_literal(43):= ' ';
       vr_tab_literal(44):= ' * * * *        FIM DA IMPRESSAO        * * * *';
       vr_tab_literal(45):= ' ';
       vr_tab_literal(46):= ' ';
       vr_tab_literal(47):= ' ';
       vr_tab_literal(48):= ' ';
       vr_tab_literal(49):= ' ';       
       vr_tab_literal(50):= ' ';
       vr_tab_literal(51):= ' ';
       vr_tab_literal(52):= ' ';
       vr_tab_literal(53):= ' ';
       vr_tab_literal(54):= ' ';


       -- Inicializa Variavel
       pr_dslitera := NULL;
       pr_dslitera:= RPAD(NVL(vr_tab_literal(1),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(2),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(3),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(4),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(5),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(6),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(7),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(8),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(9),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(10),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(11),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(12),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(13),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(14),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(15),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(16),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(17),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(18),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(19),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(20),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(21),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(22),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(23),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(24),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(25),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(26),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(27),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(28),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(29),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(30),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(31),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(32),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(33),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(34),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(35),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(36),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(37),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(38),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(39),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(40),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(41),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(42),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(43),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(44),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(45),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(46),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(47),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(48),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(49),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(50),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(51),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(52),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(53),'  '),48,' ');
       pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(54),'  '),48,' ');


       vr_busca :=  TRIM(pr_cdcooper)    || ';' ||
                    TRIM(pr_cdagenci)    || ';' ||
                    TRIM(pr_nrdcaixa)    || ';' ||
                    TO_char(rw_crapdat.dtmvtocd,'dd/mm/yyyy');

       pr_cdultseq := fn_sequence('CRAPAUT','NRSEQUEN',vr_busca);

       -- Inserir autenticacao
       BEGIN
          INSERT INTO crapaut(crapaut.cdcooper
                             ,crapaut.cdagenci
                             ,crapaut.nrdcaixa
                             ,crapaut.dtmvtolt
                             ,crapaut.nrsequen
                             ,crapaut.cdopecxa
                             ,crapaut.hrautent
                             ,crapaut.vldocmto
                             ,crapaut.nrdocmto
                             ,crapaut.tpoperac
                             ,crapaut.cdstatus
                             ,crapaut.estorno
                             ,crapaut.cdhistor
                             ,crapaut.dslitera)
                      VALUES (pr_cdcooper
                             ,pr_cdagenci
                             ,pr_nrdcaixa
                             ,rw_crapdat.dtmvtocd
                             ,pr_cdultseq
                             ,pr_cdoperad
                             ,GENE0002.fn_busca_time
                             ,pr_vlrtotal
                             ,0
                             ,0 /* Nao estorno */
                             ,'1' -- On-line
                             ,0
                             ,1414
                             ,pr_dslitera);
       EXCEPTION
          WHEN OTHERS THEN
             -- Libera Tabela de Memoria
             vr_tab_literal.DELETE;
             pr_dslitera :=  NULL;
             -- Levantar Excecao
             pr_dscritic:= 'Erro ao atualizar no BL do caixa online. '||sqlerrm;
             RAISE vr_exc_saida;
        END;

        -- Libera Tabela de Memoria
        vr_tab_literal.DELETE;
        pr_dslitera := vr_busca;
    END IF;

    -- Se houve sucesso, seta critica do log:
    vr_dscritic := 'Pagamento agendado para o dia ' || to_char(vr_dtdebito,'DD/MM/YYYY');
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => NVL(vr_dscritic,' ')
                        ,pr_dsorigem => vr_dsorigem
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> 1-TRUE/SUCESSO
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => pr_idseqttl
                        ,pr_nmdatela => pr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);

    -- Log Item => Código Pagamento
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Cod.Pagto'
                            , pr_dsdadant => TRIM(TO_CHAR(gene0002.fn_mask(pr_cdpagmto,'9999')))
                            , pr_dsdadatu => '');
    -- Log Item => Competencia
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Competencia'
                            , pr_dsdadant => SUBSTR(pr_dtcompet,5,2)||'/'||SUBSTR(pr_dtcompet,1,4)
                            , pr_dsdadatu => '');
    -- Log Item => Identificador
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Identificador'
                            , pr_dsdadant => pr_dsidenti
                            , pr_dsdadatu => '');
    -- Log Item => Valor Total
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Valor Total'
                            , pr_dsdadant => TRIM(TO_CHAR(pr_vlrtotal,'999G999G999D99'))
                            , pr_dsdadatu => '');
    -- Log Item => Data Debito
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Data Debito'
                            , pr_dsdadant => TO_CHAR(vr_dtdebito,'DD/MM/YYYY')
                            , pr_dsdadatu => '');



    COMMIT;

  EXCEPTION
    WHEN vr_exit THEN
      -- SAIR COM A TRANSACAO PENDENTE
      COMMIT;    
    WHEN vr_exc_saida THEN
      pr_dscritic := 'Agendamento não efetuado! =>' || pr_dscritic;
      pr_dslitera := '';
      pr_cdultseq := 0;

      -- Desfazer alterações
      ROLLBACK;
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => vr_dsmsglog -- Mensagem par ao LOG
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 -- ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      COMMIT; -- Commitar o LOG
    WHEN OTHERS THEN
      pr_dscritic := 'Agendamento não efetuado! (Erro: '|| to_char(SQLCODE) || ')';
      pr_dslitera := '';
      pr_cdultseq := 0;
      -- Desfazer alterações
      ROLLBACK;
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => 'Erro PC_GPS_AGMTO_NOVO: '||SQLERRM
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 -- ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      COMMIT; -- Commitar o LOG
  END pc_gps_agmto_novo;


  /*---------------------------------------------------------------------------------------------------------------
   Autor    : Andre Santos/SUPERO
   Objetivo : GPS - Efetuar pagamento de GPS
  ---------------------------------------------------------------------------------------------------------------*/
  PROCEDURE pc_gps_pagamento(pr_cdcooper   IN NUMBER
                            ,pr_nrdconta   IN NUMBER
                            ,pr_cdagenci   IN NUMBER
                            ,pr_nrdcaixa   IN NUMBER
                            ,pr_idseqttl   IN NUMBER                        
                            ,pr_tpdpagto   IN NUMBER
                            ,pr_idorigem   IN NUMBER
                            ,pr_cdoperad   IN VARCHAR2
                            ,pr_nmdatela   IN VARCHAR2
                            ,pr_idleitur   IN NUMBER   -- Indica se os campos vieram via Leitura Laser(1) ou Manual(0)
                            ,pr_inproces   IN NUMBER
                            ,pr_cdbarras   IN VARCHAR2
                            ,pr_sftcdbar   IN VARCHAR2
                            ,pr_cdpagmto   IN NUMBER
                            ,pr_dtcompet   IN VARCHAR2 -- Recebe como string e trata no programa
                            ,pr_dsidenti   IN VARCHAR2 -- Recebe como char para prese
                            ,pr_vldoinss   IN NUMBER
                            ,pr_vloutent   IN NUMBER
                            ,pr_vlatmjur   IN NUMBER
                            ,pr_vlrtotal   IN NUMBER
                            ,pr_dtvencim   IN VARCHAR2 -- Recebe como string e trata no programa
                            ,pr_inpesgps   IN NUMBER
                            ,pr_nrseqagp   IN NUMBER   -- Nr Seq Agendamento => Quando vem pelo CRPS
                            ,pr_nrcpfope   IN crapopi.nrcpfope%TYPE DEFAULT 0 -- 397
                            ,pr_dslitera  OUT VARCHAR2
                            ,pr_cdultseq  OUT NUMBER
                            ,pr_dscritic  OUT VARCHAR2) IS

     -- Busca dados da cooperativa
     CURSOR cr_crapcop(p_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT cop.cdcooper
          FROM crapcop cop
         WHERE cop.cdcooper = p_cdcooper;

     -- Buscar os dados do associado
     CURSOR cr_crapass(p_cdcooper crapcop.cdcooper%TYPE
                      ,p_nrdconta crapass.nrdconta%TYPE) IS
        SELECT ass.cdcooper
              ,ass.nrdconta
              ,ass.inpessoa
              ,ass.nmprimtl
          FROM crapass ass
         WHERE ass.cdcooper = p_cdcooper
           AND ass.nrdconta = p_nrdconta
           AND ass.dtdemiss IS NULL; -- Conta Ativa

     -- Selecionar informacoes do titular
     CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%type
                       ,pr_nrdconta IN crapttl.nrdconta%type
                       ,pr_idseqttl IN crapttl.idseqttl%type) IS
        SELECT ttl.nmextttl
              ,ttl.nrcpfcgc
              ,ttl.idseqttl
          FROM crapttl ttl
         WHERE ttl.cdcooper = pr_cdcooper
           AND ttl.nrdconta = pr_nrdconta
           AND ttl.idseqttl = pr_idseqttl;
     rw_crapttl cr_crapttl%ROWTYPE;
     --
     CURSOR cr_crapsnh2 (prc_cdcooper crapsnh.cdcooper%type,
                         prc_nrdconta crapsnh.nrdconta%type,
                         prc_idseqttl crapsnh.idseqttl%type)IS
        SELECT c.nrcpfcgc
          FROM crapsnh c
         WHERE c.cdcooper = prc_cdcooper
           AND c.nrdconta = prc_nrdconta
           AND c.idseqttl = prc_idseqttl
           AND c.tpdsenha = 1 -- INTERNET
           ;        


    /* Verifica se existe registro na CRAPBCX */
    CURSOR cr_existe_bcx(p_cdcooper IN NUMBER
                        ,p_dtmvtolt IN DATE
                        ,p_cdagenci IN NUMBER
                        ,p_nrdcaixa IN NUMBER
                        ,p_cdopecxa IN VARCHAR2)IS
        SELECT bcx.qtcompln
              ,bcx.ROWID
          FROM crapbcx bcx
         WHERE bcx.cdcooper = p_cdcooper
           AND bcx.dtmvtolt = p_dtmvtolt
           AND bcx.cdagenci = p_cdagenci
           AND bcx.nrdcaixa = p_nrdcaixa
           AND UPPER(bcx.cdopecxa) = UPPER(p_cdopecxa)
           AND bcx.cdsitbcx = 1
           FOR UPDATE NOWAIT;
    rw_existe_bcx cr_existe_bcx%ROWTYPE;


     -- Variaveis de Cursor
     rw_crapcop cr_crapcop%ROWTYPE;
     rw_crapass cr_crapass%ROWTYPE;
     rw_crapdat btch0001.cr_crapdat%ROWTYPE;

     -- Variaveis
     vr_cdbarras      VARCHAR2(44); -- Deve ser obrigatóriamente tratado para ter 44 caracteres
     vr_cdlidgfm      VARCHAR2(100); -- Linha digitavel formatada
     vr_dtcompet      VARCHAR(6);
     vr_literal       VARCHAR2(500);
     vr_ult_sequencia NUMBER;
     vr_nrseqaut      NUMBER;
     vr_nro_docto     NUMBER;
     vr_dsprotoc      VARCHAR2(1000);
     vr_nmextttl      VARCHAR2(100);
     vr_dsinfor1      crappro.dsinform##1%TYPE;
     vr_dsinfor2      crappro.dsinform##2%TYPE;
     vr_dsdpagto      VARCHAR2(60);
     vr_dspesgps      VARCHAR2(15);
     vr_dtmvtolt      DATE;
     vr_nrcpfcgc      crapsnh.nrcpfcgc%type;

     vr_lindigi1 VARCHAR2(50);
     vr_lindigi2 VARCHAR2(50);

     vr_lindigi3 VARCHAR2(50);
     vr_lindigi4 VARCHAR2(50);
     -- Digito verificar
     vr_validig1 PLS_INTEGER;
     vr_validig2 PLS_INTEGER;
     vr_validig3 PLS_INTEGER;
     vr_validig4 PLS_INTEGER;

     vr_sequen        INTEGER;
     vr_busca         VARCHAR2(100);

     vr_dstransa      VARCHAR2(100);
     vr_dsorigem      VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_idorigem);
     vr_cdcritic      PLS_INTEGER;
     vr_dscritic      VARCHAR2(500) := '';
     vr_dsretorn      VARCHAR2(500) := '';
     vr_dtvencim      DATE;

  BEGIN
     -- Inicializa Variavel
     pr_dscritic := NULL;
     pr_dslitera := NULL;
     pr_cdultseq := NULL;
     vr_dtvencim := NULL;

     -- Buscar dados da cooperativa e validar a existencia da mesma
     OPEN  cr_crapcop(pr_cdcooper);
     FETCH cr_crapcop INTO rw_crapcop;
     -- Se não encontrar
     IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        pr_dscritic := gene0001.fn_busca_critica(651);
        RAISE vr_exc_saida;
     END IF;
     -- Apenas fechar o cursor
     CLOSE cr_crapcop;

     OPEN BTCH0001.cr_crapdat(pr_cdcooper);
     FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
     -- Se não encontrar
     IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        pr_dscritic := 'Registo de data nao encontrado';
        RAISE vr_exc_saida;
     END IF;
     -- Apenas fechar o cursor
     CLOSE BTCH0001.cr_crapdat;

     IF pr_tpdpagto = 1 THEN -- Com Codigo de Barras
        vr_dstransa := 'Pagamento de GPS - Com Cod.Barras';
        vr_dsdpagto := 'Com Código de Barras';

        IF pr_idleitur = 1 THEN
           vr_dstransa := vr_dstransa || '(Leitora)';
           vr_dsdpagto := vr_dsdpagto || '(Leitora)';
        ELSE
           vr_dstransa := vr_dstransa || '(Lin.Digitável/Manual)';
           vr_dsdpagto := vr_dsdpagto || '(Lin.Digitável/Manual)';
        END IF;

     ELSE -- Sem Codigo de Barras
        vr_dstransa := 'Pagamento de GPS - Sem Cod.Barras (Manual)';
        vr_dsdpagto := 'Sem Código de Barras (Manual)';
     END IF;

     IF NVL(pr_nrdconta,0) > 0 THEN
        -- Buscar os dados do associado para validar
        OPEN cr_crapass(pr_cdcooper
                       ,pr_nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        -- Verificar se existe dados do associado
        IF cr_crapass%NOTFOUND THEN
           -- Fechar o cursor
           CLOSE cr_crapass;
           -- Gerar excecao
           pr_dscritic := gene0001.fn_busca_critica(9);
           RAISE vr_exc_saida;
        END IF;
        -- Apenas fechar o cursor
        CLOSE cr_crapass;
     END IF;

     -- Se o tipo de pessoa for diferente de
     -- 1- Pessoa Fisica
     -- 2- Pessoa Juridica
     IF pr_inpesgps NOT IN (1,2) THEN
        -- Gera critica
        pr_dscritic := 'Tipo de pessoa inválida!';
        RAISE vr_exc_saida;
     END IF;

     -- Verifica o tipo de pagamento
     -- 1-C/ Codigo de Barras
     -- 2-S/ Codigo de Barras
     IF pr_tpdpagto = 1 THEN
        -- Para os pagamentos com codigo de barras

        -- Validar o código de barras informado - Se não possuir 44 ou 48 posições
        IF TRIM(pr_cdbarras) IS NOT NULL THEN
           IF LENGTH(pr_cdbarras) <> 44  THEN
              -- Gerar excecao
              pr_dscritic := 'Código de Barras inválido ou incompleto!';
              RAISE vr_exc_saida;
           ELSE
              vr_cdbarras := pr_cdbarras;
           END IF;
        ELSIF TRIM(pr_sftcdbar) IS NOT NULL THEN
           IF LENGTH(pr_sftcdbar) <> 48 THEN
              -- Gerar excecao
              pr_dscritic := 'Linha Digitável inválida ou incompleta!';
              RAISE vr_exc_saida;
           ELSE
              -- Se o código de barras possuir 48 posições, deverá remover os dígitos, passando assim para 44 posições - LINHA DIGITÁVEL
              vr_cdbarras := SUBSTR(pr_sftcdbar, 1,11)  ||
                             SUBSTR(pr_sftcdbar,13,11)  ||
                             SUBSTR(pr_sftcdbar,25,11)  ||
                             SUBSTR(pr_sftcdbar,37,11);
           END IF;
        ELSE
           -- Gerar excecao
           pr_dscritic := 'Código de Barras ou Linha digitável devem ser informados!';
           RAISE vr_exc_saida;
        END IF;

        -- Validar o codigo do pagamento
        IF NVL(pr_cdpagmto,0) <> SUBSTR(vr_cdbarras,20, 4) THEN
           -- Gerar excecao
           pr_dscritic := 'Informação divergente no Código de Pagamento!';
           RAISE vr_exc_saida;
        END IF;

        -- Verificar a competencia
        IF NVL(pr_dtcompet,' ') <> SUBSTR(vr_cdbarras,38, 6) THEN
           -- Gerar excecao
           pr_dscritic := 'Informação divergente no campo Competência!';
           RAISE vr_exc_saida;
        END IF;

        -- Verificar o identificador do pagamento
        IF NVL(pr_dsidenti,' ') <> SUBSTR(vr_cdbarras,24,14) THEN
           -- Gerar excecao
           pr_dscritic := 'Informação divergente no campo Identificador!';
           RAISE vr_exc_saida;
        END IF;

        -- Verificar o valor do INSS
        IF NVL(pr_vldoinss,0) <> (TO_NUMBER(SUBSTR(vr_cdbarras, 6,10))/100) THEN
           -- Gerar excecao
           pr_dscritic := 'Informação divergente no campo Valor do INSS!';
           RAISE vr_exc_saida;
        END IF;

        -- Verificar se o campo de valor outras entidades está zerado
        IF NVL(pr_vloutent,0) > 0 THEN
           -- Gerar excecao
           pr_dscritic := 'Informação divergente no campo Valor Outras Entidades!';
           RAISE vr_exc_saida;
        END IF;

        -- Verificar se o campo de Atm, Juros e multa está zerado
        IF NVL(pr_vlatmjur,0) > 0 THEN
           -- Gerar excecao
           pr_dscritic := 'Informação divergente no campo ATM / Juros e Multa!';
           RAISE vr_exc_saida;
        END IF;

        -- Verificar se as informações do valor total e do INSS estã corretas
        IF NVL(pr_vlrtotal,0) <> pr_vldoinss THEN
           -- Gerar excecao
           pr_dscritic := 'Informação divergente no Valor Total!';
           RAISE vr_exc_saida;
        END IF;

     ELSIF pr_tpdpagto = 2 THEN
        -- Para os pagamentos com codigo de barras

        -- Verificar se o código de pagamento foi informado
        IF NVL(pr_cdpagmto,0) <= 0 THEN
           -- Gerar excecao
           pr_dscritic := 'Código de Pagamento não informado!';
           RAISE vr_exc_saida;
        END IF;

        -- Validar o período de competencia for null
        IF pr_dtcompet IS NULL THEN
           -- Gerar excecao
           pr_dscritic := 'Competência não informada!';
           RAISE vr_exc_saida;
        END IF;

        -- Verificar se o identificador foi informado
        IF NVL(TO_NUMBER(pr_dsidenti),0) <= 0 THEN
           -- Gerar excecao
           pr_dscritic := 'Identificador não informado!';
           RAISE vr_exc_saida;
        END IF;

        -- Verificar se o Valor Total condiz com o somatório total dos valores da tela
        IF (NVL(pr_vldoinss,0) + NVL(pr_vloutent,0) + NVL(pr_vlatmjur,0)) <> NVL(pr_vlrtotal,0) THEN
           -- Gerar excecao
           pr_dscritic := 'Informação divergente no Valor Total!';
           RAISE vr_exc_saida;
        END IF;

        -- Validar data de vencimento informada
        IF pr_dtvencim IS NULL THEN
           -- Gerar excecao
           pr_dscritic := 'Data de Vencimento é obrigatório preenchimento!';
           RAISE vr_exc_saida;
        END IF;

        vr_dtvencim := TO_DATE(pr_dtvencim,'DD/MM/YYYY');

     ELSE
        -- Gera critica
        pr_dscritic := 'Tipo de pagamento inválido!';
        RAISE vr_exc_saida;
     END IF;

     /* Ajustando a data de competencia para MMAAAA */
     vr_dtcompet := SUBSTR(pr_dtcompet,5,2)||SUBSTR(pr_dtcompet,1,4);

     -- Sempre passa a data que já está no CX-online
     vr_dtmvtolt := rw_crapdat.dtmvtocd;

     -- Chamada da procedure de validacao do SICREDI
     INSS0002.pc_gps_validar_sicredi(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => pr_cdagenci
                                    ,pr_nrdcaixa => pr_nrdcaixa
                                    ,pr_idorigem => pr_idorigem
                                    ,pr_dtmvtolt => vr_dtmvtolt
                                    ,pr_nmdatela => pr_nmdatela
                                    ,pr_cdoperad => pr_cdoperad
                                    ,pr_inproces => pr_inproces
                                    ,pr_idleitur => pr_idleitur
                                    ,pr_cddpagto => pr_cdpagmto
                                    ,pr_cdidenti => pr_dsidenti
                                    ,pr_dtvencto => vr_dtvencim
                                    ,pr_cdbarras => vr_cdbarras
                                    ,pr_dslindig => pr_sftcdbar -- Linha digitável - 48 posições
                                    ,pr_mmaacomp => vr_dtcompet
                                    ,pr_vlrdinss => pr_vldoinss
                                    ,pr_vlrouent => pr_vloutent
                                    ,pr_vlrjuros => pr_vlatmjur
                                    ,pr_vlrtotal => pr_vlrtotal
                                    ,pr_idseqttl => pr_idseqttl --\** TITULAR **\
                                    ,pr_tpdpagto => pr_tpdpagto
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_inpesgps => pr_inpesgps
                                    ,pr_indpagto => 'P' -- Pagamento
                                    ,pr_nrseqagp => pr_nrseqagp
                                    ,pr_nrcpfope => pr_nrcpfope
                                    ,pr_dslitera => vr_literal
                                    ,pr_sequenci => vr_ult_sequencia
                                    ,pr_nrseqaut => vr_nrseqaut
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_des_reto => vr_dsretorn);
     -- Se retornou erro, gera critica
     IF vr_dsretorn <> 'OK' OR NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
       IF vr_dscritic LIKE '%Transacoes pendentes%' THEN
         pr_dscritic := vr_dscritic;
         RAISE vr_exit;
       ELSE
        -- Se descricao for nula e ha codigo de erro
        IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
           pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           -- Exception
           RAISE vr_exc_saida;
        END IF;

        IF pr_idorigem = 2 THEN
          pr_dscritic := REPLACE(REPLACE(vr_dscritic,'(NEGOCIO)','(SICREDI)'),'(VALIDACAO)','(SICREDI)');
        END IF;

        IF vr_dscritic LIKE '%ERR-SVC%' THEN
          pr_dscritic := TRIM(REPLACE(vr_dscritic,'ERR-SVC','(Erro no serviço)'));
        ELSE
          pr_dscritic := vr_dscritic;
        END IF;
        RAISE vr_exc_saida;
     END IF;
     END IF;


     IF pr_idorigem = 2 THEN -- Apenas CAIXA ON-LINE
       -- Retornar valores
       pr_dslitera := vr_literal;
       pr_cdultseq := vr_nrseqaut;
       
       --Selecionar informacoes dos boletins dos caixas
        /* Tratamento para buscar registro de lote se o mesmo estiver em lock, tenta por 10 seg. */
        FOR i IN 1 .. 100 LOOP
          BEGIN
            OPEN cr_existe_bcx(pr_cdcooper
                              ,rw_crapdat.dtmvtocd
                              ,pr_cdagenci
                              ,pr_nrdcaixa
                              ,pr_cdoperad);
            --Posicionar no proximo registro
            FETCH cr_existe_bcx INTO rw_existe_bcx;
            --Se nao encontrar
            IF cr_existe_bcx%NOTFOUND THEN
              --Fechar Cursor
              CLOSE cr_existe_bcx;
              vr_cdcritic:= 698;
              pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
              --Fechar Cursor
              CLOSE cr_existe_bcx;              
              --Levantar Excecao
              RAISE vr_exc_saida;
            ELSE  
              vr_cdcritic := NULL;
              --Fechar Cursor
              CLOSE cr_existe_bcx;
              EXIT;
            END IF;

        EXCEPTION
          WHEN OTHERS THEN
            IF cr_existe_bcx%ISOPEN THEN
              CLOSE cr_existe_bcx;
            END IF;

            -- setar critica caso for o ultimo
            IF i = 100 THEN
              pr_dscritic := pr_dscritic || 'Registro de banco caixa ' ||
                             pr_nrdcaixa || ' em uso. Tente novamente!';
            END IF;
            -- aguardar 0,5 seg. antes de tentar novamente
            sys.dbms_lock.sleep(0.1);
        END;
      END LOOP;

      -- se encontrou erro ao buscar lote, abortar programa
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      ELSE  
        --Atualizar tabela crapbcx
        BEGIN
         UPDATE crapbcx SET crapbcx.qtcompln = nvl(crapbcx.qtcompln,0) + 1
         WHERE crapbcx.ROWID = rw_existe_bcx.ROWID;
        EXCEPTION
         WHEN Others THEN
           vr_cdcritic := 0;
           vr_dscritic := 'Erro ao atualizar tabela crapbcx. Erro: '||SQLERRM;
           --Levantar Excecao
           RAISE vr_exc_saida;
        END;        
      END IF;
       
     END IF;

     IF NVL(pr_nrdconta,0) > 0 THEN
        -- Se for pessoa fisica
        IF rw_crapass.inpessoa = 1 THEN

           -- Nome do titular que fez a transferencia
           OPEN cr_crapttl (pr_cdcooper => rw_crapass.cdcooper
                           ,pr_nrdconta => rw_crapass.nrdconta
                           ,pr_idseqttl => pr_idseqttl);
           -- Posicionar no proximo registro
           FETCH cr_crapttl INTO rw_crapttl;
           -- Se nao encontrar
           IF cr_crapttl%NOTFOUND THEN
              -- Fechar Cursor
              CLOSE cr_crapttl;
              vr_cdcritic:= 0;
              vr_dscritic:= 'Titular nao encontrado!';
              -- Gera exceção
              RAISE vr_exc_saida;
           END IF;
           -- Fechar Cursor
           CLOSE cr_crapttl;
           -- Nome titular
           vr_nmextttl:= rw_crapttl.nmextttl;
        ELSE
           vr_nmextttl:= rw_crapass.nmprimtl;
        END IF;

        IF pr_inpesgps = 1 THEN
          vr_dspesgps := 'PESSOA FISICA';
        ELSE
          vr_dspesgps := 'PESSOA JURIDICA';
        END IF;

        vr_dsinfor1:= 'Pagamento de GPS';
        vr_dsinfor2:= vr_nmextttl ||'#' ||
                      'Conta/dv: ' ||rw_crapass.nrdconta ||' - '||
                      rw_crapass.nmprimtl;

        -- Formatando a linha digitavel
        IF pr_sftcdbar IS NOT NULL AND pr_tpdpagto = 1 THEN -- Verifica se tem 48 posicoes
           vr_cdlidgfm := SUBSTR(pr_sftcdbar,1,11)  ||'-'|| SUBSTR(pr_sftcdbar,12,1) ||' '||
                          SUBSTR(pr_sftcdbar,13,11) ||'-'|| SUBSTR(pr_sftcdbar,24,1) ||' '||
                          SUBSTR(pr_sftcdbar,25,11) ||'-'|| SUBSTR(pr_sftcdbar,36,1) ||' '||
                          SUBSTR(pr_sftcdbar,37,11) ||'-'|| SUBSTR(pr_sftcdbar,48,1);
        END IF;

        IF pr_idorigem = 3             -- Internet Banking
        OR pr_nmdatela = 'AYLLOS' THEN -- Se veio pelo CRPS509

           -- Formatando a linha digitavel
           IF pr_cdbarras IS NOT NULL AND pr_tpdpagto = 1 THEN
              /* Verifica o Digito Verificador */
              vr_lindigi1 := SUBSTR(vr_cdbarras, 1,11);
              CXON0014.pc_verifica_digito(pr_nrcalcul => vr_lindigi1
							             ,pr_poslimit => 0            --Utilizado para validação de dígito adicional de DAS
                                         ,pr_nrdigito => vr_validig1);
              /* Verifica o Digito Verificador */
              vr_lindigi2 := SUBSTR(vr_cdbarras, 12,11);
              CXON0014.pc_verifica_digito(pr_nrcalcul => vr_lindigi2
							             ,pr_poslimit => 0            --Utilizado para validação de dígito adicional de DAS
                                         ,pr_nrdigito => vr_validig2);
              /* Verifica o Digito Verificador */
              vr_lindigi3 := SUBSTR(vr_cdbarras, 23,11);
              CXON0014.pc_verifica_digito(pr_nrcalcul => vr_lindigi3
							             ,pr_poslimit => 0            --Utilizado para validação de dígito adicional de DAS
                                         ,pr_nrdigito => vr_validig3);
              /* Verifica o Digito Verificador */
              vr_lindigi4 := SUBSTR(vr_cdbarras, 34,11);
              CXON0014.pc_verifica_digito(pr_nrcalcul => vr_lindigi4
							             ,pr_poslimit => 0            --Utilizado para validação de dígito adicional de DAS
                                         ,pr_nrdigito => vr_validig4);

              /* Montando a linha digitavel */
              vr_cdlidgfm := vr_lindigi1||'-'||vr_validig1||' '||
                             vr_lindigi2||'-'||vr_validig2||' '||
                             vr_lindigi3||'-'||vr_validig3||' '||
                             vr_lindigi4||'-'||vr_validig4;
           END IF;
          -- 397
          vr_nrcpfcgc := null;          
          FOR rw_crapsnh2 IN cr_crapsnh2 (pr_cdcooper,
                                          pr_nrdconta,
                                          pr_idseqttl) LOOP
             vr_nrcpfcgc :=  rw_crapsnh2.nrcpfcgc;        
          END LOOP;
          --
          -- Gerar Protocolo MD5
          GENE0006.pc_gera_protocolo_md5(pr_cdcooper => pr_cdcooper
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrdocmto => vr_ult_sequencia -- Sequencia CECRED
                                        ,pr_nrseqaut => vr_nrseqaut
                                        ,pr_vllanmto => pr_vlrtotal
                                        ,pr_nrdcaixa => pr_nrdcaixa
                                        ,pr_gravapro => TRUE
                                        ,pr_cdtippro => 13 -- Identificacao de Guia da Previdencia Social
                                        ,pr_dsinfor1 => vr_dsinfor1
                                        ,pr_dsinfor2 => vr_dsinfor2
                                        ,pr_dsinfor3 => 'Linha Digitavel: '||vr_cdlidgfm
                                                     || '#Codigo de Barras: '||vr_cdbarras
                                                     || '#03 - Codigo de Pagamento: '||pr_cdpagmto
                                                     || '#04 - Competência: '||SUBSTR(pr_dtcompet,5,2)||'/'||SUBSTR(pr_dtcompet,1,4)
                                                     || '#05 - Identificador: '||pr_dsidenti
                                                     || '#06 - Valor do INSS(R$): '||TO_CHAR(pr_vldoinss,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')
                                                     || '#09 - Valor Out. Entidades(R$): '||TO_CHAR(pr_vloutent,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')
                                                     || '#10 - ATM/Multa e Juros(R$): '||TO_CHAR(pr_vlatmjur,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')
                                                     || '#11 - Valor Total(R$): '||TO_CHAR(pr_vlrtotal,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')
                                        ,pr_dscedent => 'GPS Beneficiario ' || pr_dsidenti
                                        ,pr_flgagend => FALSE
                                        ,pr_nrcpfope => nvl(pr_nrcpfope,0)
                                        ,pr_nrcpfpre => nvl(vr_nrcpfcgc,0)
                                        ,pr_nmprepos => ''
                                        ,pr_dsprotoc => vr_dsprotoc
                                        ,pr_dscritic => pr_dscritic
                                        ,pr_des_erro => vr_dsretorn);

          -- Se retornou erro, gera critica
          IF pr_dscritic IS NOT NULL THEN
             RAISE vr_exc_saida;
          END IF;
        END IF;
     END IF;


     -- Se houve sucesso, seta critica do log:
     vr_dscritic := 'Pagamento GPS efetuado com sucesso!';
     GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                         ,pr_cdoperad => pr_cdoperad
                         ,pr_dscritic => NVL(vr_dscritic,' ')
                         ,pr_dsorigem => vr_dsorigem
                         ,pr_dstransa => vr_dstransa
                         ,pr_dttransa => TRUNC(SYSDATE)
                         ,pr_flgtrans => 1 --> 1-TRUE/SUCESSO
                         ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                         ,pr_idseqttl => pr_idseqttl
                         ,pr_nmdatela => pr_nmdatela
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrdrowid => vr_nrdrowid);

    -- Log Item => Código Pagamento
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Cod.Pagto'
                            , pr_dsdadant => TRIM(TO_CHAR(gene0002.fn_mask(pr_cdpagmto,'9999')))
                            , pr_dsdadatu => '');
    -- Log Item => Competencia
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Competencia'
                            , pr_dsdadant => SUBSTR(pr_dtcompet,5,2)||'/'||SUBSTR(pr_dtcompet,1,4)
                            , pr_dsdadatu => '');
    -- Log Item => Identificador
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Identificador'
                            , pr_dsdadant => pr_dsidenti
                            , pr_dsdadatu => '');
    -- Log Item => Valor Total
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Valor Total'
                            , pr_dsdadant => TO_CHAR(pr_vlrtotal,'999G999G999D99')
                            , pr_dsdadatu => '');

     -- Commit das informacoes
     COMMIT;

  EXCEPTION
    WHEN vr_exit THEN
      -- SAIR COM A TRANSACAO PENDENTE
      COMMIT;
     WHEN vr_exc_saida THEN
        -- Desfaz todas as alteracoes
        ROLLBACK;
        pr_dscritic := 'Pagamento não efetuado! =>' || pr_dscritic;
        pr_dslitera := NULL;
        pr_cdultseq := NULL;
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => NVL(pr_dscritic,' ')
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0 --> 0-FALSE/ERRO
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      COMMIT; -- Commitar o LOG
     WHEN OTHERS THEN
        -- Desfaz todas as alteracoes
        ROLLBACK;
        pr_dscritic := 'Erro e01: '||SQLCODE;
        pr_dscritic := 'Pagamento não efetuado! =>' || pr_dscritic;
        pr_dslitera := NULL;
        pr_cdultseq := NULL;
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => 'Erro pc_gps_pagamento: '||SQLERRM
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0 --> 0-FALSE/ERRO
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      COMMIT; -- Commitar o LOG
  END pc_gps_pagamento;



  /*---------------------------------------------------------------------------------------------------------------
   Autor    : Renato Darosci - Supero
   Objetivo : GPS - Consultar os dados da cooperativa para o sistema GPS
  ---------------------------------------------------------------------------------------------------------------*/
  PROCEDURE pc_gps_cooperativa(pr_cdcooper   IN crapcop.cdcooper%TYPE
                              ,pr_nrdconta   IN crapass.nrdconta%TYPE
                              ,pr_dscritic  OUT VARCHAR2
                              ,pr_retxml    OUT CLOB) IS

    vr_dstransa VARCHAR2(100) := 'Acesso a tela de Pagamento de GPS';
    vr_dsorigem VARCHAR2(100) := 'INTERNET';
    vr_dscritic VARCHAR2(500) := '';
    vr_tipdelog NUMBER        := 1; -- 1/SUCESSO/TRUE

    -- Buscar os dados que serão retornados para a tela
    CURSOR cr_cooper IS
      SELECT cop.cdcrdins
           , to_char(to_date(cop.hrinigps,'sssss'),'HH24:MI') hrinigps
           , to_char(to_date(cop.hrfimgps,'sssss'),'HH24:MI') hrfimgps
        FROM crapcop  cop
       WHERE cop.cdcooper = pr_cdcooper;

  BEGIN

    -- Montar o XML de dados que serão exibidos na tela de agendamento do GPS
    pr_retxml := '<dados >';

    -- Percorrer todos os dados retornados pela consulta
    FOR reg IN cr_cooper LOOP
      -- Conteudo dos registros
      pr_retxml := pr_retxml||'<cdcrdins>'||reg.cdcrdins||'</cdcrdins>'
                            ||'<hrinigps>'||reg.hrinigps||'</hrinigps>'
                            ||'<hrfimgps>'||reg.hrfimgps||'</hrfimgps>';

      IF  reg.cdcrdins = 0 THEN
        vr_dscritic := 'Cooperativa sem acesso GPS';
        vr_tipdelog := 0; -- ERRO/FALSE
      END IF;

      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => '996' -- pr_cdoperad
                          ,pr_dscritic => NVL(vr_dscritic,' ')
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => vr_tipdelog
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'INTERNETBANK'   -- pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    END LOOP;

    -- Finaliza o XML
    pr_retxml := pr_retxml||'</dados>';

  EXCEPTION
      WHEN OTHERS THEN
        --Monta mensagem de critica
        pr_dscritic := 'Erro na INSS0002.pc_gps_cooperativa --> '|| SQLERRM;
  END pc_gps_cooperativa;

  /*---------------------------------------------------------------------------------------------------------------
   Autor    : Renato Darosci - Supero
   Objetivo : GPS - Gerar as datas de agendamento para a competencia selecionada, retornando as mesmas
                    para serem exibidas na tela de confirmação
  ---------------------------------------------------------------------------------------------------------------*/
  PROCEDURE pc_gps_datas_competencia(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                    ,pr_nrdiadeb   IN NUMBER
                                    ,pr_dtcmptde   IN VARCHAR2 -- Recebe como string e trata no programa
                                    ,pr_dtcmpate   IN VARCHAR2 -- Recebe como string e trata no programa
                                    ,pr_dscritic  OUT VARCHAR2
                                    ,pr_retxml    OUT CLOB) IS

    -- Variáveis
    vr_dtdebito      DATE;
    vr_dtcalcul      DATE;
    vr_nrcmptde      NUMBER;
    vr_nrcmpate      NUMBER;

  BEGIN

    -- Atualizar as variáveis do período de competencia
    vr_nrcmptde := to_number(pr_dtcmptde);  -- Formato YYYYMM será tratado como number
    vr_nrcmpate := to_number(pr_dtcmpate);  -- Formato YYYYMM será tratado como number

    -- Montar o XML de dados que serão exibidos na tela de agendamento do GPS
    pr_retxml := '<dados>';

    -- Percorrer cada um dos agendamentos conforme competencia selecionada para criar os agendamentos
    FOR vr_nrmesano IN vr_nrcmptde..vr_nrcmpate LOOP

      /************************* CALCULO DE DATA *************************/
      -- Se o mês estiver indicando pagamento do décimo terceiro
      IF SUBSTR(vr_nrmesano,5) = 13 THEN
        -- Montar a data e realizar a conversão para DATE, considerando como data o dia 20/12 do ano
        vr_dtcalcul := to_date(vr_dialim13||SUBSTR(vr_nrmesano,1,4) ,'ddmmyyyy');

        pr_retxml := pr_retxml||'<linha><dscompet>13/'||SUBSTR(vr_nrmesano,1,4)||'</dscompet>';
      ELSE
        -- Montar a data e realizar a conversão para DATE, considerando como data o dia 20/12 do ano
        vr_dtcalcul := to_date( vr_nrmesano||LPAD(pr_nrdiadeb,2,'0') ,'yyyymmdd');

        pr_retxml := pr_retxml||'<linha><dscompet>'||to_char(to_date(vr_nrmesano,'yyyymm'),'mm/yyyy')||'</dscompet>';
      END IF;

      -- Igualar as variáveis com a mesma data
      vr_dtdebito := vr_dtcalcul;

      LOOP
        -- Busca uma data anterior válida - Retornar igual caso a data já seja valida
        vr_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                  ,pr_dtmvtolt => vr_dtdebito
                                                  ,pr_tipo     => 'A'); -- Retornar data anterior

        -- Validar se a data é dia util -> Se SIM... sai do loop
        EXIT WHEN vr_dtcalcul = vr_dtdebito;
        -- Atualiza a data de débito com a nova data
        vr_dtdebito := vr_dtcalcul;
      END LOOP;
      /*******************************************************************/

      -- Conteudo dos registros
      pr_retxml := pr_retxml||'<dtdebito>'||to_char(vr_dtdebito,'dd/mm/yyyy')||'</dtdebito></linha>';

    END LOOP;

    -- Finaliza o XML
    pr_retxml := pr_retxml||'</dados>';

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro['||pr_dtcmptde||'] rotina PC_GPS_DATAS_COMPETENCIA: '||SQLERRM;
      ROLLBACK;
  END pc_gps_datas_competencia;



  PROCEDURE pc_impressao_termo_gps(pr_xmldata  IN typ_xmldata
                                  ,pr_nmrescop IN VARCHAR2) IS
    -- ..........................................................................
    --  Programa : lisgps.php
    --  Sistema  : Rotinas para impressão de dados
    --  Sigla    : LISGPS
    --  Autor    : Andre Santos  - Supero
    --  Data     : Setembro/2014.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Agrupa os dados e monta o layout para impressão de dados depagamento GPS
    --
    --   Alteracoes:
    --
    -- .............................................................................

    -- Variáveis
    vr_nrdlinha     NUMBER := 0;

  BEGIN

    -- IMPRIMIR O CABEÇALHO
    pc_escreve_xml('--------------------------------------------------------------------------------',1);
    pc_escreve_xml('        '||pr_nmrescop||' - Comprovante de Pagamento - Guia da Previdencia Social ',2);

    pc_escreve_xml('   Emissao: '||TO_CHAR(SYSDATE,'DD/MM/YYYY')||' as '||TO_CHAR(SYSDATE,'HH24:MI:SS')||' Hr',4);

    pc_escreve_xml('       Conta/DV: '||TO_CHAR(pr_xmldata.nrdconta)||' - '||pr_xmldata.nmprimtl       ,6);

    pc_escreve_xml('--------------------------------------------------------------------------------',10);
    -- IMPRIMIR O CONTEÚDO
    -- Contador de linha - Iniciando na nona linha do XML
    vr_nrdlinha := 11;

    -- Codigo de Barras/Linha Digitavel
    pc_escreve_xml('             Linha Digitavel: '||pr_xmldata.cdlindig,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    pc_escreve_xml('             Codido de Barra: '||pr_xmldata.cdbarras,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime a Conta do Pagamento
    pc_escreve_xml('     03- Codigo do Pagamento: '||pr_xmldata.cddpagto,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime Competencia
    pc_escreve_xml('             04- Competencia: '||pr_xmldata.mmaacomp,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime Indentificador
    pc_escreve_xml('           05- Identificador: '||pr_xmldata.cdidenti,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime Valor do INSS
    pc_escreve_xml('      06- Valor do INSS (R$): '||TO_CHAR(pr_xmldata.vlrdinss,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime Valor de Outras Entidades
    pc_escreve_xml('09- Valor Out. Entidades(R$): '||TO_CHAR(pr_xmldata.vlrouent,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime ATM, Multa e Juros
    pc_escreve_xml('   10- ATM/Multa e Juros(R$): '||TO_CHAR(pr_xmldata.vlrjuros,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime Valor Total
    pc_escreve_xml('        11- Valor Total (R$): '||TO_CHAR(pr_xmldata.vlrtotal,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Data do Pagamento
    pc_escreve_xml('           Data do Pagamento: '||TO_CHAR(pr_xmldata.dtmvtolt,'DD/MM/RRRR'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Imprime Hora da Transacao
    pc_escreve_xml('           Hora da Transacao: '||GENE0002.fn_converte_time_data(pr_xmldata.hrtransa,'S'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Se tem Nro de Controle
    pc_escreve_xml('         Numero do Documento: '||TO_CHAR(pr_xmldata.nrdocmto,'FM9999999999','NLS_NUMERIC_CHARACTERS=,.'),vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Se tem Nro de Controle
    pc_escreve_xml('         Seq da Autenticacao: '||pr_xmldata.nrdcontr,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

    -- Autenticacao Eletronica
    pc_escreve_xml('     Autenticacao Eletronica: '||pr_xmldata.dsprotoc,vr_nrdlinha);
    vr_nrdlinha := vr_nrdlinha + 1; -- Próxima linha

  END pc_impressao_termo_gps;


  PROCEDURE pc_gps_totalizar(pr_dtpagmto IN VARCHAR2
                            ,pr_cdagenci IN VARCHAR2
                            ,pr_nrdcaixa IN VARCHAR2
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_gps_totalizar
  --  Sistema  : Busca quantidade e valor total - GPS
  --  Sigla    : CRED
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Setembro/2015.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Busca quantidade e valor total - GPS
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

     -- Cursor
     -- Buscar as informações da cooperativa
     CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
       SELECT crapcop.cdcooper
            , crapcop.cdbcoctl
            , crapcop.cdagectl
            , crapcop.nmrescop
         FROM crapcop
        WHERE crapcop.cdcooper = p_cdcooper;
     rw_crapcop cr_crapcop%ROWTYPE;

     -- Busca data do sistema
     CURSOR cr_crapdat(p_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT dat.dtmvtocd dtmvtolt
          FROM crapdat dat
         WHERE dat.cdcooper = p_cdcooper;
     rw_crapdat cr_crapdat%ROWTYPE;

     -- Busca os de GPS
     CURSOR cr_craplgp(p_cdcooper crapcop.cdcooper%TYPE
                      ,p_dtpagmto crapdat.dtmvtolt%TYPE
                      ,p_cdagenci crapage.cdagenci%TYPE
                      ,p_nrdcaixa NUMBER) IS
        SELECT COUNT(lgp.cdcooper)       qtd_recebido
              ,NVL(SUM(lgp.vlrtotal),0)  vlr_recebido
          FROM craplgp lgp
         WHERE lgp.cdcooper  = p_cdcooper
           AND lgp.dtmvtolt  = p_dtpagmto
          AND (lgp.cdagenci = p_cdagenci
            OR  p_cdagenci = 0)
           AND (lgp.nrdcaixa = p_nrdcaixa
            OR p_nrdcaixa = 0)
           AND lgp.flgpagto  = 1
           AND lgp.flgativo  = 1;
     rw_craplgp cr_craplgp%ROWTYPE;


     vr_cdcooper    NUMBER;
     vr_nmdatela    VARCHAR2(25);
     vr_nmeacao     VARCHAR2(25);
     vr_cdagenci    VARCHAR2(25);
     vr_nrdcaixa    VARCHAR2(25);
     vr_idorigem    VARCHAR2(25);
     vr_cdoperad    VARCHAR2(500);

  BEGIN
     -- Inicializa Variavel
     pr_cdcritic := NULL;
     pr_dscritic := NULL;
     pr_des_erro := NULL;
     pr_nmdcampo := NULL;

     -- Extrair informações padrão do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     -- Criar cabeçalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Buscar dados da cooperativa
     OPEN  cr_crapcop(vr_cdcooper);
     FETCH cr_crapcop INTO rw_crapcop;
        -- Se não encontrar dados
        IF cr_crapcop%NOTFOUND THEN
           -- Fecha cursor
           CLOSE cr_crapcop;
           pr_des_erro := 'Cooperativa não encontrada. VR_CDCOOPER = '||vr_cdcooper;
           RAISE vr_exc_saida;
        END IF;
     CLOSE cr_crapcop;

     -- Busca data do sistema
     OPEN cr_crapdat(rw_crapcop.cdcooper);
     FETCH cr_crapdat INTO rw_crapdat;
     CLOSE cr_crapdat;

     -- Nao pode ser null
     IF pr_dtpagmto IS NULL THEN
        pr_des_erro := 'Data de pagamento deve ser informada!';
        RAISE vr_exc_saida;
     END IF;

     -- Busca totais
     OPEN cr_craplgp(rw_crapcop.cdcooper
                    ,TO_DATE(pr_dtpagmto,'DD/MM/YYYY')
                    ,pr_cdagenci
                    ,pr_nrdcaixa);
     FETCH cr_craplgp INTO rw_craplgp;
        -- Se não encontrar dados
        IF cr_craplgp%NOTFOUND THEN
           -- Fecha cursor
           CLOSE cr_craplgp;
           pr_des_erro := 'Não foi encontrado';
           RAISE vr_exc_saida;
        END IF;
     CLOSE cr_craplgp;

     -- Nome do Primeiro Titular
     pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                        ,'/Root'
                                        ,XMLTYPE('<Dados qtd_recebido="'|| rw_craplgp.qtd_recebido ||'" vlr_recebido="'||TO_CHAR(rw_craplgp.vlr_recebido,'FM999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')||'" ></Dados>'));

  EXCEPTION
     WHEN vr_exc_saida THEN
        ROLLBACK;
        pr_dscritic := pr_des_erro;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
        ROLLBACK;
        pr_des_erro := 'Erro geral na rotina pc_gps_totalizar: '||SQLERRM;
        pr_dscritic := 'Erro geral na rotina pc_gps_totalizar: '||SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_gps_totalizar;


  PROCEDURE pc_gps_detalhes(pr_dtpagmto IN VARCHAR2
                           ,pr_cdagenci IN VARCHAR2
                           ,pr_nrdcaixa IN VARCHAR2
                           ,pr_cdidenti IN VARCHAR2
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_gps_detalhes
  --  Sistema  : Busca os detalhes de pagmentos - GPS
  --  Sigla    : CRED
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Setembro/2015.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Busca os detalhes de pagmentos - GPS
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
     -- Cursor
     -- Buscar as informações da cooperativa
     CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
       SELECT crapcop.cdcooper
            , crapcop.cdbcoctl
            , crapcop.cdagectl
            , crapcop.nmrescop
         FROM crapcop
        WHERE crapcop.cdcooper = p_cdcooper;
     rw_crapcop cr_crapcop%ROWTYPE;

     -- Busca data do sistema
     CURSOR cr_crapdat(p_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT dat.dtmvtocd dtmvtolt
          FROM crapdat dat
         WHERE dat.cdcooper = p_cdcooper;
     rw_crapdat cr_crapdat%ROWTYPE;

     -- Busca os de GPS
     CURSOR cr_craplgp(p_cdcooper crapcop.cdcooper%TYPE
                      ,p_dtpagmto crapdat.dtmvtolt%TYPE
                      ,p_cdagenci NUMBER
                      ,p_nrdcaixa NUMBER
                      ,p_cdidenti VARCHAR2) IS
        SELECT lgp.cdcooper
              ,lgp.dtmvtolt
              ,lgp.cdopecxa
              ,lgp.idsicred
               /* Lista */
              ,lgp.cdagenci
              ,lgp.nrdcaixa
              ,ope.nmoperad
              ,lgp.nrsequni
              ,lgp.cdbccxlt
              ,lgp.nrdolote
              ,lgp.vlrdinss
              ,lgp.vlrtotal
              /* Detalhes da Lista */
              ,lgp.tpdpagto
              ,lgp.tpleitur
              ,NVL(TRIM(lgp.cdbarras),NVL(TRIM(lgp.dslindig),' ')) cdbarras
              ,lgp.nrctapag
              ,DECODE(lgp.nrctapag,0,'Pago no Caixa',(SELECT ass.nmprimtl
                                                        FROM crapass ass
                                                       WHERE ass.cdcooper = lgp.cdcooper
                                                         AND ass.nrdconta = lgp.nrctapag)) nmprimtl
              ,lgp.cdidenti2 cdidenti
              ,lgp.cddpagto
              ,lgp.mmaacomp
              ,lgp.dtvencto
              ,lgp.vlrjuros
              ,lgp.vlrouent
              ,lgp.hrtransa
              ,lgp.nrautdoc
              ,DECODE(lgp.inpesgps,1,'Pessoa Física','Pessoa Júridica')  inpesgps
              , DECODE(lgp.nrseqagp,0
                ,DECODE(lgp.nrctapag,0,'Em Espécie'
                   ,DECODE(lgp.cdagenci,90,'Por Internet','Débito em Conta')
                       )
                   ,'Por Agendamento'
                   ) nrseqagp
              ,lgp.nrseqdig
          FROM craplgp lgp
              ,crapope ope
         WHERE lgp.cdcooper  = p_cdcooper
           AND lgp.dtmvtolt  = p_dtpagmto
           AND (lgp.cdagenci = p_cdagenci
              OR  p_cdagenci = 0)
           AND (lgp.nrdcaixa = p_nrdcaixa
               OR p_nrdcaixa = 0)
           AND (lgp.cdidenti2 = p_cdidenti OR
                   p_cdidenti = 0)
           AND lgp.flgpagto  = 1
           AND lgp.flgativo  = 1
           AND ope.cdcooper  = lgp.cdcooper
           AND UPPER(ope.cdoperad)  = UPPER(lgp.cdopecxa)
           ORDER BY lgp.cdagenci
                   ,lgp.nrdcaixa
                   ,lgp.nrdolote
                   ,lgp.vlrtotal;
     rw_craplgp cr_craplgp%ROWTYPE;

     -- Variaveis
     vr_exc_saida EXCEPTION;

     vr_cdcooper    NUMBER;
     vr_nmdatela    VARCHAR2(25);
     vr_nmeacao     VARCHAR2(25);
     vr_cdagenci    VARCHAR2(25);
     vr_nrdcaixa    VARCHAR2(25);
     vr_idorigem    VARCHAR2(25);
     vr_cdoperad    VARCHAR2(500);

     vr_index PLS_INTEGER;

     -- Variavel Tabela Temporaria
     vr_tab_dados   gene0007.typ_mult_array;       --> PL Table para armazenar dados para formar o XML
     vr_tab_tags    gene0007.typ_tab_tagxml;       --> PL Table para armazenar TAG´s do XML

  BEGIN
     -- Inicializa Variavel
     pr_cdcritic := NULL;
     pr_dscritic := NULL;
     pr_des_erro := NULL;
     pr_nmdcampo := NULL;

     -- Extrair informações padrão do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     -- Criar cabeçalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Buscar dados da cooperativa
     OPEN  cr_crapcop(vr_cdcooper);
     FETCH cr_crapcop INTO rw_crapcop;
        -- Se não encontrar dados
        IF cr_crapcop%NOTFOUND THEN
           -- Fecha cursor
           CLOSE cr_crapcop;
           pr_des_erro := 'Cooperativa não encontrada. VR_CDCOOPER = '||vr_cdcooper;
           RAISE vr_exc_saida;
        END IF;
     CLOSE cr_crapcop;

     -- Busca data do sistema
     OPEN cr_crapdat(rw_crapcop.cdcooper);
     FETCH cr_crapdat INTO rw_crapdat;
     CLOSE cr_crapdat;

     -- Nao pode ser null
     IF pr_dtpagmto IS NULL THEN
        pr_des_erro := 'Data de pagamento deve ser informada!';
        RAISE vr_exc_saida;
     END IF;

     FOR rw_craplgp IN cr_craplgp(rw_crapcop.cdcooper
                                 ,TO_DATE(pr_dtpagmto,'DD/MM/YYYY')
                                 ,pr_cdagenci
                                 ,pr_nrdcaixa
                                 ,pr_cdidenti) LOOP
        -- Captura último indice da PL Table
        vr_index := nvl(vr_tab_dados.count, 0) + 1;
        -- Gravando registros
        vr_tab_dados(vr_index)('cdcooper') := rw_craplgp.cdcooper;
        vr_tab_dados(vr_index)('dtmvtolt') := TO_CHAR(rw_craplgp.dtmvtolt,'DD/MM/YYYY');
        vr_tab_dados(vr_index)('cdopecxa') := rw_craplgp.cdopecxa;
        vr_tab_dados(vr_index)('idsicred') := rw_craplgp.idsicred;
        vr_tab_dados(vr_index)('cdagenci') := rw_craplgp.cdagenci;
        vr_tab_dados(vr_index)('nrdcaixa') := rw_craplgp.nrdcaixa;
        vr_tab_dados(vr_index)('nmoperad') := rw_craplgp.nmoperad;
        vr_tab_dados(vr_index)('nrsequni') := rw_craplgp.nrsequni;
        vr_tab_dados(vr_index)('cdbccxlt') := rw_craplgp.cdbccxlt;
        vr_tab_dados(vr_index)('nrdolote') := rw_craplgp.nrdolote;
        vr_tab_dados(vr_index)('vlrdinss') := TO_CHAR(rw_craplgp.vlrdinss,'FM99G999G990D00','NLS_NUMERIC_CHARACTERS=,.');
        vr_tab_dados(vr_index)('vlrtotal') := TO_CHAR(rw_craplgp.vlrtotal,'FM99G999G990D00','NLS_NUMERIC_CHARACTERS=,.');

        -- Se for com cod.barras e o tipo de leitura for manual
        IF rw_craplgp.tpdpagto = 1 AND rw_craplgp.tpleitur = 0 THEN
           vr_tab_dados(vr_index)('tpdpagto') := 'Com Código de Barras/Manual';
        -- Se for com cod.barras e o tipo de leitura for automatico
        ELSIF rw_craplgp.tpdpagto = 1 AND rw_craplgp.tpleitur = 1 THEN
           vr_tab_dados(vr_index)('tpdpagto') := 'Com Código de Barras via Leitora';
        ELSE
           vr_tab_dados(vr_index)('tpdpagto') := 'Sem Código de Barras/Manual';
        END IF;

        vr_tab_dados(vr_index)('cdbarras') := rw_craplgp.cdbarras;
        vr_tab_dados(vr_index)('nrctapag') := GENE0002.fn_mask_conta(rw_craplgp.nrctapag);
        vr_tab_dados(vr_index)('nmprimtl') := rw_craplgp.nmprimtl;
        vr_tab_dados(vr_index)('cdidenti') := rw_craplgp.cdidenti;
        vr_tab_dados(vr_index)('cddpagto') := rw_craplgp.cddpagto;
        vr_tab_dados(vr_index)('mmaacomp') := SUBSTR(LPAD(rw_craplgp.mmaacomp,6,0),1,2)||'/'||SUBSTR(LPAD(rw_craplgp.mmaacomp,6,0),3,4);
        vr_tab_dados(vr_index)('dtvencto') := TO_CHAR(rw_craplgp.dtvencto,'DD/MM/YYYY');
        vr_tab_dados(vr_index)('vlrjuros') := TO_CHAR(rw_craplgp.vlrjuros,'FM99G999G990D00','NLS_NUMERIC_CHARACTERS=,.');
        vr_tab_dados(vr_index)('vlrouent') := TO_CHAR(rw_craplgp.vlrouent,'FM99G999G990D00','NLS_NUMERIC_CHARACTERS=,.');
        vr_tab_dados(vr_index)('hrtransa') := GENE0002.fn_converte_time_data(rw_craplgp.hrtransa);
        vr_tab_dados(vr_index)('nrautdoc') := rw_craplgp.nrautdoc;
        vr_tab_dados(vr_index)('inpesgps') := rw_craplgp.inpesgps;
        vr_tab_dados(vr_index)('nrseqagp') := rw_craplgp.nrseqagp;
        vr_tab_dados(vr_index)('nrseqdig') := rw_craplgp.nrseqdig;
     END LOOP;

     -- Geração de TAG's
     gene0007.pc_gera_tag('cdcooper',vr_tab_tags);
     gene0007.pc_gera_tag('dtmvtolt',vr_tab_tags);
     gene0007.pc_gera_tag('cdopecxa',vr_tab_tags);
     gene0007.pc_gera_tag('idsicred',vr_tab_tags);
     gene0007.pc_gera_tag('cdagenci',vr_tab_tags);
     gene0007.pc_gera_tag('nrdcaixa',vr_tab_tags);
     gene0007.pc_gera_tag('nmoperad',vr_tab_tags);
     gene0007.pc_gera_tag('nrsequni',vr_tab_tags);
     gene0007.pc_gera_tag('cdbccxlt',vr_tab_tags);
     gene0007.pc_gera_tag('nrdolote',vr_tab_tags);
     gene0007.pc_gera_tag('vlrdinss',vr_tab_tags);
     gene0007.pc_gera_tag('vlrtotal',vr_tab_tags);
     gene0007.pc_gera_tag('tpdpagto',vr_tab_tags);
     gene0007.pc_gera_tag('cdbarras',vr_tab_tags);
     gene0007.pc_gera_tag('nrctapag',vr_tab_tags);
     gene0007.pc_gera_tag('nmprimtl',vr_tab_tags);
     gene0007.pc_gera_tag('cdidenti',vr_tab_tags);
     gene0007.pc_gera_tag('cddpagto',vr_tab_tags);
     gene0007.pc_gera_tag('mmaacomp',vr_tab_tags);
     gene0007.pc_gera_tag('dtvencto',vr_tab_tags);
     gene0007.pc_gera_tag('vlrjuros',vr_tab_tags);
     gene0007.pc_gera_tag('vlrouent',vr_tab_tags);
     gene0007.pc_gera_tag('hrtransa',vr_tab_tags);
     gene0007.pc_gera_tag('nrautdoc',vr_tab_tags);
     gene0007.pc_gera_tag('inpesgps',vr_tab_tags);
     gene0007.pc_gera_tag('nrseqagp',vr_tab_tags);
     gene0007.pc_gera_tag('nrseqdig',vr_tab_tags);

     -- Forma XML de retorno para casos de sucesso (listar dados)
     gene0007.pc_gera_xml(pr_tab_dados => vr_tab_dados
                         ,pr_tab_tag   => vr_tab_tags
                         ,pr_XMLType   => pr_retxml
                         ,pr_path_tag  => '/Root'
                         ,pr_tag_no    => 'detalhes'
                         ,pr_des_erro  => pr_des_erro);

     -- Se encontrar erros
     IF pr_des_erro IS NOT NULL THEN
        pr_cdcritic := 0;
        RAISE vr_exc_saida;
     END IF;

  EXCEPTION
     WHEN vr_exc_saida THEN
        ROLLBACK;
        pr_dscritic := pr_des_erro;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
        ROLLBACK;
        pr_des_erro := 'Erro geral na rotina pc_gps_detalhes: '||SQLERRM;
        pr_dscritic := 'Erro geral na rotina pc_gps_detalhes: '||SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_gps_detalhes;


  PROCEDURE pc_lisgps_imp(pr_cdcooper  IN NUMBER
                         ,pr_dsiduser  IN VARCHAR2
                         ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                         ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                         ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                         ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                         ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                         ,pr_des_erro  OUT VARCHAR2) IS         --> Erros do processo

     /* .............................................................................
     Programa: pc_lisgps_imp
     Sistema : Rotinas acessadas pelas telas de cadastros Web
     Sigla   : INSS
     Autor   : Andre Santos - Supero
     Data    : Setembro/2015.                  Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Efetua a impressao dos protocolos
     Observacao: -----

     Alteracoes:

     ..............................................................................*/
     -- CURSORES
     -- Buscar as informações da cooperativa
     CURSOR cr_crapcop IS
       SELECT crapcop.cdbcoctl
             ,crapcop.cdagectl
             ,crapcop.nmrescop
         FROM crapcop
        WHERE crapcop.cdcooper = pr_cdcooper;

    -- Busca as informacoes do associado
    CURSOR cr_crapass(p_cdcooper crapcop.cdcooper%TYPE
                     ,p_nrctapag crapass.nrdconta%TYPE) IS
       SELECT ass.nmprimtl
         FROM crapass ass
        WHERE ass.cdcooper = p_cdcooper
          AND ass.nrdconta = p_nrctapag;
    rw_crapass cr_crapass%ROWTYPE;

    -- Busca o protocolo de autenticacao do pagamento
    CURSOR cr_craplgp(p_cdcooper crapcop.cdcooper%TYPE
                     ,p_nrctapag craplgp.nrctapag%TYPE
                     ,p_nrseqdig craplgp.nrseqdig%TYPE
                     ,p_cdidenti VARCHAR2
                     ,p_dtmvtolt craplgp.dtmvtolt%TYPE) IS
       SELECT lgp.cdagenci
             ,lgp.nrctapag
             ,DECODE(lgp.inpesgps,1,'Pessoa Física','Pessoa Júridica')  inpesgps
             ,lgp.tpdpagto
             ,lgp.nrautdoc
             ,lgp.tpleitur
             ,lgp.cddpagto
             ,lgp.mmaacomp
             ,lgp.cdidenti2 cdidenti
             ,NVL(lgp.vlrdinss,0) vlrdinss
             ,NVL(lgp.vlrouent,0) vlrouent
             ,NVL(lgp.vlrjuros,0) vlrjuros
             ,NVL(lgp.vlrtotal,0) vlrtotal
             ,lgp.dtmvtolt
             ,pro.hrautent hrtransa
             ,pro.dsprotoc
             ,pro.nmprepos
             ,pro.nrdocmto
             ,pro.dsinform##3
         FROM craplgp lgp
             ,crappro pro
        WHERE lgp.cdcooper  = pro.cdcooper
          AND lgp.nrctapag  = pro.nrdconta
          AND lgp.nrautdoc  = pro.nrseqaut
          AND pro.cdtippro  = 13 -- Fixo -- Pagamento GPS
          AND lgp.cdcooper  = p_cdcooper
          AND lgp.nrctapag  = p_nrctapag
          AND lgp.nrseqdig  = p_nrseqdig
          AND lgp.cdidenti2 = p_cdidenti
          AND lgp.dtmvtolt  = p_dtmvtolt;
    rw_craplgp cr_craplgp%ROWTYPE;

    -- REGISTROS
    rw_crapcop     cr_crapcop%ROWTYPE;
    rw_crapdat     btch0001.cr_crapdat%ROWTYPE; -- Informações de data
    rw_xmldata     typ_xmldata;

    -- VARIÁVEIS
    vr_cdcooper    NUMBER;
    vr_nmdatela    VARCHAR2(25);
    vr_nmeacao     VARCHAR2(25);
    vr_cdagenci    VARCHAR2(25);
    vr_nrdcaixa    VARCHAR2(25);
    vr_idorigem    VARCHAR2(25);
    vr_cdoperad    VARCHAR2(25);

    vr_reg      GENE0002.typ_split; -- Contem registros da CRAPPRO
    vr_cdbarras GENE0002.typ_split; -- Contem registros da CRAPPRO
    vr_lindigit GENE0002.typ_split; -- Contem registros da CRAPPRO

    -- Chave para buscar o pagamento selecionado
    vr_nrctapag    craplgp.nrctapag%TYPE;
    vr_nrseqdig    craplgp.nrseqdig%TYPE;
    vr_cdidenti    VARCHAR2(20);
    vr_dtmvtolt    craplgp.dtmvtolt%TYPE;

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
     -- Guardar o nome da rotina chamada para exibir em caso de erro
      vr_nmrotina := 'PC_IMPRESSAO_TERMO_GPS';

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
       RAISE vr_exc_saida;
     END IF;
     CLOSE cr_crapcop;

    -- Busca a data de execução
    OPEN  BTCH0001.cr_crapdat(pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar dados
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      CLOSE BTCH0001.cr_crapdat;
      pr_des_erro := 'Data do sistema não encontrada. PR_CDCOOPER = '||pr_cdcooper;
      RAISE vr_exc_saida;
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
    gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_dsdirarq||'* 2> /dev/null'
                               ,pr_typ_saida   => vr_typ_said
                               ,pr_des_saida   => pr_des_erro);
    -- Verificar retorno de erro
    IF NVL(vr_typ_said, ' ') = 'ERR' THEN
      -- O comando shell executou com erro, gerar log e sair do processo
      pr_cdcritic := 0;
      pr_des_erro := 'Erro ao remover arquivos: '||pr_des_erro;
      RAISE vr_exc_saida;
    END IF;

    -- Extrair as informações para a impressão
    vr_nrctapag := TO_NUMBER(fn_extract('/Root/Dados/nrdconta/text()'));
    vr_nrseqdig := TO_NUMBER(fn_extract('/Root/Dados/nrseqdig/text()'));
    vr_cdidenti := fn_extract('/Root/Dados/dsidenti/text()');
    vr_dtmvtolt := TO_DATE(fn_extract('/Root/Dados/dtmvtolt/text()'),'DD/MM/YYYY');

    -- Busca os dados do pagamento
    OPEN cr_craplgp(pr_cdcooper
                   ,vr_nrctapag
                   ,vr_nrseqdig
                   ,vr_cdidenti
                   ,vr_dtmvtolt);
    FETCH cr_craplgp INTO rw_craplgp;
    CLOSE cr_craplgp;

    -- Busca os dados do pagamento
    OPEN cr_crapass(pr_cdcooper
                   ,vr_nrctapag);
    FETCH cr_crapass INTO rw_crapass;
    CLOSE cr_crapass;

    rw_xmldata.cddbanco := 85;
    rw_xmldata.cdagenci := rw_craplgp.cdagenci;
    rw_xmldata.nrdconta := rw_craplgp.nrctapag;
    rw_xmldata.nmprimtl := rw_crapass.nmprimtl;
    rw_xmldata.nmprepos := rw_craplgp.nmprepos;
    rw_xmldata.nrdocmto := rw_craplgp.nrdocmto;
    rw_xmldata.nrdcontr := rw_craplgp.nrautdoc;
    rw_xmldata.inpesgps := rw_craplgp.inpesgps;

    -- Se for com cod.barras e o tipo de leitura for manual
    IF rw_craplgp.tpdpagto = 1 AND rw_craplgp.tpleitur = 0 THEN
       rw_xmldata.tpdpagto := 'Com Código de Barras/Manual';
    -- Se for com cod.barras e o tipo de leitura for automatico
    ELSIF rw_craplgp.tpdpagto = 1 AND rw_craplgp.tpleitur = 0 THEN
       rw_xmldata.tpdpagto := 'Com Código de Barras via Leitora';
    ELSIF rw_craplgp.tpdpagto IN (0,2) THEN
       rw_xmldata.tpdpagto := 'Sem Código de Barras/Manual';
    END IF;

    vr_reg := gene0002.fn_quebra_string(pr_string  => rw_craplgp.dsinform##3
                                       ,pr_delimit => '#' );
    IF vr_reg.COUNT > 0 THEN
       rw_xmldata.cdbarras := '';
       rw_xmldata.cdlindig := '';
       -- Se existir codigo de barras
       IF vr_reg.EXISTS(1) THEN
          vr_lindigit := gene0002.fn_quebra_string(pr_string => vr_reg(1) , pr_delimit => ':' );
          -- Separa o cod.barras do LABEL
          IF vr_lindigit.EXISTS(2) THEN
             rw_xmldata.cdlindig := TRIM(vr_lindigit(2));
          END IF;
       END IF;
       -- Se existir linha digitavel
       IF vr_reg.EXISTS(2) THEN
          vr_cdbarras := gene0002.fn_quebra_string(pr_string => vr_reg(2) , pr_delimit => ':' );
          -- Separa o linha digitavel do LABEL
          IF vr_cdbarras.EXISTS(2) THEN
             rw_xmldata.cdbarras := TRIM(vr_cdbarras(2));
          END IF;
       END IF;
    END IF;

    rw_xmldata.mmaacomp := SUBSTR(LPAD(rw_craplgp.mmaacomp,6,0),1,2)||'/'||SUBSTR(LPAD(rw_craplgp.mmaacomp,6,0),3,4);
    rw_xmldata.cddpagto := rw_craplgp.cddpagto;
    rw_xmldata.cdidenti := rw_craplgp.cdidenti;
    rw_xmldata.vlrdinss := rw_craplgp.vlrdinss;
    rw_xmldata.vlrouent := rw_craplgp.vlrouent;
    rw_xmldata.vlrjuros := rw_craplgp.vlrjuros;
    rw_xmldata.vlrtotal := rw_craplgp.vlrtotal;
    rw_xmldata.dtmvtolt := rw_craplgp.dtmvtolt;
    rw_xmldata.hrtransa := rw_craplgp.hrtransa;
    rw_xmldata.dsprotoc := rw_craplgp.dsprotoc;

    -- Inicializar o CLOB do XML
    vr_dsxmlrel := NULL;
    dbms_lob.createtemporary(vr_dsxmlrel, true);
    dbms_lob.open(vr_dsxmlrel, dbms_lob.lob_readwrite);

    -- Inicilizar as informações do XML
    vr_dsdtexto := NULL;
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><root>');

    -- Imprimir transferencia
    pc_impressao_termo_gps(pr_xmldata  => rw_xmldata
                          ,pr_nmrescop => rw_crapcop.nmrescop);

    -- Tag de finalização do XML
    pc_escreve_xml('</root>',NULL,TRUE);

    -- Solicitar geração do relatorio
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                               ,pr_cdprogra  => vr_nmdatela -- 'LISGPS'              --> Programa chamador
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtocd                  --> Data do movimento atual
                               ,pr_dsxml     => vr_dsxmlrel                          --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/root'                              --> Nó base do XML para leitura dos dados
                               ,pr_dsjasper  => 'lisgps.jasper'                      --> Arquivo de layout do iReport
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
                               ,pr_des_erro  => pr_des_erro);                        --> Saída com erro

    -- Tratar erro
    IF TRIM(pr_des_erro) IS NOT NULL THEN
      pr_des_erro := 'Erro ao gerar relatorio: '||TRIM(pr_des_erro);
      RAISE vr_exc_saida;
    END IF;

    -- Enviar relatorio para intranet
    gene0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper    --> Cooperativa conectada
                                ,pr_cdagenci => vr_cdagenci    --> Codigo da agencia para erros
                                ,pr_nrdcaixa => vr_nrdcaixa    --> Codigo do caixa para erros
                                ,pr_nmarqpdf => vr_dsdirarq    --> Arquivo PDF  a ser gerado
                                ,pr_des_reto => vr_des_reto    --> Saída com erro
                                ,pr_tab_erro => vr_tab_erro);  --> tabela de erros

    -- caso apresente erro na operação
    IF NVL(vr_des_reto,'OK') <> 'OK' THEN
       IF vr_tab_erro.COUNT > 0 THEN
          pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          pr_des_erro := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

          RAISE vr_exc_saida;
       END IF;
    END IF;

    -- Comando para excluir arquivos já existentes
    gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_dsdirarq
                               ,pr_typ_saida   => vr_typ_said
                               ,pr_des_saida   => pr_des_erro);
    -- Verificar retorno de erro
    IF NVL(vr_typ_said, ' ') = 'ERR' THEN
       -- O comando shell executou com erro, gerar log e sair do processo
       pr_cdcritic := 0;
       pr_des_erro := 'Erro ao remover arquivos: '||pr_des_erro;
       RAISE vr_exc_saida;
    END IF;

    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_dsxmlrel);
    dbms_lob.freetemporary(vr_dsxmlrel);

    -- Criar XML de retorno
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' || vr_nmarqpdf || '</nmarqpdf>');

  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_dscritic := pr_des_erro;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');

    WHEN OTHERS THEN
      pr_des_erro := 'Erro geral em PC_LISGPS['||vr_nmrotina||']: ' || SQLERRM;
      pr_dscritic := pr_des_erro;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>Rotina com erros</Erro></Root>');
  END pc_lisgps_imp;

  /*---------------------------------------------------------------------------------------------------------------
   Autor    : Renato Darosci - Supero
   Objetivo : GPS - Validar os dados do pagamento
  ---------------------------------------------------------------------------------------------------------------*/
  PROCEDURE pc_gps_validar_pagar(pr_cdcooper   IN craplau.cdcooper%TYPE
                                ,pr_nrdconta   IN craplau.nrdconta%TYPE
                                ,pr_nrseqagp   IN craplau.nrseqagp%TYPE
                                ,pr_dtmvtolt   IN craplau.dtmvtopg%TYPE
                                ,pr_cdcritic  OUT NUMBER
                                ,pr_dscritic  OUT VARCHAR2) IS
    -- Buscar dados da CRAPLGP
    CURSOR cr_craplgp IS
      SELECT lgp.cdagenci
           , lgp.nrdcaixa
           , lgp.tpdpagto
           , lgp.cdopecxa
           , lgp.cdbarras
           , lgp.dslindig
           , lgp.cddpagto
           , lgp.mmaacomp
           , lgp.cdidenti2 cdidenti
           , lgp.vlrdinss
           , lgp.vlrouent
           , lgp.vlrjuros
           , lgp.vlrtotal
           , lgp.dtvencto
           , lgp.inpesgps
           , lgp.tpleitur
        FROM craplgp  lgp
       WHERE lgp.cdcooper = pr_cdcooper
         AND lgp.nrctapag = pr_nrdconta
         AND lgp.nrseqagp = pr_nrseqagp;
    rw_craplgp   cr_craplgp%ROWTYPE;

    --Registro tipo Data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Variáveis
    vr_dscritic  VARCHAR2(500) := NULL;
    vr_dslitera  VARCHAR2(500);
    vr_cdultseq  NUMBER;
    vr_idorigem  NUMBER(1);
    vr_cdcompet  VARCHAR2(10);

  BEGIN

    -- Carregar os dados de lançamentos de guias
    OPEN  cr_craplgp;
    FETCH cr_craplgp INTO rw_craplgp;
    -- Se não encontrar registro
    IF cr_craplgp%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_craplgp;

      -- Setar mensagem de erro
      vr_dscritic := 'Registro de Lançamentos das Guias da Previdência Social não encontrado!';

      -- Excessão
      RAISE vr_exc_saida;
    END IF;

    -- Fechar o cursor
    CLOSE cr_craplgp;

    -- Busca a data de execução
    OPEN  BTCH0001.cr_crapdat(pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar dados
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      CLOSE BTCH0001.cr_crapdat;
      vr_dscritic := 'Data do sistema não encontrada. PR_CDCOOPER = '||pr_cdcooper;
      RAISE vr_exc_saida;
    END IF;
    CLOSE BTCH0001.cr_crapdat;


  --  IF rw_craplgp.cdagenci = 90 THEN
      vr_idorigem := 3; -- 3 - INTERNET BANK
  --  ELSE
  --    vr_idorigem := 2; -- 2 - CAIXA ONLINE
  --  END IF;

    vr_cdcompet := TRIM(TO_CHAR(gene0002.fn_mask(rw_craplgp.mmaacomp,'999999'))); -- Fica 092015

    -- Chamar a rotina para validação do pagamento
    INSS0002.pc_gps_pagamento(pr_cdcooper => pr_cdcooper             -- pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta             -- pr_nrdconta
                             ,pr_cdagenci => 90  --fixo, para aparecer LISGPS rw_craplgp.cdagenci     -- pr_cdagenci
                             ,pr_nrdcaixa => 900 --fixo, rw_craplgp.nrdcaixa     -- pr_nrdcaixa
                             ,pr_idseqttl => 1
                             ,pr_tpdpagto => rw_craplgp.tpdpagto     -- pr_tpdpagto
                             ,pr_idorigem => vr_idorigem              -- pr_idorigem
                             ,pr_cdoperad => rw_craplgp.cdopecxa     -- pr_cdoperad
                             ,pr_nmdatela => 'AYLLOS'                -- pr_nmdatela
                             ,pr_idleitur => rw_craplgp.tpleitur     -- pr_idleitur
                             ,pr_inproces => rw_crapdat.inproces     -- pr_inproces/batch
                             ,pr_cdbarras => rw_craplgp.cdbarras     -- pr_cdbarras
                             ,pr_sftcdbar => rw_craplgp.dslindig     -- pr_sftcdbar
                             ,pr_cdpagmto => rw_craplgp.cddpagto     -- pr_cdpagmto
                             ,pr_dtcompet => SUBSTR(vr_cdcompet,3,4) || SUBSTR(vr_cdcompet,1,2) -- pr_dtcompet => muda para ficar 201508
                             ,pr_dsidenti => rw_craplgp.cdidenti     -- pr_dsidenti
                             ,pr_vldoinss => rw_craplgp.vlrdinss     -- pr_vldoinss
                             ,pr_vloutent => rw_craplgp.vlrouent     -- pr_vloutent
                             ,pr_vlatmjur => rw_craplgp.vlrjuros     -- pr_vlatmjur
                             ,pr_vlrtotal => rw_craplgp.vlrtotal     -- pr_vlrtotal
                             ,pr_dtvencim => to_char(rw_craplgp.dtvencto,'DD/MM/YYYY') -- pr_dtvencim
                             ,pr_inpesgps => rw_craplgp.inpesgps     -- pr_inpesgps
                             ,pr_nrseqagp => pr_nrseqagp             -- Nr Seq. Agendamento
                             ,pr_dslitera => vr_dslitera
                             ,pr_cdultseq => vr_cdultseq
                             ,pr_dscritic => vr_dscritic );          -- pr_dscritic

    -- Se houver incidencia de erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => '1'
                        ,pr_dscritic => 'OK'
                        ,pr_dsorigem => 'AYLLOS'
                        ,pr_dstransa => 'Validar/Pagar GPS'
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> 1/1/SUCESSO/TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'AYLLOS'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Retornar a mensagem de critica
      pr_dscritic := vr_dscritic;
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => '1'
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => 'AYLLOS'
                          ,pr_dstransa => 'Validar/Pagar GPS'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> 0-FALSE/ERRO
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'AYLLOS'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);

    WHEN OTHERS THEN
      --Monta mensagem de critica
      pr_dscritic := 'Erro na INSS0002.pc_gps_validar_pagar --> '|| SQLERRM;
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => '1'
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => 'AYLLOS'
                          ,pr_dstransa => 'Validar/Pagar GPS'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> 0-FALSE/ERRO
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'AYLLOS'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
  END pc_gps_validar_pagar;


  /*---------------------------------------------------------------------------------------------------------------
   Autor    : Renato Darosci - Supero
   Objetivo : GPS - Validar os dados do pagamento
  ---------------------------------------------------------------------------------------------------------------*/
  PROCEDURE pc_gps_atualiza_pagto(pr_rowidlau   IN VARCHAR2
                                 ,pr_dtmvtolt   IN DATE
                                 ,pr_cdcritic  OUT NUMBER
                                 ,pr_dscritic  OUT VARCHAR2) IS

    -- Buscar dados da CRAPLAU conforme rowid
    CURSOR cr_craplau IS
      SELECT lau.cdcooper
           , lau.nrdconta
           , lau.nrseqagp
           , lau.dtmvtolt
           , lau.dtmvtopg
        FROM craplau lau
       WHERE lau.rowid = pr_rowidlau;
    rw_craplau    cr_craplau%ROWTYPE;

    -- Variáveis
    vr_dscritic VARCHAR2(500) := NULL;


  BEGIN

    BEGIN
      -- Busca registro na CRAPLAU
      OPEN  cr_craplau;
      FETCH cr_craplau INTO rw_craplau;
      CLOSE cr_craplau;

    EXCEPTION
      WHEN OTHERS THEN
        -- Setar mensagem de erro
        vr_dscritic := 'Registro de Lançamento não encontrado: '||SQLERRM;
        -- Excessão
        RAISE vr_exc_saida;
    END;

    -- Atualizar o registro da CRAPLGP
    BEGIN
      UPDATE craplgp
         SET craplgp.flgpagto = 1
       WHERE craplgp.cdcooper = rw_craplau.cdcooper
         AND craplgp.nrctapag = rw_craplau.nrdconta
         AND craplgp.nrseqagp = rw_craplau.nrseqagp
         AND craplgp.dtmvtolt = rw_craplau.dtmvtopg;
    EXCEPTION
      WHEN OTHERS THEN
        -- Setar mensagem de erro
        vr_dscritic := 'Erro ao atualizar GPS: '||SQLERRM;
        -- Excessão
        RAISE vr_exc_saida;
    END;

    -- Atualizar o registro da TBINSS_AGENDAMENTO_GPS
    BEGIN
      UPDATE tbinss_agendamento_gps t
         SET t.dtpagamento = pr_dtmvtolt
           , t.insituacao  = 2 -- Fixo 2 - Pagas
       WHERE t.cdcooper = rw_craplau.cdcooper
         AND t.nrdconta = rw_craplau.nrdconta
         AND t.nrseqagp = rw_craplau.nrseqagp;
    EXCEPTION
      WHEN OTHERS THEN
        -- Setar mensagem de erro
        vr_dscritic := 'Erro ao atualizar Agendamento: '||SQLERRM;
        -- Excessão
        RAISE vr_exc_saida;
    END;

    GENE0001.pc_gera_log(pr_cdcooper => rw_craplau.cdcooper
                        ,pr_cdoperad => '1'
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => 'AYLLOS'
                        ,pr_dstransa => 'Atualiza Agendamento'
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> 1/SUCESSO/TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'AYLLOS'
                        ,pr_nrdconta => rw_craplau.nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Retornar a mensagem de critica
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      --Monta mensagem de critica
      pr_dscritic := 'Erro na INSS0002.pc_gps_atualiza_pagto --> '|| SQLERRM;
  END pc_gps_atualiza_pagto;


  PROCEDURE pc_gps_arquivo_download(pr_cdcooper  IN NUMBER
                                   ,pr_dtpagmto  IN VARCHAR2
                                   ,pr_cdidenti  IN VARCHAR2
                                   ,pr_xmllog    IN VARCHAR2             --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

    /* .............................................................................
     Programa: pc_gps_arquivo_download
     Sistema : Rotinas acessadas pelas telas de cadastros Web
     Sigla   : INSS
     Autor   : Renato Darosci - Supero
     Data    : Setembro/2016.                  Ultima atualizacao: 30/09/2016

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Efetua o agrupamento e criação do ZIP com arquivos para DOWNLOAD
     Observacao: -----

     Alteracoes: 30/09/2016 - Alterada a forma de listar os arquivos da pasta
                              de pc_lista_arquivos para pc_OScommand_Shell
                              (Guilherme/SUPERO)

    ..............................................................................*/
    -- CURSORES
    -- Buscar as informações da cooperativa
    CURSOR cr_crapcop IS
      SELECT crapcop.dsdircop
        FROM crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop    cr_crapcop%ROWTYPE;

    -- Tipos
    TYPE vr_tab_delete IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;

    -- DATA DA LIBERAÇÃO
    vr_dtlibera       CONSTANT DATE := to_date('27/09/2016','DD/MM/YYYY');

    -- VARIÁVEIS
    vr_tbdelete       vr_tab_delete; -- Guarda o nome dos arquivos a serem excluídos
    vr_dtvalida       DATE;
    vr_dsdireto       VARCHAR2(250);
    vr_nmarqzip       VARCHAR2(50);
    vr_dsprocur       VARCHAR2(50);
    vr_list_arquivos  VARCHAR2(10000);
    vr_array_arquivo  gene0002.typ_split;
    vr_dscritic       VARCHAR2(1000);
    vr_comando        VARCHAR2(32767);
    vr_dscomora       VARCHAR2(1000);
    vr_dsdirbin       VARCHAR2(1000);
    vr_typ_saida      VARCHAR2(3);
    vr_des_reto       VARCHAR2(30);
    vr_nmarqcri       VARCHAR2(1000);
    vr_arquivos       VARCHAR2(32767);

    vr_cdcooper       NUMBER;
    vr_nmdatela       VARCHAR2(25);
    vr_nmeacao        VARCHAR2(25);
    vr_cdagenci       VARCHAR2(25);
    vr_nrdcaixa       VARCHAR2(25);
    vr_idorigem       VARCHAR2(25);
    vr_cdoperad       VARCHAR2(25);

    -- EXCEPTION
    vr_exc_saida      EXCEPTION;

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

    -- Criar cabecalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    -- Buscar pela cooperativa do Parametro
    OPEN  cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    -- Se não encontrar a cooperativa
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_crapcop;
      -- Retornar a mensagem de erro
      pr_des_erro := 'Cooperativa nao encontrada. PR_CDCOOPER = '||pr_cdcooper;
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapcop;

    -- Verificar se o identificador informado é diferente de zero, nulo ou branco
    IF NVL(TRIM(pr_cdidenti), 0) = 0 THEN
      -- Retornar a mensagem de erro
      pr_des_erro := 'Identificador deve ser informado.';
      RAISE vr_exc_saida;
    END IF;

    -- Verificar se a data está nula
    IF TRIM(pr_dtpagmto) IS NULL THEN
      -- Retornar a mensagem de erro
      pr_des_erro := 'Data deve ser informada.';
      RAISE vr_exc_saida;
    ELSE
      -- Verificar se a data é uma data valida
      BEGIN
        vr_dtvalida := to_date(pr_dtpagmto,'DD/MM/YYYY');
      EXCEPTION
        WHEN OTHERS THEN
          -- Retornar a mensagem de erro
          pr_des_erro := 'Data informada e inválida.';
          RAISE vr_exc_saida;
      END;
    END IF;

    -- Buscar as informações da CRAPDAT
    OPEN  BTCH0001.cr_crapdat(pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO BTCH0001.rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

    -- Verificar se a data passada por parametro é data futura
    IF vr_dtvalida > BTCH0001.rw_crapdat.dtmvtolt THEN
      -- Retornar a mensagem de erro
      pr_des_erro := 'Nao e permitido informar data futura.';
      RAISE vr_exc_saida;

    -- Verificar se a data passada por parâmetro é posterior a liberação da funcionalidade
    ELSIF vr_dtvalida < vr_dtlibera THEN
      -- Retornar a mensagem de erro
      pr_des_erro := 'Para esta data, deve ser solicitado backup para INFRA.';
      RAISE vr_exc_saida;

    -- Se a data for superior a dois meses (considerando de forma direta)
    ELSIF (to_number(to_char(BTCH0001.rw_crapdat.dtmvtolt,'MM')) - to_number(to_char(vr_dtvalida,'MM'))) >= 2 THEN
      -- Retornar a mensagem de erro
      pr_des_erro := 'Para esta data, deve ser solicitado backup para INFRA.';
      RAISE vr_exc_saida;

    -- Verificar se a data de consulta é o mês atual
    ELSIF (to_number(to_char(BTCH0001.rw_crapdat.dtmvtolt,'MM')) = to_number(to_char(vr_dtvalida,'MM'))) THEN
      -- Deve definir o diretório dis arquivos
      vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => 'salvar/gps');

     -- Se for do mês anterior
    ELSIF (to_number(to_char(BTCH0001.rw_crapdat.dtmvtolt,'MM')) - to_number(to_char(vr_dtvalida,'MM'))) = 1 THEN
      -- Deve definir como diretorio de acesso dos arquivos o diretório e backup
      vr_dsdireto := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_cdacesso => 'ROOT_WIN12')
                   ||rw_crapcop.dsdircop
                   ||'/salvar/gps';

    ELSE
      -- Retornar a mensagem de erro
      pr_des_erro := 'Erro ao validar a data informada.';
      RAISE vr_exc_saida;
    END IF;

    -- Montar o padrão do nome para a consulta dos arquivos
    vr_dsprocur := 'GPS.'||LPAD(pr_cdidenti,14,'0')||'.'||to_char(vr_dtvalida,'RRRRMMDD')||'.*.crypto';

    -- Retorna a lista dos arquivos do diretório, conforme máscara
/*    gene0001.pc_lista_arquivos(pr_path     => vr_dsdireto
                              ,pr_pesq     => vr_dsprocur
                              ,pr_listarq  => vr_list_arquivos
                              ,pr_des_erro => vr_dscritic);*/
    gene0001.pc_OScommand_Shell(pr_des_comando => 'ls '||vr_dsdireto || '/' || vr_dsprocur ||' 2> /dev/null'
                               ,pr_typ_saida   => vr_dscritic
                               ,pr_des_saida   => vr_list_arquivos);

    -- Se retornou erro na busca dos arquivos
    IF NVL(vr_dscritic, ' ') = 'ERR' THEN
      -- Retornar a mensagem de erro
      pr_des_erro := 'Erro ao buscar lista de arquivos: ' || vr_list_arquivos;
      RAISE vr_exc_saida;
    END IF;

    -- Se não retornou arquivos
    IF vr_list_arquivos IS NULL THEN
      -- Retornar a mensagem de erro
      pr_des_erro := 'Nenhum arquivo encontrado para os parametros informados.';
      RAISE vr_exc_saida;
    END IF;

    -- Listar os arquivos em uma tabela de memória
    vr_array_arquivo := gene0002.fn_quebra_string(pr_string  => vr_list_arquivos
                                                 ,pr_delimit => chr(10));

    -- Buscar o diretório do script shell
    vr_dscomora:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'SCRIPT_EXEC_SHELL');
    vr_dsdirbin:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'ROOT_CECRED_BIN');

    -- Percorrer todos os arquivos encontrados na pasta
    FOR ind IN vr_array_arquivo.FIRST..vr_array_arquivo.LAST LOOP
      /**** DESCRIPTOGRAFA O ARQUIVO ****/
      -- Comando para descriptografar arquivo
      vr_comando:= vr_dscomora || ' perl_remoto ' ||vr_dsdirbin||
                   'mqcecred_descriptografa.pl --descriptografa='||
                   chr(39)|| vr_array_arquivo(ind)||chr(39);

      -- Executar o comando no unix
      GENE0001.pc_OScommand (pr_typ_comando => 'S'
                            ,pr_des_comando => vr_comando
                            ,pr_typ_saida   => vr_typ_saida
                            ,pr_des_saida   => vr_nmarqcri);

      -- Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        pr_des_erro := 'Nao foi possivel executar comando unix: '||
                        vr_comando||' - '||vr_nmarqcri;

        -- retornando ao programa chamador
        RAISE vr_exc_saida;
      END IF;

      -- Retirar caracteres ENTER e LF do nome do arquivo
      vr_nmarqcri := REPLACE(REPLACE(vr_nmarqcri,chr(10),''),chr(13),'');

      -- Renomear o arquivo atribuindo a extensão XML
      GENE0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_nmarqcri||' '||REPLACE(vr_nmarqcri,'.crypto.dcrypt','.xml'));

      -- Atualizar o nome do arquivo armazenado na variável
      vr_nmarqcri := REPLACE(vr_nmarqcri,'.crypto.dcrypt','.xml');

      /* Obtem arquivo temporario descriptografado / com .dcrypt no fim */
      IF NOT gene0001.fn_exis_arquivo(pr_caminho => vr_nmarqcri) THEN
        -- Se Existir o arquivo original
        IF gene0001.fn_exis_arquivo(pr_caminho => vr_dsdireto||'/'||vr_array_arquivo(ind)) THEN
          pr_des_erro := 'Arquivo descriptografado nao encontrado. Arquivo: '||vr_array_arquivo(ind);

          -- retornando ao programa chamador
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Guarda o nome do arquivo na lista para formar o arquivo ZIP
      vr_arquivos := vr_arquivos||vr_nmarqcri||' ';

      -- Guarda o nome do arquivo na lista de arquivos que serão aparados ao fim do processamento
      vr_tbdelete(vr_tbdelete.count()+1) := vr_nmarqcri;
    END LOOP;

    -- Montar o nome do arquivo ZIP
    vr_nmarqzip := 'GPS.'||LPAD(pr_cdidenti,14,'0')||'.'||to_char(vr_dtvalida,'RRRRMMDD')||'.'||vr_cdoperad||'.zip';

    -- Compactar os arquivos
    GENE0002.pc_zipcecred(pr_cdcooper => pr_cdcooper
                         ,pr_tpfuncao => 'A'
                         ,pr_dsorigem => vr_arquivos
                         ,pr_dsdestin => vr_dsdireto||'/'||vr_nmarqzip
                         ,pr_dspasswd => NULL
                         ,pr_des_erro => vr_dscritic);

    -- verifica se houve erro
    IF vr_dscritic IS NOT NULL THEN
      pr_des_erro := 'Erro ao compactar arquivos: '||vr_dscritic;
      RAISE vr_exc_saida;
    END IF;

    -- Se há arquivos para excluir
    IF vr_tbdelete.COUNT() > 0 THEN
      -- Percorre todos os arquivos
      FOR ind IN vr_tbdelete.FIRST..vr_tbdelete.LAST LOOP
        -- Exclui o arquivo temporario
        GENE0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_tbdelete(ind));
      END LOOP;
    END IF;

    -- Efetuar a cópia do ZIP gerado para o diretório da internet
    GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_nmarqpdf => vr_dsdireto||'/'||vr_nmarqzip
                                ,pr_des_reto => vr_des_reto    --> Saída com erro
                                ,pr_tab_erro => vr_tab_erro);  --> tabela de erros

    -- caso apresente erro na operação
    IF NVL(vr_des_reto,'OK') <> 'OK' THEN
       IF vr_tab_erro.COUNT > 0 THEN
          pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          pr_des_erro := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

          RAISE vr_exc_saida;
       END IF;
    END IF;

    -- Exclui o arquivo ZIP
    GENE0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_dsdireto||'/'||vr_nmarqzip);

    -- Criar XML de retorno
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqzip>' || vr_nmarqzip || '</nmarqzip>');

  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_dscritic := pr_des_erro;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');

    WHEN OTHERS THEN
      pr_des_erro := 'Erro geral em PC_LISGPS[pc_gps_arquivo_download]: ' || SQLERRM;
      pr_dscritic := pr_des_erro;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>Rotina com erros</Erro></Root>');
  END pc_gps_arquivo_download;
  --
  /*---------------------------------------------------------------------------------------------------------------
   Autor    : Rafael Monteiro
   Objetivo : GPS - Efetuar pagamento de GPS apos aprovacao prepostos
  ---------------------------------------------------------------------------------------------------------------*/  
  PROCEDURE pc_gps_pgt_aprovado(pr_cdcooper      IN NUMBER
                               ,pr_nrdconta      IN NUMBER
                               ,pr_cdtransacao   IN NUMBER
                               ,pr_idagendamento IN NUMBER
                               ,pr_cdcritic1     OUT NUMBER  --> Código da crítica
                               ,pr_dscritic1     OUT VARCHAR2) IS
                               
    CURSOR C1 (pr_cdcooper     IN NUMBER
              ,pr_nrdconta     IN NUMBER
              ,prc_cdtransacao IN tbgen_trans_pend.cdtransacao_pendente%type)IS
      SELECT lgm.rowid
        FROM craplgi lgi,      
             craplgm lgm
       WHERE lgi.nmdcampo LIKE 'gpscdtransacao_pendente' -- BUSCAR SOMENTE DESTE VALOR
         AND lgi.dsdadatu = pr_cdtransacao -- Busca registros da transacao
         AND lgm.cdcooper = pr_cdcooper
         AND lgm.nrdconta = pr_nrdconta
         AND lgm.dttransa > SYSDATE - 30
         AND lgi.cdcooper = lgm.cdcooper
         AND lgi.nrdconta = lgm.nrdconta
         AND lgi.idseqttl = lgm.idseqttl
         AND lgi.dttransa = lgm.dttransa
         AND lgi.hrtransa = lgm.hrtransa
         AND lgi.nrsequen = lgm.nrsequen;
    --     
    CURSOR C2 (prc_rowid in ROWID)IS
      SELECT lgi.nmdcampo,
             lgi.dsdadatu
        FROM craplgi lgi,
             craplgm lgm
       WHERE lgm.rowid    = prc_rowid
         AND lgi.cdcooper = lgm.cdcooper
         AND lgi.nrdconta = lgm.nrdconta
         AND lgi.idseqttl = lgm.idseqttl
         AND lgi.dttransa = lgm.dttransa
         AND lgi.hrtransa = lgm.hrtransa
         AND lgi.nrsequen = lgm.nrsequen;    
  -- VARIAVEIS
  
  vr_rowid ROWID;
  
  vr_cdcooper NUMBER;
  vr_nrdconta NUMBER;
  vr_tpdpagto NUMBER;
  vr_idseqttl NUMBER;
  vr_idleitur NUMBER;
  vr_cdbarras VARCHAR2(1000);
  vr_sftcdbar VARCHAR2(1000);
  vr_cdpagmto NUMBER;
  vr_dtcompet VARCHAR2(200);
  vr_dsidenti VARCHAR2(200);
  vr_vldoinss NUMBER;
  vr_vloutent NUMBER;
  vr_vlatmjur NUMBER;
  vr_vlrtotal NUMBER;
  vr_dtvencim VARCHAR2(200);
  vr_inpesgps NUMBER;
  vr_nrseqagp NUMBER;  
  vr_dtdebito VARCHAR2(200);
  vr_cdlindig VARCHAR2(200);
  vr_nrcpfope NUMBER;
  
  pr_dslitera  VARCHAR2(5000);
  pr_cdultseq  NUMBER;
  pr_dscritic  VARCHAR2(1000);
  BEGIN
    pr_dscritic1 := NULL;
    BEGIN
      FOR R1 IN C1(pr_cdcooper
                  ,pr_nrdconta
                  ,pr_cdtransacao) LOOP
        
        vr_rowid := R1.ROWID;
     
        FOR R2 IN C2(R1.ROWID) LOOP
          IF 'pr_cdcooper' = r2.nmdcampo THEN
            vr_cdcooper := TO_NUMBER(r2.dsdadatu);
          ELSIF 'pr_nrdconta' = r2.nmdcampo THEN
            vr_nrdconta := TO_NUMBER(r2.dsdadatu);
          ELSIF 'pr_tpdpagto' = r2.nmdcampo THEN 
            vr_tpdpagto := TO_NUMBER(r2.dsdadatu);
          ELSIF 'pr_idseqttl'  = r2.nmdcampo THEN
            vr_idseqttl := TO_NUMBER(r2.dsdadatu);
          ELSIF 'pr_idleitur' = r2.nmdcampo THEN
            vr_idleitur := TO_NUMBER(r2.dsdadatu);
          ELSIF 'vr_cdbarras' = r2.nmdcampo THEN
            vr_cdbarras := r2.dsdadatu;
          ELSIF 'pr_sftcdbar' = r2.nmdcampo THEN
            vr_sftcdbar := r2.dsdadatu;
          ELSIF 'pr_cdpagmto' = r2.nmdcampo THEN
            vr_cdpagmto := TO_NUMBER(r2.dsdadatu);
          ELSIF 'pr_dtcompet' = r2.nmdcampo THEN
            vr_dtcompet := r2.dsdadatu;
          ELSIF 'pr_dsidenti' = r2.nmdcampo THEN
            vr_dsidenti := r2.dsdadatu;
          ELSIF 'pr_vldoinss' = r2.nmdcampo THEN
            vr_vldoinss := TO_NUMBER(r2.dsdadatu);
          ELSIF 'pr_vloutent' = r2.nmdcampo THEN
            vr_vloutent := TO_NUMBER(r2.dsdadatu);
          ELSIF 'pr_vlatmjur' = r2.nmdcampo THEN
            vr_vlatmjur := TO_NUMBER(r2.dsdadatu);
          ELSIF 'pr_vlrtotal' = r2.nmdcampo THEN
            vr_vlrtotal := TO_NUMBER(r2.dsdadatu);
          ELSIF 'pr_dtvencim' = r2.nmdcampo THEN
            vr_dtvencim := r2.dsdadatu;
          ELSIF 'pr_inpesgps' = r2.nmdcampo THEN                        
            vr_inpesgps := TO_NUMBER(r2.dsdadatu);
          ELSIF 'pr_nrseqagp' = r2.nmdcampo THEN                        
            vr_nrseqagp := TO_NUMBER(r2.dsdadatu);
          ELSIF 'pr_dtdebito' = r2.nmdcampo THEN  
            vr_dtdebito := r2.dsdadatu;
          ELSIF 'pr_cdlindig' = r2.nmdcampo THEN
            vr_cdlindig := r2.dsdadatu;
          ELSIF 'pr_nrcpfope' = r2.nmdcampo THEN
            vr_nrcpfope := TO_NUMBER(r2.dsdadatu);
          END IF;
        END LOOP;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic1 := 'Erro for INSS0002: ' ||SQLERRM;
    END;
    
    IF pr_idagendamento = 1 THEN -- PAGAR
      INSS0002.pc_gps_pagamento(pr_cdcooper => vr_cdcooper, 
                                pr_nrdconta => vr_nrdconta, 
                                pr_cdagenci => 90 , 
                                pr_nrdcaixa => 900, 
                                pr_idseqttl => vr_idseqttl,
                                pr_tpdpagto => vr_tpdpagto, 
                                pr_idorigem => 3, 
                                pr_cdoperad => '996', 
                                pr_nmdatela => 'APROVADO', -- para nao validar os limities
                                pr_idleitur => vr_idleitur, 
                                pr_inproces => 1, 
                                pr_cdbarras => vr_cdbarras, 
                                pr_sftcdbar => vr_sftcdbar, 
                                pr_cdpagmto => vr_cdpagmto, 
                                pr_dtcompet => vr_dtcompet, 
                                pr_dsidenti => vr_dsidenti, 
                                pr_vldoinss => vr_vldoinss, 
                                pr_vloutent => vr_vloutent, 
                                pr_vlatmjur => vr_vlatmjur, 
                                pr_vlrtotal => vr_vlrtotal, 
                                pr_dtvencim => vr_dtvencim, 
                                pr_inpesgps => vr_inpesgps, 
                                pr_nrseqagp => 0, 
                                pr_nrcpfope => vr_nrcpfope,
                                pr_dslitera => pr_dslitera, 
                                pr_cdultseq => pr_cdcritic1, 
                                pr_dscritic => pr_dscritic1);
    IF NVL(pr_cdcritic1, 0) > 0 OR pr_dscritic1 IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    ELSIF pr_idagendamento = 2 THEN -- AGENDAMENTO
      INSS0002.pc_gps_agmto_novo(pr_cdcooper => vr_cdcooper, 
                                 pr_nrdconta => vr_nrdconta, 
                                 pr_tpdpagto => vr_tpdpagto, 
                                 pr_cdagenci => 90, 
                                 pr_nrdcaixa => 900, 
                                 pr_idseqttl => vr_idseqttl, 
                                 pr_idorigem => 3, 
                                 pr_cdoperad => '996', 
                                 pr_nmdatela => 'APROVADO', -- para nao validar os limites
                                 pr_idleitur => vr_idleitur, 
                                 pr_cdbarras => vr_cdbarras, 
                                 pr_cdlindig => vr_cdlindig, 
                                 pr_cdpagmto => vr_cdpagmto, 
                                 pr_dtcompet => vr_dtcompet, 
                                 pr_dsidenti => vr_dsidenti, 
                                 pr_vldoinss => vr_vldoinss, 
                                 pr_vloutent => vr_vloutent, 
                                 pr_vlatmjur => vr_vlatmjur, 
                                 pr_vlrtotal => vr_vlrtotal, 
                                 pr_dtvencim => vr_dtvencim, 
                                 pr_inpesgps => vr_inpesgps, 
                                 pr_dtdebito => vr_dtdebito, 
                                 pr_nrcpfope => vr_nrcpfope,
                                 pr_dslitera => pr_dslitera, 
                                 pr_cdultseq => pr_cdcritic1, 
                                 pr_dscritic => pr_dscritic1);
                                 
      IF NVL(pr_cdcritic1, 0) > 0 OR pr_dscritic1 IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;                                 
    END IF; 
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid
                             ,pr_nmdcampo => 'Data Aprovacao'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => trunc(sysdate));   

    gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid
                             ,pr_nmdcampo => 'Id util agend'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => pr_idagendamento);                             
  
  EXCEPTION
    WHEN vr_exc_saida THEN
       NULL;

    WHEN OTHERS THEN

      --Monta mensagem de critica
      pr_cdcritic1 := 0;
      pr_dscritic1 := 'Erro na INSS0002.pc_gps_pgt_aprovado --> ' || SQLERRM;  
  
  END pc_gps_pgt_aprovado;  
END INSS0002;
/
