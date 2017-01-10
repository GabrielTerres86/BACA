/* ..........................................................................

   Programa: Includes/var_online.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Julho/93.                       Ultima atualizacao: 07/02/2012

   Dados referentes ao programa:

   Frequencia: Diario (On-line/Batch)
   Objetivo  : Criar as variaveis compartilhadas para o on_line e processo
               batch.

   Alteracoes: 03/08/95 - Alterado para igualar os includes/var_online.i e
                          includes/var_batch.i. Estes arquivos estao linka-
                          dos com os seguintes nomes:

                             includes/var_global.i
                             includes/var_online.i
                             includes/var_batch.i

                          (Edson).

               14/02/2000 - Criar definicao da glb_nmrotina (Edson).

               20/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               30/09/2002 - Novas datas de liberacao de cheques (Margarete).
               
               10/09/2003 - Aumentar o tamanho da glb_nmimpres (Ze Eduardo).
               
               02/01/2004 - Incluir glb_percenir (Margarete).

               13/04/2004 - Criadas novas rotinas(de 5 ate 9)(Mirtes).
               
               12/05/2004 - Incluir numero do programa gerador (Margarete).
               
               17/12/2004 - Incluir nova variavel: glb_nrdrecid (Edson).
               
               20/05/2005 - Incluir novas variaveis: 
                            glb_dtultdia (ultimo dia do mes corrente)
                            glb_dtultdma (ultimo dia do mes anterior) (Edson).
                            
               21/07/2005 - Incluir nova variavel: 
                            glb_flgrlger (Informa se o relatorio e gerencial)
                            (Julio)
                                                                       
               02/08/2005 - retirada a definicao da glb_flgrlger (Julio)
               
               18/08/2005 - Incluidos novos modulos na glb_nmmodulo (Evandro).
               
               13/03/2006 - Incluida a variavel "glb_opvihelp" para o controle
                            de mensagens da AJUDA (Evandro).
                            
               19/04/2006 - Incluida a variavel "glb_hostname" para o controle
                            de processos (Edson).

               02/08/2007 - Incluida a variavel "glb_nmpacote" para o controle
                            de pacotes nos servidores (Edson).

               10/08/2007 - Incluida a variavel "glb_dsdirpkg" para o controle
                            de pacotes nos servidores (Edson).

               23/07/2008 - Incluida a variavel "glb_nmdlogin" para controlar
                            quem fez a alteracao no caso de se usar o mesmo
                            operador do Ayllos (Magui).
                            
               02/02/2009 - Alteracao cdempres (Diego).
               
               11/05/2009 - Alteracao CDOPERAD (Kbase).
               
               07/02/2012 - Incluir variavel "glb_flgresta" para controle de 
                            restart dos programas batch (David).
               
               28/02/2014 - Removido trecho das variaveis para tratamento de                                 
			                erro ao executar Store Procedure Oracle 
                            (Andre Euzebio / Supero). 

			   07/12/2016 - P341-Automatização BACENJUD - Inclusão da variável 
			                global glb_cddepart (Renato Darosci)
............................................................................. */

DEF {1} SHARED VAR glb_dtmvtolt AS DATE    FORMAT "99/99/99"         NO-UNDO.
DEF {1} SHARED VAR glb_dtmvtopr AS DATE    FORMAT "99/99/99"         NO-UNDO.
DEF {1} SHARED VAR glb_dtmvtoan AS DATE    FORMAT "99/99/99"         NO-UNDO.
DEF {1} SHARED VAR glb_dtlibdpr AS DATE    FORMAT "99/99/99"         NO-UNDO.
DEF {1} SHARED VAR glb_dtlibfpr AS DATE    FORMAT "99/99/99"         NO-UNDO.
DEF {1} SHARED VAR glb_dtlibfma AS DATE    FORMAT "99/99/99"         NO-UNDO.
DEF {1} SHARED VAR glb_dtlibdma AS DATE    FORMAT "99/99/99"         NO-UNDO.
DEF {1} SHARED VAR glb_dtultdia AS DATE    FORMAT "99/99/99"         NO-UNDO.
DEF {1} SHARED VAR glb_dtultdma AS DATE    FORMAT "99/99/99"         NO-UNDO.

DEF {1} SHARED VAR glb_cdcooper AS INT     FORMAT "zz9"              NO-UNDO.
DEF {1} SHARED VAR glb_nmrescop AS CHAR    FORMAT "x(11)"            NO-UNDO.

DEF {1} SHARED VAR glb_dsdctitg AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF {1} SHARED VAR glb_dscritic AS CHAR    FORMAT "x(40)"            NO-UNDO.
DEF {1} SHARED VAR glb_dscricpl AS CHAR    FORMAT "x(40)"            NO-UNDO.
DEF {1} SHARED VAR glb_cddopcao AS CHAR    FORMAT "!(1)"             NO-UNDO.
DEF {1} SHARED VAR glb_cdoperad AS CHAR    FORMAT "x(10)"            NO-UNDO.
DEF {1} SHARED VAR glb_cddepart AS INTE    FORMAT "zzzz9"            NO-UNDO.
DEF {1} SHARED VAR glb_dsdepart AS CHAR    FORMAT "x(30)"            NO-UNDO.
DEF {1} SHARED VAR glb_nmoperad AS CHAR    FORMAT "x(25)"            NO-UNDO.
DEF {1} SHARED VAR glb_cdprogra AS CHAR    FORMAT "x(10)"            NO-UNDO.
DEF {1} SHARED VAR glb_dsparame AS CHAR    FORMAT "x(50)"            NO-UNDO.
DEF {1} SHARED VAR glb_dsrestar AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR glb_nmformul AS CHAR    FORMAT "x(10)"            NO-UNDO.
DEF {1} SHARED VAR glb_nmarqimp AS CHAR    FORMAT "x(20)"            NO-UNDO.
DEF {1} SHARED VAR glb_nmarqcri AS CHAR    FORMAT "x(20)"            NO-UNDO.
DEF {1} SHARED VAR glb_nmdafila AS CHAR    FORMAT "x(20)"            NO-UNDO.
DEF {1} SHARED VAR glb_nmimpres AS CHAR    FORMAT "x(11)"            NO-UNDO.
DEF {1} SHARED VAR glb_nmrelimp AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.
DEF {1} SHARED VAR glb_nmsistem AS CHAR    INIT "cred" FORMAT "x(4)" NO-UNDO.
DEF {1} SHARED VAR glb_nmdatela AS CHAR    FORMAT "x(6)"             NO-UNDO.
DEF {1} SHARED VAR glb_nmrotina AS CHAR    FORMAT "x(25)"            NO-UNDO.
DEF {1} SHARED VAR glb_nmtelant AS CHAR    FORMAT "x(6)"             NO-UNDO.
DEF {1} SHARED VAR glb_nmpacote AS CHAR    FORMAT "x(30)"            NO-UNDO.
DEF {1} SHARED VAR glb_dsdirpkg AS CHAR    FORMAT "x(30)"            NO-UNDO.
DEF {1} SHARED VAR glb_hostname AS CHAR    FORMAT "x(30)"            NO-UNDO.
DEF {1} SHARED VAR glb_tldatela AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR glb_dstransa AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR glb_percenir AS DEC                               NO-UNDO.
DEF {1} SHARED VAR glb_conta_script AS INT                           NO-UNDO.

DEF {1} SHARED VAR glb_nmmodulo AS CHAR    EXTENT 14
                            INIT ["  Conta Corrente - Depositos a Vista   ",
                                  "       Conta Corrente - Capital        ",
                                  "     Conta Corrente - Emprestimos      ",
                                  "           Modulo Digitacao            ",
                                  "          Cadastros/Consultas          ",
                                  "               Processos               ",
                                  "     Parametrizacao Conta Corrente     ",
                                  "    Parametrizacao Operacoes Credito   ",
                                  "        Parametrizacao Captacoes       ",
                                  "        Parametrizacao Cobranca        ",
                                  "    Parametrizacao Cartao Cred/Seguro  ",
                                  "         Parametrizacao Outros         ",
                                  "        Solicitacoes/Impressoes        ",
                                  "            Modulo Generico            "]
                            FORMAT "x(39)"                           NO-UNDO.

DEF {1} SHARED VAR glb_flgbatch AS LOGICAL INIT TRUE                 NO-UNDO.
DEF {1} SHARED VAR glb_flgimpre AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR glb_flgescra AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR glb_flgmicro AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR glb_stprogra AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR glb_infimsol AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR glb_stsnrcal AS LOGICAL                           NO-UNDO.

DEF {1} SHARED VAR glb_cdcritic AS INT     FORMAT "zz9"              NO-UNDO.
DEF {1} SHARED VAR glb_cdopcoes AS INT     FORMAT "z9"               NO-UNDO.
DEF {1} SHARED VAR glb_inrestar AS INT     FORMAT "9"                NO-UNDO.
DEF {1} SHARED VAR glb_flgresta AS LOGICAL INIT TRUE                 NO-UNDO.
DEF {1} SHARED VAR glb_inproces AS INT                               NO-UNDO.
DEF {1} SHARED VAR glb_nrctares AS INT     FORMAT "zzzz,zzz,9"       NO-UNDO.
DEF {1} SHARED VAR glb_qtdiaute AS INT     FORMAT "z9"               NO-UNDO.
DEF {1} SHARED VAR glb_cdrelato AS INT     FORMAT "zz9" EXTENT 5     NO-UNDO.
DEF {1} SHARED VAR glb_nmdestin AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.
DEF {1} SHARED VAR glb_nrrelato AS INT     FORMAT "9"                NO-UNDO.
DEF {1} SHARED VAR glb_cdempres AS INT                               NO-UNDO.
DEF {1} SHARED VAR glb_nrdevias AS INT     FORMAT "z9"               NO-UNDO.
DEF {1} SHARED VAR glb_nrcopias AS INT     FORMAT "zz9"              NO-UNDO.
DEF {1} SHARED VAR glb_nrseqsol AS INT                               NO-UNDO.
DEF {1} SHARED VAR glb_nrposchq AS INT                               NO-UNDO.
DEF {1} SHARED VAR glb_nrtalchq AS INT                               NO-UNDO.
DEF {1} SHARED VAR glb_nrfolhas AS INT                               NO-UNDO.
DEF {1} SHARED VAR glb_nrchqsdv AS INT                               NO-UNDO.
DEF {1} SHARED VAR glb_nrchqcdv AS INT                               NO-UNDO.
DEF {1} SHARED VAR glb_opvihelp AS LOGICAL                           NO-UNDO.

DEF {1} SHARED VAR glb_nrcalcul AS DECIMAL FORMAT ">>>>>>>>>>>>>9"   NO-UNDO.
DEF {1} SHARED VAR glb_cfrvipmf AS DECIMAL DECIMALS 6 INIT 0.998003  NO-UNDO.

DEF {1} SHARED VAR glb_nrdrecid AS RECID                             NO-UNDO.

/* 0.997506 - valor usado se a aliquota do IPMF for 0,25% */
/* 1        - valor usando quando nao ha tributacao       */

DEF {1} SHARED VAR glb_vlalipmf AS DECIMAL DECIMALS 4 INIT 0.0020    NO-UNDO.

/* 0.0025    - valor da aliquota do IPMF       */
/* 0         - valor quando nao ha tributacao  */

DEF {1} SHARED VAR glb_nrmodulo AS INT     INIT 5 FORMAT "z9"        NO-UNDO.
DEF {1} SHARED VAR glb_cdagenci AS INT     FORMAT "zz9"              NO-UNDO.
DEF {1} SHARED VAR glb_cdbccxlt AS INT     FORMAT "zz9"              NO-UNDO.
DEF {1} SHARED VAR glb_nrdolote AS INT     FORMAT "zzzzz9"           NO-UNDO.
DEF {1} SHARED VAR glb_stimeout AS INT     FORMAT "zzz9"             NO-UNDO.
DEF {1} SHARED VAR glb_progerad AS CHAR    FORMAT "x(03)"            NO-UNDO.
DEF {1} SHARED VAR glb_nmdlogin AS CHAR    FORMAT "x(08)"            NO-UNDO.  

/* .......................................................................... */
 
