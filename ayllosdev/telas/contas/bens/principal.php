<?php
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rodolpho Telmo - DB1 Informatica
 * DATA CRIAÇÃO : 03/03/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de bens da tela de CONTAS 
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1).
 *							  04/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
 *							  14/04/2016 - Correcao na forma de recuperacao das variaveis do XML.SD 479874.
 */
    session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();	
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : "C";	
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '';	
	
	
	$glbvars["nmrotina"] = (isset($_POST['nmrotina'])) ? $_POST['nmrotina'] : $glbvars["nmrotina"];


	$op = ( $cddopcao == "C" ) ? "@" : $cddopcao;
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$op,false)) <> '') {
		$metodo =  ($flgcadas == 'M') ? 'proximaRotina();' : 'encerraRotina(false);';
		exibirErro('error',$msgError,'Alerta - Ayllos',$metodo,false);
	}
	
	// Verifica se o número da conta e o titular foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	// Carrega permissões do operador
	include("../../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);
	
	// Carregas as opções da Rotina de Bens
	$flgAlterar  = (in_array("A", $glbvars["opcoesTela"]));
	$flgIncluir  = (in_array("I", $glbvars["opcoesTela"]));	
	$flgExcluir  = (in_array("E", $glbvars["opcoesTela"]));	
	
	// Guardo os parâmetos do POST em variáveis
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : "";
	$idseqttl = (isset($_POST["idseqttl"])) ? $_POST["idseqttl"] : "";
	$inpessoa = (isset($_POST["inpessoa"])) ? $_POST["inpessoa"] : "";
	$nrdrowid = (isset($_POST["nrdrowid"])) ? $_POST["nrdrowid"] : "";	
	$idseqbem = (isset($_POST["idseqbem"])) ? $_POST["idseqbem"] : "";	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : "C";	
	
	// Recebe a operação que está sendo realizada
	$operacao = (isset($_POST["operacao"])) ? $_POST["operacao"] : "";
	
	if ( $operacao == 'CI' ) { 
		include('formulario_bens.php'); 
		?>
		<script type="text/javascript">
			var operacao = '<? echo $operacao; ?>';
			controlaLayout(operacao);
		</script>
		<?php
		exit(); 
	}
	
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl n&atilde;o foi informada.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0056.p</Bo>";
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
	$xml .= "		<nrdrowid>".$nrdrowid."</nrdrowid>";		
	$xml .= "		<idseqbem>".$idseqbem."</idseqbem>";		
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";		
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);	
	$registros = $xmlObjeto->roottag->tags[0]->tags;
	
	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		$metodo = ( $operecao == '' ) ? 'fechaRotina(divRotina);' : 'bloqueiaFundo(divRotina);' ;
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$metodo,false);		
	}	
	
	// Se não retornou erro, então pegar a mensagem de alerta do Progress na variável msgAlert, para ser utilizada posteriormente
	$msgAlert = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) ) ? trim($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) : '';
		
	//Verifico se conta é titular em outra conta. Se atributo vier preenchido, muda operação para 'SC' => Somente Consulta
	$msgConta = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGCONTA']) ) ? trim($xmlObjeto->roottag->tags[0]->attributes['MSGCONTA']) : '';
	if( $msgConta != '' ) {
		$operacao = ( $operacao != 'CF' ) ? 'SC' : $operacao ;
	}
	
	?>
	<script type='text/javascript'>
		$('#divConteudoOpcao').css({'-moz-opacity':'0','filter':'alpha(opacity=0)','opacity':'0'});
	</script>
	<?php
	
	// Se estiver Alterando/Incluindo, chamar o formulario de alteracao
	if(in_array($operacao,array('CI','CA','CX','CF'))) {
		include('formulario_bens.php');
	
	// Se estiver consultando, chamar a tabela que exibe os bens
	} else if(in_array($operacao,array('AC','IC','FI','FA','FE','SC',''))) {
		include('tabela_bens.php');
	}
?>	
<script type="text/javascript">		
	var msgConta = '<? echo $msgConta; ?>';
	var msgAlert = '<? echo $msgAlert; ?>';
	var operacao = '<? echo $operacao; ?>';
	
	if (inpessoa == 1) {
		var flgAlterar  = "<? echo $flgAlterar;  ?>";
		var flgIncluir  = "<? echo $flgIncluir;  ?>";
		var flgExcluir  = "<? echo $flgExcluir;  ?>";
		var flgcadas    = "<? echo $flgcadas;    ?>";
	}
	
	controlaLayout(operacao);
	
	if ( msgConta != '' && operacao == 'SC' ) { 
		showError('inform',msgConta,'Alerta - Ayllos','bloqueiaFundo(divRotina);controlaFoco(\''+operacao+'\');');
	}else if ( msgAlert != '' ){
		showError('inform',msgAlert,'Alerta - Ayllos','bloqueiaFundo(divRotina);controlaFoco(\''+operacao+'\');');
	}else{
		controlaFoco(operacao);
	}
	if ( operacao == 'CX' ){ controlaOperacao('CE'); }
</script>