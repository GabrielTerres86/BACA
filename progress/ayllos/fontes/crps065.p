/* ..........................................................................

   Programa: Fontes/crps065.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Agosto/93.                          Ultima atualizacao: 24/04/2017

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 036.
               Emitir a relacao de controle dos debitos do IPMF (53).

   Alteracoes: 05/07/94 - Alteracao no literal "cruzeiros reais".

               30/01/97 - Alterar os literais de IPMF para CPMF (Odair)

               06/04/1999 - Acerto para ler somente do ano que interessa 
                            (Deborah).

               09/06/1999 - Tratar CPMF (Deborah).

               03/03/2000 - Mudar formulario para 132dm (Deborah). 
                
               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
                          
               05/08/2009 - Nao processar enquanto o CPMF estiver suspenso - 
                            utilizada includes/cpmf.i (Fernando).
                            
               13/12/2013 - Alterado coluna da variavel rel_nrcpfcgc de 
                            "CPF/CGC" para "CPF/CNPJ". (Reinert)

			   24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

 ............................................................................ */

DEF STREAM str_1.    /*  Para relatorio de controle dos debitos do IPMF  */

{ includes/var_batch.i "NEW" }
{ includes/var_cpmf.i }

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR rel_nrcpfcgc AS CHAR                                  NO-UNDO.

DEF        VAR tab_dtiniper AS DATE    EXTENT 10                     NO-UNDO.
DEF        VAR tab_dtfimper AS DATE    EXTENT 10                     NO-UNDO.
DEF        VAR tab_dtdebito AS DATE    EXTENT 10                     NO-UNDO.
DEF        VAR tab_dtrecolh AS DATE    EXTENT 10                     NO-UNDO.
DEF        VAR tab_vlmoefix AS DECIMAL EXTENT 10                     NO-UNDO.
DEF        VAR tab_qtlancto AS INT     EXTENT 10                     NO-UNDO.
DEF        VAR tab_vlbasipm AS DECIMAL EXTENT 10                     NO-UNDO.
DEF        VAR tab_vldoipmf AS DECIMAL EXTENT 10                     NO-UNDO.
DEF        VAR tab_qtipmmfx AS DECIMAL EXTENT 10                     NO-UNDO.

DEF        VAR tot_qtlancto AS INT                                   NO-UNDO.
DEF        VAR tot_vlbasipm AS DECIMAL                               NO-UNDO.
DEF        VAR tot_vldoipmf AS DECIMAL                               NO-UNDO.
DEF        VAR tot_qtipmmfx AS DECIMAL                               NO-UNDO.

DEF        VAR aux_qtipmmfx AS DECIMAL                               NO-UNDO.

DEF        VAR aux_literalA AS CHAR    INIT "A"                      NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_contamax AS INT                                   NO-UNDO.
DEF        VAR aux_nrdconta AS INT                                   NO-UNDO.

DEF        VAR aux_flgexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgimpri AS LOGICAL                               NO-UNDO.
DEF        VAR aux_nmsegntl LIKE crapttl.nmextttl                    NO-UNDO.

glb_cdprogra = "crps065".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.
  
FORM "PERIODOS"                 AT 24
     "APURACAO"                 AT 42
     "DEBITO NA CONTA-CORRENTE" AT 64
     "RECOLHIMENTO"             AT 95
     SKIP(1)
     WITH NO-BOX WIDTH 132 FRAME f_label_per.

FORM aux_contador               AT 27 FORMAT "z9"
     tab_dtiniper[aux_contador] AT 36 FORMAT "99/99/9999"
     aux_literalA               AT 47 FORMAT "x"
     tab_dtfimper[aux_contador] AT 49 FORMAT "99/99/9999"
     tab_dtdebito[aux_contador] AT 72 FORMAT "99/99/9999"
     tab_dtrecolh[aux_contador] AT 97 FORMAT "99/99/9999"
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_periodos.

FORM crapass.nrdconta AT   1 FORMAT "zzzz,zzz,9"          LABEL "CONTA/DV"
     crapass.nmprimtl AT  12 FORMAT "x(35)"               LABEL "TITULAR(ES)"
     rel_nrcpfcgc     AT  48 FORMAT "x(20)"               LABEL "CPF/CNPJ"
     aux_contador     AT  69 FORMAT "z9"                  LABEL "PER"
     crapipm.vlbasipm AT  73 FORMAT "zzz,zzz,zzz,zz9.99-"
                             LABEL "BASE DE CALCULO"
     crapipm.vldoipmf AT  93 FORMAT "zzz,zzz,zzz,zz9.99-"
                             LABEL "VALOR DO DEBITO"
     aux_qtipmmfx     AT 113 FORMAT "zzz,zzz,zzz,zz9.9999"
                             LABEL "CPMF EM UFIR"
     WITH NO-BOX NO-LABELS WIDTH 132 DOWN FRAME f_debitos.

FORM SKIP(1)
     "RESUMO GERAL:"
     SKIP(1)
     "PER       APURACAO        DEBITO  RECOLHIMENTO  LANCTOS" AT   1
     "BASE DE CALCULO                VALOR DEBITADO"           AT  63
     "CPMF EM UFIR"                                            AT 121
     SKIP(1)
     WITH NO-BOX WIDTH 132 FRAME f_label_res.

FORM aux_contador               AT   1 FORMAT "z9"
     tab_dtiniper[aux_contador] AT   5 FORMAT "99/99/9999"
     aux_literalA               AT  16 FORMAT "x"
     tab_dtfimper[aux_contador] AT  18 FORMAT "99/99/9999"
     tab_dtdebito[aux_contador] AT  29 FORMAT "99/99/9999"
     tab_dtrecolh[aux_contador] AT  40 FORMAT "99/99/9999"
     tab_qtlancto[aux_contador] AT  51 FORMAT "zzz,zz9"
     tab_vlbasipm[aux_contador] AT  59 FORMAT "zzzz,zzz,zzz,zz9.99-"
     tab_vldoipmf[aux_contador] AT  80 FORMAT "zzzz,zzz,zzz,zzz,zzz,zz9.99-"
     tab_qtipmmfx[aux_contador] AT 109 FORMAT "zzz,zzz,zzz,zzz,zz9.9999"
     WITH NO-BOX NO-LABELS WIDTH 132 DOWN FRAME f_resumo.

{ includes/cpmf.i }

IF   tab_dtfimpmf < glb_dtmvtoan   THEN
     DO:
        RUN fontes/fimprg.p.
        RETURN.
     END.

{ includes/cabrel132_1.i }

/*  Leitura dos periodos de apuracao ja debitados  */

FOR EACH crapper WHERE  crapper.cdcooper  =       glb_cdcooper    AND
                  MONTH(crapper.dtdebito) = MONTH(glb_dtmvtoan)   AND
                   YEAR(crapper.dtdebito) =  YEAR(glb_dtmvtoan)   AND
                        crapper.indebito  = 2                     NO-LOCK:

    FIND crapmfx WHERE crapmfx.cdcooper = glb_cdcooper       AND
                       crapmfx.dtmvtolt = crapper.dtdebito   AND
                       crapmfx.tpmoefix = 2                  NO-LOCK NO-ERROR.   
    IF   NOT AVAILABLE crapmfx   THEN
         DO:
             glb_cdcritic = 140.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" + glb_dscritic +
                               " UFIR do dia " + STRING(crapper.dtdebito) +
                               " >> log/proc_batch.log").
             QUIT.
         END.

    ASSIGN aux_contador               = aux_contador + 1

           tab_dtiniper[aux_contador] = crapper.dtiniper
           tab_dtfimper[aux_contador] = crapper.dtfimper
           tab_dtdebito[aux_contador] = crapper.dtdebito
           tab_dtrecolh[aux_contador] = crapper.dtrecolh
           tab_vlmoefix[aux_contador] = crapmfx.vlmoefix.

END.  /*  Fim do FOR EACH  --  Leitura dos periodos de apuracao ja debitados  */

aux_contamax = aux_contador.

IF   aux_contamax = 0   THEN
     DO:
         RUN fontes/fimprg.p.
         QUIT.
     END.

OUTPUT STREAM str_1 TO rl/crrl053.lst PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel132_1.
VIEW STREAM str_1 FRAME f_label_per.

DO aux_contador = 1 TO aux_contamax:

   DISPLAY STREAM str_1
           aux_contador
           aux_literalA
           tab_dtiniper[aux_contador]
           tab_dtfimper[aux_contador]
           tab_dtdebito[aux_contador]
           tab_dtrecolh[aux_contador]
           WITH FRAME f_periodos.

   IF   aux_contador = aux_contamax   THEN
        DOWN STREAM str_1 2 WITH FRAME f_periodos.
   ELSE
        DOWN STREAM str_1 WITH FRAME f_periodos.

   IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
        DO:
            PAGE STREAM str_1.
            IF   aux_contador < aux_contamax   THEN
                 VIEW STREAM str_1 FRAME f_label_per.
        END.

END.  /*  Fim do DO .. TO  */

/*  Leitura do IPMF dos associados  */

FOR EACH crapipm WHERE crapipm.cdcooper = glb_cdcooper  AND
                       crapipm.indebito = 2             NO-LOCK:

    ASSIGN aux_flgexist = FALSE
	       aux_nmsegntl = "".

    DO aux_contador = 1 TO aux_contamax:

       IF   tab_dtdebito[aux_contador] = crapipm.dtdebito   THEN
            DO:
                aux_flgexist = TRUE.
                LEAVE.
            END.

    END.  /*  Fim do DO .. TO  */

    IF   NOT aux_flgexist   THEN
         NEXT.

    ASSIGN aux_qtipmmfx = TRUNCATE(crapipm.vldoipmf /
                                   tab_vlmoefix[aux_contador],4)

           tab_qtlancto[aux_contador] = tab_qtlancto[aux_contador] + 1
           tab_vlbasipm[aux_contador] = tab_vlbasipm[aux_contador] +
                                                         crapipm.vlbasipm
           tab_vldoipmf[aux_contador] = tab_vldoipmf[aux_contador] +
                                                         crapipm.vldoipmf
           tab_qtipmmfx[aux_contador] = tab_qtipmmfx[aux_contador] +
                                                         aux_qtipmmfx.

    /*FIND crapass OF crapipm NO-LOCK NO-ERROR.*/
    FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                       crapass.nrdconta = crapipm.nrdconta
                       NO-LOCK NO-ERROR.                

    IF   NOT AVAILABLE crapass   THEN
         DO:
             glb_cdcritic = 251.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" + glb_dscritic +
                               "CONTA = " + STRING(crapipm.nrdconta) +
                               " >> log/proc_batch.log").
             QUIT.
         END.

    IF   crapass.inpessoa = 1   THEN
	     DO:
         ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xxx.xxx.xxx-xx").

             FOR FIRST crapttl FIELDS(nmextttl) 
			                   WHERE crapttl.cdcooper = crapass.cdcooper AND
							         crapttl.nrdconta = crapass.nrdconta AND
									 crapttl.idseqttl = 2
									 NO-LOCK:

			   ASSIGN aux_nmsegntl = crapttl.nmextttl.

			 END.

	     END.
    ELSE
         ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").

    IF   aux_nrdconta = crapipm.nrdconta   THEN
         DO:
             IF   aux_nmsegntl <> "" AND
                  NOT aux_flgimpri                       THEN
                  DO:
                      DISPLAY STREAM str_1
                              aux_nmsegntl FORMAT "x(35)" @ crapass.nmprimtl
                              WITH FRAME f_debitos.

                      aux_flgimpri = TRUE.
                  END.

             DISPLAY STREAM str_1
                     aux_contador      crapipm.vlbasipm
                     crapipm.vldoipmf  aux_qtipmmfx
                     WITH FRAME f_debitos.
         END.
    ELSE
         DO:
             DISPLAY STREAM str_1
                     crapass.nrdconta  crapass.nmprimtl  rel_nrcpfcgc
                     aux_contador      crapipm.vlbasipm  crapipm.vldoipmf
                     aux_qtipmmfx
                     WITH FRAME f_debitos.

             ASSIGN aux_nrdconta = crapipm.nrdconta
                    aux_flgimpri = FALSE.
         END.

    DOWN STREAM str_1 WITH FRAME f_debitos.

    IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
         PAGE STREAM str_1.

END.  /*  Fim do FOR EACH  --  Leitura do IPMF dos associados  */

/*  Gera resumo geral  */

IF   LINE-COUNTER(str_1) > 80   THEN
     PAGE STREAM str_1.

VIEW STREAM str_1 FRAME f_label_res.

DO aux_contador = 1 TO aux_contamax:

   DISPLAY STREAM str_1
           aux_contador
           aux_literalA
           tab_dtiniper[aux_contador]
           tab_dtfimper[aux_contador]
           tab_dtdebito[aux_contador]
           tab_dtrecolh[aux_contador]
           tab_qtlancto[aux_contador]
           tab_vlbasipm[aux_contador]
           tab_vldoipmf[aux_contador]
           tab_qtipmmfx[aux_contador]
           WITH FRAME f_resumo.

   DOWN STREAM str_1 WITH FRAME f_resumo.

   IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
        PAGE STREAM str_1.

   ASSIGN tot_qtlancto = tot_qtlancto + tab_qtlancto[aux_contador]
          tot_vlbasipm = tot_vlbasipm + tab_vlbasipm[aux_contador]
          tot_vldoipmf = tot_vldoipmf + tab_vldoipmf[aux_contador]
          tot_qtipmmfx = tot_qtipmmfx + tab_qtipmmfx[aux_contador].

END.  /*  Fim do DO .. TO  */

aux_contador = 1.

IF  (LINE-COUNTER(str_1) + 1) > PAGE-SIZE(str_1)   THEN
     PAGE STREAM str_1.
ELSE
     DISPLAY STREAM str_1 SKIP WITH FRAME f_linha.

DISPLAY STREAM str_1
        tot_qtlancto @ tab_qtlancto[aux_contador]
        tot_vlbasipm @ tab_vlbasipm[aux_contador]
        tot_vldoipmf @ tab_vldoipmf[aux_contador]
        tot_qtipmmfx @ tab_qtipmmfx[aux_contador]
        WITH FRAME f_resumo.

OUTPUT STREAM str_1 CLOSE.

ASSIGN glb_nmarqimp = "rl/crrl053.lst"
       glb_nrcopias = 1
       glb_nmformul = "132dm".

RUN fontes/imprim.p.

RUN fontes/fimprg.p.

/* .......................................................................... */

