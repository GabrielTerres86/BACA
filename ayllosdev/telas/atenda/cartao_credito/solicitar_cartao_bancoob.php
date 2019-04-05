<?php 

		session_start();
		require_once('../../../includes/config.php');
		require_once('../../../includes/funcoes.php');
		require_once('../../../includes/controla_secao.php');
		require_once('../../../class/xmlfile.php');
		isPostMethod();		
		if((!isset($_POST['nrdconta'])) || ( !isset($_POST['nrctrcrd']))){
			echo "showError(\"error\", \"Erro ao enviar proposta ao bancoob.\", \"Alerta - Aimaro\", \"blockBackground(parseInt($('#divRotina').css('z-index')))\");";
			return;
		}
		$nrdconta   = $_POST['nrdconta'];
		$nrctrcrd   = $_POST['nrctrcrd'];
		$tpacao     = $_POST['tpacao'];
		$inpessoa   = $_POST['inpessoa'];
		

		$funcaoAposErro = 'bloqueiaFundo(divRotina);';	
		if($tpacao == "montagrid"){
			
			$dsgraupr = $_POST['dsgraupr'];
			$bancoob   = $_POST['bancoob'];
			$glbadc     = $_POST['glbadc'];//parâmetro para  verificar se é cartão adicional
			$erro = false;
			
			if((($dsgraupr == 5 || $dsgraupr == "Primeiro Titular") && $inpessoa ==1) || ($inpessoa == 2 && $glbadc == 'n')){
				$bancoobXML .= "<Root>";
				$bancoobXML .= " <Dados>";
				$bancoobXML .= "   <nrdconta>".$nrdconta."</nrdconta>";
				$bancoobXML .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
				$bancoobXML .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
				$bancoobXML .= " </Dados>";
				$bancoobXML .= "</Root>";
				if($bancoob  == 2){
					$admresult = mensageria($bancoobXML, "ATENDA_CRD", "INCLUIR_PROPOSTA_ESTEIRA", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
					$procXML = simplexml_load_string($admresult);
					echo "showError(\"inform\", \"".utf8ToHtml("Solicitação enviada para esteira com sucesso.")."\", \"Alerta - Aimaro\", \"alertarCooperado('novo');voltarParaTelaPrincipal();\");";
					echo "/* Encaminhado para a esteira \n $bancoobXML \n Retorno \n $admresult */";
				}else{
					$admresult = mensageria($bancoobXML, "CCRD0007", "SOLICITAR_CARTAO_BANCOOB", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
					$procXML = simplexml_load_string($admresult);
					echo "/* Encaminhado direto para o motor \n $bancoobXML \n Retorno\n \n $admresult \n*/";

				}
				//echo "/*".$bancoobXML."*/";
			
			}else{
				echo "/* Segundo titular - Adicional*/";
			}
			if($procXML->Erro)
			{			
				foreach($procXML->Erro->Registro->dscritic as $key => $value){
					$erro = $value;
					break;
				}			
			}
			if($erro){
				echo "showError(\"error\", \"".preg_replace( "/\r|\n/", " ", addslashes(utf8ToHtml(str_replace("ã","&atilde;",$erro) )))."\", \"Alerta - Aimaro\", \"voltarParaTelaPrincipal();\");";
				?>
					$("#emiteTermoBTN").attr("nrctrcrd","<? echo $nrctrcrd;?>");
					$("#emiteTermoBTN").click();
					voltarParaTelaPrincipal();
				<?
			}
			else{
				if(true){
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

			if(!isset($_POST['vlnovlim'])){
				echo "showError(\"error\", \"Erro ao enviar proposta ao bancoob. Novo limite não informado.\", \"Alerta - Aimaro\", \"blockBackground(parseInt($('#divRotina').css('z-index')))\");";
				return;
			}
			
			$titular  = $_POST['titular'];
			$vlnovlim = $_POST['vlnovlim'];
			$sugestao = $_POST['vlsugmot'];
			$titular  = $_POST['titular'];
			$vllimmin = $_POST['vllimmin'];
			$vllimmax = $_POST['vllimmax'];
			$tipo     = $_POST['tipo'];
			$cdadmcrd = $_POST['cdadmcrd'];
			$justificativa   = $_POST['justificativa'];
			$protocolo       = $_POST['protocolo'];
			$vlLimiteMaximo  = $_POST['vlLimiteMaximo'];
			$limiteatualCC   = $_POST['limiteatualCC'];
			
			if($titular == 'n'){
				$idseqttl = 0;
			}else
				$idseqttl = 1;
			$insitdec;
			if($titular == 'n' && $inpessoa == 1){
				$insitdec = 2;
			}else if(( $vlnovlim > $vllimmin ) && ( $vlnovlim < $sugestao)){
				$insitdec = 2;
			}else{
				$insitdec = 1;
			}
			$hasError = false;
			// validação permitir para os cartões adicionais
	
			$bancoobXML  = "<Root>";
			$bancoobXML .= " <Dados>";
			$bancoobXML .= "   <nrdconta>".$nrdconta."</nrdconta>";
			$bancoobXML .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
			$bancoobXML .= "   <vllimite>".$vlnovlim."</vllimite>";
			$bancoobXML .= "   <idseqttl >".$idseqttl."</idseqttl>";
			$bancoobXML .= " </Dados>";
			$bancoobXML .= "</Root>";

			
			$logXML  = "<Root>";
			$logXML .= " <Dados>";
			$logXML .= "   <nrdconta>".$nrdconta."</nrdconta>";
			$logXML .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
			$logXML .= "   <vllimite>".$vlnovlim."</vllimite>";
			$logXML .= "   <dsprotoc>".$protocolo."</dsprotoc >";
			$logXML .= "   <dsjustif>".$justificativa."</dsjustif>";
			$logXML .= "   <flgtplim>".$tipo."</flgtplim>";
			$logXML .= "   <tpsituac>6</tpsituac  >";
			$logXML .= "   <insitdec>".$insitdec."</insitdec  >";
			$logXML .= " </Dados>";
			$logXML .= "</Root>";
			$logResult = mensageria($logXML, "ATENDA_CRD", "ALTERAR_LIMITE_CRD", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			$OlogXML = simplexml_load_string($logResult);
			
			$bancoob = true;
			if(isset($OlogXML->Erro)){
				
				$hasError  = true;
				$errorMsg  = $OlogXML->Erro->Registro->dscritic;
				$errorCod  = $OlogXML->Erro->Registro->cdcritic;
				echo "/* acao: ALTERAR_LIMITE_CRD \n  enviado:\n $logXML \n Recebido \n    $logResult \n */ \n";
						
			}

			if(!$hasError){
			//if(true){
				if($titular == 'n' /* && $inpessoa == 1 */){
					//todo: ALTERAR_CARTAO_BANCOOB
					$admresult = mensageria($bancoobXML, "CCRD0007", "ALTERAR_CARTAO_BANCOOB", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
					$procXML = simplexml_load_string($admresult);
					if(isset($procXML->Erro)){
				
						$hasError  = true;
						$errorMsg  = $procXML->Erro->Registro->dscritic." ";
						$errorCod  = $procXML->Erro->Registro->cdcritic;
						echo "/* acao: outro ALTERAR_CARTAO_BANCOOB \n enviado:\n $bancoobXML \n Recebido \n    $admresult \n */ \n";
						
					}else
						echo "/* Encaminhado direto para o bancoob (Adicional e  PF)*/";
				}else if((/*( !($cdadmcrd == 12 && $vlnovlim == 0)  ) &&*/ ( $vlnovlim <= $sugestao))   ){
					// todo : ALTERAR_CARTAO_BANCOOB
					$admresult = mensageria($bancoobXML, "CCRD0007", "ALTERAR_CARTAO_BANCOOB", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
					$procXML = simplexml_load_string($admresult);
					if(isset($procXML->Erro)){
							
						$hasError  = true;
						$errorMsg  = $procXML->Erro->Registro->dscritic."";
						$errorCod  = $procXML->Erro->Registro->cdcritic;
						echo "/*acao: aqui ALTERAR_CARTAO_BANCOOB \n enviado:\n $bancoobXML \n Recebido \n    $admresult \n */ \n";
						
					}else
						echo "/* Encaminhado direto para o bancoob sugestão entre sugestão minima e sugestão máxima */";
				}else{

					$bancoobXML  = "<Root>";
					$bancoobXML .= " <Dados>";
					$bancoobXML .= "   <nrdconta>".$nrdconta."</nrdconta>";
					$bancoobXML .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
					$bancoobXML .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
					$bancoobXML .= " </Dados>";
					$bancoobXML .= "</Root>";
					$bancoob = false;
					$admresult = mensageria($bancoobXML, "ATENDA_CRD", "INCLUIR_PROPOSTA_ESTEIRA", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
					$procXML = simplexml_load_string($admresult);
					if(isset($procXML->Erro)){
				
						$hasError  = true;
						$errorMsg  = $procXML->Erro->Registro->dscritic."";
						$errorCod  = $procXML->Erro->Registro->cdcritic;
						echo "/*acao: INCLUIR_PROPOSTA_ESTEIRA \n enviado:\n $bancoobXML \n Recebido \n    $admresult \n */ \n";
						
					}else	
						echo "/* enviado para esteira  */";
				}
				if($inpessoa == 2 && $tipo=='G'){
					$validaXML  = "<Root>";
					$validaXML .= " <Dados>";
					$validaXML .= "   <nrdconta>".$nrdconta."</nrdconta>";
					$validaXML .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
					//$validaXML .= "   <cdcooper>".$glbvars["dtmvtolt"]."</cdcooper>";
					$validaXML .= " </Dados>";
					$validaXML .= "</Root>";

					$validaresult = mensageria($validaXML, "ATENDA_CRD", "VALIDAR_LIMITE_DIFERENCIADO", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
					$procXML = simplexml_load_string($validaresult);
					if(isset($procXML->Erro)){
				
						$hasError  = true;
						$errorMsg  = $procXML->Erro->Registro->dscritic."";
						$errorCod  = $procXML->Erro->Registro->cdcritic;
						echo "/*acao: VALIDAR_LIMITE_DIFERENCIADO \n enviado:\n $validaXML \n Recebido \n    $validaresult \n */ \n";
						
					}else{
						if($procXML->Dados->inf->limiteDifer != "N"){
							?>
							showError("alert", "<? echo utf8ToHtml("A conta possui cartões com limites diferenciados."); ?>", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
							<?
						}
					}
				}
				?>
					voltaDiv(0, 1, 4);
				<?
			}
			if($hasError){
				?>
				
				showError("error", "<? echo utf8ToHtml( preg_replace( "/\r|\n/", "", addslashes ($errorMsg))); ?>", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
				<?
			}else{
				if($bancoob){
					?>
					showError("inform", "<? echo utf8ToHtml( "Alteração Efetuada com Sucesso."); ?>", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')));alertarCooperado('novo');");
					<?
				}else{
					?>
					showError("inform", "<? echo utf8ToHtml( "Alteração enviada para esteira com sucesso."); ?>", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')));alertarCooperado('novo');");
					<?
				}
				
			}
		}
		
?>