/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +----------------------------------------+--------------------------------------------------+
  | Rotina Progress                        | Rotina Oracle PLSQL                              |
  +----------------------------------------+--------------------------------------------------+
  | Busca_Historico                        | SSCR0001.pc_busca_historico_scr_car              |
  | Verifica_Dados                         | SSCR0001.pc_verifica_dados_scr_car               |
  | Verifica_Lancamento                    | SSCR0001.pc_verifica_lancamento_scr_car          |
  | Gera_Arquivo                           | SSCR0001.pc_gera_arquivo_scr_car                 |
  | Busca_Lancamento                       | SSCR0001.pc_busca_lancamento_scr_car             |
  | Grava_Lancamento                       | SSCR0001.pc_grava_lancamento_scr_car             |
  | Atualiza_Envio                         | SSCR0001.pc_atualiza_envio_scr_car               |
  | Valida_Senha                           | LOGI0001.pc_val_senha_coordenador                |  
  +----------------------------------------+--------------------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*..............................................................................

   Programa: fontes/cadscr.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Outubro/2008                      Ultima Atualizacao: 08/12/2015

   Dados referentes ao programa:

   Frequencia: Diario (On-Line)
   Objetivo  : Mostrar tela CADSCR.

   Alteracoes: 23/10/2008 - Melhoria na opcao "C" (David).
   
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               28/11/2013 - Ajuste crapscr.dttrans PLSQL (Guilherme)
               
               16/09/2015 - Migração Progress > Oracle (José Luís - DB1)

               08/12/2015 - Ajustes de homologação referente a conversao
                            efetuada pela DB1 
                            (Adriano).
               
..............................................................................*/


/*................................ DEFINICOES ................................*/


{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/gera_erro.i}
  
/* Variavies auxiliares */
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                             NO-UNDO.
DEF VAR aux_dshistor AS CHAR                                           NO-UNDO.
DEF VAR aux_dstphist AS CHAR                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdirscr AS CHAR                                           NO-UNDO.
DEF VAR aux_cdhistor AS INTE                                           NO-UNDO.
DEF VAR aux_ultlinha AS INTE                                           NO-UNDO.
DEF VAR aux_dtmvtolt AS DATE                                           NO-UNDO.
DEF VAR aux_flgsenha AS LOGI                                           NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.

/* Variaveis para interacao de tela */
DEF VAR tel_btaltera AS CHAR INIT "Alterar"                            NO-UNDO.
DEF VAR tel_btexclui AS CHAR INIT "Excluir"                            NO-UNDO.
DEF VAR tel_btinclui AS CHAR INIT "Incluir"                            NO-UNDO.
DEF VAR tel_nrdconta AS INTE                                           NO-UNDO.
DEF VAR tel_vllanmto AS DECI                                           NO-UNDO.
DEF VAR tel_dtsolici AS DATE                                           NO-UNDO.
DEF VAR tel_dtrefere AS DATE                                           NO-UNDO.

/* Variaveis para o XML */ 
DEF VAR xDoc          AS HANDLE                                        NO-UNDO.   
DEF VAR xRoot         AS HANDLE                                        NO-UNDO.  
DEF VAR xRoot2        AS HANDLE                                        NO-UNDO.  
DEF VAR xField        AS HANDLE                                        NO-UNDO. 
DEF VAR xText         AS HANDLE                                        NO-UNDO. 
DEF VAR aux_cont_raiz AS INTEGER                                       NO-UNDO. 
DEF VAR aux_cont      AS INTEGER                                       NO-UNDO. 
DEF VAR ponteiro_xml  AS MEMPTR                                        NO-UNDO. 
DEF VAR xml_req       AS LONGCHAR                                      NO-UNDO.

DEF TEMP-TABLE tt-crapscr NO-UNDO LIKE crapscr
    FIELD dstphist AS CHAR
    FIELD dshistor AS CHAR.

DEF TEMP-TABLE tt-historicos                                           NO-UNDO
    FIELD cdhistor AS INTE 
    FIELD dshistor AS CHAR
    FIELD dstphist AS CHAR
    INDEX tt-historicos1 AS PRIMARY cdhistor.

DEF QUERY q_historicos FOR tt-historicos.
DEF QUERY q_alterar    FOR tt-crapscr.
DEF QUERY q_excluir    FOR tt-crapscr.
DEF QUERY q_consulta   FOR tt-crapscr.

DEF BROWSE b_historicos QUERY q_historicos
    DISP tt-historicos.cdhistor COLUMN-LABEL "Histor"    FORMAT "zzz9"
         tt-historicos.dshistor COLUMN-LABEL "Descricao" FORMAT "x(55)"
         tt-historicos.dstphist COLUMN-LABEL "Tipo"      FORMAT "x(9)"
    WITH NO-BOX OVERLAY 9 DOWN.

DEF BROWSE b_alterar QUERY q_alterar
    DISP tt-crapscr.cdhistor COLUMN-LABEL "Historico" FORMAT "zzz9"
         tt-crapscr.dshistor COLUMN-LABEL "Descricao" FORMAT "x(36)"
         tt-crapscr.dstphist COLUMN-LABEL "Tipo"      FORMAT "x(9)"
         tt-crapscr.vllanmto    COLUMN-LABEL "Valor"     FORMAT "zzz,zzz,zz9.99-"
    WITH OVERLAY NO-BOX 9 DOWN.

DEF BROWSE b_excluir QUERY q_excluir
    DISP tt-crapscr.cdhistor COLUMN-LABEL "Historico" FORMAT "zzz9"
         tt-crapscr.dshistor COLUMN-LABEL "Descricao" FORMAT "x(36)"
         tt-crapscr.dstphist COLUMN-LABEL "Tipo"      FORMAT "x(9)"
         tt-crapscr.vllanmto    COLUMN-LABEL "Valor"     FORMAT "zzz,zzz,zz9.99-"
    WITH OVERLAY NO-BOX 9 DOWN.

DEF BROWSE b_consulta QUERY q_consulta
    DISP tt-crapscr.dtsolici       COLUMN-LABEL "Dt.Solici." FORMAT "99/99/9999"
         tt-crapscr.nrdconta       COLUMN-LABEL "Conta/dv"   FORMAT "zzzz,zzz,9"
         tt-crapscr.dtrefere       COLUMN-LABEL "Dt.Refere." FORMAT "99/99/9999"
         tt-crapscr.cdhistor       COLUMN-LABEL "Hist"       FORMAT "zzz9"
         tt-crapscr.dstphist       COLUMN-LABEL "Tipo"       FORMAT "x(8)"
         tt-crapscr.vllanmto       COLUMN-LABEL "Valor"     FORMAT "zzzzzz,zz9.99-"
         tt-crapscr.dttransm       COLUMN-LABEL "Dt.Envio"   FORMAT "99/99/9999"
    WITH OVERLAY NO-BOX 10 DOWN.
 
FORM WITH ROW 4 COLUMN 1 OVERLAY SIZE 80 BY 18 TITLE glb_tldatela 
     FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao"       FORMAT "!(1)"       AUTO-RETURN 
      HELP "Informe a opcao (C=consulta,B=geracao,L=lancamentos,X=desfazer)"
      VALIDATE (CAN-DO("C,B,L,X",glb_cddopcao),"014 - Opcao errada.")
     tel_dtsolici AT 12 LABEL "Dt.Solic."   FORMAT "99/99/9999" AUTO-RETURN
      HELP "Informe a data de solicitacao"
     tel_dtrefere AT 35 LABEL "Dt.Refer."   FORMAT "99/99/9999" AUTO-RETURN
      HELP "Informe a data de movimento"
     tel_nrdconta AT 58 LABEL "Conta/dv"    FORMAT "zzzz,zzz,9" AUTO-RETURN
      HELP "Informe a conta/dv do associado" 
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

FORM WITH ROW 7 COLUMN 2 OVERLAY SIZE 78 BY 13 FRAME f_browse.
     
FORM b_historicos 
     HELP "Setas para navegar, <ENTER> para incluir, <END>/<F4> para sair."
     WITH ROW 8 NO-BOX CENTERED OVERLAY FRAME f_historicos.
     
FORM b_excluir
     HELP "Setas para navegar, <DELETE> para excluir, <END>/<F4> para sair."
     WITH ROW 8 NO-BOX CENTERED OVERLAY FRAME f_excluir.

FORM b_alterar
     HELP "Setas para navegar, <ENTER> para alterar, <END>/<F4> para sair."
     WITH ROW 8 NO-BOX CENTERED OVERLAY FRAME f_alterar. 
          
FORM b_consulta
     HELP "Use as setas para navegar ou <END>/<F4> para sair."
     WITH ROW 7 CENTERED OVERLAY FRAME f_consulta.
     
FORM tel_btaltera
     SPACE(5)
     tel_btexclui
     SPACE(5)
     tel_btinclui
     WITH ROW 20 CENTERED OVERLAY NO-BOX NO-LABEL FRAME f_botoes.
    
FORM SKIP(1)
     aux_cdhistor AT 02 LABEL "Historico" FORMAT "zzz9"
     SKIP
     aux_dshistor AT 02 LABEL "Descricao" FORMAT "x(61)"
     SKIP
     aux_dstphist AT 02 LABEL "Tipo     " FORMAT "x(10)"
     SKIP
     tel_vllanmto AT 02 LABEL "Valor    " FORMAT "zzz,zzz,zz9.99-"
                  HELP "Informe o valor"
     SKIP(1)
     WITH ROW 8 WIDTH 76 CENTERED OVERLAY SIDE-LABELS FRAME f_valor.
     

/*................................. TRIGGERS .................................*/


ON RETURN OF b_historicos IN FRAME f_historicos DO:

    HIDE MESSAGE NO-PAUSE.

    FIND tt-crapscr WHERE tt-crapscr.cdcooper = glb_cdcooper AND
                          tt-crapscr.nrdconta = tel_nrdconta AND
                          tt-crapscr.dtsolici = tel_dtsolici AND
                          tt-crapscr.dtrefere = tel_dtrefere AND
                          tt-crapscr.cdhistor = INTE(tt-historicos.cdhistor)
                          NO-ERROR.

    ASSIGN tel_vllanmto = IF  AVAILABLE tt-crapscr  THEN
                              tt-crapscr.vllanmto
                          ELSE
                              0
           aux_cdhistor = tt-historicos.cdhistor
           aux_dshistor = tt-historicos.dshistor
           aux_dstphist = tt-historicos.dstphist.
        
    DISPLAY aux_cdhistor 
            aux_dshistor 
            aux_dstphist 
            tel_vllanmto 
            WITH FRAME f_valor.
                
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        UPDATE tel_vllanmto WITH FRAME f_valor.
        LEAVE.            
        
    END.

    IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            HIDE FRAME f_valor NO-PAUSE.
            RETURN.    
        END.

    ASSIGN aux_confirma = "N".
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
       ASSIGN glb_cdcritic = 78.
       RUN fontes/critic.p.
       BELL.
       MESSAGE glb_dscritic UPDATE aux_confirma.
       LEAVE.
    
    END.

    IF  KEY-FUNCTION(LASTKEY) = "END-ERROR" OR aux_confirma <> "S"  THEN
        DO:
            ASSIGN glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            
            RELEASE crapscr.
            HIDE FRAME f_valor NO-PAUSE.
            RETURN.
        END.

    HIDE FRAME f_valor NO-PAUSE.

    /* Executa a store-procedure de gravacao do lancamento */
    RUN Grava_Lancamento(INPUT tel_vllanmto,                   /* Valor     */
                         INPUT STRING(tt-historicos.cdhistor), /* Historico */
                         INPUT (IF AVAILABLE tt-crapscr THEN   /* Operacao  */
                                   "A" 
                                ELSE 
                                   "I") ). 
    
    IF  RETURN-VALUE <> "OK" THEN
        NEXT.
    
END.

ON "RETURN" OF b_alterar IN FRAME f_alterar DO:

    HIDE MESSAGE NO-PAUSE.
    
    ASSIGN glb_dscritic = "".
                
    IF  NOT AVAILABLE tt-crapscr  THEN
        DO: 
            ASSIGN glb_dscritic = "Registro da tabela SCR nao encontrado.".
        END.
    
    IF  glb_dscritic <> ""  THEN
        DO:
            BELL.
            MESSAGE glb_dscritic.
            RETURN.
        END.            

    ASSIGN aux_cdhistor = tt-crapscr.cdhistor
           aux_dshistor = tt-crapscr.dshistor
           aux_dstphist = tt-crapscr.dstphist
           tel_vllanmto = tt-crapscr.vllanmto.
           
    DISPLAY aux_cdhistor 
            aux_dshistor 
            aux_dstphist 
            tel_vllanmto 
            WITH FRAME f_valor.
                
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
       UPDATE tel_vllanmto 
              WITH FRAME f_valor.

       LEAVE.            
        
    END.

    IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            HIDE FRAME f_valor NO-PAUSE.
            RETURN.    
        END.
                   
    ASSIGN aux_confirma = "N".
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
        ASSIGN glb_cdcritic = 78.
        RUN fontes/critic.p.
        BELL.
        MESSAGE glb_dscritic UPDATE aux_confirma.
        LEAVE.
    
    END.

    IF  KEY-FUNCTION(LASTKEY) = "END-ERROR" OR aux_confirma <> "S"  THEN
        DO:
            ASSIGN glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            
            RELEASE crapscr.
            HIDE FRAME f_valor NO-PAUSE.
            RETURN.
        END.

    /* Executa a store-procedure de gravacao do lancamento */
    RUN Grava_Lancamento(INPUT tel_vllanmto,                /* Valor  */
                         INPUT STRING(tt-crapscr.cdhistor), /* Historico */
                         INPUT "A" ).                       /* Operacao  */

    IF  RETURN-VALUE <> "OK" THEN
        NEXT.

    HIDE FRAME f_valor NO-PAUSE.                      

    /* Buscar novamente os lancamentos */
    RUN Busca_Lancamento ( INPUT FALSE ).

    IF  RETURN-VALUE <> "OK" THEN
        NEXT.

    CLOSE QUERY q_alterar.                    
    OPEN QUERY q_alterar FOR EACH tt-crapscr NO-LOCK.

END.
               
ON "DELETE" OF b_excluir IN FRAME f_excluir DO:
        
    HIDE MESSAGE NO-PAUSE.
    
    ASSIGN glb_dscritic = "".
    
    FIND CURRENT tt-crapscr NO-ERROR.
                
    IF NOT AVAILABLE tt-crapscr  THEN
       DO:
           ASSIGN glb_dscritic = "Registro da tabela SCR nao encontrado.".
       END.
    
    IF glb_dscritic <> ""  THEN
       DO:
           BELL.
           MESSAGE glb_dscritic.
           RETURN.
       END.            
          
    ASSIGN aux_confirma = "N".
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
        ASSIGN glb_cdcritic = 78.
        RUN fontes/critic.p.
        BELL.
        MESSAGE glb_dscritic UPDATE aux_confirma.
        LEAVE.
    
    END.

    IF KEY-FUNCTION(LASTKEY) = "END-ERROR" OR aux_confirma <> "S"  THEN
       DO: 
           ASSIGN glb_cdcritic = 79.
           RUN fontes/critic.p.
           BELL.
           MESSAGE glb_dscritic.
           
           RETURN.
       END.

    /* Executa a store-procedure de excluir o lancamento */
    RUN Grava_Lancamento(INPUT 0,     /* Valor     */
                         INPUT STRING(tt-crapscr.cdhistor),   /* Historico */
                         INPUT "E" ). /* Operacao  */

    IF RETURN-VALUE <> "OK" THEN
       NEXT.
    
    DELETE tt-crapscr.

    ASSIGN aux_ultlinha = CURRENT-RESULT-ROW("q_excluir").
                    
    CLOSE QUERY q_excluir.                                                  
    OPEN QUERY q_excluir FOR EACH tt-crapscr NO-LOCK. 
                                      
    REPOSITION q_excluir TO ROW aux_ultlinha NO-ERROR.

END.


/*................................. PRINCIPAL ................................*/


VIEW FRAME f_moldura.

PAUSE(0).

ASSIGN glb_cddopcao = "C".

DISPLAY glb_cddopcao WITH FRAME f_opcao.

DO WHILE TRUE:
                        
   RUN fontes/inicia.p.

   CLEAR FRAME f_opcao ALL NO-PAUSE.
                                   
   ASSIGN tel_dtsolici = ?
          tel_dtrefere = ?
          tel_nrdconta = 0.
                                     
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
      UPDATE glb_cddopcao WITH FRAME f_opcao.
              
      LEAVE.

   END.  

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
      DO:
         RUN fontes/novatela.p.
         
         IF CAPS(glb_nmdatela) <> "CADSCR"  THEN
            DO:
               HIDE FRAME f_moldura NO-PAUSE.
               HIDE FRAME f_opcao   NO-PAUSE.
               
               RETURN.
            END.
         ELSE
            NEXT.
      END.

   IF aux_cddopcao <> glb_cddopcao  THEN
      DO:
         { includes/acesso.i }
         aux_cddopcao = glb_cddopcao.
      END.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      UPDATE tel_dtsolici
             tel_dtrefere WHEN glb_cddopcao = "C" OR glb_cddopcao = "L"
             tel_nrdconta WHEN glb_cddopcao = "C" OR glb_cddopcao = "L"
             WITH FRAME f_opcao

      EDITING:

        READKEY.

        HIDE MESSAGE NO-PAUSE.

        APPLY LASTKEY.

        IF GO-PENDING THEN 
           DO:
              ASSIGN tel_dtsolici = INPUT tel_dtsolici
                     tel_dtrefere = INPUT tel_dtrefere
                     tel_nrdconta = INPUT tel_nrdconta.
              
              /* Verifica se os dados/filtros informados estão corretos */
              RUN Verifica_Dados.

              IF  RETURN-VALUE <> "OK" THEN DO:
                  {sistema/generico/includes/foco_campo.i &VAR-GERAL=SIM 
                      &NOME-FRAME="f_opcao"
                      &NOME-CAMPO=aux_nmdcampo}
                      
              END.

        END.

      END. /* EDITING */
                                     
      LEAVE.
   
   END. /** Fim do DO WHILE TRUE **/

   IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
       NEXT.

   /* Opções C-Consulta, B=Geracao, L=Lancamentos, X=Desfazer */
   CASE glb_cddopcao:

     WHEN "C" THEN 
       DO:
          /* Efetua a busca dos lancamentos registrados na tab.crapscr */
          RUN Busca_Lancamento ( INPUT "1" ). /* Validar se existe lanc. */
          
          IF  RETURN-VALUE <> "OK" THEN /* Houve critica/erro */
              NEXT.
        
          /* Listar os registros obtidos */
          OPEN QUERY q_consulta FOR EACH tt-crapscr NO-LOCK.
        
          HIDE MESSAGE NO-PAUSE.
        
          IF QUERY q_consulta:NUM-RESULTS = 0  THEN
             DO:
                QUERY q_consulta:QUERY-CLOSE().
                glb_dscritic = "Nenhum lancamento cadastrado na tabela SCR".
                BELL.
                MESSAGE glb_dscritic.
                NEXT.
             END.
        
          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
             UPDATE b_consulta WITH FRAME f_consulta.
             LEAVE.
        
          END.
        
          QUERY q_consulta:QUERY-CLOSE().
        
          HIDE FRAME f_consulta NO-PAUSE.

       END.
     WHEN "B" THEN 
       DO:
          HIDE MESSAGE NO-PAUSE.
         
          /* Verifica se o arquivo SCR foi gerado para a data informada */
          RUN Verifica_Lancamento ( INPUT "1" ).
         
          IF  RETURN-VALUE <> "OK" THEN /* Houve critica/erro */
              NEXT.
         
          /* Confirmação para gerar o arquivo */
          ASSIGN aux_confirma = "N".
         
          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
              ASSIGN glb_cdcritic = 78.
              RUN fontes/critic.p.
              BELL.
              MESSAGE glb_dscritic UPDATE aux_confirma.
              LEAVE.
         
          END.
         
          IF  KEY-FUNCTION(LASTKEY) = "END-ERROR" OR aux_confirma <> "S"  THEN
              DO:
                  ASSIGN glb_cdcritic = 79.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  NEXT.
              END.
         
          /* Efetua a busca dos lancamentos registrados na tab.crapscr */
          RUN Gera_Arquivo ( OUTPUT aux_dsdirscr ).
         
          IF  RETURN-VALUE <> "OK" THEN /* Houve critica/erro */
              NEXT.
         
          MESSAGE "Arquivo gerado em: " + aux_dsdirscr. 
         
       END.
     WHEN "L" THEN 
       DO:
          /* Verifica se o arquivo SCR foi gerado para a data informada */
          RUN Verifica_Lancamento ( INPUT "1" ).
          
          IF RETURN-VALUE <> "OK" THEN /* Houve critica/erro */
             NEXT.
          
          VIEW FRAME f_browse.
          
          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
              
             DISPLAY tel_btaltera 
                     tel_btexclui 
                     tel_btinclui 
                     WITH FRAME f_botoes.
                 
             CHOOSE FIELD tel_btaltera 
                          tel_btexclui 
                          tel_btinclui 
                          WITH FRAME f_botoes.
          
             HIDE MESSAGE NO-PAUSE.
             
             IF FRAME-VALUE = tel_btaltera  THEN
                DO:
                   /* Efetua a busca dos lancamentos da tab.crapscr */
                   RUN Busca_Lancamento ( INPUT "1" ).
          
                   IF  RETURN-VALUE <> "OK" THEN /* Houve critica/erro */
                       NEXT.
          
                   OPEN QUERY q_alterar FOR EACH tt-crapscr NO-LOCK.
          
                   IF QUERY q_alterar:NUM-RESULTS = 0  THEN
                      DO:
                         CLOSE QUERY q_alterar.
                         ASSIGN glb_dscritic = "Nenhum lancamento " + 
                                               "cadastrado na tabela SCR.".
                         BELL.
                         MESSAGE glb_dscritic.
                         NEXT.
                      END.
                   
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                   
                      UPDATE b_alterar WITH FRAME f_alterar.
                      LEAVE.
                                
                   END.
                   
                   CLOSE QUERY q_alterar.
          
                   HIDE FRAME f_alterar NO-PAUSE.

                END.
             ELSE
             IF FRAME-VALUE = tel_btinclui  THEN
                DO:
                   /* Carrega a tabela temporária de históricos */
                   RUN Busca_Historico.
          
                   IF RETURN-VALUE <> "OK" THEN /* Houve critica/erro */
                      NEXT.
          
                   OPEN QUERY q_historicos FOR EACH tt-historicos NO-LOCK
                                               BY tt-historicos.cdhistor.
                                 
                   IF QUERY q_historicos:NUM-RESULTS = 0  THEN
                      DO:
                         CLOSE QUERY q_historicos.
                         ASSIGN glb_dscritic = "Itens da tabela " + 
                                     "CONTAS3026 nao foram cadastrados.".
                         BELL.
                         MESSAGE glb_dscritic.
                         NEXT.
                      END.
          
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                   
                      UPDATE b_historicos WITH FRAME f_historicos.
                      LEAVE.
                                
                   END.
                   
                   CLOSE QUERY q_historicos.
          
                   HIDE FRAME f_historicos NO-PAUSE.

                END.
             ELSE
             IF FRAME-VALUE = tel_btexclui  THEN
                DO:
                   /* Efetua a busca dos lancamentos da tab.crapscr */
                   RUN Busca_Lancamento ( INPUT "1" ).
          
                   IF RETURN-VALUE <> "OK" THEN /* Houve critica/erro */
                      NEXT.
          
                   OPEN QUERY q_excluir FOR EACH tt-crapscr NO-LOCK. 
          
                   IF QUERY q_excluir:NUM-RESULTS = 0  THEN
                      DO:
                         CLOSE QUERY q_excluir.
                         ASSIGN glb_dscritic = "Nenhum lancamento cadastrado " +
                                        "na tabela SCR.".
                         BELL.
                         MESSAGE glb_dscritic.
                         NEXT.
                      END.
          
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                   
                      UPDATE b_excluir WITH FRAME f_excluir.
                      LEAVE.
                                
                   END.
                   
                   CLOSE QUERY q_excluir.
          
                   HIDE FRAME f_excluir NO-PAUSE.

                END.
          
          END. /** Fim do DO WHILE TRUE **/
          
          IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
             DO:
                HIDE MESSAGE NO-PAUSE.
          
                HIDE FRAME f_browse NO-PAUSE.
                HIDE FRAME f_botoes NO-PAUSE.
          
                NEXT.
             END.    
       END.
     WHEN "X" THEN 
       DO:
          /* Verifica existe lancamento SCR gerado para a data informada */
          RUN Verifica_Lancamento ( INPUT "0" ).
          
          IF RETURN-VALUE <> "OK" THEN /* Houve critica/erro */
             NEXT.
          
          MESSAGE "Peca a liberacao ao Coordenador/Gerente...".
          PAUSE 2 NO-MESSAGE.
          
          RUN fontes/pedesenha.p(INPUT glb_cdcooper,  
                                 INPUT 2, 
                                 OUTPUT aux_flgsenha,
                                 OUTPUT aux_cdoperad).
          
          IF KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
             NEXT.
         
          IF NOT aux_flgsenha  THEN
             NEXT.
              
          ASSIGN aux_confirma = "N".
          
          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
          
             ASSIGN glb_cdcritic = 78.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic UPDATE aux_confirma.
             LEAVE.
          
          END.
          
          IF KEY-FUNCTION(LASTKEY) = "END-ERROR" OR 
             aux_confirma <> "S"                 THEN
             DO:
                 ASSIGN glb_cdcritic = 79.
                 RUN fontes/critic.p.
                 BELL.
                 MESSAGE glb_dscritic.
                 NEXT.
             END.
          
          /* Atualizar controle de envio do arquivo */
          RUN Atualiza_Envio ( INPUT "0" ).
          
          IF RETURN-VALUE <> "OK" THEN /* Houve critica/erro */
             NEXT.

       END.

   END CASE.

END. /** Fim do DO WHILE TRUE **/


/*................................ PROCEDURES ...............................*/


/* ------------------------------------------------------------------------- */
/*                  EFETUA A BUSCA DA TABELA DE HISTORICO                    */
/* ------------------------------------------------------------------------- */
PROCEDURE Busca_Historico:

  DEFINE VARIABLE aux_dtsolici AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE aux_dtrefere AS CHARACTER   NO-UNDO.

  /* Converter p/string, o paramentro no Oracle eh varchar2 */
  ASSIGN aux_dtsolici = STRING(tel_dtsolici,"99/99/9999")
         aux_dtrefere = STRING(tel_dtrefere,"99/99/9999").

  EMPTY TEMP-TABLE tt-historicos.
  EMPTY TEMP-TABLE tt-erro.

  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

  MESSAGE "Buscando historicos, aguarde...".

  /* Efetuar a chamada da rotina Oracle */
  RUN STORED-PROCEDURE pc_busca_historico_scr_car
      aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper, /*Cooperativa*/
                                          INPUT 0,            /*Agencia    */
                                          INPUT 0,            /*Caixa      */
                                          INPUT glb_cdoperad, /*Operador   */
                                          INPUT glb_nmdatela, /*Nome tela  */
                                          INPUT 1,            /*IdOrigem   */
                                          INPUT "",           /*Cd.da Opcao*/
                                          INPUT "",           /*Operacao   */
                                          INPUT tel_nrdconta, /*Nr.da conta*/
                                          INPUT aux_dtsolici, /*Dt.Solicita*/
                                          INPUT aux_dtrefere, /*Dt.Referenc*/
                                          INPUT "",           /*Cd.Historic*/
                                         OUTPUT "", /*Nome campo */
                                         OUTPUT "",         /*Saida OK/NOK */
                                         OUTPUT ?,          /*Tab. retorno */
                                         OUTPUT 0,          /*Cod. critica */
                                         OUTPUT "").        /*Desc. critica*/

  /* Fechar o procedimento para buscarmos o resultado */
  CLOSE STORED-PROC pc_busca_historico_scr_car
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

  HIDE MESSAGE NO-PAUSE.

  /* Busca possíveis erros */
  ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_cdcritic = pc_busca_historico_scr_car.pr_cdcritic
                        WHEN pc_busca_historico_scr_car.pr_cdcritic <> ?
         aux_dscritic = pc_busca_historico_scr_car.pr_dscritic
                        WHEN pc_busca_historico_scr_car.pr_dscritic <> ?
         aux_nmdcampo = pc_busca_historico_scr_car.pr_nmdcampo
                        WHEN pc_busca_historico_scr_car.pr_nmdcampo <> ?.

  /* Preparar para NEXT-PROMPT do EDITING */
  IF  aux_nmdcampo <> "" THEN
      ASSIGN aux_nmdcampo = "tel_" + aux_nmdcampo.

  IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
      DO:
         RUN gera_erro (INPUT glb_cdcooper,
                        INPUT 0,
                        INPUT 0,
                        INPUT 1,          /** Sequencia **/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).
      
         MESSAGE aux_dscritic.
         PAUSE 3 NO-MESSAGE.
         RETURN "NOK".
      END.

  /* Buscar o XML na tabela de retorno da procedure Oracle */
  ASSIGN xml_req = pc_busca_historico_scr_car.pr_clob_ret.

  /* Ler o XML de retorno da proc e criar os registros na tt-historico
     para visualizacao dos registros na tela */
  SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1.
  PUT-STRING(ponteiro_xml,1) = xml_req.

  /* Se o ponteiro for nulo ou o XML estiver vazio, sai da procedure */
  IF ponteiro_xml = ? THEN
      RETURN "OK".

  /* Inicializando objetos para leitura do XML */
  CREATE X-DOCUMENT xDoc.    /* XML completo */
  CREATE X-NODEREF  xRoot.   /* Tag raiz em diante */
  CREATE X-NODEREF  xRoot2.  /* Tag aplicacao em diante */
  CREATE X-NODEREF  xField.  /* Campos dentro da tag INF */
  CREATE X-NODEREF  xText.   /* Texto que existe dentro da tag xField */

  /* Inicia o bloco para popular a temp-table com os dados do XML */
  xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE).
  xDoc:GET-DOCUMENT-ELEMENT(xRoot).

  DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN:
     xRoot:GET-CHILD(xRoot2,aux_cont_raiz).

     IF xRoot2:SUBTYPE <> "ELEMENT" THEN
        NEXT.

     IF xRoot2:NUM-CHILDREN > 0 THEN
        DO:
           CREATE tt-historicos.
        END.

     DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
        xRoot2:GET-CHILD(xField,aux_cont).

        IF xField:SUBTYPE <> "ELEMENT" THEN
           NEXT.

        xField:GET-CHILD(xText,1).

        ASSIGN tt-historicos.cdhistor = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdhistor"
               tt-historicos.dshistor = xText:NODE-VALUE WHEN xField:NAME = "dshistor"
               tt-historicos.dstphist = xText:NODE-VALUE WHEN xField:NAME = "dstphist".

        /* Atualizar o campo Descrição do Tipo de Histórico */
        IF xField:NAME = "dstphist" AND
           NOT CAN-DO("ATIVO,PASSIVO,RESULTADO",tt-historicos.dstphist) THEN
           DO:
              CASE SUBSTR(xText:NODE-VALUE,1,1):
                  WHEN "A" THEN ASSIGN tt-historicos.dstphist = "ATIVO".
                  WHEN "P" THEN ASSIGN tt-historicos.dstphist = "PASSIVO".
                  OTHERWISE ASSIGN tt-historicos.dstphist = "RESULTADO".
              END CASE.
           END. /* IF xField:NAME */
     END. /* DO aux_cont */
  END. /* DO aux_cont_raiz */

  SET-SIZE(ponteiro_xml) = 0.

  DELETE OBJECT xDoc.
  DELETE OBJECT xRoot.
  DELETE OBJECT xRoot2.
  DELETE OBJECT xField.
  DELETE OBJECT xText.

  HIDE MESSAGE NO-PAUSE.

  RETURN "OK".

END PROCEDURE. /* Busca_Historico */

/* ------------------------------------------------------------------------- */
/*                     VERIFICACOES INCIAIS DA TELA PRINCIPAL                */
/* ------------------------------------------------------------------------- */
PROCEDURE Verifica_Dados:

  DEFINE VARIABLE aux_dtsolici AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE aux_dtrefere AS CHARACTER   NO-UNDO.

  EMPTY TEMP-TABLE tt-erro.

  /* Converter p/string, o paramentro no Oracle eh varchar2 */
  ASSIGN aux_dtsolici = STRING(tel_dtsolici,"99/99/9999")
         aux_dtrefere = STRING(tel_dtrefere,"99/99/9999").

  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

  /* Efetuar a chamada da rotina Oracle */ 
  RUN STORED-PROCEDURE pc_verifica_dados_scr_car
      aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper, /*Cooperativa*/
                                          INPUT 0,            /*Agencia    */
                                          INPUT 0,            /*Caixa      */
                                          INPUT glb_cdoperad, /*Operador   */
                                          INPUT glb_nmdatela, /*Nome tela  */
                                          INPUT 1,            /*IdOrigem   */
                                          INPUT aux_dtsolici, /*Dt.Solicita*/
                                          INPUT aux_dtrefere, /*Dt.Referenc*/
                                          INPUT tel_nrdconta, /*Num. conta */
                                          INPUT glb_cddopcao, /*Cod. Opção */
                                          OUTPUT "", /*Nome campo */
                                          OUTPUT "",         /*Saida OK/NOK */
                                          OUTPUT ?,          /*Tab. retorno */
                                          OUTPUT 0,          /*Cod. critica */
                                          OUTPUT "").        /*Desc. critica*/

  /* Fechar o procedimento para buscarmos o resultado */ 
  CLOSE STORED-PROC pc_verifica_dados_scr_car
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

  HIDE MESSAGE NO-PAUSE.

  /* Busca possíveis erros */ 
  ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_cdcritic = pc_verifica_dados_scr_car.pr_cdcritic 
                        WHEN pc_verifica_dados_scr_car.pr_cdcritic <> ?
         aux_dscritic = pc_verifica_dados_scr_car.pr_dscritic 
                        WHEN pc_verifica_dados_scr_car.pr_dscritic <> ?
         aux_nmdcampo = pc_verifica_dados_scr_car.pr_nmdcampo
                        WHEN pc_verifica_dados_scr_car.pr_nmdcampo <> ?.

  /* Preparar para NEXT-PROMPT do EDITING */
  IF  aux_nmdcampo <> "" THEN
      ASSIGN aux_nmdcampo = "tel_" + aux_nmdcampo.

  /* Apresenta a crítica */
  IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
      DO: 
         RUN gera_erro (INPUT glb_cdcooper,
                        INPUT 0,
                        INPUT 0,
                        INPUT 1,          /** Sequencia **/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).
     
         MESSAGE aux_dscritic.
         PAUSE 3 NO-MESSAGE.
         RETURN "NOK".
      END.

  RETURN "OK".

END PROCEDURE. /* Verifica_Dados */

/* ------------------------------------------------------------------------- */
/*              EFETUA A BUSCA/CONSULTA DOS LANCAMENTO CRAPSCR               */
/* ------------------------------------------------------------------------- */
PROCEDURE Busca_Lancamento:

  DEFINE INPUT  PARAMETER par_flgvalid AS CHARACTER   NO-UNDO.

  DEFINE VARIABLE aux_dtsolici AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE aux_dtrefere AS CHARACTER   NO-UNDO.

  EMPTY TEMP-TABLE tt-erro.
  EMPTY TEMP-TABLE tt-crapscr.

  /* Converter p/string, o paramentro no Oracle eh varchar2 */
  ASSIGN aux_dtsolici = STRING(tel_dtsolici)
         aux_dtrefere = STRING(tel_dtrefere).

  MESSAGE "Aguarde... Buscando lancamento.".

  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

  /* Efetuar a chamada da rotina Oracle */ 
  RUN STORED-PROCEDURE pc_busca_lancamento_scr_car
      aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper, /*Cooperativa*/
                                          INPUT 0,            /*Agencia    */
                                          INPUT 0,            /*Caixa      */
                                          INPUT glb_cdoperad, /*Operador   */
                                          INPUT glb_nmdatela, /*Nome tela  */
                                          INPUT 1,            /*IdOrigem   */
                                          INPUT aux_dtsolici, /*Dt.Solicita*/
                                          INPUT aux_dtrefere, /*Dt.Referenc*/
                                          INPUT tel_nrdconta, /*Num. conta */
                                          INPUT "",           /*Cd.Historic*/
                                          INPUT glb_cddopcao, /*Cod. Opção */
                                          INPUT par_flgvalid, /*Valida lanc*/
                                         OUTPUT "",         /*Saida OK/NOK */
                                         OUTPUT ?,          /*Tab. retorno */
                                         OUTPUT 0,          /*Cod. critica */
                                         OUTPUT "").        /*Desc. critica*/

  /* Fechar o procedimento para buscarmos o resultado */ 
  CLOSE STORED-PROC pc_busca_lancamento_scr_car
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

  HIDE MESSAGE NO-PAUSE.

  /* Busca possíveis erros */ 
  ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_cdcritic = pc_busca_lancamento_scr_car.pr_cdcritic 
                        WHEN pc_busca_lancamento_scr_car.pr_cdcritic <> ?
         aux_dscritic = pc_busca_lancamento_scr_car.pr_dscritic 
                        WHEN pc_busca_lancamento_scr_car.pr_dscritic <> ?.

  /* Apresenta a critica */
  IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
      DO: 
         RUN gera_erro (INPUT glb_cdcooper,
                        INPUT 0,
                        INPUT 0,
                        INPUT 1,          /** Sequencia **/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).

         MESSAGE aux_dscritic.            
         PAUSE 3 NO-MESSAGE.
         RETURN "NOK".
      END.

  /* Buscar o XML na tabela de retorno da procedure Oracle */ 
  ASSIGN xml_req = pc_busca_lancamento_scr_car.pr_clob_ret.

  /* Ler o XML de retorno da proc e criar os registros na tt-historico
     para visualizacao dos registros na tela */
  SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
  PUT-STRING(ponteiro_xml,1) = xml_req. 

  /* Se o ponteiro for nulo ou o XML estiver vazio, sai da procedure */
  IF  ponteiro_xml = ? THEN
      RETURN "OK".

  /* Inicializando objetos para leitura do XML */ 
  CREATE X-DOCUMENT xDoc.    /* XML completo */ 
  CREATE X-NODEREF  xRoot.   /* Tag raiz em diante */ 
  CREATE X-NODEREF  xRoot2.  /* Tag aplicacao em diante */ 
  CREATE X-NODEREF  xField.  /* Campos dentro da tag INF */ 
  CREATE X-NODEREF  xText.   /* Texto que existe dentro da tag xField */

  /* Inicia o bloco para popular a temp-table com os dados do XML */
  xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
  xDoc:GET-DOCUMENT-ELEMENT(xRoot).

  DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
     xRoot:GET-CHILD(xRoot2,aux_cont_raiz).

     IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
        NEXT. 

     IF xRoot2:NUM-CHILDREN > 0 THEN
        DO:
           CREATE tt-crapscr.
        END.

     DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
        xRoot2:GET-CHILD(xField,aux_cont).

        IF xField:SUBTYPE <> "ELEMENT" THEN 
           NEXT. 

        xField:GET-CHILD(xText,1).

        ASSIGN tt-crapscr.cdcooper = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdcooper"
               tt-crapscr.nrdconta = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrdconta"
               tt-crapscr.cdhistor = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdhistor"
               tt-crapscr.dshistor = xText:NODE-VALUE WHEN xField:NAME = "dshistor"
               tt-crapscr.vllanmto = DEC(xText:NODE-VALUE) WHEN xField:NAME = "vllanmto"
               tt-crapscr.cdoperad = xText:NODE-VALUE WHEN xField:NAME = "cdoperad"
               tt-crapscr.dstphist = xText:NODE-VALUE WHEN xField:NAME = "dstphist"
               tt-crapscr.dtsolici = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtsolici" 
               tt-crapscr.dtrefere = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtrefere"
               tt-crapscr.dttransm = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dttransm"
               tt-crapscr.dtmvtolt = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtolt" NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN 
            DO:
               ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1) + "Erro ao " +
                                     "converter o campo " + xField:NAME       + 
                                     " - " + xText:NODE-VALUE.
            END.
        
        /* Campo logico */
        IF  xField:NAME = "flgenvio" THEN
            DO:
               /* Tratamento para valor diferente de YES/NO */
               CASE xText:NODE-VALUE:
                   WHEN "0" THEN ASSIGN tt-crapscr.flgenvio = NO.
                   WHEN "1" THEN ASSIGN tt-crapscr.flgenvio = YES.
                   OTHERWISE ASSIGN tt-crapscr.flgenvio = NO.
               END CASE.

              /* Atribuir direto ao campo para valor YES/NO */
               ASSIGN tt-crapscr.flgenvio = LOGICAL(xText:NODE-VALUE) NO-ERROR.
               IF  ERROR-STATUS:ERROR THEN 
                   DO:
                      ASSIGN tt-crapscr.flgenvio = NO.
                   END.
            END.
     END. /* DO aux_cont */
  END. /* DO aux_cont_raiz */

  SET-SIZE(ponteiro_xml) = 0. 

  DELETE OBJECT xDoc. 
  DELETE OBJECT xRoot. 
  DELETE OBJECT xRoot2. 
  DELETE OBJECT xField. 
  DELETE OBJECT xText.

  HIDE MESSAGE NO-PAUSE.

  RETURN "OK".

END PROCEDURE. /* Consulta_Lancamento */  

/* ------------------------------------------------------------------------- */
/*              VERIFICA SE O EXISTE LANCAMENTO E SE EXISTE ENVIO            */
/* ------------------------------------------------------------------------- */
PROCEDURE Verifica_Lancamento:

  DEFINE INPUT  PARAMETER par_flgvalid AS CHARACTER   NO-UNDO.

  DEFINE VARIABLE aux_dtsolici AS CHARACTER   NO-UNDO.

  EMPTY TEMP-TABLE tt-erro.

  ASSIGN aux_dtsolici = STRING(tel_dtsolici,"99/99/9999").

  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

  /* Efetuar a chamada da rotina Oracle */ 
  RUN STORED-PROCEDURE pc_verifica_lancamento_scr_car
      aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper, /*Cooperativa*/
                                          INPUT 0,            /*Agencia    */
                                          INPUT 0,            /*Caixa      */
                                          INPUT glb_cdoperad, /*Operador   */
                                          INPUT glb_nmdatela, /*Nome tela  */
                                          INPUT 1,            /*IdOrigem   */
                                          INPUT aux_dtsolici, /*Dt.Solicita*/
                                          INPUT glb_cddopcao, /*Cod. Opção */
                                          INPUT par_flgvalid, /*Validar Env*/
                                         OUTPUT "", /*Nome campo */
                                         OUTPUT "",         /*Saida OK/NOK */
                                         OUTPUT ?,          /*Tab. retorno */
                                         OUTPUT 0,          /*Cod. critica */
                                         OUTPUT "").        /*Desc. critica*/

  /* Fechar o procedimento para buscarmos o resultado */ 
  CLOSE STORED-PROC pc_verifica_lancamento_scr_car
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

  HIDE MESSAGE NO-PAUSE.

  /* Busca possíveis erros */ 
  ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_cdcritic = pc_verifica_lancamento_scr_car.pr_cdcritic 
                        WHEN pc_verifica_lancamento_scr_car.pr_cdcritic <> ?
         aux_dscritic = pc_verifica_lancamento_scr_car.pr_dscritic 
                        WHEN pc_verifica_lancamento_scr_car.pr_dscritic <> ?
         aux_nmdcampo = pc_verifica_lancamento_scr_car.pr_nmdcampo
                        WHEN pc_verifica_lancamento_scr_car.pr_nmdcampo <> ?.

  /* Preparar para NEXT-PROMPT do EDITING */
  IF  aux_nmdcampo <> "" THEN
      ASSIGN aux_nmdcampo = "tel_" + aux_nmdcampo.
  
  /* Apresenta a crítica */
  IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
      DO: 
         RUN gera_erro (INPUT glb_cdcooper,
                        INPUT 0,
                        INPUT 0,
                        INPUT 1,          /** Sequencia **/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).
     
         MESSAGE aux_dscritic.            
         PAUSE 3 NO-MESSAGE.
         RETURN "NOK".
      END.

  RETURN "OK".

END PROCEDURE. /* Verifica_Arquivo */

/* ------------------------------------------------------------------------- */
/*                     ROTINA PARA GERAR O ARQUIVO SCR                       */
/* ------------------------------------------------------------------------- */
PROCEDURE Gera_Arquivo:

  DEFINE OUTPUT PARAMETER par_dsdirscr AS CHARACTER   NO-UNDO.

  DEFINE VARIABLE aux_dtsolici AS CHARACTER   NO-UNDO.

  EMPTY TEMP-TABLE tt-erro.

  ASSIGN aux_dtsolici = STRING(tel_dtsolici,"99/99/9999").

  MESSAGE "Aguarde, gerando arquivo SCR ...".

  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

  /* Efetuar a chamada da rotina Oracle */ 
  RUN STORED-PROCEDURE pc_gera_arquivo_scr_car
      aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper, /*Cooperativa*/
                                          INPUT 0,            /*Agencia    */
                                          INPUT 0,            /*Caixa      */
                                          INPUT glb_cdoperad, /*Operador   */
                                          INPUT glb_nmdatela, /*Nome tela  */
                                          INPUT 1,            /*IdOrigem   */
                                          INPUT aux_dtsolici, /*Dt.Solicita*/
                                          INPUT "",           /*Dt.Referenc*/
                                          INPUT tel_nrdconta, /*Num. conta */
                                          INPUT "",           /*Cd.Historic*/
                                          INPUT glb_cddopcao, /*Cod. Opção */
                                         OUTPUT par_dsdirscr, /*Arquivo SCR*/
                                         OUTPUT "",         /*Saida OK/NOK */
                                         OUTPUT ?,          /*Tab. retorno */
                                         OUTPUT 0,          /*Cod. critica */
                                         OUTPUT "").        /*Desc. critica*/

  /* Fechar o procedimento para buscarmos o resultado */ 
  CLOSE STORED-PROC pc_gera_arquivo_scr_car
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

  HIDE MESSAGE NO-PAUSE.

  /* Busca possíveis erros */ 
  ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_cdcritic = pc_gera_arquivo_scr_car.pr_cdcritic 
                        WHEN pc_gera_arquivo_scr_car.pr_cdcritic <> ?
         aux_dscritic = pc_gera_arquivo_scr_car.pr_dscritic 
                        WHEN pc_gera_arquivo_scr_car.pr_dscritic <> ?
         par_dsdirscr = pc_gera_arquivo_scr_car.pr_dsdirscr 
                        WHEN pc_gera_arquivo_scr_car.pr_dsdirscr <> ?.

  /* Apresenta a crítica */
  IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
      DO: 
         RUN gera_erro (INPUT glb_cdcooper,
                        INPUT 0,
                        INPUT 0,
                        INPUT 1,          /** Sequencia **/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).
     
         MESSAGE aux_dscritic.
         PAUSE 3 NO-MESSAGE.
         RETURN "NOK".
      END.

  RETURN "OK".

END PROCEDURE. /* Gera_Arquivo */

/* ------------------------------------------------------------------------- */
/*                   ROTINA PARA GRAVAR O LANCAMENTO SCR                     */
/* ------------------------------------------------------------------------- */
PROCEDURE Grava_Lancamento:

  DEFINE INPUT  PARAMETER par_vllanmto AS DECIMAL     NO-UNDO.
  DEFINE INPUT  PARAMETER par_cdhistor AS CHARACTER   NO-UNDO.
  DEFINE INPUT  PARAMETER par_operacao AS CHARACTER   NO-UNDO.

  DEFINE VARIABLE aux_dtsolici AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE aux_dtrefere AS CHARACTER   NO-UNDO.

  EMPTY TEMP-TABLE tt-erro.

  /* Converter p/string, o paramentro no Oracle eh varchar2 */
  ASSIGN aux_dtsolici = STRING(tel_dtsolici,"99/99/9999")
         aux_dtrefere = STRING(tel_dtrefere,"99/99/9999").

  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

  /* Efetuar a chamada da rotina Oracle */ 
  RUN STORED-PROCEDURE pc_grava_lancamento_scr_car
      aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper, /*Cooperativa*/
                                          INPUT 0,            /*Agencia    */
                                          INPUT 0,            /*Caixa      */
                                          INPUT glb_cdoperad, /*Operador   */
                                          INPUT glb_nmdatela, /*Nome tela  */
                                          INPUT 1,            /*IdOrigem   */
                                          INPUT tel_nrdconta, /*Nr.da conta*/
                                          INPUT aux_dtsolici, /*Dt.Solicita*/
                                          INPUT aux_dtrefere, /*Dt.Referenc*/
                                          INPUT par_cdhistor, /*Cd.Historic*/
                                          INPUT par_vllanmto, /*Vl.Lancamen*/
                                          INPUT glb_cddopcao, /*Cd.da Opcao*/
                                          INPUT par_operacao, /*Operacao   */
                                         OUTPUT "",         /*Saida OK/NOK */
                                         OUTPUT ?,          /*Tab. retorno */
                                         OUTPUT 0,          /*Cod. critica */
                                         OUTPUT "").        /*Desc. critica*/

  /* Fechar o procedimento para buscarmos o resultado */ 
  CLOSE STORED-PROC pc_grava_lancamento_scr_car
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

  HIDE MESSAGE NO-PAUSE.

  /* Busca possíveis erros */ 
  ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_cdcritic = pc_grava_lancamento_scr_car.pr_cdcritic 
                        WHEN pc_grava_lancamento_scr_car.pr_cdcritic <> ?
         aux_dscritic = pc_grava_lancamento_scr_car.pr_dscritic 
                        WHEN pc_grava_lancamento_scr_car.pr_dscritic <> ?.

  /* Apresenta a crítica */
  IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
      DO: 
         RUN gera_erro (INPUT glb_cdcooper,
                        INPUT 0,
                        INPUT 0,
                        INPUT 1,          /** Sequencia **/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).
     
         MESSAGE aux_dscritic.            
         PAUSE 3 NO-MESSAGE.
         RETURN "NOK".
      END.

  RETURN "OK".

END PROCEDURE. /* Grava_Lancamento */

/* ------------------------------------------------------------------------- */
/*               ROTINA ATUALIZAR O CONTROLE DE ENVIO DO ARQUIVO             */
/* ------------------------------------------------------------------------- */
PROCEDURE Atualiza_Envio:

  DEFINE INPUT  PARAMETER par_flgenvio AS CHARACTER   NO-UNDO.

  DEFINE VARIABLE aux_dtsolici AS CHARACTER   NO-UNDO.

  EMPTY TEMP-TABLE tt-erro.

  ASSIGN aux_dtsolici = STRING(tel_dtsolici,"99/99/9999").

  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

  /* Efetuar a chamada da rotina Oracle */ 
  RUN STORED-PROCEDURE pc_atualiza_envio_scr_car
      aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper, /*Cooperativa*/
                                          INPUT 0,            /*Agencia    */
                                          INPUT 0,            /*Caixa      */
                                          INPUT glb_cdoperad, /*Operador   */
                                          INPUT glb_nmdatela, /*Nome tela  */
                                          INPUT 1,            /*IdOrigem   */
                                          INPUT tel_nrdconta, /*Nr.da conta*/
                                          INPUT aux_dtsolici, /*Dt.Solicita*/
                                          INPUT "",           /*Dt.Referenc*/
                                          INPUT "",           /*Cd.Historic*/
                                          INPUT glb_cddopcao, /*Cd.da Opcao*/
                                          INPUT par_flgenvio, /*Valid.Envio*/
                                         OUTPUT "",         /*Saida OK/NOK */
                                         OUTPUT ?,          /*Tab. retorno */
                                         OUTPUT 0,          /*Cod. critica */
                                         OUTPUT "").        /*Desc. critica*/

  /* Fechar o procedimento para buscarmos o resultado */ 
  CLOSE STORED-PROC pc_atualiza_envio_scr_car
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

  HIDE MESSAGE NO-PAUSE.

  /* Busca possíveis erros */ 
  ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_cdcritic = pc_atualiza_envio_scr_car.pr_cdcritic 
                        WHEN pc_atualiza_envio_scr_car.pr_cdcritic <> ?
         aux_dscritic = pc_atualiza_envio_scr_car.pr_dscritic 
                        WHEN pc_atualiza_envio_scr_car.pr_dscritic <> ?.

  /* Apresenta a crítica */
  IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
      DO: 
         RUN gera_erro (INPUT glb_cdcooper,
                        INPUT 0,
                        INPUT 0,
                        INPUT 1,          /** Sequencia **/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).
     
         MESSAGE aux_dscritic.            
         PAUSE 3 NO-MESSAGE.
         RETURN "NOK".
      END.

  RETURN "OK".

END PROCEDURE. /* Atualiza_Envio */


