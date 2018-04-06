 /******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------------+----------------------------------------+
  | Rotina Progress                          | Rotina Oracle PLSQL                    |
  +------------------------------------------+----------------------------------------+
  | sistema/generico/procedures/b1wgen9998.p |                                        |
  |   digm10                                 | CADA0001.pc_digm10                     |
  |   retorna-digito-cnpj                    | GENE0005.fn_retorna_digito_cnpj        |
  |   Gera-arquivo-controle                  | CTME0001.pc_gera_arquivo_controle      |
  |   Email-controle-movimentacao            | CTME0001.pc_email_controle_movimentacao|
  |   valida_operador_migrado                | CADA0001.pc_valida_operador_migrado    |
  +------------------------------------------+----------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/
 
 
 
 /*..............................................................................

    Programa  : b1wgen9998.p
    Autor     : Elton
    Data      : Marco/2010                   Ultima Atualizacao: 29/02/2016
    
    Dados referentes ao programa:

    Objetivo  : BO ref. TODOS OS PROCEDIMENTOS GENERICOS.
                Continuacao da b1wgen9999
    
    Alteracoes: 11/08/2010 - Incluir procedure dig_bbx (Diego).
                           - Incluir procedures dig_cmc7
                           - Incluir procedures digm10 
                           - Incluir procedures existe_conta_integracao 
                             (Guilherme).
                 
                15/09/2010 - Incluido caminho completo no destino dos arquivos
                             de log da procedure limpa_arquivos_proces;
                           - Incluido parametro par_cdcooper na procedure
                             limpa_arquivos_proces (Elton).
                             
                23/05/2011 - Criar procedure de envio de email para controle
                             de lavagem de dinheiro (Gabriel).          
                             
                20/07/2011 - Criar procedure de controle de tela/opcao
                             para o uso de um operador só (Gabriel).
                             
                           - Nao enviar email para as contas administrativas
                             no controle de movimentacao.
                             Mostrar na Juridica quem fez o saque ou recebeu
                             o deposito (Gabriel).                    
                             
                16/09/2011 - Incluir campo 'Valor retirado em especie' 
                             na impressao do controle de movimentacao (Gabriel)
                                                                      
                04/10/2011 - Se conta nao informada no DOC ou TED da erro
                             de associado nao cadastrado (Magui).
                             
                23/11/2011 - Corrigir alteracao anterior (Gabriel)             
                
                24/11/2011 - Adaptar email cme para nao cooperado (Guilherme).
                
                11/10/2012 - Incluido nova procedure valida_operador_migrado
                             (David Kruger).
                             
                03/01/2012 - Ajustado o find first crapopm da procedure
                             valida_operador_migrado (Adriano).             
                             
                04/01/2013 - Incluido condicao (craptco.tpctatrf <> 3) na busca
                             da craptco (Tiago).              
                             
                23/01/2013 - Incluso crapopm.flgativo no find (Guilherme)
                
                06/02/2013 - Incluir procedure valida_restricao_operador
                             para verificar se operador tem permissao para 
                             acessar conta do cooperado (Lucas R.).
                             
                22/05/2013 - Adicionadas procedures para retornar DV de 
                             CPF e CNPJ (Lucas).
                
                13/11/2013 - Nova forma de chamar as agências, de PAC agora 
                             a escrita será PA (Guilherme Gielow)
                             
                10/12/2013 - Incluir VALIDADE craptab (Lucas R.)
                
                03/07/2014 - Verificar se o perador tem permissao para acessar
                             determinada conta via conta ITG (Chamado 163002)
                             (Jonata - RKAM).
                             
                23/10/2014 - Incluir IF  par_nrdctitg <> "" THEN na procedure
                             valida_restricao_operador (Lucas R. #191758)
                             
                20/08/2015 - Adicionado procedure para retornar SAC e OUVIDORIA 
                             nos comprovantes (Lucas Lunelli - Melhoria 83 [SD 279180])
                             
                29/02/2016 - Trocando o campo flpolexp para inpolexp conforme
                             solicitado no chamado 402159 (Kelvin).
                             
                21/12/2017 - Adicionado o tpoperac = 3 para a melhoria 458.
                             Antonio R. Jr (Mouts)
 ............................................................................*/
    
{ sistema/generico/includes/var_internet.i }    
{ sistema/generico/includes/b1wgen9998tt.i }
{ sistema/generico/includes/gera_erro.i }   
{ sistema/generico/includes/gera_log.i  }

DEF STREAM str_1.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

/* Variaveis usadas no Controle de Movimentacao */
DEF  VAR aux_nmarquiv AS CHAR                                          NO-UNDO.
DEF  VAR aux_nmarqimp AS CHAR                                          NO-UNDO.
DEF  VAR aux_nmarqpdf AS CHAR                                          NO-UNDO.
DEF  VAR aux_flgprime AS LOGI                                          NO-UNDO.

DEF VAR h-b1wgen0011 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                         NO-UNDO.

/*****************************************************************************/
/*                 Retorna Digito Verificador do CPF ou CNPJ                 */
/*****************************************************************************/
PROCEDURE retorna-digito-cpf-cnpj:

    DEF  INPUT PARAM par_nrcalcul AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_nrdigito AS INTE                           NO-UNDO.

    IF  LENGTH(STRING(par_nrcalcul)) >= 11  THEN
        DO:
            RUN retorna-digito-cnpj (INPUT par_nrcalcul,
                                    OUTPUT par_nrdigito).
        END.
    ELSE
        DO:
            RUN retorna-digito-cpf (INPUT par_nrcalcul,
                                   OUTPUT par_nrdigito).
        END.
    
    RETURN "OK".
    
END PROCEDURE.

/*****************************************************************************/
/*                      Retorna Digito Verificador do CPF                    */
/*****************************************************************************/
PROCEDURE retorna-digito-cpf:

    /* Deve ser passado o Número do CPF SEM o dígito verificador */
    DEF  INPUT PARAM par_nrcalcul AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_nrdigito AS INTE                           NO-UNDO.

    DEF VAR aux_nrdigito AS INTE INIT 0                             NO-UNDO.
    DEF VAR aux_nrposica AS INTE INIT 0                             NO-UNDO.
    DEF VAR aux_vlrdpeso AS INTE INIT 2                             NO-UNDO.
    DEF VAR aux_vlcalcul AS INTE INIT 0                             NO-UNDO.
    DEF VAR aux_vldresto AS INTE INIT 0                             NO-UNDO.

    ASSIGN aux_vlrdpeso = 9
           aux_nrposica = 0
           aux_vlcalcul = 0.

    IF  LENGTH(STRING(par_nrcalcul)) > 9 THEN
        RETURN "OK".

    DO aux_nrposica = (LENGTH(STRING(par_nrcalcul))) TO 1 BY -1:

        ASSIGN aux_vlcalcul = aux_vlcalcul + (INTE(SUBSTR(STRING(par_nrcalcul),
                                              aux_nrposica,1)) * aux_vlrdpeso)
               aux_vlrdpeso = aux_vlrdpeso - 1.

    END. /** Fim do DO ... TO **/

    ASSIGN aux_vldresto = aux_vlcalcul MODULO 11.

    IF  aux_vldresto = 10  THEN
        ASSIGN aux_nrdigito = 0.
    ELSE
        ASSIGN aux_nrdigito = aux_vldresto.

    ASSIGN aux_vlrdpeso = 8
           aux_nrposica = 0
           aux_vlcalcul = aux_nrdigito * 9.

    DO aux_nrposica = (LENGTH(STRING(par_nrcalcul))) TO 1 BY -1:

        ASSIGN aux_vlcalcul = aux_vlcalcul + (INTE(SUBSTR(STRING(par_nrcalcul),
                                              aux_nrposica,1)) * aux_vlrdpeso)
               aux_vlrdpeso = aux_vlrdpeso - 1.

    END. /** Fim do DO ... TO **/

    ASSIGN aux_vldresto = aux_vlcalcul MODULO 11.

    IF  aux_vldresto = 10  THEN
        ASSIGN aux_nrdigito = aux_nrdigito * 10.      
    ELSE
        ASSIGN aux_nrdigito = (aux_nrdigito * 10) + aux_vldresto.

    ASSIGN par_nrdigito = aux_nrdigito.

    RETURN "OK".
    
END PROCEDURE.


/*****************************************************************************/
/*                     Retorna Digito Verificador do CNPJ                   */
/*****************************************************************************/
PROCEDURE retorna-digito-cnpj:

    /* Deve ser passado o Número do CNPJ SEM o dígito verificador */
    DEF  INPUT PARAM par_nrcalcul AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_nrdigito AS INTE                           NO-UNDO.

    DEF VAR aux_nrdigit1 AS INTE INIT 0                             NO-UNDO.
    DEF VAR aux_nrdigit2 AS INTE INIT 0                             NO-UNDO.
    DEF VAR aux_nrposica AS INTE INIT 0                             NO-UNDO.
    DEF VAR aux_vlrdpeso AS INTE INIT 2                             NO-UNDO.
    DEF VAR aux_vlcalcul AS INTE INIT 0                             NO-UNDO.
    DEF VAR aux_vldresto AS INTE INIT 0                             NO-UNDO.
    DEF VAR aux_vlresult AS INTE INIT 0                             NO-UNDO.

    IF  LENGTH(STRING(par_nrcalcul)) < 3  OR
        LENGTH(STRING(par_nrcalcul)) > 12 THEN
        RETURN "OK".

    ASSIGN aux_vlcalcul = INTE(SUBSTR(STRING(par_nrcalcul,">>>>>>>>>>>>>9"),
                                      1,1)) * 2
           aux_vlresult = INTE(SUBSTR(STRING(par_nrcalcul,">>>>>>>>>>>>>9"),
                                      2,1)) +
                          INTE(SUBSTR(STRING(par_nrcalcul,">>>>>>>>>>>>>9"),
                                      4,1)) +
                          INTE(SUBSTR(STRING(par_nrcalcul,">>>>>>>>>>>>>9"),
                                      6,1)) +
                          INTE(SUBSTR(STRING(aux_vlcalcul),1,1)) +
                          INTE(SUBSTR(STRING(aux_vlcalcul),2,1))
           aux_vlcalcul = INTE(SUBSTR(STRING(par_nrcalcul,">>>>>>>>>>>>>9"),
                                      3,1)) * 2
           aux_vlresult = aux_vlresult + 
                          INTE(SUBSTR(STRING(aux_vlcalcul),1,1)) +
                          INTE(SUBSTR(STRING(aux_vlcalcul),2,1))
           aux_vlcalcul = INTE(SUBSTR(STRING(par_nrcalcul,">>>>>>>>>>>>>9"),
                                      5,1)) * 2
           aux_vlresult = aux_vlresult +
                          INTE(SUBSTR(STRING(aux_vlcalcul),1,1)) +
                          INTE(SUBSTR(STRING(aux_vlcalcul),2,1))
           aux_vlcalcul = INTE(SUBSTR(STRING(par_nrcalcul,">>>>>>>>>>>>>9"),
                                      7,1)) * 2
           aux_vlresult = aux_vlresult +
                          INTE(SUBSTR(STRING(aux_vlcalcul),1,1)) +
                          INTE(SUBSTR(STRING(aux_vlcalcul),2,1))
           aux_vldresto = aux_vlresult MODULO 10.

    IF  aux_vldresto = 0  THEN
        ASSIGN aux_nrdigit1 = aux_vldresto.
    ELSE
        ASSIGN aux_nrdigit1 = 10 - aux_vldresto.

    ASSIGN aux_vlcalcul = 0.

    DO aux_nrposica = (LENGTH(STRING(par_nrcalcul))) TO 1 BY -1:
    
        ASSIGN aux_vlcalcul = aux_vlcalcul + (INTE(SUBSTR(STRING(par_nrcalcul),
                                              aux_nrposica,1)) * aux_vlrdpeso)
               aux_vlrdpeso = aux_vlrdpeso + 1.

        IF  aux_vlrdpeso > 9  THEN
            ASSIGN aux_vlrdpeso = 2.

    END. /** Fim do DO ... TO **/

    ASSIGN aux_vldresto = aux_vlcalcul MODULO 11.

    IF  aux_vldresto < 2  THEN
        ASSIGN aux_nrdigit1 = 0.
    ELSE
        ASSIGN aux_nrdigit1 = 11 - aux_vldresto.

    ASSIGN aux_vlrdpeso = 2
           aux_nrposica = 0
           aux_vlcalcul = 0.

    par_nrcalcul = DECI(STRING(par_nrcalcul) + STRING(aux_nrdigit1)).

    DO aux_nrposica = LENGTH(STRING(par_nrcalcul)) TO 1 BY -1:

        ASSIGN aux_vlcalcul = aux_vlcalcul + (INTE(SUBSTR(STRING(par_nrcalcul),
                                              aux_nrposica,1)) * aux_vlrdpeso)
               aux_vlrdpeso = aux_vlrdpeso + 1.

        IF  aux_vlrdpeso > 9  THEN
            ASSIGN aux_vlrdpeso = 2.

    END. /** Fim do DO ... TO **/

    ASSIGN aux_vldresto = aux_vlcalcul MODULO 11.

    IF  aux_vldresto < 2  THEN
        ASSIGN aux_nrdigit2 = 0.
    ELSE
        ASSIGN aux_nrdigit2 = 11 - aux_vldresto.

    ASSIGN par_nrdigito = INTE(STRING(aux_nrdigit1) + STRING(aux_nrdigit2)).
    
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE limpa_arquivos_proces.

    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdprogra AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
                                                                       
    DEF VAR aux_nomedarq AS CHAR.
            
    ASSIGN aux_nomedarq = "compbb/*".
    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    INPUT THROUGH VALUE( "ls " + aux_nomedarq + " 2> /dev/null") NO-ECHO.
              
    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
       
       SET aux_nomedarq FORMAT "x(60)" .
         
    END. /*** Fim do DO WHILE TRUE ***/
                  
    INPUT CLOSE.
              
    /*  Verifica se o arquivo existe em disco  */
    IF  SEARCH (aux_nomedarq)  <>  ?  THEN
        DO:

           UNIX SILENT VALUE ("mv compbb/* compbbnproc 2> /dev/null").   

           UNIX SILENT VALUE ("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                              " " + STRING(TIME,"HH:MM:SS") + "' -->  '" +
                              par_cdprogra + " - " + 
                              " Existem arquivos da COMPBB para serem integrados. " +
                              " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                                             "/log/proces.log").
        END.

    UNIX SILENT VALUE ("rm controles/ArquivosBB.OK  2> /dev/null").
    UNIX SILENT VALUE ("rm controles/ArqBancoob.ok  2> /dev/null").

END PROCEDURE.


PROCEDURE dig_bbx.

  /**********************************************************************
   Procedure para calcular e conferir o digito verificador pelo modulo onze.
   Baseado no programa fontes/digbbx.p                              
  **********************************************************************/
    
    DEF        INPUT PARAM par_cdcooper AS CHAR                        NO-UNDO.
    DEF        INPUT PARAM par_cdagenci AS INTE                        NO-UNDO.
    DEF        INPUT PARAM par_nrdcaixa AS INTE                        NO-UNDO.
    DEF        INPUT PARAM par_nrcalcul AS DECI                        NO-UNDO.
    DEF       OUTPUT PARAM par_dscalcul AS CHAR                        NO-UNDO.
                                                                       
    DEF       OUTPUT PARAM TABLE FOR tt-erro.                          
                                                                       
    DEF        VAR aux_digito   AS INT     INIT 0                      NO-UNDO.
    DEF        VAR aux_posicao  AS INT     INIT 0                      NO-UNDO.
    DEF        VAR aux_peso     AS INT     INIT 9                      NO-UNDO.
    DEF        VAR aux_calculo  AS INT     INIT 0                      NO-UNDO.
    DEF        VAR aux_resto    AS INT     INIT 0                      NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    ASSIGN aux_cdcritic = 0.

    IF   LENGTH(STRING(par_nrcalcul)) < 2   OR
         LENGTH(STRING(par_nrcalcul)) > 8   THEN
         DO:
             ASSIGN aux_cdcritic = 8
                    aux_dscritic = "".   
            
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        
                 
             RETURN "NOK".
         END.

    DO  aux_posicao = (LENGTH(STRING(par_nrcalcul)) - 1) TO 1 BY -1:

        aux_calculo = aux_calculo + (INTEGER(SUBSTRING(STRING(par_nrcalcul),
                                                aux_posicao,1)) * aux_peso).

        aux_peso = aux_peso - 1.

        IF   aux_peso = 1   THEN
             aux_peso = 9.

    END.  /*  Fim do DO .. TO  */

    ASSIGN aux_resto = aux_calculo MODULO 11.

    IF   aux_resto > 9   THEN
         aux_digito = 0.
    ELSE
         aux_digito = aux_resto.
    
    IF  (INTEGER(SUBSTRING(STRING(par_nrcalcul),
                    LENGTH(STRING(par_nrcalcul)),1))) <> aux_digito   THEN
        DO:
            ASSIGN aux_cdcritic = 8
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).        
                            
            RETURN "NOK".  
        END.

    ASSIGN par_nrcalcul = DECIMAL(SUBSTRING(STRING(par_nrcalcul),1,
                                     LENGTH(STRING(par_nrcalcul)) - 1) +
                                     STRING(aux_digito)).

    /*--  Numero calculado com digito "X"  ---------------------------------------*/

    IF  aux_resto <= 9 THEN
        par_dscalcul = SUBSTR(STRING(par_nrcalcul,"99999999"),1,7) +
                                STRING(aux_digito,"9").
    ELSE
        par_dscalcul = SUBSTR(STRING(par_nrcalcul,"99999999"),1,7) + "X".               
    /*----------------------------------------------------------------------------*/ 
    /* Trata conta da CONCREDI na CEF */

    IF   par_nrcalcul = 30035007 THEN
         ASSIGN par_nrcalcul = 30035008
                par_dscalcul = "30035008".

    RETURN "OK".

END PROCEDURE.


/* Procedure baseada no fonte fontes/dig_cmc7.p */
PROCEDURE dig_cmc7:
/*
    Objetivo  : Calcular os digitos do CMC-7.
*/

    DEF INPUT  PARAM par_dsdocmc7 AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_nrdcampo AS INT                               NO-UNDO.
    DEF OUTPUT PARAM par_lsdigctr AS CHAR                              NO-UNDO.

    DEF VAR aux_nrcalcul AS DECIMAL                                    NO-UNDO.
    DEF VAR aux_nrdigito AS INT                                        NO-UNDO.
    DEF VAR aux_stsnrcal AS LOGICAL                                    NO-UNDO.

    DEF VAR aux_nrcampo1 AS INT                                        NO-UNDO.
    DEF VAR aux_nrcampo2 AS DECIMAL                                    NO-UNDO.
    DEF VAR aux_nrcampo3 AS DECIMAL                                    NO-UNDO.

    IF   LENGTH(par_dsdocmc7) <> 34   THEN
         DO:
             par_nrdcampo = 1.
             RETURN "NOK".
         END.

    /*  Conteudo do par_dsdocmc7 =  <00100950<0168086015>870000575178:  */

    ASSIGN aux_nrcampo1 = INT(SUBSTRING(par_dsdocmc7,2,8)) NO-ERROR.

    IF   ERROR-STATUS:ERROR   THEN
         DO:
             par_nrdcampo = 1.
             RETURN "NOK".
         END.

    ASSIGN aux_nrcampo2 = DECIMAL(SUBSTRING(par_dsdocmc7,11,10)) NO-ERROR.

    IF   ERROR-STATUS:ERROR   THEN
         DO:
             par_nrdcampo = 1.
             RETURN "NOK".
         END.

    ASSIGN aux_nrcampo3 = DECIMAL(SUBSTRING(par_dsdocmc7,22,12)) NO-ERROR.

    IF   ERROR-STATUS:ERROR   THEN
         DO:
             par_nrdcampo = 1.
             RETURN "NOK".
         END.

    par_nrdcampo = 0.

    DO WHILE TRUE:

       /*  Calcula o digito do terceiro campo  - DV 1  */

       aux_nrcalcul = aux_nrcampo1.

       RUN digm10 (INPUT-OUTPUT aux_nrcalcul,
                         OUTPUT aux_nrdigito,
                         OUTPUT aux_stsnrcal).

       par_lsdigctr = STRING(aux_nrdigito,"9").

       IF   aux_nrdigito <> INT(SUBSTR(STRING(aux_nrcampo3,"999999999999"),1,1)) 
            THEN
            DO:
                par_nrdcampo = 3.
                LEAVE.
            END.

       /*  Calcula o digito do primeiro campo  - DV 2  */

       aux_nrcalcul = aux_nrcampo2 * 10.

       RUN digm10 (INPUT-OUTPUT aux_nrcalcul,
                         OUTPUT aux_nrdigito,
                         OUTPUT aux_stsnrcal).

       par_lsdigctr = par_lsdigctr + "," + STRING(aux_nrdigito,"9").

       IF   aux_nrdigito <>
            INT(SUBSTR(STRING(aux_nrcampo1),LENGTH(STRING(aux_nrcampo1)),1))   THEN
            DO:
                par_nrdcampo = 1.
                LEAVE.
            END.

       /*  Calcula digito DV 3  */

       aux_nrcalcul = DECIMAL(SUBSTRING(STRING(aux_nrcampo3,"999999999999"),2,11)).

       RUN digm10 (INPUT-OUTPUT aux_nrcalcul,
                         OUTPUT aux_nrdigito,
                         OUTPUT aux_stsnrcal).

       par_lsdigctr = par_lsdigctr + "," + STRING(aux_nrdigito,"9").

       IF   NOT aux_stsnrcal   THEN
            DO:
                par_nrdcampo = 3.
                LEAVE.
            END.

       LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    IF  par_nrdcampo <> 0  THEN
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

/* Procedure baseada no fonte fontes/digm10.p */
PROCEDURE digm10:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/
/*
    Objetivo  : Calcular e conferir o digito verificador pelo modulo dez.
                (Algoritmo fornecido pelo BANCO DO BRASIL - Gerson)
*/

    DEF INPUT-OUTPUT PARAM par_nrcalcul AS DECIMAL                     NO-UNDO.
    DEF OUTPUT       PARAM par_nrdigito AS INTEGER                     NO-UNDO.
    DEF OUTPUT       PARAM par_stsnrcal AS LOGICAL                     NO-UNDO.
  
    DEF        VAR aux_digito   AS INT     INIT 0                      NO-UNDO.
    DEF        VAR aux_posicao  AS INT     INIT 0                      NO-UNDO.
    DEF        VAR aux_peso     AS INT     INIT 2                      NO-UNDO.
    DEF        VAR aux_calculo  AS INT     INIT 0                      NO-UNDO.
    DEF        VAR aux_dezena   AS INT     INIT 0                      NO-UNDO.
    DEF        VAR aux_resulta  AS INT     INIT 0                      NO-UNDO.
    
    IF   LENGTH(STRING(par_nrcalcul)) < 2   THEN
         DO:
             par_stsnrcal = FALSE.
             RETURN.
         END.
    
    DO  aux_posicao = (LENGTH(STRING(par_nrcalcul)) - 1) TO 1 BY -1:
    
        aux_resulta = (INTEGER(SUBSTRING(STRING(par_nrcalcul),
                                   aux_posicao,1)) * aux_peso).
    
        IF   aux_resulta > 9   THEN
             aux_resulta = INT(SUBSTRING(STRING(aux_resulta,'99'),1,1)) +
                           INT(SUBSTRING(STRING(aux_resulta,'99'),2,1)).
    
        ASSIGN aux_calculo = aux_calculo + aux_resulta
    
               aux_peso = aux_peso - 1.
    
        IF   aux_peso = 0   THEN
             aux_peso = 2.
    
    END.  /*  Fim do DO .. TO  */
    
    ASSIGN aux_dezena = (INT(SUBSTRING(STRING(aux_calculo,'999'),1,2)) + 1) * 10
           aux_digito = aux_dezena - aux_calculo.
    
    IF   aux_digito = 10   THEN
         aux_digito = 0.
    
    IF  (INTEGER(SUBSTRING(STRING(par_nrcalcul),
                    LENGTH(STRING(par_nrcalcul)),1))) <> aux_digito   THEN
         par_stsnrcal = FALSE.
    ELSE
         par_stsnrcal = TRUE.
    
    ASSIGN par_nrcalcul = DECIMAL(SUBSTRING(STRING(par_nrcalcul),1,
                                   LENGTH(STRING(par_nrcalcul)) - 1) +
                                  STRING(aux_digito))
    
           par_nrdigito = aux_digito.
    
    RETURN "OK".

END PROCEDURE.

/* Procedure baseada na procedure existe_conta_integracao da include 
   includes/proc_conta_integracao.i */
PROCEDURE existe_conta_integracao:

    DEF INPUT  PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_ctpsqitg AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_nrdctitg AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_nrctaass AS INTE                              NO-UNDO.
   
   IF  LENGTH(STRING(par_ctpsqitg)) <= 8 THEN
       DO:
   
          ASSIGN par_nrctaass = 0
                 par_nrdctitg = SUBSTR(STRING(par_ctpsqitg,"99999999"),1,7) +
                                SUBSTR(STRING(par_ctpsqitg,"99999999"),8,1).
 
          FIND crapass WHERE crapass.cdcooper = par_cdcooper  AND
                             crapass.nrdctitg = par_nrdctitg  
                             NO-LOCK NO-ERROR.

          IF  NOT AVAIL crapass   THEN
              DO:
                 ASSIGN par_nrdctitg = 
                        SUBSTR(STRING(par_ctpsqitg,"99999999"),1,7) + "X".
            
                 FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                                    crapass.nrdctitg = par_nrdctitg 
                                    NO-LOCK NO-ERROR.
                                     
                 IF  NOT AVAIL crapass   THEN
                     ASSIGN par_nrdctitg = "".
                 ELSE
                     ASSIGN par_nrctaass = crapass.nrdconta.
              END. 
               
          ELSE
              ASSIGN par_nrctaass = crapass.nrdconta.
         
       END.
   ELSE 
       DO:
          ASSIGN par_nrctaass = 0
                 par_nrdctitg = SUBSTR(STRING(par_ctpsqitg,"9999999999"),1,9) +
                                SUBSTR(STRING(par_ctpsqitg,"9999999999"),10,1). 

          FIND crapass WHERE crapass.cdcooper = par_cdcooper  AND
                             crapass.nrdctitg = par_nrdctitg  
                             NO-LOCK NO-ERROR.

          IF   NOT AVAIL crapass   THEN
               DO:
                  ASSIGN par_nrdctitg = 
                   SUBSTR(STRING(par_ctpsqitg,"9999999999"),1,9) + "X".
            
                  FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                     crapass.nrdctitg = par_nrdctitg 
                                     NO-LOCK NO-ERROR.
                                      
                  IF  NOT AVAIL crapass   THEN
                      ASSIGN par_nrdctitg = "".
                  ELSE
                      ASSIGN par_nrctaass = crapass.nrdconta.
               END.
          ELSE
               ASSIGN par_nrctaass = crapass.nrdconta.
         
       END.
   
   IF   par_nrdctitg      <> ""   AND
        crapass.cdtipcta < 12    AND 
        crapass.flgctitg <> 2   THEN
        DO:
            IF  crapass.flgctitg <> 3   THEN 
                ASSIGN par_nrdctitg = "".
        END.

   RETURN "OK".
        
END PROCEDURE.


/******************************************************************************
  Gerar e enviar por email o arquivo de varios controles de movimentacao 
******************************************************************************/
PROCEDURE gera-arquivo-controle:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_dtarquiv AS DATE                              NO-UNDO. 
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-crapcme.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_flgtrans         AS LOGI                              NO-UNDO.
    DEF  VAR aux_nmtitulo         AS CHAR                              NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_nmtitulo = "Controle de Movimentacao".
         
    GERACAO:
    DO WHILE TRUE:

       FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapcop   THEN
            DO:
                ASSIGN aux_cdcritic = 794.
                LEAVE.
            END.

       ASSIGN aux_flgprime = TRUE.

       FOR EACH tt-crapcme NO-LOCK: /* Para cada controle de Movimentacao */

           RUN email-controle-movimentacao 
                                        (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT par_nmdatela,
                                         INPUT par_idorigem,
                                         INPUT tt-crapcme.nrdconta,
                                         INPUT 1,
                                         INPUT par_cddopcao,
                                         INPUT tt-crapcme.rowidcme,
                                         INPUT FALSE,
                                         INPUT par_dtmvtolt,
                                         INPUT par_flgerlog,
                                        OUTPUT TABLE tt-erro).

           IF   RETURN-VALUE <> "OK"   THEN
                LEAVE GERACAO.
 
       END.

       OUTPUT STREAM str_1 CLOSE.

       /* Sem arquivos Gerados */
       IF   aux_nmarqimp = ""  THEN
            DO:
                ASSIGN aux_flgtrans = TRUE.
                LEAVE.
            END.
                  
       RUN sistema/generico/procedures/b1wgen0024.p 
           PERSISTENT SET h-b1wgen0024.
       
       /* Gerar o PDF para enviar por email */
       RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                               INPUT aux_nmarqpdf).

       DELETE PROCEDURE h-b1wgen0024.       

       RUN sistema/generico/procedures/b1wgen0011.p 
           PERSISTENT SET h-b1wgen0011.
                 
       /* Enviar por email com o anexo do PDF gerado */
       RUN enviar_email IN h-b1wgen0011 (INPUT par_cdcooper,
                                         INPUT "b1wgen9998",
                                         INPUT crapcop.dsemlcof, 
                                         INPUT aux_nmtitulo,
                                         INPUT aux_nmarquiv,
                                         INPUT TRUE).
       DELETE PROCEDURE h-b1wgen0011.
                    
       /* Remover os arquivos gerados */         
       UNIX SILENT VALUE ("rm " + aux_nmarqimp + " 2> /dev/null").  
                                      
       ASSIGN aux_flgtrans = TRUE.

       LEAVE.

    END.

    IF   NOT aux_flgtrans   THEN
         DO:
             IF   NOT TEMP-TABLE tt-erro:HAS-RECORDS   THEN
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1, /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".

         END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************
 Montar e enviar o email que trata sobre Controle de Movimentacao
******************************************************************************/
PROCEDURE email-controle-movimentacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_rowidcme AS ROWID                             NO-UNDO.
    DEF  INPUT PARAM par_flgenvia AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.


    DEF  VAR aux_dsoperac AS CHAR INIT "Deposito,Saque"                NO-UNDO.
    DEF  VAR aux_dsdopcao AS CHAR INIT "Inclusao,Alteracao,Exclusao"   NO-UNDO.
    DEF  VAR aux_dtaltera AS DATE                                      NO-UNDO.
    DEF  VAR aux_nmextcop AS CHAR                                      NO-UNDO.
    DEF  VAR aux_dsagenci AS CHAR                                      NO-UNDO.
    DEF  VAR aux_nrcpfcgc AS CHAR                                      NO-UNDO.
    DEF  VAR aux_flgpubli AS LOGI                                      NO-UNDO.
    DEF  VAR aux_dsocpttl AS CHAR                                      NO-UNDO.
    DEF  VAR aux_descrica AS CHAR                                      NO-UNDO.
    DEF  VAR aux_inpolexp AS CHAR                                      NO-UNDO.
    
    DEF  BUFFER crabass FOR crapass.
    DEF  BUFFER crabalt FOR crapalt. 


    FORM "Controle de Movimentacao" 
         aux_dsdopcao           NO-LABEL                FORMAT "x(25)"
         SKIP(2)                                        
         par_dtmvtolt     AT 23 LABEL "Data"            FORMAT "99/99/9999"   
         SKIP(1)                                        
         aux_nmextcop     AT 16 LABEL "Cooperativa"     FORMAT "x(80)" 
         aux_dsagenci     AT 24 LABEL "PA"              FORMAT "x(80)"
         SKIP(1)
         crapass.nrdconta AT 19 LABEL "Conta/dv"  
         crapcme.nrdocmto AT 18 LABEL "Documento"           
         crapcme.vllanmto AT 22 LABEL "Valor"           FORMAT "zzz,zzz,zz9.99"
         WITH SIDE-LABELS WIDTH 132 FRAME f_controle.

    FORM "Controle de Movimentacao - Nao Cooperado" 
         aux_dsdopcao           NO-LABEL                FORMAT "x(25)"
         SKIP(2)                                        
         par_dtmvtolt     AT 23 LABEL "Data"            FORMAT "99/99/9999"   
         SKIP(1)                                        
         aux_nmextcop     AT 16 LABEL "Cooperativa"     FORMAT "x(80)" 
         aux_dsagenci     AT 24 LABEL "PA"              FORMAT "x(80)"
         SKIP(1)
         aux_nrcpfcgc     AT 19 LABEL "CPF/CNPJ" FORMAT "x(18)"
         crapcme.nmpesrcb AT 23 LABEL "Nome"
         crapcme.nrdocmto AT 18 LABEL "Documento"           
         crapcme.vllanmto AT 22 LABEL "Valor"           FORMAT "zzz,zzz,zz9.99"
         WITH SIDE-LABELS WIDTH 132 FRAME f_controle_nao_cooperado.

    FORM crapcme.vlretesp AT 02 LABEL "Valor retirado em especie"
                                                        FORMAT "zzz,zzz,zz9.99"
         WITH SIDE-LABELS WIDTH 132 FRAME f_saque.

    FORM crapass.dtadmiss AT 17 LABEL "Admis.Coop" 
         crapalt.dtaltera AT 16 LABEL "Recadastmto" 
         SKIP(2)
         WITH SIDE-LABELS WIDTH 132 FRAME f_coop.

    FORM aux_descrica AT 06 LABEL "Origem do dinheiro" FORMAT "x(100)"    
         SKIP(2)
         WITH SIDE-LABELS WIDTH 132 FRAME f_orig. 

    FORM aux_descrica AT 05 LABEL "Destino do dinheiro" FORMAT "x(100)"
         SKIP(2)
         WITH SIDE-LABELS WIDTH 132 FRAME f_dest.

    FORM "Titular(es) da Conta" AT 45
         SKIP(1)
         WITH SIDE-LABELS WIDTH 132 FRAME f_tit_fis.

    FORM "Titular da Conta" AT 25
         SKIP(1)
         WITH SIDE-LABELS WIDTH 132 FRAME f_tit_jur.

    FORM crapttl.idseqttl COLUMN-LABEL "Tit."
         crapttl.nmextttl COLUMN-LABEL "Nome" FORMAT "x(40)"
         aux_nrcpfcgc     COLUMN-LABEL "CPF"  FORMAT "x(18)"
         aux_inpolexp     COLUMN-LABEL "Politicamente exposta" FORMAT "x(08)"
         aux_flgpubli     COLUMN-LABEL "Servidor Publico"      FORMAT "Sim/Nao"
         WITH DOWN WIDTH 132 FRAME f_fis.

    FORM crapjur.nmextttl COLUMN-LABEL "Nome"
         aux_nrcpfcgc     COLUMN-LABEL "CNPJ" FORMAT "x(18)"
         WITH WIDTH 132 FRAME f_jur.

    FORM SKIP(2)
         "Operacao realizada por:"
         WITH WIDTH 132 FRAME f_rea_oper_1.
 
    FORM crapcme.nrccdrcb AT 08 LABEL "Conta/dv"
         SKIP(1)
         crabass.dtadmiss AT 06 LABEL "Admis.Coop"
         SKIP(1) 
         crabalt.dtaltera AT 05 LABEL "Recadastmto"
         SKIP(1)
         WITH SIDE-LABELS WIDTH 132 FRAME f_rea_oper_2.

    FORM crapcme.nmpesrcb COLUMN-LABEL "Nome"
         aux_nrcpfcgc     COLUMN-LABEL "CPF" FORMAT "x(14)"
         WITH DOWN WIDTH 132 FRAME f_rec_f.

    FORM crapcme.nmpesrcb COLUMN-LABEL "Nome"
         aux_nrcpfcgc     COLUMN-LABEL "CNPJ" FORMAT "x(18)"
         WITH DOWN WIDTH 132 FRAME f_rec_j.

    FORM SKIP(3)
         WITH FRAME f_pula.


    IF   par_flgerlog   THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Enviar e-mail para Controle de Movimentacao.".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsocpttl = "169,319,67,309,308,271,65,306,272,273,74,305,69," + 
                          "316,209,311,303,64,310,314,313,315,307,76,75,77," +
                          "317,325,312,304".

    EMPTY TEMP-TABLE tt-erro.

    DO WHILE TRUE:

        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.


        IF   NOT AVAIL crapcop   THEN
             DO:
                 ASSIGN aux_cdcritic = 794.
                 LEAVE.
             END.

        FIND crapcme WHERE ROWID(crapcme) = par_rowidcme NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapcme   THEN
             DO:
                 ASSIGN aux_dscritic = 
                        "Controle de movimentacao nao encontrado.".
                 LEAVE.
             END.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                           crapass.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapass   THEN
             DO: 
                 FIND FIRST crapass
                      WHERE crapass.cdcooper = par_cdcooper AND
                            crapass.nrcpfcgc = crapcme.cpfcgrcb 
                            NO-LOCK NO-ERROR.                         
             END.

        IF  AVAIL crapass  THEN
            /* Nas contas administrativas nao é necessario ter o controle */
            IF   crapass.inpessoa = 3   THEN
                 RETURN "OK".
                                 
        FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper AND
                           craptab.nmsistem = "CRED"           AND
                           craptab.tptabela = "GENERI"         AND
                           craptab.cdempres = 0                AND
                           craptab.cdacesso = "VMINCTRCEN"     AND
                           craptab.tpregist = 0            
                           NO-LOCK NO-ERROR.

        IF   AVAIL craptab   THEN
             DO:
                  /* Se valor do lancamento menor que o da TAB , */ 
                           /* entao nao manda email */
                  IF   DECI(craptab.dstextab) > crapcme.vllanmto   THEN
                       RETURN "OK".
             END.

        FIND crapage WHERE crapage.cdcooper = par_cdcooper     AND
                           crapage.cdagenci = crapcme.cdagenci NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapage   THEN
             DO:
                 ASSIGN aux_cdcritic = 15.
                 LEAVE.
             END.
        
        /* Opcao: 1 - Inclusao / 2- Alteracao / 3- Exclusao */
        IF   par_cddopcao < 1 OR par_cddopcao > 3   THEN
             DO:
                 ASSIGN aux_dscritic = "Opcao nao valida para esta operacao".
                 LEAVE.
             END.

        IF   crapcme.tpoperac <> 1   AND
             crapcme.tpoperac <> 2   AND
             crapcme.tpoperac <> 3   THEN
             DO:
                 ASSIGN aux_dscritic = "Tipo de operacao invalida".
                 LEAVE.
             END.

        IF  AVAIL crapass  THEN
            /* Data de Re cadastramento */
            FIND LAST crapalt WHERE crapalt.cdcooper = par_cdcooper       AND
                                    crapalt.nrdconta = crapass.nrdconta   AND
                                    crapalt.tpaltera = 1              
                                    NO-LOCK NO-ERROR.

        ASSIGN aux_dsdopcao = "(" + ENTRY(par_cddopcao,aux_dsdopcao) + " de " + 
                              ENTRY(crapcme.tpoperac,aux_dsoperac) + ")"

               aux_nmextcop = crapcop.nmrescop + " - " + crapcop.nmextcop
            
               aux_dsagenci = STRING(crapage.cdagenci) + " - " + 
                              crapage.nmresage + " (" + crapage.nmcidade + ")"
                              NO-ERROR.            
               
        IF   par_flgenvia    OR    /* Se gera só um arquivo de controle */ 
             aux_flgprime    THEN  /* Ou se é o primeiro de varios */
             DO:
                 ASSIGN aux_nmarquiv = STRING(par_nrdconta) + "_" + 
                                       STRING(TIME)
                  
                        aux_nmarqimp = "/usr/coop/" + crapcop.dsdircop + 
                                       "/converte/" + aux_nmarquiv + ".txt" 
                                
                        aux_nmarqpdf = "/usr/coop/" + crapcop.dsdircop +
                                       "/converte/" + aux_nmarquiv + ".pdf"
                                
                        aux_nmarquiv = aux_nmarquiv + ".pdf".
                 
                 OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp) PAGED PAGE-SIZE 84.

                 ASSIGN aux_flgprime = FALSE.   

             END.

        IF  AVAIL crapass  THEN
            DISPLAY STREAM str_1 aux_dsdopcao
                                 par_dtmvtolt                                         
                                 aux_nmextcop
                                 aux_dsagenci 
                                 crapass.nrdconta 
                                 crapcme.nrdocmto
                                 crapcme.vllanmto
                                 WITH FRAME f_controle.   
        ELSE
        DO:
            IF  crapcme.inpesrcb = 1  THEN
                ASSIGN aux_nrcpfcgc = 
                    STRING(STRING(crapcme.cpfcgrcb,"zzzzzzzzzzz"),
                                                  "xxx.xxx.xxx-xx").
            ELSE
                ASSIGN aux_nrcpfcgc = 
                    STRING(STRING(crapcme.cpfcgrcb,"zzzzzzzzzzzzzz"),
                                                   "xx.xxx.xxx/xxxx-xx").
            DISPLAY STREAM str_1 aux_dsdopcao
                                par_dtmvtolt                                         
                                aux_nmextcop
                                aux_dsagenci 
                                aux_nrcpfcgc
                                crapcme.nmpesrcb
                                crapcme.nrdocmto
                                crapcme.vllanmto
                                WITH FRAME f_controle_nao_cooperado.   

        END.

        IF   crapcme.tpoperac = 2  THEN /* Saque */
             DISPLAY STREAM str_1 crapcme.vlretesp WITH FRAME f_saque.
           
        IF  AVAIL crapass  THEN
            DISPLAY STREAM str_1 crapass.dtadmiss 
                                 crapalt.dtaltera WHEN AVAIL crapalt 
                                 WITH FRAME f_coop.
       
        IF   aux_dsdopcao MATCHES "*SAQUE*"   THEN
             DO:
                 ASSIGN aux_descrica = crapcme.dstrecur.
                
                 DISPLAY STREAM str_1 aux_descrica WITH FRAME f_dest.
                                                             
             END.
        ELSE      /* Deposito */
             DO:                 
                 ASSIGN aux_descrica = crapcme.recursos.   
                                                        
                 DISPLAY STREAM str_1 aux_descrica WITH FRAME f_orig.
             END. 

        IF  AVAIL crapass  THEN
        DO:
            IF   crapass.inpessoa = 1   THEN /* Para todos os titulares */
                 DO:          
                     VIEW STREAM str_1 FRAME f_tit_fis.
    
                     FOR EACH crapttl WHERE 
                              crapttl.cdcooper = par_cdcooper   AND
                              crapttl.nrdconta = crapass.nrdconta   NO-LOCK:
                 
                         /* Verifica se é servidor publico */
                         ASSIGN aux_flgpubli = 
                             CAN-DO(aux_dsocpttl,STRING(crapttl.cdocpttl))
                             
                                aux_nrcpfcgc =
                             STRING(STRING(crapttl.nrcpfcgc,"zzzzzzzzzzz"),
                                                           "xxx.xxx.xxx-xx").
                         IF crapttl.inpolexp = 0 THEN  
                           ASSIGN aux_inpolexp = "Nao".
                         ELSE IF crapttl.inpolexp = 1 THEN
                           ASSIGN aux_inpolexp = "Sim".
                         ELSE IF  crapttl.inpolexp = 2 THEN
                           ASSIGN aux_inpolexp = "Pendente".
 
                         DISPLAY STREAM str_1 crapttl.idseqttl  
                                              crapttl.nmextttl
                                              aux_nrcpfcgc
                                              aux_inpolexp
                                              aux_flgpubli WITH FRAME f_fis.
                        
                         DOWN WITH FRAME f_fis.           
                     END.
                 END.
            ELSE     /* Pessoa Juridica */
                 DO:          
                     FIND crapjur WHERE crapjur.cdcooper = par_cdcooper   AND
                                        crapjur.nrdconta = crapass.nrdconta   
                                        NO-LOCK NO-ERROR.
    
                     IF   NOT AVAIL crapjur   THEN
                          DO:
                              ASSIGN aux_cdcritic = 821.
                              LEAVE.
                          END.
    
                     ASSIGN aux_nrcpfcgc = 
                         STRING(STRING(crapass.nrcpfcgc,"zzzzzzzzzzzzzz"),
                                                        "xx.xxx.xxx/xxxx-xx").
    
                     VIEW STREAM str_1 FRAME f_tit_jur.
    
                     DISPLAY STREAM str_1 crapjur.nmextttl
                                          aux_nrcpfcgc
                                          WITH FRAME f_jur.
    
                 END.
        END.

        VIEW STREAM str_1 FRAME f_rea_oper_1.
                 
        /* Conta que realiza o valor movimentado */
        IF   crapcme.nrccdrcb = 0   THEN
             DO:
                 IF  crapcme.inpesrcb = 1  THEN
                 DO:
                     ASSIGN aux_nrcpfcgc = 
                         STRING(STRING(crapcme.cpfcgrcb,"zzzzzzzzzzz"),
                                                       "xxx.xxx.xxx-xx").

                     DISPLAY STREAM str_1 crapcme.nmpesrcb 
                                          aux_nrcpfcgc
                                          WITH FRAME f_rec_f.

                 END.
                 ELSE
                 DO:
                     ASSIGN aux_nrcpfcgc = 
                         STRING(STRING(crapcme.cpfcgrcb,"zzzzzzzzzzzzzz"),
                                                        "xx.xxx.xxx/xxxx-xx").

                     DISPLAY STREAM str_1 crapcme.nmpesrcb 
                                          aux_nrcpfcgc
                                          WITH FRAME f_rec_j.

                 END.
             END.
        ELSE
             DO:
                 FIND crabass WHERE crabass.cdcooper = par_cdcooper   AND
                                    crabass.nrdconta = crapcme.nrccdrcb 
                                    NO-LOCK NO-ERROR.

                 IF   NOT AVAIL crabass   THEN
                      DO:
                          ASSIGN aux_cdcritic = 9.
                          LEAVE.
                      END.
                
                 /* Data de Re cadastramento */
                 FIND LAST crabalt WHERE 
                           crabalt.cdcooper = par_cdcooper       AND
                           crabalt.nrdconta = crapcme.nrccdrcb   AND
                           crabalt.tpaltera = 1              
                           NO-LOCK NO-ERROR.
                   
                 DISPLAY STREAM str_1 
                                 crapcme.nrccdrcb
                                 crabass.dtadmiss
                                 crabalt.dtaltera WHEN AVAIL crabalt 
                                 WITH FRAME f_rea_oper_2. 

                 FOR EACH crapttl WHERE 
                          crapttl.cdcooper = par_cdcooper     AND
                          crapttl.nrdconta = crapcme.nrccdrcb NO-LOCK:
                         
                     /* Verifica se é servidor publico */
                     ASSIGN aux_flgpubli = 
                        CAN-DO(aux_dsocpttl,STRING(crapttl.cdocpttl))
                          
                            aux_nrcpfcgc =
                          STRING(STRING(crapttl.nrcpfcgc,"zzzzzzzzzzz"),
                                                    "xxx.xxx.xxx-xx").
                     IF crapttl.inpolexp = 0 THEN  
                       ASSIGN aux_inpolexp = "Nao".
                     ELSE IF crapttl.inpolexp = 1 THEN
                       ASSIGN aux_inpolexp = "Sim".
                     ELSE IF  crapttl.inpolexp = 2 THEN
                       ASSIGN aux_inpolexp = "Pendente". 
                     DISPLAY STREAM str_1 crapttl.idseqttl  
                                          crapttl.nmextttl
                                          aux_nrcpfcgc
                                          aux_inpolexp
                                          aux_flgpubli 
                                          WITH FRAME f_fis.
                      
                     DOWN WITH FRAME f_fis. 

                 END.

             END.             
             
        IF   par_flgenvia   THEN /* Se gera so um arquivo , envia ... */
             DO:
                 OUTPUT STREAM str_1 CLOSE.
                 
                 RUN sistema/generico/procedures/b1wgen0024.p 
                     PERSISTENT SET h-b1wgen0024.

                 /* Gerar o PDF para enviar por email */
                 RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                                         INPUT aux_nmarqpdf).

                 
                 DELETE PROCEDURE h-b1wgen0024.                      

                 RUN sistema/generico/procedures/b1wgen0011.p 
                     PERSISTENT SET h-b1wgen0011.
                 
                 /* Enviar por email com o anexo do PDF gerado */
                 RUN enviar_email IN h-b1wgen0011
                                    (INPUT par_cdcooper,
                                     INPUT "b1wgen9998",
                                     INPUT crapcop.dsemlcof,
                                     INPUT "Controle de Movimentacao",
                                     INPUT  aux_nmarquiv,
                                     INPUT TRUE).

                 DELETE PROCEDURE h-b1wgen0011.
                 
                 /* Remover os arquivos gerados */         
                 UNIX SILENT VALUE ("rm " + aux_nmarqimp + " 2> /dev/null").              
             END.
        ELSE     /* Se mais de um arquivo , deixar espaco */
             DO:
                 VIEW STREAM str_1 FRAME f_pula.
             END.

        LEAVE.

    END.

    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic). 

             IF   par_flgerlog   THEN 
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                     OUTPUT aux_nrdrowid). 
             RETURN "NOK".
         END.

    IF   par_flgerlog THEN
         RUN proc_gerar_log (INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT "",
                             INPUT aux_dsorigem,
                             INPUT aux_dstransa,
                             INPUT TRUE,
                             INPUT par_idseqttl,
                             INPUT par_nmdatela,
                             INPUT par_nrdconta,
                            OUTPUT aux_nrdrowid).
    RETURN "OK".

END PROCEDURE.


/* Fazer o Bloqueio / Desbloqueio da tela para so um operador usar na vez */
PROCEDURE controle-operador:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmsistem AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_tptabela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cdempres AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdacesso AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_tpregist AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgtrava AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_dstextab AS CHAR                              NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_contador AS INTE                                      NO-UNDO.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.

    DO WHILE TRUE TRANSACTION:

       DO aux_contador = 1 TO 10:

          FIND craptab WHERE craptab.cdcooper = par_cdcooper    AND
                             craptab.nmsistem = par_nmsistem    AND
                             craptab.tptabela = par_tptabela    AND
                             craptab.cdempres = par_cdempres    AND
                             craptab.cdacesso = par_cdacesso    AND
                             craptab.tpregist = par_tpregist   
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF   NOT AVAIL craptab   THEN
               IF   LOCKED craptab   THEN
                    DO:
                        ASSIGN aux_cdcritic = 77.
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
               ELSE     /* Cria tabela de controle do Operador */
                    DO:
                        CREATE craptab.
                        ASSIGN craptab.cdcooper = par_cdcooper
                               craptab.nmsistem = par_nmsistem
                               craptab.tptabela = par_tptabela
                               craptab.cdempres = par_cdempres
                               craptab.cdacesso = par_cdacesso
                               craptab.tpregist = par_tpregist.
                    END.
          ELSE
               DO:
                   IF   par_flgtrava   THEN /* Se é pra Bloquear */
                        IF    craptab.dstextab <> "" THEN
                              DO:
                                  ASSIGN aux_dscritic = 
                                   "Processo sendo utilizado pelo Operador " +
                                         craptab.dstextab + ".".
                                  LEAVE.
                              END.
               END.

          ASSIGN aux_cdcritic = 0.
          LEAVE.

       END.  /* Fim DO ... TO */

       IF    aux_cdcritic <> 0    OR
             aux_dscritic <> ""   THEN
             LEAVE.

       ASSIGN craptab.dstextab = IF   (par_flgtrava)   THEN 
                                       par_dstextab
                                 ELSE 
                                      "".
       VALIDATE craptab.

       /* Tirar Lock */ 
       FIND CURRENT craptab NO-LOCK NO-ERROR.
       
       LEAVE.

    END. /* Fim Tratamento de Transaction */

    IF    aux_cdcritic <> 0    OR
          aux_dscritic <> ""   THEN
          DO:
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,            /** Sequencia **/
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).

              RETURN "NOK". 
          END.
          
    RETURN "OK".

END PROCEDURE.  


PROCEDURE valida_operador_migrado:

    DEF INPUT PARAM par_cdoperad AS CHAR         NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE         NO-UNDO.
    DEF INPUT PARAM par_cdcooper AS INTE         NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE         NO-UNDO.
                        
    DEF OUTPUT PARAM par_opmigrad AS LOGI         NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_dscritic AS CHAR                 NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dscritic = ""
           par_opmigrad = FALSE.
           
           
    FIND FIRST crapopm WHERE (crapopm.cdopenov = par_cdoperad  OR
                              crapopm.cdoperad = par_cdoperad) AND
                              crapopm.cdcopnov = 16            AND
                              crapopm.cdcooper = par_cdcooper  and
                              crapopm.flgativo
                              NO-LOCK NO-ERROR.  
                              
    IF AVAIL crapopm THEN
       DO:
          ASSIGN par_opmigrad = TRUE.
          
          FIND FIRST craptco WHERE craptco.cdcopant = par_cdcooper AND
                                   craptco.nrctaant = par_nrdconta and
                                   craptco.tpctatrf <> 3
                                   NO-LOCK NO-ERROR.
         
          IF NOT AVAIL craptco THEN
             DO:
                 RUN gera_erro (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT 0,
                                INPUT 1,          /** Sequencia **/
                                INPUT 36,
                                INPUT-OUTPUT aux_dscritic).
         
                 RETURN "NOK". 
         
             END.
             
       END.
           
    RETURN "OK".
           

END PROCEDURE.

PROCEDURE valida_restricao_operador:

    DEF  INPUT PARAM par_cdoperad AS CHAR         NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE         NO-UNDO.
    DEF  INPUT PARAM par_nrdctitg AS CHAR         NO-UNDO.
    DEF  INPUT PARAM par_cdcooper AS INTE         NO-UNDO.

    DEF OUTPUT PARAM par_dscritic AS CHAR         NO-UNDO.

    DEF VAR aux_dscritic          AS CHAR          NO-UNDO.
    
    /*************************************************************************/

    ASSIGN aux_dscritic = "Acesso Restrito: Consulte seu Gerente/Coordenador.".

    IF   par_nrdconta <> 0   AND 
         par_nrdctitg = ""   THEN
         DO:
             FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                                crapass.nrdconta = par_nrdconta   AND
                                crapass.flgrestr = TRUE
                                NO-LOCK NO-ERROR.
         END.
    ELSE 
         DO:
            IF  par_nrdctitg <> "" THEN
                FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                                   crapass.nrdctitg = par_nrdctitg   AND
                                   crapass.flgrestr = TRUE
                                   NO-LOCK NO-ERROR.
         END.

    IF  AVAIL crapass THEN
        DO: 
            FIND FIRST crapope WHERE crapope.cdcooper = par_cdcooper AND
                                     crapope.cdoperad = par_cdoperad AND
                                     crapope.flgperac = TRUE           
                                     NO-LOCK NO-ERROR.
                      
            IF NOT AVAIL crapope THEN
                DO:
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1,          /** Sequencia **/
                                   INPUT 0,
                                   INPUT-OUTPUT aux_dscritic).
                
                    ASSIGN par_dscritic = aux_dscritic.
                                                 
                    RETURN "NOK". 
                END.
                   
        END.

        RETURN "OK".

END PROCEDURE.

/* trazer número ouvidoria e SAC */
PROCEDURE obtem-sac-ouvidoria-coop:

    DEF  INPUT  PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  OUTPUT PARAM par_nrtelsac AS CHAR                              NO-UNDO.
    DEF  OUTPUT PARAM par_nrtelouv AS CHAR                              NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.

    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                             NO-LOCK NO-ERROR NO-WAIT.

    IF  NOT AVAIL crapcop THEN
        ASSIGN aux_cdcritic = 794
               aux_dscritic = "".
    ELSE
        ASSIGN par_nrtelsac = crapcop.nrtelsac
               par_nrtelouv = crapcop.nrtelouv.

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK". 
        END.
          
    RETURN "OK".

END PROCEDURE.  

/* ..........................................................................*/



