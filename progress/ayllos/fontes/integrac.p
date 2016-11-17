/* .............................................................................

   Programa: fontes/integrac.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Data    : Fevereiro/2001                      Ultima atualizacao: 27/01/2006.

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Verifica se os arquivos de integracao devem ou nao serem execu-
               tados, verificando a sequencia dos arquivos e outros parametros
               comparando com a tabela dos convenios.

   Alteracoes:   20/03/2001 - Comparar se o arquivo esta no diretorio integra,
                              se estiver recortar (SUBSTR) somente o nome do
                              arquivo para nao duplicar o nome do diretorio.
                              (Eduardo).

                 09/07/2001 - Inserir o nr. sequencia esperada e do arquivo.
                              (Eduardo).
                              
                 10/11/2003 - Alteracao para converter o numero do convenio
                              para inteiro durante a condicao (Julio).

                 27/01/2006 - Unificacaco dos Bancos - SQLWorks - Fernando
............................................................................. */

{ includes/var_online.i}

DEF {1} SHARED VAR tab_nmarquiv   AS CHAR   FORMAT "x(25)" EXTENT 99 NO-UNDO.
  
DEF STREAM str_1.   /*  Para relatorio de criticas  */
DEF STREAM str_2.   /*  Para arquivo de trabalho */

DEF INPUT  PARAMETER par_nmarqdeb AS CHAR                            NO-UNDO.
DEF INPUT  PARAMETER par_nmtabela AS CHAR                            NO-UNDO.
DEF OUTPUT PARAMETER par_contador AS INTEGER                         NO-UNDO.

DEF     TEMP-TABLE crawarq                                           NO-UNDO
                   FIELD nmarquiv         AS CHAR   FORMAT "x(20)"
                   FIELD nrsequen         AS INT    FORMAT "999999"
                   FIELD setlinha         AS CHAR   FORMAT "x(150)".

DEF          VAR aux_nmarquiv     AS CHAR                            NO-UNDO.
DEF          VAR aux_nmarqaux     AS CHAR                            NO-UNDO.
DEF          VAR aux_setlinha     AS CHAR   FORMAT "x(150)"          NO-UNDO.
DEF          VAR aux_nrconven     AS CHAR   FORMAT "99999"           NO-UNDO.
DEF          VAR aux_nmempcon     AS CHAR   FORMAT "x(20)"           NO-UNDO.
DEF          VAR aux_nrsequen     AS INT    FORMAT "99999"           NO-UNDO.


FORM aux_setlinha    FORMAT "x(150)"
     WITH NO-BOX NO-LABELS DOWN WIDTH 150 FRAME ABC.

/*  Verifica se deve rodar ou nao  */
                                      
INPUT STREAM str_1 THROUGH VALUE( "ls " + par_nmarqdeb + " 2> /dev/null")
      NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_1 par_nmarqdeb FORMAT "x(40)" .

   UNIX SILENT VALUE("mv " + par_nmarqdeb + " " + par_nmarqdeb + ".ori").

   UNIX SILENT VALUE("script/trnulo " + par_nmarqdeb + ".ori " +
        par_nmarqdeb).
        
   UNIX SILENT VALUE("rm " + par_nmarqdeb + ".ori").

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

FIND craptab WHERE craptab.cdcooper = glb_cdcooper                    AND
                   craptab.nmsistem = SUBSTR(par_nmtabela,1,4)        AND
                   craptab.tptabela = SUBSTR(par_nmtabela,5,6)        AND
                   craptab.cdempres = INT(SUBSTR(par_nmtabela,11,2))  AND 
                   craptab.cdacesso = SUBSTR(par_nmtabela,13,10)      AND
                   craptab.tpregist = INT(SUBSTR(par_nmtabela,23,3))
                   NO-LOCK NO-ERROR.
                          
IF   NOT AVAILABLE craptab THEN
     DO:
         glb_cdcritic = 472.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '" + glb_dscritic +
                            " >> log/proc_batch.log").
         glb_cdcritic = 0.
         RETURN.
     END.
ELSE   
     aux_nrsequen = INTEGER(STRING(SUBSTR(craptab.dstextab,63,6),"999999")).

FOR EACH crawarq BY crawarq.nrsequen
                    BY crawarq.nmarquiv:  

    /*  Verifica  somente  a  Sequencia   */ 

    IF   aux_nrsequen = crawarq.nrsequen THEN
         DO:
             ASSIGN  aux_nrconven = SUBSTR(craptab.dstextab,22,5)
                     aux_nmempcon = SUBSTR(craptab.dstextab,28,20)
                     glb_cdcritic = 0.
 
             IF   SUBSTR(crawarq.setlinha,1,1) <> "A"  THEN
                  glb_cdcritic = 468.

             IF   INTEGER(SUBSTR(crawarq.setlinha,2,1)) <> 1 THEN
                  glb_cdcritic = 473.

             IF   INT(SUBSTR(crawarq.setlinha,3,20)) <> INT(aux_nrconven) THEN
                  glb_cdcritic = 474.

             IF   SUBSTR(crawarq.setlinha,23,20) <> aux_nmempcon THEN
                  glb_cdcritic = 475.

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

             UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
             UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_nmarquiv).
             UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                                " - " + glb_cdprogra + "' --> '" +
                                glb_dscritic + " " + crawarq.nmarquiv +
                            " Seq. esperada " + STRING(aux_nrsequen,"999999") +
                        "  Seq. arquivo " + STRING(crawarq.nrsequen,"999999") +
                                " >> log/proc_batch.log").
             glb_cdcritic = 0.     
             INPUT STREAM str_2 CLOSE.
             NEXT.                
         END.  /*  Fim do ELSE  */

END.  /*  Fim do FOR EACH  */

/*  Fim da verificacao se deve executar  */
/* ..........................................................................*/

