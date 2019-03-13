/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +-----------------------------------+---------------------------------------+
  | Rotina Progress                   | Rotina Oracle PLSQL                   |
  +-----------------------------------+---------------------------------------+
  | InternetBank22.p                  | PAGA0002.pc_InternetBank22            |
  +-----------------------------------+---------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank22.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Abril/2007.                       Ultima atualizacao: 12/04/2018
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Verificar e executar transferencia via Internet.
   
   Alteracoes: 08/08/2007 - Trocadas procedures da BO b1wgen00015.p e retornar
                            a mensagem de pagamento com sucesso (Evandro).
   
               09/10/2007 - Gerar log com data TODAY e nao dtmvtolt (David).
               
               27/11/2007 - Incluir parametros no metodo (David).
               
               06/02/2008 - Incluir parametro no metodo executa transferencia
                            (David).
               
               23/04/2008 - Adaptacao para agendamentos (David).
   
               03/11/2008 - Inclusao widget-pool (martin)

               28/07/2009 - Alteracoes do Projeto de Transferencia para 
                            Credito de Salario (David).
                            
               31/03/2011 - Ajustes devido agendamento no TAA (Henrique).
               
               13/04/2011 - Inclusao de parametros na procedure 
                            executa transferencia (Henrique)
                            
               05/08/2011 - Inclusao de parametro na executa transferencia
                            (Gabriel).         
                            
               05/10/2011 - Adaptacao operadores internet (Guilherme).
               
               09/01/2012 - Adicionado parametro idtitdda de entrada na 
                            chamada da proc. cadastrar agendamento. (Jorge)
                            
               11/05/2012 - Projeto TED Internet (David).
                            
               04/03/2013 - Projeto transferencia intercooperativa (Gabriel).
               
               22/07/2013 - Ajustes transferencia intercooperativa (Lucas).
               
               18/08/2014 - Inlusao do Parametro par_dshistor (Vanessa)
               
               04/11/2014 - (Chamado 161844)- Liberacao de agendamentos
                            para dia nao util. (Tiago Castro - RKAM)
                            
               17/12/2014 - Melhorias Cadastro de Favorecidos TED
                           (André Santos - SUPERO)
                            
               20/04/2015 - Inclusão do campo ISPB SD271603 FDR041 (Vanessa)             
               
               17/07/2015 - Inclusão regra para mudar a data de agendamento
                            para o primeiro dia útil após a data programada.
                            Projeto Mobile (Dionathan)
                            
               28/07/2015 - Adição de parâmetro flmobile para indicar que a origem
                            da chamada é do mobile (Dionathan)
			   
               05/08/2015 - Adicionar parametro idtitdda na chamada da procedure
                            cria_transacao_operador da b1wgen0016. 
                            (Douglas - Chamado 291387)
               
               11/06/2015 - Adaptaçao fonte hibrido Progress -> Oracle 
                            SD285179 (Odirlei-AMcom) 

               28/03/2016 - Inclusao do parametro par_iptransa
			                PRJ118 (Odirlei-AMcom)
                                         
               12/06/2017 - Tratamento para Novo Catalgo do SPB (Lucas Ranghetti #668207)
               
               09/04/2018 - Ajuste para que o caixa eletronico possa utilizar o mesmo
                            servico da conta online (PRJ 363 - Rafael Muniz Monteiro)

               12/04/2018 - Inclusao de novos campo para realizaçao 
                              de analise de fraude. 
                              PRJ381 - AntiFraude (Odirlei-AMcom)
                              
               16/02/2019 - Ajuste variável aux_nrrecid para DECI - Paulo Martins - Mouts                              
..............................................................................*/
 
CREATE WIDGET-POOL.
 
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0015tt.i }
{ sistema/generico/includes/var_oracle.i }


DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
def var aux_nrrecid  AS DECI                                           NO-UNDO.

DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dstrans1 AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dslinxml AS CHAR                                           NO-UNDO.
DEF VAR aux_lsdatagd AS CHAR                                           NO-UNDO.
DEF VAR aux_nrctatrf AS CHAR                                           NO-UNDO.
DEF VAR aux_msgaviso AS CHAR                                           NO-UNDO.
DEF VAR aux_dsprotoc AS CHAR                                           NO-UNDO.

DEF VAR aux_nrdoccre AS DECI                                           NO-UNDO.
DEF VAR aux_nrdocdeb AS DECI                                           NO-UNDO.
DEF VAR aux_nrdocmto AS DECI                                           NO-UNDO.

DEF VAR aux_cdhiscre AS INTE                                           NO-UNDO.
DEF VAR aux_cdhisdeb AS INTE                                           NO-UNDO.

DEF VAR aux_cdlantar LIKE craplat.cdlantar                             NO-UNDO.
DEF VAR aux_xml_operacao22 AS LONGCHAR                                 NO-UNDO.
DEF VAR aux_dsretorn AS CHAR                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nmrescop LIKE crapcop.nmrescop                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE craplcm.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF  INPUT PARAM par_tpoperac AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdtiptra AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cddbanco LIKE crapcti.cddbanco                    NO-UNDO.
DEF  INPUT PARAM par_cdispbif LIKE crapcti.nrispbif                    NO-UNDO.
DEF  INPUT PARAM par_cdageban LIKE crapcti.cdageban                    NO-UNDO.
DEF  INPUT PARAM par_nrctatrf LIKE crapcti.nrctatrf                    NO-UNDO.
DEF  INPUT PARAM par_nmtitula LIKE crapcti.nmtitula                    NO-UNDO.
DEF  INPUT PARAM par_nrcpfcgc LIKE crapcti.nrcpfcgc                    NO-UNDO.
DEF  INPUT PARAM par_inpessoa LIKE crapcti.inpessoa                    NO-UNDO.
DEF  INPUT PARAM par_intipcta LIKE crapcti.intipcta                    NO-UNDO.
DEF  INPUT PARAM par_idagenda AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dtmvtopg LIKE craplau.dtmvtopg                    NO-UNDO.
DEF  INPUT PARAM par_vllanmto LIKE craplcm.vllanmto                    NO-UNDO.
DEF  INPUT PARAM par_cdfinali AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dstransf AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_ddagenda AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_qtmesagd AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dtinicio AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_lsdatagd AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_flgexecu AS LOGI                                  NO-UNDO.
DEF  INPUT PARAM par_gravafav AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dshistor AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_flmobile AS LOGI                                  NO-UNDO.
DEF  INPUT PARAM par_iptransa AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_iddispos AS CHAR                                  NO-UNDO.
/* Projeto 363 - Novo ATM */
DEF  INPUT PARAM par_cdorigem AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dsorigem AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_cdagenci AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdcaixa AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nmprogra AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_cdcoptfn AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdagetfn AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrterfin AS INTE                                  NO-UNDO.
/* Projeto 363 - Novo ATM */

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.
    
ASSIGN aux_dstransa = (IF par_flgexecu     THEN "" ELSE "Valida ")           +
                      (IF par_idagenda = 1 THEN "" ELSE "Agendamento para ") + 
                      (IF par_tpoperac = 4 THEN
                          "Transferencia de TED"
                       ELSE
                          "Transferencia de Valores").

  /* Procedimento do internetbank operaçao 22 - Validar/efetuar transferencia */
  { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
  RUN STORED-PROCEDURE pc_InternetBank22
      aux_handproc = PROC-HANDLE NO-ERROR      
        (INPUT  par_cdcooper           /* --> Codigo da cooperativa         */
        ,INPUT  par_nmrescop           /* --> Nome da cooperativa           */
        ,INPUT  par_nrdconta           /* --> Numero da conta               */
        ,INPUT  par_idseqttl           /* --> Sequencial titular            */
        ,INPUT  par_nrcpfope           /* --> CPF do operador juridico      */
        ,INPUT  par_dtmvtolt           /* --> Data de movimento             */
        ,INPUT  par_tpoperac           /* --> Tipo de opracao               */
        ,INPUT  par_cdtiptra           /* --> Tipo de transacao             */
        ,INPUT  par_cddbanco           /* --> Codigo do banco               */
        ,INPUT  par_cdispbif           /* --> Numero inscriçao SPB          */
        ,INPUT  par_cdageban           /* --> codigo da agencia bancaria.   */
        ,INPUT  STRING(par_nrctatrf)   /* --> conta que recebe a transferenc*/
        ,INPUT  par_nmtitula           /* --> nome do titular da conta.     */
        ,INPUT  par_nrcpfcgc           /* --> cpf/cnpj do titular da conta. */ 
        ,INPUT  par_inpessoa           /* --> tipo de pessoa da conta.      */
        ,INPUT  par_intipcta           /* --> tipo da conta.                */
        ,INPUT  par_idagenda           /* --> Identificador de agendamento  */
        ,INPUT  par_dtmvtopg           /* --> Data do pagamento             */
        ,INPUT  par_vllanmto           /* --> Valor do lançamento           */
        ,INPUT  par_cdfinali           /* --> Codigo de finalidade          */
        ,INPUT  par_dstransf           /* --> Descricao da transferencia    */
        ,INPUT  par_ddagenda           /* --> Dia do agendamento            */
        ,INPUT  par_qtmesagd           /* --> Qtd de mes agendamento        */
        ,INPUT  par_dtinicio           /* --> data inicio                   */
        ,INPUT  par_lsdatagd           /* --> lista de datas agendamento    */
        ,INPUT  INT(par_flgexecu)      /* --> 1-TRUE 0-FALSE                */
        ,INPUT  INT(par_gravafav)      /* --> Grava favorecido 1-TRUE,0-FALS*/
        ,INPUT  par_dshistor           /* --> codifo do historico           */
        ,INPUT  INT(par_flmobile)      /* --> Indicativo de operacao mobile */
        ,INPUT  par_iptransa           /* --> IP da transacao  IBank/mobile */
        ,INPUT  par_iddispos           /* --> ID Dispositivo mobile         */
        ,INPUT  par_cdorigem           /* --> Código da Origem */
        ,INPUT  par_dsorigem           /* --> Descriçao da Origem */
        ,INPUT  par_cdagenci           /* --> Agencia */
        ,INPUT  par_nrdcaixa           /* --> Caixa */
        ,INPUT  par_nmprogra           /* --> Nome do programa */
        ,INPUT  par_cdcoptfn           /* --> Cooperativa do Terminal */
        ,INPUT  par_cdagetfn           /* --> Agencia do Terminal */
        ,INPUT  par_nrterfin           /* --> Numero do Terminal */
        ,OUTPUT ""                     /* --> Retorno XML de critica        */
        ,OUTPUT ""                     /* --> Retorno XML da operaçao 26    */
        ,OUTPUT "" ).                  /* --> Retorno de critica (OK ou NOK)*/
                                                                           

  IF  ERROR-STATUS:ERROR  THEN DO:
      DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
          ASSIGN aux_msgerora = aux_msgerora + 
                                ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
      END.
          
      ASSIGN aux_dscritic = "pc_InternetBank22 --> "  +
                            "Erro ao executar Stored Procedure: " +
                            aux_msgerora.
      
      ASSIGN xml_dsmsgerr = "<dsmsgerr>" + 
                                 "Erro inesperado. Nao foi possivel efetuar a transferencia." + 
                                 " Tente novamente ou contacte seu PA" +
                            "</dsmsgerr>".
                        
      RUN proc_geracao_log(INPUT par_dsorigem,
                           INPUT par_nmprogra).
      RETURN "NOK".
      
  END. 

  CLOSE STORED-PROC pc_InternetBank22
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

  { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl}}


  ASSIGN aux_dsretorn       = ""
         xml_dsmsgerr       = ""
         aux_xml_operacao22 = ""
         aux_dsretorn = pc_InternetBank22.pr_dsretorn 
                        WHEN pc_InternetBank22.pr_dsretorn <> ?
         xml_dsmsgerr = pc_InternetBank22.pr_xml_dsmsgerr 
                        WHEN pc_InternetBank22.pr_xml_dsmsgerr <> ?
         aux_xml_operacao22 = pc_InternetBank22.pr_xml_operacao22 
                              WHEN pc_InternetBank22.pr_xml_operacao22 <> ?               .

  /* Verificar se retornou critica */
  IF aux_dsretorn = "NOK" THEN
     RETURN "NOK".
   
  /* Atribuir xml de retorno a temptable*/ 
  IF aux_xml_operacao22 <> "" THEN
  DO:
    CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = aux_xml_operacao22. 
  END.  
  
  RETURN "OK".

/*................................ PROCEDURES ................................*/

PROCEDURE proc_geracao_log:
    
    DEF  INPUT PARAM par_dsorigem AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmprogra AS CHAR                              NO-UNDO.
    
    DEF  VAR aux_dsorigem         AS CHAR                              NO-UNDO.
    
    /* Gerar log(CRAPLGM) - Rotina Oracle */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_gera_log_prog
        aux_handproc = PROC-HANDLE NO-ERROR
        (INPUT par_cdcooper    /* pr_cdcooper */
        ,INPUT "996"           /* pr_cdoperad */
        ,INPUT aux_dscritic    /* pr_dscritic */
        ,INPUT par_dsorigem    /*  Projeto 363 - Novo ATM -> estava fixo "INTERNET"*/      /* pr_dsorigem */
        ,INPUT aux_dstransa    /* pr_dstransa */
        ,INPUT aux_datdodia    /* pr_dttransa */
        ,INPUT 0 /* Operacao sem sucesso */ /* pr_flgtrans */
        ,INPUT TIME            /* pr_hrtransa */
        ,INPUT par_idseqttl    /* pr_idseqttl */
        ,INPUT par_nmprogra    /*  Projeto 363 - Novo ATM -> estava fixo "INTERNETBANK"*/  /* pr_nmdatela */
        ,INPUT par_nrdconta    /* pr_nrdconta */
        ,OUTPUT 0 ). /* pr_nrrecid  */

    IF  ERROR-STATUS:ERROR  THEN DO:
        DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
            ASSIGN aux_msgerora = aux_msgerora + 
                                  ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
        END.
            
        ASSIGN aux_dscritic = "InternetBank26.pc_gera_log_prog ' --> '"  +
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
                              

     IF par_flmobile THEN
         ASSIGN aux_dsorigem = "MOBILE".
     ELSE 
         ASSIGN aux_dsorigem = par_nmprogra.
                              
     /* Gerar log item (CRAPLGI) - Rotina Oracle */
     { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
     RUN STORED-PROCEDURE pc_gera_log_item_prog
         aux_handproc = PROC-HANDLE NO-ERROR
            (INPUT aux_nrrecid,
             INPUT "Origem",
             INPUT "",
             INPUT par_nmprogra).                         
     CLOSE STORED-PROC pc_gera_log_item_prog
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

     { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl}}
     
    
END PROCEDURE.

/*............................................................................*/




