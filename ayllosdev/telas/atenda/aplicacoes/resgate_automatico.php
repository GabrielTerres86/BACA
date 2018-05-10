<?php
	/********************************************************************************      
	 Fonte: resgate_automatico.php                                              
	 Autor: Fabricio                                                    
	 Data : Agosto/2011                 Última alteração: 08/12/2014
	                                                                            
	 Objetivo  : Acessar operação Resgate Automatico da Rotina de    
				 Aplicações da tela ATENDA                                            
	                                                                    
	 Alterações: 30/04/2014 - Ajuste referente ao projeto Captação:
							  - Layout dos botões (Adriano).
							  
				 08/12/2014 - Chamda da procedure via OCI (Jean Michel).
	                                        					        
                 18/12/2017 - P404 - Inclusão de Garantia de Cobertura das Operações de Crédito (Augusto / Marcos (Supero))
	                                        					        
	*********************************************************************************/
		
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	$flginici = $_POST["flginici"];
	$nrdconta = $_POST["nrdconta"];
	$sldtotrg = $_POST["slresgat"];
	$vltotrgt = $_POST["vlresgat"];
	$vlresga2 = $_POST["vlrgtini"];
	$dtresgat = $_POST["dtresgat"];
	$flgctain = $_POST["flgctain"];
	$camposPc = $_POST["camposPc"];
	$dadosPrc = $_POST["dadosPrc"];
	$camposPc2 = $_POST["camposPc2"];
	$dadosPrc2 = $_POST["dadosPrc2"];
  
    // Verifica se a data de resgate é válida
	if (!validaData($dtresgat)) {
		exibeErro("Data do resgate inv&aacute;lida.");
	}
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
		
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>1</idseqttl>";
	$xml .= "		<nraplica>0</nraplica>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xml .= "		<dtresgat>".$dtresgat."</dtresgat>";
	$xml .= "		<vltotrgt>".str_replace(",",".",$vltotrgt)."</vltotrgt>";
	$xml .= "		<flgerlog>1</flgerlog>";
	$xml .= "		<resposta>".$dadosPrc."</resposta>";
	$xml .= "		<resgates>".$dadosPrc2."</resgates>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "ATENDA", "RESGAUT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
				
	// Se ocorrer um erro, mostra crítica
	if(strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO'){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibeErro($msgErro);			
		exit();
	}
	
	// Procura indíce da opção "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	if ($idPrincipal === false) {
		$idPrincipal = 0;
	}
			
	$vltotrgt = $xmlObj->roottag->tags[0]->tags[0]->cdata;
	
	//Respostas	
	$questiona_count = 0;	
	
	if($xmlObj->roottag->tags[0]->tags[1]->cdata != ""){
		$arr_resposta = explode("|",$xmlObj->roottag->tags[0]->tags[1]->cdata);
		$questiona_cliente = $arr_resposta;	
		$questiona_count = count($questiona_cliente);
	}
	
	//Resgates
	$dados_count = 0;
	if($xmlObj->roottag->tags[0]->tags[2]->cdata != ""){
		$arr_resgate = explode("|",$xmlObj->roottag->tags[0]->tags[2]->cdata);
		$dados_count = count($arr_resgate);
		
		for ($i = 0; $i < $dados_count; $i++){
			$dados_resgate[$i] = explode(";",$arr_resgate[$i]);
		}			
	}
			
	?>
	
	lstQuestionaCliente = new Array(); // Inicializar lista de questionamentos ao cliente
	lstDadosResgate = new Array(); // Inicializar lista de resgates selecionados
	
	<?php
	
	for ($i = 0; $i < $questiona_count; $i++){
		
		$nraplica = $questiona_cliente[$i][0];
		$dtvencto = $questiona_cliente[$i][1];
		$resposta = $questiona_cliente[$i][2];
	?>
		objQuestion = new Object();						
		objQuestion.nraplica = "<?php echo $nraplica; ?>";
		objQuestion.dtvencto = "<?php echo $dtvencto; ?>";
		objQuestion.resposta = "<?php echo $resposta; ?>";
		lstQuestionaCliente[<?php echo $i; ?>] = objQuestion;
		
	<?php
	
	}
		
	for ($i = 0; $i < $dados_count; $i++){
					
		$nraplica = $dados_resgate[$i][0];
		$dtmvtolt = $dados_resgate[$i][1];
		$dshistor = $dados_resgate[$i][2];
		$nrdocmto = $dados_resgate[$i][3];
		$dtvencto = $dados_resgate[$i][4];
		$sldresga = str_replace(".",",",$dados_resgate[$i][5]);
		$vlresgat = str_replace(".",",",$dados_resgate[$i][6]);
		$tpresgat = $dados_resgate[$i][7];
		$idtipapl = $dados_resgate[$i][8];

		if($tpresgat == "P"){
			$tpresgat = 1;
		}else if($tpresgat == "T"){
			$tpresgat = 2;
		}	
	?>
	
		objResgatesAuto = new Object();						
		objResgatesAuto.nraplica = "<?php echo $nraplica; ?>";
		objResgatesAuto.dtmvtolt = "<?php echo $dtmvtolt; ?>";
		objResgatesAuto.dshistor = "<?php echo $dshistor; ?>";
		objResgatesAuto.nrdocmto = "<?php echo $nrdocmto; ?>";
		objResgatesAuto.dtvencto = "<?php echo $dtvencto; ?>";
		objResgatesAuto.sldresga = "<?php echo $sldresga; ?>";
		objResgatesAuto.idtipapl = "<?php echo $idtipapl; ?>";
		
		<?php
		if ($tpresgat == "P" || $tpresgat == "1") {
		?>
			objResgatesAuto.vlresgat = "<?php echo $vlresgat; ?>";
		<?php
		
		} else {
			if ((trim($resposta) == "") && ($questiona_count > 0)){
		?>
				objResgatesAuto.vlresgat = "<?php echo $vlresgat; ?>";
		<?php
			}
			else {
				?>
				objResgatesAuto.vlresgat = "0";
		<?php
			}
		}
		?>
		
		objResgatesAuto.tpresgat = "<?php echo $tpresgat; ?>";
		lstDadosResgate[<?php echo $i; ?>] = objResgatesAuto;
		
	<?php
	
	}
	
	if (($dados_count == 0) && (trim($resposta) != "" && trim($resposta) != 0)){
		exibeErro("N&atilde;o h&aacute aplica&ccedil;&otilde;es para resgate.");
	}
	
	if ((trim($resposta) == "" || trim($resposta == 0)) && ($questiona_count > 0)){
		echo 'showConfirmacao("Aplica&ccedil;&atilde;o n&uacute;mero '.getByTagName($questiona_cliente[$questiona_count -1]->tags,"NRAPLICA").' vencer&aacute em '.getByTagName($questiona_cliente[$questiona_count -1]->tags,"DTVENCTO").'. Resgatar?","Confirma&ccedil;&atilde;o - Ayllos","continuaListarResgates(\'SIM\',\''.$vltotrgt.'\')","continuaListarResgates(\'NAO\',\''.$vltotrgt.'\')","sim.gif","nao.gif");';
	} else {
		
	?>
		var strHTML = "";
		
		strHTML +='<div class="divAplicacoesPrincipal">';
		strHTML += '	<fieldset>';
		strHTML += '	<legend align="center"><b>APLICA&Ccedil;&Otilde;ES RESGATADAS</b></legend>';
		
		strHTML += '<div class="divRegistros">';
		
		strHTML += '		<table>';
		strHTML += '			<thead>';
		strHTML += '				<tr>';
		strHTML += '                    <th><? echo utf8ToHtml('Data'); ?></th>';
		strHTML += '					<th><? echo utf8ToHtml('Hist&oacute;rico');  ?></th>';
		strHTML += '					<th><? echo utf8ToHtml('Docmto');  ?></th>';
		strHTML += '					<th><? echo utf8ToHtml('Vencto');  ?></th>';
		strHTML += '					<th><? echo utf8ToHtml('Sl Resgate');  ?></th>';
		strHTML += '					<th><? echo utf8ToHtml('Vl Resgate');  ?></th>';
		strHTML += '				</tr>';
		strHTML += '			</thead>';
		strHTML += '			<tbody>';
	
		<?php
		
		for ($i = 0; $i < $dados_count; $i++){
			
			$nraplica = $dados_resgate[$i][0];
			$dtmvtolt = $dados_resgate[$i][1];
			$dshistor = $dados_resgate[$i][2];
			$nrdocmto = $dados_resgate[$i][3];
			$dtvencto = $dados_resgate[$i][4];
			$sldresga = $dados_resgate[$i][5];
			$vlresgat = $dados_resgate[$i][6];
			$tpresgat = $dados_resgate[$i][7];
			$idtipapl = $dados_resgate[$i][8];			
		
		?>
			strHTML += '<tr id="trAplicacoesResgatadas<?php echo $i; ?>" style="cursor: pointer;">';
			strHTML += '	<td><?php echo $dtmvtolt; ?>';
			strHTML += '	</td>';
			strHTML += '	<td><?php echo $dshistor; ?>';
			strHTML += '	</td>';
			strHTML += '	<td><?php echo $nrdocmto; ?>';
			strHTML += '	</td>';
			strHTML += '	<td><?php echo $dtvencto; ?>';
			strHTML += '	</td>';
			strHTML += '	<td><?php echo number_format(str_replace(",",".",$sldresga),2,",","."); ?>';
			strHTML += '	</td>';
			strHTML += '	<td><?php echo number_format(str_replace(",",".",$vlresgat),2,",","."); ?>';
			strHTML += '	</td>';	
			strHTML += '</tr>';
		<?php
		}			
		?>
		
		strHTML += '			</tbody>';
		strHTML += '		</table>';
		strHTML += '</div>';
		
		//strHTML += '    <ul class="complemento">';
		//strHTML += '    	<li>Resgate no valor de R$</li>';
		//strHTML += '    	<li><?php echo number_format(str_replace(",",".",$vlresga2),2,",",".") ?></li>';
		//strHTML += '    </ul>';
		
		strHTML += '<ul class="complemento">';
		strHTML += '<li>Informado:</li>';
		strHTML += '<li><?php echo number_format(str_replace(",",".",$vlresga2),2,",",".") ?></li>';
		strHTML += '<li>Total selecionado:</li>';
		strHTML += '<li id="tdTotSel"><?php echo number_format(str_replace(",",".",$vltotrgt),2,",",".") ?></li>';
		strHTML += '<li>Diferen&ccedil;a:</li>';
		strHTML += '<li id="tdDifer"><?php echo number_format(str_replace(",",".",(str_replace(",",".",$vlresga2) - str_replace(",",".",$vltotrgt))),2,",",".") ?></li>';
		strHTML += '</ul>';
		
		strHTML += '	<div id="divBotoes">';
		strHTML += '		<a href="#" class="botao" id="btCancelar" onClick="voltarDivResgateAutoManual(\'false\');return false;">Cancelar</a>';
		strHTML += '		<a href="#" class="botao" id="btConcluir" onClick="validaDiferenca(\'automatica\',\'yes\',\'<?php echo $nrdconta; ?>\',\'<?php echo $dtresgat; ?>\',\'<?php echo $flgctain; ?>\');return false;">Concluir</a>';
		strHTML += '	</div>';
		
		strHTML += '	</fieldset>';
		strHTML += '</div>';
		
		
		$("#divAutoManual").html(strHTML);
		formataTabelaResgateAutomatico();
		$("#divOpcoes").css("display","none");
		$("#divAutoManual").css("display","block");
		hideMsgAguardo();
		blockBackground(parseInt($("#divRotina").css("z-index")));
	<?php
	}	
?>