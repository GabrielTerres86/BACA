/*.............................................................................

   Programa: Includes/var_deschq.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003.                  Ultima atualizacao: 24/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criacao das variaveis para tratamento do DESCONTO DE CHEQUES.

   Alteracaoes: 16/06/2004 - Incluido campos Tabela Crapavt(Mirtes).
   
                17/08/2004 - Incluido campos cidade/uf/cep(Evandro).

                12/01/2006 - Incluido campo Bens (Diego).

                25/07/2006 - Incluido opcao "CH" no help e validate dos campos
                             tpdoc... (David).

                04/07/2007 - Incluido campo lim_dtcancel
                             Incluido o campo no frame f_prolim (Guilherme).

                10/12/2009 - Adicionar frame para o novo RATING (Fernando).
                           - Alterado para um browse dinamico (Gabriel).
                           - Substituido variavel tel_vlopescr por vltotsfn 
                             (Elton).           
                            
                23/06/2010 - Utilizar a temp-table dos limites da BO 09
                             (Gabriel).
                             
                15/04/2011 - Inclusao de variáveis para CEP integrado, 
                             nrendere, complend e nrcxapst. 
                             Divisao do form f_promissoria. (André - DB1)
                             
                03/11/2011 - Quando for a CENTRAL, os campos abaixo nao serao 
                            obrigatorios:
                            - Garantia
                            - Patrimonio Pessoal Livre
		                    - Percepcao geral
                            (Adriano).        
                            
                16/10/2012 - Correçao descritivo Help campo documento
                            conjuge (Daniel).       
                            
                26/11/2012 - Ajustes referente ao Projeto GE (Lucas R.).
                
                02/05/2013 - Ajuste no layout dos frames f_grupo_economico,
                             f_grupo_economico2 ( Adriano ).   
                             
                24/06/2014 - Inclusao da include b1wgen0138tt para uso da
                             temp-table tt-grupo.
                             (Chamado 130880) - (Tiago Castro - RKAM)
                             
............................................................................. */

{ sistema/generico/includes/b1wgen0043tt.i }
{ sistema/generico/includes/b1wgen0009tt.i }
{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/b1wgen0138tt.i }


DEF {1} SHARED VAR tel_dsobserv AS CHAR  VIEW-AS EDITOR SIZE 76 BY 4 
                   BUFFER-LINES 10       PFCOLOR 0                    NO-UNDO.

DEF {1} SHARED VAR tel_nrctrpro AS INT                                NO-UNDO.
DEF {1} SHARED VAR tel_qtdiavig AS INT                                NO-UNDO.
DEF {1} SHARED VAR tel_cddlinha AS INT                                NO-UNDO.

DEF {1} SHARED VAR tel_vllimpro AS DECIMAL                            NO-UNDO.
DEF {1} SHARED VAR tel_vlfatura AS DECIMAL                            NO-UNDO.
DEF {1} SHARED VAR tel_vlmedchq AS DECIMAL                            NO-UNDO.

DEF {1} SHARED VAR tel_txjurmor AS DECIMAL DECIMALS 7                 NO-UNDO.
DEF {1} SHARED VAR tel_txdmulta AS DECIMAL DECIMALS 7                 NO-UNDO.

DEF {1} SHARED VAR tel_dsdlinha AS CHAR                               NO-UNDO.
DEF {1} SHARED VAR tel_dsramati AS CHAR                               NO-UNDO.
DEF {1} SHARED VAR tel_dsdebens AS CHAR           EXTENT 2            NO-UNDO.

DEF {1} SHARED VAR lim_nrctaav1 AS INT                                NO-UNDO.
DEF {1} SHARED VAR lim_nmdaval1 AS CHAR                               NO-UNDO.
DEF {1} SHARED VAR lim_dscpfav1 AS CHAR                               NO-UNDO.
DEF {1} SHARED VAR lim_dsendav1 AS CHAR           EXTENT 2            NO-UNDO.
DEF {1} SHARED VAR lim_nrctaav2 AS INT                                NO-UNDO.
DEF {1} SHARED VAR lim_dtcancel AS DATE  FORMAT 99/99/9999            NO-UNDO.
                                                                      
DEF {1} SHARED VAR lim_nmdaval2 AS CHAR                               NO-UNDO.
DEF {1} SHARED VAR lim_dscpfav2 AS CHAR                               NO-UNDO.
DEF {1} SHARED VAR lim_dsendav2 AS CHAR           EXTENT 2            NO-UNDO.
DEF {1} SHARED VAR lim_nmdcjav1 AS CHAR                               NO-UNDO.
DEF {1} SHARED VAR lim_dscfcav1 AS CHAR                               NO-UNDO.
DEF {1} SHARED VAR lim_nmdcjav2 AS CHAR                               NO-UNDO.
DEF {1} SHARED VAR lim_dscfcav2 AS CHAR                               NO-UNDO.


DEF {1} SHARED VAR lim_nmcidade1 AS CHAR FORMAT "x(25)"               NO-UNDO.
DEF {1} SHARED VAR lim_cdufresd1 AS CHAR FORMAT "!(2)"                NO-UNDO.
DEF {1} SHARED VAR lim_nrcepend1 AS INTE FORMAT "99999,999"           NO-UNDO.
DEF {1} SHARED VAR lim_nmcidade2 AS CHAR FORMAT "x(25)"               NO-UNDO.
DEF {1} SHARED VAR lim_cdufresd2 AS CHAR FORMAT "!(2)"                NO-UNDO.
DEF {1} SHARED VAR lim_nrcepend2 AS INTE FORMAT "99999,999"           NO-UNDO.

/* Adicionais CEP integrado */
DEF {1} SHARED VAR lim_nrendere1 AS INTE FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR lim_complend1 AS CHAR FORMAT "x(40)"               NO-UNDO.
DEF {1} SHARED VAR lim_nrcxapst1 AS INTE FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR lim_nrendere2 AS INTE FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR lim_complend2 AS CHAR FORMAT "x(40)"               NO-UNDO.
DEF {1} SHARED VAR lim_nrcxapst2 AS INTE FORMAT "zz,zz9"              NO-UNDO.

DEF {1} SHARED VAR lim_cpfcgc1  AS DEC FORMAT "zzzzzzzzzzzzz9"        NO-UNDO.
DEF {1} SHARED VAR lim_cpfccg1  AS DEC FORMAT "zzzzzzzzzzzzz9"        NO-UNDO.
DEF {1} SHARED VAR lim_cpfcgc2  AS DEC FORMAT "zzzzzzzzzzzzz9"        NO-UNDO.
DEF {1} SHARED VAR lim_cpfccg2  AS DEC FORMAT "zzzzzzzzzzzzz9"        NO-UNDO.
                                                                      
DEF {1} SHARED VAR lim_tpdocav1 AS CHAR FORMAT "x(2)"                 NO-UNDO.
DEF {1} SHARED VAR lim_tpdoccj1 AS CHAR FORMAT "x(2)"                 NO-UNDO.
DEF {1} SHARED VAR lim_tpdocav2 AS CHAR FORMAT "x(2)"                 NO-UNDO.
DEF {1} SHARED VAR lim_tpdoccj2 AS CHAR FORMAT "x(2)"                 NO-UNDO.
DEF {1} SHARED VAR lim_nrfonres1 AS CHAR FORMAT "x(20)"               NO-UNDO.
DEF {1} SHARED VAR lim_nrfonres2 AS CHAR FORMAT "x(20)"               NO-UNDO.
DEF {1} SHARED VAR lim_dsdemail1 AS CHAR FORMAT "x(30)"               NO-UNDO.
DEF {1} SHARED VAR lim_dsdemail2 AS CHAR FORMAT "x(30)"               NO-UNDO.

DEF {1} SHARED VAR lim_vlsalari AS DECI                               NO-UNDO.
DEF {1} SHARED VAR lim_vlsalcon AS DECI                               NO-UNDO.
DEF {1} SHARED VAR lim_vloutras AS DECI                               NO-UNDO.
DEF {1} SHARED VAR lim_vlfatura AS DECI                               NO-UNDO.
                                                                  
DEF {1} SHARED VAR aux_confirma AS CHAR FORMAT "!"                    NO-UNDO.
DEF {1} SHARED VAR aux_flgsaida AS logi                               NO-UNDO.    
DEF {1} SHARED VAR aux_qtctarel AS INT FORMAT "zz9"                  NO-UNDO.

DEF {1} SHARED VAR opcao        AS INTE                               NO-UNDO.
                                                                  
DEF {1} SHARED FRAME f_prolim.
DEF {1} SHARED FRAME f_promissoria.
DEF {1} SHARED FRAME f_promissoria1.
DEF {1} SHARED FRAME f_promissoria2.


DEF QUERY q-craplim FOR tt-limite_chq.

DEF BROWSE b-craplim QUERY q-craplim
               DISPLAY dtpropos COLUMN-LABEL "Proposta"   FORMAT "99/99/99"
                       dtinivig COLUMN-LABEL "Ini.Vigen." FORMAT "99/99/99"
                       nrctrlim COLUMN-LABEL "Contrato"
                       vllimite COLUMN-LABEL "Limite"
                       qtdiavig COLUMN-LABEL "Vig"
                       cddlinha COLUMN-LABEL "LD"
                       dssitlim COLUMN-LABEL "Situacao"   FORMAT "x(9)"
                       flgenvio COLUMN-LABEL "Comite"     FORMAT "x(3)"
                       WITH NO-BOX 6 DOWN.
           
DEF     BUTTON btn_btaosair label "Sair".

FORM SKIP(1)
     tel_nrctrpro AT 18 LABEL "Contrato" FORMAT "z,zzz,zz9"
                        HELP "Entre com o numero do contrato."
     SKIP(1)                   
     tel_vllimpro AT 11 LABEL "Valor do limite"  FORMAT "zzz,zzz,zz9.99"
                        HELP "Entre com o valor do novo limite."
     tel_qtdiavig AT 51 LABEL "Vigencia" FORMAT "z,zz9" "dias"
     SKIP
     tel_cddlinha AT  9 LABEL "Linha de desconto" FORMAT "zz9"
        HELP "Informe a linha de desconto ou <F7> para listar."
     tel_dsdlinha NO-LABEL FORMAT "x(25)"
     SKIP
     tel_txjurmor AT 13 LABEL "Juros de mora" FORMAT "zz9.9999999" "%"
     tel_txdmulta AT 46 LABEL "Taxa de multa" FORMAT "zz9.9999999" "%"
     SKIP
     tel_dsramati AT  9 LABEL "Ramo de atividade" FORMAT "x(40)"
     SKIP
     tel_vlmedchq AT  3 LABEL "Valor medio dos cheques" FORMAT "z,zzz,zz9.99"
     SKIP
     tel_vlfatura AT  8 LABEL "Faturamento mensal" FORMAT "z,zzz,zz9.99" 
     lim_dtcancel At 42 LABEL "Data Cancelamento"
     SKIP(1)
     WITH ROW 9 CENTERED SIDE-LABELS OVERLAY
                TITLE COLOR NORMAL " Dados do Limite de Desconto " 
                WIDTH 76 FRAME f_prolim. 


FORM SKIP(1)         
     "Conta:"         AT  6
     lim_nrctaav1     FORMAT "zzzz,zzz,9"
                 HELP "Entre com o numero da conta do primeiro avalista/fiador"
     SKIP(1)
     "Nome:"          AT 7 
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
     "Conjuge:"       AT  4 
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
                " Dados dos Avalistas/Fiadores (1) " FRAME f_promissoria1.
    
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
                " Dados dos Avalistas/Fiadores (2) " FRAME f_promissoria2.   
     

FORM SKIP(1)
     "Rendas: Salario:" AT  3
     lim_vlsalari       AT 20 FORMAT "zzz,zzz,zz9.99"
                              HELP "Entre com o valor do salario do associado."
     "Conjuge:"         AT 37
     lim_vlsalcon       AT 46 FORMAT "zzz,zzz,zz9.99"
                              HELP "Entre com o valor do salario do conjuge."
     " "
     SKIP(1)
     "Outras:"          AT 12
     lim_vloutras       AT 20 FORMAT "zzz,zzz,zz9.99"
                              HELP "Entre com o valor de outras rendas."
     SKIP(1)
     "Bens:"               AT 5 
     tel_dsdebens[1]       AT 11 FORMAT "x(60)" SKIP
     tel_dsdebens[2]       AT 11 FORMAT "x(60)"
     WITH ROW 9 COLUMN 5 NO-LABELS OVERLAY
          TITLE COLOR NORMAL " Desconto de Cheques - Rendas " FRAME f_rendas.
 
FORM SKIP(1)
     tt-valores-rating.nrgarope  AT 18 LABEL "Garantia"
                                       FORMAT "zz9"
         HELP "Informe a garantia ou <F7> para listar."
         VALIDATE((IF glb_cdcooper <> 3 THEN
                      tt-valores-rating.nrgarope <> 0
                   ELSE
                      tt-valores-rating.nrgarope = 0),
                  (IF glb_cdcooper <> 3 THEN
                      "375 - O campo deve ser preenchido."
                   ELSE 
                      "375 - O campo deve ser zerado."))
        
     tt-valores-rating.nrinfcad  AT 42 LABEL "Informacoes Cadastrais"
                                       FORMAT "zz9" 
         HELP "Informe as informacoes cadastrais ou <F7> para listar."
         VALIDATE (tt-valores-rating.nrinfcad <> 0,
                    "375 - O campo deve ser preenchido.")
        
     SKIP
     tt-valores-rating.nrliquid  AT 04 LABEL "Liquidez das Garantias"
                                       FORMAT "zz9" 
         HELP "Informe a liquidez das garantias ou <F7> para listar."
         VALIDATE(tt-valores-rating.nrliquid <> 0,
                   "375 - O campo deve ser preenchido.")
        
     tt-valores-rating.nrpatlvr  AT 40 LABEL "Patrimonio Pessoal Livre"
                                       FORMAT "zz9"
         HELP "Informe o patrimonio pessoal ou <F7> para listar."
         VALIDATE((IF glb_cdcooper <> 3 THEN 
                      tt-valores-rating.nrpatlvr <> 0 
                   ELSE 
                      tt-valores-rating.nrpatlvr = 0 ),
                  (IF glb_cdcooper <> 3 THEN
                      "375 - O campo deve ser preenchido."
                   ELSE
                      "375 - O campo deve ser zerado."))
        
     SKIP(1)
     tt-valores-rating.vltotsfn  AT 06 LABEL "Vlr. Tot. SFN c/Coop"   
                                       FORMAT "zzz,zzz,zz9.99"     
     SKIP(1)
     tt-valores-rating.perfatcl  AT 02 LABEL "% Faturamento unico cliente"
                                       FORMAT "zz9.99" 
         VALIDATE (INPUT tt-valores-rating.perfatcl > 0 AND 
                   INPUT tt-valores-rating.perfatcl <= 100,
                         "269 - Valor errado.")
       
     tt-valores-rating.nrperger  AT 39 LABEL "Percepcao geral (Empresa)"
                                       FORMAT "zz9"
         HELP "Informe percepcao geral com relacao a empresa ou <F7> p/listar."
         VALIDATE((IF glb_cdcooper <> 3 THEN
                      tt-valores-rating.nrperger <> 0 
                   ELSE 
                      tt-valores-rating.nrperger = 0),
                  (IF glb_cdcooper <> 3 THEN
                      "375 - O campo deve ser preenchido."
                   ELSE
                      "375 - O campo deve ser zerado."))
        
     WITH ROW 9 COLUMN 5 NO-LABELS SIDE-LABELS WIDTH 72 OVERLAY
          TITLE COLOR NORMAL " RATING " FRAME f_rating.

DEFINE    FRAME f_observacao
          tel_dsobserv  HELP "Use <TAB> para sair"          
          SKIP
          btn_btaosair  HELP "Tecle <Enter> para confirmar a observacao" AT 37
          WITH ROW 14 CENTERED NO-LABELS OVERLAY TITLE  " Observacoes ".

DEF QUERY q-grupo-economico FOR tt-grupo.

DEF BROWSE b-grupo-economico QUERY q-grupo-economico
    DISPLAY tt-grupo.nrctasoc 
    WITH 3 DOWN WIDTH 15 NO-BOX NO-LABELS OVERLAY.

FORM "Conta"                                      AT 7
     tel_nrdconta
     "Pertence a Grupo Economico."
     SKIP
     "Valor ultrapassa limite legal permitido."   AT 7
     SKIP
     "Verifique endividamento total das contas."  AT 7
     SKIP(1)
     "Grupo Possui"                               AT 7
     aux_qtctarel
     "Contas Relacionadas:"                       
     SKIP                                         
     "-------------------------------------"      AT 7
     SKIP                                         
     b-grupo-economico                            AT 18
     HELP "Pressione <F4> ou <END> p/ sair"
     WITH ROW 9 CENTERED NO-LABELS OVERLAY WIDTH 55 FRAME f_grupo_economico.

DEF QUERY q-grupo-economico2 FOR tt-grupo.
    
DEF BROWSE b-grupo-economico2 QUERY q-grupo-economico2
    DISPLAY tt-grupo.nrctasoc 
    WITH 3 DOWN CENTERED WIDTH 15 NO-BOX NO-LABELS OVERLAY.

FORM "Conta"                                 AT 6
     tel_nrdconta                           
     "Pertence a Grupo Economico."          
     SKIP                                   
     "Risco Atual do Grupo:"                 AT 6
     tt-grupo.dsdrisgp                   
     "."                                    
     SKIP(1)                                
     "Grupo possui"                          AT 6
     aux_qtctarel
     "Contas Relacionadas:"         
     SKIP                           
     "-------------------------------------" AT 6
     SKIP
     b-grupo-economico2                      AT 17
     HELP "Pressione ENTER, F4/END para sair"
     WITH ROW 9 CENTERED OVERLAY NO-LABELS WIDTH 55 FRAME f_grupo_economico2.

FORM SKIP(1)
     tt-dscchq_dados_bordero.dspesqui AT 22 LABEL "Pesquisa" FORMAT "x(40)"
     tt-dscchq_dados_bordero.nrborder AT 23 LABEL "Bordero"    SKIP
     tt-dscchq_dados_bordero.nrctrlim AT 22 LABEL "Contrato"   SKIP
     tt-dscchq_dados_bordero.dsdlinha AT 13 LABEL "Linha de Desconto" FORMAT "x(40)"
     SKIP(1)
     tt-dscchq_dados_bordero.qtcheque AT 10 LABEL "Qtd. Cheques"  FORMAT "zzz,zz9"
     tt-dscchq_dados_bordero.dsopedig AT 42 LABEL "Digitado por"  FORMAT "x(20)" SKIP
     tt-dscchq_dados_bordero.vlcheque AT 17 LABEL "Valor" FORMAT "zzz,zzz,zz9.99" SKIP
     tt-dscchq_dados_bordero.txmensal AT 11 LABEL "Taxa Mensal" "%"
     tt-dscchq_dados_bordero.dtlibbdc AT 43 LABEL "Liberado em" SKIP
     tt-dscchq_dados_bordero.txdiaria AT 11 LABEL "Taxa Diaria" "%"
     tt-dscchq_dados_bordero.dsopelib AT 56 NO-LABEL FORMAT "x(20)" SKIP
     tt-dscchq_dados_bordero.txjurmor AT 10 LABEL "Taxa de Mora" "%"
     SKIP(1)
     WITH ROW 7 COLUMN 2 NO-LABELS SIDE-LABELS OVERLAY WIDTH 78
          TITLE COLOR NORMAL " Analise/Liberacao de Bordero " FRAME f_bordero.

/* .......................................................................... */


