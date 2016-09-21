/* .............................................................................

   Programa: Includes/Sititg.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Setembro/2004.                  Ultima atualizacao: 29/12/2008

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Atualizar situacao da conta de integracao.

   Alteracoes: 29/12/2008 - Alteradas as situacoes (Gabriel). 
............................................................................*/    
   IF   crapass.flgctitg = 2   THEN
        tel_dssititg = "Ativa".
   ELSE
   IF   crapass.flgctitg = 3   THEN
        tel_dssititg = "Inativa".
   ELSE
   IF   crapass.nrdctitg <> ""   THEN
        tel_dssititg = "Em Proc".
   ELSE
        tel_dssititg = "".

/*..........................................................................*/    