<?php
/*!
 * FONTE        : consultar_banners.php
 * CRIAÇÃO      : Amazonas
 * DATA CRIAÇÃO : 26/02/2018
 * OBJETIVO     : Formulário com tabela dos banners configurados
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

 //Carregar os parametros do canal
$xml  = '';
$xml .= '<Root><Dados>';
$xml .= '<cdcanal>'.$cdcanal.'</cdcanal>';
$xml .= '</Dados></Root>';

// Enviar XML de ida e receber String XML de resposta
$xmlResultParamentro = mensageria($xml, 'TELA_PARBAN','TELA_BANNER_PARAMETROS', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObjetoParamentro = getObjectXML($xmlResultParamentro);

// Se ocorrer um erro, mostra crítica
if (isset($xmlObjetoParamentro->roottag->tags[0]->name) && strtoupper($xmlObjetoParamentro->roottag->tags[0]->name) == "ERRO") {
	exibeErro($xmlObjetoParamentro->roottag->tags[0]->tags[0]->tags[4]->cdata);
	die();
}
$paramentro = $xmlObjetoParamentro->roottag->tags[0]->tags[1]->tags[0]->tags;
$nrsegundos_transicao = getByTagName($paramentro,'NRSEGUNDOS_TRANSICAO');
 
$xml  = '';
$xml .= '<Root><Dados>';
$xml .= '<cdbanner>0</cdbanner>';
$xml .= '<cdcanal>'.$cdcanal.'</cdcanal>';
$xml .= '</Dados></Root>';

// Enviar XML de ida e receber String XML de resposta
$xmlResult = mensageria($xml, 'TELA_PARBAN', 'TELA_BANNER_CONSULTA', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObjeto = getObjectXML($xmlResult);

echo "<script> /*";
	print_r($xmlResult );
	echo "*/</script> ";

// Se ocorrer um erro, mostra crítica
if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
    exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
    die();
}

$registros = $xmlObjeto->roottag->tags[0]->tags[2]->tags;
		
$qtRegistros = count($registros);
?>

<style>
    .banner_disabled {
        background: darkgray;

    }

    .sortable {
        margin-right: 10px;
        cursor: pointer;
		height:20px;
		width: 100%;
		padding-left: 5px;
		padding-top: 2px;
		border-bottom: 1px solid #888;
		
    }

    /*.sortable:hover {
        background-color: rgb(244, 243, 240);
        color: rgb(0, 0, 0);
        cursor: pointer;
        outline: rgb(107, 121, 132) solid 1px;
    }*/

    .selected {
        background-color: rgb(89, 91, 244);
        color: rgb(255, 255, 255);

    }

    .selected:hover {
        background-color: rgb(89, 91, 244);
        color: rgb(255, 255, 255);
    }

	.divConsultas fieldset{
		clear: both;
    	border: 1px solid #bbb;
    	margin: 3px;
    	padding: 0px 3px 5px 3px; 
	}

	.divConsultas fieldset legend {
		font-size: 12px;
		color: #333;
		margin-left: 5px;
		padding: 0px 2px;
	}

	#action_buttons_list{
		clear: both;
		text-align: center;
		height:20px;
		padding:16px;
	}
	#grid_resultados{
		background: #ffff;
		list-style-type: none; 
		position: relative;
	}
</style>



<div class="divConsultas" height="height: 300px">

    <fieldset>
        <legend><b>Banners :</b></legend>
        <div id="content_result" style="float: left;width: 300px;overflow-y: scroll;overflow-x:  hidden;height:135px; border:1px solid #333; background-color:#fff; ">
			<?php 
				  echo "<input type=\"hidden\" name=\"hcdcooper\" id=\"hcdcooper\" value=\"".$glbvars["cdcooper"]."\" />";
				  echo "<input type=\"hidden\" name=\"hcdagenci\" id=\"hcdagenci\" value=\"".$glbvars["cdagenci"]."\" />";
				  echo "<input type=\"hidden\" name=\"hnrdcaixa\" id=\"hnrdcaixa\" value=\"".$glbvars["nrdcaixa"]."\" />";
				  echo "<input type=\"hidden\" name=\"hidorigem\" id=\"hidorigem\" value=\"".$glbvars["idorigem"]."\" />";
				  echo "<input type=\"hidden\" name=\"hcdoperad\" id=\"hcdoperad\" value=\"".$glbvars["cdoperad"]."\" />";
			?>
			
            <ul id="grid_resultados" >
				<?php
					if($qtRegistros > 0){
					    for ($i = 0; $i < $qtRegistros; $i++){ 
				?>
					<li id="banner<?= getByTagName($registros[$i]->tags, 'CDBANNER'); ?>" 
						index="<?= getByTagName($registros[$i]->tags, 'CDBANNER'); ?>" 
						key="<?= getByTagName($registros[$i]->tags, 'CDBANNER'); ?>" 
						canalKey="<?= getByTagName($registros[$i]->tags, 'CDCANAL'); ?>" 
						class="sortable"><span class=" "></span><?= getByTagName($registros[$i]->tags, 'DSTITULO_BANNER_FORMATADO'); ?></li>
				<?php
	
					    }
                    }
				?>
            </ul>
        </div>
        <div style=" margin-left: 330px;">
            <table>
                <tr>
                    <td colspan="2" style='height:25px'><b><? echo utf8ToHtml('Observação')?>:</b></td>
                </tr>
                <tr>
                    <td colspan="2" style='height:25px'><? echo utf8ToHtml('Arraste os itens e depois clique em Salvar ordem & transi&ccedil;&atilde;o dos banners')?></td>
                </tr>
                <tr>
                    <td colspan="2" style='height:25px'><? echo utf8ToHtml('Selecione um banner para editá-lo.')?></td>
                </tr>
				<tr>
                    <td colspan="2" style='height:25px'></td>
                </tr>
                <tr >
                    <td style='width:130px height:30px'>
                        <label for="nrsegundos_transicao"><? echo utf8ToHtml('Tempo de transi&ccedil;&atilde;o:') ?></label>
						
                        <input type="number" min="1" id="nrsegundos_transicao" name="nrsegundos_transicao" class="campo"
                               style="width:50px;" maxlength="2" value="<?php echo($nrsegundos_transicao); ?>"/> segundos
                    </td>
                </tr>
				<tr>
                    <td  colspan="2"></td>
                </tr>
            </table>
			
        </div>
		<div id="action_buttons_list" >
				<a href="#" class="botao" id="updatePositionBtn" onclick="updatePositions(this)" ><? echo utf8ToHtml('Salvar ordem & transi&ccedil;&atilde;o dos banners') ?></a>
				<a href="#" class="botao" id="btnExcluirBanner" onclick="excluirBanner()" >Excluir </a> 
			</div>
    </fieldset>
</div>
<script>

	setGridSortable();
	//undoGridSortable();
	
	$(".sortable").click( function (elem) {
		selectItem(elem.currentTarget);
	});

</script>
</br>
</br>