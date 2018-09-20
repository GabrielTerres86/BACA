<?
/*!
 * FONTE        : cheques_bordero_resgate.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 13/12/2016
 * OBJETIVO     : Form de exibição dos cheques para resgate do borderô
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
		!isset($_POST["nrborder"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
	$nrborder = (isset($_POST["nrborder"])) ? $_POST["nrborder"] : 0;

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o número do bordero é um inteiro válido
	if (!validaInteiro($nrborder)) {
		exibeErro("N&uacute;mero do border&ocirc; inv&aacute;lida.");
	}
	
	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrborder>".$nrborder."</nrborder>";
	$xml .= "   <cddopcao>R</cddopcao>";
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
		$vlborder = $xmlObj->roottag->tags[0]->tags[1]->cdata;
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
?>
<div id="divBorderoResgate">
	<form id="frmBorderoResgate" name="frmBorderoResgate" class="formulario" >

		<fieldset>
			<legend>Resgate</legend>
			
			<label for="nrborder">Border&ocirc;:</label>
			<input type="text" id="nrborder" name="nrborder" class="campo" value="<? echo mascara($nrborder, '###.###.###') ?>">
		
			<label for="nrctrlim">Contrato:</label>
			<input type="text" id="nrctrlim" name="nrctrlim" class="campo" value="<? echo mascara($nrctrlim, '###.###.###') ?>">			
			
			<label for="vlborder">Valor:</label>
			<input type="text" id="vlborder" name="vlborder" class="campo" value="<? echo $vlborder ?>">
			
			</br>
			
			<label for="dsdocmc7">CMC7:</label>
			<input type="text" id="dsdocmc7" name="dsdocmc7" class="campo" >
			
			<a href="#" class="botao" id="btnOk" style="padding: 3px;">Ok</a>
			<label id="dsmsgcmc7" />
			</br>
		</fieldset>					
		<div class="divRegistros" id="divCheques">	
			<table class="tituloRegistros" id="tbChequesResgate" style="table-layout: fixed;">
				<thead>
					<tr>
						<th>&nbsp;</th>
						<th>Data Boa</th>
						<th>Cmp</th>
						<th>Bco</th>
						<th>Ag.</th>
						<th>Conta</th>
						<th>Cheque</th>
						<th>Nome</th>
						<th>CPF/CNPJ</th>						
						<th>Valor</th>
					</tr>
				</thead>
				<tbody>
					<?
					if(strtoupper($xmlObj->roottag->tags[0]->tags[2]->name == 'CHEQUES')){	
						foreach($xmlObj->roottag->tags[0]->tags[2]->tags as $infoCheque){
							$aux_dtlibera = $infoCheque->tags[0]->cdata; // Data libera
							$aux_cdcmpchq = $infoCheque->tags[1]->cdata; // Comp
							$aux_cdbanchq = $infoCheque->tags[2]->cdata; // Banco
							$aux_cdagechq = $infoCheque->tags[3]->cdata; // Agência
							$aux_nrctachq = $infoCheque->tags[4]->cdata; // Número conta cheque
							$aux_nrcheque = $infoCheque->tags[5]->cdata; // Número cheque	
							$aux_nmcheque = $infoCheque->tags[6]->cdata; // Nome emitente
							$aux_nrcpfcgc = $infoCheque->tags[7]->cdata; // CPF/CNPJ Emitente
							$aux_vlcheque = $infoCheque->tags[8]->cdata; // Valor cheque
							$aux_dsdocmc7 = $infoCheque->tags[9]->cdata; // CMC7
							?>
							<tr >
								<td><input type="checkbox" id="flgresgat" name="flgresgat" style="float: none; margin: 0px" onchange="verificaFlgresgat(this);"/></td>
								<td id="dtlibera" style="width: 73px" ><span><? echo $aux_dtlibera ?></span><? echo $aux_dtlibera ?></td>
								<td id="cdcmpchq" style="width: 30px" ><span><? echo $aux_cdcmpchq ?></span><? echo $aux_cdcmpchq ?></td>
								<td id="cdbanchq" style="width: 30px" ><span><? echo $aux_cdbanchq ?></span><? echo $aux_cdbanchq ?></td>
								<td id="cdagechq" style="width: 30px" ><span><? echo $aux_cdagechq ?></span><? echo $aux_cdagechq ?></td>
								<td id="nrctachq" style="width: 69px" ><span><? echo $aux_nrctachq ?></span><? echo $aux_nrctachq ?></td>
								<td id="nrcheque" style="width: 59px" ><span><? echo $aux_nrcheque ?></span><? echo $aux_nrcheque ?></td>
								<td id="nmcheque" style="width: 210px"><span><? echo $aux_nmcheque ?></span><? echo $aux_nmcheque ?></td>
								<td id="nrcpfcgc" style="width: 100px"><span><? echo $aux_nrcpfcgc ?></span><? echo $aux_nrcpfcgc ?></td>
								<td id="vlcheque" style="width: 70px" ><span><? echo $aux_vlcheque ?></span><? echo $aux_vlcheque ?></td>
								<input type="hidden" id="aux_dsdocmc7" name="aux_dsdocmc7" value="<? echo $aux_dsdocmc7 ?>"/>
								<input type="hidden" id="aux_vlcheque" name="aux_vlcheque" value="<? echo $aux_vlcheque ?>"/>
							</tr>
							<?
						}
					}
					?>
					</tbody>
				</table>
		</div>

		<br style="clear:both" />	
	
	</form>	

	<div id="divBotoesCustodia" style="padding-bottom:10px;">
		<a href="#" class="botao" id="btVoltar" onclick="voltaDiv(3,2,4,'DESCONTO DE CHEQUES - BORDERÔS'); carregaBorderosCheques(); return false;">Voltar</a>
		<a href="#" class="botao" id="btConcluir" onclick="concluiResgate(); return false;" >Concluir</a>
	</div>
</div>
<script type="text/javascript">
dscShowHideDiv("divOpcoesDaOpcao3","divOpcoesDaOpcao2");
// Muda o título da tela
$("#tdTitRotina").html("DESCONTO DE CHEQUES - RESGATE");

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

formataLayout('frmBorderoResgate');
layoutPadrao();
</script>