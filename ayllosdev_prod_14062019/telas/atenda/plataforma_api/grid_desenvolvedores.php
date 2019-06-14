<?php
	/*!
	* FONTE        : grid_desenvolvedores.php
	* CRIAÇÃO      : André Clemer
	* DATA CRIAÇÃO : Fevereiro/2019
	* OBJETIVO     : Exibir grid de desenvolvedores para Plataforma API.
	* --------------
	* ALTERAÇÕES   :
	* --------------
	*/
	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo metodo POST
	isPostMethod();

	// Classe para leitura do xml de retorno
    require_once("../../../class/xmlfile.php");

    $cddopcao           = ((!empty($_POST['cddopcao']))  ? $_POST['cddopcao']  : 'C');
    $nrdconta           = ((!empty($_POST['nrdconta']))  ? $_POST['nrdconta']  : 0);
    $idservico_api      = ((!empty($_POST['idservico_api'])) ? $_POST['idservico_api'] : '');
    $ls_desenvolvedores = ((isset($_POST['ls_desenvolvedores'])) ? $_POST['ls_desenvolvedores'] : '');
    $carrega_memoria    = ((!empty($_POST['carrega_memoria'])) ? $_POST['carrega_memoria'] : false);
	
	$countData = 0;
    
    $xml = new XmlMensageria();

    $xml->add('idservico_api', $idservico_api);
    $xml->add('nrdconta', $nrdconta);

    $xmlResult = mensageria($xml, "TELA_ATENDA_API", "CONSULTA_DESENV_COOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
        exibeErroNew($msgErro);exit;
    }

    $registros = $xmlObj->roottag->tags[0]->tags;

    $desenvolvedores_aux = '';

    if ($ls_desenvolvedores) {
        $desenvolvedores_aux = explode('|', $ls_desenvolvedores);
    }

    $script = 'arrDesenvolvedores = [];';

?>
<fieldset style="padding: 5px" id="fldDesenvolvedor">
    <legend><? echo utf8ToHtml('Desenvolvedor(es) do cooperado');?></legend>
    <div class="divRegistros" style="height: 75px;width: 600px;">
        <table class="tituloRegistros" id="tbDesenvolvedores">
            <thead>
                <tr>
					<th>Desenvolvedor</th>
                    <th>CPF/CNPJ</th>
                </tr>
            </thead>
            <tbody>
                <?php
                // nao foi setado ainda
                if (!$carrega_memoria && $cddopcao != 'I') {
                    foreach ($registros as $r) {
                        $cddesenvolvedor = getByTagName($r->tags,"cddesenvolvedor");
                        $dsnome          = getByTagName($r->tags,"dsnome");
                        $nrdocumento     = getByTagName($r->tags,"nrdocumento");
                        $nrtelefone      = getByTagName($r->tags,"nrtelefone");
                        $dscontato       = getByTagName($r->tags,"dscontato");
                        $dsemail         = getByTagName($r->tags,"dsemail");
						
						if (!$cddesenvolvedor){ continue; }

                        $script .= 'arrDesenvolvedores.push({
                            cddesenvolvedor: ' . $cddesenvolvedor . ',
                            nmdesenvolvedor: "' . $dsnome . '",
                            nrdocumento: "' . $nrdocumento . '",
                            nrtelefone: "' . $nrtelefone . '",
                            dscontato: "' . $dscontato . '",
                            dsemail: "' . $dsemail . '"
                        });';

                        ?>
                        <tr>
                            <td>
                                <input type="hidden" id="cddesenvolvedor" name="cddesenvolvedor" value="<? echo $cddesenvolvedor; ?>" >
                                <?php echo $cddesenvolvedor . ' - ' . $dsnome; ?>
                            </td>
                            <td><?php echo $nrdocumento; ?></td>
                        </tr>
                        <?php
						$countData++;
                    }
                }
                
                $array_temp = array();
                foreach ($desenvolvedores_aux as $desenvolvedor) {
                    $d = explode('#', $desenvolvedor);
                    $cddesenvolvedor = $d[0];
                    $dsnome          = $d[1];
                    $nrdocumento     = $d[2];
                    $nrtelefone      = $d[3];
                    $dscontato       = $d[4];
                    $dsemail         = $d[5];
					
					if (!$cddesenvolvedor){ continue; }
          
          $array_temp[] = $cddesenvolvedor;
					
					if (count($array_temp) <> count(array_unique($array_temp))){ unset($array_temp[count($array_temp) - 1]); continue; }

                    $script .= 'arrDesenvolvedores.push({
                        cddesenvolvedor: ' . $cddesenvolvedor . ',
                        nmdesenvolvedor: "' . utf8_decode($dsnome) . '",
                        nrdocumento: "' . $nrdocumento . '",
                        nrtelefone: "' . $nrtelefone . '",
                        dscontato: "' . $dscontato . '",
                        dsemail: "' . $dsemail . '"
                    });';
                ?>
                    <tr>
                        <td>
                            <input type="hidden" id="cddesenvolvedor" name="cddesenvolvedor" value="<? echo $cddesenvolvedor; ?>" >
                            <?php echo $cddesenvolvedor . ' - ' . utf8_decode($dsnome); ?>
                        </td>
                        <td><?php echo $nrdocumento; ?></td>
                    </tr>
                <?
					$countData++;
                }
                ?>
            </tbody>
        </table>
        <?
        echo '<script>', $script, '</script>';
        ?>
    </div>

    
    <div id="divBotoes" style="padding-bottom:10px">
        <? if ($cddopcao != 'C') { ?>
		<input id="btIncluir"  type="button" class="botao" value="Incluir"  onclick="controlaPesquisa()" />
        <input id="btExcluir"  type="button" class="<?=(($countData) ? 'botao' : 'botaoDesativado');?>" value="Remover"  onclick="<?=(($countData) ? 'removeDesenvolvedor();' : 'return false;');?>"/>
		<? } ?>
        <input id="btDetalhar" type="button" class="<?=(($countData) ? 'botao' : 'botaoDesativado');?>" value="Detalhar" onclick="<?=(($countData) ? 'detalharDesenvolvedor();' : 'return false;');?>"/>
    </div>

</fieldset>

<script>
    hideMsgAguardo();
    
    $('#divDesenvolvedores').show();

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '400px';
    arrayLargura[1] = '205px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'center';

    $('#tbDesenvolvedores').formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
</script>

<style type="text/css">
	#fldDesenvolvedor table.tituloRegistros{width: 600px;}
	#fldDesenvolvedor table.tituloRegistros tr td:first-child{width: 400px !important;}
	#fldDesenvolvedor table.tituloRegistros tr td:last-child{width: 219px !important;}
</style>