<?php
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
 * 004: [21/07/2016] Carlos R. - Correcao na forma de uso da variavel $extr. SD 479874.
 * 005: [05/08/2016] Carlos R. - Corrigi a variavel de controle de ordenação do extrato.
 * 006: [08/08/2016] Carlos R. - Correcao na forma de ordenação das colunas que nao obedeciam a ordenacao manual.
 * 007: [30/05/2018] Concatenar dscomple (tags[31]) com historico (Alcemir Mout's - Prj. 467).
 * 008: [11/06/2018] Ajuste para concatenar dscomple (tags[31]) com historico, o traço deve ficar no front (Douglas - Prj. 467).
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
				<td><?php echo ( isset($extrato[0]->tags[4]->cdata) ) ? $extrato[0]->tags[4]->cdata : '&nbsp;'; ?></td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td><?php echo ( isset($extrato[0]->tags[15]->cdata) ) ? number_format(floatval(str_replace(",",".",$extrato[0]->tags[15]->cdata)),2,",",".") : '&nbsp;'; ?></td>
			</tr>

			<?php for ($i = 1; $i < $qtExtrato; $i++) {   
			
				if (strlen(trim($extrato[$i]->tags[31]->cdata)) > 0 ) {
                    // Exibe o complemento
                    $dshistor = $extrato[$i]->tags[3]->cdata."-".$extrato[$i]->tags[4]->cdata." ".$extrato[$i]->tags[21]->cdata." - ".$extrato[$i]->tags[31]->cdata; 
				} else {
                    // Exibe apenas o extrato
                    $dshistor = $extrato[$i]->tags[3]->cdata."-".$extrato[$i]->tags[4]->cdata." ".$extrato[$i]->tags[21]->cdata; 
				}
				$dtliblan = $extrato[$i]->tags[7]->cdata;
				$mtdClick = "selecionaExtrato('".$dshistor."', '".$dtliblan."')";
				?>

				<tr onclick= "<?php echo $mtdClick; ?>" onFocus="<?php echo $mtdClick; ?>" >
					<td>
						<span><?php echo ( isset($extrato[$i]->tags[1]->cdata) ) ? dataParaTimestamp($extrato[$i]->tags[1]->cdata) : str_pad("$i", 6, '0', STR_PAD_LEFT); ?></span>

						<?php echo $extrato[$i]->tags[1]->cdata; ?>
					</td>
						
					<td><?php 
						// verificar se existe complemento para ser adicionado ao extrato
						if (strlen(trim($extrato[$i]->tags[31]->cdata)) > 0 ) {
							// Exibe o complemento
							echo $extrato[$i]->tags[3]->cdata."-".$extrato[$i]->tags[4]->cdata." ".$extrato[$i]->tags[7]->cdata." - ".$extrato[$i]->tags[31]->cdata; 
						} else {
							// Exibe apenas o extrato
							echo $extrato[$i]->tags[3]->cdata."-".$extrato[$i]->tags[4]->cdata." ".$extrato[$i]->tags[7]->cdata; 
						}
					?></td>                    					
					
          <td><?php echo $extrato[$i]->tags[5]->cdata; ?></td>
					
					<td><?php echo $extrato[$i]->tags[6]->cdata; ?></td>
					
					<td><span><?php echo ( isset($extrato[$i]->tags[9]->cdata) ) ? str_pad(str_replace(',','.',$extrato[$i]->tags[9]->cdata * 100), 15, '0', STR_PAD_LEFT) : ''; ?></span>
						<?php echo number_format(floatval(str_replace(",",".",$extrato[$i]->tags[9]->cdata)),2,",","."); ?></td>
						
					<td><span><?php echo ( isset($extrato[$i]->tags[15]->cdata) ) ? str_pad(str_replace(',','.',$extrato[$i]->tags[15]->cdata * 100), 15, '0', STR_PAD_LEFT) : ''; ?></span>
						<?php if ($extrato[$i]->tags[15]->cdata <> "0") { echo number_format(floatval(str_replace(",",".",$extrato[$i]->tags[15]->cdata)),2,",","."); } ?></td>
						
				</tr>				
			<?php } ?>			
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
 <li class="txtNormalBold">Hist&oacute;rico:</li>
 <li id="dshistor" class="txtNormal" style="width:300px;" ></li>
 <li class="txtNormalBold">Dt.Libera:</li>
 <li id="dtlibera" class="txtNormal" style="width:50px;" ></li>
</ul>