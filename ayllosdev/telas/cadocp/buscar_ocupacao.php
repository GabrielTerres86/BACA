<?php
	/*!
	* FONTE        : buscar_ocupacao.php
	* CRIAÇÃO      : Kelvin Souza Ott - CECRED
	* DATA CRIAÇÃO : Agosto/2017
	* OBJETIVO     : Rotina para realizar a busca das ocupacoes
	* --------------
	* ALTERAÇÕES   : 
	* -------------- 
	*/		
 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') 		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	
	if($cddopcao != 'I') {
	
		$cdnatocp = isset($_POST["cdnatocp"]) ? $_POST["cdnatocp"] : 0;
		$nrregist = isset($_POST["nrregist"]) ? $_POST["nrregist"] : 0;
		$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 0;
		
		// Montar o xml de Requisicao
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <cdnatocp>".$cdnatocp."</cdnatocp>";
		$xml .= "   <nrregist>".$nrregist."</nrregist>";
		$xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
		
		$xmlResult = mensageria($xml, "TELA_CADOCP", "PC_CONSULTA_OCUPACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],
		$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		
		$xmlObj = getObjectXML($xmlResult);		
		
		//-----------------------------------------------------------------------------------------------
		// Controle de Erros
		//-----------------------------------------------------------------------------------------------
		if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
			$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
			
			if($msgErro == null || $msgErro == '')
				$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;		
			
			exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'input,select\',\'#divConteudo\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'divConteudo\');',false);
		} 
			
		$registros	= $xmlObj->roottag->tags[0]->tags;	
			
		$qtregist   = $xmlObj->roottag->tags[1]->cdata;
	}
?>

<?php if($cddopcao != 'I'){?>
	<form id="frmOcupacao" name="frmOcupacao" class="formulario" style="display:none;">

		<fieldset id="fsetOcupacao" name="fsetOcupacao" style="padding:0px; margin:0px; padding-bottom:10px;">
			
			<legend><? echo "Ocupação"; ?></legend>
			
			<div class="divRegistros">		
				<table>
					<thead>
						<tr>
							<th>C&oacute;digo</th>
							<th>Descri&ccedil;&atilde;o</th>
							<th>Descri&ccedil;&atilde;o resumida</th>
						</tr>
					</thead>
					<tbody>
						<? foreach( $registros as $ocupacao ) {    ?>
							<tr>	
								<td><span><? echo getByTagName($ocupacao->tags,'cdocupa'); ?></span><? echo getByTagName($ocupacao->tags,'cdocupa'); ?> </td>
								<td><span><? echo getByTagName($ocupacao->tags,'dsdocupa'); ?></span><? echo getByTagName($ocupacao->tags,'dsdocupa'); ?> </td>
								<td><span><? echo getByTagName($ocupacao->tags,'rsdocupa'); ?></span><? echo getByTagName($ocupacao->tags,'rsdocupa'); ?> </td>
								
								<input type="hidden" id="cdocupa" name="cdocupa" value="<? echo getByTagName($ocupacao->tags,'cdocupa'); ?>" />							
								<input type="hidden" id="dsdocupa" name="dsdocupa" value="<? echo getByTagName($ocupacao->tags,'dsdocupa'); ?>" />
								<input type="hidden" id="rsdocupa" name="rsdocupa" value="<? echo getByTagName($ocupacao->tags,'rsdocupa'); ?>" />
								
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
		</fieldset>	
	</form>
<?}?>
<?php if($cddopcao == 'A' || $cddopcao == 'I'){?>

	<form id="frmDetalhes" name="frmDetalhes" class="formulario" style="display:none;">

		<fieldset id="fsetDetalhes" name="fsetDetalhes" style="padding:0px; margin:0px; padding-bottom:10px;">
			
			<legend><? echo "Dados"; ?></legend>
			
			<?php if($cddopcao != 'I'){?>
				<label for="cdocupa"><? echo utf8ToHtml('C&oacute;digo:') ?></label>
				<input type="text" id="cdocupa" name="cdocupa" />
			<?}?>
			
			<label for="dsdocupa"><? echo utf8ToHtml('Descri&ccedil;&atilde;o:') ?></label>
			<input type="text" id="dsdocupa" name="dsdocupa" />
			
			<label for="rsdocupa"><? echo utf8ToHtml('Descri&ccedil;&atilde;o resumida:') ?></label>
			<input type="text" id="rsdocupa" name="rsdocupa" />
														
			<br />
					
			<br style="clear:both" />
			
		</fieldset>
		
	</form>

<?}?>

<div id="divBotoesDetalhes" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
			
	<?php if($cddopcao == 'A'){?>
	
		<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('2'); return false;">Voltar</a>	
		<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','alterarOcupacao();','$(\'#btVoltar\',\'#divBotoesDetalhes\').focus();','sim.gif','nao.gif');return false;">Concluir</a>	
			
	<?php }else if($cddopcao == 'C'){?>
	
		<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('2'); return false;">Voltar</a>	
	
	<?php }else if($cddopcao == 'I'){?>
	
		<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('2'); return false;">Voltar</a>	
		<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','incluirOcupacao();','$(\'#btVoltar\',\'#divBotoesDetalhes\').focus();','sim.gif','nao.gif');return false;">Concluir</a>	
	
	<?php }else if($cddopcao == 'E'){?>
	
		<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('2'); return false;">Voltar</a>	
		<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','excluirOcupacao();','$(\'#btVoltar\',\'#divBotoesDetalhes\').focus();','sim.gif','nao.gif');return false;">Concluir</a>	
	
	<?php } ?>
	
</div>

<script type="text/javascript">
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		buscarOcupacao(<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

	});
	
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		buscarOcupacao(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		
	});	
	
	formataDetalhes();
		 
</script>

