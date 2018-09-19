<?php 

	/************************************************************************
	 Fonte: eventos_em_andamento_situacao_da_inscricao.php                                            
	 Autor: Guilherme                                                 
	 Data : Setembro/2009                Ultima Alteracao:  25/07/2016     
	                                                                  
	 Objetivo  : Consultar a situacao da inscricao do evento
	                                                                  	 
	 Alteracoes: 28/06/2016 - Removido os botões “Desistente” e “Excedente” e
                              alterar o nome do botão de “Excluído” para “Excluir”.
                              PRJ229 - Melhorias OQS(Odirlei-AMcom)
							       
	             25/07/2016 - Corrigi o retorno XML de erro. SD 479874 (Carlos R.)                                                     
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
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["imptermo"]) ||
		!isset($_POST["rowidedp"]) ||
		!isset($_POST["rowidadp"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$imptermo = $_POST["imptermo"];
	$rowidedp = $_POST["rowidedp"];
	$rowidadp = $_POST["rowidadp"];	
	$dsobserv = ( isset($_POST["dsobserv"]) ) ? $_POST["dsobserv"] : '';

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	

	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetSituacaoInscricao  = "";
	$xmlGetSituacaoInscricao .= "<Root>";
	$xmlGetSituacaoInscricao .= "	<Cabecalho>";
	$xmlGetSituacaoInscricao .= "		<Bo>b1wgen0039.p</Bo>";
	$xmlGetSituacaoInscricao .= "		<Proc>situacao-inscricao</Proc>";
	$xmlGetSituacaoInscricao .= "	</Cabecalho>";
	$xmlGetSituacaoInscricao .= "	<Dados>";
	$xmlGetSituacaoInscricao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetSituacaoInscricao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetSituacaoInscricao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetSituacaoInscricao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetSituacaoInscricao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetSituacaoInscricao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetSituacaoInscricao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetSituacaoInscricao .= "		<dsobserv>".$dsobserv."</dsobserv>";
	$xmlGetSituacaoInscricao .= "		<idseqttl>1</idseqttl>";
	$xmlGetSituacaoInscricao .= "		<rowidedp>".$rowidedp."</rowidedp>";
	$xmlGetSituacaoInscricao .= "		<rowidadp>".$rowidadp."</rowidadp>";
	$xmlGetSituacaoInscricao .= "	</Dados>";
	$xmlGetSituacaoInscricao .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetSituacaoInscricao);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjSituacaoInscricao = getObjectXML($xmlResult);
	
	$eventos = ( isset($xmlObjSituacaoInscricao->roottag->tags[0]->tags) ) ? $xmlObjSituacaoInscricao->roottag->tags[0]->tags : array();
	
	$qtEventoSI = count($eventos);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlObjSituacaoInscricao->roottag->tags[0]->name) && strtoupper($xmlObjSituacaoInscricao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjSituacaoInscricao->roottag->tags[0]->tags[0]->tags[4]->cdata);
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
<script type="text/javascript">
function metodoBlock(){
	blockBackground(parseInt($("#divRotina").css("z-index")));
}
</script>


<form id="formEventosdoSI" onSubmit="return false" class="formulario">
	<fieldset>
		<legend>Situa&ccedil;&atilde;o da Inscri&ccedil;&atilde;o</legend>

	<div id="divEventosdoSI">		
		<div class="divRegistros">	
			<table>
				<thead>
					<tr>
						<th>Evento</th>
						<th>In&iacute;cio</th>
						<th>Inscrito</th>
					</tr>
				</thead>
				<tbody>
					<?php 
					for ($i = 0; $i < $qtEventoSI; $i++) {
						$aux = $i + 1;;
						$seleciona = "selecionaEventoSituacaoInscricao(".$aux.",".$qtEventoSI.",'".$eventos[$i]->tags[0]->cdata."');";	
					?>
						<tr id="trEventoSI<?php echo $i + 1; ?>" style="cursor: pointer; " onFocus="<? echo $seleciona ?>" onClick="<? echo $seleciona ?>">
							<td><span><?php echo  $eventos[$i]->tags[1]->cdata; ?></span>
									<?php echo stringTabela($eventos[$i]->tags[1]->cdata, 30, 'maiuscula'); ?>
							</td>
							<td><span><?php echo dataParaTimestamp($eventos[$i]->tags[2]->cdata); ?></span>
									<?php echo $eventos[$i]->tags[2]->cdata; ?>
							</td>
							<td><span><?php echo $eventos[$i]->tags[3]->cdata; ?></span>
									<?php echo stringTabela($eventos[$i]->tags[3]->cdata, 30, 'maiuscula'); ?>
							</td>
						</tr>
				<?php } ?>	
				</tbody>
			</table>
		</div>
	</div>
</form>

<ul class="complemento">
<li>Situa&ccedil;&atilde;o</li>
<li id="situacao"><?php echo $eventos[0]->tags[4]->cdata; ?></li>
<li>Confirm:</li>
<li id="confirm"><?php echo $eventos[0]->tags[5]->cdata; ?></li>
<li>Int:</li>
<li id="int"><?php if($eventos[0]->tags[6]->cdata == "no"){echo "N&atilde;o";}else{echo "Sim";} ?></li>
</ul>

<div id="divBotoes">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="$('#divOpcoesDaOpcao2').css('display','none');$('#divOpcoesDaOpcao1').css('display','block');return false;">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/pendente.gif" <?php if (!in_array("A",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"';   } else { echo 'onClick="msgConfirmaStatus(1,\''.$imptermo.'\');return false;"'; } ?>>
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/confirmado.gif" <?php if (!in_array("A",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="msgConfirmaStatus(2,\''.$imptermo.'\');return false;"'; } ?>>
	<!-- Remover botoes 
    <input type="hidden" src="<?php echo $UrlImagens; ?>botoes/desistente.gif" <?php if (!in_array("A",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="msgConfirmaStatus(3,\''.$imptermo.'\');return false;"'; } ?>>
    <input type="hidden" src="<?php echo $UrlImagens; ?>botoes/excedente.gif" <?php if (!in_array("A",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"';  } else { echo 'onClick="msgConfirmaStatus(5,\''.$imptermo.'\');return false;"'; } ?>>					
	-->
    <input type="image" src="<?php echo $UrlImagens; ?>botoes/excluir.gif" <?php if (!in_array("A",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"';   } else { echo 'onClick="msgConfirmaStatus(4,\''.$imptermo.'\');return false;"'; } ?>>	
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/termo.gif" <?php if ($imptermo == "no"){ echo 'style="cursor: default" onClick="return false;"';}else{ echo 'onClick="gerarImpressao(1,0);return false;"';}?>>
</div>


<script type="text/javascript">
formataEventosdoSI();

$("#divOpcoesDaOpcao1").css("display","none");
$("#divOpcoesDaOpcao2").css("display","block");

selecionaEventoSituacaoInscricao(1,<?php echo $qtEventoSI; ?>,'<?php echo $eventos[0]->tags[0]->cdata; ?>');

// Esconde mensagem de aguardo
hideMsgAguardo();
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>