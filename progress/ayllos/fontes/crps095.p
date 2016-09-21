 /* ..........................................................................

   Programa: Fontes/crps095.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Setembro/94                         Ultima atualizacao: 25/01/2016

   Dados referentes ao programa:

   Frequencia: Batch - Background.

               Rodara no primeiro dia util apos mensal (solicitacao automatica)

   Objetivo  : Listar os assossiados demitidos com limite de credito.
               Atende a solicitacao 90.
               Ordem da Solicitacao 117.
               Exclusividade 2.
               Ordem do programa na solicitacao = 3.

   Alteracao : 22/11/94 - Alterado para modificar a selecao do crapass para
                          vllimcre > 0 e cdsitct <> 1 e incluir no relatorio
                          o campo situacao da conta (Odair).

               21/08/96 - Alterado para listar o limite de cartao Credicard
                          (Edson).

               17/04/97 - Tratar vllimcrd, cartao de credito (Odair)

               25/08/98 - Modificado o acesso a tabela de limites (Deborah).

               04/01/2000 - Nao gerar pedido de impressao (Deborah).

               11/02/2000 - Gerar pedio de impressao (Deborah). 

               26/04/2000 - Mostrar se o associado com conta encerrada continua
                            como avalista (Odair)

               17/01/2001 - Substituir CCOH por COOP (Margarete/Planner).
               
               19/03/2002 - Mostrar somente os avais com determinado perfil
                            (Junior).

               31/07/2002 - Incluir nova situacao da conta (Margarete).

               25/06/2004 - Inclusao do campo MAG (se o associado ainda tem o
                            cartao magnetico em uso) (Evandro).
               
               29/06/2004 - Ler crapavl com tpdcontr = 1 (Emprestimo)(Mirtes) 
               
               15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               08/03/2013 - Nao abortar o programa se nao tiver emprestimos 
                            cadastrados (Daniele).
                            
               05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
               
               07/01/2015 - Tratamento para buscar o limite de credito dos
                            cartões Cecred da proria tabela crawcrd
                            SD204269 (Odirlei/AMcom)
                            
               25/01/2016 - Melhoria para alterar proc_batch pelo proc_message
                            na critica 532 e 356. (Jaison/Diego - SD: 365668)

............................................................................. */

DEF STREAM str_1.     /*  Para listagem dos demitidos no mes  */

{ includes/var_batch.i "NEW" }

DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.
DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR tot_vllimcre AS DECIMAL                               NO-UNDO.
DEF        VAR tot_vllimcrd AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vllimcrd AS DECIMAL                               NO-UNDO.

DEF        VAR tot_qtdconta AS INT                                   NO-UNDO.

DEF        VAR aux_dtdemiss AS DATE FORMAT "99/99/9999"              NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR    INIT "rl/crrl082.lst"         NO-UNDO.

DEF        VAR rel_dssitdct AS CHAR    FORMAT "x(25)"                NO-UNDO.
DEF        VAR rel_dsresage AS CHAR    FORMAT "x(21)"                NO-UNDO.

DEF        VAR rel_flgeaval AS LOGI    FORMAT "SIM/NAO"              NO-UNDO.
DEF        VAR aux_flgfirst AS LOGI                                  NO-UNDO.

DEF        VAR aux_vlmindev AS DECIMAL FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR aux_qtdvezes AS INT     FORMAT "999"                  NO-UNDO.
DEF        VAR aux_crtmagne AS INT                                   NO-UNDO.

glb_cdprogra = "crps095".
RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.

FORM rel_dsresage      AT  01 FORMAT "x(19)"          LABEL "PA"
     crapass.nrdconta  AT  21 FORMAT "zzzz,zzz,9"     LABEL "CONTA/DV"
     crapass.nmprimtl  AT  32 FORMAT "x(27)"          LABEL "NOME DO ASSOCIADO"
     rel_dssitdct      AT  60 FORMAT "x(25)"          LABEL "SITUACAO DA CONTA"
     crapass.vllimcre  AT  88 FORMAT "zzzzz,zz9.99"   LABEL "LIM. CREDITO"
     rel_vllimcrd      AT 101 FORMAT "zzzzz,zz9.99"   LABEL "CART.CRED"
     aux_crtmagne      AT 114 FORMAT "z"              LABEL "MAG"
     crapass.dtdemiss  AT 118 FORMAT "99/99/9999"     LABEL "DEMISSAO"
     rel_flgeaval      AT 129 FORMAT "SIM/NAO"        LABEL "AVAL"
     WITH NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 132 FRAME f_associado.

FORM SKIP(1)
     "TOTAIS ==> "               AT   5
     tot_qtdconta                AT  21 FORMAT "zz,zzz,zz9"
     tot_vllimcre                AT  87 FORMAT "zz,zzz,zz9.99"
     tot_vllimcrd                AT 100 FORMAT "zz,zzz,zz9.99"
     WITH NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 132 FRAME f_contador.

{ includes/cabrel132_1.i }               /* Monta cabecalho do relatorio */

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

VIEW    STREAM str_1                   FRAME f_cabrel132_1.

aux_flgfirst = TRUE.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "USUARI"       AND
                   craptab.cdempres = 11             AND
                   craptab.cdacesso = "PARLISAVAL"   AND
                   craptab.tpregist = 000 NO-LOCK NO-ERROR.
                   
     IF   NOT AVAILABLE craptab   THEN
          ASSIGN aux_vlmindev = 0
                 aux_qtdvezes = 0.
     ELSE
          DO:
              ASSIGN aux_vlmindev = DECIMAL(SUBSTRING(craptab.dstextab,01,12))
                     aux_qtdvezes = INTEGER(SUBSTRING(craptab.dstextab,14,1)).
          END.
 
FOR EACH crapass WHERE crapass.cdcooper  = glb_cdcooper AND
                       crapass.cdsitdct <> 1            AND
                       crapass.cdsitdct <> 6 
                       USE-INDEX crapass2 NO-LOCK
                       BREAK BY crapass.cdagenci
                                BY crapass.nrdconta :

    ASSIGN rel_vllimcrd = 0
           rel_flgeaval = FALSE
           aux_crtmagne = 0.

    /* Traz o nome da agencia para ser impresso */

    IF   FIRST-OF (crapass.cdagenci)  THEN
         DO:
             /*FIND crapage OF crapass NO-LOCK NO-ERROR.*/
             FIND crapage WHERE crapage.cdcooper = glb_cdcooper     AND
                                crapage.cdagenci = crapass.cdagenci 
                                NO-LOCK NO-ERROR.

             IF   NOT AVAILABLE crapage THEN
                  rel_dsresage = STRING(crapass.cdagenci,"zz9") + " " +
                                 "NAO CADASTRADA".
             ELSE
                  rel_dsresage = STRING(crapass.cdagenci,"zz9") + " " +
                                 crapage.nmresage.
             
             IF   NOT aux_flgfirst THEN
                  PAGE STREAM str_1.
                                       
             aux_flgfirst = FALSE.                          
                                 
         END.

    FOR EACH crawcrd WHERE crawcrd.cdcooper = glb_cdcooper     AND
                           crawcrd.nrdconta = crapass.nrdconta AND
                           crawcrd.insitcrd = 4 NO-LOCK:

        /* se for cartão cecred, identificado pela administradora
           usar o limite que consta no proprio cartão*/
        IF crawcrd.cdadmcrd >= 10 AND crawcrd.cdadmcrd <= 80 THEN
            rel_vllimcrd = rel_vllimcrd + crawcrd.vllimcrd.            
        ELSE
        DO:
            FIND craptlc WHERE craptlc.cdcooper = glb_cdcooper     AND
                               craptlc.cdadmcrd = crawcrd.cdadmcrd AND
                               craptlc.tpcartao = crawcrd.tpcartao AND
                               craptlc.cdlimcrd = crawcrd.cdlimcrd AND
                               craptlc.dddebito = 0 NO-LOCK NO-ERROR.
    
            IF   NOT AVAILABLE craptlc   THEN
                 DO:
                     glb_cdcritic = 532.
                     RUN fontes/critic.p.
                     UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '" + glb_dscritic +
                          " >> log/proc_message.log").
                     glb_cdcritic = 0.
                   
                     NEXT.
                 END.
    
            rel_vllimcrd = rel_vllimcrd + craptlc.vllimcrd.            
        END.
    END.

    FOR EACH crapavl WHERE crapavl.cdcooper = glb_cdcooper     AND
                           crapavl.nrdconta = crapass.nrdconta AND
                           crapavl.tpctrato = 1 NO-LOCK:
             
        FIND crapepr WHERE crapepr.cdcooper = glb_cdcooper     AND
                           crapepr.nrdconta = crapavl.nrctaavd AND
                           crapepr.nrctremp = crapavl.nrctravd 
                           NO-LOCK NO-ERROR.
        
        IF   NOT AVAILABLE crapepr   THEN
             DO:
                 glb_cdcritic = 356.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '" + glb_dscritic +
                      STRING(crapavl.nrctaavd,"zzzz,zz9,9") + 
                      " >> log/proc_message.log").
                 glb_cdcritic = 0.
                 NEXT.
             END.
        ELSE
             DO:
                 IF   crapepr.inliquid = 0 THEN
                      DO:
                      
                         FIND crapcot WHERE crapcot.cdcooper = glb_cdcooper AND
                                            crapcot.nrdconta = crapepr.nrdconta 
                                            NO-LOCK NO-ERROR.
                                    
                         IF   NOT AVAILABLE crapcot  THEN
                              DO:
                                  glb_cdcritic = 169.
                                  RUN fontes/critic.p.
                                  UNIX SILENT VALUE("echo " +
                                                    STRING(TIME,"HH:MM:SS") +
                                                    " - " + glb_cdprogra +
                                                    "' --> '" + glb_dscritic +
                                                    " >> log/proc_batch.log").
                                  QUIT.
                              END.
                         ELSE
                              IF   crapepr.vlsdeved > 
                                  (aux_qtdvezes * crapcot.vldcotas)  OR
                                   crapepr.vlsdeved >  aux_vlmindev  THEN
                                   rel_flgeaval = TRUE.
                      END.
             END.
    END.  
        
    IF   crapass.vllimcre = 0  AND rel_vllimcrd = 0 AND
         (NOT rel_flgeaval OR (rel_flgeaval AND crapass.cdsitdct = 3)) THEN
         NEXT.

    ASSIGN tot_qtdconta = tot_qtdconta + 1
           tot_vllimcre = tot_vllimcre + crapass.vllimcre
           tot_vllimcrd = tot_vllimcrd + rel_vllimcrd.

    rel_dssitdct =  IF    crapass.cdsitdct = 2  THEN
                          "ENCERRADA PELO ASSOCIADO"
                    ELSE
                    IF    crapass.cdsitdct = 3  THEN
                          "ENCERRADA PELA COOP"
                    ELSE
                    IF    crapass.cdsitdct = 4  THEN
                          "ENCERRADA PELA DEMISSAO"
                    ELSE
                    IF    crapass.cdsitdct = 5  THEN
                          "NAO APROVADA"
                    ELSE
                          "ENCERRADA P/OUTRO MOTIVO".
    FOR EACH crapcrm WHERE crapcrm.cdcooper = glb_cdcooper     AND
                           crapcrm.nrdconta = crapass.nrdconta AND
                           crapcrm.cdsitcar = 2 NO-LOCK.
         aux_crtmagne = aux_crtmagne + 1.
    END.
    
    DISPLAY STREAM str_1
            rel_dsresage     crapass.nrdconta  crapass.nmprimtl
            rel_dssitdct    
            crapass.vllimcre  WHEN crapass.vllimcre > 0
            rel_vllimcrd      WHEN rel_vllimcrd > 0
            aux_crtmagne
            crapass.dtdemiss  
            rel_flgeaval      WHEN rel_flgeaval = TRUE
            WITH FRAME f_associado.

    DOWN STREAM str_1 WITH FRAME f_associado.

    IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
         DO:
             PAGE STREAM str_1.
             VIEW STREAM str_1 FRAME f_label.
         END.

END.  /*  Fim do FOR EACH */

DISPLAY STREAM str_1
        tot_qtdconta  tot_vllimcre  tot_vllimcrd WITH FRAME f_contador.

OUTPUT STREAM str_1 CLOSE.
                    
glb_infimsol = true.

RUN fontes/fimprg.p.

IF   glb_cdcritic > 0   THEN
     QUIT.

ASSIGN glb_nmarqimp = aux_nmarqimp
       glb_nmformul = ""
       glb_nrcopias = 1.

RUN fontes/imprim.p. 
                                 
/*.......................................................................... */

