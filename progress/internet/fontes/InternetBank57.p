/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank57.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Janeiro/2009                     Ultima atualizacao: 06/11/2015
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Listar extrato de tarifas. 
   
   Alteracoes: 06/11/2015 - Adição da coluna INDEBCRE na tt-tarifas (Dionathan)
 
..............................................................................*/
 
CREATE WIDGET-POOL.

{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/internet/includes/var_ibank.i }

DEF VAR h-b1wgen0001 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR aux_totdomes AS DECI EXTENT 13                                 NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_anorefer AS INTE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

RUN sistema/generico/procedures/b1wgen0001.p PERSISTENT SET h-b1wgen0001.
                
IF  NOT VALID-HANDLE(h-b1wgen0001)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0001.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.
      
RUN gera_extrato_tarifas IN h-b1wgen0001 (INPUT par_cdcooper,
                                          INPUT 90,             /** PAC      **/
                                          INPUT 900,            /** Caixa    **/
                                          INPUT "996",          /** Operador **/
                                          INPUT par_nrdconta,
                                          INPUT par_anorefer,
                                          INPUT 3,              /** Origem   **/
                                          INPUT par_idseqttl,
                                          INPUT "INTERNETBANK", /** Tela     **/
                                          INPUT TRUE,           /** Logar    **/
                                         OUTPUT TABLE tt-dados_cooperado,
                                         OUTPUT TABLE tt-tarifas,
                                         OUTPUT aux_totdomes,
                                         OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0001.

IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR. 
                    
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE           
            aux_dscritic = "Nao foi possivel obter o extrato de tarifas.".
                   
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
                                                       
        RETURN "NOK".    
    END.

FIND FIRST tt-dados_cooperado NO-LOCK NO-ERROR.

IF  AVAILABLE tt-dados_cooperado  THEN
    DO:
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<DADOS><nmextcop>" + 
                                       tt-dados_cooperado.nmextcop +
                                       "</nmextcop><nrdconta>" + 
                                       STRING(tt-dados_cooperado.nrdconta) +
                                       "</nrdconta><inpessoa>" +
                                       STRING(tt-dados_cooperado.inpessoa) +
                                       "</inpessoa><nmprimtl>" +
                                       tt-dados_cooperado.nmprimtl +
                                       "</nmprimtl><nrcpfcgc>" + 
                                       STRING(tt-dados_cooperado.nrcpfcgc) +
                                       "</nrcpfcgc><cdagenci>" +
                                       STRING(tt-dados_cooperado.cdagenci) +
                                       "</cdagenci></DADOS>".
    END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<EXTRATO>".

FOR EACH tt-tarifas NO-LOCK BY tt-tarifas.indebcre DESC:

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = '<TARIFA dsexthst="' + tt-tarifas.dsexthst +
                                   '" indebcre="' + tt-tarifas.indebcre +
                                   '"><janeiro>' + 
                                   TRIM(STRING(tt-tarifas.vlrdomes[1],
                                               "zzz,zzz,zz9.99-")) +
                                   '</janeiro><fevereiro>' +
                                   TRIM(STRING(tt-tarifas.vlrdomes[2],
                                               "zzz,zzz,zz9.99-")) +        
                                   '</fevereiro><marco>' +
                                   TRIM(STRING(tt-tarifas.vlrdomes[3],
                                               "zzz,zzz,zz9.99-")) +         
                                   '</marco><abril>' +
                                   TRIM(STRING(tt-tarifas.vlrdomes[4],
                                               "zzz,zzz,zz9.99-")) +         
                                   '</abril><maio>' +
                                   TRIM(STRING(tt-tarifas.vlrdomes[5],
                                               "zzz,zzz,zz9.99-")) +         
                                   '</maio><junho>' +
                                   TRIM(STRING(tt-tarifas.vlrdomes[6],
                                               "zzz,zzz,zz9.99-")) +         
                                   '</junho><julho>' +
                                   TRIM(STRING(tt-tarifas.vlrdomes[7],
                                               "zzz,zzz,zz9.99-")) +         
                                   '</julho><agosto>' + 
                                   TRIM(STRING(tt-tarifas.vlrdomes[8],
                                               "zzz,zzz,zz9.99-")) +        
                                   '</agosto><setembro>' +
                                   TRIM(STRING(tt-tarifas.vlrdomes[9],
                                               "zzz,zzz,zz9.99-")) +       
                                   '</setembro><outubro>' +
                                   TRIM(STRING(tt-tarifas.vlrdomes[10],
                                               "zzz,zzz,zz9.99-")) +        
                                   '</outubro><novembro>' +
                                   TRIM(STRING(tt-tarifas.vlrdomes[11],
                                               "zzz,zzz,zz9.99-")) +        
                                   '</novembro><dezembro>' +        
                                   TRIM(STRING(tt-tarifas.vlrdomes[12],
                                               "zzz,zzz,zz9.99-")) +
                                   '</dezembro><vltotanu>' +
                                   TRIM(STRING(tt-tarifas.vlrdomes[13],
                                               "zzz,zzz,zz9.99-")) +
                                   '</vltotanu></TARIFA>'.

END. /** Fim do FOR EACH tt-tarifas **/

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</EXTRATO><TOTAIS><janeiro>" + 
                               TRIM(STRING(aux_totdomes[1],
                                           "zzz,zzz,zz9.99-")) +
                               "</janeiro><fevereiro>" +
                               TRIM(STRING(aux_totdomes[2],
                                           "zzz,zzz,zz9.99-")) +
                               "</fevereiro><marco>" +
                               TRIM(STRING(aux_totdomes[3],
                                           "zzz,zzz,zz9.99-")) +
                               "</marco><abril>" +
                               TRIM(STRING(aux_totdomes[4],
                                           "zzz,zzz,zz9.99-")) +
                               "</abril><maio>" +
                               TRIM(STRING(aux_totdomes[5],
                                           "zzz,zzz,zz9.99-")) +
                               "</maio><junho>" +
                               TRIM(STRING(aux_totdomes[6],
                                           "zzz,zzz,zz9.99-")) +
                               "</junho><julho>" +
                               TRIM(STRING(aux_totdomes[7],
                                           "zzz,zzz,zz9.99-")) +
                               "</julho><agosto>" +
                               TRIM(STRING(aux_totdomes[8],
                                           "zzz,zzz,zz9.99-")) +
                               "</agosto><setembro>" +
                               TRIM(STRING(aux_totdomes[9],
                                           "zzz,zzz,zz9.99-")) +
                               "</setembro><outubro>" +
                               TRIM(STRING(aux_totdomes[10],
                                           "zzz,zzz,zz9.99-")) +
                               "</outubro><novembro>" +
                               TRIM(STRING(aux_totdomes[11],
                                           "zzz,zzz,zz9.99-")) +
                               "</novembro><dezembro>" +
                               TRIM(STRING(aux_totdomes[12],
                                           "zzz,zzz,zz9.99-")) +
                               "</dezembro><vltotanu>" +
                               TRIM(STRING(aux_totdomes[13],
                                           "zzz,zzz,zz9.99-")) +
                               "</vltotanu></TOTAIS>".

RETURN "OK".

/*............................................................................*/
