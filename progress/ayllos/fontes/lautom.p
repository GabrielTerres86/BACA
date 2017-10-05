/* .............................................................................

   Programa: Fontes/lautom.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/91.                         Ultima atualizacao: 17/11/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LAUTOM.

   Alteracoes: 05/05/97 - Alterar a selecao do craplau para listar debitos que
               nao foram debitados (Odair).

               13/05/97 - Listar os avisos para folha (Odair).

               28/07/97 - Alterado para tratar crapavs.flgproce (Deborah).

               06/10/97 - Tratar tpdaviso = 3 (Odair).

               02/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               29/06/98 - Alterado para NAO tratar o historico 289 (Edson).

               10/11/98 - Mostrar banco de pagamento (Deborah). 

               13/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               20/08/2001 - Tratar onze posicoes no numero do documento (Edson).

               31/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane. 

               01/12/2006 - Aumentado formato do campo nrdocmto(Mirtes)

               13/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)
               
               05/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
                            
               18/05/2015 - Aumentar format do nrdocmto para 25 posições 
                            (Lucas Ranghetti #284300)
                            
               23/11/2015 - Ajustado para exibir os lancamentos futuros previstos
                            de Folha de Pagamento (Andre Santos - SUPERO)

               28/01/2016 - Correcao na busca dos lancamentos de credito de Folha
                            de pagamento devido a duplicidade nos registros em 
                            query ma formada (Marcos-Supero)  
               
               15/02/2016 - Inclusao do parametro conta na chamada da
                            carrega_dados_tarifa_cobranca. (Jaison/Marcos)

			   17/11/2016 - Ajuste para retirar condicao que trata o formato
						    a ser utilizado para apresentar o valor do lancamento
							(Adriano - SD 548762).
               
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }

DEF        VAR h-b1wgen0153 AS HANDLE                                   NO-UNDO.

DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"              NO-UNDO.
DEF        VAR tel_nmprimtl AS CHAR    FORMAT "x(40)"                   NO-UNDO.
DEF        VAR tel_vlstotal AS DECIMAL FORMAT "zzz,zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF        VAR tel_vllimcre AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"      NO-UNDO.
DEF        VAR tel_dshistor AS CHAR    FORMAT "x(12)"                   NO-UNDO.
DEF        VAR tel_nrconven AS INT     FORMAT "zzz"                     NO-UNDO.
DEF        VAR tel_vllanaut AS CHAR    FORMAT "x(10)"                   NO-UNDO.
DEF        VAR tel_dtmvtolt AS DATE    FORMAT "99/99/99"                NO-UNDO.
DEF        VAR tel_cdagenci AS INT     FORMAT "zz9"                     NO-UNDO.
DEF        VAR tel_cdbccxlt AS INT     FORMAT "zz9"                     NO-UNDO.
DEF        VAR tel_nrdolote AS INT     FORMAT "zzzzz9"                  NO-UNDO.
DEF        VAR tel_nrdocmto AS CHAR    FORMAT "x(12)"                   NO-UNDO.
DEF        VAR tel_cdbccxpg AS INT     FORMAT "zzz"                     NO-UNDO.
DEF        VAR tel_dtmvtopg AS CHAR    FORMAT "x(08)"                   NO-UNDO.

DEF        VAR aux_contador AS INT     FORMAT "99"                      NO-UNDO.
DEF        VAR aux_stimeout AS INT                                      NO-UNDO.

DEF        VAR aux_cdhistor AS INTE                                     NO-UNDO.
DEF        VAR aux_cdhisest AS INTE                                     NO-UNDO.
DEF        VAR aux_dtdivulg AS DATE                                     NO-UNDO.
DEF        VAR aux_dtvigenc AS DATE                                     NO-UNDO.
DEF        VAR aux_cdfvlcop AS INTE                                     NO-UNDO.
DEF        VAR aux_vltarifa AS DECI                                     NO-UNDO.
DEF        VAR aux_cdmotivo AS CHAR                                     NO-UNDO.

DEF        VAR aux_vllancto AS DECI                                     NO-UNDO.
                                                                  
DEF        VAR aux_regexist AS LOGICAL                                  NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                                  NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                     NO-UNDO.

FORM SPACE(1)                                               
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM tel_nrdconta AT  2 LABEL "Conta/dv" AUTO-RETURN
                        HELP "Informe o numero da conta do associado."

     tel_nmprimtl AT 24 LABEL "Titular"
     SKIP (1)
     tel_vllimcre AT  2 LABEL "Limite de Credito"
     tel_vlstotal AT 42 LABEL "Saldo Total"
     SKIP (1)
     "Debito   Historico    Cnv      Valor" AT  1
     "Data   PA  Bcx   Lote Pag   Documento"         AT 40
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_lautom.

FORM tel_dtmvtopg  
     tel_dshistor 
     tel_nrconven 
     tel_vllanaut 
     tel_dtmvtolt 
     tel_cdagenci
     tel_cdbccxlt 
     tel_nrdolote  FORMAT "zzzzz9"
     tel_cdbccxpg 
     tel_nrdocmto 
     WITH ROW 12 COLUMN 2 OVERLAY 9 DOWN NO-LABEL NO-BOX FRAME f_lanctos.

VIEW FRAME f_moldura.

PAUSE (0).

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_lautom NO-PAUSE.
               CLEAR FRAME f_lanctos ALL NO-PAUSE.
               glb_cdcritic = 0.
           END.

      UPDATE tel_nrdconta WITH FRAME f_lautom

      EDITING:

         aux_stimeout = 0.

         DO WHILE TRUE:

            READKEY PAUSE 1.

            IF   LASTKEY = -1   THEN
                 DO:
                     aux_stimeout = aux_stimeout + 1.

                     IF   aux_stimeout > glb_stimeout   THEN
                          QUIT.

                     NEXT.
                 END.

            APPLY LASTKEY.

            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

      END.  /*  Fim do EDITING  */

      glb_nrcalcul = tel_nrdconta.

      RUN fontes/digfun.p.

      IF   NOT glb_stsnrcal   THEN
           DO:
               glb_cdcritic = 8.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_lautom.
               NEXT.
           END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "LAUTOM"   THEN
                 DO:
                     HIDE FRAME f_lautom.
                     HIDE FRAME f_lanctos.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i}
            aux_cddopcao = glb_cddopcao.
        END.

   FIND crapass WHERE crapass.cdcooper = glb_cdcooper    AND
                      crapass.nrdconta = tel_nrdconta    NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapass   THEN
        DO:
            glb_cdcritic = 9.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_lautom.
            NEXT.
        END.

   ASSIGN tel_nmprimtl = crapass.nmprimtl
          tel_vllimcre = crapass.vllimcre
          tel_vlstotal = 0.

/* FIND crapsld OF crapass NO-LOCK NO-ERROR.*/

   FIND crapsld WHERE crapsld.cdcooper = glb_cdcooper       AND
                      crapsld.nrdconta = crapass.nrdconta   NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapsld   THEN
        DO:
            glb_cdcritic = 10.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_lautom.
            NEXT.
        END.

   FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper        AND
                          craplcm.nrdconta = crapsld.nrdconta    AND
                          craplcm.dtmvtolt = glb_dtmvtolt        AND
                          craplcm.cdhistor <> 289                
                          USE-INDEX craplcm2 NO-LOCK:

       FIND craphis NO-LOCK WHERE 
                            craphis.cdcooper = craplcm.cdcooper AND 
                            craphis.cdhistor = craplcm.cdhistor NO-ERROR.

       IF   NOT AVAILABLE craphis   THEN
            DO:
                glb_cdcritic = 80.
                LEAVE.
            END.

       IF   craphis.inhistor = 1    OR
            craphis.inhistor = 2    OR
            craphis.inhistor = 3    OR
            craphis.inhistor = 4    OR
            craphis.inhistor = 5    THEN
            tel_vlstotal = tel_vlstotal + craplcm.vllanmto.
       ELSE
       IF   craphis.inhistor = 11   OR
            craphis.inhistor = 12   OR
            craphis.inhistor = 13   OR
            craphis.inhistor = 14   OR
            craphis.inhistor = 15   THEN
            tel_vlstotal = tel_vlstotal - craplcm.vllanmto.

   END.  /*  Fim do FOR EACH  --  Leitura dos lancamentos  */

   IF   glb_cdcritic > 0   THEN
        NEXT.

   ASSIGN tel_vlstotal = tel_vlstotal     + crapsld.vlsdbloq +
                         crapsld.vlsdblpr + crapsld.vlsdblfp +
                         crapsld.vlsddisp + crapsld.vlsdchsl

          aux_regexist = FALSE
          aux_flgretor = FALSE
          aux_contador = 0.

   DISPLAY tel_nmprimtl tel_vlstotal tel_vllimcre WITH FRAME f_lautom.

   CLEAR FRAME f_lanctos ALL NO-PAUSE.

   FOR EACH craplau WHERE craplau.cdcooper = glb_cdcooper   AND
                          craplau.nrdconta = tel_nrdconta   AND
                          craplau.dtmvtopg > 04/30/1997     AND
                          craplau.dtdebito = ?              NO-LOCK:

       FIND craphis NO-LOCK WHERE 
                               craphis.cdcooper = craplau.cdcooper AND 
                               craphis.cdhistor = craplau.cdhistor NO-ERROR.

       IF   NOT AVAILABLE craphis OR craphis.indebfol > 0 THEN
            NEXT.

       ASSIGN aux_regexist = TRUE
              aux_contador = aux_contador + 1.

       IF   aux_contador = 1   THEN
            IF   aux_flgretor   THEN
                 DO:
                     PAUSE MESSAGE
                          "Tecle <Entra> para continuar ou <Fim> para encerrar".
                     CLEAR FRAME f_lanctos ALL NO-PAUSE.
                 END.
            ELSE
                 aux_flgretor = TRUE.

       FIND craphis NO-LOCK WHERE craphis.cdcooper = craplau.cdcooper AND 
                                  craphis.cdhistor = craplau.cdhistor NO-ERROR.

       IF   NOT AVAILABLE craphis   THEN
            tel_dshistor = STRING(craplau.cdhistor).
       ELSE
            tel_dshistor = craphis.dshistor.

       IF   CAN-DO("21,26,521,526",STRING(craplau.cdhistor))   THEN
            tel_nrdocmto = STRING(craplau.nrdocmto,"zzzzz,zz9,9").
       ELSE
       IF   LENGTH(STRING(craplau.nrdocmto)) < 10   THEN
            tel_nrdocmto = STRING(craplau.nrdocmto,"zzz,zzz,zz9").
       ELSE
            tel_nrdocmto = SUBSTR(STRING(craplau.nrdocmto,"9999999999999999999999999"),
                                  15,11).

       ASSIGN tel_dtmvtopg = STRING(craplau.dtmvtopg,"99/99/99")
			  tel_vllanaut = STRING(craplau.vllanaut,"zzz,zz9.99")
              tel_nrconven = 0
              tel_dtmvtolt = craplau.dtmvtolt
              tel_cdagenci = craplau.cdagenci
              tel_cdbccxlt = craplau.cdbccxlt
              tel_nrdolote = craplau.nrdolote
              tel_cdbccxpg = craplau.cdbccxpg.

       DISPLAY tel_dtmvtopg     tel_dshistor     tel_nrconven
               tel_vllanaut     tel_dtmvtolt     tel_cdagenci
               tel_cdbccxlt     tel_nrdolote     tel_nrdocmto
               tel_cdbccxpg WITH FRAME f_lanctos.

       IF   aux_contador = 9   THEN
            aux_contador = 0.
       ELSE
            DOWN WITH FRAME f_lanctos.

   END.  /*  Fim do FOR EACH  --  Leitura dos lancamentos automaticos  */

   IF   KEYFUNCTION(LASTKEY) <> "END-ERROR"   THEN DO:   /*   F4 OU FIM   */

        FOR EACH crapavs WHERE crapavs.cdcooper = glb_cdcooper       AND
                               crapavs.nrdconta = tel_nrdconta       AND
           CAN-DO("1,3",STRING(crapavs.tpdaviso))                    AND
                               crapavs.insitavs = 0                  AND
                               crapavs.flgproce = FALSE              NO-LOCK:

           ASSIGN aux_regexist = TRUE
                  aux_contador = aux_contador + 1.

           IF  aux_contador = 1   THEN
               IF  aux_flgretor   THEN DO:
                   PAUSE MESSAGE
                       "Tecle <Entra> para continuar ou <Fim> para encerrar".
                   CLEAR FRAME f_lanctos ALL NO-PAUSE.
               END.
           ELSE
               aux_flgretor = TRUE.

           FIND craphis NO-LOCK WHERE craphis.cdcooper = crapavs.cdcooper AND
                                      craphis.cdhistor = crapavs.cdhistor NO-ERROR.

           IF  NOT AVAILABLE craphis   THEN
               tel_dshistor = STRING(crapavs.cdhistor).
           ELSE
               tel_dshistor = craphis.dshistor.

           tel_vllanaut = STRING((crapavs.vllanmto - crapavs.vldebito)
                                 ,"zzz,zz9.99").

           IF  CAN-DO("21,26",STRING(crapavs.cdhistor))   THEN
               tel_nrdocmto = STRING(crapavs.nrdocmto,"zzzzz,zz9,9").
           ELSE
           IF  LENGTH(STRING(crapavs.nrdocmto)) < 10   THEN
               tel_nrdocmto = STRING(crapavs.nrdocmto,"zzz,zzz,zz9").
           ELSE
               tel_nrdocmto = STRING(crapavs.nrdocmto,"zzzzzzzzzz9").

           ASSIGN tel_dtmvtopg = IF  crapavs.tpdaviso = 1
                                 THEN "FOLHA"
                                 ELSE STRING(crapavs.dtdebito,"99/99/99")
                  tel_nrconven = crapavs.nrconven
                  tel_dtmvtolt = crapavs.dtrefere
                  tel_cdbccxlt = 0
                  tel_cdagenci = 0
                  tel_nrdolote = 0
                  tel_cdbccxpg = 0.

           DISPLAY tel_dtmvtopg     tel_dshistor    tel_nrconven
                   tel_vllanaut     tel_dtmvtolt
                   tel_cdagenci  WHEN tel_cdagenci > 0
                   tel_cdbccxlt  WHEN tel_cdbccxlt > 0
                   tel_nrdolote  WHEN tel_nrdolote > 0
                   tel_nrdocmto
                   tel_cdbccxpg WITH FRAME f_lanctos.

           IF   aux_contador = 9   THEN
                aux_contador = 0.
           ELSE
               DOWN WITH FRAME f_lanctos.

       END.  /*  Fim do FOR EACH  --  Leitura dos lancamentos automaticos  */

       /* Lancamentos de debitos de folha */
       FOR EACH crappfp WHERE crappfp.cdcooper =  glb_cdcooper 
                          AND crappfp.idsitapr > 3 /* Aprovados */
                          AND crappfp.idsitapr <> 6 /* Transacao Pendente */
                          AND crappfp.flsitdeb = 0 /* Ainda nao debitado */
                          NO-LOCK
          ,EACH craplfp WHERE craplfp.cdcooper = crappfp.cdcooper
                          AND craplfp.cdempres = crappfp.cdempres
                          AND craplfp.nrseqpag = crappfp.nrseqpag                          
                          NO-LOCK
          ,EACH crapemp WHERE crapemp.cdcooper = crappfp.cdcooper
                          AND crapemp.cdempres = crappfp.cdempres
                          AND crapemp.nrdconta = tel_nrdconta
                          NO-LOCK
          ,EACH crapofp WHERE crapofp.cdcooper = craplfp.cdcooper
                          AND crapofp.cdorigem = craplfp.cdorigem
                          NO-LOCK
          ,EACH craphis WHERE craphis.cdcooper = crapofp.cdcooper
                          AND (
                               (    crapemp.idtpempr = "C"
                                AND craphis.cdhistor = crapofp.cdhsdbcp
                               )
                             OR(    crapemp.idtpempr = "O"
                                AND craphis.cdhistor = crapofp.cdhisdeb
                               )
                              )
                          NO-LOCK BREAK BY craplfp.cdorigem:

            /* Incrementa o valor dos lancamentos */
            ASSIGN aux_vllancto = aux_vllancto + craplfp.vllancto.

            IF  LAST-OF(craplfp.cdorigem) THEN DO:

                ASSIGN aux_regexist = TRUE
                       aux_contador = aux_contador + 1.

                IF  aux_contador = 1   THEN                                        
                    IF  aux_flgretor   THEN DO:
                        PAUSE MESSAGE
                            "Tecle <Entra> para continuar ou <Fim> para encerrar".
                        CLEAR FRAME f_lanctos ALL NO-PAUSE.
                    END.
                ELSE
                     aux_flgretor = TRUE.
                
                ASSIGN tel_vllanaut = STRING(aux_vllancto,"zzz,zz9.99")
                       tel_dshistor = craphis.dshistor
                       tel_nrdocmto = STRING(crappfp.nrseqpag,"zzzzzzzzzz9")
                       tel_dtmvtopg = STRING(crappfp.dtdebito,"99/99/99")
                       tel_nrconven = 0
                       tel_dtmvtolt = crappfp.dtmvtolt
                       tel_cdbccxlt = 0
                       tel_cdagenci = 0
                       tel_nrdolote = 0
                       tel_cdbccxpg = 0
                       aux_vllancto = 0.
           
                DISPLAY tel_dtmvtopg     tel_dshistor    tel_nrconven
                        tel_vllanaut     tel_dtmvtolt
                        tel_cdagenci WHEN tel_cdagenci > 0
                        tel_cdbccxlt WHEN tel_cdbccxlt > 0
                        tel_nrdolote WHEN tel_nrdolote > 0
                        tel_nrdocmto
                        tel_cdbccxpg WITH FRAME f_lanctos.

                IF  aux_contador = 9   THEN
                    aux_contador = 0.
                ELSE
                    DOWN WITH FRAME f_lanctos.
            END.
       END. /* Fim do FOR lancamentos de debitos de folha */

       /* Lancamentos de Debitos de Tarifas */
       FOR EACH crappfp WHERE crappfp.cdcooper =  glb_cdcooper
                          AND crappfp.idsitapr > 3 /* Aprovados */
                          AND crappfp.idsitapr <> 6 /* Transacao Pendente */
                          AND crappfp.flsittar = 0 /* Ainda nao debitado a tarifa */
                          AND crappfp.vltarapr > 0 /* Com tarifa a cobrar */
                          NO-LOCK
          ,EACH crapemp WHERE crapemp.cdcooper = crappfp.cdcooper
                          AND crapemp.cdempres = crappfp.cdempres
                          AND crapemp.nrdconta = tel_nrdconta
                          NO-LOCK BY crappfp.nrseqpag:

            ASSIGN aux_regexist = TRUE
                   aux_contador = aux_contador + 1.
          
            IF  aux_contador = 1   THEN                                        
                IF  aux_flgretor   THEN DO:
                    PAUSE MESSAGE
                        "Tecle <Entra> para continuar ou <Fim> para encerrar".
                    CLEAR FRAME f_lanctos ALL NO-PAUSE.
                END.
            ELSE
                aux_flgretor = TRUE.

            ASSIGN aux_vllancto = crappfp.qtlctpag * crappfp.vltarapr
                   tel_vllanaut = STRING(aux_vllancto,"zzz,zz9.99")
                   tel_nrdocmto = STRING(crappfp.nrseqpag,"zzzzzzzzzz9")
                   tel_dtmvtopg = STRING(crappfp.dtcredit,"99/99/99")
                   tel_nrconven = 0
                   tel_dtmvtolt = crappfp.dtmvtolt
                   tel_cdbccxlt = 0
                   tel_cdagenci = 0
                   tel_nrdolote = 0
                   tel_cdbccxpg = 0
                   tel_dshistor = "".

            CASE  crappfp.idopdebi:
                WHEN 0 THEN
                    ASSIGN aux_cdmotivo = "D0".
                WHEN 1 THEN
                    ASSIGN aux_cdmotivo = "D-1".
                WHEN 2 THEN
                    ASSIGN aux_cdmotivo = "D-2".
            END CASE.
            
            IF  NOT VALID-HANDLE(h-b1wgen0153) THEN
                RUN sistema/generico/procedures/b1wgen0153.p
                PERSISTENT SET h-b1wgen0153.

            RUN carrega_dados_tarifa_cobranca IN h-b1wgen0153
                                     (INPUT crappfp.cdcooper
                                     ,INPUT crapemp.nrdconta
                                     ,INPUT crapemp.cdcontar
                                     ,INPUT "FOLHA"
                                     ,INPUT crappfp.idopdebi
                                     ,INPUT aux_cdmotivo
                                     ,INPUT 2
                                     ,INPUT crappfp.vllctpag
                                     ,INPUT 'LAUTOM'
									 ,INPUT 0 /* Nao apurar */
                                     ,OUTPUT aux_cdhistor
                                     ,OUTPUT aux_cdhisest
                                     ,OUTPUT aux_vltarifa
                                     ,OUTPUT aux_dtdivulg
                                     ,OUTPUT aux_dtvigenc
                                     ,OUTPUT aux_cdfvlcop
                                     ,OUTPUT TABLE tt-erro).

            IF  VALID-HANDLE(h-b1wgen0153) THEN
                DELETE PROCEDURE h-b1wgen0153.

            FIND FIRST craphis WHERE craphis.cdcooper = glb_cdcooper
                                 AND craphis.cdhistor = aux_cdhistor
                                 NO-LOCK NO-ERROR.

            IF  AVAIL craphis THEN
                ASSIGN tel_dshistor = craphis.dshistor.

            DISPLAY tel_dtmvtopg     tel_dshistor    tel_nrconven
                    tel_vllanaut     tel_dtmvtolt
                    tel_cdagenci WHEN tel_cdagenci > 0
                    tel_cdbccxlt WHEN tel_cdbccxlt > 0
                    tel_nrdolote WHEN tel_nrdolote > 0
                    tel_nrdocmto
                    tel_cdbccxpg WITH FRAME f_lanctos.

            IF  aux_contador = 9   THEN
                aux_contador = 0.
            ELSE
                DOWN WITH FRAME f_lanctos.

       END. /* Fim lancamentos de debitos de tarifas */


/*        /* Lancamentos de Creditos de Folha */                                                                   */
/*        FOR EACH crappfp WHERE crappfp.cdcooper =  glb_cdcooper                                                  */
/*                           AND crappfp.idsitapr > 3 /* Aprovados */                                              */
/*                           AND crappfp.flsitcre = 0 /* Pagamento ainda não creditado */                          */
/*                           NO-LOCK                                                                               */
/*           ,EACH craplfp WHERE craplfp.cdcooper = crappfp.cdcooper                                               */
/*                           AND craplfp.cdempres = crappfp.cdempres                                               */
/*                           AND craplfp.nrseqpag = crappfp.nrseqpag                                               */
/*                           AND craplfp.idtpcont = "C" /* Somente associados Cecred */                            */
/*                           AND NOT CAN-DO(craplfp.idsitlct,"E,C") /* Desconsiderar os com erros ou creditados */ */
/*                           AND craplfp.nrdconta = tel_nrdconta                                                   */
/*                           NO-LOCK                                                                               */
/*           ,EACH crapemp WHERE crapemp.cdcooper = crappfp.cdcooper                                               */
/*                           AND crapemp.cdempres = crappfp.cdempres                                               */
/*                           NO-LOCK                                                                               */
/*           ,EACH crapofp WHERE crapofp.cdcooper = craplfp.cdcooper                                               */
/*                           AND crapofp.cdorigem = craplfp.cdorigem                                               */
/*                           NO-LOCK                                                                               */
/*           ,EACH craphis WHERE craphis.cdcooper = crapofp.cdcooper                                               */
/*                           AND (                                                                                 */
/*                                (    crapemp.idtpempr = 'C'                                                      */
/*                                 AND craphis.cdhistor = crapofp.cdhscrcp                                         */
/*                                )                                                                                */
/*                            OR  (    crapemp.idtpempr = 'O'                                                      */
/*                                 AND craphis.cdhistor = crapofp.cdhiscre                                         */
/*                                )                                                                                */
/*                               )                                                                                 */
/*                           NO-LOCK BY crappfp.nrseqpag                                                           */
/*                                   BY craplfp.nrseqlfp:                                                          */
/*                                                                                                                 */
/*            ASSIGN aux_regexist = TRUE                                                                           */
/*                    aux_contador = aux_contador + 1.                                                             */
/*                                                                                                                 */
/*             IF  aux_contador = 1   THEN                                                                         */
/*                 IF  aux_flgretor   THEN DO:                                                                     */
/*                     PAUSE MESSAGE                                                                               */
/*                         "Tecle <Entra> para continuar ou <Fim> para encerrar".                                  */
/*                     CLEAR FRAME f_lanctos ALL NO-PAUSE.                                                         */
/*                 END.                                                                                            */
/*             ELSE                                                                                                */
/*                 aux_flgretor = TRUE.                                                                            */
/*                                                                                                                 */
/*             ASSIGN aux_vllancto = craplfp.vllancto                                                              */
/*                    tel_vllanaut = STRING(aux_vllancto,"zzz,zz9.99")                                             */
/*                    tel_nrdocmto = STRING(crappfp.nrseqpag,"zzzz9") + STRING(craplfp.nrseqlfp,"999999")          */
/*                    tel_dtmvtopg = STRING(crappfp.dtcredit,"99/99/99")                                           */
/*                    tel_nrconven = 0                                                                             */
/*                    tel_dtmvtolt = crappfp.dtmvtolt                                                              */
/*                    tel_cdbccxlt = 0                                                                             */
/*                    tel_cdagenci = 0                                                                             */
/*                    tel_nrdolote = 0                                                                             */
/*                    tel_cdbccxpg = 0                                                                             */
/*                    tel_dshistor = craphis.dshistor.                                                             */
/*                                                                                                                 */
/*             DISPLAY tel_dtmvtopg     tel_dshistor    tel_nrconven                                               */
/*                     tel_vllanaut     tel_dtmvtolt                                                               */
/*                     tel_cdagenci WHEN tel_cdagenci > 0                                                          */
/*                     tel_cdbccxlt WHEN tel_cdbccxlt > 0                                                          */
/*                     tel_nrdolote WHEN tel_nrdolote > 0                                                          */
/*                     tel_nrdocmto                                                                                */
/*                     tel_cdbccxpg WITH FRAME f_lanctos.                                                          */
/*                                                                                                                 */
/*             IF  aux_contador = 9   THEN                                                                         */
/*                 aux_contador = 0.                                                                               */
/*             ELSE                                                                                                */
/*                 DOWN WITH FRAME f_lanctos.                                                                      */
/*                                                                                                                 */
/*        END. /* FIM do Lancamentos de Creditos de Folha */                                                       */


   END. /* FIM do F4 OU FIM   */

   IF   NOT aux_regexist   THEN
        DO:
            glb_cdcritic = 81.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

