<?php
	/****************************************************************************************
	 Fonte: resgate_automatico.php                                             
	 Autor: Fabricio
	 Data : Agosto/2011                                    Última alteração: 09/12/2014 
	                                                                        
	 Objetivo  : Acessar opção Resgate Automatico da Rotina de 
				 Aplicações da tela ATENDA                                              
	                                                                      
	 Alterações: 21/09/2011 - Colocado em comentario a linha que adiciona o botao Parcial. 
	                          (Fabricio)                    
							  
				 30/04/2014 - Ajuste referente ao projeto Captação:
							  - Layout dos botões (Adriano).
							  
				 09/12/2014 - Incluido verificacao para execucao par funcao js
							  selecionaAplicacaoManual (Jean Michel).
							  
	****************************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	$nrdconta = $_POST["nrdconta"];
	$sldtotrg = $_POST["slresgat"];
	$vltotrgt = $_POST["vlresgat"];
	$dataresg = $_POST["dtresgat"];
	$flgctain = $_POST["flgctain"];
	$cdopera2 = (isset($_POST['cdopera2'])) ? $_POST['cdopera2'] : '';
	
	if(trim($cdopera2) == ''){
		$cdopera2 = $glbvars["cdoperad"];
	}
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
	
	// Monta o xml de requisição
	$xmlGetAplicacoes  = "";
	$xmlGetAplicacoes .= "<Root>";
	$xmlGetAplicacoes .= "	<Cabecalho>";
	$xmlGetAplicacoes .= "		<Bo>b1wgen0081.p</Bo>";
	$xmlGetAplicacoes .= "		<Proc>retorna-aplicacoes-resgate-manual</Proc>";
	$xmlGetAplicacoes .= "	</Cabecalho>";
	$xmlGetAplicacoes .= "	<Dados>";
	$xmlGetAplicacoes .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetAplicacoes .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetAplicacoes .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetAplicacoes .= "		<cdoperad>".$cdopera2."</cdoperad>";
	$xmlGetAplicacoes .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetAplicacoes .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";		
	$xmlGetAplicacoes .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetAplicacoes .= "		<idseqttl>1</idseqttl>";
	$xmlGetAplicacoes .= "		<nraplica>0</nraplica>";
	$xmlGetAplicacoes .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetAplicacoes .= "		<cdprogra>".$glbvars["nmdatela"]."</cdprogra>";
	$xmlGetAplicacoes .= "	</Dados>";
	$xmlGetAplicacoes .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetAplicacoes);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAplicacoes = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjAplicacoes->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjAplicacoes->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	// Procura indíce da opção "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	if ($idPrincipal === false) {
		$idPrincipal = 0;
	}

	$dados_resgate = $xmlObjAplicacoes->roottag->tags[0]->tags;
	$dados_count = count($dados_resgate);
	
	?>
	lstDadosResgate = new Array(); // Inicializar lista de resgates do cooperado
	lstResgatesManuais = new Array(); // Inicializar lista de resgates que o cooperado selecionar
	
	<?php
	
	for ($i = 0; $i < $dados_count; $i++){
		$nraplica = getByTagName($dados_resgate[$i]->tags,"NRAPLICA");
		$dtmvtolt = getByTagName($dados_resgate[$i]->tags,"DTMVTOLT");
		$dshistor = getByTagName($dados_resgate[$i]->tags,"DSHISTOR");
		$nrdocmto = getByTagName($dados_resgate[$i]->tags,"NRDOCMTO");
		$dtvencto = getByTagName($dados_resgate[$i]->tags,"DTVENCTO");
		$vllanmto = getByTagName($dados_resgate[$i]->tags,"VLLANMTO");
		$sldresga = getByTagName($dados_resgate[$i]->tags,"SLDRESGA");
		$dssitapl = getByTagName($dados_resgate[$i]->tags,"DSSITAPL");
		$txaplmax = getByTagName($dados_resgate[$i]->tags,"TXAPLMAX");
		$txaplmin = getByTagName($dados_resgate[$i]->tags,"TXAPLMIN");
		$cddresga = getByTagName($dados_resgate[$i]->tags,"CDDRESGA");
		$dtresgat = getByTagName($dados_resgate[$i]->tags,"DTRESGAT");		
		$idtipapl = getByTagName($dados_resgate[$i]->tags,"IDTIPAPL");
		$tpresgat = getByTagName($dados_resgate[$i]->tags,"TPRESGAT");
				
		if($tpresgat == "P"){
			$tpresgat = 1;
		}else if($tpresgat == "T"){
			$tpresgat = 2;
		}
	?>	
		objResgatesManual = new Object();						
		objResgatesManual.nraplica = "<?php echo $nraplica; ?>";
		objResgatesManual.dtmvtolt = "<?php echo $dtmvtolt; ?>";
		objResgatesManual.dshistor = "<?php echo $dshistor; ?>";
		objResgatesManual.nrdocmto = "<?php echo $nrdocmto; ?>";
		objResgatesManual.dtvencto = "<?php echo $dtvencto; ?>";
		objResgatesManual.vllanmto = "<?php echo $vllanmto; ?>";
		objResgatesManual.sldresga = "<?php echo $sldresga; ?>";
		objResgatesManual.dssitapl = "<?php echo $dssitapl; ?>";
		objResgatesManual.txaplmax = "<?php echo $txaplmax; ?>";
		objResgatesManual.txaplmin = "<?php echo $txaplmin; ?>";
		objResgatesManual.cddresga = "<?php echo $cddresga; ?>";
		objResgatesManual.dtresgat = "<?php echo $dtresgat; ?>";
		objResgatesManual.idtipapl = "<?php echo $idtipapl; ?>";
		objResgatesManual.vlresgat = "0";
		objResgatesManual.tpresgat = "<?php echo $tpresgat; ?>";
		lstDadosResgate[<?php echo $i; ?>] = objResgatesManual;		
	<?php	
	}	
	
	?>
		var strHTML = "";
		
		strHTML +='<div class="divAplicacoesPrincipal">';
		strHTML += '	<fieldset>';
		strHTML += '	<legend align="center"><b>Selecione as Aplica&ccedil;&otilde;es </b></legend>';
		strHTML += '<div class="divRegistros">';
		strHTML += '		<table>';
		strHTML += '			<thead>';
		strHTML += '				<tr>';
		strHTML += '					<th></th>';
		strHTML += '                    <th><? echo utf8ToHtml('Data'); ?></th>';
		strHTML += '					<th><? echo utf8ToHtml('Hist&oacute;rico');  ?></th>';
		strHTML += '					<th><? echo utf8ToHtml('Docmto');  ?></th>';
		strHTML += '					<th><? echo utf8ToHtml('Vencto');  ?></th>';
		strHTML += '					<th><? echo utf8ToHtml('Saldo');  ?></th>';
		strHTML += '					<th><? echo utf8ToHtml('Sl Resgate');  ?></th>';
		strHTML += '				</tr>';
		strHTML += '			</thead>';
		strHTML += '			<tbody>';
	
		<?php
		
		for ($i = 0; $i < $dados_count; $i++){
	
			$nraplica = getByTagName($dados_resgate[$i]->tags,"NRAPLICA");
			$dtmvtolt = getByTagName($dados_resgate[$i]->tags,"DTMVTOLT");
			$dshistor = getByTagName($dados_resgate[$i]->tags,"DSHISTOR");
			$nrdocmto = getByTagName($dados_resgate[$i]->tags,"NRDOCMTO");
			$dtvencto = getByTagName($dados_resgate[$i]->tags,"DTVENCTO");
			$vllanmto = getByTagName($dados_resgate[$i]->tags,"VLLANMTO");
			$sldresga = getByTagName($dados_resgate[$i]->tags,"SLDRESGA");
			
		?>
			strHTML += '<tr id="trAplicacoesResgatadas<?php echo $i; ?>" style="cursor: pointer;" onClick="selecionaAplicacaoManual(\'<?php echo $i; ?>\',\'<?php echo $dados_count; ?>\',\'<?php echo $nraplica; ?>\');">';
			strHTML += '	<td><input type="checkbox" name="appresg<?php echo $i;?>" id="appresg<?php echo $i;?>" onClick="verificaVencimento(\'<?php echo $i; ?>\',\'<?php echo $glbvars["dtmvtolt"]; ?>\');">';
			strHTML += '</td>';
			strHTML += '	<td><?php echo $dtmvtolt; ?>';
			strHTML += '			<a href="#" id="linkApl<?php echo $i; ?>" style="cursor: default;" onClick="return false;"></a>';
			strHTML += '	</td>';
			strHTML += '	<td><?php echo $dshistor; ?>';
			strHTML += '	</td>';
			strHTML += '	<td><?php echo $nrdocmto; ?>';
			strHTML += '	</td>';
			strHTML += '	<td><?php echo $dtvencto; ?>';
			strHTML += '	</td>';
			strHTML += '	<td><?php echo number_format(str_replace(",",".",$vllanmto),2,",","."); ?>';
			strHTML += '	</td>';
			strHTML += '	<td><?php echo number_format(str_replace(",",".",$sldresga),2,",","."); ?>';
			strHTML += '	</td>';	
			strHTML += '</tr>';
		<?php
		}	
		
		?>
		
		strHTML += '			</tbody>';
		strHTML += '		</table>';		
		
		strHTML += '</div>';
		
		strHTML += '<ul class="complemento">';
		strHTML += '<li>Sit:</li>';
		strHTML += '<li id="tdSitM"></li>';
		strHTML += '<li>Tx.Ctr:</li>';
		strHTML += '<li id="tdTxCtrM"></li>';
		strHTML += '<li>Tx.Min:</li>';
		strHTML += '<li id="tdTxMinM"></li>';
		strHTML += '<li>Resg:</li>';
		strHTML += '<li id="tdResgM"></li>';
		strHTML += '<li>Dt.Resg:</li>';
		strHTML += '<li id="tdDtResgM"></li>';
		strHTML += '</ul>';
		
		//strHTML += '<div id="divDadosResgate">';
		strHTML += '<ul class="complemento">';
		
		//strHTML += '		<a href="#" class="botao" id="btParcial" onClick="resgataValorParcial();return false;">Parcial</a>';
							
		strHTML += '<li>Informado:</li>';
		strHTML += '<li id="tdTotInf"></li>';
		strHTML += '<li>Total selecionado:</li>';
		strHTML += '<li id="tdTotSel"></li>';
		strHTML += '<li>Diferen&ccedil;a:</li>';
		strHTML += '<li id="tdDifer"></li>';
		strHTML += '</ul>';
		//strHTML += '</div>';		
		
		strHTML += '  <div id="divBotoes">';
		strHTML += '	<a href="#" class="botao" id="btCancelar" onClick="voltarDivResgateAutoManual(\'false\');return false;">Cancelar</a>';
		strHTML += '	<a href="#" class="botao" id="btConcluir" onClick="validaDiferenca(\'manual\',\'yes\',\'<?php echo $nrdconta; ?>\',\'<?php echo $dataresg; ?>\',\'<?php echo $flgctain; ?>\');return false;">Concluir</a>';
		strHTML += '  </div>';
		
		strHTML += '	</fieldset>';
		strHTML += '</div>';		
		
		$("#divAutoManual").html(strHTML);
		formataTabelaResgateManual();
		$("#divOpcoes").css("display","none");
		$("#divAutoManual").css("display","block");
		hideMsgAguardo();
		blockBackground(parseInt($("#divRotina").css("z-index")));
		
		<?php if($i > 0){?>
			selecionaAplicacaoManual(<?php echo ($i - 1); ?>,<?php echo $dados_count; ?>,<?php echo $nraplica; ?>);				
		<?php }?>
		
		$("#tdTotInf").html("<?php echo number_format(str_replace(",",".",$vltotrgt),2,",","."); ?>");
		$("#tdTotSel").html("0,00");
		$("#tdDifer").html("<?php echo number_format(str_replace(",",".",$vltotrgt),2,",","."); ?>");
		
		$("#tdTotInf", "#divDadosResgate").setMask("DECIMAL","zzz.zzz.zz9,99","","");
		$("#tdTotSel", "#divDadosResgate").setMask("DECIMAL","zzz.zzz.zz9,99","","");
		$("#tdDifer", "#divDadosResgate").setMask("DECIMAL","zzz.zzz.zz9,99","","");		