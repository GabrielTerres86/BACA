/* .............................................................................

   Programa: Includes/var_proepr.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/96.                           Ultima atualizacao: 12/05/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criacao das variaveis para tratamento da PROPOSTA DE EMPRESTIMO.

   Alteracoes: 10/07/2001 - Aumentar a observacao nas propostas de emprestimos.
                            (Eduardo).
               16/12/2002 - Tratar nome e documento do conjuge dos fiadores
                            (Deborah).
               23/03/2003 - Incluir tratamento da Concredi (Margarete).
               
               27/11/2003 - Inclusao do campo Nivel de Risco(Mirtes).

               11/06/2004 - Incluido campo tel_nivcalcu - Risco Calculado
                                                                (Evandro).
               16/06/2004 - Incluido campos Tabela Crapavt(Mirtes).

               13/08/2004 - Incluido campos cidade/uf/cep(Mirtes).

               27/10/2004 - Incluido novos campos: Tipo de chassi, UF placa,
                            UF licenciamento, RENAVAN (Edson).
                            
               24/02/2005 - Retirado o "NO-UNDO" da declaracao de algumas
                            variaveis pela necessidade de poder desfazer a
                            atribuicao a essas mesmas variaveis (Evandro).
                            
               29/08/2005 - Incluidas variaveis para o estado civil (Evandro).
               
               11/01/2006 - Inclusao do proprietario do bem (Evandro).
               
               06/02/2006 - Inclusao de NO-UNDO nas temp-tables - SQLWorks -
                            Eder

               10/02/2006 - Retirada variavel ali_uflicenc no frame 
                            f_alienacao, fixado "SC" , e alterado formato
                            RENAVAN para 9 posicoes (Diego).

               25/07/2006 - Incluido opcao "CH" no help e validate dos campos
                            tpdoc... (David).
                            
               08/04/2008 - Alterado o formato da variável "tel_qtpreemp" de 
                            "z9" para "zz9" 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
               
               17/06/2009 - Substituida variavel pro_dsdebens por pro_dsrelbem 
                            e variavel pro_vloutras por pro_vldrendi (Elton). 
                         
                          - Cadastro de pessoa fisica e juridica (Gabriel).
                          
               23/09/2009 - Incluido "%" no label "Concentracao faturamento
                            unico cliente" (Elton).  
                            
               26/11/2009 - Campo novo qualificacao da operacao.Projeto Rating
                            (Gabriel).                       C

               18/01/2010 - Incluir frame com opcoes para alteracao da proposta
                            de emprestimo (David).
                            
               17/03/2010 - Aumentado o formato do RENAVAN para ficar do mesmo
                            jeito que a tela ADITIV.
                           
                            Alterar para um Browser dinamico (Gabriel).    
                            
               21/06/2010 - Utilizar includes e temp-table da BO 2 (Gabriel).
               
               12/07/2010 - Projeto de melhorias de op. de credito (Gabriel).
               
               24/11/2010 - Arrumado formato do CEP do aval (Gabriel).  
               
               13/04/2011 - Inclusão de campos Nro., Complemento e Cxa. Postal,
                            ajustes no layout para CEP integrado. (André - DB1)
                                                        
               21/07/2011 - Inclusao do campo 'Tipo de Emprestimo' na tela
                            com descricao inicial correspondente ao codigo 0.
                            (Diego - GATI)
                          
               01/09/2011 - Alterado descritivo do botao tel_btalnume de 
                            "Proposta" para "Emprestimo".

               05/04/2012 - Incluido campo dtlibera (Gabriel).

               29/01/2013 - Alterado formats do browse b_crawepr (Lucas).

               04/04/2013 - Incluir * nas operacoes do tipo pre-fixado (Gabriel)

               08/05/2013 - Incluido a variavel aux_qtctarel ( Adriano ).

               26/12/2013 - Incluido a variavel aux_uflicenc e novo campo no
                            frame f_alienacao / tt-bens-alienacao.uflicenc
                            (Guilherme / SUPERO).
                           
               04/04/2014 - Trocado a ordem dos campos de Finalidade e Linha de
                            Credito. (Reinert)                            
                            
               28/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow SD137074).   
                            
               06/06/2014 - Adicionado tratamento para novos campos inpessoa e
                            dtnascto do avalista 1 e 2 (Daniel) 
               
               26/08/2014 - Ajustes no frame f_proepr - Projeto CET 
                            (Lucas R./Gielow )
                            
               01/09/2014 - Projeto Automatização de Consultas em 
                            Propostas de Crédito (Jonata/RKAM).
                          
               19/01/2015 - Melhoria Emprestimo, adicionado Tipo Veiculo.
                            (Jorge/Gielow) - SD 231859.           
               
               22/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)    

               12/05/2015 - Alteracao na critica na mudanca de numero do 
                            contrato no f_numero. (Jaison/Gielow - SD: 282303)

			   28/08/2017 - Alterado tipos de documento para utilizarem CI, CN, 
							CH, RE, PP E CT. (PRJ339 - Reinert)

............................................................................. */
           
{ sistema/generico/includes/b1wgen0002tt.i }    
{ sistema/generico/includes/b1wgen9999tt.i }

DEF {1} SHARED VAR aux_ultlinha  AS INTE                             NO-UNDO.
DEF {1} SHARED VAR aux_flgsaida  AS LOGI                             NO-UNDO.
DEF {1} SHARED VAR aux_dtdpagto  AS DATE                             NO-UNDO.
DEF {1} SHARED VAR aux_ddmesnov  AS INTE                             NO-UNDO.
DEF {1} SHARED VAR aux_qtdiacar  AS INTE                             NO-UNDO.
DEF {1} SHARED VAR aux_nrindcat  AS INTE                             NO-UNDO.
DEF {1} SHARED VAR aux_lscatbem  AS CHAR                             NO-UNDO.
DEF {1} SHARED VAR aux_lscathip  AS CHAR                             NO-UNDO.
DEF {1} SHARED VAR aux_nrindvei  AS INTE                             NO-UNDO.
DEF {1} SHARED VAR aux_lsveibem  AS CHAR                             NO-UNDO.


DEF NEW SHARED VAR shr_dsnacion AS CHAR FORMAT "x(15)"               NO-UNDO.
DEF NEW SHARED VAR shr_inpessoa AS INT                               NO-UNDO.

DEF VAR tel_btaltepr AS CHAR INIT "Toda a Proposta de Emprestimo"    NO-UNDO.
DEF VAR tel_btaltvlr AS CHAR INIT "Somente o Valor da Proposta  "    NO-UNDO.
DEF VAR tel_btalnume AS CHAR INIT "Somente o Numero do Contrato "    NO-UNDO.
DEF VAR tel_btconsul AS CHAR INIT "Somente Consultas"                NO-UNDO.

DEF VAR tel_qtpromis AS INTE                                         NO-UNDO.
DEF VAR ant_nrctremp AS INTE                                         NO-UNDO.
DEF VAR aux_nrctrobs AS INTE                                         NO-UNDO.
DEF VAR aux_nrctaava AS INTE                                         NO-UNDO.
DEF VAR aux_nrctaav2 AS INTE                                         NO-UNDO.
DEF VAR aux_vlpreemp AS DECI                                         NO-UNDO.
DEF VAR aux_qtpreant AS INTE                                         NO-UNDO.
DEF VAR aux_vleprori AS DECI                                         NO-UNDO.
DEF VAR aux_tpaltera AS INTE                                         NO-UNDO.
DEF VAR aux_contaliq AS INTE                                         NO-UNDO. 
DEF VAR aux_nrcpfcgc AS DECI                                         NO-UNDO.
DEF VAR aux_nmdavali AS CHAR                                         NO-UNDO.
DEF VAR aux_dsendre1 AS CHAR                                         NO-UNDO.

DEF VAR par_dsdalien AS CHAR                                         NO-UNDO.
DEF VAR par_dsinterv AS CHAR                                         NO-UNDO.

/* Primeiro Avalista */
DEF VAR aux_nmdaval1 AS CHAR                                         NO-UNDO.
DEF VAR aux_nrcpfav1 AS DECI                                         NO-UNDO.
DEF VAR aux_tpdocav1 AS CHAR                                         NO-UNDO.
DEF VAR aux_dsdocav1 AS CHAR                                         NO-UNDO.
DEF VAR aux_nmdcjav1 AS CHAR                                         NO-UNDO.
DEF VAR aux_cpfcjav1 AS DECI                                         NO-UNDO.
DEF VAR aux_tdccjav1 AS CHAR                                         NO-UNDO.
DEF VAR aux_doccjav1 AS CHAR                                         NO-UNDO.
DEF VAR aux_ende1av1 AS CHAR                                         NO-UNDO.
DEF VAR aux_ende2av1 AS CHAR                                         NO-UNDO.
DEF VAR aux_nrfonav1 AS CHAR                                         NO-UNDO.
DEF VAR aux_emailav1 AS CHAR                                         NO-UNDO.
DEF VAR aux_nmcidav1 AS CHAR                                         NO-UNDO.
DEF VAR aux_cdufava1 AS CHAR                                         NO-UNDO.
DEF VAR aux_nrcepav1 AS INTE                                         NO-UNDO.
DEF VAR aux_dsnacio1 AS CHAR                                         NO-UNDO.
DEF VAR aux_vledvmt1 AS DECI                                         NO-UNDO.
DEF VAR aux_vlrenme1 AS DECI                                         NO-UNDO.
DEF VAR aux_nrender1 AS INTE                                         NO-UNDO.
DEF VAR aux_nrcxaps1 AS INTE                                         NO-UNDO.
DEF VAR aux_complen1 AS CHAR                                         NO-UNDO.
DEF VAR aux_inpesso1 AS INTE                                         NO-UNDO.
DEF VAR aux_dtnasct1 AS DATE                                         NO-UNDO.
/* Segundo Avalista */
DEF VAR aux_nmdaval2 AS CHAR                                         NO-UNDO.
DEF VAR aux_nrcpfav2 AS DECI                                         NO-UNDO.
DEF VAR aux_tpdocav2 AS CHAR                                         NO-UNDO.
DEF VAR aux_dsdocav2 AS CHAR                                         NO-UNDO.
DEF VAR aux_nmdcjav2 AS CHAR                                         NO-UNDO.
DEF VAR aux_cpfcjav2 AS DECI                                         NO-UNDO.
DEF VAR aux_tdccjav2 AS CHAR                                         NO-UNDO.
DEF VAR aux_doccjav2 AS CHAR                                         NO-UNDO.
DEF VAR aux_ende1av2 AS CHAR                                         NO-UNDO.
DEF VAR aux_ende2av2 AS CHAR                                         NO-UNDO.
DEF VAR aux_nrfonav2 AS CHAR                                         NO-UNDO.
DEF VAR aux_emailav2 AS CHAR                                         NO-UNDO.
DEF VAR aux_nmcidav2 AS CHAR                                         NO-UNDO.
DEF VAR aux_cdufava2 AS CHAR                                         NO-UNDO.
DEF VAR aux_nrcepav2 AS INTE                                         NO-UNDO.
DEF VAR aux_dsnacio2 AS CHAR                                         NO-UNDO.
DEF VAR aux_vledvmt2 AS DECI                                         NO-UNDO.
DEF VAR aux_vlrenme2 AS DECI                                         NO-UNDO.
DEF VAR aux_nrender2 AS INTE                                         NO-UNDO.
DEF VAR aux_nrcxaps2 AS INTE                                         NO-UNDO.
DEF VAR aux_complen2 AS CHAR                                         NO-UNDO.
DEF VAR aux_inpesso2 AS INTE                                         NO-UNDO.
DEF VAR aux_dtnasct2 AS DATE                                         NO-UNDO.

DEF VAR ant_dslcremp AS CHAR                                         NO-UNDO.
DEF VAR ant_dsfinemp AS CHAR                                         NO-UNDO.

DEF VAR par_recidepr AS INTE                                         NO-UNDO.
DEF VAR par_dsmesage AS CHAR                                         NO-UNDO.
DEF VAR par_qtdiacar AS INTE                                         NO-UNDO.
DEF VAR par_vlutiliz AS DECI                                         NO-UNDO.
DEF VAR par_dtlibera AS DATE                                         NO-UNDO.

DEF VAR nov_nrctremp AS INTE                                         NO-UNDO. 
DEF VAR ant_cddtecla AS INTE                                         NO-UNDO.  
DEF VAR aux_dstpempr AS CHAR                                         NO-UNDO.
DEF VAR aux_qtctarel AS INT   FORMAT "zz9"                           NO-UNDO.

DEF VAR aux_uflicenc AS CHAR  FORMAT "x(2)"                          NO-UNDO.

DEF VAR aux_dspessoa AS CHAR                                         NO-UNDO.

DEF VAR h-b1wgen0191 AS HANDLE                                       NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                       NO-UNDO.                            

DEF BUTTON btn_btaosair LABEL "Sair".
DEF BUTTON btn_btsaicmt LABEL "Sair".
   

DEF QUERY  q_crawepr FOR tt-proposta-epr.

DEF BROWSE b_crawepr QUERY q_crawepr
    DISP tt-proposta-epr.dsidenti COLUMN-LABEL ""            FORMAT "x(1)"
         tt-proposta-epr.dtmvtolt COLUMN-LABEL "Data"        FORMAT "99/99/99"
         tt-proposta-epr.nrctremp COLUMN-LABEL "Contrato"    FORMAT "zz,zzz,zz9"
         tt-proposta-epr.vlemprst COLUMN-LABEL "Emprestimo"  FORMAT "zzz,zzz,zz9.99"
         tt-proposta-epr.vlpreemp COLUMN-LABEL "Prestacao"   FORMAT "z,zzz,zz9.99"
         tt-proposta-epr.qtpreemp COLUMN-LABEL "Pr"          FORMAT "zz9"
         tt-proposta-epr.cdlcremp COLUMN-LABEL "Lcr"         FORMAT "zzz9"
         tt-proposta-epr.cdfinemp COLUMN-LABEL "Fin"         FORMAT "zz9"
         tt-proposta-epr.cdoperad COLUMN-LABEL "Ac"          FORMAT "x(8)"
         tt-proposta-epr.flgenvio COLUMN-LABEL "Cmt"         FORMAT "x(3)"
         WITH CENTERED WIDTH 76 7 DOWN NO-BOX.


FORM tt-proposta-epr.nivrisco AT  9 FORMAT "x(02)" LABEL "Nivel Risco"
        HELP "Entre com o Risco(A , B , C , D , E , F , G , H)"
     tt-proposta-epr.nivcalcu AT 42 LABEL "Risco  Calc."   

     aux_dstpempr AT 13 FORMAT "x(18)" LABEL "Produto" 

     tt-proposta-epr.cdfinemp AT 44 FORMAT "zz9" LABEL "Finalidade"
        HELP "Entre com a finalidade de emprestimo ou <F7> para listar."
        AUTO-RETURN

     tt-proposta-epr.dsfinemp AT 61 FORMAT "x(16)" NO-LABEL     
        SKIP

     tt-proposta-epr.vlemprst AT  1 FORMAT "zzz,zzz,zz9.99" LABEL "Valor do Emprestimo"
        HELP "Entre com o valor a ser emprestado."
        VALIDATE(tt-proposta-epr.vlemprst > 0,"269 - Valor errado.")
        AUTO-RETURN
     
     tt-proposta-epr.cdlcremp AT 41 FORMAT "zzz9" LABEL "Linha Credito"
        HELP "Entre com a linha de credito do emprestimo ou <F7> para listar."
        AUTO-RETURN     

     tt-proposta-epr.dslcremp AT 61 FORMAT "x(16)" NO-LABEL

     SKIP

     tt-proposta-epr.vlpreemp AT  2 FORMAT "zzz,zzz,zz9.99" LABEL "Valor da Prestacao"
              
     tt-proposta-epr.idquapro AT 38 FORMAT " z9" LABEL "Qualif. Operacao"
        HELP "Informe a qualificacao da operacao ou pressione <F7>."
     tt-proposta-epr.dsquapro AT 61 FORMAT "x(16)" NO-LABEL

     tt-proposta-epr.qtpreemp AT  4 FORMAT "zz9" LABEL "Qtd. de Parcelas"
        HELP "Entre com a quantidade de parcelas do emprestimo."
        AUTO-RETURN

     tt-proposta-epr.qtdialib AT 44 FORMAT "  9" LABEL "Liberar em"
        HELP "Entre com a quantidade de dias uteis para liberacao."
        AUTO-RETURN
      "dias uteis"
      SKIP

     tt-proposta-epr.flgpagto AT 10 FORMAT "Folha/Conta" LABEL "Debitar em"
        HELP '"F" para debitar no dia da Folha ou "C" para debitar na C/C.'

          
     tt-proposta-epr.dtdpagto AT 44 FORMAT "99/99/9999" LABEL "Data pagto"
        HELP "Entre com a data do primeiro pagamento."
     SKIP

     tt-proposta-epr.percetop AT 44 FORMAT "zz9.99" LABEL "CET(%a.a.)"
        VALIDATE (tt-proposta-epr.percetop <= 100,
                  "Indice percentual do CET maior que 100.")
        HELP "Entre com o percentual da CET."
     SKIP
     tt-proposta-epr.flgimppr AT 46 FORMAT "Imprime/Nao Imprime" LABEL "Proposta"
        HELP '"I" para imprimir ou "N" para nao imprimir a proposta.'
     SKIP
     tt-proposta-epr.flgimpnp AT 38 FORMAT "Imprime/Nao Imprime" LABEL "Nota Promissoria"
        HELP '"I" para imprimir ou "N" para nao imprimir a promissoria.'
     
     tt-proposta-epr.dsctrliq AT  1 FORMAT "x(60)" LABEL "Liquidacoes"
        HELP "Pressione <ENTER> para visualizar emprestimos a liquidar."
     
     WITH ROW 5 CENTERED SIDE-LABELS NO-LABELS OVERLAY TITLE
          COLOR NORMAL " Nova Proposta de Emprestimo " WIDTH 78 FRAME f_proepr.


FORM SKIP(1) " "
     tt-proposta-epr.nrctremp FORMAT "zz,zzz,zz9"
                  LABEL "Numero do contrato impresso"
                  HELP "Entre com o numero impresso no contrato."
     " " SKIP(1)
     WITH ROW 11 CENTERED SIDE-LABELS OVERLAY FRAME f_contrato.

FORM SKIP(1) " "
     tt-proposta-epr.nrctremp FORMAT "zz,zzz,zz9"
                  LABEL "Confirme o numero do contrato impresso"
                  HELP "Confirme o numero impresso no contrato."
     " " SKIP(1)
     WITH ROW 11 CENTERED SIDE-LABELS OVERLAY FRAME f_confirma_ctr.


FORM SKIP(1)
     tt-proposta-epr.nrctremp AT 03 LABEL "Contrato atual" FORMAT "zz,zzz,zz9"
     SKIP(1)
     nov_nrctremp             AT 04 LABEL "Novo contrato"  FORMAT "zz,zzz,zz9"
        HELP "Informe o novo numero da proposta de emprestimo."
        VALIDATE (nov_nrctremp <> 0,
                  "Numero do contrato deve ser diferente de zero.")
     SKIP(1)
     WITH ROW 9 CENTERED SIDE-LABELS OVERLAY TITLE COLOR NORMAL
          " Numero da proposta "  WIDTH 32 FRAME f_numero.  

FORM SKIP         
     "Quant.:"                AT  5
     tel_qtpromis AT 13 FORMAT "zz9"
         HELP "Entre com a quantidade de promissorias a serem emitidas."

     "Conta:"                 
     tt-dados-avais.nrctaava  FORMAT "zzzz,zzz,9"
         HELP "Entre com o numero da conta do primeiro avalista/fiador."
     SKIP(1)
     "Nome:"                  AT  7 
     tt-dados-avais.nmdavali  FORMAT "x(40)"
         HELP "Entre com o nome do primeiro avalista/fiador."
     "C.P.F.:"                
     tt-dados-avais.nrcpfcgc  FORMAT "zzzzzzzzzzzzz9"
         HELP "Entre com o CPF do primeiro avalista."
     "Documento:"             AT  2
     tt-dados-avais.tpdocava  FORMAT "x(2)" 
         VALIDATE(tt-dados-avais.tpdocava = " "  OR              
                  tt-dados-avais.tpdocava = "CH" OR
                  tt-dados-avais.tpdocava = "CP" OR
                  tt-dados-avais.tpdocava = "CI" OR              
                  tt-dados-avais.tpdocava = "CT" OR
                  tt-dados-avais.tpdocava = "TE",
                  "021 - Tipo de documento errado")
         HELP "Entre com CH, CI, CP, CT, TE"
     tt-dados-avais.nrdocava  FORMAT "x(37)"
         HELP "Entre com o Docto do primeiro avalista/fiador."
     
     "Nacio.:"                  
     tt-dados-avais.dsnacion  FORMAT "x(14)"
         HELP "Entre com a nacionalidade ou tecle F7 para listar."
     SKIP
         
     "Tp.Natur.:"     AT  2
     tt-dados-avais.inpessoa    FORMAT "9"
                      HELP "Tipo de pessoa: 1 - Fisica, 2 - Juridica."
     aux_dspessoa    AT 15 FORMAT "x(20)"

     "Data Nascimento:"   AT  45 
     tt-dados-avais.dtnascto    FORMAT "99/99/9999"
                      HELP "Entre com a data de nascimento do primeiro aval."
     SKIP

     "Conjuge:"               AT  4 
     tt-dados-avais.nmconjug  FORMAT "x(40)"
         HELP "Entre com o nome do conjuge do primeiro aval." 
     "C.P.F.:"                
     tt-dados-avais.nrcpfcjg  FORMAT "zzzzzzzzzzzzz9"
         HELP "Entre com o CPF do conjuge do primeiro aval."
     "Documento:"             AT 2
     tt-dados-avais.tpdoccjg  FORMAT "x(2)" 
         VALIDATE(tt-dados-avais.tpdoccjg = " "  OR              
                  tt-dados-avais.tpdoccjg = "CI" OR
                  tt-dados-avais.tpdoccjg = "CN" OR                  
                  tt-dados-avais.tpdoccjg = "CH" OR
                  tt-dados-avais.tpdoccjg = "RE" OR
                  tt-dados-avais.tpdoccjg = "PP" OR
                  tt-dados-avais.tpdoccjg = "CT",
                  "021 - Tipo de documento errado")
         HELP "Entre com CI, CN, CH, RE, PP, CT"
     tt-dados-avais.nrdoccjg  FORMAT "x(37)"
         HELP "Entre com o Docto do conjuge do primeiro aval."
     SKIP(1)

     "CEP:"                   AT 5
     tt-dados-avais.nrcepend FORMAT "99999,999"
         HELP "Entre com o CEP ou pressione F7 para pesquisar"
     "End.     :"             AT 24
     tt-dados-avais.dsendre1  FORMAT "x(40)"
         HELP "Entre com o endereco do primeiro avalista/fiador."
     SKIP
     "Nro.:"                  AT 4
     tt-dados-avais.nrendere  FORMAT "zzz,zz9"
         HELP "Entre com o numero do endereco"
     "Complemento:"           AT 22
     tt-dados-avais.complend FORMAT "X(40)"
         HELP  "Informe o complemento do endereco"
     SKIP
     "Bairro:"                AT  2
     tt-dados-avais.dsendre2  FORMAT "x(40)"
         HELP "Entre com o bairro do primeiro avalista/fiador."
     "Caixa Postal:"          AT 55
     tt-dados-avais.nrcxapst  FORMAT "zz,zz9"  
         HELP "Informe o numero da caixa postal"
     SKIP
     "Cidade:"                AT 02
     tt-dados-avais.nmcidade  FORMAT "x(25)"
         HELP "Entre com o nome da cidade"
     "UF:"                    AT 39
     tt-dados-avais.cdufresd  FORMAT "x(2)"
         HELP "Entre com a UF"
     "Fone:"                  AT 50 
     tt-dados-avais.nrfonres  FORMAT "x(19)"
         HELP "Entre com o telefone do primeiro avalista"
     SKIP
     "E-mail:"                AT 2
     tt-dados-avais.dsdemail  FORMAT "x(30)" 
         HELP "Entre com o email do primeiro avalista/fiador"
     SKIP(1)
     "Endividamento:"         AT 02
     tt-dados-avais.vledvmto  FORMAT "z,zzz,zz9.99"
         HELP "Entre com o valor do endividamento"
     "Renda mensal:"          AT 50
     tt-dados-avais.vlrenmes  FORMAT " zzz,zz9.99"
         HELP "Entre com o valor da renda mensal"
     SKIP
        WITH WIDTH 78 ROW 5 CENTERED NO-LABELS OVERLAY TITLE COLOR NORMAL
                " Dados dos Avalistas/Fiadores " FRAME f_promissoria.
             

FORM SKIP(1)
     tt-bens-alienacao.lsbemfin AT 30 FORMAT "x(30)" NO-LABEL
     SKIP(1)
     tt-bens-alienacao.dscatbem AT  2 FORMAT "x(20)" LABEL "Categoria        "
        HELP "Use a teclas de direcao para escolher a categoria."
     tt-bens-alienacao.dstipbem AT  2 FORMAT "x(20)" LABEL "Tipo Veiculo     "
        HELP "Use a teclas de direcao para escolher o tipo de veiculo."
     tt-bens-alienacao.dsbemfin AT  2 FORMAT "x(25)" LABEL "Descricao        "
        HELP "Entre com a descricao do bem. <TAB> p/ proximo campo."
     tt-bens-alienacao.dscorbem AT  2 FORMAT "x(35)" LABEL "Cor / Classe     "
     tt-bens-alienacao.vlmerbem AT  2 FORMAT "zzz,zzz,zz9.99"
                                                     LABEL "Valor de mercado "
        HELP "Entre com o valor de mercado do bem."
     tt-bens-alienacao.dschassi AT  2 FORMAT "x(20)" LABEL "Chassi/N.Serie   "
     tt-bens-alienacao.tpchassi AT 52 FORMAT "9"     LABEL "Tipo Chassi"
                                                     AUTO-RETURN
        HELP "Entre com o tipo de chassi: 1-Remarcado, 2-Normal."
     SKIP
     tt-bens-alienacao.ufdplaca AT  2 FORMAT "xx"    LABEL "UF/Placa         " 
                                                     AUTO-RETURN
     tt-bens-alienacao.nrdplaca       FORMAT "xxx-xxxx" NO-LABEL 
     tt-bens-alienacao.uflicenc       LABEL  "UF Licenciamento"     AT  47
     SKIP
     tt-bens-alienacao.nrrenava AT  2 FORMAT "zzz,zzz,zzz,zz9" 
                                                     LABEL "RENAVAN          "
        HELP "Entre com o numero do RENAVAN do veiculo"
     tt-bens-alienacao.nranobem AT 39 FORMAT "z,zz9" LABEL "Ano Fab"
     
     tt-bens-alienacao.nrmodbem AT 56 FORMAT "z,zz9" LABEL "Ano Mod"
     SKIP(1)
     tt-bens-alienacao.nrcpfbem AT  2                LABEL "CPF/CNPJ Propr   " 
                                   
         HELP "Informe o CPF/CNPJ do Proprietario do Bem"
     SKIP(1)
     WITH WIDTH 78 ROW 5 CENTERED SIDE-LABELS OVERLAY TITLE COLOR normal 
          " Dados para Alienacao Fiduciaria " FRAME f_alienacao.

FORM SKIP(1)
     tt-hipoteca.lsbemfin  AT 30 FORMAT "x(30)" NO-LABEL
     SKIP(1)
     tt-hipoteca.dscatbem  AT  3 FORMAT "x(20)" LABEL "Categoria"
         HELP "Use a teclas de direcao para escolher a categoria."

     tt-hipoteca.vlmerbem  AT 37 FORMAT "zzz,zzz,zz9.99" 
                                                LABEL "Valor de mercado"  
         HELP "Entre com o valor de mercado do bem."    
     SKIP(1)
     tt-hipoteca.dsbemfin  AT  3 FORMAT "x(50)" LABEL "Descricao"
         HELP "Entre com a descricao do imovel."
     SKIP
 
     SKIP(1)
     tt-hipoteca.dscorbem  AT  4 FORMAT "x(50)" LABEL "Endereco"
         HELP "Entre com o endereco do imovel."
     SKIP
    
     SKIP(4)
     WITH WIDTH 78 ROW 5 CENTERED SIDE-LABELS OVERLAY TITLE COLOR NORMAL
           " Dados para a  H I P O T E C A " FRAME f_hipoteca.

/* interveniente anuente */
FORM SKIP(1)
     "Conta :"                   AT  6
     tt-interv-anuentes.nrctaava FORMAT "zzzz,zzz,9"
         HELP "Entre com o numero da conta do interveniente anuente."
     SKIP(1)
     "Nome:"                     AT  7 
     tt-interv-anuentes.nmdavali FORMAT "x(40)"
         HELP "Entre com o nome do interveniente anuente."
     "C.P.F.:"                   
     tt-interv-anuentes.nrcpfcgc FORMAT "zzzzzzzzzzzzz9"
         HELP "Entre com o CPF do interveniente anuente"
     "Documento:"                AT 2
     tt-interv-anuentes.tpdocava FORMAT "x(2)"  
         VALIDATE (tt-interv-anuentes.tpdocava = "" OR 
                   CAN-DO("CI,CN,CH,RE,PP,CT",tt-interv-anuentes.tpdocava),                 
                   "021 - Tipo de documento errado")
         HELP "Entre com CI, CN, CH, RE, PP, CT"

     tt-interv-anuentes.nrdocava FORMAT "x(37)"
         HELP "Entre com o Docto do interveniente anuente."
     "Nacio.:"         
     tt-interv-anuentes.dsnacion FORMAT "x(14)"
         HELP "Entre com a nacionalidade ou tecle F7 para listar."
     SKIP
     "Conjuge:"                  AT 4 
     tt-interv-anuentes.nmconjug FORMAT "x(40)"
         HELP "Entre com o nome do conjuge do interveniente anuente."
     "C.P.F :"              
     tt-interv-anuentes.nrcpfcjg FORMAT "zzzzzzzzzzzzz9"
         HELP "Entre com o CPF do conjuge do interveniente anuente."
     "Documento:"                AT  2
     tt-interv-anuentes.tpdoccjg  
         VALIDATE (tt-interv-anuentes.tpdoccjg = " "  OR              
                   CAN-DO("CI,CN,CH,RE,PP,CT",tt-interv-anuentes.tpdoccjg),
                   "021 - Tipo de documento errado")
         HELP "Entre com CI, CN, CH, RE, PP, CT"   
     tt-interv-anuentes.nrdoccjg FORMAT "x(37)"
         HELP "Entre com o Docto do conjuge do interveniente anuente."
     SKIP(1)

     "CEP:"                   AT 5
     tt-interv-anuentes.nrcepend FORMAT "99999,999"
         HELP "Entre com o CEP ou pressione F7 para pesquisar"
     "Endereco   :"          AT 23
     tt-interv-anuentes.dsendre[1]  FORMAT "x(40)"
         HELP "Entre com o endereco do interveniente anuente."
     SKIP
     "Nro.:"                  AT 4
     tt-interv-anuentes.nrendere  FORMAT "zzz,zz9"
         HELP "Entre com o numero do endereco"
     "Complemento:"           AT 23
     tt-interv-anuentes.complend FORMAT "X(40)"
         HELP  "Informe o complemento do endereco"
     SKIP
     "Bairro:"                AT  2
     tt-interv-anuentes.dsendre[2]  FORMAT "x(40)"
         HELP "Entre com o bairro do interveniente anuente."
     "Caixa Postal:"          AT 56
     tt-interv-anuentes.nrcxapst  FORMAT "zz,zz9"  
         HELP "Informe o numero da caixa postal"
     SKIP
     "Cidade:"                AT 02
     tt-interv-anuentes.nmcidade  FORMAT "x(25)"
         HELP "Entre com o nome da cidade"
     "UF:"                    AT 40
     tt-interv-anuentes.cdufresd  FORMAT "x(2)"
         HELP "Entre com a UF"
     "Fone:"                  AT 51 
     tt-interv-anuentes.nrfonres  FORMAT "x(19)"
         HELP "Entre com o telefone do interveniente anuente."
     SKIP
     "E-mail:"                AT 2
     tt-interv-anuentes.dsdemail  FORMAT "x(30)" 
         HELP "Entre com o email do primeiro interveniente anuente."
     SKIP(1)                                                              
     WITH WIDTH 78 ROW 5 CENTERED NO-LABELS OVERLAY TITLE COLOR NORMAL
              " Dados dos Intervenientes Anuentes " FRAME f_interveniente.

FORM tt-proposta-epr.dsquapro NO-LABEL
     HELP "Informe a qualificacao da operacao ou pressione <END> p/ voltar."
     WITH WIDTH 32 ROW 11 COLUMN 47 OVERLAY NO-BOX FRAME f_lsquapro.

FORM SKIP(1)
     tel_btaltepr NO-LABEL AT 04 FORMAT "x(29)" 
     SKIP(1)
     tel_btaltvlr NO-LABEL AT 04 FORMAT "x(29)"
     SKIP(1) 
     tel_btalnume NO-LABEL AT 04 FORMAT "x(29)"
     SKIP(1)
     tel_btconsul NO-LABEL AT 04 FORMAT "x(29)"
     WITH OVERLAY CENTERED TITLE COLOR NORMAL " Alterar? " WIDTH 40 ROW 09 
          FRAME f_opcoes_alterar.

FORM SKIP (1) 
     tt-msg-confirma.dsmensag AT  2 FORMAT "x(70)"
     SKIP (1)
     WITH NO-LABEL OVERLAY CENTERED ROW 10 WIDTH 74 FRAME f_alertas.   
     
DEF FRAME f_observ_comite
          tt-proposta-epr.dsobscmt 
            HELP "Use a tecla <F4> para sair."          
          SKIP
          btn_btsaicmt  
            HELP "Pressione <ENTER> para confirmar a observacao." AT 37
          WITH ROW 8 CENTERED NO-LABELS OVERLAY TITLE " Comite de Aprovacao ".

DEF FRAME f_observacao 
          tt-proposta-epr.dsobserv  
            HELP "Use a tecla <F4> para sair."          
          SKIP
          btn_btaosair
            HELP "Pressione <ENTER> para confirmar a observacao." AT 37
          WITH ROW 15 CENTERED NO-LABELS OVERLAY TITLE " Observacoes ".

ON RETURN OF tt-hipoteca.dsbemfin DO:

    APPLY "ENTRY" TO tt-hipoteca.dscorbem IN FRAME f_hipoteca. 

END.


ON RETURN OF tt-hipoteca.dscorbem DO:
    
    APPLY "GO".

END.
                 
/*  Funcao para exibir descricao do tipo de emprestimo */
FUNCTION fn_dstpempr RETURN CHAR ( 
    par_tpemprst AS INT,
    par_cdtpempr AS CHAR,
    par_dstpempr AS CHAR):

    DEF VAR aux_postpemp AS INTEGER     NO-UNDO.

    ASSIGN aux_postpemp  = LOOKUP(STRING(par_tpemprst),par_cdtpempr).

    IF aux_postpemp = 0 THEN
        ASSIGN aux_postpemp  = LOOKUP("0",par_cdtpempr).

    RETURN ENTRY(aux_postpemp,par_dstpempr) .
    
END FUNCTION.

/* .......................................................................... */


