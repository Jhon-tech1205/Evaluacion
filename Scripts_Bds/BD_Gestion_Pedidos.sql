Create database g_pedidos;
use g_pedidos;

CREATE TABLE usuarios (
    cod_usuario INT AUTO_INCREMENT NOT NULL,
    usuario VARCHAR(50) UNIQUE NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    clave VARCHAR(100) NOT NULL,
    estado_sesion CHAR(1) NOT NULL,
    ultima_fecha_y_hora_i_sesion DATETIME NOT NULL,
    foto_usuario LONGBLOB NOT NULL,
    PRIMARY KEY (cod_usuario)
);



CREATE TABLE cliente (
    cod_cliente INT AUTO_INCREMENT NOT NULL,
    ruc_o_dni VARCHAR(20) NOT NULL UNIQUE,
    razon_social VARCHAR(100) NOT NULL,
    direccion_entrega VARCHAR(200) NOT NULL,
    direccion_fiscal VARCHAR(200) NOT NULL,
    fecha_registro DATE NOT NULL,
    usuarios_cod_usuario INT NOT NULL,
    PRIMARY KEY (cod_cliente),
    FOREIGN KEY (usuarios_cod_usuario) REFERENCES usuarios(cod_usuario)
);

CREATE TABLE productos (
    cod_producto INT AUTO_INCREMENT NOT NULL,
    descripcion_producto VARCHAR(200) NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    moneda VARCHAR(3) NOT NULL,
    PRIMARY KEY (cod_producto)
);


CREATE TABLE cabecera_pedido (
    cod_pedido INT AUTO_INCREMENT NOT NULL,
    direccion_entrega VARCHAR(200) NOT NULL,
    sub_total DECIMAL(10, 2),
    cant_total INT,
    igv DECIMAL(10, 2),
    total DECIMAL(10, 2),
    cliente_cod_cliente INT NOT NULL,
    PRIMARY KEY (cod_pedido),
    FOREIGN KEY (cliente_cod_cliente) REFERENCES cliente(cod_cliente)
);

CREATE TABLE detalle_pedido (
    numero_linea INT NOT NULL,
    cantidad INT NOT NULL,
    total_detalle DECIMAL(10, 2) NOT NULL,
    codigo_pedido varchar(50) NOT NULL,
    cod_pedido_cabecera INT NOT NULL,
    cod_producto INT NOT NULL,
    PRIMARY KEY (numero_linea, codigo_pedido),
    FOREIGN KEY (cod_pedido_cabecera) REFERENCES cabecera_pedido(cod_pedido),
    FOREIGN KEY (cod_producto) REFERENCES productos(cod_producto)
);

Select * from detalle_pedido;
Select * from usuarios;
select*from cabecera_pedido;
select*from cliente;
select*from productos;





