<?php 

		session_start();
		require_once('../../../includes/config.php');
		require_once('../../../includes/funcoes.php');
		require_once('../../../includes/controla_secao.php');
		require_once('../../../class/xmlfile.php');
		isPostMethod();		
		if((!isset($_POST['nrdconta'])) || ( !isset($_POST['nrctrcrd']))){
			echo "showError(\"error\", \"Erro ao buscar retorno do bancoob.\", \"Alerta - Aimaro\", \"blockBackground(parseInt($('#divRotina').css('z-index')))\");";
			return;
		}
		$nrdconta = $_POST['nrdconta'];
		$nrctrcrd = $_POST['nrctrcrd'];
		$dssituac = $_POST['dssituac'];		
		$funcaoAposErro = 'bloqueiaFundo(divRotina);';	
			
		$bancoobXML .= "<Root>";
		$bancoobXML .= " <Dados>";
		$bancoobXML .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$bancoobXML .= "   <nrdconta>".$nrdconta."</nrdconta>";
		$bancoobXML .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
		$bancoobXML .= " </Dados>";
		$bancoobXML .= "</Root>";
		echo "/* \n envio \n $bancoobXML \n */";
		$admresult = mensageria($bancoobXML, "CCRD0007", "RETORNO_WS_CARTAO_BANCOOB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$procXML = simplexml_load_string($admresult);

		echo "/* \n ".$admresult." \n*/";
		$erro = false;
		if($procXML->Erro)
		{			
			foreach($procXML->Erro->Registro->dscritic as $key => $value){
				$erro = $value;
				break;
			}
		}
		if($erro)
			echo "showError(\"error\", \"".preg_replace( "/\r|\n/", " ", addslashes(utf8ToHtml(str_replace("ã","&atilde;",$erro) )))."\", \"Alerta - Aimaro\", \"\");";
		else{
			echo "nrctrcrd =  $nrctrcrd;";
			echo "dssituac =  '$dssituac';";
			echo "showError(\"error\", \"".utf8ToHtml(str_replace("Ã£",'a', $procXML->Dados->inf->mensagem))."\", \"Alerta - Ayllos\", \" carregaHistorico(0,$nrctrcrd);\");";
			?>	
				//$("#emiteTermoBTN").attr("nrctrcrd","<? echo $nrctrcrd;?>");
				//$("#emiteTermoBTN").click();
				//voltarParaTelaPrincipal();
				/*
					<?
						echo $admresult;
					?>
				*/
			<?
		}
		
?>