/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank195.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ricardo Linhares
   Data    : Julho/2017.                       Ultima atualizacao:
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Listar Agendamentos
   
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

DEF INPUT PARAM par_cdcooper  LIKE crapcop.cdcooper NO-UNDO.
DEF INPUT PARAM par_nrdconta  LIKE crapass.nrdconta NO-UNDO.
DEF INPUT PARAM par_dsorigem  AS CHAR               NO-UNDO.
DEF INPUT PARAM par_dtageini  AS DATE               NO-UNDO.
DEF INPUT PARAM par_dtagefim  AS DATE               NO-UNDO.
DEF INPUT PARAM par_insitlau  LIKE craplau.insitlau NO-UNDO.
DEF INPUT PARAM par_iniconta  AS INTEGER            NO-UNDO.
DEF INPUT PARAM par_nrregist  AS INTEGER            NO-UNDO.
DEF INPUT PARAM par_cdtipmod  AS INTEGER            NO-UNDO.
DEF OUTPUT PARAM par_dsmsgerr AS CHAR               NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

FUNCTION roundUp RETURNS INTEGER ( x as decimal ):
  IF x = TRUNCATE( x, 0 ) THEN
    RETURN INTEGER( x ).
  ELSE
    RETURN INTEGER(TRUNCATE( x, 0 ) + 1 ).
END.

/* Procedimento do internetbank operacao 195 */
{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_lista_agendamentos
    aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper
                                       ,INPUT par_nrdconta
                                       ,INPUT par_dsorigem
                                       ,INPUT par_dtageini
                                       ,INPUT par_dtagefim
                                       ,INPUT par_insitlau
                                       ,INPUT par_iniconta
                                       ,INPUT par_nrregist
                                       ,INPUT par_cdtipmod
                                      ,OUTPUT ""        /* Retorno XML*/
                                      ,OUTPUT "").      /* Retorno de critica (OK ou NOK) */
                                                                           

IF  ERROR-STATUS:ERROR  THEN DO:

    DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
        ASSIGN aux_msgerora = aux_msgerora + ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
    END.
          
    ASSIGN par_dsmsgerr = '<Root><Erro>' + aux_msgerora + '</Erro></Root>'.
    RETURN "NOK".
      
END. 

CLOSE STORED-PROC pc_lista_agendamentos
		aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl}}

/* Status da Chamada (OK / NOK) */
ASSIGN aux_dsstatus     = pc_lista_agendamentos.pr_dsretorn
       aux_xml_operacao = pc_lista_agendamentos.pr_retxml.
   
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


    
