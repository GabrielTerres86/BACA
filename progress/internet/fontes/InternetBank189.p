/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank189.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odirlei Busana - AMcom
   Data    : Outubro/2016.                       Ultima atualizacao:
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Servi�o de SMS de cobran�a
   
   Alteracoes: 
..............................................................................*/
 
CREATE WIDGET-POOL.
 
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR h-b1wgen0014        AS HANDLE                                    NO-UNDO.

DEF VAR aux_dscritic        AS CHAR                                      NO-UNDO.
DEF VAR aux_cdcritic        AS INT                                       NO-UNDO.
DEF VAR aux_dstransa        AS CHAR                                      NO-UNDO.
DEF VAR aux_dsretorn        AS CHAR                                      NO-UNDO.
DEF VAR aux_dsmsgini        AS LONGCHAR                                  NO-UNDO.
DEF VAR aux_nrdrowid        AS ROWID                                     NO-UNDO.
DEF VAR aux_iteracoes       AS INT                                       NO-UNDO.
DEF VAR aux_posini          AS INT                                       NO-UNDO.
DEF VAR aux_contador        AS INT                                       NO-UNDO.
DEF VAR aux_flsitsms        AS INT                                       NO-UNDO.
DEF VAR aux_dsalerta        AS CHAR                                      NO-UNDO.
DEF VAR aux_nmprintl        AS CHAR                                      NO-UNDO.
DEF VAR aux_nmfansia        AS CHAR                                      NO-UNDO.
DEF VAR aux_tpnmemis        AS INT                                       NO-UNDO.
DEF VAR aux_nmemisms        AS CHAR                                      NO-UNDO.
DEF VAR aux_flgativo        AS INT                                       NO-UNDO.
DEF VAR aux_dspacote        AS CHAR                                      NO-UNDO.
DEF VAR aux_dhadesao        AS DATE                                      NO-UNDO.
DEF VAR aux_idcontra        AS INT                                       NO-UNDO.
DEF VAR aux_vltarifa        AS DEC                                       NO-UNDO.
DEF VAR aux_flposcob        AS INT                                       NO-UNDO.
DEF VAR aux_idcontrato      AS INT                                       NO-UNDO.
DEF VAR aux_nmarqpdf        AS CHAR                                      NO-UNDO.

DEF INPUT  PARAM  par_cdcooper  LIKE crapcop.cdcooper                     NO-UNDO.
DEF INPUT  PARAM  par_nrdconta  LIKE crapass.nrdconta                     NO-UNDO.
DEF INPUT  PARAM  par_idseqttl  LIKE crapttl.idseqttl                     NO-UNDO.
DEF INPUT  PARAM  par_nrcpfope  LIKE crapopi.nrcpfope                     NO-UNDO.
DEF INPUT  PARAM  par_cddopcao  AS CHAR                                   NO-UNDO.
DEF INPUT  PARAM  par_idcontrato AS INT                                   NO-UNDO.
DEF INPUT  PARAM  par_tpnommis  AS INT                                    NO-UNDO.
DEF INPUT  PARAM  par_nmemisms  AS CHAR                                   NO-UNDO.

DEF OUTPUT PARAM  xml_dsmsgerr  AS CHAR                                   NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

FUNCTION roundUp RETURNS INTEGER ( x as decimal ):
  IF x = TRUNCATE( x, 0 ) THEN
    RETURN INTEGER( x ).
  ELSE
    RETURN INTEGER(TRUNCATE( x, 0 ) + 1 ).
END.

IF par_cddopcao = "V"  THEN
aux_dstransa = 'Verificar Servico SMS Cobranca'.
ELSE IF par_cddopcao = "C"  THEN
aux_dstransa = 'Carregar dados Servico SMS Cobranca'.
ELSE IF par_cddopcao = "A"  THEN
aux_dstransa = 'Ativar Servico de SMS Cobranca'.
ELSE IF par_cddopcao = "AR"  THEN
aux_dstransa = 'Alterar remetente de SMS Cobranca'.
ELSE IF par_cddopcao = "CA"  THEN
aux_dstransa = 'Cancelar Servico de SMS Cobranca'.
ELSE IF par_cddopcao = "IC"  THEN
aux_dstransa = 'Imprimir contrato de Servico SMS Cobranca'.

/* Alterar remetente */
IF par_cddopcao = "AR" THEN
  DO:
      /* Verificar se conta possui configuracao de boleto */
      { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    

      RUN STORED-PROCEDURE pc_atualizar_remetente_sms
          aux_handproc = PROC-HANDLE NO-ERROR
                                  (INPUT par_cdcooper,
                                   INPUT par_nrdconta,
                                   INPUT par_idcontrato,
                                   INPUT-OUTPUT par_tpnommis, /* par_tpnome_emissao */ 
                                   INPUT-OUTPUT par_nmemisms, /* par_nmemissao_sms */ 
                                   OUTPUT "").                /* par_dscritic */

      CLOSE STORED-PROC pc_atualizar_remetente_sms
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

      { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

      ASSIGN aux_dscritic = ""
             aux_dscritic = pc_atualizar_remetente_sms.pr_dscritic
                            WHEN pc_atualizar_remetente_sms.pr_dscritic <> ?.

      IF aux_dscritic <> "" THEN
      DO:
          xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
          RETURN "NOK".
      END. 
  END.
/* Cancelamento contrato */
ELSE IF par_cddopcao = "CA" THEN
  DO:
      /* Cancelar contrato de servico de SMS de cobranca */
      { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    

      RUN STORED-PROCEDURE pc_cancel_contrato_sms
          aux_handproc = PROC-HANDLE NO-ERROR
                                  ( INPUT par_cdcooper     /* pr_cdcooper  */
                                   ,INPUT par_nrdconta     /* pr_nrdconta  */
                                   ,INPUT par_idseqttl     /* pr_idseqttl  */
                                   ,INPUT par_idcontrato   /* pr_idcontrato*/
                                   ,INPUT 3                /* pr_idorigem  */
                                   ,INPUT '996'            /* pr_cdoperad  */
                                   ,INPUT 'INTERNETBANK'   /* pr_nmdatela  */
                                   ,INPUT par_nrcpfope     /* pr_nrcpfope  */
                                   ,INPUT 0                /* pr_inaprpen */
                                  ,OUTPUT ""               /* pr_dsretorn */
                                  ,OUTPUT 0
                                  ,OUTPUT "").             /* par_dscritic */

      CLOSE STORED-PROC pc_cancel_contrato_sms
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

      { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

      ASSIGN aux_dscritic = ""
             aux_dsretorn = ""
             aux_dsretorn = pc_cancel_contrato_sms.pr_dsretorn
                            WHEN pc_cancel_contrato_sms.pr_dsretorn <> ?
             aux_dscritic = pc_cancel_contrato_sms.pr_dscritic
                            WHEN pc_cancel_contrato_sms.pr_dscritic <> ?.

      IF aux_dscritic <> "" THEN
      DO:
          xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
          RETURN "NOK".
      END. 
      
      CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = '<dados><dsretorn>' + aux_dsretorn + 
                                     '</dsretorn></dados>'.
      
  END.
/* Ativar Contrato */
ELSE IF par_cddopcao = "A" THEN
  DO:
      /* Rotina para gera�ao do contrato de SMS */
      { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    

      RUN STORED-PROCEDURE pc_gera_contrato_sms
          aux_handproc = PROC-HANDLE NO-ERROR
                                  ( INPUT par_cdcooper     /* pr_cdcooper  */
                                   ,INPUT par_nrdconta     /* pr_nrdconta  */ 
                                   ,INPUT par_idseqttl     /* pr_idseqttl  */
                                   ,INPUT 3                /* pr_idorigem  */
                                   ,INPUT '996'            /* pr_cdoperad  */
                                   ,INPUT 'INTERNETBANK'   /* pr_nmdatela  */
                                   ,INPUT par_nrcpfope     /* pr_nrcpfope  */
                                   ,INPUT 0                /* pr_inaprpen */
                                  ,OUTPUT 0                /* pr_idcontrato */
                                  ,OUTPUT ""               /* pr_dsretorn */ 
                                  ,OUTPUT 0
                                  ,OUTPUT "").             /* par_dscritic */

      CLOSE STORED-PROC pc_gera_contrato_sms
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

      { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

      ASSIGN aux_dscritic = ""
             aux_dsretorn = ""
             aux_dsretorn = pc_gera_contrato_sms.pr_dsretorn
                            WHEN pc_gera_contrato_sms.pr_dsretorn <> ?
             aux_dscritic = pc_gera_contrato_sms.pr_dscritic
                            WHEN pc_gera_contrato_sms.pr_dscritic <> ?.

      IF aux_dscritic <> "" THEN
      DO:
          xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
          RETURN "NOK".
      END. 
      
      CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = '<dados><dsretorn>' + aux_dsretorn + 
                                     '</dsretorn></dados>'.
      
  END.

/* Impressao de Contrato */
ELSE IF par_cddopcao = "IC" THEN
  DO:
    /* Rotina para gera�ao da impressao do contrato de SMS */
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    

    RUN STORED-PROCEDURE pc_imprim_contrato_sms
        aux_handproc = PROC-HANDLE NO-ERROR
                                ( INPUT par_cdcooper     /* pr_cdcooper  */
                                 ,INPUT par_nrdconta     /* pr_nrdconta  */ 
                                 ,INPUT par_idcontrato   /* pr_idcontrato  */
                                 ,INPUT 3                /* pr_idorigem  */
                                 ,INPUT '996'            /* pr_cdoperad  */
                                 ,INPUT 'INTERNETBANK'   /* pr_nmdatela  */
                                 ,STRING(par_nrdconta) + "IB"   /* pr_dsiduser */
                                ,OUTPUT ""               /* pr_nmarqpdf */
                                ,OUTPUT 0
                                ,OUTPUT "").             /* par_dscritic */

    CLOSE STORED-PROC pc_imprim_contrato_sms
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_dscritic = ""
           aux_nmarqpdf = ""
           aux_dscritic = pc_imprim_contrato_sms.pr_dscritic
                          WHEN pc_imprim_contrato_sms.pr_dscritic <> ?
           aux_nmarqpdf = pc_imprim_contrato_sms.pr_nmarqpdf
                          WHEN pc_imprim_contrato_sms.pr_nmarqpdf <> ?.

    IF aux_dscritic <> "" THEN
    DO:
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
        RETURN "NOK".
    END.
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = '<dados><nmarqpdf>' + aux_nmarqpdf + 
                                   '</nmarqpdf></dados>'.
    
  END.

/* Verificar servico de SMS para o cooperado */
ELSE IF par_cddopcao = "V" THEN
  DO:   
  
    aux_flposcob = 0.
    /* Verificar se cooperado possui cobranca */
    FIND FIRST crapceb 
         WHERE crapceb.cdcooper = par_cdcooper
           AND crapceb.nrdconta = par_nrdconta
           AND crapceb.insitceb = 1.
    IF AVAILABLE crapceb THEN       
      DO:
        aux_flposcob = 1.
      END.
      
    /* Buscar descri�ao para tela inicial */
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_buscar_mensagem
        aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper /* par_cdcooper */     
                                           ,INPUT 19           /* pr_cdproduto  */
                                           ,INPUT 16           /* pr_cdtipo_mensagem */
                                           ,INPUT 0            /* pr_sms        */      
                                           ,INPUT ?            /* pr_valores_dinamicos*/
                                          ,OUTPUT "").         /* pr_dsmensagem */
                                                                               

    IF  ERROR-STATUS:ERROR  THEN DO:

        DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
            ASSIGN aux_msgerora = aux_msgerora + ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
        END.
              
        ASSIGN aux_dscritic = "pc_InternetBank189 --> Erro ao executar Stored Procedure: " + aux_msgerora.
          
        ASSIGN xml_dsmsgerr = "<dsmsgerr>Erro inesperado. Nao foi possivel efetuar a consulta." + 
                                " Tente novamente ou contacte seu PA" +
                              "</dsmsgerr>".
                            
        RUN proc_geracao_log (INPUT FALSE).
          
        RETURN "NOK".
          
    END. 
    
    CLOSE STORED-PROC pc_buscar_mensagem
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl}}

    ASSIGN aux_dsmsgini = pc_buscar_mensagem.pr_dsmensagem 
                     WHEN pc_buscar_mensagem.pr_dsmensagem <> ?.
                     
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = '<dados><dsmsgini>'.

    /* Atribuir xml de retorno a temptable */ 
    IF  aux_dsmsgini <> "" THEN
        DO:
            ASSIGN aux_iteracoes = roundUp(LENGTH(aux_dsmsgini) / 31000)
                   aux_posini    = 1.    

            DO  aux_contador = 1 TO aux_iteracoes:
                
                CREATE xml_operacao.
                ASSIGN xml_operacao.dslinxml = SUBSTRING(aux_dsmsgini, aux_posini, 31000)
                       aux_posini            = aux_posini + 31000.
                           
            END.
        END.
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = '</dsmsgini>'.  
    
    /* Verificar servi�o de SMS*/
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
                                                  
    RUN STORED-PROCEDURE pc_verifar_serv_sms
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper  /* pr_cdcooper  */
                                            ,INPUT par_nrdconta  /* pr_nrdconta  */
                                            ,INPUT 'INTERNETBANK'/* pr_nmdatela  */
                                            ,INPUT 3             /* pr_idorigem  */
                                            /*----> OUT <-----*/ 
                                            ,OUTPUT 0            /* pr_idcontrato */
                                            ,OUTPUT 0            /* pr_flsitsms */ 
                                            ,OUTPUT ""           /* pr_dsalerta */ 
                                            ,OUTPUT 0            /* pr_cdcritic */ 
                                            ,OUTPUT "").         /* pr_dscritic */ 

                                                                               

    IF  ERROR-STATUS:ERROR  THEN DO:

        DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
            ASSIGN aux_msgerora = aux_msgerora + ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
        END.
              
        ASSIGN aux_dscritic = "pc_InternetBank189.pc_verifar_serv_sms --> Erro ao executar Stored Procedure: " + aux_msgerora.
          
        ASSIGN xml_dsmsgerr = "<dsmsgerr>Erro inesperado. Nao foi possivel efetuar a consulta." + 
                                " Tente novamente ou contacte seu PA" +
                              "</dsmsgerr>".
                            
        RUN proc_geracao_log (INPUT FALSE).
          
        RETURN "NOK".
          
    END. 

    CLOSE STORED-PROC pc_verifar_serv_sms
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl}}

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_verifar_serv_sms.pr_cdcritic 
                          WHEN pc_verifar_serv_sms.pr_cdcritic <> ?
           aux_dscritic = pc_verifar_serv_sms.pr_dscritic 
                          WHEN pc_verifar_serv_sms.pr_dscritic <> ?.

    IF aux_dscritic <> "" THEN
      DO:
          xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
          RETURN "NOK".
      END. 
            
    ASSIGN aux_flsitsms = 0
           aux_dsalerta = ""           
           aux_idcontrato = 0
           aux_flsitsms = pc_verifar_serv_sms.pr_flsitsms 
                          WHEN pc_verifar_serv_sms.pr_flsitsms <> ?
           aux_dsalerta = pc_verifar_serv_sms.pr_dsalerta 
                          WHEN pc_verifar_serv_sms.pr_dsalerta <> ?
           aux_idcontrato = pc_verifar_serv_sms.pr_idcontrato 
                          WHEN pc_verifar_serv_sms.pr_idcontrato <> ?               .
    
    /* Se retornou numero de contrato � pq existe contrato ativo*/
    ASSIGN aux_flgativo = 0.
    IF aux_idcontrato > 0 THEN
    DO:
      ASSIGN aux_flgativo = 1.
    END.
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = '<flposcob>' + STRING(aux_flposcob) + '</flposcob>' + 
                                   '<flgativo>' + STRING(aux_flgativo) + '</flgativo>' + 
                                   '<flsitsms>' + STRING(aux_flsitsms) + '</flsitsms>' + 
                                   '<dsalerta>' + STRING(aux_dsalerta) + '</dsalerta>'.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = '</dados>'.
    
  
  END.
/* Consultar Contrato */
ELSE IF par_cddopcao = "C" THEN
  DO: 
    


    /* Carrega dados do contrato do servi�o de SMS*/
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
                                                  
    RUN STORED-PROCEDURE pc_ret_dados_serv_sms
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper  /* pr_cdcooper  */
                                            ,INPUT par_nrdconta  /* pr_nrdconta  */
                                            ,INPUT 'INTERNETBANK'/* pr_nmdatela  */
                                            ,INPUT 3             /* pr_idorigem  */
                                            /*----> OUT <-----*/ 
                                            ,OUTPUT ""           /* pr_nmprintl */ 
                                            ,OUTPUT ""           /* pr_nmfansia */ 
                                            ,OUTPUT 0            /* pr_tpnmemis */ 
                                            ,OUTPUT ""           /* pr_nmemisms */ 
                                            ,OUTPUT 0            /* pr_flgativo */ 
                                            ,OUTPUT ""           /* pr_dspacote */ 
                                            ,OUTPUT ?            /* pr_dhadesao */ 
                                            ,OUTPUT 0            /* pr_idcontrato */
                                            ,OUTPUT 0            /* pr_vltarifa */ 
                                            ,OUTPUT 0            /* pr_flsitsms */ 
                                            ,OUTPUT ""           /* pr_dsalerta */ 
                                            ,OUTPUT 0            /* pr_cdcritic */ 
                                            ,OUTPUT "").         /* pr_dscritic */ 

                                                                               

    IF  ERROR-STATUS:ERROR  THEN DO:

        DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
            ASSIGN aux_msgerora = aux_msgerora + ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
        END.
              
        ASSIGN aux_dscritic = "pc_InternetBank189.pc_ret_dados_serv_sms --> Erro ao executar Stored Procedure: " + aux_msgerora.
          
        ASSIGN xml_dsmsgerr = "<dsmsgerr>Erro inesperado. Nao foi possivel efetuar a consulta." + 
                                " Tente novamente ou contacte seu PA" +
                              "</dsmsgerr>".
                            
        RUN proc_geracao_log (INPUT FALSE).
          
        RETURN "NOK".
          
    END. 

    CLOSE STORED-PROC pc_ret_dados_serv_sms
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl}}

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_ret_dados_serv_sms.pr_cdcritic 
                          WHEN pc_ret_dados_serv_sms.pr_cdcritic <> ?
           aux_dscritic = pc_ret_dados_serv_sms.pr_dscritic 
                          WHEN pc_ret_dados_serv_sms.pr_dscritic <> ?.

    IF aux_dscritic <> "" THEN
      DO:
          xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
          RETURN "NOK".
      END. 
            
    ASSIGN aux_flsitsms = 0
           aux_dsalerta = ""
           aux_flsitsms = pc_ret_dados_serv_sms.pr_flsitsms 
                          WHEN pc_ret_dados_serv_sms.pr_flsitsms <> ?
           aux_dsalerta = pc_ret_dados_serv_sms.pr_dsalerta 
                          WHEN pc_ret_dados_serv_sms.pr_dsalerta <> ?.
                          
    ASSIGN aux_nmprintl = ""
           aux_nmfansia = ""
           aux_tpnmemis = 0
           aux_nmemisms = ""
           aux_flgativo = 0
           aux_dspacote = ""
           aux_dhadesao = ?
           aux_idcontra = 0
           aux_vltarifa = 0.

    ASSIGN aux_nmprintl = pc_ret_dados_serv_sms.pr_nmprintl 
                          WHEN pc_ret_dados_serv_sms.pr_nmprintl <> ?
           aux_nmfansia = pc_ret_dados_serv_sms.pr_nmfansia 
                          WHEN pc_ret_dados_serv_sms.pr_nmfansia <> ?
           aux_tpnmemis = pc_ret_dados_serv_sms.pr_tpnmemis 
                          WHEN pc_ret_dados_serv_sms.pr_tpnmemis <> ?
           aux_nmemisms = pc_ret_dados_serv_sms.pr_nmemisms 
                          WHEN pc_ret_dados_serv_sms.pr_nmemisms <> ?
           aux_flgativo = pc_ret_dados_serv_sms.pr_flgativo 
                          WHEN pc_ret_dados_serv_sms.pr_flgativo <> ?
           aux_dspacote = pc_ret_dados_serv_sms.pr_dspacote 
                          WHEN pc_ret_dados_serv_sms.pr_dspacote <> ?
           aux_dhadesao = pc_ret_dados_serv_sms.pr_dhadesao 
                          WHEN pc_ret_dados_serv_sms.pr_dhadesao <> ?
           aux_idcontra = pc_ret_dados_serv_sms.pr_idcontra 
                          WHEN pc_ret_dados_serv_sms.pr_idcontra <> ?
           aux_vltarifa = pc_ret_dados_serv_sms.pr_vltarifa 
                          WHEN pc_ret_dados_serv_sms.pr_vltarifa <> ?.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = '<dados>' + 
                                   '<flposcob>' + STRING(aux_flposcob) + '</flposcob>' + 
                                   '<flsitsms>' + STRING(aux_flsitsms) + '</flsitsms>' + 
                                   '<dsalerta>' + STRING(aux_dsalerta) + '</dsalerta>' + 
                                   '<nmprintl>' + STRING(aux_nmprintl) + '</nmprintl>' + 
                                   '<nmfansia>' + STRING(aux_nmfansia) + '</nmfansia>' + 
                                   '<tpnmemis>' + STRING(aux_tpnmemis) + '</tpnmemis>'.
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = '<nmemisms>' + STRING(aux_nmemisms) + '</nmemisms>' + 
                                   '<flgativo>' + STRING(aux_flgativo) + '</flgativo>' + 
                                   '<dspacote>' + STRING(aux_dspacote) + '</dspacote>' + 
                                   '<dhadesao>' + STRING(aux_dhadesao,"99/99/9999") + '</dhadesao>' + 
                                   '<idcontra>' + STRING(aux_idcontra) + '</idcontra>' + 
                                   '<vltarifa>' + STRING(aux_vltarifa,"zzz,zz9.99") + '</vltarifa>'.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = '</dados>'.
  END.
RETURN "OK".
    
/*................................ PROCEDURES ................................*/

PROCEDURE proc_geracao_log:
    
  DEF INPUT PARAM par_flgtrans AS LOGICAL                         NO-UNDO.

  RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT SET h-b1wgen0014.
      
  IF  VALID-HANDLE(h-b1wgen0014)  THEN
      DO:
          RUN gera_log IN h-b1wgen0014 (INPUT par_cdcooper,
                                        INPUT "996",
                                        INPUT aux_dscritic,
                                        INPUT "INTERNET",
                                        INPUT aux_dstransa,
                                        INPUT aux_datdodia,
                                        INPUT par_flgtrans,
                                        INPUT TIME,
                                        INPUT par_idseqttl,
                                        INPUT "INTERNETBANK",
                                        INPUT par_nrdconta,
                                        OUTPUT aux_nrdrowid).
               
          DELETE PROCEDURE h-b1wgen0014.
      END.
    
END PROCEDURE.
