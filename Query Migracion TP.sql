/* SCRIPT TP GDD MIGRACION DE DATOS */ 

use GD1C2025;
GO


IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'THIS_IS_FINE')
BEGIN
    EXEC('CREATE OR ALTER SCHEMA THIS_IS_FINE');
END;
GO

/* DROPEO las tablas para crear correctamente las PKs */

-- Tablas hijas
DROP TABLE IF EXISTS THIS_IS_FINE.detalle_pedido;
DROP TABLE IF EXISTS THIS_IS_FINE.detalle_factura;
DROP TABLE IF EXISTS THIS_IS_FINE.pedido_cancelacion;
DROP TABLE IF EXISTS THIS_IS_FINE.detalle_compra;
DROP TABLE IF EXISTS THIS_IS_FINE.sillon_material;
DROP TABLE IF EXISTS THIS_IS_FINE.Madera;
DROP TABLE IF EXISTS THIS_IS_FINE.Tela;
DROP TABLE IF EXISTS THIS_IS_FINE.Relleno;

-- Tablas intermedias o dependientes
DROP TABLE IF EXISTS THIS_IS_FINE.Compra;
DROP TABLE IF EXISTS THIS_IS_FINE.Pedido;
DROP TABLE IF EXISTS THIS_IS_FINE.Factura;
DROP TABLE IF EXISTS THIS_IS_FINE.Envio;

-- Tablas relativamente independientes
DROP TABLE IF EXISTS THIS_IS_FINE.Sillon;
DROP TABLE IF EXISTS THIS_IS_FINE.sillon_medida;
DROP TABLE IF EXISTS THIS_IS_FINE.sillon_modelo;
DROP TABLE IF EXISTS THIS_IS_FINE.Material;
DROP TABLE IF EXISTS THIS_IS_FINE.tipo_material;
DROP TABLE IF EXISTS THIS_IS_FINE.Proveedor;
DROP TABLE IF EXISTS THIS_IS_FINE.Cliente;
DROP TABLE IF EXISTS THIS_IS_FINE.Sucursal;
DROP TABLE IF EXISTS THIS_IS_FINE.Localidad;
DROP TABLE IF EXISTS THIS_IS_FINE.Provincia;


CREATE table THIS_IS_FINE.Cliente (
	cliente_codigo INT IDENTITY(1,1),
	cliente_dni NVARCHAR(100),
	cliente_nombre NVARCHAR(100),
	cliente_apellido NVARCHAR(100),
	cliente_fecha_nacimiento datetime2(6),
	cliente_mail NVARCHAR(100),
	cliente_telefono NVARCHAR(100),
	cliente_direccion NVARCHAR(100),
	cliente_localidad integer
	-- Agregar FK a Localidad
	CONSTRAINT PK_Cliente PRIMARY KEY (cliente_codigo)
)

CREATE table THIS_IS_FINE.Provincia (
	provincia_codigo INTEGER IDENTITY(1,1),
	provincia_detalle NVARCHAR(255),
	CONSTRAINT PK_Provincia PRIMARY KEY (provincia_codigo)
)

CREATE table THIS_IS_FINE.Localidad (
	localidad_codigo INTEGER IDENTITY(1,1),
	localidad_detalle NVARCHAR(255),
	localidad_provincia INTEGER -- FK a Provincia
	CONSTRAINT PK_Localidad PRIMARY KEY (localidad_codigo)
)
/* ALTER TABLE THIS_IS_FINE.Localidad
ADD CONSTRAINT FK_localidad_provincia FOREIGN KEY (localidad_provincia)
REFERENCES THIS_IS_FINE.Provincia(provincia_codigo); */


CREATE table THIS_IS_FINE.Proveedor (
	proveedor_codigo INTEGER IDENTITY(1,1),
	proveedor_cuit NVARCHAR(100),
	proveedor_razon_social NVARCHAR(100),
	proveedor_direccion NVARCHAR(100),
	proveedor_telefono	NVARCHAR(100),
	proveedor_mail NVARCHAR(100),
	proveedor_localidad INTEGER -- FK a Localidad
	CONSTRAINT PK_Proveedor PRIMARY KEY (proveedor_codigo)
)

CREATE table THIS_IS_FINE.Sucursal (
    sucursal_id int IDENTITY(1,1),
	sucursal_NroSucursal bigint, 
	sucursal_localidad INTEGER, --FK a localidad
	sucursal_direccion nvarchar(255),
	sucursal_telefono nvarchar(255),
	sucursal_mail nvarchar(255),
	CONSTRAINT PK_Sucursal PRIMARY KEY (sucursal_id)
)


/*Creación de FK Sucursal_localidad*/

/*ALTER TABLE THIS_IS_FINE.Sucursal
ADD CONSTRAINT FK_Sucursal_Localidad
FOREIGN KEY (sucursal_localidad) REFERENCES THIS_IS_FINE.Localidad(localidad_codigo); */

CREATE table THIS_IS_FINE.Pedido (
	pedido_numero decimal(18,0),
	pedido_fecha datetime2(6),
	pedido_sucursal int,
	--FK a Sucursal 
	pedido_estado nvarchar(255),
	--FK a cliente
	pedido_cliente int,
	pedido_total decimal(18,2),
	CONSTRAINT PK_Pedido PRIMARY KEY (pedido_numero),
	/*CONSTRAINT PK_Pedido_sucursal foreign key(pedido_sucursal) references THIS_IS_FINE.Sucursal(sucursal_id),
	CONSTRAINT FK_Pedido_cliente FOREIGN KEY (pedido_cliente) REFERENCES THIS_IS_FINE.Cliente(cliente_codigo) */
)


CREATE table THIS_IS_FINE.Factura (
	factura_numero bigint,
	factura_fecha datetime2(6),
	-- FK a Cliente
	factura_cliente int,
	--Fk a Sucursal
	factura_sucursal int,
	factura_total decimal(38,2),
	CONSTRAINT PK_Factura PRIMARY KEY (factura_numero),
	/*CONSTRAINT FK_factura_cliente FOREIGN KEY (factura_cliente) REFERENCES THIS_IS_FINE.Cliente(cliente_codigo),
	CONSTRAINT FK_factura_sucursal FOREIGN KEY (factura_sucursal) REFERENCES THIS_IS_FINE.Sucursal(sucursal_id) */
)

CREATE table THIS_IS_FINE.detalle_factura (
	fact_det_id int,
	--Fk a Factura
	fact_det_factura bigint,
	--FK a pedido
	fact_det_pedido decimal(18,0),
	fact_det_precio decimal(18,2),
	fact_det_cantidad decimal(18,0),
	fact_det_subtotal decimal(18,2)
	
	constraint PK_dettaleFactura primary key (fact_det_factura, fact_det_pedido, fact_det_id)
)

CREATE table THIS_IS_FINE.Envio(
    envio_numero decimal(18,0),
	envio_fecha_programada datetime2(6),
	envio_fecha datetime2(6),
	envio_importe_traslado decimal(18,2),
	envio_importe_subida decimal(18,2),
	envio_total decimal(18,2),
	envio_factura_numero bigint, --FK factura_numero
	CONSTRAINT PK_Envio PRIMARY KEY (envio_numero)
)

CREATE table THIS_IS_FINE.Sillon (
	sillon_codigo bigint,
	sillon_id_modelo BIGINT,--FK sillon_modelo
	sillon_id_medida BIGINT,-- Fk sillon_medida
	CONSTRAINT PK_Sillon PRIMARY KEY (sillon_codigo)
)

CREATE TABLE THIS_IS_FINE.detalle_pedido (
    -- Columnas FK
    pedido_numero   DECIMAL(18,0)   NOT NULL,
    sillon_codigo   BIGINT          NOT NULL,

    -- Datos propios
    pedido_det_cantidad   BIGINT        NULL,
    pedido_det_precio     DECIMAL(18,2) NULL,
	pedido_det_subtotal	  BIGINT		NULL,

    -- PK compuesta
    CONSTRAINT PK_detalle_pedido
      PRIMARY KEY (pedido_numero, sillon_codigo),

 );
--GO

CREATE table THIS_IS_FINE.pedido_cancelacion (
	pedido_cancelacion_codigo int IDENTITY(1,1),
	pedido_cancelacion_fecha datetime2(6),
	pedido_cancelacion_motivo varchar(255),
	pedido_codigo decimal(18,0),--FK a pedido
	CONSTRAINT PK_Pedido_cancelacion PRIMARY KEY (pedido_cancelacion_codigo)
)

CREATE table THIS_IS_FINE.sillon_modelo (
	sillon_modelo_codigo bigint,
	sillon_modelo_descripcion nvarchar(255),
	sillon_modelo_precio decimal(18,2),
	sillon_modelo nvarchar(255),
	CONSTRAINT PK_Modelo_Sillon PRIMARY KEY (sillon_modelo_codigo)
)

CREATE table THIS_IS_FINE.sillon_medida (
	sillon_medida_codigo int IDENTITY(1,1),
	sillon_medida_alto decimal(18,2),
	sillon_medida_ancho decimal(18,2),
	sillon_medida_profundidad decimal(18,2),
	sillon_medida_precio decimal(18,2),
	CONSTRAINT PK_MedidaSillon PRIMARY KEY (sillon_medida_codigo)
)


CREATE table THIS_IS_FINE.Compra (
	compra_numero decimal(18,0),
	compra_sucursal bigint,-- FK a Sucursal
	compra_proveedor int,-- FK a Proveedor
	compra_fecha datetime2(6),
	compra_total decimal(18,2),
	CONSTRAINT PK_CompraCodigo PRIMARY KEY (compra_numero)
)


CREATE table THIS_IS_FINE.detalle_compra (
	detalle_compra_numero decimal(18,0), -- FK a Compra
	detalle_compra_material int, -- FK a Material
	detalle_compra_precio decimal(18,2),
	detalle_compra_cantidad decimal(18,0),
	detalle_compra_precio_unitario decimal(18,2),
	detalle_compra_subtotal decimal(18,0),
	CONSTRAINT PK_DetalleCompra PRIMARY KEY (detalle_compra_numero, detalle_compra_material)
)

CREATE table THIS_IS_FINE.sillon_material (
	   id_material int, --FK a material
	   sillon_codigo bigint, -- FK a sillon
	   CONSTRAINT PK_SillonMaterial PRIMARY KEY (id_material, sillon_codigo)
)

CREATE table THIS_IS_FINE.Material (
    id_material int IDENTITY(1,1),
	material_tipo int,
	material_nombre nvarchar(255),
	material_descripcion nvarchar(255),
	material_precio decimal(38,2),
	CONSTRAINT PK_Material PRIMARY KEY (id_material)
)


CREATE table THIS_IS_FINE.Madera (
    id_material int, --FK a material
	madera_color nvarchar(255),
	madera_dureza nvarchar(255)
	CONSTRAINT PK_Madera PRIMARY KEY (id_material),
)

CREATE table THIS_IS_FINE.Tela (
    id_material int, --FK a material
	tela_color nvarchar(255),
	tela_textura nvarchar(255)
	CONSTRAINT PK_Tela PRIMARY KEY (id_material),
)


CREATE table THIS_IS_FINE.Relleno (
    id_material int, --FK a material
	relleno_densidad decimal(38,2)
	CONSTRAINT PK_Relleno PRIMARY KEY (id_material),
)

CREATE table THIS_IS_FINE.tipo_material (
     tipo_material_id int IDENTITY(1,1),
	 tipo_material_detalle nvarchar(255)
	 CONSTRAINT PK_Tipo_Material PRIMARY KEY (tipo_material_id)
) /*Ver si dejamos esto as�*/


/* A DISCUTIR: 
	- Que hacemos con tipo_material.
	- No estamos reflejando bien la relacion muchos a muchos de sillon-material, deberiamos partir la relacion con tabla intermedia
	sino no podemos reflejar de que materiales se hizo el sillon 
	- tipos de datos para las PKs
*/

/*Insertar Sill�n Modelo de la tabla maestra a tabla modelo_sillon*/
GO

      --------------   MIGRACIONES   -------------- 

CREATE OR ALTER PROCEDURE THIS_IS_FINE.migrar_sillon_modelo
AS
BEGIN

     SET NOCOUNT ON;

     INSERT INTO THIS_IS_FINE.sillon_modelo (
	      sillon_modelo_codigo, 
	      sillon_modelo_descripcion,
		  sillon_modelo_precio,
		  sillon_modelo
     )
	 SELECT DISTINCT 
	      sillon_modelo_codigo, 
		  sillon_modelo_descripcion,
		  sillon_modelo_precio,
		  sillon_modelo
     FROM gd_esquema.Maestra
	 WHERE sillon_modelo_codigo IS NOT NULL
END;
GO

exec THIS_IS_FINE.migrar_sillon_modelo -- QUEDA TODA LA TABLA EN NULLS Y ESTA BIEN
select * from THIS_IS_FINE.sillon_modelo

/*Insertar Medidas Sill�n de la tabla maestra a la tabla medida_sillon*/
GO
CREATE OR ALTER PROCEDURE THIS_IS_FINE.migrar_sillon_medida
AS
BEGIN

     SET NOCOUNT ON;

     INSERT INTO THIS_IS_FINE.sillon_medida (
	     sillon_medida_alto,
	     sillon_medida_ancho,
	     sillon_medida_profundidad
	 )
	 SELECT DISTINCT
	     sillon_medida_alto,
	     sillon_medida_ancho,
	     sillon_medida_profundidad
     FROM gd_esquema.Maestra
	 WHERE Sillon_Medida_Alto IS NOT NULL AND Sillon_Medida_Ancho IS NOT NULL 
	 AND Sillon_Medida_Profundidad IS NOT NULL  
END;
GO

exec THIS_IS_FINE.migrar_sillon_medida
GO

/*Insertar Tipo Material de la tabla maestra a la tabla tipo_material*/

CREATE OR ALTER PROCEDURE THIS_IS_FINE.migrar_tipo_material
AS
BEGIN

     SET NOCOUNT ON;

     INSERT INTO THIS_IS_FINE.tipo_material(tipo_material_detalle)
	 SELECT DISTINCT
	     material_tipo 
     FROM gd_esquema.Maestra
	 WHERE material_Tipo IS NOT NULL
END; /*Despu�s vemos si esto lo dejamos as�*/
GO
--DBCC CHECKIDENT ('THIS_IS_FINE.tipo_material', RESEED, 0);



/*Insertar provincia de la tabla maestra a tabla provincia*/

CREATE OR ALTER PROCEDURE THIS_IS_FINE.migrar_provincia
AS
BEGIN
INSERT INTO THIS_IS_FINE.Provincia (provincia_detalle)
SELECT DISTINCT provincia
FROM (
    SELECT Sucursal_Provincia AS provincia FROM gd_esquema.Maestra
    UNION
    SELECT Cliente_Provincia FROM gd_esquema.Maestra
    UNION
    SELECT Proveedor_Provincia FROM gd_esquema.Maestra
) AS provincias
WHERE provincia IS NOT NULL
and not exists (
	select 1 from THIS_IS_FINE.Provincia
)
END;
GO

/*insertando localidades de proveedor*/
CREATE OR ALTER PROCEDURE THIS_IS_FINE.migrar_localidades_proveedor
AS
BEGIN
    INSERT INTO THIS_IS_FINE.Localidad (localidad_detalle, localidad_provincia)
    SELECT DISTINCT
        RTRIM(LTRIM(maestra.Proveedor_Localidad)),
        Prov.provincia_codigo
    FROM gd_esquema.Maestra maestra
    JOIN THIS_IS_FINE.Provincia Prov 
      ON RTRIM(LTRIM(Prov.provincia_detalle)) = RTRIM(LTRIM(maestra.Proveedor_Provincia))
    WHERE maestra.Proveedor_Provincia IS NOT NULL
      AND maestra.Proveedor_Localidad IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM THIS_IS_FINE.Localidad Loc
          WHERE Loc.localidad_detalle = RTRIM(LTRIM(maestra.Proveedor_Localidad))
            AND Loc.localidad_provincia = Prov.provincia_codigo
      )
END;
GO

exec THIS_IS_FINE.migrar_localidades_proveedor
GO

--DBCC CHECKIDENT ('THIS_IS_FINE.Localidad', RESEED, 0);

/*insertando localidades de sucursal*/

CREATE OR ALTER PROCEDURE THIS_IS_FINE.migrar_localidades_sucursal
AS
BEGIN
    INSERT INTO THIS_IS_FINE.Localidad (localidad_detalle, localidad_provincia)
    SELECT DISTINCT
        RTRIM(LTRIM(maestra.Sucursal_Localidad)),
        Prov.provincia_codigo
    FROM gd_esquema.Maestra maestra
    JOIN THIS_IS_FINE.Provincia Prov
      ON RTRIM(LTRIM(Prov.provincia_detalle)) = RTRIM(LTRIM(maestra.Sucursal_Provincia))
    WHERE maestra.Sucursal_Provincia IS NOT NULL
      AND maestra.Sucursal_Localidad IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM THIS_IS_FINE.Localidad Loc
          WHERE Loc.localidad_detalle = RTRIM(LTRIM(maestra.Sucursal_Localidad))
            AND Loc.localidad_provincia = Prov.provincia_codigo
      )
END;
GO

/*insertando localidades de cliente*/

CREATE OR ALTER PROCEDURE THIS_IS_FINE.migrar_localidades_cliente
AS
BEGIN
    INSERT INTO THIS_IS_FINE.Localidad (localidad_detalle, localidad_provincia)
    SELECT DISTINCT
        RTRIM(LTRIM(maestra.Cliente_Localidad)),
        Prov.provincia_codigo
    FROM gd_esquema.Maestra maestra
    JOIN THIS_IS_FINE.Provincia Prov    
      ON RTRIM(LTRIM(Prov.provincia_detalle)) = RTRIM(LTRIM(maestra.Cliente_Provincia))
    WHERE maestra.Cliente_Provincia IS NOT NULL
      AND maestra.Cliente_Localidad IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM THIS_IS_FINE.Localidad Loc
          WHERE Loc.localidad_detalle = RTRIM(LTRIM(maestra.Cliente_Localidad))
            AND Loc.localidad_provincia = Prov.provincia_codigo
      )
END;
GO

CREATE OR ALTER PROCEDURE THIS_IS_FINE.migrar_localidades
AS
BEGIN
	EXEC THIS_IS_FINE.migrar_localidades_cliente;
	EXEC THIS_IS_FINE.migrar_localidades_proveedor;
	EXEC THIS_IS_FINE.migrar_localidades_sucursal;
END
GO

/* Migracion de Cliente */

CREATE OR ALTER procedure THIS_IS_FINE.migrar_cliente
as 
BEGIN 
	insert into THIS_IS_FINE.Cliente (cliente_dni, cliente_nombre, cliente_apellido, cliente_fecha_nacimiento, cliente_mail, cliente_telefono, cliente_direccion, cliente_localidad)
	select distinct Cliente_Dni, Cliente_Nombre, Cliente_Apellido, Cliente_FechaNacimiento, Cliente_Mail, Cliente_Telefono, Cliente_Direccion, localidad_codigo
	from gd_esquema.Maestra maestra
	join THIS_IS_FINE.Localidad on maestra.Cliente_Localidad = localidad_detalle
	join THIS_IS_FINE.Provincia on maestra.Cliente_Provincia = provincia_detalle
	where Cliente_Dni is not null and Cliente_Nombre is not null and Cliente_Apellido is not null and Cliente_FechaNacimiento is not null and Cliente_Telefono is not null and Cliente_Direccion is not null and Cliente_Localidad is not null
	and localidad_provincia = provincia_codigo
END 
GO

/* Migracion de Sucursal*/

ALTER PROCEDURE THIS_IS_FINE.migrar_sucursal
AS
BEGIN

     SET NOCOUNT ON;

     INSERT INTO THIS_IS_FINE.Sucursal (
	      sucursal_NroSucursal, 
	      sucursal_localidad,
	      sucursal_direccion,
	      sucursal_telefono,
	      sucursal_mail
     )
	 SELECT DISTINCT 
	      sucursal_NroSucursal, 
		  Loc.localidad_codigo,
		  sucursal_direccion,
		  sucursal_telefono,
		  sucursal_mail
     FROM gd_esquema.Maestra maestra
	 LEFT JOIN THIS_IS_FINE.Localidad Loc /*Creo que va con left porque no llamás por PK, y supongo que hay que traer las sucursales aunque no tengan loc*/
	 ON Loc.localidad_detalle = maestra.Sucursal_Localidad
	 join THIS_IS_FINE.Provincia on Loc.localidad_provincia = provincia_codigo and Sucursal_Provincia = provincia_detalle
	 WHERE sucursal_NroSucursal IS NOT NULL
	/*Cómo hacíamos entonces con los NULL?*/
END;
GO
/*exec THIS_IS_FINE.migrar_sucursal
select * from  THIS_IS_FINE.Sucursal
DBCC CHECKIDENT ('THIS_IS_FINE.Sucursal', RESEED, 0); */


CREATE OR ALTER PROCEDURE THIS_IS_FINE.migrar_pedido
AS
BEGIN

    INSERT INTO THIS_IS_FINE.Pedido (
        pedido_numero,
        pedido_fecha,
        pedido_sucursal,
        pedido_cliente,
        pedido_estado,
        pedido_total
    )
    SELECT DISTINCT
        ma.Pedido_Numero,
        ma.Pedido_Fecha,
        s.Sucursal_NroSucursal,
        c.cliente_codigo,
        ma.Pedido_Estado,
        ma.Pedido_Total
    FROM gd_esquema.Maestra AS ma
    LEFT JOIN THIS_IS_FINE.Cliente  AS c 
      ON c.cliente_dni = ma.Cliente_Dni
    LEFT JOIN THIS_IS_FINE.Sucursal AS s 
      ON s.sucursal_NroSucursal = ma.Sucursal_NroSucursal
    WHERE ma.Pedido_Numero IS NOT NULL
      AND ma.Sucursal_NroSucursal IS NOT NULL
      AND s.sucursal_NroSucursal IS NOT NULL
END;
GO

exec THIS_IS_FINE.migrar_pedido

-- select distinct Pedido_Numero, Pedido_Fecha, Pedido_Estado, Pedido_Total
-- from gd_esquema.Maestra
-- where Pedido_Numero is not null and Pedido_Fecha is not null and Pedido_Estado is not null and Pedido_Total is not null
select * from THIS_IS_FINE.Pedido
GO


CREATE OR ALTER PROCEDURE THIS_IS_FINE.migrar_detalle_pedido
AS
BEGIN

	SET NOCOUNT ON;
	
	INSERT INTO THIS_IS_FINE.detalle_pedido (
		pedido_numero,
		sillon_codigo,
		pedido_det_cantidad,
		pedido_det_precio,
		pedido_det_subtotal
	)
	SELECT DISTINCT
		p.pedido_numero,
		s.sillon_codigo,
		m.detalle_pedido_cantidad,
		m.detalle_pedido_precio,
		m.detalle_pedido_subtotal
		FROM gd_esquema.Maestra AS m
		JOIN THIS_IS_FINE.Pedido AS p
		ON p.pedido_numero  = m.pedido_numero
		JOIN THIS_IS_FINE.Sillon AS s
		ON s.sillon_codigo  = m.sillon_codigo
		WHERE m.pedido_numero  IS NOT NULL
		AND m.sillon_codigo  IS NOT NULL;
END
GO
/*Migración de Material*/

CREATE OR ALTER PROCEDURE THIS_IS_FINE.migrar_material
AS
BEGIN

     SET NOCOUNT ON;

     INSERT INTO THIS_IS_FINE.Material (
	     material_tipo,
	     material_nombre,
	     material_descripcion,
	     material_precio 
     )
	 SELECT DISTINCT 
	     Tipo.tipo_material_id,
		 material_nombre,
		 material_descripcion,
		 material_precio
     FROM gd_esquema.Maestra maestra
	 JOIN THIS_IS_FINE.tipo_material Tipo 
	 ON maestra.Material_Tipo = Tipo.tipo_material_detalle
	 WHERE material_descripcion IS NOT NULL
	 and material_precio IS NOT NULL /*los otros ya quedan filtrados por el JOIN?, 
	 tampoco sé si podemos traer los materiales si no tienen descripción o precio */
END;
GO

/*Migración de Madera*/

CREATE OR ALTER PROCEDURE THIS_IS_FINE.migrar_madera
AS
BEGIN

     INSERT INTO THIS_IS_FINE.Madera (
	     id_material,
	     madera_color,
	     madera_dureza
     )
	 SELECT DISTINCT 
	     Mat.id_material,
		 madera_color,
		 madera_dureza
     FROM gd_esquema.Maestra maestra
	 JOIN THIS_IS_FINE.tipo_material Tipo
	 ON maestra.Material_Tipo = Tipo.tipo_material_detalle
	 JOIN THIS_IS_FINE.Material Mat
	 ON Mat.material_tipo = Tipo.tipo_material_id
	 WHERE Tipo.tipo_material_detalle = 'Madera'
	 AND Madera_Color IS NOT NULL AND madera_dureza IS NOT NULL /*ver si se pueden aceptar nulls*/
END;
GO


exec THIS_IS_FINE.migrar_madera
GO
/*Migración de Tela*/

CREATE OR ALTER PROCEDURE THIS_IS_FINE.migrar_tela
AS
BEGIN

     SET NOCOUNT ON;

     INSERT INTO THIS_IS_FINE.Tela (
	     id_material,
	     tela_color,
		 tela_textura
     )
	 SELECT DISTINCT 
	     Mat.id_material,
		 tela_color,
		 tela_textura
     FROM gd_esquema.Maestra maestra
	 JOIN THIS_IS_FINE.tipo_material Tipo
	 ON maestra.Material_Tipo = Tipo.tipo_material_detalle
	 JOIN THIS_IS_FINE.Material Mat
	 ON Mat.material_tipo = Tipo.tipo_material_id
	 WHERE Tipo.tipo_material_detalle = 'Tela'
	 AND Tela_Color IS NOT NULL AND tela_textura IS NOT NULL /*ver si se pueden aceptar nulls*/
END;
GO

exec THIS_IS_FINE.migrar_tela
exec THIS_IS_FINE.migrar_relleno
GO
/*Migración de Relleno*/

CREATE OR ALTER PROCEDURE THIS_IS_FINE.migrar_relleno
AS
BEGIN

     SET NOCOUNT ON;

     INSERT INTO THIS_IS_FINE.Relleno (
	     id_material,
	     relleno_densidad
     )
	 SELECT DISTINCT 
	     Mat.id_material,
		 relleno_densidad
     FROM gd_esquema.Maestra maestra
	 JOIN THIS_IS_FINE.tipo_material Tipo
	 ON maestra.Material_Tipo = Tipo.tipo_material_detalle
	 JOIN THIS_IS_FINE.Material Mat
	 ON Mat.material_tipo = Tipo.tipo_material_id
	 WHERE Tipo.tipo_material_detalle = 'Relleno'
	 AND Relleno_Densidad IS NOT NULL /*ver si se pueden aceptar nulls*/
END;
GO

/*Migración de Sillon*/

CREATE OR ALTER PROCEDURE THIS_IS_FINE.migrar_sillon
AS
BEGIN

     SET NOCOUNT ON;

     INSERT INTO THIS_IS_FINE.Sillon (
	     sillon_codigo,
	     sillon_id_modelo,
	     sillon_id_medida
     )
	 SELECT DISTINCT 
	     sillon_codigo,
		 Model.sillon_modelo_codigo,
		 Med.sillon_medida_codigo
     FROM gd_esquema.Maestra maestra
	 JOIN THIS_IS_FINE.sillon_modelo Model
	 ON maestra.Sillon_Modelo_Codigo = Model.sillon_modelo_codigo
	 JOIN THIS_IS_FINE.sillon_medida Med
	 ON maestra.Sillon_Medida_Alto+maestra.Sillon_Medida_Ancho+maestra.Sillon_Medida_Precio+maestra.Sillon_Medida_Profundidad =
	 Med.sillon_medida_alto+Med.sillon_medida_ancho+Med.sillon_medida_precio+Med.sillon_medida_profundidad
	 WHERE sillon_codigo IS NOT NULL
END;
GO

/*Migración de Sillon*/

CREATE OR ALTER PROCEDURE THIS_IS_FINE.migrar_sillon_material
AS
BEGIN

     SET NOCOUNT ON;

     INSERT INTO THIS_IS_FINE.sillon_material (
	     id_material,
		 sillon_codigo
     )
	 SELECT DISTINCT 
	     Mat.id_material,
		 Sill.sillon_codigo
     FROM gd_esquema.Maestra maestra
	 JOIN THIS_IS_FINE.Sillon Sill 
	 ON maestra.Sillon_Codigo = Sill.sillon_codigo
	 JOIN THIS_IS_FINE.Material Mat
	 ON maestra.Material_Nombre+maestra.Material_Descripcion+maestra.Material_Precio =
	 Mat.material_nombre+Mat.material_descripcion+Mat.material_precio
	 WHERE maestra.sillon_codigo IS NOT NULL and maestra.material_nombre IS NOT NULL
END;
GO

CREATE OR ALTER PROCEDURE THIS_IS_FINE.migrar_Facturas
AS
BEGIN

    -- Insertamos las facturas desde la tabla maestra, haciendo join con sucursal y cliente
    INSERT INTO THIS_IS_FINE.Factura (
        factura_numero,
        factura_fecha,
        factura_total,
        factura_sucursal,
        factura_cliente
    )
    SELECT DISTINCT
        maestra.Factura_Numero,
        maestra.Factura_Fecha,
        maestra.Factura_Total,
        sucursal.sucursal_NroSucursal,
        cliente.cliente_codigo
    FROM gd_esquema.Maestra maestra
    JOIN THIS_IS_FINE.Sucursal sucursal
        ON maestra.Sucursal_NroSucursal = sucursal.sucursal_NroSucursal
    JOIN THIS_IS_FINE.Cliente cliente
        ON maestra.Cliente_Dni = cliente.cliente_dni
    WHERE maestra.Factura_Numero IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM THIS_IS_FINE.Factura factura
          WHERE factura.factura_numero = maestra.Factura_Numero
      )
END;
GO

CREATE OR ALTER PROCEDURE THIS_IS_FINE.migrar_detalle_factura
AS
BEGIN
    INSERT INTO THIS_IS_FINE.detalle_factura (
        fact_det_factura,
        fact_det_pedido,
		fact_det_id,
        fact_det_precio,
        fact_det_cantidad,
        fact_det_subtotal
    )
    SELECT
        factura.Factura_Numero,
        pedido.Pedido_Numero,
		ROW_NUMBER() OVER (
            PARTITION BY maestra.Factura_Numero, maestra.Pedido_Numero
            ORDER BY maestra.Detalle_Factura_Precio, maestra.Detalle_Factura_Cantidad
        ) AS fact_det_id,
        maestra.Detalle_Factura_Precio,
        maestra.Detalle_Factura_Cantidad,
        maestra.Detalle_Factura_SubTotal
    FROM gd_esquema.Maestra maestra
    JOIN THIS_IS_FINE.Factura factura ON factura.factura_numero = maestra.Factura_Numero
    JOIN THIS_IS_FINE.Pedido pedido ON pedido.pedido_numero = maestra.Pedido_Numero;

    
END;
GO

/*Migración de Proveedor*/

CREATE OR ALTER PROCEDURE THIS_IS_FINE.migrar_proveedor
AS
BEGIN

     SET NOCOUNT ON;

     INSERT INTO THIS_IS_FINE.Proveedor (
	     proveedor_cuit,
	     proveedor_razon_social,
	     proveedor_direccion,
	     proveedor_telefono,
	     proveedor_mail,
	     proveedor_localidad
     )
	 SELECT DISTINCT 
	     proveedor_cuit,
	     proveedor_razonSocial,
	     proveedor_direccion,
	     proveedor_telefono,
	     proveedor_mail,
		 Loc.localidad_codigo
     FROM gd_esquema.Maestra maestra
	 LEFT JOIN THIS_IS_FINE.Localidad Loc
	 ON maestra.Proveedor_Localidad = Loc.localidad_detalle
END;
GO

/*Migración de Compra*/

CREATE OR ALTER PROCEDURE THIS_IS_FINE.migrar_compra
AS
BEGIN

     SET NOCOUNT ON;

     INSERT INTO THIS_IS_FINE.Compra (
	     compra_numero,
	     compra_sucursal,
     	 compra_proveedor,
	     compra_fecha,
	     compra_total 
     )
	 SELECT DISTINCT 
	     compra_numero,
		 Suc.sucursal_id,
		 Prov.proveedor_codigo,
		 compra_fecha,
		 compra_total
     FROM gd_esquema.Maestra maestra
	 LEFT JOIN THIS_IS_FINE.Proveedor Prov
	 ON maestra.Proveedor_Cuit = Prov.proveedor_cuit /*está todo en null así que no sé si trae bien las cosas o si los cuit se repiten*/
	 LEFT JOIN THIS_IS_FINE.Sucursal Suc
	 ON maestra.Sucursal_NroSucursal+maestra.Sucursal_Localidad = Suc.Sucursal_NroSucursal+Suc.Sucursal_Localidad 
	 /*Hay un nro de sucursal que se repite*/
	 WHERE compra_numero IS NOT NULL
	 AND NOT EXISTS (
          SELECT 1 FROM THIS_IS_FINE.Compra Comp
          WHERE Comp.Compra_numero = maestra.Compra_Numero
      )
	 /*Por ahora compra está todo en NULL*/
END;
GO

/*Migración de detalle_compra*/

CREATE OR ALTER PROCEDURE THIS_IS_FINE.migrar_detalle_compra
AS
BEGIN

     SET NOCOUNT ON;

     INSERT INTO THIS_IS_FINE.detalle_compra (
	     detalle_compra_numero,
	     detalle_compra_material,
	     detalle_compra_precio_unitario,
	     detalle_compra_cantidad,
	     detalle_compra_subtotal
     )
	 SELECT DISTINCT 
	     Comp.compra_numero,
		 Mat.id_material,
		 detalle_compra_precio,
	     detalle_compra_cantidad,
	     detalle_compra_subtotal
     FROM gd_esquema.Maestra maestra
	 JOIN THIS_IS_FINE.Compra Comp
	 ON maestra.Compra_Numero = Comp.compra_numero
	 JOIN THIS_IS_FINE.Material Mat
	 ON maestra.Material_Nombre+maestra.Material_Descripcion+maestra.Material_Precio =
	 Mat.material_nombre+Mat.material_descripcion+Mat.material_precio
	 WHERE Mat.material_nombre IS NOT NULL /*NO SE SI DEFINIR ALGUNO MÁS O YA ALCANZA*/
END;
GO

/*Migración de Envío*/

CREATE OR ALTER PROCEDURE THIS_IS_FINE.migrar_envio
AS
BEGIN

     SET NOCOUNT ON;

     INSERT INTO THIS_IS_FINE.Envio (
	     envio_numero,
	     envio_fecha_programada,
	     envio_fecha,
	     envio_importe_traslado,
	     envio_importe_subida,
	     envio_total,
	     envio_factura_numero
     )
	 SELECT DISTINCT 
	     envio_numero,
	     envio_fecha_programada,
	     envio_fecha,
	     envio_importeTraslado,
	     envio_importeSubida,
	     envio_total,
		 Fac.factura_numero
     FROM gd_esquema.Maestra maestra
	 JOIN THIS_IS_FINE.Factura Fac
	 ON maestra.Factura_Numero = Fac.factura_numero
	 WHERE envio_numero IS NOT NULL /*NO SE SI DEFINIR ALGUNO MÁS O YA ALCANZA*/
END;
GO

/*Migración de Envío*/

CREATE OR ALTER PROCEDURE THIS_IS_FINE.migrar_pedido_de_cancelacion
AS
BEGIN

     SET NOCOUNT ON;

     INSERT INTO THIS_IS_FINE.pedido_cancelacion (
	     pedido_cancelacion_fecha,
	     pedido_cancelacion_motivo,
	     pedido_codigo
     )
	 SELECT DISTINCT 
	     pedido_cancelacion_fecha,
	     pedido_cancelacion_motivo,
		 Ped.pedido_numero
     FROM gd_esquema.Maestra maestra
	 JOIN THIS_IS_FINE.Pedido Ped
	 ON maestra.Pedido_Numero = Ped.pedido_numero
	 WHERE pedido_cancelacion_fecha IS NOT NULL AND pedido_cancelacion_motivo IS NOT NULL
END;
GO

select * from THIS_IS_FINE.Proveedor


exec THIS_IS_FINE.migrar_provincia;
exec THIS_IS_FINE.migrar_localidades_proveedor; 
exec THIS_IS_FINE.migrar_localidades_sucursal; 
exec THIS_IS_FINE.migrar_localidades_cliente;
exec THIS_IS_FINE.migrar_cliente;
exec THIS_IS_FINE.migrar_sucursal;
exec THIS_IS_FINE.migrar_Facturas;
exec THIS_IS_FINE.migrar_Pedido;
exec THIS_IS_FINE.migrar_detalle_pedido;
exec THIS_IS_FINE.migrar_detalle_factura;
GO

-- USE GD1C2025;
-- GO

-- DECLARE @sql NVARCHAR(MAX) = N'';

-- -- 1) Genero un string con un DROP por cada procedimiento en el esquema THIS_IS_FINE
-- SELECT @sql += 
--     N'DROP PROCEDURE THIS_IS_FINE.' + QUOTENAME(p.name) + N';' + CHAR(13) + CHAR(10)
-- FROM sys.procedures AS p
-- WHERE SCHEMA_NAME(p.schema_id) = 'THIS_IS_FINE';

-- -- 2) Ejecuto el batch que borrará todos esos procedimientos
-- EXEC sp_executesql @sql;
-- GO

select * from THIS_IS_FINE.detalle_factura