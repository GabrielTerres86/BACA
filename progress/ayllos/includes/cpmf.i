/*.............................................................................

   Programa: Fontes/ipmf.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Agosto/93.                          Ultima atualizacao: 25/01/2006

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela IPMF.
         
   Alteracoes: 25/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
............................................................................. */
/*  Tabela com a taxa do CPMF */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper       AND
                   craptab.nmsistem = "CRED"             AND
                   craptab.tptabela = "USUARI"           AND
                   craptab.cdempres = 11                 AND
                   craptab.cdacesso = "CTRCPMFCCR"       AND
                   craptab.tpregist = 1
                   USE-INDEX craptab1 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 641.
         BELL. 
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         QUIT.
     END.
 
ASSIGN tab_dtinipmf = DATE(INT(SUBSTRING(craptab.dstextab,4,2)),
                           INT(SUBSTRING(craptab.dstextab,1,2)),
                           INT(SUBSTRING(craptab.dstextab,7,4)))
       tab_dtfimpmf = DATE(INT(SUBSTRING(craptab.dstextab,15,2)),
                           INT(SUBSTRING(craptab.dstextab,12,2)),
                           INT(SUBSTRING(craptab.dstextab,18,4)))
       tab_txcpmfcc = IF glb_dtmvtolt >= tab_dtinipmf AND
                         glb_dtmvtolt <= tab_dtfimpmf 
                         THEN DECIMAL(SUBSTR(craptab.dstextab,23,13))
                         ELSE 0
       tab_txrdcpmf = IF glb_dtmvtolt >= tab_dtinipmf AND
                         glb_dtmvtolt <= tab_dtfimpmf 
                         THEN DECIMAL(SUBSTR(craptab.dstextab,38,13))
                         ELSE 1
       tab_indabono = INTE(SUBSTR(craptab.dstextab,51,1))  /* 0 = abona
                                                              1 = nao abona */
       tab_dtiniabo = DATE(INT(SUBSTRING(craptab.dstextab,56,2)),
                           INT(SUBSTRING(craptab.dstextab,53,2)),
                           INT(SUBSTRING(craptab.dstextab,59,4))). /* data de
                                         inicio do abono */
                                                             
                                                              

