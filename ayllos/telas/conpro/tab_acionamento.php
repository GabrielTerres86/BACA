<?php
	/* !
	 * FONTE        : tab_acionamento.php
	 * CRIAÇÃO      : Daniel Zimmermann
	 * DATA CRIAÇÃO : 22/03/2016 
	 * OBJETIVO     : Tabela que apresenta resultado da consulta de acionamento
	 * --------------
	 * ALTERAÇÕES   :  05/07/2017 - P337 - Prever novas situações criadas pela
	 *                              pela implantação da análise automática (Motor)
	 * ---------------- 
	 */

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
 
$dsprotocolo = (isset($_POST['dsprotocolo'])) ? $_POST['dsprotocolo'] : '';
$nmarquiv    = (isset($_POST['nmarquiv']))    ? $_POST['nmarquiv']    : '';

// Gera o arquivo
if ($dsprotocolo) {

    // Montar o xml de Requisicao
    $xml  = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <dsprotocolo>".$dsprotocolo."</dsprotocolo>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    // craprdr / crapaca 
    $xmlResult = mensageria($xml, "CONPRO", "CONPRO_GERA_ARQ", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra crítica
    if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
        exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata, 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)', false);
    }

    // Obtem nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
    echo $xmlObjeto->roottag->tags[0]->cdata;

// Efetua o download
} else if ($nmarquiv) {
  
    //Chama função para mostrar PDF do impresso gerado no browser	 
    visualizaPDF($nmarquiv);

// Mostra a listagem
} else { ?>

    <div id='divResultadoAciona'>
      <fieldset id='tabConteudo'>
        <legend><?php echo(utf8ToHtml('Acionamentos'));?></legend>
        <div class='divRegistros'>
          <table>
            <thead>
              <tr>
                <th>Acionamento</th>
                <th>Proposta</th>
                <th>PA</th>
                <th>Operador</th>
                <th>Opera&ccedil;&atilde;o</th>
                <th>Data e Hora</th>
                <th>Retorno</th>
              </tr>
            </thead>
            <tbody>
            <?php
              foreach ($registros as $r) {
                $dsoperacao = wordwrap(getByTagName($r->tags, 'operacao'),50, "<br/>\n");
                if (getByTagName($r->tags, 'dsprotocolo')) {
                  $dsoperacao = '<a href="#" onclick="abreProtocoloAcionamento(\''.getByTagName($r->tags, 'dsprotocolo').'\');" style="font-size: inherit">'.$dsoperacao.'</a>';
                }
                ?>
                <tr>
                  <td><?php echo getByTagName($r->tags, 'acionamento'); ?></td>
                  <td><?php echo getByTagName($r->tags, 'nrctrprp'); ?></td>                  
                  <td><?php echo getByTagName($r->tags, 'nmagenci'); ?></td>
                  <td><?php echo getByTagName($r->tags, 'cdoperad'); ?></td>
                  <td><?php echo $dsoperacao; ?></td>
                  <td><?php echo getByTagName($r->tags, 'dtmvtolt'); ?></td>
                  <td><?php echo getByTagName($r->tags, 'retorno'); ?></td>                
                </tr>
                <?php
              }
              ?>  
            </tbody>
          </table>
        </div>
        </fieldset>  
      </div>
      <form id="frmImprimir" name="frmImprimir">
        <input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>" />
        <input type="hidden" name="nmarquiv" id="nmarquiv" />
      </form>
	<?php  
			// Efetua formatação do layout da tabela Desabilita campo opção
			echo "<script>formataBusca(); cTodosFiltroAciona.desabilitaCampo();$('#btContinuar', '#divBotoes').hide();</script>";
		}
	
	?>