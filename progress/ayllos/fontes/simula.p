/* .............................................................................

   Programa: Fontes/simula.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Setembro/2011                        Ultima alteracao: 06/12/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Simula -  Simular Grupos economicos
   
   A fazer, quando formar o grupo economico:
   1- "tabela" ou "campo" com lista de empresas que a conta participa, pois 
      quando uma pessoa é removida, basta remontar os grupos das empresas 
      onde ele participa
   2- Tabela de grupos, para alocar todos os registros do grupo economico,
      pois quando uma pessoa estiver excluindo ou incluindo uma nova pessoa,
      nao podera haver outra pessoa fazendo a mesma situacao, pois podera causar
      inconsistencias
      
   ------------------------------
   999 formadora do grupo        
   998 proprietarios/procuradores        
   997 empresas proprietarias  
   996 resp. legal 
     1 primeiro titular        
     2 segunto titular        
     3 terceiro titular        
   ------------------------------
   
   Alteracao : 20/03/2012 - Ajuste para considerar somente as empresas 
                            cujo gncdntj.flgprsoc = true (Adriano).
                            
               02/05/2012 - Versao 2, com solicitacao da area de produtos 
                            (Guilherme)
               
               12/06/2012 - Removido escolha da titularidade (Guilherme),
               
               15/02/2013 - Alterado a chamada da procedure b1wgen0138.p para
                            b1wgen0138_guilherme.p (Adriano).
               
               25/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).    
               
               06/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
               
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0138tt.i }
{ sistema/generico/includes/var_internet.i }

DEF STREAM str_1.

DEF VAR tel_consider AS LOGI FORMAT "Primeiro Titular/Todos Titulares" NO-UNDO.
DEF VAR tel_persocio AS DECI                                           NO-UNDO.
DEF VAR aux_nrcpfcgc LIKE crapass.nrcpfcgc                             NO-UNDO.
DEF VAR aux_nrdgrupo AS INTE                                           NO-UNDO.
DEF VAR aux_nrultgrp AS INTE                                           NO-UNDO.
DEF VAR flg_continue AS LOGICAL                                        NO-UNDO.

DEF VAR tel_cddopcao AS CHAR        FORMAT "!(1)"                      NO-UNDO.

DEFINE VARIABLE aux_vlutiliz AS DECIMAL     NO-UNDO.
DEFINE VARIABLE tel_vlendivi AS DECIMAL     NO-UNDO.
DEFINE VARIABLE tel_dsdrisco AS CHARACTER   NO-UNDO.
DEFINE VARIABLE tel_flgforma AS LOGICAL     NO-UNDO.
DEFINE VARIABLE aux_dtrefere AS DATE        NO-UNDO.
DEFINE VARIABLE aux_innivris AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_nmarquiv AS CHARACTER   NO-UNDO.
DEFINE VARIABLE h-b1wgen0138 AS HANDLE      NO-UNDO.


DEF BUFFER crabass FOR crapass.

FORM WITH ROW 4 OVERLAY SIZE 80 BY 18 TITLE glb_tldatela FRAME f_simula.

FORM tel_persocio AT 05 LABEL "Percentual"   AUTO-RETURN FORMAT "zz9.99"
                        HELP "Informe percentual para calculo."
     /******************
     Nao utilizado mais
     tel_consider AT 25 LABEL "Considerar" AUTO-RETURN
                        HELP "Informe 'P' ou 'T'."
     ********************/
     tel_flgforma AT 25 LABEL "Formar grupos?" AUTO-RETURN FORMAT "SIM/NAO"
                        HELP "Informe SIM para formar e NAO para simular"
     WITH ROW 5 WIDTH 78 CENTERED OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao. 

DEF QUERY q_grupos FOR tt-grupo.
DEF QUERY q_grupos2 FOR crapgrp.
                                     
DEF BROWSE b_grupos QUERY q_grupos 
    DISPLAY tt-grupo.nrdgrupo COLUMN-LABEL "Grupo"    FORMAT "zz,zz9"
            tt-grupo.nrdconta COLUMN-LABEL "Conta"    FORMAT "zzzz,zz9,9"
            tt-grupo.nrctasoc COLUMN-LABEL "Vinculo"  FORMAT "zzzz,zz9,9"
            tt-grupo.nrcpfcgc COLUMN-LABEL "CPF/CNPJ"     
            tt-grupo.idseqttl COLUMN-LABEL "Vinc"     FORMAT "zz9"
            tt-grupo.vlendivi COLUMN-LABEL "Endivid." FORMAT "zz,zzz,zz9.99"
            tt-grupo.dsdrisco COLUMN-LABEL "Risco"    FORMAT "X(2)"
            WITH 10 DOWN.

DEF BROWSE b_grupos2 QUERY q_grupos2
    DISPLAY crapgrp.nrdgrupo COLUMN-LABEL "Grupo"    FORMAT "zz,zz9"
            crapgrp.nrdconta COLUMN-LABEL "Conta"    FORMAT "zzzz,zz9,9"
            crapgrp.nrctasoc COLUMN-LABEL "Vinculo"  FORMAT "zzzz,zz9,9"
            crapgrp.nrcpfcgc COLUMN-LABEL "CPF/CNPJ"     
            crapgrp.idseqttl COLUMN-LABEL "Vinc"     FORMAT "zz9"
            crapgrp.dsdrisco COLUMN-LABEL "Risco"    FORMAT "X(2)"
            WITH 10 DOWN.

DEF FRAME f_grupos  
          b_grupos   HELP  "Pressione <F4> ou <END> p/finalizar" 
          WITH NO-BOX CENTERED OVERLAY ROW 6.

DEF FRAME f_grupos2  
          b_grupos2   HELP  "Pressione <F4> ou <END> p/finalizar" 
          WITH NO-BOX CENTERED OVERLAY ROW 6.

FORM tt-dados-grupo.nrdgrupo  AT 14 LABEL "Grupo" FORMAT "zz,zz9"
     tt-dados-grupo.vlendivi  AT 28 LABEL "Endividamento" FORMAT "zzz,zzz,zz9.99"
     tt-dados-grupo.dsdrisco  AT 58 LABEL "Risco"
     WITH ROW 20 WIDTH 78 CENTERED OVERLAY SIDE-LABELS NO-BOX FRAME f_grupo_detalhe. 

ON ITERATION-CHANGED OF b_grupos DO:  

    FIND FIRST tt-dados-grupo WHERE 
               tt-dados-grupo.cdcooper = glb_cdcooper AND
               tt-dados-grupo.nrdgrupo = tt-grupo.nrdgrupo 
               NO-LOCK NO-ERROR.

    IF  AVAIL tt-dados-grupo THEN
        DISP tt-dados-grupo.nrdgrupo
             tt-dados-grupo.vlendivi
             tt-dados-grupo.dsdrisco
             WITH FRAME f_grupo_detalhe.
    ELSE
        DISP 0 @ tt-dados-grupo.nrdgrupo
             0 @ tt-dados-grupo.vlendivi
             "" @ tt-dados-grupo.dsdrisco
             WITH FRAME f_grupo_detalhe.

END.

ON ITERATION-CHANGED OF b_grupos2 DO:  

    DISP crapgrp.nrdgrupo @ tt-dados-grupo.nrdgrupo
         0 @ tt-dados-grupo.vlendivi
         crapgrp.dsdrisgp @ tt-dados-grupo.dsdrisco
         WITH FRAME f_grupo_detalhe.

END.
     
ASSIGN glb_cddopcao = "C" 
       glb_cdcritic = 0
       tel_persocio = 50.01 
       tel_consider = TRUE.

VIEW FRAME f_simula.
PAUSE(0).

RUN fontes/inicia.p.

DO WHILE TRUE:

    EMPTY TEMP-TABLE tt-grupo.

    HIDE b_grupos IN FRAME f_grupos.
    HIDE b_grupos2 IN FRAME f_grupos2.
    CLEAR FRAME f_grupos.
    CLEAR FRAME f_grupos2.
    CLEAR FRAME f_grupo_detalhe.
    HIDE FRAME f_grupos NO-PAUSE.
    HIDE FRAME f_grupos2 NO-PAUSE.
    HIDE FRAME f_grupo_detalhe NO-PAUSE.
    
    ASSIGN aux_nrdgrupo = 0  
           aux_nrultgrp = 0.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
        tel_flgforma = FALSE.

        UPDATE tel_persocio 
               /*************
               tel_consider 
               ***************/
               tel_flgforma
               WITH FRAME f_opcao.
             
        LEAVE.
      
    END. /* Fim do DO WHILE TRUE */
   
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN     /*   F4 OU FIM   */
    DO:
        RUN fontes/novatela.p.
        
        IF  CAPS(glb_nmdatela) <> "SIMULA"  THEN
        DO:
            HIDE FRAME f_simula.
            HIDE FRAME f_opcao.
            RETURN.
        END.
        ELSE
            NEXT.

    END.

    IF  tel_persocio <= 0  THEN
    DO:
        MESSAGE "% Societario deve ser maior que 0.".
        NEXT.
    END.

    IF  glb_cddepart <> 20  AND  /* TI                   */
        glb_cddepart <> 14  AND  /* PRODUTOS             */
        glb_cddepart <>  8  AND  /* COORD.ADM/FINANCEIRO */
        glb_cddepart <>  9  THEN /* COORD.PRODUTOS       */
    DO:
        MESSAGE "Sem permissao para simular Grupos Economicos!".
        NEXT.

    END.

    IF  tel_flgforma  THEN
    DO:
        IF  glb_cddepart <> 20 THEN /* TI */
        DO:
            MESSAGE "Sem permissao para formar Grupos Economicos, somente simular".
            NEXT.
        END.

        RUN sistema/generico/procedures/b1wgen0138_guilherme.p PERSISTENT SET
            h-b1wgen0138.

        IF  NOT VALID-HANDLE(h-b1wgen0138) THEN
        DO:
            MESSAGE "Handle invalido para b1wgen0138".
            NEXT.
        END.
        
        MESSAGE "Aguarde, efetuando formacao dos grupos economicos ...".
        
        RUN forma_grupo_economico IN h-b1wgen0138(INPUT glb_cdcooper,
                                                  INPUT 1,
                                                  INPUT 1,
                                                  INPUT glb_cdoperad,
                                                  INPUT glb_dtmvtolt,
                                                  INPUT glb_nmdatela,
                                                  INPUT 1,
                                                  INPUT tel_persocio,
                                                  INPUT tel_consider,
                                                 OUTPUT TABLE tt-erro).
    END.
    ELSE
    DO:
        RUN sistema/generico/procedures/b1wgen0138_guilherme.p PERSISTENT SET
            h-b1wgen0138.

        IF  NOT VALID-HANDLE(h-b1wgen0138) THEN
        DO:
            MESSAGE "Handle invalido para b1wgen0138".
            NEXT.
        END.

        MESSAGE "Aguarde, simulando formacao de grupos economicos ...".

        RUN simula_grupo_economico IN h-b1wgen0138(INPUT glb_cdcooper,
                                                   INPUT 1,
                                                   INPUT 1,
                                                   INPUT glb_cdoperad,
                                                   INPUT glb_dtmvtolt,
                                                   INPUT glb_nmdatela,
                                                   INPUT 1,
                                                   INPUT tel_persocio,
                                                   INPUT tel_consider,
                                                  OUTPUT TABLE tt-grupo,
                                                  OUTPUT TABLE tt-dados-grupo,
                                                  OUTPUT TABLE tt-erro).

    END.

    IF  RETURN-VALUE <> "OK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
        IF  AVAIL tt-erro  THEN
            MESSAGE tt-erro.dscritic.
        ELSE
            MESSAGE "Nao foi possivel formar o Grupo Economico".

        DELETE PROCEDURE h-b1wgen0138.

        NEXT.
    END.

    DELETE PROCEDURE h-b1wgen0138.

    HIDE MESSAGE NO-PAUSE.

    IF  tel_flgforma  THEN
    DO:
        IF  NOT CAN-FIND(FIRST crapgrp WHERE 
                               crapgrp.cdcooper = glb_cdcooper NO-LOCK) THEN
        DO:
            MESSAGE "Nenhum grupo foi formado.".
            PAUSE 3 NO-MESSAGE.
            NEXT.
        END.

    END.
    ELSE
    DO:
        IF  NOT CAN-FIND(FIRST tt-grupo NO-LOCK) THEN
        DO:
            MESSAGE "Nenhum grupo foi formado.".
            PAUSE 3 NO-MESSAGE.
            NEXT.
        END.

    END.

    /* inicializa com opção T(Terminal) */
    ASSIGN tel_cddopcao = "T".

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        MESSAGE "Visualizar em (T)ela ou gerar (A)rquivo: " UPDATE tel_cddopcao.
        LEAVE.
    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
        NEXT.

    IF  tel_cddopcao = "T"  THEN
    DO:
        IF  tel_flgforma  THEN
        DO:
            OPEN QUERY q_grupos2 
                 FOR EACH crapgrp WHERE 
                          crapgrp.cdcooper = glb_cdcooper 
                          NO-LOCK BY crapgrp.cdcooper
                                  BY crapgrp.nrdgrupo
                                  BY crapgrp.idseqttl DESC.

            ENABLE b_grupos2 WITH FRAME f_grupos2.
            APPLY "ITERATION-CHANGED" TO b_grupos2.
        END.
        ELSE
        DO:
            OPEN QUERY q_grupos 
                 FOR EACH tt-grupo NO-LOCK BY tt-grupo.cdcooper
                                           BY tt-grupo.nrdgrupo
                                           BY tt-grupo.idseqttl DESC.

            ENABLE b_grupos WITH FRAME f_grupos.
            APPLY "ITERATION-CHANGED" TO b_grupos.
        END.

        WAIT-FOR END-ERROR OF DEFAULT-WINDOW.  

    END.
    ELSE
    IF  tel_cddopcao = "A"  THEN 
    DO:
        MESSAGE "Aguarde, gerando o arquivo ...".
        FIND crapcop WHERE crapcop.cdcooper= glb_cdcooper NO-LOCK NO-ERROR.
        
        ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + "/GE." + STRING(TIME) + "." + crapcop.dsdircop.
        OUTPUT STREAM str_1 TO VALUE(aux_nmarquiv).

        DISP STREAM str_1 "Grupo;Conta;CPF/CNPJ;Vinculo;Endi. Indi.;Risco;Endi. GE;Risco;".
        
        /* Leitura de todos participantes dos grupo para gerar arquivo */
        IF  tel_flgforma  THEN
        DO:
            FOR EACH crapgrp WHERE 
                         crapgrp.cdcooper = glb_cdcooper NO-LOCK
                         BREAK BY crapgrp.cdcooper
                               BY crapgrp.nrdgrupo
                               BY crapgrp.idseqttl DESC:
            
                IF  FIRST-OF(crapgrp.nrdgrupo)  THEN
                DO:
                    FIND FIRST tt-dados-grupo WHERE 
                               tt-dados-grupo.nrdgrupo = crapgrp.nrdgrupo 
                               NO-LOCK NO-ERROR.
    
                    IF  AVAIL tt-dados-grupo  THEN
                        ASSIGN aux_innivris = tt-dados-grupo.vlendivi
                               tel_dsdrisco = tt-dados-grupo.dsdrisco.
                END.
    
                DISP STREAM str_1 
                            crapgrp.nrdgrupo FORMAT "zzz,zz9" NO-LABEL ";" 
                            crapgrp.nrdconta FORMAT "zzzz,zz9,9" NO-LABEL ";" 
                            crapgrp.nrctasoc FORMAT "zzzz,zz9,9" NO-LABEL ";" 
                            crapgrp.nrcpfcgc NO-LABEL ";" 
                            crapgrp.idseqttl FORMAT "zzz9" NO-LABEL ";" 
                            crapgrp.dsdrisco NO-LABEL ";" 
                            crapgrp.dsdrisgp NO-LABEL ";"
                            WITH WIDTH 250.
            END.
        END.    
        ELSE
        DO:
            FOR EACH tt-grupo NO-LOCK
                     BREAK BY tt-grupo.cdcooper
                           BY tt-grupo.nrdgrupo
                           BY tt-grupo.idseqttl DESC:

                IF  FIRST-OF(tt-grupo.nrdgrupo)  THEN
                DO:
                    FIND FIRST tt-dados-grupo WHERE 
                               tt-dados-grupo.nrdgrupo = tt-grupo.nrdgrupo 
                               NO-LOCK NO-ERROR.

                    IF  AVAIL tt-dados-grupo  THEN
                        ASSIGN aux_innivris = tt-dados-grupo.vlendivi
                               tel_dsdrisco = tt-dados-grupo.dsdrisco.
                END.

                DISP STREAM str_1 
                            tt-grupo.nrdgrupo FORMAT "zzz,zz9" NO-LABEL ";" 
                            tt-grupo.nrdconta FORMAT "zzzz,zz9,9" NO-LABEL ";" 
                            tt-grupo.nrctasoc FORMAT "zzzz,zz9,9" NO-LABEL ";" 
                            tt-grupo.nrcpfcgc NO-LABEL ";" 
                            tt-grupo.idseqttl FORMAT "zzz9" NO-LABEL ";" 
                            tt-grupo.vlendivi FORMAT "zz,zzz,zz9.99" NO-LABEL ";" 
                            tt-grupo.dsdrisco NO-LABEL ";" 
                            tt-dados-grupo.vlendivi FORMAT "zz,zzz,zz9.99" NO-LABEL ";" 
                            tt-dados-grupo.dsdrisco NO-LABEL ";"
                            WITH WIDTH 250.
            END.
        END.
        OUTPUT STREAM str_1 CLOSE.
        
        UNIX SILENT VALUE("ux2dos " + aux_nmarquiv + " > " + aux_nmarquiv + ".txt").
        UNIX SILENT VALUE("rm " + aux_nmarquiv).

        HIDE MESSAGE NO-PAUSE.

        MESSAGE "Arquivo gerado: " + aux_nmarquiv + ".txt".
        PAUSE.
    END.
    ELSE 
    DO:
        ASSIGN glb_cdcritic = 14.
        RUN fontes/critic.p.
        BELL.
        MESSAGE glb_dscritic.
        ASSIGN glb_cdcritic = 0.
        NEXT.        
    END.

END. /* Fim do DO WHILE */

/* .......................................................................... */


