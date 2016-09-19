/* .............................................................................

   Programa: fontes/telefones_juridica.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
............................................................................. */
{includes/var_online.i "new"}

FORM SKIP(1) 
"Operadora  DDD    Numero       Ramal     Setor         Pessoa de Contato" SKIP
"TIM        047    9953-9627      231     PRESIDENCIA   FRED"              SKIP
"TELECOM    047    331-1000       200     COMPRAS       VALMIR"
SKIP(5)
"                  Consultar    Incluir    Alterar    Excluir"
WITH ROW 10 OVERLAY SIDE-LABELS TITLE glb_tldatela CENTERED 
     FRAME f_telefones_juridica.

assign glb_tldatela = "Telefones".
       
DISP WITH FRame f_telefones_juridica.

    
 