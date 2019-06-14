<?php
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : Maio/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de Endeço da tela de CONTAS
 *
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1).
 *                16/06/2011 - Adicionado verificacao de tag xml ALERTAS (Jorge).
 *                04/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
 *                13/07/2016 - Correcao da forma de recuperacao da dados do XML.SD 479874. Carlos R.
 *                01/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
 *                             pois a BO não utiliza o mesmo (Renato Darosci)
 */	
	
	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();		
	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;	
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '' ;	
	$enderecoCorrespondencia = '';
	$enderecoComplementar = '';
	
	$glbvars["nmrotina"] = (isset($_POST['nmrotina'])) ? $_POST['nmrotina'] : $glbvars["nmrotina"];
	
	switch( $operacao ) {
		case 'CA': $op = "A"; break;
		case 'EA': $op = "A"; break;
		case 'AC': $op = "@"; break;
		case ''  : $op = "@"; break;
		default  : $op = "@"; break;
	}
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$op,false)) <> "") {
		$metodo =  ($flgcadas == 'M') ? 'proximaRotina();' : 'encerraRotina(false);';
		exibirErro('error',$msgError,'Alerta - Aimaro',$metodo,false);
	}
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);

	// Carrega permissões do operador
	include("../../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);

	// Carregas as opções da Rotina de Ativo/Passivo
	$flgAlterar  = (in_array("A", $glbvars["opcoesTela"]));
	
	$nrdconta = $_POST["nrdconta"] == "" ? 0  : $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"] == "" ? 0  : $_POST["idseqttl"];
	
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq. Titular n&atilde;o foi informada.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);	
	if ($idseqttl==0) exibirErro('error','Seq. Titular n&atilde;o foi informada.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);	
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0038.p</Bo>";
	$xml .= "		<Proc>obtem-endereco</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	$xmlResult = getDataXML($xml);
	$xmlObjEnd = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjEnd->roottag->tags[0]->name) == "ERRO") exibirErro('error',$xmlObjEnd->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','fechaRotina(divRotina);',false);

	// Percorre os enderecos retornados
	for ($i = 0; $i < count( $xmlObjEnd->roottag->tags[0]->tags); $i++) {
		
		$tpendass = getByTagName($xmlObjEnd->roottag->tags[0]->tags[$i]->tags,'tpendass');
				
		if ($tpendass == 9 || $tpendass == 10) { // Endereco Residencial/Comercial
			$endereco =  $xmlObjEnd->roottag->tags[0]->tags[$i]->tags;
		}
		else
		if ($tpendass == 13) { // Enderecos de Correspondencia 
			$enderecoCorrespondencia = $xmlObjEnd->roottag->tags[0]->tags[$i]->tags;
		} else 
		if ($tpendass == 14) { // Endereco complementar
			$enderecoComplementar    = $xmlObjEnd->roottag->tags[0]->tags[$i]->tags;
		}	
	}
	
	$msgAlert = ( isset($xmlObjEnd->roottag->tags[0]->attributes['MSGALERT']) ) ? trim($xmlObjEnd->roottag->tags[0]->attributes['MSGALERT']) : '';
	$inpessoa = ( isset($xmlObjEnd->roottag->tags[0]->attributes['INPESSOA']) ) ? trim($xmlObjEnd->roottag->tags[0]->attributes['INPESSOA']) : '';
	
	//Verifico se conta é titular em outra conta. Se atributo vier preenchido, muda operação para 'SC' => Somente Consulta
	$msgConta = trim($xmlObjEnd->roottag->tags[0]->attributes['MSGCONTA']);
	if( $msgConta != '' ) $operacao = 'SC';
	
	if ( $operacao == 'EA' ){
	
		$xmlEA  = "";
		$xmlEA .= "<Root>";
		$xmlEA .= "	<Cabecalho>";
		$xmlEA .= "		<Bo>b1wgen0038.p</Bo>";
		$xmlEA .= "		<Proc>obtem-atualizacao-endereco</Proc>";
		$xmlEA .= "	</Cabecalho>";
		$xmlEA .= "	<Dados>";
		$xmlEA .= "     <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlEA .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xmlEA .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xmlEA .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlEA .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
		$xmlEA .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
		$xmlEA .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xmlEA .= "		<idseqttl>".$idseqttl."</idseqttl>";
		$xmlEA .= "	</Dados>";
		$xmlEA .= "</Root>";
		
		$xmlResult = getDataXML($xmlEA);
		$xmlObjEA = getObjectXML($xmlResult);
		
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObjEA->roottag->tags[0]->name) == "ERRO"){ 
			exibirErro('error',$xmlObjEA->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
		}
		
		$enderecoA = $xmlObjEA->roottag->tags[0]->tags[0]->tags;
		
		?>
		<script type="text/javascript">
			$('#divConteudoOpcao').css({'-moz-opacity':'0','filter':'alpha(opacity=0)','opacity':'0'});
		</script> 
		<?
		if ( count($enderecoA) > 0 ){
			include('formulario_endereco_atualizado.php');
		}else{
			$operacao = 'CA';
			include('formulario_endereco.php');
		}
		
		
	}else{
		?>
		<script type="text/javascript">
			$('#divConteudoOpcao').css({'-moz-opacity':'0','filter':'alpha(opacity=0)','opacity':'0'});
		</script> 
		<?
		include('formulario_endereco.php');
	}	
?>
<script type='text/javascript'>
	var incasprp = '<? echo getByTagName($endereco,'incasprp'); ?>';	
	var msgAlert = '<? echo $msgAlert; ?>';
	var msgConta = '<? echo $msgConta  ?>';
	var operacao = '<? echo $operacao; ?>';
	
	controlaLayout(operacao);
	
	if (inpessoa == 1 && operacao != 'CA') {
		var flgAlterar  = "<? echo $flgAlterar;   ?>";
		var flgcadas    = "<? echo $flgcadas;     ?>";
		
		if (flgcadas == 'M') {
			controlaOperacao('CA');
		}
	}
	
	if ( msgConta != '' ) { 
		showError('inform',msgConta,'Alerta - Aimaro','bloqueiaFundo(divRotina);controlaFoco(\''+operacao+'\');');
	}else if ( msgAlert != '' ) { 
		showError('inform',msgAlert,'Alerta - Aimaro','bloqueiaFundo(divRotina);controlaFoco(\''+operacao+'\');');
	}
	if ( operacao == 'EA' ) controlaOperacao('AE'); 
</script>
<?php 
	if ( $operacao == 'EA' ){
		if(strtoupper($xmlObjEA->roottag->tags[1]->name) == "ALERTAS"){
			if($xmlObjEA->roottag->tags[1]->tags[0]->tags[0]->cdata != ""){
				exibirErro('inform',$xmlObjEA->roottag->tags[1]->tags[0]->tags[0]->cdata,'Alerta - Aimaro','controlaOperacao(\'AE\');',true,420);
			}
		}	
	}
?>
