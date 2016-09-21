/* .............................................................................

   Programa: Fontes/crps608.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Henrique
   Data    : Agosto/2011                        Ultima atualizacao: 25/01/2016

   Dados referentes ao programa:
   
   Frequencia: Mensal.
   Objetivo  : Atende a solicitacao 087, ordem 29.
               Emitir informacoes de operacoes suspeitas de lavagem de 
               dinheiro.
               
   Alteracoes: 29/08/2011 - Incluida a listagem de Movimentacoes Atipicas 
                            (Henrique).
                            
               20/06/2012 - Melhorias no Relatorio - Incluir informacoes de
                            colaboradores do Sistema - Trf. 213709 (Ze).

               22/10/2012 - Tratamento para Movimentacoes Atipicas (Ze).
               
               18/02/2013 - Tratamento para mostrar cabecalho mesmo
                            quando nao houver registros (Tiago).
               
               28/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
                            
               25/01/2016 - Melhoria para alterar proc_batch pelo proc_message
                            na critica "Controle de movimentacao em especie sem 
                            conta informada". (Jaison/Diego - SD: 364999)

............................................................................. */

{ includes/var_batch.i "NEW" }

DEF STREAM str_1.

DEF  VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.
DEF  VAR rel_nmempres     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF  VAR rel_nrmodulo     AS INT     FORMAT "9"                NO-UNDO.
DEF  VAR rel_nmmodulo     AS CHAR    FORMAT "x(15)" EXTENT 5
                          INIT ["DEP. A VISTA   ","CAPITAL        ",
                                "EMPRESTIMOS    ","DIGITACAO      ",
                                "GENERICO       "]             NO-UNDO.
DEF  VAR rel_nmmesref AS CHAR    FORMAT "x(014)"               NO-UNDO.

DEF VAR aux_tpoperac AS CHAR    FORMAT "x(10)"                 NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR    FORMAT "x(25)"                 NO-UNDO.
DEF VAR aux_tpvincul AS CHAR                                   NO-UNDO.
DEF VAR aux_dsdjusti AS CHAR                                   NO-UNDO.
DEF VAR aux_vllanmto AS DECI                                   NO-UNDO.
DEF VAR aux_dtinimes AS DATE                                   NO-UNDO.
DEF VAR aux_dtfimmes AS DATE                                   NO-UNDO.
DEF VAR aux_flgcabec AS LOGI                                   NO-UNDO.

DEF VAR aux_impatipi AS LOG                                    NO-UNDO.
DEF VAR aux_impaticb AS LOG                                    NO-UNDO.
DEF VAR aux_imprmovi AS LOG                                    NO-UNDO.
DEF VAR aux_impmovcb AS LOG                                    NO-UNDO.

                    
DEF TEMP-TABLE crawcme                                         NO-UNDO
    FIELD tpvincul AS CHAR
    FIELD cdagenci LIKE crapcme.cdagenci
    FIELD dtmvtolt LIKE crapcme.dtmvtolt
    FIELD nrdconta LIKE crapcme.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD vllanmto LIKE crapcme.vllanmto
    FIELD tpoperac AS CHAR
    FIELD dsdjusti AS CHAR
    FIELD sisbacen LIKE crapcme.sisbacen.

DEF TEMP-TABLE crawcld                                         NO-UNDO
    FIELD tpvincul AS CHAR
    FIELD cdagenci LIKE crapcld.cdagenci
    FIELD dtmvtolt LIKE crapcld.dtmvtolt
    FIELD nrdconta LIKE crapcld.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD vltotcre LIKE crapcld.vltotcre
    FIELD vlrendim LIKE crapcld.vlrendim
    FIELD dsdjusti LIKE crapcld.dsdjusti
    FIELD dsobsctr LIKE crapcld.dsobsctr
    FIELD cdtipcld LIKE crapcld.cdtipcld
    FIELD infrepcf LIKE crapcld.infrepcf.

FORM "PA"
     "Data"            AT  05
     "Conta/DV"        AT  18
     "Titular"         AT  27
     "Valor"           AT  66
     "Operacao"        AT  72
     "Justificativa"   AT  83
     "COAF"            AT 127
     SKIP
     "--- ---------- ---------- ------------------------- ------------------"
     "---------- ------------------------------------------- ----"  AT 72
     WITH NO-BOX NO-LABEL WIDTH 132 FRAME f_tit_cme.

FORM crawcme.cdagenci 
     crawcme.dtmvtolt 
     crawcme.nrdconta 
     crawcme.nmprimtl FORMAT "x(25)"
     crawcme.vllanmto 
     crawcme.tpoperac FORMAT "x(10)"
     crawcme.dsdjusti FORMAT "x(43)"
     crawcme.sisbacen 
     WITH DOWN NO-BOX NO-LABEL WIDTH 132 FRAME f_crawcme.

FORM "PA"      
     "Data"     AT 05
     "Conta/DV" AT 18
     "Titular"  AT 27
     "Total Creditos"    AT 57
     "Renda"    AT 77
     SKIP
     "--- ---------- ---------- --------------"
     "----------- ------------------ -------------------" AT 41
     WITH NO-BOX NO-LABEL WIDTH 132 FRAME f_tit_cld.
     
FORM crawcld.cdagenci   
     crawcld.dtmvtolt 
     crawcld.nrdconta   
     crawcld.nmprimtl FORMAT "x(25)"    
     crawcld.vltotcre   
     crawcld.vlrendim 
     SKIP
     "Justificativa PA: "  AT 18
     crawcld.dsdjusti 
     SKIP
     "Justificativa Sede: " AT 17
     crawcld.dsobsctr 
     WITH DOWN NO-LABEL NO-BOX WIDTH 132 FRAME f_crawcld.

FORM SKIP(1)
     "Movimentacao em Especie"
     SKIP(1)
     WITH NO-BOX NO-LABEL WIDTH 132 FRAME f_movimentacao.
     
FORM SKIP(5)
     "Movimentacao em Especie dos Colaboradores do Sistema CECRED"
     SKIP(1)
     WITH NO-BOX NO-LABEL WIDTH 132 FRAME f_movimentacao_colab.
     
FORM SKIP(1)
     "Movimentacoes Atipicas"  
     SKIP(1)
     WITH NO-BOX NO-LABEL WIDTH 132 FRAME f_atipicas.
     
FORM SKIP(5)
     "Movimentacoes Atipicas dos Colaboradores do Sistema CECRED"  
     SKIP(1)
     WITH NO-BOX NO-LABEL WIDTH 132 FRAME f_atipicas_colab.
     

ASSIGN glb_cdprogra = "crps608".

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0 THEN
    QUIT.

OUTPUT STREAM str_1 TO VALUE ("rl/crrl608.lst") PAGED PAGE-SIZE 80.

ASSIGN aux_dtfimmes = glb_dtmvtolt
       aux_dtinimes = glb_dtmvtolt - DAY(glb_dtmvtolt) + 1.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "GENERI"      AND
                   craptab.cdempres = 0             AND
                   craptab.cdacesso = "VMINCTRCEN"  AND
                   craptab.tpregist = 0             NO-LOCK NO-ERROR.
                   
IF  AVAIL craptab THEN
    DO:
        ASSIGN aux_vllanmto = DEC(craptab.dstextab).
    END.   
ELSE
    DO:
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - "
                          + glb_cdprogra + "' --> '"             + 
                          "Valor nao cadastrado!! >> log/proc_batch.log").
        QUIT.                      
    END.

{ includes/cabrel132_1.i }

VIEW STREAM str_1 FRAME f_cabrel132_1.

FOR EACH crapcme WHERE crapcme.cdcooper =  glb_cdcooper   AND
                       crapcme.dtmvtolt >= aux_dtinimes   AND
                       crapcme.dtmvtolt <= aux_dtfimmes
                       BY crapcme.sisbacen DESC
                       BY crapcme.cdagenci
                       BY crapcme.nrdconta
                       BY crapcme.dtmvtolt:

    IF  crapcme.vllanmto >= aux_vllanmto THEN
        DO:
            IF  crapcme.nrdconta = 0 THEN
                DO:
                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - "
                                      + glb_cdprogra + "' --> '"             + 
                                      "Controle de movimentacao em especie " +
                                      "sem conta informada!!!! "             +
                                      STRING(ROWID(crapcme))                 +
                                      " >> log/proc_message.log").
                    NEXT.
                END.
            
            FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                               crapass.nrdconta = crapcme.nrdconta
                               NO-LOCK NO-ERROR.

            IF  AVAIL crapass THEN     
                DO:
                    IF  crapass.inpessoa = 3 THEN
                        NEXT.                
                    
                    ASSIGN aux_nmprimtl = crapass.nmprimtl
                           aux_tpvincul = crapass.tpvincul.
                END.

            IF  crapcme.sisbacen = FALSE                            AND
                NOT CAN-DO("CA,CF,CC,CO,FU,FC,FO,ET",aux_tpvincul)  THEN
                NEXT.

            IF   NOT crapcme.sisbacen THEN
                 ASSIGN aux_dsdjusti = crapcme.dsdjusti.
            ELSE
                 DO:
                     IF   crapcme.tpoperac = 1 THEN
                          ASSIGN aux_dsdjusti = crapcme.recursos.
                     ELSE
                     IF   crapcme.tpoperac = 2 THEN
                          ASSIGN aux_dsdjusti = crapcme.dstrecur.
                 END.
            
            ASSIGN aux_tpoperac = IF crapcme.tpoperac = 1 THEN
                                     "Deposito"
                                  ELSE
                                     "Saque".
                
            CREATE crawcme.
            ASSIGN crawcme.cdagenci = crapcme.cdagenci
                   crawcme.dtmvtolt = crapcme.dtmvtolt
                   crawcme.nrdconta = crapcme.nrdconta
                   crawcme.nmprimtl = aux_nmprimtl
                   crawcme.vllanmto = crapcme.vllanmto
                   crawcme.tpoperac = aux_tpoperac
                   crawcme.dsdjusti = aux_dsdjusti
                   crawcme.sisbacen = crapcme.sisbacen
                   crawcme.tpvincul = 
                    IF   CAN-DO("CA,CF,CC,CO,FU,FC,FO,ET",aux_tpvincul) THEN
                         aux_tpvincul
                    ELSE
                         "".
            
            ASSIGN aux_tpoperac = ""
                   aux_nmprimtl = ""
                   aux_tpvincul = ""
                   aux_dsdjusti = "".
                  
        END. /* FIM IF vllanmto */

END. /* FIM FOR EACH crapcme */                       


FOR EACH crapcld WHERE crapcld.cdcooper =  glb_cdcooper   AND
                       crapcld.dtmvtolt >= aux_dtinimes   AND
                       crapcld.dtmvtolt <= aux_dtfimmes   AND
                       crapcld.infrepcf = 0 NO-LOCK
                       BY crapcld.cdagenci
                       BY crapcld.nrdconta
                       BY crapcld.dtmvtolt:
                       
    FIND crapass WHERE crapass.cdcooper = glb_cdcooper      AND
                       crapass.nrdconta = crapcld.nrdconta  NO-LOCK
                       NO-ERROR.
                       
    IF  AVAIL crapass THEN
        DO:
            ASSIGN aux_nmprimtl = crapass.nmprimtl
                   aux_tpvincul = crapass.tpvincul.
        END.

    CREATE crawcld.
    ASSIGN crawcld.cdagenci = crapcld.cdagenci
           crawcld.dtmvtolt = crapcld.dtmvtolt
           crawcld.nrdconta = crapcld.nrdconta
           crawcld.nmprimtl = aux_nmprimtl
           crawcld.vltotcre = crapcld.vltotcre
           crawcld.vlrendim = crapcld.vlrendim
           crawcld.dsdjusti = crapcld.dsdjusti
           crawcld.dsobsctr = crapcld.dsobsctr
           crawcld.cdtipcld = crapcld.cdtipcld
           crawcld.infrepcf = crapcld.infrepcf
           crawcld.tpvincul =
               IF   CAN-DO("CA,CF,CC,CO,FU,FC,FO,ET",aux_tpvincul) THEN
                         aux_tpvincul
                    ELSE
                         "".

    ASSIGN aux_nmprimtl = ""
           aux_tpvincul = "".
                       
END. /* FIM FOR EACH crapcld */
 

ASSIGN aux_flgcabec = TRUE
       aux_imprmovi = TRUE
       aux_impmovcb = TRUE.
                           
FOR EACH crawcme NO-LOCK BREAK BY crawcme.tpvincul:


    IF   FIRST-OF(crawcme.tpvincul) THEN
         DO:
             IF   crawcme.tpvincul = "" THEN 
                  DO:
                      VIEW STREAM str_1 FRAME f_movimentacao.
                      VIEW STREAM str_1 FRAME f_tit_cme.

                      ASSIGN aux_imprmovi = FALSE.
                  END.
             ELSE
                  DO:
                      IF   aux_flgcabec THEN
                           DO:
                               VIEW STREAM str_1 FRAME f_movimentacao_colab.
                               VIEW STREAM str_1 FRAME f_tit_cme.
            
                               ASSIGN aux_flgcabec = FALSE
                                      aux_impmovcb = FALSE.
                               
                           END.    
                  END.     
         END.
          
    DISPLAY STREAM str_1 crawcme.cdagenci    crawcme.dtmvtolt    
                         crawcme.nrdconta    crawcme.nmprimtl       
                         crawcme.vllanmto    crawcme.tpoperac     
                         crawcme.dsdjusti    crawcme.sisbacen 
                         WITH FRAME f_crawcme.
                 
    DOWN STREAM str_1 WITH FRAME f_crawcme.     

END.

IF  aux_imprmovi = TRUE THEN
    DO:
        VIEW STREAM str_1 FRAME f_movimentacao.
        VIEW STREAM str_1 FRAME f_tit_cme.
    END.

IF  aux_impmovcb = TRUE THEN
    DO:
        VIEW STREAM str_1 FRAME f_movimentacao_colab.
        VIEW STREAM str_1 FRAME f_tit_cme.
    END.

PAGE STREAM str_1.

ASSIGN aux_flgcabec = TRUE
       aux_impatipi = TRUE
       aux_impaticb = TRUE.

FOR EACH crawcld NO-LOCK BREAK BY crawcld.tpvincul:

    IF   FIRST-OF(crawcld.tpvincul) THEN
         DO:
             IF   crawcld.tpvincul = "" THEN 
                  DO:
                      VIEW STREAM str_1 FRAME f_atipicas.
                      VIEW STREAM str_1 FRAME f_tit_cld.

                      ASSIGN aux_impatipi = FALSE.
                  END.
             ELSE
                  DO:
                      IF   aux_flgcabec THEN
                           DO:
                               VIEW STREAM str_1 FRAME f_atipicas_colab.
                               VIEW STREAM str_1 FRAME f_tit_cld.
            
                               ASSIGN aux_flgcabec = FALSE
                                      aux_impaticb = FALSE.
                           END.    
                  END.     
         END.
 
    IF   aux_flgcabec     = FALSE  OR
        (aux_flgcabec     = TRUE   AND
         crawcld.cdtipcld = 1      AND
         crawcld.infrepcf = 1)     THEN
         DO:
             DISPLAY STREAM str_1 crawcld.cdagenci   crawcld.dtmvtolt    
                                  crawcld.nrdconta   crawcld.nmprimtl       
                                  crawcld.vltotcre   crawcld.vlrendim
                                  crawcld.dsdjusti   crawcld.dsobsctr    
                                  WITH FRAME f_crawcld.
         
             DOWN STREAM str_1 WITH FRAME f_crawcld.
         END.
END.

IF  aux_impatipi = TRUE THEN
    DO:
        VIEW STREAM str_1 FRAME f_atipicas.
        VIEW STREAM str_1 FRAME f_tit_cld.
    END.

IF  aux_impaticb = TRUE THEN
    DO:
        VIEW STREAM str_1 FRAME f_atipicas_colab.
        VIEW STREAM str_1 FRAME f_tit_cld.
    END.

OUTPUT STREAM str_1 CLOSE.

ASSIGN glb_nrcopias = 1
       glb_nmformul = "132col"
       glb_nmarqimp = "rl/crrl608.lst".

RUN fontes/imprim.p.

RUN fontes/fimprg.p.

/* .......................................................................... */
