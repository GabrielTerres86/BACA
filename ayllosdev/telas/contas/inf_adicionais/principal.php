<?php
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : Abril/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de Inf. Adicionais da tela de CONTAS
 *
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1). 
 *                06/08/2015 - Reformulacao Cadastral (Gabriel-RKAM)
 *                14/07/2016 - Correcao no tratamento da msg de retorno XML. SD 479874. Carlos R.
 *
 *                01/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
 *                             pois a BO não utiliza o mesmo (Renato Darosci)
 */	
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '';
	
	$glbvars["nmrotina"] = (isset($_POST['nmrotina'])) ? $_POST['nmrotina'] : $glbvars["nmrotina"];
	
	switch( $operacao ) {
		case 'CA': $op = "A"; break;
		case 'AC': $op = "@"; break;
		case ''  : $op = "@"; break;
		default  : $op = "@"; break;
	}
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$op,false)) <> '') {
		$metodo =  ($flgcadas == 'M') ? 'proximaRotina();' : 'encerraRotina(false);';
		exibirErro('error',$msgError,'Alerta - Aimaro',$metodo,false);
	}
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST['nrdconta']) || !isset($_POST['idseqttl'])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);

	// Carrega permissões do operador
	include("../../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);

	$qtOpcoesTela = count($opcoesTela);

	// Carregas as opções da Rotina de Bens
	$flgAlterar  = (in_array("A", $glbvars["opcoesTela"]));
	
	$nrdconta = $_POST['nrdconta'] == '' ? 0 : $_POST['nrdconta'];
	$idseqttl = $_POST['idseqttl'] == '' ? 0 : $_POST['idseqttl'];
	
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq. Titular n&atilde;o foi informada.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);	
	if ($idseqttl==0) exibirErro('error','Seq. Titular n&atilde;o foi informada.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0048.p</Bo>';
	$xml .= '		<Proc>obtem-informacoes-adicionais</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjFiliacao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjFiliacao->roottag->tags[0]->name) == 'ERRO') exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	
	$infAdicionais = $xmlObjFiliacao->roottag->tags[0]->tags[0]->tags;
	
	$textareaTags = $xmlObjFiliacao->roottag->tags[0]->tags[0]->tags[3]->tags;
	
	// Se não retornou erro, então pegar a mensagem de alerta do Progress na variável msgAlert, para ser utilizada posteriormente
	$msgAlert = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) ) ? trim($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) : '';	
	
	include('formulario_inf_adicionais.php');
?>
<script type='text/javascript'>
	msgAlert = '<? echo $msgAlert; ?>';
	operacao = '<? echo $operacao; ?>';	
	inpessoa = $('#inpessoa','#frmCabContas').val().substring(0,1);
	
	if (inpessoa == 1) {
		var flgAlterar   = "<? echo $flgAlterar;   ?>";
		var flgcadas     = "<? echo $flgcadas;     ?>";
		
		if (flgcadas == 'M' && operacao != 'CA') {
			controlaOperacao('CA');
		}
		
	}
	
	controlaLayout();
	
	if ( msgAlert != '' ) { 
		showError('inform',msgAlert,'Alerta - Aimaro','bloqueiaFundo(divRotina);controlaFoco();');
	}else{
		controlaFoco();
	}
</script>
