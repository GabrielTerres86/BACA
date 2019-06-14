<?php
    /*
     * FONTE        : form_manter_carga.php
     * CRIAÇÃO      : Lucas Lombardi
     * DATA CRIAÇÃO : 25/07/2016
     * OBJETIVO     : Tela Bloquear Carga.
     * --------------
     * ALTERAÇÕES   : 
     *
     * 000: [11/07/2017] Alteração no controla de apresentação do cargas bloqueadas na opção "A", Melhoria M441. ( Mateus Zimmermann/MoutS )
     * --------------
     */
	
    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');	
    require_once('../../class/xmlfile.php');
	
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	
	// Variaveis para paginacao
	$nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;
	$nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 1;
	
    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}
	
    // Monta o xml de requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .= "  <cddopcao>".$cddopcao."</cddopcao>";		
	$xml .= "  <nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "  <qtregist>".$nrregist."</qtregist>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "TELA_IMPPRE", "IMPPRE_BUSCA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	$cargas = $xmlObjeto->roottag->tags[0]->tags;
	$qtregist = $xmlObjeto->roottag->tags[1]->cdata;
	
?>
<form id="frmImportaCarga" name="frmImportaCarga" class="formulario">
	<div style="margin-top:10px;"></div>
	<div id="divCarga" class="divRegistros">
		<table width="100%">
			<thead>
				<tr>
					<th><?php echo utf8ToHtml('Carga') ?></th>
					<th><?php echo utf8ToHtml('Descri&ccedil;&atilde;o') ?></th>
					<th><?php echo utf8ToHtml('Bloqueio') ?></th>
					<th><?php echo utf8ToHtml('Situa&ccedil;&atilde;o') ?></th>
					<th><?php echo utf8ToHtml('Vig&ecirc;ncia Final') ?></th>
					<th><?php echo utf8ToHtml('Valor Total') ?></th>
				</tr>
			</thead>
			<tbody>
			<?php
				foreach ($cargas as $carga) {
					?>
					<tr>
						<td width="50px">
							<?php echo getByTagName($carga->tags,'idcarga'); ?>
							<input type="hidden" id="hdn_idcarga" value="<?php echo getByTagName($carga->tags,'idcarga'); ?>" />
							<input type="hidden" id="hdn_bloqueio" value="<?php echo getByTagName($carga->tags,'bloqueio'); ?>" />
              </td>
						<td width="300px"><?php echo getByTagName($carga->tags,'descricao'); ?></td>
						<td width="70px"><?php echo getByTagName($carga->tags,'bloqueio'); ?></td>
						<td width="60px"><?php echo getByTagName($carga->tags,'situacao'); ?></td>
						<td width="90px"><?php echo getByTagName($carga->tags,'vigencia_final'); ?></td>
						<td><?php echo getByTagName($carga->tags,'valor_total'); ?></td>
					</tr>
					<?php
				}
			?>
			</tbody>
		</table>
	</div>
	<div id="divPesquisaRodape" class="divPesquisaRodape">
        <table>	
          <tr>
            <td>
              <?php
              if (isset($qtregist) and $qtregist == 0) {
                $nriniseq = 0;
              }
                // Se a paginacao nao esta na primeira, exibe botao voltar
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
                ?> Exibindo <?php echo $nriniseq; ?> at&eacute; <?php
                if (($nriniseq + $nrregist) > $qtregist) {
                  echo $qtregist;
                } else {
                  echo ($nriniseq + $nrregist - 1);
                }
                ?> de <?php echo $qtregist; ?><?php
              }
              ?>
            </td>
            <td>
              <?php
              // Se a paginacao nao esta na ultima pagina, exibe botao proximo
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
	  
	<div id="divBotoes" class="rotulo-linha" style="margin-top:25px; margin-bottom :10px; text-align: center;">
		<a href="#" class="botao" id="btVoltar">Voltar</a>
		<a href="#" class="botao" id="btConcluir"><?switch(strtoupper($cddopcao))
													{
														case 'B':  echo "Bloquear"; break;
														case 'L':  echo "Liberar"; break;
														case 'E':  echo "Excluir"; break;
														case 'A':  echo "Alterar"; break;
													}?></a>
	</div>

</form>

<script type="text/javascript">
    
    $('input','#divConsultaLog').desabilitaCampo();
    
    $('a.paginacaoAnt').unbind('click').bind('click', function() {
        acessaManterCarga(<?php echo "'" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('a.paginacaoProx').unbind('click').bind('click', function() {
        acessaManterCarga(<?php echo "'" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
    });
</script>