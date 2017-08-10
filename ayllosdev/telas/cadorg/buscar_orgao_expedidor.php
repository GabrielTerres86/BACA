<?php
	/*!
	* FONTE        : buscar_orgao_pagador.php
	* CRIAÇÃO      : Adriano - CECRED
	* DATA CRIAÇÃO : Junho/2017
	* OBJETIVO     : Rotina para realizar a busca de orgão pagador
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
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$cdorgao_expedidor = isset($_POST["cdorgao_expedidor"]) ? $_POST["cdorgao_expedidor"] : 0;
	$nrregist = isset($_POST["nrregist"]) ? $_POST["nrregist"] : 0;
	$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 0;
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdorgao_expedidor>".$cdorgao_expedidor."</cdorgao_expedidor>";
	$xml .= "   <nrregist>".$nrregist."</nrregist>";
	$xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_CADORG", "CONSULTA_ORGAO_EXPEDIDOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],
	$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObj = getObjectXML($xmlResult);		
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "dsnacion";
		}
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'input,select\',\'#divConteudo\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'divConteudo\');',false);
	} 
		
	$registros	= $xmlObj->roottag->tags[0]->tags;	
	$qtregist   = $xmlObj->roottag->tags[0]->attributes['QTREGIST'];
?>


<form id="frmOrgaoExpedidor" name="frmOrgaoExpedidor" class="formulario" style="display:none;">

	<fieldset id="fsetOrgaoExpedidor" name="fsetNacionalidades" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Orgão expedidor"; ?></legend>
		
		<div class="divRegistros">		
			<table>
				<thead>
					<tr>
						<th>C&oacute;digo</th>
						<th>Descri&ccedil;&atilde;o</th>
					</tr>
				</thead>
				<tbody>
					<? foreach( $registros as $orgaos ) {    ?>
						<tr>	
							<td><span><? echo getByTagName($orgaos->tags,'cdorgao_expedidor'); ?></span><? echo getByTagName($orgaos->tags,'cdorgao_expedidor'); ?> </td>
							<td><span><? echo getByTagName($orgaos->tags,'nmorgao_expedidor'); ?></span><? echo getByTagName($orgaos->tags,'nmorgao_expedidor'); ?> </td>
							
							<input type="hidden" id="cdorgao_expedidor" name="cdorgao_expedidor" value="<? echo getByTagName($orgaos->tags,'cdorgao_expedidor'); ?>" />
							<input type="hidden" id="idorgao_expedidor" name="idorgao_expedidor" value="<? echo getByTagName($orgaos->tags,'idorgao_expedidor'); ?>" />
							<input type="hidden" id="nmorgao_expedidor" name="nmorgao_expedidor" value="<? echo getByTagName($orgaos->tags,'nmorgao_expedidor'); ?>" />
							
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
			
			<label for="cdorgao_expedidor"><? echo utf8ToHtml('C&oacute;digo:') ?></label>
			<input type="text" id="cdorgao_expedidor" name="cdorgao_expedidor" />
			
			<label for="nmorgao_expedidor"><? echo utf8ToHtml('Descri&ccedil;&atilde;o:') ?></label>
			<input type="text" id="nmorgao_expedidor" name="nmorgao_expedidor" />
			
			<input type="hidden" id="idorgao_expedidor" name="idorgao_expedidor"/>
														
			<br />
					
			<br style="clear:both" />
			
		</fieldset>
		
	</form>

<?}?>

<div id="divBotoesDetalhes" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
																			
	<?php if($cddopcao == 'A'){?>
	
		<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('2'); return false;">Voltar</a>	
		<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','alterarOrgaoExpedidor();','$(\'#btVoltar\',\'#divBotoesDetalhes\').focus();','sim.gif','nao.gif');return false;">Concluir</a>	
			
	<?php }else if($cddopcao == 'C'){?>
	
		<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('2'); return false;">Voltar</a>	
	
	<?php } ?>
	
</div>

<script type="text/javascript">
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		buscarOrgaoExpedidor(<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

	});
	
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		buscarOrgaoExpedidor(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		
	});	
	
	formataDetalhes();
		 
</script>