/* .............................................................................

   Programa: Fontes/lrotat.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Abril/2007.                         Ultima atualizacao: 23/04/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LROTAT  -- Manutencao de Credito Rotativo.

   Alteracoes: 28/09/2007 - Alterado HELP do campo tel_tpdlinha (Guilherme).

               14/07/2008 - Criadas variaveis para log e corrigido problema
                            quando chamado zoom_credito_rotativo.p estava 
                            voltando a opcao errada (Gabriel). 

               11/02/2009 - Permissao para o operador 979 (Gabriel).

               19/05/2009 - Permitir apenas operador 799 para opcoes <> C 
                            (Fernando).

               25/05/2009 - Alteracao CDOPERAD (Kbase).

               18/10/2010 - Alteracoes para implementacao de limites de credito
                            com taxas diferenciadas:
                            - Alteracao da exibicao do campo Tipo de limite;
                            - Inclusao das colunas 'Operacional' e 'CECRED';
                            - Alteracao da permissao das funcoes (Operacional:
                              "A" e "C"; CECRED: Todas);
                            - Alteracao na chamada do zoom de Linhas de Credito
                              (zoom_credito_rotativo.p)
                            (GATI - Eder)

               29/12/2010 - Inclusao do terceiro campo dsencfin (Adriano).

               17/06/2011 - Controlar tarifas das linhas de credito através
                            da tabela CRATLR (Adriano). 

               23/04/2014 - Inclusao Orige Recurso, Modalidade e Submodalidade
                            na tela (Guilherme/SUPERO)
               
............................................................................. */
{ includes/var_online.i }
{includes/gg0000.i}

DEF VAR aux_cddopcao AS CHAR                                          NO-UNDO.
DEF VAR aux_confirma AS CHAR                   FORMAT "x"             NO-UNDO.
DEF VAR aux_contador AS INT                                           NO-UNDO.
DEF VAR aux_stimeout AS INT                                           NO-UNDO.
DEF VAR aux_txrefmes AS DECIMAL FORMAT "zz9.999999"                   NO-UNDO.
DEF VAR aux_flgclear AS LOGICAL INIT TRUE                             NO-UNDO.

DEF VAR tel_cdcooper LIKE craplrt.cdcooper                            NO-UNDO.
DEF VAR tel_cddlinha LIKE craplrt.cddlinha                            NO-UNDO.
DEF VAR tel_tpdlinha AS CHAR FORMAT "X(1)"   INIT "F"                 NO-UNDO.
DEF VAR tel_dsdtplin AS CHAR FORMAT "X(20)"                           NO-UNDO.
DEF VAR tel_dsdlinha LIKE craplrt.dsdlinha                            NO-UNDO.
DEF VAR tel_dsencfin LIKE craplrt.dsencfin                            NO-UNDO.
DEF VAR tel_flgstlcr LIKE craplrt.flgstlcr                            NO-UNDO.
DEF VAR tel_qtdiavig LIKE craplrt.qtdiavig                            NO-UNDO.
DEF VAR tel_qtvezcap LIKE craplrt.qtvezcap                            NO-UNDO.
DEF VAR tel_qtvcapce LIKE craplrt.qtvcapce                            NO-UNDO.
DEF VAR tel_txjurfix LIKE craplrt.txjurfix                            NO-UNDO.
DEF VAR tel_txjurvar LIKE craplrt.txjurvar                            NO-UNDO.
DEF VAR tel_txmensal LIKE craplrt.txmensal                            NO-UNDO.
DEF VAR tel_vllimmax LIKE craplrt.vllimmax                            NO-UNDO.
DEF VAR tel_vllmaxce LIKE craplrt.vllmaxce                            NO-UNDO.

DEF VAR aux_idseqtlr AS INT                                           NO-UNDO.

DEF VAR aux_flglimit AS CHAR FORMAT "x(11)"                           NO-UNDO.
DEF VAR aux_dsdlinha LIKE craplrt.dsdlinha                            NO-UNDO.
DEF VAR aux_tpdlinha LIKE craplrt.tpdlinha                            NO-UNDO.
DEF VAR aux_qtvezcap LIKE craplrt.qtvezcap                            NO-UNDO.
DEF VAR aux_qtvcapce LIKE craplrt.qtvcapce                            NO-UNDO.
DEF VAR aux_txjurfix LIKE craplrt.txjurfix                            NO-UNDO.
DEF VAR aux_txjurvar LIKE craplrt.txjurvar                            NO-UNDO.
DEF VAR aux_vllimmax LIKE craplrt.vllimmax                            NO-UNDO.
DEF VAR aux_vllmaxce LIKE craplrt.vllmaxce                            NO-UNDO.
DEF VAR aux_qtdiavig LIKE craplrt.qtdiavig                            NO-UNDO.
DEF VAR aux_dsencfin LIKE craplrt.dsencfin                            NO-UNDO.
DEF VAR aux_flgstlcr AS CHARACTER                                     NO-UNDO.
DEF VAR aux_flgtexto AS LOGICAL                                       NO-UNDO.
DEF VAR tel_origrecu AS CHAR    FORMAT "x(25)"                        NO-UNDO.
DEF VAR tel_cdmodali LIKE craplcr.cdmodali                            NO-UNDO.
DEF VAR tel_cdsubmod LIKE craplcr.cdsubmod                            NO-UNDO.


DEF TEMP-TABLE tt-origem
    FIELD origem AS CHAR FORMAT "x(25)".

DEF TEMP-TABLE tt-modali
    FIELD cdmodali AS CHAR FORMAT "X(27)".

DEF TEMP-TABLE tt-submodali
    FIELD cdsubmod AS CHAR FORMAT "X(50)".

DEF QUERY origem-q FOR tt-origem.
DEF QUERY modali-q FOR tt-modali.
DEF QUERY submodali-q FOR tt-submodali.


DEF BROWSE brorigem QUERY origem-q
    DISPLAY origem COLUMN-LABEL "Origem Recurso" 
     WITH 4 DOWN OVERLAY.

DEF BROWSE modali-b QUERY modali-q
    DISPLAY cdmodali COLUMN-LABEL "Descricao da Modalidade"
            WITH 3 DOWN.

DEF BROWSE submodali-b QUERY submodali-q
    DISPLAY cdsubmod COLUMN-LABEL "Descricao da Submodalidade"
            WITH 9 DOWN.

DEF FRAME f_origem
    brorigem HELP "Use as SETAS para navegar e <F4> para sair"  SKIP
             WITH NO-BOX CENTERED OVERLAY ROW 10 WIDTH 2.

DEF FRAME f_modali
           modali-b HELP "Use as SETAS para navegar e <F4> para sair"  SKIP
            WITH NO-BOX CENTERED OVERLAY ROW 11.

DEF FRAME f_submodali
           submodali-b HELP "Use as SETAS para navegar e <F4> para sair"  SKIP
            WITH NO-BOX CENTERED OVERLAY ROW 8.


DEF FRAME f_moldura.
DEF FRAME f_lrotat.
DEF FRAME f_descricao.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT 11 LABEL "Opcao" AUTO-RETURN
                        HELP  "Informe a opcao desejada (A, B, C, E, I ou L)."
                        VALIDATE(CAN-DO("A,B,C,E,I,L",glb_cddopcao),
                                 "014 - Opcao errada.")
     tel_cddlinha AT 24 LABEL "Codigo" AUTO-RETURN
                  HELP "Informe o codigo ou tecle <F7> para listar as linhas."
                        VALIDATE(tel_cddlinha > 0,
                        "360 - Codigo da linha de credito deve ser informado.")
     tel_dsdlinha AT 41 LABEL "Descricao" FORMAT "x(25)" AUTO-RETURN
                        HELP  "Informe a descricao da linha de credito."
                        VALIDATE(tel_dsdlinha <> "",
                                 "375 - O campo deve ser preenchido.")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_descricao.

FORM SKIP
     tel_tpdlinha AT 02 
         LABEL "Tipo de Limite"
         HELP  "Informe o tipo de limite (F-Pessoa Fisica/J-Pessoa Juridica)."
         VALIDATE(CAN-DO("F,J",tel_tpdlinha),
                  "Tipo de limite invalido (Informe F-Fisica ou J-Juridica).")
     tel_dsdtplin       
         NO-LABEL         
     tel_flgstlcr AT 58 
         LABEL "Situacao"
         HELP  "Informe a situacao."
     SKIP(1)
     "Operacional":C14 AT 40
     "CECRED":C14      AT 55
     SKIP
     tel_qtvezcap COLON 35
                  FORMAT "zzz,zzz,zz9.99"
                  LABEL "Quantidade de vezes do capital"
                  HELP  "Informe a qtd. vezes do capital."
     tel_qtvcapce COLON 55 
                  FORMAT "zzz,zzz,zz9.99"
                  NO-LABEL
                  HELP  "Informe a qtd. vezes do capital."
     SKIP
     tel_vllimmax COLON 35 
                  LABEL "Valor Limite maximo"
                  HELP  "Informe o valor do limite maximo."
     tel_vllmaxce COLON 55 
                  NO-LABEL 
                  HELP  "Informe o valor do limite maximo."
     SKIP
     "Dias de vigencia no contrato:":R35
     tel_qtdiavig COLON 55 
                  NO-LABEL
                  HELP  "Informe a qtd. de dias de vigencia no contrato."
                  VALIDATE(tel_qtdiavig > 0,"026 - Quantidade errada.")
     SKIP
     "Taxa Fixa:":R35
     tel_txjurfix COLON 55
                  FORMAT "zz9.999999"
                  NO-LABEL
                  HELP  "Informe o percentual da taxa fixa."
     "%"                   
     SKIP
     "Taxa Variavel:":R35
     tel_txjurvar COLON 55 
                  FORMAT "zz9.999999"
                  NO-LABEL
                  HELP  "Informe o percentual da taxa variavel."
     "%"
     SKIP
     "Taxa Mensal:":R35
     tel_txmensal COLON 55
                  FORMAT "zz9.999999"
                  NO-LABEL
     "%"
     SKIP(1)
     tel_dsencfin[1] AT 06 FORMAT "x(50)"
                           LABEL "Texto no Contrato" 
     SKIP
     tel_dsencfin[2] AT 25 FORMAT "x(50)" NO-LABEL
     SKIP
     tel_dsencfin[3] AT 25 FORMAT "x(50)" NO-LABEL 
     WITH ROW 8 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_lrotat.
     
FORM SKIP (2) 
     "Informacoes Central de Risco"  AT 25 
     SKIP(3) 
     tel_origrecu AT 11 LABEL "Origem do Recurso" 
        HELP "Informe 'F7' para selecionar a Origem do Recurso"
     SKIP
     tel_cdmodali AT 10 LABEL "Modalidade (BACEN)"     FORMAT "X(30)"
         HELP "Informe 'F7' para selecionar a Modalidade."
         VALIDATE(tel_cdmodali <> "","375 - O campo deve ser preenchido.")
     SKIP
     tel_cdsubmod AT  7 LABEL "Submodalidade (BACEN)"  FORMAT "X(45)"
         HELP "Informe 'F7' para selecionar a Submodalidade."     
         VALIDATE(tel_cdsubmod <> "","375 - O campo deve ser preenchido.")

     SKIP(7)
     WITH  SIDE-LABELS ROW 4 OVERLAY TITLE glb_tldatela  WIDTH 80 FRAME f_lrotat2.


ON RETURN OF brorigem DO:

    ASSIGN tel_origrecu = tt-origem.origem.
    DISPLAY tel_origrecu WITH FRAME f_lrotat2.
    HIDE FRAME f_origem.
    APPLY "GO".

END.

ON RETURN OF modali-b IN FRAME f_modali DO:
    
    ASSIGN tel_cdmodali = tt-modali.cdmodali.
    DISPLAY tel_cdmodali WITH FRAME f_lrotat2.
    HIDE FRAME f_modali.     
    APPLY "GO".

END.

ON RETURN OF submodali-b IN FRAME f_submodali DO:
    
    IF   NOT AVAIL tt-submodali   THEN
         RETURN.

    ASSIGN tel_cdsubmod = tt-submodali.cdsubmod.
    DISPLAY tel_cdsubmod WITH FRAME f_lrotat2.
    HIDE FRAME f_submodali.     
    APPLY "GO".

END.


ON LEAVE OF tel_tpdlinha IN FRAME f_lrotat 
   DO:
       CASE INPUT tel_tpdlinha:
            WHEN "F" THEN ASSIGN tel_dsdtplin = "Limite de Credito PF".
            WHEN "J" THEN ASSIGN tel_dsdtplin = "Limite de Credito PJ".
                OTHERWISE ASSIGN tel_dsdtplin = "".
       END CASE.
       
       ASSIGN tel_tpdlinha = UPPER(INPUT tel_tpdlinha).
       
       DISP tel_tpdlinha tel_dsdtplin WITH FRAME f_lrotat.
   END.
                        
VIEW FRAME f_moldura.

PAUSE 0.

VIEW FRAME f_descricao.
VIEW FRAME f_lrotat.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      ASSIGN tel_dsdlinha    = ""
             tel_tpdlinha    = ""
             tel_dsdtplin    = ""
             tel_flgstlcr    = YES
             tel_qtdiavig    = 0
             tel_qtvezcap    = 0
             tel_qtvcapce    = 0
             tel_txjurfix    = 0
             tel_txjurvar    = 0
             tel_txmensal    = 0
             tel_vllimmax    = 0
             tel_vllmaxce    = 0
             tel_origrecu    = ""
             tel_cdmodali    = ""
             tel_cdsubmod    = ""
             tel_dsencfin[1] = ""
             tel_dsencfin[2] = ""
             tel_dsencfin[3] = ""
             aux_flglimit    = "99999999999".
             

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               IF   aux_flgclear   THEN
                    DO:
                        CLEAR FRAME f_lrotat NO-PAUSE.
                        CLEAR FRAME f_descricao NO-PAUSE.
                    END.
               MESSAGE glb_dscritic.
               ASSIGN glb_cdcritic = 0            
                      aux_flgclear = TRUE.
           END.
           
      IF   glb_dsdepart <> "PRODUTOS"               AND
           glb_dsdepart <> "COORD.ADM/FINANCEIRO"   AND
           glb_dsdepart <> "TI"                     THEN
           ASSIGN glb_cddopcao:HELP IN FRAME f_descricao = 
                      "Informe a opcao desejada (A-Alteracao ou C-Consulta).".
      ELSE
           ASSIGN glb_cddopcao:HELP IN FRAME f_descricao = 
                      "Informe a opcao desejada (A, B, C, E, I ou L).".
      
      UPDATE glb_cddopcao 
             WITH FRAME f_descricao.
             
      IF   NOT CAN-DO("A,C",glb_cddopcao) THEN
           IF   glb_dsdepart <> "PRODUTOS"             AND
                glb_dsdepart <> "COORD.ADM/FINANCEIRO" AND
                glb_dsdepart <> "TI"                   THEN
                DO:
                    BELL.
                    MESSAGE 
                      "Sistema liberado apenas para Consulta e Alteracao !!!".
                    NEXT.
                END.
                
      IF   glb_cddopcao = "I"   THEN
           ASSIGN tel_cddlinha = 0.
      
      UPDATE tel_cddlinha 
             WITH FRAME f_descricao

      EDITING:

         aux_stimeout = 0.

         DO WHILE TRUE:

            READKEY PAUSE 1.

            IF   LASTKEY = -1   THEN
                 DO:
                     aux_stimeout = aux_stimeout + 1.

                     IF   aux_stimeout > glb_stimeout   THEN
                          QUIT.

                     NEXT.
                 END.
            ELSE
                IF   LASTKEY = KEYCODE("F7") THEN DO:
                     IF   FRAME-FIELD = "tel_cddlinha" THEN
                          DO: 
                              IF   f_conectagener()   THEN
                                   DO:
                                       RUN fontes/zoom_credito_rotativo.p
                                                   ( INPUT  glb_cdcooper,
                                                     INPUT  0,
                                                     INPUT  FALSE, /*flgstlcr*/
                                                     OUTPUT tel_cddlinha).

                                       RUN p_desconectagener.
                                       
                                       DISPLAY glb_cddopcao  tel_cddlinha 
                                               WITH FRAME f_descricao.
                                       
                                       IF   tel_cddlinha > 0    THEN
                                            APPLY "RETURN".
                                   END.
                          END.
                END.
                ELSE
                      APPLY LASTKEY.

            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

      END.  /*  Fim do EDITING  */

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "lrotat"   THEN
                 DO:
                     HIDE FRAME f_lrotat.
                     HIDE FRAME f_descricao.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.
        
   


   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            ASSIGN aux_cddopcao = glb_cddopcao
                   glb_cdcritic = 0.
        END.
       
   IF   glb_cddopcao = "A"   THEN
        DO:
            RUN cria_origem.
            RUN cria_modali.
            { includes/lrotata.i }
        END.
   ELSE  
   IF   CAN-DO("B,L",glb_cddopcao)   THEN
        DO:
            { includes/lrotatbl.i }
        END.
   ELSE                         
   IF   glb_cddopcao = "C"   THEN
        DO: 
            { includes/lrotatc.i }
        END.
   ELSE 
   IF   glb_cddopcao = "E"   THEN
        DO: 
            { includes/lrotate.i }
            /*{ includes/lrotate_task2045.i }*/
        END.
   ELSE  
   IF   glb_cddopcao = "I"   THEN
        DO:  
            RUN cria_origem.
            RUN cria_modali.
            { includes/lrotati.i }
        END.
        
END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

PROCEDURE cria_Origem:

    EMPTY TEMP-TABLE tt-origem.

    CREATE tt-origem.
    ASSIGN tt-origem.origem = "RECURSO PROPRIO".
    CREATE tt-origem.
    ASSIGN tt-origem.origem = "BNDES/FINAME".

END.

/* .......................................................................... */

PROCEDURE cria_modali:

    EMPTY TEMP-TABLE tt-modali.

    FOR EACH gnmodal WHERE gnmodal.cdmodali = "02" OR 
                           gnmodal.cdmodali = "14" NO-LOCK:

        CREATE tt-modali.
        ASSIGN tt-modali.cdmodali = gnmodal.cdmodali +  "-" + 
                                    gnmodal.dsmodali.

    END.

END PROCEDURE.

/* .......................................................................... */

PROCEDURE cria_submodali:

    EMPTY TEMP-TABLE tt-submodali.

    FOR EACH gnsbmod WHERE gnsbmod.cdmodali = SUBSTR(tel_cdmodali,1,2) NO-LOCK:

        CREATE tt-submodali.
        ASSIGN tt-submodali.cdsubmod = gnsbmod.cdsubmod + "-" + 
                                       gnsbmod.dssubmod.

    END.

END PROCEDURE.

/* .......................................................................... */
