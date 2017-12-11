/*..............................................................................

   Programa: fontes/debcns.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas R.
   Data    : Julho/2013                        Ultima atualizacao: 23/10/2017

   Dados referentes ao programa:

   Frequencia: Diario (On-Line).
   Objetivo  : Apresentar todos os consorcios nao debitados no processo noturno.
   
   Alteracoes:
   
   10/01/2014 - Alterado o horário limite de execução da tela DEBCNS de 
                17:55hs para as 18:13hs (Carlos)
   
   07/11/2014 - Retirado as declaracoes de variaveis da includes crps663.i
                e declarado aqui na debcns.p para evitar problemas de 
                imcompatibilidade na hora de usar a includes, alteracoes
                referentes a automatizacao da DEBCNS (Tiago SD199974).
   
   28/01/2015 - Alteração da validação onde era passado fixo 18:13
                para hora buscada do banco (Kelvin SD 222608)

   19/11/2015 - Ajustado tamanho do campo para exibir o nome da cooperativa
                que estava sendo exibido cortado (Douglas - Chamado 285228)
                
   15/12/2015 - Passado parametro para procedure efetua-debito-consorcio como
                TRUE (processo manual) - Tiago/Elton             
				
   24/10/2016 - Inserido nova opcao na tela "S - Sumario" para contabilizar
                os lancamentos do dia - Melhoria349 (Tiago/Elton).       
                
   23/10/2017 - Ajustar relatorio e tambem para chamar a rotina efetua-debito-consorcio
                como 3 "Ultima execucao" (Lucas Ranghetti #739738)
..............................................................................*/

{ includes/var_online.i }

DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqcen AS CHAR                                           NO-UNDO.
DEF VAR aux_nmaqcesv AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.

DEF VAR aux_dtmvtopg AS DATE                                           NO-UNDO.

DEF VAR aux_flconfir AS LOGI FORMAT "S/N"                              NO-UNDO.
DEF VAR aux_flgimpri AS LOGI FORMAT "S/N"                              NO-UNDO.
DEF VAR aux_nmcooper AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcooper AS INT                                            NO-UNDO.
DEF VAR aux_cdcoopin AS INT                                            NO-UNDO.
DEF VAR aux_cdcoopfi AS INT                                            NO-UNDO.

DEF VAR tel_cdcooper AS CHAR        FORMAT "x(12)" VIEW-AS COMBO-BOX   
                                                   INNER-LINES 11      NO-UNDO.
DEF VAR aux_dtdebito AS DATE                                           NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.

DEF VAR rel_nmempres AS CHAR    FORMAT "x(15)"                         NO-UNDO.
DEF VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                         NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5                NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                INIT ["DEP. A VISTA   ","CAPITAL        ",
                                      "EMPRESTIMOS    ","DIGITACAO      ",
                                      "GENERICO       "]               NO-UNDO.

DEF VAR rel_nrmodulo AS INTE    FORMAT "9"                             NO-UNDO.

DEF VAR aux_tpconsor AS INTE                                           NO-UNDO.
                                                                       
DEF VAR aux_flsgproc AS LOG INIT FALSE                                 NO-UNDO.
                                                                       
DEF VAR aux_nrctasic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstexarq AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_nrdolote AS INTE                                           NO-UNDO.
DEF VAR aux_nrdolot1 AS INTE                                           NO-UNDO.
DEF VAR aux_nrdolot2 AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_cdcritic AS CHAR                                           NO-UNDO.
                                                                       
DEF VAR aux_cdbccxlt AS INTE                                           NO-UNDO.
                                                                       
DEF VAR aux_flgentra AS LOGICAL                                        NO-UNDO.
DEF VAR flg_ctamigra AS LOGICAL                                        NO-UNDO.
DEF VAR flg_migracao AS LOGICAL                                        NO-UNDO.
                                                                       
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
                                                                       
DEF VAR aux_nrdocmto AS DECIMAL                                        NO-UNDO.
                                                                       
DEF VAR aux_dtrefere AS DATE                                           NO-UNDO.
DEF VAR aux_dscooper AS CHAR FORMAT "x(12)"                            NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_vlefetua AS DECI                                           NO-UNDO.
DEF VAR aux_qtefetua AS INTE                                           NO-UNDO.
DEF VAR aux_dscopglb AS CHAR                                           NO-UNDO.
DEF VAR aux_cdagencic AS CHAR                                          NO-UNDO.
DEF VAR aux_cdcooperativa AS CHAR                                      NO-UNDO.
DEF VAR aux_nrdcontac AS CHAR                                          NO-UNDO.
DEF VAR aux_dstitulo AS CHAR                                           NO-UNDO.
DEF VAR aux_dstiptra AS CHAR                                           NO-UNDO.
                                                                       
DEF VAR aux_nrdoc AS CHAR FORMAT "x(25)" NO-UNDO.                      
                                                                       
DEF VAR aux_qtefetiv  AS  DECIMAL                                      NO-UNDO.
DEF VAR aux_qtnefeti  AS  DECIMAL                                      NO-UNDO.
DEF VAR aux_qtpenden  AS  DECIMAL                                      NO-UNDO.
DEF VAR aux_qttotlan  AS  DECIMAL                                      NO-UNDO.  
                                                                       
DEF TEMP-TABLE tt-obtem-consorcio NO-UNDO
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD nrdconta LIKE crapcns.nrdconta
    FIELD dsconsor AS CHAR FORMAT "x(9)"
    FIELD nrcotcns LIKE crapcns.nrcotcns
    FIELD qtparcns LIKE crapcns.qtparcns
    FIELD vlrcarta LIKE crapcns.vlrcarta
    FIELD vlparcns LIKE crapcns.vlparcns
    FIELD dscooper AS CHAR
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrctacns LIKE crapcns.nrctacns
    FIELD cdagenci AS INTE
    FIELD fldebito AS LOGI
    FIELD dscritic AS CHAR
    FIELD nrdocmto LIKE craplau.nrdocmto
    FIELD nrdgrupo LIKE crapcns.nrdgrupo
    FIELD nrctrato AS DECI FORMAT "zzz,zzz,zzz".   

    FORM SKIP(1)
         "DEBITOS PARA: "                   AT 01
         aux_dtrefere FORMAT "99/99/9999"   AT 15
         aux_dstitulo AT 59 FORMAT "x(13)"
         SKIP(2)
         WITH NO-BOX NO-LABEL WIDTH 132 FRAME f_titulo.

    FORM SKIP(1)
         " PA  "
         "CONTA/DV"
         "CTA.CONSOR"
         "NOME                       "
         "TIPO     "
         "GRUPO "
         "      COTA"
         "     VALOR"
         SKIP
         " --- --------- ---------- --------------------------- ---------"
         "------ ---------- ----------"
         WITH NO-BOX NO-LABEL WIDTH 132 FRAME f_transacao.
    
    FORM SKIP(1)
         "->"
         aux_dstiptra FORMAT "x(19)" SKIP
         "--->"
         aux_dscooper
         WITH NO-BOX NO-LABEL WIDTH 132 FRAME f_transacao1.    

    FORM SKIP(1)
         " PA  "
         "CONTA/DV"
         "CTA.CONSOR"
         "NOME                         "
         "TIPO     "
         "GRUPO "
         "      COTA"
         "     VALOR"
         "CRITICA"
         SKIP
         " --- --------- ---------- --------------------------- ---------"
         "------ ---------- ---------- ---------------------------------------"
         WITH NO-BOX NO-LABEL WIDTH 132 FRAME f_transacao2.

    FORM tt-obtem-consorcio.cdagenci FORMAT "zz9"        
         tt-obtem-consorcio.nrdconta FORMAT "zzzz,zzz,9" 
         tt-obtem-consorcio.nrctacns FORMAT "zzzz,zzz,9" 
         tt-obtem-consorcio.nmprimtl FORMAT "x(27)"      
         tt-obtem-consorcio.dsconsor FORMAT "x(9)"       
         tt-obtem-consorcio.nrdgrupo FORMAT "999999"
         tt-obtem-consorcio.nrcotcns FORMAT "zzzz,zzz,9" 
         tt-obtem-consorcio.vlparcns FORMAT "zzz,zz9.99"
         tt-obtem-consorcio.dscritic FORMAT "x(39)"
         WITH NO-BOX NO-LABEL DOWN WIDTH 132 FRAME f_nao_efetuados.

    FORM tt-obtem-consorcio.cdagenci FORMAT "zz9"          
         tt-obtem-consorcio.nrdconta FORMAT "zzzz,zzz,9"   
         tt-obtem-consorcio.nrctacns FORMAT "zzzz,zzz,9"   
         tt-obtem-consorcio.nmprimtl FORMAT "x(27)"        
         tt-obtem-consorcio.dsconsor FORMAT "x(9)"         
         tt-obtem-consorcio.nrdgrupo FORMAT "999999"
         tt-obtem-consorcio.nrcotcns FORMAT "zzzz,zzz,9"   
         tt-obtem-consorcio.vlparcns FORMAT "zzz,zz9.99" 
         WITH NO-BOX NO-LABEL DOWN WIDTH 132 FRAME f_efetuados.

    FORM SKIP(2)
         "TOTAIS --> Quantidade: "                                      AT 01
         aux_qtefetua FORMAT "zz,zzz,zzz,zz9"                           AT 24
         SKIP
         "                Valor: "                                      AT 01
         aux_vlefetua FORMAT "zzz,zzz,zz9.99"                           AT 24
         WITH NO-BOX NO-LABEL WIDTH 132 FRAME f_total.


 { includes/crps663.i } 

  DEF QUERY q_consorcio FOR tt-obtem-consorcio.

  DEF BROWSE b_consorcio QUERY q_consorcio
      DISPLAY tt-obtem-consorcio.nrdconta COLUMN-LABEL "Conta/dv"
              tt-obtem-consorcio.dsconsor COLUMN-LABEL "Tipo"
              tt-obtem-consorcio.nrcotcns COLUMN-LABEL "Cota"
              tt-obtem-consorcio.qtparcns COLUMN-LABEL "Parcelas"       
              tt-obtem-consorcio.vlrcarta COLUMN-LABEL "Valor Carta"  
              tt-obtem-consorcio.vlparcns COLUMN-LABEL "Valor Parcela" 
              WITH NO-BOX 7 DOWN.

  FORM WITH NO-LABEL TITLE COLOR MESSAGE glb_tldatela
       ROW 4 COLUMN 1 OVERLAY SIZE 80 BY 18 FRAME f_moldura.

  FORM glb_cddopcao AT 03 LABEL "Opcao" AUTO-RETURN
                    HELP "Informe a opcao (C,P,S)."
                    VALIDATE (CAN-DO("C,P,S",glb_cddopcao),"014 - Opcao Errada")
       tel_cdcooper AT 17 LABEL "Cooperativa"
                    HELP "Selecione a Cooperativa"
       aux_dtdebito AT 50 LABEL "Data Debito" FORMAT "99/99/9999"
       WITH NO-LABEL SIDE-LABELS COLUMN 2 ROW 6 OVERLAY NO-BOX FRAME f_opcao.

  FORM b_consorcio HELP "Use as setas para navegar ou <END>/<F4> para sair."  
       WITH ROW 7 OVERLAY COLUMN 3 TITLE " CONSORCIOS AGENDADOS " 
       FRAME f_b_consorcio.

  FORM tt-obtem-consorcio.dscooper FORMAT "x(12)" AT 07 LABEL "Cooperativa"
       tt-obtem-consorcio.cdagenci AT 61 LABEL "PA"
       SKIP
       tt-obtem-consorcio.nmprimtl FORMAT "x(37)" AT 09 LABEL "Cooperado"
       tt-obtem-consorcio.nrdgrupo AT 58 LABEL "Grupo"
       SKIP
       tt-obtem-consorcio.nrctacns AT 03 LABEL "Conta Consorcio"
       tt-obtem-consorcio.nrctrato AT 55 LABEL "Contrato"
       WITH ROW 18 SIDE-LABELS OVERLAY COLUMN 2 NO-BOX FRAME f_dados_consorcio.
   
  FORM SKIP(1)
       aux_qtefetiv FORMAT "z,zzz,zz9"  LABEL "        Efetivados" SKIP(1)
       aux_qtnefeti FORMAT "z,zzz,zz9"  LABEL "    Nao Efetivados" SKIP(1) 
       aux_qtpenden FORMAT "z,zzz,zz9"  LABEL "         Pendentes" SKIP(1)
       aux_qttotlan FORMAT "z,zzz,zz9"  LABEL "             Total" SKIP(1)
       WITH SIDE-LABELS COLUMN 2 ROW 8 OVERLAY WIDTH 78 TITLE "SUMARIO DE AGENDAMENTOS" FRAME f_sumario.
  
/****************************************************************************/
/*********************** INICIO DA ROTINA DE CONSORCIOS *********************/
/****************************************************************************/
ON  VALUE-CHANGED, ENTRY OF b_consorcio DO:
    
    HIDE FRAME  f_dados_consorcio NO-PAUSE.
    HIDE FRAME  f_sumario NO-PAUSE.
     
    DISPLAY tt-obtem-consorcio.dscooper         
            tt-obtem-consorcio.cdagenci
            tt-obtem-consorcio.nmprimtl
            tt-obtem-consorcio.nrdgrupo
            tt-obtem-consorcio.nrctacns
            tt-obtem-consorcio.nrctrato
            WITH FRAME f_dados_consorcio.
END.

ON RETURN OF tel_cdcooper DO:

   ASSIGN tel_cdcooper = tel_cdcooper:SCREEN-VALUE.
   ASSIGN aux_contador = 0.
   APPLY "GO".

END.

VIEW FRAME f_moldura.

PAUSE(0).

RUN fontes/inicia.p.

ASSIGN glb_cddopcao    = "C"
       glb_cdempres    = 11
       glb_cdrelato[1] = 663
       glb_nmdestin[1] = "DESTINO: ADMINISTRATIVO"
       aux_dtdebito    = glb_dtmvtolt.

/* Alimenta SELECTION-LIST de COOPERATIVAS */
IF  glb_cdcooper = 3 THEN
    DO:
        FOR EACH crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK 
                               BY crapcop.cdcooper:

            IF  aux_contador = 0 THEN
                ASSIGN aux_nmcooper = "TODAS,0," + 
                                      CAPS(crapcop.nmrescop) + "," +
                                      STRING(crapcop.cdcooper)
                       aux_contador = 1.
            ELSE
                ASSIGN aux_nmcooper = aux_nmcooper + "," +
                                      CAPS(crapcop.nmrescop) + "," +
                                      STRING(crapcop.cdcooper).
        END.                          

        ASSIGN tel_cdcooper:LIST-ITEM-PAIRS = aux_nmcooper.

       DISPLAY glb_cddopcao tel_cdcooper aux_dtdebito WITH FRAME f_opcao.
    END.
ELSE
    DO:
        DISPLAY glb_cddopcao aux_dtdebito WITH FRAME f_opcao.
        HIDE tel_cdcooper IN FRAME f_opcao.
    END.

DO  WHILE TRUE:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        IF  glb_cdcooper = 3 THEN
            UPDATE glb_cddopcao tel_cdcooper WITH FRAME f_opcao.
        ELSE
            UPDATE glb_cddopcao WITH FRAME f_opcao.
             
        LEAVE.
    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            RUN fontes/novatela.p.
            
            IF  CAPS(glb_nmdatela) <> "DEBCNS"  THEN
                DO:
                    HIDE FRAME f_moldura NO-PAUSE.
                    HIDE FRAME f_opcao   NO-PAUSE.
                    HIDE FRAME f_sumario NO-PAUSE.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> INPUT glb_cddopcao  THEN
        DO:
            { includes/acesso.i }

            ASSIGN aux_cddopcao = INPUT glb_cddopcao.
        END.
 
    /**** Define Inicio e Fim para cooperativas */
    IF  glb_cdcooper = 3 THEN
        ASSIGN aux_cdcooper = INT(tel_cdcooper).
    ELSE
        ASSIGN aux_cdcooper = glb_cdcooper.

    ASSIGN aux_cdcoopfi = IF   aux_cdcooper = 0 THEN
                               99
                          ELSE aux_cdcooper.

    ASSIGN aux_nmarqcen = "crrl663_" + STRING(TIME) + ".lst"
           aux_nmaqcesv = "rlnsv/" + aux_nmarqcen
           aux_nmarqcen = "rl/" + aux_nmarqcen.

    HIDE FRAME f_sumario NO-PAUSE.

    IF  glb_cddopcao = "C"  THEN
        DO:
            /*** PROCESSA COOPERATIVAS ***/
            EMPTY TEMP-TABLE tt-obtem-consorcio. 

            FOR EACH crapcop WHERE crapcop.cdcooper <> 3            AND 
                                   crapcop.cdcooper >= aux_cdcooper AND
                                   crapcop.cdcooper <= aux_cdcoopfi NO-LOCK:

                RUN obtem-consorcio.
    
                IF  RETURN-VALUE <> "OK"  THEN
                    DO:
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT.
                    END.

            END. /* END do FOR EACH crapcop */
                    
            OPEN QUERY q_consorcio FOR EACH tt-obtem-consorcio 
                                   BY tt-obtem-consorcio.nrdconta
                                   BY tt-obtem-consorcio.dsconsor
                                   BY tt-obtem-consorcio.nrcotcns  
                                   BY tt-obtem-consorcio.qtparcns 
                                   BY tt-obtem-consorcio.vlrcarta 
                                   BY tt-obtem-consorcio.vlparcns. 
                                  
            IF  NUM-RESULTS("q_consorcio") = 0  THEN
                DO:
                    BELL.
                    MESSAGE "Nao foram encontrados consorcios pedentes.".
                    CLOSE QUERY q_consorcio.
                    NEXT.
                END.     
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                 UPDATE b_consorcio WITH FRAME f_b_consorcio.
                 LEAVE.
            
            END.
            
            CLOSE QUERY q_consorcio.
            
            HIDE FRAME f_b_consorcio NO-PAUSE.
            HIDE FRAME f_dados_consorcio NO-PAUSE.
            HIDE FRAME f_sumario NO-PAUSE.
             
        END.
    ELSE
    IF  glb_cddopcao = "P" THEN
        DO:
                        
            EMPTY TEMP-TABLE tt-obtem-consorcio.
   
            /*** PROCESSA COOPERATIVAS ***/
            FOR EACH crapcop WHERE crapcop.cdcooper <> 3            AND
                                   crapcop.cdcooper >= aux_cdcooper AND
                                   crapcop.cdcooper <= aux_cdcoopfi NO-LOCK:
                   
                IF  TIME > crapcop.hrlimsic THEN
                    DO:
                        MESSAGE crapcop.nmrescop + " - Horario para processamento ultrapassado.".
                        NEXT.
                    END.    

                ASSIGN glb_dscritic = "".
   
                /*   Verifica somente das cooperativas que tiverem 
                     agendamentos */
                FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper AND
                                   craptab.nmsistem = "CRED"           AND
                                   craptab.tptabela = "GENERI"         AND
                                   craptab.cdempres = 00               AND
                                   craptab.cdacesso = "HRPGSICRED"     AND
                                   craptab.tpregist = 90  NO-LOCK NO-ERROR.
   
                IF  NOT AVAILABLE craptab  THEN
                    ASSIGN glb_dscritic = crapcop.nmrescop +
                                        " - Tabela HRPGSICRED nao cadastrada.".
                ELSE
                    DO:
                        IF  SUBSTR(craptab.dstextab,19,3) = "SIM"  THEN
                            ASSIGN aux_flsgproc = TRUE.
                        ELSE
                            ASSIGN aux_flsgproc = FALSE.
                                                                   
                        /*Verifica se cooperativa optou pelo segundo processo*/
                        IF  NOT aux_flsgproc  THEN
                            ASSIGN glb_dscritic = crapcop.nmrescop +
                                               " - Opcao para processo manual "
                                                  + "desabilitada.".
                        
                        /** Verifica se horario para pagamentos nao esgotou */
                        IF  TIME > INT(ENTRY(1,craptab.dstextab," ")) AND
                            TIME < INT(ENTRY(2,craptab.dstextab," ")) THEN
                            ASSIGN glb_dscritic = crapcop.nmrescop +
                                                  " - Horario para " + 
                                           "pagamentos CONSORCIO nao esgotou". 
                    END.
   
                    IF  glb_dscritic <> ""  THEN
                        DO:
                            MESSAGE glb_dscritic.
                            /* Se houve critica, desconsidera a cooperativa */
                            NEXT.
                        END.
            
                /*** PROCESSA COOPERATIVAS ***/
                RUN obtem-consorcio.
   
                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT.
                    END.
            END.

            OPEN QUERY q_consorcio FOR EACH tt-obtem-consorcio 
                                   BY tt-obtem-consorcio.nrdconta
                                   BY tt-obtem-consorcio.dsconsor
                                   BY tt-obtem-consorcio.nrcotcns  
                                   BY tt-obtem-consorcio.qtparcns 
                                   BY tt-obtem-consorcio.vlrcarta 
                                   BY tt-obtem-consorcio.vlparcns. 
                                  
            IF  NUM-RESULTS("q_consorcio") = 0  THEN
                DO:
                    BELL.
                    MESSAGE "Nao foram encontrados consorcios pedentes.".
                    CLOSE QUERY q_consorcio.
                    NEXT.
                END.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                 UPDATE b_consorcio WITH FRAME f_b_consorcio.
                 LEAVE.
            
            END.
            
            ASSIGN aux_flconfir = FALSE.
   
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
                ASSIGN glb_cdcritic = 78.
                RUN fontes/critic.p.    
                BELL.
                MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_flconfir.
                ASSIGN glb_cdcritic = 0.
                LEAVE.
   
            END.

            CLOSE QUERY q_consorcio.
            
            HIDE FRAME f_b_consorcio NO-PAUSE.
            HIDE FRAME f_dados_consorcio NO-PAUSE.
            HIDE FRAME  f_sumario NO-PAUSE.

            IF  NOT aux_flconfir OR KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                DO:
                    ASSIGN glb_cdcritic = 79.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    ASSIGN glb_cdcritic = 0.
                    NEXT.
                END.            
            
            MESSAGE "Aguarde, debitando consorcios ...".
            
            RUN efetua-debito-consorcio(INPUT TRUE,
			                                  INPUT 3).
            
            HIDE MESSAGE NO-PAUSE.
            
            /**** Define cooperativa Inicio e Fim */
            IF  glb_cdcooper = 3 THEN
                ASSIGN aux_cdcooper = INT(tel_cdcooper).
            ELSE
                ASSIGN aux_cdcooper = glb_cdcooper.
            
            ASSIGN aux_cdcoopfi = IF   aux_cdcooper = 0 THEN 99
                                  ELSE aux_cdcooper.

            FOR EACH crapcop WHERE crapcop.cdcooper <> 3            AND 
                                   crapcop.cdcooper >= aux_cdcooper AND
                                   crapcop.cdcooper <= aux_cdcoopfi 
                                   NO-LOCK:

                ASSIGN aux_nmarquiv = "crrl663_" + STRING(TIME) + ".lst"
                       aux_nmarqimp = "/usr/coop/" + crapcop.dsdircop + 
                                      "/rl/" + aux_nmarquiv
                       aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + 
                                      "/rlnsv/" + aux_nmarquiv.
   
                RUN imprime-consorcios (INPUT crapcop.cdcooper).
            
                IF  RETURN-VALUE = "OK"  THEN
                    UNIX SILENT VALUE ("cat " + aux_nmarqimp + " >> " +
                                       aux_nmarqcen). 
   
            END.
            
            ASSIGN aux_flgimpri = YES.
   
            MESSAGE "Deseja visualizar o Relatorio em Tela? "
                    UPDATE aux_flgimpri.
   
            IF  aux_flgimpri THEN
                RUN fontes/visrel.p (INPUT aux_nmarqcen).

            IF  glb_cdcooper = 3 THEN
                DO:
                    UNIX SILENT VALUE("cp " + aux_nmarqcen + " " + 
                                      aux_nmaqcesv + " 2>/dev/null").
   
                    ASSIGN glb_nrcopias = 1            
                           glb_nmformul = "132col"     
                           glb_nmarqimp = aux_nmarqcen.
   
                    RUN fontes/imprim.p.
                END.
            ELSE
                UNIX SILENT VALUE("rm " + aux_nmarqcen + " 2>/dev/null").

        END. /* fim da opcao P */
    ELSE     
    IF  glb_cddopcao = "S" THEN /*S - Sumario*/
        DO:
            MESSAGE "Carregando...".
   
            RUN sumario_lancamentos(INPUT  aux_cdcooper
                                   ,INPUT  glb_dtmvtolt
                                   ,OUTPUT aux_qtpenden
                                   ,OUTPUT aux_qtefetiv
                                   ,OUTPUT aux_qtnefeti).
                                   
            ASSIGN aux_qttotlan = 0
			       aux_qttotlan = aux_qttotlan + aux_qtpenden + aux_qtefetiv + aux_qtnefeti. /*Total de lancamentos*/
                        
            HIDE FRAME f_b_consorcio NO-PAUSE.
            HIDE FRAME f_dados_consorcio NO-PAUSE.
        
            DISPLAY aux_qtpenden aux_qtefetiv aux_qtnefeti aux_qttotlan WITH FRAME f_sumario.
            
            HIDE MESSAGE NO-PAUSE.
        
        END.
   
END. /*** fim do DO WHILE TRUE: ***/

PROCEDURE sumario_lancamentos:

  DEF INPUT  PARAM par_cdcooper      LIKE    crapcop.cdcooper    NO-UNDO.
  DEF INPUT  PARAM par_dtmvtolt      LIKE    crapdat.dtmvtolt    NO-UNDO.
  
  DEF OUTPUT PARAM par_qtpenden      AS      DECIMAL             NO-UNDO.
  DEF OUTPUT PARAM par_qtefetiv      AS      DECIMAL             NO-UNDO.
  DEF OUTPUT PARAM par_qtnefeti      AS      DECIMAL             NO-UNDO.

  DEF VAR var_qtpenden   AS  DECIMAL       NO-UNDO.
  DEF VAR var_qtefetiv   AS  DECIMAL       NO-UNDO.
  DEF VAR var_qtnefeti   AS  DECIMAL       NO-UNDO.
  DEF VAR var_insitlau   AS  INTEGER       NO-UNDO.
  
  DEF BUFFER crabcop FOR crapcop.

  /*inicializa as variaveis*/
  ASSIGN var_qtpenden = 0
         var_qtefetiv = 0 
         var_qtnefeti = 0
         par_qtpenden = 0
         par_qtefetiv = 0
         par_qtnefeti = 0.

  FOR EACH crabcop NO-LOCK WHERE crabcop.cdcooper <> 3
                             AND crabcop.cdcooper = IF par_cdcooper = 0 THEN
                                                       crabcop.cdcooper
                                                    ELSE
                                                       par_cdcooper:
                     
    ASSIGN var_insitlau = 1.
    
    DO WHILE var_insitlau <= 4:
    
      FOR EACH craplau WHERE craplau.cdcooper = crabcop.cdcooper            AND 
                             craplau.dtmvtopg = par_dtmvtolt                AND
                             craplau.insitlau = var_insitlau                AND 
                            (craplau.cdhistor = 1230                        OR 
                             craplau.cdhistor = 1231                        OR
                             craplau.cdhistor = 1232                        OR 
                             craplau.cdhistor = 1233                        OR 
                             craplau.cdhistor = 1234)                       NO-LOCK:
        
        IF craplau.insitlau = 1 THEN
        DO:
            ASSIGN var_qtpenden = var_qtpenden + 1. /*lanc pendentes*/
        END.
        ELSE
        DO:
          IF craplau.insitlau = 2 THEN
          DO:
            ASSIGN var_qtefetiv = var_qtefetiv + 1. /*lanc efetivados*/
          END.
          ELSE
          DO:
            IF craplau.insitlau >= 3 THEN
            DO:
              ASSIGN var_qtnefeti = var_qtnefeti + 1. /*lanc nao efetivados*/
            END.      
          END.    
        END.
        
      END.                     
      
      ASSIGN var_insitlau = var_insitlau + 1.
   END.   
    
  END.
  ASSIGN par_qtpenden = 0
         par_qtefetiv = 0
         par_qtnefeti = 0
         par_qtpenden = var_qtpenden
         par_qtefetiv = var_qtefetiv
         par_qtnefeti = var_qtnefeti.
  
  RETURN "OK".
END PROCEDURE.