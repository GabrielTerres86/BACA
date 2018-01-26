<?
/*!
 * FONTE        : imp_termo_pf_html.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 15/04/2010 							Ultima Atualizacao: 14/06/2017
 * OBJETIVO     : Responsável por buscar as informações que serão apresentadas no PDF de Termo da 
 *                rotina Impressões.
 *
 * 				  20/10/2010 - Realizado alteracao na clausula C (Adriano).
 *				  11/02/2011 - Aumento no formato do campo 'nome' para 50 (Gabriel).
 *		
 * 				  02/09/2015 - Projeto Reformulacao cadastral		  
 *						  	   (Tiago Castro - RKAM)			
 *
 *                07/01/2016 - Correcao nas informacoes apresentadas no paragrafo 3.a de acordo com cada cooperativa
 *                             Chamado 370421 (Heitor - RKAM)
 *
 *                14/06/2017 - Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
			                   crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
					          (Adriano - P339).
 */	 
?>
<?
	require_once('../../../includes/funcoes.php');
	require_once('../../../class/xmlfile.php');

	$xmlObjeto = $GLOBALS['xmlObjeto'];

	$AberIdent  = $xmlObjeto->roottag->tags[16]->tags[0]->tags;
	$AberPF     = $xmlObjeto->roottag->tags[17]->tags[0]->tags;
	$AberCompPF = $xmlObjeto->roottag->tags[18]->tags;
	$AberDeclPF = $xmlObjeto->roottag->tags[19]->tags[0]->tags;

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
		
	pulaLinha(3);
	
	echo '<b>';escreveLinha( preencheString('1.IDENTIFICACAO:',76) );echo '</b>';	
	escreveLinha( '<b>'.preencheString('1.1.Cooperativa: '.'</b>'.getByTagName($AberIdent,'nmextcop'),76) );
	escreveLinha( preencheString('                 '.getByTagName($AberIdent,'dslinha1'),76) );
	escreveLinha( preencheString('                 '.getByTagName($AberIdent,'dslinha2'),76) );
	escreveLinha( preencheString('                 '.getByTagName($AberIdent,'dslinha3'),76) );	
		
	echo '<b>';escreveLinha( preencheString('1.2.Cooperado(a) Titular:</b> '.getByTagName($AberPF,'nmprimtl'),80) );	
	escreveLinha( preencheString('                  Conta Corrente: '.preencheString(getByTagName($AberPF,'nrdconta').' ',11,' ','D').', CPF: '.getByTagName($AberPF,'nrcpfcgc'),76) );	
	escreveLinha( preencheString('                  RG: '.getByTagName($AberPF,'nrdocmto'),76) );	
	
	echo '<b>';escreveLinha( preencheString('1.3.Endereco:</b> '.getByTagName($AberPF,'dslinha1'),80) );	
	escreveLinha( preencheString('              '.getByTagName($AberPF,'dslinha2'),76) );
	
	echo '<b>';escreveLinha( preencheString('1.4.Estado Civil:</b> '.getByTagName($AberPF,'dsestcvl'),80) );	
	
	if ( getByTagName($AberPF,'nmrepleg') != '') {
		echo '<b>';escreveLinha( preencheString('1.5.Dados do Representante Legal:</b> '.getByTagName($AberPF,'nmrepleg'),80) );	
		escreveLinha( preencheString('                                  CPF: '.getByTagName($AberPF,'nrcpfrep'),76) );	
		escreveLinha( preencheString('                                  RG: '.getByTagName($AberPF,'nrdocrep'),76) );
	}
	pulaLinha(1);
	
	if ( count($AberCompPF) != 0 ) {
		echo '<b>';escreveLinha( preencheString('2.DADOS COMPLEMENTARES',76) );echo '</b>';
		pulaLinha();
		foreach( $AberCompPF as $titulares ) {
			echo '<b>';escreveLinha( preencheString( preencheString(getByTagName($titulares->tags,'dstitulo'),34).'</b>'.getByTagName($titulares->tags,'nmprimtl') ,80) ) ;
			
			$linha = preencheString('',22);
			$linha .= 'CPF: '.preencheString(getByTagName($titulares->tags,'nrcpfcgc'),14);
			escreveLinha( $linha );
			$linha = preencheString('',22);
			$linha .= 'RG: '.preencheString(getByTagName($titulares->tags,'nrdocmto'),76);
			escreveLinha( $linha );
			escreveLinha( '' );
		} 
	}

	echo '<b>';escreveLinha( preencheString('3.DECLARACOES',76) );echo '</b>';
	pulaLinha(1);

	escreveLinha( preencheString('O(a) <b>Cooperado(a)</b>, os demais titulares e os seus representantes legais, se',83) );
	escreveLinha( preencheString('este  for  o caso, propoem e a <b>Cooperativa</b> aceita a abertura de conta cor-',83) );
	escreveLinha( preencheString('rente, declarando   em  carater irrevogavel  e irretratavel, para todos os',76) );
	escreveLinha( preencheString('efeitos legais, que:',76) );
	pulaLinha(1);

	// Chamado 370421 - Revisao do Termo de Abertura
	$texto =  substr(getByTagName($AberDeclPF,'dsclact1'),3)
			 .getByTagName($AberDeclPF,'dsclact2').' '
			 .getByTagName($AberDeclPF,'dsclact3').' '
			 .getByTagName($AberDeclPF,'dsclact4').' '
			 .getByTagName($AberDeclPF,'dsclact5').' '
			 .getByTagName($AberDeclPF,'dsclact6');

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
	
	escreveLinha( preencheString('b) As informacoes e  elementos comprobatorios  fornecidos para abertura da',76) );
	escreveLinha( preencheString('conta  corrente, constantes  na  ficha cadastral anexa, sao a expressao da',76) );
	escreveLinha( preencheString('verdade. Desde  ja  autoriza(m) a <b>Cooperativa</b> e outras instituicoes finan-',83) );
	escreveLinha( preencheString('ceiras  parceiras, a efetuar  consultas  cadastrais  junto  ao CADIN, SPC,',76) );
	escreveLinha( preencheString('SERASA, Sistema de  Informacoes de Credito do Banco Central do Brasil-SCR,',76) );
	escreveLinha( preencheString('e demais bancos de dados que se fizerem necessarios a prestacao dos servi-',76) );
	escreveLinha( preencheString('cos financeiros  demandados pelo(s) titular(es), nos termos do previsto na',76) );
	escreveLinha( preencheString('legislacao  vigente, podendo enviar seus dados aos orgaos publicos ou pri-',76) );
	escreveLinha( preencheString('vados, administradores de banco de dados, entre outros.',76) );
	pulaLinha(1);
	
	escreveLinha( preencheString('Declara(m) ainda estar(estarem) cientes de que:',76) );
	pulaLinha(1);
	
	escreveLinha( preencheString('c) A conta aberta sera  movimentada de forma isolada  pelo(a) <b>Cooperado(a)',83) );
	escreveLinha( preencheString('Titular</b>, ou, quando possuir mais de um titular, sera movimentada separada-',83) );
	escreveLinha( preencheString('mente por cada um deles, podendo estes disporem do saldo que nela existir,',76) );
	escreveLinha( preencheString('mediante  emissao  de  cheques, recibos, TEDs, ordens  de  pagamentos,  ou',76) );
	escreveLinha( preencheString('quaisquer  outros  meios devidamentes regulamentados pelo Banco Central do',76) );
	escreveLinha( preencheString('Brasil, sendo  que  o  encerramento  da  conta  somente  podera  ser feito',76) );
	escreveLinha( preencheString('pelo(a) <b>Cooperado(a) Titular</b>.',76) );
	pulaLinha(1);
	
	escreveLinha( preencheString('d) A <b>Cooperativa</b> possui parceria com outras instituicoes para execucao dos',83) );
	escreveLinha( preencheString('servicos  de Centralizacao da Compensacao de Cheques e Outros Papeis (COM-',76) );
	escreveLinha( preencheString('PE); Manutencao do Cadastro de Emitentes de Cheques sem Fundos; Sistema de',76) );
	escreveLinha( preencheString('Liquidacao  de  Pagamentos  e Transferencias Interbancarias do Sistema Fi-',76) );
	escreveLinha( preencheString('nanceiro  Nacional e, para  disponibilizacao de cartoes e convenios diver-',76) );
	escreveLinha( preencheString('sos, autorizando para a consecucao destes servicos, o repasse das informa-',76) );
	escreveLinha( preencheString('coes cadastrais as instituicoes parceiras.',76) );
	pulaLinha(1);
	
	escreveLinha( preencheString('e) Podera(ao) ter  acesso aos  canais de autoatendimento  disponibilizados',76) );
	escreveLinha( preencheString('pela <b>Cooperativa</b>, ou ainda, outros que venham a ser  disponibilizados, pa-',83) );
	escreveLinha( preencheString('ra realizacao de movimentacoes, transacoes e  contratacoes  financeiras em',76) );
	escreveLinha( preencheString('sua conta corrente. Atualmente, sao disponibilizados os seguintes canais:',76) );
	pulaLinha(1);
	
    escreveLinha( preencheString('f) Conta online: canal eletronico via internet para  acesso  a informacoes',76) );
    escreveLinha( preencheString('sobre produtos e servicos da <b>Cooperativa</b>, que  possibilita a realizacao de',83) );
    escreveLinha( preencheString('consultas, movimentacoes, antecipacao  de pagamento de contratos (observa-',76) );
	escreveLinha( preencheString('das as  regras  estipuladas  para  este  servico), transacoes  e contrata-',76) );
	escreveLinha( preencheString('coes, inclusive de credito, diretamente em  sua conta. Apos a liberacao da',76) );
	escreveLinha( preencheString('conta   online  e  cadastramento   da  senha   no  Posto  de   Atendimento',76) );
	escreveLinha( preencheString('da <b>Cooperativa</b>, o primeiro  acesso devera ser realizado  pelo Cooperado(a)',83) );
	escreveLinha( preencheString('Titular no prazo de 03 (tres) dias, sob pena de cancelamento. E de respon-',76) );
	escreveLinha( preencheString('sabilidade do(s) titular(es) os  atos praticados  por  meio  deste  canal,',76) );
	escreveLinha( preencheString('ficando a <b>Cooperativa</b> isenta de  qualquer  responsabilidade por  eventuais',83) );
	escreveLinha( preencheString('prejuizos  sofridos, inclusive  causados  a terceiros, decorrentes de atos',76) );
	escreveLinha( preencheString('praticados mediante a utilizacao de senha pessoal.',76) );
	pulaLinha(1);
	
	escreveLinha( preencheString('g) Aplicativo  para  celular: canal  para  acesso a conta, mediante uso da',76) );
    escreveLinha( preencheString('mesma  senha  de  utilizacao  da Conta Online, podendo realizar consultas,',76) );
	escreveLinha( preencheString('movimentacoes, transacoes e contratacoes  relativas a produtos e servicos,',76) );
	escreveLinha( preencheString('inclusive  de  credito, diretamente em sua conta, conforme disponibilizado',76) );
	escreveLinha( preencheString('pela <b>Cooperativa</b>.',76) );
	
	pulaLinha(1);	
	
	escreveLinha( preencheString('h) Terminal de autoatendimento: equipamento localizado nos Postos de Aten-',76) );
	escreveLinha( preencheString('dimento  ou em  outros locais de acesso publico, devidamente identificados',76) );
	escreveLinha( preencheString('com as credenciais  da <b>Cooperativa</b>, para realizacao de consultas, movimen-',83) );
	escreveLinha( preencheString('tacoes, transacoes e  contratacoes relativas a produtos e servicos, inclu-',76) );
	escreveLinha( preencheString('sive de credito, diretamente na conta corrente.',76) );
	pulaLinha(1);	
	
	escreveLinha( preencheString('i) Sao disponibilizados  os servicos de Tele Saldo e SAC (Servico de Aten-',76) );
	escreveLinha( preencheString('dimento ao  Cooperado), por  meio de atendimento telefonico, para realizar',76) );
	escreveLinha( preencheString('consultas, obter  informacoes, solicitar e autorizar transacoes, inclusive',76) );
	escreveLinha( preencheString('as  relativas  a  contratacao  de   produtos  e  servicos,  ofertadas  pe-',76) );
	escreveLinha( preencheString('la <b>Cooperativa</b>, a  qual  reserva-se  no  direito  de, e  a  seu  exclusivo',83) );
	escreveLinha( preencheString('criterio, disponibilizar  novas  informacoes, operacoes e servicos, ou ex-',76) );
	escreveLinha( preencheString('cluir  quaisquer  daqueles  ofertados  na data da formalizacao da abertura',76) );
	escreveLinha( preencheString('da conta corrente. Por medida de seguranca fica a <b>Cooperativa</b> autorizada a',83) );
	escreveLinha( preencheString('realizar gravacoes das solicitacoes e instrucoes telefonicas.',76) );
	pulaLinha(1);	
	
	escreveLinha( preencheString('j) A <b>Cooperativa</b> podera  disponibilizar por meio dos canais de autoatendi-',83) );
	escreveLinha( preencheString('mento existentes, ou ainda aqueles que venham a ser criados, a  possibili-',76) );
	escreveLinha( preencheString('dade  de  contratacao de operacoes de credito, desde que os requisitos ne-',76) );
	escreveLinha( preencheString('cessarios  para  sua  contratacao e as regras estipuladas pela <b>Cooperativa</b>',83) );
	escreveLinha( preencheString('sejam  observados. Tratando-se  de  conta  que possuir mais de um titular,',76) );
	escreveLinha( preencheString('o(a) <b>Cooperado(a)  Titular</b> declara-se  ciente  que  os demais titulares da',83) );
	escreveLinha( preencheString('conta  tambem  poderao  realizar, em  seu  nome, as contratacoes previstas',76) );	
	escreveLinha( preencheString('neste item, sendo de sua inteira responsabilidade o adimplemento das obri-',76) );
	escreveLinha( preencheString('gacoes contraidas.',76) );		
	pulaLinha(1);	
	
	escreveLinha( preencheString('k) Diante  de  incapacidade  civil absoluta ou relativa do(a) <b>Cooperado(a)',83) );
	escreveLinha( preencheString('Titular</b>, a  movimentacao  da  conta  corrente sera  realizada por  meio de',83) );
	escreveLinha( preencheString('representacao  ou  assistencia  dos  representante(s)  legal(is), conforme',76) );	
	escreveLinha( preencheString('o caso.',76) );	
	pulaLinha(1);	
	
	escreveLinha( preencheString('l) A <b>Cooperativa</b> podera  disponibilizar  a  seu criterio pacote de tarifas',83) );
	escreveLinha( preencheString('para a movimentacao  da  conta  corrente. Ao aderir  o  pacote  de tarifas',76) );
	escreveLinha( preencheString('conforme opcao realizada em Termo de Adesao proprio, o(a) <b>Cooperado(a) Ti-',83) );
	escreveLinha( preencheString('tular</b> autoriza o debito dos valores correspondentes ao pacote, diretamente',83) );	
	escreveLinha( preencheString('desta conta.',76) );	
	pulaLinha(1);	
	
	escreveLinha( preencheString('m) As  partes  declaram que este instrumento esta vinculado as disposicoes',76) );
	escreveLinha( preencheString('legais cooperativistas, ao Estatuto Social da <b>Cooperativa</b> e demais delibe-',83) );
	escreveLinha( preencheString('racoes assembleares  desta, e do seu  Conselho de Administracao, aos quais',76) );
	escreveLinha( preencheString('o(a) <b>Cooperado(a)</b> e os demais titulares, livres e espontaneamente aderiram',83) );
	escreveLinha( preencheString('ao  integrar  o quadro social da <b>Cooperativa</b>, cujo teor ratifica, reconhe-',83) );	
	escreveLinha( preencheString('cendo neste contrato a celebracao de um <b>Ato Cooperativo</b>.',76) );	
	pulaLinha(3);		
	
	escreveLinha( preencheString(getByTagName($AberDeclPF,'dsmvtolt'),76) );
	
	pulaLinha(5);
	
	escreveLinha( preencheString('______________________________',76) );
	pulaLinha(1);
	escreveLinha( preencheString(getByTagName($AberDeclPF,'nmextttl'),76) );
	
	pulaLinha(3);
		
	$linha = '';
	$linha =  ( getByTagName($AberDeclPF,'nmsgdttl') != '' ) ? preencheString('_____________________________',50) : '';
	$linha .= ( getByTagName($AberDeclPF,'nmterttl') != '' ) ? preencheString('_____________________________',50) : '';
	escreveLinha( $linha );
	
	pulaLinha(1);
	
	$linha = '';
	$linha =  ( getByTagName($AberDeclPF,'nmsgdttl') != '' ) ? preencheString(getByTagName($AberDeclPF,'nmsgdttl'),50) : '';
	$linha .= ( getByTagName($AberDeclPF,'nmterttl') != '' ) ? preencheString(getByTagName($AberDeclPF,'nmterttl'),50) : '';
	escreveLinha( $linha );
	
	if ( getByTagName($AberDeclPF,'nmqtottl') != '' ) {
		pulaLinha(3);

		$linha =  ( getByTagName($AberDeclPF,'nmqtottl') != '' ) ? preencheString('_____________________________',76) : '';
		escreveLinha( $linha );
		
		pulaLinha(1);
		
		$linha =  ( getByTagName($AberDeclPF,'nmqtottl') != '' ) ? preencheString(getByTagName($AberDeclPF,'nmqtottl'),76) : '';
		escreveLinha( $linha );
	}
	
	pulaLinha(3);
	if ( getByTagName($AberPF,'nmrepleg') != '' ){
		$linha = ( getByTagName($AberPF,'nmrepleg') != '' ) ? preencheString('______________________________________________',76) : '';
		escreveLinha( $linha );
		pulaLinha(1);
		
		$linha = ( getByTagName($AberPF,'nmrepleg') != '' ) ? preencheString(getByTagName($AberPF,'nmrepleg'),76) : '';
		escreveLinha( $linha  );
		
		pulaLinha(2);
	}
	
	pulaLinha(3);
	
	escreveLinha( preencheString('______________________________',76) );
	pulaLinha(1);
	escreveLinha( preencheString(getByTagName($AberDeclPF,'nmextcop'),76) );
	pulaLinha(3);
	
	escreveLinha( preencheString('______________________________       ______________________________',76) );
	
	pulaLinha(1);
	
	escreveLinha( preencheString('Testemunha 1: ________________       Testemunha 2:________________',76) );

	pulaLinha(1);
	
    escreveLinha( preencheString('CPF: ___.___.___-__                  CPF: ___.___.___-__',76) );

	pulaLinha(1);
    
	//escreveLinha( preencheString('CI:___________________               CI:__________________',76) );
	
	pulaLinha(2);

	echo '<b>';escreveLinha( preencheString('Autorizacao para  movimentacao de     Autorizacao para  movimentacao de',76) );echo '</b>';
    echo '<b>';escreveLinha( preencheString('conta  corrente  para   menor  de     conta   corrente  para  menor  de',76) );echo '</b>';
    echo '<b>';escreveLinha( preencheString('idade (12 a 16 anos  incompletos)     idade (16 a 18 anos  incompletos)',76) );echo '</b>';
    escreveLinha( preencheString('Na   qualidade  de    Responsavel     Na    qualidade  de   Responsavel',76) );
    escreveLinha( preencheString('Legal do(a)  menor titular  desta     Legal  do(a) menor titular  desta',76) );
    escreveLinha( preencheString('conta, AUTORIZO-O(A) a movimentar     conta, AUTORIZO-O(A) a movimentar',76) );
    escreveLinha( preencheString('sua conta corrente,   como se por     isoladamente  sua conta corrente,',76) );
    escreveLinha( preencheString('mim    estivesse     pessoalmente     inclusive   requisitar   talao  e',76) );
    escreveLinha( preencheString('representado.                         emitir  cheques,  como   se   por',76) );
    escreveLinha( preencheString('                                      mim    estivesse     pessoalmente',76) );
    escreveLinha( preencheString('                                      representado.',76) );

	pulaLinha(3);

	escreveLinha( preencheString('     _____________________              _____________________',76) );
    escreveLinha( preencheString('       Responsavel Legal                  Responsavel Legal',76) );
	
	echo '</pre>';
?>