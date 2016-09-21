/* .............................................................................

   Programa: fontes/formacao.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
............................................................................. */
{includes/var_online.i "new"}

def input param tel_nrdconta like crapass.nrdconta.

DEF VAR tel_gresccje  LIKE crapttl.grescola     NO-UNDO.
DEF VAR tel_dsescola  AS CHAR FORMAT "x(15)"    NO-UNDO.
DEF VAR tel_cdfrmttl  LIKE crapttl.cdfrmttl     NO-UNDO.
DEF VAR tel_rsfrmttl  AS CHAR FORMAT "x(15)"    NO-UNDO.
DEF VAR tel_cdnatopc  LIKE crapttl.cdnatopc     NO-UNDO.
DEF VAR tel_rsnatocp AS CHAR FORMAT "x(15)"     NO-UNDO.
DEF VAR tel_cdocpttl LIKE crapttl.cdocpttl      NO-UNDO.   
DEF VAR tel_rsocupa  AS CHAR FORMAT "x(15)"     NO-UNDO.         
DEF VAR tel_tpcttrab LIKE crapttl.tpcttrab      NO-UNDO.
DEF VAR tel_dsctrtab AS CHAR FORMAT "x(15)"     NO-UNDO.     
DEF VAR tel_nmextemp LIKE crapttl.nmextemp      NO-UNDO.
DEF VAR tel_nrcpfemp AS CHAR FORMAT "x(18)"     NO-UNDO.
DEF VAR tel_dsproftl LIKE crapttl.dsproftl      NO-UNDO.
DEF VAR tel_cdnvlcgo LIKE crapttl.cdnvlcgo      NO-UNDO.   
DEF VAR tel_rsnvlcgo AS CHAR FORMAT "x(10)"     NO-UNDO.
DEF VAR tel_nrfonemp LIKE crapttl.nrfonemp      NO-UNDO.
DEF VAR tel_dtadmemp LIKE crapttl.dtadmemp      NO-UNDO.
DEF VAR tel_vlsalari LIKE crapttl.vlsalari      NO-UNDO.
DEF VAR tel_tpdocptl LIKE crapass.tpdocptl      NO-UNDO.
DEF VAR tel_nrdocptl LIKE crapass.nrdocptl      NO-UNDO.
DEF VAR tel_cdoedptl LIKE crapass.cdoedptl      NO-UNDO.
DEF VAR tel_cdufdptl LIKE crapass.cdufdptl      NO-UNDO.
DEF VAR tel_dtemdptl LIKE crapass.dtemdptl      NO-UNDO.
DEF VAR tel_nmcertif AS CHAR FORMAT "x(25)"     NO-UNDO. 

FORM SKIP(1) 
     crapttl.grescola        LABEL "Escolaridade"
                    HELP "Informe o grau de escolaridade ou F7 para listar"
     tel_dsescola            NO-LABEL 
     SKIP
     crapttl.cdfrmttl        LABEL "   Curso Sup"
                             HELP "Informe o curso superior ou F7 para listar"
     tel_rsfrmttl            NO-LABEL
     SKIP
     tel_nmcertif            LABEL " Certificado"
     SKIP
     crapttl.cdnatopc        LABEL "Nat.Ocupacao"
                    HELP "Informe a natureza de ocupacao ou F7 para listar" 
     tel_rsnatocp            NO-LABEL
     SKIP
     SPACE(4)
     crapttl.cdocpttl        HELP "Informe a ocupacao ou F7 para listar"
     tel_rsocupa             NO-LABEL 
     SKIP(1)
     "       Incluir      Alterar"
      WITH ROW 12 OVERLAY SIDE-LABELS TITLE glb_tldatela CENTERED 
          FRAME f_formacao.

FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                   crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.
                   
FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper AND
                   crapttl.nrdconta = tel_nrdconta AND
                   crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

assign glb_tldatela = "Formacao"
       tel_dsescola = "SUP.COMPLETO"    
       tel_rsfrmttl = "CIEN.ECONOMICA"       
       tel_rsnatocp = "APOSENTADO"   
       tel_rsocupa  = "PENSIONISTA".  
       
DISP  crapttl.grescola      tel_dsescola         crapttl.cdfrmttl  
      tel_rsfrmttl          crapttl.cdnatopc     tel_rsnatocp      
      crapttl.cdocpttl      tel_rsocupa          tel_nmcertif
      WITH FRame f_formacao.
      
