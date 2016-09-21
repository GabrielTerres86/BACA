/* .............................................................................

   Programa: Includes/var_altava.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Junho/2004                          Ultima atualizacao: 16/10/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criacao das variaveis para tratamento alteracao avalistas 
               (Tela ALTAVA).

   Alteracoes: 17/08/2004 - Incluido campos cidade/uf/cep(Evandro).

               25/07/2006 - Incluido opcao "CH" no help e validate em campos
                            tpdoc... (David).
                            
               25/04/2011 - Aumentar formatos de bairro e cidade (Gabriel).
               
               29/04/2011 - Separação de avalistas. Inclusão de CEP integrado.
                            (André - DB1)          
                            
               16/10/2012 - Correção descritivo Help campo documento
                            conjuge (Daniel).  
                            
               06/06/2014 - Adicionado novos campos inpessoa e dtnascto 
                            no frame f_promissoria1 e f_promissoria2 (Daniel). 

.............................................................................*/
DEF {1} SHARED VARIABLE aux_dtdpagto AS DATE                   NO-UNDO.
                                                               
DEF {1} SHARED VARIABLE aux_qtdiacar AS INT                    NO-UNDO.
DEF {1} SHARED VARIABLE aux_dsobserv AS CHAR                   NO-UNDO.
                                                               
DEF {1} SHARED VAR tel_qtdialib AS INT                         NO-UNDO.
                                                            
DEF {1} SHARED VAR tel_dslcremp AS CHAR                        NO-UNDO.
DEF {1} SHARED VAR tel_dsfinemp AS CHAR                        NO-UNDO.
DEF {1} SHARED VAR tel_dsctrliq AS CHAR                        NO-UNDO.
DEF {1} SHARED VAR tel_nrctrobs LIKE crawepr.nrctremp          NO-UNDO.
DEF {1} SHARED VAR tel_dsobserv AS CHAR  VIEW-AS EDITOR SIZE 76 BY 4 
                    BUFFER-LINES 10       PFCOLOR 0    NO-UNDO.

DEF {1} SHARED VAR tel_flgimppr AS LOGICAL                     NO-UNDO.
DEF {1} SHARED VAR tel_flgimpnp AS LOGICAL                     NO-UNDO.
DEF {1} SHARED VAR pro_qtpromis AS INT                         NO-UNDO.
DEF {1} SHARED VAR pro_dtvencto AS DATE                        NO-UNDO.
DEF {1} SHARED VAR pro_nrctaav1 AS INT                         NO-UNDO.
DEF {1} SHARED VAR pro_nmdaval1 AS CHAR                        NO-UNDO.
DEF {1} SHARED VAR pro_dscpfav1 AS CHAR                        NO-UNDO.
DEF {1} SHARED VAR pro_dsendav1 AS CHAR           EXTENT 2     NO-UNDO.
DEF {1} SHARED VAR pro_nrctaav2 AS INT                         NO-UNDO.
DEF {1} SHARED VAR pro_nmdaval2 AS CHAR                        NO-UNDO.
DEF {1} SHARED VAR pro_dscpfav2 AS CHAR                        NO-UNDO.
DEF {1} SHARED VAR pro_dsendav2 AS CHAR           EXTENT 2     NO-UNDO.
DEF {1} SHARED VAR pro_nmchefia AS CHAR                        NO-UNDO.
DEF {1} SHARED VAR pro_dsdebens AS CHAR           EXTENT 4     NO-UNDO.
DEF {1} SHARED VAR pro_vlsalari AS DECIMAL                     NO-UNDO.
DEF {1} SHARED VAR pro_vlsalcon AS DECIMAL                     NO-UNDO.
DEF {1} SHARED VAR pro_vloutras AS DECIMAL                     NO-UNDO.
DEF {1} SHARED VAR pro_dscfcav1 AS CHAR                        NO-UNDO.
DEF {1} SHARED VAR pro_dscfcav2 AS CHAR                        NO-UNDO.
DEF {1} SHARED VAR pro_nmcjgav1 AS CHAR                        NO-UNDO.
DEF {1} SHARED VAR pro_nmcjgav2 AS CHAR                        NO-UNDO.
                                                               
DEF {1} SHARED VAR pro_nmcidade1 AS CHAR FORMAT "x(25)"        NO-UNDO.
DEF {1} SHARED VAR pro_cdufresd1 AS CHAR FORMAT "!(2)"         NO-UNDO.
DEF {1} SHARED VAR pro_nrcepend1 AS INTE FORMAT "99999,999"    NO-UNDO.
DEF {1} SHARED VAR pro_nmcidade2 AS CHAR FORMAT "x(25)"        NO-UNDO.
DEF {1} SHARED VAR pro_cdufresd2 AS CHAR FORMAT "!(2)"         NO-UNDO.
DEF {1} SHARED VAR pro_nrcepend2 AS INTE FORMAT "99999,999"    NO-UNDO.

DEF {1} SHARED VAR pro_cpfcgc1  AS DEC FORMAT "zzzzzzzzzzzzz9" NO-UNDO.
DEF {1} SHARED VAR pro_cpfccg1  AS DEC FORMAT "zzzzzzzzzzzzz9" NO-UNDO.
DEF {1} SHARED VAR pro_cpfcgc2  AS DEC FORMAT "zzzzzzzzzzzzz9" NO-UNDO.
DEF {1} SHARED VAR pro_cpfccg2  AS DEC FORMAT "zzzzzzzzzzzzz9" NO-UNDO.

DEF {1} SHARED VAR pro_tpdocav1  AS CHAR FORMAT "x(2)"         NO-UNDO.
DEF {1} SHARED VAR pro_tpdoccj1  AS CHAR FORMAT "x(2)"         NO-UNDO.
DEF {1} SHARED VAR pro_tpdocav2  AS CHAR FORMAT "x(2)"         NO-UNDO.
DEF {1} SHARED VAR pro_tpdoccj2  AS CHAR FORMAT "x(2)"         NO-UNDO.
DEF {1} SHARED VAR pro_nrfonres1 AS CHAR FORMAT "x(20)"        NO-UNDO.
DEF {1} SHARED VAR pro_nrfonres2 AS CHAR FORMAT "x(20)"        NO-UNDO.
DEF {1} SHARED VAR pro_dsdemail1 AS CHAR FORMAT "x(30)"        NO-UNDO.
DEF {1} SHARED VAR pro_dsdemail2 AS CHAR FORMAT "x(30)"        NO-UNDO.

/* Adicionais CEP integrado */
DEF {1} SHARED VAR pro_nrendere1 AS INTE FORMAT "zzz,zz9"      NO-UNDO.
DEF {1} SHARED VAR pro_complend1 AS CHAR FORMAT "x(40)"        NO-UNDO.
DEF {1} SHARED VAR pro_nrcxapst1 AS INTE FORMAT "zz,zz9"       NO-UNDO.
DEF {1} SHARED VAR pro_nrendere2 AS INTE FORMAT "zzz,zz9"      NO-UNDO.
DEF {1} SHARED VAR pro_complend2 AS CHAR FORMAT "x(40)"        NO-UNDO.
DEF {1} SHARED VAR pro_nrcxapst2 AS INTE FORMAT "zz,zz9"       NO-UNDO.

DEF {1} SHARED VAR pro_dtnascto1 AS DATE FORMAT "99/99/9999"   NO-UNDO.
DEF {1} SHARED VAR pro_inpessoa1 AS INTE FORMAT "9"            NO-UNDO.
DEF {1} SHARED VAR pro_dspessoa1 AS CHAR FORMAT "x(40)"        NO-UNDO.
DEF {1} SHARED VAR pro_dtnascto2 AS DATE FORMAT "99/99/9999"   NO-UNDO.
DEF {1} SHARED VAR pro_inpessoa2 AS INTE FORMAT "9"            NO-UNDO.
DEF {1} SHARED VAR pro_dspessoa2 AS CHAR FORMAT "x(40)"        NO-UNDO.

DEF {1} SHARED FRAME f_promissoria.
DEF {1} SHARED FRAME f_promissoria1.
DEF {1} SHARED FRAME f_promissoria2.

DEF     BUTTON btn_btaosair label "Sair".

FORM SKIP(1)         
     "Conta:"         AT  6
     pro_nrctaav1     FORMAT "zzzz,zzz,9"
                 HELP "Entre com o numero da conta do primeiro avalista/fiador"

     "Tp.Natur.:"     AT  28
     pro_inpessoa1    FORMAT "9"
                      HELP "Tipo de pessoa: 1 - Fisica, 2 - Juridica."
     pro_dspessoa1    AT 41 FORMAT "x(8)"

     "  CPF/CNPJ:"        
     pro_cpfcgc1      FORMAT "zzzzzzzzzzzzz9"
                      HELP "Entre com o CPF do primeiro avalista"
     SKIP(1)
     "Nome:"          AT 7 
     pro_nmdaval1     FORMAT "x(40)"
                      HELP "Entre com o nome do primeiro avalista/fiador."

     "Dt. Nasc.:"     AT  55 
     pro_dtnascto1    FORMAT "99/99/9999"
                      HELP "Entre com a data de nascimento do primeiro aval."
     
     "Documento:"     AT  2
     pro_tpdocav1     VALIDATE (pro_tpdocav1 = " "  OR
                                pro_tpdocav1 = "CH" OR
                                pro_tpdocav1 = "CP" OR
                                pro_tpdocav1 = "CI" OR              
                                pro_tpdocav1 = "CT" OR
                                pro_tpdocav1 = "TE",
                                "021 - Tipo de documento errado")
                      HELP "Entre com CH, CI, CP, CT, TE"
     pro_dscpfav1     FORMAT "x(40)"
                      HELP "Entre com o Docto do primeiro avalista/fiador."
     SKIP
     
     
     SKIP(1)
     "Conjuge:"       AT  4 
     pro_nmcjgav1     FORMAT "x(40)"
                      HELP "Entre com o nome do conjuge do primeiro aval." 
     "C.P.F.:"        
     pro_cpfccg1      FORMAT "zzzzzzzzzzzzz9"
                      HELP "Entre com o CPF do conjuge do primeiro aval."
     "Documento:"     AT  2
     pro_tpdoccj1     VALIDATE (pro_tpdoccj1 = " "  OR
                                 pro_tpdoccj1 = "CH" OR
                                 pro_tpdoccj1 = "CP" OR
                                 pro_tpdoccj1 = "CI" OR              
                                 pro_tpdoccj1 = "CT" OR
                                 pro_tpdoccj1 = "TE",
                                 "021 - Tipo de documento errado")
                      HELP "Entre com CH, CI, CP, CT, TE"
     pro_dscfcav1     FORMAT "x(40)"
                      HELP "Entre com o Docto do conjuge do primeiro aval."

     SKIP(1)
     "CEP:"           AT 05
     pro_nrcepend1    HELP "Entre com o CEP ou pressione F7 para pesquisar"
     "Endereco:"      AT  23
     pro_dsendav1[1]  FORMAT "x(40)"
                      HELP "Entre com o endereco."
     SKIP
     "Nro.:"          AT 04
     pro_nrendere1    FORMAT "zzz,zz9"
                      HELP "Entre com o numero do endereco"
     "Complemento:"   AT 23
     pro_complend1    FORMAT "X(40)"
                      HELP  "Informe o complemento do endereco"
     SKIP
     "Bairro:"        AT 02
     pro_dsendav1[2]  FORMAT "x(40)"
                      HELP "Entre com o bairro"
     "Caixa Postal:"  AT 56
     pro_nrcxapst1    FORMAT "zz,zz9"  
                      HELP "Informe o numero da caixa postal"
     SKIP
     "Cidade:"        AT 02
     pro_nmcidade1    FORMAT "x(25)"
                      HELP "Entre com o nome da cidade"
     "UF:"            AT 40
     pro_cdufresd1    HELP "Entre com a UF"
     "Fone:"          AT 50 
     pro_nrfonres1    FORMAT "x(20)"
                      HELP "Entre com o telefone do primeiro avalista"
     "E-mail:"        AT 2
     pro_dsdemail1    FORMAT "x(32)" 
                      HELP "Entre com o email do primeiro avalista/fiador"
     SKIP(1)
            WITH ROW 5 WIDTH 80 CENTERED NO-LABELS OVERLAY TITLE COLOR NORMAL
                " Dados dos Avalistas/Fiadores (1) " FRAME f_promissoria1.
    
FORM SKIP(1)         
     "Conta:"         AT  6
     pro_nrctaav2     FORMAT "zzzz,zzz,9"
                 HELP "Entre com o numero da conta do primeiro avalista/fiador"
     "Tp.Natur.:"     AT  28
     pro_inpessoa2    FORMAT "9"
                      HELP "Tipo de pessoa: 1 - Fisica, 2 - Juridica."
     pro_dspessoa2    AT 41 FORMAT "x(8)"

     "  CPF/CNPJ:"        
     pro_cpfcgc2      FORMAT "zzzzzzzzzzzzz9"
                      HELP "Entre com o CPF do primeiro avalista"

     SKIP(1)
     "Nome:"          AT  7 
     pro_nmdaval2     FORMAT "x(40)"
                      HELP "Entre com o nome do primeiro avalista/fiador."

     "Dt. Nasc.:"     AT  55 
     pro_dtnascto2    FORMAT "99/99/9999"
                      HELP "Entre com a data de nascimento do primeiro aval."
     
     "Documento:"     AT  2
     pro_tpdocav2     VALIDATE (pro_tpdocav1 = " "  OR
                                pro_tpdocav1 = "CH" OR
                                pro_tpdocav1 = "CP" OR
                                pro_tpdocav1 = "CI" OR              
                                pro_tpdocav1 = "CT" OR
                                pro_tpdocav1 = "TE",
                                "021 - Tipo de documento errado")
                      HELP "Entre com CH, CI, CP, CT, TE"
     pro_dscpfav2     FORMAT "x(40)"
                      HELP "Entre com o Docto do primeiro avalista/fiador."
     SKIP
     
     SKIP(1)
     "Conjuge:"       AT  4 
     pro_nmcjgav2     FORMAT "x(40)"
                      HELP "Entre com o nome do conjuge do primeiro aval." 
     "C.P.F.:"        
     pro_cpfccg2      FORMAT "zzzzzzzzzzzzz9"
                      HELP "Entre com o CPF do conjuge do primeiro aval."
     "Documento:"     AT  2
     pro_tpdoccj2     VALIDATE (pro_tpdoccj1 = " "  OR
                                pro_tpdoccj1 = "CH" OR
                                pro_tpdoccj1 = "CP" OR
                                pro_tpdoccj1 = "CI" OR              
                                pro_tpdoccj1 = "CT" OR
                                pro_tpdoccj1 = "TE",
                                "021 - Tipo de documento errado")
                             HELP "Entre com CH, CI, CP, CT, TE"
     pro_dscfcav2     FORMAT "x(40)"
                      HELP "Entre com o Docto do conjuge do primeiro aval."

     SKIP(1)
     "CEP:"           AT 05
     pro_nrcepend2    HELP "Entre com o CEP ou pressione F7 para pesquisar"
     "Endereco:"      AT  23
     pro_dsendav2[1]  FORMAT "x(40)"
                      HELP "Entre com o endereco."
     SKIP
     "Nro.:"          AT 04
     pro_nrendere2    FORMAT "zzz,zz9"
                      HELP "Entre com o numero do endereco"
     "Complemento:"   AT 23
     pro_complend2    FORMAT "X(40)"
                      HELP  "Informe o complemento do endereco"
     SKIP
     "Bairro:"        AT 02
     pro_dsendav2[2]  FORMAT "x(40)"
                      HELP "Entre com o bairro"
     "Caixa Postal:"  AT 56
     pro_nrcxapst2    FORMAT "zz,zz9"  
                      HELP "Informe o numero da caixa postal"
     SKIP
     "Cidade:"        AT 02
     pro_nmcidade2    FORMAT "x(25)"
                      HELP "Entre com o nome da cidade"
     "UF:"            AT 40
     pro_cdufresd2    HELP "Entre com a UF"
     "Fone:"          AT 50 
     pro_nrfonres2    FORMAT "x(20)"
                      HELP "Entre com o telefone do primeiro avalista"
     "E-mail:"        AT 2
     pro_dsdemail2    FORMAT "x(32)" 
                      HELP "Entre com o email do primeiro avalista/fiador"
     SKIP(1)
            WITH ROW 5 WIDTH 80 CENTERED NO-LABELS OVERLAY TITLE COLOR NORMAL
                " Dados dos Avalistas/Fiadores (2) " FRAME f_promissoria2. 


/* .......................................................................... */
