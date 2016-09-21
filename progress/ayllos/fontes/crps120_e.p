/* ..........................................................................

   Programa: fontes/crps120_e.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Maio/95.                            Ultima atualizacao: 29/10/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Gerar relatorio de estouros (99 e 114)

   Alteracoes: 07/08/96 - Alterado para tratar varios convenios de dentistas
                          (Edson).

               19/05/97 - Alterado para tratar outros convenios (Edson).

               11/08/97 - Nao listar estouros de cotas e emprestimos (Odair)

               22/10/97 - Alterar a ordem de classificacao do relatorio de
                          convenios (Odair)

               20/03/2000 - Nao gerar pedido de impressao do relatorio 114
                            (Deborah).
                            
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               21/02/2008 - Mostrar turno da crapttl.cdturnos (Gabriel)

               08/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)
                                                                 
               01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

               21/01/2013 - Removido o indice crapass4 (Daniele).
               
               29/10/2013 - Verificacao se existem registros (aux_flarqden) para
                            saber se copia o relatorio crrl114 para o dir rlnsv 
                            no crps120.p (Carlos)

............................................................................. */
DEF INPUT  PARAM par_cdempres AS INT                                        .

DEF VAR aux_flgexist AS LOGICAL                                      NO-UNDO.

{ includes/var_batch.i } 

{ includes/var_crps120.i } 

DEF VAR ger_vlavscnv AS DECIMAL EXTENT 999                           NO-UNDO.
DEF VAR ger_vldebcnv AS DECIMAL EXTENT 999                           NO-UNDO.
DEF VAR ger_vlestcnv AS DECIMAL EXTENT 999                           NO-UNDO.

DEF VAR ger_qtavscnv AS INT     EXTENT 999                           NO-UNDO.
DEF VAR ger_qtdebcnv AS INT     EXTENT 999                           NO-UNDO.
DEF VAR ger_qtestcnv AS INT     EXTENT 999                           NO-UNDO.

DEF VAR con_flgfirst AS LOGICAL                                      NO-UNDO.

FORM rel_dsempres FORMAT "x(30)" LABEL "EMPRESA"
     SKIP(1)
     WITH NO-BOX SIDE-LABELS FRAME f_empresa.

FORM rel_dsconven     AT  1 FORMAT "x(50)" LABEL "CONVENIO"
     "QUANTIDADE"     AT 64
     "VALOR"          AT 86
     SKIP(1)
     "AVISADOS     :" AT 48
     ger_qtavscnv[aux_contador] AT 67 FORMAT "zzz,zz9" NO-LABEL
     ger_vlavscnv[aux_contador] AT 77 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP
     "DEBITADOS    :" AT 48
     ger_qtdebcnv[aux_contador] AT 67 FORMAT "zzz,zz9" NO-LABEL
     ger_vldebcnv[aux_contador] AT 77 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP
     "ESTOUROS     :" AT 48
     ger_qtestcnv[aux_contador] AT 67 FORMAT "zzz,zz9" NO-LABEL
     ger_vlestcnv[aux_contador] AT 77 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP(2)
     WITH NO-BOX SIDE-LABELS DOWN WIDTH 132 FRAME f_convenio.

ASSIGN rel_cdagenci = 0   tot_qtestcot = 0   tot_vlestcot = 0
       tot_qtestemp = 0   tot_vlestemp = 0   ger_vlavsemp = 0
       ger_vldebemp = 0   ger_vlavscot = 0   ger_vldebcot = 0
       ger_qtestcot = 0   ger_vlestcot = 0   ger_qtestemp = 0
       ger_vlestemp = 0   ger_vlantcot = 0   ger_vlantemp = 0
       ass_vlestdif = 0   ass_vlestemp = 0   rel_dsconven = ""

       ger_vlavscnv = 0   ger_vldebcnv = 0   ger_vlestcnv = 0
       ger_qtavscnv = 0   ger_qtdebcnv = 0   ger_qtestcnv = 0.

{ includes/cabrel132_3.i }

OUTPUT STREAM str_3 TO VALUE(aux_nmarqest[aux_contaarq]) PAGED PAGE-SIZE 84.

VIEW STREAM str_3 FRAME f_cabrel132_3.

FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                       crapass.dtelimin = ?             NO-LOCK
                       BREAK BY crapass.cdagenci
                               BY crapass.nrdconta: 

    ASSIGN aux_cdempres = 0.
    
    IF   crapass.inpessoa = 1   THEN
         DO:
             FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper       AND
                                crapttl.nrdconta = crapass.nrdconta   AND
                                crapttl.idseqttl = 1 NO-LOCK NO-ERROR.
        
             IF   AVAIL crapttl  THEN
                  ASSIGN aux_cdempres = crapttl.cdempres.
         END.
    ELSE
         DO:
             FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                                crapjur.nrdconta = crapass.nrdconta
                                NO-LOCK NO-ERROR.
        
             IF   AVAIL crapjur  THEN
                  ASSIGN aux_cdempres = crapjur.cdempres.
         END.

    IF   aux_cdempres <> par_cdempres THEN
         NEXT.

    ASSIGN est_flgsomar = TRUE.

    FOR EACH crapavs WHERE crapavs.cdcooper = glb_cdcooper       AND
                           crapavs.nrdconta = crapass.nrdconta   AND
                           crapavs.tpdaviso = 1                  AND
                           crapavs.dtrefere = aux_dtrefere       AND
                         ((crapavs.cdhistor = 108                OR
                           crapavs.cdhistor = 127)               OR
                           crapavs.nrconven > 0) USE-INDEX crapavs2 NO-LOCK:

        IF   crapavs.nrconven > 0   THEN
             DO:
                 ASSIGN ger_vlavscnv[crapavs.nrconven] =
                            ger_vlavscnv[crapavs.nrconven] + crapavs.vllanmto
                        ger_qtavscnv[crapavs.nrconven] =
                            ger_qtavscnv[crapavs.nrconven] + 1.

                 IF   crapavs.vldebito > 0   THEN
                      ASSIGN ger_vldebcnv[crapavs.nrconven] =
                                 ger_vldebcnv[crapavs.nrconven] +
                                     crapavs.vldebito
                             ger_qtdebcnv[crapavs.nrconven] =
                                 ger_qtdebcnv[crapavs.nrconven] + 1.
                 ELSE                                   /*  Estouro integral  */
                      ASSIGN ger_vlestcnv[crapavs.nrconven] =
                                 ger_vlestcnv[crapavs.nrconven] +
                                     crapavs.vllanmto
                             ger_qtestcnv[crapavs.nrconven] =
                                 ger_qtestcnv[crapavs.nrconven] + 1.

                 NEXT.
             END.

        /*  Tratamento dos historicos 108 e 127  */

        IF   crapavs.vldebito = 0   AND   crapavs.vlestdif = 0   THEN
             avs_vlestdif = crapavs.vllanmto * -1.
        ELSE
             avs_vlestdif = crapavs.vlestdif.

        /*  Acumula total geral dos aviso  */

        IF   crapavs.cdhistor = 108   THEN
             DO:
                 ASSIGN ger_vlavsemp = ger_vlavsemp + crapavs.vllanmto
                        ger_vldebemp = ger_vldebemp + crapavs.vldebito.

                 IF   avs_vlestdif > 0   THEN
                      ger_vlantemp = ger_vlantemp + avs_vlestdif.
                 ELSE
                 IF   avs_vlestdif < 0   THEN
                      ger_vlantemp = ger_vlantemp + (crapavs.vllanmto +
                                     avs_vlestdif - crapavs.vldebito).
             END.
        ELSE
        IF   crapavs.cdhistor = 127   THEN
             DO:
                 ASSIGN ger_vlavscot = ger_vlavscot + crapavs.vllanmto
                        ger_vldebcot = ger_vldebcot + crapavs.vldebito.

                 IF   avs_vlestdif > 0   THEN
                      ger_vlantcot = ger_vlantcot + avs_vlestdif.
                 ELSE
                 IF   avs_vlestdif < 0   THEN
                      ger_vlantcot = ger_vlantcot + (crapavs.vllanmto +
                                     avs_vlestdif - crapavs.vldebito).
             END.

        IF   crapavs.vldebito = crapavs.vllanmto   THEN
             NEXT.

        IF   avs_vlestdif > 0   THEN
             ASSIGN rel_vlestdif = avs_vlestdif
                    rel_dscritic = "DEBITO MENOR".
        ELSE
        IF   avs_vlestdif < 0   THEN
             DO:
                 ASSIGN rel_vlestdif = avs_vlestdif * -1
                        rel_dscritic = "ESTOURO".

                 IF   crapavs.cdhistor = 108   THEN
                      ASSIGN tot_qtestemp[crapass.cdagenci] =
                                          tot_qtestemp[crapass.cdagenci] +
                                          IF est_flgsomar
                                             THEN 1
                                             ELSE 0

                             tot_vlestemp[crapass.cdagenci] =
                                          tot_vlestemp[crapass.cdagenci] +
                                                       rel_vlestdif

                             ass_vlestemp = rel_vlestdif
                             ass_vlestdif = ass_vlestdif + rel_vlestdif

                             est_flgsomar = FALSE.
                 ELSE
                 IF   crapavs.cdhistor = 127   THEN
                      ASSIGN tot_qtestcot[crapass.cdagenci] =
                                          tot_qtestcot[crapass.cdagenci] + 1

                             tot_vlestcot[crapass.cdagenci] =
                                          tot_vlestcot[crapass.cdagenci] +
                                                       rel_vlestdif.
             END.

    END.  /*  Fim do FOR EACH -- Leitura dos avisos  */

    ASSIGN ass_vlestdif = 0
           ass_vlestemp = 0.

END.  /*  Fim do FOR EACH -- Leitura dos associados  */

ASSIGN rel_cdagenci = 1000
       rel_dsagenci[rel_cdagenci] = "RESUMO GERAL".

DISPLAY STREAM str_3
        rel_dsagenci[rel_cdagenci] rel_dsconven rel_dsempres  aux_dtrefere
        WITH FRAME f_agencia.

VIEW STREAM str_3 FRAME f_label_total.

DO rel_cdagenci = 1 TO 999:

   IF   tot_qtestcot[rel_cdagenci] = 0   AND
        tot_qtestemp[rel_cdagenci] = 0   THEN
        NEXT.

   ASSIGN ger_qtestcot = ger_qtestcot + tot_qtestcot[rel_cdagenci]
          ger_qtestemp = ger_qtestemp + tot_qtestemp[rel_cdagenci]
          ger_vlestcot = ger_vlestcot + tot_vlestcot[rel_cdagenci]
          ger_vlestemp = ger_vlestemp + tot_vlestemp[rel_cdagenci].

   DISPLAY STREAM str_3
           rel_dsagenci[rel_cdagenci]
           tot_qtestcot[rel_cdagenci]  tot_vlestcot[rel_cdagenci]
           tot_qtestemp[rel_cdagenci]  tot_vlestemp[rel_cdagenci]
           WITH FRAME f_total_ger.

   DOWN STREAM str_3 WITH FRAME f_total_ger.

   IF   LINE-COUNTER(str_3) > PAGE-SIZE(str_3)   THEN
        DO:
            PAGE STREAM str_3.

            DISPLAY STREAM str_3
                    "RESUMO GERAL" @ rel_dsagenci[rel_cdagenci] rel_dsconven
                    rel_dsempres  aux_dtrefere
                    WITH FRAME f_agencia.

            VIEW STREAM str_3 FRAME f_label_total.
        END.

END.  /*  Fim do DO .. TO  */

DISPLAY STREAM str_3
        ger_qtestcot  ger_vlestcot  ger_qtestemp  ger_vlestemp
        ger_vlavscot  ger_vlavsemp  ger_vldebcot  ger_vldebemp
        ger_vlantcot  ger_vlantemp
        WITH FRAME f_total.

OUTPUT STREAM str_3 CLOSE.

ASSIGN glb_nrcopias = 2
       glb_nmformul = ""
       glb_nmarqimp = aux_nmarqest[aux_contaarq]

       aux_flgexist = FALSE.

RUN fontes/imprim.p.

/*  Trata estouro dos CONVENIOS ............................................. */

aux_contador = NUM-ENTRIES(aux_lshstden).

FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper       AND
                       craptab.nmsistem = "CRED"             AND
                       craptab.tptabela = "GENERI"           AND
                       craptab.cdempres = 0                  AND
                       craptab.cdacesso = "CONVFOLHAS" NO-LOCK:

    ASSIGN aux_lshstden = aux_lshstden + (IF aux_lshstden = ""
                                            THEN STRING(craptab.tpregist)
                                            ELSE "," + STRING(craptab.tpregist))

           aux_contador = aux_contador + 1

           aux_dshstden[aux_contador] = craptab.dstextab.

END.  /*  Fim do FOR EACH -- Leitura dos historicos de convenio  */

{ includes/cabrel132_4.i }

OUTPUT STREAM str_4 TO VALUE(aux_nmarqden[aux_contaarq]) PAGED PAGE-SIZE 84.

VIEW STREAM str_4 FRAME f_cabrel132_4.

FOR EACH crapavs WHERE crapavs.cdcooper = glb_cdcooper   AND
                       crapavs.cdempres = par_cdempres   AND
                       crapavs.tpdaviso = 1              AND
                       crapavs.dtrefere = aux_dtrefere   AND
                       CAN-DO(aux_lshstden,STRING(crapavs.cdhistor)) NO-LOCK
                       BREAK BY crapavs.cdhistor
                                BY crapavs.cdagenci
                                   BY crapavs.nrdconta:

    IF   FIRST-OF(crapavs.cdhistor)   THEN
         DO:
             ASSIGN rel_cdagenci = 0   tot_qtestden = 0   tot_vlestden = 0
                    ger_qtavsden = 0   ger_vlavsden = 0   ger_qtdebden = 0
                    ger_vldebden = 0   ger_qtestden = 0   ger_vlestden = 0
                    ger_vlantden = 0   ger_vlantden = 0   ass_vlestdif = 0
                    ass_vlestden = 0   aux_flgexist = TRUE

                    rel_dsconven = aux_dshstden[LOOKUP(STRING(crapavs.cdhistor),
                                                       aux_lshstden)].

             FIND craphis NO-LOCK WHERE
                                   craphis.cdcooper = crapavs.cdcooper AND 
                                   craphis.cdhistor = crapavs.cdhistor NO-ERROR.
             IF   NOT AVAILABLE craphis   THEN
                  rel_dshistor = "N/CADASTRADO".
             ELSE
                  rel_dshistor = craphis.dshistor.

             DISPLAY STREAM str_4  "GERAL" @ rel_dsagenci[rel_cdagenci]
                                   rel_dsconven  rel_dsempres  aux_dtrefere
                                   WITH FRAME f_agencia.

             DOWN STREAM str_4 WITH FRAME f_agencia.

             VIEW STREAM str_4 FRAME f_label_aviso.

         END.

    IF   crapavs.vldebito = 0   AND   crapavs.vlestdif = 0   THEN
         avs_vlestdif = crapavs.vllanmto * -1.
    ELSE
         avs_vlestdif = crapavs.vlestdif.

    /*  Acumula total geral dos aviso  */

    ASSIGN ger_vlavsden = ger_vlavsden + crapavs.vllanmto
           ger_vldebden = ger_vldebden + crapavs.vldebito

           ger_qtavsden = ger_qtavsden + 1
           ger_qtdebden = ger_qtdebden + (IF crapavs.vldebito > 0
                                             THEN 1
                                             ELSE 0).

    IF   avs_vlestdif > 0   THEN
         ger_vlantden = ger_vlantden + avs_vlestdif.
    ELSE
    IF   avs_vlestdif < 0   THEN
         ger_vlantden = ger_vlantden + (crapavs.vllanmto +
                                        avs_vlestdif - crapavs.vldebito).

    IF   crapavs.vldebito <> crapavs.vllanmto   THEN
         DO:
             IF   avs_vlestdif > 0   THEN
                  ASSIGN rel_vlestdif = avs_vlestdif
                         rel_dscritic = "DEBITO MENOR".
             ELSE
             IF   avs_vlestdif < 0   THEN
                  DO:
                      ASSIGN rel_vlestdif = avs_vlestdif * -1
                             rel_dscritic = "ESTOURO"

                             tot_qtestden[999] = tot_qtestden[999] + 1

                             tot_vlestden[999] =
                                          tot_vlestden[999] + rel_vlestdif

                             tot_qtestden[crapavs.cdagenci] =
                                          tot_qtestden[crapavs.cdagenci] + 1

                             tot_vlestden[crapavs.cdagenci] =
                                 tot_vlestden[crapavs.cdagenci] + rel_vlestdif.
                  END.

             IF   FIRST-OF(crapavs.nrdconta)   THEN
                  DO:
                      /*FIND crapass OF crapavs NO-LOCK NO-ERROR.*/
                      FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                                         crapass.nrdconta = crapavs.nrdconta
                                         NO-LOCK NO-ERROR.

                      IF   NOT AVAILABLE crapass   THEN
                           DO:
                               glb_cdcritic = 251.
                               RUN fontes/critic.p.
                               UNIX SILENT VALUE("echo " +
                                    STRING(TIME,"HH:MM:SS") +
                                    " - " + glb_cdprogra + "' --> '" +
                                    glb_dscritic + "' --> '" + " Conta/dv " +
                                    STRING(crapavs.nrdconta) +
                                    " >> log/proc_batch.log").

                               DISPLAY STREAM str_4
                                       crapavs.nrdconta
                                       "NAO CADASTRADO" @ crapass.nmprimtl
                                       WITH FRAME f_aviso.
                           END.
                      ELSE
                           DO:
                               FIND crapttl NO-LOCK WHERE 
                                    crapttl.cdcooper = glb_cdcooper       AND
                                    crapttl.nrdconta = crapass.nrdconta   AND
                                    crapttl.idseqttl = 1   NO-ERROR.
                               
                               DISPLAY STREAM str_4
                                       crapass.cdagenci
                                       crapavs.nrdconta  crapass.nrramemp
                                       crapttl.cdturnos  WHEN AVAILABLE crapttl
                                       crapass.nmprimtl
                                       WITH FRAME f_aviso.
                  
                           END.
                  END.

             DISPLAY STREAM str_4
                     rel_dshistor      crapavs.nrdocmto  crapavs.nrseqdig
                     crapavs.vllanmto  crapavs.vldebito  rel_vlestdif
                     rel_dscritic
                     WITH FRAME f_aviso.

             DOWN STREAM str_4 WITH FRAME f_aviso.

             IF   LINE-COUNTER(str_4) > PAGE-SIZE(str_4)   THEN
                  DO:
                      PAGE STREAM str_4.

                      DISPLAY STREAM str_4
                              "GERAL" @ rel_dsagenci[rel_cdagenci]
                               rel_dsconven  rel_dsempres  aux_dtrefere
                                 WITH FRAME f_agencia.

                      DOWN STREAM str_4 WITH FRAME f_agencia.

                      VIEW STREAM str_4 FRAME f_label_aviso.

                  END.
         END.

    IF   LAST-OF(crapavs.cdhistor)   THEN
         DO:
             ASSIGN rel_cdagenci = 999.

             DISPLAY STREAM str_4
                     tot_qtestden[rel_cdagenci]
                     tot_vlestden[rel_cdagenci]
                     WITH FRAME f_total_age_den.

             PAGE STREAM str_4.

             ASSIGN rel_cdagenci = 1000
                    rel_dsagenci[rel_cdagenci] = "RESUMO GERAL".

             DISPLAY STREAM str_4
                     rel_dsagenci[rel_cdagenci]  rel_dsconven
                     rel_dsempres  aux_dtrefere
                     WITH FRAME f_agencia.

             VIEW STREAM str_4 FRAME f_label_total_den.

             DO rel_cdagenci = 1 TO 998:

                IF   tot_qtestden[rel_cdagenci] = 0   THEN
                     NEXT.

                ASSIGN ger_qtestden = ger_qtestden + tot_qtestden[rel_cdagenci]
                       ger_vlestden = ger_vlestden + tot_vlestden[rel_cdagenci].

                DISPLAY STREAM str_4
                        rel_dsagenci[rel_cdagenci]
                        tot_qtestden[rel_cdagenci]  tot_vlestden[rel_cdagenci]
                        WITH FRAME f_total_ger_den.

                DOWN STREAM str_4 WITH FRAME f_total_ger_den.

                IF   LINE-COUNTER(str_4) > PAGE-SIZE(str_4)   THEN
                     DO:
                         PAGE STREAM str_4.

                         DISPLAY STREAM str_4
                                 "RESUMO GERAL" @ rel_dsagenci[rel_cdagenci]
                                 rel_dsconven  rel_dsempres  aux_dtrefere
                                 WITH FRAME f_agencia.

                         VIEW STREAM str_4 FRAME f_label_total_den.
                     END.

             END.  /*  Fim do DO .. TO  */

             DISPLAY STREAM str_4
                     ger_qtestden  ger_vlestden
                     ger_qtavsden  ger_vlavsden
                     ger_qtdebden  ger_vldebden
                     WITH FRAME f_total_den.

             PAGE STREAM str_4.
         END.

END.  /*  Fim do FOR EACH  --  Leitura do crapavs  */

/*  Emite resumo de outros convenios - Sindicatos, farmacias, etc  */

con_flgfirst = TRUE.

DO aux_contador = 1 TO 999:

   IF   ger_qtavscnv[aux_contador] = 0   AND
        ger_qtdebcnv[aux_contador] = 0   AND
        ger_qtestcnv[aux_contador] = 0   THEN
        NEXT.

   IF   con_flgfirst   THEN
        DO:
            DISPLAY STREAM str_4 rel_dsempres WITH FRAME f_empresa.

            con_flgfirst = FALSE.
        END.

   FIND crapcnv WHERE crapcnv.cdcooper = glb_cdcooper AND
                      crapcnv.nrconven = aux_contador NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapcnv   THEN
        rel_dsconven = STRING(aux_contador,"999") + " - NAO CADASTRADO.".
   ELSE
        rel_dsconven = STRING(aux_contador,"999") + " - " + crapcnv.dsconven.

   DISPLAY STREAM str_4
           rel_dsconven
           ger_qtavscnv[aux_contador] ger_vlavscnv[aux_contador]
           ger_qtdebcnv[aux_contador] ger_vldebcnv[aux_contador]
           ger_qtestcnv[aux_contador] ger_vlestcnv[aux_contador]
           WITH FRAME f_convenio.

   DOWN STREAM str_4 WITH FRAME f_convenio.

   IF   LINE-COUNTER(str_4) > 70   THEN
        DO:
            PAGE STREAM str_4.

            DISPLAY STREAM str_4 rel_dsempres WITH FRAME f_empresa.
        END.

   aux_flgexist = TRUE.

END.  /*  Fim do DO .. TO  */

OUTPUT STREAM str_4 CLOSE.
        
IF   aux_flgexist   THEN
     DO:
         ASSIGN glb_nrcopias = 2
                glb_nmformul = ""
                glb_nmarqimp = aux_nmarqden[aux_contaarq]
                aux_flarqden = TRUE.

         /*  RUN fontes/imprim.p.  */
     END.
ELSE
    aux_flarqden = FALSE.
/* .......................................................................... */
