/*.............................................................................

    Programa: fontes/crps614.p
    Autor(a): Fabricio
    Data    : Janeiro/2012                      Ultima atualizacao: 05/12/2017
  
    Dados referentes ao programa:
  
    Frequencia: Diario (Batch).
    Objetivo  : Criar lancamento de debito na conta do cooperado, referente
                a mensalidade do cartao transportadora PAMCARD.
                
  
    Alteracoes: 03/02/2012 - Ajuste para debitar as mensalidades para quando 
                             for dia 1 - primeiro (Adriano).
                
                14/01/2014 - Alteracao referente a integracao Progress X 
                             Dataserver Oracle 
                             Inclusao do VALIDATE ( Andre Euzebio / SUPERO)
                                
                05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
                
                06/04/2015 - Alterado para que as criticas 09 e 75 fossem
                             retiradas do proc_batch.log e transferidas para
                             proc_message.log acrescentando a data na frente
                             do log (SD273423 Tiago/Fabricio).
                             
               05/12/2017 - Arrumar leitura da crappam para buscarmos da forma
                            correta na condicao "OR", foi incluido parenteses 
                            (Lucas Ranghetti #804628)
.............................................................................*/

DEF STREAM str_1.

{ includes/var_batch.i }


DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 6       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 6
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       ","PROCESSOS"]  NO-UNDO.

DEF VAR aux_contador AS INTE INIT 1                                  NO-UNDO.
DEF VAR aux_dddebpam AS INTE                                         NO-UNDO.
DEF VAR aux_vlmenpam AS DECI                                         NO-UNDO.

DEF TEMP-TABLE tt-relatorio-616                                      NO-UNDO
    FIELD cdagenci AS INTE
    FIELD nrdconta AS INTE
    FIELD nmprimtl AS CHAR.

FORM tt-relatorio-616.cdagenci COLUMN-LABEL "PA"      AT 10 FORMAT "zz9"
     tt-relatorio-616.nrdconta COLUMN-LABEL "CONTA/DV" AT 17 FORMAT "zzzz,zz9,9"
     tt-relatorio-616.nmprimtl COLUMN-LABEL "NOME/RAZAO SOCIAL" FORMAT "x(50)"
                                                                AT 31
     WITH DOWN WIDTH 132 FRAME f_relatorio.

ASSIGN glb_cdprogra = "crps614"
       glb_flgbatch = FALSE.
       
       
RUN fontes/iniprg.p.

IF glb_cdcritic > 0 THEN
    RETURN.

/* Busca dados da cooperativa */
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper 
                   NO-LOCK NO-ERROR.

IF NOT AVAILABLE crapcop THEN
   DO:
       glb_cdcritic = 651.
       RUN fontes/critic.p.
       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                         " - " + glb_cdprogra + "' --> '"  +
                         glb_dscritic + " >> log/proc_batch.log").
   
       RETURN.
   
   END.


ASSIGN aux_vlmenpam = crapcop.vlmenpam.
    
FOR EACH crappam WHERE crappam.cdcooper = crapcop.cdcooper    AND
                       crappam.flgpamca = TRUE                AND
                     ((crappam.dddebpam >  DAY(glb_dtmvtoan)  AND   
                       crappam.dddebpam <= DAY(glb_dtmvtolt)) OR    
                      (crappam.dddebpam = 1                   AND   
                       crappam.dddebpam = DAY(glb_dtmvtolt)))
                       NO-LOCK:

    ASSIGN aux_dddebpam = crappam.dddebpam.

    FIND crapass WHERE crapass.cdcooper = crappam.cdcooper AND
                       crapass.nrdconta = crappam.nrdconta 
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crapass THEN
    DO:
        glb_cdcritic = 9.
        RUN fontes/critic.p.
        UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") +
                          " "     + STRING(TIME,"HH:MM:SS")    +
                          " - "   + glb_cdprogra   + "' --> '" +
                          STRING(crappam.nrdconta) + " - "     +
                          glb_dscritic + " >> log/proc_message.log").

        NEXT.

    END.

    IF crapass.dtdemiss <> ? THEN
    DO:
        glb_cdcritic = 75.
        RUN fontes/critic.p.
        UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") +
                          " "     + STRING(TIME,"HH:MM:SS")    +
                          " - "   + glb_cdprogra   + "' --> '" +
                          STRING(crappam.nrdconta) + " - "     +
                          glb_dscritic + " >> log/proc_message.log").

        NEXT.

    END.

    /* Cria lancamento de debito na conta do cooperado */
    FIND craplot WHERE craplot.cdcooper = crappam.cdcooper AND
                       craplot.dtmvtolt = glb_dtmvtolt     AND
                       craplot.cdagenci = 1                AND
                       craplot.cdbccxlt = 100              AND
                       craplot.nrdolote = 9065 
                       NO-ERROR.

    IF NOT AVAIL craplot THEN
       DO:
           /* Criacao do lote */
           CREATE craplot.
    
           ASSIGN craplot.cdcooper = glb_cdcooper
                  craplot.dtmvtolt = glb_dtmvtolt   
                  craplot.cdagenci = 1
                  craplot.cdbccxlt = 100
                  craplot.nrdolote = 9065
                  craplot.cdoperad = glb_cdoperad
                  craplot.tplotmov = 1.
           VALIDATE craplot.
    
       END.
     
    /* Criacao do lancamento */
    CREATE craplcm.

    ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
           craplot.qtcompln = craplot.qtcompln + 1
           craplot.vlinfodb = craplot.vlinfodb + crapcop.vlmenpam
           craplot.vlcompdb = craplot.vlcompdb + crapcop.vlmenpam
           craplot.nrseqdig = craplot.nrseqdig + 1
        
           craplcm.dtmvtolt = craplot.dtmvtolt
           craplcm.cdagenci = craplot.cdagenci
           craplcm.cdbccxlt = craplot.cdbccxlt
           craplcm.nrdolote = craplot.nrdolote
           craplcm.cdoperad = craplot.cdoperad
           craplcm.nrdconta = crappam.nrdconta
           craplcm.nrdctabb = crappam.nrdconta
           craplcm.nrdctitg = crapass.nrdctitg
           craplcm.vllanmto = crapcop.vlmenpam
           craplcm.cdhistor = 1027 /* MENSALIDADE PAMCARD */
           craplcm.nrseqdig = craplot.nrseqdig
           craplcm.nrdocmto = aux_contador
           craplcm.cdcooper = glb_cdcooper.
    VALIDATE craplcm.

    ASSIGN aux_contador = aux_contador + 1.

    CREATE tt-relatorio-616.

    ASSIGN tt-relatorio-616.cdagenci = crapass.cdagenci
           tt-relatorio-616.nrdconta = crapass.nrdconta
           tt-relatorio-616.nmprimtl = crapass.nmprimtl.
    
END.
          
IF aux_dddebpam = 0 THEN
   aux_dddebpam = DAY(glb_dtmvtolt).

   RUN gera_relatorio_616(INPUT aux_dddebpam,
                          INPUT aux_vlmenpam).

       

RUN fontes/fimprg.p.


PROCEDURE gera_relatorio_616:

    DEF INPUT PARAM par_dddebpam AS INTE FORMAT "99"     NO-UNDO.
    DEF INPUT PARAM par_vlmenpam AS DECI FORMAT "zz9.99" NO-UNDO.

    DEF VAR aux_nmarquiv AS CHAR NO-UNDO.
    
    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/crrl616_" +
                            STRING(DAY(glb_dtmvtolt), "99") +
                            STRING(MONTH(glb_dtmvtolt), "99") +
                            STRING(YEAR(glb_dtmvtolt), "9999") + ".lst".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarquiv) PAGED PAGE-SIZE 84 NO-ECHO.

    { includes/cabrel132_1.i }

    VIEW STREAM str_1 FRAME f_cabrel132_1.

    PUT STREAM str_1 SKIP(3)
                     "MENSALIDADES COM DEBITO DIA " AT 10
                     par_dddebpam
                     "VALOR: " AT 45
                     par_vlmenpam
                     SKIP(3).
    
    FOR EACH tt-relatorio-616 NO-LOCK BY tt-relatorio-616.cdagenci
                                       BY tt-relatorio-616.nrdconta:
    
        IF LINE-COUNTER(str_1) >= PAGE-SIZE(str_1) THEN
        DO:
            PAGE STREAM str_1.
    
            PUT STREAM str_1 SKIP(3)
                             "MENSALIDADES COM DEBITO DIA " AT 10
                             par_dddebpam
                             "VALOR: " AT 45
                             par_vlmenpam
                             SKIP(3).
    
        END.
        
        DISP STREAM str_1 tt-relatorio-616.cdagenci
                          tt-relatorio-616.nrdconta
                          tt-relatorio-616.nmprimtl
                          WITH FRAME f_relatorio.
    
        DOWN STREAM str_1 WITH FRAME f_relatorio.
    
    END.

    OUTPUT STREAM str_1 CLOSE.

    ASSIGN glb_nrcopias = 1
           glb_nmformul = "132col"
           glb_nmarqimp = aux_nmarquiv
           glb_cdcritic = 0.

    RUN fontes/imprim.p.


END PROCEDURE.
