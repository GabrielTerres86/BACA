
/* .............................................................................

   Programa: Fontes/atucom.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes          
   Data    : Fevereiro/2004                      Ultima alteracao: 06/11/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Permitir atualizar Movtos COMPEL(Liberacao data  + 1)

   Alteracoes: 24/06/2005 - Alimentado campo cdcooper da tabela craprej e do   
                            buffer crabrej (Diego).

               25/01/2006 - Unificacao dos Bancos - SQLWorks 
               
               02/02/2006 - Gerar log na opcao "A" (Evandro).
               
               18/03/2008 - Permite atualizar movimentos de cheques do 
                            Bancoob (Elton).
               
               28/08/2009 - Substituicao do campo banco/agencia da COMPE, 
                            para o banco/agencia COMPE de CHEQUE (cdagechq e
                            cdbanchq) - (Sidnei - Precise).
              
               03/11/2009 - Incluido na selecao dos arquivos, aqueles que estao
                            presentes no diretorio win12 (Elton).
 
               21/12/2009 - Corrigida opcao "S" para arquivos do mes anterior,
                            obtidos do diretorio win12 (Elton).
                          - Alteracao da variavel tel_cdbanchq de LOG para INT,
                            adequacao do fonte para trabalhar com inteiro e 
                            tratar a opcao CECRED (Guilherme - Precise).
                            
               16/06/2010 - Acertos na Tela para Busca do Arquivo IF 085 (Ze).
               
               17/06/2010 - Alteração na extensão de arquivos de 2 para 3 
                            posições (Jonatas/Supero).
                            
               18/04/2011 - Transferido de atucom.p para atucomp.p
                          - Reestrutura da tela
                          - Opcao "S" utilizada para selecionar os cheques a 
                            serem alterados/gerados na opcao "A"
                          - Opcao "A" Gerar o arquivo de cheques alterado a
                            crapdpb e crapchd (Guilherme)
                            
               18/05/2011 - Confirmacao para finalizar a captura de cheques.
                            (Fabricio) 
                            
               02/06/2011 - Ajustes na tela pelo motivo da truncagem (Ze).
               
               21/09/2011 - Tratamento para a Rotina 66 - LANCHQ (Ze).
               
               27/12/2011 - Alterado tt-craprej.flgdepos de False p/ True (Ze).
               
               16/04/2012 - Fonte substituido por atucomp.p (Tiago)
               
               15/10/2012 - Correção erro de opção sugerir C após chamada da
                            tela ajuda (Daniel).
                            
               28/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
                            
               28/11/2013 - Inclusao de VALIDATE gncpchq (Carlos)
               
               24/12/2013 - Trocar critica 15 Agencia nao cadastrada por 
                            962 PA nao cadastrado (Gielow)
                            
               15/05/2014 - Alterado para não atualizar o campo crapdpb.dtliblan
                            a cada cheque quando for necessario gerar o
                            arquivo da compe novamente e sim apenas a cada
                            lancamento de um grupo de cheques pois estava
                            ocorrendo divergencia de datas de liberacao
                            quando era utilizado a tela ATUCOM 
                            (Tiago/Diego SD157994).
                            
               22/07/2014 - Alterado procedure gerar_compel_atucom para tratar
                            deposito intercooperativa. (Reinert)
                            
               06/11/2014 - Gerando log nas operações da tela. (Kelvin)
............................................................................. */

 { includes/var_online.i }
   
DEF STREAM str_1.
 
DEF TEMP-TABLE tt-craprej                                          NO-UNDO
    LIKE craprej
    FIELD flgdepos AS LOGICAL
    FIELD cdcmpchq LIKE crapchd.cdcmpchq
    FIELD cdbanchq LIKE crapchd.cdbanchq
    FIELD cdagechq LIKE crapchd.cdagechq
    FIELD nrctachq LIKE crapchd.nrctachq
    FIELD nrcheque LIKE crapchd.nrcheque.

DEF TEMP-TABLE tt-crapdpb LIKE crapdpb.

DEF        VAR tel_cdagenci AS INT    FORMAT "zz9"                   NO-UNDO.
DEF        VAR tel_dtrefere AS DATE   FORMAT "99/99/9999"            NO-UNDO.
DEF        VAR aux_data     AS DATE                                  NO-UNDO.
DEF        VAR tel_cdbanchq AS INT    FORMAT "999"                   NO-UNDO.

DEF        VAR aux_dsdocmc7 LIKE crapchd.dsdocmc7                    NO-UNDO.
DEF        VAR aux_cdcmpchq LIKE crapchd.cdcmpchq                    NO-UNDO.
DEF        VAR aux_cdbanchq LIKE crapchd.cdbanchq                    NO-UNDO.
DEF        VAR aux_cdagechq LIKE crapchd.cdagechq                    NO-UNDO.
DEF        VAR aux_nrctachq LIKE crapchd.nrctachq                    NO-UNDO.
DEF        VAR aux_nrcheque LIKE crapchd.nrcheque                    NO-UNDO.
DEF        VAR tel_cdcmpchq AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_cdagechq AS INT     FORMAT "zzz9"                 NO-UNDO.
DEF        VAR tel_nrddigc1 AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR tel_nrctachq AS DECIMAL FORMAT "zzz,zzz,zzz,9"        NO-UNDO.
DEF        VAR tel_nrctabdb AS DECIMAL FORMAT "zzz,zzz,zzz,9"        NO-UNDO.
DEF        VAR tel_nrddigc2 AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR tel_nrcheque AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tel_nrddigc3 AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR tel_vlcheque AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR tel_nrseqdig AS INT     FORMAT "zz,zz9"               NO-UNDO.
                                                                    
DEF        VAR tel_nrddigv1 AS INT                                   NO-UNDO.
DEF        VAR tel_nrddigv2 AS INT                                   NO-UNDO.
DEF        VAR tel_nrddigv3 AS INT                                   NO-UNDO.

DEF        VAR aux_nrdconta LIKE crapchd.nrdconta                    NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR   FORMAT "!"                     NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqres AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqdat AS CHAR   FORMAT "x(20)"                 NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.  
DEF        VAR aux_nmarqw12 AS CHAR   FORMAT "x(20)"                 NO-UNDO.  
DEF        VAR tel_dsdocmc7 AS CHAR   FORMAT "x(34)"                 NO-UNDO.

DEF        VAR aux_qtarquiv AS INT                                   NO-UNDO.
DEF        VAR aux_totregis AS INT                                   NO-UNDO.
DEF        VAR aux_vlrtotal AS DEC                                   NO-UNDO.

DEF        VAR aux_dsmessag AS CHAR                                  NO-UNDO.

DEF        VAR aux_cdopcao1 AS CHAR                                  NO-UNDO.

DEF        VAR aux_lsvalido AS CHAR INIT
 "1,2,3,4,5,6,7,8,9,0,G,<,>,:,RETURN,F4,F8,DEL,CURSOR-LEFT,CURSOR-RIGHT,BACKSPACE"
                                                                     NO-UNDO.
DEF        VAR aux_lsdigctr AS CHAR                                  NO-UNDO.

DEF BUFFER b-crapcop FOR crapcop.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT 3 LABEL "Opcao" AUTO-RETURN
                HELP "Informe a opcao desejada (A,S)."
                VALIDATE(CAN-DO("A,S",glb_cddopcao),
                             "014 - Opcao errada.")
     tel_cdagenci AT 16 LABEL "PA"
                        HELP "Entre com o numero do PA"
     tel_dsdocmc7 AT 35 LABEL "CMC-7"
                        HELP "Passe o cheque pela leitora."
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_atucom.


FORM tt-craprej.cdcmpchq FORMAT "zz9"              COLUMN-LABEL "Comp"    AT 03
     tt-craprej.cdbanchq FORMAT "zz9"              COLUMN-LABEL "Banco"   AT 10
     tt-craprej.cdagechq FORMAT "zzz9"             COLUMN-LABEL "Agencia" AT 16
     tt-craprej.nrctachq FORMAT "zz,zzz,zzz,zzz,9" COLUMN-LABEL "Conta"   AT 25
     tt-craprej.nrcheque FORMAT "zzz,zz9"          COLUMN-LABEL "Cheque"  AT 44
     tt-craprej.vllanmto FORMAT "zzz,zzz,zz9.99"   COLUMN-LABEL "Valor"   AT 54
     tt-craprej.nrseqdig FORMAT "z,zz9"            COLUMN-LABEL "Seq."    AT 71
     WITH ROW 09 COLUMN 2 OVERLAY NO-BOX 10 DOWN FRAME f_lancto.

ASSIGN glb_cddopcao = "S"
       glb_cdcritic = 0
       tel_dtrefere = glb_dtmvtoan.

VIEW FRAME f_moldura.
PAUSE(0).

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper 
             NO-LOCK NO-ERROR.
   
ASSIGN tel_nrseqdig = 0.

EMPTY TEMP-TABLE tt-craprej.

DO WHILE TRUE:

     IF glb_cddopcao <> "C" THEN
         ASSIGN aux_cdopcao1 = glb_cddopcao.

     RUN fontes/inicia.p.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        IF  glb_cdcritic > 0   THEN
            DO:
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                glb_cdcritic = 0.
            END.

            IF  glb_cddopcao = "C" THEN 
                DO:
                   ASSIGN glb_cddopcao = aux_cdopcao1. 
                   LEAVE.
               END.

           UPDATE glb_cddopcao  WITH FRAME f_atucom.

       LEAVE.
    
    END.  /*  Fim do DO WHILE TRUE  */

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
         DO:
            RUN fontes/novatela.p.
               
            IF   CAPS(glb_nmdatela) <> "ATUCOM"  THEN
                 DO:
                    HIDE FRAME f_atucom.
                    HIDE FRAME f_moldura.
                    RETURN.
                 END.
            ELSE
                 NEXT.
         END.

    IF   aux_cddopcao <> glb_cddopcao THEN
         DO:
             { includes/acesso.i }
             aux_cddopcao = glb_cddopcao.
         END.

    ASSIGN glb_dscritic = "".

    HIDE MESSAGE NO-PAUSE.

    IF   glb_cddopcao = "S"   THEN      /*  Selecionar Arquivos */
         DO:
            EMPTY TEMP-TABLE tt-craprej.
            
            HIDE FRAME f_lancto NO-PAUSE.
               
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:               
                IF   glb_cdcritic > 0   THEN
                     DO:
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         ASSIGN glb_cdcritic = 0
                                glb_dscritic = "".
                     END.
                ELSE
                IF   glb_dscritic <> ""  THEN
                     DO:
                         BELL.
                         MESSAGE glb_dscritic.
                         ASSIGN glb_cdcritic = 0
                                glb_dscritic = "".
                     END.
               
                UPDATE tel_cdagenci WITH FRAME f_atucom.
        
                IF   tel_cdagenci = 0  THEN
                     DO:
                         glb_cdcritic = 962. /* PA nao cadastrado */
                         NEXT.
                     END.
                    
                FIND crapage WHERE crapage.cdcooper = glb_cdcooper  AND
                                   crapage.cdagenci = tel_cdagenci  
                                   NO-LOCK NO-ERROR.
                                   
                IF   NOT AVAIL crapage THEN
                     DO:
                         glb_cdcritic = 962. /* PA nao cadastrado */
                         NEXT.
                     END.
                ELSE
                     LEAVE.
            END.
            
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN     
                 NEXT.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    IF   glb_cdcritic > 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        ASSIGN glb_cdcritic = 0
                               glb_dscritic = "".
                    END.
                    ELSE
                    IF   glb_dscritic <> ""  THEN
                    DO:
                        BELL.
                        MESSAGE glb_dscritic.
                        ASSIGN glb_cdcritic = 0
                               glb_dscritic = "".
                    END.

                    UPDATE tel_dsdocmc7 WITH FRAME f_atucom
                 
                    EDITING:
                        
                        READKEY.
                       
                        IF   NOT CAN-DO(aux_lsvalido,KEYLABEL(LASTKEY))   THEN
                        DO:
                            glb_cdcritic = 666.
                            NEXT.
                        END.
           
                        IF   KEYLABEL(LASTKEY) = "G"   THEN
                            APPLY KEYCODE(":").
                        ELSE
                            APPLY LASTKEY.
                                 
                    END. /*  Fim do EDITING  */
                    
                    HIDE MESSAGE NO-PAUSE.
                    
                    IF   TRIM(tel_dsdocmc7) <> ""   THEN
                    DO:
                        IF   LENGTH(tel_dsdocmc7) <> 34            OR
                             SUBSTRING(tel_dsdocmc7,01,1) <> "<"   OR
                             SUBSTRING(tel_dsdocmc7,10,1) <> "<"   OR
                             SUBSTRING(tel_dsdocmc7,21,1) <> ">"   OR
                             SUBSTRING(tel_dsdocmc7,34,1) <> ":"   THEN
                             DO:
                                 glb_cdcritic = 666.
                                 NEXT.
                             END.
                
                        RUN fontes/dig_cmc7.p (INPUT  tel_dsdocmc7,
                                               OUTPUT glb_nrcalcul,
                                               OUTPUT aux_lsdigctr).
                          
                        IF   glb_nrcalcul > 0                 OR
                             NUM-ENTRIES(aux_lsdigctr) <> 3   THEN
                             DO:
                                 glb_cdcritic = 666.
                                 NEXT.
                             END.
        
                        RUN valida_dados.
                             
                        IF   glb_cdcritic > 0   THEN
                             NEXT.
                    END.
                    ELSE
                    DO:
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
                            RUN fontes/cmc7.p (OUTPUT tel_dsdocmc7).
                                
                            IF   LENGTH(tel_dsdocmc7) <> 34   THEN
                                LEAVE.
        
                            RUN fontes/dig_cmc7.p (INPUT  tel_dsdocmc7,
                                                   OUTPUT glb_nrcalcul,
                                                   OUTPUT aux_lsdigctr).
                                                       
                            IF   glb_nrcalcul > 0                 OR
                                NUM-ENTRIES(aux_lsdigctr) <> 3   THEN
                            DO:
                                glb_cdcritic = 666.
                                NEXT.
                            END.
                                  
                            DISPLAY tel_dsdocmc7 WITH FRAME f_atucom.
                             
                            RUN valida_dados.
                                
                            IF   glb_cdcritic > 0   THEN
                                NEXT.
        
                            LEAVE.
                           
                        END.  /*  Fim do DO WHILE TRUE  */
                          
                        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
                            NEXT.
                    END.                  
                    

                    IF   glb_cdcritic > 0   THEN
                        NEXT.

                    IF   tel_cdbanchq = crapcop.cdbcoctl AND
                         tel_cdagechq = crapcop.cdagectl THEN
                    DO:
                        MESSAGE 
                        "Cheques da propria Cooperativa nao sao digitalizados.".
                        PAUSE 10 NO-MESSAGE.
                        NEXT.
                    END.
               
                    IF   CAN-FIND(FIRST tt-craprej WHERE
                                        tt-craprej.cdcooper = glb_cdcooper AND
                                       tt-craprej.dshistor = tel_dsdocmc7) THEN
                    DO:
                        glb_cdcritic = 318.
                        NEXT.
                    END.

                    RUN mostra_dados.
               
                    IF   glb_cdcritic > 0   OR 
                         glb_dscritic <> "" THEN
                        NEXT.               

                END.

                IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                DO:
                    ASSIGN aux_confirma = "N".

                    MESSAGE "Deseja finalizar a captura de cheques? (S/N):"                                  
                    
                    UPDATE aux_confirma.

                    IF   aux_confirma = "S"  THEN 
                        LEAVE.
                END.

            END. /* fim do DO WHILE dsdocmc7 */

         END.

    IF   glb_cddopcao = "A"   THEN      /*  atualizar movto e gerar arquivo */
         DO:
             HIDE FRAME f_lancto NO-PAUSE.

             PAUSE(0).

             FIND FIRST tt-craprej WHERE tt-craprej.cdcooper = glb_cdcooper 
                                         NO-LOCK NO-ERROR.
        
             IF   NOT AVAIL tt-craprej THEN
                  DO: 
                      glb_cdcritic = 244.
                      NEXT.
                  END.
            
             ASSIGN tel_cdagenci = tt-craprej.cdagenci.

             DISPLAY tel_cdagenci WITH FRAME f_atucom.
                   
             ASSIGN aux_confirma = "N".
            
             MESSAGE "Confirma atualizacao? (S/N)" UPDATE aux_confirma.

             IF   aux_confirma = "S"  THEN 
                  DO:
                      MESSAGE  
                      "Aguarde! Atualizando movimento(s) e gerando arquivo ...".

                      RUN gerar_compel_atucom(INPUT  glb_dtmvtolt,
                                              INPUT  glb_cdcooper,
                                              INPUT  tel_cdagenci,
                                              INPUT  glb_cdoperad,
                                              OUTPUT glb_cdcritic,
                                              OUTPUT aux_qtarquiv,
                                              OUTPUT aux_totregis,
                                              OUTPUT aux_vlrtotal).

                      HIDE MESSAGE NO-PAUSE.

                      IF   glb_cdcritic <> 0  THEN
                           NEXT.
            
                      MESSAGE 
                        "Foi(ram) gravado(s) " + TRIM(STRING(aux_qtarquiv)) +
                        " arquivo(s) - com o valor total: " + 
                        TRIM(STRING(aux_vlrtotal / 100,"zzz,zzz,zz9.99")).
                        
                      EMPTY TEMP-TABLE tt-craprej.
                  END.
             ELSE
                  DO:
                      glb_cdcritic = 79.
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      ASSIGN glb_cdcritic = 0
                             glb_dscritic = "".
                  END.
            
         END.

END.  /*  Fim do DO WHILE TRUE  */

/*  ........................................................................ */

PROCEDURE valida_dados:

    glb_cdcritic = 666.

    tel_cdbanchq = INT(SUBSTRING(tel_dsdocmc7,02,03)) NO-ERROR.
    
    IF   ERROR-STATUS:ERROR   THEN
         RETURN.
    
    tel_cdagechq = INT(SUBSTRING(tel_dsdocmc7,05,04)) NO-ERROR.
 
    IF   ERROR-STATUS:ERROR   THEN
         RETURN.
     
    tel_cdcmpchq = INT(SUBSTRING(tel_dsdocmc7,11,03)) NO-ERROR.

    IF   ERROR-STATUS:ERROR   THEN
         RETURN.
 
    tel_nrcheque = INT(SUBSTRING(tel_dsdocmc7,14,06)) NO-ERROR.
    
    IF   ERROR-STATUS:ERROR   THEN
         RETURN.
 
    tel_nrctachq = DECIMAL(SUBSTRING(tel_dsdocmc7,23,10)) NO-ERROR.

    IF   ERROR-STATUS:ERROR   THEN
         RETURN.

    tel_nrctabdb = IF   tel_cdbanchq = 1 THEN
                        DECIMAL(SUBSTRING(tel_dsdocmc7,25,08))
                   ELSE DECIMAL(SUBSTRING(tel_dsdocmc7,23,10)) NO-ERROR.

    IF   ERROR-STATUS:ERROR   THEN
         RETURN.
     
    glb_cdcritic = 0.
    
    /*  Calcula primeiro digito de controle  */
                  
    glb_nrcalcul = DECIMAL(STRING(tel_cdcmpchq,"999") +
                           STRING(tel_cdbanchq,"999") +
                           STRING(tel_cdagechq,"9999") + "0").
                                  
    RUN fontes/digfun.p.
                  
    tel_nrddigc1 = INT(SUBSTRING(STRING(glb_nrcalcul),
                                 LENGTH(STRING(glb_nrcalcul)))).    
                   
    /*  Calcula segundo digito de controle  */

    glb_nrcalcul = tel_nrctachq * 10.
                                         
    RUN fontes/digfun.p.
                  
    tel_nrddigc2 = INT(SUBSTRING(STRING(glb_nrcalcul),
                                 LENGTH(STRING(glb_nrcalcul)))).    
 
    /*  Calcula terceiro digito de controle  */

    glb_nrcalcul = tel_nrcheque * 10.
                                         
    RUN fontes/digfun.p.
                  
    tel_nrddigc3 = INT(SUBSTRING(STRING(glb_nrcalcul),
                          LENGTH(STRING(glb_nrcalcul)))).    
                       
    /*  Verifica se o banco existe .......................................... */
    
    FIND crapban WHERE crapban.cdbccxlt = tel_cdbanchq NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapban   THEN
         DO:
             glb_cdcritic = 57.
             RETURN.
         END.

    /*  Verifica se a agencia existe ........................................ */

    FIND crapagb WHERE crapagb.cddbanco = tel_cdbanchq AND
                       crapagb.cdageban = tel_cdagechq NO-LOCK NO-ERROR.
                       
    IF   NOT AVAILABLE crapagb   THEN
         DO:
             glb_cdcritic = 15.
             RETURN.
         END.
    
END PROCEDURE.

PROCEDURE mostra_dados:

    DEFINE VARIABLE aux_flgdepos AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE aux_dscooper AS CHAR        NO-UNDO.

    FIND crapchd WHERE crapchd.cdcooper = glb_cdcooper  AND 
                       crapchd.dtmvtolt = tel_dtrefere  AND
                       crapchd.cdcmpchq = tel_cdcmpchq  AND
                       crapchd.cdbanchq = tel_cdbanchq  AND
                       crapchd.cdagechq = tel_cdagechq  AND
                       crapchd.nrctachq = tel_nrctachq  AND
                       crapchd.nrcheque = tel_nrcheque  
                       NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapchd THEN
         DO:
             glb_cdcritic = 99.
             RETURN.
         END.

    /* So aceitar cheques depositados no pa informado na tela */
    IF   crapchd.cdagenci <> tel_cdagenci  THEN
         DO:
             glb_dscritic = "Obrigatoriamente cheque deve ter sido" + 
                            " depositado no PA informado.".
             RETURN.
         END.

    IF   crapchd.cdbccxlt = 700  THEN   /* Criticar Desconto de Cheques */
         DO:
             glb_cdcritic = 811.
             RETURN.
         END.

    IF   crapchd.cdbccxlt = 600  THEN   /* Criticar Custodia */
         DO:
             glb_cdcritic = 757.
             RETURN.
         END.

    IF   crapchd.cdbccxlt = 500    OR   /* Desprezar Lanchq */
         crapchd.nrdconta = 85448  OR   /* COOPER           */
        (crapchd.cdbccxlt = 11     AND
         crapchd.nrdolote > 30000  AND  /* Cheques da Rotina 66 - Lanchq */
         crapchd.nrdolote < 30999) THEN
         ASSIGN aux_flgdepos = FALSE.
    ELSE
         DO:
             ASSIGN aux_flgdepos = TRUE.             

             IF crapchd.nrdconta = 0 AND crapchd.nrctadst <> 0 THEN /* Depósito intercoop. */
                DO:
                    FIND b-crapcop WHERE b-crapcop.cdagectl = crapchd.cdagedst NO-LOCK NO-ERROR.
                    
                    ASSIGN aux_nrdconta = crapchd.nrctadst.    
                    FIND crapdpb WHERE crapdpb.cdcooper = b-crapcop.cdcooper AND
                                       crapdpb.dtmvtolt = crapchd.dtmvtolt   AND
                                       crapdpb.cdagenci = 1                  AND
                                       crapdpb.cdbccxlt = 100                AND
                                       crapdpb.nrdolote = 10118              AND
                                       crapdpb.nrdconta = crapchd.nrctadst   AND
                                       crapdpb.nrdocmto = crapchd.nrdocmto  NO-LOCK
                                       USE-INDEX crapdpb1 NO-ERROR.

                END.
             ELSE
                DO:
                    ASSIGN aux_nrdconta = crapchd.nrdconta.
                    FIND crapdpb WHERE crapdpb.cdcooper = glb_cdcooper      AND
                                       crapdpb.dtmvtolt = crapchd.dtmvtolt  AND
                                       crapdpb.cdagenci = crapchd.cdagenci  AND
                                       crapdpb.cdbccxlt = crapchd.cdbccxlt  AND
                                       crapdpb.nrdolote = crapchd.nrdolote  AND
                                       crapdpb.nrdconta = crapchd.nrdconta  AND
                                       crapdpb.nrdocmto = crapchd.nrdocmto  NO-LOCK
                                       USE-INDEX crapdpb1 NO-ERROR.
                END.
    
             IF   NOT AVAIL crapdpb  THEN  /* Verificar se Deposito Liberado */
                  DO: 
                      FIND craplcm WHERE 
                                   craplcm.cdcooper = glb_cdcooper      AND
                                   craplcm.dtmvtolt = crapchd.dtmvtolt  AND
                                   craplcm.cdagenci = crapchd.cdagenci  AND
                                   craplcm.cdbccxlt = crapchd.cdbccxlt  AND
                                   craplcm.nrdolote = crapchd.nrdolote  AND
                                   craplcm.nrdctabb = aux_nrdconta      AND
                                   craplcm.nrdocmto = crapchd.nrdocmto 
                                   USE-INDEX craplcm1 NO-LOCK NO-ERROR.
    
                      IF   NOT AVAIL craplcm OR
                           craplcm.cdhistor <> 372 THEN  /* Deposito Liberado */
                           DO:    
                               glb_cdcritic = 82. /* Lanc.Bloq.nao Encontrado */
                               ASSIGN aux_flgdepos = FALSE.
                           END.
                      ELSE
                           ASSIGN aux_flgdepos = FALSE. /* Deposito ja Lib. */
                  END. 
         END.

    /* Movtos que serao atualizados */

    CREATE tt-craprej. 
    ASSIGN tt-craprej.dshistor = tel_dsdocmc7
           tt-craprej.vllanmto = crapchd.vlcheque
           tt-craprej.cdagenci = crapchd.cdagenci
           tt-craprej.dtmvtolt = crapchd.dtmvtolt
           tt-craprej.cdbccxlt = crapchd.cdbccxlt
           tt-craprej.nrdolote = crapchd.nrdolote
           tt-craprej.nrdconta = aux_nrdconta
           tt-craprej.nrdocmto = crapchd.nrdocmto
           tt-craprej.cdcmpchq = crapchd.cdcmpchq
           tt-craprej.cdbanchq = crapchd.cdbanchq
           tt-craprej.cdagechq = crapchd.cdagechq
           tt-craprej.nrctachq = crapchd.nrctachq
           tt-craprej.nrcheque = crapchd.nrcheque
           tt-craprej.cdcooper = glb_cdcooper
           tt-craprej.flgdepos = aux_flgdepos
           tt-craprej.nrseqdig = tel_nrseqdig + 1
           tel_nrseqdig        = tel_nrseqdig + 1.
                                      

    FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapcop THEN
         DO:
             glb_cdcritic = 651.
             RETURN.
         END.
          
    ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".
    
    UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                      " " + STRING(TIME,"HH:MM:SS") +
                      " '-->'  Operador - " + STRING(glb_cdoperad) +
                      " Utilizou a opcao S para selecionar o cheque: Conta: " + STRING(tt-craprej.nrdconta) +
                      ", PA: " + STRING(tt-craprej.cdagenci,"zz9") +
                      ", Valor: " + STRING(tt-craprej.vllanmto,"zzz,zzz,zz9.99") +
                      ", Cheque: " + STRING(tt-craprej.nrcheque) +
                      ", Historico: '" + STRING(tt-craprej.dshistor) + "'" +
                      " >> " + aux_dscooper + "log/atucom.log").

    FIND CURRENT tt-craprej NO-LOCK.

    RELEASE tt-craprej.

    ASSIGN tel_dsdocmc7 = "".

    DISPLAY tel_dsdocmc7 WITH FRAME f_atucom.

    CLEAR FRAME f_lancto ALL.
    
    aux_contador = 0.
    
    FOR EACH tt-craprej NO-LOCK BY tt-craprej.nrseqdig DESC:
    
        aux_contador = aux_contador + 1.
        
        /*  Mostra os dados lidos  */
        DISPLAY tt-craprej.cdcmpchq   tt-craprej.cdbanchq
                tt-craprej.cdagechq   tt-craprej.nrctachq
                tt-craprej.nrcheque   tt-craprej.vllanmto   
                tt-craprej.nrseqdig   WITH FRAME f_lancto.

        DOWN WITH FRAME f_lancto.
        
        IF   aux_contador = 10 THEN
             LEAVE.
    END.
    
     
END PROCEDURE.

/* Procedure baseada na gerar_compel da b1wgen0012.p */
PROCEDURE gerar_compel_atucom:

    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM ret_cdcritic AS INT                               NO-UNDO.
    DEF OUTPUT PARAM ret_qtarquiv AS INT                               NO-UNDO. 
    DEF OUTPUT PARAM ret_totregis AS INT                               NO-UNDO.
    DEF OUTPUT PARAM ret_vlrtotal AS DEC                               NO-UNDO.
    
    DEF VAR          aux_mes      AS CHAR                              NO-UNDO.
    DEF VAR          glb_nrcalcul AS DEC                               NO-UNDO.
    DEF VAR          glb_dsdctitg AS CHAR                              NO-UNDO.
    DEF VAR          glb_stsnrcal AS LOGICAL                           NO-UNDO.
    DEF VAR          aux_flgerror AS LOGICAL                           NO-UNDO.
    DEF VAR          aux_nrseqarq AS INT                               NO-UNDO.
    DEF VAR          aux_nmarqdat AS CHAR   FORMAT "x(20)"             NO-UNDO.
    DEF VAR          aux_totqtchq AS INT                               NO-UNDO.
    DEF VAR          aux_totvlchq AS DECIMAL                           NO-UNDO.
    DEF VAR          aux_cdsituac AS INT                               NO-UNDO.
    DEF VAR          aux_nrdahora AS INT                               NO-UNDO.
    DEF VAR          aux_cdcomchq AS INT                               NO-UNDO.
    
    DEF VAR          aux_nrprevia AS INT    INIT 0                     NO-UNDO.
    DEF VAR          aux_hrprevia AS INT    INIT 0                     NO-UNDO.
    DEF VAR          aux_exetrunc AS LOGI   INIT NO                    NO-UNDO.
    DEF VAR          aux_dschqctl AS CHAR                              NO-UNDO.
    
    DEF VAR          aux_nrctachq AS CHAR   FORMAT "x(12)"             NO-UNDO.

    DEF VAR          aux_retorno  AS CHAR                              NO-UNDO.
    DEF VAR          aux_dscooper AS CHAR                              NO-UNDO.
    DEF VAR          aux_dsdirmic AS CHAR                              NO-UNDO.
    DEF VAR          aux_dscomand AS CHAR                              NO-UNDO.

    DEF VAR          aux_cdagedst LIKE crapchd.cdagedst                NO-UNDO.
    DEF VAR          aux_flgdepin AS LOGICAL                           NO-UNDO.

    DEF BUFFER crabage FOR crapage.
    DEF BUFFER crabchd FOR crapchd.
    
    ASSIGN aux_flgerror = FALSE
           aux_retorno  = "".
    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapcop THEN
         DO:
             ret_cdcritic = 651.
             RETURN.
         END.

    FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                       crapage.cdagenci = par_cdagenci NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapage THEN
         DO:
             ret_cdcritic = 962.
             RETURN.
         END.

    ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".
    
    FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "GENERI"       AND
                       craptab.cdempres = 0              AND
                       craptab.cdacesso = "EXETRUNCAGEM" AND
                       craptab.tpregist = par_cdagenci   NO-LOCK NO-ERROR.
                       
    IF   NOT AVAIL craptab THEN
         aux_exetrunc = NO.
    ELSE
         aux_exetrunc = IF   craptab.dstextab = "NAO" THEN 
                             NO 
                        ELSE YES.
                       
    IF   NOT aux_exetrunc THEN       
         DO:
             ret_cdcritic = 782.
             RETURN.
         END.

    /*** BUSCA PASTA DE DESTINO **/
    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 0            AND
                       craptab.cdacesso = "MICROTRUNC" AND
                       craptab.tpregist = par_cdagenci NO-LOCK NO-ERROR.
                  
    IF   NOT AVAIL craptab THEN
         aux_dsdirmic = "".
    ELSE
         aux_dsdirmic = craptab.dstextab.

    IF   aux_dsdirmic = "" THEN
         DO:
             ret_cdcritic = 782.
             RETURN.
         END.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "USUARI"      AND
                       craptab.cdempres = 11            AND
                       craptab.cdacesso = "MAIORESCHQ"  AND
                       craptab.tpregist = 01 NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE craptab   THEN
         DO:
             ret_cdcritic = 55.
             RETURN.
         END.
    
    ASSIGN aux_nrprevia = 0. 

    FOR EACH crapchd  WHERE crapchd.cdcooper  = par_cdcooper AND
                            crapchd.dtmvtolt  = par_dtmvtolt AND
                            crapchd.cdagenci  = par_cdagenci
                            NO-LOCK BY crapchd.nrprevia:
    
       ASSIGN aux_nrprevia = crapchd.nrprevia. 
    
    END.
   
    ASSIGN aux_nrprevia = aux_nrprevia + 1
           aux_hrprevia = TIME
           aux_nrseqarq = 1.

    /*             Nome Arquivo  
       atucom-001-20101203.001
       atucom            - string identificador
       001               - PA
       20101203          - Data Mvto. (AAAAMMDD)
       .
       001               - Nr. da Previa */
 
    aux_nmarqdat = "atucom-" +
                   STRING(par_cdagenci,"999") + "-" +
                   STRING(YEAR(par_dtmvtolt),"9999") +
                   STRING(MONTH(par_dtmvtolt),"99")  +
                   STRING(DAY(par_dtmvtolt),"99") + "." +
                   STRING(aux_nrprevia,"999").
     
    IF   SEARCH(aux_dscooper + "arq/" + aux_nmarqdat) <> ? THEN
         DO: 
             BELL.
             HIDE MESSAGE NO-PAUSE.
             MESSAGE "Arquivo ja existe:" aux_nmarqdat.
             ret_cdcritic = 459.
             RETURN.
         END.

    OUTPUT STREAM str_1 TO VALUE(aux_dscooper + "arq/" + aux_nmarqdat).

    PUT STREAM str_1  FILL("0",47)        FORMAT "x(47)"
                      "CEL605"            
                      crapage.cdcomchq    FORMAT "999"
                      "0001"              /* VERSAO */
                      crapcop.cdbcoctl    FORMAT "999"
                      crapcop.nrdivctl    FORMAT "9"   /* DV */
                      "2"                 /* Ind. Remes */
                      YEAR(par_dtmvtolt)  FORMAT "9999"
                      MONTH(par_dtmvtolt) FORMAT "99"
                      DAY(par_dtmvtolt)   FORMAT "99"
                      FILL(" ",77)        FORMAT "x(77)"
                      aux_nrseqarq        FORMAT "9999999999"
                      SKIP.

    ASSIGN aux_totqtchq = 0
           aux_totvlchq = 0.

    EMPTY TEMP-TABLE tt-crapdpb.  

    TRANS_1:
    DO TRANSACTION ON ERROR UNDO:

       FOR EACH tt-craprej NO-LOCK,
          FIRST crapchd WHERE crapchd.cdcooper = tt-craprej.cdcooper  AND 
                              crapchd.dtmvtolt = tt-craprej.dtmvtolt  AND
                              crapchd.cdcmpchq = tt-craprej.cdcmpchq  AND
                              crapchd.cdbanchq = tt-craprej.cdbanchq  AND
                              crapchd.cdagechq = tt-craprej.cdagechq  AND
                              crapchd.nrctachq = tt-craprej.nrctachq  AND
                              crapchd.nrcheque = tt-craprej.nrcheque  
                              NO-LOCK,
          FIRST crapage WHERE crapage.cdcooper  = crapchd.cdcooper    AND
                              crapage.cdagenci  = crapchd.cdagenci    AND
                              crapage.cdbanchq  = crapcop.cdbcoctl
                              NO-LOCK:

           ASSIGN aux_nrseqarq = aux_nrseqarq + 1.

           /*  Identifica se o cheque eh da propria cooperativa  */
       
           FIND crapfdc WHERE crapfdc.cdcooper = crapchd.cdcooper AND
                              crapfdc.cdbanchq = crapchd.cdbanchq AND
                              crapfdc.cdagechq = crapchd.cdagechq AND
                              crapfdc.nrctachq = crapchd.nrctachq AND
                              crapfdc.nrcheque = crapchd.nrcheque
                              USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
       
           IF   AVAILABLE crapfdc THEN
                DO:
                    ASSIGN aux_dschqctl = "PG_CX ".
                
                    IF   crapchd.cdbanchq = 1    AND
                         crapchd.cdagechq = 3420 THEN
                         ASSIGN aux_nrctachq = "0070" +    /* Grupo SETEC */
                                         STRING(crapchd.nrctachq,"99999999").
                    ELSE
                         aux_nrctachq = STRING(crapchd.nrctachq,"999999999999").
                END.
           ELSE
                ASSIGN aux_dschqctl = FILL(" ",6)
                       aux_nrctachq = STRING(crapchd.nrctachq,"999999999999").

           IF   crapchd.cdagedst <> 0 THEN /* Deposito intercooperativa */
                ASSIGN aux_cdagedst = crapchd.cdagedst
                       aux_flgdepin = TRUE.
           ELSE
                ASSIGN aux_cdagedst = crapcop.cdagectl
                       aux_flgdepin = FALSE.


           PUT STREAM str_1
               crapchd.cdcmpchq         FORMAT "999"          /* COMPE */
               crapchd.cdbanchq         FORMAT "999"          /* BANCO DEST */
               crapchd.cdagechq         FORMAT "9999"         /* AGEN. DEST */
               crapchd.nrddigv2         FORMAT "9"            /* DV 2 */
               aux_nrctachq             FORMAT "x(12)"        /* NR CONTA */
               crapchd.nrddigv1         FORMAT "9"            /* DV 1*/
               crapchd.nrcheque         FORMAT "999999"       /* NR DOCTO */
               crapchd.nrddigv3         FORMAT "9"            /* DV 3 */
               "  "                     FORMAT "x(2)"         /* FILLER */
               (crapchd.vlcheque * 100) FORMAT "99999999999999999" /* VL CHQ*/
               crapchd.cdtipchq         FORMAT "9"            /* TIPIFICACAO */
               IF   (crapchd.vlcheque >= 
                     DECIMAL(SUBSTR(craptab.dstextab,01,15))) THEN
                    "30"
               ELSE "34" FORMAT "x(2)"         /* TIPO DE DOCUMENTO - TD */
               "00"                     FORMAT "x(2)"         /* FILLER */
               crapcop.cdbcoctl         FORMAT "999"
               crapcop.cdagectl         FORMAT "9999"
               aux_cdagedst             FORMAT "9999"
               crapchd.nrdconta         FORMAT "999999999999" /* NR CTA DEPOS */
               crapage.cdcomchq         FORMAT "999"          /* COMPE  */
               YEAR(par_dtmvtolt)       FORMAT "9999"         /* DATA FORMATO */
               MONTH(par_dtmvtolt)      FORMAT "99"           /* YYYYMMDD*/
               DAY(par_dtmvtolt)        FORMAT "99"
               FILL("0",7)              FORMAT "x(7)"         /* NR LOTE*/
               FILL("0",3)              FORMAT "x(3)"         /* SEQ. LOTE*/ 
               aux_dschqctl             FORMAT "x(6)"
               FILL(" ",45)             FORMAT "x(45)"        /* FILLER */
               aux_nrseqarq             FORMAT "9999999999"
               SKIP. 
         
           /* CRIACAO DA TABELA GENERICA - GNCPCHQ*/
           CREATE gncpchq.
           ASSIGN gncpchq.cdcooper = par_cdcooper
                  gncpchq.cdagenci = crapchd.cdagenci
                  gncpchq.dtmvtolt = par_dtmvtolt
                  gncpchq.cdagectl = crapcop.cdagectl
                  gncpchq.cdbanchq = crapchd.cdbanchq
                  gncpchq.cdagechq = crapchd.cdagechq
                  gncpchq.nrctachq = crapchd.nrctachq
                  gncpchq.nrcheque = crapchd.nrcheque
                  gncpchq.nrddigv2 = crapchd.nrddigv2
                  gncpchq.cdcmpchq = crapchd.cdcmpchq
                  gncpchq.cdtipchq = crapchd.cdtipchq
                  gncpchq.nrddigv1 = crapchd.nrddigv1
                  gncpchq.vlcheque = crapchd.vlcheque
                  gncpchq.nrdconta = IF aux_flgdepin THEN 0 ELSE crapchd.nrdconta
                  gncpchq.nmarquiv = aux_nmarqdat
                  gncpchq.cdoperad = par_cdoperad
                  gncpchq.hrtransa = TIME
                  gncpchq.cdtipreg = 1
                  gncpchq.flgconci = NO
                  gncpchq.nrseqarq = aux_nrseqarq
                  gncpchq.cdbccxlt = crapchd.cdbccxlt  
                  gncpchq.nrdolote = crapchd.nrdolote
                  gncpchq.nrprevia = aux_nrprevia

                  gncpchq.cdcritic = 0
                  gncpchq.cdalinea = 0
                  gncpchq.flgpcctl = NO
                  gncpchq.nrddigv3 = crapchd.nrddigv3
                  gncpchq.cdtipdoc = IF   crapchd.vlcheque >=
                                          DEC(SUBSTR(
                                                   craptab.dstextab,01,15)) THEN
                                                   30
                                     ELSE 34
                  gncpchq.cdagedst = aux_cdagedst
                  gncpchq.nrctadst = crapchd.nrctadst.

                                 
           FIND FIRST crabage WHERE crabage.cdcooper = par_cdcooper AND
                                    crabage.flgdsede = YES  
                                    NO-LOCK NO-ERROR.
                                
           IF   NOT AVAIL crabage THEN
                aux_cdcomchq = 0.
           ELSE
                aux_cdcomchq = crabage.cdcomchq.
           
           ASSIGN gncpchq.flcmpnac = IF   aux_cdcomchq = crapchd.cdcmpchq THEN 
                                          NO
                                     ELSE YES.

           VALIDATE gncpchq.

           /* Atualiza campos da CHD - Inicio */
           DO WHILE TRUE:

               FIND crabchd WHERE RECID(crabchd) = RECID(crapchd) 
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

               IF   NOT AVAILABLE crabchd   THEN
                    IF   LOCKED crabchd   THEN
                         DO:
                             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                PAUSE(3) NO-MESSAGE.
                                LEAVE.
                             END.
                       
                             NEXT.
                         END.

               ASSIGN crabchd.nrprevia = aux_nrprevia
                      crabchd.hrprevia = aux_hrprevia
                      crabchd.insitprv = 1
                      crabchd.flgenvio = TRUE
                      crabchd.cdbcoenv = crapcop.cdbcoctl.
               
               FIND CURRENT crabchd NO-LOCK.
               RELEASE crabchd.

               LEAVE.
           END.
           /* Atualiza campos da CHD - Fim */

           ASSIGN aux_totqtchq = aux_totqtchq + 1
                  aux_totvlchq = aux_totvlchq + (crapchd.vlcheque * 100).

           IF   ((crapchd.tpdmovto = 1)                       AND
                 (DECIMAL(SUBSTR(craptab.dstextab,01,15)) > 
                                           crapchd.vlcheque)) OR
                ((crapchd.tpdmovto = 2)                       AND
                 (DECIMAL(SUBSTR(craptab.dstextab,01,15)) < 
                                           crapchd.vlcheque)) THEN
                DO:
                     ret_cdcritic = 711.
                     

                     IF aux_flgdepin THEN
                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                           " - Ref.: " + STRING(par_dtmvtolt,"99/99/9999") +
                           " Parametro do cheque superior alterado" +
                           " Cheque: " + STRING(crapchd.nrcheque,"999999") +
                           " Agencia destino: " + STRING(crapchd.cdagedst) +
                           " Conta: " + STRING(crapchd.nrctadst,
                           "999999999999") + 
                           " >> " + aux_dscooper + "log/atucom.log").

                     ELSE
                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                             " - Ref.: " + STRING(par_dtmvtolt,"99/99/9999") +
                             " Parametro do cheque superior alterado" +
                             " Cheque: " + STRING(crapchd.nrcheque,"999999") +
                             " Conta: " + STRING(crapchd.nrdconta,
                             "999999999999") + " >> " + aux_dscooper +
                             "log/atucom.log").

                     aux_flgerror = TRUE.
                     UNDO TRANS_1, LEAVE TRANS_1.
                END.
            
            IF   tt-craprej.flgdepos = TRUE THEN
                 DO:

                    IF  crapchd.nrdconta = 0 AND
                        crapchd.nrctadst <> 0 THEN
                        DO:
                            FIND b-crapcop WHERE b-crapcop.cdagectl = crapchd.cdagedst NO-LOCK NO-ERROR.

                             FIND tt-crapdpb 
                            WHERE tt-crapdpb.cdcooper = b-crapcop.cdcooper
                              AND tt-crapdpb.dtmvtolt = tt-craprej.dtmvtolt
                              AND tt-crapdpb.cdagenci = tt-craprej.cdagenci
                              AND tt-crapdpb.cdbccxlt = tt-craprej.cdbccxlt
                              AND tt-crapdpb.nrdolote = tt-craprej.nrdolote
                              AND tt-crapdpb.nrdconta = tt-craprej.nrdconta
                              AND tt-crapdpb.nrdocmto = tt-craprej.nrdocmto
                              NO-LOCK NO-ERROR.
                        END.                     
                     ELSE
                        DO:
                             FIND tt-crapdpb 
                            WHERE tt-crapdpb.cdcooper = tt-craprej.cdcooper
                              AND tt-crapdpb.dtmvtolt = tt-craprej.dtmvtolt
                              AND tt-crapdpb.cdagenci = tt-craprej.cdagenci
                              AND tt-crapdpb.cdbccxlt = tt-craprej.cdbccxlt
                              AND tt-crapdpb.nrdolote = tt-craprej.nrdolote
                              AND tt-crapdpb.nrdconta = tt-craprej.nrdconta
                              AND tt-crapdpb.nrdocmto = tt-craprej.nrdocmto
                              NO-LOCK NO-ERROR.
                        END.

                     IF  NOT AVAIL(tt-crapdpb) THEN
                         DO: 
                             CREATE tt-crapdpb.
                             ASSIGN tt-crapdpb.dtmvtolt = tt-craprej.dtmvtolt
                                    tt-crapdpb.cdagenci = tt-craprej.cdagenci
                                    tt-crapdpb.cdbccxlt = tt-craprej.cdbccxlt
                                    tt-crapdpb.nrdolote = tt-craprej.nrdolote
                                    tt-crapdpb.nrdconta = tt-craprej.nrdconta
                                    tt-crapdpb.nrdocmto = tt-craprej.nrdocmto.

                             IF  crapchd.nrdconta = 0 AND
                                 crapchd.nrctadst <> 0 THEN
                                 DO:
                                    FIND b-crapcop WHERE b-crapcop.cdagectl = crapchd.cdagedst NO-LOCK NO-ERROR.

                                    ASSIGN tt-crapdpb.cdcooper = b-crapcop.cdcooper.

                                    /* atualizar movtos */
                                    FIND crapdpb WHERE 
                                         crapdpb.cdcooper = b-crapcop.cdcooper  AND
                                         crapdpb.dtmvtolt = tt-craprej.dtmvtolt AND
                                         crapdpb.cdagenci = 1                   AND
                                         crapdpb.cdbccxlt = 100                 AND
                                         crapdpb.nrdolote = 10118               AND
                                         crapdpb.nrdconta = tt-craprej.nrdconta AND
                                         crapdpb.nrdocmto = tt-craprej.nrdocmto
                                         USE-INDEX crapdpb1 EXCLUSIVE-LOCK NO-ERROR.
                                END.
                             ELSE
                                DO:
                                   ASSIGN tt-crapdpb.cdcooper = tt-craprej.cdcooper.

                                   /* atualizar movtos */
                                   FIND crapdpb WHERE 
                                        crapdpb.cdcooper = tt-craprej.cdcooper AND
                                        crapdpb.dtmvtolt = tt-craprej.dtmvtolt  AND
                                        crapdpb.cdagenci = tt-craprej.cdagenci  AND
                                        crapdpb.cdbccxlt = tt-craprej.cdbccxlt  AND
                                        crapdpb.nrdolote = tt-craprej.nrdolote  AND
                                        crapdpb.nrdconta = tt-craprej.nrdconta  AND
                                        crapdpb.nrdocmto = tt-craprej.nrdocmto
                                        USE-INDEX crapdpb1 EXCLUSIVE-LOCK NO-ERROR.

                                END.
        
                             IF   AVAILABLE crapdpb  THEN
                                  DO:
                                      ASSIGN aux_data = (crapdpb.dtliblan + 1).
        
                                      DO WHILE TRUE:      /*  Terceiro mes  */
        
                                         IF  CAN-DO("1,7",STRING(WEEKDAY(aux_data))) OR
                                             CAN-FIND(crapfer WHERE 
                                                   crapfer.cdcooper = glb_cdcooper  AND
                                                   crapfer.dtferiad = aux_data)     THEN
                                             DO:
                                                 aux_data = aux_data + 1.
                                                 NEXT.
                                             END.
        
                                         LEAVE.
        
                                      END.  /*  Fim do DO WHILE TRUE  */
        
                                      ASSIGN crapdpb.dtliblan = aux_data. 
                                  END.
                         END.
                 END.         

       END.   /*  Fim do FOR EACH  */

       ASSIGN ret_vlrtotal = ret_vlrtotal + aux_totvlchq
              ret_qtarquiv = ret_qtarquiv + 1
              aux_nrseqarq = aux_nrseqarq + 1.

       PUT STREAM str_1
           FILL("9",47)            FORMAT "x(47)" /* HEADER */
           "CEL605"                               /* NOME   */
           crapage.cdcomchq        FORMAT "999"   /* COMPE  */
           "0001"                                 /* VERS   */
           crapcop.cdbcoctl        FORMAT "999"   /* BANCO  */
           crapcop.nrdivctl        FORMAT "9"     /* DV     */
           "2"                                    /* Ind. Rem. */
           YEAR(par_dtmvtolt)      FORMAT "9999"
           MONTH(par_dtmvtolt)     FORMAT "99"    /* YYYYMMDD*/
           DAY(par_dtmvtolt)       FORMAT "99"
           aux_totvlchq            FORMAT "99999999999999999"
           FILL(" ",60)            FORMAT "x(60)" /* FILLER */
           aux_nrseqarq            FORMAT "9999999999"  /* SEQ. */
           SKIP.

       OUTPUT STREAM str_1 CLOSE.
       
       /* Copia o arquivo para o micro que possui o scanner */
       aux_dscomand = "/usr/local/cecred/bin/EnviaArquivoTruncagem.sh " +
                      aux_dsdirmic + " " + "CEL " + "digit01 " +
                      "cecred.coop.br/digitalizar " + aux_nmarqdat + " " +
                      crapcop.dsdircop + " " + STRING(par_cdagenci,"9999") +
                      " 2>/dev/null".

       INPUT THROUGH VALUE(aux_dscomand).
        
       /*  Prever tratamento de Erro */

       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

          IMPORT UNFORMATTED aux_retorno.

          IF   aux_retorno <> ""  THEN
               LEAVE.
       END.
         
       IF   aux_retorno <> "" THEN
            DO:
                ret_cdcritic = 678.

                UNIX SILENT VALUE("rm " + aux_dscooper + "arq/" +
                                   aux_nmarqdat  + " 2>/dev/null").
                UNDO TRANS_1, LEAVE TRANS_1.
            END.
       ELSE 
            /* move para o salvar */
            UNIX SILENT VALUE("mv " + aux_dscooper + "arq/" + aux_nmarqdat + 
                              " " + aux_dscooper + "salvar/" + aux_nmarqdat +
                              "_" + STRING(TIME,"99999") + " 2>/dev/null").

    END. /** Fim DO TRANSACTION **/

    /*  Caso haja algum problema na geracao do arquivo  */
    IF   aux_flgerror THEN        
         DO:
              DO TRANSACTION ON ENDKEY UNDO, LEAVE:
                 FOR EACH gncpchq WHERE gncpchq.cdcooper = par_cdcooper   AND
                                        gncpchq.dtmvtolt = par_dtmvtolt   AND
                                        gncpchq.cdtipreg = 1              AND
                                        gncpchq.cdagenci = par_cdagenci   AND
                                        gncpchq.nrprevia = aux_nrprevia 
                                        EXCLUSIVE-LOCK:
                    DELETE gncpchq.            
                 END.
              END.   /* TRANSACTION */  
         END.

    IF   ret_cdcritic > 0 THEN
         RETURN.
   
    FOR EACH tt-craprej NO-LOCK:
        UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                      " " + STRING(TIME,"HH:MM:SS") +
                      " '-->' Operador - " + STRING(glb_cdoperad) +
                      " Utilizou a opcao A para selecionar o cheque: Conta: " + STRING(tt-craprej.nrdconta) +
                      ", PA: " + STRING(tt-craprej.cdagenci,"zz9") +
                      ", Valor: " + STRING(tt-craprej.vllanmto,"zzz,zzz,zz9.99") +
                      ", Cheque: " + STRING(tt-craprej.nrcheque) +
                      ", Historico: '" + STRING(tt-craprej.dshistor) + "'" +
                      " >> " + aux_dscooper + "log/atucom.log").
    END.
     
    EMPTY TEMP-TABLE tt-craprej.

    RETURN "OK".

END PROCEDURE.

/* .......................................................................... */


