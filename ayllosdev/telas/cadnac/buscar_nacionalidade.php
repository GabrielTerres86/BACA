<?php
	/*!
	* FONTE        : buscar_nacionalidades.php
	* CRIAÇÃO      : Adriano - CECRED
	* DATA CRIAÇÃO : Junho/2017
	* OBJETIVO     : Rotina para realizar a busca das nacionalidades
	* --------------
	* ALTERAÇÕES   : 09/04/2018 - PRJ 414 - Incluido novas colunas na tabela e novos campos
	*							  no form de alteração (Mateus Z - Mouts)
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
	
	$cdnacion = isset($_POST["cdnacion"]) ? $_POST["cdnacion"] : 0;
	$nrregist = isset($_POST["nrregist"]) ? $_POST["nrregist"] : 0;
	$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 0;
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdnacion>".$cdnacion."</cdnacion>";
	$xml .= "   <nrregist>".$nrregist."</nrregist>";
	$xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_CADNAC", "CONSULTA_NACIONALIDADES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],
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


<form id="frmNacionalidades" name="frmNacionalidades" class="formulario" style="display:none;">

	<fieldset id="fsetNacionalidades" name="fsetNacionalidades" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Nacionalidades"; ?></legend>
		
		<div class="divRegistros">		
			<table>
				<thead>
					<tr>
						<th>C&oacute;digo</th>
						<th>Nacionalidade</th>
						<th>C&oacute;d</th>
						<th>Pa&iacute;s</th>
						<th>Acordo</th>
						<th>Dt.In&iacute;cio</th>
						<th>Dt.Fim</th>
					</tr>
				</thead>
				<tbody>
					<? foreach( $registros as $nacionalidade ) {    ?>
						<tr>	
							<td><span><? echo getByTagName($nacionalidade->tags,'cdnacion'); ?></span><? echo getByTagName($nacionalidade->tags,'cdnacion'); ?> </td>
							<td><span><? echo getByTagName($nacionalidade->tags,'dsnacion'); ?></span><? echo getByTagName($nacionalidade->tags,'dsnacion'); ?> </td>
							<!-- Inicio PRJ 414 -->
							<td><span><? echo getByTagName($nacionalidade->tags,'cdpais'); ?></span><? echo getByTagName($nacionalidade->tags,'cdpais'); ?> </td>
							<td><span><? echo getByTagName($nacionalidade->tags,'nmpais'); ?></span><? echo getByTagName($nacionalidade->tags,'nmpais'); ?> </td>
							<td><span><? echo getByTagName($nacionalidade->tags,'inacordo'); ?></span><? echo getByTagName($nacionalidade->tags,'inacordo'); ?> </td>
							<td><span><? echo getByTagName($nacionalidade->tags,'dtinicio'); ?></span><? echo getByTagName($nacionalidade->tags,'dtinicio'); ?> </td>
							<td><span><? echo getByTagName($nacionalidade->tags,'dtfinal'); ?></span><? echo getByTagName($nacionalidade->tags,'dtfinal'); ?> </td>
							<!-- Fim PRJ 414 -->
							
							<input type="hidden" id="cdnacion" name="cdnacion" value="<? echo getByTagName($nacionalidade->tags,'cdnacion'); ?>" />
							<input type="hidden" id="dsnacion" name="dsnacion" value="<? echo getByTagName($nacionalidade->tags,'dsnacion'); ?>" />
							<input type="hidden" id="cdpais" name="cdpais" value="<? echo getByTagName($nacionalidade->tags,'cdpais'); ?>" />
							<input type="hidden" id="nmpais" name="nmpais" value="<? echo getByTagName($nacionalidade->tags,'nmpais'); ?>" />
							<input type="hidden" id="inacordo" name="inacordo" value="<? echo getByTagName($nacionalidade->tags,'inacordo'); ?>" />
							<input type="hidden" id="dtinicio" name="dtinicio" value="<? echo getByTagName($nacionalidade->tags,'dtinicio'); ?>" />
							<input type="hidden" id="dtfinal" name="dtfinal" value="<? echo getByTagName($nacionalidade->tags,'dtfinal'); ?>" />
							
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
			
			<label for="dsnacion"><? echo utf8ToHtml('Nacionalidade:') ?></label>
			<input type="text" id="dsnacion" name="dsnacion" />
			
			<input type="hidden" id="cdnacion" name="cdnacion"/>
			<!-- Inicio PRJ 414 -->
			<label for="cdpais"><? echo utf8ToHtml('País:') ?></label>
			<input type="text" id="cdpais" name="cdpais" />
			<input type="text" id="nmpais" name="nmpais" />

			<label for="inacordo"><? echo utf8ToHtml('Acordo:') ?></label>
			<select name="inacordo" id="inacordo" class="campo">
				<option value=""></option>
				<option value="fatca">FATCA</option>
				<option value="crs">CRS</option>
			</select>

			<label for="dtinicio"><? echo utf8ToHtml('Data Início:') ?></label>
			<input type="text" id="dtinicio" name="dtinicio" />

			<label for="dtfinal"><? echo utf8ToHtml('Data Fim:') ?></label>
			<input type="text" id="dtfinal" name="dtfinal" />
			<!-- Fim PRJ 414 -->
					
			<br style="clear:both" />
			
		</fieldset>
		
	</form>

<?}?>

<div id="divBotoesDetalhes" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
																			
	<?php if($cddopcao == 'A'){?>
	
		<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('2'); return false;">Voltar</a>	
		<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','alterarNacionalidade();','$(\'#btVoltar\',\'#divBotoesDetalhes\').focus();','sim.gif','nao.gif');return false;">Concluir</a>	
			
	<?php }else if($cddopcao == 'C'){?>
	
		<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('2'); return false;">Voltar</a>	
	
	<?php } ?>
	
</div>

<script type="text/javascript">
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		buscarNacionalidades(<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

	});
	
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		buscarNacionalidades(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		
	});	
	
	formataDetalhes();
	formataTabelaNacionalidade();	
    	 
</script>