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
      "conteudo":"{NOME}, inscrito (a) no CNPJ/CPF sob o nº {CPF}, com endereço na Rua {ENDERECO}, da cidade de {CIDADE} CEP {CEP}, titular da conta corrente nº {CONTA}."
    },
    {
      "conteudo":"Declaro que, por livre e espontânea vontade solicito o cancelamento do Seguro Prestamista, apólice nº {APOLICE}, referente ao contrato nº {NRPROPOSTA}."
    },
    {
      "conteudo":"Fico ciente e concordo que:"
    },
    {
      "conteudo":"1. O valor referente ao seguro será restituído através de um crédito na conta acima mencionada, em parcela única, depositado pela Seguradora, nos termos das Condições Gerais do Seguro, que foram aderidos no momento da contratação do seguro."
    },
    {
      "conteudo":"2. Caso valor do seguro tenha sido financiado junto com o crédito, as parcelas continuarão com os mesmos valores e com o mesmo prazo fixados na Cédula de Crédito Bancário."
    },
    {
      "conteudo":"3. Nada mais tenho a reclamar sobre os valores do crédito contratado."
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
      "conteudo":"Declaro ter lido previamente este documento, conferindo os meus dados e não possuir nenhuma dúvida com relação a quaisquer clausulas e ainda, nos termos do §5°, Art. 29 da Lei 10.931/04 e do §2° da Medida Provisória de n° 2.200-2, reconheço como válida a assinatura deste contrato em formato eletrônico, inclusive através da ferramenta digital que não utiliza o certificado digital emitido no padrão ICP – Brasil "
    },
    {
      "conteudo":"Assinado eletronicamente pelo CONTRATANTE {NOME}, no dia {DATA}, às {HORA}, IP {IP}, mediante aposição de senha numérica e letras de segurança. "
    }
  ]
}   ');
  COMMIT;
END;
/
  
