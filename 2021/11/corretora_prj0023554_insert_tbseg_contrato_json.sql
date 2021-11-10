DECLARE texto CLOB := '{  
    "paragrafo": [
      {
        "conteudo":"TERMO DO SEGURO RESIDENCIAL"
      },
      {
        "conteudo":"1.       Ao aceitar essas CONDI��ES, o COOPERADO solicita a contrata��o do seguro Residencial, nos termos e condi��es apresentadas na simula��o realizada por meio do acesso ao aplicativo Ailos"
      },
      {
        "conteudo":"2.       As Condi��es Gerais do Seguro, bem como as condi��es da Assist�ncia Residencial, poder�o ser visualizadas no site da COOPERATIVA"
      },
      {
        "conteudo":"3.       O COOPERADO declara e reconhece que:"
      },
      {
        "conteudo":"3.1.      � o primeiro titular da conta corrente indicada na simula��o e utilizada para contrata��o deste seguro;"
      },
      {
        "conteudo":"3.2.      Todos os dados fornecidos na simula��o e contrata��o do seguro s�o ver�dicos;"
      },
      {
        "conteudo":"3.3.      A emiss�o da ap�lice deste seguro ser� realizada em seu nome, conforme as op��es selecionadas durante a simula��o e contrata��o;"
      },
      {
        "conteudo":"3.4.      � o �nico e exclusivo respons�vel pela sele��o e preenchimento de todos os dados/informa��es necess�rios � efetiva��o do seguro, especialmente quanto as condi��es do im�vel objeto deste seguro;"
      },
      {
        "conteudo":"3.5.      O n�o pagamento da primeira parcela ou, se for o caso, da parcela �nica do pr�mio, implicar� no cancelamento autom�tico e sem qualquer aviso da ap�lice gerada, desde o in�cio da sua vig�ncia;"
      },
      {
        "conteudo":"3.6.  A contrata��o desse seguro foi realizada por meio digital, � sua escolha;"
      },
      {
        "conteudo":"3.7.      Todos os atos praticados mediante aceite, aposi��o de senhas num�ricas, senhas alfanum�ricas, biometria eleg�vel dentre outras formas previstas pela COOPERATIVA ser�o registrados e arquivados em meios eletr�nicos e magn�ticos, sendo reconhecidos como manifesta��o de sua vontade, para todos os fins de direito como assinatura digital, sendo considerados v�lidos, verdadeiros e processados por meios seguros e constituir�o meio eficaz e prova inequ�voca das transa��es realizadas."
      },
      {
        "conteudo":"3.8 O valor da remunera��o pela venda desse seguro foi informado durante a contrata��o do seguro, o qual estava acompanhado dos respectivos valores de pr�mio comercial."
      },
      {
        "conteudo":"4.       A COOPERATIVA n�o ser� responsabilizada por eventual falha ou erro na sele��o e preenchimento dos dados/informa��es realizadas pelo COOPERADO, necess�rios � efetiva��o do seguro, especialmente quanto as condi��es do im�vel objeto deste seguro."
      },    
      {
        "conteudo":"5.       A ap�lice do seguro ser� enviada ao COOPERADO, via e-mail informado no momento da solicita��o do seguro (dados de contato), ap�s a confirma��o pela Seguradora. A vig�ncia do seguro iniciar� �s 00hrs do dia do recebimento da confirma��o. Para solicita��o dos Servi�os de Assist�ncia ou em caso de Sinistro, voc� poder� contatar a Seguradora atrav�s dos n�meros informados na Ap�lice. NOTA: Per�odo de car�ncia para utiliza��o dos servi�os de Assist�ncia - 5 dias a contar do recebimento da ap�lice."
      },   
      {
        "conteudo":"6.       Os valores contidos na ap�lice s�o fixos, n�o sujeitos a qualquer atualiza��o monet�ria em seus valores e a al�quota do IOF � estabelecida nos termos da legisla��o vigente."
      },    
      {
        "conteudo":"7.    As Condi��es Gerais deste seguro, os Servi�os de Assist�ncia de seu perfil, seguir�o para o COOPERADO via e-mail cadastrado na proposta."
      },
      {
        "conteudo":"8.       A SUSEP - Superintend�ncia de Seguros Privados - � a Autarquia Federal respons�vel pela fiscaliza��o, normatiza��o e controle dos mercados de seguro, previd�ncia complementar aberta, capitaliza��o, resseguro e corretagem de seguros."
      },
      {
        "conteudo":"9.    As condi��es contratuais/regulamentos deste produto protocolizadas por esta Companhia Seguradora junto � SUSEP tamb�m poder�o ser consultados pelo endere�o eletr�nico www.susep.gov.br/menu/servicos-ao-cidadao/sistema-de-consulta-publica-de-produtos, por meio do n�mero do processo constante da ap�lice/proposta."
      },
      {
        "conteudo":"10.    O COOPERADO poder� consultar a situa��o cadastral de seu corretor de seguros, no site www.susep.gov.br, por meio do n�mero de seu registro na SUSEP, nome completo, CNPJ ou CPF. O telefone GRATUITO da Susep para Atendimento P�blico � 0800 021 8484."
      },
      {
        "conteudo":"11.    Em atendimento � Lei 12.741/12, incidem as al�quotas de 0,65% de PIS/Pasep e de 4% de COFINS sobre os pr�mios de seguros, deduzidos do estabelecido em legisla��o espec�fica."
      },
      {
        "conteudo":"12. O COOPERADO  est� ciente e concorda que a COOPERATIVA e o SISTEMA AILOS realizam o tratamento de meus dados pessoais de acordo com a Declara��o de Privacidade disponibilizada no site da Cooperativa, assim como autoriza que: (i) a Cooperativa realize consultas de informa��es em seu nome, conforme disposto na Cl�usulas e Condi��es Gerais Aplic�veis � Conta Corrente (dispon�veis no site da Cooperativa); (ii) compartilhe seus dados de acordo com as bases legais previstas na LGPD, principalmente com a(s) seguradora(s) contratadas e vinculadas a esta proposta."
      },
      {
        "conteudo":"13. Assinado eletronicamente pelo {NOME}, inscrito no CPF de n� {CPF} no dia {DT_CONTRATO}, as {HR_CONTRATO}, atrav�s do Aplicativo Ailos ou Conta Online, IP n� {IP} mediante senha digitada."
      }
    ]
  }';
BEGIN
  Update SEGURO.tbseg_contrato set CONTRATO = texto where PRODUTO = 1;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.put_line(SQLERRM);
  ROLLBACK;
END;
/   
