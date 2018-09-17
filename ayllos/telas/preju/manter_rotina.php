<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Jean Calao (Mout´S)
 * DATA CRIAÇÃO : 20/06/2017
 * OBJETIVO     : Rotina para estornar prejuizos
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'E')) <> ''){
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$operacao		 = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$dtprejuz		 = isset($_POST['dtprejuz'])) ? $_POST['dtprejuz'] : '';
	$nrdconta		 = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$nrctremp 		 = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
	
	switch ($operacao){
		
		case 'VALIDA_DADOS':
			$xml  = "<Root>";
			$xml .= " <Dados>";
			$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
			$xml .= "   <nrctremp>".$nrctremp."</nrctremp>";
			$xml .= " </Dados>";
			$xml .= "</Root>";

			$xmlResult = mensageria($xml, "ESTORN", "ESTORN_VALIDA_INC", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			$xmlObj = getObjectXML($xmlResult);			
			if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO"){
				$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
				if ($msgErro == "") {
					$msgErro = $xmlObj->roottag->tags[0]->cdata;
				}
				exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
			}
			
			// Vamos verificar se solicita a senha do coordenador
			if (getByTagName($xmlObj->roottag->tags[0]->tags,'flgsenha') == 1){
				echo "pedeSenhaCoordenador(2,'manterRotina(\'EFETUA_ESTORNO\')','');";				
		    }else{
				echo "manterRotina('EFETUA_ESTORNO');";
			}
		break;
		
		case 'EFETUA_ESTORNO':
			// Monta o xml de requisição
			$xml  = "";
			$xml .= "<Root>";
			$xml .= "	<Cabecalho>";
			$xml .= "		<Bo>b1wgen0084.p</Bo>";
			$xml .= "		<Proc>efetua_estorno_pagamentos_pp</Proc>";
			$xml .= "	</Cabecalho>";
			$xml .= "	<Dados>";
			$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
			$xml .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
			$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
			$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
			$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
			$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
			$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
			$xml .= "		<idseqttl>1</idseqttl>";
			$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
			$xml .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
			$xml .= "		<nrctremp>".$nrctremp."</nrctremp>";
			$xml .= "		<dsjustificativa>".$dsjustificativa."</dsjustificativa>";
			$xml .= "		<inproces>".$glbvars['inproces']."</inproces>";
			$xml .= "	</Dados>";
			$xml .= "</Root>";
			
			$xmlResult = getDataXML($xml);
			$xmlObj    = getObjectXML($xmlResult);
			if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
				exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
			}
			exibirErro('inform','Estorno Realizado com Sucesso!','Alerta - Ayllos',"estadoInicial();",false);
		break;
	}
?>