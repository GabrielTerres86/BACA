DECLARE texto CLOB := '{  
    "paragrafo": [
      {
        "conteudo":"TERMO DO SEGURO RESIDENCIAL"
      },
      {
        "conteudo":"1.       Ao aceitar essas CONDIÇÕES, o COOPERADO solicita a contratação do seguro Residencial, nos termos e condições apresentadas na simulação realizada por meio do acesso ao aplicativo Ailos"
      },
      {
        "conteudo":"2.       As Condições Gerais do Seguro, bem como as condições da Assistência Residencial, poderão ser visualizadas no site da COOPERATIVA"
      },
      {
        "conteudo":"3.       O COOPERADO declara e reconhece que:"
      },
      {
        "conteudo":"3.1.      É o primeiro titular da conta corrente indicada na simulação e utilizada para contratação deste seguro;"
      },
      {
        "conteudo":"3.2.      Todos os dados fornecidos na simulação e contratação do seguro são verídicos;"
      },
      {
        "conteudo":"3.3.      A emissão da apólice deste seguro será realizada em seu nome, conforme as opções selecionadas durante a simulação e contratação;"
      },
      {
        "conteudo":"3.4.      É o único e exclusivo responsável pela seleção e preenchimento de todos os dados/informações necessários à efetivação do seguro, especialmente quanto as condições do imóvel objeto deste seguro;"
      },
      {
        "conteudo":"3.5.      O não pagamento da primeira parcela ou, se for o caso, da parcela única do prêmio, implicará no cancelamento automático e sem qualquer aviso da apólice gerada, desde o início da sua vigência;"
      },
      {
        "conteudo":"3.6.  A contratação desse seguro foi realizada por meio digital, à sua escolha;"
      },
      {
        "conteudo":"3.7.      Todos os atos praticados mediante aceite, aposição de senhas numéricas, senhas alfanuméricas, biometria elegível dentre outras formas previstas pela COOPERATIVA serão registrados e arquivados em meios eletrônicos e magnéticos, sendo reconhecidos como manifestação de sua vontade, para todos os fins de direito como assinatura digital, sendo considerados válidos, verdadeiros e processados por meios seguros e constituirão meio eficaz e prova inequívoca das transações realizadas."
      },
      {
        "conteudo":"3.8 O valor da remuneração pela venda desse seguro foi informado durante a contratação do seguro, o qual estava acompanhado dos respectivos valores de prêmio comercial."
      },
      {
        "conteudo":"4.       A COOPERATIVA não será responsabilizada por eventual falha ou erro na seleção e preenchimento dos dados/informações realizadas pelo COOPERADO, necessários à efetivação do seguro, especialmente quanto as condições do imóvel objeto deste seguro."
      },    
      {
        "conteudo":"5.       A apólice do seguro será enviada ao COOPERADO, via e-mail informado no momento da solicitação do seguro (dados de contato), após a confirmação pela Seguradora. A vigência do seguro iniciará às 00hrs do dia do recebimento da confirmação. Para solicitação dos Serviços de Assistência ou em caso de Sinistro, você poderá contatar a Seguradora através dos números informados na Apólice. NOTA: Período de carência para utilização dos serviços de Assistência - 5 dias a contar do recebimento da apólice."
      },   
      {
        "conteudo":"6.       Os valores contidos na apólice são fixos, não sujeitos a qualquer atualização monetária em seus valores e a alíquota do IOF é estabelecida nos termos da legislação vigente."
      },    
      {
        "conteudo":"7.    As Condições Gerais deste seguro, os Serviços de Assistência de seu perfil, seguirão para o COOPERADO via e-mail cadastrado na proposta."
      },
      {
        "conteudo":"8.       A SUSEP - Superintendência de Seguros Privados - é a Autarquia Federal responsável pela fiscalização, normatização e controle dos mercados de seguro, previdência complementar aberta, capitalização, resseguro e corretagem de seguros."
      },
      {
        "conteudo":"9.    As condições contratuais/regulamentos deste produto protocolizadas por esta Companhia Seguradora junto à SUSEP também poderão ser consultados pelo endereço eletrônico www.susep.gov.br/menu/servicos-ao-cidadao/sistema-de-consulta-publica-de-produtos, por meio do número do processo constante da apólice/proposta."
      },
      {
        "conteudo":"10.    O COOPERADO poderá consultar a situação cadastral de seu corretor de seguros, no site www.susep.gov.br, por meio do número de seu registro na SUSEP, nome completo, CNPJ ou CPF. O telefone GRATUITO da Susep para Atendimento Público é 0800 021 8484."
      },
      {
        "conteudo":"11.    Em atendimento à Lei 12.741/12, incidem as alíquotas de 0,65% de PIS/Pasep e de 4% de COFINS sobre os prêmios de seguros, deduzidos do estabelecido em legislação específica."
      },
      {
        "conteudo":"12. O COOPERADO  está ciente e concorda que a COOPERATIVA e o SISTEMA AILOS realizam o tratamento de meus dados pessoais de acordo com a Declaração de Privacidade disponibilizada no site da Cooperativa, assim como autoriza que: (i) a Cooperativa realize consultas de informações em seu nome, conforme disposto na Cláusulas e Condições Gerais Aplicáveis à Conta Corrente (disponíveis no site da Cooperativa); (ii) compartilhe seus dados de acordo com as bases legais previstas na LGPD, principalmente com a(s) seguradora(s) contratadas e vinculadas a esta proposta."
      },
      {
        "conteudo":"13. Assinado eletronicamente pelo {NOME}, inscrito no CPF de nº {CPF} no dia {DT_CONTRATO}, as {HR_CONTRATO}, através do Aplicativo Ailos ou Conta Online, IP nº {IP} mediante senha digitada."
      }
    ]
  }';
BEGIN
  INSERT INTO SEGURO.tbseg_contrato(PRODUTO,DT_INICIO,DT_FIM,CONTRATO) VALUES (1,TRUNC(SYSDATE),NULL, texto);
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.put_line(SQLERRM);
  ROLLBACK;
END;
/