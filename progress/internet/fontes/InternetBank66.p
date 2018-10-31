/*..............................................................................

    Programa: sistema/internet/fontes/InternetBank66.p
    Sistema : Internet - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jorge
    Data    : Abril/2011                   Ultima atualizacao: 22/10/2018
  
    Dados referentes ao programa:
  
    Frequencia: Sempre que for chamado (On-Line)
    Objetivo  : Comandar Instruções Bancárias para Títulos - Cob. Registrada
    
    Alteracoes: 31/05/2011 - Adicionado verificacao de operacao ao carregar
                             Passado horario de operacao para XML (Jorge).
                        
                22/06/2011 - Adicionado parametro de XML idesthor no retorno de
                            <LIMITE> e verificao caso seja cob. reg. (Jorge).
                            
                14/07/2011 - Retirado duplicidade de codigo da linha 49 - 65
                             (Jorge).
                             
                26/12/2011 - Utilizar data do dia - crapdat.dtmvtocd (Rafael).
                
                10/01/2012 - Incluido rotina de geracao de log. (Rafael)
                
                04/07/2012 - Tratamento do cdoperad "operador" de INTE para CHAR.
                             (Lucas R.)
                             
                25/04/2013 - Adicionado cdocorre 7 e 8, add param de entrada
                             par_vldescto. (Jorge)    
                             
                10/06/2013 - Ajustado log de conceder/cancelar descto. (Rafael)
                
                12/07/2013 - Nao verificar horario de operacao para o comando
                             de instrucoes. O Controle do horário ficará agora 
                             com a b1wgen0088. (Rafael)
                             
                28/08/2013 - Incluso o parametro tt-lat-consolidada nas procedures
                             de instrucao (inst-) e incluso a include b1wgen0010tt.i
                             (Daniel)
                             
                05/11/2013 - Incluso chamada para a procedure efetua-lancamento-tarifas-lat
                             (Daniel)  
                             
                28/04/2015 - Ajustes referente Projeto Cooperativa Emite e Expede 
                             (Daniel/Rafael/Reinert)   

                04/02/2016 - Ajuste Projeto Negativação Serasa (Daniel)   
                                 
                13/10/2016 - Inclusao opcao 95 e 96, para Enviar e cancelar
                             SMS de vencimento. PRJ319 - SMS Cobranca (Odirlei-AMcom)

                04/05/2018 - Inclusao de parametro qtdiaprt referente a quantidade de dias 
                             para protesto automatico - instrução 80. PRJ352 - Protesto (Supero)
                                 
                01/06/2018 - Incluir parametro com o numero de celular do sacado para ser
                             processado na instruçao 95. PRJ. 285 - Nova Conta Online (Douglas)

			    18/06/2018 - Excluido parametro qtdiaprt pois só será utilizado no novo IB
				             pelo SOA. (PRJ352 - Protesto - Rafael)
                             
                22/10/2018 - Incluir parametro par_inavisms na chamada do IB66 (Lucas Ranghetti INC0025087)
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgen0010tt.i }
{ sistema/generico/includes/var_oracle.i }

DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapcob.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_nrcnvcob LIKE crapcre.nrcnvcob                    NO-UNDO.
DEF  INPUT PARAM par_nrdocmto LIKE craprem.nrdocmto                    NO-UNDO.
DEF  INPUT PARAM par_cdocorre LIKE craprem.cdocorre                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_cdoperad AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_dtvencto AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_vlabatim AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_cdtpinsc AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_vldescto AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_inavisms AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrcelsac AS DECI                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF VAR h-b1wgen0088 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0015 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0090 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO. 
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO. 

/* sistema deve atribuir data do dia vindo da crapdat
   Rafael Cechet - 06/04/2011 */
FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

IF  AVAILABLE crapdat  THEN
    ASSIGN par_dtmvtolt = crapdat.dtmvtocd.
    
{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    

RUN STORED-PROCEDURE pc_InternetBank66
    aux_handproc = PROC-HANDLE NO-ERROR
                            (INPUT par_cdcooper,
                             INPUT par_nrdconta,
                             INPUT par_nrcnvcob,
                             INPUT par_nrdocmto,
                             INPUT par_cdocorre,
                             INPUT par_dtmvtolt,
                             INPUT par_cdoperad,
                             INPUT 0,    /* par_nrremass */
                             INPUT par_vlabatim,
                             INPUT par_dtvencto,
                             INPUT par_vldescto,
                             INPUT par_cdtpinsc,
                             INPUT par_nrcelsac,
                             INPUT 0, /* qtdiaprt */
                             INPUT par_inavisms,
                             OUTPUT xml_dsmsgerr,
                             OUTPUT 0,   /* pr_cdcritic */
                             OUTPUT ""). /* pr_dscritic */

CLOSE STORED-PROC pc_InternetBank66
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_cdcritic = 0
       aux_dscritic = ""
       aux_cdcritic = pc_InternetBank66.pr_cdcritic 
                          WHEN pc_InternetBank66.pr_cdcritic <> ?
       aux_dscritic = pc_InternetBank66.pr_dscritic
                          WHEN pc_InternetBank66.pr_dscritic <> ?. 

    IF aux_dscritic <> "" THEN
      ASSIGN xml_dsmsgerr = aux_dscritic.  

    RUN pi_gera_log (INPUT "InternetBank66").


IF  xml_dsmsgerr <> ""  THEN
    DO:                                                             
        ASSIGN  aux_dscritic = xml_dsmsgerr
                xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  

        RETURN "NOK".
    END.

RETURN "OK".

PROCEDURE pi_gera_log:
    DEF INPUT PARAM par_dscritic AS CHAR                NO-UNDO.

    DEF VAR aux_nrdrowid AS ROWID                       NO-UNDO.

    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT "996",
                        INPUT "Convenio: " + 
                              STRING(par_nrcnvcob, "9999999") + 
                              " - Doc: " + 
                              STRING(par_nrdocmto, "999999999"),
                        INPUT "INTERNET",
                        INPUT par_dscritic,
                        INPUT TRUE,
                        INPUT par_idseqttl,
                        INPUT "INTERNETBANK",
                        INPUT par_nrdconta,
                       OUTPUT aux_nrdrowid).

    RETURN "OK".
END.
/*............................................................................*/
