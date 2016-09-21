/* .............................................................................

   Programa: Fontes/lcredibl.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/94.                          Ultima atualizacao: 25/04/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de bloqueio e liberacao da tela LCREDI.

   Alteracoes: 14/10/94 - Alterado para inclusao de novos parametros para as
                          linhas de credito: taxa minima e maxima e o sinali-
                          zador de linha com saldo devedor.

             20/12/2002 - Incluir campo Valor Tarifa Especial (Junior).

             24/03/2004 - Incluido na tela campo Dias Carencia(Mirtes).

             28/06/2004 - Removido - colocado em comentarios - o campo Valor
                          Maximo Linha - tel_vlmaxdiv (Evandro).

             10/08/2004 - Incluido campo tel_vlmaxasj - Valor Maximo Pessoa
                          Juridica (Evandro).

             30/08/2004 - Tratameno para tipo de desconto (Consig. Folha)
                          (Julio)

             27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

             17/03/2006 - Excluido campo "Conta ADM", e acrescentado
                          tel_flgcrcta (Diego).

             28/08/2007 - Adicionado campo cdusolcr(Guilherme).

             24/06/2009 - Incluido campo Operacao (Gabriel).

             22/07/2009 - Tratar tel_cdusolcr com tipo 2 - EPR/BOLETOS.
                          (Fernando).
                          
             16/12/2009 - Alterado campo tel_dsoperac (Elton).   
           
             15/03/2010 - Incluido o campo que ira indicar o tempo que o 
                         emprestimo permanecera na atenda apos sua 
                         liquidacao (Gati -Daniel). 
                         
             16/03/2010 - incluido o campo que ira conter a origem do
                         recurso (gati - Daniel) 
                         
             29/06/2010 - Incluir campo de 'listar na proposta' (Gabriel).
           
             23/05/2012 - Adicionado campo de Tarifa IOF (Lucas).
             
             25/07/2012 - Gravação de LOG (Lucas).
             
             10/10/2012 - Incluir campo de Modalidade e Submodalidade
                          (Gabriel).
                          
             11/10/2012 - Incluir Campo flgreneg na tela (Lucas R.)
             
             28/05/2013 - Softdesk 66547 Incluir Campo flgrefin na tela (Carlos)
             
             25/04/2014 - Aumentado format do campo cdlcremp de 3 para 4
                          posicoes (Tiago/Gielow SD137074).               
............................................................................. */

{ includes/var_online.i }

{ includes/var_lcredi.i }   /*  Contem as definicoes das variaveis e forms  */

TRANS_BL:

DO TRANSACTION ON ERROR UNDO TRANS_BL, RETRY:

   DO aux_tentaler = 1 TO 10:

      FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper    AND
                         craplcr.cdlcremp = tel_cdlcremp
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF   NOT AVAILABLE craplcr   THEN
           IF   LOCKED craplcr   THEN
                DO:
                    glb_cdcritic = 374.
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
           ELSE
                glb_cdcritic = 363.
      ELSE
           glb_cdcritic = 0.

      LEAVE.

   END.  /*  Fim do DO .. TO  */

   IF   glb_cdcritic > 0   THEN
        NEXT.

   ASSIGN tel_dslcremp = craplcr.dslcremp

          tel_dssitlcr = IF craplcr.flgstlcr THEN "LIBERADA" ELSE "BLOQUEADA"

          tel_nrgrplcr = craplcr.nrgrplcr
          tel_txmensal = craplcr.txmensal
          tel_txdiaria = craplcr.txdiaria * 100
          tel_txjurfix = craplcr.txjurfix
          tel_txjurvar = craplcr.txjurvar
          tel_txpresta = craplcr.txpresta
          tel_qtdcasas = craplcr.qtdcasas
          tel_nrinipre = craplcr.nrinipre
          tel_nrfimpre = craplcr.nrfimpre
          tel_txbaspre = craplcr.txbaspre
          tel_qtcarenc = craplcr.qtcarenc
          tel_vlmaxass = craplcr.vlmaxass
          tel_vlmaxasj = craplcr.vlmaxasj
          
          tel_flgtarif = craplcr.flgtarif
          tel_flgtaiof = craplcr.flgtaiof
          tel_vltrfesp = craplcr.vltrfesp
          tel_flgcrcta = craplcr.flgcrcta

          tel_txminima = craplcr.txminima
          tel_txmaxima = craplcr.txminima

          tel_tpctrato = craplcr.tpctrato
          tel_tpdescto = craplcr.tpdescto
          tel_nrdevias = craplcr.nrdevias
          tel_cdusolcr = craplcr.cdusolcr

          tel_tplcremp = craplcr.tplcremp
          tel_dstipolc = ENTRY(craplcr.tplcremp,aux_dstipolc)

          tel_dssitlcr = IF craplcr.flgsaldo
                            THEN tel_dssitlcr + " COM SALDO"
                            ELSE tel_dssitlcr + " SEM SALDO"
                                                                 
          tel_dsoperac = craplcr.dsoperac
          tel_cdfinemp = 0
          tel_origrecu = craplcr.dsorgrec 
          tel_manterpo = craplcr.nrdialiq
          tel_flglispr = craplcr.flglispr
          tel_flgimpde = craplcr.flgimpde
          tel_flgreneg = craplcr.flgreneg
          tel_flgrefin = craplcr.flgrefin
          aux_contador = 0.

   FIND gnmodal WHERE gnmodal.cdmodali = craplcr.cdmodali NO-LOCK NO-ERROR.

   IF   AVAIL gnmodal    THEN 
        ASSIGN tel_cdmodali = gnmodal.cdmodali + "-" + gnmodal.dsmodali.
   ELSE
        ASSIGN tel_cdmodali = "".
   
   FIND gnsbmod WHERE gnsbmod.cdmodali = craplcr.cdmodali AND
                      gnsbmod.cdsubmod = craplcr.cdsubmod
                      NO-LOCK NO-ERROR.
   
   IF   AVAIL gnsbmod   THEN
        ASSIGN tel_cdsubmod = gnsbmod.cdsubmod + "-" + gnsbmod.dssubmod.
   ELSE
        ASSIGN tel_cdsubmod = "".

   /*  Descricao do modelo do contrato  */
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND
                      craptab.nmsistem = "CRED"          AND
                      craptab.tptabela = "GENERI"        AND
                      craptab.cdempres = 0               AND
                      craptab.cdacesso = "CTRATOEMPR"    AND
                      craptab.tpregist = tel_tpctrato    NO-LOCK
                      USE-INDEX craptab1 NO-ERROR.

   IF   NOT AVAILABLE craptab   THEN
        tel_dsctrato = "MODELO NAO CADASTRADO".
   ELSE
        tel_dsctrato = craptab.dstextab.

   IF   tel_tpdescto = 1   THEN
        tel_dsdescto = "C/C".
   ELSE
        tel_dsdescto = "CONSIG. FOLHA".

   CASE tel_cdusolcr:
        WHEN 0 THEN tel_dsusolcr = "NORMAL".
        WHEN 1 THEN tel_dsusolcr = "MICRO CREDITO".
        WHEN 2 THEN tel_dsusolcr = "EPR/BOLETOS".
   END.
   
   DISPLAY tel_dslcremp WITH FRAME f_lcredi.

   PAUSE 0.

   DISPLAY tel_dsoperac
           tel_tplcremp tel_dstipolc tel_flgtarif tel_flgtaiof tel_vltrfesp
           tel_flgcrcta tel_tpctrato tel_dsctrato tel_nrdevias
           tel_flgrefin tel_flgreneg
           tel_cdusolcr tel_dssitlcr tel_tpdescto tel_dsdescto tel_dsusolcr 
           tel_origrecu tel_manterpo tel_flgimpde tel_flglispr
           tel_cdmodali tel_cdsubmod
           WITH FRAME f_lcredi_2.

   RUN fontes/confirma.p (INPUT "",
                          OUTPUT aux_confirma).

   IF   aux_confirma <> "S"   THEN
        UNDO TRANS_BL, NEXT.
        
   IF   glb_cddopcao = "B"   THEN
        craplcr.flgstlcr = FALSE.
   ELSE
        craplcr.flgstlcr = TRUE.

   tel_dssitlcr = IF craplcr.flgstlcr THEN "LIBERADA" ELSE "BLOQUEADA".

   /* Grava LOG  */
  UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "       +
                                STRING(TIME,"HH:MM:SS") + "' --> '"         +
                                " Operador: " + glb_cdoperad + " "          +
                                STRING(craplcr.flgstlcr,"LIBEROU/BLOQUEOU") +
                                " a Linha de Credito "                      +  
                                STRING(craplcr.cdlcremp,"zzz9")              +  
                                " - " + craplcr.dslcremp + "."              +   
                                " >> log/lcredi.log").                      
  
   DISPLAY tel_dssitlcr WITH FRAME f_lcredi_2.

END.  /*  Fim da transacao  */

/* .......................................................................... */

