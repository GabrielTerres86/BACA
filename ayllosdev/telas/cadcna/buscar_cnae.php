<?php
	/*!
	* FONTE        : buscar_cnae.php
	* CRIAÇÃO      : Adriano - CECRED
	* DATA CRIAÇÃO : Julho/2017
	* OBJETIVO     : Rotina para realizar a busca de CNAE
	* --------------
	* ALTERAÇÕES   : 04/08/2017 - Ajuste para chamar package MATRIC (Adriano).
	* -------------- 
	*/		
 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$cdcnae = isset($_POST["cdcnae"]) ? $_POST["cdcnae"] : 0;
	$nrregist = isset($_POST["nrregist"]) ? $_POST["nrregist"] : 0;
	$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 0;
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcnae>".$cdcnae."</cdcnae>";
	$xml .= "   <nrregist>".$nrregist."</nrregist>";
	$xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "MATRIC", "CONSULTA_CNAE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],
	$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObj = getObjectXML($xmlResult);		
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "dscnae";
		}
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'input,select\',\'#divConteudo\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'divConteudo\');',false);
	} 
		
	$registros	= $xmlObj->roottag->tags[0]->tags;	
	$qtregist   = $xmlObj->roottag->tags[0]->attributes['QTREGIST'];
?>


<form id="frmCnae" name="frmCnae" class="formulario" style="display:none;">

	<fieldset id="fsetCnae" name="fsetCnae" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "CNAE"; ?></legend>
		
		<div class="divRegistros">		
			<table>
				<thead>
					<tr>
						<th>C&oacute;digo</th>
						<th>Descri&ccedil;&atilde;o</th>
					</tr>
				</thead>
				<tbody>
					<? foreach( $registros as $cnae ) {    ?>
						<tr>	
							<td><span><? echo getByTagName($cnae->tags,'cdcnae'); ?></span><? echo getByTagName($cnae->tags,'cdcnae'); ?> </td>
							<td><span><? echo getByTagName($cnae->tags,'dscnae'); ?></span><? echo getByTagName($cnae->tags,'dscnae'); ?> </td>
							
							<input type="hidden" id="cdcnae" name="cdcnae" value="<? echo getByTagName($cnae->tags,'cdcnae'); ?>" />
							<input type="hidden" id="dscnae" name="dscnae" value="<? echo getByTagName($cnae->tags,'dscnae'); ?>" />
							
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

<?php if($cddopcao == 'A'){?>

	<form id="frmDetalhes" name="frmDetalhes" class="formulario" style="display:none;">

		<fieldset id="fsetDetalhes" name="fsetDetalhes" style="padding:0px; margin:0px; padding-bottom:10px;">
			
			<legend><? echo "Dados"; ?></legend>
			
			<label for="dscnae"><? echo utf8ToHtml('CNAE:') ?></label>
			<input type="text" id="dscnae" name="dscnae" />
			
			<input type="hidden" id="cdcnae" name="cdcnae"/>
														
			<br />
					
			<br style="clear:both" />
			
		</fieldset>
		
	</form>

<?}?>

<div id="divBotoesDetalhes" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
																			
	<?php if($cddopcao == 'A'){?>
	
		<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('2'); return false;">Voltar</a>	
		<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','alterarCnae();','$(\'#btVoltar\',\'#divBotoesDetalhes\').focus();','sim.gif','nao.gif');return false;">Concluir</a>	
			
	<?php }else if($cddopcao == 'C'){?>
	
		<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('2'); return false;">Voltar</a>	
	
	<?php } ?>
	
</div>

<script type="text/javascript">
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		buscarCnae(<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

	});
	
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		buscarCnae(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		
	});	
	
	formataDetalhes();	
	    	 
</script>