<?
/*!
 * FONTE        : cheques_bordero_custodia_selec.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 25/10/2016
 * OBJETIVO     : Form de exibição de cheques em custodia
 * --------------
 * ALTERAÇÕES   :
 */		

	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrctrlim"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
	$nrctrlim = (isset($_POST["nrctrlim"])) ? $_POST["nrctrlim"] : 0;
	$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 1;
	$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 50;

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	/*
	// Verifica se o número do bordero é um inteiro válido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("N&uacute;mero do border&ocirc; inv&aacute;lida.");
	}	
	*/
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "	<nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "	<nrregist>".$nrregist."</nrregist>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, 'TELA_ATENDA_DESCTO', 'BUSCA_CHEQUES_DSC_CST', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibeErro($msgErro);
		exit();
	}

	$qtregist = $xmlObj->roottag->tags[1]->cdata;
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
?>
<div id="divChequesCustodia">
	<form id="frmChequesCustodia" name="frmChequesCustodia" class="formulario" >

		<fieldset>
			<legend>Cheques em Cust&oacute;dia</legend>
			
			</br>
			
			<div class="divRegistros" id="divCheques">	
				<table class="tituloRegistros" id="tbCheques" style="table-layout: fixed;">
					<thead>
						<tr>
							<th>Data Boa</th>
							<th>Cmp</th>
							<th>Bco</th>
							<th>Ag.</th>
							<th>Conta</th>
							<th>Cheque</th>
							<th>Nome</th>
							<th>CPF/CNPJ</th>
							<th>Valor</th>
							<th>Situa&ccedil;&atilde;o</th>
							<th>&nbsp;</th>
						</tr>
					</thead>
					<tbody>
					<?
					if(strtoupper($xmlObj->roottag->tags[0]->name == 'DADOS')){	
						foreach($xmlObj->roottag->tags[0]->tags as $infoCheque){
							$aux_dstipchq = $infoCheque->tags[0]->cdata; // Tipo cheque
							$aux_dtmvtolt = $infoCheque->tags[1]->cdata; // Data
							$aux_dtlibera = $infoCheque->tags[2]->cdata; // Data libera
							$aux_cdcmpchq = $infoCheque->tags[3]->cdata; // Comp
							$aux_cdbanchq = $infoCheque->tags[4]->cdata; // Banco
							$aux_cdagechq = $infoCheque->tags[5]->cdata; // Agência
							$aux_nrctachq = $infoCheque->tags[6]->cdata; // Número conta cheque
							$aux_nrcheque = $infoCheque->tags[7]->cdata; // Número cheque	
							$aux_vlcheque = $infoCheque->tags[8]->cdata; // Valor cheque
							$aux_inconcil = $infoCheque->tags[9]->cdata; // Indicador de conciliação
							$aux_nmcheque = $infoCheque->tags[10]->cdata; // Nome emitente
							$aux_nrcpfcgc = $infoCheque->tags[11]->cdata; // CPF/CNPJ Emitente
							$aux_dsdocmc7 = $infoCheque->tags[12]->cdata; // CMC7
							$aux_dtdcaptu = $infoCheque->tags[13]->cdata; // Data de Emissão
							$aux_dtcustod = $infoCheque->tags[14]->cdata; // Data Custódia
							$aux_nrremret = $infoCheque->tags[15]->cdata; // Número da remessa
							$idLinha = preg_replace('~[^0-9]~', '', $aux_cdbanchq.$aux_cdagechq.$aux_cdcmpchq.$aux_nrcheque.$aux_nrctachq);
							?>
							<tr id="<? echo $idLinha ?>">
								<td id="dtlibera" style="width: 73px;"><span><? echo $aux_dtlibera ?></span><? echo $aux_dtlibera ?></td>
								<td id="cdcmpchq" style="width: 30px;"><span><? echo $aux_cdcmpchq ?></span><? echo $aux_cdcmpchq ?></td>
								<td id="cdbanchq" style="width: 30px;"><span><? echo $aux_cdbanchq ?></span><? echo $aux_cdbanchq ?></td>
								<td id="cdagechq" style="width: 30px;"><span><? echo $aux_cdagechq ?></span><? echo $aux_cdagechq ?></td>
								<td id="nrctachq" style="width: 69px;"><span><? echo $aux_nrctachq ?></span><? echo $aux_nrctachq ?></td>
								<td id="nrcheque" style="width: 59px;"><span><? echo $aux_nrcheque ?></span><? echo $aux_nrcheque ?></td>
								<td id="nmcheque" style="width: 210px;"><span><? echo $aux_nmcheque ?></span><? echo $aux_nmcheque ?></td>
								<td id="nrcpfcgc" style="width: 100px;"><span><? echo $aux_nrcpfcgc ?></span><? echo $aux_nrcpfcgc ?></td>
								<td id="vlcheque" style="width: 70px;"><span><? echo $aux_vlcheque ?></span><? echo $aux_vlcheque ?></td>
								<td id="inconcil" style="width: 59px;"><span><? echo $aux_inconcil ?></span><? echo $aux_inconcil ?></td>
								<td style="width: 20px;"><img src="<?php echo $UrlImagens; ?>geral/servico_ativo.gif" title="Adicionar" width="16" height="16" onclick="adicionaChequeBordero(this.parentNode.parentNode.innerHTML, '<? echo 's'.$idLinha; ?>'); removeChequeSelecionado('<? echo $idLinha; ?>');" /></td>
								<input type="hidden" id="dsdocmc7" name="dsdocmc7" value="<? echo $aux_dsdocmc7 ?>" />
								<input type="hidden" id="dtdcaptu" name="dtdcaptu" value="<? echo $aux_dtdcaptu ?>" />
								<input type="hidden" id="dtcustod" name="dtcustod" value="<? echo $aux_dtcustod ?>" />
								<input type="hidden" id="nrremret" name="nrremret" value="<? echo $aux_nrremret ?>" />
							</tr>
							<?
						}		
					}
					?>
					</tbody>
				</table>
			</div>
			<div id="divPesquisaRodape" class="divPesquisaRodape">
				<table>	
					<tr>
						<td>
							<?
								//
								if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
								
								// Se a paginação não está na primeira, exibe botão voltar
								if ($nriniseq > 1) { 
									?> <a class='paginacaoAnt'><<< Anterior</a> <? 
								} else {
									?> &nbsp; <?
								}
							?>
						</td>
						<td>
							<?
								if (isset($nriniseq)) { 
									?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?><?
								}
							?>
						</td>
						<td>
							<?
								// Se a paginação não está na &uacute;ltima página, exibe botão proximo
								if ($qtregist > ($nriniseq + $nrregist - 1)) {
									?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
								} else {
									?> &nbsp; <?
								}
							?>			
						</td>
					</tr>
				</table>
			</div>						
		</fieldset>
		<div id="divChequesSelPag">
			<fieldset style="margin-top: 10px">
				<legend>Cheques Selecionados</legend>
				</br>
				<div class="divRegistros" id="divChequesSel">	
					<table class="tituloRegistros" id="tbChequesSel" style="table-layout: fixed;">
						<thead>
							<tr>
								<th>Data Boa</th>								
								<th>Cmp</th>
								<th>Bco</th>
								<th>Ag.</th>
								<th>Conta</th>
								<th>Cheque</th>
								<th>Nome</th>
								<th>CPF/CNPJ</th>
								<th>Valor</th>
								<th>Situa&ccedil;&atilde;o</th>
								<th>&nbsp;</th>
							</tr>
						</thead>
						<tbody>
						</tbody>
					</table>
				</div>
			</fieldset>
		</div>
		
		<br style="clear:both" />	
	
	</form>	

	<div id="divBotoesCustodia" style="padding-bottom:10px;">
		<a href="#" class="botao" id="btVoltar" onclick="voltaDiv(4,3,4,'DESCONTO DE CHEQUES'); return false;">Voltar</a>
		<a href="#" class="botao" id="btAddChq" onclick="adicionarChqsBordero(2, 'tbChequesSel'); return false;" >Adicionar ao Border&ocirc;</a>
	</div>
</div>
<script type="text/javascript">
$('a.paginacaoAnt').unbind('click').bind('click', function() {
	var htmlDivSel = document.getElementById("divChequesSelPag").innerHTML;
	mostraTelaChequesCustodia(<?php echo "'" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>, htmlDivSel);	
});

$('a.paginacaoProx').unbind('click').bind('click', function() {
	var htmlDivSel = document.getElementById("divChequesSelPag").innerHTML;
	mostraTelaChequesCustodia(<?php echo "'" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>, htmlDivSel);
});

dscShowHideDiv("divOpcoesDaOpcao4","divOpcoesDaOpcao3");
// Muda o título da tela
$("#tdTitRotina").html("DESCONTO DE CHEQUES");

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

formataLayout('frmChequesCustodia');
$('#divPesquisaRodape', '#divChequesCustodia').formataRodapePesquisa();					
layoutPadrao();
</script>