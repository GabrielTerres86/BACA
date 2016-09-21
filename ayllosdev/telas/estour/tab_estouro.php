<? 
/*!
 * FONTE        : tab_estouro.php
 * CRIAÇÃO      : Jéssica (DB1)					Última alteração: 02/09/2015
 * DATA CRIAÇÃO : 30/07/2013
 * OBJETIVO     : Tabela que apresenta os dados do estouro da tela ESTOUR
 
      Alterações: 02/09/2015 - Ajuste para correção da conversão realizada pela DB1
						      (Adriano).
 
 */	
 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
?>
<form id="frmTabela" class="formulario" >

	<div id="divRegistros" class="divRegistros">
		<table>
			<thead>
				<tr><th>Seq.</th>
					<th>Inicio</th>
					<th>Dias</th>				
					<th>Historico</th>
					<th>Valor Est/Devol</th>
					<th>Limite Credito</th>
				</tr>			
			</thead>
			<tbody>
				<?
				foreach($registros as $i) {      
			
					// Recebo todos valores em variáveis
					$nrseqdig	= getByTagName($i->tags,'nrseqdig');
					$dtiniest	= getByTagName($i->tags,'dtiniest');
					$qtdiaest 	= getByTagName($i->tags,'qtdiaest');
					$cdhisest 	= getByTagName($i->tags,'cdhisest');				
					$vlestour 	= getByTagName($i->tags,'vlestour');
					$vllimcre   = getByTagName($i->tags,'vllimcre');
												
				?>			
					<tr>
						<td><span><? echo $nrseqdig ?></span>
							<? echo $nrseqdig; ?>
							
							<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo mascara(getByTagName($i->tags,'nrdconta'),'####.###.#') ?>" />
							<input type="hidden" id="nmprimtl" name="nmprimtl" value="<? echo getByTagName($i->tags,'nmprimtl') ?>" />
							<input type="hidden" id="qtddtdev" name="qtddtdev" value="<? echo getByTagName($i->tags,'qtddtdev') ?>" />
							<input type="hidden" id="nrdctabb" name="nrdctabb" value="<? echo mascara(getByTagName($i->tags,'nrdctabb'),'#.###.###.#')?>" />
							<input type="hidden" id="nrdocmto" name="nrdocmto" value="<? echo mascara(getByTagName($i->tags,'nrdocmto'),'#.###.###.#')?>" />
							<input type="hidden" id="cdobserv" name="cdobserv" value="<? echo getByTagName($i->tags,'cdobserv') ?>" />
							<input type="hidden" id="dsobserv" name="dsobserv" value="<? echo getByTagName($i->tags,'dsobserv') ?>" />
							<input type="hidden" id="vllimcre" name="vllimcre" value="<? echo formataMoeda(getByTagName($i->tags,'vllimcre')) ?>" />
							<input type="hidden" id="dscodant" name="dscodant" value="<? echo getByTagName($i->tags,'dscodant') ?>" />   
							<input type="hidden" id="dscodatu" name="dscodatu" value="<? echo getByTagName($i->tags,'dscodatu') ?>" />
							

						</td>
											
						<td> <? echo $dtiniest ?> </td>
						<td> <? echo $qtdiaest ?> </td>
						<td> <? echo $cdhisest ?> </td>
						
						<td><span><? echo converteFloat($vlestour,'MOEDA') ?></span>
								  <? echo formataMoeda($vlestour); ?></td>
						
						<td><span><? echo converteFloat($vllimcre,'MOEDA') ?></span>
								  <? echo formataMoeda($vllimcre); ?></td>
										
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
					<?if($qtregist > ($nriniseq + $nrregist - 1)) { ?>
						  <a class="paginacaoProx">Pr&oacute;ximo >>></a>
					<? }else{ ?>
							&nbsp;
					<? } ?>
				</td>
			</tr>
		</table>
	</div>			
	
	<form id="frmConsulta" name="frmConsulta" class="formulario">
		
		<fieldset id="fsetDetalhes">
		
			<legend><? echo utf8ToHtml('Detalhes') ?></legend>
			
			<div id="divEstouro" >
			
				
				<label for="nrdctabb"><? echo utf8ToHtml('Conta Base:') ?></label>
				<input id="nrdctabb" name="nrdctabb" type="text"/>
			
				<label for="nrdocmto"><? echo utf8ToHtml('Documento:') ?></label>
				<input id="nrdocmto" name="nrdocmto" type="text"/>
				
				<label for="cdobserv"><? echo utf8ToHtml('Observa&ccedil;&atilde;o:') ?></label>
				<input id="cdobserv" name="cdobserv" type="text"/>
				<input id="dsobserv" name="dsobserv" type="text"/>
			
				<br />
				
				<label for="dscodant"><? echo utf8ToHtml('De:') ?></label>
				<input id="dscodant" name="dscodant" type="text"/>
				
				<label for="dscodatu"><? echo utf8ToHtml('Para:') ?></label>
				<input id="dscodatu" name="dscodatu" type="text"/>
					
				<br style="clear:both" />
				
			</div>
		
		</fieldset>
		
	</form>

</form>

<script type="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		buscaEstouro(<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		buscaEstouro(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		
	});		
	
	$('#divRegistrosRodape','#frmTabela').formataRodapePesquisa();
			
    formataTabela();
	$('#divBotoes').css({'display':'block'});	
	$('#nrdconta','#frmCab').desabilitaCampo();
							
</script>
