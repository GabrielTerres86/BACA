<?php 

	/************************************************************************
	      Fonte: estouros.php
	      Autor: Guilherme
	Data : Fevereiro/2008               Ultima Alteracao: 13/07/2011

    Objetivo  : Mostrar opcao de Estouros da rotina de Ocorrencias da tela ATENDA

	Alteracoes: 13/07/2011 - Alterado para layout padrão (Rogerius - DB1).
				25/07/2016 - Correcao do uso inadequado da funcao utf8tohtml. SD 479874. Carlos R.	  

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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	

	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];

	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetEstouros  = "";
	$xmlGetEstouros .= "<Root>";
	$xmlGetEstouros .= "	<Cabecalho>";
	$xmlGetEstouros .= "		<Bo>b1wgen0027.p</Bo>";
	$xmlGetEstouros .= "		<Proc>lista_estouros</Proc>";
	$xmlGetEstouros .= "	</Cabecalho>";
	$xmlGetEstouros .= "	<Dados>";
	$xmlGetEstouros .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetEstouros .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetEstouros .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetEstouros .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetEstouros .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetEstouros .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetEstouros .= "		<idseqttl>1</idseqttl>";
	$xmlGetEstouros .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetEstouros .= "	</Dados>";
	$xmlGetEstouros .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetEstouros);

	// Cria objeto para classe de tratamento de XML
	$xmlObjEstouros = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlObjEstouros->roottag->tags[0]->name) && strtoupper($xmlObjEstouros->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjEstouros->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}

	$estouros = ( isset($xmlObjEstouros->roottag->tags[0]->tags) ) ? $xmlObjEstouros->roottag->tags[0]->tags : array();

	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) {
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}

?>


<div id="divTabEstouros">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th>Seq</th>
					<th>In&iacute;cio</th>
					<th>Dias</th>
					<th>Hist&oacute;rico</th>
					<th>Valor est/devol</th>
					<th>Conta base</th>
					<th>Documento</th>
				</tr>
			</thead>
			<tbody>
				<?php
                for ($i = 0; $i < count($estouros); $i++) {
				?>
					<tr>
						<td><span><?php echo $estouros[$i]->tags[0]->cdata ?></span>
								<?php echo formataNumericos("z.zzz.zzz",$estouros[$i]->tags[0]->cdata,".") ?>
								<input id="complem11" name="complem11" type="hidden" value="<?php echo $estouros[$i]->tags[7]->cdata." ".$estouros[$i]->tags[8]->cdata;  ?>" />
								<input id="complem21" name="complem21" type="hidden" value="<?php echo number_format(str_replace(",",".",$estouros[$i]->tags[9]->cdata),2,",","."); ?>" />
								<input id="complem31" name="complem31" type="hidden" value="<?php echo $estouros[$i]->tags[10]->cdata; ?>" />
								<input id="complem41" name="complem41" type="hidden" value="<?php echo $estouros[$i]->tags[11]->cdata; ?>" />
						</td>
						<td><span><?php echo $estouros[$i]->tags[1]->cdata; ?></span>
								<?php echo $estouros[$i]->tags[1]->cdata; ?>
						</td>
						<td><span><?php echo dataParaTimestamp($estouros[$i]->tags[2]->cdata); ?></span>
								<?php echo $estouros[$i]->tags[2]->cdata; ?>
						</td>
						<td><span><?php echo $estouros[$i]->tags[3]->cdata; ?></span>
								<?php echo $estouros[$i]->tags[3]->cdata; ?>
						</td>
						<td style="<?php echo (($estouros[$i]->tags[4]->cdata > 0) ? "color: #d63408;" : $style2); ?>">
							<span><?php echo str_replace(",",".",$estouros[$i]->tags[4]->cdata) ?></span>
								<?php echo number_format(str_replace(",",".",$estouros[$i]->tags[4]->cdata),2,",","."); ?>
						</td>
						<td><span><?php echo $estouros[$i]->tags[5]->cdata ?></span>
								<?php echo formataNumericos("zzz.zzz.z",$estouros[$i]->tags[5]->cdata,".") ?>
						</td>
						<td><span><?php echo $estouros[$i]->tags[6]->cdata ?></span>
								<?php echo formataNumericos("zzz.zzz.z",$estouros[$i]->tags[6]->cdata,"."); ?>
						</td>
	
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>

	<div id="divEstourosLinha1">
	<ul class="complemento">
	<li style="text-align:right">Observa&ccedil;&otilde;es:</li>
	<li id="complem1"><?php echo $estouros[0]->tags[7]->cdata." ".$estouros[0]->tags[8]->cdata;  ?></li>
	<li style="text-align:right">Limite Cr&eacute;dito:</li>
	<li id="complem2"><?php echo number_format(str_replace(",",".",$estouros[0]->tags[9]->cdata),2,",","."); ?></li>
	</ul>
	</div>

	<div id="divEstourosLinha2">
	<ul class="complemento">
	<li style="text-align:right">De:</li>
	<li id="complem3"><?php echo $estouros[0]->tags[10]->cdata; ?></li>
	<li style="text-align:right">Para:</li>
	<li id="complem4"><?php echo $estouros[0]->tags[11]->cdata; ?></li>
	</ul>
	</div>
	
</div>

<script type="text/javascript">
// Formata layout
formataEstouros();

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
