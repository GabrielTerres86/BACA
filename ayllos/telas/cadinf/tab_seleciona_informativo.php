<? 
/*!
 * FONTE        : tab_seleciona_informativo.php              Última alteração: 29/10/2015
 * CRIAÇÃO      : Jéssica - DB1
 * DATA CRIAÇÃO : 18/08/2015
 * OBJETIVO     : Tabela de inclusão de Informativos
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
<div id="tabSelecionaInformativo" style="display:block">
	<div class="divRegistros">
        <table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Informativo');  ?></th>
					<th><? echo utf8ToHtml('Forma Envio');  ?></th>
					<th><? echo utf8ToHtml('Periodo');   ?></th>
					<th><? echo utf8ToHtml('Todos Titula.');  ?></th>										
				</tr>
			</thead>
			<tbody>
				<?
				if ( count($registros) == 0 ) {
					$i = 0;
					// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
					?> <tr>
							<td colspan="6" style="width: 80px; text-align: center;" ondblclick="event.stopPropagation()">
								<input type="hidden" id="conteudo" name="conteudo" value="<? echo $i; ?>"  />
								<b>ATEN&Ccedil;&Atilde;O!!! N&atilde;o h&aacute; informativo a ser inclu&iacute;do.</b>
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
								<input type="hidden" id="cdrelato" name="cdrelato" value="<? echo getByTagName($registros[$i]->tags,'cdrelato') ?>" />								
								<input type="hidden" id="cdprogra" name="cdprogra" value="<? echo getByTagName($registros[$i]->tags,'cdprogra') ?>" />								
								<input type="hidden" id="cddfrenv" name="cddfrenv" value="<? echo getByTagName($registros[$i]->tags,'cddfrenv') ?>" />								
								<input type="hidden" id="cdperiod" name="cdperiod" value="<? echo getByTagName($registros[$i]->tags,'cdperiod') ?>" />	
							
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
