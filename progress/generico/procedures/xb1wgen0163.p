
/*............................................................................

     Programa: sistema/generico/procedures/xb1wgen0163.p
     Autor   : Jéssica (DB1)
     Data    : 30/07/2013                    Ultima atualizacao: 00/00/0000

     Objetivo  : BO de Comunicacao XML x BO - Tela ESTOUR

     Alteracoes: 

............................................................................*/



/*..........................................................................*/

DEF VAR aux_cdcooper AS INTE                                         NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                         NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                         NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                         NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                         NO-UNDO.
DEF VAR aux_idorigem AS INTE                                         NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                         NO-UNDO.
DEF VAR aux_flgerlog AS LOGI                                         NO-UNDO.
DEF VAR aux_msgauxil AS CHAR                                         NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                         NO-UNDO.
DEF VAR aux_qtddtdev AS INTE                                         NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                         NO-UNDO.
DEF VAR aux_nrregist AS INTE                                         NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                         NO-UNDO.
DEF VAR aux_qtregist AS INTE                                         NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0163tt.i }

/*............................... PROCEDURES ................................*/
 PROCEDURE valores_entrada:

     FOR EACH tt-param:

         CASE tt-param.nomeCampo:

             WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
             WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
             WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
             WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
             WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
             WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
             WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
             WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
             WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
                              
         END CASE.

     END. /** Fim do FOR EACH tt-param **/


 END PROCEDURE. /* valores_entrada */


/* ------------------------------------------------------------------------ */
/*                       EFETUA A PESQUISA DE REMESSA                       */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:            
    
    RUN Busca_Dados IN hBO
                  ( INPUT aux_cdcooper,   
                    INPUT aux_cdagenci,                    
                    INPUT aux_nrdcaixa,                    
                    INPUT aux_cdoperad,                    
                    INPUT aux_nmdatela,                    
                    INPUT aux_idorigem,                                 
                    INPUT aux_nrdconta,                    
                    INPUT TRUE, /* flgerlog */
                    INPUT aux_nrregist,
                    INPUT aux_nriniseq,
                   OUTPUT aux_msgauxil,
                   OUTPUT aux_nmprimtl,
                   OUTPUT aux_qtddtdev,
                   OUTPUT aux_nmdcampo,
                   OUTPUT aux_qtregist,
                   OUTPUT TABLE tt-estour,                 
                   OUTPUT TABLE tt-erro). 

                                                           
    IF  RETURN-VALUE = "NOK" THEN                          
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-estour:HANDLE,
                            INPUT "Dados").
           RUN piXmlAtributo (INPUT "msgauxil",INPUT aux_msgauxil).
           RUN piXmlAtributo (INPUT "nmprimtl",INPUT aux_nmprimtl).
           RUN piXmlAtributo (INPUT "qtddtdev",INPUT aux_qtddtdev).
           RUN piXmlAtributo (INPUT "qtregist",INPUT aux_qtregist).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Dados */

