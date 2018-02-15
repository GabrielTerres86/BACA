/* .........................................................................

   Programa: xb1wgen0025.p
   Autor   : Mateus Zimmermann (Mouts)
   Data    : Dezembro/2017                    Ultima Atualizacao: 
   
   Dados referentes ao programa:
   
   Objetivo  : BO de Comunicacao XML vs BO de Funcoes em comum (b1wgen0025.p).
              
   Alteracoes:          

..........................................................................*/

DEF VAR aux_cdcooper   AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta   AS INTE                                           NO-UNDO.
DEF VAR aux_nrcrcard   AS CHAR                                           NO-UNDO.
DEF VAR aux_idtipcar   AS INTE                                           NO-UNDO.
DEF VAR aux_dssencar   AS CHAR                                           NO-UNDO.
DEF VAR aux_infocry    AS CHAR                                           NO-UNDO.
DEF VAR aux_chvcry     AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcritic   AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic   AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0025tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }


/* .........................PROCEDURES................................... */


/**************************************************************************
       Procedure para atribuicao dos dados de entrada enviados por XML
**************************************************************************/

PROCEDURE valores_entrada:

    FOR EACH tt-param NO-LOCK:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "nrcrcard" THEN aux_nrcrcard = tt-param.valorCampo.
            WHEN "idtipcar" THEN aux_idtipcar = INTE(tt-param.valorCampo).
            WHEN "dssencar" THEN aux_dssencar = tt-param.valorCampo.
            WHEN "infocry"  THEN aux_infocry  = tt-param.valorCampo.
            WHEN "chvcry"   THEN aux_chvcry   = tt-param.valorCampo.

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.


/******************************************************************************
  Validar dados antes de listar os contratos que foram enviados para a sede. 
 (Tela IMPROP)
******************************************************************************/

PROCEDURE valida_senha_tp_cartao:
                                            
    RUN valida_senha_tp_cartao IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_nrdconta,
                                       INPUT aux_nrcrcard,
                                       INPUT aux_idtipcar,
                                       INPUT aux_dssencar,
                                       INPUT aux_infocry,
                                       INPUT aux_chvcry,
                                       OUTPUT aux_cdcritic,
                                       OUTPUT aux_dscritic).
     
    IF   RETURN-VALUE = "NOK"  THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
             IF  NOT AVAILABLE tt-erro  THEN
                 DO:
                     CREATE tt-erro.
                     ASSIGN tt-erro.dscritic = aux_dscritic.
                 END.
                 
             RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
         END.
    ELSE  
         DO:
             RUN piXmlNew.
             RUN piXmlSave.
         END.

END PROCEDURE.


/* ......................................................................*/
