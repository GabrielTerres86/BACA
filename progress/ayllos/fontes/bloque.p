/* .............................................................................

   Programa: Fontes/bloque.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                    Ultima atualizacao: 28/08/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela BLOQUE.

   Alteracoes: 05/03/98 - Tratar datas do milenio (Odair)

               26/06/98 - Alterado para NAO tratar o historico 289 (Edson).

               30/10/00 - Alterar lote p/6 posicoes (Margarete/Planner).

             08/09/2004 - Tratar conta integracao (Margarete).
             
             31/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                          (Evandro).     
                                  
             23/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando 
                 
             02/10/2006 - Alterado help do campo "Conta/dv" (Elton).    

             08/05/2008 - Ajuste comando FIND (craphis) utilizava FOR p/ acesso
                          (Sidnei - Precise)
                          
             30/11/2010 - 001 - Alterado format "x(40)" para "x(47)"
                            KBASE - Kamila Ploharski de Oliveira

             28/08/2013 - Nova forma de chamar as agências, de PAC agora 
                          a escrita será PA (André Euzébio - Supero).
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nmprimtl AS CHAR    FORMAT "x(47)"                NO-UNDO. /*001*/
DEF        VAR tel_vlsdbloq AS DECIMAL FORMAT "zz,zzz,zzz,zz9.99-"   NO-UNDO.
DEF        VAR tel_vlsdblpr AS DECIMAL FORMAT "zz,zzz,zzz,zz9.99-"   NO-UNDO.
DEF        VAR tel_vlsdblfp AS DECIMAL FORMAT "zz,zzz,zzz,zz9.99-"   NO-UNDO.
DEF        VAR tel_dshistor AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR tel_dssititg AS CHAR    FORMAT "x(07)"                NO-UNDO.   

DEF        VAR aux_contador AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR aux_stimeout AS INT                                   NO-UNDO.

DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM tel_nrdconta AT  2 LABEL "Conta/dv" AUTO-RETURN
                        HELP "Informe o numero da conta."
     tel_nmprimtl AT 24 LABEL "Titular"
     crapass.nrdctitg AT 22 LABEL "Conta/ITG"   
     tel_dssititg     NO-LABEL
     SKIP
     "Bloqueado" AT 13 "Praca" AT 45 "Fora da Praca" AT 64
     SKIP
     tel_vlsdbloq AT  4 NO-LABEL
     tel_vlsdblpr AT 32 NO-LABEL
     tel_vlsdblfp AT 59 NO-LABEL
     SKIP (1)
    "Liber   Historico               Valor    Data   PA Bcx    Lote  Documento"
     AT 5
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_bloque.

FORM crapdpb.dtliblan AT  1  FORMAT "99/99/9999"
     tel_dshistor     AT 12
     crapdpb.vllanmto AT 28  FORMAT "zz,zzz,zz9.99"
     crapdpb.dtmvtolt AT 42  FORMAT "99/99/9999"
     crapdpb.cdagenci AT 52
     crapdpb.cdbccxlt AT 56
     crapdpb.nrdolote AT 60  FORMAT "zzz,zz9"
     crapdpb.nrdocmto AT 68
     WITH ROW 13 COLUMN 2 OVERLAY 8 DOWN NO-LABEL NO-BOX FRAME f_lanctos.

VIEW FRAME f_moldura.

PAUSE (0).

glb_cddopcao = "C".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE tel_nrdconta WITH FRAME f_bloque

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
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_bloque NO-PAUSE.
               CLEAR FRAME f_lanctos ALL NO-PAUSE.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_bloque.
               glb_cdcritic = 0.
               NEXT.
           END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "BLOQUE"   THEN
                 DO:
                     HIDE FRAME f_bloque.
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

   ASSIGN tel_vlsdbloq = 0
          tel_vlsdblpr = 0
          tel_vlsdblfp = 0.

   FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                      crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapass   THEN
        DO:
            glb_cdcritic = 9.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            CLEAR FRAME f_bloque  NO-PAUSE.
            CLEAR FRAME f_lanctos ALL NO-PAUSE.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_bloque.
            glb_cdcritic = 0.
            NEXT.
        END.

   tel_nmprimtl = crapass.nmprimtl.
   
   { includes/sititg.i }

   /*FIND crapsld OF crapass NO-LOCK NO-ERROR.*/
   FIND crapsld WHERE crapsld.cdcooper = glb_cdcooper     AND
                      crapsld.nrdconta = crapass.nrdconta NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapsld   THEN
        DO:
            glb_cdcritic = 10.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            CLEAR FRAME f_bloque  NO-PAUSE.
            CLEAR FRAME f_lanctos ALL NO-PAUSE.
            DISPLAY tel_nmprimtl WITH FRAME f_bloque.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_bloque.
            glb_cdcritic = 0.
            NEXT.
        END.

   FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper       AND
                          craplcm.nrdconta = crapsld.nrdconta   AND
                          craplcm.dtmvtolt = glb_dtmvtolt       AND
                          craplcm.cdhistor <> 289
                          USE-INDEX craplcm2 NO-LOCK:

       FIND craphis NO-LOCK WHERE craphis.cdcooper = craplcm.cdcooper AND
                                  craphis.cdhistor = craplcm.cdhistor NO-ERROR.
       IF   NOT AVAILABLE craphis   THEN
            DO:
                glb_cdcritic = 80.
                LEAVE.
            END.

       IF   craphis.inhistor =  1   OR
            craphis.inhistor =  2   OR
            craphis.inhistor = 11   OR
            craphis.inhistor = 12   THEN
            NEXT.

       IF   craphis.inhistor = 3   THEN
            tel_vlsdbloq = tel_vlsdbloq + craplcm.vllanmto.
       ELSE
       IF   craphis.inhistor = 4   THEN
            tel_vlsdblpr = tel_vlsdblpr + craplcm.vllanmto.
       ELSE
       IF   craphis.inhistor = 5   THEN
            tel_vlsdblfp = tel_vlsdblfp + craplcm.vllanmto.
       ELSE
       IF   craphis.inhistor = 13   THEN
            tel_vlsdbloq = tel_vlsdbloq - craplcm.vllanmto.
       ELSE
       IF   craphis.inhistor = 14   THEN
            tel_vlsdblpr = tel_vlsdblpr - craplcm.vllanmto.
       ELSE
       IF   craphis.inhistor = 15   THEN
            tel_vlsdblfp = tel_vlsdblfp - craplcm.vllanmto.
       ELSE
            DO:
                glb_cdcritic = 83.
                LEAVE.
            END.

   END.  /*  Fim do FOR EACH  --  Leitura dos lancamentos do dia  */

   IF   glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.

   ASSIGN tel_vlsdbloq = tel_vlsdbloq + crapsld.vlsdbloq
          tel_vlsdblpr = tel_vlsdblpr + crapsld.vlsdblpr
          tel_vlsdblfp = tel_vlsdblfp + crapsld.vlsdblfp
          aux_regexist = FALSE
          aux_contador = 0.

   IF   tel_vlsdbloq > 0   OR
        tel_vlsdblpr > 0   OR
        tel_vlsdblfp > 0   THEN
        DO:
            { includes/bloque.i }
        END.
   ELSE
        DO:
            DISPLAY tel_nmprimtl crapass.nrdctitg tel_dssititg tel_vlsdbloq 
                    tel_vlsdblpr tel_vlsdblfp
                    WITH FRAME f_bloque.

            glb_cdcritic = 49.
            RUN fontes/critic.p.
            CLEAR FRAME f_lanctos ALL NO-PAUSE.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
