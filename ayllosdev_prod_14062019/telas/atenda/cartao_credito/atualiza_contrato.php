<?php 

		session_start();
		require_once('../../../includes/config.php');
		require_once('../../../includes/funcoes.php');
		require_once('../../../includes/controla_secao.php');
		require_once('../../../class/xmlfile.php');
		isPostMethod();		
		if(( !isset($_POST['nrctrcrd'])) ||(!isset($_POST['idacionamento'])) ||(!isset($_POST['nrdconta']))){
			echo "showError(\"error\", \"Erro ao atualizar contrato.\", \"Alerta - Aimaro\", \"blockBackground(parseInt($('#divRotina').css('z-index')))\");";
			return;
		}
		
        $funcaoAposErro = 'bloqueiaFundo(divRotina);';
		$nrctrcrd       = $_POST['nrctrcrd'];
		$nrdconta       = $_POST['nrdconta'];
		$idacionamento  =  $_POST['idacionamento'];
		$dsjustif  		=  $_POST['dsjustif'];
		$idproces       = $_POST['idproces'];
		$cdadmcrd       = $_POST['cdadmcrd'];
		//if(!($cdadmcrd == 16 || $cdadmcrd == 17)){
		if(TRUE){
			$updContratoXML .= "<Root>";
			$updContratoXML .= " <Dados>";
			$updContratoXML .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
			$updContratoXML .= "   <nrdconta>".$nrdconta."</nrdconta>";
			$updContratoXML .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
			$updContratoXML .= "   <dsprotoc>".$idacionamento."</dsprotoc>";
			$updContratoXML .= "   <dsjustif>".$dsjustif."</dsjustif>";
			$updContratoXML .= "   <idproces>".$idproces."</idproces>";
			$updContratoXML .= " </Dados>";
			$updContratoXML .= "</Root>";
			$admresult = mensageria($updContratoXML, "ATENDA_CRD",
													"ATUALIZAR_CONTRATO_SUGEST_MOTOR",
													$glbvars["cdcooper"], 
													$glbvars["cdpactra"], 
													$glbvars["nrdcaixa"], 
													$glbvars["idorigem"], 
													$glbvars["cdoperad"], 
													"</Root>");
			
			$procXML = simplexml_load_string($admresult);
			$xmlObject = getObjectXML($admresult);
			if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
				$msg = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;		
				echo "error = true;showError(\"error\", \"$msg.\", \"Alerta - Aimaro\", \"blockBackground(parseInt($('#divRotina').css('z-index')))\");";
				exit();
			}
		}
		else{
			echo '/* cartao de debito nao atualiza*/';
		}
		echo "/*".$admresult."  >". isset($procXML->Erro)."<*/";
        ?>
		
		
