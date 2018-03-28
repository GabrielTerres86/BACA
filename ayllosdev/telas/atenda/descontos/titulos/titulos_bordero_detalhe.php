<?php 

	/************************************************************************
	 Fonte: titulos_bordero_detalhe.php                                        
	 Autor: Alex Sandro (GFT)
	 Data : 22/03/2018                Última Alteração: 
	                                                                  
	 Objetivo  : Detalhe do pagador

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
	
	setVarSession("nmrotina","DSC TITS - BORDERO");
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["idtitulo"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$idtitulo = $_POST["idtitulo"];

	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$idtitulo."</nrdconta>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    // FAZER O INSERT CRAPRDR e CRAPACA
    $xmlResult = mensageria($xml,"XXXX","XXXX", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

	$titulos   = $xmlObj->roottag->tags[0]->tags;
	$qtTitulos = count($titulos);
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>

<div id="divDetalheBordero">
	

	<form id="formPesquisaTitulos" class="formulario">
		<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo $nrdconta; ?>" />
		<div id="divFiltros">
			<fieldset>
				<legend>Detalhes do Pagador</legend>

				
			    <label for="nmdsacad">Nome Pagador</label>
			    <input type="text" id="nmdsacad" name="nmdsacad" value="<?php echo $nmdsacad ?>" />

			    <table id="tblDetalhe1" style="padding-left:0px;width:100%">
				
					<tr>	
							
						<td style="vertical-align: bottom; ">
							<label>Restritiva:</label>
						</td>	
						<td style="vertical-align: bottom; ">
							<label >Valor:</label>
						</td>
						<td style="vertical-align: bottom;">
							<label >Quantidade:</label>
						</td>
						<td style="vertical-align: bottom; ">
							<label >Data da Ocorr&ecirc;ncia</label>
						</td>											
					</tr>

					<tr>
						<td style="align-text: center;">SPC</td>
						<td style="align-text: center;">Nada Consta</td>
						<td style="align-text: center;">Nada Consta</td>
						<td style="align-text: center;">Nada Consta</td>
					</tr>

					<tr>
						<td style="align-text: center; ">SERASA</td>
						<td style="align-text: center;">Nada Consta</td>
						<td style="align-text: center;">Nada Consta</td>
						<td style="align-text: center;">Nada Consta</td>
					</tr>

					<tr>
						<td style="align-text: center; ">BOA BISTA</td>
						<td style="align-text: center;">Nada Consta</td>
						<td style="align-text: center;">Nada Consta</td>
						<td style="align-text: center;">Nada Consta</td>
					</tr>
				</table>
				<br><br>
		
			
				<table id="tblDetalhe2" style="padding-left:0px;width:100%">
					<tr>	
							
						<td style="align-text: center; ">
							<label >% Concentra&ccedil;&atilde;o por Pagador</label>
						</td>	
						<td style="vertical-align: bottom; ">
							<label >% Liquidez do Pagador com a Cedente</label>
						</td>
						<td style="vertical-align: bottom;">
							<label >% Liquidez Geral</label>
						</td>									
					</tr>

					<tr>	
						<td style="vertical-align: bottom;">80%</td>	
						<td style="vertical-align: bottom;">90%</td>
						<td style="vertical-align: bottom;">90%</td>									
					</tr>
				</table>

			  
			</fieldset>
		</div>


		<div id="divCritica" class="formulario">
			<fieldset>
				<legend>Cr&iacute;ticas</legend>
				<div class="divRegistrosTitulosSelecionados divRegistros">
					<table class="tituloRegistros">
						<thead>
							<tr>
								<th style="text-align: left;">Cr&iacute;tica</th>
							</tr>
						</thead>
						<tbody>
							<tr>
								<td style="text-align: left;">Descri&ccedil;&atilde;o da critica retornada pelo sistema</td>
							</tr>
						</tbody>
					</table>
				</div>
			</fieldset>
		</div>
	</form>
</div>


<div id="divBotoesTitulosLimite" style="margin-bottom:10px;">
	<input type="button" class="botao" value="Voltar"  onClick="voltaDiv(5,4,5,'DESCONTO DE T&Iacute;TULOS - BORDEROS');return false; " />

<script type="text/javascript">
	dscShowHideDiv("divOpcoesDaOpcao5","divOpcoesDaOpcao1;divOpcoesDaOpcao2;divOpcoesDaOpcao3;divOpcoesDaOpcao4");

	// Muda o título da tela
	$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS - BORDERO - DETALHES");

	formataLayout('divDetalheBordero');

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));

</script>