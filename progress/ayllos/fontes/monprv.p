/*..............................................................................

    Programa: fontes/monprv.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Guilherme/Supero
    Data    : Outubro/2010                   Ultima atualizacao: 17/01/2014
    
    Dados referentes ao programa:

    Frequencia: Diario.
    Objetivo  : Consulta de Previas de Cheques compensados.
               
    Alteracoes: 09/12/2010 - Inclusao da Opcao "M"
                             Correcao da coluna Nr Previa na opcao "C"
                             Removida opcao "E" (Guilherme/Supero)

                27/01/2011 - Incluir o Banco/Caixa 500 - LANCHQ (Ze).

                22/02/2011 - Op. "C" e "M" - Incluido processamento para 
                             Custodia(crapCST) e Desconto(crapCDB)
                             Guilherme/Supero
                             
                28/02/2011 - Modificacao dos layouts do browser e do campo 
                             "custodia-desconto" nas opcoes "C" e "M" (Vitor).
                             
                07/04/2011 - Filtrar para cheques de outros bancos (Ze).
                
                18/05/2011 - Incluido cheques com banco/caixa 500 (Elton).
                
                28/09/2011 - Aplicacao de testes de digitalizacao para cheques
                             da propria cooperativa - Somente Coop. 4 (Ze).
                             
                28/10/2011 - Na opção "M" retirada a coluna Digitalizado
                             (Processar: Caixa/Custodia-Desconto).
                           - Na opção "C" retirado do campo Situação o item
                             Digitalizado 
                           - Na coluna Situação retirado o item Digitalizado 
                             (Processar: Caixa/Custodia-Desconto).
                             (Isara - RKAM)
                             
                17/11/2011 - Realizado alteracao para que, quando central, possa
                             ser optado por consultar nas demais cooperativas
                             (Adriano).             
                             
                13/02/2012 - Alteracao para que todas as coops possam 
                             digitalizar cheques da propria cooperativa (ZE).
                
                14/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
                            
                17/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                             nao cadastrado.". (Reinert)                            
..............................................................................*/

{ includes/var_online.i }

DEF STREAM str_2.

/* Variaveis de Tela */
DEF VAR tel_cddopcao AS CHAR        FORMAT "!(1)"                      NO-UNDO.
DEF VAR tel_dssituac AS CHAR        FORMAT "x(17)" VIEW-AS COMBO-BOX 
    INNER-LINES 4  LIST-ITEMS "Pendente",
                              "Nao Enviado",
                              "Gerado",
                              "Processado"                             NO-UNDO.
DEF VAR tel_dssitua2 AS CHAR        FORMAT "x(17)" VIEW-AS COMBO-BOX 
    INNER-LINES 4  LIST-ITEMS "Pendente",
                              "Nao Enviado",
                              "Gerado",
                              "Processado"                             NO-UNDO.
DEF VAR tel_cdagenci AS INT         FORMAT "zz9"    INIT 0             NO-UNDO.
DEF VAR tel_dtrefere AS DATE        FORMAT "99/99/9999"                NO-UNDO.
DEF VAR tel_datadlog AS DATE        FORMAT "99/99/9999"                NO-UNDO.
DEF VAR tel_pesquisa AS CHAR        FORMAT "x(20)"                     NO-UNDO.

DEF VAR tel_dscxcust AS CHAR        FORMAT "X(17)" VIEW-AS COMBO-BOX 
    INNER-LINES 2  LIST-ITEMS "Caixa",
                              "Custodia-Desconto"                      NO-UNDO.
DEF VAR tel_dscxcus2 AS CHAR        FORMAT "X(17)" VIEW-AS COMBO-BOX 
    INNER-LINES 2  LIST-ITEMS "Caixa",
                              "Custodia-Desconto"                      NO-UNDO.

/* Demais variaveis */
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nmcooper AS CHAR FORMAT "x(12)"                            NO-UNDO.
DEF VAR aux_cdsituac AS CHAR                                           NO-UNDO.
DEF VAR aux_contador AS INT         INIT 0                             NO-UNDO.
DEF VAR aux_cdagefim AS INT         INIT 0                             NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nomedarq AS CHAR        EXTENT 2                           NO-UNDO.
DEF VAR aux_tamarqui AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INT         INIT 0                             NO-UNDO.
DEF VAR aux_qtsitprv AS INT         EXTENT 9                           NO-UNDO.
DEF VAR aux_qtcaptur AS INT                                            NO-UNDO.
DEF VAR aux_qtprevia AS INT         INIT 0                             NO-UNDO.
DEF VAR aux_nmoperad AS CHAR        INIT ""                            NO-UNDO.

DEF VAR aux_cdcxcust AS CHAR                                           NO-UNDO.

/* variaveis para impressao */
DEF VAR aux_nmendter AS CHAR        FORMAT "x(20)"                     NO-UNDO.
DEF VAR par_flgrodar AS LOGICAL     INIT TRUE                          NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                        NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                           NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL     INIT TRUE                          NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                        NO-UNDO.
DEF VAR tel_dsimprim AS CHAR        FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF VAR tel_dscancel AS CHAR        FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.
DEF VAR aux_flexetru AS LOGICAL                   INIT FALSE           NO-UNDO.

DEF VAR aux_cdcooper AS INT                                            NO-UNDO.
DEF VAR tel_cdcooper AS CHAR FORMAT "x(12)" VIEW-AS COMBO-BOX
                             INNER-LINES 11                            NO-UNDO.
DEF VAR tel_cdcoope2 AS CHAR FORMAT "x(12)" VIEW-AS COMBO-BOX
                             INNER-LINES 11                            NO-UNDO.

DEFINE TEMP-TABLE tt-cheques                                           NO-UNDO
         FIELD cdagenci       LIKE crapchd.cdagenci
         FIELD nrdcaixa       AS INT
         FIELD nmoperad       LIKE crapope.nmoperad
         FIELD hrprevia       AS CHAR
         FIELD nrprevia       LIKE crapchd.nrprevia
         FIELD qtprevia       AS INT
         FIELD vlprevia       AS DECI
         FIELD dssitabr       AS CHAR.

DEFINE TEMP-TABLE tt-previas                                            NO-UNDO
         FIELD cdagenci       LIKE crapchd.cdagenci
         FIELD nrdcaixa       AS INT
         FIELD nmoperad       LIKE crapope.nmoperad
         FIELD qtcaptur       AS INT
         FIELD qtsit000       AS INT
         FIELD qtsit001       AS INT
         FIELD qtsit003       AS INT
         FIELD qtprevia       AS INT.

DEF QUERY q_crapchd   FOR tt-cheques.
DEF QUERY q_crapchd_2 FOR tt-cheques.
DEF QUERY q_previas   FOR tt-previas.
DEF QUERY q_previas_2 FOR tt-previas.

DEF BUFFER b-crapcop1 FOR crapcop.

DEF BROWSE b_crapchd QUERY q_crapchd
    DISPLAY tt-cheques.cdagenci COLUMN-LABEL "PA"       FORMAT "zz9"
            tt-cheques.nrdcaixa COLUMN-LABEL "Caixa"    FORMAT "zzz9"
            tt-cheques.nmoperad COLUMN-LABEL "Operador" FORMAT "x(16)"
            tt-cheques.nrprevia COLUMN-LABEL "Previa"   FORMAT "zzz9"
            tt-cheques.hrprevia COLUMN-LABEL "Hora"     FORMAT "x(5)"
            tt-cheques.qtprevia COLUMN-LABEL "Qtde"     FORMAT "zzz9"
            tt-cheques.vlprevia COLUMN-LABEL "Valor"    FORMAT "zzz,zzz,zz9.99"
            tt-cheques.dssitabr COLUMN-LABEL "Situacao" FORMAT "x(12)"
            WITH 8 DOWN WIDTH 78 SCROLLBAR-VERTICAL.

DEF BROWSE b_crapchd_2 QUERY q_crapchd_2
    DISPLAY tt-cheques.cdagenci COLUMN-LABEL "PA"         FORMAT "zz9"
            tt-cheques.nmoperad COLUMN-LABEL "Produto"    FORMAT "x(20)"
            tt-cheques.nrdcaixa COLUMN-LABEL "Lote"       FORMAT "zzz,zz9"
            tt-cheques.qtprevia COLUMN-LABEL "Quantidade" FORMAT "zzz,zz9"
            tt-cheques.vlprevia COLUMN-LABEL "Valor"    FORMAT "zzz,zzz,zz9.99"
            tt-cheques.dssitabr COLUMN-LABEL "Situacao" FORMAT "x(14)"
            WITH 8 DOWN WIDTH 78 SCROLLBAR-VERTICAL.

DEF BROWSE b_previas QUERY q_previas
    DISPLAY tt-previas.cdagenci COLUMN-LABEL "PA"          FORMAT "zz9"
            tt-previas.nrdcaixa COLUMN-LABEL "Caixa"       FORMAT "zzz9"
            tt-previas.nmoperad COLUMN-LABEL "Operador"    FORMAT "x(16)"
            tt-previas.qtcaptur COLUMN-LABEL "Captur."     FORMAT "zzz9"
            tt-previas.qtsit000 COLUMN-LABEL "Nao Enviado" FORMAT "zzz9"
            tt-previas.qtsit001 COLUMN-LABEL "Gerado"      FORMAT "zzz9"
            tt-previas.qtsit003 COLUMN-LABEL "Processado"  FORMAT "zzz9"
            tt-previas.qtprevia COLUMN-LABEL "Previas"     FORMAT "zzz9"
            WITH 8 DOWN WIDTH 78 SCROLLBAR-VERTICAL.

DEF BROWSE b_previas_2 QUERY q_previas_2
    DISPLAY tt-previas.cdagenci COLUMN-LABEL "PA"          FORMAT "zz9"
            tt-previas.nmoperad COLUMN-LABEL "Produto"     FORMAT "x(20)"
            tt-previas.qtcaptur COLUMN-LABEL "Captur."     FORMAT "zzz,zz9"
            tt-previas.qtsit000 COLUMN-LABEL "Nao Enviado" FORMAT "zzz,zz9"
            tt-previas.qtsit001 COLUMN-LABEL "Gerado"      FORMAT "zzz,zz9"
            tt-previas.qtsit003 COLUMN-LABEL "Processado"  FORMAT "zzz,zz9"
            tt-previas.qtprevia COLUMN-LABEL "Previas"     FORMAT "zzz,zz9"
            WITH 8 DOWN WIDTH 78 SCROLLBAR-VERTICAL.

/* FORMs */
FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT 03 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (C, M)."
                        VALIDATE(CAN-DO("C,M",glb_cddopcao),
                                        "014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_monprv_1.

FORM tel_dssituac AT 05 LABEL "Situacao"
                        HELP "Informe qual situacao consultar"
     tel_cdagenci AT 39 LABEL "PA"
                        HELP "Informe o numero do PA ou zero '0' para todos."
                        VALIDATE(CAN-FIND(crapage WHERE
                                          crapage.cdcooper = glb_cdcooper AND
                                          crapage.cdagenci = tel_cdagenci) OR
                                          tel_cdagenci = 0 ,
                                          "962 - PA nao cadastrado.")
     tel_dtrefere AT 52 LABEL "Data"
                        HELP "Informe a data de referencia"
     SKIP
     tel_dscxcust AT 04 LABEL "Processar"
               HELP "Informe a opcao desejada (Caixa ou Desconto/Custodia)"
     WITH ROW 6 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_monprv_2.


FORM tel_cdcoope2 AT 05 LABEL "Cooperativa"
                        HELP  "Selecione a Cooperativa"
     tel_cdagenci AT 42 LABEL "PA"
                        HELP "Informe o numero do PA ou zero '0' para todos."
                        VALIDATE(CAN-FIND(crapage WHERE
                                          crapage.cdcooper = aux_cdcooper AND
                                          crapage.cdagenci = tel_cdagenci) OR
                                          tel_cdagenci = 0 ,
                                          "962 - PA nao cadastrado.")
     SKIP
     tel_dtrefere AT 12 LABEL "Data"
                        HELP "Informe a data de referencia"

     tel_dssitua2 AT 37 LABEL "Situacao"
                        HELP "Informe qual situacao consultar"
     SKIP
     tel_dscxcus2 AT 07 LABEL "Processar"
                HELP "Informe a opcao desejada (Caixa ou Desconto/Custodia)"
     WITH ROW 6 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_monprv_central_2.


FORM tel_datadlog AT 8 LABEL "Data Log"
                       HELP "Informe a data para visualizar LOG"
     tel_pesquisa AT 32 LABEL "Pesquisar"
                     HELP "Informe texto a pesquisar (espaco em branco, tudo)."
     WITH ROW 6 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_monprv_3.

FORM tel_cdagenci AT 4 LABEL "PA"
                       HELP "Informe o numero do PA"
                       VALIDATE(CAN-FIND(crapage WHERE
                                         crapage.cdcooper = glb_cdcooper AND
                                         crapage.cdagenci = tel_cdagenci) OR
                                         tel_cdagenci = 0 ,
                                         "962 - PA nao cadastrado.")
     tel_dtrefere AT 15 LABEL "Data"
                        HELP "Informe a data de referencia"
     tel_dscxcust AT 34 LABEL "Processar"
               HELP "Informe a opcao desejada (Caixa ou Desconto/Custodia)"
     WITH ROW 6 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_monprv_m.

FORM tel_cdcooper AT 4  LABEL "Cooperativa"
                        HELP "Selecione a Cooperativa"
     tel_cdagenci AT 42 LABEL "PA"
                        HELP "Informe o numero do PA"
                        VALIDATE(CAN-FIND(crapage WHERE
                                          crapage.cdcooper = aux_cdcooper AND
                                          crapage.cdagenci = tel_cdagenci) OR
                                          tel_cdagenci = 0 ,
                                          "962 - PA nao cadastrado.")
     SKIP
     tel_dtrefere AT 11 LABEL "Data"
                        HELP "Informe a data de referencia"
     tel_dscxcus2 AT 36 LABEL "Processar"
               HELP "Informe a opcao desejada (Caixa ou Desconto/Custodia)"
     WITH ROW 6 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_monprv_central_m.

FORM b_crapchd   HELP "Setas para navegar e <END>/<F4> para sair."
     WITH ROW 9 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_monprv_caixa.

FORM b_crapchd_2 HELP "Setas para navegar e <END>/<F4> para sair."
     WITH ROW 9 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_monprv_custdesc.

FORM b_previas HELP "Setas para navegar e <END>/<F4> para sair."
     WITH ROW 9 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_monprv_caixa_m.

FORM b_previas_2 HELP "Setas para navegar e <END>/<F4> para sair."
     WITH ROW 9 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_monprv_custdesc_m.

ON RETURN OF tel_dssituac 
   DO: 
        ASSIGN tel_dssituac = tel_dssituac:SCREEN-VALUE.

        CASE tel_dssituac:
             WHEN "Pendente"     THEN aux_cdsituac = "0,1".
             WHEN "Nao Enviado"  THEN aux_cdsituac = "0".
             WHEN "Gerado"       THEN aux_cdsituac = "1".
             WHEN "Processado"   THEN aux_cdsituac = "3".
        END CASE.

        APPLY "TAB".

   END.


ON RETURN OF tel_dssitua2 
   DO: 
        ASSIGN tel_dssitua2 = tel_dssitua2:SCREEN-VALUE.

        CASE tel_dssitua2:
             WHEN "Pendente"     THEN aux_cdsituac = "0,1".
             WHEN "Nao Enviado"  THEN aux_cdsituac = "0".
             WHEN "Gerado"       THEN aux_cdsituac = "1".
             WHEN "Processado"   THEN aux_cdsituac = "3".
        END CASE.

        APPLY "TAB".

   END.


ON RETURN OF tel_dscxcust IN FRAME f_monprv_2 
   DO:  
        ASSIGN tel_dscxcust = tel_dscxcust:SCREEN-VALUE.

        CASE tel_dscxcust:
             WHEN "Caixa"              THEN aux_cdcxcust = "1".
             WHEN "Custodia-Desconto"  THEN aux_cdcxcust = "2".
        END CASE.

        APPLY "GO".
   END.

ON RETURN OF tel_dscxcus2 IN FRAME f_monprv_central_2 
   DO:  
        ASSIGN tel_dscxcus2 = tel_dscxcus2:SCREEN-VALUE.

        CASE tel_dscxcus2:
             WHEN "Caixa"              THEN aux_cdcxcust = "1".
             WHEN "Custodia-Desconto"  THEN aux_cdcxcust = "2".
        END CASE.

        APPLY "GO".
   END.

ON RETURN OF tel_dscxcust IN FRAME f_monprv_2 
   DO:  
        ASSIGN tel_dscxcust = tel_dscxcust:SCREEN-VALUE.

        CASE tel_dscxcust:
             WHEN "Caixa"              THEN aux_cdcxcust = "1".
             WHEN "Custodia-Desconto"  THEN aux_cdcxcust = "2".
        END CASE.

        APPLY "GO".
   END.


ON RETURN OF tel_dscxcust IN FRAME f_monprv_m
   DO:  
        ASSIGN tel_dscxcust = tel_dscxcust:SCREEN-VALUE.

        CASE tel_dscxcust:
             WHEN "Caixa"              THEN aux_cdcxcust = "1".
             WHEN "Custodia-Desconto"  THEN aux_cdcxcust = "2".
        END CASE.

        APPLY "GO".
   END.

ON RETURN OF tel_dscxcus2 IN FRAME f_monprv_central_m
   DO:  
        ASSIGN tel_dscxcus2 = tel_dscxcus2:SCREEN-VALUE.

        CASE tel_dscxcus2:
             WHEN "Caixa"              THEN aux_cdcxcust = "1".
             WHEN "Custodia-Desconto"  THEN aux_cdcxcust = "2".
        END CASE.

        APPLY "GO".
   END.


ON RETURN, LEAVE OF tel_cdcooper DO:

   ASSIGN tel_cdcooper = tel_cdcooper:SCREEN-VALUE
          aux_cdcooper = INT(tel_cdcooper)
          aux_contador = 0.

   APPLY "TAB".

END.

ON RETURN, LEAVE OF tel_cdcoope2 DO:

   ASSIGN tel_cdcoope2 = tel_cdcoope2:SCREEN-VALUE
          aux_cdcooper = INT(tel_cdcoope2)
          aux_contador = 0.

   APPLY "TAB".

END.


/*............................................................................*/

/* Apenas para a coop logada */
FIND FIRST crapcop WHERE crapcop.cdcooper = glb_cdcooper 
                         NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN 
     DO:
         glb_cdcritic = 794.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         glb_cdcritic = 0.
         PAUSE 2 NO-MESSAGE.
         RETURN.
     END.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       tel_dtrefere = glb_dtmvtolt.

RUN fontes/inicia.p.

VIEW FRAME f_moldura.
PAUSE(0).


FOR EACH b-crapcop1 WHERE b-crapcop1.cdcooper <> 3 
                          NO-LOCK BY b-crapcop1.cdcooper:
    
    IF aux_contador = 0 THEN
       ASSIGN aux_nmcooper = CAPS(b-crapcop1.dsdircop) + "," + 
                             STRING(b-crapcop1.cdcooper)
              aux_contador = 1.
    ELSE
       ASSIGN aux_nmcooper = aux_nmcooper + "," + 
                             CAPS(b-crapcop1.dsdircop) + "," + 
                             STRING(b-crapcop1.cdcooper).

END.


ASSIGN tel_cdcooper:LIST-ITEM-PAIRS = aux_nmcooper
       tel_cdcoope2:LIST-ITEM-PAIRS = aux_nmcooper.


DO WHILE TRUE:

   HIDE b_crapchd   IN FRAME f_monprv_caixa.
   HIDE b_previas   IN FRAME f_monprv_caixa_m.
   HIDE b_previas_2 IN FRAME f_monprv_custdesc_m.
   

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN 
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               PAUSE 2 NO-MESSAGE.
           END.

      UPDATE glb_cddopcao WITH FRAME f_monprv_1.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN 
        DO:    /*   F4 OU FIM   */
             RUN fontes/novatela.p.
 
             IF   CAPS(glb_nmdatela) <> "MONPRV"  THEN 
                  DO:
                      RUN pi_oculta_frames.
                      HIDE MESSAGE NO-PAUSE.
                      RETURN.

                  END.
             ELSE
               NEXT.

        END.

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.

        END.

   
   CASE glb_cddopcao:
        WHEN "C" THEN RUN pi_opcao_c.
        WHEN "M" THEN RUN pi_opcao_m.

   END CASE.

END. /* FIM - DO WHILE TRUE */

/*............................................................................*/

PROCEDURE pi_opcao_c:

    RUN pi_oculta_frames.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        IF glb_cdcooper <> 3 THEN
           DO:
               VIEW FRAME f_monprv_2.

               UPDATE tel_dssituac 
                      tel_cdagenci 
                      tel_dtrefere 
                      tel_dscxcust 
                      WITH FRAME f_monprv_2. 

               aux_cdcooper = glb_cdcooper.

           END.
        ELSE
          DO:
              VIEW FRAME f_monprv_central_2. 

              UPDATE tel_cdcoope2
                     tel_cdagenci 
                     tel_dtrefere 
                     tel_dssitua2 
                     tel_dscxcus2 
                     WITH FRAME f_monprv_central_2. 

          END.

        MESSAGE "AGUARDE ...".

        IF   tel_dtrefere = ? THEN 
             DO:
                 MESSAGE "Você deve informar uma data de referência".
                 NEXT.

             END.

        aux_cdagefim = IF   tel_cdagenci = 0 THEN
                            9999
                       ELSE
                            tel_cdagenci.
        
        LEAVE.

    END. /* END do DO WHILE TRUE */

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN 
         DO:
             RUN pi_oculta_frames.
             NEXT.

         END.

    EMPTY TEMP-TABLE tt-cheques.

    IF   aux_cdcxcust = "1" THEN    /* Caixa */
         DO: 
             RUN pi_processa_chq (INPUT aux_cdcooper,
                                  INPUT tel_dtrefere,
                                  INPUT tel_cdagenci,
                                  INPUT aux_cdagefim).

             CLOSE QUERY q_crapchd.

             OPEN QUERY q_crapchd FOR EACH tt-cheques NO-LOCK
                                      BY tt-cheques.cdagenci
                                         BY tt-cheques.nrdcaixa
                                            BY tt-cheques.nmoperad
                                               BY tt-cheques.nrprevia.

             ENABLE b_crapchd WITH FRAME f_monprv_caixa.  
             
             HIDE MESSAGE NO-PAUSE.

         END.
    ELSE 
         IF   aux_cdcxcust = "2" THEN   /* Custodia-Desconto */
              DO: 
                   RUN pi_processa_cst (INPUT aux_cdcooper,
                                        INPUT tel_dtrefere,
                                        INPUT tel_cdagenci,
                                        INPUT aux_cdagefim).

                   RUN pi_processa_cdb (INPUT aux_cdcooper,
                                        INPUT tel_dtrefere,
                                        INPUT tel_cdagenci,
                                        INPUT aux_cdagefim).
           
                   CLOSE QUERY q_crapchd_2.
           
                   OPEN QUERY q_crapchd_2 FOR EACH tt-cheques NO-LOCK
                                                BY tt-cheques.cdagenci
                                                   BY tt-cheques.nrdcaixa
                                                      BY tt-cheques.nmoperad.

                   ENABLE b_crapchd_2 WITH FRAME f_monprv_custdesc.  
               
                   HIDE MESSAGE NO-PAUSE.
              END.

    WAIT-FOR END-ERROR OF DEFAULT-WINDOW.

    HIDE FRAME f_monprv_caixa
         FRAME f_monprv_custdesc.

    HIDE MESSAGE NO-PAUSE.

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_opcao_p:

    HIDE MESSAGE NO-PAUSE.

    RUN pi_oculta_frames.

    ASSIGN tel_pesquisa = "".

    VIEW FRAME f_monprv_3.

    ASSIGN tel_datadlog = glb_dtmvtolt.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
       UPDATE tel_datadlog 
              tel_pesquisa 
              WITH FRAME f_monprv_3.

       LEAVE.

    END.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN 
         DO:
             HIDE tel_datadlog tel_pesquisa IN FRAM f_monprv_3.
             NEXT.

         END.

    /* DEFINIR O NOME DO LOG */
    ASSIGN aux_nmarqimp = "log/monprv_" +
                          STRING(YEAR(tel_datadlog),"9999") +
                          STRING(MONTH(tel_datadlog),"99") +
                          STRING(DAY(tel_datadlog),"99") + ".log".

    IF   SEARCH(aux_nmarqimp) = ?   THEN 
         DO:
             MESSAGE "NAO HA REGISTRO DE LOG PARA ESTA DATA!".
             PAUSE 3 NO-MESSAGE.
             RETURN.

         END.


    ASSIGN aux_nomedarq[1] = "log/arquivo_tel1".
            
    IF   TRIM(tel_pesquisa) = ""   THEN 
         UNIX SILENT VALUE("cp " + aux_nmarqimp + " " + aux_nomedarq[1]).
    ELSE 
         UNIX SILENT VALUE ("grep -i '" + tel_pesquisa + "' " + aux_nmarqimp + 
                            " > "   + aux_nomedarq[1] + " 2> /dev/null").

    aux_nmarqimp = aux_nomedarq[1].
            
    /* Verifica se o arquivo esta vazio e critica */
    INPUT STREAM str_2 THROUGH VALUE("wc -m " + aux_nmarqimp + " 2> /dev/null") 
                                     NO-ECHO.

    SET STREAM str_2 aux_tamarqui FORMAT "x(30)".

    IF   INTEGER(SUBSTRING(aux_tamarqui,1,1)) = 0   THEN
         DO:
             BELL. 
             MESSAGE "Nenhuma ocorrencia encontrada.".
             INPUT STREAM str_2 CLOSE.
             NEXT.

         END.

    INPUT STREAM str_2 CLOSE.

    ASSIGN tel_cddopcao = "T".

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       MESSAGE "(T)erminal ou (I)mpressora: " UPDATE tel_cddopcao.
       LEAVE.

    END.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
         NEXT.

    IF   tel_cddopcao = "T"   THEN
         RUN fontes/visrel.p (INPUT aux_nmarqimp).
    ELSE
    IF   tel_cddopcao = "I"   THEN
         DO:
             /* somente para o includes/impressao.i */
             FIND FIRST crapass WHERE crapass.cdcooper = aux_cdcooper
                                      NO-LOCK NO-ERROR.

             { includes/impressao.i }

         END.
    ELSE
         DO:
            glb_cdcritic = 14.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.

         END.

    /* apaga arquivos temporarios */
    IF   aux_nomedarq[1] <> ""   THEN
         UNIX SILENT VALUE ("rm " + aux_nomedarq[1] + " 2> /dev/null").

END PROCEDURE.
/*............................................................................*/

PROCEDURE pi_opcao_e:

    HIDE MESSAGE NO-PAUSE.

    RUN pi_oculta_frames.

    MESSAGE "Esta opcao executara a Atualizacao Manual de Cheques." SKIP
            "Confirma operacao ?"
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
            UPDATE aux_confirma AS LOGICAL.
    
    IF   aux_confirma THEN 
         DO:
             RUN fontes/crps584.p.
             MESSAGE 
                 "Termino da execucao Atualizacao Manual de Cheques(CRPS583)".
             PAUSE 3 NO-MESSAGE.

         END.
    ELSE 
         DO:
             MESSAGE "Atualizacao nao efetuada!".
             PAUSE 3 NO-MESSAGE.
             RETURN.

         END.
        

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_opcao_m:

    ASSIGN aux_flexetru = FALSE.

    RUN pi_oculta_frames.
    

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        IF   glb_cdcooper <> 3 THEN
             DO: 
                 VIEW FRAME f_monprv_m.

                 UPDATE tel_cdagenci tel_dtrefere tel_dscxcust 
                        WITH FRAME f_monprv_m.
   
                 aux_cdcooper = glb_cdcooper.

             END.    
        ELSE
             DO:
                 VIEW FRAME f_monprv_central_m.

                 UPDATE tel_cdcooper tel_cdagenci tel_dtrefere tel_dscxcus2 
                        WITH FRAME f_monprv_central_m.
             END.


        MESSAGE "AGUARDE ...".

        IF   tel_dtrefere = ? THEN 
             DO:
                 MESSAGE "Você deve informar uma data de referência".
                 NEXT.
             END.                                              
        
        LEAVE.

    END. /* END do DO WHILE TRUE */

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN 
         DO:
             RUN pi_oculta_frames.
             NEXT.

         END.

    aux_cdagefim = IF   tel_cdagenci = 0 THEN
                        9999
                   ELSE
                        tel_cdagenci.

    EMPTY TEMP-TABLE tt-previas.

    ASSIGN aux_qtcaptur = 0.

    IF   aux_cdcxcust = "1" THEN    /*caixa*/
         DO: 
             RUN pi_opcao_m_cria_dados_caixa  (INPUT aux_cdcooper, 
                                               INPUT tel_dtrefere, 
                                               INPUT tel_cdagenci, 
                                               INPUT aux_cdagefim).


             CLOSE QUERY q_previas.                                       
                                                                          
             OPEN QUERY q_previas FOR EACH tt-previas NO-LOCK             
                                           BY tt-previas.cdagenci         
                                              BY tt-previas.nrdcaixa      
                                                 BY tt-previas.nmoperad.  
                                                                          
             ENABLE b_previas WITH FRAME f_monprv_caixa_m.  

             HIDE MESSAGE NO-PAUSE.
         END.
    ELSE 
         IF   aux_cdcxcust = "2" THEN  /* Custodia-Desconto */
              DO: 
                  RUN pi_opcao_m_cria_dados_descust (INPUT aux_cdcooper,
                                                     INPUT tel_dtrefere,
                                                     INPUT tel_cdagenci,
                                                     INPUT aux_cdagefim).

           
                  CLOSE QUERY q_previas_2.  
                                                                             
                  OPEN QUERY q_previas_2 FOR EACH tt-previas NO-LOCK
                                             BY tt-previas.cdagenci         
                                                BY tt-previas.nrdcaixa      
                                                   BY tt-previas.nmoperad.  
                                                                            
                  ENABLE b_previas_2 WITH FRAME f_monprv_custdesc_m.
                                                                            
                  HIDE MESSAGE NO-PAUSE.       
              END.

    WAIT-FOR END-ERROR OF DEFAULT-WINDOW.                        
                                                                          
    HIDE FRAME f_monprv_caixa_m
         FRAME f_monprv_custdesc_m.                                   
                                                                 
    HIDE MESSAGE NO-PAUSE.      


END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_processa_chq:

   DEF INPUT PARAM par_cdcooper AS INT                         NO-UNDO.
   DEF INPUT PARAM par_dtrefere AS DATE                        NO-UNDO.
   DEF INPUT PARAM par_cdagenci AS INT                         NO-UNDO.
   DEF INPUT PARAM par_cdagefim AS INT                         NO-UNDO.

   DEFINE VARIABLE aux_dssitabr  AS CHAR  INIT ""              NO-UNDO.
   DEFINE VARIABLE aux_vlprevia  AS DECI  INIT ""              NO-UNDO.
   
   /*Usado substring no break by para poder agrupar pelos 3 ultimos digitos
     do nrdolote, ou seja, pelo nrdcaixa.*/
   FOR EACH crapchd WHERE crapchd.cdcooper  = par_cdcooper              AND
                          crapchd.dtmvtolt  = par_dtrefere              AND
                          crapchd.cdagenci >= par_cdagenci              AND
                          crapchd.cdagenci <= par_cdagefim              AND
                          CAN-DO("11,500",STRING(crapchd.cdbccxlt))     AND 
                          CAN-DO(aux_cdsituac,STRING(crapchd.insitprv)) AND
                          CAN-DO("0,2",STRING(crapchd.insitchq))
                          NO-LOCK BREAK BY crapchd.cdagenci
                                         BY SUBSTR(STRING(crapchd.nrdolote),3,3)
                                          BY crapchd.nrprevia:

       
       IF   FIRST-OF(crapchd.cdagenci) THEN 
            DO:
                FIND craptab WHERE craptab.cdcooper = crapchd.cdcooper AND
                                   craptab.nmsistem = "CRED"           AND
                                   craptab.tptabela = "GENERI"         AND
                                   craptab.cdempres = 0                AND
                                   craptab.cdacesso = "EXETRUNCAGEM"   AND
                                   craptab.tpregist = crapchd.cdagenci
                                   NO-LOCK NO-ERROR.

                IF   AVAIL craptab THEN
                     IF   craptab.dstextab = "SIM" THEN
                          ASSIGN aux_flexetru = TRUE.
                     ELSE
                          ASSIGN aux_flexetru = FALSE.

            END. /* FIM do IF FIRST-OF cdagenci */
       
       IF   aux_flexetru THEN
            ASSIGN aux_qtprevia = aux_qtprevia + 1
                   aux_vlprevia = aux_vlprevia + crapchd.vlcheque.
       ELSE
            NEXT.

       IF   LAST-OF(crapchd.nrprevia) THEN
            DO:
                FIND FIRST crapope WHERE 
                           crapope.cdcooper = crapchd.cdcooper AND
                           crapope.cdoperad = crapchd.cdoperad 
                           NO-LOCK NO-ERROR.
            
                IF   AVAILABLE crapope THEN
                     ASSIGN aux_nmoperad = crapope.nmoperad.
                ELSE
                     ASSIGN aux_nmoperad = "NAO ENCONTRADO".

                CASE crapchd.insitprv:
                     WHEN 0 THEN aux_dssitabr = "Nao Enviado".
                     WHEN 1 THEN aux_dssitabr = "Gerado".
                     WHEN 3 THEN aux_dssitabr = "Processado".

                END CASE.
                
                ASSIGN  aux_nrdcaixa = INT(SUBSTR(STRING(crapchd.nrdolote),
                                           LENGTH(STRING(crapchd.nrdolote)) - 2,
                                           LENGTH(STRING(crapchd.nrdolote)))).
                              
                CREATE tt-cheques.

                ASSIGN tt-cheques.cdagenci = crapchd.cdagenci
                       tt-cheques.nrdcaixa = aux_nrdcaixa
                       tt-cheques.nmoperad = aux_nmoperad
                       tt-cheques.hrprevia = STRING(crapchd.hrprevia,"HH:MM")
                       tt-cheques.nrprevia = crapchd.nrprevia
                       tt-cheques.qtprevia = aux_qtprevia
                       tt-cheques.vlprevia = aux_vlprevia
                       tt-cheques.dssitabr = aux_dssitabr.

                ASSIGN aux_qtprevia = 0
                       aux_vlprevia = 0.

            END. /* END do IF last-OF nrdolote*/
   END.

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_processa_cst:

   DEF INPUT PARAM par_cdcooper AS INT                         NO-UNDO.
   DEF INPUT PARAM par_dtrefere AS DATE                        NO-UNDO.
   DEF INPUT PARAM par_cdagenci AS INT                         NO-UNDO.
   DEF INPUT PARAM par_cdagefim AS INT                         NO-UNDO.

   DEFINE VARIABLE aux_dssitabr  AS CHAR  INIT ""              NO-UNDO.
   DEFINE VARIABLE aux_vlprevia  AS DECI  INIT ""              NO-UNDO.


   FOR EACH crapcst WHERE crapcst.cdcooper =  par_cdcooper              AND
                          crapcst.dtmvtolt =  par_dtrefere              AND
                          crapcst.cdagenci >= par_cdagenci              AND
                          crapcst.cdagenci <= par_cdagefim              AND
                          CAN-DO(aux_cdsituac,STRING(crapcst.insitprv)) AND
                         (crapcst.insitchq  = 0                OR
                          crapcst.insitchq  = 2)
                          NO-LOCK BREAK BY crapcst.cdagenci
                                         BY crapcst.nrdolote:
        
        ASSIGN aux_qtprevia = aux_qtprevia + 1
               aux_vlprevia = aux_vlprevia + crapcst.vlcheque.

        IF   LAST-OF(crapcst.nrdolote) THEN
             DO:
                 ASSIGN aux_nmoperad = "CUSTODIA"
                        aux_nrdcaixa = crapcst.nrdolote.

                 CASE crapcst.insitprv:
                      WHEN 0 THEN aux_dssitabr = "Nao Enviado".
                      WHEN 1 THEN aux_dssitabr = "Gerado".
                      WHEN 3 THEN aux_dssitabr = "Processado".

                 END CASE.
              
                 CREATE tt-cheques.

                 ASSIGN tt-cheques.cdagenci = crapcst.cdagenci
                        tt-cheques.nrdcaixa = aux_nrdcaixa
                        tt-cheques.nmoperad = aux_nmoperad
                        tt-cheques.hrprevia = STRING(0,"HH:MM")
                        tt-cheques.nrprevia = 0
                        tt-cheques.qtprevia = aux_qtprevia
                        tt-cheques.vlprevia = aux_vlprevia
                        tt-cheques.dssitabr = aux_dssitabr.

                 ASSIGN aux_qtprevia = 0
                        aux_vlprevia = 0.

             END. /* END do IF last-OF nrdolote*/
    END.

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_processa_cdb:

   DEF INPUT PARAM par_cdcooper AS INT                         NO-UNDO.
   DEF INPUT PARAM par_dtrefere AS DATE                        NO-UNDO.
   DEF INPUT PARAM par_cdagenci AS INT                         NO-UNDO.
   DEF INPUT PARAM par_cdagefim AS INT                         NO-UNDO.

   DEFINE VARIABLE aux_dssitabr  AS CHAR  INIT ""              NO-UNDO.
   DEFINE VARIABLE aux_vlprevia  AS DECI  INIT ""              NO-UNDO.


   FOR EACH crapcdb WHERE crapcdb.cdcooper =  par_cdcooper              AND
                          crapcdb.dtlibbdc =  par_dtrefere              AND
                          crapcdb.cdagenci >= par_cdagenci              AND
                          crapcdb.cdagenci <= par_cdagefim              AND
                          CAN-DO(aux_cdsituac,STRING(crapcdb.insitprv)) AND
                         (crapcdb.insitchq =  0                OR
                          crapcdb.insitchq =  2)
                          NO-LOCK BREAK BY crapcdb.cdagenci
                                           BY crapcdb.nrdolote:
        
        ASSIGN aux_qtprevia = aux_qtprevia + 1
               aux_vlprevia = aux_vlprevia + crapcdb.vlcheque.

        IF   LAST-OF(crapcdb.nrdolote) THEN
             DO:
                 ASSIGN aux_nmoperad = "DESCONTO"
                        aux_nrdcaixa = crapcdb.nrdolote.

                 CASE crapcdb.insitprv:
                      WHEN 0 THEN aux_dssitabr = "Nao Enviado".
                      WHEN 1 THEN aux_dssitabr = "Gerado".
                      WHEN 3 THEN aux_dssitabr = "Processado".

                 END CASE.

                 CREATE tt-cheques.

                 ASSIGN tt-cheques.cdagenci = crapcdb.cdagenci
                        tt-cheques.nrdcaixa = aux_nrdcaixa
                        tt-cheques.nmoperad = aux_nmoperad
                        tt-cheques.hrprevia = STRING(0,"HH:MM")
                        tt-cheques.nrprevia = 0
                        tt-cheques.qtprevia = aux_qtprevia
                        tt-cheques.vlprevia = aux_vlprevia
                        tt-cheques.dssitabr = aux_dssitabr.

                 ASSIGN aux_qtprevia = 0
                        aux_vlprevia = 0.

             END. /* END do IF last-OF nrdolote*/
    END.

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_opcao_m_cria_dados_caixa:

   DEF INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
   DEF INPUT PARAM par_dtrefere AS DATE                           NO-UNDO.
   DEF INPUT PARAM par_cdagenci AS INT                            NO-UNDO.
   DEF INPUT PARAM par_cdagefim AS INT                            NO-UNDO.

   /*Usado substring no break by para poder agrupar pelos 3 ultimos digitos
     do nrdolote, ou seja, pelo nrdcaixa.*/
   FOR EACH crapchd WHERE crapchd.cdcooper  = par_cdcooper          AND
                          crapchd.dtmvtolt  = par_dtrefere          AND
                          crapchd.cdagenci >= par_cdagenci          AND
                          crapchd.cdagenci <= par_cdagefim          AND
                          CAN-DO("11,500",STRING(crapchd.cdbccxlt)) AND
                          CAN-DO("0,2",STRING(crapchd.insitchq))
                          NO-LOCK BREAK BY crapchd.cdagenci
                                         BY SUBSTR(STRING(crapchd.nrdolote),3,3)
                                          BY crapchd.nrprevia:
              
       IF   FIRST-OF(crapchd.cdagenci) THEN 
            DO:
                FIND craptab WHERE craptab.cdcooper = crapchd.cdcooper AND
                                   craptab.nmsistem = "CRED"           AND
                                   craptab.tptabela = "GENERI"         AND
                                   craptab.cdempres = 0                AND
                                   craptab.cdacesso = "EXETRUNCAGEM"   AND
                                   craptab.tpregist = crapchd.cdagenci
                                   NO-LOCK NO-ERROR.
         
                IF   AVAILABLE craptab THEN
                     IF   craptab.dstextab = "SIM" THEN
                          ASSIGN aux_flexetru = TRUE.
                     ELSE
                          ASSIGN aux_flexetru = FALSE.

            END. /* FIM do IF FIRST-OF cdagenci */
       
       
       IF   FIRST-OF(SUBSTR(STRING(crapchd.nrdolote),3,3)) THEN
            aux_nrdcaixa = INT(SUBSTR(STRING(crapchd.nrdolote),
                               LENGTH(STRING(crapchd.nrdolote)) - 2,
                               LENGTH(STRING(crapchd.nrdolote)))).

       IF   FIRST-OF(crapchd.nrprevia)  AND
            aux_flexetru                AND
            crapchd.nrprevia <> 0       THEN
            ASSIGN aux_qtprevia = aux_qtprevia + 1.


        /*** Acumula totais SITUACOES PREVIA ****/
        IF   aux_flexetru THEN 
             DO:
                 CASE crapchd.insitprv:
                      WHEN 0 THEN aux_qtsitprv[9] = aux_qtsitprv[9] + 1.
                      OTHERWISE   aux_qtsitprv[crapchd.insitprv] = 
                                      aux_qtsitprv[crapchd.insitprv] + 1.

                 END CASE.

                 aux_qtcaptur = aux_qtcaptur + 1.

             END.


        IF   aux_flexetru THEN 
             DO:
                 IF   LAST-OF(SUBSTR(STRING(crapchd.nrdolote),3,3)) THEN 
                      DO:
                          FIND FIRST crapope WHERE 
                                     crapope.cdcooper = crapchd.cdcooper AND
                                     crapope.cdoperad = crapchd.cdoperad 
                                     NO-LOCK NO-ERROR.
                
                          IF   AVAILABLE crapope THEN
                               ASSIGN aux_nmoperad = crapope.nmoperad.
                          ELSE
                               ASSIGN aux_nmoperad = "NAO ENCONTRADO".
   
                          CREATE tt-previas.

                          ASSIGN tt-previas.cdagenci = crapchd.cdagenci
                                 tt-previas.nrdcaixa = aux_nrdcaixa
                                 tt-previas.nmoperad = aux_nmoperad
                                 tt-previas.qtcaptur = aux_qtcaptur
                                 tt-previas.qtsit000 = aux_qtsitprv[9]
                                 tt-previas.qtsit001 = aux_qtsitprv[1]
                                 tt-previas.qtsit003 = aux_qtsitprv[3]
                                 tt-previas.qtprevia = aux_qtprevia.

                          ASSIGN aux_nrdcaixa = 0
                                 aux_nmoperad = ""
                                 aux_qtsitprv = 0
                                 aux_qtprevia = 0
                                 aux_qtcaptur = 0.

                      END.
             END.
   END.

END PROCEDURE. /*PROCEDURE pi_opcao_m_cria_dados_caixa:*/

PROCEDURE pi_opcao_m_cria_dados_descust:

    DEF INPUT PARAM par_cdcooper AS INT                           NO-UNDO.
    DEF INPUT PARAM par_dtrefere AS DATE                          NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INT                           NO-UNDO.
    DEF INPUT PARAM par_cdagefim AS INT                           NO-UNDO.

    ASSIGN aux_nrdcaixa = 0
           aux_nmoperad = ""
           aux_qtsitprv = 0
           aux_qtprevia = 0
           aux_qtcaptur = 0.

    FOR EACH crapcst WHERE crapcst.cdcooper  = par_cdcooper AND
                           crapcst.dtmvtolt  = par_dtrefere AND
                           crapcst.cdagenci >= par_cdagenci AND
                           crapcst.cdagenci <= par_cdagefim AND
                          (crapcst.insitchq  = 0            OR
                           crapcst.insitchq  = 2)
                           NO-LOCK USE-INDEX crapcst1
                           BREAK BY crapcst.cdagenci:

        CASE crapcst.insitprv:
             WHEN 0 THEN aux_qtsitprv[9] = aux_qtsitprv[9] + 1.
             OTHERWISE   aux_qtsitprv[crapcst.insitprv] = 
                                   aux_qtsitprv[crapcst.insitprv] + 1.

             END CASE.
        
        aux_qtcaptur = aux_qtcaptur + 1.

        IF   LAST-OF(crapcst.cdagenci) THEN 
             DO:
                 ASSIGN aux_nmoperad = "CUSTODIA".

                 CREATE tt-previas.

                 ASSIGN tt-previas.cdagenci = crapcst.cdagenci
                        tt-previas.nrdcaixa = aux_nrdcaixa
                        tt-previas.nmoperad = aux_nmoperad
                        tt-previas.qtcaptur = aux_qtcaptur
                        tt-previas.qtsit000 = aux_qtsitprv[9]
                        tt-previas.qtsit001 = aux_qtsitprv[1]
                        tt-previas.qtsit003 = aux_qtsitprv[3]
                        tt-previas.qtprevia = aux_qtprevia.

                 ASSIGN aux_nrdcaixa = 0
                        aux_nmoperad = ""
                        aux_qtsitprv = 0
                        aux_qtprevia = 0
                        aux_qtcaptur = 0.

             END.

    END.

    ASSIGN aux_nrdcaixa = 0
           aux_nmoperad = ""
           aux_qtsitprv = 0
           aux_qtprevia = 0
           aux_qtcaptur = 0.

             /**** PROCESSAMENTO CDB ****/
    FOR EACH crapcdb WHERE crapcdb.cdcooper  = par_cdcooper AND
                           crapcdb.dtlibbdc  = par_dtrefere AND
                           crapcdb.cdagenci >= par_cdagenci AND
                           crapcdb.cdagenci <= par_cdagefim AND
                          (crapcdb.insitchq  = 0            OR
                           crapcdb.insitchq  = 2)
                           NO-LOCK USE-INDEX crapcdb1
                           BREAK BY crapcdb.cdagenci:

        CASE crapcdb.insitprv:
             WHEN 0 THEN aux_qtsitprv[9] = aux_qtsitprv[9] + 1.
             OTHERWISE   aux_qtsitprv[crapcdb.insitprv] = 
                                      aux_qtsitprv[crapcdb.insitprv] + 1.

        END CASE.
        
        aux_qtcaptur = aux_qtcaptur + 1.

        IF   LAST-OF(crapcdb.cdagenci) THEN 
             DO:
                 ASSIGN aux_nmoperad = "DESCONTO".

                 CREATE tt-previas.

                 ASSIGN tt-previas.cdagenci = crapcdb.cdagenci
                        tt-previas.nrdcaixa = aux_nrdcaixa
                        tt-previas.nmoperad = aux_nmoperad
                        tt-previas.qtcaptur = aux_qtcaptur
                        tt-previas.qtsit000 = aux_qtsitprv[9]
                        tt-previas.qtsit001 = aux_qtsitprv[1]
                        tt-previas.qtsit003 = aux_qtsitprv[3]
                        tt-previas.qtprevia = aux_qtprevia.

                 ASSIGN aux_nrdcaixa = 0
                        aux_nmoperad = ""
                        aux_qtsitprv = 0
                        aux_qtprevia = 0
                        aux_qtcaptur = 0.

             END.

    END.

END PROCEDURE.

PROCEDURE pi_oculta_frames:

    HIDE FRAME f_monprv_2.
    HIDE FRAME f_monprv_central_2.
    HIDE FRAME f_monprv_3.
    HIDE FRAME f_monprv_m.
    HIDE FRAME f_monprv_central_m.
    HIDE FRAME f_monprv_caixa.
    HIDE FRAME f_monprv_caixa_m.
    HIDE FRAME f_monprv_custdesc.
    HIDE FRAME f_monprv_custdesc_m.
    HIDE MESSAGE NO-PAUSE.

END PROCEDURE.

/*............................................................................*/
