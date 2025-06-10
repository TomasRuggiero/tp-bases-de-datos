/* SCRIPT TP GDD MIGRACION DE DATOS */ 

use GD1C2025;
GO


IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'THIS_IS_FINE')
BEGIN
    EXEC('CREATE SCHEMA THIS_IS_FINE');
END;
GO

/* DROPEO las tablas para crear correctamente las PKs */

-- Tablas hijas
DROP TABLE IF EXISTS THIS_IS_FINE.detalle_factura;
DROP TABLE IF EXISTS THIS_IS_FINE.detalle_pedido;
DROP TABLE IF EXISTS THIS_IS_FINE.pedido_de_cancelacion;
DROP TABLE IF EXISTS THIS_IS_FINE.detalle_compra;
DROP TABLE IF EXISTS THIS_IS_FINE.sillon_material;
DROP TABLE IF EXISTS THIS_IS_FINE.Madera;
DROP TABLE IF EXISTS THIS_IS_FINE.Tela;
DROP TABLE IF EXISTS THIS_IS_FINE.Relleno;

-- Tablas intermedias o dependientes
DROP TABLE IF EXISTS THIS_IS_FINE.Compra;
DROP TABLE IF EXISTS THIS_IS_FINE.Pedido;
DROP TABLE IF EXISTS THIS_IS_FINE.Envio;
DROP TABLE IF EXISTS THIS_IS_FINE.Factura;


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

/* DROP a todos los procedures para que no haya errores */
DROP PROCEDURE IF EXISTS THIS_IS_FINE.migrar_provincia;
DROP PROCEDURE IF EXISTS  THIS_IS_FINE.migrar_sillon_modelo;
DROP PROCEDURE IF EXISTS  THIS_IS_FINE.migrar_sillon_medida;
DROP PROCEDURE IF EXISTS  THIS_IS_FINE.migrar_tipo_material;
DROP PROCEDURE IF EXISTS  THIS_IS_FINE.migrar_localidad;
DROP PROCEDURE IF EXISTS  THIS_IS_FINE.migrar_cliente
DROP PROCEDURE IF EXISTS  THIS_IS_FINE.migrar_proveedor;
DROP PROCEDURE IF EXISTS  THIS_IS_FINE.migrar_sucursal;
DROP PROCEDURE IF EXISTS  THIS_IS_FINE.migrar_sillon;
DROP PROCEDURE IF EXISTS  THIS_IS_FINE.migrar_material;
DROP PROCEDURE IF EXISTS  THIS_IS_FINE.migrar_madera;
DROP PROCEDURE IF EXISTS  THIS_IS_FINE.migrar_tela;
DROP PROCEDURE IF EXISTS  THIS_IS_FINE.migrar_relleno;
DROP PROCEDURE IF EXISTS  THIS_IS_FINE.migrar_pedido;
DROP PROCEDURE IF EXISTS  THIS_IS_FINE.migrar_factura;
DROP PROCEDURE IF EXISTS  THIS_IS_FINE.migrar_envio;
DROP PROCEDURE IF EXISTS  THIS_IS_FINE.migrar_pedido_de_cancelacion;
DROP PROCEDURE IF EXISTS  THIS_IS_FINE.migrar_compra;
DROP PROCEDURE IF EXISTS  THIS_IS_FINE.migrar_detalle_pedido;
DROP PROCEDURE IF EXISTS  THIS_IS_FINE.migrar_detalle_factura;
DROP PROCEDURE IF EXISTS  THIS_IS_FINE.migrar_detalle_compra;
DROP PROCEDURE IF EXISTS  THIS_IS_FINE.migrar_sillon_material;

/* TABLAS COMPLETAMENTE INDEPENDIENTES -- SIN FKs */

create table THIS_IS_FINE.Provincia (
	provincia_codigo INTEGER IDENTITY(1,1),
	provincia_detalle NVARCHAR(255),
	CONSTRAINT PK_Provincia PRIMARY KEY (provincia_codigo)
)

create table THIS_IS_FINE.sillon_modelo (
	sillon_modelo_codigo bigint,
	sillon_modelo_descripcion nvarchar(255),
	sillon_modelo_precio decimal(18,2),
	sillon_modelo nvarchar(255),
	CONSTRAINT PK_Modelo_Sillon PRIMARY KEY (sillon_modelo_codigo)
)

create table THIS_IS_FINE.sillon_medida (
	sillon_medida_codigo int IDENTITY(1,1),
	sillon_medida_alto decimal(18,2),
	sillon_medida_ancho decimal(18,2),
	sillon_medida_profundidad decimal(18,2),
	sillon_medida_precio decimal(18,2),
	CONSTRAINT PK_MedidaSillon PRIMARY KEY (sillon_medida_codigo)
)

create table THIS_IS_FINE.tipo_material (
     tipo_material_id int IDENTITY(1,1),
	 tipo_material_detalle nvarchar(255)
	 CONSTRAINT PK_Tipo_Material PRIMARY KEY (tipo_material_id)
) 

/* TABLAS DEPENDIENTES CON DATOS MAESTROS */

create table THIS_IS_FINE.Localidad (
	localidad_codigo INTEGER IDENTITY(1,1),
	localidad_detalle NVARCHAR(255),
	localidad_provincia INTEGER -- FK a Provincia
	CONSTRAINT PK_Localidad PRIMARY KEY (localidad_codigo)
)

ALTER TABLE THIS_IS_FINE.Localidad
ADD CONSTRAINT FK_localidad_provincia FOREIGN KEY (localidad_provincia)
REFERENCES THIS_IS_FINE.Provincia(provincia_codigo);

create table THIS_IS_FINE.Cliente (
	cliente_codigo INT IDENTITY(1,1),
	cliente_dni NVARCHAR(100),
	cliente_nombre NVARCHAR(100),
	cliente_apellido NVARCHAR(100),
	cliente_fecha_nacimiento datetime2(6),
	cliente_mail NVARCHAR(100),
	cliente_telefono NVARCHAR(100),
	cliente_direccion NVARCHAR(100),
	cliente_localidad integer	-- FK a Localidad
	CONSTRAINT PK_Cliente PRIMARY KEY (cliente_codigo)
)

ALTER TABLE THIS_IS_FINE.Cliente
ADD CONSTRAINT FK_Cliente_Localidad
FOREIGN KEY (cliente_localidad) REFERENCES THIS_IS_FINE.Localidad(localidad_codigo);

create table THIS_IS_FINE.Proveedor (
	proveedor_codigo INTEGER IDENTITY(1,1),
	proveedor_cuit NVARCHAR(100),
	proveedor_razon_social NVARCHAR(100),
	proveedor_direccion NVARCHAR(100),
	proveedor_telefono	NVARCHAR(100),
	proveedor_mail NVARCHAR(100),
	proveedor_localidad INTEGER -- FK a Localidad
	CONSTRAINT PK_Proveedor PRIMARY KEY (proveedor_codigo)
)

ALTER TABLE THIS_IS_FINE.Proveedor
ADD CONSTRAINT FK_Proveedor_Localidad
FOREIGN KEY (proveedor_localidad) REFERENCES THIS_IS_FINE.Localidad(localidad_codigo);

create table THIS_IS_FINE.Sucursal (
    sucursal_id int IDENTITY(1,1),
	sucursal_NroSucursal bigint, 
	sucursal_localidad INTEGER, --FK a localidad
	sucursal_direccion nvarchar(255),
	sucursal_telefono nvarchar(255),
	sucursal_mail nvarchar(255),
	CONSTRAINT PK_Sucursal PRIMARY KEY (sucursal_id)
)

ALTER TABLE THIS_IS_FINE.Sucursal
ADD CONSTRAINT FK_Sucursal_Localidad
FOREIGN KEY (sucursal_localidad) REFERENCES THIS_IS_FINE.Localidad(localidad_codigo);

create table THIS_IS_FINE.Sillon (
    sillon_id int IDENTITY(1,1),
	sillon_codigo bigint,
	sillon_modelo BIGINT,--FK sillon_modelo
	sillon_medida INT,-- Fk sillon_medida
	CONSTRAINT PK_Sillon PRIMARY KEY (sillon_id)
)

ALTER TABLE THIS_IS_FINE.Sillon
ADD constraint FK_Sillon_Modelo
foreign key (sillon_modelo) references THIS_IS_FINE.Sillon_Modelo(sillon_modelo_codigo);

ALTER TABLE THIS_IS_FINE.Sillon
ADD constraint FK_Sillon_Medida
foreign key (sillon_medida) references THIS_IS_FINE.Sillon_Medida(sillon_medida_codigo);

create table THIS_IS_FINE.Material (
    id_material int IDENTITY(1,1),
	material_tipo int, --FK 
	material_nombre nvarchar(255),
	material_descripcion nvarchar(255),
	material_precio decimal(38,2),
	CONSTRAINT PK_Material PRIMARY KEY (id_material)
)

ALTER TABLE THIS_IS_FINE.Material
ADD constraint FK_Material_Tipo
foreign key (material_tipo) references THIS_IS_FINE.tipo_material(tipo_material_id);


create table THIS_IS_FINE.Madera (
    id_material int, --FK a material
	madera_color nvarchar(255),
	madera_dureza nvarchar(255)
	CONSTRAINT PK_Madera PRIMARY KEY (id_material),
)

ALTER TABLE THIS_IS_FINE.Madera
ADD constraint FK_Madera_id
foreign key (id_material) references THIS_IS_FINE.Material(id_material);


create table THIS_IS_FINE.Tela (
    id_material int, --FK a material
	tela_color nvarchar(255),
	tela_textura nvarchar(255)
	CONSTRAINT PK_Tela PRIMARY KEY (id_material),
)

ALTER TABLE THIS_IS_FINE.Tela
ADD constraint FK_Tela_id
foreign key (id_material) references THIS_IS_FINE.Material(id_material);

create table THIS_IS_FINE.Relleno (
    id_material int, --FK a material
	relleno_densidad decimal(38,2)
	CONSTRAINT PK_Relleno PRIMARY KEY (id_material),
)

ALTER TABLE THIS_IS_FINE.Relleno
ADD constraint FK_Relleno_id
foreign key (id_material) references THIS_IS_FINE.Material(id_material);


/* TABLAS TRANSACCIONALES - FUERTEMENTE DEPENDIENTES */

create table THIS_IS_FINE.Pedido (
	pedido_numero decimal(18,0),
	pedido_fecha datetime2(6),
	pedido_sucursal int, --FK a Sucursal 	
	pedido_estado nvarchar(255),	
	pedido_cliente int, --FK a cliente
	pedido_total decimal(18,2),
	CONSTRAINT PK_Pedido PRIMARY KEY (pedido_numero),
)

ALTER TABLE THIS_IS_FINE.Pedido
ADD	CONSTRAINT PK_Pedido_sucursal 
foreign key(pedido_sucursal) references THIS_IS_FINE.Sucursal(sucursal_id);

ALTER TABLE THIS_IS_FINE.Pedido
ADD	CONSTRAINT FK_Pedido_cliente
FOREIGN KEY (pedido_cliente) REFERENCES THIS_IS_FINE.Cliente(cliente_codigo);

create table THIS_IS_FINE.Factura (
	factura_numero bigint,
	factura_fecha datetime2(6),
	factura_cliente int, -- FK a Cliente	
	factura_sucursal int, --Fk a Sucursal
	factura_total decimal(38,2),
	CONSTRAINT PK_Factura PRIMARY KEY (factura_numero)
)

ALTER TABLE THIS_IS_FINE.Factura
ADD	CONSTRAINT FK_factura_cliente 
FOREIGN KEY (factura_cliente) REFERENCES THIS_IS_FINE.Cliente(cliente_codigo);

ALTER TABLE THIS_IS_FINE.Factura
ADD	CONSTRAINT FK_factura_sucursal FOREIGN KEY (factura_sucursal) REFERENCES THIS_IS_FINE.Sucursal(sucursal_id);

create table THIS_IS_FINE.Envio(
    envio_numero decimal(18,0),
	envio_fecha_programada datetime2(6),
	envio_fecha datetime2(6),
	envio_importe_traslado decimal(18,2),
	envio_importe_subida decimal(18,2),
	envio_total decimal(18,2),
	envio_factura_numero bigint, --FK factura_numero
	CONSTRAINT PK_Envio PRIMARY KEY (envio_numero)
)

ALTER TABLE THIS_IS_FINE.Envio
ADD constraint FK_Envio_Factura
foreign key (envio_factura_numero) references THIS_IS_FINE.Factura(factura_numero);

create table THIS_IS_FINE.pedido_de_cancelacion (
	pedido_cancelacion_codigo int IDENTITY(1,1),
	pedido_cancelacion_fecha datetime2(6),
	pedido_cancelacion_motivo varchar(255),
	pedido_codigo decimal(18,0),--FK a pedido
	CONSTRAINT PK_Pedido_cancelacion PRIMARY KEY (pedido_cancelacion_codigo)
)

ALTER TABLE THIS_IS_FINE.pedido_de_cancelacion
ADD constraint FK_Pedido_Cancelado
foreign key (pedido_codigo) references THIS_IS_FINE.Pedido(pedido_numero);

create table THIS_IS_FINE.Compra (
	compra_numero decimal(18,0),
	compra_sucursal int,-- FK a Sucursal
	compra_proveedor int,-- FK a Proveedor
	compra_fecha datetime2(6),
	compra_total decimal(18,2),
	CONSTRAINT PK_CompraCodigo PRIMARY KEY (compra_numero)
)

ALTER TABLE THIS_IS_FINE.Compra
ADD constraint FK_Compra_Sucursal
foreign key (compra_sucursal) references THIS_IS_FINE.Sucursal(sucursal_id);

ALTER TABLE THIS_IS_FINE.Compra
ADD constraint FK_Compra_Proveedor
foreign key (compra_proveedor) references THIS_IS_FINE.Proveedor(proveedor_codigo);

/* TABLAS INTERMEDIAS/HIJAS */

CREATE TABLE THIS_IS_FINE.detalle_pedido (
    -- Columnas FK
    pedido_numero   decimal(18,0)   NOT NULL,
    sillon_id       INT          NOT NULL,

    -- Datos propios
    pedido_det_cantidad   BIGINT        NULL,
    pedido_det_precio     DECIMAL(18,2) NULL,
	pedido_det_subtotal	  BIGINT		NULL,

    -- PK compuesta
    CONSTRAINT PK_detalle_pedido
      PRIMARY KEY (pedido_numero, sillon_id),

 );
GO

ALTER TABLE THIS_IS_FINE.detalle_pedido
ADD constraint FK_Detalle_Pedido_Numero
foreign key (pedido_numero) references THIS_IS_FINE.Pedido(pedido_numero);

ALTER TABLE THIS_IS_FINE.detalle_pedido
ADD constraint FK_Detalle_Pedido_Sillon
foreign key (sillon_id) references THIS_IS_FINE.Sillon(sillon_id);

create table THIS_IS_FINE.detalle_factura (
	detalle_factura_numero bigint,--Fk a Factura
	detalle_factura_pedido decimal(18,0), --FK a detalle_pedido
	detalle_factura_sillon int, --FK a detalle_pedido
	detalle_factura_precio decimal(18,2),
	detalle_factura_cantidad decimal(18,0),
	detalle_factura_subtotal decimal(18,2),
	constraint PK_dettaleFactura primary key (detalle_factura_numero, detalle_factura_pedido, detalle_factura_sillon),
)
ALTER TABLE THIS_IS_FINE.detalle_factura
ADD constraint FK_detalleFactura_Factura 
foreign key (detalle_factura_numero) references THIS_IS_FINE.Factura(factura_numero);

ALTER TABLE THIS_IS_FINE.detalle_factura
ADD CONSTRAINT FK_detalle_factura_detalle_pedido
FOREIGN KEY (detalle_factura_pedido, detalle_factura_sillon)
REFERENCES THIS_IS_FINE.detalle_pedido(pedido_numero, sillon_id);


create table THIS_IS_FINE.detalle_compra (
	detalle_compra_numero decimal(18,0), -- FK a Compra
	detalle_compra_material int, -- FK a Material
	detalle_compra_precio decimal(18,2),
	detalle_compra_cantidad decimal(18,0),
	detalle_compra_precio_unitario decimal(18,2),
	detalle_compra_subtotal decimal(18,0),
	CONSTRAINT PK_DetalleCompra PRIMARY KEY (detalle_compra_numero, detalle_compra_material)
)

ALTER TABLE THIS_IS_FINE.detalle_compra
ADD constraint FK_Detalle_Compra_Numero
foreign key (detalle_compra_numero) references THIS_IS_FINE.Compra(compra_numero);

ALTER TABLE THIS_IS_FINE.detalle_compra
ADD constraint FK_Detalle_Compra_Material
foreign key (detalle_compra_material) references THIS_IS_FINE.Material(id_material);

create table THIS_IS_FINE.sillon_material (
	   id_material int, --FK a material
	   sillon_id int, -- FK a sillon
	   CONSTRAINT PK_SillonMaterial PRIMARY KEY (id_material, sillon_id)
)

ALTER TABLE THIS_IS_FINE.sillon_material
ADD constraint FK_Material
foreign key (id_material) references THIS_IS_FINE.Material(id_material);

ALTER TABLE THIS_IS_FINE.sillon_material
ADD constraint FK_Sillon
foreign key (sillon_id) references THIS_IS_FINE.Sillon(sillon_id);
GO

      --------------   MIGRACIONES   -------------- 

/*Insertar Sill�n Modelo de la tabla maestra a tabla modelo_sillon*/
CREATE PROCEDURE THIS_IS_FINE.migrar_sillon_modelo
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

/*Insertar Medidas Sill�n de la tabla maestra a la tabla medida_sillon*/

CREATE PROCEDURE THIS_IS_FINE.migrar_sillon_medida
AS
BEGIN

     SET NOCOUNT ON;

     INSERT INTO THIS_IS_FINE.sillon_medida (
	     sillon_medida_alto,
	     sillon_medida_ancho,
	     sillon_medida_profundidad,
		 sillon_medida_precio
	 )
	 SELECT DISTINCT
	     sillon_medida_alto,
	     sillon_medida_ancho,
	     sillon_medida_profundidad,
		 sillon_medida_precio
     FROM gd_esquema.Maestra
	 WHERE Sillon_Medida_Alto IS NOT NULL AND Sillon_Medida_Ancho IS NOT NULL 
	 AND Sillon_Medida_Profundidad IS NOT NULL AND Sillon_Medida_Precio IS NOT NULL  
END;
GO


/*Insertar Tipo Material de la tabla maestra a la tabla tipo_material*/

CREATE PROCEDURE THIS_IS_FINE.migrar_tipo_material
AS
BEGIN

     SET NOCOUNT ON;

     INSERT INTO THIS_IS_FINE.tipo_material(tipo_material_detalle)
	 SELECT DISTINCT
	     material_tipo 
     FROM gd_esquema.Maestra
	 WHERE material_tipo IS NOT NULL
END; 
go
/*Insertar provincia de la tabla maestra a tabla provincia*/

CREATE PROCEDURE THIS_IS_FINE.migrar_provincia
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
WHERE provincia IS NOT NULL;
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

/*Migración completa de Localidad */
CREATE PROCEDURE THIS_IS_FINE.migrar_localidad
AS
BEGIN
   exec THIS_IS_FINE.migrar_localidades_proveedor; 
   exec THIS_IS_FINE.migrar_localidades_sucursal; 
   exec THIS_IS_FINE.migrar_localidades_cliente;
     
END;
GO

/* Migracion de Cliente */

create or alter procedure THIS_IS_FINE.migrar_cliente
as 
BEGIN 
	insert into THIS_IS_FINE.Cliente 
	(cliente_dni,
	cliente_nombre,
	cliente_apellido,
	cliente_fecha_nacimiento, 
	cliente_mail,
	cliente_telefono,
	cliente_direccion,
	cliente_localidad)
	select distinct Cliente_Dni, Cliente_Nombre, Cliente_Apellido, Cliente_FechaNacimiento, Cliente_Mail, Cliente_Telefono, Cliente_Direccion, localidad_codigo
	from gd_esquema.Maestra maestra
	join THIS_IS_FINE.Localidad on maestra.Cliente_Localidad = localidad_detalle
	join THIS_IS_FINE.Provincia on maestra.Cliente_Provincia = provincia_detalle
	where Cliente_Dni is not null and Cliente_Nombre is not null and Cliente_Apellido is not null and Cliente_FechaNacimiento is not null and Cliente_Telefono is not null and Cliente_Direccion is not null and Cliente_Localidad is not null
	and localidad_provincia = provincia_codigo
END; 
GO

/* Migracion de Sucursal*/

CREATE PROCEDURE THIS_IS_FINE.migrar_sucursal
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
	 JOIN THIS_IS_FINE.Provincia on Loc.localidad_provincia = provincia_codigo 
	 AND Sucursal_Provincia = provincia_detalle
	 WHERE sucursal_NroSucursal IS NOT NULL
END;
GO

CREATE PROCEDURE THIS_IS_FINE.migrar_pedido
AS
BEGIN
    SET NOCOUNT ON;

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
        MAX(ma.Pedido_Fecha),
        MAX(s.sucursal_id),
        MAX(c.cliente_codigo),
        MAX(ma.Pedido_Estado),
        MAX(ma.Pedido_Total)
    FROM gd_esquema.Maestra AS ma
    LEFT JOIN THIS_IS_FINE.Cliente  AS c 
      ON c.cliente_dni = ma.Cliente_Dni
	  AND c.cliente_nombre = ma.Cliente_Nombre
    LEFT JOIN THIS_IS_FINE.Sucursal AS s 
      ON s.sucursal_NroSucursal = ma.Sucursal_NroSucursal 
	  AND s.sucursal_direccion = ma.Sucursal_Direccion
    WHERE ma.Pedido_Numero IS NOT NULL
	AND NOT EXISTS(
	      SELECT 1 FROM THIS_IS_FINE.Pedido pedido
          WHERE pedido.pedido_numero = ma.pedido_Numero)
    GROUP BY ma.Pedido_Numero
END;
GO

CREATE PROCEDURE THIS_IS_FINE.migrar_detalle_pedido
AS
BEGIN

	SET NOCOUNT ON;
	
	INSERT INTO THIS_IS_FINE.detalle_pedido (
		pedido_numero,
		sillon_id,
		pedido_det_cantidad,
		pedido_det_precio,
		pedido_det_subtotal
	)
	SELECT DISTINCT
		p.pedido_numero,
		s.sillon_id,
		m.detalle_pedido_cantidad,
		m.detalle_pedido_precio,
		m.detalle_pedido_subtotal
		FROM gd_esquema.Maestra AS m
		JOIN THIS_IS_FINE.Pedido AS p
		ON p.pedido_numero  = m.pedido_numero
		JOIN THIS_IS_FINE.Sillon AS s
		ON s.sillon_codigo = m.sillon_codigo 
		AND s.sillon_modelo = m.Sillon_Modelo_Codigo --por códigos sillón repetidos
		WHERE m.pedido_numero  IS NOT NULL
		AND m.sillon_codigo  IS NOT NULL
		AND NOT EXISTS(
		         SELECT 1
				 FROM THIS_IS_FINE.detalle_pedido dp
				 WHERE dp.pedido_numero = p.pedido_numero 
				 AND dp.sillon_id = s.sillon_id
        )
END;
GO

/*Migración de Material*/

CREATE PROCEDURE THIS_IS_FINE.migrar_material
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
	 and material_precio IS NOT NULL /*los otros ya quedan filtrados por el JOIN*/
END;
GO

/*Migración de Madera*/

CREATE PROCEDURE THIS_IS_FINE.migrar_madera
AS
BEGIN

     SET NOCOUNT ON;

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
	 AND Tipo.tipo_material_detalle = 'Madera'
	 JOIN THIS_IS_FINE.Material Mat
	 ON Mat.material_tipo = Tipo.tipo_material_id
	 AND Mat.material_nombre = maestra.Material_Nombre 
	 AND Mat.material_precio = maestra.Material_Precio
	 WHERE Madera_Color IS NOT NULL AND madera_dureza IS NOT NULL
	 AND NOT EXISTS(
	     SELECT 1
		 FROM THIS_IS_FINE.Madera Mad
		 WHERE Mad.id_material = Mat.id_material
	 )/*ver si se pueden aceptar nulls*/
END;
GO

/*Migración de Tela*/

CREATE PROCEDURE THIS_IS_FINE.migrar_tela
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
	 AND Tipo.tipo_material_detalle = 'Tela'
	 JOIN THIS_IS_FINE.Material Mat
	 ON Mat.material_tipo = Tipo.tipo_material_id
	 AND Mat.material_nombre = maestra.Material_Nombre 
	 AND Mat.material_precio = maestra.Material_Precio
	 WHERE Tela_Color IS NOT NULL AND tela_textura IS NOT NULL
	 AND NOT EXISTS(
	     SELECT 1
		 FROM THIS_IS_FINE.Tela T
		 WHERE T.id_material = Mat.id_material
     )
END;
GO

/*Migración de Relleno*/

CREATE PROCEDURE THIS_IS_FINE.migrar_relleno
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
	 AND Tipo.tipo_material_detalle = 'Relleno'
	 JOIN THIS_IS_FINE.Material Mat
	 ON Mat.material_tipo = Tipo.tipo_material_id
	 AND Mat.material_nombre = maestra.Material_Nombre 
	 AND Mat.material_precio = maestra.Material_Precio
	 WHERE Relleno_Densidad IS NOT NULL
	 AND NOT EXISTS(
	     SELECT 1
		 FROM THIS_IS_FINE.Relleno Rell
		 WHERE Rell.id_material = Mat.id_material
     )
END;
GO

/*Migración de Sillon*/

CREATE PROCEDURE THIS_IS_FINE.migrar_sillon
AS
BEGIN

     SET NOCOUNT ON;

     INSERT INTO THIS_IS_FINE.Sillon (
	     sillon_codigo,
	     sillon_modelo,
	     sillon_medida
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
	 AND NOT EXISTS(
	      SELECT 1
		  FROM THIS_IS_FINE.Sillon Sill
		  WHERE sill.sillon_codigo = maestra.Sillon_Codigo
     )
END;
GO

/*Migración de Sillon*/

CREATE PROCEDURE THIS_IS_FINE.migrar_sillon_material
AS
BEGIN

     SET NOCOUNT ON;

     INSERT INTO THIS_IS_FINE.sillon_material (
	     id_material,
		 sillon_id
     )
	 SELECT DISTINCT 
	     Mat.id_material,
		 Sill.sillon_id
     FROM gd_esquema.Maestra maestra
	 JOIN THIS_IS_FINE.Sillon Sill 
	 ON maestra.Sillon_Codigo = Sill.sillon_codigo
	 AND maestra.Sillon_Modelo_Codigo = Sill.sillon_modelo
	 JOIN THIS_IS_FINE.Material Mat
	 ON maestra.Material_Nombre+maestra.Material_Descripcion = Mat.material_nombre+Mat.material_descripcion
	 AND maestra.Material_Precio = Mat.material_precio
	 WHERE maestra.sillon_codigo IS NOT NULL and maestra.material_nombre IS NOT NULL
END;
GO

CREATE PROCEDURE THIS_IS_FINE.migrar_factura
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
       MAX(maestra.Factura_Fecha),
       MAX(maestra.Factura_Total),
       MAX(sucursal.sucursal_id),
       MAX(cliente.cliente_codigo)
    FROM gd_esquema.Maestra maestra
    JOIN THIS_IS_FINE.Sucursal sucursal
        ON maestra.Sucursal_NroSucursal = sucursal.sucursal_NroSucursal 
		AND maestra.Sucursal_Direccion = sucursal.sucursal_direccion --por problema con la que se repite
    JOIN THIS_IS_FINE.Cliente cliente
        ON maestra.Cliente_Dni = cliente.cliente_dni
		AND maestra.Cliente_Nombre = cliente.cliente_nombre
    WHERE maestra.Factura_Numero IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM THIS_IS_FINE.Factura factura
          WHERE factura.factura_numero = maestra.Factura_Numero
      )
    GROUP BY maestra.Factura_Numero
END;
GO

CREATE PROCEDURE THIS_IS_FINE.migrar_detalle_factura
AS
BEGIN
    INSERT INTO THIS_IS_FINE.detalle_factura (
        detalle_factura_numero,
	    detalle_factura_pedido,
		detalle_factura_sillon,
	    detalle_factura_precio,
	    detalle_factura_cantidad,
	    detalle_factura_subtotal
    )
    SELECT
        factura.factura_numero,
        dp.pedido_Numero,
		dp.sillon_id,
        maestra.Detalle_Factura_Precio,
        maestra.Detalle_Factura_Cantidad,
        maestra.Detalle_Factura_SubTotal
    FROM gd_esquema.Maestra maestra
    JOIN THIS_IS_FINE.Factura factura 
	ON factura.factura_numero = maestra.Factura_Numero
	JOIN THIS_IS_FINE.Pedido p
		ON p.pedido_numero  = maestra.pedido_numero
		JOIN THIS_IS_FINE.Sillon s
		ON s.sillon_codigo = maestra.sillon_codigo 
		AND s.sillon_modelo = maestra.Sillon_Modelo_Codigo 
    JOIN THIS_IS_FINE.detalle_pedido dp 
	ON dp.pedido_numero = p.pedido_numero
	AND dp.sillon_id = s.sillon_id
   
END;
GO

/*Migración de Proveedor*/

CREATE PROCEDURE THIS_IS_FINE.migrar_proveedor
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

CREATE PROCEDURE THIS_IS_FINE.migrar_compra
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
		 MAX(Suc.sucursal_id),
		 MAX(Prov.proveedor_codigo),
		 MAX(compra_fecha),
		 MAX(compra_total)
     FROM gd_esquema.Maestra maestra
	 LEFT JOIN THIS_IS_FINE.Proveedor Prov
	 ON maestra.Proveedor_Cuit = Prov.proveedor_cuit /*está todo en null así que no sé si trae bien las cosas o si los cuit se repiten*/
	 JOIN THIS_IS_FINE.Sucursal Suc
	 ON maestra.Sucursal_NroSucursal = Suc.Sucursal_NroSucursal
	 AND maestra.Sucursal_Direccion = Suc.Sucursal_direccion 
	 /*Hay un nro de sucursal que se repite*/
	 WHERE compra_numero IS NOT NULL
	 AND NOT EXISTS (
          SELECT 1 FROM THIS_IS_FINE.Compra Comp
          WHERE Comp.Compra_numero = maestra.Compra_Numero
      )
	  GROUP BY compra_numero
END;
GO

/*Migración de detalle_compra*/

CREATE PROCEDURE THIS_IS_FINE.migrar_detalle_compra
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
	 ON maestra.Material_Nombre+maestra.Material_Descripcion = Mat.material_nombre+Mat.material_descripcion
	 AND maestra.Material_Precio = Mat.material_precio
	 WHERE Mat.material_nombre IS NOT NULL 
END;
GO

/*Migración de Envío*/

CREATE PROCEDURE THIS_IS_FINE.migrar_envio
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

CREATE PROCEDURE THIS_IS_FINE.migrar_pedido_de_cancelacion
AS
BEGIN

     SET NOCOUNT ON;

     INSERT INTO THIS_IS_FINE.pedido_de_cancelacion (
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

/* EJECUCIÓN DE LOS PROCEDURES EN ORDEN CORRESPONDIENTE */
exec THIS_IS_FINE.migrar_provincia;
exec THIS_IS_FINE.migrar_sillon_modelo;
exec THIS_IS_FINE.migrar_sillon_medida;
exec THIS_IS_FINE.migrar_tipo_material;
exec THIS_IS_FINE.migrar_localidad;
exec THIS_IS_FINE.migrar_cliente
exec THIS_IS_FINE.migrar_proveedor;
exec THIS_IS_FINE.migrar_sucursal;
exec THIS_IS_FINE.migrar_sillon;
exec THIS_IS_FINE.migrar_material;
exec THIS_IS_FINE.migrar_madera;
exec THIS_IS_FINE.migrar_tela;
exec THIS_IS_FINE.migrar_relleno;
exec THIS_IS_FINE.migrar_pedido;
exec THIS_IS_FINE.migrar_factura;
exec THIS_IS_FINE.migrar_envio;
exec THIS_IS_FINE.migrar_pedido_de_cancelacion;
exec THIS_IS_FINE.migrar_compra;
exec THIS_IS_FINE.migrar_detalle_pedido;
exec THIS_IS_FINE.migrar_detalle_factura;
exec THIS_IS_FINE.migrar_detalle_compra;
exec THIS_IS_FINE.migrar_sillon_material;

GO

                       /*CREACIÓN DE ÍNDICES*/

        /* ÍNDICES PARA BÚSQUEDAS POR NOMBRES O CÓDIGOS EN TABLAS DE DATOS MAESTROS*/
/* PARA CLIENTES */
CREATE INDEX IX_Cliente_Nombre_Apellido ON THIS_IS_FINE.Cliente(cliente_nombre,cliente_apellido);
CREATE INDEX IX_Cliente_DNI ON THIS_IS_FINE.Cliente(cliente_dni);
CREATE INDEX IX_Cliente_Mail ON THIS_IS_FINE.Cliente(cliente_mail);
/* PARA SUCURSALES */
CREATE INDEX IX_Sucursal_Numero ON THIS_IS_FINE.Sucursal(sucursal_NroSucursal);--Como no es PK, sirve tenerlo en un índice
CREATE INDEX IX_Sucursal_Mail ON THIS_IS_FINE.Sucursal(sucursal_mail);
/* PARA PROVEEDORES */
CREATE INDEX IX_Proveedor_Cuit ON THIS_IS_FINE.Proveedor(proveedor_cuit);
CREATE INDEX IX_Proveedor_Razon_Social ON THIS_IS_FINE.Proveedor(proveedor_razon_social);
CREATE INDEX IX_Proveedor_Mail ON THIS_IS_FINE.Proveedor(proveedor_mail);
/* PARA UBICACIONES POR NOMBRE (PROVINCIAS Y LOCALIDADES) */
CREATE INDEX IX_Provincia_Nombre ON THIS_IS_FINE.Provincia(provincia_detalle);
CREATE INDEX IX_Localidad_Nombre ON THIS_IS_FINE.Localidad(localidad_detalle);
/* PARA MATERIALES Y SUS TIPOS POR NOMBRE */
CREATE INDEX IX_Material_Nombre ON THIS_IS_FINE.Material(material_nombre);
CREATE INDEX IX_Tipo_Material_Detalle ON THIS_IS_FINE.tipo_material(tipo_material_detalle);
/* PARA SILLONES */
CREATE INDEX IX_Sillon_Codigo ON THIS_IS_FINE.Sillon(sillon_codigo);
CREATE INDEX IX_Sillon_Diseño ON THIS_IS_FINE.Sillon(sillon_modelo, sillon_medida); --filtrar por combinaciones

       /* PARA BÚSQUEDAS POR FECHAS O POR CLAVES FORÁNEAS EN TRANSACCIONES */
/* PARA FACTURAS */
CREATE INDEX IX_Factura_Fecha ON THIS_IS_FINE.Factura(factura_fecha);
CREATE INDEX IX_Factura_Cliente ON THIS_IS_FINE.Factura(factura_cliente);
CREATE INDEX IX_Factura_Sucursal ON THIS_IS_FINE.Factura(factura_sucursal);
/* PARA PEDIDOS */
CREATE INDEX IX_Pedido_Fecha ON THIS_IS_FINE.Pedido(pedido_fecha);
CREATE INDEX IX_Pedido_Cliente ON THIS_IS_FINE.Pedido(pedido_cliente);
CREATE INDEX IX_Pedido_Sucursal ON THIS_IS_FINE.Pedido(pedido_sucursal);
/* PARA COMPRAS */
CREATE INDEX IX_Compras_Fecha ON THIS_IS_FINE.Compra(compra_fecha);
CREATE INDEX IX_Compras_Proveedor ON THIS_IS_FINE.Compra(compra_proveedor);
CREATE INDEX IX_Compras_Sucursal ON THIS_IS_FINE.Compra(compra_sucursal);
/* PARA ENVÍOS */
CREATE INDEX IX_Envio_Fecha ON THIS_IS_FINE.Envio(envio_fecha);
CREATE INDEX IX_Envio_Fecha_Programada ON THIS_IS_FINE.Envio(envio_fecha_programada);
CREATE INDEX IX_Envio_Factura ON THIS_IS_FINE.Envio(envio_factura_numero);
/* PARA PEDIDO DE CANCELACIÓN */
CREATE INDEX IX_Pedido_Cancelacion_Fecha ON THIS_IS_FINE.pedido_de_cancelacion(pedido_cancelacion_fecha);
CREATE INDEX IX_Pedido_Cancelado ON THIS_IS_FINE.pedido_de_cancelacion(pedido_codigo);
CREATE INDEX IX_Pedido_Cancelado_Motivo ON THIS_IS_FINE.pedido_de_cancelacion(pedido_cancelacion_motivo);
-- Útil si motivo acepta mensajes estándar (o para filtrar por aquellos "Sin motivo")
/* PARA BÚSQUEDAS O FILTROS POR MONTOS TOTALES DE LAS TRANSACCIONES */
CREATE INDEX IX_Factura_Total ON THIS_IS_FINE.Factura(factura_total);
CREATE INDEX IX_Pedido_Total ON THIS_IS_FINE.Pedido(pedido_total);
CREATE INDEX IX_Compra_Total ON THIS_IS_FINE.Compra(compra_total);
/* PARA BÚSQUEDAS O FILTROS POR TIPOS DE MATERIALES */
CREATE INDEX IX_Madera_Color ON THIS_IS_FINE.Madera(madera_color);
CREATE INDEX IX_Madera_Dureza ON THIS_IS_FINE.Madera(madera_dureza);
CREATE INDEX IX_Tela_Color ON THIS_IS_FINE.Tela(tela_color);
CREATE INDEX IX_Tela_Textura ON THIS_IS_FINE.Tela(tela_textura);
CREATE INDEX IX_Relleno_Densidad ON THIS_IS_FINE.Relleno(relleno_densidad);









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
