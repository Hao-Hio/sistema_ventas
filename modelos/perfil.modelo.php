<?php

require_once "conexion.php";

class PerfilModelo{

    static public function mdlObtenerPerfiles(){        // CUANDO SE HACE LA CONSULTA SIEMPRE DEBE TENER LAS MISMAS COLUMNAS QUE LA CABEZERA thead

        $stmt = Conexion::conectar()->prepare("SELECT p.id_perfil,
                                                      p.descripcion,
                                                      p.estado,
                                                      date(p.fecha_creacion) as fecha_creacion,
                                                      p.fecha_actualizacion,
                                                      ' ' as opciones
                                                FROM perfiles p
                                                ORDER BY p.id_perfil");

        $stmt->execute();

        return $stmt->fetchAll();
    }

}


