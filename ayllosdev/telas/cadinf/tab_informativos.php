<? 
/*!
 * FONTE        : tab_informativos.php               Última alteração: 29/10/2015
 * CRIAÇÃO      : Jéssica - DB1
 * DATA CRIAÇÃO : 18/08/2015
 * OBJETIVO     : Tabela de Informativos
 * --------------
 * ALTERAÇÕES   : 29/10/2015 - Ajustes de homologação refente a conversão realizada pela DB1
							   (Adriano).
 * --------------
 */

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');		
	isPostMethod();	
 
?>
<div id="tabInformativo" style="display:block">
	<div class="divRegistros">
        <table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Informativo');  ?></th>
					<th><? echo utf8ToHtml('Forma Envio');  ?></th>
					<th><? echo utf8ToHtml('Periodo');   ?></th>
					<th><? echo utf8ToHtml('Todos Titula.');  ?></th>					
					<th><? echo utf8ToHtml('Envio Obrig.');  ?></th>					
				</tr>
			</thead>
			<tbody>
				<?
				if ( count($registros) == 0 ) {
					$i = 0;
					// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
					?> <tr>
							<td colspan="6" style="width: 80px; text-align: center;">
								<input type="hidden" id="conteudo" name="conteudo" value="<? echo $i; ?>" />
								<b>N&atilde;o h&aacute; registros de informativos cadastrados.</b>
							</td>
						</tr>							
				<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
				} else {
					for ($i = 0; $i < count($registros); $i++) {
					?>
						<tr id="<?php echo getByTagName($registros[$i]->tags,'nrdrowid')?>">
							<td><input type="hidden" id="conteudo" name="conteudo" value="<? echo 1; ?>" />
							    <input type="hidden" id="nrdrowid" name="nrdrowid" value="<? echo getByTagName($registros[$i]->tags,'nrdrowid') ?>" />
								<input type="hidden" id="nmrelato" name="nmrelato" value="<? echo getByTagName($registros[$i]->tags,'nmrelato') ?>" />
								<input type="hidden" id="dsfenvio" name="dsfenvio" value="<? echo getByTagName($registros[$i]->tags,'dsfenvio') ?>" />
								<input type="hidden" id="dsperiod" name="dsperiod" value="<? echo getByTagName($registros[$i]->tags,'dsperiod') ?>" />
								<input type="hidden" id="envcpttl" name="envcpttl" value="<? echo getByTagName($registros[$i]->tags,'envcpttl') ?>" />
								<input type="hidden" id="envcobrg" name="envcobrg" value="<? echo getByTagName($registros[$i]->tags,'envcobrg') ?>" />
								<input type="hidden" id="todostit" name="todostit" value="<? echo getByTagName($registros[$i]->tags,'todostit') ?>" />
								<input type="hidden" id="existcra" name="existcra" value="<? echo getByTagName($registros[$i]->tags,'existcra') ?>" />
								
							    <span><? echo getByTagName($registros[$i]->tags,'nmrelato'); ?></span>
									  <? echo getByTagName($registros[$i]->tags,'nmrelato'); ?>
							</td>
							<td><span><? echo getByTagName($registros[$i]->tags,'dsfenvio'); ?></span>
									  <? echo getByTagName($registros[$i]->tags,'dsfenvio'); ?>
							</td>													
							<td><span><? echo getByTagName($registros[$i]->tags,'dsperiod'); ?></span>
									  <? echo getByTagName($registros[$i]->tags,'dsperiod'); ?>
							</td>
							
							<?php 
								
								if(getByTagName($registros[$i]->tags,'envcpttl') == 0){
									
									$flgtitul = "Sim";
									
								?>    																					
								<?}else{
									$flgtitul = "Nao";	
								}
								
							?>						
							<td><span><? echo $flgtitul; ?></span>
									  <? echo $flgtitul; ?>
							</td>
							
							<?php 
								
								if(getByTagName($registros[$i]->tags,'envcobrg') == 1){
									
									$flgobrig = "Sim";
									
								?>    																					
								<?}else{
									$flgobrig = "Nao";	
								}
								
							?>
														
							<td><span><? echo $flgobrig; ?></span>
									  <? echo $flgobrig; ?>
							</td>
							
						</tr>
					<? } ?>
			<? } ?>
								
			
			</tbody>
		</table>
	</div>
	<div id="divPesquisaRodape" class="divPesquisaRodape">
        <table>
            <tr>
                <td>
                    <?
                        if (isset($qtregist) and count($qtregist) == 0) $nriniseq = 0;
                        if ($nriniseq > 1) {
                            ?> <a class='paginacaoAnt'><<< Anterior</a> <?
                        } else {
                            ?> &nbsp; <?
                        }
                    ?>
                </td>
                <td>
                    <?
                        if ($nriniseq) {
                            ?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
                    <?  } ?>
                </td>
                <td>
                    <?
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
</div>

<script type="text/javascript">
	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();
</script>
