/* ............................................................................

   Programa: Includes/var_dctror.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : André - DB1
   Data    : Junho/2011.                         Ultima atualizacao: 18/05/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criar as variaveis e form da tela DCTROR.

   Alteracoes: 12/12/2011 - Sustação provisória (André R./Supero).
   
               18/05/2012 - Alterar Mensagem de Prov. p/ Permanente (Ze).

............................................................................ */
DEF {1} SHARED VAR tel_nrdconta AS INTE     FORMAT "zzzz,zzz,9"        NO-UNDO.
DEF {1} SHARED VAR tel_nrctachq AS INTE     FORMAT "zzzz,zzz,9"        NO-UNDO.
DEF {1} SHARED VAR tel_cdbanchq AS INTE     FORMAT "zzz"               NO-UNDO.
DEF {1} SHARED VAR tel_cdagechq AS INTE                                NO-UNDO.
DEF {1} SHARED VAR tel_nmprimtl AS CHAR     FORMAT "x(40)"             NO-UNDO.
DEF {1} SHARED VAR tel_cdhistor AS INTE     FORMAT "zzzz"              NO-UNDO.
DEF {1} SHARED VAR tel_dshistor AS CHAR     FORMAT "x(28)"             NO-UNDO.
DEF {1} SHARED VAR tel_dtemscor AS DATE     FORMAT "99/99/9999"        NO-UNDO.
DEF {1} SHARED VAR tel_dtvalcor AS DATE     FORMAT "99/99/9999"        NO-UNDO.
DEF {1} SHARED VAR tel_nrinichq AS INTE     FORMAT "zzz,zzz,z"         NO-UNDO.
DEF {1} SHARED VAR tel_nrfinchq AS INTE     FORMAT "zzz,zzz,z"         NO-UNDO.
DEF {1} SHARED VAR tel_nrtalchq AS INTE     FORMAT "zz,zz9"            NO-UNDO.
DEF {1} SHARED VAR tel_cdsitdtl AS INTE     FORMAT "9"                 NO-UNDO.
DEF {1} SHARED VAR tel_dssitdtl AS CHAR     FORMAT "x(15)"             NO-UNDO.
DEF {1} SHARED VAR tel_tptransa AS INTE     FORMAT "9"                 NO-UNDO.
DEF {1} SHARED VAR tel_dscritic AS CHAR     FORMAT "x(40)"             NO-UNDO.
DEF {1} SHARED VAR tel_dsprovis AS CHAR     FORMAT "x(03)"             NO-UNDO.

DEF {1} SHARED VAR aux_contador AS INTE     FORMAT "99"                NO-UNDO.
DEF {1} SHARED VAR aux_nrdconta AS INTE     FORMAT "zzz,zzz,9"         NO-UNDO.
DEF {1} SHARED VAR aux_nrchqini AS INTE                                NO-UNDO.
DEF {1} SHARED VAR aux_cdhistor AS INTE                                NO-UNDO.
DEF {1} SHARED VAR aux_dtemscor AS DATE     FORMAT "99/99/9999"        NO-UNDO.
DEF {1} SHARED VAR aux_flgerros AS LOGI                                NO-UNDO.
DEF {1} SHARED VAR aux_cddopcao AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR aux_confirma AS CHAR     FORMAT "!(1)"              NO-UNDO.
DEF {1} SHARED VAR aux_dtemscch AS DATE                                NO-UNDO.
DEF {1} SHARED VAR aux_msgretor AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR aux_nmdcampo AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR aux_dsdctitg AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR aux_tplotmov AS INTE                                NO-UNDO.
DEF {1} SHARED VAR aux_stlcmexc LIKE crapcch.tpopelcm                  NO-UNDO.
DEF {1} SHARED VAR aux_stlcmcad LIKE crapcch.tpopelcm                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdctitg LIKE crapass.nrdctitg                  NO-UNDO.

DEF {1} SHARED VAR aux_lcontrat AS LOGI INIT NO                        NO-UNDO.
DEF {1} SHARED VAR aux_nrcheque AS INTE                                NO-UNDO.
DEF {1} SHARED VAR aux_nmendter AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR aux_nmarqimp AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR aux_nmarqpdf AS CHAR                                NO-UNDO.

DEF {1} SHARED VAR aut_flgsenha AS LOGI                                NO-UNDO.
DEF {1} SHARED VAR aut_cdoperad AS CHAR                                NO-UNDO.

DEF {1} SHARED VAR par_pedsenha AS LOGI                                NO-UNDO.

/* Variaveis para impressao */
DEF {1} SHARED VAR tel_dsimprim AS CHAR  FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF {1} SHARED VAR tel_dscancel AS CHAR  FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF {1} SHARED VAR par_flgrodar AS LOGI                                NO-UNDO.
DEF {1} SHARED VAR aux_flgescra AS LOGI                                NO-UNDO.
DEF {1} SHARED VAR aux_dscomand AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR par_flgfirst AS LOGI                                NO-UNDO.
DEF {1} SHARED VAR par_flgcance AS LOGI                                NO-UNDO.

DEF {1} SHARED FRAME f_moldura.
DEF {1} SHARED FRAME f_dctror.
DEF {1} SHARED FRAME f_label.


FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.


FORM glb_cddopcao         AT 02 LABEL "Opcao" AUTO-RETURN
                          HELP "Entre com a opcao desejada (A, C, E ou I)"
                          VALIDATE(CAN-DO("A,C,E,I",glb_cddopcao),
                                                       "014 - Opcao errada.")
    tel_tptransa         AT 15 LABEL "Tipo" AUTO-RETURN
            HELP "Tipo desejado (1-Bloqueio, 2-Contra-ordem/Aviso, 3-Prejuizo)"
                          VALIDATE(tel_tptransa = 1 OR tel_tptransa = 2 OR
                                   tel_tptransa = 3,
                                   "128 - Tipo de transacao errado.")
    SKIP (1)
    tel_nrdconta         AT  2 LABEL "Conta/dv." AUTO-RETURN
                          HELP "Entre com o numero da conta do associado."
                          VALIDATE(tel_nrdconta <> ? OR tel_nrdconta > 0,
                                   "008 - Digito errado.")
    tel_nmprimtl      AT 25 LABEL "Titular"
    SKIP (1)
    tel_cdsitdtl      AT  2 LABEL "Sit. do Titular"
    "-"               AT 20
    tel_dssitdtl      AT 21 NO-LABEL
    tel_dtemscor      AT 37 LABEL "Emissao"  AUTO-RETURN
                          HELP "Entre com a data da emissao da contra-ordem."
    tel_dtvalcor      AT 58 LABEL "Validade" AUTO-RETURN
    SKIP(1)
    "Hist  Banco  Agencia  Conta Cheque    Inicial     Final  Provisoria    "  
    AT 05
    tel_cdhistor      AT 05 NO-LABEL AUTO-RETURN
                       HELP "Entre com o historico ou pressione F7 para listar"
    tel_cdbanchq      AT 12 NO-LABEL AUTO-RETURN
                          HELP "Entre com o codigo do banco."
    tel_cdagechq      AT 19 NO-LABEL
    tel_nrctachq      AT 29 NO-LABEL AUTO-RETURN
                          HELP "Entre com a conta do cheque."
    tel_nrinichq      AT 41 NO-LABEL AUTO-RETURN
                          HELP "Entre com o numero do cheque inicial."
    tel_nrfinchq      AT 51 NO-LABEL AUTO-RETURN
                          HELP "Entre com o numero do cheque final."
    tel_dsprovis      AT 63 NO-LABEL

    WITH ROW 6 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_dctror.


FORM "       Emissao  Conta Cheque   Inicial     Final Historico             "
     AT 2     WITH ROW 12 COLUMN 2 OVERLAY NO-LABEL NO-BOX FRAME f_label.


FORM tt-criticas.cdbanchq AT 02  FORMAT "z,zz9"      LABEL "Banco"       
     tt-criticas.cdagechq AT 09  FORMAT "z,zz9"      LABEL "Agencia"     
     tt-criticas.nrctachq AT 18  FORMAT "zzzz,zz9,9" LABEL "Conta Cheque"
     tt-criticas.nrcheque AT 32  FORMAT "zzz,zz9,9"  LABEL "Cheque"      
     tt-criticas.dscritic AT 43  FORMAT "X(35)"      LABEL "Critica"          
     WITH ROW 14 COLUMN 1 OVERLAY 3 DOWN TITLE " CONTRA-ORDENS NAO EFETUADAS "
          WIDTH 80 FRAME f_erros.

FORM SKIP(1)
     "Contra ordem PROVISORIA ? (S/N)" AT 3
     aux_confirma AT 35
     SKIP(1)
     WITH ROW 14 COLUMN 20 OVERLAY NO-LABELS WIDTH 40 FRAME f_prov_i.
     
FORM SKIP(1)
     "Passar de Provisoria para PERMANENTE ? (S/N)" AT 3
     aux_confirma AT 48
     SKIP(1)
     WITH ROW 14 COLUMN 12 OVERLAY NO-LABELS WIDTH 55 FRAME f_prov_a.

/* ......................................................................... */

