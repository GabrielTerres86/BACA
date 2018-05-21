<?php
/*!
 * FONTE        : tab_prestacoes.php
 * CRIAÇÃO      : Jorge I. Hamaguchi
 * DATA CRIAÇÃO : 01/08/2011 
 * OBJETIVO     : Tabela que apresenta a consulta Prestacoes
 * --------------------------------------------------------------------------------------------------
 * ALTERAÇÕES   : 05/06/2014 - Ajuste para armazenar o nome do avalista. (James)
 *
 *				  28/07/2014 - Ajustado campo  <th> "contato" para "contrato" (Daniel)	
 *
 *			      03/11/2014 - Incluso botao Transf. p/ Prejuizo (Daniel)
 *
 *                25/11/2014 - Incluido um campo hidden "cdorigem". (Jaison)
 *				
 * 				  06/01/2015 - Padronizando a mascara do campo nrctremp.
 *	   	                       10 Digitos - Campos usados apenas para visualização
 *			                   8 Digitos - Campos usados para alterar ou incluir novos contratos
 *				               (Kelvin - SD 233714)
 *
 *                27/05/2015 - Inclusao do botao "Portabilidade". (Jaison/Diego - SD: 290027)
 *
 *				  21/07/2016 - Removi o session_start desnecessario, removi a funcao utf8tohtml
 *							   desnecessaria, corrigi o uso da variavel $opcoesTela. SD 479874 (Carlos R.)
 *
 *                11/05/2017 - Exibir produto Pos-Fixado. (Jaison/James - PRJ298)

 *                17/01/2018 - Inclusão do botão "Alterar Qualificação" ( Diego Simas - AMcom )
 * --------------------------------------------------------------------------------------------------
 */
 
	isPostMethod();	
	
?>

<div id="tabPrestacao">
	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><?php echo 'Lin'; 		 ?></th>
					<th><?php echo 'Fin';        ?></th>
					<th><?php echo 'Contrato';   ?></th>
					<th><?php echo 'Produto';    ?></th>
					<th><?php echo 'Data';  	 ?></th>
					<th><?php echo 'Emprestado'; ?></th>
					<th><?php echo 'Parc';  	 ?></th>
					<th><?php echo 'Valor';  	 ?></th>
					<th><?php echo 'Saldo';  	 ?></th>
				</tr>
			</thead>
			<tbody>
				<?php foreach( $registros as $banco ) {
                switch (getByTagName($banco->tags,'tpemprst')) {
                    case 0:
                        $tipo = "Price TR";
                        break;
                    case 1:
                        $tipo = "Price Pre-fixado";
                        break;
                    case 2:
                        $tipo = "Pos-fixado";
                        break;
                } ?>
				<tr onclick="changebtPagar(this);">
				    <td><?php echo getByTagName($banco->tags,'cdlcremp') ?>
						<input type="hidden" id="vlsdprej" name="vlsdprej" value="<?php echo getByTagName($banco->tags,'vlsdprej') ?>" />
						<input type="hidden" id="nrctremp" name="nrctremp" value="<?php echo getByTagName($banco->tags,'nrctremp') ?>" />
						<input type="hidden" id="inprejuz" name="inprejuz" value="<?php echo getByTagName($banco->tags,'inprejuz') ?>" />
						<input type="hidden" id="tplcremp" name="tplcremp" value="<?php echo getByTagName($banco->tags,'tplcremp') ?>" />
						<input type="hidden" id="nrdrecid" name="nrdrecid" value="<?php echo getByTagName($banco->tags,'nrdrecid') ?>" />
						<input type="hidden" id="qtpromis" name="qtpromis" value="<?php echo getByTagName($banco->tags,'qtpromis') ?>" />
						<input type="hidden" id="flgimppr" name="flgimppr" value="<?php echo getByTagName($banco->tags,'flgimppr') ?>" />
						<input type="hidden" id="flgimpnp" name="flgimpnp" value="<?php echo getByTagName($banco->tags,'flgimpnp') ?>" />
						<input type="hidden" id="tpemprst" name="tpemprst" value="<?php echo getByTagName($banco->tags,'tpemprst') ?>" />
						<input type="hidden" id="dsdavali" name="dsdavali" value="<?php echo getByTagName($banco->tags,'dsdavali') ?>" />
                        <input type="hidden" id="cdorigem" name="cdorigem" value="<?php echo getByTagName($banco->tags,'cdorigem') ?>" />
						<input type="hidden" id="liquidia" name="liquidia" value="<?php echo getByTagName($banco->tags,'liquidia') ?>" />
						<input type="hidden" id="vlemprst" name="vlemprst" value="<?php echo number_format(floatval(str_replace(",",".",getByTagName($banco->tags,'vlemprst'))),2,",",".");?>" />
						<input type="hidden" id="portabil" name="portabil" value="<?php echo getByTagName($banco->tags,'portabil') ?>" />
						<input type="hidden" id="cdlcremp" name="cdlcremp" value="<?php echo getByTagName($banco->tags,'cdlcremp') ?>" />
						<input type="hidden" id="qttolatr" name="qttolatr" value="<?php echo getByTagName($banco->tags,'qttolatr') ?>" />
					</td>
					<td><?php echo getByTagName($banco->tags,'cdfinemp') ?></td>
					<td><?php echo formataNumericos("z.zzz.zzz.zzz",getByTagName($banco->tags,'nrctremp'),"."); ?></td>
					<td><?php echo stringTabela($tipo,40,'maiuscula'); ?></td> 
					<td><?php echo getByTagName($banco->tags,'dtmvtolt') ?></td>
					<td><?php echo number_format(str_replace(",",".",getByTagName($banco->tags,'vlemprst')),2,",",".");?></td>
					<td><?php echo getByTagName($banco->tags,'qtpreemp') ?></td>
					<td><?php echo number_format(floatval(str_replace(",",".",getByTagName($banco->tags,'vlpreemp'))),2,",",".");  ?></td>
					<td><?php echo number_format(floatval(str_replace(",",".",getByTagName($banco->tags,'vlsdeved'))),2,",",".");  ?></td>
				</tr>				
				<? } ?>
			</tbody>
		</table>
	</div>	
</div>


<div id="divPesquisaRodape" class="divPesquisaRodape">
	<table>	
		<tr>
			<td>
				<?php
					if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
					
					// Se a paginação não está na primeira, exibe botão voltar
					if ($nriniseq > 1) { 
				?> <a class='paginacaoAnt'><<< Anterior</a> <?php
					} else {
				?> &nbsp; <?php
					}
				?>
			</td>
			<td>
				<?php 
					if (isset($nriniseq)) { 
						?> Exibindo <?php echo $nriniseq; ?> at&eacute; <?php if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <?php echo $qtregist; ?><?php
					}
				?>
			</td>
			<td>
				<?php
					// Se a paginação não está na ultima página, exibe botão proximo
					if ($qtregist > ($nriniseq + $nrregist - 1)) {
				?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?php
					} else {
				?> &nbsp; <?php
					}
				?>			
			</td>
		</tr>
	</table>
</div>

<div id="divBotoes">
    <a href="#" class="botao" id="btVoltar"        onClick="encerraRotina('true');">Voltar</a>
	<a href="#" class="botao" id="btConsultar"     onClick="direcionaConsulta();">Consultar</a>
	<a href="#" class="botao" id="btPagar" 	       onClick="validarLiquidacao();">Pagar</a>
 	<!--<a href="#" class="botao" id="bttranfPreju"    onClick="confirmaPrejuizo()">Transferir Prejuízo</a>-->
	<!--<a href="#" class="botao" id="btdesfazPreju"   onClick="confirmaDesfazPrejuizo()">Desfazer Prejuízo</a>-->
	<a href="#" class="botao" id="btCancelar"      onClick="controlaOperacao('D_EFETIVA');">Desfazer Efetiva&ccedil;&atilde;o</a>
    <a href="#" class="botao" id="btPortabilidade" onClick="controlaOperacao('PORTAB_CRED');">Portabilidade</a>
	<? 
		$permissao = in_array('X', $glbvars['opcoesTela']);
		if($glbvars["cddepart"] == 7 && $permissao == true) {  
	?>
			<a href="#" class="botao" id="btAltQualif" onClick="controlaOperacao('CON_QUALIFICA');">Alterar Qualificação</a>
	<? 	
		} 
	?>
</div>

<script type="text/javascript">
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		acessaOpcaoAba( qtOpcoesTela, 0, '<?php echo ( isset($opcoesTela[0]) ) ? $opcoesTela[0] : ''; ?>', <? echo "'".($nriniseq - $nrregist)."'"; ?>, <? echo "'".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		acessaOpcaoAba( qtOpcoesTela, 0, '<?php echo ( isset($opcoesTela[0]) ) ? $opcoesTela[0] : ''; ?>', <? echo "'".($nriniseq + $nrregist)."'"; ?>, <? echo "'".$nrregist."'"; ?>);
	});	
	
	$('#divPesquisaRodape','#divConteudoOpcao').formataRodapePesquisa();
	
	function changebtPagar(_this){
		if ($(_this).find('#inprejuz').val() == 1){
	   		$('a#btPagar').html('Pagar Prejuizo');
		}
		else{
			$('a#btPagar').html('Pagar');
		}
	}
	
	if ($('.tituloRegistros tbody tr').length == 1){
		if ($('.tituloRegistros tbody tr').find('#inprejuz').val() == 1){
			$('a#btPagar').html('Pagar Prejuizo');
		}
	}

	$('#divRotina').ready(function(e){
		changebtPagar(this);
	});

</script>