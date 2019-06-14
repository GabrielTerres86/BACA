<?
/*!
 * FONTE        : lista_efetivados.php
 * CRIAÇÃO      : Marcel Kohls - (AMCom)
 * DATA CRIAÇÃO : 16/04/2018
 * OBJETIVO     : Tabela que apresenta lista de registros efetivados
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?>

<div id="divConta" style="border-bottom: 1px solid #777; padding: 10px 0px;">
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
          <th><? echo utf8ToHtml('Data');  ?></th>
					<th><? echo utf8ToHtml('Conta'); ?></th>
					<th><? echo utf8ToHtml('Cooperado');  ?></th>
					<th><? echo utf8ToHtml('Valor');  ?></th>
          <th><? echo utf8ToHtml('Historico');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?php foreach( $retornoRotina as $registro ): ?>
					<tr>
            <td data-campo="datamvto"><?= getByTagName($registro->tags,'datadeb'); ?></td>
            <td data-campo="nrdconta"><?= formataContaDV(getByTagName($registro->tags,'conta')); ?></td>
						<td data-campo="cooperad"><div class="fixalargura"><?= getByTagName($registro->tags,'associado'); ?></div></td>
            <td data-campo="vldebito"><?= number_format(floatval(str_replace(",",".",getByTagName($registro->tags,'vlrdebito'))),2,",","."); ?></td>
						<td data-campo="historic" title="<?= getByTagName($registro->tags,'historico'); ?>"><div class="fixalargura"><?= getByTagName($registro->tags,'historico'); ?></div></td>
					</tr>
			  <?php endforeach; ?>
			</tbody>
		</table>
	</div>
  <div id="divPesquisaRodape" class="divPesquisaRodape">
    <table>
      <tr>
        <td>
          <?php if (!$ehPrimeiraPagina): ?>
            <a class='paginacaoAnt'><<< Anterior</a>
          <?php endif; ?>
        </td>
        <td>
            Exibindo <?= $regInicial ?> at&eacute; <?= $regFinal ?> de <?= $totRegistros ?>
        </td>
        <td>
          <?php if (!$ehUltimaPagina): ?>
            <a class='paginacaoProx'>Pr&oacute;ximo >>></a>
          <?php endif; ?>
        </td>
      </tr>
    </table>
  </div>
</div>

<div id="divBotoes" style="text-align:center; padding-bottom:10px; clear: both; float: none;">
  <a href="#" class="botao" id="btVoltar" onclick="voltarListagem();">Voltar</a>
</div>

<script type="text/javascript">
  $('a.paginacaoAnt').unbind('click').bind('click', function() {
    trocaPagina(-1);
  });

  $('a.paginacaoProx').unbind('click').bind('click', function() {
    trocaPagina(1);
  });
</script>
