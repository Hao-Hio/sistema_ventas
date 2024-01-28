
<?php

require_once "conexion.php";

class UsuarioModelo
{

    static public function mdlIniciarSesion($usuario, $password)
    {

        $stmt = Conexion::conectar()->prepare(" SELECT * FROM usuarios u 
                                            INNER JOIN perfiles p on u.id_perfil_usuario=p.id_perfil
                                            INNER JOIN perfil_modulo pm on pm.id_perfil= u.id_perfil_usuario
                                            INNER JOIN modulos m on m.id = pm.id_modulo
                                            WHERE u.usuario = :usuario AND u.clave = :password AND vista_inicio=1");


        $stmt->bindParam(":usuario", $usuario, PDO::PARAM_STR);
        $stmt->bindParam(":password", $password, PDO::PARAM_STR);

        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_CLASS);
    }

    static public function mdlObtenerMenuUsuario($id_usuario)
    {

        $stmt = Conexion::conectar()->prepare(" SELECT m.id, m.modulo, m.icon_menu, m.vista
                                    FROM usuarios u 
                                    INNER JOIN perfiles p on u.id_perfil_usuario=p.id_perfil
                                    INNER JOIN perfil_modulo pm on pm.id_perfil= p.id_perfil
                                    INNER JOIN modulos m on m.id = pm.id_modulo
                                    WHERE u.id_usuario = :id_usuario 
                                    AND (m.padre_id is null or m.padre_id = 0)
                                    ORDER BY m.orden");


        $stmt->bindParam(":id_usuario", $id_usuario, PDO::PARAM_STR);


        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_CLASS);
    }

    static public function mdlObtenerSubMenuUsuario($idMenu)
    {
            $stmt = Conexion::conectar()->prepare(" SELECT m.id, m.modulo, m.icon_menu, m.vista
                                        FROM modulos m
                                        WHERE m.padre_id = :idMenu
                                        ORDER BY m.id");


            $stmt->bindParam(":idMenu", $idMenu, PDO::PARAM_STR);


            $stmt->execute();

            return $stmt->fetchAll(PDO::FETCH_CLASS);
    }
}
