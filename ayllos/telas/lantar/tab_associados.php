<? 
/*!
 * FONTE        : tab_associados.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 16/04/2013
 * OBJETIVO     : Tabela que apresenta a consulta de associados
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */ 
?>
<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<div id="divAssociados" name="divAssociados" >
	<br style="clear:both" />
	<div class="divRegistros">
		<table width="100%">
			<thead>
				<tr>
					<th><input type="checkbox" name="checkTodos" id="checkTodos" value="no" style="float:none; height:16;"/></th>
					<th><? echo utf8ToHtml('Conta') ?></th>
					<th><? echo utf8ToHtml('Nome do titular') ?></th>
					<th><? echo utf8ToHtml('Pac') ?></th>
					<th><? echo utf8ToHtml('Tipo pessoa') ?></th>
					<th><? echo utf8ToHtml('Tipo conta') ?></th>
					<th><? echo utf8ToHtml('Ch.') ?></th>
				</tr>
			</thead>
		<tbody>

		<?
		$conta = 0;
		foreach( $associados as $r ) { 		
			$conta++;
		?>
			<tr>
				<script>
				</script>
				<td align="center" valign="center">
					<input class="flgcheck" type="checkbox" name="<? echo 'flgcheck'.$conta; ?>" id="<? echo 'flgcheck'.$conta;?>" <? echo $marcar; ?> value="no" style="float:none; height:16;"/>
				</td>
				<td><span><? echo getByTagName($r->tags,'nrdconta'); ?></span>
					<? echo formataContaDV(getByTagName($r->tags,'nrdconta')); ?>
					<input type="hidden" id="<? echo 'nrdconta'.$conta;?>" name="<?echo 'nrdconta'.$conta;?>" value="<? echo getByTagName($r->tags,'nrdconta'); ?>" />
					<input type="hidden" id="<? echo 'cdagenci'.$conta;?>" name="<?echo 'cdagenci'.$conta;?>" value="<? echo getByTagName($r->tags,'cdagenci'); ?>" />
					<input type="hidden" id="<? echo 'nrmatric'.$conta;?>" name="<?echo 'nrmatric'.$conta;?>" value="<? echo getByTagName($r->tags,'nrmatric'); ?>" />
					<input type="hidden" id="<? echo 'cdtipcta'.$conta;?>" name="<?echo 'cdtipcta'.$conta;?>" value="<? echo getByTagName($r->tags,'cdtipcta'); ?>" />
					<input type="hidden" id="<? echo 'dstipcta'.$conta;?>" name="<?echo 'dstipcta'.$conta;?>" value="<? echo getByTagName($r->tags,'dstipcta'); ?>" />
					<input type="hidden" id="<? echo 'nmprimtl'.$conta;?>" name="<?echo 'nmprimtl'.$conta;?>" value="<? echo getByTagName($r->tags,'nmprimtl'); ?>" />
					<input type="hidden" id="<? echo 'qtdchcus'.$conta;?>" name="<?echo 'qtdchcus'.$conta;?>" value="<? echo getByTagName($r->tags,'qtdchcus'); ?>" />
					<script>
					
						var strConta = ($('<? echo '#nrdconta'.$conta;?>').val()) ;
						var marcar = 0;
						
						if ( strConta != '') {
								
							for(x=0;x<arrPesqAssociado.length;x++) {
								if ( arrPesqAssociado[x].nrdconta == strConta ) {
									marcar = 1;
								}
							}
							
							if ( marcar == 1 ) {
								$('<? echo '#flgcheck'.$conta;?>').prop("checked",true);	
							}
						
						}
					
					
						$('<? echo '#flgcheck'.$conta;?>').unbind('click').bind('click',
							function(e){
								if( $(this).prop('checked') == true ){
									var strAgencia = $('<? echo '#cdagenci'.$conta;?>').val() ;
									var strConta   = $('<? echo '#nrdconta'.$conta;?>').val().toString() ;
									var strNrmatric = $('<? echo '#nrmatric'.$conta;?>').val() ;
									var strCdtipcta = $('<? echo '#cdtipcta'.$conta;?>').val() ;
									var strDstipcta = $('<? echo '#dstipcta'.$conta;?>').val() ;
									var strNmprimtl = $('<? echo '#nmprimtl'.$conta;?>').val() ;
									var strQtdchcus = $('<? echo '#qtdchcus'.$conta;?>').val() ;
									var objPesqAssociado = new pesquisa(strAgencia, strConta, strNrmatric, strCdtipcta, strDstipcta, strNmprimtl, strQtdchcus);
									arrPesqAssociado.push( objPesqAssociado );
								} else {
									try{
										var strConta = ($('<? echo '#nrdconta'.$conta;?>').val()) ;
										
										for(x=0;x<arrPesqAssociado.length;x++) {
											if ( arrPesqAssociado[x].nrdconta == strConta ) {
												arrPesqAssociado.splice(x,1);
											}
											
										}
										
									}catch (e){
										alert('Erro eliminar registro.');
									}	
								}
							}
						)
					</script>
					
				</td>
				<td><span><? echo getByTagName($r->tags,'nmprimtl'); ?></span>
					<? echo getByTagName($r->tags,'nmprimtl'); ?>
				</td>
				<td><span><? echo getByTagName($r->tags,'cdagenci'); ?></span>
					<? echo getByTagName($r->tags,'cdagenci'); ?>
				</td>
				<? if ( getByTagName($r->tags,'inpessoa') == 1) { ?> 
					<td><span><? echo getByTagName($r->tags,'inpessoa'); ?></span>
						<? echo getByTagName($r->tags,'inpessoa')?> - Fisica
					</td>
				<? } else { ?>
					<td><span><? echo getByTagName($r->tags,'inpessoa'); ?></span>
						<? echo getByTagName($r->tags,'inpessoa')?> - Juridica
					</td>
				<? } ?>
				<td><span><? echo getByTagName($r->tags,'cdtipcta'); ?></span>
					<? echo getByTagName($r->tags,'cdtipcta'); ?> - <? echo getByTagName($r->tags,'dstipcta'); ?>
				</td>
				<td><span><? echo getByTagName($r->tags,'qtdchcus'); ?></span>
					<? echo getByTagName($r->tags,'qtdchcus'); ?>
				</td>
			</tr>
		<?	
		} 				
		?>
			
			</tbody>
		</table>
			<input type="hidden" id="qtdreg" name="qtdreg" value="<? echo $conta; ?>" />
	</div>
</div>


<div id="divPesquisaRodape" class="divPesquisaRodape">
	<table>	
		<tr>
			<td>
				<?
					//
					if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
					
					// Se a paginação não está na primeira, exibe botão voltar
					if ($nriniseq > 1) { 
						?> <a class='paginacaoAnt'><<< Anterior</a> <? 
					} else {
						?> &nbsp; <?
					}
				?>
			</td>
			<td>
				<?
					if (isset($nriniseq)) { 
						?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?><?
					}
				?>
			</td>
			<td>
				<?
					// Se a paginação não está na última página, exibe botão proximo
					if ($qtregist > ($nriniseq + $nrregist - 1)) {
						?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
					} else {
						?> &nbsp; <?
					}
				?>			
			</td>
		</tr>
	</table>
</div>

<div id="divBotoes" style="margin-bottom:10px">
	<a href="#" class="botao" id="btVoltar"    onClick="<? echo 'fechaRotina($(\'#divRotina\'))'?>; return false;">Voltar</a>
	<a href="#" class="botao" id="btConcluir"  onclick="btConcluirPesquisa()">Concluir</a>
</div>

<script type="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		buscaDadosAssociado(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		buscaDadosAssociado(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
</script>