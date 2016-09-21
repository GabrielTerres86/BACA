/*..............................................................................

    Programa: fontes/prprev.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : GATI (Daniel S. / Eder)
    Data    : Maio/2011                   Ultima atualizacao: 25/03/2016

    Dados referentes ao programa:

    Frequencia: Diario.
    Objetivo  : Operacoes junto a Previdencia: geracao e processamento de 
                arquivos, processamento de demonstrativo, etc.
                
                27/09/2011 - Ordernar browse por Cooperativa/Agencia (Vitor - GATI)
                
                05/10/2011 - Na validação do diretório verificar apenas 1 arquivo
                             e não todos (Vitor - GATI)
                               
                28/12/2011 - Ajustes Uniprope (Adriano).               
                
                21/03/2012 - Incluido mensagem "Processando demonstrativos" na
                             opcao "D" (Adriano).
                             
                29/03/2012 - Colocado mensagem de "Buscando arquivos..",
                             "Enviando arquivos.." na opcao "E" (Adriano).  
                             
                03/04/2012 - Retirado a opcao "TODOS" para o envio dos 
                             arquivos (Adriano).         
                
                14/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).                             
                            
                10/01/2014 - Alterada critica "015 - Agencia nao cadastrada"
                             para "962 - PA nao cadastrado". (Reinert)
                             
                23/01/2014 - Liberado para o departamento COMPE o acesso
                             ao relatorio de conciliacao dos arquivos importados
                             do BANCOOB (opcao P). (Fabricio)
                             
               24/07/2014 - Incluido autorizacao para que a "COMPE" tambem tenha
                            acesso a opcao "H" de alteracao de horario
                            (Daniele).
                            
               25/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).               
                            
..............................................................................*/

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0091tt.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR tel_cdcooper AS CHAR        FORMAT "x(13)" VIEW-AS COMBO-BOX   
                                    INNER-LINES 11                     NO-UNDO.
DEF VAR tel_cdagenci AS INTE        FORMAT "zz9"   INIT 0              NO-UNDO.
DEF VAR tel_nmprgexe AS CHAR        FORMAT "x(14)" VIEW-AS COMBO-BOX 
                                    INNER-LINES 9                      NO-UNDO.
DEF VAR tel_flgenvio AS CHAR        FORMAT "x(13)" 
                     VIEW-AS COMBO-BOX LIST-ITEMS "Processamento",
                                                  "Geracao"            NO-UNDO.

DEF VAR tel_datadlog AS DATE        FORMAT "99/99/9999"                NO-UNDO.
DEF VAR tel_concilia AS CHAR        FORMAT "!(1)"                      NO-UNDO.
DEF VAR tel_dsdsenha AS CHAR                                           NO-UNDO.

DEF VAR aux_ultlinha AS INTE                                           NO-UNDO.
DEF VAR aux_rowttarq AS ROWID                                          NO-UNDO.
DEF VAR aux_rowttcon AS ROWID                                          NO-UNDO.
DEF VAR aux_nmcooper AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR        FORMAT "!(1)"                      NO-UNDO.
DEF VAR aux_nomedarq AS CHAR                                           NO-UNDO.
DEF VAR aux_flgsenha AS LOGI                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_logmensa AS LOGI                                           NO-UNDO.
DEF VAR aux_qtdcoops AS INT                                            NO-UNDO.
DEF VAR h_b1wgen0091 AS HANDLE                                         NO-UNDO.
DEF VAR h_b1wgen0011 AS HANDLE                                         NO-UNDO.
DEF VAR aux_flgproce AS LOG                                            NO-UNDO.
DEF VAR aux_flgderro AS LOG                                            NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR tel_cddopcao AS LOGICAL FORMAT "T/I"                           NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                           NO-UNDO.
DEF VAR par_flgrodar AS LOG INIT TRUE                                  NO-UNDO.
DEF VAR aux_flgescra AS LOG                                            NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                           NO-UNDO.
DEF VAR par_flgfirst AS LOG INIT TRUE                                  NO-UNDO.
DEF VAR aux_contador AS INT                                            NO-UNDO.
DEF VAR tel_dsimprim AS CHAR INIT "Imprimir" FORMAT "x(8)"             NO-UNDO.
DEF VAR tel_dscancel AS CHAR INIT "Cancelar" FORMAT "x(8)"             NO-UNDO.
DEF VAR par_flgcance AS LOG                                            NO-UNDO.
DEF VAR tel_hrfimpag AS INT                                            NO-UNDO.
DEF VAR tel_mmfimpag AS INT                                            NO-UNDO.

FORM tt-arquivos.nmrescop  AT  2 LABEL "Cooperativa" FORMAT "X(11)" SKIP
     tt-arquivos.cdagenci  AT 10  LABEL "PA"
     SKIP
     tt-arquivos.nmarquiv  AT  6  LABEL "Arquivo"
     SKIP(1)
     "-------Nao pagos------    ------Bloqueados------"   AT 15
     SKIP
     "Quant            Valor    Quant            Valor"   AT 15
     SKIP
     tt-arquivos.qtnaopag  AT  3  LABEL "Informados"  FORMAT "zzz,zz9"
                       HELP "Informe a quantidade de nao pagos."
     
     tt-arquivos.vlnaopag                             FORMAT "zzz,zzz,zz9.99"
                       HELP "Informe o valor de nao pagos."
     
     tt-arquivos.qtbloque  AT 41                      FORMAT "zzz,zz9"
                       HELP "Informe a quantidade de bloqueados."

     tt-arquivos.vlbloque                             FORMAT "zzz,zzz,zz9.99"
                       HELP "Informe o valor de bloqueados."
     SKIP(1)
     WITH ROW 10 CENTERED OVERLAY NO-LABELS SIDE-LABELS WIDTH 67 
          FRAME f_concilia.


DEF QUERY q_demonstrativo FOR tt-arquivos.
DEF QUERY q_processamento FOR tt-arquivos.
DEF QUERY q_envio         FOR tt-arquivos.
DEF QUERY q_opcao_l       FOR tt-log-process.
DEF QUERY q_cred_em_conta FOR tt-cred_conta.
DEF QUERY q_bancoob       FOR tt-arquivos.

DEF BROWSE b_opcao_l QUERY q_opcao_l
    DISPLAY tt-log-process.nmrescop FORMAT "X(08)" "-"
            tt-log-process.dslinlog FORMAT "X(67)"
            WITH 10 DOWN NO-BOX WIDTH 78 NO-LABELS.

DEF BROWSE b_demonstrativo QUERY q_demonstrativo
    DISPLAY tt-arquivos.nmarquiv   COLUMN-LABEL "Arquivo" FORMAT "x(70)"
            WITH 8 DOWN NO-BOX WIDTH 76.

DEF BROWSE b_bancoob QUERY q_bancoob
    DISP   tt-arquivos.nmarquiv LABEL "Arquivo" FORMAT "x(30)"
           WITH CENTERED NO-BOX 13 DOWN.


DEF BROWSE b_processamento QUERY q_processamento
    DISPLAY tt-arquivos.nmrescop   COLUMN-LABEL "Cooper."
            tt-arquivos.cdagenci   COLUMN-LABEL "PA"
            tt-arquivos.nmarquiv   COLUMN-LABEL "Arquivo" FORMAT "x(16)"
            tt-arquivos.qtnaopag   COLUMN-LABEL "Quant"   FORMAT "zz,zz9"
            tt-arquivos.vlnaopag   COLUMN-LABEL "Valor"   FORMAT "zz,zzz,zz9.99"
            tt-arquivos.qtbloque   COLUMN-LABEL "Quant"   FORMAT "zz,zz9"
            tt-arquivos.vlbloque   COLUMN-LABEL "Valor"   FORMAT "zz,zzz,zz9.99"
            WITH 8 DOWN NO-BOX WIDTH 76.

DEF BROWSE b_envio QUERY q_envio
    DISPLAY tt-arquivos.nmrescop   COLUMN-LABEL "Cooper."
            tt-arquivos.nmarquiv   COLUMN-LABEL "Arquivo" FORMAT "x(60)"
            WITH 8 DOWN NO-BOX WIDTH 75.

DEF BROWSE b_cred_em_conta QUERY q_cred_em_conta
    DISPLAY tt-cred_conta.flgenvio NO-LABEL FORMAT "x/"
            tt-cred_conta.cdcooper COLUMN-LABEL "Cooperativa"
            tt-cred_conta.cdagenci COLUMN-LABEL "PA"
            tt-cred_conta.nrdconta COLUMN-LABEL "Conta"
           (IF tt-cred_conta.nrrecben <> 0 THEN
               tt-cred_conta.nrrecben 
            ELSE 
               tt-cred_conta.nrbenefi) FORMAT "zzzzzzzzzz9" COLUMN-LABEL "NB/NIT"
            SPACE(3)
            tt-cred_conta.vlliqcre COLUMN-LABEL "Valor"
            WITH 8 DOWN NO-BOX WIDTH 62.

FORM b_opcao_l 
          HELP "Pressione <F4> p/ sair."
     WITH ROW 10 CENTERED OVERLAY NO-LABELS WIDTH 80
     TITLE " Log em " + STRING(tel_datadlog,"99/99/9999") + " " FRAME f_opcao_l.

FORM b_demonstrativo
         HELP "Pressione <DELETE> p/ excluir, <F4> p/ sair"
     WITH ROW 8 CENTERED OVERLAY SIDE-LABELS NO-LABELS WIDTH 78
          TITLE " Demonstrativos a serem processados " FRAME f_arquivos_d.

FORM "-----Nao pagos-----"  AT 37
     "-----Bloqueados----"  AT 58
     b_processamento
         HELP "Pressione <DELETE> p/ excluir, <ENTER> p/ alterar, <F4> p/ sair"
     WITH ROW 8 CENTERED OVERLAY SIDE-LABELS NO-LABELS WIDTH 78
          TITLE " Arquivos a serem processados " FRAME f_arquivos_p.

FORM b_envio HELP "Pressione <DELETE> p/ excluir, <F4> p/ sair"
     WITH ROW 8 CENTERED OVERLAY SIDE-LABELS NO-LABELS WIDTH 78
          TITLE " Arquivos a serem enviados " FRAME f_arquivos_e.

FORM b_cred_em_conta HELP "Pressione <ENTER> p/ selecionar, (T)odos, <F4> p/ sair."
     WITH ROW 8 CENTERED OVERLAY WIDTH 64
     TITLE "Credito em Conta" FRAME f_cred_em_conta.

FORM b_bancoob AT 1
         HELP "Use as <SETAS> p/ navegar e <ENTER> p/ selecionar o arquivo"
     WITH NO-BOX ROW 6 COLUMN 17 OVERLAY FRAME f_bancoob.

ON "DELETE" OF b_demonstrativo IN FRAME f_arquivos_d DO:

    IF NOT AVAILABLE tt-arquivos   THEN
       RETURN.
          
    DELETE tt-arquivos. 
        
    /* linha que foi deletada */
    aux_ultlinha = CURRENT-RESULT-ROW("q_demonstrativo").
    
    OPEN QUERY q_demonstrativo FOR EACH tt-arquivos 
                                        BY tt-arquivos.cdcooper
                                         BY tt-arquivos.cdagenci
                                          BY tt-arquivos.nmarquiv.
    
    /* reposiciona o browse */
    REPOSITION q_demonstrativo TO ROW aux_ultlinha.

END.

ON "DELETE" OF b_processamento IN FRAME f_arquivos_p DO:

    IF NOT AVAILABLE tt-arquivos   THEN
       RETURN.
          
    DELETE tt-arquivos. 
        
    /* linha que foi deletada */
    aux_ultlinha = CURRENT-RESULT-ROW("q_processamento").
    
    OPEN QUERY q_processamento FOR EACH tt-arquivos BY tt-arquivos.cdcooper
                                                     BY tt-arquivos.cdagenci
                                                      BY tt-arquivos.nmarquiv.
    
    /* reposiciona o browse */
    REPOSITION q_processamento TO ROW aux_ultlinha.

END.

ON "RETURN" OF b_processamento IN FRAME f_arquivos_p DO:

    IF tel_concilia <> "S"   THEN
       RETURN NO-APPLY.
    
    DISPLAY tt-arquivos.nmrescop
            tt-arquivos.cdagenci
            tt-arquivos.nmarquiv
            WITH FRAME f_concilia.
    
    UPDATE tt-arquivos.qtnaopag
           tt-arquivos.vlnaopag
           tt-arquivos.qtbloque
           tt-arquivos.vlbloque
           WITH FRAME f_concilia.
    
    ASSIGN aux_rowttarq = ROWID(tt-arquivos).

    HIDE FRAME f_concilia.

    OPEN QUERY q_processamento FOR EACH tt-arquivos 
                                        BY tt-arquivos.cdcooper
                                         BY tt-arquivos.cdagenci
                                          BY tt-arquivos.nmarquiv.

    REPOSITION q_processamento TO ROWID aux_rowttarq NO-ERROR.

END.

ON "DELETE" OF b_envio IN FRAME f_arquivos_e DO:

    IF NOT AVAILABLE tt-arquivos   THEN
       RETURN.
          
    DELETE tt-arquivos. 
        
    /* linha que foi deletada */
    aux_ultlinha = CURRENT-RESULT-ROW("q_envio").
    
    OPEN QUERY q_envio FOR EACH tt-arquivos 
                                BY tt-arquivos.cdcooper
                                 BY tt-arquivos.cdagenci
                                  BY tt-arquivos.nmarquiv.
    
    /* reposiciona o browse */
    REPOSITION q_envio TO ROW aux_ultlinha.

END.

ON RETURN OF b_cred_em_conta IN FRAME f_cred_em_conta 
   DO:
      FIND CURRENT tt-cred_conta NO-ERROR.

      IF tt-cred_conta.flgenvio = TRUE THEN
         tt-cred_conta.flgenvio = FALSE.
      ELSE
         tt-cred_conta.flgenvio = TRUE.

      OPEN QUERY q_cred_em_conta FOR EACH tt-cred_conta
                                          BY tt-cred_conta.nrdconta.

END.

ON t, T OF b_cred_em_conta IN FRAME f_cred_em_conta 
   DO:
      FOR EACH tt-cred_conta:

          IF tt-cred_conta.flgenvio = TRUE THEN
             tt-cred_conta.flgenvio = FALSE.
          ELSE
             tt-cred_conta.flgenvio = TRUE.

      END.
        
      OPEN QUERY q_cred_em_conta FOR EACH tt-cred_conta
                                          BY tt-cred_conta.nrdconta.

END.

ON RETURN OF b_bancoob IN FRAME f_bancoob DO:

    HIDE FRAME f_bancoob.

    APPLY "GO".

END.

DEF QUERY q_tt-arq-cooper FOR tt-arq-cooper.

DEF BROWSE b_tt-arq-cooper
     QUERY q_tt-arq-cooper
   DISPLAY tt-arq-cooper.nmrescop COLUMN-LABEL "COOPERATIVA"  FORMAT "x(11)"
           tt-arq-cooper.dsmensag COLUMN-LABEL "MENSAGEM"     FORMAT "x(50)"
    WITH 9 DOWN WIDTH 65 TITLE "Validacao Diretorio".

FORM SKIP(1)
     b_tt-arq-cooper AT  3 HELP "Use as SETAS para navegar e <F4> para sair"
     SKIP(1)
     WITH NO-LABEL ROW 6 CENTERED  OVERLAY NO-BOX WITH FRAME f_valida_dir.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT 03 LABEL "Opcao" AUTO-RETURN
                  HELP "Informe a opcao desejada (C, D, E, G, H, L, P, R, V)."
                        VALIDATE(CAN-DO("C,D,E,G,H,L,P,R,V",glb_cddopcao),
                                        "014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_opcao.

FORM tel_cdcooper AT 07 LABEL "Cooperativa"
                        HELP "Selecione a Cooperativa."
     tel_nmprgexe AT 39 LABEL "Processar"
                        HELP "Informe qual tipo de arquivo a processar"
                        VALIDATE(tel_nmprgexe <> "","014 - Opcao errada.")
     SKIP

     tel_cdagenci AT 15 LABEL "PA"
                        HELP "Informe o numero do PA ou zero '0' para todos."
     
     tel_concilia AT 39 LABEL "Conciliar"
                        HELP "S - Conciliacao; N - Nao Conciliar."
                        VALIDATE(CAN-DO("S,N",tel_concilia),
                               "014 - Opcao errada.") SKIP 
     WITH ROW 6 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_parametros_p.

FORM tel_cdcooper AT 07 LABEL "Cooperativa"
                        HELP "Selecione a Cooperativa."
     WITH ROW 6 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_parametros_e.

FORM tel_cdcooper AT 07 LABEL "Cooperativa"
                        HELP "Selecione a Cooperativa."
     SKIP
     tel_cdagenci AT 15 LABEL "PA"
                        HELP "Informe o numero do PA ou zero '0' para todos."
     WITH ROW 6 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_parametros_g.

FORM tel_cdcooper AT 07 LABEL "Cooperativa"
                        HELP "Selecione a Cooperativa."
     SKIP
     tel_cdagenci AT 15 LABEL "PA"
                        HELP "Informe o numero do PA ou zero '0' para todos."
     WITH ROW 6 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_parametros_c.


FORM tel_cdcooper AT 07 LABEL "Cooperativa"
                        HELP "Selecione a Cooperativa."

     tel_flgenvio AT 13 LABEL "Opcao"
                  HELP "Selecione Processamento ou Geracao."
     SKIP
     tel_cdagenci AT 15 LABEL "PA"
                        HELP "Informe o numero do PA ou zero '0' para todos."
     SKIP
     tel_datadlog AT 10 LABEL "Data Log"
                        HELP "Informe a data para visualizar LOG"

     WITH ROW 6 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_parametros_l.
  
FORM SKIP(1)
     tel_dsdsenha AT  3 LABEL "Senha" FORMAT "x(15)" BLANK
                        HELP "Informe a senha da Intranet BANCOOB"
                        VALIDATE(tel_dsdsenha <> "","003 - Senha errada.")
     SKIP(1)
     WITH ROW 11 WIDTH 28 CENTERED OVERLAY TITLE "Senha Intranet BANCOOB"
          SIDE-LABEL FRAME f_senha_bancoob.


FORM SKIP(1)
     tel_cdcooper AT 07 LABEL "Cooperativa"
                        HELP "Selecione a Cooperativa."
     tel_cdagenci AT 40 LABEL "PA"
          VALIDATE(tel_cdagenci = 0 OR
                   CAN-FIND(crapage WHERE crapage.cdcooper = 
                                             INT(tel_cdcooper:SCREEN-VALUE) AND
                                          crapage.cdagenci = tel_cdagenci),
                            "962 - PA nao cadastrado.")
     WITH ROW 5 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX SIZE 68 BY 16 
                          NO-LABELS FRAME f_presoc.
     
FORM tel_hrfimpag FORMAT "99"
                      LABEL "Limite para pagamento de beneficios"
                      HELP "Entre com a hora limite (0 a 23)."
                      VALIDATE(tel_hrfimpag >= 0   AND
                               tel_hrfimpag <= 23,
                               "687 - Horario errado.")
         ":"                        AT 40
         tel_mmfimpag FORMAT "99"   AT 41
                      HELP "Entre com os minutos (0 a 59)."
                      VALIDATE(tel_mmfimpag >= 0   AND
                               tel_mmfimpag <= 59,
                               "687 - Horario errado.")
         "Horas"
         WITH ROW 13 CENTERED NO-BOX NO-LABELS SIDE-LABELS OVERLAY 
                                               FRAME f_horario.


ON RETURN OF tel_nmprgexe IN FRAME f_parametros_p
   DO:
       ASSIGN tel_nmprgexe = tel_nmprgexe:SCREEN-VALUE.

       APPLY "GO".

   END.

ON RETURN OF tel_cdcooper IN FRAME f_parametros_p   
   DO:
       ASSIGN tel_cdcooper = tel_cdcooper:SCREEN-VALUE 
                             IN FRAME f_parametros_p.

       APPLY "GO".

   END.

ON RETURN OF tel_cdcooper IN FRAME f_parametros_e  
   DO:
       ASSIGN tel_cdcooper = tel_cdcooper:SCREEN-VALUE 
                             IN FRAME f_parametros_e.

       APPLY "GO".

   END.

ON RETURN OF tel_cdcooper IN FRAME f_parametros_g
   DO:
       ASSIGN tel_cdcooper = tel_cdcooper:SCREEN-VALUE 
                             IN FRAME f_parametros_g.

       APPLY "GO".

   END.

ON RETURN OF tel_cdcooper IN FRAME f_parametros_c 
   DO:
      ASSIGN tel_cdcooper = tel_cdcooper:SCREEN-VALUE
                            IN FRAME f_parametros_c.
        
      APPLY "TAB".
    
   END.

ON RETURN OF tel_cdcooper IN FRAME f_parametros_l
   DO:
       ASSIGN tel_cdcooper = tel_cdcooper:SCREEN-VALUE 
                             IN FRAME f_parametros_l.

       APPLY "TAB".

   END.

ON RETURN OF tel_cdcooper IN FRAME f_presoc  
   DO:
       ASSIGN tel_cdcooper = tel_cdcooper:SCREEN-VALUE 
                             IN FRAME f_presoc.

       APPLY "TAB".

   END.

ON RETURN OF tel_flgenvio DO:

    APPLY "GO".

END.


RUN sistema/generico/procedures/b1wgen0091.p PERSISTENT SET h_b1wgen0091.

RUN carrega_cooperativas IN  h_b1wgen0091 (OUTPUT aux_nmcooper).

DELETE PROCEDURE h_b1wgen0091.

ASSIGN tel_cdcooper:LIST-ITEM-PAIRS IN FRAME f_parametros_p = aux_nmcooper
       tel_cdcooper:LIST-ITEM-PAIRS IN FRAME f_parametros_e = 
                                    SUBSTR(aux_nmcooper,
                                    (INDEX(aux_nmcooper,"0") + 2),
                                    (LENGTH(aux_nmcooper)))
       tel_cdcooper:LIST-ITEM-PAIRS IN FRAME f_parametros_g = aux_nmcooper
       tel_cdcooper:LIST-ITEM-PAIRS IN FRAME f_parametros_l = aux_nmcooper
       tel_cdcooper:LIST-ITEM-PAIRS IN FRAME f_parametros_c = aux_nmcooper
       tel_cdcooper:LIST-ITEM-PAIRS IN FRAME f_presoc = SUBSTR(aux_nmcooper,
                                    (INDEX(aux_nmcooper,"0") + 2),
                                    (LENGTH(aux_nmcooper)))
       tel_nmprgexe:LIST-ITEMS      IN FRAME f_parametros_p = "INSS"
       tel_nmprgexe                                         = "INSS".

ASSIGN glb_cddopcao = "P"
       glb_cdcritic = 0.

RUN fontes/inicia.p.

VIEW FRAME f_moldura.
PAUSE(0).

IF glb_cdcooper = 3 THEN
   DO:
      IF glb_dsdepart <> "TI"                   AND
         glb_dsdepart <> "COORD.ADM/FINANCEIRO" AND
         glb_dsdepart <> "COORD.PRODUTOS"       AND
         glb_dsdepart <> "COMPE"                THEN
      DO:
         ASSIGN glb_nmdatela = "MENU00"
                glb_cdcritic = 36.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         PAUSE 2 NO-MESSAGE.
         ASSIGN glb_cdcritic = 0.
         RETURN.
      END.    
   END.     
ELSE
   DO:
       ASSIGN glb_nmdatela = "MENU00".
              ASSIGN glb_cdcritic = 36.
              RUN fontes/critic.p.
              BELL.
              MESSAGE glb_dscritic.
              PAUSE 2 NO-MESSAGE.
              ASSIGN glb_cdcritic = 0.
              RETURN.
    END.
                                                                
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF glb_cdcritic > 0   THEN 
         DO: 
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
             PAUSE 2 NO-MESSAGE.

         END.

      RUN oculta_frames (INPUT YES).

      UPDATE glb_cddopcao  WITH FRAME f_opcao.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN /*   F4 OU FIM   */
      DO:    
         RUN fontes/novatela.p.
         IF CAPS(glb_nmdatela) <> "PRPREV"  THEN 
            DO:
               RUN oculta_frames (INPUT YES).
               HIDE MESSAGE NO-PAUSE.
               RETURN.

            END.
         ELSE
            NEXT.

   END.

   IF aux_cddopcao <> glb_cddopcao   THEN
      DO:
          { includes/acesso.i }
          aux_cddopcao = glb_cddopcao.

      END.

   IF  glb_cddopcao = "H"  AND NOT CAN-DO("TI,COMPE",glb_dsdepart)  THEN 
       DO:
           BELL.
           MESSAGE "Operador sem autorizacao para alterar horario".
           
           PAUSE 2 NO-MESSAGE.
           RETURN.

       END.
   
   IF glb_cddopcao = "H"   THEN
      tel_cdagenci:HELP = "Informe o numero do PA para alterar o horario.".


   /* Verifica em todas as funcoes (exceto "D") se existem arquivos de 
      demonstrativo para processamento */
   IF glb_cddopcao <> "D"   THEN 
      DO:
          RUN sistema/generico/procedures/b1wgen0091.p 
                                       PERSISTENT SET h_b1wgen0091.
          
          RUN verifica_arquivos_demonstrativo_inss IN h_b1wgen0091 
                                             (INPUT glb_cdcooper,
                                              INPUT glb_cdagenci,
                                              INPUT 0,
                                              INPUT glb_dtmvtolt,
                                              INPUT glb_cdoperad,
                                              OUTPUT TABLE tt-arquivos,
                                              OUTPUT TABLE tt-erro).
          
          DELETE PROCEDURE h_b1wgen0091.

          IF CAN-FIND(FIRST tt-arquivos)   THEN
             DO:
                 MESSAGE "Demonstrativos disponiveis para processamento. " +
                         "Utilize opcao ~"D~".".

                 PAUSE.

             END.
          
      END.

   CASE glb_cddopcao:

        WHEN "P" THEN DO:          /* Processamento de Arquivos */

             RUN oculta_frames (INPUT NO).
             HIDE MESSAGE NO-PAUSE.

             HIDE tel_cdagenci
                  IN FRAME f_parametros_p.

             ASSIGN tel_concilia = "S".

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE WITH FRAME f_parametros_p:
                 
                UPDATE tel_cdcooper.
                
                IF tel_cdcooper <> "0"   THEN
                   DISP tel_cdagenci.
                ELSE
                   HIDE tel_cdagenci.
                
                UPDATE tel_nmprgexe.
                
                IF tel_cdcooper <> "0" THEN
                   UPDATE tel_cdagenci.
                ELSE
                   ASSIGN tel_cdagenci = 0.
                
                UPDATE tel_concilia.
                
                LEAVE. 

             END.

             IF KEYFUNCTION (LASTKEY) = "END-ERROR"   THEN
                NEXT.
             
             RUN sistema/generico/procedures/b1wgen0091.p 
                                             PERSISTENT SET h_b1wgen0091.
             
             RUN verifica_arquivos_processamento_inss IN h_b1wgen0091 
                                  (INPUT glb_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT tel_cdcooper,
                                   INPUT tel_cdagenci,
                                   INPUT NO,
                                   OUTPUT TABLE tt-arquivos,
                                   OUTPUT TABLE tt-erro).
             
             DELETE PROCEDURE h_b1wgen0091.
             
             IF RETURN-VALUE <> "OK"   THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                    IF AVAIL tt-erro   THEN
                       MESSAGE tt-erro.dscritic.
                    ELSE
                       MESSAGE "Erro na busca de arquivos para " + 
                               "processamento.".
                
                    PAUSE 3 NO-MESSAGE.
                
                    NEXT.

                END.

             IF NOT CAN-FIND(FIRST tt-arquivos)   THEN
                DO:
                    MESSAGE "Nao ha registro de arquivos.".
                    NEXT.

                END.
             
             ASSIGN b_processamento:HELP IN FRAME f_arquivos_p = 
                                          "Pressione <DELETE> p/ excluir, ".
             
             IF tel_concilia = "S"   THEN
                ASSIGN b_processamento:HELP IN FRAME f_arquivos_p = 
                                  b_processamento:HELP IN FRAME f_arquivos_p +
                                  "<ENTER> p/ alterar, ".
                
             ASSIGN b_processamento:HELP IN FRAME f_arquivos_p = 
                                    b_processamento:HELP IN FRAME f_arquivos_p +
                                    "<F4> p/ sair".
                     
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:            
                OPEN QUERY q_processamento FOR EACH tt-arquivos
                                                    BY tt-arquivos.cdcooper
                                                     BY tt-arquivos.cdagenci
                                                      BY tt-arquivos.nmarquiv.

                UPDATE b_processamento 
                       WITH FRAME f_arquivos_p.

                LEAVE.

             END.

             IF NOT CAN-FIND(FIRST tt-arquivos)   THEN
                DO:
                    glb_cdcritic = 239.
                    NEXT.

                END.
             
             /* Pede confirmacao */
             RUN fontes/confirma.p (INPUT "",
                                    OUTPUT aux_confirma).
             
             IF aux_confirma <> "S"   THEN
                DO:
                   HIDE FRAME f_arquivos_p.
                   CLOSE QUERY q_processamento.
                   NEXT.

                END.    

             HIDE FRAME f_arquivos_p NO-PAUSE.
             HIDE FRAME f_concilia   NO-PAUSE.
             
             RUN sistema/generico/procedures/b1wgen0091.p 
                                             PERSISTENT SET h_b1wgen0091.

             RUN processa_arquivos_inss IN  h_b1wgen0091 
                                           (INPUT glb_cdcooper,
                                            INPUT glb_cdagenci,
                                            INPUT 0,
                                            INPUT glb_dsdepart,
                                            INPUT glb_dtmvtolt,
                                            INPUT glb_cdoperad,
                                            INPUT tel_concilia,
                                            INPUT-OUTPUT TABLE tt-arquivos,
                                            OUTPUT TABLE tt-mensagens,
                                            OUTPUT TABLE tt-dif-import,
                                            OUTPUT TABLE tt-rejeicoes,
                                            OUTPUT TABLE tt-erro).

             DELETE PROCEDURE h_b1wgen0091.
             
             IF RETURN-VALUE <> "OK"   THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
                    IF AVAIL tt-erro   THEN
                       MESSAGE tt-erro.dscritic.
                    ELSE
                       MESSAGE "Erro no processamento de arquivos.".
             
                    PAUSE 3 NO-MESSAGE.
             
                    NEXT.

                END.
             

             FOR EACH tt-mensagens 
                      BY tt-mensagens.nrseqmsg:
                 
                 MESSAGE tt-mensagens.dsmensag.

             END.
            
             

             /*--- Enviar e-mail ---*/
             IF CAN-DO("TI,COORD.ADM/FINANCEIRO,COMPE",glb_dsdepart) THEN
                DO: 
                    /* Se houveram diferencas ... */
                    IF CAN-FIND(FIRST tt-dif-import)   THEN
                       DO:
                           RUN sistema/generico/procedures/b1wgen0091.p 
                                                PERSISTENT SET h_b1wgen0091.
                           
                           RUN gera_relatorio_diferencas_importacao 
                                                IN h_b1wgen0091 
                                               (INPUT glb_dsdepart,
                                                INPUT glb_dtmvtolt,
                                                INPUT TABLE tt-dif-import,
                                                OUTPUT aux_nomedarq).
                           
                           DELETE PROCEDURE h_b1wgen0091.
                           
                           RUN oculta_frames (INPUT NO).

                           UNIX SILENT VALUE("cp " + aux_nomedarq + 
                                             " /micros/gati/vitor/ 2> /dev/null").
                    
                           RUN fontes/visrel.p (INPUT aux_nomedarq).
                
                           /* So pra manter o browse visivel ... */
                           VIEW FRAME f_arquivos_p.
                
                           OPEN QUERY q_processamento 
                                FOR EACH tt-arquivos
                                         BY tt-arquivos.cdcooper 
                                          BY tt-arquivos.cdagenci
                                           BY tt-arquivos.nmarquiv.
                                                              
                           ASSIGN aux_confirma = "N".
                    
                           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                              
                              MESSAGE "Deseja enviar por e-mail o relatorio?"
                              UPDATE aux_confirma.
                              LEAVE.

                           END.
                       
                           HIDE FRAME f_dados.
                           
                           IF aux_confirma = "S"   THEN
                              DO:
                                  RUN proc_email_diferencas 
                                                (INPUT aux_nomedarq).
                              END.
                         
                           CLOSE QUERY q_processamento.
                           
                           HIDE FRAME f_arquivos_p.
                           
                       END.
                         
                    HIDE FRAME f_dados.
                    
                    UNIX SILENT VALUE ("rm " + aux_nomedarq + " 2>/dev/null").
                
                END. 
             /*--- Fim Enviar e-mail ---*/
             

             RUN sistema/generico/procedures/b1wgen0091.p 
                                             PERSISTENT SET h_b1wgen0091.
             
             RUN gera_relatorio_processamento IN h_b1wgen0091 
                                                (INPUT glb_cdcooper,
                                                 INPUT tel_cdagenci,
                                                 INPUT 0,
                                                 INPUT glb_dtmvtolt,
                                                 INPUT glb_progerad,
                                                 INPUT glb_nmdestin,
                                                 INPUT TABLE tt-arquivos,
                                                 INPUT TABLE tt-rejeicoes,
                                                 OUTPUT aux_nmarqimp,
                                                 OUTPUT TABLE tt-erro).   

             DELETE PROCEDURE h_b1wgen0091.
             
             IF RETURN-VALUE <> "OK"   THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                    IF AVAIL tt-erro   THEN
                       MESSAGE tt-erro.dscritic.
                    ELSE
                       MESSAGE "Erro na geracao do relatorio de " +
                               "processamento.".
                
                    PAUSE 3 NO-MESSAGE.
                
                    NEXT.
                END.


             ASSIGN glb_nmformul = "132col"
                    glb_nrdevias = 1
                    glb_nmarqimp = aux_nmarqimp.

             RUN fontes/imprim.p.
             
        END. /** END do WHEN "P" **/
    
        WHEN "E" THEN DO:          /*  Envio dos Arquivos  */

             RUN sistema/generico/procedures/b1wgen0091.p 
                                              PERSISTENT SET h_b1wgen0091.


             RUN verifica_operador_envio IN h_b1wgen0091 
                                          (INPUT glb_cdcooper, 
                                           INPUT glb_cdoperad,
                                           OUTPUT TABLE tt-mensagens).

             DELETE PROCEDURE h_b1wgen0091.

             
             FOR EACH tt-mensagens NO-LOCK:

                 IF   tt-mensagens.nrseqmsg = 1  THEN
                      MESSAGE tt-mensagens.dsmensag.
                 ELSE
                    IF   tt-mensagens.nrseqmsg = 2  THEN 
                         DO:
                            MESSAGE tt-mensagens.dsmensag.
                            RUN fontes/pedesenha.p (INPUT  glb_cdcooper,
                                                    INPUT  1,
                                                    OUTPUT aux_flgsenha,
                                                    OUTPUT aux_cdoperad).
                                            
                            IF  aux_flgsenha  THEN
                                LEAVE.
                         END.
                    ELSE
                    IF   tt-mensagens.nrseqmsg = 3   THEN 
                         DO:
                             MESSAGE tt-mensagens.dsmensag.
                             ASSIGN aux_logmensa = YES.
                         END.
             END.

             /* Se existem mensagens, nao continua processo */
             IF   aux_logmensa   THEN 
                  NEXT.

             /* Grava operador de envio */
             RUN sistema/generico/procedures/b1wgen0091.p 
                                             PERSISTENT SET h_b1wgen0091.
        
             RUN grava_operador_envio IN h_b1wgen0091 
                                        (INPUT glb_cdcooper, 
                                         INPUT YES,
                                         INPUT glb_cdoperad,
                                         INPUT glb_nmoperad).
         
             DELETE PROCEDURE h_b1wgen0091.

             RUN oculta_frames (INPUT NO).
            
             HIDE MESSAGE NO-PAUSE.

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE WITH FRAME f_parametros_e:
                
                ASSIGN aux_logmensa = NO.
                
                UPDATE tel_cdcooper.

                LEAVE.

             END.
             
             IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                  DO:
                      /* Liberar operador */
                      RUN sistema/generico/procedures/b1wgen0091.p 
                                               PERSISTENT SET h_b1wgen0091.

                      RUN grava_operador_envio IN h_b1wgen0091 
                                                 (INPUT glb_cdcooper, 
                                                  INPUT NO,
                                                  INPUT "",
                                                  INPUT "").

                      DELETE PROCEDURE h_b1wgen0091.
                      NEXT.

                  END.

             RUN sistema/generico/procedures/b1wgen0091.p 
                                             PERSISTENT SET h_b1wgen0091.
             
             MESSAGE "Buscando arquivos...".

             RUN verifica_arquivos_envio_inss IN h_b1wgen0091 
                                                (INPUT glb_cdcooper,
                                                 INPUT 0,
                                                 INPUT 0,
                                                 INPUT tel_cdcooper,
                                                 INPUT NO,
                                                 OUTPUT TABLE tt-arquivos,
                                                 OUTPUT TABLE tt-erro). 

             DELETE PROCEDURE h_b1wgen0091.
             
             HIDE MESSAGE NO-PAUSE.

             IF   RETURN-VALUE <> "OK"   THEN
                  DO:
                      FIND FIRST tt-erro NO-LOCK NO-ERROR.
                  
                      IF   AVAIL tt-erro   THEN
                           MESSAGE tt-erro.dscritic.
                      ELSE
                           MESSAGE 
                               "Erro na verificacao de arquivos para envio.".

                      PAUSE 3 NO-MESSAGE.

                      /* Liberar operador */
                      RUN sistema/generico/procedures/b1wgen0091.p 
                                               PERSISTENT SET h_b1wgen0091.

                      RUN grava_operador_envio IN h_b1wgen0091 
                                                 (INPUT glb_cdcooper, 
                                                  INPUT NO,
                                                  INPUT "",
                                                  INPUT "").

                      DELETE PROCEDURE h_b1wgen0091.
                      NEXT.
                  END.

             IF   NOT CAN-FIND(FIRST tt-arquivos)   THEN
                  DO:
                      MESSAGE "Nao ha registro de arquivos.".

                      /* Liberar operador */
                      RUN sistema/generico/procedures/b1wgen0091.p 
                                               PERSISTENT SET h_b1wgen0091.

                      RUN grava_operador_envio IN h_b1wgen0091 
                                                 (INPUT glb_cdcooper, 
                                                  INPUT NO,
                                                  INPUT "",
                                                  INPUT "").

                      DELETE PROCEDURE h_b1wgen0091.

                      NEXT.
                  END.
             
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                OPEN QUERY q_envio 
                           FOR EACH tt-arquivos 
                                    BY tt-arquivos.cdcooper
                                     BY tt-arquivos.cdagenci
                                      BY tt-arquivos.nmarquiv.
                               
                UPDATE b_envio 
                       WITH FRAME f_arquivos_e.

                LEAVE.

             END.
             
             IF NOT CAN-FIND(FIRST tt-arquivos)   THEN
                DO:
                    glb_cdcritic = 239.

                    /* Liberar operador */
                    RUN sistema/generico/procedures/b1wgen0091.p 
                                             PERSISTENT SET h_b1wgen0091.

                    RUN grava_operador_envio IN h_b1wgen0091 
                                               (INPUT glb_cdcooper, 
                                                INPUT NO,
                                                INPUT "",
                                                INPUT "").

                    DELETE PROCEDURE h_b1wgen0091.

                    NEXT.
                END.
                 
             /* Pede confirmacao */
             RUN fontes/confirma.p (INPUT "",
                                    OUTPUT aux_confirma).
             
             IF   aux_confirma <> "S"   THEN
                  DO:
                      HIDE FRAME f_arquivos_e.
                      CLOSE QUERY q_envio.

                      /* Liberar operador */
                      RUN sistema/generico/procedures/b1wgen0091.p 
                                               PERSISTENT SET h_b1wgen0091.
                      
                      RUN grava_operador_envio IN h_b1wgen0091 
                                                 (INPUT glb_cdcooper, 
                                                  INPUT NO,
                                                  INPUT "",
                                                  INPUT "").

                      DELETE PROCEDURE h_b1wgen0091.

                      NEXT.

                  END.    
             
             HIDE FRAME f_arquivos_e.
             
             ASSIGN tel_dsdsenha = "".
             
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE tel_dsdsenha WITH FRAME f_senha_bancoob.
                LEAVE.

             END.
             
             IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                  DO:
                      ASSIGN glb_cdcritic = 79.
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      ASSIGN glb_cdcritic = 0.
                      
                      /* Liberar operador */
                      RUN sistema/generico/procedures/b1wgen0091.p 
                                               PERSISTENT SET h_b1wgen0091.

                      RUN grava_operador_envio IN h_b1wgen0091 
                                                 (INPUT glb_cdcooper, 
                                                  INPUT NO,
                                                  INPUT "",
                                                  INPUT "").

                      DELETE PROCEDURE h_b1wgen0091.

                      NEXT.

                  END.
                 
             RUN sistema/generico/procedures/b1wgen0091.p 
                                 PERSISTENT SET h_b1wgen0091.
             
             MESSAGE "Enviando arquivos...".

             RUN envia_arquivos_inss IN h_b1wgen0091 
                                        (INPUT glb_cdcooper,
                                         INPUT tel_cdcooper,
                                         INPUT tel_cdagenci,      
                                         INPUT 0, /*par_nrdcaixa*/
                                         INPUT glb_cdoperad,
                                         INPUT tel_dsdsenha ,
                                         INPUT glb_dtmvtolt,
                                         INPUT  TABLE tt-arquivos,
                                         OUTPUT aux_flgderro,
                                         OUTPUT TABLE tt-erro).

             DELETE PROCEDURE h_b1wgen0091.
             
             HIDE MESSAGE NO-PAUSE.

             IF   RETURN-VALUE <> "OK"   THEN
                  DO:
                      FIND FIRST tt-erro NO-LOCK NO-ERROR.
                  
                      IF   AVAIL tt-erro   THEN
                           MESSAGE tt-erro.dscritic.
                      ELSE
                           MESSAGE "Erro na gravacao do Registro.".
                  
                      PAUSE 3 NO-MESSAGE.

                      /* Liberar operador */
                      RUN sistema/generico/procedures/b1wgen0091.p 
                                               PERSISTENT SET h_b1wgen0091.

                      RUN grava_operador_envio IN h_b1wgen0091 
                                                 (INPUT glb_cdcooper, 
                                                  INPUT NO,
                                                  INPUT "",
                                                  INPUT "").

                      DELETE PROCEDURE h_b1wgen0091.
                  
                      NEXT.

                  END.

              IF aux_flgderro = FALSE THEN
                 DO:
                    MESSAGE "Ha arquivo(s) nao enviado(s)...".
                    PAUSE(3) NO-MESSAGE.
                    HIDE MESSAGE.

                 END.     
              ELSE
                 DO:
                    MESSAGE "Arquivo(s) enviado(s) com sucesso.".
                    PAUSE(3) NO-MESSAGE.
                    HIDE MESSAGE.

                 END.     


             /* Liberar operador */
             RUN sistema/generico/procedures/b1wgen0091.p 
                                             PERSISTENT SET h_b1wgen0091.

             RUN grava_operador_envio IN h_b1wgen0091 
                                        (INPUT glb_cdcooper, 
                                         INPUT NO,
                                         INPUT "",
                                         INPUT "").

             DELETE PROCEDURE h_b1wgen0091.
             
        END. /** END do WHEN "E" **/

        WHEN "G" THEN DO:  /*Geracao dos Arquivos para micros/bancoob de cada                              cooperativa. Nao fica no micros/cecred */
             
             RUN oculta_frames (INPUT NO).
             
             HIDE MESSAGE NO-PAUSE.

             HIDE tel_cdagenci IN FRAME f_parametros_g.

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                UPDATE tel_cdcooper 
                       WITH FRAME f_parametros_g.

                IF tel_cdcooper <> "0"   THEN
                   DO:
                       DISP   tel_cdagenci 
                              WITH FRAME f_parametros_g.

                       UPDATE tel_cdagenci 
                              WITH FRAME f_parametros_g.

                   END.
                ELSE
                   DO: 
                       HIDE   tel_cdagenci   IN FRAME f_parametros_g.
                       ASSIGN tel_cdagenci = 0.

                   END.

                LEAVE.

             END.

             IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN  /* F4 OU FIM */
                NEXT.

             /* Pede confirmacao */
             RUN fontes/confirma.p (INPUT "",
                                    OUTPUT aux_confirma).
                    
             IF aux_confirma <> "S"   THEN
                DO:
                    NEXT.
                END.

             RUN sistema/generico/procedures/b1wgen0091.p 
                                             PERSISTENT SET h_b1wgen0091.

             RUN gera_arquivos_inss IN  h_b1wgen0091 (INPUT glb_cdcooper, 
                                                      INPUT glb_cdagenci,
                                                      INPUT 0, /*par_nrdcaixa*/
                                                      INPUT tel_cdcooper,
                                                      INPUT tel_cdagenci,
                                                      INPUT glb_dtmvtolt,
                                                      INPUT glb_cdoperad,
                                                      INPUT glb_dsdepart,
                                                      OUTPUT TABLE tt-erro).

             DELETE PROCEDURE h_b1wgen0091.

             IF   RETURN-VALUE <> "OK"   THEN
                  DO:
                      FIND FIRST tt-erro NO-LOCK NO-ERROR.
                  
                      IF   AVAIL tt-erro   THEN
                           MESSAGE tt-erro.dscritic.
                      ELSE
                           MESSAGE "Erro na geracao de arquivos.".
                  
                      PAUSE 3 NO-MESSAGE.
                  
                      NEXT.

                  END.

              ASSIGN glb_cddopcao = "L"
                     tel_datadlog = glb_dtmvtolt.
              
              RUN opcao_l_envio.

              ASSIGN glb_cddopcao = "E".
              
        END. /** END do WHEN "G" **/

        WHEN "V" THEN DO:          /* Validacao de Diretorios */

             RUN oculta_frames (INPUT NO).

             HIDE MESSAGE NO-PAUSE.

             RUN sistema/generico/procedures/b1wgen0091.p 
                                             PERSISTENT SET h_b1wgen0091.

             RUN valida_diretorio_arquivos IN h_b1wgen0091 
                                             (INPUT  glb_cdcooper,
                                              INPUT  glb_cdagenci,
                                              INPUT  0,
                                              OUTPUT TABLE tt-arq-cooper,
                                              OUTPUT TABLE tt-erro).

             DELETE PROCEDURE h_b1wgen0091.

             IF RETURN-VALUE <> "OK"   THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
               
                    IF AVAIL tt-erro   THEN
                       MESSAGE tt-erro.dscritic.
                    ELSE
                       MESSAGE "Erro no processo de validacao.".
               
                    PAUSE 3 NO-MESSAGE.
                    NEXT.

                END.

             ASSIGN aux_qtdcoops = 0.

             FOR EACH tt-arq-cooper:

                 ASSIGN aux_qtdcoops = aux_qtdcoops + 1.

             END.
             
             OPEN QUERY q_tt-arq-cooper
                  FOR EACH tt-arq-cooper NO-LOCK.
             
             MESSAGE "Existem" aux_qtdcoops
                     "cooperativas com arquivos pendentes".
             
             ENABLE b_tt-arq-cooper WITH FRAME f_valida_dir.
             
             WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
             
             HIDE FRAME f_valida_dir. 
             
             HIDE MESSAGE NO-PAUSE.

        END. /** END do WHEN "V" **/

        WHEN "L" THEN DO:          /* Consulta de Log */

             RUN oculta_frames (INPUT NO).

             HIDE MESSAGE NO-PAUSE.

             HIDE tel_flgenvio   tel_cdagenci   tel_datadlog
                  IN FRAME f_parametros_l.

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                UPDATE tel_cdcooper
                       tel_flgenvio
                       WITH FRAME f_parametros_l.
                       
                LEAVE.

             END.

             IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                NEXT.
    
             /* Processamento */
             IF tel_cdcooper <> "0"   THEN
                DO:
                    IF tel_flgenvio:SCREEN-VALUE = "Processamento" THEN
                       DO:
                          DISP tel_cdagenci 
                               WITH FRAME f_parametros_l.

                          UPDATE tel_cdagenci 
                                 WITH FRAME f_parametros_l.

                       END.

                END.
             ELSE
                DO: 
                   HIDE   tel_cdagenci   IN FRAME f_parametros_l.
                   ASSIGN tel_cdagenci = 0.
                END.

             UPDATE tel_datadlog 
                    WITH FRAME f_parametros_l.
             
             IF tel_flgenvio:SCREEN-VALUE = "Processamento" THEN
                RUN opcao_l_processamento.
             ELSE
                RUN opcao_l_envio.


        END. /** END do WHEN "L" **/

        WHEN "C" THEN DO:          /* Creditos em conta */

             RUN oculta_frames (INPUT NO).

             HIDE MESSAGE NO-PAUSE.

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                  
                UPDATE tel_cdcooper
                       tel_cdagenci
                       WITH FRAME f_parametros_c.
                         
                LEAVE.

             END.

             IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                NEXT.
    
             RUN sistema/generico/procedures/b1wgen0091.p 
                                            PERSISTENT SET h_b1wgen0091.
             
             RUN busca_credito_em_conta IN h_b1wgen0091 
                                           (INPUT tel_cdcooper,
                                            INPUT tel_cdagenci,
                                            INPUT glb_dtmvtolt,
                                            OUTPUT TABLE tt-cred_conta).

             DELETE PROCEDURE h_b1wgen0091.

             IF RETURN-VALUE = "NOK" THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF AVAIL tt-erro THEN
                       MESSAGE tt-erro.dscritic.
                    ELSE
                       MESSAGE "Erro na operacao de busca dos " + 
                               "creditos em conta.".
             
                    PAUSE 3 NO-MESSAGE.
                    
                    NEXT.

                END.

             IF NOT TEMP-TABLE tt-cred_conta:HAS-RECORDS THEN
                DO:
                   MESSAGE "Nenhum registro encontrado.".
                   PAUSE 3 NO-MESSAGE.

                   NEXT.

                END.


             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:  

                OPEN QUERY q_cred_em_conta FOR EACH tt-cred_conta
                                                    BY tt-cred_conta.nrdconta.
                
                UPDATE b_cred_em_conta 
                       WITH FRAME f_cred_em_conta.
                
                LEAVE.

             END.

             RUN fontes/confirma.p (INPUT "",
                                    OUTPUT aux_confirma).
                    
             IF aux_confirma <> "S"   THEN
                DO:
                   NEXT.

                END.
            
             HIDE FRAME f_cred_em_conta.

             RUN sistema/generico/procedures/b1wgen0091.p
                                        PERSISTEN SET h_b1wgen0091.

             FOR EACH tt-cred_conta NO-LOCK:

                 IF tt-cred_conta.flgenvio = FALSE THEN
                    NEXT.
                 
                 RUN gera_credito_em_conta IN h_b1wgen0091 
                                             (INPUT tt-cred_conta.cdcooper,
                                              INPUT glb_cdoperad,
                                              INPUT glb_cdprogra,
                                              INPUT glb_dtmvtolt,
                                              INPUT glb_dtmvtolt,
                                              INPUT tt-cred_conta.nrdrowid).
            
                 IF RETURN-VALUE = "NOK" THEN
                    DO:
                       FIND FIRST tt-erro NO-LOCK NO-ERROR.

                       IF AVAIL tt-erro THEN
                          MESSAGE tt-erro.dscritic.
                       ELSE
                          DO: 
                             MESSAGE "Erro ao gerar o lancamento para "      
                              + "a Conta: "                                  
                              + TRIM(STRING(tt-cred_conta.nrdconta,"zzzz,zzz,9"))
                              + " - "  + "Coop: "                     
                              + TRIM(STRING(tt-cred_conta.cdcooper,"zz,zz9")) 
                              + " - " + "PA:" 
                              + TRIM(STRING(tt-cred_conta.cdagenci,"zz9"))
                              + ".".

                             PAUSE 3 NO-MESSAGE.
                             NEXT.
                          
                          END.
                     
                    END.

             END.

             MESSAGE "Processo concluido.".
             PAUSE(3) NO-MESSAGE.
             HIDE MESSAGE.
            
             DELETE PROCEDURE h_b1wgen0091.
             

        END. /** END do WHEN "C" **/

        WHEN "D" THEN DO:          /* Processamento de Demonstrativos */

             RUN sistema/generico/procedures/b1wgen0091.p 
                                          PERSISTENT SET h_b1wgen0091.
             
             RUN verifica_arquivos_demonstrativo_inss IN h_b1wgen0091 
                                                (INPUT glb_cdcooper,
                                                 INPUT glb_cdagenci,
                                                 INPUT 0,
                                                 INPUT glb_dtmvtolt,
                                                 INPUT glb_cdoperad,
                                                 OUTPUT TABLE tt-arquivos,
                                                 OUTPUT TABLE tt-erro).
             
             DELETE PROCEDURE h_b1wgen0091.
             
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:  

                OPEN QUERY q_demonstrativo 
                    FOR EACH tt-arquivos BY tt-arquivos.cdcooper
                                          BY tt-arquivos.cdagenci
                                           BY tt-arquivos.nmarquiv.
                
                UPDATE b_demonstrativo 
                       WITH FRAME f_arquivos_d.
                
                LEAVE.

             END.

             IF NOT CAN-FIND(FIRST tt-arquivos)   THEN
                DO:
                    glb_cdcritic = 239.
                    NEXT.

                END.
             
             /* Pede confirmacao */
             RUN fontes/confirma.p (INPUT "",
                                    OUTPUT aux_confirma).
                    
             IF aux_confirma <> "S"   THEN
                DO:
                    NEXT.

                END.
            
             HIDE FRAME f_arquivos_d.

             MESSAGE "Processando demonstrativos...".
             
             RUN sistema/generico/procedures/b1wgen0091.p 
                                             PERSISTENT SET h_b1wgen0091.

             RUN processa_arquivos_demonstrativo IN h_b1wgen0091 
                                                   (INPUT  glb_cdcooper,
                                                    INPUT  glb_cdagenci,
                                                    INPUT  0,
                                                    INPUT  glb_dtmvtolt,
                                                    INPUT  glb_cdoperad,
                                                    INPUT  TABLE tt-arquivos,
                                                    OUTPUT aux_flgproce,
                                                    OUTPUT TABLE tt-erro).

             DELETE PROCEDURE h_b1wgen0091.

             HIDE MESSAGE NO-PAUSE.

             IF RETURN-VALUE = "NOK" THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                    IF AVAIL tt-erro THEN
                       MESSAGE tt-erro.dscritic.

                    ELSE
                      MESSAGE "Erro no processamento de demonstrativos.".
                        
                    PAUSE 3 NO-MESSAGE.
                    NEXT.

                END.
             ELSE
                IF aux_flgproce = FALSE THEN
                   DO:
                       MESSAGE "Arquivo(s) nao processado(s)...".
                       PAUSE(3) NO-MESSAGE.
                       HIDE MESSAGE.
                
                   END.
                ELSE
                   DO:
                      MESSAGE "Arquivo(s) processado(s) com sucesso.".
                      PAUSE(3) NO-MESSAGE.
                      HIDE MESSAGE.
                
                   END.


        END.

        WHEN "R" THEN DO:

             RUN oculta_frames (INPUT NO).

             EMPTY TEMP-TABLE tt-arquivos.
            
             tel_cddopcao = TRUE.
            
             RUN sistema/generico/procedures/b1wgen0091.p 
                             PERSISTENT SET h_b1wgen0091.
            
             RUN verifica_arquivos_relatorio_processamento 
                             IN h_b1wgen0091 (OUTPUT TABLE tt-arquivos).
            
             DELETE PROCEDURE h_b1wgen0091.
            
             OPEN QUERY q_bancoob FOR EACH tt-arquivos 
                                           NO-LOCK.
            
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE b_bancoob 
                       WITH FRAME f_bancoob.

                LEAVE.

             END.
             
             IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                NOT AVAILABLE tt-arquivos          THEN
                NEXT.
             
             aux_nmarqimp = "rl/" + tt-arquivos.nmarquiv.
             
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 
                 MESSAGE "(T)erminal ou (I)mpressora: " UPDATE tel_cddopcao.
             
                 IF tel_cddopcao THEN
                    RUN fontes/visrel.p(INPUT aux_nmarqimp).
                 ELSE
                      DO:
                         FIND FIRST crapass 
                              WHERE crapass.cdcooper = glb_cdcooper 
                                    NO-LOCK NO-ERROR.
                         
                         glb_nmformul = "132col".
                         { includes/impressao.i }

                      END.
                               
                 LEAVE.
            
             END. /* Fim do DO WHILE TRUE */   

        END.

        WHEN "H" THEN DO:

             RUN oculta_frames (INPUT NO).

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                UPDATE tel_cdcooper 
                       tel_cdagenci 
                       WITH FRAME f_presoc.

                LEAVE.

             END.

             IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                NEXT.

             IF tel_cdagenci = 0   THEN
                MESSAGE "O PA deve ser escolhido.".
             ELSE
                DO:
                   RUN opcao_h (INPUT tel_cdcooper,
                                INPUT tel_cdagenci,
                                INPUT glb_dtmvtolt,
                                INPUT glb_cdoperad,
                                OUTPUT TABLE tt-erro).
                 
                   IF RETURN-VALUE = "NOK" THEN
                      DO:
                          FIND FIRST tt-erro NO-LOCK NO-ERROR.
                          
                          IF AVAIL tt-erro THEN
                             DO:
                                 MESSAGE tt-erro.dscritic.
                                 PAUSE(3) NO-MESSAGE.
                                 HIDE MESSAGE.

                             END.
                          ELSE
                             DO:
                                 MESSAGE "Nao foi possivel alterar o horario.".
                                 PAUSE(3) NO-MESSAGE.
                                 HIDE MESSAGE.

                             END.

                          NEXT.
                    
                      END.

                END.
             
        END.


   END CASE.

END. /* FIM - DO WHILE TRUE */

/*............................................................................*/
PROCEDURE opcao_l_processamento:

    RUN sistema/generico/procedures/b1wgen0091.p PERSISTENT SET h_b1wgen0091.

    RUN consulta_log_processamento IN h_b1wgen0091 (INPUT glb_cdcooper,
                                                    INPUT 0,
                                                    INPUT 0,
                                                    INPUT tel_cdcooper,
                                                    INPUT tel_cdagenci,
                                                    INPUT tel_datadlog,
                                                    OUTPUT TABLE tt-log-process,
                                                    OUTPUT TABLE tt-erro).
    
    DELETE PROCEDURE h_b1wgen0091.
    
    IF RETURN-VALUE <> "OK"   THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
           IF   AVAIL tt-erro   THEN
                MESSAGE tt-erro.dscritic.
           ELSE
                MESSAGE "Erro na gravacao da Registro.".
    
           PAUSE 3 NO-MESSAGE.
           NEXT.

       END.          

      IF NOT CAN-FIND(FIRST tt-log-process)   THEN
         MESSAGE "Nao ha registro de arquivos para a data informada.".
      ELSE
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:            
            
            OPEN QUERY q_opcao_l 
                 FOR EACH tt-log-process BY tt-log-process.cdcooper 
                                          BY tt-log-process.cdagenci
                                           BY tt-log-process.dslinlog.
         
            UPDATE b_opcao_l 
                   WITH FRAME f_opcao_l.
               
            LEAVE.
         
         END.


    IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
       DO: 
          HIDE FRAME f_opcao_l NO-PAUSE.
          CLOSE QUERY q_opcao_l.

       END.

    CLOSE QUERY q_opcao_l.   

END PROCEDURE. /* opcao_l_processamento */

PROCEDURE opcao_l_envio:

    RUN sistema/generico/procedures/b1wgen0091.p PERSISTENT SET h_b1wgen0091.

    RUN consulta_log_geracao IN h_b1wgen0091 (INPUT glb_cdcooper,         
                                              INPUT 0,                    
                                              INPUT 0,                    
                                              INPUT tel_cdcooper,         
                                              INPUT tel_cdagenci,         
                                              INPUT tel_datadlog,         
                                              OUTPUT TABLE tt-log-process,
                                              OUTPUT TABLE tt-erro).      
               
    DELETE PROCEDURE h_b1wgen0091.

    IF RETURN-VALUE <> "OK"   THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
       
           IF AVAIL tt-erro   THEN
              MESSAGE tt-erro.dscritic.
           ELSE
              MESSAGE "Erro na gravacao do Registro.".
       
           PAUSE 3 NO-MESSAGE.
           NEXT.

       END.

    IF NOT CAN-FIND(FIRST tt-log-process)   THEN
       MESSAGE "Nao ha registro de arquivos para a data informada.".
    ELSE
       DO:
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:            
                                                
              OPEN QUERY q_opcao_l FOR EACH tt-log-process 
                                            BY tt-log-process.cdcooper
                                             BY tt-log-process.cdagenci 
                                              BY tt-log-process.dslinlo.
              
              UPDATE b_opcao_l 
                     WITH FRAME f_opcao_l.
                                                  
              LEAVE.

           END.

       END.

    IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
       DO:
          HIDE FRAME f_opcao_l NO-PAUSE.
          CLOSE QUERY q_opcao_l.

       END.

    CLOSE QUERY q_opcao_l.


END PROCEDURE. /* opcao_l_envio */

PROCEDURE oculta_frames:

    DEFINE INPUT  PARAMETER par_hideopcao AS LOGICAL     NO-UNDO.

    IF par_hideopcao   THEN
       HIDE FRAME f_opcao.

    HIDE FRAME f_parametros_p.
    HIDE FRAME f_parametros_e.
    HIDE FRAME f_parametros_g.
    HIDE FRAME f_parametros_c.
    HIDE FRAME f_concilia.
    HIDE FRAME f_arquivos_d.
    HIDE FRAME f_arquivos_p.
    HIDE FRAME f_arquivos_e.
    HIDE FRAME f_parametros_l.
    HIDE FRAME f_senha_bancoob.
    HIDE FRAME f_cred_em_conta.
    HIDE FRAME f_bancoob.
    HIDE FRAME f_presoc.
    HIDE FRAME f_horario.
    

    
END PROCEDURE. /* oculta_frames */

PROCEDURE proc_email_diferencas:

    DEF INPUT PARAM par_nmarqimp AS CHAR                              NO-UNDO.

    DEF VAR aux_dsdemail         AS CHAR FORMAT "x(60)"               NO-UNDO.

        
    DO WHILE TRUE ON ENDKEY UNDO,LEAVE:

       MESSAGE "Email(s) a enviar:" UPDATE aux_dsdemail.
       LEAVE.

    END.

    IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
       RETURN.
        
    RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT SET h_b1wgen0011.
    
    IF NOT VALID-HANDLE (h_b1wgen0011)   THEN
       RETURN.

    RUN converte_arquivo IN h_b1wgen0011 (INPUT glb_cdcooper,
                                          INPUT par_nmarqimp,
                                          INPUT SUBSTR(par_nmarqimp,4)).

    RUN enviar_email IN h_b1wgen0011 (INPUT glb_cdcooper,
                                      INPUT glb_cdprogra,
                                      INPUT aux_dsdemail,
                                      INPUT "PRPREV - BANCOOB",
                                      INPUT SUBSTR(par_nmarqimp,4),
                                      INPUT FALSE).

    DELETE PROCEDURE h_b1wgen0011.

END PROCEDURE. /* proc_email_diferencas */


PROCEDURE opcao_h:
    
    DEF INPUT PARAM par_cdcooper AS INT                             NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INT                             NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
     
    DO TRANSACTION ON ENDKEY UNDO, LEAVE:
       
       RUN sistema/generico/procedures/b1wgen0091.p 
           PERSISTENT SET h_b1wgen0091.
       

       RUN consulta_horario IN h_b1wgen0091 ( INPUT par_cdcooper, 
                                              INPUT par_cdagenci, 
                                              INPUT 0,
                                              OUTPUT tel_hrfimpag,
                                              OUTPUT tel_mmfimpag,
                                              OUTPUT TABLE tt-erro).
       DELETE PROCEDURE h_b1wgen0091.

       IF RETURN-VALUE = "NOK"  THEN
          RETURN "NOK".
         
       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
          UPDATE tel_hrfimpag
                 tel_mmfimpag
                 WITH FRAME f_horario.                    

          LEAVE.

       END.

       IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
          DO: 
              RUN oculta_frames (INPUT NO).
              RETURN.

          END.
       
       /* pede confirmacao */
       RUN fontes/confirma.p (INPUT "",
                              OUTPUT aux_confirma).

       IF  aux_confirma <> "S"   THEN       
           DO:  
               RUN oculta_frames(INPUT NO).
               RETURN.

           END.

       RUN sistema/generico/procedures/b1wgen0091.p 
           PERSISTENT SET h_b1wgen0091.

       RUN altera_horario IN h_b1wgen0091 ( INPUT  par_cdcooper,
                                            INPUT  par_cdagenci,
                                            INPUT  0,
                                            INPUT  tel_hrfimpag,
                                            INPUT  tel_mmfimpag,
                                            INPUT  par_dtmvtolt,
                                            INPUT  par_cdoperad,
                                            OUTPUT TABLE tt-erro).

       DELETE PROCEDURE h_b1wgen0091.

       IF  RETURN-VALUE = "NOK"  THEN
           RETURN "NOK".
            
    END.

    RETURN "OK".

END PROCEDURE. /* Fim opcao_h */
