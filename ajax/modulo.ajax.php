<?php

require_once "../controladores/modulo.controlador.php";
require_once "../modelos/modulo.modelo.php";

class AjaxModulos{

    public function ajaxObtenerModulos(){

        $modulos = ModuloControlador::ctrObtenerModulos();

        echo json_encode($modulos);
    }

    public function ajaxObtenerModulosPorPerfil($id_perfil){

        $modulosPerfil = ModuloControlador::ctrObtenerModulosPorPerfil($id_perfil);

        echo json_encode($modulosPerfil);
    }

    public function ajaxObtenerModulosSistemas(){

        $modulosSistema = ModuloControlador::ctrObtenerModulosSistema();

        echo json_encode($modulosSistema);
    }

    public function ajaxReorganizarModulos($modulos_ordenados){

        $modulosOrdenados = ModuloControlador::ctrReorganizarModulos($modulos_ordenados);

        echo json_encode($modulosOrdenados);
    }

    public function ajaxRegistrarModulo($data_modulo){

        $registro_modulo = ModuloControlador::ctrRegistrarModulo($data_modulo);

        echo json_encode($registro_modulo);

    }
}

if (isset($_POST['accion']) && $_POST['accion'] == 1) {
    
    $modulos = new AjaxModulos;
    $modulos ->ajaxObtenerModulos();

}else if (isset($_POST['accion']) && $_POST['accion'] == 2) {

    $modulosPerfil = new AjaxModulos;
    $modulosPerfil->ajaxObtenerModulosPorPerfil($_POST["id_perfil"]);

}else if (isset($_POST['accion']) && $_POST['accion'] == 3) {   //SOLICITUD PARA OBTENER MODULOS DEL SISTEMA

    $modulosSistema = new AjaxModulos;
    $modulosSistema->ajaxObtenerModulosSistemas();

}
else if (isset($_POST['accion']) && $_POST['accion'] == 4) { //SOLICITUD PARA REORGANIZAR LOS MODULOS

    $organizar_modulos = new AjaxModulos;
    $organizar_modulos->ajaxReorganizarModulos($_POST["modulos"]);

}else if (isset($_POST['accion']) && $_POST['accion'] == 5) { //SOLICITUD PARA REGISTRO DE MODULO

    $array_datos = [];

    parse_str($_POST['datos'],$array_datos);
    //var_dump($array_datos);
    $registrar_modulo = new AjaxModulos;
    $registrar_modulo->ajaxRegistrarModulo($array_datos);

}