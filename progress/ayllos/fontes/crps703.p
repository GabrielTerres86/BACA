/* ..........................................................................

   Programa: Fontes/crps703.p  
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odirlei Busana - AMcom
   Data    : Março/2016.                    Ultima atualizacao: 20/09/2016

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Envio da efetivaçao da proposta de emprestimo 
               para a Esteira de Credito.
               
   Alteracoes : 20/09/2016 - Atualizacao da data de envio da efetivação da esteira foi movida para o Oracle 
				estava gerando erro no Progress (Oscar).
   
   
   
.............................................................................*/   

{ includes/var_batch.i "NEW" }
DEF VAR aux_cdcooper AS INTEGER                                    NO-UNDO.
DEF VAR aux_cdcritic AS INTEGER                                    NO-UNDO.
DEF VAR aux_dscritic AS CHARACTER                                  NO-UNDO.
DEF VAR aux_qtsucess AS INTEGER                                    NO-UNDO.
DEF VAR aux_qtderros AS INTEGER                                    NO-UNDO.


DEF VAR h-b1wgen0195  AS HANDLE                                    NO-UNDO.

/*************************PRINCIPAL*******************************************/
ASSIGN glb_cdprogra = "crps703"
       glb_cdcooper = 3.
       

/*****************************************************/

FIND FIRST crapprg
  WHERE cdcooper = glb_cdcooper
    AND cdprogra = glb_cdprogra
    NO-LOCK NO-ERROR.

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                        " - " + glb_cdprogra + "' --> '"  +
                        "Inicio da execucao: " +  
                        glb_cdprogra + " - " + crapprg.dsprogra[1] + 
                        " >> log/proc_batch.log").
                        
UNIX SILENT VALUE("echo " + STRING(TODAY, "99/99/9999") + " - " +
                        STRING(TIME,"HH:MM:SS") +
                        " - " + glb_cdprogra + "' --> '"  +
                        "Inicio da execucao: " +  
                        glb_cdprogra + " - " + crapprg.dsprogra[1] + 
                        " >> log/proc_message.log").                        
                        
/* Captura o nome do servidor da variavel de ambiente HOST */ 
ASSIGN glb_hostname = OS-GETENV("HOST").
         
/* Buscar cooperativas ativas*/         
FOR EACH crapcop FIELDS (cdcooper)
   WHERE crapcop.flgativo = TRUE
      NO-LOCK
      BY crapcop.cdcooper:

  FOR FIRST crapdat FIELDS(inproces dtmvtolt dtmvtoan dtmvtopr) 
                     WHERE crapdat.cdcooper = crapcop.cdcooper  
                     NO-LOCK: END.

  IF NOT AVAIL crapdat THEN
    DO:
        ASSIGN glb_cdcritic = 1.

        RUN fontes/critic.p.
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> log/proc_batch.log").
        NEXT.
    END.


  /* Se ainda estiver rodando processo, busca proxima */
  IF   crapdat.inproces <> 1 THEN
       DO: 
          ASSIGN glb_dscritic = "Processo ainda está ativo para a coop " + 
                                STRING(crapcop.cdcooper,"9z") + ".".
          UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '"  +
                            glb_dscritic + " >> log/proc_batch.log").
          NEXT.
       END.
       
  RUN sistema/generico/procedures/b1wgen0195.p
           PERSISTENT SET h-b1wgen0195.
           
  RUN verifica_regras_esteira IN h-b1wgen0195
           ( INPUT crapcop.cdcooper,
             INPUT 0, /* par_nrdconta*/
             INPUT 0,  /* par_nrctremp*/
             INPUT "E", /*efetivar*/
            OUTPUT aux_dscritic,
            OUTPUT aux_dscritic).
 
  IF aux_cdcritic > 0 OR 
     aux_dscritic <> "" THEN                       
  DO:    
     ASSIGN glb_dscritic = "Coop " + STRING(crapcop.cdcooper,"9z") + ": " +
                           "Esteira em contigencia para esta cooperativa.".
     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                        " - " + glb_cdprogra + "' --> '"  +
                        glb_dscritic + " >> log/proc_message.log").
     
     ASSIGN aux_cdcritic = 0
            aux_dscritic = "".
     NEXT.
  END. 
  DELETE OBJECT h-b1wgen0195.


  ASSIGN glb_dtmvtolt = crapdat.dtmvtolt
         glb_dtmvtoan = crapdat.dtmvtoan
         glb_dtmvtopr = crapdat.dtmvtopr
         glb_cdoperad = "1"
         aux_qtderros = 0
         aux_qtsucess = 0.
         
  /* Buscar propostas efetivadas no dia anterior */
  FOR EACH crawepr FIELDS(cdcooper nrdconta nrctremp dtenefes)
     WHERE crawepr.cdcooper = crapcop.cdcooper
       AND crawepr.insitest = 3      
       AND crawepr.dtenefes = ?
       AND crawepr.dtenvest <> ?
       NO-LOCK,
      EACH crapepr FIELDS(cdagenci)
     WHERE crapepr.cdcooper = crawepr.cdcooper
       AND crapepr.nrdconta = crawepr.nrdconta
       AND crapepr.nrctremp = crawepr.nrctremp
       AND crapepr.dtmvtolt <= glb_dtmvtoan 
        NO-LOCK 
       BY crawepr.cdcooper
          BY crawepr.nrdconta
            BY crawepr.nrctremp:     

        RUN sistema/generico/procedures/b1wgen0195.p
           PERSISTENT SET h-b1wgen0195.
   
        /* Enviar efetivacao da proposta para esteira*/
        RUN Enviar_proposta_esteira IN h-b1wgen0195        
                         ( INPUT crawepr.cdcooper,
                           INPUT crapepr.cdagenci,
                           INPUT 1,
                           INPUT glb_cdprogra,
                           INPUT glb_cdoperad,
                           INPUT 9, /*Esteira */
                           INPUT crawepr.nrdconta,
                           INPUT glb_dtmvtolt,
                           INPUT glb_dtmvtopr,
                           INPUT crawepr.nrctremp, /* nrctremp */
                           INPUT crawepr.nrctremp, /* nrctremp_novo */
                           INPUT crawepr.nrctremp, /* dsiduser */
                           INPUT 0,                /* flreiflx */
                           INPUT "E",              /* tpenvest */
                          OUTPUT aux_cdcritic, 
                          OUTPUT aux_dscritic).
       
        DELETE OBJECT h-b1wgen0195.
       
        IF  RETURN-VALUE = "NOK"  THEN
          DO:
              IF aux_cdcritic = 0 AND 
                 aux_dscritic = "" THEN
              DO:
                ASSIGN aux_dscritic = "Nao foi possivel enviar efetivacao " + 
                                      "da proposta para Esteira.".
              END.
              
              UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> "  +
                            "ERRO: " + " coop " + STRING(crawepr.cdcooper,"9z") + 
                            " nrdconta " + STRING(crawepr.nrdconta) + 
                            " nrctremp " + STRING(crawepr.nrctremp) + 
                            ": "  + aux_dscritic + "' >> log/proc_message.log").
                            
              ASSIGN aux_qtderros = aux_qtderros + 1.
              NEXT.
          END. 
        
          aux_qtsucess     = aux_qtsucess + 1.
        
  END. /* fim loop crawepr */     

  IF (aux_qtderros + aux_qtderros) > 0 THEN
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '"  +
                            "Coop " + STRING(crapcop.cdcooper,"9z") + ": " +
                            "Foram enviados " +  STRING(aux_qtderros + aux_qtsucess) + 
                            " Efetivacoes para Esteira, "  + 
                            STRING(aux_qtsucess) + " com sucesso e " +
                            STRING(aux_qtderros) + " com erro." +
                            " >> log/proc_message.log").
  ELSE
     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          "Coop " + STRING(crapcop.cdcooper,"9z") + ": " +
                          "Nenhuma proposta pendente para o envio." + 
                          " >> log/proc_message.log").

END. /* Fim loop ccrapcop */                      

UNIX SILENT VALUE("echo " + STRING(TODAY, "99/99/9999") + " - " +
                        STRING(TIME,"HH:MM:SS") +
                        " - " + glb_cdprogra + "' --> '"  +
                        "Fim execucao" + 
                        " >> log/proc_message.log").
  
UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                        " - " + glb_cdprogra + "' --> '"  +
                        "Fim execucao" + 
                        " >> log/proc_batch.log").
                        
     
       




   