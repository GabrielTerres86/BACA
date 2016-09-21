/* .............................................................................

   Programa: Fontes/bo_controla_depositos.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Julho/2003.                     Ultima atualizacao: 28/10/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Fazer o tratamento para impressao do controle de   
               movimentacao em especie.

   Alteracoes: 30/09/2003 - Nao registrar acima de R$ 100.000 quando pessoa
                            juridica (Margarete).

               02/03/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               02/04/2007 - Alterado variaveis de endereco para receberem
                            valores da estrutura crapenc (Elton).
                            
               16/12/2008 - Verificacao da data de parametro na procedure 
                            bo_imp_ctr_depositos (Guilherme).

               22/12/2008 - Ajustes para unificacao dos bancos de dados
                            (Evandro).
                            
               20/10/2010 - Incluido caminho completo nas referencias do 
                            diretorio spool (Elton).

               06/04/2011 - Acertar atualizacao do campo tpoperac (Magui).
               
               20/05/2011 - Retirar campo Registrar.
                            Enviar email de controle de movimentacao.
                            Incluir campo de 'Informar destinatario' e 
                            'Informar ao COAF'. (Gabriel).
                            
               23/05/2011 - Alterada a leitura da tabela craptab para a 
                            tabela crapope (Isara - RKAM).         
                            
               25/07/2011 - Nao informar ao COAF quando conta administrativa
                            (Gabriel) .                            
                            
               19/09/2011 - Depositante ou sacador deve ser pessoa fisica
                            (Gabriel)                      
                                            
               30/09/2011 - Alterar diretorio spool para
                             /usr/coop/sistema/siscaixa/web/spool (Fernando). 
                             
                          - Mudada a extensao de geracao dos arquivos de
                            impressao de ".txt" para ".ex" (Gabriel).    
                            
               31/10/2011 - Ajuste no form de impressao (Gabriel).              
               
               17/12/2013 - Adicionado validate para tabela crapcme (Tiago).
               
               28/10/2015 - #318705 Adicionado sequencial na descricao da 
                            critica 90 (Carlos)
............................................................................. */

{dbo/bo-erro1.i}
{sistema/generico/includes/var_internet.i }

DEF BUFFER crabcme FOR crapcme.
DEF BUFFER crabass FOR crapass.
DEF BUFFER crablcm FOR craplcm.

DEF  VAR i-cod-erro     AS INTEGER.
DEF  VAR c-desc-erro    AS CHAR.
DEF  VAR aux_flerrcgc   AS LOG                                      NO-UNDO.
DEF  VAR aux_tppessoa   AS INTE                                     NO-UNDO.
DEF  VAR aux_flgerruf   AS LOG                                      NO-UNDO.
DEF  VAR rel_linhadet   AS CHAR FORMAT "x(70)".
DEF  VAR rel_nmcooper   AS CHAR FORMAT "x(70)".
DEF  VAR rel_tppessoa   AS CHAR FORMAT "x(08)".
DEF  VAR rel_nrcpfcgc   AS CHAR FORMAT "x(18)".
DEF  VAR rel_nmpesrcb   AS CHAR FORMAT "x(70)".
DEF  VAR rel_tppesrcb   AS CHAR FORMAT "x(08)".
DEF  VAR rel_cpfcgrcb   AS CHAR FORMAT "x(18)".
DEF  VAR rel_tpoperac   AS CHAR FORMAT "x(08)".
DEF  VAR rel_vllanmto   AS CHAR FORMAT "x(10)".
DEF  VAR in01           AS INTE                                     NO-UNDO.

DEF VAR aux_nmarqimp    AS CHAR                                     NO-UNDO.
DEF VAR aux_nrdolote LIKE crapcme.nrdolote                          NO-UNDO.

DEF STREAM str_1.
DEF   VAR l-retorno     AS LOG                                      NO-UNDO.
DEF   VAR tel_dsdlinha  AS CHAR                                     NO-UNDO.


DEF VAR aux_nmdafila    AS CHAR                                     NO-UNDO.
DEF VAR i-nro-vias      AS INTE                                     NO-UNDO.
DEF VAR aux_dscomand    AS CHAR                                     NO-UNDO.

FORM SKIP(3)
     "\022\024\033\120" /* reseta impressora */
     rel_nmcooper
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
     "\033\017\033\016FAVORECIDO:\024\022"
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
     SKIP(1)
     "\033\017\033\016DEPOSITANTE:\024\022"
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
     "Origem dos Recursos:" crabcme.recursos FORMAT "x(50)"
     SKIP(3)
     "Declaro(amos) assumir integral responsabilidade pelas declaracoes"
     SKIP
     "aqui prestadas."
     SKIP(2)
     "DATA:" crabcme.dtmvtolt
     SKIP(5) SPACE(6)
     "-------------------------------    -------------------------------"
     SKIP SPACE(6)
     "    DEPOSITANTE                      FUNCIONARIO(A)"
     SKIP SPACE(6)
     "                                    CADASTRO E VISTO"
     SKIP(5)
     "                                   -------------------------------"
     SKIP SPACE(6)
     "                                     COORDENADOR(A)"
     SKIP SPACE(6)
     "                                    CADASTRO E VISTO"
     WITH FRAME f_comprovante NO-BOX NO-LABELS COLUMN 10.

FORM SKIP(1) WITH NO-BOX FRAME f_linha STREAM-IO.

PROCEDURE bo_imp_ctr_depositos:

    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM par_cdopecxa    LIKE crapbcx.cdopecxa.
    DEF INPUT  PARAM par_cdagenci    LIKE craplcm.cdagenci.
    DEF INPUT  PARAM par_nrdcaixa    LIKE craplot.nrdcaixa.
    DEF INPUT  PARAM par_nrdolote    LIKE craplcm.nrdolote.
    DEF INPUT  PARAM par_nrseqaut    LIKE crapaut.nrseqaut.
    DEF INPUT  PARAM par_impressa    AS LOG.
    DEF INPUT  PARAM p-data-inf      AS INTE.
    DEF OUTPUT PARAM par_nmarqimp    AS CHAR.

    DEF VAR aux_flgexist             AS LOG.
    DEF VAR aux_nrdctabb             LIKE craplcm.nrdctabb.
    DEF VAR aux_nrdocmto             LIKE craplcm.nrdocmto.

    DEF VAR da-data-inf              AS CHAR FORMAT "x(08)"         NO-UNDO.
    DEF VAR da-data                  AS DATE                        NO-UNDO.
    DEF VAR aux_dia                  AS INTE                        NO-UNDO.
    DEF VAR aux_mes                  AS INTE                        NO-UNDO.
    DEF VAR aux_ano                  AS INTE                        NO-UNDO.
    DEF VAR i-ano-bi                 AS INTE                        NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    RUN  elimina-erro (INPUT p-cooper,
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

    IF  p-data-inf <> 0   THEN 
        DO: /* DDMMAAAA */
           
            IF  aux_dia  = 0  OR         /* Dia */
                aux_dia  > 31 THEN 
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
        
            IF  aux_mes > 12 OR       /* Mes */
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
    
    IF  p-data-inf <> 0                AND
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
    
    ASSIGN aux_flgexist = NO.    

    FOR EACH crablcm WHERE crablcm.cdcooper = crapcop.cdcooper   AND
                           crablcm.dtmvtolt = da-data            AND
                           crablcm.cdagenci = par_cdagenci       AND
                           crablcm.cdbccxlt = 11                 AND
                           crablcm.nrdolote = par_nrdolote       AND
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
                ASSIGN aux_flgexist  = YES
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
                       crabcme.nrdolote = par_nrdolote      AND
                       crabcme.nrdctabb = aux_nrdctabb      AND
                       crabcme.nrdocmto = aux_nrdocmto      NO-LOCK NO-ERROR.

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
                                            
    FIND crapenc WHERE crapenc.cdcooper = crapcop.cdcooper AND
                       crapenc.nrdconta = crabass.nrdconta AND
                       crapenc.idseqttl = 1                AND
                       crapenc.cdseqinc = 1                NO-LOCK NO-ERROR.

    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper AND
                       craptab.nmsistem = "CRED"           AND
                       craptab.tptabela = "GENERI"         AND
                       craptab.cdempres = 0                AND
                       craptab.cdacesso = "VMINCTRCEN"     AND
                       craptab.tpregist = 0                NO-LOCK NO-ERROR.
                      
    IF  par_impressa = YES   THEN  /* Impressao */
        DO:  
            /* Impressora */
         
            FIND FIRST crapope WHERE crapope.cdcooper = crapcop.cdcooper AND
                                     crapope.cdoperad = par_cdopecxa
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

                   aux_nmarqimp = "/usr/coop/sistema/siscaixa/web/spool/" +
                                  crapcop.dsdircop     +
                                  STRING(TIME)         +
                                  STRING(par_cdagenci) +
                                  STRING(par_nrdcaixa) + 
                                  "b1032.ex". /* Nome Fixo */
        END.
    ELSE 
        DO:
            ASSIGN aux_nmarqimp = "/usr/coop/sistema/siscaixa/web/spool/" + 
                                  crapcop.dsdircop     +
                                  STRING(TIME)         +
                                  STRING(par_cdagenci) +
                                  STRING(par_nrdcaixa) + 
                                  "b1032.ex"  /* Nome Fixo */
                   par_nmarqimp = aux_nmarqimp.
        END.

    ASSIGN rel_nmcooper = "\033\017\033\016" + crapcop.nmextcop + " - " + 
                          crapcop.nmrescop + "\024\022"
           rel_linhadet = FILL("_",80)
           rel_vllanmto = TRIM(STRING(crabcme.vllanmto,"zzz,zz9.99")).

    IF  crabcme.tpoperac = 1   THEN
        ASSIGN rel_tpoperac = "Deposito".
    ELSE
        ASSIGN rel_tpoperac = "Saque".
          
    IF   crabass.inpessoa = 1   THEN
         ASSIGN rel_tppessoa = "Fisica"
                rel_nrcpfcgc = STRING(crabass.nrcpfcgc,"99999999999")
                rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xxx.xxx.xxx-xx").
    ELSE
         ASSIGN rel_tppessoa = "Juridica"
                rel_nrcpfcgc = STRING(crabass.nrcpfcgc,"99999999999999")
                rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").

    IF   crabcme.nrccdrcb <> 0   THEN
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

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
    
    IF  par_impressa = YES   THEN
        DO:
            PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
            PUT STREAM str_1 CONTROL "\0330\033x0" NULL.
        END.

    DISPLAY STREAM str_1
            rel_nmcooper      rel_linhadet      rel_tpoperac 
            crabcme.nrdocmto  rel_vllanmto      crabcme.nrdconta
            crabass.nmprimtl  rel_tppessoa      rel_nrcpfcgc
            crapenc.dsendere  crapenc.nmcidade  crapenc.cdufende
            crapenc.nrcepend  rel_nmpesrcb      rel_tppesrcb
            rel_cpfcgrcb      crabcme.nridercb  crabcme.dtnasrcb
            crabcme.desenrcb  crabcme.nmcidrcb  crabcme.cdufdrcb 
            crabcme.nrceprcb  crabcme.recursos
            crabcme.dtmvtolt  
            WITH FRAME f_comprovante.

    DOWN STREAM str_1 WITH FRAME f_comprovante.

    PAGE STREAM str_1.
   
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

PROCEDURE retorna-depositante-sacador:
   DEF INPUT  PARAM p-cooper      AS CHAR.
   DEF INPUT  PARAM par_cdagenci  LIKE crapass.cdagenci.
   DEF INPUT  PARAM par_nrdcaixa  LIKE craplot.nrdcaixa.
   DEF INPUT  PARAM par_nrdconta  LIKE crapass.nrdconta.
   DEF OUTPUT PARAM par_nmpesrcb  LIKE crapass.nmprimtl.
   DEF OUTPUT PARAM par_cpfcgrcb  AS CHARACTER FORMAT "x(18)".
   DEF OUTPUT PARAM par_inpesrcb  AS CHARACTER FORMAT "x(08)".
   DEF OUTPUT PARAM par_nridercb  LIKE crapass.nrdocptl.
   DEF OUTPUT PARAM par_dtnasrcb  LIKE crapass.dtnasctl.
   DEF OUTPUT PARAM par_desenrcb  LIKE crapenc.dsendere.
   DEF OUTPUT PARAM par_nmcidrcb  LIKE crapenc.nmcidade.
   DEF OUTPUT PARAM par_cdufdrcb  LIKE crapenc.cdufende.
   DEF OUTPUT PARAM par_nrceprcb  LIKE crapenc.nrcepend.
   DEF OUTPUT PARAM par_focoerro  AS CHAR.               
                                 
   FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
   
   RUN elimina-erro (INPUT p-cooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa).    
                                           
   ASSIGN par_nrdconta = dec(REPLACE(string(par_nrdconta),".","")).

   FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                      crapass.nrdconta = par_nrdconta     NO-LOCK NO-ERROR.

   IF   NOT AVAIL crapass   THEN
        DO:
            ASSIGN i-cod-erro  = 9
                   c-desc-erro = " "
                   par_focoerro = '9'.

            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

   IF   crapass.inpessoa <> 1   THEN
        DO:
            ASSIGN i-cod-erro  = 436
                   c-desc-erro = " "
                   par_focoerro = '9'.

            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
   
   FIND crapenc WHERE crapenc.cdcooper = crapcop.cdcooper AND
                      crapenc.nrdconta = crapass.nrdconta AND
                      crapenc.idseqttl = 1                AND
                      crapenc.cdseqinc = 1                NO-LOCK NO-ERROR.
   
   ASSIGN par_nmpesrcb = crapass.nmprimtl
          par_nridercb = crapass.nrdocptl
          par_dtnasrcb = crapass.dtnasctl
          par_desenrcb = crapenc.dsendere 
          par_nmcidrcb = crapenc.nmcidade 
          par_cdufdrcb = crapenc.cdufende 
          par_nrceprcb = crapenc.nrcepend
          par_cpfcgrcb = STRING(crapass.nrcpfcgc,"99999999999").
   
   RETURN "OK".   

END PROCEDURE.

PROCEDURE valida-depositante-sacador:    
   
   DEF INPUT  PARAM p-cooper        AS CHAR.
   DEF INPUT  PARAM par_cdagenci    LIKE crapass.cdagenci.
   DEF INPUT  PARAM par_nrdcaixa    LIKE craplot.nrdcaixa.
   DEF INPUT  PARAM par_nmpesrcb    LIKE crapass.nmprimtl.
   DEF INPUT  PARAM par_cpfcgrcb    AS CHARACTER FORMAT "x(18)".
   DEF INPUT  PARAM par_inpesrcb    AS CHARACTER FORMAT "x(08)".
   DEF INPUT  PARAM par_nridercb    LIKE crapass.nrdocptl.
   DEF INPUT  PARAM par_dtnasrcb    AS CHAR FORMAT "x(10)".
   DEF INPUT  PARAM par_desenrcb    LIKE crapenc.dsendere.
   DEF INPUT  PARAM par_nmcidrcb    LIKE crapenc.nmcidade.
   DEF INPUT  PARAM par_cdufdrcb    LIKE crapenc.cdufende.
   DEF INPUT  PARAM par_nrceprcb_x  AS CHAR FORMAT "x(08)".
   DEF OUTPUT PARAM par_focoerro    AS CHAR.
   
   DEF VAR aux_dia AS INTE.
   DEF VAR aux_mes AS INTE.
   DEF VAR aux_ano AS INTE.
   DEF VAR par_nrceprcb AS INTE NO-UNDO.
           
   FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
 
   FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                            NO-LOCK NO-ERROR.
   
   RUN elimina-erro (INPUT p-cooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa).    

   IF   par_nmpesrcb = ""   THEN
        DO:
            ASSIGN i-cod-erro  = 16
                   c-desc-erro = " "
                   par_focoerro = '10'.
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
   
    ASSIGN  par_cpfcgrcb = REPLACE(par_cpfcgrcb,"/","")
            par_cpfcgrcb = REPLACE(par_cpfcgrcb,".","")
            par_cpfcgrcb = REPLACE(par_cpfcgrcb,"-","").

   IF   par_cpfcgrcb = ""   THEN
        DO:
            ASSIGN i-cod-erro  = 375
                   c-desc-erro = " "
                   par_focoerro = '12'. 
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
        
   in01  = 1.
   ASSIGN c-desc-erro = " "
          i-cod-erro  = 0.
   DO  WHILE in01 LE LENGTH(par_cpfcgrcb):
       IF   SUBSTR(par_cpfcgrcb,in01,1) <> "0" AND
            SUBSTR(par_cpfcgrcb,in01,1) <> "1" AND
            SUBSTR(par_cpfcgrcb,in01,1) <> "2" AND
            SUBSTR(par_cpfcgrcb,in01,1) <> "3" AND
            SUBSTR(par_cpfcgrcb,in01,1) <> "4" AND
            SUBSTR(par_cpfcgrcb,in01,1) <> "5" AND
            SUBSTR(par_cpfcgrcb,in01,1) <> "6" AND
            SUBSTR(par_cpfcgrcb,in01,1) <> "7" AND
            SUBSTR(par_cpfcgrcb,in01,1) <> "8" AND
            SUBSTR(par_cpfcgrcb,in01,1) <> "9" THEN 
            DO:
                ASSIGN  i-cod-erro = 27.
                LEAVE.
            END.    
       in01 = in01 + 1.
   END.

   IF   i-cod-erro > 0      THEN 
        DO:
            par_focoerro = '12'.
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.   

   RUN dbo/pcrap06.p (INPUT  par_cpfcgrcb,
                      OUTPUT aux_flerrcgc,
                      OUTPUT aux_tppessoa).

   IF   NOT aux_flerrcgc   THEN
        DO:
            ASSIGN i-cod-erro  = 27
                   c-desc-erro = ""
                   par_focoerro = '12'. 
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

   /* Tem que ser pessoa fisica */
   IF   aux_tppessoa <> 1   THEN
        DO:
            ASSIGN i-cod-erro  = 436
                   c-desc-erro = " "
                   par_focoerro = '12'.
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
           
   IF   par_nridercb = ""   THEN
        DO:
            ASSIGN i-cod-erro  = 375
                   c-desc-erro = " "
                   par_focoerro = '13'.
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
   
   IF   par_dtnasrcb = ""   THEN
        DO:
            ASSIGN i-cod-erro  = 375
                   c-desc-erro = " "
                   par_focoerro = '14'.
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK". 
        END.
  
   ASSIGN par_dtnasrcb = REPLACE(par_dtnasrcb,'/','').
                   
   IF  LENGTH(par_dtnasrcb) <> 8 THEN 
       DO:
           ASSIGN i-cod-erro  = 13 /* Data errada */
                  c-desc-erro = " ".
           RUN cria-erro (INPUT p-cooper,
                          INPUT par_cdagenci, 
                          INPUT par_nrdcaixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           par_focoerro = '14'.
           RETURN "NOK".  
       END.
           
   IF  par_dtnasrcb <> " " THEN 
       DO:
           ASSIGN i-cod-erro = 0
                  in01       = 1.
           DO  WHILE in01  LE 8:
               IF  SUBSTR(par_dtnasrcb,in01,1) <> "0"  AND
                   SUBSTR(par_dtnasrcb,in01,1) <> "1"  AND
                   SUBSTR(par_dtnasrcb,in01,1) <> "2"  AND
                   SUBSTR(par_dtnasrcb,in01,1) <> "3"  AND
                   SUBSTR(par_dtnasrcb,in01,1) <> "4"  AND
                   SUBSTR(par_dtnasrcb,in01,1) <> "5"  AND
                   SUBSTR(par_dtnasrcb,in01,1) <> "6"  AND
                   SUBSTR(par_dtnasrcb,in01,1) <> "7"  AND
                   SUBSTR(par_dtnasrcb,in01,1) <> "8"  AND
                   SUBSTR(par_dtnasrcb,in01,1) <> "9"  THEN 
                   DO:
                       ASSIGN i-cod-erro  = 13 /* Data errada */
                              c-desc-erro = " ".
                       RUN cria-erro (INPUT p-cooper,
                                      INPUT par_cdagenci, 
                                      INPUT par_nrdcaixa,
                                      INPUT i-cod-erro,
                                      INPUT c-desc-erro,
                                      INPUT YES).
                       in01 = 8.
                   END.
               in01 = in01 + 1.
           END.

           IF  i-cod-erro <> 0 THEN 
               DO:
                   par_focoerro = '14'.
                   RETURN "NOK".
               END.
                         
           ASSIGN aux_dia      = INTE(SUBSTR(par_dtnasrcb,1,2))
                  aux_mes      = INTE(SUBSTR(par_dtnasrcb,3,2))
                  aux_ano      = INTE(SUBSTR(par_dtnasrcb,5,4)).

           IF   (aux_dia = 0   OR
                 aux_dia > 31) OR
                (aux_mes = 0   OR
                 aux_mes > 12) OR
                 aux_ano = 0    THEN
                DO:
                    ASSIGN i-cod-erro  = 13
                           c-desc-erro = " "
                           par_focoerro = '14'.
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
            ELSE     
            IF   DATE(par_dtnasrcb) > crapdat.dtmvtolt - 3500 then
                 DO:
                     ASSIGN i-cod-erro  = 13
                            c-desc-erro = " "
                            par_focoerro = '14'.
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
                 END.                     
       END.

   IF   par_desenrcb = ""   THEN
        DO:
            ASSIGN i-cod-erro  = 375
                   c-desc-erro = " "
                   par_focoerro = '15'.
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
   
   IF   par_nmcidrcb = ""   THEN
        DO:
            ASSIGN i-cod-erro  = 375
                   c-desc-erro = " "
                   par_focoerro = '16'.
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
   
   RUN dbo/pcrap13.p (INPUT  par_cdufdrcb,
                      OUTPUT aux_flgerruf).
            
   IF   aux_flgerruf   THEN
        DO:
            ASSIGN i-cod-erro  = 33
                   c-desc-erro = " "
                   par_focoerro = '18'.
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.    
   
   ASSIGN  par_nrceprcb_x = REPLACE(par_nrceprcb_x,"/","")
           par_nrceprcb_x = REPLACE(par_nrceprcb_x,".","")
           par_nrceprcb_x = REPLACE(par_nrceprcb_x,"-","").

   IF   LENGTH(par_nrceprcb_x) <> 8 THEN
        DO:
           ASSIGN i-cod-erro  = 0
                  c-desc-erro = "CEP Recebimento Invalido "
                  par_focoerro = '17'.
           RUN cria-erro (INPUT p-cooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
        END.
   
   in01  = 1.
   ASSIGN c-desc-erro = " ".
   DO  WHILE in01 LE 8:
       IF   SUBSTR(par_nrceprcb_x,in01,1) <> "0" AND
            SUBSTR(par_nrceprcb_x,in01,1) <> "1" AND
            SUBSTR(par_nrceprcb_x,in01,1) <> "2" AND
            SUBSTR(par_nrceprcb_x,in01,1) <> "3" AND
            SUBSTR(par_nrceprcb_x,in01,1) <> "4" AND
            SUBSTR(par_nrceprcb_x,in01,1) <> "5" AND
            SUBSTR(par_nrceprcb_x,in01,1) <> "6" AND
            SUBSTR(par_nrceprcb_x,in01,1) <> "7" AND
            SUBSTR(par_nrceprcb_x,in01,1) <> "8" AND
            SUBSTR(par_nrceprcb_x,in01,1) <> "9" THEN 
            DO:
                ASSIGN  c-desc-erro = "CEP Recebimento Invalido ".
                LEAVE.
            END.    
       in01 = in01 + 1.
   END.
   IF   c-desc-erro <> " " THEN 
        DO:
            ASSIGN  i-cod-erro = 0.
            par_focoerro = '17'.
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.   

   ASSIGN par_nrceprcb = INT(par_nrceprcb_x).
   IF   par_nrceprcb = 0   THEN
        DO:
            ASSIGN i-cod-erro  = 34
                   c-desc-erro = " "
                   par_focoerro = '17'.
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

PROCEDURE valida-recurso:    
   
   DEF INPUT PARAM p-cooper     AS   CHAR.
   DEF INPUT PARAM par_cdagenci LIKE crapass.cdagenci.
   DEF INPUT PARAM par_nrdcaixa LIKE craplot.nrdcaixa.
   DEF INPUT PARAM par_recursos LIKE crapcme.recursos.
   DEF INPUT PARAM par_flinfdst AS   CHAR.
              
   FIND crapcop WHERE crapcop.nmrescop = p-cooper   NO-LOCK NO-ERROR.
 
   RUN elimina-erro (INPUT p-cooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa).    

   IF   par_flinfdst = "N"   THEN
        RETURN "OK".

   IF   par_recursos = ""   THEN
        DO:
            ASSIGN i-cod-erro  = 375
                   c-desc-erro = " ".
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

PROCEDURE retorna-origem-destinatario:

   DEF INPUT  PARAM p-cooper       AS CHAR.
   DEF INPUT  PARAM par_cdagenci LIKE crapass.cdagenci.
   DEF INPUT  PARAM par_nrdcaixa LIKE craplot.nrdcaixa.
   DEF INPUT  PARAM par_nrdconta LIKE crapass.nrdconta.
   DEF OUTPUT PARAM par_nmpesdst LIKE crapass.nmprimtl.
   DEF OUTPUT PARAM par_cpfcgdst AS CHARACTER FORMAT "x(18)".
   DEF OUTPUT PARAM par_inpesdst AS CHARACTER FORMAT "x(08)".
   DEF OUTPUT PARAM par_nridedst LIKE crapass.nrdocptl.
   DEF OUTPUT PARAM par_dtnasdst LIKE crapass.dtnasctl.
   DEF OUTPUT PARAM par_desendst LIKE crapenc.dsendere.
   DEF OUTPUT PARAM par_nmciddst LIKE crapenc.nmcidade.
   DEF OUTPUT PARAM par_cdufddst LIKE crapenc.cdufende.
   DEF OUTPUT PARAM par_nrcepdst LIKE crapenc.nrcepend.
   DEF OUTPUT PARAM par_focoerro AS CHAR.               
           
   FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
 
   RUN elimina-erro (INPUT p-cooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa).    
                                           
   ASSIGN par_nrdconta = dec(REPLACE(string(par_nrdconta),".","")).

   FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                      crapass.nrdconta = par_nrdconta      NO-LOCK NO-ERROR.

   IF   NOT AVAIL crapass   THEN
        DO:
            ASSIGN i-cod-erro  = 9
                   c-desc-erro = " "
                   par_focoerro = '20'.
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
                                              
   FIND crapenc WHERE crapenc.cdcooper = crapcop.cdcooper AND
                      crapenc.nrdconta = par_nrdconta     AND
                      crapenc.idseqttl = 1                AND
                      crapenc.cdseqinc = 1                NO-LOCK NO-ERROR.
   
   ASSIGN par_nmpesdst = crapass.nmprimtl
          par_nridedst = crapass.nrdocptl
          par_dtnasdst = crapass.dtnasctl
          par_desendst = crapenc.dsendere 
          par_nmciddst = crapenc.nmcidade 
          par_cdufddst = crapenc.cdufende 
          par_nrcepdst = crapenc.nrcepend.
   
   IF   crapass.inpessoa = 1   THEN
        ASSIGN par_inpesdst = "Fisica"
               par_cpfcgdst = STRING(crapass.nrcpfcgc,"99999999999").
   ELSE 
        ASSIGN par_inpesdst = "Juridica"
               par_cpfcgdst = STRING(crapass.nrcpfcgc,"99999999999999").
   RETURN "OK".   

END PROCEDURE.

PROCEDURE valida-origem-destinatario:    
   
   DEF INPUT  PARAM p-cooper       AS CHAR.
   DEF INPUT  PARAM par_cdagenci   LIKE crapass.cdagenci.
   DEF INPUT  PARAM par_nrdcaixa   LIKE craplot.nrdcaixa.
   DEF INPUT  PARAM par_nmpesdst   LIKE crapass.nmprimtl.
   DEF INPUT  PARAM par_cpfcgdst   AS CHARACTER FORMAT "x(18)".
   DEF INPUT  PARAM par_inpesdst   AS CHARACTER FORMAT "x(08)".
   DEF INPUT  PARAM par_nridedst   LIKE crapass.nrdocptl.
   DEF INPUT  PARAM par_dtnasdst   AS CHAR FORMAT "x(10)".
   DEF INPUT  PARAM par_desendst   LIKE crapenc.dsendere.
   DEF INPUT  PARAM par_nmciddst   LIKE crapenc.nmcidade.
   DEF INPUT  PARAM par_cdufddst   LIKE crapenc.cdufende.
   DEF INPUT  PARAM par_nrcepdst_x AS CHAR FORMAT "x(08)".
   DEF OUTPUT PARAM par_focoerro   AS CHAR.
   
   DEF VAR aux_dia                 AS INTE.
   DEF VAR aux_mes                 AS INTE.
   DEF VAR aux_ano                 AS INTE.
   DEF VAR par_nrcepdst            AS INTE.
   
   FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
   
   FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                            NO-LOCK NO-ERROR.
           
   RUN elimina-erro (INPUT p-cooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa).    

   IF   par_nmpesdst = ""   THEN
        DO:
            ASSIGN i-cod-erro  = 16
                   c-desc-erro = " "
                   par_focoerro = '21'.
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
   
   IF   par_inpesdst <> "Fisica"     AND
        par_inpesdst <> "Juridica"   THEN
        DO:
            ASSIGN i-cod-erro  = 436
                   c-desc-erro = " "
                   par_focoerro = '22'.
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    ASSIGN  par_cpfcgdst = REPLACE(par_cpfcgdst,"/","")
            par_cpfcgdst = REPLACE(par_cpfcgdst,".","")
            par_cpfcgdst = REPLACE(par_cpfcgdst,"-","").

   IF   par_cpfcgdst = ""   THEN
        DO:
            ASSIGN i-cod-erro  = 375
                   c-desc-erro = " "
                   par_focoerro = '23'.
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
        
   in01  = 1.
   ASSIGN c-desc-erro = " "
          i-cod-erro  = 0.
          
   DO  WHILE in01 LE LENGTH(par_cpfcgdst):
       IF  SUBSTR(par_cpfcgdst,in01,1) <> "0" AND
           SUBSTR(par_cpfcgdst,in01,1) <> "1" AND
           SUBSTR(par_cpfcgdst,in01,1) <> "2" AND
           SUBSTR(par_cpfcgdst,in01,1) <> "3" AND
           SUBSTR(par_cpfcgdst,in01,1) <> "4" AND
           SUBSTR(par_cpfcgdst,in01,1) <> "5" AND
           SUBSTR(par_cpfcgdst,in01,1) <> "6" AND
           SUBSTR(par_cpfcgdst,in01,1) <> "7" AND
           SUBSTR(par_cpfcgdst,in01,1) <> "8" AND
           SUBSTR(par_cpfcgdst,in01,1) <> "9" THEN 
           DO:
              ASSIGN  i-cod-erro = 27.
              LEAVE.
           END.    
       in01 = in01 + 1.
   END.
   IF i-cod-erro > 0      THEN DO:
       par_focoerro = '23'.
       RUN cria-erro (INPUT p-cooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT i-cod-erro,
                      INPUT c-desc-erro,
                      INPUT YES).
       RETURN "NOK".
   END.   

   RUN dbo/pcrap06.p (INPUT  par_cpfcgdst,
                      OUTPUT aux_flerrcgc,
                      OUTPUT aux_tppessoa).

   IF   NOT aux_flerrcgc   THEN
        DO:
            ASSIGN i-cod-erro  = 27
                   c-desc-erro = ""
                   par_focoerro = '23'. 
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

   IF   aux_tppessoa = 1            AND
        par_inpesdst = "Juridica"   THEN
        DO:
            ASSIGN i-cod-erro  = 436
                   c-desc-erro = " "
                   par_focoerro = '22'.
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
        
   IF   aux_tppessoa = 2          AND
        par_inpesdst = "Fisica"   THEN
        DO:
            ASSIGN i-cod-erro  = 436
                   c-desc-erro = " "
                   par_focoerro = '22'.
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

   IF   par_inpesdst = "Fisica"   THEN
        DO:
            IF   par_nridedst = ""   THEN
                 DO:
                     ASSIGN i-cod-erro  = 375
                            c-desc-erro = " "
                            par_focoerro = '24'.
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
            END.
   
            IF   par_dtnasdst = ?   THEN
                 DO:
                     ASSIGN i-cod-erro  = 375
                            c-desc-erro = " "
                            par_focoerro = '25'.
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
                 END.
   
            ASSIGN par_dtnasdst = REPLACE(par_dtnasdst,'/','').
                   
            IF  LENGTH(par_dtnasdst) <> 8 THEN 
                DO:
                    ASSIGN i-cod-erro  = 13 /* Data errada */
                           c-desc-erro = " ".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT par_cdagenci, 
                                   INPUT par_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    par_focoerro = '25'.
                    RETURN "NOK".    
                END.
           
            IF  par_dtnasdst <> " " THEN 
                DO:
                    ASSIGN i-cod-erro = 0
                           in01       = 1.
                    DO  WHILE in01  LE 8:
                        IF  SUBSTR(par_dtnasdst,in01,1) <> "0" AND
                            SUBSTR(par_dtnasdst,in01,1) <> "1" AND
                            SUBSTR(par_dtnasdst,in01,1) <> "2" AND
                            SUBSTR(par_dtnasdst,in01,1) <> "3" AND
                            SUBSTR(par_dtnasdst,in01,1) <> "4" AND
                            SUBSTR(par_dtnasdst,in01,1) <> "5" AND
                            SUBSTR(par_dtnasdst,in01,1) <> "6" AND
                            SUBSTR(par_dtnasdst,in01,1) <> "7" AND
                            SUBSTR(par_dtnasdst,in01,1) <> "8" AND
                            SUBSTR(par_dtnasdst,in01,1) <> "9" THEN 
                            DO:
                                ASSIGN i-cod-erro  = 13 /* Data errada */
                                       c-desc-erro = " ".
                                RUN cria-erro (INPUT p-cooper,
                                               INPUT par_cdagenci, 
                                               INPUT par_nrdcaixa,
                                               INPUT i-cod-erro,
                                               INPUT c-desc-erro,
                                               INPUT YES).
                                in01 = 8.
                            END.
                        in01 = in01 + 1.
                    END.
                    IF  i-cod-erro <> 0 THEN  
                        DO:
                            par_focoerro = '25'.
                            RETURN "NOK".
                        END.
                END.
  
            ASSIGN aux_dia      = INTE(SUBSTR(par_dtnasdst,1,2))
                   aux_mes      = INTE(SUBSTR(par_dtnasdst,3,2))
                   aux_ano      = INTE(SUBSTR(par_dtnasdst,5,4)).

            IF   (aux_dia = 0   OR
                  aux_dia > 31) OR
                 (aux_mes = 0   OR
                  aux_mes > 12) OR
                  aux_ano = 0    THEN
                 DO:
                     ASSIGN i-cod-erro  = 13
                            c-desc-erro = " "
                            par_focoerro = '25'.
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
                 END.
            ELSE     
                 IF   DATE(par_dtnasdst) > crapdat.dtmvtolt - 3500 then
                      DO:
                          ASSIGN i-cod-erro  = 13
                                 c-desc-erro = " "
                                 par_focoerro = '25'.
                          RUN cria-erro (INPUT p-cooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT i-cod-erro,
                                         INPUT c-desc-erro,
                                         INPUT YES).
                          RETURN "NOK".
                      END.
        END.

   IF   par_desendst = ""   THEN
        DO:
            ASSIGN i-cod-erro  = 375
                   c-desc-erro = " "
                   par_focoerro = '26'.
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
   
   IF   par_nmciddst = ""   THEN
        DO:
            ASSIGN i-cod-erro  = 375
                   c-desc-erro = " "
                   par_focoerro = '27'.
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
   
   IF   par_cdufddst = ""   THEN
        DO:
            RUN dbo/pcrap13.p (INPUT  par_cdufddst,
                               OUTPUT aux_flgerruf).
            
            IF   aux_flgerruf   THEN
                 DO:
                     ASSIGN i-cod-erro  = 33
                            c-desc-erro = " "
                            par_focoerro = '29'.
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
                 END.    
        END.
   
   IF   LENGTH(par_nrcepdst_x) <> 8 THEN
        DO:
           ASSIGN i-cod-erro  = 0
                  c-desc-erro = "CEP Destino Invalido "
                  par_focoerro = '28'.
           RUN cria-erro (INPUT p-cooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
        END.
   
   in01  = 1.
   ASSIGN c-desc-erro = " ".
   DO  WHILE in01 LE 8:
       IF  SUBSTR(par_nrcepdst_x,in01,1) <> "0" AND
           SUBSTR(par_nrcepdst_x,in01,1) <> "1" AND
           SUBSTR(par_nrcepdst_x,in01,1) <> "2" AND
           SUBSTR(par_nrcepdst_x,in01,1) <> "3" AND
           SUBSTR(par_nrcepdst_x,in01,1) <> "4" AND
           SUBSTR(par_nrcepdst_x,in01,1) <> "5" AND
           SUBSTR(par_nrcepdst_x,in01,1) <> "6" AND
           SUBSTR(par_nrcepdst_x,in01,1) <> "7" AND
           SUBSTR(par_nrcepdst_x,in01,1) <> "8" AND
           SUBSTR(par_nrcepdst_x,in01,1) <> "9" THEN 
           DO:
                ASSIGN  c-desc-erro = "CEP Destino  Invalido ".
                LEAVE.
           END.    
       in01 = in01 + 1.
   END.
   IF  c-desc-erro <> " " THEN 
       DO:
            ASSIGN  i-cod-erro = 0.
            par_focoerro = '28'.
            RUN cria-erro (INPUT p-cooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
       END.   
    
   ASSIGN par_nrcepdst = INT(par_nrcepdst_x).
   IF   par_nrcepdst = 0   THEN
        DO:
            ASSIGN i-cod-erro  = 34
                   c-desc-erro = " "
                   par_focoerro = '28'.
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

   DEF INPUT PARAM p-cooper      AS CHAR.
   DEF INPUT PARAM par_cdagenci  LIKE crapcme.cdagenci.
   DEF INPUT PARAM par_nrdcaixa  LIKE crapcme.nrdcaixa.
   DEF INPUT PARAM par_cdopecxa  LIKE crapcme.cdopecxa.
   DEF INPUT PARAM par_vlmincen  AS DECIMAL.
   DEF INPUT PARAM par_nrseqaut  LIKE crapcme.nrseqaut.
   DEF INPUT PARAM par_nrccdrcb  LIKE crapcme.nrccdrcb.
   DEF INPUT PARAM par_nmpesrcb  LIKE crapcme.nmpesrcb.
   DEF INPUT PARAM par_cpfcgrcb  AS CHAR FORMAT "x(18)".
   DEF INPUT PARAM par_inpesrcb  AS CHARACTER FORMAT "x(08)".
   DEF INPUT PARAM par_nridercb  LIKE crapcme.nridercb.
   DEF INPUT PARAM par_dtnasrcb  LIKE crapcme.dtnasrcb.
   DEF INPUT PARAM par_desenrcb  LIKE crapcme.desenrcb.
   DEF INPUT PARAM par_nmcidrcb  LIKE crapcme.nmcidrcb.
   DEF INPUT PARAM par_cdufdrcb  LIKE crapcme.cdufdrcb.
   DEF INPUT PARAM par_nrceprcb  LIKE crapcme.nrceprcb.
   DEF INPUT PARAM par_recursos  LIKE crapcme.recursos.
   DEF INPUT PARAM par_dstrecur  LIKE crapcme.dstrecur.
   DEF INPUT PARAM par_flinfdst  AS   CHAR.
 

   DEF VAR aux_flgexist          AS LOGICAL.
   DEF VAR aux_nrdctabb          LIKE craplcm.nrdctabb.
   DEF VAR aux_nrdocmto          LIKE craplcm.nrdocmto.
   DEF VAR h-b1wgen9998          AS HANDLE NO-UNDO.

   FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
  
   RUN elimina-erro (INPUT p-cooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa).    

   ASSIGN aux_flgexist = NO.
          
   FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                            NO-LOCK NO-ERROR.
   
   ASSIGN aux_nrdolote = 11000 + par_nrdcaixa.

   FOR EACH crablcm WHERE crablcm.cdcooper = crapcop.cdcooper   AND
                          crablcm.dtmvtolt = crapdat.dtmvtolt   AND
                          crablcm.cdagenci = par_cdagenci       AND
                          crablcm.cdbccxlt = 11                 AND
                          crablcm.nrdolote = aux_nrdolote       AND
                          crablcm.nrautdoc = par_nrseqaut       AND
                          crablcm.cdhistor = 1 USE-INDEX craplcm3  NO-LOCK:

       ASSIGN aux_flgexist = YES
              aux_nrdctabb = crablcm.nrdctabb
              aux_nrdocmto = crablcm.nrdocmto.
   END. 

   IF   NOT aux_flgexist   THEN
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
            
   FIND crablcm WHERE crablcm.cdcooper = crapcop.cdcooper   AND
                      crablcm.dtmvtolt = crapdat.dtmvtolt   AND
                      crablcm.cdagenci = par_cdagenci       AND
                      crablcm.cdbccxlt = 11                 AND
                      crablcm.nrdolote = aux_nrdolote       AND
                      crablcm.nrdctabb = aux_nrdctabb       AND
                      crablcm.nrdocmto = aux_nrdocmto       
                      USE-INDEX craplcm1 NO-LOCK NO-ERROR.
                      
   IF   NOT AVAILABLE crablcm   THEN
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

   FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                      crapass.nrdconta = crablcm.nrdconta  NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapass   THEN
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

   FIND crabcme WHERE crabcme.cdcooper = crapcop.cdcooper   AND
                      crabcme.dtmvtolt = crablcm.dtmvtolt   AND
                      crabcme.cdagenci = crablcm.cdagenci   AND
                      crabcme.cdbccxlt = crablcm.cdbccxlt   AND
                      crabcme.nrdolote = crablcm.nrdolote   AND
                      crabcme.nrdctabb = crablcm.nrdctabb   AND
                      crabcme.nrdocmto = crablcm.nrdocmto   
                      NO-LOCK NO-ERROR.
                           
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

   CREATE crapcme.
   ASSIGN crapcme.cdcooper = crapcop.cdcooper 
          crapcme.dtmvtolt = crablcm.dtmvtolt
          crapcme.cdagenci = crablcm.cdagenci
          crapcme.cdbccxlt = crablcm.cdbccxlt
          crapcme.nrdolote = crablcm.nrdolote
          crapcme.nrseqdig = crablcm.nrseqdig
          crapcme.nrdcaixa = par_nrdcaixa
          crapcme.cdopecxa = par_cdopecxa
          crapcme.nrdocmto = crablcm.nrdocmto
          crapcme.nmpesrcb = par_nmpesrcb
          crapcme.nrccdrcb = par_nrccdrcb
          crapcme.cpfcgrcb = DEC(STRING(par_cpfcgrcb,"99999999999"))
          crapcme.dtnasrcb = par_dtnasrcb                               
          crapcme.desenrcb = par_desenrcb
          crapcme.nmcidrcb = par_nmcidrcb
          crapcme.cdufdrcb = par_cdufdrcb
          crapcme.vllanmto = crablcm.vllanmto
          crapcme.tpoperac = 1 /* depositos */
          crapcme.nridercb = par_nridercb
          crapcme.recursos = par_recursos
          crapcme.dstrecur = par_dstrecur
          crapcme.nrdconta = crablcm.nrdconta
          crapcme.inpesrcb = 1
          crapcme.nrceprcb = par_nrceprcb
          crapcme.nrseqaut = crablcm.nrautdoc
          crapcme.nrdctabb = crablcm.nrdctabb
          crapcme.flinfdst = (par_flinfdst = "S"). /*  Informar Destinatario */ 
   
   IF   crablcm.vllanmto >= par_vlmincen   AND 
        crapass.inpessoa < 3               THEN /* Maior que R$ 100.000 */
        DO:
             ASSIGN crapcme.infrepcf = 1. /* Informar ao COAF */

             IF   crapass.inpessoa <> 2   THEN
                  ASSIGN crapcme.sisbacen = TRUE.

             RUN sistema/generico/procedures/b1wgen9998.p
                 PERSISTENT SET h-b1wgen9998.

             RUN email-controle-movimentacao IN h-b1wgen9998
                                                     (INPUT crapcop.cdcooper,
                                                      INPUT par_cdagenci,
                                                      INPUT par_nrdcaixa,
                                                      INPUT par_cdopecxa,
                                                      INPUT "crap051e.w",
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
        ASSIGN crapcme.infrepcf = 0. /* Nao Informar ao COAF */

   VALIDATE crapcme.

   RETURN "OK".
   
END PROCEDURE.

/***************************************************************************/

