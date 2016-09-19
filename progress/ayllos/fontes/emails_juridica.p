/* .............................................................................

   Programa: fontes/emails_juridica.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
............................................................................. */
{includes/var_online.i "new"}

DEF VAR tel_dtaltera AS DATE FORMAT "99/99/9999".

FORM SKIP(1) 
     "Endereco                      Setor         Pessoa de Contato" SKIP
     "hpresidencia@hering.com.br    PRESIDENCIA   FRED"  SKIP
     "www.hering.com.br             COMPRAS       VALMIR"  
     SKIP(5)
     "             Consultar    Incluir    Alterar    Excluir                  "
     WITH ROW 10 OVERLAY SIDE-LABELS TITLE glb_tldatela CENTERED 
          FRAME f_emails_juridica.

assign glb_tldatela = "E_Mails".
       
DISP WITH FRame f_emails_juridica.

    
 