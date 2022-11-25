BEGIN
  INSERT INTO SEGURO.TBSEG_TEMPLATE_DOCUMENTO(TPDOCUMENTO,DTINICIO,OBTEMPLATE) VALUES (4,TRUNC(SYSDATE),'{
  "paragrafo": 
  [
    {
      "conteudo":"TERMO DE CANCELAMENTO DO SEGURO PRESTAMISTA"
    },
    {
      "conteudo":"COOPERADO (A):"
    },
    {
      "conteudo":"{NOME}, inscrito (a) no CNPJ/CPF sob o n� {CPF}, com endere�o na Rua {ENDERECO}, da cidade de {CIDADE} CEP {CEP}, titular da conta corrente n� {CONTA}."
    },
    {
      "conteudo":"Declaro que, por livre e espont�nea vontade solicito o cancelamento do Seguro Prestamista, ap�lice n� {APOLICE}, referente ao contrato n� {NRPROPOSTA}."
    },
    {
      "conteudo":"Fico ciente e concordo que:"
    },
    {
      "conteudo":"1. O valor referente ao seguro ser� restitu�do atrav�s de um cr�dito na conta acima mencionada, em parcela �nica, depositado pela Seguradora, nos termos das Condi��es Gerais do Seguro, que foram aderidos no momento da contrata��o do seguro."
    },
    {
      "conteudo":"2. Caso valor do seguro tenha sido financiado junto com o cr�dito, as parcelas continuar�o com os mesmos valores e com o mesmo prazo fixados na C�dula de Cr�dito Banc�rio."
    },
    {
      "conteudo":"3. Nada mais tenho a reclamar sobre os valores do cr�dito contratado."
    },
    {
      "conteudo":"Blumenau, {DATAEXTENSO}."
    },
    {
      "conteudo":"_________________________"
    },
    {
      "conteudo":"COOPERADO {NOME}"
    },
    {
      "conteudo":"Declaro ter lido previamente este documento, conferindo os meus dados e n�o possuir nenhuma d�vida com rela��o a quaisquer clausulas e ainda, nos termos do �5�, Art. 29 da Lei 10.931/04 e do �2� da Medida Provis�ria de n� 2.200-2, reconhe�o como v�lida a assinatura deste contrato em formato eletr�nico, inclusive atrav�s da ferramenta digital que n�o utiliza o certificado digital emitido no padr�o ICP � Brasil "
    },
    {
      "conteudo":"Assinado eletronicamente pelo CONTRATANTE {NOME}, no dia {DATA}, �s {HORA}, IP {IP}, mediante aposi��o de senha num�rica e letras de seguran�a. "
    }
  ]
}   ');
  COMMIT;
END;
/
  
