DECLARE texto CLOB := '{
  "paragrafo": [
    {
      "titulo": "Lei 13.709/2018"
    },
    {
      "conteudo": "De acordo com a Lei 13.709/2018 (Lei Geral de Prote��o de Dados Pessoais), os dados pessoais e sens�veis dos cooperados poder�o ser usados exclusivamente para:\n\n 1. presta��o de servi�os oferecidos pela cooperativa;\n 2. contato com o cooperado para manuten��o dos servi�os contratados com a cooperativa;\n 3. atendimentos �s solicita��es de fiscaliza��o ou auditorias dos �rg�os reguladores.\n\nA qualquer momento, o cooperado ou a cooperada pode solicitar quais dados a cooperativa possui e tamb�m alter�-los, se necess�rio. A cooperativa n�o comercializa ou repassa quaisquer dados com terceiros que n�o tenham envolvimento direto e necess�rio com a presta��o de seus servi�os e, em caso de encerramento de conta, os dados ser�o exclu�dos da base de dados assim que todos os d�bitos e v�nculos forem encerrados."
    }
  ]';
BEGIN
  update SEGURO.tbseg_template_documento set
         obtemplate = texto
   where tpdocumento = 2;  
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.put_line(SQLERRM);
  ROLLBACK;
END;
/