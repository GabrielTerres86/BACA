<?php 

	/************************************************************************
	 Fonte: cheques_bordero_analise.php
	 Autor: Lucas Reinert
	 Data : Novembro/2016                �ltima Altera��o: 
	                                                                  
	 Objetivo  : Apresentar form para analise de border� de desconto 
				 de cheque
	                                                                  	 
	 Altera��es: 
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
		
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;	
	$nrborder = (isset($_POST['nrborder'])) ? $_POST['nrborder'] : 0;	
	$qtcompln = 0;
	$vlcompcr = 0;
	
	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrborder>".$nrborder."</nrborder>";
	$xml .= "   <cddopcao>N</cddopcao>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_ATENDA_DESCONTO", "BUSCA_INF_BORDERO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}

?>

<div id="divBorderosAnalise">
	<form id="frmBorderosAnalise">
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
							<th>Cr&iacute;tica</th>
							<th>Aprov.</th>
						</tr>
					</thead>
					<tbody>
					<?
					if(strtoupper($xmlObj->roottag->tags[0]->tags[2]->name == 'CHEQUES')){	
						foreach($xmlObj->roottag->tags[0]->tags[2]->tags as $infoCheque){
							$aux_dtlibera = $infoCheque->tags[0]->cdata; // Data libera
							$aux_cdcmpchq = $infoCheque->tags[1]->cdata; // Comp
							$aux_cdbanchq = $infoCheque->tags[2]->cdata; // Banco
							$aux_cdagechq = $infoCheque->tags[3]->cdata; // Ag�ncia
							$aux_nrctachq = $infoCheque->tags[4]->cdata; // N�mero conta cheque
							$aux_nrcheque = $infoCheque->tags[5]->cdata; // N�mero cheque	
							$aux_nmcheque = $infoCheque->tags[6]->cdata; // Nome emitente
							$aux_nrcpfcgc = $infoCheque->tags[7]->cdata; // CPF/CNPJ Emitente
							$aux_vlcheque = $infoCheque->tags[8]->cdata; // Valor cheque
							$aux_dscritic = $infoCheque->tags[9]->cdata; // Cr�tica
							$aux_insitana = $infoCheque->tags[10]->cdata; // Situa��o da analise
							$aux_dsdocmc7 = $infoCheque->tags[11]->cdata; // CMC7
							$aux_flbloque = $infoCheque->tags[12]->cdata; // Flag Bloqueio Opera��o
							?>
							<tr >
								<td id="dtlibera" style="width: 55px;" ><span><? echo $aux_dtlibera ?></span><? echo $aux_dtlibera ?></td>
								<td id="cdcmpchq" style="width: 30px;" ><span><? echo $aux_cdcmpchq ?></span><? echo $aux_cdcmpchq ?></td>
								<td id="cdbanchq" style="width: 30px;" ><span><? echo $aux_cdbanchq ?></span><? echo $aux_cdbanchq ?></td>
								<td id="cdagechq" style="width: 30px;" ><span><? echo $aux_cdagechq ?></span><? echo $aux_cdagechq ?></td>
								<td id="nrctachq" style="width: 69px;" ><span><? echo $aux_nrctachq ?></span><? echo $aux_nrctachq ?></td>
								<td id="nrcheque" style="width: 59px;" ><span><? echo $aux_nrcheque ?></span><? echo $aux_nrcheque ?></td>
								<td id="nmcheque" style="width: 210px;"><span><? echo $aux_nmcheque ?></span><? echo $aux_nmcheque ?></td>
								<td id="nrcpfcgc" style="width: 100px;"><span><? echo $aux_nrcpfcgc ?></span><? echo $aux_nrcpfcgc ?></td>
								<td id="vlcheque" style="width: 70px;" ><span><? echo $aux_vlcheque ?></span><? echo $aux_vlcheque ?></td>
								<td id="dscritic" style="width: 268px;"><span><? echo $aux_dscritic ?></span><? echo $aux_dscritic ?></td>
								<td><input type="checkbox" id="insitana" name="insitana" style="float: none; margin: 0px" value="<? echo $aux_insitana ?>" <? if ($aux_insitana == '1') echo ' checked'; if ($aux_flbloque == '1') echo ' disabled'; ?>/></td>
								<input type="hidden" id="dsdocmc7" name="dsdocmc7" value="<? echo $aux_dsdocmc7 ?>"/>
							</tr>
							<?
						}
					}
					?>
					</tbody>
				</table>
			</div>		
		</div>
	</form>
</div>
<div id="divBotoes">
	<a href="#" class="botao" id="btVoltar" onclick="voltaDiv(3,2,4,'DESCONTO DE CHEQUES - BORDER�S'); carregaBorderosCheques(); return false;">Voltar</a>
	<a href="#" class="botao" id="btConcluir" onclick="concluirAnaliseBordero(); return false;" >Concluir</a>
</div>

<script type="text/javascript">
dscShowHideDiv("divOpcoesDaOpcao3","divOpcoesDaOpcao2");
// Muda o t�tulo da tela
$("#tdTitRotina").html("DESCONTO DE CHEQUES - ANALISE");

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte�do que est� �tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

formataLayout('frmBorderosAnalise');
atualizaValoresBorderoAnalise();
layoutPadrao();
</script>