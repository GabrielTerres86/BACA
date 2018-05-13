/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank89.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano
   Data    : Julho/2014.                       Ultima atualizacao: 02/06/2015
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Valida se existe saldo disponivel para realizar a aplicacao
               e se o valor esta dentro o limite (internet) parametrizado
               na cooperativa.
   
   Alteracoes: 27/08/2014 - Adicionar parametro "A" - Aplicação, na chamada da 
                            procedure pc_valida_limite_internet.
                            (Douglas - Projeto Captação Internet 2014/2)
                            
               16/09/2014 - Adicionado condicao de verificacao de saldo disponivel
                            apenas quando cooperativa for diferente de 3.
                            (Jorge/Gielow - SD 185491)             

               02/06/2015 - Ajustado a pc_obtem_saldo_dia_sd_wt para saber o dia
                            que deve ser utilizado na busca do saldo na crapsda
                            (Douglas - Chamado 285228 - obtem-saldo-dia)
..............................................................................*/

{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                     NO-UNDO.
DEF INPUT PARAM par_cdagenci LIKE crapage.cdagenci                     NO-UNDO.
DEF INPUT PARAM par_nrdcaixa AS INT                                    NO-UNDO.
DEF INPUT PARAM par_cdoperad LIKE crapope.cdoperad                     NO-UNDO.
DEF INPUT PARAM par_nmdatela AS CHAR                                   NO-UNDO.
DEF INPUT PARAM par_idorigem AS INT                                    NO-UNDO.
DEF INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                     NO-UNDO.
DEF INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                     NO-UNDO.
DEF INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                     NO-UNDO.
DEF INPUT PARAM par_vlaplica LIKE craprda.vlaplica                     NO-UNDO.
DEF INPUT PARAM par_vllimcre LIKE crapass.vllimcre                     NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.


{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

/* Utilizar o tipo de busca A, para carregar do dia anterior
  (U=Nao usa data, I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1) */ 
RUN STORED-PROCEDURE pc_obtem_saldo_dia_sd_wt
    aux_handproc = PROC-HANDLE NO-ERROR
                            (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT par_cdoperad, 
                             INPUT par_nrdconta,
                             INPUT par_vllimcre,
                             INPUT "A", /* Tipo Busca */
                             OUTPUT 0,
                             OUTPUT "").

CLOSE STORED-PROC pc_obtem_saldo_dia_sd_wt 
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_cdcritic = 0
       aux_dscritic = ""
       aux_cdcritic = pc_obtem_saldo_dia_sd_wt.pr_cdcritic 
                          WHEN pc_obtem_saldo_dia_sd_wt.pr_cdcritic <> ?
       aux_dscritic = pc_obtem_saldo_dia_sd_wt.pr_dscritic
                          WHEN pc_obtem_saldo_dia_sd_wt.pr_dscritic <> ?. 

IF aux_cdcritic <> 0   OR
   aux_dscritic <> ""  THEN
   DO: 
       IF aux_dscritic = "" THEN
          DO:
             FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                                NO-LOCK NO-ERROR.
             
             IF AVAIL crapcri THEN
                ASSIGN aux_dscritic = crapcri.dscritic.
             ELSE
                ASSIGN aux_dscritic =  "Nao foi possivel consultar " +
                                       "o saldo para a operacao.".

          END.

       ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                             "</dsmsgerr>".  

       RETURN "NOK".
       
   END.

FIND FIRST wt_saldos NO-LOCK NO-ERROR.

IF NOT AVAIL wt_saldos THEN
   DO:
      ASSIGN aux_dscritic =  "Nao foi possivel consultar " +
                             "o saldo para a operacao."
             xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                            "</dsmsgerr>".                                                              
      RETURN "NOK".

   END.

IF  par_cdcooper <> 3 AND 
   (par_vlaplica > (wt_saldos.vlsddisp + wt_saldos.vllimcre)) THEN
   DO:
      ASSIGN aux_dscritic =  "Saldo CC insuficiente para a operacao.".
             xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                            "</dsmsgerr>".                                                              
      RETURN "NOK".

   END.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

RUN STORED-PROCEDURE pc_valida_limite_internet
    aux_handproc = PROC-HANDLE NO-ERROR
                            (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT par_cdoperad,
                             INPUT par_nmdatela,
                             INPUT par_idorigem,
                             INPUT par_nrdconta,
                             INPUT par_idseqttl,
                             INPUT par_vlaplica,
                             INPUT "A", /* Tipo de Movimentação "A" - Aplicação */
                             OUTPUT 0,
                             OUTPUT "").

CLOSE STORED-PROC pc_valida_limite_internet 
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_cdcritic = 0
       aux_dscritic = ""
       aux_cdcritic = pc_valida_limite_internet.pr_cdcritic 
                          WHEN pc_valida_limite_internet.pr_cdcritic <> ?
       aux_dscritic = pc_valida_limite_internet.pr_dscritic
                          WHEN pc_valida_limite_internet.pr_dscritic <> ?. 

IF aux_cdcritic <> 0   OR
   aux_dscritic <> ""  THEN
   DO:
       IF aux_dscritic = "" THEN
          DO:
             FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                                NO-LOCK NO-ERROR.
             
             IF AVAIL crapcri THEN
                ASSIGN aux_dscritic = crapcri.dscritic.
             ELSE
                ASSIGN aux_dscritic =  "Nao foi possivel validar o limite de " +
                                       "internet.".

          END.

       ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                             "</dsmsgerr>".  

       RETURN "NOK".

   END.

RETURN "OK".

/*............................................................................*/
