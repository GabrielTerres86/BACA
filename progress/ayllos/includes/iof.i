/*.............................................................................

   Programa: Fontes/iof.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Magui
   Data    : Janeiro/2008                    Ultima atualizacao: 03/01/2008

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela IOF.
         
   Alteracoes: 
............................................................................. */
/*  Tabela com a taxa do IOF */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper       AND
                   craptab.nmsistem = "CRED"             AND
                   craptab.tptabela = "USUARI"           AND
                   craptab.cdempres = 11                 AND
                   craptab.cdacesso = "VLIOFOPFIN"       AND
                   craptab.tpregist = 1
                   USE-INDEX craptab1 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 915.
         BELL. 
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         QUIT.
     END.
 
ASSIGN tab_dtiniiof = DATE(INT(SUBSTRING(craptab.dstextab,4,2)),
                           INT(SUBSTRING(craptab.dstextab,1,2)),
                           INT(SUBSTRING(craptab.dstextab,7,4)))
       tab_dtfimiof = DATE(INT(SUBSTRING(craptab.dstextab,15,2)),
                           INT(SUBSTRING(craptab.dstextab,12,2)),
                           INT(SUBSTRING(craptab.dstextab,18,4)))
       tab_txccdiof = IF glb_dtmvtolt >= tab_dtiniiof AND
                         glb_dtmvtolt <= tab_dtfimiof 
                         THEN DECIMAL(SUBSTR(craptab.dstextab,23,14))
                         ELSE 0.
                                                             
                                                              

