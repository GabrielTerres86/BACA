<?php 

		session_start();
		require_once('../../../includes/config.php');
		require_once('../../../includes/funcoes.php');
		require_once('../../../includes/controla_secao.php');
		require_once('../../../class/xmlfile.php');
		isPostMethod();		
		if((!isset($_POST['nrdconta'])) || ( !isset($_POST['nrctrcrd']))){
			echo "showError(\"error\", \"Erro ao enviar proposta ao bancoob.\", \"Alerta - Ayllos\", \"blockBackground(parseInt($('#divRotina').css('z-index')))\");";
			return;
		}
		$nrdconta = $_POST['nrdconta'];
		$nrctrcrd = $_POST['nrctrcrd'];
		$tpacao   = $_POST['tpacao'];
		$inpessoa   = $_POST['inpessoa'];
		
		$funcaoAposErro = 'bloqueiaFundo(divRotina);';	
		if($tpacao == "montagrid"){
			
			$dsgraupr = $_POST['dsgraupr'];
			$bancoob   = $_POST['bancoob'];
			$erro = false;
			
			if(($dsgraupr == 5 && $inpessoa ==1) || ($inpessoa == 2)){
				$bancoobXML .= "<Root>";
				$bancoobXML .= " <Dados>";
				$bancoobXML .= "   <nrdconta>".$nrdconta."</nrdconta>";
				$bancoobXML .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
				$bancoobXML .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
				$bancoobXML .= " </Dados>";
				$bancoobXML .= "</Root>";
				if($bancoob  == 2){
					$admresult = mensageria($bancoobXML, "ATENDA_CRD", "INCLUIR_PROPOSTA_ESTEIRA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
					$procXML = simplexml_load_string($admresult);
					echo "/* Encaminhado para a esteira  $bancoobXML */";
				}else{
					$admresult = mensageria($bancoobXML, "CCRD0007", "SOLICITAR_CARTAO_BANCOOB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
					$procXML = simplexml_load_string($admresult);
					echo "/* Encaminhado direto para o motor */";
				}
				//echo "/*".$bancoobXML."*/";
			
			}else{
				echo "/* Segundo titular */";
			}
			if($procXML->Erro)
			{			
				foreach($procXML->Erro->Registro->dscritic as $key => $value){
					$erro = $value;
					break;
				}			
			}
			if($erro)
				echo "showError(\"error\", \"".preg_replace( "/\r|\n/", " ", addslashes(utf8ToHtml(str_replace("ã","&atilde;",$erro) )))."\", \"Alerta - Ayllos\", \"voltaDiv(0, 1, 4);\");";
			else{
				if($bancoob == 1){
				?>	
					$("#emiteTermoBTN").attr("nrctrcrd","<? echo $nrctrcrd;?>");
					$("#emiteTermoBTN").click();
					voltarParaTelaPrincipal();
					/*
						<?
							echo $admresult;
						?>
					*/
				<?
				}else{
					echo "voltarParaTelaPrincipal();";
				}
			}
		}else if($tpacao =="alterar"){

			if(!isset($_POST['vlsugmot'])){
				echo "showError(\"error\", \"Erro ao enviar proposta ao bancoob. Novo limite não informado.\", \"Alerta - Ayllos\", \"blockBackground(parseInt($('#divRotina').css('z-index')))\");";
				return;
			}
			if($_POST['autorizado'] =='false'){
				$xml = "<Root>";
				$xml .= " <Dados>";
				$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
				$xml .= " </Dados>";
				$xml .= "</Root>";
				$result = mensageria($xml, "ATENDA_CRD", "VERIFICA_CARTOES_ADICIONAIS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
				$objResult = simplexml_load_string($result);
				//echo "/* $result */ ";
				if(count($objResult->Dados->cartoes->cartao) > 0){
			?>
				showConfirmacao('<? echo utf8ToHtml("Ao alterar o limite, o mesmo será replicado para os cartões adicionais.");?>', 'Confirma&ccedil;&atilde;o - Ayllos', 'alterarBancoob(true)', metodoBlock, 'sim.gif', 'nao.gif');
			<?
				return;
				}
			}
			$bancoobXML = "<Root>";
			$bancoobXML .= " <Dados>";
			$bancoobXML .= "   <nrdconta>".$nrdconta."</nrdconta>";
			$bancoobXML .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
			$bancoobXML .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
			$bancoobXML .= " </Dados>";
			$bancoobXML .= "</Root>";
			//echo $bancoobXML;
			//TODO implementar chamada para procedure de alteração de limite
			$admresult = mensageria($bancoobXML, "ATENDA_CRD", "INCLUIR_PROPOSTA_ESTEIRA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			$procXML = simplexml_load_string($admresult);
			echo "/* $bancoobXML */";
			?>
				voltaDiv(0, 1, 4);
			<?
		}
		
?>