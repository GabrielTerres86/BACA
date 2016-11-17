/*........................................................................

  Programa: Fontes/sitpgd.p
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Gabriel
  Data    : Maio/2009                          Ultima atualizacao: 16/04/2012
          
  Dados referentes ao programa:
            
  Frequencia: Diario (Online).
  Objetivo  : Efetuar conexao ao banco PROGRID e GENERICO, chamar o 
              fontes/sitpgdp.p
              
  Alteracoes: 16/04/2012 - Retirada chamada para banco banco generico (Elton).
............................................................................*/

{ includes/gg0000.i  }

         
IF   NOT f_conecta_progrid()  THEN
     DO:
         MESSAGE "Erro! Nao foi possivel conectar ao banco PROGRID.".
         RETURN.
     END.

RUN fontes/sitpgdp.p.

/* Desconecta do banco Progrid */
RUN p_desconecta_progrid.

/*............................................................................*/
