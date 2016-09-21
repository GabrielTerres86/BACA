/* .............................................................................

   Programa: Fontes/bo_imp_ctr_saques.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Julho/2003.                     Ultima atualizacao: 28/10/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Fazer o tratamento para impressao do controle de   
               movimentacao em especie.

   Alteracoes: 30/09/2003 - Nao registrar acima de R$ 100.00 quando pessoa
                            juridica (Margarete).    

               02/03/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
                
               02/04/2007 - Alterado variaveis de endereco para receberem
                            valores da estrutura crapenc (Elton).
                            
               16/12/2008 - Verificacao da data de parametro na procedure 
                            bo_imp_ctr_saques (Guilherme).

               22/12/2008 - Ajustes para unificacao dos bancos de dados
                            (Evandro).
                            
               10/12/2009 - Ajustar BO para o tratamento da rotina 20 DOC/TED,
                            os dados nao são extraidos da craplcm e sim da 
                            craptvl. (Fernando).       .
                            
               16/04/2010 - Adicionado parametros flgdebcc para verificar
                            se a transação em especie gerou débito em C/C ou
                            não - rotina 20 (sem deb) e demais. (Fernando). 
                            
               23/06/2010 - A procedure bo_imp_ctr_saques utilizava a data do
                            movimento atual para buscar as movimentacoes em
                            especie, porem o correto é utilizar a data passada
                            como parametro (Fernando).                               
                            
               20/10/2010 - Incluido caminho completo nas referencias do 
                            diretorio spool (Elton).             

               06/04/2011 - Acertar atualizacao do campo tpoperac (Magui).
               
               20/05/2011 - Retirar campo Registrar.
                            Enviar email de controle de movimentacao.
                            Incluir campo de 'Informar destinatario' e 
                            'Informar ao COAF' (Gabriel).
                            
               23/05/2011 - Alterada a leitura da tabela craptab para a 
                            tabela crapope (Isara - RKAM).            
                            
               25/07/2011 - Nao informar ao COAF quando conta Administrativa
                            (Gabriel)                            
                            
               20/09/2011 - Incluir campo valor sacado do PAC (Gabriel). 
               
               30/09/2011 - Alterar diretorio spool para
                             /usr/coop/sistema/siscaixa/web/spool (Fernando).
                             
                          - Mudada a extensao do arquivo de ".txt" para ".ex"
                            (Gabriel).                           
               
               17/11/2011 - Tratamento para depositos entre cooperativas na 
                            procedure atualiza-crapcme (Elton).
               
               24/11/2011 - Diminuir frame de impressao pra 1 folha (Gabriel).
               
               01/12/2011 - Ajuste para a transferencia intercooperativa
                            (Gabriel)     
                            
               12/11/2013 - Atribuicao para o parametro par_nmarqimp
                            independentemente de enviar o arquivo para
                            impressora ou nao; necessario para o Ayllos
                            Web - Tela TRAESP. (Fabricio)
                            
               28/10/2015 - Correcao de avail crapass (estava avail crablcm).
                            Adicionado sequencial na descricao da critica 90. 
                            (Carlos)
............................................................................. */

{dbo/bo-erro1.i}
{ sistema/generico/includes/var_internet.i }

DEF BUFFER crabcme FOR crapcme.
DEF BUFFER crabass FOR crapass.
DEF BUFFER crablcm FOR craplcm.
                        
DEF  VAR i-cod-erro     AS INTEGER.
DEF  VAR c-desc-erro    AS CHAR.
DEF  VAR rel_linhadet   AS CHAR FORMAT "x(70)".
DEF  VAR rel_nmextcop   AS CHAR FORMAT "x(70)".
DEF  VAR rel_nmrescop   AS CHAR FORMAT "x(70)".
DEF  VAR rel_tppessoa   AS CHAR FORMAT "x(08)".
DEF  VAR rel_nrcpfcgc   AS CHAR FORMAT "x(18)".
DEF  VAR rel_nmpesrcb   AS CHAR FORMAT "x(70)".
DEF  VAR rel_tppesrcb   AS CHAR FORMAT "x(08)".
DEF  VAR rel_cpfcgrcb   AS CHAR FORMAT "x(18)".
DEF  VAR rel_tpoperac   AS CHAR FORMAT "x(08)".
DEF  VAR rel_vllanmto   AS CHAR FORMAT "x(10)".

DEF VAR aux_nmarqimp    AS CHAR                                 NO-UNDO.
DEF VAR aux_nrdolote    AS INTE                                 NO-UNDO.

DEF STREAM str_1.
DEF   VAR l-retorno     AS LOG                                  NO-UNDO.
DEF   VAR tel_dsdlinha  AS CHAR                                 NO-UNDO.

DEF VAR aux_nmdafila    AS CHAR                                 NO-UNDO.
DEF VAR i-nro-vias      AS INTE                                 NO-UNDO.
DEF VAR aux_dscomand    AS CHAR                                 NO-UNDO.

FORM SKIP(3)
     "\022\024\033\120" /* reseta impressora */
     rel_nmrescop
     SKIP(1)
     rel_nmextcop
     rel_linhadet
     SKIP(3)
     "\033\017\033\016CONTROLE DE MOVIMENTACAO EM \024\022" 
     "\033\017\033\016ESPECIE  -  LEI No. 9613/98 \024\022"
     SKIP(2)
     "\033\017\033\016OPERACAO:\024\022"
     SKIP(2)
     "Tipo de Operacao:" rel_tpoperac "      Documento:" crabcme.nrdocmto
     SKIP
     "     Valor em R$:" rel_vllanmto
     SKIP(2)
     "\033\017\033\016TITULAR:\024\022"
     SKIP(1)
     "      Conta/Dv:" crabcme.nrdconta
     SKIP
     " Nome Completo:" crabass.nmprimtl
     SKIP
     "Tipo de Pessoa:" rel_tppessoa "       Cnpj/Cpf:" rel_nrcpfcgc
     SKIP
     "      Endereco:" crapenc.dsendere               
     SKIP
     "        Cidade:" crapenc.nmcidade FORMAT "x(25)" "Uf:" crapenc.cdufende 
     "  Cep:" crapenc.nrcepend
     SKIP(2)
     "\033\017\033\016SACADOR:\024\022"
     SKIP(1)
     rel_nmpesrcb
     SKIP
     "Tipo de Pessoa:" rel_tppesrcb "       Cnpj/Cpf:" rel_cpfcgrcb
     SKIP
     "    Identidade:" crabcme.nridercb "Data de Nascimento:" crabcme.dtnasrcb
     SKIP
     "      Endereco:" crabcme.desenrcb
     SKIP
     "        Cidade:" crabcme.nmcidrcb "Uf:" crabcme.cdufdrcb 
     "  Cep:" crabcme.nrceprcb
     SKIP(1)
     "Destino:" crabcme.dstrecur FORMAT "x(50)"
     SKIP(3)
     "Declaro(amos) assumir integral responsabilidade pelas declaracoes"
     SKIP
     "aqui prestadas."
     SKIP(2)
     "DATA:" crabcme.dtmvtolt
     SKIP(5) SPACE(6)
     "-------------------------------    -------------------------------"
     SKIP SPACE(6)
     "   COOPERADO(A)                      FUNCIONARIO(A)"
     SKIP SPACE(6)
     "                                    CADASTRO E VISTO"
     SKIP(4) SPACE(6)
     "                                   -------------------------------"
     SKIP SPACE(6)
     "                                     COORDENADOR(A)"
     SKIP SPACE(6)
     "                                    CADASTRO E VISTO"
     WITH FRAME f_comprovante_cooperado NO-BOX NO-LABELS COLUMN 10.

FORM SKIP(3)
     "\022\024\033\120" /* reseta impressora */
     rel_nmrescop
     SKIP(1)
     rel_nmextcop
     rel_linhadet
     SKIP(3)
     "\033\017\033\016CONTROLE DE MOVIMENTACAO EM \024\022" 
     "\033\017\033\016ESPECIE  -  LEI No. 9613/98 \024\022"
     SKIP(2)
     "\033\017\033\016OPERACAO:\024\022"
     SKIP(2)
     "Tipo de Operacao:" rel_tpoperac "      Documento:" crabcme.nrdocmto
     SKIP
     "     Valor em R$:" rel_vllanmto
     SKIP(2)
     "\033\017\033\016REMETENTE:\024\022"
     SKIP(1)
     rel_nmpesrcb
     SKIP
     "Tipo de Pessoa:" rel_tppesrcb "       Cnpj/Cpf:" rel_cpfcgrcb
     SKIP
     "    Identidade:" crabcme.nridercb "Data de Nascimento:" crabcme.dtnasrcb
     SKIP
     "      Endereco:" crabcme.desenrcb
     SKIP
     "        Cidade:" crabcme.nmcidrcb "Uf:" crabcme.cdufdrcb 
     "  Cep:" crabcme.nrceprcb
     SKIP(2)
     "Destino:" crabcme.dstrecur FORMAT "x(50)"
     SKIP(3)
     "Declaro(amos) assumir integral responsabilidade pelas declaracoes"
     SKIP
     "aqui prestadas."
     SKIP(3)
     "DATA:" crabcme.dtmvtolt
     SKIP(6) SPACE(6)
     "-------------------------------    -------------------------------"
     SKIP SPACE(6)
     "   COOPERADO(A)                      FUNCIONARIO(A)"
     SKIP SPACE(6)
     "                                    CADASTRO E VISTO"
     SKIP(6) SPACE(6)
     "                                   -------------------------------"
     SKIP SPACE(6)
     "                                     COORDENADOR(A)"
     SKIP SPACE(6)
     "                                    CADASTRO E VISTO"
     WITH FRAME f_comprovante_naocooperado NO-BOX NO-LABELS COLUMN 10.

FORM SKIP(1) WITH NO-BOX FRAME f_linha STREAM-IO.

PROCEDURE bo_imp_ctr_saques:
 
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM par_cdoperad    LIKE crapope.cdoperad.
    DEF INPUT  PARAM par_cdagenci    LIKE craplcm.cdagenci.
    DEF INPUT  PARAM par_nrdcaixa    LIKE craplot.nrdcaixa.
    DEF INPUT  PARAM par_nrdolote    LIKE craplcm.nrdolote.
    DEF INPUT  PARAM par_nrdocmto    LIKE craplcm.nrdocmto.
    DEF INPUT  PARAM par_nrseqaut    LIKE crapaut.nrseqaut.
    DEF INPUT  PARAM par_impressa    AS LOG.
    DEF INPUT  PARAM p-data-inf      AS INTE.
    DEF INPUT  PARAM par_flgdebcc    AS LOG.
    DEF INPUT  PARAM par_cdopecxa    LIKE craplcx.cdopecxa.
    DEF OUTPUT PARAM par_nmarqimp    AS CHAR.
            
    DEF VAR aux_flgexist             AS LOG.
    DEF VAR aux_nrdctabb             LIKE craplcm.nrdctabb.
    DEF VAR aux_nrdocmto             LIKE craplcm.nrdocmto.
    DEF VAR aux_nrdconta             LIKE craplcm.nrdconta.

    DEF VAR da-data-inf              AS CHAR FORMAT "x(08)" NO-UNDO.
    DEF VAR da-data                  AS DATE                NO-UNDO.
    DEF VAR aux_dia                  AS INTE                NO-UNDO.
    DEF VAR aux_mes                  AS INTE                NO-UNDO.
    DEF VAR aux_ano                  AS INTE                NO-UNDO.
    DEF VAR i-ano-bi                 AS INTE                NO-UNDO.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa).    
    
    IF  par_nrdolote = 0   THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Lote deve ser Informado".
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK". 
        END.           

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
    
    ASSIGN da-data-inf = STRING(p-data-inf,"99999999").

    ASSIGN aux_dia = INT(SUBSTR(da-data-inf,1,2))
           aux_mes = INT(SUBSTR(da-data-inf,3,2))
           aux_ano = INT(SUBSTR(da-data-inf,5,4)).

    ASSIGN aux_nrdolote = 11000 + par_nrdcaixa.

    IF  p-data-inf <> 0   THEN /* DDMMAAAA */
        DO:
                   
            IF  aux_dia  = 0    OR         /* Dia */
                aux_dia  > 31   THEN 
                DO:
                    ASSIGN i-cod-erro  = 13 /* Data errada */
                           c-desc-erro = " ".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
           
            IF (aux_mes = 4   OR
                aux_mes = 6   OR
                aux_mes = 9   OR
                aux_mes = 11) AND
               (aux_dia > 30) THEN 
                DO:
            
                    ASSIGN i-cod-erro  = 13 /* Data errada */
                           c-desc-erro = " ".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT par_cdagenci, 
                                   INPUT par_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
        
            IF  aux_mes = 2 THEN
                DO:
        
                    ASSIGN i-ano-bi = aux_ano / 4.
                    IF  i-ano-bi * 4 <> aux_ano THEN 
                        DO:
                            IF  aux_dia > 28 THEN 
                                DO:
                                    ASSIGN i-cod-erro  = 13 /* Data errada */
                                           c-desc-erro = " ".
                                    RUN cria-erro (INPUT p-cooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT i-cod-erro,
                                                   INPUT c-desc-erro,
                                                   INPUT YES).
                                    RETURN "NOK".
                                END.
                        END.
                    ELSE 
                        DO:    /* Ano Bissexto. */

                            IF  aux_dia > 29 THEN 
                                DO:
                                    ASSIGN i-cod-erro  = 13 /* Data errada */
                                           c-desc-erro = " ".
                                    RUN cria-erro (INPUT p-cooper,
                                                   INPUT par_cdagenci, 
                                                   INPUT par_nrdcaixa,
                                                   INPUT i-cod-erro,
                                                   INPUT c-desc-erro,
                                                   INPUT YES).
                                    RETURN "NOK".
                                END.
                        END.
                END.
        
            IF   aux_mes > 12 OR       /* Mes */
                 aux_mes = 0  THEN 
                 DO:
                    ASSIGN i-cod-erro  = 13 /* Data errada */
                           c-desc-erro = " ".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT par_cdagenci, 
                                   INPUT par_nrdcaixa, 
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
        END.  
    
    IF  p-data-inf = 0 THEN
        ASSIGN da-data = crapdat.dtmvtolt.
    ELSE
        ASSIGN da-data = DATE(aux_mes,aux_dia,aux_ano). 
    
    IF  p-data-inf <> 0                 AND
        da-data    > crapdat.dtmvtolt  THEN 
        DO:

            ASSIGN i-cod-erro  = 13 /* Data errada */
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci, 
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.  

    IF   par_flgdebcc = FALSE   THEN
         DO:
            ASSIGN aux_flgexist = NO.

            FOR EACH crablcm WHERE crablcm.cdcooper = crapcop.cdcooper   AND
                                   crablcm.dtmvtolt = da-data            AND
                                   crablcm.cdagenci = par_cdagenci       AND
                                   crablcm.cdbccxlt = 11                 AND
                                   crablcm.nrdolote = aux_nrdolote       AND
                                   crablcm.nrautdoc = par_nrseqaut       
                                   USE-INDEX craplcm3 NO-LOCK:
                                   
                FIND crabcme WHERE crabcme.cdcooper = crapcop.cdcooper   AND
                                   crabcme.dtmvtolt = crablcm.dtmvtolt   AND
                                   crabcme.cdagenci = crablcm.cdagenci   AND
                                   crabcme.cdbccxlt = crablcm.cdbccxlt   AND
                                   crabcme.nrdolote = crablcm.nrdolote   AND
                                   crabcme.nrdocmto = crablcm.nrdocmto   
                                   NO-LOCK NO-ERROR.
                                   
                IF  AVAILABLE crabcme   THEN
                    DO:
                        ASSIGN aux_flgexist = YES
                               aux_nrdctabb = crabcme.nrdctabb
                               aux_nrdocmto = crabcme.nrdocmto.
                        LEAVE.  
                    END.      
            END.
           
            IF  NOT aux_flgexist   THEN
                DO:
                    ASSIGN i-cod-erro  = 90
                           c-desc-erro = "(#01)".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".  
                END.      
           
            FIND crabcme WHERE crabcme.cdcooper = crapcop.cdcooper  AND
                               crabcme.dtmvtolt = da-data           AND
                               crabcme.cdagenci = par_cdagenci      AND
                               crabcme.cdbccxlt = 11                AND
                               crabcme.nrdolote = aux_nrdolote      AND
                               crabcme.nrdctabb = aux_nrdctabb      AND
                               crabcme.nrdocmto = aux_nrdocmto      
                               NO-LOCK NO-ERROR.
           
            IF  NOT AVAILABLE crabcme   THEN
                DO:
                    ASSIGN i-cod-erro  = 90
                           c-desc-erro = "(#02)".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".  
                END.   
         END.
    ELSE
         DO:
            FIND FIRST craptvl WHERE craptvl.cdcooper = crapcop.cdcooper  AND
                                     craptvl.dtmvtolt = da-data           AND
                                     craptvl.cdagenci = par_cdagenci      AND
                                     craptvl.cdbccxlt = 11                AND
                                     craptvl.nrdolote = par_nrdolote      AND
                                     craptvl.nrdocmto = par_nrdocmto   
                                     NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craptvl   THEN
                 DO:                   
                     FIND FIRST craplcx WHERE 
                                craplcx.cdcooper = crapcop.cdcooper    AND
                                craplcx.dtmvtolt = da-data             AND
                                craplcx.cdagenci = par_cdagenci        AND
                                craplcx.nrdcaixa = par_nrdcaixa        AND
                                craplcx.cdopecxa = par_cdopecxa        AND 
                                craplcx.nrdocmto = par_nrdocmto 
                                NO-LOCK NO-ERROR.   
                               
                     IF   NOT AVAIL craplcx   THEN
                          DO:
                              ASSIGN i-cod-erro  = 0
                                     c-desc-erro = 
                                  "Transferência nao efetuada.".
                              
                              RUN cria-erro (INPUT p-cooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT i-cod-erro,
                                             INPUT c-desc-erro,
                                             INPUT YES).
                              RETURN "NOK".  
                          END.
                 END.

            ASSIGN aux_nrdconta = IF   AVAIL craptvl   THEN         
                                       craptvl.nrdconta
                                  ELSE 
                                       0.

            FIND crabcme WHERE crabcme.cdcooper = crapcop.cdcooper AND
                               crabcme.dtmvtolt = da-data          AND 
                               crabcme.cdagenci = par_cdagenci     AND
                               crabcme.cdbccxlt = 11               AND
                               crabcme.nrdolote = aux_nrdolote     AND
                               crabcme.nrdctabb = aux_nrdconta     AND
                               crabcme.nrdocmto = par_nrdocmto      
                               NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE crabcme   THEN
                DO:
                    ASSIGN i-cod-erro  = 90
                           c-desc-erro = "(#03)".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".  
                END. 
    END.
     
    IF   crabcme.nrdctabb <> 0   THEN
         DO:
            FIND crabass WHERE crabass.cdcooper = crapcop.cdcooper  AND
                               crabass.nrdconta = crabcme.nrdconta  
                               NO-LOCK NO-ERROR.
           
            IF  NOT AVAILABLE crabass   THEN 
                DO:
                    ASSIGN i-cod-erro  = 9
                           c-desc-erro = "".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".  
                END.      

            IF  crabass.inpessoa = 1   THEN
                ASSIGN rel_tppessoa = "Fisica"
                       rel_nrcpfcgc = STRING(crabass.nrcpfcgc,"99999999999")
                       rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xxx.xxx.xxx-xx").
            ELSE
                ASSIGN rel_tppessoa = "Juridica"
                       rel_nrcpfcgc = STRING(crabass.nrcpfcgc,"99999999999999")
                       rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
                                                   
            FIND crapenc WHERE crapenc.cdcooper = crapcop.cdcooper AND
                               crapenc.nrdconta = crabass.nrdconta AND
                               crapenc.idseqttl = 1                AND
                               crapenc.cdseqinc = 1  NO-LOCK NO-ERROR.
         END.

    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                       craptab.nmsistem = "CRED"            AND
                       craptab.tptabela = "GENERI"          AND
                       craptab.cdempres = 0                 AND
                       craptab.cdacesso = "VMINCTRCEN"      AND
                       craptab.tpregist = 0                 NO-LOCK NO-ERROR.

                     
    IF  par_impressa = YES   THEN  /* Impressao */
        DO:  
            /* Impressora */
   
            FIND FIRST crapope WHERE crapope.cdcooper = crapcop.cdcooper AND
                                     crapope.cdoperad = par_cdoperad
                                     NO-LOCK NO-ERROR.
        
            IF  NOT AVAILABLE crapope   THEN 
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro =
                         "Registro de Impressora nao encontrada para o Operador".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".  
                END.      
        
            ASSIGN aux_nmdafila =  LC(crapope.dsimpres)
                   aux_nmarqimp =  "/usr/coop/sistema/siscaixa/web/spool/" +
                                   crapcop.dsdircop     +
                                   string(par_cdagenci) +
                                   string(par_nrdcaixa) + 
                                   "b1032.ex". /* Nome Fixo */
        END.
    ELSE 
        DO:
            ASSIGN aux_nmarqimp =  "/usr/coop/sistema/siscaixa/web/spool/" +
                                   crapcop.dsdircop     + 
                                   string(par_cdagenci) +
                                   string(par_nrdcaixa) + 
                                   "b1032.ex".  /* Nome Fixo */
        END.

    ASSIGN par_nmarqimp = aux_nmarqimp.

    ASSIGN rel_nmextcop = "\033\017\033\016" + crapcop.nmextcop + "\024\022" 
           rel_nmrescop = "\033\017\033\016" + crapcop.nmrescop + "\024\022"
           rel_linhadet = FILL("_",80)
           rel_vllanmto = TRIM(STRING(crabcme.vllanmto,"zzz,zz9.99")).

    IF  crabcme.tpoperac = 1   THEN
        ASSIGN rel_tpoperac = "Deposito".
    ELSE
        ASSIGN rel_tpoperac = "Saque".

    IF  crabcme.nrccdrcb <> 0   THEN
        ASSIGN rel_nmpesrcb = "      Conta/Dv: " + 
                              STRING(crabcme.nrccdrcb,"zzzz,zzz,9") + 
                              " - " + crabcme.nmpesrcb.
    ELSE
        ASSIGN rel_nmpesrcb = " Nome Completo: " + crabcme.nmpesrcb.
        
    IF  crabcme.inpesrcb = 1 THEN
        ASSIGN rel_tppesrcb = "Fisica"
               rel_cpfcgrcb = STRING(crabcme.cpfcgrcb,"99999999999")
               rel_cpfcgrcb = STRING(rel_cpfcgrcb,"xxx.xxx.xxx-xx").
    ELSE
        ASSIGN rel_tppesrcb = "Juridica"
               rel_cpfcgrcb = STRING(crabcme.cpfcgrcb,"99999999999999")
               rel_cpfcgrcb = STRING(rel_cpfcgrcb,"xx.xxx.xxx/xxxx-xx").
                          
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp).
    
    IF  par_impressa = YES   THEN
        DO:
            PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
            PUT STREAM str_1 CONTROL "\0330\033x0" NULL.
        END.

    IF   crabcme.nrdctabb <> 0   THEN
         DO: 
            DISPLAY STREAM str_1
                    rel_nmextcop      rel_nmrescop      rel_linhadet      
                    rel_tpoperac      crabcme.nrdocmto  rel_vllanmto      
                    crabcme.nrdconta  crabass.nmprimtl  rel_tppessoa      
                    rel_nrcpfcgc      crapenc.dsendere  crapenc.nmcidade  
                    crapenc.cdufende  crapenc.nrcepend  rel_nmpesrcb      
                    rel_tppesrcb      rel_cpfcgrcb      crabcme.nridercb  
                    crabcme.dtnasrcb  crabcme.desenrcb  crabcme.nmcidrcb  
                    crabcme.cdufdrcb  crabcme.nrceprcb        
                    crabcme.dstrecur  crabcme.dtmvtolt  
                    WITH FRAME f_comprovante_cooperado.
                       
            DOWN STREAM str_1 WITH FRAME f_comprovante_cooperado.
         END.
    ELSE
         DO: 
            DISPLAY STREAM str_1
                    rel_nmextcop      rel_nmrescop      rel_linhadet      
                    rel_tpoperac      crabcme.nrdocmto  rel_vllanmto      
                    rel_nmpesrcb      rel_tppesrcb      rel_cpfcgrcb      
                    crabcme.nridercb  crabcme.dtnasrcb  crabcme.desenrcb  
                    crabcme.nmcidrcb  crabcme.cdufdrcb  crabcme.nrceprcb  
                    crabcme.dstrecur  
                    crabcme.dtmvtolt        
                    WITH FRAME f_comprovante_naocooperado.
                       
            DOWN STREAM str_1 WITH FRAME f_comprovante_naocooperado.
         END.
    
    IF  par_impressa = YES   THEN
        DO:
            PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
            PUT STREAM str_1 CONTROL "\0330\033x0" NULL.
        END.
    
    OUTPUT STREAM str_1 CLOSE.
    
    IF  par_impressa = YES   THEN
        DO:
            ASSIGN i-nro-vias = 1
                   aux_dscomand = "lp -d" + aux_nmdafila +
                                  " -n" + STRING(i-nro-vias) +   
                                  " -oMTl88 " + aux_nmarqimp +     
                                  " > /dev/null".
            
            UNIX SILENT VALUE(aux_dscomand).
      
        END.  /* impressora */
   
    RETURN "OK".

END PROCEDURE.

PROCEDURE valida-destino:    
   
   DEF INPUT  PARAM p-cooper     AS CHAR.
   DEF INPUT  PARAM par_cdagenci LIKE crapass.cdagenci.
   DEF INPUT  PARAM par_nrdcaixa LIKE craplot.nrdcaixa.
   DEF INPUT  PARAM par_dstrecur LIKE crapcme.dstrecur.
   DEF INPUT  PARAM par_flinfdst AS CHAR.
   DEF OUTPUT PARAM par_focoerro AS CHAR.

   FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
 
   RUN elimina-erro (INPUT p-cooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa).

   /* Informacoes nao prestadas pelo cooperado */
   IF   par_flinfdst = "N"   THEN
        RETURN "OK".

   IF   par_dstrecur = ""   THEN
        DO:
            ASSIGN i-cod-erro   = 375
                   c-desc-erro  = " "
                   par_focoerro = '20'.
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    RETURN "OK".
   
END.

PROCEDURE atualiza-crapcme:

   DEF INPUT PARAM p-cooper       AS CHAR.
   DEF INPUT PARAM par_cdagenci   LIKE crapcme.cdagenci.
   DEF INPUT PARAM par_nrdcaixa   LIKE crapcme.nrdcaixa.
   DEF INPUT PARAM par_cdopecxa   LIKE crapcme.cdopecxa.
   DEF INPUT PARAM par_vlmincen   AS DECIMAL.
   DEF INPUT PARAM par_nrseqaut   LIKE crapcme.nrseqaut.
   DEF INPUT PARAM par_nrdctabb   LIKE craplcm.nrdctabb.
   DEF INPUT PARAM par_nrdocmto   LIKE craplcm.nrdocmto.
   DEF INPUT PARAM par_nrccdrcb   LIKE crapcme.nrccdrcb.
   DEF INPUT PARAM par_nmpesrcb   LIKE crapcme.nmpesrcb.
   DEF INPUT PARAM par_cpfcgrcb   AS CHAR FORMAT "x(18)".
   DEF INPUT PARAM par_inpesrcb   AS CHARACTER FORMAT "x(08)".
   DEF INPUT PARAM par_nridercb   LIKE crapcme.nridercb.
   DEF INPUT PARAM par_dtnasrcb   LIKE crapcme.dtnasrcb.
   DEF INPUT PARAM par_desenrcb   LIKE crapcme.desenrcb.
   DEF INPUT PARAM par_nmcidrcb   LIKE crapcme.nmcidrcb.
   DEF INPUT PARAM par_cdufdrcb   LIKE crapcme.cdufdrcb.
   DEF INPUT PARAM par_nrceprcb   LIKE crapcme.nrceprcb.
   DEF INPUT PARAM par_dstrecur   LIKE crapcme.dstrecur.
   DEF INPUT PARAM par_nrdolote   LIKE crapcme.nrdolote.
   DEF INPUT PARAM par_flgdebcc   AS LOGICAL.
   DEF INPUT PARAM par_flinfdst   AS CHAR.
   DEF INPUT PARAM par_dsdopera   AS INTE.
   DEF INPUT PARAM par_vlretesp   AS DECI.                              

   DEF VAR aux_flgexist           AS LOGICAL             NO-UNDO.
   DEF VAR aux_nrdctabb           LIKE craplcm.nrdctabb  NO-UNDO.
   DEF VAR aux_nrdocmto           LIKE craplcm.nrdocmto  NO-UNDO.
   DEF VAR aux_dtmvtolt           LIKE crapcme.dtmvtolt  NO-UNDO.
   DEF VAR aux_cdagenci           LIKE crapcme.cdagenci  NO-UNDO.
   DEF VAR aux_cdbccxlt           LIKE crapcme.cdbccxlt  NO-UNDO.
   DEF VAR aux_nrdolote           LIKE crapcme.nrdolote  NO-UNDO.
   DEF VAR aux_nrseqdig           LIKE crapcme.nrseqdig  NO-UNDO.
   DEF VAR aux_vllanmto           LIKE crapcme.vllanmto  NO-UNDO.
   DEF VAR aux_nrdconta           LIKE crapcme.nrdconta  NO-UNDO.
   DEF VAR aux_nrautdoc           LIKE craptvl.nrautdoc  NO-UNDO.
   DEF VAR aux_inpessoa           LIKE crapass.inpessoa  NO-UNDO.
   DEF VAR h-b1wgen9998           AS HANDLE              NO-UNDO.

   ASSIGN aux_nrdolote = 11000 + par_nrdcaixa.

   FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

   RUN elimina-erro (INPUT p-cooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa).    

   ASSIGN aux_flgexist = NO.

 
   FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper 
              NO-LOCK NO-ERROR.

   IF   par_flgdebcc = FALSE  THEN
        DO:
            IF  par_nrdolote = 10118   THEN  /** Deposito entre cooperativas **/
                DO:
                    FIND LAST craplcx WHERE  craplcx.cdcooper = crapcop.cdcooper   AND
                                             craplcx.dtmvtolt = crapdat.dtmvtolt   AND
                                             craplcx.cdagenci = par_cdagenci       AND
                                             craplcx.nrdcaixa = par_nrdcaixa       AND
                                             craplcx.cdopecxa = par_cdopecxa       AND
                                             craplcx.nrdocmto = par_nrdocmto       
                                             NO-LOCK NO-ERROR.
                       
                    IF  NOT AVAILABLE craplcx   THEN
                        DO: 
                            ASSIGN i-cod-erro  = 90
                                   c-desc-erro = "(#04)".
                            RUN cria-erro (INPUT p-cooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT i-cod-erro,
                                           INPUT c-desc-erro,
                                           INPUT YES).
                            RETURN "NOK". 
                        END.        

                    ASSIGN aux_dtmvtolt = craplcx.dtmvtolt
                           aux_cdagenci = craplcx.cdagenci
                           aux_cdbccxlt = 11
                           aux_nrdocmto = craplcx.nrdocmto
                           aux_vllanmto = craplcx.vldocmto
                           aux_nrautdoc = craplcx.nrautdoc.
                    
                END.  /** Fim Deposito entre cooperativas **/
            ELSE
                DO:
                   
                   FIND crablcm WHERE crablcm.cdcooper = crapcop.cdcooper   AND
                                      crablcm.dtmvtolt = crapdat.dtmvtolt   AND
                                      crablcm.cdagenci = par_cdagenci       AND
                                      crablcm.cdbccxlt = 11                 AND
                                      crablcm.nrdolote = aux_nrdolote       AND
                                      crablcm.nrdctabb = par_nrdctabb       AND
                                      crablcm.nrdocmto = par_nrdocmto       
                                      USE-INDEX craplcm1 NO-LOCK NO-ERROR.

                   IF   NOT AVAILABLE crablcm   THEN
                        DO:
                            ASSIGN i-cod-erro  = 90
                                   c-desc-erro = "(#05)".
                            RUN cria-erro (INPUT p-cooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT i-cod-erro,
                                           INPUT c-desc-erro,
                                           INPUT YES).
                            RETURN "NOK".  
                        END.        
            
                   FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                                      crapass.nrdconta = crablcm.nrdconta  
                                      NO-LOCK NO-ERROR.
                   
                   IF   NOT AVAILABLE crapass  THEN
                        DO:
                            ASSIGN i-cod-erro  = 9
                                   c-desc-erro = "".
                            RUN cria-erro (INPUT p-cooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT i-cod-erro,
                                           INPUT c-desc-erro,
                                           INPUT YES).
                            RETURN "NOK".  
                        END.        
                   
                   ASSIGN aux_dtmvtolt = crablcm.dtmvtolt
                          aux_cdagenci = crablcm.cdagenci
                          aux_cdbccxlt = crablcm.cdbccxlt
                          aux_nrdctabb = crablcm.nrdctabb
                          aux_nrdocmto = crablcm.nrdocmto
                          aux_nrseqdig = crablcm.nrseqdig
                          aux_vllanmto = crablcm.vllanmto
                          aux_nrdconta = crablcm.nrdconta
                          aux_nrautdoc = crablcm.nrautdoc
                          aux_inpessoa = crapass.inpessoa.
            
                END.
        END.
   ELSE /* Para DOC e TED da rotina 20 - Buscar dados na CRAPTVL */
        DO:
           FIND FIRST craptvl WHERE craptvl.cdcooper = crapcop.cdcooper  AND
                                    craptvl.dtmvtolt = crapdat.dtmvtolt  AND
                                    craptvl.cdagenci = par_cdagenci      AND
                                    craptvl.cdbccxlt = 11                AND
                                    craptvl.nrdolote = par_nrdolote      AND
                                    craptvl.nrdocmto = par_nrdocmto   
                                    NO-LOCK NO-ERROR.

           IF   NOT AVAILABLE craptvl   THEN
                DO:
                   ASSIGN i-cod-erro  = 90
                          c-desc-erro = "(#06)".

                   RUN cria-erro (INPUT p-cooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT i-cod-erro,
                                  INPUT c-desc-erro,
                                  INPUT YES).
                   RETURN "NOK".  
                END.

           ASSIGN aux_dtmvtolt = craptvl.dtmvtolt
                  aux_cdagenci = craptvl.cdagenci
                  aux_cdbccxlt = craptvl.cdbccxlt
                  aux_nrdctabb = craptvl.nrdconta
                  aux_nrdocmto = craptvl.nrdocmto
                  aux_nrseqdig = craptvl.nrseqdig
                  aux_vllanmto = craptvl.vldocrcb
                  aux_nrdconta = craptvl.nrdconta
                  aux_nrautdoc = craptvl.nrautdoc
                  aux_inpessoa = IF par_inpesrcb = "Fisica" THEN 1
                                 ELSE 2.
            
        END.

   FIND crabcme WHERE crabcme.cdcooper = crapcop.cdcooper AND
                      crabcme.dtmvtolt = aux_dtmvtolt     AND
                      crabcme.cdagenci = aux_cdagenci     AND
                      crabcme.cdbccxlt = aux_cdbccxlt     AND
                      crabcme.nrdolote = aux_nrdolote     AND
                      crabcme.nrdctabb = aux_nrdctabb     AND
                      crabcme.nrdocmto = aux_nrdocmto     NO-LOCK NO-ERROR.

   IF   AVAILABLE crabcme   THEN
        DO:
            ASSIGN i-cod-erro  = 92
                   c-desc-erro = "".
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".  
        END.

   ASSIGN par_cpfcgrcb = REPLACE(par_cpfcgrcb,'/','')
          par_cpfcgrcb = REPLACE(par_cpfcgrcb,'.','')
          par_cpfcgrcb = REPLACE(par_cpfcgrcb,'-','').

   /* Valores acima de 100.000,00 */
   IF   aux_vllanmto >= par_vlmincen   THEN
        DO:
            IF   NOT CAN-DO ("1,2",STRING(par_dsdopera))   THEN
                 DO:
                     ASSIGN i-cod-erro  = 0
                            c-desc-erro = 
                             "Tipo de operacao (Total/Parcial) nao informado.".
                 
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK". 
                 END.

            IF   par_vlretesp > aux_vllanmto   THEN
                 DO:
                     ASSIGN i-cod-erro  = 0
                            c-desc-erro = 
                    "Valor digitado nao pode ser maior que o lancamento (R$" +
                    STRING(aux_vllanmto,"zzz,zzz,zz9.99") + ").". 
                 
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
                 END.

             /* Se tipo TOTAL */
             IF   par_dsdopera = 1   THEN
                  ASSIGN par_vlretesp = aux_vllanmto.


        END.

   CREATE crapcme.
   ASSIGN crapcme.cdcooper = crapcop.cdcooper 
          crapcme.dtmvtolt = aux_dtmvtolt
          crapcme.cdagenci = aux_cdagenci
          crapcme.cdbccxlt = aux_cdbccxlt
          crapcme.nrdolote = aux_nrdolote 
          crapcme.nrseqdig = aux_nrseqdig
          crapcme.nrdcaixa = par_nrdcaixa
          crapcme.cdopecxa = par_cdopecxa
          crapcme.nrdocmto = aux_nrdocmto
          crapcme.nmpesrcb = par_nmpesrcb
          crapcme.nrccdrcb = par_nrccdrcb
          crapcme.cpfcgrcb = IF par_inpesrcb = "Fisica" 
                             THEN DEC(STRING(par_cpfcgrcb,"99999999999"))
                             ELSE DEC(STRING(par_cpfcgrcb,"99999999999999"))  
          crapcme.dtnasrcb = IF par_inpesrcb = "Fisica" THEN par_dtnasrcb
                             ELSE ?
          crapcme.desenrcb = par_desenrcb
          crapcme.nmcidrcb = par_nmcidrcb
          crapcme.cdufdrcb = par_cdufdrcb
          crapcme.vllanmto = aux_vllanmto
          crapcme.tpoperac = 2 /* saque */
          crapcme.nridercb = par_nridercb
          crapcme.dstrecur = par_dstrecur
          crapcme.nrdconta = aux_nrdconta
          crapcme.inpesrcb = IF par_inpesrcb = "Fisica" THEN 1
                             ELSE 2
          crapcme.nrceprcb = par_nrceprcb
          crapcme.nrseqaut = aux_nrautdoc
          crapcme.nrdctabb = aux_nrdctabb
          crapcme.vlretesp = par_vlretesp
          crapcme.flinfdst = (par_flinfdst = "S"). /* Informado destinatario */
          
   IF   (aux_vllanmto >= par_vlmincen  AND
         aux_inpessoa <> 2           ) THEN
        ASSIGN crapcme.sisbacen = TRUE.

   IF   aux_vllanmto >= par_vlmincen   AND 
        aux_inpessoa < 3               THEN /* Valor maior que R$ 100.000 */
        DO:
            ASSIGN crapcme.infrepcf = 1. /* Informar ao COAF */

            RUN sistema/generico/procedures/b1wgen9998.p
                PERSISTENT SET h-b1wgen9998.

            RUN email-controle-movimentacao IN h-b1wgen9998
                                                (INPUT crapcop.cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_cdopecxa,
                                                 INPUT "crap051f.w",
                                                 INPUT 2, /* Caixa */
                                                 INPUT crapcme.nrdconta,
                                                 INPUT 1, /* Tit. */
                                                 INPUT 1, /* Inclusao*/
                                                 INPUT ROWID(crapcme),
                                                 INPUT TRUE, /* Enviar */
                                                 INPUT crapdat.dtmvtolt,
                                                 INPUT TRUE,
                                                OUTPUT TABLE tt-erro).      
            DELETE PROCEDURE h-b1wgen9998.

            IF   RETURN-VALUE <> "OK"   THEN                              
                 DO:                                                      
                     FIND FIRST tt-erro NO-LOCK NO-ERROR.                 
                                                                          
                     IF   AVAIL tt-erro   THEN                            
                          IF   tt-erro.cdcritic <> 0   THEN 
                               ASSIGN i-cod-erro  = tt-erro.cdcritic.           
                          ELSE 
                               ASSIGN c-desc-erro = tt-erro.dscritic.          
                     ELSE                                                 
                          ASSIGN c-desc-erro = "Erro no envio do email.". 
                                                                          
                     RUN cria-erro (INPUT p-cooper,                       
                                    INPUT par_cdagenci,                   
                                    INPUT par_nrdcaixa,                   
                                    INPUT i-cod-erro,                     
                                    INPUT c-desc-erro,                    
                                    INPUT YES).                           
                     RETURN "NOK".                                        
                 END.                                                     
        END.
   ELSE 
        ASSIGN crapcme.infrepcf = 0.   /* Nao Informar ao COAF */

   RETURN "OK".
   
END PROCEDURE.
/***************************************************************************/


