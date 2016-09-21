<?php
/* 
 * Classe Responsavel pelos formatos permitidos no REST
 * 
 * @autor: James Prust Junior 
 */
class RestFormat{
    
    const JSON = 'application/json';

    /** @var array */
    static public $aRestFormat = Array(
	'JSON' => RestFormat::JSON
    );
}
?>