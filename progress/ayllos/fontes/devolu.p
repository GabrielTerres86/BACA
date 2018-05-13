/*  ............................................................................

   Programa: Fontes/devolu.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Junho/99.                           Ultima atualizacao: 21/12/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela DEVOLU -- Devolucao de cheques 
   
   Alteracoes: 21/07/2000 - Tratar o historico 358 (Deborah).

               26/06/2001 - Rever can-dos (Margarete).

               19/07/2001 - Tratamento da alinea 22 (Deborah).

               28/08/2001 - Tratamento da alinea 20 (Deborah).

               17/12/2001 - Tratamento da alinea 48 (Edson).

               09/07/2002 - Implementado senha de autorizacao para execucao
                            da devolucao (Deborah).

               31/07/2002 - Incluir nova situacao da conta (Margarete).

               18/12/2002 - Tratar alinea 31. (Edson/Margarete).
               
               26/03/2003 - Tratamento dos cheques da Caixa Concredi (Ze)
               
               11/07/2003 - Tratar alinea 11 apos ser devolvido pela 48 (Ze).
               
               29/09/2003 - Tirar a critica 278 do tipo de cta. 6 (Ze)

               06/10/2003 - Passar a ler o craplcm pelo dtrefere (Margarete).
               
               24/10/2003 - Incluir a alinea 30 (Ze Eduardo).

               09/01/2004 - Tratar devolucao de cheques CREDI descontados
                            (Edson)

               21/01/2004 - Tratar alinea 35 (Deborah).
               
               02/02/2004 - Tratar alinea 44 (Edson).
               
               15/09/2004 - Implementar a rotina valida_alinea.p (Edson).
               
               11/10/2004 - Tratar alinea 72 (Ze).

               17/12/2004 - Guardar o RECID do craplcm (Edson).

               30/12/2004 - Ler craplcm por uma faixa de datas (Edson).

               01/07/2005 - Alimentado campo cdcooper da tabela crapsol (Diego).

               12/09/2005 - Devolucao para contas de integracao (Ze Eduardo).
               
               09/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).

               01/11/2005 - Alterado para tratar conta integracao (Edson).

               11/11/2005 - Tratar campo cdcooper na leitura da tabela
                            crapdev (Edson).
                            
               29/12/2005 - Devolver somente cheque compensado (Ze).
               
               26/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

               06/06/2006 - Criado Browse para mostrar os dados, e
                            disponibilizada opcao "Executar Devolucao",
                            ambos quando informar conta = 0 (Diego/Ze).
                            
               30/03/2007 - Acerto para o BANCOOB, Ord. por Conta e Critic (Ze).
              
               20/08/2007 - Acerto para o BANCOOB, Desconto e Custodia (Ze).
               
               01/09/2008 - Alterar lista fixa por um browse para nao
                            estourar e carregar dinamicamente (Gabriel).
                            
               19/02/2009 - Acerto quando gerar devolucoes sem haver chq. (Ze).
               
               20/10/2009 - Padronizacao no formato do campo nrdconta (Ze).

               25/11/2009 - Inclusao de tratamento para Devolucoes banco CECRED
                            de Compe (Guilherme/Precise)

               30/03/2010 - Ajuste quando seleciona o Cheque a ser devolvido 
                            (Ze).
                            
               28/07/2010 - Acertos para devolucao cheques da CECRED (Ze).
               
               26/11/2010 - Ajuste na devolucao CECRED (Ze).
               
               02/12/2010 - Permitir contraordenar cheques apos compensado e
                            incluir no arquivo de devolucao (Ze).
                            
               11/01/2011 - Ajuste para a Migracao do PAC VIACREDI (Ze).
               
               19/01/2011 - Ajustes Gerais (Ze).
               
               08/02/2011 - Desprezar lancamentos do dia para Custodia e 
                            Desconto (Ze).
                            
               02/05/2011 - Considerar a alinea 25 (Ze).
               
               16/05/2011 - Incluir a alinea 39 (Ze).  
               
               23/05/2011 - Incluir a alinea 32 (Ze).
               
               31/05/2011 - Incluir a alinea 41 (Diego).
               
               14/06/2011 - Incluir a alinea 43 (Diego).
               
               12/11/2011 - Criticar a alinea 32 - Nao sera mais aceito
                            - Trf. 43954 (ZE).
                            
               13/12/2011 - Sustacao Provisoria (Andre R./Supero)
               
               25/04/2012 - Solicitacao de bloqueio de devolucao - Trf. 46177
                            (Ze).
                            
               11/06/2012 - Incluir alinea 42 (Ze).             
               
               02/08/2012 - Removido opcao de execucao da devolucao. (Fabricio)
                                             
               06/08/2012 - Adicionado parametro "codigo do programa" a chamada
                            da funcao geradev. (Fabricio)
                            
               20/12/2012 - Adaptacao para a Migracao AltoVale (Ze).
               
               28/01/2013 - Utilizar campo w_lancto.cdcooper na procedure 
                            'proc_gera_dev' (Diego).
               
               02/07/2013 - Gerar Log da Devolucao de Cheque (Anderson/AMCOM).
               
               19/11/2013 - Incluido tratamento para conta migrada da 
                            Acredi->Viacredi e efetuada correcao na validacao
                            dos campos aux_cdbanchq e aux_cdagechq quando for
                            cheque de conta migrada - Softdesk 106687 (Diego).
                            
               03/01/2014 - Tratamento para Migracao Acredi/Viacredi (Ze).
               
               27/01/2014 - Corrigido atribuicao da variavel aux_dsoperac;
                            quando w_lancto.flag = true entao 'marcou', senao,
                            'desmarcou'. (Fabricio)
                   
               24/07/2014 - Tratamento para marcar devolucoes apenas para
                            CECRED e mostrar mensagem especifica para cada
                            banco (Tiago/ Diego SD 179305).        
                            
               31/10/2014 - Incluso tratamento para incorporacao VIACON e
                            SCRMIL (Daniel).      
                            
               16/06/2015 - #281178 Para separar os lançamentos manuais ref. a 
                            cheque compensado e não integrado dos demais 
                            lançamentos, foi criado o historico 1873 com base 
                            no 521. Tratamento p hist 1873 igual ao tratamento 
                            do hist 521 (Carlos)
                            
               07/08/2015 - Ajuste na consulta na tabela craplcm para melhorias
                            de performace SD281896 (Odirlei-AMcom)             
                            
               20/11/2015 - #338222 Ajuste de formatação do valor do cheque no
                            procedure gera_log (Carlos)
                            
               07/12/2015 - #367740 Criado o tratamento para o historico 1874 
                            assim como eh feito com o historico 1873 (Carlos)
               
               14/12/2015 - Incluir tratamento da alinea 59 SD360177 (Odirlei-AMcom)
               
               21/12/2015 - Utilizar a procedure convertida na bo 175 para as 
                            validacoes de alinea, conforme revisao de alineas
                            e processo de devolucao de cheque (Douglas - Melhoria 100)
............................................................................. */


{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }

{ includes/gg0000.i }

DEF   VAR h-b1wgen0175 AS HANDLE                                       NO-UNDO.

DEF   VAR s_title      AS CHAR                                         NO-UNDO.

DEF   VAR tel_nrdconta AS INTE    FORMAT "zzzz,zzz,9"                  NO-UNDO.
DEF   VAR tel_cdalinea AS INTE                                         NO-UNDO.

DEF   VAR aux_cddopcao AS CHAR                                         NO-UNDO.
DEF   VAR aux_confirma AS CHAR    FORMAT "!"                           NO-UNDO.
DEF   VAR aux_regexist AS LOGI                                         NO-UNDO.
DEF   VAR aux_cddsenha AS CHAR    FORMAT "x(8)"                        NO-UNDO.

DEF   VAR tel_dtrefere AS DATE                                         NO-UNDO.
DEF   VAR tel_dtlimite AS DATE                                         NO-UNDO.

DEF   VAR p_opcao      AS CHAR    EXTENT 3 INIT  
                                  ["Devolver","","Executar Devolucao"] NO-UNDO.

DEF   VAR aux_cddevolu AS INTE                                         NO-UNDO.
DEF   VAR aux_cdagechq AS INTE                                         NO-UNDO.
DEF   VAR aux_cdbanchq AS INTE                                         NO-UNDO.
DEF   VAR aux_ultlinha AS INTE                                         NO-UNDO.
DEF   VAR aux_flghrexe AS LOG                                          NO-UNDO.

DEF   VAR tel_opgerdev AS CHAR    LABEL ""
                                  VIEW-AS SELECTION-LIST INNER-LINES 3
                                  INNER-CHARS 32 list-items
                                  "Devolucoes BANCOOB",
                                  "Devolucoes CONTA BASE", 
                                  "Devolucoes CONTA INTEGRACAO"        NO-UNDO.

DEF  VAR aut_flgsenha AS LOGICAL                                       NO-UNDO.
DEF  VAR aut_cdoperad AS CHAR                                          NO-UNDO.

DEF  VAR aux_valorvlb AS DECI                                          NO-UNDO.

DEF  VAR aux_cdcooper AS INT                                           NO-UNDO.
DEF  VAR aux_nrdconta AS INT                                           NO-UNDO.
DEF  VAR aux_cdcopfdc AS INT                                           NO-UNDO.

DEF  BUFFER crabcop FOR crapcop.

DEF TEMP-TABLE w_lancto                                                NO-UNDO
    FIELD cdcooper AS INT
    FIELD dsbccxlt AS CHAR FORMAT               "x(8)"
    FIELD nrdocmto AS DECI FORMAT         "zz,zzz,zz9"
    FIELD nrdctitg AS CHAR FORMAT        "9.999.999-X"
    FIELD cdbanchq AS INT  FORMAT              "z,zz9"
    FIELD banco    AS INT  FORMAT              "z,zz9"
    FIELD cdagechq AS INT  FORMAT              "z,zz9"
    FIELD nrctachq AS DEC
    FIELD vllanmto AS DECI FORMAT  "zz,zzz,zzz,zz9.99"
    FIELD dssituac AS CHAR FORMAT              "x(10)"
    FIELD cdalinea AS INTE FORMAT                "zz9"
    FIELD nmoperad AS CHAR FORMAT              "x(18)"
    FIELD cddsitua AS INTE FORMAT                "zz9"
    FIELD flag     AS LOGI
    FIELD nrdrecid AS RECID.

FORM tel_opgerdev AT 1 
     HELP "Pressione ENTER para selecionar / <F4> para finalizar"
     WITH NO-LABEL CENTERED OVERLAY ROW 13 WIDTH 39 TITLE 
     "ESCOLHA UMA DAS OPCOES:" FRAME f_geradev.

FORM tel_cdalinea  AT  1 LABEL  "Codigo da Alinea "  FORMAT "zz9"
     HELP "Entre com o codigo da alinea."
 VALIDATE(CAN-FIND (crapali WHERE crapali.cdalinea = tel_cdalinea), 
          "412 - Alinea invalida")
     WITH SIDE-LABELS ROW 13 CENTERED OVERLAY FRAME f_alinea.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM tel_nrdconta     AT  3 LABEL "Conta/dv" 
                            HELP "Entre com o numero da conta do associado."
     crapass.nmprimtl AT 27 NO-LABEL
     SKIP (1)
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_devolu.

FORM SPACE(10)
     p_opcao[1] FORMAT "x(8)" 
     "  "
     p_opcao[2] FORMAT "x(10)"
     "  "
     p_opcao[3] FORMAT "x(18)"
     SPACE(4)
     WITH ROW 20 CENTERED NO-BOX NO-LABELS OVERLAY FRAME f_opcoes.

FORM SKIP(1) SPACE(2) aux_cddsenha LABEL "Informe a senha" 
     BLANK SPACE(2) SKIP(1)
     WITH FRAME f_senha TITLE " Autorizacao " 
        ROW 12 CENTERED SIDE-LABELS OVERLAY.

DEF QUERY q_devolv FOR crapdev FIELDS(cdbccxlt nrdconta nrcheque 
                                      vllanmto cdalinea insitdev
                                      nrdctabb cdagechq),
                       crapope FIELDS(nmoperad).    
           
DEF QUERY q_lancto FOR w_lancto.                                     
                                     
DEF BROWSE b_devolv QUERY q_devolv 
    DISP   crapdev.cdbccxlt    COLUMN-LABEL "Bco"
           crapdev.cdagechq    COLUMN-LABEL "Age"     FORMAT "z,zz9"
           IF   crapdev.cdbccxlt = 85 THEN crapdev.nrdctabb
                                      ELSE crapdev.nrdconta     
                               COLUMN-LABEL "Conta/dv"   FORMAT "zzzz,zzz,9"
           crapdev.nrcheque    COLUMN-LABEL "Cheque"     FORMAT "zzz,zz9,9"
           crapdev.vllanmto    COLUMN-LABEL "Valor"      FORMAT "zzz,zzz,zz9.99"
           crapdev.cdalinea    COLUMN-LABEL "Alinea" 
           IF   crapdev.insitdev = 0   THEN  "a devolver"
           ELSE 
           IF   crapdev.insitdev = 1   THEN  "devolvido"
           ELSE
                "indefinida"   COLUMN-LABEL "Situacao"   FORMAT "x(10)"
           crapope.nmoperad    COLUMN-LABEL "Operador"   FORMAT "x(14)"
           WITH 8 DOWN WIDTH 77 OVERLAY TITLE COLOR NORMAL s_title.

DEF BROWSE b_lancto QUERY q_lancto
    DISP   w_lancto.dsbccxlt LABEL "Banco"
           w_lancto.cdagechq LABEL "Age"
           w_lancto.nrdocmto LABEL "Cheque"
           w_lancto.vllanmto LABEL "Valor"
           w_lancto.dssituac LABEL "Situacao"
           w_lancto.cdalinea LABEL "Alinea"
           w_lancto.nmoperad LABEL "Operador"
           WITH 8 DOWN WIDTH 78 OVERLAY TITLE s_title.

FORM SKIP(1)
     b_devolv  HELP "Pressione ENTER para selecionar / <F4> para finalizar" 
     SKIP
     WITH NO-BOX ROW 7 COLUMN 2 OVERLAY FRAME f_devolv.   
     
FORM SKIP(1)
     b_lancto HELP "Pressione ENTER para selecionar / <F4> para finalizar"
     SKIP                 
     WITH NO-BOX ROW 7 CENTERED OVERLAY FRAME f_lancto. 

/* Seleciona Conta Base ou Conta Integracao */
ON RETURN OF tel_opgerdev DO:
        
   ASSIGN aux_cddevolu = 1.
   
   IF   SUBSTRING(tel_opgerdev:SCREEN-VALUE,12,07) = "BANCOOB" THEN
        aux_cddevolu = 1.
   ELSE     
   IF   SUBSTRING(tel_opgerdev:SCREEN-VALUE,18,04) = "BASE" THEN
        aux_cddevolu = 2.
   ELSE
   IF   SUBSTRING(tel_opgerdev:SCREEN-VALUE,18,10) = "INTEGRACAO" THEN
        aux_cddevolu = 3.

   APPLY "GO".

END.

/*........................................................................... */
/* Executa Devolucao */    
ON RETURN OF b_devolv DO:

    RUN proc_exec_dev.

END.

/* Marcar p/ Devolucao */
ON RETURN OF b_lancto DO:

    /*     Se passou da hora limite cadastrada, o sistema exigira */
    /*     a senha dod coordenador para marcar os cheques         */
                             /*085*/
    IF   w_lancto.dsbccxlt = "CECRED" THEN 
         DO:
             DO WHILE TRUE:

                IF   w_lancto.vllanmto >= aux_valorvlb THEN
                     DO:
                         RUN verifica_hora_execucao(INPUT 2, 
                                                    OUTPUT aux_flghrexe).

                         IF   aux_flghrexe THEN
                              DO:
                                  MESSAGE "Hora limite para marcar cheques " +
                                          "VLB foi ultrapassada!".

                                  PAUSE 5 NO-MESSAGE.
                                  RETURN.
                              END.
                         ELSE
                              LEAVE.
                     END.
                ELSE
                     DO:
                         RUN verifica_hora_execucao(INPUT 4, 
                                                    OUTPUT aux_flghrexe).

                         IF   aux_flghrexe THEN 
                              DO:
                                  MESSAGE "Hora limite para marcar cheques " +
                                          "foi ultrapassada!".
                                  PAUSE MESSAGE 
                               "Para continuar, peca liberacao ao Coordenador". 
                                  RUN fontes/pedesenha.p 
                                               (INPUT glb_cdcooper,
                                                INPUT 2, 
                                                OUTPUT aut_flgsenha,
                                                OUTPUT aut_cdoperad).

                                  IF   aut_cdoperad = "888" THEN 
                                       DO:
                                           MESSAGE 'Acesso Operador 888 " + 
                                                   "nao permitido!'.
                                           BELL.
                                           NEXT.
                                       END.

                                  IF  aut_flgsenha THEN
                                      LEAVE.
                
                                  NEXT.
                              END.
                         ELSE
                              LEAVE.
                     END.

             END.
         END.
    ELSE
        DO:
            CASE w_lancto.cdbanchq:
                WHEN   1  THEN DO:
                    /* B.BRASIL */
                    MESSAGE "Efetue a devolucao pelo Gerenciador Financeiro.".
                    BELL.
                    NEXT.
                END.
                WHEN 756  THEN DO:
                    /* BANCOOB */
                    MESSAGE "Efetue a devolucao pela Intranet Bancoob.".
                    BELL.
                    NEXT.
                END.
            END CASE.
        END.

    RUN proc_gera_dev. 
    
    RUN gera_log. 
    
    APPLY "GO".
END.    
     
    
VIEW FRAME f_moldura.

PAUSE 0.

/*  Busca dados da cooperativa  */
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         BELL.
         ASSIGN glb_cdcritic = 0
                glb_dscritic = "".
         NEXT.
     END.
         
/* Leitura da tabela com o valor definido para cheque VLB */ 
FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "GENERI"      AND
                   craptab.cdempres = 0             AND
                   craptab.cdacesso = "VALORESVLB"  AND
                   craptab.tpregist = 0             
                   NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 55.
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         BELL.
         ASSIGN glb_cdcritic = 0
                glb_dscritic = "".
         NEXT.
     END.

ASSIGN aux_valorvlb = DECIMAL(ENTRY(2, craptab.dstextab, ";")).
         


ASSIGN s_title = " Lancamentos do dia " + STRING(glb_dtmvtoan,"99/99/9999") + 
                 "  "
       tel_dtrefere = glb_dtmvtoan
       tel_dtlimite = glb_dtmvtolt
       glb_cdcritic = 0
       glb_nrdrecid = 0.
           
DO WHILE TRUE:

   RUN fontes/inicia.p.
   
   EMPTY TEMP-TABLE w_lancto.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               ASSIGN glb_cdcritic = 0
                      glb_dscritic = "".
           END.

      UPDATE tel_nrdconta WITH FRAME f_devolu.

      ASSIGN glb_nrcalcul = tel_nrdconta
             tel_cdalinea = 0
             aux_regexist = FALSE
             glb_cddopcao = "D"
             aux_cdbanchq = 0
             aux_cdagechq = 0.

      IF  tel_nrdconta > 0 THEN
          DO:
              RUN fontes/digfun.p.

              FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                                 crapass.nrdconta = tel_nrdconta 
                                 NO-LOCK NO-ERROR.

              IF   NOT glb_stsnrcal OR  NOT AVAILABLE crapass   THEN
                   DO:
                       glb_cdcritic = IF   NOT glb_stsnrcal THEN
                                           8
                                      ELSE 9.
                       NEXT.
                   END.

              IF   aux_cddopcao <> glb_cddopcao   THEN
                   DO:
                       { includes/acesso.i}
                       aux_cddopcao = glb_cddopcao.
                   END.

              DISPLAY crapass.nmprimtl WITH FRAME f_devolu.
           
          END.
     
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   tel_nrdconta = 0 THEN
        DO:
            DISPLAY "Todas as devolucoes " @ crapass.nmprimtl 
                    WITH FRAME f_devolu.
        END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "DEVOLU"   THEN
                 DO:
                     HIDE FRAME f_devolu.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            NEXT.
        END.

   IF   tel_nrdconta = 0 THEN 
        DO:
            COLOR DISPLAY MESSAGE p_opcao[3] WITH FRAME f_opcoes.
            
            DISPLAY p_opcao WITH FRAME f_opcoes. 
            
            HIDE p_opcao[1] IN FRAME f_opcoes.
            
            PAUSE 0. 

            IF   glb_cdcooper = 16 THEN
                 OPEN QUERY q_devolv FOR EACH crapdev WHERE 
                                        (crapdev.cdcooper =  16            AND
                                         crapdev.cdhistor <> 46            AND
                                        (crapdev.dtmvtolt = glb_dtmvtolt   OR
                                         crapdev.cdoperad = "1"))          OR
                                        (crapdev.cdcooper =  1             AND
                                         crapdev.cdpesqui = "TCO"          AND
                                         crapdev.cdhistor <> 46)       NO-LOCK,
                     EACH crapope WHERE  crapope.cdcooper = glb_cdcooper   AND 
                                         crapope.cdoperad = crapdev.cdoperad
                                         NO-LOCK BY crapdev.nrdconta.
            ELSE
            IF   glb_cdcooper = 1 THEN
                 OPEN QUERY q_devolv FOR EACH crapdev WHERE 
                                        (crapdev.cdcooper =  1             AND
                                         crapdev.cdhistor <> 46            AND
                                        (crapdev.dtmvtolt = glb_dtmvtolt   OR
                                         crapdev.cdoperad = "1"))          OR
                                        (crapdev.cdcooper =  2             AND
                                         crapdev.cdpesqui = "TCO"          AND
                                         crapdev.cdhistor <> 46)       NO-LOCK,
                     EACH crapope WHERE  crapope.cdcooper = glb_cdcooper   AND 
                                         crapope.cdoperad = crapdev.cdoperad
                                         NO-LOCK BY crapdev.nrdconta.
            ELSE     
                 OPEN QUERY q_devolv FOR EACH crapdev WHERE 
                                         crapdev.cdcooper =  glb_cdcooper  AND
                                         crapdev.cdhistor <> 46            AND
                                        (crapdev.dtmvtolt = glb_dtmvtolt   OR
                                         crapdev.cdoperad = "1")       NO-LOCK,
                     EACH crapope WHERE  crapope.cdcooper = glb_cdcooper   AND 
                                         crapope.cdoperad = crapdev.cdoperad
                                         NO-LOCK BY crapdev.nrdconta.
                   

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               UPDATE b_devolv WITH FRAME f_devolv.
               LEAVE.
            END.
                           
            HIDE FRAME f_devolv
                 FRAME f_opcoes.
           
            NEXT.

        END.
            
   /* ....................................................................... */
   
   IF   CAN-DO("1",STRING(glb_cdcooper)) THEN  /* CUIDAR COM A COOP */
        IF   glb_dtmvtolt = 09/12/2008  THEN     
             tel_dtrefere = 09/10/2008.

   /* ....................................................................... */
   FOR EACH craphis NO-LOCK
            WHERE craphis.cdcooper = glb_cdcooper
              AND CAN-DO("50,59,153,313,340,358,524,572,21,521,1873,1874",
                         STRING(craphis.cdhistor)):

       FOR EACH craplcm WHERE craplcm.cdcooper  = glb_cdcooper                  AND
                              craplcm.nrdconta  = tel_nrdconta                  AND
                              craplcm.dtmvtolt >= tel_dtrefere                  AND
                              craplcm.cdhistor = craphis.cdhistor               AND
                             (craplcm.dtrefere >= tel_dtrefere                  AND
                              craplcm.dtrefere <= tel_dtlimite)                
                             /* nao colocar > e deixar pois tem os cheques da 
                                consumo que sao devolvidos um dia apos */ 
                              USE-INDEX craplcm2 NO-LOCK:
                                        
           IF CAN-DO("21,521,1873,1874",STRING(craplcm.cdhistor)) AND 
              craplcm.cdbccxlt <> 100 THEN
              DO:
                NEXT.
              END.
    
           IF   craplcm.nrdolote = 7009 OR
                craplcm.nrdolote = 7010 THEN
                DO:
                    FIND FIRST craptco WHERE craptco.cdcooper = craplcm.cdcooper AND
                                             craptco.nrdconta = craplcm.nrdconta AND
                                             craptco.tpctatrf = 1                AND
                                             craptco.flgativo = TRUE
                                             NO-LOCK NO-ERROR.
        
                    IF   AVAILABLE craptco THEN
                         ASSIGN aux_nrdconta = craptco.nrctaant
                                aux_cdcooper = craptco.cdcopant.       
                    ELSE
                         ASSIGN aux_nrdconta = craplcm.nrdctabb
                                aux_cdcooper = glb_cdcooper.
                END.
           ELSE
                ASSIGN aux_nrdconta = craplcm.nrdctabb
                       aux_cdcooper = glb_cdcooper.
           
           /*   Desprezar lancamentos do dia para Custodia e Desconto  */
                                        
           IF   craplcm.cdbccxlt = 100          AND
                craplcm.dtrefere = tel_dtlimite AND
              ((craplcm.cdhistor = 21           AND
                craplcm.nrdolote = 4500)        OR
               (craplcm.cdhistor = 521          AND
                craplcm.nrdolote = 4501)        OR 
               (craplcm.cdhistor = 1873         AND
                craplcm.nrdolote = 4501)        OR 
               (craplcm.cdhistor = 1874         AND
                craplcm.nrdolote = 4501))       THEN
                NEXT.
           
           IF   craplcm.cdbccxlt  = 100          AND
                craplcm.dtmvtolt <= glb_dtmvtoan THEN
                DO:
                    IF   ((craplcm.cdhistor = 21       AND
                           craplcm.nrdolote = 4500)    OR
                          (craplcm.cdhistor = 521      AND
                           craplcm.nrdolote = 4501)    OR 
                          (craplcm.cdhistor = 1873     AND
                           craplcm.nrdolote = 4501)    OR
                          (craplcm.cdhistor = 1874     AND
                           craplcm.nrdolote = 4501))   THEN
                         .
                    ELSE     
                         NEXT.
                END.
    
           /*  Consulta o Cheque p/ verificar se esta com indicador 5 COMPENSADO */
    
           RUN fontes/digbbx.p (INPUT  aux_nrdconta,
                                OUTPUT glb_dsdctitg,
                                OUTPUT glb_stsnrcal).
    
    
           /*  Tratamento para TCO - Contas Migradas  */
    
           FIND crabcop WHERE crabcop.cdcooper = aux_cdcooper 
                              NO-LOCK NO-ERROR.
                    
           IF   NOT AVAILABLE crabcop THEN
                DO:
                    glb_cdcritic = 651.
                    RUN fontes/critic.p.
                    MESSAGE glb_dscritic.
                    BELL.
                    ASSIGN glb_cdcritic = 0
                           glb_dscritic = "".
                    NEXT.
                END.
           
           IF   craplcm.cdbccxlt <> 100 THEN   /*  Cheque vindos da Compensacao  */
                DO:
                    IF   craplcm.cdbccxlt = 756 THEN
                         ASSIGN aux_cdbanchq = 756
                                aux_cdagechq = crabcop.cdagebcb.
                    ELSE
                    IF   craplcm.cdbccxlt = 85 THEN
                         ASSIGN aux_cdbanchq = 85
                                aux_cdagechq = crabcop.cdagectl.
                    ELSE
                         ASSIGN aux_cdbanchq = 1
                                aux_cdagechq = crabcop.cdageitg.
                END.                           
           ELSE
                     /*  Para Cheque vindos do Desconto de Cheques e Custodia  */
                DO:
                    ASSIGN aux_cdbanchq = craplcm.cdbanchq.
                    
                    IF   craplcm.cdbanchq = 756 THEN
                         ASSIGN aux_cdagechq = crabcop.cdagebcb. 
                    ELSE
                    IF   craplcm.cdbanchq = 85 THEN
                         ASSIGN aux_cdagechq = crabcop.cdagectl.
                    ELSE
                         ASSIGN aux_cdagechq = crabcop.cdageitg.
                END.
    
           ASSIGN aux_cdcopfdc = 0.
    
           FIND crapfdc WHERE crapfdc.cdcooper = aux_cdcooper                   AND
                              crapfdc.cdbanchq = aux_cdbanchq                   AND
                              crapfdc.cdagechq = aux_cdagechq                   AND
                              crapfdc.nrctachq = aux_nrdconta                   AND
                              crapfdc.nrcheque = 
                              INT(SUBSTR(STRING(craplcm.nrdocmto,"99999999"),1,7))
                              USE-INDEX crapfdc1 NO-LOCK NO-ERROR.

           IF   NOT AVAILABLE crapfdc THEN
                DO:
                    /*   Tratamento para as contas migradas da 
                         Viacredi->AltoVale e da Acredi->Viacredi
                         Concredi->Viacredi e da Credimilsul->Scrcred 
                         */
                    IF   glb_cdcooper = 16  OR 
                         glb_cdcooper = 1   OR
                         glb_cdcooper = 13  THEN
                         DO:
                             FIND craptco WHERE 
                                  craptco.cdcooper = craplcm.cdcooper AND
                                  craptco.nrdconta = craplcm.nrdconta AND
                                  craptco.tpctatrf = 1                AND
                                  craptco.flgativo = TRUE
                                  NO-LOCK NO-ERROR.
        
                             IF   AVAILABLE craptco THEN
                                  DO:
                                      FIND crabcop WHERE 
                                           crabcop.cdcooper = craptco.cdcopant 
                                           NO-LOCK NO-ERROR.
                    
                                      IF   NOT AVAILABLE crabcop THEN
                                           DO:
                                               glb_cdcritic = 651.
                                               RUN fontes/critic.p.
                                               MESSAGE glb_dscritic.
                                               BELL.
                                               ASSIGN glb_cdcritic = 0
                                                      glb_dscritic = "".
                                               NEXT.
                                           END.
           
                                      ASSIGN aux_nrdconta = craptco.nrctaant
                                             aux_cdcooper = craptco.cdcopant.       
                                      
                                      /*  Cheque vindos da Compensacao  */
    
                                      aux_cdbanchq = IF   craplcm.cdbccxlt <> 100
                                                          THEN craplcm.cdbccxlt
                                                     ELSE craplcm.cdbanchq.
                                                          
                                      IF   aux_cdbanchq = 756 THEN
                                           ASSIGN aux_cdagechq = crabcop.cdagebcb. 
                                      ELSE
                                      IF   aux_cdbanchq = 85 THEN
                                           ASSIGN aux_cdagechq = crabcop.cdagectl.
                                      ELSE
                                           ASSIGN aux_cdagechq = crabcop.cdageitg.
    
                                      /* Cheques incorporados - copiados para coop nova */ 
                                      IF   craptco.cdcopant = 4 OR
                                           craptco.cdcopant = 15 THEN
                                           ASSIGN aux_cdcopfdc = craptco.cdcooper.
                                      ELSE
                                          /* Cheques migrados - permanecem na coop antiga */ 
                                           ASSIGN aux_cdcopfdc = craptco.cdcopant.
                                           
                                      FIND crapfdc WHERE 
                                           crapfdc.cdcooper = aux_cdcopfdc     AND
                                           crapfdc.cdbanchq = aux_cdbanchq     AND
                                           crapfdc.cdagechq = aux_cdagechq     AND
                                           crapfdc.nrctachq = craptco.nrctaant AND
                                           crapfdc.nrcheque = 
                                               INT(SUBSTR(STRING(craplcm.nrdocmto,
                                                   "99999999"),1,7))
                                           USE-INDEX crapfdc1 NO-LOCK NO-ERROR. 
                                  END.
                         END.
                END.
    
                
           IF   NOT AVAILABLE crapfdc THEN
                DO:
                    glb_cdcritic = 244.
                    RUN fontes/critic.p.
                    MESSAGE glb_dscritic + " -> Cheque: " + 
                            STRING(craplcm.nrdocmto,"99999999").
                    BELL.
                    ASSIGN glb_cdcritic = 0
                           glb_dscritic = "".
                    NEXT.
                END.
    
           IF   crapfdc.incheque <> 5 AND
                crapfdc.incheque <> 6 THEN
                NEXT.
     
           CREATE w_lancto.
     
           CASE crapfdc.cdbanchq:
            
               WHEN   1  THEN w_lancto.dsbccxlt = "B.BRASIL".
               WHEN  85  THEN w_lancto.dsbccxlt = "CECRED".
               WHEN 756  THEN w_lancto.dsbccxlt = "BANCOOB".
               WHEN 104  THEN w_lancto.dsbccxlt = "CEF".
    
           END CASE. 
           
           ASSIGN w_lancto.cdcooper = IF   aux_cdcopfdc > 0  THEN
                                           aux_cdcopfdc
                                      ELSE aux_cdcooper
                  w_lancto.nrdocmto = craplcm.nrdocmto   
                  w_lancto.vllanmto = craplcm.vllanmto   
                  w_lancto.nrdctitg = craplcm.nrdctitg   
                  w_lancto.cdbanchq = crapfdc.cdbanchq   
                  w_lancto.cdagechq = crapfdc.cdagechq   
                  w_lancto.nrctachq = crapfdc.nrctachq   
                  w_lancto.banco    = aux_cdbanchq       
                  w_lancto.dssituac = "normal"
                  w_lancto.cddsitua = 0
                  w_lancto.flag     = FALSE
                  w_lancto.nrdrecid = RECID(craplcm)     
    
                  aux_regexist      = TRUE 
          
                  glb_nrcalcul      = crapfdc.nrcheque * 10.
           
           RUN fontes/digfun.p.
           
           FIND FIRST crapdev WHERE crapdev.cdcooper = w_lancto.cdcooper   AND
                                    crapdev.cdbanchq = crapfdc.cdbanchq    AND
                                    crapdev.cdagechq = crapfdc.cdagechq    AND
                                    crapdev.nrctachq = crapfdc.nrctachq    AND
                                    crapdev.nrcheque = INTE(glb_nrcalcul)  AND
                                    crapdev.cdhistor <> 46      
                                    NO-LOCK NO-ERROR.
                                             
           IF   AVAILABLE crapdev THEN
                DO:
                    CASE crapdev.insitdev:
                    
                        WHEN 0 THEN w_lancto.dssituac = "a devolver".
                        WHEN 1 THEN w_lancto.dssituac = "devolvido".
                        OTHERWISE   w_lancto.dssituac = "indefinida".
    
                    END CASE.
                    
                    FIND crapope WHERE 
                         crapope.cdcooper = glb_cdcooper       AND
                         crapope.cdoperad = crapdev.cdoperad   NO-LOCK NO-ERROR.
                    
                    ASSIGN w_lancto.cddsitua = crapdev.insitdev
                           w_lancto.flag     = TRUE
                           w_lancto.cdalinea = crapdev.cdalinea
                           w_lancto.nmoperad = IF   AVAILABLE crapope   THEN
                                                    crapope.nmoperad
                                               ELSE
                                                    STRING(crapdev.cdoperad) + 
                                                    " Nao cadastrado".
                
                END.
                                      
       END. /* FOR EACH */
   END. /* FOR EACH CRAPHIS*/

   IF   NOT aux_regexist THEN
        DO:
           glb_cdcritic = 81.
           NEXT.
        END.

   COLOR DISPLAY MESSAGE p_opcao[1] WITH FRAME f_opcoes.
   DISPLAY p_opcao WITH FRAME f_opcoes. 
   HIDE p_opcao[3] IN FRAME f_opcoes.  

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      PAUSE 0.
      
      IF   glb_cdcritic > 0   OR 
           glb_dscritic <> "" THEN
           DO:
               IF glb_dscritic = "" THEN
                   RUN fontes/critic.p.

               MESSAGE glb_dscritic.
               BELL.
               ASSIGN glb_cdcritic = 0
                      glb_dscritic = "".
           END.
      
      OPEN QUERY q_lancto FOR EACH w_lancto EXCLUSIVE-LOCK.
      
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         UPDATE b_lancto WITH FRAME f_lancto.
         LEAVE.
      END.
      
      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
           DO:
               HIDE FRAME f_lancto
                    FRAME f_alinea    
                     FRAME f_opcoes.
               LEAVE.
           END.

   END.  /* Fim do DO WHILE TRUE */
   
END. /* Fim do DO WHILE TRUE */


PROCEDURE proc_gera_dev:

     IF   w_lancto.cddsitua = 1   THEN   /* Devolvido */
          DO:
              glb_cdcritic = 414.
              RETURN.
          END. 

     glb_nrcalcul = INT(SUBSTR(STRING(w_lancto.nrdocmto,"9999999"),1,6)).

     FIND crapfdc WHERE crapfdc.cdcooper = w_lancto.cdcooper   AND
                        crapfdc.cdbanchq = w_lancto.cdbanchq   AND
                        crapfdc.cdagechq = w_lancto.cdagechq   AND
                        crapfdc.nrctachq = w_lancto.nrctachq   AND
                        crapfdc.nrcheque = INT(glb_nrcalcul)
                        USE-INDEX crapfdc1 NO-LOCK NO-ERROR. 

     IF   NOT AVAILABLE crapfdc THEN
          DO:
              glb_cdcritic = 108.
              RETURN.
          END.

     IF   crapfdc.cdbanchq = 756 THEN
          IF  CAN-FIND(crapsol WHERE
                       crapsol.cdcooper = w_lancto.cdcooper AND
                       crapsol.dtrefere = glb_dtmvtolt      AND
                       crapsol.nrsolici = 78                AND
                       crapsol.nrseqsol = 1) THEN
              DO:       
                  glb_cdcritic = 138.
                  RETURN.
              END.

     IF   crapfdc.cdbanchq = 1 THEN
          DO: 

              IF  CAN-FIND(crapsol WHERE
                           crapsol.cdcooper = w_lancto.cdcooper AND
                           crapsol.dtrefere = glb_dtmvtolt      AND
                           crapsol.nrsolici = 78                AND
                           crapsol.nrseqsol = 2) THEN
                  DO:       
                      glb_cdcritic = 138.
                      RETURN.
                  END.

              IF  CAN-FIND(crapsol WHERE
                           crapsol.cdcooper = w_lancto.cdcooper AND
                           crapsol.dtrefere = glb_dtmvtolt      AND
                           crapsol.nrsolici = 78                AND
                           crapsol.nrseqsol = 3) THEN
                  DO:       
                      glb_cdcritic = 138.
                      RETURN.
                  END.
          END.
         
     IF   crapfdc.cdbanchq = crapcop.cdbcoctl THEN 
          DO:
             IF   w_lancto.vllanmto >= aux_valorvlb THEN
                  DO:
                      IF   CAN-FIND(crapsol WHERE
                                    crapsol.cdcooper = w_lancto.cdcooper AND
                                    crapsol.dtrefere = glb_dtmvtolt      AND
                                    crapsol.nrsolici = 78                AND
                                    crapsol.nrseqsol = 4)           THEN
                           DO:       
                               glb_cdcritic = 138.
                               RETURN.
                           END.                        
                  END.
             ELSE
                  DO:

                      IF   CAN-FIND(crapsol WHERE
                                    crapsol.cdcooper = w_lancto.cdcooper AND
                                    crapsol.dtrefere = glb_dtmvtolt      AND
                                    crapsol.nrsolici = 78                AND
                                    crapsol.nrseqsol = 6)           THEN
                           DO:       
                               glb_cdcritic = 138.
                               RETURN.
                           END.                        
                  END.
          END.


     ASSIGN aux_ultlinha = CURRENT-RESULT-ROW("q_lancto")
            tel_cdalinea = 0.

     IF   NOT w_lancto.flag  THEN      /* marcada */
          DO:  
              HIDE MESSAGE NO-PAUSE.
              
              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 UPDATE tel_cdalinea WITH FRAME f_alinea.
                 LEAVE.
              END.             

              IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                   DO:
                       HIDE FRAME f_alinea.
                       RETURN.
                   END.

              RUN sistema/generico/procedures/b1wgen0175.p
			        PERSISTENT SET h-b1wgen0175.

              IF VALID-HANDLE(h-b1wgen0175) THEN
                  DO:
                      RUN verifica_alinea IN h-b1wgen0175(INPUT glb_cdcooper,
                                                          INPUT glb_dtmvtolt,
                                                          INPUT crapfdc.cdbanchq,
                                                          INPUT crapfdc.cdagechq,
                                                          INPUT crapfdc.nrdconta,
                                                          INPUT w_lancto.nrdocmto,
                                                          INPUT tel_cdalinea,
                                                         OUTPUT TABLE tt-erro).

                      DELETE PROCEDURE h-b1wgen0175.

                      IF RETURN-VALUE <> "OK" THEN 
                          DO:
                              FIND FIRST tt-erro NO-LOCK NO-ERROR.
                              IF AVAIL tt-erro THEN
                              DO:
                                  ASSIGN glb_cdcritic = tt-erro.cdcritic
                                         glb_dscritic = tt-erro.dscritic.
                                  RETURN.
                              END.
                          END.
                  END.
          END.

     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        ASSIGN aux_confirma = "N"
               glb_cdcritic = 78.
        RUN fontes/critic.p.
        BELL.
        MESSAGE glb_dscritic UPDATE aux_confirma.
        LEAVE.
     END.

     HIDE FRAME f_alinea.

     IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
          aux_confirma <> "S" THEN
          DO:
              glb_cdcritic = 79.
              RUN fontes/critic.p.
              BELL.
              MESSAGE glb_dscritic.
              PAUSE 1 NO-MESSAGE.
              ASSIGN glb_cdcritic = 0
                     glb_dscritic = "".
              RETURN.
          END.

     DO TRANSACTION:  /* transacao para devolver */

        IF   w_lancto.flag THEN  /* a devolver */
             DO:
                 ASSIGN w_lancto.dssituac = "normal"
                        w_lancto.flag     = FALSE
                        w_lancto.cdalinea = 0
                        w_lancto.nmoperad = "".
                 
                 CLOSE QUERY q_lancto.
                 OPEN QUERY  q_lancto FOR EACH w_lancto NO-LOCK.
                 REPOSITION  q_lancto TO ROW   aux_ultlinha. 

                 RUN fontes/geradev.p (INPUT  w_lancto.cdcooper,
                                       INPUT  glb_dtmvtolt,
                                       INPUT  w_lancto.banco,
                                       INPUT  5 /* indevchq */,
                                       INPUT  crapfdc.nrdconta,
                                       INPUT  w_lancto.nrdocmto,
                                       INPUT  w_lancto.nrdctitg,
                                       INPUT  w_lancto.vllanmto,
                                       INPUT  tel_cdalinea,
                                       INPUT  47,  /* cdhistor */
                                       INPUT  glb_cdoperad,
                                       INPUT  crapfdc.cdagechq,
                                       INPUT  crapfdc.nrctachq,
                                       INPUT  "devolu",
                                       OUTPUT glb_cdcritic,
                                       OUTPUT glb_dscritic).
       
                 IF   glb_cdcritic <> 0   OR
                      glb_dscritic <> ""  THEN
                      DO:
                          IF  glb_dscritic = "" THEN
                              RUN fontes/critic.p.

                          BELL.
                          MESSAGE glb_dscritic.
                          PAUSE 1 NO-MESSAGE.
                          ASSIGN glb_cdcritic = 0
                                 glb_dscritic = "".
                          RETURN.
                      END.
             END.
        ELSE
             DO: 
                 ASSIGN w_lancto.flag     = TRUE
                        w_lancto.dssituac = "a devolver" 
                        w_lancto.cdalinea = tel_cdalinea
                        w_lancto.nmoperad = STRING(glb_nmoperad,"x(20)")
                        glb_nrdrecid      = w_lancto.nrdrecid.
                 
                 CLOSE QUERY q_lancto.
                 OPEN QUERY  q_lancto FOR EACH w_lancto NO-LOCK.
                 REPOSITION  q_lancto TO ROW   aux_ultlinha.
                 
                 RUN fontes/geradev.p (INPUT  w_lancto.cdcooper,
                                       INPUT  glb_dtmvtolt,
                                       INPUT  w_lancto.banco,
                                       INPUT  1 /* indevchq */,
                                       INPUT  crapfdc.nrdconta,
                                       INPUT  w_lancto.nrdocmto,
                                       INPUT  w_lancto.nrdctitg,  
                                       INPUT  w_lancto.vllanmto,
                                       INPUT  tel_cdalinea,
                                       INPUT  47,  /* cdhistor */
                                       INPUT  glb_cdoperad,
                                       INPUT  crapfdc.cdagechq,
                                       INPUT  crapfdc.nrctachq,
                                       INPUT  "devolu",
                                       OUTPUT glb_cdcritic,
                                       OUTPUT glb_dscritic).
                                   
                 IF   glb_cdcritic <> 0  OR 
                      glb_dscritic <> "" THEN
                      DO:
                          IF  glb_dscritic = "" THEN
                              RUN fontes/critic.p.

                          BELL.
                          MESSAGE glb_dscritic.
                          PAUSE 1 NO-MESSAGE.
                          ASSIGN glb_cdcritic = 0
                                 glb_dscritic = "".
                          RETURN.
                      END.
             END.
                                     
     END. /* Transaction */    
                          
     HIDE FRAME f_opcoes NO-PAUSE.

END PROCEDURE.

PROCEDURE proc_exec_dev:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       UPDATE tel_opgerdev WITH FRAME f_geradev.
       LEAVE.
    END.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
         LASTKEY = KEYCODE("F1")              THEN 
         DO:
             glb_cdcritic = 79.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             ASSIGN glb_cdcritic = 0
                    glb_dscritic = "".
             HIDE FRAME f_geradev.
             RETURN.
         END.

    IF   CAN-FIND(crapsol WHERE crapsol.cdcooper = glb_cdcooper  AND
                                crapsol.dtrefere = glb_dtmvtolt  AND
                                crapsol.nrsolici = 78            AND
                                crapsol.nrseqsol = aux_cddevolu) THEN
         DO:
             glb_cdcritic = 138.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             ASSIGN glb_cdcritic = 0
                    glb_dscritic = "".
             HIDE FRAME f_geradev.
             RETURN.
         END.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       ASSIGN aux_confirma = "N"
              glb_cdcritic = 78.
       RUN fontes/critic.p.
       BELL.
       MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
       ASSIGN glb_cdcritic = 0
              glb_dscritic = "".
       LEAVE.
    END.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
         aux_confirma <> "S" THEN
         DO:
             glb_cdcritic = 79.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             ASSIGN glb_cdcritic = 0
                    glb_dscritic = "".
             HIDE FRAME f_geradev.
             RETURN.
         END.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        ASSIGN aux_cddsenha = ""
               glb_cdcritic = 742.
        RUN fontes/critic.p.
        UPDATE aux_cddsenha WITH FRAME f_senha.
        glb_cdcritic = 0.
        LEAVE.
    END.
    
    HIDE FRAME f_senha NO-PAUSE.
     
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
         glb_cdcritic = 79.
    ELSE
         CASE aux_cddevolu:
                         
            WHEN 1 THEN IF  aux_cddsenha <> "nacndpv"   THEN glb_cdcritic = 03.
            WHEN 2 THEN IF  aux_cddsenha <> "pspcersv"  THEN glb_cdcritic = 03.
            WHEN 3 THEN IF  aux_cddsenha <> "veqsntv"   THEN glb_cdcritic = 03.
         
         END CASE.

    IF   glb_cdcritic > 0 THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             ASSIGN glb_cdcritic = 0
                    glb_dscritic = "".
             HIDE FRAME f_geradev.
             RETURN.
         END.

    DO TRANSACTION:
        CREATE crapsol.
        ASSIGN crapsol.cdcooper = glb_cdcooper
               crapsol.nrsolici = 78
               crapsol.dtrefere = glb_dtmvtolt
               crapsol.cdempres = 11
               crapsol.dsparame = ""
               crapsol.insitsol = 1
               crapsol.nrdevias = 0
               crapsol.nrseqsol = aux_cddevolu.
    END.
                                          
    HIDE MESSAGE  NO-PAUSE.
    
    HIDE FRAME f_geradev.
                                               
    RELEASE crapsol.

    MESSAGE "Executando devolucoes ...".
     
    PAUSE 1 NO-MESSAGE.

    /* Conecta o Banco Generico .................................... */
    IF   f_conectagener() THEN
         DO:
             RUN fontes/crps264.p (INPUT glb_cdcooper,
                                   INPUT aux_cddevolu). 

             RUN p_desconectagener.
         END.
    ELSE
         DO:
             glb_cdcritic = 791.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             ASSIGN glb_cdcritic = 0
                    glb_dscritic = "".

             DO TRANSACTION:

                FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper AND
                                   crapsol.dtrefere = glb_dtmvtolt AND
                                   crapsol.nrsolici = 78           AND
                                   crapsol.nrseqsol = aux_cddevolu
                                   EXCLUSIVE-LOCK NO-ERROR.
                                   
                IF   NOT AVAILABLE crapsol THEN
                     DELETE crapsol.
             END.

             glb_cdcritic = 79.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             PAUSE 5 NO-MESSAGE.
             ASSIGN glb_cdcritic = 0
                    glb_dscritic = "".
         END.
         
END PROCEDURE.

/*............................................................................*/

PROCEDURE verifica_hora_execucao:
/* Parametro de entrada:                                                    */
/* 1 Hr Ini | 2 Hr Fim | 3 Hr Ini | 4 Hr Fim | 5 Hr Ini | 6 Hr Fim          */
   
   DEF INPUT  PARAM par_posicao  AS INTE                              NO-UNDO.
   
/* Verifica se a hora de execucao atual eh maior que a hora gravada          */
/* nos parametros da craptab                                                 */
/* YES = Maior que o parametro                                               */
/* NO  = Menor que o parametro                                               */
   
   DEF OUTPUT PARAM ret_execucao AS LOGI                              NO-UNDO.

   FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                      craptab.nmsistem = "CRED"        AND   
                      craptab.tptabela = "GENERI"      AND
                      craptab.cdempres = 0             AND
                      craptab.cdacesso = "HRTRDEVOLU"  AND
                      craptab.tpregist = 0             NO-LOCK NO-ERROR.
 
   IF   NOT AVAILABLE craptab THEN 
        DO:
            glb_cdcritic = 55. 
            RETURN "NOK".
        END.
   ELSE 
        DO:
            IF   TIME >= INT(ENTRY(par_posicao,craptab.dstextab,";")) THEN
                 ret_execucao = YES.
            ELSE ret_execucao = NO.
        END.
   RETURN "OK".

END PROCEDURE.


PROCEDURE gera_log.

   DEF VAR aux_dsoperac AS CHAR                                 NO-UNDO.

   IF   w_lancto.flag THEN
        aux_dsoperac = "marcou".
   ELSE  
        aux_dsoperac = "desmarcou". 

   UNIX SILENT
        VALUE("echo "+ STRING(glb_dtmvtolt,"99/99/9999")+
        " " + STRING(TIME,"HH:MM:SS") + "' --> '"+
        String(glb_cdoperad) + "-" + TRIM(glb_nmoperad) +
        ", "  + TRIM(aux_dsoperac) + 
        " o cheque "     + string(w_lancto.nrdocmto,"zzz,zz9") +
        " da conta/dv "  + string(w_lancto.nrctachq,"zzzz,zzz,9") +
        " do Banco "     + string(w_lancto.cdbanchq, "zz9") +
        ", valor  "      + string(w_lancto.vllanmto, "zzz,zz9.99") +
        " com alinea "   + string(w_lancto.cdalinea,"z9") +
        " >> /usr/coop/" + TRIM(crapcop.dsdircop)+
        "/log/devolu.log" ).


END PROCEDURE.
/* .......................................................................... */