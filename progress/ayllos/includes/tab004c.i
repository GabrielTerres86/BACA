/* .............................................................................

   Programa: includes/tab004c.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                        Ultima atualizacao: 27/07/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a consulta da tela TAB004.

   Alteracoes: 10/11/94 - Alterado para incluir a taxa de saque sobre deposi-
                          tos bloqueados. (Deborah).

               05/10/1999 - Aumentado o numero de casas decimais na taxa
                            (Edson).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               11/04/2007 - Retirar campo Taxa de Cheque Especial, passa para a
                            tela TELAX (Ze).
                            
               27/07/2015 - Alterado var de tel_txjurneg para tel_txnegcal e 
                            tel_txjursaq para tel_txsaqcal. Adicionado var
                            tel_txnegfix e tel_txsaqfix. Adicionado campos de 
                            Taxa fixa. (Jorge - Rodrigo) - SD 307304             
............................................................................. */

ASSIGN glb_cdcritic = 0.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND 
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "USUARI"       AND
                   craptab.cdempres = 11             AND
                   craptab.cdacesso = "JUROSNEGAT"   AND
                   craptab.tpregist = 001            NO-LOCK NO-ERROR.

IF   AVAILABLE craptab   THEN
     ASSIGN tel_txnegcal = DECIMAL(SUBSTRING(craptab.dstextab,1,10))
            tel_txnegfix = DECIMAL(SUBSTRING(craptab.dstextab,12,6)).
ELSE
     DO:
         glb_cdcritic = 187.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
     END.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND 
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "USUARI"       AND
                   craptab.cdempres = 11             AND
                   craptab.cdacesso = "JUROSSAQUE"   AND
                   craptab.tpregist = 001            NO-LOCK NO-ERROR.

IF   AVAILABLE craptab   THEN
     ASSIGN tel_txsaqcal = DECIMAL(SUBSTRING(craptab.dstextab,1,10))
            tel_txsaqfix = DECIMAL(SUBSTRING(craptab.dstextab,12,6)).
ELSE
     DO:
         glb_cdcritic = 418.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
     END.

DISPLAY tel_txnegcal tel_txnegfix tel_txsaqcal tel_txsaqfix WITH FRAME f_tab004.

/* .......................................................................... */
