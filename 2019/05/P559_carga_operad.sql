declare
  cursor cr_carga is
    select 'goes' cdoperad, 'Goes e Nicoladelli Advogados' nmoperad, 'renes.santos@ailos.coop.br' dsdemail  from dual union
    select 'henrique' cdoperad, 'Henirque G Schroeder Advogados' nmoperad, 'rene.santos@ailos.coop.br' dsdemail  from dual union
    select 't0030470' cdoperad, 'Teste Peopleware' nmoperad, 'sabrina.godoi@cecred.coop.br' dsdemail  from dual union
    select 't0032137' cdoperad, 'Amanda Medeiros de Araujo' nmoperad, 'amanda.araujo@ailos.coop.br' dsdemail  from dual union
    select 't0032138' cdoperad, 'Adriana da Luz ' nmoperad, 'adriana.luz@ailos.coop.br' dsdemail  from dual union
    select 't0032223' cdoperad, 'Rodrigo Frasseto Goes' nmoperad, 'fernanda.buettgen@ailos.coop.br' dsdemail  from dual union
    select 't0032224' cdoperad, 'Henrique Gomes Schroeder' nmoperad, 'fernanda.buettgen@ailos.coop.br' dsdemail  from dual union
    select 't0032332' cdoperad, 'GABRIELLE ELOIZE STEFFEN ' nmoperad, 'gabrielle.steffen@ailos.coop.br' dsdemail  from dual union
    select 't0032333' cdoperad, 'TAINARA CCECHELERO ' nmoperad, 'tainara.ccechelero@ailos.coop.br' dsdemail  from dual union
    select 't0032345' cdoperad, 'Bruno Ribeiro de Almeida' nmoperad, 'eduardo.santos@ailos.coop.br' dsdemail  from dual union
    select 't0032367' cdoperad, 'ALISSON DA SILVA AZEVEDO ' nmoperad, 'alisson.azevedo@ailos.coop.br' dsdemail  from dual union
    select 't0032369' cdoperad, 'EDNA MARIA DA SILVA ' nmoperad, 'edna.silva@ailos.coop.br' dsdemail  from dual union
    select 't0032370' cdoperad, 'LARISSA OURIQUES ' nmoperad, 'larissa.ouriques@ailos.coop.br' dsdemail  from dual union
    select 't0032371' cdoperad, 'MARYANA MAFESSONI DE OLIVEIRA ' nmoperad, 'maryana.oliveira@ailos.coop.br' dsdemail  from dual union
    select 't0032402' cdoperad, 'ANA KAROLINA DE ALMEIDA ' nmoperad, 'ana.almeida@ailos.coop.br' dsdemail  from dual union
    select 't0032404' cdoperad, 'ANDREIA LUCIA CAVILHA' nmoperad, 'andreia.cavilha@ailos.coop.br' dsdemail  from dual union
    select 't0032405' cdoperad, 'CAMILA DANIELLE RISTOW ' nmoperad, 'camila.ristow@ailos.coop.br' dsdemail  from dual union
    select 't0032407' cdoperad, 'CASSIA POTTERMAYER BRATFSCH ' nmoperad, 'cassia.bratfsch@ailos.coop.br' dsdemail  from dual union
    select 't0032408' cdoperad, 'DEBORA SERPA' nmoperad, 'debora.serpa@ailos.coop.br' dsdemail  from dual union
    select 't0032410' cdoperad, 'GABRIELA AGUIAR SCARPA ' nmoperad, 'gabriela.scarpa@ailos.coop.br' dsdemail  from dual union
    select 't0032411' cdoperad, 'JOICE SCHNAIDER RIBEIRO' nmoperad, 'joice.ribeiro@ailos.coop.br' dsdemail  from dual union
    select 't0032412' cdoperad, 'MARCOS EDUARDO FREIBERG ' nmoperad, 'marcos.freiberg@ailos.coop.br' dsdemail  from dual union
    select 't0032413' cdoperad, 'RODRIGO HENRIQUE CIAVAGLIA DA ' nmoperad, 'rodrigo.silva@ailos.coop.br' dsdemail  from dual union
    select 't0032447' cdoperad, 'Jessica Ariana Reinert' nmoperad, 'jessica.reinert@ailos.coop.br' dsdemail  from dual union
    select 't0032459' cdoperad, 'Thayna Taize Pereira' nmoperad, 'Vanessa.sutil@ailos.coop.br' dsdemail  from dual union
    select 't0032491' cdoperad, 'ANTONIO ROMERO FERREIRA DE BEM' nmoperad, 'antonio.junior@ailos.coop.br' dsdemail  from dual union
    select 't0032492' cdoperad, 'JOICE CAUANE TARIFA MALVINO' nmoperad, 'joice.malvino@ailos.coop.br' dsdemail  from dual union
    select 't0032493' cdoperad, 'MAYARA CRISTINA DE SOUZA' nmoperad, 'mayara.souza@ailos.coop.br' dsdemail  from dual union
    select 't003333' cdoperad, 'TAINARA CCECHELERO ' nmoperad, 'tainara.ccechelero@ailos.coop.br' dsdemail  from dual union
    select 't0032159' cdoperad, 'Portal - BLU365' nmoperad, 'felipe.silva@blu365.com.br' dsdemail  from dual union
    select 't0032160' cdoperad, 'Portal - BLU365' nmoperad, 'felipe.rodrigues@kitado.com.br' dsdemail  from dual union
    select 't0032161' cdoperad, 'Portal - BLU365' nmoperad, 'gabriela.oliveira@blu365.com.br' dsdemail  from dual union
    select 't0032162' cdoperad, 'Portal - BLU365' nmoperad, 'isabelly.toledo@blu365.com.br' dsdemail  from dual union
    select 't0032163' cdoperad, 'Portal - BLU365' nmoperad, 'jefferson.nascimento@blu365.com.br' dsdemail  from dual union
    select 't0032164' cdoperad, 'Portal - BLU365' nmoperad, 'julia.sampaio@blu365.com.br' dsdemail  from dual union
    select 't0032165' cdoperad, 'Portal - BLU365' nmoperad, 'marcella.fiorita@blu365.com.br' dsdemail  from dual union
    select 't0032166' cdoperad, 'Portal - BLU365' nmoperad, 'maiko.deizepi@blu365.com.br' dsdemail  from dual union
    select 't0032167' cdoperad, 'Samara Alves' nmoperad, 'samara.alves@blu365.com.br' dsdemail  from dual union
    select 't0032168' cdoperad, 'Portal - BLU365' nmoperad, 'rodrigo.nascimento@blu365.com.br' dsdemail  from dual union
    select 't0032430' cdoperad, 'Bruna Cabral' nmoperad, 'bruna.cabral@camesc.com.br' dsdemail  from dual union
    select 't0032432' cdoperad, 'Bruna Andrade' nmoperad, 'ferraz@ferraz.com.br' dsdemail  from dual union
    select 't0032079' cdoperad, 'Admilson Passo' nmoperad, 'estela@cmablu.com.br' dsdemail  from dual union
    select 't0032433' cdoperad, 'Barbara Hochheim' nmoperad, 'cmati@cmati.com.br' dsdemail  from dual union
    select 't0032434' cdoperad, 'Gabriela Bertoldi Purim Roeder' nmoperad, 'cmati@cmati.com.br' dsdemail  from dual union
    select 't0032435' cdoperad, 'Amanda Luiza Schaade' nmoperad, 'cmati@cmati.com.br' dsdemail  from dual union
    select 't0031493' cdoperad, 'COBRENE EX 01' nmoperad, 'cobrene@cobrene.com.br' dsdemail  from dual union
    select 'cobrene' cdoperad, 'Usuário Cobrene' nmoperad, 'cobrene@cobrene.com' dsdemail  from dual union
    select 't0031013' cdoperad, 'Decisão Cobrança 1' nmoperad, 'decisao@cobranca.com.br' dsdemail  from dual union
    select 't0031014' cdoperad, 'Decisão Cobrança 2' nmoperad, 'decisao@cobranca.com.br' dsdemail  from dual union
    select 't0031015' cdoperad, 'Decisão Cobranças - Supervisor' nmoperad, 'decisao@decisãocobrancas.com.br' dsdemail  from dual union
    select 't0031032' cdoperad, 'Decisão Cobrança 4' nmoperad, 'decisao@cobranca.com.br' dsdemail  from dual union
    select 't0031033' cdoperad, 'Decisão Cobrança 3' nmoperad, 'decisao@decisaoassessoria.com.br' dsdemail  from dual union
    select 't0031050' cdoperad, 'DECISÃO 13' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031064' cdoperad, 'Decisão Cobrança 12' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031067' cdoperad, 'Decisão Cobrança 16' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031068' cdoperad, 'Decisão reserva 01' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031071' cdoperad, 'Decisão Cobrança 14' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031072' cdoperad, 'Decisão Cobrança 15' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031266' cdoperad, 'Decisão Cobrança 18' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031267' cdoperad, 'Decisão Cobrança 17' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031271' cdoperad, 'Decisão Cobrança 5' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031272' cdoperad, 'Decisão Cobrança 6' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031273' cdoperad, 'Decisão Cobrança 7' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031275' cdoperad, 'Decisão Cobrança 8' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031276' cdoperad, 'Decisão Cobrança 9' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031277' cdoperad, 'Decisão Cobrança 10' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031278' cdoperad, 'Decisão Cobrança 11' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031365' cdoperad, 'Decisão de Cobrança 19' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031366' cdoperad, 'Decisão de Cobrança 20' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031367' cdoperad, 'Decisão de Cobrança 21' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031368' cdoperad, 'Decisão de Cobrança 22' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031369' cdoperad, 'Decisão de Cobrança 23' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031370' cdoperad, 'Decisão de Cobrança 24' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031371' cdoperad, 'Decisão de Cobrança 25' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031372' cdoperad, 'Decisão de Cobrança 26' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031374' cdoperad, 'Decisão de Cobrança 27' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031460' cdoperad, 'DECISAO EX 01' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031461' cdoperad, 'DECISAO EX 02' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031462' cdoperad, 'DECISAO EX 03' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031463' cdoperad, 'DECISAO EX 04' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031464' cdoperad, 'DECISAO EX 05' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031465' cdoperad, 'DECISAO EX 06' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031466' cdoperad, 'DECISAO EX 07' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031467' cdoperad, 'DECISAO EX 08' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031468' cdoperad, 'DECISAO EX 09' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031469' cdoperad, 'DECISAO EX 10' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031470' cdoperad, 'DECISAO EX 11' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031471' cdoperad, 'DECISAO EX 12' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031619' cdoperad, 'Decisão Cobrança 28' nmoperad, 'decsiao@decisao.com.br' dsdemail  from dual union
    select 't0031620' cdoperad, 'Decisão Cobrança 29' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031637' cdoperad, 'Decisão Cobrança 30' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031638' cdoperad, 'Decisão Cobrança 31' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031639' cdoperad, 'Decisão Cobrança 32' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031658' cdoperad, 'Decisão Cobrança 10' nmoperad, 'decisão@decisão.com.br' dsdemail  from dual union
    select 't0031659' cdoperad, 'Decisão Cobrança 11' nmoperad, 'decisão@decisão.com.br' dsdemail  from dual union
    select 't0031660' cdoperad, 'Decisão Cobrança 12' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031661' cdoperad, 'Decisão Cobrança 13' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031662' cdoperad, 'Decisão Cobrança 14 ' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031663' cdoperad, 'Decisão Cobrança 15' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031682' cdoperad, 'Decisao Cobranca 17' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031683' cdoperad, 'Decisao Cobranca 31' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0031707' cdoperad, 'Decisão Cobrança 16' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 't0032122' cdoperad, 'Thais Caetano Justino' nmoperad, 'rene.santos@ailos.coop.br' dsdemail  from dual union
    select 't0032123' cdoperad, 'Larissa Pedroso Alves' nmoperad, 'rene.santos@ailos.coop.br' dsdemail  from dual union
    select 't0032379' cdoperad, 'Reginaldo Burini' nmoperad, 'stephanie.santos@ailos.coop.br' dsdemail  from dual union
    select 'decisao1' cdoperad, 'Decisão Cobrança 5' nmoperad, 'decisao@decisaocobranca.com.br' dsdemail  from dual union
    select 'decisao2' cdoperad, 'Decisão Cobrança 6' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 'decisao3' cdoperad, 'Decisão Cobrança 7' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 'decisao4' cdoperad, 'Decisão Cobrança 8' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 'decisao5' cdoperad, 'Decisão Cobrança 9' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 'decisao6' cdoperad, 'Decisão Cobrança 10' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 'decisao7' cdoperad, 'Decisão Cobrança 11' nmoperad, 'decisao@decisao.com.br' dsdemail  from dual union
    select 'ferraz' cdoperad, 'Ferraz Cicarelli' nmoperad, 'thais@ferraz-ciralli.com.br' dsdemail  from dual union
    select 't0031449' cdoperad, 'FERRAZ EX 01' nmoperad, 'cristiane.viana@ferraz-cicarelli.com.br' dsdemail  from dual union
    select 't0031450' cdoperad, 'FERRAZ EX 03' nmoperad, 'cristiane.vianna@ferraz-cicarelli.com.br' dsdemail  from dual union
    select 't0031451' cdoperad, 'FERRAZ EX 04' nmoperad, 'cristiane.vianna@ferraz-cicarelli.com.br' dsdemail  from dual union
    select 't0031452' cdoperad, 'FERRAZ EX 06' nmoperad, 'cristiane.vianna@ferraz-cicarelli.com.br' dsdemail  from dual union
    select 't0031453' cdoperad, 'FERRAZ EX 07' nmoperad, 'cristiane.vianna@ferraz-cicarelli.com.br' dsdemail  from dual union
    select 't0031455' cdoperad, 'FERRAZ EX 09' nmoperad, 'ferraz@ferraz.com.br' dsdemail  from dual union
    select 't0031457' cdoperad, 'FERRAZ EX 11' nmoperad, 'cristiane.vianna@ferraz-cicarelli.com.br' dsdemail  from dual union
    select 't0031458' cdoperad, 'FERRAZ EX 02' nmoperad, 'cristiane.vianna@ferraz-cicarelli.com.br' dsdemail  from dual union
    select 't0031685' cdoperad, 'FERRAZ EX 12' nmoperad, 'ferraz@ferraz.com.br' dsdemail  from dual union
    select 't0031686' cdoperad, 'FERRAZ EX 13' nmoperad, 'ferraz@ferras.com.br' dsdemail  from dual union
    select 't0031687' cdoperad, 'FERRAZ EX 14' nmoperad, 'ferraz@ferraz.com.br' dsdemail  from dual union
    select 't0031787' cdoperad, 'Emerson Zanin' nmoperad, 'ferraz@ferraz.com.br' dsdemail  from dual union
    select 't0031939' cdoperad, 'Tayná Fernanda' nmoperad, 'ferraz@ferraz.com.br' dsdemail  from dual union
    select 't0032072' cdoperad, 'Bruna da Silva Pinheiro' nmoperad, 'cristiane.viana@fcpadvogados.com.br' dsdemail  from dual union
    select 't0032073' cdoperad, 'Vanessa Karina Ilheo do Nascim' nmoperad, 'cristiane.viana@fcpadvogados.com.br' dsdemail  from dual union
    select 't0032074' cdoperad, 'Angelique Menezes de Matos' nmoperad, 'cristiane.viana@fcpadvogados.com.br' dsdemail  from dual union
    select 't0032075' cdoperad, 'Larissa Caroline dos Santos' nmoperad, 'cristiane.viana@fcpadvogados.com.br' dsdemail  from dual union
    select 't0032076' cdoperad, 'Michele Aparecida M. do Santos' nmoperad, 'cristiane.viana@fcpadvogados.com.br' dsdemail  from dual union
    select 't0032080' cdoperad, 'Melissa de Jesus Pita Almeida' nmoperad, 'cristiane.viana@fcpadvogados.com.br' dsdemail  from dual union
    select 't0032081' cdoperad, 'Camila Farias dos Santos ' nmoperad, 'cobcec05@fcpadvogados.com.br' dsdemail  from dual union
    select 't0032173' cdoperad, 'Ana Paula da Silva Lima' nmoperad, 'cobcec05@fcpadvogados.com.br' dsdemail  from dual union
    select 't0032174' cdoperad, 'Maria Isabella dos Santos Laur' nmoperad, 'cobcec05@fcpadvogados.com.br' dsdemail  from dual union
    select 't0032281' cdoperad, 'Jonathan Graf' nmoperad, 'ferraz@ferraz.com.br' dsdemail  from dual union
    select 't0032414' cdoperad, 'Mike Moura da Silva' nmoperad, 'ferraz@ferraz.com.br' dsdemail  from dual union
    select 't0032467' cdoperad, 'Ana Cristina Laureano Schafer ' nmoperad, 'cobcec05@fcpadvogados.com.br' dsdemail  from dual union
    select 't0032098' cdoperad, 'Rodrigo Frasseto Goes' nmoperad, 'rodrigogoes@goesnicoladelli.com' dsdemail  from dual union
    select 't0032099' cdoperad, 'Bruno Acordi Beck' nmoperad, 'brunoacordi@goesnicoladelli.com.br' dsdemail  from dual union
    select 't0032100' cdoperad, 'Daniel da Luz Trevizani' nmoperad, 'daniel.trevizani@goesnicoladelli.com.br' dsdemail  from dual union
    select 't0032101' cdoperad, 'Fernanda de Bittencourt Vitto ' nmoperad, 'fernanda.vitto@goesnicoladelli.com.br' dsdemail  from dual union
    select 't0032103' cdoperad, 'Viviana Ferreira Dagostim' nmoperad, 'viviana.dagostim@goesnicoladelli.com.br' dsdemail  from dual union
    select 't0032104' cdoperad, 'Eduardo Procacci Feliciano' nmoperad, 'Eduardo.feliciano@goesnicoladelli.com.br' dsdemail  from dual union
    select 't0032105' cdoperad, 'Kelly Santana de Oliveira' nmoperad, 'Eduardo.feliciano@goesnicoladelli.com.br' dsdemail  from dual union
    select 't0032106' cdoperad, 'Paloma Aparecida Lirio' nmoperad, 'Eduardo.feliciano@goesnicoladelli.com.br' dsdemail  from dual union
    select 't0032107' cdoperad, 'Elisiane de Dornelles Frassett' nmoperad, 'rene.santos@ailos.coop.br' dsdemail  from dual union
    select 't0032211' cdoperad, 'Bruno Beck' nmoperad, 'brunoacordi@goesnicoladelli.com.br' dsdemail  from dual union
    select 't0032245' cdoperad, 'Paula Ozorio Vieira' nmoperad, 'tesrceiro@ailos.coop.br' dsdemail  from dual union
    select 't0032264' cdoperad, 'Samanta da Silveira Pavei' nmoperad, 'terceiro@ailos.coop.br' dsdemail  from dual union
    select 't0032265' cdoperad, 'Mariele Venhold Pícolo' nmoperad, 'terceiro@ailos.coop.br' dsdemail  from dual union
    select 't0032266' cdoperad, 'Aline Vidal Carlos' nmoperad, 'terceiro@ailos.coop.br' dsdemail  from dual union
    select 't0032267' cdoperad, 'Ana Carolina Freitas' nmoperad, 'terceiro@ailos.coop.br' dsdemail  from dual union
    select 't0032268' cdoperad, 'Thais Sachet' nmoperad, 'terceiro@ailos.coop.br' dsdemail  from dual union
    select 't0032270' cdoperad, 'Larissa Alves Benitez' nmoperad, 'terceiro@ailos.coop.br' dsdemail  from dual union
    select 't0032271' cdoperad, 'Vanessa de Freitas Clemente' nmoperad, 'terceiro@ailos.coop.br' dsdemail  from dual union
    select 't0032273' cdoperad, 'Douglas Bortolatto' nmoperad, 'terceiro@ailos.coop.br' dsdemail  from dual union
    select 't0032274' cdoperad, 'Claudia Savi Pereira' nmoperad, 'terceiro@ailos.coop.br' dsdemail  from dual union
    select 't0032275' cdoperad, 'Monica Guollo' nmoperad, 'terceiro@ailos.coop.br' dsdemail  from dual union
    select 't0032276' cdoperad, 'André Correa Ronsani' nmoperad, 'terceiro@ailos.coop.br' dsdemail  from dual union
    select 't0032277' cdoperad, 'Priscila Leandro Pacheco' nmoperad, 'terceiro@ailos.coop.br' dsdemail  from dual union
    select 't0032278' cdoperad, 'Bruno Raulino Santos Bunn' nmoperad, 'terceiro@ailos.coop.br' dsdemail  from dual union
    select 't0032294' cdoperad, 'Dione Lucio Pinheiro' nmoperad, 'terceiro@ailos.coop.br' dsdemail  from dual union
    select 't0032295' cdoperad, 'Priscila Regina Tonolli' nmoperad, 'terceiro@ailos.coop.br' dsdemail  from dual union
    select 't0032088' cdoperad, 'Henrique Gineste Schroeder' nmoperad, 'caio@schroeder-adv.com.br' dsdemail  from dual union
    select 't0032089' cdoperad, 'Caio Henrique Gomes Schroeder' nmoperad, 'sluan.breit@ailos.coop.br' dsdemail  from dual union
    select 't0032090' cdoperad, 'Juliana Gomes S. Batistussi' nmoperad, 'sluan.breit@ailos.coop.br' dsdemail  from dual union
    select 't0032091' cdoperad, 'Caroline Cordeiro' nmoperad, 'sluan.breit@ailos.coop.br' dsdemail  from dual union
    select 't0032234' cdoperad, 'Leila Pacheco' nmoperad, 'felipe.priebe@ailos.coop.br' dsdemail  from dual union
    select 't0032235' cdoperad, 'Indalécio Robson Paulo Pereira' nmoperad, 'felipe.priebe@ailos.coop.br' dsdemail  from dual union
    select 't0032236' cdoperad, 'Tatiane Benkendorf' nmoperad, 'felipe.priebe@ailos.coop.br' dsdemail  from dual union
    select 't0032237' cdoperad, 'Sabrina Alexcia Rodrigues' nmoperad, 'felipe.priebe@ailos.coop.br' dsdemail  from dual union
    select 't0032249' cdoperad, 'Juliana Guizoni' nmoperad, 'robson@schroeder-adv.com.br' dsdemail  from dual union
    select 't0032250' cdoperad, 'Maria Alice dos Anjos' nmoperad, 'robson@schroeder-adv.com.br' dsdemail  from dual union
    select 't0032251' cdoperad, 'Camila Bueno Leoni' nmoperad, 'robson@schroeder-adv.com.br' dsdemail  from dual union
    select 't0032255' cdoperad, 'Franciele Klaumann' nmoperad, 'robson@schroeder-adv.com.br' dsdemail  from dual union
    select 't0032256' cdoperad, 'Patricia Agostinho' nmoperad, 'robson@schroeder-adv.com.br' dsdemail  from dual union
    select 't0032261' cdoperad, 'Ariadne Da Silva Telles' nmoperad, 'robson@schroeder-adv.com.br' dsdemail  from dual union
    select 't0032375' cdoperad, 'Daniel Soares' nmoperad, 'vanessa.sutil@ailos.coop.br' dsdemail  from dual union
    select 't0032376' cdoperad, 'Lucas Felipe Rumpf da Rosa' nmoperad, 'vanessa.sutil@ailos.coop.br' dsdemail  from dual union
    select 't0032377' cdoperad, 'Karliani Karin Bagnhuk' nmoperad, 'vanessa.sutil@ailos.coop.br' dsdemail  from dual union
    select 't0032378' cdoperad, 'Gabrielli Esidio' nmoperad, 'vanessa.sutil@ailos.coop.br' dsdemail  from dual union
    select 't0032458' cdoperad, 'Silvania Kelly Lima Sousa' nmoperad, 'Vanessa.sutil@ailos.coop.br' dsdemail  from dual union
    select 't0032460' cdoperad, 'Lucas Nogueira Torres' nmoperad, 'lucas.torres@ailos.coop.br' dsdemail  from dual union
    select 't0032497' cdoperad, 'Mariana Perrout de Hollanda' nmoperad, 'mariana.hollanda@ailos.coop.br' dsdemail  from dual union
    select 't0032564' cdoperad, 'Keren Caroline da Silva' nmoperad, 'Vanessa.sutil@ailos.coop.br' dsdemail  from dual union
    select 't0031494' cdoperad, 'OLIVEIRA E ANTUNES EX 16' nmoperad, 'oliveira@oliveira.com.br' dsdemail  from dual union
    select 't0031495' cdoperad, 'OLIVEIRA E ANTUNES EX 15' nmoperad, 'oliveira@oliveira.com.br' dsdemail  from dual union
    select 't0031496' cdoperad, 'OLIVEIRA E ANTUNES EX 14' nmoperad, 'oliveira@oliveira.com.br' dsdemail  from dual union
    select 't0031497' cdoperad, 'OLIVEIRA E ANTUNES EX 13' nmoperad, 'oliveira@oliveira.com.br' dsdemail  from dual union
    select 't0031498' cdoperad, 'OLIVEIRA E ANTUNES EX 12' nmoperad, 'oliveira@oliveira.com.br' dsdemail  from dual union
    select 't0031500' cdoperad, 'OLIVEIRA E ANTUNES EX 10' nmoperad, 'oliveira@oliveira.com.br' dsdemail  from dual union
    select 't0031501' cdoperad, 'OLIVEIRA E ANTUNES EX 09' nmoperad, 'oliveira@oliveira.com.br' dsdemail  from dual union
    select 't0031502' cdoperad, 'OLIVEIRA E ANTUNES EX 08' nmoperad, 'oliveira@oliveira.com.br' dsdemail  from dual union
    select 't0031503' cdoperad, 'OLIVEIRA E ANTUNES EX 07' nmoperad, 'oliveira@oliveira.com.br' dsdemail  from dual union
    select 't0031504' cdoperad, 'OLIVEIRA E ANTUNES EX 06' nmoperad, 'oliveira@oliveira.com.br' dsdemail  from dual union
    select 't0031505' cdoperad, 'OLIVEIRA E ANTUNES EX 05' nmoperad, 'oliveira@oliveira.com.br' dsdemail  from dual union
    select 't0031506' cdoperad, 'OLIVEIRA E ANTUNES EX 04' nmoperad, 'oliveira@oliveira.com.br' dsdemail  from dual union
    select 't0031507' cdoperad, 'OLIVEIRA E ANTUNES EX 03' nmoperad, 'oliveira@oliveira.com.br' dsdemail  from dual union
    select 't0031508' cdoperad, 'OLIVEIRA E ANTUNES EX 02' nmoperad, 'oliveira@oliveira.com.br' dsdemail  from dual union
    select 't0031509' cdoperad, 'OLIVEIRA E ANTUNES EX 01' nmoperad, 'oliveira@oliveira.com.br' dsdemail  from dual union
    select 't0031708' cdoperad, 'OLIVEIRA E ANTUNES EX 17' nmoperad, 'oea@oea.com.br' dsdemail  from dual union
    select 't0031709' cdoperad, 'OLIVEIRA E ANTUNES EX 18' nmoperad, 'oea@oea.com.br' dsdemail  from dual union
    select 't0031710' cdoperad, 'OLIVEIRA E ANTUNES EX 19' nmoperad, 'oea@oea.com.br' dsdemail  from dual union
    select 't0031711' cdoperad, 'OLIVEIRA E ANTUNES EX 20' nmoperad, 'oea@oea.com.br' dsdemail  from dual union
    select 't0031712' cdoperad, 'OLIVEIRA E ANTUNES EX 21' nmoperad, 'oea@oea.com.br' dsdemail  from dual union
    select 't0031713' cdoperad, 'OLIVEIRA E ANTUNES EX 22' nmoperad, 'oea@oea.com.br' dsdemail  from dual union
    select 't0031715' cdoperad, 'OLIVEIRA E ANTUNES EX 23' nmoperad, 'oea@oea.com.br' dsdemail  from dual union
    select 't0031716' cdoperad, 'OLIVEIRA E ANTUNES EX 24' nmoperad, 'oea@oea.com.br' dsdemail  from dual union
    select 't0031717' cdoperad, 'OLIVEIRA E ANTUNES EX 25' nmoperad, 'oea@oea.com.br' dsdemail  from dual union
    select 't0031718' cdoperad, 'OLIVEIRA E ANTUNES EX 26' nmoperad, 'oea@oea.com.br' dsdemail  from dual union
    select 't0031962' cdoperad, 'OLIVEIRA E ANTUNES EX 27' nmoperad, 'rene.santos@cecred.coo.br' dsdemail  from dual union
    select 't0031963' cdoperad, 'OLIVEIRA E ANTUNES EX 28' nmoperad, 'rene.santos@cecred.coop.br' dsdemail  from dual union
    select 'oliveira' cdoperad, 'Usuário Oliveira e Antunes' nmoperad, 'oliveira@oliveira.com' dsdemail  from dual union
    select 'portal' cdoperad, 'Usuário do Portal' nmoperad, 'portal@portal.com' dsdemail  from dual union
    select 't0030480' cdoperad, 'Peopleware' nmoperad, 'leandro.morgado@ppware.com.br' dsdemail  from dual union
    select 't0031063' cdoperad, 'TESTE PPW' nmoperad, 'TESTE@TESTEcom.br' dsdemail  from dual union
    select 't0031280' cdoperad, 'Peopleware' nmoperad, 'people@people.com.br' dsdemail  from dual union
    select 't0031254' cdoperad, 'Escritório Dr. Sérgio Sinhori' nmoperad, 'sinhori@actio.com.br' dsdemail  from dual union
    select 't0031394' cdoperad, 'Segio Sinhori' nmoperad, 'rene.santos@cecred.coop.br' dsdemail  from dual union
    select 't0030758' cdoperad, 'Usuário Souza e De Lorenze' nmoperad, 'leonardorafael@sdl.adv.br' dsdemail  from dual union
    select 't0031340' cdoperad, 'Cristiane de Lorenzi Cancelier' nmoperad, 'souza@souza.com.br' dsdemail  from dual union
    select 't0031342' cdoperad, 'Leonardo Rafael de Souza' nmoperad, 'souza@souza.com.br' dsdemail  from dual union
    select 't0031343' cdoperad, 'Danuza Antunes' nmoperad, 'souza@souza.com.br' dsdemail  from dual union
    select 't0031344' cdoperad, 'Andrea Salles' nmoperad, 'souza@souza.com.br' dsdemail  from dual union
    select 't0031345' cdoperad, 'Camila Carioni' nmoperad, 'souza@souza.com.br' dsdemail  from dual union
    select 't0031416' cdoperad, 'Danusia Camila Dalla Zen' nmoperad, 'souza@souza.com.br' dsdemail  from dual union
    select 't0031417' cdoperad, 'Nikolas Cardoso Bittencourt' nmoperad, 'souza@souza.com.br' dsdemail  from dual union
    select 't0031418' cdoperad, 'Thainan Prado' nmoperad, 'souza@souza.com.br' dsdemail  from dual union
    select 't0031573' cdoperad, 'Beatriz Silva' nmoperad, 'souza@souza.com.br' dsdemail  from dual union
    select 't0031582' cdoperad, 'Daniela Kormann' nmoperad, 'souza@souza.com' dsdemail  from dual union
    select 't0031583' cdoperad, 'Barbara Salvan' nmoperad, 'souza@souza.com' dsdemail  from dual union
    select 't0031587' cdoperad, 'Luciana Petri' nmoperad, 'souza@souza.coop.br' dsdemail  from dual union
    select 't0031588' cdoperad, 'Elaine Machado' nmoperad, 'souza@souza.com.br' dsdemail  from dual union
    select 't0031609' cdoperad, 'Marco Antônio da Silva Júnior' nmoperad, 'souza@souza.com' dsdemail  from dual union
    select 't0032051' cdoperad, 'JULIA SALLES' nmoperad, 'cobranca01@sdl.adv.br' dsdemail  from dual union
    select 't0032141' cdoperad, 'Amanda Medeiros de Araujo' nmoperad, 'rene.santos@ailos.coop.br' dsdemail  from dual union
    select 't0032142' cdoperad, 'Adriana da Luz' nmoperad, 'rene.santos@ailos.coop.br' dsdemail  from dual union
    select 't0032238' cdoperad, 'LIVIA GARCIA RIBEIRO' nmoperad, 'rene.santos@ailos.coop.br' dsdemail  from dual union
    select 't0032241' cdoperad, 'Isabella C Andrade Santos' nmoperad, 'rene.santos@ailos.coop.br' dsdemail  from dual union
    select 't0032242' cdoperad, 'HANNA NASCIMENTO XAVIER' nmoperad, 'rene.santos@ailos.coop.br' dsdemail  from dual union
    select 't0032244' cdoperad, 'ALINY TIBES KIRSCH' nmoperad, 'rene.santos@ailos.coop.br' dsdemail  from dual union
    select 't0032306' cdoperad, 'Gabrielli Raizer Muller' nmoperad, 'administrativo@sdl.adv.br' dsdemail  from dual union
    select 't0032343' cdoperad, 'Diego Felipe da Silva' nmoperad, 'souza@souza.com.br' dsdemail  from dual union
    select 't0032399' cdoperad, 'Nicolli Correia' nmoperad, 'administrativo@sdl.adv.br' dsdemail  from dual union
    select 't0032243' cdoperad, 'Aliny Tibes Kirsch' nmoperad, 'administrativo@sdl.adv.br' dsdemail  from dual union
    select 't0031016' cdoperad, 'Teste' nmoperad, 'teste@testecyber.com.br' dsdemail  from dual union
    select 't0031073' cdoperad, 'TRC 1' nmoperad, 'TRC@TRC.COM.BR' dsdemail  from dual union
    select 't0031074' cdoperad, 'TRC 2' nmoperad, 'TRC@TRC.COM.BR' dsdemail  from dual union
    select 't0031075' cdoperad, 'TRC 3' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031076' cdoperad, 'TRC 4' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031088' cdoperad, 'TRC 5' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031091' cdoperad, 'TRC SUPERVISÃO' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031092' cdoperad, 'TRC 6' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031093' cdoperad, 'TRC 7' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031094' cdoperad, 'TRC 8' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031095' cdoperad, 'RESERVA - TRC' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031096' cdoperad, 'TRC reserva 02' nmoperad, 'trc@trctaborda.com.br' dsdemail  from dual union
    select 't0031306' cdoperad, 'TRC 9' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031307' cdoperad, 'TRC 10' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031308' cdoperad, 'TRC 11' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031309' cdoperad, 'TRC 12' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031310' cdoperad, 'TRC 13' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031311' cdoperad, 'TRC 14' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031312' cdoperad, 'TRC 15' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031313' cdoperad, 'TRC 16' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031319' cdoperad, 'TRC 17' nmoperad, 'trc@trccobrancas.com.br' dsdemail  from dual union
    select 't0031362' cdoperad, 'TRC 18' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031363' cdoperad, 'TRC 19' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031364' cdoperad, 'TRC 20' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031472' cdoperad, 'TRC EX 05' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031473' cdoperad, 'TRC EX 06' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031474' cdoperad, 'TRC EX 07' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031475' cdoperad, 'TRC EX 08' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031476' cdoperad, 'TRC EX 09' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031477' cdoperad, 'TRC EX 10' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031478' cdoperad, 'TRC EX 11' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031479' cdoperad, 'TRC EX 12' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031489' cdoperad, 'TRC EX 04' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031490' cdoperad, 'TRC EX 03' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031491' cdoperad, 'TRC EX 02' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031492' cdoperad, 'TRC EX 01' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031677' cdoperad, 'TRC 21' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031678' cdoperad, 'TRC 22' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031679' cdoperad, 'TRC 23' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031680' cdoperad, 'TRC 24' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0031681' cdoperad, 'TRC 25' nmoperad, 'trc@trc.com.br' dsdemail  from dual union
    select 't0032125' cdoperad, 'Lucas Alexandre Venancio' nmoperad, 'vinicius.leopoldino@trccob.com.br' dsdemail  from dual union
    select 't0032126' cdoperad, 'Emelin Gabriely de Oliveira Al' nmoperad, 'vinicius.leopoldino@trccob.com.br' dsdemail  from dual union
    select 't0032127' cdoperad, 'Chris dos Santos Klostermann' nmoperad, 'vinicius.leopoldino@trccob.com.br' dsdemail  from dual union
    select 't0032285' cdoperad, 'Ana Paula Pereira' nmoperad, 'teste@teste.com.br' dsdemail  from dual union
    select 't0032286' cdoperad, 'Juliana Carneiro Pastor ' nmoperad, 'teste@teste.com.br' dsdemail  from dual union
    select 't0032287' cdoperad, 'Escarlet Bianca Farias Silva' nmoperad, 'teste@teste.com.br' dsdemail  from dual union
    select 't0032288' cdoperad, 'Franciele Porto Teixeira' nmoperad, 'teste@teste.com.br' dsdemail  from dual union
    select 't0032289' cdoperad, 'Alex Souza de Freitas' nmoperad, 'TESTE@TESTE.COM.BR' dsdemail  from dual union
    select 't0031744' cdoperad, 'V2 Consulting' nmoperad, 'v2consulting@cecred.coop.br' dsdemail  from dual union
    select 't0032032' cdoperad, 'Mércia Regina C do Nascimento' nmoperad, 'rene.santos@ailos.coop.br' dsdemail  from dual union
    select 't0014067' cdoperad, 'CAMILA HILDINGER' nmoperad, 'camila.hildinger@viacredi.coop.br' dsdemail  from dual union
    select 't0014074' cdoperad, 'LECIA MARIA DE SOUZA DANTAS' nmoperad, 'lecia.dantas@viacredi.coop.br' dsdemail  from dual union
    select 't0014075' cdoperad, 'MAIARA DE FRANCA' nmoperad, 'maiara.franca@viacredi.coop.br' dsdemail  from dual union
    select 't0014078' cdoperad, 'THAYSE CORREA' nmoperad, 'thayse.correa@viacredi.coop.br' dsdemail  from dual union
    select 't0014168' cdoperad, 'Dalvana Correia          ' nmoperad, 'dalvana.correia@viacredi.coop.br' dsdemail  from dual union
    select 't0014169' cdoperad, 'Patricia Schmidt          ' nmoperad, 'patricia.schmidt@viacredi.coop.br' dsdemail  from dual union
    select 't0014170' cdoperad, 'Tauana Cristina Falk   ' nmoperad, 'tauana.falk@viacredi.coop.br' dsdemail  from dual union
    select 't0014197' cdoperad, 'Ana Paula Tavares' nmoperad, 'ana.tavares@viacredi.coop.br' dsdemail  from dual union
    select 't0014208' cdoperad, 'Fernanda De Kassia Nunes Meyer' nmoperad, 'fernanda.meyer@viacredi.coop.br' dsdemail  from dual union
    select 't0014210' cdoperad, 'Nelson Da Silva Junior' nmoperad, 'nelson.junior@viacredi.coop.br' dsdemail  from dual union
    select 't0031393' cdoperad, 'Jonny Zulauf' nmoperad, 'rene.santos@cecred.coop.br' dsdemail  from dual;
  rw_carga cr_carga%rowtype;
  
  cursor cr_crapcop is
    select *
      from crapcop c;
  rw_crapcop cr_crapcop%rowtype;
      
  cursor cr_crapope is
    select *
      from crapope o
     where o.cdoperad='AUTOCDC'
       and o.cdcooper=1;
  rw_crapope cr_crapope%rowtype;
  
begin
   open cr_crapope;
  fetch cr_crapope into rw_crapope;
  close cr_crapope;
  
  for rw_crapcop in cr_crapcop loop
    for rw_carga in cr_carga loop 
      
      --dbms_output.put_line('Criando usuário: ' || rw_carga.cdoperad || ' para cooperativa: ' || rw_crapcop.cdcooper);
      begin
        insert into crapope (cdoperad
                            ,cddsenha
                            ,dtaltsnh
                            ,nrdedias
                            ,nmoperad
                            ,cdsitope
                            ,nvoperad
                            ,vlpagchq
                            ,cdcooper
                            ,cdagenci
                            ,flgdopgd
                            ,flgacres
                            ,dsdlogin
                            ,flgdonet
                            ,vlapvcre
                            ,cdcomite
                            ,vlestor1
                            ,dsimpres
                            ,vlestor2
                            ,cdpactra
                            ,flgperac
                            ,vllimted
                            ,vlapvcap
                            ,cddepart
                            ,insaqesp
                            ,dsdemail
                            ,inutlcrm)
                    Values (gene0007.fn_caract_acento(rw_carga.cdoperad) -- cdoperad
                           ,rw_crapope.cddsenha
                           ,rw_crapope.dtaltsnh
                           ,rw_crapope.nrdedias
                           ,gene0007.fn_caract_acento(UPPER(rw_carga.nmoperad)) -- nome operador
                           ,rw_crapope.cdsitope
                           ,rw_crapope.nvoperad
                           ,rw_crapope.vlpagchq
                           ,rw_crapcop.cdcooper -- cooperativa
                           ,rw_crapope.cdagenci
                           ,rw_crapope.flgdopgd
                           ,rw_crapope.flgacres
                           ,rw_crapope.dsdlogin
                           ,rw_crapope.flgdonet
                           ,rw_crapope.vlapvcre
                           ,rw_crapope.cdcomite
                           ,rw_crapope.vlestor1
                           ,rw_crapope.dsimpres
                           ,rw_crapope.vlestor2
                           ,rw_crapope.cdpactra
                           ,rw_crapope.flgperac
                           ,rw_crapope.vllimted
                           ,rw_crapope.vlapvcap
                           ,rw_crapope.cddepart
                           ,rw_crapope.insaqesp
                           ,rw_carga.dsdemail -- email cooperado
                           ,rw_crapope.inutlcrm);    
      exception
        when others then
          dbms_output.put_line('Erro usúario: ' || rw_carga.cdoperad || ' Cooperativa: ' || rw_crapcop.cdcooper || ' Erro: ' || sqlerrm);
      end;                             

    end loop; -- carga
  end loop; -- coop
  COMMIT;
end;