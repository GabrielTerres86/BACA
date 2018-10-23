<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : 14/09/2015
 * OBJETIVO     : Rotina para estornar os pagamentos
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 *				  17/06/2016 - M181 - Alterar o CDAGENCI para passar o CDPACTRA (Rafael Maciel - RKAM)
 *				  28/08/2018 - Tratar o estorno de pagamento da C/C em prejuízo 
 *				  		       PJ 450 - Diego Simas - AMcom
 *
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	$operacao		 = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$nrdconta		 = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$nrctremp 		 = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
	$qtdlacto 		 = (isset($_POST['qtdlacto'])) ? $_POST['qtdlacto'] : 0;
	$totalest        = (isset($_POST['totalest'])) ? $_POST['totalest'] : 0;
	$dsjustificativa = (isset($_POST['dsjustificativa'])) ? $_POST['dsjustificativa'] : '';
    
    if ($operacao == 'ESTORNO_CT') {
        if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'ECT')) <> ''){
            exibirErro('error',$msgError,'Alerta - Ayllos','',false);
        }        
    }else {
        if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'E')) <> ''){
            exibirErro('error',$msgError,'Alerta - Ayllos','',false);
        }
    }
	
	switch ($operacao){
		
		case 'VALIDA_DADOS':
			$xml  = "<Root>";
			$xml .= " <Dados>";
			$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
			$xml .= "   <nrctremp>".$nrctremp."</nrctremp>";
			$xml .= "   <qtdlacto>".$qtdlacto."</qtdlacto>";
			$xml .= "   <dsjustificativa>".$dsjustificativa."</dsjustificativa>";
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
			// Empréstimo/Financiamento
			// $xml .= "		<cdorigem>3</cdorigem>";
			$xml .= "	</Dados>";
			$xml .= "</Root>";
			
			$xmlResult = getDataXML($xml);
			$xmlObj    = getObjectXML($xmlResult);
			if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
				exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
			}
			exibirErro('inform','Estorno Realizado com Sucesso!','Alerta - Ayllos',"estadoInicial();",false);
			break;

		case 'ESTORNO_CT':
			//Mensageria referente ao estorno do prejuízo da Conta Corrente
			$xml  = "";
			$xml .= "<Root>";
			$xml .= "  <Dados>";
			$xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
			$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
		    $xml .= "    <totalest>".str_replace(",",".",$totalest)."</totalest>";			
			$xml .= "    <justific>".$dsjustificativa."</justific>";
			// Prejuízo de CC
			// $xml .= "		<cdorigem>1</cdorigem>";			
			$xml .= "  </Dados>";
			$xml .= "</Root>";

			$xmlResult = mensageria($xml, "PREJ0003", "ESTORNA_PREJU_CC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");		
			$xmlObjeto = getObjectXML($xmlResult);	

			$param = $xmlObjeto->roottag->tags[0]->tags[0];

			if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
				exibirErro('error',utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata),'Alerta - Ayllos',"controlaOperacao('');",false); 
			}
			exibirErro('inform','Estorno Realizado com Sucesso!','Alerta - Ayllos',"estadoInicial();",false);
		break;
	}
?>