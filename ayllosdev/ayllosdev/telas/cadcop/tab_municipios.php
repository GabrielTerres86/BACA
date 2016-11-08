<?
/* * *********************************************************************

  Fonte: tab_municipios.php
  Autor: Andrei - RKAM
  Data : Agosto/2016                       Última Alteração:  

  Objetivo  : Mostrar tabela com de municipios.

  Alterações:  

 * ********************************************************************* */

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	require_once("../../includes/carrega_permissoes.php");	

?>
<form id="frmMunicipios" name="frmMunicipios" class="formulario" style="display:none;">
		
	<fieldset id="fsetMunicipios" name="fsetMunicipioss" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Munic&iacute;pio(s)</legend>

		<div class="divRegistros">
		
			<table class="tituloRegistros" id="tbRegFinalidades">
				<thead>
					<tr>
						<th>Cidade</th>
						<th>UF</th>							
					</tr>
				</thead>
				<tbody>
					<? foreach( $registros as $result ) {    ?>
						<tr>	
							<td><span><? echo getByTagName($result->tags,'dscidade'); ?></span> <? echo getByTagName($result->tags,'dscidade'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'cdestado'); ?></span> <? echo getByTagName($result->tags,'cdestado'); ?> </td>
							<input type="hidden" id="cdcidade" name="cdcidade" value="<? echo getByTagName($result->tags,'cdcidade'); ?>" />
						
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

<div id="divBotoesMunicipios" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
																			
	<a href="#" class="botao" id="btVoltar" onClick="estadoInicial();return false;">Voltar</a>
	<a href="#" class="botao" id="btIncluir" >Incluir</a>
	<a href="#" class="botao" id="btExcluir" >Excluir</a>
																				
</div>

<script type="text/javascript">
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		consultaMunicipios(<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		consultaMunicipios(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		
	});		

	formataTabelaMunicipios();
	$('#divRegistrosRodape','#divTabela').formataRodapePesquisa();
	$('#divTabela').css('display','block');
	$('#frmMunicipios').css('display','block');
	$('#divBotoesMunicipios').css('display','block');
	
				
</script>

