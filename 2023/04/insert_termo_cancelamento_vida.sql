DECLARE texto CLOB := '{
    "paragrafo": [
    {
       "conteudo": "TERMO DE CANCELAMENTO SEGURO DE VIDA DIGITAL"
    },
    {
       "conteudo": "Eu, cooperado(a) {NOME}, inscrito(a) no CNPJ/CPF sob o nº {CPF}, titular da conta corrente nº {CONTA}, DECLARO que, por livre e espontânea vontade, solicitei o cancelamento do Seguro de Vida, certificado {NR_CONTRATO} estando ciente e concordando com as seguintes cláusulas e condições:"
    },
    {
       "conteudo": "1. A partir da solicitação do cancelamento do Seguro de Vida, a cobertura permanecerá ativa até o último dia do mês de competência do certificado."
    },
    {
       "conteudo": "1.1. Após o prazo acima mencionado, haverá o encerramento total da cobertura do Seguro de Vida, perdendo o cooperado, todo e qualquer direito aos benefícios a ele atrelados."
    },
    {
       "conteudo": "1.2. Não haverá restituição proporcional dos prêmios pagos, nos termos das Condições Gerais do Seguro, os quais foram aderidos no momento da contratação do Seguro de Vida."
    },
    {
       "conteudo": "2. Caso o Cooperado realize o cancelamento do Seguro de Vida em até 07 (sete) dias, a partir da da data da contratação, terá direito à restituição total do seu prêmio."
    },
    {
       "conteudo": "3. Declaro ter lido e conferido os meus dados, não possuindo nenhuma dúvida e, ainda, nos termos do artigo 29, §5º da Lei 10.931/04 e do §2º da Medida Provisória de nº 2.200-2, reconheço como válida a assinatura deste documento em formato eletrônico, inclusive através da ferramenta digital que não utilize o certificado digital emitido no padrão ICP-Brasil."
    },
    {
       "conteudo": "Documento assinado eletronicamente pelo COOPERADO {NOME}, no dia {DT_CONTRATO}, às {HR_CONTRATO}, IP {IP}, mediante inserção de senha numérica e de segurança."
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
