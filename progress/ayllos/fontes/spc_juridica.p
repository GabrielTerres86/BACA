/* .............................................................................

   Programa: fontes/spc_juridica.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
............................................................................. */
{includes/var_online.i "new"}

DEF VAR tel_nrctremp LIKE crapspc.nrctremp.
DEF VAR tel_dtvencto LIKE crapspc.dtvencto.
DEF VAR tel_vldivida LIKE crapspc.vldivida.
DEF VAR tel_nrctrspc LIKE crapspc.nrctrspc.
DEF VAR tel_dtdbaixa LIKE crapspc.dtdbaixa.
DEF VAR tel_dsoberva LIKE crapspc.dsoberva.
DEF VAR tel_cdoperad LIKE crapspc.cdoperad.
DEF VAR tel_opebaixa LIKE crapspc.opebaixa.
DEF VAR tel_dtinclus LIKE crapspc.dtinclus.

FORM SKIP(1) 
     tel_nrctremp
     SPACE(10)
     tel_nrctrspc LABEL "Ctr.SPC"
     SKIP
     tel_dtvencto LABEL "Vencimento"
     SPACE(9)
     tel_vldivida LABEL "Valor"
     SKIP
     tel_dtinclus LABEL "Inclusao - Data"
     tel_cdoperad LABEL "Operador"
     SKIP
     tel_dtdbaixa LABEL "Baixa - Data"
     SPACE(4)
     tel_opebaixa LABEL "Operador"
     tel_dsoberva
     SKIP(1)
     "                        Incluir      Alterar"
      WITH ROW 12 OVERLAY SIDE-LABELS TITLE glb_tldatela CENTERED 
          FRAME f_spc_juridica.

assign glb_tldatela = "S.P.C".
       
DISP tel_nrctremp   tel_dtvencto   tel_vldivida
     tel_nrctrspc   tel_dtdbaixa   tel_dsoberva
     tel_cdoperad   tel_opebaixa   tel_dtinclus
     WITH FRame f_spc_juridica.

    
 