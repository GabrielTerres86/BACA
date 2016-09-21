/* .............................................................................

   Programa: Fontes/lcredif.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/94.                          Ultima atualizacao: 28/05/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta de finalidades da tela LCREDI.

   Alteracoes: 20/12/2002 - Incluir campo Valor Tarifa Especial (Junior).

               24/03/2004 - Incluido na tela campo Dias Carencia(Mirtes).

               11/06/2004 - Incluido na tela campos - Valor Maximo Linha e
                                         Valor Maximo Associado (Evandro).

               28/06/2004 - Removido - colocado em comentarios - o campo Valor
                            Maximo Linha - tel_vlmaxdiv (Evandro).

               10/08/2004 - Incluido campo tel_vlmaxasj - Valor Maximo Pessoa
                            Juridica (Evandro).

               30/08/2004 - Tratamento para tipo de desconto de emprestimo
                            (Julio)

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               17/03/2006 - Excluido campo "Conta ADM", e acrescentado 
                            tel_flgcrcta (Diego).
                            
               28/08/2007 - Adicionado campo cdusolcr micro credito(Guilherme).             
               
               24/06/2009 - Incluido campo Operacao (Gabriel).
                
               22/07/2009 - Tratar tel_cdusolcr com tipo 2 - EPR/BOLETOS.
                            (Fernando).
                            
               16/12/2009 - Alterado campo tel_dsoperac (Elton).             
               
               29/06/2010 - Incluir campo de 'listar na proposta' (Gabriel).
               
               23/05/2012 - Adicionado campo de Tarifa IOF (Lucas).
               
               11/06/2012 - Tratamento para remoção do campo EXTENT crapfin.cdlcrhab (Lucas).

               09/10/2012 - Inclur campos de modalidade e submodalidade
                            (Gabriel).                                                            
                                                  
               11/10/2012 - Incluir Campo flgreneg na tela (Lucas R.)
               
               28/05/2013 - Softdesk 66547 Incluir Campo flgrefin na tela 
                           (Carlos)                         
............................................................................. */

{ includes/var_online.i }

{ includes/var_lcredi.i }   /*  Contem as definicoes das variaveis e forms  */

FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper   AND 
                   craplcr.cdlcremp = tel_cdlcremp   NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craplcr   THEN
     DO:
         glb_cdcritic = 363.
         NEXT-PROMPT tel_cdlcremp WITH FRAME f_lcredi.
         NEXT.
     END.

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
       tel_txmaxima = craplcr.txmaxima

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
       tel_flglispr = craplcr.flglispr
       tel_flgimpde = craplcr.flgimpde
       
       tel_flgrefin = craplcr.flgrefin
       tel_flgreneg = craplcr.flgreneg

       tel_cdfinemp = 0
       tel_qtpresta = 0
       tel_inpresta = 0

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
FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                   craptab.nmsistem = "CRED"           AND
                   craptab.tptabela = "GENERI"         AND
                   craptab.cdempres = 0                AND
                   craptab.cdacesso = "CTRATOEMPR"     AND
                   craptab.tpregist = tel_tpctrato     NO-LOCK
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
        tel_flgimpde tel_origrecu tel_manterpo tel_flglispr
        tel_cdmodali tel_cdsubmod
        WITH FRAME f_lcredi_2.

CLEAR FRAME f_presta ALL NO-PAUSE.

ASSIGN tel_dsfinali = " "
       aux_contador = 0
       aux_contalin = 0.

FINALIDADES:
FOR EACH craplch WHERE craplch.cdcooper = glb_cdcooper     AND
                       craplch.cdlcrhab = craplcr.cdlcremp NO-LOCK,
   FIRST crapfin WHERE crapfin.cdcooper = glb_cdcooper     AND
                       crapfin.cdfinemp = craplch.cdfinemp NO-LOCK
                       BREAK BY craplch.cdfinemp:

    ASSIGN aux_contador = aux_contador + 1
           tel_dsfinali = tel_dsfinali + STRING(craplch.cdfinemp,"zz9") + "  " +
                                         STRING(crapfin.dsfinemp,"x(25)") + 
                                         "    ".

    IF   aux_contador = 2         OR
         LAST(craplch.cdfinemp)   THEN
         DO:
             aux_contalin = aux_contalin + 1.

             IF   aux_contalin > 8   THEN
                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE FINALIDADES:
                      
                     PAUSE MESSAGE
                          "Tecle <Entra> para continuar ou <Fim> para encerrar".
                     CLEAR FRAME f_presta ALL NO-PAUSE.

                     aux_contalin = 0.

                     LEAVE.

                  END.  /*  Fim do DO WHILE TRUE  */

             DISPLAY tel_dsfinali WITH FRAME f_finalidade.
             
             DOWN WITH FRAME f_finalidade.

             IF   LAST(craplch.cdfinemp)   THEN
                  LEAVE.

             ASSIGN tel_dsfinali = " "
                    aux_contador = 0.
         END.

END.  /*  Fim do FOR EACH  */

IF   tel_dsfinali <> " "                   AND
     KEYFUNCTION(LASTKEY) <> "END-ERROR"   THEN    /*   F4 OU FIM   */
     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        PAUSE MESSAGE "Tecle <Fim> para encerrar.".

        CLEAR FRAME f_finalidade ALL NO-PAUSE.

        LEAVE.

     END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_finalidade NO-PAUSE.

/* .......................................................................... */
