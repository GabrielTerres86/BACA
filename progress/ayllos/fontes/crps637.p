/*..............................................................................

    Programa: fontes/crps637.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Lunelli
    Data    : Fevereiro/2013                  Ultima Atualizacao : 14/05/2018
    
    Dados referente ao programa:
    
    Frequencia : Diario (Batch). 
    Objetivo   : Convenios Sicredi - Importação de Arquivos.
                 Chamado Softdesk 43626.
                 
    Alteracoes : 06/05/2013 - Retirado filtro CONCREDI (Lucas).
                 
                 14/05/2013 - Não liberar DAS para pagamentos pela
                              Internet (Lucas).
                 
                 21/05/2013 - Alterações e Filtro CONCREDI DARFs (Lucas).
                 
                 22/05/2013 - Bloqueio importação DARFs (Lucas).
                 
                 05/06/2013 - Remoção filtro CONCREDI (Lucas).
                 
                 14/06/2013 - Remoção filtro DARF NUMERADA (Lucas).
                 
                 07/10/2013 - Filtro DARF NUMERADA (Lucas).
                 
                 22/04/2014 - Ajustes referentes ao Softdesk 148645 (Lucas R.)
                 
                 05/03/2015 - Retirado a condicao
                              " crapscn.dsnomcnv MATCHES "*FEBRABAN*" "
                              do fonte (SD 233749 - Tiago).
                              
                 30/11/2015 - Adicionado validacao na leitura da crapscn na 
                              procedure cria-registro-alteracao-tarifa
                              (Lucas Ranghetti #365399 )
                              
                 01/09/2016 - Retirar campo FCDEBAUTO da gravacao da tabela, 
                              pois nao utiliza em nenhum lugar (Lucas Ranghetti #506682)
                              
                 01/12/2016 - Alterar alteracao do CCROCONV para atualizar campos
                              de segmento e empresa da crapscn somente se seguir a
                              regra de crapscn.dsoparre = "E"  AND 
                              (crapscn.cddmoden = "A"  OR crapscn.cddmoden = "C")
                              (Lucas Ranghetti #531045)                          
                              
                22/02/2017 - Atualizar somente o segmento para a planilha CCROCONV
                             (Lucas Ranghetti #618741)
                             
                11/12/2017 - Alterar campo flgcnvsi por tparrecd.
                             PRJ406-FGTS (Odirlei-AMcom)    
                             
                14/05/2018 - Adicionar chamada do fonte imprim_unif.p no lugar do imprim.p
                             (Lucas Ranghetti #860204)

                09/11/2018 - Criado um tratamento para apresentar 30 carcatereres no campo dstransa (Descrição da transação).
                			 SCTASK0032223 (Paulo Kowalsky).             
							 
                16/04/2019 - Criar copia dos arquivos ccrotran e ccroconv para a pasta micros.
                             Chamado RITM0012005 - Gabriel Marcos (Mouts).

..............................................................................*/

DEF STREAM str_1.  /* ARQ. IMPORTAÇÃO       */
DEF STREAM str_2.  /* LINHA ARQ. IMPORTAÇÃO */
DEF STREAM str_3.  /* CRRL640               */

{ includes/var_batch.i } 

DEF  VAR  rel_nmempres    AS CHAR    FORMAT "x(15)"                   NO-UNDO.
DEF  VAR  rel_nmresemp    AS CHAR    FORMAT "x(15)"                   NO-UNDO.
DEF  VAR  rel_nmrelato    AS CHAR    FORMAT "x(40)" EXTENT 5          NO-UNDO.
DEF  VAR  rel_nrmodulo    AS INTE    FORMAT "9"                       NO-UNDO.
DEF  VAR  rel_nmmodulo    AS CHAR    FORMAT "x(15)" EXTENT 5          
                        INIT ["DEP. A VISTA   ","CAPITAL        ",    
                              "EMPRESTIMOS    ","DIGITACAO      ",    
                              "GENERICO       "]                      NO-UNDO.

DEF  VAR  aux_nmmesano    AS CHAR    EXTENT 12 INIT                   
                                [" JANEIRO ","FEVEREIRO",             
                                 "  MARCO  ","  ABRIL  ",             
                                 "  MAIO   ","  JUNHO  ",             
                                 " JULHO   "," AGOSTO  ",             
                                 "SETEMBRO "," OUTUBRO ",             
                                 "NOVEMBRO ","DEZEMBRO "]             NO-UNDO.

DEF  VAR aux_nmarqimp AS    CHAR   FORMAT "x(21)"                     NO-UNDO.
DEF  VAR aux_nomedarq AS    CHAR   FORMAT "x(21)"                     NO-UNDO.
DEF  VAR aux_nmarqrel AS    CHAR   FORMAT "x(21)"                     NO-UNDO.
DEF  VAR aux_setlinha AS    CHAR                                      NO-UNDO.
DEF  VAR aux_qtregist AS    INTE                                      NO-UNDO.
DEF  VAR aux_flgarqui AS    LOGI                                      NO-UNDO.
DEF  VAR aux_flginter AS    LOGI                                      NO-UNDO.
DEF  VAR aux_dstransa AS    CHAR                                      NO-UNDO.
                                                                      
/* Temp-table para crrl640 */
DEF TEMP-TABLE tt-crrl640
    FIELD idtpoper AS INTE
    FIELD dsnomcnv AS CHAR
    FIELD cdempres AS CHAR
    FIELD nrdiaflt AS INTE
    FIELD nrfltant AS INTE
    FIELD vltrfuni AS DECI
    FIELD vltarant AS DECI
    FIELD tpmeiarr AS CHAR
    FIELD dsmeiarr AS CHAR
    FIELD dtcanemp AS DATE.

/* Mantem como FALSE para rodar o programa manualmente na tela PRCCON */
ASSIGN glb_flgbatch = FALSE.

ASSIGN glb_cdprogra = "crps637"
       aux_flgarqui = FALSE.

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0   THEN
     RETURN.

UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")           + 
                        " - "   + STRING(TIME,"HH:MM:SS")         + 
                   " - "   + glb_cdprogra + "' --> '"             + 
                   "Iniciada importacao dos Arquivos do Sicredi." +
                   " >> log/prccon.log").

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop   THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")   + 
                            " - "   + STRING(TIME,"HH:MM:SS")      +
                            " - " + glb_cdprogra + "' --> '"       +
                            glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.

/* Informações de DARF */
ASSIGN aux_nmarqimp = "/usr/connect/sicredi/recebe/CCROTRIB.csv".

INPUT STREAM str_1 THROUGH VALUE("ls " + aux_nmarqimp + " 2>/dev/null") NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
    
    SET STREAM str_1 aux_nmarqimp FORMAT "x(70)".

    INPUT STREAM str_2 FROM VALUE(aux_nmarqimp) NO-ECHO.

    DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:
    
        IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

        ASSIGN aux_setlinha = REPLACE(aux_setlinha,'","', "|").

        /* Despreza primeira linha */
        IF  TRIM(ENTRY(1, aux_setlinha,  "|"),'"') = " " THEN
            NEXT.

        FIND crapstb WHERE crapstb.cdtribut = INTE(TRIM(ENTRY(5, aux_setlinha, "|"),'"'))
                                              EXCLUSIVE-LOCK NO-ERROR.

        IF  NOT AVAIL crapstb THEN
            CREATE crapstb.                                                               /* CCROTRIB  */

        ASSIGN crapstb.dsaretrb = TRIM(ENTRY(4, aux_setlinha, "|"),'"')                   /* fcarea    */
               crapstb.dstribut = TRIM(ENTRY(6, aux_setlinha, "|"),'"')                   /* fcdesc    */
               crapstb.dstrbtaa = TRIM(ENTRY(7, aux_setlinha, "|"),'"')                   /* fcdesctf  */
               crapstb.dsrestri = TRIM(ENTRY(8, aux_setlinha, "|"),'"')                   /* fcrestri  */
               crapstb.nrgrptrb = DECI(TRIM(ENTRY(9, aux_setlinha, "|"),'"'))             /* fngrupo   */
               crapstb.cdtribut = INTE(TRIM(ENTRY(5, aux_setlinha, "|"),'"'))             /* fccodtrib */
               crapstb.fgloppag = IF TRIM(ENTRY(11, aux_setlinha, "|"),'"') <> " " THEN
                                     LOGICAL(TRIM(ENTRY(11, aux_setlinha,"|"),'"'),"S/N") /* fcopcao   */
                                  ELSE FALSE.
        VALIDATE crapstb.

    END. /* DO WHILE TRUE */

    INPUT STREAM str_2 CLOSE.

    ASSIGN aux_flgarqui = TRUE.

END. /* DO WHILE TRUE */

INPUT STREAM str_1 CLOSE.

/* Log */
IF  aux_flgarqui THEN
    DO:
        UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")                   + 
                           " - "   + STRING(TIME,"HH:MM:SS")                      +
                           " - "   + glb_cdprogra + "' --> '"                     +
                           "Arquivo " + aux_nmarqimp + " processado com sucesso." +
                           " >> log/prccon.log").

        /* copia para o dir de armazenamento */
        UNIX SILENT VALUE("cp " + aux_nmarqimp + " /usr/connect/sicredi/recebidos/CCROTRIB_" + STRING(YEAR(TODAY),"9999") +
                                            STRING(MONTH(TODAY),"99") + STRING(DAY(TODAY),"99") + ".csv " + "2> /dev/null").

        /* remove o arq antigo */
        UNIX SILENT VALUE("rm " + aux_nmarqimp + " 2> /dev/null").

    END.

ASSIGN aux_flgarqui = FALSE.

/* Transações */
ASSIGN aux_nmarqimp = "/usr/connect/sicredi/recebe/CCROTRAN.csv".

INPUT STREAM str_1 THROUGH VALUE("ls " + aux_nmarqimp + " 2>/dev/null") NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

    SET STREAM str_1 aux_nmarqimp FORMAT "x(70)".

    INPUT STREAM str_2 FROM VALUE(aux_nmarqimp) NO-ECHO.

    DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:
        
        IMPORT STREAM str_2 UNFORMATTED aux_setlinha.
     
        ASSIGN aux_setlinha = REPLACE(aux_setlinha,'","', "|").

        /* Desconsiderar primeira linha */
        IF  TRIM(ENTRY(1, aux_setlinha,  "|"),'"') = " " THEN
            NEXT.

        FIND crapstn WHERE crapstn.cdtransa = TRIM(ENTRY(4,  aux_setlinha, "|"),'"')
                                              EXCLUSIVE-LOCK NO-ERROR. 
                                                                                                                            
        IF  NOT AVAIL crapstn THEN
            CREATE crapstn.                                                                 /* CCROTRAN   */
        ELSE
            RUN cria-registro-alteracao-tarifa.

        aux_dstransa = string(TRIM(ENTRY(6,  aux_setlinha, "|"),'"')).       
        RUN fontes/substitui_caracter.p (INPUT-OUTPUT aux_dstransa).                           
        aux_dstransa = SUBSTRING(aux_dstransa,1,30).


        ASSIGN crapstn.dsctacro = TRIM(ENTRY(47, aux_setlinha, "|"),'"')                    /* fccrarreco */
               crapstn.dsctccrs = TRIM(ENTRY(34, aux_setlinha, "|"),'"')                    /* fccrbcodes */
               crapstn.dsctccrm = TRIM(ENTRY(32, aux_setlinha, "|"),'"')                    /* fccrbcorem */
               crapstn.dsctcccs = TRIM(ENTRY(21, aux_setlinha, "|"),'"')                    /* fccrctbdes */
               crapstn.dsctcccm = TRIM(ENTRY(11, aux_setlinha, "|"),'"')                    /* fccrctbrem */
               crapstn.dsctccrt = TRIM(ENTRY(51, aux_setlinha, "|"),'"')                    /* fccrtarifa */
               crapstn.dsctpcre = TRIM(ENTRY(56, aux_setlinha, "|"),'"')                    /* fcctaprocr */
               crapstn.dsctpdeb = TRIM(ENTRY(54, aux_setlinha, "|"),'"')                    /* fcctaprodb */
               crapstn.dsctdbar = TRIM(ENTRY(46, aux_setlinha, "|"),'"')                    /* fcdbarreco */
               crapstn.dsctcdbs = TRIM(ENTRY(33, aux_setlinha, "|"),'"')                    /* fcdbbcodes */
               crapstn.dsctcdbm = TRIM(ENTRY(31, aux_setlinha, "|"),'"')                    /* fcdbbcorem */
               crapstn.dsctcdds = TRIM(ENTRY(20, aux_setlinha, "|"),'"')                    /* fcdbctbdes */
               crapstn.dsctcddm = TRIM(ENTRY(10, aux_setlinha, "|"),'"')                    /* fcdbctbrem */
               crapstn.dsctcdbt = TRIM(ENTRY(52, aux_setlinha, "|"),'"')                    /* fcdbtarifa */
               crapstn.dstransa = aux_dstransa                                              /* fcdescri   */
               crapstn.cdhdsbcc = TRIM(ENTRY(17, aux_setlinha, "|"),'"')                    /* fchsdbccor */
               crapstn.tpmeiarr = TRIM(ENTRY(58, aux_setlinha, "|"),'"')                    /* fcperarrec */ 
               crapstn.dspercon = TRIM(ENTRY(42, aux_setlinha, "|"),'"')                    /* fcpermconv */
               crapstn.dsperfil = TRIM(ENTRY(41, aux_setlinha, "|"),'"')                    /* fcpermfili */
               crapstn.dstipsfz = TRIM(ENTRY(35, aux_setlinha, "|"),'"')                    /* fctipodar  */
               crapstn.dstipdrf = TRIM(ENTRY(36, aux_setlinha, "|"),'"')                    /* fctipodarf */
               crapstn.dstiptra = TRIM(ENTRY(5,  aux_setlinha, "|"),'"')                    /* fctiptran  */
               crapstn.dsrsppag = TRIM(ENTRY(44, aux_setlinha, "|"),'"')                    /* fctpcoopta */
               crapstn.dscrdatr = TRIM(ENTRY(7,  aux_setlinha, "|"),'"')                    /* fcutiliz   */
               crapstn.tpcredes = TRIM(ENTRY(19, aux_setlinha, "|"),'"')                    /* fclancdest */
               crapstn.tpcreexe = TRIM(ENTRY(16, aux_setlinha, "|"),'"')                    /* fclancexec */
               crapstn.tpcrerem = TRIM(ENTRY(9,  aux_setlinha, "|"),'"')                    /* fclancrem  */
               crapstn.cdestdeb = TRIM(ENTRY(60, aux_setlinha, "|"),'"')                    /* fccodest   */
               crapstn.cdtransa = TRIM(ENTRY(4,  aux_setlinha, "|"),'"')                    /* fccodtran  */
               crapstn.cdcoptrf = TRIM(ENTRY(45, aux_setlinha, "|"),'"')                    /* fccooptari */
               crapstn.cdempres = TRIM(ENTRY(26, aux_setlinha, "|"),'"')                    /* fcempconv  */
               crapstn.cdhisrem = TRIM(ENTRY(40, aux_setlinha, "|"),'"')                    /* fchccremn  */
               crapstn.cdhisccd = TRIM(ENTRY(25, aux_setlinha, "|"),'"')                    /* fchisccdes */
               crapstn.cdhisccr = TRIM(ENTRY(15, aux_setlinha, "|"),'"')                    /* fchisccrem */
               crapstn.cdhisccc = TRIM(ENTRY(18, aux_setlinha, "|"),'"')                    /* fchscrccor */
               crapstn.cdhiscdd = INTE(TRIM(ENTRY(22, aux_setlinha, "|"),'"'))              /* fchsctbdes */
               crapstn.cdhiscdr = INTE(TRIM(ENTRY(12, aux_setlinha, "|"),'"'))              /* fchsctbrem */
               crapstn.cdhistcc = INTE(TRIM(ENTRY(57, aux_setlinha, "|"),'"'))              /* fchstrcc   */
               crapstn.cdhisprv = INTE(TRIM(ENTRY(55, aux_setlinha, "|"),'"'))              /* fcctaprohs */
               crapstn.cdhisarc = INTE(TRIM(ENTRY(48, aux_setlinha, "|"),'"'))              /* fchsarreco */
               crapstn.cdhisctr = INTE(TRIM(ENTRY(53, aux_setlinha, "|"),'"'))              /* fchscctari */
               crapstn.cdhiscds = INTE(TRIM(ENTRY(37, aux_setlinha, "|"),'"'))              /* fchctbdesn */
               crapstn.cdhctbre = INTE(TRIM(ENTRY(39, aux_setlinha, "|"),'"'))              /* fchctbremn */
               crapstn.cdhisdes = INTE(TRIM(ENTRY(38, aux_setlinha, "|"),'"'))              /* fchccdesn  */
               crapstn.tpnattaa = INTE(TRIM(ENTRY(8,  aux_setlinha, "|"),'"'))              /* fcnatterm  */
               crapstn.cdtraorg = INTE(TRIM(ENTRY(28, aux_setlinha, "|"),'"'))              /* fctranorig */
               crapstn.vltrfuni = DECI(TRIM(ENTRY(27, aux_setlinha, "|"),'"'))              /* fntarifuni */ 
               crapstn.vltrfbru = DECI(TRIM(ENTRY(59, aux_setlinha, "|"),'"'))              /* fntarifbru */
               crapstn.vltarifa = DECI(TRIM(ENTRY(43, aux_setlinha, "|"),'"'))              /* fnvalortar */
               crapstn.flgipcra = IF ENTRY(50, aux_setlinha, "|") <> " " THEN               
                                     LOGICAL(TRIM(ENTRY(50, aux_setlinha, "|"),'"'),"S/N")  /* fcimparrec */
                                  ELSE FALSE                                                
               crapstn.flgipdba = IF ENTRY(49, aux_setlinha, "|") <> " " THEN               
                                     LOGICAL(TRIM(ENTRY(49, aux_setlinha, "|"),'"'),"S/N")  /* fcimparred */
                                  ELSE FALSE                                                
               crapstn.flgipcrd = IF ENTRY(23, aux_setlinha, "|") <> " " THEN               
                                     LOGICAL(TRIM(ENTRY(23, aux_setlinha, "|"),'"'),"S/N")  /* fcimpcrdes */ 
                                  ELSE FALSE                                                
               crapstn.flgipcrr = IF ENTRY(13, aux_setlinha, "|") <> " " THEN               
                                     LOGICAL(TRIM(ENTRY(13, aux_setlinha, "|"),'"'),"S/N")  /* fcimpcrrem */
                                  ELSE TRUE                                                 
               crapstn.flgipdbd = IF ENTRY(24, aux_setlinha, "|") <> " " THEN               
                                     LOGICAL(TRIM(ENTRY(24, aux_setlinha, "|"),'"'),"S/N")  /* fcimpdbdes */
                                  ELSE FALSE                                                
               crapstn.flgipdbr = IF ENTRY(14, aux_setlinha, "|") <> " " THEN               
                                     LOGICAL(TRIM(ENTRY(14, aux_setlinha, "|"),'"'),"S/N")  /* fcimpdbrem */
                                  ELSE FALSE                                                
               crapstn.flgaccre = IF ENTRY(30, aux_setlinha, "|") <> " " THEN               
                                     LOGICAL(TRIM(ENTRY(30, aux_setlinha, "|"),'"'),"S/N")  /* fcacumtrcr */  
                                  ELSE FALSE                                                
               crapstn.flgacdeb = IF ENTRY(29, aux_setlinha, "|") <> " " THEN               
                                     LOGICAL(TRIM(ENTRY(29, aux_setlinha, "|"),'"'),"S/N")  /* fcacumtrdb */
                                  ELSE FALSE.
        VALIDATE crapstn.

    END. /* DO WHILE TRUE */                                       
                                                                   
    INPUT STREAM str_2 CLOSE.

    ASSIGN aux_flgarqui = TRUE.
                                                                   
END. /* DO WHILE TRUE */                                           
                                                                   
INPUT STREAM str_1 CLOSE.

/* Log */
IF  aux_flgarqui THEN
    DO:
        UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")                   + 
                           " - "   + STRING(TIME,"HH:MM:SS")                      + 
                           " - "   + glb_cdprogra + "' --> '"                     + 
                           "Arquivo " + aux_nmarqimp + " processado com sucesso." +
                           " >> log/prccon.log").

        /* copia para o dir de armazenamento */
        UNIX SILENT VALUE("cp " + aux_nmarqimp + " /usr/connect/sicredi/recebidos/CCROTRAN_" + STRING(YEAR(TODAY),"9999") +
                                            STRING(MONTH(TODAY),"99") + STRING(DAY(TODAY),"99") + ".csv " + "2> /dev/null").

        /* Disponibiliza copia do arquivo para acesso da area de negocio */
        UNIX SILENT VALUE("cp " + aux_nmarqimp + " /micros/convenios/tabela_ccrotran/CCROTRAN_" + STRING(YEAR(TODAY),"9999") +
                                            STRING(MONTH(TODAY),"99") + STRING(DAY(TODAY),"99") + ".csv " + "2> /dev/null").											

        /* remove o arq antigo */
        UNIX SILENT VALUE("rm " + aux_nmarqimp + " 2> /dev/null").

    END.

ASSIGN aux_flgarqui = FALSE.

/* Empresas e DARF */
ASSIGN aux_nmarqimp = "/usr/connect/sicredi/recebe/CCROCONV.csv".

INPUT STREAM str_1 THROUGH VALUE("ls " + aux_nmarqimp + " 2>/dev/null") NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

    SET STREAM str_1 aux_nmarqimp FORMAT "x(70)".

    INPUT STREAM str_2 FROM VALUE(aux_nmarqimp) NO-ECHO.

    DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

        IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

        ASSIGN aux_setlinha = REPLACE(aux_setlinha,'","', "|").

        /* Despreza primeira linha */
        IF  TRIM(ENTRY(1, aux_setlinha,  "|"),'"') = " " THEN
            NEXT.

        /* Fazer verificação se registro se existe na crapscn */
        FIND crapscn WHERE crapscn.cdempres = TRIM(ENTRY(4,  aux_setlinha, "|"),'"')
                                              EXCLUSIVE-LOCK NO-ERROR.    

        IF  NOT AVAIL crapscn THEN
            DO:
                RUN cria-registro-inclusao.
                CREATE crapscn.                                                             /*  CCROCONV   */ 
            END.
        ELSE
            DO:
                /* Se houve mudança no valor do FLOAT */
                IF  crapscn.nrdiaflt <> INTE(TRIM(ENTRY(109,aux_setlinha, "|"),'"')) THEN
                    RUN cria-registro-alteracao-float.

                /* Se já foi um convenio cancelado, registra reativação */
                IF  crapscn.dtencemp <> ?                        AND 
                    ENTRY(91, aux_setlinha, "|") = "00/00/0000"  THEN
                    RUN cria-registro-reativacao-convenio.
            END.

        /* Verifica se a Data é nula */
        IF  ENTRY(91, aux_setlinha, "|") <> "00/00/0000" THEN
            DO:
                /* Converte em Data e valida */
                DATE(ENTRY(91, aux_setlinha, "|")) NO-ERROR.
                IF  NOT ERROR-STATUS:ERROR THEN /* Verifica se não houve erro na conversão */
                    IF  AVAIL crapscn THEN      /* Se disponível na crapscn... */
                        DO:
                            IF  crapscn.dtencemp <> DATE(ENTRY(91, aux_setlinha, "|")) THEN  /* Verifica se a data está diferente, ou seja, foi cancelado */
                                RUN cria-registro-cancelamento.
                        END.
                    ELSE                        /* Caso não esteja disponível na crapscn, cria registro para o convênio cancelado */
                        RUN cria-registro-cancelamento.
            END.

        ASSIGN crapscn.dscodemp = TRIM(ENTRY(64, aux_setlinha, "|"),'"')                    /*  fccodempr  */  
               crapscn.dscodfeb = TRIM(ENTRY(42, aux_setlinha, "|"),'"')                    /*  fccodifebr */  
               crapscn.dscodtra = TRIM(ENTRY(24, aux_setlinha, "|"),'"')                    /*  fccodtran  */  
               crapscn.dsconfeb = TRIM(ENTRY(23, aux_setlinha, "|"),'"')                    /*  fcconsfebr */  
               crapscn.dscntade = TRIM(ENTRY(10, aux_setlinha, "|"),'"')                    /*  fccontades */  
               crapscn.dscntaex = TRIM(ENTRY(8,  aux_setlinha, "|"),'"')                    /*  fccontaexe */  
               crapscn.dsconteu = TRIM(ENTRY(65, aux_setlinha, "|"),'"')                    /*  fcconteudo */  
               crapscn.dscooper = TRIM(ENTRY(62, aux_setlinha, "|"),'"')                    /*  fccoop	  */  
               crapscn.dscoopde = TRIM(ENTRY(9,  aux_setlinha, "|"),'"')                    /*  fccoopdes  */  
               crapscn.dsdgreum = TRIM(ENTRY(57, aux_setlinha, "|"),'"')                    /*  fcdgrestum */  
               crapscn.dsdgrezo = TRIM(ENTRY(56, aux_setlinha, "|"),'"')                    /*  fcdgrestzr */  
               crapscn.dsdiarep = TRIM(ENTRY(18, aux_setlinha, "|"),'"')                    /*  fcdiarepas */  
               crapscn.dsdiaatr = TRIM(ENTRY(16, aux_setlinha, "|"),'"')                    /*  fcdiasatra */  
               crapscn.dsdianor = TRIM(ENTRY(14, aux_setlinha, "|"),'"')                    /*  fcdiasnorm */  
               crapscn.dsdiatar = TRIM(ENTRY(36, aux_setlinha, "|"),'"')                    /*  fcdiastari */  
               crapscn.dsiloteg = TRIM(ENTRY(63, aux_setlinha, "|"),'"')                    /*  fcloteg	  */  
               crapscn.dsdiatol = TRIM(ENTRY(12, aux_setlinha, "|"),'"')                    /*  fcdiastole */  
               crapscn.dstalote = TRIM(ENTRY(83, aux_setlinha, "|"),'"')                    /*  fcctaloteg */                 
               crapscn.dsarqtra = TRIM(ENTRY(29, aux_setlinha, "|"),'"')                    /*  fcarqtrans */  
               crapscn.dsdirdes = TRIM(ENTRY(51, aux_setlinha, "|"),'"')                    /*  fcdirdest  */  
               crapscn.dsdirori = TRIM(ENTRY(50, aux_setlinha, "|"),'"')                    /*  fcdirorig  */
               crapscn.cdempres = TRIM(ENTRY(4,  aux_setlinha, "|"),'"')                    /*  fcempconv  */
               crapscn.dsempfeb = TRIM(ENTRY(40, aux_setlinha, "|"),'"')                    /*  fcempfebr  */ 
               crapscn.dsemplot = TRIM(ENTRY(84, aux_setlinha, "|"),'"')                    /*  fcemplotfg */  
               crapscn.dsnomcnv = TRIM(ENTRY(5,  aux_setlinha, "|"),'"')                    /*  fcnomeconv */
               crapscn.dsoparre = TRIM(ENTRY(90, aux_setlinha, "|"),'"')                    /*  fcperarrec */  
               crapscn.dsperrep = TRIM(ENTRY(103,aux_setlinha, "|"),'"')                    /*  fcperiorep */  
               crapscn.dsiniage = TRIM(ENTRY(66, aux_setlinha, "|"),'"')                    /*  fcinicagen */  
               crapscn.dssigemp = TRIM(ENTRY(6,  aux_setlinha, "|"),'"')                    /*  fcsigla    */
               crapscn.dsdesrp2 = TRIM(ENTRY(73, aux_setlinha, "|"),'"')                    /*  fc2desrep  */  
               crapscn.dsundfed = TRIM(ENTRY(59, aux_setlinha, "|"),'"')                    /*  fcuf	   */  
               crapscn.dsperrp3 = TRIM(ENTRY(74, aux_setlinha, "|"),'"')                    /*  fc3desrep  */  
               crapscn.dsdesrp1 = TRIM(ENTRY(72, aux_setlinha, "|"),'"')                    /*  fc1desrep  */  
               crapscn.dstipage = TRIM(ENTRY(67, aux_setlinha, "|"),'"')                    /*  fctipoagen */  
               crapscn.cdtipcon = TRIM(ENTRY(21, aux_setlinha, "|"),'"')                    /*  fctipocons */
               crapscn.cdtipdeb = TRIM(ENTRY(22, aux_setlinha, "|"),'"')                    /*  fctipodeb  */
               crapscn.detiprep = TRIM(ENTRY(7,  aux_setlinha, "|"),'"')                    /*  fctiporep  */
               crapscn.cdtipven = TRIM(ENTRY(25, aux_setlinha, "|"),'"')                    /*  fctipovenc */
               crapscn.cdhiscre = TRIM(ENTRY(33, aux_setlinha, "|"),'"')                    /*  fccretarif */
               crapscn.flgrelip = TRIM(ENTRY(35, aux_setlinha, "|"),'"')                    /*  fccronogra */
               crapscn.cddmoden = TRIM(ENTRY(43, aux_setlinha, "|"),'"')                    /*  fcenviaopt */
               crapscn.flgfimsm = TRIM(ENTRY(17, aux_setlinha, "|"),'"')                    /*  fcfimseman */
               crapscn.flgpadfb = TRIM(ENTRY(58, aux_setlinha, "|"),'"')                    /*  fcversfebr */ 
               crapscn.cdhisdeb = INTE(TRIM(ENTRY(34, aux_setlinha, "|"),'"'))              /*  fcdebtarif */  
               crapscn.cddbanco = INTE(TRIM(ENTRY(30, aux_setlinha, "|"),'"'))              /*  fccodbanco */  
               crapscn.cdempco2 = INTE(TRIM(ENTRY(85, aux_setlinha, "|"),'"'))              /*  fcnumbarr2 */  
               crapscn.cdempco3 = INTE(TRIM(ENTRY(86, aux_setlinha, "|"),'"'))              /*  fcnumbarr3 */  
               crapscn.cdempco4 = INTE(TRIM(ENTRY(87, aux_setlinha, "|"),'"'))              /*  fcnumbarr4 */  
               crapscn.cdempco5 = INTE(TRIM(ENTRY(88, aux_setlinha, "|"),'"'))              /*  fcnumbarr5 */  
               crapscn.cdagenci = INTE(TRIM(ENTRY(45, aux_setlinha, "|"),'"'))              /*  fcagencia  */   
               crapscn.nrreatra = INTE(TRIM(ENTRY(15, aux_setlinha, "|"),'"'))              /*  fnarreatra */  
               crapscn.nrrenorm = INTE(TRIM(ENTRY(13, aux_setlinha, "|"),'"'))              /*  fnarrenorm */  
               crapscn.nrdiaflt = INTE(TRIM(ENTRY(109,aux_setlinha, "|"),'"'))              /*  fndiafloat */  
               crapscn.nrdiaiof = INTE(TRIM(ENTRY(79, aux_setlinha, "|"),'"'))              /*  fndiaiofrp */  
               crapscn.nrdiarep = INTE(TRIM(ENTRY(110,aux_setlinha, "|"),'"'))              /*  fndiasrp   */  
               crapscn.ddmestar = INTE(TRIM(ENTRY(31, aux_setlinha, "|"),'"'))              /*  fndiatarif */  
               crapscn.nrmodulo = INTE(TRIM(ENTRY(52, aux_setlinha, "|"),'"'))              /*  fnmodulo   */  
               crapscn.nrmultip = INTE(TRIM(ENTRY(55, aux_setlinha, "|"),'"'))              /*  fnmultfina */  
               crapscn.nrmulini = INTE(TRIM(ENTRY(54, aux_setlinha, "|"),'"'))              /*  fnmultinic */  
               crapscn.nrposini = INTE(TRIM(ENTRY(48, aux_setlinha, "|"),'"'))              /*  fnposiniba */  
               crapscn.nrtamdoc = INTE(TRIM(ENTRY(53, aux_setlinha, "|"),'"'))              /*  fntamdoc   */  
               crapscn.nrtolera = INTE(TRIM(ENTRY(11, aux_setlinha, "|"),'"'))              /*  fntoleranc */  
               crapscn.nrultcre = INTE(TRIM(ENTRY(46, aux_setlinha, "|"),'"'))              /*  fnultcred  */  
               crapscn.nrultdin = INTE(TRIM(ENTRY(47, aux_setlinha, "|"),'"'))              /*  fnultdiner */  
               crapscn.nrultrem = INTE(TRIM(ENTRY(26, aux_setlinha, "|"),'"'))              /*  fnultremes */
               crapscn.nrultret = INTE(TRIM(ENTRY(27, aux_setlinha, "|"),'"'))              /*  fnultretor */  
               crapscn.nrdiarp1 = INTE(TRIM(ENTRY(75, aux_setlinha, "|"),'"'))              /*  fn1diasrep */  
               crapscn.nrdiarp3 = INTE(TRIM(ENTRY(77, aux_setlinha, "|"),'"'))              /*  fn3diasrep */  
               crapscn.nrdiarp2 = INTE(TRIM(ENTRY(76, aux_setlinha, "|"),'"'))              /*  fn2diasrep */  
               crapscn.nrtipemp = INTE(TRIM(ENTRY(105,aux_setlinha, "|"),'"'))              /*  ftpempresa */  
               crapscn.vlperep1 = DECI(TRIM(ENTRY(69, aux_setlinha, "|"),'"'))              /*  fn1perrep  */  
               crapscn.vlpercen = DECI(TRIM(ENTRY(19, aux_setlinha, "|"),'"'))              /*  fnpercent  */  
               crapscn.vlperep3 = DECI(TRIM(ENTRY(71, aux_setlinha, "|"),'"'))              /*  fn3perrep  */  
               crapscn.vlperep2 = DECI(TRIM(ENTRY(70, aux_setlinha, "|"),'"'))              /*  fn2perrep  */  
               crapscn.vliofrat = DECI(TRIM(ENTRY(78, aux_setlinha, "|"),'"')).             /*  fniofratrp */
               

        ASSIGN crapscn.flgacchq = IF ENTRY(93, aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(93, aux_setlinha, "|"),'"'),"S/N")  /*  fcaceitach */  
                                  ELSE FALSE                                                                
               crapscn.flgacemp = IF ENTRY(97, aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(97, aux_setlinha, "|"),'"'),"S/N")  /*  fcaceitemp */  
                                  ELSE FALSE                                                                
               crapscn.flgarqat = IF ENTRY(107,aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(107,aux_setlinha, "|"),'"'),"S/N")  /*  fcarqautom */  
                                  ELSE FALSE                                                                
               crapscn.flgarqcn = IF ENTRY(44, aux_setlinha, "|") <> " " then                               
                                     LOGICAL(TRIM(ENTRY(44, aux_setlinha, "|"),'"'),"S/N")  /*  fcarqcnab  */  
                                  ELSE FALSE                                                             
               crapscn.flgarqfe = IF ENTRY(20, aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(20, aux_setlinha, "|"),'"'),"S/N")  /*  fcarqfetag */  
                                  ELSE FALSE                                                                
               crapscn.flgarqvz = IF ENTRY(108,aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(108,aux_setlinha, "|"),'"'),"S/N")  /*  fcarqvazio */  
                                  ELSE FALSE                                                                
               crapscn.flgblqvl = IF ENTRY(96, aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(96, aux_setlinha, "|"),'"'),"S/N")  /*  fcbloqvlr  */  
                                  ELSE FALSE                                                                
               crapscn.flgdevcc = IF ENTRY(94, aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(94, aux_setlinha, "|"),'"'),"S/N")  /*  fcccordev  */  
                                  ELSE FALSE                                                                
               crapscn.flgcodba = IF ENTRY(37, aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(37, aux_setlinha, "|"),'"'),"S/N")  /*  fccodbarra */  
                                  ELSE FALSE
               crapscn.flgdesta = IF ENTRY(41, aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(41, aux_setlinha, "|"),'"'),"S/N")  /*  fcdesctari */  
                                  ELSE FALSE                                                                
               crapscn.flgdiast = IF ENTRY(60, aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(60, aux_setlinha, "|"),'"'),"S/N")  /*  fcdigagen  */  
                                  ELSE FALSE                                                                
               crapscn.flgdivtr = IF ENTRY(92, aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(92, aux_setlinha, "|"),'"'),"S/N")  /*  fcdivtrans */  
                                  ELSE FALSE                                                                
               crapscn.flgexcop = IF ENTRY(68, aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(68, aux_setlinha, "|"),'"'),"S/N")  /*  fcexclopta */
                                  ELSE FALSE                                                                
               crapscn.flggerlt = IF ENTRY(113,aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(113,aux_setlinha, "|"),'"'),"S/N")  /*  fcgerlotex */  
                                  ELSE FALSE                                                                
               crapscn.flgguiac = IF ENTRY(102,aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(102,aux_setlinha, "|"),'"'),"S/N")  /*  fcguiach   */  
                                  ELSE FALSE                                                                
               crapscn.flglocal = IF ENTRY(61, aux_setlinha, "|") <> " " THEN                                
                                     LOGICAL(TRIM(ENTRY(61, aux_setlinha, "|"),'"'),"S/N")  /*  fclocal	   */  
                                  ELSE FALSE                                                                
               crapscn.flglotej = IF ENTRY(95, aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(95, aux_setlinha, "|"),'"'),"S/N")  /*  fclotej	   */  
                                  ELSE FALSE                                                                
               crapscn.flglotex = IF ENTRY(104,aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(104,aux_setlinha, "|"),'"'),"S/N")  /*  fclotex	   */  
                                  ELSE FALSE                                                                
               crapscn.flgrelvz = IF ENTRY(111,aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(111,aux_setlinha, "|"),'"'),"S/N")  /*  fcrelvazio */  
                                  ELSE FALSE                                                                
               crapscn.flgtarat = IF ENTRY(98, aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(98, aux_setlinha, "|"),'"'),"S/N")  /*  fctarifatm */  
                                  ELSE FALSE
               crapscn.flgtarpe = IF ENTRY(106,aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(106,aux_setlinha, "|"),'"'),"S/N")  /*  fctarperio */  
                                  ELSE FALSE                                                                
               crapscn.flgultdi = IF ENTRY(112,aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(112,aux_setlinha, "|"),'"'),"S/N")  /*  fcultdia   */  
                                  ELSE FALSE                                                                
               crapscn.flgultpo = IF ENTRY(49, aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(49, aux_setlinha, "|"),'"'),"S/N")  /*  fcultposba */
                                  ELSE FALSE                                                                
               crapscn.flgdest1 = IF ENTRY(80, aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(80, aux_setlinha, "|"),'"'),"S/N")  /*  fc1destari */  
                                  ELSE FALSE                                                                
               crapscn.flgratt1 = IF ENTRY(99, aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(99, aux_setlinha, "|"),'"'),"S/N")  /*  fc1perrep  */  
                                  ELSE FALSE                                                                
               crapscn.flgdest2 = IF ENTRY(81, aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(81, aux_setlinha, "|"),'"'),"S/N")  /*  fc2destari */  
                                  ELSE FALSE                                                                
               crapscn.flgratt2 = IF ENTRY(100,aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(100,aux_setlinha, "|"),'"'),"S/N")  /*  fc2perrep  */  
                                  ELSE FALSE                                                                
               crapscn.flgratt3 = IF ENTRY(101, aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(101, aux_setlinha, "|"),'"'),"S/N") /*  fc3perrep  */  
                                  ELSE FALSE                                                                
               crapscn.flgdest3 = IF ENTRY(82, aux_setlinha, "|") <> " " THEN                               
                                     LOGICAL(TRIM(ENTRY(82, aux_setlinha, "|"),'"'),"S/N")  /*  fc3destari */  
                                  ELSE FALSE                                                                
               crapscn.dtarqemp = IF ENTRY(28, aux_setlinha, "|") <> "00/00/0000" THEN                      
                                     DATE(TRIM(ENTRY(28, aux_setlinha, "|"),'"'))           /*  fdarqempre */  
                                  ELSE ?                                                                    
               crapscn.dtencemp = IF ENTRY(91, aux_setlinha, "|") <> "00/00/0000" THEN                      
                                     DATE(TRIM(ENTRY(91, aux_setlinha, "|"),'"'))           /*  fddtaenc   */  
                                  ELSE ?                                                                    
               crapscn.dtulttar = IF ENTRY(32, aux_setlinha, "|") <> "00/00/0000" THEN                      
                                     DATE(TRIM(ENTRY(32, aux_setlinha, "|"),'"'))           /*  fdulttarif */  
                                  ELSE ?.
        
        /* 
           FCENVIAOPT (crapscn.cddmoden) - identifica quem é o responsavel pelo cadastro do optante do debito 
                                           automatico.
           A-Agencia/Cooperativa
           B-Empresa Conveniada
           C-Misto
           
           FCPERARREC (crapscn.dsoparre) - Identifica se é convenio de arrecadacao ou debito automatico
           As letras representam os canais:
           A-Caixa
           B-ATM
           C-Agente credenciado
           D-IB
           E-Debito automatico
           F-CNAB
        */
        
        IF  crapscn.dsoparre = "E"  AND
           (crapscn.cddmoden = "A"  OR
            crapscn.cddmoden = "C") THEN
            ASSIGN crapscn.cdsegmto = TRIM(ENTRY(39, aux_setlinha, "|"),'"').   /*  fcsegmento */
        ELSE
            DO:            
            ASSIGN crapscn.cdsegmto = TRIM(ENTRY(39, aux_setlinha, "|"),'"')         /*  fcsegmento */
                   crapscn.cdempcon = INTE(TRIM(ENTRY(38, aux_setlinha, "|"),'"')).  /*  fcnumbarra */ 

        VALIDATE crapscn.

        /* Não gravar crapcon quando cod. segmento ou cod. empresa forem 0,
           quando o Segmento for "X" ou quando do conv. estiver cancelado */
        IF  crapscn.cdempcon = 0   OR
            crapscn.cdsegmto = ""  OR
            crapscn.cdsegmto = "X" OR
            crapscn.dtencemp <> ?  THEN
            NEXT.
            
        FOR EACH crapcop NO-LOCK.

            IF  crapscn.cdempres = "608" THEN /* DARF NUMERADO */
                NEXT.
            
            /* Verifica se convenio existe na cooperativa */
            FIND crapcon WHERE crapcon.cdcooper  = crapcop.cdcooper AND
                               crapcon.cdempcon  = crapscn.cdempcon AND   
                        STRING(crapcon.cdsegmto) = crapscn.cdsegmto
                               EXCLUSIVE-LOCK NO-ERROR.   

            IF  NOT AVAIL crapcon THEN
                DO:
                    ASSIGN aux_flginter = FALSE.

                    /* Faz consulta para verificar se possui meio de arrecadação internet */
                    IF  CAN-FIND(FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                                     crapstn.tpmeiarr = "D")             THEN
                        ASSIGN aux_flginter = TRUE.
                    
                    
                    /* Faz consulta para verificar se é DARF ou DAS */
                    IF  CAN-FIND(FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                                     crapstn.dstipdrf <> "")             OR
                        crapscn.cdempres = "K0"                                          THEN
                        ASSIGN aux_flginter = FALSE.
                    
                    /* Percorre campos de Cod. da Empresa no Cod. de Barras criando registros na crapcon */
                    IF  crapscn.cdempcon <> 0 THEN
                        RUN cria-reg-crapcon (INPUT crapscn.cdempcon,
                                              INPUT aux_flginter).

                    IF  crapscn.cdempco2 <> 0 THEN
                        RUN cria-reg-crapcon (INPUT crapscn.cdempco2,
                                              INPUT aux_flginter).

                    IF  crapscn.cdempco3 <> 0 THEN
                        RUN cria-reg-crapcon (INPUT crapscn.cdempco3,
                                              INPUT aux_flginter).

                    IF  crapscn.cdempco4 <> 0 THEN
                        RUN cria-reg-crapcon (INPUT crapscn.cdempco4,
                                              INPUT aux_flginter).

                    IF  crapscn.cdempco5 <> 0 THEN
                        RUN cria-reg-crapcon (INPUT crapscn.cdempco5,
                                              INPUT aux_flginter).

                END.
            ELSE
                DO:
                            ASSIGN crapcon.flgacsic = TRUE.
                            
                            IF  crapcon.tparrecd = 1 THEN /* Conv. SICREDI já existente, atualiza dados */
                        DO:
                            
                            ASSIGN crapcon.nmrescon = CAPS(crapscn.dssigemp)
                                   crapcon.nmextcon = CAPS(crapscn.dsnomcnv)
                                   crapcon.cdhistor = 1154        /* Fixo */
                                   crapcon.nrdolote = 15000       /* Fixo */
                                   crapcon.cdempcon = crapscn.cdempcon
                                   crapcon.cdsegmto = INT(crapscn.cdsegmto).

                            
                         END.
                     ELSE            /* Conv. existe na CECRED */
                         NEXT.
                END.

        END. /* FOR EACH crapcop */
            END.
    END. /* DO WHILE TRUE */

    INPUT STREAM str_2 CLOSE.

    ASSIGN aux_flgarqui = TRUE.

END. /* DO WHILE TRUE */

INPUT STREAM str_1 CLOSE.

/* Log */
IF  aux_flgarqui THEN
    DO:
        UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")                   + 
                           " - "   + STRING(TIME,"HH:MM:SS")                      + 
                           " - "   + glb_cdprogra + "' --> '"                     + 
                           "Arquivo " + aux_nmarqimp + " processado com sucesso." +
                           " >> log/prccon.log").

        /* copia para o dir de armazenamento */
        UNIX SILENT VALUE("cp " + aux_nmarqimp + " /usr/connect/sicredi/recebidos/CCROCONV_" + STRING(YEAR(TODAY),"9999") +
                                            STRING(MONTH(TODAY),"99") + STRING(DAY(TODAY),"99") + ".csv " + "2> /dev/null").

        /* Disponibiliza copia do arquivo para acesso da area de negocio */
        UNIX SILENT VALUE("cp " + aux_nmarqimp + " /micros/convenios/tabela_ccroconv/CCROCONV_" + STRING(YEAR(TODAY),"9999") +
                                            STRING(MONTH(TODAY),"99") + STRING(DAY(TODAY),"99") + ".csv " + "2> /dev/null").											

        /* remove o arq antigo */
        UNIX SILENT VALUE("rm " + aux_nmarqimp + " 2> /dev/null").

    END.

/* Crrl640 - Criações, Alterações, Cancelamentos e Reativação de Conv. SICREDI */
RUN gera-rel640.

UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")             + 
                   " - "   + STRING(TIME,"HH:MM:SS")                + 
                   " - "   + glb_cdprogra + "' --> '"               + 
                   "Finalizada importacao dos arquivos do Sicredi." +
                   " >> log/prccon.log").

RUN fontes/fimprg.p.


PROCEDURE cria-registro-inclusao:

    FOR EACH crapstn WHERE crapstn.cdempres = TRIM(ENTRY(4,  aux_setlinha, "|"),'"') NO-LOCK.

        CREATE tt-crrl640.
        ASSIGN tt-crrl640.idtpoper = 1 /* Inclusão */
               tt-crrl640.dsnomcnv = TRIM(ENTRY(5,  aux_setlinha, "|"),'"')
               tt-crrl640.cdempres = TRIM(ENTRY(4,  aux_setlinha, "|"),'"')
               tt-crrl640.nrdiaflt = INTE(TRIM(ENTRY(109,aux_setlinha, "|"),'"'))
               tt-crrl640.vltrfuni = crapstn.vltrfuni
               tt-crrl640.tpmeiarr = crapstn.tpmeiarr
               tt-crrl640.dsmeiarr = IF crapstn.tpmeiarr = "A" THEN "ATM"
                                ELSE IF crapstn.tpmeiarr = "B" THEN "CORRESPONDENTE BANCARIO"
                                ELSE IF crapstn.tpmeiarr = "C" THEN "CAIXA"
                                ELSE IF crapstn.tpmeiarr = "D" THEN "INTERNET BANKING"
                                ELSE IF crapstn.tpmeiarr = "E" THEN "DEBIT.AUTOM"
                                ELSE IF crapstn.tpmeiarr = "F" THEN "ARQ.CNAB240"
                                ELSE "NAO INFORMADO".
    END.

END PROCEDURE.

PROCEDURE cria-registro-alteracao-tarifa:

    /* Manteve a mesma tarifa, entao volta */
    IF  crapstn.cdempres = TRIM(ENTRY(26, aux_setlinha, "|"),'"')       AND
        crapstn.tpmeiarr = TRIM(ENTRY(58, aux_setlinha, "|"),'"')       AND
        crapstn.vltrfuni = DECI(TRIM(ENTRY(27, aux_setlinha, "|"),'"')) THEN
        RETURN.

    FIND crapscn WHERE crapscn.cdempres = crapstn.cdempres NO-LOCK NO-ERROR.

    CREATE tt-crrl640.
    ASSIGN tt-crrl640.idtpoper = 2 /* Alteração Tarifas */
           tt-crrl640.dsnomcnv = crapscn.dsnomcnv WHEN AVAIL crapscn
           tt-crrl640.cdempres = crapscn.cdempres WHEN AVAIL crapscn
           tt-crrl640.vltrfuni = DECI(TRIM(ENTRY(27, aux_setlinha, "|"),'"'))
           tt-crrl640.vltarant = crapstn.vltrfuni
           tt-crrl640.tpmeiarr = crapstn.tpmeiarr
           tt-crrl640.dsmeiarr = IF crapstn.tpmeiarr = "A" THEN "ATM"
                            ELSE IF crapstn.tpmeiarr = "B" THEN "CORRESPONDENTE BANCARIO"
                            ELSE IF crapstn.tpmeiarr = "C" THEN "CAIXA"
                            ELSE IF crapstn.tpmeiarr = "D" THEN "INTERNET BANKING"
                            ELSE IF crapstn.tpmeiarr = "E" THEN "DEBIT.AUTOM"
                            ELSE IF crapstn.tpmeiarr = "F" THEN "ARQ.CNAB240"
                            ELSE "NAO INFORMADO".
                            
END PROCEDURE.

PROCEDURE cria-registro-cancelamento:

    FOR EACH crapstn WHERE crapstn.cdempres = TRIM(ENTRY(4,  aux_setlinha, "|"),'"') NO-LOCK.

        CREATE tt-crrl640.
        ASSIGN tt-crrl640.idtpoper = 3 /* Cancelamento */
               tt-crrl640.dsnomcnv = TRIM(ENTRY(5,  aux_setlinha, "|"),'"')
               tt-crrl640.cdempres = TRIM(ENTRY(4,  aux_setlinha, "|"),'"')
               tt-crrl640.nrdiaflt = INTE(TRIM(ENTRY(109,aux_setlinha, "|"),'"'))
               tt-crrl640.vltrfuni = crapstn.vltrfuni
               tt-crrl640.tpmeiarr = crapstn.tpmeiarr
               tt-crrl640.dtcanemp = DATE(ENTRY(91, aux_setlinha, "|"))
               tt-crrl640.dsmeiarr = IF crapstn.tpmeiarr = "A" THEN "ATM"
                                ELSE IF crapstn.tpmeiarr = "B" THEN "CORRESPONDENTE BANCARIO"
                                ELSE IF crapstn.tpmeiarr = "C" THEN "CAIXA"
                                ELSE IF crapstn.tpmeiarr = "D" THEN "INTERNET BANKING"
                                ELSE IF crapstn.tpmeiarr = "E" THEN "DEBIT.AUTOM"
                                ELSE IF crapstn.tpmeiarr = "F" THEN "ARQ.CNAB240"
                                ELSE "NAO INFORMADO".
    END.

    /* Elimina registro do Conv. Sicredi Cancelado em todas as cooperativas */
    FOR EACH crapcop NO-LOCK.

        /* Procura o Cód da Emp (cdempcon) no fcnumbarra */
        FIND crapcon WHERE crapcon.cdcooper = crapcop.cdcooper                              AND
                           crapcon.cdempcon = INTE(TRIM(ENTRY(38, aux_setlinha, "|"),'"'))  AND
                           crapcon.cdsegmto = INTE(TRIM(ENTRY(39, aux_setlinha, "|"),'"'))  
                           EXCLUSIVE-LOCK NO-ERROR.
        
        IF  AVAIL crapcon THEN
        DO:
           /* SICREDI */
           IF crapcon.tparrecd = 1 THEN
             DO:
               /* Caso for arrecadado pelo Sicredi deve excluir registro*/
            DELETE crapcon.
             END.
           /* Caso nao for arrecadado, 
              apenas muda para nao permitir */  
           ELSE IF crapcon.tparrecd <> 1 THEN
             DO:
               crapcon.flgacsic = FALSE.              
             END.  

        END. 
        

        /* Procura o Cód da Emp (cdempcon) no fcnumbarr2 */
        FIND crapcon WHERE crapcon.cdcooper = crapcop.cdcooper                              AND
                           crapcon.cdempcon = INTE(TRIM(ENTRY(85, aux_setlinha, "|"),'"'))  AND
                           crapcon.cdsegmto = INTE(TRIM(ENTRY(39, aux_setlinha, "|"),'"'))  
                           EXCLUSIVE-LOCK NO-ERROR.
        
        IF  AVAIL crapcon THEN
        DO:
           /* SICREDI */
           IF crapcon.tparrecd = 1 THEN
             DO:
               /* Caso for arrecadado pelo Sicredi deve excluir registro*/
            DELETE crapcon.

             END.
           /* Caso nao for arrecadado, 
              apenas muda para nao permitir */  
           ELSE IF crapcon.tparrecd <> 1 THEN
             DO:
               crapcon.flgacsic = FALSE.              
             END.  
        END. 

        /* Procura o Cód da Emp (cdempcon) no fcnumbarr3 */
        FIND crapcon WHERE crapcon.cdcooper = crapcop.cdcooper                              AND
                           crapcon.cdempcon = INTE(TRIM(ENTRY(86, aux_setlinha, "|"),'"'))  AND
                           crapcon.cdsegmto = INTE(TRIM(ENTRY(39, aux_setlinha, "|"),'"'))  
                           EXCLUSIVE-LOCK NO-ERROR.
        
        IF  AVAIL crapcon THEN
        DO:
           /* SICREDI */
           IF crapcon.tparrecd = 1 THEN
             DO:
               /* Caso for arrecadado pelo Sicredi deve excluir registro*/
            DELETE crapcon.

    END.
           /* Caso nao for arrecadado, 
              apenas muda para nao permitir */  
           ELSE IF crapcon.tparrecd <> 1 THEN
             DO:
               crapcon.flgacsic = false.              
             END.  
        END. 

    END.

END PROCEDURE.

PROCEDURE cria-registro-alteracao-float:

    CREATE tt-crrl640.
    ASSIGN tt-crrl640.idtpoper = 4 /* Alteração FLOAT */
           tt-crrl640.dsnomcnv = crapscn.dsnomcnv
           tt-crrl640.cdempres = crapscn.cdempres
           tt-crrl640.nrdiaflt = INTE(TRIM(ENTRY(109,aux_setlinha, "|"),'"'))
           tt-crrl640.nrfltant = crapscn.nrdiaflt.
                            
END PROCEDURE.

PROCEDURE cria-registro-reativacao-convenio:

    FOR EACH crapstn WHERE crapstn.cdempres = TRIM(ENTRY(4,  aux_setlinha, "|"),'"') NO-LOCK.

        CREATE tt-crrl640.
        ASSIGN tt-crrl640.idtpoper = 5 /* Reativação */
               tt-crrl640.dsnomcnv = TRIM(ENTRY(5,  aux_setlinha, "|"),'"')
               tt-crrl640.cdempres = TRIM(ENTRY(4,  aux_setlinha, "|"),'"')
               tt-crrl640.nrdiaflt = INTE(TRIM(ENTRY(109,aux_setlinha, "|"),'"'))
               tt-crrl640.vltrfuni = crapstn.vltrfuni
               tt-crrl640.tpmeiarr = crapstn.tpmeiarr
               tt-crrl640.dsmeiarr = IF crapstn.tpmeiarr = "A" THEN "ATM"
                                ELSE IF crapstn.tpmeiarr = "B" THEN "CORRESPONDENTE BANCARIO"
                                ELSE IF crapstn.tpmeiarr = "C" THEN "CAIXA"
                                ELSE IF crapstn.tpmeiarr = "D" THEN "INTERNET BANKING"
                                ELSE IF crapstn.tpmeiarr = "E" THEN "DEBIT.AUTOM"
                                ELSE IF crapstn.tpmeiarr = "F" THEN "ARQ.CNAB240"
                                ELSE "NAO INFORMADO".
        
    END.

END PROCEDURE.

PROCEDURE gera-rel640:

    FORM tt-crrl640.dsnomcnv         FORMAT "X(35)"         COLUMN-LABEL "CONVENIO"
         tt-crrl640.cdempres         FORMAT "X(10)"         COLUMN-LABEL "COD.SICREDI"
         tt-crrl640.nrdiaflt         FORMAT "z9"            COLUMN-LABEL "FLOAT"
         tt-crrl640.vltrfuni         FORMAT "zz,zzz,zz9.99" COLUMN-LABEL "VL.TARIFA" 
         tt-crrl640.dsmeiarr         FORMAT "X(20)"         COLUMN-LABEL "ARRECADACAO"
         WITH NO-BOX DOWN WIDTH 132 FRAME f_crrl640_inclusao.

    FORM tt-crrl640.dsnomcnv         FORMAT "X(35)"         COLUMN-LABEL "CONVENIO"
         tt-crrl640.cdempres         FORMAT "X(10)"         COLUMN-LABEL "COD.SICREDI"
         tt-crrl640.nrdiaflt         FORMAT "z9"            COLUMN-LABEL "FLOAT"
         tt-crrl640.vltrfuni         FORMAT "zz,zzz,zz9.99" COLUMN-LABEL "VL.TARIFA" 
         tt-crrl640.dsmeiarr         FORMAT "X(20)"         COLUMN-LABEL "ARRECADACAO"
         tt-crrl640.dtcanemp                                COLUMN-LABEL "DT.CANCEL."
         WITH NO-BOX DOWN WIDTH 132 FRAME f_crrl640_cancel.

    IF  NOT TEMP-TABLE tt-crrl640:HAS-RECORDS THEN
        RETURN.

    ASSIGN aux_nmarqrel    = "/usr/coop/cecred/rl/crrl640.lst"
           glb_cdcritic    = 0         
           glb_cdrelato[3] = 640
           glb_cdempres    = 11
           glb_nrcopias    = 1
           glb_nmformul    = "132col"
           glb_nmarqimp    = aux_nmarqrel. /* "rl/crrl640.lst" */

    { includes/cabrel132_3.i }

    OUTPUT STREAM str_3 TO VALUE(aux_nmarqrel) PAGED PAGE-SIZE 84.

    VIEW STREAM str_3 FRAME f_cabrel132_3.
   
    FOR EACH tt-crrl640 WHERE tt-crrl640.idtpoper = 1 /* Inclusao */
                              NO-LOCK  BREAK BY tt-crrl640.idtpoper
                                             BY tt-crrl640.cdempres
                                             BY tt-crrl640.tpmeiarr:

        IF  FIRST-OF (tt-crrl640.idtpoper) THEN
            DO:
                PUT STREAM str_3 UNFORMATTED "INCLUSOES".
                PUT STREAM str_3 SKIP(2).
            END.
   
        IF  LINE-COUNTER(str_3) > (PAGE-SIZE(str_3) - 10) THEN
            DO:
                PAGE STREAM str_3.
      
                DOWN STREAM str_3 WITH FRAME f_crrl640_inclusao.
   
            END.
   
        DISPLAY STREAM str_3 tt-crrl640.dsnomcnv
                             tt-crrl640.cdempres
                             tt-crrl640.nrdiaflt
                             tt-crrl640.vltrfuni 
                             tt-crrl640.dsmeiarr
                             WITH FRAME f_crrl640_inclusao.
   
        DOWN STREAM str_3 WITH FRAME f_crrl640_inclusao.
   
    END.
   
    FOR EACH tt-crrl640 WHERE tt-crrl640.idtpoper = 3 /* Cancelamento */
                              NO-LOCK  BREAK BY tt-crrl640.idtpoper
                                             BY tt-crrl640.cdempres
                                             BY tt-crrl640.tpmeiarr:

        IF  FIRST-OF (tt-crrl640.idtpoper) THEN
            DO:
                PUT STREAM str_3 SKIP(2).
                PUT STREAM str_3 UNFORMATTED "CANCELAMENTOS".
                PUT STREAM str_3 SKIP(2).
            END.
   
        IF  LINE-COUNTER(str_3) > (PAGE-SIZE(str_3) - 10) THEN
            DO:
               PAGE STREAM str_3.
      
               DOWN STREAM str_3 WITH FRAME f_crrl640_cancel.
   
           END.
   
        DISPLAY STREAM str_3 tt-crrl640.dsnomcnv
                             tt-crrl640.cdempres
                             tt-crrl640.nrdiaflt
                             tt-crrl640.vltrfuni 
                             tt-crrl640.dsmeiarr
                             tt-crrl640.dtcanemp
                             WITH FRAME f_crrl640_cancel.
   
        DOWN STREAM str_3 WITH FRAME f_crrl640_cancel.
   
    END.

    FOR EACH tt-crrl640 WHERE tt-crrl640.idtpoper = 5 /* Reativação */
                              NO-LOCK  BREAK BY tt-crrl640.idtpoper
                                             BY tt-crrl640.cdempres
                                             BY tt-crrl640.tpmeiarr:

        IF  FIRST-OF (tt-crrl640.idtpoper) THEN
            DO:
                PUT STREAM str_3 SKIP(2).
                PUT STREAM str_3 UNFORMATTED "REATIVACAO".
                PUT STREAM str_3 SKIP(2).
            END.
   
        IF  LINE-COUNTER(str_3) > (PAGE-SIZE(str_3) - 10) THEN
            DO:
                PAGE STREAM str_3.
      
                DOWN STREAM str_3 WITH FRAME f_crrl640_inclusao.
   
            END.
   
        DISPLAY STREAM str_3 tt-crrl640.dsnomcnv
                             tt-crrl640.cdempres
                             tt-crrl640.nrdiaflt
                             tt-crrl640.vltrfuni 
                             tt-crrl640.dsmeiarr
                             WITH FRAME f_crrl640_inclusao.
   
        DOWN STREAM str_3 WITH FRAME f_crrl640_inclusao.
   
    END.

    FOR EACH tt-crrl640 WHERE tt-crrl640.idtpoper = 2  /* Alteração Tarifas */
                              NO-LOCK BREAK BY tt-crrl640.idtpoper
                                            BY tt-crrl640.cdempres
                                            BY tt-crrl640.tpmeiarr.

        IF  FIRST-OF (tt-crrl640.idtpoper) THEN
            DO:
                PUT STREAM str_3 SKIP(2).
                PUT STREAM str_3 UNFORMATTED "ALTERACAO TARIFAS".
                PUT STREAM str_3 SKIP(2).
            END.

        IF  LINE-COUNTER(str_3) > (PAGE-SIZE(str_3) - 10) THEN
            PAGE STREAM str_3.
      

        PUT STREAM str_3 UNFORMATTED "Convenio " + tt-crrl640.dsnomcnv + ", codigo SICREDI " + tt-crrl640.cdempres      +
                                     ", teve tarifa alterada de R$ " + TRIM(STRING(tt-crrl640.vltarant,"zz,zzz,zz9.99")) + 
                                     " para R$ " + TRIM(STRING(tt-crrl640.vltrfuni,"zz,zzz,zz9.99"))                     +
                                     " para o meio de arrecadacaoo " + tt-crrl640.tpmeiarr + " - " + tt-crrl640.dsmeiarr + "." SKIP(1).

    END.

    FOR EACH tt-crrl640 WHERE tt-crrl640.idtpoper = 4 /* Alteração FLOAT */
                              NO-LOCK BREAK BY tt-crrl640.idtpoper
                                            BY tt-crrl640.cdempres
                                            BY tt-crrl640.tpmeiarr.

        IF  FIRST-OF (tt-crrl640.idtpoper) THEN
            DO:
                PUT STREAM str_3 SKIP(2).
                PUT STREAM str_3 UNFORMATTED "ALTERACAO FLOAT".
                PUT STREAM str_3 SKIP(2).
            END.

        IF  LINE-COUNTER(str_3) > (PAGE-SIZE(str_3) - 10) THEN
            PAGE STREAM str_3.
      
        PUT STREAM str_3 UNFORMATTED "Convenio " + tt-crrl640.dsnomcnv + ", codigo SICREDI " + tt-crrl640.cdempres                        +
                                     ", teve o float alterado de " + STRING(tt-crrl640.nrfltant) + " para " + STRING(tt-crrl640.nrdiaflt) +
                                     " dia(s)." SKIP(1).

    END.

    OUTPUT STREAM str_3 CLOSE.
    
    RUN fontes/imprim_unif.p (INPUT glb_cdcooper).

END PROCEDURE.

PROCEDURE cria-reg-crapcon:

    DEF INPUT  PARAM par_cdempcon AS INTE                    NO-UNDO.
    DEF INPUT  PARAM par_flginter AS LOGI                    NO-UNDO.

    CREATE crapcon.
    ASSIGN crapcon.cdcooper = crapcop.cdcooper
           crapcon.cdempcon = par_cdempcon
           crapcon.cdsegmto = INT(crapscn.cdsegmto)
           crapcon.nmrescon = CAPS(crapscn.dssigemp)
           crapcon.nmextcon = CAPS(crapscn.dsnomcnv)
           crapcon.cdhistor = 1154        /* Fixo */
           crapcon.nrdolote = 15000       /* Fixo */
           crapcon.tparrecd = 1
           crapcon.flgacsic = TRUE
           crapcon.flginter = par_flginter.
    VALIDATE crapcon.

END PROCEDURE.
