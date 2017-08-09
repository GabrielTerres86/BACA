<?
/*!
 * FONTE        : imp_termo_pj_html.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 15/04/2010 							Ultima Atualizacao: 03/02/2016.
 * OBJETIVO     : Responsável por buscar as informações que serão apresentadas no PDF de Termo da 
 *                rotina Impressões.
 *	
 *			      20/10/2010 - Realizado alteracao na clausula C (Adriano).
 *
 * 				  02/09/2015 - Projeto Reformulacao cadastral		  
 *					  	      (Tiago Castro - RKAM)			 
 *
 *                07/01/2016 - Correcao nas informacoes apresentadas no paragrafo 3.a de acordo com cada cooperativa
 *                             Chamado 370421 (Heitor - RKAM)
 *                  
 *                03/02/2016 - Adicionado duas novas clausulas ao contrato conforme solicitado no chamado 388719. (Kelvin)
 */	 
?>
<?
	require_once('../../../includes/funcoes.php');
	require_once('../../../class/xmlfile.php');
	
	$xmlObjeto = $GLOBALS['xmlObjeto']; 	
		
	$AberIdent  = $xmlObjeto->roottag->tags[16]->tags[0]->tags;
	$AberPJ     = $xmlObjeto->roottag->tags[20]->tags[0]->tags;
	$AberCompPJ = $xmlObjeto->roottag->tags[21]->tags;
	$AberDeclPJ = $xmlObjeto->roottag->tags[22]->tags[0]->tags;
	
?>
<style type="text/css">
	pre, b { 
		font-family: monospace, "Courier New", Courier; 
		font-size:9pt;
	}
	p {
		 page-break-before: always;
		 padding: 0px;
		 margin:0px;	
	}
</style>
<?
    //Funcao para justificar o texto que esta sendo inserido no arquivo
    function justify( $str_in, $desired_length=48 ) {
		// Cut off long lines
		if ( strlen( $str_in ) > $desired_length ) {
			$str_in = current( explode( "\n", wordwrap( $str_in, $desired_length ) ) );
		}
		// String length
		$string_length = strlen( $str_in );
		// Number of spaces
		$spaces_count = substr_count( $str_in, ' ' );
		// Number of total spaces needed
		$needed_spaces_count = $desired_length - $string_length + $spaces_count;
		// One word, so split spaces in half, ceil it add it to eaither side of the word
		// Then take the first 48 chars
		if ( $spaces_count === 0 ) {
			return str_pad( $str_in, $desired_length, ' ', STR_PAD_BOTH );
		}
		// How many spaces the string needs per space to have atleast 48 characters
		$spaces_per_space = ceil( $needed_spaces_count / $spaces_count );
		// Replace all spaces with the neccessary spaces per space
		// This string will sometimes be too long
		$spaced_string = preg_replace( '~\s+~', str_repeat( ' ', $spaces_per_space ), $str_in );
		// Now, some strings will be too long so you need to replace the spaces with one less space until
		// the desired amount of characters is reached
		//
		// This is done with preg_replace callback and the $limit parameter
		// Limit replacements to the exact number we need to reach the desired length
		return preg_replace_callback(
			sprintf( '~\s{%s}~', $spaces_per_space ),
			function ( $m ) use( $spaces_per_space ) {
				return str_repeat( ' ', $spaces_per_space-1 );
			},
			$spaced_string,
			strlen( $spaced_string ) - $desired_length
		);
	}

	echo '<pre>'; 
	
	// if ( $GLOBALS['tprelato'] == 'completo' ) escreveLinha( preencheString('PAG '.$GLOBALS['numPagina'],76,' ','D') );
	echo '<b>';
	escreveLinha( preencheString('PROPOSTA/CONTRATO DE ABERTURA DE CONTA CORRENTE',76,' ','C') );	
	escreveLinha( preencheString(getByTagName($AberIdent,'dstitulo'),76,' ','C') );	
	echo '</b>';
		
	pulaLinha(2);
	
	echo '<b>';escreveLinha( preencheString('1.IDENTIFICACAO:',76) );echo '</b>';		
	echo '<b>';escreveLinha( preencheString('1.1.Cooperativa:</b> '.getByTagName($AberIdent,'nmextcop'),76) );
	escreveLinha( preencheString('                 '.getByTagName($AberIdent,'dslinha1'),76) );
	escreveLinha( preencheString('                 '.getByTagName($AberIdent,'dslinha2'),76) );
	escreveLinha( preencheString('                 '.getByTagName($AberIdent,'dslinha3'),76) );

	echo '<b>';escreveLinha( preencheString('1.2.Cooperada Titular:</b> '.getByTagName($AberPJ,'nmprimtl'),80) );	
	escreveLinha( preencheString('               Conta Corrente: '.preencheString(getByTagName($AberPJ,'nrdconta').' ',11,' ','D').', CNPJ: '.getByTagName($AberPJ,'nrcpfcgc'),80) );
	
	
	echo '<b>';escreveLinha( preencheString('1.3.Endereco:</b> '.getByTagName($AberPJ,'dslinha1'),79) );	
	escreveLinha( preencheString('              '.getByTagName($AberPJ,'dslinha2'),79) );
	
	pulaLinha(1);
	
	echo '<b>';escreveLinha( preencheString('2.DADOS COMPLEMENTARES:',76) );echo '</b>';
	
	echo '<b>';escreveLinha( preencheString('2.1.Natureza Juridica:</b> '.preencheString(getByTagName($AberPJ,'dsnatjur').' ',15).' ,<b>Inscricao Estadual:</b> '.getByTagName($AberPJ,'nrinsest'),87) );
		
	echo '<b>';escreveLinha( preencheString('2.2.Qualificacao dos Administradores:',76) );echo '</b>';
	
	pulaLinha(1);
	
	foreach( $AberCompPJ as $admin ) {
		echo '<b>';escreveLinha( preencheString( preencheString(getByTagName($admin->tags,'dstitulo'),16).'</b>'.getByTagName($admin->tags,'dsproftl') ,80) );
		escreveLinha( preencheString( preencheString( '' ,16).'CPF: '.preencheString( getByTagName($admin->tags,'nrcpfcgc') ,14).' , RG: '.getByTagName($admin->tags,'nrdocmto') ,76) );
		echo '<b>';escreveLinha( preencheString( '      Endereco:</b> '.getByTagName($admin->tags,'dslinha1'),79) );
		escreveLinha( preencheString( '                '.getByTagName($admin->tags,'dslinha2'),79) );
		pulaLinha(1);
	}
	
	echo '<b>';escreveLinha( preencheString('3.DECLARACOES',76) );echo '</b>';
	pulaLinha(1);
		
	escreveLinha( preencheString('A <b>Cooperada</b>  propoe  e  a Cooperativa aceita a abertura de conta corrente,',83) );
	escreveLinha( preencheString('declarando  em  carater  irrevogavel e irretratavel, para todos oe efeitos',76) );
	escreveLinha( preencheString('legais, que:',76) );
	pulaLinha(1);
	
	// Chamado 370421 - Revisao do Termo de Abertura
	$texto =  substr(getByTagName($AberDeclPJ,'dsclact1'),3)
			 .getByTagName($AberDeclPJ,'dsclact2').' '
			 .getByTagName($AberDeclPJ,'dsclact3').' '
			 .getByTagName($AberDeclPJ,'dsclact4').' '
			 .getByTagName($AberDeclPJ,'dsclact5').' '
			 .getByTagName($AberDeclPJ,'dsclact6');

	$texto = str_replace('- ','',$texto);

	if (in_array($GLOBALS['cdcooper'],array(4,5,6,10,11))) {
		$texto = str_replace('  ',' ',$texto);
	}

	escreveLinha( preencheString('a) Esta(Estao) de pleno acordo com as disposicoes  contidas  nas <b>CLAUSULAS',77) );
	escreveLinha( preencheString('GERAIS APLICAVEIS AO CONTRATO DE CONTA CORRENTE E CONTA INVESTIMENTO</b>, dis-',78) );

	$texto2 = wordwrap($texto,74,'</br>',true);

	for ($i = 1; $i <= 4; $i++) {
		$posicao = stripos($texto2,'</br>');
		escreveLinha( preencheString(justify(trim(substr($texto2,0,$posicao)),74),74) );
		$texto2 = substr($texto2,$posicao+5);
	}

	escreveLinha( preencheString($texto2,74) );
	pulaLinha(1);
	// Fim Chamado 370421 - Revisao do Termo de Abertura
	/*
	escreveLinha( preencheString('a) Esta  de  pleno acordo com as disposicoes contidas nas <b>CLAUSULAS GERAIS',83) );
	escreveLinha( preencheString('APLICAVEIS AO CONTRATO DE CONTA CORRENTE  E CONTA INVESTIMENTO</b>, disponivel' ,83) );
	escreveLinha( preencheString('no site da <b>Cooperativa</b> (www.viacredi.coop.br) e registrado no  Cartorio de' ,83) );
	escreveLinha( preencheString('Registro de Titulos e Documentos da cidade de Blumenau, sob n 99742, Livro' ,76) );
	escreveLinha( preencheString('B 340, Folha 005 em  13/11/2006, que integram  este  contrato, formando um' ,76) );
	escreveLinha( preencheString('documento unico e indivisivel, cuja copia recebe no ato da assinatura des-' ,76) );
	escreveLinha( preencheString('te instrumento.' ,76) );
	pulaLinha(1);
	*/
		 	
	escreveLinha( preencheString('b) As informacoes e  elementos comprobatorios  fornecidos para abertura da',76) );
	escreveLinha( preencheString('conta  corrente, constantes  na  ficha cadastral anexa, sao a expressao da',76) );
	escreveLinha( preencheString('verdade. Desde ja autoriza a <b>Cooperativa</b> e outras instituicoes financeiras',83) );
	escreveLinha( preencheString('parceiras, a  efetuar  consultas  cadastrais  junto ao CADIN, SPC, SERASA,',76) );
	escreveLinha( preencheString('Sistema de Informacoes de Credito do Banco Central do Brasil-SCR, e demais',76) );
	escreveLinha( preencheString('bancos de dados que se fizerem necessarios a prestacao dos servicos finan-',76) );
	escreveLinha( preencheString('ceiros  demandados  pela <b>Cooperada</b>, nos  termos do previsto  na Legislacao',83) );
	escreveLinha( preencheString('vigente, podendo  enviar  seus  dados  aos  orgaos  publicos  ou privados,',76) );
	escreveLinha( preencheString('administradores de banco de dados, entre outros.',76) );
	pulaLinha(1);
	
	/* escreveLinha( preencheString('b) Declara a  <b>Cooperada</b>  estar ciente e de pleno acordo com as disposicoes',83) );
	escreveLinha( preencheString('contidas  nas   CLAUSULAS   GERAIS  DO   CONTRATO   DE  CONTA  CORRENTE  E',76) );
	escreveLinha( preencheString('CONTA INVESTIMENTO, '.getByTagName($AberDeclPJ,'dsclact1'),76) );
	escreveLinha( preencheString(getByTagName($AberDeclPJ,'dsclact2'),76) );
	escreveLinha( preencheString(getByTagName($AberDeclPJ,'dsclact3'),76) );
	escreveLinha( preencheString(getByTagName($AberDeclPJ,'dsclact4'),76) );
	escreveLinha( preencheString(getByTagName($AberDeclPJ,'dsclact5'),76) );
	escreveLinha( preencheString(getByTagName($AberDeclPJ,'dsclact6'),76) ); */
	
	escreveLinha( preencheString('Declara ainda estar ciente de que:',76) );
	pulaLinha(1);
		
	escreveLinha( preencheString('c) A conta aberta, sera movimentada por um ou mais socios, ou por procura-',76) );
	escreveLinha( preencheString('dores  legalmente  constituidos, conforme especificado na ficha cadastral,',83) );
	escreveLinha( preencheString('podendo  estes  disporem  do  saldo que nela existir, mediante  emissao de',76) );
	escreveLinha( preencheString('cheques, recibos, TEDs, ordens  de  pagamentos, ou quaisquer outros  meios',76) );
	escreveLinha( preencheString('devidamentes  regulamentados  pelo Banco Central do Brasil, podendo inclu-',76) );
	escreveLinha( preencheString('sive, realizar seu encerramento.',76) );
	pulaLinha(1);	
	
	escreveLinha( preencheString('d) A <b>Cooperativa</b> possui parceria com outras instituicoes para execucao dos',83) );
	escreveLinha( preencheString('servicos de Centralizacao da  Compensacao de Cheques e Outros Papeis (COM-',76) );
	escreveLinha( preencheString('PE); Manutencao do Cadastro de Emitentes de Cheques sem Fundos; Sistema de',76) );
	escreveLinha( preencheString('Liquidacao de Pagamentos e Transferencias Interbancarias do Sistema Finan-',76) );
	escreveLinha( preencheString('ceiro Nacional e, para disponibilizacao de  cartoes e convenios  diversos,',76) );
	escreveLinha( preencheString('autorizando para a consecucao destes servicos, o  repasse das  informacoes',76) );
	escreveLinha( preencheString('cadastrais as instituicoes parceiras.',76) );
	pulaLinha(1);	
	
	escreveLinha( preencheString('e) Podera  ter  acesso  aos  canais  de  autoatendimento  disponibilizados',76) );
	escreveLinha( preencheString('pela <b>Cooperativa</b>, ou ainda, outros que venham a ser disponibilizados, para',83) );
	escreveLinha( preencheString('realizacao de movimentacoes, transacoes e contratacoes  financeiras em sua',76) );
	escreveLinha( preencheString('conta corrente. Atualmente, sao disponibilizados os seguintes canais:',76) );
	pulaLinha(1);
	
	escreveLinha( preencheString('f) Conta online: canal eletronico via internet, para acesso  a informacoes',76) );
    escreveLinha( preencheString('sobre produtos e servicos da <b>Cooperativa</b>, podendo  realizar consultas, mo-',83) );
    escreveLinha( preencheString('vimentacoes, antecipacao de  pagamento de contratos (observadas as  regras',76) );
	escreveLinha( preencheString('estipuladas  para  este  servico), transacoes  e  contratacoes,  inclusive',76) );
	escreveLinha( preencheString('de  credito, diretamente  em  sua  conta. Na  liberacao de acesso da conta',76) );
	escreveLinha( preencheString('online, os  atos  praticados neste canal, serao realizadas de acordo com o',76) );
	escreveLinha( preencheString('que  dispuser os atos constitutivos da <b>Cooperada</b> e nos limites de  poderes',83) );
	escreveLinha( preencheString('de representacao conferidos aos seus representantes legais. No caso de re-',76) );
	escreveLinha( preencheString('presentacao  por unica pessoa fisica, esta fara o uso de sua senha pessoal',76) );
	escreveLinha( preencheString('e intransferivel para realizacao de todos os atos. No  caso de representa-',76) );
	escreveLinha( preencheString('cao por duas ou mais pessoas fisicas, os atos somente serao concluidos me-',76) );
	escreveLinha( preencheString('diante confirmacao  das operacoes e com  senha  pessoal de todos os repre-',76) );
	escreveLinha( preencheString('sentantes legais  da <b>Cooperada</b>. E de responsabilidade da <b>Cooperada</b> os atos',89) );
	escreveLinha( preencheString('praticados por  meio deste canal, ficando a <b>Cooperativa</b> isenta de qualquer',83) );
	escreveLinha( preencheString('responsabilidade  por  eventuais  prejuizos sofridos, inclusive causados a',76) );
	escreveLinha( preencheString('terceiros, decorrentes  de  atos praticados mediante a utilizacao de senha',76) );
	escreveLinha( preencheString('pessoal.',76) );
	pulaLinha(1);
	
	escreveLinha( preencheString('g) A <b>Cooperada</b> podera  cadastrar operador(es) para utilizacao da conta on-',83) );
	escreveLinha( preencheString('line, hipotese  em  que  necessariamente  devera(ao)  ser definida(s) a(s)',76) );
	escreveLinha( preencheString('senha(s)  e  as permissoes de acesso para o(s) operador(es) cadastrado(s).',76) );
	escreveLinha( preencheString('As  transacoes  financeiras  realizadas  pelo(s) operador(es) deverao  ser',76) );
	escreveLinha( preencheString('aprovadas pelo(s) representante(s) legal(is) da <b>Cooperada</b>, mediante acesso',83) );
	escreveLinha( preencheString('a conta online no site da <b>Cooperativa</b>. Nao havendo aprovacao, as operacoes',83) );
	escreveLinha( preencheString('serao canceladas e deverao ser novamente registradas e aprovadas.',76) );
	pulaLinha(1);
	
	escreveLinha( preencheString('h) Aplicativo  para  celular: canal  para  acesso a conta, mediante uso da',76) );
    escreveLinha( preencheString('mesma  senha  de  utilizacao  da Conta Online, podendo realizar consultas,',76) );
	escreveLinha( preencheString('movimentacoes, transacoes e contratacoes  relativas a produtos e servicos,',76) );
	escreveLinha( preencheString('inclusive  de credito, diretamente em sua conta, conforme  disponibilizado',76) );
	escreveLinha( preencheString('pela <b>Cooperativa</b>.',76) );
	pulaLinha(1);
	
	escreveLinha( preencheString('i) Terminal de autoatendimento: equipamento localizado nos Postos de Aten-',76) );
	escreveLinha( preencheString('dimento  ou em  outros locais de acesso publico, devidamente identificados',76) );
	escreveLinha( preencheString('com as credenciais  da <b>Cooperativa</b>, para realizacao de consultas, movimen-',83) );
	escreveLinha( preencheString('tacoes, transacoes e  contratacoes relativas a produtos e servicos, inclu-',76) );
	escreveLinha( preencheString('sive de credito, diretamente na conta corrente.',76) );
	pulaLinha(1);	
	
	escreveLinha( preencheString('j) Sao  disponibilizados os servicos de Tele Saldo e SAC (Servico de Aten-',76) );
	escreveLinha( preencheString('dimento  ao  Cooperado), por  meio  de atendimento telefonico, para reali-',76) );
	escreveLinha( preencheString('zar consultas, obter informacoes, solicitar e autorizar transacoes, inclu-',76) );
	escreveLinha( preencheString('sive  as  relativas  a  contratacao de produtos e servicos, ofertadas  pe-',76) );
	escreveLinha( preencheString('la <b>Cooperativa</b>, a  qual  reserva-se  no  direito  de, e  a  seu  exclusivo',83) );
	escreveLinha( preencheString('criterio,  disponibilizar  novas  informacoes,  operacoes  e  servicos, ou',76) );
	escreveLinha( preencheString('excluir  quaisquer  daqueles ofertados na data da formalizacao da abertura',76) );
	escreveLinha( preencheString('da conta  corrente. Por  medida de seguranca fica a <b>Cooperativa</b> autorizada',83) );
	escreveLinha( preencheString('a realizar gravacoes das solicitacoes e instrucoes telefonicas.',76) );
	pulaLinha(1);	
	
	escreveLinha( preencheString('k) A <b>Cooperativa</b> podera  disponibilizar por meio dos canais de autoatendi-',83) );
	escreveLinha( preencheString('mento existentes, ou ainda aqueles que venham a ser criados, a  possibili-',76) );
	escreveLinha( preencheString('dade  de  contratacao de operacoes de credito, desde que os requisitos ne-',76) );
	escreveLinha( preencheString('cessarios  para  sua  contratacao e as regras estipuladas pela <b>Cooperativa</b>',83) );
	escreveLinha( preencheString('sejam  observados. A <b>Cooperada</b>  declara-se  ciente de que é de sua inteira',83) );
	escreveLinha( preencheString('reponsabilidade o adimplemento das obrigacoes contraidas/contratacoes rea-',76) );
	escreveLinha( preencheString('lizadas em seu nome.',76) );
	pulaLinha(1);	
	
	escreveLinha( preencheString('l) A <b>Cooperativa</b> podera  disponibilizar  a  seu criterio pacote de tarifas',83) );
	escreveLinha( preencheString('para  movimentacao  da  conta  corrente. Ao  aderir  o  pacote  de tarifas',76) );
	escreveLinha( preencheString('conforme opcao realizada em Termo de  Adesao proprio, a <b>Cooperada</b> autoriza',83) );
	escreveLinha( preencheString('o  debito dos valores correspondentes ao pacote, diretamente desta conta.',76) );	
	pulaLinha(1);	
			 
	escreveLinha( preencheString('m) A <b>Cooperativa</b> possui  Politica  de  Responsabilidade  Socioambiental, a',83) );
	escreveLinha( preencheString('qual a <b>Cooperada</b>  declara  conhecer, cumprindo  e  respeitando,  durante a',83) );
	escreveLinha( preencheString('vigencia desta Proposta/Contrato de Abertura de Conta Corrente, o disposto',76) );
	escreveLinha( preencheString('na legislacao e a regulamentacao ambiental e trabalhista, especialmente as',76) );
	escreveLinha( preencheString('normas  relativas a seguranca e medicina do trabalho e ao Meio Ambiente, e',76) );
	escreveLinha( preencheString('a  inexistencia  de  trabalho que importe em incentivo a prostituicao, que',76) );
	escreveLinha( preencheString('utilize mao de obra infantil, que mantenha seus trabalhadores em condicoes',76) );
	escreveLinha( preencheString('analogas a escravidao ou que cause danos ao meio ambiente.',76) );
	pulaLinha(1);	
	 
	escreveLinha( preencheString('n) Independentemente  de  culpa,  a  <b>Cooperada</b> ressarcira  a  <b>Cooperativa</b>,',89) );
	escreveLinha( preencheString('de  qualquer  quantia  que  esta  seja  compelido  a  pagar,  bem  como  a',76) );
	escreveLinha( preencheString('indenizara  por  quaisquer  perdas e danos  referentes a danos  ambientais',76) );
	escreveLinha( preencheString('ou  relativos  a  saude e seguranca  ocupacional que, de qualquer forma, a',76) );
	escreveLinha( preencheString('autoridade entenda estar relacionados a utilizacao dos produtos e servicos',76) );
	escreveLinha( preencheString('decorrentes desta Proposta/Contrato de Abertura de Conta Corrente.',76) );
	pulaLinha(1);	

	escreveLinha( preencheString('o) As  partes  declaram que este instrumento esta vinculado as disposicoes',76) );
	escreveLinha( preencheString('legais cooperativistas, ao Estatuto Social da <b>Cooperativa</b> e demais delibe-',83) );
	escreveLinha( preencheString('racoes assembleares desta, e do  seu  Conselho de Administracao, aos quais',76) );
	escreveLinha( preencheString('a <b>Cooperada</b>, livre  e espontaneamente  aderiu ao  integrar o quadro social',83) );
	escreveLinha( preencheString('da <b>Cooperativa</b>, cujo teor ratifica, reconhecendo neste contrato a celebra-',83) );	
	escreveLinha( preencheString('cao de um <b>Ato Cooperativo</b>.',76) );	
	
	pulaLinha(1);
	escreveLinha( preencheString(getByTagName($AberDeclPJ,'dsmvtolt'),76) );
	
	pulaLinha(6);
	
	escreveLinha( preencheString('______________________________',76) );
	pulaLinha(1);
	escreveLinha( preencheString(getByTagName($AberDeclPJ,'nmprimtl'),76) );
	
	pulaLinha(3);
	
	escreveLinha( preencheString('______________________________',76) );
	pulaLinha(1);
	escreveLinha( preencheString(getByTagName($AberDeclPJ,'nmextcop'),76) );
	
	pulaLinha(3);
	
	escreveLinha( preencheString('______________________________       ______________________________',76) );
	
	pulaLinha(1);
	
	escreveLinha( preencheString('Testemunha 1: ________________       Testemunha 2:________________',76) );

	pulaLinha(1);
	
    escreveLinha( preencheString('CPF: ___.___.___-__               CPF: ___.___.___-__',76) );

	pulaLinha(1);
    
	//escreveLinha( preencheString('CI:___________________               CI:__________________',76) );

	
	echo '</pre>';

?>