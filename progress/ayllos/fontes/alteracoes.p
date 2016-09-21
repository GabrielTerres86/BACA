/* .............................................................................

   Programa: fontes/alteracoes.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
............................................................................. */

{includes/var_online.i "new"}

DEF input PARAM tel_nrdconta LIKE crapass.nrdconta.

DEF VAR tel_dtaltera AS DATE FORMAT "99/99/9999".

FORM SKIP(1) 
     crapass.dtatipct  LABEL "     Tipo Conta" FORMAT "99/99/9999"
     crapass.dtultlcr  LABEL "  Lim.Cred." FORMAT "99/99/9999"
     SKIP
     crapass.dtasitct  LABEL " Situacao Conta" FORMAT "99/99/9999"
     tel_dtaltera       LABEL "     Recad." FORMAT "99/99/9999"
     SKIP
     crapass.dtultalt  LABEL "Ultima Atualiz."  FORMAT "99/99/9999"
     SKIP(1)
     WITH ROW 15 OVERLAY SIDE-LABELS TITLE glb_tldatela CENTERED 
          FRAME f_alteracoes.

FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND 
                   crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

ASSIGN glb_tldatela = "Ult.Alteracoes"
       tel_dtaltera = 07/19/2004.
       
DISP crapass.dtatipct    crapass.dtultlcr 
     crapass.dtasitct    tel_dtaltera      crapass.dtultalt
     WITH FRame f_alteracoes.

