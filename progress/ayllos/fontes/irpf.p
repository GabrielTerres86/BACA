/* .............................................................................

   Programa: Fontes/irpf.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Julho/95.                       Ultima atualizacao: 18/03/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Apresentar os registros IRPF  na tela IRPF.

   Alteracoes: 21/03/97 - Alterado para somar no saldo das aplicacoes e rendi-
                          mentos o valor da Poupanca Programada (Edson).

               19/02/98 - Alterado para somar o valor do abono no rendimento
                          das aplicacoes e poup.progr. Vide programa
                          fontes/impextir96.p (Deborah).

               01/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               26/01/99 - Tratar abono do IOF (Deborah).

               09/02/99 - Usar as 12 ocorrencias de rendimento das aplicacoes
                          (Deborah).

             03/01/2005 - Descontar IRRF pago dos rendimentos (Margarete).
             
             01/04/2005 - Mostrar IRRF cobrado (Edson).
             
             17/01/2006 - Incluir ajustes do IR nos calculos (Edson).
             
             27/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
             
             18/03/2010 - Incluir dados das aplicacoes RDCPOS e RDCPRE (Magui)
             
             12/01/2011 - Incluido o format de 46 para o nmprimtl
                          (Kbase - Gilnei)
             
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_dsmoeuti AS CHAR    FORMAT "x(20)"                NO-UNDO.

DEF        VAR aux_contador AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR aux_stimeout AS INT                                   NO-UNDO.
DEF        VAR aux_cdacesso AS CHAR                                  NO-UNDO.

DEF        VAR tel_dtanoref AS INT     FORMAT "zzzz"                 NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_vlconsld AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlconjur AS DECIMAL FORMAT "999999.99999999"      NO-UNDO.

DEF        VAR tot_qtextcta AS INT                                   NO-UNDO.
DEF        VAR tot_qtextepr AS INT                                   NO-UNDO.
DEF        VAR tot_qtextimp AS INT                                   NO-UNDO.
DEF        VAR tot_qtextrda AS INT                                   NO-UNDO.

DEF        VAR rel_vldjuros AS DECIMAL                               NO-UNDO.
DEF        VAR rel_qtjaicmf AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vlrenapl AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vldoirrf AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vlcpmfpg AS DECIMAL                               NO-UNDO.

FORM "Aplicacoes de Renda Fixa (Rendimentos) ...............:" AT  3
     rel_vlrenapl     FORMAT "zzz,zzz,zzz,zz9.99-"  AT 58
     SKIP
     "Aplicacoes de Renda Fixa (Saldo) .....................:" AT  3
     crapdir.vlsdapli FORMAT "zzz,zzz,zzz,zz9.99-"  AT 58
     SKIP
     "Deposito em C/C de Dep. a Vista ou de Investimento ...:" AT  3
     crapdir.vlsdccdp FORMAT "zzz,zzz,zzz,zz9.99-"  AT 58
     SKIP
     "Saldo Devedor de Emprestimos .........................:" AT  3
     crapdir.vlsddvem FORMAT "zzz,zzz,zzz,zz9.99-"  AT 58
     SKIP
     "Saldo das Cotas de Capital ...........................:" AT  3
     crapdir.vlttccap FORMAT "zzz,zzz,zzz,zz9.99-"  AT 58
     SKIP(1)
     "CPMF Pago no Ano .....................................:" AT  3
     rel_vlcpmfpg     FORMAT "zzz,zzz,zzz,zz9.99-"  AT 58
     SKIP
     "Imposto de Renda Retido na Fonte Sobre Aplicacoes ....:"   AT  3
     rel_vldoirrf     FORMAT "zzz,zzz,zzz,zz9.99-"  AT 58
     SKIP(1)
     "Juros ao Capital Creditado no Ano ....................:" AT  3
     rel_vldjuros     FORMAT "zzz,zzz,zzz,zz9.99-"  AT 58
     WITH ROW 10 COLUMN 2 OVERLAY NO-LABEL NO-BOX FRAME f_histori.

FORM tel_nrdconta     LABEL "Conta/Dv"              AT  3
     crapass.nmprimtl LABEL "Titular"               FORMAT "x(46)"
     SKIP(1)
     tel_dtanoref     LABEL "Ano Ref."              AT  3  AUTO-RETURN
     tel_dsmoeuti     NO-LABEL                      AT 56
     WITH ROW 6 COLUMN 2 OVERLAY  SIDE-LABELS NO-BOX FRAME f_irpf.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

VIEW FRAME f_moldura.

PAUSE(0).

VIEW FRAME f_irpf.

PAUSE(0).

VIEW FRAME f_histori.

PAUSE(0).

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   NEXT-PROMPT tel_nrdconta WITH FRAME f_irpf.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_histori ALL   NO-PAUSE.
               glb_cdcritic = 0.
           END.

      UPDATE  tel_nrdconta tel_dtanoref WITH FRAME f_irpf

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

      IF   tel_dtanoref = 0
      or   tel_dtanoref < 1000 THEN
           DO:
               glb_cdcritic = 013.
               NEXT-PROMPT tel_dtanoref WITH FRAME f_irpf.
               NEXT.
           END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "IRPF"   THEN
                 DO:
                     HIDE FRAME f_histori.
                     HIDE FRAME f_irpf.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   glb_nrcalcul = tel_nrdconta.

   RUN fontes/digfun.p.

   IF   NOT glb_stsnrcal THEN
        DO:
            glb_cdcritic = 8.
            CLEAR FRAME f_irpf.
            NEXT.
        END.

   FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                      crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapass   THEN
        DO:
            glb_cdcritic = 9.
            CLEAR FRAME f_irpf.
            NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i}
            aux_cddopcao = glb_cddopcao.
        END.

   DISPLAY crapass.nmprimtl  WITH FRAME f_irpf.

   FIND FIRST crapdir WHERE crapdir.cdcooper  = glb_cdcooper     AND
                            crapdir.nrdconta  = crapass.nrdconta AND
                       YEAR(crapdir.dtmvtolt) = tel_dtanoref NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapdir THEN
        DO:
            glb_cdcritic = 438.
            NEXT.
        END.

   aux_cdacesso = "IRENDA" + STRING(YEAR(crapdir.dtmvtolt),"9999").

   FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                      craptab.nmsistem = "CRED"       AND
                      craptab.tptabela = "GENERI"     AND
                      craptab.cdempres = 00           AND
                      craptab.cdacesso = aux_cdacesso AND
                      craptab.tpregist = 001          NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craptab THEN
        DO:
            glb_cdcritic = 457.
            NEXT.
        END.

   ASSIGN tel_dsmoeuti = STRING(SUBSTR(craptab.dstextab,1,20))
          aux_vlconsld = DECIMAL(STRING(SUBSTR(craptab.dstextab,22,15),
                                               "999999,99999999"))
          aux_vlconjur = DECIMAL(STRING(SUBSTR(craptab.dstextab,38,15),
                                               "999999,99999999"))

          rel_vlcpmfpg = crapdir.vlcpmfpg

          rel_vlrenapl = 
              IF  crapass.inpessoa = 1 THEN
                         crapdir.vlrenrdc[01] + crapdir.vlrenrdc[02] +
                         crapdir.vlrenrdc[03] + crapdir.vlrenrdc[04] +
                         crapdir.vlrenrdc[05] + crapdir.vlrenrdc[06] +
                         crapdir.vlrenrdc[07] + crapdir.vlrenrdc[08] +
                         crapdir.vlrenrdc[09] + crapdir.vlrenrdc[10] +
                         crapdir.vlrenrdc[11] + crapdir.vlrenrdc[12] +
                         crapdir.vlrenrda[01] + crapdir.vlrenrda[02] + 
                         crapdir.vlrenrda[03] + crapdir.vlrenrda[04] +
                         crapdir.vlrenrda[05] + crapdir.vlrenrda[06] +
                         crapdir.vlrenrda[07] + crapdir.vlrenrda[08] +
                         crapdir.vlrenrda[09] + crapdir.vlrenrda[10] +
                         crapdir.vlrenrda[11] + crapdir.vlrenrda[12] +
                         crapdir.vlrenrpp + crapdir.vlabonpp + crapdir.vlabonrd
                       + crapdir.vlabiopp + crapdir.vlabiord -
                         crapdir.vlirabap[1]  - crapdir.vlirabap[2] -
                         crapdir.vlirabap[3]  - crapdir.vlirabap[4] -
                         crapdir.vlirabap[5]  - crapdir.vlirabap[6] -
                         crapdir.vlirabap[7]  - crapdir.vlirabap[8] -
                         crapdir.vlirabap[9]  - crapdir.vlirabap[10] -
                         crapdir.vlirabap[11] - crapdir.vlirabap[12] -
                         crapdir.vlirrdca[1]  - crapdir.vlirrdca[2] -
                         crapdir.vlirrdca[3]  - crapdir.vlirrdca[4] -
                         crapdir.vlirrdca[5]  - crapdir.vlirrdca[6] -
                         crapdir.vlirrdca[7]  - crapdir.vlirrdca[8] -
                         crapdir.vlirrdca[9]  - crapdir.vlirrdca[10] -
                         crapdir.vlirrdca[11] - crapdir.vlirrdca[12] -
                         crapdir.vlrirrpp[1]  - crapdir.vlrirrpp[2] -
                         crapdir.vlrirrpp[3]  - crapdir.vlrirrpp[4] -
                         crapdir.vlrirrpp[5]  - crapdir.vlrirrpp[6] -
                         crapdir.vlrirrpp[7]  - crapdir.vlrirrpp[8] -
                         crapdir.vlrirrpp[9]  - crapdir.vlrirrpp[10] -
                         crapdir.vlrirrpp[11] - crapdir.vlrirrpp[12] -
                         crapdir.vlirajus[1]  - crapdir.vlirajus[2] -
                         crapdir.vlirajus[3]  - crapdir.vlirajus[4] -
                         crapdir.vlirajus[5]  - crapdir.vlirajus[6] -
                         crapdir.vlirajus[7]  - crapdir.vlirajus[8] -
                         crapdir.vlirajus[9]  - crapdir.vlirajus[10] -
                         crapdir.vlirajus[11] - crapdir.vlirajus[12] -
                         crapdir.vlirfrdc[01] - crapdir.vlirfrdc[02] -
                         crapdir.vlirfrdc[03] - crapdir.vlirfrdc[04] -
                         crapdir.vlirfrdc[05] - crapdir.vlirfrdc[06] -
                         crapdir.vlirfrdc[07] - crapdir.vlirfrdc[08] -
                         crapdir.vlirfrdc[09] - crapdir.vlirfrdc[10] -
                         crapdir.vlirfrdc[11] - crapdir.vlirfrdc[12]
              ELSE
                   crapdir.vlrenrdc[01] + crapdir.vlrenrdc[02] +
                   crapdir.vlrenrdc[03] + crapdir.vlrenrdc[04] +
                   crapdir.vlrenrdc[05] + crapdir.vlrenrdc[06] +
                   crapdir.vlrenrdc[07] + crapdir.vlrenrdc[08] +
                   crapdir.vlrenrdc[09] + crapdir.vlrenrdc[10] +
                   crapdir.vlrenrdc[11] + crapdir.vlrenrdc[12] +
                   crapdir.vlrenrda[01] + crapdir.vlrenrda[02] + 
                   crapdir.vlrenrda[03] + crapdir.vlrenrda[04] +
                   crapdir.vlrenrda[05] + crapdir.vlrenrda[06] +
                   crapdir.vlrenrda[07] + crapdir.vlrenrda[08] +
                   crapdir.vlrenrda[09] + crapdir.vlrenrda[10] +
                   crapdir.vlrenrda[11] + crapdir.vlrenrda[12] +
                   crapdir.vlrenrpp + crapdir.vlabonpp + crapdir.vlabonrd
                   + crapdir.vlabiopp + crapdir.vlabiord 
               
          rel_vldoirrf = crapdir.vlirabap[1]  + crapdir.vlirabap[2] +
                         crapdir.vlirabap[3]  + crapdir.vlirabap[4] +
                         crapdir.vlirabap[5]  + crapdir.vlirabap[6] +
                         crapdir.vlirabap[7]  + crapdir.vlirabap[8] +
                         crapdir.vlirabap[9]  + crapdir.vlirabap[10] +
                         crapdir.vlirabap[11] + crapdir.vlirabap[12] +
                         crapdir.vlirrdca[1]  + crapdir.vlirrdca[2] +
                         crapdir.vlirrdca[3]  + crapdir.vlirrdca[4] +
                         crapdir.vlirrdca[5]  + crapdir.vlirrdca[6] +
                         crapdir.vlirrdca[7]  + crapdir.vlirrdca[8] +
                         crapdir.vlirrdca[9]  + crapdir.vlirrdca[10] +
                         crapdir.vlirrdca[11] + crapdir.vlirrdca[12] +
                         crapdir.vlrirrpp[1]  + crapdir.vlrirrpp[2] +
                         crapdir.vlrirrpp[3]  + crapdir.vlrirrpp[4] +
                         crapdir.vlrirrpp[5]  + crapdir.vlrirrpp[6] +
                         crapdir.vlrirrpp[7]  + crapdir.vlrirrpp[8] +
                         crapdir.vlrirrpp[9]  + crapdir.vlrirrpp[10] +
                         crapdir.vlrirrpp[11] + crapdir.vlrirrpp[12] +
                         crapdir.vlirajus[1]  + crapdir.vlirajus[2] +
                         crapdir.vlirajus[3]  + crapdir.vlirajus[4] +
                         crapdir.vlirajus[5]  + crapdir.vlirajus[6] +
                         crapdir.vlirajus[7]  + crapdir.vlirajus[8] +
                         crapdir.vlirajus[9]  + crapdir.vlirajus[10] +
                         crapdir.vlirajus[11] + crapdir.vlirajus[12] +
                         crapdir.vlirfrdc[01] + crapdir.vlirfrdc[02] +
                         crapdir.vlirfrdc[03] + crapdir.vlirfrdc[04] +
                         crapdir.vlirfrdc[05] + crapdir.vlirfrdc[06] +
                         crapdir.vlirfrdc[07] + crapdir.vlirfrdc[08] +
                         crapdir.vlirfrdc[09] + crapdir.vlirfrdc[10] +
                         crapdir.vlirfrdc[11] + crapdir.vlirfrdc[12]
          
          rel_vldjuros = ROUND((crapdir.qtjaicmf * aux_vlconjur),2).

   DISPLAY tel_dsmoeuti WITH FRAME f_irpf.

   DISPLAY crapdir.vlsddvem       
           crapdir.vlsdccdp       
           crapdir.vlttccap       
           rel_vldjuros
          (crapdir.vlsdapli + crapdir.vlsdrdpp) @ crapdir.vlsdapli
           rel_vlrenapl
           rel_vldoirrf           rel_vlcpmfpg
           WITH FRAME f_histori.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

