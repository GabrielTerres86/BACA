<?php 

	/************************************************************************
	 Fonte: titulos_bordero_detalhe.php                                        
	 Autor: Alex Sandro (GFT)
	 Data : 22/03/2018                Última Alteração: 30/07/2018
	                                                                  
	 Objetivo  : Detalhe do pagador

	 Alterações: 04/04/2018 - Ajuste nas tabelas de críticas e restrições (Leonardo Oliveira - GFT).
                 30/07/2019 - Removida porcentagem de Liquidez do pagador com o cedente quando não houver parcelas suficientes para o calculo - Darlei (Supero)

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
	if (!isset($_POST["selecionados"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$selecionados = $_POST["selecionados"];
	$nrdconta = $_POST["nrdconta"];

	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <nrborder></nrborder>";
    $xml .= "   <chave>".$selecionados."</chave>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    // FAZER O INSERT CRAPRDR e CRAPACA
    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","LISTAR_DETALHE_TITULO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    
    $xmlObj = getClassXML($xmlResult);
    $root = $xmlObj->roottag;
	if ($root->erro){
		exibeErro(htmlentities($root->erro->registro->dscritic));
	}

	$dados = $xmlObj->roottag->tags[0];
	$pagador = $dados->tags[0];
	$biros = $dados->tags[1];
	$detalhe = $dados->tags[2];
	$criticas = $dados->tags[3];
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
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

				<?php if( getByTagName($detalhe->tags,'dtreapro') <> ''){ ?>
				
					<label for='dtreapro' style="width:200px;"  class='rotulo-linha'>Data de Reaproveitamento:</label>
					<input type="text" style="width:80px;" id="dtreapro" name="dtreapro" value="<?php echo getByTagName($detalhe->tags,'dtreapro'); ?>" />
			
				<?php } ?>

			    <div class="divRestricoes divRegistros">
				    <table id="tblDetalhe1" class="tituloRegistros">
						<thead>
							<tr>	
								<th>Restritiva</th>	
								<th>Valor</th>
								<th>Quantidade</th>
								<th>Data da Ocorr&ecirc;ncia</th>											
							</tr>
						</thead>
						<tbody>
							<?php if(count($biros->tags)>0){ ?>
								<?php foreach($biros->tags AS $t) {?>
									<tr>
										<td><? echo getByTagName($t->tags,'dsnegati');  ?></td>
										<?php if(getByTagName($t->tags,'qtnegati')>0) { ?>
											<td><? echo (formataMoeda(getByTagName($t->tags,'vlnegati'))); ?></td>
											<td><? echo getByTagName($t->tags,'qtnegati'); ?></td>
											<td><? echo getByTagName($t->tags,'dtultneg'); ?></td>
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
				    	</tbody>
					</table>
				</div><!-- divRestricoes -->

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
						<td><? echo formataMoeda(getByTagName($detalhe->tags,'concpaga'));?></td><!--style="vertical-align: bottom;"-->
						<td><? 
								if(getByTagName($detalhe->tags,'qtparcmi') == 1){
									echo '-';
								}else{
									echo formataMoeda(getByTagName($detalhe->tags,'liqpagcd'));
								}
							?></td>
						<td><? echo formataMoeda(getByTagName($detalhe->tags,'liqgeral'));?></td>
					</tr>
				</table>

			  
			</fieldset>
		</div>

		<? if(count($criticas->tags)>0) { ?>
		<div id="divCritica" class="formulario">
			<fieldset>
				<legend>Cr&iacute;ticas</legend>
				<div id="divCriticasBordero">
					<table class="tituloRegistros divRegistros">
						<thead>
							<tr>
								<th width="50%">Cr&iacute;tica</th>
								<th width="50%">Valor</th>
							</tr>
						</thead>
						<tbody>
							<?php foreach($criticas->tags AS $c) {?>
								<tr>
									<td style="border-right:1px dotted #999;"><?php echo getByTagName($c->tags,'dsc'); ?></td>
									<td style="border-right:1px dotted #999;"><?php echo getByTagName($c->tags,'vlr');?></td>
								</tr>
							<?} // Fim do foreach ?>	
						</tbody>
					</table>
				</div><!-- divRegistrosTitulosSelecionados -->
			</fieldset>
		</div><!-- divCritica -->
		<? } ?>

	</form>
</div><!-- divDetalheBordero -->


<div id="divBotoesTitulosLimite" style="margin-bottom:10px;">
	<input type="button" class="botao" value="Voltar"  onClick="voltaDiv(5,4,5,'DESCONTO DE T&Iacute;TULOS - BORDEROS');return false; " />

<script type="text/javascript">
	dscShowHideDiv("divOpcoesDaOpcao5","divOpcoesDaOpcao1;divOpcoesDaOpcao2;divOpcoesDaOpcao3;divOpcoesDaOpcao4");

	// Muda o título da tela
	$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS - BORDERO - DETALHES");

	formataLayout('divDetalheBordero');
	formataTabelaCriticas($("#divCriticasBordero"));
	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));

</script>