DECLARE texto CLOB := '{
    "paragrafo": [
    {
       "conteudo": "TERMO DO SEGURO VIDA"
    },
    {
       "conteudo": "1. Ao finalizar esta jornada, o Cooperado está solicitando a contratação do Seguro de Vida – Proposta nº {NR_CONTRATO}, nos termos e condições apresentadas na simulação realizada por meio do acesso aos Canais Digitais."
    },
    {
       "conteudo": "2. As Condições Gerais do Seguro poderão ser visualizadas no site da seguradora contratada."
    },
    {
       "conteudo": "3. O Cooperado declara e reconhece que:"
    },
    {
       "conteudo": "3.1. É o primeiro titular da conta corrente indicada na simulação e utilizada para contratação deste seguro;"
    },
    {
       "conteudo": "3.2. Todos os dados fornecidos na simulação e contratação do seguro são verídicos;"
    },
	{
       "conteudo": "3.3. A emissão da apólice deste seguro será realizada em seu nome, conforme as opções selecionadas durante a simulação e contratação;"
    },
    {
       "conteudo": "3.4. É o único e exclusivo responsável pela seleção e preenchimento de todos os dados/informações necessários à efetivação do seguro;"
    },
    {
       "conteudo": "3.5. O não pagamento da primeira parcela ou, se for o caso, da parcela única do prêmio, implicará no cancelamento automático e sem qualquer aviso da apólice gerada, desde o início da sua vigência;"
    },
    {
       "conteudo": "3.6. A contratação desse seguro foi realizada por meio de Cana Digital escolhido por ele;"
    },
    {
       "conteudo": "3.7. O valor da remuneração pela venda desse seguro foi informado durante a contratação do seguro, o qual estava acompanhado dos respectivos valores de prêmio comercial."
    },
    {
       "conteudo": "4. A Cooperativa não será responsabilizada por eventual falha ou erro na seleção e preenchimento dos dados/informações realizadas pelo Cooperado necessários à efetivação do seguro."
    },
    {
       "conteudo": "5. A apólice do seguro será enviada ao Cooperado através do e-mail informado no momento da solicitação do seguro (dados de contato), após a confirmação da contratação pela Seguradora. A vigência do seguro iniciará às 00hrs do dia do recebimento da confirmação. Para solicitação dos Serviços de Assistência Funeral ou em caso de Sinistro, você poderá contatar a Seguradora através dos números informados na Apólice."
    },
	{
       "conteudo": "5.1. O período de carência para acionamento do Seguro contrato deve ser consultado na Proposta apresentada ao Cooperado durante a contratação."
    },
    {
       "conteudo": "6. A SUSEP - Superintendência de Seguros Privados - é a Autarquia Federal responsável pela fiscalização, normatização e controle dos mercados de seguro, previdência complementar aberta, capitalização, resseguro e corretagem de seguros."
    },
    {
       "conteudo": "7. As condições contratuais/regulamentos deste produto protocolizadas por esta Companhia Seguradora junto à SUSEP também poderão ser consultados pelo endereço eletrônico www.susep.gov.br/menu/servicos-ao-cidadao/sistema-de-consulta-publica-de-produtos, por meio do número do processo constante da apólice/proposta."
    },
    {
       "conteudo": "8. O Cooperado poderá consultar a situação cadastral de seu corretor de seguros, no site www.susep.gov.br, por meio do número de seu registro na SUSEP, nome completo, CNPJ ou CPF. O telefone GRATUITO da Susep para Atendimento Público é 0800 021 8484."
    },
    {
       "conteudo": "9. Em atendimento à Lei 12.741/12, incidem as alíquotas de 0,65% de PIS/Pasep e de 4% de COFINS sobre os prêmios de seguros, deduzidos do estabelecido em legislação específica."
    },
    {
       "conteudo": "10. O Cooperado está ciente que a Cooperativa e o Sistema Ailos realizam o tratamento de seus dados pessoais de acordo com a Declaração de Privacidade disponibilizada no site da Cooperativa, assim como autoriza e tem ciência de que: (i) a Cooperativa realiza consultas de informações em seu nome, conforme disposto na Cláusulas e Condições Gerais Aplicáveis à Conta Corrente (disponíveis no site da Cooperativa); (ii) compartilha seus dados pessoais, bem como dados referentes ao produto, de acordo com as bases legais previstas na LGPD, principalmente com a(s) seguradora(s) contratadas e vinculadas a esta proposta, a fim de permitir sua devida contratação."
    },
    {
       "conteudo": "11. O Cooperado declara, por fim, ter lido previamente este documento, conferido os dados e não possuir nenhuma dúvida com relação a quaisquer cláusulas e ainda, nos termos do §5º, Art. 29 da Lei 10.931/04 e do §2º da Medida Provisória de nº 2.200-2, reconhece como válida a assinatura deste contrato em formato eletrônico, inclusive através da ferramenta digital que não utilize o certificado digital emitido no padrão ICP – Brasil."
    },	
    {
       "conteudo": "Documento assinado eletronicamente pelo COOPERADO {NOME} inscrito no CPF {CPF}, no dia {DT_CONTRATO}, as {HR_CONTRATO}, IP {IP}, mediante inserção de senha numéricas e de segurança."
    }
  ]
}';
BEGIN
  UPDATE SEGURO.tbseg_template_documento SET dtfim = trunc(sysdate) WHERE tpdocumento = 2;
  INSERT INTO SEGURO.tbseg_template_documento(tpdocumento,dtinicio,dtfim,obtemplate) VALUES (2,TRUNC(SYSDATE) + 1,NULL, texto);
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.put_line(SQLERRM);
  ROLLBACK;
END;
/