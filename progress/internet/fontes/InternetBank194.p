/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank194.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ricardo Linhares
   Data    : Julho/2017.                       Ultima atualizacao:
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Detalhe Comprovante
   
   Alteracoes: 
..............................................................................*/
 
CREATE WIDGET-POOL.
 
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_xml_operacao AS LONGCHAR NO-UNDO.
DEF VAR aux_iteracoes    AS INT      NO-UNDO.
DEF VAR aux_posini       AS INT      NO-UNDO.
DEF VAR aux_contador     AS INT      NO-UNDO.
DEF VAR aux_dsstatus     AS CHAR     NO-UNDO.

DEF VAR  aux_cdcooper  LIKE crappro.cdcooper NO-UNDO.
DEF VAR  aux_nrdconta  LIKE crappro.nrdconta NO-UNDO.
DEF VAR  aux_dsprotoc  LIKE crappro.dsprotoc NO-UNDO.
DEF VAR  aux_dtmvtolt  AS DATE               NO-UNDO.
DEF VAR  aux_cdorigem  AS INTEGER            NO-UNDO.

DEF INPUT  PARAM par_cdcooper  LIKE crappro.cdcooper NO-UNDO.
DEF INPUT  PARAM par_nrdconta  LIKE crappro.nrdconta NO-UNDO.
DEF INPUT  PARAM par_dsprotoc  LIKE crappro.dsprotoc NO-UNDO.
DEF INPUT  PARAM par_cdorigem  AS INTEGER            NO-UNDO.
DEF INPUT  PARAM par_cdtippro  AS INTEGER            NO-UNDO.
DEF OUTPUT PARAM par_dsmsgerr  AS CHAR               NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

FUNCTION roundUp RETURNS INTEGER ( x as decimal ):
  IF x = TRUNCATE( x, 0 ) THEN
    RETURN INTEGER( x ).
  ELSE
    RETURN INTEGER(TRUNCATE( x, 0 ) + 1 ).
END.

  ASSIGN aux_cdcooper = par_cdcooper
         aux_nrdconta = par_nrdconta
         aux_dsprotoc = par_dsprotoc
         aux_cdorigem = par_cdorigem.
  
/* Procedimento do internetbank operacao 194 */
{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl}}

  RUN STORED-PROCEDURE pc_detalhe_comprovante
        aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper
                                           ,INPUT par_nrdconta
                                           ,INPUT par_cdtippro
                                           ,INPUT par_dsprotoc
                                           ,INPUT par_cdorigem
                                           ,OUTPUT ""   /* Retorno XML*/
                                           ,OUTPUT ""). /* Retorno de critica (OK ou NOK) */

    IF  ERROR-STATUS:ERROR  THEN DO:

        DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
            ASSIGN aux_msgerora = aux_msgerora + ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
        END.
              
        ASSIGN par_dsmsgerr = '<Root><Erro>' + aux_msgerora + '</Erro></Root>'.
        RETURN "NOK".
          
    END. 

    CLOSE STORED-PROC pc_detalhe_comprovante
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
        
    /* Status da Chamada (OK / NOK) */
    ASSIGN aux_dsstatus     = pc_detalhe_comprovante.pr_dsretorn
           aux_xml_operacao = pc_detalhe_comprovante.pr_retxml.        
   
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl}}

 /* Atribuir xml de retorno a temptable */ 
IF  aux_xml_operacao <> "" THEN
    DO:
        ASSIGN aux_iteracoes = roundUp(LENGTH(aux_xml_operacao) / 31000)
               aux_posini    = 1.    

        DO  aux_contador = 1 TO aux_iteracoes:
        
            CREATE xml_operacao.
            ASSIGN xml_operacao.dslinxml = SUBSTRING(aux_xml_operacao, aux_posini, 31000)
                   aux_posini            = aux_posini + 31000.
                   
        END.
    END.

IF aux_dsstatus = "OK" THEN
  RETURN "OK".
ELSE
  RETURN "NOK".
  



    
