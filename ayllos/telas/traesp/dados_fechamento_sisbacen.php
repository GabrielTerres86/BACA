<?php
	//*********************************************************************          ***//
	//*** Fonte: dados_fechamento_sisbacen.php                                       ***//
	//*** Autor: Fabricio                                                            ***//
	//*** Data : Maio/2012                 Ultima Alteracao: 15/08/2013              ***//
	//***                                                                            ***//
	//*** Objetivo  : Mostrar dados das cooperativas para realizar o fechamento.     ***//
	//***			  							     								 ***//
	//***             		                                                         ***//
	//*** Alteracoes: 15/08/2013 - Alteração da sigla PAC para PA (Carlos)           ***//
	//***                                        							         ***//
	//***                                        		                             ***//
	//***                                        					                 ***//
	//*********************************************************************          ***//
	
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	$cdcooper = $_POST["cdcooper"];
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo '$("#divDadosConfirmaSisbacen").html("");';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos");';
		exit();
	}
	
	
	// Monta o xml de requisição
	$xmlDadosFechamento  = "";
	$xmlDadosFechamento .= "<Root>";
	$xmlDadosFechamento .= "	<Cabecalho>";
	$xmlDadosFechamento .= "		<Bo>b1wgen0135.p</Bo>";
	$xmlDadosFechamento .= "		<Proc>consulta-dados-fechamento</Proc>";
	$xmlDadosFechamento .= "	</Cabecalho>";
	$xmlDadosFechamento .= "	<Dados>";
	$xmlDadosFechamento .= "		<cdcooper>".$cdcooper."</cdcooper>";
	$xmlDadosFechamento .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlDadosFechamento .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlDadosFechamento .= "	</Dados>";
	$xmlDadosFechamento .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlDadosFechamento);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjFechamento = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjFechamento->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjFechamento->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	// Procura indíce da opção "F"
	$idPrincipal = array_search("F",$glbvars["opcoesTela"]);
	
	if ($idPrincipal == false) {
		$idPrincipal = 0;
	}

	$dados_fechamento = $xmlObjFechamento->roottag->tags[0]->tags;
	$total_registros = $xmlObjFechamento->roottag->tags[0]->attributes["NRTOTREG"];
	$dados_count = count($dados_fechamento);
	
	?>
	lstDadosFechamento = new Array(); // Inicializar lista dos dados de fechamento para o SISBACEN
	
	<?php
	
	for ($i = 0; $i < $dados_count; $i++){
		$cdcooper = getByTagName($dados_fechamento[$i]->tags,"CDCOOPER");
		$cdagenci = getByTagName($dados_fechamento[$i]->tags,"CDAGENCI");
		$nrdconta = getByTagName($dados_fechamento[$i]->tags,"NRDCONTA");
		$nmprimtl = substr(getByTagName($dados_fechamento[$i]->tags,"NMPRIMTL"), 0, 50);
		$nrdocmto = getByTagName($dados_fechamento[$i]->tags,"NRDOCMTO");
		$tpoperac = getByTagName($dados_fechamento[$i]->tags,"TPOPERAC");
		$recursos = getByTagName($dados_fechamento[$i]->tags,"RECURSOS");
		$dstrecur = getByTagName($dados_fechamento[$i]->tags,"DSTRECUR");
		
		if (getByTagName($dados_fechamento[$i]->tags,"FLINFDST") == "yes")
			$flinfdst = "SIM";
		else
			$flinfdst = "NAO";
			
		$vllanmto = getByTagName($dados_fechamento[$i]->tags,"VLLANMTO");
		$dtmvtolt = getByTagName($dados_fechamento[$i]->tags,"DTMVTOLT");
		$infrepcf = getByTagName($dados_fechamento[$i]->tags,"INFREPCF");
		$dsdjusti = getByTagName($dados_fechamento[$i]->tags,"DSDJUSTI");
		
		$nrdrowid = getByTagName($dados_fechamento[$i]->tags,"NRDROWID");
		
	?>
	
		objDadosFechamento = new Object();						
		objDadosFechamento.cdcooper = "<?php echo $cdcooper; ?>";
		objDadosFechamento.cdagenci = "<?php echo $cdagenci; ?>";
		objDadosFechamento.nrdconta = "<?php echo $nrdconta; ?>";
		objDadosFechamento.nmprimtl = "<?php echo $nmprimtl; ?>";
		objDadosFechamento.nrdocmto = "<?php echo $nrdocmto; ?>";
		objDadosFechamento.tpoperac = "<?php echo $tpoperac; ?>";
		objDadosFechamento.recursos = "<?php echo $recursos; ?>";
		objDadosFechamento.dstrecur = "<?php echo $dstrecur; ?>";
		objDadosFechamento.flinfdst = "<?php echo $flinfdst; ?>";
		objDadosFechamento.vllanmto = "<?php echo $vllanmto; ?>";
		objDadosFechamento.dtmvtolt = "<?php echo $dtmvtolt; ?>";
		objDadosFechamento.infrepcf = "<?php echo $infrepcf; ?>";
		objDadosFechamento.dsdjusti = "<?php echo $dsdjusti; ?>";
		objDadosFechamento.nrdrowid = "<?php echo $nrdrowid; ?>";
		lstDadosFechamento[<?php echo $i; ?>] = objDadosFechamento;
		
	<?php
	
	}
	
	?>
		var strHTML = "";

		strHTML +='<div class="divRegistrosFechamento">';
		strHTML += '	<fieldset>';
		strHTML += '	<legend align="center"><b>Selecione os Registros Desejados</b></legend>';
		strHTML += '<div class="divRegistros">';
		strHTML += '		<table>';
		strHTML += '			<thead>';
		strHTML += '				<tr>';
		strHTML += '					<th> <input type="checkbox" name="chktodos" id="chktodos" onClick="marcaTodos(\'<?php echo $dados_count; ?>\');"> </th>';
		strHTML += '                    <th><? echo utf8ToHtml('Coop'); ?></th>';
		strHTML += '					<th><? echo utf8ToHtml('PA');  ?></th>';
		strHTML += '					<th><? echo utf8ToHtml('Conta');  ?></th>';
		strHTML += '					<th><? echo utf8ToHtml('Docmto');  ?></th>';
		strHTML += '					<th><? echo utf8ToHtml('Opera&ccedil;&atilde;o');  ?></th>';
		strHTML += '					<th><? echo utf8ToHtml('Valor');  ?></th>';
		strHTML += '					<th><? echo utf8ToHtml('COAF');  ?></th>';
		strHTML += '				</tr>';
		strHTML += '			</thead>';
		strHTML += '			<tbody>';
	
		<?php
		
		for ($i = 0; $i < $dados_count; $i++){
	
			$cdcooper = getByTagName($dados_fechamento[$i]->tags,"CDCOOPER");
			$cdagenci = getByTagName($dados_fechamento[$i]->tags,"CDAGENCI");
			$nrdconta = getByTagName($dados_fechamento[$i]->tags,"NRDCONTA");
			$nrdocmto = getByTagName($dados_fechamento[$i]->tags,"NRDOCMTO");
			$tpoperac = getByTagName($dados_fechamento[$i]->tags,"TPOPERAC");
			$vllanmto = getByTagName($dados_fechamento[$i]->tags,"VLLANMTO");
			$infrepcf = getByTagName($dados_fechamento[$i]->tags,"INFREPCF");
			
		?>
			strHTML += '<tr id="trRegistros<?php echo $i; ?>" style="cursor: pointer;" onClick="selecionaRegistro(\'<?php echo $i; ?>\',\'<?php echo $dados_count; ?>\');">';
			strHTML += '	<td><input type="checkbox" class="checkbox" name="appreg<?php echo $i; ?>" id="appreg<?php echo $i; ?>" onClick="verificaInfoCoaf(\'<?php echo $i; ?>\',\'<?php echo $dados_count; ?>\')">';
			strHTML += '	</td>';
			strHTML += '	<td><?php echo $cdcooper; ?>';
			strHTML += '	</td>';
			strHTML += '	<td><?php echo $cdagenci; ?>';
			strHTML += '	</td>';
			strHTML += '	<td><?php echo $nrdconta; ?>';
			strHTML += '	</td>';
			strHTML += '	<td><?php echo $nrdocmto; ?>';
			strHTML += '	</td>';
			strHTML += '	<td><?php echo $tpoperac; ?>';
			strHTML += '	</td>';
			strHTML += '	<td><?php echo number_format(trim(str_replace(",",".",$vllanmto)),2,",","."); ?>';
			strHTML += '	</td>';
			strHTML += '	<td><?php echo $infrepcf; ?>';
			strHTML += '	</td>';
			strHTML += '</tr>';
		<?php
		}
		
		?>
		
		strHTML += '			</tbody>';
		strHTML += '		</table>';
		
		
		strHTML += '</div>';
		
		strHTML += '<div id="divPesquisaRodapeFechamento" class="divPesquisaRodape">';
		strHTML += '	<table cellspacing="3px" cellpadding="3px">';
		strHTML += '		<tr>';
		strHTML += '			<td>';
		strHTML += '				 &nbsp;';
		strHTML += '			</td>';
		strHTML += '			<td>';
		strHTML += '				<div width="350px" style="margin-left:auto; margin-right:auto;">';
		strHTML += '					 Exibindo 1 at&eacute; <? echo $total_registros; ?> de <? echo $total_registros; ?>';
		strHTML += '				</div>';
		strHTML += '			</td>';
		strHTML += '			<td>';
		strHTML += '				&nbsp;';
		strHTML += '			</td>';
		strHTML += '		</tr>';
		strHTML += '	</table>';
		strHTML += '</div>';
		
		strHTML += '<ul class="complemento">';
		
		strHTML += '<li>Cooperado:</li>';
		strHTML += '<li id="tdNmprimtl"></li>';
		strHTML += '<li>Data:</li>';
		strHTML += '<li id="tdDtmvtolt"></li>';
		
		strHTML += '<li>Informações foram prestadas:</li>';
		strHTML += '<li id="tdFlinfdst"></li>';
		strHTML += '<li>Origem:</li>';
		strHTML += '<li id="tdRecursos"></li>';
		strHTML += '<li>Destino:</li>';
		strHTML += '<li id="tdDstrecur"></li>';
		strHTML += '</ul>';
		
		strHTML += '	</fieldset>';
		strHTML += '</div>';
		
		
		
		$("#divDadosConfirmaSisbacen").html(strHTML);
		formataTabelaFechamento();
		$("#divPesquisaRodapeFechamento").formataRodapePesquisa();
		
		$('#justific','#divDadosConfirmaSisbacen').unbind('keypress').bind('keypress', function(e) {
			if (divError.css('display') == 'block') { return false; }
			// Se é a tecla ENTER
			if (e.keyCode == 13) {
				confirmaDadosSisbacen(0,false);
				return false;
			}
		});
		
		$("#divDadosConfirmaSisbacen").css("display","block");
		selecionaRegistro(0,<?php echo $dados_count; ?>);
		hideMsgAguardo();
		