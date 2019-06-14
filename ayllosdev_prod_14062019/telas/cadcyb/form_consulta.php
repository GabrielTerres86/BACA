<?php
/*!
 * FONTE        : form_consulta.php
 * CRIAÇÃO      : Lucas R.
 * DATA CRIAÇÃO : Agosto/2013
 * OBJETIVO     : Listar registros de consulta da crapcyc.
 * --------------
 * ALTERAÇÕES   : 06/01/2015 - Padronizando a mascara do campo nrctremp.
 *	   	                       10 Digitos - Campos usados apenas para visualização
 *			                   8 Digitos - Campos usados para alterar ou incluir novos contratos
 *				               (Kelvin - SD 233714)
 *
 *                16/09/2015 - Melhorias na tela CADCYB (Douglas - Melhoria 12).
 *				  29/07/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 *                18/08/2018 - Incluso tratativa para produto desconto de titulo (GFT)
 * --------------
 */
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");	
	require_once("../../class/xmlfile.php");
	isPostMethod();	


?>

<div id="divConsulta" name="divConsulta" >
	<div class="divRegistros">			
	
		<table width="100%">
			<thead>
				<tr>
				<th>Origem</th>
				<th>Conta</th>
				<?=(in_array($cdorigem, array(1,3)) ? '<th>Contrato</th>' : '');?>
				<?=(in_array($cdorigem, array(4))   ? '<th>Borderô</th>' : '');?>
				<?=(in_array($cdorigem, array(4))   ? '<th>Titulo</th>' : '');?>
				<th>Judicial</th>
				<th>Extra Judicial</th>
				<th>CIN</th>
				</tr>
			</thead>
			<tbody>
				<?php 
				$conta = 0;
				foreach( $registros as $r ) { 
					$conta++;
					$dsorigem = getByTagName($r->tags,"dsorigem");
					$nrdconta = formataContaDV(getByTagName($r->tags,"nrdconta"));
					$nrctremp = mascara(getByTagName($r->tags,"nrctremp"),"#.###.###.###");
					$flgjudic = getByTagName($r->tags,"flgjudic");
					$flextjud = getByTagName($r->tags,"flextjud");
					$flgehvip = getByTagName($r->tags,"flgehvip");
					$dtenvcbr = getByTagName($r->tags,"dtenvcbr");
					$nrborder = getByTagName($r->tags,"nrborder");
					$nrtitulo = getByTagName($r->tags,"nrtitulo");
					$nrdocmto = getByTagName($r->tags,"nrdocmto");
					$dtinclus = getByTagName($r->tags,"dtinclus");
					$cdopeinc = getByTagName($r->tags,"cdopeinc");
					$dtaltera = getByTagName($r->tags,"dtaltera");
					$cdoperad = getByTagName($r->tags,"cdoperad");
					$assessor = getByTagName($r->tags,"nmassess");
					$motivocin = getByTagName($r->tags,"dsmotcin");
				?>
				<tr onClick="mostraDetalhes('<? echo $dsorigem; ?>', '<? echo $nrdconta; ?>', '<? echo $nrctremp; ?>', '<? echo $flgjudic; ?>', '<? echo $flextjud; ?>', '<? echo $flgehvip; ?>', '<? echo $dtenvcbr; ?>', '<? echo $dtinclus; ?>', '<? echo $cdopeinc; ?>', '<? echo $dtaltera; ?>', '<? echo $cdoperad; ?>', '<? echo $assessor; ?>', '<? echo $motivocin; ?>', '<? echo $nrborder; ?>', '<? echo $nrtitulo; ?>', <? echo $nrdocmto; ?>  );" >
					<td>
						<span><?php echo $dsorigem;?></span>
						<?php echo $dsorigem;?>						
					</td>
					<td>
						<span><?php echo $nrdconta;?></span>
						<?php echo $nrdconta; ?>
					</td>

					<?=(in_array($cdorigem, array(1,3)) ? '<td><span>'.$nrctremp.'</span>'.$nrctremp.'</td>' : '');?>
					<?=(in_array($cdorigem, array(4))   ? '<td><span>'.$nrborder.'</span>'.$nrborder.'</td>' : '');?>
					<?=(in_array($cdorigem, array(4))   ? '<td><span>'.$nrdocmto.'</span>'.$nrdocmto.'</td>' : '');?>
					
					<td>
						<span><?php echo $flgjudic; ?></span>
						<?php echo $flgjudic; ?>						
					</td>
					<td>
						<span><?php echo $flextjud; ?></span>
						<?php echo $flextjud; ?>						
					</td>
					<td>
						<span><?php echo $flgehvip ;?></span>
						<?php echo $flgehvip; ?>						
					</td>
				</tr>
				<?php } ?>
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
							?> <a class="paginacaoAnt"><<< Anterior</a> <? 
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
						// Se a paginação não está na &uacute;ltima página, exibe botão proximo
						if ($qtregist > ($nriniseq + $nrregist - 1)) {
							?> <a class="paginacaoProx">Pr&oacute;ximo >>></a> <?
						} else {
							?> &nbsp; <?
						}
					?>			
				</td>
			</tr>
		</table>
	</div>

<script type="text/javascript">

	var nrctremp_1     = $("#nrctremp","#frmNumero");
	
	$("a.paginacaoAnt").unbind("click").bind("click", function() {
		buscaConsulta(<? echo '"'.($nriniseq - $nrregist).'","'.$nrregist.'"'; ?>);
	});
	
	$("a.paginacaoProx").unbind("click").bind("click", function() {
		buscaConsulta(<? echo '"'.($nriniseq + $nrregist).'","'.$nrregist.'"'; ?>);
	});	
	
</script>