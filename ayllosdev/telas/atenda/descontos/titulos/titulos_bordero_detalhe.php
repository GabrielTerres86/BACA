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
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrnosnum"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrnosnum = $_POST["nrnosnum"];
	$nrdconta = $_POST["nrdconta"];

	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <nrnosnum>".$nrnosnum."</nrnosnum>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    // FAZER O INSERT CRAPRDR e CRAPACA
    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","LISTAR_DETALHE_TITULO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

   
	$dados = $xmlObj->roottag->tags[0];
	$pagador = $dados->tags[0];
	$biros = $dados->tags[1];
	$detalhe = $dados->tags[2];
	$critica = $dados->tags[3];
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
			    <input type="text" id="nmdsacad" name="nmdsacad" value="<?php echo getByTagName($pagador->tags,'nmdsacad'); ?>" />

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
					<?php if(count($biros->tags)>0){ ?>
						<?php foreach($biros->tags AS $t) {?>
						<tr>
							<td style="align-text: center;"><? echo getByTagName($t->tags,'dsnegati');  ?></td>
							<?php if(getByTagName($t->tags,'qtnegati')>0) { ?>
								<td style="align-text: center;"><? echo formataMoeda(getByTagName($t->tags,'vlnegati')); ?></td>
								<td style="align-text: center;"><? echo getByTagName($t->tags,'qtnegati'); ?></td>
								<td style="align-text: center;"><? echo getByTagName($t->tags,'dtultneg'); ?></td>
							<?php }
							else { ?>
								<td>Nada Consta</td>
								<td>Nada Consta</td>
								<td>Nada Consta</td>
					 		<? } ?>
						</tr>
				    	<?php } 
				    	} else{ ?>
						<tr>
								<td>Nada Consta</td>
								<td>Nada Consta</td>
								<td>Nada Consta</td>
								<td>Nada Consta</td>
						</tr>
			    	<?php } ?>

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
						<td style="vertical-align: bottom;"><? echo formataMoeda(getByTagName($detalhe->tags,'concpaga'));?></td>
						<td style="vertical-align: bottom;"><? echo formataMoeda(getByTagName($detalhe->tags,'liqpagcd'));?></td>
						<td style="vertical-align: bottom;"><? echo formataMoeda(getByTagName($detalhe->tags,'liqgeral'));?></td>
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
							<?php foreach($critica->tags AS $c) { ?>
								<tr>
									<td style="text-align: left;"><? echo $c->cdata;?></td>
								</tr>
							<?} // Fim do foreach ?>	
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