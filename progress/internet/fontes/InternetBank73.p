/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +-----------------------------------+---------------------------------------+
  | Rotina Progress                   | Rotina Oracle PLSQL                   |
  +-----------------------------------+---------------------------------------+
  | InternetBank73.p                  | INET0002.pc_busca_trans_pend          |
  +-----------------------------------+---------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank73.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Outubro/2011                        Ultima atualizacao: 08/01/2016

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Transacoes pendentes dos operadores de internet
   
   Alteracoes: 10/05/2012 - Projeto TED Internet (David).
   
               23/07/2013 - Projeto Transferencia Intercooperativa (David).

               17/07/2014 - Adicionado validacao para identificar se existem transacoes 
                            que serao atualizadas, pois excederam dia/horario para 
                            aprovacao. (Douglas - Chamado 178989)
                            
               03/11/2014 - Implementacao de paginacao em Transacoes Pendentes.
                            (Jorge/Elton - SD 197579)             

               23/09/2015 - Incluir validacao de valor nulo do xml para os campos
                            aux_dscedent, aux_dslindig e aux_dscodbar.
                            (Lucas Ranghetti #333078)
                            
               08/01/2016 - Convertido a rotina para rotina Oracle, juntamente com 
                            ajustes do Proj. 131 Assinatura Multipla. (Jorge/David)
                            
               16/02/2019 - Ajuste variável aux_nrrecid para DECI - Paulo Martins - Mouts                            
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/internet/includes/b1wnet0002tt.i }
{ sistema/generico/includes/var_oracle.i }

DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_idseqttl AS INTE        NO-UNDO.
DEFINE INPUT  PARAMETER par_nrcpfope AS DECIMAL     NO-UNDO.
DEFINE INPUT  PARAMETER par_cpfopelg AS DECIMAL     NO-UNDO.
DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_cdtransa LIKE tbgen_trans_pend.cdtransacao_pendente NO-UNDO.
DEFINE INPUT  PARAMETER par_insittra AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER par_dtiniper AS DATE        NO-UNDO.
DEFINE INPUT  PARAMETER par_dtfimper AS DATE        NO-UNDO.
DEFINE INPUT  PARAMETER par_nrregist AS INTE        NO-UNDO.
DEFINE INPUT  PARAMETER par_nriniseq AS INTE        NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr   AS CHAR                                NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
def var aux_nrrecid  AS DECI                                           NO-UNDO.
DEF VAR aux_xml_operacao73 AS LONGCHAR                                 NO-UNDO.
DEF VAR aux_nrletini AS INTE                                           NO-UNDO.
DEF VAR aux_nrletmax AS INTE                                           NO-UNDO.
DEF VAR aux_nrlettot AS INTE                                           NO-UNDO.
DEF VAR aux_dsxmlcon AS CHAR                                           NO-UNDO.

ASSIGN aux_dstransa = "Buscar Transacoes Pendentes cadastradas pelos operadores da conta.".

/* Procedimento do internetbank operaçao 73 - Buscar Tramsacoes Pendentes  */
{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_busca_trans_pend
      aux_handproc = PROC-HANDLE NO-ERROR      
        (INPUT  par_cdcooper          /* --> Codigo da cooperativa         */
        ,INPUT  par_nrdconta          /* --> Numero da conta               */
        ,INPUT  par_idseqttl          /* --> Sequencial titular            */
        ,INPUT  par_nrcpfope          /* --> CPF do operador juridico      */
        ,INPUT  par_cdagenci          /* --> Codigo do PA                  */
        ,INPUT  par_dtmvtolt          /* --> Data de movimento             */
        ,INPUT  par_idorigem          /* --> Id da origem                  */
        ,INPUT  par_cdtransa          /* --> Código da transaçao pendente  */
        ,INPUT  par_insittra          /* --> Id situacao da transacao      */
        ,INPUT  par_dtiniper          /* --> Data inicio do periodo        */
        ,INPUT  par_dtfimper          /* --> Data fim do periodo           */
        ,INPUT  par_nrregist          /* --> Numero de registro por pagina */
        ,INPUT  par_nriniseq          /* --> Numero de registro inicial pag*/
        ,OUTPUT ""                    /* --> Retorno XML da operacao       */
        ,OUTPUT 0                     /* --> Retorno d codigo critica      */
        ,OUTPUT "" ).                 /* --> Retorno de descricao critica  */
                                                                           

IF  ERROR-STATUS:ERROR  THEN 
DO:
    DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
      ASSIGN aux_msgerora = aux_msgerora + ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
    END.
              
    ASSIGN aux_dscritic = "INET0002.pc_busca_trans_pend --> "  +
                          "Erro ao executar Stored Procedure: " +
                          aux_msgerora.
    
    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + 
                             "Erro inesperado. Nao foi possivel efetuar a transacao." + 
                             " Tente novamente ou contacte seu PA" +
                        "</dsmsgerr>".
    
    RUN proc_geracao_log.
    
    RETURN "NOK".
END.

CLOSE STORED-PROC pc_busca_trans_pend
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl}}


ASSIGN aux_cdcritic       = 0
       aux_dscritic       = ""
       aux_xml_operacao73 = ""
       aux_cdcritic = pc_busca_trans_pend.pr_cdcritic 
                        WHEN  pc_busca_trans_pend.pr_cdcritic <> ?
       aux_dscritic = pc_busca_trans_pend.pr_dscritic
                        WHEN  pc_busca_trans_pend.pr_dscritic <> ?
       aux_xml_operacao73 = pc_busca_trans_pend.pr_clobxmlc
                        WHEN  pc_busca_trans_pend.pr_clobxmlc <> ?.

/* Verificar se retornou critica */
IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
DO:
  IF aux_dscritic = "" THEN
     aux_dscritic = "INET0002.pc_busca_trans_pend --> "  +
                    "Erro ao executar Stored Procedure.".

  ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
  RUN proc_geracao_log.
  RETURN "NOK".
END.

/* Atribuir xml de retorno a temptable*/ 
IF aux_xml_operacao73 <> "" THEN
DO:
    aux_nrletini = 1.
    aux_nrletmax = 30000. /* tamanho suportado por um campo tipo CHAR */
    aux_nrlettot = aux_nrletmax.
    
    DO WHILE TRUE:
        aux_dsxmlcon = SUBSTR(aux_xml_operacao73,aux_nrletini,aux_nrletmax).
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = aux_dsxmlcon.
        
        IF LENGTH(SUBSTR(aux_xml_operacao73,(aux_nrlettot + 1))) > 0 THEN
        DO:
            aux_nrletini = aux_nrlettot + 1.
            aux_nrlettot = aux_nrlettot + aux_nrletmax.
            NEXT.
        END.
        ELSE
            LEAVE.
    END.
END.  

RETURN "OK".


/*................................ PROCEDURES ................................*/

PROCEDURE proc_geracao_log:
    
    /* Gerar log(CRAPLGM) - Rotina Oracle */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_gera_log_prog
        aux_handproc = PROC-HANDLE NO-ERROR
        (INPUT par_cdcooper    /* pr_cdcooper */
        ,INPUT "996"           /* pr_cdoperad */
        ,INPUT aux_dscritic    /* pr_dscritic */
        ,INPUT "INTERNET"      /* pr_dsorigem */
        ,INPUT aux_dstransa    /* pr_dstransa */
        ,INPUT aux_datdodia    /* pr_dttransa */
        ,INPUT 0 /* Operacao sem sucesso */ /* pr_flgtrans */
        ,INPUT TIME            /* pr_hrtransa */
        ,INPUT par_idseqttl    /* pr_idseqttl */
        ,INPUT "INTERNETBANK"  /* pr_nmdatela */
        ,INPUT par_nrdconta    /* pr_nrdconta */
        ,OUTPUT 0 ). /* pr_nrrecid  */



    IF  ERROR-STATUS:ERROR  THEN DO:
        DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
            ASSIGN aux_msgerora = aux_msgerora + 
                                  ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
        END.
            
        ASSIGN aux_dscritic = "InternetBank73.pc_gera_log_prog ' --> '"  +
                              "Erro ao executar Stored Procedure: '" +
                              aux_msgerora.
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + aux_dscritic +  "' >> log/proc_batch.log").
        
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
        
    END. 
    
    CLOSE STORED-PROC pc_gera_log_prog
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl}}
    
    
     ASSIGN aux_nrrecid = pc_gera_log_prog.pr_nrrecid
                              WHEN pc_gera_log_prog.pr_nrrecid <> ?.       
                              
                              
     /* Gerar log item (CRAPLGI) - Rotina Oracle */
     { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
     RUN STORED-PROCEDURE pc_gera_log_item_prog
         aux_handproc = PROC-HANDLE NO-ERROR
            (INPUT aux_nrrecid,
             INPUT "Origem",
             INPUT "",
             INPUT "INTERNETBANK").                         
     CLOSE STORED-PROC pc_gera_log_item_prog
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

     { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl}}
         
END PROCEDURE.


/*............................................................................*/
