const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql2');
const jwt = require('jsonwebtoken');

const app = express();
const port = 3000;

const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: process.env.MYSQL_PASSWORD,
  database: 'g_pedidos' 
});

connection.connect((err) => {
  if (err) {
    console.error('Error al conectar a MySQL:', err);
    throw err;
  }
  console.log('Conectado a MySQL correctamente.');
});

app.use(bodyParser.json());


app.post('/login', (req, res) => {
  const { usuario, clave } = req.body;

  connection.query(
    'SELECT * FROM usuarios WHERE usuario = ? AND clave = SHA2(?, 256)',
    [usuario, clave],
    (error, results, fields) => {
      if (error) {
        console.error('Error al autenticar usuario:', error);
        res.status(500).json({ error: 'Error en el servidor' });
      } else {
        if (results.length > 0) {
          const token = jwt.sign({ usuario: results[0].usuario }, 'key12', { expiresIn: '1h' });
          res.json({ token });
        } else {
          res.status(401).json({ error: 'Credenciales incorrectas' });
        }
      }
    }
  );
});


app.get('/pedidos', (req, res) => {
  const { cod_cliente } = req.query;
  connection.query(
    'SELECT * FROM cabecera_pedido WHERE cliente_cod_cliente = ?',
    [cod_cliente],
    (error, results, fields) => {
      if (error) {
        console.error('Error al consultar pedidos:', error);
        res.status(500).json({ error: 'Error en el servidor' });
      } else {
        if (results.length > 0) {
          res.json(results);
        } else {
          res.status(404).json({ error: 'Cliente no encontrado o no tiene pedidos registrados' });
        }
      }
    }
  );
});


app.get('/pedidos/:id', (req, res) => {
  const pedidoId = req.params.id;

  const sql = `
    SELECT dp.numero_linea, dp.cantidad, dp.total_detalle, p.descripcion_producto, p.precio_unitario
    FROM detalle_pedido dp
    INNER JOIN productos p ON dp.cod_producto = p.cod_producto
    WHERE dp.codigo_pedido = ?;
  `;

  connection.query(sql, [pedidoId], (err, results) => {
    if (err) {
      console.error('Error al consultar el detalle del pedido:', err);
      return res.status(500).json({ error: 'Error interno del servidor' });
    }

    const detallePedido = results.map(row => ({
      numero_linea: row.numero_linea,
      cantidad: row.cantidad,
      total_detalle: row.total_detalle,
      descripcion_producto: row.descripcion_producto,
      precio_unitario: row.precio_unitario
    }));

    res.json(detallePedido);
  });
});


app.listen(port, () => {
  console.log(`Servidor escuchando en http://localhost:${port}`);
});
