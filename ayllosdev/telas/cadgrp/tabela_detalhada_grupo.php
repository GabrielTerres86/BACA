<?php
/* 
 * FONTE        : tabela_detalhada_grupo.php
 * CRIAÇÃO      : Jonata - Mouts
 * DATA CRIAÇÃO : Setembro/2018
 * OBJETIVO     : Tabela da opcao "C"
 */
 
 
 session_start();
 require_once('../../includes/config.php');
 require_once('../../includes/funcoes.php');	
 require_once('../../includes/controla_secao.php');		
 require_once('../../class/xmlfile.php');
 isPostMethod();	

?>
 
 
<form id="frmDetalhadaGrupo" name="frmDetalhadaGrupo" class="formulario">

	<fieldset id="fsetDetalhadaGrupo" name="fsetDetalhadaGrupo" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Detalhes"; ?></legend>
		
		<div class="divRegistros">		
			<table >
				<thead>
					<tr>
						<th>Grupo</th>
						<th>Cargo</th>
						<th>Conta</th>
						<th>CPF/CNPJ</th>
						<th>Nome Completo</th>
					</tr>
				</thead>
				<tbody>
					<? foreach( $registros as $result ) {    ?>
						<tr>	
							<td><span><? echo getByTagName($result->tags,'nrdgrupo'); ?></span> <? echo getByTagName($result->tags,'nrdgrupo'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'dsfuncao'); ?></span> <? echo getByTagName($result->tags,'dsfuncao'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'nrdconta'); ?></span> <? echo getByTagName($result->tags,'nrdconta'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'nrcpfcgc'); ?></span> <? echo getByTagName($result->tags,'nrcpfcgc'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'nmprimtl'); ?></span> <? echo getByTagName($result->tags,'nmprimtl'); ?> </td>
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

<div id="divBotoesDetalhadaGrupo" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:block;' >
																			
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('5'); return false;">Voltar</a>
  <a href="#" class="botao" id="btExportarCSV" onClick="exportar_csv(); return false;">Exportar</a>

</div>

<script type="text/javascript">
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		consultaDetalhadaGrupos(<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

	});
	
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		consultaDetalhadaGrupos(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		
	});			
	
	$('input, select','#frmFiltroConsultaDetalhada').desabilitaCampo();
    $('#divBotoesFiltroConsultaDetalhda').css('display', 'none');
	formataTabelaDetalhadaGrupo();	
	
				
</script>