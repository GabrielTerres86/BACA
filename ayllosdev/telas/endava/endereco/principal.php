<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : Maio/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de Endeço da tela de CONTAS
 *
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1).
 *				  
 *			      16/06/2011 - Adicionado verificacao de tag xml ALERTAS (Jorge).
 *
 *                02/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
 *                             pois a BO não utiliza o mesmo (Renato Darosci)
 *
 */	
?>
<?	
	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();		
	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;	
	
	switch( $operacao ) {
		case 'CA': $op = "A"; break;
		case 'EA': $op = "A"; break;
		case 'AC': $op = "@"; break;
		case ''  : $op = "@"; break;
		default  : $op = "@"; break;
	}
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$op)) <> "") exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);

	$nrdconta = $_POST["nrdconta"] == "" ? 0 : $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"] == "" ? 0 : $_POST["idseqttl"];
	
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq. Titular n&atilde;o foi informada.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);	
	if ($idseqttl==0) exibirErro('error','Seq. Titular n&atilde;o foi informada.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);	
	
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
	if (strtoupper($xmlObjEnd->roottag->tags[0]->name) == "ERRO") exibirErro('error',$xmlObjEnd->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','fechaRotina(divRotina);',false);
	
	$endereco = $xmlObjEnd->roottag->tags[0]->tags[0]->tags;	
	$msgAlert = trim($xmlObjEnd->roottag->tags[0]->attributes['MSGALERT']);		
	$inpessoa = $xmlObjEnd->roottag->tags[0]->attributes['INPESSOA'];
	
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
			exibirErro('error',$xmlObjEA->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);',false);
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
	if ( msgConta != '' ) { 
		showError('inform',msgConta,'Alerta - Ayllos','bloqueiaFundo(divRotina);controlaFoco(\''+operacao+'\');');
	}else if ( msgAlert != '' ) { 
		showError('inform',msgAlert,'Alerta - Ayllos','bloqueiaFundo(divRotina);controlaFoco(\''+operacao+'\');');
	}
	if ( operacao == 'EA' ) controlaOperacao('AE'); 
</script>
<?php 
	if ( $operacao == 'EA' ){
		if(strtoupper($xmlObjEA->roottag->tags[1]->name) == "ALERTAS"){
			if($xmlObjEA->roottag->tags[1]->tags[0]->tags[0]->cdata != ""){
				exibirErro('inform',$xmlObjEA->roottag->tags[1]->tags[0]->tags[0]->cdata,'Alerta - Ayllos','controlaOperacao(\'AE\');',true,420);
			}
		}	
	}
?>
