<?php 

	/************************************************************************
	 Fonte: historico_de_participacao_eventos_cooperado.php                                             
	 Autor: Guilherme                                                 
	 Data : Setembro/2009                Ultima Alteracao:  27/07/2016    
	                                                                  
	 Objetivo  : Mostrar eventos que o cooperado participou no per&iacute;odo
	                                                                  	 
	 Alteracoes: 09/02/2011 - Incluir parametro na chamada da Procedure (Gabriel).                                                  

					14/07/2011 - Alterado para layout padrão (Rogerius - DB1). 	

				 27/07/2016 - Corrigi o retorno XML e o uso de variaveis do array XML. SD 479874 (Carlos R.)
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
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["inianoev"]) ||
		!isset($_POST["finanoev"]) ||
		!isset($_POST["idevento"]) ||
		!isset($_POST["cdevento"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$inianoev = $_POST["inianoev"];
	$finanoev = $_POST["finanoev"];
	$idevento = $_POST["idevento"];	
	$cdevento = $_POST["cdevento"];

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($inianoev) && ($inianoev > 0)) {
		exibeErro("Ano in&iacute;cio da pesquisa inv&aacute;lido.");
	}

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($finanoev) && ($finanoev > 0)) {
		exibeErro("Ano fim da pesquisa inv&aacute;lido.");
	}
	
	// Verifica se o c&oacute;digo do identificador do evento &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($idevento)) {
		exibeErro("C&oacute;digo do identificador do evento inv&aacute;lido.");
	}	
	
	// Verifica se o c&oacute;digo do evento &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($cdevento)) {
		exibeErro("C&oacute;digo do evento inv&aacute;lido.");
	}	

	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetDadosEventosHistoricoCooperado  = "";
	$xmlGetDadosEventosHistoricoCooperado .= "<Root>";
	$xmlGetDadosEventosHistoricoCooperado .= "	<Cabecalho>";
	$xmlGetDadosEventosHistoricoCooperado .= "		<Bo>b1wgen0039.p</Bo>";
	$xmlGetDadosEventosHistoricoCooperado .= "		<Proc>obtem-historico</Proc>";
	$xmlGetDadosEventosHistoricoCooperado .= "	</Cabecalho>";
	$xmlGetDadosEventosHistoricoCooperado .= "	<Dados>";
	$xmlGetDadosEventosHistoricoCooperado .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDadosEventosHistoricoCooperado .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDadosEventosHistoricoCooperado .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDadosEventosHistoricoCooperado .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDadosEventosHistoricoCooperado .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDadosEventosHistoricoCooperado .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetDadosEventosHistoricoCooperado .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDadosEventosHistoricoCooperado .= "		<inipesqu>".$inianoev."</inipesqu>"; // Ano atual para trazer por 
	$xmlGetDadosEventosHistoricoCooperado .= "		<finpesqu>".$finanoev."</finpesqu>"; // default os eventos do ano
	$xmlGetDadosEventosHistoricoCooperado .= "		<idevento>".$idevento."</idevento>";
	$xmlGetDadosEventosHistoricoCooperado .= "		<cdevento>".$cdevento."</cdevento>";
	$xmlGetDadosEventosHistoricoCooperado .= "		<tpimpres>T</tpimpres>"; // Terminal
	$xmlGetDadosEventosHistoricoCooperado .= "		<idseqttl>1</idseqttl>";
	$xmlGetDadosEventosHistoricoCooperado .= "	</Dados>";
	$xmlGetDadosEventosHistoricoCooperado .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDadosEventosHistoricoCooperado);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosEventosHistoricoCooperado = getObjectXML($xmlResult);
	
	$histEventos = ( isset($xmlObjDadosEventosHistoricoCooperado->roottag->tags[0]->tags) ) ? $xmlObjDadosEventosHistoricoCooperado->roottag->tags[0]->tags : array();
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlObjDadosEventosHistoricoCooperado->roottag->tags[0]->name) && strtoupper($xmlObjDadosEventosHistoricoCooperado->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDadosEventosHistoricoCooperado->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}	
?>	
<div id="divEventosdoHistorico">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th>Nome inscrito</th>
					<th>Nome evento</th>
				</tr>
			</thead>
			<tbody>
				<?php
				for ($i = 0; $i < count($histEventos); $i++) { 								
				?>
					<tr>
						<td><span><?php echo $histEventos[$i]->tags[0]->cdata; ?></span>
								<?php echo $histEventos[$i]->tags[0]->cdata; ?>
								<input id="situacao" name="situacao" type="hidden" value="<?php echo $histEventos[$i]->tags[4]->cdata; ?>" />
								<input id="dtinicio" name="dtinicio" type="hidden" value="<?php echo $histEventos[$i]->tags[2]->cdata; ?>" />
								<input id="dtfim" name="dtfim" type="hidden" value="<?php echo $histEventos[$i]->tags[3]->cdata; ?>" />
						</td>
						<td><span><?php echo $histEventos[$i]->tags[1]->cdata; ?></span>
								<?php echo $histEventos[$i]->tags[1]->cdata; ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
</div>


<ul class="complemento">
<li>Situa&ccedil;&atilde;o:</li>
<li id="situacao"><?php echo ( isset($histEventos[0]->tags[4]->cdata) ) ? $histEventos[0]->tags[4]->cdata : ''; ?></li>
<li>In&iacute;cio:</li>
<li id="dtinicio"><?php echo ( isset($histEventos[0]->tags[2]->cdata) ) ? $histEventos[0]->tags[2]->cdata : ''; ?></li>
<li>Fim:</li>
<li id="dtfim"><?php echo ( isset($histEventos[0]->tags[3]->cdata) ) ? $histEventos[0]->tags[3]->cdata : ''; ?></li>
</ul>

<div id="divBotoes" style="margin-bottom:3px">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="$('#divOpcoesDaOpcao2').css('display','none');$('#divOpcoesDaOpcao1').css('display','block');return false;">
</div>	



<script type="text/javascript">

// Formata
formataEventosdoHistorico();

$('th','#divEventosdoHistorico').css({'padding':'2px'});
$('td','#divEventosdoHistorico').css({'padding':'2px 2px 2px 4px'});

$("#divOpcoesDaOpcao1").css("display","none");
$("#divOpcoesDaOpcao2").css("display","block");

// Esconde mensagem de aguardo
hideMsgAguardo();
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>