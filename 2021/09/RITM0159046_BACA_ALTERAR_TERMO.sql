declare 
  vr_novo_texto CLOB := '#CENTER##B#TERMO DE ADESÃO A PRESTAÇÃO DE SERVIÇO PARA#/BR#
PAGAMENTO ATRAVÉS DE TROCA ELETRÔNICA DE ARQUIVOS.#/B##/CENTER#
#/BR#
#/BR#
Razão social: #NMPRIMTL##/BR#
CNPJ.............: #NRCPFCGC##/BR#
Endereço......: #DSENDERE##/BR#
PA: #CDAGENCI# #NBSP##NBSP##NBSP# Conta Elegível: #NRDCONTA##/BR#
#/BR#
#/BR#
Confirmamos a sua adesão ao serviço de pagamento através de troca eletrônica de arquivos, de acordo com as Cláusulas e Condições Gerais Aplicáveis ao Contrato de Prestação de Serviço para Pagamento através da Troca Eletrônica de Arquivos, as quais integram este Contrato/Termo de Adesão, para os devidos fins, formando um documento único e indivisível, cujo teor declara conhecer e entender e com o qual concordam, passando a assumir todas as prerrogativas e obrigações que lhes são atribuídas, na condição de #B#COOPERADO#/B#.#/BR#
#/BR#
1 – A prestação regular deste serviço está condicionada a remessa pelo #B#COOPERADO#/B# de apenas títulos não vencidos. Havendo envio de boletos vencidos de outras instituições financeiras, o pagamento será rejeitado e encaminhado através do arquivo de retorno.#/BR#
#/BR#
2 – O #B#COOPERADO#/B# compromete-se a manter recursos disponíveis para a efetivação de todos os pagamentos enviados através de arquivo, bem como remete-los à #B#COOPERATIVA#/B# com, no mínimo, 01 (um) dia antes da data do vencimento dos boletos.#/BR#
#/BR#
3 – Para efetivação dos pagamentos, os arquivos deverão ser enviados pelo #B#COOPERADO#/B# até o horário limite estabelecido pela #B#COOPERATIVA#/B#. Os arquivos enviados após aquele horário serão rejeitados.
#/BR#
4 - O(a) Emitente/Cooperado(a)autoriza o pagamento através de débito automático, na conta corrente acima indicada, por tempo indeterminado, a cada mês, para pagamento do valor correspondente ao produto ora aderido e decorrentes de tarifas e demais despesas previstas.
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