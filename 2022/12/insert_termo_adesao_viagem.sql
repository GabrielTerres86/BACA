DECLARE texto CLOB := '{
    "paragrafo": [
    {
       "conteudo": "TERMO DO SEGURO VIAGEM"
    },
    {
       "conteudo": "1. Ao finalizar esta jornada, o Cooperado está solicitando a contratação do Seguro Viagem, nos termos e condições apresentadas na simulação realizada por meio do acesso aos Canais Digitais."
    },
    {
       "conteudo": "2. As Condições Gerais do Seguro contratado poderão ser visualizadas no site da respectiva seguradora, ficando sob responsabilidade exclusiva do Cooperado conhecê-las."
    },
    {
       "conteudo": "3. O Cooperado declara e reconhece que:"
    },
    {
       "conteudo": "3.1. É o primeiro titular da conta corrente utilizada para contratação deste seguro;"
    },
    {
       "conteudo": "3.2. Todos os dados fornecidos na simulação e contratação do seguro são verídicos, não contendo omissões ou incorreções;"
    },
	{
       "conteudo": "3.3. A emissão da apólice do seguro será realizada em seu nome e dos demais segurados, conforme as opções selecionadas durante a simulação e contratação;"
    },
    {
       "conteudo": "3.4. É o único responsável pela seleção e preenchimento de todos os dados/informações necessários à efetivação do seguro;"
    },
    {
       "conteudo": "3.5. Este seguro será cancelado imediatamente e não produzirá quaisquer efeitos caso seja contratado depois de iniciada sua viagem ou se a contratação ocorrer fora do território nacional;"
    },
    {
       "conteudo": "3.6. Não há cobertura para eventos decorrentes de viagens de motocicleta na América Latina;"
    },
    {
       "conteudo": "3.7. O não pagamento da primeira parcela ou, se for o caso, da parcela única do prêmio, implicará no cancelamento automático da apólice gerada, desde o início da sua vigência;"
    },
    {
       "conteudo": "3.8. A contratação desse seguro foi realizada por meio de canal digital;"
    },
    {
       "conteudo": "3.9. Todos os atos praticados mediante aceite, aposição de senhas numéricas, senhas alfanuméricas, biometria elegível dentre outras formas previstas pela Cooperativa serão registrados e arquivados em meios eletrônicos e magnéticos, sendo reconhecidos como manifestação de sua vontade, para todos os fins de direito como assinatura digital, sendo considerados válidos, verdadeiros e processados por meios seguros e constituirão meio eficaz e prova inequívoca das transações realizadas."
    },
    {
       "conteudo": "3.10. O valor da remuneração pela venda desse seguro foi informado durante a contratação do seguro, o qual estava acompanhado dos respectivos valores de prêmio comercial."
    },
    {
       "conteudo": "4. A Cooperativa não será responsabilizada por eventual falha ou erro na seleção e preenchimento dos dados/informações realizadas pelo Cooperado necessários à efetivação do seguro."
     },
    {
       "conteudo": "5. O voucher e a apólice do seguro serão enviados ao Cooperado para o e-mail informado no momento da solicitação do seguro (dados de contato), após a confirmação da contratação pela Seguradora. A vigência do seguro se dará entre a data de início da viagem e seu término, conforme informado na proposta pelo Cooperado. Para solicitação dos Serviços de Assistência ou em caso de Sinistro, você poderá contatar a Seguradora através dos números informados na Apólice."
    },
    {
       "conteudo": "6. Os valores contidos na apólice são fixos, não sujeitos a qualquer atualização monetária em seus valores e a alíquota do IOF é estabelecida nos termos da legislação vigente."
    },
    {
       "conteudo": "7. A SUSEP - Superintendência de Seguros Privados - é a Autarquia Federal responsável pela fiscalização, normatização e controle dos mercados de seguro, previdência complementar aberta, capitalização, resseguro e corretagem de seguros."
    },
    {
       "conteudo": "8. As condições contratuais/regulamentos deste produto protocolizadas por esta Companhia Seguradora junto à SUSEP também poderão ser consultados no respectivo órgão por meio do número do processo constante da apólice/proposta."
    },
    {
       "conteudo": "9. O Cooperado poderá consultar a situação cadastral de seu corretor de seguros, no site www.susep.gov.br, por meio do número de seu registro na SUSEP, nome completo, CNPJ ou CPF. O telefone GRATUITO da Susep para Atendimento Público é 0800 021 8484."
    },
    {
       "conteudo": "10. Em atendimento à Lei 12.741/12, incidem as alíquotas de PIS/Pasep e de COFINS sobre os prêmios de seguros nos percentuais previstos ne Lei, deduzidos do estabelecido em legislação específica."
    },
    {
       "conteudo": "11. O Cooperado está ciente e concorda que a Cooperativa e o Sistema Ailos realizam o tratamento de seus dados pessoais de acordo com a Declaração de Privacidade disponibilizada no site da Cooperativa, assim como autoriza que: (i) a Cooperativa realize consultas de informações em seu nome, conforme disposto na Cláusulas e Condições Gerais Aplicáveis à Conta Corrente (disponíveis no site da Cooperativa); (ii) compartilhe seus dados de acordo com as bases legais previstas na LGPD, principalmente com a(s) seguradora(s) contratadas e vinculadas a esta proposta."
    },	
    {
       "conteudo": "12. O Cooperado declara, por fim, ter lido previamente este documento, conferido os dados e não possuir nenhuma dúvida com relação a quaisquer cláusulas e ainda, nos termos do §5º, Art. 29 da Lei 10.931/04 e do §2º da Medida Provisória de nº 2.200-2, reconhece como válida a assinatura deste contrato em formato eletrônico, inclusive através da ferramenta digital que não utilize o certificado digital emitido no padrão ICP – Brasil."
    },
    {
       "conteudo": "Documento assinado eletronicamente pelo COOPERADO {NOME} inscrito no CPF {CPF}, no dia {DT_CONTRATO}, as {HR_CONTRATO}, IP {IP}, mediante inserção de senha numéricas e de segurança."
    }
  ]
}';
BEGIN
  INSERT INTO SEGURO.tbseg_template_documento(tpdocumento,dtinicio,dtfim,obtemplate) VALUES (5,TRUNC(SYSDATE),NULL, texto);
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.put_line(SQLERRM);
  ROLLBACK;
END;
/