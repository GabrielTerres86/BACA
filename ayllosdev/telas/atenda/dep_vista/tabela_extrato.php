<? 
/*!
 * FONTE        : tabela_extrato.php
 * CRIAÇÃO      : Gabriel Capoia - DB1
 * DATA CRIAÇÃO : 30/06/2011 
 * OBJETIVO     : Tabela de extratos
 * --------------
 * ALTERAÇÕES   :
 * --------------
  * 002: [01/09/2011] Gabriel S. Ramirez (CECRED) - Incluir rodape com mais informacoes.
  * 003: [15/09/2011] David G. Kistner (CECRED) - Alterar leitura do saldo anterior.
 */	
?>


<div class="divRegistros">	
	<table>
		<thead>
			<tr>
				<th>Data</th>
				<th>Hist&oacute;rico</th>
				<th>Docmto</th>
				<th>D/C</th>
				<th>Valor</th>
				<th>Saldo</th>
			</tr>			
		</thead>
		<tbody>
			<tr>
				<td>&nbsp;</td>
				<td><?php echo $extrato[0]->tags[4]->cdata; ?></td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td><?php echo number_format(str_replace(",",".",$extrato[0]->tags[15]->cdata),2,",","."); ?></td>
			</tr>

			<? for ($i = 1; $i < $qtExtrato; $i++) {   
			
				$dshistor = $extrato[$i]->tags[3]->cdata."-".$extrato[$i]->tags[4]->cdata."   ".$extrato[$i]->tags[21]->cdata; 
				$dtliblan = $extrato[$i]->tags[7]->cdata;
				
				$mtdClick = "selecionaExtrato('".$dshistor."', '".$dtliblan."')";
				?>

				<tr onclick= "<? echo $mtdClick; ?>" onFocus="<? echo $mtdClick; ?>" >
					<td><span><? echo dataParaTimestamp($extr->tags[0]->cdata) ?></span>
						<?php echo $extrato[$i]->tags[1]->cdata; ?></td>
						
					<td><?php echo $extrato[$i]->tags[3]->cdata."-".$extrato[$i]->tags[4]->cdata." ".$extrato[$i]->tags[7]->cdata; ?></td>
					
					<td><?php echo $extrato[$i]->tags[5]->cdata; ?></td>
					
					<td><?php echo $extrato[$i]->tags[6]->cdata; ?></td>
					
					<td><span><? echo str_replace(',','.',$extr->tags[5]->cdata) ?></span>
						<?php echo number_format(str_replace(",",".",$extrato[$i]->tags[9]->cdata),2,",","."); ?></td>
						
					<td><span><? echo str_replace(',','.',$extr->tags[6]->cdata) ?></span>
						<?php if ($extrato[$i]->tags[15]->cdata <> "0") { echo number_format(str_replace(",",".",$extrato[$i]->tags[15]->cdata),2,",","."); } ?></td>
						
				</tr>				
			<? } ?>			
		</tbody>		
	</table>
</div>
<div id="divPesquisaRodape" class="divPesquisaRodape">
	<table>
		<tr>
			<?php if ($iniregis > 1) { ?>					
			<td><a href="#"  onClick="navega(<?php echo $iniregis - $qtregpag; ?>);return false;"><< Anterior</a></td>
			<?php } else { ?>					
			<td>&nbsp;</td>
			<?php } ?>
			<td>
				<?php if ($qtregist > 0) { ?>
				Exibindo <?php echo $iniregis; ?> at&eacute; <?php if (($iniregis + $qtregpag) > $qtregist) { echo $qtregist; } else { echo ($iniregis + $qtregpag - 1); } ?> de <?php echo $qtregist; ?>
				<?php }?>
			</td>
			<?php if ($qtregist > ($iniregis + $qtregpag - 1)) { ?>
			<td><a href="#"  onClick="navega(<?php echo $iniregis + $qtregpag; ?>);return false;">Pr&oacute;ximo >></a></td>					
			<?php } else { ?>
			<td>&nbsp;</td>					
			<?php } ?>				
		</tr>
	</table>
</div>


<ul class="complemento" id="complemento">
 <li class="txtNormalBold"> <? echo utf8ToHtml('Histórico:') ?>  </li>
 <li id="dshistor" class="txtNormal" style="width:300px;" ></li>
 <li class="txtNormalBold"> <? echo utf8ToHtml('Dt.Libera:') ?></li>
 <li id="dtlibera" class="txtNormal" style="width:50px;" ></li>
</ul>