use g_pedidos;

-- Funcion para insertar un nuevo usuario
DELIMITER //
CREATE PROCEDURE RegistrarUsuario (
    IN p_usuario VARCHAR(50),
    IN p_nombres VARCHAR(100),
    IN p_clave VARCHAR(100),
    IN p_estado_sesion CHAR(1),
    IN p_ultima_fecha_hora DATETIME,
    IN p_foto_usuario LONGBLOB
)
BEGIN
    DECLARE v_cod_usuario INT;
    DECLARE v_clave_encriptada VARCHAR(64); 
    SET v_clave_encriptada = SHA2(p_clave, 256);
    INSERT INTO usuarios (usuario, nombres, clave, estado_sesion, ultima_fecha_y_hora_i_sesion, foto_usuario)
    VALUES (p_usuario, p_nombres, v_clave_encriptada, p_estado_sesion, p_ultima_fecha_hora, p_foto_usuario);
    SET v_cod_usuario = LAST_INSERT_ID();
    SELECT v_cod_usuario AS cod_usuario;
END //
DELIMITER ;


-- Funcion para iniciar sesion
DELIMITER //
CREATE FUNCTION IniciarSesion (
    p_usuario VARCHAR(50),
    p_clave VARCHAR(50)
)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_cod_usuario INT;
    DECLARE v_clave_encriptada VARCHAR(100);
    SET v_clave_encriptada = SHA2(p_clave, 256);
    SELECT cod_usuario INTO v_cod_usuario
    FROM usuarios
    WHERE usuario = p_usuario AND clave = v_clave_encriptada;
    IF v_cod_usuario IS NOT NULL THEN
        UPDATE usuarios
        SET estado_sesion = 'A',
            ultima_fecha_y_hora_i_sesion = NOW()
        WHERE cod_usuario = v_cod_usuario;
        
        RETURN v_cod_usuario;
    ELSE
        RETURN 0;
    END IF;
END //
DELIMITER ;


-- funcion para cerrar sesion 
DELIMITER //

CREATE FUNCTION CerrarSesion (
    p_cod_usuario INT
)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE v_rows_affected INT;
    UPDATE usuarios
    SET estado_sesion = 'C',
        ultima_fecha_y_hora_i_sesion = NOW()
    WHERE cod_usuario = p_cod_usuario;
    SELECT ROW_COUNT() INTO v_rows_affected;
    IF v_rows_affected > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END //

DELIMITER ;

-- funcion para ver el estado de la sesion 
DELIMITER //

CREATE FUNCTION VerificarEstadoSesion (
    p_usuario VARCHAR(50),
    p_clave VARCHAR(50)
)
RETURNS CHAR(1) 
READS SQL DATA
BEGIN
    DECLARE v_estado_sesion CHAR(1);
    DECLARE v_clave_encriptada VARCHAR(100);
    
    SET v_clave_encriptada = SHA2(p_clave, 256);

    SELECT estado_sesion INTO v_estado_sesion
    FROM usuarios
    WHERE usuario = p_usuario AND clave = v_clave_encriptada;
    RETURN v_estado_sesion;
END //

DELIMITER ;

-- funcion para calcular de manera masiva y actualizar en cabecera pedido
DELIMITER //

CREATE PROCEDURE ActualizarTotalesCabeceraPedido ()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_cod_pedido INT;
    DECLARE v_subtotal DECIMAL(10, 2);
    DECLARE v_cantidad_total INT;
    DECLARE v_igv DECIMAL(10, 2);
    DECLARE v_total DECIMAL(10, 2);

    DECLARE cur_pedidos CURSOR FOR
        SELECT cod_pedido
        FROM cabecera_pedido;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur_pedidos;

    read_loop: LOOP
        FETCH cur_pedidos INTO v_cod_pedido;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET v_subtotal = 0;
        SET v_cantidad_total = 0;

        SELECT SUM(total_detalle), SUM(cantidad)
        INTO v_subtotal, v_cantidad_total
        FROM detalle_pedido
        WHERE cod_pedido_cabecera = v_cod_pedido;

        SET v_igv = v_subtotal * 0.18;
        SET v_total = v_subtotal + v_igv;
        UPDATE cabecera_pedido
        SET sub_total = v_subtotal,
            cant_total = v_cantidad_total,
            igv = v_igv,
            total = v_total
        WHERE cod_pedido = v_cod_pedido;
    END LOOP;

    CLOSE cur_pedidos;
END //

DELIMITER ;

CALL ActualizarTotalesCabeceraPedido();

