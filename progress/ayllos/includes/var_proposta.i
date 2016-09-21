/* ............................................................................

   Programa: includes/var_proposta.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Setembro/2010                      Ultima atualizacao: 28/11/2014
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Declarar as variaveis e form que sao comum as operacoes de 
               credito.

   Alteracoes: 31/08/2011 - Ajuste no indice do tt-aval-crapbem para nao
                            dar erro de duplicacao de dados (Gabriel).
   
               04/11/2011 - Quando for a CENTRAL, os campos abaixo nao serao 
                            obrigatorios:
                            - Garantia
                            - Patrimonio Pessoal Livre
		                    - Percepcao geral
                            (Adriano).            
                            
               24/11/2011 - Ajuste para a inclusao do campo "Justificativa"
                            (Adriano).
               
               13/03/2014 - Aumento do format do campo tt-rendimento.vlmedfat 
                           "Faturamento Bruto Gerencial" (Daniele).      
                           
               18/08/2014 - Projeto Automatização de Consultas em Propostas
                            de Crédito (Jonata-RKAM).   
                            
               28/11/2014 - Retirar consultas do 2.do titular (Jonata-RKAM).                                                                                                                                                                                                                                  
............................................................................ */
    
{ sistema/generico/includes/b1wgen0024tt.i }                 
{ sistema/generico/includes/b1wgen0043tt.i }  

/* Varaiveis auxiliares */
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR                                           NO-UNDO.
DEF VAR aux_flggener AS LOGI                                           NO-UNDO.
DEF VAR aux_indirend AS INTE                                           NO-UNDO.
DEF VAR aux_vlmedfat AS DECI                                           NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_titelavl AS CHAR FORMAT "x(61)"                            NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_regexist AS LOGI                                           NO-UNDO.
DEF VAR aux_qtlintel AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_dsjusren AS CHAR EXTENT 3 FORMAT "x(60)"                   NO-UNDO.

DEF VAR par_dsdfinan AS CHAR                                           NO-UNDO.
DEF VAR par_dsdrendi AS CHAR                                           NO-UNDO.
DEF VAR par_dsdebens AS CHAR                                           NO-UNDO.
DEF VAR par_dsdbeavt AS CHAR                                           NO-UNDO.
DEF VAR par_nmdcampo AS CHAR                                           NO-UNDO.

DEF VAR log_tpatlcad AS INTE                                           NO-UNDO.
DEF VAR log_msgatcad AS CHAR                                           NO-UNDO.
DEF VAR log_chavealt AS CHAR                                           NO-UNDO.
                                                                      
/* Handle para BO´s */
DEF VAR h-b1wgen0002 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0043 AS HANDLE                                         NO-UNDO.

DEF VAR tel_nrpatlvr AS CHAR                                           NO-UNDO.

DEF VAR aux_flgtpren AS LOG                                            NO-UNDO.
DEF VAR aux_renoutro AS INT                                            NO-UNDO.

DEF TEMP-TABLE tt-tipo-rendi                                           NO-UNDO
    FIELD tpdrendi   AS INTE
    FIELD dsdrendi   AS CHAR.

DEF TEMP-TABLE bb-dados-avais                                          NO-UNDO
    LIKE tt-dados-avais.

DEF TEMP-TABLE tt-aval-crapbem                                         NO-UNDO
    LIKE tt-crapbem 
    USE-INDEX crapbem2 USE-INDEX tt-crapbem AS PRIMARY.


DEF QUERY  q-craprad FOR tt-itens-topico-rating SCROLLING.

DEF BROWSE b-craprad QUERY q-craprad  
        DISPLAY nrseqite COLUMN-LABEL "Seq.Item"
                dsseqite COLUMN-LABEL "Descricao Seq.Item" FORMAT "x(55)"
                WITH CENTERED 5 DOWN TITLE " Itens do rating ".




FORM b-craprad 
     WITH CENTERED NO-BOX OVERLAY ROW 10 COLUMN 3 WIDTH 70 FRAME f_craprad.

FORM SKIP(1)  
     "Salario:"                AT 02
     tt-rendimento.vlsalari    AT 11 FORMAT "zzz,zz9.99" 
        HELP 
        "Entre com o salario do associado."

    "Demais Tit./Outros:"      AT 34
    tt-rendimento.vloutras     AT 54 FORMAT "z,zzz,zz9.99"
        HELP "Entre com o valor dos salarios dos demais titulares."

    SKIP(1)
     "Outras Rendas - Origem:" AT 02

     tt-rendimento.tpdrendi[1] AT 26 FORMAT "z9"
        HELP "Entre com o codigo do rendimento ou pressione <F7> para listar."

     tt-rendimento.dsdrendi[1] AT 30 FORMAT "x(20)"
        HELP "Entre com a descricao do rendimento."
                                
     tt-rendimento.vldrendi[1] AT 52 FORMAT "zzz,zzz,zz9.99"
        HELP "Entre com o valor de outras rendas."                         
        VALIDATE((INPUT tt-rendimento.tpdrendi[1] = 0  AND  
                  INPUT tt-rendimento.vldrendi[1] = 0) OR 
                 
                 (INPUT tt-rendimento.tpdrendi[1] <> 0    AND  
                  INPUT tt-rendimento.vldrendi[1] <> 0), 
                 "375 - O campo deve ser preenchido.")            
     SKIP
  
     tt-rendimento.tpdrendi[2] AT 26 FORMAT "z9"
        HELP "Entre com o codigo do rendimento ou pressione <F7> para listar."
     
     tt-rendimento.dsdrendi[2] AT 30 FORMAT "x(20)"
        HELP "Entre com a descricao do rendimento."
                                
     tt-rendimento.vldrendi[2] AT 52 FORMAT "zzz,zzz,zz9.99"
        HELP "Entre com o valor de outras rendas."    
        VALIDATE((INPUT tt-rendimento.tpdrendi[2] = 0  AND  
                  INPUT tt-rendimento.vldrendi[2] = 0) OR

                 (INPUT tt-rendimento.tpdrendi[2] <> 0 AND 
                  INPUT tt-rendimento.vldrendi[2] <> 0),
                 "375 - O campo deve ser preenchido.")                
     SKIP
     tt-rendimento.tpdrendi[3] AT 26 FORMAT "z9"
        HELP "Entre com o codigo do rendimento ou pressione <F7> para listar."
     
     tt-rendimento.dsdrendi[3] AT 30 FORMAT "x(20)"
        HELP "Entre com a descricao do rendimento."
                               
     tt-rendimento.vldrendi[3] AT 52 FORMAT "zzz,zzz,zz9.99"
        HELP "Entre com o valor de outras rendas."
        VALIDATE((INPUT tt-rendimento.tpdrendi[3] = 0  AND
                  INPUT tt-rendimento.vldrendi[3] = 0) OR 

                 (INPUT tt-rendimento.tpdrendi[3] <> 0 AND  
                  INPUT tt-rendimento.vldrendi[3] <> 0),
                 "375 - O campo deve ser preenchido.")
                 
     SKIP
     tt-rendimento.tpdrendi[4] AT 26 FORMAT "z9"
        HELP "Entre com o codigo do rendimento ou pressione <F7> para listar."
 
     tt-rendimento.dsdrendi[4] AT 30 FORMAT "x(20)"
        HELP "Entre com a descricao do rendimento."
                                
     tt-rendimento.vldrendi[4] AT 52 FORMAT "zzz,zzz,zz9.99"
        HELP "Entre com o valor de outras rendas."
        VALIDATE((INPUT tt-rendimento.tpdrendi[4] = 0  AND
                  INPUT tt-rendimento.vldrendi[4] = 0) OR 

                 (INPUT tt-rendimento.tpdrendi[4] <> 0 AND
                  INPUT tt-rendimento.vldrendi[4] <> 0),
                 "375 - O campo deve ser preenchido.")
     SKIP
     tt-rendimento.tpdrendi[5] AT 26 FORMAT "z9"
        HELP "Entre com o codigo do rendimento ou pressione <F7> para listar."
 
     tt-rendimento.dsdrendi[5] AT 30 FORMAT "x(20)"
        HELP "Entre com a descricao do rendimento."
                                
     tt-rendimento.vldrendi[5] AT 52 FORMAT "zzz,zzz,zz9.99"
        HELP "Entre com o valor de outras rendas."
        VALIDATE((INPUT tt-rendimento.tpdrendi[5] = 0  AND
                  INPUT tt-rendimento.vldrendi[5] = 0) OR 

                 (INPUT tt-rendimento.tpdrendi[5] <> 0 AND
                  INPUT tt-rendimento.vldrendi[5] <> 0),
                 "375 - O campo deve ser preenchido.")

     tt-rendimento.tpdrendi[6] AT 26 FORMAT "z9"
        HELP "Entre com o codigo do rendimento ou pressione <F7> para listar."
 
     tt-rendimento.dsdrendi[6] AT 30 FORMAT "x(20)"
        HELP "Entre com a descricao do rendimento."
                                
     tt-rendimento.vldrendi[6] AT 52 FORMAT "zzz,zzz,zz9.99"
        HELP "Entre com o valor de outras rendas."
        VALIDATE((INPUT tt-rendimento.tpdrendi[6] = 0  AND
                  INPUT tt-rendimento.vldrendi[6] = 0) OR 

                 (INPUT tt-rendimento.tpdrendi[6] <> 0 AND
                  INPUT tt-rendimento.vldrendi[6] <> 0),
                 "375 - O campo deve ser preenchido.")   
     SKIP
     "Justificativa:"       AT 02
     aux_dsjusren[1]        
     SKIP
     aux_dsjusren[2]        AT 17
     SKIP
     aux_dsjusren[3]        AT 17
     SKIP
     "Conjuge - Salario:"   AT 02
     tt-rendimento.vlsalcon AT 21 FORMAT "zzz,zzz,zz9.99"
        HELP "Entre com o valor do salario do conjuge."
     
     "Local de Trabalho:"   AT 37
     tt-rendimento.nmextemp AT 56 FORMAT "x(20)"
        HELP "Entre com o local de trabalho do conjuge."
     
    SKIP
     "Co-Responsavel:"      AT 05
     tt-rendimento.flgdocje AT 21
        HELP "S p/ conjuge co-responsavel e N p/ conjuge nao co-responsavel."
   
     "Aluguel (Despesas):"  AT 36
     tt-rendimento.vlalugue AT 56 FORMAT "zzz,zz9.99"
        HELP "Entre com o valor do aluguel."
     SKIP
     "Consultar Conjuge:"   AT 02
     tt-rendimento.inconcje AT 21 FORMAT "Sim/Nao"
        HELP "Informe se deseja consultar o conjuge."

     WITH ROW 5 CENTERED NO-LABELS OVERLAY WIDTH 78

          TITLE COLOR NORMAL " Dados para a Proposta " FRAME f_tel_fis.

FORM SKIP(1)
      "Faturamento bruto gerencial mensal:"       AT 08
     tt-rendimento.vlmedfat AT 44 FORMAT "-z,zzz,zzz,zzz,zzz,zz9.99"  
        HELP "Pressione <ENTER> para editar o faturamento."
        
     "(media)"
     SKIP(2)
     
     "Concentracao faturamento unico cliente %:" AT 02
     tt-rendimento.perfatcl AT 51 FORMAT "zz9.99"
        HELP "Entre com a concentracao do faturamento unico cliente."
        VALIDATE(tt-rendimento.perfatcl >  0 AND tt-rendimento.perfatcl <= 100,
                 "269 - Valor errado.")
    
     SKIP(2)
     
    "Aluguel (Despesas):"              AT 24
     tt-rendimento.vlalugue AT 47 FORMAT "zzz,zz9.99"
        HELP "Entre com o valor do aluguel."

     SKIP(5)

     WITH ROW 5 CENTERED NO-LABELS OVERLAY WIDTH 78
        
          TITLE COLOR NORMAL " Dados para a Proposta " FRAME f_tel_jur.


FORM SKIP(1)
     " ----------------------- Central de Risco - Bacen -------------------------"
     SKIP(1) 
     tt-dados-analise.dtdrisco AT 03 LABEL "Consulta 1o Tit"
        HELP "Informe a data da consulta na central de risco."
                                                             FORMAT "99/99/9999"
        VALIDATE(tt-dados-analise.dtdrisco <= glb_dtmvtolt OR
                 tt-dados-analise.dtdrisco = ?,
                 "013 - Data errada.")

     tt-dados-analise.qtopescr AT 32 LABEL "Qtd Operacoes"   FORMAT "zzz,zz9"
        HELP "Informe a quantidade de operacoes."
     
     tt-dados-analise.qtifoper AT 56 LABEL "Qtd. IF com ope." 
                                                             FORMAT "z9"  
        HELP "Informe a quantidade de IF em que possui operacoes."
     
     SKIP
     
     tt-dados-analise.vltotsfn AT 03 LABEL "Endividamento" FORMAT "zz,zzz,zz9.99"
        HELP "Valor total do Sistema Financeiro Nacional com a Cooperativa."
     
     tt-dados-analise.vlopescr AT 32 LABEL "Vencidas"     FORMAT "z,zzz,zz9.99"
        HELP "Informe o valor das operacoes vencidas."
     
     tt-dados-analise.vlrpreju AT 56 LABEL "Prej."     FORMAT "z,zzz,zz9.99"        
        HELP "Informe o valor do prejuizo."

     SKIP

     tt-dados-analise.dtoutris AT 03 LABEL "Consulta Conjuge"  
                                                          FORMAT "99/99/9999"
         HELP "Informe a data da consulta na central de risco do Conjuge."
         VALIDATE(tt-dados-analise.dtoutris <= glb_dtmvtolt OR
                  tt-dados-analise.dtoutris  = ?,
                  "013 - Data errada.")

     tt-dados-analise.vlsfnout AT 47 LABEL "Endiv. Conjuge"
                                                          FORMAT "z,zzz,zz9.99" 
        HELP "Informe o valor do endividamento do Conjuge."

     SKIP(1)
     " ------------------------------- Garantias --------------------------------"
     SKIP(1)

     tt-dados-analise.nrgarope AT 03 LABEL "Garantia"     FORMAT "zz9"
        HELP "Entre com a garantia ou pressione ou <F7> p/ listar."
        VALIDATE((IF glb_cdcooper <> 3 THEN 
                     tt-dados-analise.nrgarope <> 0
                  ELSE 
                     tt-dados-analise.nrgarope = 0),
                  (IF glb_cdcooper <> 3 THEN
                      "375 - O campo deve ser preenchido."
                   ELSE
                      "375 - O campo deve ser zerado."))
                 
     tt-dados-analise.dsgarope AT 17 NO-LABEL             FORMAT "x(22)"

     tt-dados-analise.nrliquid AT 41 LABEL "Liquidez"     FORMAT "zz9"
        HELP "Informe a liquidez das garantias ou <F7> para listar."
        VALIDATE (tt-dados-analise.nrliquid <> 0,
                  "375 - O campo deve ser preenchido.")
       
     tt-dados-analise.dsliquid AT 55 NO-LABEL             FORMAT "x(21)"  
     SKIP
     tel_nrpatlvr              AT 03 NO-LABEL             FORMAT "x(28)"

     tt-dados-analise.nrpatlvr AT 32 NO-LABEL             FORMAT "zz9"
        HELP "Informe o codigo do patrimonio ou <F7> p/ listar."
        VALIDATE((IF glb_cdcooper <> 3 THEN 
                     tt-dados-analise.nrpatlvr <> 0
                  ELSE 
                     tt-dados-analise.nrpatlvr = 0),
                 (IF glb_cdcooper <> 3 THEN
                     "375 - O campo deve ser preenchido."
                  ELSE 
                     "375 - O campo deve ser zerado."))
     
     tt-dados-analise.dspatlvr AT 36 NO-LABEL             FORMAT "x(40)"

     SKIP
     tt-dados-analise.nrperger AT 03 
        LABEL "Percepcao geral com relacao a empresa"     FORMAT "zz9"
        HELP "Informe o codigo da informacao ou <F7> para listar."
        VALIDATE((IF glb_cdcooper <> 3 THEN 
                     tt-dados-analise.nrperger <> 0
                  ELSE 
                     tt-dados-analise.nrperger = 0),
                  (IF glb_cdcooper <> 3 THEN
                      "375 - O campo deve ser preenchido."
                   ELSE
                      "375 - O campo deve ser zerado."))
       
     tt-dados-analise.dsperger AT 46 NO-LABEL             FORMAT "x(30)"   
     SKIP(2)
     WITH OVERLAY CENTERED SIDE-LABELS ROW 5 WIDTH 78 TITLE 
     
          COLOR NORMAL " Analise da Proposta " FRAME f_analise_proposta.
     

ON RETURN OF b-craprad IN FRAME f_craprad DO:

    APPLY "GO".

END.

/* ..........................................................................*/

