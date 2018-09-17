<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 25/07/2011
 * OBJETIVO     : Capturar dados para tela ALIENA
 * --------------
 * ALTERAÇÕES   : 21/11/2013 - Novas colunas GRAVAMES (Guilherme/SUPERO)
 * -------------- 
 */ 
?>

<?	
	session_start();	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	// Inicializa as variaveis
	$posicaoXML 		= 0;

	// Recebe o POST
	$cddopcao 			= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$nrdconta 			= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
	$nrctremp 			= (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0  ;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Se conta informada não for um número inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Ayllos','',false);
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0102.p</Bo>';
	$xml .= '		<Proc>Busca_Dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<nrctremp>'.$nrctremp.'</nrctremp>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult 	= getDataXML($xml);
	$xmlObjeto 	= getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$erro  	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;								
		echo 'erro = "'.$erro.'";';
		$posicaoXML++;
	}
	
	// Preenche o cabecalho com os dados do associado
	$cabecalho 	= $xmlObjeto->roottag->tags[$posicaoXML]->tags[0]->tags;
	echo 'aux_dtmvtolt = "'.getByTagName($cabecalho,'dtmvtolt').'";';
	echo 'aux_nmprimtl = "'.getByTagName($cabecalho,'nmprimtl').'";';
	
	// Recebe os dados da tabela	
	$tabela		= $xmlObjeto->roottag->tags[1]->tags;
	echo 'total = "'.count($tabela).'";';
	$i 			= 0; 
	
	// Armazena registros em um array
	foreach ( $tabela as $registro ) {
		echo 'var aux = new Array();';
		
		$strlen = strlen(getByTagName($registro->tags,'dscatbem'));
		
		echo 'aux[\'cdcooper\'] = "'.getByTagName($registro->tags,'cdcooper').'";';
		echo 'aux[\'nrdconta\'] = "'.getByTagName($registro->tags,'nrdconta').'";';
		echo 'aux[\'tpctrpro\'] = "'.getByTagName($registro->tags,'tpctrpro').'";';
		echo 'aux[\'nrctrpro\'] = "'.getByTagName($registro->tags,'nrctrpro').'";';
		echo 'aux[\'idseqbem\'] = "'.getByTagName($registro->tags,'idseqbem').'";';
		echo 'aux[\'dscatbem\'] = "'.getByTagName($registro->tags,'dscatbem').'";';
		echo 'aux[\'dsbemfin\'] = "'.substr(getByTagName($registro->tags,'dsbemfin'),0,38-$strlen).'";';
		echo 'aux[\'flgalfid\'] = "'.getByTagName($registro->tags,'flgalfid').'";';
		echo 'aux[\'dtvigseg\'] = "'.getByTagName($registro->tags,'dtvigseg').'";';
		echo 'aux[\'flglbseg\'] = "'.getByTagName($registro->tags,'flglbseg').'";';
		echo 'aux[\'flgrgcar\'] = "'.getByTagName($registro->tags,'flgrgcar').'";';
		echo 'aux[\'flgperte\'] = "'.getByTagName($registro->tags,'flgperte').'";';
		echo 'aux[\'dtatugrv\'] = "'.getByTagName($registro->tags,'dtatugrv').'";';
		echo 'aux[\'tpinclus\'] = "'.getByTagName($registro->tags,'tpinclus').'";';
		echo 'aux[\'cdsitgrv\'] = "'.getByTagName($registro->tags,'cdsitgrv').'";';

		echo 'arrayAliena['.$i.'] = aux;';
		$i++;

	}		
	
	
	echo 'controlaLayout();';
		
?>