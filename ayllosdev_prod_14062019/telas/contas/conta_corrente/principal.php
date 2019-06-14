<?php
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 12/05/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de CONTA CORRENTE da tela de CONTAS 
 *
 * ALTERAÇÕES    : 30/07/2010 - Incluir parametro dtmvtolt (Guilherme).
 *                 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1).
 *                 08/02/2013 - Incluir campo flgrestr em procedure busca_dados (Lucas R.)
 *	         	   05/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
 *                 11/08/2015 - Projeto 218 - Melhorias Tarifas (Carlos Rafael Tanholi).
 *				   02/11/2015 - Melhoria 126 - Encarteiramento de cooperados (Heitor - RKAM)
 *				   14/04/2016 - Correcao no uso do array de opcoestela indefinido. SD 479874. Carlos R.
 *			       15/07/2016 - Incluir rotina para buscar o flg de devolução automatica - Melhoria 69 (Lucas Ranghetti #484923)
 *                 01/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
 *                              pois a BO não utiliza o mesmo (Renato Darosci)
 *				   27/02/2019 - ACELERA - Buscar flag reapresentação automatica de cheque - (Lucas H - SUPERO)
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
	if (!isset($_POST['nrdconta']) || !isset($_POST['idseqttl'])) 
		exibirErro('error','Parâmetros incorretos.','Alerta - Aimaro','fechaRotina(divRotina)');

	// Carrega permissões do operador
	include("../../../includes/carrega_permissoes.php");

	setVarSession("opcoesTela", $opcoesTela);

	$qtOpcoesTela = count($opcoesTela);

	// Carregas as opções da Rotina de Bens
	$flgAlterar  = (in_array('A', $glbvars['opcoesTela']));
	$flgExcluir  = (in_array('E', $glbvars['opcoesTela']));
	$flgEncerrar = (in_array('E', $glbvars['opcoesTela']));
	$flgSolITG   = (in_array('S', $glbvars['opcoesTela']));
	
	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = ($_POST['nrdconta'] == '') ? 0  : $_POST['nrdconta'];
	$idseqttl = ($_POST['idseqttl'] == '') ? 0  : $_POST['idseqttl'];

		
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Aimaro','fechaRotina(divRotina)');
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl não foi informada.','Alerta - Aimaro','fechaRotina(divRotina)');
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0074.p</Bo>';
	$xml .= '		<Proc>busca_dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);

	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);

	// Variável que representa o registro
	$registro = $xmlObj->roottag->tags[0]->tags[0]->tags;

	// Variáveis que representam a visibilidade dos botões
	$btsolitg = getByTagName($registro,'btsolitg');
	$btaltera = getByTagName($registro,'btaltera'); 
	$btencitg = getByTagName($registro,'btencitg');
	$btexcttl = getByTagName($registro,'btexcttl');
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO') exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','fechaRotina(divRotina);');

	// Se não retornou erro, então pegar a mensagem de alerta do Progress na variável msgAlert, para ser utilizada posteriormente
	$msgAlert = ( isset($xmlObj->roottag->tags[0]->attributes['MSGALERT']) ) ? trim($xmlObj->roottag->tags[0]->attributes['MSGALERT']) : '';

	$cdtipcta = getByTagName($registro,'cdtipcta');
	$cdbcoctl = getByTagName($registro,'cdbcoctl');
	$flgrestr = getByTagName($registro,'flgrestr');

	// Melhoria 69
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "FLGDEVOLU_AUTOM", 'VERIFICA_SIT_DEV_XML', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");
	$xmlObjeto1 = getObjectXML($xmlResult);
	
	$flgdevolu_autom = getByTagName($xmlObjeto1->roottag->tags[0]->tags, 'flgdevolu_autom');		
	
	// Melhoria 126
	$nmdeacao = "CADCON_CONSULTA_CONTA";

	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "CADCON", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");

	$xmlObjeto = simplexml_load_string($xmlResult);

	if (isset($xmlObjeto->Erro->Registro->dscritic) && $xmlObjeto->Erro->Registro->dscritic != "") {
		$cdconsul = 0;
		$nmconsul = '';
	}

	foreach($xmlObjeto->conta as $conta){
		if ($nrdconta == $conta->nrdconta) {
			$cdconsul = $conta->cdconsul;
			$nmconsul = $conta->nmoperad;
		}
	}

	//Fim Melhoria 126
	
	//ACELERA - Flag reapresentação automatica de cheque
	$nmdeacao = "BUSCA_REAPRE_CHEQUE";
	
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "CONTAS", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");
	$xmlObjeto1 = getObjectXML($xmlResult);
	
	$flgreapre = getByTagName($xmlObjeto1->roottag->tags[0]->tags, 'flgreapre');
	
	//FIM ACELERA - Flag reapresentação automatica de cheque
	
	include('formulario_conta_corrente.php');
?>
<script type="text/javascript">
	var msgAlert   = '<? echo $msgAlert; ?>';
	var operacao   = '<? echo $operacao; ?>';
	var flgdevolu_autom = '<? echo $flgdevolu_autom; ?>';
	var flgreapre = '<? echo flgreapre; ?>';

	cdtipcta = '<? echo $cdtipcta ?>';
	cdbcoctl = '<? echo $cdbcoctl ?>';

	//Guarda a informacao da agencia original da conta
	var cdageant = '<? echo getByTagName($registro,'cdagepac'); ?>';
	
	var flgrestr = '<? echo $flgrestr; ?>';
	var nvoperad = '<? echo $glbvars['nvoperad']; ?>';

	controlaLayout(operacao);

	if (inpessoa == 1) {
		var flgAlterar  = '<? echo $flgAlterar;  ?>';
		var flgExcluir  = '<? echo $flgExcluir;  ?>';
		var flgEncerrar = '<? echo $flgEncerrar; ?>';
		var flgSolITG   = '<? echo $flgSolITG;   ?>';
		var flgcadas    = '<? echo $flgcadas;    ?>';

	    if (flgcadas == 'M' && operacao != 'CA') {
			controlaOperacao('CA');
		}
	}

	if ( msgAlert != '' ) {
		showError('inform',msgAlert,'Alerta - Aimaro','bloqueiaFundo(divRotina);controlaFoco(operacao);');
	} else {
		controlaFoco(operacao);
	}

	if ( operacao == 'ET' ) {
		mostraTabelaTitulares('TS'); 
	}
</script>