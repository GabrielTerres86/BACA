<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 10/06/2011
 * OBJETIVO     : Capturar dados para tela DCTROR
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

	// Inicializa as variaveis
	$procedure 	= '';
	$mtdErro	= 'estadoCabecalho();';

	// Recebe o POST
	$operacao 	= (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;
	$controle 	= (isset($_POST['controle'])) ? $_POST['controle'] : 0  ;
	$cddopcao 	= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$tptransa 	= (isset($_POST['tptransa'])) ? $_POST['tptransa'] : '' ;
	$nrdconta 	= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
	$idseqttl 	= 1;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
	// Se conta informada não for um número inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Aimaro','',false);
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0095.p</Bo>";
	$xml .= "		<Proc>busca-dados</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "		<tptransa>".$tptransa."</tptransa>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult 	= getDataXML($xml);
	$xmlObjeto 	= getObjectXML($xmlResult);

	$msgretor 	= $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'];
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$dados 	= $xmlObjeto->roottag->tags[1]->tags;
		echo "$('#cdsitdtl','#frmDctror').val('".getByTagName($dados[0]->tags,'cdsitdtl')."');";
		echo "$('#cdsitdtl','#frmDctror').val('".getByTagName($dados[0]->tags,'cdsitdtl')."');";
		echo "$('#dssitdtl','#frmDctror').val('".getByTagName($dados[0]->tags,'dssitdtl')."');";
		echo "$('#nmprimtl','#frmCab').val('".getByTagName($dados[0]->tags,'nmprimtl')."');";
		
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$msgErro  = !empty($msgretor) ? $msgErro . '<br />' .$msgretor : $msgErro;
		
		exibirErro('error',$msgErro,'Alerta - Aimaro',$mtdErro,false);
	} 

	$registros 	= $xmlObjeto->roottag->tags[0]->tags;
	include('form_cabecalho.php');	
	include('form_dctror.php');	
	
		
?>

<script type='text/javascript'>
	atualizaSeletor();
	formataCabecalho();
	cConta.focus();
	controlaLayout();
</script>