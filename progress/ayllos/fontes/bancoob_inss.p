/*.............................................................................

   Programa: fontes/bancoob_inss.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson/Egolf
   Data    : Novembro/2007                         Ultima alteracao: 01/12/2008
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Validacao do cartao e senha para pagamento do INSS via BANCOOB.

   Alteracoes: 27/08/2008 - Receber e passar o codigo da Agencia Bancoob para
                            montagem do diretorio (Evandro).

               01/12/2008 - Alterado IP 172.18.1.6 para 172.17.2.253 (Edson).

............................................................................. */

DEFINE INPUT  PARAM p-Cartao  AS CHARACTER  NO-UNDO.
DEFINE INPUT  PARAM p-Senha   AS CHARACTER  NO-UNDO.
DEFINE INPUT  PARAM p-Agebcb  AS INTEGER    NO-UNDO.
DEFINE OUTPUT PARAM p-Status  AS INTEGER    NO-UNDO.
DEFINE OUTPUT PARAM p-Critica AS CHARACTER  NO-UNDO.

DEFINE VARIABLE p-DtHor       AS CHARACTER  NO-UNDO.
DEFINE VARIABLE p-Agencia     AS INTEGER    NO-UNDO.
DEFINE VARIABLE p-Conta       AS DECIMAL    NO-UNDO.
DEFINE VARIABLE p-Mac         AS CHARACTER  NO-UNDO.

DEFINE VARIABLE h-inss        AS HANDLE     NO-UNDO.

CREATE SERVER h-inss.

/* Edson/Evandro - Firewall Interno */
h-inss:CONNECT("-AppService inss -H 172.17.2.253").
 
/*** Evandro - Maquina Virtual (micro do Edson) ***
h-inss:CONNECT("-H 172.18.2.44 -AppService inss"). 
***/

IF   h-inss:CONNECTED()   THEN 
     DO:
         RUN valsenha.p ON h-inss (INPUT  p-Cartao,
                                   INPUT  p-Senha,
                                   INPUT  p-Agebcb,
                                   OUTPUT p-Status,
                                   OUTPUT p-DtHor,
                                   OUTPUT p-Agencia,
                                   OUTPUT p-Conta,
                                   OUTPUT p-Mac).

         h-inss:DISCONNECT().
     END.
ELSE 
     p-Status = 999.

/*message p-Status p-DtHor p-Agencia p-Conta p-Mac.*/

IF   VALID-HANDLE(h-inss)   THEN
     DELETE OBJECT h-inss.
     
CASE p-Status:
     WHEN  00 THEN p-Critica = "OK".
     WHEN  01 THEN p-Critica = "Erro desconhecido.".
     WHEN  02 THEN p-Critica = "Senha invalida.".
     WHEN  03 THEN p-Critica = "Tabela invalida, erro de leitura.".
     WHEN  04 THEN p-Critica = "Tabela invalida, data de validade encerrada.".
     WHEN  05 THEN p-Critica = "Operacao abortada.".
     WHEN  06 THEN p-Critica = "Cartao nao reconhecido.".
     WHEN  07 THEN p-Critica = "Cartao nao cadastrado.".
     WHEN  08 THEN p-Critica = "Erro nos parametros.".
     WHEN  09 THEN p-Critica = "Erro no pinpad.".
     WHEN  13 THEN p-Critica = "Tabela nao localizada.".
     WHEN  17 THEN p-Critica = "Cartao com data vencida.".
     WHEN  19 THEN p-Critica = "Tipo de pinpad invalido.".
     WHEN  23 THEN p-Critica = "Localizou tabela mas campo nao numerico.".
     WHEN  27 THEN p-Critica = "Erro no cartao.".
     WHEN  29 THEN p-Critica = "Parametros da serial invalidos.".
     WHEN  33 THEN p-Critica = "Erro ao tentar abrir a tabela.".
     WHEN  39 THEN p-Critica = "Erro na abertura da porta serial.".
     WHEN  43 THEN p-Critica = "Erro 1 de leitura na tabela.".
     WHEN  49 THEN p-Critica = "Erro na inicializacao do pinpad.".
     WHEN  53 THEN p-Critica = "Erro de pesquisa.".
     WHEN  59 THEN p-Critica = "Erro na leitura do status do pinpad.".
     WHEN  63 THEN p-Critica = "Erro 2 de leitura na tabela.".
     WHEN  69 THEN p-Critica = "Erro 1 na leitura da trilha do cartao no " +
                               "pinpad.".
     WHEN  73 THEN p-Critica = "Erro de formato do header ou trailer.".
     WHEN  79 THEN p-Critica = "Erro 2 na leitura da trilha do cartao no " +
                               "pinpad.".
     WHEN  83 THEN p-Critica = "Erro de tamanho do arquivo.".
     WHEN  89 THEN p-Critica = "Erro nos parametros do pinpad.".
     WHEN  93 THEN p-Critica = "Erro no tamanho do campo NSQ.".
     WHEN  99 THEN p-Critica = "Erro de leitura da senha no pinpad.".
     WHEN 999 THEN p-Critica = "Erro de conexao com o APPServer.".
     OTHERWISE     p-Critica = "Erro generico.".
END CASE.

/* .......................................................................... */
