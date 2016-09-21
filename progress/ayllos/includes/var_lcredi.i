/* .............................................................................

   Programa: includes/var_lcredi.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/94.                           Ultima atualizacao: 16/11/2015
   
   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Definicao das variaveis e forms da tela LCREDI.

   Alteracoes: 14/10/94 - Alterado para inclusao de novos parametros para as
                          linhas de credito: taxa minima e maxima e o sinali-
                          zador de linha com saldo devedor.

               21/02/97 - Alterado para permitir o tratamento de ate 100 par-
                          celas (Edson).

               05/10/1999 - Aumentado o numero de casas decimais na taxa
                            (Edson).

               07/03/2001 - Permitir numeracao dos grupos ate 20 (Deborah).
               
               20/12/2002 - Incluir na tela Valor da Tarifa Especial (Junior).
               
               24/03/2004 - Incluido na tela campo Dias Carencia(Mirtes).
               
               11/06/2004 - Incluido na tela campos - Valor Maximo Linha e
                                         Valor Maximo Associado (Evandro).

               28/06/2004 - Removido - colocado em comentarios - o campo Valor
                            Maximo Linha - tel_vlmaxdiv (Evandro).
                            
               10/08/2004 - Incluido campo tel_vlmaxasj - Valor Maximo Pessoa
                            Juridica (Evandro).
                            
               30/08/2004 - Inclusao do campo tpdescto para consig. de emprest.
                            (Julio).

               08/08/2006 - Alteracao de WORKFILE para TEMP-TABLE linha 48 - 
                            SQLWorks - Fernando.

               17/03/2006 - Excluido campo "Conta ADM", e acrescentado
                            tel_flgcrcta (Diego).
                            
               28/08/2007 - Adicionado campo cdusolcr(Guilherme).

               10/12/2007 - Retirado VALIDATE do campo tel_txminima para 
                            efetuar tratamento para Transpocred (Diego).
                            
               24/04/2008 - Alterado formato da mascara das variaveis
                            "tel_nrfimpre" e "tel_qtpresta" de "z9" para "zz9".
                            Alterada condicao de validacao da variavel
                            "tel_nrfimpre" de "100" para "240" - Kbase IT
                             Solutions - Paulo Ricardo Maciel.
               
               23/06/2009 - Incluido campo Operacao (Gabriel).
               
               16/12/2009 - Alterado campo Operacao "tel_dsoperac" para ser 
                            CHAR ao invés de LOGICAL e incluido browser para
                            "F7" desse campo (Elton).
               
               15/03/2010 - Incluido o campo que irá indicar o tempo que o 
                            empréstimo permanecerá na atenda após sua 
                            liquidaçao (Gati -Daniel). 
               
               16/03/2010 - incluido o campo que ira conter a origem do
                            recurso (gati - Daniel)  
                            
               15/06/2010 - incluido o campo que determina se a impressao da
                            declaracao (Sandro - gati)          
                            
               19/07/2010 - Incluir campo de 'Listar na proposta' (Gabriel).   
               
               
               16/06/2011 - Inclusao do campo craplcr.perjurmo (Adriano). 
               
               28/11/2011 - Alteraçoes para tornar a variável 'tel_tplcremp'
                            disponível para ediçao na tela LCREDI, na Opçao A 
                            (Lucas). 
                            
               16/03/2012 - Retirado limitaçao do grupo da linha de credito
                            ter número até 50. (Irlan).        
                            
               23/05/2012 - Adicionado campo de Tarifa IOF (Lucas).
               
               12/06/2012 - Criado o BUFFER crablch (Lucas).
               
               25/07/2012 - Declaraçao da Temp-Table 'tt-log-craplcr' e da 
                            var 'aux_cdfinlog' para LOG (Lucas).
                            
               08/10/2012 - Incluir campos de Modalidade e Sub Modalidade
                            (Gabriel).         
                            
               11/10/2012 - Incluir Campo flgreneg na tela (Lucas R.)
               
               28/05/2013 - Softdesk 66547 Incluir Campo flgrefin na tela 
                            (Carlos)    
                            
               03/07/2013 - Alterado tamanho do BROWSE para visualizaçao da
                            Modalidade (Douglas).
                            
               25/04/2014 - Aumentado format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow SD137074).
                            
               29/01/2015 - (Chamado 248647)Inclusao do novo campo de
                            consulta automatizada (Tiago Castro - RKAM).
                            
               24/02/2015 - Novo campo QTRECPRO para a analise de credito
                            (Jonata-RKAM).             
                            
               04/03/2015 - Aumentar campo tel_origrecu para poder receber
                            a nova origem de recurso "MICROCREDITO PNMPO 
                            BNDES CECRED". (Jaison/Gielow - SD: 257430)
                            
               27/05/2015 - Incluir Frame da Cessao de Credito. (James)
               
               16/11/2015 - Aumentado format do campo de GRUPO (Lunelli SD 353723)
               
............................................................................. */

DEF BUFFER crabtab FOR craptab.
DEF BUFFER crablcr FOR craplcr.
DEF BUFFER crablch FOR craplch.

DEF TEMP-TABLE crawlcr                                                  NO-UNDO
             FIELD cdlcremp AS INT     FORMAT "zzz9".

DEF TEMP-TABLE tt-log-craplcr  NO-UNDO LIKE craplcr.



DEF {1} SHARED VAR tel_cdlcremp AS INT     FORMAT "zzz9"                NO-UNDO.
DEF {1} SHARED VAR tel_dslcremp AS CHAR    FORMAT "x(30)"               NO-UNDO.
DEF {1} SHARED VAR tel_dssitlcr AS CHAR    FORMAT "x(25)"               NO-UNDO.
DEF {1} SHARED VAR tel_indsaldo AS CHAR    FORMAT "x(01)"               NO-UNDO.
DEF {1} SHARED VAR tel_dsdsaldo AS CHAR    FORMAT "x(09)"               NO-UNDO.
DEF {1} SHARED VAR tel_insitlcr AS CHAR    FORMAT "x(01)"               NO-UNDO.
DEF {1} SHARED VAR tel_cdfinemp AS INT     FORMAT "zzz"      EXTENT 81  NO-UNDO.
DEF {1} SHARED VAR tel_qtpresta AS INT     FORMAT "zz9"      EXTENT 24  NO-UNDO.
DEF {1} SHARED VAR tel_inpresta AS DECIMAL FORMAT "9.999999" EXTENT 24  NO-UNDO.
DEF {1} SHARED VAR tel_dsoperac AS CHAR   FORMAT "x(29)"                NO-UNDO.
DEF {1} SHARED VAR aux_dsoperac AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR tel_txjurfix AS DECIMAL FORMAT "zz9.99"              NO-UNDO.
DEF {1} SHARED VAR tel_txjurvar AS DECIMAL FORMAT "zz9.99"              NO-UNDO.
DEF {1} SHARED VAR tel_txpresta AS DECIMAL FORMAT "zz9.99"              NO-UNDO.
DEF {1} SHARED VAR tel_txbaspre AS DECIMAL FORMAT "zz9.99"              NO-UNDO.
DEF {1} SHARED VAR tel_txmensal AS DECIMAL FORMAT "zz9.999999"          NO-UNDO.
DEF {1} SHARED VAR tel_perjurmo AS DECIMAL FORMAT "zz9.999999"          NO-UNDO.
DEF {1} SHARED VAR tel_txminima AS DECIMAL FORMAT "zz9.99"              NO-UNDO.
DEF {1} SHARED VAR tel_txmaxima AS DECIMAL FORMAT "zz9.99"              NO-UNDO.
DEF {1} SHARED VAR tel_txdiaria AS DECIMAL FORMAT "zz9.9999999"         NO-UNDO.
DEF {1} SHARED VAR tel_qtdcasas AS INT     FORMAT "9"                   NO-UNDO.
DEF {1} SHARED VAR tel_nrinipre AS INT     FORMAT "z9"                  NO-UNDO.
DEF {1} SHARED VAR tel_nrfimpre AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_nrgrplcr AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_nrdevias AS INT     FORMAT "9"                   NO-UNDO.
DEF {1} SHARED VAR tel_cdusolcr AS INT     FORMAT "99"                  NO-UNDO.
DEF {1} SHARED VAR tel_tplcremp AS INT     FORMAT "9"                   NO-UNDO.
DEF {1} SHARED VAR tel_tpctrato AS INT     FORMAT "9"                   NO-UNDO.
DEF {1} SHARED VAR tel_flgcrcta AS LOGICAL FORMAT "Sim/Nao"             NO-UNDO.
DEF {1} SHARED VAR tel_dstipolc AS CHAR    FORMAT "x(23)"               NO-UNDO.
DEF {1} SHARED VAR tel_dsctrato AS CHAR    FORMAT "x(16)"               NO-UNDO.
DEF {1} SHARED VAR tel_dsdescto AS CHAR    FORMAT "x(13)"               NO-UNDO.
DEF {1} SHARED VAR tel_dsusolcr AS CHAR    FORMAT "x(13)"               NO-UNDO.
DEF {1} SHARED VAR tel_dsindice AS CHAR    FORMAT "x(65)"               NO-UNDO.
DEF {1} SHARED VAR tel_dsfinali AS CHAR    FORMAT "x(65)"               NO-UNDO.
DEF {1} SHARED VAR tel_flgtarif AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR tel_flgtaiof LIKE craplcr.flgtaiof                   NO-UNDO.
DEF {1} SHARED VAR tel_vltrfesp AS DECIMAL FORMAT "zzz,zz9.99"          NO-UNDO.
DEF {1} SHARED VAR tel_qtcarenc AS INTE    FORMAT " z,zz9"              NO-UNDO.
DEF {1} SHARED VAR tel_origrecu AS CHAR    FORMAT "x(35)"               NO-UNDO.
DEF {1} SHARED VAR tel_manterpo AS INTE    FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_flgimpde AS LOGICAL FORMAT "Sim/Nao"  INITIAL NO NO-UNDO.
DEF {1} SHARED VAR tel_tpdescto LIKE craplcr.tpdescto                   NO-UNDO.
DEF {1} SHARED VAR tel_flglispr LIKE craplcr.flglispr                   NO-UNDO.
DEF {1} SHARED VAR tel_cdmodali LIKE craplcr.cdmodali                   NO-UNDO.
DEF {1} SHARED VAR tel_cdsubmod LIKE craplcr.cdsubmod                   NO-UNDO.
DEF {1} SHARED VAR tel_flgreneg AS LOGICAL FORMAT "Sim/Nao" INITIAL NO  NO-UNDO.
DEF {1} SHARED VAR tel_flgrefin LIKE craplcr.flgrefin 
                                           FORMAT "Sim/Nao" INITIAL YES NO-UNDO.

DEF {1} SHARED VAR tel_consaut  AS LOGICAL FORMAT "Sim/Nao" INITIAL YES  NO-UNDO.

DEF {1} SHARED VAR tel_vlmaxass AS DECIMAL FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF {1} SHARED VAR tel_vlmaxasj AS DECIMAL FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF {1} SHARED VAR tel_qtrecpro AS DECIMAL FORMAT "zz9.99"              NO-UNDO.

DEF {1} SHARED VAR ant_nrinipre AS INT                                  NO-UNDO.
DEF {1} SHARED VAR ant_nrfimpre AS INT                                  NO-UNDO.
DEF {1} SHARED VAR ant_tplcremp AS INT     FORMAT "9"                   NO-UNDO.

DEF {1} SHARED VAR aux_dstipolc AS CHAR                                 NO-UNDO.

DEF {1} SHARED VAR aux_cddopcao AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_cdfinlog AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_lslcrhab AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_lsfinhab AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_lsctrato AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_nvfinhab AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_exfinhab AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_confirma AS CHAR    FORMAT "x"                   NO-UNDO.

DEF {1} SHARED VAR aux_incalpre AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR aux_incalcul AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR aux_txbaspre AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR aux_txutiliz AS DECIMAL                              NO-UNDO.

DEF {1} SHARED VAR aux_qtpresta AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_tentaler AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_contalcr AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_contador AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_contalin AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_stimeout AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrseqlch AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_cdlcremp AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_cdusolcr AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_flusolcr AS LOGICAL                              NO-UNDO.

DEF {1} SHARED VAR aux_flgclear AS LOGICAL INIT TRUE                    NO-UNDO.

DEF {1} SHARED VAR aut_flgsenha AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aut_cdoperad AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR tel_flgdisap LIKE craplcr.flgdisap                   NO-UNDO.
DEF {1} SHARED VAR tel_flgcobmu LIKE craplcr.flgcobmu                   NO-UNDO.
DEF {1} SHARED VAR tel_flgsegpr LIKE craplcr.flgsegpr                   NO-UNDO.
DEF {1} SHARED VAR tel_cdhistor LIKE craplcr.cdhistor                   NO-UNDO.

DEF {1} SHARED FRAME f_moldura.
DEF {1} SHARED FRAME f_lcredi.
DEF {1} SHARED FRAME f_finali.
DEF {1} SHARED FRAME f_presta.
DEF {1} SHARED FRAME f_descricao.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT 3 LABEL "Opcao" AUTO-RETURN
                  HELP "Informe a opcao desejada (A, B, C, E, F, I, L ou P)."
                        VALIDATE(CAN-DO("A,B,C,E,F,I,L,P",glb_cddopcao),
                                 "014 - Opcao errada.")

     tel_cdlcremp AT 15 LABEL "Codigo" AUTO-RETURN
         HELP "Informe o codigo ou tecle <F7> para listar as linhas."
                          VALIDATE(tel_cdlcremp > 0,
                                   "363 - Linha de credito nao cadastrada.")

     tel_dslcremp AT 30  LABEL "Descricao" 
                             HELP "Informe a descricao da linha de credito."
                             VALIDATE(tel_dslcremp <> "",
                                      "375 - O campo deve ser preenchido.")
    SKIP(8)
    WITH CENTERED NO-BOX ROW 6 SIDE-LABELS OVERLAY WIDTH 78 FRAME f_lcredi.


FORM tel_dsoperac AT  2 LABEL "Ope." AUTO-RETURN
      HELP "Informe 'F7' para selecionar o tipo de operacao." 

     tel_tplcremp AT 39 LABEL "Tipo"
      HELP "Entre com o tipo de Linha de Credito (1-Normal, 2-Equiv. Salarial)."
                             VALIDATE(tel_tplcremp > 0 and
                                  tel_tplcremp < NUM-ENTRIES(aux_dstipolc) + 1,
                                      "513 - Tipo errado.")                            
     tel_dstipolc            NO-LABEL
     SKIP(1)
     tel_tpdescto AT  2 LABEL "Dscto."
      HELP "Entre com o tipo de desconto (1-C/C, 2-Consig. Folha)."
                             VALIDATE(tel_tpdescto > 0 and tel_tpdescto < 3,
                                      "513 - Tipo errado.")
     tel_dsdescto            NO-LABEL
     
     tel_tpctrato AT 37 LABEL "Modelo"
      HELP "Entre com o modelo do contrato (1-Normal, 2-Alienacao, 3-Hipoteca)."
                             VALIDATE(CAN-DO(aux_lsctrato,
                                             STRING(tel_tpctrato)),
                                     "529 - Modelo de contrato nao cadastrado.")
         
     tel_dsctrato            NO-LABEL
    
     tel_nrdevias AT 64 LABEL "Qt.Vias"
         HELP "Entre com a quantidade vias a serem impressas do contrato."
         VALIDATE(tel_nrdevias > 0,"026 - Quantidade errada.")

     SKIP
     tel_flgrefin AT 2  LABEL "Refinancia contratos?"
         HELP "(S)im identifica linha de refinanciamento ou (N)ao caso contrario."

     tel_flgreneg AT 31 LABEL "Renegociacao"
         HELP "(S)im identifica linha de renegociacao ou (N)ao caso contrario."

     SKIP
     tel_cdusolcr AT  2 LABEL "Cod. Uso" FORMAT "z9"
         HELP "Entre com 0-Normal, 1-Micro Credito ou 2-Epr/Boletos."
         VALIDATE(tel_cdusolcr < 3,"269 -  Valor errado.")

     tel_dsusolcr       NO-LABEL

     tel_flgtarif AT  30 LABEL "Tarifa Normal" FORMAT "Cobrar/Isentar"
         HELP "Entre com (C)obrar ou (I)sentar a tarifa para o contrato."

     tel_flgtaiof AT  62 LABEL "IOF" FORMAT "Cobrar/Isentar"
         HELP "Entre com (C)obrar ou (I)sentar o IOF."

    SKIP(1)
    tel_vltrfesp  AT   2 LABEL "Vlr. Tarifa Especial" 
         HELP "Entre com o valor da tarifa especial para o contrato."

    tel_flgcrcta  AT 37 LABEL "Credita C/C"
         HELP "Informe (S)im p/ creditar ou (N)ao p/ nao creditar em C/C. "   
     
     tel_manterpo AT 55 LABEL "Manter apos Liq." 
     HELP "Informe a qtde de dias apos liq. emprestimo permanece na atenda. "

     SKIP(1)

     tel_flgimpde   AT 2 LABEL "Imprime Declaracao"
         HELP "Informe (S)im p/ imprimir ou (N)ao p/ nao imprimir a declaracao. " 

     tel_origrecu AT 28 LABEL "Origem Rec" 
        HELP "Informe 'F7' para selecionar a Origem do Recurso"
     
     SKIP(1)

     tel_flglispr AT 2 LABEL "Listar na Proposta" FORMAT "Sim/Nao"
         HELP "Informe (S)im p/ imprimir na proposta ou (N)ao p/ nao imprimir."
     
     tel_dssitlcr AT 35 LABEL "Situacao"
     
     SKIP(1)
     tel_cdmodali AT  2 LABEL "Modalidade (BACEN)"     FORMAT "X(12)"
         HELP "Informe 'F7' para selecionar a Modalidade."
         VALIDATE(tel_cdmodali <> "","375 - O campo deve ser preenchido.")

     tel_cdsubmod AT 35 LABEL "Submodalidade (BACEN)"  FORMAT "X(18)"
         HELP "Informe 'F7' para selecionar a Submodalidade."     
         VALIDATE(tel_cdsubmod <> "","375 - O campo deve ser preenchido.") 

     WITH SIDE-LABEL CENTERED ROW 7 OVERLAY WIDTH 78 FRAME f_lcredi_2.

    
FORM tel_txjurfix   AT  2 LABEL "Taxa Fixa"
                          HELP "Informe a taxa fixa da linha de credito."
     "%"            AT 26
     
     tel_txjurvar   AT 28 LABEL "Taxa Variavel"
                          HELP "Informe a taxa variavel da linha de credito."
     "% da TR/UFIR" AT 50

     SKIP(1)

     tel_txpresta   AT  2 LABEL "Taxa s/ Prest."
                          HELP "Informe a taxa sobre o valor da prestacao."
     "%"            AT 26
     
     tel_txminima   AT 28 LABEL "Taxa Minima  "
                          HELP "Informe a taxa minima contratual."
     "%"            AT 50
     
     tel_txmaxima   AT 55 LABEL "Taxa Maxima"
                          HELP "Informe a taxa maxima contratual."
     "%"            AT 75

     SKIP(1)

     tel_txmensal   AT  2 LABEL "Taxa Mensal"
     "%"            AT 26
     
     tel_txdiaria   AT 28 LABEL "Taxa Diaria  "
     "%"            AT 55
     tel_txbaspre   AT 57 LABEL "Taxa Base"
                          HELP "Informe a taxa base para calculo das prestacoes"
     "%"            AT 75

     SKIP(1)
     tel_nrgrplcr   AT  2 LABEL "Grupo"
                          HELP "Informe o numero do grupo da linha de credito."
    
     tel_qtcarenc   AT 28 LABEL "Dias Carencia"
                       HELP "Informe dias Carencia"
     tel_perjurmo         LABEL "% Juros de Mora"
                       HELP "Informe % juros de mora."

     SKIP(1)

     tel_vlmaxass   AT  2  LABEL "Valor Maximo Associado"
                       HELP "Informe o valor maximo associado" 
     tel_consaut    AT 43 LABEL "Efetua Consulta Automatizada"
                       HELP "Informe uma opcao para a consulta"
     SKIP(1)
     tel_vlmaxasj   AT  2  LABEL "Val.Max. Pes. Juridica"
                       HELP "Informe o valor maximo pessoa juridica" 
     tel_nrinipre   AT  43 LABEL "Prestacao"
                          HELP "Informe o numero minimo de prestacoes (1)."
                          VALIDATE(tel_nrinipre > 0,"380 - Numero errado.")
     "a"            
     tel_nrfimpre     NO-LABEL  
                    HELP "Informe o numero maximo de prestacoes da linha."
                          VALIDATE(tel_nrfimpre > 0 AND tel_nrfimpre <= 240,
                                   "380 - Numero errado.")

     tel_qtdcasas    LABEL "Decimais"
                       HELP "Infome o numero de casas decimais do coeficiente."
                       VALIDATE(tel_qtdcasas > 0 AND tel_qtdcasas < 7,
                                "380 - Numero errado.") 
     SKIP(1)
     tel_qtrecpro   AT  2  LABEL "Reciprocidade da linha"
                       HELP "Informe a Reciprocidade da linha"
     WITH SIDE-LABEL CENTERED ROW 7 OVERLAY WIDTH 78 FRAME f_lcredi_3.


FORM tel_flgdisap   AT  2 LABEL "Dispensar Aprovacao"
                          HELP "Informe dispensa aprovacao pelo comite."
     tel_flgcobmu   AT 30 LABEL "Cobrar Multa"
                          HELP "Informe cobra multa."
     tel_flgsegpr   AT 51 LABEL "Seguro Prestamista"
                          HELP "Informe seguro prestamista."
     SKIP(1)
     tel_cdhistor   AT  2 LABEL "Codigo do historico de contrato para lancamento contabil"
                          HELP "Informe o codigo do historico."
     SKIP(10)
     WITH SIDE-LABEL CENTERED ROW 7 OVERLAY WIDTH 78 FRAME f_lcredi_4.


FORM "Finalidades:"    AT 01
     SKIP(1)
     tel_cdfinemp[001] AT 01 NO-LABEL
     tel_cdfinemp[002] AT 05 NO-LABEL
     tel_cdfinemp[003] AT 09 NO-LABEL
     tel_cdfinemp[004] AT 13 NO-LABEL
     tel_cdfinemp[005] AT 17 NO-LABEL
     tel_cdfinemp[006] AT 21 NO-LABEL
     tel_cdfinemp[007] AT 25 NO-LABEL
     tel_cdfinemp[008] AT 29 NO-LABEL
     tel_cdfinemp[009] AT 33 NO-LABEL
     SKIP
     tel_cdfinemp[010] AT 01 NO-LABEL
     tel_cdfinemp[011] AT 05 NO-LABEL
     tel_cdfinemp[012] AT 09 NO-LABEL
     tel_cdfinemp[013] AT 13 NO-LABEL
     tel_cdfinemp[014] AT 17 NO-LABEL
     tel_cdfinemp[015] AT 21 NO-LABEL
     tel_cdfinemp[016] AT 25 NO-LABEL
     tel_cdfinemp[017] AT 29 NO-LABEL
     tel_cdfinemp[018] AT 33 NO-LABEL
     SKIP
     tel_cdfinemp[019] AT 01 NO-LABEL
     tel_cdfinemp[020] AT 05 NO-LABEL
     tel_cdfinemp[021] AT 09 NO-LABEL
     tel_cdfinemp[022] AT 13 NO-LABEL
     tel_cdfinemp[023] AT 17 NO-LABEL
     tel_cdfinemp[024] AT 21 NO-LABEL
     tel_cdfinemp[025] AT 25 NO-LABEL
     tel_cdfinemp[026] AT 29 NO-LABEL
     tel_cdfinemp[027] AT 33 NO-LABEL
     SKIP
     tel_cdfinemp[028] AT 01 NO-LABEL
     tel_cdfinemp[029] AT 05 NO-LABEL
     tel_cdfinemp[030] AT 09 NO-LABEL
     tel_cdfinemp[031] AT 13 NO-LABEL
     tel_cdfinemp[032] AT 17 NO-LABEL
     tel_cdfinemp[033] AT 21 NO-LABEL
     tel_cdfinemp[034] AT 25 NO-LABEL
     tel_cdfinemp[035] AT 29 NO-LABEL
     tel_cdfinemp[036] AT 33 NO-LABEL
     SKIP
     tel_cdfinemp[037] AT 01 NO-LABEL
     tel_cdfinemp[038] AT 05 NO-LABEL
     tel_cdfinemp[039] AT 09 NO-LABEL
     tel_cdfinemp[040] AT 13 NO-LABEL
     tel_cdfinemp[041] AT 17 NO-LABEL
     tel_cdfinemp[042] AT 21 NO-LABEL
     tel_cdfinemp[043] AT 25 NO-LABEL
     tel_cdfinemp[044] AT 29 NO-LABEL
     tel_cdfinemp[045] AT 33 NO-LABEL
     SKIP
     tel_cdfinemp[046] AT 01 NO-LABEL
     tel_cdfinemp[047] AT 05 NO-LABEL
     tel_cdfinemp[048] AT 09 NO-LABEL
     tel_cdfinemp[049] AT 13 NO-LABEL
     tel_cdfinemp[050] AT 17 NO-LABEL
     tel_cdfinemp[051] AT 21 NO-LABEL
     tel_cdfinemp[052] AT 25 NO-LABEL
     tel_cdfinemp[053] AT 29 NO-LABEL
     tel_cdfinemp[054] AT 33 NO-LABEL
     SKIP
     tel_cdfinemp[055] AT 01 NO-LABEL
     tel_cdfinemp[056] AT 05 NO-LABEL
     tel_cdfinemp[057] AT 09 NO-LABEL
     tel_cdfinemp[058] AT 13 NO-LABEL
     tel_cdfinemp[059] AT 17 NO-LABEL
     tel_cdfinemp[060] AT 21 NO-LABEL
     tel_cdfinemp[061] AT 25 NO-LABEL
     tel_cdfinemp[062] AT 29 NO-LABEL
     tel_cdfinemp[063] AT 33 NO-LABEL
     SKIP
     tel_cdfinemp[064] AT 01 NO-LABEL
     tel_cdfinemp[065] AT 05 NO-LABEL
     tel_cdfinemp[066] AT 09 NO-LABEL
     tel_cdfinemp[067] AT 13 NO-LABEL
     tel_cdfinemp[068] AT 17 NO-LABEL
     tel_cdfinemp[069] AT 21 NO-LABEL
     tel_cdfinemp[070] AT 25 NO-LABEL
     tel_cdfinemp[071] AT 29 NO-LABEL
     tel_cdfinemp[072] AT 33 NO-LABEL
     SKIP
     tel_cdfinemp[073] AT 01 NO-LABEL
     tel_cdfinemp[074] AT 05 NO-LABEL
     tel_cdfinemp[075] AT 09 NO-LABEL
     tel_cdfinemp[076] AT 13 NO-LABEL
     tel_cdfinemp[077] AT 17 NO-LABEL
     tel_cdfinemp[078] AT 21 NO-LABEL
     tel_cdfinemp[079] AT 25 NO-LABEL
     tel_cdfinemp[080] AT 29 NO-LABEL
     tel_cdfinemp[081] AT 33 NO-LABEL
     WITH ROW 7 CENTERED SIDE-LABELS OVERLAY WIDTH 37 FRAME f_finali.

FORM tel_dsindice AT 2
     LABEL "Prazo   Indice   Prazo   Indice   Prazo   Indice   Prazo   Indice"
     WITH ROW 8 CENTERED OVERLAY 8 DOWN WIDTH 70 FRAME f_presta.

FORM tel_dsfinali AT 2
     LABEL "Finalidade                        Finalidade"
     WITH ROW 8 CENTERED OVERLAY 8 DOWN WIDTH 70 FRAME f_finalidade.

DEF TEMP-TABLE w-dsoperac NO-UNDO
               FIELD dsoperac AS CHAR FORMAT "x(35)".

DEF TEMP-TABLE tt-origem
    FIELD origem AS CHAR FORMAT "x(35)".

DEF TEMP-TABLE tt-modali
    FIELD cdmodali AS CHAR FORMAT "X(27)".

DEF TEMP-TABLE tt-submodali
    FIELD cdsubmod AS CHAR FORMAT "X(50)".

DEF QUERY origem-q FOR tt-origem.

DEF BROWSE brorigem QUERY origem-q
    DISPLAY origem COLUMN-LABEL "Origem Recurso" 
     WITH 6 DOWN OVERLAY.

DEF QUERY dsoperac-q FOR w-dsoperac.
                    
DEF BROWSE dsoperac-b QUERY dsoperac-q
    DISPLAY  dsoperac COLUMN-LABEL "Descricao da Operacao" 
             WITH 6 DOWN OVERLAY.          
           
DEF QUERY modali-q FOR tt-modali.

DEF BROWSE modali-b QUERY modali-q
    DISPLAY cdmodali COLUMN-LABEL "Descricao da Modalidade"
            WITH 3 DOWN.

DEF QUERY submodali-q FOR tt-submodali.

DEF BROWSE submodali-b QUERY submodali-q
    DISPLAY cdsubmod COLUMN-LABEL "Descricao da Submodalidade"
            WITH 9 DOWN.

DEF FRAME   f_dsoperac
            dsoperac-b HELP "Use as SETAS para navegar e <F4> para sair"  SKIP
            WITH NO-BOX CENTERED OVERLAY ROW 10.

DEF FRAME f_origem
    brorigem HELP "Use as SETAS para navegar e <F4> para sair"  SKIP
             WITH NO-BOX CENTERED OVERLAY ROW 10 WIDTH 2.
                     

DEF FRAME f_modali
           modali-b HELP "Use as SETAS para navegar e <F4> para sair"  SKIP
            WITH NO-BOX CENTERED OVERLAY ROW 11.

DEF FRAME f_submodali
           submodali-b HELP "Use as SETAS para navegar e <F4> para sair"  SKIP
            WITH NO-BOX CENTERED OVERLAY ROW 8.

ON RETURN OF dsoperac-b  DO: 
    
    ASSIGN  tel_dsoperac = w-dsoperac.dsoperac.
    DISPLAY tel_dsoperac WITH FRAME f_lcredi_2.
    HIDE FRAME f_dsoperac.
    APPLY "GO".

END.

ON RETURN OF brorigem DO:

    ASSIGN tel_origrecu = tt-origem.origem.
    DISPLAY tel_origrecu WITH FRAME f_lcredi_2.
    HIDE FRAME f_origem.
    APPLY "GO".

END.

ON RETURN OF modali-b IN FRAME f_modali DO:
    
    ASSIGN tel_cdmodali = tt-modali.cdmodali.
    DISPLAY tel_cdmodali WITH FRAME f_lcredi_2.
    HIDE FRAME f_modali.     
    APPLY "GO".

END.

ON RETURN OF submodali-b IN FRAME f_submodali DO:
    
    IF   NOT AVAIL tt-submodali   THEN
         RETURN.

    ASSIGN tel_cdsubmod = tt-submodali.cdsubmod.
    DISPLAY tel_cdsubmod WITH FRAME f_lcredi_2.
    HIDE FRAME f_submodali.     
    APPLY "GO".

END.

/* Na entrada do Frame */
ON ENTRY OF FRAME f_lcredi_2 DO: 
    
    IF   INPUT tel_cdusolcr = 0  THEN
         DO:
             DISABLE tel_origrecu 
                     tel_flgimpde WITH FRAME f_lcredi_2.

             ENABLE tel_dsoperac 
                    tel_tplcremp WHEN glb_cddopcao = "I" OR glb_cddopcao = "A"
                    tel_tpdescto 
                    tel_tpctrato WHEN glb_cddopcao = "I"
                    tel_nrdevias
                    tel_flgrefin tel_flgreneg
                    tel_cdusolcr tel_flgtarif
                    tel_flgtaiof tel_vltrfesp tel_flgcrcta 
                    tel_manterpo tel_flglispr 
                    tel_cdmodali tel_cdsubmod
                    WITH FRAME f_lcredi_2.   
         END.
    ELSE
    IF   INPUT tel_cdusolcr = 1 THEN 
         DO:
             ENABLE tel_dsoperac 
                    tel_tplcremp WHEN glb_cddopcao = "I" OR glb_cddopcao = "A"
                    tel_tpdescto 
                    tel_tpctrato WHEN glb_cddopcao = "I"
                    tel_nrdevias 
                    tel_flgrefin tel_flgreneg
                    tel_cdusolcr tel_flgtarif
                    tel_flgtaiof tel_vltrfesp tel_flgcrcta 
                    tel_manterpo tel_flgimpde 
                    tel_origrecu tel_flglispr 
                    tel_cdmodali tel_cdsubmod
                    WITH FRAME f_lcredi_2.   
         END.
    ELSE
         DO:
             DISABLE tel_origrecu WITH FRAME f_lcredi_2.

             ENABLE tel_dsoperac
                    tel_tplcremp WHEN glb_cddopcao = "I" OR glb_cddopcao = "A"
                    tel_tpdescto 
                    tel_tpctrato WHEN glb_cddopcao = "I"
                    tel_nrdevias 
                    tel_flgrefin tel_flgreneg
                    tel_cdusolcr tel_flgtarif 
                    tel_flgtaiof tel_vltrfesp tel_flgcrcta 
                    tel_manterpo tel_flgimpde 
                    tel_flglispr 
                    tel_cdmodali tel_cdsubmod
                    WITH FRAME f_lcredi_2.
         END.   

    RETURN NO-APPLY.

END.

ON LEAVE OF tel_cdusolcr DO:

    IF   INPUT tel_cdusolcr = 0 THEN 
         DO:
             ASSIGN tel_origrecu = ""
                    tel_flgimpde = NO.
                   
             DISABLE tel_origrecu  
                     tel_flgimpde WITH FRAME f_lcredi_2. 

             DISPLAY tel_origrecu 
                     tel_flgimpde WITH FRAME f_lcredi_2.
         END. 
    ELSE
    IF   INPUT tel_cdusolcr = 1 THEN
         DO:
             ENABLE tel_dsoperac 
                    tel_tplcremp WHEN glb_cddopcao = "I" OR glb_cddopcao = "A"
                    tel_tpdescto
                    tel_tpctrato WHEN glb_cddopcao = "I"
                    tel_nrdevias 
                    tel_flgrefin tel_flgreneg
                    tel_cdusolcr tel_flgtarif
                    tel_flgtaiof tel_vltrfesp tel_flgcrcta 
                    tel_manterpo tel_flgimpde 
                    tel_origrecu tel_flglispr 
                    tel_cdmodali tel_cdsubmod 
                    WITH FRAME f_lcredi_2.

             NEXT-PROMPT tel_flgtarif WITH FRAME f_lcredi_2.
           
             RETURN NO-APPLY.
         END.
    ELSE
         DO:
             ASSIGN tel_origrecu = "".
                        
             DISABLE tel_origrecu WITH FRAME f_lcredi_2. 
         
             DISPLAY tel_origrecu WITH FRAME f_lcredi_2.
        
             ENABLE tel_dsoperac
                    tel_tplcremp WHEN glb_cddopcao = "I" OR glb_cddopcao = "A"
                    tel_tpdescto 
                    tel_tpctrato WHEN glb_cddopcao = "I"
                    tel_nrdevias 
                    tel_flgrefin tel_flgreneg
                    tel_cdusolcr tel_flgtarif 
                    tel_flgtaiof tel_vltrfesp tel_flgcrcta 
                    tel_manterpo tel_flgimpde 
                    tel_flglispr 
                    tel_cdmodali tel_cdsubmod 
                    WITH FRAME f_lcredi_2.

             NEXT-PROMPT tel_flgtarif WITH FRAME f_lcredi_2.

             RETURN NO-APPLY.
         END.      
END.


/* .......................................................................... */




