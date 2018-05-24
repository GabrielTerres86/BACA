<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Dionathan Hnechel
 * DATA CRIAÇÃO : 05/05/2016
 * OBJETIVO     : Rotina para manter as operações da tela PARMDA
 * --------------
 * ALTERAÇÕES   : 
 *			[30/08/2017] - Realizar as alterações pertinentes as novas funcionalidades de
 * 						   parametrização das mensagens de SMS. (Renato Darosci - Prj360)
 * -------------- 
 */
?> 

<?	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	// Inicializa
	$procedure 		= '';
	$retornoAposErro= '';
	
	
	// Recebe a operação que está sendo realizada
	$cddopcao		 = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$cdprodut		 = (isset($_POST['cdprodut'])) ? $_POST['cdprodut'] : '' ;
	$cdcooper		 = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : '' ;
	$flgenvia_sms	 = (isset($_POST['flgenvia_sms'])) ? $_POST['flgenvia_sms'] : '' ;
	$flgcobra_tarifa = (isset($_POST['flgcobra_tarifa'])) ? $_POST['flgcobra_tarifa'] : '' ;
	$cdtarifa_pf	 = (isset($_POST['cdtarifa_pf'])) ? $_POST['cdtarifa_pf'] : '' ;
	$cdtarifa_pj	 = (isset($_POST['cdtarifa_pj'])) ? $_POST['cdtarifa_pj'] : '' ;
	$hrenvio_sms	 = (isset($_POST['hrenvio_sms'])) ? $_POST['hrenvio_sms'] : '' ;
	$json_mensagens	 = (isset($_POST['json_mensagens'])) ? $_POST['json_mensagens'] : '' ;
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure 	= '';
	switch($cddopcao) {
		case 'C': $procedure = 'BUSCA_PARMDA';
				   break;
		case 'A': $procedure = 'MANTEM_PARMDA';
				   break;
		case 'E': $procedure = 'EXCLUI_PARMDA';
				   break;
		case 'TPF': $procedure = 'BUSCA_TARIFA_PARMDA';
				   break;
		case 'TPJ': $procedure = 'BUSCA_TARIFA_PARMDA';
				   break;
	}
	
	// Nao precisa validar permissao para consulta de tarifas
	if ($cddopcao <> "TPF" && $cddopcao <> "TPJ") {
		if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
			exibirErro('error',$msgError,'Alerta - Ayllos','',false);
		}
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooperalt>$cdcooper</cdcooperalt>";
	$xml .= "   <cdprodut>$cdprodut</cdprodut>";
	
	switch($cddopcao) {
		case 'A': 
			$xml .= "   <flgenvia_sms>$flgenvia_sms</flgenvia_sms>";
			$xml .= "   <flgcobra_tarifa>$flgcobra_tarifa</flgcobra_tarifa>";
			$xml .= "   <hrenvio_sms_fmt>$hrenvio_sms</hrenvio_sms_fmt>";
			$xml .= "   <cdtarifa_pf>$cdtarifa_pf</cdtarifa_pf>";
			$xml .= "   <cdtarifa_pj>$cdtarifa_pj</cdtarifa_pj>";
			$xml .= "   <json_mensagens>".utf8_decode($json_mensagens)."</json_mensagens>";
			break;
		case 'TPF': 
			$xml .= "   <cdtarifa>$cdtarifa_pf</cdtarifa>";
			break;
		case 'TPJ': 
			$xml .= "   <cdtarifa>$cdtarifa_pj</cdtarifa>";
			break;
	}
	
	$xml .= " </Dados>";
	$xml .= "</Root>";
		
	//echo '$("#divDetalhamento").html("<p>'.$xml.'</p>")';return;
	
	// Chamada mensageria
    $xmlResult = mensageria($xml, "PARMDA", $procedure, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		if ( !empty($nmdcampo) ) { 
			$mtdErro = "$('#".$nmdcampo."','#frmPrincipal').focus();";
		}
		
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);
	}
	
	if ($cddopcao == "C"){
		
		$registro = $xmlObjeto->roottag->tags[0]->tags;
		
		$flgenvia_sms	 = getByTagName($registro,'flgenvia_sms') == 1 ? "'checked'" : "null";
		$flgcobra_tarifa = getByTagName($registro,'flgcobra_tarifa') == 1 ? "'checked'" : "null";
		$cdtarifa_pf     = getByTagName($registro,'cdtarifa_pf');
		$vltarifa_pf     = formataMoeda(getByTagName($registro,'vltarifa_pf'));
		$cdtarifa_pj     = getByTagName($registro,'cdtarifa_pj');
		$vltarifa_pj     = formataMoeda(getByTagName($registro,'vltarifa_pj'));
		$hrenvio_sms     = getByTagName($registro,'hrenvio_sms');
	
		// Ler o retorno dos flags para controle de tela - Prj360
		$prod_enviasms = getByTagName($registro,'prod_enviasms'); 
		$prod_flcbrtar = getByTagName($registro,'prod_flcbrtar'); 
		$flghrenviosms = getByTagName($registro,'flghrenviosms');

		/* Habilita horário de envio de SMS  */
		if ($flghrenviosms == 1) {
		  echo "$('#hrenvio_sms','#frmPrincipal').css({'display':'block'});";
	      echo "$('label[for=\"hrenvio_sms\"]','#frmPrincipal').css({'display':'block'});";
		} else {
		  echo "$('#hrenvio_sms','#frmPrincipal').css({'display':'none'});";
	      echo "$('label[for=\"hrenvio_sms\"]','#frmPrincipal').css({'display':'none'});";
		}
		
		echo "tratarCamposPrincipal('" . $prod_enviasms . "','" . $prod_flcbrtar . "');";
	
		echo "$('#flgenvia_sms',   '#frmPrincipal').attr('checked',$flgenvia_sms);";
	    echo "$('#flgcobra_tarifa','#frmPrincipal').attr('checked',$flgcobra_tarifa);";
		echo "$('#cdtarifa_pf',    '#frmPrincipal').val('$cdtarifa_pf');";
		echo "$('#vltarifa_pf',    '#frmPrincipal').val('$vltarifa_pf');";
		echo "$('#cdtarifa_pj',    '#frmPrincipal').val('$cdtarifa_pj');";
		echo "$('#vltarifa_pj',    '#frmPrincipal').val('$vltarifa_pj');";
	    echo "$('#hrenvio_sms',    '#frmPrincipal').val('$hrenvio_sms');";
		
		$htmlmensagens = '';
		$ultimofieldset = '';
		
		// Gera os campos das mensagens
		foreach( $registro[10]->tags as $msg ) {
			$cdtipo_mensagem = $msg->attributes['CDTIPO_MENSAGEM'];
			$dscampo = $msg->tags[0]->cdata;
			$dsmensagem = $msg->tags[1]->cdata;
			$dsobservacao = $msg->tags[2]->cdata;
			$fieldset = $msg->tags[3]->cdata;
			
			//Verifica se o fieldset alterou (Tag DsAreaTela)
			if ($fieldset != $ultimofieldset) {
				if ($ultimofieldset != '') //Fecha o fieldset anterior
					$htmlmensagens .= "</fieldset>";
				
				$htmlmensagens .= "<br/>";
				$htmlmensagens .= "<fieldset><legend>".htmlentities($fieldset)."</legend>";
				$ultimofieldset = $fieldset;
			}
			else {
				$htmlmensagens .= "<br/>";
			}
			
			//Imprime o campo
			$htmlmensagens .= "<fieldset><legend>".htmlentities($dscampo)."</legend>";
			$htmlmensagens .= "<textarea id=\"mensagem$cdtipo_mensagem\" name=\"mensagem$cdtipo_mensagem\" cdtipo_mensagem=\"$cdtipo_mensagem\" class=\"campo\" style=\"width: 100%;height: 50px;\">".htmlentities($dsmensagem)."</textarea>";
			$htmlmensagens .= "<br/>";
			if ($dsobservacao) // Imprime a observação apenas se tiver
				$htmlmensagens .= "<span>Obs.:".htmlentities($dsobservacao)."</span>";
			$htmlmensagens .= "</fieldset>";
		}
		$htmlmensagens .= "</fieldset>";
		
		echo "$('#divMensagens').html('$htmlmensagens');";
				
		return;
		
	} elseif ($cddopcao == "A") {
	
		echo 'showError("inform","'.utf8_decode('Parametros alterados com sucesso.').'","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';	
	
	} elseif ($cddopcao == "E") {
	
		echo 'showError("inform","'.utf8_decode('Parametros excluídos com sucesso.').'","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';	
	
	} elseif ($cddopcao == "TPF") {
	
		$vltarifa = formataMoeda($xmlObjeto->roottag->tags[0]->cdata);
		echo "$('#vltarifa_pf',    '#frmPrincipal').val('$vltarifa');";
	
	} elseif ($cddopcao == "TPJ") {
	
		$vltarifa = formataMoeda($xmlObjeto->roottag->tags[0]->cdata);
		echo "$('#vltarifa_pj',    '#frmPrincipal').val('$vltarifa');";
	}
		
?>
