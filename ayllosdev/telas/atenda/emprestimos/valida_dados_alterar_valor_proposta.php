<? 
/*
 FONTE        : valida_dados_alterar_valor_proposta.php
 CRIAÇÃO      : James Prust Junior
 DATA CRIAÇÃO : 25/01/2016
 OBJETIVO     : Valida os dados da rotina de alteracao do valor da proposta
 --------------
 ALTERAÇÕES   :
 --------------
 */
?>
<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();		
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A')) <> ''){
		exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	}	
	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
	$vlemprst = (isset($_POST['vlemprst'])) ? $_POST['vlemprst'] : 0;
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : 0;
	
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrctremp>".$nrctremp."</nrctremp>";
	$xml .= "   <vlemprst>".str_replace(",",".",str_replace(".","",$vlemprst))."</vlemprst>";
	$xml .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "   <idseqttl>".$idseqttl."</idseqttl>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "EMPR0001", "EMPR001_VALIDA_ALTERACAO_VALOR_PROPOSTA", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);			
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Aimaro','',false);
	}
	
	$nmfuncao = "atualizaArray('V_VALOR');";
	if (getByTagName($xmlObj->roottag->tags[0]->tags,'DSMENSAG') != ""){
		
		$metodo = "bloqueiaFundo(divRotina);";
		// Condicao para verificar se apresenta senha de confirmacao
		if (getByTagName($xmlObj->roottag->tags[0]->tags,'FLGSENHA') == 1){			
			$metodo .= "pedeSenhaCoordenador(2,'".addslashes(addslashes($nmfuncao))."','');";
		}else{
			$metodo .= $nmfuncao;
		}
		exibirErro('inform',getByTagName($xmlObj->roottag->tags[0]->tags,'DSMENSAG'),'Alerta - Aimaro',$metodo,false);		
	}else{
		echo $nmfuncao;
	}	
?>