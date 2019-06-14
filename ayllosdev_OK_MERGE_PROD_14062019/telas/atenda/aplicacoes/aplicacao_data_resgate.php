<?php 

	/*******************************************************************************************
	  Fonte: aplicacao_data_resgate.php                                
	  Autor: David                                                     
	  Data : Outubro/2010                 Última Alteração: 29/07/2014
	                                                                   
	  Objetivo  : Script para calcular data de resgate da aplicação    	
	                                                                   	 
	  Alterações: 01/12/2010 - Alterado a chamada da BO b1wgen0004.p   
	                           para a BO b1wgen0081.p (Adriano).      

				  11/06/2014 - Ajustes referente ao projeto de captação
							   (Adriano).
							   
				  29/07/2014 - Ajustes referente ao projeto de captação,
							   inclusao de novos parametros e chamada de procedure.
							   (Jean Michel).
							   
	********************************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	$nrdconta = isset($_POST["nrdconta"]) ? $_POST["nrdconta"] : 0;
	$tpaplica = isset($_POST["tpaplica"]) ? $_POST["tpaplica"] : 0;	 /*Codigo do tipo da aplicacao*/	
	$qtdiaapl = isset($_POST["qtdiaapl"]) ? $_POST["qtdiaapl"] : 0;		
	$qtdiacar = isset($_POST["qtdiacar"]) ? $_POST["qtdiacar"] : 0;		
	$dtresgat = isset($_POST["dtresgat"]) ? $_POST["dtresgat"] : '';			
	$nmdcampo = isset($_POST["nmdcampo"]) ? $_POST["nmdcampo"] : '';
	$dtcarenc = isset($_POST["dtcarenc"]) ? $_POST["dtcarenc"] : ''; /*Data de carencia*/
	$qtdiapra = isset($_POST["qtdiapra"]) ? $_POST["qtdiapra"] : ''; /*Dias de Prazo*/
	
	$idtippro =  isset($_POST["idtippro"]) ? $_POST["idtippro"] : 0; /*Verifica se produto é PRE OU POS dos produtos novos*/
	$idprodut =  isset($_POST["idprodut"]) ? $_POST["idprodut"] : 0; /*Verifica se é produto novo ou antigo*/
	
		
	if ($idprodut == "A"){
		$frm = ($tpaplica == 7) ? "frmDadosAplicacaoPre" : "frmDadosAplicacaoPos";
	}else{
		$frm = "frmDadosAplicacaoPos";
	}
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.",$frm);
	}	
	
	// Verifica se tipo de aplicação é um inteiro válido
	if (!validaInteiro($tpaplica)) {
		exibeErro("Tipo de aplica&ccedil;&atilde;o inv&aacute;lida.",$frm);
	}	
	
	// Verifica se quantidade de dias é um inteiro válido
	if (!validaInteiro($qtdiaapl)) {
		exibeErro("Quantidade de dias inv&aacute;lida.",$frm);
	}
	
	// Verifica se quantidade de dias de carencia é um inteiro válido
	if (!validaInteiro($qtdiacar)) {
		exibeErro("Car&ecirc;ncia inv&aacute;lida.",$frm);
	}
	
	// Verifica se é uma data válida
	if ($dtresgat <> "" && !validaData($dtresgat)) {
		exibeErro("Data de vencimento inv&aacute;lida.",$frm);
	}
	
	if ($idprodut == "A"){
		
		// Monta o xml de requisição
		$xmlPermanencia  = "";
		$xmlPermanencia .= "<Root>";
		$xmlPermanencia .= "	<Cabecalho>";
		$xmlPermanencia .= "		<Bo>b1wgen0081.p</Bo>";
		$xmlPermanencia .= "		<Proc>calcula-permanencia-resgate</Proc>";
		$xmlPermanencia .= "	</Cabecalho>";
		$xmlPermanencia .= "	<Dados>";
		$xmlPermanencia .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlPermanencia .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xmlPermanencia .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xmlPermanencia .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlPermanencia .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xmlPermanencia .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
		$xmlPermanencia .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xmlPermanencia .= "		<idseqttl>1</idseqttl>";
		$xmlPermanencia .= "		<tpaplica>".$tpaplica."</tpaplica>";
		$xmlPermanencia .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
		$xmlPermanencia .= "		<qtdiaapl>".$qtdiaapl."</qtdiaapl>";
		$xmlPermanencia .= "		<qtdiacar>".$qtdiacar."</qtdiacar>";
		$xmlPermanencia .= "		<dtvencto>".$dtresgat."</dtvencto>";	
		$xmlPermanencia .= "	</Dados>";
		$xmlPermanencia .= "</Root>";	
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xmlPermanencia);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObjPermanencia = getObjectXML($xmlResult);		
		
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObjPermanencia->roottag->tags[0]->name) == "ERRO") {
			exibeErro($xmlObjPermanencia->roottag->tags[0]->tags[0]->tags[4]->cdata,$frm);
		} 
		
		echo 'flgDigitVencto = false;';
		
	}else{
		
		// Montar o xml de Requisicao
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <datcaren>".$dtcarenc."</datcaren>";
		$xml .= "   <datvenci>".$dtresgat."</datvenci>";
		$xml .= "   <diaspraz>".$qtdiapra."</diaspraz>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
		
		$xmlResult = mensageria($xml, "ATENDA", "VALDTV", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjPermanencia = getObjectXML($xmlResult);
					
		//-----------------------------------------------------------------------------------------------
		// Controle de Erros
		//-----------------------------------------------------------------------------------------------
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObjPermanencia->roottag->tags[0]->name) == "ERRO") {		
			$msgErro = $xmlObjPermanencia->roottag->tags[0]->tags[0]->tags[4]->cdata;
			
			if($msgErro == null || $msgErro == ""){
				$msgErro = $xmlObjPermanencia->roottag->tags[0]->cdata;
			}
			
			exibeErro($msgErro,$frm);
			
		}else{
			echo '$("#qtdiaapl","#'.$frm.'").val("'.trim($xmlObjPermanencia->roottag->tags[0]->tags[0]->cdata).'");';
			echo 'hideMsgAguardo();';
			echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
			
			echo 'flgDigitVencto = false;';
		}	
	}	
			
	if ($idprodut == "A"){	
?>

	glbvenct = "<?php echo $xmlObjPermanencia->roottag->tags[0]->attributes["DTVENCTO"]; ?>";	
	glbqtdia = "<?php echo $xmlObjPermanencia->roottag->tags[0]->attributes["QTDIAAPL"]; ?>";	

	/*RDCPRE*/
	if(tpaplrdc == 1){
		$("#qtdiaapl","#frmDadosAplicacaoPre").val("<?php echo $xmlObjPermanencia->roottag->tags[0]->attributes["QTDIAAPL"]; ?>");
		$("#dtresgat","#frmDadosAplicacaoPre").val("<?php echo $xmlObjPermanencia->roottag->tags[0]->attributes["DTVENCTO"]; ?>");
		$("#qtdiacar","#frmDadosAplicacaoPre").val("0");

		if ("<?php echo $nmdcampo;?>" == "dtresgat") {
			carregaCarenciaAplicacao();
		}
		
	}else{
		<?php			
			echo 'aux_qtdiaapl = glbqtdia;';			
			if($dtresgat == ''){
		?>
			$("#dtresgat","#<?php echo $frm;?>").val("<?php echo $xmlObjPermanencia->roottag->tags[0]->attributes["DTVENCTO"]; ?>");				
		<?php
			}
		?>		
	}	
	<?php } ?>
	
	hideMsgAguardo();
	blockBackground(parseInt($("#divRotina").css("z-index")));

<?php
	
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro,$frm) {	
		if ($idprodut == "A"){	
			echo '$("#dtresgat","#'.$frm.'").val(glbvenct);';		
			echo '$("#qtdiaapl","#'.$frm.'").val(glbqtdia);';
			echo 'aux_qtdiaapl = glbqtdia;';
			
			if ($nmdcampo == "") {
				$nmdcampo = "qtdiaapl";
			}
		}else{
			echo '$("#dtresgat","#'.$frm.'").val("");';	
			$nmdcampo = "dtresgat";	
		}
		
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","$(\'#'.$nmdcampo.'\',\'#'.$frm.'\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
		
	}
?>