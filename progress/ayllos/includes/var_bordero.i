/* ............................................................................

   Programa: Includes/var_bordero.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003.                     Ultima atualizacao: 06/01/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criacao das variaveis para tratamento do BORDERO DE DESCONTO DE
               CHEQUES.

   Alteracoes: 08/03/2004 - Aumentei o tamanho dos arrays de 100 p/ 500 (Julio)

               06/01/2006 - Incluir flglibch (Magui).
............................................................................. */

DEFINE {1} SHARED VARIABLE e_column   AS INTEGER              NO-UNDO.
DEFINE {1} SHARED VARIABLE e_hide     AS LOGICAL INITIAL TRUE NO-UNDO.
DEFINE {1} SHARED VARIABLE e_init     AS CHARACTER INITIAL "" NO-UNDO.
DEFINE {1} SHARED VARIABLE e_row      AS INTEGER              NO-UNDO.
DEFINE {1} SHARED VARIABLE e_title    AS CHARACTER            NO-UNDO.
DEFINE {1} SHARED VARIABLE e_wide     AS LOGICAL              NO-UNDO.

DEFINE {1} SHARED VARIABLE e_chcnt    AS INTEGER              NO-UNDO.
DEFINE {1} SHARED VARIABLE e_chextent AS INTEGER              NO-UNDO.
DEFINE {1} SHARED VARIABLE e_chlist   AS CHARACTER EXTENT 500 NO-UNDO.
DEFINE {1} SHARED VARIABLE e_choice   AS INTEGER   EXTENT 500 NO-UNDO.
DEFINE {1} SHARED VARIABLE e_recid    AS INTEGER   EXTENT 500 NO-UNDO.

DEFINE {1} SHARED VARIABLE e_nrctrlim AS INTEGER   EXTENT 500 NO-UNDO.
DEFINE {1} SHARED VARIABLE e_cdtiparq AS INTEGER   EXTENT 500 NO-UNDO.

DEFINE {1} SHARED VARIABLE e_multiple AS LOGICAL              NO-UNDO.

/* .......................................................................... */

DEF {1} SHARED VAR tel_dsobserv AS CHAR  VIEW-AS EDITOR SIZE 76 BY 4 
                   BUFFER-LINES 10       PFCOLOR 0    NO-UNDO.

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

DEF {1} SHARED VAR lim_nrctaav1 AS INT                        NO-UNDO.
DEF {1} SHARED VAR lim_nmdaval1 AS CHAR                       NO-UNDO.
DEF {1} SHARED VAR lim_dscpfav1 AS CHAR                       NO-UNDO.
DEF {1} SHARED VAR lim_dsendav1 AS CHAR           EXTENT 2    NO-UNDO.
DEF {1} SHARED VAR lim_nrctaav2 AS INT                        NO-UNDO.
DEF {1} SHARED VAR lim_nmdaval2 AS CHAR                       NO-UNDO.
DEF {1} SHARED VAR lim_dscpfav2 AS CHAR                       NO-UNDO.
DEF {1} SHARED VAR lim_dsendav2 AS CHAR           EXTENT 2    NO-UNDO.
DEF {1} SHARED VAR lim_nmdcjav1 AS CHAR                       NO-UNDO.
DEF {1} SHARED VAR lim_dscfcav1 AS CHAR                       NO-UNDO.
DEF {1} SHARED VAR lim_nmdcjav2 AS CHAR                       NO-UNDO.
DEF {1} SHARED VAR lim_dscfcav2 AS CHAR                       NO-UNDO.

DEF {1} SHARED VAR lim_vlsalari AS DECI                            NO-UNDO.
DEF {1} SHARED VAR lim_vlsalcon AS DECI                            NO-UNDO.
DEF {1} SHARED VAR lim_vloutras AS DECI                            NO-UNDO.
DEF {1} SHARED VAR lim_vlfatura AS DECI                            NO-UNDO.

DEF {1} SHARED VAR aux_confirma AS CHAR FORMAT "!"                 NO-UNDO.
DEF {1} SHARED VAR aux_flglibch AS LOG                             NO-UNDO.

DEF {1} SHARED FRAME f_prolim.
DEF {1} SHARED FRAME f_promissoria.

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
     SKIP(1)
     WITH ROW 9 CENTERED SIDE-LABELS OVERLAY
                TITLE COLOR NORMAL " Dados do Limite de Desconto " 
                WIDTH 76 FRAME f_prolim.

FORM SKIP(1)
     "Conta/dv"       AT  2
     lim_nrctaav1     FORMAT "zzzz,zzz,9"
                 HELP "Entre com o numero da conta do primeiro avalista/fiador."
     "Nome     :"     AT 22 
     lim_nmdaval1     AT 33 FORMAT "x(40)"
                      HELP "Entre com o nome do primeiro avalista/fiador." "   "
     SKIP
     "Documento:"     AT 22
     lim_dscpfav1     AT 33 FORMAT "x(40)"
                      HELP "Entre com o CPF do primeiro avalista/fiador."
     SKIP
     "Conjuge  :"     AT 22 
     lim_nmdcjav1     AT 33 FORMAT "x(40)"
                      HELP "Entre com o nome do conjuge do primeiro aval." "   "
     SKIP
     "Documento:"     AT 22
     lim_dscfcav1     AT 33 FORMAT "x(40)"
                      HELP "Entre com o CPF do conjuge do primeiro aval."
     SKIP
     "Endereco :"     AT 22
     lim_dsendav1[1]  AT 33 FORMAT "x(40)"
                      HELP "Entre com o endereco do primeiro avalista/fiador."
     SKIP
     " "              AT 19
     lim_dsendav1[2]  AT 33 FORMAT "x(40)"
                      HELP "Entre com o endereco do primeiro avalista/fiador."
     SKIP(1)
     "Conta/dv"       AT  2
     lim_nrctaav2     FORMAT "zzzz,zzz,9"
                 HELP "Entre com o numero da conta do segundo avalista/fiador."
     "Nome     :"     AT 22
     lim_nmdaval2     AT 33 FORMAT "x(40)"
                      HELP "Entre com o nome do segundo avalista/fiador."
     SKIP
     "Documento:"     AT 22
     lim_dscpfav2     AT 33 FORMAT "x(40)"
                      HELP "Entre com o CPF do segundo avalista/fiador."
     SKIP
     "Conjuge  :"     AT 22
     lim_nmdcjav2     AT 33 FORMAT "x(40)"
                      HELP "Entre com o nome do conjuge do segundo aval."
     SKIP
     "Documento:"     AT 22
     lim_dscfcav2     AT 33 FORMAT "x(40)"
                      HELP "Entre com o CPF do conjuge do segundo aval."
     SKIP
     "Endereco :"     AT 22
     lim_dsendav2[1]  AT 33 FORMAT "x(40)"
                      HELP "Entre com o endereco do segundo avalista/fiador."
     SKIP
     lim_dsendav2[2]  AT 33 FORMAT "x(40)"
                      HELP "Entre com o endereco do segundo avalista/fiador."
     WITH ROW 5 CENTERED NO-LABELS OVERLAY TITLE COLOR NORMAL
                " Dados dos Avalistas/Fiadores " FRAME f_promissoria.

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
     WITH ROW 7 CENTERED NO-LABELS OVERLAY
          TITLE COLOR NORMAL " Desconto de Cheques - Rendas " FRAME f_rendas.
 
DEFINE    FRAME f_observacao
          tel_dsobserv  HELP "Use <TAB> para sair"          
          SKIP
          btn_btaosair  HELP "Tecle <Enter> para confirmar a observacao" AT 37
          WITH ROW 14 CENTERED NO-LABELS OVERLAY TITLE  " Observacoes ".

/* .......................................................................... */
