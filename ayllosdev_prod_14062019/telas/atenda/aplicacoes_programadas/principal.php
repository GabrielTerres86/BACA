<?php 

	/***************************************************************************
	 Fonte: principal.php                                             
	 Autor: David                                                     
	 Data : Março/2010                   Última Alteração: 27/07/2018
	                                                                  
	 Objetivo  : Mostrar opcao Principal da rotina de Aplicações Programadas da    
	             tela ATENDA                                          
	                                                                  	 
	 Alterações: 13/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)
	 *
	 *			 09/07/2012 - Retirado campo "redirect" popup. (Jorge)
	 *
	 *			 04/06/2013 - Incluir b1wgen0155 e ul complemento (Lucas R.)
	 
	             30/09/2015 - Ajuste para inclusão das novas telas "Produtos"
						     (Gabriel - Rkam -> Projeto 217).	

                 27/11/2017 - Inclusao do valor de bloqueio em garantia.
                              PRJ404 - Garantia Empr.(Odirlei-AMcom) 
						  
				 01/12/2017 - Não permitir acesso a opção de incluir quando conta demitida (Jonata - RKAM P364).
						  
                 29/01/2018 - Ajuste no layout dos campos de valor de bloqueio.
				 
				 27/07/2018 - Derivação para Aplicação Programada (Proj. 411.2 - CIS Corporate)
						  
	***************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se número da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$sitaucaoDaContaCrm = (isset($_POST['sitaucaoDaContaCrm'])?$_POST['sitaucaoDaContaCrm']:'');

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	
	//Monta o xml de requisição - Via mensageria 
	$xmlLstPoupancas = "<Root>";
	$xmlLstPoupancas .= " <Dados>";
	$xmlLstPoupancas .= "	<nrdconta>".$nrdconta."</nrdconta>";
	$xmlLstPoupancas .= "	<idseqttl>1</idseqttl>";
	$xmlLstPoupancas .= "	<nrctrrpp>0</nrctrrpp>";
	$xmlLstPoupancas .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlLstPoupancas .= "	<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlLstPoupancas .= "	<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlLstPoupancas .= "   <flgerlog>1</flgerlog>";
	$xmlLstPoupancas .= "   <percenir>0</percenir>";
	$xmlLstPoupancas .= "   <tpapprog>0</tpapprog>";
	$xmlLstPoupancas .= " </Dados>";
	$xmlLstPoupancas .= "</Root>";
	$xmlResultLst = mensageria($xmlLstPoupancas, "APLI0008", "LISTA_CONTAS_POUPANCA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");


	$xmlObjPoupancas = getObjectXML($xmlResultLst);
	if (strtoupper($xmlObjPoupancas->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjPoupancas->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObjPoupancas->roottag->tags[0]->cdata;
		}
		exibeErro($msgErro);
		exit();
	}
	
	
	$poupancas   = $xmlObjPoupancas->roottag->tags[0]->tags;	
	$qtPoupancas = count($poupancas);

	/*
	
	// Monta o xml de requisição - antigo
	$xmlGetPoupancas  = "";
	$xmlGetPoupancas .= "<Root>";
	$xmlGetPoupancas .= "	<Cabecalho>";
	$xmlGetPoupancas .= "		<Bo>b1wgen0006.p</Bo>";
	$xmlGetPoupancas .= "		<Proc>consulta-poupanca</Proc>";
	$xmlGetPoupancas .= "	</Cabecalho>";
	$xmlGetPoupancas .= "	<Dados>";
	$xmlGetPoupancas .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetPoupancas .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetPoupancas .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetPoupancas .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetPoupancas .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetPoupancas .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";		
	$xmlGetPoupancas .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetPoupancas .= "		<idseqttl>1</idseqttl>";
	$xmlGetPoupancas .= "		<nrctrrpp>0</nrctrrpp>";
	$xmlGetPoupancas .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetPoupancas .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlGetPoupancas .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlGetPoupancas .= "		<cdprogra>".$glbvars["nmdatela"]."</cdprogra>";
	$xmlGetPoupancas .= "	</Dados>";
	$xmlGetPoupancas .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetPoupancas);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjPoupancas = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjPoupancas->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjPoupancas->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$poupancas   = $xmlObjPoupancas->roottag->tags[0]->tags;	
	$qtPoupancas = count($poupancas);

	//Traz as informações atualizadas nas novas captacoes - verificar se não podemos melhorar o desempenho - remover
	for ($i = 0; $i < $qtPoupancas; $i++) { 
		if ($poupancas[$i]->tags[27]->cdata>0) {
			// Nova aplicacao programada 
			$xmlDet = "<Root>";
			$xmlDet .= " <Dados>";
			$xmlDet .= "  <nrdconta>".$nrdconta."</nrdconta>";    
			$xmlDet .= "  <idseqttl>1</idseqttl>";    
			$xmlDet .= "  <nrctrrpp>".$poupancas[$i]->tags[0]->cdata."</nrctrrpp>";
			$xmlDet .= "  <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";			
			$xmlDet .= " </Dados>";
			$xmlDet .= "</Root>";
			$xmlResultDet = mensageria($xmlDet, "APLI0008", "SALDO_APL_PGM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			$xmlObjDet = getObjectXML($xmlResultDet);
			if (strtoupper($xmlObjDet->roottag->tags[0]->name) == "ERRO") {
				$msgErro = $xmlObjDet->roottag->tags[0]->tags[0]->tags[4]->cdata;
				if ($msgErro == "") {
					$msgErro = $xmlObjDet->roottag->tags[0]->cdata;
				}
				exibeErro($msgErro);
				exit();
			}
			$poupancas[$i]->tags[11]->cdata=$xmlObjDet->roottag->tags[0]->tags[0]->tags[0]->cdata; //Saldo
		}
	}
	*/
	
	// Procura indíce da opção "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	if ($idPrincipal === false) {
		$idPrincipal = 0;
	}		

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
	 // Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0155.p</Bo>";
	$xml .= "		<Proc>retorna-valor-blqjud</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<nrcpfcgc>0</nrcpfcgc>";
	$xml .= "		<cdtipmov>0</cdtipmov>";
	$xml .= "		<cdmodali>3</cdmodali>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
		// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjBlqJud = getObjectXML($xmlResult);
	
	$vlbloque = $xmlObjBlqJud->roottag->tags[0]->attributes['VLBLOQUE']; 
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjBlqJud->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjBlqJud->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "  <nrdconta>".$nrdconta."</nrdconta>";    
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "BLOQ0001", "CALC_BLOQ_GARANTIA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
        }

        exibeErro($msgErro);
        exit();
    }

    $registros = $xmlObj->roottag->tags[0]->tags;
    $vlblqpou  = getByTagName($registros, 'vlblqpou');	
    
?>
<?/**/?>
<div id="divPoupancasPrincipal">
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th>Data</th>
					<th>Finalidade</th>
					<th>Contrato</th>
					<th>Dia</th>
					<th>Presta&ccedil;&atilde;o</th>
					<th>Saldo</th>	
					<th>Situa&ccedil;&atilde;o</th>
					<th>Blq</th>
					<th>CI</th>						
					<th>Resg</th>
				</tr>			
			</thead>
			<tbody>
				<?  for ($i = 0; $i < $qtPoupancas; $i++) { 
												
						$mtdClick = "selecionaAplicacao('".$i."','".$qtPoupancas."','".$poupancas[$i]->tags[0]->cdata."','".$poupancas[$i]->tags[24]->cdata."','".$poupancas[$i]->tags[26]->cdata."','".$poupancas[$i]->tags[27]->cdata."');";
					?>
					
					<tr id="trPoupanca<?php echo $i; ?>" onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>">
						
						<td><?php echo $poupancas[$i]->tags[4]->cdata; ?></td>
						
						<td><?php echo $poupancas[$i]->tags[28]->cdata; ?></td>
						
						<td align="right"><?php echo number_format($poupancas[$i]->tags[0]->cdata,0,",","."); ?></td>
						
						<td align="center"><?php echo $poupancas[$i]->tags[7]->cdata; ?></td>
						
						<td align="right"><?php echo number_format(str_replace(",",".",$poupancas[$i]->tags[8]->cdata),2,",","."); ?></td>
						
						<td align="right"><?php if ($poupancas[$i]->tags[24]->cdata == 0) { echo number_format(str_replace(",",".",$poupancas[$i]->tags[11]->cdata),2,",","."); } else { echo ""; } ?></td>
						
						<td><?php echo $poupancas[$i]->tags[19]->cdata; ?></td>
						
						<td align="center"><?php echo $poupancas[$i]->tags[20]->cdata; ?></td>
						
						<td align="center"><?php echo $poupancas[$i]->tags[22]->cdata; ?></td>
						
						<td align="center"><?php echo $poupancas[$i]->tags[21]->cdata; ?></td>
						
					</tr>
				<?} // Fim do for ?>			
			</tbody>
		</table>
	</div>
	
	<ul class="complemento" align="left">
		<div style="float: left; text-align: left; width: 50%;">
			<label class="txtNormalBold">Valor Bloq. Judicial:</label>
			<label><? echo number_format(str_replace(",",".", $vlbloque),2,",","."); ?></label>
		</div>
		<div style="float: right; text-align: right; width: 50%;">
			<label class="txtNormalBold">Valor Bloq. Garantia:</label>
			<label><? echo number_format(str_replace(",",".", $vlblqpou),2,",","."); ?></label>
		</div>
	</ul>
	
	<div id="divBotoes">
		<input type="image" id="btnAlterar" name="btnAlterar" src="<?php echo $UrlImagens; ?>botoes/alterar.gif" <?php if (!in_array("A",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="acessaOpcaoAlterar();return false;"'; } ?> />
		<input type="image" id="btnCancelar" name="btnCancelar" src="<?php echo $UrlImagens; ?>botoes/cancelar.gif" <?php if (!in_array("X",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="acessaOpcaoCancelar();return false;"'; } ?> />
		<input type="image" id="btnConsultar" name="btnConsultar" src="<?php echo $UrlImagens; ?>botoes/consultar.gif" <?php if (!in_array("C",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="consultarPoupanca();return false;"'; } ?> />
		<input type="image" id="btnImprimir" name="btnImprimir" src="<?php echo $UrlImagens; ?>botoes/imprimir.gif" <?php if (!in_array("M",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="imprimirAutorizacao(\'\',\'\',\'\');return false;"'; } ?> />
		
		<?php if(!($sitaucaoDaContaCrm == '4' || 
				   $sitaucaoDaContaCrm == '7' || 
				   $sitaucaoDaContaCrm == '8'  )){?>

			<input type="image" id="btnIncluir" name="btnIncluir" src="<?php echo $UrlImagens; ?>botoes/incluir.gif" <?php if (!in_array("I",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="acessaOpcaoIncluir();return false;"'; } ?> />
		
		<?}?>
		
		<input type="image" id="btnReativar" name="btnReativar" src="<?php echo $UrlImagens; ?>botoes/reativar.gif" <?php if (!in_array("R",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="acessaOpcaoReativar();return false;"'; } ?> />
		<input type="image" id="btnResgate" name="btnResgate" src="<?php echo $UrlImagens; ?>botoes/resgate.gif" <?php if (!in_array("G",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="acessaOpcaoResgate();return false;"'; } ?> />
		<input type="image" id="btnSuspender" name="btnSuspender" src="<?php echo $UrlImagens; ?>botoes/suspender.gif" <?php if (!in_array("S",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="acessaOpcaoSuspender();return false;"'; } ?> />
	</div>
</div>

<div id="divResgate">
	<div id="divBotoes">
		<form class="formulario">
			<fieldset>
				<legend><? echo utf8ToHtml('Resgates') ?></legend>
				<div style="margin:65px 0px;">
					<input type="image" id="btnVoltarPrincipal" name="btnVoltarPrincipal" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltarDivPrincipal();return false;" />
					<input type="image" src="<?php echo $UrlImagens; ?>botoes/resgate.gif" onClick="acessaOpcaoEfetuarResgate();return false;" />
					<input type="image" src="<?php echo $UrlImagens; ?>botoes/cancelamento.gif" onClick="obtemResgates('yes');return false;" />
					<input type="image" src="<?php echo $UrlImagens; ?>botoes/proximos.gif" onClick="obtemResgates('no');return false;" />
				</div>
			</fieldset>
		</form>
	</div>
</div>

<div id="divOpcoes"></div>
<form action="<?php echo $UrlSite; ?>telas/atenda/aplicacoes_programadas/aplicacoes_programadas_autorizacao.php" name="frmAutorizacao" id="frmAutorizacao" method="post">
<input type="hidden" name="nrdconta" id="nrdconta" value="">
<input type="hidden" name="nrdrowid" id="nrdrowid" value="">
<input type="hidden" name="cdtiparq" id="cdtiparq" value="">
<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>		
<script type="text/javascript"> 
	controlaLayout('divPoupancasPrincipal');

	// Aumenta tamanho do div onde o conteúdo da opção será visualizado
	$("#divConteudoOpcao").css("height","225px");

	$("#btnVoltarPrincipal").unbind("click");
	$("#btnVoltarPrincipal").bind("click",function() {
		if (flgoprgt) {
			acessaOpcaoAba(<?php echo count($glbvars["opcoesTela"]); ?>,<?php echo $idPrincipal; ?>,'<?php echo $glbvars["opcoesTela"][$idPrincipal]; ?>');		
		} else {
			voltarDivPrincipal();
		}
		
		return false;
	}); 

	<?php if (in_array("A",$glbvars["opcoesTela"])) { ?>
		$("#btnAlterar").unbind("mouseover");
		$("#btnAlterar").bind("mouseover",function() { 		
			$(this).css("cursor",(cdtiparq == 0 ? "pointer" : "default"));
		}); 
	<?php } ?>
	<?php if (in_array("X",$glbvars["opcoesTela"])) { ?>
		$("#btnCancelar").unbind("mouseover");
		$("#btnCancelar").bind("mouseover",function() { 		
			$(this).css("cursor",(cdtiparq == 0 ? "pointer" : "default"));
		}); 
	<?php } ?>
	<?php if (in_array("C",$glbvars["opcoesTela"])) { ?>
		$("#btnConsultar").unbind("mouseover");
		$("#btnConsultar").bind("mouseover",function() { 		
			$(this).css("cursor",(cdtiparq == 0 ? "pointer" : "default"));
		}); 
	<?php } ?>
	<?php if (in_array("R",$glbvars["opcoesTela"])) { ?>
		$("#btnReativar").unbind("mouseover");
		$("#btnReativar").bind("mouseover",function() { 		
			$(this).css("cursor",(cdtiparq == 0 ? "pointer" : "default"));
		}); 
	<?php } ?>
	<?php if (in_array("G",$glbvars["opcoesTela"])) { ?>
		$("#btnResgate").unbind("mouseover");
		$("#btnResgate").bind("mouseover",function() { 		
			$(this).css("cursor",(cdtiparq == 0 ? "pointer" : "default"));
		}); 
	<?php } ?>
	<?php if (in_array("S",$glbvars["opcoesTela"])) { ?>
		$("#btnSuspender").unbind("mouseover");
		$("#btnSuspender").bind("mouseover",function() { 		
			$(this).css("cursor",(cdtiparq == 0 ? "pointer" : "default"));
		}); 
	<?php } ?>

	$("#divPoupancasPrincipal").css("display","block");	
	$("#divResgate").css("display","none");
	$("#divOpcoes").css("display","none");


	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));	

	//Se esta tela foi chamada através da rotina "Produtos" então acessa a opção conforme definido pelos responsáveis do projeto 217
	(executandoProdutos == true) ? acessaOpcaoIncluir() : "";
		
</script>
