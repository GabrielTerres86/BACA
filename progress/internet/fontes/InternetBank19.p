/*..............................................................................
    
   Programa: sistema/internet/fontes/InternetBank19.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Marco/2007                        Ultima atualizacao: 22/01/2015
   
   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Consultar e carregar dados do sacado para boleto bancario.
   
   Alteracoes: 03/11/2008 - Inclusao widget-pool (martin)

               02/03/2009 - Melhorias no servico de cobranca (David).
               
               22/04/2009 - Retornar CPF/CNPJ formatado no xml (David).
               
               22/06/2009 - Incluido nrctasac no xml(Guilherme).
               
               27/06/2011 - Adicionado atributo qtd de registros em tag SACADO,
                            passa-se regsitros quando < 4000 registros. (Jorge)
 
               20/01/2012 - Adicionado campo de critica de endereco (dscriend)
                            do sacado. (Rafael)

               02/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                            Cedente por Beneficiário e  Sacado por Pagador 
                            Chamado 229313 (Jean Reddiga - RKAM).    

               22/01/2015 - Adicionar os campos de e-mail e celular carregamento
                            dos pagadores - Projeto Boleto por E-mail (Douglas)
..............................................................................*/
 
CREATE WIDGET-POOL.
 
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/internet/includes/b1wnet0001tt.i }

DEF VAR h-b1wnet0001 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_qtemails AS INTE                                           NO-UNDO.
DEF VAR aux_nrcelsac AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdemail AS CHAR                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_nrinssac LIKE crapsab.nrinssac                    NO-UNDO.
DEF  INPUT PARAM par_nmdsacad LIKE crapsab.nmdsacad                    NO-UNDO.
DEF  INPUT PARAM par_cdsitsac LIKE crapsab.cdsitsac                    NO-UNDO.
DEF  INPUT PARAM par_flgvalid AS LOGI                                  NO-UNDO.
                                              
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

RUN sistema/internet/procedures/b1wnet0001.p PERSISTENT SET h-b1wnet0001.
  
IF  NOT VALID-HANDLE(h-b1wnet0001)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wnet0001.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.

IF  par_nrinssac > 0  THEN
    DO:
        RUN valida-sacado IN h-b1wnet0001 
                                  (INPUT par_cdcooper,
                                   INPUT 90,             /** PAC      **/
                                   INPUT 900,            /** Caixa    **/
                                   INPUT "996",          /** Operador **/
                                   INPUT "INTERNETBANK", /** Tela     **/
                                   INPUT "3",            /** Origem   **/
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                   INPUT par_nrinssac,
                                   INPUT par_flgvalid,
                                   INPUT TRUE,           /** Logar    **/
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT TABLE tt-dados-sacado-blt).

        DELETE PROCEDURE h-b1wnet0001.
                
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                IF  AVAILABLE tt-erro  THEN
                    aux_dscritic = tt-erro.dscritic.
                ELSE
                    aux_dscritic = "Nao foi possivel carregar dados do " +
                                   "Pagador.".
                    
                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
                RETURN "NOK".
            END.
           
        FIND FIRST tt-dados-sacado-blt NO-LOCK NO-ERROR.
        
        IF  AVAILABLE tt-dados-sacado-blt  THEN
            DO:
                ASSIGN aux_nrcelsac = "".
                IF tt-dados-sacado-blt.nrcelsac > 0 THEN
                   ASSIGN aux_nrcelsac = TRIM(STRING(tt-dados-sacado-blt.nrcelsac)).
                
                CREATE xml_operacao.
                ASSIGN xml_operacao.dslinxml = "<BOLETO><nmdsacad>" +
                                           TRIM(tt-dados-sacado-blt.nmdsacad) +
                                               "</nmdsacad><dsendsac>" +
                                           TRIM(tt-dados-sacado-blt.dsendsac) +
                                               "</dsendsac><nrendsac>" +
                                   TRIM(STRING(tt-dados-sacado-blt.nrendsac)) +
                                               "</nrendsac><nmbaisac>" +
                                           TRIM(tt-dados-sacado-blt.nmbaisac) +
                                               "</nmbaisac><nmcidsac>" +
                                           TRIM(tt-dados-sacado-blt.nmcidsac) +
                                               "</nmcidsac><cdufsaca>" +
                                           TRIM(tt-dados-sacado-blt.cdufsaca) +
                                               "</cdufsaca><nrcepsac>" +
                           TRIM(STRING(STRING(tt-dados-sacado-blt.nrcepsac,
                                              "99999999"),"xxxxx-xxx")) +
                                               "</nrcepsac><complend>" +
                                           TRIM(tt-dados-sacado-blt.complend) +
                                               "</complend><nrinssac>" +
                                   TRIM(STRING(tt-dados-sacado-blt.nrinssac)) + 
                                               "</nrinssac><cdtpinsc>" +
                                   TRIM(STRING(tt-dados-sacado-blt.cdtpinsc)) +
                                               "</cdtpinsc><cdsitsac>" +
                                   TRIM(STRING(tt-dados-sacado-blt.cdsitsac)) +
                                               "</cdsitsac><flgremov>" +
                                   TRIM(STRING(tt-dados-sacado-blt.flgremov)) +
                                               "</flgremov>" + 
                                               "<dscriend>" + 
                                           TRIM(tt-dados-sacado-blt.dscriend) +
                                               "</dscriend>" + 
                                               "<dsdemail>" + 
                                           TRIM(tt-dados-sacado-blt.dsdemail) +
                                               "</dsdemail>" + 
                                               "<nrcelsac>" + 
                                               aux_nrcelsac +
                                               "</nrcelsac>" +                                                
                                               "<dssitsac>" +
                                               tt-dados-sacado-blt.dssitsac +
                                               "</dssitsac>" +                                               
                                               "<nrdddcel>" +
                                               (IF tt-dados-sacado-blt.nrcelsac > 0 THEN
                                                   SUBSTR(STRING(tt-dados-sacado-blt.nrcelsac),1,2)
                                                ELSE
                                                   "0") +
                                               "</nrdddcel>" +
                                               "<nrcelula>" +
                                               (IF tt-dados-sacado-blt.nrcelsac > 0 THEN
                                                   SUBSTR(STRING(tt-dados-sacado-blt.nrcelsac),3)
                                                ELSE
                                                   "0") +
                                               "</nrcelula>" +                                               
                                               "</BOLETO>".
            END.
    END.
ELSE
    DO:
        RUN seleciona-sacados IN h-b1wnet0001 
                                        (INPUT par_cdcooper,
                                         INPUT 90,             /** PAC      **/
                                         INPUT 900,            /** Caixa    **/
                                         INPUT "996",          /** Operador **/
                                         INPUT "INTERNETBANK", /** Tela     **/
                                         INPUT "3",            /** Origem   **/
                                         INPUT par_nrdconta,
                                         INPUT par_idseqttl,
                                         INPUT par_nmdsacad,
                                         INPUT par_cdsitsac,
                                         INPUT FALSE,          /** Logar    **/
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-sacados-blt).

        DELETE PROCEDURE h-b1wnet0001.
                
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                IF  AVAILABLE tt-erro  THEN
                    aux_dscritic = tt-erro.dscritic.
                ELSE
                    aux_dscritic = "Nao foi possivel consultar pagadores.".
                    
                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
                RETURN "NOK".
            END.
    
        FOR EACH tt-sacados-blt NO-LOCK:
            ASSIGN aux_contador = aux_contador + 1.
        END.

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<SACADOS qttotsac='" + 
                                        STRING(aux_contador) + "'>".
        
        IF aux_contador < 4000 THEN
        DO:
            FOR EACH tt-sacados-blt NO-LOCK:

                CREATE xml_operacao.
                ASSIGN xml_operacao.dslinxml = "<SACADO><nmdsacad>" +
                                               tt-sacados-blt.nmdsacad +
                                               "</nmdsacad><nrinssac>" +
                                               STRING(tt-sacados-blt.nrinssac) +
                                               "</nrinssac><dsinssac>" +
                                               tt-sacados-blt.dsinssac +
                                               "</dsinssac><nrctasac>" +
                                               STRING(tt-sacados-blt.nrctasac) +
                                               "</nrctasac><dsctasac>" +
                                               tt-sacados-blt.dsctasac +
                                               "</dsctasac>" + 
                                               "<cdsitsac> " + 
                                               STRING(tt-sacados-blt.cdsitsac) +
                                               "</cdsitsac>" +
                                               "<flgemail>" +
                                               (IF(tt-sacados-blt.flgemail)THEN
                                                   "1"
                                                ELSE 
                                                   "0") +
                                               "</flgemail><nmsacado>" +
                                               tt-sacados-blt.nmsacado +
                                               "</nmsacado><dsflgend>" +
                                               STRING(tt-sacados-blt.dsflgend) +
                                               "</dsflgend><dsflgprc>" +
                                               STRING(tt-sacados-blt.dsflgprc) +
                                               "</dsflgprc><dssitsac>" +
                                               tt-sacados-blt.dssitsac +
                                               "</dssitsac><LISTA_EMAILS>".
                                               
                DO aux_qtemails = 1 TO NUM-ENTRIES(tt-sacados-blt.dsdemail,";"):
                
                   ASSIGN aux_dsdemail = ENTRY(aux_qtemails,tt-sacados-blt.dsdemail,";").
                   
                   IF  TRIM(aux_dsdemail) <> "" THEN
                       DO:
                           CREATE xml_operacao.
                           ASSIGN xml_operacao.dslinxml = "<EMAIL><dsdemail>" + 
                                                          TRIM(aux_dsdemail) + 
                                                          "</dsdemail></EMAIL>".
                       END.
                
                END.                                               
                                               
                CREATE xml_operacao.
                ASSIGN xml_operacao.dslinxml = "</LISTA_EMAILS></SACADO>".
            END.
        END.

        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "</SACADOS>".
    END.

RETURN "OK".
        
/*............................................................................*/
