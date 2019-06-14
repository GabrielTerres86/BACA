<?php 

	/********************************************************************
	 Fonte: principal.php                                             
	 Autor: Gabriel - Rkam                                                     
	 Data : Agosto - 2015                  Última Alteração: 25/07/2016
	                                                                  
	 Objetivo  : Mostrar opcao Principal da rotina de Atendimento da tela ATENDA                                          
	                                                                  	 
	 Alteraçães: 25/07/2016 - Correcao na forma de tratamento do retorno XML. SD 479874 (Carlos R.)
	 
	*********************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))');
	}		
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) ||
	    !isset($_POST["nrregist"]) ||
		!isset($_POST["nriniseq"])) {
		
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))');

	}	

	$nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;
	$nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 30;
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : null;
	
	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))');
	}
	
	// Monta o xml de requisição
	$xmlBuscaServicosOferecidos  = "";
	$xmlBuscaServicosOferecidos .= "<Root>";
	$xmlBuscaServicosOferecidos .= "   <Dados>";
	$xmlBuscaServicosOferecidos .= "	   <nrdconta>".$nrdconta."</nrdconta>";
	$xmlBuscaServicosOferecidos .= "	   <cddopcao>C</cddopcao>";
	$xmlBuscaServicosOferecidos .= "	   <nriniseq>".$nriniseq."</nriniseq>";
	$xmlBuscaServicosOferecidos .= "	   <nrregist>".$nrregist."</nrregist>";	
	$xmlBuscaServicosOferecidos .= "   </Dados>";
	$xmlBuscaServicosOferecidos .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlBuscaServicosOferecidos, "ATENDIMENTO", "BUSCASERVICOSATIVOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjServicos = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjServicos->roottag->tags[0]->name) && strtoupper($xmlObjServicos->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjServicos->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))');
	}
	
	$registros = ( isset($xmlObjServicos->roottag->tags) ) ? $xmlObjServicos->roottag->tags : array();
	$qtregist  = ( isset($xmlObjServicos->roottag->attributes["QTREGIST"]) ) ? $xmlObjServicos->roottag->attributes["QTREGIST"] : 0;
?>

<div id="divServicos">
	
	<div id="divTabelaServicos">
	
		<div class="divRegistros">
			<table>
				<thead>
					<tr>
						<th>Data/Hora</th>
						<th>Servi&ccedil;o</th>
						<th>Operador</th>		
					</tr>			
				</thead>
				<tbody>
					<?php foreach( $registros as $result ) {  ?>
						<tr>	
							<td><span><? echo getByTagName($result->tags,'dtatendimento'); ?></span> <? echo getByTagName($result->tags,'dtatendimento')." - ".getByTagName($result->tags,'hratendimento'); ; ?>  </td>
							<td><span><? echo getByTagName($result->tags,'nmservico'); ?></span><? echo getByTagName($result->tags,'nmservico'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'nmoperad'); ?></span><? echo getByTagName($result->tags,'nmoperad'); ?> </td>	
										
							<input type="hidden" id="dtatendimento" name="dtatendimento" value="<? echo getByTagName($result->tags,'dtatendimento'); ?>" />
							<input type="hidden" id="hratendimento" name="hratendimento" value="<?echo getByTagName($result->tags,'hratendimento'); ?>" />
							<input type="hidden" id="cdservico" name="cdservico" value="<?echo getByTagName($result->tags,'cdservico'); ?>" />
							<input type="hidden" id="nmservico" name="nmservico" value="<?echo getByTagName($result->tags,'nmservico'); ?>" />
							<input type="hidden" id="dsservico_solicitado" name="dsservico_solicitado" value="<?echo getByTagName($result->tags,'dsservico_solicitado'); ?>" />							
							
						</tr>	
					<? } ?>
				</tbody>
			</table>
		</div>
		<div id="divRegistrosRodape" class="divRegistrosRodape">
			<table>	
				<tr>
					<td>
						<? if (isset($qtregist) and $qtregist == 0){ $nriniseq = 0;} ?>
						<? if ($nriniseq > 1){ ?>
							   <a class="paginacaoAnt"><<< Anterior</a>
						<? }else{ ?>
								&nbsp;
						<? } ?>
					</td>
					<td>
						<? if (isset($nriniseq)) { ?>
							   Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
						<? } ?>
						
					</td>
					<td>
						<? if($qtregist > ($nriniseq + $nrregist - 1)) { ?>
							  <a class="paginacaoProx">Pr&oacute;ximo >>></a>
						<? }else{ ?>
								&nbsp;
						<? } ?>
					</td>
				</tr>
			</table>			
			
		</div>	
		
	</div> 
	
	<div id="divInformacoes" style="display:none">		
			
	</div>

	<div id="divBotoes" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
		
		<a href="#" class="botao" id="btVoltar" onClick="encerraRotina(true);">Voltar</a>
		<a href="#" class="botao" id="btConsultar" onClick="mostraFormServicos('C');">Consultar</a>
		<a href="#" class="botao" id="btAlterar" onClick="mostraFormServicos('A');">Alterar</a>
		<a href="#" class="botao" id="btIncluir" onClick="mostraFormServicos('I');">Incluir</a>
		<a href="#" class="botao" id="btExcluir" onClick="mostraFormServicos('E');">Excluir</a>
				
	</div>
		
</div>

<script type="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		buscaRegistro(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);				
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		buscaRegistro(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);	
	});	
	
	$('#divRegistrosRodape').formataRodapePesquisa();
	$('#divBotoes').css('display','block');

	controlaLayout("T");

	hideMsgAguardo();
	bloqueiaFundo(divRotina);

</script>
	
	



