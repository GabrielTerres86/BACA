/* .............................................................................

   Programa: Fontes/inicia.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                        Ultima atualizacao: 11/03/2014

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Rotina de inicio do programa.

   Alteracoes: 11/11/98 - Permitir consultas apos a solicitacao do processo
                          (Deborah).

             12/05/2004 - Atualiza glb_progerad (Margarete).
             
             27/10/2004 - Colocado "F2 = AJUDA" que sera exibido em todas as
                          telas (Evandro).

             12/11/2004 - Se acesso livre(flgacliv = yes) permitir acessar
                          tela(Mirtes)

             08/03/2005 - Permitir acessar com glb_inproces >= 3 e       
                          Substituido flag flgacliv por inacesso(Mirtes).

             20/05/2005 - Alimentar as variaveis:
                          glb_dtultdia (Ultimo dia do mes corrente)
                          glb_dtultdma (Ultimo dia do mes anterior) (Edson).

             15/08/2005 - Capturar codigo da cooperativa da variavel de 
                          ambiente CDCOOPER (Edson).

             24/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
             
             01/03/2006 - Incluida chamada ao programa 'inicia_help.p' para o
                          controle de mensagens para uma nova versao da AJUDA 
                          da tela (Evandro).
                          
             18/06/2006 - Capturar o codigo da cooperativa da variavel de 
                          ambiente HOST (Edson).
 
             02/08/2007 - Capturar o nome do pacote da variavel de ambiente
                          PKGNAME (Edson).
                          
             11/03/2014 - Variaveis Projeto Oracle + gravar operacao (Guilherme)

............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_oracle.i }

DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_flgdesco AS LOGICAL INIT FALSE                    NO-UNDO.

/*  Captura o nome do pacote da variavel de ambiente PKGNAME ................ */

glb_nmpacote = OS-GETENV("PKGNAME").

IF   glb_nmpacote = ?   THEN
     ASSIGN glb_nmpacote = ""
            glb_dsdirpkg = "".
ELSE
     glb_dsdirpkg = "/" + glb_nmpacote.
 
/*  Captura codigo da cooperativa da variavel de ambiente CDCOOPER .......... */

glb_cdcooper = INT(OS-GETENV("CDCOOPER")).

IF   glb_cdcooper = ?   THEN
     glb_cdcooper = 0.

/*  Verifica se a cooperativa esta cadastrada ............................... */
   
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop   THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic "--> SISTEMA CANCELADO!".
         PAUSE MESSAGE "Tecle <entra> para voltar `a tela de identificacao!".
         BELL.
         QUIT.
     END.

glb_nmrescop = crapcop.nmrescop.

/*  Captura o nome do servidor da variavel de ambiente HOST ................. */

glb_hostname = OS-GETENV("HOST").

IF   glb_hostname = ?   OR
     glb_hostname = ""  THEN
     DO:
         BELL.
         MESSAGE "ERRO: Variavel glb_hostname NAO inicializada.".
         PAUSE MESSAGE "Tecle <entra> para voltar `a tela de identificacao!".
         BELL.
         QUIT.
     END.

/* Le data do sistema ....................................................... */

FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapdat   THEN
     DO:
         glb_cdcritic = 1.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic "--> SISTEMA CANCELADO!".
         PAUSE MESSAGE "Tecle <entra> para voltar `a tela de identificacao!".
         BELL.
         QUIT.
     END.

PUT SCREEN "F2 = AJUDA" COLOR MESSAGE ROW 22 COLUMN 70.

ASSIGN glb_dtmvtolt = crapdat.dtmvtolt
       glb_dtmvtopr = crapdat.dtmvtopr
       glb_dtmvtoan = crapdat.dtmvtoan
       glb_inproces = crapdat.inproces
       glb_dtultdma = crapdat.dtmvtolt - DAY(crapdat.dtmvtolt)
       
       glb_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) +
                                   4) - DAY(DATE(MONTH(glb_dtmvtolt),28,
                                                  YEAR(glb_dtmvtolt)) + 4)).

RUN  fontes/verdata.p.

FIND FIRST craptel WHERE craptel.cdcooper = glb_cdcooper    AND
                         craptel.nmdatela = glb_nmdatela    NO-LOCK NO-ERROR.

IF  (AVAIL  craptel AND
    craptel.inacesso = 2   AND
    crapdat.inproces > 2)      OR
    glb_nmdatela = " "         OR
    glb_nmdatela = "PRINCIPAL" OR  
    glb_nmdatela = "IDENTI" THEN 
    .
ELSE
IF   AVAIL craptel AND
     craptel.inacesso = 1 THEN
     DO:
         IF   crapdat.inproces > 2 THEN
              DO:
                  glb_cdcritic = 138.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  PAUSE MESSAGE
                        "Tecle <entra> para voltar `a tela de identificacao!".
                  QUIT.
              END.
     END.

ELSE   

IF   crapdat.inproces = 1 OR         /* Modulo Consulta */
    (crapdat.inproces = 2 AND SEARCH("arquivos/so_consulta") <> ? ) THEN
     .
ELSE
     DO:
         IF  AVAIL craptel THEN
             DO:
                glb_cdcritic = 138.
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                 PAUSE MESSAGE 
                  "Tecle <entra> para voltar `a tela de identificacao!".
                QUIT.
             END.
     END.

FIND crapprg WHERE crapprg.cdcooper = glb_cdcooper  AND
                   crapprg.cdprogra = glb_cdprogra  AND
                   crapprg.nmsistem = glb_nmsistem  NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapprg   THEN
     DO:
         glb_cdcritic = 2.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic "(" glb_cdprogra ")" " --> SISTEMA CANCELADO!".
         PAUSE MESSAGE "Tecle <entra> para voltar `a tela de identificacao!".
         BELL.
         QUIT.
     END.
ELSE
     DO:
         IF   crapprg.nrsolici = 50   THEN /* TELAS */
              ASSIGN glb_progerad = "TEL".
         ELSE
              ASSIGN glb_progerad = 
                         STRING(SUBSTRING(STRING(glb_cdprogra,"x(07)"),5,3)).
     END.

/*  Le tabela com o tempo maximo que o terminal pode ficar ocioso  */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "USUARI"      AND
                   craptab.cdempres = 0             AND
                   craptab.cdacesso = "TEMPOCIOSO"  AND
                   craptab.tpregist = 0             NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     glb_stimeout = 300.
ELSE
     glb_stimeout = IF glb_hostname <> "l1000"
                       THEN INTEGER(craptab.dstextab)
                       ELSE 99999.

{ includes/gg0000.i } 

/* Se ja estava conectado, nao desconecta */
IF   CONNECTED("bdgener")   THEN
     aux_flgdesco = FALSE.
ELSE
     aux_flgdesco = TRUE.
     
IF  f_conectagener() THEN
    DO:
       /* Verifica se o usuario ja viu a versao da AJUDA para dar a mensagem */
       RUN fontes/inicia_help.p (YES).
       IF   aux_flgdesco   THEN
            RUN p_desconectagener.
    END.

{ includes/PLSQL_grava_operacao.i &dboraayl={&scd_dboraayl} }

/** Gravacao do LOG de ACESSO a TELAS */
IF  TRIM(glb_nmdatela) <> "IDENTI"
AND TRIM(glb_nmdatela) <> "FIM"
AND glb_nmdatela <> "" THEN DO:

    { includes/logace.i }

END. /* FIM DO IF glb_nmdatela */

/* .......................................................................... */

