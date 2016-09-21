/* ............................................................................
   Programa: sistema/internet/fontes/InternetBank35.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Novembro/2007.                   Ultima atualizacao:   /  /
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Cancelar cadastro do novo plano de capital na Internet.
   
   Alteracoes: 
   
               03/11/2008 - Inclusao widget-pool (martin)
 
 ............................................................................ */
 
create widget-pool.
 
    
{ sistema/generico/includes/b1wgen0021tt.i }
{ sistema/generico/includes/var_internet.i }
DEF VAR h-b1wgen0021 AS HANDLE                                         NO-UNDO.
DEF  INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_idseqttl AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_vlprepla AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_flgpagto AS LOGI                                  NO-UNDO.
DEF  INPUT PARAM par_qtpremax AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dtdpagto AS DATE                                  NO-UNDO.
    
RUN sistema/generico/procedures/b1wgen0021.p PERSISTENT 
    SET h-b1wgen0021.
IF  VALID-HANDLE(h-b1wgen0021)  THEN
    DO: 
        RUN cancela-criacao-plano IN h-b1wgen0021 
                                       (INPUT par_cdcooper,
                                        INPUT "996",          /** Operador **/
                                        INPUT "INTERNETBANK", /** Tela     **/
                                        INPUT 3,              /** Origem   **/ 
                                        INPUT par_nrdconta,
                                        INPUT par_idseqttl,
                                        INPUT par_vlprepla,
                                        INPUT par_flgpagto,
                                        INPUT par_qtpremax,
                                        INPUT par_dtdpagto).
     
        DELETE PROCEDURE h-b1wgen0021.
        RETURN "OK".
    END.
