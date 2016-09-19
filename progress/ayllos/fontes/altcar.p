/* .............................................................................

Programa: Fontes/altcar.p
Sistema : Conta-Corrente - Cooperativa de Credito
Sigla   : CRED
Autor   : André Santos - Supero
Data    : JULHO/2011                         Ultima Atualizacao: 28/10/2011


Dados referentes ao programa:

Frequencia: Diario (on-line)
Objetivo  : ALterar registros importados do cartao de credito.

Alteracoes: 19/10/2011 - Acerto na geração do log (Irlan)

            28/10/2011 - Criado a opcao "F7" para buscar e listar o nome
                         dos arquivos (Adriano).
                         

............................................................................. */

{ includes/var_online.i } 
{ sistema/generico/includes/b1wgen0059tt.i }


DEF        BUTTON btn-salvar LABEL "Salvar".
DEF        BUTTON btn-detalh LABEL "Detalhe".
DEF        BUTTON btn-voltar LABEL "Voltar".

DEF        VAR tel_cdadmcrd AS INTE    FORMAT "99"                 NO-UNDO.
DEF        VAR tel_cdtabela AS INTE    FORMAT "99"                 NO-UNDO.
DEF        VAR tel_qtparcan AS INTE    FORMAT "99"                 NO-UNDO.
DEF        VAR tel_vlanuida AS DECI    FORMAT "999999.99"          NO-UNDO.
DEF        VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"         NO-UNDO.
DEF        VAR tel_dtvencto AS CHAR                                NO-UNDO.
DEF        VAR tel_nmarquiv AS CHAR                                NO-UNDO.
DEF        VAR tel_dscritic AS CHAR                                NO-UNDO.
DEF        VAR aux_cdacesso AS CHAR                                NO-UNDO.
DEF        VAR aux_dsacesso AS CHAR    FORMAT "x(50)"              NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                 NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                NO-UNDO.    
DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)" INIT "N"      NO-UNDO.
DEF        VAR aux_dtvctini AS DATE                                NO-UNDO. 
DEF        VAR aux_dtvctfim AS DATE                                NO-UNDO. 
DEF        VAR tel_cdcooper LIKE  crapecv.cdcooper                 NO-UNDO.
DEF        VAR tel_nrcrcard LIKE  crapecv.nrcrcard                 NO-UNDO.
DEF        VAR tel_nrdconta LIKE  crapecv.nrdconta                 NO-UNDO.
DEF        VAR tel_cdcritic LIKE  crapecv.cdcritic                 NO-UNDO.
                                                                 
DEF        VAR aux_coopant  LIKE  crapecv.cdcooper                 NO-UNDO.
DEF        VAR aux_cartant  LIKE  crapecv.nrcrcard                 NO-UNDO.
DEF        VAR aux_contant  LIKE  crapecv.nrdconta                 NO-UNDO.
DEF        VAR aux_critant  LIKE  crapecv.cdcritic                 NO-UNDO.

DEF        VAR tel_flgajus  AS LOGI INIT TRUE FORMAT "SIM/NAO"     NO-UNDO.

DEF        VAR h-b1wgen0014 AS HANDLE                              NO-UNDO.
DEF        VAR h-b1wgen0059 AS HANDLE                              NO-UNDO.
DEF        VAR aux_nrdrowid AS ROWID                               NO-UNDO.
DEF        VAR aux_dsaltera AS CHAR                                NO-UNDO.

DEF        BUFFER b2crapecv    FOR crapecv.

DEF        BUFFER bcrapecv     FOR crapecv.

DEF        QUERY qry_extrato   FOR bcrapecv.
DEF        QUERY q_crapecv     FOR tt-crapecv.

DEF        BROWSE brw_extrato  QUERY qry_extrato     
    DISP bcrapecv.cdcooper     COLUMN-LABEL "Coop"            FORMAT "zz9"
         bcrapecv.nrcrcard     COLUMN-LABEL "Cartao"          FORMAT "9999,9999,9999,9999"   
         bcrapecv.nrdconta     COLUMN-LABEL "Conta/dv"        FORMAT "zzzz,zzz,9"
         bcrapecv.nmtitcrd     COLUMN-LABEL "Portador"        FORMAT "x(20)"
         bcrapecv.indebcre     COLUMN-LABEL "D/C"             FORMAT "x(1)"
         bcrapecv.vlcparea     COLUMN-LABEL "Valor(R$)"       FORMAT "zzz,zz9.99"
         bcrapecv.cdcritic     COLUMN-LABEL "Crit"            FORMAT "zz9"
WITH 7 DOWN WIDTH 78 NO-BOX SCROLLBAR-VERTICAL.
                          
DEF        BROWSE b_crapecv QUERY q_crapecv
    DISP  tt-crapecv.nmarqimp COLUMN-LABEL "Arquivo" FORMAT "x(25)"
WITH 8 DOWN OVERLAY.

FORM b_crapecv HELP "Use as SETAS para navegar ou F4 para sair"
     SKIP
     WITH NO-BOX ROW 8 COLUMN 5 OVERLAY CENTERED FRAME f_crapecv. 

FORM SKIP(1) 
    "Opcao:"                                                                         AT 4
    glb_cddopcao AT 11 NO-LABEL AUTO-RETURN
          HELP "Informe a opcao desejada( A )"
          VALIDATE (glb_cddopcao = "A", "014 - Opcao errada.")
    tel_dtvencto       LABEL "Vencimento"                     FORMAT "99/9999"       AT 19  
          HELP "Informe o periodo de vencimento."
    tel_nmarquiv       LABEL "Arquivo"                        FORMAT "x(25)"         AT 40 
          HELP "Informe o nome do arquivo ou <F7> para listar."
 WITH SIDE-LABELS
 TITLE glb_tldatela
 ROW 4 COLUMN 1 OVERLAY SIZE 80 BY 18 FRAME f_opcao029.
    
FORM SKIP(1)
    tel_cdcooper        LABEL "Cooperativa"                   FORMAT "zz9"           AT 7               
          HELP "Informe o codigo da administradora de cartoes."  
    SKIP
    tel_nrcrcard        LABEL "Nr Cartao"                                            AT 9              
          HELP "Informe o codigo da administradora de cartoes."  
    SKIP
    tel_nrdconta        LABEL "Nr Conta"                      FORMAT "zzzz,zzz,9"    AT 10              
          HELP "Informe o codigo da administradora de cartoes."  
    SKIP
    crapecv.nmtitcrd    LABEL "Nome do Portador"              FORMAT "x(30)"         AT 2
    SKIP
    crapecv.indebcre    LABEL "D/C"                                                  AT 15
    SKIP
    crapecv.vlcparea    LABEL "Vlr R$"                        FORMAT "zzz,zz9.99"    AT 12
    SKIP
    tel_cdcritic        LABEL "Critica"                       FORMAT "zz9"           AT 11
          HELP "Informe o codigo da administradora de cartoes."
    tel_dscritic     NO-LABEL                                 FORMAT "x(30)"         AT 25
    SKIP
    tel_flgajus        LABEL "Replicar Ajustes?"
    SKIP
WITH SIDE-LABELS ROW 9 COLUMN 2 OVERLAY WIDTH 56 CENTERED TITLE " ALTERACAO" FRAME f_alteracao.
    
FORM SKIP(2) 
    crapecv.dtvencto    LABEL "Dt. Vencto"                                           AT 10  
    crapecv.dtcompra    LABEL "Dt. Compra"                                           AT 44
    SKIP                                                                      
    crapecv.dsestabe    LABEL "Estabelecimento"               FORMAT "x(45)"         AT 5 
    SKIP                                                                      
    crapecv.dsatvcom    LABEL "Atividade Comercial"           FORMAT "x(30)"         AT 1
    SKIP                                                                      
    crapecv.tpatvcom    LABEL "Tp Ativ Comercial"             FORMAT "9"             AT 3
    crapecv.cdmoedtr    LABEL "Moeda"                         FORMAT "x(3)"          AT 49
    SKIP                                                                      
    crapecv.vlcpaori    LABEL "Vlr Moeda Orig."               FORMAT "zzz,zz9.99"    AT 5
    crapecv.vlcparea    LABEL "Vlr R$"                        FORMAT "zzz,zz9.99"    AT 48    
    SKIP                                                                      
    crapecv.nmcidade    LABEL "Cidade"                        FORMAT "x(15)"         AT 14
    crapecv.cdufende    LABEL "UF"                            FORMAT "x(2)"          AT 52
    SKIP                                                                      
    crapecv.nmarqimp    LABEL "Nm Arquivo"                    FORMAT "x(21)"         AT 10
    crapecv.idseqinc    LABEL "Sequencia"                     FORMAT "zzzzz9"        AT 45
    SKIP                                                                      
    crapecv.cdoperad    LABEL "Operador"                      FORMAT "x(10)"         AT 12
    crapecv.cdtransa    LABEL "Transacao"                     FORMAT "x(4)"          AT 45
    SKIP                                                                  
    crapecv.dtmvtolt    LABEL "Data Transacao"                                       AT 6 
    SKIP(1)                                                                 
    btn-voltar                                                                       AT 30
WITH ROW 6 COLUMN 2 OVERLAY 1 DOWN WIDTH 76 CENTERED
SIDE-LABELS TITLE " DETALHES " FRAME f_detalhe.

DEF FRAME f_brwextrato
  brw_extrato SKIP (1)
  btn-detalh                                                                         AT 35 
      HELP "Tecle <Entra> ou <Fim> para voltar"
WITH NO-BOX CENTERED OVERLAY ROW 9.


ON "RETURN" OF b_crapecv DO:
   IF NOT AVAIL tt-crapecv THEN
      DO:
         HIDE FRAME f_crapecv.
         APPLY "END-ERROR".
      END.
   ELSE
      DO:
         tel_nmarquiv = tt-crapecv.nmarqimp.
              
         DISPLAY tel_nmarquiv WITH FRAME f_opcao029.
              
         APPLY "GO".

      END.


END.


ON ENTRY, VALUE-CHANGED OF brw_extrato DO:
    IF   glb_cddopcao = "A" THEN
         MESSAGE "Pressione <ENTER> para alterar o registro!".
    END.

ON ENTER OF brw_extrato IN FRAME f_brwextrato DO:

    HIDE FRAME f_detalhe.
    
    FIND FIRST crapecv
         WHERE ROWID(crapecv) = ROWID(bcrapecv) 
         EXCLUSIVE-LOCK NO-ERROR.

    IF NOT AVAIL crapecv THEN RETURN.    

    ASSIGN tel_cdcooper = crapecv.cdcooper
           tel_nrcrcard = crapecv.nrcrcard
           tel_nrdconta = crapecv.nrdconta
           tel_cdcritic = crapecv.cdcritic.

    FIND FIRST crapcri WHERE
               crapcri.cdcritic = tel_cdcritic NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcri THEN
       tel_dscritic = "Critica Nao Encontrada".
    ELSE
        IF tel_cdcritic = 0 THEN
           tel_dscritic = "" .
        ELSE
           tel_dscritic = SUBSTR(crapcri.dscritic,7).
          
        DISP tel_cdcooper
             tel_nrcrcard
             tel_nrdconta
             tel_cdcritic
             tel_dscritic
             tel_flgajus
             crapecv.nmtitcrd 
             crapecv.indebcre 
             crapecv.vlcparea WITH FRAME f_alteracao.
                     
        ASSIGN aux_coopant = tel_cdcooper
               aux_cartant = tel_nrcrcard
               aux_contant = tel_nrdconta
               aux_critant = tel_cdcritic.

    DO WHILE TRUE:
    
        UPDATE tel_cdcooper WITH FRAME f_alteracao.
    
        IF NOT CAN-FIND (crapcop NO-LOCK WHERE crapcop.cdcooper = tel_cdcooper) THEN
           DO:
              MESSAGE "Cooperativa Invalida".
              NEXT.
           END.
        
        UPDATE tel_nrcrcard 
               tel_nrdconta
               tel_cdcritic 
               tel_flgajus WITH FRAME f_alteracao.
        
        IF NOT CAN-FIND (crapcrd NO-LOCK WHERE 
                           crapcrd.cdcooper = tel_cdcooper AND 
                           crapcrd.nrcrcard = tel_nrcrcard AND 
                           crapcrd.cdadmcrd = 3) THEN
           DO:
              MESSAGE "Numero Do Cartao Invalido".
              NEXT.
           END.
             
        IF NOT CAN-FIND (crapcrd NO-LOCK WHERE
                         crapcrd.cdcooper = tel_cdcooper AND 
                         crapcrd.nrcrcard = tel_nrcrcard AND 
                         crapcrd.nrdconta = tel_nrdconta AND 
                         crapcrd.cdadmcrd = 3) THEN
           DO:
              MESSAGE "Numero Da Conta Invalida".
              NEXT.
           END.
        
        FIND FIRST  crapcri WHERE
             crapcri.cdcritic = tel_cdcritic NO-LOCK NO-ERROR.
        
        IF NOT AVAIL crapcri THEN
           tel_dscritic = "Critica Nao Encontrada".
        ELSE
        IF tel_cdcritic = 0 THEN
           tel_dscritic = "" .
        ELSE
           tel_dscritic = SUBSTR(crapcri.dscritic,7).
            
        DISP tel_dscritic WITH FRAME f_alteracao.
         
        aux_dsaltera = "Alteracao do campo".

        IF aux_coopant <> tel_cdcooper OR
           aux_cartant <> tel_nrcrcard OR 
           aux_contant <> tel_nrdconta OR 
           aux_critant <> tel_cdcritic THEN 
        DO:
    
            IF tel_cdcritic <> aux_critant AND
               tel_cdcritic <> 0 THEN
                 MESSAGE "Voce alterou o registro. Critica deve ser 0!"
                 VIEW-AS ALERT-BOX INFO BUTTONS OK.
            ELSE 
            DO:
               IF  tel_cdcritic = 0 THEN 
               DO:
                   
                   IF  aux_coopant <> tel_cdcooper THEN 
                       aux_dsaltera = aux_dsaltera + " cdcooper ".
                 
                   IF aux_cartant <> tel_nrcrcard THEN
                      aux_dsaltera = aux_dsaltera + " nrcrcard ".
                 
                   IF aux_contant <> tel_nrdconta THEN 
                      aux_dsaltera = aux_dsaltera + " nrdconta ".

                   IF tel_cdcritic = 0 THEN
                      aux_dsaltera = aux_dsaltera + " cdcritic ".
    
                   IF tel_flgajus = TRUE THEN 
                      RUN pi_ajusta_em_lote. 
                   ELSE DO:
                       FIND FIRST crapcrd WHERE
                                  crapcrd.cdcooper = tel_cdcooper AND
                                  crapcrd.nrdconta = tel_nrdconta AND
                                  crapcrd.nrcrcard = tel_nrcrcard 
                                  NO-LOCK NO-ERROR.
                       IF  NOT AVAIL crapcrd THEN
                           crapecv.nmtitcrd = "Cooperado nao encontrado".
                       ELSE
                           crapecv.nmtitcrd = crapcrd.nmtitcrd.
                   
                       ASSIGN crapecv.cdcooper = tel_cdcooper 
                              crapecv.nrcrcard = tel_nrcrcard 
                              crapecv.nrdconta = tel_nrdconta 
                              crapecv.cdcritic = tel_cdcritic.
                   END.
                   
                   RUN gera_log(INPUT aux_dsaltera,
                                INPUT TRUE). 
    
                   MESSAGE "Registro Alterado Com Sucesso.."
                      VIEW-AS ALERT-BOX INFO BUTTONS OK.

                    HIDE MESSAGE.
                    HIDE FRAME f_alteracao.

                    LEAVE.

               END.
               ELSE
                 MESSAGE "Voce alterou o registro. Critica deve ser 0!"
                 VIEW-AS ALERT-BOX INFO BUTTONS OK.

            END.
        END.
        ELSE 
        DO: 
            MESSAGE "Nada foi alterado! Alteracao cancelada"
            VIEW-AS ALERT-BOX INFO BUTTONS OK.
            LEAVE.
        END.
    END.

    HIDE MESSAGE.
    HIDE FRAME f_alteracao.
    RUN p_carregabrowse.
    
END.

ON RETURN OF brw_extrato IN FRAME f_brwextrato DO:
    HIDE FRAME f_alteracao.
    HIDE FRAME f_detalhe.
END.
    
ON CHOOSE OF btn-voltar IN FRAME f_detalhe DO:
    HIDE FRAME f_detalhe.
END.

ON CHOOSE OF btn-detalh IN FRAME f_brwextrato DO:
    
    FIND FIRST crapecv
      WHERE ROWID (crapecv) = ROWID (bcrapecv) 
      EXCLUSIVE-LOCK NO-ERROR.

    IF NOT AVAIL crapecv THEN RETURN.
    
    DISP crapecv.cdmoedtr 
         crapecv.cdoperad 
         crapecv.cdtransa 
         crapecv.cdufende 
         crapecv.dsatvcom 
         crapecv.dsestabe 
         crapecv.dtcompra 
         crapecv.dtmvtolt 
         crapecv.dtvencto 
         crapecv.idseqinc 
         crapecv.nmarqimp 
         crapecv.nmcidade 
         crapecv.vlcpaori 
         crapecv.tpatvcom 
         crapecv.vlcparea
         WITH FRAME f_detalhe.
    
    ENABLE btn-voltar WITH FRAME f_detalhe.
    
    APPLY "ENTRY" TO btn-voltar IN FRAME f_detalhe.
    
    RETURN.
    
END.

glb_cddopcao = "A".

DO WHILE TRUE:

    RUN fontes/inicia.p.

    DISPLAY glb_cddopcao WITH FRAME f_opcao029.

    HIDE FRAME f_detalhe.
    HIDE FRAME f_alteracao.
    HIDE FRAME f_brwextrato.

    /* Realiza somente ALTERACOES */
    ASSIGN  glb_cddopcao = "A".

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       PROMPT-FOR glb_cddopcao WITH FRAME f_opcao029.
       LEAVE.
    END.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
         DO:
             RUN fontes/novatela.p.
             IF   CAPS(glb_nmdatela) <> "ALTCAR"   THEN
                  DO:
                      HIDE FRAME f_opcao029.
                      RETURN.
                  END.
             ELSE
                  NEXT.
         END.

    IF   aux_cddopcao <> INPUT glb_cddopcao THEN
         DO:
             { includes/acesso.i }
             aux_cddopcao = INPUT glb_cddopcao.
         END.

    IF INPUT glb_cddopcao = "A" THEN
       DO:
          UPDATE tel_dtvencto
                 WITH FRAME f_opcao029.

          UPDATE tel_nmarquiv 
                 WITH FRAME f_opcao029
          
          EDITING:
          
             READKEY.
          
             IF LAST-KEY = KEYCODE("F7") THEN
                DO:
                   RUN sistema/generico/procedures/b1wgen0059.p
                              PERSISTENT SET h-b1wgen0059.
               
                   IF VALID-HANDLE(h-b1wgen0059)  THEN
                      DO:
                         RUN busca-crapecv IN h-b1wgen0059 
                                              (INPUT tel_dtvencto,
                                               OUTPUT TABLE tt-crapecv).
          
                         FIND FIRST tt-crapecv NO-LOCK NO-ERROR.

                         IF NOT AVAIL tt-crapecv THEN
                            MESSAGE "Nenhum arquivo encontrado.".
                         
                         OPEN QUERY q_crapecv FOR EACH tt-crapecv NO-LOCK.
                         
                         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            UPDATE b_crapecv WITH FRAME f_crapecv.
                            LEAVE.
                         
                         END.
                         
                         IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                            HIDE FRAME f_crapecv.

                         CLOSE QUERY q_crapecv.

                      END.
                  
                   DELETE PROCEDURE h-b1wgen0059.
             
                END.
             ELSE
               APPLY LAST-KEY.

          END.

          IF NOT (tel_nmarquiv MATCHES("*original*")) THEN
             ASSIGN tel_nmarquiv = tel_nmarquiv + ".original". 
          
          IF INTE(SUBSTR(tel_dtvencto,01,02)) > 12 OR
             INTE(SUBSTR(tel_dtvencto,01,02)) = 0  OR
             INTE(SUBSTR(tel_dtvencto,03,04)) > YEAR(glb_dtmvtolt) THEN
             MESSAGE "Periodo informado invalido".
              
          ELSE DO:
                ASSIGN aux_dtvctini = DATE(INTE(SUBSTR(tel_dtvencto,1,2)),
                                                1,
                                      INTE(SUBSTR(tel_dtvencto,3,4))).
                ASSIGN aux_dtvctfim = IF (INTE(SUBSTR(tel_dtvencto,1,2)) + 1) 
                                              = 13 THEN
                                 DATE(12,31,INTE(SUBSTR(tel_dtvencto,3,4)))
                             ELSE
                                 DATE (INTE(SUBSTR(tel_dtvencto,1,2)) + 1,
                                                1,
                                       INTE(SUBSTR(tel_dtvencto,3,4))) - 1.
                                  
                FIND FIRST bcrapecv
                     WHERE bcrapecv.dtvencto >= aux_dtvctini   
                       AND bcrapecv.dtvencto <= aux_dtvctfim NO-LOCK NO-ERROR. 
                
               
                IF NOT AVAIL bcrapecv THEN DO:
                     MESSAGE "Periodo nao encontrado".
                    NEXT. 
                END.
                
               
                FIND FIRST bcrapecv 
                    WHERE bcrapecv.nmarqimp = tel_nmarquiv NO-LOCK NO-ERROR. 
                
          
                IF NOT AVAIL bcrapecv THEN DO:
                     MESSAGE "Arquivo nao localizado" .
                    NEXT.
                END.
               
                FIND FIRST bcrapecv
                     WHERE bcrapecv.dtvencto >= aux_dtvctini 
                       AND bcrapecv.dtvencto <= aux_dtvctfim  
                       AND bcrapecv.nmarqimp =  tel_nmarquiv 
                       AND bcrapecv.cdcritic <> 0 NO-LOCK NO-ERROR.
              
               
                IF NOT AVAIL bcrapecv THEN DO :
                   MESSAGE "CRITICAS JA REGULARIZADAS".
                   NEXT.
                END.
               
                RUN p_carregabrowse.
                SET brw_extrato WITH FRAME f_brwextrato.
                ENABLE btn-detalh 
                       WITH FRAME f_brwextrato.
          END.
       
       END.
       

END. /* Fim do DO WHILE TRUE */

PROCEDURE p_carregabrowse:

    DEF   VAR    aux_nmadmcrd         LIKE crapadc.nmresadm     NO-UNDO.

    OPEN QUERY qry_extrato FOR EACH bcrapecv NO-LOCK WHERE
               bcrapecv.dtvencto >= aux_dtvctini
           AND bcrapecv.dtvencto <= aux_dtvctfim
           AND bcrapecv.nmarqimp =  tel_nmarquiv
           AND bcrapecv.cdcritic <> 0 
            BY bcrapecv.cdcooper
            BY bcrapecv.nrdconta 
            BY bcrapecv.nrcrcard.

    HIDE FRAME f_brwextrato.
    ENABLE brw_extrato 
           btn-detalh WITH FRAME f_brwextrato.

    IF NUM-RESULTS("qry_extrato") = 0 THEN
         MESSAGE "NAO HA REGISTROS PARA AJUSTE".

END.

PROCEDURE gera_log:
    
    DEF INPUT PARAM par_dstransa LIKE craplgm.dstransa              NO-UNDO.
    DEF INPUT PARAM par_flgtrans LIKE craplgm.flgtrans              NO-UNDO.
    
    RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT 
    SET h-b1wgen0014.
    
    IF  VALID-HANDLE(h-b1wgen0014)  THEN
        DO:
            RUN gera_log IN h-b1wgen0014 (INPUT crapecv.cdcooper,
                                          INPUT glb_cdoperad,
                                          INPUT "",
                                          INPUT "AYLLOS",
                                          INPUT par_dstransa,
                                          INPUT glb_dtmvtolt,
                                          INPUT par_flgtrans,
                                          INPUT TIME,
                                          INPUT 1,
                                          INPUT glb_cdprogra,
                                          INPUT crapecv.nrdconta,
                                          OUTPUT aux_nrdrowid).
                                        
            DELETE PROCEDURE h-b1wgen0014.
        END.
    
    
END PROCEDURE.

/*** FIM PROCEDURE p_carregabrowse ***/

PROCEDURE pi_ajusta_em_lote:

   FOR EACH b2crapecv 
      WHERE b2crapecv.cdcooper = bcrapecv.cdcooper
        AND b2crapecv.nrdconta = bcrapecv.nrdconta
        AND b2crapecv.nrcrcard = bcrapecv.nrcrcard
        AND b2crapecv.cdcritic = bcrapecv.cdcritic
        AND b2crapecv.dtvencto = bcrapecv.dtvencto
        AND b2crapecv.nmarqimp = bcrapecv.nmarqimp EXCLUSIVE-LOCK:

        ASSIGN b2crapecv.cdcooper = tel_cdcooper
               b2crapecv.nrcrcard = tel_nrcrcard
               b2crapecv.nrdconta = tel_nrdconta
               b2crapecv.cdcritic = tel_cdcritic.
          
        FIND FIRST crapcrd WHERE
                   crapcrd.cdcooper = tel_cdcooper AND
                   crapcrd.nrdconta = tel_nrdconta AND
                   crapcrd.nrcrcard = tel_nrcrcard 
                 NO-LOCK NO-ERROR.
                                    
        IF  NOT AVAIL crapcrd THEN
            b2crapecv.nmtitcrd = "Cooperado nao encontrado".
        ELSE
            b2crapecv.nmtitcrd = crapcrd.nmtitcrd.
    END.
   ASSIGN aux_dsaltera = "Alter. em lote: " + STRING(bcrapecv.cdcooper)  + "/"
                                            + STRING(bcrapecv.nrdconta)  + "/"
                                            + STRING(bcrapecv.nrcrcard)  + "/"
                                            + STRING(bcrapecv.cdcritic)  + "/"
                                            + STRING(bcrapecv.dtvencto)  + "/"
                                            + STRING(bcrapecv.nmarqimp).

END PROCEDURE.


/* .......................................................................... */

