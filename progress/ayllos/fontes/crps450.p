/* .............................................................................

   Programa: Fontes/crps450.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio   
   Data    : junho/2005                       Ultima atualizacao: 16/08/2013
      
   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Gerar listagem dos cartoes credito prestes a vencer.
               Atende a solicitacao 87. Ordem 9.  Emite relatorio 422.

   Alteracoes: 17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
   
               09/03/2009 - Colocar relatorio 422 na intranet (Gabriel). 
               
               22/09/2010 - Inclusão de titulo no inicio do relatorio.
                          - Remocao do campo parentesco
                          - Inserção do campo Tipo
                          - Inibir parte do numero do cartão no relatorio.
                          - Exibir formato de data "99/99/99"
                          (Irlan)
                                      
               01/04/2010 - Voltar a exibir o numero completo do cartão no 
                            relatorio. (Irlan).
               
               16/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
............................................................................. */

DEF STREAM str_1. 

{ includes/var_batch.i "new" }

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR    INIT "rl/crrl422.lst"         NO-UNDO.
DEF        VAR aux_dsdctabb AS CHAR                                  NO-UNDO.
DEF        VAR aux_vllimcrd LIKE craptlc.vllimcrd                    NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_desctipo AS CHAR                                  NO-UNDO.
DEF        VAR aux_qtcartao AS INT                                   NO-UNDO.
DEF        VAR aux_nrcrcard LIKE crawcrd.nrcrcard                    NO-UNDO.


DEF TEMP-TABLE cratcrd FIELD nrdconta LIKE crawcrd.nrdconta 
                       FIELD cdagenci LIKE crapass.cdagenci
                       FIELD nrcrcard LIKE crawcrd.nrcrcard
                       FIELD nmtitcrd LIKE crawcrd.nmtitcrd
                       FIELD dtvalida LIKE crawcrd.dtvalida
                       FIELD vllimcrd LIKE craptlc.vllimcrd
                       FIELD dddebito LIKE crawcrd.dddebito
                       FIELD cdadmcrd LIKE crawcrd.cdadmcrd
                       FIELD nmadmcrd LIKE crapadc.nmadmcrd
                       FIELD nmresadm LIKE crapadc.nmresadm
                       FIELD desctipo AS   CHARACTER.
                       
ASSIGN glb_cdprogra = "crps450".

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0   THEN
    QUIT.

FORM SKIP(2)
     "CARTOES A VENCER:"
     SKIP(1)
     "ADMINISTRADORA: " cratcrd.nmresadm 
     SKIP(3)
     WITH NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 132 FRAME f_admcrd.

FORM SKIP(2)
     "QUANTIDADE DE CARTOES A VENCER: " aux_qtcartao
     SKIP(3)
     WITH NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 132 FRAME f_qtcartao.

FORM cratcrd.cdagenci AT   1 FORMAT "zz9"                 LABEL "PA"
     cratcrd.nrdconta AT   7                              LABEL "CONTA/DV"
     cratcrd.desctipo AT  21 FORMAT "x(2)"                LABEL "TIPO"   
     cratcrd.nmtitcrd AT  28 FORMAT "x(19)"               LABEL "NOME"
     cratcrd.nrcrcard AT  50 FORMAT "9999,9999,9999,9999" LABEL "CARTAO"
     cratcrd.dtvalida AT  71 FORMAT "99/99/99"            LABEL "VALIDADE"
     cratcrd.vllimcrd AT  82 FORMAT "zzz,zzz,zz9.99"      LABEL "LIMITE"
     cratcrd.dddebito AT  99 FORMAT "99"                  LABEL "DEBITO"
     SKIP(1)
     WITH DOWN NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 132 FRAME f_lanctos.

FORM SKIP(5)
     "NAO HA CARTOES VENCENDO NOS PROXIMOS 30 DIAS!"
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_mensagem.

{ includes/cabrel132_1.i }

glb_nmarqimp = "rl/crrl422.lst".

OUTPUT STREAM str_1 TO VALUE(glb_nmarqimp) PAGED PAGE-SIZE 80.

FOR EACH crawcrd WHERE crawcrd.cdcooper  = glb_cdcooper        AND
                 MONTH(crawcrd.dtvalida) = MONTH(glb_dtmvtopr) AND
                  YEAR(crawcrd.dtvalida) = YEAR(glb_dtmvtopr)  AND
                       crawcrd.insitcrd  = 4                   NO-LOCK:

    ASSIGN aux_nrcrcard = 0.

    FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                       crapass.nrdconta = crawcrd.nrdconta NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapass   THEN
        DO:
            glb_cdcritic = 651.
            RUN fontes/critic.p.
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - " + glb_cdprogra + "' --> '"  +
                              glb_dscritic + " >> log/proc_batch.log").
            RUN fontes/fimprg.p.                  
            QUIT.
        END. 

    IF  crapass.inpessoa = 1 THEN
        ASSIGN aux_desctipo = "PF".
    ELSE
    IF  (crapass.inpessoa = 2 OR crapass.inpessoa = 3) THEN
        ASSIGN aux_desctipo = "PJ".
    ELSE
        ASSIGN aux_desctipo = "  ".


    FIND craptlc WHERE craptlc.cdcooper = glb_cdcooper     AND
                       craptlc.cdadmcrd = crawcrd.cdadmcrd AND
                       craptlc.tpcartao = crawcrd.tpcartao AND
                       craptlc.dddebito = 0                AND
                       craptlc.cdlimcrd = crawcrd.cdlimcrd NO-LOCK NO-ERROR.
    
    IF   AVAILABLE craptlc   THEN
         ASSIGN aux_vllimcrd = craptlc.vllimcrd.
         
    FIND crapadc WHERE crapadc.cdcooper = glb_cdcooper     AND
                       crapadc.cdadmcrd = crawcrd.cdadmcrd NO-LOCK NO-ERROR.
                                       
    IF   NOT AVAILABLE crapadc   THEN
         DO:
             glb_cdcritic = 605.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '" +
                               glb_dscritic + " >> log/proc_batch.log").
             glb_cdcritic = 0.
             RUN fontes/fimprg.p.
             QUIT.
         END.

    CREATE cratcrd.    
    ASSIGN cratcrd.nrdconta = crawcrd.nrdconta
           cratcrd.cdagenci = crapass.cdagenci
           cratcrd.cdadmcrd = crawcrd.cdadmcrd
           cratcrd.nrcrcard = crawcrd.nrcrcard
           cratcrd.nmtitcrd = crawcrd.nmtitcrd
           cratcrd.dtvalida = crawcrd.dtvalida
           cratcrd.dddebito = crawcrd.dddebito
           cratcrd.vllimcrd = aux_vllimcrd
           cratcrd.nmadmcrd = crapadc.nmadmcrd
           cratcrd.nmresadm = crapadc.nmresadm 
           cratcrd.desctipo = aux_desctipo.

END. /* FOR EACH crawcrd */

VIEW STREAM str_1 FRAME f_cabrel132_1.

ASSIGN aux_flgfirst = TRUE
       aux_qtcartao = 0. 

FOR EACH cratcrd BREAK BY cratcrd.cdadmcrd BY cratcrd.cdagenci :

    IF   FIRST-OF(cratcrd.cdadmcrd)   THEN
         DO:
             IF    NOT aux_flgfirst   THEN
                   PAGE STREAM str_1.
                   
             ASSIGN aux_flgfirst = FALSE
                    aux_qtcartao = 0. 
                   
             DISPLAY STREAM str_1 cratcrd.nmresadm 
                                  WITH FRAME f_admcrd.
         END.

    DISPLAY STREAM str_1 cratcrd.nrdconta cratcrd.cdagenci 
                         cratcrd.nrcrcard cratcrd.nmtitcrd 
                         cratcrd.dtvalida cratcrd.vllimcrd
                         cratcrd.dddebito cratcrd.desctipo
                         WITH FRAME f_lanctos.

    ASSIGN aux_qtcartao = aux_qtcartao + 1.

    DOWN STREAM str_1 WITH FRAME f_lanctos.    

    IF  LAST-OF(cratcrd.cdadmcrd)  THEN
        DISPLAY STREAM str_1 aux_qtcartao WITH FRAME f_qtcartao.


END. /* FOR EACK cratcrd */

OUTPUT STREAM str_1 CLOSE.

RUN fontes/imprim.p.    

RUN fontes/fimprg.p.

/* .......................................................................... */


