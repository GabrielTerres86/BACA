/* .............................................................................

   Programa: fontes/cliente_sfn.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
............................................................................. */

{includes/var_online.i "new"}
FORM 
     skip(1)
     "Abertura C/C: 01/01/1995" SKIP(1)   
     "Cod. Banco:     1" SKIP(1)
     "Agencia Banco:   150        Conta C/C: 0123456789 DV: 0" SKIP(1) 
     "Nome Instituicao Financeira:" SKIP(2)
     "                  Dados    Emissao"
     WITH ROW 9 OVERLAY SIDE-LABELS TITLE glb_tldatela CENTERED 
     FRAME f_cliente_sfn.

assign glb_tldatela = "CLIENTE FINANCEIRO NACIONAL".

DISP WITH FRame f_cliente_sfn.  


 