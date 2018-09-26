<?php 

	/************************************************************************
	    Fonte: extrato_exibir.php
	    Autor: Guilherme/Supero
	    Data :                              Última Alteração: 15/12/2011

	    Objetivo  : Listar o Extrato do Cartao Cecred Visa

        Alterações: 15/12/2011 - Ajustado a tabela de listagem do extratos 
								(Adriano).
              

	  ************************************************************************/

	session_start();

	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"T")) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro',$funcaoAposErro);
	}
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrcrcard"]) || !isset($_POST["dtextrat"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro',$funcaoAposErro);
	}

	$nrcrcard = $_POST["nrcrcard"];
	$nrdconta = $_POST["nrdconta"];
	$dtextrat = $_POST["dtextrat"];
	
	$dtperiod = $dtextrat;
	$dtextrat = explode("/",$dtextrat);
	$dtvctini = date("d/m/Y", mktime(0, 0, 0, $dtextrat[0], 1, $dtextrat[1])); // Primeiro data do mes
    $dtvctfim = date("t/m/Y", mktime(0, 0, 0, $dtextrat[0], 1, $dtextrat[1])); // Ultimo data do mes
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisição
	$xmlSetExtrato  = "";
	$xmlSetExtrato .= "<Root>";
	$xmlSetExtrato .= "	<Cabecalho>";
	$xmlSetExtrato .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetExtrato .= "		<Proc>extrato_cartao_bradesco</Proc>";
	$xmlSetExtrato .= "	</Cabecalho>";
	$xmlSetExtrato .= "	<Dados>";
	$xmlSetExtrato .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetExtrato .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetExtrato .= "		<nrcrcard>".$nrcrcard."</nrcrcard>";
	$xmlSetExtrato .= "		<dtvctini>".$dtvctini."</dtvctini>";
	$xmlSetExtrato .= "		<dtvctfim>".$dtvctfim."</dtvctfim>";
	$xmlSetExtrato .= "	</Dados>";
	$xmlSetExtrato .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetExtrato);

	// Cria objeto para classe de tratamento de XML
	$xmlObjExtrato = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjExtrato->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjExtrato->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Seta a tag de lancamentos para a variavel
	$lancamentos = $xmlObjExtrato->roottag->tags[0]->tags;
	
	if (count($lancamentos) == 0) {
		exibeErro("FATURA NÃO ENCONTRADA!");
	}

	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) {
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
	$nmprimtl     = getByTagName($lancamentos[0]->tags,"nmprimtl");
	$nmtitcrd     = getByTagName($lancamentos[0]->tags,"nmtitcrd");
	$vllimite     = getByTagName($lancamentos[0]->tags,"vllimite");
	$tot_vlcrdolr = 0;
	$tot_vldbdolr = 0;
	$tot_vlcrreal = 0;
	$tot_vldbreal = 0;
?>
<script type="text/javascript">
	$(function(){
		$("#btVoltarExtrato").click(function(){
			$("#divImpressaoCartao").css("display","none");
			$("#divExtratoDetalhe").css("width","517px");
			$("#divImpressaoCartao").css("width","517px");
			$("#divExtrato").css("display","block");			
			$("#divBotoes2").css("display","none");
		})
	})
</script>
<div id="divImpressaoCartao">
<br />
<div class="divTituloExtrato">
	<table width="100%">
		<tr>
			<td align="Center"><b><? echo utf8ToHtml('EXTRATO CART&Atilde;O DE CR&Eacute;DITO CECRED VISA')?></b>
			</td>
		</tr>
	</table>
</div>
<br />
<div class="divCabecalho">
	<table width="100%">
		<tr>
			<td align="right"><label for="nrdconta"><? echo utf8ToHtml('Conta/DV:')?></label></td>
			<td> <? echo formataNumericos("zzzz.zzz-9",$nrdconta,".-");  ?></td>
			<td align="right"><label for="nmprimtl"><? echo utf8ToHtml('Nome:')?></label></td>
			<td> <? echo $nmprimtl; ?></td>
		</tr>
		<tr>
			<td align="right"><label for="nrcrcard"><? echo utf8ToHtml('Cart&atilde;o:')?></label></td>
			<td> <? echo formataNumericos("9999.9999.9999.9999",$nrcrcard,".-"); ?></td>
			<td align="right"><label for="nmtitcrd"><? echo utf8ToHtml('Portador:')?></label></td>
			<td> <? echo $nmtitcrd; ?></td>
		</tr>
			<td align="right"><label for="dtperiod"><? echo utf8ToHtml('Per&iacute;odo:')?></label></td>
			<td> <? echo $dtperiod; ?></td>
			<td align="right"><label for="vllimite"><? echo utf8ToHtml('Limite:')?></label></td>
			<td> R$ <? echo number_format(str_replace(",",".",$vllimite),2,",","."); ?></td>
		</tr>
	</table>
</div>
<BR/>
<BR/>
<div class="divRegistros">
	<table>
		<thead>
			<tr>
				<th> <? echo utf8ToHtml('Data'); ?></th>
				<th> <? echo utf8ToHtml('Descri&ccedil;&atilde;o');  ?></th>
				<th> <? echo utf8ToHtml('Cidade');  ?></th>
				<th> <? echo utf8ToHtml('Cr&eacute;dito(US$)');  ?></th>
				<th> <? echo utf8ToHtml('D&eacute;bito(US$)');  ?></th>
				<th> <? echo utf8ToHtml('Cr&eacute;dito(R$)');  ?></th>
				<th> <? echo utf8ToHtml('D&eacute;bito(R$)');  ?></th>				
			</tr>
		</thead>
		<tbody>
			<?
			for ($i = 0; $i < count($lancamentos); $i++) {
				if  (getByTagName($lancamentos[$i]->tags,"cdmoedtr") == "R$") {
					$vlcrdolr = 0;
					$vldbdolr = 0;
				   if  (getByTagName($lancamentos[$i]->tags,"indebcre") == "C") {
					   $vlcrreal = getByTagName($lancamentos[$i]->tags,"vlcparea");
					   $vldbreal = 0;
				   }
				   else {
					   $vlcrreal = 0;
					   $vldbreal = getByTagName($lancamentos[$i]->tags,"vlcparea");
					}
			   }
			   else {
				   if  (getByTagName($lancamentos[$i]->tags,"indebcre") == "C") {
					   $vlcrreal = getByTagName($lancamentos[$i]->tags,"vlcparea");
					   $vldbreal = 0;
					   $vlcrdolr = getByTagName($lancamentos[$i]->tags,"vlcpaori");
					   $vldbdolr = 0;
				   }
				   else {
					   $vlcrreal = 0;
					   $vldbreal = getByTagName($lancamentos[$i]->tags,"vlcparea");
					   $vlcrdolr = 0;
					   $vldbdolr = getByTagName($lancamentos[$i]->tags,"vlcpaori");
					}
				}
				$vlcrdolr = str_replace(",",".",$vlcrdolr);
				$vldbdolr = str_replace(",",".",$vldbdolr);
				$vlcrreal = str_replace(",",".",$vlcrreal);
				$vldbreal = str_replace(",",".",$vldbreal);
?>
				<tr>
					<td><span><? echo getByTagName($lancamentos[$i]->tags,"dtcompra");  ?></span><? echo getByTagName($lancamentos[$i]->tags,"dtcompra");  ?>	</td>
					<td><span><? echo getByTagName($lancamentos[$i]->tags,"dsestabe"); ?></span><? echo getByTagName($lancamentos[$i]->tags,"dsestabe"); ?></td>
					<td><span><? echo getByTagName($lancamentos[$i]->tags,"nmcidade"); ?></span><? echo getByTagName($lancamentos[$i]->tags,"nmcidade"); ?></td>
					<td><span><? echo number_format(str_replace(",",".",$vlcrdolr),2,",","."); ?></span><? echo number_format(str_replace(",",".",$vlcrdolr),2,",","."); ?></td>
					<td><span><? echo number_format(str_replace(",",".",$vldbdolr),2,",","."); ?></span><? echo number_format(str_replace(",",".",$vldbdolr),2,",","."); ?></td>
					<td><span><? echo number_format(str_replace(",",".",$vlcrreal),2,",","."); ?></span><? echo number_format(str_replace(",",".",$vlcrreal),2,",","."); ?></td>
					<td><span><? echo number_format(str_replace(",",".",$vldbreal),2,",","."); ?></span><? echo number_format(str_replace(",",".",$vldbreal),2,",","."); ?></td>

				</tr>
<? 				$tot_vlcrdolr += $vlcrdolr;
				$tot_vldbdolr += $vldbdolr;
				$tot_vlcrreal += $vlcrreal;
				$tot_vldbreal += $vldbreal;
				
			} 
			$saldoFinal = $tot_vldbreal - $tot_vlcrreal;
?>	
				<tr>
					<td colspan="3"><div align="right"><label><span><? echo utf8ToHtml('TOTAL');  ?></span><? echo utf8ToHtml('TOTAL');  ?></label></div></td>
					<td><label><span><? echo number_format($tot_vlcrdolr,2,",",".");?></span><? echo number_format($tot_vlcrdolr,2,",",".");?></label></td>
					<td><label><span><? echo number_format($tot_vldbdolr,2,",",".");?></span><? echo number_format($tot_vldbdolr,2,",",".");?></label></td>
					<td><label><span><? echo number_format($tot_vlcrreal,2,",",".");?></span><? echo number_format($tot_vlcrreal,2,",",".");?></label></td>
					<td><label><span><? echo number_format($tot_vldbreal,2,",",".");?></span><? echo number_format($tot_vldbreal,2,",",".");?></label></td>
				</tr>
				<tr>
					<td colspan="4"><div align="right"><label><span><? echo utf8ToHtml('TOTAL PARA PAGAMENTO');  ?></span><? echo utf8ToHtml('TOTAL PARA PAGAMENTO');  ?></label></div></td>
					<td></td>
					<td colspan="2"><div align="center"><label><span>R$ <? echo number_format(str_replace(",",".",($saldoFinal)),2,",",".") ?></span>R$ <? echo number_format(str_replace(",",".",($saldoFinal)),2,",",".") ?></label></div></td>
				</tr>
		</tbody>
	</table>
</div>


<? include("impressao_extrato.php"); ?>

</div>
<div id="divBotoes2" >
	<br />
	<input type="image" id="btVoltarExtrato" src="<? echo $UrlImagens; ?>botoes/voltar.gif" />

	<input type="image" src="<?php echo $UrlImagens; ?>botoes/imprimir.gif" onClick="ImprimeExtratoCartao2(18,<? echo $nrdconta ?>,<? echo $nrcrcard ?>,'<? echo $dtvctini ?>','<? echo $dtvctfim ?>');return false;">
</div>

<script type="text/javascript">
	// Mostra o div da Tela da opção
	$("#divOpcoesDaOpcao1").css("display","block");
	$("#divConteudoCartoes").css("display","none");
	$("#divExtrato").css("display","none");
	
	$("#divExtratoDetalhe").css("display","block").css("width","730px");
	$("#divImpressaoCartao").css("width","730px");
	
	controlaLayout('divExtratoDetalhe');
	
	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);

	
</script>