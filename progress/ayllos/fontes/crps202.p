/* ..........................................................................

   Programa: Fontes/crps202.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Maio/97                          Ultima atualizacao: 09/09/2013

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 039.
               Listar estatistica de talonarios de cheques.
               Emite relatorio 159.

   Alteracoes: 03/20/2000 - Gerar pedido de impressao (deborah).

               06/09/2004 - Gerar 3 copias para a VIACREDI (Edson).

               06/09/2005 - Acrescentados codigo PAC e codigo EMPRESA (Diego).
               
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               07/02/2008 - Cancelada uma via somente para a Viacredi
                            (Gabriel).
                            
               17/05/2010 - Tratar crapger.cdempres com 9999 em vez de 999
                            (Diego).
                                           
               27/09/2010 - Inserida a coluna de quantidade de cheques 
                            solicitados e retirados pela CECRED. Alterado
                            formulario para 132col. (Henrique)
               
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
               
               06/03/2018 - Retirados os valores referentes a cheques BB e Bancoob 
                            e a coluna total do relatório. PRJ366 (Lombardi).
............................................................................. */

DEF STREAM str_1.

{ includes/var_batch.i "NEW" }

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                     NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]               NO-UNDO.

DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                 NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5        NO-UNDO.
DEF        VAR rel_nmempres AS CHAR                                   NO-UNDO.


DEF        VAR aux_primvez  AS LOG     INITIAL yes.                        
DEF        VAR aux_mesrefer AS CHAR    FORMAT "x(20)"                 NO-UNDO.
DEF        VAR aux_dtrefere AS DATE                                   NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                   NO-UNDO.
DEF        VAR aux_dsagenci AS CHAR    FORMAT "x(20)"                 NO-UNDO.
DEF        VAR aux_dsempres AS CHAR    FORMAT "x(20)"                 NO-UNDO.

DEF        VAR aux_nmmesano AS CHAR    EXTENT 12 INIT
                                       ["JANEIRO","FEVEREIRO",
                                        "MARCO","ABRIL",
                                        "MAIO","JUNHO",
                                        "JULHO","AGOSTO",
                                        "SETEMBRO","OUTUBRO",
                                        "NOVEMBRO","DEZEMBRO"]        NO-UNDO.

FORM  aux_mesrefer AT 20 LABEL "REFERENCIA"
      SKIP(2)
      WITH SIDE-LABELS NO-BOX WIDTH 132 FRAME f_mes.

FORM  SPACE(21) "QTD. TALOES"
      SPACE(4)  "QTD. TALOES"
      SKIP
      WITH NO-LABELS NO-BOX COLUMN 5 WIDTH 132 FRAME f_cab_ambos.

FORM  aux_dsagenci     LABEL "PA"
      crapger.qtsltlct LABEL "SOLICITADOS"
      SPACE(4)
      crapger.qtrttlct LABEL " ENTREGUES"
      SKIP(1)
      WITH NO-LABELS NO-BOX DOWN COLUMN 5 WIDTH 132 FRAME f_pacs.

FORM  aux_dsempres     LABEL "EMPRESA"
      crapger.qtsltlct LABEL "SOLICITADOS"
      SPACE(4)
      crapger.qtrttlct LABEL " ENTREGUES"
      SKIP(1)
      WITH NO-LABELS NO-BOX DOWN COLUMN 5 WIDTH 132 FRAME f_emp.

glb_cdprogra = "crps202".

RUN fontes/iniprg.p.

{ includes/cabrel132_1.i }

IF   glb_cdcritic > 0 THEN
     QUIT.

ASSIGN aux_nmarqimp = "rl/crrl159.lst"

       aux_dtrefere = glb_dtmvtolt - DAY(glb_dtmvtolt)
       aux_mesrefer = aux_nmmesano[MONTH(aux_dtrefere)] + "/" +
                      SUBSTR(STRING(aux_dtrefere,"99/99/9999"),7,4) + ".".
       

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel132_1.

DISPLAY STREAM str_1 aux_mesrefer WITH FRAME f_mes.
DISPLAY STREAM str_1 WITH FRAME f_cab_ambos.

FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper      NO-LOCK, 
    EACH crapger WHERE crapger.cdcooper = glb_cdcooper      AND
                       crapger.dtrefere = aux_dtrefere      AND
                       crapger.cdagenci = crapage.cdagenci  AND
                       crapger.cdempres = 0                 NO-LOCK:

    ASSIGN aux_dsagenci = STRING(crapage.cdagenci) + "-" + crapage.nmresage.

    IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN
        DO:
            PAGE STREAM str_1.

            DISPLAY STREAM str_1 aux_mesrefer WITH FRAME f_mes.
            DISPLAY STREAM str_1 WITH FRAME f_cab_ambos. 

        END.
       
    DISPLAY STREAM str_1
            aux_dsagenci 
            crapger.qtsltlct 
            crapger.qtrttlct
            WITH FRAME f_pacs.

    DOWN STREAM str_1 WITH FRAME f_pacs.
END.

FOR EACH crapger WHERE crapger.cdcooper = glb_cdcooper  AND
                       crapger.dtrefere = aux_dtrefere  AND
                       crapger.cdagenci = 0             AND
                       crapger.cdempres = 0             NO-LOCK :
           
    DISPLAY STREAM str_1
            "RESUMO GERAL"  @ aux_dsagenci
            crapger.qtsltlct   
            crapger.qtrttlct
            WITH FRAME f_pacs.

    DOWN STREAM str_1 WITH FRAME f_pacs.

END.

DISPLAY STREAM str_1 SKIP(2).

FOR EACH crapemp WHERE crapemp.cdcooper = glb_cdcooper      NO-LOCK, 
    EACH crapger WHERE crapger.cdcooper = glb_cdcooper      AND
                       crapger.dtrefere = aux_dtrefere      AND
                       crapger.cdagenci = 0                 AND
                       crapger.cdempres = crapemp.cdempres  NO-LOCK:

    ASSIGN aux_dsempres = STRING(crapemp.cdempres) + "-" + crapemp.nmresemp.

    IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN
        DO:
            PAGE STREAM str_1.

            DISPLAY STREAM str_1 aux_mesrefer WITH FRAME f_mes.
            DISPLAY STREAM str_1 WITH FRAME f_cab_ambos.
            ASSIGN aux_primvez = no.
        
        END.

    IF   aux_primvez THEN
         DISPLAY STREAM str_1  WITH FRAME f_cab_ambos.
           
    ASSIGN aux_primvez = no.

    DISPLAY STREAM str_1
            aux_dsempres 
            crapger.qtsltlct  
            crapger.qtrttlct
            WITH FRAME f_emp.

    DOWN STREAM str_1 WITH FRAME f_emp.
END.

FOR EACH crapger WHERE crapger.cdcooper = glb_cdcooper  AND
                       crapger.dtrefere = aux_dtrefere  AND
                       crapger.cdagenci = 0             AND
                       crapger.cdempres = 9999           NO-LOCK :
     
    DISPLAY STREAM str_1
            "RESUMO GERAL"  @ aux_dsempres
            crapger.qtsltlct  
            crapger.qtrttlct
            WITH FRAME f_emp.

END.

OUTPUT STREAM str_1 CLOSE.

ASSIGN glb_nmformul = "132col"
       glb_nmarqimp = aux_nmarqimp
       glb_nrcopias = IF glb_cdcooper = 1 
                         THEN 2
                         ELSE 1.
      
RUN fontes/imprim.p.
         
RUN fontes/fimprg.p.

/* .......................................................................... */

