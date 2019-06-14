<?php 

	/*************************************************************************
		Fonte: imprimir.php                                              
		Autor: David                                                     
		Data : Mar�o/2008                   �ltima Altera��o: 07/05/2015
	                                                                  
		Objetivo  : Mostrar op��o Imprimir da rotina de Limite de        
					Cr�dito da tela ATENDA                               
	                                                                  	 
		Altera��es: 16/04/2010 - Adaptar para novo RATING (David).      
	                                                                  
					16/09/2010 - Ajuste para enviar impressoes via email 
								 para o PAC Sede (David).                
	                                                                 	 
	                28/06/2011 - Tableless - (Rogerius DB1)   		   
	                                          						   
	    			09/07/2012 - Adicionado onkeypress em campo contrato 
	   						     e retirado campo "redirect" (Jorge).	   
																	   
	 			    14/07/2014 - Ajustes Referentes ao projeto CET      
							     (Lucas R./Gielow)		

					07/05/2015 - Consultas automatizadas (Gabriel-RKAM).					
	*************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"I")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o n�mero da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];

	// Verifica se o n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Procura ind�ce da op��o "I"
	$idImpressao = array_search("I",$glbvars["opcoesTela"]);
	
	// Se o �ndice da op��o "I" n�o foi encontrado, encaminha para primeira op��o da rotina
	if ($idImpressao === false) {
		$idImpressao = 0;	
	}
	
	// Fun��o para rodar caso a impress�o do rating apresente cr�ticas
	echo '<script type="text/javascript">var metodoImpressao = \'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idImpressao.',"'.$glbvars["opcoesTela"][$idImpressao].'")\';</script>';
	
	if ($glbvars["cdcooper"] == 3) {
		$divBloqueia = "blockBackground(parseInt($('#divRotina').css('z-index')))";
		$imp_rating = "showError('inform','Utilize a tela ATURAT para a impress&atilde;o do rating.','Alerta - Aimaro',".$divBloqueia.");";
	} else {
		$imp_rating = "carregarImpresso(5,'no','no',0,metodoImpressao);";
	}
	
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>

<form action="<?php echo $UrlSite; ?>telas/atenda/limite_credito/imprimir_dados.php" name="frmImprimir" id="frmImprimir" method="post">
	
	<input type="hidden" name="nrdconta" id="nrdconta" value="">
	<input type="hidden" name="nrctrlim" id="nrctrlim" value="">
	<input type="hidden" name="idimpres" id="idimpres" value="">
	<input type="hidden" name="flgemail" id="flgemail" value="">
	<input type="hidden" name="flgimpnp" id="flgimpnp" value="">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">							

	<label for="contrato"><? echo utf8ToHtml('N&uacute;mero do Contrato:') ?></label>	
	<input name="contrato" type="text" id="contrato" onkeypress="return checaEnter(this,event);">


	<div id="divBotoes">
		<!-- bruno - prj - 438 - sprint 7 - tela principal -->
		<a href="#" class="botao" id="btVoltarImpressao" onClick="acessaTela('@');  return false;">Voltar</a>
		<a href="#" class="botao" id="btCompleta" onClick="verificaEnvioEmail(1,'yes');   return false;">Completa  </a>
		<a href="#" class="botao" id="btContrato" onClick="verificaEnvioEmail(2,'yes');   return false;">Contrato  </a>
		<a href="#" class="botao" id="btCet"      onClick="verificaEnvioEmail(6,'yes');   return false;">CET       </a>
		<a href="#" class="botao" id="btProposta" onClick="verificaEnvioEmail(3,'no');    return false;">Proposta  </a>
		<a href="#" class="botao" id="btRecisao"  onClick="verificaEnvioEmail(4,'no');    return false;">Recisao   </a>
		<a href="#" class="botao" id="btRating"   onClick="<?php echo $imp_rating; ?>     return false;">Rating    </a>
		<a href="#" class="botao" id="btConsulta" onClick="carregarImpresso(7,'no','no'); return false;">Consultas </a>		
	</div>

</form>

<script type="text/javascript">
	$("#contrato","#frmImprimir").setMask("INTEGER","z.zzz.zz9","","");
	$("#contrato","#frmImprimir").val(nrctrimp);
	nrctrimp = "0";
	$("#contrato","#frmImprimir").focus();
	
	formataImprimir();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
</script>