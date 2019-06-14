<?
/*!
 * FONTE        : tab_historico.php
 * CRIAÇÃO      : Marcel Kohls - (AMCom)
 * DATA CRIAÇÃO : 23/03/2018
 * OBJETIVO     : Tabela que apresenta historico de registros de ativo problematico
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?>

<div id="divConta">
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Conta'); ?></th>
					<th><? echo utf8ToHtml('Contrato');  ?></th>
					<th><? echo utf8ToHtml('Motivo');  ?></th>
					<th><? echo utf8ToHtml('Dt. Envio');  ?></th>
					<th><? echo utf8ToHtml('Tipo Envio');  ?></th>
				</tr>
			</thead>
			<tbody>
        <?php foreach( $retornoRotina as $registro ): ?>
					<tr>
            <td><?= getByTagName($registro->tags,'nrdconta'); ?></td>
            <td><?= getByTagName($registro->tags,'nrctremp'); ?></td>
            <td><?= getByTagName($registro->tags,'dsmotivo'); ?></td>
            <td><?= getByTagName($registro->tags,'dataEnvio'); ?></td>
            <td><?= getByTagName($registro->tags,'tipoEnvio'); ?></td>
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
