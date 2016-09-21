/* .............................................................................

   Programa: includes/proc_lantit.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2000.                     Ultima atualizacao: 20/08/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Procedures da tela lantit.

   Alteracoes: 09/01/2001 - Adaptar o novo codigo de barra para o lote 21, 
                            IPTU Blumenau. (Eduardo).
                            
               10/02/2004 - Incluido tres parametros chamada titulo_r(Mirtes)
               
               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               17/05/2007 - Incluir campo banco na tabela crawage (David).
               
               11/09/2008 - Incluir campo cdcomchq na tabela crawage (Diego).

               08/12/2008 - Chamar programa pcrap03.p no lugar do digm10.p
                            (David).

               26/08/2009 - Substituicao do campo banco/agencia da COMPE, 
                            para o banco/agencia COMPE de TITULO (cdagetit e
                            cdbantit) - (Sidnei - Precise).

               20/08/2010 - Alterada crawage para atender a nossa IF (Magui).
............................................................................. */

DEF TEMP-TABLE crawage                                                  NO-UNDO
       FIELD  cdagenci      LIKE crapage.cdagenci
       FIELD  nmresage      LIKE crapage.nmresage
       FIELD  nmcidade      LIKE crapage.nmcidade 
       FIELD  cdbandoc      LIKE crapage.cdbandoc
       FIELD  cdbantit      LIKE crapage.cdbantit
       FIELD  cdagecbn      LIKE crapage.cdagecbn
       FIELD  cdbanchq      LIKE crapage.cdbanchq
       FIELD  cdcomchq      LIKE crapage.cdcomchq.
   
PROCEDURE mostra_dados:

    DEF VAR aux_nrdigito AS INT                                      NO-UNDO.

    /*  Compoe a linha digitavel atraves do codigo de barras  */

    IF  aux_tplotmov = 21 THEN
         DO:
             ASSIGN tel_nrcampo1 = DECIMAL(SUBSTRING(tel_dscodbar,01,11))  
                    tel_nrcampo2 = DECIMAL(SUBSTRING(tel_dscodbar,12,11))
                    tel_nrcampo3 = DECIMAL(SUBSTRING(tel_dscodbar,23,11))
                    tel_nrcampo4 = DECIMAL(SUBSTRING(tel_dscodbar,34,11)).
              
             tel_dsdlinha = STRING(tel_nrcampo1,"99999,999999")  + " " +
                            STRING(tel_nrcampo2,"99999,999999") + " " +
                            STRING(tel_nrcampo3,"99999,999999") + " " +
                            STRING(tel_nrcampo4,"99999,999999").  
         END.
    ELSE
         DO:
             ASSIGN tel_nrcampo1 = DECIMAL(SUBSTRING(tel_dscodbar,01,04) +
                                   SUBSTRING(tel_dscodbar,20,01) +
                                   SUBSTRING(tel_dscodbar,21,04) + "0")
                    tel_nrcampo2 = DECIMAL(SUBSTRING(tel_dscodbar,25,10) + "0")
                    tel_nrcampo3 = DECIMAL(SUBSTRING(tel_dscodbar,35,10) + "0")
                    tel_nrcampo4 = INTEGER(SUBSTRING(tel_dscodbar,05,01))
                    tel_nrcampo5 = DECIMAL(SUBSTRING(tel_dscodbar,06,14)).
        
              
             RUN dbo/pcrap03.p (INPUT-OUTPUT tel_nrcampo1,      
                                INPUT        TRUE,          /* Validar zeros */
                                      OUTPUT aux_nrdigito,  /* Sem uso       */
                                      OUTPUT glb_stsnrcal).
                              
             RUN dbo/pcrap03.p (INPUT-OUTPUT tel_nrcampo2,      
                                INPUT        FALSE,         /* Validar zeros */
                                      OUTPUT aux_nrdigito,  /* Sem uso       */
                                      OUTPUT glb_stsnrcal).
                              
             RUN dbo/pcrap03.p (INPUT-OUTPUT tel_nrcampo3,      
                                INPUT        FALSE,         /* Validar zeros */
                                      OUTPUT aux_nrdigito,  /* Sem uso       */
                                      OUTPUT glb_stsnrcal).
                
             tel_dsdlinha = STRING(tel_nrcampo1,"99999,99999")  + " " +
                            STRING(tel_nrcampo2,"99999,999999") + " " +
                            STRING(tel_nrcampo3,"99999,999999") + " " +
                            STRING(tel_nrcampo4,"9")            + " " +
                            STRING(tel_nrcampo5,"zzzzzzzzzzz999").
         END.
    
END PROCEDURE.

PROCEDURE proc_lista_lote:

    IF   aux_tplotmov <> 21 THEN
         DO:
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                aux_confirma = "N".
                MESSAGE COLOR NORMAL "Imprimir o lote aberto? (S/N):" 
                                      UPDATE aux_confirma FORMAT "!".
                LEAVE.
       
             END.  /*  Fim do DO WHILE TRUE  */
 
             IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                  aux_confirma <> "S" THEN
                  .
             ELSE
                  DO:
                      /*FOR EACH crawage:
                          DELETE crawage.
                      END.*/
                      EMPTY TEMP-TABLE crawage.
                      
                      FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper
                                             NO-LOCK:
                          CREATE crawage.
                          ASSIGN crawage.cdagenci = crapage.cdagenci
                                 crawage.nmresage = crapage.nmresage.
                      END. 
                      RUN fontes/titulo_r.p (INPUT tel_dtmvtolt,
                                             INPUT tel_cdagenci,
                                             INPUT tel_cdbccxlt,
                                             INPUT tel_nrdolote,
                                             INPUT FALSE,
                                             INPUT TABLE crawage, 
                                             INPUT YES,
                                             INPUT NO).
                  END.
         END.  /*   Fim  do  IF   */
    ELSE
         PAUSE 0 NO-MESSAGE.  

END PROCEDURE.

/* .......................................................................... */

