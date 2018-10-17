/* ........................................................................... 
   
   Programa: Fontes/sldccr_n.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/97.                       Ultima atualizacao: 13/10/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para novas propostas de cartao de credito.

   Alteracoes: 11/08/98 - Alimentar o campo dtentr2v (Deborah).

               20/08/98 - Tratar novo cartao (Odair)

               31/08/98 - Incluir data de nascimento e identidade do titular
                          do cartao (Deborah).

               04/09/98 - Tratar tipo de conta 7 (Deborah).

               09/11/98 - Tratar situacao em prejuizo (Deborah).

             24/10/2000 - Desmembrar a critica 95 conforme a situacao do 
                          titular (Eduardo).

             25/07/2001 - Incluir geracao de nota promissoria (Margarete).

             28/12/2001 - Alterado para tratar a rotina ver_capital (Edson).

             18/04/2002 - Forcar a impressao da nota promissoria (Edson).

             25/06/2002 - Buscar o salario do cadastro (Deborah).

             31/07/2002 - Incluir nova situacao da conta (Margarete).
             
             20/01/2003 - Ajuste na nota promissoria para tratar os 
                          conjuges fiadores (Eduardo).
                          
             31/07/2003 - Inclusao da rotina ver_cadastro (Julio).

             01/09/2003 - Tratamento para segundo titular "corrige_segntl.p"
                          (Julio)
                          
             10/02/2004 - Tratamento para dia de debito conforme adm (Julio)
             
             10/05/2004 - Fazer aparecer sempre a ultima administradora por 
                          primeiro (Julio).

             23/06/2004 - Atualizar tabela avalistas Terceiros(Mirtes)

             17/08/2004 - Incluido campos cidade/uf/cep(Evandro).
             
             12/11/2004 - Tratar conta integracao (Ze).

             08/06/2005 - Tratar tipo de conta 17 / 18(Mirtes).

             05/07/2005 - Alimentado campo cdcooper das tabelas crawcrd,
                          crapavl e crapavt (Diego).
                          
             22/11/2005 - Correcao do tratamento para o dia do debito, caso 
                          nao esteja cadastrado (Julio)

             22/11/2005 - Permitir alterar tipo de cartao(devido 
                          conta integracao) (Mirtes)
             
             13/02/2006 - Criticar conta integracao caso for cartao para a 
                          mesma;
                        - Incluido glb_cdcooper nas buscas (Evandro).

             13/04/2006 - Incluido campo "Limite Debito" (Diego).
             
             29/06/2006 - Incluida critica para Atualizacao Cadastral na
                          inclusao de Cartao BB (Diego).

             12/09/2006 - Excluidas opcoes "TAB" (Diego).

             24/10/2006 - Pedir o documento antes do nascimento (Magui).
             
             05/01/2007 - Permitir cartao da conta integracao para tipos de
                          conta BANCOOB com conta itg ativa (Evandro).

             24/09/2007 - Conversao de rotina ver_capital e
                          ver_cadastro para BO (Sidnei/Precise)
                          
             25/01/2008 - Nao permitir novas propostas de cartao BB da mesma
                          modalidade (Elton).
                          
             10/06/2008 - Valor limite da cooperativa mediante ao BB(Guilherme)
             
             22/08/2008 - Alterar mensagem de erro (269) quando tipo ou valor 
                          de limite forem invalidos (David).

             24/09/2008 - Ajuste cartoes BB somente para 1o. titular(Guilherme)

             22/12/2008 - Valida cartoes BB por cpf(Guilherme).
             
             02/02/2009 - Correcao na validacao dos cartoes BB (Guilherme).

             13/02/2009 - Valida modalidade do cartao BB por CPF (David).
             
             02/06/2009 - Alteracao para utilizacao de BOs - Temp-tables -
                          GATI - Eder
                                                    
             06/10/2010 - Alteracao para contemplar pessoa juridica.
                          GATI - Sandro
                          
             26/04/2011 - Inclusões de variaveis de CEP integrado (nrendere,
                          complend e nrcxapst). (André - DB1)  
                          
             05/09/2011 - Incluido a chamada da procedure alerta_fraude
                          (Adriano).
                          
             25/05/2012 - Incluida mensagem de help para o campo tel_nmtitcrd
                          (Tiago).
                          
             10/07/2012 - Incluído nome do plástico no formulário alterando 
                          coluna nmtitcrd. Alterado campo "Titular do cartão"
                          para alterar coluna nmextttl (Guilherme Maba).
                          
             01/04/2013 - Retirado a chamada da procedure alerta_fraude
                          (Adriano).             
             
             29/05/2014 - Bloqueio de opcoes para Cartoes BANCOOB (Jean Michel). 
             
             18/06/2014 - Inclusao de novo parametro "tpdpagto" na procedure
                          cadastra_novo_cartao, foi deixado como default "0".
                          (Jean Michel).            
                          
            07/07/2014 - Correção da passagem de parâmetros para procedimento
                         de novo cartão (Lucas Lunelli - Projeto Cartões Bancoob)
                         
            25/09/2014 - Incluir parametro na chamada da rotina 
                         cadastra_novo_cartao (Renato-Supero)
            
            01/10/2014 - Incluir parametro na chamada da rotina 
                         carrega_dados_inclusao (Vanessa)
                         
            13/10/2015 - Desenvolvimento do projeto 126. (James)
                                                    
............................................................................ */

{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_sldccr.i }
{ includes/var_limite.i "NEW"} 

DEF VAR tel_dsgraupr AS CHAR FORMAT "x(16)"                            NO-UNDO.
DEF VAR tel_nmtitcrd AS CHAR FORMAT "x(40)"                            NO-UNDO.
DEF VAR tel_nmextttl AS CHAR FORMAT "x(50)"                            NO-UNDO.
DEF VAR tel_nrdoccrd AS CHAR FORMAT "x(15)"                            NO-UNDO.
DEF VAR tel_dsadmcrd AS CHAR FORMAT "x(20)"                            NO-UNDO.
DEF VAR tel_dscartao AS CHAR FORMAT "x(15)"                            NO-UNDO.

DEF VAR tel_flgimpnp AS LOGI FORMAT "Imprime/Nao Imprime"              NO-UNDO.

DEF VAR tel_dddebito AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR tel_cdadmcrd AS INTE                                           NO-UNDO.

DEF VAR tel_nrcpfcpf AS DECI FORMAT "999,999,999,99"                   NO-UNDO.
DEF VAR tel_vlsaltit AS DECI FORMAT "zzz,zz9.99"                       NO-UNDO.
DEF VAR tel_vlsalcjg AS DECI FORMAT "zzz,zz9.99"                       NO-UNDO.
DEF VAR tel_vlrendas AS DECI FORMAT "zzz,zz9.99"                       NO-UNDO.
DEF VAR tel_vlalugue AS DECI FORMAT "zzz,zz9.99"                       NO-UNDO.
DEF VAR tel_vllimdeb AS DECI FORMAT "zzz,zzz,zzz,zz9.99"               NO-UNDO.
DEF VAR tel_vllimpro AS DECI FORMAT "zzz,zz9.99"                       NO-UNDO.

DEF VAR tel_dtnasccr AS DATE FORMAT "99/99/9999"                       NO-UNDO.

DEF VAR tel_nmprimtl AS CHAR FORMAT "x(40)"                            NO-UNDO.
DEF VAR tel_dsrepinc AS CHAR FORMAT "x(40)"                            NO-UNDO.
DEF VAR tel_nrrepinc AS DECI                                           NO-UNDO.

DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_codrep   AS CHAR                                           NO-UNDO.
DEF VAR aux_cpfrepre AS DECI                                           NO-UNDO.
DEF VAR aux_nrrepinc AS CHAR                                           NO-UNDO.
DEF VAR aux_dsrepinc AS CHAR                                           NO-UNDO.
DEF VAR aux_idrepinc AS INTE                                           NO-UNDO.

DEF VAR aux_dsadmcrd AS CHAR                                           NO-UNDO.
DEF VAR aux_cdadmcrd AS CHAR                                           NO-UNDO.
DEF VAR aux_dscartao AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcartao AS CHAR                                           NO-UNDO.
DEF VAR aux_dddebito AS CHAR                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!"                                NO-UNDO.

DEF VAR aux_cdlimcrd AS INTE                                           NO-UNDO.
DEF VAR aux_idgraupr AS INTE                                           NO-UNDO.
DEF VAR aux_idadmcrd AS INTE                                           NO-UNDO.
DEF VAR aux_idcartao AS INTE                                           NO-UNDO.
DEF VAR aux_iddebito AS INTE                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_bfexiste AS LOGI                                           NO-UNDO.
DEF VAR aux_dtnasctl AS DATE                                           NO-UNDO.
DEF VAR aux_ulcpftit AS DECI FORMAT "999,999,999,99"                   NO-UNDO.

DEF VAR h_b1wgen0028 AS HANDLE                                         NO-UNDO.


FORM tel_dsgraupr  LABEL "Parentesco"         AT 08
     HELP "Use as teclas de direcao para selecionar o parentesco"
     tel_nrcpfcpf  LABEL "C.P.F."             AT 38
     SKIP(1)
     tel_nmextttl  LABEL "Titular do cartao"  AT 01
     HELP "Informar nome conforme Receita Federal"
     tel_nmtitcrd  LABEL "Nome no plastico"   AT 02
     HELP "Nao permitido abreviar o primeiro e o ultimo nome"
     tel_nrdoccrd  LABEL "Identidade"         AT 05
     tel_dtnasccr  LABEL "Nascimento"         AT 38
     SKIP(1)
     tel_dsadmcrd  LABEL "Administradora"     AT 01
     tel_dscartao  LABEL "Tipo"               AT 39
     SKIP(1)     
     tel_vlsaltit  LABEL "Salario"            AT 07
     tel_vlsalcjg  LABEL "Salario conjuge"    AT 33
     SKIP
     tel_vlrendas  LABEL "Outras rendas"      AT 01
     tel_vlalugue  LABEL "Aluguel"            AT 41
     SKIP(1)
     tel_dddebito  LABEL "Dia debito"  
                          HELP "Use as setas para escolher o dia para Debito."
     tel_vllimpro  LABEL "Limite proposto"
     tel_flgimpnp  LABEL "Promissoria"
          HELP '"I" para imprimir ou "N" para nao imprimir a promissoria.'
     SKIP(1)
     tel_vllimdeb  LABEL "Limite Debito" AT 01
     WITH ROW 6 SIDE-LABELS OVERLAY TITLE COLOR NORMAL " Nova Proposta "
               FRAME f_nova CENTERED.
               
FORM tel_nmprimtl  LABEL "Razao Social"      AT 01
     SKIP
     tel_nrcpfcgc  LABEL "CNPJ        "              AT 01
     SKIP(1)
     tel_dsrepinc  LABEL "Representante solicitante" AT 01
     HELP "Utilizar setas direita/esquerda para escolher Representante"
     SKIP(1)
     tel_nrcpfcpf  LABEL "CPF do titular do cartao"             AT 01
     tel_dtnasccr  LABEL "Nascimento"         AT 44
     SKIP(1)
     tel_nmextttl  LABEL "Titular do Cartao"  AT 01
     SKIP
     tel_nmtitcrd  LABEL "Nome no plastico"  AT 01
     SKIP(1)
     tel_dsadmcrd  LABEL "Administradora"     AT 01
     HELP "Utilizar setas direita/esquerda para escolher Administradora"
     tel_dscartao  LABEL "Tipo"               AT 39
     HELP "Utilizar setas direita/esquerda para escolher o Tipo de cartao"
     SKIP(1)     
     tel_dddebito  LABEL "Dia debito"  
                          HELP "Use as setas para escolher o dia para Debito."
     tel_vllimpro  LABEL "Limite Credito"
     SKIP(1)
     tel_vllimdeb  LABEL "Limite Debito" AT 01
     WITH ROW 5 SIDE-LABELS OVERLAY TITLE COLOR NORMAL " Nova Proposta "
               FRAME f_nova_pj CENTERED.

FORM "VERIFICAR ATUALIZACAO CADASTRAL" 
     WITH CENTERED ROW 10 OVERLAY COLOR MESSAGE FRAME f_msg_atualiza.

FUNCTION f_dddebito RETURN CHAR(INPUT par_indposic AS INTE):

    DEF VAR cDDebito AS CHAR NO-UNDO.

    DO aux_contador = 1 TO NUM-ENTRIES(tt-nova_proposta.dddebito,"#"):
        
        ASSIGN cDDebito = ENTRY(aux_contador,tt-nova_proposta.dddebito,"#").
        
        IF  ENTRY(1,cDDebito,";") = STRING(par_indposic,"99")  THEN 
            DO:
                ASSIGN cDDebito = ENTRY(2,cDDebito,";").
                LEAVE.
            END.
        ELSE
            ASSIGN cDDebito = "0".

    END.
   
    RETURN cDDebito.
   
END FUNCTION.

IF  NOT VALID-HANDLE(h_b1wgen0028) THEN
DO.
    RUN sistema/generico/procedures/b1wgen0028.p
        PERSISTENT SET h_b1wgen0028.

END.
ASSIGN aux_inpessoa = DYNAMIC-FUNCTION("f_tipo_assoc" IN h_b1wgen0028,glb_cdcooper,tel_nrdconta).

DELETE PROCEDURE h_b1wgen0028.


DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.
    
    RUN carrega_dados_inclusao IN h_b1wgen0028
                                    (INPUT glb_cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT glb_cdoperad,
                                     INPUT tel_nrdconta,
                                     INPUT glb_dtmvtolt,
                                     INPUT 1,
                                     INPUT 1,
                                     INPUT glb_nmdatela,
                                     INPUT 'V',
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-nova_proposta).
  
    
    DELETE PROCEDURE h_b1wgen0028.
    
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  AVAIL tt-erro   THEN
                DO:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                END.

            RETURN "NOK".

         END.
         
    FIND tt-nova_proposta NO-ERROR.
    
    IF  NOT AVAIL tt-nova_proposta  THEN
        RETURN "NOK".
         
    IF  aux_inpessoa = 1 THEN
        ASSIGN aux_dsgraupr = tt-nova_proposta.dsgraupr
               aux_cdgraupr = tt-nova_proposta.cdgraupr
               aux_dsadmcrd = tt-nova_proposta.dsadmcrd
               aux_cdadmcrd = tt-nova_proposta.cdadmcrd
               aux_dddebito = f_dddebito(INTE(ENTRY(1, aux_cdadmcrd)))
               aux_dscartao = tt-nova_proposta.dscartao
               aux_idgraupr = 4
               aux_idadmcrd = 1
               aux_idcartao = 2
               aux_iddebito = 1                        
               tel_dsgraupr = TRIM(ENTRY(aux_idgraupr,tt-nova_proposta.dsgraupr))
               tel_dsadmcrd = TRIM(ENTRY(aux_idadmcrd,tt-nova_proposta.dsadmcrd))
               tel_cdadmcrd = INTE(TRIM(ENTRY(aux_idadmcrd,
                                              tt-nova_proposta.cdadmcrd)))
               tel_dscartao = TRIM(ENTRY(aux_idcartao,tt-nova_proposta.dscartao))
               tel_vlsaltit = tt-nova_proposta.vlsalari
               tel_dddebito = INTE(ENTRY(aux_iddebito,aux_dddebito))
               tel_flgimpnp = TRUE
               aux_nrrepinc = ""
               tel_nrrepinc = 0
               tel_dsrepinc = "". 
    ELSE
        ASSIGN tel_nmprimtl = tt-nova_proposta.nmtitcrd
               tel_nrcpfcgc = STRING(tt-nova_proposta.nrcpfcgc,"99999999999999")
               tel_nrcpfcgc = STRING(tel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx")                                   
               aux_dsadmcrd = tt-nova_proposta.dsadmcrd
               aux_cdadmcrd = tt-nova_proposta.cdadmcrd
               aux_dscartao = tt-nova_proposta.dscartao
               aux_idrepinc = 1
               aux_idadmcrd = 1
               aux_idcartao = 2               
               tel_dsadmcrd = TRIM(ENTRY(aux_idadmcrd,tt-nova_proposta.dsadmcrd))
               tel_cdadmcrd = INTE(TRIM(ENTRY(aux_idadmcrd,
                                              tt-nova_proposta.cdadmcrd)))
               tel_dscartao = TRIM(ENTRY(aux_idcartao,tt-nova_proposta.dscartao))

               aux_nrrepinc = tt-nova_proposta.nrrepinc
               tel_nrrepinc = DECIMAL(TRIM(ENTRY(aux_idrepinc,
                                              tt-nova_proposta.nrrepinc)))
               aux_dsrepinc = tt-nova_proposta.dsrepinc

               tel_dsrepinc = TRIM(ENTRY(aux_idrepinc,tt-nova_proposta.dsrepinc))
               aux_iddebito = 1               
               aux_dddebito = f_dddebito(INTE(ENTRY(1, aux_cdadmcrd)))
               tel_dddebito = INTE(ENTRY(aux_iddebito,aux_dddebito)).

    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
        IF  aux_inpessoa = 1 THEN
            DO:

                DISPLAY tel_dscartao tel_flgimpnp WITH FRAME f_nova.
       
                UPDATE tel_dsgraupr   tel_nrcpfcpf   tel_nmextttl tel_nmtitcrd  
                       tel_nrdoccrd   tel_dtnasccr   tel_dsadmcrd 
                       tel_dscartao   tel_vlsaltit   tel_vlsalcjg   
                       tel_vlrendas   tel_vlalugue   tel_dddebito
                       tel_vllimpro
                       WITH FRAME f_nova
    
                EDITING:
            
                    READKEY.
            
                    IF  FRAME-FIELD = "tel_dsgraupr"  THEN
                        DO:
                            IF  KEYFUNCTION(LASTKEY) = "CURSOR-UP"     OR
                                KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
                                DO:
                                    IF  aux_idgraupr > NUM-ENTRIES(aux_dsgraupr)  THEN
                                        aux_idgraupr = NUM-ENTRIES(aux_dsgraupr).
                                         
                                    aux_idgraupr = aux_idgraupr - 1.
                                    
                                    IF  aux_idgraupr = 0  THEN
                                        aux_idgraupr = NUM-ENTRIES(aux_dsgraupr).
                                         
                                    tel_dsgraupr = ENTRY(aux_idgraupr,aux_dsgraupr).
                                    
                                    DISPLAY tel_dsgraupr WITH FRAME f_nova.
                                END.
                            ELSE
                            IF  KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"  OR
                                KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN  
                                DO:
                                    aux_idgraupr = aux_idgraupr + 1.
            
                                    IF  aux_idgraupr > NUM-ENTRIES(aux_dsgraupr)  THEN
                                        aux_idgraupr = 1.
            
                                    tel_dsgraupr = TRIM(ENTRY(aux_idgraupr,
                                                              aux_dsgraupr)).
            
                                    DISPLAY tel_dsgraupr WITH FRAME f_nova.
                                END.
                            ELSE
                            IF  KEYFUNCTION(LASTKEY) = "RETURN"    OR
                                KEYFUNCTION(LASTKEY) = "BACK-TAB"  OR
                                KEYFUNCTION(LASTKEY) = "GO"        THEN
                                DO:                                       
                                    IF  TRIM(ENTRY(aux_idgraupr,
                                                   aux_cdgraupr)) = "6"  THEN
                                        DO:        
                                            ASSIGN 
                                            tel_nmtitcrd = tt-nova_proposta.nmsegntl
                                            tel_nmextttl = tt-nova_proposta.nmsegntl
                                            tel_nrcpfcpf = 
                                                IF tt-nova_proposta.inpessoa = 1 THEN
                                                      tt-nova_proposta.nrcpfstl
                                                ELSE
                                                   0
                                            tel_dtnasccr = tt-nova_proposta.dtnasstl
                                            tel_nrdoccrd = tt-nova_proposta.nrdocstl.
                                               
                                            DISPLAY tel_nmextttl tel_nmtitcrd 
                                                    tel_nrcpfcpf tel_dtnasccr 
                                                    tel_nrdoccrd 
                                                    WITH FRAME f_nova.
                                        END.
                                    ELSE
                                    IF  TRIM(ENTRY(aux_idgraupr,
                                                   aux_cdgraupr)) = "1"  THEN
                                        DO:
                                            ASSIGN
                                               tel_nmtitcrd = tt-nova_proposta.nmconjug
                                               tel_nmextttl = tt-nova_proposta.nmconjug
                                               tel_dtnasccr = tt-nova_proposta.dtnasccj
                                               tel_nrdoccrd = ""
                                               tel_nrcpfcpf = 0.
                                                       
                                            DISPLAY tel_nmextttl tel_nmtitcrd 
                                                    tel_nrcpfcpf tel_dtnasccr 
                                                    tel_nrdoccrd  
                                                    WITH FRAME f_nova.
                                        END.
                                    ELSE           
                                    IF  TRIM(ENTRY(aux_idgraupr,
                                                   aux_cdgraupr)) = "5"  THEN
                                        DO:
                                            ASSIGN 
                                               tel_nmtitcrd = tt-nova_proposta.nmtitcrd
                                               tel_nmextttl = tt-nova_proposta.nmtitcrd
                                               tel_nrcpfcpf = 
                                                   IF tt-nova_proposta.inpessoa = 1 THEN
                                                      tt-nova_proposta.nrcpfcgc
                                                   ELSE
                                                      0
                                               tel_dtnasccr = tt-nova_proposta.dtnasctl
                                               tel_nrdoccrd = tt-nova_proposta.nrdocptl.
            
                                            DISPLAY tel_nmextttl tel_nmtitcrd 
                                                    tel_nrcpfcpf tel_dtnasccr 
                                                    tel_nrdoccrd
                                                    WITH FRAME f_nova.
                                        END.
                                    ELSE     
                                        DO:
                                            ASSIGN tel_nmextttl = ""
                                                   tel_nmtitcrd = ""
                                                   tel_nrcpfcpf = 0
                                                   tel_nrdoccrd = ""
                                                   tel_dtnasccr = ?.
                        
                                            DISPLAY tel_nmextttl tel_nmtitcrd 
                                                    tel_nrcpfcpf tel_dtnasccr 
                                                    tel_nrdoccrd
                                                    WITH FRAME f_nova.
                                        END.
            
                                    APPLY LASTKEY.
                                END.
                            ELSE
                            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                                APPLY LASTKEY.                  
                        END.      
                    ELSE
                    IF  FRAME-FIELD = "tel_dsadmcrd" AND TRIM(aux_dsadmcrd) <> ""  THEN
                        DO:
                            IF  KEYFUNCTION(LASTKEY) = "CURSOR-UP"     OR
                                KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
                                DO:
                                    IF  aux_idadmcrd > NUM-ENTRIES(aux_dsadmcrd)  THEN
                                        aux_idadmcrd = NUM-ENTRIES(aux_dsadmcrd).
            
                                    aux_idadmcrd = aux_idadmcrd - 1.
             
                                    IF  aux_idadmcrd = 0  THEN
                                        aux_idadmcrd = NUM-ENTRIES(aux_dsadmcrd).
            
                                    ASSIGN tel_dsadmcrd = ENTRY(aux_idadmcrd,
                                                                aux_dsadmcrd)
                                           tel_cdadmcrd = INTE(ENTRY(aux_idadmcrd,
                                                                     aux_cdadmcrd))
                                           aux_dddebito = f_dddebito(INT(ENTRY(
                                                            aux_idadmcrd,aux_cdadmcrd)))
                                           tel_dddebito = INT(ENTRY(1,aux_dddebito)).
                                    
                                    DISPLAY tel_dsadmcrd tel_dddebito WITH FRAME f_nova.
                                    
                                END.
                            ELSE
                            IF  KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"  OR
                                KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
                                DO: 
                                    aux_idadmcrd = aux_idadmcrd + 1.
            
                                    IF  aux_idadmcrd > NUM-ENTRIES(aux_dsadmcrd)  THEN
                                        aux_idadmcrd = 1.
                                    
                                    ASSIGN tel_dsadmcrd = ENTRY(aux_idadmcrd,
                                                                aux_dsadmcrd)
                                           tel_cdadmcrd = INTE(ENTRY(aux_idadmcrd,
                                                                     aux_cdadmcrd))
                                           aux_dddebito = f_dddebito(INT(ENTRY(
                                                            aux_idadmcrd,aux_cdadmcrd)))
                                           tel_dddebito = INT(ENTRY(1,aux_dddebito)).
            
                                    DISPLAY tel_dsadmcrd tel_dddebito WITH FRAME f_nova.
                                    
                                END.
                            ELSE
                            IF  KEYFUNCTION(LASTKEY) = "RETURN"     OR
                                KEYFUNCTION(LASTKEY) = "BACK-TAB"   OR
                                KEYFUNCTION(LASTKEY) = "GO"         OR
                                KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                                APPLY LASTKEY.
                        END. 
                    ELSE
                    IF  FRAME-FIELD = "tel_dddebito"  THEN
                        DO:
                            IF  KEYFUNCTION(LASTKEY) = "CURSOR-UP"     OR
                                KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
                                DO:
                                    IF  aux_iddebito > NUM-ENTRIES(aux_dddebito)  THEN
                                        aux_iddebito = NUM-ENTRIES(aux_dddebito).
            
                                    aux_iddebito = aux_iddebito - 1.
             
                                    IF  aux_iddebito = 0  THEN
                                        aux_iddebito = NUM-ENTRIES(aux_dddebito).
            
                                    tel_dddebito = INT(ENTRY(aux_iddebito,
                                                             aux_dddebito)).
            
                                    DISPLAY tel_dddebito WITH FRAME f_nova.
                                END.
                            ELSE
                            IF  KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"  OR
                                KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
                                DO:
                                    aux_iddebito = aux_iddebito + 1.
            
                                    IF  aux_iddebito > NUM-ENTRIES(aux_dddebito)  THEN
                                        aux_iddebito = 1.
            
                                    tel_dddebito = INT(ENTRY(aux_iddebito,
                                                             aux_dddebito)).
            
                                    DISPLAY tel_dddebito WITH FRAME f_nova.
                                END.
                            ELSE
                            IF  KEYFUNCTION(LASTKEY) = "RETURN"     OR
                                KEYFUNCTION(LASTKEY) = "BACK-TAB"   OR
                                KEYFUNCTION(LASTKEY) = "GO"         OR
                                KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                                APPLY LASTKEY.
                        END.
                    ELSE     
                    IF  FRAME-FIELD = "tel_dscartao"  THEN
                        DO:
                            IF  KEYFUNCTION(LASTKEY) = "CURSOR-UP"     OR
                                KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
                                DO:
                                    IF  aux_idcartao > NUM-ENTRIES(aux_dscartao)  THEN
                                        aux_idcartao = NUM-ENTRIES(aux_dscartao).
            
                                    aux_idcartao = aux_idcartao - 1.
            
                                    IF  aux_idcartao = 0  THEN
                                        aux_idcartao = NUM-ENTRIES(aux_dscartao).
            
                                    tel_dscartao = ENTRY(aux_idcartao,aux_dscartao).
            
                                    DISPLAY tel_dscartao WITH FRAME f_nova.
                                END.
                            ELSE
                            IF  KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"  OR
                                KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
                                DO:
                                    aux_idcartao = aux_idcartao + 1.
            
                                    IF  aux_idcartao > NUM-ENTRIES(aux_dscartao)  THEN
                                        aux_idcartao = 1.
            
                                    tel_dscartao = TRIM(ENTRY(aux_idcartao,
                                                              aux_dscartao)).
            
                                    DISPLAY tel_dscartao WITH FRAME f_nova.
                                END.
                            ELSE
                            IF  KEYFUNCTION(LASTKEY) = "RETURN"     OR
                                KEYFUNCTION(LASTKEY) = "BACK-TAB"   OR
                                KEYFUNCTION(LASTKEY) = "GO"         OR
                                KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                                APPLY LASTKEY.
                        END.      
                    ELSE
                    IF  FRAME-FIELD = "tel_vlsaltit"  OR 
                        FRAME-FIELD = "tel_vlsalcjg"  OR
                        FRAME-FIELD = "tel_vlrendas"  OR 
                        FRAME-FIELD = "tel_vlalugue"  OR
                        FRAME-FIELD = "tel_vllimpro"  THEN
                        IF  LASTKEY =  KEYCODE(".")  THEN
                            APPLY 44.
                        ELSE
                            APPLY LASTKEY.
                    ELSE
                        APPLY LASTKEY.            
                        
                END. /* Fim do EDITING */
                    
                /* Atualiza Limite Debito somente para Administradoras BB */
                IF  CAN-DO(tt-nova_proposta.cdadmdeb,STRING(tel_cdadmcrd))  THEN
                    DO:
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                     
                            UPDATE tel_vllimdeb WITH FRAME f_nova
                        
                            EDITING:
                         
                                READKEY.
                            
                                IF  FRAME-FIELD = "tel_vllimdeb"  THEN
                                    DO:
                                        IF  LASTKEY = KEYCODE(".")  THEN
                                            APPLY 44.
                                        ELSE
                                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN 
                                            LEAVE.
                                        ELSE     
                                            APPLY LASTKEY.                          
                                    END.     
                                ELSE
                                    APPLY LASTKEY.            
                         
                            END. /* Fim do EDITING */          
                                     
                            LEAVE.
            
                        END. /* FIM do DO WHILE TRUE */
        
                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                            NEXT.
                    END.
                ELSE
                    DO:
                        ASSIGN tel_vllimdeb = 0.
                        DISPLAY tel_vllimdeb WITH FRAME f_nova.
                        PAUSE 0. 
                    END. 


            END.
        ELSE
            DO:

                DISPLAY tel_nmprimtl tel_nrcpfcgc WITH FRAME f_nova_pj.
       
                UPDATE tel_dsrepinc   tel_nrcpfcpf   tel_dtnasccr tel_nmextttl
                       tel_nmtitcrd   tel_dsadmcrd   tel_dscartao
                       tel_dddebito   tel_vllimpro                   
                       WITH FRAME f_nova_pj

                EDITING:
            
                    READKEY.
          
                    IF  FRAME-FIELD = "tel_dsrepinc" AND TRIM(tel_dsrepinc) <> ""  THEN
                        DO:
                            IF  KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
                                DO:
                                    IF  aux_idrepinc > NUM-ENTRIES(aux_dsrepinc)  THEN
                                        aux_idrepinc = NUM-ENTRIES(aux_dsrepinc).
                
                                    aux_idrepinc = aux_idrepinc - 1.
                
                                    IF  aux_idrepinc = 0  THEN
                                        aux_idrepinc = NUM-ENTRIES(aux_dsrepinc).
                
                                    ASSIGN tel_dsrepinc = ENTRY(aux_idrepinc,
                                                                aux_dsrepinc).
                
                                    ASSIGN tel_nrrepinc = DECIMAL(ENTRY(aux_idrepinc,
                                                              aux_nrrepinc)).
    
                                    DISPLAY tel_dsrepinc WITH FRAME f_nova_pj.
                                END.            
                            ELSE
                            IF  KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
                                DO:
                                    aux_idrepinc = aux_idrepinc + 1.
            
                                    IF  aux_idrepinc > NUM-ENTRIES(aux_dsrepinc)  THEN
                                        aux_idrepinc = 1.
            
                                    ASSIGN tel_dsrepinc = ENTRY(aux_idrepinc,
                                                                aux_dsrepinc).
            
                                    ASSIGN tel_nrrepinc = DECIMAL(ENTRY(aux_idrepinc,
                                                              aux_nrrepinc)).

                                    DISPLAY tel_dsrepinc WITH FRAME f_nova_pj.
                                END.
                            ELSE
                                IF  KEYFUNCTION(LASTKEY) = "RETURN"      OR
                                    KEYFUNCTION(LASTKEY) = "BACK-TAB"    OR
                                    KEYFUNCTION(LASTKEY) = "GO"          OR
                                    KEYFUNCTION(LASTKEY) = "CURSOR-UP"   OR
                                    KEYFUNCTION(LASTKEY) = "CURSOR-DOWN" OR
                                    KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                                    APPLY LASTKEY.
                        END. 

                    ELSE
                    IF  FRAME-FIELD = "tel_nrcpfcpf"           AND
                        (KEYFUNCTION(LASTKEY) = "RETURN"       OR
                         KEYFUNCTION(LASTKEY) = "BACK-TAB"     OR
                         KEYFUNCTION(LASTKEY) = "GO"           OR
                         KEYFUNCTION(LASTKEY) = "CURSOR-UP"    OR
                         KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"  OR
                         KEYFUNCTION(LASTKEY) = "CURSOR-UP"    OR
                         KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"  )
                        THEN
                        DO:

                            IF  INPUT FRAME f_nova_pj tel_nrcpfcpf = 0 THEN
                                DO:

                                    ASSIGN tel_nmtitcrd:SENSITIVE = NO
                                           tel_nmextttl:SENSITIVE = NO
                                           tel_dtnasccr:SENSITIVE = NO
                                           tel_nmtitcrd = ""
                                           tel_dtnasccr = ?.

                                    DISP tel_nmtitcrd
                                         tel_dtnasccr WITH FRAME f_nova_pj.

                                END.

                            ELSE
                                 DO:

                                     ASSIGN tel_nmtitcrd:SENSITIVE = YES.

                                     IF  NOT VALID-HANDLE(h_b1wgen0028) THEN
                                     DO.
                                         RUN sistema/generico/procedures/b1wgen0028.p
                                             PERSISTENT SET h_b1wgen0028.
                                             
                                     END.

                                     RUN busca_dados_assoc IN h_b1wgen0028 ( INPUT glb_cdcooper,
                                                                             INPUT FRAME f_nova_pj tel_nrcpfcpf,
                                                                             INPUT YES,
                                                                             OUTPUT aux_nmprimtl,
                                                                             OUTPUT aux_dtnasctl,
                                                                             OUTPUT aux_bfexiste).

                                    IF  aux_bfexiste THEN
                                        DO:

                                            ASSIGN tel_nmextttl = aux_nmprimtl
                                                   tel_nmtitcrd = aux_nmprimtl
                                                   tel_dtnasccr = aux_dtnasctl
                                                   tel_dtnasccr:SENSITIVE = NO.

                                            DISP tel_nmtitcrd
                                                 tel_nmextttl
                                                 tel_dtnasccr WITH FRAME f_nova_pj.


                                        END.                                        
                                    ELSE
                                        DO:
    

                                            IF  aux_ulcpftit <> DEC(INPUT FRAME f_nova_pj tel_nrcpfcpf) THEN
                                                DO:

                                                    ASSIGN tel_nmtitcrd = ""
                                                           tel_dtnasccr = ?.

                                                    DISP tel_nmtitcrd
                                                         tel_dtnasccr WITH FRAME f_nova_pj.

                                                END.
                                            
                                            ASSIGN tel_dtnasccr:SENSITIVE = YES.

  
                                        END.
                                        

                                     DELETE PROCEDURE h_b1wgen0028.
                                     
                                 END.


                            ASSIGN aux_ulcpftit = INPUT FRAME f_nova_pj tel_nrcpfcpf.


                            APPLY LASTKEY.

                        END.

                    ELSE
                    IF  FRAME-FIELD = "tel_dsadmcrd" AND TRIM(aux_dsadmcrd) <> ""  THEN
                        DO:
                            IF  KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
                                DO:
                                    IF  aux_idadmcrd > NUM-ENTRIES(aux_dsadmcrd)  THEN
                                        aux_idadmcrd = NUM-ENTRIES(aux_dsadmcrd).

                                    aux_idadmcrd = aux_idadmcrd - 1.

                                    IF  aux_idadmcrd = 0  THEN
                                        aux_idadmcrd = NUM-ENTRIES(aux_dsadmcrd).

                                    ASSIGN tel_dsadmcrd = ENTRY(aux_idadmcrd,
                                                                aux_dsadmcrd)
                                           tel_cdadmcrd = INTE(ENTRY(aux_idadmcrd,
                                                                     aux_cdadmcrd))
                                           aux_dddebito = f_dddebito(INT(ENTRY(
                                                            aux_idadmcrd,aux_cdadmcrd)))
                                           tel_dddebito = INT(ENTRY(1,aux_dddebito)).

                                    DISPLAY tel_dsadmcrd tel_dddebito WITH FRAME f_nova_pj.
                                END.

                            ELSE
                                IF  KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
                                    DO:
                                        aux_idadmcrd = aux_idadmcrd + 1.

                                        IF  aux_idadmcrd > NUM-ENTRIES(aux_dsadmcrd)  THEN
                                            aux_idadmcrd = 1.

                                        ASSIGN tel_dsadmcrd = ENTRY(aux_idadmcrd,
                                                                    aux_dsadmcrd)
                                               tel_cdadmcrd = INTE(ENTRY(aux_idadmcrd,
                                                                         aux_cdadmcrd))
                                               aux_dddebito = f_dddebito(INT(ENTRY(
                                                                aux_idadmcrd,aux_cdadmcrd)))
                                               tel_dddebito = INT(ENTRY(1,aux_dddebito)).

                                        DISPLAY tel_dsadmcrd tel_dddebito WITH FRAME f_nova_pj.
                                    END.
                                ELSE
                                    IF  KEYFUNCTION(LASTKEY) = "RETURN"      OR
                                        KEYFUNCTION(LASTKEY) = "BACK-TAB"    OR
                                        KEYFUNCTION(LASTKEY) = "GO"          OR
                                        KEYFUNCTION(LASTKEY) = "CURSOR-UP"   OR
                                        KEYFUNCTION(LASTKEY) = "CURSOR-DOWN" OR
                                        KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                                        APPLY LASTKEY.
                        END.
                    ELSE
                    IF  FRAME-FIELD = "tel_dscartao"  THEN
                        DO:
                            IF  KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
                                DO:
                                    IF  aux_idcartao > NUM-ENTRIES(aux_dscartao)  THEN
                                        aux_idcartao = NUM-ENTRIES(aux_dscartao).

                                    aux_idcartao = aux_idcartao - 1.

                                    IF  aux_idcartao = 0  THEN
                                        aux_idcartao = NUM-ENTRIES(aux_dscartao).

                                    tel_dscartao = ENTRY(aux_idcartao,aux_dscartao).

                                    DISPLAY tel_dscartao WITH FRAME f_nova_pj.
                                END.
                            ELSE
                            IF  KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
                                DO:
                                    aux_idcartao = aux_idcartao + 1.

                                    IF  aux_idcartao > NUM-ENTRIES(aux_dscartao)  THEN
                                        aux_idcartao = 1.

                                    tel_dscartao = TRIM(ENTRY(aux_idcartao,
                                                              aux_dscartao)).

                                    DISPLAY tel_dscartao WITH FRAME f_nova_pj.
                                END.
                            ELSE
                            IF  KEYFUNCTION(LASTKEY) = "RETURN"      OR
                                KEYFUNCTION(LASTKEY) = "BACK-TAB"    OR
                                KEYFUNCTION(LASTKEY) = "GO"          OR
                                KEYFUNCTION(LASTKEY) = "CURSOR-UP"   OR
                                KEYFUNCTION(LASTKEY) = "CURSOR-DOWN" OR
                                KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                                APPLY LASTKEY.
                        END.

                   ELSE
                   IF  FRAME-FIELD = "tel_dddebito"  THEN
                       DO:
                           IF  KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
                               DO:
                                   IF  aux_iddebito > NUM-ENTRIES(aux_dddebito)  THEN
                                       aux_iddebito = NUM-ENTRIES(aux_dddebito).

                                   aux_iddebito = aux_iddebito - 1.

                                   IF  aux_iddebito = 0  THEN
                                       aux_iddebito = NUM-ENTRIES(aux_dddebito).

                                   tel_dddebito = INT(ENTRY(aux_iddebito,
                                                            aux_dddebito)).

                                   DISPLAY tel_dddebito WITH FRAME f_nova_pj.
                               END.
                           ELSE
                           IF  KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
                               DO:
                                   aux_iddebito = aux_iddebito + 1.

                                   IF  aux_iddebito > NUM-ENTRIES(aux_dddebito)  THEN
                                       aux_iddebito = 1.

                                   tel_dddebito = INT(ENTRY(aux_iddebito,
                                                            aux_dddebito)).

                                       DISPLAY tel_dddebito WITH FRAME f_nova_pj.
                               END.
                           ELSE
                           IF  KEYFUNCTION(LASTKEY) = "RETURN"      OR
                               KEYFUNCTION(LASTKEY) = "BACK-TAB"    OR
                               KEYFUNCTION(LASTKEY) = "GO"          OR
                               KEYFUNCTION(LASTKEY) = "CURSOR-UP"   OR
                               KEYFUNCTION(LASTKEY) = "CURSOR-DOWN" OR
                               KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                               APPLY LASTKEY.
                       END.


                   ELSE
                       APPLY LASTKEY.

                END. /* Fim do EDITING */

            END.
        
        IF tel_dsgraupr <> 'Primeiro Titular' THEN
            DO: 
                FIND crapadc WHERE crapadc.cdcooper = glb_cdcooper AND
                                   crapadc.nmresadm = tel_dsadmcrd NO-LOCK NO-ERROR NO-WAIT.

                IF AVAIL crapadc AND crapadc.cdadmcrd >= 81 AND crapadc.cdadmcrd < 90 THEN
                    DO:
                        BELL.
                        MESSAGE "Solicitacao de cartaoes BB somente para primeiro titular".
                        PAUSE 3.
                        HIDE MESSAGE.
                        NEXT.
                    END.
            END.
        

        RUN sistema/generico/procedures/b1wgen0028.p 
            PERSISTENT SET h_b1wgen0028.
        
        RUN valida_nova_proposta IN h_b1wgen0028
                                    (INPUT glb_cdcooper,
                                     INPUT glb_cdagenci, 
                                     INPUT 0, /*nrdcaixa*/
                                     INPUT 1, /*ayllos*/
                                     INPUT glb_nmdatela,
                                     INPUT glb_cdoperad,
                                     INPUT tel_nrdconta,
                                     INPUT glb_dtmvtolt,
                                     INPUT tel_dsgraupr,
                                     INPUT tel_nmtitcrd,
                                     INPUT tel_dsadmcrd,
                                     INPUT tel_dscartao,
                                     INPUT tel_vllimpro,
                                     INPUT tel_vllimdeb,
                                     INPUT tel_nrcpfcpf,
                                     INPUT INTE(tel_dddebito),
                                     INPUT tel_dtnasccr,
                                     INPUT tel_nrdoccrd,
                                     INPUT tel_dsrepinc,
                                     INPUT " ", /* dsrepres */
									 INPUT FALSE, /*par_flgdebit*/
									 INPUT 0, /*par_flgdebit*/
                                    OUTPUT TABLE tt-msg-confirma,
                                    OUTPUT TABLE tt-erro). 

        DELETE PROCEDURE h_b1wgen0028.
        
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
               FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
               IF  AVAIL tt-erro  THEN
                   DO:
                       BELL.
                       MESSAGE tt-erro.dscritic.
                   END.
            
               NEXT.
            END.
        
        FOR EACH tt-msg-confirma:
                    
            MESSAGE tt-msg-confirma.dsmensag.
            PAUSE.
               
        END. 
        
        LEAVE.

    END. /* Fim do DO WHILE TRUE */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:

            IF  aux_inpessoa = 1 THEN
                HIDE FRAME f_nova NO-PAUSE.
            ELSE
                HIDE FRAME f_nova_pj NO-PAUSE.

            RETURN "NOK".
        END.
        
    ASSIGN lim_nrctaav1    = 0
           lim_nmdaval1    = " "
           lim_cpfcgc1     = 0
           lim_tpdocav1    = " " 
           lim_dscpfav1    = " "
           lim_nmdcjav1    = " "
           lim_cpfccg1     = 0
           lim_tpdoccj1    = " " 
           lim_dscfcav1    = " "
           lim_dsendav1[1] = " "
           lim_dsendav1[2] = " "
           lim_nrfonres1   = " "
           lim_dsdemail1   = " "
           lim_nmcidade1   = " " 
           lim_cdufresd1   = " "
           lim_nrcepend1   = 0
           lim_nrendere1   = 0    
           lim_complend1   = " "
           lim_nrcxapst1   = 0

           lim_nrctaav2    = 0 
           lim_nmdaval2    = " " 
           lim_cpfcgc2     = 0
           lim_tpdocav2    = " "
           lim_dscpfav2    = " "
           lim_nmdcjav2    = " "
           lim_cpfccg2     = 0
           lim_tpdoccj2    = " " 
           lim_dscfcav2    = " "
           lim_dsendav2[1] = " "
           lim_dsendav2[2] = " "
           lim_nrfonres2   = " "
           lim_dsdemail2   = " "
           lim_nmcidade2   = " " 
           lim_cdufresd2   = " "
           lim_nrcepend2   = 0
           lim_nrendere2   = 0    
           lim_complend2   = " "
           lim_nrcxapst2   = 0.
          

    IF  aux_inpessoa = 1 THEN
        IF  tel_flgimpnp  THEN 
            DO:
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                     
                    RUN fontes/limite_inp.p.
            
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN 
                        DO:
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                                aux_confirma = "N".
                            
                                BELL.
                                MESSAGE COLOR NORMAL
                                        "Confirma o cancelamento da proposta?" 
                                        UPDATE aux_confirma.
    
                                LEAVE.
    
                            END.
    
                            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                                aux_confirma = "S"                  THEN
                                DO:
                                    glb_cdcritic = 79.
                                    RUN fontes/critic.p.
                                    glb_cdcritic = 0.
    
                                    BELL.
                                    MESSAGE glb_dscritic.
    
                                    HIDE FRAME f_nova NO-PAUSE. 
                                    
                                    RETURN "NOK".
                                END.
                            ELSE
                                NEXT.
                        END. 
                          
                    LEAVE.    
                          
                END. /* Fim do DO WHILE TRUE */     
            END. 
        
    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.
    
    RUN cadastra_novo_cartao IN h_b1wgen0028
                                (/*** Parametros Gerais ***/
                                 INPUT glb_cdcooper,
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT glb_cdoperad,
                                 INPUT tel_nrdconta,
                                 INPUT glb_dtmvtolt,
                                 INPUT 1,
                                 INPUT 1,
                                 INPUT glb_nmdatela,
                                 /*** Dados do Novo Cartao ***/
                                 INPUT tel_dsgraupr,
                                 INPUT tel_nrcpfcpf,
                                 INPUT tel_nmextttl,
                                 INPUT tel_nmtitcrd,
                                 INPUT "",
                                 INPUT tel_nrdoccrd,
                                 INPUT tel_dtnasccr,
                                 INPUT tel_dsadmcrd,
                                 INPUT tel_cdadmcrd,
                                 INPUT tel_dscartao,
                                 INPUT tel_vlsaltit,
                                 INPUT tel_vlsalcjg,
                                 INPUT tel_vlrendas,
                                 INPUT tel_vlalugue,
                                 INPUT INT(tel_dddebito),
                                 INPUT tel_vllimpro,
                                 INPUT tel_flgimpnp,
                                 INPUT tel_vllimdeb,
                                 INPUT tel_nrrepinc,
                                 INPUT 0,
                                 INPUT 0,
                                 /*** Dados do primeiro avalista ***/
                                 INPUT lim_nrctaav1,
                                 INPUT lim_nmdaval1,
                                 INPUT lim_cpfcgc1,
                                 INPUT lim_tpdocav1,
                                 INPUT lim_dscpfav1,
                                 INPUT lim_nmdcjav1,
                                 INPUT lim_cpfccg1,
                                 INPUT lim_tpdoccj1,
                                 INPUT lim_dscfcav1,
                                 INPUT lim_dsendav1[1],
                                 INPUT lim_dsendav1[2],
                                 INPUT lim_nrfonres1,
                                 INPUT lim_dsdemail1,
                                 INPUT lim_nmcidade1,
                                 INPUT lim_cdufresd1,
                                 INPUT lim_nrcepend1,
                                 INPUT lim_nrendere1,
                                 INPUT lim_complend1,
                                 INPUT lim_nrcxapst1,
                                 /*** Dados do segundo avalista ***/
                                 INPUT lim_nrctaav2,
                                 INPUT lim_nmdaval2,
                                 INPUT lim_cpfcgc2,
                                 INPUT lim_tpdocav2,
                                 INPUT lim_dscpfav2,
                                 INPUT lim_nmdcjav2,
                                 INPUT lim_cpfccg2,
                                 INPUT lim_tpdoccj2,
                                 INPUT lim_dscfcav2,
                                 INPUT lim_dsendav2[1],
                                 INPUT lim_dsendav2[2],
                                 INPUT lim_nrfonres2,
                                 INPUT lim_dsdemail2,
                                 INPUT lim_nmcidade2,
                                 INPUT lim_cdufresd2,
                                 INPUT lim_nrcepend2,
                                 INPUT lim_nrendere2,
                                 INPUT lim_complend2,
                                 INPUT lim_nrcxapst2,
                                 INPUT " ", /* par_dsrepres */
                                 INPUT " ", /* par_dsrepinc */
                                 INPUT FALSE,
								 INPUT 0, /*par_nrctrcrd*/
                                OUTPUT TABLE tt-ctr_novo_cartao,
                                OUTPUT TABLE tt-msg-confirma,
                                OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h_b1wgen0028.
    

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAIL tt-erro  THEN
                DO:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                END.

            NEXT.
        END.
                                   
    FOR EACH tt-msg-confirma:
        MESSAGE tt-msg-confirma.dsmensag.
        PAUSE.
    END.

    FIND tt-ctr_novo_cartao NO-ERROR.
    
    IF  NOT AVAIL tt-ctr_novo_cartao  THEN
        DO:

            IF  aux_inpessoa = 1 THEN
                HIDE FRAME f_nova NO-PAUSE.
            ELSE
                HIDE FRAME f_nova_pj NO-PAUSE.

            RETURN "NOK".
        END.    

    IF  aux_inpessoa = 1 THEN
        HIDE FRAME f_nova NO-PAUSE.    
    ELSE
        HIDE FRAME f_nova_pj NO-PAUSE.

    LEAVE.

END. /* Fim do DO WHILE TRUE */

IF  aux_inpessoa = 1 THEN
    RUN fontes/sldccr_ip.p (INPUT tt-ctr_novo_cartao.nrctrcrd,1).
ELSE
    RUN fontes/sldccr_ip.p (INPUT tt-ctr_novo_cartao.nrctrcrd,2).

RETURN "OK".

/* ......................................................................... */
