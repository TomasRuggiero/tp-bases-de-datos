/* SCRIPT TP GDD MIGRACION DE DATOS */ 

use GD1C2025;
GO

/*if not exists(SELECT * from sys.schemas where name='THIS_IS_FINE')
BEGIN
EXEC*/(/*'*/ create schema THIS_IS_FINE;/*'*/)
--END

drop table if exists THIS_IS_FINE.Provincia;

drop table if exists THIS_IS_FINE.Localidad;

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

-- Tablas relativamente independientes
DROP TABLE IF EXISTS THIS_IS_FINE.Sillon;
DROP TABLE IF EXISTS THIS_IS_FINE.modelo_sillon;
DROP TABLE IF EXISTS THIS_IS_FINE.medida_sillon;
DROP TABLE IF EXISTS THIS_IS_FINE.Material;
DROP TABLE IF EXISTS THIS_IS_FINE.tipo_material;
DROP TABLE IF EXISTS THIS_IS_FINE.Proveedor;
DROP TABLE IF EXISTS THIS_IS_FINE.Cliente;
DROP TABLE IF EXISTS THIS_IS_FINE.Sucursal;
DROP TABLE IF EXISTS THIS_IS_FINE.Localidad;
DROP TABLE IF EXISTS THIS_IS_FINE.Provincia;


create table THIS_IS_FINE.Cliente (
	cliente_codigo INT IDENTITY(1,1),
	cliente_dni NVARCHAR(100),
	cliente_nombre NVARCHAR(100),
	cliente_apellido NVARCHAR(100),
	cliente_fecha_nacimiento datetime2(6),
	cliente_mail NVARCHAR(100),
	cliente_telefono NVARCHAR(100),
	cliente_direccion NVARCHAR(100)
	-- Agregar FK a Localidad
	CONSTRAINT PK_Cliente PRIMARY KEY (cliente_codigo)
)

create table THIS_IS_FINE.Provincia (
	provincia_codigo INTEGER IDENTITY(1,1),
	provincia_detalle NVARCHAR(255),
	CONSTRAINT PK_Provincia PRIMARY KEY (provincia_codigo)
)

create table THIS_IS_FINE.Localidad (
	localidad_codigo INTEGER IDENTITY(1,1),
	localidad_detalle NVARCHAR(255),
	localidad_provincia INTEGER
	-- Agregar FK a Provincia
	CONSTRAINT PK_Localidad PRIMARY KEY (localidad_codigo)
)

/*
ALTER TABLE THIS_IS_FINE.Localidad
ADD CONSTRAINT FK_localidad_provincia FOREIGN KEY (localidad_provincia)
REFERENCES THIS_IS_FINE.Provincia(provincia_codigo);
*/

create table THIS_IS_FINE.Proveedor (
	proveedor_codigo INTEGER IDENTITY(1,1),
	proveedor_cuit NVARCHAR(100),
	proveedor_razon_social NVARCHAR(100),
	proveedor_direccion NVARCHAR(100),
	proveedor_telefono	NVARCHAR(100),
	proveedor_mail NVARCHAR(100)
	-- Agregar FK a Localidad
	CONSTRAINT PK_Proveedor PRIMARY KEY (proveedor_codigo)
)

create table THIS_IS_FINE.Factura (
	factura_numero bigint,
	factura_fecha datetime2(6),
	-- FK a Cliente
	factura_total decimal(38,2),
	--Fk a Sucursal
	CONSTRAINT PK_Factura PRIMARY KEY (factura_numero)
)

create table THIS_IS_FINE.Sucursal (
	sucursal_NroSucursal bigint, 
	sucursal_localidad int,
	sucursal_direccion nvarchar(255),
	sucursal_telefono nvarchar(255),
	sucursal_mail nvarchar(255),
	CONSTRAINT PK_Sucursal PRIMARY KEY (sucursal_Nrosucursal)
)

/*Creación de FK Sucursal_localidad*/

ALTER TABLE THIS_IS_FINE.Sucursal
ADD CONSTRAINT FK_Sucursal_Localidad
FOREIGN KEY (sucursal_localidad) REFERENCES THIS_IS_FINE.Localidad(localidad_codigo);

create table THIS_IS_FINE.detalle_factura (
	--Fk a Factura
	--FK a pedido
	fact_det_precio decimal(18,2),
	fact_det_cantidad decimal(18,0),
	fact_det_subtotal decimal(18,2)
	--CONSTRAINT PK_detalleFactura PRIMARY KEY (fact_det_factura, fact_det_pedido)
)

create table THIS_IS_FINE.Pedido (
	pedido_numero decimal(18,0),
	pedido_fecha datetime2(6),
	--FK a Sucursal 
	pedido_estado nvarchar(255),
	--FK a cliente
	pedido_total decimal(18,2),
	CONSTRAINT PK_Pedido PRIMARY KEY (pedido_numero)
)

create table THIS_IS_FINE.detalle_pedido (
	--FK a Pedido 
	-- FK a sillon
	-- PK es (pedido, sillon)
	pedido_det_cantidad bigint,
	pedido_det_precio decimal(18,2),
	--pedido_det_subtotal discutir que hacer con esto
)

create table THIS_IS_FINE.pedido_cancelacion (
	cancel_pedido_codigo int,
	cancel_pedido_fecha datetime2(6),
	--FK a pedido
	CONSTRAINT PK_Pedido_cancelacion PRIMARY KEY (cancel_pedido_codigo)
)

create table THIS_IS_FINE.Sillon (
	sillon_codigo bigint,
	-- FK a sillon modelo
	-- FK a sillon medida
	CONSTRAINT PK_Sillon PRIMARY KEY (sillon_codigo)
)

create table THIS_IS_FINE.modelo_sillon (
	sillon_modelo_codigo bigint,
	sillon_modelo_descripcion nvarchar(255),
	sillon_modelo_precio decimal(18,2),
	CONSTRAINT PK_ModeloSillon PRIMARY KEY (sillon_modelo_codigo)
)

create table THIS_IS_FINE.medida_sillon (
	sillon_medida_codigo int IDENTITY(1,1),
	sillon_medida_alto decimal(18,2),
	sillon_medida_ancho decimal(18,2),
	sillon_medida_profundidad decimal(18,2),
	sillon_medida_precio decimal(18,2),
	CONSTRAINT PK_MedidaSillon PRIMARY KEY (sillon_medida_codigo)
)

create table THIS_IS_FINE.Compra (
	compra_codigo decimal(18,0),
	-- FK a Sucursal
	-- FK a Envio
	-- FK a Proveedor
	compra_fecha datetime2(6),
	compra_total decimal(18,2),
	CONSTRAINT PK_CompraCodigo PRIMARY KEY (compra_codigo)
)

create table THIS_IS_FINE.detalle_compra (
	-- FK a Compra
	-- FK a Material
	compra_precio_unitario decimal(18,2),
	compra_cantidad decimal(18,0),
	compra_subtotal decimal(18,0),
	--CONSTRAINT PK_DetalleCompra PRIMARY KEY (compra_codigo, material_codigo)
)

create table THIS_IS_FINE.sillon_material (
	--FK a sillon
	-- Fk a material
	material_cantidad decimal(18,2),
	--CONSTRAINT PK_SillonMaterial PRIMARY KEY (sillon_codigo, material_codigo)
)

create table THIS_IS_FINE.Material (
    id_material int IDENTITY(1,1),
	material_tipo int,
	material_nombre nvarchar(255),
	material_descripcion nvarchar(255),
	material_precio decimal(38,2),
	CONSTRAINT PK_Material PRIMARY KEY (id_material)
)

/*Creación FK Material_tipo*/
ALTER TABLE THIS_IS_FINE.Material
ADD CONSTRAINT FK_Material_Tipo
FOREIGN KEY (material_tipo) REFERENCES THIS_IS_FINE.tipo_material(tipo_material_id);

create table THIS_IS_FINE.Madera (
    id_material int,
	madera_color nvarchar(255),
	madera_dureza nvarchar(255)
	CONSTRAINT PK_Madera PRIMARY KEY (id_material),
)

/*Creación FK Madera a Material*/
ALTER TABLE THIS_IS_FINE.Madera
ADD CONSTRAINT FK_Madera_Material
FOREIGN KEY (id_material) REFERENCES THIS_IS_FINE.Material (id_material) 


create table THIS_IS_FINE.Tela (
    id_material int,
	tela_color nvarchar(255),
	tela_textura nvarchar(255)
	CONSTRAINT PK_Tela PRIMARY KEY (id_material),
)

/*Creación FK Tela a Material*/
ALTER TABLE THIS_IS_FINE.Tela
ADD CONSTRAINT FK_Tela_Material 
FOREIGN KEY (id_material) REFERENCES THIS_IS_FINE.Material(id_material) 

create table THIS_IS_FINE.Relleno (
    id_material int,
	relleno_densidad decimal(38,2)
	CONSTRAINT PK_Relleno PRIMARY KEY (id_material),
)
/*Creación FK Relleno a Material*/
ALTER TABLE THIS_IS_FINE.Relleno
ADD CONSTRAINT FK_Relleno_Material 
FOREIGN KEY (id_material) REFERENCES THIS_IS_FINE.Material (id_material)

create table THIS_IS_FINE.tipo_material (
     tipo_material_id int IDENTITY(1,1) PRIMARY KEY,
	 tipo_material_detalle nvarchar(255)
	 -- CONSTRAINT PK_TipoMaterial PRIMARY KEY (tipo_material_id)
) /*Ver si dejamos esto as�*/


/* A DISCUTIR: 
	- Que hacemos con tipo_material.
	- No estamos reflejando bien la relacion muchos a muchos de sillon-material, deberiamos partir la relacion con tabla intermedia
	sino no podemos reflejar de que materiales se hizo el sillon 
	- tipos de datos para las PKs
*/

/*Insertar Sill�n Modelo de la tabla maestra a tabla modelo_sillon*/
GO

CREATE PROCEDURE THIS_IS_FINE.migrar_modelo_sillon
AS
BEGIN

     SET NOCOUNT ON;

     INSERT INTO THIS_IS_FINE.modelo_sillon (
	      sillon_modelo_codigo, 
	      sillon_modelo_descripcion,
	      sillon_modelo_precio
     )
	 SELECT DISTINCT 
	      sillon_modelo_codigo, 
		  sillon_modelo_descripcion,
		  sillon_modelo_precio
     FROM gd_esquema.Maestra
	 WHERE sillon_modelo_codigo IS NOT NULL
	/*C�mo hac�amos entonces con los NULL?*/
END;
GO

/*Insertar Medidas Sill�n de la tabla maestra a la tabla medida_sillon*/

CREATE PROCEDURE THIS_IS_FINE.migrar_medida_sillon
AS
BEGIN

     SET NOCOUNT ON;

     INSERT INTO THIS_IS_FINE.medida_sillon (
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
END; /*Despu�s vemos si esto lo dejamos as�*/
GO

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

CREATE PROCEDURE THIS_IS_FINE.migrar_localidades_proveedor
AS
BEGIN
INSERT INTO THIS_IS_FINE.Localidad (localidad_detalle, localidad_provincia)
SELECT DISTINCT
    maestra.Proveedor_Localidad,
    Prov.provincia_codigo
FROM gd_esquema.Maestra maestra
JOIN THIS_IS_FINE.Provincia Prov 
  ON Prov.provincia_detalle = maestra.Proveedor_Provincia
WHERE maestra.Proveedor_Provincia IS NOT NULL
  AND maestra.Proveedor_Localidad IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM THIS_IS_FINE.Localidad Loc
      WHERE Loc.localidad_detalle = maestra.Proveedor_Localidad and Loc.localidad_provincia = Prov.provincia_codigo
  	)
END;
GO
/*insertando localidades de sucursal*/

CREATE PROCEDURE THIS_IS_FINE.migrar_localidades_sucursal
AS
BEGIN
INSERT INTO THIS_IS_FINE.Localidad (localidad_detalle, localidad_provincia)
SELECT DISTINCT
    maestra.Sucursal_Localidad,
    Prov.provincia_codigo
FROM gd_esquema.Maestra maestra
JOIN THIS_IS_FINE.Provincia Prov
  ON Prov.provincia_detalle = maestra.Sucursal_Provincia
WHERE maestra.Sucursal_Provincia IS NOT NULL
  AND maestra.Sucursal_Localidad IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM THIS_IS_FINE.Localidad Loc
      WHERE Loc.localidad_detalle = maestra.Sucursal_Localidad and Loc.localidad_provincia = Prov.provincia_codigo
  	)
END;
GO
/*insertando localidades de cliente*/

CREATE PROCEDURE THIS_IS_FINE.migrar_localidades_cliente
AS
BEGIN
INSERT INTO THIS_IS_FINE.Localidad (localidad_detalle, localidad_provincia)
SELECT DISTINCT
    maestra.Cliente_Localidad,
    Prov.provincia_codigo
FROM gd_esquema.Maestra maestra
JOIN THIS_IS_FINE.Provincia Prov    
  ON Prov.provincia_detalle = maestra.Cliente_Provincia
WHERE maestra.Cliente_Provincia IS NOT NULL
  AND maestra.Cliente_Localidad IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM THIS_IS_FINE.Localidad Loc
      WHERE Loc.localidad_detalle = maestra.Cliente_Localidad and Loc.localidad_provincia = Prov.provincia_codigo
	)
END;
GO

/* Migracion de Cliente */

create procedure migrar_cliente
as 
BEGIN 
	insert into THIS_IS_FINE.Cliente (cliente_dni, cliente_nombre, cliente_apellido, cliente_fecha_nacimiento, cliente_mail, cliente_telefono, cliente_direccion)
	select distinct Cliente_Dni, Cliente_Nombre, Cliente_Apellido, Cliente_FechaNacimiento, Cliente_Mail, Cliente_Telefono, Cliente_Direccion
	from gd_esquema.Maestra
	where Cliente_Dni is not null and Cliente_Nombre is not null and Cliente_Apellido is not null and Cliente_FechaNacimiento is not null and Cliente_Telefono is not null and Cliente_Direccion is not null 
END 

exec migrar_cliente;	


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
	 WHERE sucursal_NroSucursal IS NOT NULL
	/*Cómo hacíamos entonces con los NULL?*/
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
	 and material_precio IS NOT NULL /*los otros ya quedan filtrados por el JOIN?, 
	 tampoco sé si podemos traer los materiales si no tienen descripción o precio */
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
	 JOIN THIS_IS_FINE.Material Mat
	 ON Mat.material_tipo = Tipo.tipo_material_id
	 WHERE Tipo.tipo_material_detalle = 'Madera'
	 AND Madera_Color IS NOT NULL AND madera_dureza IS NOT NULL /*ver si se pueden aceptar nulls*/
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
	 JOIN THIS_IS_FINE.Material Mat
	 ON Mat.material_tipo = Tipo.tipo_material_id
	 WHERE Tipo.tipo_material_detalle = 'Tela'
	 AND Tela_Color IS NOT NULL AND tela_textura IS NOT NULL /*ver si se pueden aceptar nulls*/
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
	 JOIN THIS_IS_FINE.Material Mat
	 ON Mat.material_tipo = Tipo.tipo_material_id
	 WHERE Tipo.tipo_material_detalle = 'Relleno'
	 AND Relleno_Densidad IS NOT NULL /*ver si se pueden aceptar nulls*/
END;
GO