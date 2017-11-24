<?php
	/*!
	 * FONTE        : carrega_layout.php
	 * DATA CRIAÇÃO : 11/09/2017
	 * OBJETIVO     : Arquivo para carregar layouts das telas
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
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script>';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));hideMsgAguardo();");';
		echo '</script>';
		exit();
	}
	
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$cdorigem_mensagem = (isset($_POST['cdorigem_mensagem'])) ? $_POST['cdorigem_mensagem'] : 0;
	$cdmotivo_mensagem = (isset($_POST['cdmotivo_mensagem'])) ? $_POST['cdmotivo_mensagem'] : 0;
	$cdmensagem = (isset($_POST['cdmensagem'])) ? $_POST['cdmensagem'] : 0;
	
	if($cddopcao == "A"){
		include 'form_origem_motivo.php';
	}else if($cddopcao == "C"){
		include 'consultar_notificacoes.php';
	}else if($cddopcao == "CM"){
		$xml  = '';
		$xml .= '<Root><Dados>';
		$xml .= '<cdcooper>0</cdcooper>';
		$xml .= '<flgativo>1</flgativo>';
		$xml .= '</Dados></Root>';

		// Enviar XML de ida e receber String XML de resposta
		$xmlResultCooper = mensageria($xml, 'CADA0001','LISTA_COOPERATIVAS', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjetoCooper = getObjectXML($xmlResultCooper);

		// Se ocorrer um erro, mostra crítica
		if (isset($xmlObjetoCooper->roottag->tags[0]->name) && strtoupper($xmlObjetoCooper->roottag->tags[0]->name) == "ERRO") {
			exibeErro($xmlObjetoCooper->roottag->tags[0]->tags[0]->tags[4]->cdata);
			die();
		}
		
		$msgCooper = $xmlObjetoCooper->roottag->tags[0]->tags;
				
		$xml  = '';
		$xml .= '<Root><Dados>';
		$xml .= '<cdmensagem>'.$cdmensagem.'</cdmensagem>';
		$xml .= '</Dados></Root>';

		// Enviar XML de ida e receber String XML de resposta
		$xmlResultMsgCons = mensageria($xml, 'TELA_ENVNOT','MSG_MANUAL', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjetoMsgCons = getObjectXML($xmlResultMsgCons);

		// Se ocorrer um erro, mostra crítica
		if (isset($xmlObjetoMsgCons->roottag->tags[0]->name) && strtoupper($xmlObjetoMsgCons->roottag->tags[0]->name) == "ERRO") {
			exibeErro($xmlObjetoMsgCons->roottag->tags[0]->tags[0]->tags[4]->cdata);
			die();
		}
		
		$msgCons = $xmlObjetoMsgCons->roottag->tags[0]->tags[1]->tags;
		
		$dstitulo_mensagem = getByTagName($msgCons,'DSTITULO_MENSAGEM');
		$dstexto_mensagem = trim(getByTagName($msgCons,'DSTEXTO_MENSAGEM'));
		$cdicone = getByTagName($msgCons,'CDICONE');
		$inenviar_push = getByTagName($msgCons,'INENVIAR_PUSH');
		$inexibir_banner = (getByTagName($msgCons,'INEXIBIR_BANNER') == 1) ? " checked " : "";
		$nmimagem_banner = getByTagName($msgCons,'NMIMAGEM_BANNER');
		$urlimagem_banner = getByTagName($msgCons,'URLIMAGEM_BANNER');
		$dshtml_mensagem = getByTagName($msgCons,'DSHTML_MENSAGEM');
		$dsvariaveis_mensagem = getByTagName($msgCons,'DSVARIAVEIS_MENSAGEM');
		$inexibe_botao_acao_mobile = (getByTagName($msgCons,'INEXIBE_BOTAO_ACAO_MOBILE') == 1) ? " checked " : "";
		$dstexto_botao_acao_mobile = getByTagName($msgCons,'DSTEXTO_BOTAO_ACAO_MOBILE');
		$idacao_botao_acao_mobile = getByTagName($msgCons,'IDACAO_BOTAO_ACAO_MOBILE');	
		$cdmenu_acao_mobile = getByTagName($msgCons,'CDMENU_ACAO_MOBILE');
		$inmensagem_ativa = getByTagName($msgCons,'INMENSAGEM_ATIVA');
		$chk_dsmensagem_acao_mobile = (trim(getByTagName($msgCons,'DSMENSAGEM_ACAO_MOBILE') != "")) ? " checked " : "";
		$dslink_acao_mobile = getByTagName($msgCons,'DSLINK_ACAO_MOBILE');
		$dsmensagem_acao_mobile = getByTagName($msgCons,'DSMENSAGEM_ACAO_MOBILE');
		$cdtipo_mensagem = getByTagName($msgCons,'CDTIPO_MENSAGEM');
		$intipo_repeticao = getByTagName($msgCons,'INTIPO_REPETICAO');
		$nrdias_semana = getByTagName($msgCons,'NRDIAS_SEMANA');
		$nrsemanas_repeticao = getByTagName($msgCons,'NRSEMANAS_REPETICAO');
		$nrdias_mes = getByTagName($msgCons,'NRDIAS_MES');
		$nrmeses_repeticao = getByTagName($msgCons,'NRMESES_REPETICAO');
		$dsurl_sevidor_imagem = getByTagName($msgCons,'DSURL_SEVIDOR_IMAGEM');
		$cdsituacao_mensagem = getByTagName($msgCons,'CDSITUACAO_MENSAGEM');
		$dtenvio_mensagem = getByTagName($msgCons,'DTENVIO_MENSAGEM');
		$hrenvio_mensagem = getByTagName($msgCons,'HRENVIO_MENSAGEM');
								
		$tpfiltro = getByTagName($msgCons,'TPFILTRO');
		$dsfiltro_cooperativas = getByTagName($msgCons,'DSFILTRO_COOPERATIVAS');
    
		$dsfiltro_tipos_conta = getByTagName($msgCons,'DSFILTRO_TIPOS_CONTA');
		$arrDsFiltro = explode(",",$dsfiltro_tipos_conta);
		if(count($arrDsFiltro) == 2){
			$dsfiltro_tipos_conta_fis = (isset($arrDsFiltro[0]) && $arrDsFiltro[0] == 1) ? " checked" : "";
			$dsfiltro_tipos_conta_jur = (isset($arrDsFiltro[1]) && $arrDsFiltro[0] == 2) ? " checked" : "";
		}else{
			if($arrDsFiltro[0] == 1){
				$dsfiltro_tipos_conta_fis = " checked";	
			}else if($arrDsFiltro[0] == 2){
				$dsfiltro_tipos_conta_jur = " checked";	
			}
		}	
		
		$tpfiltro_mobile = getByTagName($msgCons,'TPFILTRO_MOBILE');
				
		echo "<form enctype=\"multipart/form-data\" id=\"frmMsgConsulta\" name=\"frmMsgConsulta\" class=\"formulario condensado\" method=\"post\" action=\"upload_consulta.php\">";
			echo "<input type=\"hidden\" name=\"cdcooper\" id=\"cdcooper\" value=\"".$glbvars["cdcooper"]."\" />";
			echo "<input type=\"hidden\" name=\"cdagenci\" id=\"cdagenci\" value=\"".$glbvars["cdagenci"]."\" />";
			echo "<input type=\"hidden\" name=\"nrdcaixa\" id=\"nrdcaixa\" value=\"".$glbvars["nrdcaixa"]."\" />";
			echo "<input type=\"hidden\" name=\"idorigem\" id=\"idorigem\" value=\"".$glbvars["idorigem"]."\" />";
			echo "<input type=\"hidden\" name=\"cdoperad\" id=\"cdoperad\" value=\"".$glbvars["cdoperad"]."\" />";
			echo "<input type=\"hidden\" name=\"hdnCdmensagem\" id=\"hdnCdmensagem\" value=\"".$cdmensagem."\" />";
			echo "<div style=\"padding-top:20px; text-align: center; width: 100%; padding-left: 30%; \">";
				echo "<a href=\"#\" class=\"botao\" id=\"btnVoltarConsulta\" name=\"btnVoltarConsulta\" onClick=\"voltar();return false;\" >Voltar</a>";
				if($cdsituacao_mensagem == 1){
					echo "<a href=\"#\" class=\"botao\" id=\"btnEditarMsg\" name=\"btnEditarMsg\" onClick=\"editarMsg();return false;\" >Editar Mensagem</a>";
					echo "<a href=\"#\" class=\"botao\" id=\"btnCancelarEnvio\" style=\"width: 120px; \" name=\"btnCancelarEnvio\" onClick=\"cancelarEnvioMsg(".$cdmensagem.");return false;\" >Cancelar Envio</a>";
				}else{
					echo "<a href=\"#\" class=\"botao\" id=\"btnReenviarMsg\" name=\"btnReenviarMsg\" onClick=\"reenviarMsg();return false;\" >Reenviar Mensagem</a>";
				}			
			echo "</div>";
			echo "<div style=\"padding-top:20px;\">&nbsp;</div>";
			include 'titulo.php';
			echo "<br/><fieldset style=\"background-color: #dbe2da;\"><legend><b>Tela de detalhamento</b></legend>";
			include 'banner_detalhamento.php';
			include 'conteudo.php';
			include 'botao_acao.php';
			echo "</fieldset>";
			include 'enviar_para.php';
			include 'enviar_em.php';
			echo "<script>$('#frmMsgConsulta :input').attr('disabled','disabled');$('#dtenvio_mensagem').datepicker('disable'); </script>";
		echo "</form>";
		
	}else if($cddopcao == "AM"){
		$xml  = '';
		$xml .= '<Root><Dados>';
		$xml .= '<cdorigem_mensagem>'.$cdorigem_mensagem.'</cdorigem_mensagem>';
		$xml .= '<cdmotivo_mensagem>'.$cdmotivo_mensagem.'</cdmotivo_mensagem>';
		$xml .= '</Dados></Root>';

		// Enviar XML de ida e receber String XML de resposta
		$xmlResultMsgAuto = mensageria($xml, 'TELA_ENVNOT','MSG_AUTOMATICA', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjetoMsgAuto = getObjectXML($xmlResultMsgAuto);

		// Se ocorrer um erro, mostra crítica
		if (isset($xmlObjetoMsgAuto->roottag->tags[0]->name) && strtoupper($xmlObjetoMsgAuto->roottag->tags[0]->name) == "ERRO") {
			exibeErro($xmlObjetoMsgAuto->roottag->tags[0]->tags[0]->tags[4]->cdata);
			die();
		}
		
		$msgAuto = $xmlObjetoMsgAuto->roottag->tags[0]->tags[2]->tags;
		
		$dstitulo_mensagem = getByTagName($msgAuto,'DSTITULO_MENSAGEM');
		$dstexto_mensagem = trim(getByTagName($msgAuto,'DSTEXTO_MENSAGEM'));
		$cdicone = getByTagName($msgAuto,'CDICONE');
		$inenviar_push = getByTagName($msgAuto,'INENVIAR_PUSH');
		$inexibir_banner = (getByTagName($msgAuto,'INEXIBIR_BANNER') == 1) ? " checked " : "";
		$nmimagem_banner = getByTagName($msgAuto,'NMIMAGEM_BANNER');
		$urlimagem_banner = getByTagName($msgAuto,'URLIMAGEM_BANNER');
		$dshtml_mensagem = getByTagName($msgAuto,'DSHTML_MENSAGEM');
		$dsvariaveis_mensagem = getByTagName($msgAuto,'DSVARIAVEIS_MENSAGEM');
		$inexibe_botao_acao_mobile = (getByTagName($msgAuto,'INEXIBE_BOTAO_ACAO_MOBILE') == 1) ? " checked " : "";
		$dstexto_botao_acao_mobile = getByTagName($msgAuto,'DSTEXTO_BOTAO_ACAO_MOBILE');
		$idacao_botao_acao_mobile = getByTagName($msgAuto,'IDACAO_BOTAO_ACAO_MOBILE');	
		$cdmenu_acao_mobile = getByTagName($msgAuto,'CDMENU_ACAO_MOBILE');
		$inmensagem_ativa = getByTagName($msgAuto,'INMENSAGEM_ATIVA');
		$chk_dsmensagem_acao_mobile = (trim(getByTagName($msgAuto,'DSMENSAGEM_ACAO_MOBILE') != "")) ? " checked " : "";
		$dslink_acao_mobile = getByTagName($msgAuto,'DSLINK_ACAO_MOBILE');
		$dsmensagem_acao_mobile = getByTagName($msgAuto,'DSMENSAGEM_ACAO_MOBILE');
		$cdtipo_mensagem = getByTagName($msgAuto,'CDTIPO_MENSAGEM');
		$hrenvio_mensagem = getByTagName($msgAuto,'HRENVIO_MENSAGEM');
		$intipo_repeticao = getByTagName($msgAuto,'INTIPO_REPETICAO');
		$nrdias_semana = getByTagName($msgAuto,'NRDIAS_SEMANA');
		$nrsemanas_repeticao = getByTagName($msgAuto,'NRSEMANAS_REPETICAO');
		$nrdias_mes = getByTagName($msgAuto,'NRDIAS_MES');
		$nrmeses_repeticao = getByTagName($msgAuto,'NRMESES_REPETICAO');
		$dsurl_sevidor_imagem = getByTagName($msgAuto,'DSURL_SEVIDOR_IMAGEM');
		
		echo "<form enctype=\"multipart/form-data\" id=\"frmMsgAutomatica\" name=\"frmMsgAutomatica\" class=\"formulario condensado\" method=\"post\" action=\"upload_automatica.php\">";
			echo "<input type=\"hidden\" name=\"cdcooper\" id=\"cdcooper\" value=\"".$glbvars["cdcooper"]."\" />";
			echo "<input type=\"hidden\" name=\"cdagenci\" id=\"cdagenci\" value=\"".$glbvars["cdagenci"]."\" />";
			echo "<input type=\"hidden\" name=\"nrdcaixa\" id=\"nrdcaixa\" value=\"".$glbvars["nrdcaixa"]."\" />";
			echo "<input type=\"hidden\" name=\"idorigem\" id=\"idorigem\" value=\"".$glbvars["idorigem"]."\" />";
			echo "<input type=\"hidden\" name=\"cdoperad\" id=\"cdoperad\" value=\"".$glbvars["cdoperad"]."\" />";
			
			include 'titulo.php';
			echo "<br/><fieldset style=\"background-color: #dbe2da;\"><legend><b>Tela de detalhamento</b></legend>";
			include 'banner_detalhamento.php';
			include 'conteudo.php';
			include 'botao_acao.php';
			echo "</fieldset>";
			
			if($cdtipo_mensagem == 1){
				include 'recorrencia.php';
			}
		echo "</form>";
	}else if($cddopcao == "N"){
		
		$xml  = '';
		$xml .= '<Root><Dados>';
		$xml .= '<cdcooper>0</cdcooper>';
		$xml .= '<flgativo>1</flgativo>';
		$xml .= '</Dados></Root>';

		// Enviar XML de ida e receber String XML de resposta
		$xmlResultCooper = mensageria($xml, 'CADA0001','LISTA_COOPERATIVAS', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjetoCooper = getObjectXML($xmlResultCooper);

		// Se ocorrer um erro, mostra crítica
		if (isset($xmlObjetoCooper->roottag->tags[0]->name) && strtoupper($xmlObjetoCooper->roottag->tags[0]->name) == "ERRO") {
			exibeErro($xmlObjetoCooper->roottag->tags[0]->tags[0]->tags[4]->cdata);
			die();
		}
		
		$msgCooper = $xmlObjetoCooper->roottag->tags[0]->tags;
		
		$xml  = '';
		$xml .= '<Root><Dados>';
		$xml .= '<cdmensagem>0</cdmensagem>';
		$xml .= '</Dados></Root>';

		// Enviar XML de ida e receber String XML de resposta
		$xmlResultMsgManu = mensageria($xml, 'TELA_ENVNOT','MSG_MANUAL', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjetoMsgManu = getObjectXML($xmlResultMsgManu);

		// Se ocorrer um erro, mostra crítica
		if (isset($xmlObjetoMsgManu->roottag->tags[0]->name) && strtoupper($xmlObjetoMsgManu->roottag->tags[0]->name) == "ERRO") {
			exibeErro($xmlObjetoMsgManu->roottag->tags[0]->tags[0]->tags[4]->cdata);
			die();
		}
		
		$msgManu = $xmlObjetoMsgManu->roottag->tags[0]->tags[1]->tags;
		
		$dstitulo_mensagem = getByTagName($msgManu,'DSTITULO_MENSAGEM');
		$dstexto_mensagem = trim(getByTagName($msgManu,'DSTEXTO_MENSAGEM'));
		$cdicone = getByTagName($msgManu,'CDICONE');
		$inenviar_push = getByTagName($msgManu,'INENVIAR_PUSH');
		$inexibir_banner = (getByTagName($msgManu,'INEXIBIR_BANNER') == 1) ? " checked " : "";
		$nmimagem_banner = getByTagName($msgManu,'NMIMAGEM_BANNER');
		$urlimagem_banner = getByTagName($msgManu,'URLIMAGEM_BANNER');
		$dshtml_mensagem = getByTagName($msgManu,'DSHTML_MENSAGEM');
		$dsvariaveis_mensagem = getByTagName($msgManu,'DSVARIAVEIS_MENSAGEM');
		$inexibe_botao_acao_mobile = (getByTagName($msgManu,'INEXIBE_BOTAO_ACAO_MOBILE') == 1) ? " checked " : "";
		$dstexto_botao_acao_mobile = getByTagName($msgManu,'DSTEXTO_BOTAO_ACAO_MOBILE');
		$idacao_botao_acao_mobile = getByTagName($msgManu,'IDACAO_BOTAO_ACAO_MOBILE');	
		$cdmenu_acao_mobile = getByTagName($msgManu,'CDMENU_ACAO_MOBILE');
		$inmensagem_ativa = getByTagName($msgManu,'INMENSAGEM_ATIVA');
		$chk_dsmensagem_acao_mobile = (trim(getByTagName($msgManu,'DSMENSAGEM_ACAO_MOBILE') != "")) ? " checked " : "";
		$dslink_acao_mobile = getByTagName($msgManu,'DSLINK_ACAO_MOBILE');
		$dsmensagem_acao_mobile = getByTagName($msgManu,'DSMENSAGEM_ACAO_MOBILE');
		$cdtipo_mensagem = getByTagName($msgManu,'CDTIPO_MENSAGEM');
		$hrenvio_mensagem = getByTagName($msgManu,'HRENVIO_MENSAGEM');
		$intipo_repeticao = getByTagName($msgManu,'INTIPO_REPETICAO');
		$nrdias_semana = getByTagName($msgManu,'NRDIAS_SEMANA');
		$nrsemanas_repeticao = getByTagName($msgManu,'NRSEMANAS_REPETICAO');
		$nrdias_mes = getByTagName($msgManu,'NRDIAS_MES');
		$nrmeses_repeticao = getByTagName($msgManu,'NRMESES_REPETICAO');
		$dsurl_sevidor_imagem = getByTagName($msgManu,'DSURL_SEVIDOR_IMAGEM');
		$dtenvio_mensagem = getByTagName($msgManu,'DTENVIO_MENSAGEM');
		
		$tpfiltro = getByTagName($msgManu,'TPFILTRO');
		$dsfiltro_cooperativas = getByTagName($msgManu,'DSFILTRO_COOPERATIVAS');
    $dsfiltro_tipos_conta = getByTagName($msgManu,'DSFILTRO_TIPOS_CONTA');
		$dsfiltro_tipos_conta_fis = in_array(1, $arrDsFiltro) ? " checked" : "";
		$dsfiltro_tipos_conta_jur = in_array(2, $arrDsFiltro)  ? " checked" : "";
		$dsfiltro_tipos_conta_fis = " checked";	
		$dsfiltro_tipos_conta_jur = " checked";	
		
		$tpfiltro_mobile = getByTagName($msgManu,'tpfiltro_mobile');
		
		echo "<form enctype=\"multipart/form-data\" id=\"frmMsgManual\" name=\"frmMsgManual\" class=\"formulario condensado\" method=\"post\" action=\"upload_manual.php\">";
			echo "<input type=\"hidden\" name=\"cdcooper\" id=\"cdcooper\" value=\"".$glbvars["cdcooper"]."\" />";
			echo "<input type=\"hidden\" name=\"cdagenci\" id=\"cdagenci\" value=\"".$glbvars["cdagenci"]."\" />";
			echo "<input type=\"hidden\" name=\"nrdcaixa\" id=\"nrdcaixa\" value=\"".$glbvars["nrdcaixa"]."\" />";
			echo "<input type=\"hidden\" name=\"idorigem\" id=\"idorigem\" value=\"".$glbvars["idorigem"]."\" />";
			echo "<input type=\"hidden\" name=\"cdoperad\" id=\"cdoperad\" value=\"".$glbvars["cdoperad"]."\" />";
			include 'titulo.php';
			echo "<br/><fieldset style=\"background-color: #dbe2da;\"><legend><b>Tela de detalhamento</b></legend>";
			include 'banner_detalhamento.php';
			include 'conteudo.php';
			include 'botao_acao.php';
			echo "</fieldset>";
			include 'enviar_para.php';
			include 'enviar_em.php';
		echo "</form>";
	}
?>