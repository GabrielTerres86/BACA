<?php 
/*!
 * FONTE         : principal.php
 * CRIAÇÃO       : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO  : 05/05/2010 
 * OBJETIVO      : Mostrar opcao Principal da rotina de Impressões da tela de CONTAS
 *
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1). 
 * ALTERACOES   : 23/07/2013 - Inclusão da opção de Cartão Assinatura (Jean Michel).
 *                02/09/2015 - Projeto Reformulacao cadastral. (Tiago Castro - RKAM)
 *                14/07/2016 - Correcao na forma de recuperacao de informacoes do XML. SD 479874. Carlos R.
 *
 *                01/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
 *                             pois a BO não utiliza o mesmo (Renato Darosci)
 * 				        03/10/2017 - Projeto 410 - RF 52 / 62 - Tela impressão declaração optante simples nacional (Diogo - Mouts)
 */
 
	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");	
	require_once("../../../class/xmlfile.php");
	isPostMethod();		
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") exibirErro('error',$msgError,'Alerta - Ayllos','fechaRotina(divRotina)');
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','bloqueiaFundo(divRotina)');

	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = $_POST["nrdconta"] == "" ?  0  : $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"] == "" ?  0  : $_POST["idseqttl"];
	$inpessoa = $_POST["inpessoa"] == "" ?  0  : $_POST["inpessoa"];
	$tpregtrb = $_POST["tpregtrb"] == "" ?  0  : $_POST["tpregtrb"];

	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl n&atilde;o foi informada.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0063.p</Bo>";
	$xml .= "		<Proc>busca_tprelatorio</Proc>";
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
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjImp = getObjectXML($xmlResult);
	
	//Busca se deve mostrar o botão para impressão da declaração de isenção de IOF
	$xml = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>' . $glbvars['cdcooper'] . '</cdcooper>';
	$xml .= '		<nrdconta>' . $nrdconta . '</nrdconta>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "CONTAS", "CONS_DEC_PJ_COOPER", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	// Cria objeto para classe de tratamento de XML
	$xmlObjDados = getObjectXML($xmlResult);
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error', $msg, 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)', false);
	}
	$pessoaJuridicaCooperativa = $xmlObjDados->roottag->tags[0]->cdata;
?>

<div id="divImpressoes">	
	<div id="completo">Completo</div>
	<div id="ficha_cadastral">Ficha Cadastral</div>
	<div id="abertura">Abertura</div>
	<div id="financeiro">Financeiro</div>
	<? if ($inpessoa == 1) { ?>
	<div id="declaracao_pep">Declara&ccedil;&atilde;o PEP</div>
	<? } ?>
	<div id="cartao_assinatura">Cart&atilde;o Assinatura</div>
    <? if ($tpregtrb == 1) { ?>
        <div id="declaracao_optante_simples_nacional">Declara&ccedil;&atilde;o de Optante Simples Nacional</div>
    <? } ?>
    <? if ($pessoaJuridicaCooperativa == 'S') { ?>
        <div id="declaracao_pj_cooperativa">Declara&ccedil;&atilde;o de pessoa jur&iacute;dica cooperativa</div>
    <? } ?>
	<div id="btVoltar" onClick="fechaRotina(divRotina);return false;">Cancelar</div>
	<input type="hidden" id="inpessoa" name="inpessoa" value="<?echo $inpessoa;?>" />
</div>

<script type="text/javascript">		
	
	var relatorios = new Object();
	
	<? for($i = 0; $i <= 8; $i++ ){ ?>
		
	 var relatorio = new Object();	 
		 relatorio['msg']  = '<?php echo ( isset($xmlObjImp->roottag->tags[0]->tags[$i]->tags[1]->cdata) ) ? $xmlObjImp->roottag->tags[0]->tags[$i]->tags[1]->cdata : '';?>';
		 relatorio['flag'] = '<?php echo ( isset($xmlObjImp->roottag->tags[0]->tags[$i]->tags[2]->cdata) ) ? $xmlObjImp->roottag->tags[0]->tags[$i]->tags[2]->cdata : '';?>';
		
		 relatorios['<?php echo ( isset($xmlObjImp->roottag->tags[0]->tags[$i]->tags[0]->cdata) ) ? strtolower(str_replace(' ','_',trim($xmlObjImp->roottag->tags[0]->tags[$i]->tags[0]->cdata))) : '';?>'] = relatorio;
		
	<?}?>
	var inpessoa = "<?php echo $inpessoa; ?>";	
	
	controlaLayout(inpessoa);
</script>
