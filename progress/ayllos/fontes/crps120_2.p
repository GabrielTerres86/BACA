/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps120_2.p              | Incorporado ao pc_crps120         |
   +---------------------------------+----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/











/* ..........................................................................

   Programa: Fontes/crps120_2.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/95.                           Ultima atualizacao: 27/03/2014

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado pelo crps120.
   Objetivo  : Processar os debitos dos planos de capital (Cotas).

   Alteracoes: 16/01/97 - Alterado para tratar CPMF (Edson).

               13/02/97 - Fazer tratamento para nova rotina do capital (Odair).

               27/08/97 - Alterado para tratar o campo flgproce (Deborah).

               30/10/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
               
               11/04/03 - Comparar com o total de prestacoes do plano capital.
                          (Ze Eduardo).

               29/06/2005 - Alimentado campo cdcooper da tabela craplct (Diego).

               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               20/08/2013 - Quando o salario nao for suficiente para o debito
                            de cotas, seta crappla.indpagto = 0 e atribui o 
                            valor da prestacao de cotas ao novo campo 
                            crappla.vlpenden. Do contrario, seta indpagto = 1 e 
                            atribui valor zero ao campo vlpenden. (Fabricio)
                            
               15/01/2014 - Inclusao de VALIDATE craplct (Carlos)
               
               27/01/2014 - Atualizacao do campo crappla.dtdpagto (data do
                            proximo debito). (Fabricio)
                            
               27/03/2014 - Atualizacao do campo crappla.flgatupl 
                            (identificador de necessidade de correcao do valor
                             do plano de capital). (Fabricio)
............................................................................. */

DEF INPUT  PARAM par_nrdconta AS INT                                        .
DEF INPUT  PARAM par_nrctrpla AS INT                                        .
DEF INPUT  PARAM par_nrdolote AS INT                                        .
DEF INPUT  PARAM par_vldaviso AS DECIMAL                                    .
DEF INPUT  PARAM par_vlsalliq AS DECIMAL                                    .
DEF INPUT  PARAM par_dtintegr AS DATE                                       .
DEF INPUT  PARAM par_dtdemiss AS DATE                                       .
DEF INPUT  PARAM par_cdhistor AS INT                                        .
DEF OUTPUT PARAM par_insitavs AS INT                                        .
DEF OUTPUT PARAM par_vldebito AS DECIMAL                                    .
DEF OUTPUT PARAM par_vlestdif AS DECIMAL                                    .
DEF OUTPUT PARAM par_vldoipmf AS DECIMAL                                    .
DEF OUTPUT PARAM par_flgproce AS LOGICAL                                    .

{ includes/var_batch.i }

DEF        VAR aux_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT     INIT 100                      NO-UNDO.
DEF        VAR aux_nrmesant AS INT                                   NO-UNDO.

DEF        VAR aux_flgsomar AS LOGICAL                               NO-UNDO.

DEF        VAR aux_vllanmto AS DECIMAL                               NO-UNDO.

DEF        VAR aux_dtdpagto AS DATE                                  NO-UNDO.

DEF        VAR aux_dtultcor AS DATE                                  NO-UNDO.

ASSIGN glb_cdcritic = 0

       par_vldebito = 0
       par_flgproce = FALSE

       aux_nrmesant = IF MONTH(glb_dtmvtolt) = 1
                         THEN 12
                         ELSE MONTH(glb_dtmvtolt) - 1

       aux_dtultcor = ADD-INTERVAL(glb_dtmvtolt, -1, "years").

/*  Leitura do contrato de plano  */

DO WHILE TRUE:

   FIND FIRST crappla WHERE crappla.cdcooper = glb_cdcooper  AND
                            crappla.nrdconta = par_nrdconta  AND
                            crappla.tpdplano = 1             AND
                            crappla.cdsitpla = 1
                            USE-INDEX crappla1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE crappla   THEN
        IF   LOCKED crappla   THEN
             DO:
                 PAUSE 2 NO-MESSAGE.
                 NEXT.
             END.
        ELSE
             DO:
                 ASSIGN par_vlestdif = par_vldaviso
                        par_insitavs = 1
                        par_flgproce = TRUE.
                 RETURN.

             END.
   ELSE
        IF   crappla.qtprepag > crappla.qtpremax  THEN
             DO:
                 ASSIGN par_vlestdif = par_vldaviso
                        par_insitavs = 1
                        par_flgproce = TRUE.
                 RETURN.
             END.
   
   /* FIND crapcot OF crappla EXCLUSIVE-LOCK NO-ERROR NO-WAIT. */
   FIND crapcot WHERE crapcot.cdcooper = glb_cdcooper       AND
                      crapcot.nrdconta = crappla.nrdconta   
                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE crapcot   THEN
        IF   LOCKED crapcot   THEN
             DO:
                 PAUSE 2 NO-MESSAGE.
                 NEXT.
             END.
        ELSE
             DO:
                 glb_cdcritic = 169.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                   glb_cdprogra + "' --> '" + glb_dscritic +
                                   " CTA: " + STRING(par_nrdconta,"zzzzzzz,9") +
                                   " >> log/proc_batch.log").
                 RETURN.
             END.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

IF   MONTH(glb_dtmvtolt) = MONTH(crappla.dtultpag) THEN
     aux_flgsomar = TRUE.
ELSE
     aux_flgsomar = FALSE.

par_vldoipmf = 0.

/* Atribui data do proximo debito no mes seguinte */ 
RUN fontes/calcdata.p (crappla.dtdpagto,1,"M", 0,OUTPUT aux_dtdpagto).

ASSIGN crappla.dtdpagto = aux_dtdpagto.

/* Verifica se o valor do salario eh suficiente para debitar a parcela do 
   plano */ 
IF   par_vldaviso > (par_vlsalliq + par_vldoipmf)   THEN
     DO:
         ASSIGN par_vlestdif = par_vldaviso * -1
                par_insitavs = 1
                par_flgproce = TRUE
                par_vldoipmf = 0
                /* Mesmo sem debitar COTAS passaremos o aviso de debito para 
                "processado". Com a tentativa diaria de debito da parcela de
                COTAS este valor ficara pendente na LAUTOM atraves do registro
                na crappla */ 
                crappla.indpagto = 0 /* A debitar */ 
                crappla.vlpenden = par_vldaviso.

         RETURN.
     END.
ELSE
     ASSIGN aux_vllanmto = par_vldaviso
            par_vlestdif = 0
            par_insitavs = 1
            par_flgproce = TRUE
            crappla.indpagto = 1 /* Debito efetuado */ 
            crappla.vlpenden = 0.

DO WHILE TRUE:

   FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                      craplot.dtmvtolt = par_dtintegr   AND
                      craplot.cdagenci = aux_cdagenci   AND
                      craplot.cdbccxlt = aux_cdbccxlt   AND
                      craplot.nrdolote = par_nrdolote
                      USE-INDEX craplot1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE craplot   THEN
        IF   LOCKED craplot   THEN
             DO:
                 PAUSE 1 NO-MESSAGE.
                 NEXT.
             END.
        ELSE
             DO:
                 glb_cdcritic = 60.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                   glb_cdprogra + "' --> '" + glb_dscritic +
                                   " AG: 001 BCX: 100 LOTE: " +
                                   STRING(par_nrdolote,"999999") +
                                   " >> log/proc_batch.log").
                 RETURN.
             END.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

CREATE craplct.
ASSIGN craplct.dtmvtolt = craplot.dtmvtolt
       craplct.cdagenci = craplot.cdagenci
       craplct.cdbccxlt = craplot.cdbccxlt
       craplct.nrdolote = craplot.nrdolote
       craplct.nrdconta = crappla.nrdconta
       craplct.nrdocmto = craplot.nrdolote
       craplct.cdhistor = par_cdhistor
       craplct.vllanmto = aux_vllanmto
       craplct.nrseqdig = craplot.nrseqdig + 1
       craplct.nrctrpla = crappla.nrctrpla
       craplct.cdcooper = glb_cdcooper

       craplot.qtinfoln = craplot.qtinfoln + 1
       craplot.qtcompln = craplot.qtcompln + 1
       craplot.vlinfocr = craplot.vlinfocr + aux_vllanmto
       craplot.vlcompcr = craplot.vlcompcr + aux_vllanmto
       craplot.nrseqdig = craplct.nrseqdig

       crapcot.vldcotas = crapcot.vldcotas + aux_vllanmto
       crapcot.qtprpgpl = crapcot.qtprpgpl + 1

       crappla.vlpagmes = IF aux_flgsomar
                             THEN crappla.vlpagmes + aux_vllanmto
                             ELSE aux_vllanmto

       crappla.dtultpag = craplot.dtmvtolt
       crappla.qtprepag = crappla.qtprepag + 1
       crappla.vlprepag = crappla.vlprepag + aux_vllanmto

       par_vldebito     = aux_vllanmto.

VALIDATE craplct.

IF crappla.dtultcor <= aux_dtultcor AND crappla.cdtipcor > 0 THEN
    ASSIGN crappla.flgatupl = TRUE.

IF   crappla.qtprepag = crappla.qtpremax THEN
     ASSIGN crappla.dtcancel = glb_dtmvtolt
            crappla.cdsitpla = 2.
/* .......................................................................... */

