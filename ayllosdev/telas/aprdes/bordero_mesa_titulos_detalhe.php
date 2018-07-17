<?php 
	/************************************************************************
	 Fonte: bordero_mesa_titulos_detalhe.php                                        
	 Autor: Luis Fernando (GFT)
	 Data : 27/04/2018
	                                                                  
	 Objetivo  : Detalhes e Parecer dos titulos


	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["chave"]) || !isset($_POST["nrborder"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}


	$nrdconta = $_POST["nrdconta"];
	$nrborder = $_POST["nrborder"];
	$chave = $_POST["chave"];

	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <nrborder>".$nrborder."</nrborder>";
    $xml .= "   <chave>".$chave."</chave>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    // FAZER O INSERT CRAPRDR e CRAPACA
    $xmlResult = mensageria($xml,"TELA_APRDES","VISUALIZAR_DETALHES_TITULO_MESA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getClassXML($xmlResult);
    $root = $xmlObj->roottag;
    if ($root->erro){
		exibeErro($root->erro->registro->dscritic);
    }
    $dados = $root->dados;

	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>


<form id="formParecer" class="formulario">
	<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo $nrdconta; ?>" />
	<input type="hidden" id="nrborder" name="nrborder" value="<? echo $nrborder; ?>" />
	<input type="hidden" id="chave" name="chave" value="<? echo $chave; ?>" />

	<div id="divFiltros">
		<fieldset>
			<legend>Detalhes do Pagador</legend>
			
		    <label for="nmdsacad">Nome Pagador</label>
		    <input type="text" id="nmdsacad" name="nmdsacad" value="<?php echo $dados->pagador->nmdsacad ?>" />

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
						<?php if($dados->biro->find("craprpf") && count($dados->biro->find("craprpf"))>0){ ?>
							<?php foreach($dados->biro->find("craprpf") AS $t) {?>
								<tr>
									<td><? echo $t->dsnegati;  ?></td>
									<?php if($t->findFirst("qtnegati")!= '' && $t->findFirst("qtnegati")>0) { ?>
										<td><? echo (formataMoeda($t->vlnegati)); ?></td>
										<td><? echo $t->qtnegati; ?></td>
										<td><? echo $t->dtultneg; ?></td>
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
					<td><? echo formataMoeda($dados->detalhe->concpaga);?></td><!--style="vertical-align: bottom;"-->
					<td><? echo formataMoeda($dados->detalhe->liqpagcd);?></td>
					<td><? echo formataMoeda($dados->detalhe->liqgeral);?></td>
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
							<th>Cr&iacute;tica</th>
							<th>Valor</th>
						</tr>
					</thead>
					<tbody>
						<?php foreach($dados->criticas->find("critica") AS $c) {?>
							<tr>
								<td><? echo $c->dsc;?></td>
								<td><? echo $c->vlr;?></td>
							</tr>
						<?} // Fim do foreach ?>	
					</tbody>
				</table>
			</div><!-- divRegistrosTitulosSelecionados -->
		</fieldset>
	</div><!-- divCritica -->

	<div id="divParecer" class="formulario">
		<fieldset>
			<legend>Pareceres</legend>
			<div class="divRegistrosPareceres divRegistros">
				<table class="tituloRegistros">
					<thead>
						<tr>
							<th>Data</th>
							<th>Operador</th>
							<th>Parecer</th>
						</tr>
					</thead>
					<tbody>
						<?php foreach($dados->pareceres->find("parecer") AS $c) {?>
							<tr>
								<td><?=$c->dtparecer?></td>
								<td><?=$c->nmoperad?></td>
								<td><?=$c->dsparecer?></td>
							</tr>
						<?} // Fim do foreach ?>
					</tbody>
				</table>
			</div><!-- divRegistrosTitulosSelecionados -->
			<textarea id="dsparecer" name="dsparecer" placeholder="-- digite o parecer" style="width:100%;"></textarea>
		</fieldset>
	</div><!-- divParecer -->
</form>


<div id="divBotoesTitulosLimite" style="margin-bottom:10px;">
	<input type="button" class="botao" value="Voltar"  onClick="voltarDetalhe();return false; " />
	<input type="button" class="botao" value="Gravar Parecer"  onClick='showConfirmacao("Deseja gravar o parecer do t&iacute;tulo?","Confirma&ccedil;&atilde;o - Ayllos","gravaParecer()","bloqueiaFundo(divRotina)","sim.gif","nao.gif")' />

<script type="text/javascript">
	hideMsgAguardo();
	formataLayoutDetalhes();
	// // Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));

</script>