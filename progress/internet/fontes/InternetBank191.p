/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank191.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David Giovanni Kistner
   Data    : Abril/2017.                     Ultima atualizacao:
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Solicitaçao de Empréstimo
   
   Alteracoes: 
..............................................................................*/
 
CREATE WIDGET-POOL.
 
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapass.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dsdemail AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_vlemprst AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_qtparcel AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dsmensag AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_idorigem AS INTE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgsai  AS CHAR                                 NO-UNDO.

DEF VAR aux_dsmsgsai AS CHAR                                           NO-UNDO.
DEF VAR aux_flgderro AS CHAR                                           NO-UNDO.

/* Verificar se conta possui configuracao de boleto */
{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_solicitar_emprestimo
      aux_handproc = PROC-HANDLE NO-ERROR
                              (INPUT par_cdcooper,     /* pr_cdcooper     */ 
                               INPUT 90,               /* pr_cdagenci     */
                               INPUT 900,              /* pr_nrdcaixa     */
                               INPUT "996",            /* Operador do IB  */
                               INPUT par_idorigem,     /* pr_cddcanal     */ 
                               INPUT par_nrdconta,     /* pr_nrdconta     */
                               INPUT par_idseqttl,     /* pr_idseqttl     */
                               INPUT par_dsdemail,     /* pr_dsdemail     */
                               INPUT par_qtparcel,     /* pr_qtparcel     */
                               INPUT par_vlemprst,     /* pr_vlemprst     */
                               INPUT par_dsmensag,     /* pr_dsmensag     */
                               OUTPUT "",              /* pr_flgderro     */
                               OUTPUT "").             /* pr_dsmsgsai     */

CLOSE STORED-PROC pc_solicitar_emprestimo
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_flgderro = ""
       aux_dsmsgsai = ""
       aux_flgderro = pc_solicitar_emprestimo.pr_flgderro
                      WHEN pc_solicitar_emprestimo.pr_flgderro <> ?
       aux_dsmsgsai = pc_solicitar_emprestimo.pr_dsmsgsai
                      WHEN pc_solicitar_emprestimo.pr_dsmsgsai <> ?.

IF  aux_flgderro = "NOK"  THEN
    DO:
        xml_dsmsgsai = "<dsmsgerr>" + aux_dsmsgsai + "</dsmsgerr>".  
        RETURN "NOK".
    END.
ELSE
    DO:
        xml_dsmsgsai = "<dsmsgsuc>" + aux_dsmsgsai + "</dsmsgsuc>".
        RETURN "OK".
    END.
