/*-----------------------------------------------------------------------------

    b1crap11.p - Validacao/Atualizacao Inclusao Boletim Caixa 
    
    Alteracoes: 23/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                18/12/2008 - Ajustes para unificacao dos bancos de dados
                             (Evandro).
                             
                30/04/2009 - Excluido os parametros "p-dsc-compl4" e
                             "p-dsc-compl5" da procedure
                             grava-lancamento-boletim (Elton).
                                           
                25/05/2009 - Alteracao CDOPERAD (Kbase).
                
                23/11/2009 - Alteracao Codigo Historico (Kbase).
                
                19/04/2013 - Realizado tratamento para os historicos 1152 e 
                             1153, na procedure grava-lancamento-boletim.
                             Solicitar codigo do operador e senha quando
                             historico for 1152 ou 1153.
                             Realizado tratamento na procedure 
                             valida-existencia-boletim, para apenas permitir
                             valores multiplos de 1000(mil), quando o historico
                             for 1152 ou 1153.
                             (Fabricio)
                             
                02/07/2013 - Criada funcao reabilita-caixa-sangria. (Fabricio)
                
                09/12/2013 - Tratamento temporario para migracao 
                             Acredi x Viacredi; comentado bloco de valores
                             multiplos de 1000(mil) para historico 1152 e
                             1153(sangria de caixa). Procedure
                             valida-existencia-boletim. (Fabricio)
                             
                16/12/2013 - Adicionado validate para tabela crapslc (Tiago).
                
                05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
                
                25/11/2014 - Efetuado tratamento para permitir qualquer valor
                             na sangria de caixa para a Concredi e Credimilsul 
                             no dia 28/11/2014. 
                             Procedure valida-existencia-boletim. (Reinert)
                
                12/06/2017 - Bloquear lancamento do historico 
                             762 - Despesa de Falha Operacional na viacredi
                             (Tiago/Fabricio #661260).
-----------------------------------------------------------------------------*/

{dbo/bo-erro1.i}

DEF VAR i-cod-erro         AS INTEGER.
DEF VAR c-desc-erro        AS CHAR.
DEF VAR h-b1crap00         AS HANDLE                            NO-UNDO.
DEF VAR in99               AS INTE                              NO-UNDO.

DEF VAR p-literal          AS CHAR                              NO-UNDO.
DEF VAR p-ult-sequencia    AS INTE                              NO-UNDO.
DEF var p-registro         AS RECID                             NO-UNDO.

DEF VAR i-nro-docto        AS INTE                              NO-UNDO.
DEF VAR c-docto-salvo      AS CHAR                              NO-UNDO.
DEF VAR c-desc-debito      AS CHAR                              NO-UNDO.
DEF VAR c-desc-credito     AS CHAR                              NO-UNDO.
DEF VAR c-literal          AS CHAR  FORMAT "x(48)" EXTENT 46.
DEF VAR c-linha1           AS CHAR                              NO-UNDO.
DEF VAR c-linha2           AS CHAR                              NO-UNDO.
DEF VAR c-valor            AS CHAR                              NO-UNDO.
DEF VAR c-nome-operador    AS CHAR                              NO-UNDO.
DEF VAR aux_complemento    AS CHAR                              NO-UNDO.
DEF VAR c-texto-2-via      AS CHAR                              NO-UNDO.

FUNCTION reabilita-caixa-sangria RETURNS LOGICAL (INPUT p-cod-cooper  AS INTE,
                                                  INPUT p-cod-agencia AS INTE,
                                                  INPUT p-saldo-caixa AS DECI,
                                                  INPUT p-valor-docto AS DECI)
                                                  FORWARD.

PROCEDURE valida-lancamento-boletim:
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-operador  AS char.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-cod-histor    AS INTE.
       
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
    
    RUN verifica-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    FIND  LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper    AND
                             crapbcx.dtmvtolt = crapdat.dtmvtolt    AND
                             crapbcx.cdagenci = p-cod-agencia       AND
                             crapbcx.nrdcaixa = p-nro-caixa         AND
                             crapbcx.cdopecxa = p-cod-operador      AND
                             crapbcx.cdsitbcx = 1           
                             NO-LOCK NO-ERROR. 
                             
    IF  NOT AVAIL crapbcx  THEN 
        DO:
            ASSIGN i-cod-erro  = 698
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
   
    FIND craphis WHERE craphis.cdcooper = crapcop.cdcooper   AND
                       craphis.cdhistor = p-cod-histor
                       NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL craphis   THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Codigo de Historico nao Cadastrado".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
    
    /* 762 - Despesa de Falha Operacional */    
    IF p-cod-histor     = 762       AND 
       crapcop.cdcooper = 1         THEN
       DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Historico nao permitido. Consulte a sede da cooperativa.". 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
       END.
   
   
    IF  craphis.tplotmov <> 22  THEN 
        DO:
            ASSIGN i-cod-erro  = 100
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.
        
    IF  craphis.indoipmf > 0 THEN
        DO:
            ASSIGN i-cod-erro  = 94
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.

    IF  craphis.indebcre = "D"  AND
        craphis.inhistor = 12   THEN 
        DO:
            ASSIGN i-cod-erro  = 94
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.

    IF  craphis.indebcre = "C"  AND
        craphis.inhistor =  2   THEN 
        DO:
            ASSIGN i-cod-erro  = 94
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.

    RUN verifica-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa).
                       
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    RETURN "OK".
END PROCEDURE.

PROCEDURE retorna-valor-historico:

    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-cod-histor    AS INTE.
    DEF OUTPUT PARAM p-nrctacrd      AS INTE.
    DEF OUTPUT PARAM p-nrctadeb      AS INTE.
    DEF OUTPUT PARAM p-cdhstctb      AS INTE.
    DEF OUTPUT PARAM p-indcompl      AS INTE.
    DEF OUTPUT PARAM p-ds-histor     AS CHAR.
       
    FIND crapcop WHERE crapcop.nmrescop = p-cooper          NO-LOCK NO-ERROR.

    FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper  AND
                       crapage.cdagenci = p-cod-agencia     NO-LOCK NO-ERROR.
  
    FIND craphis WHERE craphis.cdcooper = crapcop.cdcooper  AND
                       craphis.cdhistor = p-cod-histor      NO-LOCK NO-ERROR.
     
    IF  craphis.tpctbcxa = 2    THEN
        ASSIGN p-nrctadeb = crapage.cdcxaage
               p-nrctacrd = craphis.nrctacrd.
    ELSE
        IF  craphis.tpctbcxa = 3    THEN
            ASSIGN p-nrctacrd = crapage.cdcxaage
                    p-nrctadeb = craphis.nrctadeb.
        ELSE
            ASSIGN p-nrctacrd = craphis.nrctacrd
                   p-nrctadeb = craphis.nrctadeb.
    
    ASSIGN p-cdhstctb  = craphis.cdhstctb
           p-indcompl  = craphis.indcompl
           p-ds-histor = craphis.dshistor.
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE grava-lancamento-boletim:
    DEF INPUT  PARAM p-cooper               AS CHAR.
    DEF INPUT  PARAM p-cod-operador         AS CHAR.
    DEF INPUT  PARAM p-cod-agencia          AS INTE.
    DEF INPUT  PARAM p-nro-caixa            AS INTE.
    DEF INPUT  PARAM p-cod-histor           AS INTE.    
    DEF INPUT  PARAM p-vlr-docto            AS DEC.
    DEF INPUT  PARAM p-dsc-compl1           AS CHAR.
    DEF INPUT  PARAM p-dsc-compl2           AS CHAR.
    DEF INPUT  PARAM p-dsc-compl3           AS CHAR.
     
    DEF INPUT  PARAM p-codigo               AS CHAR.
    DEF INPUT  PARAM p-senha                AS CHAR.

    DEF INPUT  PARAM p-debito               AS CHAR.
    DEF INPUT  PARAM p-credito              AS CHAR.
    DEF INPUT  PARAM p-hist-contab          AS CHAR.

    DEF INPUT  PARAM p-docto                AS INTE.
    DEF OUTPUT PARAM p-pg                   AS LOG.
    DEF OUTPUT PARAM p-literal-autentica    AS CHAR.
    DEF OUTPUT PARAM p-ult-sequencia        AS INTE.

    DEF VAR v-saldo-caixa AS DECI.
    DEF VAR v-flg-sangria AS LOGI.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
          
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
    
    ASSIGN c-docto-salvo = STRING(TIME).
   
    IF  p-docto = 0 THEN
        ASSIGN i-nro-docto = INTE(c-docto-salvo).
    ELSE
        ASSIGN i-nro-docto = p-docto.
       
    RUN valida-permissao-historico IN THIS-PROCEDURE (INPUT p-cooper,
                                                      INPUT p-cod-agencia, 
                                                      INPUT p-nro-caixa, 
                                                      INPUT p-cod-operador, 
                                                      INPUT p-codigo, 
                                                      INPUT p-senha,
                                                      INPUT p-cod-histor).
    IF  RETURN-VALUE = 'NOK' THEN
        RETURN 'NOK'.       

    FIND craphis WHERE craphis.cdcooper = crapcop.cdcooper   AND
                       craphis.cdhistor = p-cod-histor
                       NO-LOCK NO-ERROR.
    
    IF  craphis.indebcre = "C" THEN
        ASSIGN p-pg = NO.   /* Credito = Recebimento */
    ELSE
        ASSIGN p-pg = YES.  /* Debito = Pagamento */

    ASSIGN in99 = 0.
    DO WHILE TRUE:
    
        FIND LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper     AND
                                crapbcx.dtmvtolt = crapdat.dtmvtolt     AND
                                crapbcx.cdagenci = p-cod-agencia        AND
                                crapbcx.nrdcaixa = p-nro-caixa          AND
                                crapbcx.cdopecxa = p-cod-operador       AND
                                crapbcx.cdsitbcx = 1  
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
        ASSIGN in99 = in99 + 1.
        IF  NOT AVAILABLE crapbcx THEN  
            DO:
                IF  LOCKED crapbcx   THEN  
                    DO:
                        IF  in99 <  100  THEN  
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                        ELSE 
                            DO:
                                ASSIGN i-cod-erro  = 0
                                       c-desc-erro = "Tabela CRAPBCX em uso ".
                                RUN cria-erro (INPUT p-cooper,
                                               INPUT p-cod-agencia,
                                               INPUT p-nro-caixa,
                                               INPUT i-cod-erro,
                                               INPUT c-desc-erro,
                                               INPUT YES).
                                RETURN "NOK".
                            END.
                    END.
                ELSE 
                    DO:
                        ASSIGN i-cod-erro  = 698
                               c-desc-erro = " ".           
                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK".
                    END.
            END.
        LEAVE.
    END.  /*  DO WHILE */

    /* Tratamento SANGRIA DE CAIXA */
    IF p-cod-histor = 1152 OR p-cod-histor = 1153 THEN
    DO:
        ASSIGN in99 = 0
               v-flg-sangria = TRUE.

        DO WHILE TRUE:

            FIND crapslc WHERE crapslc.cdcooper = crapcop.cdcooper AND
                           crapslc.cdagenci = p-cod-agencia        AND
                           crapslc.nrdcofre = 1
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
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = "Tabela CRAPSLC em uso.".

                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).

                        RETURN "NOK".
                    END.
                END.
                ELSE
                DO:
                    IF p-cod-histor = 1153 THEN
                    DO:
                        ASSIGN i-cod-erro = 0
                               c-desc-erro = "Saldo indisponivel no cofre " +
                                             "para realizar essa operacao.".

                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).

                        RETURN "NOK".
                    END.
                    ELSE
                    IF p-cod-histor = 1152 THEN
                    DO:
                        RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.

                        RUN verifica-saldo-caixa IN h-b1crap00 
                                                   (INPUT crapcop.cdcooper,
                                                    INPUT crapcop.nmrescop,
                                                    INPUT p-cod-agencia,
                                                    INPUT p-nro-caixa,
                                                    INPUT p-cod-operador,
                                                   OUTPUT v-saldo-caixa).

                        IF VALID-HANDLE(h-b1crap00) THEN
                            DELETE OBJECT h-b1crap00.

                        IF RETURN-VALUE = "NOK" THEN
                            RETURN "NOK".

                        IF p-vlr-docto > v-saldo-caixa THEN
                        DO:
                            ASSIGN i-cod-erro = 0
                                   c-desc-erro = "Saldo insuficiente no caixa "
                                               + "para realizar essa operacao.".

                            RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT i-cod-erro,
                                           INPUT c-desc-erro,
                                           INPUT YES).

                            RETURN "NOK".
                        END.

                        CREATE crapslc.
                        ASSIGN crapslc.cdcooper = crapcop.cdcooper
                               crapslc.cdagenci = p-cod-agencia
                               crapslc.nrdcofre = 1
                               crapslc.vlrsaldo = p-vlr-docto.
                        VALIDATE crapslc.

                        ASSIGN v-flg-sangria = reabilita-caixa-sangria
                                                      (INPUT crapcop.cdcooper,
                                                       INPUT p-cod-agencia,
                                                       INPUT v-saldo-caixa,
                                                       INPUT p-vlr-docto)
                               crapbcx.flgcxsgr = v-flg-sangria
                               crapbcx.hrultsgr = TIME WHEN v-flg-sangria AND p-cod-histor = 1152.

                    END.
                END.
            END.
            ELSE
            DO:
                IF p-cod-histor = 1153 THEN
                DO:
                    IF p-vlr-docto > crapslc.vlrsaldo THEN
                    DO:
                        ASSIGN i-cod-erro = 0
                               c-desc-erro = "Saldo insuficiente no cofre " +
                                             "para realizar essa operacao.".

                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).

                        RETURN "NOK".
                    END.

                    ASSIGN crapslc.vlrsaldo = crapslc.vlrsaldo - p-vlr-docto.

                END.
                ELSE
                IF p-cod-histor = 1152 THEN
                DO:
                    RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.

                    RUN verifica-saldo-caixa IN h-b1crap00 
                                                   (INPUT crapcop.cdcooper,
                                                    INPUT crapcop.nmrescop,
                                                    INPUT p-cod-agencia,
                                                    INPUT p-nro-caixa,
                                                    INPUT p-cod-operador,
                                                   OUTPUT v-saldo-caixa).

                    IF VALID-HANDLE(h-b1crap00) THEN
                        DELETE OBJECT h-b1crap00.

                    IF RETURN-VALUE = "NOK" THEN
                        RETURN "NOK".

                    IF p-vlr-docto > v-saldo-caixa THEN
                    DO:
                        ASSIGN i-cod-erro = 0
                               c-desc-erro = "Saldo insuficiente no caixa "
                                           + "para realizar essa operacao.".

                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).

                        RETURN "NOK".
                    END.

                    ASSIGN crapslc.vlrsaldo = crapslc.vlrsaldo + p-vlr-docto.

                    ASSIGN v-flg-sangria = reabilita-caixa-sangria
                                                      (INPUT crapcop.cdcooper,
                                                       INPUT p-cod-agencia,
                                                       INPUT v-saldo-caixa,
                                                       INPUT p-vlr-docto)
                           crapbcx.flgcxsgr = v-flg-sangria
                           crapbcx.hrultsgr = TIME WHEN v-flg-sangria AND p-cod-histor = 1152.

                END.
            END.

            LEAVE.
        END.
								END.                          
										  
							CREATE craplcx.
							ASSIGN craplcx.cdcooper = crapcop.cdcooper
									craplcx.dtmvtolt = crapdat.dtmvtolt
	 		    craplcx.cdagenci = p-cod-agencia
	 		    craplcx.nrdcaixa = p-nro-caixa
	 		    craplcx.cdopecxa = p-cod-operador
	 		    craplcx.nrdocmto = i-nro-docto
			    craplcx.nrseqdig = crapbcx.qtcompln + 1
			    craplcx.nrdmaqui = p-nro-caixa
			    craplcx.cdhistor = p-cod-histor
			    aux_complemento  = STRING(CAPS(p-dsc-compl1),"x(26)")  + 
								   STRING(CAPS(p-dsc-compl2),"x(26)")  +
								   STRING(CAPS(p-dsc-compl3),"x(26)") 
			    craplcx.dsdcompl = aux_complemento
			    crapbcx.qtcompln = crapbcx.qtcompln + 1
			    craplcx.vldocmto = p-vlr-docto.
	  
	
    RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
    RUN grava-autenticacao  IN h-b1crap00 (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT p-cod-operador,
                                           INPUT p-vlr-docto,
                                           INPUT DEC(i-nro-docto),
                                           INPUT p-pg, /* YES (PG), NO (REC) */
                                           INPUT "1",  /* On-line           */ 
                                           INPUT NO,    /* Nao estorno        */
                                           INPUT p-cod-histor, 
                                           INPUT ?, /* Data off-line */
                                           INPUT 0, /* Sequencia off-line */
                                           INPUT 0, /* Hora off-line */
                                           INPUT 0, /* Seq.orig.Off-line */

                                           OUTPUT p-literal,
                                           OUTPUT p-ult-sequencia,
                                           OUTPUT p-registro).
    DELETE PROCEDURE h-b1crap00.
    
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    /* Atualiza sequencia Autenticacao */
    ASSIGN  craplcx.nrautdoc = p-ult-sequencia.

    ASSIGN p-literal-autentica = p-literal.

    IF  craphis.indcompl = 1    /*  AND     
        craphis.cdhistor <> 746  */ THEN 
        DO:
    
            /*----- Gera Autenticacao Recebimento   --------*/ 
 
            IF  p-debito BEGINS "11" THEN
                ASSIGN c-desc-debito = " - CAIXA".
            ELSE
                ASSIGN c-desc-debito = " - ________________________________".
        
            IF  p-credito BEGINS "11" THEN
                ASSIGN c-desc-credito = " - CAIXA".
            ELSE
                ASSIGN c-desc-credito = " - ________________________________".
    
            ASSIGN c-literal = " ".
            ASSIGN c-literal[1] = TRIM(crapcop.nmrescop) +  " - " + 
                                  TRIM(crapcop.nmextcop) 
                   c-literal[2] = " "
                   c-literal[3] = STRING(crapdat.dtmvtolt,"99/99/99") + " " +
                                  STRING(TIME,"HH:MM:SS")     +  " PA " + 
                                  STRING(p-cod-agencia,"999") + 
                                  "  CAIXA: " +
                                  STRING(p-nro-caixa,"Z99") + "/" +
                                  SUBSTR(p-cod-operador,1,10)  
                   c-literal[4] = " " 
                   c-literal[5] = "      ** DOCUMENTO DE CAIXA " + 
                                  STRING(i-nro-docto,"ZZZ,ZZ9")  + " **" 
                   c-literal[6] = " " 

                   c-literal[7] = STRING(p-cod-histor,"9999") +
                                   " - " + craphis.dshistor              

                   c-literal[8]  = " "            
                   c-literal[9]  = "DEBITO : " + p-debito +  c-desc-debito
                   c-literal[10] = " "      

                   c-literal[11] = "CREDITO: " + p-credito + c-desc-credito
                   c-literal[12] = " "      

                   c-literal[13] = "HST CTL: " + p-hist-contab  
                   c-literal[14] = " ".      

            IF  p-dsc-compl1 <> " " THEN
                ASSIGN c-literal[15] = CAPS(p-dsc-compl1).           
            ELSE
                ASSIGN c-literal[15] = " ". 
                          
            IF  p-dsc-compl2 <> " " THEN
                ASSIGN c-literal[16] = CAPS(p-dsc-compl2).        
            ELSE
                ASSIGN c-literal[16] = " ". 
  
            IF  p-dsc-compl3 <> " " THEN
                ASSIGN c-literal[17] = CAPS(p-dsc-compl3).       
            ELSE
                ASSIGN c-literal[17] = " ". 

            RUN dbo/pcrap12.p (INPUT  p-vlr-docto,
                               INPUT  47,
                               INPUT  47,
                               INPUT  "M",
                               OUTPUT c-linha1,
                               OUTPUT c-linha2).

            ASSIGN c-valor = FILL(" ",14 - 
                             LENGTH(TRIM(STRING(p-vlr-docto,
                                                "zzz,zzz,zz9.99")))) + 
                             "*" + 
                            (TRIM(STRING(p-vlr-docto,"zzz,zzz,zz9.99"))).
    
            FIND FIRST crapope WHERE crapope.cdcooper = crapcop.cdcooper    AND
                                     crapope.cdoperad = p-cod-operador 
                                     NO-LOCK NO-ERROR.
                                     
            IF  AVAIL crapope THEN
                ASSIGN c-nome-operador = crapope.nmoperad.
    
            ASSIGN c-literal[20] = " "
                   c-literal[21] = "VALOR DE R$    " + c-valor
                   c-literal[22] = "(" + TRIM(c-linha1)
                   c-literal[23] = TRIM(c-linha2) + ")"
                   c-literal[24] = " "
                   c-literal[25] = " "          
                   c-literal[26] = " "
                   c-literal[27] = "ASSINATURAS:"
                   c-literal[28] = " "
                   c-literal[29] = " "
                   c-literal[30] = 
                            "_______________________________________________"
                   c-literal[31] = SUBSTR(p-cod-operador,1,10) + " - " +
                                   c-nome-operador
                   c-literal[32] = " "
                   c-literal[33] = " "
                   c-literal[34] = " "
                   c-literal[35] = 
                            "APROVADO POR: _________________________________" 
                   c-literal[36] = " "
                   c-literal[37] = p-literal   
                   c-literal[38] = " "
                   c-literal[39] = " "
                   c-literal[40] = " "
                   c-literal[41] = " "
                   c-literal[42] = " "
                   c-literal[43] = " "
                   c-literal[44] = " "
                   c-literal[45] = " "
                   c-literal[46] = " ".

            ASSIGN p-literal-autentica = STRING(c-literal[1],"x(48)")    + 
                                         STRING(c-literal[2],"x(48)")    + 
                                         STRING(c-literal[3],"x(48)")    + 
                                         STRING(c-literal[4],"x(48)")    + 
                                         STRING(c-literal[5],"x(48)")    + 
                                         STRING(c-literal[6],"x(48)")    + 
                                         STRING(c-literal[7],"x(48)")    + 
                                         STRING(c-literal[8],"x(48)")    + 
                                         STRING(c-literal[9],"x(48)")    + 
                                         STRING(c-literal[10],"x(48)")   +   
                                         STRING(c-literal[11],"x(48)")   + 
                                         STRING(c-literal[12],"x(48)")   +
                                         STRING(c-literal[13],"x(48)")   + 
                                         STRING(c-literal[14],"x(48)").    

            IF  c-literal[15] <> " " THEN
                ASSIGN p-literal-autentica = p-literal-autentica +                                              STRING(c-literal[15],"x(48)").
 
            IF  c-literal[16] <> " " THEN
                ASSIGN p-literal-autentica = p-literal-autentica +                                              STRING(c-literal[16],"x(48)").
  
            IF  c-literal[17] <> " " THEN
                ASSIGN p-literal-autentica = p-literal-autentica +                                              STRING(c-literal[17],"x(48)").

            IF  c-literal[18] <> " " THEN
                ASSIGN p-literal-autentica = p-literal-autentica +                                              STRING(c-literal[18],"x(48)").
                     
            IF  c-literal[19] <> " " THEN
                ASSIGN p-literal-autentica = p-literal-autentica +                                              STRING(c-literal[19],"x(48)"). 

            ASSIGN p-literal-autentica = p-literal-autentica             +
                                         STRING(c-literal[20],"x(48)")   + 
                                         STRING(c-literal[21],"x(48)")   + 
                                         STRING(c-literal[22],"x(48)")   + 
                                         STRING(c-literal[23],"x(48)")   + 
                                         STRING(c-literal[24],"x(48)")   + 
                                         STRING(c-literal[25],"x(48)")   +
                                         STRING(c-literal[26],"x(48)")   + 
                                         STRING(c-literal[27],"x(48)")   + 
                                         STRING(c-literal[28],"x(48)")   + 
                                         STRING(c-literal[29],"x(48)")   + 
                                         STRING(c-literal[30],"x(48)")   + 
                                         STRING(c-literal[31],"x(48)")   + 
                                         STRING(c-literal[32],"x(48)")   + 
                                         STRING(c-literal[33],"x(48)")   + 
                                         STRING(c-literal[34],"x(48)")   +
                                         STRING(c-literal[35],"x(48)")   +
                                         STRING(c-literal[36],"x(48)")   + 
                                         STRING(c-literal[37],"x(48)")   + 
                                         STRING(c-literal[38],"x(48)")   + 
                                         STRING(c-literal[39],"x(48)")   + 
                                         STRING(c-literal[40],"x(48)")   + 
                                         STRING(c-literal[41],"x(48)")   + 
                                         STRING(c-literal[42],"x(48)")   + 
                                         STRING(c-literal[43],"x(48)")   + 
                                         STRING(c-literal[44],"x(48)")   +
                                         STRING(c-literal[45],"x(48)")   + 
                                         STRING(c-literal[46],"x(48)").     
     
            /*-- 
            ASSIGN c-texto-2-via = p-literal-autentica.
    
            ASSIGN p-literal-autentica = p-literal-autentica + c-texto-2-via.
            --*/
    
            ASSIGN in99 = 0. 
            DO  WHILE TRUE:
        
                ASSIGN in99 = in99 + 1.
                FIND FIRST crapaut WHERE RECID(crapaut) = p-registro 
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
                                        ASSIGN i-cod-erro  = 0
                                               c-desc-erro = 
                                                    "Tabela CRAPAUT em uso ".
                                        RUN cria-erro (INPUT p-cooper,
                                                       INPUT p-cod-agencia,
                                                       INPUT p-nro-caixa,
                                                       INPUT i-cod-erro,
                                                       INPUT c-desc-erro,
                                                       INPUT YES).
                                        RETURN "NOK".
                                    END.
                            END.
                    END.
                ELSE 
                    DO:
                        ASSIGN  crapaut.dslitera = p-literal-autentica.
                        RELEASE crapaut.
                        LEAVE.
                    END.
            END. /* DO  WHILE TRUE */
    
        END.
    
    RELEASE crapbcx.
    RELEASE craplcx.

    RETURN "OK".
END.

PROCEDURE valida-permissao-historico:

    DEF INPUT  PARAM p-cooper           AS CHAR.
    DEF INPUT  PARAM p-cod-agencia      AS INTE.
    DEF INPUT  PARAM p-nro-caixa        AS INTE.
    DEF INPUT  PARAM p-cod-operador     AS CHAR.
    DEF INPUT  PARAM p-codigo           AS char.
    DEF INPUT  PARAM p-senha            AS CHAR.
    DEF INPUT  PARAM p-cod-histor       AS INTEGER NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    IF  p-cod-histor <> 701     AND 
        p-cod-histor <> 702     AND
        p-cod-histor <> 733     AND 
        p-cod-histor <> 734     AND
        p-cod-histor <> 1152    AND
        p-cod-histor <> 1153    THEN
        RETURN 'OK'.

    IF  p-codigo = "" THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Informe Codigo/Senha ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    FIND FIRST crapope WHERE crapope.cdcooper = crapcop.cdcooper    AND
                             crapope.cdoperad = p-codigo    
                             NO-LOCK NO-ERROR.
                             
    IF  NOT AVAIL crapope THEN 
        DO:
            ASSIGN i-cod-erro  = 67
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    IF  p-senha <> crapope.cddsenha  THEN
        DO:
            ASSIGN i-cod-erro  = 3
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    /* 1 - Operador, 2-Supervisor , 3-Gerente  */
    IF  crapope.nvoperad <> 2     AND 
        crapope.nvoperad <> 3     AND
            p-cod-histor <> 1152  AND
            p-cod-histor <> 1153  THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro =
                        "Somente um Coordenador pode liberar o lancamento.".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE valida-existencia-boletim:

    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-operador  AS char.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-cod-histor    AS INTE.
    DEF INPUT  PARAM p-nro-docto     AS INTE.
    DEF INPUT  PARAM p-valor         AS DEC.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
    
    FIND craphis WHERE craphis.cdcooper = crapcop.cdcooper   AND
                       craphis.cdhistor = p-cod-histor
                       NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL craphis  THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Codigo de Historico nao Cadastrado".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
    
    IF (craphis.indcompl = 0    /*  OR
        craphis.cdhistor = 746 */)  AND
        p-nro-docto      = 0        THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Documento deve ser Informado".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
    
    IF  p-valor     = 0 THEN DO: 
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Valor deve ser Informado".
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.
                     
    IF  p-nro-docto > 0 THEN 
        DO:
            FIND FIRST craplcx WHERE craplcx.cdcooper = crapcop.cdcooper    AND
                                     craplcx.dtmvtolt = crapdat.dtmvtolt    AND
                                     craplcx.cdagenci = p-cod-agencia       AND
                                     craplcx.nrdcaixa = p-nro-caixa         AND
                                     craplcx.cdopecxa = p-cod-operador      AND
                                     craplcx.nrdocmto = p-nro-docto         AND
                                     craplcx.cdhistor = p-cod-histor
                                     USE-INDEX craplcx2 NO-LOCK NO-ERROR.
                                     
            IF  AVAIL craplcx THEN 
                DO: 
                    ASSIGN i-cod-erro  = 92
                           c-desc-erro = " ".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
        END.
    /* Chamado 112510 - Devido a migracao Acredi x Viacredi, foi solicitado
                        no chamado em questao, a liberacao de qualquer valor
                        para procedimentos de recolhimento e suprimento do
                        caixa, entre os dias 30/12/2013 a 01/01/2014. Apos
                        este periodo, o tratamento em questao volta a ser
                        utilizado. */
    /* Chamado 224322 - Foi solicitado a liberacao de qualquer valor de recolhimento
                        ou de suprimento do caixa no dia 28/11/2014 devido a incorporacao
                        da Concredi e Credimilsul */
    IF (crapdat.dtmvtolt < 11/28/2014  AND
       (crapcop.cdcooper = 4 OR crapcop.cdcooper = 15))  OR
       (crapcop.cdcooper <> 4 AND crapcop.cdcooper <> 15)  THEN
        DO:
            IF p-cod-histor = 1152 OR p-cod-histor = 1153 THEN
            DO:
                IF p-valor MOD 1000 <> 0 OR
                INDEX(STRING(p-valor), ",") > 0     THEN
                DO:
                    ASSIGN i-cod-erro = 0
                           c-desc-erro = "Permitido apenas valores multiplos de " +
                                         "1.000 (mil) para este historico.".
        
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
        
                    RETURN "NOK".
                END.
            END.
        END.
        
    RETURN "OK".
    
END PROCEDURE.

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
    
/* b1crap11.p */

/* .......................................................................... */

 
