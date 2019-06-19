<?php
/*!
 * FONTE        : form_motivos.php
 * CRIAÇÃO      : Petter Rafael - Envolti
 * DATA CRIAÇÃO : Janeiro/2019
 * OBJETIVO     : Formulário da rotina Motivos da tela ATENDA
 * --------------
 * ALTERAÇÕES   : 08/08/2017 
 * --------------
 */	
?>
<div class="divRegistros">
    <table>
		<thead>
			<tr>
                <th>Motivo</th>
                <th>Data Bloqueio</th>
                <th>Data Regulariza&ccedil;&atilde;o</th>
            </tr>
        </thead>
        <tbody>
            <?
            $motivos = $xmlObjeto->roottag->tags[0]->tags;

            foreach($motivos as $motivo){
                $idmotivo = getByTagName($motivo->tags,'idmotivo');
                $dsmotivo = getByTagName($motivo->tags,'dsmotivos');
                $dtbloqueio = getByTagName($motivo->tags,'dtbloqueio');
                $dtregulariza = getByTagName($motivo->tags,'dtregulariza');
                ?>
                <tr>
                    <td>
                        <?if(!empty($idmotivo)){
                            echo $idmotivo . " - " . $dsmotivo;
                        }else{
                            echo $dsmotivo;
                        }?>
                    </td>
                    <td>
                        <? echo $dtbloqueio; ?>
                    </td>
                    <td>
                        <? echo $dtregulariza; ?>
                    </td>
                </tr>
                <?
            }
            ?>
        </tbody>
    </table>
</div>
<ul class="complemento">
    <li>QUANTIDADE REGISTROS:</li>
    <li><? echo $xmlObjeto->roottag->tags[1]->cdata; ?></li>
</ul>