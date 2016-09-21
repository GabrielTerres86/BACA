/* .............................................................................

   Programa: fontes/crps387a.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Data    : Abril/2004                     Ultima atualizacao: 17/06/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Verifica se os arquivos de integracao devem ou nao serem execu-
               tados, verificando a sequencia dos arquivos e outros parametros
               comparando com a tabela dos convenios.

   Alteracoes: 30/11/2004 - Aplicar dos2ux para leitura dos arquivos (Julio).  
   
               07/12/2004 - Nao consistir nome da empresa para conveio 
                            VIVO (15). Provisorio durante o processo de
                            migracao interna da VIVO - (Julio)

               06/03/2005 - Numero do convenio pode ter mais de 5 digitos
                            (Julio).
                            
               13/04/2006 - Nao consistir mais nome do convenio no arquivo
                            (Julio).
                            
               17/06/2013 - Envio de email quando ocorrer critica 476(Jean Michel).

............................................................................. */

{ includes/var_online.i}

DEF {1} SHARED VAR tab_nmarquiv   AS CHAR   FORMAT "x(25)" EXTENT 99 NO-UNDO.
  
DEF STREAM str_1.   /*  Para relatorio de criticas  */
DEF STREAM str_2.   /*  Para arquivo de trabalho */

DEF INPUT  PARAMETER par_nmarqdeb AS CHAR                            NO-UNDO.
DEF INPUT  PARAMETER par_cdconven AS INTEGER                         NO-UNDO.
DEF INPUT  PARAMETER par_nrseqarq AS INTEGER                         NO-UNDO.
DEF OUTPUT PARAMETER par_contador AS INTEGER                         NO-UNDO.

DEF     TEMP-TABLE crawarq                                           NO-UNDO
        FIELD nmarquiv         AS CHAR   FORMAT "x(20)"
        FIELD nrsequen         AS INT    FORMAT "999999"
        FIELD setlinha         AS CHAR   FORMAT "x(150)"
        INDEX nrsequen
              nmarquiv.

DEF          VAR aux_nmarquiv     AS CHAR                            NO-UNDO.
DEF          VAR aux_nmarqaux     AS CHAR                            NO-UNDO.
DEF          VAR aux_setlinha     AS CHAR   FORMAT "x(150)"          NO-UNDO.
DEF          VAR aux_nrconven     AS CHAR   FORMAT "99999"           NO-UNDO.
DEF          VAR aux_nrsequen     AS INT    FORMAT "99999"           NO-UNDO.
DEF          VAR aux_conteudo     AS CHARACTER                       NO-UNDO.

DEF          VAR h-b1wgen0011     AS HANDLE                          NO-UNDO.

FORM aux_setlinha    FORMAT "x(150)"
     WITH NO-BOX NO-LABELS DOWN WIDTH 150 FRAME ABC.

/*  Verificar se deve rodar        */
                                      
INPUT STREAM str_1 THROUGH VALUE( "ls " + par_nmarqdeb + " 2> /dev/null")
      NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
   
   SET STREAM str_1 par_nmarqdeb FORMAT "x(40)" .

   UNIX SILENT VALUE("mv " + par_nmarqdeb + " " + par_nmarqdeb + ".ori").

   UNIX SILENT VALUE("script/trnulo " + par_nmarqdeb + ".ori " +
        par_nmarqdeb).
        
   UNIX SILENT VALUE("rm " + par_nmarqdeb + ".ori").

   UNIX SILENT VALUE("mv " + par_nmarqdeb + " " + par_nmarqdeb + ".ux").
   
   UNIX SILENT VALUE("dos2ux " + par_nmarqdeb + ".ux > " + par_nmarqdeb).

   UNIX SILENT VALUE("rm " + par_nmarqdeb + ".ux").

   UNIX SILENT VALUE("quoter " + par_nmarqdeb + " > " +
                      par_nmarqdeb + ".q 2> /dev/null").

   INPUT STREAM str_2 FROM VALUE(par_nmarqdeb + ".q") NO-ECHO.
      
   SET STREAM str_2 aux_setlinha WITH FRAME ABC WIDTH 150.
   
   CREATE crawarq.
   ASSIGN crawarq.nrsequen = INT(STRING(SUBSTR(aux_setlinha,74,6)))
          crawarq.nmarquiv = par_nmarqdeb
          crawarq.setlinha = aux_setlinha. 
          
   INPUT STREAM str_2 CLOSE.
                                                       
END.  /*  Fim do DO WHILE TRUE  */

INPUT STREAM str_1 CLOSE.
   
FIND  gnconve NO-LOCK WHERE
      gnconve.cdconven = par_cdconven NO-ERROR.

IF  NOT AVAIL gnconve THEN
    DO:
       glb_cdcritic = 566. /* Falta Controle Convenio */
       RUN fontes/critic.p.
       UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '" + glb_dscritic +
                          " >> log/proc_batch.log").
       glb_cdcritic = 0.
       RETURN.
    END.

ASSIGN aux_nrsequen = par_nrseqarq.
                           
FOR EACH crawarq BY crawarq.nrsequen
                 BY crawarq.nmarquiv:  
        
    /*  Verifica  somente  a  Sequencia   */ 
    IF   aux_nrsequen = crawarq.nrsequen THEN
         DO:
             ASSIGN  aux_nrconven = TRIM(SUBSTR(gnconve.nrcnvfbr,1,10))
                     glb_cdcritic = 0.
 
             IF   SUBSTR(crawarq.setlinha,1,1) <> "A"  THEN
                  glb_cdcritic = 468.

             IF   INTEGER(SUBSTR(crawarq.setlinha,2,1)) <> 1 THEN
                  glb_cdcritic = 473.

             IF   INT(SUBSTR(crawarq.setlinha,3,20)) <> INT(aux_nrconven) THEN
                  glb_cdcritic = 474.

             IF   INTEGER(SUBSTR(crawarq.setlinha,80,2)) <> 4 THEN
                  glb_cdcritic = 477.

             IF   SUBSTR(crawarq.setlinha,82,17) <> "DEBITO AUTOMATICO" THEN
                  glb_cdcritic = 478.
             
             IF   glb_cdcritic <> 0 THEN
                  DO:
                      RUN fontes/critic.p.
                      
                      aux_nmarqaux = crawarq.nmarquiv.
                      
                      IF  SUBSTR(aux_nmarqaux,1,8) = "integra/" THEN
                          aux_nmarqaux = SUBSTR(aux_nmarqaux,9,
                                                LENGTH(aux_nmarqaux)).
                      
                      aux_nmarquiv = "integra/err" + aux_nmarqaux.

                      UNIX SILENT VALUE("rm " + crawarq.nmarquiv + 
                                        ".q 2> /dev/null").
                      UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + 
                                        aux_nmarquiv).
                      UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                                         " - " + glb_cdprogra + "' --> '" +
                                         glb_dscritic + " " + aux_nmarquiv +
                                         " >> log/proc_batch.log").
                      glb_cdcritic = 0.      
                      INPUT STREAM str_2 CLOSE.
                      NEXT.
                  END.
             ELSE
                  DO:
                      ASSIGN aux_nrsequen = aux_nrsequen + 1
                             par_contador = par_contador + 1 
                             tab_nmarquiv[par_contador] = crawarq.nmarquiv.
                                                               
                  END.  /*  Fim  do  ELSE   */
         END.  /*  Fim do IF  */
    ELSE
         DO:
             glb_cdcritic = 476.
             RUN fontes/critic.p.
             
             aux_nmarqaux = crawarq.nmarquiv.
                                   
             IF  SUBSTR(aux_nmarqaux,1,8) = "integra/" THEN
                 aux_nmarqaux = SUBSTR(aux_nmarqaux, 9, LENGTH(aux_nmarqaux)).
                      
             aux_nmarquiv = "integra/err" + aux_nmarqaux.
             
             aux_conteudo = STRING(TIME,"HH:MM:SS") + " - " + glb_cdprogra + " --> " + 
                       glb_dscritic + " " + aux_nmarqaux +
                       " Seq. Parametrizada " + STRING(aux_nrsequen,"999999") +
                       " Seq. Arquivo " + STRING(crawarq.nrsequen,"999999").
             
             UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
             UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_nmarquiv).
             
             UNIX SILENT VALUE ("echo " + aux_conteudo + " >> log/proc_batch.log").    
            
             IF  NOT VALID-HANDLE (h-b1wgen0011)  THEN
                DO:
                    RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT SET h-b1wgen0011.
                END.                                  
             
             RUN enviar_email_completo IN h-b1wgen0011
                (INPUT glb_cdcooper,
                 INPUT "crps387a",                
                 INPUT "cpd@cecred.coop.br",
                 INPUT "convenios@cecred.coop.br",
                 INPUT "Arquivo Fora de Sequencia - " + gnconve.nmempres,
                 INPUT "",
                 INPUT "",
                 INPUT aux_conteudo,
                 INPUT TRUE).                  
                      
             IF VALID-HANDLE (h-b1wgen0011)  THEN
                DO:             
                    DELETE PROCEDURE h-b1wgen0011.      
                END.
             
             glb_cdcritic = 0.  

             INPUT STREAM str_2 CLOSE.
             NEXT.                
         END.  /*  Fim do ELSE  */

END.  /*  Fim do FOR EACH  */
/* ..........................................................................*/

