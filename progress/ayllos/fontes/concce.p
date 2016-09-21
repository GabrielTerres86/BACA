/* ............................................................................

   Programa: Fontes/concce.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme Boettcher (Supero)
   Data    : Outubro/2009                       Ultima alteracao: 26/11/2013
 
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Tela para visualizacao dos dados das tabelas Genericas
               sistema - GNCPTIT - GNCPDOC - GNCPCHQ - GNCPDEV.
   
   Atualizacoes: 23/12/2009 - Inclusao de filtros novos na tela de acordo com
                              os novos campos da tabela. Inclusao da opcao de
                              consulta da GNCPDEV (Guilherme/Supero)
                              
                 25/05/2010 - Alteracao no formato do cdoperad e descricao do
                              TD para titulos (Ze).
                              
                 16/04/2012 - Fonte substituido por conccep.p (Tiago)   
                 
                 10/09/2013 - Nova forma de chamar as agências, de PAC agora 
                              a escrita será PA (André Euzébio - Supero).          
                              
                 26/11/2013 - Alteradas colunas do form f_detalhe_doctos de
                              "CPF/CGC" para "CPF/CNPJ". (Reinert)
............................................................................ */

{ includes/var_online.i  }

DEF        VAR tel_cdagenci AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_dtinicio AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_dttermin AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR aux_dscritic AS CHAR                                  NO-UNDO.  
DEF        VAR aux_dscaptur AS CHAR                                  NO-UNDO.

DEF        VAR aux_opcaotel AS CHAR                                  NO-UNDO.
DEF        VAR tel_opcaotel AS CHAR    FORMAT "x(09)" VIEW-AS COMBO-BOX
   LIST-ITEMS
      "Cheques",
      "Titulos",
      "DOC",
      "Devolu"                                                       NO-UNDO.


DEF        VAR tel_flgconci AS CHAR    FORMAT "x(1)" INIT "T"        NO-UNDO.

DEF        VAR tel_idseqttl AS INT     FORMAT "9"  INIT 0            NO-UNDO.
DEF        VAR tel_nmprimtl AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR tel_cdoperad AS CHAR    FORMAT "x(10)"                NO-UNDO.
DEF        VAR aux_stimeout AS INT                                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_query    AS CHAR                                  NO-UNDO.

DEF        VAR nome_frame   AS CHAR                                  NO-UNDO.
DEF        VAR nome_query   AS CHAR                                  NO-UNDO.
DEF        VAR nome_browse  AS CHAR                                  NO-UNDO.
DEF        VAR aux_cdagenci LIKE tel_cdagenci                        NO-UNDO.
DEF        VAR aux_hrtransa AS CHAR                                  NO-UNDO.

DEFINE BUTTON btn_devolucoes LABEL "Voltar".

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT 3 LABEL "Opcao" AUTO-RETURN
               HELP "Informe a opcao desejada (C)."
               VALIDATE(CAN-DO("C",glb_cddopcao),"014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_opcao.


FORM tel_cdagenci  AT 08  LABEL "PA"
                          HELP "Entre com o número do PA para consulta."
     tel_dtinicio  AT 19  LABEL "Data Inicial"
                          HELP "Entre com a data inicial (DD/MM/AAAA)"
     tel_dttermin  AT 45  LABEL "Data Final"
                          HELP "Entre com a data final (DD/MM/AAAA)"
     SKIP
     tel_opcaotel  AT  1  LABEL "Genericos"
                          HELP "Tabelas a processar"
     tel_flgconci  AT 45  LABEL "Conciliado"
                          HELP "Registros Conciliados? (Sim/Nao/Todos)"
                 VALIDATE(CAN-DO("S,N,T",tel_flgconci), "Opcao Invalida")
     WITH ROW 6 COLUMN 13 SIDE-LABELS OVERLAY NO-BOX FRAME f_concce.

FORM SKIP(1)
     gncpchq.cdcmpchq  LABEL "COMPE"              AT 15 FORMAT "999" 
     gncpchq.nrddigv1  LABEL "DV1"                AT 17 FORMAT "9"     
     gncpchq.nrddigv2  LABEL "DV2"                AT 27 FORMAT "9"    
     gncpchq.nrddigv3  LABEL "DV3"                AT 37 FORMAT "9"     
     SKIP 
     gncpchq.cdtipdoc  LABEL "Tipo Documento"     AT 06 FORMAT "999"   
     SKIP 
     gncpchq.nrdconta  LABEL "Conta Depositado"   AT 04 FORMAT ">>>>,>>>,9"
     SKIP(1)
     aux_hrtransa      LABEL "Hora Geracao Arq"   AT 04
     gncpchq.nmarquiv  LABEL "Nome do Arquivo"    AT 05 FORMAT "x(25)" 
     SKIP
     gncpchq.cdoperad  LABEL "Operador"           AT 12 FORMAT "x(4)"
     SKIP
     gncpchq.flgconci  LABEL "Conciliado"         AT 10 FORMAT "Sim/Nao"     
     SKIP
     "Critica"                                    AT 25
     SKIP
     aux_dscritic      NO-LABEL                   AT 01 FORMAT "x(66)"
     SKIP(1)
     btn_devolucoes    AT 27
     WITH ROW 6 COLUMN 2 OVERLAY 1 DOWN WIDTH 68 CENTERED
          SIDE-LABELS TITLE " DETALHES DO CHEQUE "
          FRAME f_detalhe_cheque.

FORM SKIP(1)
     gncptit.cddmoeda  LABEL "Moeda"              AT 13 FORMAT "99"         
     SKIP
     gncptit.dscodbar  LABEL "Codigo de Barras"   AT 02 FORMAT "x(44)"      
     SKIP
     gncptit.nrdvcdbr  LABEL "DV"                 AT 16 FORMAT "9"
     gncptit.cdfatven  LABEL "Fator Vencimento"   AT 42 FORMAT ">>>9"       
     SKIP
     gncptit.tpdocmto  LABEL "Tipo Documento"     AT 04 FORMAT "99"       
     SKIP
     gncptit.cdmotdev  LABEL "Devolucao"          AT 09 FORMAT ">9"         
     gncptit.nrdolote  LABEL "Lote"               AT 54 FORMAT "9999999"
     SKIP
     gncptit.tpcaptur  LABEL "Tipo Captura"       AT 06 FORMAT "9"
     aux_dscaptur      NO-LABEL                   AT 22 FORMAT "x(45)"
     SKIP(1)
     aux_hrtransa      LABEL "Hora Geracao Arq"   AT 02
     gncptit.nmarquiv  LABEL "Nome do Arquivo"    AT 30 FORMAT "x(20)"     
     SKIP
     gncptit.cdoperad  LABEL "Operador"           AT 10 FORMAT "x(4)"
     SKIP
     gncptit.flgconci  LABEL "Conciliado"         AT 08 FORMAT "Sim/Nao"     
     SKIP
     "Critica"                                    AT 33
     SKIP
     aux_dscritic      NO-LABEL                   AT 02 FORMAT "x(66)"
     SKIP(1)
     btn_devolucoes    AT 33
     WITH ROW 5 COLUMN 2 OVERLAY 1 DOWN WIDTH 70 CENTERED
          SIDE-LABELS TITLE " DETALHES DO TITULO "
          FRAME f_detalhe_titulo.

FORM SKIP(1)
     gncpdoc.cdcmpchq  LABEL "Compe Destino"      AT 05 FORMAT "999"
     gncpdoc.cdagercb  LABEL "Agencia Dest"       AT 43 FORMAT "9999"
     gncpdoc.dvagenci  NO-LABEL                         FORMAT "9"
     SKIP
     gncpdoc.nmpesrcb  LABEL "Destinatario"       AT 06 FORMAT "x(40)"      
     SKIP
     gncpdoc.cpfcgrcb  LABEL "CPF/CNPJ Dest"      AT 05 FORMAT ">>>>>>>>>>>>>9"
     SKIP
     gncpdoc.nmpesemi  LABEL "Emitente"           AT 10 FORMAT "x(40)"      
     SKIP
     gncpdoc.cpfcgemi  LABEL "CPF/CNPJ Emit"      AT 05 FORMAT ">>>>>>>>>>>>>9"
     gncpdoc.nrdconta  LABEL "Conta/dv"           AT 47 FORMAT ">>>>,>>>,9" 
     SKIP
     gncpdoc.tpdoctrf  LABEL "Tipo"               AT 14 FORMAT "99"
     gncpdoc.cdmotdev  LABEL "Devolucao"          AT 46 FORMAT "99"
     SKIP(1)
     aux_hrtransa      LABEL "Hora Geracao Arq"   AT 02
     gncpdoc.nmarquiv  LABEL "Nome do Arquivo"    AT 03 FORMAT "x(20)" 
     gncpdoc.cdoperad  LABEL "Operador"           AT 47 FORMAT "x(4)"
     SKIP
     
     SKIP
     gncpdoc.flgconci  LABEL "Conciliado"         AT 08 FORMAT "Sim/Nao"
     SKIP
     "Critica"                                    AT 33
     SKIP
     aux_dscritic      NO-LABEL                   AT 02 FORMAT "x(66)"
     SKIP(1)
     btn_devolucoes    AT 32
     WITH ROW 5 COLUMN 2 OVERLAY 1 DOWN WIDTH 78 CENTERED
          SIDE-LABELS TITLE " DETALHES DO DOC "
          FRAME f_detalhe_doctos.

FORM SKIP(1)
     gncpdev.cdcmpchq  LABEL "Comp. Cheque"       AT 07 FORMAT "999"       
     SKIP
     gncpdev.cdbanchq  LABEL "Banco Cheque"       AT 07 FORMAT "999"
     gncpdev.cdagechq  LABEL "Agencia"            AT 31 FORMAT "9999"      
     SKIP
     gncpdev.nrddigv1  LABEL "DV1 Cheque"         AT 09 FORMAT "9"          
     SKIP
     gncpdev.nrddigv2  LABEL "DV2 Cheque"         AT 09 FORMAT "9"          
     SKIP
     gncpdev.nrddigv3  LABEL "DV3 Cheque"         AT 09 FORMAT "9"
     SKIP 
     gncpdev.cdtipdoc  LABEL "Tipo Documento"     AT 05 FORMAT "999"        
     SKIP
     gncpdev.cdperdev  LABEL "Periodo Devolucao"  AT 02  FORMAT "9"
     SKIP(1)
     gncpdev.nmarquiv  LABEL "Nome do Arquivo"    AT 04 FORMAT "x(25)" 
     SKIP
     gncpdev.cdoperad  LABEL "Operador"           AT 11 FORMAT "x(4)"
     gncpdev.cdcritic  LABEL "Critica"            AT 31 FORMAT ">>9"   
     SKIP
     gncpdev.flgconci  LABEL "Conciliado"         AT 09 FORMAT "Sim/Nao"
     SKIP(1)
     btn_devolucoes    AT 22
     WITH ROW 6 COLUMN 2 OVERLAY 1 DOWN WIDTH 55 CENTERED
          SIDE-LABELS TITLE " DETALHES DA DEVOLUCAO DE CHEQUES "
          FRAME f_detalhe_devolu.

DEF QUERY q_gncptit FOR gncptit FIELDS(dtmvtolt
                                       cdagenci
                                       cdbandst
                                       vltitulo
                                       vldpagto
                                       nrseqarq).

DEF QUERY q_gncpdoc FOR gncpdoc FIELDS(dtmvtolt
                                       cdagenci
                                       cdbccrcb
                                       nrcctrcb
                                       nrdocmto
                                       vldocmto
                                       nrseqarq).

DEF QUERY q_gncpchq FOR gncpchq FIELDS(dtmvtolt
                                       cdagenci
                                       cdbanchq
                                       cdagechq
                                       nrctachq
                                       nrcheque
                                       vlcheque
                                       nrseqarq).
   
DEF QUERY q_gncpdev FOR gncpdev FIELDS(dtmvtolt
                                       hrtransa
                                       cdagenci
                                       nrctachq
                                       nrcheque
                                       vlcheque
                                       cdalinea
                                       nrseqarq).

DEF BROWSE b_gncpchq QUERY q_gncpchq
    DISP gncpchq.dtmvtolt COLUMN-LABEL "Data"        FORMAT "99/99/99"
         gncpchq.cdagenci COLUMN-LABEL "PA"          FORMAT "zz9"
         gncpchq.cdbanchq COLUMN-LABEL "Bco.Chq"     FORMAT "999"
         gncpchq.cdagechq COLUMN-LABEL "Age.Chq"     FORMAT "9999"
         gncpchq.nrctachq COLUMN-LABEL "Conta Chq"   FORMAT ">>>>>,>>>,>99,9"
         gncpchq.nrcheque COLUMN-LABEL "Cheque"      FORMAT ">>>,>>9"
         gncpchq.vlcheque COLUMN-LABEL "Valor"       FORMAT ">>,>>>,>>9.99"
         gncpchq.nrseqarq COLUMN-LABEL "Seq.Arq"     FORMAT ">>>>>>9"
         WITH 8 DOWN WIDTH 78 SCROLLBAR-VERTICAL.

DEF BROWSE b_gncptit QUERY q_gncptit
    DISP gncptit.dtmvtolt COLUMN-LABEL "Data"        FORMAT "99/99/99" 
         gncptit.cdagenci COLUMN-LABEL "PA"          FORMAT "zz9"
         gncptit.cdbandst COLUMN-LABEL "Banco Dest." FORMAT "999"
         gncptit.vltitulo COLUMN-LABEL "Vl Titulo"   FORMAT ">>>,>>>,>>9.99"
         gncptit.vldpagto COLUMN-LABEL "Valor Pago"  FORMAT ">>>,>>>,>>9.99"
         gncptit.nrseqarq COLUMN-LABEL "Seq Arq"     FORMAT ">>>>>>>>9"
         WITH 8 DOWN WIDTH 69 SCROLLBAR-VERTICAL.

DEF BROWSE b_gncpdoc QUERY q_gncpdoc
    DISP gncpdoc.dtmvtolt COLUMN-LABEL "Data"        FORMAT "99/99/99"
         gncpdoc.cdagenci COLUMN-LABEL "PA"          FORMAT "zz9"
         gncpdoc.cdbccrcb COLUMN-LABEL "Banco Dest"  FORMAT "999"
         gncpdoc.nrcctrcb COLUMN-LABEL "Conta Dest"  FORMAT ">>>,>>>,>>>,>>9,9"
         gncpdoc.nrdocmto COLUMN-LABEL "Documento"   FORMAT ">>,>>>,>>9"
         gncpdoc.vldocmto COLUMN-LABEL "Valor"       FORMAT ">>>,>>>,>>9.99"
         gncpdoc.nrseqarq COLUMN-LABEL "Seq.Arq"     FORMAT ">>>>>>>9"
         WITH 8 DOWN WIDTH 78 SCROLLBAR-VERTICAL.

DEF BROWSE b_gncpdev QUERY q_gncpdev
    DISP gncpdev.dtmvtolt COLUMN-LABEL "Data"        FORMAT "99/99/99"
         STRING(gncpdev.hrtransa,"HH:MM:SS") COLUMN-LABEL "Hora"
         gncpdev.cdagenci COLUMN-LABEL "PA"          FORMAT "zz9"
         gncpdev.nrctachq COLUMN-LABEL "Conta"       FORMAT ">>,>>>,>>>,>>9,99"
         gncpdev.nrcheque COLUMN-LABEL "Cheque"      FORMAT ">>>,>>9"
         gncpdev.vlcheque COLUMN-LABEL "Valor"       FORMAT ">>>,>>>,>>9.99"
         gncpdev.cdalinea COLUMN-LABEL "Al"          FORMAT ">9"
         gncpdev.nrseqarq COLUMN-LABEL "Seq.Arq"     FORMAT ">>>>>>9"
         WITH 8 DOWN WIDTH 78 SCROLLBAR-VERTICAL.

DEF FRAME f_gncptit
          b_gncptit  
    HELP "Pressione <ENTER> p/ outras informacoes "
    WITH NO-BOX CENTERED OVERLAY ROW 9.

DEF FRAME f_gncpchq
          b_gncpchq  
    HELP "Pressione <ENTER> p/ outras informacoes "
    WITH NO-BOX CENTERED OVERLAY ROW 9.

DEF FRAME f_gncpdoc
          b_gncpdoc  
    HELP "Pressione <ENTER> p/ outras informacoes "
    WITH NO-BOX CENTERED OVERLAY ROW 9.

DEF FRAME f_gncpdev
          b_gncpdev  
    HELP "Pressione <ENTER> p/ outras informacoes "
    WITH NO-BOX CENTERED OVERLAY ROW 9.


ON RETURN OF tel_opcaotel DO:

   IF   SUBSTRING(tel_opcaotel:SCREEN-VALUE,1,7) = "Cheques" THEN
        aux_opcaotel = "C".
   ELSE
   IF   SUBSTRING(tel_opcaotel:SCREEN-VALUE,1,7) = "Titulos" THEN
        aux_opcaotel = "T".
   ELSE
   IF   SUBSTRING(tel_opcaotel:SCREEN-VALUE,1,3) = "DOC"     THEN
        aux_opcaotel = "D".
   ELSE
   IF   SUBSTRING(tel_opcaotel:SCREEN-VALUE,1,6) = "Devolu"  THEN
        aux_opcaotel = "V".

   APPLY "GO".
END.

ON ENTER OF b_gncpchq IN FRAME f_gncpchq DO:

    ASSIGN aux_hrtransa = "".
    FIND CURRENT gncpchq NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE gncpchq   THEN
         RETURN NO-APPLY.

    ASSIGN aux_hrtransa = STRING(gncpchq.hrtransa,"HH:MM:SS").
    
    IF  gncpchq.cdagenci = 0  THEN
        gncpchq.nrdconta:LABEL IN FRAME f_detalhe_cheque = "Cta. Depositante".
    ELSE
        gncpchq.nrdconta:LABEL IN FRAME f_detalhe_cheque = "Conta Depositado".
        
    FIND crapcri WHERE crapcri.cdcritic = gncpchq.cdcritic NO-LOCK NO-ERROR.

    IF  AVAIL crapcri  THEN
        aux_dscritic = crapcri.dscritic.
    ELSE
        aux_dscritic = "** SEM CRITICAS **".
    
    DISPLAY gncpchq.cdcmpchq
            gncpchq.nrddigv1
            gncpchq.nrddigv2
            gncpchq.nrddigv3 
            gncpchq.cdtipdoc 
            gncpchq.nrdconta
            aux_hrtransa
            gncpchq.nmarquiv
            gncpchq.cdoperad
            gncpchq.flgconci
            aux_dscritic 
           WITH FRAME f_detalhe_cheque.

       ENABLE btn_devolucoes WITH FRAME f_detalhe_cheque.
       APPLY "ENTRY" TO btn_devolucoes IN FRAME f_detalhe_cheque.

END.

ON ENTER OF b_gncptit IN FRAME f_gncptit DO:

    ASSIGN aux_hrtransa = "".
    FIND CURRENT gncptit NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE gncptit   THEN
         RETURN NO-APPLY.

    ASSIGN aux_hrtransa = STRING(gncptit.hrtransa,"HH:MM:SS").

    FIND crapcri WHERE crapcri.cdcritic = gncptit.cdcritic NO-LOCK NO-ERROR.

    IF  AVAIL crapcri  THEN
        aux_dscritic = crapcri.dscritic.
    ELSE
        aux_dscritic = "** SEM CRITICAS **".
    
    IF  gncptit.tpcaptur = 1  THEN
        ASSIGN aux_dscaptur = "Guiche de Caixa".
    ELSE
    IF  gncptit.tpcaptur = 2  THEN
        ASSIGN aux_dscaptur = "Terminal de Auto Atendimento".
    ELSE
    IF  gncptit.tpcaptur = 3  THEN
        ASSIGN aux_dscaptur = "Internet (Home/Office bankin)".
    ELSE
    IF  gncptit.tpcaptur = 5  THEN
        ASSIGN aux_dscaptur = "Correspondente".
    ELSE
    IF  gncptit.tpcaptur = 6  THEN
        ASSIGN aux_dscaptur = "Telefone".
    ELSE
    IF  gncptit.tpcaptur = 7  THEN
        ASSIGN aux_dscaptur = "Arquivo Eletronico (pagto atraves troca arq.)".
    ELSE
        ASSIGN aux_dscaptur = "** SEM DESCRICAO CAPTURA **".
    DISPLAY gncptit.cddmoeda
            gncptit.dscodbar
            gncptit.nrdvcdbr
            gncptit.cdfatven
            gncptit.tpdocmto
            gncptit.cdmotdev
            gncptit.nrdolote
            gncptit.tpcaptur
            aux_dscaptur
            aux_hrtransa
            gncptit.nmarquiv
            gncptit.cdoperad
            gncptit.flgconci
            aux_dscritic
           WITH FRAME f_detalhe_titulo.

       ENABLE btn_devolucoes WITH FRAME f_detalhe_titulo.
       APPLY "ENTRY" TO btn_devolucoes IN FRAME f_detalhe_titulo.

END.

ON ENTER OF b_gncpdoc IN FRAME f_gncpdoc DO:

    ASSIGN aux_hrtransa = "".
    FIND CURRENT gncpdoc NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE gncpdoc   THEN
         RETURN NO-APPLY.

    ASSIGN aux_hrtransa = STRING(gncpdoc.hrtransa,"HH:MM:SS").

    FIND crapcri WHERE crapcri.cdcritic = gncpdoc.cdcritic NO-LOCK NO-ERROR.

    IF  AVAIL crapcri  THEN
        aux_dscritic = crapcri.dscritic.
    ELSE
        aux_dscritic = "** SEM CRITICAS **".

    DISPLAY gncpdoc.cdcmpchq
            gncpdoc.cdagercb
            gncpdoc.dvagenci
            gncpdoc.nmpesrcb
            gncpdoc.cpfcgrcb
            gncpdoc.nmpesemi
            gncpdoc.cpfcgemi
            gncpdoc.nrdconta
            gncpdoc.tpdoctrf
            gncpdoc.cdmotdev
            aux_hrtransa
            gncpdoc.nmarquiv
            gncpdoc.cdoperad
            gncpdoc.flgpcctl
            gncpdoc.flgconci
            aux_dscritic
           WITH FRAME f_detalhe_doctos.

       ENABLE btn_devolucoes WITH FRAME f_detalhe_doctos.
       APPLY "ENTRY" TO btn_devolucoes IN FRAME f_detalhe_doctos.

END.

ON ENTER OF b_gncpdev IN FRAME f_gncpdev DO:

    FIND CURRENT gncpdev NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE gncpdev   THEN
         RETURN NO-APPLY.

    DISPLAY gncpdev.cdcmpchq
            gncpdev.cdbanchq
            gncpdev.cdagechq
            gncpdev.nrddigv1
            gncpdev.nrddigv2
            gncpdev.nrddigv3 
            gncpdev.cdtipdoc 
            gncpdev.cdperdev
            gncpdev.nmarquiv
            gncpdev.cdoperad
            gncpdev.cdcritic
            gncpdev.flgconci
           WITH FRAME f_detalhe_devolu.

       ENABLE btn_devolucoes WITH FRAME f_detalhe_devolu.
       APPLY "ENTRY" TO btn_devolucoes IN FRAME f_detalhe_devolu.

END.

ON CHOOSE OF btn_devolucoes IN FRAME f_detalhe_cheque
   DO:  
      HIDE FRAME f_detalhe_cheque.
   END.

ON "F4" OF btn_devolucoes IN FRAME f_detalhe_cheque
   DO:
       HIDE FRAME f_detalhe_cheque.
       APPLY "ENTRY" TO b_gncpchq IN FRAME f_gncpchq.
       RETURN NO-APPLY.
   END.

ON CHOOSE OF btn_devolucoes IN FRAME f_detalhe_titulo
   DO:  
      HIDE FRAME f_detalhe_titulo.
   END.

ON "F4" OF btn_devolucoes IN FRAME f_detalhe_titulo
   DO:
       HIDE FRAME f_detalhe_titulo.
       APPLY "ENTRY" TO b_gncptit IN FRAME f_gncptit.
       RETURN NO-APPLY.
   END.

ON CHOOSE OF btn_devolucoes IN FRAME f_detalhe_doctos
   DO:  
      HIDE FRAME f_detalhe_doctos.
   END.

ON "F4" OF btn_devolucoes IN FRAME f_detalhe_doctos
   DO:
       HIDE FRAME f_detalhe_doctos.
       APPLY "ENTRY" TO b_gncpdoc IN FRAME f_gncpdoc.
       RETURN NO-APPLY.
   END.

ON CHOOSE OF btn_devolucoes IN FRAME f_detalhe_devolu
   DO:  
      HIDE FRAME f_detalhe_devolu.
   END.

ON "F4" OF btn_devolucoes IN FRAME f_detalhe_devolu
   DO:
       HIDE FRAME f_detalhe_devolu.
       APPLY "ENTRY" TO b_gncpdev IN FRAME f_gncpdev.
       RETURN NO-APPLY.
   END.

VIEW FRAME f_moldura.

PAUSE(0).

ASSIGN glb_cdcritic = 0
       glb_cdprogra = "CONCCE"
       glb_cddopcao = "C".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   ASSIGN tel_dtinicio = glb_dtmvtolt
          tel_dttermin = glb_dtmvtolt.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               glb_cdcritic = 0.
           END.

      UPDATE glb_cddopcao  WITH FRAME f_opcao.
      
      LEAVE.
   END.
      
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "CONCCE"  THEN
                 DO:
                     HIDE FRAME f_concce.
                     HIDE FRAME f_opcao.
                     HIDE FRAME f_moldura.
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

   IF   glb_cddopcao = "C" THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
               UPDATE tel_cdagenci WITH FRAME f_concce.
      
               aux_cdagenci = IF   tel_cdagenci = 0 THEN 
                                   9999 
                              ELSE tel_cdagenci.

               IF   tel_cdagenci > 0   THEN
                    DO:
                        FIND FIRST crapage WHERE crapage.cdcooper = glb_cdcooper
                                             AND crapage.cdagenci = tel_cdagenci
                                             NO-LOCK NO-ERROR.

                        IF   NOT AVAILABLE crapage THEN
                             DO:
                                 glb_cdcritic = 16.
                                 RUN fontes/critic.p.
                                 BELL.
                                 MESSAGE glb_dscritic.
                                 NEXT.
                             END.
                    END. /* Fim do IF   tel_cdagenci > 0   THEN DO:*/


               UPDATE tel_dtinicio tel_dttermin WITH FRAME f_concce.
               UPDATE tel_opcaotel WITH FRAME f_concce.
               UPDATE tel_flgconci WITH FRAME f_concce.

               ASSIGN tel_flgconci = UPPER(tel_flgconci).
           
               DISPLAY tel_opcaotel WITH FRAME f_concce.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               
                  CASE STRING(aux_opcaotel):
                       /*Titulos*/
                       WHEN "T" THEN
                            DO:
                               RUN pi_monta_query (INPUT "gncptit").
                               QUERY q_gncptit:QUERY-CLOSE().
                               QUERY q_gncptit:QUERY-PREPARE(aux_query).
                 
                               MESSAGE "Aguarde...".
                               QUERY q_gncptit:QUERY-OPEN().

                               HIDE MESSAGE NO-PAUSE.

                               ENABLE b_gncptit WITH FRAME f_gncptit.

                               WAIT-FOR END-ERROR OF DEFAULT-WINDOW.

                               HIDE FRAME f_gncptit.
        
                               HIDE MESSAGE NO-PAUSE.
        
                               LEAVE.
                            END.
              
                       WHEN "C" THEN   /* Cheques */
                            DO:
                               RUN pi_monta_query (INPUT "gncpchq").
                               QUERY q_gncpchq:QUERY-CLOSE().
                               QUERY q_gncpchq:QUERY-PREPARE(aux_query).

                               MESSAGE "Aguarde...".
                               QUERY q_gncpchq:QUERY-OPEN().

                               HIDE MESSAGE NO-PAUSE.

                               ENABLE b_gncpchq WITH FRAME f_gncpchq.

                               WAIT-FOR END-ERROR OF DEFAULT-WINDOW.

                               HIDE FRAME f_gncpchq.
        
                               HIDE MESSAGE NO-PAUSE.
        
                               LEAVE.
                             END.

                        WHEN "D" THEN   /* DOC */
                             DO:
                                RUN pi_monta_query (INPUT "gncpdoc").
                                QUERY q_gncpdoc:QUERY-CLOSE().
                                QUERY q_gncpdoc:QUERY-PREPARE(aux_query).

                                MESSAGE "Aguarde...".
                                QUERY q_gncpdoc:QUERY-OPEN().

                                HIDE MESSAGE NO-PAUSE.

                                ENABLE b_gncpdoc WITH FRAME f_gncpdoc.

                                WAIT-FOR END-ERROR OF DEFAULT-WINDOW.

                                HIDE FRAME f_gncpdoc.
        
                                HIDE MESSAGE NO-PAUSE.
        
                                LEAVE.
                             END.

                        WHEN "V" THEN  /* Devolucao */
                             DO:
                                RUN pi_monta_query (INPUT "gncpdev").
                                QUERY q_gncpdev:QUERY-CLOSE().
                                QUERY q_gncpdev:QUERY-PREPARE(aux_query).

                                MESSAGE "Aguarde...".
                                QUERY q_gncpdev:QUERY-OPEN().

                                HIDE MESSAGE NO-PAUSE.

                                ENABLE b_gncpdev WITH FRAME f_gncpdev.

                                WAIT-FOR END-ERROR OF DEFAULT-WINDOW.

                                HIDE FRAME f_gncpdev.
        
                                HIDE MESSAGE NO-PAUSE.
        
                                LEAVE.
                             END.

                  END CASE.

               END.  /*  Fim do DO WHILE TRUE ON ENDKEY UNDO, LEAVE */

            END.  /*  Fim do DO WHILE TRUE  */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN /* F4 OU FIM */
                 DO:
                     HIDE FRAME f_concce.
                     LEAVE.
                 END.
                 
        END.  /* Fim do IF  aux_opcaotel = "C" */
END.
/* .......................................................................... */

PROCEDURE pi_monta_query:
    
    DEF INPUT PARAMETER p_aux_tabela AS CHAR NO-UNDO.
    
    DEFINE VARIABLE     cl_tipreg    AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE     cl_ordenar   AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE     cl_where     AS CHARACTER  NO-UNDO.

    CASE p_aux_tabela:
        WHEN "gncptit" THEN ASSIGN cl_ordenar = " BY gncptit.cdbandst ".
        WHEN "gncpdoc" THEN ASSIGN cl_ordenar = " BY gncpdoc.cdcmpchq " +
                                                " BY gncpdoc.cdbccrcb " +
                                                " BY gncpdoc.cdagercb " +
                                                " BY gncpdoc.dvagenci ".
        WHEN "gncpchq" THEN ASSIGN cl_ordenar = " BY gncpchq.cdagectl " +
                                                " BY gncpchq.cdbanchq " +
                                                " BY gncpchq.cdagechq " +
                                                " BY gncpchq.nrctachq " .
        WHEN "gncpdev" THEN ASSIGN cl_ordenar = " BY gncpdev.cdagectl " +
                                                " BY gncpdev.cdbanchq " +
                                                " BY gncpdev.cdagechq " +
                                                " BY gncpdev.nrctachq " .
    END CASE.

    CASE tel_flgconci:
        WHEN "S" THEN ASSIGN cl_where = " AND " + p_aux_tabela + ".flgconci = YES ".
        WHEN "N" THEN ASSIGN cl_where = " AND " + p_aux_tabela + ".flgconci = NO  ".
        WHEN "T" THEN ASSIGN cl_where = " ".
    END CASE.

    
    IF   p_aux_tabela = "gncpdev" THEN
         ASSIGN cl_tipreg = "     AND (" + p_aux_tabela + ".cdtipreg = 3 "   + 
                            "      OR  " + p_aux_tabela + ".cdtipreg = 4 ) ".
    ELSE
         ASSIGN cl_tipreg = "     AND (" + p_aux_tabela + ".cdtipreg = 1 "   + 
                            "      OR  " + p_aux_tabela + ".cdtipreg = 2 ) ".
    

    /* Montagem da QUERY dinamicamente para melhoria de performance */
    aux_query = 
        "FOR EACH " + p_aux_tabela + " " +
        "   WHERE " + p_aux_tabela + ".cdcooper  = " + STRING(glb_cdcooper) +
        "     AND " + p_aux_tabela + ".cdagenci >= " + STRING(tel_cdagenci) +
        "     AND " + p_aux_tabela + ".cdagenci <= " + STRING(aux_cdagenci) +
        "     AND " + p_aux_tabela + ".dtmvtolt >= " + STRING(tel_dtinicio) +
        "     AND " + p_aux_tabela + ".dtmvtolt <= " + STRING(tel_dttermin) +
        cl_tipreg +
        cl_where + 
        "  NO-LOCK BY " + p_aux_tabela + ".cdagenci " +
        "          BY " + p_aux_tabela + ".dtmvtolt DESC " +
        "          BY " + p_aux_tabela + ".hrtransa DESC " +
        cl_ordenar + " ".

END PROCEDURE.

