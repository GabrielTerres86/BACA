/* ...........................................................................

   Programa: fontes/prcitg.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Abril/2005                      Ultima atualizacao: 29/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Tela para solicitar os processos referentes a C/C INTEGRACAO 
               para GERAR ARQUIVOS e PROCESSAR RETORNOS do Banco do Brasil.

   Alteracoes: 08/04/2005 - Criada opcao "D"(Diego). 

               07/07/2005 - Alimentado campo cdcooper da tabela crapsol (Diego).

               21/09/2005 - Incluir a opcao de processar o DEB668 (Ze Eduardo).
               
               28/10/2005 - Excluir os arquivos da conta integracao (COO*) que
                            estiverem ZERADOS (Evandro).
                            
               16/11/2005 - Definir as TRANSACOES e controle de somente um
                            usuario por vez usando a tela (Evandro).
                            
               07/12/2005 - Liberar os programas COO408/COO508 (Evandro).
               
               09/12/2005 - Restricao de processamento e geracao de arquivos 
                            por horarios de acordo com o manual (Evandro).
                            
               23/01/2006 - Limpar os arquivos de controle do gerenciador
                            financeiro "*.pak" e "*.cri" (Evandro).
                            
               31/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
                
               09/02/2006 - Inclusao de LOCK nas pesquisas - SQLWorks - Andre
               
               16/02/2006 - Liberar o COO410/COO510 (Evandro).
               
               24/04/2006 - Correcao na eliminacao da solicitacao (Evandro).
               
               27/04/2006 - Liberados  COO401/C00501 e COO510 (Diego).
               
               19/10/2006 - Permitir que o coordenador libere a tela no caso
                            do proprio operador estar "preso" (Evandro).

               29/11/2006 - Liberado para operadores 996 e 799 recebimento
                            apos 13:00 horas(Mirtes)
                            
               01/10/2007 - Alterada mensagem de liberacao de operador
                            bloqueado (Evandro).
                            
               11/03/2008 - Incluidos programas crps503.p e crps504.p
                           (ENCERRAMENTO CONTA ITG) (Diego).
                           
               04/04/2008 - Acertado para permitir Desbloqueio do arquivo
                            COO409 (Diego).
                         
               05/08/2008 - Comentado geracao do arquivo coo407 (Gabriel).

               20/08/2008 - Desconsiderar somente o SUPER-USUARIO na hora de 
                            restringir os horarios dos arquivos (Gabriel).
                            
               29/01/2009 - Retirar permissao do operador 799 (Gabriel).
               
               01/06/2009 - Retirado message "Pressione barra de espacao"
                            durante o processamento da opcao P e G.
                            Liberado acesso na tela somente para o operador
                            996 (Fernando).
              
               03/06/2009 - Alteracao CDOPERAD (Kbase).
               
               09/06/2009 - Inclusao da Importacao do Arquivo COO553 -
                            Estatisticas de Movimentacao das Contas de
                            ITG (GATI - Antonio)
                            
               18/06/2010 - Alteracao tamanho SET STREAM (Vitor).  
               
               
               28/10/2010 - Alterado para validar senha atraves do fonte
                            pedesenha.p (Adriano).
                            
               22/08/2011 - Incluir a chamada do programa para integrar o total
                            da fatura Cartao Credito BB (Ze).
                            
               18/04/2012 - Incluir departamento COMPE na geracao do arq. (Ze).
               
               28/06/2012 - Enviado parametro para o prg crps428.p para 
                            indicar se o arquivo COO510 foi processado (Tiago).
                            
               17/12/2013 - Inclusao de VALIDATE crapsol (Carlos)
               
              23/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
............................................................................. */

{ includes/var_online.i } 

DEF STREAM str_1.
DEF STREAM str_2.

DEF VAR aux_flrel510 AS LOGICAL                                     NO-UNDO.

DEF VAR aux_nmarquiv AS CHAR                                        NO-UNDO.
DEF VAR aux_tamarqui AS CHAR                                        NO-UNDO.
DEF VAR aux_confirma AS CHAR     FORMAT "!"                         NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                        NO-UNDO.
DEF VAR aux_ultlinha AS INT                                         NO-UNDO.
DEF VAR aux_contador AS INT                                         NO-UNDO.

DEF VAR aut_flgsenha AS LOGICAL                                     NO-UNDO.
DEF VAR aut_cdoperad AS CHAR                                        NO-UNDO.

DEF VAR tel_datadlog AS DATE     FORMAT "99/99/9999"                NO-UNDO.
DEF VAR tel_cddopcao AS CHAR     FORMAT "!(1)"                      NO-UNDO.

DEF VAR aux_dadosusr AS CHAR                                        NO-UNDO.
DEF VAR par_loginusr AS CHAR                                        NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                        NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                        NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                        NO-UNDO.
DEF VAR par_numipusr AS CHAR                                        NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                      NO-UNDO.


DEF TEMP-TABLE crawarq                                              NO-UNDO
    FIELD tparquiv  AS CHAR
    FIELD dsarquiv  AS CHAR.

DEF QUERY q_arquivos   FOR crawarq.
DEF QUERY q_desbloques FOR crawarq.

DEF BROWSE b_arquivos QUERY q_arquivos
    DISPLAY crawarq.tparquiv  COLUMN-LABEL "TIPO"       FORMAT "x(6)"
            crawarq.dsarquiv  COLUMN-LABEL "DESCRICAO"  FORMAT "x(57)"
            WITH 7 DOWN WIDTH 70 TITLE "Arquivos a serem gerados/processados".

DEF BROWSE b_desbloques QUERY q_desbloques
    DISPLAY crawarq.tparquiv  COLUMN-LABEL "TIPO"       FORMAT "x(6)"
            crawarq.dsarquiv  COLUMN-LABEL "DESCRICAO"  FORMAT "x(57)"
            WITH 7 DOWN WIDTH 70 TITLE "Desbloqueios a serem efetuados".
            
FORM SKIP(1)
     glb_cddopcao AT 5 LABEL  "Opcao"
       HELP "Informe a opcao(D-Desbloq./G-Geracao/L-Log/P-Process./R-Relat.)"
                        VALIDATE(CAN-DO("D,G,L,P,R",glb_cddopcao),
                                "014 - Opcao errada.")
     tel_datadlog AT 30 LABEL "Data do Log"
                        HELP "Informe a data do log desejado"
     SKIP(1)
     b_arquivos   AT  5 HELP "Pressione DELETE para excluir / F4 para sair"
     SKIP(2)
     WITH ROW 4 OVERLAY SIDE-LABELS NO-LABELS WIDTH 80 TITLE glb_tldatela 
          FRAME f_prcitg.
          
FORM b_desbloques  AT 5 HELP "Pressione ENTER para desbloquear / F4 para sair" 
     WITH ROW 7 OVERLAY SIDE-LABELS NO-LABELS WIDTH 75 NO-BOX WITH CENTERED
          FRAME f_desbloque.
  
ON "DELETE" OF b_arquivos IN FRAME f_prcitg DO:

    IF   NOT AVAILABLE crawarq   THEN
         RETURN.
             
    DELETE crawarq. 
        
    /* linha que foi deletada */
    aux_ultlinha = CURRENT-RESULT-ROW("q_arquivos").
    
    OPEN QUERY q_arquivos FOR EACH crawarq   BY crawarq.tparquiv.
    
    /* reposiciona o browse */
    REPOSITION q_arquivos TO ROW aux_ultlinha.
END.

ON RETURN OF b_desbloques IN FRAME f_desbloque DO:

    IF   NOT AVAILABLE crawarq   THEN
         RETURN.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       ASSIGN aux_confirma = "N"
              glb_cdcritic = 78.

       RUN fontes/critic.p.
       BELL.
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
    
    DO aux_contador = 1 TO 10 TRANSACTION:
    
       FIND craptab WHERE 
            craptab.cdcooper = glb_cdcooper        AND
            craptab.nmsistem = "CRED"              AND
            craptab.tptabela = "GENERI"            AND
            craptab.cdempres = 00                  AND
            craptab.cdacesso = "NRARQMVITG"        AND
            craptab.tpregist = INTEGER(SUBSTRING(crawarq.tparquiv,4,3))
            EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
    
       IF   NOT AVAILABLE craptab   THEN
            DO:
               IF   LOCKED craptab   THEN
                    DO:
                        RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.
                        
                        RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                        					 INPUT "banco",
                        					 INPUT "craptab",
                        					 OUTPUT par_loginusr,
                        					 OUTPUT par_nmusuari,
                        					 OUTPUT par_dsdevice,
                        					 OUTPUT par_dtconnec,
                        					 OUTPUT par_numipusr).
                        
                        DELETE PROCEDURE h-b1wgen9999.
                        
                        ASSIGN aux_dadosusr = 
                        "077 - Tabela sendo alterada p/ outro terminal.".
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 3 NO-MESSAGE.
                        LEAVE.
                        END.
                        
                        ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                        			  " - " + par_nmusuari + ".".
                        
                        HIDE MESSAGE NO-PAUSE.
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 5 NO-MESSAGE.
                        LEAVE.
                        END.
                      
                        NEXT.
                    END.
               ELSE
                    DO:
                        glb_cdcritic = 55.
                        LEAVE.
                    END.    
            END.
       ELSE
            DO:
                glb_cdcritic = 0.
                ASSIGN SUBSTRING(craptab.dstextab,7,1) = "0".
                LEAVE.
            END.
    END.  /*  Fim do DO .. TO  */

    IF   glb_cdcritic > 0 THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
             PAUSE 3 NO-MESSAGE.
             RETURN.
         END.         
                            
    DELETE  crawarq. 
        
    /* linha que foi desbloqueada */
    aux_ultlinha = CURRENT-RESULT-ROW("q_desbloques").
    
    OPEN QUERY q_desbloques FOR EACH crawarq BY crawarq.tparquiv. 
    
    /* reposiciona o browse */
    REPOSITION q_desbloques TO ROW aux_ultlinha.
END.

/* Verifica se o arquivo pode ser gerado */
FUNCTION verifica_horario RETURNS LOGICAL (INPUT par_tparquiv AS INT):

    FIND craptab WHERE craptab.cdcooper = glb_cdcooper        AND 
                       craptab.nmsistem = "CRED"              AND
                       craptab.tptabela = "GENERI"            AND
                       craptab.cdempres = 00                  AND
                       craptab.cdacesso = "NRARQMVITG"        AND
                       craptab.tpregist = par_tparquiv        NO-LOCK NO-ERROR.

    IF  (NOT AVAILABLE craptab                                    OR
         STRING(TIME,"HH:MM") > SUBSTRING(craptab.dstextab,9,5))  THEN
         RETURN FALSE.
    ELSE
         RETURN TRUE.

END FUNCTION.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

ASSIGN glb_cdcritic = 0
       glb_cddopcao = "P".    /* PROCESSAMENTO */
        
/* Somente um usuario pode usar a tela ao mesmo tempo */
DO WHILE TRUE:
   
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper        AND 
                      craptab.nmsistem = "CRED"              AND
                      craptab.tptabela = "GENERI"            AND
                      craptab.cdempres = 00                  AND
                      craptab.cdacesso = "NRARQMVITG"        AND
                      craptab.tpregist = 0                   NO-LOCK NO-ERROR.
                      
   IF   craptab.dstextab <> ""   THEN
        DO:
            HIDE MESSAGE.
            MESSAGE "Esta tela esta sendo usada pelo operador"
                    craptab.dstextab.
        
            /* Verifica se o operador que esta usando a tela eh o mesmo que
               esta tentando acessar */
            IF   glb_cdoperad <> SUBSTRING(craptab.dstextab,1,10)   THEN
                 DO:
                     MESSAGE "Peca a liberacao ao Coordenador/Gerente...".
                     PAUSE 2 NO-MESSAGE.

                     /* necessita da senha do coordenador/gerente */
                     RUN fontes/pedesenha.p (INPUT glb_cdcooper,
                                             INPUT 2,
                                             OUTPUT aut_flgsenha,
                                             OUTPUT aut_cdoperad).
                                          
                     IF   aut_flgsenha   THEN
                          LEAVE.
                 END.
            ELSE
                 DO:
                     MESSAGE "Aguarde ou pressione F4/END para sair...".
                     READKEY PAUSE 2.
                 END.
                 
            IF   KEY-FUNCTION(LASTKEY) = "END-ERROR"   THEN
                 DO:
                    /* Forca a saida para a tela do MENU */
                    glb_nmdatela = "".
                    RETURN.
                 END.

            NEXT.
        END.   
   ELSE
        DO TRANSACTION:
            FIND CURRENT craptab EXCLUSIVE-LOCK NO-ERROR.
            
            IF   AVAILABLE craptab   THEN
                 craptab.dstextab = STRING(glb_cdoperad,"x(10)") + "-" +
                                    glb_nmoperad.
                 
            RELEASE craptab.
            HIDE MESSAGE.
        END. 

    LEAVE.
   
END. /* Fim do DO WHILE */        

DO WHILE TRUE:  

   HIDE b_arquivos   IN FRAME f_prcitg.
   HIDE tel_datadlog IN FRAME f_prcitg.
   
   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      UPDATE glb_cddopcao WITH FRAME f_prcitg.
      
      IF   (glb_dsdepart <> "SUPORTE" AND
            glb_dsdepart <> "CARTOES" AND
            glb_dsdepart <> "COMPE"   AND
            glb_dsdepart <> "TI")     AND
           (glb_cddopcao <> "L"       AND
            glb_cddopcao <> "R")THEN
           DO:
              glb_cdcritic = 036.
              RUN fontes/critic.p.
              BELL.
              MESSAGE glb_dscritic.
              glb_cdcritic = 0.
              NEXT.
           END.
      
      LEAVE.
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "PRCITG"   THEN
                 DO:
                     DO TRANSACTION:
                        FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                                           craptab.nmsistem = "CRED"        AND
                                           craptab.tptabela = "GENERI"      AND
                                           craptab.cdempres = 00            AND
                                           craptab.cdacesso = "NRARQMVITG"  AND
                                           craptab.tpregist = 0
                                           EXCLUSIVE-LOCK NO-ERROR.
            
                        IF   AVAILABLE craptab   THEN
                             craptab.dstextab = "".
                     END. 

                     HIDE FRAME f_prcitg.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
           IF   glb_cddopcao <> "L" AND
                glb_cddopcao <> "R" THEN 
                DO:
                   { includes/acesso.i}
                END.
           aux_cddopcao = glb_cddopcao.
        END.                                 
   
   IF   glb_cddopcao = "G"   THEN
        RUN carrega_tabela_geracao.
   ELSE
   IF   glb_cddopcao = "P"   THEN
        RUN carrega_tabela_retorno.
   ELSE
   IF   glb_cddopcao = "D"   THEN
        DO:
            RUN opcao_d.
            CLOSE QUERY q_desbloques.
            NEXT.
        END.    
   ELSE   
   IF   glb_cddopcao = "L"   THEN
        DO:
            RUN opcao_l.
            NEXT.
        END.
   ELSE
   IF   glb_cddopcao = "R"   THEN
        DO:
            RUN opcao_r.
            NEXT.
        END.
   ELSE   
        NEXT.

   /* as opcoes G e P entram aqui, as outras executam NEXT */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:            
      OPEN QUERY q_arquivos FOR EACH crawarq   BY crawarq.tparquiv.
      UPDATE b_arquivos WITH FRAME f_prcitg.
      LEAVE.
   END.

   /* pede confirmacao */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.

      RUN fontes/critic.p.
      BELL.
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
           CLOSE QUERY q_arquivos. 
           NEXT.
        END.

   CLOSE QUERY q_arquivos.

   FIND FIRST crawarq NO-LOCK NO-ERROR.
   
   IF   AVAILABLE crawarq   THEN
        RUN executa.
   ElSE
        DO:
            glb_cdcritic = 239.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

END.  /* fim DO WHILE TRUE */

PROCEDURE carrega_tabela_retorno.
    
    DEF VAR aux_flghorar AS LOGICAL    INIT TRUE                     NO-UNDO.


    /*FOR EACH crawarq:
        DELETE crawarq.
    END.*/
    
    EMPTY TEMP-TABLE crawarq.
    
    ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + 
                          "/compel/recepcao/*.*".
            
    INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
                       NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

       SET STREAM str_1 aux_nmarquiv FORMAT "x(70)" .  
       
       /* Limpa arquivos de controle do gerenciador financeiro, *.cri, *.pak */
       IF   (aux_nmarquiv MATCHES "*COO5*"      OR
             aux_nmarquiv MATCHES "*DEB668*")   AND
            (aux_nmarquiv MATCHES "*.cri"       OR
             aux_nmarquiv MATCHES "*.pak")      THEN
            DO:
                UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").
                NEXT.
            END.
         
       IF   (aux_nmarquiv MATCHES "*COO5*")    AND
             aux_flghorar                      THEN
            DO:
                /* O processamento de arquivos da conta integracao, somente
                   podera ser feito antes das 13:00 para que nao sejam
                   processados arquivos incompletos */
                IF   STRING(TIME,"HH:MM") > "22:00"   THEN  /* Mirtes */
                     DO:
                        aux_flghorar = FALSE.
                        HIDE MESSAGE NO-PAUSE.
                        
                        MESSAGE "Horario limite para arquivos da Conta"
                                "Integracao excedido (13:00)".
                        
                        /* Para nao quebrar com F4/END */
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                           PAUSE 4 NO-MESSAGE.
                           LEAVE.
                        END.
                        
                        NEXT.
                     END.

                 /* Verifica se o arquivo esta vazio e o remove */
                INPUT STREAM str_2 THROUGH VALUE( "wc -m " + aux_nmarquiv + 
                                                  " 2> /dev/null") NO-ECHO.
                                                  
                SET STREAM str_2 aux_tamarqui FORMAT "x(30)".
                
                IF   INTEGER(SUBSTRING(aux_tamarqui,1,1)) = 0   THEN
                     DO:
                         UNIX SILENT VALUE("rm " + aux_nmarquiv + 
                                           " 2> /dev/null").
                         INPUT STREAM str_2 CLOSE.
                         NEXT.
                     END.

                INPUT STREAM str_2 CLOSE.
                
                FIND FIRST crawarq WHERE 
                           crawarq.tparquiv = SUBSTRING(aux_nmarquiv,
                                                 INDEX(aux_nmarquiv,"COO5"),6)
                           NO-LOCK NO-ERROR.
                                  
                IF   NOT AVAILABLE crawarq   THEN
                     DO TRANSACTION:
                        CREATE crawarq.
                        ASSIGN crawarq.tparquiv = CAPS(SUBSTRING(aux_nmarquiv,
                                                 INDEX(aux_nmarquiv,"COO5"),6))
                               crawarq.dsarquiv = 
                                          IF crawarq.tparquiv = "COO500" THEN
                                             "PROCESSAR RETORNO DO" + 
                                             " CADASTRAMENTO"
                                          ELSE
                                          IF crawarq.tparquiv = "COO501" THEN
                                             "PROCESSAR RETORNO DA ALTERACAO" +
                                             " DE LIMITES"
                                          ELSE
                                          IF crawarq.tparquiv = "COO504" THEN
                                             "PROCESSAR RETORNO DOS SALDOS" +
                                             " DISPONIVEIS"
                                          ELSE
                                          IF crawarq.tparquiv = "COO505" THEN
                                             "PROCESSAR RETORNO DAS" + 
                                             " ALTERACOES CADASTRAIS"
                                          ELSE
                                          IF crawarq.tparquiv = "COO506" THEN
                                             "PROCESSAR RETORNO DOS COMANDOS" +
                                             " DE CHEQUES"
                                          ELSE
                                          IF crawarq.tparquiv = "COO507" THEN
                                             "PROCESSAR RETORNO DOS COMANDOS" +
                                             " DE DEVOLUCAO CHEQUES"
                                          ELSE
                                          IF crawarq.tparquiv = "COO508" THEN
                                             "PROCESSAR RETORNO DA" +
                                             " INCLUSAO/EXCLUSAO NO CCF"
                                          ELSE
                                          IF crawarq.tparquiv = "COO509" THEN
                                             "PROCESSAR RETORNO DE" + 
                                             " ENCERRAMENTO DA CONTA INTEGRACAO"
                                          ELSE
                                          IF crawarq.tparquiv = "COO510" THEN
                                             "PROCESSAR RETORNO DA" +
                                             " MOVIMENTACAO PARA CARTAO DE" +
                                             " CREDITO"
                                          ELSE
                                          IF crawarq.tparquiv = "COO552" THEN
                                             "PROCESSAR ARQUIVO DA RELACAO" +
                                             " DE CONTAS CADASTRADAS"

                                          ELSE
                                          IF crawarq.tparquiv = "COO553" THEN
                                             "PROCESSAR ARQUIVO DA RELACAO" +
                                             " LANCAMENTOS CONTA INTEGRACAO" +
                                             " BB"
                                          ELSE
                                             "".
                                 
                        IF   crawarq.dsarquiv = ""   THEN
                             DELETE crawarq.
                     END.
            END.

       IF   (aux_nmarquiv MATCHES "*DEB668*")  THEN
            DO TRANSACTION:
                FIND FIRST crawarq WHERE 
                           crawarq.tparquiv = SUBSTRING(aux_nmarquiv,
                                                INDEX(aux_nmarquiv,"DEB668"),6)
                           NO-LOCK NO-ERROR.
                                                
                IF   NOT AVAILABLE crawarq   THEN
                     DO:
                        CREATE crawarq.
                        ASSIGN crawarq.tparquiv = "DEB668"
                               crawarq.dsarquiv = "PROCESSAR ARQUIVO DE" +
                                                  " LANCAMENTOS DE TED".
                     END.
            END.
            

       IF   (aux_nmarquiv MATCHES "*VIP*")  THEN
            DO TRANSACTION:
                FIND FIRST crawarq WHERE 
                           crawarq.tparquiv = SUBSTRING(aux_nmarquiv,
                                                INDEX(aux_nmarquiv,"VIP"),3)
                           NO-LOCK NO-ERROR.
                                                
                IF   NOT AVAILABLE crawarq   THEN
                     DO:
                        CREATE crawarq.
                        ASSIGN crawarq.tparquiv = "VIP"
                               crawarq.dsarquiv = "PROCESSAR TOTAL DA" +
                                                  " FATURA CARTAO CREDITO".
                     END.
            END.
     
               
    END.  /*  Fim do DO WHILE TRUE  */

    INPUT STREAM str_1 CLOSE.

END PROCEDURE.

PROCEDURE carrega_tabela_geracao:

    DEF VAR aux_contador AS INT                                     NO-UNDO.
    
    /* limpa a tabela */
    EMPTY TEMP-TABLE crawarq.
    
    DO aux_contador = 1 TO 9 TRANSACTION:

       CREATE crawarq.
       
       IF   aux_contador = 1        AND
            verifica_horario(400)   THEN
            ASSIGN crawarq.tparquiv = "COO400"
                   crawarq.dsarquiv = "GERAR ARQUIVO DE CADASTRAMENTO".
       ELSE
       IF   aux_contador = 2        AND
            verifica_horario(401)   THEN
            ASSIGN crawarq.tparquiv = "COO401"
                   crawarq.dsarquiv = "GERAR ARQUIVO DE ALTERACAO DE LIMITES".
       ELSE
       IF   aux_contador = 3        AND
            verifica_horario(404)   THEN
            ASSIGN crawarq.tparquiv = "COO404"
                   crawarq.dsarquiv = "GERAR ARQUIVO DE SALDOS DISPONIVEIS".
       ELSE
       IF   aux_contador = 4        AND
            verifica_horario(405)   THEN
            ASSIGN crawarq.tparquiv = "COO405"
                   crawarq.dsarquiv = "GERAR ARQUIVO DE ALTERACOES CADASTRAIS".
       ELSE
       IF   aux_contador = 5        AND
            verifica_horario(406)   THEN
            ASSIGN crawarq.tparquiv = "COO406"
                   crawarq.dsarquiv = "GERAR ARQUIVO DE COMANDOS DE CHEQUES".
       ELSE
       IF   aux_contador = 6        AND
            verifica_horario(407)   THEN
            ASSIGN crawarq.tparquiv = "COO407"
                   crawarq.dsarquiv = "GERAR ARQUIVO DE RETIRADA DE CHEQUES " +
                                      "DA DEVOLUCAO".
       ELSE
       IF   aux_contador = 7        AND
            verifica_horario(408)   THEN
            ASSIGN crawarq.tparquiv = "COO408"
                   crawarq.dsarquiv = "GERAR ARQUIVO DE INCLUSAO/EXCLUSAO NO" +
                                      " CCF".       
       ELSE
       IF   aux_contador = 8        AND
            verifica_horario(409)   THEN
            ASSIGN crawarq.tparquiv = "COO409"
                   crawarq.dsarquiv = "GERAR ARQUIVO DE ENCERRAMENTO CONTA" + 
                                      " INTEGRACAO".
       ELSE
       IF   aux_contador = 9        AND
            verifica_horario(410)   THEN
            ASSIGN crawarq.tparquiv = "COO410"
                   crawarq.dsarquiv = "GERAR ARQUIVO DE MOVIMENTACAO PARA" + 
                                      " CARTAO DE CREDITO".
       
       IF   crawarq.tparquiv = ""   THEN
            DELETE crawarq.
            
    END.   /* fim DO */
   
END PROCEDURE.

PROCEDURE opcao_d:

    /* limpa a tabela */
    EMPTY TEMP-TABLE crawarq.
     
    FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper         AND
                           craptab.nmsistem = "CRED"               AND
                           craptab.tptabela = "GENERI"             AND
                           craptab.cdempres = 00                   AND
                           craptab.cdacesso = "NRARQMVITG"         AND
                           SUBSTRING(craptab.dstextab,7,1) = "1"   NO-LOCK:

        CREATE crawarq.
        ASSIGN crawarq.tparquiv = "COO" + STRING(craptab.tpregist)
               crawarq.dsarquiv = IF craptab.tpregist = 400 THEN
                                     "DESBLOQUEAR TABELA DO" + 
                                     " CADASTRAMENTO"
                                  ELSE
                                  IF craptab.tpregist = 401 THEN
                                     "DESBLOQUEAR TABELA DA ALTERACAO" +
                                     " DE LIMITES"
                                  ELSE
                                  IF craptab.tpregist = 404 THEN
                                     "DESBLOQUEAR TABELA DOS SALDOS" +
                                     " DISPONIVEIS"
                                  ELSE
                                  IF craptab.tpregist = 405 THEN
                                     "DESBLOQUEAR TABELA DAS" + 
                                     " ALTERACOES CADASTRAIS"
                                  ELSE
                                  IF craptab.tpregist = 406 THEN
                                     "DESBLOQUEAR TABELA DOS COMANDOS" +
                                     " DE CHEQUES"
                                  ELSE
                                  IF craptab.tpregist = 407 THEN
                                     "DESBLOQUEAR TABELA DE RETIRADA DE" +
                                     " CHEQUES DA DEVOLUCAO"
                                  ELSE
                                  IF craptab.tpregist = 408 THEN
                                     "DESBLOQUEAR TABELA DA" +
                                     " INCLUSAO/EXCLUSAO NO CCF"
                                  ELSE 
                                  IF craptab.tpregist = 409 THEN
                                     "DESBLOQUEAR TABELA DE" +
                                     " EXCLUSAO CONTA INTEGRACAO"
                                  ELSE
                                  IF craptab.tpregist = 410 THEN
                                     "DESBLOQUEAR TABELA DA" +
                                     " MOVIMENTACAO PARA CARTAO DE" +
                                     " CREDITO"
                                  ELSE 
                                     "".      
    END.

    OPEN QUERY q_desbloques FOR EACH crawarq BY crawarq.tparquiv.
    
    UPDATE b_desbloques WITH FRAME f_desbloque.
    
END PROCEDURE.

PROCEDURE executa:

    /* Limpa as solicitacoes */
    DO TRANSACTION:
       FIND FIRST crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                crapsol.nrsolici = 99             AND
                                crapsol.dtrefere = glb_dtmvtolt   
                                NO-LOCK NO-ERROR.
                                
       IF   AVAILABLE crapsol   THEN
            DO:
                FIND CURRENT crapsol EXCLUSIVE-LOCK.
                
                DELETE crapsol.
            END.
    END.
    
    DO TRANSACTION:
       FIND FIRST crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                crapsol.nrsolici = 100            AND
                                crapsol.dtrefere = glb_dtmvtolt   
                                NO-LOCK NO-ERROR.
                                
       IF   AVAILABLE crapsol   THEN
            DO:
                FIND CURRENT crapsol EXCLUSIVE-LOCK.
                
                DELETE crapsol.
            END.
    END.


    DO TRANSACTION:
   
       /* cria a solicitacao --> 99 para GERACAO de arquivos/relatorio */
       CREATE crapsol. 
       ASSIGN crapsol.nrsolici = 99
              crapsol.dtrefere = glb_dtmvtolt
              crapsol.nrseqsol = 1
              crapsol.cdempres = 11
              crapsol.dsparame = ""
              crapsol.insitsol = 1
              crapsol.nrdevias = 0
              crapsol.cdcooper = glb_cdcooper.
       VALIDATE crapsol.
          
       /* cria a solicitacao --> 100 se for P - PROCESSAMENTO */
       IF   glb_cddopcao = "P"   THEN
            DO:
               CREATE crapsol. 
               ASSIGN crapsol.nrsolici = 100
                      crapsol.dtrefere = glb_dtmvtolt
                      crapsol.nrseqsol = 1
                      crapsol.cdempres = 11
                      crapsol.dsparame = ""
                      crapsol.insitsol = 1
                      crapsol.nrdevias = 0
                      crapsol.cdcooper = glb_cdcooper.
               VALIDATE crapsol.
            END.
    END. /* Fim TRANSACTION */
                
    aux_flrel510 = FALSE.                         
    FOR EACH crawarq BY crawarq.tparquiv:
        
        PUT SCREEN COLOR MESSAGE ROW 22
            "Aguarde... Gerando/Processando Arquivos (" + crawarq.tparquiv +
            ")...".
            
        CASE crawarq.tparquiv:
             /* programas de geracao */
             WHEN "COO400" THEN  RUN fontes/crps407.p.
             WHEN "COO401" THEN  RUN fontes/crps419.p. 
             WHEN "COO404" THEN  RUN fontes/crps409.p.
             WHEN "COO405" THEN  RUN fontes/crps410.p.
             WHEN "COO406" THEN  RUN fontes/crps443.p.
                
             /***ESTE ARQUIVO SO DEVE SER GERADO
             WHEN "COO407" THEN  RUN fontes/crps424.p. 
             ****ATRAVES DA TELA DEVOLU *******/                            
             
             WHEN "COO408" THEN  RUN fontes/crps447.p.
             WHEN "COO409" THEN  RUN fontes/crps503.p.
             WHEN "COO410" THEN  RUN fontes/crps422.p.

             /* programas de retornos */
             WHEN "COO500" THEN  RUN fontes/crps426.p.
             WHEN "COO501" THEN  RUN fontes/crps421.p. 
             WHEN "COO504" THEN  RUN fontes/crps438.p. 
             WHEN "COO505" THEN  RUN fontes/crps411.p.
             WHEN "COO506" THEN  RUN fontes/crps420.p.
             WHEN "COO507" THEN  RUN fontes/crps446.p.
             WHEN "COO508" THEN  RUN fontes/crps448.p.
             WHEN "COO509" THEN  RUN fontes/crps504.p.
             WHEN "COO510" THEN  DO: 
                                    RUN fontes/crps423.p. 
                                    aux_flrel510 = TRUE.    
                                 END.    
             WHEN "COO552" THEN  RUN fontes/crps454.p.
             WHEN "COO553" THEN  RUN fontes/crps527.p.
             
             WHEN "DEB668" THEN  RUN fontes/crps456.p.

             WHEN "VIP"    THEN  RUN fontes/crps606.p.
             
        END CASE.
    END.

    /* gera o relatorio */
    RUN fontes/crps428.p(INPUT aux_flrel510).
    
    /* Limpa as solicitacoes */
    DO TRANSACTION:
       FIND FIRST crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                crapsol.nrsolici = 99             AND
                                crapsol.dtrefere = glb_dtmvtolt   
                                NO-LOCK NO-ERROR.
                                
       IF   AVAILABLE crapsol   THEN
            DO:
                FIND CURRENT crapsol EXCLUSIVE-LOCK.
                
                DELETE crapsol.
            END.
    END.
    
    DO TRANSACTION:
       FIND FIRST crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                crapsol.nrsolici = 100            AND
                                crapsol.dtrefere = glb_dtmvtolt   
                                NO-LOCK NO-ERROR.
                                
       IF   AVAILABLE crapsol   THEN
            DO:
                FIND CURRENT crapsol EXCLUSIVE-LOCK.
                
                DELETE crapsol.
            END.
    END.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       MESSAGE "ATENCAO! Verifique a GERIMP!".
       PAUSE(5) NO-MESSAGE.    
       HIDE MESSAGE NO-PAUSE.
       LEAVE.
    END.

END PROCEDURE.  

PROCEDURE opcao_l:

    DEF VAR aux_nmarqimp AS CHAR    FORMAT "x(40)"                NO-UNDO.

    /* variaveis para impressao */
    DEF VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
    DEF VAR par_flgrodar AS LOGICAL INIT TRUE                     NO-UNDO.
    DEF VAR aux_flgescra AS LOGICAL                               NO-UNDO.
    DEF VAR aux_dscomand AS CHAR                                  NO-UNDO.
    DEF VAR par_flgfirst AS LOGICAL INIT TRUE                     NO-UNDO.
    DEF VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
    DEF VAR tel_dsimprim AS CHAR FORMAT "x(8)" INIT "Imprimir"    NO-UNDO.
    DEF VAR tel_dscancel AS CHAR FORMAT "x(8)" INIT "Cancelar"    NO-UNDO.
    DEF VAR par_flgcance AS LOGICAL                               NO-UNDO.

    ASSIGN tel_datadlog = glb_dtmvtolt.
    
    UPDATE tel_datadlog WITH FRAME f_prcitg.
    
    ASSIGN aux_nmarqimp = "log/prcitg_" + STRING(YEAR(tel_datadlog),"9999") + 
                          STRING(MONTH(tel_datadlog),"99") + 
                          STRING(DAY(tel_datadlog),"99") + ".log".
                          
    IF   SEARCH(aux_nmarqimp) = ?   THEN
         DO:
             MESSAGE "!!NAO EXISTEM PENDENCIAS ATE O MOMENTO!!".
             PAUSE 2 NO-MESSAGE.
             RETURN.
         END.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
       MESSAGE "(T)erminal ou (I)mpressora: " UPDATE tel_cddopcao.
    
       IF   tel_cddopcao = "T"   THEN
            RUN fontes/visrel.p (INPUT aux_nmarqimp).
       ELSE
       IF   tel_cddopcao = "I"   THEN
            DO:
                /* somente para o includes/impressao.i */
                FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                         NO-LOCK NO-ERROR.
                
                { includes/impressao.i }
            END.
       ELSE
            DO: 
               glb_cdcritic = 14.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               NEXT.
            END.
       
       LEAVE.
    END.

END PROCEDURE.

PROCEDURE opcao_r:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       ASSIGN aux_confirma = "N"
              glb_cdcritic = 78.

       RUN fontes/critic.p.
       BELL.
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
             RETURN.
         END.

    DO TRANSACTION:

       /* cria a solicitacao 99 para gerar o relatorio */ 
       CREATE crapsol. 
       ASSIGN crapsol.nrsolici = 99
              crapsol.dtrefere = glb_dtmvtolt
              crapsol.nrseqsol = 1
              crapsol.cdempres = 11
              crapsol.dsparame = ""
              crapsol.insitsol = 1
              crapsol.nrdevias = 0
              crapsol.cdcooper = glb_cdcooper.
       VALIDATE crapsol.
    END.
    
    MESSAGE "Aguarde... Gerando Relatorio...".
    
    aux_flrel510 = FALSE.
    RUN fontes/crps428.p(INPUT aux_flrel510).
    
    /* Limpa as solicitacoes */
    DO TRANSACTION:
       FIND FIRST crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND 
                                crapsol.nrsolici = 99             AND
                                crapsol.dtrefere = glb_dtmvtolt   
                                NO-LOCK NO-ERROR.
                                
       IF   AVAILABLE crapsol   THEN
            DO:
                FIND CURRENT crapsol EXCLUSIVE-LOCK.
                
                DELETE crapsol.
            END.
    END.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       MESSAGE "Verifique o relatorio 396 na tela IMPREL!".
       PAUSE(3) NO-MESSAGE.
       HIDE MESSAGE NO-PAUSE.
       LEAVE.
    END.
    
END PROCEDURE.

  
/* .......................................................................... */

