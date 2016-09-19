/* ............................................................................

   Programa: Fontes/crps374.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo.
   Data    : Marco/2004.                        Ultima atualizacao: 20/01/2015

   Dados referentes ao programa:

   Frequencia : Diario.
   Objetivo   : Atende a solicitacao 094.
                Listar os debitos de emprestimos e cotas.
                Emite relatorio 324.
               
   Alteracoes:  12/06/2004 - Acertos no relatorio. (Ze Eduardo).

                12/12/2005 - Nao listar emprestimos consignados "tpdescto = 2"
                             (Julio)
                             
                17/02/2006 - Unificacao dos bancos - SQLWorks - Eder
                
                31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

                09/06/2014 - Adicionado condicao inliquid = 0 para pesquisa dos
                             contratos de emprestimo (Douglas - Chamado 157511)
                             
                20/01/2015 - Alterado o formato do campo nrctremp para 8 
                             caracters (Kelvin - 233714)                             
............................................................................. */

DEF STREAM str_1.

{ includes/var_batch.i {1} }

{ includes/var_cpmf.i } 

DEF TEMP-TABLE crawrel                                               NO-UNDO
    FIELD cdindica AS INTEGER       /*    1 - epr   2 - pla   */
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD cdempres LIKE crapttl.cdempres
    FIELD nrctremp AS INTEGER
    FIELD dtdpagto AS DATE
    FIELD vlpresta AS DECIMAL
    INDEX crawrel1 AS PRIMARY
          cdindica cdempres nrdconta.
 
DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]      NO-UNDO.
DEF        VAR tot_nrmatric AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_nmoperad AS CHAR    FORMAT "x(12)"                NO-UNDO.
DEF        VAR aux_vldecpmf AS DECIMAL                               NO-UNDO.

DEF        VAR rel_dsempres AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR rel_nrcadast AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR rel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR rel_nrctremp AS INT     FORMAT "zz,zzz,zz9"           NO-UNDO.
DEF        VAR rel_vlpreemp AS DEC     FORMAT "zzzzzzz,zz9.99"       NO-UNDO.
DEF        VAR rel_vldecpmf AS DEC     FORMAT "z,zzz,zz9.99"         NO-UNDO.
DEF        VAR rel_nmprimtl AS CHAR    FORMAT "x(37)"                NO-UNDO.
DEF        VAR rel_dsprodut AS CHAR    FORMAT "x(13)"                NO-UNDO.

DEF        VAR tot_vlpreemp AS DECIMAL                               NO-UNDO.
DEF        VAR tot_vldecpmf AS DECIMAL                               NO-UNDO.

ASSIGN glb_cdprogra = "crps374"
       glb_nmarqimp = "rl/crrl324.lst".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.

FORM rel_dsempres AT  1 FORMAT "x(20)" LABEL "EMPRESA"
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS WIDTH 132 FRAME f_empresa.

FORM rel_nrcadast AT  1  FORMAT "zzzz,zzz,9"         LABEL "CADASTRO/DV"
     rel_nrdconta AT 15  FORMAT "zzzz,zzz,9"         LABEL "CONTA/DV"
     rel_nmprimtl AT 28  FORMAT "x(40)"              LABEL "NOME"
     rel_dsprodut AT 71  FORMAT "x(13)"              LABEL "PRODUTO"
     rel_nrctremp AT 86  FORMAT "zz,zzz,zz9"         LABEL "CONTRATO"
     rel_vlpreemp AT 100 FORMAT "zzzzzzz,zz9.99"     LABEL "PRESTACAO"
     rel_vldecpmf AT 121 FORMAT "z,zzz,zz9.99"       LABEL "PREST + CPMF"
     WITH NO-BOX NO-ATTR-SPACE DOWN WIDTH 132 FRAME f_emprestimos.

FORM SKIP(1)
     "TOTAIS ==>" AT  1
     tot_vlpreemp AT 96  FORMAT "zzz,zzz,zzz,zz9.99"
     tot_vldecpmf AT 115 FORMAT "zzz,zzz,zzz,zz9.99"
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_totais.

{ includes/cpmf.i }

FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper  AND
                       crapsol.nrsolici = 98            AND
                       crapsol.dtrefere = glb_dtmvtolt  AND
                       crapsol.insitsol = 1:
                                              
    /*  Contratos de Emprestimos  */

    FOR EACH crapepr WHERE 
             crapepr.cdcooper = glb_cdcooper    AND
             crapepr.flgpagto = FALSE           AND
             crapepr.qtpreemp > 1               AND /* exceto papagaio */
             crapepr.tpdescto = 1               AND
             crapepr.inliquid = 0               NO-LOCK:
             
        CREATE crawrel.
        ASSIGN crawrel.cdindica = 1
               crawrel.nrdconta = crapepr.nrdconta 
               crawrel.cdempres = crapepr.cdempres
               crawrel.nrctremp = crapepr.nrctremp
               crawrel.dtdpagto = crapepr.dtdpagto
               crawrel.vlpresta = crapepr.vlpreemp.
             
    END.   /*    Fim do For Each crapepr   */

    /*  Contratos de Planos de Capital  */

    FOR EACH crappla WHERE crappla.cdcooper = glb_cdcooper  AND
                           crappla.flgpagto = FALSE         NO-LOCK:
                       
        CREATE crawrel.
        ASSIGN crawrel.cdindica = 2
               crawrel.nrdconta = crappla.nrdconta 
               crawrel.cdempres = crappla.cdempres
               crawrel.nrctremp = crappla.nrctrpla
               crawrel.dtdpagto = crappla.dtdpagto
               crawrel.vlpresta = crappla.vlprepla.
             
    END.   /*    Fim do For Each crapepr   */

    { includes/cabrel132_1.i }

    OUTPUT STREAM str_1 TO VALUE(glb_nmarqimp) PAGE-SIZE 84.

    VIEW STREAM str_1 FRAME f_cabrel132_1.

    FOR EACH crawrel NO-LOCK USE-INDEX crawrel1 BREAK BY crawrel.cdindica 
                                                         BY crawrel.cdempres:
                                                      
        IF   FIRST-OF(crawrel.cdindica) THEN
             DO:
                 PAGE STREAM str_1.
         
                 rel_dsprodut = IF  crawrel.cdindica = 1 
                                    THEN "EMPRESTIMO"
                                    ELSE "COTAS".
             END.               
                       
        IF   FIRST-OF(crawrel.cdempres) THEN
             DO:
                 FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper     AND
                                    crapemp.cdempres = crawrel.cdempres 
                                    NO-LOCK NO-ERROR.
              
                 IF   NOT AVAILABLE crapemp THEN
                      DO:
                          glb_cdcritic = 040.
                          RUN fontes/critic.p.
                          UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                            " - " + glb_cdprogra + "' --> '" +
                                            glb_dscritic + " CONTA = " +
                                           STRING(crawrel.nrdconta,"zzzz,zzz,9")
                                            + " >> log/proc_batch.log").
                          LEAVE.
                      END.
    
                 rel_dsempres = crapemp.nmresemp.
              
                 DISPLAY STREAM str_1 rel_dsempres  WITH FRAME f_empresa.
             END.
         
        FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                           crapass.nrdconta = crawrel.nrdconta NO-LOCK NO-ERROR.
                           
        IF   NOT AVAILABLE crapass THEN
             DO:
                 glb_cdcritic = 251.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                   " - " + glb_cdprogra + "' --> '" +
                                   glb_dscritic + " CONTA = " +
                                   STRING(crawrel.nrdconta,"zzzz,zzz,9") +
                                   " >> log/proc_batch.log").
                 LEAVE.
             END.
    
        ASSIGN rel_vldecpmf = crawrel.vlpresta + 
                              (ROUND(crawrel.vlpresta * tab_txcpmfcc,2) + 0.01)
               rel_nrcadast = crapass.nrcadast
               rel_nrdconta = crapass.nrdconta
               rel_nmprimtl = crapass.nmprimtl
               rel_nrctremp = crawrel.nrctremp
               rel_vlpreemp = crawrel.vlpresta.
           
        DISPLAY STREAM str_1 rel_nrcadast   rel_nrdconta   rel_nmprimtl
                             rel_dsprodut   rel_nrctremp   rel_vlpreemp
                             rel_vldecpmf   WITH FRAME f_emprestimos.

        DOWN STREAM str_1 WITH FRAME f_emprestimos.

        ASSIGN tot_vlpreemp = tot_vlpreemp + rel_vlpreemp
               tot_vldecpmf = tot_vldecpmf + rel_vldecpmf.
    
        IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
             PAGE STREAM str_1.    
             
        IF   LAST-OF(crawrel.cdempres) THEN
             DO:   
                 DISPLAY STREAM str_1  tot_vlpreemp   tot_vldecpmf 
                                       WITH FRAME f_totais.
                 PAGE STREAM str_1.

                 ASSIGN tot_vlpreemp = 0
                        tot_vldecpmf = 0.
             END.
 
    END. /* Fim do FOR EACH crawrel */

    OUTPUT STREAM str_1 CLOSE.

    ASSIGN glb_nrcopias = crapsol.nrdevias
           glb_nmformul = "132col".

    DO TRANSACTION ON ERROR UNDO, RETRY:

       crapsol.insitsol = 2.

    END.  /*  Fim da transacao  */
                            
    RUN fontes/imprim.p.

END. /* Fim do FOR EACH do crapsol. */
    
RUN fontes/fimprg.p.

/*........................................................................... */

