/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------+-------------------------------------+
  | Rotina Progress                    | Rotina Oracle PLSQL                 |
  +------------------------------------+-------------------------------------+
  | procedures/b1wgen0079.p	           | DDDA0001	                         |
  |  atualizar-situacao-titulo-sacado  |   pc_atualz_situac_titulo_sacado    |
  |  obtem-dados-legado                |   pc_obtem_dados_legado             |
  |  requisicao-atualizar-situacao     |   pc_requis_atualizar_situacao      |
  |  retorna-linha-log                 |   pc_grava_linha_log                |
  |  baixa-operacional                 |   pc_exec_baixa_operacional         |
  |  gera-cabecalho-soap               |   pc_gera_cabecalho_soap            |
  |  cria-tag                          |   pc_cria_tag                       |
  |  efetua-requisicao-soap            |   pc_efetua_requisicao_soap         |
  |  obtem-fault-packet                |   pc_obtem_fault_packet             |
  |  elimina-arquivos-requisicao       |   pc_elimina_arquivos_requisicao    |
  +------------------------------------+-------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/












/*.............................................................................

    Programa  : sistema/generico/procedures/b1wgen0079.p
    Autor     : David
    Data      : Dezembro/2010                Ultima Atualizacao: 01/08/2017
    
    Dados referentes ao programa:

    Objetivo  : BO para comunicacao com o aplicativo JDDDA.
                Regras para o servico DDA (Debito Direto Autorizado).

    Alteracoes: 
    
    26/11/2011 - Adicionado campo em tt-titulos-sacado-dda.vlliquid para 
                 valor do titulo - abatimento e desconto.(Jorge)
                 
    03/02/2012 - Adicionado campos em tt-titulos-sacado-dda: vldsccal, 
                 vljurcal, vlmulcal e vltotcob (Jorge).
               - Criado procedure baixa-operacional. (Jorge)
    
    27/02/2012 - Setar flag de titulo vencido pela data limite 
                 de pagamento. (Rafael)
               
    06/03/2012 - Incluido rotina para desconsiderar juros/multa quando vencto
                 na praca do sacado for feriado. (Rafael)
                 
    12/03/2012 - Repassado parametro de data limite de pagamento para a 
                 tt-titulos-sacado-dda. (Jorge)
                 
    20/03/2012 - Ajustes na rotina de baixa-operacional. (Rafael)
    
    13/04/2012 - Ajustes na procedure atualizar-situacao-titulo-sacado. 
                 Estava provocando erro ao agendar titulos DDA. (Rafael)
                 
    19/04/2012 - Verificar se data limite de pagto nao eh feriado. (Rafael)
    
    03/08/2012 - Ajuste na informação de baixa operacional devido a aplicacao
                 do catalogo Bacen 3.06. (Rafael)
                 
    12/11/2012 - Ajuste em proc. carrega-dados-titulo quando campo for
                 RepetDesctTit, adicionado condicional "or". (Jorge)
                 
    03/01/2013 - Ajustes em campo "RepetDesctTit" da procedure 
                 carrega-dados-titulo (Jorge)
                 
    02/05/2013 - Ajuste em proc. carrega-dados-titulo, adicionado replace de
                 campos com nomes, retirando "," ";" e "#". (Jorge)             
    
    07/11/2013 - Ajuste em proc. carrega-dados-titulo, adicionado replace de
                 campos com nomes, retirando "'" (Jorge)
    
    12/11/2013 - Nova forma de chamar as agências, de PAC agora 
                 a escrita será PA (Guilherme Gielow)
             
    01/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                 Cedente por Beneficiário e  Sacado por Pagador 
                 Chamado 229313 (Jean Reddiga - RKAM).    
                           
    29/12/2016 - Tratamento Nova Plataforma de cobrança PRJ340 - NPC (Odirlei-AMcom)                         

    20/07/2017 - Ajuste para remover caracteres especiais na listar titulo sacado
                 PRJ340 - NPC (Odirlei-AMcom)      
                   									
    01/08/2017 - Substituir caracter "." por "," na conversao de valores, devido
                 ao ajuste realizado no retorno do XML da cabine JDNPC (Rafael).

    06/09/2017 - Removido tag JDNPCSitTitulo por orientação da JD. (Rafael)


    25/10/2017 - Ajuste para criar arquivo de chamada web com chaves para tratamento
                 de concorrência.
                 PRJ356.4 - DDA (Ricardo Linhares)  
                           
    04/04/2018 - Adicionada chamada pc_valida_adesao_produto para verificar se o 
                 tipo de conta permite a contrataçao do produto. PRJ366 (Lombardi).
.............................................................................*/


/*................................ DEFINICOES ...............................*/


{ sistema/generico/includes/b1wgen0079tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF TEMP-TABLE bb-instr-tit-sacado-dda  NO-UNDO LIKE tt-instr-tit-sacado-dda.
DEF TEMP-TABLE bb-descto-tit-sacado-dda NO-UNDO LIKE tt-descto-tit-sacado-dda.

DEF VAR i             AS INTE                                         NO-UNDO.
DEF VAR j             AS INTE                                         NO-UNDO.
DEF VAR k             AS INTE                                         NO-UNDO.
DEF VAR l             AS INTE                                         NO-UNDO.
                                                                   
DEF VAR aux_cdcritic  AS INTE                                         NO-UNDO.
DEF VAR aux_nrorditm  AS INTE                                         NO-UNDO.
DEF VAR aux_qtdiapro  AS INTE                                         NO-UNDO.
DEF VAR aux_cdsittit  AS INTE                                         NO-UNDO.
DEF VAR aux_cdbccced  AS INTE                                         NO-UNDO.
DEF VAR aux_tpdocsav  AS INTE                                         NO-UNDO.

DEF VAR aux_dscritic  AS CHAR                                         NO-UNDO.
DEF VAR aux_dsorigem  AS CHAR                                         NO-UNDO.
DEF VAR aux_dstransa  AS CHAR                                         NO-UNDO.
DEF VAR aux_dsreturn  AS CHAR                                         NO-UNDO.
DEF VAR aux_nmrescop  AS CHAR                                         NO-UNDO.
DEF VAR aux_cdlegado  AS CHAR                                         NO-UNDO.
DEF VAR aux_nrispbif  AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarqlog  AS CHAR                                         NO-UNDO.
DEF VAR aux_msgenvio  AS CHAR                                         NO-UNDO.
DEF VAR aux_msgreceb  AS CHAR                                         NO-UNDO.
DEF VAR aux_cdderror  AS CHAR                                         NO-UNDO.
DEF VAR aux_dsderror  AS CHAR                                         NO-UNDO.
DEF VAR aux_nmdsacad  AS CHAR                                         NO-UNDO.
DEF VAR aux_tppessac  AS CHAR                                         NO-UNDO.
DEF VAR aux_nmcedent  AS CHAR                                         NO-UNDO.
DEF VAR aux_tppesced  AS CHAR                                         NO-UNDO.
DEF VAR aux_nrdocmto  AS CHAR                                         NO-UNDO.
DEF VAR aux_cddmoeda  AS CHAR                                         NO-UNDO.
DEF VAR aux_nossonum  AS CHAR                                         NO-UNDO.
DEF VAR aux_cdtpmora  AS CHAR                                         NO-UNDO.
DEF VAR aux_cdtpmult  AS CHAR                                         NO-UNDO.
DEF VAR aux_nmsacava  AS CHAR                                         NO-UNDO.
DEF VAR aux_dscodbar  AS CHAR                                         NO-UNDO.
DEF VAR aux_dstpdesc  AS CHAR EXTENT 7                                NO-UNDO.
DEF VAR aux_dsdmoeda  AS CHAR EXTENT 14                               NO-UNDO.
DEF VAR aux_cdcartei  AS CHAR                                         NO-UNDO.
DEF VAR aux_idtitneg  AS CHAR                                         NO-UNDO.

DEF VAR aux_idtitdda  AS DECI                                         NO-UNDO.
DEF VAR aux_nrdocsac  AS DECI                                         NO-UNDO.
DEF VAR aux_nrdocced  AS DECI                                         NO-UNDO.
DEF VAR aux_vltitulo  AS DECI                                         NO-UNDO.
DEF VAR aux_vlrabati  AS DECI                                         NO-UNDO.
DEF VAR aux_vlrdmora  AS DECI                                         NO-UNDO.
DEF VAR aux_vlrmulta  AS DECI                                         NO-UNDO.
DEF VAR aux_nrdocsav  AS DECI                                         NO-UNDO.
DEF VAR aux_vldsccal  AS DECI                                         NO-UNDO.
DEF VAR aux_vljurcal  AS DECI                                         NO-UNDO.
DEF VAR aux_vlmulcal  AS DECI                                         NO-UNDO.
DEF VAR aux_vltotcob  AS DECI                                         NO-UNDO.

DEF VAR aux_nmcidsac  AS CHAR                                         NO-UNDO.
DEF VAR aux_cdufssac  AS CHAR                                         NO-UNDO.
                   
DEF VAR aux_dtvencto  AS DATE                                         NO-UNDO.
DEF VAR aux_dtlimpgt  AS DATE                                         NO-UNDO.
DEF VAR aux_dtemissa  AS DATE                                         NO-UNDO.
DEF VAR aux_dtdamora  AS DATE                                         NO-UNDO.
DEF VAR aux_dtdmulta  AS DATE                                         NO-UNDO.
                   
DEF VAR aux_xmlresul  AS MEMPTR                                       NO-UNDO.
                   
DEF VAR aux_nrdrowid  AS ROWID                                        NO-UNDO.

/** Objetos Resposta XML **/
DEF VAR hXmlDoc       AS HANDLE                                       NO-UNDO.
DEF VAR hXmlRoot      AS HANDLE                                       NO-UNDO.
DEF VAR hXmlNode1     AS HANDLE                                       NO-UNDO.
DEF VAR hXmlNode2     AS HANDLE                                       NO-UNDO.
DEF VAR hXmlNode3     AS HANDLE                                       NO-UNDO.
DEF VAR hXmlNode4     AS HANDLE                                       NO-UNDO.
DEF VAR hXmlTag       AS HANDLE                                       NO-UNDO.
DEF VAR hXmlTagTemp   AS HANDLE                                       NO-UNDO.
DEF VAR hXmlText      AS HANDLE                                       NO-UNDO.
                                                                      
/** Objetos Mensagem XML-SOAP **/
DEF VAR hXmlSoap      AS HANDLE                                       NO-UNDO.
DEF VAR hXmlEnvelope  AS HANDLE                                       NO-UNDO.
DEF VAR hXmlHeader    AS HANDLE                                       NO-UNDO.
DEF VAR hXmlBody      AS HANDLE                                       NO-UNDO.
DEF VAR hXmlAutentic  AS HANDLE                                       NO-UNDO.
DEF VAR hXmlMetodo    AS HANDLE                                       NO-UNDO.
DEF VAR hXmlRootSoap  AS HANDLE                                       NO-UNDO.
DEF VAR hXmlNode1Soap AS HANDLE                                       NO-UNDO.
DEF VAR hXmlNode2Soap AS HANDLE                                       NO-UNDO.
DEF VAR hXmlTagSoap   AS HANDLE                                       NO-UNDO.
DEF VAR hXmlTextSoap  AS HANDLE                                       NO-UNDO.

ASSIGN aux_dstpdesc[1] = "VALOR FIXO ATE A DATA INFORMADA"
       aux_dstpdesc[2] = "PERCENTUAL ATE A DATA INFORMADA"
       aux_dstpdesc[3] = "VALOR POR ANTECIPACAO DIA CORRIDO"
       aux_dstpdesc[4] = "VALOR POR ANTECIPACAO DIA UTIL"
       aux_dstpdesc[5] = "PERCENTUAL POR ANTECIPACAO DIA CORRIDO"
       aux_dstpdesc[6] = "PERCENTUAL POR ANTECIPACAO DIA UTIL"
       aux_dstpdesc[7] = "CANCELAMENTO DE DESCONTO".

ASSIGN aux_dsdmoeda[1]  = "RESERVADO PARA USO FUTURO"
       aux_dsdmoeda[2]  = "DOLAR AMERICANO COMERCIAL (VENDA)"
       aux_dsdmoeda[3]  = "DOLAR AMERICANO TURISMO (VENDA)"
       aux_dsdmoeda[4]  = "ITRD"
       aux_dsdmoeda[5]  = "IDTR"
       aux_dsdmoeda[6]  = "UFIR DIARIA"
       aux_dsdmoeda[7]  = "UFIR MENSAL"
       aux_dsdmoeda[8]  = "FAJ-TR"
       aux_dsdmoeda[9]  = "REAL"
       aux_dsdmoeda[10] = "TR"
       aux_dsdmoeda[11] = "IGPM"
       aux_dsdmoeda[12] = "CDI"
       aux_dsdmoeda[13] = "PERCENTUAL DO CDI"
       aux_dsdmoeda[14] = "EURO".


/*................................. FUNCTIONS ...............................*/

FUNCTION GetSalt RETURNS RAW ():
    SECURITY-POLICY:SYMMETRIC-ENCRYPTION-ALGORITHM = "AES_CBC_256".
    RETURN GENERATE-RANDOM-KEY.
END FUNCTION.

FUNCTION gerar-chave RETURNS CHARACTER():

  DEFINE VARIABLE rSalt AS RAW NO-UNDO.
  DEFINE VARIABLE cSalt AS CHARACTER NO-UNDO.

  cSalt = STRING(HEX-ENCODE(GetSalt())).

  RETURN cSalt.

END.

FUNCTION cria-tag RETURNS LOGICAL (INPUT par_dsnomtag AS CHAR,
                                   INPUT par_dsvaltag AS CHAR,
                                   INPUT par_dstpdado AS CHAR,
                                   INPUT par_handnode AS HANDLE):

    hXmlSoap:CREATE-NODE(hXmlTagSoap,par_dsnomtag,"ELEMENT").
    hXmlTagSoap:SET-ATTRIBUTE("xsi:type","xsd:" + par_dstpdado).
    par_handnode:APPEND-CHILD(hXmlTagSoap).

    hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
    hXmlTagSoap:APPEND-CHILD(hXmlTextSoap).
    hXmlTextSoap:NODE-VALUE = par_dsvaltag.

    RETURN TRUE.            

END FUNCTION.

FUNCTION retorna-linha-log RETURNS LOGICAL (INPUT par_cdcooper AS INTE,
                                            INPUT par_nrdconta AS INTE,
                                            INPUT par_nmmetodo AS CHAR,
                                            INPUT par_cdderror AS CHAR,
                                            INPUT par_dsderror AS CHAR):

    DEF VAR aux_nmprimtl AS CHAR                                    NO-UNDO.
    DEF VAR aux_dscpfcgc AS CHAR                                    NO-UNDO.

    IF  aux_nmarqlog = ""  THEN
        RETURN TRUE.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF  AVAILABLE crapass  THEN
        DO:
            ASSIGN aux_nmprimtl = crapass.nmprimtl.

            IF  crapass.inpessoa = 1  THEN
                ASSIGN aux_dscpfcgc = STRING(STRING(crapass.nrcpfcgc,
                                             "99999999999"),
                                             "    xxx.xxx.xxx-xx").
            ELSE
                ASSIGN aux_dscpfcgc = STRING(STRING(crapass.nrcpfcgc,
                                             "99999999999999"),
                                             "xx.xxx.xxx/xxxx-xx").
        END.
    ELSE
        ASSIGN aux_nmprimtl = ""
               aux_dscpfcgc = "".
    
    UNIX SILENT VALUE('echo "' + (STRING(aux_datdodia,"99/99/9999") + " " +
                                  STRING(TIME,"HH:MM:SS")  + " --> " +
                                  STRING(par_nrdconta,"9999,999,9") + " | " +
                                  STRING(aux_nmprimtl,"x(50)") + " | " +
                                  STRING(aux_dscpfcgc,"x(18)") + " | " +
                                  STRING(par_nmmetodo,"x(40)") + " | " +
                                  STRING(par_cdderror,"x(30)") + " | " +
                                  par_dsderror) + '" >> ' + aux_nmarqlog).

    RETURN TRUE.

END FUNCTION.


/*............................ PROCEDURES EXTERNAS ..........................*/


/*****************************************************************************/
/**      Procedure para consultar lista de titulos do sacado eletronico     **/
/*****************************************************************************/
PROCEDURE lista-titulos-sacado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagecxa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdopecxa AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvenini AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvenfin AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nritmini AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nritmfin AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsittit AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idordena AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qttitulo AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-titulos-sacado-dda.
    DEF OUTPUT PARAM TABLE FOR tt-instr-tit-sacado-dda.
    DEF OUTPUT PARAM TABLE FOR tt-descto-tit-sacado-dda.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrcpfcgc AS DECI                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-titulos-sacado-dda.
    EMPTY TEMP-TABLE tt-instr-tit-sacado-dda.  
    EMPTY TEMP-TABLE tt-descto-tit-sacado-dda. 
    EMPTY TEMP-TABLE tt-erro.
    
    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "DDA - Listar Titulos do Pagador".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdderror = ""
           aux_dsderror = ""
           aux_dsreturn = "NOK".
           
    DO WHILE TRUE:

        RUN obtem-dados-legado (INPUT par_cdcooper,
                                INPUT par_nrdconta,
                                INPUT par_idseqttl,
                                INPUT par_cdagecxa,
                                INPUT par_nrdcaixa).
    
        IF  RETURN-VALUE = "NOK"  THEN
            LEAVE.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 9.
                LEAVE.
            END.

        IF  crapass.inpessoa = 1  THEN
            DO:
                FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                   crapttl.nrdconta = par_nrdconta AND
                                   crapttl.idseqttl = par_idseqttl NO-LOCK NO-ERROR.
        
                IF  NOT AVAILABLE crapttl  THEN
                    DO:
                        ASSIGN aux_dscritic = "Titular nao cadastrado.".
                        LEAVE.
                    END.

                ASSIGN aux_nrcpfcgc = crapttl.nrcpfcgc.
            END.
        ELSE
            ASSIGN aux_nrcpfcgc = crapass.nrcpfcgc.
        
        IF  par_dtvenini <> ?             AND
            par_dtvenfin <> ?             AND 
            par_dtvenini > par_dtvenfin  THEN
            DO:
                ASSIGN aux_dscritic = "Periodo de consulta invalido.".
                LEAVE.
            END.

        IF  par_nritmini <= 0             OR
            par_nritmfin <= 0             OR 
            par_nritmini > par_nritmfin   THEN
            DO:
                ASSIGN aux_dscritic = "Sequencia de consulta invalida.".
                LEAVE.
            END.

        IF  par_cdsittit < 0   OR
            par_cdsittit > 16  THEN
            DO:
                ASSIGN aux_dscritic = "Situacao invalida.".
                LEAVE.
            END.

        IF  par_idordena < 1  OR
            par_idordena > 4  THEN
            DO:
                ASSIGN aux_dscritic = "Tipo de ordenacao invalida.".
                LEAVE.
            END.
        
        RUN requisicao-lista-titulos (INPUT par_cdcooper,
                                      INPUT par_cdagecxa,
                                      INPUT par_nrdcaixa,
                                      INPUT par_nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT aux_nrcpfcgc,
                                      INPUT crapass.inpessoa,
                                      INPUT par_dtvenini,
                                      INPUT par_dtvenfin,
                                      INPUT par_nritmini,
                                      INPUT par_nritmfin,
                                      INPUT par_cdsittit,
                                      INPUT par_idordena,
                                     OUTPUT par_qttitulo).

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  aux_dsreturn = "NOK"  THEN
        DO: 
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Falha na requisicao DDA. Comunique " +
                                      "seu PA.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagecxa,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            retorna-linha-log (INPUT par_cdcooper,
                               INPUT par_nrdconta,
                               INPUT "ListarTitulos",
                               INPUT (IF  aux_cdderror <> ""  THEN
                                          aux_cdderror
                                      ELSE
                                          STRING(aux_cdcritic)),
                               INPUT (IF  aux_dsderror <> ""  THEN
                                          aux_dsderror
                                      ELSE
                                          aux_dscritic)).
        END.

    IF  par_flgerlog  THEN 
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdopecxa,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT IF aux_dsreturn = "OK" 
                                  THEN TRUE ELSE FALSE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

    RETURN aux_dsreturn.

END PROCEDURE.


/*****************************************************************************/
/**     Procedure para atualizar situacao do titulo do Pagador eletronico    **/
/*****************************************************************************/
PROCEDURE atualizar-situacao-titulo-sacado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagecxa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdopecxa AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idtitdda AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdsittit AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "DDA - Atualizar Situacao do Titulo do Pagador".
   
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdderror = ""
           aux_dsderror = "".

    DO WHILE TRUE:

        ASSIGN aux_dsreturn = "NOK".

        RUN obtem-dados-legado (INPUT par_cdcooper,
                                INPUT par_nrdconta,
                                INPUT par_idseqttl,
                                INPUT par_cdagecxa,
                                INPUT par_nrdcaixa).

        ASSIGN aux_dsreturn = RETURN-VALUE.
    
        IF  RETURN-VALUE = "NOK"  THEN
            LEAVE.

        IF  par_cdsittit < 1  OR
            par_cdsittit > 4  THEN
            DO:
                ASSIGN aux_dscritic = "Situacao do titulo invalida.".
                LEAVE.
            END.

        RUN requisicao-atualizar-situacao (INPUT par_idtitdda,
                                           INPUT par_cdsittit).

        ASSIGN aux_dsreturn = RETURN-VALUE.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  aux_dsreturn = "NOK"  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Falha na requisicao DDA. Comunique " 
                                      + "seu PA.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagecxa,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            retorna-linha-log (INPUT par_cdcooper,
                               INPUT par_nrdconta,
                               INPUT "AtualizarSituacao",
                               INPUT (IF  aux_cdderror <> ""  THEN
                                          aux_cdderror
                                      ELSE
                                          STRING(aux_cdcritic)),
                               INPUT (IF  aux_dsderror <> ""  THEN
                                          aux_dsderror
                                      ELSE
                                          aux_dscritic)).

            RETURN "NOK".
        END.

    IF  par_flgerlog  THEN 
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdopecxa,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT IF  aux_dsreturn = "OK"  THEN 
                                      TRUE 
                                  ELSE 
                                      FALSE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).


      ASSIGN aux_cdcritic = 0
             aux_dscritic = ""
             aux_cdderror = ""
             aux_dsderror = "".

      /* se título pago, realizar baixa operacional */
      IF par_cdsittit = 3 OR 
         par_cdsittit = 4 THEN 
      DO:
          ASSIGN aux_dsreturn = "NOK".

          DO WHILE TRUE:

              RUN obtem-dados-legado (INPUT par_cdcooper,
                                      INPUT par_nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT par_cdagecxa,
                                      INPUT par_nrdcaixa).

              ASSIGN aux_dsreturn = RETURN-VALUE.

              IF  RETURN-VALUE = "NOK"  THEN
                  LEAVE.

              IF  par_cdsittit < 1  OR
                  par_cdsittit > 4  THEN
                  DO:
                      ASSIGN aux_dscritic = "Situacao do titulo invalida.".
                      LEAVE.
                  END.

              RUN baixa-operacional (INPUT par_idtitdda).

              ASSIGN aux_dsreturn = RETURN-VALUE.

              LEAVE.

          END. /** Fim do DO WHILE TRUE **/

          IF  aux_dsreturn = "NOK"  THEN
              DO:
                  IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                      ASSIGN aux_dscritic = "Falha na requisicao DDA. Comunique " 
                                            + "seu PA.".

                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagecxa,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).

                  retorna-linha-log (INPUT par_cdcooper,
                                     INPUT par_nrdconta,
                                     INPUT "BaixaOperacional",
                                     INPUT (IF  aux_cdderror <> ""  THEN
                                                aux_cdderror
                                            ELSE
                                                STRING(aux_cdcritic)),
                                     INPUT (IF  aux_dsderror <> ""  THEN
                                                aux_dsderror
                                            ELSE
                                                aux_dscritic)).
              END.

          IF  par_flgerlog  THEN 
              RUN proc_gerar_log (INPUT par_cdcooper,
                                  INPUT par_cdopecxa,
                                  INPUT aux_dscritic,
                                  INPUT aux_dsorigem,
                                  INPUT aux_dstransa,
                                  INPUT IF  aux_dsreturn = "OK"  THEN 
                                            TRUE 
                                        ELSE 
                                            FALSE,
                                  INPUT par_idseqttl,
                                  INPUT par_nmdatela,
                                  INPUT par_nrdconta,
                                 OUTPUT aux_nrdrowid).

          IF  aux_dsreturn = "NOK" THEN 
              RETURN "NOK".

      END. /* fim - se título pago */


    RETURN aux_dsreturn.

END PROCEDURE.


/*****************************************************************************
 Realizar a requisicao de inclusao do Pagador eletronico
****************************************************************************/
PROCEDURE requisicao-incluir-sacado:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagecxa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR         aux_tppessoa AS CHAR                            NO-UNDO. 
    DEF  VAR         aux_nrcpfcgc AS DECI                            NO-UNDO.
    DEF  VAR         aux_ctrlpart AS CHAR                            NO-UNDO. 

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdderror = "".

    EMPTY TEMP-TABLE tt-erro.

    DO WHILE TRUE:

       FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                          crapass.nrdconta = par_nrdconta
                          NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapass   THEN
            DO:
                 ASSIGN aux_cdcritic = 9.
                 LEAVE.
            END.

       IF   crapass.inpessoa = 1   THEN
            DO:
                FIND crapttl WHERE crapttl.cdcooper = par_cdcooper   AND
                                   crapttl.nrdconta = par_nrdconta   AND
                                   crapttl.idseqttl = par_idseqttl
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAIL crapttl   THEN
                     DO:
                         ASSIGN aux_dscritic = "Titular nao cadastrado.".
                         LEAVE.
                     END.

                ASSIGN aux_nrcpfcgc = crapttl.nrcpfcgc.

            END.
       ELSE
            ASSIGN aux_nrcpfcgc = crapass.nrcpfcgc.

       ASSIGN aux_tppessoa = IF crapass.inpessoa = 1 THEN "F" ELSE "J".

       /* buscar quantidade maxima de digitos aceitos para o convenio */
       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
                     
       RUN STORED-PROCEDURE pc_valida_adesao_produto
           aux_handproc = PROC-HANDLE NO-ERROR
                                   (INPUT par_cdcooper,
                                    INPUT par_nrdconta,
                                    INPUT 9, /* DDA */
                                    OUTPUT 0,   /* pr_cdcritic */
                                    OUTPUT ""). /* pr_dscritic */
                   
       CLOSE STORED-PROC pc_valida_adesao_produto
             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

       ASSIGN aux_cdcritic = 0
              aux_dscritic = ""
              aux_cdcritic = pc_valida_adesao_produto.pr_cdcritic                          
                                 WHEN pc_valida_adesao_produto.pr_cdcritic <> ?
              aux_dscritic = pc_valida_adesao_produto.pr_dscritic
                                 WHEN pc_valida_adesao_produto.pr_dscritic <> ?.
       
       IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
         LEAVE.
       
       RUN obtem-dados-legado (INPUT par_cdcooper,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_cdagecxa,
                               INPUT par_nrdcaixa). 

       IF   RETURN-VALUE = "NOK"  THEN
            LEAVE.
       
       RUN gera-cabecalho-soap (INPUT 1,INPUT "Incluir").

       /** Parametros do Metodo **/
       cria-tag (INPUT "CdLegado",INPUT aux_cdlegado,
                 INPUT "string",INPUT hXmlMetodo).
       
       cria-tag (INPUT "ISPBPartRecbdrPrincipal",INPUT aux_nrispbif,
                 INPUT "int",INPUT hXmlMetodo).
       
       cria-tag (INPUT "ISPBPartRecebdrAdmtd",INPUT aux_nrispbif,
                 INPUT "int",INPUT hXmlMetodo). 
       
       ASSIGN aux_ctrlpart = STRING(TODAY,"99999999")+ STRING( ETIME) + "DDAI" .
       
       cria-tag (INPUT "NumCtrlPart",INPUT aux_ctrlpart,
                 INPUT "string",INPUT hXmlMetodo). 
       
       cria-tag (INPUT "TpPessoaPagdr",INPUT aux_tppessoa,
                 INPUT "string",INPUT hXmlMetodo).
       
       cria-tag (INPUT "CPFCNPJPagdr",INPUT STRING(aux_nrcpfcgc),
                 INPUT "int",INPUT hXmlMetodo). 
       
       /* Cria Root 'RepetCtPagdr' */
       hXmlSoap:CREATE-NODE(hXmlRootSoap,"RepetCtPagdr","ELEMENT").
       hXmlMetodo:APPEND-CHILD(hXmlRootSoap).
                  
       /* Cria novo Pagador */
       hXmlSoap:CREATE-NODE(hXmlNode1Soap,"Conta","ELEMENT").
       hXmlRootSoap:APPEND-CHILD(hXmlNode1Soap).
        
       cria-tag (INPUT "TpAgPagdr",INPUT 'F', /* Fisica  */
                 INPUT "string",INPUT hXmlNode1Soap). 
       
       cria-tag (INPUT "AgPagdr",INPUT STRING(crapcop.cdagectl),
                 INPUT "int",INPUT hXmlNode1Soap). 
       
       cria-tag (INPUT "TpCtPagdr",INPUT "CC",
                 INPUT "string",INPUT hXmlNode1Soap). 
       
       cria-tag (INPUT "CtPagdr",INPUT STRING(par_nrdconta),
                 INPUT "int",INPUT hXmlNode1Soap).       

       cria-tag (INPUT "DtAdesDDA",INPUT STRING(YEAR(TODAY),"9999") + 
                                         STRING(MONTH(TODAY), "99") + 
                                         STRING(DAY(TODAY), "99"),
                 INPUT "string",INPUT hXmlNode1Soap).                        

       RUN efetua-requisicao-soap (INPUT 1,INPUT "Incluir").

       IF   RETURN-VALUE = "NOK"  THEN
            LEAVE.
          
       RUN obtem-fault-packet (INPUT "").
       
       IF  RETURN-VALUE = "NOK"  THEN
           LEAVE.

       hXmlMetodo:GET-CHILD(hXmlTagSoap,1).
       
       IF  hXmlTagSoap:NAME <> "return"  THEN
           DO:
               ASSIGN aux_dscritic = "Resposta SOAP invalida (Return).".                              
               LEAVE.
           END.
       
       /** Obtem retorno do metodo **/
       hXmlTagSoap:GET-CHILD(hXmlTextSoap,1).
   
       IF  hXmlTextSoap:NODE-VALUE <> "true"  THEN
           DO:
               RUN elimina-arquivos-requisicao. 
               ASSIGN aux_dscritic = "Falha na atualizacao da situacao.".                 
               LEAVE.                 
           END.

       RUN elimina-arquivos-requisicao.
        
       LEAVE.

    END. /* Fim tratamento criticas */

    IF   aux_cdcritic <> 0   OR
         aux_dscritic <> ""  THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagecxa,
                            INPUT par_nrdcaixa,
                            INPUT 1,  /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic). 

             retorna-linha-log (INPUT par_cdcooper,
                                INPUT par_nrdconta,
                                INPUT "Incluir",
                                INPUT (IF  aux_cdderror <> ""  THEN
                                           aux_cdderror
                                       ELSE
                                          STRING(aux_cdcritic)),
                                INPUT (IF  aux_dsderror <> ""  THEN
                                           aux_dsderror
                                       ELSE
                                           aux_dscritic)).
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.

/****************************************************************************
 Efetuar o encerramento do Pagador eletronico  
****************************************************************************/
PROCEDURE requisicao-encerrar-sacado:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagecxa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR         aux_tppessoa AS CHAR                            NO-UNDO. 
    DEF  VAR         aux_nrcpfcgc AS DECI                            NO-UNDO.
    DEF  VAR         aux_ctrlpart AS CHAR                            NO-UNDO. 

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdderror = "".

    EMPTY TEMP-TABLE tt-erro.

    DO WHILE TRUE:
        
       FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                          crapass.nrdconta = par_nrdconta
                          NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapass   THEN
            DO:
                 ASSIGN aux_cdcritic = 9.
                 LEAVE.
            END.

       IF   crapass.inpessoa = 1   THEN
            DO:
                FIND crapttl WHERE crapttl.cdcooper = par_cdcooper   AND
                                   crapttl.nrdconta = par_nrdconta   AND
                                   crapttl.idseqttl = par_idseqttl
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAIL crapttl   THEN
                     DO:
                         ASSIGN aux_dscritic = "Titular nao cadastrado.".
                         LEAVE.
                     END.

                ASSIGN aux_nrcpfcgc = crapttl.nrcpfcgc.

            END.
       ELSE
            ASSIGN aux_nrcpfcgc = crapass.nrcpfcgc.

       ASSIGN aux_tppessoa = IF crapass.inpessoa = 1 THEN "F" ELSE "J".

       RUN obtem-dados-legado (INPUT par_cdcooper,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_cdagecxa,
                               INPUT par_nrdcaixa). 

       IF   RETURN-VALUE = "NOK"  THEN
            LEAVE.

       RUN gera-cabecalho-soap (INPUT 1,INPUT "Excluir").

       /** Parametros do Metodo **/
       cria-tag (INPUT "CdLegado",INPUT aux_cdlegado,
                 INPUT "string",INPUT hXmlMetodo).

       cria-tag (INPUT "ISPBPartRecbdrPrincipal",INPUT aux_nrispbif,
                 INPUT "int",INPUT hXmlMetodo).

       cria-tag (INPUT "ISPBPartRecebdrAdmtd",INPUT aux_nrispbif,
                 INPUT "int",INPUT hXmlMetodo).

       ASSIGN aux_ctrlpart = STRING(TODAY,"99999999")+ STRING( ETIME) + "DDAE" .
       
       cria-tag (INPUT "NumCtrlPart",INPUT aux_ctrlpart,
                 INPUT "string",INPUT hXmlMetodo).


       cria-tag (INPUT "TpPessoaPagdr",INPUT aux_tppessoa,
                 INPUT "string",INPUT hXmlMetodo).

       cria-tag (INPUT "CPFCNPJPagdr",INPUT STRING(aux_nrcpfcgc),
                 INPUT "int",INPUT hXmlMetodo). 

       RUN efetua-requisicao-soap (INPUT 1,INPUT "Excluir").

       IF   RETURN-VALUE = "NOK"  THEN
            LEAVE.

       RUN obtem-fault-packet (INPUT "").

       IF  RETURN-VALUE = "NOK"  THEN
           LEAVE.

       hXmlMetodo:GET-CHILD(hXmlTagSoap,1).

       IF  hXmlTagSoap:NAME <> "return"  THEN
           DO:
               ASSIGN aux_dscritic = "Resposta SOAP invalida (Return).".                              
               LEAVE.
           END.

       /** Obtem retorno do metodo **/
       hXmlTagSoap:GET-CHILD(hXmlTextSoap,1).

       IF  hXmlTextSoap:NODE-VALUE <> "true"  THEN
           DO:
               RUN elimina-arquivos-requisicao. 
               ASSIGN aux_dscritic = "Falha na atualizacao da situacao.".                 
               LEAVE.                 
           END.

       RUN elimina-arquivos-requisicao.

       LEAVE.

    END. /* Fim tratamento criticas */

    IF   aux_cdcritic <> 0   OR
         aux_dscritic <> ""  THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagecxa,
                            INPUT par_nrdcaixa,
                            INPUT 1,  /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic). 

             retorna-linha-log (INPUT par_cdcooper,
                                INPUT par_nrdconta,
                                INPUT "Excluir",
                                INPUT (IF  aux_cdderror <> ""  THEN
                                           aux_cdderror
                                       ELSE
                                          STRING(aux_cdcritic)),
                                INPUT (IF  aux_dsderror <> ""  THEN
                                           aux_dsderror
                                       ELSE
                                           aux_dscritic)).
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.


/****************************************************************************
 Efetuar a consulta da situacao do Pagador eletronico  
****************************************************************************/
PROCEDURE requisicao-consulta-situacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagecxa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-consulta-situacao.

    DEF  VAR         aux_contador AS INTE                            NO-UNDO.
    DEF  VAR         aux_tppessoa AS CHAR                            NO-UNDO. 
    DEF  VAR         aux_flgativo AS LOGI                            NO-UNDO.
    DEF  VAR         aux_cdsituac AS INTE                            NO-UNDO.
    DEF  VAR         aux_dtsituac AS DATE                            NO-UNDO.
    DEF  VAR         aux_qtadesao AS INTE                            NO-UNDO.
    DEF  VAR         aux_dtadesao AS DATE                            NO-UNDO.
    DEF  VAR         aux_dtexclus AS DATE                            NO-UNDO.
    DEF  VAR         aux_nrcpfcgc AS DECI                            NO-UNDO.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdderror = "".

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-consulta-situacao.

    DO WHILE TRUE:

       FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                          crapass.nrdconta = par_nrdconta
                          NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapass   THEN
            DO:
                 ASSIGN aux_cdcritic = 9.
                 LEAVE.
            END.

       IF   crapass.inpessoa = 1   THEN
            DO:
                FIND crapttl WHERE crapttl.cdcooper = par_cdcooper   AND
                                   crapttl.nrdconta = par_nrdconta   AND
                                   crapttl.idseqttl = par_idseqttl
                                   NO-LOCK NO-ERROR.

                IF NOT AVAIL crapttl   THEN
                     DO:
                         ASSIGN aux_dscritic = "Titular nao cadastrado.".
                         LEAVE.
                     END.

                ASSIGN aux_nrcpfcgc = crapttl.nrcpfcgc.

            END.
       ELSE
            ASSIGN aux_nrcpfcgc = crapass.nrcpfcgc.
    
       ASSIGN aux_tppessoa = IF crapass.inpessoa = 1 THEN "F" ELSE "J".

       RUN obtem-dados-legado (INPUT par_cdcooper,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_cdagecxa,
                               INPUT par_nrdcaixa). 

       IF   RETURN-VALUE = "NOK"  THEN
            LEAVE.

       RUN gera-cabecalho-soap (INPUT 1,INPUT "ConsultaProprio").

       /** Parametros do Metodo **/
       cria-tag (INPUT "CdLegado",INPUT aux_cdlegado,
                 INPUT "string",INPUT hXmlMetodo).

       cria-tag (INPUT "ISPBPartRecbdrPrincipal",INPUT aux_nrispbif,
                 INPUT "int",INPUT hXmlMetodo).

       cria-tag (INPUT "ISPBPartRecebdrAdmtd",INPUT aux_nrispbif,
                 INPUT "int",INPUT hXmlMetodo).
       
       cria-tag (INPUT "TpPessoaPagdr",INPUT aux_tppessoa,
                 INPUT "string",INPUT hXmlMetodo).

       cria-tag (INPUT "CPFCNPJPagdr",INPUT STRING(aux_nrcpfcgc),
                 INPUT "int",INPUT hXmlMetodo). 
       
       RUN efetua-requisicao-soap (INPUT 1,INPUT "ConsultaProprio").

       IF   RETURN-VALUE = "NOK"  THEN
            LEAVE.

       RUN obtem-fault-packet (INPUT "SOAP-ENV:-365,SOAP-ENV:-366"). 
                          
       IF  RETURN-VALUE = "NOK"  THEN
           LEAVE.

       hXmlMetodo:GET-CHILD(hXmlTagSoap,1) NO-ERROR.
     
       IF  hXmlTagSoap:NAME <> "return"  THEN
           DO:
               ASSIGN aux_dscritic = "Resposta SOAP invalida (Return).".                              
               LEAVE.
           END.

       /** Obtem retorno do metodo **/
       hXmlTagSoap:GET-CHILD(hXmlTextSoap,1).

       hXmlTextSoap:NODE-VALUE-TO-MEMPTR(aux_xmlresul) NO-ERROR.

       IF  ERROR-STATUS:ERROR             OR 
           ERROR-STATUS:NUM-MESSAGES > 1  THEN
           DO:
               RUN elimina-arquivos-requisicao.

               SET-SIZE(aux_xmlresul) = 0.

               ASSIGN aux_dscritic = "Resposta SOAP invalida (Memptr).".               
               LEAVE.
           END.         

       /** Cria objetos para leitura do XML retornado **/
       RUN cria-objetos-xml.

       /** Carrega XML retornado na mensagem SOAP **/
       hXmlDoc:LOAD("MEMPTR",aux_xmlresul,FALSE).
       
       /** Obtem Node Root - Tag "SacEletronico" **/
       hXmlDoc:GET-DOCUMENT-ELEMENT(hXmlRoot).
       
       /* Leitura das tags de <Tag> */
       DO aux_contador = 1 TO hXmlRoot:NUM-CHILDREN:

          hXmlRoot:GET-CHILD(hXmlTag,aux_contador).
        
          hXmlTag:GET-CHILD(hXmlText,1).

          IF   hXmlTag:NAME = "JDNPCSitPagEletrc"   THEN
               DO:
                   aux_cdsituac = INTE(hXmlText:NODE-VALUE).
               END.
          ELSE
          IF   hXmlTag:NAME = "JDNPCDtHrSitSacEletrc"   THEN
               DO:
                   aux_dtsituac = DATE(INT(SUBSTR(hXmlText:NODE-VALUE,5,2)),
                                       INT(SUBSTR(hXmlText:NODE-VALUE,7,2)),
                                       INT(SUBSTR(hXmlText:NODE-VALUE,1,4))).
               END.
          ELSE 
          IF   hXmlTag:NAME = "QtdAdesoes"   THEN
               DO:
                   aux_qtadesao = INTE(hXmlText:NODE-VALUE). 
               END.
          ELSE
          IF   hXmlTag:NAME = "DtIniAdesao"   THEN
               DO:
                   aux_dtadesao = DATE(INT(SUBSTR(hXmlText:NODE-VALUE,5,2)),
                                       INT(SUBSTR(hXmlText:NODE-VALUE,7,2)),
                                       INT(SUBSTR(hXmlText:NODE-VALUE,1,4))).
               END.
          ELSE
          IF   hXmlTag:NAME = "DtFimAdesao"   THEN
               DO:
                   aux_dtexclus = DATE(INT(SUBSTR(hXmlText:NODE-VALUE,5,2)),
                                       INT(SUBSTR(hXmlText:NODE-VALUE,7,2)),
                                       INT(SUBSTR(hXmlText:NODE-VALUE,1,4))).  
               END.
       END.

       /* Caso seja situacao seja 6, DDDA esta ativo */
       IF aux_cdsituac = 6 THEN
         DO:       
            ASSIGN aux_flgativo = TRUE.
         END.
       ELSE  
         DO:       
            ASSIGN aux_flgativo = FALSE.
         END.
       

       CREATE tt-consulta-situacao.
       ASSIGN tt-consulta-situacao.flgativo = aux_flgativo
              tt-consulta-situacao.cdsituac = aux_cdsituac
              tt-consulta-situacao.dtsituac = aux_dtsituac
              tt-consulta-situacao.qtadesao = aux_qtadesao
              tt-consulta-situacao.dtadesao = aux_dtadesao
              tt-consulta-situacao.dtexclus = aux_dtexclus
              /* Flag indicando se eh Pagador eletronico na Cecred */
              tt-consulta-situacao.flsacpro = (aux_cdsituac >= 6 AND
                                               aux_cdsituac <= 16).

       RUN elimina-objetos-xml.
       RUN elimina-arquivos-requisicao.

       LEAVE.

    END. /* Fim tratamento criticas */

    IF   aux_cdcritic <> 0   OR
         aux_dscritic <> ""  THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagecxa,
                            INPUT par_nrdcaixa,
                            INPUT 1,  /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic). 

             retorna-linha-log (INPUT par_cdcooper,
                                INPUT par_nrdconta,
                                INPUT "ConsultaProprio",
                                INPUT (IF  aux_cdderror <> ""  THEN
                                           aux_cdderror
                                       ELSE
                                          STRING(aux_cdcritic)),
                                INPUT (IF  aux_dsderror <> ""  THEN
                                           aux_dsderror
                                       ELSE
                                           aux_dscritic)).
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************
 Realizar a requisicao 'VerificarLote' que verifica a situacao de Varios 
 CPF/CNPJ como ativo ou nao no sistema DDA
******************************************************************************/
PROCEDURE requisicao-verificar-lote:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagecxa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-verificar-lote.

    DEF VAR aux_contador AS INTE                                     NO-UNDO.
    DEF VAR aux_contado2 AS INTE                                     NO-UNDO.
    DEF VAR aux_nrcpfsac AS DECI                                     NO-UNDO.
    DEF VAR aux_flgativo AS LOGI                                     NO-UNDO.

    DEF VAR par_stsnrcal AS LOGI                                     NO-UNDO.
    DEF VAR par_inpessoa AS INTE                                     NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI                                     NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                   NO-UNDO.

    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdderror = "".

    EMPTY TEMP-TABLE tt-erro.

    DO WHILE TRUE:

        RUN sistema/generico/procedures/b1wgen9999.p 
            PERSISTENT SET h-b1wgen9999.

        /* Validar os CPF/CNPJ */
        FOR EACH tt-verificar-lote NO-LOCK:
        
            RUN valida-cpf-cnpj IN h-b1wgen9999
                                (INPUT tt-verificar-lote.nrcpfsac,
                                 OUTPUT par_stsnrcal,
                                 OUTPUT par_inpessoa).
              
            IF   NOT par_stsnrcal   THEN /* CPF/CNPJ com erro */
                 DO:
                     ASSIGN aux_cdcritic = 27.
                     LEAVE.
                 END.

            IF   NOT CAN-DO("F,J",tt-verificar-lote.tppessoa)   THEN
                 DO:
                     ASSIGN aux_cdcritic = 436.
                     LEAVE.
                 END.

            IF   tt-verificar-lote.tppessoa = "F"   AND  
                 par_inpessoa <> 1                  THEN
                 DO:
                     ASSIGN aux_cdcritic = 436.
                     LEAVE.
                 END.

            IF   tt-verificar-lote.tppessoa = "J"   AND 
                 par_inpessoa <> 2                  THEN
                 DO:
                     ASSIGN aux_cdcritic = 436.
                     LEAVE.
                 END.
        END.

        DELETE PROCEDURE h-b1wgen9999.

        IF   aux_cdcritic <> 0    OR
             aux_dscritic <> ""   THEN
             LEAVE.

        RUN obtem-dados-legado (INPUT par_cdcooper,
                                INPUT par_nrdconta,
                                INPUT par_idseqttl,
                                INPUT par_cdagecxa,
                                INPUT par_nrdcaixa). 

        IF   RETURN-VALUE = "NOK"  THEN
             LEAVE.

        RUN gera-cabecalho-soap (INPUT 1,INPUT "VerificarLote").
       
        /** Parametros do Metodo **/
        cria-tag (INPUT "CdLegado",INPUT aux_cdlegado,
                  INPUT "string"  ,INPUT hXmlMetodo).
        
        /* Cria Root 'RepetSacdEletrnc' */
        hXmlSoap:CREATE-NODE(hXmlRootSoap,"RepetSacdEletrnc","ELEMENT").
        hXmlMetodo:APPEND-CHILD(hXmlRootSoap).
          
        FOR EACH tt-verificar-lote NO-LOCK:
        
            /* Cria novo Pagador */
            hXmlSoap:CREATE-NODE(hXmlNode1Soap,"SacEletronico","ELEMENT").
            hXmlRootSoap:APPEND-CHILD(hXmlNode1Soap).
                   
            cria-tag (INPUT "TpPessoaPagdr",INPUT tt-verificar-lote.tppessoa,
                      INPUT "string"     ,INPUT hXmlNode1Soap).
             
            cria-tag (INPUT "CPFCNPJPagdr", INPUT STRING(tt-verificar-lote.nrcpfsac),
                      INPUT "int"       , INPUT hXmlNode1Soap).                                       
        END.
        
        RUN efetua-requisicao-soap (INPUT 1,INPUT "VerificarLote").

        IF   RETURN-VALUE = "NOK"  THEN
             LEAVE.
        
        RUN obtem-fault-packet (INPUT ""). 
                           
        IF  RETURN-VALUE = "NOK"  THEN
            LEAVE.

        hXmlMetodo:GET-CHILD(hXmlTagSoap,1) NO-ERROR.
     
        IF  hXmlTagSoap:NAME <> "return"  THEN
            DO:
                ASSIGN aux_dscritic = "Resposta SOAP invalida (Return).".                              
                LEAVE.
            END.

        /** Obtem retorno do metodo **/
        hXmlTagSoap:GET-CHILD(hXmlTextSoap,1).

        hXmlTextSoap:NODE-VALUE-TO-MEMPTR(aux_xmlresul) NO-ERROR.

        IF  ERROR-STATUS:ERROR             OR 
            ERROR-STATUS:NUM-MESSAGES > 1  THEN
            DO:
                RUN elimina-arquivos-requisicao.

                SET-SIZE(aux_xmlresul) = 0.

                ASSIGN aux_dscritic = "Resposta SOAP invalida (Memptr).".               
                LEAVE.
            END.         

        /** Cria objetos para leitura do XML retornado **/
        RUN cria-objetos-xml.

        /** Carrega XML retornado na mensagem SOAP **/
        hXmlDoc:LOAD("MEMPTR",aux_xmlresul,FALSE).
       
        /** Obtem Node Root - Tag "VerificarLote" **/
        hXmlDoc:GET-DOCUMENT-ELEMENT(hXmlRoot).

        /* Para todos os Pagadores enviados */
        DO aux_contador = 1 TO hXmlRoot:NUM-CHILDREN:

            /** Obtem Node Root - Tag "SacEletronico" */
            hXmlRoot:GET-CHILD(hXmlNode1,aux_contador).  

            /* Para as Tags do Pagador */
            DO aux_contado2 = 1 TO hXmlNode1:NUM-CHILDREN:

                hXmlNode1:GET-CHILD(hXmlTag,aux_contado2).

                hXmlTag:GET-CHILD(hXmlText,1).

                IF   hXmlTag:NAME = "CPFCNPJPagdr"   THEN
                     DO:
                         ASSIGN aux_nrcpfsac = DECI(hXmlText:NODE-VALUE).
                     END.
                ELSE 
                IF   hXmlTag:NAME = "IndrAdesPagdrDDA"   THEN
                     DO:
                         ASSIGN aux_flgativo = (hXmlText:NODE-VALUE = "S").   
                     END.
            END.

            /* Atualizar tabela passada como parametro para devolver */
            FOR EACH tt-verificar-lote WHERE
                     tt-verificar-lote.nrcpfsac = aux_nrcpfsac:

                ASSIGN tt-verificar-lote.flgativo = aux_flgativo.    
            END.              

        END. /* Fim leitura dos Pagadors */
  
        RUN elimina-objetos-xml.
        RUN elimina-arquivos-requisicao.

        ASSIGN aux_flgtrans = TRUE.
        LEAVE.

    END.

    IF   NOT aux_flgtrans    THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagecxa,
                            INPUT par_nrdcaixa,
                            INPUT 1,  /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.


/****************************************************************************
 Efetuar a verificacao se o CPF/CNPJ é um Pagador eletronico na base JDDDA  
****************************************************************************/
PROCEDURE requisicao-verificar:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagecxa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM par_flgverif AS LOGI                            NO-UNDO.

    DEF  VAR aux_nrcpfcgc          AS DECI                           NO-UNDO.
    DEF  VAR aux_tppessoa          AS CHAR                           NO-UNDO. 

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdderror = "".

    EMPTY TEMP-TABLE tt-erro.


    DO WHILE TRUE:

       FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                          crapass.nrdconta = par_nrdconta
                          NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapass   THEN
            DO:
                 ASSIGN aux_cdcritic = 9.
                 LEAVE.
            END.

       IF   crapass.inpessoa = 1   THEN
            DO:
                FIND crapttl WHERE crapttl.cdcooper = par_cdcooper   AND
                                   crapttl.nrdconta = par_nrdconta   AND
                                   crapttl.idseqttl = par_idseqttl
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAIL crapttl   THEN
                     DO:
                         ASSIGN aux_dscritic = "Titular nao cadastrado.".
                         LEAVE.
                     END.

                ASSIGN aux_nrcpfcgc = crapttl.nrcpfcgc.

            END.
       ELSE
            ASSIGN aux_nrcpfcgc = crapass.nrcpfcgc.
    
       ASSIGN aux_tppessoa = IF crapass.inpessoa = 1 THEN "F" ELSE "J".

       RUN obtem-dados-legado (INPUT par_cdcooper,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_cdagecxa,
                               INPUT par_nrdcaixa). 

       IF   RETURN-VALUE = "NOK"  THEN
            LEAVE.

       RUN gera-cabecalho-soap (INPUT 1,INPUT "Verificar").

       /** Parametros do Metodo **/
       cria-tag (INPUT "CdLegado",INPUT aux_cdlegado,
                 INPUT "string",INPUT hXmlMetodo).

       cria-tag (INPUT "TpPessoaPagdr",INPUT aux_tppessoa,
                 INPUT "string",INPUT hXmlMetodo).

       cria-tag (INPUT "CPFCNPJPagdr",INPUT STRING(aux_nrcpfcgc),
                 INPUT "int",INPUT hXmlMetodo). 

       RUN efetua-requisicao-soap (INPUT 1,INPUT "Verificar").

       IF   RETURN-VALUE = "NOK"  THEN
            LEAVE.

       RUN obtem-fault-packet (INPUT ""). 
                          
       IF  RETURN-VALUE = "NOK"  THEN
           LEAVE.

       hXmlMetodo:GET-CHILD(hXmlTagSoap,1) NO-ERROR.
     
       IF  hXmlTagSoap:NAME <> "return"  THEN
           DO:
               ASSIGN aux_dscritic = "Resposta SOAP invalida (Return).".                              
               LEAVE.
           END.

       /** Obtem retorno do metodo **/
       hXmlTagSoap:GET-CHILD(hXmlTextSoap,1).

       par_flgverif = LOGICAL(hXmlTextSoap:NODE-VALUE).          

       RUN elimina-arquivos-requisicao.  

       LEAVE.

    END.

    IF   aux_cdcritic <> 0   OR
         aux_dscritic <> ""  THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagecxa,
                            INPUT par_nrdcaixa,
                            INPUT 1,  /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic). 
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.


/*............................ PROCEDURES INTERNAS ..........................*/


PROCEDURE obtem-dados-legado PRIVATE:

    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdagecxa AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                             NO-UNDO.
    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651.

            RETURN "NOK".
        END.

    ASSIGN aux_nmrescop = crapcop.nmrescop
           aux_cdlegado = "LEGWS" 
           aux_nmarqlog = "/usr/coop/" + crapcop.dsdircop + "/log/" +
                          "JDNPC_LogErros_" + STRING(aux_datdodia,"99999999") + 
                          ".log" 
           aux_msgenvio = "/usr/coop/" + crapcop.dsdircop + "/arq/" +
                          "SOAP.MESSAGE.ENVIO." + 
                          STRING(aux_datdodia,"99999999") + 
                          STRING(TIME,"99999") + 
                          gerar-chave() +
                          STRING(par_nrdconta,"99999999") + 
                          STRING(par_idseqttl).
           aux_msgreceb = "/usr/coop/" + crapcop.dsdircop + "/arq/" +
                          "SOAP.MESSAGE.RECEBIMENTO." + 
                          STRING(aux_datdodia,"99999999") + 
                          STRING(TIME,"99999") + 
                          gerar-chave() +
                          STRING(par_nrdconta,"99999999") + 
                          STRING(par_idseqttl).

    FIND crapban WHERE crapban.cdbccxlt = crapcop.cdbcoctl NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapban  THEN
        DO:
            ASSIGN aux_cdcritic = 57.

            RETURN "NOK".
        END.

    ASSIGN aux_nrispbif = STRING(crapban.nrispbif,"99999999").

    RETURN "OK".

END PROCEDURE.


PROCEDURE cria-objetos-xml PRIVATE:

    RUN elimina-objetos-xml.

    CREATE X-DOCUMENT hXmlDoc.
    CREATE X-NODEREF  hXmlRoot.
    CREATE X-NODEREF  hXmlNode1.
    CREATE X-NODEREF  hXmlNode2.
    CREATE X-NODEREF  hXmlNode3.
    CREATE X-NODEREF  hXmlNode4.
    CREATE X-NODEREF  hXmlTag.
    CREATE X-NODEREF  hXmlText.

    RETURN "OK".

END PROCEDURE.


PROCEDURE cria-objetos-soap PRIVATE:

    RUN elimina-objetos-soap.

    CREATE X-DOCUMENT hXmlSoap.
    CREATE X-NODEREF  hXmlEnvelope.
    CREATE X-NODEREF  hXmlHeader.
    CREATE X-NODEREF  hXmlBody.
    CREATE X-NODEREF  hXmlAutentic.
    CREATE X-NODEREF  hXmlMetodo.
    CREATE X-NODEREF  hXmlRootSoap.
    CREATE X-NODEREF  hXmlNode1Soap.
    CREATE X-NODEREF  hXmlNode2Soap.
    CREATE X-NODEREF  hXmlTagSoap.
    CREATE X-NODEREF  hXmlTextSoap.

    RETURN "OK".

END PROCEDURE.


PROCEDURE elimina-objetos-xml PRIVATE:

    IF  VALID-HANDLE(hXmlText)  THEN
        DELETE OBJECT hXmlText.

    IF  VALID-HANDLE(hXmlTag)  THEN
        DELETE OBJECT hXmlTag.

    IF  VALID-HANDLE(hXmlNode4)  THEN
        DELETE OBJECT hXmlNode4.

    IF  VALID-HANDLE(hXmlNode3)  THEN
        DELETE OBJECT hXmlNode3.

    IF  VALID-HANDLE(hXmlNode2)  THEN
        DELETE OBJECT hXmlNode2.

    IF  VALID-HANDLE(hXmlNode1)  THEN
        DELETE OBJECT hXmlNode1.

    IF  VALID-HANDLE(hXmlRoot)  THEN
        DELETE OBJECT hXmlRoot.

    IF  VALID-HANDLE(hXmlDoc)  THEN
        DELETE OBJECT hXmlDoc.

    RETURN "OK".

END PROCEDURE.


PROCEDURE elimina-objetos-soap PRIVATE:

    IF  VALID-HANDLE(hXmlTextSoap)   THEN
        DELETE OBJECT hXmlTextSoap.

    IF  VALID-HANDLE(hXmlTagSoap)    THEN
        DELETE OBJECT hXmlTagSoap.

    IF  VALID-HANDLE(hXmlMetodo)     THEN
        DELETE OBJECT hXmlMetodo.

    IF  VALID-HANDLE(hXmlRootSoap)   THEN
        DELETE OBJECT hXmlRootSoap.

    IF  VALID-HANDLE(hXmlNode1Soap)  THEN
        DELETE OBJECT hXmlNode1Soap.

    IF  VALID-HANDLE(hXmlNode2Soap)  THEN
        DELETE OBJECT hXmlNode2Soap.

    IF  VALID-HANDLE(hXmlAutentic)   THEN
        DELETE OBJECT hXmlAutentic.

    IF  VALID-HANDLE(hXmlBody)       THEN
        DELETE OBJECT hXmlBody.

    IF  VALID-HANDLE(hXmlHeader)     THEN
        DELETE OBJECT hXmlHeader.

    IF  VALID-HANDLE(hXmlEnvelope)   THEN
        DELETE OBJECT hXmlEnvelope.

    IF  VALID-HANDLE(hXmlSoap)       THEN
        DELETE OBJECT hXmlSoap.

    RETURN "OK".

END PROCEDURE.


PROCEDURE gera-cabecalho-soap PRIVATE:

    DEF  INPUT PARAM par_idservic AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmmetodo AS CHAR                           NO-UNDO.

    DEF VAR aux_nmservic AS CHAR                                    NO-UNDO.

    CASE par_idservic:
        WHEN 1 THEN aux_nmservic = "PagadorEletronico".
        WHEN 2 THEN aux_nmservic = "PagadorEletronicoAgregado".
        WHEN 3 THEN aux_nmservic = "TituloPagadorEletronico".
    END CASE.

    RUN cria-objetos-soap.

    /** Criacao do Envelope SOAP **/
    hXmlSoap:CREATE-NODE(hXmlEnvelope,"SOAP-ENV:Envelope","ELEMENT").
    hXmlEnvelope:SET-ATTRIBUTE("xmlns:SOAP-ENV",
                               "http://schemas.xmlsoap.org/soap/envelope/").
    hXmlEnvelope:SET-ATTRIBUTE("xmlns:xsd",
                               "http://www.w3.org/2001/XMLSchema").
    hXmlEnvelope:SET-ATTRIBUTE("xmlns:xsi",
                               "http://www.w3.org/2001/XMLSchema-instance").
    hXmlEnvelope:SET-ATTRIBUTE("xmlns:SOAP-ENC",                        "http://schemas.xmlsoap.org/soap/encoding/").
    hXmlSoap:APPEND-CHILD(hXmlEnvelope).

    /** Criacao do SOAP HEADER **/
    hXmlSoap:CREATE-NODE(hXmlHeader,"SOAP-ENV:Header","ELEMENT").
    hXmlHeader:SET-ATTRIBUTE("SOAP-ENV:encodingStyle",
                             "http://schemas.xmlsoap.org/soap/encoding/").
    hXmlHeader:SET-ATTRIBUTE("xmlns:NS1",
                             "urn:JDNPCWS_" + aux_nmservic + "Intf").
    hXmlEnvelope:APPEND-CHILD(hXmlHeader).

    /** Criacao do Node de Autenticacao **/
    hXmlSoap:CREATE-NODE(hXmlAutentic,"NS1:TAutenticacao","ELEMENT").
    hXmlAutentic:SET-ATTRIBUTE("xsi:type","NS1:TAutenticacao").
    hXmlHeader:APPEND-CHILD(hXmlAutentic).

    /** Usuario para Autenticacao **/
    cria-tag (INPUT "Usuario", INPUT "u",
              INPUT "string",  INPUT hXmlAutentic).

    /** Senha para Autenticacao **/
    cria-tag (INPUT "Senha",  INPUT "s", 
              INPUT "string", INPUT hXmlAutentic).
    
    /** Criacao do SOAP BODY **/
    hXmlSoap:CREATE-NODE(hXmlBody,"SOAP-ENV:Body","ELEMENT").
    hXmlBody:SET-ATTRIBUTE("SOAP-ENV:encodingStyle",
                           "http://schemas.xmlsoap.org/soap/encoding/").
    hXmlEnvelope:APPEND-CHILD(hXmlBody).

    /** Criacao do Node de Metodo e Parametros **/
    hXmlSoap:CREATE-NODE(hXmlMetodo,"NS2:" + par_nmmetodo,"ELEMENT").
    hXmlMetodo:SET-ATTRIBUTE("xmlns:NS2",
                             "urn:JDNPCWS_" + aux_nmservic + "Intf-IJDNPCWS_" + 
                             aux_nmservic).
    hXmlBody:APPEND-CHILD(hXmlMetodo).

    RETURN "OK".

END PROCEDURE.


PROCEDURE efetua-requisicao-soap PRIVATE:

    DEF  INPUT PARAM par_idservic AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmmetodo AS CHAR                           NO-UNDO.

    hXmlSoap:SAVE("FILE",aux_msgenvio).

    UNIX SILENT VALUE("cat " + aux_msgenvio + " | /usr/local/cecred/bin/" +
                      "SendSoapNPC.pl --servico='" + STRING(par_idservic) + 
                      "' > " + aux_msgreceb).

    /* aux_msgreceb = replace(aux_msgreceb,'&gt','>'). */
    /* aux_msgreceb = replace(aux_msgreceb,'&lt;','<'). */
                       


    ASSIGN aux_dsderror = "".

    /** Cria novamente os handles para leitura do soap retornado **/
    RUN cria-objetos-soap.

    DO WHILE TRUE:
           
        /** Valida SOAP retornado pelo WebService **/
        
        hXmlSoap:LOAD("FILE",aux_msgreceb,FALSE) NO-ERROR.
    
        IF  ERROR-STATUS:NUM-MESSAGES > 0  THEN
            DO:
                ASSIGN aux_dsderror = "Resposta SOAP invalida (XML).".
                LEAVE.
            END. 
    
        hXmlSoap:GET-DOCUMENT-ELEMENT(hXmlEnvelope) NO-ERROR.
    
        IF  ERROR-STATUS:NUM-MESSAGES > 0             OR 
            hXmlEnvelope:NAME <> "SOAP-ENV:Envelope"  THEN
            DO:
                ASSIGN aux_dsderror = "Resposta SOAP invalida (Envelope).".
                LEAVE.
            END.
    
        hXmlEnvelope:GET-CHILD(hXmlBody,1) NO-ERROR.
    
        IF  ERROR-STATUS:NUM-MESSAGES > 0      OR 
            hXmlBody:NAME <> "SOAP-ENV:Body"  THEN
            DO:
                ASSIGN aux_dsderror = "Resposta SOAP invalida (Body).".
                LEAVE.
            END.
    
        hXmlBody:GET-CHILD(hXmlMetodo,1) NO-ERROR.
    
        IF  ERROR-STATUS:NUM-MESSAGES > 0                          OR 
           (hXmlMetodo:NAME <> "SOAP-ENV:Fault"                    AND 
            hXmlMetodo:NAME <> "NS1:" + par_nmmetodo + "Response") THEN
            DO:
                ASSIGN aux_dsderror = "Resposta SOAP invalida (Result).".
                LEAVE.
            END.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  aux_dsderror <> ""  THEN
        DO:
            RUN elimina-arquivos-requisicao.

            ASSIGN aux_dscritic = "Falha2 na execucao do metodo NPC" +
                                  (IF  aux_dsderror <> ""  THEN
                                       " (Erro: " + aux_dsderror + ")"
                                   ELSE
                                       "") + 
                                   ". Comunique seu PA."
                   aux_dsreturn = "NOK".

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE obtem-fault-packet PRIVATE:

    /* Parametro que sirve para ignorar certos erros */
    DEF  INPUT PARAM par_dsderror AS CHAR                           NO-UNDO.

    ASSIGN aux_cdderror = ""
           aux_dsderror = "".

    /** Verifica se foi retornado um fault packet (Erro) **/

    IF  hXmlMetodo:NAME = "SOAP-ENV:Fault"  THEN
        DO: 
            DO i = 1 TO hXmlMetodo:NUM-CHILDREN:
    
                hXmlMetodo:GET-CHILD(hXmlTagSoap,i).
        
                IF  hXmlTagSoap:NAME = "#text"  THEN
                    NEXT.

                hXmlTagSoap:GET-CHILD(hXmlTextSoap,1) NO-ERROR.
                 
                IF  ERROR-STATUS:ERROR             OR 
                    ERROR-STATUS:NUM-MESSAGES > 0  THEN
                    NEXT.             

                IF  hXmlTagSoap:NAME = "faultcode"  THEN
                    ASSIGN aux_cdderror = hXmlTextSoap:NODE-VALUE.
        
                IF  hXmlTagSoap:NAME = "faultstring"  THEN
                    ASSIGN aux_dsderror = hXmlTextSoap:NODE-VALUE.
        
            END. /** Fim do DO ... TO **/
            
            /* Se possui erro e foi passado parametro para ignorar ... */
            IF  par_dsderror <> ""            AND 
                aux_cdderror <> ""            AND 
                CAN-DO (par_dsderror,STRING(aux_cdderror)) THEN
                ASSIGN aux_dsreturn = "OK".                
            ELSE
                ASSIGN aux_dscritic = "Falha1 na execucao do metodo NPC" +
                                      (IF  aux_dsderror <> ""  THEN
                                           " (Erro: " + aux_dsderror + ")"
                                       ELSE
                                           "") + 
                                       ". Comunique seu PA."
                       aux_dsreturn = "NOK".

            RUN elimina-arquivos-requisicao.

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE elimina-arquivos-requisicao PRIVATE:

    RUN elimina-objetos-soap.
                         
    UNIX SILENT VALUE("rm " + aux_msgenvio + " 2>/dev/null").
    UNIX SILENT VALUE("rm " + aux_msgreceb + " 2>/dev/null"). 
                          
    RETURN "OK".

END PROCEDURE.


PROCEDURE requisicao-lista-titulos PRIVATE:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagecxa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvenini AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvenfin AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nritmini AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nritmfin AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsittit AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idordena AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qttitulo AS INTE                           NO-UNDO.

    DEF VAR aux_tppessoa AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtvenini AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtvenfin AS CHAR                                    NO-UNDO.

    
    ASSIGN aux_tppessoa = IF par_inpessoa = 1 THEN "F" ELSE "J"
           aux_dtvenini = STRING(YEAR(par_dtvenini),"9999") + 
                          STRING(MONTH(par_dtvenini),"99") +
                          STRING(DAY(par_dtvenini),"99")
           aux_dtvenfin = STRING(YEAR(par_dtvenfin),"9999") + 
                          STRING(MONTH(par_dtvenfin),"99") +
                          STRING(DAY(par_dtvenfin),"99").
    
    RUN gera-cabecalho-soap (INPUT 3, INPUT "ListarTitulos").

    /** Parametros do Metodo **/
    cria-tag (INPUT "CdLegado", INPUT aux_cdlegado,
              INPUT "string", INPUT hXmlMetodo).

    cria-tag (INPUT "ISPBPartRecbdrPrincipal", INPUT aux_nrispbif, 
              INPUT "int", INPUT hXmlMetodo).

    cria-tag (INPUT "ISPBPartRecebdrAdmtd", INPUT aux_nrispbif, 
              INPUT "int", INPUT hXmlMetodo).          

    cria-tag (INPUT "TpPessoaPagdr", INPUT aux_tppessoa, 
              INPUT "string", INPUT hXmlMetodo).

    cria-tag (INPUT "CNPJ_CPFPagdr", INPUT STRING(par_nrcpfcgc), 
              INPUT "int", INPUT hXmlMetodo).

    cria-tag (INPUT "JDNPCSitTitulo", INPUT STRING(par_cdsittit), 
              INPUT "int", INPUT hXmlMetodo).

    IF   aux_dtvenini <> ?   THEN
         cria-tag (INPUT "DtVencTitIni", INPUT aux_dtvenini, 
                   INPUT "int", INPUT hXmlMetodo).
    
    IF   aux_dtvenfin <> ?   THEN
         cria-tag (INPUT "DtVencTitFim", INPUT aux_dtvenfin, 
                   INPUT "int", INPUT hXmlMetodo).
        
    cria-tag (INPUT "ItemInicial", INPUT STRING(par_nritmini), 
              INPUT "int", INPUT hXmlMetodo).

    cria-tag (INPUT "ItemFinal", INPUT STRING(par_nritmfin), 
              INPUT "int", INPUT hXmlMetodo).

    cria-tag (INPUT "JDNPCOrdemTit", INPUT STRING(par_idordena), 
              INPUT "int", INPUT hXmlMetodo).

    RUN efetua-requisicao-soap (INPUT 3,INPUT "ListarTitulos").
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".
    
    RUN obtem-fault-packet (INPUT "SOAP-ENV:-950").
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN aux_dsreturn.
    ELSE
        DO:
            hXmlMetodo:GET-CHILD(hXmlTagSoap,1).

            IF  hXmlTagSoap:NAME <> "return"  THEN
                DO:
                    RUN elimina-arquivos-requisicao.

                    ASSIGN aux_dscritic = "Resposta SOAP invalida (Return)."
                           aux_dsreturn = "NOK".

                    RETURN "NOK".
                END.
            
            /** Obtem retorno do metodo **/
            hXmlTagSoap:GET-CHILD(hXmlTextSoap,1).

            hXmlTextSoap:NODE-VALUE-TO-MEMPTR(aux_xmlresul) NO-ERROR.

            IF  ERROR-STATUS:ERROR             OR 
                ERROR-STATUS:NUM-MESSAGES > 1  THEN
                DO:
                    RUN elimina-arquivos-requisicao.

                    SET-SIZE(aux_xmlresul) = 0.

                    ASSIGN aux_dscritic = "Resposta SOAP invalida (Memptr)."
                           aux_dsreturn = "NOK".

                    RETURN "NOK".
                END.

            /** Cria objetos para leitura do XML retornado **/
            RUN cria-objetos-xml.

            /** Carrega XML retornado na mensagem SOAP **/
            hXmlDoc:LOAD("MEMPTR",aux_xmlresul,FALSE).
            
            /** Obtem Node Root - Tag "ListaTitulos" **/
            hXmlDoc:GET-DOCUMENT-ELEMENT(hXmlRoot).

            /** Leitura da Tag "QtdTotalItensLista" **/
            hXmlRoot:GET-CHILD(hXmlTag,4).
            
            hXmlTag:GET-CHILD(hXmlText,1).
            ASSIGN par_qttitulo = INTE(hXmlText:NODE-VALUE).

            /** Leitura do Node "RepetTit" - Titulos **/
            hXmlRoot:GET-CHILD(hXmlNode1,6).

            DO i = 1 TO hXmlNode1:NUM-CHILDREN:

                /** Leitura dos Nodes "Tit" - Dados de Titulo **/
                hXmlNode1:GET-CHILD(hXmlNode2,i).

                EMPTY TEMP-TABLE bb-instr-tit-sacado-dda. 
                EMPTY TEMP-TABLE bb-descto-tit-sacado-dda.

                ASSIGN aux_nrorditm = 0
                       aux_idtitdda = 0
                       aux_cdsittit = 0
                       aux_cdbccced = 0
                       aux_tppesced = ""
                       aux_nrdocced = 0
                       aux_nmcedent = ""
                       aux_tppessac = ""
                       aux_nrdocsac = 0
                       aux_nmdsacad = ""
                       aux_nmsacava = ""
                       aux_tpdocsav = 0
                       aux_nrdocsav = 0
                       aux_nossonum = ""
                       aux_dscodbar = ""
                       aux_dtvencto = ?
                       aux_dtlimpgt = ?
                       aux_vltitulo = 0
                       aux_nrdocmto = ""
                       aux_cddmoeda = ""
                       aux_dtemissa = ?
                       aux_qtdiapro = 0
                       aux_vlrabati = 0
                       aux_cdtpmora = ""
                       aux_dtdamora = ?
                       aux_vlrdmora = 0
                       aux_cdtpmult = ""
                       aux_dtdmulta = ?   
                       aux_vlrmulta = 0
                       aux_cdcartei = ""
                       aux_idtitneg = ""
                       aux_vldsccal = 0
                       aux_vljurcal = 0
                       aux_vlmulcal = 0
                       aux_vltotcob = 0.

                DO j = 1 TO hXmlNode2:NUM-CHILDREN:

                    hXmlNode2:GET-CHILD(hXmlTag,j).

                    RUN carrega-dados-titulo.

                END. /** Fim do DO .. TO **/

                RUN cria-registro-titulo (INPUT par_cdcooper,
                                          INPUT par_cdagecxa,
                                          INPUT par_nrdcaixa,
                                          INPUT par_nrdconta,
                                          INPUT par_idseqttl).

                IF  RETURN-VALUE = "NOK"  THEN
                    DO:     
                        SET-SIZE(aux_xmlresul) = 0.

                        RUN elimina-objetos-xml.
                        RUN elimina-arquivos-requisicao.

                        RETURN "NOK".
                    END.
                                                               
            END. /** Fim do DO ... TO **/

            SET-SIZE(aux_xmlresul) = 0.

            ASSIGN aux_dsreturn = "OK".
        END.
    
    RUN elimina-objetos-xml.
    RUN elimina-arquivos-requisicao.
    
    RETURN "OK".

END PROCEDURE.



PROCEDURE baixa-operacional:

    DEF  INPUT PARAM par_idtitdda AS DECI                           NO-UNDO.

    RUN gera-cabecalho-soap (INPUT 3, INPUT "BaixaOperacional").

    /** Parametros do Metodo **/

    cria-tag (INPUT "CdLegado", INPUT aux_cdlegado,
              INPUT "string", INPUT hXmlMetodo).

    cria-tag (INPUT "ISPBIF", INPUT aux_nrispbif,
              INPUT "int", INPUT hXmlMetodo).

    cria-tag (INPUT "NumIdentcDDA", INPUT STRING(par_idtitdda),
              INPUT "int", INPUT hXmlMetodo).

    RUN efetua-requisicao-soap (INPUT 3,INPUT "BaixaOperacional").

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "OK".
    
    RUN obtem-fault-packet (INPUT "").

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN aux_dsreturn.
    ELSE
        DO:
            hXmlMetodo:GET-CHILD(hXmlTagSoap,1).

            IF  hXmlTagSoap:NAME <> "return"  THEN
                DO:
                    ASSIGN aux_dscritic = "Resposta SOAP invalida (Return)."
                           aux_dsreturn = "NOK".
                    RETURN "NOK".
                END.

            /** Obtem retorno do metodo **/
            hXmlTagSoap:GET-CHILD(hXmlTextSoap,1).

            IF  hXmlTextSoap:NODE-VALUE <> "true"  THEN
                DO:
                    RUN elimina-arquivos-requisicao.

                    ASSIGN aux_dscritic = "Falha na baixa operacional."
                           aux_dsreturn = "NOK".

                    RETURN "NOK".
                END.

            ASSIGN aux_dsreturn = "OK".
        END.

    RUN elimina-arquivos-requisicao.
    
    RETURN "OK".

END PROCEDURE.




PROCEDURE requisicao-atualizar-situacao PRIVATE:

    DEF  INPUT PARAM par_idtitdda AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdsittit AS INTE                           NO-UNDO.

    RUN gera-cabecalho-soap (INPUT 3, INPUT "AtualizarSituacao").

    /** Parametros do Metodo **/

    cria-tag (INPUT "CdLegado", INPUT aux_cdlegado,
              INPUT "string", INPUT hXmlMetodo).

    cria-tag (INPUT "ISPBPartRecbdrPrincipal", INPUT aux_nrispbif,
              INPUT "int", INPUT hXmlMetodo).

    cria-tag (INPUT "ISPBPartRecebdrAdmtd", INPUT aux_nrispbif,
              INPUT "int", INPUT hXmlMetodo).

    cria-tag (INPUT "NumIdentcNPC", INPUT STRING(par_idtitdda),
              INPUT "int", INPUT hXmlMetodo).

    cria-tag (INPUT "JDNPCSitManutTitSac", INPUT STRING(par_cdsittit),
              INPUT "int", INPUT hXmlMetodo).

    RUN efetua-requisicao-soap (INPUT 3,INPUT "AtualizarSituacao").

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "OK".
    
    RUN obtem-fault-packet (INPUT "").

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN aux_dsreturn.
    ELSE
        DO:
            hXmlMetodo:GET-CHILD(hXmlTagSoap,1).

            IF  hXmlTagSoap:NAME <> "return"  THEN
                DO:
                    ASSIGN aux_dscritic = "Resposta SOAP invalida (Return)."
                           aux_dsreturn = "NOK".
                    RETURN "NOK".
                END.

            /** Obtem retorno do metodo **/
            hXmlTagSoap:GET-CHILD(hXmlTextSoap,1).

            IF  hXmlTextSoap:NODE-VALUE <> "true"  THEN
                DO:
                    RUN elimina-arquivos-requisicao.

                    ASSIGN aux_dscritic = "Falha na atualizacao da situacao."
                           aux_dsreturn = "NOK".

                    RETURN "NOK".
                END.

            ASSIGN aux_dsreturn = "OK".
        END.

    RUN elimina-arquivos-requisicao.
    
    RETURN "OK".

END PROCEDURE.

FUNCTION substituir_caracter RETURNS CHAR ( INPUT par_dsdtexto AS CHAR ) :

DEF VAR aux_dsdtexto AS CHAR                                   NO-UNDO.

  ASSIGN aux_dsdtexto = par_dsdtexto. 

  ASSIGN aux_dsdtexto = REPLACE(
                        REPLACE(
                        REPLACE(
                        REPLACE(
                        REPLACE(aux_dsdtexto,",","")
                                            ,";","")
                                            ,"#","")
                                            ,"&","E")
                                            ,"'","").
        
  ASSIGN aux_dsdtexto = REPLACE(aux_dsdtexto,CHR(20),'').
  ASSIGN aux_dsdtexto = REPLACE(aux_dsdtexto,CHR(24),'').
  ASSIGN aux_dsdtexto = REPLACE(aux_dsdtexto,CHR(25),'').
  ASSIGN aux_dsdtexto = REPLACE(aux_dsdtexto,CHR(26),'').


  RETURN aux_dsdtexto.
END.

PROCEDURE carrega-dados-titulo PRIVATE:

DEF    VAR       aux_flgxmlok AS LOGICAL                        NO-UNDO.

    hXmlTag:GET-CHILD(hXmlText,1).
    
    CASE (hXmlTag:NAME):
        WHEN "NumItem" THEN 
            ASSIGN aux_nrorditm = INTE(hXmlText:NODE-VALUE).
        WHEN "NumIdentcTit" THEN 
            ASSIGN aux_idtitdda = DECI(hXmlText:NODE-VALUE).
        WHEN "JDNPCSitTitulo" THEN
            ASSIGN aux_cdsittit = INTE(hXmlText:NODE-VALUE).
        WHEN "CodPartDestinatario" THEN
            ASSIGN aux_cdbccced = INTE(hXmlText:NODE-VALUE).
        WHEN "TpPessoaBenfcrioOr" THEN
            ASSIGN aux_tppesced = hXmlText:NODE-VALUE.
        WHEN "CPFCNPJBenfcrioOr" THEN 
            ASSIGN aux_nrdocced = DECI(hXmlText:NODE-VALUE).
        WHEN "NomRzSocBenfcrioOr" THEN
        DO:
        
            ASSIGN aux_nmcedent = substituir_caracter(INPUT hXmlText:NODE-VALUE).
            
        END.                                                     
        WHEN "TpPessoaPagdr" THEN
            ASSIGN aux_tppessac = hXmlText:NODE-VALUE.
        WHEN "CPFCNPJPagdr" THEN
            ASSIGN aux_nrdocsac = DECI(hXmlText:NODE-VALUE).
        WHEN "NomRzSocPagdr" THEN
        DO:            
            ASSIGN aux_nmdsacad = substituir_caracter(INPUT hXmlText:NODE-VALUE).            
        END.
        WHEN "Nom_RzSocSacdrAvalst" THEN
        DO:
            ASSIGN aux_nmsacava = substituir_caracter(INPUT hXmlText:NODE-VALUE).            
        END.
        WHEN "TpIdentcSacdrAvalst" THEN
            ASSIGN aux_tpdocsav = INTE(hXmlText:NODE-VALUE).
        WHEN "IdentcSacdrAvalst" THEN
            ASSIGN aux_nrdocsav = DECI(hXmlText:NODE-VALUE).
        WHEN "IdentdNossoNum" THEN 
            ASSIGN aux_nossonum = hXmlText:NODE-VALUE.
        WHEN "NumCodBarras" THEN 
            ASSIGN aux_dscodbar = hXmlText:NODE-VALUE.
        WHEN "DtVencTit" THEN
            ASSIGN aux_dtvencto = IF  hXmlText:NODE-VALUE = ""  THEN
                                      ?
                                  ELSE
                                    DATE(INTE(SUBSTR(hXmlText:NODE-VALUE,5,2)),
                                         INTE(SUBSTR(hXmlText:NODE-VALUE,7,2)),
                                         INTE(SUBSTR(hXmlText:NODE-VALUE,1,4))).
        WHEN "DtLimPgtoTit" THEN
            ASSIGN aux_dtlimpgt = IF  hXmlText:NODE-VALUE = ""  THEN
                                      ?
                                  ELSE
                                    DATE(INTE(SUBSTR(hXmlText:NODE-VALUE,5,2)),
                                         INTE(SUBSTR(hXmlText:NODE-VALUE,7,2)),
                                         INTE(SUBSTR(hXmlText:NODE-VALUE,1,4))).
        WHEN "VlrTit" THEN 
            ASSIGN aux_vltitulo = DECI(REPLACE(hXmlText:NODE-VALUE,".",",")).
        WHEN "NumDocTit" THEN 
            ASSIGN aux_nrdocmto = hXmlText:NODE-VALUE.
        WHEN "CodCartTit" THEN
            ASSIGN aux_cdcartei = hXmlText:NODE-VALUE.
        WHEN "CodMoedaCNAB" THEN 
            ASSIGN aux_cddmoeda = hXmlText:NODE-VALUE.
        WHEN "DtEmsTit" THEN 
            ASSIGN aux_dtemissa = IF  hXmlText:NODE-VALUE = ""  THEN
                                      ?
                                  ELSE
                                    DATE(INTE(SUBSTR(hXmlText:NODE-VALUE,5,2)),
                                         INTE(SUBSTR(hXmlText:NODE-VALUE,7,2)),
                                         INTE(SUBSTR(hXmlText:NODE-VALUE,1,4))).
        WHEN "QtdDiaPrott" THEN 
            ASSIGN aux_qtdiapro = INTE(hXmlText:NODE-VALUE).
        WHEN "IndrTitNegcd" THEN
            ASSIGN aux_idtitneg = IF  hXmlText:NODE-VALUE = "S"  THEN
                                      "SIM"
                                  ELSE
                                  IF  hXmlText:NODE-VALUE = "N"  THEN
                                      "NAO"
                                  ELSE
                                      "".
        WHEN "VlrAbattTit" THEN
            ASSIGN aux_vlrabati = DECI(REPLACE(hXmlText:NODE-VALUE,".",",")).
        
        WHEN "JurosTit" THEN 
            /** Leitura dos Nodes "multas" - Instrucoes **/
            DO k = 1 TO hXmlTag:NUM-CHILDREN:

                hXmlTag:GET-CHILD(hXmlNode3,k).                
                hXmlNode3:GET-CHILD(hXmlText,1).
                
                IF hXmlNode3:NAME = "DtJurosTit" THEN
                  DO:
                    ASSIGN aux_dtdamora = IF  hXmlText:NODE-VALUE = ""  THEN
                                      ?
                                  ELSE
                                    DATE(INTE(SUBSTR(hXmlText:NODE-VALUE,5,2)),
                                         INTE(SUBSTR(hXmlText:NODE-VALUE,7,2)),
                                         INTE(SUBSTR(hXmlText:NODE-VALUE,1,4))).
                  END.
                ELSE IF hXmlNode3:NAME = "CodJurosTit" THEN
            ASSIGN aux_cdtpmora = IF  hXmlText:NODE-VALUE = "2"  THEN
                                      "% AO DIA"
                                  ELSE
                                  IF  hXmlText:NODE-VALUE = "3"  THEN
                                      "% AO MES"
                                  ELSE
                                  IF  hXmlText:NODE-VALUE = "4"  THEN
                                      "% AO MES"
                                  ELSE
                                      "".
                                                
                ELSE IF hXmlNode3:NAME = "VlrPercJurosTit" THEN
            ASSIGN aux_vlrdmora = DECI(REPLACE(hXmlText:NODE-VALUE,".",",")).

            END. /** Fim do DO ... TO **/  
        
        WHEN "MultaTit" THEN
            /** Leitura dos Nodes "multas" - Instrucoes **/
            DO k = 1 TO hXmlTag:NUM-CHILDREN:

                hXmlTag:GET-CHILD(hXmlNode3,k).                
                hXmlNode3:GET-CHILD(hXmlText,1).
                
                IF hXmlNode3:NAME = "DtMultaTit" THEN
                  DO:
            ASSIGN aux_dtdmulta = IF  hXmlText:NODE-VALUE = ""  THEN
                                      ?
                                  ELSE
                                    DATE(INTE(SUBSTR(hXmlText:NODE-VALUE,5,2)),
                                         INTE(SUBSTR(hXmlText:NODE-VALUE,7,2)),
                                         INTE(SUBSTR(hXmlText:NODE-VALUE,1,4))).
                  END.
                ELSE IF hXmlNode3:NAME = "CodMultaTit" THEN
                      ASSIGN aux_cdtpmult = IF  hXmlText:NODE-VALUE = "2"  THEN
                                                "%"
                                            ELSE
                                                "". 
                                                
                ELSE IF hXmlNode3:NAME = "VlrPercMultaTit" THEN
            ASSIGN aux_vlrmulta = DECI(REPLACE(hXmlText:NODE-VALUE,".",",")).
                
              

            END. /** Fim do DO ... TO **/        
        
        WHEN "RepetInfCliCed" THEN DO:
            /** Leitura dos Nodes "Informacao" - Instrucoes **/
            DO k = 1 TO hXmlTag:NUM-CHILDREN:

                hXmlTag:GET-CHILD(hXmlNode3,k).
                hXmlNode3:GET-CHILD(hXmlNode4,1).
                hXmlNode4:GET-CHILD(hXmlText,1).

                CREATE bb-instr-tit-sacado-dda.
                ASSIGN bb-instr-tit-sacado-dda.nrorditm = aux_nrorditm
                       bb-instr-tit-sacado-dda.dsdinstr = hXmlText:NODE-VALUE.

            END. /** Fim do DO ... TO **/
        END.
        
        WHEN "RepetDesctTit" THEN DO:
            
        
            /** Leitura dos Nodes "Desconto" - Descontos **/
            DO k = 1 TO hXmlTag:NUM-CHILDREN:

                hXmlTag:GET-CHILD(hXmlNode3,k).

                CREATE bb-descto-tit-sacado-dda.
                ASSIGN bb-descto-tit-sacado-dda.nrorditm = aux_nrorditm.
                
                
                DO k = 1 TO hXmlNode3:NUM-CHILDREN:
                  hXmlNode3:GET-CHILD(hXmlNode4,k).
                hXmlNode4:GET-CHILD(hXmlText,1).
                  
                  
                  IF hXmlNode4:NAME = 'DtDesctTit' THEN
                  DO:
                ASSIGN bb-descto-tit-sacado-dda.dtlimdsc = 
                                  IF  hXmlText:NODE-VALUE = "" OR
                                      hXmlText:NODE-VALUE = "0" THEN
                                      ?
                                  ELSE
                                    DATE(INTE(SUBSTR(hXmlText:NODE-VALUE,5,2)),
                                         INTE(SUBSTR(hXmlText:NODE-VALUE,7,2)),
                                         INTE(SUBSTR(hXmlText:NODE-VALUE,1,4))).
                  END .
                
                  IF hXmlNode4:NAME = 'CodDesctTit' THEN
                  DO:
                ASSIGN bb-descto-tit-sacado-dda.cdtpdesc = 
                                 IF  CAN-DO("2,5,6",hXmlText:NODE-VALUE)  THEN
                                     "%"
                                 ELSE
                                     ""
                       bb-descto-tit-sacado-dda.dstpdesc = 
                                 IF INTE(hXmlText:NODE-VALUE) > 0 THEN
                                    aux_dstpdesc[INTE(hXmlText:NODE-VALUE)]
                                 ELSE 
                                     "".
                  END.
                
                  IF hXmlNode4:NAME = 'VlrPercDesctTit' THEN
                    DO:
        
                        ASSIGN bb-descto-tit-sacado-dda.vldescto = 
                                             DECI(REPLACE(hXmlText:NODE-VALUE,".",",")).
                  END.     
                    END.

                ASSIGN bb-descto-tit-sacado-dda.dsdescto =
                       IF bb-descto-tit-sacado-dda.vldesct > 0 THEN
                          (
                             TRIM(STRING(bb-descto-tit-sacado-dda.vldesct,
                                        "zzz,zzz,zzz,zz9.99")) +
                             bb-descto-tit-sacado-dda.cdtpdesc + 
                             (
                                 IF  bb-descto-tit-sacado-dda.dtlimdsc = ?  THEN
                                     ""
                                 ELSE
                                     " ATE " + 
                                     STRING(bb-descto-tit-sacado-dda.dtlimdsc,
                                            "99/99/9999")
                             ) 
                             + " - " + bb-descto-tit-sacado-dda.dstpdesc
                          ) 
                       ELSE 
                           "".
                
                
            END. /** Fim do DO ... TO **/
            
            
        END.
        WHEN "VlrCalcdDesct" THEN
            ASSIGN aux_vldsccal = DECI(REPLACE(hXmlText:NODE-VALUE,".",",")).
        WHEN "VlrCalcdJuros" THEN
            ASSIGN aux_vljurcal = DECI(REPLACE(hXmlText:NODE-VALUE,".",",")).
        WHEN "VlrCalcdMulta" THEN
            ASSIGN aux_vlmulcal = DECI(REPLACE(hXmlText:NODE-VALUE,".",",")).
        WHEN "VlrTotCobrar" THEN
            ASSIGN aux_vltotcob = DECI(REPLACE(hXmlText:NODE-VALUE,".",",")).

        WHEN "CidSacdEletrnc" THEN
            ASSIGN aux_nmcidsac = substituir_caracter(INPUT hXmlText:NODE-VALUE).
        WHEN "UFSacdEletrnc" THEN
            ASSIGN aux_cdufssac = hXmlText:NODE-VALUE.
    END CASE.

    IF aux_dtdamora = 12/30/1899 THEN 
       ASSIGN aux_dtdamora = ?.

    IF aux_dtdmulta = 12/30/1899 THEN
       ASSIGN aux_dtdmulta = ?.

    RETURN "OK".

END PROCEDURE.


PROCEDURE cria-registro-titulo PRIVATE:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagecxa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    
    DEF VAR h-b2crap14   AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0044 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_nrdigito AS INTE                                    NO-UNDO.
    DEF VAR aux_nrctacob AS INTE                                    NO-UNDO.
    DEF VAR aux_insittit AS INTE                                    NO-UNDO.
    DEF VAR aux_intitcop AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdctabb AS INTE                                    NO-UNDO.
    
    DEF VAR aux_flgvenci AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgretor AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_lindigi1 AS DECI                                    NO-UNDO.
    DEF VAR aux_lindigi2 AS DECI                                    NO-UNDO.
    DEF VAR aux_lindigi3 AS DECI                                    NO-UNDO.
    DEF VAR aux_lindigi4 AS DECI                                    NO-UNDO.
    DEF VAR aux_lindigi5 AS DECI                                    NO-UNDO.
    DEF VAR aux_nrcnvcob AS DECI                                    NO-UNDO.
    DEF VAR aux_nrbloque AS DECI                                    NO-UNDO.

    DEF VAR aux_nmressac AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmresced AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmcedhis AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdamora AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdmulta AS CHAR                                    NO-UNDO.
    DEF VAR aux_proxutil AS DATE                                    NO-UNDO.
    
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_dscritic = "Handle invalido para BO b1wgen9999."
                   aux_dsreturn = "NOK".
            RETURN "NOK".
        END.       

    RUN Abrevia_Nome IN h-b1wgen9999 (INPUT aux_nmdsacad,
                                      INPUT 28,
                                     OUTPUT aux_nmressac).

    IF  LENGTH(aux_nmressac) > 28  THEN
        ASSIGN aux_nmressac = TRIM(SUBSTR(aux_nmressac,1,28)).

    RUN Abrevia_Nome IN h-b1wgen9999 (INPUT aux_nmcedent,
                                      INPUT 28,
                                     OUTPUT aux_nmresced).

    IF  LENGTH(aux_nmresced) > 28  THEN
        ASSIGN aux_nmresced = TRIM(SUBSTR(aux_nmresced,1,28)).

    RUN Abrevia_Nome IN h-b1wgen9999 (INPUT aux_nmcedent,
                                      INPUT 15,
                                     OUTPUT aux_nmcedhis).

    IF  LENGTH(aux_nmcedhis) > 15  THEN
        ASSIGN aux_nmcedhis = TRIM(SUBSTR(aux_nmcedhis,1,15)).

    DELETE PROCEDURE h-b1wgen9999.

    RUN dbo/b2crap14.p PERSISTENT SET h-b2crap14.

    IF  NOT VALID-HANDLE(h-b2crap14)  THEN
        DO:
            ASSIGN aux_dscritic = "Handle invalido para BO b2crap14."
                   aux_dsreturn = "NOK".
            RETURN "NOK".
        END.                  

    RUN identifica-titulo-coop IN h-b2crap14 (INPUT aux_nmrescop,
                                              INPUT par_nrdconta,
                                              INPUT par_idseqttl,
                                              INPUT par_cdagecxa,
                                              INPUT par_nrdcaixa,
                                              INPUT aux_dscodbar,
                                              INPUT FALSE,
                                             OUTPUT aux_nrctacob,
                                             OUTPUT aux_insittit,
                                             OUTPUT aux_intitcop,
                                             OUTPUT aux_nrcnvcob,
                                             OUTPUT aux_nrbloque,
                                             OUTPUT aux_nrdctabb).   

    ASSIGN aux_flgvenci = FALSE.

    /** Verifica se titulo esta vencido **/
    IF  aux_intitcop <> 1                   AND 
        CAN-DO("1,2",STRING(aux_cdsittit))  AND
        aux_dtvencto <> ?                   THEN 
        RUN verifica-vencimento-titulo IN h-b2crap14 
                                      (INPUT par_cdcooper,
                                       INPUT par_cdagecxa,
                                       INPUT ?,
                                       INPUT aux_dtvencto,
                                      OUTPUT aux_flgvenci).

    /* se houver dt lim de pagto, verificar se nao eh feriado */
    IF aux_dtlimpgt <> ? THEN
    DO:
        RUN verifica-vencimento-titulo IN h-b2crap14 
                                      (INPUT par_cdcooper,
                                       INPUT par_cdagecxa,
                                       INPUT ?,
                                       INPUT aux_dtlimpgt,
                                      OUTPUT aux_flgvenci).
    END.

    DELETE PROCEDURE h-b2crap14.
                              
    /** Formata Linha Digitavel **/
    ASSIGN aux_lindigi1 = DECI(SUBSTR(aux_dscodbar,01,04) +
                               SUBSTR(aux_dscodbar,20,01) +
                               SUBSTR(aux_dscodbar,21,04) + "0")
           aux_lindigi2 = DECI(SUBSTR(aux_dscodbar,25,10) + "0")
           aux_lindigi3 = DECI(SUBSTR(aux_dscodbar,35,10) + "0")
           aux_lindigi4 = INTE(SUBSTR(aux_dscodbar,05,01))
           aux_lindigi5 = DECI(SUBSTR(aux_dscodbar,06,14)).
    
    RUN dbo/pcrap03.p (INPUT-OUTPUT aux_lindigi1,
                       INPUT        TRUE,  
                             OUTPUT aux_nrdigito,
                             OUTPUT aux_flgretor).

    RUN dbo/pcrap03.p (INPUT-OUTPUT aux_lindigi2,
                       INPUT        TRUE,  
                             OUTPUT aux_nrdigito,
                             OUTPUT aux_flgretor).

    RUN dbo/pcrap03.p (INPUT-OUTPUT aux_lindigi3,
                       INPUT        TRUE,  
                             OUTPUT aux_nrdigito,
                             OUTPUT aux_flgretor).

    /** Obtem nome do banco Beneficiário **/
    FIND crapban WHERE crapban.cdbccxlt = aux_cdbccced NO-LOCK NO-ERROR.

    ASSIGN aux_dsdamora = TRIM(STRING(aux_vlrdmora,"zzz,zzz,zzz,zz9.99")) + 
                          aux_cdtpmora + 
                         (IF  aux_dtdamora = ?  THEN
                              ""
                          ELSE
                              " - A PARTIR DE " + 
                                  STRING(aux_dtdamora,"99/99/9999"))
           aux_dsdmulta = TRIM(STRING(aux_vlrmulta,"zzz,zzz,zzz,zz9.99")) +
                          aux_cdtpmult + 
                         (IF  aux_dtdmulta = ?  THEN
                              ""
                          ELSE
                              " - A PARTIR DE " + 
                                  STRING(aux_dtdmulta,"99/99/9999")).

    CREATE tt-titulos-sacado-dda.
    ASSIGN tt-titulos-sacado-dda.nrorditm = aux_nrorditm
           tt-titulos-sacado-dda.idtitdda = aux_idtitdda
           tt-titulos-sacado-dda.cdsittit = aux_cdsittit
           tt-titulos-sacado-dda.cdbccced = STRING(aux_cdbccced,"999")
           tt-titulos-sacado-dda.nmbccced = IF  AVAILABLE crapban  THEN
                                                crapban.nmresbcc
                                            ELSE
                                                "NAO CADASTRADO"
           tt-titulos-sacado-dda.tppesced = aux_tppesced
           tt-titulos-sacado-dda.nrdocced = aux_nrdocced
           tt-titulos-sacado-dda.nmcedent = aux_nmcedent
           tt-titulos-sacado-dda.nmresced = aux_nmresced
           tt-titulos-sacado-dda.nmcedhis = aux_nmcedhis
           tt-titulos-sacado-dda.tppessac = aux_tppessac
           tt-titulos-sacado-dda.nrdocsac = aux_nrdocsac
           tt-titulos-sacado-dda.nmdsacad = aux_nmdsacad
           tt-titulos-sacado-dda.nmressac = aux_nmressac
           tt-titulos-sacado-dda.nmsacava = aux_nmsacava
           tt-titulos-sacado-dda.nrdocsav = aux_nrdocsav
           tt-titulos-sacado-dda.nossonum = aux_nossonum
           tt-titulos-sacado-dda.dscodbar = aux_dscodbar
           tt-titulos-sacado-dda.dtvencto = aux_dtvencto
           tt-titulos-sacado-dda.vltitulo = aux_vltitulo
           tt-titulos-sacado-dda.nrdocsac = aux_nrdocsac
           tt-titulos-sacado-dda.nrdocmto = aux_nrdocmto
           tt-titulos-sacado-dda.cddmoeda = aux_cddmoeda
           tt-titulos-sacado-dda.dsdmoeda = aux_dsdmoeda[INTE(aux_cddmoeda)]
           tt-titulos-sacado-dda.dtemissa = aux_dtemissa
           tt-titulos-sacado-dda.qtdiapro = aux_qtdiapro
           tt-titulos-sacado-dda.idtpdpag = 2  /* Titulo */
           tt-titulos-sacado-dda.vlrabati = aux_vlrabati
           tt-titulos-sacado-dda.cdtpmora = aux_cdtpmora
           tt-titulos-sacado-dda.vlrdmora = aux_vlrdmora
           tt-titulos-sacado-dda.dtdamora = aux_dtdamora
           tt-titulos-sacado-dda.dsdamora = aux_dsdamora
           tt-titulos-sacado-dda.cdtpmult = aux_cdtpmult
           tt-titulos-sacado-dda.vlrmulta = aux_vlrmulta
           tt-titulos-sacado-dda.dtdmulta = aux_dtdmulta
           tt-titulos-sacado-dda.dsdmulta = aux_dsdmulta
           tt-titulos-sacado-dda.flgvenci = aux_flgvenci
           tt-titulos-sacado-dda.cdcartei = aux_cdcartei
           tt-titulos-sacado-dda.idtitneg = aux_idtitneg
           tt-titulos-sacado-dda.dslindig = STRING(STRING(aux_lindigi1,
                                                  "9999999999"),"xxxxx.xxxxx")
                                            + " " +
                                            STRING(STRING(aux_lindigi2,
                                                  "99999999999"),"xxxxx.xxxxxx")
                                            + " " +
                                            STRING(STRING(aux_lindigi3,
                                                  "99999999999"),"xxxxx.xxxxxx")
                                            + " " +
                                            STRING(aux_lindigi4,"9")
                                            + " " +     
                                            STRING(aux_lindigi5,
                                                  "99999999999999"). 
    /** Formata CPF/CNPJ do Sacado **/
    IF  aux_tppessac = "F"  THEN
        ASSIGN tt-titulos-sacado-dda.dsdocsac = 
                          STRING(STRING(aux_nrdocsac,
                                        "99999999999"),"xxx.xxx.xxx-xx").
    ELSE
        ASSIGN tt-titulos-sacado-dda.dsdocsac = 
                          STRING(STRING(aux_nrdocsac,
                                        "99999999999999"),"xx.xxx.xxx/xxxx-xx").

    /** Formata CPF/CNPJ do Beneficiário **/
    IF  aux_tppesced = "F"  THEN
        ASSIGN tt-titulos-sacado-dda.dsdocced = 
                          STRING(STRING(aux_nrdocced,
                                        "99999999999"),"xxx.xxx.xxx-xx").
    ELSE
        ASSIGN tt-titulos-sacado-dda.dsdocced = 
                          STRING(STRING(aux_nrdocced,
                                        "99999999999999"),"xx.xxx.xxx/xxxx-xx").

    /** Formata Documento do Pagador Avalista **/
    IF  aux_tpdocsav = 0  OR  
        aux_nrdocsav = 0  THEN
        ASSIGN tt-titulos-sacado-dda.dsdocsav = "".
    ELSE
    IF  aux_tpdocsav = 1  THEN
        ASSIGN tt-titulos-sacado-dda.dsdocsav = 
                          STRING(STRING(aux_nrdocsav,
                                        "99999999999"),"xxx.xxx.xxx-xx").
    ELSE
    IF  aux_tpdocsav = 2  THEN
        ASSIGN tt-titulos-sacado-dda.dsdocsav = 
                          STRING(STRING(aux_nrdocsav,
                                        "99999999999999"),"xx.xxx.xxx/xxxx-xx").
    ELSE
        ASSIGN tt-titulos-sacado-dda.dsdocsav = STRING(aux_nrdocsav).

    /** Obtem descricao da situacao do titulo **/
    IF  aux_cdsittit = 1  THEN
        ASSIGN tt-titulos-sacado-dda.dssittit = "Aberto".
    ELSE
    IF  aux_cdsittit = 2  THEN
        ASSIGN tt-titulos-sacado-dda.dssittit = "Agendado".
    ELSE
    IF  CAN-DO("3,4,6,7",STRING(aux_cdsittit))  THEN
        ASSIGN tt-titulos-sacado-dda.dssittit = "Pago".
    ELSE
    IF  CAN-DO("5,8,9",STRING(aux_cdsittit))  THEN
        ASSIGN tt-titulos-sacado-dda.dssittit = "Baixado".
    ELSE
    IF  aux_cdsittit = 11  THEN
        ASSIGN tt-titulos-sacado-dda.dssittit = "Registrado".
    ELSE
    IF  aux_cdsittit = 13  THEN
        ASSIGN tt-titulos-sacado-dda.dssittit = "Bloqueado".
    ELSE
    IF  CAN-DO("14,15,16", STRING(aux_cdsittit)) THEN
        ASSIGN tt-titulos-sacado-dda.dssittit = "Pago *".
    ELSE
        ASSIGN tt-titulos-sacado-dda.dssittit = "".

    IF  aux_flgvenci                            OR
        NOT CAN-DO("1,2",STRING(aux_cdsittit))  THEN
        ASSIGN tt-titulos-sacado-dda.flgpghab = FALSE.
    ELSE
        ASSIGN tt-titulos-sacado-dda.flgpghab = TRUE.

    CASE aux_cdcartei:
        WHEN "1" THEN
            ASSIGN tt-titulos-sacado-dda.dscartei = STRING(aux_cdcartei) + " - "
                                                    + "COBRANCA SIMPLES".
        WHEN "2" THEN
            ASSIGN tt-titulos-sacado-dda.dscartei = STRING(aux_cdcartei) + " - "
                                                    + "COBRANCA VINCULADA".
        WHEN "3" THEN
            ASSIGN tt-titulos-sacado-dda.dscartei = STRING(aux_cdcartei) + " - "
                                                    + "COBRANCA CAUCIONADA".
        WHEN "4" THEN
            ASSIGN tt-titulos-sacado-dda.dscartei = STRING(aux_cdcartei) + " - "
                                                    + "COBRANCA DESCONTADA".
        WHEN "5" THEN
            ASSIGN tt-titulos-sacado-dda.dscartei = STRING(aux_cdcartei) + " - "
                                                    + "COBRANCA VENDOR".
        OTHERWISE
            ASSIGN tt-titulos-sacado-dda.dscartei = STRING(aux_cdcartei).
    END CASE.
    
    FOR EACH bb-instr-tit-sacado-dda NO-LOCK:

        CREATE tt-instr-tit-sacado-dda.
        BUFFER-COPY bb-instr-tit-sacado-dda TO tt-instr-tit-sacado-dda.

    END.

    FOR EACH bb-descto-tit-sacado-dda NO-LOCK:

        CREATE tt-descto-tit-sacado-dda.
        BUFFER-COPY bb-descto-tit-sacado-dda TO tt-descto-tit-sacado-dda.

    END.

    ASSIGN tt-titulos-sacado-dda.vlliquid = aux_vltitulo - aux_vlrabati.
    
    FIND FIRST bb-descto-tit-sacado-dda 
         WHERE bb-descto-tit-sacado-dda.dtlimdsc >= TODAY
         NO-LOCK NO-ERROR.

    IF AVAIL bb-descto-tit-sacado-dda THEN
       ASSIGN tt-titulos-sacado-dda.vlliquid = 
              tt-titulos-sacado-dda.vlliquid - bb-descto-tit-sacado-dda.vldesct.

    RUN sistema/generico/procedures/b1wgen0044.p
        PERSISTENT SET h-b1wgen0044.

    /* verifica vencimento na praca do Pagador */
    RUN prox_dia_util in h-b1wgen0044 ( INPUT par_cdcooper,
                                        INPUT aux_nmcidsac,
                                        INPUT aux_cdufssac,
                                        INPUT aux_dtvencto,
                                       OUTPUT aux_proxutil ).

    DELETE PROCEDURE h-b1wgen0044.

    /* se o vencimento for feriado e houve ajuste no valor a cobrar 
       pela CIP no prox dia util, entao zerar os valores de juros e multa */
    IF aux_proxutil = TODAY AND aux_vltotcob > 0 THEN
    DO:
        ASSIGN aux_vldsccal = 0
               aux_vljurcal = 0
               aux_vlmulcal = 0
               aux_vltotcob = 0.
    END.

    ASSIGN tt-titulos-sacado-dda.vldsccal = aux_vldsccal
           tt-titulos-sacado-dda.vljurcal = aux_vljurcal
           tt-titulos-sacado-dda.vlmulcal = aux_vlmulcal
           tt-titulos-sacado-dda.vltotcob = aux_vltotcob
           tt-titulos-sacado-dda.dtlimpgt = aux_dtlimpgt.

    RETURN "OK".

END PROCEDURE.

PROCEDURE alterar-sacado-eletronico :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    
    DEF  VAR aux_tppessoa AS CHAR                                   NO-UNDO.
    DEF  VAR aux_nrcpfcgc AS DECI                                   NO-UNDO.
    
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                       

    message "Alterar-sacado" view-as alert-box.
          
    
    ASSIGN aux_tppessoa = IF crapass.inpessoa = 1 THEN "F" ELSE "J".           
      
    IF  crapass.inpessoa = 1   THEN
            DO:
                FIND crapttl WHERE crapttl.cdcooper = par_cdcooper   AND
                                   crapttl.nrdconta = par_nrdconta   AND
                                   crapttl.idseqttl = par_idseqttl
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAIL crapttl   THEN
                     DO:
                         ASSIGN aux_dscritic = "Titular nao cadastrado.".
                         message aux_dscritic view-as alert-box.
                         LEAVE.
                     END.

                ASSIGN aux_nrcpfcgc = crapttl.nrcpfcgc.

            END.
       ELSE
            ASSIGN aux_nrcpfcgc = crapass.nrcpfcgc.
            

       message "obtem-dados-legado" view-as alert-box.
            
       RUN obtem-dados-legado (INPUT par_cdcooper,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT 0,
                               INPUT 0). 

       IF   RETURN-VALUE = "NOK"  THEN
            LEAVE.
                                
    RUN gera-cabecalho-soap (INPUT 1, INPUT "Alterar").

    /** Parametros do Metodo **/

    cria-tag (INPUT "CdLegado", INPUT aux_cdlegado,
              INPUT "string", INPUT hXmlMetodo).

    cria-tag (INPUT "ISPBPartRecbdrPrincipal", INPUT aux_nrispbif,
              INPUT "int", INPUT hXmlMetodo).
              
    cria-tag (INPUT "ISPBPartRecbdrAdmtd", INPUT aux_nrispbif,
              INPUT "int", INPUT hXmlMetodo).              

    cria-tag (INPUT "NumCtrlPart", INPUT "",
              INPUT "string", INPUT hXmlMetodo).

    cria-tag (INPUT "TpPessoaPagdr",INPUT aux_tppessoa,
              INPUT "string",INPUT hXmlMetodo).
                      
    cria-tag (INPUT "CPFCNPJPagdr", INPUT STRING(aux_nrcpfcgc),
              INPUT "long", INPUT hXmlMetodo).
              
    cria-tag (INPUT "Agencia", INPUT STRING(par_cdagenci),
              INPUT "int", INPUT hXmlMetodo).              
              
    cria-tag (INPUT "TpConta", INPUT "CC",
              INPUT "string", INPUT hXmlMetodo).

    cria-tag (INPUT "Conta",INPUT STRING(par_nrdconta),
              INPUT "long",INPUT hXmlMetodo). 
              
    cria-tag (INPUT "DtIniAdesao", INPUT "",
              INPUT "string", INPUT hXmlMetodo).
       
    cria-tag (INPUT "TpAvisManutTit","2",
              INPUT "int",INPUT hXmlMetodo).

    cria-tag (INPUT "TpAvisManutTitConsd","2",
              INPUT "int",INPUT hXmlMetodo). 
              
    
    RUN efetua-requisicao-soap (INPUT 1,INPUT "Alterar").
    
    message return-value view-as alert-box.

    IF  RETURN-VALUE = "NOK"  THEN
    do:
        RETURN "OK".
    end.
    
    RUN obtem-fault-packet (INPUT "").

    IF  RETURN-VALUE = "NOK"  THEN
    do:
        RETURN aux_dsreturn.
    end.
    ELSE
        DO:
            hXmlMetodo:GET-CHILD(hXmlTagSoap,1).

            IF  hXmlTagSoap:NAME <> "return"  THEN
                DO:
                    ASSIGN aux_dscritic = "Resposta SOAP invalida (Return)."
                           aux_dsreturn = "NOK".
                    RETURN "NOK".
                END.

            /** Obtem retorno do metodo **/
            hXmlTagSoap:GET-CHILD(hXmlTextSoap,1).

            IF  hXmlTextSoap:NODE-VALUE <> "true"  THEN
                DO:
                    RUN elimina-arquivos-requisicao.

                    ASSIGN aux_dscritic = "Falha na atualizacao da situacao."
                           aux_dsreturn = "NOK".
                           
                    RETURN "NOK".
                END.

            ASSIGN aux_dsreturn = "OK".
        END.

    RUN elimina-arquivos-requisicao.
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE requisicao-alterar-sacado:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagecxa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_novacont AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_novaagen AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR         aux_tppessoa AS CHAR                            NO-UNDO. 
    DEF  VAR         aux_nrcpfcgc AS DECI                            NO-UNDO.
    DEF  VAR         aux_ctrlpart AS CHAR                            NO-UNDO. 

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdderror = "".

    EMPTY TEMP-TABLE tt-erro.

    DO WHILE TRUE:

       FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                          crapass.nrdconta = par_nrdconta
                          NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapass   THEN
            DO:
                 ASSIGN aux_cdcritic = 9.
                 LEAVE.
            END.

       IF   crapass.inpessoa = 1   THEN
            DO:
                FIND crapttl WHERE crapttl.cdcooper = par_cdcooper   AND
                                   crapttl.nrdconta = par_nrdconta   AND
                                   crapttl.idseqttl = par_idseqttl
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAIL crapttl   THEN
                     DO:
                         ASSIGN aux_dscritic = "Titular nao cadastrado.".
                         LEAVE.
                     END.

                ASSIGN aux_nrcpfcgc = crapttl.nrcpfcgc.

            END.
       ELSE
            ASSIGN aux_nrcpfcgc = crapass.nrcpfcgc.

       ASSIGN aux_tppessoa = IF crapass.inpessoa = 1 THEN "F" ELSE "J".

       RUN obtem-dados-legado (INPUT par_cdcooper,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_cdagecxa,
                               INPUT par_nrdcaixa). 

       IF   RETURN-VALUE = "NOK"  THEN
            LEAVE.
       
       RUN gera-cabecalho-soap (INPUT 1,INPUT "Alterar").

       /** Parametros do Metodo **/
       cria-tag (INPUT "CdLegado",INPUT aux_cdlegado,
                 INPUT "string",INPUT hXmlMetodo).
       
       cria-tag (INPUT "ISPBPartRecbdrPrincipal",INPUT aux_nrispbif,
                 INPUT "int",INPUT hXmlMetodo).
       
       cria-tag (INPUT "ISPBPartRecebdrAdmtd",INPUT aux_nrispbif,
                 INPUT "int",INPUT hXmlMetodo). 
       
       ASSIGN aux_ctrlpart = STRING(TODAY,"99999999")+ STRING( ETIME) + "DDAI" .
       
       cria-tag (INPUT "NumCtrlPart",INPUT aux_ctrlpart,
                 INPUT "string",INPUT hXmlMetodo). 
       
       cria-tag (INPUT "TpPessoaPagdr",INPUT aux_tppessoa,
                 INPUT "string",INPUT hXmlMetodo).
       
       cria-tag (INPUT "CPFCNPJPagdr",INPUT STRING(aux_nrcpfcgc),
                 INPUT "int",INPUT hXmlMetodo).                  
       
       /* Cria Root 'RepetCtPagdr' */
       hXmlSoap:CREATE-NODE(hXmlRootSoap,"RepetCtPagdr","ELEMENT").
       hXmlMetodo:APPEND-CHILD(hXmlRootSoap).
                  
        
       /* Cria novo Pagador */
       hXmlSoap:CREATE-NODE(hXmlNode1Soap,"CtPagdr","ELEMENT").
       hXmlRootSoap:APPEND-CHILD(hXmlNode1Soap).

       cria-tag (INPUT "IndrManutCtPagdr", INPUT 'I', /* Fisica  */
                 INPUT "string",INPUT hXmlNode1Soap). 
        
       cria-tag (INPUT "TpAgPagdr", INPUT 'F', /* Fisica  */
                 INPUT "int",INPUT hXmlNode1Soap). 
       
       cria-tag (INPUT "AgPagdr",INPUT STRING(par_novaagen),
                 INPUT "int",INPUT hXmlNode1Soap). 
       
       cria-tag (INPUT "TpCtPagdr",INPUT "CC",
                 INPUT "string",INPUT hXmlNode1Soap). 
       
       cria-tag (INPUT "CtPagdr",INPUT STRING(par_novacont),
                 INPUT "int",INPUT hXmlNode1Soap).       

       RUN efetua-requisicao-soap (INPUT 1,INPUT "Alterar").

       IF   RETURN-VALUE = "NOK"  THEN
            LEAVE.
          
       RUN obtem-fault-packet (INPUT "").
       
       IF  RETURN-VALUE = "NOK"  THEN
           LEAVE.

       hXmlMetodo:GET-CHILD(hXmlTagSoap,1).
       
       IF  hXmlTagSoap:NAME <> "return"  THEN
           DO:
               ASSIGN aux_dscritic = "Resposta SOAP invalida (Return).".                      LEAVE.
           END.
       
       /** Obtem retorno do metodo **/
       hXmlTagSoap:GET-CHILD(hXmlTextSoap,1).
   
       IF  hXmlTextSoap:NODE-VALUE <> "true"  THEN
           DO:
               RUN elimina-arquivos-requisicao. 
               ASSIGN aux_dscritic = "Falha na atualizacao da situacao.".                     LEAVE.                 
           END.

       RUN elimina-arquivos-requisicao.
        
       LEAVE.

    END. /* Fim tratamento criticas */

    IF   aux_cdcritic <> 0   OR
         aux_dscritic <> ""  THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagecxa,
                            INPUT par_nrdcaixa,
                            INPUT 1,  /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic). 

             retorna-linha-log (INPUT par_cdcooper,
                                INPUT par_nrdconta,
                                INPUT "Alterar",
                                INPUT (IF  aux_cdderror <> ""  THEN
                                           aux_cdderror
                                       ELSE
                                          STRING(aux_cdcritic)),
                                INPUT (IF  aux_dsderror <> ""  THEN
                                           aux_dsderror
                                       ELSE
                                           aux_dscritic)).
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.


/*...........................................................................*/




