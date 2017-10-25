/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0120.p
    Autor   : Gabriel Capoia dos Santos (DB1)
    Data    : Outubro/2011                     Ultima atualizacao: 15/08/2017

    Objetivo  : Tranformacao BO tela BCAIXA

    Alteracoes: 19/12/2011 - incluido tratamento para a instancia 
                             h-b1wgen9999 pois estava ficando presa (Tiago).
                             
                22/12/2011 - Incluir listagem de Saques na Gera Deposito ,
                             tratar historico 1030 (Gabriel).             
                             
                27/01/2012 - correções bcaixa (Tiago).             
                
                27/02/2012 - Alteracao para que todas as coops possam 
                             digitalizar cheques da propria cooperativa (ZE).
                             
                08/03/2012 - Alterado a composicao da autenticacao
                             (cratfit.dslitera) para autenticacoes com data
                             >= 25/04/2012, na procedure Gera_Fita_Caixa.
                             (Fabricio)
                             
                15/06/2012 - Incluido variavel aux_dslitera (David Kruger).
                
                06/08/2012 - Tratamento cdhistor = 21 fita caixa (Guilherme).
                
                05/09/2012 - Desfeito alteracao aux_dslitera (Tiago).
                
                22/01/2013 - Alteração para aceitar PAC = 0 (Daniele).
                
                09/04/2013 - Incluir parametro par_tpcaicof na busca_dados
                           - Incluir procedure imprime_caixa_cofre para 
                             imprimir dados de caiixa e cofre (Lucas R.)
                
                03/06/2013 - Ajustes para arrecadacadao de DARF's (Elton).
                
                13/08/2013 - Nova forma de chamar as agências, alterado para
                         "Posto de Atendimento" (PA). (André Santos - SUPERO)
                         
                28/08/2013 - Alteracao da procedure Busca_Dados e SaldoCaixas 
                             para filtrar por dtmvtolt (inclusao do param
                             dtrefere) (Carlos)
                
                03/09/2013 - Nova forma de chamar as agências, de PAC agora 
                             a escrita será PA (André Euzébio - Supero).
                             
                10/10/2013 - Verificar situacao do PA antes de criar o
                             Caixa (Ze).
                             
                12/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
                
                06/01/2014 - Criticas de busca de crapage alteradas de 15 para
                             962 (Carlos)
                             
                18/09/2014 - Ajuste da mensagem de Identificação de envelope,
                             pois nao tinha como diferenciar os depositos
                             de envelope (Diego)
                                       
                12/03/2015 - Incluir procedures SaldoCaixas, SaldoCofre e 
                             SaldoTotal chamando a rotina convertida do Oracle
                             (Lucas R. #245838))
                
                26/03/2015 - Ajuste no saldo da opcao C da tela BCAIXA
                             (Chamado 260095) (Jonata-RKAM).
                
                25/05/2015 - Incluida gravacao de autenticacao na opcao L 
                             da tela BCAIXA, para que fique equivalente ao 
                             processo efetuado no Caixa Online (Rotina 11)
                             Incluídas validações existentes na rotina 11
                             do Caixa Online referente aos históricos 1152
                             e 1153. (Chamado 270784) (Heitor-RKAM).

                04/11/2015 - Adicionado condição para nao deixar abrir um mesmo
                             caixa no mesmo dia atraves da opcao "I".
                             (Jorge/Elton) - SD 342537

                05/011/2015 - Projeto GPS 254 - Adaptacao para consulta GPS 
                              SICREDI (Guilherme/SUPERO)

                26/11/2015 - Correcao do cálculo da fita de caixa 
                            (Guilherme/SUPERO)

                13/06/2016 - P290 -> Informações adicionais no boletim do Caixa
                            (Rafael Maciel / RKAM)
                            
                27/06/2016 - P290 -> Incluido identificador de CARTAO ou BOLETO para operações de saque, TED, DOC e transferência.
                             (Gil/Rkam)

                02/08/2016 - Inclusao insitage 3-Temporariamente Indisponivel.
                             (Jaison/Anderson)

                23/08/2016 - Agrupamento das informacoes (M36 - Kelvin).

                30/09/2016 - Ajuste realizado para corrigir o problema da melhoria 36 onde
                             não estava mostrando as arrecações de GPS, conforme é citado no chamado 532033.
                             (Kelvin)

                06/10/2016 - SD 489677 - Inclusao do flgativo na CRAPLGP
                             (Guilherme/SUPERO)

			          17/11/2016 - #549653 Ajustes de formats das quantidades para rotinas do bcaixa (Carlos)
				
                06/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                             departamento passando a considerar o código (Renato Darosci)
                             
                10/01/2016 - #587076 aumento de formats para o boletim de caixa (Carlos)

				        13/04/2017 - Inserido o campo nrsequen no create da tt-estorno
				                     #625135 (Tiago/Elton)
				
                26/06/2017 - Incluido parametro de etapa com valor 0 para procedure Busca_Dados e valor 1 para procedure imprime_caixa_cofre
            				         Chamado 660322 - (Belli Envolti)
                
                15/08/2017 - Ajuste para permitir o fechamento de caixas de dias diferentes do dia atual
                             (Lucas Ranghetti #665982)
............................................................................*/

/*............................. DEFINICOES .................................*/

{ sistema/generico/includes/b1wgen0120tt.i }
{ sistema/generico/includes/b1wgen0096tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1cabrelvar.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }
{ includes/var_online.i "NEW" }

DEF STREAM str_1.
DEF STREAM str_2.

DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                        NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                      NO-UNDO.
DEF VAR aux_nrcoluna AS INTE                                        NO-UNDO.
DEF VAR aux_idorigem AS INTE                                        NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!"                             NO-UNDO.

DEF BUFFER crabhis FOR craphis.

FUNCTION LockTabela   RETURNS CHARACTER PRIVATE 
    ( INPUT par_cddrecid AS RECID,
      INPUT par_nmtabela AS CHAR ) FORWARD.

FUNCTION VerificaData RETURNS LOGICAL PRIVATE 
    ( INPUT par_dtmvtolt AS DATE ) FORWARD.

/*................................ PROCEDURES ..............................*/
/* ------------------------------------------------------------------------ */
/*                     EFETUA A BUSCA BOLETIM DE CAIXA                      */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdopecxa AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolx AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtrefere AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoplanc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_tpcaicof AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM aux_msgsenha AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_msgretor AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_flgsemhi AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM aux_saldot   AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-boletimcx.
    DEF OUTPUT PARAM TABLE FOR tt-lanctos.
    DEF OUTPUT PARAM TABLE FOR tt_crapbcx.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_vlctrmve AS DECI                                    NO-UNDO.
    DEF VAR aux_tipconsu AS LOGI                                    NO-UNDO.
    DEF VAR h-b1crap80   AS HANDLE                                  NO-UNDO.
    DEF VAR aux_autchave AS INTE                                    NO-UNDO.
    DEF VAR aux_cdchave  AS CHAR                                    NO-UNDO.
    DEF VAR aux_sdfinbol LIKE crapbcx.vldsdfin                      NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlrttdeb AS DECI                                    NO-UNDO.
    DEF VAR aux_vlrttcrd AS DECI    FORMAT "zzz,zzz,zz9.99-"        NO-UNDO.
    DEF VAR aux_dshistor AS CHAR                                    NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados Boletim de Caixa".

    EMPTY TEMP-TABLE tt-erro.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-boletimcx.
        EMPTY TEMP-TABLE tt-lanctos.
        

        IF  NOT CAN-FIND(crapage WHERE 
                         crapage.cdcooper = par_cdcooper  AND
                         crapage.cdagenci = par_cdagencx) AND 
                         par_cdagencx <> 0 THEN
            DO:
                ASSIGN aux_cdcritic = 962.
                LEAVE Busca.
            END.

        IF  CAN-DO("C,S",par_cddopcao)             AND
            NOT VerificaData( INPUT par_dtmvtolx ) THEN
            DO:
                ASSIGN aux_cdcritic = 13.
                LEAVE Busca.
            END.

        IF  par_cddopcao <> "T" AND
            NOT CAN-FIND (crapope WHERE 
                          crapope.cdcooper = par_cdcooper AND
                          crapope.cdoperad = par_cdopecxa) THEN
            DO:
                ASSIGN aux_cdcritic = 67.
                LEAVE Busca.
            END.

        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        IF  par_cddopcao = "I" AND
            par_dtmvtolx <> par_dtmvtolt THEN
            DO:
                ASSIGN aux_cdcritic = 13.
                LEAVE Busca.
            END.

        FOR FIRST crapope FIELDS(cddepart cdsitope)
            WHERE crapope.cdcooper = par_cdcooper  AND
                  crapope.cdoperad = par_cdopecxa NO-LOCK: END.

        /* Restricoes para o caixa da INTERNET e TAA*/
        IF  ( par_cdagencx  = 90      OR  /** Internet **/
              par_cdagencx  = 91 )    AND /** TAA **/
              par_nrdcaixx  = 900     AND
            ( AVAIL crapope AND crapope.cddepart = 18)  AND  /** "SUPORTE" **/
              par_cddopcao <> "C"      AND
              par_cddopcao <> "S"     THEN
            DO:
                ASSIGN aux_dscritic = "Opcao nao permitida para o caixa " +
                                      "da INTERNET.".
                LEAVE Busca.
            END.

        CASE par_cddopcao:
            WHEN "C" THEN
                DO:
                    FOR EACH crapbcx WHERE crapbcx.cdcooper = par_cdcooper AND
                                           crapbcx.dtmvtolt = par_dtmvtolx AND
                                           crapbcx.cdagenci = par_cdagencx AND
                                           crapbcx.nrdcaixa = par_nrdcaixx AND
                                           crapbcx.cdopecxa = par_cdopecxa 
                                           NO-LOCK USE-INDEX crapbcx2:
                        
                        CREATE tt-boletimcx.
                        ASSIGN tt-boletimcx.cdopecxa = crapbcx.cdopecxa
                               tt-boletimcx.hrabtbcx = crapbcx.hrabtbcx
                               tt-boletimcx.hrfecbcx = crapbcx.hrfecbcx
                               tt-boletimcx.vldsdini = crapbcx.vldsdini
                               tt-boletimcx.vldsdfin = crapbcx.vldsdfin
                               tt-boletimcx.dshrabtb = STRING(crapbcx.hrabtbcx,
                                                                    "HH:MM:SS")
                               tt-boletimcx.dshrfecb = IF crapbcx.hrfecbcx = 0 
                                                       THEN "" 
                                                       ELSE STRING(
                                                       crapbcx.hrfecbcx,
                                                       "HH:MM:SS")
                               tt-boletimcx.nrcrecid = RECID(crapbcx).

                    END. /* FOR EACH crapbcx */
                END. /* par_cddopcao = C */
            WHEN "F" THEN
                DO:
                    FOR EACH craplot WHERE 
                             craplot.cdcooper = par_cdcooper    AND
                             craplot.dtmvtolt = par_dtmvtolt    AND
                             craplot.cdagenci = par_cdagencx    AND
                            (craplot.cdbccxlt = 11              OR
                             craplot.cdbccxlt = 30              OR
                             craplot.cdbccxlt = 31              OR
                             craplot.cdbccxlt = 500)            AND
                             craplot.nrdcaixa = par_nrdcaixx    AND
                             craplot.cdopecxa = par_cdopecxa    NO-LOCK:
                        
                        IF  craplot.qtcompln <> craplot.qtinfoln OR  
                            craplot.vlcompcr <> craplot.vlinfocr OR
                            craplot.vlcompdb <> craplot.vlinfodb THEN
                            DO:
                                ASSIGN aux_cdcritic = 139.
                                LEAVE Busca.
                            END.
                    END. /* FOR EACH craplot */

                    FIND craptab WHERE 
                         craptab.cdcooper = par_cdcooper AND
                         craptab.nmsistem = "CRED"       AND
                         craptab.tptabela = "GENERI"     AND
                         craptab.cdempres = 0            AND
                         craptab.cdacesso = "VLCTRMVESP" AND
                         craptab.tpregist = 0            NO-LOCK NO-ERROR.

                    IF  AVAIL craptab THEN
                        ASSIGN aux_vlctrmve = DEC(craptab.dstextab).

                    ASSIGN aux_dshistor = "1,21,22,1030".

                    FOR EACH craplcm WHERE 
                             craplcm.cdcooper = par_cdcooper                 AND
                             craplcm.dtmvtolt = par_dtmvtolt                 AND
                             craplcm.cdagenci = par_cdagencx                 AND
                             craplcm.cdbccxlt = 11                           AND
                             craplcm.nrdolote = 11000 + par_nrdcaixx         AND
                             CAN-DO(aux_dshistor,STRING(craplcm.cdhistor))   AND
                             craplcm.vllanmto >= aux_vlctrmve
                             USE-INDEX craplcm3 NO-LOCK:

                        IF  craplcm.cdhistor = 21 AND 
                            craplcm.cdpesqbb BEGINS "CRAP51" THEN
                            NEXT.

                        FIND crapcme WHERE 
                             crapcme.cdcooper = par_cdcooper     AND
                             crapcme.dtmvtolt = craplcm.dtmvtolt AND
                             crapcme.cdagenci = craplcm.cdagenci AND
                             crapcme.cdbccxlt = craplcm.cdbccxlt AND
                             crapcme.nrdolote = craplcm.nrdolote AND
                             crapcme.nrdctabb = craplcm.nrdctabb AND
                             crapcme.nrdocmto = craplcm.nrdocmto 
                             NO-LOCK NO-ERROR.
                                                     
                        IF  NOT AVAIL crapcme THEN
                            DO:               
                                ASSIGN aux_cdcritic = 768.
                                LEAVE Busca.     
                            END.                        
                                    
                    END. /* FOR EACH craplcm */

                    /**************** Deposito entre cooperativas ********************/
                    FOR EACH craplcx WHERE  craplcx.cdcooper = par_cdcooper         AND
                                            craplcx.dtmvtolt = par_dtmvtolt         AND
                                            craplcx.cdagenci = par_cdagencx         AND
                                            craplcx.nrdcaixa = par_nrdcaixx         AND
                                            craplcx.cdopecxa = par_cdopecxa         AND
                                            craplcx.cdhistor = 1003                 AND
                                            craplcx.vldocmto >= aux_vlctrmve   NO-LOCK:
                        
                        FIND LAST crapcme WHERE crapcme.cdcooper = par_cdcooper          AND
                                                crapcme.dtmvtolt = par_dtmvtolt          AND
                                                crapcme.cdagenci = par_cdagencx          AND
                                                crapcme.cdbccxlt = 11                    AND
                                                crapcme.nrdolote = 11000 + par_nrdcaixx  AND                            
                                                crapcme.nrdocmto = craplcx.nrdocmto
                                                NO-LOCK NO-ERROR.
                                                         
                        IF  NOT AVAIL crapcme THEN
                            DO:
                                ASSIGN aux_cdcritic = 768.
                                LEAVE Busca.
                            END.                                
                    END.
                    

                    FIND craptab WHERE 
                         craptab.cdcooper = par_cdcooper   AND
                         craptab.nmsistem = "CRED"         AND
                         craptab.tptabela = "GENERI"       AND
                         craptab.cdempres = 0              AND
                         craptab.cdacesso = "EXETRUNCAGEM" AND
                         craptab.tpregist = par_cdagencx
                         NO-LOCK NO-ERROR.

                    IF  AVAIL craptab THEN
                        DO:
                            /* Se o PA nao possuir registro 
                            de indisponibilidade ativa */
                            IF NOT CAN-FIND(FIRST crapikx WHERE
                                                  crapikx.cdcooper = 
                                                               par_cdcooper AND
                                                  crapikx.cdagenci = 
                                                               par_cdagencx AND
                                                  crapikx.dtindisp = 
                                                               par_dtmvtolt AND
                                                  crapikx.flindisp = TRUE
                                            NO-LOCK) THEN
                                DO:

                                    /* verifica a situacao das previas */
                                    IF  craptab.dstextab = "SIM" THEN
                                        DO:
                                            FIND FIRST crapchd WHERE 
                                                       crapchd.cdcooper  = 
                                                               par_cdcooper AND
                                                       crapchd.dtmvtolt  = 
                                                               par_dtmvtolt AND
                                                       crapchd.cdagenci  = 
                                                               par_cdagencx AND
                                                     ((crapchd.cdbccxlt  = 
                                                                         11 AND
                                                       crapchd.nrdolote  = 
                                                       11000 + par_nrdcaixx) OR
                                                      (crapchd.cdbccxlt  = 
                                                                         11 AND
                                                       crapchd.nrdolote  = 
                                                       30000 + par_nrdcaixx) OR
                                                      (crapchd.cdbccxlt  = 
                                                                        500 AND
                                                       crapchd.nrdolote  = 
                                                     28000 + par_nrdcaixx)) AND
                                                      crapchd.insitprv <= 1
                                           USE-INDEX crapchd3 NO-LOCK NO-ERROR.

                                            IF  AVAIL crapchd THEN
                                                DO:
                                                    ASSIGN aux_dscritic = 
                                                  "Ha cheques pendentes para" +
                                                  " a realizacao da previa.".
                                                    LEAVE Busca.
                                                END.
                                        END. /* IF  craptab.dstextab = "SIM" */
                                END. /* IF NOT CAN-FIND */
                        END. /* IF  AVAIL craptab */
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 55.
                            LEAVE Busca.
                        END.

                    FOR EACH craptvl WHERE 
                            (craptvl.cdcooper = par_cdcooper         AND
                             craptvl.dtmvtolt = par_dtmvtolt         AND
                             craptvl.cdagenci = par_cdagencx         AND
                             craptvl.cdbccxlt = 11                   AND
           /* TED - SPB */   craptvl.nrdolote = 23000 + par_nrdcaixx AND
                             craptvl.flgespec = TRUE                ) OR
                            (craptvl.cdcooper = par_cdcooper         AND
                             craptvl.dtmvtolt = par_dtmvtolt         AND
                             craptvl.cdagenci = par_cdagencx         AND
                             craptvl.cdbccxlt = 11                   AND
            /* TED - BB */   craptvl.nrdolote = 21000 + par_nrdcaixx AND
                             craptvl.flgespec = TRUE                ) OR
                            (craptvl.cdcooper = par_cdcooper         AND
                             craptvl.dtmvtolt = par_dtmvtolt         AND
                             craptvl.cdagenci = par_cdagencx         AND
                             craptvl.cdbccxlt = 11                   AND
                 /* DOC */   craptvl.nrdolote = 20000 + par_nrdcaixx AND
                             craptvl.flgespec = TRUE          ) NO-LOCK:

                        
                        IF  craptvl.nrdconta <> 0 THEN
                            DO:   
                                FIND craptab WHERE 
                                     craptab.cdcooper = par_cdcooper AND
                                     craptab.nmsistem = "CRED"       AND
                                     craptab.tptabela = "GENERI"     AND
                                     craptab.cdempres = 0            AND
                                     craptab.cdacesso = "VLCTRMVESP" AND
                                     craptab.tpregist = 0 NO-LOCK NO-ERROR.

                                IF  AVAIL craptab AND
                                    craptvl.vldocrcb < DEC(craptab.dstextab) THEN
                                    NEXT.
                            END. 

                        FIND crapcme WHERE 
                             crapcme.cdcooper = par_cdcooper         AND
                             crapcme.dtmvtolt = craptvl.dtmvtolt     AND
                             crapcme.cdagenci = craptvl.cdagenci     AND
                             crapcme.cdbccxlt = craptvl.cdbccxlt     AND
                             crapcme.nrdolote = 11000 + par_nrdcaixx AND
                             crapcme.nrdctabb = craptvl.nrdconta     AND
                             crapcme.nrdocmto = craptvl.nrdocmto 
                             NO-LOCK NO-ERROR.
                                                   
                        IF  NOT AVAILABLE crapcme THEN
                            DO:
                                ASSIGN aux_cdcritic = 768.
                                LEAVE Busca.
                            END.
                                                         
                    END. /* Fim do FOR EACH craptvl */
                    
                    FIND LAST crapbcx WHERE 
                              crapbcx.cdcooper = par_cdcooper   AND
                              crapbcx.dtmvtolt = par_dtmvtolx   AND
                              crapbcx.cdagenci = par_cdagencx   AND
                              crapbcx.nrdcaixa = par_nrdcaixx   AND
                              crapbcx.cdopecxa = par_cdopecxa   AND
                              crapbcx.cdsitbcx = 1          
                              NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE crapbcx THEN
                        DO:
                            ASSIGN aux_cdcritic = 698.
                            LEAVE Busca.
                        END.

                    CREATE tt-boletimcx.
                    ASSIGN tt-boletimcx.nrdmaqui = crapbcx.nrdmaqui
                           tt-boletimcx.qtautent = crapbcx.qtautent
                           tt-boletimcx.nrdlacre = crapbcx.nrdlacre
                           tt-boletimcx.vldsdini = crapbcx.vldsdini
                           tt-boletimcx.nrcrecid = RECID(crapbcx)
                           aux_tipconsu          = YES.

                    FIND crapage WHERE 
                         crapage.cdcooper = crapcop.cdcooper AND
                         crapage.cdagenci = par_cdagencx NO-LOCK NO-ERROR.

                    IF  AVAIL crapage THEN
                        IF  crapage.cdagecbn <> 0       AND                            
                            crapage.vercoban            AND
                            par_dtmvtolt = par_dtmvtolx THEN
                            DO:

                                IF  NOT VALID-HANDLE(h-b1crap80) THEN
                                    RUN siscaixa/web/dbo/b1crap80.p
                                        PERSISTENT SET h-b1crap80.

                                RUN executa-pendencias-fechamento IN h-b1crap80
                                    ( INPUT crapcop.nmrescop,
                                      INPUT par_cdagencx,
                                      INPUT par_nrdcaixx,
                                      INPUT par_cdopecxa,
                                     OUTPUT aux_autchave,
                                     OUTPUT aux_cdchave ).

                                IF  VALID-HANDLE(h-b1crap80) THEN
                                    DELETE PROCEDURE h-b1crap80.
                            END.

                        IF  RETURN-VALUE = "NOK" THEN   
                            DO:
                                FIND FIRST craperr WHERE 
                                           craperr.cdcooper = par_cdcooper AND
                                           craperr.cdagenci = par_cdagencx AND
                                           craperr.nrdcaixa = par_nrdcaixx
                                           NO-LOCK NO-ERROR.

                                IF  AVAIL craperr THEN
                                    ASSIGN aux_msgsenha = craperr.dscritic.
                            END.

                        RUN Gera_Boletim
                            ( INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_idorigem,
                              INPUT par_nmdatela,
                              INPUT par_dtmvtolt,       
                              INPUT par_dsiduser,
                              INPUT YES, /* tipconsu */
                              INPUT tt-boletimcx.nrcrecid,
                             OUTPUT aux_flgsemhi,
                             OUTPUT aux_sdfinbol,
                             OUTPUT aux_vlrttcrd,
                             OUTPUT aux_vlrttdeb,
                             OUTPUT aux_nmarqimp,
                             OUTPUT aux_nmarqpdf,
                             OUTPUT TABLE tt-erro).

                        IF  RETURN-VALUE <> "OK" THEN
                            LEAVE Busca.
                    
                END. /* par_cddopcao = F */
            WHEN "I" THEN
                DO:
                    IF  NOT AVAIL crapope THEN
                        DO:
                            ASSIGN aux_cdcritic = 67.
                            LEAVE Busca.
                        END.

                    IF  crapope.cdsitope <> 1 THEN
                        DO:
                            ASSIGN aux_cdcritic = 627.
                            LEAVE Busca. 
                        END.

                    FIND crapage WHERE 
                         crapage.cdcooper = crapcop.cdcooper AND
                         crapage.cdagenci = par_cdagencx 
                         NO-LOCK NO-ERROR.

                    IF  AVAIL crapage THEN
                        DO:
                            IF   crapage.insitage <> 1   AND   /* Ativo */
                                 crapage.insitage <> 3   THEN  /* Temporariamente Indisponivel */
                                 DO:
                                     ASSIGN aux_cdcritic = 856.
                                     LEAVE Busca. 
                                 END.
                        END.

                END. /* par_cddopcao = I */
            WHEN "L" OR WHEN "K" THEN
                DO:
                    IF  par_cdoplanc = "" THEN
                        IF  par_cddopcao = "K" THEN
                            DO:
                                FIND LAST crapbcx WHERE 
                                          crapbcx.cdcooper = par_cdcooper AND
                                          crapbcx.dtmvtolt = par_dtmvtolt AND
                                          crapbcx.cdagenci = par_cdagencx AND
                                          crapbcx.nrdcaixa = par_nrdcaixx AND
                                          crapbcx.cdopecxa = par_cdopecxa
                                          NO-LOCK NO-ERROR.
    
                                IF  AVAIL crapbcx THEN
                                    DO:
                                        IF  crapbcx.cdsitbcx = 2 THEN 
                                            ASSIGN aux_msgretor = "Boletim" +
                                                   " ja fechado. Reabri-lo?".
                                    END.
                                ELSE
                                    DO:
                                        ASSIGN aux_cdcritic = 698.
                                        LEAVE Busca.
                                    END.
                            END.
                        ELSE
                            DO:
                                FIND LAST crapbcx WHERE 
                                          crapbcx.cdcooper = par_cdcooper AND
                                          crapbcx.dtmvtolt = par_dtmvtolt AND
                                          crapbcx.cdagenci = par_cdagencx AND
                                          crapbcx.nrdcaixa = par_nrdcaixx AND
                                          crapbcx.cdopecxa = par_cdopecxa AND
                                          crapbcx.cdsitbcx = 1 NO-LOCK NO-ERROR.
    
                                IF  NOT AVAIL crapbcx THEN
                                    DO:
                                        ASSIGN aux_cdcritic = 698.
                                        LEAVE Busca.
                                    END.
                                
                            END.
                    
                    CASE par_cdoplanc:
                        WHEN "C" THEN DO:
                            FOR EACH craplcx FIELDS(cdhistor dsdcompl nrdocmto
                                                    vldocmto nrseqdig cdcooper)
                               WHERE craplcx.cdcooper = par_cdcooper  AND
                                     craplcx.dtmvtolt = par_dtmvtolt  AND
                                     craplcx.cdagenci = par_cdagencx  AND
                                     craplcx.nrdcaixa = par_nrdcaixx  AND
                                     craplcx.cdopecxa = par_cdopecxa  NO-LOCK,
                                EACH craphis FIELDS(dshistor)
                               WHERE craphis.cdcooper = craplcx.cdcooper AND 
                                     craphis.cdhistor = craplcx.cdhistor NO-LOCK
                                     BY craplcx.nrseqdig:

                                CREATE tt-lanctos.
                                ASSIGN tt-lanctos.cdhistor = craplcx.cdhistor
                                       tt-lanctos.dshistor = craphis.dshistor
                                       tt-lanctos.dsdcompl = craplcx.dsdcompl
                                       tt-lanctos.nrdocmto = craplcx.nrdocmto
                                       tt-lanctos.vldocmto = craplcx.vldocmto
                                       tt-lanctos.nrseqdig = craplcx.nrseqdig.

                            END. /* FOR EACH craplcx */
                        END. /* par_cdoplanc = C */
                    END CASE.
                END. /* par_cddopcao = I */
            WHEN "S" THEN
                DO:
                    FOR EACH crapbcx FIELDS(cdagenci nrdcaixa cdsitbcx
                                            vldsdini vldsdfin cdopecxa)
                       WHERE crapbcx.cdcooper = par_cdcooper     AND
                             crapbcx.dtmvtolt = par_dtmvtolx
                             USE-INDEX crapbcx2 NO-LOCK,
                       FIRST crapope FIELDS(nmoperad)
                       WHERE crapope.cdcooper = par_cdcooper     AND
                             crapope.cdoperad = crapbcx.cdopecxa NO-LOCK:

                        CREATE tt-boletimcx.
                        ASSIGN tt-boletimcx.cdagenci = crapbcx.cdagenci
                               tt-boletimcx.nrdcaixa = crapbcx.nrdcaixa
                               tt-boletimcx.cdsitbcx = crapbcx.cdsitbcx
                               tt-boletimcx.vldsdini = crapbcx.vldsdini
                               tt-boletimcx.vldsdfin = crapbcx.vldsdfin
                               tt-boletimcx.nmoperad = crapope.nmoperad
                               tt-boletimcx.nrcrecid = RECID(crapbcx).

                    END. /* FOR EACH crapbcx */
            
                END. /* par_cddopcao = S */
            WHEN "T" THEN
                DO: 
                    IF  par_tpcaicof = "CAIXA" THEN
                        DO:
                            /* Buscar saldo em caixa */
                            RUN SaldoCaixas (INPUT par_cdcooper,
                                             INPUT par_cdagencx,
                                             INPUT par_nrdcaixa,
                                             INPUT par_dtrefere,
                                             INPUT par_cdoperad,
                                             INPUT par_cdprogra,
                                             INPUT par_dtmvtolt,
                                             INPUT "0", /* Indica a etapa do processo Chamado 660322 26/06/2017 */
                                            OUTPUT aux_saldot,
                                            OUTPUT aux_nmarqimp,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE tt_crapbcx).
                           
                            IF  RETURN-VALUE <> "OK" THEN
                                LEAVE Busca.
                            
                        END.
                    ELSE 
                    IF  par_tpcaicof = "COFRE" THEN
                        DO:
                            /* Buscar saldo em cofre */
                            RUN SaldoCofre ( INPUT par_cdcooper,
                                             INPUT par_cdagencx,
                                             INPUT par_nrdcaixa,
                                             INPUT par_dtmvtolt,
                                             INPUT par_cdprogra, /* Chamado 660322 23/06/2017 */
                                             INPUT "0",          /* Indica a etapa do processo Chamado 660322 26/06/2017 */
                                            OUTPUT aux_saldot,
                                            OUTPUT aux_nmarqimp,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE tt_crapbcx).
                           
                            IF  RETURN-VALUE <> "OK" THEN
                                LEAVE Busca.
                        END.
                    ELSE 
                    IF  par_tpcaicof = "TOTAL" THEN
                        DO:
                            /* Buscar saldo em cofre */
                            RUN SaldoTotal ( INPUT par_cdcooper,
                                             INPUT par_cdagencx,
                                             INPUT par_nrdcaixa,
                                             INPUT par_dtrefere,
                                             INPUT par_cdoperad,
                                             INPUT par_cdprogra,
                                             INPUT par_dtmvtolt,
                                             INPUT "0", /* Indica a etapa do processo Chamado 660322 26/06/2017 */
                                            OUTPUT aux_saldot,
                                            OUTPUT aux_nmarqimp,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE tt_crapbcx).
                           
                            IF  RETURN-VALUE <> "OK" THEN
                                LEAVE Busca.
                        END.
                END. /* par_cddopcao = T */
        END CASE.

        LEAVE Busca.

    END. /* Busca */


    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0  OR 
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
            ELSE
                DO:
                    FIND FIRST tt-erro NO-ERROR.

                    IF  AVAIL tt-erro THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                END.

            IF  par_flgerlog THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT NO,
                                    INPUT 1, /** idseqttl **/
                                    INPUT par_nmdatela,
                                    INPUT 0, /* nrdconta */
                                   OUTPUT aux_nrdrowid).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Dados */

PROCEDURE Gera_Boletim:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tipconsu AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_ndrrecid AS RECID                          NO-UNDO.
    
    DEF  OUTPUT PARAM aux_flgsemhi AS LOGI                          NO-UNDO.
    DEF  OUTPUT PARAM aux_vldsdfin LIKE crapbcx.vldsdfin            NO-UNDO.
    DEF  OUTPUT PARAM aux_vlrttcrd AS DECI FORMAT "zzz,zzz,zz9.99-" NO-UNDO.
    DEF  OUTPUT PARAM aux_vlrttdeb AS DECI FORMAT "zzz,zzz,zz9.99-" NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgouthi AS LOGI                                    NO-UNDO.
    DEF VAR aux_vlrttctb AS DECI    FORMAT "zzz,zzz,zz9.99-"        NO-UNDO.
    DEF VAR aux_qtrttctb AS INTE                                    NO-UNDO.
    DEF VAR aux_vlroti14 AS DECI                                    NO-UNDO.
    DEF VAR aux_qtroti14 AS INTE                                    NO-UNDO.
    DEF VAR aux_vllanchq AS DECI                                    NO-UNDO.
    DEF VAR aux_qtlanchq AS INTE                                    NO-UNDO.
    DEF VAR aux_nrctadeb AS INTE    FORMAT "9999"                   NO-UNDO.
    DEF VAR aux_nrctacrd AS INTE    FORMAT "9999"                   NO-UNDO.
    DEF VAR aux_cdhistor AS INTE    FORMAT "9999"                   NO-UNDO.
    DEF VAR aux_descrctb AS CHAR    FORMAT "x(31)"                  NO-UNDO. 
    DEF VAR aux_deschist AS CHAR    FORMAT "x(47)"                  NO-UNDO.
    DEF VAR aux_vlrtthis AS DECI    FORMAT "zzz,zzz,zz9.99"         NO-UNDO.
    DEF VAR aux_deshi717 AS CHAR    FORMAT "X(76)"                  NO-UNDO.
    DEF VAR aux_dshistor AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdtraco AS CHAR    INIT "________________"         NO-UNDO.

    /*Variavel para o formulario de arrecadacao*/
    DEF VAR aux_dsarecad AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlarecad AS DECI                                    NO-UNDO.
    
    /*Arrecadacoes*/
    DEF VAR aux_vlarctot AS DECI                                    NO-UNDO.
    DEF VAR aux_dsarctot AS CHAR                                    NO-UNDO.        
    DEF VAR aux_arcconta AS INTE                                    NO-UNDO.   
    DEF VAR aux_vlarccon AS DECI                                    NO-UNDO.
    DEF VAR aux_vlarcdar AS DECI                                    NO-UNDO.
    DEF VAR aux_vlarcgps AS DECI                                    NO-UNDO.
    DEF VAR aux_vlarcnac AS DECI                                    NO-UNDO.
    DEF VAR aux_qtarccon AS INTE                                    NO-UNDO.
    DEF VAR aux_qtarcdar AS INTE                                    NO-UNDO.
    DEF VAR aux_qtarcgps AS INTE                                    NO-UNDO.
    DEF VAR aux_qtarcnac AS INTE                                    NO-UNDO.
    
    /*Titulos*/
    DEF VAR aux_vltittot AS DECI                                    NO-UNDO. 
    DEF VAR aux_qttittot AS INTE                                    NO-UNDO. 
    DEF VAR aux_flg713ti AS LOGI                                    NO-UNDO.
    
    /*Deposito a vista*/
    DEF VAR aux_vldepsup AS DECI                                    NO-UNDO. 
    DEF VAR aux_qtdepsup AS INTE                                    NO-UNDO. 
    DEF VAR aux_vldepinf AS DECI                                    NO-UNDO. 
    DEF VAR aux_qtdepinf AS INTE                                    NO-UNDO. 
    DEF VAR aux_vldepcop AS DECI                                    NO-UNDO. 
    DEF VAR aux_qtdepcop AS INTE                                    NO-UNDO. 
    DEF VAR aux_vldepout AS DECI                                    NO-UNDO. 
    DEF VAR aux_qtdepout AS INTE                                    NO-UNDO. 
    
    /*Auxiliares para impressao*/
    DEF VAR aux_nrdevias AS INTE                                    NO-UNDO.
    DEF VAR aux_dscomand AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmdafila AS CHAR                                    NO-UNDO.
    
    DEF VAR aux_vlrtotal AS DECI                                    NO-UNDO.

    DEF VAR tot_qtgerfin AS INTE                                    NO-UNDO.
    DEF VAR tot_vlgerfin AS DECI                                    NO-UNDO.
    
    DEF VAR rel_nmresage AS CHAR                                    NO-UNDO.
    DEF VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                  NO-UNDO.


    DEF VAR rel_dtmvtolt LIKE crapbcx.dtmvtolt                      NO-UNDO.
    DEF VAR rel_cdagenci LIKE crapbcx.cdagenci                      NO-UNDO.
    DEF VAR rel_cdopecxa LIKE crapbcx.cdopecxa                      NO-UNDO. 
    DEF VAR rel_nmoperad LIKE crapope.nmoperad                      NO-UNDO.
    DEF VAR rel_nrdcaixa LIKE crapbcx.nrdcaixa                      NO-UNDO. 
    DEF VAR rel_nrdmaqui like crapbcx.nrdmaqui                      NO-UNDO.
    DEF VAR rel_nrdlacre like crapbcx.nrdlacre                      NO-UNDO.
    DEF VAR rel_vldsdini LIKE crapbcx.vldsdini                      NO-UNDO.
    DEF VAR rel_qtautent LIKE crapbcx.qtautent                      NO-UNDO.
    DEF VAR rel_dsfechad AS CHAR                                    NO-UNDO.

    FORM HEADER
     "REFERENCIA:" rel_dtmvtolt 
     SKIP(1)
     " PA:" rel_cdagenci FORMAT "ZZ9" "-" rel_nmresage FORMAT "x(18)" SPACE(1)
     "OPERADOR:" rel_cdopecxa FORMAT "x(10)" "-" rel_nmoperad  FORMAT "x(20)" 
     SKIP(1)
     "CAIXA:" rel_nrdcaixa FORMAT "ZZ9" "AUTENTICADORA:" AT 16 rel_nrdmaqui
     FORMAT "ZZ9" "QTD. AUT.:" AT 39 rel_qtautent "LACRE:" AT 61 rel_nrdlacre
     SKIP(1)
     FILL("=",76)  FORMAT "x(76)"
     SKIP(1)
     WITH NO-BOX COLUMN aux_nrcoluna
          NO-LABELS PAGE-TOP WIDTH 76 FRAME f_cabec_boletim.
     
    FORM HEADER     
         "SALDO INICIAL" FILL(".",44) FORMAT "x(44)" ":" rel_vldsdini
         SKIP(1)
         FILL("-",76) FORMAT "x(76)"
         SKIP
         "***   E N T R A D A S   ***" AT 26 SKIP
         FILL("-",76) FORMAT "x(76)" SKIP
         "DESCRICAO" AT 1 "CONTABILIDADE   HIST." AT 35 "VALOR R$" AT 68 SKIP
         FILL("-",76) FORMAT "x(76)"
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_inicio_boletim.
     
    FORM aux_descrctb FORMAT "x(60)"
         aux_vlrttctb FORMAT "zzz,zzz,zz9.99-"
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_ctb_boletim.

    FORM SPACE(2)
         aux_deschist FORMAT "x(41)"
         ":"
         aux_vlrtthis FORMAT "zzz,zzz,zz9.99"
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_his_boletim.
    
    FORM aux_dsarecad FORMAT "x(43)"
         ":"
         aux_vlarecad FORMAT "zzz,zzz,zz9.99" 
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_tot_arc_boletim.
    
    FORM HEADER
         SKIP(1)
         "TOTAL DE CREDITOS" 
         FILL(".",40) FORMAT "x(40)" ":"
         aux_vlrttcrd FORMAT "zzz,zzz,zz9.99-"
         SKIP(1)
         FILL("-",76) FORMAT "x(76)" SKIP
         "***   S A I D A S   ***" AT 29
         FILL("-",76) FORMAT "x(76)" SKIP
         "DESCRICAO" AT 1 "CONTABILIDADE   COD. HIST." AT 26 "VALOR R$" AT 68 SKIP
         FILL("-",76) FORMAT "x(76)"
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_saidas_boletim.

    FORM HEADER
         SKIP(1)
         "TOTAL DE DEBITOS"
         FILL(".",41) FORMAT "x(41)" ":"
         aux_vlrttdeb FORMAT "zzz,zzz,zz9.99-"
         SKIP(1)
         FILL("-",76) FORMAT "x(76)" SKIP(1)
         "SALDO FINAL" FILL(".",46) FORMAT "x(46)" ":"
         aux_vldsdfin  FORMAT "zzz,zzz,zz9.99-" SKIP(1)
         FILL("=",76) FORMAT "x(76)"
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_saldo_final.
    
    FORM HEADER
         SKIP(1)
         "***   E S T O R N O S   ***" AT 25
         FILL("-",76) FORMAT "x(76)" SKIP
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_ini_estornos.

    FORM SPACE(2)
         crapaut.nrsequen COLUMN-LABEL "Aut"       FORMAT "zzz,zz9"
         aux_dshistor     COLUMN-LABEL "Historico" FORMAT "x(23)"
         crapaut.nrdocmto
         crapaut.vldocmto COLUMN-LABEL "Valor" FORMAT "zzzz,zz9.99"
         crapaut.tpoperac COLUMN-LABEL "PG/RC"
         crapaut.nrseqaut COLUMN-LABEL "Aut.Est"   FORMAT "zzz,zz9"
         WITH NO-BOX COLUMN aux_nrcoluna DOWN WIDTH 76 FRAME f_estornos.
    
    FORM crapaut.nrsequen COLUMN-LABEL "Aut"
         aux_dshistor     COLUMN-LABEL "Historico" FORMAT "x(23)"
         crapaut.nrdocmto
         crapaut.vldocmto COLUMN-LABEL "Valor" FORMAT "zzzz,zz9.99"
         aux_dsdtraco     COLUMN-LABEL "Nr. Pendencia" FORMAT "x(16)"    
         WITH NO-BOX COLUMN aux_nrcoluna DOWN WIDTH 76 FRAME f_gerfin.
    
    FORM HEADER
         SKIP(1)
         FILL("-",76) FORMAT "x(76)" SKIP
         WITH NO-BOX COLUMN aux_nrcoluna DOWN WIDTH 76 FRAME f_fim_estornos.
          
    FORM  "VISTOS: " SPACE(47) 
          rel_dsfechad FORMAT "x(21)" NO-LABEL
          SKIP(4)
          "------------------ ------------------"
          "------------------"
          SKIP   
          SPACE(5) "OPERADOR" SPACE(10) "RESPONSAVEL" 
          SPACE(7) "CONTABILIDADE"
          WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_vistos .
    
    FORM aux_deshi717
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_descricao_717.
    
    FORM SKIP(1)
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_linha_branco.

    FORM HEADER
        SKIP(1)
        "--------------------------------------------------------------------------~~-" SKIP
        "***   Diferencas Caixa  ***" AT 29
     "---------------------------------------------------------------------------" ~SKIP
        SKIP 
        WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS 
        WIDTH 76 FRAME f_inicio_diferenca  STREAM-IO.

    FORM HEADER
        SKIP(1)
     "---------------------------------------------------------------------------" 
        SKIP(1)
        WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS 
        WIDTH 76 FRAME f_fim_diferenca STREAM-IO.
    
    ASSIGN aux_vlrttcrd = 0
           aux_vlrttdeb = 0.
    
    EMPTY TEMP-TABLE tt-erro.

    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:

        FOR FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crapcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        IF par_idorigem = 2 THEN
           DO:               
              ASSIGN aux_nmendter = "/usr/coop/sistema/siscaixa/web/spool/" + STRING(crapcop.dsdircop) + 
                                                                              STRING(par_cdagenci) + 
                                                                              STRING(par_nrdcaixa) + "b2013".

              IF aux_nmendter <> "" AND
			           NOT par_tipconsu THEN
			           DO:				 
			              UNIX SILENT VALUE("rm " + aux_nmendter + "*").
                 END.
		
              ASSIGN aux_nmarqimp = aux_nmendter + string(random(1,99999)) + ".txt".

           END.
        ELSE
           DO:
              ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" + par_dsiduser.
              
        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".
           END.

        IF  NOT par_tipconsu THEN
            DO:
                OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

                /* Cdempres = 11 , Relatorio 258 em 80 colunas */
                { sistema/generico/includes/b1cabrel080.i "11" "258" "80" } 
                
                
            END.
        ELSE
            DO:
                /* visualiza nao pode ter caracteres de controle */
                OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp). 
            END.

        FIND crapbcx WHERE RECID(crapbcx) = par_ndrrecid NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapbcx THEN
            DO:
                ASSIGN aux_cdcritic = 11.
                LEAVE Imprime.
            END.

        FOR FIRST crapage WHERE crapage.cdcooper = par_cdcooper     AND
                                crapage.cdagenci = crapbcx.cdagenci NO-LOCK:
        END.

        IF  NOT AVAIL crapage THEN
            DO:
                ASSIGN aux_cdcritic = 962.
                LEAVE Imprime.
            END.

        FOR FIRST crapope WHERE crapope.cdcooper = par_cdcooper     AND
                                crapope.cdoperad = crapbcx.cdopecxa NO-LOCK:
        END.

        IF  NOT AVAIL crapope THEN
            DO:
                ASSIGN aux_cdcritic = 702.
                LEAVE Imprime.
            END.

        ASSIGN rel_dtmvtolt = crapbcx.dtmvtolt 
               rel_cdagenci = crapbcx.cdagenci
               rel_nmresage = crapage.nmresage
               rel_cdopecxa = crapbcx.cdopecxa 
               rel_nmoperad = crapope.nmoperad
               rel_nrdcaixa = crapbcx.nrdcaixa
               rel_nrdmaqui = crapbcx.nrdmaqui
               rel_qtautent = crapbcx.qtautent
               rel_nrdlacre = crapbcx.nrdlacre
               rel_vldsdini = crapbcx.vldsdini
               aux_flgsemhi = NO.

        VIEW STREAM str_1 FRAME f_cabec_boletim.
        
        VIEW STREAM str_1 FRAME f_inicio_boletim.

        
        /*Loop feito para acumular os valores do gps separadamente*/
        FOR EACH craphis WHERE craphis.cdcooper = par_cdcooper AND
                               ((craphis.tplotmov = 30) OR  /* GPS */
                               (craphis.tplotmov = 0   AND /* GPS SICREDI */            
                               craphis.cdhistor = 1414)) NO-LOCK: 
        
           IF  craphis.nmestrut = "craplgp" THEN
                DO:
                    /* Verifica qual historico deve rodar conforme cadastro
                     da COOP. Se tem Credenciamento, deve ser historico 
                     582 senao 458 */
                    IF (   (crapcop.cdcrdarr = 0 AND
                            craphis.cdhistor = 458)
                       OR  (crapcop.cdcrdarr <> 0 AND
                            craphis.cdhistor = 582)) THEN DO:
                        
                        RUN gera_craplgp
                            ( INPUT par_cdcooper,
                              INPUT-OUTPUT aux_vlarcgps,
                              INPUT-OUTPUT aux_qtarcgps).
                    END.
                    ELSE DO:
                        IF (crapcop.cdcrdins <> 0  AND /* GPS SICREDI NOVO */
                            craphis.cdhistor = 1414) THEN DO:
                            
                            RUN gera_craplgp_gps
                               ( INPUT par_cdcooper,
                                 INPUT-OUTPUT aux_vlarcgps,
                                 INPUT-OUTPUT aux_qtarcgps).
                        END.
                    END.
                END.
        END.
          
        FOR EACH craphis WHERE 
                 craphis.cdcooper = par_cdcooper AND
               ((craphis.tplotmov = 22  OR
                 craphis.tplotmov = 24  OR
                 craphis.tplotmov = 25  OR
                 craphis.tplotmov = 28  OR    /* COBAN */
                 craphis.tplotmov = 29  OR    /* CONTA INVESTIMENTO*/
                 craphis.tplotmov = 31  OR    /* Recebimento INSS */
                 craphis.tplotmov = 32  OR    /* Conta salario */
                 craphis.tplotmov = 33) OR    /* Receb. INSS-BANCOOB */
                (craphis.tplotmov = 5   AND    /* Pagto Emprestimo Cx */
                 craphis.cdhistor = 92)
               )
                 NO-LOCK
                 BREAK BY craphis.indebcre
                          BY craphis.cdhistor:

            ASSIGN aux_flgouthi = NO
                   aux_flg713ti = NO
                   aux_vlrttctb = 0
                   aux_qtrttctb = 0
                   aux_vlarccon = 0
                   aux_qtarccon = 0
                   aux_vlarcdar = 0
                   aux_qtarcdar = 0
                   aux_vlarcnac = 0
                   aux_qtarcnac = 0
                   aux_vldepsup = 0
                   aux_qtdepsup = 0
                   aux_vldepinf = 0
                   aux_qtdepinf = 0
                   aux_vldepcop = 0
                   aux_qtdepcop = 0
                   aux_vldepout = 0
                   aux_qtdepout = 0.                   

            EMPTY TEMP-TABLE tt-histor.
            
            IF  craphis.nmestrut = "craplcm" THEN
                DO:
                    FOR EACH craplot WHERE 
                             craplot.cdcooper = par_cdcooper       AND
                             craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                             craplot.cdagenci = crapbcx.cdagenci   AND
                             craplot.cdbccxlt = 11                 AND
                             craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                             craplot.cdopecxa = crapbcx.cdopecxa   AND
                             craplot.tplotmov = 1
                             NO-LOCK:

                        FOR EACH craplcm WHERE 
                                 craplcm.cdcooper = par_cdcooper     AND
                                 craplcm.dtmvtolt = craplot.dtmvtolt AND
                                 craplcm.cdagenci = craplot.cdagenci AND
                                 craplcm.cdbccxlt = craplot.cdbccxlt AND
                                 craplcm.nrdolote = craplot.nrdolote   
                                 USE-INDEX craplcm1 NO-LOCK:

                            /* MODIFICANDO GIL RKAM */
                            { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} } /* incluir session oracle */
                            RUN STORED-PROCEDURE pc_busca_tipo_cartao_mvt aux_handproc = PROC-HANDLE NO-ERROR /* Consulta Oracle da tablela tbcrd_log_operacao - retorno tipo de cartao */
                               (INPUT craplcm.cdcooper,
                                INPUT craplcm.nrdconta,
                                INPUT craplcm.nrdocmto,
                                INPUT craplcm.cdhistor,
                                INPUT craplcm.dtmvtolt,
                                OUTPUT pr_tpcartao,
                                OUTPUT pr_dscritic).
                            
                            IF  ERROR-STATUS:ERROR  THEN DO:
                                DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
                                    ASSIGN aux_msgerora = aux_msgerora + 
                                                          ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
                                END.
                                    
                                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                                  " - " + glb_cdprogra + "' --> '"  +
                                                  "Erro ao executar Stored Procedure: '" +
                                                  aux_msgerora + " - " + pr_dscritic + "' >> log/proc_batch.log").
                                RETURN.
                            END.
                            
                            CLOSE STORED-PROCEDURE pc_busca_tipo_cartao_mvt WHERE PROC-HANDLE = aux_handproc.
                            { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} } /* sair session oracle */
                            
                            RUN gera_tt-histor 
                                ( INPUT par_cdcooper,
                                  INPUT craplcm.cdhistor,
                                  INPUT craplcm.vllanmto,
                                  INPUT "", /*dsdcompl*/
                                  INPUT 0, /*tpfatura*/
                                  INPUT-OUTPUT aux_flgouthi,
                                  INPUT-OUTPUT aux_vlrttctb,
                                  INPUT-OUTPUT aux_qtrttctb,
                                  INPUT-OUTPUT aux_vlarccon,
                                  INPUT-OUTPUT aux_qtarccon,
                                  INPUT-OUTPUT aux_vlarcdar,
                                  INPUT-OUTPUT aux_qtarcdar,
                                  INPUT-OUTPUT aux_vlarcgps,
                                  INPUT-OUTPUT aux_qtarcgps,
                                  INPUT-OUTPUT aux_vlarcnac,
                                  INPUT-OUTPUT aux_qtarcnac,
                                  INPUT-OUTPUT aux_vldepsup,
                                  INPUT-OUTPUT aux_qtdepsup,
                                  INPUT-OUTPUT aux_vldepinf,
                                  INPUT-OUTPUT aux_qtdepinf,
                                  INPUT-OUTPUT aux_vldepcop,
                                  INPUT-OUTPUT aux_qtdepcop,
                                  INPUT-OUTPUT aux_vldepout,
                                  INPUT-OUTPUT aux_qtdepout,
								  INPUT pr_tpcartao).

                        END. /* FOR EACH craplcm */

                    END. /* FOR EACH craplot */ 
                  
                END. /* craphis.nmestrut = "craplcm" */
            ELSE
            IF  craphis.nmestrut = "craplem" AND
                craphis.tplotmov <> 5 THEN
                DO:
                    FOR EACH craplot WHERE 
                             craplot.cdcooper = par_cdcooper       AND
                             craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                             craplot.cdagenci = crapbcx.cdagenci   AND
                             craplot.cdbccxlt = 11                 AND
                             craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                             craplot.cdopecxa = crapbcx.cdopecxa   AND
                             craplot.tplotmov = 5
                             NO-LOCK:

                        FOR EACH craplem WHERE 
                                 craplem.cdcooper = par_cdcooper     AND
                                 craplem.dtmvtolt = craplot.dtmvtolt AND
                                 craplem.cdagenci = craplot.cdagenci AND
                                 craplem.cdbccxlt = craplot.cdbccxlt AND
                                 craplem.nrdolote = craplot.nrdolote
                                 USE-INDEX craplem1 NO-LOCK:

                            RUN gera_tt-histor 
                                ( INPUT par_cdcooper,
                                  INPUT craplem.cdhistor,
                                  INPUT craplem.vllanmto,
                                  INPUT "", /*dsdcompl*/
                                  INPUT 0, /*tpfatura*/
                                  INPUT-OUTPUT aux_flgouthi,
                                  INPUT-OUTPUT aux_vlrttctb,
                                  INPUT-OUTPUT aux_qtrttctb,
                                  INPUT-OUTPUT aux_vlarccon,
                                  INPUT-OUTPUT aux_qtarccon,
                                  INPUT-OUTPUT aux_vlarcdar,
                                  INPUT-OUTPUT aux_qtarcdar,
                                  INPUT-OUTPUT aux_vlarcgps,
                                  INPUT-OUTPUT aux_qtarcgps,
                                  INPUT-OUTPUT aux_vlarcnac,
                                  INPUT-OUTPUT aux_qtarcnac,
                                  INPUT-OUTPUT aux_vldepsup,
                                  INPUT-OUTPUT aux_qtdepsup,
                                  INPUT-OUTPUT aux_vldepinf,
                                  INPUT-OUTPUT aux_qtdepinf,
                                  INPUT-OUTPUT aux_vldepcop,
                                  INPUT-OUTPUT aux_qtdepcop,
                                  INPUT-OUTPUT aux_vldepout,
                                  INPUT-OUTPUT aux_qtdepout,
                                  INPUT 9).

                        END. /* FOR EACH craplem */

                    END. /* FOR EACH craplot */

                END. /* IF   craphis.nmestrut = "craplem"  */
            ELSE
            IF  craphis.nmestrut = "crapcbb" AND
                craphis.tplotmov = 31 THEN
                DO:
                    RUN gera_crapcbb_INSS
                        ( INPUT par_cdcooper,
                          INPUT-OUTPUT aux_vlrttctb,
                          INPUT-OUTPUT aux_qtrttctb).
                END.
            ELSE
            IF  craphis.nmestrut = "crapcbb" THEN 
                DO:
                    RUN gera_crapcbb
                        ( INPUT par_cdcooper,
                          INPUT-OUTPUT aux_vlrttctb,
                          INPUT-OUTPUT aux_qtrttctb).
                END.
            ELSE
            IF  craphis.nmestrut = "craplpi" THEN
                DO:
                    RUN gera_craplpi
                        ( INPUT par_cdcooper,
                          INPUT-OUTPUT aux_vlrttctb,
                          INPUT-OUTPUT aux_qtrttctb).
                END.
            ELSE 
            IF  craphis.nmestrut = "craplcs" THEN 
                DO:
                    RUN gera_craplcs
                        ( INPUT par_cdcooper,
                          INPUT-OUTPUT aux_vlrttctb,
                          INPUT-OUTPUT aux_vlrttcrd,
                          INPUT-OUTPUT aux_qtrttctb).
                END.
            ELSE
            IF  craphis.nmestrut = "craplci" THEN
                DO:
                    RUN gera_craplci
                        ( INPUT par_cdcooper,
                          INPUT-OUTPUT aux_vlrttctb,
                          INPUT-OUTPUT aux_qtrttctb).
                END.
            ELSE
            IF  craphis.nmestrut = "craplem" THEN
                DO:
                    RUN gera_craplem
                        ( INPUT par_cdcooper,
                          INPUT-OUTPUT aux_vlrttctb,
                          INPUT-OUTPUT aux_qtrttctb).
                END.
            ELSE 
            IF  craphis.nmestrut = "craplft"   THEN
                DO:
                    FOR EACH craplot WHERE 
                             craplot.cdcooper = par_cdcooper       AND
                             craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                             craplot.cdagenci = crapbcx.cdagenci   AND
                            (craplot.cdbccxlt = 30                 OR
                             craplot.cdbccxlt = 31                 OR
                             craplot.cdbccxlt = 11)                AND
                             craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                             craplot.cdopecxa = crapbcx.cdopecxa   AND
                             craplot.tplotmov = 13
                             NO-LOCK:

                        FOR EACH craplft WHERE 
                                 craplft.cdcooper = par_cdcooper     AND
                                 craplft.dtmvtolt = craplot.dtmvtolt AND
                                 craplft.cdagenci = craplot.cdagenci AND
                                 craplft.cdbccxlt = craplot.cdbccxlt AND
                                 craplft.nrdolote = craplot.nrdolote
                                 USE-INDEX craplft1 NO-LOCK:

                            ASSIGN aux_vlrtotal = craplft.vllanmto + 
                                                  craplft.vlrjuros + 
                                                  craplft.vlrmulta.

                            RUN gera_tt-histor 
                                ( INPUT par_cdcooper,
                                  INPUT craplft.cdhistor,         
                                  INPUT aux_vlrtotal,      
                                  INPUT "", /*dsdcompl*/
                                  INPUT craplft.tpfatura, /*PARAMETRO PASSADO APENAS NESSA SITUACAO*/
                                  INPUT-OUTPUT aux_flgouthi,
                                  INPUT-OUTPUT aux_vlrttctb,
                                  INPUT-OUTPUT aux_qtrttctb,
                                  INPUT-OUTPUT aux_vlarccon,
                                  INPUT-OUTPUT aux_qtarccon,
                                  INPUT-OUTPUT aux_vlarcdar,
                                  INPUT-OUTPUT aux_qtarcdar,
                                  INPUT-OUTPUT aux_vlarcgps,
                                  INPUT-OUTPUT aux_qtarcgps,
                                  INPUT-OUTPUT aux_vlarcnac,
                                  INPUT-OUTPUT aux_qtarcnac,
                                  INPUT-OUTPUT aux_vldepsup,
                                  INPUT-OUTPUT aux_qtdepsup,
                                  INPUT-OUTPUT aux_vldepinf,
                                  INPUT-OUTPUT aux_qtdepinf,
                                  INPUT-OUTPUT aux_vldepcop,
                                  INPUT-OUTPUT aux_qtdepcop,
                                  INPUT-OUTPUT aux_vldepout,
                                  INPUT-OUTPUT aux_qtdepout,
                                  INPUT 9).

                        END. /* FOR EACH craplft */

                    END. /* FOR EACH craplot  */

                    FOR EACH craplot WHERE 
                             craplot.cdcooper = par_cdcooper       AND
                             craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                             craplot.cdagenci = crapbcx.cdagenci   AND
                             craplot.cdbccxlt = 11                 AND
                             craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                             craplot.cdopecxa = crapbcx.cdopecxa   AND
                             craplot.tplotmov = 21
                             NO-LOCK:

                        FOR EACH craptit WHERE 
                                 craptit.cdcooper = par_cdcooper     AND
                                 craptit.dtmvtolt = craplot.dtmvtolt AND
                                 craptit.cdagenci = craplot.cdagenci AND
                                 craptit.cdbccxlt = craplot.cdbccxlt AND
                                 craptit.nrdolote = craplot.nrdolote
                                 USE-INDEX craptit1 NO-LOCK:

                            RUN gera_tt-histor 
                                ( INPUT par_cdcooper,
                                  INPUT 373,
                                  INPUT craptit.vldpagto,
                                  INPUT "", /*dsdcompl*/
                                  INPUT 0, /*tpfatura*/
                                  INPUT-OUTPUT aux_flgouthi,
                                  INPUT-OUTPUT aux_vlrttctb,
                                  INPUT-OUTPUT aux_qtrttctb,
                                  INPUT-OUTPUT aux_vlarccon,
                                  INPUT-OUTPUT aux_qtarccon,
                                  INPUT-OUTPUT aux_vlarcdar,
                                  INPUT-OUTPUT aux_qtarcdar,
                                  INPUT-OUTPUT aux_vlarcgps,
                                  INPUT-OUTPUT aux_qtarcgps,
                                  INPUT-OUTPUT aux_vlarcnac,
                                  INPUT-OUTPUT aux_qtarcnac,
                                  INPUT-OUTPUT aux_vldepsup,
                                  INPUT-OUTPUT aux_qtdepsup,
                                  INPUT-OUTPUT aux_vldepinf,
                                  INPUT-OUTPUT aux_qtdepinf,
                                  INPUT-OUTPUT aux_vldepcop,
                                  INPUT-OUTPUT aux_qtdepcop,
                                  INPUT-OUTPUT aux_vldepout,
                                  INPUT-OUTPUT aux_qtdepout,
                                  INPUT 9).

                        END. /* FOR EACH craptit */

                    END. /* FOR EACH craplot */

                END. /* IF   craphis.nmestrut = "craplft" */
            ELSE
            IF  craphis.nmestrut = "craptit" AND 
                craphis.cdhistor = 713 THEN        /* Titulos outros bancos */
                DO:
                    FOR EACH craplot WHERE 
                             craplot.cdcooper = par_cdcooper       AND
                             craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                             craplot.cdagenci = crapbcx.cdagenci   AND
                             craplot.cdbccxlt = 11                 AND
                             craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                             craplot.cdopecxa = crapbcx.cdopecxa   AND
                             craplot.tplotmov = 20
                             NO-LOCK:

                        FOR EACH craptit WHERE 
                                 craptit.cdcooper = par_cdcooper     AND
                                 craptit.dtmvtolt = craplot.dtmvtolt AND
                                 craptit.cdagenci = craplot.cdagenci AND
                                 craptit.cdbccxlt = craplot.cdbccxlt AND
                                 craptit.nrdolote = craplot.nrdolote AND
                                 craptit.intitcop = 0
                                 USE-INDEX craptit1 NO-LOCK:

                            ASSIGN aux_vlrttctb = aux_vlrttctb + 
                                                               craptit.vldpagto
                                   aux_qtrttctb = aux_qtrttctb + 1.

                        END. /* FOR EACH craptit */

                    END. /* FOR EACH craplot */

                END. /* IF   craphis.nmestrut = "craptit" */
            ELSE
            IF  craphis.nmestrut = "craptit" AND 
                craphis.cdhistor = 751 THEN        /* Titulos Cooperativa   */
                DO:
                    FOR EACH craplot WHERE 
                             craplot.cdcooper = par_cdcooper       AND
                             craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                             craplot.cdagenci = crapbcx.cdagenci   AND
                             craplot.cdbccxlt = 11                 AND
                             craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                             craplot.cdopecxa = crapbcx.cdopecxa   AND
                             craplot.tplotmov = 20
                             NO-LOCK:

                        FOR EACH craptit WHERE 
                                 craptit.cdcooper = par_cdcooper     AND
                                 craptit.dtmvtolt = craplot.dtmvtolt AND
                                 craptit.cdagenci = craplot.cdagenci AND
                                 craptit.cdbccxlt = craplot.cdbccxlt AND
                                 craptit.nrdolote = craplot.nrdolote AND
                                 craptit.intitcop = 1
                                 USE-INDEX craptit1 NO-LOCK:

                            ASSIGN aux_vlrttctb = 
                                                aux_vlrttctb + craptit.vldpagto
                                   aux_qtrttctb = aux_qtrttctb + 1.
                        END. /* FOR EACH craptit */

                    END. /* FOR EACH craplot */
                    
                END. /* IF   craphis.nmestrut = "craptit" */
            ELSE
            IF  craphis.nmestrut = "crapchd" THEN  /*  Cheques capturados  */
                DO:
                    FOR EACH craplot WHERE 
                             craplot.cdcooper = par_cdcooper       AND
                             craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                             craplot.cdagenci = crapbcx.cdagenci   AND
                            (craplot.cdbccxlt = 11                 OR
                             craplot.cdbccxlt = 500)               AND
                             craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                             craplot.cdopecxa = crapbcx.cdopecxa   AND
                            (craplot.tplotmov = 1                  OR
                             craplot.tplotmov = 23                 OR
                             craplot.tplotmov = 29) NO-LOCK:

                        FOR EACH crapchd WHERE 
                                 crapchd.cdcooper = par_cdcooper     AND
                                 crapchd.dtmvtolt = craplot.dtmvtolt AND
                                 crapchd.cdagenci = craplot.cdagenci AND
                                 crapchd.cdbccxlt = craplot.cdbccxlt AND
                                 crapchd.nrdolote = craplot.nrdolote AND
                                 crapchd.inchqcop = 0
                                 USE-INDEX crapchd3 NO-LOCK:

                            IF  crapchd.cdbccxlt = 500 THEN
                                ASSIGN aux_vlroti14 = 
                                                aux_vlroti14 + crapchd.vlcheque
                                       aux_qtroti14 = aux_qtroti14 + 1.
                            ELSE
                                DO:
                                    IF  crapchd.nrdolote > 30000 AND
                                        crapchd.nrdolote < 30999 THEN
                                        ASSIGN aux_vllanchq = aux_vllanchq +
                                                               crapchd.vlcheque
                                               aux_qtlanchq = aux_qtlanchq + 1.
                                    ELSE
                                        ASSIGN aux_vlrttctb = aux_vlrttctb +
                                                               crapchd.vlcheque
                                               aux_qtrttctb = aux_qtrttctb + 1.
                                END.

                        END. /* FOR EACH crapchd */

                    END. /* FOR EACH craplot */

                END. /* IF   craphis.nmestrut = "crapchd" */
            ELSE
            /****** lancamentos extra-sistema *******/
            IF  craphis.nmestrut = "craplcx" THEN
                DO:
                    FOR EACH craplcx WHERE 
                             craplcx.cdcooper = par_cdcooper      AND
                             craplcx.dtmvtolt = crapbcx.dtmvtolt  AND
                             craplcx.cdagenci = crapbcx.cdagenci  AND
                             craplcx.nrdcaixa = crapbcx.nrdcaixa  AND
                             craplcx.cdopecxa = crapbcx.cdopecxa
                             USE-INDEX craplcx1 NO-LOCK:

                        IF  craplcx.cdhistor <> craphis.cdhistor THEN
                            NEXT.
                        IF  craphis.indcompl <> 0 THEN
                            RUN gera_tt-histor 
                                ( INPUT par_cdcooper,
                                  INPUT craplcx.cdhistor,
                                  INPUT craplcx.vldocmto,
                                  INPUT craplcx.dsdcompl,
                                  INPUT 0, /*tpfatura*/
                                  INPUT-OUTPUT aux_flgouthi,
                                  INPUT-OUTPUT aux_vlrttctb,
                                  INPUT-OUTPUT aux_qtrttctb,
                                  INPUT-OUTPUT aux_vlarccon,
                                  INPUT-OUTPUT aux_qtarccon,
                                  INPUT-OUTPUT aux_vlarcdar,
                                  INPUT-OUTPUT aux_qtarcdar,
                                  INPUT-OUTPUT aux_vlarcgps,
                                  INPUT-OUTPUT aux_qtarcgps,
                                  INPUT-OUTPUT aux_vlarcnac,
                                  INPUT-OUTPUT aux_qtarcnac,
                                  INPUT-OUTPUT aux_vldepsup,
                                  INPUT-OUTPUT aux_qtdepsup,
                                  INPUT-OUTPUT aux_vldepinf,
                                  INPUT-OUTPUT aux_qtdepinf,
                                  INPUT-OUTPUT aux_vldepcop,
                                  INPUT-OUTPUT aux_qtdepcop,
                                  INPUT-OUTPUT aux_vldepout,
                                  INPUT-OUTPUT aux_qtdepout,
                                  INPUT 9).
                        ELSE
                            ASSIGN aux_vlrttctb = aux_vlrttctb + 
                                                               craplcx.vldocmto
                                   aux_qtrttctb = aux_qtrttctb + 1.

                    END. /* FOR EACH craplcx */                  

                END. /* IF   craphis.nmestrut = "craplcx" */
            ELSE
            IF  craphis.nmestrut = "craptvl" THEN
                DO:                

                    FOR EACH craplot WHERE 
                             craplot.cdcooper = par_cdcooper       AND
                             craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                             craplot.cdagenci = crapbcx.cdagenci   AND
                             craplot.cdbccxlt = 11                 AND
                             craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                             craplot.cdopecxa = crapbcx.cdopecxa   AND
                             craplot.tplotmov = craphis.tplotmov
                             NO-LOCK:

                        FOR EACH craptvl WHERE 
                                 craptvl.cdcooper = par_cdcooper     AND
                                 craptvl.dtmvtolt = craplot.dtmvtolt AND
                                 craptvl.cdagenci = craplot.cdagenci AND
                                 craptvl.cdbccxlt = craplot.cdbccxlt AND
                                 craptvl.nrdolote = craplot.nrdolote
                                 USE-INDEX craptvl2 NO-LOCK:

                            ASSIGN aux_vlrttctb = aux_vlrttctb + 
                                                               craptvl.vldocrcb
                                   aux_qtrttctb = aux_qtrttctb + 1.

                        END. /* FOR EACH craptvl */

                    END. /* FOR EACH craplot */

                END. /* IF   craphis.nmestrut = "craptvl" */
            ELSE
                DO:
                    ASSIGN aux_flgsemhi = YES.
                    LEAVE Imprime.
                END.
            /*** tratamento para historico 717-arrecadacoes ******/
            IF  craphis.cdhistor = 717    AND
                (aux_vlrttctb <> 0        OR
                aux_vlarcgps <> 0)       THEN
                DO:
                    IF  NOT par_tipconsu AND
                        LINE-COUNTER(str_1) > 76 THEN
                        PAGE STREAM str_1.

                    FOR EACH tt-histor NO-LOCK BY tt-histor.cdhistor:

                        FIND crabhis WHERE crabhis.cdcooper = par_cdcooper AND
                                           crabhis.cdhistor = tt-histor.cdhistor
                                           NO-LOCK NO-ERROR.

                        IF  craphis.indebcre = "C" THEN
                        DO:
                            ASSIGN aux_vlrttcrd = aux_vlrttcrd + tt-histor.vllanmto.
                        END.
                        ELSE
                            ASSIGN aux_vlrttdeb = aux_vlrttdeb + tt-histor.vllanmto.
                             
                        
                        IF  crabhis.tpctbcxa = 2 THEN
                            ASSIGN aux_nrctadeb = crapage.cdcxaage
                                   aux_nrctacrd = crabhis.nrctacrd.
                        ELSE
                        IF  crabhis.tpctbcxa = 3 THEN
                            ASSIGN aux_nrctacrd = crapage.cdcxaage
                                   aux_nrctadeb = crabhis.nrctadeb.
                        ELSE
                            ASSIGN aux_nrctacrd = crabhis.nrctacrd
                                   aux_nrctadeb = crabhis.nrctadeb.

                        ASSIGN aux_cdhistor = crabhis.cdhstctb
                               aux_vlrttctb = tt-histor.vllanmto
                               aux_vlarctot = aux_vlarctot + tt-histor.vllanmto.
                         
                        /*Tramento feito para identificar se e Convenio, DARF, GPS
                          ou Simples Nacional*/
                        
                        IF  par_tipconsu AND
                            LINE-COUNTER(str_1) = 80 THEN
                            PAGE STREAM str_1.

                    END. /* FOR EACH tt-histor */
                    
                    /*Contabiliza os valores do GPS ao total das arrecadacoes e também 
                      neste momento no total de creditos pois ele nao e contabilizado 
                      junto aos outros*/
                    ASSIGN aux_qtrttctb = aux_qtrttctb + aux_qtarcgps
                           aux_vlarctot = aux_vlarctot + aux_vlarcgps   
                           aux_vlrttcrd = aux_vlrttcrd + aux_vlarcgps.
                    
                    /*Cabecalho juntamente com o TOTAL das arrecadacoes*/
                    ASSIGN aux_deshi717 = TRIM(craphis.dshistor) + FILL(" ",12) + 
                                          "(" + STRING(aux_qtrttctb,"zz,zz9") + ") " +
                                          FILL(".",25) + " : " + STRING(aux_vlarctot,"zzz,zzz,zz9.99-").
                                          
                    DISPLAY STREAM str_1
                        WITH FRAME f_linha_branco.
                    DOWN STREAM str_1 WITH FRAME f_linha_branco.       

                    DISPLAY STREAM str_1 
                        aux_deshi717 WITH FRAME f_descricao_717.
                    DOWN STREAM str_1 WITH FRAME f_descricao_717.
                    
                    /*CONVENIO*/
                    ASSIGN aux_dsarecad = "  CONVENIO" + 
                                           FILL(" ",15) + 
                                           "(" + STRING(aux_qtarccon,"zz,zz9") + ")  " +
                                           FILL(".",9)
                            aux_vlarecad = aux_vlarccon.
                    
                    DISPLAY STREAM str_1
                        aux_dsarecad aux_vlarecad   
                        WITH FRAME f_tot_arc_boletim.
                    DOWN STREAM str_1 WITH FRAME f_tot_arc_boletim.
                    
                    /*DARF*/
                    ASSIGN aux_dsarecad = "  DARF" + 
                                           FILL(" ",19) + 
                                           "(" + STRING(aux_qtarcdar,"zz,zz9") + ")  " +
                                           FILL(".",9)
                            aux_vlarecad = aux_vlarcdar.
                    
                    DISPLAY STREAM str_1
                        aux_dsarecad aux_vlarecad   
                        WITH FRAME f_tot_arc_boletim.
                    DOWN STREAM str_1 WITH FRAME f_tot_arc_boletim.
                    
                    /*GPS*/
                    ASSIGN aux_dsarecad = "  GPS" + 
                                           FILL(" ",20) + 
                                           "(" + STRING(aux_qtarcgps,"zz,zz9") + ")  " +
                                           FILL(".",9)
                            aux_vlarecad = aux_vlarcgps.
                    
                    DISPLAY STREAM str_1
                        aux_dsarecad aux_vlarecad   
                        WITH FRAME f_tot_arc_boletim.
                    DOWN STREAM str_1 WITH FRAME f_tot_arc_boletim.
                    
                    /*SIMPLES NACIONAL*/
                    ASSIGN aux_dsarecad = "  SIMPLES NACIONAL" + 
                                           FILL(" ",7) + 
                                           "(" + STRING(aux_qtarcnac,"zz,zz9") + ")  " +
                                           FILL(".",9)
                            aux_vlarecad = aux_vlarcnac.
                    
                    DISPLAY STREAM str_1
                        aux_dsarecad aux_vlarecad   
                        WITH FRAME f_tot_arc_boletim.
                    DOWN STREAM str_1 WITH FRAME f_tot_arc_boletim.
                    
                END. /* FIM tratamento para historico 717-arrecadacoes */  

            /****** tratamento para os outros tipos de historicos ******/
            IF  craphis.cdhistor <> 717   AND
                craphis.cdhistor <> 561   AND
               (aux_vlrttctb <> 0         OR
                aux_vllanchq <> 0         OR
                aux_vlroti14 <> 0)        THEN
                DO:
                    IF  aux_vllanchq > 0 THEN
                        ASSIGN aux_vlrttdeb = aux_vlrttdeb + aux_vllanchq.

                    IF  aux_vlroti14 > 0 THEN
                        ASSIGN aux_vlrttdeb = aux_vlrttdeb + aux_vlroti14.

                    IF  craphis.indebcre = "C" THEN
                        ASSIGN aux_vlrttcrd = aux_vlrttcrd + aux_vlrttctb.
                    ELSE
                        ASSIGN aux_vlrttdeb = aux_vlrttdeb + aux_vlrttctb.
                    
                    IF  craphis.tpctbcxa = 2 THEN
                        ASSIGN aux_nrctadeb = crapage.cdcxaage
                               aux_nrctacrd = craphis.nrctacrd.
                    ELSE
                    IF  craphis.tpctbcxa = 3 THEN
                       ASSIGN aux_nrctacrd = crapage.cdcxaage
                              aux_nrctadeb = craphis.nrctadeb.
                    ELSE
                        ASSIGN aux_nrctacrd = craphis.nrctacrd
                               aux_nrctadeb = craphis.nrctadeb.

                    ASSIGN aux_cdhistor = craphis.cdhstctb.

                    IF  aux_vllanchq > 0 THEN
                        DO:

                           ASSIGN aux_descrctb = 
                                            TRIM(SUBSTR(craphis.dshistor,1,16))
                                                                + "(ROTINA 66)"
                                            SUBSTR(aux_descrctb,length(
                                                             aux_descrctb) + 2,
                                            (24 - length(aux_descrctb) - 1)) =
                                        FILL(".",24 - length(aux_descrctb) - 1)

                                  aux_descrctb = SUBSTRING(aux_descrctb,1,24) +
                                    "(" + STRING(aux_qtlanchq, "zz,zz9") + ") ".

                           DISPLAY STREAM str_1
                               WITH FRAME f_linha_branco.
                           DOWN STREAM str_1 WITH FRAME f_linha_branco.       

                           DISPLAY STREAM str_1
                               aux_descrctb aux_vllanchq @ aux_vlrttctb
                               WITH FRAME f_ctb_boletim.

                           DOWN STREAM str_1 WITH FRAME f_ctb_boletim.

                           IF  NOT par_tipconsu AND
                               LINE-COUNTER(str_1) = 80   THEN
                               PAGE STREAM str_1.

                           ASSIGN aux_vllanchq = 0
                                  aux_qtlanchq = 0.
                       END.

                    IF  aux_vlroti14 > 0 THEN
                        DO:
                            ASSIGN aux_descrctb = 
                            TRIM(SUBSTR(craphis.dshistor,1,16)) + "(ROTINA 14)"
                                  SUBSTR(aux_descrctb,length(aux_descrctb) + 2,
                                            (24 - length(aux_descrctb) - 1)) =
                                       FILL(".",24 - length(aux_descrctb) - 1)

                                   aux_descrctb = SUBSTRING(aux_descrctb,1,24) +
                                     "(" + STRING(aux_qtroti14, "zz,zz9") + ") ".

                            DISPLAY STREAM str_1
                                WITH FRAME f_linha_branco.
                            DOWN STREAM str_1 WITH FRAME f_linha_branco.       

                            DISPLAY STREAM str_1
                                aux_descrctb aux_vlroti14 @ aux_vlrttctb
                                WITH FRAME f_ctb_boletim.

                            DOWN STREAM str_1 WITH FRAME f_ctb_boletim.

                            IF  NOT par_tipconsu AND
                                LINE-COUNTER(str_1) = 80 THEN
                                PAGE STREAM str_1.

                            ASSIGN aux_vlroti14 = 0
                                   aux_qtroti14 = 0.
                        END.

                    
                    ASSIGN aux_descrctb = TRIM(SUBSTRING(craphis.dshistor,1,24))
                           SUBSTR(aux_descrctb,LENGTH(aux_descrctb) + 2,
                                     (24 - LENGTH(aux_descrctb) - 1)) =
                                        FILL(" ",24 - LENGTH(aux_descrctb) - 1)

                            aux_descrctb = SUBSTRING(aux_descrctb,1,24) + 
                                    "(" + STRING(aux_qtrttctb, "zz,zz9") + ") " + FILL(".",26) + " :" .

                    /*Titulos Eletr*/
                    IF craphis.cdhistor = 713 THEN 
                       DO:
                          /*Se for historico 713 guarda os valores totais na variavel
                            para quando chegar no historico 751 somar e ter um total dos dois
                            historicos.*/
                          ASSIGN aux_vltittot = aux_vlrttctb
                                 aux_qttittot = aux_qtrttctb.
                          
                          FOR EACH craplot WHERE craplot.cdcooper = par_cdcooper     AND
                                                 craplot.dtmvtolt = crapbcx.dtmvtolt AND
                                                 craplot.cdagenci = crapbcx.cdagenci AND
                                                 craplot.cdbccxlt = 11               AND
                                                 craplot.nrdcaixa = crapbcx.nrdcaixa AND
                                                 craplot.cdopecxa = crapbcx.cdopecxa  AND
                                                 craplot.tplotmov = 20 NO-LOCK:

                             FIND FIRST craptit WHERE craptit.cdcooper = craplot.cdcooper AND
                                                      craptit.dtmvtolt = craplot.dtmvtolt AND
                                                      craptit.cdagenci = craplot.cdagenci AND
                                                      craptit.cdbccxlt = craplot.cdbccxlt AND
                                                      craptit.nrdolote = craplot.nrdolote AND
                                                      craptit.intitcop = 1
                                                      USE-INDEX craptit1 NO-ERROR.

                             
                             /*Faz o find na tit para validar se retorna algo,
                               caso nao encontrar deve dar display apenas do historico 713*/
                             IF NOT AVAIL craptit THEN
                                   ASSIGN aux_flg713ti = YES. 
                          
                          END.        
                          
                          /*Nao encontrou registros para o historico 751*/
                          IF aux_flg713ti THEN
                             DO:
                                ASSIGN aux_flg713ti = NO
                                       aux_descrctb = TRIM(SUBSTRING("TITULOS",1,24))
                                                      SUBSTR(aux_descrctb,LENGTH(aux_descrctb) + 2,
                                                            (24 - LENGTH(aux_descrctb) - 1)) =
                                                            FILL(" ",24 - LENGTH(aux_descrctb) - 1)
                                       aux_descrctb = SUBSTRING(aux_descrctb,1,24) + 
                                                      "(" + STRING(aux_qtrttctb, "zz,zz9") + ") " 
                                                      + FILL(".",26) + " :" .   

                             END.
                          ELSE
                             /*Passa para o proximo historico*/
                             NEXT.
                       END.
                    ELSE
                       DO:
                          /*Titulos Coop*/
                          IF craphis.cdhistor = 751 THEN
                             DO:
                                /*Nesse momento somo o total desse historico (751) com o valor
                                 do historico 713 armazenado em cima.*/
                                ASSIGN aux_vlrttctb = aux_vlrttctb + aux_vltittot 
                                       aux_qtrttctb = aux_qtrttctb + aux_qttittot 
                                       aux_descrctb = TRIM(SUBSTRING("TITULOS",1,24))
                                                      SUBSTR(aux_descrctb,LENGTH(aux_descrctb) + 2,
                                                            (24 - LENGTH(aux_descrctb) - 1)) =
                                                            FILL(" ",24 - LENGTH(aux_descrctb) - 1)
                            aux_descrctb = SUBSTRING(aux_descrctb,1,24) + 
                                                      "(" + STRING(aux_qtrttctb, "zz,zz9") + ") " 
                                                      + FILL(".",26) + " :" .                                    
                             END.
                       END.
                    

                    DISPLAY STREAM str_1
                        WITH FRAME f_linha_branco.

                    DOWN STREAM str_1 WITH FRAME f_linha_branco.       

                    DISPLAY STREAM str_1
                        aux_descrctb aux_vlrttctb
                        WITH FRAME f_ctb_boletim.
                    DOWN STREAM str_1 WITH FRAME f_ctb_boletim.

                    IF  NOT par_tipconsu AND
                        LINE-COUNTER(str_1) = 80 THEN
                        PAGE STREAM str_1.

                    IF  aux_flgouthi THEN
                        DO:
                           IF CAN-DO("715",STRING(craphis.cdhistor)) THEN
                              DO:
                                 /*DEP. CHQ. SUPERIOR*/
                                 ASSIGN aux_deschist = "DEP. CHQ. SUPERIOR" + 
                                        FILL(" ",5) + 
                                        "(" + STRING(aux_qtdepsup,"zz,zz9") + ")  " +
                                        FILL(".",9)   
                                        aux_vlrtthis = aux_vldepsup.
                                        
                                 DISPLAY STREAM str_1
                                    aux_deschist aux_vlrtthis 
                                    WITH FRAME f_his_boletim.
                                 DOWN STREAM str_1 WITH FRAME f_his_boletim.
                                       
                                 IF  NOT par_tipconsu AND
                                     LINE-COUNTER(str_1) = 80 THEN
                                     PAGE STREAM str_1.

                                 /*DEP. CHQ. INFERIOR*/
                                 ASSIGN aux_deschist = "DEP. CHQ. INFERIOR" + 
                                        FILL(" ",5) + 
                                        "(" + STRING(aux_qtdepinf,"zz,zz9") + ")  " +
                                        FILL(".",9)   
                                        aux_vlrtthis = aux_vldepinf.

                                 DISPLAY STREAM str_1
                                    aux_deschist aux_vlrtthis 
                                    WITH FRAME f_his_boletim.
                                 DOWN STREAM str_1 WITH FRAME f_his_boletim.
                                    
                                 IF  NOT par_tipconsu AND
                                     LINE-COUNTER(str_1) = 80 THEN
                                     PAGE STREAM str_1.
                                     
                                 /*DEP. CHQ. COOP.*/
                                 ASSIGN aux_deschist = "DEP. CHQ. COOP." + 
                                        FILL(" ",8) + 
                                        "(" + STRING(aux_qtdepcop,"zz,zz9") + ")  " +
                                        FILL(".",9)   
                                        aux_vlrtthis = aux_vldepcop.

                                        DISPLAY STREAM str_1
                                            aux_deschist aux_vlrtthis 
                                            WITH FRAME f_his_boletim.
                                            DOWN STREAM str_1 WITH FRAME f_his_boletim.
                                         
                                        IF  NOT par_tipconsu AND
                                            LINE-COUNTER(str_1) = 80 THEN
                                            PAGE STREAM str_1.
                             
                                 /*OUTROS*/
                                 ASSIGN aux_deschist = "OUTROS" + 
                                        FILL(" ",17) + 
                                        "(" + STRING(aux_qtdepout,"zz,zz9") + ")  " +
                                        FILL(".",9)   
                                        aux_vlrtthis = aux_vldepout.

                                 DISPLAY STREAM str_1
                                    aux_deschist aux_vlrtthis 
                                    WITH FRAME f_his_boletim.
                                 DOWN STREAM str_1 WITH FRAME f_his_boletim.

                                 IF  NOT par_tipconsu AND
                                     LINE-COUNTER(str_1) = 80 THEN
                                     PAGE STREAM str_1.

                              END.
                           ELSE
                    DO:
                                 FOR EACH tt-histor NO-LOCK BY tt-histor.cdhistor:
                                
                                    ASSIGN aux_deschist = ""
                                           aux_vlrtthis = tt-histor.vllanmto.

                                    IF  craphis.nmestrut <> "craplcx" THEN DO:                                 
                                        ASSIGN aux_deschist = STRING(tt-histor.cdhistor,"9999") + "-" +  
                                               STRING(tt-histor.dshistor,"x(18)") + "(" +
                                               STRING(tt-histor.qtlanmto, "zz,zz9") + ") "
                                               SUBSTR(aux_deschist,length(aux_deschist) + 2,
                                               (41 - LENGTH(aux_deschist) - 1)) =
                                               FILL(".",41 - LENGTH(aux_deschist) - 1).                                   
											     
										DISPLAY STREAM str_1
											aux_deschist aux_vlrtthis 
											WITH FRAME f_his_boletim.
										DOWN STREAM str_1 WITH FRAME f_his_boletim.

                        IF  NOT par_tipconsu AND
											LINE-COUNTER(str_1) = 80 THEN
                            PAGE STREAM str_1.

										IF tt-histor.qtlanmto-recibo > 0 THEN
										DO:
											ASSIGN aux_deschist = ""
											   aux_vlrtthis = tt-histor.vllanmto-recibo.

											ASSIGN aux_deschist = 
											   "   RECIBO              "  + "(" +
											   STRING(tt-histor.qtlanmto-recibo, "zz,zz9") + ") " +
											   " .........".
                        DISPLAY STREAM str_1 
												aux_deschist aux_vlrtthis 
												WITH FRAME f_his_boletim.
												DOWN STREAM str_1 WITH FRAME f_his_boletim.
                        
											IF  tt-histor.qtlanmto-recibo > 0 AND
													LINE-COUNTER(str_1) = 80 THEN
													PAGE STREAM str_1.
										END.
										IF tt-histor.qtlanmto-cartao > 0 THEN
										DO:
											ASSIGN aux_deschist = ""
											   aux_vlrtthis = tt-histor.vllanmto-cartao.

											ASSIGN aux_deschist = 
											   "   CARTAO              "  + "(" +
											   STRING(tt-histor.qtlanmto-cartao, "zz,zz9") + ") " +
											   " .........".

											DISPLAY STREAM str_1
												aux_deschist aux_vlrtthis 
												WITH FRAME f_his_boletim.
												DOWN STREAM str_1 WITH FRAME f_his_boletim.
                            
											IF  tt-histor.qtlanmto-cartao > 0 AND
													LINE-COUNTER(str_1) = 80 THEN
													PAGE STREAM str_1.
										END.
									END.
									ELSE DO:

                                        ASSIGN aux_deschist = 
                                            SUBSTR(tt-histor.dsdcompl,1,40) 
                                        SUBSTR(aux_deschist,LENGTH(aux_deschist) + 2,
                                            (44 - LENGTH(aux_deschist) - 1)) =
                                            FILL(".",44 - LENGTH(aux_deschist) - 1).

                            DISPLAY STREAM str_1  
                                            aux_deschist aux_vlrtthis 
                                            WITH FRAME f_his_boletim.
                                            DOWN STREAM str_1 WITH FRAME f_his_boletim.

                                        IF  NOT par_tipconsu AND
                                LINE-COUNTER(str_1) = 80 THEN
                                PAGE STREAM str_1.
                                    END.

                        END. /* FOR EACH tt-histor */
						      END.	
                        END. /* IF  aux_flgouthi */

                END. /* FIM tratamento para os outros tipos de historicos */

                IF  craphis.cdhistor = 561    AND
                   (aux_vlrttctb <> 0         OR
                    aux_vllanchq <> 0         OR
                    aux_vlroti14 <> 0)        THEN 
                    DO:
                        
                        ASSIGN aux_descrctb = 
                                         TRIM(SUBSTRING(craphis.dshistor,1,24))
                             SUBSTR(aux_descrctb,length(aux_descrctb) + 2,(24 -
                                                   LENGTH(aux_descrctb) - 1)) =
                                        FILL(".",24 - length(aux_descrctb) - 1)
                            aux_descrctb = SUBSTRING(aux_descrctb,1,24) + "(" +
                                          STRING(aux_qtrttctb, "zz,zz9") + ") ".

                        DISPLAY STREAM str_1 WITH FRAME f_linha_branco.

                        DISPLAY STREAM str_1
                            aux_descrctb aux_vlrttctb
                            WITH FRAME f_ctb_boletim.
                        DOWN STREAM str_1 WITH FRAME f_ctb_boletim.

                        FOR EACH tt-empresa NO-LOCK:

                            FIND crapemp WHERE 
                                 crapemp.cdcooper = par_cdcooper AND
                                 crapemp.cdempres = tt-empresa.cdempres NO-LOCK.

                            ASSIGN aux_vlrtthis = tt-empresa.vllanmto
                                   aux_deschist = 
                                    STRING(tt-empresa.cdempres,"99999")  + "-" +
                                    STRING(crapemp.nmresemp,"x(18)")  + "(" +
                                    STRING(tt-empresa.qtlanmto, "zz,zz9") + ") "
                                   SUBSTR(aux_deschist,length(aux_deschist) + 2,
                                             (41 - LENGTH(aux_deschist) - 1)) =
                                       FILL(".",41 - length(aux_deschist) - 1).
                            
                            DISPLAY STREAM str_1 aux_deschist aux_vlrtthis 
                                WITH FRAME f_his_boletim.

                            DOWN STREAM str_1 WITH FRAME f_his_boletim.
                            
                        END. /* FOR EACH tt-empresa */

                    END. /* IF  LAST-OF(craphis.cdhistor)  */

                IF  LAST-OF(craphis.indebcre) THEN
                    DO:
                        IF  craphis.indebcre = "C" THEN
                            DO:
                                VIEW STREAM str_1 FRAME f_saidas_boletim.

                                IF  NOT par_tipconsu AND
                                    LINE-COUNTER(str_1) > 80 THEN
                                    PAGE STREAM str_1.
                            END.
                        ELSE
                            DO:
                                ASSIGN aux_vldsdfin = crapbcx.vldsdini +
                                       aux_vlrttcrd - aux_vlrttdeb.

                                IF  NOT par_tipconsu AND
                                    LINE-COUNTER(str_1) > 80 THEN
                                    PAGE STREAM str_1.

                                VIEW STREAM str_1 FRAME f_saldo_final.
                            END.
                    END.

        END. /* FOR EACH craphis */

        EMPTY TEMP-TABLE tt-estorno.

        FOR EACH crapaut WHERE 
                 crapaut.cdcooper = par_cdcooper     AND
                 crapaut.dtmvtolt = crapbcx.dtmvtolt AND
                 crapaut.cdagenci = crapbcx.cdagenci AND 
                 crapaut.nrdcaixa = crapbcx.nrdcaixa AND
                 crapaut.estorno  = YES NO-LOCK
                 BREAK BY crapaut.nrsequen:

            IF  FIRST(crapaut.nrsequen) THEN 
                DO:
                    DISPLAY STREAM str_1 WITH FRAME f_ini_estornos.
                    DOWN STREAM str_1 WITH FRAME f_ini_estornos.
                END.

            FIND craphis WHERE 
                 craphis.cdcooper = par_cdcooper AND
                 craphis.cdhistor = crapaut.cdhistor NO-LOCK NO-ERROR.

            ASSIGN aux_dshistor = STRING(crapaut.cdhistor,"9999") + "-".
            
            IF  AVAIL craphis THEN  
                ASSIGN aux_dshistor = aux_dshistor + craphis.dshistor.
            ELSE
                ASSIGN aux_dshistor = aux_dshistor + "***************".

            DISPLAY STREAM str_1
                crapaut.nrsequen
                aux_dshistor
                crapaut.nrdocmto
                crapaut.vldocmto
                crapaut.tpoperac
                crapaut.nrseqaut
                WITH FRAME f_estornos.

            DOWN STREAM str_1 WITH FRAME f_estornos.

            CREATE tt-estorno.
            ASSIGN tt-estorno.cdagenci = crapbcx.cdagenci    
                   tt-estorno.nrdcaixa = crapbcx.nrdcaixa     
                   tt-estorno.nrseqaut = crapaut.nrseqaut
				   tt-estorno.nrsequen = crapaut.nrsequen.

            IF  LAST(crapaut.nrsequen) THEN
                DO:
                    DISPLAY STREAM str_1 WITH FRAME f_fim_estornos.
                    DOWN STREAM str_1 WITH FRAME f_fim_estornos.
                END.

        END. /* FOR EACH crapaut */

        /*=== Historicos Dif.Caixa/Recuperacao Caixa(701/702/733/734 ===*/
        FOR EACH craplcx WHERE 
                 craplcx.cdcooper = par_cdcooper     AND
                 craplcx.cdagenci = crapbcx.cdagenci AND
                 craplcx.nrdcaixa = crapbcx.nrdcaixa AND
                 craplcx.dtmvtolt = crapbcx.dtmvtolt AND
                (craplcx.cdhistor = 701               OR
                 craplcx.cdhistor = 702               OR
                 craplcx.cdhistor = 733               OR
                 craplcx.cdhistor = 734)             NO-LOCK
                 BREAK BY craplcx.dtmvtolt
                          BY craplcx.nrautdoc:

            FIND craphis WHERE 
                 craphis.cdcooper = par_cdcooper     AND
                 craphis.cdhistor = craplcx.cdhistor NO-LOCK NO-ERROR. 

            ASSIGN aux_dshistor = STRING(craplcx.cdhistor,"9999") + "-".

            IF  AVAIL craphis THEN  
                ASSIGN aux_dshistor = aux_dshistor + craphis.dshistor.
            ELSE
                ASSIGN aux_dshistor = aux_dshistor + "***************".

            FIND crapaut WHERE 
                 crapaut.cdcooper = par_cdcooper      AND
                 crapaut.cdagenci = craplcx.cdagenci  AND
                 crapaut.nrdcaixa = craplcx.nrdcaixa  AND
                 crapaut.dtmvtolt = craplcx.dtmvtolt  AND
                 crapaut.nrsequen = craplcx.nrautdoc  NO-LOCK NO-ERROR.

            IF  FIRST-OF(craplcx.dtmvtolt) THEN  
                VIEW STREAM str_1 FRAME f_inicio_diferenca.

            IF  AVAIL crapaut THEN
                DO:
                    DISP STREAM str_1 
                        crapaut.nrsequen
                        aux_dshistor
                        craplcx.nrdocmto @ crapaut.nrdocmto
                        craplcx.vldocmto @ crapaut.vldocmto
                        crapaut.tpoperac
                        crapaut.nrseqaut
                        WITH  FRAME f_estornos.
        
                    DOWN STREAM str_1 WITH  FRAME f_estornos.
                END.

            IF  LAST-OF(craplcx.dtmvtolt) THEN  
                VIEW STREAM str_1 FRAME f_fim_diferenca.

        END. /* FIM Historicos Dif.Caixa/Recuperacao Caixa(701/702/733/734 */

        IF  NOT par_tipconsu THEN
            DO:
                IF  LINE-COUNTER(str_1) > 72 THEN
                    PAGE STREAM str_1.

                IF  crapbcx.cdsitbcx = 2   THEN
                    ASSIGN rel_dsfechad = "** BOLETIM FECHADO **".
                ELSE
                    ASSIGN rel_dsfechad = " ** BOLETIM ABERTO **".

                DISPLAY STREAM str_1 rel_dsfechad WITH FRAME f_vistos.
            END.

        /*  Historicos transitados no gerenciador financeiro - Edson */
        IF  crapbcx.cdsitbcx = 2 AND 
           (par_cdcooper     = 1  OR        /* para a Viacredi */
            par_cdcooper     = 2) THEN      /* para a Creditextil */
            DO:

                FOR EACH crapaut WHERE 
                         crapaut.cdcooper = par_cdcooper       AND
                         crapaut.dtmvtolt = crapbcx.dtmvtolt   AND
                         crapaut.cdagenci = crapbcx.cdagenci   AND
                         crapaut.nrdcaixa = crapbcx.nrdcaixa   AND
                         CAN-DO("707,708,747",STRING(crapaut.cdhistor))
                         NO-LOCK BREAK BY crapaut.nrsequen:


                    IF  FIRST(crapaut.nrsequen) THEN 
                        DO:
                            PAGE STREAM str_1.

                            DISPLAY STREAM str_1
                            "DOCUMENTOS TRANSITADOS VIA GERENCIADOR FINANCEIRO"
                                SKIP(1)
                                WITH NO-BOX COLUMN aux_nrcoluna
                                NO-LABELS WIDTH 76 FRAME f_cab_gerfin.
                        END.

                    FIND tt-estorno WHERE
                         tt-estorno.cdagenci = crapbcx.cdagenci AND
                         tt-estorno.nrdcaixa = crapbcx.nrdcaixa AND
                         tt-estorno.nrseqaut = crapaut.nrsequen 
                         NO-LOCK NO-ERROR.

                    IF  NOT AVAIL tt-estorno THEN
                        DO:
                            IF  NOT crapaut.estorno THEN
                                DO:
                                    FIND craphis WHERE
                                         craphis.cdcooper = par_cdcooper AND
                                         craphis.cdhistor = crapaut.cdhistor
                                         NO-LOCK NO-ERROR.

                                    ASSIGN aux_dshistor = 
                                         STRING(crapaut.cdhistor,"9999") + "-".

                                    IF  AVAIL craphis   THEN  
                                        ASSIGN aux_dshistor = aux_dshistor + 
                                                              craphis.dshistor.
                                    ELSE
                                        ASSIGN aux_dshistor = aux_dshistor + 
                                                             "***************".

                                    ASSIGN tot_qtgerfin = tot_qtgerfin + 1
                                           tot_vlgerfin = tot_vlgerfin +
                                                              crapaut.vldocmto.

                                    DISPLAY STREAM str_1
                                        crapaut.nrsequen   aux_dshistor
                                        crapaut.nrdocmto   crapaut.vldocmto
                                        aux_dsdtraco WITH FRAME f_gerfin.

                                    DOWN 2 STREAM str_1 WITH FRAME f_gerfin.

                                    IF  NOT par_tipconsu AND
                                        LINE-COUNTER(str_1) = 80 THEN
                                        DO:
                                            PAGE STREAM str_1.

                                            DISPLAY STREAM str_1
                            "DOCUMENTOS TRANSITADOS VIA GERENCIADOR FINANCEIRO"
                                            SKIP(1)
                                            WITH NO-BOX COLUMN aux_nrcoluna
                                         NO-LABELS WIDTH 76 FRAME f_cab_gerfin.
                                        END.

                                END. /* IF  NOT crapaut.estorno */

                        END. /* IF  NOT AVAIL tt-estorno */

                    IF  LAST(crapaut.nrsequen) THEN
                        DO:
                            DISPLAY STREAM str_1
                                "T O T A I S ===>" AT  1
                                tot_qtgerfin       AT 41 FORMAT "zz,zz9"
                                tot_vlgerfin       AT 48 FORMAT "zzzz,zzz.99"
                                SKIP
                                WITH NO-BOX COLUMN aux_nrcoluna
                                    NO-LABELS WIDTH 76 FRAME f_total_gerfin.
                            
                            DISPLAY STREAM str_1 WITH FRAME f_fim_estornos.
                            
                            DOWN STREAM str_1 WITH FRAME f_fim_estornos.
                        END.

                END.  /*  Fim do FOR EACH -- crapaut  */


                IF  NOT par_tipconsu THEN
                    DO:
                        IF  LINE-COUNTER(str_1) > 72 THEN
                            PAGE STREAM str_1.
    
                        IF  crapbcx.cdsitbcx = 2 THEN
                            ASSIGN rel_dsfechad = "** BOLETIM FECHADO **".
                        ELSE
                            ASSIGN rel_dsfechad = " ** BOLETIM ABERTO **".
    
                        DISPLAY STREAM str_1 rel_dsfechad WITH FRAME f_vistos.
                    END.

            END. /* FIM - Historicos transitados no gerenciador financeiro */
        
        OUTPUT STREAM str_1 CLOSE.

        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:
                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.

                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE Imprime.
                    END.

                RUN envia-arquivo-web IN h-b1wgen0024 
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT aux_nmarqimp,
                     OUTPUT aux_nmarqpdf,
                     OUTPUT TABLE tt-erro ).

                IF  VALID-HANDLE(h-b1wgen0024)  THEN
                    DELETE PROCEDURE h-b1wgen0024.

                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".
            END.
        ELSE 
            DO:
               IF  NOT par_tipconsu     AND  
                       par_idorigem = 2 AND /*Caixa online*/
                       (par_nmdatela = "CRAP012" OR
					    par_nmdatela = "CRAP013") /*Fechamento do caixa*/ THEN 
                  DO:
                     IF crapope.dsimpres = "" THEN
                        DO:                          
                           ASSIGN aux_dscritic = "Registro de impressora nao encontrado para o Operador".
                           LEAVE Imprime.            
                        END.
                     
                     
                     
                     ASSIGN aux_nrdevias   = 1
                            aux_nmdafila = LC(crapope.dsimpres). 
                            aux_dscomand = "lp -d " + aux_nmdafila +
                                           " -n " + STRING(aux_nrdevias) +   
                                           " -oMTl88 " + aux_nmarqimp + 
                                           " 2> /dev/null".
                     
                     UNIX SILENT VALUE(aux_dscomand).
                    
                  END.
            END.    


        ASSIGN aux_returnvl = "OK".

        LEAVE Imprime.

    END. /*Imprime*/
    
    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END. /* Gera_Boletim */

PROCEDURE Gera_Termo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ndrrecid AS RECID                          NO-UNDO.
    DEF  INPUT PARAM par_nrdlacre AS INTE                           NO-UNDO.
    
    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabbcx FOR crapbcx.

    DEF VAR ant_nrdlacre AS INTE    FORMAT "z,zzz,zz9"              NO-UNDO.
    DEF VAR aux_lintrac1 AS CHAR    FORMAT "x(80)"                  NO-UNDO. 
    DEF VAR aux_lintrac2 AS CHAR    FORMAT "x(48)"                  NO-UNDO.
    DEF VAR aux_lintrac3 AS CHAR    FORMAT "x(80)"                  NO-UNDO.
    DEF VAR aux_lintrac4 AS CHAR    FORMAT "x(65)"                  NO-UNDO.

    FORM "REFERENCIA:" crapbcx.dtmvtolt 
     "** TERMO DE ABERTURA **" AT 29 
     SKIP(1)
     "PA:" crapbcx.cdagenci "-" crapage.nmresage
     "OPERADOR:" crapbcx.cdopecxa "-" crapope.nmoperad  FORMAT "x(25)" 
     SKIP(1)
     "CAIXA:" crapbcx.nrdcaixa "AUTENTICADORA:" AT 21 crapbcx.nrdmaqui
     "LACRE ANTERIOR:" AT 56 ant_nrdlacre
     SKIP(1)
     aux_lintrac1 FORMAT "x(80)"
     SKIP(1)
     "SALDO INICIAL" aux_lintrac2 FORMAT "x(48)" ":" crapbcx.vldsdini
      SKIP(1)
      aux_lintrac3 FORMAT "x(80)"
      SKIP(1)
      "VISTOS: "
      SKIP(4)
      SPACE(10) "------------------------------"
      SPACE(6)  "------------------------------"
      SKIP   
      SPACE(17) "OPERADOR         " SPACE(22) "RESPONSAVEL"
      SKIP(3)
      SPACE(51) "AUTENTICACAO MECANICA"
      SKIP(4)
      "---<Corte aqui>" SPACE(0) aux_lintrac4 FORMAT "x(65)"
     WITH NO-BOX COLUMN 1 NO-LABELS  FRAME f_termo.

    EMPTY TEMP-TABLE tt-erro.

    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
    
        FOR FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crapcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" +
                              par_dsiduser.

        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".

        IF  CAN-DO("C,S",par_cddopcao) THEN
            DO: 
                FIND LAST crabbcx WHERE 
                          crabbcx.cdcooper = par_cdcooper     AND
                          crabbcx.dtmvtolt = par_dtmvtolt     AND
                          crabbcx.cdagenci = crapbcx.cdagenci AND
                          crabbcx.nrdcaixa = crapbcx.nrdcaixa AND
                          crabbcx.cdsitbcx = 2 /* fechado */
                          USE-INDEX crapbcx1 NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crabbcx THEN
                    FIND LAST crabbcx WHERE 
                              crabbcx.cdcooper = par_cdcooper     AND 
                              crabbcx.dtmvtolt < par_dtmvtolt     AND 
                              crabbcx.cdagenci = crapbcx.cdagenci AND
                              crabbcx.nrdcaixa = crapbcx.nrdcaixa AND
                              crabbcx.cdsitbcx = 2 /* fechado */   
                              USE-INDEX crapbcx1 NO-LOCK NO-ERROR.

                ASSIGN ant_nrdlacre = IF AVAIL crabbcx THEN 
                                         crabbcx.nrdlacre
                                      ELSE 0.
            END. /* IF  par_cddopcao = "C" */
        ELSE
        IF  par_cddopcao = "I" THEN
            ASSIGN ant_nrdlacre = par_nrdlacre.

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

        /* Cdempres = 11 , Relatorio 258 em 80 colunas */
        { sistema/generico/includes/b1cabrel080.i "11" "258" }  
        
        /*  Configura a impressora para 1/8"  */
        PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
        
        PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

        FIND crapbcx WHERE RECID(crapbcx) = par_ndrrecid NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapbcx THEN
            DO:
                ASSIGN aux_cdcritic = 90.
                LEAVE Imprime.
            END.

        FIND crapage WHERE 
             crapage.cdcooper = par_cdcooper     AND
             crapage.cdagenci = crapbcx.cdagenci NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapage THEN
            DO:
                ASSIGN aux_cdcritic = 962.
                LEAVE Imprime.
            END.

        FIND crapope WHERE 
             crapope.cdcooper = par_cdcooper     AND
             crapope.cdoperad = crapbcx.cdopecxa NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapope THEN
            DO:
                ASSIGN aux_cdcritic = 702.
                LEAVE Imprime.
            END.

        ASSIGN aux_lintrac1 = FILL("=",80)
               aux_lintrac2 = FILL(".",48)
               aux_lintrac3 = FILL("-",80)
               aux_lintrac4 = FILL("-",65).

        DISPLAY STREAM str_1
                crapbcx.dtmvtolt 
                crapbcx.cdagenci 
                crapage.nmresage
                crapbcx.cdopecxa
                crapope.nmoperad
                crapbcx.nrdcaixa
                crapbcx.nrdmaqui
                ant_nrdlacre
                aux_lintrac1
                aux_lintrac2
                crapbcx.vldsdini
                aux_lintrac3
                aux_lintrac4
                WITH FRAME f_termo.
        DOWN STREAM str_1 WITH FRAME f_termo.        
        PAGE STREAM str_1.

        OUTPUT STREAM str_1 CLOSE.
        
        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:
                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.

                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE Imprime.
                    END.
            
                RUN envia-arquivo-web IN h-b1wgen0024 
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT aux_nmarqimp,
                     OUTPUT aux_nmarqpdf,
                     OUTPUT TABLE tt-erro ).

                IF  VALID-HANDLE(h-b1wgen0024)  THEN
                    DELETE PROCEDURE h-b1wgen0024.

                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Imprime.

    END. /*Imprime*/
    
    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END. /* Gera_Termo */

PROCEDURE Gera_Fita_Caixa:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ndrrecid AS RECID                          NO-UNDO.
    DEF  INPUT PARAM par_tipconsu AS LOGI                           NO-UNDO.
    
    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_vlrttcrd AS DECI    FORMAT "zzz,zzz,zz9.99-"        NO-UNDO.
    DEF VAR aux_flgsemhi AS LOGI                                    NO-UNDO.
    DEF VAR aux_dtmvtolt AS DATE    FORMAT "99/99/9999"             NO-UNDO.
    DEF VAR aux_cdagenci AS INT                                     NO-UNDO.
    DEF VAR aux_cdopecxa AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdcaixa AS INT                                     NO-UNDO.
    DEF VAR aux_hrautent AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmdmeses AS CHAR                                    NO-UNDO.
    DEF VAR aux_vllanmto AS CHAR                                    NO-UNDO.
    DEF VAR aux_blidenti AS CHAR                                    NO-UNDO.
    DEF VAR aux_bltotpag LIKE crapaut.bltotpag                      NO-UNDO.
    DEF VAR aux_bltotrec LIKE crapaut.bltotrec                      NO-UNDO.
    DEF VAR aux_blsldini LIKE crapaut.blsldini                      NO-UNDO.
    DEF VAR aux_blvalrec LIKE crapaut.blvalrec                      NO-UNDO.
    DEF VAR aux_blideimp LIKE crapaut.blidenti                      NO-UNDO.
    DEF VAR aux_prmregip AS LOGICAL INITIAL YES                     NO-UNDO.
    DEF VAR aux_vldsdfin LIKE crapbcx.vldsdfin                      NO-UNDO.
    DEF VAR aux_sdfinbol LIKE crapbcx.vldsdfin                      NO-UNDO.
    DEF VAR aux_vlrttdeb AS DECI                                    NO-UNDO.
    
    DEF VAR aux_dshistor AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdocmto AS CHAR                                    NO-UNDO.
    
    DEF VAR aux_vlchqcmp AS DECIMAL                                 NO-UNDO.
    DEF VAR aux_qtchqcmp AS INT                                     NO-UNDO.
    
    DEF VAR aux_vlroti14 AS DECIMAL                                 NO-UNDO.
    DEF VAR aux_qtroti14 AS INT                                     NO-UNDO.
    
    DEF VAR aux_dsidenti AS CHAR FORMAT "x(49)"                     NO-UNDO.

    DEF VAR rel_dsfechad AS CHAR                                    NO-UNDO.
    DEF VAR rel_dtmvtolt LIKE crapbcx.dtmvtolt                      NO-UNDO.
    DEF VAR rel_nmresage AS CHAR                                    NO-UNDO.
    DEF VAR rel_cdagenci LIKE crapbcx.cdagenci                      NO-UNDO.
    DEF VAR rel_cdopecxa LIKE crapbcx.cdopecxa                      NO-UNDO. 
    DEF VAR rel_nmoperad LIKE crapope.nmoperad                      NO-UNDO.
    DEF VAR rel_nrdcaixa LIKE crapbcx.nrdcaixa                      NO-UNDO. 
    DEF VAR rel_nrdmaqui like crapbcx.nrdmaqui                      NO-UNDO.
    DEF VAR rel_nrdlacre like crapbcx.nrdlacre                      NO-UNDO.
    DEF VAR rel_vldsdini LIKE crapbcx.vldsdini                      NO-UNDO.
    DEF VAR rel_qtautent LIKE crapbcx.qtautent                      NO-UNDO.

    DEF VAR aux_flgouthi AS LOGICAL                                 NO-UNDO.
    DEF VAR aux_opcimpri AS LOGICAL                                 NO-UNDO.
    DEF VAR aux_qtrttctb AS INT                                     NO-UNDO.

    FORM HEADER
     "REFERENCIA:" rel_dtmvtolt 
     SKIP(1)
     "PA:" rel_cdagenci FORMAT "ZZ9" "-" rel_nmresage FORMAT "x(18)" SPACE(1)
     "OPERADOR:" rel_cdopecxa FORMAT "x(10)" "-" rel_nmoperad  FORMAT "x(20)"
     SKIP(1)
     "CAIXA:" rel_nrdcaixa FORMAT "ZZ9" "AUTENTICADORA:" AT 16 rel_nrdmaqui
     FORMAT "ZZ9" "QTD. AUT.:" AT 39 rel_qtautent "LACRE:" AT 61 rel_nrdlacre
     SKIP(1)
     FILL("=",128)  FORMAT "x(128)"
     SKIP(1)
     WITH NO-BOX COLUMN aux_nrcoluna
          NO-LABELS PAGE-TOP WIDTH 128 FRAME f_cabec_boletim.
     
    FORM HEADER     
         "SALDO INICIAL" FILL(".",96) FORMAT "x(96)" ":" rel_vldsdini
         SKIP(1)
         FILL("-",128) FORMAT "x(128)"
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 128 FRAME f_inicio_boletim.
     
    FORM HEADER
         "SALDO FINAL" FILL(".",98) FORMAT "x(98)" ":"
         aux_vldsdfin  FORMAT "zzz,zzz,zz9.99-" SKIP(1)
         FILL("=",128) FORMAT "x(128)"
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 128 FRAME f_saldo_final.
     
    FORM HEADER
         FILL("-",128) FORMAT "x(128)" SKIP
         WITH NO-BOX COLUMN aux_nrcoluna DOWN WIDTH 128 FRAME f_traco.

    FORM  SKIP(1)
          "VISTOS: "  
          rel_dsfechad AT 108 FORMAT "x(21)" NO-LABEL
          SKIP(4)
          "----------------------------"
          "----------------------------"
          "----------------------------"
          "-----------------------------"
          SKIP   
          SPACE(12) "CAIXA" SPACE(21) "COORDENADOR" SPACE(18) "TESOURARIA"
          SPACE(18) "CONTABILIDADE"
          WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 128 FRAME f_vistos .
    
    FORM HEADER 
         "AUTE          VALOR OP         HORA DESCRICAO" SPACE(39)
         "PAGO    RECEBIDO    DINHEIRO       TROCO"
         SKIP(1)
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 128 PAGE-TOP 
              FRAME f_label_bl.

    FORM HEADER 
         "AUTE          VALOR OP         HORA DESCRICAO" SPACE(30)
         "PAGO       RECEBIDO       DINHEIRO         TROCO"
         SKIP(1)
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 128  
              FRAME f_label_bl1.
    
    FORM cratfit.nrsequen cratfit.vllanmto cratfit.tpoperac
         "==>"
         aux_hrautent 
         aux_dshistor FORMAT "x(28)"
         cratfit.bltotpag FORMAT "-zz,zzz,zz9.99"
         cratfit.bltotrec FORMAT "-zz,zzz,zz9.99"
         cratfit.blsldini FORMAT "-zz,zzz,zz9.99"
         cratfit.blvalrec FORMAT "zz,zzz,zz9.99-"
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS DOWN WIDTH 128 FRAME f_fita_1.
    
    FORM "Inicio do BL: " cratfit.blidenti SKIP(1)
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS DOWN WIDTH 128 FRAME f_inicio_bl.
    
    FORM " Final do BL: " aux_blidenti FORMAT "x(40)"
         SKIP(1)
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS DOWN WIDTH 128 FRAME f_final_bl.
    
    FORM "          BL: " cratfit.blidenti FORMAT "x(10)" 
         "     Pago: "   cratfit.bltotpag FORMAT "-zzz,zz9.99"
         "  Recebido: "  cratfit.bltotrec FORMAT "-zzz,zz9.99"
         SKIP SPACE(23)
         "    Dinheiro: "   cratfit.blsldini FORMAT "-zzz,zz9.99"
         "     Troco: "  cratfit.blvalrec FORMAT "-zzz,zz9.99"
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS DOWN WIDTH 128 FRAME f_bl.

    FORM cratfit.blidenti AT 63 FORMAT "x(66)"
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS DOWN WIDTH 128 FRAME f_fita_2.
    
    FORM aux_dsdocmto AT 28 FORMAT "x(49)"
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS DOWN WIDTH 128 FRAME f_fita_3.
    
    FORM SKIP(1)
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 128 FRAME f_linha_branco.

    ASSIGN aux_nmdmeses = "JAN,FEV,MAR,ABR,MAI,JUN,JUL,AGO,SET,OUT,NOV,DEZ".
    
    EMPTY TEMP-TABLE tt-erro.

    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:

        RUN Gera_Boletim( INPUT par_cdcooper,       
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_idorigem,
                          INPUT par_nmdatela,
                          INPUT par_dtmvtolt,       
                          INPUT par_dsiduser,
                          INPUT YES, /* tipconsu */
                          INPUT par_ndrrecid,
                         OUTPUT aux_flgsemhi,
                         OUTPUT aux_sdfinbol,
                         OUTPUT aux_vlrttcrd,
                         OUTPUT aux_vlrttdeb,
                         OUTPUT aux_nmarqimp,
                         OUTPUT aux_nmarqpdf,
                         OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Imprime.

        FOR FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crapcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" +
                              par_dsiduser.
                
        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".
        
        IF  NOT par_tipconsu THEN
            DO:
                OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
                
                /* Cdempres = 11 , Relatorio 282 em 132 colunas */
                { sistema/generico/includes/cabrel.i "11" "282" "132" } 
               
                /*  Configura a impressora para 1/8" - 17cpi */
                PUT STREAM str_1 CONTROL "\022\024\017" NULL.

                PUT STREAM str_1 CONTROL "\0330\033x0" NULL.
            END.
        ELSE
            DO:
                /* visualiza nao pode ter caracteres de controle */
                OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp). 
            END.
        
        FIND crapbcx WHERE RECID(crapbcx) = par_ndrrecid NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapbcx THEN
            DO:
                ASSIGN aux_cdcritic = 11.
                LEAVE Imprime.
            END.

        FIND crapage WHERE 
             crapage.cdcooper = par_cdcooper     AND
             crapage.cdagenci = crapbcx.cdagenci NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapage THEN
            DO:
                ASSIGN aux_cdcritic = 962.
                LEAVE Imprime.
            END.

        FIND crapope WHERE 
             crapope.cdcooper = par_cdcooper     AND
             crapope.cdoperad = crapbcx.cdopecxa NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapope THEN
            DO:
                ASSIGN aux_cdcritic = 702.
                LEAVE Imprime.
            END.

        ASSIGN rel_dtmvtolt = crapbcx.dtmvtolt 
               rel_cdagenci = crapbcx.cdagenci
               rel_nmresage = crapage.nmresage
               rel_cdopecxa = crapbcx.cdopecxa 
               rel_nmoperad = crapope.nmoperad
               rel_nrdcaixa = crapbcx.nrdcaixa
               rel_nrdmaqui = crapbcx.nrdmaqui
               rel_qtautent = crapbcx.qtautent
               rel_nrdlacre = crapbcx.nrdlacre
               rel_vldsdini = crapbcx.vldsdini
               aux_vldsdfin = crapbcx.vldsdini
               aux_flgsemhi = NO
               aux_vlchqcmp = 0.
            
        VIEW STREAM str_1 FRAME f_cabec_boletim.
        
        VIEW STREAM str_1 FRAME f_inicio_boletim.
                                  
        VIEW STREAM str_1 FRAME f_label_bl1.

        EMPTY TEMP-TABLE cratfit.

        FOR EACH crapaut WHERE 
                 crapaut.cdcooper = par_cdcooper     AND
                 crapaut.cdagenci = crapbcx.cdagenci AND
                 crapaut.nrdcaixa = crapbcx.nrdcaixa AND
                 crapaut.dtmvtolt = crapbcx.dtmvtolt NO-LOCK:   

            /*Se for agendamento GPS nao entra na fita de caixa */
            IF  crapaut.dslitera matches "*AGENDAMENTO GPS*" THEN
                NEXT.

            /* Identificado */
            CREATE cratfit.
            ASSIGN cratfit.nrsequen = crapaut.nrsequen
                   cratfit.nrdconta = crapaut.nrdconta
                   cratfit.nrdocmto = crapaut.nrdocmto
                   cratfit.vllanmto = crapaut.vldocmto
                   cratfit.hrautent = crapaut.hrautent
                   cratfit.blidenti = CAPS(crapaut.blidenti)
                   cratfit.bltotpag = crapaut.bltotpag
                   cratfit.bltotrec = crapaut.bltotrec
                   cratfit.blsldini = crapaut.blsldini
                   cratfit.blvalrec = crapaut.blvalrec
                   cratfit.cdhistor = IF crapaut.cdhistor = 386
                                         THEN 21
                                         ELSE crapaut.cdhistor
                   cratfit.tpoperac = crapaut.tpoperac
                   cratfit.estorno  = crapaut.estorno
                   cratfit.nrseqaut = crapaut.nrseqaut
                   cratfit.dsidenve = crapaut.dslitera
                   cratfit.dsdocmto = IF crapaut.cdhistor = 386
                                         THEN "Cheque recebido em deposito"
                                         ELSE ""
                   cratfit.tplotmov = 0.

            IF  crapaut.dtmvtolt < 07/27/2001 THEN
                
                ASSIGN cratfit.dslitera = SUBSTR(crapaut.dslitera,
                                          LENGTH(TRIM(crapaut.dslitera)) - 47, 48).
            ELSE
                ASSIGN cratfit.dslitera = SUBSTR(crapaut.dslitera,1,47).

            IF  NOT cratfit.tpoperac THEN
                IF  cratfit.estorno THEN
                    ASSIGN aux_vldsdfin = aux_vldsdfin - cratfit.vllanmto.
                ELSE     
                    ASSIGN aux_vldsdfin = aux_vldsdfin + cratfit.vllanmto.
            ELSE
                IF  cratfit.estorno   THEN
                    ASSIGN aux_vldsdfin = aux_vldsdfin + cratfit.vllanmto.
                ELSE
                    ASSIGN aux_vldsdfin = aux_vldsdfin - cratfit.vllanmto.

        END.  /*  Fim do FOR EACH -- Leitura do crapaut  */
        
        FOR EACH craplot WHERE 
                 craplot.cdcooper = par_cdcooper     AND
                 craplot.dtmvtolt = crapbcx.dtmvtolt AND
                 craplot.cdagenci = crapbcx.cdagenci AND
                (craplot.cdbccxlt = 11               OR
                 craplot.cdbccxlt = 500)             AND
                 craplot.nrdcaixa = crapbcx.nrdcaixa AND
                 craplot.cdopecxa = crapbcx.cdopecxa AND
                (craplot.tplotmov = 1                OR
                 craplot.tplotmov = 23)              NO-LOCK:

            FOR EACH crapchd WHERE 
                     crapchd.cdcooper = par_cdcooper      AND
                     crapchd.dtmvtolt = craplot.dtmvtolt  AND
                     crapchd.cdagenci = craplot.cdagenci  AND
                     crapchd.cdbccxlt = craplot.cdbccxlt  AND
                     crapchd.nrdolote = craplot.nrdolote  AND
                     crapchd.inchqcop = 0                 NO-LOCK
                     USE-INDEX crapchd3:

                IF  crapchd.nrdolote > 30000 AND
                    crapchd.nrdolote < 30999 THEN
                    NEXT.

                IF  craplot.cdbccxlt = 500 THEN
                    ASSIGN aux_vlroti14 = aux_vlroti14 + crapchd.vlcheque
                           aux_qtroti14 = aux_qtroti14 + 1.
                ELSE
                    ASSIGN aux_vlchqcmp = aux_vlchqcmp + crapchd.vlcheque
                           aux_qtchqcmp = aux_qtchqcmp + 1.

            END.  /*  Fim do FOR EACH -- Leitura do crapchd  */

        END.  /*  Fim do FOR EACH -- Leitura do craplot  */

        IF  aux_vlroti14 > 0 THEN
            DO:
                
                CREATE cratfit.
                ASSIGN cratfit.nrsequen = 9998
                       cratfit.nrdconta = 0
                       cratfit.nrdocmto = 0
                       cratfit.vllanmto = aux_vlroti14
                       cratfit.hrautent = IF  crapbcx.hrfecbcx > 0 THEN
                                              crapbcx.hrfecbcx
                                          ELSE TIME
                       cratfit.blidenti = "BL: "
                       cratfit.cdhistor = 731
                       cratfit.tpoperac = TRUE
                       cratfit.estorno  = FALSE
                       cratfit.dsdocmto = "Qtd. de cheques recebidos pela " +
                                  "ROTINA 14: " + STRING(aux_qtroti14,"zz,zz9")
                       cratfit.tplotmov = 22

                       aux_vllanmto     = "*" + TRIM(STRING(cratfit.vllanmto,
                                                "zzz,zzz,zzz,zz9.99"))         
                       aux_vldsdfin = aux_vldsdfin - cratfit.vllanmto.

                IF  crapbcx.dtmvtolt < 04/25/2012  THEN
                    ASSIGN cratfit.dslitera = STRING(crapcop.dssigaut,"x(4)") +
                                              " 9999 "                        +
                                           STRING(DAY(crapbcx.dtmvtolt),"99") +
                                              ENTRY(MONTH(crapbcx.dtmvtolt),
                                                                aux_nmdmeses) +
                                              SUBSTR(STRING(
                                                 YEAR(crapbcx.dtmvtolt)),3,2) +
                                          FILL(" ",22 - LENGTH(aux_vllanmto)) +
                                              aux_vllanmto + "PG "            +
                                          STRING(crapbcx.nrdcaixa,"99") + " " +
                                          STRING(crapbcx.cdagenci,"999").
                ELSE
                    ASSIGN cratfit.dslitera = STRING(crapcop.cdbcoctl, "999") +
                                             STRING(crapcop.cdagectl, "9999") +
                                             STRING(crapage.cdagenci, "999")  +
                                             STRING(crapbcx.nrdcaixa, "99")   +
                                             "      "                         +
                                             " "                              +
                                           STRING(DAY(crapbcx.dtmvtolt),"99") +
                                        STRING(MONTH(crapbcx.dtmvtolt), "99") +
                                              SUBSTR(STRING(
                                                 YEAR(crapbcx.dtmvtolt)),3,2) +
                                             "      "                         +
                                             "*"                              +
                                             STRING(aux_vllanmto, 
                                                    "zzz,zzz,zz9.99")         +
                                             "PG".

                                             

            END.

        IF  aux_vlchqcmp > 0 THEN
            DO:
                CREATE cratfit.
                ASSIGN cratfit.nrsequen = 9999
                       cratfit.nrdconta = 0
                       cratfit.nrdocmto = 0
                       cratfit.vllanmto = aux_vlchqcmp
                       cratfit.hrautent = IF crapbcx.hrfecbcx > 0
                                             THEN crapbcx.hrfecbcx
                                             ELSE TIME
                       cratfit.blidenti = "BL: "
                       cratfit.cdhistor = 731
                       cratfit.tpoperac = TRUE
                       cratfit.estorno  = FALSE
                       cratfit.dsdocmto = "Qtd. de cheques recebidos: " +
                                          STRING(aux_qtchqcmp,"zz,zz9")
                       cratfit.tplotmov = 22 
        
                       aux_vllanmto     = "*" + TRIM(STRING(cratfit.vllanmto,
                                                         "zzz,zzz,zzz,zz9.99"))
                       aux_vldsdfin = aux_vldsdfin - cratfit.vllanmto.

                IF  crapbcx.dtmvtolt < 04/25/2012  THEN
                    ASSIGN cratfit.dslitera = STRING(crapcop.dssigaut,"x(4)") +
                                                                     " 9999 " +
                                           STRING(DAY(crapbcx.dtmvtolt),"99") +
                                           ENTRY(MONTH(crapbcx.dtmvtolt),
                                                                aux_nmdmeses) +
                                           SUBSTR(STRING(
                                                 YEAR(crapbcx.dtmvtolt)),3,2) +
                                          FILL(" ",22 - LENGTH(aux_vllanmto)) +
                                          aux_vllanmto + "PG " +
                                          STRING(crapbcx.nrdcaixa,"99") + " " +
                                          STRING(crapbcx.cdagenci,"999").
                ELSE
                    ASSIGN cratfit.dslitera = STRING(crapcop.cdbcoctl, "999") +
                                             STRING(crapcop.cdagectl, "9999") +
                                             STRING(crapage.cdagenci, "999")  +
                                             STRING(crapbcx.nrdcaixa, "99")   +
                                             "      "                         +
                                             " "                              +
                                           STRING(DAY(crapbcx.dtmvtolt),"99") +
                                        STRING(MONTH(crapbcx.dtmvtolt), "99") +
                                              SUBSTR(STRING(
                                                 YEAR(crapbcx.dtmvtolt)),3,2) +
                                             "      "                         +
                                             "*"                              +
                                             STRING(aux_vllanmto, 
                                                    "zzz,zzz,zz9.99")         +
                                             "PG".

            END.

        IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
            RUN sistema/generico/procedures/b1wgen9999.p
                PERSISTENT SET h-b1wgen9999.

        /*  Incluindo lotes que foram gerados pelo caixa off-line  */
        FOR EACH craplot WHERE 
                 craplot.cdcooper = par_cdcooper AND
                 craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                 craplot.cdagenci = crapbcx.cdagenci   AND
                 craplot.cdbccxlt = 11                 AND
                 craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                 craplot.cdopecxa = crapbcx.cdopecxa   NO-LOCK:

            RUN critica_numero_lote IN h-b1wgen9999 
                ( INPUT par_cdcooper,
                  INPUT 0, /* agenci */
                  INPUT 0, /* caixa  */
                  INPUT craplot.nrdolote,
                 OUTPUT TABLE tt-erro).

            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    EMPTY TEMP-TABLE tt-erro.
                    NEXT.
                END.

            IF  craplot.tplotmov <> 6   AND 
                craplot.tplotmov <> 12  AND 
                craplot.tplotmov <> 17  AND
                craplot.nrdolote > 5999 AND
                craplot.nrdolote < 7000 THEN
                NEXT.

            IF  craplot.tplotmov = 6     AND
               (craplot.nrdolote < 6000  OR
                craplot.nrdolote > 6499) THEN
                NEXT.

            IF  craplot.vlcompcr <> 0 THEN
                DO:
                    CREATE cratfit.
                    ASSIGN cratfit.nrsequen = 9998
                           cratfit.nrdconta = 0
                           cratfit.nrdocmto = 0
                           cratfit.vllanmto = craplot.vlcompcr
                           cratfit.hrautent = IF crapbcx.hrfecbcx > 0
                                                 THEN crapbcx.hrfecbcx
                                              ELSE TIME
                           cratfit.blidenti = "BL: "
                           cratfit.cdhistor = 703
                           cratfit.tpoperac = FALSE
                           cratfit.estorno  = FALSE
                           cratfit.dsdocmto = "Doctos do CAIXA OFF-LINE"
                           cratfit.tplotmov = 22
        
                           aux_vllanmto   = "*" + TRIM(STRING(craplot.vlcompcr,
                                                        "zzz,zzz,zzz,zz9.99"))
                           aux_vldsdfin = aux_vldsdfin + cratfit.vllanmto.

                    IF  crapbcx.dtmvtolt < 04/25/2012  THEN
                        ASSIGN cratfit.dslitera =
                                   STRING(crapcop.dssigaut,"x(4)") + " 9999 " +
                                   STRING(DAY(craplot.dtmvtolt),"99") +
                                  ENTRY(MONTH(craplot.dtmvtolt),aux_nmdmeses) +
                                   SUBSTR(STRING(YEAR(craplot.dtmvtolt)),3,2) +
                                   FILL(" ",22 - LENGTH(aux_vllanmto)) +
                                   aux_vllanmto + "RC " +
                                   STRING(crapbcx.nrdcaixa,"99") + " " +
                                   STRING(crapbcx.cdagenci,"999").
                    ELSE
                        ASSIGN cratfit.dslitera = 
                                              STRING(crapcop.cdbcoctl, "999") +
                                             STRING(crapcop.cdagectl, "9999") +
                                             STRING(crapage.cdagenci, "999")  +
                                             STRING(crapbcx.nrdcaixa, "99")   +
                                             "      "                         +
                                             " "                              +
                                           STRING(DAY(crapbcx.dtmvtolt),"99") +
                                        STRING(MONTH(crapbcx.dtmvtolt), "99") +
                                              SUBSTR(STRING(
                                                 YEAR(crapbcx.dtmvtolt)),3,2) +
                                             "      "                         +
                                             "*"                              +
                                             STRING(aux_vllanmto, 
                                                    "zzz,zzz,zz9.99")         +
                                             "RC".
                END.

            IF  craplot.vlcompdb <> 0 THEN
                DO:
                    CREATE cratfit.
                    ASSIGN cratfit.nrsequen = 9997
                           cratfit.nrdconta = 0
                           cratfit.nrdocmto = 0
                           cratfit.vllanmto = craplot.vlcompdb
                           cratfit.hrautent = IF crapbcx.hrfecbcx > 0
                                                 THEN crapbcx.hrfecbcx
                                              ELSE TIME
                           cratfit.blidenti = "BL: "
                           cratfit.cdhistor = 704
                           cratfit.tpoperac = TRUE
                           cratfit.estorno  = FALSE
                           cratfit.dsdocmto = "Doctos do CAIXA OFF-LINE"
                           cratfit.tplotmov = 22
        
                           aux_vllanmto   = "*" + TRIM(STRING(craplot.vlcompdb,
                                                         "zzz,zzz,zzz,zz9.99"))
                           aux_vldsdfin = aux_vldsdfin - cratfit.vllanmto.

                    IF  crapbcx.dtmvtolt < 04/25/2012  THEN
                        ASSIGN cratfit.dslitera =
                                   STRING(crapcop.dssigaut,"x(4)") + " 9999 " +
                                   STRING(DAY(craplot.dtmvtolt),"99") +
                                  ENTRY(MONTH(craplot.dtmvtolt),aux_nmdmeses) +
                                   SUBSTR(STRING(YEAR(craplot.dtmvtolt)),3,2) +
                                   FILL(" ",22 - LENGTH(aux_vllanmto)) +
                                   aux_vllanmto + "PG " +
                                   STRING(crapbcx.nrdcaixa,"99") + " " +
                                   STRING(crapbcx.cdagenci,"999").
                    ELSE
                        ASSIGN cratfit.dslitera = 
                                              STRING(crapcop.cdbcoctl, "999") +
                                             STRING(crapcop.cdagectl, "9999") +
                                             STRING(crapage.cdagenci, "999")  +
                                             STRING(crapbcx.nrdcaixa, "99")   +
                                             "      "                         +
                                             " "                              +
                                           STRING(DAY(crapbcx.dtmvtolt),"99") +
                                        STRING(MONTH(crapbcx.dtmvtolt), "99") +
                                              SUBSTR(STRING(
                                                 YEAR(crapbcx.dtmvtolt)),3,2) +
                                             "      "                         +
                                             "*"                              +
                                             STRING(aux_vllanmto, 
                                                    "zzz,zzz,zz9.99")         +
                                             "PG".
                END.
        END. /* FOR EACH craplot */

        IF  VALID-HANDLE(h-b1wgen9999) THEN
            DELETE PROCEDURE h-b1wgen9999.

        FOR EACH craplot WHERE 
                 craplot.cdcooper = par_cdcooper     AND
                 craplot.dtmvtolt = crapbcx.dtmvtolt AND
                 craplot.cdagenci = crapbcx.cdagenci AND
                 craplot.cdbccxlt = 11               AND
                 craplot.cdopecxa = crapbcx.cdopecxa AND
                 craplot.nrdcaixa = crapbcx.nrdcaixa NO-LOCK:

            IF  craplot.tplotmov = 1 THEN /*  Movto de Conta-corrente  */
                FOR EACH craplcm WHERE 
                         craplcm.cdcooper = par_cdcooper     AND
                         craplcm.dtmvtolt = craplot.dtmvtolt AND
                         craplcm.cdagenci = craplot.cdagenci AND
                         craplcm.cdbccxlt = craplot.cdbccxlt AND
                         craplcm.nrdolote = craplot.nrdolote 
                         USE-INDEX craplcm3 NO-LOCK:

                    FIND cratfit WHERE cratfit.nrsequen = craplcm.nrautdoc
                                       NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE cratfit THEN
                        NEXT.
                    
                    ASSIGN cratfit.nrdconta = craplcm.nrdconta
                           cratfit.tplotmov = craplot.tplotmov 
                           cratfit.dsidenti = craplcm.dsidenti.
                           
                END.  /*  Fim do FOR EACH craplcm  */
            ELSE
            IF  craplot.tplotmov = 13 THEN  /*  Arrecadacao FATURAS  */
                FOR EACH craplft WHERE 
                         craplft.cdcooper = par_cdcooper       AND
                         craplft.dtmvtolt = craplot.dtmvtolt   AND
                         craplft.cdagenci = craplot.cdagenci   AND
                         craplft.cdbccxlt = craplot.cdbccxlt   AND
                         craplft.nrdolote = craplot.nrdolote   NO-LOCK:

                    FIND cratfit WHERE cratfit.nrsequen = craplft.nrautdoc
                                                            NO-LOCK NO-ERROR.

                    IF  NOT AVAIL cratfit THEN
                        NEXT.

                    ASSIGN cratfit.dsdocmto = craplft.cdbarras
                           cratfit.tplotmov = craplot.tplotmov.

                END.  /*  Fim do FOR EACH craplft  */
            ELSE
            IF  craplot.tplotmov = 21 THEN /*  Tributos PMB  */
                FOR EACH craptit WHERE 
                         craptit.cdcooper = par_cdcooper       AND
                         craptit.dtmvtolt = craplot.dtmvtolt   AND
                         craptit.cdagenci = craplot.cdagenci   AND
                         craptit.cdbccxlt = craplot.cdbccxlt   AND
                         craptit.nrdolote = craplot.nrdolote   NO-LOCK:

                    FIND cratfit WHERE cratfit.nrsequen = craptit.nrautdoc
                                NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE cratfit THEN
                        NEXT.

                    ASSIGN cratfit.dsdocmto = craptit.dscodbar
                           cratfit.tplotmov = craplot.tplotmov.

                END.  /*  Fim do FOR EACH craplcm  */

        END. /* FOR EACH craplot */

        FOR EACH craplcx WHERE 
                 craplcx.cdcooper = par_cdcooper       AND
                 craplcx.dtmvtolt = crapbcx.dtmvtolt   AND
                 craplcx.cdagenci = crapbcx.cdagenci   AND
                 craplcx.nrdcaixa = crapbcx.nrdcaixa   AND
                 craplcx.cdopecxa = crapbcx.cdopecxa   NO-LOCK:

            FIND cratfit WHERE cratfit.nrsequen = craplcx.nrautdoc 
                               NO-LOCK NO-ERROR.

            IF  NOT AVAIL cratfit THEN
                NEXT.

            ASSIGN cratfit.dsdocmto = craplcx.dsdcompl
                   cratfit.tplotmov = 22.

        END.  /*  Fim do FOR EACH craplcx  */

        FOR EACH cratfit NO-LOCK:

            IF  aux_blidenti <> cratfit.blidenti THEN
                DO:
                    IF  aux_blidenti <> "" THEN
                        DO:
                            DISPLAY STREAM str_1
                                aux_blidenti 
                                WITH FRAME f_final_bl.
                            DOWN STREAM str_1 WITH FRAME f_final_bl. 
                            DISPLAY STREAM STR_1 WITH FRAME f_traco.
                            DOWN STREAM str_1 WITH FRAME f_traco.
                        END.

                    ASSIGN aux_blidenti = cratfit.blidenti.

                    IF  cratfit.blidenti <> ""          AND
                        TRIM(cratfit.blidenti) <> "BL:" THEN 
                        DO:
                            DISPLAY STREAM str_1
                                cratfit.blidenti WITH FRAME f_inicio_bl.
                            DOWN WITH FRAME f_inicio_bl.
                        END.
                END.

            IF  cratfit.cdhistor > 0 THEN
                DO:
                    FIND craphis NO-LOCK WHERE 
                         craphis.cdcooper = par_cdcooper     AND 
                         craphis.cdhistor = cratfit.cdhistor NO-ERROR.

                    ASSIGN aux_dshistor = STRING(craphis.cdhistor) + "-" + 
                                          craphis.dshistor + " " + 
                           (IF cratfit.cdhistor = 21
                                THEN TRIM(STRING(cratfit.nrdocmto,"zzz,zzz,9"))
                            ELSE 
                            IF cratfit.tplotmov = 23  AND
                               cratfit.cdhistor = 731 THEN
                                "- ROTINA 66" 
                                ELSE "").
                END.
            ELSE
                ASSIGN aux_dshistor = "ASSOCIACAO DE LOTE".

            ASSIGN aux_dsdocmto = "".

            IF  cratfit.estorno  THEN
                ASSIGN aux_dsdocmto = "Estorno da autenticacao nro. " +
                                      TRIM(STRING(cratfit.nrseqaut,"zzzz9")).
            ELSE                    
            IF  cratfit.tplotmov = 1    OR
                cratfit.cdhistor = 1030 OR
                cratfit.cdhistor = 22   THEN 
                DO:
                    IF  cratfit.nrdconta > 0 THEN
                        DO:
                            FIND crapass WHERE 
                                 crapass.cdcooper = par_cdcooper   AND
                                 crapass.nrdconta = cratfit.nrdconta
                                 NO-LOCK.
                            
                            IF  cratfit.cdhistor = 1009 THEN   /*** Transferencia entre cooperativas ***/
                                ASSIGN aux_dsdocmto = cratfit.dsidenti.
                            ELSE
                            IF  cratfit.cdhistor = 21  THEN
                                ASSIGN aux_dsdocmto = cratfit.dsdocmto + " Conta/dv: " + 
                                                  TRIM(STRING(cratfit.nrdconta,
                                                        "zzzz,zzz,9")) + " " +
                                                              crapass.nmprimtl.
                            ELSE
                                ASSIGN aux_dsdocmto = "Conta/dv: " + 
                                                  TRIM(STRING(cratfit.nrdconta,
                                                        "zzzz,zzz,9")) + " " +
                                                              crapass.nmprimtl.

                        END.
                    ELSE
                        ASSIGN aux_dsdocmto = cratfit.dsdocmto.
                END.
            ELSE
            IF  cratfit.tplotmov <> 13 AND
                cratfit.tplotmov <> 20 AND
                cratfit.tplotmov <> 21 THEN
                ASSIGN aux_dsdocmto = cratfit.dsdocmto.

            ASSIGN aux_hrautent = STRING(cratfit.hrautent,"HH:MM:SS").

            DISPLAY STREAM str_1 
                cratfit.nrsequen cratfit.vllanmto cratfit.tpoperac
                aux_hrautent aux_dshistor WITH FRAME f_fita_1.

            IF  cratfit.blidenti <> ""          AND
                TRIM(cratfit.blidenti) <> "BL:" THEN
                DISPLAY STREAM str_1
                    cratfit.bltotpag  cratfit.bltotrec  
                    cratfit.blsldini  cratfit.blvalrec
                    WITH FRAME f_fita_1.

            DOWN STREAM str_1 WITH FRAME f_fita_1.

            IF  TRIM(aux_dsdocmto) <> "" THEN
                DO:
                    DISPLAY STREAM str_1
                     aux_dsdocmto WITH FRAME f_fita_3.
                    
                    DOWN STREAM str_1 WITH FRAME f_fita_3.
                END.

            IF  cratfit.cdhistor = 700  AND  /* Deposito */
                cratfit.dsidenti <> " " THEN /* Identificacao de Deposito */
                DO:
                    ASSIGN aux_dsidenti = "Identificado por: " + 
                                                        TRIM(cratfit.dsidenti).

                    DISPLAY STREAM str_1
                        aux_dsidenti @ aux_dsdocmto WITH FRAME f_fita_3.

                    DOWN STREAM str_1 WITH FRAME f_fita_3.
                END.
            ELSE
                IF (cratfit.cdhistor = 700  OR cratfit.cdhistor = 1003) AND  /* Situacao de deposito entre cooperativas */
                    cratfit.dsidenve MATCHES "*Deposito de envelope*" THEN /* Identificacao de Deposito */
                    DO:
                        ASSIGN aux_dsidenti = "Identificado por: Deposito de envelope".

                        DISPLAY STREAM str_1
                                       aux_dsidenti @ aux_dsdocmto WITH FRAME f_fita_3.

                        DOWN STREAM str_1 WITH FRAME f_fita_3.
                    END.

            VIEW STREAM str_1 FRAME f_linha_branco.

            IF  aux_prmregip THEN
                ASSIGN aux_prmregip = NO.

        END. /* FOR EACH cratfit */

        VIEW STREAM str_1 FRAME f_traco.

        VIEW STREAM str_1 FRAME f_saldo_final.
        
        IF  aux_vldsdfin <> aux_sdfinbol THEN
            DISPLAY STREAM str_1
                           SKIP(2)
                           "*** ATENCAO!!!! Diferenca entre o BOLETIM"
                           "e a FITA DO CAIXA" SKIP(1)
                           "*** AVISE O Suporte CECRED ***"
                           SKIP(2)
                           WITH NO-BOX FRAME f_aviso.
        
        IF  NOT par_tipconsu THEN
            DO:
                IF  LINE-COUNTER(str_1) > 72 THEN
                    PAGE STREAM str_1.

                IF  crapbcx.cdsitbcx = 2  THEN
                    ASSIGN rel_dsfechad = "  ** CAIXA FECHADO **".
                ELSE
                    ASSIGN rel_dsfechad = "   ** CAIXA ABERTO **".

                DISPLAY STREAM str_1 rel_dsfechad WITH FRAME f_vistos.
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Imprime.

    END. /*Imprime*/

    OUTPUT STREAM str_1 CLOSE. /*tiago*/

    IF  par_idorigem = 5  THEN  /** Ayllos Web **/
        DO:
            RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                SET h-b1wgen0024.

            IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                DO:
                    ASSIGN aux_dscritic = "Handle invalido para BO " +
                                          "b1wgen0024.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.

            RUN envia-arquivo-web IN h-b1wgen0024 
                ( INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT par_nrdcaixa,
                  INPUT aux_nmarqimp,
                 OUTPUT aux_nmarqpdf,
                 OUTPUT TABLE tt-erro ).

            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.

            IF  RETURN-VALUE <> "OK" THEN
                RETURN "NOK".
        END.


    IF  TEMP-TABLE tt-erro:HAS-RECORDS OR
        aux_dscritic <> "" OR 
        aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END. /* Gera_Fita_Caixa */

PROCEDURE Gera_Depositos_Saques:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ndrrecid AS RECID                          NO-UNDO.
    DEF  INPUT PARAM par_tipconsu AS LOGI                           NO-UNDO.
    
    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR rel_dsfechad AS CHAR                                    NO-UNDO.

    DEF VAR rel_nmresage AS CHAR                                    NO-UNDO.
    DEF VAR rel_dtmvtolt LIKE crapbcx.dtmvtolt                      NO-UNDO.
    DEF VAR rel_cdagenci LIKE crapbcx.cdagenci                      NO-UNDO.
    DEF VAR rel_cdopecxa LIKE crapbcx.cdopecxa                      NO-UNDO. 
    DEF VAR rel_nmoperad LIKE crapope.nmoperad                      NO-UNDO.
    DEF VAR rel_nrdcaixa LIKE crapbcx.nrdcaixa                      NO-UNDO. 
    DEF VAR rel_nrdmaqui like crapbcx.nrdmaqui                      NO-UNDO.
    DEF VAR rel_nrdlacre like crapbcx.nrdlacre                      NO-UNDO.
    DEF VAR rel_vldsdini LIKE crapbcx.vldsdini                      NO-UNDO.
    DEF VAR rel_qtautent LIKE crapbcx.qtautent                      NO-UNDO.
    
    DEF VAR aux_vldsdfin LIKE crapbcx.vldsdfin                      NO-UNDO.
    DEF VAR aux_flgouthi AS LOGICAL                                 NO-UNDO.
    DEF VAR aux_opcimpri AS LOGICAL                                 NO-UNDO.
    
    DEF VAR aux_qtlanmto AS INT                                     NO-UNDO.
    DEF VAR aux_vllanmto AS DECIMAL                                 NO-UNDO.
    DEF VAR aux_dshistor AS CHAR                                    NO-UNDO.


    FORM HEADER
     "REFERENCIA:" rel_dtmvtolt 
     SKIP(1)
     "PA:" rel_cdagenci FORMAT "ZZ9" "-" rel_nmresage FORMAT "x(18)" SPACE(1)
     "OPERADOR:" rel_cdopecxa FORMAT "x(10)" "-" rel_nmoperad FORMAT "x(20)"
     SKIP(1)
     "CAIXA:" rel_nrdcaixa FORMAT "ZZ9" "AUTENTICADORA:" AT 16 rel_nrdmaqui
     FORMAT "ZZ9" "QTD. AUT.:" AT 39 rel_qtautent "LACRE:" AT 61 rel_nrdlacre
     SKIP(1)
     FILL("=",128)  FORMAT "x(128)"
     SKIP(1)
     WITH NO-BOX COLUMN aux_nrcoluna
          NO-LABELS PAGE-TOP WIDTH 128 FRAME f_cabec_boletim.
     
    FORM HEADER     
         "SALDO INICIAL" FILL(".",96) FORMAT "x(96)" ":" rel_vldsdini
         SKIP(1)
         FILL("-",128) FORMAT "x(128)"
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 128 FRAME f_inicio_boletim.
     
    FORM craplcm.nrdconta LABEL "CONTA/DV"  AT 10
         crapass.nmprimtl LABEL "NOME" FORMAT "x(40)"
         craplcm.nrautdoc LABEL "AUT"
         craplcm.nrdocmto LABEL "DOCUMENTO"
         craplcm.cdhistor LABEL "COD."
         craphis.dshistor LABEL "HISTORICO" FORMAT "x(15)"
         craplcm.vllanmto LABEL "VALOR"
         WITH NO-BOX COLUMN aux_nrcoluna DOWN NO-LABELS 
              WIDTH 128 FRAME f_lancamentos.

    FORM HEADER
         "SALDO FINAL" FILL(".",98) FORMAT "x(98)" ":"
         aux_vldsdfin  FORMAT "zzz,zzz,zz9.99-" SKIP(1)
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 128 FRAME f_saldo_final.
    
    FORM HEADER
         FILL("-",128) FORMAT "x(128)" SKIP
         WITH NO-BOX COLUMN aux_nrcoluna DOWN WIDTH 128 FRAME f_traco.

    FORM  SKIP(1)
          "VISTOS: "  
          rel_dsfechad AT 108 FORMAT "x(21)" NO-LABEL
          SKIP(4)
          "----------------------------"
          "----------------------------"
          "----------------------------"
          "-----------------------------"
          SKIP   
          SPACE(12) "CAIXA" SPACE(21) "COORDENADOR" SPACE(18) "TESOURARIA"
          SPACE(18) "CONTABILIDADE"
          WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 128 FRAME f_vistos .
    
    FORM SKIP(1)
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 128 FRAME f_linha_branco.
    
    FORM SKIP(1)
         "RELACAO PARA SIMPLES CONFERENCIA DOS DEPOSITOS ACOLHIDOS" AT 40
         SKIP(1)
         WITH COLUMN aux_nrcoluna NO-BOX NO-LABELS WIDTH 128 FRAME f_label_dep.

    FORM SKIP(1)
         "RELACAO PARA SIMPLES CONFERENCIA DOS SAQUES EFETUADOS" AT 40
         SKIP(1)
         WITH COLUMN aux_nrcoluna NO-BOX NO-LABELS WIDTH 128 FRAME f_label_saq.

    FORM HEADER
         FILL("=",128) FORMAT "x(128)" 
         WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 128 FRAME f_finaliza.
    
    EMPTY TEMP-TABLE tt-erro.

    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
    
        FOR FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crapcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" +
                              par_dsiduser.
        
        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".

        IF  NOT par_tipconsu THEN
            DO:
                OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

                /* Cdempres = 11 , Relatorio 282 em 132 colunas */
                { sistema/generico/includes/cabrel.i "11" "258" "132" } 

                /*  Configura a impressora para 1/8" - 17cpi */
                PUT STREAM str_1 CONTROL "\022\024\017" NULL.

                PUT STREAM str_1 CONTROL "\0330\033x0" NULL.
            END.
        ELSE
            DO:
                /* visualiza nao pode ter caracteres de controle */
                OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp). 
            END.

        FIND crapbcx WHERE RECID(crapbcx) = par_ndrrecid NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapbcx THEN
            DO:
                ASSIGN aux_cdcritic = 11.
                LEAVE Imprime.
            END.

        FIND crapage WHERE 
             crapage.cdcooper = par_cdcooper     AND
             crapage.cdagenci = crapbcx.cdagenci NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapage THEN
            DO:
                ASSIGN aux_cdcritic = 962.
                LEAVE Imprime.
            END.

        FIND crapope WHERE 
             crapope.cdcooper = par_cdcooper     AND
             crapope.cdoperad = crapbcx.cdopecxa NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapope THEN
            DO:
                ASSIGN aux_cdcritic = 702.
                LEAVE Imprime.
            END.

        ASSIGN rel_dtmvtolt = crapbcx.dtmvtolt 
               rel_cdagenci = crapbcx.cdagenci
               rel_nmresage = crapage.nmresage
               rel_cdopecxa = crapbcx.cdopecxa 
               rel_nmoperad = crapope.nmoperad
               rel_nrdcaixa = crapbcx.nrdcaixa
               rel_nrdmaqui = crapbcx.nrdmaqui
               rel_qtautent = crapbcx.qtautent
               rel_nrdlacre = crapbcx.nrdlacre
               rel_vldsdini = crapbcx.vldsdini
               aux_vldsdfin = crapbcx.vldsdfin.
        
        VIEW STREAM str_1 FRAME f_cabec_boletim.

        VIEW STREAM str_1 FRAME f_inicio_boletim.
        
        VIEW STREAM str_1 FRAME f_label_dep.

        ASSIGN aux_dshistor = "1,3,4,386,372".

        FOR EACH craplcm WHERE 
                 craplcm.cdcooper = par_cdcooper                  AND
                 craplcm.dtmvtolt = crapbcx.dtmvtolt              AND
                 craplcm.cdagenci = crapbcx.cdagenci              AND
                 craplcm.nrdolote = (11000 + crapbcx.nrdcaixa)    AND 
                 CAN-DO (aux_dshistor,STRING(craplcm.cdhistor))   NO-LOCK
                 USE-INDEX craplcm3
                 BY craplcm.nrautdoc
                        BY craplcm.nrdocmto:

            FIND craphis WHERE 
                 craphis.cdcooper = craplcm.cdcooper AND 
                 craphis.cdhistor = craplcm.cdhistor NO-LOCK NO-ERROR.
            
            FIND crapass WHERE 
                 crapass.cdcooper = par_cdcooper     AND
                 crapass.nrdconta = craplcm.nrdconta NO-LOCK NO-ERROR.
            
            DISPLAY STREAM str_1
                craplcm.nrdconta
                crapass.nmprimtl
                craplcm.nrautdoc
                craplcm.nrdocmto
                craplcm.cdhistor
                craphis.dshistor
                craplcm.vllanmto 
                WITH FRAME f_lancamentos.

            DOWN STREAM str_1 WITH FRAME f_lancamentos.
            
            IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN
                 DO:
                      VIEW STREAM str_1 FRAME f_cabec_boletim.
                 
                      VIEW STREAM str_1 FRAME f_inicio_boletim.
                      
                      VIEW STREAM str_1 FRAME f_label.
                 END.
                 
            ASSIGN aux_qtlanmto = aux_qtlanmto + 1
                   aux_vllanmto = aux_vllanmto + craplcm.vllanmto.
            
        END.  /*  Fim do FOR EACH -- craplcm  */

        DISPLAY STREAM str_1
                SKIP(1)
                aux_qtlanmto AT  10 "DEPOSITOS"
                aux_vllanmto AT 106 FORMAT "zzz,zzz,zz9.99"
                SKIP(1)
           WITH COLUMN aux_nrcoluna NO-BOX NO-LABELS WIDTH 128 FRAME f_total.

        VIEW STREAM str_1 FRAME f_traco.

        VIEW STREAM str_1 FRAME f_saldo_final.

        /********************* SAQUE ******************************/
        VIEW STREAM str_1 FRAME f_label_saq.

        ASSIGN aux_qtlanmto = 0
               aux_vllanmto = 0
               aux_dshistor = "1030".

        FOR EACH craplcm WHERE 
                 craplcm.cdcooper = par_cdcooper                  AND
                 craplcm.dtmvtolt = crapbcx.dtmvtolt              AND
                 craplcm.cdagenci = crapbcx.cdagenci              AND
                 craplcm.nrdolote = (11000 + crapbcx.nrdcaixa)    AND 
                 CAN-DO (aux_dshistor,STRING(craplcm.cdhistor))   NO-LOCK
                 USE-INDEX craplcm3
                 BY craplcm.nrautdoc
                        BY craplcm.nrdocmto:

            FIND craphis WHERE 
                 craphis.cdcooper = craplcm.cdcooper AND 
                 craphis.cdhistor = craplcm.cdhistor NO-LOCK NO-ERROR.
            
            FIND crapass WHERE 
                 crapass.cdcooper = par_cdcooper     AND
                 crapass.nrdconta = craplcm.nrdconta NO-LOCK NO-ERROR.
            
            DISPLAY STREAM str_1
                craplcm.nrdconta
                crapass.nmprimtl
                craplcm.nrautdoc
                craplcm.nrdocmto
                craplcm.cdhistor
                craphis.dshistor
                craplcm.vllanmto 
                WITH FRAME f_lancamentos.

            DOWN STREAM str_1 WITH FRAME f_lancamentos.
            
            IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN
                 DO:
                      VIEW STREAM str_1 FRAME f_cabec_boletim.
                 
                      VIEW STREAM str_1 FRAME f_inicio_boletim.
                      
                      VIEW STREAM str_1 FRAME f_label.
                 END.
                 
            ASSIGN aux_qtlanmto = aux_qtlanmto + 1
                   aux_vllanmto = aux_vllanmto + craplcm.vllanmto.
            
        END.  /*  Fim do FOR EACH -- craplcm  */

        DISPLAY STREAM str_1
                SKIP(1)
                aux_qtlanmto AT  10 "SAQUES"
                aux_vllanmto AT 106 FORMAT "zzz,zzz,zz9.99"
                SKIP(1)
           WITH COLUMN aux_nrcoluna NO-BOX NO-LABELS WIDTH 128 FRAME f_total_2.

        VIEW STREAM str_1 FRAME f_traco.

        VIEW STREAM str_1 FRAME f_finaliza.

        OUTPUT STREAM str_1 CLOSE.

        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:
                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.

                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE Imprime.
                    END.

                RUN envia-arquivo-web IN h-b1wgen0024 
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT aux_nmarqimp,
                     OUTPUT aux_nmarqpdf,
                     OUTPUT TABLE tt-erro ).

                IF  VALID-HANDLE(h-b1wgen0024)  THEN
                    DELETE PROCEDURE h-b1wgen0024.

                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Imprime.

    END. /*Imprime*/
    
    IF  TEMP-TABLE tt-erro:HAS-RECORDS OR
        aux_dscritic <> "" OR 
        aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END. /* Gera_Depositos_Saques */

/* ------------------------------------------------------------------------- */
/*                  Efetua a Validação dos dados informados                  */
/* ------------------------------------------------------------------------- */
PROCEDURE Valida_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdopecxa AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolx AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vldentra AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vldsaida AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdoplanc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqdig AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vldocmto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_msgretor AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_vlrttcrd AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM aux_vldsdfin AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM aux_nrctadeb AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM aux_nrctacrd AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM aux_cdhistor AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM aux_dshistor AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_dsdcompl AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_vldocmto AS DECI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabope FOR crapope.

    DEF VAR aux_flgsemhi AS LOGI                                    NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlrcalcu AS DECI                                    NO-UNDO.
    DEF VAR aux_vlrdifer AS DECI                                    NO-UNDO.
    DEF VAR aux_vlrttdeb AS DECI                                    NO-UNDO.
    DEF VAR aux_sdfinbol LIKE crapbcx.vldsdfin                      NO-UNDO.
            
    ASSIGN aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Valida Boletim Caixa"
           aux_cdcritic = 0
           par_nmdcampo = ""
           aux_returnvl = "NOK".
    
    EMPTY TEMP-TABLE tt-erro.

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:

        IF  par_cddopcao = "F" THEN
            DO:
                FIND LAST crapbcx WHERE 
                          crapbcx.cdcooper = par_cdcooper AND
                          crapbcx.dtmvtolt = par_dtmvtolx AND
                          crapbcx.cdagenci = par_cdagencx AND
                          crapbcx.nrdcaixa = par_nrdcaixx AND
                          crapbcx.cdopecxa = par_cdopecxa AND
                          crapbcx.cdsitbcx = 1          
                          NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapbcx THEN
                    DO:
                        ASSIGN aux_cdcritic = 698.
                        LEAVE.
                    END.
            
                RUN Gera_Boletim
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_idorigem,
                      INPUT par_nmdatela,
                      INPUT par_dtmvtolt,       
                      INPUT par_dsiduser,
                      INPUT YES, /* tipconsu */
                      INPUT RECID(crapbcx),
                     OUTPUT aux_flgsemhi,
                     OUTPUT aux_sdfinbol,
                     OUTPUT aux_vlrttcrd,
                     OUTPUT aux_vlrttdeb,
                     OUTPUT aux_nmarqimp,
                     OUTPUT aux_nmarqpdf,
                     OUTPUT TABLE tt-erro).

                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE Valida.

                IF  par_vldentra <> aux_vlrttcrd + crapbcx.vldsdini THEN
                    DO:
                        ASSIGN aux_cdcritic = 705
                               aux_vlrcalcu = aux_vlrttcrd + crapbcx.vldsdini
                               aux_vlrdifer = (aux_vlrttcrd + crapbcx.vldsdini)
                                                                 - par_vldentra
                               aux_msgretor = "Calculado " +
                                 TRIM(STRING(aux_vlrcalcu,"zzz,zzz,zz9.99-")) +
                                                             " Diferenca de " +
                                 TRIM(STRING(aux_vlrdifer,"zzz,zzz,zz9.99-"))
                               par_nmdcampo = "vldentra".
                        LEAVE Valida.
                    END.

                IF  par_vldsaida <> aux_vlrttdeb THEN
                    DO:
                        ASSIGN aux_cdcritic = 706
                               aux_vlrcalcu = aux_vlrttdeb
                               aux_vlrdifer = aux_vlrttdeb - par_vldsaida
                               aux_msgretor = "Calculado " +
                                 TRIM(STRING(aux_vlrcalcu,"zzz,zzz,zz9.99-")) +
                                                             " Diferenca de " +
                                 TRIM(STRING(aux_vlrdifer,"zzz,zzz,zz9.99-"))
                               par_nmdcampo = "vldsaida".
                        LEAVE Valida.
                    END.

                ASSIGN aux_vldsdfin = par_vldentra - par_vldsaida.
                
            END. /* IF  par_cddopcao = "F" */
        ELSE
        IF  par_cddopcao = "L" OR 
            par_cddopcao = "K" THEN
            DO:
                IF  NOT CAN-FIND (craphis WHERE 
                                 craphis.cdhistor = par_cdhistor AND
                                 craphis.cdcooper = par_cdcooper) THEN
                    DO:
                        ASSIGN aux_cdcritic = 526.
                        LEAVE Valida.
                    END.

                IF  par_nrdocmto = 0 THEN
                    DO:
                        ASSIGN aux_dscritic = "Numero do documento deve ser" +
                                              " preenchido.".
                        LEAVE Valida.
                    END.

                CASE par_cdoplanc:
                    WHEN "A" OR WHEN "E" THEN DO:
                        FIND craphis WHERE 
                             craphis.cdhistor = par_cdhistor AND
                             craphis.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

                        FIND crapage WHERE 
                             crapage.cdcooper = par_cdcooper  AND
                             crapage.cdagenci = par_cdagencx NO-LOCK NO-ERROR.

                        IF  NOT AVAIL crapage THEN
                            DO:
                                ASSIGN aux_cdcritic = 962.
                                LEAVE Valida.
                            END.

                        IF  craphis.tpctbcxa = 2 THEN
                            ASSIGN aux_nrctadeb = crapage.cdcxaage
                                   aux_nrctacrd = craphis.nrctacrd.
                        ELSE
                        IF  craphis.tpctbcxa = 3 THEN
                            ASSIGN aux_nrctacrd = crapage.cdcxaage
                                   aux_nrctadeb = craphis.nrctadeb.
                        ELSE
                            ASSIGN aux_nrctacrd = craphis.nrctacrd
                                   aux_nrctadeb = craphis.nrctadeb.

                        ASSIGN aux_cdhistor = craphis.cdhstctb
                               aux_dshistor = craphis.dshistor.

                        FIND craplcx WHERE 
                             craplcx.cdcooper = par_cdcooper AND
                             craplcx.dtmvtolt = par_dtmvtolt AND
                             craplcx.cdagenci = par_cdagencx AND
                             craplcx.nrdcaixa = par_nrdcaixx AND
                             craplcx.cdopecxa = par_cdopecxa AND
                             craplcx.nrdocmto = par_nrdocmto AND
                             craplcx.nrseqdig = par_nrseqdig
                             NO-LOCK NO-ERROR.

                        IF  NOT AVAIL craplcx THEN
                            DO:
                                ASSIGN aux_cdcritic = 90.
                                LEAVE Valida.
                            END.

                        IF  par_cdoplanc = "A" THEN
                            DO:
                                FIND crapage WHERE 
                                     crapage.cdcooper = par_cdcooper     AND
                                     crapage.cdagenci = craplcx.cdagenci 
                                     NO-LOCK NO-ERROR.

                                IF  NOT AVAIL crapage THEN
                                    DO:
                                        ASSIGN aux_cdcritic = 962.
                                        LEAVE Valida.
                                    END.
                            END.
                        
                        ASSIGN aux_dsdcompl = craplcx.dsdcompl
                               aux_vldocmto = craplcx.vldocmto.

                        IF  craplcx.nrautdoc <> 0 THEN
                            DO:
                                ASSIGN aux_cdcritic = 36.
                                LEAVE Valida.
                            END.

                        IF  par_cdoplanc = "E" THEN
                            DO:
                                IF  craphis.cdhistor = 701 OR /* Dif. caixa */
                                    craphis.cdhistor = 702 THEN 
                                    DO:
                                        FIND crabope where 
                                            crabope.cdcooper = par_cdcooper AND
                                            crabope.cdoperad = par_cdoperad
                                            NO-LOCK NO-ERROR.

                                        IF  AVAIL crabope THEN 
                                            DO:
                                                /* 1-Operador, 2-Supervisor
                                                 , 3-Gerente */
                                                IF  crabope.nvoperad <> 2 AND
                                                    crabope.nvoperad <> 3 THEN
                                                    DO:
                                                        ASSIGN 
                                                            aux_cdcritic = 824.
                                                        LEAVE Valida.
                                                    END.
                                            END.
                                    END.

                            END. /* IF  par_cdoplanc = "E" */

                    END. /* par_cdoplanc = A ou E */

                END CASE.
                
            END. /* IF  par_cddopcao = "L" */
        
        LEAVE Valida.

    END. /* Valida */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_returnvl = "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* Valida_Dados */

/* ------------------------------------------------------------------------- */
/*                  Efetua a Validação dos dados informados                  */
/* ------------------------------------------------------------------------- */
PROCEDURE Valida_Historico:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoplanc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqdig AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM aux_nrctadeb AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM aux_nrctacrd AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM aux_cdhistor AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM aux_dshistor AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_indcompl AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabope FOR crapope.

    DEF VAR aux_flgsemhi AS LOGI                                    NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlrcalcu AS DECI                                    NO-UNDO.
    DEF VAR aux_vlrdifer AS DECI                                    NO-UNDO.
    DEF VAR aux_vlrttdeb AS DECI                                    NO-UNDO.
            
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".
    
    EMPTY TEMP-TABLE tt-erro.

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:

        FIND craphis WHERE 
             craphis.cdhistor = par_cdhistor AND
             craphis.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        IF  NOT AVAIL craphis THEN
            DO:
                ASSIGN aux_cdcritic = 526.
                LEAVE Valida.
            END.

        FIND crapage WHERE crapage.cdcooper = par_cdcooper  AND
                           crapage.cdagenci = par_cdagencx
                           NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapage THEN
            DO:
                ASSIGN aux_cdcritic = 962.
                LEAVE Valida.
            END.

        IF  craphis.tpctbcxa = 2 THEN
            ASSIGN aux_nrctadeb = crapage.cdcxaage
                   aux_nrctacrd = craphis.nrctacrd.
        ELSE
        IF  craphis.tpctbcxa = 3 THEN
            ASSIGN aux_nrctacrd = crapage.cdcxaage
            aux_nrctadeb = craphis.nrctadeb.
        ELSE
            ASSIGN aux_nrctacrd = craphis.nrctacrd
                   aux_nrctadeb = craphis.nrctadeb.

        ASSIGN aux_cdhistor = craphis.cdhstctb
               aux_dshistor = craphis.dshistor.

        IF  craphis.tplotmov <> 22 OR
           (par_cdoplanc = "I"     AND
            craphis.tpctbcxa = 0)  THEN
            DO:
                ASSIGN aux_cdcritic = 100.
                LEAVE Valida.
            END.

        IF  craphis.indoipmf > 0   THEN
            DO:
                ASSIGN aux_cdcritic = 94.
                LEAVE Valida.
            END.

        IF  craphis.indebcre = "D" AND
            craphis.inhistor = 12  THEN
            DO:
                ASSIGN aux_cdcritic = 94.
                LEAVE Valida.
            END.

        IF  craphis.indebcre = "C" AND
            craphis.inhistor = 2   THEN
            DO:
                ASSIGN aux_cdcritic = 94.
                LEAVE Valida.
            END.

        ASSIGN aux_indcompl = craphis.indcompl.

        IF  craphis.cdhistor = 701 OR /* Dif. caixa */ 
            craphis.cdhistor = 702 THEN 
            DO:
                FIND crabope WHERE
                     crabope.cdcooper = par_cdcooper AND
                     crabope.cdoperad = par_cdoperad NO-LOCK NO-ERROR.

                IF  AVAIL crabope THEN
                    DO:
                        /* 1-Operador, 2-Supervisor , 3-Gerente */
                        IF  crabope.nvoperad <> 2 AND
                            crabope.nvoperad <> 3 THEN 
                            DO:
                                ASSIGN aux_cdcritic = 824.
                                LEAVE Valida.
                            END.
                    END.
            END.

        LEAVE Valida.

    END. /* Valida */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_returnvl = "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* Valida_Historico */

/* ------------------------------------------------------------------------- */
/*                 Função para reabilitar sangria de caixa                   */
/* ------------------------------------------------------------------------- */
FUNCTION reabilita-caixa-sangria RETURNS LOGICAL (INPUT p-cod-cooper  AS INTE,
                                                  INPUT p-cod-agencia AS INTE,
                                                  INPUT p-saldo-caixa AS DECI,
                                                  INPUT p-valor-docto AS DECI):

    FIND crapage WHERE crapage.cdcooper = p-cod-cooper AND
                       crapage.cdagenci = p-cod-agencia
                       NO-LOCK NO-ERROR.

    IF (p-saldo-caixa - p-valor-docto) >= crapage.vlmaxsgr THEN
        RETURN FALSE.

    RETURN TRUE.

END FUNCTION.

/* ------------------------------------------------------------------------- */
/*                 REALIZA A GRAVACAO DOS DADOS DA TELA BCAIXA               */
/* ------------------------------------------------------------------------- */
PROCEDURE Grava_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoplanc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdopecxa AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdlacre AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtautent AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vldentra AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vldsaida AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vldsdini AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrdmaqui AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqdig AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsdcompl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vldocmto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolx AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_operauto AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM aux_nrdrecid AS RECID                          NO-UNDO.
    DEF OUTPUT PARAM aux_nrdlacre AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador   AS INTE                                  NO-UNDO.
    DEF VAR aux_nrseqdig   AS INTE                                  NO-UNDO.
    DEF VAR aux_flgdocto   AS LOGI                                  NO-UNDO.
    DEF VAR aux_flgdebcr   AS LOGI                                  NO-UNDO.
    DEF VAR aux_dslitera   AS CHAR                                  NO-UNDO.
    DEF VAR aux_nrultseq   AS INTE                                  NO-UNDO.
    DEF VAR aux_nrregist   AS RECID                                 NO-UNDO.
    DEF VAR h-b1crap00     AS HANDLE                                NO-UNDO.
    DEF VAR h-b1crap11     AS HANDLE                                NO-UNDO.
    DEF VAR aux_nrctacrd   AS CHAR                                  NO-UNDO.
    DEF VAR aux_nrctadeb   AS CHAR                                  NO-UNDO.
    DEF VAR aux_cdhstctb   AS CHAR                                  NO-UNDO.
    DEF VAR aux_indcompl   AS CHAR                                  NO-UNDO.
    DEF VAR aux_dshistor   AS CHAR                                  NO-UNDO.
    DEF VAR aux_descdebi   AS CHAR                                  NO-UNDO.
    DEF VAR aux_desccred   AS CHAR                                  NO-UNDO.
    DEF VAR aux_literal    AS CHAR  FORMAT "x(48)" EXTENT 46        NO-UNDO.
    DEF VAR aux_dsccoml1   AS CHAR                                  NO-UNDO.
    DEF VAR aux_dsccoml2   AS CHAR                                  NO-UNDO.
    DEF VAR aux_dsccoml3   AS CHAR                                  NO-UNDO.
    DEF VAR aux_linha1     AS CHAR                                  NO-UNDO.
    DEF VAR aux_linha2     AS CHAR                                  NO-UNDO.
    DEF VAR aux_valor      AS CHAR                                  NO-UNDO.
    DEF VAR aux_nomeoper   AS CHAR                                  NO-UNDO.
    DEF VAR aux_liteaute   AS CHAR                                  NO-UNDO.
    DEF VAR in99           AS INTE                                  NO-UNDO.
    DEF VAR aux_indsangr   AS LOGI                                  NO-UNDO.
    DEF VAR aux_vlsdcaix   AS DECI                                  NO-UNDO.
    DEF VAR aux_dsopecxa   AS CHAR                                  NO-UNDO.
    DEF VAR aux_dsoperad   AS CHAR                                  NO-UNDO.    
    DEF VAR aux_dstxtlog   AS CHAR                                  NO-UNDO.    

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Grava Boletim de Caixa"
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_idorigem = par_idorigem.
    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper 
                 NO-LOCK NO-ERROR.        
    
    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:
        
        IF  par_cddopcao = "F" THEN
            DO:
                Contador: DO aux_contador = 1 TO 10:

                    FIND LAST crapbcx WHERE crapbcx.cdcooper = par_cdcooper AND
                                            crapbcx.dtmvtolt = par_dtmvtolx AND
                                            crapbcx.cdagenci = par_cdagencx AND
                                            crapbcx.nrdcaixa = par_nrdcaixx AND
                                            crapbcx.cdopecxa = par_cdopecxa AND
                                            crapbcx.cdsitbcx = 1
                                            EXCLUSIVE-LOCK NO-ERROR.
        
                    IF  NOT AVAIL crapbcx THEN
                        DO:
                            IF  LOCKED(crapbcx)   THEN
                                DO:
                                    IF  aux_contador = 10 THEN
                                        DO:
                                            FIND LAST crapbcx WHERE 
                                                      crapbcx.cdcooper = 
                                                               par_cdcooper AND
                                                      crapbcx.dtmvtolt = 
                                                               par_dtmvtolt AND
                                                      crapbcx.cdagenci = 
                                                               par_cdagencx AND
                                                      crapbcx.nrdcaixa = 
                                                               par_nrdcaixx AND
                                                      crapbcx.cdopecxa = 
                                                               par_cdopecxa AND
                                                      crapbcx.cdsitbcx = 1
                                                      NO-LOCK NO-ERROR.
        
                                            /* encontra o usuario que esta 
                                               travando */
                                            ASSIGN aux_dscritic = 
                                             LockTabela( INPUT RECID(crapbcx),
                                                         INPUT "crapbcx").
                                            LEAVE Contador.
                                        END.
                                    ELSE 
                                        DO:
                                           PAUSE 1 NO-MESSAGE.
                                           NEXT Contador.
                                        END.
                                END.
                            ELSE
                                DO:
                                    ASSIGN aux_cdcritic = 698.
                                    LEAVE Contador.
                                END.
                        END.
                    ELSE
                        LEAVE Contador.
        
                END. /* Contador */

                IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                    UNDO Grava, LEAVE Grava.

                ASSIGN crapbcx.cdsitbcx = 2
                       crapbcx.hrfecbcx = TIME
                       crapbcx.nrdlacre = par_nrdlacre
                       crapbcx.qtautent = par_qtautent
                       crapbcx.vldsdfin = par_vldentra - par_vldsaida
                       crapbcx.ipmaqcxa = ""
                       aux_nrdrecid     = RECID(crapbcx).
                       
                /* Buscar nome do operador de caixa */    
                FIND FIRST crapope WHERE crapope.cdcooper = par_cdcooper
                                     AND crapope.cdoperad = par_cdopecxa
                                     NO-LOCK NO-ERROR.
                                     
                IF  AVAILABLE crapope THEN
                    ASSIGN aux_dsopecxa = crapope.nmoperad.
                    
                /* Buscar nome do operador - Coordenador */    
                FIND FIRST crapope WHERE crapope.cdcooper = par_cdcooper
                                     AND crapope.cdoperad = par_operauto
                                     NO-LOCK NO-ERROR.
                                     
                IF  AVAILABLE crapope THEN
                    ASSIGN aux_dsoperad = crapope.nmoperad.                                  
                       
                /***********************************************************************************************
                  Se a data do fechamento for a mesma da data da abertura nao sera necessario a apresentacao do
                  campo Liberado pelo Coordenador no log, pois nao sera exigida a senha dele nesses casos.
                ************************************************************************************************/    
                                              
                IF  par_dtmvtolt <> par_dtmvtolx THEN
                    ASSIGN aux_dstxtlog = STRING(par_dtmvtolt,"99/99/9999") + " "   +
                                          STRING(TIME,"HH:MM:SS") + " '-->' "       +                                        
                                          " Operador: " + par_cdopecxa + " - "      + 
                                          aux_dsopecxa                              +
                                          ", fechou o caixa referente ao dia "      + 
                                          STRING(par_dtmvtolx,"99/99/9999")         +                                          
                                          ". Liberado pelo coordenador: "           +  
                                          par_operauto + " - " + aux_dsoperad.
                ELSE
                    ASSIGN aux_dstxtlog = STRING(par_dtmvtolt,"99/99/9999") + "  "  +
                                          STRING(TIME,"HH:MM:SS") + "'-->' "        +
                                          " Operador: " + par_cdopecxa + " - "      +
                                          aux_dsopecxa                              +
                                          ", fechou o caixa referente ao dia "      + 
                                          STRING(par_dtmvtolx,"99/99/9999").

                UNIX SILENT VALUE("echo " + aux_dstxtlog              +
                                  " >> /usr/coop/" + crapcop.dsdircop +
                                  "/log/bcaixa.log").

            END. /* IF  par_cddopcao = "F" */
        ELSE
        IF  par_cddopcao = "I" THEN
            DO:
                IF  par_nrdmaqui = 0 THEN
                    DO:
                        ASSIGN aux_dscritic = "O numero da autenticadora " +
                                              "deve ser informado.".
                        UNDO Grava, LEAVE Grava.
                    END.

                FOR EACH crapbcx WHERE 
                         crapbcx.cdcooper = par_cdcooper    AND
                         crapbcx.dtmvtolt = par_dtmvtolt    AND
                         crapbcx.cdopecxa = par_cdopecxa    AND
                         crapbcx.cdsitbcx = 1
                         USE-INDEX crapbcx2 NO-LOCK:
                    ASSIGN aux_cdcritic = 703.
                    UNDO Grava, LEAVE Grava.
                END.

                FIND LAST crapbcx WHERE 
                          crapbcx.cdcooper = par_cdcooper AND
                          crapbcx.dtmvtolt = par_dtmvtolt AND
                          crapbcx.cdagenci = par_cdagencx AND
                          crapbcx.nrdcaixa = par_nrdcaixx
                          USE-INDEX crapbcx1 NO-LOCK NO-ERROR.

                IF  NOT AVAIL crapbcx THEN
                    FIND FIRST crapbcx WHERE 
                               crapbcx.cdcooper = par_cdcooper  AND
                               crapbcx.cdagenci = par_cdagencx  AND
                               crapbcx.nrdcaixa = par_nrdcaixx  AND
                               crapbcx.dtmvtolt < par_dtmvtolt  
                               USE-INDEX crapbcx5 NO-LOCK NO-ERROR.

                IF  NOT AVAIL crapbcx THEN
                    DO:
                        ASSIGN aux_cdcritic = 701.
                        UNDO Grava, LEAVE Grava.
                    END.
                ELSE
                IF  crapbcx.cdsitbcx <> 2 THEN
                    DO:
                        ASSIGN aux_cdcritic = 704.
                        UNDO Grava, LEAVE Grava.
                    END.
                ELSE
                IF  crapbcx.vldsdfin <> par_vldsdini THEN
                    DO:  
                        ASSIGN aux_cdcritic = 700.
                        UNDO Grava, LEAVE Grava.
                    END.
                ELSE
                IF  crapbcx.cdopecxa = par_cdopecxa AND
                    crapbcx.dtmvtolt = par_dtmvtolt THEN
                    DO:
                        /* Operador nao pode abrir um 
                        mesmo caixa no mesmo dia  */
                        ASSIGN aux_cdcritic = 703.
                        UNDO Grava, LEAVE Grava.
                    END.
                ELSE
                IF  crapbcx.dtmvtolt = par_dtmvtolt AND
                    crapbcx.cdsitbcx = 2            THEN
                    DO:
                          ASSIGN aux_cdcritic = 836.
                          UNDO Grava, LEAVE Grava.
                   END.
                ELSE
                    ASSIGN aux_nrdlacre = crapbcx.nrdlacre.

                ASSIGN aux_nrseqdig = IF crapbcx.dtmvtolt <> par_dtmvtolt
                                      THEN 1
                                      ELSE crapbcx.nrseqdig + 1.

                FIND crapbcx WHERE
                     crapbcx.cdcooper = par_cdcooper AND
                     crapbcx.dtmvtolt = par_dtmvtolt AND
                     crapbcx.cdagenci = par_cdagencx AND
                     crapbcx.nrdcaixa = par_nrdcaixx AND
                     crapbcx.nrseqdig = aux_nrseqdig
                     USE-INDEX crapbcx1 NO-LOCK NO-ERROR.

                IF  AVAIL crapbcx THEN
                    DO:
                        ASSIGN aux_cdcritic = 92.
                        UNDO Grava, LEAVE Grava.
                    END.

                CREATE crapbcx.
                ASSIGN crapbcx.dtmvtolt = par_dtmvtolt
                       crapbcx.cdagenci = par_cdagencx
                       crapbcx.nrdcaixa = par_nrdcaixx
                       crapbcx.nrseqdig = aux_nrseqdig
                       crapbcx.cdopecxa = par_cdopecxa
                       crapbcx.cdsitbcx = 1
                       crapbcx.nrdlacre = 0
                       crapbcx.nrdmaqui = par_nrdmaqui
                       crapbcx.qtautent = 0
                       crapbcx.vldsdini = par_vldsdini
                       crapbcx.vldsdfin = par_vldsdini
                       crapbcx.hrabtbcx = TIME
                       crapbcx.hrfecbcx = 0
                       crapbcx.cdcooper = par_cdcooper
                       aux_nrdrecid     = RECID(crapbcx).
                VALIDATE crapbcx.

            END. /* IF  par_cddopcao = "I" */
        ELSE
        IF  par_cddopcao = "L" OR 
            par_cddopcao = "K" THEN
            DO:
                IF  par_cddopcao = "K" AND
                    par_cdoplanc = ""  THEN
                    DO:
                        Contador: DO aux_contador = 1 TO 10:

                            FIND LAST crapbcx WHERE 
                                      crapbcx.cdcooper = par_cdcooper AND
                                      crapbcx.dtmvtolt = par_dtmvtolt AND
                                      crapbcx.cdagenci = par_cdagencx AND
                                      crapbcx.nrdcaixa = par_nrdcaixx AND
                                      crapbcx.cdopecxa = par_cdopecxa
                                      EXCLUSIVE-LOCK NO-ERROR.

                            IF  NOT AVAIL crapbcx THEN
                                DO:
                                    IF  LOCKED(crapbcx)   THEN
                                        DO:
                                            IF  aux_contador = 10 THEN
                                                DO:
                                                    FIND LAST crapbcx WHERE 
                                                            crapbcx.cdcooper = 
                                                               par_cdcooper AND
                                                            crapbcx.dtmvtolt = 
                                                               par_dtmvtolt AND
                                                            crapbcx.cdagenci = 
                                                               par_cdagencx AND
                                                            crapbcx.nrdcaixa = 
                                                               par_nrdcaixx AND
                                                            crapbcx.cdopecxa = 
                                                               par_cdopecxa AND
                                                           crapbcx.cdsitbcx = 1
                                                            NO-LOCK NO-ERROR.
        
                                            /* encontra o usuario que esta 
                                               travando */
                                                    ASSIGN aux_dscritic = 
                                              LockTabela( INPUT RECID(crapbcx),
                                                           INPUT "crapbcx").
                                                    LEAVE Contador.
                                                END.
                                            ELSE 
                                                DO:
                                                    PAUSE 1 NO-MESSAGE.
                                                    NEXT Contador.
                                                END.
                                        END.
                                    ELSE
                                        DO:
                                            ASSIGN aux_cdcritic = 698.
                                            LEAVE Contador.
                                        END.
                                END.
                            ELSE
                                LEAVE Contador.
                        END. /* Contador */

                        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                            UNDO Grava, LEAVE Grava.

                        ASSIGN crapbcx.cdsitbcx = 1
                               crapbcx.hrfecbcx = 0
                               crapbcx.nrdlacre = 0
                               crapbcx.qtautent = 0
                               crapbcx.vldsdfin = 0.

                        RELEASE crapbcx.
                        
                    END.

                IF  CAN-DO("A,I",par_cdoplanc) AND
                    par_vldocmto = 0 THEN
                    DO:
                        ASSIGN aux_dscritic = "Valor dever ser diferente" +
                                              " de zero".
                        UNDO Grava, LEAVE Grava.
                    END.

                IF  CAN-DO("A,E",par_cdoplanc) THEN DO:

                    Contador: DO aux_contador = 1 TO 10:

                        FIND craplcx WHERE
                             craplcx.cdcooper = par_cdcooper AND
                             craplcx.dtmvtolt = par_dtmvtolt AND
                             craplcx.cdagenci = par_cdagencx AND
                             craplcx.nrdcaixa = par_nrdcaixx AND
                             craplcx.cdopecxa = par_cdopecxa AND
                             craplcx.nrdocmto = par_nrdocmto AND
                             craplcx.nrseqdig = par_nrseqdig
                             EXCLUSIVE-LOCK NO-ERROR.

                        IF  NOT AVAIL craplcx THEN
                            DO:
                                IF  LOCKED(craplcx) THEN
                                    DO:
                                        IF  aux_contador = 10 THEN
                                            DO:
                                                FIND craplcx WHERE
                                                     craplcx.cdcooper = 
                                                               par_cdcooper AND
                                                     craplcx.dtmvtolt = 
                                                               par_dtmvtolt AND
                                                     craplcx.cdagenci = 
                                                               par_cdagencx AND
                                                     craplcx.nrdcaixa = 
                                                               par_nrdcaixx AND
                                                     craplcx.cdopecxa = 
                                                               par_cdopecxa AND
                                                     craplcx.nrdocmto = 
                                                               par_nrdocmto AND
                                                     craplcx.nrseqdig =
                                                               par_nrseqdig
                                                              NO-LOCK NO-ERROR.

                                                /* encontra o usuario que
                                                              esta travando */
                                                ASSIGN aux_dscritic = 
                                             LockTabela( INPUT RECID(craplcx),
                                                         INPUT "craplcx" ).
                                                LEAVE Contador.

                                            END.
                                        ELSE 
                                            DO:
                                                PAUSE 1 NO-MESSAGE.
                                                NEXT Contador.
                                            END.
                                    END.
                                ELSE
                                    DO:
                                        ASSIGN aux_cdcritic = 698.
                                        LEAVE Contador.
                                    END.
                            END.
                        ELSE
                            LEAVE Contador.
                    END. /* Contador */

                    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                        UNDO Grava, LEAVE Grava.

                    IF  par_cdoplanc = "A" THEN
                        ASSIGN craplcx.cdhistor = par_cdhistor
                               craplcx.dsdcompl = CAPS(par_dsdcompl)
                               craplcx.vldocmto = par_vldocmto.
                    ELSE
                    IF  par_cdoplanc = "E" THEN
                        DO:
                            DELETE craplcx.
                            RELEASE craplcx.
                        END.
                        
                END. /* par_cdoplanc = "A" ou "E" */
                ELSE
                IF  par_cdoplanc = "I" THEN DO:

                    Contador: DO aux_contador = 1 TO 10:

                        FIND LAST crapbcx WHERE 
                                  crapbcx.cdcooper = par_cdcooper AND
                                  crapbcx.dtmvtolt = par_dtmvtolt AND
                                  crapbcx.cdagenci = par_cdagencx AND
                                  crapbcx.nrdcaixa = par_nrdcaixx AND
                                  crapbcx.cdopecxa = par_cdopecxa AND
                                  crapbcx.cdsitbcx = 1
                                  EXCLUSIVE-LOCK NO-ERROR.

                        IF  NOT AVAIL crapbcx THEN
                            DO:
                                IF  LOCKED(crapbcx)   THEN
                                    DO:
                                        IF  aux_contador = 10 THEN
                                            DO:
                                                FIND LAST crapbcx WHERE 
                                                           crapbcx.cdcooper = 
                                                               par_cdcooper AND
                                                           crapbcx.dtmvtolt = 
                                                               par_dtmvtolt AND
                                                           crapbcx.cdagenci = 
                                                               par_cdagencx AND
                                                           crapbcx.nrdcaixa = 
                                                               par_nrdcaixx AND
                                                           crapbcx.cdopecxa = 
                                                               par_cdopecxa AND
                                                           crapbcx.cdsitbcx = 1
                                                           NO-LOCK NO-ERROR.

                                                /* encontra o usuario que esta 
                                                travando */
                                                ASSIGN aux_dscritic = 
                                              LockTabela( INPUT RECID(crapbcx),
                                                              INPUT "crapbcx").
                                                LEAVE Contador.
                                            END.
                                        ELSE 
                                            DO:
                                                PAUSE 1 NO-MESSAGE.
                                                NEXT Contador.
                                            END.
                                    END.
                                ELSE
                                    DO:
                                        ASSIGN aux_cdcritic = 698.
                                        LEAVE Contador.
                                    END.
                            END.
                        ELSE
                            LEAVE Contador.

                    END. /* Contador */

                    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                        UNDO Grava, LEAVE Grava.

                    ASSIGN aux_flgdocto = NO.

                    FOR EACH craplcx WHERE 
                             craplcx.cdcooper = par_cdcooper AND
                             craplcx.dtmvtolt = par_dtmvtolt AND
                             craplcx.cdagenci = par_cdagencx AND
                             craplcx.nrdcaixa = par_nrdcaixx AND
                             craplcx.cdopecxa = par_cdopecxa AND
                             craplcx.nrdocmto = par_nrdocmto
                             USE-INDEX craplcx2 NO-LOCK:

                        IF  craplcx.cdhistor = par_cdhistor THEN
                            DO:
                                ASSIGN aux_flgdocto = YES.
                                LEAVE.
                            END.    
                    END. /* FOR EACH craplcx */

                    IF  aux_flgdocto THEN
                        DO:
                            ASSIGN aux_cdcritic = 92.
                            UNDO Grava, LEAVE Grava.
                        END.

                    /* Busca a cooperativa e o historico para passar parametros para a rotina que grava autenticacao (Chamado 270784) (Heitor-RKAM) */
                    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

                    /* Novo */
                    /* Tratamento SANGRIA DE CAIXA */
                    IF par_cdhistor = 1152 OR par_cdhistor = 1153 THEN
                    DO:
                        ASSIGN in99 = 0
                               aux_indsangr = TRUE.
                        
                        DO WHILE TRUE:
                
                            FIND crapslc WHERE crapslc.cdcooper     = par_cdcooper AND
                                               crapslc.cdagenci     = par_cdagencx AND
                                               crapslc.nrdcofre     = 1
                                               EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                
                            ASSIGN in99 = in99 + 1.
                        
                            IF NOT AVAIL crapslc THEN
                            DO:
                                IF LOCKED crapslc THEN
                                DO:
                                    IF in99 < 100 THEN
                                    DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT.
                                    END.
                                    ELSE
                                    DO:
                                        ASSIGN aux_cdcritic  = 0
                                               aux_dscritic  = "Tabela CRAPSLC em uso.".

                                        RUN gera_erro (INPUT par_cdcooper,
                                                       INPUT par_cdagencx,
                                                       INPUT par_nrdcaixx,
                                                       INPUT 1,
                                                       INPUT aux_cdcritic,
                                                       INPUT-OUTPUT aux_dscritic).

                                        RETURN "NOK".
                                    END.
                                END.
                                ELSE
                                DO:
                                    IF par_cdhistor = 1153 THEN
                                    DO:
                                        ASSIGN aux_cdcritic = 0
                                               aux_dscritic = "Saldo indisponivel no cofre " +
                                                             "para realizar essa operacao.".
                
                                        RUN gera_erro (INPUT par_cdcooper,
                                                       INPUT par_cdagencx,
                                                       INPUT par_nrdcaixx,
                                                       INPUT 1,
                                                       INPUT aux_cdcritic,
                                                       INPUT-OUTPUT aux_dscritic).
                
                                        RETURN "NOK".
                                    END.
                                    ELSE
                                    IF par_cdhistor = 1152 THEN
                                    DO:
                                        RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
                
                                        RUN verifica-saldo-caixa IN h-b1crap00 
                                                                   (INPUT par_cdcooper,
                                                                    INPUT crapcop.nmrescop,
                                                                    INPUT par_cdagencx,
                                                                    INPUT par_nrdcaixx,
                                                                    INPUT par_cdopecxa,
                                                                   OUTPUT aux_vlsdcaix).

                                        IF VALID-HANDLE(h-b1crap00) THEN
                                            DELETE OBJECT h-b1crap00.
                
                                        IF RETURN-VALUE <> "OK" THEN
                                            RETURN "NOK".
                
                                        IF par_vldocmto > aux_vlsdcaix THEN
                                        DO:
                                            ASSIGN aux_cdcritic = 0
                                                   aux_dscritic = "Saldo insuficiente no caixa "
                                                                   + "para realizar essa operacao.".
                    
                                            RUN gera_erro (INPUT par_cdcooper,
                                                           INPUT par_cdagencx,
                                                           INPUT par_nrdcaixx,
                                                           INPUT 1,
                                                           INPUT aux_cdcritic,
                                                           INPUT-OUTPUT aux_dscritic).

                                            RETURN "NOK".
                                        END.

                                        CREATE crapslc.
                                        ASSIGN crapslc.cdcooper = crapcop.cdcooper
                                               crapslc.cdagenci = par_cdagencx
                                               crapslc.nrdcofre = 1
                                               crapslc.vlrsaldo = par_vldocmto.
                                        VALIDATE crapslc.
                                        
                                        ASSIGN aux_indsangr = reabilita-caixa-sangria
                                                                      (INPUT crapcop.cdcooper,
                                                                       INPUT par_cdagencx,
                                                                       INPUT aux_vlsdcaix,
                                                                       INPUT par_vldocmto)
                                               crapbcx.flgcxsgr = aux_indsangr
                                               crapbcx.hrultsgr = TIME WHEN aux_indsangr AND par_cdhistor = 1152.
                
                                    END.
                                END.
                            END.
                            ELSE
                            DO:
                                IF par_cdhistor = 1153 THEN
                                DO:
                                    IF par_vldocmto > crapslc.vlrsaldo THEN
                                    DO:
                                        ASSIGN aux_cdcritic = 0
                                               aux_dscritic = "Saldo insuficiente no cofre " +
                                                         "para realizar essa operacao.".
                
                                        RUN gera_erro (INPUT par_cdcooper,
                                                       INPUT par_cdagencx,
                                                       INPUT par_nrdcaixx,
                                                       INPUT 1,
                                                       INPUT aux_cdcritic,
                                                       INPUT-OUTPUT aux_dscritic).

                                        RETURN "NOK".
                                    END.

                                    ASSIGN crapslc.vlrsaldo = crapslc.vlrsaldo - par_vldocmto.

                                END.
                                ELSE
                                IF par_cdhistor = 1152 THEN
                                DO:
                                    RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
                                    
                                    RUN verifica-saldo-caixa IN h-b1crap00
                                                                   (INPUT par_cdcooper,
                                                                    INPUT crapcop.nmrescop,
                                                                    INPUT par_cdagencx,
                                                                    INPUT par_nrdcaixx,
                                                                    INPUT par_cdopecxa,
                                                                   OUTPUT aux_vlsdcaix).
                                    
                                    IF VALID-HANDLE(h-b1crap00) THEN
                                        DELETE OBJECT h-b1crap00.
                
                                    IF RETURN-VALUE <> "OK" THEN
                                        RETURN "NOK".
                
                                    IF par_vldocmto > aux_vlsdcaix THEN
                                    DO:
                                        ASSIGN aux_cdcritic = 0
                                               aux_dscritic = "Saldo insuficiente no caixa "
                                                           + "para realizar essa operacao.".
                
                                        RUN gera_erro (INPUT par_cdcooper,
                                                       INPUT par_cdagencx,
                                                       INPUT par_nrdcaixx,
                                                       INPUT 1,
                                                       INPUT aux_cdcritic,
                                                       INPUT-OUTPUT aux_dscritic).
                                        
                                        RETURN "NOK".
                                    END.
                
                                    ASSIGN crapslc.vlrsaldo = crapslc.vlrsaldo + par_vldocmto.
                
                                    ASSIGN aux_indsangr = reabilita-caixa-sangria
                                                                      (INPUT par_cdcooper,
                                                                       INPUT par_cdagencx,
                                                                       INPUT aux_vlsdcaix,
                                                                       INPUT par_vldocmto)
                                           crapbcx.flgcxsgr = aux_indsangr
                                           crapbcx.hrultsgr = TIME WHEN aux_indsangr AND par_cdhistor = 1152.
                
                                END.
                            END.

                            LEAVE.
                        END.
                    END.
                    /* Novo */

                    CREATE craplcx.
                    ASSIGN craplcx.dtmvtolt = par_dtmvtolt
                           craplcx.cdagenci = par_cdagencx
                           craplcx.nrdcaixa = par_nrdcaixx
                           craplcx.cdopecxa = par_cdopecxa
                           craplcx.nrdocmto = par_nrdocmto
                           craplcx.nrseqdig = crapbcx.qtcompln + 1
                           craplcx.nrdmaqui = par_nrdmaqui
                           craplcx.cdhistor = par_cdhistor
                           craplcx.dsdcompl = CAPS(par_dsdcompl)
                           crapbcx.qtcompln = crapbcx.qtcompln + 1
                           craplcx.vldocmto = par_vldocmto
                           craplcx.cdcooper = par_cdcooper.
                    
                    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

                    FIND craphis WHERE craphis.cdcooper = par_cdcooper
                                   AND craphis.cdhistor = par_cdhistor NO-LOCK NO-ERROR.

                    /* Passa parametro YES se for pagamento e NO se for recebimento, conforme regra existente na b1crap11 (Chamado 270784) (Heitor-RKAM) */
                    IF  craphis.indebcre = "C" THEN
                      ASSIGN aux_flgdebcr = NO.   /* Credito = Recebimento */
                    ELSE
                      ASSIGN aux_flgdebcr = YES.  /* Debito = Pagamento */

                    /* Chamada da rotina grava-autenticacao, para criar o registro de autenticacao, conforme e efetuado na rotina 11 do Caixa Online (Chamado 270784) (Heitor-RKAM) */
                    RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
                    RUN grava-autenticacao  IN h-b1crap00 (INPUT crapcop.nmrescop,
                                                           INPUT par_cdagencx,
                                                           INPUT par_nrdcaixx,
                                                           INPUT par_cdopecxa,
                                                           INPUT par_vldocmto,
                                                           INPUT DEC(par_nrdocmto),
                                                           INPUT aux_flgdebcr, /* YES (PG), NO (REC) */
                                                           INPUT "1",  /* On-line           */ 
                                                           INPUT NO,    /* Nao estorno        */
                                                           INPUT par_cdhistor, 
                                                           INPUT ?, /* Data off-line */
                                                           INPUT 0, /* Sequencia off-line */
                                                           INPUT 0, /* Hora off-line */
                                                           INPUT 0, /* Seq.orig.Off-line */
                                                           OUTPUT aux_dslitera,
                                                           OUTPUT aux_nrultseq,
                                                           OUTPUT aux_nrregist).
                    DELETE PROCEDURE h-b1crap00.

                    IF  RETURN-VALUE <> "OK" THEN
                        RETURN "NOK".

                    /* Atualiza sequencia Autenticacao (Chamado 270784) (Heitor-RKAM) */
                    ASSIGN craplcx.nrautdoc = aux_nrultseq.
                    ASSIGN aux_liteaute = aux_dslitera.
                    
                    RUN dbo/b1crap11.p PERSISTENT SET h-b1crap11.
                    RUN retorna-valor-historico IN h-b1crap11 (INPUT crapcop.nmrescop,
                                                               INPUT int(par_cdagencx),
                                                               INPUT int(par_cdhistor),
                                                               OUTPUT aux_nrctacrd,
                                                               OUTPUT aux_nrctadeb,
                                                               OUTPUT aux_cdhstctb,
                                                               OUTPUT aux_indcompl,
                                                               OUTPUT aux_dshistor).
                    
                    DELETE PROCEDURE h-b1crap11.

                    IF  RETURN-VALUE <> "OK" THEN
                        RETURN "NOK".

                    IF  craphis.indcompl = 1 THEN 
                        DO:
                    
                            /*----- Gera Autenticacao Recebimento   --------*/ 
                 
                            IF  aux_nrctadeb BEGINS "11" THEN
                                ASSIGN aux_descdebi = " - CAIXA".
                            ELSE
                                ASSIGN aux_descdebi = " - ________________________________".
                        
                            IF  aux_nrctacrd BEGINS "11" THEN
                                ASSIGN aux_desccred = " - CAIXA".
                            ELSE
                                ASSIGN aux_desccred = " - ________________________________".

                            ASSIGN aux_literal = " ".
                            ASSIGN aux_literal[1] = TRIM(crapcop.nmrescop) +  " - " + 
                                                  TRIM(crapcop.nmextcop) 
                                   aux_literal[2] = " "
                                   aux_literal[3] = STRING(crapdat.dtmvtolt,"99/99/99") + " " +
                                                  STRING(TIME,"HH:MM:SS")     +  " PA " + 
                                                  STRING(par_cdagencx,"999") + 
                                                  "  CAIXA: " +
                                                  STRING(par_nrdcaixx,"Z99") + "/" +
                                                  SUBSTR(par_cdopecxa,1,10)  
                                   aux_literal[4] = " " 
                                   aux_literal[5] = "      ** DOCUMENTO DE CAIXA " + 
                                                  STRING(par_nrdocmto,"ZZZ,ZZ9")  + " **" 
                                   aux_literal[6] = " " 

                                   aux_literal[7] = STRING(par_cdhistor,"9999") +
                                                   " - " + craphis.dshistor              

                                   aux_literal[8]  = " "            
                                   aux_literal[9]  = "DEBITO : " + aux_nrctadeb + aux_descdebi
                                   aux_literal[10] = " "      

                                   aux_literal[11] = "CREDITO: " + aux_nrctacrd + aux_desccred
                                   aux_literal[12] = " "      

                                   aux_literal[13] = "HST CTL: " + aux_cdhstctb  
                                   aux_literal[14] = " ".      

                            IF  par_dsdcompl <> " " THEN
                                ASSIGN aux_literal[15] = CAPS(par_dsdcompl).
                            ELSE
                                ASSIGN aux_literal[15] = " ". 
                                          
                            /* BCAIXA, opcao L, so possui um campo de complemento */
                            ASSIGN aux_literal[16] = " ".
                            ASSIGN aux_literal[17] = " ".
                            
                            
                            RUN dbo/pcrap12.p (INPUT  par_vldocmto,
                                               INPUT  47,
                                               INPUT  47,
                                               INPUT  "M",
                                               OUTPUT aux_linha1,
                                               OUTPUT aux_linha2).
                
                            ASSIGN aux_valor = FILL(" ",14 - 
                                             LENGTH(TRIM(STRING(par_vldocmto,
                                                                "zzz,zzz,zz9.99")))) + 
                                             "*" + 
                                            (TRIM(STRING(par_vldocmto,"zzz,zzz,zz9.99"))).
                    
                            FIND FIRST crapope WHERE crapope.cdcooper = crapcop.cdcooper    AND
                                                     crapope.cdoperad = par_cdopecxa 
                                                     NO-LOCK NO-ERROR.
                                                     
                            IF  AVAIL crapope THEN
                                ASSIGN aux_nomeoper = crapope.nmoperad.
                            
                            ASSIGN aux_literal[20] = " "
                                   aux_literal[21] = "VALOR DE R$    " + aux_valor
                                   aux_literal[22] = "(" + TRIM(aux_linha1)
                                   aux_literal[23] = TRIM(aux_linha2) + ")"
                                   aux_literal[24] = " "
                                   aux_literal[25] = " "          
                                   aux_literal[26] = " "
                                   aux_literal[27] = "ASSINATURAS:"
                                   aux_literal[28] = " "
                                   aux_literal[29] = " "
                                   aux_literal[30] = 
                                            "_______________________________________________"
                                   aux_literal[31] = SUBSTR(par_cdopecxa,1,10) + " - " +
                                                   aux_nomeoper
                                   aux_literal[32] = " "
                                   aux_literal[33] = " "
                                   aux_literal[34] = " "
                                   aux_literal[35] = 
                                            "APROVADO POR: _________________________________" 
                                   aux_literal[36] = " "
                                   aux_literal[37] = aux_dslitera
                                   aux_literal[38] = " "
                                   aux_literal[39] = " "
                                   aux_literal[40] = " "
                                   aux_literal[41] = " "
                                   aux_literal[42] = " "
                                   aux_literal[43] = " "
                                   aux_literal[44] = " "
                                   aux_literal[45] = " "
                                   aux_literal[46] = " ".
                            
                            ASSIGN aux_liteaute = STRING(aux_literal[1],"x(48)")    + 
                                                  STRING(aux_literal[2],"x(48)")    + 
                                                  STRING(aux_literal[3],"x(48)")    + 
                                                  STRING(aux_literal[4],"x(48)")    + 
                                                  STRING(aux_literal[5],"x(48)")    + 
                                                  STRING(aux_literal[6],"x(48)")    + 
                                                  STRING(aux_literal[7],"x(48)")    + 
                                                  STRING(aux_literal[8],"x(48)")    + 
                                                  STRING(aux_literal[9],"x(48)")    + 
                                                  STRING(aux_literal[10],"x(48)")   +   
                                                  STRING(aux_literal[11],"x(48)")   + 
                                                  STRING(aux_literal[12],"x(48)")   +
                                                  STRING(aux_literal[13],"x(48)")   + 
                                                  STRING(aux_literal[14],"x(48)").
                            
                            IF  aux_literal[15] <> " " THEN
                                ASSIGN aux_liteaute = aux_liteaute + STRING(aux_literal[15],"x(48)").
                 
                            IF  aux_literal[16] <> " " THEN
                                ASSIGN aux_liteaute = aux_liteaute + STRING(aux_literal[16],"x(48)").
                  
                            IF  aux_literal[17] <> " " THEN
                                ASSIGN aux_liteaute = aux_liteaute + STRING(aux_literal[17],"x(48)").
                
                            IF  aux_literal[18] <> " " THEN
                                ASSIGN aux_liteaute = aux_liteaute + STRING(aux_literal[18],"x(48)").
                                     
                            IF  aux_literal[19] <> " " THEN
                                ASSIGN aux_liteaute = aux_liteaute + STRING(aux_literal[19],"x(48)"). 
                            
                            ASSIGN aux_liteaute = aux_liteaute +
                                                  STRING(aux_literal[20],"x(48)")   + 
                                                  STRING(aux_literal[21],"x(48)")   + 
                                                  STRING(aux_literal[22],"x(48)")   + 
                                                  STRING(aux_literal[23],"x(48)")   + 
                                                  STRING(aux_literal[24],"x(48)")   + 
                                                  STRING(aux_literal[25],"x(48)")   +
                                                  STRING(aux_literal[26],"x(48)")   + 
                                                  STRING(aux_literal[27],"x(48)")   + 
                                                  STRING(aux_literal[28],"x(48)")   + 
                                                  STRING(aux_literal[29],"x(48)")   + 
                                                  STRING(aux_literal[30],"x(48)")   + 
                                                  STRING(aux_literal[31],"x(48)")   + 
                                                  STRING(aux_literal[32],"x(48)")   + 
                                                  STRING(aux_literal[33],"x(48)")   + 
                                                  STRING(aux_literal[34],"x(48)")   +
                                                  STRING(aux_literal[35],"x(48)")   +
                                                  STRING(aux_literal[36],"x(48)")   + 
                                                  STRING(aux_literal[37],"x(48)")   + 
                                                  STRING(aux_literal[38],"x(48)")   + 
                                                  STRING(aux_literal[39],"x(48)")   + 
                                                  STRING(aux_literal[40],"x(48)")   + 
                                                  STRING(aux_literal[41],"x(48)")   + 
                                                  STRING(aux_literal[42],"x(48)")   + 
                                                  STRING(aux_literal[43],"x(48)")   + 
                                                  STRING(aux_literal[44],"x(48)")   +
                                                  STRING(aux_literal[45],"x(48)")   + 
                                                  STRING(aux_literal[46],"x(48)").     
                            
                            ASSIGN in99 = 0. 
                            DO  WHILE TRUE:
                        
                                ASSIGN in99 = in99 + 1.
                                FIND FIRST crapaut WHERE RECID(crapaut) = aux_nrregist
                                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                IF  NOT AVAIL  crapaut  THEN  
                                    DO:
                                        IF  LOCKED crapaut  THEN 
                                            DO:
                                                IF  in99 <  100  THEN 
                                                    DO:
                                                        PAUSE 1 NO-MESSAGE.
                                                        NEXT.
                                                    END.
                                                ELSE 
                                                    DO:
                                                        RETURN "NOK".
                                                    END.
                                            END.
                                    END.
                                ELSE 
                                    DO:
                                        ASSIGN  crapaut.dslitera = aux_liteaute.
                                        RELEASE crapaut.
                                        LEAVE.
                                    END.
                            END. /* DO  WHILE TRUE */
                        END.
                    
                    VALIDATE craplcx.

                    RELEASE craplcx.
                    RELEASE crapbcx.
                END. /* par_cdoplanc = "I" */
                
            END. /* par_cddopcao = "L" */

        LEAVE Grava.

    END. /* Grava */
    
    ASSIGN aux_returnvl = "OK".

    IF  aux_dscritic <> "" OR 
        aux_cdcritic <> 0  THEN
        DO: 
            
                ASSIGN aux_returnvl = "NOK".
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
          
        END.
    ELSE
        DO:        
            IF TEMP-TABLE tt-erro:HAS-RECORDS THEN
                ASSIGN aux_returnvl = "NOK".
                
        END.

    RETURN aux_returnvl.

END PROCEDURE. /* Grava_Dados */

/*............................. PROCEDURES INTERNAS .........................*/

PROCEDURE lista_lancamentos:

   
        RETURN "OK".

END PROCEDURE.


PROCEDURE gera_tt-histor:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdhistor LIKE craphis.cdhistor.
    DEF INPUT PARAM par_vllanmto LIKE craplcm.vllanmto.
    DEF INPUT PARAM par_dsdcompl LIKE craplcx.dsdcompl.
    DEF INPUT PARAM par_tpfatura LIKE craplft.tpfatura.
    DEF INPUT-OUTPUT PARAM par_flgouthi AS LOGI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vlrttctb AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_qtrttctb AS INTE                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vlarccon AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_qtarccon AS INTE                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vlarcdar AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_qtarcdar AS INTE                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vlarcgps AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_qtarcgps AS INTE                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vlarcnac AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_qtarcnac AS INTE                     NO-UNDO.    
    DEF INPUT-OUTPUT PARAM par_vldepsup AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_qtdepsup AS INTE                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vldepinf AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_qtdepinf AS INTE                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vldepcop AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_qtdepcop AS INTE                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vldepout AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_qtdepout AS INTE                     NO-UNDO.
    DEF INPUT PARAM pr_tpcartao AS INTE.  /* tpcartao */
    
    /* Vriavel da prcodeure gera_tt-hist -> b1wgen0120.p*/
    DEF VAR qtlanmto-recibo AS INTE.
    DEF VAR vllanmto-recibo LIKE craplcm.vllanmto.
    DEF VAR qtlanmto-cartao AS INTE.
    DEF VAR vllanmto-cartao LIKE craplcm.vllanmto.
    
    FOR FIRST crabhis WHERE crabhis.cdcooper = par_cdcooper AND
                            crabhis.cdhistor = par_cdhistor NO-LOCK: END.

    IF  NOT AVAILABLE crabhis THEN
        NEXT.

    IF  craphis.cdhistor <> 717 /* Arrecadacoes */ AND
        crabhis.indebcre <> craphis.indebcre   THEN
        NEXT.

    /* rotina conta recibo */
    IF pr_tpcartao = 0 THEN
       ASSIGN qtlanmto-recibo = 1
              vllanmto-recibo = par_vllanmto.
    /* rotina conta cartao */
    IF pr_tpcartao = 1 OR pr_tpcartao = 2 THEN
       ASSIGN qtlanmto-cartao = 1
              vllanmto-cartao = par_vllanmto.

    FIND tt-histor WHERE tt-histor.cdhistor = par_cdhistor           AND
                         tt-histor.dshistor = TRIM(crabhis.dshistor) AND
                         tt-histor.dsdcompl = TRIM(par_dsdcompl)     NO-ERROR.
    
    IF  NOT AVAIL tt-histor THEN
        DO:
            CREATE tt-histor.
            ASSIGN tt-histor.cdhistor = par_cdhistor
                   tt-histor.dshistor = TRIM(crabhis.dshistor)
                   tt-histor.dsdcompl = TRIM(par_dsdcompl).
        END.

    ASSIGN par_flgouthi       = YES
           par_vlrttctb       = par_vlrttctb + par_vllanmto
           par_qtrttctb       = par_qtrttctb + 1
           tt-histor.qtlanmto = tt-histor.qtlanmto + 1
           tt-histor.vllanmto = tt-histor.vllanmto + par_vllanmto
           tt-histor.qtlanmto-recibo = tt-histor.qtlanmto-recibo + qtlanmto-recibo
           tt-histor.vllanmto-recibo = tt-histor.vllanmto-recibo + vllanmto-recibo
           tt-histor.qtlanmto-cartao = tt-histor.qtlanmto-cartao + qtlanmto-cartao
           tt-histor.vllanmto-cartao = tt-histor.vllanmto-cartao + vllanmto-cartao.

    /*Arrecadacoes*/
    IF crabhis.tplotmov   = 0    AND
       crabhis.cdhistor   = 1154 AND 
       par_tpfatura       = 2    THEN
       DO:
        
          ASSIGN par_vlarcdar = par_vlarcdar + par_vllanmto
                 par_qtarcdar = par_qtarcdar + 1.
       END.
    ELSE
         DO:
            /*GPS*/
            IF CAN-DO("40,380,458,540,582,585,1414",STRING(crabhis.cdhistor)) THEN
               DO:
                  ASSIGN par_vlarcgps = par_vlarcgps + par_vllanmto
                         par_qtarcgps = par_qtarcgps + 1.         
               END.
            ELSE
               DO:
                  /*Simples Nacional*/
                  IF crabhis.tplotmov   = 0    AND
                     crabhis.cdhistor   = 1154 AND 
                     par_tpfatura       = 1   THEN
                     DO:
                        ASSIGN par_vlarcnac = par_vlarcnac + par_vllanmto
                               par_qtarcnac = par_qtarcnac + 1.
                     END.
                    
                  /*Convenios*/
                  ELSE
                     DO:
                        IF par_tpfatura = 0 THEN
                            DO:
                                ASSIGN par_vlarccon = par_vlarccon + par_vllanmto
                                       par_qtarccon = par_qtarccon + 1.
                            END.
                     END.
               END.
         END.
    /*Deposito a vista*/       
    /*EP. CHQ. SUPERIOR: cheques depositados que nao pertencem 
      A COOPERATIVA QUE RECEBEU O CHEQUE e sao igual ou superior 
      a R$300,00.*/
    IF CAN-DO("3,4,372",STRING(crabhis.cdhistor)) AND
       par_vllanmto >= 300 THEN
       DO:
          ASSIGN par_vldepsup = par_vldepsup + par_vllanmto
                 par_qtdepsup = par_qtdepsup + 1.
       END.
    ELSE
       DO:
          /*DEP. CHQ. INFERIOR: cheques depositados que nao 
           pertencem A COOPERATIVA QUE RECEBEU O CHEQUE e sao 
           igual ou inferior a R$299,99.*/
          IF CAN-DO("3,4,372",STRING(crabhis.cdhistor)) AND
             par_vllanmto < 300 THEN
             DO:
                ASSIGN par_vldepinf = par_vldepinf + par_vllanmto
                       par_qtdepinf = par_qtdepinf + 1.
             
             END.
          ELSE
             DO:
                /*DEP. CHQ. COOP.: equivale ao total de cheques depositados 
                  que pertencem EXCLUSIVAMENTE A COOPERATIVA.*/
                IF CAN-DO("21,386",STRING(crabhis.cdhistor)) THEN
                   DO:
                      ASSIGN par_vldepcop = par_vldepcop + par_vllanmto
                             par_qtdepcop = par_qtdepcop + 1.
                   END.
                /*Totalizando outros historicos restantes*/
                ELSE
                   DO:
                      ASSIGN par_vldepout = par_vldepout + par_vllanmto
                             par_qtdepout = par_qtdepout + 1.
                   END.
             END.
       
       END.
END PROCEDURE. /* gera_tt-histor */

PROCEDURE gera_crapcbb_INSS:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vlrttctb AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_qtrttctb AS INTE                     NO-UNDO.
                           
    FOR EACH craplot WHERE craplot.cdcooper = par_cdcooper       AND
                           craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                           craplot.cdagenci = crapbcx.cdagenci   AND
                           craplot.cdbccxlt = 11                 AND
                           craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                           craplot.cdopecxa = crapbcx.cdopecxa   AND
                           craplot.tplotmov = 31                 NO-LOCK:
                           
        FOR EACH crapcbb WHERE crapcbb.cdcooper = par_cdcooper      AND
                               crapcbb.dtmvtolt = craplot.dtmvtolt  AND
                               crapcbb.cdagenci = craplot.cdagenci  AND
                               crapcbb.cdbccxlt = craplot.cdbccxlt  AND
                               crapcbb.nrdolote = craplot.nrdolote  AND
                               crapcbb.tpdocmto = 3                 NO-LOCK:
                 
            ASSIGN par_vlrttctb = par_vlrttctb + crapcbb.valorpag
                   par_qtrttctb = par_qtrttctb + 1.
        END.    
    END.              
END PROCEDURE. /* gera_crapcbb_INSS */

PROCEDURE gera_crapcbb:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vlrttctb AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_qtrttctb AS INTE                     NO-UNDO.

    FOR EACH craplot WHERE craplot.cdcooper = par_cdcooper       AND
                           craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                           craplot.cdagenci = crapbcx.cdagenci   AND
                           craplot.cdbccxlt = 11                 AND
                           craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                           craplot.cdopecxa = crapbcx.cdopecxa   AND
                           craplot.tplotmov = 28                 NO-LOCK:

        FOR EACH crapcbb WHERE crapcbb.cdcooper = par_cdcooper      AND
                               crapcbb.dtmvtolt = craplot.dtmvtolt  AND
                               crapcbb.cdagenci = craplot.cdagenci  AND
                               crapcbb.cdbccxlt = craplot.cdbccxlt  AND
                               crapcbb.nrdolote = craplot.nrdolote  AND
                               crapcbb.flgrgatv = YES               AND
                               crapcbb.tpdocmto < 3                 NO-LOCK:

            ASSIGN par_vlrttctb = par_vlrttctb + crapcbb.valorpag
                   par_qtrttctb = par_qtrttctb + 1.
        END.    
    END.              
END PROCEDURE. /* gera_crapcbb */

PROCEDURE gera_craplpi:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vlrttctb AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_qtrttctb AS INTE                     NO-UNDO.

    FOR EACH craplot WHERE craplot.cdcooper = par_cdcooper       AND
                           craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                           craplot.cdagenci = crapbcx.cdagenci   AND
                           craplot.cdbccxlt = 11                 AND
                           craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                           craplot.cdopecxa = crapbcx.cdopecxa   AND
                           craplot.tplotmov = 33                 NO-LOCK:
                           
        FOR EACH craplpi WHERE craplpi.cdcooper = craplot.cdcooper   AND
                               craplpi.dtmvtolt = craplot.dtmvtolt   AND
                               craplpi.cdagenci = craplot.cdagenci   AND
                               craplpi.cdbccxlt = craplot.cdbccxlt   AND
                               craplpi.nrdolote = craplot.nrdolote
                               NO-LOCK:
                               
            ASSIGN par_vlrttctb = par_vlrttctb + craplpi.vllanmto
                   par_qtrttctb = par_qtrttctb + 1.
        END.    
    END.              
END PROCEDURE. /* gera_craplpi */

PROCEDURE gera_craplcs:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vlrttctb AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vlrttcrd AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_qtrttctb AS INTE                     NO-UNDO.

    DEF VAR aux_qtlanmto AS INT                                     NO-UNDO.
    DEF VAR aux_vllanmto AS DEC                                     NO-UNDO.
    
    EMPTY TEMP-TABLE tt-empresa.
    
    FOR EACH craplot WHERE craplot.cdcooper = par_cdcooper      AND
                           craplot.dtmvtolt = crapbcx.dtmvtolt  AND
                           craplot.cdagenci = crapbcx.cdagenci  AND
                           craplot.cdbccxlt = 11                AND
                           craplot.nrdcaixa = crapbcx.nrdcaixa  AND
                           craplot.cdopecxa = crapbcx.cdopecxa  AND
                           craplot.tplotmov = 32                NO-LOCK:
                           
        FOR EACH  craplcs WHERE craplcs.cdcooper = craplot.cdcooper   AND
                                craplcs.dtmvtolt = craplot.dtmvtolt   AND
                                craplcs.cdagenci = craplot.cdagenci   AND
                                craplcs.cdhistor = 561 /* Cta. Sal */ AND
                                craplcs.nrdolote = craplot.nrdolote   NO-LOCK,
            FIRST crapccs WHERE crapccs.cdcooper = craplcs.cdcooper   AND
                                crapccs.nrdconta = craplcs.nrdconta   NO-LOCK
                                BREAK BY crapccs.cdempres:
            
                   /* Total da empresa */
            ASSIGN aux_qtlanmto = aux_qtlanmto + 1
                   aux_vllanmto = aux_vllanmto + craplcs.vllanmto
                   
                   /* Total do historico */
                   par_vlrttctb = par_vlrttctb + craplcs.vllanmto
                   par_qtrttctb = par_qtrttctb + 1
                    
                   /* Total de creditos */
                   par_vlrttcrd = par_vlrttcrd + craplcs.vllanmto. 
                   
            IF   LAST-OF(crapccs.cdempres)   THEN
                 DO:
                     CREATE tt-empresa.
                     ASSIGN tt-empresa.cdempres = crapccs.cdempres
                            tt-empresa.qtlanmto = aux_qtlanmto
                            tt-empresa.vllanmto = aux_vllanmto
                            aux_qtlanmto = 0
                            aux_vllanmto = 0.
                 END.
        END.    
    END.
    
END PROCEDURE. /* gera_craplcs */


PROCEDURE gera_craplgp:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vlarcgps AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_qtarcgps AS INTE                     NO-UNDO.

    FOR EACH craplot WHERE craplot.cdcooper = par_cdcooper       AND
                           craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                           craplot.cdagenci = crapbcx.cdagenci   AND
                           craplot.cdbccxlt = 11                 AND
                           craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                           craplot.cdopecxa = crapbcx.cdopecxa   AND
                           craplot.tplotmov = 30                 NO-LOCK:

        FOR EACH craplgp WHERE craplgp.cdcooper = par_cdcooper      AND
                               craplgp.dtmvtolt = craplot.dtmvtolt  AND
                               craplgp.cdagenci = craplot.cdagenci  AND
                               craplgp.cdbccxlt = craplot.cdbccxlt  AND
                               craplgp.nrdolote = craplot.nrdolote  NO-LOCK:

            
            
            ASSIGN par_vlarcgps = par_vlarcgps + craplgp.vlrtotal
                   par_qtarcgps = par_qtarcgps + 1.
        END.    
    END.              
END PROCEDURE. /* gera_craplgp */


PROCEDURE gera_craplgp_gps:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vlarcgps AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_qtarcgps AS INTE                     NO-UNDO.

    FOR EACH craplot WHERE craplot.cdcooper = par_cdcooper       AND
                           craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                           craplot.cdagenci = crapbcx.cdagenci   AND
                           craplot.cdbccxlt = 100                AND
                           craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                           craplot.cdopecxa = crapbcx.cdopecxa   AND
                           craplot.tplotmov = 30                 NO-LOCK:

        FOR EACH craplgp WHERE craplgp.cdcooper = par_cdcooper      AND
                               craplgp.dtmvtolt = craplot.dtmvtolt  AND
                               craplgp.cdagenci = craplot.cdagenci  AND
                               craplgp.cdbccxlt = craplot.cdbccxlt  AND
                               craplgp.nrdolote = craplot.nrdolote  AND
                               craplgp.idsicred <> 0                AND
                               craplgp.nrseqagp = 0
                           AND craplgp.flgativo = TRUE              NO-LOCK:
                     /** Nao pegar GPS agendada */

            ASSIGN par_vlarcgps = par_vlarcgps + craplgp.vlrtotal
                   par_qtarcgps = par_qtarcgps + 1.
        END.    
    END.              
END PROCEDURE. /* gera_craplgp_gps */


PROCEDURE gera_craplci:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vlrttctb AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_qtrttctb AS INTE                     NO-UNDO.

    FOR EACH craplot WHERE craplot.cdcooper = par_cdcooper       AND
                           craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                           craplot.cdagenci = crapbcx.cdagenci   AND
                           craplot.cdbccxlt = 11                 AND
                           craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                           craplot.cdopecxa = crapbcx.cdopecxa   AND
                           craplot.tplotmov = 29                 NO-LOCK:

        FOR EACH craplci WHERE craplci.cdcooper = par_cdcooper      AND
                               craplci.dtmvtolt = craplot.dtmvtolt  AND
                               craplci.cdagenci = craplot.cdagenci  AND
                               craplci.cdbccxlt = craplot.cdbccxlt  AND
                               craplci.nrdolote = craplot.nrdolote  AND   
                               craplci.cdhistor = craphis.cdhistor  NO-LOCK: 
                               
            ASSIGN par_vlrttctb = par_vlrttctb + craplci.vllanmto
                   par_qtrttctb = par_qtrttctb + 1.
        END.    
    END.              
END PROCEDURE. /* gera_craplci */

PROCEDURE gera_craplem:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vlrttctb AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_qtrttctb AS INTE                     NO-UNDO.

    FOR EACH craplot WHERE craplot.cdcooper = par_cdcooper       AND
                           craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                           craplot.cdagenci = crapbcx.cdagenci   AND
                           craplot.cdbccxlt = 11                 AND
                           craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                           craplot.cdopecxa = crapbcx.cdopecxa   AND
                           craplot.tplotmov = 5                  NO-LOCK:
                           
        FOR EACH craplem WHERE craplem.cdcooper = par_cdcooper      AND
                               craplem.dtmvtolt = craplot.dtmvtolt  AND
                               craplem.cdagenci = craplot.cdagenci  AND
                               craplem.cdbccxlt = craplot.cdbccxlt  AND
                               craplem.nrdolote = craplot.nrdolote
                               USE-INDEX craplem1 NO-LOCK:
                               
            ASSIGN par_vlrttctb = par_vlrttctb + craplem.vllanmto
                   par_qtrttctb = par_qtrttctb + 1.
        END.    
    END.              

END PROCEDURE. /* gera_craplem */

PROCEDURE imprime_caixa_cofre:
    
    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_dtrefere AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                               NO-UNDO.            
    DEF INPUT PARAM par_cdprogra AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_dsiduser AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_tpcaicof AS CHAR                               NO-UNDO.

    DEF OUTPUT PARAM aux_nmarqimp AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_nmarqpdf AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    
    DEF VAR h-b1wgen0024 AS HANDLE                                     NO-UNDO.
    DEF VAR aux_vlrsaldo AS DEC                                        NO-UNDO.
    DEF VAR aux_nmendter AS CHAR                                       NO-UNDO.

    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                             NO-LOCK NO-ERROR.
    
    IF  par_tpcaicof = "CAIXA" THEN
        DO:
            /* Buscar saldo em caixa */
            RUN SaldoCaixas (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT 0, /* nrdcaixa */
                             INPUT par_dtrefere,
                             INPUT par_cdoperad,
                             INPUT par_cdprogra,
                             INPUT par_dtmvtolt,
                             INPUT "1", /* Indica a etapa do processo Chamado 660322 26/06/2017 */
                            OUTPUT aux_vlrsaldo,
                            OUTPUT aux_nmendter,
                            OUTPUT TABLE tt-erro,
                            OUTPUT TABLE tt_crapbcx).
           
            IF  RETURN-VALUE <> "OK" THEN
                RETURN "NOK".
        END.
    ELSE 
    IF  par_tpcaicof = "COFRE" THEN
        DO:
            /* Buscar saldo em cofre */
            RUN SaldoCofre ( INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT 0, /* nrdcaixa */
                             INPUT par_dtmvtolt,
                             INPUT par_cdprogra, /* Chamado 660322 23/06/2017 */
                             INPUT "1",          /* Indica a etapa do processo Chamado 660322 26/06/2017 */
                            OUTPUT aux_vlrsaldo,
                            OUTPUT aux_nmendter,
                            OUTPUT TABLE tt-erro,
                            OUTPUT TABLE tt_crapbcx).
           
            IF  RETURN-VALUE <> "OK" THEN
                RETURN "NOK".
        END.
    ELSE 
    IF  par_tpcaicof = "TOTAL" THEN
        DO:
            /* Buscar saldo em cofre */
            RUN SaldoTotal ( INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT 0, /* nrdcaixa */
                             INPUT par_dtrefere,
                             INPUT par_cdoperad,
                             INPUT par_cdprogra,
                             INPUT par_dtmvtolt,
                             INPUT "1", /* Indica a etapa do processo Chamado 660322 26/06/2017 */
                            OUTPUT aux_vlrsaldo,
                            OUTPUT aux_nmendter,
                            OUTPUT TABLE tt-erro,
                            OUTPUT TABLE tt_crapbcx).
           
            IF  RETURN-VALUE <> "OK" THEN
                RETURN "NOK".
        END.

    /* Montar endereco do arquivo de impressao */
    ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" +
                          aux_nmendter.
    
    ASSIGN aux_nmarqimp = aux_nmendter + ".ex"
           aux_nmarqpdf = aux_nmendter + ".pdf".
                                    
    /* Mensagem de impressao */
    FIND FIRST tt-msg-confirma NO-LOCK NO-ERROR NO-WAIT.
    
    IF  NOT AVAIL tt-msg-confirma THEN
        DO:
            CREATE tt-msg-confirma.
            ASSIGN tt-msg-confirma.inconfir = 1
                   tt-msg-confirma.dsmensag = "Confirma Impressao de relatorio?" +
                                              "(SIM/NAO)".  
            
        END.

    IF  par_idorigem = 5  THEN  /** Ayllos Web **/
        DO:
            RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                SET h-b1wgen0024.
    
            IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                DO:
                    ASSIGN aux_dscritic = "Handle invalido para BO " +
                                          "b1wgen0024.".
                    LEAVE.
                END.
        
            RUN envia-arquivo-web IN h-b1wgen0024 
                ( INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT 0,
                  INPUT aux_nmarqimp,
                 OUTPUT aux_nmarqpdf,
                 OUTPUT TABLE tt-erro ).
    
            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.
    
            IF  RETURN-VALUE <> "OK" THEN
                RETURN "NOK".
        END.
         
       LEAVE.

END PROCEDURE.

PROCEDURE SaldoCaixas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtrefere AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inetapa  AS CHAR                           NO-UNDO. /* Indica a etapa do processo Chamado 660322 26/06/2017 */
    DEF OUTPUT PARAM par_saldotot AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt_crapbcx. 

    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

    /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_saldo_caixas
         aux_handproc = PROC-HANDLE NO-ERROR
                      ( INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT par_dtrefere,
                        INPUT par_cdoperad,
                        INPUT par_cdprogra,
                        INPUT par_dtmvtolt,
                        INPUT par_inetapa, /* Indica a etapa do processo Chamado 660322 26/06/2017 */
                       OUTPUT "", /* nmarqimp */
                       OUTPUT 0,  /* saldotot */
                       OUTPUT "", /* critica */
                       OUTPUT ?). /* tabela com registros */

    CLOSE STORED-PROC pc_saldo_caixas 
       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
 
    ASSIGN aux_dscritic = ""
           par_nmarqimp = ""
           par_saldotot = 0
           aux_dscritic = pc_saldo_caixas.pr_dscritic
                             WHEN pc_saldo_caixas.pr_dscritic <> ?
           par_nmarqimp = pc_saldo_caixas.pr_nmarqimp
                             WHEN pc_saldo_caixas.pr_nmarqimp <> ?
           par_saldotot = pc_saldo_caixas.pr_saldotot
                             WHEN pc_saldo_caixas.pr_saldotot <> ?.
    
    IF  aux_dscritic <> "" THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.cdcritic = 0
                   tt-erro.dscritic = aux_dscritic.
            RETURN "NOK".
        END.

    EMPTY TEMP-TABLE tt_crapbcx.

    /* Leitura dos registros XML retornados pela procedure do oracle */
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_saldo_caixas.pr_clobxmlc. 
    
    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
    
    IF  ponteiro_xml <> ? THEN
        DO:
            xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
            xDoc:GET-DOCUMENT-ELEMENT(xRoot).
    
            DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
    
                xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
    
                IF  xRoot2:SUBTYPE <> "ELEMENT" THEN 
                    NEXT. 
    
                IF  xRoot2:NUM-CHILDREN > 0 THEN
                    CREATE tt_crapbcx.
    
                DO  aux_cont = 1 TO xRoot2:NUM-CHILDREN:
    
                    xRoot2:GET-CHILD(xField,aux_cont).
    
                    IF  xField:SUBTYPE <> "ELEMENT" THEN 
                        NEXT. 
    
                    xField:GET-CHILD(xText,1).

                    ASSIGN tt_crapbcx.cdagenci = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdagenci".
                    ASSIGN tt_crapbcx.nrdcaixa = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrdcaixa".
                    ASSIGN tt_crapbcx.csituaca = STRING (xText:NODE-VALUE) WHEN xField:NAME = "csituaca".     
                    ASSIGN tt_crapbcx.nmoperad = STRING (xText:NODE-VALUE) WHEN xField:NAME = "nmoperad".
                    ASSIGN tt_crapbcx.vldsdtot = DEC(xText:NODE-VALUE) WHEN xField:NAME = "vldsdtot".
                    ASSIGN tt_crapbcx.totcacof = DEC(xText:NODE-VALUE) WHEN xField:NAME = "totcacof".
                    ASSIGN tt_crapbcx.vltotcai = DEC(xText:NODE-VALUE) WHEN xField:NAME = "vltotcai".
                    ASSIGN tt_crapbcx.vltotcof = DEC(xText:NODE-VALUE) WHEN xField:NAME = "vltotcof".    

                END. 
            END.     
            SET-SIZE(ponteiro_xml) = 0. 
        END.
    
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE SaldoCofre:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO. /* Chamado 660322 26/06/2017 */
    DEF  INPUT PARAM par_inetapa  AS CHAR                           NO-UNDO. /* Chamado 660322 26/06/2017 */
    DEF OUTPUT PARAM par_saldotot AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt_crapbcx. 

    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

     /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_saldo_cofre
         aux_handproc = PROC-HANDLE NO-ERROR
                      ( INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT par_dtmvtolt,
                        INPUT par_cdprogra, /* Chamado 660322 26/06/2017 */
                        INPUT par_inetapa,  /* Indica a etapa do processo Chamado 660322 26/06/2017 */
                       OUTPUT "", /* nmarqimp */
                       OUTPUT 0,  /* saldotot */
                       OUTPUT "", /* critica */
                       OUTPUT ?). /* tabela com registros */

    CLOSE STORED-PROC pc_saldo_cofre 
       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
 
    ASSIGN aux_dscritic = ""
           par_nmarqimp = ""
           par_saldotot = 0
           aux_dscritic = pc_saldo_cofre.pr_dscritic
                             WHEN pc_saldo_cofre.pr_dscritic <> ?
           par_nmarqimp = pc_saldo_cofre.pr_nmarqimp
                             WHEN pc_saldo_cofre.pr_nmarqimp <> ?
           par_saldotot = pc_saldo_cofre.pr_saldotot
                             WHEN pc_saldo_cofre.pr_saldotot <> ?.

    IF  aux_dscritic <> "" THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.cdcritic = 0
                   tt-erro.dscritic = aux_dscritic.
            RETURN "NOK".
        END.

    EMPTY TEMP-TABLE tt_crapbcx.

    /* Leitura dos registros XML retornados pela procedure do oracle */
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_saldo_cofre.pr_clobxmlc. 
    
      /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
    
    IF  ponteiro_xml <> ? THEN
        DO:
            xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
            xDoc:GET-DOCUMENT-ELEMENT(xRoot).
    
            DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
    
                xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
    
                IF  xRoot2:SUBTYPE <> "ELEMENT" THEN 
                    NEXT. 
    
                IF  xRoot2:NUM-CHILDREN > 0 THEN
                    CREATE tt_crapbcx.
    
                DO  aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                
                    xRoot2:GET-CHILD(xField,aux_cont).
    
                    IF  xField:SUBTYPE <> "ELEMENT" THEN 
                        NEXT. 
    
                    xField:GET-CHILD(xText,1).
                    
                    ASSIGN tt_crapbcx.cdagenci = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdagenci".
                    ASSIGN tt_crapbcx.vldsdtot = DEC(xText:NODE-VALUE) WHEN xField:NAME = "vldsdtot".

                END. 
            END.     
            SET-SIZE(ponteiro_xml) = 0. 
        END.
                        
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE SaldoTotal:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtrefere AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inetapa  AS CHAR                           NO-UNDO. /* Indica a etapa do processo Chamado 660322 26/06/2017 */
    DEF OUTPUT PARAM par_saldotot AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt_crapbcx. 

    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

     /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_saldo_total
         aux_handproc = PROC-HANDLE NO-ERROR
                      ( INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT par_dtrefere,
                        INPUT par_cdoperad,
                        INPUT par_cdprogra,
                        INPUT par_dtmvtolt,
                        INPUT par_inetapa, /* Indica a etapa do processo Chamado 660322 26/06/2017 */
                       OUTPUT "", /* nmarqimp */
                       OUTPUT 0,  /* saldotot */
                       OUTPUT "", /* critica */
                       OUTPUT ?). /* tabela com registros */

    CLOSE STORED-PROC pc_saldo_total 
       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
 
    ASSIGN aux_dscritic = ""
           par_nmarqimp = ""
           par_saldotot = 0
           aux_dscritic = pc_saldo_total.pr_dscritic
                             WHEN pc_saldo_total.pr_dscritic <> ?
           par_nmarqimp = pc_saldo_total.pr_nmarqimp
                             WHEN pc_saldo_total.pr_nmarqimp <> ?
           par_saldotot = pc_saldo_total.pr_saldotot
                             WHEN pc_saldo_total.pr_saldotot <> ?.

    IF  aux_dscritic <> "" THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.cdcritic = 0
                   tt-erro.dscritic = aux_dscritic.
            RETURN "NOK".
        END.

    EMPTY TEMP-TABLE tt_crapbcx.

    /* Leitura dos registros XML retornados pela procedure do oracle */
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_saldo_total.pr_clobxmlc. 
    
    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
    
    IF  ponteiro_xml <> ? THEN
        DO:
            xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
            xDoc:GET-DOCUMENT-ELEMENT(xRoot).
    
            DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
    
                xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
    
                IF  xRoot2:SUBTYPE <> "ELEMENT" THEN 
                    NEXT. 
    
                IF  xRoot2:NUM-CHILDREN > 0 THEN
                    CREATE tt_crapbcx.
    
                DO  aux_cont = 1 TO xRoot2:NUM-CHILDREN:

                    xRoot2:GET-CHILD(xField,aux_cont).
    
                    IF  xField:SUBTYPE <> "ELEMENT" THEN 
                        NEXT. 
    
                    xField:GET-CHILD(xText,1).

                    ASSIGN tt_crapbcx.cdagenci = INT (xText:NODE-VALUE) WHEN xField:NAME = "cdagenci".
                    ASSIGN tt_crapbcx.totcacof = DEC (xText:NODE-VALUE) WHEN xField:NAME = "totcacof".
                    ASSIGN tt_crapbcx.vltotcai = DEC (xText:NODE-VALUE) WHEN xField:NAME = "vltotcai".
                    ASSIGN tt_crapbcx.vltotcof = DEC (xText:NODE-VALUE) WHEN xField:NAME = "vltotcof".
                END. 
            END.     
            SET-SIZE(ponteiro_xml) = 0. 
        END.
    
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
    
    RETURN "OK".

END PROCEDURE.

/*.............................. PROCEDURES (FIM) ...........................*/

/*................................ FUNCTIONS ................................*/

FUNCTION VerificaData RETURNS LOGICAL PRIVATE 
    ( INPUT par_dtmvtolt AS DATE ):

    IF  par_dtmvtolt < 04/01/2005 THEN
        RETURN FALSE.
    ELSE
        RETURN TRUE.

END FUNCTION.

FUNCTION LockTabela RETURNS CHARACTER PRIVATE 
    ( INPUT par_cddrecid AS RECID,
      INPUT par_nmtabela AS CHAR ):
/*-----------------------------------------------------------------------------
  Objetivo:  Identifica o usuario que esta locando o registro
     Notas:  
-----------------------------------------------------------------------------*/

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_loginusr AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmusuari AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdevice AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtconnec AS CHAR                                    NO-UNDO.
    DEF VAR aux_numipusr AS CHAR                                    NO-UNDO.
    DEF VAR aux_mslocktb AS CHAR                                    NO-UNDO.

    ASSIGN aux_mslocktb = "Registro sendo alterado em outro terminal " +
                          "(" + par_nmtabela + ").".

    IF  aux_idorigem = 3  THEN  /** InternetBank **/
        RETURN aux_mslocktb.

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
    
    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        RETURN aux_mslocktb.

    RUN acha-lock IN h-b1wgen9999 (INPUT par_cddrecid,
                                   INPUT "banco",
                                   INPUT par_nmtabela,
                                  OUTPUT aux_loginusr,
                                  OUTPUT aux_nmusuari,
                                  OUTPUT aux_dsdevice,
                                  OUTPUT aux_dtconnec, 
                                  OUTPUT aux_numipusr).

    DELETE OBJECT h-b1wgen9999.

    ASSIGN aux_mslocktb = aux_mslocktb + " Operador: " + 
                          aux_loginusr + " - " + aux_nmusuari.

    RETURN aux_mslocktb.   /* Function return value. */

END FUNCTION.

/* ......................................................................... */
