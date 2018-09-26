<?
/*!
 * FONTE        : cheques_bordero_custodia_novo.php
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

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o número do bordero é um inteiro válido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("N&uacute;mero do contrato de limite inv&aacute;lido.");
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
<div id="divChequesCustodiaNovo">
	<form id="frmChequesCustodiaNovo" name="frmChequesCustodiaNovo" class="formulario" >

		<fieldset>
			<legend>Novo Cheque</legend>
			
			<label for="dtlibera">Data Boa:</label>
			<input type="text" id="dtlibera" name="dtlibera" class="campo">
			
			<label for="dtdcaptu">Data de Emiss&atilde;o:</label>
			<input type="text" id="dtdcaptu" name="dtdcaptu" class="campo" >
			
			<label for="vlcheque">Valor:</label>
			<input type="text" id="vlcheque" name="vlcheque" class="campo" >
			
			</br>
			
			<label for="dsdocmc7">CMC7:</label>
			<input type="text" id="dsdocmc7" name="dsdocmc7" class="campo" >
			
			<a href="#" class="botao" id="btnOk" style="padding: 3px;">Ok</a>
			</br>
		</fieldset>					
		<div class="divRegistros" id="divCheques">	
			<table class="tituloRegistros" id="tbChequesNovos" style="table-layout: fixed;">
				<thead>
					<tr>
						<th>Data Boa</th>
						<th>Data Emiss&atilde;o</th>
						<th>Cmp</th>
						<th>Bco</th>
						<th>Ag.</th>
						<th>Conta</th>
						<th>Cheque</th>
						<th>Valor</th>
						<th>Situa&ccedil;&atilde;o</th>
						<th>Cr&iacute;tica</th>
						<th>&nbsp;</th>
					</tr>
				</thead>
				<tbody>					
				</tbody>
			</table>
		</div>

		<br style="clear:both" />	
	
	</form>	

	<div id="divBotoesCustodia" style="padding-bottom:10px;">
		<a href="#" class="botao" id="btVoltar" onclick="voltaDiv(4,3,4,'DESCONTO DE CHEQUES'); return false;">Voltar</a>
		<a href="#" class="botao" id="btProsseguir" style="display: none;" onclick="verificarEmitentes(); return false;" >Prosseguir</a>
		<a href="#" class="botao" id="btAddChq" onclick="validaNovosCheques(); return false;" >Adicionar ao Border&ocirc;</a>
	</div>
</div>
<script type="text/javascript">
dscShowHideDiv("divOpcoesDaOpcao4","divOpcoesDaOpcao3");
// Muda o título da tela
$("#tdTitRotina").html("DESCONTO DE CHEQUES");

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

formataLayout('frmChequesCustodiaNovo');
layoutPadrao();
var aux_dtmvtolt = "<?php echo $glbvars["dtmvtolt"]; ?>";
</script>