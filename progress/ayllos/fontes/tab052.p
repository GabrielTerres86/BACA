/* .............................................................................

   Programa: Fontes/tab052.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Julho/2008                          Ultima alteracao: 08/03/2016
      
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAB052 - Parametro para o desconto de títulos.
   
   Alteracoes: - 11/02/2009 - Liberar alteracoes pras cooperativas, criar 
                              log/tab052.log (Gabriel).

                 09/03/2009 - Tirar permissoes pras cooperativas (Gabriel).
                 
                 20/05/2009 - Adicionar parâmetros para CECRED 
                            - Liberar tela para cooperativas 
                            - Travar Perc. Multa em 2% Tarefa 23731(Guilherme).

                 25/05/2009 - Alteracao CDOPERAD (Kbase).
                 
                 28/12/2010 - Incluido log para todos os campos editaveis 
                              na tela (Henrique).
                              
                 26/06/2012 - Adequar layout da tela para novos campos de 
                              cobrança (David Kruger).
                              
                02/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                             Cedente por Beneficiário e  Sacado por Pagador 
                             Chamado 229313 (Jean Reddiga - RKAM).    
                
                26/02/2016 - Inclusão do campo de dias de carencia melhoria 116
                             (Tiago/Rodrigo).  
                             
                08/03/2016 - Ajuste no layout da tela (Kelvin).
............................................................................. */

{ includes/var_online.i }

{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }

DEF VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.
DEF VAR aux_contador AS INT                                   NO-UNDO.
DEF VAR flg_erro     AS LOGICAL INIT FALSE                    NO-UNDO.

DEF VAR aux_dsctit_vllimite AS DECI                           NO-UNDO.
DEF VAR aux_dsctit_qtrenova AS INTE                           NO-UNDO.
DEF VAR aux_dsctit_qtdiavig AS INTE                           NO-UNDO.
DEF VAR aux_cecred_vllimite AS DECI                           NO-UNDO.
DEF VAR aux_cecred_qtrenova AS INTE                           NO-UNDO.
DEF VAR aux_cecred_qtdiavig AS INTE                           NO-UNDO.
DEF VAR aux_mensagem AS CHAR                                  NO-UNDO.
DEF VAR aux_mensage2 AS CHAR                                  NO-UNDO.
DEF VAR aux_mensage3 AS CHAR                                  NO-UNDO.
DEF VAR aux_mensage4 AS CHAR                                  NO-UNDO.
                                                                      
DEF VAR tel_tpcobran AS LOG FORMAT "Registrada/Sem registro"  NO-UNDO.
  
DEF VAR h-b1wgen0030 AS HANDLE NO-UNDO.

DEF TEMP-TABLE tt-log               LIKE tt-dados_dsctit.
DEF TEMP-TABLE tt-log_cecred        LIKE tt-dados_cecred_dsctit.

DEF TEMP-TABLE tt-param 
    FIELDS dsparame     AS  CHAR FORMAT "x(40)"
    FIELDS properac     AS  DECI FORMAT "zzz,zzz,zz9.99"
    FIELDS prcecred     AS  DECI FORMAT "zzz,zzz,zz9.99".

/* variaveis para mostrar a consulta */           
DEF QUERY  param-q FOR  tt-param. 

DEF BROWSE param-b QUERY param-q
    DISPLAY tt-param.dsparame  NO-LABEL
            tt-param.properac  LABEL "Operacional"
            tt-param.prcecred  LABEL "CECRED"
    WITH 12 DOWN OVERLAY WIDTH 78 CENTERED.

FORM SPACE(1) 
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.
      
FORM 
      param-b HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
      WITH NO-LABEL ROW 5 COLUMN 2 WIDTH 78 OVERLAY NO-BOX FRAME f_param52.

FORM 
    glb_cddopcao AT 1 LABEL "Opção" AUTO-RETURN FORMAT "!"
                       HELP "Entre com a opção desejada (A,C)."
                       VALIDATE(CAN-DO("A,C",glb_cddopcao),
                                "014 - Opção errada.")
    
    tel_tpcobran  AT 10 LABEL "Tipo de cobranca"
    HELP "'R' para cobrança registrada e 'S' para cobrança sem registro."
    "Operacional" AT 45
    "CECRED"      AT 68
    
    WITH ROW 6 COLUMN 2 SIDE-LABELS NO-BOX OVERLAY WIDTH 78 FRAME f_cabecalho.                            

FORM
    tt-dados_dsctit.vllimite AT 15 LABEL "Limite Máximo do Contrato"
                       HELP "Entre com o valor máximo do contrato."  
    tt-dados_cecred_dsctit.vllimite AT 64 NO-LABEL
                       HELP "Entre com o limite para o Operacional."

    tt-dados_dsctit.vlconsul AT 4
                       LABEL "Consultar CPF/CNPJ(Pagador) Acima de"
                       HELP "Entre com o valor do título a ser consultado."
    tt-dados_cecred_dsctit.vlconsul AT 64 NO-LABEL

    tt-dados_dsctit.vlminsac AT 7 LABEL "Valor Mínimo Permitido por Título"
            HELP "Entre com o valor mínimo permitido por título."    
    tt-dados_cecred_dsctit.vlminsac AT 64 NO-LABEL

    tt-dados_dsctit.vlmaxsac AT 7 LABEL "Valor Máximo Permitido por Título"
            HELP "Entre com o valor máximo permitido por título."
    tt-dados_cecred_dsctit.vlmaxsac AT 64 NO-LABEL
                      HELP "Entre com o limite para o Operacional."

    tt-dados_dsctit.qtremcrt AT 16 LABEL "Qtd. Remessa em Cartório"
    tt-dados_cecred_dsctit.qtremcrt AT 64 NO-LABEL

    tt-dados_dsctit.qttitprt AT 14 LABEL "Qtd de Títulos Protestados"
    tt-dados_cecred_dsctit.qttitprt AT 64 NO-LABEL

    tt-dados_dsctit.qtrenova AT 22 LABEL "Qtd. de Renovações"
                             "vezes"             
    tt-dados_cecred_dsctit.qtrenova AT 64 NO-LABEL
                 HELP "Entre com a quantidade de renovações do contrato."
                      "vezes"

    tt-dados_dsctit.qtdiavig AT 18 LABEL "Vigência Mínima (dias)"
    tt-dados_cecred_dsctit.qtdiavig AT 64 NO-LABEL 
                  HELP "Entre com a quantidade de dias da vigência mínima."
                  
    tt-dados_dsctit.qtprzmin AT 21 LABEL "Prazo Mínimo (dias)"
        HELP "Entre com a qtd. de dias de prazo mínimo do título"
    tt-dados_cecred_dsctit.qtprzmin AT 64 NO-LABEL
        
    
    tt-dados_dsctit.qtprzmax AT 21 LABEL "Prazo Máximo (dias)"
        HELP "Entre com a qtd. de dias de prazo máximo do título(Até 360 dias)"
    tt-dados_cecred_dsctit.qtprzmax AT 64 NO-LABEL
        HELP "Entre com o limite para o Operacional."
                   
    tt-dados_dsctit.cardbtit AT 3 LABEL "Carência débito título vencido (dias)"
            HELP "Entre com a qtd. de dias de prazo máximo do título(Até 360 dias)"
    tt-dados_cecred_dsctit.cardbtit AT 64 NO-LABEL
            HELP "Entre com o limite para o Operacional."
                       
    tt-dados_dsctit.qtminfil AT 9 LABEL "Tempo Mínimo de Filiação (dias)"
                       HELP "Entre com o tempo mínimo de filiação."
    tt-dados_cecred_dsctit.qtminfil AT 64 NO-LABEL    

    tt-dados_dsctit.nrmespsq AT 3 LABEL "Nro de Meses para Pesquisa de Pagador"
            HELP "Meses usados para calculo de títulos não pagos por pagador."
    tt-dados_cecred_dsctit.nrmespsq AT 64 NO-LABEL


    tt-dados_dsctit.pctitemi AT 7 LABEL "Percentual de Títulos por Pagador"
        HELP "Entre com o percentual de títulos por emitente (concentração)."
        SPACE(0) "%"
    tt-dados_cecred_dsctit.pctitemi AT 64 NO-LABEL
        SPACE(0) "%"

    tt-dados_dsctit.pctolera AT 9 LABEL "Tolerância para Limite Excedido"
               HELP "Entre com a tolerância para limite excedido no contrato."
                     SPACE(0) "%"
    tt-dados_cecred_dsctit.pctolera AT 64 NO-LABEL
               HELP "Entre com o limite para o Operacional."
                     SPACE(0) "%"

    tt-dados_dsctit.pcdmulta AT 21 LABEL "Percentual de Multa"
                       HELP "Entre com o percentual de multa sobre devolução."
                       SPACE(0) "%"
    tt-dados_cecred_dsctit.pcdmulta AT 64 NO-LABEL
                       SPACE(0) "%"

    WITH ROW 7 OVERLAY SIDE-LABELS WIDTH 80 FRAME f_tab052.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

VIEW FRAME f_moldura. 
PAUSE 0.

DO WHILE TRUE:
    HIDE FRAME f_cabecalho.
    HIDE FRAME f_tab052.
    HIDE FRAME f_param52.
    
    
    CLEAR FRAME f_cabecalho NO-PAUSE.
    CLEAR FRAME f_tab052 NO-PAUSE.
    CLEAR FRAME f_param52 NO-PAUSE.
    
    
    RUN fontes/inicia.p.
   
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        IF  glb_cdcritic > 0   THEN
            DO:
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                CLEAR FRAME f_tab052 NO-PAUSE.
                glb_cdcritic = 0.
            END.
        
        UPDATE glb_cddopcao tel_tpcobran WITH FRAME f_cabecalho.

        LEAVE.
   
    END.  /*  Fim do DO WHILE TRUE  */
   
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:

            RUN fontes/novatela.p.
            
            IF   CAPS(glb_nmdatela) <> "TAB052"   THEN
                 DO:
                     HIDE FRAME f_tab052.
                     RETURN.
                 END.
            ELSE      
                 NEXT.
        END.
    
    IF  aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.

        END.
   
    IF  glb_cddopcao = "A" THEN
        DO:
            RUN sistema/generico/procedures/b1wgen0030.p 
                PERSISTENT SET h-b1wgen0030.
        
            IF  NOT VALID-HANDLE(h-b1wgen0030)  THEN
                DO:
                    glb_dscritic = "Handle inválido para b1wgen0030.".
                    MESSAGE glb_dscritic.
                    NEXT.        
                 END.            
  
            RUN busca_parametros_dsctit IN h-b1wgen0030
                                       (INPUT glb_cdcooper,
                                        INPUT 0,
                                        INPUT 0,
                                        INPUT glb_cdoperad,
                                        INPUT glb_dtmvtolt,
                                        INPUT 1,
                                        INPUT tel_tpcobran,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-dados_dsctit,
                                        OUTPUT TABLE tt-dados_cecred_dsctit).
  
            IF  RETURN-VALUE = "NOK" THEN
                DO:
                    DELETE PROCEDURE h-b1wgen0030.
                       
                    FIND FIRST tt-erro NO-LOCK.
                      
                    IF  AVAILABLE tt-erro  THEN
                        DO:
                            MESSAGE tt-erro.dscritic.
                            ASSIGN flg_erro = TRUE.
                            LEAVE.
                        END.
                END.
            
            ASSIGN aux_dsctit_vllimite = 0
                   aux_dsctit_qtrenova = 0
                   aux_dsctit_qtdiavig = 0
                   aux_cecred_vllimite = 0
                   aux_cecred_qtrenova = 0
                   aux_cecred_qtdiavig = 0.
                 
            FIND FIRST tt-dados_dsctit NO-LOCK NO-ERROR.     
            FIND FIRST tt-dados_cecred_dsctit NO-LOCK NO-ERROR.     
            
            EMPTY TEMP-TABLE tt-log.
            EMPTY TEMP-TABLE tt-log_cecred.
  
            BUFFER-COPY tt-dados_dsctit TO tt-log.
            BUFFER-COPY tt-dados_cecred_dsctit TO tt-log_cecred.

            DISPLAY tt-dados_cecred_dsctit.vlconsul
                    tt-dados_cecred_dsctit.vlminsac
                    tt-dados_cecred_dsctit.qtprzmin
                    tt-dados_cecred_dsctit.qtminfil 
                    tt-dados_cecred_dsctit.nrmespsq 
                    tt-dados_cecred_dsctit.pctitemi
                    tt-dados_cecred_dsctit.vllimite
                    tt-dados_cecred_dsctit.vlmaxsac
                    tt-dados_cecred_dsctit.qtrenova
                    tt-dados_cecred_dsctit.qtdiavig
                    tt-dados_cecred_dsctit.qtprzmax
                    tt-dados_cecred_dsctit.cardbtit
                    tt-dados_cecred_dsctit.pctolera            
                    tt-dados_cecred_dsctit.pcdmulta 
                    tt-dados_dsctit.qtrenova
                    tt-dados_dsctit.qtdiavig
                    tt-dados_cecred_dsctit.qtremcrt WHEN tel_tpcobran = TRUE
                    tt-dados_cecred_dsctit.qttitprt WHEN tel_tpcobran = TRUE
                    WITH FRAME f_tab052.

            IF tel_tpcobran = FALSE THEN
               DO:
                  ASSIGN 
                       tt-dados_dsctit.qtremcrt:VISIBLE IN FRAME f_tab052 = FALSE
                       tt-dados_cecred_dsctit.qtremcrt:VISIBLE IN FRAME f_tab052 = FALSE
                       tt-dados_dsctit.qttitprt:VISIBLE IN FRAME f_tab052 = FALSE
                       tt-dados_cecred_dsctit.qttitprt:VISIBLE IN FRAME f_tab052 = FALSE.
               END.
            
            ASSIGN aux_dsctit_vllimite = tt-dados_dsctit.vllimite
                   aux_dsctit_qtrenova = tt-dados_dsctit.qtrenova
                   aux_dsctit_qtdiavig = tt-dados_dsctit.qtdiavig.
                   
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
               UPDATE tt-dados_dsctit.vllimite 
                      tt-dados_dsctit.vlconsul 
                      tt-dados_dsctit.vlminsac 
                      tt-dados_dsctit.vlmaxsac 
                      tt-dados_dsctit.qtremcrt WHEN tel_tpcobran = TRUE 
                      tt-dados_dsctit.qttitprt WHEN tel_tpcobran = TRUE
                      tt-dados_dsctit.qtrenova
                      tt-dados_dsctit.qtdiavig
                      tt-dados_dsctit.qtprzmin 
                      tt-dados_dsctit.qtprzmax                       
                      tt-dados_dsctit.qtminfil 
                      tt-dados_dsctit.nrmespsq 
                      tt-dados_dsctit.pctitemi 
                      tt-dados_dsctit.pctolera 
                      tt-dados_dsctit.pcdmulta 
                      WITH FRAME f_tab052
  
                  EDITING:
  
                     READKEY.
              
                     IF   FRAME-FIELD = "tt-dados_dsctit.vllimite"  OR
                          FRAME-FIELD = "tt-dados_dsctit.vlconsul"  OR
                          FRAME-FIELD = "tt-dados_dsctit.vlmaxsac"  OR
                          FRAME-FIELD = "tt-dados_dsctit.vlminsac"  OR
                          FRAME-FIELD = "tt-dados_dsctit.pcdmulta"  THEN
                          IF   LASTKEY =  KEYCODE(".")   THEN
                               APPLY 44.
                          ELSE
                               APPLY LASTKEY.
                     ELSE
                          APPLY LASTKEY.
  
                  END.  /*  Fim do EDITING  */            
                
                IF   tt-dados_dsctit.qtprzmin > tt-dados_dsctit.qtprzmax  THEN
                     DO:
                         glb_cdcritic = 26.
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         NEXT-PROMPT tt-dados_dsctit.qtprzmin 
                                     WITH FRAME f_tab052.
                         NEXT.
                     END.
  
                IF   tt-dados_dsctit.qtprzmax > 360   THEN
                     DO:
                         glb_cdcritic = 26.
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         NEXT-PROMPT tt-dados_dsctit.qtprzmax 
                                     WITH FRAME f_tab052.
                         NEXT.
                     END.     
            
                IF  tt-dados_dsctit.vllimite >  
                    tt-dados_cecred_dsctit.vllimite  THEN
                    DO:
                        MESSAGE "O valor deve ser inferior ou igual ao" +
                                " estipulado pela CECRED".
                        NEXT-PROMPT tt-dados_dsctit.vllimite
                                    WITH FRAME f_tab052.
                        NEXT.
                            
                    END.
                
                IF  tt-dados_dsctit.vlmaxsac >  
                    tt-dados_cecred_dsctit.vlmaxsac  THEN
                    DO:
                        MESSAGE "O valor deve ser inferior ou igual ao" +
                                " estipulado pela CECRED".
                        NEXT-PROMPT tt-dados_dsctit.vlmaxsac
                                    WITH FRAME f_tab052.
                        NEXT.
  
                    END.
                IF  tt-dados_dsctit.qtprzmax > 
                    tt-dados_cecred_dsctit.qtprzmax  THEN
                    DO:
                        MESSAGE "O valor deve ser inferior ou igual ao" +
                                " estipulado pela CECRED".
                        NEXT-PROMPT tt-dados_dsctit.qtprzmax
                                    WITH FRAME f_tab052.
                        NEXT.
                    END.
                
                IF  tt-dados_dsctit.cardbtit > 5 THEN
                    DO:
                        MESSAGE "A quantidade de dias de carencia de " + 
                                "debito de titulo deve ser menor ou igual a 5".
                        NEXT-PROMPT tt-dados_dsctit.cardbtit
                                    WITH FRAME f_tab052.
                        NEXT.
                    END.

                IF  tt-dados_dsctit.pctolera > 
                    tt-dados_cecred_dsctit.pctolera  THEN
                    DO:
                        MESSAGE "O valor deve ser inferior ou igual ao" +
                                " estipulado pela CECRED".
                        NEXT-PROMPT tt-dados_dsctit.pctolera
                                    WITH FRAME f_tab052.
                        NEXT.
                    END.
                
                IF  tt-dados_dsctit.pcdmulta > 2  THEN
                    DO:
                        MESSAGE "Valor nao deve ser superior a 2% (Exigencia " +
                                "Legal).".
                        NEXT-PROMPT tt-dados_dsctit.pcdmulta
                                    WITH FRAME f_tab052.
                        NEXT.
                    END.
                                   
                IF  glb_dsdepart <> "TI"                   AND
                    glb_dsdepart <> "PRODUTOS"             AND
                    glb_dsdepart <> "COORD.ADM/FINANCEIRO" THEN
                    DO:
                                         
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            aux_confirma = "N".
        
                            glb_cdcritic = 78.
                            RUN fontes/critic.p.
                            BELL.
                            glb_cdcritic = 0.
                            MESSAGE COLOR NORMAL glb_dscritic 
                            UPDATE aux_confirma.
                            LEAVE.
                        END.
        
                        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                             aux_confirma <> "S" THEN
                             DO:
                                 glb_cdcritic = 79.
                                 RUN fontes/critic.p.
                                 BELL.
                                 MESSAGE glb_dscritic.
                                 glb_cdcritic = 0.
                                 NEXT.
                             END.
                    END.
                LEAVE.
  
            END.  /*  Fim do DO WHILE TRUE  */

            ASSIGN aux_cecred_vllimite = tt-dados_cecred_dsctit.vllimite
                   aux_cecred_qtrenova = tt-dados_cecred_dsctit.qtrenova
                   aux_cecred_qtdiavig = tt-dados_cecred_dsctit.qtdiavig.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN  /*   F4 OU FIM */
                 DO:
                     DELETE PROCEDURE h-b1wgen0030.
                     NEXT.
                 END.    
  
            IF  glb_dsdepart = "TI"                   OR
                glb_dsdepart = "PRODUTOS"             OR
                glb_dsdepart = "COORD.ADM/FINANCEIRO" THEN
                DO:
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                   
                   UPDATE tt-dados_cecred_dsctit.vllimite
                          tt-dados_cecred_dsctit.vlconsul
                          tt-dados_cecred_dsctit.vlminsac
                          tt-dados_cecred_dsctit.vlmaxsac 
                          tt-dados_cecred_dsctit.qtremcrt WHEN tel_tpcobran = TRUE
                          tt-dados_cecred_dsctit.qttitprt WHEN tel_tpcobran = TRUE
                          tt-dados_cecred_dsctit.qtrenova
                          tt-dados_cecred_dsctit.qtdiavig
                          tt-dados_cecred_dsctit.qtprzmin
                          tt-dados_cecred_dsctit.qtprzmax
                          tt-dados_cecred_dsctit.cardbtit
                          tt-dados_cecred_dsctit.qtminfil
                          tt-dados_cecred_dsctit.nrmespsq
                          tt-dados_cecred_dsctit.pctitemi
                          tt-dados_cecred_dsctit.pctolera
                          tt-dados_cecred_dsctit.pcdmulta
                          WITH FRAME f_tab052
        
                      EDITING:
        
                         READKEY.
                  
                         IF   FRAME-FIELD = "tt-dados_cecred_dsctit.vllimite"
                          OR  FRAME-FIELD = "tt-dados_cecred_dsctit.vlmaxsac"
                         THEN IF   LASTKEY =  KEYCODE(".")   THEN
                                   APPLY 44.
                              ELSE
                                   APPLY LASTKEY.
                         ELSE
                              APPLY LASTKEY.
        
                      END.  /*  Fim do EDITING  */            
                    
                    IF  tt-dados_dsctit.vllimite >  
                        tt-dados_cecred_dsctit.vllimite  THEN
                        DO:
                            MESSAGE "O valor não pode ser menor que o da" +
                                    " cooperativa.".
                            NEXT-PROMPT tt-dados_cecred_dsctit.vllimite
                                        WITH FRAME f_tab052.
                            NEXT.
                                
                        END.
                    
                    IF  tt-dados_dsctit.vlmaxsac >  
                        tt-dados_cecred_dsctit.vlmaxsac  THEN
                        DO:
                            MESSAGE "O valor não pode ser menor que o da" +
                                    " cooperativa.".
                            NEXT-PROMPT tt-dados_cecred_dsctit.vlmaxsac
                                        WITH FRAME f_tab052.
                            NEXT.
        
                        END.

                    IF  tt-dados_dsctit.qtprzmax > 
                        tt-dados_cecred_dsctit.qtprzmax  THEN
                        DO:
                            MESSAGE "O valor não pode ser menor que o da" +
                                    " cooperativa.".
                            NEXT-PROMPT tt-dados_cecred_dsctit.qtprzmax
                                        WITH FRAME f_tab052.
                            NEXT.
                        END.
                    
                    IF  tt-dados_dsctit.cardbtit > 5 THEN
                        DO:
                            MESSAGE "A quantidade de dias de carencia de " + 
                                    "debito de titulo deve ser menor ou igual a 5".
                            NEXT-PROMPT tt-dados_dsctit.cardbtit
                                        WITH FRAME f_tab052.
                            NEXT.
                        END.

                    IF  tt-dados_dsctit.pctolera > 
                        tt-dados_cecred_dsctit.pctolera  THEN
                        DO:
                            MESSAGE "O valor não pode ser menor que o da" +
                                    " cooperativa.".
                            NEXT-PROMPT tt-dados_cecred_dsctit.pctolera
                                        WITH FRAME f_tab052.
                            NEXT.
                        END.

                    ASSIGN aux_mensagem = ""
                           aux_mensage2 = ""
                           aux_mensage3 = ""
                           aux_mensage4 = "".

                    IF ((aux_dsctit_vllimite <> tt-dados_dsctit.vllimite)        OR
                       (aux_cecred_vllimite <> tt-dados_cecred_dsctit.vllimite)) AND
                       ((aux_dsctit_qtrenova <> tt-dados_dsctit.qtrenova)        OR    
                       (aux_cecred_qtrenova <> tt-dados_cecred_dsctit.qtrenova)) AND
                       ((aux_dsctit_qtdiavig <> tt-dados_dsctit.qtdiavig)        OR     
                       (aux_cecred_qtdiavig <> tt-dados_cecred_dsctit.qtdiavig)) THEN
                       DO:
                          MESSAGE 'Atenção! Os parâmetros "Limite máximo do contrato", ' +
                                  '"Qtd. de renovações" e "Vigência minima" serão alterados ' +
                                  'para os dois tipos de cobrança, registrada e  ' +
                                  'sem registro.' VIEW-AS ALERT-BOX.   
                       END.
                    ELSE
                      DO:
                        IF (aux_dsctit_vllimite <> tt-dados_dsctit.vllimite) OR
                           (aux_cecred_vllimite <> tt-dados_cecred_dsctit.vllimite) THEN
                           DO:
                              ASSIGN aux_mensagem = aux_mensagem + '"Limite Máximo do Contrato" '
                                     aux_mensage4 = 'O parâmetro '
                                     aux_mensage3 = 'será alterado'
                                     aux_mensage2 = 'Atenção! ' + aux_mensage4 + aux_mensagem +
                                                    aux_mensage3 + ' para os dois tipos de cobrança, ' +
                                                    'registrada e sem registro.'.
                                     
                           END.
                      
                        IF (aux_dsctit_qtrenova <> tt-dados_dsctit.qtrenova) OR
                           (aux_cecred_qtrenova <> tt-dados_cecred_dsctit.qtrenova) THEN
                           DO:
                              ASSIGN aux_mensagem = aux_mensagem + 
                                                    (IF aux_mensagem <> "" THEN ", " ELSE "") +
                                                    '"Qtd. de renovações" '
                                     aux_mensage3 = (IF aux_mensage3 <> "" THEN 
                                                        'serão alterados' 
                                                     ELSE 'será alterado')
                                     aux_mensage4 = (IF aux_mensage4 <> "" THEN 
                                                     "Os parâmetros " ELSE "O parâmetro ")
                                     aux_mensage2 = 'Atenção! ' + aux_mensage4 + aux_mensagem + 
                                         aux_mensage3 + ' para os dois tipos de cobrança,' +
                                         ' registrada e sem registro.'.
                           END.
                      
                        IF (aux_dsctit_qtdiavig <> tt-dados_dsctit.qtdiavig) OR
                           (aux_cecred_qtdiavig <> tt-dados_cecred_dsctit.qtdiavig) THEN
                           DO:
                              ASSIGN aux_mensagem = aux_mensagem + 
                                                    (IF aux_mensagem <> "" THEN ", " ELSE "") + 
                                                    '"Vigência mínima" '
                                     aux_mensage3 = (IF aux_mensage3 <> "" THEN 
                                                        'serão alterados' 
                                                     ELSE 'será alterado')
                                     aux_mensage4 = (IF aux_mensage4 <> "" THEN 
                                                     "Os parâmetros " ELSE "O parâmetro ")
                                     aux_mensage2 = 'Atenção! ' + aux_mensage4 + aux_mensagem + 
                                         aux_mensage3 + ' para os dois tipos de cobrança,' + 
                                         ' registrada e sem registro.'.
                           END.
                      END.

                    IF aux_mensage2 <> "" THEN
                       MESSAGE aux_mensage2 VIEW-AS ALERT-BOX.

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        aux_confirma = "N".
        
                        glb_cdcritic = 78.
                        RUN fontes/critic.p.
                        BELL.
                        glb_cdcritic = 0.
                        MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                        LEAVE.
                    END.
        
                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                         aux_confirma <> "S" THEN
                         DO:
                             glb_cdcritic = 79.
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             glb_cdcritic = 0.
                             NEXT.
                         END.
        
                    LEAVE.
        
                END.  /*  Fim do DO WHILE TRUE  */

                IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN  /*   F4 OU FIM */
                     DO:
                         DELETE PROCEDURE h-b1wgen0030.
                         NEXT.
                     END.    
                END. /* fim do if glb_operad */
  
            IF  NOT flg_erro  THEN
                DO:
                    RUN grava_parametros_dsctit IN h-b1wgen0030
                                (INPUT glb_cdcooper,
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT glb_cdoperad,
                                 INPUT glb_dtmvtolt,
                                 INPUT 1,
                                 INPUT tel_tpcobran,
                                 INPUT TABLE tt-dados_dsctit,
                                 INPUT TABLE tt-dados_cecred_dsctit,
                                 OUTPUT TABLE tt-erro).
                                 
                    IF   RETURN-VALUE = "NOK" THEN
                         DO:
                            DELETE PROCEDURE h-b1wgen0030.
                             
                            FIND FIRST tt-erro NO-LOCK.
                      
                            IF   AVAILABLE tt-erro  THEN
                                 DO:
                                     BELL.
                                     MESSAGE tt-erro.dscritic.
                                     ASSIGN flg_erro = TRUE.
                                     LEAVE.                         
                                 END.
                         END.
  
                    RUN proc_log (STRING(tt-log.vllimite,"zzz,zzz,zz9.99"),
                                  STRING(tt-dados_dsctit.vllimite,
                                                             "zzz,zzz,zz9.99"),
                                  "Limite Maximo do Contrato").
                    
                    RUN proc_log (STRING(tt-log_cecred.vllimite,
                                                          "zzz,zzz,zz9.99"),
                                  STRING(tt-dados_cecred_dsctit.vllimite,
                                                          "zzz,zzz,zz9.99"),
                                 "Limite Maximo do Contrato CECRED").
  
                    RUN proc_log (STRING(tt-log.vlconsul,"zzz,zzz,zz9.99"),
                                  STRING(tt-dados_dsctit.vlconsul,
                                                             "zzz,zzz,zz9.99"),
                                  "Consul. CPF/CNPJ de Tit. Acima").
                                            
                    RUN proc_log (STRING(tt-log.vlmaxsac,"zzz,zzz,zz9.99"),
                                  STRING(tt-dados_dsctit.vlmaxsac,
                                                             "zzz,zzz,zz9.99"),
                                  "Valor Maximo Permitido por Titulo").
                                          
                    RUN proc_log (STRING(tt-log_cecred.vlmaxsac,
                                                             "zzz,zzz,zz9.99"),
                                  STRING(tt-dados_cecred_dsctit.vlmaxsac,
                                                             "zzz,zzz,zz9.99"),
                                  "Valor Maximo Permitido por Titulo CECRED").
                    
                    RUN proc_log (STRING(tt-log.vlminsac,"zzz,zzz,zz9.99"),
                                  STRING(tt-dados_dsctit.vlminsac,
                                                             "zzz,zzz,zz9.99"),
                                  INPUT "Valor Minimo Permitido por Titulo").
                                                
                    RUN proc_log (STRING(tt-log_cecred.qtrenova,"z,zz9"),
                                  STRING(tt-dados_cecred_dsctit.qtrenova,
                                                            "z,zz9"),
                                  INPUT "Qtd. de Renovacoes CECRED").
  
                    RUN proc_log (STRING(tt-log_cecred.qtdiavig,"z,zz9"),
                                  STRING(tt-dados_cecred_dsctit.qtdiavig,
                                                            "z,zz9"),
                                  INPUT "Vigencia Minima CECRED").
                    
                    RUN proc_log (STRING(tt-log.qtprzmin,"z,zz9"),
                                  STRING(tt-dados_dsctit.qtprzmin,"z,zz9"),
                                  INPUT "Prazo Minimo"). 
                                                     
                    RUN proc_log (STRING(tt-log.qtprzmax,"z,zz9"),
                                  STRING(tt-dados_dsctit.qtprzmax,"z,zz9"),
                                  INPUT "Prazo Maximo").
                    
                    RUN proc_log (STRING(tt-log_cecred.qtprzmax,"z,zz9"),
                                  STRING(tt-dados_cecred_dsctit.qtprzmax,
                                         "z,zz9"),
                                  INPUT "Prazo Maximo CECRED").
                                                                   
                    RUN proc_log (STRING(tt-log.qtminfil,"z,zz9"),
                                  STRING(tt-dados_dsctit.qtminfil,"z,zz9"),
                                  INPUT "Tempo Minimo de Filiacao").
                                                                
                    RUN proc_log (STRING(tt-log.nrmespsq,"z,zz9"),
                                  STRING(tt-dados_dsctit.nrmespsq,"z,zz9"),
                                  INPUT "Nro de Meses p/ Pesquisa de Pagador").
                                      
                    RUN proc_log (STRING(tt-log.pctitemi,"zz9"),
                                  STRING(tt-dados_dsctit.pctitemi,"zz9"),
                                  INPUT "Percentual de Titulos por Pagador").
                                  
                    RUN proc_log (STRING(tt-log_cecred.pctitemi,"zz9"),
                                  STRING(tt-dados_cecred_dsctit.pctitemi,
                                                    "zz9"),
                                  INPUT "Percentual de Titulos por Pagador" +                                        " CECRED").
                                                    
                    RUN proc_log (STRING(tt-log.pctolera,"zz9"),
                                  STRING(tt-dados_dsctit.pctolera,"zz9"),
                                  INPUT "Tolerancia para Limite Excedido").
                    
                    RUN proc_log (STRING(tt-log_cecred.pctolera,"zz9"),
                                  STRING(tt-dados_cecred_dsctit.pctolera,
                                                    "zz9"),
                                  INPUT "Tolerancia para Limite Excedido" +
                                        " CECRED").
                                                                  
                    RUN proc_log (STRING(tt-log.pcdmulta,"zz9.999999"),
                                  STRING(tt-dados_dsctit.pcdmulta,"zz9.999999"),
                                  INPUT "Percentual de Multa").
                                                   
                    RUN proc_log (STRING(tt-log_cecred.pcdmulta,"zz9.999999"),
                                  STRING(tt-dados_cecred_dsctit.pcdmulta,
                                                    "zz9.999999"),
                                  INPUT "Percentual de Multa CECRED").                         END.
    
            DELETE PROCEDURE h-b1wgen0030.    
            
            CLEAR FRAME f_tab052 NO-PAUSE.
  
         END.  /*  Fim da Alteracao  */
    ELSE
    IF   glb_cddopcao = "C" THEN
         DO:
             RUN sistema/generico/procedures/b1wgen0030.p 
                 PERSISTENT SET h-b1wgen0030.
         
             IF   NOT VALID-HANDLE(h-b1wgen0030)  THEN
                  DO:
                     BELL.
                     glb_dscritic = "Handle inválido para b1wgen0030.".
                     MESSAGE glb_dscritic.
                     NEXT.        
                  END.            
             
             RUN busca_parametros_dsctit IN h-b1wgen0030
                                           (INPUT glb_cdcooper,
                                            INPUT 0,
                                            INPUT 0,
                                            INPUT glb_cdoperad,
                                            INPUT glb_dtmvtolt,
                                            INPUT 1,
                                            INPUT tel_tpcobran,
                                           OUTPUT TABLE tt-erro,
                                           OUTPUT TABLE tt-dados_dsctit,
                                           OUTPUT TABLE tt-dados_cecred_dsctit).
   
             DELETE PROCEDURE h-b1wgen0030.
             
             IF   RETURN-VALUE = "NOK" THEN
                  DO:
                     FIND FIRST tt-erro NO-LOCK NO-ERROR.
                     IF   AVAILABLE tt-erro  THEN
                          DO:
                              BELL.
                              MESSAGE tt-erro.dscritic.
                              ASSIGN flg_erro = TRUE.
                              LEAVE.                         
                          END.
                  END.            
                  
             FIND FIRST tt-dados_dsctit NO-LOCK NO-ERROR.
             FIND FIRST tt-dados_cecred_dsctit NO-LOCK NO-ERROR.


             RUN carrega_browser.

         END.

END.  /*  Fim do DO WHILE TRUE  */


PROCEDURE proc_log:

    DEF INPUT PARAM par_vldantes AS CHAR  NO-UNDO.
    DEF INPUT PARAM par_vldepois AS CHAR  NO-UNDO.
    DEF INPUT PARAM par_dsdcampo AS CHAR  NO-UNDO.
    
    IF   par_vldantes = par_vldepois   THEN
         RETURN.
             
    UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "   +
                      STRING(TIME,"HH:MM:SS") + "' --> '"                 +
                      " Operador " + glb_cdoperad + " alterou o campo "   +
                      par_dsdcampo + " de " + par_vldantes                +
                      " para "  + par_vldepois + " >> log/tab052.log").

END PROCEDURE.

PROCEDURE carrega_browser:

    EMPTY TEMP-TABLE tt-param.

    /*Cria temp-table com os registros, um create para cada parametro*/
    CREATE tt-param.
    ASSIGN tt-param.dsparame = "Limite Máximo do Contrato"
           tt-param.properac = tt-dados_dsctit.vllimite
           tt-param.prcecred = tt-dados_cecred_dsctit.vllimite.

    CREATE tt-param.
    ASSIGN tt-param.dsparame = "Consultar CPF/CNPJ(Pagador) Acima de"
           tt-param.properac = tt-dados_dsctit.vlconsul
           tt-param.prcecred = tt-dados_cecred_dsctit.vlconsul.

    CREATE tt-param.
    ASSIGN tt-param.dsparame = "Valor Mínimo Permitido por Título"
           tt-param.properac = tt-dados_dsctit.vlminsac
           tt-param.prcecred = tt-dados_cecred_dsctit.vlminsac.

    CREATE tt-param.
    ASSIGN tt-param.dsparame = "Valor Máximo Permitido por Título"
           tt-param.properac = tt-dados_dsctit.vlmaxsac
           tt-param.prcecred = tt-dados_cecred_dsctit.vlmaxsac.

    IF  tel_tpcobran = TRUE THEN
        DO: 
            CREATE tt-param.
            ASSIGN tt-param.dsparame = "Qtd. Remessa em Cartório"
                   tt-param.properac = tt-dados_dsctit.qtremcrt
                   tt-param.prcecred = tt-dados_cecred_dsctit.qtremcrt.
        
            CREATE tt-param.
            ASSIGN tt-param.dsparame = "Qtd de Títulos Protestados"
                   tt-param.properac = tt-dados_dsctit.qttitprt
                   tt-param.prcecred = tt-dados_cecred_dsctit.qttitprt.
        END.

    CREATE tt-param.
    ASSIGN tt-param.dsparame = "Qtd. de Renovações"
           tt-param.properac = tt-dados_dsctit.qtrenova
           tt-param.prcecred = tt-dados_cecred_dsctit.qtrenova.

    CREATE tt-param.
    ASSIGN tt-param.dsparame = "Vigência Mínima (dias)"
           tt-param.properac = tt-dados_dsctit.qtdiavig
           tt-param.prcecred = tt-dados_cecred_dsctit.qtdiavig.

    CREATE tt-param.
    ASSIGN tt-param.dsparame = "Prazo Mínimo (dias)"
           tt-param.properac = tt-dados_dsctit.qtprzmin
           tt-param.prcecred = tt-dados_cecred_dsctit.qtprzmin.

    CREATE tt-param.
    ASSIGN tt-param.dsparame = "Prazo Máximo (dias)"
           tt-param.properac = tt-dados_dsctit.qtprzmax
           tt-param.prcecred = tt-dados_cecred_dsctit.qtprzmax.

    CREATE tt-param.
    ASSIGN tt-param.dsparame = "Carência débito título vencido (dias)"
           tt-param.properac = 0
           tt-param.prcecred = tt-dados_cecred_dsctit.cardbtit.

    CREATE tt-param.
    ASSIGN tt-param.dsparame = "Tempo Mínimo de Filiação (dias)"
           tt-param.properac = tt-dados_dsctit.qtminfil
           tt-param.prcecred = tt-dados_cecred_dsctit.qtminfil.

    CREATE tt-param.
    ASSIGN tt-param.dsparame = "Nro de Meses para Pesquisa de Pagador"
           tt-param.properac = tt-dados_dsctit.nrmespsq
           tt-param.prcecred = tt-dados_cecred_dsctit.nrmespsq.

    CREATE tt-param.
    ASSIGN tt-param.dsparame = "Percentual de Títulos por Pagador"
           tt-param.properac = tt-dados_dsctit.pctitemi
           tt-param.prcecred = tt-dados_cecred_dsctit.pctitemi.

    CREATE tt-param.
    ASSIGN tt-param.dsparame = "Tolerância para Limite Excedido"
           tt-param.properac = tt-dados_dsctit.pctolera
           tt-param.prcecred = tt-dados_cecred_dsctit.pctolera.

    CREATE tt-param.
    ASSIGN tt-param.dsparame = "Percentual de Multa"
           tt-param.properac = tt-dados_dsctit.pcdmulta
           tt-param.prcecred = tt-dados_cecred_dsctit.pcdmulta.

    OPEN QUERY param-q FOR EACH  tt-param NO-LOCK.

    ENABLE param-b    
           WITH FRAME f_param52.

    WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.

END PROCEDURE.

/* .......................................................................... */
