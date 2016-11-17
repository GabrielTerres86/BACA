/*..............................................................................

   Programa: b1craplot.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Abril/2007                    Ultima atualizacao: 03/11/2014     

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Tratar ALTERACAO e INCLUSAO na tabela craplot.

   Alteracoes: 20/05/2009 - Alterar tratamento para verificacao de registros
                            que estao com EXCLUSIVE-LOCK (David).
                
               23/02/2012 - Nova função para criação automatica de lotes por
                            parametros (Oscar).

               17/12/2013 - Adicionado validate para tabela craplot (Tiago).
               
               03/11/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
..............................................................................*/

DEF TEMP-TABLE cratlot NO-UNDO LIKE craplot.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.


PROCEDURE inclui-registro:
    
    DEF  INPUT PARAM TABLE        FOR cratlot.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    
    FIND FIRST cratlot NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE cratlot  THEN
        DO:
            par_dscritic = "Registro para inclusao (cratlot) nao encontrado.".
            RETURN "NOK".
        END.    
    
    /* Verifica se o lote ja foi cadastrado */
    FIND craplot WHERE craplot.cdcooper = cratlot.cdcooper   AND
                       craplot.dtmvtolt = cratlot.dtmvtolt   AND
                       craplot.cdagenci = cratlot.cdagenci   AND
                       craplot.cdbccxlt = cratlot.cdbccxlt   AND
                       craplot.nrdolote = cratlot.nrdolote
                       NO-LOCK NO-ERROR.

    IF  AVAILABLE craplot  THEN
        DO:
            par_dscritic = "Lote ja cadastrado.".
            RETURN "NOK".
        END.
    
    CREATE craplot.
    BUFFER-COPY cratlot TO craplot.
    VALIDATE craplot.

    RETURN "OK".

END PROCEDURE. 

PROCEDURE altera-registro:
    
    DEF  INPUT PARAM TABLE        FOR cratlot.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    FIND FIRST cratlot NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE cratlot  THEN
        DO:
            par_dscritic = "Registro para alteracao (cratlot) nao encontrado.".
            RETURN "NOK".
        END.
        
    DO aux_contador = 1 TO 10:
    
        par_dscritic = "".        
    
        /* Pega o registro do banco */
        FIND craplot WHERE craplot.cdcooper = cratlot.cdcooper   AND
                           craplot.dtmvtolt = cratlot.dtmvtolt   AND
                           craplot.cdagenci = cratlot.cdagenci   AND
                           craplot.cdbccxlt = cratlot.cdbccxlt   AND
                           craplot.nrdolote = cratlot.nrdolote
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                           
        IF  NOT AVAILABLE craplot  THEN
            DO:
                IF  LOCKED crapaut  THEN
                    DO:
                        par_dscritic = "Lote ja esta sendo alterada. " +
                                       "Tente novamente.".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.    
                ELSE                                    
                     par_dscritic = "Lote nao encontrado.".                 
             END.
             
        LEAVE.
        
    END. /* Fim do DO ... TO */        
    
    IF  par_dscritic <> ""  THEN
        RETURN "NOK".             
    
    BUFFER-COPY cratlot TO craplot.
    
    RELEASE craplot NO-ERROR.
    
    RETURN "OK".

END PROCEDURE. 


PROCEDURE inclui-altera-lote:
    
  /* Parametros de entrada */
  DEF INPUT  PARAM par_cdcooper LIKE craplot.cdcooper NO-UNDO.
  DEF INPUT  PARAM par_dtmvtolt LIKE craplot.dtmvtolt NO-UNDO.
  DEF INPUT  PARAM par_cdagenci LIKE craplot.cdagenci NO-UNDO.
  DEF INPUT  PARAM par_cdbccxlt LIKE craplot.cdbccxlt NO-UNDO.
  DEF INPUT  PARAM par_nrdolote LIKE craplot.nrdolote NO-UNDO.
  DEF INPUT  PARAM par_tplotmov LIKE craplot.tplotmov NO-UNDO.
  DEF INPUT  PARAM par_cdoperad LIKE craplot.cdoperad NO-UNDO.
  DEF INPUT  PARAM par_cdhistor LIKE craplot.cdhistor NO-UNDO.
  DEF INPUT  PARAM par_dtmvtopg LIKE craplot.dtmvtopg NO-UNDO.
  DEF INPUT  PARAM par_vllanmto LIKE craplot.vlinfocr NO-UNDO.
  DEF INPUT  PARAM par_flgincre AS LOGICAL NO-UNDO. /* Aumenta ou Diminui Lote */
  DEF INPUT  PARAM par_flgcredi AS LOGICAL NO-UNDO. /* Credita ou Debita Lote */
  
  /* Parametros de Saida */
  DEF OUTPUT PARAM par_nrseqdig AS INTE                NO-UNDO.
  DEF OUTPUT PARAM par_cdcritic AS INTE                NO-UNDO.
    
  /* Variaveis locais */
  DEF VAR aux_nrtentat AS INT NO-UNDO.
  DEF VAR aux_nrincrem AS INT NO-UNDO.
   
  ASSIGN par_cdcritic = 0
         aux_nrincrem = IF   par_flgincre   THEN 
                             1
                        ELSE
                            -1.           
  
  DO aux_nrtentat = 1 TO 10:           
       
     FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND 
                        craplot.dtmvtolt = par_dtmvtolt   AND
                        craplot.cdagenci = par_cdagenci   AND
                        craplot.cdbccxlt = par_cdbccxlt   AND
                        craplot.nrdolote = par_nrdolote
                        EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
     IF NOT AVAIL craplot THEN 
        DO:
            IF   LOCKED craplot THEN
                 DO:
                    RUN sistema/generico/procedures/b1wgen9999.p
                    PERSISTENT SET h-b1wgen9999.
                    
                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craplot),
                    					 INPUT "banco",
                    					 INPUT "craplot",
                    					 OUTPUT par_loginusr,
                    					 OUTPUT par_nmusuari,
                    					 OUTPUT par_dsdevice,
                    					 OUTPUT par_dtconnec,
                    					 OUTPUT par_numipusr).
                    
                    DELETE PROCEDURE h-b1wgen9999.
                    
                    ASSIGN aux_dadosusr = 
                    "077 - Tabela sendo alterada p/ outro terminal.".
                    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    MESSAGE aux_dadosusr.
                    PAUSE 3 NO-MESSAGE.
                    LEAVE.
                    END.
                    
                    ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                    			  " - " + par_nmusuari + ".".
                    
                    HIDE MESSAGE NO-PAUSE.
                    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    MESSAGE aux_dadosusr.
                    PAUSE 5 NO-MESSAGE.
                    LEAVE.
                    END.
                    
                   ASSIGN par_cdcritic = 0.   
                   NEXT.
                 END.
            ELSE
                 DO:
                     CREATE craplot.
                     ASSIGN craplot.nrseqdig = 0
                            craplot.cdcooper = par_cdcooper
                            craplot.dtmvtolt = par_dtmvtolt
                            craplot.cdagenci = par_cdagenci
                            craplot.cdbccxlt = par_cdbccxlt
                            craplot.nrdolote = par_nrdolote
                            craplot.tplotmov = par_tplotmov
                            craplot.cdoperad = par_cdoperad
                            craplot.cdhistor = par_cdhistor
                            craplot.dtmvtopg = par_dtmvtopg.
                 END.
        END.

     
     ASSIGN par_cdcritic = 0
            craplot.nrseqdig = craplot.nrseqdig +  1
            /*Quantidade computada de lancamentos.*/
            craplot.qtcompln = craplot.qtcompln + aux_nrincrem
            /*Quantidade de lancamentos do lote.*/
            craplot.qtinfoln = craplot.qtinfoln + aux_nrincrem
            par_nrseqdig     = craplot.nrseqdig.
    
     /* Credita ou Debita */
     IF   par_flgcredi THEN
         DO:
                    /*Total de valores computados a credito no lote*/
             ASSIGN craplot.vlcompcr = craplot.vlcompcr + 
                                 (par_vllanmto * aux_nrincrem)
                    /*Total de valores a credito do lote.*/
                    craplot.vlinfocr = craplot.vlinfocr + 
                                 (par_vllanmto * aux_nrincrem).
         END.
     ELSE
         DO:
            /*Total de valores computados a debito no lote.*/    
            ASSIGN craplot.vlcompdb = craplot.vlcompdb + 
                                 (par_vllanmto * aux_nrincrem)
                   /*Total de valores a debito do lote.*/
                   craplot.vlinfodb = craplot.vlinfodb + 
                                 (par_vllanmto * aux_nrincrem).
         END.

     LEAVE.
      
  END.
  
  VALIDATE craplot.

  IF par_cdcritic > 0 THEN
     RETURN "NOK".
  ELSE
     RETURN "OK".

END PROCEDURE. 
 

/*..............................................................................*/
