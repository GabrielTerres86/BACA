/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------+-------------------------------------+
  | Rotina Progress                    | Rotina Oracle PLSQL                 |
  +------------------------------------+-------------------------------------+
  |   opcao_b                          | SSPB0001.pc_trfsal_opcao_b          |
  |   opcao_x                          | SSPB0001.pc_trfsal_opcao_x          |
  +------------------------------------+-------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 05/08/2015 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/* .............................................................................

   Programa: fontes/trfsal.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Dezembro/2006                      Ultima alteracao: 19/12/2018
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Gerar Arquivo TED para transmissao ao Banco Brasil referente as
               contas salario.                                         
   
   Alteracao : 23/08/2007 - Quando nao houver TED para o banco do brasil e
                            houver para outros bancos considerar aux_nrdolote
                            como sendo 1 (Elton).
                          - Incluido permissoes de acesso (Guilherme).

               10/12/2007 - Alterado Temp-Table da BO b1wgen0012.p para
                            enviar informacoes da tabela crapccs e craplcs
                            (Sidnei - Precise).
                            
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS.   
                          - Kbase IT Solutions - Eduardo Silva.               
                          
               26/01/2009 - Alteracao cdempres (Diego).
               
               23/10/2009 - Alterada a procedure opcao_b para enviar TEC´s por
                            mensageria - SPB (Fernando).               
                            
               08/12/2009 - Alteracao codigo historico (Diego).
                                     
               24/05/2010 - Incluido digito na conta de envio dos TEC - SPB
                            (Fernando).

               07/06/2010 - Alterado numero de controle do TEC - SPB. Passar a
                            usar ETIME. (Fernando).

               08/06/2010 - Nao deixar Reativar Registros quando estiver
                            operando com o SPB (Fernando).
                            
               26/06/2010 - Quando for digito X no envio do TEC - SPB, passar
                            0 (Fernando).               
                            
               11/10/2010 - Incluso parametro em branco para proc_envia_tec_ted
                            (Guilherme).             
                            
               10/03/2011 - Incluir critica de horario no envio de TED/DOC
                            (Gabriel).      
                            
               11/04/2011 - Alterado layout da opcao "T" para o valor aparecer
                            todo na tela (Adriano).
                            
               20/07/2011 - Controle de uso exclusivo para a opcao 'B'.
                            Corrigir duplicacao de envio de TED/DOC.             
             
               16/09/2011 - Incluido log ao se realizar a opcao 'B'. (Henrique)
               
               30/09/2011 - Incluido trabamento do evento ENDKEY no final do 
                            bloco transaction da opcao 'B' (Henrique).
                            
               06/10/2011 - Na opcao B, quando for banco 85, creditar online
                            (Gabriel).   
                            
               27/03/2012 - Incluir no log erros da opção 'B'        
                            (David Kruger).
                            
               20/04/2012 - Inclusao do parametro "origem", na chamada da
                            procedure proc_envia_tec_ted. (Fabricio)
                            
               11/07/2012 - Efetuado tratamento na leitura da tabela crapcop da
                            opcao 'B', pois quando o horario de envio de TED
                            era alterado na TAB085 em uma outra sessao, o mesmo
                            nao atualizava na TRFSAL, era necessario sair do 
                            do menu e logar novamente (Diego).
                            
               04/12/2012 - Incluir origem da mensagem no numero de controle
                            (Diego).              
                            
               26/03/2013 - Ajustado o retorno na chamada proc envia tec ted
                            (Gabriel).             
               
               30/04/2013 - Incluir tratamento para hora limite e so altera 
                            quando for CENTRAL (Lucas R.)
                            
               30/07/2013 - Ajuste para permitir alterar individualmente o
                            horario por cooperativa (combo de cooperativas)
                            pela CECRED. As cooperativas podem apenas 
                            visualizar o horario.                   (Carlos)
               
               05/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
                            
               05/03/2014 - Inclusao de VALIDATE crablcs e craptab (Carlos)
               
               09/04/2014 - SD #146218 Ajustes nos UNDOs para desfazer toda a 
                            transaction "Transf" (Carlos)
                            
               02/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
               13/06/2014 - Adicionado parametros dtagendt, nrseqarq, cdconven
                             'a chamada da procedure proc_envia_tec_ted.
                             (PRJ Automatizacao TED pagto convenio repasse) -
                             (Fabricio)
               
               29/08/2014 - Incluso parametro em branco na proc_envia_tec_ted
                            referente a descrição do histórico(Vanessa).
                            
               24/10/2014 - Enviar a hora da transferencia (Jonata-RKAM).
               
               05/06/2015 - Inclusão do paramentro par_cdispbif = 0 na procedure
                             proc_envia_tec_ted (Vanessa - FDR041 SD271603)
                             
               15/06/2015 - Alterar o sistema para substituir a utilização
                            do parâmetro HRTRCTASAL dentro da CRAPTAB por
                            FOLHAIB_HOR_LIM_PORTAB.(Andre Santos - SUPERO)
              
              05/08/2015 - Conversao da opcao_b PROGRESS --> ORACLE e inclusao
                            dos tratamentos do projeto FOLHAIB (Vanessa). 
                            
              10/08/2015 - Inclusao opcao "E" e refeita a opcao "X" para o 
                           projeto FOLHAIB (Jean Michel). 
						   
              02/03/2016 - Ajuste no nrdocmto devido a problema com exibicao
                           de valores do Folha IB (Marcos-Supero). 						   
                            
              22/09/2016 - Alterar para exibir o glb_dscritic ao invés do glb_cdcritic
                           (Lucas Ranghetti #500917)
						   
			  25/10/2017 - Desabilitando a opcao "B", conforme solicitado no chamado
						   654712. (Kelvin)

			  19/12/2018 - Realizado limpeza da tabela após o estorno (Marco Amorim - Mout'S)   		   	
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/var_oracle.i }

DEF    STREAM str_1.

DEF    VAR aux_confirma     AS CHAR    FORMAT "!(1)"                  NO-UNDO.
DEF    VAR aux_nmendter     AS CHAR                                   NO-UNDO.
DEF    VAR aux_nmarqimp     AS CHAR                                   NO-UNDO.
DEF    VAR aux_nrdolote     AS INT                                    NO-UNDO.
DEF    VAR aux_flgopspb     AS LOG                                    NO-UNDO.
DEF    VAR h-b1wgen0012     AS HANDLE                                 NO-UNDO.
DEF    VAR h-b1wgen0046     AS HANDLE                                 NO-UNDO.
DEF    VAR aux_tipselec     AS CHAR                                   NO-UNDO.

DEF    VAR aux_contacop     AS INT     INIT 0                         NO-UNDO.
DEF    VAR tel_nmcooper     AS CHAR                                   NO-UNDO.
DEF    VAR tel_cdcooper     AS CHAR    FORMAT "x(12)" VIEW-AS COMBO-BOX   
                                                      INNER-LINES 11  NO-UNDO.
                                                      
/* Variaveis para impressao */
DEF    VAR aux_contador     AS INT     INIT 0                         NO-UNDO.
DEF    VAR aux_flgescra     AS LOGICAL                                NO-UNDO.
DEF    VAR aux_dscomand     AS CHAR                                   NO-UNDO.
DEF    VAR par_flgfirst     AS LOGI                                   NO-UNDO.
DEF    VAR par_flgrodar     AS LOGICAL                                NO-UNDO.
DEF    VAR par_flgcance     AS LOGI                                   NO-UNDO.
DEF    VAR tel_dsimprim     AS CHAR    FORMAT "x(08)" INIT "Imprimir" NO-UNDO.
DEF    VAR tel_dscancel     AS CHAR    FORMAT "x(08)" INIT "Cancelar" NO-UNDO.
DEF    VAR aux_cddopcao     AS CHAR                                   NO-UNDO.
DEF    VAR flg_doctobb      AS LOG INIT NO                            NO-UNDO.
DEF    VAR aux_ponteiro     AS INT                                    NO-UNDO.
  
DEF    VAR aux_cdcritic AS INTE                                  NO-UNDO.
DEF    VAR aux_dscritic AS CHAR                                  NO-UNDO.
  
DEF    VAR aux_cdhisdev     AS INT                                    NO-UNDO.
DEF    VAR aux_cdhisest     AS INT                                    NO-UNDO.
DEF    VAR aux_nrdcomto     AS INT                                    NO-UNDO.
DEF    VAR aux_hrlimite     AS INT                                    NO-UNDO.
DEF    VAR aux_strhrlim     AS CHAR                                   NO-UNDO. 
DEF    VAR aux_contregi     AS INT                                    NO-UNDO.

DEF    VAR h-b1wgen0118     AS HANDLE                                 NO-UNDO.
DEF    VAR h-b1wgen9999     AS HANDLE                                 NO-UNDO.

DEF    BUFFER crablcs FOR craplcs.

DEF    TEMP-TABLE crawlcs                                             NO-UNDO
       FIELD cdcooper LIKE craplcs.cdcooper 
       FIELD nrdconta LIKE craplcs.nrdconta
       FIELD cdempres LIKE crapccs.cdempres
       FIELD dtmvtolt LIKE craplcs.dtmvtolt
       FIELD dttransf LIKE craplcs.dttransf
       FIELD vllanmto LIKE craplcs.vllanmto
       FIELD cdbantrf LIKE crapccs.cdbantrf
       FIELD cdagetrf LIKE crapccs.cdagetrf
       FIELD nrctatrf LIKE crapccs.nrctatrf
       FIELD flgenvio LIKE craplcs.flgenvio
       FIELD cdagenci LIKE crapccs.cdagenci
       FIELD nmfuncio LIKE crapccs.nmfuncio
       FIELD nrdocmto LIKE craplcs.nrdocmto
       FIELD nmarqenv LIKE craplcs.nmarqenv
       FIELD hrtransf LIKE craplcs.hrtransf
       FIELD idseleca AS CHAR
       FIELD idopetrf LIKE craplcs.idopetrf
       FIELD nrridlfp LIKE craplcs.nrridlfp
       FIELD cdhistor LIKE craplcs.cdhistor
       INDEX crawlcs1 cdcooper dtmvtolt nrdconta.
    
DEF TEMP-TABLE cratemp                                                NO-UNDO
       FIELD cdempres LIKE crapemp.cdempres
       FIELD nrdconta LIKE crapemp.nrdconta
       FIELD vllanmto LIKE craplcm.vllanmto
       INDEX cratemp1 cdempres. 

DEF TEMP-TABLE crawarq                                             NO-UNDO
       FIELD nmarqenv AS CHAR.

DEF TEMP-TABLE craxlcs LIKE crawlcs.

DEF TEMP-TABLE crattem                                                NO-UNDO
       FIELD cdseqarq AS INTEGER
       FIELD nrdolote AS INTEGER
       FIELD cddbanco AS INTEGER
       FIELD nmarquiv AS CHAR
       FIELD nrrectit AS RECID
       FIELD nrdconta LIKE crapccs.nrdconta
       FIELD cdagenci LIKE crapccs.cdagenci
       FIELD cdbantrf LIKE crapccs.cdbantrf
       FIELD cdagetrf LIKE crapccs.cdagetrf
       FIELD nrctatrf LIKE crapccs.nrctatrf
       FIELD nrdigtrf LIKE crapccs.nrdigtrf
       FIELD nmfuncio LIKE crapccs.nmfuncio
       FIELD nrcpfcgc LIKE crapccs.nrcpfcgc
       FIELD nrdocmto LIKE craplcs.nrdocmto
       FIELD vllanmto LIKE craplcs.vllanmto
       FIELD dtmvtolt LIKE craplcs.dtmvtolt
       FIELD tppessoa AS INT FORMAT "9"
       INDEX crattem1 cdseqarq nrdolote.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao  AT  3  LABEL "Opcao"
                          VALIDATE(CAN-DO("B,C,E,R,T,X",glb_cddopcao),
                                   "014 - Opcao errada.")
                          HELP "Informe a opcao desejada (B, C, E, R, T ou X)"
     WITH SIDE-LABELS OVERLAY NO-BOX ROW 6 COLUMN 2 FRAME f_trfsal.

FORM "(B) - Gerar arquivos"        SKIP
     "(E) - Estorno de Rejeicoes"  SKIP
     "(C) - Consultar"             SKIP
     "(R) - Relatorio"             SKIP
     "(T) - Extrato"               SKIP
     "(X) - Reenvio de Rejeicoes"  SKIP
     WITH SIZE 40 BY 8 CENTERED OVERLAY ROW 9
          TITLE "Escolha uma das opcoes abaixo:" FRAME f_helpopcao.

DEF QUERY q_craxlcs_e FOR craxlcs.
  
DEF BROWSE b_craxlcs_e QUERY q_craxlcs_e
    DISPLAY craxlcs.idseleca COLUMN-LABEL ""         FORMAT "x(01)"
          craxlcs.nrdconta COLUMN-LABEL "Conta/dv"
          craxlcs.cdagenci COLUMN-LABEL "PA"       FORMAT "zz9"
          craxlcs.dtmvtolt COLUMN-LABEL "Dt.Credi" FORMAT "99/99/99"
          craxlcs.dttransf COLUMN-LABEL "Dt.Trans" FORMAT "99/99/99"
          craxlcs.vllanmto COLUMN-LABEL "Valor"    FORMAT "zzzz9.99"
          craxlcs.cdbantrf COLUMN-LABEL "Bco"      FORMAT "zzz9"
          craxlcs.cdagetrf COLUMN-LABEL "Age"      FORMAT "zzz9"
          craxlcs.nrctatrf COLUMN-LABEL "Conta TRF"
          WITH 12 DOWN.
          
DEF QUERY q_craxlcs_x FOR craxlcs.
  
DEF BROWSE b_craxlcs_x QUERY q_craxlcs_x
    DISPLAY craxlcs.idseleca COLUMN-LABEL ""         FORMAT "x(01)"
          craxlcs.nrdconta COLUMN-LABEL "Conta/dv"
          craxlcs.cdagenci COLUMN-LABEL "PA"       FORMAT "zz9"
          craxlcs.dtmvtolt COLUMN-LABEL "Dt.Credi" FORMAT "99/99/99"
          craxlcs.dttransf COLUMN-LABEL "Dt.Trans" FORMAT "99/99/99"
          craxlcs.vllanmto COLUMN-LABEL "Valor"    FORMAT "zzzz9.99"
          craxlcs.cdbantrf COLUMN-LABEL "Bco"      FORMAT "zzz9"
          craxlcs.cdagetrf COLUMN-LABEL "Age"      FORMAT "zzz9"
          craxlcs.nrctatrf COLUMN-LABEL "Conta TRF"
          WITH 12 DOWN.          
  
FORM b_craxlcs_e HELP "ENTER - Selecionar / F5 - Processar / F6 - Processar Todos"
    WITH ROW 5 COLUMN 4 OVERLAY NO-BOX FRAME f_browser_e.

FORM b_craxlcs_x HELP "F5 - Executar / F4 - Sair"
    WITH ROW 5 COLUMN 4 OVERLAY NO-BOX FRAME f_browser_x.

VIEW FRAME f_moldura.
PAUSE 0.
glb_cddopcao = "C".

ON ANY-KEY OF b_craxlcs_x IN FRAME f_browser_x DO:
          
  HIDE MESSAGE NO-PAUSE.

  IF KEY-FUNCTION(LASTKEY) = "CURSOR-DOWN" THEN
      DO:
        RETURN.
      END.
  ELSE IF KEY-FUNCTION(LASTKEY) = "CURSOR-UP" THEN
    DO:
      RETURN.
    END.
  ELSE
    DO:
        
      IF KEY-FUNCTION(LASTKEY) = "END-ERROR" THEN
        DO:  
          EMPTY TEMP-TABLE craxlcs.
        
          CLEAR FRAME f_browser_x.
          CLEAR FRAME q_craxlcs_x.
          
          HIDE FRAME f_browser_x.
          HIDE FRAME q_craxlcs_x.
          HIDE BROWSE b_craxlcs_x.
          
          RETURN.                              
        END.
      ELSE IF KEY-FUNCTION(LASTKEY) = "GET" THEN
        DO:
          IF TEMP-TABLE craxlcs:HAS-RECORDS THEN
            DO:
              EMPTY TEMP-TABLE tt-erro.
              RUN fontes/confirma.p (INPUT "Confirma processamento de todos registros pendentes?",
                                    OUTPUT aux_confirma).
                     
              IF aux_confirma <> "S" THEN
                RETURN NO-APPLY.
              ELSE
                DO:                      
                  RUN efetua_processo_x.
                  
                  IF RETURN-VALUE = "NOK" THEN
                    DO:                      
                      FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                      IF AVAILABLE tt-erro THEN
                        DO:
                          MESSAGE "Erro: " + STRING(tt-erro.dscritic).
                        END.   
                      ELSE
                        DO:
                          MESSAGE "Erro no processamento.".
                        END.   
                      PAUSE 2 NO-MESSAGE.
                      APPLY "GO".
                    END.
                  ELSE
                    DO:
                      IF RETURN-VALUE <> "HOR" THEN
                        DO:
                          EMPTY TEMP-TABLE craxlcs.
                      
                          BELL.
                          MESSAGE "Processo efetuado com sucesso.".
                          PAUSE 2 NO-MESSAGE. 
                          APPLY "GO".                   

                        END.
                    END.
                END.              
              END.
            ELSE
              DO:
                EMPTY TEMP-TABLE craxlcs.
                
                BELL.
                MESSAGE "Nao ha registros a serem processados.".
                PAUSE 2 NO-MESSAGE. 
                APPLY "GO".
              END.
        END.
    END.
  RETURN.
END.

/* "ENTER" */
ON ANY-KEY OF b_craxlcs_e IN FRAME f_browser_e DO:
    
  HIDE MESSAGE NO-PAUSE.
  
  ASSIGN aux_tipselec = "".
  
  IF KEY-FUNCTION(LASTKEY) = "CURSOR-DOWN" THEN
    DO:
      RETURN.
    END.
  ELSE IF KEY-FUNCTION(LASTKEY) = "CURSOR-UP" THEN
    DO:
      RETURN.
    END.
  ELSE
    DO:   
      
      IF KEY-FUNCTION(LASTKEY) = "END-ERROR" THEN
          DO:
                        
            CLEAR FRAME f_browser_e.
            CLEAR FRAME q_craxlcs_e.
            
            HIDE FRAME f_browser_e.
            HIDE FRAME q_craxlcs_e.
            HIDE BROWSE b_craxlcs_e.
            
            RETURN.
          END.
      ELSE IF KEY-FUNCTION(LASTKEY) = "GET" THEN
        DO:
          IF TEMP-TABLE craxlcs:HAS-RECORDS THEN
            DO:
                
              ASSIGN aux_tipselec = "F5".
              
              IF aux_contador <= 0 THEN
                DO: 
                  MESSAGE "Favor selecionar pelo menos um registro!".
                END.
              ELSE
                DO:
                  RUN fontes/confirma.p (INPUT "Confirma processamento dos registros selecionados?",
                                        OUTPUT aux_confirma).
                         
                  IF aux_confirma <> "S" THEN
                    DO:
                      RETURN.
                    END.
                  ELSE
                    DO:
                      RUN efetua_processo_e.
                      
                      IF RETURN-VALUE <> "OK" THEN
                        DO:
                          RETURN.
                        END.
                      ELSE
                        DO:
                          BELL.
                          MESSAGE "Processo efetuado com sucesso.".
                          PAUSE 2 NO-MESSAGE.                      
                         
                          APPLY "GO".
                        END.
                    END.
                END.
            END.
          ELSE
            DO:
              EMPTY TEMP-TABLE craxlcs.
              
              BELL.
              MESSAGE "Nao ha registros a serem processados.".
              PAUSE 2 NO-MESSAGE. 
              APPLY "GO".
            END.
        END.
      ELSE IF KEY-FUNCTION(LASTKEY) = "PUT" THEN
        DO:
          IF TEMP-TABLE craxlcs:HAS-RECORDS THEN
            DO:
              ASSIGN aux_tipselec = "F6".
              
              RUN fontes/confirma.p (INPUT "Confirma processamento de todos registros pendentes?",
                                    OUTPUT aux_confirma).
                     
              IF aux_confirma <> "S" THEN
                DO:
                  RETURN NO-APPLY.
                END.
              ELSE
                DO:
                  RUN efetua_processo_e.

                  IF RETURN-VALUE <> "OK" THEN
                    DO:
                      RETURN.
                    END.
                  ELSE
                    DO:
                        BELL.
                        MESSAGE "Processo efetuado com sucesso.".
                        PAUSE 3 NO-MESSAGE.                     

                        APPLY "GO".
                    END.                  
                END.
            END.
          ELSE
            DO:
              EMPTY TEMP-TABLE craxlcs.
              
              BELL.
              MESSAGE "Nao ha registros a serem processados.".
              PAUSE 2 NO-MESSAGE. 
              APPLY "GO".
            END.
        END.   
    END.
END. /* "ENTER" */


/* Pressionar ENTER para selecionar/descelecionar os registros da opcao E */
ON ENTER OF b_craxlcs_e IN FRAME f_browser_e DO:
          
    HIDE MESSAGE NO-PAUSE.
  
    /* Procura o registro corrente/selecionado no browse */
    FIND CURRENT craxlcs EXCLUSIVE-LOCK NO-ERROR.
    
    IF NOT AVAILABLE craxlcs THEN
      RETURN.
    
    /* Seleciona/Desmarca a linha conforme a interacao do usuario */
    IF craxlcs.idseleca:SCREEN-VALUE IN BROWSE b_craxlcs_e = "*" THEN
      DO:
          ASSIGN craxlcs.idseleca:SCREEN-VALUE IN BROWSE b_craxlcs_e = ""
                 craxlcs.idseleca = "" 
                 aux_contador = aux_contador - 1.                      
      END.
    ELSE 
      DO:
        /* atualiza o registro = selecionado! */
        ASSIGN craxlcs.idseleca:SCREEN-VALUE IN BROWSE b_craxlcs_e = "*"
               craxlcs.idseleca = "*"
               aux_contador = aux_contador + 1.
        /* Passa a proxima linha para facilitar a digitacao */
        APPLY "CURSOR-DOWN" TO b_craxlcs_e IN FRAME f_browser_e.
        
      END.   
  
  RETURN.

END. /* "ENTER" */

DO WHILE TRUE:
  
   RUN fontes/inicia.p.
                         
   VIEW FRAME f_helpopcao.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      UPDATE glb_cddopcao WITH FRAME f_trfsal.
      LEAVE.
   END.
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "TRFSAL"  THEN
                 DO:
                     HIDE FRAME f_moldura.
                     HIDE FRAME f_trfsal.
                     HIDE FRAME f_helpopcao.
                     RETURN.
                 END.
        END.

   /* Controle de operadores */
   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

  IF glb_cddopcao = "B"   THEN
    DO:

        MESSAGE "Opcao desabilitada.".
		/*IF RETURN-VALUE <> "OK"   THEN
          NEXT.
        
        RUN opcao_b.*/

    END.
   ELSE
   IF   glb_cddopcao = "C"   THEN
        RUN opcao_c.
   ELSE
   IF   glb_cddopcao = "R"   THEN
        RUN opcao_r.
   ELSE
   IF   glb_cddopcao = "T"   THEN
        RUN opcao_t.
   ELSE
   IF   glb_cddopcao = "X"   THEN
        RUN opcao_x.
   ELSE
   IF glb_cddopcao = "E"   THEN
    RUN opcao_e.

END. /* Fim DO WHILE TRUE */

/* Mostra os arquivos do dia informado e retorna o escolhido, nao foi usada uma
   funcao porque nao pode ter UPDATE dentro de uma funcao */
PROCEDURE zoom_arquivos:
    DEF INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.

    DEF QUERY q_arquivos FOR crawarq.
    DEF BROWSE b_arquivos QUERY q_arquivos
        DISPLAY crawarq.nmarqenv COLUMN-LABEL "Arquivos"  FORMAT "X(20)"
                WITH NO-BOX 5 DOWN.
                
    FORM b_arquivos
         WITH OVERLAY ROW 8 COLUMN 50 FRAME f_arquivos.
    
    ON RETURN OF b_arquivos IN FRAME f_arquivos DO:
       APPLY "GO".
    END.
    
    EMPTY TEMP-TABLE crawarq.
    
    /* Cria uma opcao para TODOS os arquivos */
    CREATE crawarq.
    ASSIGN crawarq.nmarqenv = "TODOS ARQUIVOS".
    
    FOR EACH craplcs WHERE craplcs.cdcooper = glb_cdcooper   AND
                           craplcs.dtmvtolt = par_dtmvtolt   AND
                           craplcs.nmarqenv <> ""            NO-LOCK
                           BREAK BY craplcs.nmarqenv:
                           
        IF   FIRST-OF(craplcs.nmarqenv)   THEN
             DO:
                 CREATE crawarq.
                 ASSIGN crawarq.nmarqenv = craplcs.nmarqenv.
             END.
    END.
    
    OPEN QUERY q_arquivos FOR EACH crawarq.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       UPDATE b_arquivos WITH FRAME f_arquivos.
       LEAVE.
    END.
    
    HIDE FRAME f_arquivos.
    PAUSE 0.
    
    RETURN crawarq.nmarqenv.

END PROCEDURE. /* Fim zoom_arquivos */

PROCEDURE opcao_c:

   DEF  VAR tel_dtmvtolt AS DATE                                       NO-UNDO.
   DEF  VAR tel_dssitlcs AS LOGICAL  FORMAT "Enviados/Nao enviados"    NO-UNDO.
   DEF  VAR tel_cdagenci LIKE crapass.cdagenci                         NO-UNDO.
   DEF  VAR tel_nrdconta LIKE crapass.nrdconta                         NO-UNDO.
   DEF  VAR tel_nmarqenv AS CHAR                                       NO-UNDO.
   
   DEF QUERY q_crawlcs FOR crawlcs.

   DEF BROWSE b_crawlcs QUERY q_crawlcs
       DISPLAY crawlcs.nrdconta COLUMN-LABEL "Conta/dv"
               crawlcs.cdagenci COLUMN-LABEL "PA"           FORMAT "zz9"
               crawlcs.dtmvtolt COLUMN-LABEL "Dt.Credi"     FORMAT "99/99/99"
               crawlcs.dttransf COLUMN-LABEL "Dt.Trans"     FORMAT "99/99/99"
               crawlcs.vllanmto COLUMN-LABEL "Valor"        FORMAT "zzzz9.99"
               crawlcs.cdbantrf COLUMN-LABEL "Bco"          FORMAT "zzz9"
               crawlcs.cdagetrf COLUMN-LABEL "Age"          FORMAT "zzz9"
               crawlcs.nrctatrf COLUMN-LABEL "Conta TRF"
               crawlcs.flgenvio COLUMN-LABEL "Sit" FORMAT "E/N"
               WITH 5 DOWN.
        
   
   FORM glb_cddopcao  AT  3  LABEL "Opcao"
        
        tel_dtmvtolt  AT 16  LABEL "Referencia"         FORMAT "99/99/9999"
                             HELP "Informe a data a ser consultada"
                             VALIDATE(tel_dtmvtolt <> ?,
                                      "013 - Data errada.")
                                      
        tel_cdagenci  AT 51  LABEL "PA"
                          HELP "Informe o PA a ser consultado - 0 para todos"
        SKIP
        tel_nrdconta  AT 18  LABEL "Conta/dv"
                             HELP "Informe a conta/dv ou 0 para todas"
                             VALIDATE(tel_nrdconta = 0 OR
                                      CAN-FIND(crapccs WHERE crapccs.cdcooper =
                                                             glb_cdcooper AND
                                                             crapccs.nrdconta =
                                                             tel_nrdconta
                                                             NO-LOCK),
                                      "127 - Conta errada.")
                             
        tel_dssitlcs  AT 45  LABEL "Situacao"
                             HELP "Situacao (E)nviados / (N)ao enviados"
        SKIP
        tel_nmarqenv  AT 19  LABEL "Arquivo"    FORMAT "x(20)"
                      HELP "Tecle F7 para listar os arquivos"
                      VALIDATE(INPUT tel_cdagenci <> 0 OR
                               INPUT tel_dssitlcs = NO OR
                              (INPUT tel_cdagenci = 0 AND tel_nmarqenv <> ""),
                               "O Arquivo deve ser escolhido.")
        SKIP(1)
        b_crawlcs        HELP "Use as setas para navegar / F4 ou END para sair"
        WITH ROW 6 COLUMN 2 NO-BOX SIDE-LABELS OVERLAY FRAME f_consulta.
        
   FORM crawlcs.cdempres  AT  4  LABEL "Empresa"  FORMAT "zzzz9"
        crawlcs.nmfuncio  AT 31  LABEL "Nome"
        SKIP
        crawlcs.nrdocmto  AT  2                   FORMAT "zzzzzzzzz9"
        crawlcs.nmarqenv  AT 28
        crawlcs.hrtransf  AT 57
        WITH ROW 19 COLUMN 2 NO-BOX SIDE-LABELS OVERLAY FRAME f_detalhes.
        

   /* Esconde a conta e o arquivo, se informar o PA */
   ON LEAVE OF tel_cdagenci IN FRAME f_consulta DO:
      
      IF   INPUT FRAME f_consulta tel_cdagenci <> 0   THEN
           DO:
               ASSIGN tel_nrdconta = 0
                      tel_nmarqenv = "".
               
               DISPLAY tel_nrdconta
                       tel_nmarqenv
                       WITH FRAME f_consulta.

               DISABLE tel_nrdconta
                       tel_nmarqenv
                       WITH FRAME f_consulta.
           END.
      ELSE
           DO:
               ENABLE tel_dtmvtolt
                      tel_cdagenci
                      tel_nrdconta
                      tel_dssitlcs
                      tel_nmarqenv
                      WITH FRAME f_consulta.
                      
               NEXT-PROMPT tel_nrdconta WITH FRAME f_consulta.
               RETURN NO-APPLY.
           END.
   END.
   
   /* Esconde o arquivo, se informar NAO ENVIADOS */
   ON LEAVE OF tel_dssitlcs IN FRAME f_consulta DO:
      
      IF   INPUT FRAME f_consulta tel_dssitlcs = NO   THEN
           DO:
               ASSIGN tel_nmarqenv = "".
               
               DISPLAY tel_nmarqenv
                       WITH FRAME f_consulta.

               DISABLE tel_nmarqenv
                       WITH FRAME f_consulta.
                       
               IF   KEY-FUNCTION(LASTKEY) = "RETURN"   THEN
                    APPLY "GO".                                     
           END.
      ELSE
           DO:
               ENABLE tel_dtmvtolt
                      tel_cdagenci
                      tel_nrdconta
                      tel_dssitlcs
                      tel_nmarqenv
                      WITH FRAME f_consulta.
                      
               NEXT-PROMPT tel_nmarqenv WITH FRAME f_consulta.
               RETURN NO-APPLY.
           END.
   END.
   
   /* Para atualizacao do frame f_detalhes */
   ON ENTRY, VALUE-CHANGED OF b_crawlcs IN FRAME f_consulta DO:
   
      IF   AVAILABLE crawlcs   THEN
           DISPLAY crawlcs.cdempres    crawlcs.nmfuncio
                   crawlcs.nrdocmto    crawlcs.nmarqenv
                   STRING(crawlcs.hrtransf,"HH:MM:SS") @ crawlcs.hrtransf
                   WITH FRAME f_detalhes.      
   END.
   
   ASSIGN tel_dtmvtolt = glb_dtmvtolt.

   DISPLAY glb_cddopcao WITH FRAME f_consulta.
   
   UPDATE tel_dtmvtolt    tel_cdagenci
          tel_nrdconta    tel_nmarqenv
          tel_dssitlcs
          WITH FRAME f_consulta

   EDITING:

      DO WHILE TRUE:
      
         READKEY.
               
         IF   FRAME-FIELD = "tel_nmarqenv"   THEN
              DO:
                  IF   KEY-LABEL(LASTKEY) = "F7"   THEN
                       DO:
                           RUN zoom_arquivos(INPUT INPUT FRAME f_consulta
                                             tel_dtmvtolt).
                                               
                           tel_nmarqenv = RETURN-VALUE.
                  
                           DISPLAY tel_nmarqenv WITH FRAME f_consulta.
                       END.
                       
                  IF   NOT CAN-DO("END-ERROR,GO,RETURN,TAB,BACK-TAB," +
                                  "BACKSPACE,CURSOR-UP,CURSOR-DOWN",
                                  KEYFUNCTION(LASTKEY)) THEN
                       NEXT.
              END.
              
         APPLY LASTKEY.
         
         LEAVE.
      END.
   END. /* Fim EDITING */
   
   EMPTY TEMP-TABLE crawlcs.
   
   FOR EACH craplcs  WHERE craplcs.cdcooper = glb_cdcooper        AND
                           craplcs.dtmvtolt = tel_dtmvtolt        AND

                           /* CONTA ou todas as contas */
                          (craplcs.nrdconta = tel_nrdconta   OR
                           tel_nrdconta     = 0)                  AND

                           /* Envio */
                           craplcs.flgenvio = tel_dssitlcs        AND
                           
                           /* Arquivo */
                          (craplcs.nmarqenv = tel_nmarqenv     OR
                           tel_nmarqenv     = "TODOS ARQUIVOS" OR
                           tel_dssitlcs     = NO               OR
                           tel_cdagenci    <> 0)                  AND
                           
                           /* Creditos de salario */
                          (craplcs.cdhistor = 560   OR
                           craplcs.cdhistor = 561)                NO-LOCK,

       FIRST crapccs WHERE crapccs.cdcooper = glb_cdcooper        AND
                           crapccs.nrdconta = craplcs.nrdconta    AND
                                          
                           /* PA ou todos os PA'S */
                          (crapccs.cdagenci = tel_cdagenci   OR
                           tel_cdagenci     = 0)                  NO-LOCK:
                           
       CREATE crawlcs.
       ASSIGN crawlcs.nrdconta = craplcs.nrdconta
              crawlcs.cdempres = crapccs.cdempres
              crawlcs.dtmvtolt = craplcs.dtmvtolt
              crawlcs.dttransf = craplcs.dttransf
              crawlcs.vllanmto = craplcs.vllanmto
              crawlcs.cdbantrf = crapccs.cdbantrf
              crawlcs.cdagetrf = crapccs.cdagetrf
              crawlcs.nrctatrf = crapccs.nrctatrf
              crawlcs.flgenvio = craplcs.flgenvio
              crawlcs.cdagenci = crapccs.cdagenci
              crawlcs.nmfuncio = crapccs.nmfuncio
              crawlcs.nrdocmto = craplcs.nrdocmto
              crawlcs.nmarqenv = craplcs.nmarqenv
              crawlcs.hrtransf = craplcs.hrtransf.
   END.
   
   OPEN QUERY q_crawlcs FOR EACH crawlcs NO-LOCK.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      UPDATE b_crawlcs WITH FRAME f_consulta.
      LEAVE.
   END.
   
END PROCEDURE. /* Fim opcao_c */

PROCEDURE opcao_x:
        
  HIDE FRAME f_trfsal.
  HIDE FRAME f_helpopcao.

  CLEAR FRAME f_browser_x.
  CLEAR FRAME q_craxlcs_x.
  
  RUN consulta_registros(OUTPUT TABLE craxlcs).
      
  OPEN QUERY q_craxlcs_x FOR EACH craxlcs NO-LOCK.    
  
  REPOSITION q_craxlcs_x TO ROW(1).  
  
  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    UPDATE b_craxlcs_x WITH FRAME f_browser_x.
    LEAVE.
  END.  
  
  EMPTY TEMP-TABLE craxlcs.
        
  CLEAR FRAME f_browser_x.
  CLEAR FRAME q_craxlcs_x.
  
  HIDE FRAME f_browser_x.
  HIDE FRAME q_craxlcs_x.
  HIDE BROWSE b_craxlcs_x.
          
END PROCEDURE. /* Fim opcao_x */

PROCEDURE opcao_e:
        
  HIDE FRAME f_trfsal.
  HIDE FRAME f_helpopcao.

  CLEAR FRAME f_browser_e.
  CLEAR FRAME q_craxlcs_e.
  
  RUN consulta_registros(OUTPUT TABLE craxlcs).
      
  OPEN QUERY q_craxlcs_e FOR EACH craxlcs NO-LOCK.    
  
  REPOSITION q_craxlcs_e TO ROW(1).  
  
  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    UPDATE b_craxlcs_e WITH FRAME f_browser_e.
    LEAVE.
  END. 
  
  EMPTY TEMP-TABLE craxlcs.
        
  CLEAR FRAME f_browser_e.
  CLEAR FRAME q_craxlcs_e.
  
  HIDE FRAME f_browser_e.
  HIDE FRAME q_craxlcs_e.
  HIDE BROWSE b_craxlcs_e.
  
END PROCEDURE. /* Fim opcao_e */

PROCEDURE opcao_r:

  DEF  VAR tel_dtmvtolt AS DATE                                       NO-UNDO.

  DEF  VAR rel_dssitlcs AS CHAR                                       NO-UNDO.
  DEF  VAR rel_vllanemp LIKE craplcs.vllanmto                         NO-UNDO.
  DEF  VAR rel_vltotlan LIKE craplcs.vllanmto                         NO-UNDO.

  /* Variaveis para impressao */
  DEF   VAR rel_nmempres     AS CHAR    FORMAT "x(15)"                NO-UNDO.
  DEF   VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.
  DEF   VAR rel_nrmodulo AS INT     FORMAT "9"                        NO-UNDO.
  DEF   VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                INIT ["DEP. A VISTA   ","CAPITAL        ",
                                      "EMPRESTIMOS    ","DIGITACAO      ",
                                      "GENERICO       "]             NO-UNDO.

  { includes/cabrel132_1.i }


  FORM glb_cddopcao  AT  3  LABEL "Opcao"
      
      tel_dtmvtolt  AT 16  LABEL "Referencia"         FORMAT "99/99/9999"
      WITH ROW 6 COLUMN 2 NO-BOX SIDE-LABELS OVERLAY FRAME f_relatorio.
      
  FORM "RELACAO DE TRANSFERENCIA DE CREDITO DO SALARIO -"   AT 36
      tel_dtmvtolt  NO-LABEL       FORMAT "99/99/9999"
      SKIP(2)
      WITH SIDE-LABELS NO-BOX DOWN WIDTH 132 FRAME f_rel_titulo.
      
  FORM rel_dssitlcs        LABEL "SITUACAO"        FORMAT "x(20)"
      SKIP(1)
      "EMPRESA"
      "CONTA"             AT  27
      "NOME"              AT  34
      "DATA CREDITO"      AT  76
      "DATA TRANSMISSAO"  AT  90
      "HORA"              AT 108
      "VALOR"             AT 128
      WITH SIDE-LABELS NO-BOX DOWN WIDTH 132 FRAME f_rel_cabecalho.
      
  FORM crapemp.nmextemp           FORMAT "x(19)"
      crapccs.nrdconta   AT  22
      crapccs.nmfuncio   AT  34  FORMAT "x(40)"
      craplcs.dtmvtolt   AT  77
      craplcs.dttransf   AT  93
      craplcs.hrtransf   AT 108
      craplcs.vllanmto   AT 119  FORMAT "zzz,zzz,zz9.99"
      WITH NO-LABELS NO-BOX DOWN WIDTH 132 FRAME f_rel_dados.

  ASSIGN tel_dtmvtolt    = glb_dtmvtolt
        glb_cdcritic    = 0
        glb_nrdevias    = 1
        glb_cdempres    = 11
        rel_nrmodulo    = 1
        glb_cdrelato[1] = 443.

  DISPLAY glb_cddopcao
         WITH FRAME f_relatorio.
                 
  UPDATE tel_dtmvtolt
        WITH FRAME f_relatorio.

  INPUT THROUGH basename `tty` NO-ECHO.
  SET aux_nmendter WITH FRAME f_terminal.
  INPUT CLOSE.

  aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                       aux_nmendter.
   
  UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").
   
  ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

  OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 80.

  VIEW STREAM str_1 FRAME f_cabrel132_1.

  DISPLAY STREAM str_1
         tel_dtmvtolt
         WITH FRAME f_rel_titulo.

  FOR EACH crapccs WHERE crapccs.cdcooper = glb_cdcooper       NO-LOCK,
     EACH craplcs WHERE craplcs.cdcooper = crapccs.cdcooper   AND
                        craplcs.nrdconta = crapccs.nrdconta   AND
                        craplcs.dtmvtolt = tel_dtmvtolt       AND
                       
                        /* Creditos de salario */
                       (craplcs.cdhistor = 560   OR
                        craplcs.cdhistor = 561)               NO-LOCK
                        BREAK BY craplcs.flgenvio
                                BY crapccs.cdempres
                                  BY craplcs.nrdconta:

     IF   FIRST-OF(craplcs.flgenvio)   THEN
          DO:
              ASSIGN rel_vltotlan = 0
                     rel_dssitlcs = IF craplcs.flgenvio = NO THEN
                                       "NAO ENVIADO"
                                    ELSE
                                       "ENVIADO".
                                
              DISPLAY STREAM str_1
                      rel_dssitlcs
                      WITH FRAME f_rel_cabecalho.
                      
          END.
          
     IF   FIRST-OF(crapccs.cdempres)   THEN
          DO:
              rel_vllanemp = 0.
     
              FIND crapemp WHERE crapemp.cdcooper = crapccs.cdcooper   AND
                                 crapemp.cdempres = crapccs.cdempres
                                 NO-LOCK.
          END.

     DISPLAY STREAM str_1
            (STRING(crapccs.cdempres,"99999") + 
             "-" + 
             STRING(crapemp.nmextemp,"x(15)"))
                    WHEN FIRST-OF(crapccs.cdempres) @ crapemp.nmextemp
                    
             crapccs.nrdconta
             crapccs.nmfuncio
             craplcs.dtmvtolt
             craplcs.dttransf
             STRING(craplcs.hrtransf,"HH:MM") @ craplcs.hrtransf
             craplcs.vllanmto
             WITH FRAME f_rel_dados.
             
     DOWN STREAM str_1 WITH FRAME f_rel_dados.
     
     ASSIGN rel_vllanemp = rel_vllanemp + craplcs.vllanmto
            rel_vltotlan = rel_vltotlan + craplcs.vllanmto.
            
     /* Total de cada empresa */
     IF   LAST-OF(crapccs.cdempres)   THEN
          DO:
              DISPLAY STREAM str_1
                      "TOTAL DA EMPRESA" AT  90
                      rel_vllanemp       AT 113 NO-LABEL
                                                FORMAT "z,zzz,zzz,zzz,zz9.99"
                      WITH NO-BOX WIDTH 132 FRAME f_tel_dados_tot.
                      
              DOWN 2 STREAM str_1 WITH FRAME f_rel_dados_tot.
          END.
          
     /* Total por situacao */
     IF   LAST-OF(craplcs.flgenvio)   THEN
          DO:
              DISPLAY STREAM str_1
                      "TOTAL " + rel_dssitlcs 
                                      AT  90 FORMAT "x(17)"
                      rel_vltotlan    AT 113 NO-LABEL
                                             FORMAT "z,zzz,zzz,zzz,zz9.99"
                      WITH NO-BOX WIDTH 132 FRAME f_tel_dados_tot_ger.

              DOWN 2 STREAM str_1 WITH FRAME f_rel_dados_tot_ger.
           END.
  END.

  /* Se nao teve registros */
  IF   PAGE-NUMBER(str_1)  = 1   AND
      LINE-COUNTER(str_1) = 4   THEN
      DO:
          OUTPUT STREAM str_1 CLOSE.
          MESSAGE "NAO HOUVERAM MOVIMENTACOES PARA A DATA INFORMADA!!!".
          PAUSE 3 NO-MESSAGE.
          RETURN.
      END.
  ELSE
      OUTPUT STREAM str_1 CLOSE.

  ASSIGN glb_nmarqimp = aux_nmarqimp
        glb_nmformul = "132col"
        glb_nrdevias = 1
        par_flgrodar = TRUE.

  /* Somente para a impressao */
  FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

  { includes/impressao.i }

END PROCEDURE. /* Fim opcao_r */

PROCEDURE opcao_b:
   
  RUN fontes/confirma.p (INPUT "",
                        OUTPUT aux_confirma).
                                       
  IF aux_confirma <> "S" THEN
    DO:
      RETURN.
    END.
   
  ASSIGN glb_cdcritic = 0
         glb_dscritic = "".
          
 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
      
  /* Efetuar a chamada a rotina Oracle */
  RUN STORED-PROCEDURE pc_trfsal_opcao_b
  aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper     /* Código da Cooperativa*/
                                      ,INPUT 0                /* Cod. Agencia */
                                      ,INPUT 1                /* Numero  Caixa */
                                      ,INPUT glb_cdoperad     /* Codigo Operador*/
                                      ,INPUT 0                /* Codigo Empresa*/
                                      ,OUTPUT glb_cdcritic    /* Código da crítica */
                                      ,OUTPUT glb_dscritic).  /* Descrição da crítica */

  /* Fechar o procedimento para buscarmos o resultado */ 
  CLOSE STORED-PROC pc_trfsal_opcao_b
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
  
  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

  ASSIGN glb_cdcritic = pc_trfsal_opcao_b.pr_cdcritic
         glb_dscritic = pc_trfsal_opcao_b.pr_dscritic.
          
  IF (glb_dscritic <> ? AND glb_dscritic <> "")  THEN
     DO:
         MESSAGE glb_dscritic. 
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
              PAUSE 3 NO-MESSAGE. 
              RETURN.            
         END.
         HIDE MESSAGE.
         
     END.
  ELSE
     DO:
         MESSAGE "Arquivo gerado com sucesso!".
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
             PAUSE 3 NO-MESSAGE.
             RETURN.
         END. 
         HIDE MESSAGE.
         
     END.   

END PROCEDURE. /* Fim opcao_b */

PROCEDURE opcao_t:

   DEF  VAR tel_dtmvtolt AS DATE                                       NO-UNDO.
   DEF  VAR tel_nrdconta LIKE crapass.nrdconta                         NO-UNDO.

   DEF  VAR aux_tpimprim AS LOGICAL FORMAT "Tela/Impressora"           NO-UNDO.

   DEF  VAR rel_dshistor AS CHAR                                       NO-UNDO.
   
   FORM glb_cddopcao  AT  3  LABEL "Opcao"
        
        tel_dtmvtolt  AT 16  LABEL "A partir de"         FORMAT "99/99/9999"
                             HELP "Informe a data inicial a ser consultada"
                             VALIDATE(tel_dtmvtolt <> ?,
                                      "013 - Data errada.")
                                      
        tel_nrdconta  AT 45  LABEL "Conta/dv"
                             HELP "Informe a conta/dv"
                             VALIDATE(CAN-FIND(crapccs WHERE crapccs.cdcooper =
                                                             glb_cdcooper AND
                                                             crapccs.nrdconta =
                                                             tel_nrdconta
                                                             NO-LOCK),
                                      "127 - Conta errada.")
        WITH ROW 6 COLUMN 2 NO-BOX SIDE-LABELS OVERLAY FRAME f_extrato.
        
   FORM "EXTRATO DE MOVIMENTACAO DE CONTA SALARIO - A PARTIR DE"   AT 8
        tel_dtmvtolt          NO-LABEL           FORMAT "99/99/9999"
        SKIP(1)
        crapccs.nrdconta AT 2 LABEL "CONTA/DV"
        SKIP
        crapccs.nmfuncio AT 6 LABEL "NOME"
        SKIP(1)
        WITH SIDE-LABELS NO-BOX DOWN WIDTH 80 FRAME f_ext_cabecalho.
        
   FORM craplcs.dtmvtolt  AT  2   LABEL "DATA"
        rel_dshistor      AT 14   LABEL "HISTORICO"   FORMAT "x(25)"
        craplcs.nrdocmto  AT 41   LABEL "DOCUMENTO"   FORMAT "zzzzzzzzz9"
        craphis.indebcre  AT 54   LABEL "D/C"
        craplcs.vllanmto  AT 60   LABEL "VALOR"
        WITH NO-BOX NO-LABELS DOWN WIDTH 80 FRAME f_ext_dados.

   
   ASSIGN tel_dtmvtolt = glb_dtmvtolt.

   DISPLAY glb_cddopcao WITH FRAME f_extrato.
   
   UPDATE tel_dtmvtolt    tel_nrdconta
          WITH FRAME f_extrato.
   
   INPUT THROUGH basename `tty` NO-ECHO.
   SET aux_nmendter WITH FRAME f_terminal.
   INPUT CLOSE.

   aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                         aux_nmendter.
     
   UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").
     
   ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".
   
   OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 80.
 
   FIND crapccs WHERE crapccs.cdcooper = glb_cdcooper AND
                      crapccs.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

   DISPLAY STREAM str_1
           tel_dtmvtolt    crapccs.nrdconta    crapccs.nmfuncio
           WITH FRAME f_ext_cabecalho. 
   
   FOR EACH craplcs WHERE craplcs.cdcooper  = glb_cdcooper   AND
                          craplcs.dtmvtolt >= tel_dtmvtolt   AND
                          craplcs.nrdconta  = tel_nrdconta   NO-LOCK
                          BY craplcs.dtmvtolt
                            BY craplcs.nrdocmto:
                           
       FIND craphis WHERE
            craphis.cdcooper = glb_cdcooper AND
            craphis.cdhistor = craplcs.cdhistor
                          NO-LOCK NO-ERROR.
                        
       rel_dshistor = STRING(craphis.cdhistor,"9999") + "-" +
                      craphis.dshistor.
                          
       DISPLAY STREAM str_1
               craplcs.dtmvtolt    rel_dshistor
               craplcs.nrdocmto    craphis.indebcre
               craplcs.vllanmto
               WITH FRAME f_ext_dados.
               
       DOWN STREAM str_1 WITH FRAME f_ext_dados.
   END.
   
   OUTPUT STREAM str_1 CLOSE.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      MESSAGE "Voce deseja visualizar o extrato em TELA ou na"
              "IMPRESSORA? (T/I)" UPDATE aux_tpimprim.
      LEAVE.
   END.  /*  Fim do DO WHILE TRUE  */
   
   IF   aux_tpimprim   THEN
        RUN fontes/visrel.p (INPUT aux_nmarqimp).
   ELSE
        DO:
            ASSIGN glb_nmarqimp = aux_nmarqimp
                   glb_nmformul = "80col"
                   glb_nrdevias = 1
                   par_flgrodar = TRUE.
   
            /* Somente para a impressao */
            FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper 
                                     NO-LOCK NO-ERROR.
   
            { includes/impressao.i }
        END.

END PROCEDURE. /* Fim opcao_t */

/* Verifica se existe o lote, cria e/ou "prende" conforme necessario */
PROCEDURE verifica_lote:

    DO WHILE TRUE:

       FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                          craplot.dtmvtolt = glb_dtmvtolt   AND
                          craplot.cdagenci = 1              AND
                          craplot.cdbccxlt = 100            AND
                          craplot.nrdolote = 10200          AND
                          craplot.tplotmov = 32
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE craplot   THEN
            DO:
                IF   LOCKED(craplot)   THEN
                     DO:
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     DO:
                         CREATE craplot.
                         ASSIGN craplot.cdcooper = glb_cdcooper
                                craplot.dtmvtolt = glb_dtmvtolt
                                craplot.cdagenci = 1
                                craplot.cdbccxlt = 100
                                craplot.nrdolote = 10200
                                craplot.tplotmov = 32.
                         VALIDATE craplot.
                     END.
            END.

       LEAVE.
    END.
    
END PROCEDURE. /* Fim verifica_lote */

PROCEDURE consulta_registros:
  DEFINE OUTPUT PARAMETER TABLE FOR craxlcs.
   
  DEF VAR aux_cdhistor AS INT.
  
  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                
  /*** Faz a busca do historico da transação ***/
  RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement
     aux_ponteiro = PROC-HANDLE
     ("SELECT gene0001.fn_param_sistema('CRED','" +
      STRING(glb_cdcooper) + "','FOLHAIB_HIST_REC_TECSAL') FROM DUAL").

  FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = aux_ponteiro:
     ASSIGN aux_cdhistor = INT(proc-text).
  END.

  CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement
     WHERE PROC-HANDLE = aux_ponteiro.

  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

  EMPTY TEMP-TABLE craxlcs.
  EMPTY TEMP-TABLE cratemp.
               
  FOR EACH craplcs WHERE craplcs.cdcooper = glb_cdcooper
                     AND craplcs.dtmvtolt >= glb_dtmvtoan /* Dia atual ou dia anterior */
                     AND craplcs.cdhistor = aux_cdhistor
                     AND craplcs.flgenvio = FALSE /* Não enviados */
                     AND craplcs.flgopfin = FALSE /* False [Recusadas na Cabine] */ NO-LOCK,
    
    EACH crapccs WHERE crapccs.cdcooper = craplcs.cdcooper
                   AND crapccs.nrdconta = craplcs.nrdconta NO-LOCK:
              
      CREATE craxlcs.
      ASSIGN craxlcs.cdcooper = craplcs.cdcooper
             craxlcs.nrdconta = craplcs.nrdconta
             craxlcs.cdagenci = craplcs.cdagenci
             craxlcs.dtmvtolt = craplcs.dtmvtolt
             craxlcs.dttransf = craplcs.dttransf
             craxlcs.vllanmto = craplcs.vllanmto
             craxlcs.cdbantrf = crapccs.cdbantrf
             craxlcs.cdagetrf = crapccs.cdagetrf
             craxlcs.nrctatrf = crapccs.nrctatrf
             craxlcs.idseleca = ""
             craxlcs.idopetrf = craplcs.idopetrf
             craxlcs.nrridlfp = craplcs.nrridlfp
             craxlcs.cdhistor = craplcs.cdhistor
             craxlcs.nrdocmto = craplcs.nrdocmto.    
  END.
  
END PROCEDURE.

PROCEDURE efetua_processo_e:
  
  { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
  
  /*** Faz a busca do historico da transação ***/
  RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement
   aux_ponteiro = PROC-HANDLE
   ("SELECT gene0001.fn_param_sistema('CRED','" +
    STRING(glb_cdcooper) + "','FOLHAIB_HIST_DEV_TECSAL') FROM DUAL").
  
  FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = aux_ponteiro:
   ASSIGN aux_cdhisdev = INT(proc-text).
  END.
  
  CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement
   WHERE PROC-HANDLE = aux_ponteiro.

  /*** Faz a busca do historico da transação ***/
  RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement
   aux_ponteiro = PROC-HANDLE
   ("SELECT gene0001.fn_param_sistema('CRED','" +
    STRING(glb_cdcooper) + "','FOLHAIB_NRLOTE_CTASAL') FROM DUAL").
  
  FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = aux_ponteiro:
   ASSIGN aux_nrdolote = INT(proc-text).
  END.
  
  CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement
   WHERE PROC-HANDLE = aux_ponteiro.
  
  { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
    
  /* Atualizacao de lancamentos para empresas */
  { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
  
  /*** Faz a busca do historico da transação ***/
  RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement
   aux_ponteiro = PROC-HANDLE
   ("SELECT gene0001.fn_param_sistema('CRED','" +
    STRING(glb_cdcooper) + "','FOLHAIB_HIST_EST_TECSAL') FROM DUAL").
  
  FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = aux_ponteiro:
    ASSIGN aux_cdhisest = INT(proc-text).
  END.
  
  CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement
   WHERE PROC-HANDLE = aux_ponteiro.
  
  { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }  
  
  Processo: 
  DO TRANSACTION ON ERROR  UNDO Processo, LEAVE Processo
                 ON QUIT   UNDO Processo, LEAVE Processo
                 ON STOP   UNDO Processo, LEAVE Processo
                 ON ENDKEY UNDO Processo, LEAVE Processo:
  
    FIND FIRST craplot WHERE craplot.cdcooper = glb_cdcooper
                         AND craplot.dtmvtolt = glb_dtmvtolt
                         AND craplot.cdbccxlt = 100
                         AND craplot.nrdolote = aux_nrdolote EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF NOT AVAILABLE craplot THEN
        DO:
            CREATE craplot.
            ASSIGN craplot.cdcooper = glb_cdcooper
                   craplot.dtmvtolt = glb_dtmvtolt
                   craplot.cdagenci = 1
                   craplot.cdbccxlt = 100
                   craplot.nrdolote = aux_nrdolote
                   craplot.tplotmov = 1.
        END.
        
    IF aux_tipselec = "F6" THEN
      DO:
        FOR EACH craxlcs WHERE craxlcs.cdcooper = glb_cdcooper EXCLUSIVE-LOCK:
                           
          ASSIGN craxlcs.idseleca = "*".
          
        END.                   
      END.
    
    FOR EACH craxlcs WHERE craxlcs.cdcooper = glb_cdcooper
                       AND craxlcs.idseleca <> "" 
                       AND craxlcs.idseleca <> ? NO-LOCK:    
  
      FIND craplcs WHERE craplcs.cdcooper = glb_cdcooper
                     AND craplcs.dtmvtolt = glb_dtmvtolt
                     AND craplcs.nrdconta = craxlcs.nrdconta
                     AND craplcs.cdhistor = aux_cdhisdev
                     AND craplcs.nrdocmto = craxlcs.nrdocmto NO-LOCK NO-ERROR NO-WAIT.

      IF AVAILABLE craplcs THEN
        ASSIGN aux_nrdcomto = craxlcs.nrdocmto + 1000000.
      ELSE
        ASSIGN aux_nrdcomto = craxlcs.nrdocmto.              
      
      CREATE craplcs.
      ASSIGN craplcs.cdcooper = glb_cdcooper
             craplcs.cdopecrd = glb_cdoperad
             craplcs.dtmvtolt = glb_dtmvtolt
             craplcs.nrdconta = craxlcs.nrdconta
             craplcs.nrdocmto = aux_nrdcomto
             craplcs.vllanmto = craxlcs.vllanmto
             craplcs.cdhistor = aux_cdhisdev
             craplcs.nrdolote = aux_nrdolote
             craplcs.cdbccxlt = 100
             craplcs.cdagenci = 1
             craplcs.flgenvio = TRUE
             craplcs.flgopfin = TRUE
             craplcs.dttransf = TODAY
             craplcs.hrtransf = TIME
             craplcs.idopetrf = craxlcs.idopetrf
             craplcs.cdopetrf = glb_cdoperad
             craplcs.cdsitlcs = 1
             craplcs.nrridlfp = craxlcs.nrridlfp
             craplot.qtinfoln = craplot.qtinfoln + 1
             craplot.qtcompln = craplot.qtcompln + 1
             craplot.vlinfodb = craplot.vlinfodb + craxlcs.vllanmto
             craplot.vlcompdb = craplot.vlcompdb + craxlcs.vllanmto
             craplot.nrseqdig = craplot.nrseqdig + 1.

      FIND craplfp WHERE craplfp.cdcooper = glb_cdcooper
                     AND RECID(craplfp)   = craxlcs.nrridlfp EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF AVAILABLE craplfp THEN
          DO:
              ASSIGN craplfp.idsitlct = "D"
                     craplfp.dsobslct = "Registro devolvido a empresa por Rejeição da TEC".
          END.            
          
       FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper
                      AND crapemp.cdempres = craplfp.cdempres NO-LOCK NO-ERROR NO-WAIT.

       IF AVAILABLE crapemp THEN
          DO:
              FIND cratemp WHERE cratemp.cdempres = crapemp.cdempres NO-LOCK NO-ERROR.

              IF AVAILABLE cratemp THEN
                  DO:
                      FIND CURRENT cratemp EXCLUSIVE-LOCK.
                      ASSIGN cratemp.vllanmto = cratemp.vllanmto + craxlcs.vllanmto.
                  END.
              ELSE
                  DO:
                      CREATE cratemp.
                      ASSIGN cratemp.cdempres = crapemp.cdempres
                             cratemp.nrdconta = crapemp.nrdconta
                             cratemp.vllanmto = craxlcs.vllanmto.
                  END.
          END.
 
      FIND craplcs WHERE craplcs.cdcooper = craxlcs.cdcooper
                     AND craplcs.dtmvtolt = craxlcs.dtmvtolt
                     AND craplcs.nrdconta = craxlcs.nrdconta
                     AND craplcs.cdhistor = craxlcs.cdhistor
                     AND craplcs.nrdocmto = craxlcs.nrdocmto EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
      IF AVAILABLE craplcs THEN
        DO:
          ASSIGN craplcs.flgenvio = TRUE. 
        END.
    END.
    
    /* Leitura de registros de empresas */
    FOR EACH cratemp NO-LOCK:
        FIND craptab WHERE       craptab.cdcooper  = glb_cdcooper
                       AND UPPER(craptab.nmsistem) = "CRED"
                       AND UPPER(craptab.tptabela) = "GENERI"
                       AND       craptab.cdempres  = 0
                       AND UPPER(craptab.cdacesso) = "NUMLOTEFOL"
                       AND       craptab.tpregist  = cratemp.cdempres NO-LOCK NO-ERROR NO-WAIT.


        IF AVAILABLE craptab THEN
          DO:
            ASSIGN aux_nrdolote = INT(craptab.dstextab).
          END.
        
        /* Verifica se lote existe */
        FIND craplot WHERE craplot.cdcooper = glb_cdcooper
                       AND craplot.dtmvtolt = glb_dtmvtolt
                       AND craplot.cdagenci = 1
                       AND craplot.cdbccxlt = 100
                       AND craplot.nrdolote = aux_nrdolote EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        
        IF NOT AVAILABLE craplot THEN
          DO:
            CREATE craplot.
            ASSIGN craplot.cdcooper = glb_cdcooper
                   craplot.dtmvtolt = glb_dtmvtolt
                   craplot.cdagenci = 1
                   craplot.cdbccxlt = 100
                   craplot.nrdolote = aux_nrdolote
                   craplot.tplotmov = 1.
          END.
                  
        /* Atualiza registros de lote com valores de estorno */
        ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
               craplot.qtcompln = craplot.qtcompln + 1
               craplot.vlinfocr = craplot.vlinfocr + cratemp.vllanmto
               craplot.vlcompcr = craplot.vlcompcr + cratemp.vllanmto
               craplot.nrseqdig = craplot.nrseqdig + 1.
               
        /* Criacao do registro de lancamento de estorno */       
        CREATE craplcm.
        ASSIGN craplcm.dtmvtolt = glb_dtmvtolt
               craplcm.cdagenci = 1
               craplcm.cdbccxlt = 100
               craplcm.nrdolote = aux_nrdolote
               craplcm.nrdconta = cratemp.nrdconta
               craplcm.nrdctabb = cratemp.nrdconta
               craplcm.nrdctitg = STRING(cratemp.nrdconta,"999999999")
               craplcm.nrdocmto = craplot.nrseqdig
               craplcm.cdhistor = aux_cdhisest
               craplcm.vllanmto = cratemp.vllanmto
               craplcm.nrseqdig = craplot.nrseqdig
               craplcm.cdcooper = glb_cdcooper.
        
    END.
    
  END. /* Fim Transacao */

  RETURN "OK".
  
END PROCEDURE.

PROCEDURE efetua_processo_x:
                  
  /*** Faz a busca de horario de transação ***/
  RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement
   aux_ponteiro = PROC-HANDLE
   ("SELECT trim(to_char(trunc(crapcop.fimopstr/3600),'00'))||':'||" +
    "trim(to_char(((crapcop.fimopstr/3600) - trunc(crapcop.fimopstr/3600))*60,'00')) " +
	" FROM crapcop WHERE cdcooper = " +  STRING(glb_cdcooper) ).
	   

  FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = aux_ponteiro:
      ASSIGN aux_strhrlim = TRIM(proc-text).
  END.

  CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement
   WHERE PROC-HANDLE = aux_ponteiro.

  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

  ASSIGN aux_hrlimite = (((INT(ENTRY(1,aux_strhrlim,":")) * 60) + INT(ENTRY(2,aux_strhrlim,":"))) * 60).
  
  IF aux_hrlimite < TIME THEN
    DO:
      ASSIGN aux_strhrlim  = "Horário SPB " + aux_strhrlim + " atingido, deseja continuar?".

      RUN fontes/confirma.p (INPUT aux_strhrlim,
                            OUTPUT aux_confirma).
             
      IF aux_confirma <> "S" THEN
        DO:
          RETURN "HOR".
        END.
      ELSE
          DO:
            
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
      
            /* Efetuar a chamada a rotina Oracle */
            RUN STORED-PROCEDURE pc_trfsal_opcao_x
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper     /* Código da Cooperativa*/
                                                ,INPUT 0                /* Cod. Agencia */
                                                ,INPUT 1                /* Numero  Caixa */
                                                ,INPUT glb_cdoperad     /* Codigo Operador*/
                                                ,INPUT 0                /* Codigo Empresa*/
                                                ,OUTPUT aux_cdcritic    /* Código da crítica */
                                                ,OUTPUT aux_dscritic).  /* Descrição da crítica */

            /* Fechar o procedimento para buscarmos o resultado */ 
            CLOSE STORED-PROC pc_trfsal_opcao_x
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
            
            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
          END.
    END.
  ELSE
    DO:
        
      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }        
             
      /* Efetuar a chamada a rotina Oracle */
      RUN STORED-PROCEDURE pc_trfsal_opcao_x
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper     /* Código da Cooperativa*/
                                            ,INPUT 0                /* Cod. Agencia */
                                            ,INPUT 1                /* Numero  Caixa */
                                            ,INPUT glb_cdoperad     /* Codigo Operador*/
                                            ,INPUT 0                /* Codigo Empresa*/
                                            ,OUTPUT aux_cdcritic    /* Código da crítica */
                                            ,OUTPUT aux_dscritic).  /* Descrição da crítica */

      /* Fechar o procedimento para buscarmos o resultado */ 
      CLOSE STORED-PROC pc_trfsal_opcao_x
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
      
      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    END.

  /* Busca possíveis erros */ 
  ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_cdcritic = pc_trfsal_opcao_x.pr_cdcritic 
                        WHEN pc_trfsal_opcao_x.pr_cdcritic <> ?
         aux_dscritic = pc_trfsal_opcao_x.pr_dscritic 
                        WHEN pc_trfsal_opcao_x.pr_dscritic <> ?.
    
  IF aux_cdcritic <> 0 OR
     (aux_dscritic <> ? AND
     aux_dscritic <> "")THEN
    DO:
      RUN gera_erro (INPUT glb_cdcooper,
                     INPUT glb_cdagenci,
                     INPUT 1,
                     INPUT 1,          /** Sequencia **/
                     INPUT aux_cdcritic,
                     INPUT-OUTPUT aux_dscritic).
      RETURN "NOK".
    END.
  
  RETURN "OK".
    
END PROCEDURE.
/* ......................................................................... */