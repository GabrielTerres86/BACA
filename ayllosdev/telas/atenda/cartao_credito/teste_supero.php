<?php
		session_start();
		require_once('../../../includes/config.php');
		require_once('../../../includes/funcoes.php');
		require_once('../../../includes/controla_secao.php');
		require_once('../../../class/xmlfile.php');
		isPostMethod();	
		$nrdconta = $_POST["nrdconta"];
		$nrctrcrd = $_POST["nrctrcrd"];
		
		
		
		$bancoobXML .= "<Root>";
		$bancoobXML .= " <Dados>";
		$bancoobXML .= "   <nrdconta>".$nrdconta."</nrdconta>";
		$bancoobXML .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
		$bancoobXML .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$bancoobXML .= "   <des_mensagem>".$nrdconta."</des_mensagem>";
		$bancoobXML .= " </Dados>";
		$bancoobXML .= "</Root>";
		$admresult = mensageria($bancoobXML, "CCRD0007", "SOLICITAR_CARTAO_BANCOOB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$procXML = simplexml_load_string($admresult);
		
		$erro = false;
		if($procXML->Erro)
		{
			
			foreach($procXML->Erro->Registro->dscritic as $key => $value){
				$erro = $value;
				break;
			}
			
		}
		if($erro)
			echo "showError(\"error\", \"".utf8ToHtml($erro)."\", \"Alerta - Ayllos\", \"blockBackground(parseInt($('#divRotina').css('z-index')))\");";

?>