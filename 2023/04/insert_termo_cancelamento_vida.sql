DECLARE texto CLOB := '{
    "paragrafo": [
    {
       "conteudo": "TERMO DE CANCELAMENTO SEGURO DE VIDA DIGITAL"
    },
    {
       "conteudo": "Eu, cooperado(a) {NOME}, inscrito(a) no CNPJ/CPF sob o n� {CPF}, titular da conta corrente n� {CONTA}, DECLARO que, por livre e espont�nea vontade, solicitei o cancelamento do Seguro de Vida, certificado {NR_CONTRATO} estando ciente e concordando com as seguintes cl�usulas e condi��es:"
    },
    {
       "conteudo": "1. A partir da solicita��o do cancelamento do Seguro de Vida, a cobertura permanecer� ativa at� o �ltimo dia do m�s de compet�ncia do certificado."
    },
    {
       "conteudo": "1.1. Ap�s o prazo acima mencionado, haver� o encerramento total da cobertura do Seguro de Vida, perdendo o cooperado, todo e qualquer direito aos benef�cios a ele atrelados."
    },
    {
       "conteudo": "1.2. N�o haver� restitui��o proporcional dos pr�mios pagos, nos termos das Condi��es Gerais do Seguro, os quais foram aderidos no momento da contrata��o do Seguro de Vida."
    },
    {
       "conteudo": "2. Caso o Cooperado realize o cancelamento do Seguro de Vida em at� 07 (sete) dias, a partir da da data da contrata��o, ter� direito � restitui��o total do seu pr�mio."
    },
    {
       "conteudo": "3. Declaro ter lido e conferido os meus dados, n�o possuindo nenhuma d�vida e, ainda, nos termos do artigo 29, �5� da Lei 10.931/04 e do �2� da Medida Provis�ria de n� 2.200-2, reconhe�o como v�lida a assinatura deste documento em formato eletr�nico, inclusive atrav�s da ferramenta digital que n�o utilize o certificado digital emitido no padr�o ICP-Brasil."
    },
    {
       "conteudo": "Documento assinado eletronicamente pelo COOPERADO {NOME}, no dia {DT_CONTRATO}, �s {HR_CONTRATO}, IP {IP}, mediante inser��o de senha num�rica e de seguran�a."
    }
  ]
}';
BEGIN
  INSERT INTO SEGURO.tbseg_template_documento(tpdocumento,dtinicio,dtfim,obtemplate) VALUES (6,TRUNC(SYSDATE),NULL, texto);
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.put_line(SQLERRM);
  ROLLBACK;
END;
/
