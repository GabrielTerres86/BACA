 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Carga de códigos CNAE- Script de carga
    Projeto     : 403 - Desconto de Títulos - Release 3
    Autor       : André Ávila (GFT)
    Data        : Maio/2018
    Objetivo    : Realiza a carga dos códigos CNAE
  ---------------------------------------------------------------------------------------------------------------------*/

DECLARE

-- Dados da planilha enviada pela CECRED para carga CNAE
-- Cursor com os dados da carga CNAE

CURSOR cr_cnae
      IS
SELECT  2449102 CDCNAE, 'Producao de laminados de zinco' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2449103 CDCNAE, 'Producao de soldas e anodos para galvanoplastia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2449199 CDCNAE, 'Metalurgia de outros metais nao-ferrosos e suas ligas nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2451200 CDCNAE, 'Fundicao de ferro e aco' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2452100 CDCNAE, 'Fundicao de metais nao-ferrosos e suas ligas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2511000 CDCNAE, 'Fabricacao de estruturas metalicas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2512800 CDCNAE, 'Fabricacao de esquadrias de metal' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2513600 CDCNAE, 'Fabricacao de obras de caldeiraria pesada' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2521700 CDCNAE, 'Fabricacao de tanques, reservatorios metalicos e caldeiras para aquecimento central' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2522500 CDCNAE, 'Fabricacao de caldeiras geradoras de vapor, exceto para aquecimento central e para veiculos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2531401 CDCNAE, 'Producao de forjados de aco' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2531402 CDCNAE, 'Producao de forjados de metais nao-ferrosos e suas ligas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2532201 CDCNAE, 'Producao de artefatos estampados de metal' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2532202 CDCNAE, 'Metalurgia do po' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2539000 CDCNAE, 'Servicos de usinagem, solda, tratamento e revestimento em metais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2541100 CDCNAE, 'Fabricacao de artigos de cutelaria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2542000 CDCNAE, 'Fabricacao de artigos de serralheria, exceto esquadrias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2543800 CDCNAE, 'Fabricacao de ferramentas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2550101 CDCNAE, 'Fabricacao de equipamento belico pesado, exceto veiculos militares de combate' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2550102 CDCNAE, 'Fabricacao de armas de fogo e municoes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2591800 CDCNAE, 'Fabricacao de embalagens metalicas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2592601 CDCNAE, 'Fabricacao de produtos de trefilados de metal padronizados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2592602 CDCNAE, 'Fabricacao de produtos de trefilados de metal, exceto padronizados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2593400 CDCNAE, 'Fabricacao de artigos de metal para uso domestico e pessoal' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2599301 CDCNAE, 'Servicos de confeccao de armacoes metalicas para a construcao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2599399 CDCNAE, 'Fabricacao de outros produtos de metal nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2610800 CDCNAE, 'Fabricacao de componentes eletronicos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2621300 CDCNAE, 'Fabricacao de equipamentos de informatica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2622100 CDCNAE, 'Fabricacao de perifericos para equipamentos de informatica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2631100 CDCNAE, 'Fabricacao de equipamentos transmissores de comunicacao, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2632900 CDCNAE, 'Fabricacao de aparelhos telefonicos e de outros equipamentos de comunicacao, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2640000 CDCNAE, 'Fabricacao de aparelhos de recepcao, reproducao, gravacao e amplificacao de audio e video' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2651500 CDCNAE, 'Fabricacao de aparelhos e equipamentos de medida, teste e controle' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2652300 CDCNAE, 'Fabricacao de cronometros e relogios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2660400 CDCNAE, 'Fabricacao de aparelhos eletromedicos e eletroterapeuticos e equipamentos de irradiacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2670101 CDCNAE, 'Fabricacao de equipamentos e instrumentos opticos, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2670102 CDCNAE, 'Fabricacao de aparelhos fotograficos e cinematograficos, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2680900 CDCNAE, 'Fabricacao de midias virgens, magneticas e opticas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2710401 CDCNAE, 'Fabricacao de geradores de corrente continua e alternada, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2710402 CDCNAE, 'Fabricacao de transformadores, indutores, conversores, sincronizadores e semelhantes, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2710403 CDCNAE, 'Fabricacao de motores eletricos, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2721000 CDCNAE, 'Fabricacao de pilhas, baterias e acumuladores eletricos, exceto para veiculos automotores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2722801 CDCNAE, 'Fabricacao de baterias e acumuladores para veiculos automotores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2722802 CDCNAE, 'Recondicionamento de baterias e acumuladores para veiculos automotores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2731700 CDCNAE, 'Fabricacao de aparelhos e equipamentos para distribuicao e controle de energia eletrica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2732500 CDCNAE, 'Fabricacao de material eletrico para instalacoes em circuito de consumo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2733300 CDCNAE, 'Fabricacao de fios, cabos e condutores eletricos isolados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2740601 CDCNAE, 'Fabricacao de lampadas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2740602 CDCNAE, 'Fabricacao de luminarias e outros equipamentos de iluminacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2751100 CDCNAE, 'Fabricacao de fogoes, refrigeradores e maquinas de lavar e secar para uso domestico, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2759701 CDCNAE, 'Fabricacao de aparelhos eletricos de uso pessoal, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2759799 CDCNAE, 'Fabricacao de outros aparelhos eletrodomesticos nao especificados anteriormente, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2790201 CDCNAE, 'Fabricacao de eletrodos, contatos e outros artigos de carvao e grafita para uso eletrico, eletroimas e isoladores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2790202 CDCNAE, 'Fabricacao de equipamentos para sinalizacao e alarme' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2790299 CDCNAE, 'Fabricacao de outros equipamentos e aparelhos eletricos nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2811900 CDCNAE, 'Fabricacao de motores e turbinas, pecas e acessorios, exceto para avioes e veiculos rodoviarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2812700 CDCNAE, 'Fabricacao de equipamentos hidraulicos e pneumaticos, pecas e acessorios, exceto valvulas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2813500 CDCNAE, 'Fabricacao de valvulas, registros e dispositivos semelhantes, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2814301 CDCNAE, 'Fabricacao de compressores para uso industrial, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2814302 CDCNAE, 'Fabricacao de compressores para uso nao industrial, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2815101 CDCNAE, 'Fabricacao de rolamentos para fins industriais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2815102 CDCNAE, 'Fabricacao de equipamentos de transmissao para fins industriais, exceto rolamentos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2821601 CDCNAE, 'Fabricacao de fornos industriais, aparelhos e equipamentos nao-eletricos para instalacoes termicas, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2821602 CDCNAE, 'Fabricacao de estufas e fornos eletricos para fins industriais, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2822401 CDCNAE, 'Fabricacao de maquinas, equipamentos e aparelhos para transporte e elevacao de pessoas, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2822402 CDCNAE, 'Fabricacao de maquinas, equipamentos e aparelhos para transporte e elevacao de cargas, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2823200 CDCNAE, 'Fabricacao de maquinas e aparelhos de refrigeracao e ventilacao para uso industrial e comercial, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2824101 CDCNAE, 'Fabricacao de aparelhos e equipamentos de ar condicionado para uso industrial' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2824102 CDCNAE, 'Fabricacao de aparelhos e equipamentos de ar condicionado para uso nao-industrial' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2825900 CDCNAE, 'Fabricacao de maquinas e equipamentos para saneamento basico e ambiental, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2829101 CDCNAE, 'Fabricacao de maquinas de escrever, calcular e outros equipamentos nao-eletronicos para escritorio, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2829199 CDCNAE, 'Fabricacao de outras maquinas e equipamentos de uso geral nao especificados anteriormente, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2831300 CDCNAE, 'Fabricacao de tratores agricolas, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2832100 CDCNAE, 'Fabricacao de equipamentos para irrigacao agricola, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2833000 CDCNAE, 'Fabricacao de maquinas e equipamentos para a agricultura e pecuaria, pecas e acessorios, exceto para irrigacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2840200 CDCNAE, 'Fabricacao de maquinas-ferramenta, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2851800 CDCNAE, 'Fabricacao de maquinas e equipamentos para a prospeccao e extracao de petroleo, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2852600 CDCNAE, 'Fabricacao de outras maquinas e equipamentos para uso na extracao mineral, pecas e acessorios, exceto na extracao petroleo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2853400 CDCNAE, 'Fabricacao de tratores, pecas e acessorios, exceto agricolas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2854200 CDCNAE, 'Fabricacao de maquinas e equipamentos para terraplenagem, pavimentacao e construcao, pecas e acessorios, exceto tratores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2861500 CDCNAE, 'Fabricacao de maquinas para a industria metalurgica, pecas e acessorios, exceto maquinas-ferramenta' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2862300 CDCNAE, 'Fabricacao de maquinas e equipamentos para as industrias de alimentos, bebidas e fumo, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2863100 CDCNAE, 'Fabricacao de maquinas e equipamentos para a industria textil, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2864000 CDCNAE, 'Fabricacao de maquinas e equipamentos para as industrias do vestuario, do couro e de calcados, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2865800 CDCNAE, 'Fabricacao de maquinas e equipamentos para as industrias de celulose, papel e papelao e artefatos, pecas e acessorio' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2866600 CDCNAE, 'Fabricacao de maquinas e equipamentos para a industria do plastico, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  810009 CDCNAE, 'Extracao de basalto e beneficiamento associado' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  810010 CDCNAE, 'Beneficiamento de gesso e caulim associado a extracao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  810099 CDCNAE, 'Extracao e britamento de pedras e outros materiais para construcao e beneficiamento associado' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  891600 CDCNAE, 'Extracao de minerais para fabricacao de adubos, fertilizantes e outros produtos quimicos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  892401 CDCNAE, 'Extracao de sal marinho' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  892402 CDCNAE, 'Extracao de sal-gema' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  892403 CDCNAE, 'Refino e outros tratamentos do sal' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  893200 CDCNAE, 'Extracao de gemas (pedras preciosas e semipreciosas)' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  899101 CDCNAE, 'Extracao de grafita' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  899102 CDCNAE, 'Extracao de quartzo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  899103 CDCNAE, 'Extracao de amianto' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  899199 CDCNAE, 'Extracao de outros minerais nao-metalicos nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  910600 CDCNAE, 'Atividades de apoio a extracao de petroleo e gas natural' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  990401 CDCNAE, 'Atividades de apoio a extracao de minerio de ferro' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  990402 CDCNAE, 'Atividades de apoio a extracao de minerais metalicos nao-ferrosos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  990403 CDCNAE, 'Atividades de apoio a extracao de minerais nao-metalicos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1011201 CDCNAE, 'Frigorifico - abate de bovinos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1011202 CDCNAE, 'Frigorifico - abate de equinos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1011203 CDCNAE, 'Frigorifico - abate de ovinos e caprinos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1011204 CDCNAE, 'Frigorifico - abate de bufalinos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1011205 CDCNAE, 'Matadouro - abate de reses sob contrato - exceto abate de suinos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1012101 CDCNAE, 'Abate de aves' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1012102 CDCNAE, 'Abate de pequenos animais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1012103 CDCNAE, 'Frigorifico - abate de suinos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1012104 CDCNAE, 'Matadouro - abate de suinos sob contrato' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1013901 CDCNAE, 'Fabricacao de produtos de carne' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1013902 CDCNAE, 'Preparacao de subprodutos do abate' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1020101 CDCNAE, 'Preservacao de peixes, crustaceos e moluscos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1020102 CDCNAE, 'Fabricacao de conservas de peixes, crustaceos e moluscos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1031700 CDCNAE, 'Fabricacao de conservas de frutas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1032501 CDCNAE, 'Fabricacao de conservas de palmito' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1032599 CDCNAE, 'Fabricacao de conservas de legumes e outros vegetais, exceto palmito' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1033301 CDCNAE, 'Fabricacao de sucos concentrados de frutas, hortalicas e legumes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1033302 CDCNAE, 'Fabricacao de sucos de frutas, hortalicas e legumes, exceto concentrados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1041400 CDCNAE, 'Fabricacao de oleos vegetais em bruto, exceto oleo de milho' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1042200 CDCNAE, 'Fabricacao de oleos vegetais refinados, exceto oleo de milho' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1043100 CDCNAE, 'Fabricacao de margarina e outras gorduras vegetais e de oleos nao-comestiveis de animais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1051100 CDCNAE, 'Preparacao do leite' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1052000 CDCNAE, 'Fabricacao de laticinios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1053800 CDCNAE, 'Fabricacao de sorvetes e outros gelados comestiveis' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1061901 CDCNAE, 'Beneficiamento de arroz' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1061902 CDCNAE, 'Fabricacao de produtos do arroz' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1062700 CDCNAE, 'Moagem de trigo e fabricacao de derivados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1063500 CDCNAE, 'Fabricacao de farinha de mandioca e derivados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1064300 CDCNAE, 'Fabricacao de farinha de milho e derivados, exceto oleos de milho' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1065101 CDCNAE, 'Fabricacao de amidos e feculas de vegetais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1065102 CDCNAE, 'Fabricacao de oleo de milho em bruto' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1065103 CDCNAE, 'Fabricacao de oleo de milho refinado' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1066000 CDCNAE, 'Fabricacao de alimentos para animais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1069400 CDCNAE, 'Moagem e fabricacao de produtos de origem vegetal nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1071600 CDCNAE, 'Fabricacao de acucar em bruto' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1072401 CDCNAE, 'Fabricacao de acucar de cana refinado' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1072402 CDCNAE, 'Fabricacao de acucar de cereais (dextrose) e de beterraba' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1081301 CDCNAE, 'Beneficiamento de cafe' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1081302 CDCNAE, 'Torrefacao e moagem de cafe' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1082100 CDCNAE, 'Fabricacao de produtos a base de cafe' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1091100 CDCNAE, 'Fabricacao de produtos de panificacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1092900 CDCNAE, 'Fabricacao de biscoitos e bolachas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1093701 CDCNAE, 'Fabricacao de produtos derivados do cacau e de chocolates' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1093702 CDCNAE, 'Fabricacao de frutas cristalizadas, balas e semelhantes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1094500 CDCNAE, 'Fabricacao de massas alimenticias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1095300 CDCNAE, 'Fabricacao de especiarias, molhos, temperos e condimentos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1096100 CDCNAE, 'Fabricacao de alimentos e pratos prontos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1099601 CDCNAE, 'Fabricacao de vinagres' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1099602 CDCNAE, 'Fabricacao de pos alimenticios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1099603 CDCNAE, 'Fabricacao de fermentos e leveduras' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1099604 CDCNAE, 'Fabricacao de gelo comum' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1099605 CDCNAE, 'Fabricacao de produtos para infusao (cha, mate, etc.)' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1099606 CDCNAE, 'Fabricacao de adocantes naturais e artificiais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1099699 CDCNAE, 'Fabricacao de outros produtos alimenticios nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1111901 CDCNAE, 'Fabricacao de aguardente de cana-de-acucar' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1111902 CDCNAE, 'Fabricacao de outras aguardentes e bebidas destiladas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1112700 CDCNAE, 'Fabricacao de vinho' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1113501 CDCNAE, 'Fabricacao de malte, inclusive malte uisque' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1113502 CDCNAE, 'Fabricacao de cervejas e chopes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1121600 CDCNAE, 'Fabricacao de aguas envasadas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1122401 CDCNAE, 'Fabricacao de refrigerantes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1122402 CDCNAE, 'Fabricacao de cha mate e outros chas prontos para consumo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1122403 CDCNAE, 'Fabricacao de refrescos, xaropes e pos para refrescos, exceto refrescos de frutas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1122499 CDCNAE, 'Fabricacao de outras bebidas nao-alcoolicas nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1210700 CDCNAE, 'Processamento industrial do fumo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1220401 CDCNAE, 'Fabricacao de cigarros' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1220402 CDCNAE, 'Fabricacao de cigarrilhas e charutos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1220403 CDCNAE, 'Fabricacao de filtros para cigarros' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1220499 CDCNAE, 'Fabricacao de outros produtos do fumo, exceto cigarros, cigarrilhas e charutos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1311100 CDCNAE, 'Preparacao e fiacao de fibras de algodao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1312000 CDCNAE, 'Preparacao e fiacao de fibras texteis naturais, exceto algodao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1313800 CDCNAE, 'Fiacao de fibras artificiais e sinteticas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1314600 CDCNAE, 'Fabricacao de linhas para costurar e bordar' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1321900 CDCNAE, 'Tecelagem de fios de algodao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1322700 CDCNAE, 'Tecelagem de fios de fibras texteis naturais, exceto algodao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1323500 CDCNAE, 'Tecelagem de fios de fibras artificiais e sinteticas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1330800 CDCNAE, 'Fabricacao de tecidos de malha' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1340501 CDCNAE, 'Estamparia e texturizacao em fios, tecidos, artefatos texteis e pecas do vestuario' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1340502 CDCNAE, 'Alvejamento, tingimento e torcao em fios, tecidos, artefatos texteis e pecas do vestuario' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1340599 CDCNAE, 'Outros servicos de acabamento em fios, tecidos, artefatos texteis e pecas do vestuario' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1351100 CDCNAE, 'Fabricacao de artefatos texteis para uso domestico' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1352900 CDCNAE, 'Fabricacao de artefatos de tapecaria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1353700 CDCNAE, 'Fabricacao de artefatos de cordoaria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1354500 CDCNAE, 'Fabricacao de tecidos especiais, inclusive artefatos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1359600 CDCNAE, 'Fabricacao de outros produtos texteis nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1411801 CDCNAE, 'Confeccao de roupas intimas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1411802 CDCNAE, 'Faccao de roupas intimas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1412601 CDCNAE, 'Confeccao de pecas do vestuario, exceto roupas intimas e as confeccionadas sob medida' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1412602 CDCNAE, 'Confeccao, sob medida, de pecas do vestuario, exceto roupas intimas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1412603 CDCNAE, 'Faccao de pecas do vestuario, exceto roupas intimas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1413401 CDCNAE, 'Confeccao de roupas profissionais, exceto sob medida' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1413402 CDCNAE, 'Confeccao, sob medida, de roupas profissionais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1413403 CDCNAE, 'Faccao de roupas profissionais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1414200 CDCNAE, 'Fabricacao de acessorios do vestuario, exceto para seguranca e protecao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1421500 CDCNAE, 'Fabricacao de meias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1422300 CDCNAE, 'Fabricacao de artigos do vestuario, produzidos em malharias e tricotagens, exceto meias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1510600 CDCNAE, 'Curtimento e outras preparacoes de couro' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1521100 CDCNAE, 'Fabricacao de artigos para viagem, bolsas e semelhantes de qualquer material' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1529700 CDCNAE, 'Fabricacao de artefatos de couro nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1531901 CDCNAE, 'Fabricacao de calcados de couro' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1531902 CDCNAE, 'Acabamento de calcados de couro sob contrato' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1532700 CDCNAE, 'Fabricacao de tenis de qualquer material' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1533500 CDCNAE, 'Fabricacao de calcados de material sintetico' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1539400 CDCNAE, 'Fabricacao de calcados de materiais nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1540800 CDCNAE, 'Fabricacao de partes para calcados, de qualquer material' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1610201 CDCNAE, 'Serrarias com desdobramento de madeira' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1610202 CDCNAE, 'Serrarias sem desdobramento de madeira' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1621800 CDCNAE, 'Fabricacao de madeira laminada e de chapas de madeira compensada, prensada e aglomerada' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2869100 CDCNAE, 'Fabricacao de maquinas e equipamentos para uso industrial especifico nao especificados anteriormente, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2910701 CDCNAE, 'Fabricacao de automoveis, camionetas e utilitarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2910702 CDCNAE, 'Fabricacao de chassis com motor para automoveis, camionetas e utilitarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2910703 CDCNAE, 'Fabricacao de motores para automoveis, camionetas e utilitarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2920401 CDCNAE, 'Fabricacao de caminhoes e onibus' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2920402 CDCNAE, 'Fabricacao de motores para caminhoes e onibus' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2930101 CDCNAE, 'Fabricacao de cabines, carrocerias e reboques para caminhoes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2930102 CDCNAE, 'Fabricacao de carrocerias para onibus' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2930103 CDCNAE, 'Fabricacao de cabines, carrocerias e reboques para outros veiculos automotores, exceto caminhoes e onibus' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2941700 CDCNAE, 'Fabricacao de pecas e acessorios para o sistema motor de veiculos automotores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2942500 CDCNAE, 'Fabricacao de pecas e acessorios para os sistemas de marcha e transmissao de veiculos automotores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2943300 CDCNAE, 'Fabricacao de pecas e acessorios para o sistema de freios de veiculos automotores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2944100 CDCNAE, 'Fabricacao de pecas e acessorios para o sistema de direcao e suspensao de veiculos automotores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2945000 CDCNAE, 'Fabricacao de material eletrico e eletronico para veiculos automotores, exceto baterias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2949201 CDCNAE, 'Fabricacao de bancos e estofados para veiculos automotores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2949299 CDCNAE, 'Fabricacao de outras pecas e acessorios para veiculos automotores nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2950600 CDCNAE, 'Recondicionamento e recuperacao de motores para veiculos automotores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3011301 CDCNAE, 'Construcao de embarcacoes de grande porte' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3011302 CDCNAE, 'Construcao de embarcacoes para uso comercial e para usos especiais, exceto de grande porte' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3012100 CDCNAE, 'Construcao de embarcacoes para esporte e lazer' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3021100 CDCNAE, 'Manutencao e reparacao de embarcacoes e estruturas flutuantes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3022900 CDCNAE, 'Manutencao e reparacao de embarcacoes para esporte e lazer' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3031800 CDCNAE, 'Fabricacao de locomotivas, vagoes e outros materiais rodantes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3032600 CDCNAE, 'Fabricacao de pecas e acessorios para veiculos ferroviarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3041500 CDCNAE, 'Fabricacao de aeronaves' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3042300 CDCNAE, 'Fabricacao de turbinas, motores e outros componentes e pecas para aeronaves' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3050400 CDCNAE, 'Fabricacao de veiculos militares de combate' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3091100 CDCNAE, 'Fabricacao de motocicletas, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3092000 CDCNAE, 'Fabricacao de bicicletas e triciclos nao-motorizados, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3099700 CDCNAE, 'Fabricacao de equipamentos de transporte nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3101200 CDCNAE, 'Fabricacao de moveis com predominancia de madeira' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3102100 CDCNAE, 'Fabricacao de moveis com predominancia de metal' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3103900 CDCNAE, 'Fabricacao de moveis de outros materiais, exceto madeira e metal' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3104700 CDCNAE, 'Fabricacao de colchoes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3211601 CDCNAE, 'Lapidacao de gemas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3211602 CDCNAE, 'Fabricacao de artefatos de joalheria e ourivesaria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3211603 CDCNAE, 'Cunhagem de moedas e medalhas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3212400 CDCNAE, 'Fabricacao de bijuterias e artefatos semelhantes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3220500 CDCNAE, 'Fabricacao de instrumentos musicais, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3230200 CDCNAE, 'Fabricacao de artefatos para pesca e esporte' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3240001 CDCNAE, 'Fabricacao de jogos eletronicos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3240002 CDCNAE, 'Fabricacao de mesas de bilhar, de sinuca e acessorios nao associada a locacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3240003 CDCNAE, 'Fabricacao de mesas de bilhar, de sinuca e acessorios associada a locacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3240099 CDCNAE, 'Fabricacao de outros brinquedos e jogos recreativos nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3250701 CDCNAE, 'Fabricacao de instrumentos nao-eletronicos e utensilios para uso medico, cirurgico, odontologico e de laboratorio' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3250702 CDCNAE, 'Fabricacao de mobiliario para uso medico, cirurgico, odontologico e de laboratorio' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3250703 CDCNAE, 'Fabricacao de aparelhos e utensilios para correcao de defeitos fisicos e aparelhos ortopedicos em geral sob encomend' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3250704 CDCNAE, 'Fabricacao de aparelhos e utensilios para correcao de defeitos fisicos e aparelhos ortopedicos em geral, exceto sob encomenda' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3250705 CDCNAE, 'Fabricacao de materiais para medicina e odontologia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3250706 CDCNAE, 'Servicos de protese dentaria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3250707 CDCNAE, 'Fabricacao de artigos opticos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3250708 CDCNAE, 'Fabricacao de artefatos de tecido nao tecido para uso odonto-medico-hospitalar' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3291400 CDCNAE, 'Fabricacao de escovas, pinceis e vassouras' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3292201 CDCNAE, 'Fabricacao de roupas de protecao e seguranca e resistentes a fogo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3292202 CDCNAE, 'Fabricacao de equipamentos e acessorios para seguranca pessoal e profissional' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3299001 CDCNAE, 'Fabricacao de guarda-chuvas e similares' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3299002 CDCNAE, 'Fabricacao de canetas, lapis e outros artigos para escritorio' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3299003 CDCNAE, 'Fabricacao de letras, letreiros e placas de qualquer material, exceto luminosos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3299004 CDCNAE, 'Fabricacao de paineis e letreiros luminosos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3299005 CDCNAE, 'Fabricacao de aviamentos para costura' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3299099 CDCNAE, 'Fabricacao de produtos diversos nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3311200 CDCNAE, 'Manutencao e reparacao de tanques, reservatorios metalicos e caldeiras, exceto para veiculos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3312101 CDCNAE, 'Manutencao e reparacao de equipamentos transmissores de comunicacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3312102 CDCNAE, 'Manutencao e reparacao de aparelhos e instrumentos de medida, teste e controle' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3312103 CDCNAE, 'Manutencao e reparacao de aparelhos eletromedicos e eletroterapeuticos e equipamentos de irradiacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3312104 CDCNAE, 'Manutencao e reparacao de equipamentos e instrumentos opticos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3313901 CDCNAE, 'Manutencao e reparacao de geradores, transformadores e motores eletricos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3313902 CDCNAE, 'Manutencao e reparacao de baterias e acumuladores eletricos, exceto para veiculos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3313999 CDCNAE, 'Manutencao e reparacao de maquinas, aparelhos e materiais eletricos nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3314701 CDCNAE, 'Manutencao e reparacao de maquinas motrizes nao-eletricas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3314702 CDCNAE, 'Manutencao e reparacao de equipamentos hidraulicos e pneumaticos, exceto valvulas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3314703 CDCNAE, 'Manutencao e reparacao de valvulas industriais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3314704 CDCNAE, 'Manutencao e reparacao de compressores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3314705 CDCNAE, 'Manutencao e reparacao de equipamentos de transmissao para fins industriais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3314706 CDCNAE, 'Manutencao e reparacao de maquinas, aparelhos e equipamentos para instalacoes termicas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3314707 CDCNAE, 'Manutencao e reparacao de maquinas e aparelhos de refrigeracao e ventilacao para uso industrial e comercial' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3314708 CDCNAE, 'Manutencao e reparacao de maquinas, equipamentos e aparelhos para transporte e elevacao de cargas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3314709 CDCNAE, 'Manutencao e reparacao de maquinas de escrever, calcular e de outros equipamentos nao-eletronicos para escritorio' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3314710 CDCNAE, 'Manutencao e reparacao de maquinas e equipamentos para uso geral nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3314711 CDCNAE, 'Manutencao e reparacao de maquinas e equipamentos para agricultura e pecuaria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3314712 CDCNAE, 'Manutencao e reparacao de tratores agricolas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3314713 CDCNAE, 'Manutencao e reparacao de maquinas-ferramenta' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3314714 CDCNAE, 'Manutencao e reparacao de maquinas e equipamentos para a prospeccao e extracao de petroleo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3314715 CDCNAE, 'Manutencao e reparacao de maquinas e equipamentos para uso na extracao mineral, exceto na extracao de petroleo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3314716 CDCNAE, 'Manutencao e reparacao de tratores, exceto agricolas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3314717 CDCNAE, 'Manutencao e reparacao de maquinas e equipamentos de terraplenagem, pavimentacao e construcao, exceto tratores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3314718 CDCNAE, 'Manutencao e reparacao de maquinas para a industria metalurgica, exceto maquinas-ferramenta' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3314719 CDCNAE, 'Manutencao e reparacao de maquinas e equipamentos para as industrias de alimentos, bebidas e fumo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3314720 CDCNAE, 'Manutencao e reparacao de maquinas e equipamentos para a industria textil, do vestuario, do couro e calcados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3314721 CDCNAE, 'Manutencao e reparacao de maquinas e aparelhos para a industria de celulose, papel e papelao e artefatos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  111301 CDCNAE, 'Cultivo de arroz' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  111302 CDCNAE, 'Cultivo de milho' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  111303 CDCNAE, 'Cultivo de trigo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  111399 CDCNAE, 'Cultivo de outros cereais nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  112101 CDCNAE, 'Cultivo de algodao herbaceo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  112102 CDCNAE, 'Cultivo de juta' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  112199 CDCNAE, 'Cultivo de outras fibras de lavoura temporaria nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  113000 CDCNAE, 'Cultivo de cana-de-acucar' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  114800 CDCNAE, 'Cultivo de fumo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  115600 CDCNAE, 'Cultivo de soja' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  116401 CDCNAE, 'Cultivo de amendoim' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  116402 CDCNAE, 'Cultivo de girassol' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  116403 CDCNAE, 'Cultivo de mamona' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  116499 CDCNAE, 'Cultivo de outras oleaginosas de lavoura temporaria nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  119901 CDCNAE, 'Cultivo de abacaxi' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  119902 CDCNAE, 'Cultivo de alho' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  119903 CDCNAE, 'Cultivo de batata-inglesa' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  119904 CDCNAE, 'Cultivo de cebola' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  119905 CDCNAE, 'Cultivo de feijao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  119906 CDCNAE, 'Cultivo de mandioca' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  119907 CDCNAE, 'Cultivo de melao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  119908 CDCNAE, 'Cultivo de melancia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  119909 CDCNAE, 'Cultivo de tomate rasteiro' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  119999 CDCNAE, 'Cultivo de outras plantas de lavoura temporaria nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  121101 CDCNAE, 'Horticultura, exceto morango' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  121102 CDCNAE, 'Cultivo de morango' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  122900 CDCNAE, 'Floricultura' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  131800 CDCNAE, 'Cultivo de laranja' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  132600 CDCNAE, 'Cultivo de uva' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  133401 CDCNAE, 'Cultivo de acai' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  133402 CDCNAE, 'Cultivo de banana' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  133403 CDCNAE, 'Cultivo de caju' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  133404 CDCNAE, 'Cultivo de citricos, exceto laranja' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  133405 CDCNAE, 'Cultivo de coco-da-baia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  133406 CDCNAE, 'Cultivo de guarana' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  133407 CDCNAE, 'Cultivo de maca' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  133408 CDCNAE, 'Cultivo de mamao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  133409 CDCNAE, 'Cultivo de maracuja' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  133410 CDCNAE, 'Cultivo de manga' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  133411 CDCNAE, 'Cultivo de pessego' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  133499 CDCNAE, 'Cultivo de frutas de lavoura permanente nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  134200 CDCNAE, 'Cultivo de cafe' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  135100 CDCNAE, 'Cultivo de cacau' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  139301 CDCNAE, 'Cultivo de cha-da-india' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  139302 CDCNAE, 'Cultivo de erva-mate' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  139303 CDCNAE, 'Cultivo de pimenta-do-reino' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  139304 CDCNAE, 'Cultivo de plantas para condimento, exceto pimenta-do-reino' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  139305 CDCNAE, 'Cultivo de dende' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  139306 CDCNAE, 'Cultivo de seringueira' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  139399 CDCNAE, 'Cultivo de outras plantas de lavoura permanente nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  141501 CDCNAE, 'Producao de sementes certificadas, exceto de forrageiras para pasto' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  141502 CDCNAE, 'Producao de sementes certificadas de forrageiras para formacao de pasto' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  142300 CDCNAE, 'Producao de mudas e outras formas de propagacao vegetal, certificadas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  151201 CDCNAE, 'Criacao de bovinos para corte' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  151202 CDCNAE, 'Criacao de bovinos para leite' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  151203 CDCNAE, 'Criacao de bovinos, exceto para corte e leite' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  152101 CDCNAE, 'Criacao de bufalinos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  152102 CDCNAE, 'Criacao de equinos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  152103 CDCNAE, 'Criacao de asininos e muares' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  153901 CDCNAE, 'Criacao de caprinos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  153902 CDCNAE, 'Criacao de ovinos, inclusive para producao de la' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  154700 CDCNAE, 'Criacao de suinos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  155501 CDCNAE, 'Criacao de frangos para corte' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  155502 CDCNAE, 'Producao de pintos de um dia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  155503 CDCNAE, 'Criacao de outros galinaceos, exceto para corte' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  155504 CDCNAE, 'Criacao de aves, exceto galinaceos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  155505 CDCNAE, 'Producao de ovos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  159801 CDCNAE, 'Apicultura' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  159802 CDCNAE, 'Criacao de animais de estimacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  159803 CDCNAE, 'Criacao de escargo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  159804 CDCNAE, 'Criacao de bicho-da-seda' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  159899 CDCNAE, 'Criacao de outros animais nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  161001 CDCNAE, 'Servico de pulverizacao e controle de pragas agricolas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  161002 CDCNAE, 'Servico de poda de arvores para lavouras' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  161003 CDCNAE, 'Servico de preparacao de terreno, cultivo e colheita' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  161099 CDCNAE, 'Atividades de apoio a agricultura nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  162801 CDCNAE, 'Servico de inseminacao artificial de animais *' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  162802 CDCNAE, 'Servico de tosquiamento de ovinos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  162803 CDCNAE, 'Servico de manejo de animais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  162899 CDCNAE, 'Atividades de apoio a pecuaria nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  163600 CDCNAE, 'Atividades de pos-colheita' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  170900 CDCNAE, 'Caca e servicos relacionados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  210101 CDCNAE, 'Cultivo de eucalipto' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  210102 CDCNAE, 'Cultivo de acacia-negra' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  210103 CDCNAE, 'Cultivo de pinus' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  210104 CDCNAE, 'Cultivo de teca' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  210105 CDCNAE, 'Cultivo de especies madeireiras, exceto eucalipto, acacia-negra, pinus e teca' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  210106 CDCNAE, 'Cultivo de mudas em viveiros florestais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  210107 CDCNAE, 'Extracao de madeira em florestas plantadas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  210108 CDCNAE, 'Producao de carvao vegetal - florestas plantadas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  210109 CDCNAE, 'Producao de casca de acacia-negra - florestas plantadas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  210199 CDCNAE, 'Producao de produtos nao-madeireiros nao especificados anteriormente em florestas plantadas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  220901 CDCNAE, 'Extracao de madeira em florestas nativas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  220902 CDCNAE, 'Producao de carvao vegetal - florestas nativas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  220903 CDCNAE, 'Coleta de castanha-do-para em florestas nativas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  220904 CDCNAE, 'Coleta de latex em florestas nativas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  220905 CDCNAE, 'Coleta de palmito em florestas nativas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  220906 CDCNAE, 'Conservacao de florestas nativas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  220999 CDCNAE, 'Coleta de produtos nao-madeireiros nao especificados anteriormente em florestas nativas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  230600 CDCNAE, 'Atividades de apoio a producao florestal' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  311601 CDCNAE, 'Pesca de peixes em agua salgada' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  311602 CDCNAE, 'Pesca de crustaceos e moluscos em agua salgada' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  311603 CDCNAE, 'Coleta de outros produtos marinhos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  311604 CDCNAE, 'Atividades de apoio a pesca em agua salgada' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  312401 CDCNAE, 'Pesca de peixes em agua doce' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  312402 CDCNAE, 'Pesca de crustaceos e moluscos em agua doce' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  312403 CDCNAE, 'Coleta de outros produtos aquaticos de agua doce' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  312404 CDCNAE, 'Atividades de apoio a pesca em agua doce' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  321301 CDCNAE, 'Criacao de peixes em agua salgada e salobra' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  321302 CDCNAE, 'Criacao de camaroes em agua salgada e salobra' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  321303 CDCNAE, 'Criacao de ostras e mexilhoes em agua salgada e salobra' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  321304 CDCNAE, 'Criacao de peixes ornamentais em agua salgada e salobra' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  321305 CDCNAE, 'Atividades de apoio a aquicultura em agua salgada e salobra' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  321399 CDCNAE, 'Cultivos e semicultivos da aquicultura em agua salgada e salobra nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  322101 CDCNAE, 'Criacao de peixes em agua doce' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  322102 CDCNAE, 'Criacao de camaroes em agua doce' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  322103 CDCNAE, 'Criacao de ostras e mexilhoes em agua doce' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  322104 CDCNAE, 'Criacao de peixes ornamentais em agua doce' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  322105 CDCNAE, 'Ranicultura' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  322106 CDCNAE, 'Criacao de jacare' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  322107 CDCNAE, 'Atividades de apoio a aquicultura em agua doce' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  322199 CDCNAE, 'Cultivos e semicultivos da aquicultura em agua doce nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  500301 CDCNAE, 'Extracao de carvao mineral' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  500302 CDCNAE, 'Beneficiamento de carvao mineral' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  600001 CDCNAE, 'Extracao de petroleo e gas natural' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  600002 CDCNAE, 'Extracao e beneficiamento de xisto' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  600003 CDCNAE, 'Extracao e beneficiamento de areias betuminosas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  710301 CDCNAE, 'Extracao de minerio de ferro' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  710302 CDCNAE, 'Pelotizacao, sinterizacao e outros beneficiamentos de minerio de ferro' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  721901 CDCNAE, 'Extracao de minerio de aluminio' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  721902 CDCNAE, 'Beneficiamento de minerio de aluminio' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  722701 CDCNAE, 'Extracao de minerio de estanho' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  722702 CDCNAE, 'Beneficiamento de minerio de estanho' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  723501 CDCNAE, 'Extracao de minerio de manganes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  723502 CDCNAE, 'Beneficiamento de minerio de manganes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  724301 CDCNAE, 'Extracao de minerio de metais preciosos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  724302 CDCNAE, 'Beneficiamento de minerio de metais preciosos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  725100 CDCNAE, 'Extracao de minerais radioativos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  729401 CDCNAE, 'Extracao de minerios de niobio e titanio' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  729402 CDCNAE, 'Extracao de minerio de tungstenio' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  729403 CDCNAE, 'Extracao de minerio de niquel' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  729404 CDCNAE, 'Extracao de minerios de cobre, chumbo, zinco e outros minerais metalicos nao-ferrosos nao especificados anteriorment' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  729405 CDCNAE, 'Beneficiamento de minerios de cobre, chumbo, zinco e outros minerais metalicos nao-ferrosos nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  810001 CDCNAE, 'Extracao de ardosia e beneficiamento associado' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  810002 CDCNAE, 'Extracao de granito e beneficiamento associado' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  810003 CDCNAE, 'Extracao de marmore e beneficiamento associado' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  810004 CDCNAE, 'Extracao de calcario e dolomita e beneficiamento associado' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  810005 CDCNAE, 'Extracao de gesso e caulim' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  810006 CDCNAE, 'Extracao de areia, cascalho ou pedregulho e beneficiamento associado' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  810007 CDCNAE, 'Extracao de argila e beneficiamento associado' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  810008 CDCNAE, 'Extracao de saibro e beneficiamento associado' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1622602 CDCNAE, 'Fabricacao de esquadrias de madeira e de pecas de madeira para instalacoes industriais e comerciais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1622699 CDCNAE, 'Fabricacao de outros artigos de carpintaria para construcao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1623400 CDCNAE, 'Fabricacao de artefatos de tanoaria e de embalagens de madeira' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1629301 CDCNAE, 'Fabricacao de artefatos diversos de madeira, exceto moveis' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1629302 CDCNAE, 'Fabricacao de artefatos diversos de cortica, bambu, palha, vime e outros materiais trancados, exceto moveis' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1710900 CDCNAE, 'Fabricacao de celulose e outras pastas para a fabricacao de papel' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1721400 CDCNAE, 'Fabricacao de papel' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1722200 CDCNAE, 'Fabricacao de cartolina e papel-cartao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1731100 CDCNAE, 'Fabricacao de embalagens de papel' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1732000 CDCNAE, 'Fabricacao de embalagens de cartolina e papel-cartao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1733800 CDCNAE, 'Fabricacao de chapas e de embalagens de papelao ondulado' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1741901 CDCNAE, 'Fabricacao de formularios continuos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1741902 CDCNAE, 'Fabricacao de produtos de papel, cartolina, papel-cartao e papelao ondulado para uso industrial, comercial e de escritor exceto formulario continuo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1742701 CDCNAE, 'Fabricacao de fraldas descartaveis' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1742702 CDCNAE, 'Fabricacao de absorventes higienicos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1742799 CDCNAE, 'Fabricacao de produtos de papel para uso domestico e higienico-sanitario nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1749400 CDCNAE, 'Fabricacao de produtos de pastas celulosicas, papel, cartolina, papel-cartao e papelao ondulado nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1811301 CDCNAE, 'Impressao de jornais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1811302 CDCNAE, 'Impressao de livros, revistas e outras publicacoes periodicas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1812100 CDCNAE, 'Impressao de material de seguranca' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1813001 CDCNAE, 'Impressao de material para uso publicitario' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1813099 CDCNAE, 'Impressao de material para outros usos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1821100 CDCNAE, 'Servicos de pre-impressao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1822900 CDCNAE, 'Servicos de acabamentos graficos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1830001 CDCNAE, 'Reproducao de som em qualquer suporte' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1830002 CDCNAE, 'Reproducao de video em qualquer suporte' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1830003 CDCNAE, 'Reproducao de software em qualquer suporte' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1910100 CDCNAE, 'Coquerias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1921700 CDCNAE, 'Fabricacao de produtos do refino de petroleo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1922501 CDCNAE, 'Formulacao de combustiveis' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1922502 CDCNAE, 'Rerrefino de oleos lubrificantes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1922599 CDCNAE, 'Fabricacao de outros produtos derivados do petroleo, exceto produtos do refino' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1931400 CDCNAE, 'Fabricacao de alcool' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1932200 CDCNAE, 'Fabricacao de biocombustiveis, exceto alcool' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2011800 CDCNAE, 'Fabricacao de cloro e alcalis' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2012600 CDCNAE, 'Fabricacao de intermediarios para fertilizantes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2013400 CDCNAE, 'Fabricacao de adubos e fertilizantes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2014200 CDCNAE, 'Fabricacao de gases industriais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2019301 CDCNAE, 'Elaboracao de combustiveis nucleares' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2019399 CDCNAE, 'Fabricacao de outros produtos quimicos inorganicos nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2021500 CDCNAE, 'Fabricacao de produtos petroquimicos basicos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2022300 CDCNAE, 'Fabricacao de intermediarios para plastificantes, resinas e fibras' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2029100 CDCNAE, 'Fabricacao de produtos quimicos organicos nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2031200 CDCNAE, 'Fabricacao de resinas termoplasticas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2032100 CDCNAE, 'Fabricacao de resinas termofixas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2033900 CDCNAE, 'Fabricacao de elastomeros' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2040100 CDCNAE, 'Fabricacao de fibras artificiais e sinteticas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2051700 CDCNAE, 'Fabricacao de defensivos agricolas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2052500 CDCNAE, 'Fabricacao de desinfestantes domissanitarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2061400 CDCNAE, 'Fabricacao de saboes e detergentes sinteticos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2062200 CDCNAE, 'Fabricacao de produtos de limpeza e polimento' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2063100 CDCNAE, 'Fabricacao de cosmeticos, produtos de perfumaria e de higiene pessoal' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2071100 CDCNAE, 'Fabricacao de tintas, vernizes, esmaltes e lacas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2072000 CDCNAE, 'Fabricacao de tintas de impressao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2073800 CDCNAE, 'Fabricacao de impermeabilizantes, solventes e produtos afins' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2091600 CDCNAE, 'Fabricacao de adesivos e selantes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2092401 CDCNAE, 'Fabricacao de polvoras, explosivos e detonantes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2092402 CDCNAE, 'Fabricacao de artigos pirotecnicos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2092403 CDCNAE, 'Fabricacao de fosforos de seguranca' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2093200 CDCNAE, 'Fabricacao de aditivos de uso industrial' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2094100 CDCNAE, 'Fabricacao de catalisadores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2099101 CDCNAE, 'Fabricacao de chapas, filmes, papeis e outros materiais e produtos quimicos para fotografia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2099199 CDCNAE, 'Fabricacao de outros produtos quimicos nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2110600 CDCNAE, 'Fabricacao de produtos farmoquimicos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2121101 CDCNAE, 'Fabricacao de medicamentos alopaticos para uso humano' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2121102 CDCNAE, 'Fabricacao de medicamentos homeopaticos para uso humano' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2121103 CDCNAE, 'Fabricacao de medicamentos fitoterapicos para uso humano' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2122000 CDCNAE, 'Fabricacao de medicamentos para uso veterinario' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2123800 CDCNAE, 'Fabricacao de preparacoes farmaceuticas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2211100 CDCNAE, 'Fabricacao de pneumaticos e de camaras-de-ar' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2212900 CDCNAE, 'Reforma de pneumaticos usados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2219600 CDCNAE, 'Fabricacao de artefatos de borracha nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2221800 CDCNAE, 'Fabricacao de laminados planos e tubulares de material plastico' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2222600 CDCNAE, 'Fabricacao de embalagens de material plastico' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2223400 CDCNAE, 'Fabricacao de tubos e acessorios de material plastico para uso na construcao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2229301 CDCNAE, 'Fabricacao de artefatos de material plastico para uso pessoal e domestico' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2229302 CDCNAE, 'Fabricacao de artefatos de material plastico para usos industriais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2229303 CDCNAE, 'Fabricacao de artefatos de material plastico para uso na construcao, exceto tubos e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2229399 CDCNAE, 'Fabricacao de artefatos de material plastico para outros usos nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2311700 CDCNAE, 'Fabricacao de vidro plano e de seguranca' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2312500 CDCNAE, 'Fabricacao de embalagens de vidro' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2319200 CDCNAE, 'Fabricacao de artigos de vidro' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2320600 CDCNAE, 'Fabricacao de cimento' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2330301 CDCNAE, 'Fabricacao de estruturas pre-moldadas de concreto armado, em serie e sob encomenda' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2330302 CDCNAE, 'Fabricacao de artefatos de cimento para uso na construcao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2330303 CDCNAE, 'Fabricacao de artefatos de fibrocimento para uso na construcao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2330304 CDCNAE, 'Fabricacao de casas pre-moldadas de concreto' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2330305 CDCNAE, 'Preparacao de massa de concreto e argamassa para construcao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2330399 CDCNAE, 'Fabricacao de outros artefatos e produtos de concreto, cimento, fibrocimento, gesso e materiais semelhantes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2341900 CDCNAE, 'Fabricacao de produtos ceramicos refratarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2342701 CDCNAE, 'Fabricacao de azulejos e pisos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2342702 CDCNAE, 'Fabricacao de artefatos de ceramica e barro cozido para uso na construcao, exceto azulejos e pisos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2349401 CDCNAE, 'Fabricacao de material sanitario de ceramica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2349499 CDCNAE, 'Fabricacao de produtos ceramicos nao-refratarios nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2391501 CDCNAE, 'Britamento de pedras, exceto associado a extracao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2391502 CDCNAE, 'Aparelhamento de pedras para construcao, exceto associado a extracao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2391503 CDCNAE, 'Aparelhamento de placas e execucao de trabalhos em marmore, granito, ardosia e outras pedras' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2392300 CDCNAE, 'Fabricacao de cal e gesso' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2399101 CDCNAE, 'Decoracao, lapidacao, gravacao, vitrificacao e outros trabalhos em ceramica, louca, vidro e cristal' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2399199 CDCNAE, 'Fabricacao de outros produtos de minerais nao-metalicos nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2411300 CDCNAE, 'Producao de ferro-gusa' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2412100 CDCNAE, 'Producao de ferroligas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2421100 CDCNAE, 'Producao de semi-acabados de aco' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2422901 CDCNAE, 'Producao de laminados planos de aco ao carbono, revestidos ou nao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2422902 CDCNAE, 'Producao de laminados planos de acos especiais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2423701 CDCNAE, 'Producao de tubos de aco sem costura' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2423702 CDCNAE, 'Producao de laminados longos de aco, exceto tubos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2424501 CDCNAE, 'Producao de arames de aco' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2424502 CDCNAE, 'Producao de relaminados, trefilados e perfilados de aco, exceto arames' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2431800 CDCNAE, 'Producao de tubos de aco com costura' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2439300 CDCNAE, 'Producao de outros tubos de ferro e aco' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2441501 CDCNAE, 'Producao de aluminio e suas ligas em formas primarias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2441502 CDCNAE, 'Producao de laminados de aluminio' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2442300 CDCNAE, 'Metalurgia dos metais preciosos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2443100 CDCNAE, 'Metalurgia do cobre' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2449101 CDCNAE, 'Producao de zinco em formas primarias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9001999 CDCNAE, 'Artes cenicas, espetaculos e atividades complementares nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9002701 CDCNAE, 'Atividades de artistas plasticos, jornalistas independentes e escritores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9002702 CDCNAE, 'Restauracao de obras-de-arte' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9003500 CDCNAE, 'Gestao de espacos para artes cenicas, espetaculos e outras atividades artisticas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9101500 CDCNAE, 'Atividades de bibliotecas e arquivos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9102301 CDCNAE, 'Atividades de museus e de exploracao de lugares e predios historicos e atracoes similares' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9102302 CDCNAE, 'Restauracao e conservacao de lugares e predios historicos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9103100 CDCNAE, 'Atividades de jardins botanicos, zoologicos, parques nacionais, reservas ecologicas e areas de protecao ambiental' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9200301 CDCNAE, 'Casas de bingo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9200302 CDCNAE, 'Exploracao de apostas em corridas de cavalos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9200399 CDCNAE, 'Exploracao de jogos de azar e apostas nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9311500 CDCNAE, 'Gestao de instalacoes de esportes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9312300 CDCNAE, 'Clubes sociais, esportivos e similares' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9313100 CDCNAE, 'Atividades de condicionamento fisico' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9319101 CDCNAE, 'Producao e promocao de eventos esportivos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9319199 CDCNAE, 'Outras atividades esportivas nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9321200 CDCNAE, 'Parques de diversao e parques tematicos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9329801 CDCNAE, 'Discotecas, danceterias, saloes de danca e similares' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9329802 CDCNAE, 'Exploracao de boliches' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9329803 CDCNAE, 'Exploracao de jogos de sinuca, bilhar e similares' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9329804 CDCNAE, 'Exploracao de jogos eletronicos recreativos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9329899 CDCNAE, 'Outras atividades de recreacao e lazer nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9411100 CDCNAE, 'Atividades de organizacoes associativas patronais e empresariais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9412000 CDCNAE, 'Atividades de organizacoes associativas profissionais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9420100 CDCNAE, 'Atividades de organizacoes sindicais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9430800 CDCNAE, 'Atividades de associacoes de defesa de direitos sociais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9491000 CDCNAE, 'Atividades de organizacoes religiosas' DSCNAE, '0' FLSERASA FROM DUAL UNION 
SELECT  9492800 CDCNAE, 'Atividades de organizacoes politicas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9493600 CDCNAE, 'Atividades de organizacoes associativas ligadas a cultura e a arte' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9499500 CDCNAE, 'Atividades associativas nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9511800 CDCNAE, 'Reparacao e manutencao de computadores e de equipamentos perifericos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9512600 CDCNAE, 'Reparacao e manutencao de equipamentos de comunicacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9521500 CDCNAE, 'Reparacao e manutencao de equipamentos eletroeletronicos de uso pessoal e domestico' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9529101 CDCNAE, 'Reparacao de calcados, de bolsas e artigos de viagem*' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9529102 CDCNAE, 'Chaveiros' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9529103 CDCNAE, 'Reparacao de relogios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9529104 CDCNAE, 'Reparacao de bicicletas, triciclos e outros veiculos nao-motorizados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9529105 CDCNAE, 'Reparacao de artigos do mobiliario' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9529106 CDCNAE, 'Reparacao de joias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9529199 CDCNAE, 'Reparacao e manutencao de outros objetos e equipamentos pessoais e domesticos nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9601701 CDCNAE, 'Lavanderias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9601702 CDCNAE, 'Tinturarias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9601703 CDCNAE, 'Toalheiros' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9602501 CDCNAE, 'Cabeleireiros' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9602502 CDCNAE, 'Outras atividades de tratamento de beleza' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9603301 CDCNAE, 'Gestao e manutencao de cemiterios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9603302 CDCNAE, 'Servicos de cremacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9603303 CDCNAE, 'Servicos de sepultamento' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9603304 CDCNAE, 'Servicos de funerarias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9603305 CDCNAE, 'Servicos de somatoconservacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9603399 CDCNAE, 'Atividades funerarias e servicos relacionados nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9609201 CDCNAE, 'Clinicas de estetica e similares*' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9609202 CDCNAE, 'Agencias matrimoniais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9609203 CDCNAE, 'Alojamento, higiene e embelezamento de animais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9609204 CDCNAE, 'Exploracao de maquinas de servicos pessoais acionadas por moeda' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9609299 CDCNAE, 'Outras atividades de servicos pessoais nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9700500 CDCNAE, 'Servicos domesticos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9900800 CDCNAE, 'Organismos internacionais e outras instituicoes extraterritoriais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4921302 CDCNAE, 'Transporte rodoviario coletivo de passageiros, com itinerario fixo, intermunicipal em regiao metropolitana' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4922101 CDCNAE, 'Transporte rodoviario coletivo de passageiros, com itinerario fixo, intermunicipal, exceto em regiao metropolitana' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4922102 CDCNAE, 'Transporte rodoviario coletivo de passageiros, com itinerario fixo, interestadual' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4922103 CDCNAE, 'Transporte rodoviario coletivo de passageiros, com itinerario fixo, internacional' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4923001 CDCNAE, 'Servico de taxi' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4923002 CDCNAE, 'Servico de transporte de passageiros - locacao de automoveis com motorista' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4924800 CDCNAE, 'Transporte escolar' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4929901 CDCNAE, 'Transporte rodoviario coletivo de passageiros, sob regime de fretamento, municipal' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4929902 CDCNAE, 'Transporte rodoviario coletivo de passageiros, sob regime de fretamento, intermunicipal, interestadual e internacional' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4929903 CDCNAE, 'Organizacao de excursoes em veiculos rodoviarios proprios, municipal' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4929904 CDCNAE, 'Organizacao de excursoes em veiculos rodoviarios proprios, intermunicipal, interestadual e internacional' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4929999 CDCNAE, 'Outros transportes rodoviarios de passageiros nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4930201 CDCNAE, 'Transporte rodoviario de carga, exceto produtos perigosos e mudancas, municipal' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4930202 CDCNAE, 'Transporte rodoviario de carga, exceto produtos perigosos e mudancas, intermunicipal, interestadual e internacional' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4930203 CDCNAE, 'Transporte rodoviario de produtos perigosos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4930204 CDCNAE, 'Transporte rodoviario de mudancas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4940000 CDCNAE, 'Transporte dutoviario' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4950700 CDCNAE, 'Trens turisticos, telefericos e similares' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5011401 CDCNAE, 'Transporte maritimo de cabotagem - Carga' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5011402 CDCNAE, 'Transporte maritimo de cabotagem - passageiros' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5012201 CDCNAE, 'Transporte maritimo de longo curso - Carga' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5012202 CDCNAE, 'Transporte maritimo de longo curso - Passageiros' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5021101 CDCNAE, 'Transporte por navegacao interior de carga, municipal, exceto travessia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5021102 CDCNAE, 'Transporte por navegacao interior de carga, intermunicipal, interestadual e internacional, exceto travessia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5022001 CDCNAE, 'Transporte por navegacao interior de passageiros em linhas regulares, municipal, exceto travessia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5022002 CDCNAE, 'Transporte por navegacao interior de passageiros em linhas regulares, intermunicipal, interestadual e internacional, exc travessia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5030101 CDCNAE, 'Navegacao de apoio maritimo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5030102 CDCNAE, 'Navegacao de apoio portuario' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5091201 CDCNAE, 'Transporte por navegacao de travessia, municipal' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5091202 CDCNAE, 'Transporte por navegacao de travessia, intermunicipal' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5099801 CDCNAE, 'Transporte aquaviario para passeios turisticos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5099899 CDCNAE, 'Outros transportes aquaviarios nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5111100 CDCNAE, 'Transporte aereo de passageiros regular' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5112901 CDCNAE, 'Servico de taxi aereo e locacao de aeronaves com tripulacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5112999 CDCNAE, 'Outros servicos de transporte aereo de passageiros nao-regular' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5120000 CDCNAE, 'Transporte aereo de carga' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5130700 CDCNAE, 'Transporte espacial' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5211701 CDCNAE, 'Armazens gerais - emissao de warrant' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5211702 CDCNAE, 'Guarda-moveis' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5211799 CDCNAE, 'Depositos de mercadorias para terceiros, exceto armazens gerais e guarda-moveis' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5212500 CDCNAE, 'Carga e descarga' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5221400 CDCNAE, 'Concessionarias de rodovias, pontes, tuneis e servicos relacionados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5222200 CDCNAE, 'Terminais rodoviarios e ferroviarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5223100 CDCNAE, 'Estacionamento de veiculos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5229001 CDCNAE, 'Servicos de apoio ao transporte por taxi, inclusive centrais de chamada' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5229002 CDCNAE, 'Servicos de reboque de veiculos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5229099 CDCNAE, 'Outras atividades auxiliares dos transportes terrestres nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5231101 CDCNAE, 'Administracao da infra-estrutura portuaria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5231102 CDCNAE, 'Operacoes de terminais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5232000 CDCNAE, 'Atividades de agenciamento maritimo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5239700 CDCNAE, 'Atividades auxiliares dos transportes aquaviarios nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5240101 CDCNAE, 'Operacao dos aeroportos e campos de aterrissagem' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5240199 CDCNAE, 'Atividades auxiliares dos transportes aereos, exceto operacao dos aeroportos e campos de aterrissagem' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5250801 CDCNAE, 'Comissaria de despachos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5250802 CDCNAE, 'Atividades de despachantes aduaneiros' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5250803 CDCNAE, 'Agenciamento de cargas, exceto para o transporte maritimo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5250804 CDCNAE, 'Organizacao logistica do transporte de carga' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5250805 CDCNAE, 'Operador de transporte multimodal - OTM' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5310501 CDCNAE, 'Atividades do Correio Nacional' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5310502 CDCNAE, 'Atividades de  franqueadas e permissionarias do Correio Nacional' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5320201 CDCNAE, 'Servicos de malote nao realizados pelo Correio Nacional' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5320202 CDCNAE, 'Servicos de entrega rapida' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5510801 CDCNAE, 'Hoteis' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5510802 CDCNAE, 'Apart-hoteis' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5510803 CDCNAE, 'Moteis' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5590601 CDCNAE, 'Albergues, exceto assistenciais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5590602 CDCNAE, 'Campings' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5590603 CDCNAE, 'Pensoes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5590699 CDCNAE, 'Outros alojamentos nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5611201 CDCNAE, 'Restaurantes e similares' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5611202 CDCNAE, 'Bares e outros estabelecimentos especializados em servir bebidas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5611203 CDCNAE, 'Lanchonetes, casas de cha, de sucos e similares' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5612100 CDCNAE, 'Servicos ambulantes de alimentacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5620101 CDCNAE, 'Fornecimento de alimentos preparados preponderantemente para empresas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5620102 CDCNAE, 'Servicos de alimentacao para eventos e recepcoes - bufe' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5620103 CDCNAE, 'Cantinas - servicos de alimentacao privativos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5620104 CDCNAE, 'Fornecimento de alimentos preparados preponderantemente para consumo domiciliar' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5811500 CDCNAE, 'Edicao de livros' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5812300 CDCNAE, 'Edicao de jornais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5813100 CDCNAE, 'Edicao de revistas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5819100 CDCNAE, 'Edicao de cadastros, listas e de outros produtos graficos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5821200 CDCNAE, 'Edicao integrada a impressao de livros' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5822100 CDCNAE, 'Edicao integrada a impressao de jornais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5823900 CDCNAE, 'Edicao integrada a impressao de revistas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5829800 CDCNAE, 'Edicao integrada a impressao de cadastros, listas e de outros produtos graficos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5911101 CDCNAE, 'Estudios cinematograficos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5911102 CDCNAE, 'Producao de filmes para publicidade' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5911199 CDCNAE, 'Atividades de producao cinematografica, de videos e de programas de televisao nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5912001 CDCNAE, 'Servicos de dublagem' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5912002 CDCNAE, 'Servicos de mixagem sonora' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5912099 CDCNAE, 'Atividades de pos-producao cinematografica, de videos e de programas de televisao nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5913800 CDCNAE, 'Distribuicao cinematografica, de video e de programas de televisao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5914600 CDCNAE, 'Atividades de exibicao cinematografica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5920100 CDCNAE, 'Atividades de gravacao de som e de edicao de musica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6010100 CDCNAE, 'Atividades de radio' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6021700 CDCNAE, 'Atividades de televisao aberta' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6022501 CDCNAE, 'Programadoras' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6022502 CDCNAE, 'Atividades relacionadas a televisao por assinatura, exceto programadoras' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6110801 CDCNAE, 'Servicos de telefonia fixa comutada - STFC' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6110802 CDCNAE, 'Servicos de redes de transportes de telecomunicacoes - SRTT' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6110803 CDCNAE, 'Servicos de comunicacao multimidia - SMC' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6110899 CDCNAE, 'Servicos de telecomunicacoes por fio nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6120501 CDCNAE, 'Telefonia movel celular' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6120502 CDCNAE, 'Servico movel especializado - SME' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6120599 CDCNAE, 'Servicos de telecomunicacoes sem fio nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6130200 CDCNAE, 'Telecomunicacoes por satelite' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6141800 CDCNAE, 'Operadoras de televisao por assinatura por cabo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6142600 CDCNAE, 'Operadoras de televisao por assinatura por microondas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6143400 CDCNAE, 'Operadoras de televisao por assinatura por satelite' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6190601 CDCNAE, 'Provedores de acesso as redes de comunicacoes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6190602 CDCNAE, 'Provedores de voz sobre protocolo internet - VOIP' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6190699 CDCNAE, 'Outras atividades de telecomunicacoes nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6201500 CDCNAE, 'Desenvolvimento de programas de computador sob encomenda' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6202300 CDCNAE, 'Desenvolvimento e licenciamento de programas de computador customizaveis' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6203100 CDCNAE, 'Desenvolvimento e licenciamento de programas de computador nao-customizaveis' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6204000 CDCNAE, 'Consultoria em tecnologia da informacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6209100 CDCNAE, 'Suporte tecnico, manutencao e outros servicos em tecnologia da informacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6311900 CDCNAE, 'Tratamento de dados, provedores de servicos de aplicacao e servicos de hospedagem na internet' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6319400 CDCNAE, 'Portais, provedores de conteudo e outros servicos de informacao na internet' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6391700 CDCNAE, 'Agencias de noticias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6399200 CDCNAE, 'Outras atividades de prestacao de servicos de informacao nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6410700 CDCNAE, 'Banco Central' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6421200 CDCNAE, 'Bancos comerciais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6422100 CDCNAE, 'Bancos multiplos, com carteira comercial' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6423900 CDCNAE, 'Caixas economicas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6424701 CDCNAE, 'Bancos cooperativos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6424702 CDCNAE, 'Cooperativas centrais de credito' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6424703 CDCNAE, 'Cooperativas de credito mutuo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6424704 CDCNAE, 'Cooperativas de credito rural' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6431000 CDCNAE, 'Bancos multiplos, sem carteira comercial' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6432800 CDCNAE, 'Bancos de investimento' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6433600 CDCNAE, 'Bancos de desenvolvimento' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6434400 CDCNAE, 'Agencias de fomento' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6435201 CDCNAE, 'Sociedades de credito imobiliario' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6435202 CDCNAE, 'Associacoes de poupanca e emprestimo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6435203 CDCNAE, 'Companhias hipotecarias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6436100 CDCNAE, 'Sociedades de credito, financiamento e investimento - financeiras' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6437900 CDCNAE, 'Sociedades de credito ao microempreendedor' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6440900 CDCNAE, 'Arrendamento mercantil' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6450600 CDCNAE, 'Sociedades de capitalizacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6461100 CDCNAE, 'Holdings de instituicoes financeiras' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6462000 CDCNAE, 'Holdings de instituicoes nao-financeiras' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6463800 CDCNAE, 'Outras sociedades de participacao, exceto holdings' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6470101 CDCNAE, 'Fundos de investimento, exceto previdenciarios e imobiliarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6470102 CDCNAE, 'Fundos de investimento previdenciarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6470103 CDCNAE, 'Fundos de investimento imobiliarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6491300 CDCNAE, 'Sociedades de fomento mercantil - factoring' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6492100 CDCNAE, 'Securitizacao de creditos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6493000 CDCNAE, 'Administracao de consorcios para aquisicao de bens e direitos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6499901 CDCNAE, 'Clubes de investimento' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6499902 CDCNAE, 'Sociedades de investimento' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6499903 CDCNAE, 'Fundo garantidor de credito' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6499904 CDCNAE, 'Caixas de financiamento de corporacoes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6499905 CDCNAE, 'Concessao de credito pelas OSCIP' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6499999 CDCNAE, 'Outras atividades de servicos financeiros nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6511101 CDCNAE, 'Seguros de vida' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6511102 CDCNAE, 'Planos de auxilio-funeral' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6512000 CDCNAE, 'Seguros nao-vida' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6520100 CDCNAE, 'Seguros-saude' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6530800 CDCNAE, 'Resseguros' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6541300 CDCNAE, 'Previdencia complementar fechada' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6542100 CDCNAE, 'Previdencia complementar aberta' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6550200 CDCNAE, 'Planos de saude' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6611801 CDCNAE, 'Bolsa de valores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6611802 CDCNAE, 'Bolsa de mercadorias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6611803 CDCNAE, 'Bolsa de mercadorias e futuros' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6611804 CDCNAE, 'Administracao de mercados de balcao organizados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6612601 CDCNAE, 'Corretoras de titulos e valores mobiliarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6612602 CDCNAE, 'Distribuidoras de titulos e valores mobiliarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6612603 CDCNAE, 'Corretoras de cambio' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6612604 CDCNAE, 'Corretoras de contratos de mercadorias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6612605 CDCNAE, 'Agentes de investimentos em aplicacoes financeiras' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6613400 CDCNAE, 'Administracao de cartoes de credito' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6619301 CDCNAE, 'Servicos de liquidacao e custodia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6619302 CDCNAE, 'Correspondentes de instituicoes financeiras' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6619303 CDCNAE, 'Representacoes de bancos estrangeiros' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6619304 CDCNAE, 'Caixas eletronicos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6619305 CDCNAE, 'Operadoras de cartoes de debito' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6619399 CDCNAE, 'Outras atividades auxiliares dos servicos financeiros nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6621501 CDCNAE, 'Peritos e avaliadores de seguros' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6621502 CDCNAE, 'Auditoria e consultoria atuarial' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6622300 CDCNAE, 'Corretores e agentes de seguros, de planos de previdencia complementar e de saude' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6629100 CDCNAE, 'Atividades auxiliares dos seguros, da previdencia complementar e dos planos de saude nao especificadas anteriorment' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6630400 CDCNAE, 'Atividades de administracao de fundos por contrato ou comissao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6810201 CDCNAE, 'Compra e venda de imoveis proprios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6810202 CDCNAE, 'Aluguel de imoveis proprios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6821801 CDCNAE, 'Corretagem na compra e venda e avaliacao de imoveis' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6821802 CDCNAE, 'Corretagem no aluguel de imoveis' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6822600 CDCNAE, 'Gestao e administracao da propriedade imobiliaria*' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6911701 CDCNAE, 'Servicos advocaticios' DSCNAE, '0' FLSERASA FROM DUAL UNION 
SELECT  6911702 CDCNAE, 'Atividades auxiliares da justica' DSCNAE, '0' FLSERASA FROM DUAL UNION 
SELECT  6911703 CDCNAE, 'Agente de propriedade industrial' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6912500 CDCNAE, 'Cartorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6920601 CDCNAE, 'Atividades de contabilidade' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6920602 CDCNAE, 'Atividades de consultoria e auditoria contabil e tributaria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7020400 CDCNAE, 'Atividades de consultoria em gestao empresarial, exceto consultoria tecnica especifica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7111100 CDCNAE, 'Servicos de arquitetura' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7112000 CDCNAE, 'Servicos de engenharia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7119701 CDCNAE, 'Servicos de cartografia, topografia e geodesia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7119702 CDCNAE, 'Atividades de estudos geologicos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7119703 CDCNAE, 'Servicos de desenho tecnico relacionados a arquitetura e engenharia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7119704 CDCNAE, 'Servicos de pericia tecnica relacionados a seguranca do trabalho' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7119799 CDCNAE, 'Atividades tecnicas relacionadas a engenharia e arquitetura nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7120100 CDCNAE, 'Testes e analises tecnicas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7210000 CDCNAE, 'Pesquisa e desenvolvimento experimental em ciencias fisicas e naturais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7220700 CDCNAE, 'Pesquisa e desenvolvimento experimental em ciencias sociais e humanas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7311400 CDCNAE, 'Agencias de publicidade' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7312200 CDCNAE, 'Agenciamento de espacos para publicidade, exceto em veiculos de comunicacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7319001 CDCNAE, 'Criacao e montagem de estandes para feiras e exposicoes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7319002 CDCNAE, 'Promocao de vendas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7319003 CDCNAE, 'Marketing direto' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7319004 CDCNAE, 'Consultoria em publicidade' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7319099 CDCNAE, 'Outras atividades de publicidade nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7320300 CDCNAE, 'Pesquisas de mercado e de opiniao publica' DSCNAE, '0' FLSERASA FROM DUAL UNION 
SELECT  7410201 CDCNAE, 'Design' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7410202 CDCNAE, 'Decoracao de interiores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7420001 CDCNAE, 'Atividades de producao de fotografias, exceto aerea e submarina' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7420002 CDCNAE, 'Atividades de producao de fotografias aereas e submarinas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7420003 CDCNAE, 'Laboratorios fotograficos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7420004 CDCNAE, 'Filmagem de festas e eventos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7420005 CDCNAE, 'Servicos de microfilmagem' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7490101 CDCNAE, 'Servicos de traducao, interpretacao e similares' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7490102 CDCNAE, 'Escafandria e mergulho' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7490103 CDCNAE, 'Servicos de agronomia e de consultoria as atividades agricolas e pecuarias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7490104 CDCNAE, 'Atividades de intermediacao e agenciamento de servicos e negocios em geral, exceto imobiliarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7490105 CDCNAE, 'Agenciamento de profissionais para atividades esportivas, culturais e artisticas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7490199 CDCNAE, 'Outras atividades profissionais, cientificas e tecnicas nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7500100 CDCNAE, 'Atividades veterinarias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7711000 CDCNAE, 'Locacao de automoveis sem condutor' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7719501 CDCNAE, 'Locacao de embarcacoes sem tripulacao, exceto para fins recreativos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7719502 CDCNAE, 'Locacao de aeronaves sem tripulacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7719599 CDCNAE, 'Locacao de outros meios de transporte nao especificados anteriormente, sem condutor' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7721700 CDCNAE, 'Aluguel de equipamentos recreativos e esportivos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7722500 CDCNAE, 'Aluguel de fitas de video, DVDs e similares' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7723300 CDCNAE, 'Aluguel de objetos do vestuario, joias e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7729201 CDCNAE, 'Aluguel de aparelhos de jogos eletronicos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7729202 CDCNAE, 'Aluguel de moveis, utensilios e aparelhos de uso domestico e pessoal; instrumentos musicais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7729203 CDCNAE, 'Aluguel de material medico*' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7729299 CDCNAE, 'Aluguel de outros objetos pessoais e domesticos nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7731400 CDCNAE, 'Aluguel de maquinas e equipamentos agricolas sem operador' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7732201 CDCNAE, 'Aluguel de maquinas e equipamentos para construcao sem operador, exceto andaimes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7732202 CDCNAE, 'Aluguel de andaimes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7733100 CDCNAE, 'Aluguel de maquinas e equipamentos para escritorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7739001 CDCNAE, 'Aluguel de maquinas e equipamentos para extracao de minerios e petroleo, sem operador' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7739002 CDCNAE, 'Aluguel de equipamentos cientificos, medicos e hospitalares, sem operador' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7739003 CDCNAE, 'Aluguel de palcos, coberturas e outras estruturas de uso temporario, exceto andaimes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7739099 CDCNAE, 'Aluguel de outras maquinas e equipamentos comerciais e industriais nao especificados anteriormente, sem operador' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7740300 CDCNAE, 'Gestao de ativos intangiveis nao-financeiros' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3314722 CDCNAE, 'Manutencao e reparacao de maquinas e aparelhos para a industria do plastico' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3314799 CDCNAE, 'Manutencao e reparacao de outras maquinas e equipamentos para usos industriais nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3315500 CDCNAE, 'Manutencao e reparacao de veiculos ferroviarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3316301 CDCNAE, 'Manutencao e reparacao de aeronaves, exceto a manutencao na pista' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3316302 CDCNAE, 'Manutencao de aeronaves na pista *' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3319800 CDCNAE, 'Manutencao e reparacao de equipamentos e produtos nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3321000 CDCNAE, 'Instalacao de maquinas e equipamentos industriais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3329501 CDCNAE, 'Servicos de montagem de moveis de qualquer material' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3329599 CDCNAE, 'Instalacao de outros equipamentos nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3511500 CDCNAE, 'Geracao de energia eletrica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3512300 CDCNAE, 'Transmissao de energia eletrica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3513100 CDCNAE, 'Comercio atacadista de energia eletrica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3514000 CDCNAE, 'Distribuicao de energia eletrica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3520401 CDCNAE, 'Producao de gas; processamento de gas natural' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3520402 CDCNAE, 'Distribuicao de combustiveis gasosos por redes urbanas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3530100 CDCNAE, 'Producao e distribuicao de vapor, agua quente e ar condicionado' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3600601 CDCNAE, 'Captacao, tratamento e distribuicao de agua' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3600602 CDCNAE, 'Distribuicao de agua por caminhoes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3701100 CDCNAE, 'Gestao de redes de esgoto' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3702900 CDCNAE, 'Atividades relacionadas a esgoto, exceto a gestao de redes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3811400 CDCNAE, 'Coleta de residuos nao-perigosos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3812200 CDCNAE, 'Coleta de residuos perigosos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3821100 CDCNAE, 'Tratamento e disposicao de residuos nao-perigosos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3822000 CDCNAE, 'Tratamento e disposicao de residuos perigosos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3831901 CDCNAE, 'Recuperacao de sucatas de aluminio' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3831999 CDCNAE, 'Recuperacao de materiais metalicos, exceto aluminio' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3832700 CDCNAE, 'Recuperacao de materiais plasticos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3839401 CDCNAE, 'Usinas de compostagem' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3839499 CDCNAE, 'Recuperacao de materiais nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3900500 CDCNAE, 'Descontaminacao e outros servicos de gestao de residuos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4110700 CDCNAE, 'Incorporacao de empreendimentos imobiliarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4120400 CDCNAE, 'Construcao de edificios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4211101 CDCNAE, 'Construcao de rodovias e ferrovias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4211102 CDCNAE, 'Pintura para sinalizacao em pistas rodoviarias e aeroportos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4212000 CDCNAE, 'Construcao de obras de arte especiais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4213800 CDCNAE, 'Obras de urbanizacao - ruas, pracas e calcadas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4221901 CDCNAE, 'Construcao de barragens e represas para geracao de energia eletrica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4221902 CDCNAE, 'Construcao de estacoes e redes de distribuicao de energia eletrica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4221903 CDCNAE, 'Manutencao de redes de distribuicao de energia eletrica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4221904 CDCNAE, 'Construcao de estacoes e redes de telecomunicacoes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4221905 CDCNAE, 'Manutencao de estacoes e redes de telecomunicacoes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4222701 CDCNAE, 'Construcao de redes de abastecimento de agua, coleta de esgoto e construcoes correlatas, exceto obras de irrigacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4222702 CDCNAE, 'Obras de irrigacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4223500 CDCNAE, 'Construcao de redes de transportes por dutos, exceto para agua e esgoto' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4291000 CDCNAE, 'Obras portuarias, maritimas e fluviais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4292801 CDCNAE, 'Montagem de estruturas metalicas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4292802 CDCNAE, 'Obras de montagem industrial' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4299501 CDCNAE, 'Construcao de instalacoes esportivas e recreativas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4299599 CDCNAE, 'Outras obras de engenharia civil nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4311801 CDCNAE, 'Demolicao de edificios e outras estruturas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4311802 CDCNAE, 'Preparacao de canteiro e limpeza de terreno' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4312600 CDCNAE, 'Perfuracoes e sondagens' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4313400 CDCNAE, 'Obras de terraplenagem' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4319300 CDCNAE, 'Servicos de preparacao do terreno nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4321500 CDCNAE, 'Instalacao e manutencao eletrica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4322301 CDCNAE, 'Instalacoes hidraulicas, sanitarias e de gas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4322302 CDCNAE, 'Instalacao e manutencao de sistemas centrais de ar condicionado, de ventilacao e refrigeracao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4322303 CDCNAE, 'Instalacoes de sistema de prevencao contra incendio' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4329101 CDCNAE, 'Instalacao de paineis publicitarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4329102 CDCNAE, 'Instalacao de equipamentos para orientacao a navegacao maritima, fluvial e lacustre' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4329103 CDCNAE, 'Instalacao, manutencao e reparacao de elevadores, escadas e esteiras rolantes, exceto de fabricacao propria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4329104 CDCNAE, 'Montagem e instalacao de sistemas e equipamentos de iluminacao e sinalizacao em vias publicas, portos e aeroportos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4329105 CDCNAE, 'Tratamentos termicos, acusticos ou de vibracao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4329199 CDCNAE, 'Outras obras de instalacoes em construcoes nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4330401 CDCNAE, 'Impermeabilizacao em obras de engenharia civil' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4330402 CDCNAE, 'Instalacao de portas, janelas, tetos, divisorias e armarios embutidos de qualquer material' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4330403 CDCNAE, 'Obras de acabamento em gesso e estuque' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4330404 CDCNAE, 'Servicos de pintura de edificios em geral' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4330405 CDCNAE, 'Aplicacao de revestimentos e de resinas em interiores e exteriores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4330499 CDCNAE, 'Outras obras de acabamento da construcao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4391600 CDCNAE, 'Obras de fundacoes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4399101 CDCNAE, 'Administracao de obras' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4399102 CDCNAE, 'Montagem e desmontagem de andaimes e outras estruturas temporarias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4399103 CDCNAE, 'Obras de alvenaria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4399104 CDCNAE, 'Servicos de operacao e fornecimento de equipamentos para transporte e elevacao de cargas e pessoas para uso em o' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4399105 CDCNAE, 'Perfuracao e construcao de pocos de agua' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4399199 CDCNAE, 'Servicos especializados para construcao nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4511101 CDCNAE, 'Comercio a varejo de automoveis, camionetas e utilitarios novos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4511102 CDCNAE, 'Comercio a varejo de automoveis, camionetas e utilitarios usados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4511103 CDCNAE, 'Comercio por atacado de automoveis, camionetas e utilitarios novos e usados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4511104 CDCNAE, 'Comercio por atacado de caminhoes novos e usados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4511105 CDCNAE, 'Comercio por atacado de reboques e semi-reboques novos e usados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4511106 CDCNAE, 'Comercio por atacado de onibus e microonibus novos e usados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4512901 CDCNAE, 'Representantes comerciais e agentes do comercio de veiculos automotores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4512902 CDCNAE, 'Comercio sob consignacao de veiculos automotores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4520001 CDCNAE, 'Servicos de manutencao e reparacao mecanica de veiculos automotores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4520002 CDCNAE, 'Servicos de lanternagem ou funilaria e pintura de veiculos automotores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4520003 CDCNAE, 'Servicos de manutencao e reparacao eletrica de veiculos automotores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4520004 CDCNAE, 'Servicos de alinhamento e balanceamento de veiculos automotores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4520005 CDCNAE, 'Servicos de lavagem, lubrificacao e polimento de veiculos automotores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4520006 CDCNAE, 'Servicos de borracharia para veiculos automotores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4520007 CDCNAE, 'Servicos de instalacao, manutencao e reparacao de acessorios para veiculos automotores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4530701 CDCNAE, 'Comercio por atacado de pecas e acessorios novos para veiculos automotores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4530702 CDCNAE, 'Comercio por atacado de pneumaticos e camaras-de-ar' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4530703 CDCNAE, 'Comercio a varejo de pecas e acessorios novos para veiculos automotores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4530704 CDCNAE, 'Comercio a varejo de pecas e acessorios usados para veiculos automotores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4530705 CDCNAE, 'Comercio a varejo de pneumaticos e camaras-de-ar' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4530706 CDCNAE, 'Representantes comerciais e agentes do comercio de pecas e acessorios novos e usados para veiculos automotores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4541201 CDCNAE, 'Comercio por atacado de motocicletas e motonetas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4541202 CDCNAE, 'Comercio por atacado de pecas e acessorios para motocicletas e motonetas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4541203 CDCNAE, 'Comercio a varejo de motocicletas e motonetas novas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4541204 CDCNAE, 'Comercio a varejo de motocicletas e motonetas usadas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4541205 CDCNAE, 'Comercio a varejo de pecas e acessorios para motocicletas e motonetas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4542101 CDCNAE, 'Representantes comerciais e agentes do comercio de motocicletas e motonetas, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4542102 CDCNAE, 'Comercio sob consignacao de motocicletas e motonetas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4543900 CDCNAE, 'Manutencao e reparacao de motocicletas e motonetas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4611700 CDCNAE, 'Representantes comerciais e agentes do comercio de materias-primas agricolas e animais vivos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4612500 CDCNAE, 'Representantes comerciais e agentes do comercio de combustiveis, minerais, produtos siderurgicos e quimicos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4751201 CDCNAE, 'Comercio varejista especializado de equipamentos e suprimentos de informatica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1091102 CDCNAE, 'Padaria e confeitaria com predominancia de producao propria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1099607 CDCNAE, 'Fabricacao de alimentos dieteticos e complementos alimentares' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1122404 CDCNAE, 'Fabricacao de bebidas isotonicas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1822901 CDCNAE, 'Servicos de encadernacao e plastificacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1822999 CDCNAE, 'Servicos de acabamentos graficos, exceto encadernacao e plastificacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2013401 CDCNAE, 'Fabricacao de adubos e fertilizantes organo-minerais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2013402 CDCNAE, 'Fabricacao de adubos e fertilizantes, exceto organo-minerais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2090401 CDCNAE, 'Fabricacao de polvoras, explosivos e detonantes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2399102 CDCNAE, 'Fabricacao de abrasivos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2539002 CDCNAE, 'Servicos de tratamento e revestimento em metais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2599302 CDCNAE, 'Servico de corte e dobra de metais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  28220402 CDCNAE, 'Fabricacao de maquinas, equipamentos e aparelhos para transporte e elevacao de cargas, pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3091101 CDCNAE, 'Fabricacao de motocicletas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3091102 CDCNAE, 'Fabricacao de pecas e acessorios para motocicletas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3250709 CDCNAE, 'Servico de laboratorio optico' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3299006 CDCNAE, 'Fabricacao de velas, inclusive decorativas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3317101 CDCNAE, 'Manutencao e reparacao de embarcacoes e estruturas flutuantes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3317102 CDCNAE, 'Manutencao e reparacao de embarcacoes para esportes e lazer' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3511501 CDCNAE, 'Geracao de energia eletrica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  3511502 CDCNAE, 'Atividades de coordenacao e controle da operacao da geracao e transmissao de energia eletrica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4520008 CDCNAE, 'Servicos de capotaria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4954601 CDCNAE, 'Comercio atacadista de equipamentos de informatica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4729602 CDCNAE, 'Comercio varejista de mercadorias em lojas de conveniencia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4744006 CDCNAE, 'Comercio varejista de pedras para revestimento' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4751202 CDCNAE, 'Recarga de cartuchos para equipamentos de informatica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5030103 CDCNAE, 'Servicos de rebocadores e empurradores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5239701 CDCNAE, 'Servicos de praticagem' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5239799 CDCNAE, 'Atividades auxiliares dos transportes aquaviarios nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5812301 CDCNAE, 'Edicao de jornais diarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5812302 CDCNAE, 'Edicao de jornais nao diarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5822101 CDCNAE, 'Edicao integrada a impressao de jornais diarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  5822102 CDCNAE, 'Edicao integrada a impressao de jornais nao diarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6201501 CDCNAE, 'Desenvolvimento de programas de computador sob encomenda' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6201502 CDCNAE, 'Web design                                                                                                     ' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6438701 CDCNAE, 'Bancos de cambio                                                                                                       ' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6438702 CDCNAE, 'Outra instituicoes de intermediacao nao-monetaria nao especificadas anteriormente                                     ' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  6810203 CDCNAE, 'Loteamento de imoveis proprios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7410203 CDCNAE, 'Design de produto' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7410299 CDCNAE, 'Atividades de design nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8020001 CDCNAE, 'Atividades de monitoramento de sistemas de seguranca eletronico' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8020002 CDCNAE, 'Outras atividades de servicos de seguranca' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8299601 CDCNAE, 'Formacao de condutores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8610201 CDCNAE, 'Laboratorios de anatomia patologica e citologica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8690903 CDCNAE, 'Atividades de acupuntura' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8690904 CDCNAE, 'Atividades de podologia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9412001 CDCNAE, 'Atividades de fiscalizacao profissional' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9412099 CDCNAE, 'Outras Atividades associativas profissionais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9609207 CDCNAE, 'Alojamento de animais domesticos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9609208 CDCNAE, 'Higiene e embelezamento de animais domesticos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9609205 CDCNAE, 'Atividades de sauna e banhos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9609206 CDCNAE, 'Servicos de tatuagem e colocacao de piercing' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  2539001 CDCNAE, 'Servicos de usinagem, tornearia e solda' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1091101 CDCNAE, 'Fabricacao de produtos de panificacao industrial' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  1622601 CDCNAE, 'Fabricacao de casas de madeira pre-fabricadas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4613300 CDCNAE, 'Representantes comerciais e agentes do comercio de madeira, material de construcao e ferragens' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4614100 CDCNAE, 'Representantes comerciais e agentes do comercio de maquinas, equipamentos, embarcacoes e aeronaves' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4615000 CDCNAE, 'Representantes comerciais e agentes do comercio de eletrodomesticos, moveis e artigos de uso domestico' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4616800 CDCNAE, 'Representantes comerciais e agentes do comercio de texteis, vestuario, calcados e artigos de viagem' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4617600 CDCNAE, 'Representantes comerciais e agentes do comercio de produtos alimenticios, bebidas e fumo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4618401 CDCNAE, 'Representantes comerciais e agentes do comercio de medicamentos, cosmeticos e produtos de perfumaria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4618402 CDCNAE, 'Representantes comerciais e agentes do comercio de instrumentos e materiais odonto-medico-hospitalares' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4618403 CDCNAE, 'Representantes comerciais e agentes do comercio de jornais, revistas e outras publicacoes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4618499 CDCNAE, 'Outros representantes comerciais e agentes do comercio especializado em produtos nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4619200 CDCNAE, 'Representantes comerciais e agentes do comercio de mercadorias em geral nao especializado' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4621400 CDCNAE, 'Comercio atacadista de cafe em grao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4622200 CDCNAE, 'Comercio atacadista de soja' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4623101 CDCNAE, 'Comercio atacadista de animais vivos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4623102 CDCNAE, 'Comercio atacadista de couros, las, peles e outros subprodutos nao-comestiveis de origem animal' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4623103 CDCNAE, 'Comercio atacadista de algodao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4623104 CDCNAE, 'Comercio atacadista de fumo em folha nao beneficiado' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4623105 CDCNAE, 'Comercio atacadista de cacau *' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4623106 CDCNAE, 'Comercio atacadista de sementes, flores, plantas e gramas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4623107 CDCNAE, 'Comercio atacadista de sisal' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4623108 CDCNAE, 'Comercio atacadista de materias-primas agricolas com atividade de fracionamento e acondicionamento associada' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4623109 CDCNAE, 'Comercio atacadista de alimentos para animais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4623199 CDCNAE, 'Comercio atacadista de materias-primas agricolas nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4631100 CDCNAE, 'Comercio atacadista de leite e laticinios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4632001 CDCNAE, 'Comercio atacadista de cereais e leguminosas beneficiados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4632002 CDCNAE, 'Comercio atacadista de farinhas, amidos e feculas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4632003 CDCNAE, 'Comercio atacadista de cereais e leguminosas beneficiados, farinhas, amidos e feculas, com atividade de fracionament acondicionamento associada' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4633801 CDCNAE, 'Comercio atacadista de frutas, verduras, raizes, tuberculos, hortalicas e legumes frescos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4633802 CDCNAE, 'Comercio atacadista de aves vivas e ovos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4633803 CDCNAE, 'Comercio atacadista de coelhos e outros pequenos animais vivos para alimentacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4634601 CDCNAE, 'Comercio atacadista de carnes bovinas e suinas e derivados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4634602 CDCNAE, 'Comercio atacadista de aves abatidas e derivados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4634603 CDCNAE, 'Comercio atacadista de pescados e frutos do mar' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4634699 CDCNAE, 'Comercio atacadista de carnes e derivados de outros animais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4635401 CDCNAE, 'Comercio atacadista de agua mineral' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4635402 CDCNAE, 'Comercio atacadista de cerveja, chope e refrigerante' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4635403 CDCNAE, 'Comercio atacadista de bebidas com atividade de fracionamento e acondicionamento associada' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4635499 CDCNAE, 'Comercio atacadista de bebidas nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4636201 CDCNAE, 'Comercio atacadista de fumo beneficiado' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4636202 CDCNAE, 'Comercio atacadista de cigarros, cigarrilhas e charutos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4637101 CDCNAE, 'Comercio atacadista de cafe torrado, moido e soluvel' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4637102 CDCNAE, 'Comercio atacadista de acucar' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4637103 CDCNAE, 'Comercio atacadista de oleos e gorduras' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4637104 CDCNAE, 'Comercio atacadista de paes, bolos, biscoitos e similares' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4637105 CDCNAE, 'Comercio atacadista de massas alimenticias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4637106 CDCNAE, 'Comercio atacadista de sorvetes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4637107 CDCNAE, 'Comercio atacadista de chocolates, confeitos, balas, bombons e semelhantes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4637199 CDCNAE, 'Comercio atacadista especializado em outros produtos alimenticios nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4639701 CDCNAE, 'Comercio atacadista de produtos alimenticios em geral' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4639702 CDCNAE, 'Comercio atacadista de produtos alimenticios em geral, com atividade de fracionamento e acondicionamento associada' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4641901 CDCNAE, 'Comercio atacadista de tecidos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4641902 CDCNAE, 'Comercio atacadista de artigos de cama, mesa e banho' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4641903 CDCNAE, 'Comercio atacadista de artigos de armarinho' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4642701 CDCNAE, 'Comercio atacadista de artigos do vestuario e acessorios, exceto profissionais e de seguranca' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4642702 CDCNAE, 'Comercio atacadista de roupas e acessorios para uso profissional e de seguranca do trabalho' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4643501 CDCNAE, 'Comercio atacadista de calcados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4643502 CDCNAE, 'Comercio atacadista de bolsas, malas e artigos de viagem' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4644301 CDCNAE, 'Comercio atacadista de medicamentos e drogas de uso humano' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4644302 CDCNAE, 'Comercio atacadista de medicamentos e drogas de uso veterinario' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4645101 CDCNAE, 'Comercio atacadista de instrumentos e materiais para uso medico, cirurgico, hospitalar e de laboratorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4645102 CDCNAE, 'Comercio atacadista de proteses e artigos de ortopedia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4645103 CDCNAE, 'Comercio atacadista de produtos odontologicos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4646001 CDCNAE, 'Comercio atacadista de cosmeticos e produtos de perfumaria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4646002 CDCNAE, 'Comercio atacadista de produtos de higiene pessoal' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4647801 CDCNAE, 'Comercio atacadista de artigos de escritorio e de papelaria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4647802 CDCNAE, 'Comercio atacadista de livros, jornais e outras publicacoes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4649401 CDCNAE, 'Comercio atacadista de equipamentos eletricos de uso pessoal e domestico' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4649402 CDCNAE, 'Comercio atacadista de aparelhos eletronicos de uso pessoal e domestico' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4649403 CDCNAE, 'Comercio atacadista de bicicletas, triciclos e outros veiculos recreativos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4649404 CDCNAE, 'Comercio atacadista de moveis e artigos de colchoaria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4649405 CDCNAE, 'Comercio atacadista de artigos de tapecaria; persianas e cortinas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4649406 CDCNAE, 'Comercio atacadista de lustres, luminarias e abajures' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4649407 CDCNAE, 'Comercio atacadista de filmes, CDs, DVDs, fitas e discos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4649408 CDCNAE, 'Comercio atacadista de produtos de higiene, limpeza e conservacao domiciliar' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4649409 CDCNAE, 'Comercio atacadista de produtos de higiene, limpeza e conservacao domiciliar, com atividade de fracionamento e acondicionamento associada' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4649410 CDCNAE, 'Comercio atacadista de joias, relogios e bijuterias, inclusive pedras preciosas e semipreciosas lapidadas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4649499 CDCNAE, 'Comercio atacadista de outros equipamentos e artigos de uso pessoal e domestico nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4651601 CDCNAE, 'Comercio atacadista de equipamentos de informatica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4651602 CDCNAE, 'Comercio atacadista de suprimentos para informatica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4652400 CDCNAE, 'Comercio atacadista de componentes eletronicos e equipamentos de telefonia e comunicacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4661300 CDCNAE, 'Comercio atacadista de maquinas, aparelhos e equipamentos para uso agropecuario; partes e pecas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4662100 CDCNAE, 'Comercio atacadista de maquinas, equipamentos para terraplenagem, mineracao e construcao; partes e pecas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4663000 CDCNAE, 'Comercio atacadista de maquinas e equipamentos para uso industrial; partes e pecas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4664800 CDCNAE, 'Comercio atacadista de maquinas, aparelhos e equipamentos para uso odonto-medico-hospitalar; partes e pecas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4665600 CDCNAE, 'Comercio atacadista de maquinas e equipamentos para uso comercial; partes e pecas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4669901 CDCNAE, 'Comercio atacadista de bombas e compressores; partes e pecas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4669999 CDCNAE, 'Comercio atacadista de outras maquinas e equipamentos nao especificados anteriormente; partes e pecas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4671100 CDCNAE, 'Comercio atacadista de madeira e produtos derivados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4672900 CDCNAE, 'Comercio atacadista de ferragens e ferramentas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4673700 CDCNAE, 'Comercio atacadista de material eletrico' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4674500 CDCNAE, 'Comercio atacadista de cimento' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4679601 CDCNAE, 'Comercio atacadista de tintas, vernizes e similares' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4679602 CDCNAE, 'Comercio atacadista de marmores e granitos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4679603 CDCNAE, 'Comercio atacadista de vidros, espelhos e vitrais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4679604 CDCNAE, 'Comercio atacadista especializado de materiais de construcao nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4679699 CDCNAE, 'Comercio atacadista de materiais de construcao em geral' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4681801 CDCNAE, 'Comercio atacadista de alcool carburante, biodiesel, gasolina e demais derivados de petroleo, exceto lubrificantes, nao realizado por transportador retalhista (TRR)' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4681802 CDCNAE, 'Comercio atacadista de combustiveis realizado por transportador retalhista (TRR)' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4681803 CDCNAE, 'Comercio atacadista de combustiveis de origem vegetal, exceto alcool carburante' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4681804 CDCNAE, 'Comercio atacadista de combustiveis de origem mineral em bruto' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4681805 CDCNAE, 'Comercio atacadista de lubrificantes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4682600 CDCNAE, 'Comercio atacadista de gas liquefeito de petroleo (GLP)' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4683400 CDCNAE, 'Comercio atacadista de defensivos agricolas, adubos, fertilizantes e corretivos do solo' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4684201 CDCNAE, 'Comercio atacadista de resinas e elastomeros' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4684202 CDCNAE, 'Comercio atacadista de solventes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4684299 CDCNAE, 'Comercio atacadista de outros produtos quimicos e petroquimicos nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4685100 CDCNAE, 'Comercio atacadista de produtos siderurgicos e metalurgicos, exceto para construcao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4686901 CDCNAE, 'Comercio atacadista de papel e papelao em bruto' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4686902 CDCNAE, 'Comercio atacadista de embalagens' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4687701 CDCNAE, 'Comercio atacadista de residuos de papel e papelao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4687702 CDCNAE, 'Comercio atacadista de residuos e sucatas nao-metalicos, exceto de papel e papelao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4687703 CDCNAE, 'Comercio atacadista de residuos e sucatas metalicos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4689301 CDCNAE, 'Comercio atacadista de produtos da extracao mineral, exceto combustiveis' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4689302 CDCNAE, 'Comercio atacadista de fios e fibras texteis beneficiados *' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4689399 CDCNAE, 'Comercio atacadista especializado em outros produtos intermediarios nao especificados anteriormente *' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4691500 CDCNAE, 'Comercio atacadista de mercadorias em geral, com predominancia de produtos alimenticios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4692300 CDCNAE, 'Comercio atacadista de mercadorias em geral, com predominancia de insumos agropecuarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4693100 CDCNAE, 'Comercio atacadista de mercadorias em geral, sem predominancia de alimentos ou de insumos agropecuarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4711301 CDCNAE, 'Comercio varejista de mercadorias em geral, com predominancia de produtos alimenticios - hipermercados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4711302 CDCNAE, 'Comercio varejista de mercadorias em geral, com predominancia de produtos alimenticios - supermercados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4712100 CDCNAE, 'Comercio varejista de mercadorias em geral, com predominancia de produtos alimenticios - minimercados, mercearias armazens' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4713001 CDCNAE, 'Lojas de departamentos ou magazines' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4713002 CDCNAE, 'Lojas de variedades, exceto lojas de departamentos ou magazines' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4713003 CDCNAE, 'Lojas duty free de aeroportos internacionais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4721101 CDCNAE, 'Padaria e confeitaria com predominancia de producao propria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4721102 CDCNAE, 'Padaria e confeitaria com predominancia de revenda' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4721103 CDCNAE, 'Comercio varejista de laticinios e frios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4721104 CDCNAE, 'Comercio varejista de doces, balas, bombons e semelhantes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4722901 CDCNAE, 'Comercio varejista de carnes - acougues' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4722902 CDCNAE, 'Peixaria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4723700 CDCNAE, 'Comercio varejista de bebidas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4724500 CDCNAE, 'Comercio varejista de hortifrutigranjeiros' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4729601 CDCNAE, 'Tabacaria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4729699 CDCNAE, 'Comercio varejista de produtos alimenticios em geral ou especializado em produtos alimenticios nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4731800 CDCNAE, 'Comercio varejista de combustiveis para veiculos automotores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4732600 CDCNAE, 'Comercio varejista de lubrificantes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4741500 CDCNAE, 'Comercio varejista de tintas e materiais para pintura' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4742300 CDCNAE, 'Comercio varejista de material eletrico' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4743100 CDCNAE, 'Comercio varejista de vidros' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4744001 CDCNAE, 'Comercio varejista de ferragens e ferramentas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4744002 CDCNAE, 'Comercio varejista de madeira e artefatos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4744003 CDCNAE, 'Comercio varejista de materiais hidraulicos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4744004 CDCNAE, 'Comercio varejista de cal, areia, pedra britada, tijolos e telhas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4744005 CDCNAE, 'Comercio varejista de materiais de construcao nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4744099 CDCNAE, 'Comercio varejista de materiais de construcao em geral' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4751200 CDCNAE, 'Comercio varejista especializado de equipamentos e suprimentos de informatica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4752100 CDCNAE, 'Comercio varejista especializado de equipamentos de telefonia e comunicacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4753900 CDCNAE, 'Comercio varejista especializado de eletrodomesticos e equipamentos de audio e video' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4754701 CDCNAE, 'Comercio varejista de moveis' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4754702 CDCNAE, 'Comercio varejista de artigos de colchoaria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4754703 CDCNAE, 'Comercio varejista de artigos de iluminacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4755501 CDCNAE, 'Comercio varejista de tecidos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4755502 CDCNAE, 'Comercio varejista de artigos de armarinho' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4755503 CDCNAE, 'Comercio varejista de artigos de cama, mesa e banho' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4756300 CDCNAE, 'Comercio varejista especializado de instrumentos musicais e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4757100 CDCNAE, 'Comercio varejista especializado de pecas e acessorios para aparelhos eletroeletronicos para uso domestico, exceto informatica e comunicacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4759801 CDCNAE, 'Comercio varejista de artigos de tapecaria, cortinas e persianas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4759899 CDCNAE, 'Comercio varejista de outros artigos de uso domestico nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4761001 CDCNAE, 'Comercio varejista de livros' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4761002 CDCNAE, 'Comercio varejista de jornais e revistas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4761003 CDCNAE, 'Comercio varejista de artigos de papelaria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4762800 CDCNAE, 'Comercio varejista de discos, CDs, DVDs e fitas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4763601 CDCNAE, 'Comercio varejista de brinquedos e artigos recreativos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4763602 CDCNAE, 'Comercio varejista de artigos esportivos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4763603 CDCNAE, 'Comercio varejista de bicicletas e triciclos; pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4763604 CDCNAE, 'Comercio varejista de artigos de caca, pesca e camping' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4763605 CDCNAE, 'Comercio varejista de embarcacoes e outros veiculos recreativos; pecas e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4771701 CDCNAE, 'Comercio varejista de produtos farmaceuticos, sem manipulacao de formulas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4771702 CDCNAE, 'Comercio varejista de produtos farmaceuticos, com manipulacao de formulas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4771703 CDCNAE, 'Comercio varejista de produtos farmaceuticos homeopaticos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4771704 CDCNAE, 'Comercio varejista de medicamentos veterinarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4772500 CDCNAE, 'Comercio varejista de cosmeticos, produtos de perfumaria e de higiene pessoal' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4773300 CDCNAE, 'Comercio varejista de artigos medicos e ortopedicos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4774100 CDCNAE, 'Comercio varejista de artigos de optica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4781400 CDCNAE, 'Comercio varejista de artigos do vestuario e acessorios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4782201 CDCNAE, 'Comercio varejista de calcados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4782202 CDCNAE, 'Comercio varejista de artigos de viagem' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4783101 CDCNAE, 'Comercio varejista de artigos de joalheria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4783102 CDCNAE, 'Comercio varejista de artigos de relojoaria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4784900 CDCNAE, 'Comercio varejista de gas liquefeito de petroleo (GLP)' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4785701 CDCNAE, 'Comercio varejista de antiguidades' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4785799 CDCNAE, 'Comercio varejista de outros artigos usados' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4789001 CDCNAE, 'Comercio varejista de suvenires, bijuterias e artesanatos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4789002 CDCNAE, 'Comercio varejista de plantas e flores naturais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4789003 CDCNAE, 'Comercio varejista de objetos de arte' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4789004 CDCNAE, 'Comercio varejista de animais vivos e de artigos e alimentos para animais de estimacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4789005 CDCNAE, 'Comercio varejista de produtos saneantes domissanitarios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4789006 CDCNAE, 'Comercio varejista de fogos de artificio e artigos pirotecnicos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4789007 CDCNAE, 'Comercio varejista de equipamentos para escritorio' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4789008 CDCNAE, 'Comercio varejista de artigos fotograficos e para filmagem' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4789009 CDCNAE, 'Comercio varejista de armas e municoes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4789099 CDCNAE, 'Comercio varejista de outros produtos nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4911600 CDCNAE, 'Transporte ferroviario de carga' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4912401 CDCNAE, 'Transporte ferroviario de passageiros intermunicipal e interestadual' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4912402 CDCNAE, 'Transporte ferroviario de passageiros municipal e em regiao metropolitana' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4912403 CDCNAE, 'Transporte metroviario' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  4921301 CDCNAE, 'Transporte rodoviario coletivo de passageiros, com itinerario fixo, municipal' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7810800 CDCNAE, 'Selecao e agenciamento de mao-de-obra' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7820500 CDCNAE, 'Locacao de mao-de-obra temporaria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7830200 CDCNAE, 'Fornecimento e gestao de recursos humanos para terceiros' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7911200 CDCNAE, 'Agencias de viagens' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7912100 CDCNAE, 'Operadores turisticos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  7990200 CDCNAE, 'Servicos de reservas e outros servicos de turismo nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8011101 CDCNAE, 'Atividades de vigilancia e seguranca privada' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8011102 CDCNAE, 'Servicos de adestramento de caes de guarda' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8012900 CDCNAE, 'Atividades de transporte de valores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8020000 CDCNAE, 'Atividades de monitoramento de sistemas de seguranca' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8030700 CDCNAE, 'Atividades de investigacao particular' DSCNAE, '0' FLSERASA FROM DUAL UNION 
SELECT  8111700 CDCNAE, 'Servicos combinados para apoio a edificios, exceto condominios prediais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8112500 CDCNAE, 'Condominios prediais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8121400 CDCNAE, 'Limpeza em predios e em domicilios' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8122200 CDCNAE, 'Imunizacao e controle de pragas urbanas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8129000 CDCNAE, 'Atividades de limpeza nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8130300 CDCNAE, 'Atividades paisagisticas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8211300 CDCNAE, 'Servicos combinados de escritorio e apoio administrativo' DSCNAE, '0' FLSERASA FROM DUAL UNION 
SELECT  8219901 CDCNAE, 'Fotocopias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8219999 CDCNAE, 'Preparacao de documentos e servicos especializados de apoio administrativo nao especificados anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8220200 CDCNAE, 'Atividades de teleatendimento' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8230001 CDCNAE, 'Servicos de organizacao de feiras, congressos, exposicoes e festas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8230002 CDCNAE, 'Casas de festas e eventos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8291100 CDCNAE, 'Atividades de cobrancas e informacoes cadastrais' DSCNAE, '0' FLSERASA FROM DUAL UNION 
SELECT  8292000 CDCNAE, 'Envasamento e empacotamento sob contrato' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8299701 CDCNAE, 'Medicao de consumo de energia eletrica, gas e agua' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8299702 CDCNAE, 'Emissao de vales-alimentacao, vales-transporte e similares' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8299703 CDCNAE, 'Servicos de gravacao de carimbos, exceto confeccao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8299704 CDCNAE, 'Leiloeiros independentes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8299705 CDCNAE, 'Servicos de levantamento de fundos sob contrato' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8299706 CDCNAE, 'Casas lotericas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8299707 CDCNAE, 'Salas de acesso a internet' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8299799 CDCNAE, 'Outras atividades de servicos prestados principalmente as empresas nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8411600 CDCNAE, 'Administracao publica em geral' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8412400 CDCNAE, 'Regulacao das atividades de saude, educacao, servicos culturais e outros servicos sociais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8413200 CDCNAE, 'Regulacao das atividades economicas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8414100 CDCNAE, 'Atividades de suporte a administracao publica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8421300 CDCNAE, 'Relacoes exteriores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8422100 CDCNAE, 'Defesa' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8423000 CDCNAE, 'Justica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8424800 CDCNAE, 'Seguranca e ordem publica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8425600 CDCNAE, 'Defesa Civil' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8430200 CDCNAE, 'Seguridade social obrigatoria' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8511200 CDCNAE, 'Educacao infantil - creche' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8512100 CDCNAE, 'Educacao infantil - pre-escola' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8513900 CDCNAE, 'Ensino fundamental' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8520100 CDCNAE, 'Ensino medio' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8531700 CDCNAE, 'Educacao superior - graduacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8532500 CDCNAE, 'Educacao superior - graduacao e pos-graduacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8533300 CDCNAE, 'Educacao superior - pos-graduacao e extensao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8541400 CDCNAE, 'Educacao profissional de nivel tecnico' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8542200 CDCNAE, 'Educacao profissional de nivel tecnologico' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8550301 CDCNAE, 'Administracao de caixas escolares' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8550302 CDCNAE, 'Servicos auxiliares a educacao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8591100 CDCNAE, 'Ensino de esportes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8592901 CDCNAE, 'Ensino de danca' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8592902 CDCNAE, 'Ensino de artes cenicas, exceto danca' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8592903 CDCNAE, 'Ensino de musica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8592999 CDCNAE, 'Ensino de arte e cultura nao especificado anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8593700 CDCNAE, 'Ensino de idiomas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8599601 CDCNAE, 'Formacao de condutores' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8599602 CDCNAE, 'Cursos de pilotagem' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8599603 CDCNAE, 'Treinamento em informatica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8599604 CDCNAE, 'Treinamento em desenvolvimento profissional e gerencial' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8599605 CDCNAE, 'Cursos preparatorios para concursos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8599699 CDCNAE, 'Outras atividades de ensino nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8610101 CDCNAE, 'Atividades de atendimento hospitalar, exceto pronto-socorro e unidades para atendimento a urgencias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8610102 CDCNAE, 'Atividades de atendimento em pronto-socorro e unidades hospitalares para atendimento a urgencias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8621601 CDCNAE, 'UTI movel' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8621602 CDCNAE, 'Servicos moveis de atendimento a urgencias, exceto por UTI movel' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8622400 CDCNAE, 'Servicos de remocao de pacientes, exceto os servicos moveis de atendimento a urgencias' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8630501 CDCNAE, 'Atividade medica ambulatorial com recursos para realizacao de procedimentos cirurgicos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8630502 CDCNAE, 'Atividade medica ambulatorial com recursos para realizacao de exames complementares' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8630503 CDCNAE, 'Atividade medica ambulatorial restrita a consultas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8630504 CDCNAE, 'Atividade odontologica com recursos para realizacao de procedimentos cirurgicos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8630505 CDCNAE, 'Atividade odontologica sem recursos para realizacao de procedimentos cirurgicos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8630506 CDCNAE, 'Servicos de vacinacao e imunizacao humana' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8630507 CDCNAE, 'Atividades de reproducao humana assistida' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8630599 CDCNAE, 'Atividades de atencao ambulatorial nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8640201 CDCNAE, 'Laboratorios de anatomia patologica e citologica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8640202 CDCNAE, 'Laboratorios clinicos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8640203 CDCNAE, 'Servicos de dialise e nefrologia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8640204 CDCNAE, 'Servicos de tomografia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8640205 CDCNAE, 'Servicos de diagnostico por imagem com uso de radiacao ionizante, exceto tomografia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8640206 CDCNAE, 'Servicos de ressonancia magnetica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8640207 CDCNAE, 'Servicos de diagnostico por imagem sem uso de radiacao ionizante, exceto ressonancia magnetica' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8640208 CDCNAE, 'Servicos de diagnostico por registro grafico - ECG, EEG e outros exames analogos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8640209 CDCNAE, 'Servicos de diagnostico por metodos opticos - endoscopia e outros exames analogos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8640210 CDCNAE, 'Servicos de quimioterapia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8640211 CDCNAE, 'Servicos de radioterapia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8640212 CDCNAE, 'Servicos de hemoterapia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8640213 CDCNAE, 'Servicos de litotripsia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8640214 CDCNAE, 'Servicos de bancos de celulas e tecidos humanos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8640299 CDCNAE, 'Atividades de servicos de complementacao diagnostica e terapeutica nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8650001 CDCNAE, 'Atividades de enfermagem' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8650002 CDCNAE, 'Atividades de profissionais da nutricao' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8650003 CDCNAE, 'Atividades de psicologia e psicanalise' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8650004 CDCNAE, 'Atividades de fisioterapia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8650005 CDCNAE, 'Atividades de terapia ocupacional' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8650006 CDCNAE, 'Atividades de fonoaudiologia' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8650007 CDCNAE, 'Atividades de terapia de nutricao enteral e parenteral' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8650099 CDCNAE, 'Atividades de profissionais da area de saude nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8660700 CDCNAE, 'Atividades de apoio a gestao de saude' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8690901 CDCNAE, 'Atividades de praticas integrativas e complementares em saude humana' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8690902 CDCNAE, 'Atividades de banco de leite humano' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8690999 CDCNAE, 'Outras atividades de atencao a saude humana nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8711501 CDCNAE, 'Clinicas e residencias geriatricas' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8711502 CDCNAE, 'Instituicoes de longa permanencia para idosos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8711503 CDCNAE, 'Atividades de assistencia a deficientes fisicos, imunodeprimidos e convalescentes' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8711504 CDCNAE, 'Centros de apoio a pacientes com cancer e com AIDS' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8711505 CDCNAE, 'Condominios residenciais para idosos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8712300 CDCNAE, 'Atividades de fornecimento de infra-estrutura de apoio e assistencia a paciente no domicilio' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8720401 CDCNAE, 'Atividades de centros de assistencia psicossocial' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8720499 CDCNAE, 'Atividades de assistencia psicossocial e a saude a portadores de disturbios psiquicos, deficiencia mental e dependencia quimica nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8730101 CDCNAE, 'Orfanatos' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8730102 CDCNAE, 'Albergues assistenciais' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8730199 CDCNAE, 'Atividades de assistencia social prestadas em residencias coletivas e particulares nao especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  8800600 CDCNAE, 'Servicos de assistencia social sem alojamento' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9001901 CDCNAE, 'Producao teatral' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9001902 CDCNAE, 'Producao musical' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9001903 CDCNAE, 'Producao de espetaculos de danca' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9001904 CDCNAE, 'Producao de espetaculos circenses, de marionetes e similares' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9001905 CDCNAE, 'Producao de espetaculos de rodeios, vaquejadas e similares' DSCNAE, '1' FLSERASA FROM DUAL UNION 
SELECT  9001906 CDCNAE, 'Atividades de sonorizacao e de iluminacao' DSCNAE, '1' FLSERASA FROM DUAL UNION
SELECT  5231103 CDCNAE, 'Gestão de terminais aquaviários'DSCNAE, '1' FLSERASA FROM DUAL UNION
SELECT  6438799 CDCNAE, 'Outras instituições de intermediação não-monetária' DSCNAE, '1' FLSERASA FROM DUAL UNION
SELECT  74102099  CDCNAE, 'Atividades de design não especificadas anteriormente' DSCNAE, '1' FLSERASA FROM DUAL;

-- Variavel para contagem de registros CNAE
v_count number := 0;

BEGIN

-- Loop depara codigo CNAE novo com codigo CNAE existente na tabela TBGEN_CNAE

FOR rw_cnae IN cr_cnae LOOP

SELECT COUNT(1) 
    INTO   v_count
    FROM   tbgen_cnae t
    WHERE  t.cdcnae = rw_cnae.cdcnae;

-- Verifica se existe CNAE novo na tabela TBGEN_CNAE
-- Se sim, faz UPDATE nos campos DSCNAE e FLSERASA
-- Se nao, faz INSERT dos campos CDCNAE, DSCNAE e FLSERASA em um novo registro

IF v_count = 0 THEN

      INSERT INTO CECRED.TBGEN_CNAE (CDCNAE,DSCNAE,FLSERASA) VALUES (rw_cnae.CDCNAE,rw_cnae.DSCNAE,rw_cnae.FLSERASA);
         
ELSE
     
      UPDATE CECRED.TBGEN_CNAE SET DSCNAE = rw_cnae.DSCNAE, FLSERASA = rw_cnae.FLSERASA WHERE cdcnae = rw_cnae.CDCNAE;
      
END IF;

END LOOP;

-- Verifica qualquer erro ocorrido.

EXCEPTION

   WHEN OTHERS THEN

        raise_application_error(-20001,'Erro na carga do cnae: '||sqlerrm);
END;