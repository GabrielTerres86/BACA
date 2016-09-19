/* .............................................................................

   Programa: Includes/var_dsctit.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Agosto/2008.                       Ultima atualizacao: 07/07/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criar as variaveis e form da rotina de Desconto de titulos da 
               tela ATENDA.

   Alteracoes: 10/12/2009 - Variaveis/forms para gerao do rating (Gabriel).
                          - Substituido no rating as referencias de vlopescr 
                            por vltotsfn (Elton).
                            
               28/04/2011 - Incluidas variaveis para CEP integrado. Divisao
                            do form f_promissoria. (André - DB1)
                            
               03/11/2011 - Quando for a CENTRAL, os campos abaixo nao serao 
                            obrigatorios:
                            - Garantia
                            - Patrimonio Pessoal Livre
		                    - Percepcao geral
                            (Adriano).  
                            
               09/07/2012 - Adicionado browse 'b_linhas_desc' para escolha 
                            de Linha de Desconto de Título (Lucas).
                            
               16/10/2012 - Correçao descritivo Help campo documento
                            conjuge (Daniel).
                            
               06/11/2012 - Incluido frame f_ge_desc, f_ge_desc2 referente 
                            ao projeto GE (Adriano). 
                            
               02/05/2013 - Ajuste no layout dos frames f_grupo_economico,
                            f_grupo_economico2 ( Adriano ).   
                            
               23/06/2014 - Inclusao da include b1wgen0138tt para uso da
                            temp-table tt-grupo ao invés da tt-ge-ocorrencias.
                            (Chamado 130880) - (Tiago Castro - RKAM)
                            
............................................................................ */

{ sistema/generico/includes/b1wgen0138tt.i }
DEF VAR opc_dsimprim AS CHAR INIT "Imprimir"                         NO-UNDO.
DEF VAR opc_dsvisual AS CHAR INIT "Visualizar Titulos"               NO-UNDO.

DEF BUTTON btn_btaosair LABEL "Sair".
DEF VAR aux_confirma AS CHAR FORMAT "!"                              NO-UNDO.
DEF VAR tel_dsvisual AS CHAR VIEW-AS EDITOR SIZE 80 BY 15 PFCOLOR 0  NO-UNDO.
DEF VAR tel_dsobserv AS CHAR  VIEW-AS EDITOR SIZE 76 BY 4 
                              BUFFER-LINES 13  PFCOLOR 0             NO-UNDO.

DEF {1} SHARED VAR lim_nrgarope AS INTE  FORMAT "z9"                 NO-UNDO.
DEF {1} SHARED VAR lim_nrinfcad AS INTE  FORMAT "z9"                 NO-UNDO.
DEF {1} SHARED VAR lim_nrliquid AS INTE  FORMAT "z9"                 NO-UNDO.
DEF {1} SHARED VAR lim_nrpatlvr AS INTE  FORMAT "z9"                 NO-UNDO.
DEF {1} SHARED VAR lim_nrperger AS INTE  FORMAT "z9"                 NO-UNDO.
DEF {1} SHARED VAR lim_perfatcl AS DECI  FORMAT "zz9.99"             NO-UNDO.
DEF {1} SHARED VAR lim_vltotsfn AS DECI  FORMAT "z,zzz,zz9.99"       NO-UNDO.

DEF {1} SHARED VAR lim_nrctaav1 AS INT                               NO-UNDO.
DEF {1} SHARED VAR lim_nmdaval1 AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR lim_dscpfav1 AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR lim_dsendav1 AS CHAR           EXTENT 2           NO-UNDO.
DEF {1} SHARED VAR lim_nrctaav2 AS INT                               NO-UNDO.
DEF {1} SHARED VAR lim_dtcancel AS DATE  FORMAT 99/99/9999           NO-UNDO.
                                                                     
DEF {1} SHARED VAR lim_nmdaval2 AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR lim_dscpfav2 AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR lim_dsendav2 AS CHAR           EXTENT 2           NO-UNDO.
DEF {1} SHARED VAR lim_nmdcjav1 AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR lim_dscfcav1 AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR lim_nmdcjav2 AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR lim_dscfcav2 AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR lim_nmcidade1 AS CHAR FORMAT "x(25)"              NO-UNDO.
DEF {1} SHARED VAR lim_cdufresd1 AS CHAR FORMAT "!(2)"               NO-UNDO.
DEF {1} SHARED VAR lim_nrcepend1 AS INTE FORMAT "99999,999"          NO-UNDO.
DEF {1} SHARED VAR lim_nmcidade2 AS CHAR FORMAT "x(25)"              NO-UNDO.
DEF {1} SHARED VAR lim_cdufresd2 AS CHAR FORMAT "!(2)"               NO-UNDO.
DEF {1} SHARED VAR lim_nrcepend2 AS INTE FORMAT "99999,999"          NO-UNDO.
DEF {1} SHARED VAR lim_cpfcgc1  AS DEC FORMAT "zzzzzzzzzzzzz9"       NO-UNDO.
DEF {1} SHARED VAR lim_cpfccg1  AS DEC FORMAT "zzzzzzzzzzzzz9"       NO-UNDO.
DEF {1} SHARED VAR lim_cpfcgc2  AS DEC FORMAT "zzzzzzzzzzzzz9"       NO-UNDO.
DEF {1} SHARED VAR lim_cpfccg2  AS DEC FORMAT "zzzzzzzzzzzzz9"       NO-UNDO.

/* Adicionais CEP integrado */
DEF {1} SHARED VAR lim_nrendere1 AS INTE FORMAT "zzz,zz9"            NO-UNDO.
DEF {1} SHARED VAR lim_complend1 AS CHAR FORMAT "x(40)"              NO-UNDO.
DEF {1} SHARED VAR lim_nrcxapst1 AS INTE FORMAT "zz,zz9"             NO-UNDO.
DEF {1} SHARED VAR lim_nrendere2 AS INTE FORMAT "zzz,zz9"            NO-UNDO.
DEF {1} SHARED VAR lim_complend2 AS CHAR FORMAT "x(40)"              NO-UNDO.
DEF {1} SHARED VAR lim_nrcxapst2 AS INTE FORMAT "zz,zz9"             NO-UNDO.

DEF {1} SHARED VAR lim_tpdocav1 AS CHAR FORMAT "x(2)"                NO-UNDO.
DEF {1} SHARED VAR lim_tpdoccj1 AS CHAR FORMAT "x(2)"                NO-UNDO.
DEF {1} SHARED VAR lim_tpdocav2 AS CHAR FORMAT "x(2)"                NO-UNDO.
DEF {1} SHARED VAR lim_tpdoccj2 AS CHAR FORMAT "x(2)"                NO-UNDO.
DEF {1} SHARED VAR lim_nrfonres1 AS CHAR FORMAT "x(20)"              NO-UNDO.
DEF {1} SHARED VAR lim_nrfonres2 AS CHAR FORMAT "x(20)"              NO-UNDO.
DEF {1} SHARED VAR lim_dsdemail1 AS CHAR FORMAT "x(30)"              NO-UNDO.
DEF {1} SHARED VAR lim_dsdemail2 AS CHAR FORMAT "x(30)"              NO-UNDO.
DEF {1} SHARED VAR aux_qtctarel AS INT FORMAT "zz9"                  NO-UNDO.

DEF QUERY q_linhas_desc FOR tt-linhas_desc.

DEF BROWSE b_linhas_desc QUERY q_linhas_desc
    DISP tt-linhas_desc.cddlinha     COLUMN-LABEL "Cod"
         tt-linhas_desc.dsdlinha     COLUMN-LABEL "Descricao"
         tt-linhas_desc.txmensal     COLUMN-LABEL "Taxa"
         WITH 9 DOWN OVERLAY TITLE "Linhas de Desconto de Titulo".

FORM b_linhas_desc HELP "Use as SETAS para navegar." SKIP
     WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_linhas_desc. 

FORM SKIP(1)         
     "Conta:"         AT  6
     lim_nrctaav1     FORMAT "zzzz,zzz,9"
                 HELP "Entre com o numero da conta do primeiro avalista/fiador"
     SKIP(1)
     "Nome:"          AT  7 
     lim_nmdaval1     FORMAT "x(40)"
                      HELP "Entre com o nome do primeiro avalista/fiador."
     "C.P.F.:"        
     lim_cpfcgc1      FORMAT "zzzzzzzzzzzzz9"
                      HELP "Entre com o CPF do primeiro avalista"
     "Documento:"     AT  2
     lim_tpdocav1     VALIDATE (lim_tpdocav1 = " "  OR
                                lim_tpdocav1 = "CH" OR
                                lim_tpdocav1 = "CP" OR
                                lim_tpdocav1 = "CI" OR              
                                lim_tpdocav1 = "CT" OR
                                lim_tpdocav1 = "TE",
                                "021 - Tipo de documento errado")
                             HELP "Entre com CH, CI, CP, CT, TE"
     lim_dscpfav1     FORMAT "x(40)"
                      HELP "Entre com o Docto do primeiro avalista/fiador."
     SKIP(1)
     "Conjuge:"       AT 4
     lim_nmdcjav1     FORMAT "x(40)"
                      HELP "Entre com o nome do conjuge do primeiro aval." 
     "C.P.F.:"        
     lim_cpfccg1      FORMAT "zzzzzzzzzzzzz9"
                      HELP "Entre com o CPF do conjuge do primeiro aval."
     "Documento:"     AT  2
     lim_tpdoccj1     VALIDATE (lim_tpdoccj1 = " "  OR
                                lim_tpdoccj1 = "CH" OR
                                lim_tpdoccj1 = "CP" OR
                                lim_tpdoccj1 = "CI" OR              
                                lim_tpdoccj1 = "CT" OR
                                lim_tpdoccj1 = "TE",
                                "021 - Tipo de documento errado")
                      HELP "Entre com CH, CI, CP, CT, TE"
     lim_dscfcav1     FORMAT "x(40)"
                      HELP "Entre com o Docto do conjuge do primeiro aval."

     SKIP(1)
     "CEP:"           AT 05
     lim_nrcepend1    HELP "Entre com o CEP ou pressione F7 para pesquisar"
     "Endereco:"      AT  23
     lim_dsendav1[1]  FORMAT "x(40)"
                      HELP "Entre com o endereco."
     SKIP
     "Nro.:"          AT 04
     lim_nrendere1    FORMAT "zzz,zz9"
                      HELP "Entre com o numero do endereco"
     "Complemento:"   AT 23
     lim_complend1    FORMAT "X(40)"
                      HELP  "Informe o complemento do endereco"
     SKIP
     "Bairro:"        AT 02
     lim_dsendav1[2]  FORMAT "x(40)"
                      HELP "Entre com o bairro"
     "Caixa Postal:"  AT 56
     lim_nrcxapst1    FORMAT "zz,zz9"  
                      HELP "Informe o numero da caixa postal"
     SKIP
     "Cidade:"        AT 02
     lim_nmcidade1    FORMAT "x(25)"
                      HELP "Entre com o nome da cidade"
     "UF:"            AT 40
     lim_cdufresd1    HELP "Entre com a UF"
     "Fone:"          AT 50 
     lim_nrfonres1    FORMAT "x(20)"
                      HELP "Entre com o telefone do primeiro avalista"
     "E-mail:"        AT 2
     lim_dsdemail1    FORMAT "x(32)" 
                      HELP "Entre com o email do primeiro avalista/fiador"
     SKIP(1)
            WITH ROW 5 WIDTH 78 CENTERED NO-LABELS OVERLAY TITLE COLOR NORMAL
            " Dados dos Avalistas/Fiadores (1) " FRAME f_dsctit_promissoria1.
    
FORM SKIP(1)        
     "Conta:"         AT  6
     lim_nrctaav2     FORMAT "zzzz,zzz,9"
                 HELP "Entre com o numero da conta do primeiro avalista/fiador"
     SKIP(1)
     "Nome:"          AT  7
     lim_nmdaval2     FORMAT "x(40)"
                      HELP "Entre com o nome do primeiro avalista/fiador."
     "C.P.F.:"        
     lim_cpfcgc2      FORMAT "zzzzzzzzzzzzz9"
                      HELP "Entre com o CPF do primeiro avalista"
     "Documento:"     AT  2
     lim_tpdocav2     VALIDATE (lim_tpdocav1 = " "  OR
                                lim_tpdocav1 = "CH" OR
                                lim_tpdocav1 = "CP" OR
                                lim_tpdocav1 = "CI" OR              
                                lim_tpdocav1 = "CT" OR
                                lim_tpdocav1 = "TE",
                                "021 - Tipo de documento errado")
                      HELP "Entre com CH, CI, CP, CT, TE"
     lim_dscpfav2     FORMAT "x(40)"
                      HELP "Entre com o Docto do primeiro avalista/fiador."
     SKIP(1)
     "Conjuge:"       AT  4 
     lim_nmdcjav2     FORMAT "x(40)"
                      HELP "Entre com o nome do conjuge do primeiro aval." 
     "C.P.F.:"        
     lim_cpfccg2      FORMAT "zzzzzzzzzzzzz9"
                      HELP "Entre com o CPF do conjuge do primeiro aval."
     "Documento:"     AT  2
     lim_tpdoccj2     VALIDATE (lim_tpdoccj1 = " "  OR
                                lim_tpdoccj1 = "CH" OR
                                lim_tpdoccj1 = "CP" OR
                                lim_tpdoccj1 = "CI" OR              
                                lim_tpdoccj1 = "CT" OR
                                lim_tpdoccj1 = "TE",
                                "021 - Tipo de documento errado")
                      HELP "Entre com CH, CI, CP, CT, TE"
     lim_dscfcav2     FORMAT "x(40)"
                      HELP "Entre com o Docto do conjuge do primeiro aval."

     SKIP(1)
     "CEP:"           AT 05
     lim_nrcepend2    HELP "Entre com o CEP ou pressione F7 para pesquisar"
     "Endereco:"      AT  23
     lim_dsendav2[1]  FORMAT "x(40)"
                      HELP "Entre com o endereco."
     SKIP
     "Nro.:"          AT 04
     lim_nrendere2    FORMAT "zzz,zz9"
                      HELP "Entre com o numero do endereco"
     "Complemento:"   AT 23
     lim_complend2    FORMAT "X(40)"
                      HELP  "Informe o complemento do endereco"
     SKIP
     "Bairro:"        AT 02
     lim_dsendav2[2]  FORMAT "x(40)"
                      HELP "Entre com o bairro"
     "Caixa Postal:"  AT 56
     lim_nrcxapst2    FORMAT "zz,zz9"  
                      HELP "Informe o numero da caixa postal"
     SKIP
     "Cidade:"        AT 02
     lim_nmcidade2    FORMAT "x(25)"
                      HELP "Entre com o nome da cidade"
     "UF:"            AT 40
     lim_cdufresd2    HELP "Entre com a UF"
     "Fone:"          AT 50 
     lim_nrfonres2    FORMAT "x(20)"
                      HELP "Entre com o telefone do primeiro avalista"
     "E-mail:"        AT 2
     lim_dsdemail2    FORMAT "x(32)" 
                      HELP "Entre com o email do primeiro avalista/fiador"
     SKIP(1)
            WITH ROW 5 WIDTH 78 CENTERED NO-LABELS OVERLAY TITLE COLOR NORMAL
            " Dados dos Avalistas/Fiadores (2) " FRAME f_dsctit_promissoria2. 


FORM SKIP(1)
     tt-dsctit_dados_limite.nrctrlim
                  AT 18 LABEL "Contrato" FORMAT "z,zzz,zz9"
                        HELP "Entre com o numero do contrato."
     SKIP(1)                   
     tt-dsctit_dados_limite.vllimite
                  AT 11 LABEL "Valor do limite"  FORMAT "zzz,zzz,zz9.99"
                        HELP "Entre com o valor do novo limite."
     tt-dsctit_dados_limite.qtdiavig 
                  AT 51 LABEL "Vigencia" FORMAT "z,zz9" "dias"
     SKIP
     tt-dsctit_dados_limite.cddlinha 
                  AT  9 LABEL "Linha de desconto" FORMAT "zz9"
     tt-dsctit_dados_limite.dsdlinha NO-LABEL FORMAT "x(25)"
     SKIP
     tt-dsctit_dados_limite.txjurmor 
                  AT 13 LABEL "Juros de mora" FORMAT "zz9.9999999" "%"
     tt-dsctit_dados_limite.txdmulta 
                  AT 46 LABEL "Taxa de multa" FORMAT "zz9.9999999" "%"
     SKIP
     tt-dsctit_dados_limite.dsramati 
                  AT  9 LABEL "Ramo de atividade" FORMAT "x(40)"
     SKIP
     tt-dsctit_dados_limite.vlmedtit
                  AT  3 LABEL "Valor medio dos titulos" FORMAT "z,zzz,zz9.99"
     SKIP
     tt-dsctit_dados_limite.vlfatura 
                  AT  8 LABEL "Faturamento mensal" FORMAT "z,zzz,zz9.99" 
     tt-dsctit_dados_limite.dtcancel AT 42 LABEL "Data Cancelamento"
     SKIP(1)
     WITH ROW 9 CENTERED SIDE-LABELS OVERLAY
                TITLE COLOR NORMAL " Dados do Limite de Desconto de Titulos " 
                WIDTH 76 FRAME f_dsctit_prolim.

FORM SKIP(1)
     "Rendas: Salario:" AT  3
     tt-dsctit_dados_limite.vlsalari
                        AT 20 FORMAT "zzz,zzz,zz9.99"
                              HELP "Entre com o valor do salario do associado."
     "Conjuge:"         AT 37
     tt-dsctit_dados_limite.vlsalcon       AT 46 FORMAT "zzz,zzz,zz9.99"
                              HELP "Entre com o valor do salario do conjuge."
     " "
     SKIP(1)
     "Outras:"          AT 12
     tt-dsctit_dados_limite.vloutras       AT 20 FORMAT "zzz,zzz,zz9.99"
                              HELP "Entre com o valor de outras rendas."
     SKIP(1)
     "Bens:"               AT 5 
     tt-dsctit_dados_limite.dsdbens1       AT 11 FORMAT "x(60)" SKIP
     tt-dsctit_dados_limite.dsdbens2       AT 11 FORMAT "x(60)"
     WITH ROW 9 COLUMN 5 NO-LABELS OVERLAY
          TITLE COLOR NORMAL " Desconto de Titulos - Rendas " 
                                FRAME f_dsctit_rendas.

FORM SKIP(1)
     tt-dsctit_dados_bordero.dspesqui AT 22 LABEL "Pesquisa" 
                                            FORMAT "x(40)"
     tt-dsctit_dados_bordero.nrborder AT 23 LABEL "Bordero"  
                                            SKIP
     tt-dsctit_dados_bordero.nrctrlim AT 22 LABEL "Contrato"  
                                            SKIP
     tt-dsctit_dados_bordero.dsdlinha AT 13 LABEL "Linha de Desconto" 
                                            FORMAT "x(40)" SKIP(1)
     tt-dsctit_dados_bordero.qttitulo     AT 10 LABEL "Qtd. Titulos"  
                                            FORMAT "zzz,zz9"
     tt-dsctit_dados_bordero.dsopedig     AT 42 LABEL "Digitado por"  
                                            FORMAT "x(20)" SKIP
     tt-dsctit_dados_bordero.vltitulo     AT 17 LABEL "Valor" 
                                            FORMAT "zzz,zzz,zz9.99" SKIP
     tt-dsctit_dados_bordero.txmensal AT 11 LABEL "Taxa Mensal" "%"
     tt-dsctit_dados_bordero.dtlibbdt AT 43 LABEL "Liberado em" SKIP
     tt-dsctit_dados_bordero.txdiaria AT 11 LABEL "Taxa Diaria" "%"
     tt-dsctit_dados_bordero.dsopelib AT 56 NO-LABEL FORMAT "x(20)" SKIP
     tt-dsctit_dados_bordero.txjurmor AT 10 LABEL "Taxa de Mora" "%"
     SKIP(1)
     opc_dsimprim     AT 24 NO-LABEL FORMAT "x(8)"
     opc_dsvisual     AT 38 NO-LABEL FORMAT "x(18)"
     WITH ROW 9 COLUMN 2 NO-LABELS SIDE-LABELS OVERLAY WIDTH 78
          TITLE COLOR NORMAL " Consulta de Bordero " FRAME f_bordero.

FORM SKIP(1)
     tt-dsctit_dados_bordero.dspesqui AT 22 LABEL "Pesquisa" 
                                            FORMAT "x(40)"
     tt-dsctit_dados_bordero.nrborder AT 23 LABEL "Bordero"  
                                            SKIP
     tt-dsctit_dados_bordero.nrctrlim AT 22 LABEL "Contrato"  
                                            SKIP
     tt-dsctit_dados_bordero.dsdlinha AT 13 LABEL "Linha de Desconto" 
                                            FORMAT "x(40)" SKIP(1)
     tt-dsctit_dados_bordero.qttitulo     AT 10 LABEL "Qtd. Titulos"  
                                            FORMAT "zzz,zz9"
     tt-dsctit_dados_bordero.dsopedig     AT 42 LABEL "Digitado por"  
                                            FORMAT "x(20)" SKIP
     tt-dsctit_dados_bordero.vltitulo     AT 17 LABEL "Valor" 
                                            FORMAT "zzz,zzz,zz9.99" SKIP
     tt-dsctit_dados_bordero.txmensal AT 11 LABEL "Taxa Mensal" "%"
     tt-dsctit_dados_bordero.dtlibbdt AT 43 LABEL "Liberado em" SKIP
     tt-dsctit_dados_bordero.txdiaria AT 11 LABEL "Taxa Diaria" "%"
     tt-dsctit_dados_bordero.dsopelib AT 56 NO-LABEL FORMAT "x(20)" SKIP
     tt-dsctit_dados_bordero.txjurmor AT 10 LABEL "Taxa de Mora" "%"
     SKIP(1)
     WITH ROW 9 COLUMN 2 NO-LABELS SIDE-LABELS OVERLAY WIDTH 78
          TITLE COLOR NORMAL " Dados do Bordero " FRAME f_bordero2.

FORM SKIP(1)
     tt-dsctit_dados_limite.nrgarope FORMAT "z9" AT 18 LABEL "Garantia"
         HELP "Informe a garantia ou <F7> para listar."
         VALIDATE((IF glb_cdcooper <> 3 THEN 
                     tt-dsctit_dados_limite.nrgarope <> 0
                   ELSE
                     tt-dsctit_dados_limite.nrgarope = 0),
                   (IF glb_cdcooper <> 3 THEN
                       "375 - O campo deve ser preenchido."
                    ELSE 
                       "375 - O campo deve ser zerado."))
       
    tt-dsctit_dados_limite.nrinfcad  FORMAT "z9" AT 42 
                                     LABEL "Informacoes Cadastrais"
         HELP "Informe as informacoes cadastrais ou <F7> para listar."
         VALIDATE (tt-dsctit_dados_limite.nrinfcad <> 0, 
                    "375 - O campo deve ser preenchido.")
     SKIP

     tt-dsctit_dados_limite.nrliquid FORMAT "z9" AT 04 
                                     LABEL "Liquidez das Garantias"
         HELP "Informe a liquidez das garantias ou <F7> para listar."
         VALIDATE(tt-dsctit_dados_limite.nrliquid <> 0, 
                  "375 - O campo deve ser preenchido.")
     
    tt-dsctit_dados_limite.nrpatlvr FORMAT "z9" AT 40 
                                    LABEL "Patrimonio Pessoal Livre"    
         HELP "Informe o patrimonio pessoal ou <F7> para listar."
         VALIDATE((IF glb_cdcooper <> 3 THEN 
                     tt-dsctit_dados_limite.nrpatlvr <> 0
                   ELSE
                     tt-dsctit_dados_limite.nrpatlvr = 0),
                  (IF glb_cdcooper <> 3 THEN
                      "375 - O campo deve ser preenchido."
                   ELSE
                      "375 - O campo deve ser zerado."))
     SKIP(1)

    tt-dsctit_dados_limite.vltotsfn  FORMAT "z,zzz,zz9.99" AT 01 
                                     LABEL "Vlr. Tot. SFN c/Coop"
         HELP "Informe o valor total do SFN."        
    SKIP
    tt-dsctit_dados_limite.perfatcl FORMAT "zz9.99" AT 02 
                                    LABEL "% Faturamento unico cliente"
         HELP "Informe a faturamento unico cliente."
         VALIDATE (INPUT tt-dsctit_dados_limite.perfatcl > 0 
                         AND INPUT tt-dsctit_dados_limite.perfatcl <= 100,
                         "269 - Valor errado.")
    
    tt-dsctit_dados_limite.nrperger FORMAT "z9" AT 39 
                                    LABEL "Percepcao geral (Empresa)"
         HELP "Percepcao geral com relacao a empresa."
         VALIDATE((IF glb_cdcooper <> 3 THEN 
                     tt-dsctit_dados_limite.nrperger <> 0
                   ELSE
                     tt-dsctit_dados_limite.nrperger = 0),
                  (IF glb_cdcooper <> 3 THEN
                      "375 - O campo deve ser preenchido."
                   ELSE
                      "375 - O campo deve ser zerado."))
     
    WITH ROW 9 COLUMN 5 NO-LABELS SIDE-LABELS WIDTH 72 OVERLAY
          TITLE COLOR NORMAL " RATING " FRAME f_rating.
          
FORM 
    tel_dsobserv  HELP "Use <TAB> para sair"          
    SKIP
    btn_btaosair  HELP "Tecle <Enter> para sair." AT 37
    WITH ROW 14 CENTERED NO-LABELS OVERLAY TITLE  " Observacoes " 
    FRAME f_observacao.       
             
FORM 
    tel_dsvisual HELP "Pressione <F4> ou <END> para finalizar" 
    WITH SIZE 76 BY 15 ROW 6 COLUMN 3 USE-TEXT NO-BOX NO-LABELS OVERLAY
    FRAME f_visualiza.         


DEF QUERY q-grupo-economico FOR tt-grupo.

DEF BROWSE b-grupo-economico QUERY q-grupo-economico
    DISPLAY tt-grupo.nrctasoc 
    WITH 3 DOWN NO-LABELS NO-BOX WIDTH 15 OVERLAY.

FORM "Conta"                                     AT 8
     tel_nrdconta
     "Pertence a Grupo Economico."              
     SKIP
     "Valor ultrapassa limite legal permitido."  AT 8
     SKIP
     "Verifique endividamento total das contas." AT 8
     SKIP(1)
     "Grupo possui"                              AT 8
     aux_qtctarel
     "Contas Relacionadas:"
     SKIP
     "-------------------------------------"     AT 8
     SKIP
     b-grupo-economico                           AT 20
     HELP  "Pressione ENTER / F4 ou END para sair."
     WITH ROW 9 COLUMN 12 NO-LABELS OVERLAY WIDTH 60 FRAME f_grupo_economico.


DEF QUERY q-grupo-economico2 FOR tt-grupo.

DEF BROWSE b-grupo-economico2 QUERY q-grupo-economico2
    DISPLAY tt-grupo.nrctasoc 
    WITH 3 DOWN NO-LABELS NO-BOX WIDTH 25 OVERLAY.

FORM "Conta"                                       AT 8
     tel_nrdconta                                
     "Pertence a Grupo Economico."                 
     SKIP                                        
     "Risco Atual do Grupo: "                      AT 8
     tt-grupo.dsdrisgp
     "."
     SKIP(1)
     "Grupo possui"                                AT 8
     aux_qtctarel
     "Contas Relacionadas:"
     SKIP
     "-------------------------------------"       AT 8
     SKIP
     b-grupo-economico2                            AT 21
     HELP "Pressione ENTER / F4 ou END para sair."
     WITH ROW 9 COLUMN 12 NO-LABELS OVERLAY WIDTH 60 FRAME f_grupo_economico2.

ON RETURN OF b-grupo-economico IN FRAME f_grupo_economico DO:

    APPLY "GO".

END.

ON RETURN OF b-grupo-economico2 IN FRAME f_grupo_economico2 DO:

    APPLY "GO".

END.

/* .......................................................................... */


