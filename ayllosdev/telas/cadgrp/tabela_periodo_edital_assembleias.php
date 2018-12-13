<?php
/* 
 * FONTE        : tabela_periodo_edital_assembleias.php.php
 * CRIAÇÃO      : Jonata - Mouts
 * DATA CRIAÇÃO : Setembro/2018
 * OBJETIVO     : Tabela da opção "E"
 */
 
 
 session_start();
 require_once('../../includes/config.php');
 require_once('../../includes/funcoes.php');
 require_once('../../includes/controla_secao.php');		
 require_once('../../class/xmlfile.php');
 isPostMethod();

 
?>
  
<form id="frmPeriodo" name="frmPeriodo" class="formulario">

	<fieldset id="fsetPeriodo" name="fsetPeriodo" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Per&iacute;odos"; ?></legend>

		<label for="tituloAssembleias"><?php echo utf8ToHtml("Edital Assembleias"); ?></label>
		<label for="tituloTravamento"><?php echo utf8ToHtml("Travamento de grupos"); ?></label>
		
		<div class="divRegistros">		
			<table>
				<thead>
					<tr>
						<th>Exerc&iacute;cio</th>
						<th>Inicio</th>
						<th>Fim</th>
						<th><?php echo "Situa&ccedil;&atilde;o" ?></th>
					</tr>
				</thead>
				<tbody>
					<? foreach( $registros as $result ) {    

						$VR_FLAGTIVO = getByTagName($result->tags,'flgativo');

						?>
						<tr>	
							<td><span><? echo getByTagName($result->tags,'nrano_exercicio'); ?></span> <? echo getByTagName($result->tags,'nrano_exercicio'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'dtinicio_grupo'); ?></span><? echo getByTagName($result->tags,'dtinicio_grupo'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'dtfim_grupo'); ?></span><? echo getByTagName($result->tags,'dtfim_grupo'); ?> </td>
							<td class='tdAtivo'>
								<span><? echo $VR_FLAGTIVO ?></span>
								<? echo $VR_FLAGTIVO ?>
							</td>
							
							<input type="hidden" id="rowid" name="rowid" value="<? echo getByTagName($result->tags,'rowid'); ?>" />
							<input type="hidden" id="nrano_exercicio" name="nrano_exercicio" value="<? echo getByTagName($result->tags,'nrano_exercicio'); ?>" />
							<input type="hidden" id="dtinicio_grupo" name="dtinicio_grupo" value="<? echo getByTagName($result->tags,'dtinicio_grupo'); ?>" />
							<input type="hidden" id="dtfim_grupo" name="dtfim_grupo" value="<? echo getByTagName($result->tags,'dtfim_grupo'); ?>" />
							<input type="hidden" id="flgativo" name="flgativo" value="<? echo $VR_FLAGTIVO; ?>" />
														
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

<div id="divBotoesPeriodos" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:block;' >
																			
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1'); return false;">Voltar</a>																																							
	<a href="#" class="botao" id="btAlterar" >Alterar</a>
	<a href="#" class="botao" id="btIncluir" >Incluir</a>
	<a href="#" class="botao" id="btExcluir" >Excluir</a>
	<a href="#" class="botao" id="btAtivar" >Ativar</a>
	   																			
</div>



<script type="text/javascript">
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		consultaPeriodoEditalAssembleias(<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

	});
	
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		consultaPeriodoEditalAssembleias(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		
	});			
				
	formataTabelaPeriodos();	
	
				
</script>