DECLARE texto CLOB := '{
  "paragrafo": [
    {
      "titulo": "Lei 13.709/2018"
    },
    {
      "conteudo": "De acordo com a Lei 13.709/2018 (Lei Geral de Proteção de Dados Pessoais), os dados pessoais e sensíveis dos cooperados poderão ser usados exclusivamente para:\n\n • prestação de serviços oferecidos pela cooperativa;\n • contato com o cooperado para manutenção dos serviços contratados com a cooperativa;\n • atendimentos às solicitações de fiscalização ou auditorias dos órgãos reguladores.\n\nA qualquer momento, o cooperado ou a cooperada pode solicitar quais dados a cooperativa possui e também alterá-los, se necessário. A cooperativa não comercializa ou repassa quaisquer dados com terceiros que não tenham envolvimento direto e necessário com a prestação de seus serviços e, em caso de encerramento de conta, os dados serão excluídos da base de dados assim que todos os débitos e vínculos forem encerrados."
    }
  ]';
BEGIN
  INSERT INTO SEGURO.tbseg_template_documento(tpdocumento,dtinicio,dtfim,obtemplate) VALUES (2,TRUNC(SYSDATE),NULL, texto);
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.put_line(SQLERRM);
  ROLLBACK;
END;
/
