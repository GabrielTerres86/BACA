<?php 

	/************************************************************************
	 Fonte: titulos_bordero_liberaranalisar.php                       
	 Autor: Guilherme                                                 
	 Data : Novembro/2008                Última Alteração: 09/03/2017
	                                                                  
	 Objetivo  : Liberar um bordero de desconto de títulos            
	                                                                  
	 Alterações: 14/09/2011 - Incluido chamada da procedure alerta_fraude
							  (Adriano).
					
				 01/11/2011 - Correção para mostar as mensagens de alerta 
							  (Adriano).
							  
	             14/11/2012 - Ajustes refente ao projeto GE (Adriano).						  
				
                 26/03/2013 - Retirado a chamada da procedure alerta_fraude e 
							  retirado o tratamento para quando $inconfir = 33
						     (Adriano).				
		         17/06/2016 - M181 - Alterar o CDAGENCI para          
                      passar o CDPACTRA (Rafael Maciel - RKAM) 
			
                 27/06/2016 - Passagem da aux_inconfi6. (Jaison/James)
							  
				 09/03/2017 - Ajuste para tratar titulo já incluso em outro borderô
							 (Adriano - SD 603451).
							  
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrborder"]) ||
		!isset($_POST["cddopcao"]) ||
		!isset($_POST["inconfir"]) || 
		!isset($_POST["inconfi2"]) ||
		!isset($_POST["inconfi3"]) ||
		!isset($_POST["inconfi4"]) ||
		!isset($_POST["inconfi5"]) ||
		!isset($_POST["inconfi6"]) ||
		!isset($_POST["indrestr"]) ||
		!isset($_POST["indentra"]) ||
		!isset($_POST["nrcpfcgc"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrborder = $_POST["nrborder"];
	$cddopcao = $_POST["cddopcao"];
	$inconfir = $_POST["inconfir"];
	$inconfi2 = $_POST["inconfi2"];
	$inconfi3 = $_POST["inconfi3"];
	$inconfi4 = $_POST["inconfi4"];
	$inconfi5 = $_POST["inconfi5"];
	$inconfi6 = $_POST["inconfi6"];
	$indentra = $_POST["indentra"];
	$indrestr = $_POST["indrestr"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
    $cdopcoan = $_POST["cdopcoan"];
    $cdopcolb = $_POST["cdopcolb"];
	
	$msg = Array();
	
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o indicador do tipo de impressão é um inteiro válido
	if (!validaInteiro($nrborder)) {
		exibeErro("N&uacute;mero do border&ocirc; inv&aacute;lido.");
	}
	
	// Verifica se o CPF/CNPJ &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcpfcgc)) {
		exibeErro("N&uacute;mero de CPF/CNPJ inv&aacute;lido.");
	}	
	
		
	// Monta o xml de requisição
	$xmlLiberacao  = "";
	$xmlLiberacao .= "<Root>";
	$xmlLiberacao .= "	<Cabecalho>";
	$xmlLiberacao .= "		<Bo>b1wgen0030.p</Bo>";
	$xmlLiberacao .= "		<Proc>efetua_liber_anali_bordero</Proc>";
	$xmlLiberacao .= "	</Cabecalho>";
	$xmlLiberacao .= "	<Dados>";
	$xmlLiberacao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlLiberacao .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xmlLiberacao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlLiberacao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlLiberacao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlLiberacao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlLiberacao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlLiberacao .= "		<idseqttl>1</idseqttl>";
	$xmlLiberacao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlLiberacao .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";	
	$xmlLiberacao .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlLiberacao .= "		<nrborder>".$nrborder."</nrborder>";	
	$xmlLiberacao .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xmlLiberacao .= "		<inconfir>".$inconfir."</inconfir>";
	$xmlLiberacao .= "		<inconfi2>".$inconfi2."</inconfi2>";
	$xmlLiberacao .= "		<inconfi3>".$inconfi3."</inconfi3>";
	$xmlLiberacao .= "		<inconfi4>".$inconfi4."</inconfi4>";
	$xmlLiberacao .= "		<inconfi5>".$inconfi5."</inconfi5>";
	$xmlLiberacao .= "		<inconfi6>".$inconfi6."</inconfi6>";
	$xmlLiberacao .= "		<indrestr>".$indrestr."</indrestr>";
	$xmlLiberacao .= "		<indentra>".$indentra."</indentra>";
	$xmlLiberacao .= "		<cdopcoan>".$cdopcoan."</cdopcoan>";
	$xmlLiberacao .= "		<cdopcolb>".$cdopcolb."</cdopcolb>";
	$xmlLiberacao .= "	</Dados>";
	$xmlLiberacao .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlLiberacao);

	// Cria objeto para classe de tratamento de XML
	$xmlObjLiberacao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjLiberacao->roottag->tags[0]->name) == "ERRO") {
					
		$aux_mensagem = $xmlObjLiberacao->roottag->tags[1]->tags[0]->tags[1]->cdata;
		$aux_inconfir = $xmlObjLiberacao->roottag->tags[1]->tags[0]->tags[0]->cdata;	
		$grupo 		  = $xmlObjLiberacao->roottag->tags[2]->tags;  
				
		/*Se a conta em questão fizer parte de algum grupo economico e o valor legal for excedido então, será mostrado 
		  todas as contas deste grupo.*/
		if($aux_inconfir == 19 && count($grupo) > 0){?>	
		
			strHTML = '';
			strHTML2 = '';
						
			strHTML2 += '<form name="frmGrupoEconomico" id="frmGrupoEconomico" class="formulario">';
			strHTML2 +=		'<br />';
			strHTML2 +=		'Conta pertence a grupo econ&ocirc;mico.';
			strHTML2 +=		'<br />';
			strHTML2 +=		'Valor ultrapassa limite legal permitido.';
			strHTML2 +=		'<br />';
			strHTML2 +=		'Verifique endividamento total das contas.';
			strHTML2 += '</form>';
			strHTML  += '<br style="clear:both" />';
			strHTML  += '<br style="clear:both" />';
			strHTML  += '<div class="divRegistros">';
			strHTML  +=	'<table>';
			strHTML  +=		'<thead>';
			strHTML  +=			'<tr>';
			strHTML  +=				'<th>Contas Relacionadas</th>';
			strHTML  +=			'</tr>';
			strHTML  +=		'</thead>';
			strHTML  +=		'<tbody>';
		
			
			<?php 
			for ($i = 0; $i < count($grupo); $i++) { ?>
					
				strHTML +=				'<tr>';
				strHTML +=					'<td><span><?php echo $grupo[$i]->tags[2]->cdata;?></span>';
				strHTML +=							'<?php echo formataContaDV($grupo[$i]->tags[2]->cdata);?>';
				strHTML +=					'</td>';
				strHTML +=				'</tr>';
						
			<?php
			}
			?>
			
			strHTML +=		'</tbody>';
			strHTML +=	'</table>';
						
			dsmetodo = 'showError("error","<?echo $xmlObjLiberacao->roottag->tags[0]->tags[0]->tags[4]->cdata;?>","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));");';
			showError("inform","<?echo $aux_mensagem;?>","Alerta - Aimaro","mostraMsgsGrupoEconomico();formataGrupoEconomico();");
		
			<?
			exit();
			
		}elseif($aux_inconfir == 19){?>
		
			hideMsgAguardo();
			showError("inform","<? echo $aux_mensagem;?>","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')));hideMsgAguardo();showError('error','<?echo $xmlObjLiberacao->roottag->tags[0]->tags[0]->tags[4]->cdata;?>','Alerta - Aimaro','blockBackground(parseInt($(\\'#divRotina\\').css(\\'z-index\\')))');");
			<?
			exit();
		
		}elseif($aux_inconfir == 72){?>
		
			hideMsgAguardo();
			showError("inform","<? echo $aux_mensagem;?>","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')));hideMsgAguardo();showError('error','<?echo $xmlObjLiberacao->roottag->tags[0]->tags[0]->tags[4]->cdata;?>','Alerta - Aimaro','blockBackground(parseInt($(\\'#divRotina\\').css(\\'z-index\\')))');");
			<?
			exit();
		
		}else{
			
			$msgAlertas = $xmlObjLiberacao->roottag->tags[0]->tags;

			if (count($msgAlertas) > 1){
				?>
			    
				strHTML = '';		 
				
				strHTML += '<div class="divRegistros">';
				strHTML += '  <table>';
				strHTML += '    <thead>';
				strHTML += '       <tr>';
				strHTML += '          <th>Sequ&ecirc;ncia</th>';
				strHTML += '          <th>Descri&ccedil;&atilde;o</th>';
				strHTML += '       </tr>';
				strHTML += '    </thead>';
				strHTML += '    <tbody>';

				<? for ($i = 0; $i < count($msgAlertas); $i++) {?>
				
					strHTML += '     	       <tr>'; 	
					strHTML += '     	   	     <td><? echo $msgAlertas[$i]->tags[2]->cdata; ?> </td>';
					strHTML += '     	   	     <td><? echo $msgAlertas[$i]->tags[4]->cdata; ?> </td>';
					strHTML += '     	       </tr>';	
				
				<? } ?>

				strHTML += '     </tbody>';	
				strHTML += '  </table>';
				strHTML += '</div>';
				
				mostraMsgsGenericas();

				
			<?
				exit();

			}else{
			exibeErro($xmlObjLiberacao->roottag->tags[0]->tags[0]->tags[4]->cdata);
			}

		
		}
						
	}

	$qtMensagens = count($xmlObjLiberacao->roottag->tags[1]->tags);
	$mensagem    = $xmlObjLiberacao->roottag->tags[1]->tags[$qtMensagens - 1]->tags[1]->cdata;
	$inconfir    = $xmlObjLiberacao->roottag->tags[1]->tags[$qtMensagens - 1]->tags[0]->cdata;
	$indentra    = $xmlObjLiberacao->roottag->tags[1]->attributes["INDENTRA"];
	$indrestr    = $xmlObjLiberacao->roottag->tags[1]->attributes["INDRESTR"];
	 
	
	if ($inconfir == 88 ) {?>
	
		hideMsgAguardo();
		nrbordero = "<?php echo $nrborder; ?>";
		showError("inform","<?php echo $mensagem; ?>","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));carregaBorderosTitulos();voltaDiv(3,2,4,\"DESCONTO DE T&Iacute;TULOS - BORDER&Ocirc;S\");");
		<?
		
	}elseif ($inconfir == 2){	?>
	
		hideMsgAguardo();
		aux_inconfir = "<?php echo $inconfir; ?>";	
		showConfirmacao("<?php echo $mensagem; ?>","Confirma&ccedil;&atilde;o - Aimaro","liberaAnalisaBorderoDscTit('<?php echo $cddopcao; ?>',aux_inconfir,aux_inconfi2,aux_inconfi3,aux_inconfi4,aux_inconfi5,aux_inconfi6,'<?php echo $indentra; ?>','<?php echo $indrestr; ?>')","blockBackground(parseInt($('#divRotina').css('z-index')))","sim.gif","nao.gif");
		
	<?
	}elseif ($inconfir == 12){	?>
	
		hideMsgAguardo();
		aux_inconfi2 = "<?php echo $inconfir; ?>";
		showConfirmacao("<?php echo $mensagem; ?>","Confirma&ccedil;&atilde;o - Aimaro","liberaAnalisaBorderoDscTit('<?php echo $cddopcao; ?>',aux_inconfir,aux_inconfi2,aux_inconfi3,aux_inconfi4,aux_inconfi5,aux_inconfi6,'<?php echo $indentra; ?>','<?php echo $indrestr; ?>')","blockBackground(parseInt($('#divRotina').css('z-index')))","sim.gif","nao.gif");
		
	<?php
	}elseif ($inconfir == 22){	?>
	
		hideMsgAguardo();
		aux_inconfi3 = "<?php echo $inconfir; ?>";
		showConfirmacao("<?php echo $mensagem; ?>","Confirma&ccedil;&atilde;o - Aimaro","liberaAnalisaBorderoDscTit('<?php echo $cddopcao; ?>',aux_inconfir,aux_inconfi2,aux_inconfi3,aux_inconfi4,aux_inconfi5,aux_inconfi6,'<?php echo $indentra; ?>','<?php echo $indrestr; ?>')","blockBackground(parseInt($('#divRotina').css('z-index')))","sim.gif","nao.gif");

	<?php
	}elseif ($inconfir == 31){	?>
	
		hideMsgAguardo();
		aux_inconfi5 = "<?php echo ($inconfir + 1); ?>";
		showConfirmacao("<?php echo $mensagem; ?>","Confirma&ccedil;&atilde;o - Aimaro","liberaAnalisaBorderoDscTit('<?php echo $cddopcao; ?>',aux_inconfir,aux_inconfi2,aux_inconfi3,aux_inconfi4,aux_inconfi5,aux_inconfi6,'<?php echo $indentra; ?>','<?php echo $indrestr; ?>')","blockBackground(parseInt($('#divRotina').css('z-index')))","sim.gif","nao.gif");

	<?php
	}elseif ($inconfir == 72){	?>
	
	    hideMsgAguardo();
		aux_inconfi4 = "<?php echo $inconfir; ?>";
		showError("inform","<?php echo $mensagem; ?>","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));liberaAnalisaBorderoDscTit('<?php echo $cddopcao; ?>',aux_inconfir,aux_inconfi2,aux_inconfi3,aux_inconfi4,aux_inconfi5,aux_inconfi6,'<?php echo $indentra; ?>','<?php echo $indrestr; ?>')");
		
	<?php
	}elseif ($inconfir == 52){	?>

	    hideMsgAguardo();
		aux_inconfi6 = "<?php echo $inconfir; ?>";
        mostraListagemRestricoes('<?php echo $cddopcao; ?>',aux_inconfir,aux_inconfi2,aux_inconfi3,aux_inconfi4,aux_inconfi5,aux_inconfi6,'<?php echo $indentra; ?>','<?php echo $indrestr; ?>');
		
	<?php
	}
	

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>