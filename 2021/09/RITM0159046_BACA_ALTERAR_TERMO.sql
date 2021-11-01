declare 
  vr_novo_texto CLOB := '#CENTER##B#TERMO DE ADES�O A PRESTA��O DE SERVI�O PARA#/BR#
PAGAMENTO ATRAV�S DE TROCA ELETR�NICA DE ARQUIVOS.#/B##/CENTER#
#/BR#
#/BR#
Raz�o social: #NMPRIMTL##/BR#
CNPJ.............: #NRCPFCGC##/BR#
Endere�o......: #DSENDERE##/BR#
PA: #CDAGENCI# #NBSP##NBSP##NBSP# Conta Eleg�vel: #NRDCONTA##/BR#
#/BR#
#/BR#
Confirmamos a sua ades�o ao servi�o de pagamento atrav�s de troca eletr�nica de arquivos, de acordo com as Cl�usulas e Condi��es Gerais Aplic�veis ao Contrato de Presta��o de Servi�o para Pagamento atrav�s da Troca Eletr�nica de Arquivos, as quais integram este Contrato/Termo de Ades�o, para os devidos fins, formando um documento �nico e indivis�vel, cujo teor declara conhecer e entender e com o qual concordam, passando a assumir todas as prerrogativas e obriga��es que lhes s�o atribu�das, na condi��o de #B#COOPERADO#/B#.#/BR#
#/BR#
1 � A presta��o regular deste servi�o est� condicionada a remessa pelo #B#COOPERADO#/B# de apenas t�tulos n�o vencidos. Havendo envio de boletos vencidos de outras institui��es financeiras, o pagamento ser� rejeitado e encaminhado atrav�s do arquivo de retorno.#/BR#
#/BR#
2 � O #B#COOPERADO#/B# compromete-se a manter recursos dispon�veis para a efetiva��o de todos os pagamentos enviados atrav�s de arquivo, bem como remete-los � #B#COOPERATIVA#/B# com, no m�nimo, 01 (um) dia antes da data do vencimento dos boletos.#/BR#
#/BR#
3 � Para efetiva��o dos pagamentos, os arquivos dever�o ser enviados pelo #B#COOPERADO#/B# at� o hor�rio limite estabelecido pela #B#COOPERATIVA#/B#. Os arquivos enviados ap�s aquele hor�rio ser�o rejeitados.
#/BR#
4 - O(a) Emitente/Cooperado(a)autoriza o pagamento atrav�s de d�bito autom�tico, na conta corrente acima indicada, por tempo indeterminado, a cada m�s, para pagamento do valor correspondente ao produto ora aderido e decorrentes de tarifas e demais despesas previstas.
#/BR#
#/BR#
#/BR#
#/BR#
#NMEXTCOP# - #NMRESCOP#
#/BR#
#DATA#';

 CURSOR cr_craptab IS 
   SELECT ROWID 
		 FROM craptab
    WHERE UPPER(craptab.nmsistem) = 'CRED'
      AND UPPER(craptab.tptabela) = 'GENERI' 
      AND UPPER(craptab.cdacesso) = 'TAPGTFPA';
begin
  -- Test statements here
  FOR tab IN cr_craptab LOOP
		  UPDATE craptab 
			   SET dstextab = vr_novo_texto
			 WHERE ROWID = tab.rowid;
	END LOOP;
	COMMIT;
end;