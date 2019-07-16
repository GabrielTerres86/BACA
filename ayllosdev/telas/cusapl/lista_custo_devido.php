<?php
//*********************************************************************************************//
//*** Fonte: lista_custo_devido.php                                    						***//
//*** Autor: David Valente - Envolti                                           				***//
//*** Data : Abril/2019                  Última Alteração: --/--/----  					    ***//
//***                                                                  						***//
//*** Objetivo  : Lista todos os custos devido                      					    ***//
//***             cooperativa selecionada.                             						***//
//*** Alterações: 																			***//
//*********************************************************************************************//

	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	$tpproces	= (isset($_POST["tpproces"])) ? $_POST["tpproces"] : '';
	$cdcooper	= (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : '';
	$dtde 		= (isset($_POST["dtde"])) ? $_POST["dtde"] : '';
	$dtate		= (isset($_POST["dtate"])) ? $_POST["dtate"] : '';
	$nrdconta	= (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;

	/*
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibirErro($msgError);
	}
	*/

	if (! isset($_POST['cdcooper'])) {
		exibirErro("Par&acirc;metros incorretos.");
	}
/*
	// Verifica se número da conta foi informado
	if ( !isset($_POST["nrdconta"])) {
		exibirErro("Par&acirc;metros incorretos.");
	}

	// Verifica se número da conta é um inteiro válido
	if (!isset($nrdconta) || !validaInteiro($nrdconta)) {
		exibirErro("Conta/dv inv&aacute;lida.");
	}
*/

	// Montar o xml de Requisicao
	$xml = '';
	$xml .= "	<Root>";
	$xml .= "		<Dados>";
	$xml .= "			<cdcooper>".$cdcooper."</cdcooper>";
	$xml .= "			<cdmodulo>CUSAPL</cdmodulo>";
	$xml .= "			<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "			<dtde>".$dtde."</dtde>";
	$xml .= "			<dtate>".$dtate."</dtate>";
	$xml .= "			<tpproces>".$tpproces."</tpproces>";
	$xml .= "		</Dados>";
	$xml .= "	</Root>";

	$xmlResult = mensageria($xml, "TELA_CUSAPL", "TELA_CUSAPL_TRT_CST_FRN_APL", $cdcooper, $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro',$retornoAposErro);
	} else {
		if ($tpproces == 1) {
			$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->cdata;
			exibirErro('inform',$msgErro,'Alerta - Aimaro',$retornoAposErro);
		} else if ($tpproces == 3) {
			$nmarquivo = getByTagName($xmlObjeto->roottag->tags[0]->tags[0]->tags,'nmarq001csv');// $xmlObjeto->roottag->tags[0]->tags[0]->tags[0]->cdata;

			if (!$eval) {
				$tagant = "<script>";
				$tagdep = "</script>";
			}

			echo $tagant;
			echo 'Gera_Impressao(\''.$nmarquivo.'\',\'\');';
			echo $tagdep;

			exit; //termina processamento para exportar arquivo.
		} else {
			$nmarquivo = getByTagName($xmlObjeto->roottag->tags[0]->tags[0]->tags,'nmarq001xml');// $xmlObjeto->roottag->tags[0]->tags[0]->tags[0]->cdata;

			if ($nmarquivo=="") {
				exibirErro('error',"Arquivo n&atilde;o gerado, verifique.",'Alerta - Aimaro',$retornoAposErro);
			}elseif(trim(substr($nmarquivo,0,13)) == 'teds_migradas'){
				$dsdircop = $glbvars["dscopmig"];
			}else{
				$dsdircop = $glbvars["dsdircop"];
			}

			$nmarqpdf  = "/var/www/ayllos/documentos/".$dsdircop."/temp/".$nmarquivo;

			if (!file_exists($nmarqpdf)) {
				exibirErro('error',"Arquivo n&atilde;o encontrado, tente novamente mais tarde.",'Alerta - Aimaro',$retornoAposErro);
			} else {
				$xmlResult = file_get_contents($nmarqpdf);
			}

			$xmlObjeto = getObjectXML($xmlResult);
			$dadosfinais = $xmlObjeto->roottag->tags[0]->tags[1];
			$listacusdev = $xmlObjeto->roottag->tags[0]->tags[0];
?>

<script type="text/javascript" src="../../scripts/funcoes.js"></script>

<style>
    .linha{ cursor: pointer; }
    .linha:hover {
        outline: rgb(107,121,132) solid 1px !important;
    }
	.divRegistrosCustoDevido tfoot {
		border-top: 2px solid black;
		border-bottom: 2px solid black;
	}
	.divRegistrosCustoDevido thead th, .divRegistrosCustoDevido tbody td, .divRegistrosCustoDevido tfoot td{
		border-top: 1px solid black;
		border-bottom: 1px solid black;
		border-left: 1px dotted #999;
		padding: 2px 10px;
	}
	.divRegistrosCustoDevido td.vlsalcon, .divRegistrosCustoDevido td.valueC {
		text-align: right;
		border-right: 1px dotted #999;
	}
	.divRegistrosCustoDevido th.thValue {
		border-right: 1px dotted #999;
	}
	div.divRegistrosCustoDevido table {
		border-collapse: collapse;
	}
</style>
<br />
<div class="tableListaCustoDevido">
    <div class="divRegistrosCustoDevido">
        <table id="tableArquivos" style="padding:0; margin:0 auto;">
            <thead style="diplay:block;">
                <tr>
                    <th>Dia</th>
                    <th class="thValue">Valores</th>
                </tr>
            </thead>
            <tbody>
                <?php
                if (count($listacusdev->tags) > 0) {
                    $parImpar = 1;
                    $idlinha = 0;
                    foreach ($listacusdev->tags as $dadosdia) {
                        $classelinha = '';
                        if ($parImpar == 1) {
                            $classelinha = 'even corImpar';
                            $parImpar = 2;
                        } else if ($parImpar == 2) {
                            $classelinha = 'odd corPar';
                            $parImpar = 1;
                        }
                        echo '<tr id="linha-', $idlinha, '" class="linha ', $classelinha, '">
								<td class="dtmvtolt">', getByTagName($dadosdia->tags,'dtmvtolt'), '</td>
								<td class="vlsalcon">', getByTagName($dadosdia->tags,'vlsalcon'), '</td>
							</tr>';
                        $idlinha++;
                    }
                } else {
                    echo '<tr class="linha"><td class="celula" colspan="2">Sem registros encontrados!</td></tr>';
                }
                ?>
            </tbody>
            <tfoot>
                <tr class="linha" style="">
					<td>Dias Uteis</td>
					<td class="valueC"><? echo getByTagName($dadosfinais->tags,'qtdiauti') ?></td>
				</tr>
				<tr class="linha">
					<td>Base Volume</td>
					<td class="valueC"><? echo getByTagName($dadosfinais->tags,'vlsalmed') ?></td>
				</tr>
				<tr class="linha">
					<td>Taxa Mensal</td>
					<td class="valueC"><? echo getByTagName($dadosfinais->tags,'prtaxmen') ?></td>
				</tr>
				<tr class="linha">
					<td>Valor Base C/Taxa Mensal</td>
					<td class="valueC"><? echo getByTagName($dadosfinais->tags,'vladicio') ?></td>
				</tr>
				<tr class="linha">
					<td>Valor Adicional  </td>
					<td class="valueC"><? echo getByTagName($dadosfinais->tags,'vltotadi') ?></td>
				</tr>
				<tr class="linha">
					<td>Valor Fixo</td>
					<td class="valueC"><? echo getByTagName($dadosfinais->tags,'vlcusfix') ?></td>
				</tr>
				<tr class="linha">
					<td>Valor Registrado Total</td>
					<td class="valueC"><? echo getByTagName($dadosfinais->tags,'vlregist') ?></td>
				</tr>
				<tr class="linha">
					<td>Percentual P/Valor Registrado</td>
					<td class="valueC"><? echo getByTagName($dadosfinais->tags,'prvlrreg') ?></td>
				</tr>
				<tr class="linha">
					<td>Valor Registrado a pagar</td>
					<td class="valueC"><? echo getByTagName($dadosfinais->tags,'vlregcal') ?></td>
				</tr>
				<tr class="linha">
					<td>Valor Devido Total</td>
					<td class="valueC"><? echo getByTagName($dadosfinais->tags,'vlsaltot') ?></td>
				</tr>
            </tfoot>
        </table>
    </div>
</div>

	<?php }
	}	?>