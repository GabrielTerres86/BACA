/* .............................................................................

   Programa: Fontes/tabseg.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Dezembro/96.                        Ultima atualizacao: 25/05/2009

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TABSEG.

   Alteracoes: 20/06/97 - Alterado para tratar planos de seguros AUTO (Edson).

               22/08/97 - Alterado para tratar varias seguradoras (Edson).

               05/07/2005 - Alimentado campo cdcooper da tabela crapsga (Diego).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               12/09/2006 - Excluida opcao "TAB" (Diego).
               
               03/03/2009 - Permitir somente operador 799 ou 1 nas
                            opcoes A,I,E.   (Fernando).
                            
               25/05/2009 - Alteracao CDOPERAD (Kbase).
............................................................................. */

{ includes/var_online.i }

DEF       VAR tel_dslinha1 AS CHAR    FORMAT "x(74)" EXTENT 4      NO-UNDO.
DEF       VAR tel_dslinha2 AS CHAR    FORMAT "x(71)" EXTENT 4      NO-UNDO.

DEF       VAR aux_confirma AS CHAR    FORMAT "!(1)"                NO-UNDO.
DEF       VAR aux_cddopcao AS CHAR                                 NO-UNDO.
DEF       VAR aux_lsnomseg AS CHAR                                 NO-UNDO.
DEF       VAR aux_lscodseg AS CHAR                                 NO-UNDO.

DEF       VAR aux_flgerros AS LOGICAL                              NO-UNDO.
DEF       VAR aux_flgretor AS LOGICAL                              NO-UNDO.
DEF       VAR aux_regexist AS LOGICAL                              NO-UNDO.

DEF       VAR aux_contador AS INT                                  NO-UNDO.
DEF       VAR aux_cdsegura AS INT                                  NO-UNDO.
DEF       VAR aux_nrindseg AS INT                                  NO-UNDO.

DEF       VAR tel_cdsitpsg AS LOGICAL FORMAT "Ativo/Inativo"       NO-UNDO.
DEF       VAR tel_inplaseg AS LOGICAL FORMAT "Sim/Nao"             NO-UNDO.
DEF       VAR tel_flgtpseg AS LOGICAL FORMAT "AUTO/CASA"           NO-UNDO.
DEF       VAR tel_flgconsi AS LOGICAL FORMAT "MAIOR/IGUAL"         NO-UNDO.
DEF       VAR tel_flgassis AS LOGICAL FORMAT "Sim/Nao"             NO-UNDO.
DEF       VAR tel_flgcurso AS LOGICAL FORMAT "Sim/Nao"             NO-UNDO.
DEF       VAR tel_flgreduz AS LOGICAL FORMAT "Sim/Nao"             NO-UNDO.
DEF       VAR tel_flgunica AS LOGICAL FORMAT "Unico/Mensal"        NO-UNDO.
DEF       VAR tel_flgespec AS LOGICAL FORMAT "Sim/Nao"             NO-UNDO.

DEF       VAR tel_dsgarant AS CHAR    FORMAT "x(20)"               NO-UNDO.
DEF       VAR tel_dsmorada AS CHAR    FORMAT "x(50)"               NO-UNDO.
DEF       VAR tel_dsocupac AS CHAR    FORMAT "x(25)"               NO-UNDO.
DEF       VAR tel_nmresseg AS CHAR                                 NO-UNDO.
DEF       VAR tel_dssitpla AS CHAR                                 NO-UNDO.

DEF       VAR tel_nrtabela AS INT     FORMAT "z9"                  NO-UNDO.
DEF       VAR tel_tpplaseg AS INT     FORMAT "zz9"                 NO-UNDO.
DEF       VAR tel_tpseguro AS INT     FORMAT "z9"                  NO-UNDO.

DEF       VAR tel_vlplaseg AS DECIMAL FORMAT "zzz,zz9.99"          NO-UNDO.
DEF       VAR tel_vlmorada AS DECIMAL FORMAT "zzzz,zz9.99"         NO-UNDO.

DEF       VAR tel_vlverbae AS DECIMAL                              NO-UNDO.
DEF       VAR tel_vldanmat AS DECIMAL                              NO-UNDO.
DEF       VAR tel_vldanpes AS DECIMAL                              NO-UNDO.
DEF       VAR tel_vldanmor AS DECIMAL                              NO-UNDO.
DEF       VAR tel_vlappmor AS DECIMAL                              NO-UNDO.
DEF       VAR tel_vlappinv AS DECIMAL                              NO-UNDO.
DEF       VAR tel_vltarifa AS DECIMAL                              NO-UNDO.

FORM SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                      TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  3 FORMAT "!" LABEL "Opcao" AUTO-RETURN
                        HELP "Entre com a opcao desejada (A, B, C, E, I ou L)"
                        VALIDATE(CAN-DO("A,B,C,E,I,L",glb_cddopcao),
                                 "014 - Opcao errada.")

     tel_flgtpseg AT 28 FORMAT "AUTO/CASA" LABEL "Tipo de seguro"
                        HELP "Entre com (A)uto ou (C)asa para o tipo de seguro."

     tel_tpplaseg AT 61 FORMAT "zz9" LABEL "Plano"
                        HELP "Entre com o tipo do plano de seguro."
                        VALIDATE(tel_tpplaseg > 0,"193 - Tipo de plano errado")
     SKIP(1)
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

FORM tel_nmresseg AT  3 FORMAT "x(30)" LABEL "Seguradora"
                        HELP "Entre com o nome da seguradora."

     tel_flgconsi AT 54 FORMAT "MAIOR/IGUAL" LABEL "Consistencia"
              HELP "Entre com (M)aior ou (I)gual para consistencia dos valores."
     SKIP(1)
     tel_vlverbae AT 03 FORMAT "zzzzz,zz9.99"
                        LABEL "Diaria de Indisponibilidade"
     SKIP
     tel_vldanmat AT 15 FORMAT "zzzzz,zz9.99" LABEL "Danos Materiais"
                        HELP "Entre com o valor para Danos Materiais."
     SKIP
     tel_vldanpes AT 16 FORMAT "zzzzz,zz9.99" LABEL "Danos Pessoais"
                        HELP "Entre com o valor para Danos Pessoais."
     SKIP
     tel_vldanmor AT 06 FORMAT "zzzzz,zz9.99" LABEL "Danos Morais a Terceiros"
                        HELP "Entre com o valor para Danos Morais a Terceiros."
     SKIP
     tel_vlappmor AT 21 FORMAT "zzzzz,zz9.99" LABEL "APP Morte"
                        HELP "Entre com o valor para APP Morte."
     SKIP
     tel_vlappinv AT 17 FORMAT "zzzzz,zz9.99" LABEL "APP Invalidez"
                        HELP "Entre com o valor para APP Invalidez."
     SKIP
     tel_vltarifa AT 24 FORMAT "zzzzz,zz9.99" LABEL "TARIFA"
                        HELP "Entre com o valor da TARIFA."
     SKIP
     tel_flgassis AT 19 FORMAT "Sim/Nao" LABEL "Assistencia"
                        HELP "Entre com (S)im ou (N)ao para o indicador."
     tel_flgreduz AT 48 FORMAT "Sim/Nao" LABEL "Tarifa Reduzida"
                        HELP "Entre com (S)im ou (N)ao para o indicador."
     SKIP
     tel_flgcurso AT 08 FORMAT "Sim/Nao" LABEL "Curso Viva no Transito"
                      HELP "Entre com (S)im ou (N)ao para o indicador de Curso."
     tel_flgunica AT 49 FORMAT "Unico/Mensal" LABEL "Forma de Pagto"
         HELP "Entre com (U)nico ou (M)ensal para a forma de pagamento."
     SKIP
     tel_flgespec AT 16   FORMAT "Sim/Nao" LABEL "Plano ESPECIAL"
              HELP "Entre com (S)im ou (N)ao para o indicador de plano Especial"
     SKIP
     tel_dssitpla AT 13 FORMAT "x(20)"     LABEL "Situacao do Plano"
     WITH ROW 8 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_seg_auto.



/*

    /* tel_tpseguro AT 42 LABEL "Tipo de Seguro"
                        VALIDATE (tel_tpseguro = 1, "513 - Tipo errado") */
     SKIP(1)
     "Plano     Premio Tipo de Moradia"           AT  2
     "Tabela"                                     AT 70 SKIP
     "Cobertura Garantias            Ocupacao"    AT 09
     "Sit.     Esp."                              AT 66
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

*/


FORM tel_tpplaseg AT  4 NO-LABEL AUTO-RETURN
             HELP "Entre com o tipo de plano de seguro. ( 1 a 36 ou 90)"
                        VALIDATE (tel_tpplaseg < 37 OR tel_tpplaseg = 90,
                                  "193 - Tipo de plano errado")

     tel_vlplaseg AT  8 NO-LABEL AUTO-RETURN
                        HELP "Entre com o valor do premio"
                        VALIDATE (tel_vlplaseg > 0, "269 - Valor errado.")

     tel_dsmorada AT 19 NO-LABEL AUTO-RETURN
                        HELP "Entre com a descricao da moradia."

     tel_nrtabela AT 72 NO-LABEL AUTO-RETURN
                        HELP "Entre com o numero da tabela. ( 1 a 9 )"
                        VALIDATE(tel_nrtabela > 0 AND tel_nrtabela < 10,
                                 "053 - Tipo de tabela errado.")

     tel_vlmorada AT 7  NO-LABEL AUTO-RETURN
                        HELP "Entre com o valor da cobertura"
                        VALIDATE(tel_vlmorada > 0 , "269 - Valor errado")

     tel_dsgarant AT 19 NO-LABEL AUTO-RETURN
                        HELP "Entre com as garantias."

     tel_dsocupac AT 40 NO-LABEL AUTO-RETURN
                        HELP "Entre com o tipo de ocupacao."

     tel_cdsitpsg AT 66 NO-LABEL
                        HELP "Entre com a situacao do plano (Ativo, Inativo)"

     tel_inplaseg AT 75 NO-LABEL
                        HELP "Informe se e plano especial (Sim, Nao)"
     WITH ROW 11 COLUMN 2 OVERLAY NO-LABELS NO-BOX FRAME f_tabseg.

FORM tel_dslinha1[1] AT 4 NO-LABEL  tel_dslinha2[1] AT 7 NO-LABEL
     tel_dslinha1[2] AT 4 NO-LABEL  tel_dslinha2[2] AT 7 NO-LABEL
     tel_dslinha1[3] AT 4 NO-LABEL  tel_dslinha2[3] AT 7 NO-LABEL
     tel_dslinha1[4] AT 4 NO-LABEL  tel_dslinha2[4] AT 7 NO-LABEL
     WITH ROW 13 COLUMN 2 OVERLAY NO-BOX FRAME f_regant.

VIEW FRAME f_moldura.

ASSIGN glb_cddopcao = "C"
       tel_tpseguro = 1
       glb_cdcritic = 0.

/*  Leitura do cadastro de seguradoras  */

FOR EACH crapcsg WHERE crapcsg.cdcooper = glb_cdcooper NO-LOCK.

    IF   TRIM(aux_lsnomseg) <> ""   THEN
         ASSIGN aux_lsnomseg = aux_lsnomseg + "," + TRIM(crapcsg.nmresseg)
                aux_lscodseg = aux_lscodseg + "," + STRING(crapcsg.cdsegura).
    ELSE
         ASSIGN aux_lsnomseg = TRIM(crapcsg.nmresseg)
                aux_lscodseg = STRING(crapcsg.cdsegura).

END.  /*  Fim do FOR EACH  --  Leitura do cadastro de seguradoras  */

PAUSE(0).

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      UPDATE glb_cddopcao tel_flgtpseg tel_tpplaseg WITH FRAME f_opcao.

      IF   CAN-DO ("A,I,E",glb_cddopcao)      THEN
           IF   glb_dsdepart <> "TI"       AND
                glb_dsdepart <> "PRODUTOS" THEN
                DO:
                   glb_cdcritic = 36.
                   NEXT.
                END.

      IF   TRIM(aux_lsnomseg) = ""   THEN
           DO:
               glb_cdcritic = 556.
               NEXT-PROMPT tel_flgtpseg WITH FRAME f_opcao.
               CLEAR FRAME f_opcao NO-PAUSE.
               NEXT.
           END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "TABSEG"   THEN
                 DO:
                     HIDE FRAME f_opcao.
                     HIDE FRAME f_tabseg.
                     HIDE FRAME f_regant.
                     HIDE FRAME f_seg_auto.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "A" THEN
        DO:
            IF   NOT tel_flgtpseg   THEN                     /*  Seguro CASA  */
                 DO WHILE TRUE TRANSACTION:

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                       LEAVE.

                    END.  /*  Fim do DO WHILE TRUE  */

                    LEAVE.

                 END.  /*  Fim do DO WHILE TRUE  */
            ELSE                                             /*  Seguro AUTO  */
                 DO WHILE TRUE TRANSACTION:

                     FIND crapsga WHERE crapsga.cdcooper = glb_cdcooper AND
                                        crapsga.tpplaseg = tel_tpplaseg
                                        EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                     IF   NOT AVAILABLE crapsga   THEN
                          IF   LOCKED crapsga   THEN
                               DO:
                                   PAUSE 2 NO-MESSAGE.
                                   NEXT.
                               END.
                          ELSE
                               DO:
                                   glb_cdcritic = 200.
                                   NEXT-PROMPT tel_tpplaseg WITH FRAME f_opcao.
                                   CLEAR FRAME f_seg_auto NO-PAUSE.
                                   LEAVE.
                               END.

                   /*FIND crapcsg OF crapsga NO-LOCK NO-ERROR. */
                   
                     FIND crapcsg WHERE crapcsg.cdcooper = glb_cdcooper AND
                                        crapcsg.cdsegura = crapsga.cdsegura
                                        NO-LOCK NO-ERROR.
                     
                     IF   NOT AVAILABLE crapcsg   THEN
                          DO:
                              glb_cdcritic = 556.
                              NEXT-PROMPT tel_tpplaseg WITH FRAME f_opcao.
                              CLEAR FRAME f_seg_auto NO-PAUSE.
                              LEAVE.
                          END.

                     IF   crapsga.cdsitpsg <> 1   THEN
                          DO:
                              glb_cdcritic = 206.
                              NEXT-PROMPT tel_tpplaseg WITH FRAME f_opcao.
                              CLEAR FRAME f_seg_auto NO-PAUSE.
                              LEAVE.
                          END.

                     ASSIGN tel_nmresseg = crapcsg.nmresseg
                            tel_flgconsi = crapsga.flgconsi
                            tel_vlverbae = crapsga.vlverbae
                            tel_flgassis = crapsga.flgassis
                            tel_vldanmat = crapsga.vldanmat
                            tel_vldanpes = crapsga.vldanpes
                            tel_vldanmor = crapsga.vldanmor
                            tel_vlappmor = crapsga.vlappmor
                            tel_vlappinv = crapsga.vlappinv
                            tel_flgcurso = crapsga.flgcurso
                            tel_flgreduz = crapsga.flgreduz
                            tel_flgunica = crapsga.flgunica
                            tel_vltarifa = crapsga.vltarifa

                            tel_dssitpla = IF crapsga.cdsitpsg = 1
                                              THEN "Liberado"
                                              ELSE "Bloqueado"

                            tel_flgespec = IF crapsga.inplaseg = 1
                                              THEN FALSE
                                              ELSE TRUE.


                     DISPLAY tel_nmresseg tel_dssitpla WITH FRAME f_seg_auto.

                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                        UPDATE tel_flgconsi tel_vlverbae
                               tel_vldanmat tel_vldanpes tel_vldanmor
                               tel_vlappmor tel_vlappinv tel_vltarifa
                               tel_flgassis tel_flgcurso tel_flgespec
                               tel_flgreduz tel_flgunica
                               WITH FRAME f_seg_auto

                        EDITING:

                           READKEY.
                           IF   FRAME-FIELD = "tel_vltarifa"   THEN
                                IF   LASTKEY =  KEYCODE(".")   THEN
                                     APPLY 44.
                                ELSE
                                     APPLY LASTKEY.
                           ELSE
                                APPLY LASTKEY.

                        END.  /*  Fim do EDITING  */
                              /*
                        IF   tel_flgunica   THEN
                             DO:
                                 IF   crapcsg.cdhstaut[4] = 0   THEN
                                      DO:
                                          glb_cdcritic = 581.
                                          NEXT-PROMPT tel_flgunica
                                                      WITH FRAME f_seg_auto.
                                          NEXT.
                                      END.
                             END.
                        ELSE   
                             IF   crapcsg.cdhstaut[1] = 0   OR
                                  crapcsg.cdhstaut[2] = 0   OR
                                  crapcsg.cdhstaut[3] = 0   THEN
                                  DO:
                                      glb_cdcritic = 581.
                                      NEXT-PROMPT tel_flgunica
                                                  WITH FRAME f_seg_auto.
                                      NEXT.
                                  END.
                              */
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                           aux_confirma = "N".

                           glb_cdcritic = 78.
                           RUN fontes/critic.p.
                           BELL.
                          MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                           glb_cdcritic = 0.
                           LEAVE.

                        END.  /*  Fim do DO WHILE TRUE  */

                        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                             aux_confirma <> "S" THEN
                             DO:
                                 glb_cdcritic = 79.
                                 RUN fontes/critic.p.
                                 BELL.
                                 MESSAGE glb_dscritic.
                                 glb_cdcritic = 0.
                                 NEXT.
                             END.

                        LEAVE.

                     END.  /*  Fim do DO WHILE TRUE  */

                     IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                          LEAVE.


                     ASSIGN crapsga.flgconsi = tel_flgconsi
                            crapsga.vlverbae = tel_vlverbae
                            crapsga.flgassis = tel_flgassis
                            crapsga.vldanmat = tel_vldanmat
                            crapsga.vldanpes = tel_vldanpes
                            crapsga.vldanmor = tel_vldanmor
                            crapsga.vlappmor = tel_vlappmor
                            crapsga.vlappinv = tel_vlappinv
                            crapsga.flgcurso = tel_flgcurso
                            crapsga.flgreduz = tel_flgreduz
                            crapsga.flgunica = tel_flgunica
                            crapsga.vltarifa = tel_vltarifa

                            crapsga.inplaseg = IF tel_flgespec
                                                  THEN 2
                                                  ELSE 1.

                     CLEAR FRAME f_seg_auto NO-PAUSE.
                     CLEAR FRAME f_opcao    NO-PAUSE.

                     tel_tpplaseg = 0.

                     LEAVE.

                 END.  /*  Fim do DO WHILE TRUE  */
        END.
   ELSE
   IF   glb_cddopcao = "B"   OR
        glb_cddopcao = "L"   THEN
        DO:
            glb_cdcritic = 999.
            NEXT.
        END.
   ELSE
   IF   glb_cddopcao = "C" THEN
        DO:
            IF   NOT tel_flgtpseg   THEN                     /*  Seguro CASA  */
                 DO:
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                        LEAVE.

                     END.  /*  Fim do DO WHILE TRUE  */
                 END.
            ELSE                                             /*  Seguro AUTO  */
                 DO:
                     FIND crapsga WHERE crapsga.cdcooper = glb_cdcooper AND
                                        crapsga.tpplaseg = tel_tpplaseg
                                        NO-LOCK NO-ERROR.

                     IF   NOT AVAILABLE crapsga   THEN
                          DO:
                              glb_cdcritic = 200.
                              NEXT-PROMPT tel_tpplaseg WITH FRAME f_opcao.
                              CLEAR FRAME f_seg_auto NO-PAUSE.
                              NEXT.
                          END.

                  /* FIND crapcsg OF crapsga NO-LOCK NO-ERROR.*/
                  
                     FIND crapcsg WHERE crapcsg.cdcooper = glb_cdcooper AND
                                        crapcsg.cdsegura = crapsga.cdsegura
                                        NO-LOCK NO-ERROR.                        
                     IF   NOT AVAILABLE crapcsg   THEN
                          DO:
                              glb_cdcritic = 556.
                              NEXT-PROMPT tel_flgtpseg WITH FRAME f_opcao.
                              CLEAR FRAME f_seg_auto NO-PAUSE.
                              NEXT.
                          END.

                     ASSIGN tel_nmresseg = crapcsg.nmresseg
                            tel_flgconsi = crapsga.flgconsi
                            tel_vlverbae = crapsga.vlverbae
                            tel_flgassis = crapsga.flgassis
                            tel_vldanmat = crapsga.vldanmat
                            tel_vldanpes = crapsga.vldanpes
                            tel_vldanmor = crapsga.vldanmor
                            tel_vlappmor = crapsga.vlappmor
                            tel_vlappinv = crapsga.vlappinv
                            tel_flgcurso = crapsga.flgcurso
                            tel_flgreduz = crapsga.flgreduz
                            tel_flgunica = crapsga.flgunica
                            tel_vltarifa = crapsga.vltarifa

                            tel_dssitpla = IF crapsga.cdsitpsg = 1
                                              THEN "Liberado"
                                              ELSE "Bloqueado"

                            tel_flgespec = IF crapsga.inplaseg = 1
                                              THEN FALSE
                                              ELSE TRUE.

                     DISPLAY tel_nmresseg tel_flgconsi tel_vlverbae
                             tel_flgassis tel_vldanmat tel_vldanpes
                             tel_vldanmor tel_vlappmor tel_vlappinv
                             tel_flgcurso tel_vltarifa tel_dssitpla
                             tel_flgespec tel_flgreduz tel_flgunica
                             WITH FRAME f_seg_auto.
                 END.

            NEXT-PROMPT tel_tpplaseg WITH FRAME f_opcao.
        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN
        DO:
            IF   NOT tel_flgtpseg   THEN                      /* Seguro CASA  */
                 DO:
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                        LEAVE.

                     END.  /*  Fim do DO WHILE TRUE  */
                 END.
            ELSE                                             /*  Seguro AUTO  */
                 DO WHILE TRUE TRANSACTION:

                     FIND crapsga WHERE crapsga.cdcooper = glb_cdcooper AND
                                        crapsga.tpplaseg = tel_tpplaseg
                                        EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                     IF   NOT AVAILABLE crapsga   THEN
                          IF   LOCKED crapsga   THEN
                               DO:
                                   PAUSE 2 NO-MESSAGE.
                                   NEXT.
                               END.
                          ELSE
                               DO:
                                   glb_cdcritic = 200.
                                   NEXT-PROMPT tel_tpplaseg WITH FRAME f_opcao.
                                   CLEAR FRAME f_seg_auto NO-PAUSE.
                                   LEAVE.
                               END.

                   /*FIND crapcsg OF crapsga NO-LOCK NO-ERROR. */

                     FIND crapcsg WHERE crapcsg.cdcooper = glb_cdcooper AND
                                        crapcsg.cdsegura = crapsga.cdsegura
                                        NO-LOCK NO-ERROR.

                     IF   NOT AVAILABLE crapcsg   THEN
                          DO:
                              glb_cdcritic = 556.
                              NEXT-PROMPT tel_flgtpseg WITH FRAME f_opcao.
                              CLEAR FRAME f_seg_auto NO-PAUSE.
                              LEAVE.
                          END.

                     ASSIGN tel_nmresseg = crapcsg.nmresseg

                            tel_flgconsi = crapsga.flgconsi
                            tel_vlverbae = crapsga.vlverbae
                            tel_flgassis = crapsga.flgassis
                            tel_vldanmat = crapsga.vldanmat
                            tel_vldanpes = crapsga.vldanpes
                            tel_vldanmor = crapsga.vldanmor
                            tel_vlappmor = crapsga.vlappmor
                            tel_vlappinv = crapsga.vlappinv
                            tel_flgcurso = crapsga.flgcurso
                            tel_flgreduz = crapsga.flgreduz
                            tel_flgunica = crapsga.flgunica
                            tel_vltarifa = crapsga.vltarifa

                            tel_dssitpla = IF crapsga.cdsitpsg = 1
                                              THEN "Liberado"
                                              ELSE "Bloqueado"

                            tel_flgespec = IF crapsga.inplaseg = 1
                                              THEN FALSE
                                              ELSE TRUE.

                     DISPLAY tel_nmresseg tel_flgconsi tel_vlverbae
                             tel_flgassis tel_vldanmat tel_vldanpes
                             tel_vldanmor tel_vlappmor tel_vlappinv
                             tel_flgcurso tel_vltarifa tel_dssitpla
                             tel_flgespec tel_flgreduz tel_flgunica
                             WITH FRAME f_seg_auto.

                     /*  PROCURAR POR SEGUROS COM ESTE TIPO DE PLANO  */

                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                        aux_confirma = "N".

                        glb_cdcritic = 78.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                        glb_cdcritic = 0.
                        LEAVE.

                     END.  /*  Fim do DO WHILE TRUE  */

                     IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                          aux_confirma <> "S" THEN
                          DO:
                              glb_cdcritic = 79.
                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE glb_dscritic.
                              glb_cdcritic = 0.
                              LEAVE.
                          END.

                     DELETE crapsga.

                     CLEAR FRAME f_seg_auto NO-PAUSE.
                     CLEAR FRAME f_opcao    NO-PAUSE.

                     tel_tpplaseg = 0.

                     LEAVE.

                 END.  /*  Fim do DO WHILE TRUE  */
        END.
   ELSE
   IF   glb_cddopcao = "I"   THEN
        DO:
            ASSIGN aux_nrindseg = 1
                   tel_nmresseg = ENTRY(aux_nrindseg,aux_lsnomseg)
                   aux_cdsegura = INT(ENTRY(aux_nrindseg,aux_lscodseg)).

            IF   NOT tel_flgtpseg   THEN                      /* Seguro CASA  */
                 DO WHILE TRUE:

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                       LEAVE.

                    END.  /*  Fim do DO WHILE TRUE  */

                    LEAVE.

                 END.  /*  Fim do DO WHILE TRUE  */
            ELSE                                             /*  Seguro AUTO  */
                 DO WHILE TRUE:

                    IF   CAN-FIND(crapsga WHERE
                                  crapsga.cdcooper = glb_cdcooper    AND
                                  crapsga.tpplaseg = tel_tpplaseg)   THEN
                         DO:
                             glb_cdcritic = 198.
                             NEXT-PROMPT tel_tpplaseg WITH FRAME f_opcao.
                             NEXT.
                         END.

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                       IF   glb_cdcritic > 0   THEN
                            DO:
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE glb_dscritic.
                                glb_cdcritic = 0.
                            END.

                       tel_dssitpla = "NOVO PLANO".

                       DISPLAY tel_dssitpla WITH FRAME f_seg_auto.

                       UPDATE tel_nmresseg tel_flgconsi tel_vlverbae
                              tel_vldanmat tel_vldanpes tel_vldanmor
                              tel_vlappmor tel_vlappinv tel_vltarifa
                              tel_flgassis tel_flgcurso tel_flgespec
                              tel_flgreduz tel_flgunica
                              WITH FRAME f_seg_auto

                       EDITING:

                          READKEY.

                          IF   FRAME-FIELD = "tel_nmresseg"   THEN
                               DO:
                                   IF KEYFUNCTION(LASTKEY) = "CURSOR-UP"    OR
                                      KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT" THEN
                                      DO:
                                          aux_nrindseg = aux_nrindseg - 1.

                                          IF   aux_nrindseg <= 0   THEN
                                               aux_nrindseg =
                                                   NUM-ENTRIES(aux_lsnomseg).

                                          tel_nmresseg = ENTRY(aux_nrindseg,
                                                               aux_lsnomseg).
                                          aux_cdsegura = INT(ENTRY(aux_nrindseg,
                                                             aux_lscodseg)).

                                          DISPLAY tel_nmresseg
                                                  WITH FRAME f_seg_auto.
                                      END.
                                   ELSE
                                   IF KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"   OR
                                      KEYFUNCTION(LASTKEY) = "CURSOR-LEFT" THEN
                                      DO:
                                          aux_nrindseg = aux_nrindseg + 1.

                                          IF   aux_nrindseg >
                                               NUM-ENTRIES(aux_lsnomseg)   THEN
                                               aux_nrindseg = 1.

                                          tel_nmresseg = ENTRY(aux_nrindseg,
                                                               aux_lsnomseg).
                                          aux_cdsegura = INT(ENTRY(aux_nrindseg,
                                                             aux_lscodseg)).

                                          DISPLAY tel_nmresseg
                                                  WITH FRAME f_seg_auto.
                                      END.
                                   ELSE
                                   IF   KEYFUNCTION(LASTKEY) = "RETURN"   OR
                                        KEYFUNCTION(LASTKEY) = "BACK-TAB" OR
                                        KEYFUNCTION(LASTKEY) = "GO"       THEN
                                        APPLY LASTKEY.
                               END.
                          ELSE
                          IF   FRAME-FIELD = "tel_vltarifa"   THEN
                               IF   LASTKEY =  KEYCODE(".")   THEN
                                    APPLY 44.
                               ELSE
                                    APPLY LASTKEY.
                          ELSE
                               APPLY LASTKEY.

                       END.  /*  Fim do EDITING  */

                       FIND crapcsg WHERE crapcsg.cdcooper = glb_cdcooper AND
                                          crapcsg.cdsegura = aux_cdsegura
                                          NO-LOCK NO-ERROR.

                       IF   NOT AVAILABLE crapcsg   THEN
                            DO:
                                glb_cdcritic = 556.
                                NEXT-PROMPT tel_nmresseg WITH FRAME f_seg_auto.
                                NEXT.
                            END.
                                                        /*
                       IF   tel_flgunica   THEN
                            DO:
                                IF   crapcsg.cdhstaut[4] = 0   THEN
                                     DO:
                                         glb_cdcritic = 581.
                                         NEXT-PROMPT tel_flgunica
                                                     WITH FRAME f_seg_auto.
                                         NEXT.
                                     END.
                            END.
                       ELSE
                            IF   crapcsg.cdhstaut[1] = 0   OR
                                 crapcsg.cdhstaut[2] = 0   OR
                                 crapcsg.cdhstaut[3] = 0   THEN
                                 DO:
                                     glb_cdcritic = 581.
                                     NEXT-PROMPT tel_flgunica
                                                 WITH FRAME f_seg_auto.
                                     NEXT.
                                 END.
                                                          */
                       LEAVE.

                    END.  /*  Fim do DO WHILE TRUE  */

                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                         LEAVE.

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                       aux_confirma = "N".

                       glb_cdcritic = 78.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                       glb_cdcritic = 0.
                       LEAVE.

                    END.  /*  Fim do DO WHILE TRUE  */

                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                         aux_confirma <> "S" THEN
                         DO:
                             glb_cdcritic = 79.
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             glb_cdcritic = 0.
                             NEXT.
                         END.

                    DO TRANSACTION ON ERROR UNDO, NEXT.

                       CREATE crapsga.
                       ASSIGN crapsga.cdsegura = INT(ENTRY(aux_nrindseg,
                                                               aux_lscodseg))
                              crapsga.tpplaseg = tel_tpplaseg

                              crapsga.flgconsi = tel_flgconsi
                              crapsga.vlverbae = tel_vlverbae
                              crapsga.flgassis = tel_flgassis
                              crapsga.vldanmat = tel_vldanmat
                              crapsga.vldanpes = tel_vldanpes
                              crapsga.vldanmor = tel_vldanmor
                              crapsga.vlappmor = tel_vlappmor
                              crapsga.vlappinv = tel_vlappinv
                              crapsga.flgcurso = tel_flgcurso
                              crapsga.flgreduz = tel_flgreduz
                              crapsga.flgunica = tel_flgunica
                              crapsga.vltarifa = tel_vltarifa
                              crapsga.cdsitpsg = 1
                              crapsga.inplaseg = IF tel_flgespec
                                                    THEN 2
                                                    ELSE 1
                              crapsga.cdcooper = glb_cdcooper. 

                    END.  /*  Fim da transacao  */

                    RELEASE crapsga.

                    ASSIGN tel_flgconsi = FALSE
                           tel_flgassis = FALSE
                           tel_flgcurso = FALSE
                           tel_flgreduz = FALSE
                           tel_flgunica = FALSE
                           tel_flgespec = FALSE

                           tel_tpplaseg = 0
                           tel_vlverbae = 0
                           tel_vldanmat = 0
                           tel_vldanpes = 0
                           tel_vldanmor = 0
                           tel_vlappmor = 0
                           tel_vlappinv = 0
                           tel_vltarifa = 0.

                    CLEAR FRAME f_seg_auto NO-PAUSE.
                    CLEAR FRAME f_opcao    NO-PAUSE.

                    LEAVE.

                 END.  /*  Fim do DO WHILE TRUE  */
        END.

   END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

