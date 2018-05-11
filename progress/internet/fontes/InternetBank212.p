/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank212.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Douglas Quisinski
   Data    : Agosto/2017                       Ultima atualizacao:   /  /    
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Cancelar o agendamento de pagamento dos titulos agendados por 
               arquivo 
               
   Observacao: Os agendamentos que foram selecionados em tela devem ser separados por "|"
               Os dados de cada agendamento devem ser separados por ";"
               EXEMPLO:
                   "nrconven1;intipmvt1;nrremret1;nrseqarq1|
                    nrconven2;intipmvt2;nrremret2;nrseqarq2"

   Alteracoes: 
..............................................................................*/
 
CREATE WIDGET-POOL.
 
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }

DEF  INPUT PARAM par_cdcooper  AS INTE                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta  AS INTE                  NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt  AS DATE                  NO-UNDO.
DEF  INPUT PARAM par_dsagdcan  AS LONGCHAR              NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr  AS CHAR                  NO-UNDO.

/* Dados de cada agendamento */ 
DEF    VAR       aux_dsagenda  AS CHAR                  NO-UNDO.
DEF    VAR       aux_nrconven  AS INTE                  NO-UNDO.
DEF    VAR       aux_intipmvt  AS INTE                  NO-UNDO.
DEF    VAR       aux_nrremret  AS INTE                  NO-UNDO.
DEF    VAR       aux_nrseqarq  AS INTE                  NO-UNDO.

/* Total de agendamentos para cancelar */
DEF    VAR       aux_qtagdcan  AS INTE                  NO-UNDO.
DEF    VAR       aux_contador  AS INTE                  NO-UNDO.

/* Controle de Sequenciais */ 
DEF    VAR       aux_nrseqarq_new AS INTE               NO-UNDO.
DEF    VAR       aux_nrremret_new AS INTE               NO-UNDO.

DEF    VAR       aux_dscritic  AS CHAR                  NO-UNDO.
DEF    VAR       aux_dserros   AS CHAR                  NO-UNDO.

/* inicializar o numero da remessa */
ASSIGN aux_nrremret_new = 0.       
/* Quantidade de boletos */
ASSIGN aux_qtagdcan = NUM-ENTRIES(par_dsagdcan,"|").

/* Percorrer todas os boletos e gerar o log informando que não foi possivel 
   enviá-lo por e-mail */
DO aux_contador = 1 TO aux_qtagdcan:
    
    ASSIGN aux_dsagenda = ENTRY(aux_contador,par_dsagdcan,"|")
           aux_nrconven = INTE(ENTRY(1,aux_dsagenda,";"))
           aux_intipmvt = INTE(ENTRY(2,aux_dsagenda,";"))
           aux_nrremret = INTE(ENTRY(3,aux_dsagenda,";"))
           aux_nrseqarq = INTE(ENTRY(4,aux_dsagenda,";")).
        

    /* Cancelar Agendamento de Pagamento */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_canc_agd_pgto_tit_car
        aux_handproc = PROC-HANDLE NO-ERROR
                      (INPUT par_cdcooper,  /* Cooperativa */
                       INPUT par_nrdconta,  /* Conta */
                       INPUT aux_nrconven,  /* Numero do convenio */
                       INPUT STRING(par_dtmvtolt, "99/99/9999"),  /* Data */
                       INPUT "996",         /* Nome do OPERADOR */
                       INPUT 3,             /* Origem: Internet Bank */
                       /*Dados para identificar o agendamento que esta sendo cancelado*/
                       INPUT aux_intipmvt,  /* Tipo de Movimento */
                       INPUT aux_nrremret,  /* Numero de Remessa */
                       INPUT aux_nrseqarq,  /* Sequencia do agendamento no arquivo */
                       /* Novo Numero de sequencia - Utilizar o contador para isso */
                       INPUT aux_nrremret_new, /* Numero de Remessa de Retorno que geramos */
                       INPUT aux_contador,  /* Sequencia do agendamento no arquivo */
                      OUTPUT 0,   /* Numero do Arquivo de Retorno */
                      OUTPUT 0,   /* Código da crítica */
                      OUTPUT ""). /* Descricao da critica */

    CLOSE STORED-PROC pc_canc_agd_pgto_tit_car
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_dscritic = ""
           aux_nrremret_new = pc_canc_agd_pgto_tit_car.pr_nrremret_out
                              WHEN pc_canc_agd_pgto_tit_car.pr_nrremret_out <> ?
           aux_dscritic = pc_canc_agd_pgto_tit_car.pr_dscritic
                          WHEN pc_canc_agd_pgto_tit_car.pr_dscritic <> ?.

    IF aux_dscritic <> "" THEN
    DO:
        ASSIGN aux_dserros = aux_dserros + 
                             " Convenio: " + STRING(aux_nrconven) + 
                             " Tipo Mov: " + STRING(aux_intipmvt) + 
                             " Nr Ret: "   + STRING(aux_nrremret) + 
                             " Seq Arq: "  + STRING(aux_nrseqarq) + 
                             " - "     + aux_dscritic.
    END.

END.


IF aux_dserros <> "" THEN
DO:
    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dserros + 
                          "</dsmsgerr>".
    RETURN "NOK".
END.

RETURN "OK".
