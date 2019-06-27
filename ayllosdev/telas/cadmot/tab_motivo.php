<?php
/* !
 * FONTE        : tab_pagamento.php
 * CRIAÇÃO      : Christian Grauppe - ENVOLTI
 * DATA CRIAÇÃO : Janeiro/2019
 * OBJETIVO     : tabela motivos cadastrados
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
 
?>
<div id="tabMotivo" style="display:block;">
  <div class="divRegistros">
    <table class="tituloRegistros">
      <thead>
        <tr>
          <th>C&oacute;digo</th>
          <th>Descri&ccedil;&atilde;o</th>
          <th>Produto</th>
          <th>Reservado Sistema</th>
          <th>Ativo</th>
          <th>Tipo</th>
          <th>Exibe</th>
        </tr>
      </thead>
      <tbody>
        <?php
                if ( $qtregist == 0 ) {
                $i = 0;?>
        <tr>
          <td colspan="7" style="width: 80px; text-align: center;">
            <input type="hidden" id="conteudo" name="conteudo" value="<?php echo $i; ?>" />
            <b>N&atilde;o foram encontrados registros de Motivos cadastrados.</b>
          </td>
        </tr>
        <?php	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
                } else {
					foreach( $registros->tags as $motivo ) {
					/*	echo getByTagName($motivo->tags,'idmotivo');
						var_dump($motivo->tags);die;
					}
					
					for ($i = 0; $i < count($motivo); $i++) {
					var_dump($motivo);die;
					*/
                ?>
        <tr class="conteudo" id="idmotivo<?php echo getByTagName($motivo->tags,'idmotivo'); ?>">
          <td>
            <input type="hidden" class="idmotivo" name="idmotivo" value="<?php echo getByTagName($motivo->tags,'idmotivo'); ?>" />
            <input type="hidden" class="dsmotivo" name="dsmotivo" value="<?php echo getByTagName($motivo->tags,'dsmotivo'); ?>" />
            <input type="hidden" class="cdproduto" name="cdproduto" value="<?php echo getByTagName($motivo->tags,'cdproduto'); ?>" />
            <input type="hidden" class="flgreserva_sistema" name="flgreserva_sistema" value="<?php echo getByTagName($motivo->tags,'flgreserva_sistema'); ?>" />
            <input type="hidden" class="flgativo" name="flgativo" value="<?php echo getByTagName($motivo->tags,'flgativo'); ?>" />
            <input type="hidden" class="flgtipo" name="flgtipo" value="<?php echo getByTagName($motivo->tags,'flgtipo'); ?>" />
            <input type="hidden" class="flgexibe" name="flgexibe" value="<?php echo getByTagName($motivo->tags,'flgexibe'); ?>" />
            <span>
              <?php echo getByTagName($motivo->tags,'idmotivo'); ?>
            </span>
            <?php echo getByTagName($motivo->tags,'idmotivo'); ?>
          </td>
          <td>
            <span>
              <?php echo getByTagName($motivo->tags,'dsmotivo'); ?>
            </span>
            <?php echo getByTagName($motivo->tags,'dsmotivo'); ?>
          </td>
          <td>
            <span>
              <?php echo getByTagName($motivo->tags,'dsproduto'); ?>
            </span>
            <?php echo getByTagName($motivo->tags,'dsproduto'); ?>
          </td>
          <td>
            <span>
              <?php echo $flgreserva_sistema = (getByTagName($motivo->tags,'flgreserva_sistema') == 0) ? "N&atilde;o" : "Sim"; ?>
            </span>
            <?php echo $flgreserva_sistema; ?>
          </td>
          <td>
            <span>
              <?php echo $flgativo = (getByTagName($motivo->tags,'flgativo') == 0) ? "N&atilde;o" : "Sim"; ?>
            </span>
            <?php echo $flgativo; ?>
          </td>
          <td>
            <span>
              <?php echo $flgtipo = (getByTagName($motivo->tags,'flgtipo') == 0) ? "Bloqueio" : "Desbloqueio"; ?>
            </span>
            <?php echo $flgtipo; ?>
          </td>
          <td>
            <span>
              <?php echo $flgexibe = (getByTagName($motivo->tags,'flgexibe') == 0) ? "N&atilde;o" : "Sim"; ?>
            </span>
            <?php echo $flgexibe; ?>
          </td>
        </tr>
        <?php }
                 } ?>
      </tbody>
    </table>
  </div>
  <div id="divPesquisaRodape" class="divPesquisaRodape">
    <table>
      <tr>
        <td>
          <?php
                    if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
                    if ($nriniseq > 1) {
                    ?> <a class='paginacaoAnterior'> <<< Anterior</a> <?php
                    } else {
                    ?> &nbsp; <?php
                    }
                    ?>
        </td>
        <td>
          <?php
                    if ($nriniseq) {
                    ?> Exibindo <?php echo $nriniseq; ?> at&eacute; <?php if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <?php echo $qtregist; ?>
          <?php } ?>
        </td>
        <td>
          <?php
                    if ($qtregist > ($nriniseq + $nrregist - 1)) {
                    ?> <a class='paginacaoProximo'>Pr&oacute;ximo >>></a> <?php
                    } else {
                    ?> &nbsp; <?php
                    }
                    ?>
        </td>
      </tr>
    </table>
  </div>
</div>
<script type="text/javascript">
  function paginaMotivos() {
  buscaMotivos(<?php echo "'" . $nriniseq . "','" . $nrregist . "'"; ?>);
  };

  $('a.paginacaoAnterior').unbind('click').bind('click', function() {
  buscaMotivos(<?php echo "'" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
  });

  $('a.paginacaoProximo').unbind('click').bind('click', function() {
  buscaMotivos(<?php echo "'" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
  });

  $('#divPesquisaRodape', '#divTela').formataRodapePesquisa();

  // Habilta
  $('#frmCab').css({'display': 'block'});
  $('#divBotoes').css({'display': 'block'});
</script>