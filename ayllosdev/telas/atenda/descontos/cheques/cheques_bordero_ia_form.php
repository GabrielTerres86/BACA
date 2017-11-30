<?php 

	/************************************************************************
	 Fonte: cheques_bordero_ia_form.php
	 Autor: Lucas Reinert
	 Data : Outubro/2016                Última Alteração: 26/06/2017 
	                                                                  
	 Objetivo  : Apresentar form para inclusão/alteração de borderô de desconto 
				 de cheque
	                                                                  	 
	 Alterações: 26/06/2017 - Ajuste para rotina ser chamada através da tela ATENDA > Produtos (Jonata - RKAM / P364).


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
		
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;	
	$nrborder = (isset($_POST['nrborder'])) ? $_POST['nrborder'] : 0;	
	$executandoProdutos = $_POST['executandoProdutos'];
	
	$qtcompln = 0;
	$vlcompcr = 0;
	
	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrborder>".$nrborder."</nrborder>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_ATENDA_DESCTO", "BUSCA_INF_BORDERO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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

	if(strtoupper($xmlObj->roottag->tags[0]->name == 'DADOS')){	
		$nrctrlim = $xmlObj->roottag->tags[0]->tags[0]->cdata;
		$vllimite = $xmlObj->roottag->tags[0]->tags[1]->cdata;
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}

?>

<div id="divBorderosIA">
	<form id="frmBorderosIA">
		<fieldset>
			<legend>Desconto de Cheque</legend>			
			<div style="height: 50px">
				<label for="nrborder">Border&ocirc;:</label>
				<input type="text" id="nrborder" name="nrborder" class="campo" value="<? echo mascara($nrborder, '###.###.###') ?>">
			
				<label for="nrctrlim">Contrato:</label>
				<input type="text" id="nrctrlim" name="nrctrlim" class="campo" value="<? echo mascara($nrctrlim, '###.###.###') ?>">
				
				<label for="vllimite">Limite Dispon&iacute;vel:</label>
				<input type="text" id="vllimite" name="vllimite" class="campo" value="<? echo $vllimite ?>">
				
				</br>
				
				<label for="qtcompln">Qtd. Computada:</label>
				<input type="text" id="qtcompln" name="qtcompln" class="campo" value="<? echo $qtcompln ?>">
				
				<label for="vlcompcr">Valor Computado:</label>
				<input type="text" id="vlcompcr" name="vlcompcr" class="campo" value="<? echo formataMoeda($vlcompcr) ?>">
			</div>
			<div align="right" id="divBotoesBordero">
				<div style="border: 1px; display: inline-block;">
					<a href="#" class="botao" id="btSelCheque" style="padding: 3px;" onclick="mostraTelaChequesCustodia(1,50,'');return false;"><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="11" height="11" border="0"> Selecionar Cheque em Cust&oacute;dia</a>
					<a href="#" class="botao" id="btNovoCheque" style="padding: 3px;" onclick="mostraTelaChequesNovos();">Novo Cheque</a>
				</div>
			</div>
		</fieldset>
		<div id="divChqsBordero">
			<div class="divRegistros">	
				<table class="tituloRegistros" id="tbChequesBordero">
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
							<th><? echo '&nbsp;' ?></th>
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>
			</div>		
		</div>
		<div id="divEmiten" style="display: none">
			<div class="divRegistros">
				<table class="tituloRegistros" id="tabEmiten">
					<thead>
						<tr>
							<th>Banco</th>
							<th>Ag&ecirc;ncia</th>
							<th>N&uacute;mero da Conta</th>
							<th>CPF/CNPJ</th>
							<th>Emitente</th>						
							<th>Cr&iacute;tica</th>						
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>
			</div> 
		</div>
	</form>
</div>
<div id="divBotoes">

	<?if($executandoProdutos == 'true'){?>
		
		<a href="#" class="botao" id="btVoltar" onclick="encerraRotina(true);return false;">Voltar</a>
		
	<?}else{?>
		
	<a href="#" class="botao" id="btVoltar" onclick="voltaDiv(3,2,4,'DESCONTO DE CHEQUES - BORDERÔS'); carregaBorderosCheques(); return false;">Voltar</a>
	
	<?}?>
	
	<a href="#" class="botao" id="btProsseguir" onclick="verificarEmitentes(); return false;" >Prosseguir</a>
</div>

<script type="text/javascript">
var cddopcao = '<?php echo $cddopcao; ?>';

dscShowHideDiv("divOpcoesDaOpcao3","divOpcoesDaOpcao2");
if (cddopcao == 'I'){
	// Muda o título da tela
	$("#tdTitRotina").html("DESCONTO DE CHEQUES - INCLUS&Atilde;O");
}else{
	// Muda o título da tela
	$("#tdTitRotina").html("DESCONTO DE CHEQUES - ALTERA&Ccedil;&Atilde;O");
}
// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

formataLayout('frmBorderosIA');

if (cddopcao == 'I'){
	$("#tbCheques > tbody").append($('<tr>')
								.attr('class','corImpar')
								.attr('align','center')
								.text("Sem Registros")
								);
}
</script>

<?
if(strtoupper($xmlObj->roottag->tags[0]->tags[2]->name == 'CHEQUES')){	
	echo '<script type="text/javascript">';
	foreach($xmlObj->roottag->tags[0]->tags[2]->tags as $infoCheque){
		$aux_dtlibera = $infoCheque->tags[0]->cdata; // Data libera
		$aux_cdcmpchq = $infoCheque->tags[1]->cdata; // Comp
		$aux_cdbanchq = $infoCheque->tags[2]->cdata; // Banco
		$aux_cdagechq = $infoCheque->tags[3]->cdata; // Agência
		$aux_nrctachq = $infoCheque->tags[4]->cdata; // Número conta cheque
		$aux_nrcheque = $infoCheque->tags[5]->cdata; // Número cheque	
		$aux_vlcheque = $infoCheque->tags[6]->cdata; // Valor cheque
		$aux_nmcheque = $infoCheque->tags[7]->cdata; // Nome emitente
		$aux_nrcpfcgc = $infoCheque->tags[8]->cdata; // CPF/CNPJ Emitente
		$aux_dssitchq = $infoCheque->tags[9]->cdata; // Situação do cheque
		$aux_dsdocmc7 = $infoCheque->tags[10]->cdata; // CMC7
		echo 'adicionarChequeBordero(\''.$aux_dtlibera.'\','.
									'\''.$aux_cdcmpchq.'\','. 
									'\''.$aux_cdbanchq.'\','. 
									'\''.$aux_cdagechq.'\','. 
									'\''.$aux_nrctachq.'\','. 
									'\''.$aux_nrcheque.'\','. 
									'\''.$aux_vlcheque.'\','. 
									'\''.$aux_dssitchq.'\','. 
									'\''.$aux_nmcheque.'\','. 
									'\''.$aux_nrcpfcgc.'\','. 
									'\'0\','. 
									'\''.$aux_dsdocmc7.'\','. 
									'\' \','. 
									'\' \','.
									'\' \','.
									'\'1\');';
	}
	echo 'layoutPadrao();';
	echo '</script>';																				
}
?>