<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 02/08/2011
 * OBJETIVO     : Capturar dados para tela EXTRDA
 * --------------
 * ALTERAÇÕES   : 
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


	// Recebe o POST
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Se conta informada não for um número inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Ayllos','',false);
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0103.p</Bo>';
	$xml .= '		<Proc>Busca_Extrda</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult 	= getDataXML($xml);
	$xmlObjeto 	= getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$registro 	= $xmlObjeto->roottag->tags[1]->tags[0]->tags;
		echo "cNmprimtl.val('".getByTagName($registro,'nmprimtl')."');";
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;								
		exibirErro('error',$msgErro,'Alerta - Ayllos','cNrdconta.focus();',false);
	} 

	$nraplica	= $xmlObjeto->roottag->tags[0]->attributes['NRAPLICA'];
	$registro 	= $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	echo "cNmprimtl.val('".getByTagName($registro,'nmprimtl')."');";
	
	// Verifica se voltou o numero do contrato
	
	if ( empty($nraplica) ) {
		echo "cNrdconta.desabilitaCampo();";
		echo "cNraplica.habilitaCampo().focus();";
		echo "qtdeExtrda='1';";
		echo "trocaBotao('concluir');";
		echo "hideMsgAguardo();";
	} else {
		echo "cNraplica.val('".$nraplica."');";
		echo "cNraplica.trigger('blur');";
		echo "manterRotina();";
	}

	echo "controlaPesquisas();";
	
?>